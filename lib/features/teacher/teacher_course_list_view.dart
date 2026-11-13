part of 'teacher_course_page.dart';

/// COURSE LIST VIEW — filter bar, stats, skeleton / empty state, grid & list.
extension _ListView on _TeacherCoursePageState {
  List<Map<String, dynamic>> get _filteredCourses => filterCourses(
        _coursess,
        searchQuery: _searchQuery.text,
        selectedCurriculumId: _selectedCurriculumId,
        selectedGradeId: _selectedGradeId,
      );

  Widget _buildListView() {
    final courses = _filteredCourses;
    final Widget body;
    if (_isListLoading) {
      body = _skeletons();
    } else if (courses.isEmpty) {
      body = _emptyState();
    } else if (_viewMode == 'grid') {
      final cols = context.isXl ? 4 : (context.isMd ? 3 : (context.isSm ? 2 : 1));
      body = _gridRows(
        cols,
        context.isSm ? 16 : 12,
        [for (var i = 0; i < courses.length; i++) _CourseGridCard(course: courses[i], index: i, page: this)],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < courses.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _CourseListRow(course: courses[i], index: i, page: this),
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _filterBar(),
        const SizedBox(height: 16),
        _statsBar(courses.length),
        const SizedBox(height: 16),
        body,
      ],
    );
  }

