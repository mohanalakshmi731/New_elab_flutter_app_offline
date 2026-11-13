part of 'class_course_create_page.dart';

/// The expanded course (`AccordionContent`, `bg-white
/// dark:bg-primary-foreground border rounded-2xl p-4 sm:p-6 shadow-md`,
/// `text-sm`): header bar with the tab switcher and "Back to Courses", then
/// the tab.
///
/// The `<Tabs>` root is `flex flex-col gap-2`, and besides the header and the
/// active tab it holds an empty `<div v-if="canManage">` (the detach-instructor
/// dialog's wrapper) between the Overview and Manage contents — so the gap
/// above the tab is the header's `mb-4 sm:mb-6` plus one or two `gap-2`, and
/// Overview gets one more `gap-2` below it.
class _CourseDetail extends StatelessWidget {
  const _CourseDetail({required this.s, required this.course, required this.idx});
  final _ClassCourseCreatePageState s;
  final Map<String, dynamic> course;
  final int idx;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final manage = s._canManage;
    final tab = s._activeTabs[idx] ?? (manage ? 'overview' : 'preview');

    final Widget tabBody = switch (tab) {
      'overview' => _OverviewTab(s: s, course: course),
      'outline' => _OutlineTab(s: s, course: course),
      _ => _PreviewTab(s: s),
    };
    final gapsAbove = !manage || tab == 'overview' ? 8.0 : 16.0;
    final gapBelow = manage && tab == 'overview' ? 8.0 : 0.0;

    return Container(
      padding: EdgeInsets.all(sm ? 24 : 16),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkPrimaryForeground : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate200),
        boxShadow: _shadowMd,
      ),
      child: DefaultTextStyle.merge(
        style: const TextStyle(fontSize: 14, height: 20 / 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _DetailHeader(s: s, course: course, idx: idx, tab: tab),
            SizedBox(height: (sm ? 24 : 16) + gapsAbove),
            tabBody,
            if (gapBelow > 0) SizedBox(height: gapBelow),
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({required this.s, required this.course, required this.idx, required this.tab});
  final _ClassCourseCreatePageState s;
  final Map<String, dynamic> course;
  final int idx;
  final String tab;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final lg = context.isLg;
    final published = course['status'] == 'published';
    final primary = context.colors.primary;

    // Draft: `bg-slate-50 text-slate-700 border-slate-205 dark:bg-slate-850
    // dark:text-slate-400 dark:border-slate-800` — slate-205/850 don't exist,
    // so the border falls back to `--border` and the light background stays
    // in dark mode.
    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: published ? (dark ? Tw.emerald500.withValues(alpha: 0.1) : Tw.emerald50) : Tw.slate50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: published
              ? (dark ? Tw.emerald500.withValues(alpha: 0.2) : Tw.emerald200)
              : (dark ? Tw.slate800 : AppColors.border),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(shape: BoxShape.circle, color: published ? Tw.emerald500 : Tw.slate400),
          ),
          const SizedBox(width: 6),
          Text(
            published ? 'Active' : 'Draft',
            style: TextStyle(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w600,
              color: published ? (dark ? Tw.emerald400 : Tw.emerald700) : (dark ? Tw.slate400 : Tw.slate700),
            ),
          ),
        ],
      ),
    );

    final titleBlock = Row(
      mainAxisSize: lg ? MainAxisSize.min : MainAxisSize.max,
      children: [
        Container(
          width: sm ? 48 : 40,
          height: sm ? 48 : 40,
          decoration: BoxDecoration(
            color: primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
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
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${course['title'] ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: sm ? 24 : 18,
                      height: sm ? 32 / 24 : 28 / 18,
                      fontWeight: FontWeight.w700,
                      color: dark ? Colors.white : Tw.slate900,
                    ),
                  ),
                  pill,
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

    final tabs = _TabSwitcher(
      value: tab,
      expand: !lg,
      tabs: [
        if (s._canManage) const ('overview', 'Overview'),
        if (s._canManage) const ('outline', 'Manage'),
        const ('preview', 'Preview'),
      ],
      onChanged: (v) {
        if (v == 'preview') {
          s._onPreviewTabClick(course['id'], idx);
        } else {
          s._set(() => s._activeTabs[idx] = v);
        }
      },
    );

    final back = _BackButton(onTap: () => s._set(() => s._setExpandedCourse('')), expand: !lg);

    final divider = Border(bottom: BorderSide(color: dark ? Tw.slate800 : Tw.slate100));
    if (lg) {
      return Container(
        padding: const EdgeInsets.only(bottom: 24),
        decoration: BoxDecoration(border: divider),
        child: Row(
          children: [
            Expanded(child: Align(alignment: Alignment.centerLeft, child: titleBlock)),
            const SizedBox(width: 16),
            tabs,
            const SizedBox(width: 16),
            back,
          ],
        ),
      );
    }
    return Container(
      padding: EdgeInsets.only(bottom: sm ? 24 : 16),
      decoration: BoxDecoration(border: divider),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [titleBlock, const SizedBox(height: 16), tabs, const SizedBox(height: 16), back],
      ),
    );
  }
}

