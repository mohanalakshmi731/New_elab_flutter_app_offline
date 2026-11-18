part of 'zones_page.dart';

/// ACTIVITY BOARD — the selected chapter's activities as a grid or a list.
extension _Board on _ZonePageState {
  Widget _buildBoard(bool isStudent) {
    final active = _activeChapter;
    if (active == null) return _loading ? const SizedBox.shrink() : _boardNoChapter();

    final dark = context.isDark;
    final colors = context.colors;
    final sm = context.isSm;
    final acts = _currentChapterActivities;

    final Widget body;
    if (_sheetLoading) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const RingSpinner(size: 32, stroke: 2),
            const SizedBox(width: 12),
            Opacity(
              opacity: 0.4,
              child: Text('Loading activities…',
                  style: zt(14, FontWeight.w700, dark ? Colors.white : Tw.gray500, height: 20 / 14)),
            ),
          ],
        ),
      );
    } else if (acts.isEmpty) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Opacity(
          opacity: 0.4,
          child: Column(
            children: [
              Icon(BootstrapIcons.inbox, size: 36, color: dark ? Tw.slate600 : Tw.gray300),
              const SizedBox(height: 12),
              Text('No activities in this chapter',
                  style: zt(14, FontWeight.w900, dark ? Tw.slate500 : Tw.gray400, height: 20 / 14)),
            ],
          ),
        ),
      );
    } else if (_isGrid) {
      body = _activityGrid(acts, isStudent);
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < acts.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            _ActivityRow(
              activity: acts[i],
              isStudent: isStudent,
              stars: _getActivityStars(acts[i]),
              starColor: _currentStarColor(_getActivityStars(acts[i])),
              thumbDark: _style.listThumbDark,
              onStart: () => _goToActivity(acts[i]),
              onQuiz: () => _goToQuiz(acts[i]),
            ),
          ],
        ],
      );
    }

    final progress = _chapterProgress;
    final titleSize = sm ? 24.0 : 20.0;

    return TopAccentBox(
      radius: 32,
      color: dark ? _style.boardDarkBg : Colors.white,
      borderColor: dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.1),
      topColor: colors.primary,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Chapter header
          Padding(
            padding: const EdgeInsets.only(bottom: 8 + 20),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 24,
                  decoration: BoxDecoration(color: colors.primary, borderRadius: BorderRadius.circular(999)),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    jsStr(active['name']) ?? '',
                    style: zt(titleSize, FontWeight.w900, dark ? Colors.white : Tw.gray900, height: 1.25),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: dark ? Colors.white.withValues(alpha: 0.06) : Tw.gray100,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('${acts.length} activities',
                      style: zt(12, FontWeight.w700, dark ? Tw.slate400 : Tw.gray500, height: 16 / 12)),
                ),
              ],
            ),
          ),

          // Progress bar
          if (isStudent)
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray100),
                ),
              ),
              child: Row(
                children: [
                  Opacity(
                    opacity: 0.4,
                    child: Text('PROGRESS',
                        style: zt(10, FontWeight.w900, dark ? Colors.white : Tw.gray600,
                            spacing: 1, height: 1.5)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        height: 8,
                        alignment: Alignment.centerLeft,
                        color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200,
                        child: AnimatedFractionallySizedBox(
                          duration: const Duration(milliseconds: 1000),
                          curve: kTwEaseOut,
                          widthFactor: pctFraction(progress),
                          heightFactor: 1,
                          child: ColoredBox(color: colors.primary),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text('${jsNumDisplay(progress)}%',
                      style: zt(12, FontWeight.w900, colors.primary, height: 16 / 12)),
                ],
              ),
            ),

          body,
        ],
      ),
    );
  }

  /// "Tap a milestone flag to load activities".
  ///
  /// The box has both `bg-white/85 border-white/20` and (light)
  /// `bg-white border-gray-200`; Tailwind 4 emits `bg-white/85` after
  /// `bg-white` and `border-white/20` after `border-gray-200`, so those win.
  /// In dark mode the `dark:` variants win over `bg-white/[0.03]
  /// border-white/[0.07]`.
  Widget _boardNoChapter() {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 16),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: dark ? Tw.slate800.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.2),
        ),
        boxShadow: AppShadows.xs,
      ),
      child: Column(
        children: [
          Opacity(
            opacity: 0.3,
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(BootstrapIcons.flag, size: 30, color: dark ? Colors.white : Tw.gray500),
            ),
          ),
          const SizedBox(height: 16),
          Opacity(
            opacity: 0.4,
            child: Text(
              'Tap a milestone flag to load activities',
              textAlign: TextAlign.center,
              style: zt(14, FontWeight.w900, dark ? Colors.white : Tw.gray600, height: 20 / 14),
            ),
          ),
        ],
      ),
    );
  }

  /// `grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-4 sm:gap-5`
  /// (rows share the tallest card's height, like a CSS grid row).
  Widget _activityGrid(List<Json> acts, bool isStudent) {
    final cols = context.isXl ? 4 : (context.isLg ? 3 : (context.isSm ? 2 : 1));
    final gap = context.isSm ? 20.0 : 16.0;
    final rows = <Widget>[];
    for (var start = 0; start < acts.length; start += cols) {
      final cells = <Widget>[];
      for (var c = 0; c < cols; c++) {
        if (c > 0) cells.add(SizedBox(width: gap));
        final i = start + c;
        cells.add(Expanded(
          child: i < acts.length
              ? _ActivityCard(
                  activity: acts[i],
                  isStudent: isStudent,
                  stars: _getActivityStars(acts[i]),
                  starColor: _currentStarColor(_getActivityStars(acts[i])),
                  fadeDark: _style.thumbFadeDark,
                  onStart: () => _goToActivity(acts[i]),
                  onQuiz: () => _goToQuiz(acts[i]),
                )
              : const SizedBox.shrink(),
        ));
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
      rows.add(IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

/// Primary / secondary action button of the cards and rows:
/// `rounded-xl` (20px) `text-xs font-black hover:opacity-90`, with a
/// `text-sm` icon whose 20px line box sets the content height.
class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
    required this.onTap,
    required this.padding,
    required this.shadow,
    this.gap = 8,
    this.expand = false,
    this.pressScale = 0.95,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;
  final EdgeInsets padding;
  final double gap;
  final bool expand;
  final List<BoxShadow> shadow;

  /// `active:scale-95` (grid buttons only).
  final double pressScale;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: zt(12, FontWeight.w900, foreground, height: 16 / 12),
    );
    return ZonePressable(
      onTap: onTap,
      pressScale: pressScale,
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(20),
          boxShadow: shadow,
        ),
        child: Row(
          mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20, child: Center(child: Icon(icon, size: 14, color: foreground))),
            SizedBox(width: gap),
            // Flexible only when the button has a bounded width (w-full).
            if (expand) Flexible(child: text) else text,
          ],
        ),
      ),
    );
  }
}

