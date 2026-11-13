/// Painters and small widgets shared by the eLabs Math Zone / Science Zone
/// pages (road, milestone flag, stars, banner decorations, spinners).
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../library/library_widgets.dart' show libNunito;
import 'zones_logic.dart';

/// Which zone page is rendered.
enum ZoneKind { math, science }

/// The few template differences between elabsmathzone.vue and
/// elabssciencezone.vue.
class ZoneStyle {
  const ZoneStyle._({
    required this.label,
    required this.zone,
    required this.route,
    required this.persistedChapterKey,
    required this.headerIcon,
    required this.boardDarkBg,
    required this.thumbFadeDark,
    required this.listThumbDark,
    required this.patternDot,
  });

  /// Banner label (`Math Zone` / `Science Zone`).
  final String label;

  /// Subject `zone` picked from `getAllSubjects`.
  final String zone;

  /// `fromRoute` stored in the activity context.
  final String route;

  /// lmsHandoff key of the persisted chapter id.
  final String persistedChapterKey;

  /// `bi-collection-play-fill` / `bi-eyedropper`.
  final IconData headerIcon;

  /// Activity board background in dark mode.
  final Color boardDarkBg;

  /// Grid-card thumbnail bottom fade in dark mode.
  final Color thumbFadeDark;

  /// List-row thumbnail placeholder in dark mode.
  final Color listThumbDark;

  /// `.pattern-overlay` dot colour.
  final Color patternDot;

  static const math = ZoneStyle._(
    label: 'Math Zone',
    zone: 'MATH_ZONE',
    route: '/elabsmathzone',
    persistedChapterKey: 'persistedMathChapterId',
    headerIcon: BootstrapIcons.collection_play_fill,
    boardDarkBg: Color.fromRGBO(19, 19, 58, 0.8),
    thumbFadeDark: Color(0xFF13133A),
    listThumbDark: Color(0xFF1A1A45),
    patternDot: Color.fromRGBO(255, 255, 255, 0.1),
  );

  static const science = ZoneStyle._(
    label: 'Science Zone',
    zone: 'SCIENCE_ZONE',
    route: '/elabssciencezone',
    persistedChapterKey: 'persistedScienceChapterId',
    headerIcon: BootstrapIcons.eyedropper,
    boardDarkBg: Color.fromRGBO(13, 13, 43, 0.85),
    thumbFadeDark: Color(0xFF071A0D),
    listThumbDark: Color(0xFF13133A),
    patternDot: Color.fromRGBO(74, 222, 128, 0.1),
  );

  static ZoneStyle of(ZoneKind kind) => kind == ZoneKind.math ? math : science;
}

/// The page loads Nunito (`font-[Nunito,sans-serif]`), with the real weight
/// face (the library pages' [libNunito]).
TextStyle zt(double size, FontWeight weight, Color? color,
        {double? height, double? spacing, List<Shadow>? shadows}) =>
    libNunito(
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height,
      letterSpacing: spacing,
      shadows: shadows,
    );

/// Tailwind's `transition` default timing function, `ease-out` and `ease-in`.
const kTwEase = Cubic(0.4, 0, 0.2, 1);
const kTwEaseOut = Cubic(0, 0, 0.2, 1);
const kTwEaseIn = Cubic(0.4, 0, 1, 1);

/// Tailwind 4 `drop-shadow-md` (`0 3px 3px rgb(0 0 0 / .12)`) as a text
/// shadow; a CSS drop-shadow blur is the Gaussian's standard deviation.
const List<Shadow> kDropShadowMd = [
  Shadow(color: Color(0x1F000000), offset: Offset(0, 3), blurRadius: (3 - 0.5) / 0.57735),
];

/// Rebuilds with `hovered == true` while the pointer is over the child
/// (Tailwind `hover:` / `group-hover:`).
///
/// The cursor defers to the ancestors unless [cursor] is given: Tailwind 4's
/// preflight no longer gives buttons `cursor: pointer`, so only elements
/// with `cursor-pointer` (or inside one) show the hand.
class ZoneHover extends StatefulWidget {
  const ZoneHover({super.key, required this.builder, this.onTap, this.cursor});
  final Widget Function(BuildContext context, bool hovered) builder;
  final VoidCallback? onTap;
  final MouseCursor? cursor;

