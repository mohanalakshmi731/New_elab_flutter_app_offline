import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/lucide_icon.dart';
import 'student_payment_logic.dart';

/// Colours of studentpayment.vue that are not a plain `Tw` lookup.
///
/// The `rose*` / `amber*` / `emerald300` aliases point at the Tailwind v4
/// palette ([Tw]) the web build uses.
class SpTw {
  SpTw._();

  /// `--primary` in style.css: `#4f46e5` (light) / `#9db1d4` (dark).
  static Color primary(BuildContext context) => context.isDark ? AppColors.darkPrimary : AppColors.primary;

  /// Text that sets no colour inherits the shells' `text-gray-900
  /// dark:text-white` (DashboardLayout `<main>` / newdashboardlayout root).
  static Color foreground(BuildContext context) => context.isDark ? Colors.white : Tw.gray900;

  static const emerald300 = Tw.emerald300;
  static const rose100 = Tw.rose100;
  static const rose300 = Tw.rose300;
  static const rose400 = Tw.rose400;
  static const rose700 = Tw.rose700;
  static const amber100 = Tw.amber100;
  static const amber700 = Tw.amber700;
}

/// This theme's radii (style.css `--radius: 1rem`): `rounded-md` 14,
/// `rounded-lg` 16, `rounded-xl` 20; `rounded-2xl` 16 and `rounded-3xl` 24
/// keep Tailwind's values.
class SpRadius {
  SpRadius._();
  static const md = 14.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xl2 = 16.0;
  static const xl3 = 24.0;
}

/// Tailwind's line height for a `text-*` size as a Flutter height factor
/// (`text-xs` 16px, `text-sm` 20px, `text-base` 24px, `text-lg`/`text-xl`
/// 28px, `text-2xl` 32px, `text-3xl` 36px, `text-5xl` 1).
double spLeading(double fontSize) => switch (fontSize) {
      12.0 => 16 / 12,
      14.0 => 20 / 14,
      16.0 => 24 / 16,
      18.0 => 28 / 18,
      20.0 => 28 / 20,
      24.0 => 32 / 24,
      30.0 => 36 / 30,
      48.0 => 1,
      _ => 1.5,
    };

/// `font-mono` (ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, …).
const spMonoFamily = 'monospace';
const spMonoFallback = <String>['SF Mono', 'Menlo', 'Monaco', 'Consolas', 'Liberation Mono', 'Courier New'];

/// `animate-spin` icon (one turn per second).
class SpinningIcon extends StatefulWidget {
  const SpinningIcon(this.icon, {super.key, required this.size, required this.color});
  final IconData icon;
  final double size;
  final Color color;

  @override
  State<SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<SpinningIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      RotationTransition(turns: _c, child: Icon(widget.icon, size: widget.size, color: widget.color));
}

/// Tracks `:hover` (and `group-hover`) for a clickable area.
class PayHover extends StatefulWidget {
  const PayHover({super.key, required this.builder, this.onTap, this.cursor});
  final Widget Function(BuildContext context, bool hover) builder;
  final VoidCallback? onTap;

  /// Defaults to the click cursor when [onTap] is set.
  final MouseCursor? cursor;

  @override
  State<PayHover> createState() => _PayHoverState();
}

class _PayHoverState extends State<PayHover> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: widget.cursor ?? (widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer),
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: widget.builder(context, _hover),
        ),
      );
}

/// `h-px bg-slate-100 dark:bg-slate-800` (pass [darkColor] when the web has
/// no dark variant).
class HLine extends StatelessWidget {
  const HLine({super.key, this.color = Tw.slate100, this.darkColor = Tw.slate800});
  final Color color;
  final Color darkColor;

  @override
  Widget build(BuildContext context) => Container(height: 1, color: context.isDark ? darkColor : color);
}

/// Tailwind `tracking-widest` section caption (`text-xs font-bold uppercase
/// text-slate-400`).
class Caption extends StatelessWidget {
  const Caption(this.text, {super.key, this.size = 12});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: size,
          height: size == 12 ? 16 / 12 : null,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.1 * size,
          color: Tw.slate400,
        ),
      );
}

/// Colours of `statusStyle(item)` / `invoiceTheme(data)`.
class PayStatusStyle {
  const PayStatusStyle({
    required this.bg,
    required this.border,
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.text,
    required this.badgeText,
  });

