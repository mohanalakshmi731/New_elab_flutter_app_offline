/// Pure helpers for the exam screens (`exam.vue`, `ExamsList.vue`,
/// `examcreate.vue`, `newexams.vue`): JavaScript value semantics, the
/// computed lists of `ExamsList.vue`, date formatting and the create-exam
/// payload. No Flutter imports, so everything here is unit-tested.
library;

import 'dart:convert';
import 'dart:math' as math;

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';

typedef Json = Map<String, dynamic>;

/// `Array.isArray(x) ? x : []`, keeping only the object rows.
List<Json> examMaps(dynamic list) => [for (final e in asList(list)) ?asMap(e)];

// ── JavaScript value semantics ────────────────────────────────────────────

/// `Number(v)` — `null` → 0, `''` → 0, unparsable → NaN.
num jsNum(Object? v) {
  if (v == null) return 0;
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return 0;
    final i = int.tryParse(s);
    if (i != null) return i;
    if (s == 'Infinity' || s == '+Infinity') return double.infinity;
    if (s == '-Infinity') return double.negativeInfinity;
    if (!RegExp(r'^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$').hasMatch(s)) return double.nan;
    return double.tryParse(s) ?? double.nan;
  }
  if (v is List) {
    if (v.isEmpty) return 0;
    if (v.length == 1) return jsNum(v.first);
  }
  return double.nan;
}

/// `Number(map.key)` where a missing key is `undefined` (→ NaN) and an
/// explicit `null` is 0.
num jsNumField(Json m, String key) => m.containsKey(key) ? jsNum(m[key]) : double.nan;

/// `Math.max(...values)` — NaN wins, `-Infinity` for none.
num jsMax(Iterable<num> values) {
  num best = double.negativeInfinity;
  for (final v in values) {
    if (v.isNaN) return double.nan;
    if (v > best) best = v;
  }
  return best;
}

/// `String(n)` for a number (`5.0` → `'5'`, NaN → `'NaN'`).
String jsNumStr(num n) {
  if (n.isNaN) return 'NaN';
  if (n.isInfinite) return n > 0 ? 'Infinity' : '-Infinity';
  if (n is double && n == n.truncateToDouble() && n.abs() < 1e21) return n.toInt().toString();
  return n.toString();
}

/// `String(v)` (`null`/`undefined` both become `'null'`).
String jsStr(Object? v) {
  if (v == null) return 'null';
  if (v is num) return jsNumStr(v);
  if (v is String) return v;
  if (v is List) return v.map((e) => e == null ? '' : jsStr(e)).join(',');
  if (v is Map) return '[object Object]';
  return v.toString();
}

/// Vue's `{{ v }}` (`toDisplayString`): `null` → `''`, objects → JSON.
String display(Object? v) {
  if (v == null) return '';
  if (v is num) return jsNumStr(v);
  if (v is String) return v;
  if (v is List || v is Map) {
    try {
      return const JsonEncoder.withIndent('  ').convert(v);
    } catch (_) {
      return v.toString();
    }
  }
  return v.toString();
}

/// `n.toFixed(digits)`.
String jsToFixed(num n, int digits) {
  if (n.isNaN) return 'NaN';
  if (n.isInfinite) return n > 0 ? 'Infinity' : '-Infinity';
  return n.toStringAsFixed(digits);
}

/// `a || b`
Object? jsOr(Object? a, Object? b) => jsTruthy(a) ? a : b;

/// A number as `JSON.stringify` sends it: whole doubles as ints, NaN and
/// ±Infinity as `null` (dart:convert would throw on them).
num? jsonNum(num n) {
  if (!n.isFinite) return null;
  if (n is double && n == n.truncateToDouble() && n.abs() < 9007199254740992) return n.toInt();
  return n;
}

/// `Number(v) || 1` as sent in JSON.
num? numberOrOne(Object? v) {
  final n = jsNum(v);
  return jsonNum(n.isNaN || n == 0 ? 1 : n);
}

/// The value an `<input type="number">` hands to `v-model`: the trimmed
/// text when it is a valid number, `''` otherwise (browsers sanitise invalid
/// input to an empty value).
String htmlNumberValue(String text) {
  final s = text.trim();
  if (s.isEmpty) return '';
  return RegExp(r'^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$').hasMatch(s) ? s : '';
}

/// `v-model.number` (`looseToNumber`): `parseFloat(v)`, or the string itself
/// when that is NaN.
Object looseToNumber(String v) {
  final m = RegExp(r'^\s*[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?').firstMatch(v);
  if (m == null) return v;
  final n = double.tryParse(m.group(0)!.trim());
  if (n == null) return v;
  return jsonNum(n) ?? n;
}

