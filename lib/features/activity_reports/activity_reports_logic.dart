/// Pure data shaping of `src/pages/library/ActivityReports.vue`
/// (`/activityreport`): the option lists of the four filters, the
/// quiz-performance payloads, the activity / student mapping and the
/// error texts. The async flow lives in `activity_reports_controller.dart`.
///
/// The web works on loosely typed JSON with JavaScript coercions
/// (`String(x)`, `Number(x)`, `a || b`); the small `js*` helpers below
/// reproduce them so ids and labels come out exactly as on the web.
library;

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart' show ApiError;

// ── JavaScript coercions ───────────────────────────────────────────────────

/// JS `undefined` — a missing key (`obj.key`), as opposed to JSON `null`.
const Object jsUndefined = _JsUndefined();

class _JsUndefined {
  const _JsUndefined();
  @override
  String toString() => 'undefined';
}

/// `obj?.key`: the value, or [jsUndefined] when [obj] is not an object or
/// has no such key.
Object? jsProp(Object? obj, String key) {
  if (obj is Map) return obj.containsKey(key) ? obj[key] : jsUndefined;
  return jsUndefined;
}

/// JavaScript truthiness: `undefined`, `null`, `false`, `0`, `NaN` and `''`
/// are falsy; everything else (including `[]` / `{}`) is truthy.
bool jsTruthyValue(Object? v) {
  if (v == null || identical(v, jsUndefined)) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// `a || b`
Object? jsOr(Object? a, Object? b) => jsTruthyValue(a) ? a : b;

/// `String(v)`: `5.0` → `'5'`, `null` → `'null'`, `undefined` →
/// `'undefined'`, `NaN` → `'NaN'`, arrays comma-joined, objects
/// `'[object Object]'`.
String jsStringOf(Object? v) {
  if (v == null) return 'null';
  if (identical(v, jsUndefined)) return 'undefined';
  if (v is num) return jsNumberText(v);
  if (v is List) {
    return v.map((e) => e == null || identical(e, jsUndefined) ? '' : jsStringOf(e)).join(',');
  }
  if (v is Map) return '[object Object]';
  return '$v';
}

/// How JavaScript prints a number (`3.0` → `'3'`, `2.5` → `'2.5'`).
String jsNumberText(num n) {
  if (n.isNaN) return 'NaN';
  if (n.isInfinite) return n > 0 ? 'Infinity' : '-Infinity';
  if (n is double && n == n.truncateToDouble() && n.abs() < 1e21) {
    return n.toInt().toString();
  }
  return '$n';
}

/// `Number(v)`: `undefined` → NaN, `null` / `''` → 0, booleans → 1/0,
/// numeric strings parsed, anything else NaN.
num jsNumberOf(Object? v) {
  if (identical(v, jsUndefined)) return double.nan;
  if (v == null) return 0;
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return 0;
    final i = int.tryParse(s);
    if (i != null) return i;
    if (s == '+Infinity') return double.infinity;
    return double.tryParse(s) ?? double.nan; // also 'NaN' / 'Infinity' / '-Infinity'
  }
  if (v is List) return jsNumberOf(jsStringOf(v)); // [] → 0, [5] → 5, [1, 2] → NaN
  return double.nan;
}

/// The property key a number becomes (`obj[1]` → `'1'`); also stands in
/// for JS `Map`/`Set` SameValueZero keys (all NaNs equal, `1` == `1.0`).
String jsNumberKey(num n) => jsNumberText(n == 0 ? 0 : n);

/// `{{ v }}` in a Vue template: `null`/`undefined` → `''`, arrays and plain
/// objects pretty-printed as JSON, everything else `String(v)`.
String vueDisplay(Object? v) {
  if (v == null || identical(v, jsUndefined)) return '';
  if (v is List || v is Map) {
    try {
      return const JsonEncoder.withIndent('  ').convert(v);
    } catch (_) {
      return jsStringOf(v);
    }
  }
  return jsStringOf(v);
}

/// `{ ...a, ...b }` for a JSON value: maps contribute their entries, arrays
/// their indexes, everything else nothing.
void _spreadInto(Map<String, dynamic> target, Object? source) {
  if (source is Map) {
    source.forEach((k, v) => target['$k'] = v);
  } else if (source is List) {
    for (var i = 0; i < source.length; i++) {
      target['$i'] = source[i];
    }
  }
}

