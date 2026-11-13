part of 'activity_library_page.dart';

/// Top bar, empty state, tab bar and the tab panels of activitylibrary.vue.
extension _ActivityWorkspace on _ActivityLibraryPageState {
  double get _stateHeight => (MediaQuery.sizeOf(context).height - 56 - 64 - 48).clamp(240.0, 4000.0);

  // ===== TOP NAV =====
  Widget _topNav(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final md = context.isMd;
    final lg = context.isLg;
    final titleSize = lg ? 18.0 : (md ? 16.0 : (sm ? 14.0 : 12.0));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Row(children: [
        _NavIconButton(
          icon: BootstrapIcons.chevron_left,
          iconSize: sm ? 16 : 14,
          radius: 99,
          onTap: _goBack,
        ),
        const SizedBox(width: 8),
        // `flex-1 flex justify-center px-1` > `text-center line-clamp-1
        // tracking-tight font-bold` (`text-slate-850` is not a Tailwind
        // colour, so the body's foreground shows).
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              _pageTitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: libNunito(
                fontSize: titleSize,
                height: twLeading(titleSize),
                fontWeight: FontWeight.w700,
                letterSpacing: -0.025 * titleSize,
                color: dark ? Colors.white : AppColors.foreground,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // `rounded-lg` is 16px in this theme.
        _NavIconButton(
          icon: BootstrapIcons.folder,
          iconSize: sm ? 20 : 18,
          radius: 16,
          onTap: () => _set(() => _openNotesSidebar = true),
        ),
      ]),
    );
  }

