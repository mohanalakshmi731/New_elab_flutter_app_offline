import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../core/theme/app_theme.dart';

/// Port of `src/components/loader.vue` — the ELABS orbit loader: an indigo
/// "E LABS" ball with four orbits carrying the letters E / L / A / B, the
/// "ELABS" label and three pulsing dots (190×205).
///
/// Use [LoadingOverlay] to show it while a screen is `loading`.
class AppLoader extends StatefulWidget {
  const AppLoader({super.key, this.size = 190});

  /// Width of the loader box (the web's `.elabs-loader` is 190×205).
  final double size;

  @override
  State<AppLoader> createState() => _AppLoaderState();
}

class _AppLoaderState extends State<AppLoader> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _t = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) => setState(() => _t = elapsed.inMicroseconds / 1e6))..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  static const _brand = Color(0xFF5146E5);

  /// `font-family: Inter, Arial, sans-serif` on the ball and the letters.
  static const _inter = TextStyle(fontFamily: AppFonts.inter, fontFamilyFallback: ['Arial', 'sans-serif']);

  // Orbits: diameter, border colour, seconds per turn (negative = reverse),
  // letter, letter colour, letter side.
  static const _orbits = [
    (d: 128.0, border: Color(0x214F46E5), period: 4.0, letter: 'E', color: Color(0xFF5146E5), side: 0),
    (d: 148.0, border: Color(0x1C6366F1), period: -5.0, letter: 'L', color: Color(0xFF22A06B), side: 1),
    (d: 108.0, border: Color(0x1A22C55E), period: 3.5, letter: 'A', color: Color(0xFFEF6B5F), side: 2),
    (d: 164.0, border: Color(0x1AF59E0B), period: -6.0, letter: 'B', color: Color(0xFF2F80ED), side: 3),
  ];

  /// A CSS `0%,100% → a; 50% → b` keyframe pair with `ease-in-out`.
  static double _pingPong(double t, double period, double a, double b, {double delay = 0}) {
    final p = ((t - delay) % period) / period;
    final half = p < 0.5 ? p * 2 : (p - 0.5) * 2;
    final eased = Curves.easeInOut.transform(half);
    return p < 0.5 ? a + (b - a) * eased : b + (a - b) * eased;
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size / 190;
    final t = _t;
    const cx = 95.0;
    const cy = 205 * 0.42; // `top: 42%`
    final inter = _inter;

    Widget symbol(String letter, Color color) => Container(
          width: 28 * s,
          height: 28 * s,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0x144F46E5), width: s),
            boxShadow: [cssShadow(0, 5 * s, 14 * s, 0, const Color(0x1A000000))],
          ),
          child: Text(
            letter,
            style: inter.copyWith(fontSize: 11 * s, fontWeight: FontWeight.w800, color: color, height: 1),
          ),
        );

    final ballScale = _pingPong(t, 1.8, 1, 1.07);
    final logoScale = _pingPong(t, 1.8, 1, 1.04);
    final logoLift = _pingPong(t, 1.8, 0, 0.03); // translate(-50%, -53%)
    final hiOpacity = _pingPong(t, 2, 0.25, 0.45);
    final hiShift = _pingPong(t, 2, 0, 1);

    return SizedBox(
      width: 190 * s,
      height: 205 * s,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // ── Orbits (the letters ride on them, rotating with the ring) ──
          for (final o in _orbits)
            Positioned(
              left: (cx - o.d / 2) * s,
              top: (cy - o.d / 2) * s,
              width: o.d * s,
              height: o.d * s,
              child: Transform.rotate(
                angle: t / o.period * 2 * math.pi,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: o.border, width: s),
                        ),
                      ),
                    ),
                    Positioned(
                      left: switch (o.side) {
                        0 || 2 => (o.d / 2 - 14) * s,
                        1 => (o.d - 14) * s,
                        _ => -14 * s,
                      },
                      top: switch (o.side) {
                        0 => -14 * s,
                        2 => (o.d - 14) * s,
                        _ => (o.d / 2 - 14) * s,
                      },
                      child: symbol(o.letter, o.color),
                    ),
                  ],
                ),
              ),
            ),

          // ── The ball ──
          Positioned(
            left: (cx - 44) * s,
            top: (cy - 44) * s,
            width: 88 * s,
            height: 88 * s,
            child: Transform.scale(
              scale: ballScale,
              child: _Ball(
                s: s,
                highlightOpacity: hiOpacity,
                highlightShift: hiShift,
                logo: Transform.translate(
                  offset: Offset(0, -logoLift * 33 * s),
                  child: Transform.scale(
                    scale: logoScale,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('E',
                            style: inter.copyWith(
                                fontSize: 27 * s,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1 * s,
                                color: Colors.white,
                                height: 1.2)),
                        SizedBox(width: s),
                        Text('LABS',
                            style: inter.copyWith(
                                fontSize: 14 * s,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1 * s,
                                color: Colors.white,
                                height: 1.2)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── "ELABS" label ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 25 * s,
            child: Center(
              child: Text(
                'ELABS',
                style: TextStyle(
                  fontSize: 12 * s,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3 * s,
                  color: _brand,
                  height: 1.5,
                  shadows: [Shadow(color: const Color(0x1F4F46E5), offset: Offset(0, 2 * s), blurRadius: 8 * s)],
                ),
              ),
            ),
          ),

          // ── Loading dots ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 8 * s,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 3; i++) ...[
                  if (i > 0) SizedBox(width: 5 * s),
                  Opacity(
                    opacity: _pingPong(t, 1.2, 0.3, 1, delay: i * 0.15),
                    child: Transform.scale(
                      scale: _pingPong(t, 1.2, 0.7, 1.25, delay: i * 0.15),
                      child: Container(
                        width: 4 * s,
                        height: 4 * s,
                        decoration: const BoxDecoration(color: _brand, shape: BoxShape.circle),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// `.loader-ball`: 88px, `linear-gradient(145deg, #6366f1, #5146e5 45%,
/// #3730a3)`, indigo glow, a darker bottom half (`::after`), a blurred
/// moving highlight and the logo.
class _Ball extends StatelessWidget {
  const _Ball({required this.s, required this.highlightOpacity, required this.highlightShift, required this.logo});
  final double s;
  final double highlightOpacity;
  final double highlightShift;
  final Widget logo;

  @override
  Widget build(BuildContext context) {
    // border-radius: 50% 50% 48% 48%
    final radius = BorderRadius.only(
      topLeft: Radius.circular(44 * s),
      topRight: Radius.circular(44 * s),
      bottomLeft: Radius.circular(42.24 * s),
      bottomRight: Radius.circular(42.24 * s),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: radius,
        // CSS 145deg on a square: the gradient line runs corner-ward,
        // ~1.39× the half-size from the centre.
        gradient: const LinearGradient(
          begin: Alignment(-0.80, -1.14),
          end: Alignment(0.80, 1.14),
          colors: [Color(0xFF6366F1), Color(0xFF5146E5), Color(0xFF3730A3)],
          stops: [0, 0.45, 1],
        ),
        boxShadow: [cssShadow(0, 14 * s, 35 * s, 0, const Color(0x474F46E5))],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // ::after — bottom shade
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 34 * s,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(50 * s)),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x0AFFFFFF), Color(0x330F1750)],
                  ),
                ),
              ),
            ),
            // .ball-highlight
            Positioned(
              left: (16 + 5 * highlightShift) * s,
              top: (12 + 3 * highlightShift) * s,
              child: Opacity(
                opacity: highlightOpacity,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 3 * s, sigmaY: 3 * s),
                  child: Container(
                    width: 23 * s,
                    height: 23 * s,
                    decoration: const BoxDecoration(color: Color(0x4DFFFFFF), shape: BoxShape.circle),
                  ),
                ),
              ),
            ),
            logo,
          ],
        ),
      ),
    );
  }
}

/// `<Loader :loading="isLoading" />`. Like the web's `.loader-wrapper`
/// (`position: fixed; inset: 0; background: transparent;
/// pointer-events: none`), the loader floats in the middle of the window
/// without dimming or blocking the screen.
class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({super.key, required this.loading, required this.child});
  final bool loading;
  final Widget child;

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  final _portal = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    _portal.show();
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal(
      controller: _portal,
      overlayLocation: OverlayChildLocation.rootOverlay,
      overlayChildBuilder: (_) => widget.loading
          ? const Positioned.fill(child: IgnorePointer(child: Center(child: AppLoader())))
          : const SizedBox.shrink(),
      child: widget.child,
    );
  }
}
