part of 'class_course_create_page.dart';

/// "Manage" tab (`value="outline"`, `px-2 sm:px-4 space-y-4`): sections →
/// chapters → concepts.
class _OutlineTab extends StatelessWidget {
  const _OutlineTab({required this.s, required this.course});
  final _ClassCourseCreatePageState s;
  final Map<String, dynamic> course;

  @override
  Widget build(BuildContext context) {
    final sm = context.isSm;
    final dark = context.isDark;
    final store = s._store;
    final sections = store.sections;
    final primary = context.colors.primary;

    final title = Text(
      'COURSE OUTLINE PLAN',
      style: TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.7,
        color: dark ? Tw.slate400 : Tw.slate500,
      ),
    );
    // `bg-primary hover:bg-primary/95 text-white rounded-xl shadow-sm px-5
    // font-medium flex items-center gap-1.5` (h-9) + `bi-plus-lg text-xs`.
    final create = s._canManage
        ? AppButton(
            onPressed: s._openCreateSectionDialog,
            foregroundColor: Colors.white,
            hoverBackgroundColor: primary.withValues(alpha: 0.95),
            radius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            shadow: _shadowSm,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(BootstrapIcons.plus_lg, size: 12, color: Colors.white),
                SizedBox(width: 6),
                Text('Create Section'),
              ],
            ),
          )
        : null;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: sm ? 16 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (sm)
            Row(children: [Expanded(child: title), ?create])
          else ...[
            title,
            if (create != null) ...[const SizedBox(height: 12), Align(alignment: Alignment.centerRight, child: create)],
          ],
          const SizedBox(height: 16),
          if (sections.isEmpty)
            // `border-slate-200 dark:border-slate-850` — slate-850 is not a
            // Tailwind colour, so the light border stays in dark mode.
            _DashedBox(
              color: Tw.slate200,
              radius: 16,
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Column(
                children: [
                  Icon(BootstrapIcons.layout_text_window_reverse, size: 30, color: dark ? Tw.slate700 : Tw.slate300),
                  const SizedBox(height: 8),
                  const Text('No sections available for this course.',
                      style: TextStyle(fontSize: 14, height: 20 / 14, color: Tw.slate400)),
                ],
              ),
            )
          else
            for (var i = 0; i < sections.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _SectionItem(
                s: s,
                course: course,
                section: sections[i],
                index: i,
                last: i == sections.length - 1,
              ),
            ],
        ],
      ),
    );
  }
}

/// Border of an `AccordionItem` (`border-b last:border-b-0` + the page's
/// `border`): the last item has no bottom border.
Border _itemBorder(Color color, {required bool last}) {
  final side = BorderSide(color: color);
  return Border(top: side, left: side, right: side, bottom: last ? BorderSide.none : side);
}

/// Round action button on an accordion header: `bg-white/10
/// hover:bg-white/20 text-white` when the row is open, else the tinted
/// `bg-x-50 hover:bg-x-100 text-x-600 dark:bg-x-950/20` style. The
/// `dark:text-x-450/455` classes are not Tailwind colours (text stays x-600),
/// and in dark mode `dark:bg-*` beats `hover:bg-*`, so there is no hover.
Widget _headerAction(
  BuildContext context, {
  required bool open,
  required IconData icon,
  required double iconSize,
  required String tooltip,
  required Color light,
  required Color lightHover,
  required Color text,
  required Color darkBg,
  required double size,
  required VoidCallback onTap,
}) {
  final dark = context.isDark;
  return _RoundIconButton(
    icon: icon,
    size: size,
    iconSize: iconSize,
    tooltip: tooltip,
    background: open ? Colors.white.withValues(alpha: 0.1) : (dark ? darkBg : light),
    hoverBackground: open ? Colors.white.withValues(alpha: 0.2) : (dark ? null : lightHover),
    foreground: open ? Colors.white : text,
    onTap: onTap,
  );
}

/// Accordion trigger background (`rounded-md`, so its bottom corners are
/// rounded too) with the hover colour.
class _TriggerBox extends StatefulWidget {
  const _TriggerBox({required this.color, required this.hoverColor, required this.padding, required this.onTap, required this.child});
  final Color color;
  final Color? hoverColor;
  final EdgeInsetsGeometry padding;
  final VoidCallback onTap;
  final Widget child;

  @override
  State<_TriggerBox> createState() => _TriggerBoxState();
}

class _TriggerBoxState extends State<_TriggerBox> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final bg = _hover && widget.hoverColor != null ? widget.hoverColor! : widget.color;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: widget.padding,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          child: widget.child,
        ),
      ),
    );
  }
}

