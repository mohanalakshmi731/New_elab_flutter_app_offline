/// Store actions and pure helpers shared by the Class Math (`/classmath`) and
/// Math Play (`/mathplay`) pages — ports of the parts of
/// `src/store/Userstore.ts` that `classmath.vue` / `mathplay.vue` map and the
/// shared MathZoro controller does not already provide.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';
import '../mathzoro/mathzoro_controller.dart';
import '../mathzoro/mz_ui.dart';

typedef Json = Map<String, dynamic>;

final mathPlayStoreProvider = Provider<MathPlayStore>(MathPlayStore.new);

/// Userstore actions used by the two pages. Store *state* stays where the
/// rest of the app keeps it: `math_zoro_courses` / `selectedClass` in
/// [mathZoroProvider]; `persistedClassId` in [lmsHandoffProvider];
/// `userInfo` / `classDetails` / `language` in `sessionProvider`.
///
/// `selectedActivityContext` is one store field on the web but has two
/// homes here: the eLabs pages (activity library, …) read the
/// [lmsHandoffProvider] key `selectedActivityContext`, the MathZoro screens
/// read [MathZoroState.selectedActivityContext]. [selectedActivityContext]
/// reads the handoff copy first; [setActivityContext] writes both.
class MathPlayStore {
  MathPlayStore(this._ref);
  final Ref _ref;

  /// `userInfo?.institute_id || userInfo?.instituteId || ''`.
  String get instituteId {
    final id = _ref.read(sessionProvider).instituteId;
    return jsTruthy(id) ? jsStr(id)! : '';
  }

  /// `language?.id ?? null`.
  int get languageId => _ref.read(sessionProvider).language.id;

  /// `store.selectedActivityContext`.
  Json? get selectedActivityContext =>
      asMap(_ref.read(lmsHandoffProvider)['selectedActivityContext']) ??
      _ref.read(mathZoroProvider).selectedActivityContext;

  /// `store.setActivityContext({ ...store.selectedActivityContext, ...patch })`.
  /// `undefined` values (null here) are kept as keys, like the spread.
  void setActivityContext(Json patch) {
    final next = <String, dynamic>{...?selectedActivityContext, ...patch};
    _ref.read(lmsHandoffProvider.notifier).set('selectedActivityContext', next);
    _ref.read(mathZoroProvider.notifier).setSelectedActivityContext(next);
  }

  /// `unlockZslActivity(activityId)`.
  Future<dynamic> unlockZslActivity(String activityId) async {
    final session = _ref.read(sessionProvider);
    final ui = session.userInfo;
    final instituteId = jsStr(ui?.instituteId);
    final subUserId = jsStr(ui?.zsl);

    final classId = firstNonEmpty([
      jsStr(selectedActivityContext?['classId']),
      jsStr(session.classDetails?.id),
      jsStr(ui?.classesId),
    ]);

    if (instituteId == null || instituteId.isEmpty) {
      throw const ApiError('Institute ID not available');
    }
    if (classId.isEmpty) throw const ApiError('Class ID not available');
    if (subUserId == null || subUserId.isEmpty) {
      throw const ApiError('Sub User ID not available');
    }

    return _ref.read(gameTokensServiceProvider).unlockActivity(instituteId, activityId, subUserId);
  }

  /// The `classId` fallback chain of `submitZslQuiz` on the eLabs side —
  /// identical to [MathZoroController.submitZslQuiz] plus `persistedClassId`
  /// (set by the eLabs library / math-zone pages). Returns null when every
  /// source is empty so the controller raises its usual error.
  String? zslQuizClassId() {
    final session = _ref.read(sessionProvider);
    final ui = session.userInfo;
    final mz = _ref.read(mathZoroProvider);
    String truthy(dynamic v) => jsTruthy(v) ? jsStr(v)! : '';
    final id = firstNonEmpty([
      truthy(mz.selectedClass?['zsl_class_id']),
      truthy(mz.selectedClass?['classes_id']),
      truthy(_ref.read(lmsHandoffProvider)['persistedClassId']),
      truthy(session.classDetails?.id),
      truthy(ui?.zslClassId),
      truthy(ui?.classesId),
      truthy(selectedActivityContext?['classId']),
      truthy(mz.mathZoroCourses.isNotEmpty ? mz.mathZoroCourses.first['zsl_class_id'] : null),
    ]);
    return id.isEmpty ? null : id;
  }
}

