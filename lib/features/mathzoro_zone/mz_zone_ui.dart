/// Widgets, painters and colours shared by the MathZoro Math Zone
/// (`studentmathzone.vue`) and Play Zone (`playzone.vue`) ports.
library;

import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// `color/xx` (Tailwind opacity modifier).
Color op(Color c, double alpha) => c.withValues(alpha: alpha);

const kWhite = Color(0xFFFFFFFF);
const kBlack = Color(0xFF000000);

/// Tailwind 4 `drop-shadow-md` (`0 3px 3px rgb(0 0 0 / 0.12)`) on text.
const kMzDropShadowMd = [Shadow(color: Color(0x1F000000), blurRadius: 3, offset: Offset(0, 3))];

// ── Hover / press ───────────────────────────────────────────────────────────

/// Pointer state for Tailwind `hover:` / `active:` variants.
class ZonePress extends StatefulWidget {
  const ZonePress({super.key, required this.builder, this.onTap, this.enabled = true});

  final Widget Function(BuildContext context, bool hovered, bool pressed) builder;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<ZonePress> createState() => _ZonePressState();
}

class _ZonePressState extends State<ZonePress> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.enabled && widget.onTap != null;
    final child = widget.builder(context, _hover, _down && active);
    return MouseRegion(
      cursor: active
          ? SystemMouseCursors.click
          : (widget.onTap != null ? SystemMouseCursors.forbidden : MouseCursor.defer),
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _down = false;
      }),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: active ? (_) => setState(() => _down = true) : null,
        onTapUp: active ? (_) => setState(() => _down = false) : null,
        onTapCancel: active ? () => setState(() => _down = false) : null,
        onTap: active ? widget.onTap : null,
        child: child,
      ),
    );
  }
}

// ── Spinner ─────────────────────────────────────────────────────────────────

/// `rounded-full border-[n] animate-spin` with a [track] colour and a
/// coloured top edge ([head]).
class ZoneRingSpinner extends StatefulWidget {
  const ZoneRingSpinner({
    super.key,
    required this.size,
    required this.stroke,
    required this.track,
    required this.head,
  });

  final double size;
  final double stroke;
  final Color track;
  final Color head;

  @override
  State<ZoneRingSpinner> createState() => _ZoneRingSpinnerState();
}

class _ZoneRingSpinnerState extends State<ZoneRingSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

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
      painter: _RingPainter(track: widget.track, head: widget.head, stroke: widget.stroke),
    ),
  );
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.track, required this.head, required this.stroke});
  final Color track;
  final Color head;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (Offset.zero & size).deflate(stroke / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    // border-top of a circle: the quarter between -135° and -45° in [head],
    // the other three sides in [track] (a transparent side stays empty).
    canvas.drawArc(r, -math.pi / 4, math.pi * 3 / 2, false, p..color = track);
    canvas.drawArc(r, -math.pi * 3 / 4, math.pi / 2, false, p..color = head);
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.track != track || old.head != head || old.stroke != stroke;
}

/// The `animate-spin` "loading" SVG of buttons
/// (`<circle opacity-25 stroke-width=4/>` + `<path opacity-75 d="M4 12a8 8 0 018-8v8z"/>`).
class ZoneButtonSpinner extends StatefulWidget {
  const ZoneButtonSpinner({super.key, required this.size, required this.color});
  final double size;
  final Color color;

  @override
  State<ZoneButtonSpinner> createState() => _ZoneButtonSpinnerState();
}

class _ZoneButtonSpinnerState extends State<ZoneButtonSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

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
      painter: _ButtonSpinnerPainter(widget.color),
    ),
  );
}

class _ButtonSpinnerPainter extends CustomPainter {
  _ButtonSpinnerPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.save();
    canvas.scale(s);
    canvas.drawCircle(
      const Offset(12, 12),
      10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = color.withValues(alpha: color.a * 0.25),
    );
    final path = Path()
      ..moveTo(4, 12)
      ..arcToPoint(const Offset(12, 4), radius: const Radius.circular(8))
      ..lineTo(12, 12)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: color.a * 0.75));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ButtonSpinnerPainter old) => old.color != color;
}