/// `TabsList` (`flex w-full lg:w-auto gap-2 p-1 bg-slate-100
/// dark:bg-slate-950 rounded-xl`; the shadcn `h-9` stays, so the list is 36px
/// tall and each `px-5 py-3 rounded-lg` trigger only 27px).
class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.value, required this.tabs, required this.onChanged, required this.expand});
  final String value;
  final List<(String, String)> tabs;
  final ValueChanged<String> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    Widget trigger(String v, String label) {
      final active = v == value;
      // The Preview trigger's `data-[state=active]:text-white` wins over
      // `text-primary` (tailwind-merge), and it has no `dark:` text override,
      // so the base `dark:data-[state=active]:text-foreground` applies.
      final Color fg = active
          ? (v == 'preview'
              ? (dark ? AppColors.darkForeground : Colors.white)
              : (dark ? Colors.white : context.colors.primary))
          : (dark ? AppColors.darkMutedForeground : AppColors.foreground);
      final child = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            height: 27,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? (dark ? Tw.slate900 : Colors.white) : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              // `border border-transparent dark:data-[state=active]:border-input`
              border: Border.all(color: active && dark ? AppColors.darkInput : Colors.transparent),
              boxShadow: active ? _shadowSm : null,
            ),
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.visible,
              style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: fg),
            ),
          ),
        ),
      );
      return expand ? Expanded(child: child) : child;
    }

    return Container(
      height: 36,
      padding: const EdgeInsets.all(4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark ? Tw.slate950 : Tw.slate100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            trigger(tabs[i].$1, tabs[i].$2),
          ],
        ],
      ),
    );
  }
}

/// `flex items-center gap-2 px-4 py-2 border border-slate-200
/// dark:border-slate-800 rounded-xl hover:bg-slate-50 dark:hover:bg-slate-900
/// text-slate-600 dark:text-slate-400 hover:text-slate-900
/// dark:hover:text-white text-sm font-medium shadow-sm justify-center` — the
/// `text-lg` arrow's 28px line box makes it 46px tall.
class _BackButton extends StatefulWidget {
  const _BackButton({required this.onTap, required this.expand});
  final VoidCallback onTap;
  final bool expand;

  @override
  State<_BackButton> createState() => _BackButtonState();
}

class _BackButtonState extends State<_BackButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final fg = _hover ? (dark ? Colors.white : Tw.slate900) : (dark ? Tw.slate400 : Tw.slate600);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: widget.expand ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _hover ? (dark ? Tw.slate900 : Tw.slate50) : null,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: dark ? Tw.slate800 : Tw.slate200),
            boxShadow: _shadowSm,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 28, child: Icon(BootstrapIcons.arrow_left, size: 18, color: fg)),
              const SizedBox(width: 8),
              Text('Back to Courses',
                  style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: fg)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Overview tab ───────────────────────────────────────────────────────────

