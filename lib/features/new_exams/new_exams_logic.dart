/// Pure computed values of `newexams.vue`. Unlike `ExamsList.vue`, this
/// component compares ids strictly (`===`) and reads the raw store
/// `examattempts`, so the rules differ slightly — kept as in the web.
library;

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../exams/exams_logic.dart';

/// `(e.exam_type || '').toLowerCase() === 'exam'`
bool isExamType(Json e) => lowerOrEmpty(e['exam_type']) == 'exam';

/// `filteredExams` — EXAM rows only; institutes don't see drafts.
List<Json> newFilteredExams(List<Json> exams, String role) => [
      for (final e in exams)
        if (isExamType(e) && (role != 'institute' || e['status'] != 'DRAFT')) e,
    ];

List<Json> _attemptsFor(List<Json> attempts, Object? examId) => [
      for (final a in attempts)
        if (a['exam_id'] == examId) a,
    ];

/// `availableExams` — scheduled exams whose highest attempt number is below
/// `max_attempts || 1` (an attempt without `attempt_number` makes it NaN →
/// not available, like `Math.max(undefined)`).
List<Json> newAvailableExams(List<Json> exams, List<Json> attempts) => [
      for (final exam in exams)
        if (isExamType(exam) && exam['status'] == 'SCHEDULED' && _available(exam, attempts)) exam,
    ];

bool _available(Json exam, List<Json> attempts) {
  final mine = _attemptsFor(attempts, exam['id']);
  final num highest = mine.isEmpty ? 0 : jsMax(mine.map((a) => jsNumField(a, 'attempt_number')));
  return highest < jsNum(maxAttemptsOf(exam));
}

/// `inProgressExams`
List<Json> newInProgressExams(List<Json> attempts) => [
      for (final a in attempts)
        if (a['status'] == 'IN_PROGRESS') {...?asMap(a['exam']), 'attempt_id': a['id']},
    ];

/// `completedExams` — one entry per exam with a SUBMITTED attempt.
List<Json> newCompletedExams(List<Json> attempts) {
  final groups = <Object?, List<Json>>{};
  for (final a in attempts) {
    if (a['status'] == 'SUBMITTED') groups.putIfAbsent(a['exam_id'], () => []).add(a);
  }
  return [
    for (final g in groups.values) {...?asMap(g.first['exam']), 'last_attempt_number': highestAttempt(g)},
  ];
}

/// `getAttemptsLeft(examId, max)` with strict id equality.
Object newAttemptsLeft(List<Json> attempts, Object? examId, Object max) {
  final mine = _attemptsFor(attempts, examId);
  if (mine.isEmpty) return max;
  final left = jsNum(max) - highestAttempt(mine);
  return left.isNaN ? double.nan : (left > 0 ? left : 0);
}

/// `getAttemptsLeft(...) > 0`
bool hasAttemptsLeft(Object left) => jsNum(left) > 0;

// ── Result view ──────────────────────────────────────────────────────────

List<Json> _questions(Json? attempt) => examMaps(attempt?['attempt_questions']);

num _score(Json res) => jsNum(res['final_score'] ?? res['auto_score'] ?? 0);

num _max(Json q) => jsNum(jsOr(jsOr(q['max_marks'], dig(q, ['question', 'marks'])), 1));

/// `res.selected_option_ids?.length > 0`
bool _hasSelection(Json res) {
  final ids = res['selected_option_ids'];
  if (ids is List) return ids.isNotEmpty;
  if (ids is String) return ids.isNotEmpty;
  return false;
}

/// `resultTotalQuestions`
int resultTotalQuestions(Json? attempt) => _questions(attempt).length;

/// `resultCorrect` — score ≥ the question's max marks.
int resultCorrect(Json? attempt) => _questions(attempt).where((q) {
      final res = asMap(q['response']);
      if (!jsTruthy(res)) return false;
      return _score(res!) >= _max(q);
    }).length;

/// `resultIncorrect` — answered (note: a `null` answer_text counts as an
/// answer, like `undefined !== ''` on the web) and scored below max.
int resultIncorrect(Json? attempt) => _questions(attempt).where((q) {
      final res = asMap(q['response']);
      if (!jsTruthy(res)) return false;
      final text = res!['answer_text'];
      final hasAnswer = _hasSelection(res) || (text is String ? text.trim() != '' : true);
      return hasAnswer && _score(res) < _max(q);
    }).length;

/// `resultNotAnswered`
int resultNotAnswered(Json? attempt) => _questions(attempt).where((q) {
      final res = asMap(q['response']);
      if (!jsTruthy(res)) return true;
      final text = res!['answer_text'];
      return !_hasSelection(res) && !(text is String && text.trim().isNotEmpty);
    }).length;

/// `q.response?.selected_option_ids?.includes(opt.id)`
bool optionSelected(Json q, Object? optionId) {
  final ids = dig(q, ['response', 'selected_option_ids']);
  if (ids is List) return ids.contains(optionId);
  if (ids is String && optionId is String) return ids.contains(optionId);
  return false;
}

/// `loadExams`: `language?.name?.slice(0, 2).toLowerCase()`.
String? localeFromLanguageName(String? name) {
  if (name == null) return null;
  return (name.length > 2 ? name.substring(0, 2) : name).toLowerCase();
}

/// `Number(selectedAttempt?.percentage).toFixed(2)` (`undefined` → NaN).
String percentFixed2(Json? attempt) {
  if (attempt == null || !attempt.containsKey('percentage')) return 'NaN';
  return jsToFixed(jsNum(attempt['percentage']), 2);
}

/// `(attempt.percentage * 100).toFixed(0)`
String percentTimes100(Json attempt) {
  if (!attempt.containsKey('percentage')) return 'NaN';
  return jsToFixed(jsNum(attempt['percentage']) * 100, 0);
}