/// The section / chapter name (`hover:underline cursor-pointer text-sm text-left`).
class _TriggerName extends StatefulWidget {
  const _TriggerName({required this.text, required this.style});
  final String text;
  final TextStyle style;

  @override
  State<_TriggerName> createState() => _TriggerNameState();
}

class _TriggerNameState extends State<_TriggerName> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: Text(
          widget.text,
          style: widget.style.copyWith(
            decoration: _hover ? TextDecoration.underline : null,
            decorationColor: widget.style.color,
          ),
        ),
      );
}

class _SectionItem extends StatelessWidget {
  const _SectionItem({
    required this.s,
    required this.course,
    required this.section,
    required this.index,
    required this.last,
  });
  final _ClassCourseCreatePageState s;
  final Map<String, dynamic> course;
  final Map<String, dynamic> section;
  final int index;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final value = 'section-$index';
    final open = s._expandedSectionRow == value;
    final showActions =
        s._role == Role.institute || s._institutes.any((inst) => jsTruthy(asMap(inst)?['is_admin']));
    final chapters = s._store.chapters;

    final fg = open ? Colors.white : (dark ? Tw.slate200 : Tw.slate800);
    // Closed: `bg-slate-100 hover:bg-slate-150 dark:bg-slate-950
    // dark:hover:bg-slate-900` (slate-150 doesn't exist: no light hover).
    final header = _TriggerBox(
      color: open ? (dark ? Tw.slate800 : Tw.slate900) : (dark ? Tw.slate950 : Tw.slate100),
      hoverColor: open || !dark ? null : Tw.slate900,
      padding: const EdgeInsets.all(20),
      onTap: () {
        s._set(() => s._expandedSectionRow = open ? '' : value);
        s._onSectionSelect(section);
      },
      child: Row(
        children: [
          _OrderChip(text: 'Sec ${section['order'] ?? ''}', open: open, alpha: 0.15, dark: dark, hPad: 8),
          const SizedBox(width: 12),
          // The name keeps its own `font-semibold` when the trigger turns bold.
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _TriggerName(
                text: '${section['name'] ?? ''}',
                style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: fg),
              ),
            ),
          ),
          if (showActions) ...[
            const SizedBox(width: 8),
            _headerAction(
              context,
              open: open,
              icon: BootstrapIcons.plus,
              iconSize: 18,
              size: 30,
              tooltip: 'Add Chapter',
              light: Tw.yellow50,
              lightHover: Tw.yellow100,
              text: Tw.yellow600,
              darkBg: Tw.yellow950.withValues(alpha: 0.2),
              onTap: s._openCreateChapterDialog,
            ),
            const SizedBox(width: 8),
            _headerAction(
              context,
              open: open,
              icon: BootstrapIcons.pencil_square,
              iconSize: 14,
              size: 30,
              tooltip: 'Edit Section',
              light: Tw.emerald50,
              lightHover: Tw.emerald100,
              text: Tw.emerald600,
              darkBg: Tw.emerald950.withValues(alpha: 0.2),
              onTap: () => s._openSectionUpdateDialog(course['id'], section['id']),
            ),
            const SizedBox(width: 8),
            _headerAction(
              context,
              open: open,
              icon: BootstrapIcons.dash_circle_fill,
              iconSize: 14,
              size: 30,
              tooltip: 'Delete Section',
              light: Tw.rose50,
              lightHover: Tw.rose100,
              text: Tw.rose600,
              darkBg: Tw.rose950.withValues(alpha: 0.2),
              onTap: () => s._openDeleteSectionDialog(section),
            ),
            const SizedBox(width: 16),
          ],
          const SizedBox(width: 16),
          _Chevron(open: open),
        ],
      ),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: _itemBorder(dark ? Tw.slate800 : Tw.slate200, last: last),
        boxShadow: _shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: !open
                ? const SizedBox(width: double.infinity)
                : Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: dark ? Tw.slate900.withValues(alpha: 0.1) : Tw.slate50.withValues(alpha: 0.5),
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
                      border: Border(top: BorderSide(color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate100)),
                    ),
                    child: chapters.isEmpty
                        // `dark:text-slate-550` is not a Tailwind colour.
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text('No chapters available for this section.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 14, height: 20 / 14, color: Tw.slate400)),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (var i = 0; i < chapters.length; i++) ...[
                                if (i > 0) const SizedBox(height: 8),
                                _ChapterItem(
                                  s: s,
                                  course: course,
                                  section: section,
                                  chapter: chapters[i],
                                  index: i,
                                  last: i == chapters.length - 1,
                                ),
                              ],
                            ],
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// `Sec N` / `Ch N` chip (`text-xs font-bold font-mono rounded bg-black/15
/// text-slate-600 dark:text-slate-400`, open: `text-white bg-white/20` — the
/// `dark:text-slate-400` survives, so the open chip's text is slate-400 in
/// dark mode).
class _OrderChip extends StatelessWidget {
  const _OrderChip({required this.text, required this.open, required this.alpha, required this.dark, required this.hPad});
  final String text;
  final bool open;
  final double alpha;
  final bool dark;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 2),
      decoration: BoxDecoration(
        color: open ? Colors.white.withValues(alpha: alpha + 0.05) : Colors.black.withValues(alpha: alpha),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w700,
          fontFamily: 'monospace',
          color: dark ? Tw.slate400 : (open ? Colors.white : (hPad == 8 ? Tw.slate600 : Tw.slate500)),
        ),
      ),
    );
  }
}

