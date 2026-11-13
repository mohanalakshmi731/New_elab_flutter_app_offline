/// Pure helpers ported from `src/pages/exams/startexam.vue` (no Flutter
/// imports, unit-tested in `test/take_exam_logic_test.dart`).
library;

import 'dart:math' as math;

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../schedules/schedule_exam_logic.dart' show jsNumber, jsStr;

/// One entry of `this.questions` (built in `mounted()` from
/// `currentExamAttempt.attempt_questions`).
class ExamQuestion {
  const ExamQuestion({
    required this.id,
    required this.questionId,
    required this.questionType,
    required this.stem,
    required this.options,
    required this.images,
  });

  /// `q.id` — the attempt-question id (key of `answers`).
  final Object? id;

  /// `question.id`
  final Object? questionId;

  /// `question.question_type` — `MCQ`, `SAQ` or `MEQ`.
  final Object? questionType;

  /// `question.stem` (HTML).
  final Object? stem;

  /// `question.options || []`
  final List<Map<String, dynamic>> options;

  /// `question.images` or `[{ id: 'single-img', image_url }]` or `[]`.
  final List<Map<String, dynamic>> images;

  bool get isMcq => questionType == 'MCQ';
  bool get isText => questionType == 'SAQ' || questionType == 'MEQ';
}

List<Map<String, dynamic>> _maps(Object? list) => [for (final e in asList(list)) ?asMap(e)];

/// `attempt.attempt_questions.map(q => { … })`
List<ExamQuestion> mapAttemptQuestions(Object? attempt) {
  final out = <ExamQuestion>[];
  for (final raw in asList(asMap(attempt)?['attempt_questions'])) {
    final q = asMap(raw) ?? const <String, dynamic>{};
    final question = asMap(q['question']) ?? const <String, dynamic>{};
    final images = asList(question['images']).isNotEmpty
        ? _maps(question['images'])
        : jsTruthy(question['image_url'])
            ? [
                {'id': 'single-img', 'image_url': question['image_url']},
              ]
            : <Map<String, dynamic>>[];
    out.add(ExamQuestion(
      id: q['id'],
      questionId: question['id'],
      questionType: question['question_type'],
      stem: question['stem'],
      options: _maps(question['options']),
      images: images,
    ));
  }
  return out;
}

/// `examDurationSeconds()` — `Math.max(0, Math.floor(Number(duration_minutes || 0) * 60))`.
/// (A non-numeric duration gave `NaN` on the web; it is 0 here.)
int examDurationSeconds(Object? exam) {
  final raw = asMap(exam)?['duration_minutes'];
  final minutes = jsNumber(jsTruthy(raw) ? raw : 0);
  if (minutes.isNaN) return 0;
  if (minutes.isInfinite) return minutes > 0 ? 1 << 31 : 0;
  return math.max(0, (minutes * 60).floor());
}

/// `Math.max(0, Math.floor((endTime - Date.now()) / 1000))`
int remainingSeconds(int endTimeMs, int nowMs) =>
    math.max(0, ((endTimeMs - nowMs) / 1000).floor());

/// `timeWarning`
bool isTimeWarning(int timeRemaining) => timeRemaining < 300 && timeRemaining > 60;

/// `timeCritical`
bool isTimeCritical(int timeRemaining) => timeRemaining <= 60;

String _pad2(int v) => v.toString().padLeft(2, '0');

/// `formatTime(sec)` — `HH:MM:SS` from one hour, otherwise `MM:SS`.
String formatExamTime(int sec) {
  final h = sec ~/ 3600;
  final m = (sec % 3600) ~/ 60;
  final s = sec % 60;
  if (h > 0) return '${_pad2(h)}:${_pad2(m)}:${_pad2(s)}';
  return '${_pad2(m)}:${_pad2(s)}';
}

/// `isAnswered(q)` — MCQ: any truthy option id; SAQ/MEQ: non-blank text.
bool isQuestionAnswered(ExamQuestion q, Object? value) {
  if (q.isMcq) return jsTruthy(value);
  if (q.isText) return value is String && value.trim().isNotEmpty;
  return false;
}

/// `answeredCount`
int answeredCount(List<ExamQuestion> questions, Map<Object?, Object?> answers) =>
    questions.where((q) => isQuestionAnswered(q, answers[q.id])).length;

/// `getDirectImage(url)` — Google Drive share links → direct image host.
String getDirectImage(String url) {
  if (url.isEmpty) return url;
  final match = RegExp(r'[-\w]{25,}').firstMatch(url);
  if (url.contains('drive.google.com') && match != null) {
    return 'https://lh3.googleusercontent.com/d/${match.group(0)}';
  }
  return url;
}

/// `normalizeExamReturnPath(path)` — `/myclasses…` gets `tab=Exams`.
String normalizeExamReturnPath(String path) {
  if (!path.startsWith('/myclasses')) return path;
  try {
    final uri = Uri.parse(path);
    final params = <String, List<String>>{};
    var hasTab = false;
    uri.queryParametersAll.forEach((k, v) {
      if (k == 'tab') {
        hasTab = true;
        params[k] = const ['Exams'];
      } else {
        params[k] = v;
      }
    });
    if (!hasTab) params['tab'] = const ['Exams'];
    final query = Uri(queryParameters: params).query;
    return '${uri.path}?$query${uri.hasFragment ? '#${uri.fragment}' : ''}';
  } catch (_) {
    return '/exams';
  }
}

/// `resolveExamReturnPath()` from the `redirect` query value.
String resolveExamReturnPath(String? redirect) {
  final value = redirect;
  if (value != null && value.startsWith('/') && !value.startsWith('/startexam')) {
    return normalizeExamReturnPath(value);
  }
  return '/exams';
}

/// The `submitExamAnswer` payloads `submitExam()` sends, in order (without
/// the `institute_id` the store action adds).
List<Map<String, dynamic>> buildAnswerSubmissions(
  Object? attemptId,
  List<ExamQuestion> questions,
  Map<Object?, Object?> answers,
) {
  final out = <Map<String, dynamic>>[];
  for (final q in questions) {
    final value = answers[q.id];
    if (!jsTruthy(value)) continue;
    if (q.isMcq) {
      out.add({
        'exam_attempt_id': attemptId,
        'question_id': jsStr(q.questionId),
        'selected_option_ids': [value],
      });
    } else if (q.isText) {
      if (value is! String || value.trim().isEmpty) continue;
      out.add({
        'exam_attempt_id': attemptId,
        'question_id': jsStr(q.questionId),
        'answer_text': value,
      });
    }
  }
  return out;
}
