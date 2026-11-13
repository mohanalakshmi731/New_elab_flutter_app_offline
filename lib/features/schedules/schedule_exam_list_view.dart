import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../widgets/app_loader.dart';
import 'schedule_exam_controller.dart';
import 'schedule_exam_logic.dart';
import 'schedule_exam_view.dart';
import 'schedule_exam_widgets.dart';

/// Port of `src/pages/schedules/scheduleexamlist.vue`, embedded by the
/// schedules screens: `<scheduleexamlist :key="activeScheduleId"
/// :exam-id="activeexamid" :schedule-id="activeScheduleId">`.
///
/// Shows the quiz of the schedule (store `exams`, loaded by
/// `fetchExamById`) with its status / edit / view / start actions. The edit
/// button shows [ScheduleExamView] inline below the details (as on the web).
class ScheduleExamListView extends ConsumerStatefulWidget {
  const ScheduleExamListView({super.key, required this.examId, required this.scheduleId});

  /// `examId` (required, String | Number).
  final Object examId;

  /// `scheduleId` (required, String | Number).
  final Object scheduleId;

  @override
  ConsumerState<ScheduleExamListView> createState() => _ScheduleExamListViewState();
}

/// Tailwind colours used here that `Tw` does not define.
class _C {
  _C._();
  static const blue300 = Color(0xFF93C5FD);
  static const blue800 = Color(0xFF1E40AF);
  static const yellow600 = Color(0xFFCA8A04);
}

/// `(border, text)` colours of the status pill.
(Color, Color) _statusColors(Object? status) => switch (status) {
      'SCHEDULED' => (_C.blue300, _C.blue800),
      'DRAFT' => (Tw.yellow500, _C.yellow600),
      'ARCHIVED' => (Tw.gray500, Tw.gray600),
      'COMPLETED' => (Tw.green500, Tw.green600),
      'CANCELLED' => (Tw.red500, Tw.red600),
      _ => (Tw.slate500, Tw.slate600),
    };

class _ScheduleExamListViewState extends ConsumerState<ScheduleExamListView> {
  // ── data() ──────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _showScheduleComp = false;
  Object? _selectedExamId;

  ScheduleExamController get _ctrl => ref.read(scheduleExamControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    // `watch: examId { immediate: true }`
    Future.microtask(() {
      if (mounted) _onExamId(widget.examId);
    });
  }

