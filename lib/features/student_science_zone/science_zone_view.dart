part of 'student_science_zone_page.dart';

const _darkPageBg = Color(0xFF161233);
const _lightPageBg = Color(0xFFF1F5F9);
const _darkRoadBg = Color(0xFF1E1842);
const _lightRoadBg = Color(0xFFDDE3EC);
const _onAccent = Color(0xFF003A1D);

/// `shadow-[0_0_10px_#f43f5e]` (arbitrary hex; the dot itself is `bg-rose-500`).
const _roseGlow = Color(0xFFF43F5E);

/// `.classmathzone { font-family: 'Inter', 'Urbanist', sans-serif }` — the
/// page uses Inter in both modes; the inherited line-height is 1.5.
const _pageFont = TextStyle(
  fontFamily: AppFonts.inter,
  fontFamilyFallback: AppFonts.fallback,
  height: 1.5,
);

/// Template of `studentsciencezone.vue`.
///
/// Not reproduced: the milestone label cards' `backdrop-blur-md` (they are
/// 88–98% opaque) and the board's `backdrop-filter` (over a solid page
/// background).
extension _ScienceZoneView on _StudentScienceZonePageState {
  Widget _buildPage(BuildContext context) {
    final dark = context.isDark;
    return ColoredBox(
      color: dark ? _darkPageBg : _lightPageBg,
      child: DefaultTextStyle.merge(
        style: _pageFont.copyWith(color: dark ? Colors.white : Tw.gray900),
        child: LayoutBuilder(
          builder: (context, c) {
            if (_loading || _error != null) {
              // `min-h-screen flex flex-col` + a `flex-1` centred state.
              return SingleChildScrollView(
                child: SizedBox(
                  height: math.max(c.maxHeight, 420),
                  child: Column(
                    children: [
                      _banner(context),
                      Expanded(child: _loading ? _loadingState() : _errorState()),
                    ],
                  ),
                ),
              );
            }
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _banner(context),
                  _roadmap(context),
                  _activityBoard(context),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ══ HEADER / BANNER ══

  Widget _banner(BuildContext context) {
    final sm = context.isSm;
    final md = context.isMd;
    final titleSize = md ? 48.0 : (sm ? 36.0 : 24.0);
    final iconBoxRadius = BorderRadius.circular(sm ? 24 : 20);
    return RepaintBoundary(
      child: Container(
        height: 142,
        margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: _bannerBg, borderRadius: BorderRadius.circular(40)),
        child: Stack(
          children: [
            const Positioned.fill(child: CustomPaint(painter: _DotPatternPainter())),
            // .banner-glow-1 (drift1 8s)
            Positioned(
              left: -100,
              top: -150,
              width: 400,
              height: 400,
              child: _Drift(
                period: const Duration(seconds: 8),
                from: (Offset.zero, 1.0),
                to: (const Offset(30, -20), 1.1),
                child: _glow(_accent),
              ),
            ),
            // .banner-glow-2 (drift2 10s)
            Positioned(
              right: -50,
              bottom: -150,
              width: 350,
              height: 350,
              child: _Drift(
                period: const Duration(seconds: 10),
                from: (Offset.zero, 1.2),
                to: (const Offset(-40, 30), 0.9),
                child: _glow(_accentSecondary),
              ),
            ),
            // Floating decorative icons (`absolute right-10 flex gap-6
            // opacity-20`, vertically centred; the row's items keep their
            // own heights and sit at its top).
            Positioned(
              right: 40,
              top: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.2,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _Float(
                          delay: Duration.zero,
                          child: _HeroIcon(HeroPaths.table, size: 64, strokeWidth: 1.5, color: Colors.white),
                        ),
                        if (sm) ...[
                          const SizedBox(width: 24),
                          const _Float(
                            delay: Duration(seconds: 1),
                            child: CustomPaint(size: Size(48, 48), painter: _DashedCirclePainter()),
                          ),
                        ],
                        if (md) ...[
                          const SizedBox(width: 24),
                          const _Float(
                            delay: Duration(seconds: 2),
                            child: CustomPaint(size: Size(80, 80), painter: _RoundedSquarePainter()),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: md ? 48 : (sm ? 32 : 24)),
                child: Row(
                  children: [
                    // `rounded-[1.25rem] sm:rounded-[1.5rem] shadow-lg border-white/20`,
                    // `background: rgba(0,0,0,.2); backdrop-filter: blur(12px)`.
                    Container(
                      width: sm ? 80 : 56,
                      height: sm ? 80 : 56,
                      decoration: BoxDecoration(borderRadius: iconBoxRadius, boxShadow: AppShadows.lg),
                      child: ClipRRect(
                        borderRadius: iconBoxRadius,
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.2),
                              borderRadius: iconBoxRadius,
                              border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                            ),
                            child: _HeroIcon(HeroPaths.table,
                                size: sm ? 40 : 28, strokeWidth: 2, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: sm ? 24 : 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _PulseDot(size: sm ? 10 : 8),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  'INTERACTIVE PLAYGROUND',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: sm ? 12 : 10,
                                    height: sm ? 16 / 12 : 1.5,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: sm ? 1.2 : 1.0,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedSubjectName.isNotEmpty ? _selectedSubjectName : 'Science Zone',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: titleSize,
                              height: 1.25,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -titleSize * 0.025,
                              color: Colors.white,
                              // drop-shadow-md: 0 3px 3px rgb(0 0 0 / .12); the CSS blur is a
                              // standard deviation (3) → blurRadius ≈ 4.33.
                              shadows: const [
                                Shadow(color: Color(0x1F000000), blurRadius: 4.33, offset: Offset(0, 3)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: sm ? 20 : 16,
              right: sm ? 24 : 16,
              child: _BannerBackButton(
                showLabel: sm,
                onTap: () => context.go('/newlayout/teachersdashboardpage'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// `radial-gradient(circle, <c> 0%, transparent 70%)` (the circle's
  /// farthest-corner ray is r·√2, so 70% ≈ the edge) with `filter: blur(80px)`.
  Widget _glow(Color color) => IgnorePointer(
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: 80, sigmaY: 80, tileMode: TileMode.decal),
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [color, color.withValues(alpha: 0)],
                stops: const [0, 0.7 * math.sqrt2],
              ),
            ),
          ),
        ),
      );

  // ══ LOADING / ERROR ══

  Widget _loadingState() => const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AccentSpinner(size: 44, stroke: 3),
          SizedBox(height: 16),
          Opacity(
            opacity: 0.5,
            child: Text('Loading chapters…',
                style: TextStyle(
                    fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w700, letterSpacing: 0.35)),
          ),
        ],
      );

  Widget _errorState() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: Tw.red400)),
            const SizedBox(height: 16),
            HoverBuilder(
              onTap: () => _fire(_autoSelectAndLoad),
              cursor: SystemMouseCursors.basic,
              builder: (_, _) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration:
                    BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(999)),
                child: const Text('Retry',
                    style: TextStyle(
                        fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w700, color: _onAccent)),
              ),
            ),
          ],
        ),
      );

  // ══ LEARNING PATH ROADMAP ══

  Widget _roadmap(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    // Height of the sticky header row (py-3 + the Scroll button).
    final headerH = sm ? 54.0 : 50.0;
    const radius = BorderRadius.all(Radius.circular(40));
    return Container(
      height: 400,
      margin: EdgeInsets.fromLTRB(sm ? 16 : 8, 16, sm ? 16 : 8, 0),
      decoration: BoxDecoration(
        color: dark ? _darkRoadBg : _lightRoadBg,
        borderRadius: radius,
        border: Border.all(
            color: dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: LayoutBuilder(
          builder: (context, c) {
            final containerWidth = c.maxWidth;
            final chapters = _filteredChapters;
            final width = pathMinWidth(chapters.length, containerWidth);
            final points = buildMilestonePoints(chapters.length, width);
            return Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _GridPainter(
                      color: dark
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
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Road SVG
                          Positioned(
                            left: 0,
                            top: headerH,
                            width: width,
                            height: 400,
                            child: IgnorePointer(
                              child: CustomPaint(
                                painter: _RoadPainter(
                                  points: points,
                                  base: dark
                                      ? Colors.white.withValues(alpha: 0.06)
                                      : Colors.black.withValues(alpha: 0.07),
                                ),
                              ),
                            ),
                          ),
                          for (var i = 0; i < points.length; i++)
                            Positioned(
                              key: ValueKey(jsStr(chapters[i]['id']) ?? '$i'),
                              left: points[i].dx,
                              top: headerH + points[i].dy,
                              child: FractionalTranslation(
                                translation: const Offset(-0.5, -1),
                                child: _milestone(context, i),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Sticky header
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  child: Padding(
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
                                style: TextStyle(
                                  fontSize: sm ? 14 : 12,
                                  height: sm ? 20 / 14 : 16 / 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: sm ? 1.4 : 1.2,
                                  color: dark ? Colors.white : Tw.gray700,
                                  shadows: const [
                                    Shadow(color: Color(0x1F000000), blurRadius: 3, offset: Offset(0, 3)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        _ScrollChip(onTap: _scrollPathRight),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _milestone(BuildContext context, int i) {
    final dark = context.isDark;
    final sm = context.isSm;
    final chapters = _filteredChapters;
    final chapter = chapters[i];
    final pct = _getChapterPctByIndex(i);
    final hasPerf = _getChapterPerfByIndex(i) != null;
    final colors = flagColor(pct, i, chapters.length);
    final selected = _selectedChapterIndex == i;
    final name = jsDisplay(chapter['name']);
    // pct >= 100 → #4ade80, > 0 → accentColor (also #4ade80), else transparent.
    final barColor = pct > 0 ? _accent : Colors.transparent;

    return HoverBuilder(
      onTap: () => _fire(() => _selectChapter(chapter, i)),
      builder: (context, hovered) => AnimatedScale(
        scale: hovered ? 1.06 : 1,
        alignment: Alignment.bottomCenter,
        duration: const Duration(milliseconds: 280),
        curve: const Cubic(0.4, 0, 0.2, 1),
        child: SizedBox(
          width: cardWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flag with completion ring
              AnimatedScale(
                scale: hovered ? 1.1 : 1,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: 48,
                  height: 56,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _FlagPainter(fill: colors.fill, stroke: colors.stroke),
                        ),
                      ),
                      if (hasPerf)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            width: 20,
                            height: 20,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                              color: pct > 0 ? _accent : const Color.fromRGBO(100, 100, 100, 0.5),
                            ),
                            // text-[7px]: "100%" is wider than the badge and
                            // overflows it, centred.
                            child: OverflowBox(
                              maxWidth: double.infinity,
                              child: Text(
                                pct > 0 ? '$pct%' : '?',
                                maxLines: 1,
                                softWrap: false,
                                style: const TextStyle(
                                    fontSize: 7, fontWeight: FontWeight.w900, color: _onAccent),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Label card
              Container(
                width: cardWidth,
                padding: EdgeInsets.symmetric(horizontal: sm ? 12 : 8, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: selected
                      ? (dark
                          ? const Color.fromRGBO(22, 18, 51, 0.97)
                          : const Color.fromRGBO(255, 255, 255, 0.98))
                      : (dark
                          ? const Color.fromRGBO(22, 18, 51, 0.88)
                          : const Color.fromRGBO(255, 255, 255, 0.92)),
                  border: Border.all(
                    color: selected
                        ? _accent
                        : (dark
                            ? Colors.white.withValues(alpha: 0.12)
                            : Colors.black.withValues(alpha: 0.1)),
                  ),
                  boxShadow: selected
                      ? [BoxShadow(color: _accent.withValues(alpha: 0x55 / 255), spreadRadius: 2)]
                      : null,
                ),
                child: Column(
                  children: [
                    Text(
                      'MILESTONE-${i + 1}',
                      style: TextStyle(
                        fontSize: sm ? 10 : 9,
                        height: 1.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: sm ? 1.0 : 0.9,
                        color: dark ? Colors.white.withValues(alpha: 0.5) : Tw.gray400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Tooltip(
                      message: name,
                      child: Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: sm ? 14 : 12,
                          height: sm ? 20 / 14 : 16 / 12,
                          fontWeight: FontWeight.w700,
                          color: dark ? Colors.white : Tw.gray800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ProgressTrack(
                      height: 4,
                      fraction: pct / 100,
                      track: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200,
                      color: barColor,
                      duration: const Duration(milliseconds: 700),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══ ACTIVITY BOARD ══

  Widget _activityBoard(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    return Container(
      margin: EdgeInsets.fromLTRB(sm ? 16 : 8, 16, sm ? 16 : 8, 16),
      constraints: const BoxConstraints(minHeight: 300),
      child: CustomPaint(
        painter: _BoardBorderPainter(
          background: dark ? const Color.fromRGBO(38, 32, 75, 0.7) : Colors.white,
          side: dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.1),
          top: _accent,
        ),
        // padding: 1.25rem inside the 4px top / 1px side borders
        child: Padding(
          padding: const EdgeInsets.fromLTRB(21, 24, 21, 21),
          child: _activeChapter == null ? _boardEmpty(context) : _boardContent(context),
        ),
      ),
    );
  }

  Widget _boardEmpty(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final color = dark ? Colors.white : Tw.gray600;
    // `flex-grow` inside the board's 300px min-height (minus borders and
    // padding).
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 300 - 45),
      child: Center(
        child: Opacity(
          opacity: 0.4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _HeroIcon(HeroPaths.flag, size: sm ? 48 : 40, strokeWidth: 1.5, color: color),
                const SizedBox(height: 16),
                Text(
                  'Select a milestone flag on the road\nto unlock activities here',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: sm ? 18 : 16,
                    height: sm ? 28 / 18 : 1.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _boardContent(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final chapter = _activeChapter!;
    final progress = _chapterProgress;
    // chapterProgress >= 100 ? '#4ade80' : accentColor — the same colour.
    const progressColor = _accent;
    final unit = jsTruthy(chapter['unit']) ? jsDisplay(chapter['unit']) : _selectedSubjectName;

    final left = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: dark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            unit.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
              color: dark ? Colors.white.withValues(alpha: 0.5) : Tw.gray400,
            ),
          ),
        ),
        Text(
          jsDisplay(chapter['name']),
          style: TextStyle(
            fontSize: sm ? 30 : 24,
            height: 1.25,
            fontWeight: FontWeight.w900,
            color: dark ? Colors.white : Tw.gray900,
          ),
        ),
        // Chapter stars — the star SVGs are `hidden`; only the row's mt-2 stays.
        const SizedBox(height: 8),
      ],
    );

    final refButton = _OutlineChip(
      onTap: () => _fire(_openChapterReferenceDialog),
      label: 'Chapter Reference',
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Chapter header
        if (sm)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [Expanded(child: left), const SizedBox(width: 12), refButton],
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [left, const SizedBox(height: 12), refButton],
          ),
        const SizedBox(height: 16),

        // Chapter Progress bar
        Container(
          padding: EdgeInsets.only(bottom: sm ? 24 : 20),
          margin: EdgeInsets.only(bottom: sm ? 32 : 24),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200),
            ),
          ),
          child: Row(
            children: [
              Text(
                'PROGRESS',
                style: TextStyle(
                  fontSize: sm ? 12 : 10,
                  height: sm ? 16 / 12 : 1.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: sm ? 1.2 : 1.0,
                  color: dark ? Colors.white.withValues(alpha: 0.4) : Tw.gray400,
                ),
              ),
              SizedBox(width: sm ? 16 : 12),
              Expanded(
                child: _ProgressTrack(
                  height: 10,
                  fraction: progress / 100,
                  track: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200,
                  color: progressColor,
                  glow: progress > 0 ? progressColor.withValues(alpha: 0x66 / 255) : null,
                  shimmer: progress > 0 && progress < 100,
                  duration: const Duration(milliseconds: 1000),
                ),
              ),
              SizedBox(width: sm ? 16 : 12),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 48),
                child: Text(
                  '$progress%',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                      fontSize: sm ? 14 : 12,
                      height: sm ? 20 / 14 : 16 / 12,
                      fontWeight: FontWeight.w900,
                      color: progressColor),
                ),
              ),
            ],
          ),
        ),

        if (_sheetLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 64),
            child: Center(child: _AccentSpinner(size: 32, stroke: 2)),
          )
        else if (_chapterActivities.isEmpty)
          Opacity(
            opacity: 0.4,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 48),
              child: Column(
                children: [
                  _HeroIcon(HeroPaths.inbox,
                      size: sm ? 48 : 40, strokeWidth: 1.5, color: dark ? Colors.white : Tw.gray500),
                  const SizedBox(height: 12),
                  Text('No activities in this chapter',
                      style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w600,
                          color: dark ? Colors.white : Tw.gray500)),
                ],
              ),
            ),
          )
        else
          _activityGrid(context),
      ],
    );
  }

  Widget _activityGrid(BuildContext context) {
    final sm = context.isSm;
    final cols = context.isXl ? 2 : 1;
    final gap = sm ? 24.0 : 16.0;
    return LayoutBuilder(
      builder: (context, c) {
        final cardW = (c.maxWidth - gap * (cols - 1)) / cols;
        final cards = [for (final act in _chapterActivities) _activityCard(context, act, cardW)];
        final rows = <Widget>[];
        for (var i = 0; i < cards.length; i += cols) {
          rows.add(cols == 1
              ? cards[i]
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: cards[i]),
                      SizedBox(width: gap),
                      Expanded(
                          child: i + 1 < cards.length ? cards[i + 1] : const SizedBox.shrink()),
                    ],
                  ),
                ));
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) SizedBox(height: gap),
              rows[r],
            ],
          ],
        );
      },
    );
  }

  Widget _activityCard(BuildContext context, _Json act, double cardWidth) {
    final dark = context.isDark;
    final sm = context.isSm;
    final stars = _getActivityStars(act);
    final filePath = jsDisplay(act['file_path']);
    final cardRadius = BorderRadius.circular(sm ? 32 : 24);
    final thumbRadius = BorderRadius.circular(sm ? 24 : 20);
    final subtitle = jsTruthy(act['topic_name'])
        ? jsDisplay(act['topic_name'])
        : jsDisplay(act['description_preview']);

    // card width − border − p-[0.875rem]
    final innerW = cardWidth - 2 - 28;
    final thumbW = math.max(85.0, innerW * 0.28);
    final infoW = innerW - thumbW - (sm ? 20 : 12);

    return HoverBuilder(
      cursor: MouseCursor.defer,
      builder: (context, hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: cardRadius,
          color: dark
              ? Colors.white.withValues(alpha: hovered ? 0.1 : 0.05)
              : (hovered ? Tw.gray100 : Tw.gray50),
          border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200),
        ),
        child: Stack(
          children: [
            // Completion glow overlay (`absolute inset-0` over the padding box)
            if (stars >= 5)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: cardRadius,
                      border: Border.all(color: const Color.fromRGBO(74, 222, 128, 0.2)),
                      gradient: const CssLinearGradient(
                        angle: 135,
                        colors: [Color.fromRGBO(74, 222, 128, 0.06), Color.fromRGBO(74, 222, 128, 0)],
                        stops: [0, 0.6],
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Thumbnail
                    Container(
                      width: thumbW,
                      constraints: const BoxConstraints(minHeight: 110),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        borderRadius: thumbRadius,
                        color: dark ? Colors.black.withValues(alpha: 0.2) : Tw.gray200,
                        border: Border.all(
                            color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200),
                      ),
                      child: Stack(
                        children: [
                          if (filePath.isNotEmpty)
                            Positioned.fill(
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 500),
                                scale: hovered ? 1.1 : 1,
                                child: AnimatedOpacity(
                                  duration: const Duration(milliseconds: 500),
                                  opacity: hovered ? 1 : 0.8,
                                  child: Image.network(
                                    filePath,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                                  ),
                                ),
                              ),
                            )
                          else
                            Positioned.fill(
                              child: Opacity(
                                opacity: 0.2,
                                child: Center(
                                  child: _HeroIcon(HeroPaths.playCircle,
                                      size: sm ? 48 : 40,
                                      strokeWidth: 1.5,
                                      color: dark ? Colors.white : Tw.gray400),
                                ),
                              ),
                            ),
                          if (stars > 0)
                            Positioned(
                              top: 6,
                              left: 6,
                              child: Container(
                                width: 24,
                                height: 24,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _accent,
                                  boxShadow: AppShadows.lg,
                                ),
                                child: Text('$stars★',
                                    style: const TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.w900,
                                        color: _onAccent)),
                              ),
                            ),
                          Positioned.fill(
                            child: IgnorePointer(
                              child: Opacity(
                                opacity: 0.6,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                      colors: dark
                                          ? [_darkPageBg, _darkPageBg.withValues(alpha: 0)]
                                          : [_lightPageBg, _lightPageBg.withValues(alpha: 0)],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: sm ? 20 : 12),
                    // Info + Buttons
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(0, sm ? 4 : 2, sm ? 8 : 4, sm ? 4 : 2),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              jsDisplay(act['name']),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: sm ? 18 : 16,
                                height: 1.25,
                                fontWeight: FontWeight.w700,
                                color: dark ? Colors.white : Tw.gray900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: sm ? 12 : 11,
                                height: sm ? 16 / 12 : 1.5,
                                fontWeight: FontWeight.w500,
                                color: dark ? Colors.white.withValues(alpha: 0.5) : Tw.gray500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                for (var s = 1; s <= 5; s++) ...[
                                  if (s > 1) const SizedBox(width: 4),
                                  _StarIcon(
                                    size: 14,
                                    filled: s <= stars,
                                    color: currentStarColor(stars),
                                    emptyStroke: dark
                                        ? Colors.white.withValues(alpha: 0.2)
                                        : Colors.black.withValues(alpha: 0.15),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: sm ? 12 : 8),
                            const Spacer(),
                            _cardButtons(context, act, infoW - (sm ? 8 : 4)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// `flex flex-wrap items-center gap-2 sm:gap-3` — Why Learn?, Quiz and a
  /// `flex-grow` LAUNCH button, broken into lines like CSS flex-wrap.
  Widget _cardButtons(BuildContext context, _Json act, double width) {
    final dark = context.isDark;
    final sm = context.isSm;
    final gap = sm ? 12.0 : 8.0;
    final why = _ChipButton(
      label: 'WHY LEARN?',
      onTap: () => _fire(() => _openWhyToLearn(act)),
      bg: dark ? Tw.indigo500.withValues(alpha: 0.15) : Tw.indigo50,
      hoverBg: dark ? Tw.indigo500.withValues(alpha: 0.25) : Tw.indigo100,
      fg: dark ? Tw.indigo300 : Tw.indigo700,
      border: dark ? Tw.indigo500.withValues(alpha: 0.2) : Tw.indigo200,
    );
    final quiz = _ChipButton(
      label: 'QUIZ',
      onTap: () => _fire(() => _openQuiz(act)),
      bg: dark ? Tw.pink500.withValues(alpha: 0.15) : Tw.pink50,
      hoverBg: dark ? Tw.pink500.withValues(alpha: 0.25) : Tw.pink100,
      fg: dark ? Tw.pink300 : Tw.pink700,
      border: dark ? Tw.pink500.withValues(alpha: 0.2) : Tw.pink200,
    );
    final launch = _LaunchButton(onTap: () => _launchActivity(act));

    final chipFont = sm ? 10.0 : 9.0;
    double chipW(String label) =>
        _textWidth(label, chipFont, FontWeight.w900, chipFont * 0.05) + (sm ? 32 : 24) + 2;
    final launchMin = _textWidth('LAUNCH', sm ? 12 : 10, FontWeight.w900, 0) + (sm ? 8 : 6) + 12;

    final items = <(Widget, double, bool)>[
      (why, chipW('WHY LEARN?'), false),
      (quiz, chipW('QUIZ'), false),
      (launch, launchMin, true),
    ];
    final lines = <List<(Widget, double, bool)>>[];
    var used = 0.0;
    for (final it in items) {
      if (lines.isEmpty || used + gap + it.$2 > width) {
        lines.add([it]);
        used = it.$2;
      } else {
        lines.last.add(it);
        used += gap + it.$2;
      }
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var l = 0; l < lines.length; l++) ...[
          if (l > 0) SizedBox(height: gap),
          Row(
            children: [
              for (var k = 0; k < lines[l].length; k++) ...[
                if (k > 0) SizedBox(width: gap),
                if (lines[l][k].$3) Expanded(child: lines[l][k].$1) else lines[l][k].$1,
              ],
            ],
          ),
        ],
      ],
    );
  }

  static double _textWidth(String text, double size, FontWeight weight, double letterSpacing) {
    final tp = TextPainter(
      text: TextSpan(
          text: text,
          style: _pageFont.copyWith(fontSize: size, fontWeight: weight, letterSpacing: letterSpacing)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final w = tp.width;
    tp.dispose();
    return w;
  }
}

// ── widgets ─────────────────────────────────────────────────────────────────

/// An inline heroicon `<svg viewBox="0 0 24 24" fill="none"
/// stroke="currentColor">` (SVG default butt caps / miter joins), or a
/// filled one.
class _HeroIcon extends StatelessWidget {
  const _HeroIcon(this.data, {required this.size, this.strokeWidth = 2, this.color, this.fill = false});
  final String data;
  final double size;
  final double strokeWidth;
  final Color? color;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    final c = color ?? IconTheme.of(context).color ?? DefaultTextStyle.of(context).style.color ?? Colors.black;
    return CustomPaint(
      size: Size.square(size),
      painter: _HeroIconPainter(data, c, strokeWidth, fill),
    );
  }
}

class _HeroIconPainter extends CustomPainter {
  const _HeroIconPainter(this.data, this.color, this.strokeWidth, this.fill);
  final String data;
  final Color color;
  final double strokeWidth;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    canvas.drawPath(
      svgPath(data),
      fill
          ? (Paint()..color = color)
          : (Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth
            ..color = color),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_HeroIconPainter old) =>
      old.data != data || old.color != color || old.strokeWidth != strokeWidth || old.fill != fill;
}

/// `rounded-full border-[3px] animate-spin` with `border-color: accent33;
/// border-top-color: accent` — a faint ring whose top quarter is solid,
/// turning once a second.
class _AccentSpinner extends StatefulWidget {
  const _AccentSpinner({required this.size, required this.stroke});
  final double size;
  final double stroke;

  @override
  State<_AccentSpinner> createState() => _AccentSpinnerState();
}

class _AccentSpinnerState extends State<_AccentSpinner> with SingleTickerProviderStateMixin {
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
        child: CustomPaint(
          size: Size.square(widget.size),
          painter: _RingPainter(stroke: widget.stroke),
        ),
      );
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.stroke});
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawOval(rect, paint..color = _accent.withValues(alpha: 0x33 / 255));
    // The top border runs between the 45° corner joins.
    canvas.drawArc(rect, -math.pi * 3 / 4, math.pi / 2, false, paint..color = _accent);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.stroke != stroke;
}

/// A native `<button>` (default cursor) with `hover:scale-105`.
class _BannerBackButton extends StatelessWidget {
  const _BannerBackButton({required this.showLabel, required this.onTap});
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = Colors.white.withValues(alpha: 0.8);
    return HoverBuilder(
      onTap: onTap,
      cursor: SystemMouseCursors.basic,
      builder: (context, hovered) => AnimatedScale(
        scale: hovered ? 1.05 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: showLabel ? 16 : 12, vertical: showLabel ? 8 : 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: hovered ? Colors.white.withValues(alpha: 0.1) : Colors.transparent,
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          // text-xs sm:text-sm line box
          child: SizedBox(
            height: showLabel ? 20 : 16,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(BootstrapIcons.chevron_left, size: showLabel ? 14 : 12, color: fg),
                if (showLabel) ...[
                  const SizedBox(width: 8),
                  Text('Back',
                      style: TextStyle(
                          fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: fg)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The roadmap's "Scroll →" chip (`backdrop-blur-md hover:scale-105`).
class _ScrollChip extends StatelessWidget {
  const _ScrollChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    return HoverBuilder(
      onTap: onTap,
      cursor: SystemMouseCursors.basic,
      builder: (context, hovered) {
        final fg = dark ? Colors.white.withValues(alpha: 0.6) : Tw.gray500;
        return AnimatedScale(
          scale: hovered ? 1.05 : 1,
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
                      ? Colors.white.withValues(alpha: hovered ? 0.1 : 0.05)
                      : (hovered ? Tw.gray100 : Colors.white.withValues(alpha: 0.5)),
                  border: Border.all(
                      color: dark ? Colors.white.withValues(alpha: 0.2) : Tw.gray300),
                ),
                child: SizedBox(
                  height: 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Scroll',
                          style: TextStyle(
                              fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: fg)),
                      SizedBox(width: sm ? 6 : 4),
                      Icon(BootstrapIcons.arrow_right, size: 12, color: fg),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// "Chapter Reference" button (`rounded-xl border text-xs sm:text-sm
/// hover:scale-105`, document icon `w-4 h-4 sm:w-5 sm:h-5`).
class _OutlineChip extends StatelessWidget {
  const _OutlineChip({required this.onTap, required this.label});
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final fg = dark ? Colors.white.withValues(alpha: 0.7) : Tw.gray600;
    return HoverBuilder(
      onTap: onTap,
      cursor: SystemMouseCursors.basic,
      builder: (context, hovered) => AnimatedScale(
        scale: hovered ? 1.05 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sm ? 16 : 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            color: hovered
                ? (dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray50)
                : Colors.transparent,
            border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.2) : Tw.gray300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _HeroIcon(HeroPaths.document, size: sm ? 20 : 16, color: fg),
              const SizedBox(width: 8),
              Text(label,
                  style: TextStyle(
                      fontSize: sm ? 14 : 12,
                      height: sm ? 20 / 14 : 16 / 12,
                      fontWeight: FontWeight.w600,
                      color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Why Learn? / Quiz chips (`text-[9px] sm:text-[10px] font-black py-2
/// sm:py-2.5 px-3 sm:px-4 rounded-xl uppercase tracking-wider border`).
class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.label,
    required this.onTap,
    required this.bg,
    required this.hoverBg,
    required this.fg,
    required this.border,
  });
  final String label;
  final VoidCallback onTap;
  final Color bg;
  final Color hoverBg;
  final Color fg;
  final Color border;

  @override
  Widget build(BuildContext context) {
    final sm = context.isSm;
    final size = sm ? 10.0 : 9.0;
    return HoverBuilder(
      onTap: onTap,
      cursor: SystemMouseCursors.basic,
      builder: (context, hovered) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(horizontal: sm ? 16 : 12, vertical: sm ? 10 : 8),
        decoration: BoxDecoration(
          color: hovered ? hoverBg : bg,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: border),
        ),
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
              fontSize: size,
              height: 1.5,
              fontWeight: FontWeight.w900,
              letterSpacing: size * 0.05,
              color: fg),
        ),
      ),
    );
  }
}

/// `LAUNCH ▶` — accent background, `#003a1d` text, `rounded-xl shadow-md
/// hover:opacity-90`.
class _LaunchButton extends StatelessWidget {
  const _LaunchButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sm = context.isSm;
    return HoverBuilder(
      onTap: onTap,
      cursor: SystemMouseCursors.basic,
      builder: (context, hovered) => AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: hovered ? 0.9 : 1,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: sm ? 10 : 8),
          decoration: BoxDecoration(
            color: _accent,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            boxShadow: AppShadows.md,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('LAUNCH',
                  style: TextStyle(
                      fontSize: sm ? 12 : 10,
                      height: sm ? 16 / 12 : 1.5,
                      fontWeight: FontWeight.w900,
                      color: _onAccent)),
              SizedBox(width: sm ? 8 : 6),
              const _HeroIcon(HeroPaths.play, size: 12, color: _onAccent, fill: true),
            ],
          ),
        ),
      ),
    );
  }
}

/// A rounded `overflow-hidden` track whose fill animates to [fraction]; the
/// fill's glow and shimmer are clipped by the track (not by the fill).
class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({
    required this.height,
    required this.fraction,
    required this.track,
    required this.color,
    required this.duration,
    this.glow,
    this.shimmer = false,
  });
  final double height;
  final double fraction;
  final Color track;
  final Color color;
  final Duration duration;
  final Color? glow;
  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    final f = fraction.isNaN ? 0.0 : fraction.clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: height,
        color: track,
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: duration,
          curve: Curves.easeOut,
          widthFactor: f,
          heightFactor: 1,
          child: Stack(
            clipBehavior: Clip.none,
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: glow == null ? null : [cssShadow(0, 0, 10, 0, glow!)],
                ),
              ),
              if (shimmer) const _Shimmer(),
            ],
          ),
        ),
      ),
    );
  }
}

/// `.shimmer-bar::after` — a light band sweeping across every 2s (`ease`).
class _Shimmer extends StatefulWidget {
  const _Shimmer();

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, c) => AnimatedBuilder(
          animation: _c,
          builder: (context, _) => Transform.translate(
            // translateX(-100%) → translateX(200%)
            offset: Offset(c.maxWidth * (-1 + 3 * Curves.ease.transform(_c.value)), 0),
            child: const DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(999)),
                gradient: LinearGradient(
                  colors: [Color(0x00FFFFFF), Color(0x4DFFFFFF), Color(0x00FFFFFF)],
                ),
              ),
              child: SizedBox.expand(),
            ),
          ),
        ),
      );
}

