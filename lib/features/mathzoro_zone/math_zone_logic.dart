/// Pure logic of the MathZoro Math Zone (`studentmathzone.vue`) and the
/// class / subject resolution it shares with the Play Zone (`playzone.vue`):
/// road geometry, performance → stars / progress maths, response reshaping.
/// JavaScript value semantics (`Number(x)`, `Math.round`, `x || y`) are kept
/// where the templates depend on them.
library;

import 'dart:ui' show Color, Offset;

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../mathzoro/mz_ui.dart' show jsStr, jsNumber, jsNumKey;

typedef Json = Map<String, dynamic>;

// ── Road geometry (module constants of studentmathzone.vue) ─────────────────

const double kMzRoadHeight = 400;
const double kMzSnakeTopY = 120;
const double kMzSnakeBotY = 300;
const double kMzPadX = 110;
const double kMzCardWidth = 160;
const double kMzMinStep = kMzCardWidth + 120; // 280px

/// `buildMilestonePoints(count, width)` — even indices on the bottom row,
/// odd ones on the top row.
List<Offset> mzMilestonePoints(int count, double width) {
  if (count == 0) return const [];
  final usableWidth = width - kMzPadX * 2;
  final step = count > 1 ? usableWidth / (count - 1) : 0.0;
  return List.generate(
    count,
    (i) => Offset(kMzPadX + i * step, i.isEven ? kMzSnakeBotY : kMzSnakeTopY),
  );
}

/// `pathMinWidth` computed.
double mzPathMinWidth(int chapterCount, double containerWidth) {
  final minForChapters = chapterCount <= 1
      ? containerWidth
      : (chapterCount - 1) * kMzMinStep + kMzPadX * 2;
  return containerWidth > minForChapters ? containerWidth : minForChapters;
}

/// The cubic segments of `pointsToSvgPath(pts)`:
/// `C cpX prev.y, cpX curr.y, curr.x curr.y` with `cpX = (prev.x + curr.x) / 2`.
/// Each record is (control point 1, control point 2, end point).
List<(Offset, Offset, Offset)> mzRoadSegments(List<Offset> pts) {
  final out = <(Offset, Offset, Offset)>[];
  for (var i = 1; i < pts.length; i++) {
    final prev = pts[i - 1];
    final curr = pts[i];
    final cpX = (prev.dx + curr.dx) / 2;
    out.add((Offset(cpX, prev.dy), Offset(cpX, curr.dy), curr));
  }
  return out;
}

// ── Performance / stars ─────────────────────────────────────────────────────

/// JS `Math.round` (halves round towards +∞; NaN / ±∞ unchanged).
double jsRound(double v) => v.isFinite ? (v + 0.5).floorToDouble() : v;

/// `res?.data || res || fallback`.
dynamic dataOr(dynamic res, dynamic fallback) {
  final inner = asMap(res)?['data'];
  if (jsTruthy(inner)) return inner;
  if (jsTruthy(res)) return res;
  return fallback;
}

/// `chapterPerformanceMap` computed: `Number(chapter_id)` → chapter perf plus
/// an `activityMap` keyed by `Number(activity_id)`.
Map<String, Json> mzChapterPerformanceMap(dynamic subjectPerformance) {
  final map = <String, Json>{};
  final chapters = asList(asMap(subjectPerformance)?['chapters']);
  for (final raw in chapters) {
    final ch = asMap(raw) ?? const <String, dynamic>{};
    final activityMap = <String, Json>{};
    for (final a in asList(ch['activities'])) {
      final act = asMap(a);
      if (act == null) continue;
      activityMap[jsNumKey(act['activity_id'])] = act;
    }
    map[jsNumKey(ch['chapter_id'])] = {...ch, 'activityMap': activityMap};
  }
  return map;
}

/// `ticketsToStars(tickets)` — `Math.min(5, Math.floor(Number(tickets)))`;
/// NaN for non-numeric tickets (every comparison then fails, like the web).
double mzTicketsToStars(dynamic tickets) {
  if (!jsTruthy(tickets)) return 0;
  final n = jsNumber(tickets);
  if (n.isNaN) return double.nan;
  if (n <= 0) return 0;
  final f = n.floorToDouble();
  return f < 5 ? f : 5;
}

/// `currentStarColor(filled)`.
Color mzStarColor(double filled) {
  if (filled >= 5) return const Color(0xFF4ADE80);
  if (filled >= 4) return const Color(0xFFFACC15);
  if (filled >= 3) return const Color(0xFFFB923C);
  if (filled >= 2) return const Color(0xFFF59E0B);
  if (filled >= 1) return const Color(0xFFFDE047);
  return const Color(0x00000000);
}