// ── Inline SVG icons ────────────────────────────────────────────────────────

/// Parses SVG path data (`M L H V C S Q T A Z`, absolute and relative,
/// compact arc flags such as `a2 2 0 012-2`). Results are cached by string.
Path zoneSvgPath(String d) => _svgPathCache[d] ??= _parseSvgPath(d);

final _svgPathCache = <String, Path>{};

Path _parseSvgPath(String d) {
  final p = Path();
  var i = 0;
  bool isSep(int c) => c == 32 || c == 44 || c == 9 || c == 10 || c == 13;
  void skip() {
    while (i < d.length && isSep(d.codeUnitAt(i))) {
      i++;
    }
  }

  bool atCommand() {
    skip();
    if (i >= d.length) return false;
    final c = d.codeUnitAt(i);
    return (c >= 65 && c <= 90 || c >= 97 && c <= 122) && c != 101 && c != 69;
  }

  double number() {
    skip();
    final start = i;
    if (i < d.length && (d[i] == '-' || d[i] == '+')) i++;
    var dot = false;
    while (i < d.length) {
      final c = d.codeUnitAt(i);
      if (c >= 48 && c <= 57) {
        i++;
      } else if (c == 46 && !dot) {
        dot = true;
        i++;
      } else if ((c == 101 || c == 69) && i > start) {
        i++;
        if (i < d.length && (d[i] == '-' || d[i] == '+')) i++;
      } else {
        break;
      }
    }
    return double.tryParse(d.substring(start, i)) ?? 0;
  }

  bool flag() {
    skip();
    return i < d.length && d[i++] == '1';
  }

  var cmd = '';
  var x = 0.0, y = 0.0, sx = 0.0, sy = 0.0;
  // Reflected control point for S / T.
  var cx = 0.0, cy = 0.0;
  var lastCubic = false, lastQuad = false;
  while (true) {
    skip();
    if (i >= d.length) break;
    if (atCommand()) {
      cmd = d[i++];
    } else if (cmd == 'M') {
      cmd = 'L';
    } else if (cmd == 'm') {
      cmd = 'l';
    } else if (cmd == 'Z' || cmd == 'z' || cmd.isEmpty) {
      break;
    }
    final rel = cmd == cmd.toLowerCase();
    final ox = rel ? x : 0.0, oy = rel ? y : 0.0;
    var cubic = false, quad = false;
    switch (cmd.toUpperCase()) {
      case 'M':
        x = ox + number();
        y = oy + number();
        sx = x;
        sy = y;
        p.moveTo(x, y);
      case 'L':
        x = ox + number();
        y = oy + number();
        p.lineTo(x, y);
      case 'H':
        x = ox + number();
        p.lineTo(x, y);
      case 'V':
        y = oy + number();
        p.lineTo(x, y);
      case 'C':
        final x1 = ox + number(), y1 = oy + number();
        cx = ox + number();
        cy = oy + number();
        x = ox + number();
        y = oy + number();
        p.cubicTo(x1, y1, cx, cy, x, y);
        cubic = true;
      case 'S':
        final x1 = lastCubic ? 2 * x - cx : x, y1 = lastCubic ? 2 * y - cy : y;
        cx = ox + number();
        cy = oy + number();
        x = ox + number();
        y = oy + number();
        p.cubicTo(x1, y1, cx, cy, x, y);
        cubic = true;
      case 'Q':
        cx = ox + number();
        cy = oy + number();
        x = ox + number();
        y = oy + number();
        p.quadraticBezierTo(cx, cy, x, y);
        quad = true;
      case 'T':
        cx = lastQuad ? 2 * x - cx : x;
        cy = lastQuad ? 2 * y - cy : y;
        x = ox + number();
        y = oy + number();
        p.quadraticBezierTo(cx, cy, x, y);
        quad = true;
      case 'A':
        final rx = number().abs(), ry = number().abs(), rot = number();
        final large = flag(), sweep = flag();
        x = ox + number();
        y = oy + number();
        p.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rot,
          largeArc: large,
          clockwise: sweep,
        );
      case 'Z':
        p.close();
        x = sx;
        y = sy;
      default:
        return p;
    }
    lastCubic = cubic;
    lastQuad = quad;
  }
  return p;
}