  @override
  State<ZoneHover> createState() => _ZoneHoverState();
}

class _ZoneHoverState extends State<ZoneHover> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final child = widget.builder(context, _hover);
    return MouseRegion(
      cursor: widget.cursor ?? MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: widget.onTap == null
          ? child
          : GestureDetector(behavior: HitTestBehavior.opaque, onTap: widget.onTap, child: child),
    );
  }
}

/// A pressable pill button with `hover:opacity-90 active:scale-95`
/// (`hover:scale-105` when [hoverScale] is set). Like [ZoneHover], the
/// cursor defers to the ancestors (no `cursor-pointer` on these buttons).
class ZonePressable extends StatefulWidget {
  const ZonePressable({
    super.key,
    required this.child,
    required this.onTap,
    this.hoverOpacity = 0.9,
    this.hoverScale = 1,
    this.pressScale = 0.95,
    this.cursor = MouseCursor.defer,
  });
  final Widget child;
  final VoidCallback onTap;
  final double hoverOpacity;
  final double hoverScale;
  final double pressScale;
  final MouseCursor cursor;

  @override
  State<ZonePressable> createState() => _ZonePressableState();
}

class _ZonePressableState extends State<ZonePressable> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final scale = _down ? widget.pressScale : (_hover ? widget.hoverScale : 1.0);
    return MouseRegion(
      cursor: widget.cursor,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _down = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => setState(() => _down = true),
        onTapUp: (_) => setState(() => _down = false),
        onTapCancel: () => setState(() => _down = false),
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: scale,
          duration: const Duration(milliseconds: 150),
          curve: kTwEase,
          child: AnimatedOpacity(
            opacity: _hover ? widget.hoverOpacity : 1,
            duration: const Duration(milliseconds: 150),
            curve: kTwEase,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// `rounded-full border-[n] animate-spin border-muted border-t-primary`.
class RingSpinner extends StatefulWidget {
  const RingSpinner({super.key, required this.size, required this.stroke});
  final double size;
  final double stroke;

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
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return RotationTransition(
      turns: _c,
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: _RingPainter(
          track: colors.surfaceContainerHighest,
          head: colors.primary,
          stroke: widget.stroke,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.track, required this.head, required this.stroke});
  final Color track;
  final Color head;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(stroke / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawOval(r, p..color = track);
    // border-top of a circle: the quarter between -135° and -45°.
    canvas.drawArc(r, -math.pi * 3 / 4, math.pi / 2, false, p..color = head);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.track != track || old.head != head || old.stroke != stroke;
}

/// A rounded box with a thicker top border (`border` + `borderTop: 4px`
/// + `border-radius`), painted the way browsers draw it: the inner edge of
/// the corners is elliptical (radius minus the border widths) and the top
/// colour meets the 1px side colour on the diagonal through the corner
/// (proportional to the two widths). Children are not clipped (no
/// `overflow-hidden` on the web).
class TopAccentBox extends StatelessWidget {
  const TopAccentBox({
    super.key,
    required this.child,
    required this.radius,
    required this.color,
    required this.borderColor,
    required this.topColor,
    this.topWidth = 4,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final double radius;
  final Color color;
  final Color borderColor;
  final Color topColor;
  final double topWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _TopAccentPainter(
          radius: radius,
          color: color,
          borderColor: borderColor,
          topColor: topColor,
          topWidth: topWidth,
        ),
        child: Padding(
          padding: padding + EdgeInsets.fromLTRB(1, topWidth, 1, 1),
          child: child,
        ),
      );
}

class _TopAccentPainter extends CustomPainter {
  _TopAccentPainter({
    required this.radius,
    required this.color,
    required this.borderColor,
    required this.topColor,
    required this.topWidth,
  });

  final double radius;
  final Color color;
  final Color borderColor;
  final Color topColor;
  final double topWidth;

  static const double _side = 1;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final outer = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius));
    final sideR = math.max(0.0, radius - _side);
    final topR = math.max(0.0, radius - topWidth);
    final inner = RRect.fromRectAndCorners(
      Rect.fromLTRB(_side, topWidth, w - _side, h - _side),
      topLeft: Radius.elliptical(sideR, topR),
      topRight: Radius.elliptical(sideR, topR),
      bottomLeft: Radius.circular(sideR),
      bottomRight: Radius.circular(sideR),
    );
    // background-clip: border-box — the background runs under the border.
    canvas.drawRRect(outer, Paint()..color = color);

    final ring = Path.combine(
      PathOperation.difference,
      Path()..addRRect(outer),
      Path()..addRRect(inner),
    );
    // The corner joins run from each outer top corner towards (side, top).
    final dx = radius * _side / topWidth;
    final topRegion = Path()
      ..moveTo(0, 0)
      ..lineTo(w, 0)
      ..lineTo(w - dx, radius)
      ..lineTo(dx, radius)
      ..close();
    canvas.drawPath(
      Path.combine(PathOperation.difference, ring, topRegion),
      Paint()..color = borderColor,
    );
    canvas.drawPath(
      Path.combine(PathOperation.intersect, ring, topRegion),
      Paint()..color = topColor,
    );
  }

  @override
  bool shouldRepaint(_TopAccentPainter old) =>
      old.radius != radius ||
      old.color != color ||
      old.borderColor != borderColor ||
      old.topColor != topColor ||
      old.topWidth != topWidth;
}

/// A blurred colour blob: a `rounded-full` disc with `blur-[n]`
/// ([solid]), or a `radial-gradient(circle, c 0%, transparent 70%)` disc
/// with `filter: blur(n)`, at `opacity`.
///
/// It lays out at the element's own [diameter] (so it can be positioned
/// with the web's top/left/right/bottom values) and paints the blurred
/// result around it. The radial profile is the disc convolved with a
/// Gaussian whose standard deviation is the CSS blur length.
class GlowBlob extends StatelessWidget {
  const GlowBlob({
    super.key,
    required this.color,
    required this.opacity,
    required this.diameter,
    required this.blur,
    this.solid = true,
  });

  final Color color;
  final double opacity;
  final double diameter;
  final double blur;

  /// `true`: a solid disc; `false`: a `radial-gradient(… 0%, transparent 70%)`.
  final bool solid;

  static final Map<(double, double, bool), (double, List<double>, List<double>)> _profiles = {};

  /// (painted radius, stops, alpha factors) of the blurred disc.
  static (double, List<double>, List<double>) _profile(double diameter, double sigma, bool solid) =>
      _profiles.putIfAbsent((diameter, sigma, solid), () {
        final r = diameter / 2;
        // Solid: alpha 1 up to the edge. Gradient: alpha falls linearly to 0
        // at `70%` of the farthest-corner distance (r·√2 ≈ just inside r).
        final edge = solid ? r : math.min(r, 0.7 * r * math.sqrt2);
        final reach = edge + 3 * sigma;
        const samples = 24;
        final stops = <double>[];
        final alphas = <double>[];
        for (var i = 0; i <= samples; i++) {
          final t = i / samples;
          stops.add(t);
          alphas.add(_blurredDisc(t * reach, edge, !solid, math.max(sigma, 1)));
        }
        return (reach, stops, alphas);
      });

  /// Intensity at distance [rho] from the centre of a disc of radius [edge]
  /// (alpha 1, or — [linear] — falling from 1 at the centre to 0 at the
  /// edge) blurred with a Gaussian of standard deviation [sigma].
  static double _blurredDisc(double rho, double edge, bool linear, double sigma) {
    const n = 96; // Simpson intervals (even)
    final hStep = edge / n;
    final s2 = sigma * sigma;
    double f(double x) {
      final weight = linear ? math.max(0.0, 1 - x / edge) : 1.0;
      final d = x - rho;
      return weight * (x / s2) * math.exp(-d * d / (2 * s2)) * _i0e(x * rho / s2);
    }

    var sum = f(0) + f(edge);
    for (var i = 1; i < n; i++) {
      sum += f(i * hStep) * (i.isOdd ? 4 : 2);
    }
    return (sum * hStep / 3).clamp(0.0, 1.0);
  }

  /// Exponentially scaled modified Bessel function `I0(x)·e^-x`
  /// (Abramowitz & Stegun 9.8.1 / 9.8.2).
  static double _i0e(double x) {
    if (x <= 3.75) {
      final t = (x / 3.75) * (x / 3.75);
      final i0 = 1 +
          t * (3.5156229 + t * (3.0899424 + t * (1.2067492 + t * (0.2659732 + t * (0.0360768 + t * 0.0045813)))));
      return i0 * math.exp(-x);
    }
    final t = 3.75 / x;
    final p = 0.39894228 +
        t * (0.01328592 +
            t * (0.00225319 +
                t * (-0.00157565 +
                    t * (0.00916281 + t * (-0.02057706 + t * (0.02635537 + t * (-0.01647633 + t * 0.00392377)))))));
    return p / math.sqrt(x);
  }

  @override
  Widget build(BuildContext context) {
    final (reach, stops, alphas) = _profile(diameter, blur, solid);
    final base = color.a * opacity;
    return SizedBox.square(
      dimension: diameter,
      child: OverflowBox(
        minWidth: reach * 2,
        maxWidth: reach * 2,
        minHeight: reach * 2,
        maxHeight: reach * 2,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [for (final a in alphas) color.withValues(alpha: base * a)],
              stops: stops,
            ),
          ),
        ),
      ),
    );
  }
}

