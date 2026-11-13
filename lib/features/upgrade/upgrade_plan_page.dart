import 'dart:ui';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/external_link.dart';
import '../../core/utils/toast.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import 'upgrade_plan_controller.dart';
import 'upgrade_plan_logic.dart';
import 'upgrade_plan_widgets.dart';

enum _View { plans, checkout }

/// What started a payment-status check.
enum _Check {
  /// `mounted()` with `?transaction_id=` (return from the gateway on the web).
  route,

  /// The app regained focus while a payment was open in the browser.
  resume,

  /// The "Check payment status" button.
  manual,
}

/// Port of `src/components/Upgradeplan.vue` (`/upgradeplan`, inside the
/// eLabs DashboardShell).
///
/// [transactionId] is the `transaction_id` query parameter the payment
/// gateway appends when it sends the browser back to the web page; when
/// present the status is checked on open, like the web's `mounted()`.
///
/// Native flow: the gateway page opens in the external browser and cannot
/// return into the app, so the order id from `/payment/create` is kept and
/// verified with the same `/payment/status` call when the app regains focus
/// and from the "Check payment status" button.
class UpgradePlanPage extends ConsumerStatefulWidget {
  const UpgradePlanPage({super.key, this.transactionId});
  final String? transactionId;

  @override
  ConsumerState<UpgradePlanPage> createState() => _UpgradePlanPageState();
}

class _UpgradePlanPageState extends ConsumerState<UpgradePlanPage> {
  _View _currentView = _View.plans;
  String? _selectedSyllabus;
  List<Map<String, dynamic>> _selectedPlans = [];
  bool _paymentLoading = false;
  String? _paymentError;

  // ── Native: payment opened in the external browser ──
  bool _awaitingPayment = false;
  String? _pendingOrderId;
  String? _pendingUrl;
  bool _checkingStatus = false;
  DateTime? _lastAutoCheck;
  late final AppLifecycleListener _lifecycle;

