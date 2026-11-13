import 'dart:async';

import 'package:flutter/material.dart';

/// Tailwind box shadows with a custom colour (`shadow-xl shadow-primary/20`).
///
/// Note: in this web build every `shadow-*` resolves to the theme's black
/// shadow variables and colour modifiers have no effect, so the upgrade page
/// now uses `AppShadows`; kept for other callers.
class TwShadow {
  TwShadow._();
  static List<BoxShadow> sm(Color c) => [
        BoxShadow(color: c, blurRadius: 3, offset: const Offset(0, 1)),
        BoxShadow(color: c, blurRadius: 2, spreadRadius: -1, offset: const Offset(0, 1)),
      ];
  static List<BoxShadow> md(Color c) => [
        BoxShadow(color: c, blurRadius: 6, spreadRadius: -1, offset: const Offset(0, 4)),
        BoxShadow(color: c, blurRadius: 4, spreadRadius: -2, offset: const Offset(0, 2)),
      ];
  static List<BoxShadow> lg(Color c) => [
        BoxShadow(color: c, blurRadius: 15, spreadRadius: -3, offset: const Offset(0, 10)),
        BoxShadow(color: c, blurRadius: 6, spreadRadius: -4, offset: const Offset(0, 4)),
      ];
  static List<BoxShadow> xl(Color c) => [
        BoxShadow(color: c, blurRadius: 25, spreadRadius: -5, offset: const Offset(0, 20)),
        BoxShadow(color: c, blurRadius: 10, spreadRadius: -6, offset: const Offset(0, 8)),
      ];
}

/// Vue `<Transition mode="out-in">` with opacity + translate classes: the
/// old child leaves over [leave] (fading towards [leaveOffset]), then the
/// new one enters over [enter] (from [enterOffset]).
class OutInSwitcher extends StatelessWidget {
  const OutInSwitcher({
    super.key,
    required this.child,
    required this.enter,
    required this.leave,
    this.enterOffset = Offset.zero,
    this.leaveOffset = Offset.zero,
    this.expand = false,
  });

  final Widget child;
  final Duration enter;
  final Duration leave;
  final Offset enterOffset;
  final Offset leaveOffset;

  /// Fill the parent (views) instead of sizing to the child (inner content).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final total = enter + leave;
    final start = leave.inMicroseconds / total.inMicroseconds;
    return AnimatedSwitcher(
      duration: total,
      reverseDuration: leave,
      switchInCurve: Interval(start, 1, curve: Curves.easeOut),
      switchOutCurve: Curves.easeIn,
      layoutBuilder: (current, previous) => Stack(
        fit: expand ? StackFit.expand : StackFit.loose,
        alignment: Alignment.topCenter,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, animation) {
        final incoming = child.key == this.child.key;
        final offset = incoming ? enterOffset : leaveOffset;
        return AnimatedBuilder(
          animation: animation,
          child: child,
          builder: (context, c) => Opacity(
            opacity: animation.value.clamp(0.0, 1.0),
            child: Transform.translate(offset: offset * (1 - animation.value), child: c),
          ),
        );
      },
      child: child,
    );
  }
}

/// `animate-in fade-in slide-in-from-*` with an `animationDelay`.
class EntranceAnimation extends StatefulWidget {
  const EntranceAnimation({
    super.key,
    required this.child,
    this.offset = Offset.zero,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 500),
  });

  final Widget child;
  final Offset offset;
  final Duration delay;
  final Duration duration;

  @override
  State<EntranceAnimation> createState() => _EntranceAnimationState();
}

class _EntranceAnimationState extends State<EntranceAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.duration);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _c.forward();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _c.forward();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        final t = Curves.ease.transform(_c.value);
        return Opacity(
          opacity: t,
          child: Transform.translate(offset: widget.offset * (1 - t), child: child),
        );
      },
    );
  }
}

/// Tailwind `animate-bounce` (1 s, −25 % of the element's height).
class BounceAnimation extends StatefulWidget {
  const BounceAnimation({super.key, required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  @override
  State<BounceAnimation> createState() => _BounceAnimationState();
}

class _BounceAnimationState extends State<BounceAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));
  Timer? _timer;
  static const _down = Cubic(0.8, 0, 1, 1);
  static const _up = Cubic(0, 0, 0.2, 1);

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _c.repeat();
    } else {
      _timer = Timer(widget.delay, () {
        if (mounted) _c.repeat();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      child: widget.child,
      builder: (context, child) {
        if (!_c.isAnimating) return child!;
        final t = _c.value;
        final y = t < 0.5 ? -0.25 * (1 - _down.transform(t / 0.5)) : -0.25 * _up.transform((t - 0.5) / 0.5);
        return FractionalTranslation(translation: Offset(0, y), child: child);
      },
    );
  }
}

/// `animate-spin`.
class SpinAnimation extends StatefulWidget {
  const SpinAnimation({super.key, required this.child});
  final Widget child;

  @override
  State<SpinAnimation> createState() => _SpinAnimationState();
}

class _SpinAnimationState extends State<SpinAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(turns: _c, child: widget.child);
}

/// Tracks `:hover` (and `group-hover`) for a clickable area.
class HoverArea extends StatefulWidget {
  const HoverArea({super.key, required this.builder, this.onTap});
  final Widget Function(BuildContext context, bool hover) builder;
  final VoidCallback? onTap;

  @override
  State<HoverArea> createState() => _HoverAreaState();
}

class _HoverAreaState extends State<HoverArea> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: widget.builder(context, _hover),
      ),
    );
  }
}
