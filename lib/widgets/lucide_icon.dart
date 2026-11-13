import 'package:flutter/material.dart';

/// The few lucide icons the shadcn kit draws itself (select chevron, check,
/// dialog close X, pagination chevrons), painted like lucide's SVGs:
/// 24×24 view box, 2px round stroke, scaled to [LucideIcon.size].
enum Lucide { chevronDown, chevronUp, chevronLeft, chevronRight, check, x, moreHorizontal }

class LucideIcon extends StatelessWidget {
  const LucideIcon(this.icon, {super.key, this.size = 16, this.color, this.strokeWidth = 2});

  final Lucide icon;

  /// `size-4` = 16.
  final double size;

  /// Defaults to the ambient [IconTheme] colour.
  final Color? color;

  /// In view-box units (lucide default 2).
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? DefaultTextStyle.of(context).style.color ?? Colors.black;
    return CustomPaint(size: Size.square(size), painter: _LucidePainter(icon, c, strokeWidth));
  }
}

class _LucidePainter extends CustomPainter {
  _LucidePainter(this.icon, this.color, this.stroke);
  final Lucide icon;
  final Color color;
  final double stroke;

  static const _paths = <Lucide, List<List<Offset>>>{
    Lucide.chevronDown: [
      [Offset(6, 9), Offset(12, 15), Offset(18, 9)],
    ],
    Lucide.chevronUp: [
      [Offset(18, 15), Offset(12, 9), Offset(6, 15)],
    ],
    Lucide.chevronLeft: [
      [Offset(15, 18), Offset(9, 12), Offset(15, 6)],
    ],
    Lucide.chevronRight: [
      [Offset(9, 18), Offset(15, 12), Offset(9, 6)],
    ],
    Lucide.check: [
      [Offset(20, 6), Offset(9, 17), Offset(4, 12)],
    ],
    Lucide.x: [
      [Offset(18, 6), Offset(6, 18)],
      [Offset(6, 6), Offset(18, 18)],
    ],
  };

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (icon == Lucide.moreHorizontal) {
      for (final x in const [5.0, 12.0, 19.0]) {
        canvas.drawCircle(Offset(x * s, 12 * s), 1 * s, paint);
      }
      return;
    }
    for (final line in _paths[icon]!) {
      final path = Path()..moveTo(line.first.dx * s, line.first.dy * s);
      for (final p in line.skip(1)) {
        path.lineTo(p.dx * s, p.dy * s);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_LucidePainter old) => old.icon != icon || old.color != color || old.stroke != stroke;
}
