/// Pure helpers of `studentsciencezone.vue` (unit-tested).
library;

import 'dart:math' as math;
import 'dart:ui';

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../mathzoro/mz_ui.dart' show jsDisplay, jsNumKey, jsNumber;

// Road geometry — same snake layout as Component 1
const snakeTopY = 120.0;
const snakeBotY = 300.0;
const padX = 110.0;
const cardWidth = 160.0;
const minStep = cardWidth + 120; // 280 px between centres

/// `pathMinWidth`.
double pathMinWidth(int chapterCount, double containerWidth) {
  final minForChapters =
      chapterCount <= 1 ? containerWidth : (chapterCount - 1) * minStep + padX * 2;
  return math.max(containerWidth, minForChapters);
}

/// `buildMilestonePoints(count, width)` — even → bottom row, odd → top.
List<Offset> buildMilestonePoints(int count, double width) {
  if (count <= 0) return const [];
  final usableWidth = width - padX * 2;
  final step = count > 1 ? usableWidth / (count - 1) : 0.0;
  return [
    for (var i = 0; i < count; i++) Offset(padX + i * step, i.isEven ? snakeBotY : snakeTopY),
  ];
}

/// One `C cpX prev.y, cpX curr.y, curr.x curr.y` segment of `pointsToSvgPath`.
typedef RoadCurve = ({Offset c1, Offset c2, Offset end});

/// The cubic segments of `pointsToSvgPath(pts)` (after `M pts[0]`).
List<RoadCurve> roadCurves(List<Offset> pts) {
  final out = <RoadCurve>[];
  for (var i = 1; i < pts.length; i++) {
    final prev = pts[i - 1];
    final curr = pts[i];
    final cpX = (prev.dx + curr.dx) / 2;
    out.add((c1: Offset(cpX, prev.dy), c2: Offset(cpX, curr.dy), end: curr));
  }
  return out;
}

/// `pointsToSvgPath(pts)` as a [Path].
Path roadPath(List<Offset> pts) {
  final p = Path();
  if (pts.isEmpty) return p;
  p.moveTo(pts.first.dx, pts.first.dy);
  for (final c in roadCurves(pts)) {
    p.cubicTo(c.c1.dx, c.c1.dy, c.c2.dx, c.c2.dy, c.end.dx, c.end.dy);
  }
  return p;
}

/// `findPhysicsSubject(subjects)` — the exact `CHEMISTRYSSS` name first,
/// then the first name containing physics / science / chemistry.
/// Throws (like `s.name.trim()` on a missing name) when a name isn't text.
Map<String, dynamic>? findPhysicsSubject(List<dynamic> subjects) {
  if (subjects.isEmpty) return null;
  String nameOf(dynamic s) {
    final n = asMap(s)?['name'];
    if (n is! String) throw StateError("Cannot read properties of undefined (reading 'trim')");
    return n;
  }

  for (final s in subjects) {
    if (nameOf(s).trim().toUpperCase() == 'CHEMISTRYSSS') return asMap(s);
  }
  for (final s in subjects) {
    final n = nameOf(s).toLowerCase();
    if (n.contains('physics') || n.contains('science') || n.contains('chemistry')) {
      return asMap(s);
    }
  }
  return null;
}

/// `ticketsToStars(tickets)` — `!tickets || tickets <= 0 → 0`, else
/// `Math.min(5, Math.floor(Number(tickets)))`.
int ticketsToStars(dynamic tickets) {
  if (!jsTruthy(tickets)) return 0;
  final n = jsNumber(tickets);
  // NaN stars (a non-numeric string) fill no star, like 0.
  if (n.isNaN || n <= 0) return 0;
  return math.min(5, n.floor());
}

/// `currentStarColor(filled)`.
Color currentStarColor(int filled) {
  if (filled >= 5) return const Color(0xFF4ADE80);
  if (filled >= 4) return const Color(0xFFFACC15);
  if (filled >= 3) return const Color(0xFFFB923C);
  if (filled >= 2) return const Color(0xFFF59E0B);
  if (filled >= 1) return const Color(0xFFFDE047);
  return const Color(0x00000000);
}

/// `Math.round(x ?? 0)` (NaN → 0).
int jsRound(dynamic v) {
  final d = v == null ? 0.0 : jsNumber(v);
  if (d.isNaN || d.isInfinite) return 0;
  return (d + 0.5).floor();
}

