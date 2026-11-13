/// Pure helpers behind
/// `src/components/new_ui_student_teacher_for_both_labs/studentdashbaordlayout.vue`.
/// The schedule-banner helpers are shared with the teacher dashboard port
/// (`features/teacher_dashboard/teacher_dashboard_logic.dart`).
library;

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../upgrade/upgrade_plan_logic.dart' show jsNumber;

/// JS `String(v)` for ids (`undefined`/`null` print as text, so two missing
/// ids compare equal, like on the web).
String _jsString(Object? v) {
  if (v == null) return 'undefined';
  if (v is double && v.isFinite && v == v.truncateToDouble()) return v.toInt().toString();
  return '$v';
}

String _upper(Object? v) => jsTruthy(v) ? '$v'.toUpperCase() : '';

/// `Array.isArray(res) ? res : (res && res.data ? res.data : [])`
List<dynamic> examArrayOf(Object? res) {
  if (res is List) return res;
  final data = asMap(res)?['data'];
  return jsTruthy(data) ? asList(data) : const [];
}

/// `availableExams` — scheduled EXAM-type exams the student still has
/// attempts left for (`submitted < (max_attempts || 1)`).
List<Map<String, dynamic>> availableExams(List<dynamic> allExams, List<dynamic> studentAttempts) {
  final out = <Map<String, dynamic>>[];
  for (final e in allExams) {
    final exam = asMap(e);
    if (exam == null) continue;
    // 1. must be EXAM type
    if (_upper(exam['exam_type']) != 'EXAM') continue;
    // 2. must be SCHEDULED status
    if (_upper(exam['status']) != 'SCHEDULED') continue;
    // 3. check attempts remaining
    final examId = _jsString(exam['id']);
    var submitted = 0;
    for (final a in studentAttempts) {
      final attempt = asMap(a) ?? const <String, dynamic>{};
      final attemptExamId = attempt['exam_id'] ?? dig(attempt, const ['exam', 'id']);
      if (_jsString(attemptExamId) != examId) continue;
      if (_upper(attempt['status']) == 'SUBMITTED') submitted++;
    }
    final maxAttempts = jsTruthy(exam['max_attempts']) ? jsNumber(exam['max_attempts']) : 1;
    if (submitted < maxAttempts) out.add(exam);
  }
  return out;
}

/// The exam-type family behind `examStripClass` / `examIconBg` /
/// `examIconColor`.
enum ExamTypeKind { quiz, practice, exam }

ExamTypeKind examTypeKind(Map<String, dynamic> exam) => switch (_upper(exam['exam_type'])) {
      'QUIZ' => ExamTypeKind.quiz,
      'PRACTICE' => ExamTypeKind.practice,
      _ => ExamTypeKind.exam,
    };

/// `examStatusClass(status)` family.
enum ExamStatusKind { scheduled, ongoing, completed, draft, other }

ExamStatusKind examStatusKind(Object? status) => switch (_upper(status)) {
      'SCHEDULED' => ExamStatusKind.scheduled,
      'ONGOING' => ExamStatusKind.ongoing,
      'COMPLETED' => ExamStatusKind.completed,
      'DRAFT' => ExamStatusKind.draft,
      _ => ExamStatusKind.other,
    };

const _enInMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];

/// `fmtDate(dateStr)` — `toLocaleDateString('en-IN', { day: '2-digit',
/// month: 'short', year: 'numeric' })` → `05 Nov 2026`; "Invalid Date" for
/// an unparsable value, `—` when empty. ISO date-only strings are UTC like
/// JS. [toLocal] is only for tests.
String fmtExamDate(Object? dateStr, {DateTime Function(DateTime)? toLocal}) {
  if (!jsTruthy(dateStr)) return '—';
  final s = '$dateStr'.trim();
  final dateOnly = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(s);
  final parsed = dateOnly != null
      ? DateTime.utc(int.parse(dateOnly.group(1)!), int.parse(dateOnly.group(2)!), int.parse(dateOnly.group(3)!))
      : DateTime.tryParse(s);
  if (parsed == null) return 'Invalid Date';
  final d = toLocal != null ? toLocal(parsed) : parsed.toLocal();
  return '${d.day.toString().padLeft(2, '0')} ${_enInMonths[d.month - 1]} ${d.year}';
}

/// `exam.duration_minutes ? exam.duration_minutes + ' min' : '—'`
String examDurationLabel(Map<String, dynamic> exam) {
  final v = exam['duration_minutes'];
  if (!jsTruthy(v)) return '—';
  if (v is double && v == v.truncateToDouble()) return '${v.toInt()} min';
  return '$v min';
}