/// The `bg-rose-500 animate-pulse` dot with its `#f43f5e` glow.
class _PulseDot extends StatefulWidget {
  const _PulseDot({required this.size});
  final double size;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = _c.value;
          final v = t < 0.5 ? t * 2 : (1 - t) * 2;
          // pulse: 50% { opacity: .5 }, cubic-bezier(0.4, 0, 0.6, 1)
          return Opacity(
              opacity: 1 - 0.5 * const Cubic(0.4, 0, 0.6, 1).transform(v), child: child);
        },
        child: Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Tw.rose500,
            boxShadow: [cssShadow(0, 0, 10, 0, _roseGlow)],
          ),
        ),
      );
}

/// A keyframe loop `0%,100% {from} 50% {to}` of translate + scale, eased
/// per segment (`ease-in-out infinite`) — the banner glows' drift.
class _Drift extends StatefulWidget {
  const _Drift({required this.period, required this.from, required this.to, required this.child});
  final Duration period;
  final (Offset, double) from;
  final (Offset, double) to;
  final Widget child;

  @override
  State<_Drift> createState() => _DriftState();
}

class _DriftState extends State<_Drift> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: widget.period)..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = _c.value;
          final e = Curves.easeInOut.transform(t < 0.5 ? t * 2 : (1 - t) * 2);
          final offset = Offset.lerp(widget.from.$1, widget.to.$1, e)!;
          final scale = ui.lerpDouble(widget.from.$2, widget.to.$2, e)!;
          return Transform.translate(
            offset: offset,
            child: Transform.scale(scale: scale, child: child),
          );
        },
        child: widget.child,
      );
}

