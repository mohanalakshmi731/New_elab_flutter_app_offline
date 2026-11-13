/// Pure helpers behind the question / exam management ports
/// (`createquestion.vue`, `EditExams.vue`, `ViewExams.vue`,
/// `ExamAttempts.vue`, `ExamResults.vue`), written with the JavaScript
/// semantics the web relied on (`String(x)`, `Number(x)`, `x || y`, Vue's
/// number casting of `<input type="number">`, `toLocaleString`). Free of
/// Flutter so they can be unit-tested.
library;

import 'package:intl/intl.dart';

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';

typedef Json = Map<String, dynamic>;

/// `Locale` from `src/types/enums.ts` (key = label, value = stored value).
const examLocales = <String, String>{
  'All': 'all',
  'Telugu': 'te',
  'English': 'en',
};

/// `defaultLocale` (`Locale.English`).
const defaultExamLocale = 'en';

/// `EditExams.languageOptions` — only the two-letter locales.
List<MapEntry<String, String>> get examLanguageOptions =>
    [for (final e in examLocales.entries) if (e.value.length == 2) e];

List<Json> mapsOf(Object? list) => [for (final e in asList(list)) ?asMap(e)];

// ── JS coercions ───────────────────────────────────────────────────────────

/// JS `String(v)` for a present value (`null` → `'null'`; integral doubles
/// print without `.0`).
String jsStr(Object? v) {
  if (v == null) return 'null';
  if (v is double && v.isFinite && v == v.truncateToDouble()) {
    return v.toInt().toString();
  }
  return v.toString();
}

/// JS `String(obj.key)` — `'undefined'` when [m] is not an object or lacks
/// [key].
String jsField(Object? m, String key) {
  final map = asMap(m);
  if (map == null || !map.containsKey(key)) return 'undefined';
  return jsStr(map[key]);
}

/// `{{ v }}` in a Vue template: null/undefined render as ''.
String vueText(Object? v) => v == null ? '' : jsStr(v);

/// JS `Number(v)`: numbers as-is, `''`/whitespace → 0, `null` → 0,
/// booleans → 1/0, unparsable strings (and anything else) → NaN.
num jsNumber(Object? v) {
  if (v == null) return 0;
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return 0;
    final i = int.tryParse(s);
    if (i != null) return i;
    final d = double.tryParse(s);
    if (d != null) return d;
    if (s == 'Infinity' || s == '+Infinity') return double.infinity;
    if (s == '-Infinity') return double.negativeInfinity;
    return double.nan;
  }
  return double.nan;
}

/// `Number(obj.key)` — a missing key is `undefined` → NaN.
num jsNumberField(Object? m, String key) {
  final map = asMap(m);
  if (map == null || !map.containsKey(key)) return double.nan;
  return jsNumber(map[key]);
}

/// `n.toFixed(digits)` (`NaN` → `'NaN'`).
String jsToFixed(num n, int digits) {
  if (n.isNaN) return 'NaN';
  if (n.isInfinite) return n > 0 ? 'Infinity' : '-Infinity';
  return n.toStringAsFixed(digits);
}

/// What `v-model` on an `<input type="number">` stores (Vue's
/// `looseToNumber`): the parsed number, or the raw text when it does not
/// parse (`''` stays `''`).
Object vueNumberInput(String text) {
  final t = text.trim();
  if (t.isEmpty) return text;
  final i = int.tryParse(t);
  if (i != null) return i;
  final d = double.tryParse(t);
  if (d != null && !d.isNaN) return d;
  return text;
}

/// The value `JSON.stringify` writes for a JS number: NaN/±Infinity become
/// `null`, integral doubles become ints.
Object? jsonNum(num n) {
  if (n.isNaN || n.isInfinite) return null;
  if (n is double && n == n.truncateToDouble() && n.abs() < 9007199254740992) {
    return n.toInt();
  }
  return n;
}

/// A raw form value as `JSON.stringify` sends it (numbers through [jsonNum]).
Object? jsonVal(Object? v) => v is num ? jsonNum(v) : v;

