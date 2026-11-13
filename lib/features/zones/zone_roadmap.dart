part of 'zones_page.dart';

/// Height of the sticky "Your Learning Path" header (`py-3` around the
/// 30px "Scroll" pill). The canvas starts below it, like the web's flow
/// layout, and milestones may overlap it.
const double _kRoadHeaderH = 54;

/// The roadmap's inner height: `height: 380px` is the border box
/// (`box-sizing: border-box`), so 378px inside the 1px border; the 380px
/// canvas below the header is clipped there (`overflow-y: hidden`).
const double _kRoadInnerH = kRoadmapHeight - 2;

/// ROADMAP — horizontally scrolling road with one milestone flag per chapter.
extension _Roadmap on _ZonePageState {
  Widget _buildRoadmap(bool isStudent) {
    final dark = context.isDark;
    return Container(
      height: kRoadmapHeight,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF13133A) : const Color(0xFFDDE3EC),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark ? Tw.slate800.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: AppShadows.xs,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: LayoutBuilder(builder: (context, c) {
          // `containerWidth` = roadmapContainer.clientWidth
          final width = pathMinWidth(_chapters.length, c.maxWidth);
          final points = buildMilestonePoints(_chapters.length, width);

          final Widget? state;
          if (_loading && _chapters.isEmpty) {
            state = _roadLoading();
          } else if (!jsTruthy(_selectedClassId) && !_loading) {
            state = _roadNoClass();
          } else {
            state = null;
          }

          return Stack(
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: GridPainter(dark
                      ? const Color.fromRGBO(255, 255, 255, 0.022)
                      : const Color.fromRGBO(0, 0, 0, 0.032)),
                ),
              ),
              if (state == null)
                Positioned.fill(
                  child: SingleChildScrollView(
                    controller: _roadmapScroll,
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: width,
                      height: _kRoadInnerH,
                      child: _roadCanvas(points, width, isStudent),
                    ),
                  ),
                )
              else
                Positioned.fill(child: state),
              Positioned(left: 0, right: 0, top: 0, height: _kRoadHeaderH, child: _roadHeader()),
            ],
          );
        }),
      ),
    );
  }

  Widget _roadHeader() {
    final dark = context.isDark;
    final sm = context.isSm;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sm ? 24 : 16, vertical: 12),
      child: Row(
        children: [
          IgnorePointer(
            child: Opacity(
              opacity: 0.7,
              child: Text(
                'YOUR LEARNING PATH',
                style: zt(
                  sm ? 14 : 12,
                  FontWeight.w900,
                  dark ? Colors.white : Tw.gray700,
                  height: sm ? 20 / 14 : 16 / 12,
                  spacing: (sm ? 14 : 12) * 0.1,
                  shadows: kDropShadowMd,
                ),
              ),
            ),
          ),
          const Spacer(),
          ZoneHover(
            onTap: _scrollPathRight,
            builder: (context, hover) {
              final fg = dark ? Colors.white.withValues(alpha: 0.6) : Tw.gray500;
              final Color bg = dark
                  ? Colors.white.withValues(alpha: hover ? 0.1 : 0.05)
                  : (hover ? Tw.gray100 : Colors.white.withValues(alpha: 0.5));
              return AnimatedScale(
                scale: hover ? 1.05 : 1,
                duration: const Duration(milliseconds: 150),
                curve: kTwEase,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.2) : Tw.gray300),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Scroll', style: zt(12, FontWeight.w600, fg, height: 16 / 12)),
                      const SizedBox(width: 6),
                      Icon(BootstrapIcons.arrow_right, size: 12, color: fg),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _roadLoading() {
    final dark = context.isDark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const RingSpinner(size: 40, stroke: 3),
        const SizedBox(height: 12),
        Opacity(
          opacity: 0.4,
          child: Text('Loading chapters…',
              style: zt(12, FontWeight.w700, dark ? Colors.white : Tw.gray600, height: 16 / 12)),
        ),
      ],
    );
  }

  Widget _roadNoClass() {
    final dark = context.isDark;
    return Opacity(
      opacity: 0.4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(BootstrapIcons.mortarboard, size: 36, color: dark ? Tw.slate600 : Tw.gray400),
          const SizedBox(height: 12),
          Text('Select a class below to begin',
              style: zt(14, FontWeight.w900, dark ? Tw.slate500 : Tw.gray400, height: 20 / 14)),
        ],
      ),
    );
  }

  Widget _roadCanvas(List<Offset> points, double width, bool isStudent) {
    final dark = context.isDark;
    final colors = context.colors;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          left: 0,
          top: _kRoadHeaderH,
          width: width,
          height: kRoadmapHeight,
          child: IgnorePointer(
            child: CustomPaint(painter: RoadPainter(points: points, dark: dark)),
          ),
        ),
        // `translate(-50%, -100%)`: each milestone's bottom centre sits on
        // its road point.
        for (var i = 0; i < points.length && i < _chapters.length; i++)
          Positioned(
            left: points[i].dx - kCardWidth / 2,
            bottom: _kRoadInnerH - (_kRoadHeaderH + points[i].dy),
            width: kCardWidth,
            child: _Milestone(
              index: i,
              name: jsStr(_chapters[i]['name']) ?? '',
              selected: _selectedChapterIndex == i,
              flag: _flagColor(i, colors),
              isStudent: isStudent,
              showBadge: isStudent && _getChapterPerfByIndex(i) != null,
              pct: _getChapterPctByIndex(i),
              onTap: () => _selectChapter(_chapters[i], i),
            ),
          ),
      ],
    );
  }
}

