import '../../widgets/content_image.dart';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/form_fields.dart' show AppSelectItem, appMenuItemStyle;
import '../../widgets/lucide_icon.dart';

/// `font-[Nunito,sans-serif]` text (library.vue / activitylibrary.vue roots)
/// with the real weight face: google_fonts registers one family per weight,
/// so a weight merged onto an inherited `GoogleFonts.nunito()` style would be
/// a synthetic bold of the regular face.
TextStyle libNunito({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? height,
  double? letterSpacing,
  List<Shadow>? shadows,
}) =>
    GoogleFonts.nunito(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      shadows: shadows,
    );

/// Tailwind's line height for a `text-*` size (`text-xs` 16px,
/// `text-sm` 20px, `text-base` 24px, `text-lg`/`text-xl` 28px, …) as a
/// Flutter height factor.
double twLeading(double fontSize) => switch (fontSize) {
      12.0 => 16 / 12,
      14.0 => 20 / 14,
      16.0 => 24 / 16,
      18.0 => 28 / 18,
      20.0 => 28 / 20,
      24.0 => 32 / 24,
      30.0 => 36 / 30,
      36.0 => 40 / 36,
      _ => 1.5,
    };

/// Colours used by the library templates that are not in [Tw].
class LibColors {
  LibColors._();

  /// `--primary` in style.css (light `#4f46e5`, dark `#9db1d4`).
  static Color primary(BuildContext context) =>
      context.isDark ? AppColors.darkPrimary : AppColors.primary;

  /// `--accent` (`#f49148` in both themes — the later `.dark` value wins).
  static const accent = Color(0xFFF49148);

  static const gray950 = Color(0xFF030712);
  static const blue900 = Color(0xFF1E3A8A);

  /// `bg-[#f5f6f8]` (newlibrarypage).
  static const pageLight = Color(0xFFF5F6F8);

  /// The Virtual Labs green (`#1d9e75` / hover `#0f6e56`).
  static const green = Color(0xFF1D9E75);
  static const greenDark = Color(0xFF0F6E56);
  static const greenTint = Color(0xFFE1F5EE);
  static const greenLight = Color(0xFF5DCAA5);
  static const greenPanel = Color(0xFFF0FAF6);

  /// `--sidebar-bg` / `--navbar-bg` / `--card-border` (dark theme).
  static const sidebarBg = Color(0xFF161E36);
  static const navbarBg = Color(0xFF0A0F1F);
  static const cardBorder = Color(0xFF2E3B5E);
  static const sidebarText = Color(0xFF95A3FF);
  static const darkSidebarBorder = Color(0xFF303540);
}

/// shadcn `<Select>` with a caller-styled trigger (the library pages style
/// every trigger differently).
///
/// Trigger: the caller's [decoration] (swapped for [hoverDecoration] while
/// hovered), text and padding; the kit's `ChevronDown size-4 opacity-50` in
/// `text-muted-foreground`; `disabled:opacity-50`. Pass [height] for the
/// kit's fixed `data-[size=default]:h-9` (36), which beats a page's `py-…`.
///
/// Menu (`<SelectContent position="popper">`): `bg-popover border rounded-md
/// p-1 shadow-md`, 4px below the trigger and at least as wide; items
/// `rounded-sm py-1.5 pl-2 pr-8 text-sm` turn `bg-accent` when highlighted,
/// with a check on the selected one; disabled items `opacity-50`.
class LibrarySelect<T> extends StatefulWidget {
  const LibrarySelect({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    this.placeholder = 'Select',
    this.enabled = true,
    this.decoration,
    this.hoverDecoration,
    this.textStyle,
    this.placeholderColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    this.minHeight = 40,
    this.height,
    this.menuMaxHeight = double.infinity,
    this.menuBackgroundColor,
    this.menuBorderColor,
    this.menuRadius = AppTheme.radiusMd,
    this.menuElevation = 2,
    this.disabledItemColor,
  });

  final T? value;
  final List<AppSelectItem<T>> items;
  final ValueChanged<T>? onChanged;
  final String placeholder;
  final bool enabled;
  final BoxDecoration? decoration;

  /// `hover:bg-…` / `hover:shadow-…` of the trigger.
  final BoxDecoration? hoverDecoration;
  final TextStyle? textStyle;
  final Color? placeholderColor;
  final EdgeInsetsGeometry padding;
  final double minHeight;

  /// Fixed trigger height (the kit's `h-9`); [padding] then only pads the sides.
  final double? height;

  /// The web limits the list only by the space left on screen.
  final double menuMaxHeight;