/// `x.toLowerCase()` of `(x || '')`.
String lowerOrEmpty(Object? v) => jsTruthy(v) ? jsStr(v).toLowerCase() : '';

// ── Dates ─────────────────────────────────────────────────────────────────

/// `new Date(v)` in local time; `null` for an Invalid Date. Date-only ISO
/// strings are UTC in JavaScript.
DateTime? jsDate(Object? v) {
  if (v == null) return null;
  if (v is num) return v.isFinite ? DateTime.fromMillisecondsSinceEpoch(v.toInt()) : null;
  final s = v.toString().trim();
  if (s.isEmpty) return null;
  if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
    return DateTime.tryParse('${s}T00:00:00Z')?.toLocal();
  }
  return DateTime.tryParse(s)?.toLocal();
}

String _two(int n) => n.toString().padLeft(2, '0');

/// CLDR `en-IN` / `en-GB` abbreviated months (`Sept`).
const _shortMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];

/// `new Date(v).toLocaleString('en-IN')` → `15/1/2025, 3:45:00 pm`.
String toLocaleStringEnIn(Object? v) {
  final d = jsDate(v);
  if (d == null) return 'Invalid Date';
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '${d.day}/${d.month}/${d.year}, $h:${_two(d.minute)}:${_two(d.second)} ${d.hour < 12 ? 'am' : 'pm'}';
}

/// `newexams.vue` `fmtDate`: `toLocaleDateString('en-IN', { day: '2-digit',
/// month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })`
/// → `15 Jan 2025, 03:45 pm`; `'—'` for an empty value.
String fmtDateTimeEnIn(Object? v) {
  if (!jsTruthy(v)) return '—';
  final d = jsDate(v);
  if (d == null) return 'Invalid Date';
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '${_two(d.day)} ${_shortMonths[d.month - 1]} ${d.year}, '
      '${_two(h)}:${_two(d.minute)} ${d.hour < 12 ? 'am' : 'pm'}';
}

/// `newexams.vue` `formatDate`: `toLocaleDateString('en-GB', { day:
/// '2-digit', month: 'short', year: 'numeric' })` → `15 Jan 2025`.
String formatDateEnGb(Object? v) {
  if (!jsTruthy(v)) return '—';
  final d = jsDate(v);
  if (d == null) return 'Invalid Date';
  return '${_two(d.day)} ${_shortMonths[d.month - 1]} ${d.year}';
}

/// The Start/End Time cells of `ExamsList.vue`:
/// `is_open_anytime ? 'Anytime' : time ? toLocaleString('en-IN') : '-'`.
String examTimeCell(Json exam, String key) {
  if (jsTruthy(exam['is_open_anytime'])) return 'Anytime';
  final t = exam[key];
  return jsTruthy(t) ? toLocaleStringEnIn(t) : '-';
}

// ── Store unwrapping ──────────────────────────────────────────────────────

/// `fetchExams` / `fetchExamAttempts`:
/// `payload = res?.data ?? res?.response ?? res ?? []`,
/// `Array.isArray(payload) ? payload : payload?.data` — `null` when that is
/// not an array (the store then throws).
List<dynamic>? unwrapExamArray(dynamic res) {
  final m = asMap(res);
  final payload = m?['data'] ?? m?['response'] ?? res ?? const [];
  if (payload is List) return payload;
  final inner = asMap(payload)?['data'];
  return inner is List ? inner : null;
}

// ── ExamsList.vue computed ────────────────────────────────────────────────

const _examTypes = ['exam', 'quiz'];

/// `filteredExams` — EXAM/QUIZ rows; institutes don't see drafts.
List<Json> listFilteredExams(List<Json> rows, String role) => [
      for (final e in rows)
        if (_examTypes.contains(lowerOrEmpty(e['exam_type'])) && (role != 'institute' || e['status'] != 'DRAFT')) e,
    ];

/// `studentAttempts` — every attempt with its `exam_id` resolved
/// (`exam_id ?? exam.id`), the status upper-cased and the listed exam merged
/// under the attempt's own `exam`.
List<Json> normalizeStudentAttempts(List<dynamic> examattempts, List<Json> examRows) {
  final out = <Json>[];
  for (final attempt in examMaps(examattempts)) {
    final nested = asMap(attempt['exam']);
    final examId = attempt['exam_id'] ?? nested?['id'];
    Json? listed;
    for (final e in examRows) {
      if (jsStr(e['id']) == jsStr(examId)) {
        listed = e;
        break;
      }
    }
    if (examId == null) continue;
    out.add({
      ...attempt,
      'exam_id': examId,
      'status': jsStr(jsOr(attempt['status'], '')).toUpperCase(),
      'exam': {...?listed, ...?nested, 'id': examId},
    });
  }
  return out;
}

