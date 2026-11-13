import 'dart:ui' show ImageFilter;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/js_compat.dart';
import 'student_payment_logic.dart';
import 'student_payment_widgets.dart';

/// Opens one of the page's own modals (`<Teleport to="body">` + `fixed
/// inset-0 … p-4` with an `absolute inset-0 bg-black/50 backdrop-blur-sm`
/// backdrop that closes on click). They are plain `v-if` blocks, so they
/// appear and disappear without a transition.
Future<T?> showPaymentModal<T>(BuildContext context, {required WidgetBuilder builder}) => showDialog<T>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      animationStyle: const AnimationStyle(duration: Duration.zero, reverseDuration: Duration.zero),
      builder: (ctx) => Stack(
        children: [
          // `backdrop-blur-sm` (8px); taps go through to the barrier.
          Positioned.fill(
            child: IgnorePointer(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          builder(ctx),
        ],
      ),
    );

/// The modal card shared by both dialogs (`relative w-full bg-white
/// dark:bg-slate-900 rounded-3xl shadow-2xl overflow-hidden`).
class _ModalCard extends StatelessWidget {
  const _ModalCard({required this.maxWidth, required this.child, this.maxHeight});
  final double maxWidth;
  final double? maxHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) => Dialog(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight ?? double.infinity),
          child: Container(
            decoration: BoxDecoration(
              color: context.isDark ? Tw.slate900 : Colors.white,
              borderRadius: BorderRadius.circular(SpRadius.xl3),
              // `shadow-2xl` is only `0 1px 3px rgb(0 0 0/.25)` in this theme.
              boxShadow: AppShadows.xl2,
            ),
            clipBehavior: Clip.antiAlias,
            child: Material(type: MaterialType.transparency, child: child),
          ),
        ),
      );
}

Widget _iconBox(BuildContext context, IconData icon, {required double size, required double iconSize, double radius = 16}) {
  final primary = SpTw.primary(context);
  return Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(radius),
    ),
    child: Icon(icon, size: iconSize, color: primary),
  );
}

// ═══════════════════════════════════════════════════════════════════════════
//  MODAL: Confirm Payment
// ═══════════════════════════════════════════════════════════════════════════

/// The "Confirm Payment" modal. Pops `true` on "Confirm & Pay".
class ConfirmPaymentDialog extends StatelessWidget {
  const ConfirmPaymentDialog({
    super.key,
    required this.plans,
    required this.referralApplied,
    required this.referralCode,
    required this.grandTotal,
  });

  final List<Map<String, dynamic>> plans;
  final bool referralApplied;
  final String referralCode;
  final String grandTotal;

