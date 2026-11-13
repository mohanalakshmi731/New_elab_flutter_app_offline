part of 'new_exams_page.dart';

/// The `create`, `attempts` and `result` views of `newexams.vue`.
extension _NewExamsDetail on _NewExamsPageState {
  void _toList() => _set(() => _currentView = 'list');
  void _toAttempts() => _set(() => _currentView = 'attempts');

  // ── CREATE ──

  Widget _createView() {
    return GapColumn(
      gap: 20,
      children: [
        _ViewHeader(
          crumbs: [('Exams', _toList)],
          current: 'Create Exam',
          title: 'Create Exam',
          subtitle: 'Fill in the details below to create a new exam.',
          backLabel: 'Back to List',
          onBack: _toList,
        ),
        ExamCard(
          clip: true,
          child: GapColumn(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: context.exMuted.withValues(alpha: 0.4),
                  border: Border(bottom: BorderSide(color: context.exBorder)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(color: Tw.cyan100, borderRadius: BorderRadius.circular(20)),
                      child: const Icon(BootstrapIcons.file_earmark_plus, size: 18, color: Tw.cyan600),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('New Exam',
                              style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w700)),
                          Text('Complete all required fields to schedule the exam.',
                              style: TextStyle(fontSize: 12, height: 16 / 12, color: context.exMutedFg)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: ExamCreateView(onExamCreated: _handleExamCreated),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── ATTEMPTS ──

  Widget _attemptsView() {
    final attempts = examMaps(ref.read(examsControllerProvider).examattempts);
    return GapColumn(
      gap: 20,
      children: [
        _ViewHeader(
          crumbs: [('Exams', _toList)],
          current: 'Attempts',
          title: display(_selectedExam?['name']),
          subtitle: 'Exam Code: ${display(_selectedExam?['code'])}',
          backLabel: 'Back to Exams',
          onBack: _toList,
        ),
        ExamCard(
          clip: true,
          child: GapColumn(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: context.exBorder))),
                child: const Text('Student Attempts',
                    style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600)),
              ),
              _AttemptsTable(
                loading: _loadingAttempts,
                attempts: attempts,
                loadingResult: _loadingResult,
                onView: _viewResult,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── RESULT ──

  Widget _resultView() {
    final a = _selectedAttempt;
    final total = resultTotalQuestions(a);
    final muted = context.exMutedFg;

    Widget tile(String label, int value, {Color? bg, Color? fg}) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bg ?? context.exMuted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.exBorder),
          ),
          child: Column(
            children: [
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, height: 16 / 12, color: muted)),
              const SizedBox(height: 4),
              Text('$value', style: TextStyle(fontSize: 30, height: 36 / 30, fontWeight: FontWeight.w700, color: fg)),
            ],
          ),
        );

    final tiles = [
      tile('Total Questions', total),
      // `bg-green-50` / `bg-red-50` have no dark variant on the web.
      tile('Correct', resultCorrect(a), bg: Tw.green50, fg: Tw.green600),
      tile('Incorrect', resultIncorrect(a), bg: Tw.red50, fg: Tw.red500),
      tile('Not Answered', resultNotAnswered(a), fg: muted),
    ];
    final cols = context.isSm ? 4 : 2;
    final grid = GapColumn(
      gap: 12,
      children: [
        for (var i = 0; i < tiles.length; i += cols)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var j = 0; j < cols; j++) ...[
                  if (j > 0) const SizedBox(width: 12),
                  Expanded(child: tiles[i + j]),
                ],
              ],
            ),
          ),
      ],
    );

    final student = asMap(a?['student']);
    final summary = Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 16,
      runSpacing: 16,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${display(student?['first_name'])} ${display(student?['last_name'])}',
                style: const TextStyle(fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w600)),
            Text(display(student?['email']), style: TextStyle(fontSize: 14, height: 20 / 14, color: muted)),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            _BareBadge(display(a?['status']),
                bg: Tw.orange100, fg: Tw.orange700, border: Tw.orange200, fontSize: 16),
            const SizedBox(height: 4),
            Text(
              '${display(a?['total_score'])} / ${display(a?['max_score'])}',
              style: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w700, color: context.colors.primary),
            ),
            const SizedBox(height: 4),
            Text('${percentFixed2(a)}%', style: TextStyle(fontSize: 14, height: 20 / 14, color: muted)),
          ],
        ),
      ],
    );

    final questions = examMaps(a?['attempt_questions']);
    final breakdown = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text.rich(
          TextSpan(text: 'Question Breakdown', children: [
            TextSpan(
              text: ' ($total Questions)',
              style: TextStyle(color: muted, fontWeight: FontWeight.w400),
            ),
          ]),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < questions.length; i++)
          Padding(padding: const EdgeInsets.only(bottom: 24), child: _questionBlock(questions[i], i)),
      ],
    );

    return GapColumn(
      gap: 20,
      children: [
        _ViewHeader(
          crumbs: [('Exams', _toList), ('Attempts', _toAttempts)],
          current: 'Result',
          title: display(dig(a, ['exam', 'name'])),
          subtitle: 'Exam Code: ${display(dig(a, ['exam', 'code']))}',
          backLabel: 'Back to Attempts',
          onBack: _toAttempts,
        ),
        ExamCard(
          padding: const EdgeInsets.all(20),
          child: GapColumn(
            children: [
              Padding(padding: const EdgeInsets.only(bottom: 20), child: summary),
              Padding(padding: const EdgeInsets.only(bottom: 24), child: grid),
              breakdown,
            ],
          ),
        ),
      ],
    );
  }

  Widget _questionBlock(Json q, int index) {
    final muted = context.exMutedFg;
    final question = asMap(q['question']);
    final response = asMap(q['response']);
    final score = jsOr(response?['final_score'], 0);
    final positive = jsNum(score) > 0;

    final Widget answer;
    if (question?['question_type'] == 'SAQ') {
      answer = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Student Answer:', style: TextStyle(fontSize: 12, height: 16 / 12, color: muted)),
          const SizedBox(height: 8),
          Container(
            // rows="3": 3 × 20px lines + p-2 + border.
            height: 3 * 20 + 16 + 2,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.exMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: context.exBorder),
            ),
            child: SingleChildScrollView(
              child: SelectableText(
                display(jsOr(response?['answer_text'], 'Not Answered')),
                style: TextStyle(fontSize: 14, height: 20 / 14, color: context.exFg),
              ),
            ),
          ),
        ],
      );
    } else {
      final options = examMaps(question?['options']);
      answer = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < options.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _optionRow(q, options[i]),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Tw.blue600, borderRadius: BorderRadius.circular(16)),
              child: Text('Q${index + 1}',
                  style: const TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(display(question?['stem']),
                      style: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 12),
                  answer,
                  const SizedBox(height: 12),
                  Text.rich(
                    TextSpan(text: 'Score: ', children: [
                      TextSpan(
                        text: display(score),
                        style: TextStyle(fontWeight: FontWeight.w600, color: positive ? Tw.green600 : Tw.red500),
                      ),
                      TextSpan(text: ' / ${display(q['max_marks'])}'),
                    ]),
                    style: const TextStyle(fontSize: 14, height: 20 / 14),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Divider(height: 1, thickness: 1, color: context.exBorder),
      ],
    );
  }

  Widget _optionRow(Json q, Json opt) {
    final correct = jsTruthy(opt['is_correct']);
    final selected = optionSelected(q, opt['id']);
    final (bg, fg) = correct
        ? (Tw.green500, Colors.white)
        : selected
            ? (Tw.red500, Colors.white)
            : (context.exMuted, context.exMutedFg);
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
            child: Text(
              '${display(opt['option_label'])}. ${display(opt['option_text'])}',
              style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: fg),
            ),
          ),
        ),
        if (correct || selected) ...[
          const SizedBox(width: 8),
          LucideIcon(correct ? Lucide.check : Lucide.x,
              size: 14, strokeWidth: 3, color: correct ? Tw.green500 : Tw.red500),
        ],
      ],
    );
  }
}

