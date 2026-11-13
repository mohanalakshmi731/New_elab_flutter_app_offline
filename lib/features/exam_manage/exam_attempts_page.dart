import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/json.dart';
import '../../widgets/app_button.dart';
import 'exam_manage_controller.dart';
import 'exam_manage_logic.dart';
import 'exam_manage_widgets.dart';

/// Port of `src/pages/exams/ExamAttempts.vue` (`/examattempts/:id`, [id] =
/// the route param): the exam's name / code and its student attempts.
/// Shows the store's previous `exams` / `examattempts` until the requests
/// return, like the web.
class ExamAttemptsPage extends ConsumerStatefulWidget {
  const ExamAttemptsPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<ExamAttemptsPage> createState() => _ExamAttemptsPageState();
}

class _ExamAttemptsPageState extends ConsumerState<ExamAttemptsPage> {
  ExamManageController get _ctrl => ref.read(examManageControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(_mounted);
  }

  /// `mounted()` — the attempts are requested once the exam has loaded.
  Future<void> _mounted() async {
    try {
      await _ctrl.fetchExamById(widget.id);
    } catch (_) {
      return;
    }
    if (!mounted) return;
    _ctrl.fetchExamAttempts(widget.id).catchError((Object _) => null);
  }

  void _examResults(Object? attemptId) => context.go('/results/${vueText(attemptId)}');

  void _back() => context.go('/exams');

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(examManageControllerProvider);
    final exams = asMap(s.exams);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // `flex justify-between mb-4`; an empty `<p class="text-2xl">` has
          // no height.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (vueText(exams?['name']).isNotEmpty)
                      Text(
                        vueText(exams?['name']),
                        style: const TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600),
                      ),
                    Text('Exam Code: ${vueText(exams?['code'])}',
                        style: const TextStyle(fontSize: 14, height: 20 / 14, color: Tw.gray500)),
                  ],
                ),
              ),
              // `variant="ghost" class="flex items-center gap-2"` + `bi-arrow-left`.
              AppButton(
                label: 'Back to List',
                icon: BootstrapIcons.arrow_left,
                iconSize: 14,
                variant: AppButtonVariant.ghost,
                onPressed: _back,
              ),
            ],
          ),
          const SizedBox(height: 16),
          ExmCard(
            padding: const EdgeInsets.all(16),
            children: [
              const ExmCardTitle('Student Attempts', primary: true),
              // `<Card class="m-4 p-0">`
              Padding(
                padding: const EdgeInsets.all(16),
                child: ExamAttemptsTable(attempts: s.examattempts, onView: _examResults),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
