part of 'exam_page.dart';

/// Port of `src/pages/exams/ExamsList.vue`: language / class / batch filters,
/// the student tabs (available / in progress / completed) and the staff
/// table with view / edit / delete / results / publish.
class _ExamsListView extends ConsumerStatefulWidget {
  const _ExamsListView({super.key});

  @override
  ConsumerState<_ExamsListView> createState() => _ExamsListViewState();
}

class _ExamsListViewState extends ConsumerState<_ExamsListView> {
  // ── data() ──
  String? _selectedYear;
  Object? _selectedBatch;
  String _activeExamTab = 'availableexams';
  late String _selectedLocale;
  Json? _examToDelete;

  ExamsController get _ctrl => ref.read(examsControllerProvider.notifier);
  String get _role => ref.read(sessionProvider).role;

  /// `selectedLocale !== 'all' ? selectedLocale : undefined`
  String? get _localeParam => _selectedLocale != 'all' ? _selectedLocale : null;

  @override
  void initState() {
    super.initState();
    _selectedLocale = _role == Role.student ? 'all' : defaultExamLocale;
    Future.microtask(_mounted);
  }

  /// Errors were already toasted by the API client; the web only logged them.
  Future<void> _quiet(Future<dynamic> Function() fn) async {
    try {
      await fn();
    } catch (_) {}
  }

  /// `mounted()` — `Promise.allSettled([...])`.
  Future<void> _mounted() async {
    final student = _role == Role.student;
    await Future.wait([
      _quiet(() => _ctrl.fetchExams(_localeParam)),
      _quiet(() => _ctrl.getClasses('published')),
      if (student) _quiet(() => _ctrl.fetchExamAttempts()),
    ]);
  }

  /// `watch: selectedLocale`
  void _setLocale(String? v) {
    if (v == null || v == _selectedLocale) return;
    setState(() => _selectedLocale = v);
    _quiet(() => _ctrl.fetchExams(_localeParam, _selectedYear, _selectedBatch));
  }

  /// `watch: selectedBatch`
  void _setBatch(Object? v) {
    if (v == _selectedBatch) return;
    setState(() => _selectedBatch = v);
    _quiet(() => _ctrl.fetchExams(_localeParam, _selectedYear, v));
  }

  /// `v-model="selectedYear"` + `onYearChange`
  Future<void> _onYearChange(String? value) async {
    setState(() => _selectedYear = value);
    if (value == null) return;
    _setBatch(null);
    final classId = jsonNum(jsNum(value));
    try {
      await _ctrl.getBatches(classId);
      await _ctrl.fetchExams(_localeParam, classId, null);
    } catch (_) {}
  }

  void _goToStudentResult(Object? examId) => context.go('/examattempts/$examId');

  Future<void> _publishExam(Object? examId) async {
    try {
      await _ctrl.examStatus(examId ?? 'undefined');
      await _ctrl.fetchExams();
    } catch (_) {}
  }

  /// `startexam(examId)` → `/startexam?redirect=<current path>` (the attempt
  /// is handed over through lmsHandoff `currentExamAttempt`).
  Future<void> _startexam(Object? examId) async {
    dynamic res;
    try {
      res = await _ctrl.startExam(examId ?? 'undefined');
    } catch (_) {
      return;
    }
    if (!jsTruthy(res) || !mounted) return;
    var redirect = '/exams';
    try {
      redirect = GoRouterState.of(context).uri.toString();
    } catch (_) {}
    context.go(Uri(path: '/startexam', queryParameters: {'redirect': redirect}).toString());
  }

  void _openDeleteDialog(Json exam) {
    _examToDelete = exam;
    showAppDialog<void>(context, builder: (dialogCtx) => _deleteDialog(dialogCtx));
  }

  Future<void> _confirmDelete(BuildContext dialogCtx) async {
    final exam = _examToDelete;
    if (exam == null) return;
    try {
      await _ctrl.examDelete(exam['id'] ?? 'undefined');
    } catch (_) {
      return;
    }
    if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
    _examToDelete = null;
    await _quiet(() => _ctrl.fetchExams());
  }

  void _editexams(Json exam) => context.go('/editexams/${exam['id']}');
  void _viewexams(Json exam) => context.go('/viewexams/${exam['id']}');
  void _goToExamResults(Json exam) => context.go('/examattempts/${exam['id']}');

