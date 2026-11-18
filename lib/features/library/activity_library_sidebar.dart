part of 'activity_library_page.dart';

/// The right "notes" drawer and the "All Activities" popup.
extension _ActivitySidebar on _ActivityLibraryPageState {
  // ===== RIGHT SIDEBAR =====
  Widget _sidebar(BuildContext context) {
    final dark = context.isDark;
    final w = MediaQuery.sizeOf(context).width;
    final factor = context.isXl
        ? 0.22
        : context.isLg
            ? 0.26
            : context.isMd
                ? 0.38
                : context.isSm
                    ? 0.55
                    : 0.8;
    final width = w * factor;
    // `text-(--sidebar-bg) dark:text-(--sidebar-text)`: --sidebar-bg only
    // exists in .dark, so light mode inherits the body text colour.
    final text = dark ? LibColors.sidebarText : AppColors.foreground;
    final labelStyle = libNunito(
      fontSize: 14,
      height: twLeading(14),
      fontWeight: FontWeight.w600,
      letterSpacing: 0.7,
      color: dark ? Tw.gray400 : Tw.gray600,
    );
    final selectText = libNunito(fontSize: 16, fontWeight: FontWeight.w500, color: text);
    final primary = LibColors.primary(context);
    final sidebarBorder = dark
        ? LibColors.darkSidebarBorder.withValues(alpha: 0.3)
        : Colors.white.withValues(alpha: 0.3);

    // Triggers: `rounded-xl bg-white/20 dark:bg-(--sidebar-bg)/30 border
    // border-white/30 dark:border-(--sidebar-border)/30 text-base
    // font-medium` + the kit's `h-9 px-3 shadow-xs dark:hover:bg-input/50`;
    // the chapter one adds `p-3 hover:bg-white/85`.
    BoxDecoration selectDeco({required bool hover, required bool lightHover}) => BoxDecoration(
          color: dark
              ? (hover ? AppColors.darkInput.withValues(alpha: 0.5) : LibColors.sidebarBg.withValues(alpha: 0.3))
              : Colors.white.withValues(alpha: hover && lightHover ? 0.85 : 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: sidebarBorder),
          boxShadow: AppShadows.xs,
        );

    Widget label(String s) => Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(s.toUpperCase(), style: labelStyle),
        );
    Widget note(String s) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(s,
              textAlign: TextAlign.center,
              style: libNunito(fontSize: 16, height: 1.5, color: dark ? Tw.gray400 : Tw.gray500)),
        );
    Widget spinnerLine(String s) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            SpinIcon(size: 16, color: primary),
            const SizedBox(width: 4),
            Text(s, style: libNunito(fontSize: 16, height: 1.5, color: text)),
          ]),
        );

    /// `space-y-3`: 12px between the children of a section.
    Widget section(List<Widget> children) => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            children[i],
          ],
        ]);

    final chapters = _filteredChapters;
    final topics = _topicsForSelectedChapter;

    final chapterSection = section([
      label('Select Chapter'),
      if (_loading) spinnerLine('Loading chapters...'),
      LibrarySelect<String>(
        value: _selectedChapterId,
        enabled: chapters.isNotEmpty && !_loading,
        placeholder: 'Choose a chapter',
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: selectDeco(hover: false, lightHover: true),
        hoverDecoration: selectDeco(hover: true, lightHover: true),
        textStyle: selectText,
        items: [
          for (final raw in chapters)
            if (asMap(raw) case final ch?) AppSelectItem(jsString(ch['id']), vueText(ch['name'])),
        ],
        onChanged: _onChapterChange,
      ),
      if (_error != null)
        Padding(
          padding: const EdgeInsets.all(8),
          child: Text(_error!, style: libNunito(fontSize: 14, height: twLeading(14), color: Tw.red500)),
        ),
    ]);

    final topicSection = section([
      label('Select Topic'),
      LibrarySelect<String>(
        value: jsString(_topicId),
        placeholder: 'Choose a topic',
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: selectDeco(hover: false, lightHover: false),
        hoverDecoration: selectDeco(hover: true, lightHover: false),
        textStyle: selectText,
        items: [
          for (final raw in topics)
            if (asMap(raw) case final t?) AppSelectItem(jsString(t['id']), vueText(t['name'])),
        ],
        onChanged: (val) {
          Map<String, dynamic>? topic;
          for (final raw in topics) {
            if (jsString(asMap(raw)?['id']) == val) {
              topic = asMap(raw);
              break;
            }
          }
          _guard(() => _handleTopicClick(topic));
        },
      ),
      if (topics.isEmpty) note('No topics in this chapter'),
    ]);

    final activitySection = section([
      label('Select Activity'),
      LibrarySelect<Object?>(
        value: _selectedActivityId,
        enabled: _allactivities.isNotEmpty,
        placeholder: 'Choose an activity',
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: selectDeco(hover: false, lightHover: false),
        hoverDecoration: selectDeco(hover: true, lightHover: false),
        textStyle: selectText,
        items: [
          for (final raw in _allactivities)
            if (asMap(raw) case final a?) AppSelectItem<Object?>(a['id'], vueText(a['name'])),
        ],
        onChanged: (v) {
          _set(() => _selectedActivityId = v);
          _guard(_onActivityChange);
        },
      ),
      if (_allactivities.isEmpty) note('No activities available'),
      if (_loadingActivity) spinnerLine('Loading activity...'),
    ]);

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      top: 0,
      bottom: 0,
      width: width,
      right: _openNotesSidebar ? 0 : -(width + 40),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
          boxShadow: [cssShadow(0, 8, 32, 0, const Color(0x401F2687))],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
          child: BackdropFilter(
            // backdrop-blur-2xl (40px)
            filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                // `bg-linear-to-bl from-white/30 to-white/10
                // dark:from-(--sidebar-bg)/40 dark:to-(--navbar-bg)/20`
                gradient: CssLinearGradient(
                  corner: Alignment.bottomLeft,
                  colors: dark
                      ? [LibColors.sidebarBg.withValues(alpha: 0.4), LibColors.navbarBg.withValues(alpha: 0.2)]
                      : [Colors.white.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0.1)],
                ),
                border: Border.all(color: sidebarBorder),
              ),
              child: Material(
                type: MaterialType.transparency,
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: text),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      chapterSection,
                      if (_selectedChapterId.isNotEmpty) ...[const SizedBox(height: 16), topicSection],
                      const SizedBox(height: 16),
                      activitySection,
                      const SizedBox(height: 16),
                      _SidebarAction(
                        dark: dark,
                        hoverGlow: true,
                        onTap: () => _setPopup(true),
                        child: Text('VIEW ALL ACTIVITIES',
                            style: libNunito(
                                fontSize: 14, height: twLeading(14), fontWeight: FontWeight.w600, letterSpacing: 0.35)),
                      ),
                      const SizedBox(height: 16),
                      _SidebarAction(
                        dark: dark,
                        hoverGlow: false,
                        onTap: () => _set(() => _openNotesSidebar = false),
                        child: Row(children: [
                          const Icon(BootstrapIcons.arrow_left, size: 16),
                          const SizedBox(width: 12),
                          Text('Close Menu',
                              style: libNunito(
                                  fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, letterSpacing: 0.4)),
                        ]),
                      ),
                    ]),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===== ALL ACTIVITY POPUP =====
  Widget _allActivitiesPopup(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final md = context.isMd;
    final size = MediaQuery.sizeOf(context);
    final pad = sm ? 16.0 : 8.0;
    final factor = context.isXl
        ? 0.75
        : context.isLg
            ? 0.8
            : md
                ? 0.85
                : sm
                    ? 0.9
                    : 0.95;
    final cols = libGridColumns(context);
    final indigo = dark ? Tw.indigo300 : Tw.indigo600;
    final faint = dark ? Tw.gray500 : Tw.gray400;
    final chapterSize = sm ? 18.0 : 16.0;
    final titleSize = md ? 20.0 : (sm ? 18.0 : 16.0);

    // Margins collapse in this block layout: h3 `mb-4` + topic label `mt-5`
    // → 20px; grid / note `mb-2` + next label `mt-5` → 20px; the last
    // `mb-2` folds into the chapter's `mb-8`.
    final chapters = <Widget>[];
    for (final chapter in _allChapters) {
      final topics = asList(chapter['topics']);
      chapters.add(Padding(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            margin: EdgeInsets.only(bottom: topics.isEmpty ? 16 : 0),
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.indigo50)),
            ),
            child: Text(vueText(chapter['name']),
                style: libNunito(
                    fontSize: chapterSize, height: twLeading(chapterSize), fontWeight: FontWeight.w700, color: indigo)),
          ),
          for (final raw in topics)
            if (asMap(raw) case final topic?) ...[
              Padding(
                padding: const EdgeInsets.only(top: 20, bottom: 8, left: 4),
                child: Row(children: [
                  Icon(BootstrapIcons.bookmark_fill, size: 12, color: LibColors.primary(context)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(vueText(topic['name']).toUpperCase(),
                        style: libNunito(
                          fontSize: 12,
                          height: twLeading(12),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                          color: faint,
                        )),
                  ),
                ]),
              ),
              if (asList(topic['activities']).isNotEmpty)
                LibGrid(
                  columns: cols,
                  gap: 16,
                  stretch: true,
                  children: [
                    for (final a in asList(topic['activities']))
                      if (asMap(a) case final activity?)
                        _PopupActivityCard(
                          activity: activity,
                          current: sameId(activity['id'], _selectedActivityId),
                          onTap: () => _guard(() => _handleActivityFromPopup(topic, activity)),
                        ),
                  ],
                )
              else
                Padding(
                  padding: const EdgeInsets.only(left: 4, top: 8, bottom: 8),
                  child: Text('No activities in this topic',
                      style: libNunito(fontSize: 14, height: twLeading(14), color: faint)),
                ),
            ],
          if (topics.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text('No topics in this chapter',
                  textAlign: TextAlign.center, style: libNunito(fontSize: 16, height: 1.5, color: faint)),
            ),
        ]),
      ));
    }
    if (_allChapters.isEmpty) {
      final muted = dark ? Tw.gray400 : Tw.gray500;
      chapters.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(children: [
          Icon(BootstrapIcons.inboxes, size: 36, color: muted),
          const SizedBox(height: 12),
          Text('No chapters available', style: libNunito(fontSize: 16, height: 1.5, color: muted)),
        ]),
      ));
    }

    return Positioned.fill(
      child: BackdropFilter(
        // backdrop-blur-sm (8px)
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Material(
          color: Colors.black.withValues(alpha: 0.6),
          child: DefaultTextStyle.merge(
            style: GoogleFonts.nunito(color: dark ? AppColors.darkForeground : AppColors.foreground),
            child: Center(
              child: Container(
                width: (size.width - pad * 2) * factor,
                height: size.height * 0.85,
                padding: EdgeInsets.all(sm ? 20 : 16),
                decoration: BoxDecoration(
                  color: dark ? AppColors.dashboardDark : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.indigo100),
                  boxShadow: AppShadows.xl2,
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: sm ? 16 : 12),
                    child: Row(children: [
                      Expanded(
                        child: Text('All Activities - ${vueText(_subjectName)}',
                            style: libNunito(
                              fontSize: titleSize,
                              height: twLeading(titleSize),
                              fontWeight: FontWeight.w700,
                              color: indigo,
                            )),
                      ),
                      HoverLift(
                        lift: 0,
                        onTap: () => _setPopup(false),
                        builder: (context, hover) => Icon(BootstrapIcons.x_lg,
                            size: 20,
                            color: hover
                                ? (dark ? Colors.white : Tw.indigo600)
                                : (dark ? Tw.gray400 : Tw.gray600)),
                      ),
                    ]),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(right: 8),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: chapters),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "VIEW ALL ACTIVITIES" / "Close Menu": `p-3 rounded-xl font-semibold
/// tracking-wide bg-white/20 dark:bg-(--sidebar-bg)/30 border
/// border-white/30 dark:border-(--sidebar-border)/30 shadow-lg
/// hover:text-primary hover:border-primary hover:bg-white/85
/// dark:hover:bg-(--navbar-bg)/50 hover:scale-[1.04]`; the first also
/// `hover:shadow-[0_8px_30px_rgba(149,163,255,0.35)]`.
class _SidebarAction extends StatelessWidget {
  const _SidebarAction({required this.dark, required this.hoverGlow, required this.onTap, required this.child});

  final bool dark;
  final bool hoverGlow;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final primary = LibColors.primary(context);
    return HoverLift(
      lift: 0,
      onTap: onTap,
      builder: (context, hover) => AnimatedScale(
        scale: hover ? 1.04 : 1,
        duration: const Duration(milliseconds: 300),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: hover
                ? (dark ? LibColors.navbarBg.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.85))
                : (dark ? LibColors.sidebarBg.withValues(alpha: 0.3) : Colors.white.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(20),
            // `dark:border-(--sidebar-border)/30` beats `hover:border-primary`.
            border: Border.all(
              color: dark
                  ? LibColors.darkSidebarBorder.withValues(alpha: 0.3)
                  : (hover ? primary : Colors.white.withValues(alpha: 0.3)),
            ),
            boxShadow: hover && hoverGlow
                ? [cssShadow(0, 8, 30, 0, const Color(0x5995A3FF))]
                : AppShadows.lg,
          ),
          child: IconTheme.merge(
            data: IconThemeData(color: hover ? primary : null),
            child: DefaultTextStyle.merge(style: TextStyle(color: hover ? primary : null), child: child),
          ),
        ),
      ),
    );
  }
}

/// Popup card: the kit `<Card>` (`flex flex-col gap-6 border shadow-sm`)
/// with `items-center p-3 rounded-xl border-2`; current `bg-primary/10
/// border-primary shadow-md`, otherwise `bg-white dark:bg-(--sidebar-bg)/30
/// border-gray-100 dark:border-(--card-border) hover:border-primary/50
/// hover:shadow-md`. The kit's `gap-6` stays between the image, the name
/// and the button.
class _PopupActivityCard extends StatelessWidget {
  const _PopupActivityCard({required this.activity, required this.current, required this.onTap});

  final Map<String, dynamic> activity;
  final bool current;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final primary = LibColors.primary(context);
    final name = vueText(activity['name']);
    final fp = activity['file_path'];
    final nameSize = sm ? 14.0 : 12.0;

    return HoverLift(
      lift: 0,
      onTap: onTap,
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: current
              ? primary.withValues(alpha: 0.1)
              : (dark ? LibColors.sidebarBg.withValues(alpha: 0.3) : Colors.white),
          borderRadius: BorderRadius.circular(20),
          // In dark mode `dark:border-(--card-border)` beats
          // `hover:border-primary/50`.
          border: Border.all(
            width: 2,
            color: current
                ? primary
                : (dark ? LibColors.cardBorder : (hover ? primary.withValues(alpha: 0.5) : Tw.gray100)),
          ),
          boxShadow: current || hover ? AppShadows.md : AppShadows.sm,
        ),
        child: Column(children: [
          Container(
            height: 96,
            margin: const EdgeInsets.only(bottom: 8),
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: dark ? Tw.gray800 : Tw.gray50,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: jsTruthy(fp)
                ? contentImage(jsString(fp),
                    fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox.shrink())
                : Icon(BootstrapIcons.play_circle, size: 30, color: dark ? Tw.gray600 : Tw.gray300),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Tooltip(
                message: name,
                child: Text(name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: libNunito(
                      fontSize: nameSize,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      color: dark ? Tw.gray100 : Tw.gray800,
                    )),
              ),
            ),
          ),
          const SizedBox(height: 8 + 24),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            // `group-hover:bg-primary group-hover:text-white` lose to the
            // `dark:` colours, so only light mode reacts to the hover.
            decoration: BoxDecoration(
              color: current ? primary : (dark ? Tw.gray700 : (hover ? primary : Tw.gray100)),
              borderRadius: BorderRadius.circular(99),
              boxShadow: AppShadows.sm,
            ),
            child: Text(
              current ? '✓ CURRENT' : 'OPEN',
              textAlign: TextAlign.center,
              style: libNunito(
                fontSize: 12,
                height: twLeading(12),
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
                color: current ? Colors.white : (dark ? Tw.gray300 : (hover ? Colors.white : Tw.gray600)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