  UpgradePlanController get _ctrl => ref.read(upgradePlanControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(onResume: _onResume);
    Future.microtask(() {
      if (!mounted) return;
      _ctrl.fetchZslClassesplan(true, 1);
      _checkPaymentStatus(widget.transactionId, _Check.route);
    });
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  // ── Payment status ──

  void _onResume() {
    final id = _pendingOrderId;
    if (!mounted || !_awaitingPayment || id == null) return;
    final now = DateTime.now();
    // Desktop reports every window focus change; don't re-check on each one.
    if (_lastAutoCheck != null && now.difference(_lastAutoCheck!) < const Duration(seconds: 3)) {
      return;
    }
    _lastAutoCheck = now;
    _checkPaymentStatus(id, _Check.resume);
  }

  /// `checkPaymentStatus()` — `getPaymentStatusAction(transactionId)`.
  Future<void> _checkPaymentStatus(String? transactionId, _Check trigger) async {
    if (transactionId == null || transactionId.isEmpty || _checkingStatus) return;
    setState(() => _checkingStatus = true);
    try {
      final res = await _ctrl.getPaymentStatusAction(transactionId, silent: trigger == _Check.resume);
      if (!mounted) return;
      // The web only checks after the gateway is done, so anything that is
      // not a success is a failure there. In the app the payment may still
      // be in progress, hence the three-way reading for re-checks.
      final outcome = trigger == _Check.route
          ? (isUpgradePaymentSuccess(res) ? PaymentOutcome.success : PaymentOutcome.failed)
          : classifyPaymentStatus(res);
      switch (outcome) {
        case PaymentOutcome.success:
          AppToast.success('Payment Successful 🎉');
          setState(() {
            _awaitingPayment = false;
            _pendingOrderId = null;
            _pendingUrl = null;
            _selectedPlans = [];
            _paymentError = null;
            _currentView = _View.plans;
          });
        case PaymentOutcome.failed:
          AppToast.error('Payment Failed ❌');
          setState(() {
            _awaitingPayment = false;
            _pendingOrderId = null;
            _pendingUrl = null;
          });
        case PaymentOutcome.pending:
          if (trigger == _Check.manual) {
            AppToast.info('Payment is still pending. Complete it in your browser, then check again.');
          }
      }
    } catch (_) {
      // The web only logs it; the API client already toasted the error.
    } finally {
      if (mounted) setState(() => _checkingStatus = false);
    }
  }

  // ── Plan selection ──

  bool _isSelected(Object? id) => _selectedPlans.any((p) => planIdOf(p) == id);

  void _togglePlan(Map<String, dynamic> plan) {
    final id = planIdOf(plan);
    setState(() {
      if (_isSelected(id)) {
        _selectedPlans = [for (final p in _selectedPlans) if (planIdOf(p) != id) p];
      } else {
        _selectedPlans = [..._selectedPlans, plan];
      }
    });
  }

  void _goToCheckout() => setState(() => _currentView = _View.checkout);

  void _goBack() => setState(() {
        _currentView = _View.plans;
        _paymentError = null;
      });

  Future<void> _proceedToPayment() async {
    if (_paymentLoading) return;
    if (_selectedPlans.isEmpty) {
      setState(() => _paymentError = 'Please select at least one plan');
      return;
    }
    setState(() {
      _paymentLoading = true;
      _paymentError = null;
    });
    try {
      final response = await _ctrl.createPaymentOrderAction(
        type: 'zsl_plan',
        zslPlanIds: zslPlanIdsOf(_selectedPlans),
      );
      final redirectUrl = paymentRedirectUrl(response);
      if (redirectUrl != null) {
        if (mounted) {
          setState(() {
            _awaitingPayment = true;
            _pendingUrl = redirectUrl;
            _pendingOrderId = paymentOrderId(response);
            _lastAutoCheck = null;
          });
        }
        // Web: `window.location.href = redirectUrl`.
        await openExternal(redirectUrl);
      } else if (mounted) {
        setState(() => _paymentError = 'Payment URL not received. Please try again.');
      }
    } catch (e) {
      if (mounted) setState(() => _paymentError = paymentErrorText(e));
    } finally {
      if (mounted) setState(() => _paymentLoading = false);
    }
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    final zslClasses = ref.watch(upgradePlanControllerProvider).zslClasses;
    return ColoredBox(
      color: context.isDark ? Tw.slate950 : Colors.white,
      child: OutInSwitcher(
        expand: true,
        enter: const Duration(milliseconds: 500),
        leave: const Duration(milliseconds: 300),
        enterOffset: const Offset(-40, 0),
        leaveOffset: const Offset(-40, 0),
        child: _currentView == _View.plans
            ? KeyedSubtree(key: const ValueKey('plans'), child: _plansView(zslClasses))
            : KeyedSubtree(key: const ValueKey('checkout'), child: _checkoutView()),
      ),
    );
  }

  // ════════ VIEW: PLAN SELECTION ════════

  Widget _plansView(List<Map<String, dynamic>> zslClasses) {
    final filtered = _selectedSyllabus == null
        ? const <Map<String, dynamic>>[]
        : [for (final p in zslClasses) if (p['syllabus'] == _selectedSyllabus) p];
    final px = context.isSm ? 24.0 : 16.0;
    return Stack(
      children: [
        Positioned.fill(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _hero(),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1152), // max-w-6xl
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(px, 0, px, 144), // pb-36
                      child: OutInSwitcher(
                        enter: const Duration(milliseconds: 400),
                        leave: const Duration(milliseconds: 200),
                        enterOffset: const Offset(0, 16),
                        child: _selectedSyllabus == null
                            ? const KeyedSubtree(key: ValueKey('empty'), child: _EmptyPlans())
                            : KeyedSubtree(
                                key: ValueKey(_selectedSyllabus),
                                child: _planGrid(filtered),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        // FIXED BOTTOM BAR
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            reverseDuration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: _selectedPlans.isNotEmpty
                ? KeyedSubtree(key: const ValueKey('bar'), child: _bottomBar())
                : const SizedBox.shrink(key: ValueKey('no-bar')),
          ),
        ),
      ],
    );
  }

  Widget _hero() {
    final dark = context.isDark;
    final primary = context.colors.primary;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: primary.withValues(alpha: dark ? 0.10 : 0.05),
        border: Border(bottom: BorderSide(color: primary.withValues(alpha: dark ? 0.20 : 0.10))),
      ),
      child: ClipRect(
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: _Glow(width: 500, height: 280, color: primary.withValues(alpha: dark ? 0.20 : 0.10)),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: _Glow(width: 400, height: 280, color: primary.withValues(alpha: dark ? 0.15 : 0.08)),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 48, 16, 64),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 768),
                  child: EntranceAnimation(
                    duration: const Duration(milliseconds: 700),
                    offset: const Offset(0, -16),
                    child: _heroContent(),
                  ),
                ),
              ),
            ),
            // DASHBOARD BACK BUTTON
            Positioned(
              top: 16,
              left: 16,
              child: HoverArea(
                onTap: () => context.go('/dashboard'),
                builder: (context, hover) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: hover
                        ? primary
                        : (dark ? Tw.slate800.withValues(alpha: 0.8) : primary.withValues(alpha: 0.2)),
                    border: Border.all(color: hover ? primary : (dark ? Tw.slate700 : Tw.slate200)),
                    boxShadow: AppShadows.sm,
                  ),
                  child: const Icon(BootstrapIcons.arrow_left, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heroContent() {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final sm = context.isSm;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: primary.withValues(alpha: dark ? 0.20 : 0.10),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: primary.withValues(alpha: dark ? 0.30 : 0.20)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // The icon glyph also gets the 0.35em tracking, then `me-1`
              // and the text node's leading space.
              Icon(BootstrapIcons.stars, size: 11, color: primary),
              const SizedBox(width: 11 * 0.35 + 4),
              Text(
                ' PREMIUM LEARNING PLANS',
                style: TextStyle(
                  fontSize: 11,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 11 * 0.35,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'Choose Your'),
            TextSpan(text: ' Upgrade Plan', style: TextStyle(color: primary)),
          ]),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: sm ? 48 : 36,
            height: 1.25,
            fontWeight: FontWeight.w800,
            letterSpacing: (sm ? 48 : 36) * -0.025,
            color: dark ? Tw.slate50 : Tw.slate900,
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: Text(
            'Select your syllabus and pick the plan that fits your learning goals.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, height: 1.5, color: dark ? Tw.slate400 : Tw.slate500),
          ),
        ),
        const SizedBox(height: 32), // gap-4 + mt-4
        // SYLLABUS TOGGLE
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: dark ? Tw.slate800 : Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: dark ? Tw.slate700 : Tw.slate200),
            boxShadow: AppShadows.md,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _syllabusButton('CBSE'),
              const SizedBox(width: 4),
              _syllabusButton('STATE'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _syllabusButton(String syllabus) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final selected = _selectedSyllabus == syllabus;
    return HoverArea(
      onTap: () => setState(() => _selectedSyllabus = syllabus),
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected ? AppShadows.md : null,
        ),
        child: Text(
          syllabus,
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : hover
                    ? primary
                    : (dark ? Tw.slate400 : Tw.slate500),
          ),
        ),
      ),
    );
  }

  Widget _planGrid(List<Map<String, dynamic>> plans) {
    final columns = context.isLg ? 3 : (context.isSm ? 2 : 1);
    const gap = 20.0;
    final rows = <Widget>[];
    for (var i = 0; i < plans.length; i += columns) {
      if (rows.isNotEmpty) rows.add(const SizedBox(height: gap));
      final cells = <Widget>[];
      for (var j = 0; j < columns; j++) {
        if (j > 0) cells.add(const SizedBox(width: gap));
        final index = i + j;
        if (index >= plans.length) {
          cells.add(const Expanded(child: SizedBox()));
          continue;
        }
        final plan = plans[index];
        final id = planIdOf(plan);
        cells.add(Expanded(
          child: EntranceAnimation(
            key: ValueKey('plan-$id'),
            delay: Duration(milliseconds: index * 80),
            offset: const Offset(0, 20),
            child: _PlanCard(
              plan: plan,
              selected: _isSelected(id),
              onTap: () => _togglePlan(plan),
            ),
          ),
        ));
      }
      rows.add(IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
      ));
    }
    return Padding(
      padding: const EdgeInsets.only(top: 40), // pt-10
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );
  }

  Widget _bottomBar() {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final sm = context.isSm;
    final totals = PlanTotals.of(_selectedPlans);

    final chips = Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: sm ? WrapAlignment.start : WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text('Selected:', style: TextStyle(fontSize: 14, color: dark ? Tw.slate400 : Tw.slate500)),
        for (final plan in _selectedPlans)
          Container(
            key: ValueKey('chip-${planIdOf(plan)}'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: dark ? 0.20 : 0.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: primary.withValues(alpha: dark ? 0.30 : 0.20)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_display(plan['class_name']),
                    style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: primary)),
                const SizedBox(width: 10),
                HoverArea(
                  onTap: () => _togglePlan(plan),
                  builder: (context, hover) => SizedBox(
                    height: 20,
                    child: Icon(
                      BootstrapIcons.x,
                      size: 14,
                      color: hover ? primary : primary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (sm) ...[
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Total', style: TextStyle(fontSize: 12, height: 16 / 12, color: dark ? Tw.slate500 : Tw.slate400)),
              Text('₹${totals.totalText}',
                  style: TextStyle(
                    fontSize: 18,
                    height: 28 / 18,
                    fontWeight: FontWeight.w700,
                    color: dark ? Tw.slate50 : Tw.slate900,
                  )),
            ],
          ),
          const SizedBox(width: 16),
        ],
        _ActionButton(
          onPressed: _goToCheckout,
          hoverScale: 1.05,
          pressScale: 0.95,
          padding: const EdgeInsets.symmetric(horizontal: 32),
          builder: (hover) => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Proceed to Checkout'),
              const SizedBox(width: 8),
              AnimatedSlide(
                duration: const Duration(milliseconds: 300),
                offset: Offset(hover ? 0.3 : 0, 0),
                child: const Icon(BootstrapIcons.arrow_right, size: 14),
              ),
            ],
          ),
        ),
      ],
    );

    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: (dark ? Tw.slate900 : Colors.white).withValues(alpha: 0.95),
            border: Border(
              top: BorderSide(color: dark ? Tw.slate700.withValues(alpha: 0.8) : Tw.slate200),
            ),
            boxShadow: AppShadows.xl2, // shadow-2xl (the colour modifier has no effect)
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1152),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: sm ? 24 : 16, vertical: 16),
                child: sm
                    ? Row(
                        children: [
                          Expanded(child: chips),
                          const SizedBox(width: 16),
                          actions,
                        ],
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [chips, const SizedBox(height: 16), actions],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ════════ VIEW: CHECKOUT ════════

  Widget _checkoutView() {
    final dark = context.isDark;
    final leftBg = dark ? Tw.slate950 : Tw.slate50;
    if (context.isLg) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ColoredBox(
              color: leftBg,
              child: SingleChildScrollView(child: _checkoutLeft()),
            ),
          ),
          SizedBox(width: context.isXl ? 420 : 380, child: _orderSummary(fixed: true)),
        ],
      );
    }
    return LayoutBuilder(
      builder: (context, c) => SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // `min-h-screen` on the left panel.
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: c.maxHeight),
              child: ColoredBox(color: leftBg, child: _checkoutLeft()),
            ),
            _orderSummary(fixed: false),
          ],
        ),
      ),
    );
  }

  Widget _checkoutLeft() {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final px = context.isSm ? 40.0 : 24.0;
    final muted = dark ? Tw.slate500 : Tw.slate400;

    final header = Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(px, 32, px, 24),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900 : Colors.white,
        border: Border(
          bottom: BorderSide(color: dark ? Tw.slate700.withValues(alpha: 0.8) : Tw.slate200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HoverArea(
            onTap: _goBack,
            builder: (context, hover) {
              final fg = hover ? primary : (dark ? Tw.slate400 : Tw.slate500);
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hover ? primary : (dark ? Tw.slate800 : Tw.slate100),
                      border: Border.all(color: hover ? primary : (dark ? Tw.slate700 : Tw.slate200)),
                    ),
                    child: Icon(BootstrapIcons.arrow_left,
                        size: 14, color: hover ? Colors.white : (dark ? Tw.slate400 : Tw.slate500)),
                  ),
                  const SizedBox(width: 8),
                  Text('Back', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fg)),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          // STEPPER
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(shape: BoxShape.circle, color: Tw.emerald500),
                child: const Center(child: _CheckMark(size: 12, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text('Select Plans',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: muted)),
              ),
              const SizedBox(width: 12),
              _StepLine(color: primary.withValues(alpha: 0.5)),
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(shape: BoxShape.circle, color: primary),
                child: const Text('2',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text('Review & Pay',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: dark ? Tw.slate100 : Tw.slate800,
                    )),
              ),
              const SizedBox(width: 12),
              _StepLine(color: dark ? Tw.slate700 : Tw.slate200),
              const SizedBox(width: 12),
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: dark ? Tw.slate800 : Tw.slate100,
                  border: Border.all(color: dark ? Tw.slate700 : Tw.slate200),
                ),
                child: Text('3', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: muted)),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text('Confirmed',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: muted)),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Review Your Order',
            style: TextStyle(
              fontSize: context.isSm ? 30 : 24,
              height: context.isSm ? 36 / 30 : 32 / 24,
              fontWeight: FontWeight.w800,
              letterSpacing: (context.isSm ? 30 : 24) * -0.025,
              color: dark ? Tw.slate50 : Tw.slate900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Confirm the plans you've selected before payment.",
            style: TextStyle(fontSize: 14, height: 20 / 14, color: dark ? Tw.slate400 : Tw.slate500),
          ),
        ],
      ),
    );

    final items = <Widget>[];
    for (var i = 0; i < _selectedPlans.length; i++) {
      final plan = _selectedPlans[i];
      items.add(Padding(
        key: ValueKey('checkout-${planIdOf(plan)}'),
        padding: const EdgeInsets.only(top: 16),
        child: EntranceAnimation(
          delay: Duration(milliseconds: i * 60),
          offset: const Offset(-16, 0),
          child: _CheckoutItem(plan: plan, onRemove: () => _togglePlan(plan)),
        ),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        Padding(
          padding: EdgeInsets.symmetric(horizontal: px, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'SELECTED PLANS (${_selectedPlans.length})',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: muted),
              ),
              ...items,
              // Empty guard
              if (_selectedPlans.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 16 + 80, bottom: 80),
                  child: Column(
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: dark ? Tw.slate800 : Tw.slate100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(BootstrapIcons.cart3, size: 30, color: muted),
                      ),
                      const SizedBox(height: 16),
                      Text('No plans selected.',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: muted)),
                      const SizedBox(height: 16),
                      HoverArea(
                        onTap: _goBack,
                        builder: (context, hover) {
                          final c = hover ? primary.withValues(alpha: 0.8) : primary;
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(BootstrapIcons.arrow_left, size: 14, color: c),
                              const SizedBox(width: 4),
                              Text(
                                'Go back to Dashboard',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: c,
                                  decoration: TextDecoration.underline,
                                  decorationColor: c,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// RIGHT PANEL — fixed to the right on `lg`, stacked below otherwise.
  Widget _orderSummary({required bool fixed}) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final n = _selectedPlans.length;
    final totals = PlanTotals.of(_selectedPlans);
    final divider = Container(height: 1, color: dark ? Tw.slate800 : Tw.slate100);
    final rule = dark ? Tw.slate700.withValues(alpha: 0.8) : Tw.slate100;
    final muted = dark ? Tw.slate500 : Tw.slate400;

    Widget row(String label, String value, {Color? valueColor}) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: TextStyle(fontSize: 14, color: dark ? Tw.slate400 : Tw.slate500)),
            Text(value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor ?? (dark ? Tw.slate200 : Tw.slate800),
                )),
          ],
        );

    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < n; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: dark ? 0.20 : 0.10),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(BootstrapIcons.book_fill, size: 14, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _display(_selectedPlans[i]['class_name']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: dark ? Tw.slate300 : Tw.slate600),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '₹${_display(_selectedPlans[i]['price'])}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: dark ? Tw.slate200 : Tw.slate800,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 20),
          divider,
          const SizedBox(height: 20),
          row('Subtotal', '₹${totals.totalText}'),
          const SizedBox(height: 20),
          row('GST (18%)', '₹${totals.gstText}', valueColor: dark ? Tw.slate300 : Tw.slate700),
          const SizedBox(height: 20),
          divider,
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Payable',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: dark ? Tw.slate100 : Tw.slate800,
                  )),
              Text('₹${totals.grandText}',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: primary)),
            ],
          ),
          if (n > 1) ...[
            const SizedBox(height: 20),
            _Notice(
              icon: BootstrapIcons.gift_fill,
              iconColor: dark ? Tw.emerald400 : Tw.emerald500,
              text: "You're saving with a multi-plan bundle!",
              textColor: dark ? Tw.emerald400 : Tw.emerald700,
              background: dark ? Tw.emerald950.withValues(alpha: 0.5) : Tw.emerald50,
              border: dark ? Tw.emerald800 : Tw.emerald200,
            ),
          ],
          // Error message
          if (_paymentError != null) ...[
            const SizedBox(height: 20),
            _Notice(
              icon: BootstrapIcons.exclamation_circle_fill,
              iconColor: dark ? Tw.rose400 : Tw.rose500,
              text: _paymentError!,
              textColor: dark ? Tw.rose400 : Tw.rose600,
              background: dark ? Tw.rose950.withValues(alpha: 0.5) : Tw.rose50,
              border: dark ? Tw.rose800 : Tw.rose200,
            ),
          ],
          if (_awaitingPayment) ...[
            const SizedBox(height: 20),
            _pendingPaymentPanel(),
          ],
        ],
      ),
    );

    final header = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: dark ? 0.10 : 0.05),
        border: Border(bottom: BorderSide(color: rule)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary',
              style: TextStyle(
                fontSize: 18,
                height: 28 / 18,
                fontWeight: FontWeight.w800,
                color: dark ? Tw.slate100 : Tw.slate800,
              )),
          const SizedBox(height: 2),
          Text('$n plan${n != 1 ? 's' : ''} selected', style: TextStyle(fontSize: 12, color: muted)),
        ],
      ),
    );

    // Pay Button pinned to bottom
    final footer = Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900 : Colors.white,
        border: Border(top: BorderSide(color: rule)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (n > 0) ...[
            _ActionButton(
              onPressed: _paymentLoading ? null : _proceedToPayment,
              hoverScale: 1.02,
              pressScale: _paymentLoading ? 1 : 0.95,
              dimmed: _paymentLoading,
              fontSize: 16,
              builder: (hover) => Row(
                mainAxisSize: MainAxisSize.min,
                children: _paymentLoading
                    ? const [
                        SpinAnimation(child: Icon(BootstrapIcons.arrow_repeat, size: 18)),
                        SizedBox(width: 8),
                        Text('Processing...'),
                      ]
                    : [
                        const Icon(BootstrapIcons.shield_lock_fill, size: 16),
                        const SizedBox(width: 8),
                        Text('Pay ₹${totals.grandText}'),
                        const SizedBox(width: 8),
                        AnimatedSlide(
                          duration: const Duration(milliseconds: 300),
                          offset: Offset(hover ? 0.25 : 0, 0),
                          child: const Icon(BootstrapIcons.arrow_right, size: 16),
                        ),
                      ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(BootstrapIcons.shield_lock_fill, size: 12, color: muted),
              const SizedBox(width: 6),
              Text('Secured & encrypted payment', style: TextStyle(fontSize: 12, color: muted)),
            ],
          ),
        ],
      ),
    );

    return Container(
      decoration: BoxDecoration(
        color: dark ? Tw.slate900 : Colors.white,
        border: Border(left: BorderSide(color: dark ? Tw.slate700.withValues(alpha: 0.8) : Tw.slate200)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          if (fixed) Expanded(child: SingleChildScrollView(child: body)) else body,
          footer,
        ],
      ),
    );
  }

  /// Native only: the payment page is open in the browser.
  Widget _pendingPaymentPanel() {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final canCheck = _pendingOrderId != null;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: dark ? 0.10 : 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: dark ? 0.30 : 0.20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(BootstrapIcons.hourglass_split, size: 16, color: primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Waiting for payment',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: dark ? Tw.slate100 : Tw.slate800,
                    )),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            canCheck
                ? 'Complete the payment in your browser. The status is checked automatically '
                    'when you return to the app.'
                : 'Complete the payment in your browser. The server did not return an order '
                    'reference, so the payment status cannot be checked from the app.',
            style: TextStyle(fontSize: 12, color: dark ? Tw.slate400 : Tw.slate500),
          ),
          const SizedBox(height: 12),
          Wrap(
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
                  onPressed: () => _checkPaymentStatus(_pendingOrderId, _Check.manual),
                ),
              AppButton(
                label: 'Open payment page again',
                icon: BootstrapIcons.box_arrow_up_right,
                variant: AppButtonVariant.ghost,
                size: AppButtonSize.sm,
                onPressed: _pendingUrl == null ? null : () => openExternal(_pendingUrl),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// `{{ value }}` — Vue prints `null` as an empty string and numbers the JS way.
String _display(Object? v) {
  if (v == null) return '';
  if (v is num) return jsNumberString(v);
  return '$v';
}

/// `bg-primary/5` glow blobs of the hero (`rounded-full blur-[100px]`).
class _Glow extends StatelessWidget {
  const _Glow({required this.width, required this.height, required this.color});
  final double width;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: ImageFiltered(
          imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100, tileMode: TileMode.decal),
          child: Container(
            width: width,
            height: height,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
          ),
        ),
      ),
    );
  }
}

