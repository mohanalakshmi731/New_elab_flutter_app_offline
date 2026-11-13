/// Small widgets shared by `/mathplay` and `/classmath`: Tailwind's easing
/// curves, the `animate-spin` spinners, `active:scale-95` press feedback and
/// the inline `<svg>` icons of the two templates.
library;

import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Tailwind v4 `transition` default timing / `ease-in-out`
/// (`cubic-bezier(0.4, 0, 0.2, 1)`).
const Curve kTwEase = Cubic(0.4, 0, 0.2, 1);

/// Tailwind v4 `ease-out` (`cubic-bezier(0, 0, 0.2, 1)`).
const Curve kTwEaseOut = Cubic(0, 0, 0.2, 1);

/// Tailwind v4 `ease-in` (`cubic-bezier(0.4, 0, 1, 1)`).
const Curve kTwEaseIn = Cubic(0.4, 0, 1, 1);

/// Line height of Tailwind's font-size utilities (`text-xs` … `text-xl`).
abstract final class TwLeading {
  static const xs = 16 / 12;
  static const sm = 20 / 14;
  static const base = 24 / 16;
  static const lg = 28 / 18;
  static const xl = 28 / 20;
}

/// `rounded-full border-[n] animate-spin` with a [track] colour on every side
/// and a [head] colour on the top side (`border-t-*`), turning once a second.
class BorderSpinner extends StatefulWidget {
  const BorderSpinner({
    super.key,
    required this.size,
    required this.stroke,
    required this.track,
    required this.head,
    this.spinTrack = true,
  });

  final double size;
  final double stroke;
  final Color track;
  final Color head;

  /// False when the track is a separate, static element (only the head turns).
  final bool spinTrack;

  @override
  State<BorderSpinner> createState() => _BorderSpinnerState();
}

class _BorderSpinnerState extends State<BorderSpinner> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = Size.square(widget.size);
    final head = RotationTransition(
      turns: _c,
      child: CustomPaint(
        size: size,
        painter: _BorderRingPainter(
            track: widget.spinTrack ? widget.track : Colors.transparent, head: widget.head, stroke: widget.stroke),
      ),
    );
    if (widget.spinTrack) return head;
    return Stack(children: [
      CustomPaint(
          size: size,
          painter: _BorderRingPainter(track: widget.track, head: Colors.transparent, stroke: widget.stroke)),
      head,
    ]);
  }
}

class _BorderRingPainter extends CustomPainter {
  _BorderRingPainter({required this.track, required this.head, required this.stroke});
  final Color track;
  final Color head;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final r = (Offset.zero & size).deflate(stroke / 2);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    if (track.a > 0) canvas.drawOval(r, p..color = track);
    // The top border of a circle: the quarter between -135° and -45°.
    if (head.a > 0) canvas.drawArc(r, -math.pi * 3 / 4, math.pi / 2, false, p..color = head);
  }

  @override
  bool shouldRepaint(_BorderRingPainter old) => old.track != track || old.head != head || old.stroke != stroke;
}

/// The buttons' `animate-spin` SVG:
/// `<circle r=10 stroke-width=4 opacity-25/>` + `<path opacity-75 d="M4 12a8 8 0 018-8v8z"/>`.
class SvgSpinner extends StatefulWidget {
  const SvgSpinner({super.key, required this.size, required this.color});
  final double size;
  final Color color;

  @override
  State<SvgSpinner> createState() => _SvgSpinnerState();
}

class _SvgSpinnerState extends State<SvgSpinner> with SingleTickerProviderStateMixin {
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
        child: CustomPaint(size: Size.square(widget.size), painter: _SvgSpinnerPainter(widget.color)),
      );
}

class _SvgSpinnerPainter extends CustomPainter {
  _SvgSpinnerPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24);
    canvas.drawCircle(
      const Offset(12, 12),
      10,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = color.withValues(alpha: color.a * 0.25),
    );
    final wedge = Path()
      ..moveTo(4, 12)
      ..arcToPoint(const Offset(12, 4), radius: const Radius.circular(8))
      ..lineTo(12, 12)
      ..close();
    canvas.drawPath(wedge, Paint()..color = color.withValues(alpha: color.a * 0.75));
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SvgSpinnerPainter old) => old.color != color;
}