/// The text an `<Input v-model>` shows for a stored value.
String inputText(Object? v) {
  if (v == null) return '';
  if (v is double && (v.isNaN || v.isInfinite)) return '';
  return jsStr(v);
}

/// Whether a plain `<input type="checkbox" v-model>` is checked: Vue's
/// `looseEqual(value, true)` compares `String(value) === 'true'`, so `1`
/// shows unchecked while `v-if="value"` still treats it as truthy.
bool vueChecked(Object? v) => v is bool ? v : jsStr(v) == 'true';

// ── dates ──────────────────────────────────────────────────────────────────

final _dateOnly = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// `new Date(v)` (local time); `null` → the epoch, unparsable / undefined →
/// `null` (Invalid Date). Date-only ISO strings are UTC like in JS.
DateTime? jsDate(Object? v, {bool isUndefined = false}) {
  if (isUndefined) return null;
  if (v == null) return DateTime.fromMillisecondsSinceEpoch(0);
  if (v is num) return v.isFinite ? DateTime.fromMillisecondsSinceEpoch(v.toInt()) : null;
  if (v is DateTime) return v.toLocal();
  final s = v.toString().trim();
  if (_dateOnly.hasMatch(s)) {
    final d = DateTime.tryParse('${s}T00:00:00Z');
    return d?.toLocal();
  }
  final d = DateTime.tryParse(s);
  if (d == null) return null;
  return d.isUtc ? d.toLocal() : d;
}

/// `new Date(obj.key).toLocaleString()` (en-US: `1/15/2025, 10:30:00 AM`).
String jsLocaleStringField(Object? m, String key) {
  final map = asMap(m);
  final d = jsDate(map?[key], isUndefined: map == null || !map.containsKey(key));
  if (d == null) return 'Invalid Date';
  return DateFormat('M/d/yyyy, h:mm:ss a', 'en_US').format(d);
}

/// `date.toLocaleDateString()` (en-US `M/d/yyyy`).
String jsLocaleDateString(DateTime d) => DateFormat('M/d/yyyy', 'en_US').format(d);

/// `new Date(v).toLocaleString('en-IN', { dateStyle: 'medium', timeStyle:
/// 'short' })` → `15 Jan 2025, 10:30 am`.
String enInMediumShort(Object? v) {
  final d = jsDate(v);
  if (d == null) return 'Invalid Date';
  final date = DateFormat('d MMM y', 'en_US').format(d);
  final time = DateFormat('h:mm a', 'en_US').format(d).toLowerCase();
  return '$date, $time';
}

/// `getHours().padStart(2,'0') + ':' + getMinutes().padStart(2,'0')`.
String hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

/// How a browser `<input type="time">` (en-US) shows an `HH:mm` value.
String timeInputDisplay(String value) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(value);
  if (m == null) return '';
  final h = int.parse(m.group(1)!);
  final min = m.group(2)!;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '${h12.toString().padLeft(2, '0')}:$min ${h < 12 ? 'AM' : 'PM'}';
}

// ── createquestion.vue ─────────────────────────────────────────────────────

final _driveD = RegExp(r'/d/([-\w]{25,})');
final _driveId = RegExp(r'[?&]id=([-\w]{25,})');

/// `convertDriveUrl(url)` — Google Drive share links → direct view links.
String convertDriveUrl(String url) {
  if (url.isEmpty) return '';
  if (!url.contains('drive.google.com')) return url;
  final m = _driveD.firstMatch(url) ?? _driveId.firstMatch(url);
  if (m == null) return url;
  return 'https://drive.google.com/uc?export=view&id=${m.group(1)}';
}

/// `videoEmbedUrl` — YouTube / Drive / direct mp4 preview URL, or ''.
String videoEmbedUrl(String videoUrl) {
  if (videoUrl.isEmpty) return '';
  final url = videoUrl.trim();
  final yt = RegExp(r'youtube\.com/watch\?v=([^&]+)').firstMatch(url) ??
      RegExp(r'youtu\.be/([^?]+)').firstMatch(url);
  if (yt != null) return 'https://www.youtube.com/embed/${yt.group(1)}';
  final drive = _driveD.firstMatch(url) ?? _driveId.firstMatch(url);
  if (drive != null) return 'https://drive.google.com/file/d/${drive.group(1)}/preview';
  if (url.endsWith('.mp4')) return url;
  return '';
}

