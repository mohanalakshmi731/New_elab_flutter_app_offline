part of 'course_list_view.dart';

/// "Manage" tab: sections → chapters → concepts accordions (`type="single"
/// collapsible`). Every expanded section lists the store's `chapters` and
/// every expanded chapter the store's `contents`, like the web.
extension _OutlineUi on _CourseListViewState {
  Widget _buildOutlineTab(CoursesState cs) {
    final sm = context.isSm;
    final md = context.isMd;
    final lg = context.isLg;
    final dark = context.isDark;
    final sections = cs.sections;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: lg ? 40 : (md ? 24 : (sm ? 16 : 0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: AppButton(label: 'Create Section', expand: !sm, onPressed: _openCreateSectionDialog),
          ),
          const SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(sm ? 16 : 12),
            decoration: BoxDecoration(
              color: dark ? AppColors.darkCard : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: dark ? Tw.slate800 : Tw.slate100),
              boxShadow: _CC.shadowSm,
            ),
            child: sections.isEmpty
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Column(
                      children: [
                        Icon(BootstrapIcons.inbox, size: 24, color: Tw.slate400),
                        SizedBox(height: 4),
                        Text(
                          'No sections available for this course.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Tw.slate400),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < sections.length; i++)
                        _buildSectionItem(cs, sections[i], i, last: i == sections.length - 1),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  /// Chevron of `<AccordionTrigger>` (`text-muted-foreground size-4
  /// translate-y-0.5`, rotates when open). The trigger is `items-start`.
  Widget _chevron(bool open) => Padding(
    padding: const EdgeInsets.only(top: 2),
    child: AnimatedRotation(
      turns: open ? 0.5 : 0,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        width: 16,
        height: 16,
        child: Icon(
          BootstrapIcons.chevron_down,
          size: 13,
          color: context.isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground,
        ),
      ),
    ),
  );

  /// `<AccordionContent>` (`animate-accordion-down/up`, 200ms).
  Widget _accordionReveal(bool open, Widget Function() body) => AnimatedSize(
    duration: const Duration(milliseconds: 200),
    curve: Curves.easeOut,
    alignment: Alignment.topCenter,
    child: open ? body() : const SizedBox(width: double.infinity),
  );

  /// `<AccordionItem class="border … rounded-xl mb-4 overflow-hidden">`
  /// (`last:border-b-0` from the base class still applies).
  BoxDecoration _accordionItemDecoration({required bool last}) {
    final dark = context.isDark;
    final side = BorderSide(color: dark ? Tw.slate800 : Tw.slate200);
    return BoxDecoration(
      color: dark ? AppColors.darkCard : Colors.white,
      borderRadius: BorderRadius.circular(20),
      border: Border(top: side, left: side, right: side, bottom: last ? BorderSide.none : side),
      boxShadow: _CC.shadowSm,
    );
  }

  Widget _buildSectionItem(CoursesState cs, Map<String, dynamic> section, int index, {required bool last}) {
    final sm = context.isSm;
    final dark = context.isDark;
    final value = 'section-$index';
    final open = _expandedSectionRow == value;
    final primary = context.colors.primary;

    Widget action(IconData icon, Color color, Color hoverBg, String tip, VoidCallback onTap) => _IconAction(
      icon: icon,
      size: sm ? 32 : 28,
      iconSize: sm ? 18 : 16,
      color: open ? Colors.white.withValues(alpha: 0.9) : color,
      hoverColor: open ? Colors.white : null,
      hoverBg: open ? Colors.white.withValues(alpha: 0.1) : hoverBg,
      tooltip: tip,
      onTap: onTap,
    );

    final trigger = _Hover(
      onTap: () {
        _set(() => _expandedSectionRow = open ? '' : value);
        _fire(() => _onSectionSelect(section));
      },
      builder: (h) => Container(
        padding: EdgeInsets.symmetric(horizontal: sm ? 24 : 12, vertical: sm ? 16 : 12),
        decoration: BoxDecoration(
          gradient: open ? LinearGradient(colors: [primary, context.colors.secondary]) : null,
          color: open ? null : (h ? (dark ? Tw.slate900 : Tw.slate50) : (dark ? AppColors.darkCard : Colors.white)),
        ),
        // `flex items-start justify-between gap-4 … hover:underline`
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: open ? Colors.white.withValues(alpha: 0.2) : (dark ? Tw.slate800 : Tw.slate100),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: open ? Colors.white.withValues(alpha: 0.3) : (dark ? Tw.slate700 : Tw.slate200),
                      ),
                    ),
                    child: Text(
                      vText(section['order']),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: open ? Colors.white : (dark ? Tw.slate300 : Tw.slate600),
                        decoration: h ? TextDecoration.underline : null,
                        decorationColor: open ? Colors.white : (dark ? Tw.slate300 : Tw.slate600),
                      ),
                    ),
                  ),
                  SizedBox(width: sm ? 12 : 8),
                  Flexible(
                    child: Text(
                      vText(section['name']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: sm ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: open ? Colors.white : (dark ? Tw.slate200 : Tw.slate800),
                        decoration: h ? TextDecoration.underline : null,
                        decorationColor: open ? Colors.white : (dark ? Tw.slate200 : Tw.slate800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            action(
              BootstrapIcons.plus_circle,
              _CC.yellow600,
              dark ? _CC.yellow950.withValues(alpha: 0.2) : _CC.yellow50,
              'Add Chapter',
              _openCreateChapterDialog,
            ),
            SizedBox(width: sm ? 8 : 4),
            action(
              BootstrapIcons.pencil_square,
              Tw.emerald600,
              dark ? _CC.emerald950.withValues(alpha: 0.2) : Tw.emerald50,
              'Edit Section',
              () => _fire(() => _openSectionUpdateDialog(_selectedCourse?['id'], section['id'])),
            ),
            SizedBox(width: sm ? 8 : 4),
            action(
              BootstrapIcons.dash_circle,
              Tw.rose600,
              dark ? _CC.rose950.withValues(alpha: 0.2) : Tw.rose50,
              'Delete Section',
              () => _openDeleteSectionDialog(section),
            ),
            SizedBox(width: sm ? 16 : 8),
            const SizedBox(width: 16),
            _chevron(open),
          ],
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      decoration: _accordionItemDecoration(last: last),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          trigger,
          _accordionReveal(
            open,
            () => _accordionBody(
              padding: EdgeInsets.symmetric(horizontal: sm ? 24 : 12, vertical: 16),
              child: cs.chapters.isEmpty
                  ? _dashedEmpty('No chapters available for this section.', iconSize: 20)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var j = 0; j < cs.chapters.length; j++)
                          _buildChapterItem(cs, section, cs.chapters[j], j, last: j == cs.chapters.length - 1),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  /// `<AccordionContent class="bg-slate-50/55 dark:bg-slate-900/10 border-t …">`
  Widget _accordionBody({required EdgeInsets padding, required Widget child}) {
    final dark = context.isDark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: dark ? Tw.slate900.withValues(alpha: 0.1) : Tw.slate50.withValues(alpha: 0.55),
        border: Border(top: BorderSide(color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate100)),
      ),
      child: child,
    );
  }

  /// `text-center py-6 text-slate-400 border border-dashed … rounded-xl`
  /// (`text-slate-350` doesn't exist, so the icon stays `text-slate-400`.)
  Widget _dashedEmpty(String text, {double iconSize = 18}) {
    final dark = context.isDark;
    return _DashedBox(
      color: dark ? Tw.slate800 : Tw.slate200,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(BootstrapIcons.inbox, size: iconSize, color: Tw.slate400),
          const SizedBox(height: 4),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterItem(
    CoursesState cs,
    Map<String, dynamic> section,
    Map<String, dynamic> chapter,
    int index, {
    required bool last,
  }) {
    final sm = context.isSm;
    final dark = context.isDark;
    final value = 'chapter-$index';
    final open = _expandedChapterRow == value;

    Widget action(IconData icon, Color color, Color hoverBg, String tip, VoidCallback onTap) => _IconAction(
      icon: icon,
      size: sm ? 28 : 24,
      iconSize: sm ? 16 : 14,
      radius: 14,
      color: color,
      hoverBg: hoverBg,
      tooltip: tip,
      onTap: onTap,
    );

    final trigger = _Hover(
      onTap: () {
        _set(() => _expandedChapterRow = open ? '' : value);
        _fire(() => _onChapterSelect(chapter));
      },
      builder: (h) => Container(
        padding: EdgeInsets.symmetric(horizontal: sm ? 20 : 12, vertical: 12),
        color: open
            ? (dark ? Tw.slate800 : Tw.slate100)
            : (h
                  ? (dark ? Tw.slate900.withValues(alpha: 0.5) : Tw.slate50)
                  : (dark ? AppColors.darkCard : Colors.white)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: dark ? Tw.slate900 : Tw.slate50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: dark ? Tw.slate700 : Tw.slate200),
                    ),
                    child: Text(
                      vText(chapter['order']),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: dark ? Tw.slate400 : Tw.slate500,
                        decoration: h ? TextDecoration.underline : null,
                        decorationColor: dark ? Tw.slate400 : Tw.slate500,
                      ),
                    ),
                  ),
                  SizedBox(width: sm ? 12 : 8),
                  Flexible(
                    child: Text(
                      vText(chapter['name']),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      // The span's own `font-medium` beats the open trigger's
                      // `font-semibold`.
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: open ? (dark ? Colors.white : Tw.slate900) : (dark ? Tw.slate200 : Tw.slate800),
                        decoration: h ? TextDecoration.underline : null,
                        decorationColor: open
                            ? (dark ? Colors.white : Tw.slate900)
                            : (dark ? Tw.slate200 : Tw.slate800),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            action(
              BootstrapIcons.plus_circle,
              _CC.yellow600,
              dark ? _CC.yellow950.withValues(alpha: 0.2) : _CC.yellow50,
              'Add Concept',
              () => _openConceptDialog(chapter),
            ),
            SizedBox(width: sm ? 8 : 4),
            action(
              BootstrapIcons.pencil_square,
              Tw.emerald600,
              dark ? _CC.emerald950.withValues(alpha: 0.2) : Tw.emerald50,
              'Edit Chapter',
              () => _fire(() => _openChapterUpdateDialog(_selectedCourse?['id'], section['id'], chapter['id'])),
            ),
            SizedBox(width: sm ? 8 : 4),
            action(
              BootstrapIcons.dash_circle,
              Tw.rose600,
              dark ? _CC.rose950.withValues(alpha: 0.2) : Tw.rose50,
              'Delete Chapter',
              () => _openDeleteChapterDialog(chapter),
            ),
            SizedBox(width: sm ? 12 : 8),
            const SizedBox(width: 16),
            _chevron(open),
          ],
        ),
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      decoration: _accordionItemDecoration(last: last),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          trigger,
          _accordionReveal(
            open,
            () => _accordionBody(
              padding: EdgeInsets.symmetric(horizontal: sm ? 16 : 8, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (cs.contents.isEmpty) _dashedEmpty('No Concepts available.'),
                  for (var k = 0; k < cs.contents.length; k++) ...[
                    if (k > 0)
                      Divider(height: 1, thickness: 1, color: dark ? Tw.slate800.withValues(alpha: 0.85) : Tw.slate100),
                    _buildContentRow(section, chapter, cs.contents[k]),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// One concept row (type icon, name → preview dialog, edit / delete).
  Widget _buildContentRow(Map<String, dynamic> section, Map<String, dynamic> chapter, Map<String, dynamic> content) {
    final sm = context.isSm;
    final dark = context.isDark;
    final type = content['type'];
    final (Color boxBg, Color boxFg) = switch (type) {
      'html' => (dark ? Tw.indigo500.withValues(alpha: 0.1) : Tw.indigo100, dark ? Tw.indigo400 : Tw.indigo600),
      'pdf' => (dark ? Tw.rose500.withValues(alpha: 0.1) : _CC.rose100, dark ? _CC.rose400 : Tw.rose600),
      _ => (dark ? Tw.blue500.withValues(alpha: 0.1) : Tw.blue100, dark ? Tw.blue400 : Tw.blue600),
    };
    final IconData? typeIcon = switch (type) {
      'html' => BootstrapIcons.file_earmark_richtext,
      'pdf' => BootstrapIcons.filetype_pdf,
      'url' => BootstrapIcons.link_45deg,
      _ => null,
    };

    final left = Row(
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dark ? Tw.slate900 : Tw.slate100,
            borderRadius: BorderRadius.circular(4),
            // `dark:border-slate-850` doesn't exist → the default `--border`.
            border: Border.all(color: dark ? AppColors.darkBorder : Tw.slate200),
          ),
          child: Text(
            vText(content['order']),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: dark ? Tw.slate400 : Tw.slate500),
          ),
        ),
        SizedBox(width: sm ? 16 : 12),
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: boxBg, borderRadius: BorderRadius.circular(16)),
          child: typeIcon == null ? null : Icon(typeIcon, size: 18, color: boxFg),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: _Hover(
            onTap: () => _handleContentClick(content),
            builder: (h) => Text(
              vText(content['name']),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: dark ? Tw.blue400 : Tw.blue600,
                decoration: h ? TextDecoration.underline : null,
                decorationColor: dark ? Tw.blue400 : Tw.blue600,
              ),
            ),
          ),
        ),
      ],
    );

    final actions = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _IconAction(
          icon: BootstrapIcons.pencil_square,
          iconSize: 18,
          color: Tw.emerald600,
          hoverBg: dark ? Tw.emerald500.withValues(alpha: 0.1) : Tw.emerald50,
          tooltip: 'Edit Concept',
          onTap: () => _fire(
            () => _openContentUpdateDialog(_selectedCourse?['id'], section['id'], chapter['id'], content['id']),
          ),
        ),
        const SizedBox(width: 8),
        _IconAction(
          icon: BootstrapIcons.dash_circle,
          iconSize: 18,
          color: Tw.rose600,
          hoverBg: dark ? _CC.rose950.withValues(alpha: 0.2) : Tw.rose50,
          tooltip: 'Delete Concept',
          onTap: () => _openDeleteContentDialog(content),
        ),
      ],
    );

    return _Hover(
      cursor: MouseCursor.defer,
      builder: (h) => Container(
        padding: EdgeInsets.symmetric(horizontal: sm ? 12 : 8, vertical: 12),
        decoration: BoxDecoration(
          color: h ? (dark ? Tw.slate900.withValues(alpha: 0.3) : Tw.slate50.withValues(alpha: 0.5)) : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: sm
            ? Row(
                children: [
                  Expanded(child: left),
                  const SizedBox(width: 16),
                  actions,
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  left,
                  const SizedBox(height: 8),
                  Padding(padding: const EdgeInsets.only(left: 36), child: actions),
                ],
              ),
      ),
    );
  }
}