  @override
  Widget build(BuildContext context) {
    final primary = SpTw.primary(context);
    return _ModalCard(
      maxWidth: 384,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(height: 6, color: primary),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    _iconBox(context, BootstrapIcons.shield_lock_fill, size: 48, iconSize: 20),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Confirm Payment',
                            style: TextStyle(
                                fontSize: 18, height: 1.25, fontWeight: FontWeight.w800, color: Tw.slate900)),
                        SizedBox(height: 2),
                        Text('Review your order before paying',
                            style: TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 20),
                  for (final (i, plan) in plans.indexed) ...[
                    if (i > 0) const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Tw.slate50,
                        borderRadius: BorderRadius.circular(SpRadius.xl),
                        border: Border.all(color: Tw.slate100),
                      ),
                      child: Row(children: [
                        Icon(BootstrapIcons.book_fill, size: 14, color: primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(jsDisplay(plan['class_name']),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: Tw.slate700)),
                        ),
                        const SizedBox(width: 8),
                        Text('₹${jsDisplay(plan['price'])}',
                            style: const TextStyle(
                                fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w700, color: Tw.slate800)),
                      ]),
                    ),
                  ],
                  if (referralApplied) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Tw.emerald50,
                        borderRadius: BorderRadius.circular(SpRadius.xl),
                        border: Border.all(color: Tw.emerald200),
                      ),
                      child: Row(children: [
                        const Icon(BootstrapIcons.gift_fill, size: 14, color: Tw.emerald500),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text.rich(
                            TextSpan(children: [
                              const TextSpan(text: 'Referral "'),
                              TextSpan(text: referralCode, style: const TextStyle(fontWeight: FontWeight.w700)),
                              const TextSpan(text: '" applied'),
                            ]),
                            style: const TextStyle(
                                fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: Tw.emerald600),
                          ),
                        ),
                      ]),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const HLine(darkColor: Tw.slate100),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(SpRadius.xl),
                      border: Border.all(color: primary.withValues(alpha: 0.2)),
                    ),
                    child: Row(children: [
                      const Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Total Payable',
                              style: TextStyle(
                                  fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w700, color: Tw.slate700)),
                          SizedBox(height: 2),
                          Text('Incl. 18% GST', style: TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
                        ]),
                      ),
                      Text('₹$grandTotal',
                          style: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w800, color: primary)),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
            child: Row(children: [
              Expanded(
                child: FlatPayButton(
                  label: 'Cancel',
                  icon: BootstrapIcons.x_lg,
                  expand: true,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  background: Tw.slate100,
                  hoverBackground: Tw.slate200,
                  foreground: Tw.slate700,
                  onPressed: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FlatPayButton(
                  label: 'Confirm & Pay',
                  icon: BootstrapIcons.shield_lock_fill,
                  expand: true,
                  weight: FontWeight.w700,
                  shadow: true,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  background: primary,
                  hoverBackground: primary.withValues(alpha: 0.9),
                  foreground: Colors.white,
                  onPressed: () => Navigator.of(context).pop(true),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  MODAL: Invoice
// ═══════════════════════════════════════════════════════════════════════════

/// The "Invoice" modal: fetches `getPaymentByIdAction(orderId)` and shows
/// the merged transaction (`invoiceLoading` / `invoiceError` / `invoiceData`
/// live here; `retryInvoice` refetches the same transaction).
class InvoiceDialog extends StatefulWidget {
  const InvoiceDialog({super.key, required this.txn, required this.orderId, required this.load});
  final Map<String, dynamic> txn;
  final String orderId;
  final Future<dynamic> Function(String orderId) load;

  @override
  State<InvoiceDialog> createState() => _InvoiceDialogState();
}

class _InvoiceDialogState extends State<InvoiceDialog> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) _fetch();
    });
  }

  /// `openInvoice(txn)` after the order-id check.
  Future<void> _fetch() async {
    setState(() {
      _loading = true;
      _error = null;
      _data = null;
    });
    try {
      final result = await widget.load(widget.orderId);
      if (!mounted) return;
      setState(() => _data = mergeInvoice(widget.txn, result));
    } catch (e) {
      if (mounted) setState(() => _error = jsErrorMessage(e, 'Failed to fetch invoice details.'));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    void close() => Navigator.of(context).pop();
    return _ModalCard(
      maxWidth: 512,
      maxHeight: MediaQuery.sizeOf(context).height * 0.9,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Invoice header
          Container(
            padding: const EdgeInsets.fromLTRB(28, 24, 28, 16),
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Tw.slate100))),
            child: Row(children: [
              // `w-10 h-10 rounded-xl` (20px radius → a circle).
              _iconBox(context, BootstrapIcons.receipt, size: 40, iconSize: 18, radius: SpRadius.xl),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Invoice',
                      style: TextStyle(fontSize: 18, height: 1.25, fontWeight: FontWeight.w800, color: Tw.slate900)),
                  Text('Payment Receipt', style: TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
                ]),
              ),
              _CloseSquare(onPressed: close),
            ]),
          ),
          // Invoice body
          Flexible(child: SingleChildScrollView(child: _body(context))),
          // Invoice footer (the "Print / Save" button is `hidden` on the web)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
            decoration: BoxDecoration(
              color: dark ? Tw.slate900 : Colors.white,
              border: const Border(top: BorderSide(color: Tw.slate100)),
            ),
            child: FlatPayButton(
              label: 'Close',
              icon: BootstrapIcons.x_lg,
              expand: true,
              padding: const EdgeInsets.symmetric(vertical: 12),
              background: Tw.slate100,
              hoverBackground: Tw.slate200,
              foreground: Tw.slate700,
              onPressed: close,
            ),
          ),
        ],
      ),
    );
  }

  Widget _body(BuildContext context) {
    final primary = SpTw.primary(context);
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(children: [
          SpinningIcon(BootstrapIcons.arrow_repeat, size: 20, color: primary),
          const SizedBox(height: 16),
          const Text('Fetching invoice details…', style: TextStyle(fontSize: 14, height: 20 / 14, color: Tw.slate400)),
        ]),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 28),
        child: Column(children: [
          const Icon(BootstrapIcons.exclamation_circle_fill, size: 20, color: Tw.rose500),
          const SizedBox(height: 16),
          const Text('Failed to load invoice',
              style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: Tw.slate600)),
          const SizedBox(height: 16),
          Text(_error!,
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, height: 20 / 14, color: Tw.slate400)),
          const SizedBox(height: 16),
          FlatPayButton(
            label: 'Retry',
            icon: BootstrapIcons.arrow_clockwise,
            background: primary,
            foreground: Colors.white,
            onPressed: _fetch,
          ),
        ]),
      );
    }
    final data = _data;
    if (data == null) return const SizedBox.shrink();
    return _InvoiceContent(data: data);
  }
}

class _CloseSquare extends StatefulWidget {
  const _CloseSquare({required this.onPressed});
  final VoidCallback onPressed;

  @override
  State<_CloseSquare> createState() => _CloseSquareState();
}

class _CloseSquareState extends State<_CloseSquare> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onPressed,
          // `w-9 h-9 rounded-xl`: the 20px radius is clamped to a circle.
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _hover ? Tw.slate200 : Tw.slate100,
              shape: BoxShape.circle,
            ),
            child: const Icon(BootstrapIcons.x_lg, size: 14, color: Tw.slate500),
          ),
        ),
      );
}

/// The invoice data: status banner, transaction details, payment breakdown.
class _InvoiceContent extends StatelessWidget {
  const _InvoiceContent({required this.data});
  final Map<String, dynamic> data;