  /// `<SelectContent class="bg-… border-… rounded-… shadow-…">` overrides.
  final Color? menuBackgroundColor;
  final Color? menuBorderColor;
  final double menuRadius;
  final double menuElevation;

  /// `<SelectItem disabled class="text-…">`.
  final Color? disabledItemColor;

  @override
  State<LibrarySelect<T>> createState() => _LibrarySelectState<T>();
}

class _LibrarySelectState<T> extends State<LibrarySelect<T>> {
  final _menu = MenuController();
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final muted = context.mutedFgColor;
    AppSelectItem<T>? selected;
    for (final it in widget.items) {
      if (it.value == widget.value) selected = it;
    }
    final style = (widget.textStyle ?? const TextStyle(fontSize: 14));
    final enabled = widget.enabled && widget.onChanged != null;
    final decoration = _hover && enabled && widget.hoverDecoration != null
        ? widget.hoverDecoration
        : widget.decoration;

    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth.isFinite ? c.maxWidth : 220.0;
      final screenW = MediaQuery.sizeOf(context).width;
      // `min-w-[8rem]`, at least the trigger's width.
      final minW = math.max(128.0, width);
      final maxW = math.max(minW, screenW - 16);
      return MenuAnchor(
        controller: _menu,
        crossAxisUnconstrained: false,
        alignmentOffset: const Offset(0, 4),
        style: MenuStyle(
          minimumSize: WidgetStatePropertyAll(Size(minW, 0)),
          maximumSize: WidgetStatePropertyAll(Size(maxW, widget.menuMaxHeight)),
          backgroundColor: WidgetStatePropertyAll(widget.menuBackgroundColor ?? context.popoverColor),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(widget.menuElevation),
          shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.5)),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.menuRadius),
            side: BorderSide(color: widget.menuBorderColor ?? context.borderColor),
          )),
        ),
        menuChildren: [
          for (final it in widget.items)
            MenuItemButton(
              onPressed: it.enabled ? () => widget.onChanged?.call(it.value) : null,
              style: appMenuItemStyle(context, foreground: it.enabled ? null : widget.disabledItemColor),
              overflowAxis: Axis.vertical,
              child: Opacity(
                opacity: it.enabled ? 1 : 0.5,
                child: Row(children: [
                  Expanded(child: Text(it.label)),
                  const SizedBox(width: 10),
                  // `absolute right-2 size-3.5` check indicator.
                  SizedBox.square(
                    dimension: 14,
                    child: it.value == widget.value
                        ? OverflowBox(
                            maxWidth: 16,
                            maxHeight: 16,
                            child: LucideIcon(Lucide.check, size: 16, color: muted),
                          )
                        : null,
                  ),
                ]),
              ),
            ),
        ],
        builder: (context, controller, _) {
          final pad = widget.padding.resolve(TextDirection.ltr);
          return Opacity(
            opacity: enabled ? 1 : 0.5,
            child: MouseRegion(
              cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
              onEnter: (_) => setState(() => _hover = true),
              onExit: (_) => setState(() => _hover = false),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: enabled ? () => controller.isOpen ? controller.close() : controller.open() : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: widget.height,
                  constraints: widget.height == null ? BoxConstraints(minHeight: widget.minHeight) : null,
                  padding: widget.height == null ? pad : EdgeInsets.only(left: pad.left, right: pad.right),
                  decoration: decoration,
                  child: Row(children: [
                    Expanded(
                      child: Text(
                        selected?.label ?? widget.placeholder,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: selected == null
                            ? style.copyWith(color: widget.placeholderColor ?? muted)
                            : style,
                      ),
                    ),
                    const SizedBox(width: 8),
                    LucideIcon(Lucide.chevronDown, size: 16, color: muted.withValues(alpha: 0.5)),
                  ]),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}

/// `hover:-translate-y-1` cards: lifts by [lift] px while hovered and hands
/// the hover state to [builder] (border / shadow changes).
class HoverLift extends StatefulWidget {
  const HoverLift({
    super.key,
    required this.builder,
    this.onTap,
    this.lift = 4,
    this.duration = const Duration(milliseconds: 250),
  });

  final Widget Function(BuildContext context, bool hovered) builder;
  final VoidCallback? onTap;
  final double lift;

  /// `duration-…` of the lift.
  final Duration duration;

  @override
  State<HoverLift> createState() => _HoverLiftState();
}

class _HoverLiftState extends State<HoverLift> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: widget.duration,
          curve: const Cubic(0.4, 0, 0.2, 1),
          transform: Matrix4.translationValues(0, _hover ? -widget.lift : 0, 0),
          child: widget.builder(context, _hover),
        ),
      ),
    );
  }
}