// ── models ─────────────────────────────────────────────────────────────────

/// `ClassItem`
class ReportClassOption {
  const ReportClassOption({required this.id, required this.name});
  final String id;
  final String name;
}

/// `BatchItem`
class ReportBatchOption {
  const ReportBatchOption({required this.id, required this.name, required this.classId});
  final String id;
  final String name;
  final String classId;
}

/// `SubjectItem` (a course of the class, with its ZSL class/subject).
class ReportSubjectOption {
  const ReportSubjectOption({
    required this.id,
    required this.name,
    required this.classId,
    required this.zslClassId,
    required this.zslSubjectId,
  });
  final String id;
  final String name;
  final String classId;
  final String zslClassId;
  final String zslSubjectId;

  bool get hasZslMapping => zslClassId.isNotEmpty && zslSubjectId.isNotEmpty;
}

/// `ChapterItem`
class ReportChapterOption {
  const ReportChapterOption({required this.id, required this.name, required this.subjectId});
  final String id;
  final String name;
  final String subjectId;
}

/// `Activity` (one column of the performance table).
class ReportActivity {
  const ReportActivity({
    required this.id,
    required this.code,
    required this.name,
    required this.hasQuiz,
    required this.marks,
    required this.chapterId,
  });

  /// `Number(activity.activity_id)` (may be NaN for a malformed row).
  final num id;

  /// `A1`, `A2`, … in response order.
  final String code;

  /// `activity.activity_name` as rendered by `{{ }}`.
  final String name;
  final bool hasQuiz;

  /// `Math.max(0, Number(total_questions) || 0)`.
  final num marks;
  final String chapterId;

  /// The key `student.scores[activity.id]` uses.
  String get key => jsNumberKey(id);
}

/// `Student` (one row of the performance table).
class ReportStudent {
  ReportStudent({
    required this.id,
    required this.name,
    required this.zslId,
    required this.batchIds,
    Map<String, num>? scores,
  }) : scores = scores ?? <String, num>{};

  final num id;
  final String name;
  final String zslId;
  final List<String> batchIds;

  /// Best score per activity, keyed by [ReportActivity.key].
  final Map<String, num> scores;

  /// `student.name.charAt(0)` (whole first code point, so an emoji does not
  /// split into an unpaired surrogate).
  String get initial => name.isEmpty ? '' : String.fromCharCode(name.runes.first);
}

// ── option lists ───────────────────────────────────────────────────────────

/// `Array.isArray(res) ? res : res?.data || []`, then gated by
/// `list.length > 0`: a non-array `data` (e.g. a paginator object) has no
/// `length`, so it counts as an empty list.
List<dynamic> listOrDataList(Object? body) {
  if (body is List) return body;
  final data = jsProp(body, 'data');
  return data is List ? data : const [];
}

/// `results.flatMap((r) => Array.isArray(r) ? r : r?.data || [])` (batches
/// of "All Classes"): a truthy non-array `data` is kept as one element.
List<dynamic> flatMapListOrData(List<dynamic> responses) {
  final out = <dynamic>[];
  for (final r in responses) {
    if (r is List) {
      out.addAll(r);
      continue;
    }
    final data = jsOr(jsProp(r, 'data'), const <dynamic>[]);
    if (data is List) {
      out.addAll(data);
    } else {
      out.add(data);
    }
  }
  return out;
}

/// `fetchClasses`: `{ id: String(c.id || c.zsl_class_id), name: String(c.name
/// || c.class_name || c.year || 'Unnamed Class') }` (no de-duplication).
List<ReportClassOption> mapReportClasses(List<dynamic> rows) => [
      for (final c in rows)
        ReportClassOption(
          id: jsStringOf(jsOr(jsProp(c, 'id'), jsProp(c, 'zsl_class_id'))),
          name: jsStringOf(jsOr(
              jsOr(jsOr(jsProp(c, 'name'), jsProp(c, 'class_name')), jsProp(c, 'year')),
              'Unnamed Class')),
        ),
    ];