/// `res?.data?.file_url || res?.file_url || res?.url` of `uploadExamFile`.
String? uploadedFileUrl(Object? res) {
  final m = asMap(res);
  final candidates = [dig(m, const ['data', 'file_url']), m?['file_url'], m?['url']];
  for (final c in candidates) {
    if (jsTruthy(c)) return jsStr(c);
  }
  final last = candidates.last;
  return last == null ? null : jsStr(last);
}

/// `String.fromCharCode(65 + i)`
String optionLabel(int index) => String.fromCharCode(65 + index);

/// `tagsInput.split(',').map(t => t.trim()).filter(Boolean)`
List<String> parseTags(String input) =>
    [for (final t in input.split(',')) if (t.trim().isNotEmpty) t.trim()];

/// `filteredContents` — the store `contents` of the selected chapter.
List<Json> contentsOfChapter(List<Json> contents, String selectedChapterId) {
  if (selectedChapterId.isEmpty) return const [];
  return [for (final c in contents) if (jsField(c, 'chapter_id') == selectedChapterId) c];
}

/// `selectedCourseExamId` — `String(course?.exam_course_id ?? '')` of the
/// course whose `id` is [selectedCourseId].
String selectedCourseExamId(List<Json> courses, String selectedCourseId) {
  for (final c in courses) {
    if (jsField(c, 'id') == selectedCourseId) {
      return c['exam_course_id'] == null ? '' : jsStr(c['exam_course_id']);
    }
  }
  return '';
}

/// `saveQuestion`: `String(section.exam_section_id ?? section.id)` of the
/// section holding the chapter [selectedChapterId], or ''.
String examSectionIdFor(List<Json> sections, String selectedChapterId) {
  for (final section in sections) {
    for (final ch in mapsOf(section['chapters'])) {
      if (jsField(ch, 'id') == selectedChapterId) {
        return jsStr(section['exam_section_id'] ?? section['id']);
      }
    }
  }
  return '';
}

/// One MCQ option of the form (`{ label, text, correct, image }`).
typedef QuestionOptionValue = ({Object? label, String text, Object? correct, String image});

/// One question-level image of the form (`{ url, caption, order_index }`);
/// [orderIndex] is what `v-model` stored (number, `''` or raw text).
typedef QuestionImageValue = ({String url, String caption, Object? orderIndex});

/// The `payload` built by `saveQuestion()` (before the store adds
/// `institute_id`). `undefined` values are omitted like `JSON.stringify`.
Json buildQuestionPayload({
  required String code,
  required String stem,
  required String questionType,
  required String examSectionId,
  required String difficulty,
  required Object? marks,
  required Object? negativeMarks,
  required String explanation,
  required Object? isActive,
  required String selectedContentId,
  required String selectedCourseExamId,
  required String videoUrl,
  required List<QuestionOptionValue> options,
  required List<QuestionImageValue> images,
  required List<String> tags,
  required String defaultLocale,
}) {
  final kept = [for (final img in images) if (img.url.isNotEmpty) img];
  return {
    'code': code,
    'title': stem,
    'type': questionType,
    'exam_section_id': examSectionId,
    'difficulty_level': difficulty,
    'marks': jsonVal(marks),
    'negative_marks': jsonVal(negativeMarks),
    'explanation': explanation,
    'is_active': jsonVal(isActive),
    'exam_chapter_id': selectedContentId,
    'exam_course_id': selectedCourseExamId,
    'video_url': convertDriveUrl(videoUrl),
    if (questionType == 'MCQ')
      'options': [
        for (var i = 0; i < options.length; i++)
          {
            'label': options[i].label,
            'text': options[i].text,
            'is_correct': jsonVal(options[i].correct),
            'order_index': i + 1,
            'image_url': convertDriveUrl(options[i].image),
          },
      ],
    'images': [
      for (var i = 0; i < kept.length; i++)
        {
          'image_url': convertDriveUrl(kept[i].url),
          'caption': kept[i].caption.isNotEmpty ? kept[i].caption : '',
          'order_index': jsonNum(jsNumber(jsTruthy(kept[i].orderIndex) ? kept[i].orderIndex : i + 1)),
        },
    ],
    'tags': [...tags],
    'default_locale': defaultLocale,
  };
}

