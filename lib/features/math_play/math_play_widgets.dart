part of 'math_play_page.dart';

/// Header, filter bar (chapter / level dropdowns, lock toggle) and the
/// loading / error / empty / grid states.
extension _MathPlayWidgets on _MathPlayPageState {
  // ══════════ HEADER ══════════
  Widget _buildHeader(bool dark, int filteredCount) {
    Widget pill({
      required Color fg,
      required Color bg,
      required Color border,
      IconData? icon,
      required List<InlineSpan> text,
      FontWeight weight = FontWeight.w900,
    }) =>
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, size: 11, color: fg), const SizedBox(width: 6)],
              Text.rich(TextSpan(children: text),
                  style: _nunito(size: 12, weight: weight, height: TwLeading.xs, color: fg)),
            ],
          ),
        );

    final countFg = dark ? Tw.slate400 : Tw.gray500;
    final badges = Wrap(
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: [
        pill(
          fg: countFg,
          bg: dark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
          border: dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.07),
          weight: FontWeight.w700,
          text: [
            TextSpan(text: '$filteredCount '),
            // <span class="opacity-50 ml-0.5">
            const WidgetSpan(child: SizedBox(width: 2)),
            TextSpan(text: 'activities', style: TextStyle(color: countFg.withValues(alpha: 0.5))),
          ],
        ),
        if (_lockedCount > 0)
          pill(
            fg: dark ? Tw.yellow400 : Tw.amber700,
            bg: dark ? Tw.yellow400.withValues(alpha: 0.1) : Tw.amber50,
            border: dark ? Tw.yellow400.withValues(alpha: 0.25) : Tw.amber200,
            icon: BootstrapIcons.lock_fill,
            text: [TextSpan(text: '$_lockedCount locked')],
          ),
        if (_unlockedCount > 0)
          pill(
            fg: dark ? Tw.green400 : Tw.green700,
            bg: dark ? Tw.green400.withValues(alpha: 0.1) : Tw.green50,
            border: dark ? Tw.green400.withValues(alpha: 0.25) : Tw.green200,
            icon: BootstrapIcons.unlock_fill,
            text: [TextSpan(text: '$_unlockedCount unlocked')],
          ),
      ],
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: kTwEase,
      decoration: BoxDecoration(
        color: dark ? _C.ink.withValues(alpha: 0.95) : Colors.white.withValues(alpha: 0.95),
        border: Border(
          bottom: BorderSide(
              color: dark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.07)),
        ),
        boxShadow: dark ? null : AppShadows.sm,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: LayoutBuilder(builder: (context, c) {
        // The badges are `shrink-0` (natural width) and the title `min-w-0`
        // (it truncates). Only when the badges alone would overflow do they
        // wrap (the web overflows there).
        final badgesMax = c.maxWidth - 44 - 12 - 16;
        return Row(
          children: [
            // Left: Logo + Subject Name
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: dark
                            ? [Tw.yellow400.withValues(alpha: 0.2), Tw.amber500.withValues(alpha: 0.2)]
                            : const [Tw.yellow400, Tw.amber500],
                      ),
                      border: dark ? Border.all(color: Tw.yellow400.withValues(alpha: 0.3)) : null,
                      // shadow-lg (its colour modifier has no effect)
                      boxShadow: AppShadows.lg,
                    ),
                    child: Icon(BootstrapIcons.play_fill, size: 18, color: dark ? Tw.yellow400 : Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('NOW PLAYING',
                            style: _nunito(
                                size: 10,
                                weight: FontWeight.w900,
                                spacing: 2.5,
                                height: 1,
                                color: dark ? Tw.yellow400 : Tw.yellow600)),
                        const SizedBox(height: 4),
                        Text(
                          _selectedSubjectName.isNotEmpty ? _selectedSubjectName : 'Subject',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _nunito(
                              size: 16, weight: FontWeight.w900, height: 1.25, color: dark ? Colors.white : Tw.gray900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Right: Badges
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: badgesMax < 0 ? 0 : badgesMax),
              child: badges,
            ),
          ],
        );
      }),
    );
  }

  // ══════════ FILTERS BAR ══════════
  Widget _buildFilters(BuildContext context, bool dark) {
    final chapter = _chapterDropdown(dark);
    final level = SizedBox(width: 176, child: _levelDropdown(dark));
    final lock = _lockToggle(dark);

    return GestureDetector(
      // @click.stop — clicks inside the bar don't close the menus via the root
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: LayoutBuilder(builder: (context, c) {
          // flex-wrap with `flex-1 min-w-[180px]` / `w-44` / shrink-0 items.
          final w = c.maxWidth;
          final lockW = _lockToggleWidth();
          const gap = 12.0;
          if (w >= 180 + gap + 176 + gap + lockW) {
            return Row(children: [
              Expanded(child: chapter),
              const SizedBox(width: gap),
              level,
              const SizedBox(width: gap),
              lock,
            ]);
          }
          final List<Widget> lines;
          if (w >= 180 + gap + 176) {
            lines = [
              Row(children: [Expanded(child: chapter), const SizedBox(width: gap), level]),
              Align(alignment: Alignment.centerLeft, child: lock),
            ];
          } else if (176 + gap + lockW <= w) {
            lines = [chapter, Row(children: [level, const SizedBox(width: gap), lock])];
          } else {
            lines = [
              chapter,
              Align(alignment: Alignment.centerLeft, child: level),
              Align(alignment: Alignment.centerLeft, child: lock),
            ];
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < lines.length; i++) ...[
                if (i > 0) const SizedBox(height: gap),
                lines[i],
              ],
            ],
          );
        }),
      ),
    );
  }

  /// Width of the lock pill toggle (`p-1` + three `px-3` buttons + `gap-1`).
  double _lockToggleWidth() {
    var total = 2 + 8 + 4.0 * 2; // border + p-1 + gaps
    for (final lf in _kLockFilterOptions) {
      final tp = TextPainter(
        text: TextSpan(text: lf.label, style: _nunito(size: 12, weight: FontWeight.w900)),
        textDirection: TextDirection.ltr,
      )..layout();
      total += 24 + 12 + 6 + tp.width;
      tp.dispose();
    }
    return total.ceilToDouble();
  }

  Widget _filterButton({
    required bool dark,
    required bool active,
    required bool open,
    required Color activeFg,
    required Color activeBg,
    required Color activeBorder,
    required Widget leading,
    required String label,
    required VoidCallback onTap,
  }) =>
      HoverBuilder(
        onTap: onTap,
        builder: (context, hover) {
          final Color fg, bg, border;
          if (active) {
            fg = activeFg;
            bg = activeBg;
            border = activeBorder;
          } else if (dark) {
            fg = Tw.slate300;
            bg = Colors.white.withValues(alpha: hover ? 0.07 : 0.04);
            border = Colors.white.withValues(alpha: hover ? 0.15 : 0.09);
          } else {
            fg = Tw.gray600;
            bg = hover ? Tw.gray50 : Colors.white;
            border = Colors.black.withValues(alpha: hover ? 0.14 : 0.09);
          }
          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: kTwEase,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 8),
                Expanded(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: _nunito(size: 14, weight: FontWeight.w700, height: TwLeading.sm, color: fg)),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: open ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  curve: kTwEase,
                  child: Icon(BootstrapIcons.chevron_down, size: 12, color: fg),
                ),
              ],
            ),
          );
        },
      );

  /// The dropdown panel under its button (`absolute top-full mt-2 left-0
  /// right-0 z-50`) with the 150 ms enter / 100 ms leave transition.
  Widget _menuPanel(OverlayChildLayoutInfo info, _AnimatedPortal menu, bool dark, Widget child) {
    if (info.childPaintTransform.determinant() == 0.0) return const SizedBox.shrink();
    final transform = info.childPaintTransform.clone()
      ..translateByDouble(0, info.childSize.height + 8, 0, 1);
    return Transform(
      transform: transform,
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: info.childSize.width,
          child: AnimatedBuilder(
            animation: menu.curved,
            builder: (context, c) {
              final v = menu.curved.value;
              return Opacity(
                opacity: v.clamp(0.0, 1.0),
                child: Transform.translate(
                  offset: Offset(0, -8 * (1 - v)),
                  child: Transform.scale(scale: 0.95 + 0.05 * v, child: c),
                ),
              );
            },
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: dark ? _C.card : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: dark ? Colors.white.withValues(alpha: 0.09) : Colors.black.withValues(alpha: 0.08)),
                // shadow-2xl (its colour modifier has no effect)
                boxShadow: AppShadows.xl2,
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem({
    required bool dark,
    required bool selected,
    required Color selectedFg,
    required Color selectedBg,
    required Widget leading,
    required String label,
    Widget? trailing,
    required VoidCallback onTap,
  }) =>
      HoverBuilder(
        onTap: onTap,
        builder: (context, hover) {
          final Color fg;
          final Color bg;
          if (selected) {
            fg = selectedFg;
            bg = selectedBg;
          } else if (dark) {
            fg = hover ? Tw.slate200 : Tw.slate400;
            bg = hover ? Colors.white.withValues(alpha: 0.05) : Colors.transparent;
          } else {
            fg = hover ? Tw.gray800 : Tw.gray500;
            bg = hover ? Tw.gray50 : Colors.transparent;
          }
          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            curve: kTwEase,
            color: bg,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                leading,
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: _nunito(
                          size: 14,
                          weight: selected ? FontWeight.w900 : FontWeight.w600,
                          height: TwLeading.sm,
                          color: fg)),
                ),
                if (trailing != null) IconTheme.merge(data: IconThemeData(color: fg), child: trailing),
              ],
            ),
          );
        },
      );

  // Chapter Dropdown
  Widget _chapterDropdown(bool dark) {
    final active = _selectedChapterId != 'all';
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _chapterMenu.portal,
      overlayChildBuilder: (context, info) => _menuPanel(
        info,
        _chapterMenu,
        dark,
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 256),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (final ch in _chapterOptions)
                _menuItem(
                  dark: dark,
                  selected: _selectedChapterId == ch.value,
                  selectedFg: dark ? Tw.yellow300 : Tw.yellow700,
                  selectedBg: dark ? Tw.yellow400.withValues(alpha: 0.15) : Tw.yellow50,
                  leading: AnimatedContainer(
                    duration: const Duration(milliseconds: 100),
                    curve: kTwEase,
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _selectedChapterId == ch.value
                          ? Tw.yellow400
                          : (dark ? Tw.slate700 : Tw.gray300),
                    ),
                  ),
                  label: ch.label,
                  onTap: () => _selectChapter(ch.value),
                ),
            ],
          ),
        ),
      ),
      child: _filterButton(
        dark: dark,
        active: active,
        open: _chapterOpen,
        activeFg: dark ? Tw.yellow300 : Tw.yellow700,
        activeBg: dark ? Tw.yellow400.withValues(alpha: 0.1) : Tw.yellow50,
        activeBorder: dark ? Tw.yellow400.withValues(alpha: 0.5) : Tw.yellow500.withValues(alpha: 0.6),
        leading: Opacity(
          opacity: 0.7,
          child: Icon(BootstrapIcons.journal_bookmark_fill,
              size: 14,
              color: active ? (dark ? Tw.yellow300 : Tw.yellow700) : (dark ? Tw.slate300 : Tw.gray600)),
        ),
        label: _selectedChapterLabel,
        onTap: () => _setMenus(chapter: !_chapterOpen, level: false),
      ),
    );
  }

  // Level Dropdown
  Widget _levelDropdown(bool dark) {
    final active = _selectedLevel != 'all';
    final selFg = dark ? Tw.purple300 : Tw.purple700;
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: _levelMenu.portal,
      overlayChildBuilder: (context, info) => _menuPanel(
        info,
        _levelMenu,
        dark,
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final lv in kLevelOptions)
                _menuItem(
                  dark: dark,
                  selected: _selectedLevel == lv.value,
                  selectedFg: selFg,
                  selectedBg: dark ? Tw.purple400.withValues(alpha: 0.15) : Tw.purple50,
                  leading: Text(lv.emoji, style: const TextStyle(fontSize: 14, height: 1)),
                  label: lv.label,
                  trailing: _selectedLevel == lv.value ? const Icon(BootstrapIcons.check2, size: 12) : null,
                  onTap: () => _selectLevel(lv.value),
                ),
            ],
          ),
        ),
      ),
      child: _filterButton(
        dark: dark,
        active: active,
        open: _levelOpen,
        activeFg: selFg,
        activeBg: dark ? Tw.purple400.withValues(alpha: 0.1) : Tw.purple50,
        activeBorder: Tw.purple400.withValues(alpha: dark ? 0.5 : 0.6),
        leading: Text(_levelEmoji, style: const TextStyle(fontSize: 14, height: 1)),
        label: _selectedLevelLabel,
        onTap: () => _setMenus(chapter: false, level: !_levelOpen),
      ),
    );
  }

  // Lock Status Pill Toggle
  Widget _lockToggle(bool dark) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: kTwEase,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: dark ? Colors.white.withValues(alpha: 0.04) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: dark ? Colors.white.withValues(alpha: 0.09) : Colors.black.withValues(alpha: 0.09)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < _kLockFilterOptions.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              () {
                final lf = _kLockFilterOptions[i];
                final selected = _selectedLockFilter == lf.value;
                return HoverBuilder(
                  onTap: () => _selectLockFilter(lf.value),
                  builder: (context, hover) {
                    final fg = selected
                        ? lf.activeFg
                        : dark
                            ? (hover ? Tw.slate300 : Tw.slate500)
                            : (hover ? Tw.gray600 : Tw.gray400);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      curve: kTwEase,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: selected ? lf.activeBg : Colors.transparent,
                        // rounded-xl (20 px in this theme)
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(lf.icon, size: 12, color: fg),
                          const SizedBox(width: 6),
                          Text(lf.label,
                              style: _nunito(size: 12, weight: FontWeight.w900, height: TwLeading.xs, color: fg)),
                        ],
                      ),
                    );
                  },
                );
              }(),
            ],
          ],
        ),
      );

  // ══════════ LOADING ══════════
  Widget _buildLoading(bool dark) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 128),
          child: Column(
            children: [
              // A static `border-4` ring + a `border-t-yellow-400 animate-spin` ring.
              BorderSpinner(
                size: 56,
                stroke: 4,
                track: Tw.yellow400.withValues(alpha: dark ? 0.2 : 0.3),
                head: Tw.yellow400,
                spinTrack: false,
              ),
              const SizedBox(height: 20),
              Text('Loading activities…',
                  style: _nunito(
                      size: 14,
                      weight: FontWeight.w700,
                      spacing: 0.35,
                      height: TwLeading.sm,
                      color: dark ? Tw.slate500 : Tw.gray400)),
            ],
          ),
        ),
      );

  // ══════════ ERROR ══════════
  Widget _buildError(bool dark) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 128),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: dark ? Tw.red500.withValues(alpha: 0.1) : Tw.red50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: dark ? Tw.red500.withValues(alpha: 0.25) : Tw.red200),
                ),
                child: const Icon(BootstrapIcons.exclamation_triangle_fill, size: 24, color: Tw.red400),
              ),
              const SizedBox(height: 16),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Text(_error ?? '',
                    textAlign: TextAlign.center,
                    style: _nunito(size: 14, weight: FontWeight.w700, height: TwLeading.sm, color: Tw.red400)),
              ),
              const SizedBox(height: 16),
              PressHover(
                onTap: _fetchData,
                builder: (context, hover, pressed) => ActiveScale(
                  pressed: pressed,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: kTwEase,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    decoration: BoxDecoration(
                      color: hover ? Tw.yellow300 : Tw.yellow400,
                      // rounded-xl (20 px in this theme)
                      borderRadius: BorderRadius.circular(20),
                      // shadow-lg (its colour modifier has no effect)
                      boxShadow: AppShadows.lg,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(BootstrapIcons.arrow_clockwise, size: 14, color: _C.ink),
                        const SizedBox(width: 8),
                        Text('Retry',
                            style: _nunito(size: 14, weight: FontWeight.w900, height: TwLeading.sm, color: _C.ink)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  // ══════════ EMPTY ══════════
  Widget _buildEmpty(bool dark) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 128),
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: dark ? Colors.white.withValues(alpha: 0.04) : Tw.gray100,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.07) : Tw.gray200),
                ),
                child: Icon(BootstrapIcons.inbox, size: 24, color: dark ? Tw.slate600 : Tw.gray300),
              ),
              const SizedBox(height: 12),
              Text('No activities found',
                  style: _nunito(
                      size: 14, weight: FontWeight.w900, height: TwLeading.sm, color: dark ? Tw.slate500 : Tw.gray400)),
              const SizedBox(height: 12),
              Text('Try adjusting your filters',
                  style: _nunito(
                      size: 12, weight: FontWeight.w600, height: TwLeading.xs, color: dark ? Tw.slate600 : Tw.gray400)),
            ],
          ),
        ),
      );

  // ══════════ CARD GRID ══════════
  Widget _buildGrid(BuildContext context, bool dark, List<Json> items) {
    // grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4 gap-5
    final cols = context.isXl ? 4 : (context.isLg ? 3 : (context.isSm ? 2 : 1));
    final rows = (items.length / cols).ceil();
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
      sliver: SliverList.builder(
        itemCount: rows,
        itemBuilder: (context, r) => Padding(
          padding: EdgeInsets.only(bottom: r == rows - 1 ? 0 : 20),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var c = 0; c < cols; c++) ...[
                  if (c > 0) const SizedBox(width: 20),
                  Expanded(
                    child: r * cols + c < items.length
                        ? _ActivityCard(
                            key: ValueKey('mp-${jsStr(items[r * cols + c]['id'])}'),
                            activity: items[r * cols + c],
                            dark: dark,
                            unlocking: _unlockingIds.contains(items[r * cols + c]['id']),
                            onPlay: () => _goToActivity(items[r * cols + c]),
                            onQuiz: () => _goToQuiz(items[r * cols + c]),
                            onUnlock: () => _onUnlockRequest(items[r * cols + c]),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `LOCK_FILTER_OPTIONS`.
final List<({String value, String label, IconData icon, Color activeFg, Color activeBg})> _kLockFilterOptions = [
  (
    value: 'all',
    label: 'All',
    icon: BootstrapIcons.grid_fill,
    activeFg: Tw.yellow400,
    activeBg: Tw.yellow400.withValues(alpha: 0.15),
  ),
  (
    value: 'unlocked',
    label: 'Free',
    icon: BootstrapIcons.unlock_fill,
    activeFg: Tw.green400,
    activeBg: Tw.green400.withValues(alpha: 0.15),
  ),
  (
    value: 'locked',
    label: 'Locked',
    icon: BootstrapIcons.lock_fill,
    activeFg: Tw.yellow400,
    activeBg: Tw.yellow400.withValues(alpha: 0.15),
  ),
];