/// An inline `<svg viewBox="0 0 24 24" fill="none" stroke="currentColor"
/// stroke-width="…">` icon made of [paths] (or a `fill="currentColor"` one
/// with [filled]).
class ZoneSvgIcon extends StatelessWidget {
  const ZoneSvgIcon(
    this.paths, {
    super.key,
    required this.size,
    required this.color,
    this.strokeWidth = 2,
    this.filled = false,
    this.round = false,
    this.viewBox = 24,
  });

  final List<String> paths;
  final double size;
  final Color color;

  /// In viewBox units.
  final double strokeWidth;
  final bool filled;

  /// `stroke-linecap="round" stroke-linejoin="round"`.
  final bool round;
  final double viewBox;

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.square(size),
    painter: _SvgIconPainter(paths, color, strokeWidth, filled, round, viewBox),
  );
}

class _SvgIconPainter extends CustomPainter {
  _SvgIconPainter(this.paths, this.color, this.strokeWidth, this.filled, this.round, this.viewBox);
  final List<String> paths;
  final Color color;
  final double strokeWidth;
  final bool filled;
  final bool round;
  final double viewBox;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / viewBox;
    canvas.save();
    canvas.translate((size.width - viewBox * s) / 2, (size.height - viewBox * s) / 2);
    canvas.scale(s);
    final paint = Paint()..color = color;
    if (!filled) {
      paint
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = round ? StrokeCap.round : StrokeCap.butt
        ..strokeJoin = round ? StrokeJoin.round : StrokeJoin.miter;
    }
    for (final d in paths) {
      canvas.drawPath(zoneSvgPath(d), paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SvgIconPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.filled != filled ||
      old.round != round ||
      old.viewBox != viewBox ||
      !listEquals(old.paths, paths);
}

/// Heroicons (outline) path data used by the zone pages' inline SVGs.
class ZoneIcons {
  ZoneIcons._();

  static const flag =
      'M3 21v-4m0 0V5a2 2 0 012-2h6.5l1 1H21l-3 6 3 6H12.5l-1-1H5a2 2 0 00-2 2zm9-13.5V9';
  static const inbox =
      'M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5m16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293l-2.414-2.414A1 1 0 006.586 13H4';
  static const playTriangle =
      'M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z';
  static const circle = 'M21 12a9 9 0 11-18 0 9 9 0 0118 0z';
  static const documentText =
      'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z';
  static const lightBulb =
      'M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z';
  static const x = 'M6 18L18 6M6 6l12 12';
  static const warning =
      'M12 9v2m0 4h.01M10.29 3.86L1.82 18a2 2 0 001.71 3h16.94a2 2 0 001.71-3L13.71 3.86a2 2 0 00-3.42 0z';
  static const questionCircle =
      'M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 11-18 0 9 9 0 0118 0zm-9 5.25h.008v.008H12v-.008z';

  /// `<path d="M8 5v14l11-7z"/>` (filled play).
  static const play = 'M8 5v14l11-7z';
}

// ── Painters ────────────────────────────────────────────────────────────────

/// The star path used by the rating rows and the banner (`viewBox 0 0 24 24`).
final Path zoneStarPath = Path()
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

/// A star (`<svg viewBox="0 0 24 24"><path d="M12 2l3.09 …"/></svg>`).
class ZoneStarPainter extends CustomPainter {
  ZoneStarPainter({this.fill, required this.stroke, required this.strokeWidth, this.glow});
  final Color? fill;
  final Color stroke;

  /// In viewBox units.
  final double strokeWidth;

  /// `drop-shadow(0 0 3px color)`.
  final Color? glow;

  @override
  void paint(Canvas canvas, Size size) {
    final s = math.min(size.width, size.height) / 24;
    canvas.save();
    canvas.scale(s);
    final g = glow;
    if (g != null) {
      canvas.drawPath(
        zoneStarPath,
        Paint()
          ..color = g
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, 1.5 / s),
      );
    }
    final f = fill;
    if (f != null) canvas.drawPath(zoneStarPath, Paint()..color = f);
    canvas.drawPath(
      zoneStarPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeJoin = StrokeJoin.round
        ..strokeCap = StrokeCap.round
        ..color = stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(ZoneStarPainter old) =>
      old.fill != fill ||
      old.stroke != stroke ||
      old.glow != glow ||
      old.strokeWidth != strokeWidth;
}

/// A dot grid: one dot of [radius] centred in every [spacing]² tile
/// (`radial-gradient(color r, transparent r)` with `background-size`).
class ZoneDotGridPainter extends CustomPainter {
  ZoneDotGridPainter({required this.color, required this.spacing, required this.radius});
  final Color color;
  final double spacing;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = color;
    final half = spacing / 2;
    for (var y = half; y < size.height + half; y += spacing) {
      for (var x = half; x < size.width + half; x += spacing) {
        canvas.drawCircle(Offset(x, y), radius, p);
      }
    }
  }

  @override
  bool shouldRepaint(ZoneDotGridPainter old) =>
      old.color != color || old.spacing != spacing || old.radius != radius;
}

/// 1px grid lines every 40px (`linear-gradient(c 1px, transparent 1px)` ×2,
/// `background-size: 40px 40px`).
class ZoneGridPainter extends CustomPainter {
  ZoneGridPainter(this.color);
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
  bool shouldRepaint(ZoneGridPainter old) => old.color != color;
}

/// A blurred colour blob (`rounded-full blur-[n] opacity-x` or
/// `radial-gradient(circle, c 0%, transparent 70%)` + `filter: blur(n)`),
/// approximated with a radial gradient spread over the blur radius.
class ZoneGlow extends StatelessWidget {
  const ZoneGlow({
    super.key,
    required this.color,
    required this.diameter,
    required this.blur,
    this.opacity = 1,
    this.solid = true,
  });

  final Color color;
  final double diameter;
  final double blur;
  final double opacity;

  /// `true`: a solid disc; `false`: a `radial-gradient(… 0%, transparent 70%)`.
  final bool solid;

  /// Total painted size (disc plus blur spread on both sides).
  double get extent => diameter + blur * 2;

  @override
  Widget build(BuildContext context) {
    final r = extent / 2;
    final c = color.withValues(alpha: color.a * opacity);
    final innerStop = solid ? ((diameter / 2 - blur) / r).clamp(0.0, 1.0) : 0.0;
    return SizedBox(
      width: extent,
      height: extent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: solid
                ? [c, c, c.withValues(alpha: 0)]
                : [
                    c.withValues(alpha: c.a * 0.55),
                    c.withValues(alpha: c.a * 0.25),
                    c.withValues(alpha: 0),
                  ],
            stops: solid ? [0, innerStop, 1] : const [0, 0.45, 1],
          ),
        ),
      ),
    );
  }
}