/// A row of 5 stars (`v-for="star in 5"`), plus "Not attempted" at 0.
class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.stars, required this.color});
  final double stars;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Row(
      children: [
        for (var star = 1; star <= 5; star++) ...[
          if (star > 1) const SizedBox(width: 4),
          CustomPaint(
            size: const Size.square(16),
            painter: StarPainter(
              fill: star <= stars ? color : null,
              stroke: star <= stars
                  ? color
                  : (dark ? Colors.white.withValues(alpha: 0.2) : Colors.black.withValues(alpha: 0.15)),
              strokeWidth: 2,
              glow: star <= stars ? color.withValues(alpha: 0x88 / 255) : null,
            ),
          ),
        ],
        if (stars == 0) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Opacity(
              opacity: 0.4,
              child: Text('Not attempted',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: zt(10, FontWeight.w600, dark ? Colors.white : Tw.gray500, height: 1.5)),
            ),
          ),
        ],
      ],
    );
  }
}

/// GRID VIEW card.
class _ActivityCard extends StatefulWidget {
  const _ActivityCard({
    required this.activity,
    required this.isStudent,
    required this.stars,
    required this.starColor,
    required this.fadeDark,
    required this.onStart,
    required this.onQuiz,
  });

  final Json activity;
  final bool isStudent;
  final double stars;
  final Color starColor;
  final Color fadeDark;
  final VoidCallback onStart;
  final VoidCallback onQuiz;

