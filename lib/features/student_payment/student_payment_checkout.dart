import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import 'student_payment_logic.dart';
import 'student_payment_widgets.dart';

/// `px-6 sm:px-10`
double checkoutPadX(BuildContext context) => context.isSm ? 40 : 24;

// ═══════════════════════════════════════════════════════════════════════════
//  Header + Tabs
// ═══════════════════════════════════════════════════════════════════════════

class CheckoutHeader extends StatelessWidget {
  const CheckoutHeader({
    super.key,
    required this.getuserbyid,
    required this.currentPlanName,
    required this.activeTab,
    required this.onTab,
    required this.selectedCount,
    required this.historyCount,
  });

  final dynamic getuserbyid;
  final String currentPlanName;

  /// `'order'` | `'history'`
  final String activeTab;
  final ValueChanged<String> onTab;
  final int selectedCount;
  final int historyCount;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final px = checkoutPadX(context);
    final subscription = asMap(getuserbyid)?['subscription'];

    return Container(
      padding: EdgeInsets.fromLTRB(px, 24, px, 0),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900 : Colors.white,
        border: Border(
          bottom: BorderSide(color: dark ? Tw.slate700.withValues(alpha: 0.8) : Tw.slate200),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StepBreadcrumb(currentStep: 2),
          const SizedBox(height: 20),
          Text(
            'Review Your Order',
            style: TextStyle(
              fontSize: context.isSm ? 30 : 24,
              height: spLeading(context.isSm ? 30 : 24),
              fontWeight: FontWeight.w800,
              letterSpacing: -0.025 * (context.isSm ? 30 : 24),
              color: dark ? Tw.slate50 : Tw.slate900,
            ),
          ),
          const SizedBox(height: 4),
          const Text('Select a plan before proceeding to payment.',
              style: TextStyle(fontSize: 14, height: 20 / 14, color: Tw.slate500)),
          if (jsTruthy(subscription)) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Tw.emerald50,
                borderRadius: BorderRadius.circular(SpRadius.xl),
                border: Border.all(color: Tw.emerald200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CURRENT PLAN',
                      style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700, color: Tw.emerald600)),
                  // `font-bold text-lg` with no colour: the shell's
                  // `text-gray-900 dark:text-white`.
                  Text(currentPlanName,
                      style: TextStyle(
                          fontSize: 18,
                          height: 28 / 18,
                          fontWeight: FontWeight.w700,
                          color: SpTw.foreground(context))),
                  Text(jsDisplay(asMap(subscription)?['status']),
                      style: const TextStyle(fontSize: 14, height: 20 / 14, color: Tw.slate500)),
                  const SizedBox(height: 4),
                  Text('Valid Till: ${formatPaymentDate(asMap(subscription)?['end_date'])}',
                      style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
                ],
              ),
            ),
          ],
          const SizedBox(height: 20),
          // `-mb-px`: the active tab's border covers the header's border-b.
          Transform.translate(
            offset: const Offset(0, 1),
            child: Wrap(
              spacing: 4,
              children: [
                for (final tab in const ['order', 'history'])
                  _TabButton(
                    active: activeTab == tab,
                    icon: tab == 'order' ? BootstrapIcons.cart3 : BootstrapIcons.clock_history,
                    label: tab == 'order' ? 'Order' : 'Payment History',
                    count: tab == 'order' ? selectedCount : historyCount,
                    onTap: () => onTab(tab),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.active,
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = SpTw.primary(context);
    return PayHover(
      onTap: onTap,
      builder: (context, hover) {
        final color = active ? primary : (hover ? Tw.slate600 : Tw.slate400);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: active ? primary : Colors.transparent, width: 2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 8),
              Text(label, style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: color)),
              if (count > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('$count',
                      style: TextStyle(fontSize: 10, height: 1.4, fontWeight: FontWeight.w700, color: primary)),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  TAB: Order
// ═══════════════════════════════════════════════════════════════════════════

class OrderTab extends StatelessWidget {
  const OrderTab({
    super.key,
    required this.allPlans,
    required this.isSelected,
    required this.onToggle,
    required this.onReload,
    required this.hasSelection,
  });

  final List<Map<String, dynamic>> allPlans;
  final bool Function(Map<String, dynamic> plan) isSelected;
  final ValueChanged<Map<String, dynamic>> onToggle;
  final VoidCallback onReload;
  final bool hasSelection;

  @override
  Widget build(BuildContext context) {
    final primary = SpTw.primary(context);
    final px = checkoutPadX(context);
    final children = <Widget>[
      const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Caption('Available Plans'),
          Text('Select a plan', style: TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
        ],
      ),
      if (allPlans.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 80),
          child: Column(children: [
            const Icon(BootstrapIcons.cart3, size: 30, color: Tw.slate400),
            const SizedBox(height: 16),
            const Text('No plans available.',
                style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500, color: Tw.slate400)),
            const SizedBox(height: 16),
            UnderlineTextButton(
              label: 'Reload',
              icon: BootstrapIcons.arrow_clockwise,
              color: primary,
              weight: FontWeight.w600,
              onTap: onReload,
            ),
          ]),
        ),
      for (final plan in allPlans) PlanCard(plan: plan, selected: isSelected(plan), onTap: () => onToggle(plan)),
      if (!hasSelection && allPlans.isNotEmpty)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Tw.amber50,
            borderRadius: BorderRadius.circular(SpRadius.xl2),
            border: Border.all(color: Tw.amber200),
          ),
          child: const Row(children: [
            Icon(BootstrapIcons.info_circle_fill, size: 14, color: Tw.amber500),
            SizedBox(width: 12),
            Expanded(
              child: Text('Please select a plan to proceed.',
                  style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: Tw.amber700)),
            ),
          ]),
        ),
    ];
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: px, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, c) in children.indexed) ...[
            if (i > 0) const SizedBox(height: 16),
            c,
          ],
        ],
      ),
    );
  }
}

