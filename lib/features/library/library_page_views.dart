part of 'library_page.dart';

/// Grid view, list view and the chapter reference panel of library.vue.
extension _LibraryViews on _LibraryPageState {
  // ══ GRID VIEW ══
  Widget _gridView(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final lg = context.isLg;
    final cols = libGridColumns(context);

    if (_showAllActivitiesInline) {
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        for (final raw in _filteredChapters)
          if (asMap(raw) case final chapter?)
            Padding(
              padding: EdgeInsets.only(bottom: sm ? 56 : 40),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _chapterHeader(context, vueText(chapter['name']), big: true),
                Builder(builder: (context) {
                  final acts = activitiesForChapter(_allActivitiesData, chapter['id']);
                  if (acts.isEmpty) return _emptyLine('No activities in this chapter', 24);
                  // CSS grid rows stretch the cards; `mt-auto` keeps the
                  // buttons at the bottom.
                  return LibGrid(
                    columns: cols,
                    gap: lg ? 24 : (sm ? 20 : 16),
                    stretch: true,
                    children: [for (final a in acts) _activityCard(context, a)],
                  );
                }),
              ]),
            ),
      ]);
    }

    final topics = _filteredTopics;
    final size = sm ? 16.0 : 14.0;
    final muted = libNunito(color: dark ? Tw.gray400 : Tw.gray500, fontSize: size, height: twLeading(size));
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (topics.isNotEmpty)
        LibGrid(
          columns: cols,
          gap: lg ? 32 : (sm ? 28 : 24),
          children: [for (final t in topics) _topicCard(context, t)],
        ),
      if (jsTruthy(_selectedChapterId) && topics.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 64),
          child: Text('No topics available in this chapter.', textAlign: TextAlign.center, style: muted),
        ),
      if (!jsTruthy(_selectedChapterId) && !_loading)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 64),
          child: Text('Please select a chapter to view topics.', textAlign: TextAlign.center, style: muted),
        ),
    ]);
  }

  /// `flex items-center gap-3 border-b-2 border-slate-200/60
  /// dark:border-slate-800/80` + `w-1.5 bg-indigo-600 rounded-full` bar.
  Widget _chapterHeader(BuildContext context, String name, {required bool big}) {
    final dark = context.isDark;
    final sm = context.isSm;
    final size = big ? (sm ? 18.0 : 16.0) : (sm ? 16.0 : 14.0);
    return Container(
      margin: EdgeInsets.only(bottom: big ? 20 : 16),
      padding: EdgeInsets.fromLTRB(big ? 4 : 0, 0, big ? 4 : 0, big ? 12 : 8),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            width: 2,
            color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate200.withValues(alpha: 0.6),
          ),
        ),
      ),
      child: Row(children: [
        Container(
          width: 6,
          height: big ? 24 : 20,
          decoration: BoxDecoration(color: Tw.indigo600, borderRadius: BorderRadius.circular(99)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(name,
              style: libNunito(
                fontSize: size,
                height: twLeading(size),
                fontWeight: FontWeight.w700,
                color: dark ? Tw.indigo300 : Tw.indigo600,
              )),
        ),
      ]),
    );
  }

  Widget _emptyLine(String text, double vPad) {
    final size = context.isSm ? 16.0 : 14.0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vPad),
      child: Text(text,
          textAlign: TextAlign.center,
          style: libNunito(color: Tw.gray400, fontSize: size, height: twLeading(size))),
    );
  }

  /// `rounded-2xl bg-white/85 dark:bg-slate-900/85 border border-slate-200
  /// dark:border-slate-800/80 hover:border-indigo-400
  /// dark:hover:border-indigo-500/80` + the indigo shadows.
  BoxDecoration _cardDecoration(bool dark, bool hover) => BoxDecoration(
        color: dark ? Tw.slate900.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hover
              ? (dark ? Tw.indigo500.withValues(alpha: 0.8) : Tw.indigo400)
              : (dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate200),
        ),
        boxShadow: libCardShadow(dark, hover),
      );

  /// Show-all mode card (`goToPopupActivity`).
  Widget _activityCard(BuildContext context, Map<String, dynamic> activity) {
    final dark = context.isDark;
    final sm = context.isSm;
    final name = vueText(activity['name']);
    final fp = activity['file_path'];
    final img = fp is String && fp.isNotEmpty ? fp : null;
    final titleSize = sm ? 16.0 : 14.0;
    final buttonSize = sm ? 14.0 : 12.0;

    return HoverLift(
      duration: const Duration(milliseconds: 300),
      onTap: () => _goToPopupActivity(activity),
      builder: (context, hover) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: _cardDecoration(dark, hover),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ColoredBox(
              color: dark ? Tw.gray700 : Tw.gray50,
              child: LibImage(
                img,
                fallback: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(BootstrapIcons.image, size: sm ? 36 : 30, color: Tw.gray400),
                  const SizedBox(height: 4),
                  Text('No Image', style: libNunito(fontSize: 12, height: twLeading(12), color: Tw.gray400)),
                ]),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Tooltip(
                  message: name,
                  child: Text(name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: libNunito(
                        fontSize: titleSize,
                        height: 1.375,
                        fontWeight: FontWeight.w500,
                        color: dark ? Colors.white : Tw.gray800,
                      )),
                ),
                const SizedBox(height: 12),
                const Spacer(),
                // `rounded-xl bg-[#1e3a8a] hover:bg-[#1e3a8a]/90 py-2.5 px-4 shadow-sm`
                HoverLift(
                  lift: 0,
                  builder: (context, btnHover) => AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: btnHover ? LibColors.blue900.withValues(alpha: 0.9) : LibColors.blue900,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: AppShadows.sm,
                    ),
                    child: Text('Go to Activity',
                        textAlign: TextAlign.center,
                        style: libNunito(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: buttonSize,
                          height: twLeading(buttonSize),
                        )),
                  ),
                ),
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  /// Normal topic card (`goToActivity`).
  Widget _topicCard(BuildContext context, Map<String, dynamic> topic) {
    final dark = context.isDark;
    final sm = context.isSm;
    final lg = context.isLg;
    final fp = topic['file_path'];
    final img = jsTruthy(fp) ? jsString(fp) : null;
    final title = jsTruthy(topic['name']) ? jsString(topic['name']) : 'No Title';

    return HoverLift(
      duration: const Duration(milliseconds: 300),
      onTap: () => _goToActivity(topic),
      builder: (context, hover) => Container(
        height: lg ? 300 : 250,
        clipBehavior: Clip.antiAlias,
        decoration: _cardDecoration(dark, hover),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: ColoredBox(
              color: dark ? Tw.gray700 : Tw.gray100,
              child: LibImage(img,
                  fallback: const Center(child: Icon(BootstrapIcons.image, size: 36, color: Tw.gray400))),
            ),
          ),
          Container(
            constraints: const BoxConstraints(minHeight: 60),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: sm ? 16 : 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: dark
                    ? [Tw.indigo950.withValues(alpha: 0.3), Tw.indigo950.withValues(alpha: 0.15)]
                    : [Tw.indigo50.withValues(alpha: 0.8), Tw.indigo100.withValues(alpha: 0.4)],
              ),
              border: Border(
                top: BorderSide(color: dark ? Tw.slate800.withValues(alpha: 0.6) : Tw.slate200),
              ),
            ),
            // `text-indigo-955` is not a Tailwind colour: the card's
            // `text-card-foreground` shows in light mode.
            child: Text(
              truncateTitle(title, 20),
              textAlign: TextAlign.center,
              style: libNunito(
                fontWeight: FontWeight.w700,
                fontSize: lg ? 16 : (sm ? 14 : 12),
                height: 1.375,
                color: dark ? Tw.indigo200 : AppColors.cardForeground,
              ),
            ),
          ),
        ]),
      ),
    );
  }

  // ══ LIST VIEW ══
  Widget _listView(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final lg = context.isLg;

    final String heading;
    if (jsTruthy(_selectedChapterId) && !_showAllActivitiesInline) {
      heading = vueText(_selectedChapter['name']);
    } else if (_showAllActivitiesInline) {
      heading = 'All Chapters Activities';
    } else {
      heading = 'No data';
    }
    final headingSize = lg ? 30.0 : (sm ? 24.0 : 20.0);

    final children = <Widget>[
      Padding(
        padding: EdgeInsets.only(bottom: sm ? 32 : 24),
        child: Text(heading,
            style: libNunito(
              fontSize: headingSize,
              height: twLeading(headingSize),
              fontWeight: FontWeight.w700,
              color: dark ? Tw.indigo300 : Tw.indigo600,
            )),
      ),
    ];

    if (_showAllActivitiesInline) {
      for (final raw in _filteredChapters) {
        final chapter = asMap(raw);
        if (chapter == null) continue;
        final acts = activitiesForChapter(_allActivitiesData, chapter['id']);
        children.add(Padding(
          padding: EdgeInsets.only(bottom: sm ? 40 : 32),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _chapterHeader(context, vueText(chapter['name']), big: false),
            if (acts.isNotEmpty)
              for (var i = 0; i < acts.length; i++)
                Padding(
                  padding: EdgeInsets.only(top: i == 0 ? 0 : 4),
                  child: _listRow(context, vueText(acts[i]['name']),
                      oneLine: true, onTap: () => _goToPopupActivity(acts[i])),
                )
            else
              _emptyLine('No activities in this chapter', 20),
          ]),
        ));
      }
    } else {
      final topics = _filteredTopics;
      if (jsTruthy(_selectedChapterId) && topics.isNotEmpty) {
        for (var i = 0; i < topics.length; i++) {
          children.add(Padding(
            padding: EdgeInsets.only(top: i == 0 ? 0 : 4),
            child: _listRow(context, vueText(topics[i]['name']),
                oneLine: false, onTap: () => _goToActivity(topics[i])),
          ));
        }
      } else {
        final size = sm ? 16.0 : 14.0;
        final muted =
            libNunito(color: dark ? Tw.gray400 : Tw.gray500, fontSize: size, height: twLeading(size));
        String? msg;
        if (jsTruthy(_selectedChapterId) && topics.isEmpty) {
          msg = 'No topics available in this chapter.';
        } else if (!_loading) {
          msg = 'Loading topics...';
        }
        children.add(Padding(
          padding: EdgeInsets.symmetric(vertical: sm ? 80 : 56),
          child: msg == null ? const SizedBox() : Text(msg, textAlign: TextAlign.center, style: muted),
        ));
      }
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  /// `flex items-center gap-3 py-3 px-4 rounded-xl hover:bg-indigo-50/50
  /// dark:hover:bg-indigo-950/20 hover:text-indigo-600
  /// dark:hover:text-indigo-400` with the round chevron / play badges.
  Widget _listRow(BuildContext context, String name,
      {required bool oneLine, required VoidCallback onTap}) {
    final dark = context.isDark;
    final sm = context.isSm;
    final size = sm ? 16.0 : 14.0;

    Widget circle(IconData icon) => Container(
          width: sm ? 32 : 28,
          height: sm ? 32 : 28,
          decoration: BoxDecoration(
            color: dark ? Tw.indigo950.withValues(alpha: 0.2) : Tw.indigo50,
            shape: BoxShape.circle,
            border: Border.all(
                color: dark ? Tw.slate800.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.2)),
            boxShadow: AppShadows.sm,
          ),
          child: Icon(icon, size: sm ? 14 : 12, color: dark ? Tw.indigo300 : Tw.indigo600),
        );

    return HoverLift(
      lift: 0,
      onTap: onTap,
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: hover
              ? (dark ? Tw.indigo950.withValues(alpha: 0.2) : Tw.indigo50.withValues(alpha: 0.5))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(children: [
          circle(BootstrapIcons.chevron_right),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              maxLines: oneLine ? 1 : 2,
              overflow: TextOverflow.ellipsis,
              style: libNunito(
                fontSize: size,
                fontWeight: FontWeight.w500,
                height: oneLine ? twLeading(size) : 1.375,
                color: hover
                    ? (dark ? Tw.indigo400 : Tw.indigo600)
                    : (dark ? Colors.white : Tw.slate800),
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (oneLine)
            circle(BootstrapIcons.play_fill)
          else
            Tooltip(message: 'Open Activity', child: circle(BootstrapIcons.play_fill)),
        ]),
      ),
    );
  }

  // ══ CHAPTER REFERENCE PANEL ══
  Widget _referencePanel(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final h = MediaQuery.sizeOf(context).height;
    final indigo = dark ? Tw.indigo300 : Tw.indigo600;
    final titleSize = sm ? 16.0 : 14.0;

    Widget body;
    if (_referenceLoading) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const RingSpinner(color: LibColors.accent),
          const SizedBox(width: 12),
          Pulse(
            child: Text('Loading chapter reference...',
                style: libNunito(fontSize: 14, height: twLeading(14), color: Tw.gray400)),
          ),
        ]),
      );
    } else if (_chapterReferenceUrl != null) {
      body = SizedBox(
        height: (h * 0.6).clamp(520.0, 780.0),
        child: WebContentView(url: _chapterReferenceUrl),
      );
    } else {
      // `p-4 sm:p-6 … overflow-auto` with `max-height: 60vh` (the WebView
      // needs a fixed height, so it is always 60vh).
      body = SizedBox(
        height: h * 0.6,
        child: WebContentView(
          html: libInlineHtmlPage(
            _chapterReferenceContent ?? '',
            dark: dark,
            color: dark ? AppColors.darkForeground : AppColors.foreground,
            background: dark ? Tw.slate900 : Colors.white,
            padding: sm ? 24 : 16,
            fontFamily: 'Nunito, sans-serif',
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 20),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? Tw.slate900.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: dark ? Tw.slate800.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.2)),
        boxShadow: AppShadows.xs,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: sm ? 20 : 16, vertical: 12),
          decoration: BoxDecoration(
            color: dark ? Tw.indigo950.withValues(alpha: 0.2) : Tw.indigo50.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(
                  color: dark ? Tw.slate800.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.2)),
            ),
          ),
          child: Row(children: [
            Container(
              width: 6,
              height: 20,
              decoration: BoxDecoration(color: Tw.indigo600, borderRadius: BorderRadius.circular(99)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Chapter Reference',
                  style: libNunito(
                      color: indigo, fontSize: titleSize, height: twLeading(titleSize), fontWeight: FontWeight.w700)),
            ),
            // `hover:opacity-70 transition-opacity`
            HoverLift(
              lift: 0,
              onTap: () => _set(() => _referenceExpanded = !_referenceExpanded),
              builder: (context, hover) => AnimatedOpacity(
                opacity: hover ? 0.7 : 1,
                duration: const Duration(milliseconds: 150),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_referenceExpanded ? BootstrapIcons.chevron_up : BootstrapIcons.chevron_down,
                      size: 14, color: indigo),
                  const SizedBox(width: 4),
                  Text(_referenceExpanded ? 'Collapse' : 'Expand',
                      style: libNunito(
                          color: indigo, fontSize: 14, height: twLeading(14), fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ]),
        ),
        // v-show: the iframe stays loaded while collapsed.
        Visibility(visible: _referenceExpanded, maintainState: true, child: body),
      ]),
    );
  }
}