/// `.floating-icon` — `float-icon 4s infinite ease-in-out` (translateY 0 →
/// −15px, rotate 0 → 5deg) after an `animation-delay`.
class _Float extends StatefulWidget {
  const _Float({required this.delay, required this.child});
  final Duration delay;
  final Widget child;

  @override
  State<_Float> createState() => _FloatState();
}

class _FloatState extends State<_Float> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 4));
  Timer? _start;

  @override
  void initState() {
    super.initState();
    if (widget.delay == Duration.zero) {
      _c.repeat();
    } else {
      _start = Timer(widget.delay, () {
        if (mounted) _c.repeat();
      });
    }
  }

  @override
  void dispose() {
    _start?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = _c.value;
          final e = Curves.easeInOut.transform(t < 0.5 ? t * 2 : (1 - t) * 2);
          return Transform.translate(
            offset: Offset(0, -15 * e),
            child: Transform.rotate(angle: e * 5 * math.pi / 180, child: child),
          );
        },
        child: widget.child,
      );
}

/// The 5-point star SVG (`w-3.5 h-3.5`, stroke-width 2), filled or outlined;
/// a filled star has `filter: drop-shadow(0 0 3px <color>88)`.
class _StarIcon extends StatelessWidget {
  const _StarIcon({
    required this.size,
    required this.filled,
    required this.color,
    required this.emptyStroke,
  });
  final double size;
  final bool filled;
  final Color color;
  final Color emptyStroke;

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: Size.square(size),
        painter: _StarPainter(
          fill: filled ? color : null,
          stroke: filled ? color : emptyStroke,
          glow: filled ? color.withValues(alpha: 0x88 / 255) : null,
        ),
      );
}

