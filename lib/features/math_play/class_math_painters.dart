/// Painters for the Class Math roadmap — the inline `<svg>` of
/// `classmath.vue`, split into layers so only the animated dark-mode parts
/// repaint every frame:
///
/// 1. [ClassMathBackPainter]   sky → hills → fields → river → fences → road →
///                              trees → bushes → flowers (static)
/// 2. [ClassMathCampfirePainter] campfires (dark mode, animated)
/// 3. [ClassMathFrontPainter]  houses, barns, tents, win banner shapes (static)
/// 4. [ClassMathLightsPainter] lit house windows + chimney smoke (dark mode,
///                              animated)
///
/// The banner texts ("YOU WIN! 🏆", ★) are widgets laid over the painters so
/// the Fredoka font can load asynchronously.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import 'class_math_scene.dart';

// ── drawing helpers ─────────────────────────────────────────────────────────

const _black = Color(0xFF000000);

Color _op(Color c, double o) => c.withValues(alpha: (c.a * o).clamp(0.0, 1.0));

Paint _fill(Color c, [double o = 1]) => Paint()..color = _op(c, o);

Paint _stroke(Color c, double w, {double o = 1, StrokeCap cap = StrokeCap.butt}) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = cap
  ..color = _op(c, o);

Rect _ltwh(double x, double y, double w, double h) => Rect.fromLTWH(x, y, w, h);

void _oval(Canvas c, double cx, double cy, double rx, double ry, Paint p) =>
    c.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), p);

void _rrect(Canvas c, double x, double y, double w, double h, double r, Paint p) {
  if (w <= 0 || h <= 0) return; // SVG: negative / zero size is not rendered
  c.drawRRect(RRect.fromRectAndRadius(_ltwh(x, y, w, h), Radius.circular(r)), p);
}

void _poly(Canvas c, List<Offset> pts, Paint p) => c.drawPath(Path()..addPolygon(pts, true), p);

/// SVG `linearGradient x1=0 y1=0 x2=0 y2=1` over [r] (objectBoundingBox).
Shader _vGrad(Rect r, Color top, Color bottom, [double o = 1]) =>
    ui.Gradient.linear(r.topCenter, r.bottomCenter, [_op(top, o), _op(bottom, o)]);

/// SVG `linearGradient x1=0 x2=1` with a mirrored middle stop.
Shader _hGrad3(Rect r, Color edge, Color mid) =>
    ui.Gradient.linear(r.centerLeft, r.centerRight, [edge, mid, edge], const [0, 0.5, 1]);

Path _toPath(SmoothPath sp) {
  final p = Path();
  final s = sp.start;
  if (s == null) return p;
  p.moveTo(s.dx, s.dy);
  for (final seg in sp.segments) {
    p.cubicTo(seg.c1.dx, seg.c1.dy, seg.c2.dx, seg.c2.dy, seg.to.dx, seg.to.dy);
  }
  return p;
}

/// `stroke-dasharray` for a stroked path.
Path _dashed(Path src, List<double> pattern) {
  final out = Path();
  for (final m in src.computeMetrics()) {
    var d = 0.0;
    var i = 0;
    while (d < m.length) {
      final len = pattern[i % pattern.length];
      if (i.isEven) out.addPath(m.extractPath(d, math.min(d + len, m.length)), Offset.zero);
      d += len;
      i++;
    }
  }
  return out;
}

/// `filter: feDropShadow` on a group: the group's silhouette, offset, blurred
/// and flooded with [color], then the group itself.
void _dropShadowGroup(Canvas canvas, Rect bounds, Offset offset, double sigma, Color color,
    void Function() draw) {
  canvas.saveLayer(
    bounds.inflate(sigma * 3).shift(offset),
    Paint()
      ..imageFilter = ui.ImageFilter.blur(sigmaX: sigma, sigmaY: sigma, tileMode: TileMode.decal)
      ..colorFilter = ColorFilter.mode(color, BlendMode.srcIn),
  );
  canvas.translate(offset.dx, offset.dy);
  draw();
  canvas.restore();
  draw();
}

/// SVG `<text>` at baseline ([x], [y]) with `text-anchor` middle or start.
void _svgText(Canvas canvas, String text, double x, double y, double size, Color color,
    {bool middle = false}) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: TextStyle(fontSize: size, color: color)),
    textDirection: TextDirection.ltr,
  )..layout();
  final base = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  tp.paint(canvas, Offset(middle ? x - tp.width / 2 : x, y - base));
  tp.dispose();
}

/// Value of a CSS keyframe animation at [t] seconds. Before [delay] (no
/// `animation-fill-mode`) the element shows its own value, [idle]
/// (defaults to the first keyframe).
double keyframe(double t, double duration, List<double> at, List<double> values,
    {double delay = 0, Curve curve = Curves.easeInOut, double? idle}) {
  if (t < delay) return idle ?? values.first;
  final p = ((t - delay) % duration) / duration;
  for (var i = 0; i < at.length - 1; i++) {
    if (p >= at[i] && p <= at[i + 1]) {
      final local = (p - at[i]) / (at[i + 1] - at[i]);
      return values[i] + (values[i + 1] - values[i]) * curve.transform(local);
    }
  }
  return values.last;
}

