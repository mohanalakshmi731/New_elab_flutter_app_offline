part of 'course_list_view.dart';

/// The expanded course panel: header bar (title, status, Overview / Manage /
/// Preview triggers, Back) and the Overview tab.
extension _ExpandedUi on _CourseListViewState {
  /// `activeTabs[expandedIndex]` (`default-value="overview"`).
  String get _courseTab => _activeTabs[_expandedIndex] ?? 'overview';

  Widget _buildExpandedPanel(CoursesState cs, String role) {
    final sm = context.isSm;
    final dark = context.isDark;
    final tab = _courseTab;
    return Container(
      padding: EdgeInsets.all(sm ? 24 : 12),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkPrimaryForeground : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _CC.shadowLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildExpandedHeader(role),
          if (tab == 'overview') _buildOverviewTab(cs),
          if (tab == 'outline') _buildOutlineTab(cs),
          if (tab == 'preview') _buildPreviewTab(),
        ],
      ),
    );
  }

  Widget _buildExpandedHeader(String role) {
    final sm = context.isSm;
    final lg = context.isLg;
    final dark = context.isDark;
    final primary = context.colors.primary;
    final course = _selectedCourse ?? const <String, dynamic>{};
    final status = course['status'];

    final left = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: sm ? 48 : 40,
          height: sm ? 48 : 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(16)),
          child: Icon(BootstrapIcons.journal_bookmark_fill, size: sm ? 24 : 20, color: primary),
        ),
        SizedBox(width: sm ? 16 : 12),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    vText(course['title']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: sm ? 24 : 18,
                      height: (sm ? 32 : 28) / (sm ? 24 : 18),
                      fontWeight: FontWeight.w700,
                      color: dark ? Colors.white : Tw.slate900,
                    ),
                  ),
                  _StatusPill(status: status, label: statusLabel(status), kind: _PillKind.header),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Course Administration & Curriculum Management',
                style: TextStyle(
                  fontSize: sm ? 14 : 12,
                  height: sm ? 20 / 14 : 16 / 12,
                  color: dark ? Tw.slate400 : Tw.slate500,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final triggers = role != Role.student ? _buildCourseTabsList() : null;

    // `px-4 py-2 border rounded-xl hover:bg-slate-50 … shadow-sm hover:shadow
    // w-full lg:w-auto justify-center`
    final back = _Hover(
      onTap: () => _set(() => _setExpandedCourse(null)),
      builder: (h) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: h ? (dark ? Tw.slate900 : Tw.slate50) : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dark ? Tw.slate800 : Tw.slate200),
          boxShadow: _CC.shadowSm,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              BootstrapIcons.arrow_left,
              size: 18,
              color: h ? (dark ? Colors.white : Tw.slate900) : (dark ? Tw.slate400 : Tw.slate600),
            ),
            const SizedBox(width: 8),
            Text(
              'Back to Courses',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: h ? (dark ? Colors.white : Tw.slate900) : (dark ? Tw.slate400 : Tw.slate600),
              ),
            ),
          ],
        ),
      ),
    );

    final body = lg
        ? Row(
            children: [
              Flexible(child: left),
              if (triggers != null)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Center(child: triggers),
                  ),
                )
              else
                const Spacer(),
              back,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(alignment: Alignment.centerLeft, child: left),
              // `flex-col items-start`: the TabsList keeps its own width.
              if (triggers != null) ...[
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerLeft, child: triggers),
              ],
              const SizedBox(height: 16),
              back,
            ],
          );

    return Container(
      margin: EdgeInsets.only(bottom: sm ? 24 : 16),
      padding: EdgeInsets.only(bottom: sm ? 24 : 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dark ? Tw.slate800 : Tw.slate100)),
      ),
      child: body,
    );
  }

  /// `<TabsList class="flex gap-2 p-1 bg-slate-100/80 rounded-2xl border …">`
  /// with Overview / Manage / Preview. The triggers are `flex-1`, so they
  /// share the list's width equally.
  Widget _buildCourseTabsList() {
    final sm = context.isSm;
    final dark = context.isDark;
    final current = _courseTab;

    Widget trigger(String value, String label) {
      final active = current == value;
      // `text-foreground dark:text-muted-foreground`,
      // `dark:data-[state=active]:text-foreground`
      final fg = dark ? (active ? AppColors.darkForeground : AppColors.darkMutedForeground) : AppColors.foreground;
      return Expanded(
        child: _Hover(
          onTap: () {
            _set(() => _activeTabs[_expandedIndex] = value);
            if (value == 'preview') _fire(() => _onPreviewTabClick(_selectedCourse?['id'], _expandedIndex));
          },
          builder: (_) => AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(horizontal: sm ? 24 : 12, vertical: 8),
            decoration: BoxDecoration(
              // `data-[state=active]:bg-background dark:data-[state=active]:bg-secondary`
              color: active ? (dark ? AppColors.secondary : AppColors.background) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              // `border border-transparent dark:data-[state=active]:border-input`
              border: Border.all(color: active && dark ? AppColors.darkInput : Colors.transparent),
              boxShadow: active ? _CC.shadowSm : null,
            ),
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(
                fontSize: sm ? 14 : 12,
                height: sm ? 20 / 14 : 16 / 12,
                fontWeight: FontWeight.w500,
                color: fg,
              ),
            ),
          ),
        ),
      );
    }

    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: dark ? Tw.slate900.withValues(alpha: 0.8) : Tw.slate100.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.05) : Tw.slate200.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            trigger('overview', 'Overview'),
            const SizedBox(width: 8),
            trigger('outline', 'Manage'),
            const SizedBox(width: 8),
            trigger('preview', 'Preview'),
          ],
        ),
      ),
    );
  }

  // ── Overview tab ──────────────────────────────────────────────────────

  Widget _buildOverviewTab(CoursesState cs) {
    final sm = context.isSm;
    final md = context.isMd;
    final lg = context.isLg;
    final dark = context.isDark;
    final course = _selectedCourse ?? const <String, dynamic>{};
    final details = _selectedCourseDetails;

    Widget field(String label, Widget child) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // `<Label class="text-sm font-semibold … mb-2">` (`leading-none`)
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            height: 1,
            fontWeight: FontWeight.w600,
            color: dark ? Tw.slate300 : Tw.slate700,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );

    final instructorField = field(
      'Course Instructor',
      _DisabledBox(
        text: orBlank(details?['createdInstructorName']).isNotEmpty ? '${details!['createdInstructorName']}' : 'N/A',
      ),
    );

    final cols = lg ? 3 : (sm ? 2 : 1);
    final topGrid = _Grid(
      columns: cols,
      gap: sm ? 24 : 16,
      children: [
        field('Course Title', _DisabledBox(text: vText(course['title']))),
        field('Status', _DisabledBox(text: statusLabel(course['status']), chevron: true)),
        if (cols == 2) _Span(child: instructorField) else instructorField,
      ],
    );

    final curriculumCard = _buildAttachedCurriculumsCard(cs, details);
    final instructorCard = _buildAttachedInstructorsCard(cs, details);

    return Padding(
      // `px-0 sm:px-4 md:px-6 lg:px-10`
      padding: EdgeInsets.symmetric(horizontal: lg ? 40 : (md ? 24 : (sm ? 16 : 0))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          topGrid,
          SizedBox(height: sm ? 32 : 24),
          if (lg)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: curriculumCard),
                SizedBox(width: sm ? 32 : 16),
                Expanded(child: instructorCard),
              ],
            )
          else ...[
            curriculumCard,
            SizedBox(height: sm ? 32 : 16),
            instructorCard,
          ],
        ],
      ),
    );
  }

  /// `bg-slate-50/50 dark:bg-slate-800/30 … rounded-2xl p-4 sm:p-5` card with
  /// the attach form and the scrollable list.
  Widget _manageCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required int count,
    required Widget picker,
    required bool loading,
    required VoidCallback onAttach,
    required List<Widget> items,
    required Widget empty,
  }) {
    final sm = context.isSm;
    final dark = context.isDark;
    // `<Button class="rounded-xl shadow px-5 shrink-0">`
    final attach = _SubmitButton(
      loading: loading,
      label: 'Attach',
      hPad: 20,
      shadow: _CC.shadowSm,
      onPressed: onAttach,
    );
    return Container(
      padding: EdgeInsets.all(sm ? 20 : 16),
      decoration: BoxDecoration(
        color: dark ? Tw.slate800.withValues(alpha: 0.3) : Tw.slate50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Tw.slate800.withValues(alpha: 0.5) : Tw.slate100.withValues(alpha: 0.8)),
        boxShadow: _CC.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Icon(icon, size: 16, color: iconColor),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                  color: dark ? Tw.slate200 : Tw.slate800,
                ),
              ),
              _CountBadge(
                count,
                bold: false,
                fontSize: 12,
                bg: dark ? Tw.slate800 : Tw.slate100,
                fg: dark ? Tw.slate400 : Tw.slate500,
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (sm)
            Row(
              children: [
                Expanded(child: picker),
                const SizedBox(width: 12),
                attach,
              ],
            )
          else ...[
            picker,
            const SizedBox(height: 12),
            attach,
          ],
          const SizedBox(height: 20),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 240),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(right: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: items.isEmpty
                    ? [empty]
                    : [
                        for (var i = 0; i < items.length; i++) ...[if (i > 0) const SizedBox(height: 12), items[i]],
                      ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// `text-center py-6 text-slate-400 border border-dashed border-slate-200
  /// dark:border-slate-800 rounded-xl` "nothing attached" box.
  Widget _emptyAttached(IconData icon, String text) {
    final dark = context.isDark;
    return _DashedBox(
      color: dark ? Tw.slate800 : Tw.slate200,
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(icon, size: 20, color: Tw.slate300),
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

  /// Picker trigger of the attach forms: an outline `Button` with
  /// `flex-1 justify-between font-normal bg-white dark:bg-card
  /// border-slate-200 dark:border-slate-800 rounded-xl shadow-none` and a
  /// `ChevronDown` with `h-4 w-4 opacity-50 ml-2`.
  Widget _attachTrigger(VoidCallback toggle, String text) => _OutlineTrigger(
    onTap: toggle,
    text: text,
    spaceBetween: true,
    background: context.isDark ? AppColors.darkCard : Colors.white,
    borderColor: context.isDark ? Tw.slate800 : Tw.slate200,
    shadow: const [],
    chevronGap: 16,
  );

  /// Item card of the attached lists (`bg-white dark:bg-card border …
  /// rounded-xl shadow-sm hover:shadow` — `shadow` equals `shadow-sm` here).
  Widget _attachedItem({required Widget child, double padding = 14}) {
    final dark = context.isDark;
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate100),
        boxShadow: _CC.shadowSm,
      ),
      child: child,
    );
  }

  Widget _buildAttachedCurriculumsCard(CoursesState cs, Map<String, dynamic>? details) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final course = _selectedCourse;
    final curriculums = [for (final c in asList(details?['curriculums'])) ?asMap(c)];
    final published = [
      for (final c in cs.curriculums)
        if (c['status'] == 'published') c,
    ];
    final selectedName = orBlank(course?['selectedCourseCurriculumName']);

    return _manageCard(
      icon: BootstrapIcons.journal_text,
      iconColor: primary,
      title: 'Attached Curriculums',
      count: curriculums.length,
      loading: _isAttachCurriculLoad,
      onAttach: () {
        if (course != null) _fire(() => _attachCurriculum(course));
      },
      picker: _Dropdown(
        width: 288,
        items: [
          _menuLabel('Select Curriculum'),
          _menuSeparator(),
          for (final c in published) _menuItem(onPressed: () => _curriculumSelected(c), child: Text(vText(c['name']))),
        ],
        trigger: (toggle, _) =>
            _attachTrigger(toggle, selectedName.isNotEmpty ? selectedName : 'Select Curriculum to attach'),
      ),
      empty: _emptyAttached(BootstrapIcons.inbox, 'No curriculum attached to this course.'),
      items: [
        for (final c in curriculums)
          _attachedItem(
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(BootstrapIcons.file_text_fill, size: 14, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    vText(c['name']),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: dark ? Tw.slate200 : Tw.slate800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _IconAction(
                  icon: BootstrapIcons.trash,
                  iconSize: 14,
                  radius: 999,
                  color: dark ? _CC.rose400 : Tw.rose600,
                  bg: dark ? Tw.rose500.withValues(alpha: 0.1) : Tw.rose50,
                  hoverBg: dark ? Tw.rose500.withValues(alpha: 0.2) : _CC.rose100,
                  tooltip: 'Detach Curriculum',
                  onTap: () => _openDeleteCurriculumDialog(course, c),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildAttachedInstructorsCard(CoursesState cs, Map<String, dynamic>? details) {
    final sm = context.isSm;
    final dark = context.isDark;
    final course = _selectedCourse;
    final instructors = [for (final i in asList(details?['instructors'])) ?asMap(i)];
    final selectedName = orBlank(course?['selectedInstructorName']);

    Widget actions(Map<String, dynamic> instructor) {
      final user = asMap(instructor['user']);
      final email = user?['email'];
      final phone = user?['phone'];
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (jsTruthy(email)) ...[
            _IconAction(
              icon: BootstrapIcons.envelope,
              iconSize: 14,
              radius: 999,
              color: dark ? Tw.orange400 : Tw.orange600,
              bg: dark ? _CC.orange950.withValues(alpha: 0.2) : _CC.orange50,
              hoverBg: dark ? _CC.orange950.withValues(alpha: 0.4) : _CC.orange100,
              tooltip: 'Email Instructor',
              onTap: () => _fire(() async => openExternal('mailto:$email')),
            ),
            const SizedBox(width: 8),
          ],
          if (jsTruthy(phone)) ...[
            _IconAction(
              icon: BootstrapIcons.telephone,
              iconSize: 14,
              radius: 999,
              color: dark ? _CC.sky400 : _CC.sky600,
              bg: dark ? _CC.sky950.withValues(alpha: 0.2) : Tw.sky50,
              hoverBg: dark ? _CC.sky950.withValues(alpha: 0.4) : Tw.sky100,
              tooltip: 'Call Instructor',
              onTap: () => _fire(() async => openExternal('tel:$phone')),
            ),
            const SizedBox(width: 8),
          ],
          _IconAction(
            icon: BootstrapIcons.trash,
            iconSize: 14,
            radius: 999,
            color: dark ? _CC.rose400 : Tw.rose600,
            bg: dark ? Tw.rose500.withValues(alpha: 0.1) : Tw.rose50,
            hoverBg: dark ? Tw.rose500.withValues(alpha: 0.2) : _CC.rose100,
            tooltip: 'Detach Instructor',
            onTap: () => _openDeleteInstructorDialog(instructor),
          ),
        ],
      );
    }

    Widget who(Map<String, dynamic> instructor) {
      final email = asMap(instructor['user'])?['email'];
      return Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: dark ? Tw.blue500.withValues(alpha: 0.1) : Tw.blue100,
              shape: BoxShape.circle,
            ),
            child: Text(
              instructorInitials(instructor),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: dark ? Tw.blue400 : Tw.blue600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  instructorFullName(instructor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: dark ? Tw.slate200 : Tw.slate800),
                ),
                if (jsTruthy(email))
                  Text(
                    '$email',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: dark ? Tw.slate500 : Tw.slate400),
                  ),
              ],
            ),
          ),
        ],
      );
    }

    return _manageCard(
      icon: BootstrapIcons.people,
      iconColor: Tw.blue500,
      title: 'Attached Instructors',
      count: instructors.length,
      loading: _isAttachINSLoad,
      onAttach: () {
        if (course != null) _fire(() => _attachInstructor(course));
      },
      picker: _Dropdown(
        width: 288,
        items: [
          _menuLabel('Select Instructor'),
          _menuSeparator(),
          for (final inst in cs.instructors)
            _menuItem(
              onPressed: () => _selectInstructorForCourse(course, inst),
              child: Text(instructorDisplayName(inst)),
            ),
        ],
        trigger: (toggle, _) =>
            _attachTrigger(toggle, selectedName.isNotEmpty ? selectedName : 'Select Instructor to attach'),
      ),
      empty: _emptyAttached(BootstrapIcons.people, 'No instructors attached to this course.'),
      items: [
        for (final instructor in instructors)
          _attachedItem(
            padding: 12,
            child: sm
                ? Row(
                    children: [
                      Expanded(child: who(instructor)),
                      const SizedBox(width: 8),
                      actions(instructor),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      who(instructor),
                      const SizedBox(height: 8),
                      Align(alignment: Alignment.centerRight, child: actions(instructor)),
                    ],
                  ),
          ),
      ],
    );
  }
}