  /// `grid grid-cols-N gap-X` with equal-height rows.
  Widget _gridRows(int cols, double gap, List<Widget> items) {
    final rows = <Widget>[];
    for (var start = 0; start < items.length; start += cols) {
      final row = Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var c = 0; c < cols; c++) ...[
            if (c > 0) SizedBox(width: gap),
            Expanded(child: start + c < items.length ? items[start + c] : const SizedBox.shrink()),
          ],
        ],
      );
      // Cards stretch to the tallest one in the row (CSS grid); also gives
      // the cards' `Expanded` body a bounded height.
      rows.add(IntrinsicHeight(child: row));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          rows[i],
        ],
      ],
    );
  }

  Widget _filterBar() {
    final dark = context.isDark;
    final sm = context.isSm;
    final border = dark ? Tw.slate700 : Tw.slate200;

    final search = _FilterSearchField(controller: _searchQuery);

    // `<SelectTrigger class="h-9 sm:h-10 text-[13px] border-slate-200
    // dark:border-slate-700 w-full sm:w-[180px]">` with the mortarboard icon;
    // the kit's `data-[size=default]:h-9` beats `sm:h-10`, so it stays 36px.
    final theme = Theme.of(context);
    final inputTheme = theme.inputDecorationTheme;
    final side = BorderSide(color: border);
    final institutes = _store.institutes;
    final classSelect = Theme(
      data: theme.copyWith(
        inputDecorationTheme: inputTheme.copyWith(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          enabledBorder: (inputTheme.enabledBorder ?? inputTheme.border)?.copyWith(borderSide: side),
        ),
      ),
      child: AppSelect<String>(
        value: jsTruthy(_selectedClassId) ? '$_selectedClassId' : 'all',
        placeholder: 'Select class',
        leadingIcon: BootstrapIcons.mortarboard,
        items: [
          const AppSelectItem('all', 'All Classes'),
          for (final inst in institutes) AppSelectItem('${inst['id']}', instituteLabel(inst)),
        ],
        onChanged: _onClassSelectChange,
      ),
    );

    final anyFilter = jsTruthy(_selectedCurriculumId) ||
        jsTruthy(_selectedGradeId) ||
        _searchQuery.text.isNotEmpty ||
        jsTruthy(_selectedClassId);
    final clear = anyFilter ? _ClearFiltersButton(onTap: _clearAllFilters) : null;

    // `flex items-center gap-0.5 border rounded-lg bg-white dark:bg-slate-800 p-1`
    final toggles = Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dark ? Tw.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        _ViewToggleButton(
          icon: BootstrapIcons.grid_3x3_gap_fill,
          active: _viewMode == 'grid',
          onTap: () => _set(() => _viewMode = 'grid'),
        ),
        const SizedBox(width: 2),
        _ViewToggleButton(
          icon: BootstrapIcons.list_ul,
          active: _viewMode == 'list',
          onTap: () => _set(() => _viewMode = 'list'),
        ),
      ]),
    );

    if (!sm) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          search,
          const SizedBox(height: 8),
          classSelect,
          const SizedBox(height: 8),
          Row(children: [?clear, const Spacer(), toggles]),
        ],
      );
    }
    return Row(
      children: [
        Flexible(
          child: ConstrainedBox(constraints: const BoxConstraints(minWidth: 180, maxWidth: 320), child: search),
        ),
        const SizedBox(width: 8),
        SizedBox(width: 180, child: classSelect),
        const SizedBox(width: 8),
        if (clear != null) ...[clear, const SizedBox(width: 8)],
        toggles,
      ],
    );
  }

  Widget _statsBar(int count) {
    final dark = context.isDark;
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text.rich(
          TextSpan(children: [
            TextSpan(
              text: '$count',
              style: TextStyle(fontWeight: FontWeight.w700, color: dark ? Colors.white : Tw.slate800),
            ),
            const TextSpan(text: ' courses'),
          ]),
          style: TextStyle(fontSize: context.isSm ? 13 : 12, color: Tw.slate500),
        ),
        if (_selectedClassName.isNotEmpty)
          EmeraldBadge(icon: BootstrapIcons.mortarboard_fill, label: _selectedClassName),
        if (jsTruthy(_selectedCurriculumId) || _searchQuery.text.isNotEmpty)
          const EmeraldBadge(icon: BootstrapIcons.funnel_fill, label: 'Filtered'),
      ],
    );
  }

  Widget _skeletons() {
    final sm = context.isSm;
    final dark = context.isDark;
    Widget card() => Container(
          padding: EdgeInsets.all(sm ? 20 : 16),
          decoration: BoxDecoration(
            color: dark ? Tw.slate800 : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dark ? Tw.slate700 : Tw.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // `rounded-xl` (20) / `rounded-md` (14)
                  Skeleton(width: sm ? 44 : 40, height: sm ? 44 : 40, radius: 20),
                  const Spacer(),
                  const Skeleton(width: 80, height: 24, radius: 14),
                ],
              ),
              const SizedBox(height: 12),
              const FractionallySizedBox(widthFactor: 0.8, child: Skeleton(height: 16, radius: 4)),
              const SizedBox(height: 12),
              const FractionallySizedBox(widthFactor: 0.5, child: Skeleton(height: 12, radius: 4)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: dark ? Tw.slate700 : Tw.slate100)),
                ),
                child: const Row(children: [
                  Skeleton(width: 80, height: 12, radius: 4),
                  Spacer(),
                  Skeleton(width: 56, height: 12, radius: 4),
                ]),
              ),
            ],
          ),
        );

    final items = [for (var i = 0; i < 8; i++) card()];
    if (_viewMode == 'grid') {
      final cols = context.isLg ? 4 : (context.isMd ? 3 : (sm ? 2 : 1));
      return _gridRows(cols, sm ? 16 : 12, items);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          items[i],
        ],
      ],
    );
  }

  Widget _emptyState() {
    final dark = context.isDark;
    final sm = context.isSm;
    final circle = sm ? 72.0 : 64.0;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: sm ? 80 : 64, horizontal: 16),
      child: Column(
        children: [
          // `rounded-full … border-2 border-dashed`
          CustomPaint(
            foregroundPainter: _DashedCirclePainter(color: dark ? Tw.slate700 : Tw.slate200),
            child: Container(
              width: circle,
              height: circle,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: dark ? Tw.slate800 : Tw.slate100, shape: BoxShape.circle),
              child: Icon(BootstrapIcons.journal_x, size: sm ? 30 : 24, color: Tw.slate400),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No courses found',
            style: TextStyle(
              height: 1.5,
              fontSize: sm ? 16 : 14,
              fontWeight: FontWeight.w700,
              color: dark ? Colors.white : Tw.slate800,
            ),
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Text(
              _selectedClassName.isNotEmpty
                  ? 'No courses in "$_selectedClassName".'
                  : 'Adjust your filters or create a new course.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Tw.slate400),
            ),
          ),
          if (_canManage) ...[
            const SizedBox(height: 20),
            _GradientPillButton(label: 'New Course', fontSize: 13, onTap: _openCreateDialog),
          ],
        ],
      ),
    );
  }
}

/// Hover tracking for the course cards / rows
/// (`hover:border-emerald-400 hover:shadow-xl`).
class _Hoverable extends StatefulWidget {
  const _Hoverable({required this.builder});
  final Widget Function(bool hover) builder;

  @override
  State<_Hoverable> createState() => _HoverableState();
}

class _HoverableState extends State<_Hoverable> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: widget.builder(_hover),
      );
}

/// One card of the GRID VIEW.
class _CourseGridCard extends StatelessWidget {
  const _CourseGridCard({required this.course, required this.index, required this.page});
  final Map<String, dynamic> course;
  final int index;
  final _TeacherCoursePageState page;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final canManage = page._canManage;
    final curriculum = courseCurriculum(course);
    String orDash(Object? v) => jsTruthy(v) ? '$v' : '—';

