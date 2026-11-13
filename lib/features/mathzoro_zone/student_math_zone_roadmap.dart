part of 'student_math_zone_page.dart';

/// ══ LEARNING PATH ROADMAP ══ — a 400px box that scrolls horizontally; the
/// sticky "Your Learning Path" header sits in the flow above the canvas
/// (so the 400px canvas is partly clipped, like the web's overflow-y:hidden).
extension _Roadmap on _StudentMathZonePageState {
  Widget _roadmap(Map<String, Json> perfMap) {
    final dark = context.isDark;
    final sm = context.isSm;
    final mx = sm ? 16.0 : 8.0;
    // py-3 around the 30px (26px below sm) "Scroll" pill.
    final headerH = sm ? 54.0 : 50.0;
    final radius = BorderRadius.circular(40);

    return Padding(
      padding: EdgeInsets.fromLTRB(mx, 16, mx, 0),
      child: Container(
        height: kMzRoadHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: dark ? const Color(0xFF1E1842) : const Color(0xFFDDE3EC),
          borderRadius: radius,
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1),
          ),
        ),
        // border-box: the 1px border is inside the 400px.
        padding: const EdgeInsets.all(1),
        child: LayoutBuilder(
          builder: (context, c) {
            // `containerWidth` = roadmapContainer.clientWidth
            final width = mzPathMinWidth(_chapters.length, c.maxWidth);
            final points = mzMilestonePoints(_chapters.length, width);
            return Stack(
              children: [
                // The background grid does not scroll with the content.
                Positioned.fill(
                  child: CustomPaint(
                    painter: ZoneGridPainter(
                      dark
                          ? Colors.white.withValues(alpha: 0.022)
                          : Colors.black.withValues(alpha: 0.032),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: SingleChildScrollView(
                    controller: _roadScroll,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      height: c.maxHeight,
                      child: _roadCanvas(points, width, headerH, c.maxHeight, perfMap),
                    ),
                  ),
                ),
                Positioned(left: 0, right: 0, top: 0, child: _roadHeader(sm, dark)),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Sticky header (`pointer-events-none`, except the Scroll pill).
  Widget _roadHeader(bool sm, bool dark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sm ? 24 : 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: IgnorePointer(
              child: Opacity(
                opacity: 0.8,
                child: Text(
                  'YOUR LEARNING PATH',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _t(
                    sm ? 14 : 12,
                    FontWeight.w900,
                    dark ? Colors.white : Tw.gray700,
                    spacing: (sm ? 14 : 12) * 0.1,
                    shadows: kMzDropShadowMd,
                  ),
                ),
              ),
            ),
          ),
          ZonePress(
            onTap: _scrollPathRight,
            builder: (context, hover, _) => AnimatedScale(
              scale: hover ? 1.05 : 1,
              duration: const Duration(milliseconds: 150),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: BackdropFilter(
                  filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: sm ? 12 : 10, vertical: sm ? 6 : 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: dark
                          ? Colors.white.withValues(alpha: hover ? 0.1 : 0.05)
                          : (hover ? Tw.gray100 : Colors.white.withValues(alpha: 0.5)),
                      border: Border.all(
                        color: dark ? Colors.white.withValues(alpha: 0.2) : Tw.gray300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Scroll',
                          style: _t(
                            12,
                            FontWeight.w600,
                            dark ? Colors.white.withValues(alpha: 0.6) : Tw.gray500,
                            height: 16 / 12,
                          ),
                        ),
                        SizedBox(width: sm ? 6 : 4),
                        Icon(
                          BootstrapIcons.arrow_right,
                          size: 12,
                          color: dark ? Colors.white.withValues(alpha: 0.6) : Tw.gray500,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// `scrollPathRight()` — `scrollBy({ left: 300, behavior: 'smooth' })`.
  void _scrollPathRight() {
    if (!_roadScroll.hasClients) return;
    final pos = _roadScroll.position;
    final target = math.min(pos.pixels + 300, pos.maxScrollExtent);
    _roadScroll.animateTo(
      target,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Widget _roadCanvas(
    List<Offset> points,
    double width,
    double headerH,
    double height,
    Map<String, Json> perfMap,
  ) {
    final dark = context.isDark;
    final n = _chapters.length;
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _MzRoadPainter(
                points: points,
                offsetY: headerH,
                base: dark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.07),
                accent: _accent,
              ),
            ),
          ),
        ),
        for (var i = 0; i < points.length; i++)
          Positioned(
            key: ValueKey(_chapters[i]['id'] ?? i),
            left: points[i].dx - kMzCardWidth / 2,
            width: kMzCardWidth,
            bottom: height - (points[i].dy + headerH),
            child: _MzMilestone(
              index: i,
              name: jsDisplay(_chapters[i]['name']),
              selected: _selectedChapterIndex == i,
              hasPerf: _chapterPerfByIndex(perfMap, i) != null,
              pct: _chapterPctByIndex(perfMap, i),
              flag: mzFlagColor(_chapterPctByIndex(perfMap, i), i, n),
              accent: _accent,
              text: _t,
              onTap: () => _selectChapter(i < _chapters.length ? _chapters[i] : null, i),
            ),
          ),
      ],
    );
  }
}

/// The road SVG: a wide translucent band (44) and the dashed accent centre
/// line (3.5, `stroke-dasharray="14 18"`, opacity .65).
class _MzRoadPainter extends CustomPainter {
  _MzRoadPainter({
    required this.points,
    required this.offsetY,
    required this.base,
    required this.accent,
  });

  final List<Offset> points;
  final double offsetY;
  final Color base;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    // `M x y` alone (one chapter) draws nothing.
    if (points.length < 2) return;
    canvas.save();
    canvas.translate(0, offsetY);
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final (c1, c2, end) in mzRoadSegments(points)) {
      path.cubicTo(c1.dx, c1.dy, c2.dx, c2.dy, end.dx, end.dy);
    }
    Paint stroke(Color c, double w) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = w
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = c;

    canvas.drawPath(path, stroke(base, 44));
    final dash = stroke(accent.withValues(alpha: accent.a * 0.65), 3.5);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, math.min(d + 14, metric.length)), dash);
        d += 32;
      }
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MzRoadPainter old) =>
      old.base != base ||
      old.accent != accent ||
      old.offsetY != offsetY ||
      !_samePoints(old.points, points);

