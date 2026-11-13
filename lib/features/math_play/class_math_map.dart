part of 'class_math_page.dart';

/// The roadmap ("MAP" branch of the template): the painted scene, the
/// chapter signs, the road dots and the START banner.
extension _ClassMathMap on _ClassMathPageState {
  Widget _buildMap(BuildContext context, bool dark, List<Json> filtered) {
    final size = MediaQuery.sizeOf(context);
    // `stageW: Math.max(360, window.innerWidth)` — the window, not the
    // content area, so on wide layouts the stage is centred and its edges
    // clipped (overflow-x-hidden + justify-center), as on the web.
    final stageW = math.max(360.0, size.width);
    final count = filtered.length;
    final stageH = stageHeight(count, size.height);

    var scene = _scene;
    if (scene == null || !scene.sameAs(count, stageW, stageH, dark)) {
      scene = ClassMathScene(count: count, stageW: stageW, stageH: stageH, dark: dark);
      _scene = scene;
    }
    final nodes = chapterNodes(filtered, stageW);
    final totalSecs = _ClassMathPageState._entranceSeconds(count);

    final stage = SizedBox(
      width: stageW,
      height: stageH,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: RepaintBoundary(child: CustomPaint(painter: ClassMathBackPainter(scene))),
          ),
          if (dark)
            Positioned.fill(
              child: RepaintBoundary(
                  child: CustomPaint(painter: ClassMathCampfirePainter(scene, _time))),
            ),
          Positioned.fill(
            child: RepaintBoundary(child: CustomPaint(painter: ClassMathFrontPainter(scene))),
          ),
          if (count > 0) ..._bannerTexts(scene, dark),
          if (dark)
            Positioned.fill(
              child: RepaintBoundary(
                  child: CustomPaint(painter: ClassMathLightsPainter(scene, _time))),
            ),

          // ══ CHAPTER SIGNS ══ (z-8, below every dot)
          for (var idx = 0; idx < nodes.length; idx++)
            Positioned(
              key: ValueKey('sign-${jsStr(nodes[idx].id)}'),
              left: nodes[idx].signX,
              top: nodes[idx].signY,
              width: kSignW,
              child: _ChapterSign(
                node: nodes[idx],
                activityCount: _chapterActivityCount(nodes[idx].id),
                dark: dark,
                entrance: _entrance,
                curve: Interval(
                  math.min(1, idx * 0.09 / totalSecs),
                  math.min(1, (idx * 0.09 + 0.55) / totalSecs),
                  curve: _kBackOut,
                ),
                onTap: () => _openSheet(nodes[idx]),
              ),
            ),

          // road dots (z-10)
          for (final node in nodes)
            Positioned(
              key: ValueKey('dot-${jsStr(node.id)}'),
              left: node.x - 15,
              top: node.y - 15,
              width: 30,
              height: 30,
              child: _RoadDot(
                number: node.number,
                dark: dark,
                entrance: _entrance,
                curve: Interval(0, math.min(1, 0.45 / totalSecs), curve: _kBackOut),
                onTap: () => _openSheet(node),
              ),
            ),

          // ══ START BANNER ══ (bottom-7 + mb-10)
          Positioned(
            left: 0,
            right: 0,
            bottom: 28 + 40,
            child: Center(child: _StartBanner(dark: dark)),
          ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        controller: _scroll,
        child: SizedBox(
          width: constraints.maxWidth,
          height: stageH,
          child: ClipRect(
            child: OverflowBox(
              minWidth: stageW,
              maxWidth: stageW,
              minHeight: stageH,
              maxHeight: stageH,
              alignment: Alignment.topCenter,
              child: stage,
            ),
          ),
        ),
      ),
    );
  }

  /// The banner `<text>`s (★ YOU WIN! 🏆 ★), positioned by their baseline.
  List<Widget> _bannerTexts(ClassMathScene scene, bool dark) {
    final w = scene.stageW, baseline = scene.bannerY + 38;
    final starColor = dark ? const Color(0xFF3B82F6) : const Color(0xFFC8860A);
    Widget atBaseline(double left, double width, Alignment align, Widget text) => Positioned(
          left: left,
          width: width,
          top: baseline - 60,
          height: 90,
          child: IgnorePointer(
            child: Align(
              alignment: align,
              child: Baseline(baseline: 60, baselineType: TextBaseline.alphabetic, child: text),
            ),
          ),
        );
    final star = _nunito(size: 22, color: starColor);
    return [
      atBaseline(w * 0.5 - 96, 40, Alignment.topLeft, Text('★', style: star)),
      atBaseline(w * 0.5 + 76, 40, Alignment.topLeft, Text('★', style: star)),
      atBaseline(
        w * 0.5 - 200,
        400,
        Alignment.topCenter,
        Text('YOU WIN! 🏆',
            maxLines: 1,
            softWrap: false,
            style: _fredoka(size: 28, spacing: 2, color: dark ? Tw.slate200 : const Color(0xFF7B3F00))),
      ),
    ];
  }
}