// ── Teleported modals ───────────────────────────────────────────────────────

/// How a modal animates in/out.
enum ZoneModalTransition {
  /// `.modal-fade`: opacity + scale(.96); translateY(40px) below 640px.
  fade,

  /// playzone's unlock modal: backdrop fades, panel opacity + scale(.9) +
  /// translateY(16px).
  pop,
}

/// Shows a `fixed inset-0` overlay whose open state lives in [state] (the
/// component's `xModal.open` flag). The route closes itself as soon as
/// [isOpen] turns false; the backdrop / Escape / system back call
/// [onDismiss], which decides whether to close (like `@click.self`).
Future<void> showZoneModal<T>(
  BuildContext context, {
  required ValueListenable<T> state,
  required bool Function(T value) isOpen,
  required VoidCallback onDismiss,
  required Widget Function(BuildContext context, T value) builder,
  ZoneModalTransition transition = ZoneModalTransition.fade,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.transparent,
    transitionDuration: Duration(milliseconds: transition == ZoneModalTransition.fade ? 250 : 200),
    pageBuilder: (dialogContext, _, _) =>
        _ZoneModalHost<T>(state: state, isOpen: isOpen, onDismiss: onDismiss, builder: builder),
    transitionBuilder: (dialogContext, anim, _, child) {
      final forward = anim.status != AnimationStatus.reverse;
      final t = (forward ? Curves.easeOut : Curves.easeIn).transform(anim.value);
      if (transition == ZoneModalTransition.fade) {
        return Opacity(
          opacity: t,
          child: MediaQuery.sizeOf(dialogContext).width >= 640
              ? Transform.scale(scale: 0.96 + 0.04 * t, child: child)
              : Transform.translate(offset: Offset(0, 40 * (1 - t)), child: child),
        );
      }
      return _PopTransition(t: t, child: child);
    },
  ).then((_) {
    // Popped by something else (e.g. a route reset): keep the flag in sync.
    if (isOpen(state.value)) onDismiss();
  });
}

