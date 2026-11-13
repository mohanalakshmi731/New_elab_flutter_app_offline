part of 'new_exams_page.dart';

/// The main exam list view of `newexams.vue`.
extension _NewExamsList on _NewExamsPageState {
  Widget _listView() {
    final role = ref.read(sessionProvider).role;
    final student = role == Role.student;
    final s = ref.read(examsControllerProvider);

    final header = Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 12,
      runSpacing: 12,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Exams',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: -0.75, height: 1.25)),
            const SizedBox(height: 4),
            Text(
              student
                  ? 'Your exams — available, in-progress, and completed.'
                  : 'Manage and review all scheduled exams.',
              style: TextStyle(fontSize: 14, color: context.exMutedFg),
            ),
          ],
        ),
        if (!student && role != Role.institute)
          _CreateExamButton(onPressed: () => _set(() => _currentView = 'create')),
      ],
    );

    return GapColumn(
      gap: 20,
      children: [
        header,
        if (!student) _filters(s),
        if (student) _studentTabBar(),
        if (_loading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 64),
            child: Column(
              children: [
                const _RingSpinner(),
                const SizedBox(height: 12),
                Text('Loading exams…', style: TextStyle(fontSize: 14, color: context.exMutedFg)),
              ],
            ),
          )
        else if (student)
          _studentGrid()
        else
          _staffGrid(role),
      ],
    );
  }

  // ── filters ──

  Widget _filterLabel(String text, Widget child) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            text.toUpperCase(),
            style: TextStyle(
                fontSize: 10, height: 1.5, fontWeight: FontWeight.w700, letterSpacing: 1, color: context.exMutedFg),
          ),
          const SizedBox(height: 6),
          child,
        ],
      );

  /// `<SelectTrigger class="h-10 rounded-xl border bg-card">` — the kit's
  /// `data-[size=default]:h-9` beats `h-10`, `dark:bg-input/30` beats
  /// `bg-card` in dark mode, and the trigger stays `w-fit`.
  Widget _fitSelect<T>(AppSelect<T> Function(Color? fill) build, String label) => _FitWidth(
        label: label,
        child: build(context.isDark ? null : AppColors.card),
      );

  String _selectLabel<T>(List<AppSelectItem<T>> items, T value, String placeholder) {
    for (final it in items) {
      if (!it.isLabel && it.value == value) return it.label;
    }
    return placeholder;
  }

  Widget _filters(ExamsState s) {
    final noClass = _selectedYear.isEmpty || _selectedYear == 'all';
    final published = [for (final b in s.batches) if (b['status'] == 'published') b];
    final yearItems = [
      const AppSelectItem('all', 'All Classes'),
      for (final inst in s.institutes) AppSelectItem(jsStr(inst['id']), display(inst['year'])),
    ];
    final cls = _filterLabel(
      'Class',
      _fitSelect<String>(
        (fill) => AppSelect<String>(
          value: _selectedYear,
          placeholder: 'All Classes',
          radius: 20,
          fillColor: fill,
          items: yearItems,
          onChanged: _onYearChange,
        ),
        _selectLabel(yearItems, _selectedYear, 'All Classes'),
      ),
    );
    final batchPlaceholder = noClass ? 'Select a class first' : 'All Batches';
    final batchItems = [
      const AppSelectItem<Object>('all', 'All Batches'),
      if (published.isEmpty)
        const AppSelectItem<Object>.message('__none__', 'No batches available', messagePadding: EdgeInsets.symmetric(vertical: 10), messageFontSize: 12)
      else
        for (final b in published)
          if (b['exam_batch_id'] != null) AppSelectItem<Object>(b['exam_batch_id'] as Object, display(b['name'])),
    ];
    final batch = _filterLabel(
      'Batch',
      _fitSelect<Object>(
        (fill) => AppSelect<Object>(
          value: _selectedBatch,
          placeholder: batchPlaceholder,
          enabled: !noClass,
          radius: 20,
          fillColor: fill,
          items: batchItems,
          onChanged: (v) => _setBatch(v ?? 'all'),
        ),
        _selectLabel(batchItems, _selectedBatch, batchPlaceholder),
      ),
    );
    return LayoutBuilder(
      builder: (context, c) => c.maxWidth >= 312
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Expanded(child: cls), const SizedBox(width: 12), Expanded(child: batch)],
            )
          : GapColumn(gap: 12, children: [cls, batch]),
    );
  }

  // ── student ──

  List<(String, String, int)> get _studentTabs => [
        ('available', 'Available', _availableExams.length),
        ('inprogress', 'In Progress', _inProgressExams.length),
        ('completed', 'Completed', _completedExams.length),
      ];

  Widget _studentTabBar() {
    final tabs = _studentTabs;
    if (!context.isSm) {
      final items = [
        AppSelectItem('available', 'Available (${tabs[0].$3})'),
        AppSelectItem('inprogress', 'In Progress (${tabs[1].$3})'),
        AppSelectItem('completed', 'Completed (${tabs[2].$3})'),
      ];
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 280),
          child: _fitSelect<String>(
            (fill) => AppSelect<String>(
              value: _activeTab,
              radius: 20,
              fillColor: fill,
              items: items,
              onChanged: (v) => _set(() => _activeTab = v ?? _activeTab),
            ),
            _selectLabel(items, _activeTab, ''),
          ),
        ),
      );
    }
    final dark = context.isDark;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(color: context.exMuted, borderRadius: BorderRadius.circular(16)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              () {
                final (key, label, count) = tabs[i];
                return _TabButton(
                  label: label,
                  count: count,
                  active: _activeTab == key,
                  dark: dark,
                  onTap: () => _set(() => _activeTab = key),
                );
              }(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _studentGrid() {
    final exams = _activeTabExams;
    if (exams.isEmpty) {
      return _EmptyState(
        title: 'No $_activeTabLabel Exams',
        text: switch (_activeTab) {
          'available' => 'You have no exams available right now.',
          'inprogress' => 'You have no exams in progress.',
          _ => "You haven't completed any exams yet.",
        },
      );
    }
    return _AutoFillGrid(children: [for (final exam in exams) _studentCard(exam)]);
  }

  Widget _cardTop(Json exam) => Padding(
        padding: const EdgeInsets.only(top: 2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Wrap(spacing: 6, runSpacing: 6, children: [
                _StatusPill(exam['status']),
                _Pill(display(exam['exam_type']), bg: Tw.sky100, fg: Tw.sky700),
              ]),
            ),
            const SizedBox(width: 8),
            _Pill(
              exam['locale'] == 'te' ? 'Telugu' : 'English',
              bg: context.exMuted,
              fg: context.exMutedFg,
              weight: FontWeight.w600,
            ),
          ],
        ),
      );

  Widget _cardBody(Json exam) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: context.exMuted, borderRadius: BorderRadius.circular(4)),
            child: Text(
              display(exam['code']),
              style: TextStyle(
                fontSize: 10,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: context.exMutedFg,
                fontFamily: 'monospace',
                fontFamilyFallback: const ['Consolas', 'Menlo', 'Courier New'],
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            display(exam['name']),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.375),
          ),
          if (jsTruthy(exam['description'])) ...[
            const SizedBox(height: 4),
            Text(
              display(exam['description']),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, height: 1.375, color: context.exMutedFg),
            ),
          ],
        ],
      );

  /// The `border-t pt-2.5` schedule line (or "Open anytime"); `null` when
  /// neither applies.
  Widget? _cardTime(Json exam) {
    final open = jsTruthy(exam['is_open_anytime']);
    if (!open && !jsTruthy(exam['start_time'])) return null;
    final color = open ? Tw.emerald600 : context.exMutedFg;
    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: context.exBorder))),
      child: Row(
        children: [
          Icon(open ? BootstrapIcons.clock : BootstrapIcons.calendar, size: 11, color: color),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              open ? 'Open anytime' : '${fmtDateTimeEnIn(exam['start_time'])} — ${fmtDateTimeEnIn(exam['end_time'])}',
              style: TextStyle(fontSize: 11, height: 1.5, color: color),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statLine(IconData icon, String text) => Row(
        children: [
          Icon(icon, size: 12, color: context.exMutedFg.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Expanded(child: Text(text, style: TextStyle(fontSize: 12, height: 16 / 12, color: context.exMutedFg))),
        ],
      );

  Widget _studentCard(Json exam) {
    final left = _getAttemptsLeft(exam['id'], maxAttemptsOf(exam));
    final time = _cardTime(exam);
    final duration = jsTruthy(exam['duration_minutes']) ? '${display(exam['duration_minutes'])} min' : '—';
    return _ExamTile(
      status: exam['status'],
      content: [
        _cardTop(exam),
        _cardBody(exam),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statLine(BootstrapIcons.clock, duration),
            const SizedBox(height: 6),
            _statLine(BootstrapIcons.person, display(jsOr(dig(exam, ['batch', 'name']), '—'))),
            const SizedBox(height: 6),
            _statLine(BootstrapIcons.activity, '${display(left)} attempt(s) left'),
          ],
        ),
        ?time,
      ],
      actions: [
        if (_activeTab == 'available')
          _ChipButton(
            label: 'Start Exam',
            icon: BootstrapIcons.play_fill,
            bg: Tw.emerald100,
            hoverBg: Tw.emerald200,
            fg: Tw.emerald800,
            hPad: 14,
            onTap: () => _startexam(exam['id']),
          )
        else if (_activeTab == 'inprogress')
          _ChipButton(
            label: 'Resume',
            icon: BootstrapIcons.play_fill,
            bg: Tw.sky100,
            hoverBg: Tw.sky200,
            fg: Tw.sky800,
            hPad: 14,
            onTap: () => _startexam(exam['id']),
          )
        else if (_activeTab == 'completed') ...[
          _ChipButton(
            label: 'View Results',
            icon: BootstrapIcons.file_earmark_text,
            bg: Tw.indigo100,
            hoverBg: Tw.indigo200,
            fg: Tw.indigo800,
            hPad: 14,
            onTap: () => _openAttempts(exam),
          ),
          if (hasAttemptsLeft(left))
            _ChipButton(
              label: 'Retry',
              bg: Tw.sky100,
              hoverBg: Tw.sky200,
              fg: Tw.sky800,
              hPad: 14,
              onTap: () => _startexam(exam['id']),
            ),
        ],
      ],
    );
  }

  // ── staff ──

  Widget _staffGrid(String role) {
    final exams = newFilteredExams(_exams, role);
    if (exams.isEmpty) {
      return _EmptyState(
        title: 'No Exams Found',
        text: 'No exams match your current filters. Try adjusting or create a new exam.',
        action: role != Role.institute
            ? _CreateExamButton(shadow: false, onPressed: () => _set(() => _currentView = 'create'))
            : null,
      );
    }
    return _AutoFillGrid(children: [for (final exam in exams) _staffCard(exam, role)]);
  }

  Widget _statTile(Widget value, String label) => Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: context.exMuted.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, height: 1),
              child: value,
            ),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(fontSize: 10, height: 1.5, color: context.exMutedFg)),
          ],
        ),
      );

  Widget _staffCard(Json exam, String role) {
    final draft = exam['status'] == 'DRAFT';
    final id = jsStr(exam['id']);
    final publishing = _publishing == id;
    final time = _cardTime(exam);
    final duration = exam['duration_minutes'];
    final courseName = dig(exam, ['course', 'name']);
    final batchName = dig(exam, ['batch', 'name']);
    return _ExamTile(
      status: exam['status'],
      content: [
        _cardTop(exam),
        _cardBody(exam),
        Wrap(spacing: 6, runSpacing: 6, children: [
          if (jsTruthy(courseName))
            _MetaPill(display(courseName), bg: Tw.indigo50, fg: Tw.indigo700),
          if (jsTruthy(batchName)) _MetaPill(display(batchName), bg: Tw.violet50, fg: Tw.violet700),
        ]),
        Row(
          children: [
            Expanded(
              child: _statTile(
                Text.rich(TextSpan(text: display(duration ?? '—'), children: [
                  if (jsTruthy(duration))
                    const TextSpan(text: 'm', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ])),
                'Duration',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: _statTile(Text(display(exam['max_attempts'] ?? '—')), 'Attempts')),
            const SizedBox(width: 8),
            Expanded(
              child: _statTile(
                Text(display(dig(exam, ['sections', 0, 'marks_per_question']) ?? '—')),
                'Marks/Q',
              ),
            ),
          ],
        ),
        ?time,
      ],
      actions: [
        _SquareIconButton(
          icon: BootstrapIcons.eye,
          bg: Tw.blue100,
          hoverBg: Tw.blue200,
          fg: Tw.blue800,
          tooltip: 'Preview',
          onTap: () => _openPreview(exam),
        ),
        if (role != Role.institute)
          _SquareIconButton(
            icon: BootstrapIcons.pencil_square,
            bg: draft ? Tw.emerald100 : context.exMuted,
            hoverBg: draft ? Tw.emerald200 : context.exMuted,
            fg: draft ? Tw.emerald800 : context.exMutedFg,
            tooltip: 'Edit (DRAFT only)',
            onTap: draft ? () => _editExam(exam) : null,
          ),
        if (role != Role.institute)
          _SquareIconButton(
            icon: BootstrapIcons.trash,
            bg: draft ? Tw.rose100 : context.exMuted,
            hoverBg: draft ? Tw.rose200 : context.exMuted,
            fg: draft ? Tw.rose800 : context.exMutedFg,
            tooltip: 'Delete (DRAFT only)',
            onTap: draft ? () => _openDeleteDialog(exam) : null,
          ),
        if (role != Role.institute && draft)
          Opacity(
            opacity: publishing ? 0.6 : 1,
            child: _ChipButton(
              label: publishing ? '…' : 'Publish',
              bg: publishing ? context.exMuted : Tw.emerald100,
              hoverBg: publishing ? context.exMuted : Tw.emerald200,
              fg: publishing ? context.exMutedFg : Tw.emerald800,
              leading: publishing
                  ? AppSpinner(size: 12, color: context.exMutedFg)
                  : const Icon(BootstrapIcons.cloud_upload, size: 12, color: Tw.emerald800),
              onTap: publishing ? null : () => _publishExam(id),
            ),
          ),
        if (const ['SCHEDULED', 'ONGOING', 'COMPLETED'].contains(exam['status']))
          _ChipButton(
            label: 'Results',
            icon: BootstrapIcons.file_earmark_text,
            bg: Tw.indigo100,
            hoverBg: Tw.indigo200,
            fg: Tw.indigo800,
            onTap: () => _openAttempts(exam),
          ),
      ],
    );
  }
}

/// `text-[11px] font-semibold px-2 py-0.5 rounded-lg` course / batch pills.
class _MetaPill extends StatelessWidget {
  const _MetaPill(this.text, {required this.bg, required this.fg});
  final String text;
  final Color bg;
  final Color fg;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(16)),
        child: Text(text, style: TextStyle(fontSize: 11, height: 16 / 11, fontWeight: FontWeight.w600, color: fg)),
      );
}

/// A student tab: `inline-flex items-center gap-2 px-4 py-2 rounded-xl
/// text-sm font-semibold transition-all`; active `bg-card text-foreground
/// shadow-sm`, else `text-muted-foreground hover:text-foreground`.
class _TabButton extends StatefulWidget {
  const _TabButton({
    required this.label,
    required this.count,
    required this.active,
    required this.dark,
    required this.onTap,
  });
  final String label;
  final int count;
  final bool active;
  final bool dark;
  final VoidCallback onTap;

  @override
  State<_TabButton> createState() => _TabButtonState();
}

class _TabButtonState extends State<_TabButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? context.exCard : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: active ? AppShadows.sm : const [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  fontWeight: FontWeight.w600,
                  color: active || _hover ? context.exFg : context.exMutedFg,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: active ? Tw.sky100 : (widget.dark ? AppColors.darkBorder : AppColors.border),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${widget.count}',
                  style: TextStyle(
                    fontSize: 11,
                    height: 16 / 11,
                    fontWeight: FontWeight.w700,
                    color: active ? Tw.sky700 : context.exMutedFg,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