/// `.pattern-overlay` — `radial-gradient(dot 2px, transparent 2px)` every 30px.
class DotPatternPainter extends CustomPainter {
  DotPatternPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (var y = 15.0; y < size.height + 15; y += 30) {
      for (var x = 15.0; x < size.width + 15; x += 30) {
        canvas.drawCircle(Offset(x, y), 2, p);
      }
    }
  }

  @override
  bool shouldRepaint(DotPatternPainter old) => old.color != color;
}

/// 1px grid lines every 40px (`backgroundSize: 40px 40px`).
class GridPainter extends CustomPainter {
  GridPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    for (var y = 0.0; y < size.height; y += 40) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), p);
    }
    for (var x = 0.0; x < size.width; x += 40) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.height), p);
    }
  }

  @override
  bool shouldRepaint(GridPainter old) => old.color != color;
}

// ── Road ───────────────────────────────────────────────────────────────────

/// The road SVG: gravel edge (52), curbs (44), asphalt (40, drop shadow) and
/// the dashed yellow centre line.
class RoadPainter extends CustomPainter {
  RoadPainter({required this.points, required this.dark});
  final List<Offset> points;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    // `M x y` alone (one chapter) draws nothing.
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final (c1, c2, end) in roadSegments(points)) {
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
    }

    Paint stroke(Color c, double w) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = c;

    canvas.drawPath(path, stroke(dark ? const Color(0xFF27272A) : const Color(0xFF94A3B8), 52));
    canvas.drawPath(path, stroke(dark ? const Color(0xFF52525B) : const Color(0xFFCBD5E1), 44));
    // feDropShadow dx=0 dy=6 stdDeviation=4 flood-opacity=0.4
    canvas.drawPath(
      path.shift(const Offset(0, 6)),
      stroke(const Color.fromRGBO(0, 0, 0, 0.4), 40)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawPath(path, stroke(dark ? const Color(0xFF18181B) : const Color(0xFF3F3F46), 40));

    // stroke-dasharray="10 15"
    final dash = stroke(const Color(0xFFFACC15), 2.5);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 10, metric.length)), dash);
        d += 25;
      }
    }
  }

  @override
  bool shouldRepaint(RoadPainter old) => old.dark != dark || !listEquals(old.points, points);
}