/// `exam.max_attempts || 1`
Object maxAttemptsOf(Json exam) => jsOr(exam['max_attempts'], 1)!;

/// `availableExams` — scheduled exams with no attempt in progress and
/// attempts left.
List<Json> listAvailableExams(List<Json> rows, List<Json> studentAttempts) => [
      for (final exam in rows)
        if (_examTypes.contains(lowerOrEmpty(exam['exam_type'])) &&
            jsStr(exam['status']).toUpperCase() == 'SCHEDULED' &&
            _hasAttemptsLeft(exam, studentAttempts))
          exam,
    ];

bool _hasAttemptsLeft(Json exam, List<Json> studentAttempts) {
  final attempts = [
    for (final a in studentAttempts)
      if (jsStr(a['exam_id']) == jsStr(exam['id'])) a,
  ];
  if (attempts.any((a) => a['status'] == 'IN_PROGRESS')) return false;
  final num highest = attempts.isEmpty
      ? 0
      : jsMax(attempts.map((a) {
          final n = jsNum(a['attempt_number']);
          return n.isNaN || n == 0 ? 0 : n;
        }));
  return highest < jsNum(maxAttemptsOf(exam));
}

/// `inProgressExams` — the exam of every IN_PROGRESS attempt with its
/// `attempt_id`.
List<Json> listInProgressExams(List<Json> attempts) => [
      for (final a in attempts)
        if (a['status'] == 'IN_PROGRESS') {...?asMap(a['exam']), 'attempt_id': a['id']},
    ];

/// Groups attempts by `exam_id` in first-seen order (JS `Map`).
Map<Object?, List<Json>> _groupByExam(Iterable<Json> attempts) {
  final map = <Object?, List<Json>>{};
  for (final a in attempts) {
    map.putIfAbsent(a['exam_id'], () => []).add(a);
  }
  return map;
}

/// `Math.max(...attempts.map(a => a.attempt_number || 0))`
num highestAttempt(List<Json> attempts) =>
    jsMax(attempts.map((a) => jsNum(jsOr(a['attempt_number'], 0))));

/// `completedExams` — exams whose submitted attempts used up every attempt.
List<Json> listCompletedExams(List<Json> studentAttempts) {
  final result = <Json>[];
  final groups = _groupByExam(studentAttempts.where((a) => a['status'] == 'SUBMITTED'));
  for (final attempts in groups.values) {
    final exam = asMap(attempts.first['exam']) ?? const {};
    final maxAttempts = jsOr(exam['max_attempts'], 1);
    final highest = highestAttempt(attempts);
    if (highest >= jsNum(maxAttempts)) {
      result.add({...exam, 'last_attempt_number': highest});
    }
  }
  return result;
}

/// `getAttemptsLeft(examId, max)` (ExamsList: ids compared as strings).
/// Returns [max] untouched when the exam has no attempt.
Object listAttemptsLeft(List<Json> studentAttempts, Object? examId, Object max) {
  final attempts = [
    for (final a in studentAttempts)
      if (jsStr(a['exam_id']) == jsStr(examId)) a,
  ];
  if (attempts.isEmpty) return max;
  final left = jsNum(max) - highestAttempt(attempts);
  return left.isNaN ? double.nan : math.max(left, 0);
}

/// Language column: `te` → Telugu, `en` → English, otherwise `-`.
String localeLabel(Object? locale) => switch (locale) {
      'te' => 'Telugu',
      'en' => 'English',
      _ => '-',
    };

/// `Locale` of `src/types/enums.ts` as `{{ key }}` / value pairs.
const localeOptions = [('All', 'all'), ('Telugu', 'te'), ('English', 'en')];

/// `defaultLocale`
const defaultExamLocale = 'en';

// ── examcreate.vue ────────────────────────────────────────────────────────

/// The `courseSections` watcher: every section's chapters, flattened.
List<Json> chaptersOf(List<dynamic> sections) => [
      for (final s in examMaps(sections)) ...examMaps(jsOr(s['chapters'], const [])),
    ];

/// `topics` — the contents of the chapter whose `id === selectedSubjectId`
/// (with `topic_id = exam_content_id`); `[]` when no chapter is selected.
List<Json> topicsOf(List<dynamic> sections, Object? selectedSubjectId) {
  if (!jsTruthy(selectedSubjectId)) return const [];
  for (final section in examMaps(sections)) {
    for (final chapter in examMaps(jsOr(section['chapters'], const []))) {
      if (chapter['id'] == selectedSubjectId) {
        return [
          for (final c in examMaps(jsOr(chapter['contents'], const []))) {...c, 'topic_id': c['exam_content_id']},
        ];
      }
    }
  }
  return const [];
}

