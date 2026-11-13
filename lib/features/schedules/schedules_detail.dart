part of 'schedules_page.dart';

/// The accordion content of a schedule: the section tabs, the class chat and
/// the live participants (On Going) or attendance list (other tabs). Every
/// open item shows the page-wide state, exactly like the web.
extension _DetailUi on _SchedulesPageState {
  Widget _buildDetail(BuildContext context, {required bool ongoing}) {
    final left = _buildSectionTabs(context, ongoing: ongoing);
    final chat = _buildChat(context, ongoing: ongoing);
    final Widget top;
    if (context.isLg) {
      // `flex lg:flex-row gap-6` with a `flex-1` sections panel next to a
      // `w-full` chat: the panel shrinks to its min-content width and the
      // chat takes the rest of the row.
      top = LayoutBuilder(builder: (context, c) {
        final leftW = math.min(_leftPanelWidth(context, ongoing: ongoing), math.max(0.0, c.maxWidth - 24 - 160));
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Panel(width: leftW, child: left),
            const SizedBox(width: 24),
            Expanded(child: _Panel(shadowMd: true, child: chat)),
          ],
        );
      });
    } else {
      top = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [_Panel(child: left), const SizedBox(height: 24), _Panel(shadowMd: true, child: chat)],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        top,
        const SizedBox(height: 16),
        ongoing ? _buildParticipants(context) : _buildAttendance(context),
      ],
    );
  }

  // ── section tabs ─────────────────────────────────────────────────────────

  /// On Going: select below lg, tab list from xl (neither in between — as on
  /// the web); other tabs: select below 2xl, tab list from 2xl.
  ({bool select, bool list}) _sectionNav(BuildContext context, {required bool ongoing}) {
    final w = context.screenWidth;
    return ongoing ? (select: !context.isLg, list: context.isXl) : (select: w < 1536, list: w >= 1536);
  }

  List<(String, String)> _sectionTabs({required bool ongoing}) => [
        ('BasicInfo', ongoing ? 'Basic Info' : 'Class Info'),
        ('ClassReference', 'Class Reference'),
        ('ClassActivity', 'Class Assignment'),
        ('HomeActivity', 'Home Assignment'),
        ('Quiz', 'Quiz'),
      ];

  List<AppSelectItem<String>> _sectionItems({required bool ongoing}) => [
        AppSelectItem('BasicInfo', ongoing ? 'Basic Info' : 'Class Info'),
        const AppSelectItem('ClassReference', 'Class Reference'),
        const AppSelectItem('ClassActivity', 'Class Assignments'),
        const AppSelectItem('HomeActivity', 'Home Assignments'),
        const AppSelectItem('Quiz', 'Quiz'),
      ];

  /// The sections panel's min-content width on the web (≥ lg): the widest of
  /// the tab list / section select and the active section, plus `p-4` and
  /// the border.
  double _leftPanelWidth(BuildContext context, {required bool ongoing}) {
    final nav = _sectionNav(context, ongoing: ongoing);
    var w = 0.0;
    if (nav.list) {
      w = _SectionTabsList.naturalWidth(context, [for (final t in _sectionTabs(ongoing: ongoing)) t.$2]);
    }
    if (nav.select) {
      var label = 'Select Section';
      for (final it in _sectionItems(ongoing: ongoing)) {
        if (it.value == _activetabs) label = it.label;
      }
      w = math.max(w, _selectFitWidth(context, label));
    }
    final canAdd = _role != Role.institute && _role != Role.student;
    double buttonW(String label) =>
        _textWidth(context, label, const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)) + 32;
    switch (_activetabs) {
      case 'BasicInfo':
        final f = _getScheduleForm;
        final classType = vText(f['classType']);
        var subject = 'Select a Subject';
        for (final c in _courses) {
          if (schString(c['id']) == vText(f['subjectId'])) subject = vText(c['title']);
        }
        final typeW = _selectFitWidth(context, classType == 'eClass' ? 'eClass' : 'Select Class Type');
        final subjectW = _selectFitWidth(context, subject);
        // On Going: `lg:flex-row` rows; others: a `md:grid-cols-2` grid.
        w = math.max(w, ongoing ? typeW + 16 + subjectW : 2 * math.max(typeW, subjectW) + 16);
      case 'ClassReference' || 'ClassActivity' || 'HomeActivity':
        // `min-w-[600px]` table in a `mx-4` / `m-4` card.
        w = math.max(w, 632);
      case 'Quiz':
        final hasExam = jsTruthy(_activeexamid) && jsTruthy(_activeScheduleId);
        // Estimated min-content of the exam card (status pill + icons), or
        // the longest word of "Please create a Quiz" (`text-lg`).
        w = math.max(w, hasExam ? 300 : 100);
        if (canAdd) w = math.max(w, buttonW('Create Quiz'));
    }
    return w + 34;
  }

  Widget _buildSectionTabs(BuildContext context, {required bool ongoing}) {
    final nav = _sectionNav(context, ongoing: ongoing);
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // `mb-4` select / `mb-6` tab list, then the Tabs root's `gap-2` and
          // the content's `mt-4`.
          if (nav.select)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppSelect<String>(
                value: _activetabs,
                placeholder: 'Select Section',
                items: _sectionItems(ongoing: ongoing),
                onChanged: (v) {
                  if (v != null) _set(() => _activetabs = v);
                },
              ),
            ),
          if (nav.list)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: _SectionTabsList(
                    value: _activetabs,
                    tabs: _sectionTabs(ongoing: ongoing),
                    onTap: (v) {
                      _set(() => _activetabs = v);
                      if (v == 'Quiz') _guard(_fetchExam);
                    },
                  ),
                ),
              ),
            ),
          Padding(
            // `mt-4 … pb-20`; the other tabs' Tabs root adds `pb-16`.
            padding: EdgeInsets.only(top: 24, bottom: ongoing ? 80 : 144),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 768),
                child: _sectionContent(context, ongoing: ongoing),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionContent(BuildContext context, {required bool ongoing}) {
    final canAdd = _role != Role.institute && _role != Role.student;
    // `flex justify-end px-4`, then `space-y-4` (16) to the table card.
    Widget addButton(String label, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Align(alignment: Alignment.centerRight, child: AppButton(label: label, onPressed: onTap)),
        );
    switch (_activetabs) {
      case 'Quiz':
        return _buildQuizTab(context, ongoing: ongoing);
      case 'BasicInfo':
        return _buildBasicInfo(context, ongoing: ongoing);
      case 'ClassReference':
        final rows = ongoing ? schMaps(dig(_store.ongoingschedules, [0, 'references'])) : _classreference;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canAdd)
              addButton('Add Class Reference', ongoing ? _openClassReferenceDialog : _showClassReferenceDialog),
            _itemsTable(
              context,
              ongoing: ongoing,
              rows: rows,
              emptyText: ongoing ? 'No references found' : 'No references.',
              onView: _viewClassReference,
              onEdit: _editClassReference,
              // The On Going table's delete icon has no handler on the web.
              onDelete: ongoing ? null : (r) => _deleteClassReference(r['id']),
            ),
          ],
        );
      case 'ClassActivity':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canAdd)
              addButton(ongoing ? 'Add Class Assignment' : 'Add Class Assignments',
                  ongoing ? _openClassActivityDialog : _showClassActivityDialog),
            _itemsTable(
              context,
              ongoing: ongoing,
              rows: _classActivities,
              emptyText: ongoing ? 'No Class Assignments' : 'No Class Assignments.',
              onView: (a) => _viewActivity(a, home: false),
              onEdit: (a) => _editActivity(a, home: false),
              onDelete: (a) => _deleteClassActivity(a['id']),
            ),
          ],
        );
      case 'HomeActivity':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canAdd) addButton('Add Home Assignments', _showHomeActivityDialog),
            _itemsTable(
              context,
              ongoing: ongoing,
              rows: _homeActivities,
              emptyText: ongoing ? 'No Home Assignments' : 'No Home Assignments.',
              onView: (a) => _viewActivity(a, home: true),
              onEdit: (a) => _editActivity(a, home: true),
              // The web calls deleteClassActivity for home items too.
              onDelete: (a) => _deleteClassActivity(a['id']),
            ),
          ],
        );
    }
    return const SizedBox.shrink();
  }

  /// ID / Name / Action table of references and assignments.
  ///
  /// * On Going: `<Card class="mx-4 rounded-md shadow-sm">` around a
  ///   `w-80 md:w-full overflow-x-auto` box, `whitespace-nowrap`, ID
  ///   `font-medium`, name `max-w-[260px] truncate`, empty
  ///   `text-muted-foreground py-8`, rows `hover:bg-muted/40`.
  /// * Others: `<Card class="m-4 rounded-md shadow-md">`, empty
  ///   `text-gray-500 py-6`, rows `hover:bg-gray-50`.
  Widget _itemsTable(
    BuildContext context, {
    required bool ongoing,
    required List<SJson> rows,
    required String emptyText,
    required void Function(SJson) onView,
    required void Function(SJson) onEdit,
    required void Function(SJson)? onDelete,
  }) {
    final muted = context.isDark ? AppColors.darkMuted : AppColors.muted;
    final table = _SchedTable(
      minWidth: 600,
      emptyText: emptyText,
      emptyColor: ongoing ? _mutedFg(context) : Tw.gray500,
      emptyPadding: ongoing ? 32 : 24,
      hoverColor: ongoing ? muted.withValues(alpha: 0.4) : Tw.gray50,
      columns: const [('ID', 0.6, false), ('Name', 2, false), ('Action', 1, true)],
      rows: [
        for (final r in rows)
          [
            Text(vText(r['id']), style: TextStyle(fontWeight: ongoing ? FontWeight.w500 : null)),
            Text(vText(r['name']), maxLines: 1, overflow: TextOverflow.ellipsis),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ScaleIcon(BootstrapIcons.eye_fill, color: Tw.blue600, onTap: () => onView(r)),
                const SizedBox(width: 16),
                _ScaleIcon(BootstrapIcons.pencil_square, color: Tw.green600, onTap: () => onEdit(r)),
                const SizedBox(width: 16),
                _ScaleIcon(BootstrapIcons.trash3_fill,
                    color: Tw.red600, onTap: onDelete == null ? null : () => onDelete(r)),
              ],
            ),
          ],
      ],
    );
    if (ongoing) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: _TableCard(
          child: context.isMd
              ? table
              : Align(alignment: Alignment.centerLeft, child: SizedBox(width: 320, child: table)),
        ),
      );
    }
    // `m-4`: its top margin collapses with the button row (`mb-0`) or the
    // content's `mt-4`, so only the sides and the bottom remain.
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: _TableCard(shadowMd: true, child: table),
    );
  }

  Widget _buildQuizTab(BuildContext context, {required bool ongoing}) {
    final hasExam = jsTruthy(_activeexamid) && jsTruthy(_activeScheduleId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_role != Role.institute && _role != Role.student)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Align(
              alignment: Alignment.centerRight,
              child: AppButton(label: 'Create Quiz', onPressed: _openQuizDialog),
            ),
          ),
        // `<Card class="p-4 shadow-sm rounded-md border">`
        ShadCard(
          padding: const EdgeInsets.all(16),
          radius: 14,
          child: hasExam
              ? ScheduleExamListView(
                  key: ValueKey('exam-list-${schString(_activeScheduleId)}'),
                  examId: _activeexamid!,
                  scheduleId: _activeScheduleId!,
                )
              : SizedBox(
                  height: 160,
                  child: Center(
                    child: Text(
                      ongoing ? 'Please create a Quiz,' : 'Please create a Quiz ',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18, color: Tw.gray500),
                    ),
                  ),
                ),
        ),
      ],
    );
  }

  /// The read-only Basic Info / Class Info fields: On Going rows
  /// `flex lg:flex-row gap-4` with `space-y-4`; others `grid md:grid-cols-2
  /// gap-4` rows with `space-y-6`.
  Widget _buildBasicInfo(BuildContext context, {required bool ongoing}) {
    final f = _getScheduleForm;
    Widget field(String label, String value, String hint) => _labeled(
          label,
          AppTextField(key: ValueKey('$label-$value'), initialValue: value, hint: hint, enabled: false),
        );
    final columns = ongoing ? (context.isLg ? 2 : 1) : (context.isMd ? 2 : 1);
    final classType = vText(f['classType']);
    final subjectId = vText(f['subjectId']);
    final rows = [
      [
        field("Start's time", vText(f['startDate']), 'Enter start time'),
        field('Duration (Minutes)', vText(f['duration']), 'Duration in minutes'),
      ],
      [
        _labeled(
          'Class Type',
          AppSelect<String>(
            value: classType.isEmpty ? null : classType,
            enabled: false,
            placeholder: 'Select Class Type',
            items: const [AppSelectItem('eClass', 'eClass')],
            onChanged: null,
          ),
        ),
        _labeled(
          'Subject',
          AppSelect<String>(
            value: subjectId.isEmpty ? null : subjectId,
            enabled: false,
            placeholder: 'Select a Subject',
            items: [for (final c in _courses) AppSelectItem(schString(c['id']), vText(c['title']))],
            onChanged: null,
          ),
        ),
      ],
      [field('Class Title', vText(f['title']), 'Enter class title')],
    ];
    final rowGap = ongoing ? 16.0 : 24.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: rowGap),
          FormGrid(columns: columns, gap: 16, children: rows[i]),
        ],
      ],
    );
  }

  // ── chat ─────────────────────────────────────────────────────────────────

  Widget _buildChat(BuildContext context, {required bool ongoing}) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _borderColor(context)))),
            child: Text(
              'Class Chat',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: context.colors.primary),
            ),
          ),
          Expanded(child: _ChatList(messages: _chatMessages, headerGap: ongoing ? 16 : 4)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: AppTextField(
                  controller: _chatInput,
                  hint: 'Type a message...',
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              AppButton(label: 'Send', size: AppButtonSize.sm, onPressed: _sendMessage),
            ],
          ),
        ],
      );

  // ── participants / attendance ────────────────────────────────────────────

  /// `<Card class="mt-4 p-4">` (`gap-6`): the heading and the
  /// `min-w-[650px] whitespace-nowrap` table.
  Widget _buildParticipants(BuildContext context) {
    final students = asList(_store.scheduleStudents);
    return ShadCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Live Participants', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              Text(
                '( ${onlineStudentCount(_store.scheduleStudents, _onlineUsers)} active / ${students.length} students )',
                style: const TextStyle(fontSize: 14, color: Tw.gray500),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SchedTable(
            minWidth: 650,
            emptyText: 'No participants found.',
            columns: const [('Name', 1.4, false), ('Email', 1.8, false), ('In Class', 1, false), ('Join', 1, false)],
            rows: [
              for (final st in students)
                [
                  Text('${dig(st, ['user', 'first_name']) ?? ''} ${dig(st, ['user', 'last_name']) ?? ''}'),
                  Text(jsTruthy(dig(st, ['user', 'email'])) ? '${dig(st, ['user', 'email'])}' : 'N/A'),
                  isStudentOnline(st, _onlineUsers)
                      ? const Text('Active', style: TextStyle(color: Tw.green600, fontWeight: FontWeight.w600))
                      : const Text('Inactive', style: TextStyle(color: Tw.gray500, fontWeight: FontWeight.w500)),
                  joinedStudentIdsHas(st, _joinedStudentIds)
                      ? const Text('Joined', style: TextStyle(color: Tw.green600, fontWeight: FontWeight.w600))
                      : const Text('Not Joined', style: TextStyle(color: Tw.gray500, fontWeight: FontWeight.w500)),
                ],
            ],
          ),
        ],
      ),
    );
  }

  /// `<Card class="mt-4 p-4">` (`gap-6`) with "Attendance List" and the
  /// table in a nested `<Card class="m-4 p-0">`.
  Widget _buildAttendance(BuildContext context) => ShadCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Attendance List', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            ShadCard(
              margin: const EdgeInsets.all(16),
              padding: EdgeInsets.zero,
              child: _SchedTable(
                minWidth: 640,
                emptyText: 'No Attendance Records Found',
                columns: const [
                  ('Name', 1.4, false),
                  ('email', 1.8, false),
                  ('Join Time', 1, false),
                  ('Leave Time', 1, false),
                  ('Duration (mins)', 1, false),
                  ('Status', 1, false),
                ],
                rows: [
                  for (final record in _attendanceRecordsLocal)
                    () {
                      final user = dig(record, ['student', 'user']);
                      final first = asMap(user)?['first_name'];
                      final last = asMap(user)?['last_name'];
                      final email = asMap(user)?['email'];
                      final duration = asMap(record)?['duration'];
                      final attended = schNumber(duration) > 0;
                      return <Widget>[
                        Text('${jsTruthy(first) ? first : 'Unknown'} ${jsTruthy(last) ? last : ''}'),
                        Text(jsTruthy(email) ? '$email' : '-'),
                        Text(formatAttendanceTime(asMap(record)?['from'])),
                        Text(formatAttendanceTime(asMap(record)?['to'])),
                        Text(jsTruthy(duration) ? vText(duration) : '0'),
                        Text(attended ? 'Attended' : 'Absent',
                            style: TextStyle(color: attended ? Tw.green600 : Tw.red600)),
                      ];
                    }(),
                ],
              ),
            ),
          ],
        ),
      );
}