/// A plan card: radio circle, book icon, name + chips, price.
class PlanCard extends StatelessWidget {
  const PlanCard({super.key, required this.plan, required this.selected, required this.onTap});
  final Map<String, dynamic> plan;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final primary = SpTw.primary(context);
    final fullAccess = jsTruthy(plan['full_access']);

    Widget chip(Widget child, {Color? bg, Color? border}) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: bg ?? (dark ? Tw.slate800 : Tw.slate100),
            borderRadius: BorderRadius.circular(999),
            border: border == null ? null : Border.all(color: border),
          ),
          child: child,
        );
    const chipText = TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate500);

    return PayHover(
      onTap: onTap,
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.05) : (dark ? Tw.slate900 : Colors.white),
          borderRadius: BorderRadius.circular(SpRadius.xl2),
          border: Border.all(
            color: selected
                ? primary.withValues(alpha: 0.4)
                : hover
                    ? primary.withValues(alpha: 0.3)
                    : (dark ? Tw.slate700.withValues(alpha: 0.8) : Tw.slate200),
          ),
          // `shadow-md shadow-primary/10` — the colour modifier has no effect
          // on this theme's shadow variables.
          boxShadow: selected || hover ? AppShadows.md : null,
        ),
        child: Row(
          children: [
            // Radio circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? primary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  width: 2,
                  color: selected ? primary : (hover ? primary.withValues(alpha: 0.5) : Tw.slate300),
                ),
              ),
              child: selected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            // Icon
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SpRadius.xl),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Icon(BootstrapIcons.book_fill, size: 20, color: primary),
            ),
            const SizedBox(width: 16),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jsDisplay(plan['class_name']),
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: selected ? primary : (dark ? Tw.slate100 : Tw.slate800),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (jsTruthy(plan['syllabus'])) chip(Text(jsDisplay(plan['syllabus']), style: chipText)),
                      chip(Text('${jsDisplay(plan['duration'])} days', style: chipText)),
                      chip(
                        Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(fullAccess ? BootstrapIcons.unlock_fill : BootstrapIcons.lock_fill,
                              size: 12, color: fullAccess ? Tw.emerald600 : Tw.slate500),
                          const SizedBox(width: 4),
                          Text(fullAccess ? 'Full Access' : 'Demo',
                              style: TextStyle(
                                fontSize: 12,
                                height: 16 / 12,
                                fontWeight: FontWeight.w600,
                                color: fullAccess ? Tw.emerald600 : Tw.slate500,
                              )),
                        ]),
                        bg: fullAccess ? Tw.emerald50 : Tw.slate100,
                        border: fullAccess ? Tw.emerald200 : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${jsDisplay(plan['price'])}',
                    style: TextStyle(
                      fontSize: 20,
                      height: 28 / 20,
                      fontWeight: FontWeight.w800,
                      color: selected ? primary : (dark ? Tw.slate50 : Tw.slate900),
                    )),
                const SizedBox(height: 4),
                const Text('incl. 18% GST', style: TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  TAB: History
// ═══════════════════════════════════════════════════════════════════════════

class HistoryTab extends StatelessWidget {
  const HistoryTab({
    super.key,
    required this.history,
    required this.loading,
    required this.onRefresh,
    required this.onOpen,
  });

  final List<dynamic> history;
  final bool loading;
  final VoidCallback onRefresh;
  final ValueChanged<Map<String, dynamic>> onOpen;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final primary = SpTw.primary(context);
    final px = checkoutPadX(context);

    final Widget body;
    if (loading) {
      body = Column(children: [
        for (var n = 0; n < 3; n++) ...[
          if (n > 0) const SizedBox(height: 12),
          _Pulse(
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: dark ? Tw.slate800 : Tw.slate100,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ]);
    } else if (history.isNotEmpty) {
      body = Column(children: [
        for (final (i, t) in history.indexed) ...[
          if (i > 0) const SizedBox(height: 16),
          HistoryItem(txn: asMap(t) ?? const {}, onTap: () => onOpen(asMap(t) ?? const {})),
        ],
      ]);
    } else {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 80),
        child: Column(children: [
          const Icon(BootstrapIcons.receipt, size: 30, color: Tw.slate400),
          const SizedBox(height: 16),
          const Text('No transactions yet',
              style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: Tw.slate500)),
          const SizedBox(height: 16),
          // `max-w-xs`
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: const Text('Your payment history will appear here after a purchase.',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 20 / 14, color: Tw.slate400)),
          ),
        ]),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: px, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Caption('Transaction History'),
              // `<button :disabled="historyLoading">` (no disabled styling).
              PayHover(
                onTap: loading ? null : onRefresh,
                cursor: loading ? MouseCursor.defer : SystemMouseCursors.click,
                builder: (context, _) => Row(mainAxisSize: MainAxisSize.min, children: [
                  loading
                      ? SpinningIcon(BootstrapIcons.arrow_clockwise, size: 14, color: primary)
                      : Icon(BootstrapIcons.arrow_clockwise, size: 14, color: primary),
                  const SizedBox(width: 6),
                  Text('Refresh',
                      style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: primary)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          body,
        ],
      ),
    );
  }
}