/// `saveExam`'s section lookup: the first section having a chapter whose
/// `exam_chapter_id === selectedSubjectId`. (The chapter select stores the
/// chapter's `id`, so this rarely matches — kept from the web.)
Json? sectionForChapter(List<dynamic> sections, Object? selectedSubjectId) {
  for (final section in examMaps(sections)) {
    final chapters = section['chapters'];
    if (chapters is! List) continue;
    for (final c in examMaps(chapters)) {
      if (c.containsKey('exam_chapter_id') && c['exam_chapter_id'] == selectedSubjectId) return section;
    }
  }
  return null;
}

/// One `rules[]` entry of a section, as plain values.
class ExamRuleInput {
  const ExamRuleInput({this.topicId = '', this.difficulty = '', this.questionType = '', this.pickCount = 0});
  final String topicId;
  final String difficulty;
  final String questionType;

  /// `v-model.number` value (a number, or the raw string).
  final Object pickCount;
}

/// One `sections[]` entry, as plain values.
class ExamSectionInput {
  const ExamSectionInput({
    this.name = '',
    this.description = '',
    this.questionCount = 0,
    this.marksPerQuestion = 1,
    this.rules = const [],
  });
  final String name;
  final String description;
  final Object questionCount;
  final Object marksPerQuestion;
  final List<ExamRuleInput> rules;
}

/// `saveExam`'s payload (before the store prepends `institute_id`).
/// `undefined` fields are left out, like `JSON.stringify` does.
Json buildCreateExamPayload({
  required String selectedCourseId,
  required Json? selectedSection,
  required String selectedBatchId,
  required String name,
  required String code,
  required String description,
  required String examType,
  required String durationMinutes,
  required bool randomizeQuestionOrder,
  required bool randomizeOptionOrder,
  required bool showImmediateFeedback,
  required bool enableNegativeMarking,
  required String negativeMarks,
  required String locale,
  required String imageUrl,
  required Object imageOrder,
  required Object maxAttempts,
  required List<ExamSectionInput> sections,
}) {
  final subjectId = selectedSection?['exam_section_id'];
  return {
    'exam_course_id': selectedCourseId,
    if (selectedSection != null && selectedSection.containsKey('exam_section_id')) 'exam_subject_id': subjectId,
    'exam_batch_id': selectedBatchId,
    'name': name,
    'code': code,
    if (description.isNotEmpty) 'description': description,
    'exam_type': examType,
    'is_open_anytime': true,
    'duration_minutes': jsonNum(jsNum(durationMinutes)),
    'randomize_question_order': randomizeQuestionOrder,
    'randomize_option_order': randomizeOptionOrder,
    'show_immediate_feedback': showImmediateFeedback,
    'default_negative_marks': enableNegativeMarking ? jsonNum(jsNum(negativeMarks)) : 0,
    'allow_negative_marking': enableNegativeMarking,
    'locale': locale,
    'images': imageUrl.isNotEmpty
        ? [
            {'image_url': imageUrl, 'caption': '', 'order_index': numberOrOne(imageOrder)},
          ]
        : const [],
    'max_attempts': numberOrOne(maxAttempts),
    'sections': [
      for (var i = 0; i < sections.length; i++)
        {
          'name': sections[i].name.isNotEmpty ? sections[i].name : 'Section ${i + 1}',
          'section_order': i + 1,
          'question_count': numberOrOne(sections[i].questionCount),
          'marks_per_question': numberOrOne(sections[i].marksPerQuestion),
          if (sections[i].description.isNotEmpty) 'description': sections[i].description,
          'blueprints': [
            for (final rule in sections[i].rules)
              if (rule.topicId.isNotEmpty)
                {
                  'topic_id': rule.topicId,
                  'difficulty_level': rule.difficulty.isNotEmpty ? rule.difficulty : 'EASY',
                  'question_type': rule.questionType.isNotEmpty ? rule.questionType : 'MCQ',
                  'questions_to_pick': numberOrOne(rule.pickCount),
                },
          ],
        },
    ],
  };
}

/// `onImageUpload`: `res?.url || res?.data?.url || res?.file_url`.
String? uploadedImageUrl(dynamic res) {
  final m = asMap(res);
  final url = jsOr(jsOr(m?['url'], dig(m, ['data', 'url'])), m?['file_url']);
  return url == null ? null : jsStr(url);
}