  @override
  void didUpdateWidget(covariant ScheduleExamListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.examId != widget.examId) _onExamId(widget.examId);
  }

  /// Runs a store action; errors were toasted by the API client (or only
  /// logged on the web).
  Future<void> _quiet(Future<void> Function() fn) async {
    try {
      await fn();
    } catch (_) {}
  }

  void _onExamId(Object? id) {
    if (!jsTruthy(id)) return;
    _quiet(() => _ctrl.fetchExamById(id!));
  }

  /// `handleSaved()` — hides the form and reloads the exam.
  Future<void> _handleSaved() async {
    setState(() => _showScheduleComp = false);
    await _quiet(() => _ctrl.fetchExamById(widget.examId));
  }

  /// `viewexams(exam)` → `ViewExams` (`/viewexams/:id`).
  void _viewExams(Map<String, dynamic> exam) => context.go('/viewexams/${vueText(exam['id'])}');

  /// `editexams(exam)`
  void _editExams(Map<String, dynamic> exam) {
    setState(() {
      _isLoading = true;
      _selectedExamId = exam['id'];
      _showScheduleComp = true;
      _isLoading = false;
    });
  }

  /// `updateStatus(examId)` — sets the exam to SCHEDULED, then reloads it.
  Future<void> _updateStatus(Object? examId) => _quiet(() async {
        await _ctrl.examStatus(jsStr(examId));
        await _ctrl.fetchExamById(examId ?? 'undefined');
      });

  /// `startExam(examId)` → `/startexam` when an attempt came back.
  Future<void> _startExam(Object? examId) => _quiet(() async {
        final res = await _ctrl.startExam(jsStr(examId));
        if (!mounted) return;
        if (jsTruthy(res)) context.go('/startexam');
        // else: "Exam not started" (console only)
      });

  @override
  Widget build(BuildContext context) {
    final exam = asMap(ref.watch(scheduleExamControllerProvider.select((s) => s.exams)));
    final role = ref.watch(sessionProvider.select((s) => s.role));
    final muted = examMuted(context);

    return LoadingOverlay(
      loading: _isLoading,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Schedule Quiz',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: context.colors.primary),
          ),
          const SizedBox(height: 16),
          if (exam != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _details(context, exam)),
                const SizedBox(width: 8),
                _actions(context, exam, role),
              ],
            )
          else
            Text('Loading exam details…', style: TextStyle(color: muted)),
          if (_showScheduleComp)
            ScheduleExamView(
              scheduleId: jsField(exam, 'schedule_id'),
              examId: _selectedExamId,
              onCreated: _handleSaved,
            ),
        ],
      ),
    );
  }

  Widget _details(BuildContext context, Map<String, dynamic> exam) {
    final primary = context.colors.primary;
    Widget line(String label, Object? value, {bool primaryLabel = false}) => Text.rich(
          TextSpan(children: [
            TextSpan(
              text: label,
              style: TextStyle(fontWeight: FontWeight.w700, color: primaryLabel ? primary : null),
            ),
            TextSpan(text: ' ${vueText(value)}'),
          ]),
          style: const TextStyle(fontSize: 16),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        line('Name:', exam['name']),
        line('Course:', asMap(exam['course'])?['name'], primaryLabel: true),
        line('Subject:', asMap(exam['subject'])?['name']),
        line('Batch:', asMap(exam['batch'])?['name'], primaryLabel: true),
      ],
    );
  }

  Widget _actions(BuildContext context, Map<String, dynamic> exam, String role) {
    final isStudent = role == Role.student;
    final status = exam['status'];
    final scheduled = status == 'SCHEDULED';
    final (borderColor, textColor) = _statusColors(status);
    final statusDisabled = scheduled || isStudent;
    // `opacity-60` (SCHEDULED) wins over the student's `opacity-50`.
    final statusOpacity = scheduled ? 0.6 : (isStudent ? 0.5 : 1.0);

    final children = <Widget>[
      // Status pill
      Opacity(
        opacity: statusOpacity,
        child: MouseRegion(
          cursor: statusDisabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
          child: GestureDetector(
            onTap: statusDisabled ? null : () => _updateStatus(exam['id']),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: borderColor),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(BootstrapIcons.pencil, size: 14, color: textColor),
                  const SizedBox(width: 8),
                  Text(vueText(status),
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor)),
                ],
              ),
            ),
          ),
        ),
      ),

      // Edit (instructors only; admins see it disabled)
      if (!isStudent && role != Role.institute)
        _IconAction(
          icon: BootstrapIcons.pencil_square,
          enabled: role == Role.instructor,
          onTap: () => _editExams(exam),
        ),

      // View
      _IconAction(
        icon: BootstrapIcons.eye_fill,
        color: Tw.sky500,
        enabled: !isStudent,
        onTap: () => _viewExams(exam),
      ),

      // Start quiz (students)
      if (isStudent)
        MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            onTap: () => _startExam(exam['id']),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.colors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text('Start quiz', style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ),
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.end,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: children,
    );
  }
}

/// A bare `<button><i class="bi … text-lg"/></button>`; disabled =
/// `cursor-not-allowed opacity-50 pointer-events-none`.
class _IconAction extends StatelessWidget {
  const _IconAction({required this.icon, required this.onTap, this.enabled = true, this.color});

  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final glyph = Icon(icon, size: 18, color: color ?? DefaultTextStyle.of(context).style.color);
    if (!enabled) return IgnorePointer(child: Opacity(opacity: 0.5, child: glyph));
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: glyph),
    );
  }
}