/// The store's `createExamQuestion(payload)` body: only the listed keys are
/// forwarded (so `tags` is dropped), `topic_id` is never set.
Json createQuestionBody(String instituteId, Json payload) {
  const keys = [
    'code',
    'title',
    'type',
    'exam_section_id',
    'exam_chapter_id',
    'exam_course_id',
    'difficulty_level',
    'marks',
    'negative_marks',
    'explanation',
    'is_active',
    'topic_id',
    'options',
    'images',
    'video_url',
    'default_locale',
  ];
  return {
    'institute_id': instituteId,
    for (final k in keys)
      if (payload.containsKey(k)) k: payload[k],
  };
}

/// `loadQuestionForEdit` — the basic form fields read from question [q].
({
  String code,
  String questionType,
  String stem,
  num marks,
  num negativeMarks,
  String explanation,
  bool isActive,
  String difficulty,
  String videoUrl,
  List<String> tags,
  String tagsInput,
  String defaultLocale,
}) questionFormFrom(Json q) {
  final tags = [
    for (final t in asList(q['tags'] ?? const []))
      if (asMap(t) case final m?) m['tag'] == null ? '' : jsStr(m['tag']) else '',
  ];
  return (
    code: q['code'] == null ? '' : jsStr(q['code']),
    questionType: q['question_type'] == null ? 'MCQ' : jsStr(q['question_type']),
    stem: q['stem'] == null ? '' : jsStr(q['stem']),
    marks: jsNumber(q['marks'] ?? 0),
    negativeMarks: jsNumber(q['negative_marks'] ?? 0),
    explanation: q['explanation'] == null ? '' : jsStr(q['explanation']),
    isActive: jsTruthy(q['is_active']),
    difficulty: jsTruthy(q['difficulty_level']) ? jsStr(q['difficulty_level']) : '',
    videoUrl: jsTruthy(q['video_url']) ? jsStr(q['video_url']) : '',
    tags: tags,
    tagsInput: tags.join(', '),
    defaultLocale: jsTruthy(q['default_locale']) ? jsStr(q['default_locale']) : defaultExamLocale,
  );
}

/// `String(q.course_id || q.course?.id || q.subject?.course_id)` — a missing
/// value is `'undefined'` (which then matches courses without an
/// `exam_course_id`, like on the web).
String questionExamCourseKey(Json q) {
  if (jsTruthy(q['course_id'])) return jsStr(q['course_id']);
  final courseId = dig(q, const ['course', 'id']);
  if (jsTruthy(courseId)) return jsStr(courseId);
  return jsField(q['subject'], 'course_id');
}

/// The course whose `String(exam_course_id)` equals [examCourseKey].
Json? courseByExamKey(List<Json> courses, String examCourseKey) {
  for (final c in courses) {
    if (jsField(c, 'exam_course_id') == examCourseKey) return c;
  }
  return null;
}

/// `loadQuestionForEdit`'s chapter / content lookup: only the FIRST section
/// whose `exam_section_id` equals `q.subject_id` is searched (the loop
/// breaks after it either way). Returns `null` when nothing matched.
({String chapterId, String contentId})? locateQuestionTopic(List<Json> sections, Json q) {
  final subjectId = jsField(q, 'subject_id');
  final topicId = jsField(q, 'topic_id');
  for (final section in sections) {
    if (jsField(section, 'exam_section_id') != subjectId) continue;
    for (final chapter in mapsOf(section['chapters'])) {
      for (final c in mapsOf(chapter['contents'])) {
        if (jsField(c, 'exam_content_id') == topicId) {
          return (chapterId: jsField(chapter, 'id'), contentId: jsField(c, 'exam_content_id'));
        }
      }
    }
    break;
  }
  return null;
}