/// [builder] gets the `:hover` and `:active` states. Without [onTap] the
/// child is not clickable (a `disabled` button) and never "active".
class PressHover extends StatefulWidget {
  const PressHover({super.key, required this.builder, this.onTap, this.cursor});
  final Widget Function(BuildContext context, bool hovered, bool pressed) builder;
  final VoidCallback? onTap;
  final MouseCursor? cursor;

  @override
  State<PressHover> createState() => _PressHoverState();
}

class _PressHoverState extends State<PressHover> {
  bool _hover = false;
  bool _pressed = false;

  void _press(bool v) {
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    final child = widget.builder(context, _hover, enabled && _pressed);
    return MouseRegion(
      cursor: widget.cursor ?? (enabled ? SystemMouseCursors.click : MouseCursor.defer),
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: !enabled
          ? child
          : GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapDown: (_) => _press(true),
              onTapUp: (_) => _press(false),
              onTapCancel: () => _press(false),
              onTap: widget.onTap,
              child: child,
            ),
    );
  }
}

/// `active:scale-95` with the `transition-all duration-150` easing.
class ActiveScale extends StatelessWidget {
  const ActiveScale({super.key, required this.pressed, required this.child, this.scale = 0.95});
  final bool pressed;
  final double scale;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedScale(
        scale: pressed ? scale : 1,
        duration: const Duration(milliseconds: 150),
        curve: kTwEase,
        child: child,
      );
}

/// The inline `<svg viewBox="0 0 24 24">` icons of the two templates.
enum SvgGlyph {
  /// `<rect x=3 y=3 w=18 h=18 rx=2/><circle 8.5 8.5 r1.5/><polyline 21 15 16 10 5 21/>`.
  image,

  /// `<circle r=10/><line 12,8→12,12/><line 12,16→12.01,16/>` (butt caps, so
  /// the dot is invisible).
  alertCircle,

  /// `<circle r=10/><path d="M9.09 9a3 3 0 0 1 5.83 1c0 2-3 3-3 3"/>` (+ an
  /// invisible butt-capped dot).
  helpCircle,

  /// `<polygon points="5 3 19 12 5 21 5 3" fill="currentColor"/>`.
  play,
}

class SvgIcon extends StatelessWidget {
  const SvgIcon(this.glyph, {super.key, required this.size, required this.color, this.strokeWidth = 2});
  final SvgGlyph glyph;
  final double size;
  final Color color;

  /// In view-box units.
  final double strokeWidth;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _SvgIconPainter(glyph, color, strokeWidth));
}

class _SvgIconPainter extends CustomPainter {
  _SvgIconPainter(this.glyph, this.color, this.stroke);
  final SvgGlyph glyph;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24);
    final p = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    switch (glyph) {
      case SvgGlyph.image:
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTWH(3, 3, 18, 18), const Radius.circular(2)), p);
        canvas.drawCircle(const Offset(8.5, 8.5), 1.5, p);
        canvas.drawPath(
            Path()
              ..moveTo(21, 15)
              ..lineTo(16, 10)
              ..lineTo(5, 21),
            p);
      case SvgGlyph.alertCircle:
        canvas.drawCircle(const Offset(12, 12), 10, p);
        canvas.drawLine(const Offset(12, 8), const Offset(12, 12), p);
      case SvgGlyph.helpCircle:
        canvas.drawCircle(const Offset(12, 12), 10, p);
        canvas.drawPath(
            Path()
              ..moveTo(9.09, 9)
              ..arcToPoint(const Offset(14.92, 10), radius: const Radius.circular(3))
              ..cubicTo(14.92, 12, 11.92, 13, 11.92, 13),
            p);
      case SvgGlyph.play:
        canvas.drawPath(
            Path()
              ..moveTo(5, 3)
              ..lineTo(19, 12)
              ..lineTo(5, 21)
              ..close(),
            Paint()..color = color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SvgIconPainter old) => old.glyph != glyph || old.color != color || old.stroke != stroke;
}