/// `<img :src>` with a fallback when the URL is empty or fails to load.
class LibImage extends StatelessWidget {
  const LibImage(this.url, {super.key, this.fit = BoxFit.cover, required this.fallback});

  final String? url;
  final BoxFit fit;
  final Widget fallback;

  @override
  Widget build(BuildContext context) {
    final u = url;
    if (u == null || u.isEmpty) return fallback;
    return contentImage(
      u,
      fit: fit,
      width: double.infinity,
      height: double.infinity,
      errorBuilder: (_, _, _) => fallback,
    );
  }
}

/// `animate-pulse` (opacity 1 → 0.5 → 1, 2s).
class Pulse extends StatefulWidget {
  const Pulse({super.key, required this.child});
  final Widget child;

  @override
  State<Pulse> createState() => _PulseState();
}

class _PulseState extends State<Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0.5)
            .animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
        child: widget.child,
      );
}

/// `.brain-loader` from style.css: three counter-rotating partial rings and
/// a pulsing dot.
class BrainLoader extends StatefulWidget {
  const BrainLoader({super.key});

  @override
  State<BrainLoader> createState() => _BrainLoaderState();
}

class _BrainLoaderState extends State<BrainLoader> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        width: 72,
        height: 72,
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, _) => CustomPaint(painter: _BrainPainter(_c.value)),
        ),
      );
}

class _BrainPainter extends CustomPainter {
  _BrainPainter(this.t);
  final double t;

  /// ease-in-out 0 → 1 → 0 over the cycle, shifted by [delay] (fraction).
  double _wave(double delay) {
    final p = (t - delay) % 1.0;
    final half = p < 0.5 ? p * 2 : (1 - p) * 2;
    return Curves.easeInOut.transform(half.clamp(0.0, 1.0));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    void ring(double diameter, Color color, double startDeg, double delay) {
      final w = _wave(delay);
      final angle = w * math.pi;
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = color.withValues(alpha: 0.4 + 0.6 * w);
      final r = diameter / 2 - 1;
      // Two coloured border sides = half the circle.
      canvas.drawArc(Rect.fromCircle(center: c, radius: r),
          startDeg * math.pi / 180 + angle, math.pi, false, paint);
    }

    // br1: top + right borders, br2: top + left, br3: bottom + right.
    // (br2's `animation-direction: reverse` replays the symmetric 0 → 180 → 0
    // keyframes unchanged, so it turns the same way.)
    ring(72, LibColors.accent, -135, 0);
    ring(52, const Color(0xFF1D9E75), 135, 0.075);
    ring(34, const Color(0xFFD85A30), -45, 0.15);

    final d = _wave(0);
    canvas.drawCircle(c, 5 * (0.6 + 0.8 * d),
        Paint()..color = LibColors.accent.withValues(alpha: 0.4 + 0.6 * d));
  }

  @override
  bool shouldRepaint(covariant _BrainPainter old) => old.t != t;
}

/// `.pattern-overlay`: white 2px dots every 30px at 10% (×0.5 opacity).
class DotPatternPainter extends CustomPainter {
  const DotPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    for (double y = 15; y < size.height; y += 30) {
      for (double x = 15; x < size.width; x += 30) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant DotPatternPainter oldDelegate) => false;
}

/// A soft radial glow (the web's blurred `radial-gradient` blobs).
class GlowBlob extends StatelessWidget {
  const GlowBlob({super.key, required this.size, required this.color, this.opacity = 1});

  final double size;
  final Color color;
  final double opacity;

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [
              color.withValues(alpha: color.a * opacity),
              color.withValues(alpha: 0),
            ]),
          ),
        ),
      );
}

/// CSS grid `grid-cols-N gap-X`: rows of equal-width cells; cells of a row
/// share the row height when [stretch] is set.
class LibGrid extends StatelessWidget {
  const LibGrid({
    super.key,
    required this.columns,
    required this.gap,
    required this.children,
    this.stretch = false,
  });

  final int columns;
  final double gap;
  final List<Widget> children;
  final bool stretch;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final cells = <Widget>[];
      for (var j = 0; j < columns; j++) {
        if (j > 0) cells.add(SizedBox(width: gap));
        final idx = i + j;
        cells.add(Expanded(child: idx < children.length ? children[idx] : const SizedBox()));
      }
      Widget row = Row(
        crossAxisAlignment: stretch ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
        children: cells,
      );
      if (stretch) row = IntrinsicHeight(child: row);
      if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
      rows.add(row);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

/// `grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4`.
int libGridColumns(BuildContext context) => context.isXl
    ? 4
    : context.isLg
        ? 3
        : context.isSm
            ? 2
            : 1;

/// `w-5 h-5 border-2 border-[color] border-t-transparent rounded-full
/// animate-spin`: a three-quarter ring turning once a second.
class RingSpinner extends StatefulWidget {
  const RingSpinner({super.key, this.size = 20, this.stroke = 2, required this.color});