/// `getChapterPctByIndex(i)` / `chapterProgress` for a chapter's perf entry:
/// `Math.round(Number(earned_tickets || 0) / (activities.length * 5) * 100)`.
double mzChapterPct(Json? perf) {
  if (perf == null) return 0;
  final activityCount = asList(perf['activities']).length;
  final totalTickets = activityCount * 5;
  if (totalTickets == 0) return 0;
  final earned = jsNumber(jsTruthy(perf['earned_tickets']) ? perf['earned_tickets'] : 0);
  return jsRound(earned / totalTickets * 100);
}

/// `{{ n }}` for a number that is normally an integer (`NaN` prints as such).
String jsNumText(double v) => v.isNaN ? 'NaN' : jsStr(v)!;

/// Flag badge text:
/// `Math.round(pct) > 0 ? Math.round(pct) + '%' : '?'`.
String mzFlagBadgeLabel(double pct) {
  final r = jsRound(pct);
  return r > 0 ? '${jsNumText(r)}%' : '?';
}

/// `width: pct + '%'` inside an `overflow-hidden` track.
double mzPctFraction(double pct) {
  if (pct.isNaN || pct <= 0) return 0;
  return pct >= 100 ? 1 : pct / 100;
}

/// `flagColor(i)`.
({Color fill, Color stroke}) mzFlagColor(double pct, int index, int count) {
  if (pct >= 100) return (fill: const Color(0xFF4ADE80), stroke: const Color(0xFF166534));
  if (pct > 0) return (fill: const Color(0xFFFACC15), stroke: const Color(0xFF92400E));
  final half = (count / 2).ceil();
  return index < half
      ? (fill: const Color(0xFF94A3B8), stroke: const Color(0xFF475569))
      : (fill: const Color(0xFFF43F5E), stroke: const Color(0xFF881337));
}

/// `isMath` computed — the accent colour / banner icon switch.
bool mzIsMath(String subjectName) {
  final name = subjectName.toLowerCase();
  return name.contains('math') ||
      name.contains('maths') ||
      name.contains('arithmetic') ||
      name.isEmpty;
}

// ── Activities ──────────────────────────────────────────────────────────────

final _tags = RegExp(r'<[^>]+>');

/// `loadChapterActivities` reshaping:
/// `(topics || []).flatMap(t => (t.activities || []).map(a => ({ ...a,
/// file_path: a.file_path || t.file_path || '', topic_name, topic_id,
/// chapter_id, description_preview })))`.
///
/// Throws (like the JavaScript TypeError) when the response is not a list of
/// topics, so the caller's `catch` runs.
List<Json> mzFlattenTopics(dynamic topics, dynamic chapterId) {
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
      final content = asMap(a['description'])?['content'];
      out.add({
        ...a,
        'file_path': jsTruthy(a['file_path'])
            ? a['file_path']
            : (jsTruthy(t['file_path']) ? t['file_path'] : ''),
        'topic_name': t['name'],
        'topic_id': t['id'],
        'chapter_id': chapterId,
        'description_preview': content is String && content.isNotEmpty
            ? _slice(content.replaceAll(_tags, ''), 100)
            : '',
      });
    }
  }
  return out;
}

String _slice(String s, int n) => s.length <= n ? s : s.substring(0, n);

// ── Class / subject resolution (shared with the Play Zone) ──────────────────

/// `math_zoro_courses.find(c => c.zone?.toLowerCase() === zone &&
/// String(c.zsl_class_id) === String(classId))`.
Json? findZoneCourse(List<Json> courses, String zone, String classId) {
  for (final c in courses) {
    final z = c['zone'];
    if (z is String && z.toLowerCase() == zone && _jsString(c['zsl_class_id']) == classId) {
      return c;
    }
  }
  return null;
}

/// `subjects.find(s => String(s.zsl_subject_id ?? s.id) === String(subjectId))`.
Json? findZoneSubject(List<dynamic> subjects, dynamic subjectId) {
  final target = _jsString(subjectId);
  for (final raw in subjects) {
    final s = asMap(raw);
    if (s == null) continue;
    if (_jsString(s['zsl_subject_id'] ?? s['id']) == target) return s;
  }
  return null;
}

/// JS `String(v)` (`null` → `'null'`).
String _jsString(dynamic v) => jsStr(v) ?? 'null';

/// The subject id kept by the pages: `String(s.zsl_subject_id ?? s.id)`.
String zoneSubjectId(Json subject) => _jsString(subject['zsl_subject_id'] ?? subject['id']);

/// The chapters cache key (`chaptersCache[chapterId]`, a JS object key).
String cacheKey(dynamic id) => jsStr(id) ?? 'undefined';
