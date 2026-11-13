/// Pure helpers behind `scheduleexam.vue` / `scheduleexamlist.vue`, written
/// with the JavaScript semantics the web relied on (`String(x)`, `Number(x)`,
/// `x || y`, Vue's number casting of `<input type="number">`).
library;

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';

/// `Locale` from `src/types/enums.ts` — `v-for="(value, key) in Locale"`
/// shows the key and stores the value.
const scheduleExamLocales = <String, String>{
  'All': 'all',
  'Telugu': 'te',
  'English': 'en',
};

/// `defaultLocale` (`Locale.English`).
const defaultScheduleExamLocale = 'en';

/// A new section as pushed by "Add Section".
Map<String, dynamic> newExamSection() => {
      'name': '',
      'description': '',
      'question_count': 0,
      'marks_per_question': 1,
      'rules': <Map<String, dynamic>>[],
    };

/// A new rule as pushed by "Add Rule" (and the one in the initial section).
Map<String, dynamic> newExamRule() => {
      'topic_id': '',
      'difficulty': 'EASY',
      'question_type': 'MCQ',
      'tags': '',
      'pick_count': 1,
    };

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

/// JS `String(obj.key)` — `'undefined'` when [m] lacks [key].
String jsField(Object? m, String key) {
  final map = asMap(m);
  if (map == null || !map.containsKey(key)) return 'undefined';
  return jsStr(map[key]);
}

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

/// The text an `<Input v-model>` shows for a stored value.
String inputText(Object? v) {
  if (v == null) return '';
  if (v is double && (v.isNaN || v.isInfinite)) return '';
  return jsStr(v);
}

// ── course tree lookups (`courseSections` = store `sections`) ─────────────

List<Map<String, dynamic>> _maps(Object? list) => [for (final e in asList(list)) ?asMap(e)];

/// `selectedSectionChapters` — the chapters of the FIRST section only.
List<Map<String, dynamic>> firstSectionChapters(List<Map<String, dynamic>> sections) {
  if (sections.isEmpty) return const [];
  return _maps(sections.first['chapters']);
}

/// `topics` — the contents of the chapter whose id is [selectedSubjectId]
/// (searched in every section).
List<Map<String, dynamic>> topicsOfChapter(
    List<Map<String, dynamic>> sections, String selectedSubjectId) {
  if (selectedSubjectId.isEmpty) return const [];
  for (final section in sections) {
    for (final c in _maps(section['chapters'])) {
      if (jsField(c, 'id') == selectedSubjectId) {
        final contents = c['contents'];
        return jsTruthy(contents) ? _maps(contents) : const [];
      }
    }
  }
  return const [];
}

/// `saveExam`: the section that owns the chapter [selectedSubjectId].
Map<String, dynamic>? sectionOfChapter(
    List<Map<String, dynamic>> sections, String selectedSubjectId) {
  for (final section in sections) {
    for (final c in _maps(section['chapters'])) {
      if (jsField(c, 'id') == selectedSubjectId) return section;
    }
  }
  return null;
}

/// `onTopicSelect`: the section with a chapter content whose
/// `exam_content_id` is [topicId].
Map<String, dynamic>? sectionOfTopic(List<Map<String, dynamic>> sections, String topicId) {
  for (final section in sections) {
    for (final chapter in _maps(section['chapters'])) {
      for (final c in _maps(chapter['contents'])) {
        if (jsField(c, 'exam_content_id') == topicId) return section;
      }
    }
  }
  return null;
}

/// The edit watcher's topic lookup: the content whose `id` or
/// `exam_content_id` equals [topicUuid] → its `exam_content_id` and chapter id.
({String examContentId, String chapterId})? locateTopic(
    List<Map<String, dynamic>> sections, Object topicUuid) {
  final wanted = jsStr(topicUuid);
  for (final section in sections) {
    for (final chapter in _maps(section['chapters'])) {
      for (final content in _maps(chapter['contents'])) {
        if (jsField(content, 'id') == wanted || jsField(content, 'exam_content_id') == wanted) {
          return (
            examContentId: jsField(content, 'exam_content_id'),
            chapterId: jsField(chapter, 'id'),
          );
        }
      }
    }
  }
  return null;
}

// ── exam (edit mode) → form ───────────────────────────────────────────────

/// `this.sections = (res.sections || []).map(...)` in the `examId` watcher.
List<Map<String, dynamic>> sectionsFromExam(Map<String, dynamic> res) => [
      for (final sec in _maps(res['sections']))
        {
          'name': jsTruthy(sec['name']) ? sec['name'] : '',
          'description': jsTruthy(sec['description']) ? sec['description'] : '',
          'question_count': jsNumber(jsTruthy(sec['question_count']) ? sec['question_count'] : 0),
          'marks_per_question':
              jsNumber(jsTruthy(sec['marks_per_question']) ? sec['marks_per_question'] : 1),
          'rules': [
            for (final bp in _maps(sec['blueprints']))
              {
                'topic_uuid': jsField(bp, 'topic_id'),
                'topic_id': '',
                'difficulty': bp['difficulty_level'],
                'question_type': bp['question_type'],
                'tags': jsTruthy(bp['tag']) ? bp['tag'] : '',
                'pick_count':
                    jsNumber(jsTruthy(bp['questions_to_pick']) ? bp['questions_to_pick'] : 1),
              },
          ],
        },
    ];

/// Every `sections[].question_pool[].question_id` (as strings).
List<String> poolQuestionIdsOf(Map<String, dynamic> res) => [
      for (final sec in _maps(res['sections']))
        for (final qp in _maps(sec['question_pool']))
          if (jsTruthy(qp['question_id'])) jsStr(qp['question_id']),
    ];