/// The accordion trigger's `ChevronDown` (`text-muted-foreground size-4
/// translate-y-0.5`, rotates when open). It keeps the muted colour on the
/// dark open header, as on the web.
class _Chevron extends StatelessWidget {
  const _Chevron({required this.open});
  final bool open;

  @override
  Widget build(BuildContext context) => Transform.translate(
        offset: const Offset(0, 2),
        child: AnimatedRotation(
          turns: open ? 0.5 : 0,
          duration: const Duration(milliseconds: 200),
          child: Icon(BootstrapIcons.chevron_down, size: 16, color: _mutedFg(context)),
        ),
      );
}

class _ChapterItem extends StatelessWidget {
  const _ChapterItem({
    required this.s,
    required this.course,
    required this.section,
    required this.chapter,
    required this.index,
    required this.last,
  });
  final _ClassCourseCreatePageState s;
  final Map<String, dynamic> course;
  final Map<String, dynamic> section;
  final Map<String, dynamic> chapter;
  final int index;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final value = 'chapter-$index';
    final open = s._expandedChapterRow == value;
    final contents = s._store.contents;
    // `text-slate-700 … dark:text-slate-350`: slate-350 doesn't exist, so the
    // closed name stays slate-700 in dark mode.
    final fg = open ? Colors.white : Tw.slate700;

