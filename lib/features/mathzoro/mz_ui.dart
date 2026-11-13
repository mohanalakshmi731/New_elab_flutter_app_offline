import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/utils/json.dart';

/// Tailwind colours used by the MathZoro screens that are not part of the
/// shared `Tw` palette (app_colors.dart).
class Mz {
  Mz._();

  static const cyan50 = Color(0xFFECFEFF);
  static const cyan200 = Color(0xFFA5F3FC);
  static const cyan400 = Color(0xFF22D3EE);
  static const cyan500 = Color(0xFF06B6D4);
  static const cyan600 = Color(0xFF0891B2);
  static const amber300 = Color(0xFFFCD34D);
  static const green400 = Color(0xFF4ADE80);
  static const rose400 = Color(0xFFFB7185);
  static const gray950 = Color(0xFF030712);
  static const yellow50 = Color(0xFFFEFCE8);
  static const yellow200 = Color(0xFFFEF08A);
  static const yellow600 = Color(0xFFCA8A04);
  static const sky400 = Color(0xFF38BDF8);
  static const sky600 = Color(0xFF0284C7);
  static const indigo100 = Color(0xFFE0E7FF);

  /// `bg-[rgba(38,32,75,0.7)]` — dark card surface of the student dashboard.
  static const darkCard = Color(0xB326204B);

  /// `bg-[rgba(38,32,75,0.97)]` — dark dialog / toast surface.
  static const darkDialog = Color(0xF726204B);

  /// `#ffde3b` — Math Zone accent.
  static const mathYellow = Color(0xFFFFDE3B);

  // shadcn tokens (`src/style.css` `:root` / `.dark`), for popovers & menus.
  /// `bg-popover`.
  static Color popover(bool dark) => dark ? const Color(0xFF2A2F3C) : Colors.white;

  /// `text-popover-foreground`.
  static Color popoverForeground(bool dark) =>
      dark ? const Color(0xFFE1E3E9) : const Color(0xFF1F2430);

  /// `border-border` / `border-input`.
  static Color border(bool dark) => dark ? const Color(0xFF303540) : const Color(0xFFE1E3E9);

  /// `bg-accent` (`focus:bg-accent` on menu items) — the same orange in both modes.
  static const accent = Color(0xFFF49148);

  /// `text-accent-foreground`.
  static const accentForeground = Color(0xFF1F2430);

  /// `bg-primary` (tooltips).
  static Color primary(bool dark) => dark ? const Color(0xFF9DB1D4) : const Color(0xFF4F46E5);

  /// `text-primary-foreground`.
  static Color primaryForeground(bool dark) => dark ? const Color(0xFF1F2430) : Colors.white;

  /// `text-muted-foreground`.
  static Color mutedForeground(bool dark) =>
      dark ? const Color(0xFF9DB1D4) : const Color(0xFF1F2430);
}

/// The web theme's box shadows (`--shadow-*` in `src/style.css`, used by
/// Tailwind's `shadow-*` utilities) — much lighter than Tailwind's defaults.
class MzShadow {
  MzShadow._();

  static const _c10 = Color(0x1A000000);

  /// `shadow-xs` / `shadow-2xs`.
  static const xs = [BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1))];

  /// `shadow-sm` / `shadow`.
  static const sm = [
    BoxShadow(color: _c10, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _c10, blurRadius: 2, spreadRadius: -1, offset: Offset(0, 1)),
  ];

  /// `shadow-md`.
  static const md = [
    BoxShadow(color: _c10, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _c10, blurRadius: 4, spreadRadius: -1, offset: Offset(0, 2)),
  ];

  /// `shadow-lg`.
  static const lg = [
    BoxShadow(color: _c10, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _c10, blurRadius: 6, spreadRadius: -1, offset: Offset(0, 4)),
  ];

  /// `shadow-xl`.
  static const xl = [
    BoxShadow(color: _c10, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _c10, blurRadius: 10, spreadRadius: -1, offset: Offset(0, 8)),
  ];

  /// `shadow-2xl`.
  static const xl2 = [BoxShadow(color: Color(0x40000000), blurRadius: 3, offset: Offset(0, 1))];
}

/// CSS `linear-gradient()` painted the way browsers do. Flutter's
/// [LinearGradient] runs between two box-relative alignments, so on a
/// non-square box its colour bands are not at the CSS angle; this keeps them.
///
/// * [angle] — `linear-gradient(135deg, …)` (0 = to top, 90 = to right).
/// * [corner] — keyword directions (`to bottom right`, Tailwind
///   `bg-gradient-to-br` / `bg-linear-to-br`): `Alignment.bottomRight`,
///   `Alignment.centerRight` (`to right`)… Overrides [angle].
/// * [sizeX] / [positionX] — `background-size: 200% 100%` and
///   `background-position: X% 0%` (0 = left, 1 = right).
class CssLinearGradient extends LinearGradient {
  const CssLinearGradient({
    this.angle = 180,
    this.corner,
    required super.colors,
    super.stops,
    this.sizeX = 1,
    this.positionX = 0,
  });