    final top = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => page._openCourse(course, index),
        child: Padding(
          padding: EdgeInsets.all(sm ? 20 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SubjectIconBox(
                    title: course['title'],
                    size: sm ? 44 : 40,
                    iconSize: sm ? 18 : 16,
                  ),
                  const Spacer(),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 100),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: dark ? Tw.slate700 : Tw.slate100,
                      borderRadius: BorderRadius.circular(14), // rounded-md
                      border: Border.all(color: dark ? Tw.slate600 : Tw.slate200),
                    ),
                    child: Text(
                      (curriculum.isEmpty ? '—' : curriculum).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.25,
                        color: dark ? Tw.slate300 : Tw.slate500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                '${course['title'] ?? ''}',
                style: TextStyle(
                  fontSize: sm ? 14.5 : 13.5,
                  fontWeight: FontWeight.w700,
                  height: 1.375,
                  color: dark ? Colors.white : Tw.slate900,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(orDash(course['short_name']), style: TextStyle(fontSize: sm ? 11.5 : 11, color: Tw.slate400)),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(color: Tw.slate300, shape: BoxShape.circle),
                  ),
                  Text(orDash(course['course_code']), style: TextStyle(fontSize: sm ? 11.5 : 11, color: Tw.slate400)),
                ],
              ),
              const SizedBox(height: 12),
              Row(children: [
                Icon(BootstrapIcons.collection, size: sm ? 12 : 11.5, color: Tw.slate400),
                const SizedBox(width: 6),
                Text(modulesLabel(course['sections_count']),
                    style: TextStyle(fontSize: sm ? 12 : 11.5, color: Tw.slate400)),
              ]),
            ],
          ),
        ),
      ),
    );

    final footer = Container(
      padding: EdgeInsets.symmetric(horizontal: sm ? 20 : 16, vertical: 10),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900.withValues(alpha: 0.5) : Tw.slate50,
        border: Border(top: BorderSide(color: dark ? Tw.slate700 : Tw.slate100)),
      ),
      child: Row(
        children: [
          StatusDot(course['status']),
          const SizedBox(width: 6),
          Expanded(
            child: Text(capitalizeWords(course['status']),
                overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Tw.slate400)),
          ),
          if (canManage)
            Row(mainAxisSize: MainAxisSize.min, children: [
              SquareActionButton(delete: false, onTap: () => page._openUpdateDialog(course['id'])),
              const SizedBox(width: 6),
              SquareActionButton(delete: true, onTap: () => page._openDeleteCourseDialog(course)),
            ])
          else
            const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(BootstrapIcons.eye, size: 11, color: Tw.slate400),
              SizedBox(width: 4),
              Text('View only', style: TextStyle(fontSize: 10, color: Tw.slate400)),
            ]),
        ],
      ),
    );

    return _Hoverable(
      builder: (hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: dark ? Tw.slate800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hover ? Tw.emerald400 : (dark ? Tw.slate700 : Tw.slate200)),
          // `hover:shadow-xl` (the `shadow-slate-200/60` tint can't apply).
          boxShadow: hover ? TcShadows.xl : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Expanded(child: top), footer],
        ),
      ),
    );
  }
}

/// One row of the LIST VIEW.
class _CourseListRow extends StatelessWidget {
  const _CourseListRow({required this.course, required this.index, required this.page});
  final Map<String, dynamic> course;
  final int index;
  final _TeacherCoursePageState page;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    void open() => page._openCourse(course, index);
    final curriculum = courseCurriculum(course);
    final sub = '${course['short_name'] ?? ''} • ${course['course_code'] ?? ''}'
        '${sm ? ' • ${curriculum.isEmpty ? 'No curriculum' : curriculum}' : ''}';

    return _Hoverable(
      builder: (hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: sm ? 16 : 12, vertical: sm ? 14 : 12),
        decoration: BoxDecoration(
          color: dark ? Tw.slate800 : Colors.white,
          borderRadius: BorderRadius.circular(20), // rounded-xl
          border: Border.all(color: hover ? Tw.emerald400 : (dark ? Tw.slate700 : Tw.slate200)),
          boxShadow: hover ? TcShadows.md : null,
        ),
        child: Row(
          children: [
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: open,
                child: SubjectIconBox(
                  title: course['title'],
                  size: sm ? 40 : 36,
                  radius: 16, // rounded-lg
                  iconSize: sm ? 15 : 14,
                ),
              ),
            ),
            SizedBox(width: sm ? 14 : 10),
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: open,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${course['title'] ?? ''}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: sm ? 14 : 13,
                          fontWeight: FontWeight.w600,
                          color: dark ? Colors.white : Tw.slate900,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(sub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: sm ? 12 : 11, color: Tw.slate400)),
                    ],
                  ),
                ),
              ),
            ),
            if (sm) ...[
              SizedBox(width: sm ? 14 : 10),
              const Icon(BootstrapIcons.collection, size: 12, color: Tw.slate500),
              const SizedBox(width: 6),
              Text('${course['sections_count'] ?? 0}', style: const TextStyle(fontSize: 12, color: Tw.slate500)),
            ],
            // The status badge is `hidden xs:flex` — never shown (no `xs` breakpoint).
            if (page._canManage) ...[
              SizedBox(width: sm ? 14 : 10),
              SquareActionButton(delete: false, onTap: () => page._openUpdateDialog(course['id'])),
              const SizedBox(width: 6),
              SquareActionButton(delete: true, onTap: () => page._openDeleteCourseDialog(course)),
            ],
          ],
        ),
      ),
    );
  }
}