/// The attempts `<Table>`: header with the global `thead th` primary
/// colour, a spinner row while loading, "No attempts found" when empty.
class _AttemptsTable extends StatelessWidget {
  const _AttemptsTable({
    required this.loading,
    required this.attempts,
    required this.loadingResult,
    required this.onView,
  });

  final bool loading;
  final List<Json> attempts;
  final String? loadingResult;
  final ValueChanged<String> onView;

  static const _cols = [
    ('Student', 2.2),
    ('Attempt', 0.8),
    ('Score', 1.0),
    ('Status', 1.1),
    ('Started', 1.6),
    ('Submitted', 1.6),
    ('Actions', 0.8),
  ];

  @override
  Widget build(BuildContext context) {
    final border = context.exBorder;
    final muted = context.exMutedFg;

    Widget row(List<Widget> cells, {bool header = false, bool last = false}) {
      final content = Container(
          constraints: BoxConstraints(minHeight: header ? 40 : 44),
          decoration: BoxDecoration(
            color: header ? context.colors.primary : null,
            border: last ? null : Border(bottom: BorderSide(color: border)),
          ),
          child: Row(
            children: [
              for (var i = 0; i < _cols.length; i++)
                Expanded(
                  flex: (_cols[i].$2 * 100).round(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: header ? 16 : 8, vertical: 8),
                    child: Align(
                      alignment: i == _cols.length - 1 ? Alignment.centerRight : Alignment.centerLeft,
                      child: cells[i],
                    ),
                  ),
                ),
            ],
          ),
        );
      // `hover:bg-muted/30 transition-colors`
      return header ? content : _HoverRow(child: content);
    }