/// A wooden chapter sign on its post (`.sign-wrap`).
class _ChapterSign extends StatelessWidget {
  const _ChapterSign({
    required this.node,
    required this.activityCount,
    required this.dark,
    required this.entrance,
    required this.curve,
    required this.onTap,
  });

  final ChapterNode node;
  final int activityCount;
  final bool dark;
  final Animation<double> entrance;
  final Curve curve;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = dark ? AppColors.darkPrimary : AppColors.primary;
    final onPrimary = dark ? AppColors.darkPrimaryForeground : AppColors.primaryForeground;
    Widget bolt() => Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dark ? Tw.slate600 : const Color(0xFFF0C060),
            border: Border.all(color: dark ? Tw.slate500 : const Color(0xFFA07010)),
            boxShadow: [cssShadow(0, 1, 3, 0, const Color.fromRGBO(0, 0, 0, 0.35))],
          ),
        );

    final board = HoverBuilder(
      onTap: onTap,
      builder: (context, hover) => AnimatedScale(
        scale: hover ? 1.07 : 1,
        duration: const Duration(milliseconds: 200),
        curve: kTwEase,
        child: AnimatedRotation(
          turns: hover ? -1.8 / 360 : 0,
          duration: const Duration(milliseconds: 200),
          curve: kTwEase,
          child: Container(
            width: kSignW,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
              // bg-gradient-to-br on a wide box
              gradient: CssLinearGradient(
                corner: Alignment.bottomRight,
                colors: dark
                    ? const [Tw.slate900, Tw.slate950]
                    : const [Color(0xFFFFF9DC), Color(0xFFFFF0B0)],
              ),
              border: dark
                  ? Border.all(color: Tw.slate700.withValues(alpha: 0.8))
                  : Border.all(color: const Color(0xFFB87820), width: 3),
              boxShadow: [
                cssShadow(0, 8, 28, 0,
                    dark ? const Color.fromRGBO(0, 0, 0, 0.7) : const Color.fromRGBO(0, 0, 0, 0.28)),
              ],
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        jsDisplay(node.name),
                        style: _nunito(
                          size: 12.5,
                          weight: FontWeight.w900,
                          height: 1.375,
                          color: dark ? Tw.slate100 : const Color(0xFF3A2010),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(color: primary, shape: BoxShape.circle),
                            child: Text('$activityCount',
                                style: _nunito(size: 10, weight: FontWeight.w900, height: 1.5, color: onPrimary)),
                          ),
                          const SizedBox(width: 6),
                          Text('activities',
                              style: _nunito(
                                  size: 11,
                                  weight: FontWeight.w700,
                                  height: 1.5,
                                  color: dark ? Tw.slate400 : const Color(0xFF7A5A20))),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(top: 5, left: 5, child: bolt()),
                Positioned(top: 5, right: 5, child: bolt()),
                Positioned(bottom: 5, left: 5, child: bolt()),
                Positioned(bottom: 5, right: 5, child: bolt()),
              ],
            ),
          ),
        ),
      ),
    );

    final post = Container(
      width: 10,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark ? const [Tw.slate600, Tw.slate800] : const [Color(0xFFC8860A), Color(0xFFA07008)],
        ),
        boxShadow: [cssShadow(2, 2, 8, 0, const Color.fromRGBO(0, 0, 0, 0.28))],
      ),
    );

    // signIn: opacity 0→1 and `scale(.65) translateY(20px) rotate(-4deg)` →
    // identity, about the centre. The functions apply right to left, so the
    // translation is scaled too.
    return AnimatedBuilder(
      animation: entrance,
      builder: (context, child) {
        final v = curve.transform(entrance.value);
        return Opacity(
          opacity: v.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: 0.65 + 0.35 * v,
            child: Transform.translate(
              offset: Offset(0, 20 * (1 - v)),
              child: Transform.rotate(angle: -4 * math.pi / 180 * (1 - v), child: child),
            ),
          ),
        );
      },
      child: Column(mainAxisSize: MainAxisSize.min, children: [board, post]),
    );
  }
}