  final double size;
  final double stroke;
  final Color color;

  @override
  State<RingSpinner> createState() => _RingSpinnerState();
}

class _RingSpinnerState extends State<RingSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
        turns: _c,
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _RingPainter(widget.color, widget.stroke),
        ),
      );
}

class _RingPainter extends CustomPainter {
  const _RingPainter(this.color, this.stroke);
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    // Every border side but the (transparent) top one.
    canvas.drawArc(
      rect,
      -math.pi / 4,
      math.pi * 1.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.color != color || old.stroke != stroke;
}

/// The library "glass" page container (`bg-white/75 dark:bg-slate-900/80
/// border-2 border-white/40 dark:border-slate-800/80 rounded-[32px]
/// shadow-[0_20px_50px_-12px_rgba(99,102,241,0.15)]`). The backdrop blur is
/// left out (it would re-blur the whole page on every frame).
BoxDecoration libGlassContainer(BuildContext context) {
  final dark = context.isDark;
  return BoxDecoration(
    color: dark ? Tw.slate900.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.75),
    borderRadius: BorderRadius.circular(32),
    border: Border.all(
      width: 2,
      color: dark ? Tw.slate800.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.4),
    ),
    boxShadow: [cssShadow(0, 20, 50, -12, const Color(0x266366F1))],
  );
}

/// The indigo card shadow used by the library cards (normal / hovered):
/// `shadow-[0_0_0_1px_rgba(99,102,241,0.08),_0_10px_30px_-10px_rgba(99,102,241,0.08)]`
/// `hover:shadow-[0_0_0_2px_rgba(99,102,241,0.2),_0_20px_40px_-12px_rgba(99,102,241,0.18)]`
/// and the `dark:` variants.
List<BoxShadow> libCardShadow(bool dark, bool hover) => hover
    ? [
        cssShadow(0, 0, 0, 2, dark ? const Color(0x4D818CF8) : const Color(0x336366F1)),
        cssShadow(0, 20, 40, -12, dark ? const Color(0x80000000) : const Color(0x2E6366F1)),
      ]
    : [
        cssShadow(0, 0, 0, 1, dark ? const Color(0x26818CF8) : const Color(0x146366F1)),
        cssShadow(0, 10, 30, -10, dark ? const Color(0x4D000000) : const Color(0x146366F1)),
      ];

/// `v-html` chapter reference text as a WebView document styled like the
/// page around it: the web injects it inline, so Tailwind's preflight
/// applies (no default margins, headings at the body size, `ul`/`ol` get
/// the global `list-style` + `margin-left: 2rem`); there is no typography
/// plugin, so `prose` does nothing.
String libInlineHtmlPage(
  String html, {
  required bool dark,
  required Color color,
  required Color background,
  required double padding,
  String fontFamily = 'sans-serif',
}) {
  String css(Color c) =>
      'rgba(${(c.r * 255).round()},${(c.g * 255).round()},${(c.b * 255).round()},${c.a.toStringAsFixed(3)})';
  // style.css: `thead th { background: var(--primary); color: var(--primary-foreground); … }`
  final th = dark
      ? 'background-color:#9db1d4;color:#1f2430;border-bottom:1px solid #303540'
      : 'background-color:#4f46e5;color:#ffffff;border-bottom:1px solid #e1e3e9';
  return '<!doctype html><html><head><meta charset="utf-8">'
      '<style>thead th{$th;padding:.5rem 1rem}</style>'
      '<meta name="viewport" content="width=device-width, initial-scale=1"><style>'
      '*,::before,::after{box-sizing:border-box;margin:0;padding:0;border:0 solid}'
      'html,body{background:${css(background)};}'
      'body{padding:${padding}px;font-family:$fontFamily;font-size:16px;line-height:1.5;color:${css(color)};}'
      'h1,h2,h3,h4,h5,h6{font-size:inherit;font-weight:inherit}'
      'a{color:inherit;text-decoration:inherit}'
      'img,video,iframe{display:block;max-width:100%;height:auto}'
      'table{border-collapse:collapse}'
      'ul{list-style-type:disc;margin-left:2rem}ol{list-style-type:decimal;margin-left:2rem}'
      '</style></head><body>$html</body></html>';
}