  @override
  State<_ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<_ActivityCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final colors = context.colors;
    final primary = colors.primary;
    final a = widget.activity;
    final stars = widget.stars;
    final filePath = a['file_path'];
    final topic = a['topic_name'];
    final hover = _hover;

    // shadow-[0_0_0_1px_…,_0_10px_30px_-10px_…] / hover:shadow-[0_0_0_2px_…,_0_20px_40px_-12px_…]
    final List<BoxShadow> shadow;
    if (hover) {
      shadow = dark
          ? [
              cssShadow(0, 0, 0, 2, const Color.fromRGBO(129, 140, 248, 0.3)),
              cssShadow(0, 20, 40, -12, const Color.fromRGBO(0, 0, 0, 0.5)),
            ]
          : [
              cssShadow(0, 0, 0, 2, const Color.fromRGBO(99, 102, 241, 0.2)),
              cssShadow(0, 20, 40, -12, const Color.fromRGBO(99, 102, 241, 0.18)),
            ];
    } else {
      shadow = dark
          ? [
              cssShadow(0, 0, 0, 1, const Color.fromRGBO(129, 140, 248, 0.15)),
              cssShadow(0, 10, 30, -10, const Color.fromRGBO(0, 0, 0, 0.3)),
            ]
          : [
              cssShadow(0, 0, 0, 1, const Color.fromRGBO(99, 102, 241, 0.08)),
              cssShadow(0, 10, 30, -10, const Color.fromRGBO(99, 102, 241, 0.08)),
            ];
    }