/// EMPTY — "Pick a syllabus above to see available plans".
class _EmptyPlans extends StatelessWidget {
  const _EmptyPlans();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 96),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BounceAnimation(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: dark ? 0.10 : 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary.withValues(alpha: dark ? 0.20 : 0.10)),
              ),
              child: Icon(BootstrapIcons.mortarboard, size: 30, color: primary),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Pick a syllabus above to see available plans',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: dark ? Tw.slate500 : Tw.slate400,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final delay in const [0, 150, 300]) ...[
                if (delay > 0) const SizedBox(width: 8),
                BounceAnimation(
                  delay: Duration(milliseconds: delay),
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: primary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// One plan in the selection grid.
class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan, required this.selected, required this.onTap});
  final Map<String, dynamic> plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    const fast = Duration(milliseconds: 300);
    const slow = Duration(milliseconds: 500);
    final fullAccess = jsTruthy(plan['full_access']);

    return HoverArea(
      onTap: onTap,
      builder: (context, hover) {
        final borderColor = selected
            ? primary
            : hover
                ? primary.withValues(alpha: dark ? 0.4 : 0.3)
                : (dark ? Tw.slate700 : Tw.slate200);
        final transform = selected
            ? Matrix4.diagonal3Values(1.02, 1.02, 1)
            : hover
                ? Matrix4.translationValues(0, -4, 0)
                : Matrix4.identity();
        // `shadow-xl` / `hover:shadow-lg`: the theme's black shadows (the
        // `shadow-primary/…` colour modifiers have no effect).
        final shadows = selected
            ? AppShadows.xl
            : hover
                ? AppShadows.lg
                : const <BoxShadow>[];

        Widget feature(IconData icon, Color iconColor, String label, String value, Color valueColor) => Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: dark ? Tw.slate800 : Tw.slate100,
                  ),
                  child: Icon(icon, size: 11, color: iconColor),
                ),
                const SizedBox(width: 10),
                Text(label, style: TextStyle(fontSize: 14, height: 20 / 14, color: dark ? Tw.slate500 : Tw.slate400)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: valueColor),
                  ),
                ),
              ],
            );

        final iconMuted = dark ? Tw.slate400 : Tw.slate500;
        final strong = dark ? Tw.slate200 : Tw.slate800;

        final content = Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('PLAN',
                            style: TextStyle(
                              fontSize: 12,
                              height: 16 / 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: dark ? Tw.slate500 : Tw.slate400,
                            )),
                        const SizedBox(height: 4),
                        Text(_display(plan['class_name']),
                            style: TextStyle(
                              fontSize: 18,
                              height: 28 / 18,
                              fontWeight: FontWeight.w700,
                              color: dark ? Tw.slate100 : Tw.slate800,
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: AnimatedOpacity(
                      duration: slow,
                      opacity: selected || hover ? 1 : 0.6,
                      child: AnimatedScale(
                        duration: slow,
                        scale: selected ? 1 : 0.9,
                        child: AnimatedContainer(
                          duration: slow,
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selected ? Tw.emerald500 : (dark ? Tw.slate800 : Tw.slate100),
                            border: selected
                                ? null
                                : Border.all(color: dark ? Tw.slate700 : Tw.slate200),
                            boxShadow: selected ? AppShadows.md : null,
                          ),
                          child: Center(
                            child: _CheckMark(
                              size: 14,
                              color: selected ? Colors.white : (dark ? Tw.slate600 : Tw.slate300),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    horizontal: BorderSide(color: dark ? Tw.slate800 : Tw.slate100),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('₹',
                          style: TextStyle(fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w700, color: primary)),
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _display(plan['price']),
                        style: TextStyle(
                          fontSize: 36,
                          height: 1,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 36 * -0.025,
                          color: dark ? Tw.slate50 : Tw.slate900,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('/ year',
                          style: TextStyle(fontSize: 14, height: 20 / 14, color: dark ? Tw.slate500 : Tw.slate400)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // `<ul class="flex flex-col gap-2.5">`: style.css's unlayered
              // `ul { margin-left: 2rem }` indents it (the flex `li`s show no
              // bullets).
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    feature(
                        BootstrapIcons.journal_text, iconMuted, 'Syllabus', _display(plan['syllabus']), strong),
                    const SizedBox(height: 10),
                    feature(BootstrapIcons.calendar3, iconMuted, 'Duration', '${_display(plan['duration'])} days',
                        strong),
                    const SizedBox(height: 10),
                    feature(
                      fullAccess ? BootstrapIcons.unlock_fill : BootstrapIcons.lock_fill,
                      fullAccess ? Tw.emerald500 : (dark ? Tw.slate500 : Tw.slate400),
                      'Access',
                      fullAccess ? 'Full Access' : 'Demo Only',
                      fullAccess ? (dark ? Tw.emerald400 : Tw.emerald600) : (dark ? Tw.slate500 : Tw.slate400),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20), // gap-4 + mt-1
              AnimatedContainer(
                duration: fast,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: selected
                      ? primary
                      : hover
                          ? primary.withValues(alpha: dark ? 0.20 : 0.10)
                          : (dark ? Tw.slate800 : Tw.slate100),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: selected ? AppShadows.md : null,
                ),
                child: Builder(builder: (context) {
                  final fg = selected
                      ? Colors.white
                      : hover
                          ? primary
                          : (dark ? Tw.slate400 : Tw.slate500);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? BootstrapIcons.check_circle_fill : BootstrapIcons.plus_circle,
                        size: 14,
                        color: fg,
                      ),
                      const SizedBox(width: 8),
                      Text(selected ? 'Selected' : 'Select Plan',
                          style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: fg)),
                    ],
                  );
                }),
              ),
            ],
          ),
        );

        return AnimatedContainer(
          duration: fast,
          transform: transform,
          transformAlignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? primary.withValues(alpha: dark ? 0.10 : 0.05)
                : (dark ? Tw.slate900 : Colors.white),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: shadows,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Stack(
              children: [
                content,
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 3,
                  child: AnimatedOpacity(
                    duration: slow,
                    opacity: selected || hover ? 1 : 0,
                    child: ColoredBox(color: selected ? primary : primary.withValues(alpha: 0.4)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// One selected plan in the checkout list.
class _CheckoutItem extends StatelessWidget {
  const _CheckoutItem({required this.plan, required this.onRemove});
  final Map<String, dynamic> plan;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final fullAccess = jsTruthy(plan['full_access']);
    final chipText = dark ? Tw.slate400 : Tw.slate500;
    final chipBg = dark ? Tw.slate800 : Tw.slate100;

    Widget chip(String text) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(999)),
          child: Text(text, style: TextStyle(fontSize: 12, height: 16 / 12, color: chipText)),
        );

    final accessColor = fullAccess ? (dark ? Tw.emerald400 : Tw.emerald600) : chipText;
    final access = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: fullAccess ? (dark ? Tw.emerald950.withValues(alpha: 0.5) : Tw.emerald50) : chipBg,
        borderRadius: BorderRadius.circular(999),
        border: fullAccess ? Border.all(color: dark ? Tw.emerald800 : Tw.emerald200) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(fullAccess ? BootstrapIcons.unlock_fill : BootstrapIcons.lock_fill, size: 12, color: accessColor),
          const SizedBox(width: 4),
          Text(fullAccess ? 'Full Access' : 'Demo',
              style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: accessColor)),
        ],
      ),
    );

    return HoverArea(
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: dark ? Tw.slate900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hover
                ? primary.withValues(alpha: dark ? 0.4 : 0.3)
                : (dark ? Tw.slate700.withValues(alpha: 0.8) : Tw.slate200),
          ),
          boxShadow: hover ? AppShadows.md : null,
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: dark ? 0.20 : 0.10),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withValues(alpha: dark ? 0.30 : 0.20)),
              ),
              child: Icon(BootstrapIcons.book_fill, size: 20, color: primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_display(plan['class_name']),
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: dark ? Tw.slate100 : Tw.slate800,
                      )),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      chip(_display(plan['syllabus'])),
                      chip('${_display(plan['duration'])} days'),
                      access,
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${_display(plan['price'])}',
                    style: TextStyle(
                      fontSize: 20,
                      height: 28 / 20,
                      fontWeight: FontWeight.w800,
                      color: dark ? Tw.slate50 : Tw.slate900,
                    )),
                const SizedBox(height: 8),
                Text('/ year', style: TextStyle(fontSize: 12, color: dark ? Tw.slate500 : Tw.slate400)),
                const SizedBox(height: 12),
                HoverArea(
                  onTap: onRemove,
                  builder: (context, removeHover) {
                    final c = removeHover
                        ? (dark ? Tw.rose400 : Tw.rose500)
                        : (dark ? Tw.slate500 : Tw.slate400);
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(BootstrapIcons.trash3, size: 12, color: c),
                        const SizedBox(width: 4),
                        Text('Remove', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: c)),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// `flex-1 h-px max-w-[60px]` stepper connector.
class _StepLine extends StatelessWidget {
  const _StepLine({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Flexible(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 60),
          height: 1,
          color: color,
        ),
      );
}

/// The emerald "bundle" and rose error boxes of the order summary.
class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.textColor,
    required this.background,
    required this.border,
  });

  final IconData icon;
  final Color iconColor;
  final String text;
  final Color textColor;
  final Color background;
  final Color border;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: textColor)),
          ),
        ],
      ),
    );
  }
}