// ── Milestone flag ─────────────────────────────────────────────────────────

/// The 48×56 flag SVG (`viewBox="0 0 24 32"`), including its
/// `drop-shadow(0 8px 10px rgba(0,0,0,0.55))` and the `animate-ping` ring of
/// the selected milestone ([ping] = animation value 0..1, null = no ring).
class FlagPainter extends CustomPainter {
  FlagPainter({
    required this.fill,
    required this.stroke,
    required this.ringColor,
    this.ping,
  });

  final Color fill;
  final Color stroke;
  final Color ringColor;
  final double? ping;

  static final Path _banner = Path()
    ..moveTo(6, 3)
    ..cubicTo(11, 1, 14, 5, 22, 3)
    ..lineTo(22, 13)
    ..cubicTo(14, 15, 11, 11, 6, 13)
    ..close();

  static final Path _base = Path()
    ..moveTo(2, 30)
    ..lineTo(8, 30)
    ..lineTo(9, 27)
    ..lineTo(1, 27)
    ..close();

  void _shapes(Canvas canvas, {required bool shadow}) {
    Paint fillP(Color c) => Paint()..color = c;
    Paint strokeP(Color c, double w) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeJoin = StrokeJoin.round
      ..color = c;

    final p = ping;
    if (p != null && !shadow) {
      // animate-ping (1s cubic-bezier(0, 0, .2, 1)): 0→75% scale 1→2,
      // opacity 1→0; then hidden.
      final t = (p / 0.75).clamp(0.0, 1.0);
      final eased = const Cubic(0, 0, 0.2, 1).transform(t);
      final opacity = p >= 0.75 ? 0.0 : 1 - eased;
      if (opacity > 0) {
        canvas.drawCircle(const Offset(5, 30), 4 * (1 + eased),
            strokeP(ringColor.withValues(alpha: opacity), 2 * (1 + eased)));
      }
    }
    canvas.drawOval(Rect.fromCenter(center: const Offset(5, 30), width: 16, height: 6),
        fillP(const Color.fromRGBO(0, 0, 0, 0.35)));
    canvas.drawPath(_base, fillP(const Color(0xFF94A3B8)));
    canvas.drawPath(_base, strokeP(const Color(0xFF475569), 0.5));
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(4, 2, 2, 25), const Radius.circular(0.5)),
        fillP(const Color(0xFFE2E8F0)));
    canvas.drawLine(const Offset(4.5, 2), const Offset(4.5, 27), strokeP(const Color(0xFF94A3B8), 0.5));
    canvas.drawCircle(const Offset(5, 2), 1.5, fillP(const Color(0xFFFBBF24)));
    canvas.drawCircle(const Offset(5, 2), 1.5, strokeP(const Color(0xFFD97706), 0.5));
    canvas.drawPath(_banner, fillP(fill));
    canvas.drawPath(_banner, strokeP(stroke, 1.2));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width / 24, size.height / 32);
    final dx = (size.width - 24 * s) / 2;
    final dy = (size.height - 32 * s) / 2;

    // drop-shadow(0 8px 10px rgba(0,0,0,.55)): the flag's silhouette, 8px
    // lower, blurred with a standard deviation of 10px (a CSS drop-shadow
    // blur is the deviation, not a box-shadow blur radius).
    canvas.saveLayer(
      Rect.fromLTWH(-40, -40, size.width + 80, size.height + 88),
      Paint()
        ..colorFilter = const ColorFilter.mode(Color.fromRGBO(0, 0, 0, 0.55), BlendMode.srcIn)
        ..imageFilter = ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
    );
    canvas.translate(dx, dy + 8);
    canvas.scale(s);
    _shapes(canvas, shadow: true);
    canvas.restore();

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(s);
    _shapes(canvas, shadow: false);
    canvas.restore();
  }

  @override
  bool shouldRepaint(FlagPainter old) =>
      old.fill != fill || old.stroke != stroke || old.ping != ping || old.ringColor != ringColor;
}