    final fade = dark ? widget.fadeDark : Colors.white;
    final thumbnail = SizedBox(
      height: 160,
      child: ColoredBox(
        color: dark ? Colors.black.withValues(alpha: 0.3) : Tw.gray100,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (jsTruthy(filePath))
              AnimatedScale(
                scale: hover ? 1.05 : 1,
                duration: const Duration(milliseconds: 500),
                curve: kTwEase,
                child: AnimatedOpacity(
                  opacity: hover ? 1 : 0.9,
                  duration: const Duration(milliseconds: 500),
                  curve: kTwEase,
                  child: contentImage(
                    jsStr(filePath)!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => const SizedBox.shrink(),
                  ),
                ),
              )
            else
              Center(
                child: Opacity(
                  opacity: 0.2,
                  child: Icon(BootstrapIcons.play_circle, size: 48, color: dark ? Colors.white : Tw.gray400),
                ),
              ),
            // Bottom fade
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 48,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [fade, fade.withValues(alpha: 0)],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (jsTruthy(topic))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      jsStr(topic)!.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: zt(10, FontWeight.w900, dark ? Tw.slate500 : Tw.gray400,
                          spacing: 1.5, height: 1.5),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    jsStr(a['name']) ?? '',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: zt(13, FontWeight.w900,
                        hover ? primary : (dark ? Tw.slate100 : Tw.gray900),
                        height: 1.375),
                  ),
                ),
                if (widget.isStudent) _StarsRow(stars: stars, color: widget.starColor),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Start Activity',
                  icon: BootstrapIcons.play_fill,
                  background: primary,
                  foreground: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shadow: AppShadows.md,
                  expand: true,
                  onTap: widget.onStart,
                ),
              ),
              if (widget.isStudent) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _ActionButton(
                    label: 'Start Quiz',
                    icon: BootstrapIcons.patch_question_fill,
                    background: colors.secondary,
                    foreground: colors.onSecondary,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shadow: AppShadows.md,
                    expand: true,
                    onTap: widget.onQuiz,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: kTwEase,
        transform: Matrix4.translationValues(0, hover ? -4 : 0, 0),
        decoration: BoxDecoration(
          color: dark ? Tw.slate900.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: hover
                ? (dark ? Tw.indigo500.withValues(alpha: 0.8) : Tw.indigo400)
                : (dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate200),
          ),
          boxShadow: shadow,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [thumbnail, Expanded(child: body)],
              ),
              // Completion glow overlay
              if (widget.isStudent && stars >= 5)
                Positioned.fill(
                  child: IgnorePointer(
                    child: Opacity(
                      opacity: 0.15,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: primary),
                          // linear-gradient(135deg, var(--primary) 0%, transparent 60%)
                          gradient: CssLinearGradient(
                            angle: 135,
                            colors: [primary, primary.withValues(alpha: 0)],
                            stops: const [0, 0.6],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              // Completion badge
              if (widget.isStudent && stars > 0)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: stars >= 5 ? primary : colors.secondary,
                      boxShadow: AppShadows.lg,
                    ),
                    child: Text('${jsNumDisplay(stars)}★',
                        style: zt(9, FontWeight.w900, colors.onPrimary, height: 1)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// LIST VIEW row.
class _ActivityRow extends StatefulWidget {
  const _ActivityRow({
    required this.activity,
    required this.isStudent,
    required this.stars,
    required this.starColor,
    required this.thumbDark,
    required this.onStart,
    required this.onQuiz,
  });

  final Json activity;
  final bool isStudent;
  final double stars;
  final Color starColor;
  final Color thumbDark;
  final VoidCallback onStart;
  final VoidCallback onQuiz;

  @override
  State<_ActivityRow> createState() => _ActivityRowState();
}

class _ActivityRowState extends State<_ActivityRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final colors = context.colors;
    final primary = colors.primary;
    final a = widget.activity;
    final stars = widget.stars;
    final filePath = a['file_path'];
    final topic = a['topic_name'];

    // w-12 h-12 rounded-xl (20px) overflow-hidden border
    final thumb = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.08) : Tw.gray100),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19),
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(
              color: dark ? widget.thumbDark : primary.withValues(alpha: 0.05),
              child: Center(
                child: Icon(BootstrapIcons.play_fill,
                    size: 16, color: dark ? Tw.slate600 : primary.withValues(alpha: 0.7)),
              ),
            ),
            if (jsTruthy(filePath))
              contentImage(
                jsStr(filePath)!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            if (widget.isStudent && stars > 0)
              ColoredBox(
                color: Colors.black.withValues(alpha: 0.4),
                child: Center(
                  child: Text('${jsNumDisplay(stars)}★',
                      style: zt(10, FontWeight.w900, Colors.white, height: 1)),
                ),
              ),
          ],
        ),
      ),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Flexible(
              child: Text(
                jsStr(a['name']) ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: zt(14, FontWeight.w900, dark ? Tw.slate100 : Tw.gray900, height: 20 / 14),
              ),
            ),
            if (widget.isStudent && stars > 0) ...[
              const SizedBox(width: 8),
              for (var s = 1; s <= stars; s++) ...[
                if (s > 1) const SizedBox(width: 2),
                Icon(BootstrapIcons.star_fill, size: 10, color: widget.starColor),
              ],
            ],
          ],
        ),
        if (jsTruthy(topic))
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              jsStr(topic)!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: zt(11, FontWeight.w600, dark ? Tw.slate500 : Tw.gray400, height: 1.5),
            ),
          ),
      ],
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: kTwEase,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _hover
              ? (dark ? Colors.white.withValues(alpha: 0.05) : Tw.gray50)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            thumb,
            const SizedBox(width: 12),
            Expanded(child: info),
            const SizedBox(width: 12),
            // px-3 py-2 rounded-xl shadow hover:opacity-90 (no active:scale-95)
            _ActionButton(
              label: 'Start',
              icon: BootstrapIcons.play_fill,
              background: primary,
              foreground: colors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              gap: 6,
              shadow: AppShadows.base,
              pressScale: 1,
              onTap: widget.onStart,
            ),
            if (widget.isStudent) ...[
              const SizedBox(width: 8),
              _ActionButton(
                label: 'Quiz',
                icon: BootstrapIcons.patch_question_fill,
                background: colors.secondary,
                foreground: colors.onSecondary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                gap: 6,
                shadow: AppShadows.base,
                pressScale: 1,
                onTap: widget.onQuiz,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