/// The numbered dot on the road (`.road-dot`).
class _RoadDot extends StatelessWidget {
  const _RoadDot({
    required this.number,
    required this.dark,
    required this.entrance,
    required this.curve,
    required this.onTap,
  });
  final int number;
  final bool dark;
  final Animation<double> entrance;
  final Curve curve;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dot = HoverBuilder(
      onTap: onTap,
      builder: (context, hover) => AnimatedScale(
        scale: hover ? 1.3 : 1,
        duration: const Duration(milliseconds: 200),
        curve: kTwEase,
        child: Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: dark ? const [Tw.slate700, Tw.slate900] : const [Color(0xFFFFEE80), Color(0xFFE8C030)],
            ),
            border: dark
                ? Border.all(color: Tw.slate700)
                : Border.all(color: const Color(0xFF7A5010), width: 3),
            boxShadow: [
              cssShadow(0, 4, 14, 0, dark ? const Color.fromRGBO(0, 0, 0, 0.6) : const Color.fromRGBO(0, 0, 0, 0.32)),
            ],
          ),
          child: Text('$number',
              style: _fredoka(size: 12, color: dark ? Tw.slate200 : const Color(0xFF3A2010))
                  .copyWith(height: 1)),
        ),
      ),
    );

    // dotPop: scale 0→1, rotate -180°→0.
    return AnimatedBuilder(
      animation: entrance,
      builder: (context, child) {
        final v = curve.transform(entrance.value);
        return Transform.rotate(
          angle: -math.pi * (1 - v),
          child: Transform.scale(scale: v, child: child),
        );
      },
      child: dot,
    );
  }
}

/// 🚩 START 🚩
class _StartBanner extends StatelessWidget {
  const _StartBanner({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: dark ? Tw.slate900 : null,
        gradient: dark
            ? null
            : const LinearGradient(colors: [Color(0xFF1A4A10), Color(0xFF2A7020)]),
        border: Border.all(color: dark ? Tw.slate700.withValues(alpha: 0.8) : const Color(0xFFA8D870)),
        boxShadow: [
          cssShadow(0, 8, 28, 0, dark ? const Color.fromRGBO(0, 0, 0, 0.6) : const Color.fromRGBO(0, 0, 0, 0.35)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🚩', style: TextStyle(fontSize: 18, height: TwLeading.lg)),
          const SizedBox(width: 10),
          Text('START',
              style: _fredoka(
                      size: 16,
                      spacing: 16 * 0.06,
                      color: dark ? AppColors.darkPrimary : const Color(0xFFC8F080))
                  .copyWith(height: TwLeading.base)),
          const SizedBox(width: 10),
          const Text('🚩', style: TextStyle(fontSize: 18, height: TwLeading.lg)),
        ],
      ),
    );
  }
}
