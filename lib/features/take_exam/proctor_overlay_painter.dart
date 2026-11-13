import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'proctor_logic.dart';

/// What `drawOverlay(data)` last drew: the boxes in capture-frame pixels and
/// the canvas size (`captureSize`).
class OverlaySnapshot {
  const OverlaySnapshot({required this.width, required this.height, required this.boxes});
  final int width;
  final int height;
  final List<OverlayBox> boxes;
}

/// The `<canvas ref="overlay">` laid over the camera preview. The web canvas
/// has the capture size as its bitmap and is stretched over the video box
/// (`absolute inset-0 h-full w-full`), so the drawing is scaled the same way.
///
/// `drawBoxes`: 3 px stroke, label `"<class> <confidence>"` in a 22 px tall
/// filled tab above the box, white 13 px text.
class ProctorOverlayPainter extends CustomPainter {
  const ProctorOverlayPainter(this.snapshot);

  final OverlaySnapshot? snapshot;

  @override
  void paint(Canvas canvas, Size size) {
    final s = snapshot;
    if (s == null || s.width <= 0 || s.height <= 0 || s.boxes.isEmpty) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    canvas.scale(size.width / s.width, size.height / s.height);

    for (final item in s.boxes) {
      final x = item.bbox[0], y = item.bbox[1], w = item.bbox[2], h = item.bbox[3];
      final color = Color(item.color);
      canvas.drawRect(
        Rect.fromLTWH(x, y, w, h),
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );

      final text = TextPainter(
        text: TextSpan(
          text: item.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontFamily: 'Inter',
            fontFamilyFallback: ['sans-serif'],
          ),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      final textWidth = text.width + 10;
      canvas.drawRect(Rect.fromLTWH(x, math.max(0, y - 22), textWidth, 22), Paint()..color = color);
      // fillText(label, x + 5, max(14, y - 7)) — y is the alphabetic baseline.
      final baseline = math.max(14.0, y - 7);
      final ascent = text.computeDistanceToActualBaseline(TextBaseline.alphabetic);
      text.paint(canvas, Offset(x + 5, baseline - ascent));
      text.dispose();
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ProctorOverlayPainter oldDelegate) =>
      oldDelegate.snapshot != snapshot;
}