    final header = row([
      for (final (label, _) in _cols)
        Text(label,
            style: TextStyle(
                fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: context.colors.onPrimary)),
    ], header: true);

    final List<Widget> body;
    if (loading) {
      body = [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppSpinner(size: 16, color: muted),
              const SizedBox(width: 8),
              Text('Loading attempts…', style: TextStyle(fontSize: 14, height: 20 / 14, color: muted)),
            ],
          ),
        ),
      ];
    } else if (attempts.isEmpty) {
      body = [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 40),
          child: Text('No attempts found',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 20 / 14, color: muted)),
        ),
      ];
    } else {
      body = [
        for (var i = 0; i < attempts.length; i++) row(_cells(context, attempts[i]), last: i == attempts.length - 1),
      ];
    }

    return LayoutBuilder(
      builder: (context, c) {
        final width = math.max(c.maxWidth.isFinite ? c.maxWidth : 820.0, 820.0);
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [header, ...body]),
          ),
        );
      },
    );
  }

  List<Widget> _cells(BuildContext context, Json attempt) {
    final muted = context.exMutedFg;
    final student = asMap(attempt['student']);
    final status = attempt['status'];
    final (bg, fg) = switch (status) {
      'SUBMITTED' => (Tw.green50, Tw.green700),
      'IN_PROGRESS' => (Tw.blue50, Tw.blue700),
      _ => (context.exMuted, muted),
    };
    final id = jsStr(attempt['id']);
    // `loadingResult === attempt.id` compares a string with the raw id, so
    // the spinner only shows for string ids (kept); `:disabled` uses String().
    final spinning = loadingResult != null && loadingResult == attempt['id'];
    final disabled = loadingResult == id;
    return [
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${display(student?['first_name'])} ${display(student?['last_name'])}',
              style: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500)),
          Text(display(student?['email']), style: TextStyle(fontSize: 12, height: 16 / 12, color: muted)),
        ],
      ),
      Text(display(attempt['attempt_number']), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${display(attempt['total_score'])} / ${display(attempt['max_score'])}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text('${percentTimes100(attempt)}%', style: TextStyle(fontSize: 12, color: muted)),
        ],
      ),
      _BareBadge(display(status), bg: bg, fg: fg),
      Text(jsTruthy(attempt['start_time']) ? toLocaleStringEnIn(attempt['start_time']) : '—',
          style: TextStyle(fontSize: 14, color: muted)),
      Text(jsTruthy(attempt['end_time']) ? toLocaleStringEnIn(attempt['end_time']) : '—',
          style: TextStyle(fontSize: 14, color: muted)),
      AppButton(
        variant: AppButtonVariant.ghost,
        size: AppButtonSize.icon,
        height: 32,
        tooltip: 'View Result',
        foregroundColor: Tw.blue600,
        hoverForegroundColor: Tw.blue700,
        // `dark:hover:bg-accent/50` from the kit still wins in dark mode.
        hoverBackgroundColor: context.isDark ? AppColors.accent.withValues(alpha: 0.5) : Tw.blue50,
        onPressed: disabled ? null : () => onView(id),
        child: spinning ? const AppSpinner(size: 16, color: Tw.blue600) : const Icon(BootstrapIcons.eye, size: 16),
      ),
    ];
  }
}

/// `<TableRow class="hover:bg-muted/30 transition-colors">`
class _HoverRow extends StatefulWidget {
  const _HoverRow({required this.child});
  final Widget child;

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          color: _hover ? context.exMuted.withValues(alpha: 0.3) : Colors.transparent,
          child: widget.child,
        ),
      );
}