  final double angle;
  final Alignment? corner;
  final double sizeX;
  final double positionX;

  @override
  Shader createShader(Rect rect, {TextDirection? textDirection}) {
    var r = rect;
    if (sizeX != 1) {
      final w = rect.width * sizeX;
      r = Rect.fromLTWH(rect.left + (rect.width - w) * positionX, rect.top, w, rect.height);
    }
    final w = r.width, h = r.height;
    double dx, dy;
    final c = corner;
    if (c != null) {
      // Perpendicular to the line joining the two neighbouring corners.
      dx = c.x.sign * h;
      dy = c.y.sign * w;
      final n = math.sqrt(dx * dx + dy * dy);
      if (n == 0) {
        dx = 0;
        dy = 1;
      } else {
        dx /= n;
        dy /= n;
      }
    } else {
      final a = angle * math.pi / 180;
      dx = math.sin(a);
      dy = -math.cos(a);
    }
    final half = (w * dx.abs() + h * dy.abs()) / 2;
    final d = Offset(dx, dy) * half;
    final s = stops ??
        [for (var i = 0; i < colors.length; i++) colors.length == 1 ? 0.0 : i / (colors.length - 1)];
    return ui.Gradient.linear(r.center - d, r.center + d, colors, s, tileMode);
  }

  static CssLinearGradient? _lerp(CssLinearGradient a, CssLinearGradient b, double t) {
    if (a.angle != b.angle ||
        a.corner != b.corner ||
        a.colors.length != b.colors.length ||
        (a.stops == null) != (b.stops == null)) {
      return null;
    }
    return CssLinearGradient(
      angle: a.angle,
      corner: a.corner,
      colors: [for (var i = 0; i < a.colors.length; i++) Color.lerp(a.colors[i], b.colors[i], t)!],
      stops: a.stops == null
          ? null
          : [for (var i = 0; i < a.stops!.length; i++) ui.lerpDouble(a.stops![i], b.stops![i], t)!],
      sizeX: ui.lerpDouble(a.sizeX, b.sizeX, t)!,
      positionX: ui.lerpDouble(a.positionX, b.positionX, t)!,
    );
  }

  @override
  Gradient? lerpFrom(Gradient? a, double t) =>
      (a is CssLinearGradient ? _lerp(a, this, t) : null) ?? super.lerpFrom(a, t);

  @override
  Gradient? lerpTo(Gradient? b, double t) =>
      (b is CssLinearGradient ? _lerp(this, b, t) : null) ?? super.lerpTo(b, t);

  @override
  CssLinearGradient scale(double factor) => CssLinearGradient(
        angle: angle,
        corner: corner,
        colors: [for (final c in colors) Color.lerp(null, c, factor)!],
        stops: stops,
        sizeX: sizeX,
        positionX: positionX,
      );

  @override
  bool operator ==(Object other) =>
      other is CssLinearGradient &&
      other.angle == angle &&
      other.corner == corner &&
      other.sizeX == sizeX &&
      other.positionX == positionX &&
      super == other;

  @override
  int get hashCode => Object.hash(super.hashCode, angle, corner, sizeX, positionX);
}

/// CSS `saturate(<amount>)` as a colour matrix (backdrop filters).
ColorFilter cssSaturate(double s) => ColorFilter.matrix(<double>[
      0.213 + 0.787 * s, 0.715 - 0.715 * s, 0.072 - 0.072 * s, 0, 0, //
      0.213 - 0.213 * s, 0.715 + 0.285 * s, 0.072 - 0.072 * s, 0, 0, //
      0.213 - 0.213 * s, 0.715 - 0.715 * s, 0.072 + 0.928 * s, 0, 0, //
      0, 0, 0, 1, 0, //
    ]);

/// `backdrop-filter: blur(<blur>px) saturate(<saturate>)`.
ui.ImageFilter cssBackdrop({required double blur, double saturate = 1}) {
  final b = ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur);
  return saturate == 1 ? b : ui.ImageFilter.compose(outer: cssSaturate(saturate), inner: b);
}

// ── JavaScript value semantics used by the ported templates ─────────────────

/// JS `String(v)` / `v?.toString()` — integral doubles print without `.0`.
String? jsStr(dynamic v) {
  if (v == null) return null;
  if (v is double && v.isFinite && v == v.truncateToDouble()) {
    return v.toInt().toString();
  }
  return v.toString();
}