  factory PayStatusStyle.of(PayStatusKind kind) => switch (kind) {
        PayStatusKind.paid => const PayStatusStyle(
            bg: Tw.emerald50,
            border: Tw.emerald200,
            iconBg: Tw.emerald100,
            icon: BootstrapIcons.check_circle_fill,
            iconColor: Tw.emerald500,
            text: Tw.emerald700,
            badgeText: Tw.emerald700,
          ),
        PayStatusKind.failed => const PayStatusStyle(
            bg: Tw.rose50,
            border: Tw.rose200,
            iconBg: Tw.rose100,
            icon: BootstrapIcons.x_circle_fill,
            iconColor: Tw.rose500,
            text: Tw.rose700,
            badgeText: Tw.rose700,
          ),
        PayStatusKind.other => const PayStatusStyle(
            bg: Tw.amber50,
            border: Tw.amber200,
            iconBg: Tw.amber100,
            icon: BootstrapIcons.clock_history,
            iconColor: Tw.amber500,
            text: Tw.amber700,
            badgeText: Tw.amber700,
          ),
      };

  /// `bg-*-50` (banner / icon wrap / badge background).
  final Color bg;

  /// `border-*-200`
  final Color border;

  /// `bg-*-100` (invoice banner icon box).
  final Color iconBg;
  final IconData icon;
  final Color iconColor;

  /// `text-*-700`
  final Color text;
  final Color badgeText;
}

/// The status pill (`text-xs px-2 py-0.5 rounded-full font-semibold` +
/// `statusStyle(txn).badge`).
class PayStatusBadge extends StatelessWidget {
  const PayStatusBadge({super.key, required this.label, required this.style, this.wide = false});
  final String label;
  final PayStatusStyle style;

  /// `px-2.5 py-1` (invoice rows) instead of `px-2 py-0.5`.
  final bool wide;

  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(horizontal: wide ? 10 : 8, vertical: wide ? 4 : 2),
        decoration: BoxDecoration(
          color: style.bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: style.border),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: style.badgeText)),
      );
}

/// The `StepBreadcrumb` component: Plan Selected → Review & Pay → Confirmed.
///
/// [compact]: inside the centred result column the `flex-1` connector lines
/// get no width on the web (shrink-to-fit container), only the gaps remain.
class StepBreadcrumb extends StatelessWidget {
  const StepBreadcrumb({super.key, this.currentStep = 2, this.resultStatus, this.compact = false});
  final int currentStep;

  /// `'success'` / `'failed'` / null.
  final String? resultStatus;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final primary = SpTw.primary(context);
    const gap = SizedBox(width: 8);

    Widget circle({required Color color, Color? border, required Widget child}) => Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: border == null ? null : Border.all(color: border),
          ),
          child: child,
        );
    // `<svg class="w-3 h-3" stroke-width="3">` check / cross.
    const check = LucideIcon(Lucide.check, size: 12, color: Colors.white, strokeWidth: 3);
    const cross = LucideIcon(Lucide.x, size: 12, color: Colors.white, strokeWidth: 3);
    Widget number(String n, Color color) =>
        Text(n, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color, height: 1));
    Widget label(String text, bool strong) => Text(
          text,
          softWrap: false,
          style: TextStyle(
            fontSize: 12,
            height: 16 / 12,
            fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
            color: strong ? Tw.slate800 : Tw.slate400,
          ),
        );
    Widget line(Color color, bool withLines) => !withLines
        ? const SizedBox.shrink()
        : Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 60),
              child: Container(height: 1, color: color),
            ),
          );

    final step2 = currentStep > 2
        ? circle(color: Tw.emerald500, child: check)
        : currentStep == 2
            ? circle(color: primary, child: number('2', Colors.white))
            : circle(color: Tw.slate100, border: Tw.slate200, child: number('2', Tw.slate400));

    final Widget step3;
    if (currentStep == 3 && resultStatus == 'success') {
      step3 = circle(color: Tw.emerald500, child: check);
    } else if (currentStep == 3 && resultStatus == 'failed') {
      step3 = circle(color: Tw.rose500, child: cross);
    } else {
      step3 = circle(color: Tw.slate100, border: Tw.slate200, child: number('3', Tw.slate400));
    }

    Widget row(bool withLines) => Row(
          mainAxisSize: withLines ? MainAxisSize.max : MainAxisSize.min,
          children: [
            circle(color: Tw.emerald500, child: check),
            gap,
            label('Plan Selected', false),
            gap,
            line(currentStep >= 2 ? Tw.emerald500.withValues(alpha: 0.6) : Tw.slate200, withLines),
            gap,
            step2,
            gap,
            label('Review & Pay', currentStep >= 2),
            gap,
            line(
                currentStep >= 3
                    ? (resultStatus == 'success'
                        ? Tw.emerald500.withValues(alpha: 0.6)
                        : Tw.rose400.withValues(alpha: 0.6))
                    : Tw.slate200,
                withLines),
            gap,
            step3,
            gap,
            label('Confirmed', currentStep == 3),
          ],
        );

    // Too narrow for the nowrap labels: the flex-1 lines collapse (as on the
    // web) and the row is scaled down instead of overflowing.
    Widget scaled() => FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: row(false));
    if (compact) return scaled();
    return LayoutBuilder(builder: (context, c) => c.maxWidth >= 400 ? row(true) : scaled());
  }
}