/// Hands the panel's own fade/scale to [ZoneModalScaffold] through an
/// inherited value so that only the panel (not the backdrop) scales.
class _PopTransition extends InheritedWidget {
  const _PopTransition({required this.t, required super.child});
  final double t;

  static double? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_PopTransition>()?.t;

  @override
  bool updateShouldNotify(_PopTransition old) => old.t != t;
}

class _ZoneModalHost<T> extends StatefulWidget {
  const _ZoneModalHost({
    required this.state,
    required this.isOpen,
    required this.onDismiss,
    required this.builder,
  });

  final ValueListenable<T> state;
  final bool Function(T value) isOpen;
  final VoidCallback onDismiss;
  final Widget Function(BuildContext context, T value) builder;

  @override
  State<_ZoneModalHost<T>> createState() => _ZoneModalHostState<T>();
}

class _ZoneModalHostState<T> extends State<_ZoneModalHost<T>> {
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.state.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (!mounted) return;
    if (!widget.isOpen(widget.state.value)) {
      _close();
    } else {
      setState(() {});
    }
  }

  void _close() {
    if (_closing) return;
    final route = ModalRoute.of(context);
    if (route == null || !route.isActive) return;
    _closing = true;
    final nav = Navigator.of(context);
    if (route.isCurrent) {
      nav.pop();
    } else {
      nav.removeRoute(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) widget.onDismiss();
      },
      child: _ZoneModalDismiss(
        onDismiss: widget.onDismiss,
        child: widget.builder(context, widget.state.value),
      ),
    );
  }
}

/// Gives [ZoneModalScaffold] access to the host's dismiss callback.
class _ZoneModalDismiss extends InheritedWidget {
  const _ZoneModalDismiss({required this.onDismiss, required super.child});
  final VoidCallback onDismiss;

  static VoidCallback? of(BuildContext context) =>
      context.getInheritedWidgetOfExactType<_ZoneModalDismiss>()?.onDismiss;

  @override
  bool updateShouldNotify(_ZoneModalDismiss old) => false;
}

/// The `fixed inset-0 … flex items-* justify-center` wrapper of a modal: the
/// tinted / blurred backdrop (tap = `@click.self`) and the aligned panel.
class ZoneModalScaffold extends StatelessWidget {
  const ZoneModalScaffold({
    super.key,
    required this.backdrop,
    required this.blur,
    required this.alignment,
    required this.padding,
    required this.maxWidth,
    required this.child,
  });

  final Color backdrop;
  final double blur;
  final AlignmentGeometry alignment;
  final EdgeInsets padding;
  final double maxWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dismiss = _ZoneModalDismiss.of(context);
    final pop = _PopTransition.of(context);
    Widget panel = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    );
    if (pop != null) {
      panel = Opacity(
        opacity: pop,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - pop)),
          child: Transform.scale(scale: 0.9 + 0.1 * pop, child: panel),
        ),
      );
    }
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: dismiss,
              child: Opacity(
                opacity: pop == null ? 1 : pop.clamp(0.0, 1.0),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                  child: ColoredBox(color: backdrop),
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: padding.bottom > 0,
            child: Padding(
              padding: padding,
              child: Align(
                alignment: alignment,
                // Taps on the panel must not reach the backdrop.
                child: GestureDetector(onTap: () {}, child: panel),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
