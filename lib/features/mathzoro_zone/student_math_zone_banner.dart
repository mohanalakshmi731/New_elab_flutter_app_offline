part of 'student_math_zone_page.dart';

typedef _TextFn =
    TextStyle Function(
      double size,
      FontWeight weight,
      Color? color, {
      double? height,
      double? spacing,
      List<Shadow>? shadows,
    });

/// ══ HEADER / BANNER ══ — 142px rounded banner with the drifting glows,
/// floating outline icons, the "Interactive Playground" eyebrow and the
/// optional Back pill.
class _MzBanner extends StatefulWidget {
  const _MzBanner({
    required this.isMath,
    required this.accent,
    required this.accentSecondary,
    required this.showBack,
    required this.onBack,
    required this.text,
  });

  final bool isMath;
  final Color accent;
  final Color accentSecondary;
  final bool showBack;
  final VoidCallback onBack;
  final _TextFn text;

  @override
  State<_MzBanner> createState() => _MzBannerState();
}

class _MzBannerState extends State<_MzBanner> with SingleTickerProviderStateMixin {
  /// One clock for every keyframe animation (40s = LCM of 8s, 10s, 4s, 2s).
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 40),
  )..repeat();

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  double get _seconds => _clock.value * 40;

  /// `0%,100% → a; 50% → b` with `ease-in-out` on each half.
  static double _pingPong(double seconds, double period) {
    final p = (seconds % period) / period;
    final half = p < 0.5 ? p / 0.5 : (1 - p) / 0.5;
    return Curves.easeInOut.transform(half.clamp(0.0, 1.0));
  }

  /// `@keyframes float-icon` (4s) with an `animation-delay`.
  Matrix4 _float(double delay) {
    final e = _pingPong(_seconds - delay + 40, 4);
    return Matrix4.translationValues(0, -15 * e, 0)..rotateZ(5 * math.pi / 180 * e);
  }

  @override
  Widget build(BuildContext context) {
    final sm = context.isSm;
    final md = context.isMd;
    final px = md ? 48.0 : (sm ? 32.0 : 24.0);
    final t = widget.text;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: Container(
          height: 142,
          color: widget.isMath ? const Color(0xFF3A2E00) : const Color(0xFF003A1D),
          child: AnimatedBuilder(
            animation: _clock,
            builder: (context, _) {
              final s = _seconds;
              final d1 = _pingPong(s, 8);
              final d2 = _pingPong(s, 10);
              final pulse = _pingPong(s, 2);
              return Stack(
                clipBehavior: Clip.hardEdge,
                children: [
                  // .pattern-overlay (opacity .5)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: ZoneDotGridPainter(
                        color: Colors.white.withValues(alpha: 0.05),
                        spacing: 30,
                        radius: 2,
                      ),
                    ),
                  ),
                  // .banner-glow-1 — 400px at top:-150 left:-100, drift1 8s
                  Positioned(
                    left: -100 - 80,
                    top: -150 - 80,
                    child: Transform.translate(
                      offset: Offset(30 * d1, -20 * d1),
                      child: Transform.scale(
                        scale: 1 + 0.1 * d1,
                        child: IgnorePointer(
                          child: ZoneGlow(
                            color: widget.accent,
                            diameter: 400,
                            blur: 80,
                            solid: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // .banner-glow-2 — 350px at bottom:-150 right:-50, drift2 10s
                  Positioned(
                    right: -50 - 80,
                    bottom: -150 - 80,
                    child: Transform.translate(
                      offset: Offset(-40 * d2, 30 * d2),
                      child: Transform.scale(
                        scale: 1.2 - 0.3 * d2,
                        child: IgnorePointer(
                          child: ZoneGlow(
                            color: widget.accentSecondary,
                            diameter: 350,
                            blur: 80,
                            solid: false,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Floating outline icons (opacity-20)
                  Positioned(
                    right: 40,
                    top: 0,
                    bottom: 0,
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: 0.2,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform(
                              alignment: Alignment.center,
                              transform: _float(0),
                              child: CustomPaint(
                                size: const Size.square(64),
                                painter: ZoneStarPainter(stroke: Colors.white, strokeWidth: 1.5),
                              ),
                            ),
                            if (sm) ...[
                              const SizedBox(width: 24),
                              Transform(
                                alignment: Alignment.center,
                                transform: _float(1),
                                child: CustomPaint(
                                  size: const Size.square(48),
                                  painter: _OutlineIconPainter.dashedCircle(),
                                ),
                              ),
                            ],
                            if (md) ...[
                              const SizedBox(width: 24),
                              Transform(
                                alignment: Alignment.center,
                                transform: _float(2),
                                child: CustomPaint(
                                  size: const Size.square(80),
                                  painter: _OutlineIconPainter.square(),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Content
                  Positioned.fill(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: px),
                      child: Row(
                        children: [
                          _iconBox(sm),
                          SizedBox(width: sm ? 24 : 16),
                          Expanded(child: _titles(sm, md, pulse, t)),
                        ],
                      ),
                    ),
                  ),
                  if (widget.showBack)
                    Positioned(top: sm ? 20 : 16, right: sm ? 24 : 16, child: _backButton(sm, t)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _iconBox(bool sm) {
    final size = sm ? 80.0 : 56.0;
    final radius = BorderRadius.circular(sm ? 24 : 20);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: radius,
        // shadow-lg (the theme's light value)
        boxShadow: AppShadows.lg,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.2),
              borderRadius: radius,
              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
            ),
            alignment: Alignment.center,
            child: CustomPaint(
              size: Size.square(sm ? 40 : 28),
              painter: widget.isMath ? _OutlineIconPainter.mathList() : _OutlineIconPainter.table(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _titles(bool sm, bool md, double pulse, _TextFn t) {
    final dot = sm ? 10.0 : 8.0;
    final h1Size = md ? 48.0 : (sm ? 36.0 : 24.0);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // animate-pulse: opacity 1 → .5 → 1 (2s)
            Opacity(
              opacity: 1 - 0.5 * pulse,
              child: Container(
                width: dot,
                height: dot,
                decoration: BoxDecoration(
                  color: Tw.rose500,
                  shape: BoxShape.circle,
                  // shadow-[0_0_10px_#f43f5e]
                  boxShadow: [cssShadow(0, 0, 10, 0, const Color(0xFFF43F5E))],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                'INTERACTIVE PLAYGROUND',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t(
                  sm ? 12 : 10,
                  FontWeight.w900,
                  Colors.white.withValues(alpha: 0.8),
                  height: sm ? 16 / 12 : 1.5,
                  spacing: (sm ? 12 : 10) * 0.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Math Zone',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          softWrap: false,
          style: t(
            h1Size,
            FontWeight.w900,
            Colors.white,
            height: 1.25,
            spacing: -0.025 * h1Size,
            // drop-shadow-md (Tailwind 4: 0 3px 3px rgb(0 0 0 / .12))
            shadows: kMzDropShadowMd,
          ),
        ),
      ],
    );
  }

  Widget _backButton(bool sm, _TextFn t) => ZonePress(
    onTap: widget.onBack,
    builder: (context, hover, _) => AnimatedScale(
      scale: hover ? 1.05 : 1,
      duration: const Duration(milliseconds: 150),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: sm ? 16 : 12, vertical: sm ? 8 : 6),
        decoration: BoxDecoration(
          color: hover ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
        ),
        // One text-xs / sm:text-sm line (16 / 20px).
        constraints: BoxConstraints(minHeight: (sm ? 20 : 16) + (sm ? 16 : 12) + 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              BootstrapIcons.chevron_left,
              size: sm ? 14 : 12,
              color: Colors.white.withValues(alpha: 0.8),
            ),
            if (sm) ...[
              const SizedBox(width: 8),
              Text(
                'Back',
                style: t(14, FontWeight.w600, Colors.white.withValues(alpha: 0.8), height: 20 / 14),
              ),
            ],
          ],
        ),
      ),
    ),
  );
}

/// The banner's inline 24×24 outline SVGs (white strokes).
class _OutlineIconPainter extends CustomPainter {
  _OutlineIconPainter._(this.kind, this.strokeWidth);

  /// `<circle cx=12 cy=12 r=10 stroke-dasharray="4 4"/>`.
  factory _OutlineIconPainter.dashedCircle() => _OutlineIconPainter._(0, 1.5);

  /// `<rect x=3 y=3 width=18 height=18 rx=2/>`.
  factory _OutlineIconPainter.square() => _OutlineIconPainter._(1, 1.5);

  /// `M4 6h16M4 12h16M4 18h7` + `M15 15l2 2 4-4` (Math subject).
  factory _OutlineIconPainter.mathList() => _OutlineIconPainter._(2, 2);

  /// `M9 3H5a2 2 0 00-2 2v4m6-6h10a2 2 0 012 2v4M9 3v18m0 0h10a2 2 0
  /// 002-2v-4M9 21H5a2 2 0 01-2-2v-4m0 0h18` (other subjects).
  factory _OutlineIconPainter.table() => _OutlineIconPainter._(3, 2);

  final int kind;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.save();
    canvas.scale(s);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = Colors.white;
    switch (kind) {
      case 0:
        final path = Path()..addOval(Rect.fromCircle(center: const Offset(12, 12), radius: 10));
        for (final metric in path.computeMetrics()) {
          var d = 0.0;
          while (d < metric.length) {
            canvas.drawPath(metric.extractPath(d, math.min(d + 4, metric.length)), p);
            d += 8;
          }
        }
      case 1:
        canvas.drawRRect(
          RRect.fromRectAndRadius(const Rect.fromLTWH(3, 3, 18, 18), const Radius.circular(2)),
          p,
        );
      case 2:
        canvas.drawPath(
          Path()
            ..moveTo(4, 6)
            ..lineTo(20, 6)
            ..moveTo(4, 12)
            ..lineTo(20, 12)
            ..moveTo(4, 18)
            ..lineTo(11, 18)
            ..moveTo(15, 15)
            ..lineTo(17, 17)
            ..lineTo(21, 13),
          p,
        );
      default:
        const r = Radius.circular(2);
        canvas.drawPath(
          Path()
            ..moveTo(9, 3)
            ..lineTo(5, 3)
            ..arcToPoint(const Offset(3, 5), radius: r, clockwise: false)
            ..lineTo(3, 9)
            ..moveTo(9, 3)
            ..lineTo(19, 3)
            ..arcToPoint(const Offset(21, 5), radius: r)
            ..lineTo(21, 9)
            ..moveTo(9, 3)
            ..lineTo(9, 21)
            ..lineTo(19, 21)
            ..arcToPoint(const Offset(21, 19), radius: r, clockwise: false)
            ..lineTo(21, 15)
            ..moveTo(9, 21)
            ..lineTo(5, 21)
            ..arcToPoint(const Offset(3, 19), radius: r)
            ..lineTo(3, 15)
            ..lineTo(21, 15),
          p,
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_OutlineIconPainter old) => old.kind != kind;
}