  // ===== MAIN CONTENT =====
  Widget _mainContent(BuildContext context) {
    final dark = context.isDark;
    if (_pageLoading) {
      return SizedBox(
        height: _stateHeight,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          SpinIcon(size: 36, color: LibColors.primary(context)),
          const SizedBox(height: 12),
          Text('Loading activity...',
              style: libNunito(fontSize: 16, height: 1.5, color: dark ? Tw.gray400 : Tw.gray500)),
        ]),
      );
    }
    if (!_hasActivities) return _noActivityState(context);
    return _workspace(context);
  }

  Widget _noActivityState(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final muted = dark ? Tw.gray400 : Tw.gray500;

    // `<Button variant="outline|ghost" class="w-full sm:w-auto hover:bg-muted
    // hover:text-primary p-3 rounded-full">` (the kit keeps `h-9`, and its
    // `dark:hover:bg-input/50` / `dark:hover:bg-accent/50`); the icon's `mr-2`
    // adds to the button's `gap-2`.
    Widget stateButton({
      required bool outline,
      required IconData icon,
      required String label,
      required VoidCallback onTap,
    }) =>
        AppButton(
          variant: outline ? AppButtonVariant.outline : AppButtonVariant.ghost,
          radius: 999,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          hoverBackgroundColor: dark
              ? (outline ? AppColors.darkInput.withValues(alpha: 0.5) : AppColors.accent.withValues(alpha: 0.5))
              : AppColors.muted,
          hoverForegroundColor: LibColors.primary(context),
          expand: !sm,
          onPressed: onTap,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14),
            const SizedBox(width: 16),
            Text(label, style: libNunito(fontSize: 14, fontWeight: FontWeight.w500)),
          ]),
        );

    final browse = stateButton(
      outline: true,
      icon: BootstrapIcons.folder,
      label: 'Browse Other Topics',
      onTap: () => _set(() => _openNotesSidebar = true),
    );
    final back = stateButton(
      outline: false,
      icon: BootstrapIcons.arrow_left,
      label: 'Back to Library',
      onTap: _goBack,
    );

    return SizedBox(
      height: _stateHeight,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 448),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(BootstrapIcons.inboxes, size: 60, color: dark ? Tw.gray600 : Tw.gray300),
              const SizedBox(height: 24),
              Text('No Activities Available',
                  textAlign: TextAlign.center,
                  style: libNunito(
                      fontSize: 20,
                      height: twLeading(20),
                      fontWeight: FontWeight.w600,
                      color: dark ? Tw.gray300 : Tw.gray700)),
              const SizedBox(height: 8),
              Text('There are no activities available for this topic.',
                  textAlign: TextAlign.center, style: libNunito(fontSize: 16, height: 1.5, color: muted)),
              if (jsTruthy(_topicName)) ...[
                const SizedBox(height: 4),
                Text.rich(
                  TextSpan(children: [
                    const TextSpan(text: 'Topic: '),
                    TextSpan(
                        text: vueText(_topicName),
                        style: libNunito(fontSize: 14, height: twLeading(14), fontWeight: FontWeight.w500)),
                  ]),
                  textAlign: TextAlign.center,
                  style: libNunito(fontSize: 14, height: twLeading(14), color: muted),
                ),
              ],
              const SizedBox(height: 24),
              // sm+: two inline buttons separated by the space between them;
              // phones: `w-full` buttons, `space-y-3`.
              if (sm)
                Wrap(alignment: WrapAlignment.center, spacing: 4, runSpacing: 12, children: [browse, back])
              else
                Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  browse,
                  const SizedBox(height: 12),
                  back,
                ]),
            ]),
          ),
        ),
      ),
    );
  }

  // ===== TAB-DRIVEN WORKSPACE =====
  Widget _workspace(BuildContext context) {
    final dark = context.isDark;
    final h = MediaQuery.sizeOf(context).height;
    final fixed = workspaceHasFixedHeight(_activeTab, _activeTabContent);

    final panelDecoration = BoxDecoration(
      color: dark ? Tw.slate900.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
          color: dark ? Tw.slate800.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.2)),
    );

    if (fixed) {
      return SizedBox(
        height: h * 0.85,
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _tabBar(context),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: panelDecoration,
              child: _isFullscreen ? const SizedBox.expand() : _panelBody(context, fill: true),
            ),
          ),
        ]),
      );
    }

    final bothUrlAndText = (_activeTab == 'teacher-guide' || _activeTab == 'learning-outcome') &&
        _activeTabContent.url.isNotEmpty &&
        _activeTabContent.text.isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _tabBar(context),
      const SizedBox(height: 16),
      Container(
        // min-height: 350px for the whole workspace (tab bar ≈ 52 + 16 gap).
        constraints: BoxConstraints(minHeight: bothUrlAndText ? 0 : 350 - 52 - 16),
        clipBehavior: Clip.antiAlias,
        decoration: panelDecoration,
        child: _isFullscreen ? const SizedBox() : _panelBody(context, fill: false),
      ),
    ]);
  }

  /// `px-1.5 py-1.5 bg-white/45 dark:bg-slate-900/45 border border-white/20
  /// dark:border-slate-800/60 rounded-2xl shadow-xs` (min-height 52px).
  Widget _tabBar(BuildContext context) {
    final dark = context.isDark;
    final tabs = _filteredTabs;
    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: dark ? Tw.slate800.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.2)),
        boxShadow: AppShadows.xs,
      ),
      // `flex gap-1 overflow-x-auto` with `flex-1` buttons: equal widths that
      // fill the bar, scrolling when they do not fit.
      child: LayoutBuilder(
        builder: (context, c) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: c.maxWidth),
            child: IntrinsicWidth(
              child: Row(children: [
                for (var i = 0; i < tabs.length; i++) ...[
                  if (i > 0) const SizedBox(width: 4),
                  Expanded(
                    child: _TabButton(
                      meta: _tabMeta[tabs[i]]!,
                      active: _activeTab == tabs[i],
                      onTap: () => _guard(() => _handleTabClick(tabs[i])),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ),
      ),
    );
  }

  /// The panel body (`ref="iframeWrapper"`) — also what goes fullscreen.
  Widget _panelBody(BuildContext context, {required bool fill}) {
    final content = _tabContent(context, fill: fill);
    return Stack(children: [
      if (fill) Positioned.fill(child: content) else content,
      if (_activeTab == 'activity')
        Positioned(
          bottom: 16,
          right: 16,
          child: _FullscreenButton(isFullscreen: _isFullscreen, onTap: _toggleFullscreen),
        ),
    ]);
  }

  Widget _tabContent(BuildContext context, {required bool fill}) {
    final dark = context.isDark;
    final h = MediaQuery.sizeOf(context).height;
    final muted = dark ? Tw.gray500 : Tw.gray400;

    /// `w-full h-full flex flex-col items-center justify-center`: centred in
    /// a fixed-height panel; in an auto-height panel `h-full` resolves to the
    /// content height, so it sits at the top.
    Widget centered(Widget child) => fill
        ? Center(child: child)
        : SizedBox(height: 350 - 52 - 16, child: Align(alignment: Alignment.topCenter, child: child));

    // ACTIVITY TAB
    if (_activeTab == 'activity') {
      if (_signedUrl.isNotEmpty) {
        return KeyedSubtree(key: _activityViewKey, child: WebContentView(url: _signedUrl));
      }
      return centered(Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(BootstrapIcons.hourglass_split, size: 36, color: muted),
        const SizedBox(height: 12),
        Text('Preparing activity...', style: libNunito(fontSize: 14, height: twLeading(14), color: muted)),
      ]));
    }

    // QUIZ TAB
    if (_activeTab == 'quiz') return _quizPanel(context);

    // CONTENT TABS
    if (_tabContentLoading) {
      return centered(Column(mainAxisSize: MainAxisSize.min, children: [
        SpinIcon(size: 30, color: dark ? Tw.indigo300 : Tw.indigo600),
        const SizedBox(height: 8),
        Text('Loading details...',
            style: libNunito(fontSize: 14, height: twLeading(14), color: dark ? Tw.gray400 : Tw.gray500)),
      ]));
    }

    if (_activeTab == 'reference-video') {
      final text = _activeTabContent.text;
      final view = text.isEmpty
          ? const SizedBox()
          : WebContentView(html: referenceVideoPage(text));
      return Padding(
        padding: const EdgeInsets.all(16),
        child: fill ? view : SizedBox(height: h * 0.85, child: view),
      );
    }

    final text = _activeTabContent.text;
    final url = _activeTabContent.url;
    if (text.isNotEmpty || url.isNotEmpty) {
      // <IsolatedHtmlContent> — `<iframe srcdoc>` 500px tall.
      Widget isolated() => SizedBox(
            height: 500,
            child: text.trim().isEmpty ? const SizedBox() : WebContentView(html: text),
          );

      if (url.isNotEmpty && text.isEmpty) {
        final view = WebContentView(url: url);
        return fill ? view : SizedBox(height: h * 0.85, child: view);
      }
      if (text.isNotEmpty && url.isEmpty) {
        return Align(alignment: Alignment.topCenter, child: isolated());
      }
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
        SizedBox(height: h * 0.85, child: WebContentView(url: url)),
        isolated(),
      ]);
    }

    return centered(Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(BootstrapIcons.inbox, size: 48, color: muted),
      const SizedBox(height: 12),
      Text('No content details available.',
          style: libNunito(fontSize: 14, height: twLeading(14), fontWeight: FontWeight.w500, color: muted)),
    ]));
  }

  // ===== QUIZ TAB =====
  Widget _quizPanel(BuildContext context) {
    final primary = LibColors.primary(context);

    // `px-5 py-2 bg-primary text-white rounded-lg` (16px radius here; the
    // text keeps the inherited 16px size).
    Widget primaryButton(String label, VoidCallback? onTap, {bool disabled = false}) => Opacity(
          opacity: disabled ? 0.5 : 1,
          child: MouseRegion(
            cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
            child: GestureDetector(
              onTap: disabled ? null : onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(color: primary, borderRadius: BorderRadius.circular(16)),
                child: Text(label, style: libNunito(fontSize: 16, height: 1.5, color: Colors.white)),
              ),
            ),
          ),
        );

    final heading = libNunito(fontSize: 18, height: twLeading(18), fontWeight: FontWeight.w600);

    final Widget body;
    if (_quizSubmitted) {
      body = Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(BootstrapIcons.check_circle, size: 48, color: Tw.green500),
        const SizedBox(height: 12),
        Text(vueText(dig(_quizResult, ['msg'])), textAlign: TextAlign.center, style: heading),
        const SizedBox(height: 8),
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'Questions Correct: '),
            TextSpan(
                text: vueText(dig(_quizResult, ['tickets'])),
                style: libNunito(fontSize: 14, height: twLeading(14), fontWeight: FontWeight.w700, color: primary)),
          ]),
          style: libNunito(fontSize: 14, height: twLeading(14), color: Tw.gray500),
        ),
        const SizedBox(height: 16),
        primaryButton('Retry Quiz', _resetQuiz),
      ]);
    } else if (!_quizStarted) {
      body = Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(BootstrapIcons.play_circle, size: 48, color: primary),
        const SizedBox(height: 12),
        Text('Start Quiz', style: heading),
        const SizedBox(height: 8),
        // `text-gray-500` (no dark variant).
        Text('Click below to begin the quiz.', style: libNunito(fontSize: 16, height: 1.5, color: Tw.gray500)),
        const SizedBox(height: 20),
        if (_isInstructorQuizMode) ...[
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 672),
            child: _quizSelectors(context),
          ),
          const SizedBox(height: 20),
        ],
        primaryButton('Start Quiz', () => _guard(_startQuiz), disabled: _quizStartDisabled),
        if (_quizSysSessionError.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(_quizSysSessionError,
              textAlign: TextAlign.center,
              style: libNunito(fontSize: 14, height: twLeading(14), fontWeight: FontWeight.w600, color: Tw.red500)),
        ],
      ]);
    } else if (_quizLoading) {
      body = Column(mainAxisSize: MainAxisSize.min, children: [
        SpinIcon(size: 24, color: primary),
        const SizedBox(height: 12),
        Text('Loading Quiz...', style: libNunito(fontSize: 16, height: 1.5)),
      ]);
    } else {
      body = const SizedBox();
    }

    // `text-center py-10 px-4` at the top of the panel.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Align(alignment: Alignment.topCenter, child: body),
    );
  }

  /// Instructor class / batch pickers (native `<select>`s with `rounded-xl
  /// border-slate-700 bg-slate-950/50 px-4 py-3 text-sm font-semibold
  /// text-white`, dark-styled in both themes like the web).
  Widget _quizSelectors(BuildContext context) {
    final decoration = BoxDecoration(
      color: Tw.slate950.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Tw.slate700),
    );
    final textStyle = libNunito(fontSize: 14, height: twLeading(14), fontWeight: FontWeight.w600, color: Colors.white);
    final labelStyle = libNunito(fontSize: 12, height: twLeading(12), fontWeight: FontWeight.w700, color: Tw.slate300);

    final classField = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Class', style: labelStyle),
      const SizedBox(height: 6),
      LibrarySelect<String>(
        value: _selectedQuizClassId,
        enabled: !_quizSelectionLoading,
        decoration: decoration,
        textStyle: textStyle,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minHeight: 46,
        items: [
          const AppSelectItem('', 'Select class'),
          for (final raw in _quizClassOptions)
            if (asMap(raw) case final c?) AppSelectItem(jsString(c['id']), vueText(c['name'])),
        ],
        onChanged: (v) {
          _set(() => _selectedQuizClassId = v);
          _guard(_onQuizClassChange);
        },
      ),
    ]);

    final batchField = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text('Batch', style: labelStyle),
      const SizedBox(height: 6),
      LibrarySelect<String>(
        value: _selectedQuizBatchId,
        enabled: !_quizBatchLoading && _selectedQuizClassId.isNotEmpty,
        decoration: decoration,
        textStyle: textStyle,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        minHeight: 46,
        items: [
          AppSelectItem('', _quizBatchLoading ? 'Loading batches...' : 'Select batch'),
          for (final raw in _quizBatchOptions)
            if (asMap(raw) case final b?) AppSelectItem(jsString(b['id']), vueText(b['name'])),
        ],
        onChanged: (v) => _set(() => _selectedQuizBatchId = v),
      ),
    ]);

    if (!context.isSm) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        classField,
        const SizedBox(height: 12),
        batchField,
      ]);
    }
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(child: classField),
      const SizedBox(width: 12),
      Expanded(child: batchField),
    ]);
  }
}