/// `winPulse 3.5s ease-in-out infinite` (`.bulb-win-pulse`).
double winPulse(double t) =>
    keyframe(t, 3.5, const [0, 0.3, 0.6, 1], const [0.85, 1.0, 0.75, 0.85]);

// ── 1. background ───────────────────────────────────────────────────────────

class ClassMathBackPainter extends CustomPainter {
  ClassMathBackPainter(this.scene);
  final ClassMathScene scene;

  bool get _dark => scene.dark;
  Color _d(int dark, int light) => Color(_dark ? dark : light);

  @override
  void paint(Canvas canvas, Size size) {
    final w = scene.stageW, h = scene.stageH;

    // sky + stars in dark mode
    final full = _ltwh(0, 0, w, h);
    canvas.drawRect(full, Paint()..shader = _vGrad(full, _d(0xFF020817, 0xFF7DCE4A), _d(0xFF0F172A, 0xFFE8F8DC)));
    if (_dark) _stars(canvas, Rect.fromLTWH(0, 0, w, h * 0.45));

    // moon in dark mode
    if (_dark) {
      final mx = w * 0.85, my = h * 0.06;
      canvas.drawCircle(Offset(mx, my), 28, _fill(const Color(0xFFFFF8D0), 0.92));
      canvas.drawCircle(Offset(mx + 10, my - 8), 22, _fill(const Color(0xFF020817)));
      // `filter="url(#fGlowStrong)"` references no filter, so it is ignored.
      canvas.drawCircle(Offset(mx, my), 50, _fill(const Color(0xFFFFF8D0), 0.08));
    }

    Shader hill1(Rect r, [double o = 1]) =>
        _vGrad(r, _d(0xFF0F1F3D, 0xFF6DC040), _d(0xFF0A1628, 0xFF4E9A28), o);
    Shader hill2(Rect r, [double o = 1]) =>
        _vGrad(r, _d(0xFF0D1F3F, 0xFF85D04A), _d(0xFF0A1628, 0xFF60B030), o);
    void ellipseShader(double cx, double cy, double rx, double ry, Shader Function(Rect) s) {
      final r = Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);
      canvas.drawOval(r, Paint()..shader = s(r));
    }

    ellipseShader(w * 0.15, h * 0.15, 180, 120, (r) => hill1(r, 0.55));
    ellipseShader(w * 0.82, h * 0.12, 210, 140, (r) => hill2(r, 0.5));
    _oval(canvas, w * 0.5, h * 0.08, 160, 100, _fill(_d(0xFF0F1A35, 0xFF82C448), 0.45));
    final ground = _ltwh(0, h * 0.05, w, h * 0.95);
    canvas.drawRect(ground, Paint()..shader = _vGrad(ground, _d(0xFF0F172A, 0xFF7DCE4A), _d(0xFF020817, 0xFF5AAA2A)));
    ellipseShader(w * 0.1, h * 0.22, 220, 150, hill1);
    ellipseShader(w * 0.88, h * 0.18, 240, 160, hill2);
    _oval(canvas, w * 0.5, h * 0.38, 200, 130, _fill(_d(0xFF0A1628, 0xFF7DCE4A), 0.7));

    // crop fields
    _cropField(canvas, _ltwh(w * 0.03, h * 0.08, w * 0.22, h * 0.14),
        fill: _d(0xFF1E293B, 0xFFA8D860), fillOp: 0.9, patternOp: 0.6,
        stroke: _d(0xFF334155, 0xFF78A828), strokeOp: 0.8);
    _cropField(canvas, _ltwh(w * 0.72, h * 0.07, w * 0.24, h * 0.13),
        fill: _d(0xFF1E3A5F, 0xFFC8E870), fillOp: 0.85, patternOp: 0.5,
        stroke: _d(0xFF1E3A5F, 0xFF88B030), strokeOp: 0.7);

    // river
    final river = _toPath(scene.riverPath);
    if (scene.riverPath.segments.isNotEmpty) {
      final b = river.getBounds();
      Shader riverGrad([double o = 1]) => ui.Gradient.linear(b.centerLeft, b.centerRight, [
            _op(_d(0xFF1E3A5F, 0xFF5BBFEF), o),
            _op(_d(0xFF1D4ED8, 0xFF3AAADE), o),
            _op(_d(0xFF1E3A5F, 0xFF5BBFEF), o),
          ], const [0, 0.5, 1]);
      canvas.drawPath(river, _stroke(_black, kRiverW + 6, cap: StrokeCap.round)..shader = riverGrad(0.25));
      canvas.drawPath(river, _stroke(_black, kRiverW, cap: StrokeCap.round)..shader = riverGrad());
      canvas.drawPath(
          _dashed(river, const [30, 20]),
          _stroke(_dark ? const Color.fromRGBO(59, 130, 246, 0.3) : const Color.fromRGBO(255, 255, 255, 0.5), 3));
    }

    // fences
    for (final f in scene.fenceItems) {
      _fence(canvas, f);
    }