/// `fetchBatches`: de-duplicated by id (a later row wins but keeps the
/// first row's position); `classId` falls back to the selected class.
List<ReportBatchOption> mapReportBatches(List<dynamic> rows, String selectedClass) {
  final unique = <String, ReportBatchOption>{};
  for (final b in rows) {
    final id = jsStringOf(jsProp(b, 'id'));
    unique[id] = ReportBatchOption(
      id: id,
      name: jsStringOf(jsOr(jsProp(b, 'name'), 'Unnamed Batch')),
      classId: jsStringOf(jsOr(jsProp(b, 'classes_id'), selectedClass)),
    );
  }
  return unique.values.toList();
}

/// Whether a course row of `getClassDetails(..).courses` needs
/// `getCourseDetails` to learn its ZSL class / subject.
bool courseNeedsDetails(Object? course) =>
    !(jsTruthyValue(jsProp(course, 'zsl_class_id')) && jsTruthyValue(jsProp(course, 'zsl_subject_id')));

/// `course.id || course.course_id` (the `getCourseDetails` id).
Object courseDetailsId(Object? course) {
  final id = jsOr(jsProp(course, 'id'), jsProp(course, 'course_id'));
  return id == null ? 'null' : (identical(id, jsUndefined) ? 'undefined' : id);
}

/// `{ ...course, ...details, reportClassId }`.
Map<String, dynamic> mergeCourseDetails(Object? course, Object? details, String reportClassId) {
  final out = <String, dynamic>{};
  _spreadInto(out, course);
  _spreadInto(out, details);
  out['reportClassId'] = reportClassId;
  return out;
}

/// `fetchSubjects`: courses (already merged with their details) →
/// subjects, de-duplicated by `String(s.id || s.course_id)`.
List<ReportSubjectOption> mapReportSubjects(List<Map<String, dynamic>> courses) {
  final unique = <String, ReportSubjectOption>{};
  for (final s in courses) {
    final id = jsStringOf(jsOr(jsProp(s, 'id'), jsProp(s, 'course_id')));
    final zslClass = jsProp(s, 'zsl_class_id');
    final zslSubject = jsProp(s, 'zsl_subject_id');
    unique[id] = ReportSubjectOption(
      id: id,
      name: jsStringOf(jsOr(jsOr(jsProp(s, 'title'), jsProp(s, 'name')), 'Unnamed Course')),
      classId: jsStringOf(jsProp(s, 'reportClassId')),
      zslClassId: jsTruthyValue(zslClass) ? jsStringOf(zslClass) : '',
      zslSubjectId: jsTruthyValue(zslSubject) ? jsStringOf(zslSubject) : '',
    );
  }
  return unique.values.toList();
}

/// `response.data ?? response` of `getAllChapters` (the caller checks that
/// it is a list).
Object? chapterPayload(Object? response) {
  final data = jsProp(response, 'data');
  return data == null || identical(data, jsUndefined) ? response : data;
}

/// `chapters.map((chapter) => ({ ...chapter, reportSubjectId }))`.
List<Map<String, dynamic>> tagChapters(List<dynamic> chapters, String reportSubjectId) => [
      for (final ch in chapters) {..._spread(ch), 'reportSubjectId': reportSubjectId},
    ];

Map<String, dynamic> _spread(Object? v) {
  final out = <String, dynamic>{};
  _spreadInto(out, v);
  return out;
}

/// `fetchChapters`: de-duplicated by `String(c.id)`.
List<ReportChapterOption> mapReportChapters(List<Map<String, dynamic>> chapters) {
  final unique = <String, ReportChapterOption>{};
  for (final c in chapters) {
    final id = jsStringOf(jsProp(c, 'id'));
    unique[id] = ReportChapterOption(
      id: id,
      name: jsStringOf(jsOr(jsProp(c, 'name'), 'Unnamed Chapter')),
      subjectId: jsStringOf(jsProp(c, 'reportSubjectId')),
    );
  }
  return unique.values.toList();
}

