import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import 'exam_manage_controller.dart';
import 'exam_manage_logic.dart';
import 'exam_manage_widgets.dart';

/// Port of `src/pages/exams/ExamResults.vue` (`/results/:attemptId`,
/// [attemptId] = the route param): one attempt's score, answer counts and
/// per-question breakdown. Shows the store's previous `attemptexam` until
/// the request returns, like the web.
class ExamResultsPage extends ConsumerStatefulWidget {
  const ExamResultsPage({super.key, required this.attemptId});

  final String attemptId;

  @override
  ConsumerState<ExamResultsPage> createState() => _ExamResultsPageState();
}

class _ExamResultsPageState extends ConsumerState<ExamResultsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref
          .read(examManageControllerProvider.notifier)
          .fetchAttemptById(widget.attemptId)
          .catchError((Object _) => null);
    });
  }

  void _back() => context.go('/exams');

  @override
  Widget build(BuildContext context) {
    final attempt = ref.watch(examManageControllerProvider.select((s) => s.attemptexam));
    final a = asMap(attempt);
    final counts = attemptCounts(attempt);
    final questions = asList(a?['attempt_questions']);
    final muted = mutedFg(context);
    final columns = context.isLg ? 4 : (context.isSm ? 2 : 1);

    final header = Wrap(
      alignment: WrapAlignment.spaceBetween,
      spacing: 8,
      runSpacing: 8,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // `text-3xl font-semibold text-primary` (an empty `<p>` has no height).
            if (vueText(dig(a, const ['exam', 'name'])).isNotEmpty)
              Text(
                vueText(dig(a, const ['exam', 'name'])),
                style: TextStyle(
                  fontSize: 30,
                  height: 36 / 30,
                  fontWeight: FontWeight.w600,
                  color: context.colors.primary,
                ),
              ),
            Text('Exam Code: ${vueText(dig(a, const ['exam', 'code']))}', style: _gray500),
            Text(
              'Student: ${vueText(dig(a, const ['student', 'first_name']))} '
              '${vueText(dig(a, const ['student', 'last_name']))}',
              style: _gray500,
            ),
            Text('Email: ${vueText(dig(a, const ['student', 'email']))}', style: _gray500),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // `inline-block px-3 py-1 rounded bg-orange-400 text-white text-sm`
            // (`rounded` = 0.25rem in Tailwind 4).
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Tw.orange400, borderRadius: BorderRadius.circular(4)),
              child: Text(
                vueText(a?['status']),
                style: const TextStyle(fontSize: 14, height: 20 / 14, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            const Text('Score', style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600)),
            Text('${vueText(a?['total_score'])} / ${vueText(a?['max_score'])}',
                style: TextStyle(fontSize: 24, height: 32 / 24, color: context.colors.primary)),
            Text('${jsToFixed(jsNumberField(a, 'percentage'), 2)}%',
                style: TextStyle(fontSize: 14, height: 20 / 14, color: muted)),
          ],
        ),
      ],
    );

    final stats = [
      _stat('Total Questions', counts.total, null),
      _stat('Correct Answers', counts.correct, Tw.green500),
      _stat('Incorrect Answers', counts.incorrect, Tw.red500),
      _stat('Not Answered', counts.notAnswered, Tw.gray300),
    ];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExmCard(
            padding: const EdgeInsets.all(16),
            children: [
              SizedBox(width: double.infinity, child: header),
              _statGrid(stats, columns),
              ExmCard(
                padding: const EdgeInsets.all(24),
                children: [
                  // `<CardTitle class="mb-6 text-lg font-semibold">` (`text-lg`
                  // replaces `leading-none`: a 28px line) + a `ml-2 text-sm
                  // text-gray-400` span that keeps the semibold weight.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text.rich(
                      TextSpan(children: [
                        const TextSpan(text: 'Question Breakdown '),
                        const WidgetSpan(child: SizedBox(width: 8)),
                        TextSpan(
                          text: '(${counts.total} Questions)',
                          style: const TextStyle(fontSize: 14, color: Tw.gray400),
                        ),
                      ]),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 28 / 18),
                    ),
                  ),
                  for (var i = 0; i < questions.length; i++) _questionBlock(i, asMap(questions[i]) ?? const {}),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(alignment: Alignment.centerLeft, child: AppButton(label: 'Back', onPressed: _back)),
        ],
      ),
    );
  }

  static const _gray500 = TextStyle(fontSize: 14, height: 20 / 14, color: Tw.gray500);

  /// `<Card class="p-6">` with a muted label and a `text-3xl` number.
  Widget _stat(String label, int value, Color? color) => ExmCard(
        padding: const EdgeInsets.all(24),
        children: [
          Text(label, style: TextStyle(fontSize: 14, height: 20 / 14, color: mutedFg(context))),
          Text('$value', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600, color: color, height: 1.2)),
        ],
      );

  /// `grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6`
  Widget _statGrid(List<Widget> cells, int columns) {
    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += columns) {
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var j = 0; j < columns; j++) ...[
              if (j > 0) const SizedBox(width: 24),
              Expanded(child: i + j < cells.length ? cells[i + j] : const SizedBox.shrink()),
            ],
          ],
        ),
      ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 24),
          rows[i],
        ],
      ],
    );
  }

  /// One question (`mb-6`, then `<hr class="my-6">`).
  Widget _questionBlock(int index, Json q) {
    final dark = context.isDark;
    final muted = mutedFg(context);
    final question = asMap(q['question']);
    final response = asMap(q['response']);
    final finalScore = response?['final_score'];

    Widget body;
    if (question?['question_type'] == 'SAQ') {
      final answer = response?['answer_text'];
      body = Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Student Answer:', style: TextStyle(fontSize: 14, height: 20 / 14, color: muted)),
            const SizedBox(height: 8),
            // `<textarea rows="3" readonly class="border rounded-md p-2 bg-gray-100">`
            Container(
              height: 90,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Tw.gray100,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: dark ? AppColors.darkBorder : AppColors.border),
              ),
              child: SingleChildScrollView(
                child: SelectableText(jsTruthy(answer) ? jsStr(answer) : 'Not Answered',
                    style: const TextStyle(fontSize: 16, height: 1.5)),
              ),
            ),
          ],
        ),
      );
    } else {
      final selected = response?['selected_option_ids'];
      body = Padding(
        padding: const EdgeInsets.only(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Options:', style: TextStyle(fontSize: 14, height: 20 / 14, color: muted)),
            const SizedBox(height: 12),
            for (final (i, raw) in asList(question?['options']).indexed) ...[
              if (i > 0) const SizedBox(height: 8),
              _optionRow(asMap(raw) ?? const {}, selected),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // `rounded bg-blue-600 px-3 py-1 text-white text-sm font-semibold`
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: Tw.blue600, borderRadius: BorderRadius.circular(4)),
              child: Text('Q${index + 1}',
                  style: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    vueText(question?['stem']),
                    style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500),
                  ),
                  body,
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text.rich(
                      TextSpan(children: [
                        const TextSpan(text: 'Score: '),
                        TextSpan(
                          text: vueText(jsTruthy(finalScore) ? finalScore : 0),
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: scoreAboveZero(finalScore) ? Tw.green500 : Tw.red500,
                          ),
                        ),
                        TextSpan(text: ' / ${vueText(q['max_marks'])}'),
                      ]),
                      style: const TextStyle(fontSize: 14, height: 20 / 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // `<hr class="my-6">` inside the `mb-6` block.
        const SizedBox(height: 24),
        Container(height: 1, color: dark ? AppColors.darkBorder : AppColors.border),
        const SizedBox(height: 48),
      ],
    );
  }

  /// An option chip: green when correct, red when picked but wrong (the
  /// `bg-gray-200` of wrong options loses to `bg-red-600` in the CSS),
  /// gray otherwise; then a check / cross mark.
  Widget _optionRow(Json opt, Object? selected) {
    final correct = jsTruthy(opt['is_correct']);
    final picked = selectedIncludes(selected, opt['id']);
    final Color bg;
    Color? fg;
    if (correct) {
      bg = Tw.green500;
      fg = Colors.white;
    } else if (picked) {
      bg = Tw.red600;
      fg = Colors.white;
    } else {
      bg = Tw.gray200;
    }
    return Row(
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
            child: Text('${vueText(opt['option_label'])}. ${vueText(opt['option_text'])}',
                style: TextStyle(fontSize: 14, height: 20 / 14, color: fg)),
          ),
        ),
        if (correct) ...[
          const SizedBox(width: 8),
          const Icon(BootstrapIcons.check2, size: 16, color: Tw.green500),
        ] else if (picked) ...[
          const SizedBox(width: 8),
          const Icon(BootstrapIcons.x, size: 16, color: Tw.red600),
        ],
      ],
    );
  }
}
