import 'dart:async';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/external_link.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../upgrade/upgrade_plan_controller.dart';
import '../upgrade/upgrade_plan_logic.dart' show jsNumber, jsNumberString, paymentOrderId;
import '../users/users_controller.dart';
import 'student_payment_checkout.dart';
import 'student_payment_controller.dart';
import 'student_payment_dialogs.dart';
import 'student_payment_logic.dart';
import 'student_payment_widgets.dart';

/// `view`: 'loading' | 'error' | 'checkout' | 'polling' | 'result'
enum _View { loading, error, checkout, polling, result }

/// What started a payment-status check.
enum _Check {
  /// The web's `setInterval` (every 5 s).
  poll,

  /// Native: the app regained focus after the browser.
  resume,

  /// Native: the "Check payment status" button.
  manual,
}

/// Port of
/// `src/components/new_ui_student_teacher_for_both_labs/studentpayment.vue`
/// — the student "Review Your Order" checkout (subscription plans, referral
/// code, 18 % GST, payment history + invoice). Used at `/studentupgradeplan`
/// (eLabs DashboardShell) and `/newlayout/studentupgradeplan` (MathZoro
/// shell); the component has no flavor or role branches.
///
/// [classId] is the `class_id` query parameter (`$route.query.class_id`),
/// only used to filter the payment history (falls back to
/// `userInfo.classes_id`).
///
/// Payment: `POST /payment/create` → the gateway page opens in the external
/// browser (the web opened a popup tab) → `POST /payment/status` every 5 s
/// like the web, plus right away when the app regains focus and from a
/// "Check payment status" button.
class StudentPaymentPage extends ConsumerStatefulWidget {
  const StudentPaymentPage({super.key, this.classId});
  final String? classId;

  @override
  ConsumerState<StudentPaymentPage> createState() => _StudentPaymentPageState();
}

class _StudentPaymentPageState extends ConsumerState<StudentPaymentPage> {
  double _referralDiscount = 0;
  // `partnerShare` (`partner_share` of the referral check) is stored by the
  // web but never displayed or sent, so it is not kept here.
  _View _view = _View.loading;
  String? _errorMessage;
  List<Map<String, dynamic>> _allPlans = [];
  List<Map<String, dynamic>> _selectedPlans = [];
  String _activeTab = 'order';

  bool _paymentLoading = false;
  String? _paymentError;
  PaymentResult? _paymentResult;
  Timer? _pollInterval;
  String? _pendingPaymentUrl;
  bool _popupBlocked = false;

  final _referralCode = TextEditingController();
  bool _referralApplied = false;
  String _referralError = '';

  List<dynamic> _paymentHistory = [];
  bool _historyLoading = false;

  // ── Native: payment page open in the external browser ──
  String? _pendingOrderId;
  bool _checkingStatus = false;
  DateTime? _lastAutoCheck;
  late final AppLifecycleListener _lifecycle;

  StudentPaymentController get _ctrl => ref.read(studentPaymentControllerProvider.notifier);
  UpgradePlanController get _payment => ref.read(upgradePlanControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _referralCode.addListener(_onReferralChanged);
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    // mounted()
    Future.microtask(() {
      if (!mounted) return;
      _getUserById();
      _loadPlans();
      _loadPaymentHistory();
    });
  }

  @override
  void dispose() {
    // beforeUnmount()
    _stopPolling();
    _lifecycle.dispose();
    _referralCode.removeListener(_onReferralChanged);
    _referralCode.dispose();
    super.dispose();
  }

  void _onReferralChanged() {
    if (mounted) setState(() {});
  }

