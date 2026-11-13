import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// shadcn `<Button variant size>` (`src/components/ui/button/index.ts`).
enum AppButtonVariant { primary, destructive, outline, secondary, ghost, link }

enum AppButtonSize {
  /// `h-9 px-4`
  normal,

  /// `h-8 px-3 gap-1.5`
  sm,

  /// `h-10 px-6`
  lg,

  /// `size-9` square
  icon,
}

/// shadcn `<Button>`: `rounded-md text-sm font-medium`, `shadow-xs` (except
/// ghost/link), the variant's hover colours, `focus-visible` ring
/// (`ring-[3px] ring-ring/50`) and `disabled:opacity-50`.
///
/// Hover colours follow the web exactly, including its quirks: outline and
/// ghost buttons turn `bg-accent` (#f49148) on hover, and a colour override
/// such as `class="bg-red-600"` keeps the variant's hover
/// (`hover:bg-primary/90`) unless the page also sets a `hover:bg-…` class —
/// pass [hoverBackgroundColor] for that.
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.normal,
    this.loading = false,
    this.loadingLabel,
    this.expand = false,
    this.backgroundColor,
    this.foregroundColor,
    this.tooltip,
    this.hoverBackgroundColor,
    this.hoverForegroundColor,
    this.borderColor,
    this.radius,
    this.padding,
    this.height,
    this.fontSize,
    this.fontWeight,
    this.shadow,
    this.iconSize,
  }) : assert(label != null || child != null || icon != null);

  final VoidCallback? onPressed;
  final String? label;
  final Widget? child;
  final IconData? icon;
  final AppButtonVariant variant;
  final AppButtonSize size;

  /// Shows the `Loader2` spinner and disables the button.
  final bool loading;

  /// Text shown while [loading] (e.g. "Saving..."); defaults to [label].
  final String? loadingLabel;

  /// `w-full`
  final bool expand;

  /// Overrides for one-off colours (`class="bg-red-600 text-white"`).
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? tooltip;

  /// `hover:bg-…` / `hover:text-…` from the page's class (defaults to the
  /// variant's hover colours).
  final Color? hoverBackgroundColor;
  final Color? hoverForegroundColor;

  /// `border-…` override (adds a 1px border to variants without one).
  final Color? borderColor;

  /// `rounded-…` override (default `rounded-md` = 14).
  final double? radius;

  /// `px-…` / `py-…` override.
  final EdgeInsetsGeometry? padding;

  /// `h-…` override.
  final double? height;

  /// `text-…` overrides (default `text-sm font-medium`).
  final double? fontSize;
  final FontWeight? fontWeight;

  /// `shadow-…` override (`[]` for `shadow-none`).
  final List<BoxShadow>? shadow;

  /// Icon size (default 16 = `size-4`).
  final double? iconSize;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  final _states = WidgetStatesController();

  @override
  void dispose() {
    _states.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final dark = context.isDark;
    final scheme = context.colors;
    final destructive = context.destructiveColor;
    final input = context.inputColor;
    final ringBase = w.variant == AppButtonVariant.destructive ? destructive : context.ringColor;
    final ring = w.variant == AppButtonVariant.destructive
        ? ringBase.withValues(alpha: dark ? 0.4 : 0.2)
        : ringBase.withValues(alpha: 0.5);

    // Base / hover colours per variant (button/index.ts).
    Color bg;
    Color fg;
    Color hoverBg;
    Color? hoverFg;
    Color? border;
    var shadow = AppShadows.xs;
    switch (w.variant) {
      case AppButtonVariant.primary:
        bg = scheme.primary;
        fg = scheme.onPrimary;
        hoverBg = scheme.primary.withValues(alpha: 0.9);
      case AppButtonVariant.destructive:
        bg = dark ? destructive.withValues(alpha: 0.6) : destructive;
        fg = Colors.white;
        hoverBg = destructive.withValues(alpha: 0.9);
      case AppButtonVariant.outline:
        bg = dark ? input.withValues(alpha: 0.3) : AppColors.background;
        fg = scheme.onSurface;
        border = dark ? input : AppColors.border;
        hoverBg = dark ? input.withValues(alpha: 0.5) : AppColors.accent;
        hoverFg = AppColors.accentForeground;
      case AppButtonVariant.secondary:
        bg = scheme.secondary;
        fg = AppColors.secondaryForeground;
        hoverBg = scheme.secondary.withValues(alpha: 0.8);
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = scheme.onSurface;
        hoverBg = dark ? AppColors.accent.withValues(alpha: 0.5) : AppColors.accent;
        hoverFg = AppColors.accentForeground;
        shadow = const [];
      case AppButtonVariant.link:
        bg = Colors.transparent;
        fg = scheme.primary;
        hoverBg = Colors.transparent;
        shadow = const [];
    }
    bg = w.backgroundColor ?? bg;
    fg = w.foregroundColor ?? fg;
    hoverBg = w.hoverBackgroundColor ?? hoverBg;
    final hoverText = w.hoverForegroundColor ?? hoverFg ?? fg;
    final borderC = w.borderColor ?? border;
    final shadowC = w.shadow ?? shadow;

    final (defHeight, defPad, gap) = switch (w.size) {
      AppButtonSize.normal => (36.0, 16.0, 8.0),
      AppButtonSize.sm => (32.0, 12.0, 6.0),
      AppButtonSize.lg => (40.0, 24.0, 8.0),
      AppButtonSize.icon => (36.0, 0.0, 8.0),
    };
    final height = w.height ?? defHeight;
    final radius = w.radius ?? AppTheme.radiusMd;
    final enabled = w.onPressed != null && !w.loading;
    final text = w.loading ? (w.loadingLabel ?? w.label) : w.label;

    Widget content(Color color, bool hovered) {
      final iconSize = w.iconSize ?? 16;
      return Row(
        mainAxisSize: w.expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (w.loading)
            AppSpinner(size: iconSize, color: color)
          else if (w.icon != null)
            Icon(w.icon, size: iconSize, color: color),
          if ((w.loading || w.icon != null) && (text != null || w.child != null)) SizedBox(width: gap),
          if (text != null)
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: w.fontSize ?? 14,
                  fontWeight: w.fontWeight ?? FontWeight.w500,
                  color: color,
                  // `underline-offset-4 hover:underline`
                  decoration: w.variant == AppButtonVariant.link && hovered ? TextDecoration.underline : null,
                  decorationColor: color,
                ),
              ),
            )
          else if (w.child != null)
            Flexible(
              child: DefaultTextStyle.merge(
                style: TextStyle(fontSize: w.fontSize ?? 14, fontWeight: w.fontWeight ?? FontWeight.w500, color: color),
                child: IconTheme.merge(data: IconThemeData(color: color, size: iconSize), child: w.child!),
              ),
            ),
        ],
      );
    }

    Widget button = ValueListenableBuilder<Set<WidgetState>>(
      valueListenable: _states,
      builder: (context, states, _) {
        final hovered = enabled && (states.contains(WidgetState.hovered) || states.contains(WidgetState.pressed));
        final focused = enabled &&
            states.contains(WidgetState.focused) &&
            FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
        final color = hovered ? hoverText : fg;
        // `focus-visible:border-ring` only shows on variants with a border.
        final side = borderC == null ? BorderSide.none : BorderSide(color: focused ? ringBase : borderC);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            boxShadow: [
              ...shadowC,
              if (focused) BoxShadow(color: ring, spreadRadius: 3),
            ],
          ),
          child: TextButton(
            onPressed: enabled ? w.onPressed : null,
            statesController: _states,
            style: ButtonStyle(
              minimumSize: WidgetStatePropertyAll(Size(w.size == AppButtonSize.icon ? height : 0, height)),
              maximumSize: WidgetStatePropertyAll(Size(double.infinity, height)),
              fixedSize: w.size == AppButtonSize.icon ? WidgetStatePropertyAll(Size(height, height)) : null,
              padding: WidgetStatePropertyAll(w.padding ?? EdgeInsets.symmetric(horizontal: defPad)),
              backgroundColor: WidgetStatePropertyAll(hovered ? hoverBg : bg),
              foregroundColor: WidgetStatePropertyAll(color),
              overlayColor: const WidgetStatePropertyAll(Colors.transparent),
              splashFactory: NoSplash.splashFactory,
              side: WidgetStatePropertyAll(side),
              shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius))),
              elevation: const WidgetStatePropertyAll(0),
              animationDuration: const Duration(milliseconds: 150),
              mouseCursor: WidgetStatePropertyAll(enabled ? SystemMouseCursors.click : SystemMouseCursors.basic),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.standard,
            ),
            child: content(color, hovered),
          ),
        );
      },
    );
    // `disabled:opacity-50` (buttons are disabled while loading too).
    if (!enabled) button = Opacity(opacity: 0.5, child: button);
    if (w.expand) button = SizedBox(width: double.infinity, child: button);
    if (w.tooltip != null) button = Tooltip(message: w.tooltip!, child: button);
    return button;
  }
}

/// lucide `<Loader2 class="animate-spin">`: a 288° arc spinning once a second.
class AppSpinner extends StatefulWidget {
  const AppSpinner({super.key, this.size = 16, this.color, this.strokeWidth});
  final double size;
  final Color? color;

  /// Defaults to lucide's 2px-at-24px stroke, scaled to [size].
  final double? strokeWidth;

  @override
  State<AppSpinner> createState() => _AppSpinnerState();
}

class _AppSpinnerState extends State<AppSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? IconTheme.of(context).color ?? context.colors.onSurface;
    return RotationTransition(
      turns: _c,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _ArcPainter(color, widget.strokeWidth ?? widget.size / 12),
      ),
    );
  }
}

class _ArcPainter extends CustomPainter {
  _ArcPainter(this.color, this.stroke);
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    // lucide loader-circle: `M21 12a9 9 0 1 1-6.219-8.56` in a 24 box.
    final r = size.width * 9 / 24;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: r);
    canvas.drawArc(
      rect,
      0,
      288 * math.pi / 180,
      false,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_ArcPainter old) => old.color != color || old.stroke != stroke;
}