/// `TabsContent value="overview"` (`px-2 sm:px-4 space-y-6`). Its children's
/// `mt-*` and the `space-y-6` bottom margins collapse: 32px above the attach
/// panels, 24px above the attached lists.
///
/// Several labels use `dark:text-slate-350`, which is not a Tailwind colour,
/// so they stay `text-slate-700` in dark mode, as on the web.
class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.s, required this.course});
  final _ClassCourseCreatePageState s;
  final Map<String, dynamic> course;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final details = s._selectedCourseDetails;
    final curriculums = mapsOf(details?['curriculums']);
    final instructors = mapsOf(details?['instructors']);
    final columns = context.isLg
        ? 3
        : context.isSm
            ? 2
            : 1;
    final threeCols = context.isMd
        ? 3
        : context.isSm
            ? 2
            : 1;
    final published = [for (final c in s._store.curriculums) if (c['status'] == 'published') c];
    final emptyBorder = dark ? Tw.slate800 : Tw.slate200;

    Widget sectionTitle(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Icon(icon, size: 14, color: context.colors.primary),
              const SizedBox(width: 8),
              Flexible(
                child: Text(text,
                    style: const TextStyle(
                        fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: Tw.slate700)),
              ),
            ],
          ),
        );

    Widget emptyBox(String text) => _DashedBox(
          color: emptyBorder,
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: Text(text,
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
          ),
        );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.isSm ? 16 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          _Grid(
            columns: columns,
            equalHeight: false,
            children: [
              _DisabledField(label: 'Course Title', text: '${course['title'] ?? ''}'),
              _DisabledField(label: 'Status', text: statusLabel(course['status']), select: true),
              _DisabledField(
                label: 'Course Instructor',
                text: jsTruthy(details?['createdInstructorName']) ? '${details!['createdInstructorName']}' : 'N/A',
              ),
            ],
          ),
          if (s._canManage) ...[
            const SizedBox(height: 32),
            _AttachPanel(
              title: 'Attach Curriculum',
              dropdown: _MenuDropdown(
                text: jsTruthy(course['selectedCourseCurriculumName'])
                    ? '${course['selectedCourseCurriculumName']}'
                    : 'Select Curriculum',
                header: 'Select Curriculum',
                items: [
                  for (final c in published)
                    (
                      '${c['name'] ?? ''}',
                      () => s._set(() {
                            course['selectedCourseCurriculumId'] = c['id'];
                            course['selectedCourseCurriculumName'] = c['name'];
                          }),
                    ),
                ],
              ),
              loading: s._isAttachCurriculLoad,
              onAttach: () => s._attachCurriculum(course),
            ),
            const SizedBox(height: 24),
            sectionTitle(BootstrapIcons.journal_bookmark_fill, 'Attached Curriculums (${curriculums.length})'),
            if (curriculums.isEmpty)
              emptyBox('No curriculum attached')
            else
              _Grid(
                columns: threeCols,
                gap: 12,
                children: [
                  for (final c in curriculums)
                    _AttachedTile(
                      leading: const Icon(BootstrapIcons.book, size: 14, color: Tw.slate400),
                      title: '${c['name'] ?? ''}',
                      actions: [
                        // `dark:text-rose-455` is not a Tailwind colour.
                        _RoundIconButton(
                          icon: BootstrapIcons.trash,
                          iconSize: 14,
                          tooltip: 'Detach Curriculum',
                          background: dark ? Tw.rose950.withValues(alpha: 0.3) : Tw.rose50,
                          hoverBackground: dark ? Tw.rose950.withValues(alpha: 0.5) : Tw.rose100,
                          foreground: Tw.rose600,
                          onTap: () => s._openDeleteCurriculumDialog(course, c),
                        ),
                      ],
                    ),
                ],
              ),
            const SizedBox(height: 32),
            _AttachPanel(
              title: 'Select Instructor',
              dropdown: _MenuDropdown(
                text: jsTruthy(course['selectedInstructorName'])
                    ? '${course['selectedInstructorName']}'
                    : 'Select Instructor',
                header: 'Select Instructor',
                items: [
                  for (final inst in s._store.instructors)
                    (instructorDisplayName(inst), () => s._selectInstructorForCourse(course, inst)),
                ],
              ),
              loading: s._isAttachINSLoad,
              onAttach: () => s._attachInstructor(course),
            ),
            const SizedBox(height: 24),
            sectionTitle(BootstrapIcons.people_fill, 'Attached Instructors (${instructors.length})'),
            if (instructors.isEmpty)
              emptyBox('No instructors attached')
            else
              _Grid(
                columns: threeCols,
                gap: 12,
                children: [for (final i in instructors) _InstructorTile(s: s, instructor: i)],
              ),
          ],
        ],
      ),
    );
  }
}

/// A disabled `<Input>` / `<Select>` of the Overview grid
/// (`bg-slate-50 dark:bg-slate-950 border-slate-200 dark:border-slate-800
/// rounded-xl text-slate-500 dark:text-slate-400 cursor-not-allowed`, h-9,
/// `shadow-xs`, `disabled:opacity-50`). The inputs' text is `text-base
/// md:text-sm`, the select's `text-sm` with the `opacity-50` chevron.
///
/// "Course Title" / "Course Instructor" use `<Label>` (`leading-none`),
/// "Status" a plain `<label>` (20px line).
class _DisabledField extends StatelessWidget {
  const _DisabledField({required this.label, required this.text, this.select = false});
  final String label;
  final String text;
  final bool select;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final fontSize = select || context.isMd ? 14.0 : 16.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 14, height: select ? 20 / 14 : 1, fontWeight: FontWeight.w500, color: Tw.slate700)),
        const SizedBox(height: 8),
        Opacity(
          opacity: 0.5,
          child: MouseRegion(
            cursor: SystemMouseCursors.forbidden,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: dark ? Tw.slate950 : Tw.slate50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: dark ? Tw.slate800 : Tw.slate200),
                boxShadow: _shadowXs,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: fontSize, color: dark ? Tw.slate400 : Tw.slate500)),
                  ),
                  if (select) ...[
                    const SizedBox(width: 8),
                    Opacity(
                      opacity: 0.5,
                      child: Icon(BootstrapIcons.chevron_down, size: 16, color: _mutedFg(context)),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// "Attach Curriculum" / "Select Instructor" panel (`flex flex-col mt-8
/// bg-white dark:bg-slate-900/60 p-5 rounded-2xl border border-slate-100
/// dark:border-slate-800/80 shadow-sm`): dropdown + Attach.
class _AttachPanel extends StatelessWidget {
  const _AttachPanel({required this.title, required this.dropdown, required this.loading, required this.onAttach});
  final String title;
  final Widget dropdown;
  final bool loading;
  final VoidCallback onAttach;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900.withValues(alpha: 0.6) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate100),
        boxShadow: _shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title,
              style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  color: dark ? Colors.white : Tw.slate800)),
          const SizedBox(height: 8),
          if (sm)
            Row(children: [
              SizedBox(width: 288, child: dropdown),
              const SizedBox(width: 12),
              _AttachButton(loading: loading, onPressed: onAttach),
            ])
          else ...[
            dropdown,
            const SizedBox(height: 12),
            _AttachButton(loading: loading, onPressed: onAttach, expand: true),
          ],
        ],
      ),
    );
  }
}