    // road
    if (scene.roadPath.segments.isNotEmpty) {
      final road = _toPath(scene.roadPath);
      final b = road.getBounds();
      canvas.drawPath(
          road,
          _stroke(_dark ? const Color.fromRGBO(0, 0, 0, 0.7) : const Color.fromRGBO(0, 0, 0, 0.18),
              kRoadW + 14, cap: StrokeCap.round));
      canvas.drawPath(road, _stroke(_d(0xFF1E293B, 0xFFC4975A), kRoadW + 4, cap: StrokeCap.round));
      canvas.drawPath(
          road,
          _stroke(_black, kRoadW, cap: StrokeCap.round)
            ..shader = _hGrad3(b, _d(0xFF1E293B, 0xFFD4B483), _d(0xFF334155, 0xFFE8C890)));
      canvas.drawPath(
          road,
          _stroke(_dark ? const Color.fromRGBO(255, 255, 255, 0.03) : const Color.fromRGBO(255, 255, 255, 0.2),
              kRoadW - 10, cap: StrokeCap.round));
      canvas.drawPath(
          _dashed(road, const [22, 18]),
          _stroke(_dark ? const Color.fromRGBO(148, 163, 184, 0.2) : const Color.fromRGBO(255, 255, 255, 0.7),
              2.5));
    }

    // bg trees
    for (final t in scene.bgTreeItems) {
      _rrect(canvas, t.x - t.sz * 0.08, t.y, t.sz * 0.16, t.sz * 0.55, 3, _fill(_d(0xFF1E293B, 0xFF8B5E2A)));
      _oval(canvas, t.x, t.y - t.sz * 0.05, t.sz * 0.62, t.sz * 0.38, _fill(t.c1, 0.9));
      _oval(canvas, t.x, t.y - t.sz * 0.42, t.sz * 0.48, t.sz * 0.30, _fill(t.c2));
      _oval(canvas, t.x, t.y - t.sz * 0.72, t.sz * 0.32, t.sz * 0.22, _fill(t.c3));
    }

    // road trees
    for (final t in scene.roadTreeItems) {
      _rrect(canvas, t.x - t.sz * 0.07, t.y, t.sz * 0.14, t.sz * 0.48, 2, _fill(_d(0xFF0F172A, 0xFF7A4E2A)));
      _oval(canvas, t.x, t.y - t.sz * 0.05, t.sz * 0.52, t.sz * 0.34, _fill(t.c1, 0.92));
      _oval(canvas, t.x, t.y - t.sz * 0.36, t.sz * 0.40, t.sz * 0.26, _fill(t.c2));
      _oval(canvas, t.x, t.y - t.sz * 0.60, t.sz * 0.26, t.sz * 0.18, _fill(t.c3));
    }

    // bushes
    for (final b in scene.bushItems) {
      _oval(canvas, b.x, b.y, b.r, b.r * 0.62, _fill(b.col));
      _oval(canvas, b.x - b.r * 0.38, b.y - b.r * 0.28, b.r * 0.55, b.r * 0.42, _fill(_d(0xFF1E3A5F, 0xFF52CC38), 0.6));
      _oval(canvas, b.x + b.r * 0.30, b.y - b.r * 0.22, b.r * 0.45, b.r * 0.35, _fill(_d(0xFF1E293B, 0xFF60D844), 0.5));
    }

