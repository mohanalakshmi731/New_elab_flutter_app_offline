import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/form_fields.dart';
import '../exams/exam_widgets.dart' show ExamFieldLabel, ExamInfoNote, ExamTabs;
import 'exam_manage_controller.dart';
import 'exam_manage_logic.dart';
import 'exam_manage_widgets.dart';

/// Port of `src/pages/exams/ViewExams.vue` (`/viewexams/:id`, [id] = the
/// route param): the exam's details, sections, (static) assigned students
/// and its attempts. Shows the store's previous `exams` / `examattempts`
/// until the requests return, like the web.
class ViewExamPage extends ConsumerStatefulWidget {
  const ViewExamPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ViewExamPage> createState() => _ViewExamPageState();
}

class _ViewExamPageState extends ConsumerState<ViewExamPage> {
  String _tab = 'details';

  ExamManageController get _ctrl => ref.read(examManageControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      try {
        await _ctrl.fetchExamById(widget.id);
      } catch (_) {}
    });
  }

  /// `onTabChange(tab)` — the Attempts tab (re)loads the attempts.
  Future<void> _onTabChange(String tab) async {
    if (tab == _tab) return;
    setState(() => _tab = tab);
    if (tab == 'attempts') {
      try {
        await _ctrl.fetchExamAttempts(widget.id);
      } catch (_) {}
    }
  }

  void _back() => context.go('/exams');

  void _examResults(Object? attemptId) => context.go('/results/${vueText(attemptId)}');

  void _editExam() {
    if (widget.id.isEmpty) return;
    context.go('/editexams/${widget.id}');
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(examManageControllerProvider);
    final exams = asMap(s.exams);
    final muted = mutedFg(context);

    final name = vueText(exams?['name']);
    final code = vueText(exams?['code']);
    // `flex items-center justify-between mb-4`; an empty `<h1>` / `<p>` has
    // no height.
    final header = Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (name.isNotEmpty)
                Text(name, style: const TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600)),
              if (code.isNotEmpty) Text(code, style: TextStyle(fontSize: 14, height: 20 / 14, color: muted)),
            ],
          ),
        ),
        AppButton(label: 'Edit Exam', onPressed: _editExam),
        const SizedBox(width: 12),
        // `variant="ghost" class="flex items-center gap-2"` + `bi-arrow-left`.
        AppButton(
          label: 'Back to Exams',
          icon: BootstrapIcons.arrow_left,
          iconSize: 14,
          variant: AppButtonVariant.ghost,
          onPressed: _back,
        ),
      ],
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 16),
          // `<Tabs>` (`flex flex-col gap-2`) + `<TabsList class="w-full h-12 p-1">`.
          ExamTabs(
            value: _tab,
            onChanged: _onTabChange,
            tabs: const [
              ('details', 'Details'),
              ('questions', 'Questions'),
              ('assignedstudents', 'Assigned Students'),
              ('attempts', 'Attempts'),
            ],
          ),
          const SizedBox(height: 8),
          switch (_tab) {
            'questions' => _questionsTab(exams),
            'assignedstudents' => _assignedStudentsTab(),
            'attempts' => _attemptsTab(s.examattempts),
            _ => _detailsTab(exams),
          },
        ],
      ),
    );
  }

  // ── Details ──────────────────────────────────────────────────────────────

  /// `grid grid-cols-N gap-y-6 gap-x-12`
  Widget _infoGrid(List<Widget> cells, int columns) {
    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += columns) {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var j = 0; j < columns; j++) ...[
            if (j > 0) const SizedBox(width: 48),
            Expanded(child: i + j < cells.length ? cells[i + j] : const SizedBox.shrink()),
          ],
        ],
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

  /// `<Label>` (`text-sm leading-none font-medium`) + a `font-medium` value.
  Widget _info(String label, Widget value, {bool mutedLabel = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ExamFieldLabel(label, color: mutedLabel ? mutedFg(context) : null),
          value,
        ],
      );

  Widget _value(String text) =>
      Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.5));

  /// The status pill (`SCHEDULED` blue, `ARCHIVED` orange, `DRAFT` gray).
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
        vueText(status),
        style: TextStyle(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: FontWeight.w600,
          color: bg == null ? null : Colors.white,
        ),
      ),
    );
  }

  Widget _detailsTab(Json? exams) {
    String when(String key) => jsTruthy(exams?[key]) ? enInMediumShort(exams![key]) : '-';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExmCard(
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: ExmCardTitle('Basic Information', primary: true),
            ),
            _infoGrid([
              _info('Exam Type', _value(vueText(exams?['exam_type'])), mutedLabel: true),
              _info('Duration', _value('${vueText(exams?['duration_minutes'])} minutes'), mutedLabel: true),
              _info('Max Attempts', _value(vueText(exams?['max_attempts'])), mutedLabel: true),
              _info(
                'Status',
                Align(alignment: Alignment.centerLeft, child: _statusPill(exams?['status'])),
                mutedLabel: true,
              ),
            ], 2),
          ],
        ),
        const SizedBox(height: 16),
        ExmCard(
          padding: const EdgeInsets.all(16),
          children: [
            const ExmCardTitle('Schedule', primary: true),
            if (jsTruthy(exams?['is_open_anytime']))
              const ExamInfoNote('This exam is open anytime - students can take it at their convenience')
            else
              _infoGrid([_value(when('start_time')), _value(when('end_time'))], 2),
          ],
        ),
        const SizedBox(height: 16),
        ExmCard(
          padding: const EdgeInsets.all(16),
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: ExmCardTitle('Association', primary: true),
            ),
            _infoGrid([
              _info('Batch', _value(vueText(dig(exams, const ['batch', 'name'])))),
              _info('Course', _value(vueText(dig(exams, const ['course', 'name'])))),
              _info('Subject', _value(vueText(dig(exams, const ['subject', 'name'])))),
            ], 3),
          ],
        ),
        // The last card's `mb-4`.
        const SizedBox(height: 16),
      ],
    );
  }

  // ── Questions ────────────────────────────────────────────────────────────

  /// `px-3 py-1 text-sm bg-muted rounded-full`
  Widget _chip(String text) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: mutedBg(context), borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: const TextStyle(fontSize: 14, height: 20 / 14)),
      );

  Widget _questionsTab(Json? exams) {
    final sections = asList(exams?['sections']);
    return ExmCard(
      padding: const EdgeInsets.all(16),
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ExmCardTitle('Exam Sections & Questions', primary: true),
        ),
        for (var index = 0; index < sections.length; index++)
          () {
            final section = asMap(sections[index]) ?? const <String, dynamic>{};
            final description = vueText(section['description']);
            return ExmCard(
              padding: const EdgeInsets.all(16),
              children: [
                // `<div class="font-medium">` + `<p class="text-gray-400 text-sm">`
                // (an empty `<p>` has no height).
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Section ${index + 1}: ${vueText(section['name'])}',
                        style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500)),
                    if (description.isNotEmpty)
                      Text(description, style: const TextStyle(fontSize: 14, height: 20 / 14, color: Tw.gray400)),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _chip('${vueText(section['question_count'])} questions'),
                    _chip('${vueText(section['marks_per_question'])} marks each'),
                  ],
                ),
              ],
            );
          }(),
      ],
    );
  }

  // ── Assigned Students ────────────────────────────────────────────────────

  Widget _assignedStudentsTab() {
    final muted = mutedFg(context);
    return ExmCard(
      padding: const EdgeInsets.all(16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Row(
            children: [
              const Expanded(child: ExmCardTitle('Assigned Students', primary: true)),
              AppButton(
                label: 'Assign Students',
                icon: BootstrapIcons.person_plus_fill,
                iconSize: 14,
                onPressed: _openAssignDialog,
              ),
            ],
          ),
        ),
        // Batch Assignment
        Container(
          padding: const EdgeInsets.all(16),
          // `bg-blue-50 border border-blue-300 rounded-md p-4 flex gap-4`
          decoration: BoxDecoration(
            color: Tw.blue50,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: Tw.blue300),
          ),
          child: Row(
            children: [
              const Icon(BootstrapIcons.people_fill, size: 30, color: Tw.blue500),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 4),
                      child: Text(
                        'Batch Assignment',
                        style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500),
                      ),
                    ),
                    Text.rich(
                      TextSpan(children: const [
                        TextSpan(text: 'All students in '),
                        TextSpan(text: 'Test Batch', style: TextStyle(fontWeight: FontWeight.w600)),
                        TextSpan(text: ' can take this exam'),
                      ]),
                      style: TextStyle(fontSize: 14, height: 20 / 14, color: muted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Individual Assignments
        ExmCard(
          padding: const EdgeInsets.all(16),
          children: [
            const ExmCardTitle('Individual Assignments (0)'),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 448),
              child: Text.rich(
                TextSpan(children: const [
                  TextSpan(text: 'No individual student assignments. Click '),
                  TextSpan(text: '“Assign Students”', style: TextStyle(fontWeight: FontWeight.w500)),
                  TextSpan(text: ' to add specific students.'),
                ]),
                style: TextStyle(fontSize: 14, height: 20 / 14, color: muted),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// The static "Assign Students to Exam" dialog (nothing is submitted on
  /// the web either): `<DialogContent class="sm:max-w-xl max-h-[90vh]">`
  /// holding a `<CardHeader>` and a `<CardContent>`, each with its own
  /// `px-6` inside the dialog's `p-6`.
  Future<void> _openAssignDialog() async {
    String? student;
    String? type;
    await showAppDialog<void>(
      context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) {
          final white = ctx.isDark ? null : Colors.white;
          // `<FormItem>` (`grid gap-2`) with `<Label class="mb-2">`.
          Widget item(String label, Widget child, {double gap = 16}) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [ExamFieldLabel(label), SizedBox(height: gap), child],
              );
          return AppDialogFrame(
            maxWidth: 576,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // CardTitle `mb-4` + the dialog's `gap-4`.
                  const Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: ExmCardTitle('Assign Students to Exam', primary: true),
                  ),
                  item(
                    'Select Students',
                    AppSelect<String>(
                      value: student,
                      placeholder: 'Select Students',
                      fillColor: white,
                      items: const [AppSelectItem('Student1', 'Students 1'), AppSelectItem('Student2', 'Students 2')],
                      onChanged: (v) => setLocal(() => student = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  item(
                    'Assignment Type',
                    AppSelect<String>(
                      value: type,
                      placeholder: 'Assignment  Type',
                      fillColor: white,
                      items: const [
                        AppSelectItem('individual', 'Individual'),
                        AppSelectItem('makeup', 'Makeup'),
                        AppSelectItem('batch', 'Batch'),
                      ],
                      onChanged: (v) => setLocal(() => type = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // `field-sizing-content min-h-16`: `rows` has no effect.
                  item('Notes (Optional)', const AppTextField(hint: 'Notes', maxLines: null), gap: 8),
                  // The form's `gap-4` + `mt-4`.
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AppButton(
                        label: 'Cancel',
                        variant: AppButtonVariant.outline,
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                      const SizedBox(width: 16),
                      // `type="submit"` on a form without a submit handler.
                      AppButton(label: 'Assign', onPressed: () {}),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Attempts ─────────────────────────────────────────────────────────────

  Widget _attemptsTab(List<dynamic> attempts) {
    return ExmCard(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            const Expanded(child: ExmCardTitle('Student Attempts', primary: true)),
            // No click handler on the web.
            AppButton(label: 'Refresh', icon: BootstrapIcons.arrow_clockwise, iconSize: 14, onPressed: () {}),
          ],
        ),
        // `<Card class="m-4 p-0">`
        Padding(
          padding: const EdgeInsets.all(16),
          child: ExamAttemptsTable(attempts: attempts, onView: _examResults),
        ),
      ],
    );
  }
}