  static bool _samePoints(List<Offset> a, List<Offset> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// One milestone: flag (with the completion ring) above the label card.
/// `hover` scales the whole milestone (1.06, from the bottom centre) and the
/// flag (1.1).
class _MzMilestone extends StatefulWidget {
  const _MzMilestone({
    required this.index,
    required this.name,
    required this.selected,
    required this.hasPerf,
    required this.pct,
    required this.flag,
    required this.accent,
    required this.text,
    required this.onTap,
  });

  final int index;
  final String name;
  final bool selected;
  final bool hasPerf;
  final double pct;
  final ({Color fill, Color stroke}) flag;
  final Color accent;
  final _TextFn text;
  final VoidCallback onTap;

  @override
  State<_MzMilestone> createState() => _MzMilestoneState();
}

class _MzMilestoneState extends State<_MzMilestone> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final t = widget.text;
    final pct = widget.pct;
    final accent = widget.accent;

    final ringBg = pct >= 100
        ? const Color(0xFF4ADE80)
        : (pct > 0 ? accent : const Color.fromRGBO(100, 100, 100, 0.5));
    final barColor = pct >= 100 ? const Color(0xFF4ADE80) : (pct > 0 ? accent : Colors.transparent);

    final flag = AnimatedScale(
      scale: _hover ? 1.1 : 1,
      duration: const Duration(milliseconds: 300),
      child: SizedBox(
        width: 48,
        height: 56,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _MzFlagPainter(fill: widget.flag.fill, stroke: widget.flag.stroke),
              ),
            ),
            if (widget.hasPerf)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: ringBg,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Text(
                    mzFlagBadgeLabel(pct),
                    maxLines: 1,
                    style: t(7, FontWeight.w900, const Color(0xFF1A1200), height: 1),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    final card = Container(
      width: kMzCardWidth,
      padding: EdgeInsets.symmetric(horizontal: sm ? 12 : 8, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: widget.selected
            ? (dark
                  ? const Color.fromRGBO(22, 18, 51, 0.97)
                  : const Color.fromRGBO(255, 255, 255, 0.98))
            : (dark
                  ? const Color.fromRGBO(22, 18, 51, 0.88)
                  : const Color.fromRGBO(255, 255, 255, 0.92)),
        border: Border.all(
          color: widget.selected
              ? accent
              : (dark
                    ? const Color.fromRGBO(255, 255, 255, 0.12)
                    : const Color.fromRGBO(0, 0, 0, 0.1)),
        ),
        boxShadow: widget.selected
            ? [BoxShadow(color: accent.withValues(alpha: 0x55 / 255), spreadRadius: 2)]
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'MILESTONE-${widget.index + 1}',
            textAlign: TextAlign.center,
            style: t(
              sm ? 10 : 9,
              FontWeight.w900,
              dark ? Colors.white.withValues(alpha: 0.5) : Tw.gray400,
              height: 1.5,
              spacing: (sm ? 10 : 9) * 0.1,
            ),
          ),
          const SizedBox(height: 2),
          SizedBox(
            width: double.infinity,
            child: Text(
              widget.name,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: t(
                sm ? 14 : 12,
                FontWeight.w700,
                dark ? Colors.white : Tw.gray800,
                height: sm ? 20 / 14 : 16 / 12,
              ),
            ),
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 4,
              color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200,
              alignment: Alignment.centerLeft,
              child: AnimatedFractionallySizedBox(
                duration: const Duration(milliseconds: 700),
                widthFactor: mzPctFraction(pct),
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _hover ? 1.06 : 1,
          alignment: Alignment.bottomCenter,
          duration: const Duration(milliseconds: 280),
          curve: const Cubic(0.4, 0, 0.2, 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [flag, const SizedBox(height: 8), card],
          ),
        ),
      ),
    );
  }
}

/// The 48×56 flag SVG (`viewBox="0 0 24 32"`) with its
/// `drop-shadow(0 8px 10px rgba(0,0,0,0.55))`.
class _MzFlagPainter extends CustomPainter {
  _MzFlagPainter({required this.fill, required this.stroke});
  final Color fill;
  final Color stroke;