/// `q.options.sort((a, b) => a.order_index - b.order_index)` as V8 runs it
/// on short arrays: a NaN comparison counts as 0 (spec), the leading run is
/// detected (and reversed when strictly descending), the rest is binary
/// insertion sorted (stable).
List<Json> sortedByOrderIndex(List<Json> options) {
  final a = [...options];
  final n = a.length;
  if (n < 2) return a;
  num cmp(Json x, Json y) {
    final v = jsNumberField(x, 'order_index') - jsNumberField(y, 'order_index');
    return v.isNaN ? 0 : v;
  }

  // CountAndMakeRun
  var runLength = 2;
  final descending = cmp(a[1], a[0]) < 0;
  var previous = a[1];
  for (var i = 2; i < n; i++) {
    final order = cmp(a[i], previous);
    if (descending ? order >= 0 : order < 0) break;
    previous = a[i];
    runLength++;
  }
  if (descending) {
    final run = a.sublist(0, runLength).reversed.toList();
    a.setRange(0, runLength, run);
  }

  // BinaryInsertionSort
  for (var start = runLength; start < n; start++) {
    final pivot = a[start];
    var left = 0;
    var right = start;
    while (left < right) {
      final mid = left + ((right - left) >> 1);
      if (cmp(pivot, a[mid]) < 0) {
        right = mid;
      } else {
        left = mid + 1;
      }
    }
    for (var p = start; p > left; p--) {
      a[p] = a[p - 1];
    }
    a[left] = pivot;
  }
  return a;
}

// ── EditExams.vue ──────────────────────────────────────────────────────────

/// `selectedSectionChapters` — the chapters of the FIRST store section.
List<Json> firstSectionChapters(List<Json> sections) {
  if (sections.isEmpty) return const [];
  return mapsOf(sections.first['chapters']);
}

/// `topics` — the contents of the chapter whose `exam_chapter_id` is
/// [selectedSubjectId] (first match across the sections).
List<Json> topicsOfSubject(List<Json> sections, String selectedSubjectId) {
  if (selectedSubjectId.isEmpty) return const [];
  for (final section in sections) {
    for (final c in mapsOf(section['chapters'])) {
      if (jsField(c, 'exam_chapter_id') == selectedSubjectId) {
        return jsTruthy(c['contents']) ? mapsOf(c['contents']) : const [];
      }
    }
  }
  return const [];
}

/// A new section as pushed by "Add Section" (and the initial one).
Json newEditSection() => {
      'name': '',
      'description': '',
      'question_count': 0,
      'marks_per_question': 0,
      'rules': [newEditRule()],
    };

/// A new rule as pushed by "Add Rule".
Json newEditRule() => {
      'topic_id': '',
      'difficulty': '',
      'question_type': '',
      'tags': '',
      'pick_count': 0,
    };

/// `exam.x ?? fallback`
Object? _orNull(Object? v, Object? fallback) => v ?? fallback;

/// The form values `mounted()` reads from the exam (basic info + settings).
Json editExamFormFrom(Json exam) {
  final srs = exam['show_results_to_student_at'];
  return {
    'locale': jsTruthy(exam['locale']) ? exam['locale'] : defaultExamLocale,
    'name': _orNull(exam['name'], ''),
    'code': _orNull(exam['code'], ''),
    'description': _orNull(exam['description'], ''),
    'exam_type': _orNull(exam['exam_type'], 'EXAM'),
    'duration_minutes': _orNull(exam['duration_minutes'], 0),
    'max_attempts': _orNull(exam['max_attempts'], 0),
    'enable_negative_marking': _orNull(exam['allow_negative_marking'], false),
    'negative_marks': jsNumber(jsTruthy(exam['default_negative_marks']) ? exam['default_negative_marks'] : 0),
    'randomize_question_order': _orNull(exam['randomize_question_order'], false),
    'randomize_options_order': _orNull(exam['randomize_option_order'], false),
    'show_immediate_feedback':
        exam['show_immediate_feedback'] == true || exam['show_immediate_feedback'] == 'true',
    // API returns e.g. "AFTER_EXAM"; the web strips the underscores.
    'show_results_to_student_at': srs is String ? srs.replaceAll('_', '').toLowerCase() : '',
    'is_open_anytime': _orNull(exam['is_open_anytime'], false),
  };
}

