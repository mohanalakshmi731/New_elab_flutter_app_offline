/// Pure logic of `src/components/QuizExam.vue` (kept separate so it can be
/// unit-tested).
library;

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../mathzoro/mz_ui.dart' show jsStr, jsDisplay;

/// Key a JavaScript object uses for `obj[value]` (`String(value)`).
String quizKey(dynamic id) => jsStr(id) ?? 'undefined';

/// `isOptionCorrect(option)`.
bool quizOptionIsCorrect(Map<String, dynamic> option) {
  final v = option['is_correct'];
  return v == true ||
      v == 'true' ||
      option['isCorrect'] == true ||
      option['correct'] == true ||
      (v is num && v == 1) ||
      v == '1';
}

/// `currentQuestion.options` as maps (non-objects dropped).
List<Map<String, dynamic>> quizOptions(Map<String, dynamic>? question) =>
    asList(question?['options']).map(asMap).whereType<Map<String, dynamic>>().toList();

/// `option.display_label || String.fromCharCode(64 + (index + 1))`.
String quizOptionLabel(Map<String, dynamic> option, int index) {
  final label = option['display_label'];
  if (jsTruthy(label)) return jsDisplay(label);
  return String.fromCharCode(64 + index + 1);
}

/// `{{ option.text || option.option_text }}`.
String quizOptionText(Map<String, dynamic> option) =>
    jsTruthy(option['text']) ? jsDisplay(option['text']) : jsDisplay(option['option_text']);

/// `v-html="currentQuestion.text || currentQuestion.stem"`.
String quizQuestionHtml(Map<String, dynamic> question) =>
    jsTruthy(question['text']) ? jsDisplay(question['text']) : jsDisplay(question['stem']);

/// `{{ option.remarks || 'No explanation provided.' }}`.
String quizOptionRemarks(Map<String, dynamic> option) => jsTruthy(option['remarks'])
    ? jsDisplay(option['remarks'])
    : 'No explanation provided.';

/// `String(currentStep).padStart(2, '0')`.
String quizStepLabel(int step) => step.toString().padLeft(2, '0');

/// True for the keys JavaScript treats as array indices (`"0"`, `"12"`, …
/// below 2^32 − 1); those come first, in ascending order, in `Object.keys`.
bool _isArrayIndexKey(String k) {
  if (k.isEmpty || k.length > 10) return false;
  if (k != '0' && !RegExp(r'^[1-9][0-9]*$').hasMatch(k)) return false;
  if (k == '0') return true;
  final n = int.tryParse(k);
  return n != null && n < 4294967295;
}

/// `Object.keys(obj)` order: integer-like keys ascending, then the other
/// keys in insertion order.
List<String> jsObjectKeys(Map<String, dynamic> obj) {
  final ints = <String>[];
  final others = <String>[];
  for (final k in obj.keys) {
    (_isArrayIndexKey(k) ? ints : others).add(k);
  }
  ints.sort((a, b) => int.parse(a).compareTo(int.parse(b)));
  return [...ints, ...others];
}

/// The `answers` object as JavaScript would enumerate it.
Map<String, dynamic> jsOrderedAnswers(Map<String, dynamic> answers) =>
    {for (final k in jsObjectKeys(answers)) k: answers[k]};

/// `buildAnswersPayload()` — `Object.entries(answers).map(([q, o]) =>
/// ({ question_id: String(q), option_id: String(o) }))`.
List<Map<String, String>> buildQuizAnswersPayload(Map<String, dynamic> answers) => [
      for (final k in jsObjectKeys(answers))
        {'question_id': k, 'option_id': jsStr(answers[k]) ?? 'null'},
    ];

/// `progressPercent` (0–100): answered / total.
double quizProgressPercent(int answeredCount, int total) =>
    total == 0 ? 0 : answeredCount / total * 100;

/// `progressCircle` as a 0–1 fraction of the ring (`currentStep / total`).
double quizStepFraction(int currentStep, int total) => total == 0 ? 0 : currentStep / total;