/// One transaction of the payment history.
class HistoryItem extends StatelessWidget {
  const HistoryItem({super.key, required this.txn, required this.onTap});
  final Map<String, dynamic> txn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final primary = SpTw.primary(context);
    final style = PayStatusStyle.of(payStatusKind(txn));
    final date = firstTruthy([txn['created_at'], txn['date']]);
    final transactionId = txn['transaction_id'];

    return PayHover(
      onTap: onTap,
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: dark ? Tw.slate900 : Colors.white,
          borderRadius: BorderRadius.circular(SpRadius.xl2),
          border: Border.all(
            color: hover
                ? primary.withValues(alpha: 0.3)
                : (dark ? Tw.slate700.withValues(alpha: 0.8) : Tw.slate200),
          ),
          boxShadow: hover ? AppShadows.md : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: style.bg,
                borderRadius: BorderRadius.circular(SpRadius.xl),
                border: Border.all(color: style.border),
              ),
              child: Icon(style.icon, size: 18, color: style.iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(historyTitle(txn),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w700,
                          color: dark ? Tw.slate100 : Tw.slate800)),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      PayStatusBadge(label: payStatusLabel(txn), style: style),
                      if (date != null)
                        Text(formatPaymentDate(date),
                            style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
                      if (jsTruthy(transactionId))
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 120),
                          child: Text('#${jsDisplay(transactionId)}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12,
                                  height: 16 / 12,
                                  fontFamily: spMonoFamily,
                                  fontFamilyFallback: spMonoFallback,
                                  color: Tw.slate400)),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('₹${totalWithGst(txn)}',
                    style: TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        fontWeight: FontWeight.w800,
                        color: dark ? Tw.slate50 : Tw.slate900)),
                const SizedBox(height: 4),
                Text(
                    '₹${jsDisplay(firstTruthy([txn['amount'], txn['price']]) ?? '0')} + 18% GST',
                    style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
                const SizedBox(height: 4),
                AnimatedOpacity(
                  opacity: hover ? 1 : 0,
                  duration: const Duration(milliseconds: 150),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(BootstrapIcons.receipt, size: 10, color: primary),
                    const SizedBox(width: 4),
                    Text('View Invoice',
                        style: TextStyle(fontSize: 10, height: 1.5, fontWeight: FontWeight.w600, color: primary)),
                  ]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tailwind `animate-pulse`.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
        ]).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
        child: widget.child,
      );
}

