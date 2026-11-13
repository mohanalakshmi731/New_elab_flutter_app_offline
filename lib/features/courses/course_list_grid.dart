part of 'course_list_view.dart';

/// Course tab: header, filters, the collapsed card grid and (when a course
/// is open) the expanded panel.
extension _GridUi on _CourseListViewState {
  Widget _buildCourseTab(CoursesState cs, String role) {
    final sm = context.isSm;
    final lg = context.isLg;
    final dark = context.isDark;
    final expanded = _expandedCourse != null;
    final filtered = _filteredCourses;

    // `<Card class="p-1 overflow-hidden">` (`border-0 shadow-none
    // bg-transparent` once a course is open — still rounded and clipping).
    final card = Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: expanded ? null : (dark ? AppColors.darkCard : AppColors.card),
        borderRadius: BorderRadius.circular(20),
        border: expanded ? null : Border.all(color: dark ? AppColors.darkBorder : AppColors.border),
        boxShadow: expanded ? null : _CC.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No courses available.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, height: 1.5, color: Tw.gray500),
              ),
            )
          else if (!expanded)
            _buildCourseGrid(filtered),
          if (expanded)
            // `<Transition enter-from-class="opacity-0 scale-95"
            // enter-active-class="transition-all duration-300 ease-out">`
            TweenAnimationBuilder<double>(
              key: ValueKey(_expandedCourse),
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              builder: (context, t, child) => Opacity(
                opacity: t,
                child: Transform.scale(scale: 0.95 + 0.05 * t, child: child),
              ),
              child: _buildExpandedPanel(cs, role),
            ),
        ],
      ),
    );

    return Padding(
      // `px-0 sm:px-6 lg:px-10`
      padding: EdgeInsets.symmetric(horizontal: lg ? 40 : (sm ? 24 : 0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!expanded) ...[
            _buildCourseHeader(role),
            const SizedBox(height: 24),
            _buildCourseFilters(cs),
            const SizedBox(height: 24),
          ],
          card,
        ],
      ),
    );
  }

  /// "Courses & Subjects" + Create Course.
  Widget _buildCourseHeader(String role) {
    final sm = context.isSm;
    final dark = context.isDark;
    // `text-xl sm:text-2xl font-bold tracking-tight`
    final size = sm ? 24.0 : 20.0;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Courses & Subjects',
          style: TextStyle(
            fontSize: size,
            height: (sm ? 32 : 28) / size,
            fontWeight: FontWeight.w700,
            letterSpacing: size * -0.025,
            color: dark ? Colors.white : Tw.slate800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Manage and organise your course library',
          style: TextStyle(fontSize: 14, height: 20 / 14, color: dark ? Tw.slate400 : Tw.slate500),
        ),
      ],
    );
    // `<Button class="rounded-xl shadow-sm gap-1.5 w-full sm:w-auto">`
    final create = role != Role.instructor
        ? _RoundedButton(
            leading: const Icon(BootstrapIcons.plus_circle),
            label: 'Create Course',
            gap: 6,
            shadow: _CC.shadowSm,
            onPressed: _createCourse,
          )
        : null;
    if (sm) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(child: title),
          ?create,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(alignment: Alignment.centerLeft, child: title),
        if (create != null) ...[const SizedBox(height: 12), create],
      ],
    );
  }

  /// Curriculum filter menu, status select and the course search.
  Widget _buildCourseFilters(CoursesState cs) {
    final sm = context.isSm;
    final dark = context.isDark;
    final published = [
      for (final c in cs.curriculums)
        if (c['status'] == 'published') c,
    ];

    // `<Button variant="outline" class="rounded-xl gap-2 shadow-sm flex-1
    // sm:flex-none">` + `<DropdownMenuContent class="w-60">`
    final curriculumMenu = _Dropdown(
      width: 240,
      items: [
        _menuItem(
          icon: BootstrapIcons.grid,
          onPressed: () => _fire(() => _onCurriculumSelect(null)),
          child: const Text('Show All Courses'),
        ),
        _menuSeparator(),
        _menuLabel('Filter by Curriculum'),
        _menuSeparator(),
        for (final curriculum in published)
          _menuItem(
            icon: BootstrapIcons.journal_text,
            iconColor: context.colors.primary,
            onPressed: () => _fire(() => _onCurriculumSelect(curriculum)),
            child: Text(vText(curriculum['name'])),
          ),
      ],
      trigger: (toggle, _) => _OutlineTrigger(
        onTap: toggle,
        leading: const Icon(BootstrapIcons.funnel, size: 14),
        text: _selectedCurriculum.isNotEmpty ? _selectedCurriculum : 'Curriculum',
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
        maxTextWidth: 140,
        chevronSize: 14,
        shadow: _CC.shadowSm,
        center: !sm,
      ),
    );

    // `<SelectTrigger class="w-auto flex-1 sm:flex-none rounded-xl shadow-sm
    // bg-white dark:bg-card gap-2"><i class="bi bi-sliders" />`
    const statuses = [
      ('all', 'All Statuses'),
      ('published', 'Published'),
      ('draft', 'UnPublished'),
      ('archived', 'Archived'),
    ];
    final statusLabelText = statuses.firstWhere((e) => e.$1 == _statuscourse, orElse: () => statuses.first).$2;
    final statusSelect = LayoutBuilder(
      builder: (context, c) {
        final menuWidth = sm ? 160.0 : c.maxWidth;
        return _Dropdown(
          width: menuWidth,
          items: [
            for (final (value, label) in statuses)
              _menuItem(
                select: true,
                selected: _statuscourse == value,
                onPressed: () => _set(() => _statuscourse = value),
                child: Text(label),
              ),
          ],
          trigger: (toggle, _) => _OutlineTrigger(
            onTap: toggle,
            button: false,
            spaceBetween: !sm,
            leading: const Icon(BootstrapIcons.sliders, size: 14),
            text: statusLabelText,
            background: dark ? AppColors.darkCard : Colors.white,
            shadow: _CC.shadowSm,
          ),
        );
      },
    );

    // `<input class="w-full sm:w-64 pl-9 pr-4 py-2.5 … rounded-xl">` +
    // `bi-search absolute left-3 text-sm`.
    final searchField = _WebInput(
      controller: _searchQueryCourse,
      hint: 'Search courses...',
      prefixIcon: BootstrapIcons.search,
      prefixIconSize: 14,
      padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
      onSubmitted: (_) => _fire(_searchCourseByName),
    );
    final search = Row(
      mainAxisSize: sm ? MainAxisSize.min : MainAxisSize.max,
      children: [
        if (sm) SizedBox(width: 256, child: searchField) else Expanded(child: searchField),
        const SizedBox(width: 8),
        _RoundedButton(label: 'Search', shadow: _CC.shadowSm, onPressed: () => _fire(_searchCourseByName)),
      ],
    );

    if (sm) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [curriculumMenu, statusSelect],
            ),
          ),
          const SizedBox(width: 12),
          search,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: curriculumMenu),
            const SizedBox(width: 8),
            Expanded(child: statusSelect),
          ],
        ),
        const SizedBox(height: 12),
        search,
      ],
    );
  }

  /// `grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4`
  Widget _buildCourseGrid(List<Map<String, dynamic>> courses) {
    final sm = context.isSm;
    final cols = context.isLg ? 4 : (context.isMd ? 3 : (sm ? 2 : 1));
    final gap = sm ? 24.0 : 16.0;
    final rows = <Widget>[];
    for (var start = 0; start < courses.length; start += cols) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < cols; i++) ...[
                if (i > 0) SizedBox(width: gap),
                Expanded(
                  child: start + i < courses.length
                      ? _buildCourseCard(courses[start + i], start + i)
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.all(sm ? 16 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < rows.length; i++) ...[if (i > 0) SizedBox(height: gap), rows[i]],
        ],
      ),
    );
  }

  /// One collapsed course card (`handleCardClick`).
  Widget _buildCourseCard(Map<String, dynamic> course, int idx) {
    final dark = context.isDark;
    final sm = context.isSm;
    final image = jsTruthy(course['image'])
        ? '${course['image']}'
        : (jsTruthy(course['attach']) ? '${course['attach']}' : null);
    return _Hover(
      onTap: () => _openCourse(course, idx),
      // `rounded-2xl shadow-sm hover:shadow-xl transition-all duration-300`
      builder: (h) => AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkCard : AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dark ? Tw.slate800 : Tw.slate100),
          boxShadow: h ? _CC.shadowXl : _CC.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: dark ? const [Tw.slate800, Tw.slate900] : const [Tw.slate100, Tw.slate200],
                      ),
                    ),
                  ),
                  if (image != null)
                    AnimatedScale(
                      scale: h ? 1.05 : 1,
                      duration: const Duration(milliseconds: 500),
                      child: Image.network(
                        image,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox.shrink(),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    left: 8,
                    child: _StatusPill(
                      status: course['status'],
                      label: statusLabel(course['status'], draftLabel: 'Draft'),
                      kind: _PillKind.thumbnail,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: sm ? 16 : 12, vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          vText(course['title']),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w600,
                            color: dark ? Tw.slate100 : Tw.slate800,
                          ),
                        ),
                        if (jsTruthy(course['course_code']))
                          Text(
                            '${course['course_code']}',
                            style: TextStyle(fontSize: 12, height: 16 / 12, color: dark ? Tw.slate500 : Tw.slate400),
                          ),
                      ],
                    ),
                  ),
                  // `justify-between gap-2` + the actions' `ml-2`.
                  const SizedBox(width: 16),
                  _IconAction(
                    icon: BootstrapIcons.pencil_square,
                    color: dark ? Tw.slate400 : Tw.slate500,
                    hoverColor: dark ? Colors.white : Tw.slate800,
                    hoverBg: dark ? Tw.slate800 : Tw.slate100,
                    tooltip: 'Edit Course',
                    onTap: () => _fire(() => _openUpdateCourseDialog(course['id'])),
                  ),
                  const SizedBox(width: 4),
                  _IconAction(
                    icon: BootstrapIcons.trash3_fill,
                    color: dark ? _CC.rose400 : Tw.rose500,
                    hoverBg: dark ? Tw.rose500.withValues(alpha: 0.1) : Tw.rose50,
                    tooltip: 'Delete Course',
                    onTap: () => _openDeleteCourseDialog(course),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