/// The search `<Input class="pl-9 pr-9 h-9 sm:h-10 text-[13px] border-slate-200
/// dark:border-slate-700">` (the kit's `md:text-sm` makes it 14px from 768px)
/// with the `bi-search` icon (`left-3 text-[13px] text-slate-400`) and the
/// `bi-x text-lg` clear button (`right-2.5`, `hover:text-slate-600`).
class _FilterSearchField extends StatelessWidget {
  const _FilterSearchField({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final inputTheme = Theme.of(context).inputDecorationTheme;
    final side = BorderSide(color: dark ? Tw.slate700 : Tw.slate200);
    final empty = controller.text.isEmpty;
    return Container(
      height: context.isSm ? 40 : 36,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        boxShadow: TcShadows.xs,
      ),
      child: TextField(
        controller: controller,
        expands: true,
        maxLines: null,
        textAlignVertical: TextAlignVertical.center,
        style: TextStyle(fontSize: context.isMd ? 14 : 13),
        decoration: InputDecoration(
          hintText: 'Search courses...',
          isDense: true,
          contentPadding: EdgeInsets.only(right: empty ? 36 : 0),
          enabledBorder: (inputTheme.enabledBorder ?? inputTheme.border)?.copyWith(borderSide: side),
          prefixIcon: const Icon(BootstrapIcons.search, size: 13, color: Tw.slate400),
          prefixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 0),
          suffixIcon: empty
              ? null
              : IconTapButton(
                  icon: BootstrapIcons.x,
                  size: 18,
                  color: Tw.slate400,
                  hoverColor: Tw.slate600,
                  onTap: controller.clear,
                ),
          suffixIconConstraints: const BoxConstraints(minWidth: 36, minHeight: 0),
        ),
      ),
    );
  }
}

/// `<Button variant="ghost" class="gap-1 text-[12px] font-medium text-red-500
/// hover:text-red-600 hover:bg-red-50 dark:hover:bg-red-950 h-9 sm:h-10 px-2">`
/// — the "Clear" label is `hidden sm:inline`.
class _ClearFiltersButton extends StatefulWidget {
  const _ClearFiltersButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_ClearFiltersButton> createState() => _ClearFiltersButtonState();
}

class _ClearFiltersButtonState extends State<_ClearFiltersButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final sm = context.isSm;
    final fg = _hover ? Tw.red600 : Tw.red500;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: sm ? 40 : 36,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: _hover ? (context.isDark ? TcTw.red950 : TcTw.red50) : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(BootstrapIcons.x_circle, size: 12, color: fg),
            if (sm) ...[
              const SizedBox(width: 4),
              Text('Clear', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: fg)),
            ],
          ]),
        ),
      ),
    );
  }
}

/// A grid / list toggle (`w-7 h-7 sm:w-8 sm:h-8 rounded-md text-sm`; active
/// `bg-emerald-500 text-white`, else `text-slate-400 hover:text-slate-700
/// dark:hover:text-slate-200 hover:bg-slate-100 dark:hover:bg-slate-700`).
class _ViewToggleButton extends StatefulWidget {
  const _ViewToggleButton({required this.icon, required this.active, required this.onTap});
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_ViewToggleButton> createState() => _ViewToggleButtonState();
}

class _ViewToggleButtonState extends State<_ViewToggleButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final size = context.isSm ? 32.0 : 28.0;
    final active = widget.active;
    final Color bg = active
        ? Tw.emerald500
        : (_hover ? (dark ? Tw.slate700 : Tw.slate100) : Colors.transparent);
    final Color fg = active ? Colors.white : (_hover ? (dark ? Tw.slate200 : Tw.slate700) : Tw.slate400);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
          child: Icon(widget.icon, size: 14, color: fg),
        ),
      ),
    );
  }
}

/// `border-2 border-dashed` around the empty-state circle.
class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rect = Rect.fromLTWH(1, 1, size.width - 2, size.height - 2);
    final circumference = math.pi * rect.width;
    // Chrome draws 2px dashes as ~6px dash / 6px gap around a circle.
    const dash = 6.0;
    final count = (circumference / (dash * 2)).floor().clamp(1, 1000);
    final sweep = 2 * math.pi / count;
    for (var i = 0; i < count; i++) {
      canvas.drawArc(rect, i * sweep, sweep / 2, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}