  /// `getUserById()` — not awaited on mount; failures only reach the console
  /// on the web.
  Future<void> _getUserById() async {
    try {
      await ref.read(usersControllerProvider.notifier).getUserById();
    } catch (_) {}
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PLANS
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadPlans() async {
    setState(() {
      _view = _View.loading;
      _errorMessage = null;
    });
    try {
      final res = await _ctrl.mathzorogetAppSubscriptionPlans();
      final raw = rawPlansOf(res);
      // The web fails on `raw.filter` when the list is not an array.
      if (raw == null) throw const FormatException();
      final plans = paidPlansOf(raw);
      if (!mounted) return;
      setState(() => _allPlans = plans);
      if (plans.isEmpty) throw const _PlanError('No plans available');
      // Auto-select the first plan
      setState(() {
        _selectedPlans = [plans.first];
        _view = _View.checkout;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e is _PlanError ? e.message : jsErrorMessage(e, 'Failed to load plans');
        _view = _View.error;
      });
    }
  }

  bool _isPlanSelected(Map<String, dynamic> plan) => _selectedPlans.any((p) => p['id'] == plan['id']);

  void _togglePlan(Map<String, dynamic> plan) {
    if (_isPlanSelected(plan)) return; // already selected
    setState(() => _selectedPlans = [plan]);
    if (plan['allow_referral_code'] == false) {
      setState(() {
        _referralApplied = false;
        _referralDiscount = 0;
        _referralError = '';
      });
      _referralCode.text = '';
    } else if (_referralApplied) {
      _applyReferral();
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAYMENT
  // ─────────────────────────────────────────────────────────────────────────

  OrderTotals get _totals => OrderTotals.of(_selectedPlans, _referralDiscount);

  /// Step 1 — open the confirm modal.
  Future<void> _openConfirmModal() async {
    if (_selectedPlans.isEmpty) {
      setState(() => _paymentError = 'Please select at least one plan.');
      return;
    }
    setState(() => _paymentError = null);
    final confirmed = await showPaymentModal<bool>(
      context,
      builder: (_) => ConfirmPaymentDialog(
        plans: _selectedPlans,
        referralApplied: _referralApplied,
        referralCode: _referralCode.text,
        grandTotal: _totals.grandTotal,
      ),
    );
    if (confirmed == true && mounted) _startPayment();
  }

  /// Step 2 — "Confirm & Pay": create the order, open the gateway, poll.
  Future<void> _startPayment() async {
    setState(() {
      _paymentLoading = true;
      _paymentError = null;
    });
    try {
      final response = await _payment.createPaymentOrderAction(
        type: 'subscription_plan',
        subscriptionPlanIds: [for (final p in _selectedPlans) jsDisplay(p['id'])],
        referralCode: _referralCode.text,
      );
      final paymentUrl = studentPaymentUrl(response);
      final orderId = paymentOrderId(response);
      if (paymentUrl == null) throw const _PlanError('No payment URL received from server');
      if (orderId == null) throw const _PlanError('No order ID received from server');
      if (!mounted) return;

      setState(() {
        _view = _View.polling;
        _pendingOrderId = orderId;
        _lastAutoCheck = null;
      });
      _openPaymentWindow(paymentUrl);
      _startPolling(orderId);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _paymentError = e is _PlanError ? e.message : jsErrorMessage(e, 'Failed to initiate payment');
        _view = _View.checkout;
      });
    } finally {
      if (mounted) setState(() => _paymentLoading = false);
    }
  }

  /// Step 3 — open the payment URL (external browser instead of a popup).
  Future<void> _openPaymentWindow(String? url) async {
    setState(() {
      _pendingPaymentUrl = url;
      _popupBlocked = false;
    });
    // openExternal already toasts when the browser cannot be opened.
    final ok = await openExternal(url);
    if (!ok && mounted) setState(() => _popupBlocked = true);
  }

  /// Step 4 — poll the payment status every 5 seconds.
  void _startPolling(String orderId) {
    _stopPolling();
    _pollInterval = Timer.periodic(const Duration(seconds: 5), (_) => _checkStatus(orderId, _Check.poll));
  }

  void _stopPolling() {
    _pollInterval?.cancel();
    _pollInterval = null;
  }

  void _onResume() {
    final id = _pendingOrderId;
    if (!mounted || _view != _View.polling || id == null) return;
    final now = DateTime.now();
    // Desktop reports every window focus change; don't re-check on each one.
    if (_lastAutoCheck != null && now.difference(_lastAutoCheck!) < const Duration(seconds: 3)) return;
    _lastAutoCheck = now;
    _checkStatus(id, _Check.resume);
  }

  /// The polling callback (`getPaymentStatusAction(orderId)`).
  Future<void> _checkStatus(String orderId, _Check trigger) async {
    if (!mounted || _checkingStatus) return;
    setState(() => _checkingStatus = true);
    try {
      final result = await _payment.getPaymentStatusAction(orderId, silent: trigger == _Check.resume);
      // Cancelled (or finished) while the request was running.
      if (!mounted || _view != _View.polling || _pendingOrderId != orderId) return;

      final reading = PollReading.of(result);
      switch (reading.outcome) {
        case PollOutcome.success:
          // ✅ PAYMENT SUCCEEDED
          _stopPolling();
          await ref.read(usersControllerProvider.notifier).getUserById();
          if (!mounted) return;
          setState(() {
            _paymentResult = PaymentResult(
              success: true,
              amount: reading.amount,
              transactionId: reading.transactionId(orderId),
            );
            _view = _View.result;
            _pendingOrderId = null;
          });
          AppToast.success('Payment successful!');
          _loadPaymentHistory();
        case PollOutcome.failed:
          // ❌ PAYMENT FAILED
          _stopPolling();
          setState(() {
            _paymentResult = PaymentResult(
              success: false,
              message: reading.failureMessage,
              transactionId: reading.transactionId(orderId),
            );
            _view = _View.result;
            _pendingOrderId = null;
          });
          AppToast.error(reading.failureToast);
          _loadPaymentHistory();
        case PollOutcome.pending:
          // 'pending' / 'initiated' / no status yet → keep polling.
          if (trigger == _Check.manual) {
            AppToast.info('Payment is still pending. Complete it in your browser, then check again.');
          }
      }
    } catch (_) {
      // "[Payment Poll] Error checking status" — console only on the web.
    } finally {
      if (mounted) setState(() => _checkingStatus = false);
    }
  }

  /// "Cancel & go back" on the polling screen.
  void _cancelPayment() {
    _stopPolling();
    setState(() {
      _pendingPaymentUrl = null;
      _pendingOrderId = null;
      _popupBlocked = false;
      _paymentError = null;
      _view = _View.checkout;
      _activeTab = 'history';
    });
    _loadPaymentHistory();
  }

  /// "Back to Checkout" / "Try Again" / "Start Learning" on the result screen.
  void _goToCheckout() {
    _stopPolling();
    setState(() {
      _paymentResult = null;
      _paymentError = null;
      _pendingPaymentUrl = null;
      _pendingOrderId = null;
      _popupBlocked = false;
      _view = _View.checkout; // the checkout scroll view starts at the top
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  REFERRAL CODE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _applyReferral() async {
    final code = _referralCode.text.trim();
    if (code.isEmpty) return;
    try {
      setState(() => _referralError = '');
      final response = await _ctrl.mathzorovalidateReferralCodeAction({
        'referral_code': code,
        'platform': 'web',
        'plan_type': 'subscription_plan',
        'subscription_plan_ids': [for (final p in _selectedPlans) jsDisplay(p['id'])],
      });
      if (!mounted) return;
      final r = asMap(response);
      if (jsTruthy(r?['valid'])) {
        setState(() {
          _referralApplied = true;
          _referralDiscount = jsNumber(firstTruthy([r!['customer_discount']]) ?? 0);
        });
        AppToast.success('Referral applied! ${jsNumberString(_referralDiscount)}% discount');
      } else {
        setState(() {
          _referralApplied = false;
          _referralDiscount = 0;
          _referralError = jsTruthy(r?['msg']) ? '${r!['msg']}' : 'Invalid referral code';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _referralApplied = false;
        _referralError = referralErrorText(e);
      });
    }
  }

  void _removeReferral() {
    setState(() {
      _referralApplied = false;
      _referralError = '';
    });
    _referralCode.text = '';
    AppToast.info('Referral code removed.');
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  PAYMENT HISTORY / INVOICE
  // ─────────────────────────────────────────────────────────────────────────

  Future<void> _loadPaymentHistory() async {
    setState(() => _historyLoading = true);
    try {
      // query.class_id || params.class_id (no such param) || userInfo.classes_id
      final classId = firstTruthy([widget.classId, ref.read(sessionProvider).userInfo?.classesId]);
      final res = await _ctrl.getPaymentListAction(classId == null ? null : jsDisplay(classId));
      final history = historyFromResponse(res);
      if (history != null && mounted) setState(() => _paymentHistory = history);
    } catch (_) {
      // "[Payment History] Failed to load" — console only on the web.
    } finally {
      if (mounted) setState(() => _historyLoading = false);
    }
  }

  void _openInvoice(Map<String, dynamic> txn) {
    final orderId = invoiceOrderId(txn);
    if (orderId == null) {
      AppToast.error('No order ID found.');
      return;
    }
    showPaymentModal<void>(
      context,
      builder: (_) => InvoiceDialog(txn: txn, orderId: orderId, load: _ctrl.getPaymentByIdAction),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final Widget child = switch (_view) {
      _View.loading => _loadingView(),
      _View.error => _errorView(),
      _View.polling => _pollingView(),
      _View.checkout => _checkoutView(),
      _View.result => _resultView(),
    };
    return ColoredBox(color: dark ? Tw.slate950 : Colors.white, child: child);
  }

  // ═══ VIEW: LOADING ═══
  Widget _loadingView() {
    final primary = SpTw.primary(context);
    return CenteredScroll(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _spinBox(primary, size: 64, iconSize: 24),
        const SizedBox(height: 24),
        const Text('Loading your plan…',
            style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: Tw.slate400)),
      ]),
    );
  }

  Widget _spinBox(Color primary, {required double size, required double iconSize}) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: primary.withValues(alpha: 0.1)),
        ),
        child: SpinningIcon(BootstrapIcons.arrow_repeat, size: iconSize, color: primary),
      );

  // ═══ VIEW: ERROR ═══
  Widget _errorView() {
    final primary = SpTw.primary(context);
    return CenteredScroll(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 64,
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Tw.rose50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Tw.rose200),
          ),
          child: const Icon(BootstrapIcons.exclamation_circle_fill, size: 24, color: Tw.rose500),
        ),
        const SizedBox(height: 20),
        const Text('Failed to load plans',
            style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: Tw.slate600)),
        const SizedBox(height: 20),
        Text(_errorMessage ?? '',
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, height: 20 / 14, color: Tw.slate400)),
        const SizedBox(height: 20),
        FlatPayButton(
          label: 'Retry',
          icon: BootstrapIcons.arrow_clockwise,
          background: primary,
          hoverBackground: primary.withValues(alpha: 0.9),
          foreground: Colors.white,
          onPressed: _loadPlans,
        ),
      ]),
    );
  }

  // ═══ VIEW: POLLING (waiting for payment) ═══
  Widget _pollingView() {
    final primary = SpTw.primary(context);
    final canCheck = _pendingOrderId != null;
    const gap = SizedBox(height: 24);
    return CenteredScroll(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _spinBox(primary, size: 80, iconSize: 30),
        gap,
        const Text('Waiting for Payment',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w700, color: Tw.slate700)),
        const SizedBox(height: 4),
        const Text(
          'Complete the payment in the opened tab. This page updates automatically.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, height: 20 / 14, color: Tw.slate400),
        ),
        if (_popupBlocked) ...[
          gap,
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 384),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Tw.rose50,
                borderRadius: BorderRadius.circular(SpRadius.xl),
                border: Border.all(color: Tw.rose200),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                  padding: EdgeInsets.only(top: 2),
                  child: Icon(BootstrapIcons.exclamation_triangle_fill, size: 14, color: Tw.rose500),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    // Native wording: the web's "Popup Blocked / Browser blocked the
                    // payment window. Allow popups and …" has no popup to allow here.
                    const Text('Payment page not opened',
                        style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700, color: Tw.rose700)),
                    const SizedBox(height: 2),
                    Wrap(crossAxisAlignment: WrapCrossAlignment.center, children: [
                      const Text('The browser could not be opened. ',
                          style: TextStyle(fontSize: 12, height: 1.625, color: Tw.rose600)),
                      GestureDetector(
                        onTap: () => _openPaymentWindow(_pendingPaymentUrl),
                        child: const MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: Text('click here to retry',
                              style: TextStyle(
                                fontSize: 12,
                                height: 1.625,
                                fontWeight: FontWeight.w600,
                                color: Tw.rose600,
                                decoration: TextDecoration.underline,
                                decorationColor: Tw.rose600,
                              )),
                        ),
                      ),
                      const Text('.', style: TextStyle(fontSize: 12, height: 1.625, color: Tw.rose600)),
                    ]),
                  ]),
                ),
              ]),
            ),
          ),
        ],
        gap,
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Tw.amber50,
            borderRadius: BorderRadius.circular(SpRadius.xl),
            border: Border.all(color: Tw.amber200),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(BootstrapIcons.clock_history, size: 14, color: Tw.amber500),
            SizedBox(width: 8),
            Flexible(
              child: Text('Checking status every 5 seconds…',
                  style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: Tw.amber700)),
            ),
          ]),
        ),
        // Native only: re-check now / reopen the gateway page.
        gap,
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            if (canCheck)
              AppButton(
                label: 'Check payment status',
                icon: BootstrapIcons.arrow_clockwise,
                variant: AppButtonVariant.outline,
                size: AppButtonSize.sm,
                loading: _checkingStatus,
                loadingLabel: 'Checking...',
                onPressed: () => _checkStatus(_pendingOrderId!, _Check.manual),
              ),
            AppButton(
              label: 'Open payment page again',
              icon: BootstrapIcons.box_arrow_up_right,
              variant: AppButtonVariant.ghost,
              size: AppButtonSize.sm,
              onPressed: _pendingPaymentUrl == null ? null : () => _openPaymentWindow(_pendingPaymentUrl),
            ),
          ],
        ),
        gap,
        UnderlineTextButton(
          label: 'Cancel & go back',
          color: Tw.slate400,
          hoverColor: Tw.slate600,
          onTap: _cancelPayment,
        ),
      ]),
    );
  }

  // ═══ VIEW: CHECKOUT ═══
  Widget _checkoutView() {
    final dark = context.isDark;
    final getuserbyid = ref.watch(usersControllerProvider.select((s) => s.getuserbyid));
    final lg = context.isLg;

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CheckoutHeader(
          getuserbyid: getuserbyid,
          currentPlanName: currentPlanName(getuserbyid, _allPlans),
          activeTab: _activeTab,
          onTab: (t) => setState(() => _activeTab = t),
          selectedCount: _selectedPlans.length,
          historyCount: _paymentHistory.length,
        ),
        if (_activeTab == 'order')
          OrderTab(
            allPlans: _allPlans,
            isSelected: _isPlanSelected,
            onToggle: _togglePlan,
            onReload: _loadPlans,
            hasSelection: _selectedPlans.isNotEmpty,
          )
        else
          HistoryTab(
            history: _paymentHistory,
            loading: _historyLoading,
            onRefresh: _loadPaymentHistory,
            onOpen: _openInvoice,
          ),
      ],
    );

    Widget summary(bool fixed) => OrderSummary(
          fixed: fixed,
          selectedPlans: _selectedPlans,
          totals: _totals,
          referralApplied: _referralApplied,
          referralDiscount: _referralDiscount,
          showReferral: showReferralCodeSection(_selectedPlans),
          referralController: _referralCode,
          referralError: _referralError,
          onApplyReferral: _applyReferral,
          onRemoveReferral: _removeReferral,
          paymentError: _paymentError,
          paymentLoading: _paymentLoading,
          onPay: _openConfirmModal,
        );

    final leftBg = dark ? Tw.slate950 : Tw.slate50;
    if (lg) {
      // `lg:flex-row` + the fixed right sidebar (`lg:w-[380px] xl:w-[420px]`).
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ColoredBox(
              color: leftBg,
              child: LayoutBuilder(
                builder: (context, c) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: c.maxHeight),
                    child: left,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: context.isXl ? 420 : 380, child: summary(true)),
        ],
      );
    }
    // Below `lg` the summary follows the plans column, which is at least
    // one screen high (`min-h-screen`).
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: ColoredBox(color: leftBg, child: left),
            ),
            summary(false),
          ],
        ),
      ),
    );
  }

  // ═══ VIEW: RESULT (success / failed) ═══
  Widget _resultView() {
    final result = _paymentResult;
    final success = result?.success ?? false;
    final failed = result != null && !result.success;
    final accent200 = success ? Tw.emerald200 : Tw.rose200;

    final hero = Container(
      color: success ? Tw.emerald50 : Tw.rose50,
      padding: const EdgeInsets.fromLTRB(40, 40, 40, 32),
      child: Column(children: [
        Container(
          width: 96,
          height: 96,
          alignment: Alignment.center,
          // `ring-4 ring-*-200`: a 4px ring outside the 96px circle.
          decoration: BoxDecoration(
            color: success ? Tw.emerald100 : Tw.rose100,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: accent200, spreadRadius: 4)],
          ),
          child: Icon(
            success ? BootstrapIcons.check_circle_fill : BootstrapIcons.x_circle_fill,
            size: 48,
            color: success ? Tw.emerald500 : Tw.rose500,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          success ? 'Payment Successful!' : 'Payment Failed',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: context.isSm ? 30 : 24,
            height: spLeading(context.isSm ? 30 : 24),
            fontWeight: FontWeight.w800,
            letterSpacing: -0.025 * (context.isSm ? 30 : 24),
            color: success ? Tw.emerald700 : Tw.rose700,
          ),
        ),
        const SizedBox(height: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Text(
            success
                ? 'Your subscription is now active. Start learning right away!'
                : (jsTruthy(result?.message) ? result!.message! : 'Something went wrong. Please try again.'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1.625, color: Tw.slate500),
          ),
        ),
        if (success && jsTruthy(result?.amount)) ...[
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SpRadius.xl2),
              border: Border.all(color: Tw.emerald200),
              boxShadow: AppShadows.sm,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              // The web's `bi-shield-check-fill` is not a Bootstrap Icons
              // glyph (bootstrap-icons 1.13.1), so the circle stays empty.
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(color: Tw.emerald100, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Amount Paid', style: TextStyle(fontSize: 12, height: 1, color: Tw.slate400)),
                Text('₹${jsDisplay(result!.amount)}',
                    style: const TextStyle(
                        fontSize: 18, height: 1.25, fontWeight: FontWeight.w800, color: Tw.slate900)),
              ]),
            ]),
          ),
        ],
      ]),
    );

    final sm = context.isSm;
    final tryAgain = FlatPayButton(
      label: 'Try Again',
      icon: BootstrapIcons.arrow_clockwise,
      expand: true,
      weight: FontWeight.w700,
      shadow: true,
      padding: const EdgeInsets.symmetric(vertical: 14),
      background: Tw.rose500,
      hoverBackground: Tw.rose600,
      foreground: Colors.white,
      onPressed: _goToCheckout,
    );
    final back = FlatPayButton(
      label: success ? 'Start Learning' : 'Back to Checkout',
      icon: success ? BootstrapIcons.mortarboard_fill : BootstrapIcons.arrow_left,
      expand: true,
      weight: FontWeight.w700,
      shadow: success,
      padding: const EdgeInsets.symmetric(vertical: 14),
      background: success ? Tw.emerald500 : Tw.slate100,
      hoverBackground: success ? Tw.emerald600 : Tw.slate200,
      foreground: success ? Colors.white : Tw.slate700,
      onPressed: _goToCheckout,
    );

    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accent200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 6, color: success ? Tw.emerald500 : Tw.rose500),
          hero,
          // Activated plans
          if (success && _selectedPlans.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Tw.emerald100)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Caption('Activated Plans'),
                for (final plan in _selectedPlans) ...[
                  const SizedBox(height: 12),
                  _activatedPlan(plan),
                ],
              ]),
            ),
          // Failure info
          if (failed)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Tw.rose100)),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Tw.rose50,
                  borderRadius: BorderRadius.circular(SpRadius.xl),
                  border: Border.all(color: Tw.rose200),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(BootstrapIcons.info_circle, size: 14, color: Tw.rose400),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      jsTruthy(result.message)
                          ? result.message!
                          : 'Your payment could not be processed. No amount has been deducted.',
                      style: const TextStyle(fontSize: 12, height: 1.625, color: Tw.rose600),
                    ),
                  ),
                ]),
              ),
            ),
          // Action buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Tw.slate100)),
            ),
            child: sm
                ? Row(children: [
                    if (failed) ...[Expanded(child: tryAgain), const SizedBox(width: 12)],
                    Expanded(child: back),
                  ])
                : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    if (failed) ...[tryAgain, const SizedBox(height: 12)],
                    back,
                  ]),
          ),
        ],
      ),
    );

    return CenteredScroll(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 80),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        StepBreadcrumb(currentStep: 3, resultStatus: result == null ? null : (success ? 'success' : 'failed'), compact: true),
        const SizedBox(height: 40),
        ConstrainedBox(constraints: const BoxConstraints(maxWidth: 512), child: card),
        if (jsTruthy(result?.transactionId)) ...[
          const SizedBox(height: 24),
          Text.rich(
            TextSpan(children: [
              const TextSpan(text: 'Transaction ID: '),
              TextSpan(
                text: result!.transactionId,
                style: const TextStyle(
                    fontFamily: spMonoFamily,
                    fontFamilyFallback: spMonoFallback,
                    fontWeight: FontWeight.w600,
                    color: Tw.slate500),
              ),
            ]),
            style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400),
          ),
        ],
      ]),
    );
  }

  Widget _activatedPlan(Map<String, dynamic> plan) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Tw.slate50,
          borderRadius: BorderRadius.circular(SpRadius.xl),
          border: Border.all(color: Tw.slate100),
        ),
        child: Row(children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: Tw.emerald100, borderRadius: BorderRadius.circular(SpRadius.lg)),
            child: const Icon(BootstrapIcons.book_fill, size: 14, color: Tw.emerald600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(jsDisplay(plan['class_name']),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: Tw.slate800)),
              Text('${jsDisplay(plan['duration'])} days',
                  style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
            ]),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Tw.emerald50,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Tw.emerald200),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(BootstrapIcons.check_circle_fill, size: 12, color: Tw.emerald600),
              SizedBox(width: 6),
              Text('Active',
                  style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700, color: Tw.emerald600)),
            ]),
          ),
        ]),
      );
}

/// A `new Error(message)` thrown by the component itself.
class _PlanError implements Exception {
  const _PlanError(this.message);
  final String message;
}