// ═══════════════════════════════════════════════════════════════════════════
//  RIGHT SIDE: Order Summary
// ═══════════════════════════════════════════════════════════════════════════

/// The order-summary sidebar. On `lg` it is a fixed column on the right
/// whose middle part scrolls ([fixed]); below `lg` it follows the plans.
class OrderSummary extends StatelessWidget {
  const OrderSummary({
    super.key,
    required this.fixed,
    required this.selectedPlans,
    required this.totals,
    required this.referralApplied,
    required this.referralDiscount,
    required this.showReferral,
    required this.referralController,
    required this.referralError,
    required this.onApplyReferral,
    required this.onRemoveReferral,
    required this.paymentError,
    required this.paymentLoading,
    required this.onPay,
  });

  final bool fixed;
  final List<Map<String, dynamic>> selectedPlans;
  final OrderTotals totals;
  final bool referralApplied;
  final double referralDiscount;
  final bool showReferral;
  final TextEditingController referralController;
  final String referralError;
  final VoidCallback onApplyReferral;
  final VoidCallback onRemoveReferral;
  final String? paymentError;
  final bool paymentLoading;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final primary = SpTw.primary(context);
    final edge = dark ? Tw.slate700.withValues(alpha: 0.8) : Tw.slate100;

    final header = Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: dark ? 0.1 : 0.05),
        border: Border(bottom: BorderSide(color: edge)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Order Summary',
              style: TextStyle(
                  fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w800, color: dark ? Tw.slate100 : Tw.slate800)),
          const SizedBox(height: 2),
          const Text('1 plan selected', style: TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
        ],
      ),
    );

    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: _summaryBody(context),
    );

    final footer = Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900 : Colors.white,
        border: Border(top: BorderSide(color: edge)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PayButton(
            loading: paymentLoading,
            hasSelection: selectedPlans.isNotEmpty,
            grandTotal: totals.grandTotal,
            onPressed: onPay,
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(BootstrapIcons.shield_lock_fill, size: 12, color: Tw.slate400),
              SizedBox(width: 6),
              Text('Secured & encrypted payment', style: TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
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
        mainAxisSize: fixed ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          if (fixed) Expanded(child: SingleChildScrollView(child: body)) else body,
          footer,
        ],
      ),
    );
  }

  Widget _summaryBody(BuildContext context) {
    final dark = context.isDark;
    final primary = SpTw.primary(context);
    final children = <Widget>[];

    if (selectedPlans.isEmpty) {
      children.add(const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          Icon(BootstrapIcons.cart3, size: 20, color: Tw.slate400),
          SizedBox(height: 12),
          Text('No plan selected',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: Tw.slate400)),
          SizedBox(height: 12),
          Text('Click a plan on the left to add it.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
        ]),
      ));
    } else {
      children.add(Column(children: [
        for (final (i, plan) in selectedPlans.indexed) ...[
          if (i > 0) const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dark ? Tw.slate800.withValues(alpha: 0.6) : Tw.slate50,
              borderRadius: BorderRadius.circular(SpRadius.xl),
              border: Border.all(color: dark ? Tw.slate700.withValues(alpha: 0.6) : Tw.slate100),
            ),
            child: Row(children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SpRadius.lg),
                ),
                child: Icon(BootstrapIcons.book_fill, size: 14, color: primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(jsDisplay(plan['class_name']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w500,
                        color: dark ? Tw.slate300 : Tw.slate600)),
              ),
              const SizedBox(width: 12),
              Text('₹${jsDisplay(plan['price'])}',
                  style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w600,
                      color: dark ? Tw.slate200 : Tw.slate800)),
            ]),
          ),
        ],
      ]));

      children.add(const HLine());
      if (referralApplied && referralDiscount > 0) {
        children.add(Row(children: [
          Expanded(
            child: Text('Discount (${jsDisplay(referralDiscount)}%)',
                style: const TextStyle(fontSize: 14, height: 20 / 14, color: Tw.emerald600)),
          ),
          Text('-₹${totals.discountAmount}',
              style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: Tw.emerald600)),
        ]));
      }
      children.add(Row(children: [
        const Text('GST', style: TextStyle(fontSize: 14, height: 20 / 14, color: Tw.slate500)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Tw.amber50,
            borderRadius: BorderRadius.circular(SpRadius.md),
            border: Border.all(color: Tw.amber200),
          ),
          child: const Text('18%',
              style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700, color: Tw.amber600)),
        ),
        const Spacer(),
        Text('+₹${totals.gstAmount}',
            style: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: Tw.slate700)),
      ]));
      children.add(const HLine());
      children.add(Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Total Payable',
                style: TextStyle(
                    fontSize: 16, height: 1.5, fontWeight: FontWeight.w700, color: dark ? Tw.slate100 : Tw.slate800)),
            const SizedBox(height: 2),
            const Text('Incl. of all taxes', style: TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
          ]),
        ),
        Text('₹${totals.grandTotal}',
            style: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w800, color: primary)),
      ]));
      children.add(const HLine());
    }

    if (showReferral) {
      children.add(ReferralField(
        controller: referralController,
        applied: referralApplied,
        error: referralError,
        onApply: onApplyReferral,
        onRemove: onRemoveReferral,
      ));
    }

    if (jsTruthy(paymentError)) {
      children.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Tw.rose50,
          borderRadius: BorderRadius.circular(SpRadius.xl),
          border: Border.all(color: Tw.rose200),
        ),
        child: Row(children: [
          const Icon(BootstrapIcons.exclamation_circle_fill, size: 16, color: Tw.rose500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(paymentError!,
                style: const TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: Tw.rose600)),
          ),
        ]),
      ));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (i, c) in children.indexed) ...[
          if (i > 0) const SizedBox(height: 20),
          c,
        ],
      ],
    );
  }
}