// ── painters ────────────────────────────────────────────────────────────────

class _StarPainter extends CustomPainter {
  const _StarPainter({required this.fill, required this.stroke, this.glow});
  final Color? fill;
  final Color stroke;
  final Color? glow;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final path = svgPath(HeroPaths.star).transform(Matrix4.diagonal3Values(s, s, 1).storage);
    if (glow != null) {
      // drop-shadow blur 3px is the standard deviation → sigma 3
      final shadow = Paint()
        ..color = glow!
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      canvas.drawPath(path, shadow);
      canvas.drawPath(
          path,
          Paint()
            ..color = glow!
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2 * s
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5));
    }
    if (fill != null) canvas.drawPath(path, Paint()..color = fill!);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2 * s
        ..color = stroke,
    );
  }

  @override
  bool shouldRepaint(_StarPainter old) => old.fill != fill || old.stroke != stroke || old.glow != glow;
}

/// The activity board's box: background, 1px side borders and the 4px
/// accent top border painted like a browser does with a 2.5rem radius (the
/// top colour wraps into the corners up to the outer→inner corner diagonal).
class _BoardBorderPainter extends CustomPainter {
  const _BoardBorderPainter({required this.background, required this.side, required this.top});
  final Color background;
  final Color side;
  final Color top;

  static const _r = 40.0;
  static const _topW = 4.0;
  static const _sideW = 1.0;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final outer = RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(_r));
    final inner = RRect.fromLTRBAndCorners(
      _sideW,
      _topW,
      w - _sideW,
      h - _sideW,
      topLeft: const Radius.elliptical(_r - _sideW, _r - _topW),
      topRight: const Radius.elliptical(_r - _sideW, _r - _topW),
      bottomLeft: const Radius.circular(_r - _sideW),
      bottomRight: const Radius.circular(_r - _sideW),
    );
    canvas.drawRRect(outer, Paint()..color = background);
    canvas.drawDRRect(outer, inner, Paint()..color = side);
    canvas.save();
    // Side/top colour boundaries: rays from the outer corners through the
    // inner corners (slope _topW / _sideW).
    const k = _r / _topW;
    canvas.clipPath(Path()
      ..addPolygon([
        Offset.zero,
        Offset(w, 0),
        Offset(w - _sideW * k, _r),
        const Offset(_sideW * k, _r),
      ], true));
    canvas.drawDRRect(outer, inner, Paint()..color = top);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BoardBorderPainter old) =>
      old.background != background || old.side != side || old.top != top;
}

