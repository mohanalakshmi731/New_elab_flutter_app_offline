/// Pure logic of the MathZoro Play Zone (`playzone.vue`): level inference,
/// topic colours, activity reshaping, filters, XP parsing and the unlock
/// error message.
library;

import 'dart:ui' show Color;

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../mathzoro/mz_ui.dart' show jsStr;

typedef Json = Map<String, dynamic>;

/// `LEVEL_OPTIONS` (the level dropdown itself is `hidden` on the web).
const playLevelOptions = <({String value, String label, String emoji})>[
  (value: 'all', label: 'All Levels', emoji: '🌐'),
  (value: 'beginner', label: 'Beginner', emoji: '🌱'),
  (value: 'intermediate', label: 'Intermediate', emoji: '⚡'),
  (value: 'expert', label: 'Expert', emoji: '🔥'),
];

/// `TOPIC_COLORS` — green, pink, orange, purple, cyan, rose, indigo, teal (500).
const playTopicColors = <Color>[
  Color(0xFF22C55E),
  Color(0xFFEC4899),
  Color(0xFFF97316),
  Color(0xFFA855F7),
  Color(0xFF06B6D4),
  Color(0xFFF43F5E),
  Color(0xFF6366F1),
  Color(0xFF14B8A6),
];

/// `inferLevel(name = '')` — throws for `null` / non-string names like the
/// JavaScript `name.toUpperCase()` TypeError.
String? inferLevel(Json activity) {
  final Object? name = activity.containsKey('name') ? activity['name'] : '';
  if (name is! String) {
    throw StateError("Cannot read properties of $name (reading 'toUpperCase')");
  }
  final n = name.toUpperCase();
  if (n.contains('(EXPERT)')) return 'expert';
  if (n.contains('(ADVANCED)')) return 'intermediate';
  if (n.contains('(BEGINNER)')) return 'beginner';
  return null;
}

/// `topicColorIndex(name)` — `hash = (hash * 31 + charCode) | 0` over UTF-16
/// code units, `Math.abs(hash) % 8`.
int topicColorIndex(String name) {
  var hash = 0;
  for (final unit in name.codeUnits) {
    hash = (hash * 31 + unit).toSigned(32);
  }
  return hash.abs() % playTopicColors.length;
}

/// `topicIconBg(topicName)`; `null` / missing topic names hash as `''`.
Color topicColor(dynamic topicName) =>
    playTopicColors[topicColorIndex(topicName is String ? topicName : (jsStr(topicName) ?? ''))];

/// `capitalise(s)`.
String capitalise(String? s) => s == null || s.isEmpty ? '' : s[0].toUpperCase() + s.substring(1);

/// The activity reshaping of `fetchData` / `fetchChapterActivities`:
/// `(topics || []).flatMap(t => (t.activities || []).map(a => ({ ...a,
/// file_path, topic_name, topic_id, chapter_id, chapterNumber, level,
/// is_unlocked })))`. Throws (like the JavaScript TypeError) for malformed
/// responses, so the caller's `catch` / `allSettled` drops them.
List<Json> playFlattenTopics(dynamic topics, dynamic chapterId, int chapterNumber) {
  if (!jsTruthy(topics)) return [];
  if (topics is! List) throw StateError('topics.flatMap is not a function');
  final out = <Json>[];
  for (final rawTopic in topics) {
    final t = asMap(rawTopic);
    if (t == null) throw StateError("Cannot read properties of null (reading 'activities')");
    final acts = jsTruthy(t['activities']) ? t['activities'] : const [];
    if (acts is! List) throw StateError('activities.map is not a function');
    for (final rawAct in acts) {
      final a = asMap(rawAct);
      if (a == null) throw StateError("Cannot read properties of null (reading 'file_path')");
      final unlocked = a['is_unlocked'];
      final required = a['required_tickets_to_unlock'];
      out.add({
        ...a,
        'file_path': jsTruthy(a['file_path'])
            ? a['file_path']
            : (jsTruthy(t['file_path']) ? t['file_path'] : ''),
        'topic_name': t['name'],
        'topic_id': t['id'],
        'chapter_id': chapterId,
        'chapterNumber': chapterNumber,
        'level': jsTruthy(a['level']) ? a['level'] : inferLevel(a),
        'is_unlocked': unlocked is bool ? unlocked : (required is num && required == 0),
      });
    }
  }
  return out;
}

/// `filteredActivities` computed.
List<Json> filterPlayActivities(
  List<Json> all, {
  required String chapterId,
  required String level,
  required String lock,
}) {
  var list = all;
  if (chapterId != 'all') {
    list = list.where((a) => (jsStr(a['chapter_id']) ?? 'undefined') == chapterId).toList();
  }
  if (level != 'all') {
    list = list.where((a) => (jsTruthy(a['level']) ? jsStr(a['level']) : '') == level).toList();
  }
  if (lock == 'unlocked') {
    list = list.where((a) => jsTruthy(a['is_unlocked'])).toList();
  } else if (lock == 'locked') {
    list = list.where((a) => !jsTruthy(a['is_unlocked'])).toList();
  }
  return list;
}

/// `fetchXp()` response parsing:
/// `res.xp ?? res.total_xp ?? res.data?.xp ?? res.data?.total_xp ?? 0`
/// (`!== undefined` checks: a present `null` wins), a bare number as-is,
/// anything else 0.
dynamic parseXp(dynamic res) {
  if (res is num) return res;
  if (res is List) return 0; // typeof [] === 'object', no xp keys
  final m = asMap(res);
  if (m == null) return 0;
  if (m.containsKey('xp')) return m['xp'];
  if (m.containsKey('total_xp')) return m['total_xp'];
  final data = asMap(m['data']);
  if (data != null && data.containsKey('xp')) return data['xp'];
  if (data != null && data.containsKey('total_xp')) return data['total_xp'];
  return 0;
}

/// `err?.response?.data?.msg || err?.response?.data?.message || err?.message
/// || 'Something went wrong. Please try again.'` (axios error messages).
String unlockErrorMessage(Object error) {
  const fallback = 'Something went wrong. Please try again.';
  if (error is DioException) {
    final data = asMap(error.response?.data);
    if (jsTruthy(data?['msg'])) return jsStr(data!['msg'])!;
    if (jsTruthy(data?['message'])) return jsStr(data!['message'])!;
    final status = error.response?.statusCode;
    if (status != null) return 'Request failed with status code $status';
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return 'timeout exceeded';
    }
    return 'Network Error';
  }
  if (error is ApiError) return error.message.isEmpty ? fallback : error.message;
  final text = error.toString();
  return text.isEmpty ? fallback : text;
}