// ── JS semantics ────────────────────────────────────────────────────────────

/// `String(obj.key)` — `"undefined"` for a missing key, `"null"` for null.
String jsStringOf(Map<String, dynamic>? obj, String key) {
  if (obj == null || !obj.containsKey(key)) return 'undefined';
  return jsStr(obj[key]) ?? 'null';
}

/// `res?.data || res || []` — the value the pages treat as the question list.
dynamic dataOrSelf(dynamic res) {
  final inner = asMap(res)?['data'];
  if (jsTruthy(inner)) return inner;
  if (jsTruthy(res)) return res;
  return const [];
}

/// `x.length` truthiness for values that may not be arrays.
bool hasItems(dynamic v) => v is List && v.isNotEmpty;

/// `(answersPayload)` of QuizExam's `submitted` event as typed rows.
List<Map<String, String>> answersPayloadOf(Map<String, dynamic> event) => [
      for (final row in asList(event['answersPayload']))
        if (asMap(row) case final m?)
          {
            'question_id': jsStr(m['question_id']) ?? '',
            'option_id': jsStr(m['option_id']) ?? '',
          },
    ];

/// `(topics || []).flatMap(t => (t.activities || []).map(a => ({ ...a,
/// file_path: a.file_path || t.file_path || '', topic_name: t.name,
/// topic_id: t.id, chapter_id: chapterId, ...extra(a) })))`.
///
/// Throws [TypeError]-like [StateError] when `topics` is truthy but not an
/// array (the web's `flatMap` would throw and the chapter is dropped/cached
/// empty by the caller).
List<Json> flattenTopicActivities(dynamic topics, dynamic chapterId,
    [Json Function(Json activity)? extra]) {
  if (!jsTruthy(topics)) return [];
  if (topics is! List) throw StateError('topics.flatMap is not a function');
  final out = <Json>[];
  for (final rawTopic in topics) {
    final t = asMap(rawTopic);
    if (t == null) {
      // `null.activities` throws; other primitives have no activities.
      if (rawTopic == null) throw StateError('Cannot read properties of null');
      continue;
    }
    final acts = t['activities'];
    if (!jsTruthy(acts)) continue;
    if (acts is! List) throw StateError('activities.map is not a function');
    for (final rawAct in acts) {
      final a = asMap(rawAct) ?? <String, dynamic>{};
      final filePath = jsTruthy(a['file_path'])
          ? a['file_path']
          : (jsTruthy(t['file_path']) ? t['file_path'] : '');
      final row = <String, dynamic>{
        ...a,
        'file_path': filePath,
        'topic_name': t['name'],
        'topic_id': t['id'],
        'chapter_id': chapterId,
      };
      if (extra != null) row.addAll(extra(a));
      out.add(row);
    }
  }
  return out;
}

// ── classmath.vue ───────────────────────────────────────────────────────────

/// `Array.isArray(res) ? res : (res?.data || res?.[alt] || [])`.
dynamic arrayOr(dynamic res, String alt) {
  if (res is List) return res;
  final m = asMap(res);
  if (jsTruthy(m?['data'])) return m!['data'];
  if (jsTruthy(m?[alt])) return m![alt];
  return const [];
}

/// `classes.find(c => String(c.id) === String(selectedClassId)) || classes[0]`.
Json pickClass(List<dynamic> classes, String selectedClassId) {
  for (final c in classes) {
    final m = asMap(c);
    if (jsStringOf(m, 'id') == selectedClassId) return m!;
  }
  return asMap(classes.first) ?? <String, dynamic>{};
}