    // flowers
    for (final f in scene.flowerItems) {
      canvas.drawLine(Offset(f.x, f.y + f.r), Offset(f.x, f.y + f.r + 8), _stroke(_d(0xFF1E3A5F, 0xFF3A8020), 1.5));
      canvas.drawCircle(Offset(f.x, f.y), f.r + 2, _fill(f.petal, 0.5));
      canvas.drawCircle(Offset(f.x, f.y), f.r, _fill(f.col));
      canvas.drawCircle(Offset(f.x, f.y), 2, _fill(_d(0xFF60A5FA, 0xFFFFEE44)));
    }
  }

  /// `<pattern id="stars">` (120×80 tiles) over [r] at opacity 0.7.
  void _stars(Canvas canvas, Rect r) {
    const stars = [
      (10.0, 12.0, 1.0, 0.8), (35.0, 6.0, 1.2, 0.6), (58.0, 22.0, 0.8, 0.9), (80.0, 8.0, 1.1, 0.7),
      (100.0, 18.0, 0.9, 0.8), (20.0, 35.0, 1.0, 0.5), (65.0, 40.0, 1.3, 0.6), (90.0, 32.0, 0.7, 0.9),
      (48.0, 55.0, 1.0, 0.7), (110.0, 50.0, 0.8, 0.8),
    ];
    final paints = [for (final s in stars) _fill(const Color(0xFFFFFFFF), s.$4 * 0.7)];
    canvas.save();
    canvas.clipRect(r);
    for (var ty = 0.0; ty < r.bottom; ty += 80) {
      for (var tx = 0.0; tx < r.right; tx += 120) {
        for (var i = 0; i < stars.length; i++) {
          canvas.drawCircle(Offset(tx + stars[i].$1, ty + stars[i].$2), stars[i].$3, paints[i]);
        }
      }
    }
    canvas.restore();
  }

  /// A crop field: filled rect, `cropRows` pattern (16×12 tiles anchored at
  /// the stage origin) and outline, all `rx=8`.
  void _cropField(Canvas canvas, Rect r,
      {required Color fill,
      required double fillOp,
      required double patternOp,
      required Color stroke,
      required double strokeOp}) {
    final rr = RRect.fromRectAndRadius(r, const Radius.circular(8));
    canvas.drawRRect(rr, _fill(fill, fillOp));

    final base = _d(0xFF1E293B, 0xFF88C040);
    final band = _d(0xFF0F172A, 0xFF70A830);
    // band at 0.6 over base, flattened (both opaque inside the tile).
    final bandFlat = Color.lerp(base, band, 0.6)!;
    canvas.save();
    canvas.clipRRect(rr);
    canvas.drawRect(r, _fill(base, patternOp));
    final bandPaint = _fill(bandFlat, patternOp);
    for (var y = (r.top / 12).floorToDouble() * 12; y < r.bottom; y += 12) {
      canvas.drawRect(Rect.fromLTRB(r.left, y, r.right, y + 5), bandPaint);
    }
    canvas.restore();

    canvas.drawRRect(rr, _stroke(stroke, 2, o: strokeOp));
  }

  /// A fence: `<rect fill="url(#fenceH)" rx=2>` in a group with opacity .85.
  void _fence(Canvas canvas, Fence f) {
    final r = _ltwh(f.x, f.y, f.w, 14);
    if (f.w <= 0) return;
    final rail = _fill(_d(0xFF334155, 0xFFC8A060));
    final post = _fill(_d(0xFF1E293B, 0xFFB88840));
    canvas.saveLayer(r, Paint()..color = const Color.fromRGBO(0, 0, 0, 0.85));
    canvas.clipRRect(RRect.fromRectAndRadius(r, const Radius.circular(2)));
    for (var ty = (r.top / 14).floorToDouble() * 14; ty < r.bottom; ty += 14) {
      for (var tx = (r.left / 24).floorToDouble() * 24; tx < r.right; tx += 24) {
        canvas.save();
        canvas.clipRect(_ltwh(tx, ty, 24, 14));
        _rrect(canvas, tx, ty + 4, 24, 3, 1.5, rail);
        _rrect(canvas, tx, ty + 9, 24, 3, 1.5, rail);
        _rrect(canvas, tx + 2, ty + 1, 4, 12, 2, post);
        _rrect(canvas, tx + 10, ty + 1, 4, 12, 2, post);
        _rrect(canvas, tx + 18, ty + 1, 4, 12, 2, post);
        canvas.restore();
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(ClassMathBackPainter old) => old.scene != scene;
}

// ── 2. campfires (dark mode) ───────────────────────────────────────────────

class ClassMathCampfirePainter extends CustomPainter {
  ClassMathCampfirePainter(this.scene, this.time) : super(repaint: time);
  final ClassMathScene scene;

  /// Seconds since the animations started.
  final ValueListenable<double> time;

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    for (final cf in scene.campfireItems) {
      _campfire(canvas, cf, t);
    }
  }

  void _campfire(Canvas canvas, Campfire cf, double t) {
    final x = cf.x, y = cf.y, r = cf.r;

    // Ground glow halo — campGlow + fCampGlow (blur 22, the blurred image
    // merged ×3) + campfire-pulse (opacity .7↔1, scale 1↔1.12). The class
    // sets no `transform-box`, so the scale is about the SVG origin (the
    // stage's top-left corner): the halo drifts to (1.12x, 1.12y) and back.
    final pulseOp = keyframe(t, 1.8, const [0, 0.5, 1], const [0.7, 1.0, 0.7]);
    final pulseScale = keyframe(t, 1.8, const [0, 0.5, 1], const [1.0, 1.12, 1.0]);
    {
      final cx = x, cy = y + 8, rx = r * 3.5, ry = r * 1.4;
      final m = Float64List(16)
        ..[0] = 1
        ..[5] = ry / rx
        ..[10] = 1
        ..[15] = 1
        ..[13] = cy - cy * ry / rx;
      final glow = Paint()
        ..shader = ui.Gradient.radial(
          Offset(cx, cy),
          rx,
          [
            _op(const Color(0xFFFF6600), 0.9),
            _op(const Color(0xFFFF4400), 0.5),
            _op(const Color(0xFFFF2200), 0),
          ],
          const [0, 0.5, 1],
          TileMode.clamp,
          m,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 22);
      final box = Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2);
      canvas.save();
      canvas.scale(pulseScale);
      canvas.saveLayer(box.inflate(22 * 3), Paint()..color = _op(_black, pulseOp));
      for (var i = 0; i < 3; i++) {
        canvas.drawOval(box, glow);
      }
      canvas.restore();
      canvas.restore();
    }

    // Ground scatter light
    _oval(canvas, x, y + 10, r * 2.2, r * 0.9, _fill(const Color(0xFFFF6600), 0.18));

    // Logs
    _rrect(canvas, x - r * 1.1, y + r * 0.6, r * 2.2, 5, 2.5, _fill(const Color(0xFF5A2E0A), 0.9));
    for (final (angle, color) in const [(40.0, Color(0xFF7A3A0C)), (-40.0, Color(0xFF6B3010))]) {
      canvas.save();
      canvas.translate(x, y + r * 0.6);
      canvas.rotate(angle * math.pi / 180);
      canvas.translate(-x, -(y + r * 0.6));
      _rrect(canvas, x - r * 0.7, y + r * 0.3, r * 1.4, 4, 2, _fill(color, 0.85));
      canvas.restore();
    }

    // Ember dots
    canvas.drawCircle(Offset(x - r * 0.5, y + r * 0.5), 2, _fill(const Color(0xFFFF8800), 0.9));
    canvas.drawCircle(Offset(x + r * 0.4, y + r * 0.6), 1.5, _fill(const Color(0xFFFFAA00), 0.8));
    canvas.drawCircle(Offset(x, y + r * 0.4), 2, _fill(const Color(0xFFFF6600), 0.9));

    // Flame layer 1 (back) — flameFlick2: scaleX + skewX, 0.9s
    final f1 = Path()
      ..moveTo(x - r * 0.7, y + r * 0.5)
      ..cubicTo(x - r * 0.5, y - r * 0.8, x + r * 0.1, y - r * 1.4, x, y - r * 2.2)
      ..cubicTo(x + r * 0.3, y - r * 1.2, x + r * 0.8, y - r * 0.6, x + r * 0.7, y + r * 0.5)
      ..close();
    const k2 = [0.0, 0.33, 0.66, 1.0];
    final sx2 = keyframe(t, 0.9, k2, const [1.0, 1.09, 0.92, 1.0]);
    final sk2 = keyframe(t, 0.9, k2, const [0.0, 5.0, -4.0, 0.0]);
    _withFlameTransform(canvas, f1.getBounds(), (c) {
      c.scale(sx2, 1);
      c.skew(math.tan(sk2 * math.pi / 180), 0);
    }, () => canvas.drawPath(f1, _fill(const Color(0xFFCC3300), 0.9)));

    // Flame layer 2 (mid) — flameFlick, 1.1s
    final f2 = Path()
      ..moveTo(x - r * 0.55, y + r * 0.5)
      ..cubicTo(x - r * 0.35, y - r * 0.6, x - r * 0.1, y - r * 1.6, x + r * 0.05, y - r * 2.6)
      ..cubicTo(x + r * 0.25, y - r * 1.5, x + r * 0.55, y - r * 0.5, x + r * 0.55, y + r * 0.5)
      ..close();
    const k1 = [0.0, 0.25, 0.5, 0.75, 1.0];
    final sx1 = keyframe(t, 1.1, k1, const [1.0, 0.90, 1.06, 0.94, 1.0]);
    final sy1 = keyframe(t, 1.1, k1, const [1.0, 1.07, 0.94, 1.05, 1.0]);
    _withFlameTransform(canvas, f2.getBounds(), (c) => c.scale(sx1, sy1),
        () => canvas.drawPath(f2, _fill(const Color(0xFFFF5500), 0.95)));

    // Flame layer 3 (front, yellow core) — flameFlick3, 1.3s
    final f3 = Path()
      ..moveTo(x - r * 0.3, y + r * 0.4)
      ..cubicTo(x - r * 0.15, y - r * 0.4, x + r * 0.05, y - r * 1.8, x + r * 0.05, y - r * 2.4)
      ..cubicTo(x + r * 0.2, y - r * 1.6, x + r * 0.3, y - r * 0.3, x + r * 0.3, y + r * 0.4)
      ..close();
    const k3 = [0.0, 0.4, 0.7, 1.0];
    final tx3 = keyframe(t, 1.3, k3, const [0.0, 2.0, -2.0, 0.0]);
    final sy3 = keyframe(t, 1.3, k3, const [1.0, 1.09, 0.94, 1.0]);
    _withFlameTransform(canvas, f3.getBounds(), (c) {
      c.translate(tx3, 0);
      c.scale(1, sy3);
    }, () => canvas.drawPath(f3, _fill(const Color(0xFFFFB300), 0.95)));

    // Flame tip — flameFlick
    final tip = Rect.fromCenter(
        center: Offset(x + r * 0.05, y - r * 2.0), width: r * 0.36, height: r * 0.6);
    _withFlameTransform(canvas, tip, (c) => c.scale(sx1, sy1),
        () => canvas.drawOval(tip, _fill(const Color(0xFFFFEE88), 0.8)));

    // Sparks — `translate(dx,dy) scale(s)` about the SVG origin (no
    // `transform-box`), so each spark streaks towards the stage's top-left
    // corner while it shrinks and fades.
    void spark(double cx, double cy, double rad, Color col, double dur, double delay,
        List<double> ops, List<double> dxs, List<double> dys, List<double> ss) {
      const at = [0.0, 0.5, 1.0];
      final o = keyframe(t, dur, at, ops, delay: delay, curve: Curves.easeOut);
      final dx = keyframe(t, dur, at, dxs, delay: delay, curve: Curves.easeOut);
      final dy = keyframe(t, dur, at, dys, delay: delay, curve: Curves.easeOut);
      final s = keyframe(t, dur, at, ss, delay: delay, curve: Curves.easeOut);
      canvas.drawCircle(Offset(dx + s * cx, dy + s * cy), rad * s, _fill(col, o));
    }

    const s1o = [0.9, 0.6, 0.0], s1x = [0.0, -4.0, -6.0], s1y = [0.0, -8.0, -16.0], s1s = [1.0, 0.7, 0.3];
    spark(x - r * 0.2, y - r * 2.8, 1.5, const Color(0xFFFFDD00), 1.6, 0, s1o, s1x, s1y, s1s);
    spark(x + r * 0.4, y - r * 2.2, 1, const Color(0xFFFF8800), 2.0, 0.4,
        const [0.8, 0.5, 0.0], const [0.0, 5.0, 8.0], const [0.0, -7.0, -14.0], const [1.0, 0.6, 0.2]);
    spark(x - r * 0.5, y - r * 1.8, 1.2, const Color(0xFFFFCC00), 1.8, 0.8,
        const [0.7, 0.4, 0.0], const [0.0, -3.0, -5.0], const [0.0, -10.0, -20.0], const [1.0, 0.5, 0.2]);
    spark(x + r * 0.2, y - r * 3.0, 0.8, const Color(0xFFFFE066), 1.6, 0, s1o, s1x, s1y, s1s);

    // Smoke wisps
    smokeWisp(
      canvas,
      Path()
        ..moveTo(x, y - r * 2.5)
        ..quadraticBezierTo(x - 8, y - r * 3.5, x + 4, y - r * 4.5),
      const Color(0xFF888888),
      2.5,
      t: t,
      duration: 3.0,
      at: const [0, 0.5, 1],
      opacity: const [0.22, 0.12, 0],
      dx: const [0, -4, -8],
      dy: const [0, -12, -26],
      sx: const [1, 1.3, 1.6],
    );
    smokeWisp(
      canvas,
      Path()
        ..moveTo(x + r * 0.2, y - r * 2.2)
        ..quadraticBezierTo(x + 10, y - r * 3.2, x - 5, y - r * 4.2),
      const Color(0xFFAAAAAA),
      1.8,
      t: t,
      duration: 3.5,
      delay: 0.7,
      idleOpacity: 0.12, // opacity="0.12" until the delayed animation starts
      at: const [0, 0.5, 1],
      opacity: const [0.16, 0.09, 0],
      dx: const [0, 5, 9],
      dy: const [0, -10, -22],
      sx: const [1, 1.2, 1.5],
    );
  }

  /// `transform-origin: center bottom; transform-box: fill-box`.
  void _withFlameTransform(
      Canvas canvas, Rect box, void Function(Canvas c) transform, void Function() draw) {
    final o = Offset(box.center.dx, box.bottom);
    canvas.save();
    canvas.translate(o.dx, o.dy);
    transform(canvas);
    canvas.translate(-o.dx, -o.dy);
    draw();
    canvas.restore();
  }

  @override
  bool shouldRepaint(ClassMathCampfirePainter old) => old.scene != scene || old.time != time;
}

