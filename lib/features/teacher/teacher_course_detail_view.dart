part of 'teacher_course_page.dart';

/// DETAIL VIEW — course header, tabs, Overview and Manage (outline) tabs and
/// their actions.
extension _DetailView on _TeacherCoursePageState {
  Widget _buildDetailView() {
    final dark = context.isDark;
    final course = _selectedCourse;
    final Widget tab = switch (_activeCourseTab) {
      'outline' => _manageTab(),
      'preview' => _previewTab(),
      _ => _overviewTab(),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (course != null) ...[
              SubjectIconBox(title: course['title'], size: 40),
              const SizedBox(width: 12),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${course?['title'] ?? ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: context.isSm ? 18 : 16,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                      color: dark ? Colors.white : Tw.slate900,
                    ),
                  ),
                  Text(
                    '${course?['short_name'] ?? ''} • ${course?['course_code'] ?? ''}',
                    style: const TextStyle(fontSize: 11, color: Tw.slate400),
                  ),
                ],
              ),
            ),
            if (!_canManage) const SizedBox(width: 12),
            if (!_canManage)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Tw.amber50,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Tw.amber200),
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(BootstrapIcons.eye, size: 11, color: Tw.amber600),
                  SizedBox(width: 4),
                  Text('View Only', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Tw.amber600)),
                ]),
              ),
          ],
        ),
        const SizedBox(height: 16),
        CourseTabs(
          value: _activeCourseTab,
          tabs: const [
            ('overview', BootstrapIcons.info_circle, 'Overview'),
            ('outline', BootstrapIcons.list_nested, 'Manage'),
            ('preview', BootstrapIcons.play_circle, 'Preview'),
          ],
          onTap: (v) {
            _set(() => _activeCourseTab = v);
            if (v == 'preview') _onPreviewTabClick();
          },
        ),
        // `mb-5` on the tab bar + the `<Tabs>` root's `gap-2`.
        const SizedBox(height: 28),
        tab,
      ],
    );
  }

  /// `bg-white dark:bg-slate-800 border … rounded-2xl p-4 sm:p-6`
  Widget _tabCard(Widget child) {
    final dark = context.isDark;
    return Container(
      padding: EdgeInsets.all(context.isSm ? 24 : 16),
      decoration: BoxDecoration(
        color: dark ? Tw.slate800 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Tw.slate700 : Tw.slate200),
      ),
      child: child,
    );
  }

  // ── OVERVIEW ─────────────────────────────────────────────────────────────

  Widget _overviewTab() {
    final dark = context.isDark;
    final details = _selectedCourseDetails;
    final course = _selectedCourse;
    final canManage = _canManage;
    final cols = context.isLg ? 3 : (context.isSm ? 2 : 1);

    Widget field(String label, Widget child) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // `<Label class="text-[12px] text-slate-500">` (`leading-none font-medium`)
            Text(label,
                style: const TextStyle(fontSize: 12, height: 1, fontWeight: FontWeight.w500, color: Tw.slate500)),
            const SizedBox(height: 4),
            child,
          ],
        );

    final fields = [
      field('Course Title', _ReadonlyBox(text: '${course?['title'] ?? ''}', input: true)),
      field(
        'Status',
        _ReadonlyBox(
          leading: Padding(padding: const EdgeInsets.only(right: 8), child: StatusDot(course?['status'])),
          text: capitalizeWords(course?['status']),
        ),
      ),
      field(
        'Course Instructor',
        _ReadonlyBox(
          text: jsTruthy(details?['createdInstructorName']) ? '${details!['createdInstructorName']}' : 'N/A',
          input: true,
        ),
      ),
    ];

    final curricula = [for (final c in asList(details?['curriculums'])) ?asMap(c)];
    final instructors = [for (final i in asList(details?['instructors'])) ?asMap(i)];
    final listBox = BoxDecoration(
      color: dark ? Tw.slate900 : Tw.slate50,
      borderRadius: BorderRadius.circular(20), // rounded-xl
      border: Border.all(color: dark ? Tw.slate700 : Tw.slate200),
    );

    Widget heading(IconData icon, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Icon(icon, size: 13, color: Tw.emerald500),
            const SizedBox(width: 6),
            Text(text,
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: dark ? Tw.slate200 : Tw.slate700)),
          ]),
        );

    Widget attachRow(Widget dropdown, bool loading, VoidCallback onAttach) {
      final button = AppButton(
        expand: !context.isSm,
        onPressed: loading ? null : onAttach,
        child: loading ? SpinIcon(size: 14, color: context.colors.onPrimary) : const Text('Attach'),
      );
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: context.isSm
            ? Row(children: [dropdown, const SizedBox(width: 12), button])
            : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [dropdown, const SizedBox(height: 12), button]),
      );
    }

    Widget countLine(String label, int n) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: '$label: '),
              TextSpan(text: '$n', style: const TextStyle(fontWeight: FontWeight.w700)),
            ]),
            style: const TextStyle(fontSize: 12, color: Tw.slate500),
          ),
        );

    Widget emptyLine(String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(text, style: const TextStyle(fontSize: 12, color: Tw.slate400)),
        );

    // `<button><i class="bi bi-dash-circle-fill text-lg"></button>` — the
    // icon's 28px line box sets the row height.
    Widget removeButton(VoidCallback onTap) => SizedBox(
          height: 28,
          child: Center(
            child: IconTapButton(
              icon: BootstrapIcons.dash_circle_fill,
              color: Tw.red500,
              hoverColor: TcTw.red700,
              onTap: onTap,
            ),
          ),
        );

    // `text-base cursor-pointer` icons without a handler.
    Widget pointerIcon(IconData icon, Color color) => MouseRegion(
          cursor: SystemMouseCursors.click,
          child: SizedBox(height: 24, child: Icon(icon, size: 16, color: color)),
        );

    final published = [for (final c in _store.curriculums) if (c['status'] == 'published') c];

    return _tabCard(Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormGrid(columns: cols, children: fields),
        const SizedBox(height: 32),
        Container(
          padding: const EdgeInsets.only(top: 20),
          decoration: BoxDecoration(border: Border(top: BorderSide(color: dark ? Tw.slate700 : Tw.slate100))),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Attach Curriculum ──
              heading(BootstrapIcons.journal_bookmark_fill, 'Attached Curricula'),
              if (canManage)
                attachRow(
                  OutlineDropdown<Map<String, dynamic>>(
                    text: jsTruthy(course?['selectedCourseCurriculumName'])
                        ? '${course!['selectedCourseCurriculumName']}'
                        : 'Select Curriculum',
                    menuLabel: 'Select Curriculum',
                    items: [for (final c in published) (c, '${c['name'] ?? ''}')],
                    onSelected: _curriculumSelected,
                  ),
                  _isAttachCurriculLoad,
                  () => _attachCurriculum(course),
                ),
              countLine('Attached Curricula', curricula.length),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: listBox,
                child: curricula.isEmpty
                    ? emptyLine('No curriculum attached')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < curricula.length; i++)
                            Padding(
                              padding: EdgeInsets.only(top: i == 0 ? 4 : 12, bottom: 4),
                              child: Row(children: [
                                Expanded(
                                    child: Text('${curricula[i]['name'] ?? ''}', style: const TextStyle(fontSize: 13))),
                                if (canManage)
                                  removeButton(() => _openDeleteCurriculumDialog(course, curricula[i])),
                              ]),
                            ),
                        ],
                      ),
              ),
              const SizedBox(height: 24),
              // ── Attach Instructor ──
              heading(BootstrapIcons.person_badge_fill, 'Attached Instructors'),
              if (canManage)
                attachRow(
                  OutlineDropdown<Map<String, dynamic>>(
                    text: jsTruthy(course?['selectedInstructorName'])
                        ? '${course!['selectedInstructorName']}'
                        : 'Select Instructor',
                    menuLabel: 'Select Instructor',
                    items: [for (final inst in _store.instructors) (inst, instructorDisplayName(inst))],
                    onSelected: (inst) => _selectInstructorForCourse(course, inst),
                  ),
                  _isAttachINSLoad,
                  () => _attachInstructor(course),
                ),
              countLine('Attached Instructors', instructors.length),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: listBox,
                child: instructors.isEmpty
                    ? emptyLine('No instructors attached')
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < instructors.length; i++)
                            Padding(
                              padding: EdgeInsets.only(top: i == 0 ? 4 : 12, bottom: 4),
                              child: Row(children: [
                                Expanded(
                                  child: Text(
                                    '${dig(instructors[i], ['user', 'first_name']) ?? ''} '
                                    '${dig(instructors[i], ['user', 'last_name']) ?? ''}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                pointerIcon(BootstrapIcons.envelope_fill, Tw.orange500),
                                const SizedBox(width: 12),
                                pointerIcon(BootstrapIcons.telephone_fill, Tw.blue500),
                                if (canManage) ...[
                                  const SizedBox(width: 12),
                                  removeButton(() => _openDeleteInstructorDialog(instructors[i])),
                                ],
                              ]),
                            ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ],
    ));
  }

  /// `curriculumSelected(curriculum)` — tags the selected course like the web.
  void _curriculumSelected(Map<String, dynamic> curriculum) {
    final course = _selectedCourse;
    if (course == null) return;
    _set(() {
      course['selectedCourseCurriculumId'] = curriculum['id'];
      course['selectedCourseCurriculumName'] = curriculum['name'];
    });
  }

  /// `attachCurriculum(course)`
  Future<void> _attachCurriculum(Map<String, dynamic>? course) async {
    if (!_canManage) return;
    final curriculumId = course?['selectedCourseCurriculumId'];
    final courseId = jsTruthy(_selectedCourseId) ? '$_selectedCourseId' : (course?['id']?.toString() ?? '');
    _set(() => _isAttachCurriculLoad = true);
    try {
      await _ctrl.attachCurriculumToCourse(curriculumId, courseId);
      final details = await _ctrl.fetchCourseDetails(courseId);
      _set(() {
        _selectedCourseDetails = details;
        if (course != null) {
          course['selectedCourseCurriculumId'] = null;
          course['selectedCourseCurriculumName'] = '';
        }
      });
    } catch (_) {
    } finally {
      _set(() => _isAttachCurriculLoad = false);
    }
  }

  /// `openDeleteCurriculumDialog(course, curriculum)` + `DetachCurriculum()`
  void _openDeleteCurriculumDialog(Map<String, dynamic>? course, Map<String, dynamic> curriculum) {
    if (!_canManage) return;
    showTcConfirm(
      context,
      title: 'Confirm Detach',
      message: const TextSpan(text: 'Are you sure you want to detach this curriculum?'),
      onConfirm: () async {
        if (!_canManage || !jsTruthy(course?['id']) || !jsTruthy(curriculum['id'])) return false;
        _set(() => _isLoading = true);
        try {
          await _ctrl.removeCurriculumFromCourse('${curriculum['id']}', '${course!['id']}');
          final details = _selectedCourseDetails;
          if (details != null && details['curriculums'] is List) {
            _set(() => _selectedCourseDetails = {
                  ...details,
                  'curriculums': [
                    for (final c in asList(details['curriculums']))
                      if (asMap(c)?['id'] != curriculum['id']) c,
                  ],
                });
          }
          return true;
        } catch (_) {
          return false;
        } finally {
          _set(() => _isLoading = false);
        }
      },
    );
  }

  /// `selectInstructorForCourse(course, instructor)`
  void _selectInstructorForCourse(Map<String, dynamic>? course, Map<String, dynamic> instructor) {
    if (!_canManage || course == null) return;
    _set(() {
      course['selectedInstructorId'] = instructor['id'];
      course['selectedInstructorName'] = instructorDisplayName(instructor);
    });
  }

  /// `attachInstructor(course)`
  Future<void> _attachInstructor(Map<String, dynamic>? course) async {
    if (!_canManage) return;
    final instructorId = course?['selectedInstructorId']?.toString();
    final courseId = jsTruthy(_selectedCourseId) ? '$_selectedCourseId' : course?['id']?.toString();
    _set(() => _isAttachINSLoad = true);
    try {
      await _ctrl.attachInstructorToCourse(courseId, instructorId);
      final details = await _ctrl.fetchCourseDetails(courseId ?? '');
      _set(() {
        _selectedCourseDetails = details;
        if (course != null) {
          course['selectedInstructorId'] = null;
          course['selectedInstructorName'] = '';
        }
      });
    } catch (_) {
    } finally {
      _set(() => _isAttachINSLoad = false);
    }
  }

  /// `openDeleteInstructorDialog(instructor)` + `DetachInstructor()`
  void _openDeleteInstructorDialog(Map<String, dynamic> instructor) {
    if (!_canManage) return;
    showTcConfirm(
      context,
      title: 'Confirm Detach',
      message: const TextSpan(text: 'Are you sure you want to detach this instructor?'),
      onConfirm: () async {
        final courseId = _selectedCourseId;
        if (!_canManage || !jsTruthy(courseId)) return false;
        _set(() => _isLoading = true);
        try {
          await _ctrl.removeInstructorFromCourse('${instructor['id']}', '$courseId');
          final details = _selectedCourseDetails;
          if (details != null && details['instructors'] is List) {
            _set(() => _selectedCourseDetails = {
                  ...details,
                  'instructors': [
                    for (final i in asList(details['instructors']))
                      if (asMap(i)?['id'] != instructor['id']) i,
                  ],
                });
          }
          return true;
        } catch (_) {
          return false;
        } finally {
          _set(() => _isLoading = false);
        }
      },
    );
  }

  // ── MANAGE (OUTLINE) ─────────────────────────────────────────────────────

  Widget _manageTab() {
    final dark = context.isDark;
    final canManage = _canManage;
    final store = ref.read(teacherCourseControllerProvider);
    final sections = store.sections;
    final sm = context.isSm;

    Widget actionIcons({
      required bool open,
      required double size,
      required (String, VoidCallback) add,
      required (String, VoidCallback) edit,
      required (String, VoidCallback) delete,
    }) {
      Widget btn(IconData icon, Color color, Color hover, (String, VoidCallback) a) => IconTapButton(
            icon: icon,
            size: size,
            tooltip: a.$1,
            color: open ? Colors.white.withValues(alpha: 0.8) : color,
            hoverColor: open ? Colors.white : hover,
            onTap: a.$2,
          );
      return Row(mainAxisSize: MainAxisSize.min, children: [
        btn(BootstrapIcons.plus_circle_fill, Tw.amber500, Tw.amber600, add),
        const SizedBox(width: 10),
        btn(BootstrapIcons.pencil_square, Tw.blue500, Tw.blue600, edit),
        const SizedBox(width: 10),
        btn(BootstrapIcons.dash_circle_fill, Tw.red500, Tw.red600, delete),
      ]);
    }

    Widget orderAndName(Object? order, Object? name, double nameSize, FontWeight weight) => Row(children: [
          Opacity(
            opacity: 0.6,
            child: Text('${order ?? ''}', style: const TextStyle(fontSize: 11, fontFamily: 'monospace')),
          ),
          const SizedBox(width: 8),
          Flexible(child: Text('${name ?? ''}', style: TextStyle(fontSize: nameSize, fontWeight: weight))),
        ]);

    Widget contentRow(Map<String, dynamic> section, Map<String, dynamic> chapter, Map<String, dynamic> content, bool last) {
      final icon = contentTypeIcon(content['type'], 14);
      return _HoverRow(
        last: last,
        child: Row(children: [
          SizedBox(
            width: 24,
            child: Text('${content['order'] ?? ''}',
                textAlign: TextAlign.right,
                style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: Tw.slate400)),
          ),
          const SizedBox(width: 12),
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: dark ? Tw.slate700 : Tw.slate100,
              borderRadius: BorderRadius.circular(14), // rounded-md
            ),
            child: icon,
          ),
          const SizedBox(width: 12),
          Expanded(child: _LinkText(text: '${content['name'] ?? ''}', onTap: () => _handleContentClick(content))),
          if (canManage) ...[
            const SizedBox(width: 8),
            IconTapButton(
              icon: BootstrapIcons.pencil_square,
              size: 16,
              color: Tw.blue500,
              hoverColor: Tw.blue700,
              onTap: () => _openContentUpdateDialog(_selectedCourseId, section['id'], chapter['id'], content['id']),
            ),
            const SizedBox(width: 10),
            IconTapButton(
              icon: BootstrapIcons.dash_circle_fill,
              size: 16,
              color: Tw.red500,
              hoverColor: TcTw.red700,
              onTap: () => _openDeleteContentDialog(content),
            ),
          ],
        ]),
      );
    }

    Widget chaptersOf(Map<String, dynamic> section) {
      final chapters = store.chapters;
      if (chapters.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Text('No chapters available for this section.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Tw.slate400)),
        );
      }
      final contents = store.contents;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var ci = 0; ci < chapters.length; ci++) ...[
            if (ci > 0) const SizedBox(height: 6),
            () {
              final chapter = chapters[ci];
              final open = _expandedChapterRow == 'chapter-$ci';
              return AccordionTile(
                open: open,
                radius: 16, // rounded-lg
                last: ci == chapters.length - 1,
                bold: open,
                headerPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                headerColor: open ? Tw.emerald500 : (dark ? Tw.slate800 : Colors.white),
                headerForeground: open ? Colors.white : (dark ? Tw.slate200 : Tw.slate800),
                onTap: () {
                  _set(() => _expandedChapterRow = open ? '' : 'chapter-$ci');
                  _onChapterSelect(chapter);
                },
                header: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(children: [
                    Expanded(child: orderAndName(chapter['order'], chapter['name'], 13, FontWeight.w500)),
                    if (canManage)
                      actionIcons(
                        open: open,
                        size: 16,
                        add: ('Add Concept', () => _openConceptDialog(chapter)),
                        edit: (
                          'Edit Chapter',
                          () => _openChapterUpdateDialog(_selectedCourseId, section['id'], chapter['id'])
                        ),
                        delete: ('Delete Chapter', () => _openDeleteChapterDialog(chapter)),
                      ),
                  ]),
                ),
                content: Container(
                  color: dark ? Tw.slate800 : Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: sm ? 16 : 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (contents.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Text('No concepts available.',
                              textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Tw.slate400)),
                        ),
                      for (var k = 0; k < contents.length; k++)
                        contentRow(section, chapter, contents[k], k == contents.length - 1),
                    ],
                  ),
                ),
              );
            }(),
          ],
        ],
      );
    }

    return _tabCard(Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (canManage)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Align(
              alignment: Alignment.centerRight,
              // `class="gap-1.5 text-[13px]"`
              child: AppButton(
                onPressed: _openCreateSectionDialog,
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(BootstrapIcons.plus_lg, size: 13),
                  SizedBox(width: 6),
                  Text('Create Section', style: TextStyle(fontSize: 13)),
                ]),
              ),
            ),
          ),
        if (sections.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Column(children: [
              Icon(BootstrapIcons.collection, size: 30, color: Tw.slate400),
              SizedBox(height: 8),
              Text('No sections available for this course.',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16, height: 1.5, color: Tw.slate400)),
            ]),
          )
        else
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            () {
              final section = sections[i];
              final open = _expandedSectionRow == 'section-$i';
              return AccordionTile(
                open: open,
                radius: 20, // rounded-xl
                last: i == sections.length - 1,
                // open: `rounded-t-xl` over the kit's `rounded-md`
                headerRadius: open
                    ? const BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(14))
                    : const BorderRadius.all(Radius.circular(14)),
                bold: open,
                headerPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                headerColor: open ? Tw.emerald600 : (dark ? Tw.slate900 : Tw.slate50),
                headerForeground: open ? Colors.white : (dark ? Tw.slate200 : Tw.slate800),
                onTap: () {
                  _set(() => _expandedSectionRow = open ? '' : 'section-$i');
                  _onSectionSelect(section);
                },
                header: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Row(children: [
                    Expanded(child: orderAndName(section['order'], section['name'], 13.5, FontWeight.w600)),
                    if (canManage)
                      actionIcons(
                        open: open,
                        size: 18,
                        add: ('Add Chapter', _openCreateChapterDialog),
                        edit: ('Edit Section', () => _openSectionUpdateDialog(_selectedCourseId, section['id'])),
                        delete: ('Delete Section', () => _openDeleteSectionDialog(section)),
                      ),
                  ]),
                ),
                content: Container(
                  color: dark ? Tw.slate900.withValues(alpha: 0.5) : Tw.slate50,
                  padding: EdgeInsets.symmetric(horizontal: sm ? 16 : 12, vertical: 12),
                  child: chaptersOf(section),
                ),
              );
            }(),
          ],
      ],
    ));
  }

  // ── sections ─────────────────────────────────────────────────────────────

  /// `openCreateSectionDialog()` + `createSection()`
  void _openCreateSectionDialog() {
    if (!_canManage) return;
    showAppDialog<void>(
      context,
      builder: (_) => NameOrderDialog(
        title: 'Create Section',
        nameLabel: 'Section Name',
        namePlaceholder: 'Enter section name',
        submitLabel: 'Create',
        onSubmit: (name, order) async {
          if (!_canManage) return false;
          try {
            await _ctrl.createSection(name, jsNumberJson(order));
            final id = _selectedCourseId;
            if (id != null) await _ctrl.fetchSections(id);
            return true;
          } catch (_) {
            return false;
          }
        },
      ),
    );
  }

  /// `onSectionSelect(section)`
  Future<void> _onSectionSelect(Map<String, dynamic> section) async {
    _ctrl.setSectionId(section['id']);
    _set(() => _isLoading = true);
    try {
      await _ctrl.fetchChapters(section['id'] as Object);
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  Map<String, dynamic>? _findById(dynamic list, Object? id) {
    for (final e in asList(list)) {
      final m = asMap(e);
      if (m != null && m['id'] == id) return m;
    }
    return null;
  }

  /// `openSectionUpdateDialog(courseId, sectionId)` + `sectionUpdate()`
  void _openSectionUpdateDialog(Object? courseId, Object? sectionId) {
    if (!_canManage || !jsTruthy(courseId) || !jsTruthy(sectionId)) return;
    final current = _selectedSectionDetails;
    showAppDialog<void>(
      context,
      builder: (_) => NameOrderDialog(
        title: 'Edit Section',
        nameLabel: 'Section Name',
        namePlaceholder: 'Section name',
        submitLabel: 'Update',
        initialName: current == null ? null : '${current['name'] ?? ''}',
        initialOrder: _updateSectionOrder,
        load: () async {
          _set(() => _isLoading = true);
          try {
            final details = await _ctrl.fetchCourseDetails(courseId!);
            final section = _findById(details?['sections'], sectionId);
            if (section == null) {
              _selectedSectionDetails = null;
              return null;
            }
            _selectedSectionDetails = section;
            _updateSectionOrder = '${section['order'] ?? ''}';
            return ('${section['name'] ?? ''}', _updateSectionOrder);
          } catch (_) {
            return null;
          } finally {
            _set(() => _isLoading = false);
          }
        },
        onSubmit: (name, order) async {
          final sel = _selectedSectionDetails;
          if (!_canManage || sel == null || !jsTruthy(sel['id'])) return false;
          _selectedSectionDetails = {...sel, 'name': name};
          _updateSectionOrder = order;
          try {
            await _ctrl.updateSection(sel['id'] as Object, name, jsNumberJson(order));
          } catch (_) {
            return false;
          }
          final id = _selectedCourseId;
          if (id != null) unawaited(_ctrl.fetchSections(id).catchError((_) {}));
          return true;
        },
      ),
    );
  }

  /// `openDeleteSectionDialog(section)` + `confirmDeleteSection()`
  void _openDeleteSectionDialog(Map<String, dynamic> section) {
    if (!_canManage) return;
    showTcConfirm(
      context,
      title: 'Confirm Delete',
      message: TextSpan(children: [
        const TextSpan(text: 'Delete section '),
        _bold('"${section['name'] ?? ''}"'),
        const TextSpan(text: '?'),
      ]),
      onConfirm: () async {
        if (!_canManage || !jsTruthy(section['id'])) return false;
        _set(() => _isLoading = true);
        try {
          await _ctrl.deleteSection(section['id'] as Object);
          _set(() => _expandedSectionRow = '');
          final id = _selectedCourseId;
          if (id != null) await _ctrl.fetchSections(id);
          return true;
        } catch (_) {
          return false;
        } finally {
          _set(() => _isLoading = false);
        }
      },
    );
  }

  // ── chapters ─────────────────────────────────────────────────────────────

  /// `openCreateChapterDialog()` + `createChapter()` — uses the store's
  /// `section_id` (the last section clicked), like the web.
  void _openCreateChapterDialog() {
    if (!_canManage) return;
    showAppDialog<void>(
      context,
      builder: (_) => NameOrderDialog(
        title: 'Create Chapter',
        nameLabel: 'Chapter Name',
        namePlaceholder: 'Enter chapter name',
        submitLabel: 'Create',
        onSubmit: (name, order) async {
          if (!_canManage) return false;
          try {
            await _ctrl.createChapter(name, jsNumberJson(order));
            return true;
          } catch (_) {
            return false;
          }
        },
      ),
    );
  }

  /// `onChapterSelect(chapter)`
  Future<void> _onChapterSelect(Map<String, dynamic> chapter) async {
    _set(() => _selectedChapterId = chapter['id']);
    _ctrl.setChapterId(chapter['id']);
    _set(() => _isLoading = true);
    try {
      await _ctrl.fetchContents(chapter['id'] as Object);
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  /// `openChapterUpdateDialog(courseId, sectionId, chapterId)` + `chapterUpdate()`
  void _openChapterUpdateDialog(Object? courseId, Object? sectionId, Object? chapterId) {
    if (!_canManage || !jsTruthy(courseId) || !jsTruthy(sectionId) || !jsTruthy(chapterId)) return;
    final current = _selectedChapterDetails;
    showAppDialog<void>(
      context,
      builder: (_) => NameOrderDialog(
        title: 'Edit Chapter',
        nameLabel: 'Chapter Name',
        namePlaceholder: 'Chapter name',
        submitLabel: 'Update',
        initialName: current == null ? null : '${current['name'] ?? ''}',
        initialOrder: _updatechapterOrder,
        load: () async {
          try {
            final details = await _ctrl.fetchCourseDetails(courseId!);
            final section = _findById(details?['sections'], sectionId);
            if (section == null) return null;
            final chapter = _findById(section['chapters'], chapterId);
            if (chapter == null) return null;
            _selectedChapterDetails = chapter;
            _updatechapterOrder = '${chapter['order'] ?? ''}';
            return ('${chapter['name'] ?? ''}', _updatechapterOrder);
          } catch (_) {
            return null;
          }
        },
        onSubmit: (name, order) async {
          final sel = _selectedChapterDetails;
          if (!_canManage || sel == null || !jsTruthy(sel['id'])) return false;
          _selectedChapterDetails = {...sel, 'name': name};
          _updatechapterOrder = order;
          try {
            await _ctrl.updateChapter(sel['id'] as Object, name, jsNumberJson(order));
            final sectionId = _ctrl.sectionId;
            if (sectionId != null) await _ctrl.fetchChapters(sectionId);
            return true;
          } catch (_) {
            return false;
          }
        },
      ),
    );
  }

  /// `openDeleteChapterDialog(chapter)` + `confirmDeleteChapter()`
  void _openDeleteChapterDialog(Map<String, dynamic> chapter) {
    if (!_canManage) return;
    showTcConfirm(
      context,
      title: 'Confirm Delete',
      message: TextSpan(children: [
        const TextSpan(text: 'Delete chapter '),
        _bold('"${chapter['name'] ?? ''}"'),
        const TextSpan(text: '?'),
      ]),
      onConfirm: () async {
        if (!_canManage || !jsTruthy(chapter['id'])) return false;
        _set(() => _isLoading = true);
        try {
          await _ctrl.deleteChapter(chapter['id'] as Object);
          _set(() => _expandedChapterRow = '');
          final sectionId = _ctrl.sectionId;
          if (sectionId != null) await _ctrl.fetchChapters(sectionId);
          return true;
        } catch (_) {
          return false;
        } finally {
          _set(() => _isLoading = false);
        }
      },
    );
  }

  // ── concepts (contents) ──────────────────────────────────────────────────

  /// `openConceptDialog(chapter)` + `createContent()`
  void _openConceptDialog(Map<String, dynamic> chapter) {
    if (!_canManage) return;
    _set(() => _selectedChapterId = chapter['id']);
    _ctrl.setChapterId(chapter['id']);
    showAppDialog<void>(
      context,
      builder: (_) => ConceptDialog(
        edit: false,
        initial: const ConceptValues(type: 'html'),
        onSubmit: (v) async {
          if (!_canManage) return false;
          try {
            await _ctrl.createContent(_ctrl.sectionId, _selectedChapterId, {
              'name': v.name,
              'type': v.type,
              'url': v.url,
              'zslactvity': '',
              'file': v.file,
              'html_content': v.htmlContent,
              'order': v.order,
            });
            return true;
          } catch (_) {
            return false;
          }
        },
      ),
    );
  }

  /// `openContentUpdateDialog(courseId, sectionId, chapterId, contentId)` +
  /// `contentUpdate(id)`. The dialog opens once the concept is loaded (the
  /// web rendered it only when `selectedContentDetails.id` was set).
  Future<void> _openContentUpdateDialog(Object? courseId, Object? sectionId, Object? chapterId, Object? contentId) async {
    if (!_canManage ||
        !jsTruthy(courseId) ||
        !jsTruthy(sectionId) ||
        !jsTruthy(chapterId) ||
        !jsTruthy(contentId)) {
      return;
    }
    Map<String, dynamic> selected;
    String order;
    try {
      final details = await _ctrl.fetchCourseDetails(courseId!);
      final section = _findById(details?['sections'], sectionId);
      if (section == null) return;
      final chapter = _findById(section['chapters'], chapterId);
      if (chapter == null) return;
      final content = _findById(chapter['contents'], contentId);
      if (content == null) return;
      order = '${content['order'] ?? ''}';
      String s(String k) => jsTruthy(content[k]) ? '${content[k]}' : '';
      selected = {
        'id': content['id'],
        'name': s('name'),
        'type': s('type'),
        'url': s('url'),
        'html_content': s('content'),
        'order': '',
        'file': null,
      };
    } catch (_) {
      return;
    }
    if (!mounted) return;
    await showAppDialog<void>(
      context,
      builder: (_) => ConceptDialog(
        key: ValueKey(selected['id']),
        edit: true,
        initial: ConceptValues(
          name: '${selected['name']}',
          order: order,
          type: '${selected['type']}',
          htmlContent: '${selected['html_content']}',
          url: '${selected['url']}',
        ),
        onSubmit: (v) async {
          if (!_canManage) return false;
          try {
            await _ctrl.updateContent(selected['id'], {
              ...selected,
              'name': v.name,
              'type': v.type,
              'url': v.url,
              'html_content': v.htmlContent,
              'file': v.file,
              // `selectedContentDetails.order = Number(updatecontentOrder)`
              'order': v.order,
            });
          } catch (_) {
            return false;
          }
          final chapter = _selectedChapterId;
          if (chapter != null) unawaited(_ctrl.fetchContents(chapter).catchError((_) {}));
          return true;
        },
      ),
    );
  }

  /// `handleContentClick(content)` — the preview dialog.
  void _handleContentClick(Map<String, dynamic> content) =>
      showAppDialog<void>(context, builder: (_) => ContentPreviewDialog(content: content));

  /// `openDeleteContentDialog(content)` + `confirmDeleteContent()`
  void _openDeleteContentDialog(Map<String, dynamic> content) {
    if (!_canManage) return;
    showTcConfirm(
      context,
      title: 'Confirm Delete',
      message: TextSpan(children: [
        const TextSpan(text: 'Delete concept '),
        _bold('"${content['name'] ?? ''}"'),
        const TextSpan(text: '?'),
      ]),
      onConfirm: () async {
        if (!_canManage || !jsTruthy(content['id'])) return false;
        _set(() => _isLoading = true);
        try {
          await _ctrl.deleteContent(content['id'] as Object);
          final chapter = _selectedChapterId;
          if (chapter != null) await _ctrl.fetchContents(chapter);
          return true;
        } catch (_) {
          return false;
        } finally {
          _set(() => _isLoading = false);
        }
      },
    );
  }
}

/// The Overview tab's read-only boxes, all `h-9 rounded-md` (14px) with
/// `bg-slate-50 dark:bg-slate-900`:
/// * [input] — a disabled shadcn `<Input class="text-[13px]">`: `border-input`,
///   `shadow-xs`, `disabled:opacity-50`, and the kit's `md:text-sm` (14px
///   from 768px);
/// * otherwise the Status box:
///   `<div class="px-3 border border-slate-200 dark:border-slate-700 text-[13px]">`.
class _ReadonlyBox extends StatelessWidget {
  const _ReadonlyBox({required this.text, this.leading, this.input = false});
  final String text;
  final Widget? leading;
  final bool input;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final borderColor = input
        ? (dark ? AppColors.darkBorder : AppColors.border)
        : (dark ? Tw.slate700 : Tw.slate200);
    final box = Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900 : Tw.slate50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
        boxShadow: input ? TcShadows.xs : null,
      ),
      child: Row(children: [
        ?leading,
        Expanded(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: input && context.isMd ? 14 : 13)),
        ),
      ]),
    );
    return input ? Opacity(opacity: 0.5, child: box) : box;
  }
}

/// A concept row (`py-2.5 px-2 rounded-lg border-b last:border-b-0
/// hover:bg-slate-50 dark:hover:bg-slate-700/30`).
class _HoverRow extends StatefulWidget {
  const _HoverRow({required this.child, required this.last});
  final Widget child;
  final bool last;

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: _hover ? (dark ? Tw.slate700.withValues(alpha: 0.3) : Tw.slate50) : null,
          borderRadius: BorderRadius.circular(16), // rounded-lg
          border: widget.last ? null : Border(bottom: BorderSide(color: dark ? Tw.slate700 : Tw.slate100)),
        ),
        child: widget.child,
      ),
    );
  }
}

/// `text-[13px] text-blue-600 font-medium hover:underline cursor-pointer truncate`
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
  Widget build(BuildContext context) => MouseRegion(
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
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Tw.blue600,
              decoration: _hover ? TextDecoration.underline : null,
              decorationColor: Tw.blue600,
            ),
          ),
        ),
      );
}