  // ── template ──

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(examsControllerProvider);
    final role = ref.watch(sessionProvider).role;
    final examRows = examMaps(s.examslist);

    return GapColumn(
      children: [
        _filters(s),
        if (role == Role.student) _studentTabs(examRows, s) else _staffTable(listFilteredExams(examRows, role), role),
      ],
    );
  }

  Widget _filters(ExamsState s) {
    final published = [for (final b in s.batches) if (b['status'] == 'published') b];
    final language = _labeled(
      'Language',
      AppSelect<String>(
        value: _selectedLocale,
        placeholder: 'Select Language',
        items: [for (final (key, value) in localeOptions) AppSelectItem(value, key)],
        onChanged: _setLocale,
      ),
    );
    final cls = _labeled(
      'Select Class',
      AppSelect<String>(
        value: _selectedYear,
        placeholder: 'Select a Class',
        items: [for (final i in s.institutes) AppSelectItem(jsStr(i['id']), display(i['year']))],
        onChanged: _onYearChange,
      ),
    );
    final batch = _labeled(
      'Batch',
      AppSelect<Object>(
        value: _selectedBatch,
        placeholder: 'Select Batches',
        enabled: _selectedYear != null,
        items: published.isEmpty
            ? const [AppSelectItem<Object>.message('__none__', 'No batches available', messagePadding: EdgeInsets.symmetric(vertical: 12))]
            : [
                for (final b in published)
                  if (b['exam_batch_id'] != null) AppSelectItem<Object>(b['exam_batch_id'] as Object, display(b['name'])),
              ],
        onChanged: _setBatch,
      ),
    );
    if (!context.isSm) return GapColumn(gap: 16, children: [language, cls, batch]);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(width: 192, child: language),
        const SizedBox(width: 16),
        Expanded(child: cls),
        const SizedBox(width: 16),
        Expanded(child: batch),
      ],
    );
  }

  /// `flex flex-col gap-1` + `<Label>`
  Widget _labeled(String label, Widget child) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [FieldLabel(label), const SizedBox(height: 4), child],
      );

  // ── student ──

  static const _tabs = [
    ('availableexams', 'Available Exams'),
    ('inprogress', 'In progress'),
    ('completed', 'Completed'),
  ];

  Widget _studentTabs(List<Json> examRows, ExamsState s) {
    final attempts = normalizeStudentAttempts(s.examattempts, examRows);
    // `hidden lg:flex justify-center mt-4` + `<TabsList class="w-full
    // max-w-lg h-12 p-1">`; below 1024px `lg:hidden px-4 mt-4` + a `h-12`
    // select (the kit's `data-[size=default]:h-9` wins over `h-12`).
    final selector = context.isLg
        ? Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 512),
                child: ExamTabs(
                  tabs: _tabs,
                  value: _activeExamTab,
                  onChanged: (v) => setState(() => _activeExamTab = v),
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: AppSelect<String>(
              value: _activeExamTab,
              placeholder: 'Select Exam Type',
              items: const [
                AppSelectItem('availableexams', 'Available Exams'),
                AppSelectItem('inprogress', 'In Progress'),
                AppSelectItem('completed', 'Completed'),
              ],
              onChanged: (v) => setState(() => _activeExamTab = v ?? _activeExamTab),
            ),
          );

    final Widget table = switch (_activeExamTab) {
      'inprogress' => _studentTable(
          listInProgressExams(attempts),
          attempts,
          emptyText: 'No exams in progress.',
          action: (exam) => _playButton('Resume', () => _startexam(exam['id'])),
        ),
      'completed' => _studentTable(
          listCompletedExams(attempts),
          attempts,
          emptyText: '',
          action: _completedActions,
        ),
      _ => _studentTable(
          listAvailableExams(examRows, attempts),
          attempts,
          emptyText: 'No available exams for the selected filters.',
          action: (exam) => _playButton('Start Exam', () => _startexam(exam['id'])),
        ),
    };

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        selector,
        const SizedBox(height: 8),
        Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: table),
      ],
    );
  }

  Widget _studentTable(
    List<Json> exams,
    List<Json> attempts, {
    required String emptyText,
    required Widget Function(Json exam) action,
  }) {
    // `<Card class="my-4 p-0 overflow-hidden"><Table class="min-w-[960px]">`;
    // the empty row is `text-center py-6 text-muted-foreground` (the
    // Completed tab has none, so only the header shows).
    return AppTable(
      minWidth: 960,
      fontSize: 14,
      emptyText: emptyText,
      emptyTextColor: context.mutedFgColor,
      emptyPadding: emptyText.isEmpty ? EdgeInsets.zero : const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      columns: const [
        AppTableColumn('Code', flex: 0.8),
        AppTableColumn('Name', flex: 1.4),
        AppTableColumn('Type', flex: 0.8),
        AppTableColumn('Status'),
        AppTableColumn('Attempts Left'),
        AppTableColumn('Duration', flex: 0.8),
        AppTableColumn('Start Time', flex: 1.5),
        AppTableColumn('End Time', flex: 1.5),
        AppTableColumn('Actions', flex: 1.3),
      ],
      rows: [
        for (final exam in exams)
          [
            Text(display(exam['code'])),
            Text(display(exam['name'])),
            Text(display(exam['exam_type'])),
            Text(display(exam['status'])),
            Text(display(listAttemptsLeft(attempts, exam['id'], maxAttemptsOf(exam)))),
            Text(display(exam['duration_minutes'])),
            Text(examTimeCell(exam, 'start_time')),
            Text(examTimeCell(exam, 'end_time')),
            action(exam),
          ],
      ],
    );
  }

  /// `<Button variant="outline" size="sm" class="inline-flex gap-2
  /// text-green-600">` with `bi-play-circle-fill` (`table .bi` = 18px).
  Widget _playButton(String label, VoidCallback onTap) => AppButton(
        variant: AppButtonVariant.outline,
        size: AppButtonSize.sm,
        foregroundColor: Tw.green600,
        onPressed: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(BootstrapIcons.play_circle_fill, size: 18),
            const SizedBox(width: 8),
            Flexible(child: Text(label, maxLines: 1, softWrap: false, overflow: TextOverflow.ellipsis)),
          ],
        ),
      );

  /// Completed tab: a play icon without a handler (`cursor-pointer
  /// hover:scale-110`) + RESULTS.
  Widget _completedActions(Json exam) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _HoverScaleIcon(icon: BootstrapIcons.play_circle_fill, color: Tw.green600),
          const SizedBox(width: 16),
          _linkButton(BootstrapIcons.file_text, 'RESULTS', Tw.blue600, () => _goToStudentResult(exam['id'])),
        ],
      );

  /// `<button class="text-*-600 font-medium hover:underline"><i/> LABEL</button>`
  Widget _linkButton(IconData icon, String label, Color color, VoidCallback onTap) => _HoverLink(
        icon: icon,
        label: label,
        color: color,
        onTap: onTap,
      );

  // ── staff ──

  Widget _staffTable(List<Json> exams, String role) {
    // `<div class="overflow-x-auto"><Table class="min-w-max">`; the empty row
    // is `text-center py-6 text-gray-500`.
    return AppTable(
      card: false,
      minWidth: 1000,
      fontSize: 14,
      emptyText: 'No exams found',
      emptyPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      columns: const [
        AppTableColumn('Language', flex: 0.9),
        AppTableColumn('Code'),
        AppTableColumn('Name', flex: 1.5),
        AppTableColumn('Type', flex: 0.8),
        AppTableColumn('Status', flex: 1.1),
        AppTableColumn('Duration', flex: 0.9),
        AppTableColumn('Marks', flex: 0.7),
        AppTableColumn('Actions', flex: 2.4),
      ],
      rows: [
        for (final exam in exams)
          [
            Text(localeLabel(exam['locale'])),
            Text(display(exam['code'])),
            Text(display(exam['name'])),
            Text(display(exam['exam_type'])),
            _statusPill(exam['status']),
            Text('${display(exam['duration_minutes'])}min'),
            Text(display(dig(exam, ['sections', 0, 'marks_per_question']) ?? '-')),
            _staffActions(exam, role),
          ],
      ],
    );
  }

  Widget _statusPill(Object? status) {
    final bg = switch (status) {
      'SCHEDULED' => Tw.blue400,
      'ARCHIVED' => Tw.orange400,
      'DRAFT' => Tw.gray400,
      _ => null,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(
        display(status),
        style: TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w600,
          color: bg == null ? null : Colors.white,
        ),
      ),
    );
  }

  Widget _staffActions(Json exam, String role) {
    final draft = exam['status'] == 'DRAFT';
    Widget draftOnly(IconData icon, Color color, VoidCallback onTap) => Opacity(
          opacity: draft ? 1 : 0.4,
          child: TableActionIcon(icon: icon, color: color, onTap: draft ? onTap : null),
        );
    return Wrap(
      spacing: 12,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        TableActionIcon(icon: BootstrapIcons.eye_fill, color: Tw.sky500, onTap: () => _viewexams(exam)),
        if (role == Role.instructor) draftOnly(BootstrapIcons.pencil_square, Tw.green600, () => _editexams(exam)),
        if (role == Role.instructor)
          draftOnly(BootstrapIcons.trash3_fill, Tw.red600, () => _openDeleteDialog(exam)),
        if (exam['status'] == 'SCHEDULED')
          _linkButton(BootstrapIcons.file_text, 'RESULTS', Tw.blue600, () => _goToExamResults(exam)),
        if (draft) _linkButton(BootstrapIcons.upload, 'PUBLISH', Tw.green600, () => _publishExam(exam['id'])),
      ],
    );
  }

  // ── delete dialog ──

  Widget _deleteDialog(BuildContext dialogCtx) {
    final name = jsOr(_examToDelete?['name'], 'this exam');
    // `<DialogContent class="max-w-md p-6">`: tailwind-merge drops the kit's
    // `max-w-[calc(100%-2rem)]`, so below 640px it is `w-full max-w-md`
    // (no side inset) and from 640px the kit's `sm:max-w-lg`.
    final wide = context.isSm;
    return AppDialogFrame(
      maxWidth: wide ? 512 : 448,
      insetPadding: wide ? const EdgeInsets.all(16) : const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Tw.red100, shape: BoxShape.circle),
            child: const Icon(BootstrapIcons.trash3_fill, size: 20, color: Tw.red600),
          ),
          const SizedBox(height: 12),
          // `text-gray-900` has no dark variant on the web.
          // The page's `text-lg` drops the kit's `leading-none` (28px line).
          const Text('Confirm Delete',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w600, color: Tw.gray900)),
          const SizedBox(height: 12),
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(text: 'Are you sure you want to delete '),
                TextSpan(
                  text: '${display(name)} ',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Tw.gray900),
                ),
                const TextSpan(text: '?\n'),
                const TextSpan(
                  text: 'This action cannot be undone.',
                  style: TextStyle(color: Tw.red500, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, height: 1.625, color: Tw.gray600),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100),
                child: AppButton(
                  label: 'No',
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.of(dialogCtx).pop(),
                ),
              ),
              const SizedBox(width: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 100),
                child: AppButton(
                  label: 'Yes',
                  backgroundColor: Tw.red600,
                  hoverBackgroundColor: Tw.red700,
                  foregroundColor: Colors.white,
                  onPressed: () => _confirmDelete(dialogCtx),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// A text button with an icon that underlines on hover.
class _HoverLink extends StatefulWidget {
  const _HoverLink({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_HoverLink> createState() => _HoverLinkState();
}

class _HoverLinkState extends State<_HoverLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: widget.color,
      decoration: _hover ? TextDecoration.underline : null,
      decorationColor: widget.color,
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // `table .bi { font-size: 18px }`, then a space.
            Icon(widget.icon, size: 18, color: widget.color),
            const SizedBox(width: 4),
            Text(widget.label, style: style),
          ],
        ),
      ),
    );
  }
}

/// `<i class="bi … cursor-pointer hover:scale-110 transition">` (18px in a
/// table).
class _HoverScaleIcon extends StatefulWidget {
  const _HoverScaleIcon({required this.icon, required this.color});
  final IconData icon;
  final Color color;

  @override
  State<_HoverScaleIcon> createState() => _HoverScaleIconState();
}

class _HoverScaleIconState extends State<_HoverScaleIcon> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedScale(
          scale: _hover ? 1.1 : 1,
          duration: const Duration(milliseconds: 150),
          child: Icon(widget.icon, size: 18, color: widget.color),
        ),
      );
}
