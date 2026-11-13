part of 'student_activity_page.dart';

const _navbarBgVar = Color(0xFF0A0F1F); // --navbar-bg

/// The `fixed inset-0` layers of `studentactivitypage.vue`: right sidebar,
/// all-activities popup, learning-outcome modal and the performance dialog.
/// Each is a route on the root navigator (so it covers the shell, like the
/// web) whose content rebuilds with the page state.
extension _StudentActivityOverlays on _StudentActivityPageState {
  Future<void> _pushModal(_ModalSlot slot, Route<void> route, [VoidCallback? onGone]) async {
    slot.route = route;
    _set(() {});
    await Navigator.of(context, rootNavigator: true).push(route);
    if (identical(slot.route, route)) slot.route = null;
    _set(onGone ?? () {});
  }

  /// Sets the web flag (`openNotesSidebar = false` …) — removes the layer.
  void _closeModal(_ModalSlot slot, [VoidCallback? clearFlag]) {
    final r = slot.route;
    slot.route = null;
    _set(clearFlag ?? () {});
    if (r == null || !r.isActive) return;
    if (r.isCurrent) {
      r.navigator?.pop();
    } else {
      r.navigator?.removeRoute(r);
    }
  }

  Widget _live(Widget Function(BuildContext context) builder) => ValueListenableBuilder<int>(
        valueListenable: _rev,
        builder: (context, _, _) => builder(context),
      );

  // ===== RIGHT SIDEBAR (+ black/40 overlay) =====