/// The referral-code input with its absolutely positioned Apply / Applied
/// button, error line and "applied" line.
class ReferralField extends StatefulWidget {
  const ReferralField({
    super.key,
    required this.controller,
    required this.applied,
    required this.error,
    required this.onApply,
    required this.onRemove,
  });

  final TextEditingController controller;
  final bool applied;
  final String error;
  final VoidCallback onApply;
  final VoidCallback onRemove;

  @override
  State<ReferralField> createState() => _ReferralFieldState();
}

class _ReferralFieldState extends State<ReferralField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_onFocus);
  }

  @override
  void dispose() {
    _focus.removeListener(_onFocus);
    _focus.dispose();
    super.dispose();
  }

  void _onFocus() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final dark = context.isDark;
    final primary = SpTw.primary(context);
    final hasCode = w.controller.text.trim().isNotEmpty;
    final hasError = w.error.isNotEmpty;
    final focused = _focus.hasFocus && !w.applied;

    // applied: `bg-emerald-50 border-emerald-300 text-emerald-700`
    // error:   `bg-rose-50 border-rose-300 focus:ring-2 focus:ring-rose-300`
    // default: `bg-slate-50 dark:bg-slate-800 border-slate-200
    //           dark:border-slate-700 focus:border-primary focus:ring-2
    //           focus:ring-primary/20`
    final Color fill;
    final Color border;
    final Color? ring;
    if (w.applied) {
      fill = Tw.emerald50;
      border = Tw.emerald300;
      ring = null;
    } else if (hasError) {
      fill = Tw.rose50;
      border = Tw.rose300;
      ring = focused ? Tw.rose300 : null;
    } else {
      fill = dark ? Tw.slate800 : Tw.slate50;
      border = focused ? primary : (dark ? Tw.slate700 : Tw.slate200);
      ring = focused ? primary.withValues(alpha: 0.2) : null;
    }
    OutlineInputBorder outline(Color c) =>
        OutlineInputBorder(borderRadius: BorderRadius.circular(SpRadius.xl), borderSide: BorderSide(color: c));

    final Widget button = w.applied
        ? GestureDetector(
            onTap: w.onRemove,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Tw.emerald100,
                  borderRadius: BorderRadius.circular(SpRadius.lg),
                  border: Border.all(color: Tw.emerald200),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(BootstrapIcons.check_circle_fill, size: 12, color: Tw.emerald600),
                  SizedBox(width: 4),
                  Text('Applied',
                      style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700, color: Tw.emerald600)),
                  SizedBox(width: 6),
                  Icon(BootstrapIcons.x_lg, size: 10, color: Tw.emerald600),
                ]),
              ),
            ),
          )
        : PayHover(
            onTap: hasCode ? w.onApply : null,
            cursor: hasCode ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
            builder: (context, hover) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                // `bg-primary text-white hover:bg-primary/90` /
                // `bg-slate-200 text-slate-400 cursor-not-allowed`
                color: hasCode ? (hover ? primary.withValues(alpha: 0.9) : primary) : Tw.slate200,
                borderRadius: BorderRadius.circular(SpRadius.lg),
              ),
              child: Text('Apply',
                  style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w700,
                      color: hasCode ? Colors.white : Tw.slate400)),
            ),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          Icon(BootstrapIcons.gift_fill, size: 12, color: primary.withValues(alpha: 0.7)),
          const SizedBox(width: 6),
          const Flexible(
            child: Text.rich(
              TextSpan(children: [
                TextSpan(text: 'Referral Code '),
                TextSpan(text: '(optional)', style: TextStyle(fontWeight: FontWeight.w400, color: Tw.slate400)),
              ]),
              style: TextStyle(
                  fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700, letterSpacing: 0.3, color: Tw.slate500),
            ),
          ),
        ]),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SpRadius.xl),
            // `ring-2`: a 2px ring outside the border.
            boxShadow: ring == null ? const [] : [BoxShadow(color: ring, spreadRadius: 2)],
          ),
          child: Stack(
            alignment: Alignment.centerRight,
            children: [
              MouseRegion(
                cursor: w.applied ? SystemMouseCursors.forbidden : SystemMouseCursors.text,
                child: TextField(
                  controller: w.controller,
                  focusNode: _focus,
                  enabled: !w.applied,
                  onSubmitted: (_) => w.onApply(),
                  inputFormatters: [LengthLimitingTextInputFormatter(32)],
                  cursorColor: SpTw.foreground(context),
                  // `text-sm font-medium`; the colour is inherited from the
                  // shell (`text-gray-900 dark:text-white`) unless applied.
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: w.applied ? Tw.emerald700 : SpTw.foreground(context),
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Enter code e.g. FRIEND10',
                    hintStyle: const TextStyle(
                        fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: AppColors.placeholder),
                    filled: true,
                    fillColor: fill,
                    hoverColor: Colors.transparent,
                    // `pl-4 pr-20 py-2.5`
                    contentPadding: const EdgeInsets.fromLTRB(16, 11, 80, 11),
                    enabledBorder: outline(border),
                    disabledBorder: outline(border),
                    border: outline(border),
                    focusedBorder: outline(border),
                  ),
                ),
              ),
              Positioned(right: 8, child: button),
            ],
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(BootstrapIcons.exclamation_circle_fill, size: 12, color: Tw.rose500),
            const SizedBox(width: 4),
            Expanded(child: Text(w.error, style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.rose500))),
          ]),
        ],
        if (w.applied) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(BootstrapIcons.gift_fill, size: 12, color: Tw.emerald600),
            const SizedBox(width: 4),
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  const TextSpan(text: 'Referral "'),
                  TextSpan(text: w.controller.text, style: const TextStyle(fontWeight: FontWeight.w700)),
                  const TextSpan(text: '" applied!'),
                ]),
                style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.emerald600),
              ),
            ),
          ]),
        ],
      ],
    );
  }
}