  static const _rowIcons = <String, IconData>{
    'invoice': BootstrapIcons.receipt,
    'order': BootstrapIcons.hash,
    'transaction': BootstrapIcons.credit_card,
    'bank': BootstrapIcons.bank,
    'tracking': BootstrapIcons.geo_alt,
    'date': BootstrapIcons.calendar3,
    'gateway': BootstrapIcons.shield_lock,
    'mode': BootstrapIcons.wallet2,
    'currency': BootstrapIcons.currency_dollar,
    'status': BootstrapIcons.flag,
    'status_message': BootstrapIcons.chat_text,
    'failure': BootstrapIcons.exclamation_circle,
    'referral': BootstrapIcons.gift,
  };

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final primary = SpTw.primary(context);
    final theme = PayStatusStyle.of(payStatusKind(data));
    final invoiceNumber = data['invoice_number'];

    Widget box(List<Widget> rows) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Tw.slate100),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (i, r) in rows.indexed) ...[
                if (i > 0) const HLine(darkColor: Tw.slate100),
                r,
              ],
            ],
          ),
        );

    final rows = [
      for (final row in invoiceRows(data))
        if (row.visible) _detailRow(row, theme, dark),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Status banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: theme.bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: theme.border),
            ),
            child: Row(children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: theme.iconBg, borderRadius: BorderRadius.circular(SpRadius.xl)),
                child: Icon(theme.icon, size: 24, color: theme.iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(payStatusLabel(data),
                      style: TextStyle(fontSize: 16, height: 1.25, fontWeight: FontWeight.w800, color: theme.text)),
                  const SizedBox(height: 2),
                  Text(invoicePlanName(data),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
                  if (jsTruthy(invoiceNumber)) ...[
                    const SizedBox(height: 4),
                    Text('# ${jsDisplay(invoiceNumber)}',
                        style: const TextStyle(
                            fontSize: 12,
                            height: 16 / 12,
                            fontFamily: spMonoFamily,
                            fontFamilyFallback: spMonoFallback,
                            fontWeight: FontWeight.w700,
                            color: Tw.slate500)),
                  ],
                ]),
              ),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('₹${invoiceTotal(data)}',
                    style: TextStyle(fontSize: 24, height: 1.25, fontWeight: FontWeight.w800, color: theme.text)),
                const SizedBox(height: 2),
                Text('incl. ${invoiceGstPercentage(data)}% GST',
                    style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
              ]),
            ]),
          ),
          const SizedBox(height: 24),
          const Caption('Transaction Details', size: 10),
          const SizedBox(height: 8),
          box(rows),
          const SizedBox(height: 24),
          const Caption('Payment Breakdown', size: 10),
          const SizedBox(height: 8),
          box([
            _plainRow('Original Amount',
                '₹${jsTruthy(data['amount']) ? jsDisplay(data['amount']) : '0'}'),
            _plainRow('GST (${invoiceGstPercentage(data)}%)', invoiceGstAmount(data)),
            Container(
              color: Tw.slate50,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(children: [
                const Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Total Paid',
                        style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w700, color: Tw.slate800)),
                    Text('Incl. of all taxes', style: TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
                  ]),
                ),
                Text('₹${invoiceTotal(data)}',
                    style: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w800, color: primary)),
              ]),
            ),
          ]),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.only(bottom: 4),
            child: Text(
              'This is a system-generated receipt. For support, contact us with your Order ID or Invoice No.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, height: 1.6, color: Tw.slate400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _plainRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400))),
          const SizedBox(width: 16),
          Text(value,
              style: const TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: Tw.slate700)),
        ]),
      );

  Widget _detailRow(InvoiceRowData row, PayStatusStyle theme, bool dark) {
    final failure = row.key == 'failure';
    final labelColor = failure ? Tw.rose400 : Tw.slate400;
    final value = jsDisplay(row.value);

    final mono = const {'invoice', 'order', 'transaction', 'bank', 'tracking'}.contains(row.key);
    final Color valueColor = switch (row.key) {
      'invoice' => Tw.slate700,
      'order' || 'transaction' || 'bank' || 'tracking' => Tw.slate600,
      'failure' => Tw.rose600,
      'referral' => Tw.emerald600,
      _ => dark ? Tw.slate200 : Tw.slate700,
    };
    // The value span always has `font-semibold`; the rows' extra
    // `font-bold` (Invoice No., Referral Code) is generated earlier in the
    // stylesheet, so `font-semibold` wins.
    const weight = FontWeight.w600;

    return Container(
      color: failure ? Tw.rose50 : null,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(children: [
        Icon(_rowIcons[row.key], size: 12, color: labelColor),
        const SizedBox(width: 6),
        Text(row.label, style: TextStyle(fontSize: 12, height: 16 / 12, color: labelColor)),
        const SizedBox(width: 16),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: row.key == 'status'
                ? PayStatusBadge(label: value, style: theme, wide: true)
                : Text(
                    value,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: weight,
                      color: valueColor,
                      fontFamily: mono ? spMonoFamily : null,
                      fontFamilyFallback: mono ? spMonoFallback : null,
                    ),
                  ),
          ),
        ),
      ]),
    );
  }
}