/// The "always force Mathematics" subject pick of `autoSelectAndLoad`.
Json pickMathSubject(List<dynamic> subjects) {
  String nameOf(dynamic s) => jsStr(asMap(s)?['name']) ?? '';
  for (final s in subjects) {
    if (nameOf(s).trim().toLowerCase() == 'mathematics') return asMap(s)!;
  }
  for (final s in subjects) {
    final n = nameOf(s).toLowerCase();
    if (n.contains('math') && !n.contains('play')) return asMap(s)!;
  }
  return asMap(subjects.first) ?? <String, dynamic>{};
}

/// `filteredChapters` (declared as a method on the web — see the page doc):
/// only chapters whose `subject_id` matches the selected subject.
List<Json> filterChaptersBySubject(List<Json> chapters, String selectedSubjectId) => [
      for (final ch in chapters)
        if (selectedSubjectId.isNotEmpty &&
            jsTruthy(ch['subject_id']) &&
            jsStr(ch['subject_id']) == selectedSubjectId)
          ch,
    ];

// ── mathplay.vue ────────────────────────────────────────────────────────────

/// `LEVEL_OPTIONS`.
const List<({String value, String label, String emoji})> kLevelOptions = [
  (value: 'all', label: 'All Levels', emoji: '🌐'),
  (value: 'beginner', label: 'Beginner', emoji: '🌱'),
  (value: 'intermediate', label: 'Intermediate', emoji: '⚡'),
  (value: 'expert', label: 'Expert', emoji: '🔥'),
];

/// `inferLevel(name = '')`. A present-but-non-string name throws like
/// `name.toUpperCase()` would.
String? inferLevel(Json activity) {
  final String name;
  if (!activity.containsKey('name')) {
    name = '';
  } else if (activity['name'] is String) {
    name = activity['name'] as String;
  } else {
    throw StateError('name.toUpperCase is not a function');
  }
  final n = name.toUpperCase();
  if (n.contains('(EXPERT)')) return 'expert';
  if (n.contains('(ADVANCED)')) return 'intermediate';
  if (n.contains('(BEGINNER)')) return 'beginner';
  return null;
}

/// `topicColorIndex(name = '')` — 32-bit string hash modulo the 8 colours.
int topicColorIndex(String? name) {
  final s = name ?? '';
  var hash = 0;
  for (var i = 0; i < s.length; i++) {
    hash = (hash * 31 + s.codeUnitAt(i)) & 0xffffffff;
    if (hash >= 0x80000000) hash -= 0x100000000; // `| 0`
  }
  return hash.abs() % 8;
}

/// The extra fields `fetchData` adds to every activity.
Json mathPlayActivityExtras(Json a, int chapterNumber) {
  final level = jsTruthy(a['level']) ? a['level'] : inferLevel(a);
  final unlocked = a['is_unlocked'] is bool
      ? a['is_unlocked'] as bool
      : (a['required_tickets_to_unlock'] is num && a['required_tickets_to_unlock'] == 0);
  return {'chapterNumber': chapterNumber, 'level': level, 'is_unlocked': unlocked};
}

/// `filteredActivities`.
List<Json> filterMathPlayActivities(
  List<Json> all, {
  required String chapterId,
  required String level,
  required String lockFilter,
}) {
  var list = all;
  if (chapterId != 'all') {
    list = list.where((a) => jsStringOf(a, 'chapter_id') == chapterId).toList();
  }
  if (level != 'all') {
    list = list.where((a) => (jsTruthy(a['level']) ? a['level'] : '') == level).toList();
  }
  if (lockFilter == 'unlocked') {
    list = list.where((a) => jsTruthy(a['is_unlocked'])).toList();
  } else if (lockFilter == 'locked') {
    list = list.where((a) => !jsTruthy(a['is_unlocked'])).toList();
  }
  return list;
}

/// `capitalise(s)`.
String capitalise(dynamic s) {
  final v = jsStr(s) ?? '';
  if (!jsTruthy(s) || v.isEmpty) return '';
  return v[0].toUpperCase() + v.substring(1);
}