/// `flagColor(i)` → (fill, stroke).
({Color fill, Color stroke}) flagColor(int pct, int index, int chapterCount) {
  if (pct >= 100) return (fill: const Color(0xFF4ADE80), stroke: const Color(0xFF166534));
  if (pct > 0) return (fill: const Color(0xFFFACC15), stroke: const Color(0xFF92400E));
  final half = (chapterCount / 2).ceil();
  return index < half
      ? (fill: const Color(0xFF94A3B8), stroke: const Color(0xFF475569))
      : (fill: const Color(0xFFF43F5E), stroke: const Color(0xFF881337));
}

/// `chapterPerformanceMap` — `{ [Number(chapter_id)]: { ...ch, activityMap:
/// { [Number(activity_id)]: a } } }` keyed by [jsNumKey].
Map<String, Map<String, dynamic>> chapterPerformanceMap(dynamic subjectPerformance) {
  final map = <String, Map<String, dynamic>>{};
  for (final raw in asList(asMap(subjectPerformance)?['chapters'])) {
    final ch = asMap(raw);
    if (ch == null) continue;
    final activityMap = <String, Map<String, dynamic>>{};
    for (final a in asList(ch['activities'])) {
      final am = asMap(a);
      if (am != null) activityMap[jsNumKey(am['activity_id'])] = am;
    }
    map[jsNumKey(ch['chapter_id'])] = {...ch, 'activityMap': activityMap};
  }
  return map;
}

/// `a.description?.content ? content.replace(/<[^>]+>/g, '').slice(0, 100) : ''`.
String descriptionPreview(dynamic activity) {
  final content = asMap(asMap(activity)?['description'])?['content'];
  if (!jsTruthy(content)) return '';
  final text = jsDisplay(content).replaceAll(RegExp(r'<[^>]+>'), '');
  // String.prototype.slice counts UTF-16 code units, like Dart's substring.
  return text.length <= 100 ? text : text.substring(0, 100);
}

// ── Inline SVG icons ────────────────────────────────────────────────────────

/// The template's inline heroicon paths (`viewBox="0 0 24 24"`).
abstract final class HeroPaths {
  /// Banner / floating "table" icon.
  static const table = 'M9 3H5a2 2 0 00-2 2v4m6-6h10a2 2 0 012 2v4M9 3v18m0 0h10a2 2 0 002-2v-4'
      'M9 21H5a2 2 0 01-2-2v-4m0 0h18';

  /// Empty activity board.
  static const flag = 'M3 21v-4m0 0V5a2 2 0 012-2h6.5l1 1H21l-3 6 3 6H12.5l-1-1H5a2 2 0 00-2 2zm9-13.5V9';

  /// Chapter Reference button / dialog.
  static const document = 'M9 12h6m-6 4h6m2 5H7a2 2 0 01-2-2V5a2 2 0 012-2h5.586a1 1 0 01.707.293'
      'l5.414 5.414a1 1 0 01.293.707V19a2 2 0 01-2 2z';

  /// "No activities in this chapter".
  static const inbox = 'M20 13V6a2 2 0 00-2-2H6a2 2 0 00-2 2v7m16 0v5a2 2 0 01-2 2H6a2 2 0 01-2-2v-5'
      'm16 0h-2.586a1 1 0 00-.707.293l-2.414 2.414a1 1 0 01-.707.293h-3.172a1 1 0 01-.707-.293'
      'l-2.414-2.414A1 1 0 006.586 13H4';

  /// Activity thumbnail placeholder (two paths).
  static const playCircle = 'M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832'
      'l3.197-2.132a1 1 0 000-1.664z M21 12a9 9 0 11-18 0 9 9 0 0118 0z';

  /// Why Learn dialog.
  static const lightBulb = 'M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3'
      'm3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19'
      'a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z';

  /// Dialog close (×).
  static const x = 'M6 18L18 6M6 6l12 12';

  /// LAUNCH ▶ (filled).
  static const play = 'M8 5v14l11-7z';

  /// The 5-point star.
  static const star = 'M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14'
      ' 2 9.27l6.91-1.01L12 2z';
}

final _svgPathCache = <String, Path>{};

/// SVG path data → [Path]: `M L H V C S Q T A Z` (absolute and relative),
/// implicit repeats, and compact arc flags (`a2 2 0 012-2`). Cached.
Path svgPath(String d) => _svgPathCache[d] ??= _SvgPathParser(d).parse();

class _SvgPathParser {
  _SvgPathParser(this.d);
  final String d;
  int i = 0;

  bool _isSep(int c) => c == 0x20 || c == 0x2C || c == 0x0A || c == 0x0D || c == 0x09;
  bool _isDigit(int c) => c >= 0x30 && c <= 0x39;