/// Round / rounded icon buttons of the top bar: `border
/// border-slate-200/60 dark:border-slate-800/80 w-8 h-8 sm:w-9 sm:h-9
/// bg-white/80 dark:bg-[#161e36] text-slate-700 dark:text-slate-200
/// hover:bg-indigo-50 dark:hover:bg-indigo-950/20 hover:text-indigo-600
/// shadow-sm`.
class _NavIconButton extends StatelessWidget {
  const _NavIconButton({
    required this.icon,
    required this.iconSize,
    required this.radius,
    required this.onTap,
  });

  final IconData icon;
  final double iconSize;
  final double radius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final size = context.isSm ? 36.0 : 32.0;
    return HoverLift(
      lift: 0,
      onTap: onTap,
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: hover
              ? (dark ? Tw.indigo950.withValues(alpha: 0.2) : Tw.indigo50)
              : (dark ? LibColors.sidebarBg : Colors.white.withValues(alpha: 0.8)),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
              color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate200.withValues(alpha: 0.6)),
          boxShadow: AppShadows.sm,
        ),
        // `dark:text-slate-200` comes after `hover:text-indigo-600` in the
        // CSS, so dark mode keeps slate-200 on hover.
        child: Icon(icon,
            size: iconSize,
            color: dark ? Tw.slate200 : (hover ? Tw.indigo600 : Tw.slate700)),
      ),
    );
  }
}