/// `res.sections?.[0]?.blueprints?.[0]?.topic_id || …topic_uuid || null`
Object? firstTopicUuidOf(Map<String, dynamic> res) {
  final bp = asMap(dig(res, const ['sections', 0, 'blueprints', 0]));
  if (bp == null) return null;
  if (jsTruthy(bp['topic_id'])) return bp['topic_id'];
  if (jsTruthy(bp['topic_uuid'])) return bp['topic_uuid'];
  return null;
}

// ── question filtering ────────────────────────────────────────────────────

/// `applyRuleFilter()` — filters [allQuestions] by the FIRST rule of the
/// FIRST section. Returns `null` when the web would leave `questions`
/// untouched (no section / no rule, or `allQuestions` is not an array — the
/// spread throws there).
List<dynamic>? filterQuestionsByRule(Object? allQuestions, List<Map<String, dynamic>> sections) {
  if (sections.isEmpty) return null;
  final rules = _maps(sections.first['rules']);
  if (rules.isEmpty) return null;
  final rule = rules.first;
  if (allQuestions is! List) return null;

  var filtered = [...allQuestions];

  final difficulty = rule['difficulty'];
  if (jsTruthy(difficulty)) {
    final want = jsStr(difficulty).toUpperCase();
    filtered = [
      for (final q in filtered)
        if (jsField(q, 'difficulty_level').toUpperCase() == want) q,
    ];
  }

  final type = rule['question_type'];
  if (jsTruthy(type)) {
    final want = jsStr(type).toUpperCase();
    filtered = [
      for (final q in filtered)
        if (jsField(q, 'question_type').toUpperCase() == want) q,
    ];
  }

  final tags = rule['tags'];
  if (tags is String && tags.trim().isNotEmpty) {
    final tagList = tags.split(',').map((t) => t.trim().toLowerCase()).toList();
    filtered = [
      for (final q in filtered)
        if (tagList.any((tag) => _tagsText(q).toLowerCase().contains(tag))) q,
    ];
  }
  return filtered;
}

String _tagsText(Object? q) {
  final t = asMap(q)?['tags'];
  if (!jsTruthy(t)) return '';
  return t is String ? t : t.toString();
}

// ── save payload ──────────────────────────────────────────────────────────

/// The `payload` built by `saveExam()` (before the store adds
/// `institute_id`). [sections] use the form keys (`name`, `description`,
/// `question_count`, `marks_per_question`, `rules[{topic_id, difficulty,
/// question_type, tags, pick_count}]`); numeric form values are what
/// `v-model` stored (number or raw text). `undefined` fields are omitted.
Map<String, dynamic> buildScheduleExamPayload({
  required Object? locale,
  required Object? activeScheduleId,
  required Map<String, dynamic> selectedSection,
  required Object? durationMinutes,
  required Object? maxAttempts,
  required bool enableNegativeMarking,
  required Object? negativeMarks,
  required bool randomizeQuestionOrder,
  required bool randomizeOptionsOrder,
  required String imageUrl,
  required String imageCaption,
  required List<Map<String, dynamic>> sections,
  required List<Object?> selectedQuestionIds,
}) {
  return {
    'locale': locale,
    'is_open_anytime': true,
    'exam_type': 'QUIZ',
    'schedule_id': jsStr(activeScheduleId),
    'exam_subject_id': jsField(selectedSection, 'exam_section_id'),
    'duration_minutes': jsonNum(jsNumber(durationMinutes)),
    'max_attempts': jsonNum(jsNumber(jsTruthy(maxAttempts) ? maxAttempts : 1)),
    'allow_negative_marking': enableNegativeMarking,
    if (enableNegativeMarking) 'default_negative_marks': jsonNum(jsNumber(negativeMarks)),
    'randomize_question_order': randomizeQuestionOrder,
    'randomize_option_order': randomizeOptionsOrder,
    'images': imageUrl.isNotEmpty
        ? [
            {'url': imageUrl, 'caption': imageCaption.isNotEmpty ? imageCaption : ''},
          ]
        : const [],
    'sections': [
      for (var index = 0; index < sections.length; index++)
        _sectionPayload(sections[index], index, selectedQuestionIds),
    ],
  };
}

Map<String, dynamic> _sectionPayload(
    Map<String, dynamic> sec, int index, List<Object?> selectedQuestionIds) {
  num orOne(Object? v) {
    final n = jsNumber(v);
    return jsTruthy(n) ? n : 1;
  }

  return {
    'name': jsTruthy(sec['name']) ? sec['name'] : 'Section ${index + 1}',
    if (jsTruthy(sec['description'])) 'description': sec['description'],
    'question_count': jsonNum(orOne(sec['question_count'])),
    'marks_per_question': jsonNum(orOne(sec['marks_per_question'])),
    'section_order': index + 1,
    'selected_question_ids': [...selectedQuestionIds],
    'blueprints': [
      for (final rule in _maps(sec['rules']))
        if (jsTruthy(rule['topic_id']))
          {
            'topic_id': jsStr(rule['topic_id']),
            'difficulty_level': rule['difficulty'],
            'question_type': rule['question_type'],
            'questions_to_pick':
                jsonNum(jsNumber(jsTruthy(rule['pick_count']) ? rule['pick_count'] : 1)),
            if (jsTruthy(rule['tags'])) 'tags': rule['tags'],
          },
    ],
  };
}