/// A rising, fading smoke stroke (`smokeRise*` / `chimneySmoke*`):
/// `translate(dx,dy) scaleX(s)` about the SVG origin (the classes set no
/// `transform-box`), so the wisp also slides right by (s − 1) × its x.
void smokeWisp(
  Canvas canvas,
  Path path,
  Color color,
  double width, {
  required double t,
  required double duration,
  double delay = 0,
  double? idleOpacity,
  required List<double> at,
  required List<double> opacity,
  required List<double> dx,
  required List<double> dy,
  required List<double> sx,
}) {
  final o = keyframe(t, duration, at, opacity, delay: delay, curve: Curves.easeOut, idle: idleOpacity);
  final ox = keyframe(t, duration, at, dx, delay: delay, curve: Curves.easeOut);
  final oy = keyframe(t, duration, at, dy, delay: delay, curve: Curves.easeOut);
  final s = keyframe(t, duration, at, sx, delay: delay, curve: Curves.easeOut);
  canvas.save();
  canvas.translate(ox, oy);
  canvas.scale(s, 1);
  canvas.drawPath(path, _stroke(color, width, o: o, cap: StrokeCap.round));
  canvas.restore();
}

// ── 3. houses, barns, tents, banner ────────────────────────────────────────

class ClassMathFrontPainter extends CustomPainter {
  ClassMathFrontPainter(this.scene);
  final ClassMathScene scene;