// ── Star ────────────────────────────────────────────────────────────────────

/// The star path used by the banner and the rating rows (`viewBox 0 0 24 24`).
final Path starPath24 = Path()
  ..moveTo(12, 2)
  ..lineTo(15.09, 8.26)
  ..lineTo(22, 9.27)
  ..lineTo(17, 14.14)
  ..lineTo(18.18, 21.02)
  ..lineTo(12, 17.77)
  ..lineTo(5.82, 21.02)
  ..lineTo(7, 14.14)
  ..lineTo(2, 9.27)
  ..lineTo(8.91, 8.26)
  ..close();

/// The star SVG (`fill` / `stroke` / `stroke-width`, SVG default miter
/// joins).
class StarPainter extends CustomPainter {
  StarPainter({this.fill, required this.stroke, required this.strokeWidth, this.glow});
  final Color? fill;
  final Color stroke;

  /// In viewBox units.
  final double strokeWidth;

  /// `drop-shadow(0 0 3px color)` (the shadow of the filled and stroked
  /// star, blurred with a 3px standard deviation).
  final Color? glow;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 24;
    canvas.save();
    canvas.scale(s);
    Paint strokePaint(Color c) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeJoin = StrokeJoin.miter
      ..strokeMiterLimit = 4
      ..color = c;
    final g = glow;
    if (g != null) {
      // One layer at the glow's alpha, so fill and stroke don't add up.
      final opaque = g.withValues(alpha: 1);
      final blur = MaskFilter.blur(BlurStyle.normal, 3 / s);
      canvas.saveLayer(null, Paint()..color = Color.fromRGBO(0, 0, 0, g.a));
      if (fill != null) canvas.drawPath(starPath24, Paint()..color = opaque..maskFilter = blur);
      canvas.drawPath(starPath24, strokePaint(opaque)..maskFilter = blur);
      canvas.restore();
    }
    final f = fill;
    if (f != null) canvas.drawPath(starPath24, Paint()..color = f);
    canvas.drawPath(starPath24, strokePaint(stroke));
    canvas.restore();
  }

  @override
  bool shouldRepaint(StarPainter old) =>
      old.fill != fill || old.stroke != stroke || old.glow != glow || old.strokeWidth != strokeWidth;
}