/// `exam.sections?.map(...) ?? []` of `mounted()`.
List<Json> editSectionsFromExam(Json exam) => [
      for (final sec in mapsOf(exam['sections']))
        {
          'name': _orNull(sec['name'], ''),
          'description': _orNull(sec['description'], ''),
          'question_count': jsNumber(jsTruthy(sec['question_count']) ? sec['question_count'] : 0),
          'marks_per_question': jsNumber(jsTruthy(sec['marks_per_question']) ? sec['marks_per_question'] : 0),
          'rules': [
            for (final bp in mapsOf(sec['blueprints']))
              {
                'topic_id': _orNull(bp['topic_id'], ''),
                'difficulty': _orNull(bp['difficulty_level'], ''),
                'question_type': _orNull(bp['question_type'], ''),
                'tags': _orNull(bp['tag'], ''),
                'pick_count': _orNull(bp['questions_to_pick'], 0),
              },
          ],
        },
    ];

/// The topic mapping at the end of `mounted()`: for every blueprint whose
/// topic is a content of [courseSections], `selectedSubjectId` becomes that
/// chapter's `exam_chapter_id` (the last match wins) and the blueprint's
/// `topic_id` is rewritten (mutating [exam], as the web mutated the store
/// object). Returns the last subject id set, or null.
String? mapExamTopics(Json exam, List<Json> courseSections) {
  if (!jsTruthy(exam['sections']) || courseSections.isEmpty) return null;
  String? subject;
  for (final sec in mapsOf(exam['sections'])) {
    for (final bp in mapsOf(sec['blueprints'])) {
      final topicId = bp['topic_id'];
      if (!jsTruthy(topicId)) continue;
      final wanted = jsStr(topicId);
      var found = false;
      for (final section in courseSections) {
        for (final chapter in mapsOf(section['chapters'])) {
          for (final c in mapsOf(chapter['contents'])) {
            if (jsField(c, 'exam_content_id') == wanted) {
              subject = jsField(chapter, 'exam_chapter_id');
              bp['topic_id'] = jsField(c, 'exam_content_id');
              found = true;
              break;
            }
          }
          if (found) break;
        }
        if (found) break;
      }
    }
  }
  return subject;
}

/// The `payload` built by `updateExamHandler()` (before the store adds
/// `institute_id`). Text fields hold what the inputs show; `Number(...)` is
/// applied like the web.
Json buildUpdateExamPayload({
  required String locale,
  required String name,
  required String code,
  required String description,
  required String examType,
  required String durationMinutes,
  required String maxAttempts,
  required Object? enableNegativeMarking,
  required String negativeMarks,
  required Object? randomizeQuestionOrder,
  required Object? randomizeOptionsOrder,
  required bool showImmediateFeedback,
  required String showResultsToStudentAt,
  required String selectedCourseId,
  required String selectedSubjectId,
  required String selectedBatchId,
  required Object? isOpenAnytime,
  required List<Json> sections,
  required String imageUrl,
  required String imageCaption,
  required String imageOrder,
}) {
  num orOne(num n) => jsTruthy(n) ? n : 1;
  return {
    'locale': locale,
    'name': name,
    'code': code,
    'description': description,
    'exam_type': examType,
    'duration_minutes': jsonNum(jsNumber(durationMinutes)),
    'max_attempts': jsonNum(jsNumber(maxAttempts)),
    'allow_negative_marking': jsonVal(enableNegativeMarking),
    'default_negative_marks': jsonNum(jsNumber(negativeMarks)),
    'randomize_question_order': jsonVal(randomizeQuestionOrder),
    'randomize_option_order': jsonVal(randomizeOptionsOrder),
    'show_immediate_feedback': showImmediateFeedback,
    'show_results_to_student_at': showResultsToStudentAt.toUpperCase(),
    'course_id': selectedCourseId.isNotEmpty ? selectedCourseId : null,
    'subject_id': selectedSubjectId.isNotEmpty ? selectedSubjectId : null,
    'batch_id': selectedBatchId.isNotEmpty ? selectedBatchId : null,
    'is_open_anytime': jsonVal(isOpenAnytime),
    'sections': [
      for (var i = 0; i < sections.length; i++)
        {
          'name': sections[i]['name'],
          'description': sections[i]['description'],
          'question_count': jsonNum(jsNumber(sections[i]['question_count'])),
          'marks_per_question': jsonNum(jsNumber(sections[i]['marks_per_question'])),
          'section_order': i + 1,
          'blueprints': [
            for (final r in mapsOf(sections[i]['rules']))
              {
                'topic_id': jsonVal(r['topic_id']),
                'difficulty_level': jsTruthy(r['difficulty']) ? r['difficulty'] : 'EASY',
                'question_type': jsTruthy(r['question_type']) ? r['question_type'] : 'MCQ',
                'tag': jsTruthy(r['tags']) ? r['tags'] : null,
                'questions_to_pick': jsonNum(orOne(jsNumber(r['pick_count']))),
              },
          ],
        },
    ],
    'images': imageUrl.isNotEmpty
        ? [
            {
              'image_url': imageUrl,
              'caption': imageCaption.isNotEmpty ? imageCaption : null,
              'order_index': jsonNum(orOne(jsNumber(vueNumberInput(imageOrder)))),
            },
          ]
        : const [],
  };
}

