import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// shadcn `<Skeleton>`: `animate-pulse rounded-md bg-primary/10`.
class Skeleton extends StatefulWidget {
  const Skeleton({super.key, this.width, this.height = 16, this.radius = 14, this.circle = false});

  final double? width;
  final double height;
  final double radius;
  final bool circle;

  @override
  State<Skeleton> createState() => _SkeletonState();
}

class _SkeletonState extends State<Skeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static const _pulse = Cubic(0.4, 0, 0.6, 1);

  @override
  Widget build(BuildContext context) {
    final base = context.colors.primary.withValues(alpha: 0.10);
    return FadeTransition(
      // Tailwind animate-pulse: opacity 1 → .5 → 1 over 2s, cubic-bezier(.4,0,.6,1).
      opacity: TweenSequence<double>([
        TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5).chain(CurveTween(curve: _pulse)), weight: 1),
        TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0).chain(CurveTween(curve: _pulse)), weight: 1),
      ]).animate(_c),
      child: Container(
        width: widget.circle ? widget.height : widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: base,
          shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: widget.circle ? null : BorderRadius.circular(widget.radius.clamp(0, widget.height / 2)),
        ),
      ),
    );
  }
}