/// `<circle cx=12 cy=12 r=10 stroke-dasharray="4 4"/>` (`viewBox 0 0 24 24`).
class DashedCirclePainter extends CustomPainter {
  DashedCirclePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.save();
    canvas.scale(s);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = color;
    final path = Path()..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 10));
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 4, metric.length)), p);
        d += 8;
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(DashedCirclePainter old) => old.color != color;
}

/// `<rect x=3 y=3 width=18 height=18 rx=2/>` (`viewBox 0 0 24 24`).
class RoundedSquarePainter extends CustomPainter {
  RoundedSquarePainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.save();
    canvas.scale(s);
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(3, 3, 18, 18), const Radius.circular(2)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = color,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(RoundedSquarePainter old) => old.color != color;
}

// ── Inline SVG icons ────────────────────────────────────────────────────────

/// The template's inline outline SVGs (`viewBox="0 0 24 24"`, `fill="none"
/// stroke="currentColor"`).
abstract final class ZoneSvg {
  /// Science banner shape 1 (light bulb).
  static const bulb =
      'M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z';

  /// Science banner shape 3 (beaker).
  static const beaker =
      'M19.428 15.428a2 2 0 00-1.022-.547l-2.387-.477a6 6 0 00-3.86.517l-.318.158a6 6 0 01-3.86.517L6.05 15.21a2 2 0 00-1.806.547M8 4h8l-1 1v5.172a2 2 0 00.586 1.414l5 5c1.26 1.26.367 3.414-1.415 3.414H4.828c-1.782 0-2.674-2.154-1.414-3.414l5-5A2 2 0 009 10.172V5L8 4z';

  /// "Quiz Unavailable" header icon (warning triangle).
  static const warning =
      'M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z';

  /// "No Questions Yet" icon (question mark in a circle).
  static const question =
      'M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9 5.25h.008v.008H12v-.008z';

  /// Modal close button (X).
  static const close = 'M6 18L18 6M6 6l12 12';

  static final Map<String, Path> _cache = {};

  /// The parsed path (cached).
  static Path path(String d) => _cache.putIfAbsent(d, () => parseSvgPathData(d));
}