  void _skip() {
    while (i < d.length && _isSep(d.codeUnitAt(i))) {
      i++;
    }
  }

  bool _atNumber() {
    _skip();
    if (i >= d.length) return false;
    final c = d.codeUnitAt(i);
    return _isDigit(c) || c == 0x2D || c == 0x2B || c == 0x2E;
  }

  double _num() {
    _skip();
    final start = i;
    if (i < d.length && (d[i] == '-' || d[i] == '+')) i++;
    var dot = false, exp = false;
    while (i < d.length) {
      final c = d.codeUnitAt(i);
      if (_isDigit(c)) {
        i++;
      } else if (c == 0x2E && !dot && !exp) {
        dot = true;
        i++;
      } else if ((c == 0x65 || c == 0x45) && !exp) {
        exp = true;
        i++;
        if (i < d.length && (d[i] == '-' || d[i] == '+')) i++;
      } else {
        break;
      }
    }
    return double.tryParse(d.substring(start, i)) ?? 0;
  }

  bool _flag() {
    _skip();
    final f = i < d.length && d[i] == '1';
    i++;
    return f;
  }

  Path parse() {
    final path = Path();
    var cx = 0.0, cy = 0.0, sx = 0.0, sy = 0.0;
    double? ctrlX, ctrlY; // last cubic / quadratic control point
    var last = '';
    while (true) {
      _skip();
      if (i >= d.length) break;
      final ch = d[i];
      if (!RegExp(r'[MmLlHhVvCcSsQqTtAaZz]').hasMatch(ch)) {
        i++;
        continue;
      }
      i++;
      final rel = ch == ch.toLowerCase();
      var c = ch.toUpperCase();
      if (c == 'Z') {
        path.close();
        cx = sx;
        cy = sy;
        last = 'Z';
        ctrlX = null;
        continue;
      }
      do {
        final ox = rel ? cx : 0.0, oy = rel ? cy : 0.0;
        switch (c) {
          case 'M':
            cx = _num() + ox;
            cy = _num() + oy;
            path.moveTo(cx, cy);
            sx = cx;
            sy = cy;
            ctrlX = null;
            // Further pairs are implicit line-tos.
            c = 'L';
          case 'L':
            cx = _num() + ox;
            cy = _num() + oy;
            path.lineTo(cx, cy);
            ctrlX = null;
          case 'H':
            cx = _num() + ox;
            path.lineTo(cx, cy);
            ctrlX = null;
          case 'V':
            cy = _num() + oy;
            path.lineTo(cx, cy);
            ctrlX = null;
          case 'C':
            final x1 = _num() + ox, y1 = _num() + oy;
            final x2 = _num() + ox, y2 = _num() + oy;
            cx = _num() + ox;
            cy = _num() + oy;
            path.cubicTo(x1, y1, x2, y2, cx, cy);
            ctrlX = x2;
            ctrlY = y2;
          case 'S':
            final smooth = (last == 'C' || last == 'S') && ctrlX != null;
            final x1 = smooth ? 2 * cx - ctrlX : cx;
            final y1 = smooth ? 2 * cy - ctrlY! : cy;
            final x2 = _num() + ox, y2 = _num() + oy;
            cx = _num() + ox;
            cy = _num() + oy;
            path.cubicTo(x1, y1, x2, y2, cx, cy);
            ctrlX = x2;
            ctrlY = y2;
          case 'Q':
            final x1 = _num() + ox, y1 = _num() + oy;
            cx = _num() + ox;
            cy = _num() + oy;
            path.quadraticBezierTo(x1, y1, cx, cy);
            ctrlX = x1;
            ctrlY = y1;
          case 'T':
            final smooth = (last == 'Q' || last == 'T') && ctrlX != null;
            final x1 = smooth ? 2 * cx - ctrlX : cx;
            final y1 = smooth ? 2 * cy - ctrlY! : cy;
            cx = _num() + ox;
            cy = _num() + oy;
            path.quadraticBezierTo(x1, y1, cx, cy);
            ctrlX = x1;
            ctrlY = y1;
          case 'A':
            final rx = _num().abs(), ry = _num().abs(), rot = _num();
            final large = _flag(), sweep = _flag();
            cx = _num() + ox;
            cy = _num() + oy;
            if (rx == 0 || ry == 0) {
              path.lineTo(cx, cy);
            } else {
              path.arcToPoint(Offset(cx, cy),
                  radius: Radius.elliptical(rx, ry), rotation: rot, largeArc: large, clockwise: sweep);
            }
            ctrlX = null;
        }
        last = c;
      } while (_atNumber());
    }
    return path;
  }
}