/// An attached curriculum / instructor card (`flex justify-between
/// items-center bg-white dark:bg-slate-950 border border-slate-150
/// dark:border-slate-800/80 rounded-xl px-4 py-3 shadow-sm`; slate-150 is not
/// a Tailwind colour, so the border is `--border`).
class _AttachedTile extends StatelessWidget {
  const _AttachedTile({required this.leading, required this.title, this.subtitle, required this.actions});
  final Widget leading;
  final String title;
  final String? subtitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: dark ? Tw.slate950 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? Tw.slate800.withValues(alpha: 0.8) : AppColors.border),
        boxShadow: _shadowSm,
      ),
      child: Row(
        children: [
          leading,
          SizedBox(width: subtitle == null ? 8 : 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        height: 20 / 14,
                        fontWeight: FontWeight.w600,
                        color: dark ? Tw.slate300 : Tw.slate700)),
                if (subtitle != null)
                  Text(subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400)),
              ],
            ),
          ),
          const SizedBox(width: 6),
          for (var i = 0; i < actions.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            actions[i],
          ],
        ],
      ),
    );
  }
}

/// Attached instructor: initial avatar, name + email, and the Gmail / Call /
/// Detach buttons. In dark mode the `dark:bg-*` classes beat the light
/// `hover:bg-*` ones, so the mail and call buttons don't change on hover.
class _InstructorTile extends StatelessWidget {
  const _InstructorTile({required this.s, required this.instructor});
  final _ClassCourseCreatePageState s;
  final Map<String, dynamic> instructor;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final user = asMap(instructor['user']);
    final first = user?['first_name'];
    final email = user?['email'];
    final primary = context.colors.primary;
    final initial = jsTruthy(first) ? '$first'.substring(0, 1) : 'I';
    String part(Object? v) => v == null ? '' : '$v';

    return _AttachedTile(
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(shape: BoxShape.circle, color: primary.withValues(alpha: 0.1)),
        alignment: Alignment.center,
        child: Text(initial, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primary)),
      ),
      title: '${part(first)} ${part(user?['last_name'])}',
      subtitle: part(email),
      actions: [
        // `text-orange-650` is not a Tailwind colour: the tile's foreground shows.
        _RoundIconButton(
          icon: BootstrapIcons.envelope_fill,
          tooltip: 'Compose email via Gmail',
          background: dark ? Tw.orange950.withValues(alpha: 0.2) : Tw.orange50,
          hoverBackground: dark ? null : Tw.orange100,
          foreground: dark ? Tw.orange400 : AppColors.foreground,
          onTap: () => openExternal('https://mail.google.com/mail/?view=cm&fs=1&to=${email ?? 'undefined'}'),
        ),
        _RoundIconButton(
          icon: BootstrapIcons.telephone_fill,
          tooltip: 'Call',
          background: dark ? Tw.blue950.withValues(alpha: 0.2) : Tw.blue50,
          hoverBackground: dark ? null : Tw.blue100,
          foreground: dark ? Tw.blue400 : Tw.blue600,
        ),
        _RoundIconButton(
          icon: BootstrapIcons.trash,
          tooltip: 'Detach Instructor',
          background: dark ? Tw.rose950.withValues(alpha: 0.3) : Tw.rose50,
          hoverBackground: dark ? Tw.rose950.withValues(alpha: 0.5) : Tw.rose100,
          foreground: Tw.rose600,
          onTap: () => s._openDeleteInstructorDialog(instructor),
        ),
      ],
    );
  }
}