/// `<circle r="10" stroke-dasharray="4 4">`.
class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5 * s
      ..color = Colors.white;
    final path = Path()..addOval(Rect.fromCircle(center: Offset(12 * s, 12 * s), radius: 10 * s));
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 8 * s) {
        canvas.drawPath(m.extractPath(d, math.min(d + 4 * s, m.length)), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// `<rect x="3" y="3" width="18" height="18" rx="2">`.
class _RoundedSquarePainter extends CustomPainter {
  const _RoundedSquarePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(3 * s, 3 * s, 18 * s, 18 * s), Radius.circular(2 * s)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5 * s
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// `.pattern-overlay` — white dots every 30px at 10% (layer opacity .5).
class _DotPatternPainter extends CustomPainter {
  const _DotPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.05);
    for (var x = 15.0; x < size.width; x += 30) {
      for (var y = 15.0; y < size.height; y += 30) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The roadmap's 40px grid lines.
class _GridPainter extends CustomPainter {
  const _GridPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var x = 0.0; x < size.width; x += 40) {
      canvas.drawRect(Rect.fromLTWH(x, 0, 1, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 40) {
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, 1), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}

/// The road: a 44px translucent band + a dashed accent centre line.
class _RoadPainter extends CustomPainter {
  const _RoadPainter({required this.points, required this.base});
  final List<Offset> points;
  final Color base;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final path = roadPath(points);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 44
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = base,
    );
    final dash = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = _accent.withValues(alpha: 0.65);
    for (final m in path.computeMetrics()) {
      for (var d = 0.0; d < m.length; d += 32) {
        canvas.drawPath(m.extractPath(d, math.min(d + 14, m.length)), dash);
      }
    }
  }

  @override
  bool shouldRepaint(_RoadPainter old) => old.points != points || old.base != base;
}

/// The milestone flag (`viewBox 0 0 24 32` in a 48×56 box) with its drop
/// shadow.
class _FlagPainter extends CustomPainter {
  const _FlagPainter({required this.fill, required this.stroke});
  final Color fill;
  final Color stroke;

  @override
  void paint(Canvas canvas, Size size) {
    // preserveAspectRatio xMidYMid meet → uniform scale, centred.
    final s = math.min(size.width / 24, size.height / 32);
    final dx = (size.width - 24 * s) / 2;
    final dy = (size.height - 32 * s) / 2;

    Path shapes() => Path()
      ..addOval(Rect.fromCenter(center: const Offset(5, 30), width: 16, height: 6))
      ..addRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(4, 2, 2, 28), const Radius.circular(1)))
      ..addPolygon(const [Offset(6, 4), Offset(22, 9), Offset(6, 14)], true);

    canvas.save();
    // drop-shadow(0 8px 10px rgba(0,0,0,0.55)): the CSS blur is a standard
    // deviation (10px), divided by the canvas scale.
    canvas.translate(dx, dy + 8);
    canvas.scale(s);
    canvas.drawPath(
      shapes(),
      Paint()
        ..color = const Color.fromRGBO(0, 0, 0, 0.55)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 / s),
    );
    canvas.restore();

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(s);
    canvas.drawOval(Rect.fromCenter(center: const Offset(5, 30), width: 16, height: 6),
        Paint()..color = const Color.fromRGBO(0, 0, 0, 0.35));
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(4, 2, 2, 28), const Radius.circular(1)),
        Paint()..color = const Color(0xFFCBD5E1));
    final flag = Path()..addPolygon(const [Offset(6, 4), Offset(22, 9), Offset(6, 14)], true);
    canvas.drawPath(flag, Paint()..color = fill);
    canvas.drawPath(
      flag,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..strokeJoin = StrokeJoin.round
        ..color = stroke,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_FlagPainter old) => old.fill != fill || old.stroke != stroke;
}