/// The selection a fetch leaves behind. With options: keep [current] when it
/// is `'all'` or still listed, otherwise pick the first option. Without
/// options: classes reset to `''`; batch / subject / chapter keep `'all'`
/// and otherwise reset to `''`.
String reconcileSelection(String current, List<String> ids, {bool keepAllWhenEmpty = true}) {
  if (ids.isEmpty) return keepAllWhenEmpty && current == 'all' ? 'all' : '';
  final valid = current == 'all' || ids.contains(current);
  return current.isEmpty || !valid ? ids.first : current;
}

// ── computed ───────────────────────────────────────────────────────────────

/// `hasActiveFilters`: all four selects have a value (`'all'` counts).
bool hasActiveReportFilters(String cls, String batch, String subject, String chapter) =>
    cls.isNotEmpty && batch.isNotEmpty && subject.isNotEmpty && chapter.isNotEmpty;

List<ReportBatchOption> filterBatches(List<ReportBatchOption> batches, String selectedClass) =>
    selectedClass == 'all' ? batches : batches.where((b) => b.classId == selectedClass).toList();

List<ReportSubjectOption> filterSubjects(List<ReportSubjectOption> subjects, String selectedClass) =>
    selectedClass == 'all' ? subjects : subjects.where((s) => s.classId == selectedClass).toList();

List<ReportChapterOption> filterChapters(List<ReportChapterOption> chapters, String selectedSubject) =>
    selectedSubject == 'all'
        ? chapters
        : chapters.where((c) => c.subjectId == selectedSubject).toList();

/// `displayedActivities` (every activity — deliberately no `slice` — for
/// "All Chapters").
List<ReportActivity> displayReportActivities(List<ReportActivity> activities, String selectedChapter) =>
    selectedChapter == 'all'
        ? activities
        : activities.where((a) => a.chapterId == selectedChapter).toList();

/// `displayedStudents`
List<ReportStudent> displayReportStudents(List<ReportStudent> students, String selectedBatch) =>
    selectedBatch == 'all'
        ? students
        : students.where((s) => s.batchIds.contains(selectedBatch)).toList();

/// `selectedClassName` & co.: the `'all'` label, the name of the option
/// with that id (searched in the unfiltered list), or `''`.
String selectedOptionName<T>(
    String selected, String allLabel, List<T> options, String Function(T) id, String Function(T) name) {
  if (selected == 'all') return allLabel;
  for (final o in options) {
    if (id(o) == selected) return name(o);
  }
  return '';
}

/// "1 activity" / "N activities".
String activityCountLabel(int n) => '$n ${n == 1 ? 'activity' : 'activities'}';

/// Text under an activity card: `hasQuiz ? `${marks} marks` : 'No quiz'`.
String activityMarksLabel(ReportActivity a) => a.hasQuiz ? '${jsNumberText(a.marks)} marks' : 'No quiz';

/// `getScore(student, activityId)`: the best score, or `null` when not
/// attempted.
num? reportScore(ReportStudent student, ReportActivity activity) => student.scores[activity.key];

/// Stars drawn for a score: `v-for="star in score"` (a fractional score
/// rounds up, as the loop runs while `i < score`).
int starCount(num score) => score.isFinite && score > 0 ? score.ceil() : 0;

// ── scores ─────────────────────────────────────────────────────────────────

const instituteRequiredMessage = 'An institute is required to view reports.';
const missingMappingMessage =
    'This course is missing its ZSL class or subject mapping. Please configure the course mapping.';
const unreadableChaptersMessage = 'Unable to read ZSL chapters.';
const invalidChapterMessage = 'Please select a valid ZSL chapter.';
const invalidSubjectMappingMessage = 'The selected course needs a valid ZSL class and subject mapping.';
const unexpectedFormatMessage = 'The activity report response has an unexpected format.';

