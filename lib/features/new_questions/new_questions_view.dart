part of 'new_questions_page.dart';

/// The page template: header, filters and the questions card.
extension _NewQuestionsView on _NewQuestionsPageState {
  Widget _buildPage(BuildContext context) {
    final store = ref.watch(questionsControllerProvider);
    final role = ref.watch(sessionProvider.select((s) => s.role));
    final sm = context.isSm;
    // `p-3 sm:p-4 flex flex-col gap-5 w-full max-w-6xl mx-auto`: the padding
    // sits inside the 1152px box.
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1152),
          child: Padding(
            padding: EdgeInsets.all(sm ? 16 : 12),
            child: NqSlideUp(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (role != 'student') ...[
                    _header(context, role == 'instructor' && store.courses.isNotEmpty),
                    const SizedBox(height: 20),
                  ],
                  _filters(context, store),
                  const SizedBox(height: 20),
                  _questionsCard(context, role == 'instructor'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// `!bg-cyan-500 hover:!bg-cyan-400 !text-slate-900 font-black rounded-xl
  /// px-… py-2.5 flex items-center gap-2 shadow-lg h-auto text-sm`.
  Widget _addQuestionButton({double horizontalPadding = 16, bool hoverScale = true}) => NqButton(
        label: 'Add Question',
        icon: BootstrapIcons.plus_lg,
        shadow: AppShadows.lg,
        hoverScale: hoverScale,
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 10),
        onPressed: _openCreateDialog,
      );

  Widget _header(BuildContext context, bool showActions) {
    final dark = context.isDark;
    final sm = context.isSm;
    final md = context.isMd;
    final size = md ? 36.0 : (sm ? 30.0 : 24.0);
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // `font-urbanist` isn't defined in the web build: the default font.
        Text(
          'Questions',
          style: TextStyle(
            fontSize: size,
            height: twLineHeight(size) / size,
            fontWeight: FontWeight.w900,
            color: dark ? Colors.white : Tw.slate900,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Browse, manage and import exam questions.',
          style: TextStyle(
            fontSize: sm ? 14 : 12,
            height: sm ? 20 / 14 : 16 / 12,
            color: dark ? Tw.slate400 : Tw.slate500,
          ),
        ),
      ],
    );
    // `<i class="bi … me-2" />Template` in a `gap-2` button: 16px apart.
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        NqButton.plain(
          context,
          label: 'Template',
          icon: BootstrapIcons.download,
          iconGap: 16,
          onPressed: _downloadTemplate,
        ),
        NqButton.plain(
          context,
          label: 'Import',
          icon: BootstrapIcons.upload,
          iconGap: 16,
          onPressed: _openImportDialog,
        ),
        _addQuestionButton(),
      ],
    );
    if (!sm) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [title, if (showActions) ...[const SizedBox(height: 12), actions]],
      );
    }
    // `sm:flex-row sm:justify-between sm:items-end`: the buttons keep their
    // width at the right edge.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: title),
        if (showActions) ...[const SizedBox(width: 12), actions],
      ],
    );
  }

  Widget _filters(BuildContext context, QuestionsState store) {
    final dark = context.isDark;
    final courses = store.courses;
    final chapters = store.chapters;
    final contents = _filteredContents;
    // `!bg-white dark:!bg-[#1e1b4b]` triggers.
    final fill = dark ? NqTw.navy : Colors.white;
    return FormGrid(
      columns: context.isLg ? 3 : (context.isSm ? 2 : 1),
      gap: 12,
      children: [
        NqField(
          label: const NqLabel('Course'),
          child: nqSelect(
            context,
            value: _selectedCourseId,
            items: courses.isNotEmpty
                ? [for (final c in courses) AppSelectItem('${c['id']}', displayValue(c['title']))]
                : const [AppSelectItem(noOptionsValue, 'No courses available', enabled: false)],
            onChanged: _setSelectedCourseId,
            placeholder: courses.isNotEmpty ? 'Select Course' : 'No courses available',
            enabled: courses.isNotEmpty,
            fill: fill,
          ),
        ),
        NqField(
          label: const NqLabel('Chapter'),
          child: nqSelect(
            context,
            value: _selectedChapterId,
            items: chapters.isNotEmpty
                ? [for (final c in chapters) AppSelectItem('${c['id']}', displayValue(c['name']))]
                : const [AppSelectItem.message(noOptionsValue, 'No chapters found', messageColor: Tw.slate400)],
            onChanged: _setSelectedChapterId,
            placeholder: _selectedCourseId.isEmpty
                ? 'Select course first'
                : chapters.isNotEmpty
                    ? 'Select Chapter'
                    : 'No chapters available',
            enabled: _selectedCourseId.isNotEmpty && chapters.isNotEmpty,
            fill: fill,
          ),
        ),
        NqField(
          label: const NqLabel('Content'),
          child: nqSelect(
            context,
            value: _selectedContentId,
            items: contents.isNotEmpty
                ? [for (final c in contents) AppSelectItem('${c['id']}', displayValue(c['name']))]
                : const [AppSelectItem(noOptionsValue, 'No content available', enabled: false)],
            onChanged: _setSelectedContentId,
            placeholder: _selectedChapterId.isEmpty
                ? 'Select chapter first'
                : contents.isNotEmpty
                    ? 'Select Content'
                    : 'No content available',
            enabled: _selectedChapterId.isNotEmpty && contents.isNotEmpty,
            fill: fill,
          ),
        ),
      ],
    );
  }

  /// `rounded-2xl border border-slate-200 dark:border-white/10 bg-white
  /// dark:bg-[#1e1b4b] shadow-sm overflow-hidden`
  Widget _questionsCard(BuildContext context, bool instructor) {
    final dark = context.isDark;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? NqTw.navy : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: NqTw.border(context)),
        boxShadow: AppShadows.sm,
      ),
      child: _questions.isEmpty ? _emptyState(context, instructor) : _table(context, instructor),
    );
  }

  Widget _emptyState(BuildContext context, bool instructor) {
    final dark = context.isDark;
    final sm = context.isSm;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: sm ? 96 : 64),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: dark ? NqTw.white(0.05) : Tw.slate50,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: NqTw.border(context)),
              boxShadow: AppShadows.sm,
            ),
            child: Icon(BootstrapIcons.patch_question, size: 30, color: dark ? Tw.slate600 : Tw.slate300),
          ),
          const SizedBox(height: 24),
          Text(
            'No Questions Found',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: sm ? 20 : 18,
              height: 28 / (sm ? 20 : 18),
              fontWeight: FontWeight.w900,
              color: dark ? Colors.white : Tw.slate900,
            ),
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              'Select a course, chapter, and content to load questions, or add a new question.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: sm ? 14 : 12, height: 1.625, color: Tw.slate500),
            ),
          ),
          if (instructor) ...[
            const SizedBox(height: 20),
            _addQuestionButton(horizontalPadding: 20, hoverScale: false),
          ],
        ],
      ),
    );
  }

  Widget _table(BuildContext context, bool instructor) {
    // Fixed `w-[…]` columns; Question takes the rest of `min-w-[900px]`.
    const widths = <double?>[100, 110, null, 120, 120, 80];
    final labels = ['Language', 'Code', 'Question', 'Type', 'Difficulty', 'Marks'];
    final allWidths = [...widths, if (instructor) 120.0];
    final allLabels = [...labels, if (instructor) 'Actions'];

    Widget cell(int i, Widget child, {required bool header}) {
      final pad = header ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8) : const EdgeInsets.all(8);
      final end = instructor && i == allWidths.length - 1;
      final content = Padding(
        padding: pad,
        child: Align(alignment: end ? Alignment.centerRight : Alignment.centerLeft, child: child),
      );
      final w = allWidths[i];
      return w == null ? Expanded(child: content) : SizedBox(width: w, child: content);
    }

    // style.css `thead th { background: var(--primary); color:
    // var(--primary-foreground) }` beats the row's `bg-slate-50` and the
    // heads' `text-slate-500`; `text-[10px] font-black uppercase
    // tracking-wider` still apply.
    final scheme = context.colors;
    final headerRow = Container(
      constraints: const BoxConstraints(minHeight: 40),
      decoration: BoxDecoration(
        color: scheme.primary,
        border: Border(bottom: BorderSide(color: context.borderColor)),
      ),
      child: Row(
        children: [
          for (var i = 0; i < allLabels.length; i++)
            cell(
              i,
              Text(
                allLabels[i].toUpperCase(),
                maxLines: 1,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: scheme.onPrimary,
                ),
              ),
              header: true,
            ),
        ],
      ),
    );

    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth.isFinite && c.maxWidth > 900 ? c.maxWidth : 900.0;
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                headerRow,
                for (var r = 0; r < _questions.length; r++)
                  _NqHoverRow(
                    last: r == _questions.length - 1,
                    // `p-2` around the 28px action buttons / a 20px line.
                    minHeight: instructor ? 44 : 36,
                    child: Row(
                      children: [
                        for (final (i, w) in _rowCells(context, _questions[r], instructor).indexed)
                          cell(i, w, header: false),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _rowCells(BuildContext context, Map<String, dynamic> q, bool instructor) {
    final dark = context.isDark;
    final difficulty = q['difficulty_level'];
    final (Color? diffBg, Color? diffFg) = switch (difficulty) {
      'EASY' => (
          dark ? Tw.emerald900.withValues(alpha: 0.4) : Tw.emerald100,
          dark ? Tw.emerald300 : Tw.emerald700,
        ),
      'MEDIUM' => (
          dark ? Tw.amber900.withValues(alpha: 0.4) : Tw.amber100,
          dark ? Tw.amber300 : Tw.amber700,
        ),
      'HARD' => (
          dark ? Tw.rose900.withValues(alpha: 0.4) : Tw.rose100,
          dark ? Tw.rose300 : Tw.rose700,
        ),
      _ => (null, null),
    };
    // The action buttons' `bi … text-xs` icons are 18px: style.css's
    // unlayered `table .bi { font-size: 18px }` beats the utility.
    return [
      NqPill(
        text: getLocaleName(q['default_locale']),
        bg: dark ? NqTw.white(0.1) : Tw.slate100,
        fg: dark ? Tw.slate400 : Tw.slate600,
        weight: FontWeight.w500,
      ),
      Text(
        displayValue(q['code']),
        style: TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w700,
          color: dark ? Tw.slate200 : Tw.slate800,
        ),
      ),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: HtmlText(
          truncate(q['stem']),
          maxLines: 2,
          softWrap: false,
          style: TextStyle(fontSize: 12, height: 16 / 12, color: dark ? Tw.slate300 : Tw.slate700),
        ),
      ),
      NqPill(
        text: displayValue(q['question_type']),
        bg: dark ? Tw.indigo900.withValues(alpha: 0.4) : Tw.indigo100,
        fg: dark ? Tw.indigo300 : Tw.indigo700,
      ),
      NqPill(text: displayValue(difficulty), bg: diffBg, fg: diffFg),
      Text(
        displayValue(q['marks']),
        style: TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w700,
          color: dark ? Tw.slate200 : Tw.slate800,
        ),
      ),
      if (instructor)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            NqIconButton(
              icon: BootstrapIcons.eye_fill,
              iconSize: 18,
              color: Tw.blue500,
              background: dark ? Tw.blue900.withValues(alpha: 0.3) : Tw.blue50,
              hoverBackground: dark ? Tw.blue900.withValues(alpha: 0.5) : Tw.blue100,
              onTap: () => _openPreview(q),
            ),
            const SizedBox(width: 8),
            NqIconButton(
              icon: BootstrapIcons.pencil_square,
              iconSize: 18,
              color: Tw.emerald500,
              background: dark ? Tw.emerald900.withValues(alpha: 0.3) : Tw.emerald50,
              hoverBackground: dark ? Tw.emerald900.withValues(alpha: 0.5) : Tw.emerald100,
              onTap: () => _openEditDialog(q),
            ),
            const SizedBox(width: 8),
            NqIconButton(
              icon: BootstrapIcons.trash3_fill,
              iconSize: 18,
              color: Tw.rose500,
              background: dark ? Tw.rose900.withValues(alpha: 0.3) : Tw.rose50,
              hoverBackground: dark ? Tw.rose900.withValues(alpha: 0.5) : Tw.rose100,
              onTap: () => _openDeleteDialog(q),
            ),
          ],
        ),
    ];
  }
}

/// `<TableRow class="border-b border-slate-100 dark:border-white/5
/// hover:bg-slate-50 dark:hover:bg-white/5 transition-colors">`
class _NqHoverRow extends StatefulWidget {
  const _NqHoverRow({required this.child, required this.last, required this.minHeight});
  final Widget child;
  final bool last;
  final double minHeight;

  @override
  State<_NqHoverRow> createState() => _NqHoverRowState();
}

class _NqHoverRowState extends State<_NqHoverRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        constraints: BoxConstraints(minHeight: widget.minHeight),
        decoration: BoxDecoration(
          color: _hover ? (dark ? NqTw.white(0.05) : Tw.slate50) : null,
          border: widget.last
              ? null
              : Border(bottom: BorderSide(color: dark ? NqTw.white(0.05) : Tw.slate100)),
        ),
        child: widget.child,
      ),
    );
  }
}