/// Parses SVG path data (`M L H V C S Q T A Z`, absolute and relative,
/// implicit repeats, single-character arc flags).
Path parseSvgPathData(String d) {
  final path = Path();
  final letter = RegExp('[A-Za-z]');
  var i = 0;
  bool isSep(int c) => c == 0x20 || c == 0x2C || c == 0x0A || c == 0x0D || c == 0x09;
  bool isDigit(int c) => c >= 0x30 && c <= 0x39;
  void skip() {
    while (i < d.length && isSep(d.codeUnitAt(i))) {
      i++;
    }
  }

  double number() {
    skip();
    final start = i;
    if (i < d.length && (d[i] == '-' || d[i] == '+')) i++;
    var dot = false;
    while (i < d.length) {
      final c = d.codeUnitAt(i);
      if (isDigit(c)) {
        i++;
      } else if (c == 0x2E && !dot) {
        dot = true;
        i++;
      } else {
        break;
      }
    }
    if (i < d.length && (d[i] == 'e' || d[i] == 'E')) {
      i++;
      if (i < d.length && (d[i] == '-' || d[i] == '+')) i++;
      while (i < d.length && isDigit(d.codeUnitAt(i))) {
        i++;
      }
    }
    return double.parse(d.substring(start, i));
  }

  bool flag() {
    skip();
    return d[i++] == '1';
  }

  var cur = Offset.zero;
  var start = Offset.zero;
  Offset? lastCubic; // second control point of the previous C/S
  Offset? lastQuad;
  var cmd = '';
  while (true) {
    skip();
    if (i >= d.length) break;
    if (letter.hasMatch(d[i])) {
      cmd = d[i];
      i++;
    } else if (cmd == 'M') {
      cmd = 'L'; // implicit lineto after a moveto
    } else if (cmd == 'm') {
      cmd = 'l';
    }
    final rel = cmd == cmd.toLowerCase();
    Offset pt(double x, double y) => rel ? cur + Offset(x, y) : Offset(x, y);
    switch (cmd.toUpperCase()) {
      case 'Z':
        path.close();
        cur = start;
        lastCubic = lastQuad = null;
        skip();
        if (i < d.length && !letter.hasMatch(d[i])) return path; // malformed
      case 'M':
        cur = pt(number(), number());
        start = cur;
        path.moveTo(cur.dx, cur.dy);
        lastCubic = lastQuad = null;
      case 'L':
        cur = pt(number(), number());
        path.lineTo(cur.dx, cur.dy);
        lastCubic = lastQuad = null;
      case 'H':
        final x = number();
        cur = Offset(rel ? cur.dx + x : x, cur.dy);
        path.lineTo(cur.dx, cur.dy);
        lastCubic = lastQuad = null;
      case 'V':
        final y = number();
        cur = Offset(cur.dx, rel ? cur.dy + y : y);
        path.lineTo(cur.dx, cur.dy);
        lastCubic = lastQuad = null;
      case 'C':
        final c1 = pt(number(), number());
        final c2 = pt(number(), number());
        final end = pt(number(), number());
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        lastCubic = c2;
        lastQuad = null;
        cur = end;
      case 'S':
        final c1 = lastCubic == null ? cur : cur * 2 - lastCubic;
        final c2 = pt(number(), number());
        final end = pt(number(), number());
        path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
        lastCubic = c2;
        lastQuad = null;
        cur = end;
      case 'Q':
        final c = pt(number(), number());
        final end = pt(number(), number());
        path.quadraticBezierTo(c.dx, c.dy, end.dx, end.dy);
        lastQuad = c;
        lastCubic = null;
        cur = end;
      case 'T':
        final c = lastQuad == null ? cur : cur * 2 - lastQuad;
        final end = pt(number(), number());
        path.quadraticBezierTo(c.dx, c.dy, end.dx, end.dy);
        lastQuad = c;
        lastCubic = null;
        cur = end;
      case 'A':
        final rx = number();
        final ry = number();
        final rotation = number();
        final large = flag();
        final sweep = flag();
        final end = pt(number(), number());
        _svgArc(path, cur, end, rx, ry, rotation, large, sweep);
        lastCubic = lastQuad = null;
        cur = end;
      default:
        return path; // unknown command
    }
  }
  return path;
}