/// Tab button: `px-4 py-2 rounded-xl text-xs sm:text-sm font-bold border-0
/// flex-1`; active `bg-indigo-50/50 text-indigo-600 dark:bg-indigo-950/30
/// dark:text-indigo-400 shadow-xs` (its `border` loses to `border-0`, so no
/// border shows); otherwise `text-slate-500 hover:text-slate-700
/// dark:text-slate-400 hover:bg-slate-50/50 dark:hover:bg-slate-800/50`.
class _TabButton extends StatelessWidget {
  const _TabButton({required this.meta, required this.active, required this.onTap});

  final _TabMeta meta;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    return HoverLift(
      lift: 0,
      onTap: onTap,
      builder: (context, hover) {
        final fg = active
            ? (dark ? Tw.indigo400 : Tw.indigo600)
            : (dark ? Tw.slate400 : (hover ? Tw.slate700 : Tw.slate500));
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active
                ? (dark ? Tw.indigo950.withValues(alpha: 0.3) : Tw.indigo50.withValues(alpha: 0.5))
                : (hover
                    ? (dark ? Tw.slate800.withValues(alpha: 0.5) : Tw.slate50.withValues(alpha: 0.5))
                    : Colors.transparent),
            borderRadius: BorderRadius.circular(20),
            boxShadow: active ? AppShadows.xs : null,
          ),
          // The `bi` icon's line box (text-sm → 20px) sets the height.
          child: SizedBox(
            height: 20,
            child: Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
              Icon(meta.icon, size: 14, color: fg),
              if (sm) ...[
                const SizedBox(width: 6),
                Text(meta.label,
                    maxLines: 1,
                    softWrap: false,
                    style: libNunito(fontSize: 14, fontWeight: FontWeight.w700, color: fg)),
              ],
            ]),
          ),
        );
      },
    );
  }
}

/// `absolute bottom-4 right-4 w-12 h-12 rounded-full bg-black/70
/// hover:bg-black text-white shadow-xl hover:scale-110`.
class _FullscreenButton extends StatelessWidget {
  const _FullscreenButton({required this.isFullscreen, required this.onTap});

  final bool isFullscreen;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => HoverLift(
        lift: 0,
        onTap: onTap,
        builder: (context, hover) => AnimatedScale(
          scale: hover ? 1.1 : 1,
          duration: const Duration(milliseconds: 300),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: hover ? Colors.black : Colors.black.withValues(alpha: 0.7),
              shape: BoxShape.circle,
              boxShadow: AppShadows.xl,
            ),
            child: Icon(isFullscreen ? BootstrapIcons.fullscreen_exit : BootstrapIcons.fullscreen,
                size: 18, color: Colors.white),
          ),
        ),
      );
}
