/// Pure logic shared by the eLabs Math Zone and Science Zone pages
/// (`src/pages/library/elabsmathzone.vue`, `elabssciencezone.vue`):
/// the road geometry, star / progress maths and the response reshaping.
/// JavaScript value semantics (`Number(x)`, `Math.round`, `x || y`) are
/// reproduced where the templates depend on them.
library;

import 'dart:ui' show Color, Offset;

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';

typedef Json = Map<String, dynamic>;

// ── Road geometry ───────────────────────────────────────────────────────────

const double kSnakeTopY = 110;
const double kSnakeBotY = 280;
const double kPadX = 110;
const double kCardWidth = 156;
const double kMinStep = kCardWidth + 120;

/// Height of the roadmap box and of its canvas (`height: 380px`).
const double kRoadmapHeight = 380;

/// `buildMilestonePoints(count, width)`.
List<Offset> buildMilestonePoints(int count, double width) {
  if (count == 0) return const [];
  final usableWidth = width - kPadX * 2;
  final step = count > 1 ? usableWidth / (count - 1) : 0.0;
  return List.generate(
    count,
    (i) => Offset(kPadX + i * step, i.isEven ? kSnakeBotY : kSnakeTopY),
  );
}

/// `pathMinWidth` computed.
double pathMinWidth(int chapterCount, double containerWidth) {
  final minForChapters =
      chapterCount <= 1 ? containerWidth : (chapterCount - 1) * kMinStep + kPadX * 2;
  return containerWidth > minForChapters ? containerWidth : minForChapters;
}

/// The cubic segments of `pointsToSvgPath(pts)`:
/// `C cpX prev.y, cpX curr.y, curr.x curr.y` with `cpX = (prev.x + curr.x) / 2`.
/// Each record is (control point 1, control point 2, end point).
List<(Offset, Offset, Offset)> roadSegments(List<Offset> pts) {
  final out = <(Offset, Offset, Offset)>[];
  for (var i = 1; i < pts.length; i++) {
    final prev = pts[i - 1];
    final curr = pts[i];
    final cpX = (prev.dx + curr.dx) / 2;
    out.add((Offset(cpX, prev.dy), Offset(cpX, curr.dy), curr));
  }
  return out;
}

// ── JavaScript helpers ─────────────────────────────────────────────────────

/// JS `String(v)` — integral doubles print without `.0`; `null` → null.
String? jsStr(dynamic v) {
  if (v == null) return null;
  if (v is double && v.isFinite && v == v.truncateToDouble()) {
    return v.toInt().toString();
  }
  return v.toString();
}

/// JS `Number(v)` (NaN when not numeric; `null`/missing is treated as
/// `undefined` → NaN).
double jsNumber(dynamic v) {
  if (v == null) return double.nan;
  if (v is bool) return v ? 1 : 0;
  if (v is num) return v.toDouble();
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return 0;
    return double.tryParse(s) ?? double.nan;
  }
  return double.nan;
}

/// Object key produced by `map[Number(x)]`.
String numKey(dynamic v) {
  final d = jsNumber(v);
  if (d.isNaN) return 'NaN';
  return jsStr(d)!;
}

/// JS `Math.round` (halves round towards +∞; NaN stays NaN).
double jsRound(double v) => v.isFinite ? (v + 0.5).floorToDouble() : v;

/// `{{ n }}` for a number that is normally an integer.
String jsNumDisplay(double v) {
  if (v.isNaN) return 'NaN';
  return jsStr(v)!;
}

/// `res.data || res || fallback`.
dynamic dataOr(dynamic res, dynamic fallback) {
  final inner = asMap(res)?['data'];
  if (jsTruthy(inner)) return inner;
  if (jsTruthy(res)) return res;
  return fallback;
}

// ── Performance / stars ─────────────────────────────────────────────────────

/// `ticketsToStars(tickets)` — `Math.min(5, Math.floor(Number(tickets)))`.
/// Returns NaN for non-numeric tickets, like the web (all comparisons then
/// fail, so nothing is shown).
double ticketsToStars(dynamic tickets) {
  if (!jsTruthy(tickets)) return 0;
  final n = jsNumber(tickets);
  if (n <= 0) return 0;
  if (n.isNaN) return double.nan;
  final f = n.floorToDouble();
  return f < 5 ? f : 5;
}