  bool get _dark => scene.dark;
  Color _d(int dark, int light) => Color(_dark ? dark : light);

  @override
  void paint(Canvas canvas, Size size) {
    final shadow = _dark ? const Color.fromRGBO(0, 0, 0, 0.8) : const Color.fromRGBO(0, 0, 0, 0.22);

    for (final h in scene.houseItems) {
      final bounds = Rect.fromLTRB(h.x - 6, h.y - h.rh, h.x + h.w + 6, h.y + h.h + 16);
      _dropShadowGroup(canvas, bounds, const Offset(2, 4), 5, shadow, () => _house(canvas, h));
    }
    for (final b in scene.barnItems) {
      final bounds = Rect.fromLTRB(b.x - 4, b.y - b.rh, b.x + b.w + 4, b.y + b.h + 13);
      _dropShadowGroup(canvas, bounds, const Offset(2, 4), 5, shadow, () => _barn(canvas, b));
    }
    for (final t in scene.tentItems) {
      _tent(canvas, t);
    }
    if (scene.count > 0) _winBanner(canvas);
  }

  void _house(Canvas canvas, House h) {
    final p = h.palette;
    _oval(canvas, h.x + h.w * 0.5, h.y + h.h + 8, h.w * 0.5, 8, _fill(const Color.fromRGBO(0, 0, 0, 0.2)));
    _rrect(canvas, h.x, h.y, h.w, h.h, 3, _fill(_dark ? p.wallDark : p.wall));
    _rrect(canvas, h.x + h.w * 0.38, h.y + h.h * 0.55, h.w * 0.24, h.h * 0.45, 2,
        _fill(_dark ? const Color(0xFF0F172A) : p.door));

    // Windows — in dark mode they glow and pulse, see ClassMathLightsPainter.
    if (!_dark) {
      for (final wx in const [0.10, 0.65]) {
        final win = _ltwh(h.x + h.w * wx, h.y + h.h * 0.25, h.w * 0.25, h.w * 0.25);
        final rr = RRect.fromRectAndRadius(win, const Radius.circular(3));
        canvas.drawRRect(rr, _fill(const Color(0xFFA8D8F0)));
        canvas.drawRRect(rr, _stroke(const Color(0xFFFFFFFF), 2));
        _windowCross(canvas, win, const Color(0xFFFFFFFF));
      }
    }

    // Roof
    _poly(canvas, [Offset(h.x - 6, h.y), Offset(h.x + h.w / 2, h.y - h.rh), Offset(h.x + h.w + 6, h.y)],
        _fill(_dark ? p.roofDark : p.roof));
    // Chimney
    final chimney = _dark ? const Color(0xFF334155) : p.chimney;
    _rrect(canvas, h.x + h.w * 0.72, h.y - h.rh * 0.7, 10, 22, 2, _fill(chimney));
    _rrect(canvas, h.x + h.w * 0.72 - 2, h.y - h.rh * 0.7 - 4, 14, 5, 2, _fill(chimney));
  }