/// A plain rounded button (`px-* py-* rounded-xl font-semibold text-sm
/// flex items-center gap-2 active:scale-95`) used by the views and dialogs.
class FlatPayButton extends StatefulWidget {
  const FlatPayButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.background,
    required this.foreground,
    this.hoverBackground,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
    this.weight = FontWeight.w600,
    this.fontSize = 14,
    this.expand = false,
    this.shadow = false,
    this.radius = SpRadius.xl,
    this.pressScale = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Color background;
  final Color foreground;
  final Color? hoverBackground;
  final IconData? icon;
  final EdgeInsets padding;
  final FontWeight weight;
  final double fontSize;
  final bool expand;

  /// `shadow-md`
  final bool shadow;

  /// `rounded-xl` (20 in this theme).
  final double radius;

  /// `active:scale-95`
  final bool pressScale;

  @override
  State<FlatPayButton> createState() => _FlatPayButtonState();
}

class _FlatPayButtonState extends State<FlatPayButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final row = Row(
      mainAxisSize: w.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (w.icon != null) ...[
          Icon(w.icon, size: w.fontSize, color: w.foreground),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(w.label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontSize: w.fontSize, height: spLeading(w.fontSize), fontWeight: w.weight, color: w.foreground)),
        ),
      ],
    );
    return MouseRegion(
      cursor: w.onPressed != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: w.onPressed,
        child: AnimatedScale(
          scale: _down && w.pressScale ? 0.95 : 1,
          duration: const Duration(milliseconds: 120),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: w.padding,
            decoration: BoxDecoration(
              color: _hover && w.hoverBackground != null ? w.hoverBackground : w.background,
              borderRadius: BorderRadius.circular(w.radius),
              boxShadow: w.shadow ? AppShadows.md : null,
            ),
            child: row,
          ),
        ),
      ),
    );
  }
}

/// `min-h-screen flex flex-col items-center justify-center` — centred in the
/// available height, scrollable when taller.
class CenteredScroll extends StatelessWidget {
  const CenteredScroll({super.key, required this.child, this.padding = EdgeInsets.zero});
  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          padding: padding,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: (c.maxHeight - padding.vertical).clamp(0, double.infinity)),
            child: Center(child: child),
          ),
        ),
      );
}

/// `text-xs` / `text-sm` underlined text button (`underline
/// underline-offset-4`), e.g. "Cancel & go back" and "Reload".
class UnderlineTextButton extends StatefulWidget {
  const UnderlineTextButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.color,
    this.hoverColor,
    this.icon,
    this.fontSize = 14,
    this.weight = FontWeight.w400,
  });

  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color? hoverColor;
  final IconData? icon;
  final double fontSize;
  final FontWeight weight;

  @override
  State<UnderlineTextButton> createState() => _UnderlineTextButtonState();
}

class _UnderlineTextButtonState extends State<UnderlineTextButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final color = _hover && w.hoverColor != null ? w.hoverColor! : w.color;
    final style = TextStyle(
      fontSize: w.fontSize,
      height: spLeading(w.fontSize),
      fontWeight: w.weight,
      color: color,
      decoration: TextDecoration.underline,
      decorationColor: color,
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: w.onTap,
        child: Text.rich(
          TextSpan(children: [
            if (w.icon != null) ...[
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(w.icon, size: w.fontSize, color: color),
              ),
              const TextSpan(text: ' '),
            ],
            TextSpan(text: w.label),
          ]),
          style: style,
        ),
      ),
    );
  }
}