  void _showSidebar() {
    // openNotesSidebar = true
    if (_sidebarSlot.route != null) return;
    _pushModal(
      _sidebarSlot,
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierLabel: 'Close menu',
        barrierColor: Colors.black.withValues(alpha: 0.4),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => _live(_sidebarPanel),
        transitionsBuilder: (_, anim, _, child) => SlideTransition(
          position: Tween(begin: const Offset(1, 0), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeInOut)),
          child: child,
        ),
      ),
    );
  }

  void _closeSidebar() => _closeModal(_sidebarSlot);

  Widget _sidebarPanel(BuildContext context) {
    final dark = context.isDark;
    final mq = MediaQuery.of(context);
    final w = mq.size.width;
    final width = w *
        (w >= 1280
            ? 0.22
            : w >= 1024
                ? 0.26
                : w >= 768
                    ? 0.38
                    : w >= 640
                        ? 0.55
                        : 0.80);
    final top = mq.padding.top + 56;
    final height = math.max(200.0, mq.size.height - mq.padding.top - 56 - 64);
    const radius = BorderRadius.horizontal(left: Radius.circular(16));

    final chapters = _filteredChapters;
    final topics = _topicsForSelectedChapter;
    final muted = dark ? Tw.gray400 : Tw.gray600;

    // `text-sm font-semibold uppercase tracking-wider pl-2`
    Widget label(String text) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(text.toUpperCase(),
              style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.7,
                  color: muted)),
        );

    // `text-center py-2` + `<i class="bi bi-arrow-repeat animate-spin text-accent" />`
    Widget spinLine(String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SpinIcon(size: 16, color: AppColors.accent),
              Text(' $text', style: const TextStyle(height: 1.5)),
            ],
          ),
        );

    // `text-center text-gray-500 dark:text-gray-400 py-2`
    Widget emptyLine(String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(text,
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5, color: dark ? Tw.gray400 : Tw.gray500)),
        );

    // `space-y-3` inside each group, `space-y-4` between the groups.
    const gap3 = SizedBox(height: 12);
    const gap4 = SizedBox(height: 16);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Chapter Select
        label('Select Chapter'),
        if (_loading) ...[gap3, spinLine('Loading chapters...')],
        gap3,
        _glassSelect(
          context,
          value: _selectedChapterId,
          items: [
            for (final c in chapters) AppSelectItem(jsStr(c['id']) ?? '', jsDisplay(c['name'])),
          ],
          placeholder: 'Choose a chapter',
          enabled: chapters.isNotEmpty && !_loading,
          onChanged: (v) {
            if (v == null || v == _selectedChapterId) return;
            _onChapterChange(v);
          },
        ),
        if (_error != null) ...[
          gap3,
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(_error!,
                style: const TextStyle(fontSize: 14, height: 20 / 14, color: Tw.red500)),
          ),
        ],
        gap4,

        // Topic Select
        if (_selectedChapterId.isNotEmpty) ...[
          label('Select Topic'),
          gap3,
          _glassSelect(
            context,
            value: jsStr(_topicId) ?? '',
            items: [
              for (final t in topics) AppSelectItem(jsStr(t['id']) ?? '', jsDisplay(t['name'])),
            ],
            placeholder: 'Choose a topic',
            enabled: true,
            onChanged: (v) {
              if (v == null || v == jsStr(_topicId)) return;
              _fire(() => _handleTopicClick(
                  topics.where((t) => jsStr(t['id']) == v).firstOrNull));
            },
          ),
          if (topics.isEmpty) ...[gap3, emptyLine('No topics in this chapter')],
          gap4,
        ],

        // Activity Select
        label('Select Activity'),
        gap3,
        _glassSelect(
          context,
          value: _selectedActivityId == null ? null : jsStr(_selectedActivityId),
          items: [
            for (final a in _allactivities)
              AppSelectItem(jsStr(a['id']) ?? '', jsDisplay(a['name'])),
          ],
          placeholder: 'Choose an activity',
          enabled: _allactivities.isNotEmpty,
          onChanged: (v) {
            if (v == null || v == jsStr(_selectedActivityId)) return;
            final picked = _allactivities.where((a) => jsStr(a['id']) == v).firstOrNull;
            _set(() => _selectedActivityId = picked?['id'] ?? v);
            _fire(_onActivityChange);
          },
        ),
        if (_allactivities.isEmpty) ...[gap3, emptyLine('No activities available')],
        if (_loadingActivity) ...[gap3, spinLine('Loading activity...')],
        gap4,

        _GlassMenuButton(
          onTap: _showActivityPopup,
          hoverGlow: true,
          child: const Text('VIEW ALL ACTIVITIES',
              style: TextStyle(
                  fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, letterSpacing: 0.35)),
        ),
        gap4,
        _GlassMenuButton(
          onTap: _closeSidebar,
          child: const Row(
            children: [
              Icon(BootstrapIcons.arrow_left, size: 16),
              SizedBox(width: 12),
              Text('Close Menu',
                  style: TextStyle(height: 1.5, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
            ],
          ),
        ),
      ],
    );

    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: EdgeInsets.only(top: top),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: radius,
            // shadow-[0_8px_32px_rgba(31,38,135,0.25)]
            boxShadow: [cssShadow(0, 8, 32, 0, const Color.fromRGBO(31, 38, 135, 0.25))],
          ),
          child: ClipRRect(
            borderRadius: radius,
            child: BackdropFilter(
              // backdrop-blur-2xl backdrop-saturate-150
              filter: cssBackdrop(blur: 40, saturate: 1.5),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: radius,
                  // bg-linear-to-bl
                  gradient: CssLinearGradient(
                    corner: Alignment.bottomLeft,
                    colors: dark
                        ? [
                            AppColors.sidebarBg.withValues(alpha: 0.4),
                            _navbarBgVar.withValues(alpha: 0.2),
                          ]
                        : [
                            Colors.white.withValues(alpha: 0.3),
                            Colors.white.withValues(alpha: 0.1),
                          ],
                  ),
                  border: Border.all(
                    color: dark
                        ? AppColors.darkBorder.withValues(alpha: 0.3)
                        : Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                child: Material(
                  type: MaterialType.transparency,
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                        fontSize: 16,
                        color: dark ? AppColors.sidebarText : AppColors.foreground),
                    child: IconTheme.merge(
                      data: IconThemeData(
                          color: dark ? AppColors.sidebarText : AppColors.foreground),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        child: content,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// The sidebar's `<Select>`s: `rounded-xl bg-white/20 dark:bg-(--sidebar-bg)/30
  /// border-white/30 dark:border-(--sidebar-border)/30 text-base font-medium`;
  /// the kit's `h-9` still applies (36px) and the value inherits the
  /// sidebar's text colour.
  Widget _glassSelect(
    BuildContext context, {
    required String? value,
    required List<AppSelectItem<String>> items,
    required String placeholder,
    required bool enabled,
    required ValueChanged<String?> onChanged,
  }) {
    final dark = context.isDark;
    return DefaultTextStyle.merge(
      style: const TextStyle(fontWeight: FontWeight.w500),
      child: AppSelect<String>(
        value: value,
        items: items,
        placeholder: placeholder,
        enabled: enabled,
        onChanged: onChanged,
        height: 36,
        radius: AppTheme.radiusXl,
        fontSize: 16,
        fillColor: dark
            ? AppColors.sidebarBg.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.2),
        borderColor: dark
            ? AppColors.darkBorder.withValues(alpha: 0.3)
            : Colors.white.withValues(alpha: 0.3),
        textColor: dark ? AppColors.sidebarText : AppColors.foreground,
      ),
    );
  }

  // ===== ALL ACTIVITY POPUP =====

  void _showActivityPopup() {
    // openActivityPopup = true
    if (_popupSlot.route != null) return;
    _pushModal(
      _popupSlot,
      DialogRoute<void>(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        useSafeArea: false,
        builder: (_) => _live(_activityPopup),
      ),
    );
  }

  Widget _activityPopup(BuildContext context) {
    final dark = context.isDark;
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final sm = w >= 640;
    final widthFactor = w >= 1280
        ? 0.75
        : w >= 1024
            ? 0.8
            : w >= 768
                ? 0.85
                : sm
                    ? 0.9
                    : 0.95;
    final cols = w >= 1280
        ? 4
        : w >= 1024
            ? 3
            : sm
                ? 2
                : 1;
    final headColor = dark ? AppColors.sidebarText : AppColors.foreground;
    final titleSize = w >= 768 ? 20.0 : (sm ? 18.0 : 16.0);

    final sections = <Widget>[
      for (final chapter in _allChapters) _popupChapter(context, chapter, cols),
      if (_allChapters.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: Icon(BootstrapIcons.inboxes, size: 36, color: dark ? Tw.gray400 : Tw.gray500),
              ),
              const SizedBox(height: 12),
              Text('No chapters available',
                  style: TextStyle(height: 1.5, color: dark ? Tw.gray400 : Tw.gray500)),
            ],
          ),
        ),
    ];

    // The `w-[…%]` widths resolve against the overlay's padded box (px-2 sm:px-4).
    final overlayPad = sm ? 16.0 : 8.0;
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: overlayPad),
        child: Material(
          color: dark ? AppColors.sidebarBg : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            side: BorderSide(color: dark ? AppColors.darkBorder : Colors.white),
          ),
          clipBehavior: Clip.antiAlias,
          child: SizedBox(
            width: (w - overlayPad * 2) * widthFactor,
            height: size.height * 0.85,
            child: Padding(
              padding: EdgeInsets.all(sm ? 20 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'All Activities - $_subjectName',
                          style: TextStyle(
                              fontSize: titleSize,
                              height: (sm ? 28 : 24) / titleSize,
                              fontWeight: FontWeight.w600,
                              color: AppColors.accent),
                        ),
                      ),
                      HoverBuilder(
                        onTap: () => _closeModal(_popupSlot),
                        builder: (_, _) => SizedBox(
                          height: 28,
                          child: Icon(BootstrapIcons.x_lg, size: 20, color: headColor),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: sm ? 16 : 12),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: sections,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// One chapter of the popup. The block margins collapse like the web's:
  /// h3 `mb-4` / topic heading `mt-5` -> 20px, a topic's `mb-2` / the next
  /// heading's `mt-5` -> 20px, the last `mb-2` folds into the chapter's `mb-8`.
  Widget _popupChapter(BuildContext context, _Json chapter, int cols) {
    final dark = context.isDark;
    final sm = context.isSm;
    final topics = _StudentActivityPageState._maps(chapter['topics']);
    final muted = dark ? Tw.gray500 : Tw.gray400;
    return Padding(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: dark ? Tw.gray700 : Tw.gray200)),
            ),
            child: Text(
              jsDisplay(chapter['name']),
              style: TextStyle(
                fontSize: sm ? 18 : 16,
                height: (sm ? 28 : 24) / (sm ? 18 : 16),
                fontWeight: FontWeight.w600,
                color: dark ? AppColors.sidebarText : AppColors.foreground,
              ),
            ),
          ),
          for (final topic in topics) ...[
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Row(
                children: [
                  const Icon(BootstrapIcons.bookmark_fill, size: 12, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      jsDisplay(topic['name']).toUpperCase(),
                      style: TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: muted),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            if (_StudentActivityPageState._maps(topic['activities']).isNotEmpty)
              _grid(
                cols,
                [
                  for (final activity in _StudentActivityPageState._maps(topic['activities']))
                    _PopupActivityCard(
                      activity: activity,
                      current: sameId(activity['id'], _selectedActivityId),
                      onTap: () => _fire(() => _handleActivityFromPopup(topic, activity)),
                    ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
                child: Text('No activities in this topic',
                    style: TextStyle(fontSize: 14, height: 20 / 14, color: muted)),
              ),
          ],
          if (topics.isEmpty) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('No topics in this chapter',
                  textAlign: TextAlign.center, style: TextStyle(height: 1.5, color: muted)),
            ),
          ],
        ],
      ),
    );
  }

  /// CSS grid with `gap-4`: equal-height cells per row.
  Widget _grid(int cols, List<Widget> cells) {
    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += cols) {
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var j = 0; j < cols; j++) ...[
              if (j > 0) const SizedBox(width: 16),
              Expanded(child: i + j < cells.length ? cells[i + j] : const SizedBox.shrink()),
            ],
          ],
        ),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: 16),
          rows[r],
        ],
      ],
    );
  }

  // ===== LEARNING OUTCOME MODAL =====

  void _showLearningOutcomeModal() {
    // showLearningOutcome = true
    if (_learningSlot.route != null) return;
    _pushModal(
      _learningSlot,
      DialogRoute<void>(
        context: context,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        builder: (_) => _live(_learningOutcomeBox),
      ),
    );
  }

  Widget _learningOutcomeBox(BuildContext context) {
    final dark = context.isDark;
    final md = context.isMd;
    final pad = EdgeInsets.all(md ? 24 : 16);
    final html = jsDisplay(_selectedActivity?['learning_outcome']);
    void close() => _closeModal(_learningSlot);
    final barColor = dark ? Tw.gray800 : Tw.gray50;
    final barBorder = BorderSide(color: dark ? Tw.gray700 : Tw.gray300);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 512),
          // rounded-2xl shadow-2xl
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: dark ? Tw.gray900 : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppShadows.xl2,
            ),
            child: Material(
              type: MaterialType.transparency,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: pad,
                    decoration: BoxDecoration(color: barColor, border: Border(bottom: barBorder)),
                    child: Row(
                      children: [
                        Icon(BootstrapIcons.lightbulb, color: AppColors.accent, size: md ? 20 : 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text('Learning Outcome',
                              style: TextStyle(
                                  fontSize: md ? 20 : 18,
                                  height: 28 / (md ? 20 : 18),
                                  fontWeight: FontWeight.w600,
                                  color: dark ? Colors.white : Tw.gray800)),
                        ),
                        // `text-xl p-1 rounded-full hover:bg-gray-200 dark:hover:bg-gray-700`
                        HoverBuilder(
                          onTap: close,
                          cursor: SystemMouseCursors.basic,
                          builder: (_, hovered) => Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: hovered ? (dark ? Tw.gray700 : Tw.gray200) : Colors.transparent,
                            ),
                            child: SizedBox(
                              width: 20,
                              height: 28,
                              child: Icon(BootstrapIcons.x_lg,
                                  size: 20,
                                  color: hovered
                                      ? (dark ? Colors.white : Tw.gray800)
                                      : (dark ? Tw.gray400 : Tw.gray500)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: pad,
                      child: html.isNotEmpty
                          ? MzHtmlText(
                              html,
                              style: TextStyle(
                                  fontSize: 16, height: 1.625, color: dark ? Tw.gray300 : Tw.gray700),
                            )
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 40,
                                    child: Icon(BootstrapIcons.lightbulb,
                                        size: 36, color: dark ? Tw.gray400 : Tw.gray500),
                                  ),
                                  const SizedBox(height: 12),
                                  Text('No learning outcome available.',
                                      style: TextStyle(
                                          height: 1.5, color: dark ? Tw.gray400 : Tw.gray500)),
                                ],
                              ),
                            ),
                    ),
                  ),
                  Container(
                    padding: pad,
                    decoration: BoxDecoration(color: barColor, border: Border(top: barBorder)),
                    alignment: md ? Alignment.centerLeft : null,
                    child: HoverBuilder(
                      onTap: close,
                      cursor: SystemMouseCursors.basic,
                      builder: (_, hovered) => Container(
                        width: md ? null : double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: hovered ? 0.9 : 1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                        ),
                        child: const Text('Close',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white, height: 1.5, fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== PERFORMANCE RECORDED DIALOG =====

  void _showPerformanceModal(String title, String message) {
    _set(() {
      _performanceTitle = title;
      _performanceMessage = message;
      _performanceVisible = true;
    });
    if (_performanceSlot.route != null || !mounted) return;
    _pushModal(
      _performanceSlot,
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierLabel: 'Close',
        barrierColor: Colors.black.withValues(alpha: 0.6),
        transitionDuration: const Duration(milliseconds: 300),
        reverseTransitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (_, _, _) => _live(_performanceBox),
        transitionsBuilder: (_, anim, _, child) {
          final a = CurvedAnimation(parent: anim, curve: Curves.easeOut, reverseCurve: Curves.easeIn);
          return FadeTransition(
            opacity: a,
            child: ScaleTransition(scale: Tween(begin: 0.95, end: 1.0).animate(a), child: child),
          );
        },
      ),
      () => _performanceVisible = false,
    );
  }

  Widget _performanceBox(BuildContext context) {
    final dark = context.isDark;
    if (!_performanceVisible) return const SizedBox.shrink();
    return Stack(
      children: [
        // backdrop-blur-xs (blur(4px))
        Positioned.fill(
          child: IgnorePointer(
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 384),
              child: Material(
                type: MaterialType.transparency,
                child: Container(
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: dark ? const [Tw.gray900, Tw.gray950] : const [Colors.white, Tw.gray50],
                    ),
                    border: Border.all(
                      color: dark
                          ? Tw.gray800.withValues(alpha: 0.5)
                          : Tw.gray200.withValues(alpha: 0.5),
                    ),
                    // shadow-2xl (the theme's 0 1px 3px rgb(0 0 0 / .25))
                    boxShadow: AppShadows.xl2,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        height: 8,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(colors: [Tw.green400, Tw.emerald500, Tw.teal500]),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                        child: Column(
                          children: [
                            SizedBox(
                              width: 64,
                              height: 64,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned.fill(
                                    child: _Ping(
                                      // blur-md = blur(12px)
                                      child: ImageFiltered(
                                        imageFilter: ui.ImageFilter.blur(
                                            sigmaX: 12, sigmaY: 12, tileMode: TileMode.decal),
                                        child: DecoratedBox(
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: dark
                                                ? Tw.green500.withValues(alpha: 0.1)
                                                : Tw.green400.withValues(alpha: 0.2),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: dark
                                              ? [
                                                  Tw.green500.withValues(alpha: 0.1),
                                                  Tw.emerald500.withValues(alpha: 0.1),
                                                ]
                                              : [
                                                  Tw.green400.withValues(alpha: 0.15),
                                                  Tw.emerald500.withValues(alpha: 0.15),
                                                ],
                                        ),
                                        border: Border.all(color: Tw.green500.withValues(alpha: 0.2)),
                                      ),
                                      child: Icon(BootstrapIcons.trophy,
                                          size: 30, color: dark ? Tw.green400 : Tw.green500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _performanceTitle,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                height: 28 / 18,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.45,
                                color: dark ? Colors.white : Tw.gray900,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              _performanceMessage,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.625,
                                fontWeight: FontWeight.w600,
                                color: dark ? Tw.gray400 : Tw.gray500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: dark
                              ? Tw.gray900.withValues(alpha: 0.5)
                              : Tw.gray50.withValues(alpha: 0.5),
                          border: Border(
                            top: BorderSide(
                                color: dark ? Tw.gray800.withValues(alpha: 0.8) : Tw.gray100),
                          ),
                        ),
                        child: HoverBuilder(
                          onTap: () =>
                              _closeModal(_performanceSlot, () => _performanceVisible = false),
                          cursor: SystemMouseCursors.basic,
                          builder: (_, hovered) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: hovered ? 0.9 : 1),
                              borderRadius: BorderRadius.circular(16),
                              // shadow-lg (`shadow-accent/20` has no effect on the
                              // theme's shadow variables)
                              boxShadow: AppShadows.lg,
                            ),
                            child: const Text(
                              'Okay',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 20 / 14,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.35,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// A sidebar button: glass tile, `hover:text-accent hover:border-accent
/// hover:scale-[1.04]`.
class _GlassMenuButton extends StatelessWidget {
  const _GlassMenuButton({required this.onTap, required this.child, this.hoverGlow = false});
  final VoidCallback onTap;
  final Widget child;

  /// `hover:shadow-[0_8px_30px_rgba(149,163,255,0.35)]` (VIEW ALL ACTIVITIES only).
  final bool hoverGlow;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return HoverBuilder(
      onTap: onTap,
      builder: (context, hovered) => AnimatedScale(
        duration: const Duration(milliseconds: 300),
        scale: hovered ? 1.04 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            color: hovered
                ? (dark ? _navbarBgVar.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.4))
                : (dark
                    ? AppColors.sidebarBg.withValues(alpha: 0.3)
                    : Colors.white.withValues(alpha: 0.2)),
            border: Border.all(
              color: hovered
                  ? AppColors.accent
                  : (dark
                      ? AppColors.darkBorder.withValues(alpha: 0.3)
                      : Colors.white.withValues(alpha: 0.3)),
            ),
            boxShadow: hovered && hoverGlow
                ? [cssShadow(0, 8, 30, 0, const Color.fromRGBO(149, 163, 255, 0.35))]
                : AppShadows.lg,
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: hovered ? AppColors.accent : null),
            child: IconTheme.merge(
              data: IconThemeData(color: hovered ? AppColors.accent : null),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

/// An activity card of the all-activities popup.
class _PopupActivityCard extends StatelessWidget {
  const _PopupActivityCard({required this.activity, required this.current, required this.onTap});
  final _Json activity;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final filePath = jsDisplay(activity['file_path']);
    return HoverBuilder(
      onTap: onTap,
      builder: (context, hovered) {
        final border = current
            ? AppColors.accent
            : hovered
                ? AppColors.accent.withValues(alpha: 0.5)
                : (dark ? _cardBorderVar : Tw.gray100);
        final bg = current
            ? AppColors.accent.withValues(alpha: 0.1)
            : (dark ? AppColors.sidebarBg.withValues(alpha: 0.3) : Colors.white);
        final pillBg = current || hovered ? AppColors.accent : (dark ? Tw.gray700 : Tw.gray100);
        final pillFg = current || hovered ? Colors.white : (dark ? Tw.gray300 : Tw.gray600);
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppTheme.radiusXl),
            border: Border.all(color: border, width: 2),
            boxShadow: current || hovered ? AppShadows.md : AppShadows.sm,
          ),
          child: Column(
            children: [
              Container(
                height: 96,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: dark ? Tw.gray800 : Tw.gray50,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                ),
                child: filePath.isNotEmpty
                    ? Image.network(
                        filePath,
                        fit: BoxFit.contain,
                        // @error → img.style.display = 'none'
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      )
                    : Icon(BootstrapIcons.play_circle,
                        size: 30, color: dark ? Tw.gray600 : Tw.gray300),
              ),
              // shadcn Card keeps its `gap-6` between children.
              const SizedBox(height: 32),
              Expanded(
                child: Tooltip(
                  message: jsDisplay(activity['name']),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      jsDisplay(activity['name']),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: sm ? 14 : 12,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: dark ? Tw.gray100 : Tw.gray800,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: pillBg,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: AppShadows.sm,
                ),
                child: Text(
                  current ? '✓ CURRENT' : 'OPEN',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: pillFg),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// `animate-ping` (scale 1 → 2, opacity 1 → 0, every second).
class _Ping extends StatefulWidget {
  const _Ping({required this.child});
  final Widget child;

  @override
  State<_Ping> createState() => _PingState();
}

class _PingState extends State<_Ping> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = const Cubic(0, 0, 0.2, 1).transform(_c.value);
          return Opacity(
            opacity: 1 - t,
            child: Transform.scale(scale: 1 + t, child: child),
          );
        },
        child: widget.child,
      );
}