  void _barn(Canvas canvas, Barn b) {
    _oval(canvas, b.x + b.w * 0.5, b.y + b.h + 6, b.w * 0.5, 7, _fill(const Color.fromRGBO(0, 0, 0, 0.2)));
    _rrect(canvas, b.x, b.y, b.w, b.h, 3, _fill(_d(0xFF1E293B, 0xFFC83030)));
    // `rx="4 4 0 0"` is not a valid length → square corners.
    canvas.drawRect(_ltwh(b.x + b.w * 0.28, b.y + b.h * 0.40, b.w * 0.44, b.h * 0.60),
        _fill(_d(0xFFFFD060, 0xFF5A1A0A), _dark ? 0.45 : 1));
    _oval(canvas, b.x + b.w * 0.50, b.y + b.h * 0.40, b.w * 0.22, 10,
        _fill(_d(0xFFFFB300, 0xFF5A1A0A), _dark ? 0.5 : 1));
    final cross = _stroke(const Color(0xFFFFFFFF), 2, o: 0.3);
    canvas.drawLine(Offset(b.x + b.w * 0.28, b.y + b.h * 0.40), Offset(b.x + b.w * 0.72, b.y + b.h), cross);
    canvas.drawLine(Offset(b.x + b.w * 0.72, b.y + b.h * 0.40), Offset(b.x + b.w * 0.28, b.y + b.h), cross);
    _poly(canvas, [Offset(b.x - 4, b.y), Offset(b.x + b.w * 0.5, b.y - b.rh * 0.55), Offset(b.x + b.w + 4, b.y)],
        _fill(_d(0xFF334155, 0xFFCC2828)));
    _poly(
        canvas,
        [
          Offset(b.x + b.w * 0.18, b.y - b.rh * 0.55),
          Offset(b.x + b.w * 0.5, b.y - b.rh),
          Offset(b.x + b.w * 0.82, b.y - b.rh * 0.55),
        ],
        _fill(_d(0xFF1E293B, 0xFFAA2020)));
    _svgText(canvas, '✦', b.x + b.w * 0.5, b.y + b.h * 0.28, 14, _op(const Color(0xFFFFFFFF), 0.4),
        middle: true);
  }

  void _tent(Canvas canvas, Tent t) {
    _oval(canvas, t.x, t.y + 4, 28, 6, _fill(const Color.fromRGBO(0, 0, 0, 0.15)));
    final body = [Offset(t.x - 26, t.y + 4), Offset(t.x, t.y - 28), Offset(t.x + 26, t.y + 4)];
    _poly(canvas, body, _fill(_dark ? t.colDark : t.col));
    _poly(canvas, body, _fill(const Color.fromRGBO(255, 255, 255, 0.1)));
    _poly(canvas, [Offset(t.x - 8, t.y + 4), Offset(t.x, t.y - 10), Offset(t.x + 8, t.y + 4)],
        _dark ? _fill(const Color(0xFFFFD060), 0.45) : _fill(const Color.fromRGBO(0, 0, 0, 0.3)));
  }