/// An SVG elliptical arc from [p0] to [p1] (SVG 1.1 F.6.5 endpoint → centre
/// conversion) as cubic Béziers of at most 90° each. (`Path.arcToPoint`
/// flattens an exact half circle — `a2 2 0 11-4 0` — into two lines.)
void _svgArc(Path path, Offset p0, Offset p1, double rx, double ry, double rotationDeg, bool largeArc,
    bool sweep) {
  if (p0 == p1) return;
  rx = rx.abs();
  ry = ry.abs();
  if (rx == 0 || ry == 0) {
    path.lineTo(p1.dx, p1.dy);
    return;
  }
  final phi = rotationDeg * math.pi / 180;
  final cosP = math.cos(phi), sinP = math.sin(phi);
  final hx = (p0.dx - p1.dx) / 2, hy = (p0.dy - p1.dy) / 2;
  final x1 = cosP * hx + sinP * hy;
  final y1 = -sinP * hx + cosP * hy;
  final lambda = (x1 * x1) / (rx * rx) + (y1 * y1) / (ry * ry);
  if (lambda > 1) {
    rx *= math.sqrt(lambda);
    ry *= math.sqrt(lambda);
  }
  final numer = rx * rx * ry * ry - rx * rx * y1 * y1 - ry * ry * x1 * x1;
  final denom = rx * rx * y1 * y1 + ry * ry * x1 * x1;
  var coef = denom == 0 ? 0.0 : math.sqrt(math.max(0.0, numer / denom));
  if (largeArc == sweep) coef = -coef;
  final cx1 = coef * rx * y1 / ry;
  final cy1 = -coef * ry * x1 / rx;
  final cx = cosP * cx1 - sinP * cy1 + (p0.dx + p1.dx) / 2;
  final cy = sinP * cx1 + cosP * cy1 + (p0.dy + p1.dy) / 2;

  double angle(double ux, double uy, double vx, double vy) => math.atan2(ux * vy - uy * vx, ux * vx + uy * vy);
  final ux = (x1 - cx1) / rx, uy = (y1 - cy1) / ry;
  final vx = (-x1 - cx1) / rx, vy = (-y1 - cy1) / ry;
  var theta = angle(1, 0, ux, uy);
  var dTheta = angle(ux, uy, vx, vy);
  if (!sweep && dTheta > 0) dTheta -= 2 * math.pi;
  if (sweep && dTheta < 0) dTheta += 2 * math.pi;

  Offset map(double x, double y) =>
      Offset(cx + rx * x * cosP - ry * y * sinP, cy + rx * x * sinP + ry * y * cosP);
  final segments = math.max(1, (dTheta.abs() / (math.pi / 2) - 1e-9).ceil());
  final delta = dTheta / segments;
  final k = 4 / 3 * math.tan(delta / 4);
  for (var i = 0; i < segments; i++) {
    final c1 = math.cos(theta), s1 = math.sin(theta);
    final theta2 = theta + delta;
    final c2 = math.cos(theta2), s2 = math.sin(theta2);
    final a = map(c1 - k * s1, s1 + k * c1);
    final b = map(c2 + k * s2, s2 - k * c2);
    final e = i == segments - 1 ? p1 : map(c2, s2);
    path.cubicTo(a.dx, a.dy, b.dx, b.dy, e.dx, e.dy);
    theta = theta2;
  }
}

/// An outline SVG icon (`fill="none" stroke="currentColor"`) drawn at
/// [size] from a 24×24 viewBox.
class SvgStrokeIcon extends StatelessWidget {
  const SvgStrokeIcon(
    this.data, {
    super.key,
    required this.size,
    required this.color,
    required this.strokeWidth,
    this.round = false,
  });

  final String data;
  final double size;
  final Color color;

  /// `stroke-width` in viewBox units.
  final double strokeWidth;

  /// `stroke-linecap="round" stroke-linejoin="round"` (else the SVG
  /// defaults: butt caps, miter joins).
  final bool round;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _SvgStrokePainter(ZoneSvg.path(data), color, strokeWidth, round),
      );
}

class _SvgStrokePainter extends CustomPainter {
  _SvgStrokePainter(this.path, this.color, this.strokeWidth, this.round);
  final Path path;
  final Color color;
  final double strokeWidth;
  final bool round;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 24;
    canvas.save();
    canvas.scale(s);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = round ? StrokeCap.round : StrokeCap.butt
        ..strokeJoin = round ? StrokeJoin.round : StrokeJoin.miter
        ..strokeMiterLimit = 4
        ..color = color,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SvgStrokePainter old) =>
      old.path != path || old.color != color || old.strokeWidth != strokeWidth || old.round != round;
}
