part of 'student_math_zone_page.dart';

/// ══ ACTIVITY BOARD ══ — the selected chapter's header, progress bar and
/// activity cards.
extension _Board on _StudentMathZonePageState {
  Widget _board(Map<String, Json> perfMap) {
    final dark = context.isDark;
    final sm = context.isSm;
    final mx = sm ? 16.0 : 8.0;
    final chapter = _activeChapter;

    return Padding(
      padding: EdgeInsets.fromLTRB(mx, 16, mx, 16),
      child: _TopAccentCard(
        radius: 40,
        color: dark ? const Color.fromRGBO(38, 32, 75, 0.7) : Colors.white,
        borderColor: dark
            ? const Color.fromRGBO(255, 255, 255, 0.08)
            : const Color.fromRGBO(0, 0, 0, 0.1),
        topColor: _accent,
        child: ConstrainedBox(
          // min-height: 300px (border-box: minus the 4px top / 1px bottom borders)
          constraints: const BoxConstraints(minHeight: 300 - 5),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: chapter == null ? _boardEmpty(dark, sm) : _boardContent(chapter, perfMap),
          ),
        ),
      ),
    );
  }

  Widget _boardEmpty(bool dark, bool sm) {
    final color = dark ? Colors.white : Tw.gray600;
    // flex-grow: fills the 255px content box; py-12 around the content.
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 300 - 5 - 40),
      child: Center(
        child: Opacity(
          opacity: 0.4,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZoneSvgIcon(const [ZoneIcons.flag], size: sm ? 48 : 40, color: color, strokeWidth: 1.5),
                const SizedBox(height: 16),
                Text(
                  'Select a milestone flag on the road\nto unlock activities here',
                  textAlign: TextAlign.center,
                  style: _t(sm ? 18 : 16, FontWeight.w700, color, height: sm ? 28 / 18 : 1.5),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _boardContent(Json chapter, Map<String, Json> perfMap) {
    final dark = context.isDark;
    final sm = context.isSm;
    final progress = _chapterProgress(perfMap);
    final done = progress >= 100;
    final progressColor = done ? const Color(0xFF4ADE80) : _accent;

    final unit = _StudentMathZonePageState._or([chapter['unit'], _selectedSubjectName]);
    final titleBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: dark
                ? Colors.white.withValues(alpha: 0.1)
                : Colors.black.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            unit.toUpperCase(),
            style: _t(
              10,
              FontWeight.w900,
              dark ? Colors.white.withValues(alpha: 0.5) : Tw.gray400,
              height: 1.5,
              spacing: 1,
            ),
          ),
        ),
        Text(
          jsDisplay(chapter['name']),
          style: _t(sm ? 30 : 24, FontWeight.w900, dark ? Colors.white : Tw.gray900, height: 1.25),
        ),
        // The chapter stars / tickets row is `hidden` on the web; only its
        // mt-2 remains.
        const SizedBox(height: 8),
      ],
    );

    final refButton = _ChapterRefButton(onTap: _openChapterReferenceDialog, text: _t);

    final header = sm
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: titleBlock),
              const SizedBox(width: 12),
              refButton,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [titleBlock, const SizedBox(height: 12), refButton],
          );

    final progressRow = Container(
      margin: EdgeInsets.only(bottom: sm ? 32 : 24),
      padding: EdgeInsets.only(bottom: sm ? 24 : 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200),
        ),
      ),
      child: Row(
        children: [
          Text(
            done ? 'COMPLETED' : 'PROGRESS',
            softWrap: false,
            style: _t(
              sm ? 12 : 10,
              FontWeight.w700,
              dark ? Colors.white.withValues(alpha: 0.4) : Tw.gray400,
              spacing: (sm ? 12 : 10) * 0.1,
            ),
          ),
          SizedBox(width: sm ? 16 : 12),
          Expanded(
            child: _ProgressBar(
              pct: progress,
              color: progressColor,
              track: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200,
            ),
          ),
          SizedBox(width: sm ? 16 : 12),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 48),
            child: Text(
              '${jsNumText(progress)}%',
              textAlign: TextAlign.right,
              style: _t(sm ? 14 : 12, FontWeight.w900, progressColor),
            ),
          ),
        ],
      ),
    );

    final Widget activities;
    if (_sheetLoading) {
      activities = Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Center(
          child: ZoneRingSpinner(
            size: 32,
            stroke: 2,
            track: _accent.withValues(alpha: 0x33 / 255),
            head: _accent,
          ),
        ),
      );
    } else if (_chapterActivities.isEmpty) {
      final color = dark ? Colors.white : Tw.gray500;
      activities = Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Opacity(
          opacity: 0.4,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ZoneSvgIcon(const [ZoneIcons.inbox], size: sm ? 48 : 40, color: color, strokeWidth: 1.5),
              const SizedBox(height: 12),
              Text(
                'No activities in this chapter',
                style: _t(14, FontWeight.w600, color, height: 20 / 14),
              ),
            ],
          ),
        ),
      );
    } else {
      activities = _activityGrid(perfMap);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [header, const SizedBox(height: 16), progressRow, activities],
    );
  }

  /// `grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4 sm:gap-5`
  /// (rows share the tallest card's height, like a CSS grid row).
  Widget _activityGrid(Map<String, Json> perfMap) {
    final acts = _chapterActivities;
    final cols = context.isXl ? 3 : (context.isSm ? 2 : 1);
    final gap = context.isSm ? 20.0 : 16.0;
    final rows = <Widget>[];
    for (var start = 0; start < acts.length; start += cols) {
      final cells = <Widget>[];
      for (var c = 0; c < cols; c++) {
        if (c > 0) cells.add(SizedBox(width: gap));
        final i = start + c;
        if (i >= acts.length) {
          cells.add(const Expanded(child: SizedBox.shrink()));
          continue;
        }
        final act = acts[i];
        final stars = _activityStars(perfMap, act);
        cells.add(
          Expanded(
            child: _MzActivityCard(
              key: ValueKey(act['id'] ?? i),
              activity: act,
              stars: stars,
              accent: _accent,
              text: _t,
              onWhy: () => _openWhyToLearn(act),
              onQuiz: () => _openQuiz(act),
              onLaunch: () => _launchActivity(act),
            ),
          ),
        );
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
      rows.add(
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
        ),
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

/// A rounded box with `border: 1px` and a 4px `borderTop` in [topColor].
/// Flutter cannot combine non-uniform borders with a radius, so the top edge
/// is painted as a clipped strip.
class _TopAccentCard extends StatelessWidget {
  const _TopAccentCard({
    required this.child,
    required this.radius,
    required this.color,
    required this.borderColor,
    required this.topColor,
  });

  final Widget child;
  final double radius;
  final Color color;
  final Color borderColor;
  final Color topColor;

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    return ClipRRect(
      borderRadius: br,
      child: ColoredBox(
        color: color,
        child: Stack(
          children: [
            Padding(padding: const EdgeInsets.fromLTRB(1, 4, 1, 1), child: child),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: br,
                    border: Border.all(color: borderColor),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 0,
              height: 4,
              child: IgnorePointer(child: ColoredBox(color: topColor)),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Chapter Reference" outline button.
class _ChapterRefButton extends StatelessWidget {
  const _ChapterRefButton({required this.onTap, required this.text});
  final VoidCallback onTap;
  final _TextFn text;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final fg = dark ? Colors.white.withValues(alpha: 0.7) : Tw.gray600;
    return ZonePress(
      onTap: onTap,
      builder: (context, hover, _) => AnimatedScale(
        scale: hover ? 1.05 : 1,
        duration: const Duration(milliseconds: 150),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: sm ? 16 : 12, vertical: 8),
          decoration: BoxDecoration(
            // rounded-xl (20px in this theme)
            borderRadius: BorderRadius.circular(20),
            color: hover
                ? (dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray50)
                : Colors.transparent,
            border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.2) : Tw.gray300),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ZoneSvgIcon(const [ZoneIcons.documentText], size: sm ? 20 : 16, color: fg),
              const SizedBox(width: 8),
              Text(
                'Chapter Reference',
                style: text(sm ? 14 : 12, FontWeight.w600, fg, height: sm ? 20 / 14 : 16 / 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The chapter progress bar (h-2.5) with its glow and the shimmer that runs
/// while 0 < progress < 100.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.pct, required this.color, required this.track});
  final double pct;
  final Color color;
  final Color track;

  @override
  Widget build(BuildContext context) {
    final fraction = mzPctFraction(pct);
    final glow = pct > 0;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: Container(
        height: 10,
        color: track,
        alignment: Alignment.centerLeft,
        child: AnimatedFractionallySizedBox(
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeOut,
          widthFactor: fraction,
          heightFactor: 1,
          // The shimmer is not clipped by the fill (only by the track).
          child: Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(999),
              boxShadow: glow
                  ? [cssShadow(0, 0, 10, 0, color.withValues(alpha: 0x66 / 255))]
                  : null,
            ),
            child: pct > 0 && pct < 100 ? const _Shimmer() : null,
          ),
        ),
      ),
    );
  }
}

/// `.shimmer-bar::after` — a white highlight sweeping across the fill (2s).
class _Shimmer extends StatefulWidget {
  const _Shimmer();

  @override
  State<_Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<_Shimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

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
        offset: Offset(c.maxWidth * (-1 + 3 * _c.value), 0),
        child: const DecoratedBox(
          decoration: BoxDecoration(
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

/// One activity card of the board.
class _MzActivityCard extends StatefulWidget {
  const _MzActivityCard({
    super.key,
    required this.activity,
    required this.stars,
    required this.accent,
    required this.text,
    required this.onWhy,
    required this.onQuiz,
    required this.onLaunch,
  });

  final Json activity;
  final double stars;
  final Color accent;
  final _TextFn text;
  final VoidCallback onWhy;
  final VoidCallback onQuiz;
  final VoidCallback onLaunch;

  @override
  State<_MzActivityCard> createState() => _MzActivityCardState();
}

class _MzActivityCardState extends State<_MzActivityCard> {
  bool _hover = false;
  bool _imgFailed = false;

  @override
  void didUpdateWidget(_MzActivityCard old) {
    super.didUpdateWidget(old);
    if (old.activity['file_path'] != widget.activity['file_path']) _imgFailed = false;
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final act = widget.activity;
    final stars = widget.stars;
    final t = widget.text;
    final accent = widget.accent;
    final starColor = mzStarColor(stars);
    final radius = BorderRadius.circular(24);
    final filePath = act['file_path'];

    final thumb = SizedBox(
      height: 160,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(color: dark ? Colors.black.withValues(alpha: 0.3) : Tw.gray200),
          if (jsTruthy(filePath) && !_imgFailed)
            AnimatedScale(
              scale: _hover ? 1.05 : 1,
              duration: const Duration(milliseconds: 500),
              child: AnimatedOpacity(
                opacity: _hover ? 1 : 0.9,
                duration: const Duration(milliseconds: 500),
                child: Image.network(
                  jsDisplay(filePath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) {
                    // @error → display:none
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted && !_imgFailed) setState(() => _imgFailed = true);
                    });
                    return const SizedBox.shrink();
                  },
                ),
              ),
            )
          else if (!jsTruthy(filePath))
            Center(
              child: Opacity(
                opacity: 0.2,
                child: ZoneSvgIcon(
                  const [ZoneIcons.playTriangle, ZoneIcons.circle],
                  size: 56,
                  strokeWidth: 1.5,
                  color: dark ? Colors.white : Tw.gray400,
                ),
              ),
            ),
          // Completion badge
          if (stars > 0)
            Positioned(
              top: 8,
              left: 8,
              width: 28,
              height: 28,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: stars >= 5 ? const Color(0xFF4ADE80) : accent,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.lg,
                ),
                child: Text(
                  '${jsNumText(stars)}★',
                  style: t(9, FontWeight.w900, const Color(0xFF1A1200), height: 1),
                ),
              ),
            ),
          // Bottom fade
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 40,
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      dark ? const Color(0xFF1E1842) : Colors.white,
                      (dark ? const Color(0xFF1E1842) : Colors.white).withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    final starsRow = Row(
      children: [
        for (var s = 1; s <= 5; s++) ...[
          if (s > 1) const SizedBox(width: 4),
          CustomPaint(
            size: const Size.square(16),
            painter: ZoneStarPainter(
              fill: s <= stars ? starColor : null,
              stroke: s <= stars
                  ? starColor
                  : (dark
                        ? Colors.white.withValues(alpha: 0.2)
                        : Colors.black.withValues(alpha: 0.15)),
              strokeWidth: 2,
              glow: s <= stars ? starColor.withValues(alpha: 0x88 / 255) : null,
            ),
          ),
        ],
        if (stars == 0) ...[
          // gap-1 + ml-1
          const SizedBox(width: 8),
          Flexible(
            child: Opacity(
              opacity: 0.4,
              child: Text(
                'Not attempted',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t(10, FontWeight.w600, dark ? Colors.white : Tw.gray500),
              ),
            ),
          ),
        ],
      ],
    );

    final buttons = Row(
      children: [
        _TagButton(
          label: 'WHY LEARN?',
          onTap: widget.onWhy,
          text: t,
          bg: dark ? op(Tw.indigo500, 0.15) : Tw.indigo50,
          hoverBg: dark ? op(Tw.indigo500, 0.25) : Tw.indigo100,
          fg: dark ? Tw.indigo300 : Tw.indigo700,
          border: dark ? op(Tw.indigo500, 0.2) : Tw.indigo200,
        ),
        const SizedBox(width: 8),
        _TagButton(
          label: 'QUIZ',
          onTap: widget.onQuiz,
          text: t,
          bg: dark ? op(Tw.pink500, 0.15) : Tw.pink50,
          hoverBg: dark ? op(Tw.pink500, 0.25) : Tw.pink100,
          fg: dark ? Tw.pink300 : Tw.pink700,
          border: dark ? op(Tw.pink500, 0.2) : Tw.pink200,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ZonePress(
            onTap: widget.onLaunch,
            builder: (context, hover, _) => AnimatedOpacity(
              opacity: hover ? 0.9 : 1,
              duration: const Duration(milliseconds: 150),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: AppShadows.md,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'LAUNCH',
                      softWrap: false,
                      style: t(11, FontWeight.w900, const Color(0xFF161233), height: 1.5),
                    ),
                    const SizedBox(width: 6),
                    const ZoneSvgIcon(
                      [ZoneIcons.play],
                      size: 12,
                      filled: true,
                      color: Color(0xFF161233),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: radius,
        color: dark ? Colors.white.withValues(alpha: _hover ? 0.08 : 0.05) : Colors.white,
        border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200),
        boxShadow: !dark && _hover ? AppShadows.md : const [],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                thumb,
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jsDisplay(act['name']),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t(
                            16,
                            FontWeight.w700,
                            dark ? Colors.white : Tw.gray900,
                            height: 1.375,
                          ),
                        ),
                        const SizedBox(height: 12),
                        starsRow,
                        const Spacer(),
                        const SizedBox(height: 12 + 4),
                        buttons,
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Completion glow overlay
            if (stars >= 5)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: radius,
                      border: Border.all(color: const Color.fromRGBO(74, 222, 128, 0.2)),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [0, 0.6],
                        colors: [Color.fromRGBO(74, 222, 128, 0.06), Color(0x004ADE80)],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: card,
    );
  }
}

/// The small uppercase "Why Learn?" / "Quiz" buttons.
class _TagButton extends StatelessWidget {
  const _TagButton({
    required this.label,
    required this.onTap,
    required this.text,
    required this.bg,
    required this.hoverBg,
    required this.fg,
    required this.border,
  });

  final String label;
  final VoidCallback onTap;
  final _TextFn text;
  final Color bg;
  final Color hoverBg;
  final Color fg;
  final Color border;

  @override
  Widget build(BuildContext context) => ZonePress(
    onTap: onTap,
    builder: (context, hover, _) => AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: hover ? hoverBg : bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        softWrap: false,
        style: text(10, FontWeight.w900, fg, height: 1.5, spacing: 0.5),
      ),
    ),
  );
}