    final header = _TriggerBox(
      color: open
          ? (dark ? Tw.slate700.withValues(alpha: 0.6) : Tw.slate800)
          : (dark ? Tw.slate900.withValues(alpha: 0.5) : Tw.slate50),
      hoverColor: open
          ? null
          : (dark ? Tw.slate800.withValues(alpha: 0.4) : Color.alphaBlend(Tw.slate100.withValues(alpha: 0.5), Colors.white)),
      padding: const EdgeInsets.all(16),
      onTap: () {
        s._set(() => s._expandedChapterRow = open ? '' : value);
        s._onChapterSelect(chapter);
      },
      child: Row(
        children: [
          _OrderChip(text: 'Ch ${chapter['order'] ?? ''}', open: open, alpha: 0.1, dark: dark, hPad: 6),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: _TriggerName(
                text: '${chapter['name'] ?? ''}',
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: open ? FontWeight.w700 : FontWeight.w500,
                  color: fg,
                ),
              ),
            ),
          ),
          if (s._canManage) ...[
            const SizedBox(width: 8),
            _headerAction(
              context,
              open: open,
              icon: BootstrapIcons.plus,
              iconSize: 16,
              size: 28,
              tooltip: 'Add Concept',
              light: Tw.yellow50,
              lightHover: Tw.yellow100,
              text: Tw.yellow600,
              darkBg: Tw.yellow950.withValues(alpha: 0.2),
              onTap: () => s._openConceptDialog(chapter),
            ),
            const SizedBox(width: 8),
            _headerAction(
              context,
              open: open,
              icon: BootstrapIcons.pencil_square,
              iconSize: 12,
              size: 28,
              tooltip: 'Edit Chapter',
              light: Tw.emerald50,
              lightHover: Tw.emerald100,
              text: Tw.emerald600,
              darkBg: Tw.emerald950.withValues(alpha: 0.2),
              onTap: () => s._openChapterUpdateDialog(course['id'], section['id'], chapter['id']),
            ),
            const SizedBox(width: 8),
            _headerAction(
              context,
              open: open,
              icon: BootstrapIcons.dash_circle_fill,
              iconSize: 12,
              size: 28,
              tooltip: 'Delete Chapter',
              light: Tw.rose50,
              lightHover: Tw.rose100,
              text: Tw.rose600,
              darkBg: Tw.rose950.withValues(alpha: 0.2),
              onTap: () => s._openDeleteChapterDialog(chapter),
            ),
            const SizedBox(width: 16),
          ],
          const SizedBox(width: 16),
          _Chevron(open: open),
        ],
      ),
    );

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? Tw.slate950 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: _itemBorder(dark ? Tw.slate800 : Tw.slate200.withValues(alpha: 0.6), last: last),
        boxShadow: _shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: !open
                ? const SizedBox(width: double.infinity)
                : Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: dark ? Tw.slate900.withValues(alpha: 0.1) : Tw.slate50.withValues(alpha: 0.3),
                      border: Border(top: BorderSide(color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate100)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (contents.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Text('No Concepts available.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
                          ),
                        for (var i = 0; i < contents.length; i++)
                          Container(
                            decoration: i == 0
                                ? null
                                : BoxDecoration(
                                    border: Border(
                                      top: BorderSide(
                                          color: dark ? Tw.slate800.withValues(alpha: 0.5) : Tw.slate100),
                                    ),
                                  ),
                            child: _ConceptRow(
                              s: s,
                              content: contents[i],
                              onEdit: () => s._openContentUpdateDialog(
                                  course['id'], section['id'], chapter['id'], contents[i]['id']),
                            ),
                          ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

/// One concept (`flex items-center justify-between py-2.5
/// hover:bg-slate-50/50 dark:hover:bg-slate-900/25`).
class _ConceptRow extends StatefulWidget {
  const _ConceptRow({required this.s, required this.content, required this.onEdit});
  final _ClassCourseCreatePageState s;
  final Map<String, dynamic> content;
  final VoidCallback onEdit;

  @override
  State<_ConceptRow> createState() => _ConceptRowState();
}

class _ConceptRowState extends State<_ConceptRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final s = widget.s;
    final content = widget.content;
    final type = content['type'];
    final inherit = dark ? AppColors.darkForeground : AppColors.foreground;
    // `text-rose-650` / `text-blue-650` / `dark:text-rose-450` are not
    // Tailwind colours: those icons take the inherited foreground.
    final (Color? bg, Color fg, IconData? icon) = switch (type) {
      'html' => (
          dark ? Tw.indigo950.withValues(alpha: 0.3) : Tw.indigo50,
          dark ? Tw.indigo400 : Tw.indigo600,
          BootstrapIcons.file_earmark_richtext
        ),
      'pdf' => (dark ? Tw.rose950.withValues(alpha: 0.3) : Tw.rose50, inherit, BootstrapIcons.filetype_pdf),
      'url' => (
          dark ? Tw.blue950.withValues(alpha: 0.3) : Tw.blue50,
          dark ? Tw.blue400 : inherit,
          BootstrapIcons.link_45deg
        ),
      _ => (null, inherit, null),
    };

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hover ? (dark ? Tw.slate900.withValues(alpha: 0.25) : Tw.slate50.withValues(alpha: 0.5)) : null,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            // `text-slate-450` is not a Tailwind colour: inherited foreground.
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 70),
              child: Text('Concept ${content['order'] ?? ''}',
                  style: TextStyle(fontSize: 12, height: 16 / 12, fontFamily: 'monospace', color: inherit)),
            ),
            const SizedBox(width: 16),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(16),
                boxShadow: _shadowSm,
              ),
              alignment: Alignment.center,
              child: icon == null ? null : Icon(icon, size: 16, color: fg),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: _LinkText(
                  text: '${content['name'] ?? ''}',
                  onTap: () => s._handleContentClick(content),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // `dark:text-emerald-450` / `dark:text-rose-455` are not Tailwind colours.
            _RoundIconButton(
              icon: BootstrapIcons.pencil,
              tooltip: 'Edit Concept',
              background: dark ? Tw.emerald950.withValues(alpha: 0.2) : Tw.emerald50,
              hoverBackground: dark ? Tw.emerald950.withValues(alpha: 0.4) : Tw.emerald100,
              foreground: Tw.emerald600,
              onTap: widget.onEdit,
            ),
            const SizedBox(width: 8),
            _RoundIconButton(
              icon: BootstrapIcons.dash_circle_fill,
              tooltip: 'Delete Concept',
              background: dark ? Tw.rose950.withValues(alpha: 0.2) : Tw.rose50,
              hoverBackground: dark ? Tw.rose950.withValues(alpha: 0.4) : Tw.rose100,
              foreground: Tw.rose600,
              onTap: () => s._openDeleteContentDialog(content),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

/// `text-primary hover:underline font-semibold text-sm cursor-pointer truncate`.
class _LinkText extends StatefulWidget {
  const _LinkText({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  State<_LinkText> createState() => _LinkTextState();
}

class _LinkTextState extends State<_LinkText> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text(
          widget.text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w600,
            color: primary,
            decoration: _hover ? TextDecoration.underline : null,
            decorationColor: primary,
          ),
        ),
      ),
    );
  }
}