/// "Pay ₹X (incl. 18% GST)" — the kit `<Button>` with `w-full rounded-xl
/// text-white font-bold py-4 text-base shadow-md`. The size variant's `h-9`
/// survives tailwind-merge, so the button is 36px tall (the `py-4` content
/// overflows evenly and stays centred). Enabled: `bg-primary
/// hover:bg-primary/90 hover:scale-[1.02] active:scale-95`; disabled:
/// `bg-primary/40` plus the kit's `disabled:opacity-50`.
class PayButton extends StatefulWidget {
  const PayButton({
    super.key,
    required this.loading,
    required this.hasSelection,
    required this.grandTotal,
    required this.onPressed,
  });

  final bool loading;
  final bool hasSelection;
  final String grandTotal;
  final VoidCallback onPressed;

  @override
  State<PayButton> createState() => _PayButtonState();
}

class _PayButtonState extends State<PayButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final primary = SpTw.primary(context);
    final disabled = widget.loading || !widget.hasSelection;
    const textStyle = TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w700, color: Colors.white);
    const gap = SizedBox(width: 8);

    final List<Widget> content;
    if (widget.loading) {
      content = const [
        SpinningIcon(BootstrapIcons.arrow_repeat, size: 18, color: Colors.white),
        gap,
        Flexible(child: Text('Processing...', maxLines: 1, overflow: TextOverflow.ellipsis, style: textStyle)),
      ];
    } else if (!widget.hasSelection) {
      content = const [
        Icon(BootstrapIcons.cart3, size: 16, color: Colors.white),
        gap,
        Flexible(child: Text('Select a Plan', maxLines: 1, overflow: TextOverflow.ellipsis, style: textStyle)),
      ];
    } else {
      // Flex items separated by the button's `gap-2`.
      content = [
        const Icon(BootstrapIcons.shield_lock_fill, size: 16, color: Colors.white),
        gap,
        Flexible(
          child: Text('Pay ₹${widget.grandTotal}', maxLines: 1, overflow: TextOverflow.ellipsis, style: textStyle),
        ),
        gap,
        Flexible(
          child: Text('(incl. 18% GST)',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.white.withValues(alpha: 0.75))),
        ),
        gap,
        AnimatedSlide(
          offset: Offset(_hover ? 0.25 : 0, 0),
          duration: const Duration(milliseconds: 300),
          child: const Icon(BootstrapIcons.arrow_right, size: 16, color: Colors.white),
        ),
      ];
    }

    // `disabled:pointer-events-none`: no hover/press effects while disabled.
    final hover = _hover && !disabled;
    final scale = disabled ? 1.0 : (_down ? 0.95 : (hover ? 1.02 : 1.0));
    return MouseRegion(
      cursor: disabled ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: disabled ? null : (_) => setState(() => _down = true),
        onTapUp: disabled ? null : (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: disabled ? null : widget.onPressed,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 300),
          // `disabled:opacity-50`
          child: AnimatedOpacity(
            opacity: disabled ? 0.5 : 1,
            duration: const Duration(milliseconds: 300),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: disabled ? primary.withValues(alpha: 0.4) : (hover ? primary.withValues(alpha: 0.9) : primary),
                borderRadius: BorderRadius.circular(SpRadius.xl),
                boxShadow: AppShadows.md,
              ),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: content),
            ),
          ),
        ),
      ),
    );
  }
}