/// `a || b || c || ''` over strings.
String firstNonEmpty(Iterable<String?> values) {
  for (final v in values) {
    if (v != null && v.isNotEmpty) return v;
  }
  return '';
}

/// `{{ value }}` interpolation — `null` renders as an empty string.
String jsDisplay(dynamic v) => jsStr(v) ?? '';

/// Key used for `map[Number(x)]` lookups (JS object keys are strings).
String jsNumKey(dynamic v) {
  if (v is bool) return v ? '1' : '0';
  if (v is String && v.trim().isEmpty) return '0';
  final d = asDouble(v);
  if (d == null || d.isNaN) return 'NaN';
  return jsStr(d)!;
}

/// `Number(x)` as a double (NaN when not numeric).
double jsNumber(dynamic v) {
  if (v is bool) return v ? 1 : 0;
  if (v is String && v.trim().isEmpty) return 0;
  return asDouble(v) ?? double.nan;
}

/// `Math.round(x || 0)` printed like JS (Infinity stays "Infinity").
String jsRoundLabel(double v) {
  if (v.isNaN || v == 0) return '0';
  if (v.isInfinite) return v > 0 ? 'Infinity' : '-Infinity';
  return (v + 0.5).floor().toString();
}

// ── Small shared widgets ────────────────────────────────────────────────────

/// Rebuilds with `hovered == true` while the pointer is over the child
/// (Tailwind `hover:` variants). Shows the click cursor when [onTap] is set.
class HoverBuilder extends StatefulWidget {
  const HoverBuilder({super.key, required this.builder, this.onTap, this.cursor});
  final Widget Function(BuildContext context, bool hovered) builder;
  final VoidCallback? onTap;
  final MouseCursor? cursor;

  @override
  State<HoverBuilder> createState() => _HoverBuilderState();
}

class _HoverBuilderState extends State<HoverBuilder> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final child = widget.builder(context, _hover);
    return MouseRegion(
      cursor: widget.cursor ??
          (widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer),
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: widget.onTap == null
          ? child
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: widget.onTap,
              child: child,
            ),
    );
  }
}

/// `rounded-full border-[3px] border-cyan-400/30 border-t-cyan-400 animate-spin`.
class MzSpinner extends StatelessWidget {
  const MzSpinner({super.key, this.size = 36, this.stroke = 3, this.color = Mz.cyan400});
  final double size;
  final double stroke;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: stroke,
          color: color,
          backgroundColor: color.withValues(alpha: 0.3),
        ),
      );
}

/// A rounded box whose left edge is thicker than the other edges
/// (`border border-l-4 rounded-3xl`). Flutter cannot combine non-uniform
/// borders with a radius, so the left edge is painted as a clipped strip.
class AccentBorderBox extends StatelessWidget {
  const AccentBorderBox({
    super.key,
    required this.child,
    required this.radius,
    required this.borderColor,
    required this.leftColor,
    this.leftWidth = 4,
    this.borderWidth = 1,
    this.color,
    this.boxShadow,
  });