/// `currentStarColor(filled)` — the Science Zone uses green for 5 stars and
/// yellow for 4.
Color starColor(double filled, {required bool science}) {
  if (filled >= 5) return science ? const Color(0xFF4ADE80) : const Color(0xFFFACC15);
  if (filled >= 4) return science ? const Color(0xFFFACC15) : const Color(0xFFFDE047);
  if (filled >= 3) return const Color(0xFFFB923C);
  if (filled >= 2) return const Color(0xFFF59E0B);
  if (filled >= 1) return const Color(0xFFFDE047);
  return const Color(0x00000000);
}

/// `chapterPerformanceMap` computed: `Number(chapter_id)` → chapter perf
/// plus an `activityMap` keyed by `Number(activity_id)`.
Map<String, Json> chapterPerformanceMap(dynamic subjectPerformance) {
  final map = <String, Json>{};
  final chapters = asList(asMap(subjectPerformance)?['chapters']);
  for (final raw in chapters) {
    final ch = asMap(raw) ?? const <String, dynamic>{};
    final activityMap = <String, Json>{};
    for (final a in asList(ch['activities'])) {
      final act = asMap(a);
      if (act == null) continue;
      activityMap[numKey(act['activity_id'])] = act;
    }
    map[numKey(ch['chapter_id'])] = {...ch, 'activityMap': activityMap};
  }
  return map;
}

/// `getChapterPctByIndex(i)` / `chapterProgress` for a chapter's perf entry:
/// `Math.round(earned_tickets / (activities.length * 5) * 100)`.
double chapterPct(Json? perf) {
  if (perf == null) return 0;
  final activityCount = asList(perf['activities']).length;
  final totalTickets = activityCount * 5;
  if (totalTickets == 0) return 0;
  final earned = jsNumber(jsTruthy(perf['earned_tickets']) ? perf['earned_tickets'] : 0);
  return jsRound(earned / totalTickets * 100);
}

/// Flag badge text: `Math.round(pct) > 0 ? Math.round(pct) + '%' : '0%'`.
String pctBadgeLabel(double pct) {
  final r = jsRound(pct);
  return r > 0 ? '${jsNumDisplay(r)}%' : '0%';
}

/// Bar width fraction for `width: pct + '%'` (overflow-hidden parent).
double pctFraction(double pct) {
  if (pct.isNaN || pct <= 0) return 0;
  return pct >= 100 ? 1 : pct / 100;
}

// ── Activities ──────────────────────────────────────────────────────────────

/// `(topics || []).flatMap(t => (t.activities || []).map(a => ({ ...a,
/// topic_name, topic_id, chapter_id, file_path: a.file_path || t.file_path || '' })))`.
///
/// Throws (like the JavaScript TypeError) when the response is not a list of
/// topics, so the caller's `catch` runs.
List<Json> flattenTopics(dynamic topics, dynamic chapterId) {
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
      out.add({
        ...a,
        'topic_name': t['name'],
        'topic_id': t['id'],
        'chapter_id': chapterId,
        'file_path': jsTruthy(a['file_path'])
            ? a['file_path']
            : (jsTruthy(t['file_path']) ? t['file_path'] : ''),
      });
    }
  }
  return out;
}

/// `responses.flat()` (one level).
List<dynamic> flatOne(Iterable<dynamic> responses) => [
      for (final r in responses)
        if (r is List) ...r else r,
    ];

/// `totalActivityCount` computed.
int totalActivityCount(List<dynamic> allActivitiesData) {
  var sum = 0;
  for (final t in allActivitiesData) {
    sum += asList(asMap(t)?['activities']).length;
  }
  return sum;
}

/// The chapter id kept when a chapter is re-selected from the persisted
/// value: `saved ? chapters.findIndex(String(ch.id) === String(saved)) : -1`,
/// falling back to 0.
int persistedChapterIndex(List<Json> chapters, dynamic saved) {
  final savedIdx = jsTruthy(saved)
      ? chapters.indexWhere((ch) => jsStr(ch['id']) == jsStr(saved))
      : -1;
  return savedIdx >= 0 && savedIdx < chapters.length ? savedIdx : 0;
}