/// One milestone: flag (+ completion badge) and the label card.
class _Milestone extends StatefulWidget {
  const _Milestone({
    required this.index,
    required this.name,
    required this.selected,
    required this.flag,
    required this.isStudent,
    required this.showBadge,
    required this.pct,
    required this.onTap,
  });

  final int index;
  final String name;
  final bool selected;
  final ({Color fill, Color stroke}) flag;
  final bool isStudent;
  final bool showBadge;
  final double pct;
  final VoidCallback onTap;

  @override
  State<_Milestone> createState() => _MilestoneState();
}

class _MilestoneState extends State<_Milestone> with SingleTickerProviderStateMixin {
  bool _hover = false;

  /// `animate-ping` on the selected milestone's base ring.
  late final AnimationController _ping =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));

  @override
  void initState() {
    super.initState();
    _syncPing();
  }

  @override
  void didUpdateWidget(_Milestone old) {
    super.didUpdateWidget(old);
    if (old.selected != widget.selected) _syncPing();
  }

  void _syncPing() {
    if (widget.selected) {
      _ping.repeat();
    } else {
      _ping.stop();
    }
  }

  @override
  void dispose() {
    _ping.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final colors = context.colors;
    final primary = colors.primary;
    final selected = widget.selected;

    final flag = SizedBox(
      width: 48,
      height: 56,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ping,
              builder: (context, _) => CustomPaint(
                painter: FlagPainter(
                  fill: widget.flag.fill,
                  stroke: widget.flag.stroke,
                  ringColor: primary,
                  ping: selected ? _ping.value : null,
                ),
              ),
            ),
          ),
          if (widget.showBadge)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.pct > 0 ? primary : const Color.fromRGBO(100, 100, 100, 0.5),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  pctBadgeLabel(widget.pct),
                  style: zt(7, FontWeight.w900, colors.onPrimary, height: 1),
                ),
              ),
            ),
        ],
      ),
    );

    // Label card: `transition-all duration-200` between the selected and
    // plain styles.
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: kTwEase,
      width: kCardWidth,
      padding: EdgeInsets.symmetric(horizontal: sm ? 12 : 8, vertical: 8),
      decoration: BoxDecoration(
        color: selected
            ? (dark ? const Color.fromRGBO(13, 13, 43, 0.97) : const Color.fromRGBO(255, 255, 255, 0.98))
            : (dark ? const Color.fromRGBO(13, 13, 43, 0.88) : const Color.fromRGBO(255, 255, 255, 0.92)),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: selected
              ? primary
              : (dark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.1)),
        ),
        boxShadow: selected ? [BoxShadow(color: primary, spreadRadius: 2)] : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'MILESTONE ${widget.index + 1}',
            textAlign: TextAlign.center,
            style: zt(9, FontWeight.w900,
                dark ? Colors.white.withValues(alpha: 0.5) : Tw.gray400,
                spacing: 0.9, height: 1.5),
          ),
          const SizedBox(height: 2),
          Text(
            widget.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: zt(
              sm ? 14 : 12,
              FontWeight.w700,
              selected ? primary : (dark ? Colors.white : Tw.gray800),
              height: sm ? 20 / 14 : 16 / 12,
            ),
          ),
          if (widget.isStudent)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 4,
                  color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200,
                  alignment: Alignment.centerLeft,
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 700),
                    curve: kTwEase,
                    widthFactor: pctFraction(widget.pct),
                    heightFactor: 1,
                    child: ColoredBox(color: primary),
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
          scale: _hover ? 1.07 : 1,
          alignment: Alignment.bottomCenter,
          duration: const Duration(milliseconds: 280),
          curve: const Cubic(0.4, 0, 0.2, 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: AnimatedScale(
                  scale: _hover ? 1.1 : 1,
                  duration: const Duration(milliseconds: 300),
                  curve: kTwEase,
                  child: flag,
                ),
              ),
              card,
            ],
          ),
        ),
      ),
    );
  }
}