  final Widget child;
  final double radius;
  final Color borderColor;
  final Color leftColor;
  final double leftWidth;
  final double borderWidth;
  final Color? color;
  final List<BoxShadow>? boxShadow;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: boxShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: color ?? Colors.transparent,
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(leftWidth, borderWidth, borderWidth, borderWidth),
                child: child,
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(radius),
                      border: Border.all(color: borderColor, width: borderWidth),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: leftWidth,
                child: IgnorePointer(child: ColoredBox(color: leftColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── shadcn DropdownMenu / Select popovers ───────────────────────────────────

/// Opens a shadcn-style popover menu (`DropdownMenuContent` /
/// `SelectContent`: `bg-popover rounded-md border p-1 shadow-md`) below the
/// widget of [anchorContext]. Near the right edge it grows to the left, i.e.
/// `align="end"`. [height] fixes the height (`h-[40vh]`), [maxHeight] caps it.
Future<T?> showMzMenu<T>(
  BuildContext anchorContext, {
  required List<PopupMenuEntry<T>> items,
  double? width,
  double minWidth = 128,
  double? height,
  double? maxHeight,
}) {
  final dark = Theme.of(anchorContext).brightness == Brightness.dark;
  final button = anchorContext.findRenderObject()! as RenderBox;
  final overlay =
      Navigator.of(anchorContext).overlay!.context.findRenderObject()! as RenderBox;
  const gap = Offset(0, 4); // side-offset / translate-y-1
  final position = RelativeRect.fromRect(
    Rect.fromPoints(
      button.localToGlobal(button.size.bottomLeft(gap), ancestor: overlay),
      button.localToGlobal(button.size.bottomRight(gap), ancestor: overlay),
    ),
    Offset.zero & overlay.size,
  );
  return showMenu<T>(
    context: anchorContext,
    position: position,
    items: items,
    color: Mz.popover(dark),
    surfaceTintColor: Colors.transparent,
    shadowColor: Colors.black,
    elevation: 3,
    menuPadding: const EdgeInsets.all(4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: BorderSide(color: Mz.border(dark)),
    ),
    constraints: BoxConstraints(
      minWidth: width ?? minWidth,
      maxWidth: width ?? double.infinity,
      minHeight: height ?? 0,
      maxHeight: height ?? maxHeight ?? double.infinity,
    ),
    popUpAnimationStyle: const AnimationStyle(duration: Duration(milliseconds: 150)),
  );
}

/// `DropdownMenuItem` / `SelectItem`: `rounded-sm px-2 py-1.5 text-sm`,
/// `focus:bg-accent focus:text-accent-foreground` while hovered. A tap
/// closes the menu with [value] (a `null` value just closes it).
/// [checked] adds the SelectItem's check mark (`pr-8`, check at `right-2`).
class MzMenuItem<T> extends PopupMenuEntry<T> {
  const MzMenuItem({
    super.key,
    this.value,
    required this.child,
    this.enabled = true,
    this.checked,
    this.textStyle,
  });

  final T? value;
  final Widget child;
  final bool enabled;

  /// `null` → a DropdownMenuItem; `true`/`false` → a SelectItem.
  final bool? checked;
  final TextStyle? textStyle;

  @override
  double get height => 32;

  @override
  bool represents(T? value) => value == this.value;

  @override
  State<MzMenuItem<T>> createState() => _MzMenuItemState<T>();
}

class _MzMenuItemState<T> extends State<MzMenuItem<T>> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final hi = _hover && widget.enabled;
    final fg = hi ? Mz.accentForeground : Mz.popoverForeground(dark);
    final isSelect = widget.checked != null;
    Widget row = Padding(
      padding: EdgeInsets.fromLTRB(8, 6, isSelect ? 32 : 8, 6),
      child: DefaultTextStyle(
        style: TextStyle(fontSize: 14, height: 20 / 14, color: fg)
            .merge(widget.textStyle),
        child: IconTheme.merge(data: IconThemeData(size: 14, color: fg), child: widget.child),
      ),
    );
    if (widget.checked == true) {
      row = Stack(alignment: Alignment.centerLeft, children: [
        row,
        Positioned(
          right: 8,
          child: Icon(Icons.check, size: 16, color: fg),
        ),
      ]);
    }
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.enabled ? () => Navigator.pop<T>(context, widget.value) : null,
        child: Opacity(
          opacity: widget.enabled ? 1 : 0.5,
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: hi ? Mz.accent : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: row,
          ),
        ),
      ),
    );
  }
}

/// `DropdownMenuSeparator`: `bg-border -mx-1 my-1 h-px`.
class MzMenuSeparator<T> extends PopupMenuEntry<T> {
  const MzMenuSeparator({super.key});

  @override
  double get height => 9;

  @override
  bool represents(T? value) => false;

  @override
  State<MzMenuSeparator<T>> createState() => _MzMenuSeparatorState<T>();
}

class _MzMenuSeparatorState<T> extends State<MzMenuSeparator<T>> {
  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: LayoutBuilder(
        builder: (context, c) => SizedBox(
          height: 1,
          child: OverflowBox(
            minWidth: c.maxWidth + 8,
            maxWidth: c.maxWidth + 8,
            child: ColoredBox(color: Mz.border(dark)),
          ),
        ),
      ),
    );
  }
}

/// A plain (non-item) row inside a Select popover, e.g.
/// `<div class="px-3 py-2 text-xs text-gray-400">No classes found</div>`.
class MzMenuNote<T> extends PopupMenuEntry<T> {
  const MzMenuNote({super.key, required this.child});
  final Widget child;

  @override
  double get height => 32;

  @override
  bool represents(T? value) => false;

  @override
  State<MzMenuNote<T>> createState() => _MzMenuNoteState<T>();
}

class _MzMenuNoteState<T> extends State<MzMenuNote<T>> {
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: widget.child,
      );
}

/// shadcn `TooltipContent`: `bg-primary text-primary-foreground rounded-md
/// px-3 py-1.5 text-xs`.
class MzTooltip extends StatelessWidget {
  const MzTooltip({super.key, required this.message, required this.child});
  final String message;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Tooltip(
      message: message,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      verticalOffset: 22,
      decoration: BoxDecoration(
        color: Mz.primary(dark),
        borderRadius: BorderRadius.circular(14),
      ),
      textStyle: TextStyle(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w400,
        color: Mz.primaryForeground(dark),
      ),
      child: child,
    );
  }
}