  static final Path _banner = Path()
    ..moveTo(6, 4)
    ..lineTo(22, 9)
    ..lineTo(6, 14)
    ..close();

  void _shapes(Canvas canvas) {
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(5, 30), width: 16, height: 6),
      Paint()..color = const Color.fromRGBO(0, 0, 0, 0.35),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(4, 2, 2, 28), const Radius.circular(1)),
      Paint()..color = const Color(0xFFCBD5E1),
    );
    canvas.drawPath(_banner, Paint()..color = fill);
    canvas.drawPath(
      _banner,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeJoin = StrokeJoin.round
        ..color = stroke,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    // preserveAspectRatio="xMidYMid meet"
    final s = math.min(size.width / 24, size.height / 32);
    final dx = (size.width - 24 * s) / 2;
    final dy = (size.height - 32 * s) / 2;

    // drop-shadow: the silhouette in rgba(0,0,0,.55), blurred, 8px lower.
    canvas.saveLayer(
      Rect.fromLTWH(-30, -30, size.width + 60, size.height + 60),
      Paint()
        ..colorFilter = const ColorFilter.mode(Color.fromRGBO(0, 0, 0, 0.55), BlendMode.srcIn)
        ..imageFilter = ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5),
    );
    canvas.translate(dx, dy + 8);
    canvas.scale(s);
    _shapes(canvas);
    canvas.restore();

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(s);
    _shapes(canvas);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MzFlagPainter old) => old.fill != fill || old.stroke != stroke;
}
