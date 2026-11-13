part of 'course_list_view.dart';

/// Header banner (`hideTriggers`), the curriculum/course switchers and the
/// curriculum tab.
extension _TabsUi on _CourseListViewState {
  /// `<div v-if="hideTriggers && !expandedCourse" class="relative bg-primary …">`
  Widget _buildBanner() {
    final sm = context.isSm;
    final md = context.isMd;
    final curriculum = _activeTab == 'curriculum';
    // `text-lg sm:text-xl md:text-2xl` (line heights 28 / 28 / 32), `tracking-tight`.
    final titleSize = md ? 24.0 : (sm ? 20.0 : 18.0);
    final titleLine = md ? 32.0 : 28.0;
    return Container(
      decoration: BoxDecoration(
        color: context.colors.primary,
        border: Border(bottom: BorderSide(color: context.isDark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate100)),
        boxShadow: _CC.shadowMd,
      ),
      child: Stack(
        children: [
          // radial-gradient(circle at 85% 15%, #fff 0, transparent 55%) at 10%.
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(0.7, -0.7),
                    radius: 0.9,
                    colors: [Colors.white, Colors.white.withValues(alpha: 0)],
                    stops: const [0, 0.55],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: sm ? 24 : 16, vertical: sm ? 24 : 16),
            child: Row(
              children: [
                Container(
                  width: sm ? 48 : 40,
                  height: sm ? 48 : 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _CC.shadowMd,
                  ),
                  child: Icon(
                    curriculum ? BootstrapIcons.journal_text : BootstrapIcons.mortarboard,
                    size: sm ? 24 : 20,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: sm ? 16 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        curriculum ? 'Curriculums' : 'Courses',
                        style: TextStyle(
                          fontSize: titleSize,
                          height: titleLine / titleSize,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: titleSize * -0.025,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        curriculum
                            ? 'Manage departments, learning streams, and global curricula.'
                            : 'Organise individual courses, chapters, section logs, and assessments.',
                        style: TextStyle(fontSize: 12, height: 16 / 12, color: Colors.white.withValues(alpha: 0.8)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// `<div class="block lg:hidden w-full sm:w-72 mb-6"><Select v-model="activeTab">`
  Widget _buildMobileTabSelect(CoursesState cs) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final curriculum = _activeTab == 'curriculum';
    final curriculumCount = cs.curriculums.length;
    final courseCount = _filteredCourses.length;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: context.isSm ? 288 : double.infinity,
          child: LayoutBuilder(
            builder: (context, c) {
              // Item content: menu `p-1` + item `pl-2 pr-8` (check included).
              final itemWidth = c.maxWidth - 8 - 16;
              Widget option(String value, IconData icon, String label, int count) => _menuItem(
                select: true,
                width: itemWidth,
                selected: _activeTab == value,
                onPressed: () => _set(() => _activeTab = value),
                // `flex items-center justify-between w-full`
                child: Row(
                  children: [
                    Icon(icon, size: 14),
                    const SizedBox(width: 8),
                    Expanded(child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 12),
                    _CountBadge(count, bg: dark ? Tw.slate800 : Tw.slate100),
                  ],
                ),
              );
              return _Dropdown(
                radius: 20,
                items: [
                  _menuLabel('Learning Management'),
                  option('curriculum', BootstrapIcons.journal_text, 'Curriculum', curriculumCount),
                  option('course', BootstrapIcons.mortarboard, 'Course', courseCount),
                ],
                // `<SelectTrigger class="w-full h-12 rounded-xl border-slate-200
                // dark:border-slate-800 bg-slate-50 dark:bg-slate-900">` — the
                // kit's `data-[size=default]:h-9` beats `h-12`.
                trigger: (toggle, _) => _OutlineTrigger(
                  onTap: toggle,
                  button: false,
                  spaceBetween: true,
                  background: dark ? Tw.slate900 : Tw.slate50,
                  borderColor: dark ? Tw.slate800 : Tw.slate200,
                  leading: Icon(
                    curriculum ? BootstrapIcons.journal_text : BootstrapIcons.mortarboard,
                    size: 14,
                    color: primary,
                  ),
                  text: curriculum ? 'Curriculum' : 'Course',
                  textStyle: const TextStyle(fontWeight: FontWeight.w500),
                  trailingBadge: _CountBadge(curriculum ? curriculumCount : courseCount),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// Desktop underline tab switcher (`hidden lg:flex`).
  Widget _buildDesktopTabs(CoursesState cs) {
    final dark = context.isDark;
    Widget tab(String value, IconData icon, String label, int count) {
      final active = _activeTab == value;
      final primary = context.colors.primary;
      return _Hover(
        onTap: () => _set(() => _activeTab = value),
        builder: (h) {
          final fg = active
              ? primary
              : h
              ? (dark ? Tw.slate200 : Tw.slate700)
              : (dark ? Tw.slate400 : Tw.slate500);
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // `w-7 h-7 rounded-lg` (16px → round).
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: active ? primary.withValues(alpha: 0.1) : (dark ? Tw.slate800 : Tw.slate100),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(icon, size: 14, color: active ? primary : Tw.slate400),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: fg),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: active ? primary.withValues(alpha: 0.1) : (dark ? Tw.slate800 : Tw.slate100),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: active ? primary : (dark ? Tw.slate400 : Tw.slate500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 2,
                decoration: BoxDecoration(
                  color: active ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          );
        },
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dark ? Tw.slate700 : Tw.slate200)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IntrinsicWidth(child: tab('curriculum', BootstrapIcons.journal_text, 'Curriculum', cs.curriculums.length)),
            IntrinsicWidth(child: tab('course', BootstrapIcons.mortarboard, 'Course', _filteredCourses.length)),
          ],
        ),
      ),
    );
  }

  // ── Curriculum tab ────────────────────────────────────────────────────

  Widget _buildCurriculumTab(CoursesState cs) {
    final sm = context.isSm;
    final lg = context.isLg;
    // `<input class="w-full sm:w-72 pl-9 pr-4 py-2.5 … rounded-xl">` with the
    // `bi-search absolute left-3 text-slate-400` icon.
    final searchField = _WebInput(
      controller: _searchQueryCurriculum,
      hint: 'Search curriculum...',
      prefixIcon: BootstrapIcons.search,
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
      onSubmitted: (_) => _searchCurriculumByName(),
    );
    // `<i class="bi bi-search mr-1" /> <span class="hidden xs:inline">Search</span>`
    // (`xs` = the component's own 380px rule).
    final searchButton = _RoundedButton(
      leading: const Icon(BootstrapIcons.search),
      label: context.screenWidth >= 380 ? 'Search' : null,
      gap: 12,
      shadow: _CC.shadowSm,
      onPressed: _searchCurriculumByName,
    );
    final search = Row(
      mainAxisSize: sm ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (sm) SizedBox(width: 288, child: searchField) else Expanded(child: searchField),
        const SizedBox(width: 8),
        searchButton,
      ],
    );
    // `<Button class="rounded-xl shadow-sm gap-1.5 w-full sm:w-auto"><i bi-plus-circle/> Add Curriculum`
    final add = _RoundedButton(
      leading: const Icon(BootstrapIcons.plus_circle),
      label: 'Add Curriculum',
      gap: 6,
      shadow: _CC.shadowSm,
      onPressed: () => unawaited(_showDialog(_buildCurriculumCreateDialog, guard: true)),
    );

    return LayoutBuilder(
      builder: (context, c) {
        // `px-0 sm:px-[3%] lg:px-[10%]`
        final pad = c.maxWidth * (lg ? 0.10 : (sm ? 0.03 : 0));
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: pad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (sm)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(child: search),
                    add,
                  ],
                )
              else ...[
                search,
                const SizedBox(height: 12),
                add,
              ],
              const SizedBox(height: 24),
              _buildCurriculumTable(cs),
            ],
          ),
        );
      },
    );
  }

  /// The curriculum `<Table class="min-w-[520px]">` inside its card. The
  /// component overrides the global `thead th` colours (transparent header
  /// cells, inherited text colour, `font-weight: 600`, `.75rem 1rem`), and
  /// `table .bi` makes every icon in the table 18px.
  Widget _buildCurriculumTable(CoursesState cs) {
    final dark = context.isDark;
    final border = dark ? AppColors.darkBorder : AppColors.border;
    final muted = dark ? AppColors.darkMuted : AppColors.muted;
    const flex = [5, 3, 2];

    Widget row(List<Widget> cells, {EdgeInsets padding = const EdgeInsets.all(8)}) => Row(
      children: [
        for (var i = 0; i < cells.length; i++)
          Expanded(
            flex: flex[i],
            child: Padding(padding: padding, child: cells[i]),
          ),
      ],
    );

    final headerStyle = TextStyle(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
      color: context.colors.onSurface,
    );
    // `<TableRow class="bg-slate-50 dark:bg-slate-900/40">` (+ the base
    // `hover:bg-muted/50`).
    final header = _Hover(
      cursor: MouseCursor.defer,
      builder: (h) => Container(
        decoration: BoxDecoration(
          color: h ? muted.withValues(alpha: 0.5) : (dark ? Tw.slate900.withValues(alpha: 0.4) : Tw.slate50),
          border: Border(bottom: BorderSide(color: border)),
        ),
        child: row([
          Row(
            children: [
              Icon(BootstrapIcons.journal_text, size: _kTableIconSize, color: context.colors.primary),
              const SizedBox(width: 8),
              Flexible(child: Text('Curriculum Name', style: headerStyle)),
            ],
          ),
          Text('Status', style: headerStyle),
          Text('Actions', style: headerStyle),
        ], padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
      ),
    );

    // `[&_tr:last-child]:border-0`
    BoxDecoration rowBorder(bool last) => BoxDecoration(
      border: last ? null : Border(bottom: BorderSide(color: border)),
    );

    final body = <Widget>[];
    if (_isListLoading) {
      for (var n = 0; n < 6; n++) {
        body.add(
          Container(
            decoration: rowBorder(n == 5),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: const Skeleton(height: 20, radius: 14),
          ),
        );
      }
    } else if (cs.curriculums.isNotEmpty) {
      for (var i = 0; i < cs.curriculums.length; i++) {
        final curriculum = cs.curriculums[i];
        final last = i == cs.curriculums.length - 1;
        body.add(
          _Hover(
            cursor: MouseCursor.defer,
            builder: (h) => AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              decoration: rowBorder(last).copyWith(
                color: h ? (dark ? Tw.slate900.withValues(alpha: 0.2) : Tw.slate50.withValues(alpha: 0.7)) : null,
              ),
              child: row([
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: context.colors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        BootstrapIcons.journal_bookmark,
                        size: _kTableIconSize,
                        color: context.colors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        vText(curriculum['name']),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: dark ? Tw.slate200 : Tw.slate800,
                        ),
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusPill(
                    status: curriculum['status'],
                    label: statusLabel(curriculum['status']),
                    kind: _PillKind.table,
                    onTap: () => _fire(() => _handleCurriculumStatusChange(curriculum)),
                    trailing: Opacity(
                      opacity: 0.7,
                      child: Icon(
                        BootstrapIcons.pencil,
                        size: _kTableIconSize,
                        color: _pillColors(curriculum['status'], _PillKind.table, dark).$2,
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    _IconAction(
                      icon: BootstrapIcons.pencil_square,
                      iconSize: _kTableIconSize,
                      color: Tw.emerald600,
                      hoverBg: dark ? Tw.emerald500.withValues(alpha: 0.1) : Tw.emerald50,
                      tooltip: 'Edit',
                      onTap: () => _fire(() => _openUpdateCurriculum(curriculum['id'])),
                    ),
                    const SizedBox(width: 8),
                    _IconAction(
                      icon: BootstrapIcons.trash3_fill,
                      iconSize: _kTableIconSize,
                      color: Tw.rose600,
                      hoverBg: dark ? Tw.rose500.withValues(alpha: 0.1) : Tw.rose50,
                      tooltip: 'Delete',
                      onTap: () => _openDeleteDialog(curriculum),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        );
      }
    } else {
      body.add(
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 8),
          child: Column(
            children: [
              Icon(BootstrapIcons.inbox, size: _kTableIconSize, color: Tw.slate300),
              SizedBox(height: 8),
              Text('No curriculums found.', style: TextStyle(fontSize: 14, color: Tw.slate400)),
            ],
          ),
        ),
      );
    }

    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? Tw.slate800 : Tw.slate100),
        boxShadow: _CC.shadowSm,
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth.isFinite && c.maxWidth > 520 ? c.maxWidth : 520.0;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [header, ...body],
              ),
            ),
          );
        },
      ),
    );
  }
}