/// The `getQuizPerformance` payloads of `fetchScores`: one institute-wide
/// request for All Classes + All Subjects + All Chapters, otherwise one per
/// distinct ZSL class/subject (+ chapter). Throws [ApiError] like the web.
///
/// Web quirk kept: with a specific class, "All Subjects" fails when any of
/// the class's courses lacks a ZSL mapping (the chapter list silently skips
/// such courses).
List<Map<String, dynamic>> quizPerformancePayloads({
  required String instituteId,
  required String selectedClass,
  required String selectedSubject,
  required String selectedChapter,
  required List<ReportSubjectOption> subjects,
  required List<ReportChapterOption> chapters,
}) {
  ReportChapterOption? chapter;
  for (final c in chapters) {
    if (c.id == selectedChapter) {
      chapter = c;
      break;
    }
  }
  if (selectedChapter != 'all' && chapter == null) throw const ApiError(invalidChapterMessage);
  final instituteWide = selectedClass == 'all' && selectedSubject == 'all' && selectedChapter == 'all';
  final selected = subjects
      .where((s) =>
          (selectedSubject == 'all' || s.id == selectedSubject) &&
          (selectedChapter == 'all' || s.id == chapter?.subjectId))
      .toList();
  if (!instituteWide && (selected.isEmpty || selected.any((s) => !s.hasZslMapping))) {
    throw const ApiError(invalidSubjectMappingMessage);
  }
  if (instituteWide) {
    return [
      {'institute_id': instituteId},
    ];
  }
  final unique = <String, Map<String, dynamic>>{};
  for (final s in selected) {
    final payload = <String, dynamic>{
      'institute_id': instituteId,
      'classes_id': s.zslClassId,
      'subject_id': s.zslSubjectId,
      if (selectedChapter != 'all') 'chapter_id': selectedChapter,
    };
    unique[jsonEncode(payload)] = payload;
  }
  return unique.values.toList();
}

/// The merged `getQuizPerformance` responses: activities de-duplicated by
/// `Number(activity_id)` (first position, last row wins), students
/// concatenated.
typedef QuizPerformance = ({List<dynamic> activities, List<dynamic> students});

/// Validates every response (`activities` and `students` must be arrays,
/// else [unexpectedFormatMessage]) and merges them.
QuizPerformance mergeQuizResponses(List<dynamic> responses) {
  for (final r in responses) {
    if (jsProp(r, 'activities') is! List || jsProp(r, 'students') is! List) {
      throw const ApiError(unexpectedFormatMessage);
    }
  }
  final activities = <String, dynamic>{};
  final students = <dynamic>[];
  for (final r in responses) {
    for (final a in jsProp(r, 'activities') as List) {
      activities[jsNumberKey(jsNumberOf(jsProp(a, 'activity_id')))] = a;
    }
    students.addAll(jsProp(r, 'students') as List);
  }
  return (activities: activities.values.toList(), students: students);
}

/// `this.activities = response.activities.map(...)`.
List<ReportActivity> mapReportActivities(List<dynamic> rows) => [
      for (var i = 0; i < rows.length; i++)
        ReportActivity(
          id: jsNumberOf(jsProp(rows[i], 'activity_id')),
          code: 'A${i + 1}',
          name: vueDisplay(jsProp(rows[i], 'activity_name')),
          chapterId: jsStringOf(jsProp(rows[i], 'chapter_id')),
          marks: _marks(jsNumberOf(jsProp(rows[i], 'total_questions'))),
          hasQuiz: jsProp(rows[i], 'has_quiz') == true,
        ),
    ];

/// `Math.max(0, Number(x) || 0)`
num _marks(num n) {
  final v = jsTruthyValue(n) ? n : 0;
  return v > 0 ? v : 0;
}

/// Rows of one `studentService.getStudents` page: `data` (or the response
/// itself) when it is an array, otherwise its object values that look like
/// records (`'id' in item`).
List<dynamic> studentPageRows(Object? response) {
  final d = jsProp(response, 'data');
  final data = d == null || identical(d, jsUndefined) ? response : d;
  if (data is List) return data;
  if (data is Map) {
    return data.values.where((item) => item is Map && item.containsKey('id')).toList();
  }
  return const [];
}

/// `Number(response.last_page || 1)`
num studentLastPage(Object? response) => jsNumberOf(jsOr(jsProp(response, 'last_page'), 1));