// ── store actions ──────────────────────────────────────────────────────────

/// `fetchExamAttempts`: `res?.data ?? res?.response ?? res ?? []`, then the
/// array itself or its `.data`. Returns null when that is not an array (the
/// store throws).
List<dynamic>? attemptsFromResponse(Object? res) {
  final m = asMap(res);
  final payload = m?['data'] ?? m?['response'] ?? res ?? const [];
  if (payload is List) return payload;
  final inner = asMap(payload)?['data'];
  return inner is List ? inner : null;
}

// ── ExamResults.vue ────────────────────────────────────────────────────────

/// `q.response?.selected_option_ids?.includes(optId)` — arrays compare by
/// value; a string does a substring search like `String.prototype.includes`.
bool selectedIncludes(Object? selectedOptionIds, Object? optId) {
  if (selectedOptionIds is List) return selectedOptionIds.contains(optId);
  if (selectedOptionIds is String) return selectedOptionIds.contains(jsStr(optId));
  return false;
}

bool _hasAnswer(Json res) {
  final ids = res['selected_option_ids'];
  final idsLen = ids is List ? ids.length : (ids is String ? ids.length : 0);
  if (jsTruthy(ids) && idsLen > 0) return true;
  final text = res['answer_text'];
  return jsTruthy(text) && jsStr(text).trim().isNotEmpty;
}

num _scoreOf(Json res) => jsNumber(res['final_score'] ?? res['auto_score'] ?? 0);

num _maxOf(Json q) {
  if (jsTruthy(q['max_marks'])) return jsNumber(q['max_marks']);
  final marks = dig(q, const ['question', 'marks']);
  return jsNumber(jsTruthy(marks) ? marks : 1);
}

/// `totalQuestions`, `correctCount`, `incorrectCount`, `notAnsweredCount`
/// of an attempt (`attemptexam`).
({int total, int correct, int incorrect, int notAnswered}) attemptCounts(Object? attempt) {
  final questions = asList(asMap(attempt)?['attempt_questions']);
  var correct = 0;
  var incorrect = 0;
  var notAnswered = 0;
  for (final raw in questions) {
    final q = asMap(raw) ?? const <String, dynamic>{};
    final res = asMap(q['response']);
    if (res == null || !jsTruthy(q['response'])) {
      notAnswered++;
      continue;
    }
    final score = _scoreOf(res);
    final max = _maxOf(q);
    final answered = _hasAnswer(res);
    if (score >= max) correct++;
    if (answered && score < max) incorrect++;
    if (!answered) notAnswered++;
  }
  return (total: questions.length, correct: correct, incorrect: incorrect, notAnswered: notAnswered);
}

/// `q.response?.final_score > 0` (JS relational comparison).
bool scoreAboveZero(Object? finalScore) {
  if (finalScore == null) return false;
  final n = jsNumber(finalScore);
  return !n.isNaN && n > 0;
}