/// The page's custom primary buttons ("Proceed to Checkout", "Pay ₹…"):
/// `h-9 rounded-xl bg-primary text-white font-bold shadow-md`,
/// `hover:bg-primary/90 hover:scale-…`, `active:scale-95`,
/// `disabled:opacity-50`.
class _ActionButton extends StatefulWidget {
  const _ActionButton({
    required this.onPressed,
    required this.builder,
    this.hoverScale = 1,
    this.pressScale = 1,
    this.padding = EdgeInsets.zero,
    this.dimmed = false,
    this.fontSize = 14,
  });

  final VoidCallback? onPressed;
  final Widget Function(bool hover) builder;
  final double hoverScale;

  /// `active:scale-95`
  final double pressScale;
  final EdgeInsetsGeometry padding;

  /// `paymentLoading`: `bg-primary/60` while disabled.
  final bool dimmed;
  final double fontSize;

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final enabled = widget.onPressed != null;
    return Listener(
      onPointerDown: (_) => setState(() => _pressed = true),
      onPointerUp: (_) => setState(() => _pressed = false),
      onPointerCancel: (_) => setState(() => _pressed = false),
      child: HoverArea(
        onTap: widget.onPressed,
        builder: (context, hover) {
          final active = hover && enabled;
          final scale = _pressed && enabled ? widget.pressScale : (active ? widget.hoverScale : 1.0);
          return Opacity(
            opacity: enabled ? 1 : 0.5,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: scale,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 36,
                padding: widget.padding,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: widget.dimmed
                      ? primary.withValues(alpha: 0.6)
                      : (active ? primary.withValues(alpha: 0.9) : primary),
                  borderRadius: BorderRadius.circular(20),
                  // shadow-md (the shadow-primary/… modifiers have no effect).
                  boxShadow: AppShadows.md,
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(fontSize: widget.fontSize, fontWeight: FontWeight.w700, color: Colors.white),
                  child: IconTheme.merge(
                    data: const IconThemeData(color: Colors.white),
                    child: widget.builder(active),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// The inline svg check (`viewBox="0 0 24 24" stroke-width="3"`, polyline
/// `points="20 6 9 17 4 12"`; butt caps, miter joins).
class _CheckMark extends StatelessWidget {
  const _CheckMark({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(size: Size.square(size), painter: _CheckMarkPainter(color));
}

class _CheckMarkPainter extends CustomPainter {
  _CheckMarkPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    canvas.drawPath(
      Path()
        ..moveTo(20, 6)
        ..lineTo(9, 17)
        ..lineTo(4, 12),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
  }

  @override
  bool shouldRepaint(_CheckMarkPainter old) => old.color != color;
}