/// `fetchInstituteStudents`: rows of every class page → students,
/// de-duplicated by `Number(row.id)` with their batch ids merged. Rows of
/// another institute and rows without a numeric id are skipped; when a
/// batch is selected it is added to every row's batch ids.
List<ReportStudent> mapInstituteStudents(List<dynamic> rows, String instituteId, String? batchId) {
  final students = <String, ReportStudent>{};
  for (final row in rows) {
    if (row == null) continue;
    final institute = jsProp(row, 'institute_id');
    if (institute != null && !identical(institute, jsUndefined) && jsStringOf(institute) != instituteId) {
      continue;
    }
    final id = jsNumberOf(jsProp(row, 'id'));
    if (!id.isFinite) continue;
    final batches = jsOr(jsProp(row, 'batches'), const <dynamic>[]);
    final batchIds = [
      if (batches is List)
        for (final b in batches) jsStringOf(jsProp(b, 'id')),
    ];
    if (batchId != null && batchId.isNotEmpty && !batchIds.contains(batchId)) batchIds.add(batchId);
    final key = jsNumberKey(id);
    final existing = students[key];
    final user = jsProp(row, 'user');
    final fullName = [jsProp(user, 'first_name'), jsProp(user, 'last_name')]
        .where(jsTruthyValue)
        .map(jsStringOf)
        .join(' ');
    final zslId = jsProp(row, 'zsl_id');
    students[key] = ReportStudent(
      id: id,
      zslId: zslId == null || identical(zslId, jsUndefined) ? '' : jsStringOf(zslId),
      name: jsStringOf(jsOr(jsOr(fullName, jsProp(user, 'email')), 'Unnamed student')),
      batchIds: <String>{...?existing?.batchIds, ...batchIds}.toList(),
    );
  }
  return students.values.toList();
}

/// Fills `student.scores` from the performance rows: per ZSL sub-user, the
/// best `best_score` of every attempted activity that is in [activities].
List<ReportStudent> applyReportScores(
    List<ReportStudent> students, List<dynamic> performanceRows, List<ReportActivity> activities) {
  final performance = <String, List<dynamic>>{};
  for (final s in performanceRows) {
    final id = jsStringOf(jsProp(s, 'sub_user_id'));
    final rows = jsOr(jsProp(s, 'activities'), const <dynamic>[]);
    performance[id] = [...?performance[id], if (rows is List) ...rows];
  }
  final activityIds = {for (final a in activities) a.key};
  for (final student in students) {
    for (final attempt in performance[student.zslId] ?? const <dynamic>[]) {
      final score = jsNumberOf(jsProp(attempt, 'best_score'));
      final key = jsNumberKey(jsNumberOf(jsProp(attempt, 'activity_id')));
      if (jsProp(attempt, 'is_attempted') == true &&
          activityIds.contains(key) &&
          score.isFinite &&
          score >= 0) {
        final previous = student.scores[key] ?? 0;
        student.scores[key] = previous >= score ? previous : score;
      }
    }
  }
  return students;
}

// ── errors ─────────────────────────────────────────────────────────────────

/// `error.message` of what the web can catch: axios errors
/// (`Request failed with status code N` / `Network Error`) and the page's
/// own `new Error(text)`; [fallback] otherwise.
String jsErrorText(Object error, String fallback) {
  if (error is ApiError) return error.message;
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status != null) return 'Request failed with status code $status';
    return 'Network Error';
  }
  return fallback;
}

/// `loadFilters` catch: `error.message` or 'Unable to load report filters.'
String filterErrorMessage(Object error) => jsErrorText(error, 'Unable to load report filters.');

/// `fetchScores` catch: the API's validation `errors` (all messages joined),
/// else its `message` / `msg`, else the error's own message.
String scoreErrorMessage(Object error) {
  final data = error is DioException ? error.response?.data : null;
  final errors = jsProp(data, 'errors');
  var details = '';
  if (jsTruthyValue(errors)) {
    final values = errors is Map ? errors.values : (errors is List ? errors : const <dynamic>[]);
    details = values
        .expand((v) => v is List ? v : [v])
        .map((v) => v == null || identical(v, jsUndefined) ? '' : jsStringOf(v))
        .join(' ');
  }
  final message = jsOr(jsOr(details, jsProp(data, 'message')), jsProp(data, 'msg'));
  if (jsTruthyValue(message)) return jsStringOf(message);
  return jsErrorText(error, 'Unable to load activity reports.');
}