  void _winBanner(Canvas canvas) {
    final w = scene.stageW, wy = scene.bannerY;
    final pole = _fill(_d(0xFF334155, 0xFFC8860A));
    _rrect(canvas, w * 0.18 - 4, wy - 10, 8, 80, 4, pole);
    _rrect(canvas, w * 0.82 - 4, wy - 10, 8, 80, 4, pole);
    canvas.drawPath(
      _dashed(Path()
        ..moveTo(w * 0.18, wy + 14)
        ..lineTo(w * 0.82, wy + 14), const [8, 6]),
      _stroke(_d(0xFF1E293B, 0xFF9B6F14), 2),
    );
    for (final bt in scene.buntings) {
      _poly(canvas, [bt.p1, bt.p2, bt.p3], _fill(bt.col, 0.95));
    }
    final board = RRect.fromRectAndRadius(_ltwh(w * 0.5 - 122, wy - 4, 244, 56), const Radius.circular(12));
    // fSoft: drop shadow 0 3 / blur 8
    canvas.drawRRect(
        board.shift(const Offset(0, 3)),
        Paint()
          ..color = _dark ? const Color.fromRGBO(0, 0, 0, 0.9) : const Color.fromRGBO(0, 0, 0, 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawRRect(board, _fill(_d(0xFF0F172A, 0xFFFFE082)));
    canvas.drawRRect(board, _stroke(_d(0xFF3B82F6, 0xFFC8860A), 2.5));
    final ribbon = _fill(_d(0xFF1E3A5F, 0xFFF5C040));
    _poly(canvas, [Offset(w * 0.5 - 122, wy - 4), Offset(w * 0.5 - 140, wy + 24), Offset(w * 0.5 - 122, wy + 52)], ribbon);
    _poly(canvas, [Offset(w * 0.5 + 122, wy - 4), Offset(w * 0.5 + 140, wy + 24), Offset(w * 0.5 + 122, wy + 52)], ribbon);
  }

  @override
  bool shouldRepaint(ClassMathFrontPainter old) => old.scene != scene;
}

/// The two window bars of a house window.
void _windowCross(Canvas canvas, Rect win, Color color) {
  final p = _stroke(color, 1.5);
  canvas.drawLine(Offset(win.center.dx, win.top), Offset(win.center.dx, win.bottom), p);
  canvas.drawLine(Offset(win.left, win.center.dy), Offset(win.right, win.center.dy), p);
}

// ── 4. lit windows + chimney smoke (dark mode) ─────────────────────────────

class ClassMathLightsPainter extends CustomPainter {
  ClassMathLightsPainter(this.scene, this.time) : super(repaint: time);
  final ClassMathScene scene;
  final ValueListenable<double> time;

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    final pulse = winPulse(t);
    for (final h in scene.houseItems) {
      for (final wx in const [0.10, 0.65]) {
        final win = _ltwh(h.x + h.w * wx, h.y + h.h * 0.25, h.w * 0.25, h.w * 0.25);
        final rr = RRect.fromRectAndRadius(win, const Radius.circular(3));
        canvas.drawRRect(
            rr,
            Paint()
              ..shader = ui.Gradient.radial(win.center, win.width / 2, [
                _op(const Color(0xFFFFF0A0), pulse),
                _op(const Color(0xFFFFD060), 0.9 * pulse),
                _op(const Color(0xFFFF9900), 0.4 * pulse),
              ], const [0, 0.6, 1]));
        canvas.drawRRect(rr, _stroke(const Color(0xFFFFD060), 1.5, o: pulse));
        // Inner ambient rect: its `opacity="0.18"` is overridden by the
        // winPulse animation, exactly as in the browser.
        canvas.drawRRect(RRect.fromRectAndRadius(win.inflate(2), const Radius.circular(3)),
            _fill(const Color(0xFFFFE088), pulse));
        _windowCross(canvas, win, const Color.fromRGBO(255, 220, 100, 0.55));
      }

      // Chimney smoke
      final cy = h.y - h.rh * 0.7;
      smokeWisp(
        canvas,
        Path()
          ..moveTo(h.x + h.w * 0.727, cy - 6)
          ..quadraticBezierTo(h.x + h.w * 0.7, cy - 22, h.x + h.w * 0.73, cy - 38),
        const Color(0xFF666666),
        3,
        t: t,
        duration: 4.0,
        at: const [0, 0.6, 1],
        opacity: const [0.2, 0.10, 0],
        dx: const [0, -5, -9],
        dy: const [0, -10, -20],
        sx: const [1, 1.4, 1.8],
      );
      smokeWisp(
        canvas,
        Path()
          ..moveTo(h.x + h.w * 0.733, cy - 6)
          ..quadraticBezierTo(h.x + h.w * 0.76, cy - 18, h.x + h.w * 0.72, cy - 32),
        const Color(0xFF888888),
        2,
        t: t,
        duration: 4.5,
        delay: 1.0,
        at: const [0, 0.6, 1],
        opacity: const [0.14, 0.07, 0],
        dx: const [0, 4, 7],
        dy: const [0, -8, -18],
        sx: const [1, 1.3, 1.7],
      );
    }
  }

  @override
  bool shouldRepaint(ClassMathLightsPainter old) => old.scene != scene || old.time != time;
}
