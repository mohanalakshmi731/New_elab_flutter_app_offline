/// Pure layout of the Class Math roadmap — the module-level helpers and the
/// computed properties of `src/components/Mathzoro/classmath.vue`
/// (`snakePt`, `buildSmoothPath`, `buildRiverPath`, `perpOffset`, `seeded`,
/// `chapterNodes`, `bgTrees`, `roadTrees`, `bushes`, `flowers`, `houses`,
/// `barns`, `tents`, `fences`, `campfires`, `buntingItems`).
///
/// Everything is in stage (SVG user-space) pixels; the painters in
/// `class_math_painters.dart` draw it.
library;

import 'dart:math' as math;
import 'dart:ui' show Color, Offset;

const double kNodeGap = 260;
const double kRoadW = 68;
const double kRiverW = 38;
const double kSnakeAmpFrac = 0.28;
const double kSnakeFreq = 0.5;

const double kSignW = 168;
const double kSignH = 90;

const List<Color> kBuntingCols = [
  Color(0xFFFF6B6B),
  Color(0xFFFFD93D),
  Color(0xFF6BCB77),
  Color(0xFF4D96FF),
  Color(0xFFFF8CC8),
  Color(0xFFF97316),
  Color(0xFFA78BFA),
];

class HousePalette {
  const HousePalette(this.wall, this.wallDark, this.roof, this.roofDark, this.door, this.chimney);
  final Color wall;
  final Color wallDark;
  final Color roof;
  final Color roofDark;
  final Color door;
  final Color chimney;
}

const List<HousePalette> kHousePalettes = [
  HousePalette(Color(0xFFF5F0E8), Color(0xFF111827), Color(0xFFC83030), Color(0xFF1E293B),
      Color(0xFF8B4513), Color(0xFFA04020)),
  HousePalette(Color(0xFFEAF0FF), Color(0xFF111827), Color(0xFF2060C8), Color(0xFF1E3A5F),
      Color(0xFF5A3010), Color(0xFF607080)),
  HousePalette(Color(0xFFFFFDE8), Color(0xFF111827), Color(0xFFE84040), Color(0xFF1E293B),
      Color(0xFF7B3F00), Color(0xFF8A4020)),
  HousePalette(Color(0xFFF0F8E8), Color(0xFF111827), Color(0xFF308030), Color(0xFF1E3A5F),
      Color(0xFF4A2808), Color(0xFF506040)),
  HousePalette(Color(0xFFFEF0F8), Color(0xFF111827), Color(0xFFC040A0), Color(0xFF1E293B),
      Color(0xFF7B2060), Color(0xFF804060)),
];

/// `snakePt(t, count, W)`.
Offset snakePt(double t, int count, double w) {
  final y = 340 + (count - 1) * kNodeGap - t * kNodeGap;
  final x = w / 2 + w * kSnakeAmpFrac * math.cos(t * math.pi * 2 * kSnakeFreq);
  return Offset(x, y);
}

/// `nodePt(i, count, W)`.
Offset nodePt(num i, int count, double w) => snakePt(i.toDouble(), count, w);

/// `perpOffset(i, count, W)` → `{ px, py }`.
({double px, double py}) perpOffset(num i, int count, double w) {
  const dt = 0.05;
  final a = snakePt(math.max(0, i - dt).toDouble(), count, w);
  final b = snakePt(math.min(count - 1, i + dt).toDouble(), count, w);
  final dx = b.dx - a.dx, dy = b.dy - a.dy;
  var len = math.sqrt(dx * dx + dy * dy);
  if (len == 0 || len.isNaN) len = 1; // `|| 1`
  return (px: -dy / len, py: dx / len);
}

/// `seeded(seed)` — the LCG used for tree / bush / flower sizes. Reproduces
/// the JavaScript int32 arithmetic (`& 0xffffffff`, `>>> 0`).
double Function() seeded(int seed) {
  var s = seed;
  return () {
    var v = (s * 1664525 + 1013904223) & 0xffffffff;
    if (v >= 0x80000000) v -= 0x100000000; // ToInt32
    s = v;
    return (s & 0xffffffff) / 0xffffffff;
  };
}

/// One cubic Bézier segment (`C c1 c2 to`).
class CubicSeg {
  const CubicSeg(this.c1, this.c2, this.to);
  final Offset c1;
  final Offset c2;
  final Offset to;
}

/// A smooth path: `M start` followed by [segments].
class SmoothPath {
  const SmoothPath(this.start, this.segments);
  final Offset? start;
  final List<CubicSeg> segments;

  static const empty = SmoothPath(null, []);
}

/// Catmull-Rom (tension 0.5) through [pts], as `buildSmoothPath` writes it.
SmoothPath _catmullRom(List<Offset> pts) {
  final segs = <CubicSeg>[];
  for (var i = 0; i < pts.length - 1; i++) {
    final p0 = pts[math.max(0, i - 1)], p1 = pts[i], p2 = pts[i + 1];
    final p3 = pts[math.min(pts.length - 1, i + 2)];
    const t = 0.5;
    segs.add(CubicSeg(
      Offset(p1.dx + (p2.dx - p0.dx) * t / 3, p1.dy + (p2.dy - p0.dy) * t / 3),
      Offset(p2.dx - (p3.dx - p1.dx) * t / 3, p2.dy - (p3.dy - p1.dy) * t / 3),
      p2,
    ));
  }
  return SmoothPath(pts.first, segs);
}

/// `buildSmoothPath(count, W)` — the road.
SmoothPath buildSmoothPath(int count, double w) {
  if (count <= 0) return SmoothPath.empty;
  if (count == 1) return SmoothPath(snakePt(0, count, w), const []);
  const subs = 20;
  final total = (count - 1) * subs;
  final pts = List.generate(total + 1, (s) => snakePt(s / total * (count - 1), count, w));
  return _catmullRom(pts);
}

/// `buildRiverPath(count, W)`. With one chapter the web divides 0 by 0 and
/// produces `M NaN NaN` (nothing drawn) — returned as an empty path.
SmoothPath buildRiverPath(int count, double w) {
  if (count <= 1) return SmoothPath.empty;
  const subs = 20;
  final total = (count - 1) * subs;
  final pts = List.generate(total + 1, (s) {
    final t2 = s / total * (count - 1);
    final y = 340 + (count - 1) * kNodeGap - t2 * kNodeGap;
    final x = w / 2 + w * 0.36 * math.cos(t2 * math.pi * 2 * kSnakeFreq + 0.8);
    return Offset(math.max(12, math.min(w - 12, x)), y);
  });
  return _catmullRom(pts);
}

/// `stageH` — `Math.max(window.innerHeight || 700, (n - 1) * NODE_GAP + 520)`.
double stageHeight(int count, double windowHeight) =>
    math.max(windowHeight == 0 ? 700 : windowHeight, (count - 1) * kNodeGap + 520);

/// `winBannerY`.
double winBannerY(int count, double w) =>
    count == 0 ? 80 : nodePt(count - 1, count, w).dy - 140;

/// An entry of `chapterNodes` (`{ ...ch, number, x, y, signX, signY }`).
class ChapterNode {
  const ChapterNode({
    required this.chapter,
    required this.number,
    required this.x,
    required this.y,
    required this.signX,
    required this.signY,
  });
  final Map<String, dynamic> chapter;
  final int number;
  final double x;
  final double y;
  final double signX;
  final double signY;

  dynamic get id => chapter['id'];
  dynamic get name => chapter['name'];

  /// The object the web passed around (`activeChapter`).
  Map<String, dynamic> toJson() =>
      {...chapter, 'number': number, 'x': x, 'y': y, 'signX': signX, 'signY': signY};
}

List<ChapterNode> chapterNodes(List<Map<String, dynamic>> chapters, double w) {
  final count = chapters.length;
  const sw = kRoadW / 2 + 20;
  return [
    for (var i = 0; i < count; i++)
      () {
        final pt = nodePt(i, count, w);
        final px = perpOffset(i, count, w).px;
        final side = pt.dx >= w / 2 ? -1 : 1;
        final offX = side * px * sw;
        var signX = side == -1 ? pt.dx + offX - kSignW : pt.dx + offX;
        signX = math.max(4, math.min(w - kSignW - 4, signX));
        return ChapterNode(
          chapter: chapters[i],
          number: i + 1,
          x: pt.dx,
          y: pt.dy,
          signX: signX,
          signY: pt.dy - kSignH / 2 - 10,
        );
      }(),
  ];
}

class Tree {
  const Tree(this.x, this.y, this.sz, this.c1, this.c2, this.c3);
  final double x;
  final double y;
  final double sz;
  final Color c1;
  final Color c2;
  final Color c3;
}

typedef _Pal = (Color, Color, Color);

const List<_Pal> _bgTreesLight = [
  (Color(0xFF2A8830), Color(0xFF38AA3C), Color(0xFF48C850)),
  (Color(0xFF208028), Color(0xFF2E9C34), Color(0xFF3CB840)),
  (Color(0xFF186020), Color(0xFF258C2C), Color(0xFF32A838)),
  (Color(0xFF306038), Color(0xFF3E7E48), Color(0xFF4EA058)),
];
const List<_Pal> _bgTreesDark = [
  (Color(0xFF1E293B), Color(0xFF1E3A5F), Color(0xFF334155)),
  (Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF1E3A5F)),
  (Color(0xFF1E293B), Color(0xFF334155), Color(0xFF1E3A5F)),
  (Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF334155)),
];

/// `bgTrees`.
List<Tree> bgTrees(double w, double h, bool dark) {
  final rng = seeded(42);
  final palette = dark ? _bgTreesDark : _bgTreesLight;
  const positions = [
    (0.04, 0.10), (0.12, 0.08), (0.20, 0.13), (0.78, 0.08), (0.86, 0.11),
    (0.93, 0.07), (0.07, 0.22), (0.91, 0.20), (0.03, 0.32), (0.95, 0.30),
  ];
  return [
    for (var k = 0; k < positions.length; k++)
      () {
        final p = palette[k % palette.length];
        return Tree(w * positions[k].$1, h * positions[k].$2, 44 + rng() * 28, p.$1, p.$2, p.$3);
      }(),
  ];
}

const List<_Pal> _roadTreesLight = [
  (Color(0xFF1E7A28), Color(0xFF2A9A34), Color(0xFF38B842)),
  (Color(0xFF166018), Color(0xFF228022), Color(0xFF30A030)),
  (Color(0xFF248030), Color(0xFF30A03C), Color(0xFF40C04A)),
];
const List<_Pal> _roadTreesDark = [
  (Color(0xFF1E293B), Color(0xFF1E3A5F), Color(0xFF334155)),
  (Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF1E3A5F)),
  (Color(0xFF1E3A5F), Color(0xFF1D4ED8), Color(0xFF334155)),
];

/// JS `x | 0` for the small positive values used here.
int _trunc(double v) => v.truncate();

/// `roadTrees`.
List<Tree> roadTrees(int count, double w, bool dark) {
  final list = <Tree>[];
  if (count == 0) return list;
  final rng = seeded(77);
  final palette = dark ? _roadTreesDark : _roadTreesLight;
  const hr = kRoadW / 2;
  const dists = [hr + 36, hr + 76, hr + 118];
  const vos = [-14, 18, -8];
  for (var i = 0; i < count; i++) {
    final pt = nodePt(i, count, w);
    final p = perpOffset(i, count, w);
    for (var oi = 0; oi < dists.length; oi++) {
      final dist = dists[oi];
      for (final s in const [-1, 1]) {
        final x = pt.dx + s * p.px * dist, y = pt.dy + s * p.py * dist + vos[oi];
        if (x >= 12 && x <= w - 12) {
          final pal = palette[(i + oi) % palette.length];
          list.add(Tree(x, y, (22 + _trunc(rng() * 18)).toDouble(), pal.$1, pal.$2, pal.$3));
        }
      }
    }
  }
  return list;
}

class Bush {
  const Bush(this.x, this.y, this.r, this.col);
  final double x;
  final double y;
  final double r;
  final Color col;
}

/// `bushes`.
List<Bush> bushes(int count, double w, bool dark) {
  final list = <Bush>[];
  final rng = seeded(13);
  const lc = [Color(0xFF4ABE2C), Color(0xFF38A820), Color(0xFF56CC38), Color(0xFF42B02A)];
  const dc = [Color(0xFF1E293B), Color(0xFF1E3A5F), Color(0xFF334155), Color(0xFF0F172A)];
  final cols = dark ? dc : lc;
  const hr = kRoadW / 2;
  const dists = [hr + 12, hr + 52];
  for (var i = 0; i < count; i++) {
    final pt = nodePt(i, count, w);
    final p = perpOffset(i, count, w);
    for (var di = 0; di < dists.length; di++) {
      for (final s in const [-1, 1]) {
        final x = pt.dx + s * p.px * dists[di], y = pt.dy + s * p.py * dists[di] + di * 16;
        if (x >= 8 && x <= w - 8) {
          list.add(Bush(x, y, (10 + _trunc(rng() * 14)).toDouble(), cols[list.length % 4]));
        }
      }
    }
  }
  return list;
}

class Flower {
  const Flower(this.x, this.y, this.r, this.col, this.petal);
  final double x;
  final double y;
  final double r;
  final Color col;
  final Color petal;
}

/// `flowers`.
List<Flower> flowers(int count, double w, bool dark) {
  final list = <Flower>[];
  final rng = seeded(99);
  final fc = dark
      ? const [Color(0xFF1E3A5F), Color(0xFF1D4ED8), Color(0xFF334155), Color(0xFF1E293B),
          Color(0xFF0F172A), Color(0xFF1E3A5F)]
      : const [Color(0xFFFF6B6B), Color(0xFFFFD93D), Color(0xFFFF8CC8), Color(0xFFA78BFA),
          Color(0xFF60D8F8), Color(0xFFFF9F43)];
  final pc = dark
      ? const [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A), Color(0xFF1E293B),
          Color(0xFF0F172A), Color(0xFF1E293B)]
      : const [Color(0xFFFFB3B3), Color(0xFFFFF0A0), Color(0xFFFFC2E2), Color(0xFFC4B5FD),
          Color(0xFFB0EEFF), Color(0xFFFFCF96)];
  const hr = kRoadW / 2;
  for (var i = 0; i < count; i++) {
    final pt = nodePt(i, count, w);
    final p = perpOffset(i, count, w);
    for (var f = 0; f < 7; f++) {
      final dist = hr + 16 + (f % 3) * 26;
      final yOff = ((f * 19) % 38) - 18;
      for (final s in const [-1, 1]) {
        final x = pt.dx + s * p.px * dist, y = pt.dy + s * p.py * dist + yOff;
        if (x >= 8 && x <= w - 8) {
          final k = list.length;
          list.add(Flower(x, y, (4 + _trunc(rng() * 3)).toDouble(), fc[k % fc.length],
              pc[k % pc.length]));
        }
      }
    }
  }
  return list;
}

class House {
  const House(this.x, this.y, this.w, this.h, this.rh, this.palette);
  final double x;
  final double y;
  final double w;
  final double h;
  final double rh;
  final HousePalette palette;
}

/// `houses`.
List<House> houses(int count, double w, double h) {
  if (count == 0) return const [];
  const placements = [
    (0.06, 0.12), (0.74, 0.06), (0.80, 0.25), (0.04, 0.28),
    (0.78, 0.45), (0.05, 0.50), (0.80, 0.65), (0.04, 0.68),
  ];
  return [
    for (var k = 0; k < placements.length; k++)
      () {
        final hw = 60.0 + (k % 3) * 14, hh = 46.0 + (k % 2) * 10;
        return House(w * placements[k].$1, h * placements[k].$2 - hh, hw, hh,
            32.0 + (k % 2) * 8, kHousePalettes[k % kHousePalettes.length]);
      }(),
  ];
}

class Barn {
  const Barn(this.x, this.y, this.w, this.h, this.rh);
  final double x;
  final double y;
  final double w;
  final double h;
  final double rh;
}

/// `barns`.
List<Barn> barns(int count, double w, double h) {
  if (count == 0) return const [];
  const placements = [(0.72, 0.18), (0.06, 0.38), (0.76, 0.55)];
  return [
    for (var k = 0; k < placements.length; k++)
      () {
        final bw = 72.0 + k * 8, bh = 52.0 + k * 4;
        return Barn(w * placements[k].$1, h * placements[k].$2 - bh, bw, bh, 36);
      }(),
  ];
}

class Tent {
  const Tent(this.x, this.y, this.col, this.colDark);
  final double x;
  final double y;
  final Color col;
  final Color colDark;
}

/// `tents`.
List<Tent> tents(double w, double h) => [
      Tent(w * 0.08, h * 0.55, const Color(0xFFF5A020), const Color(0xFF1E293B)),
      Tent(w * 0.88, h * 0.42, const Color(0xFFE84040), const Color(0xFF0F172A)),
      Tent(w * 0.10, h * 0.72, const Color(0xFF40A8E8), const Color(0xFF1E3A5F)),
    ];

class Fence {
  const Fence(this.x, this.y, this.w);
  final double x;
  final double y;
  final double w;
}

/// `fences`.
List<Fence> fences(double w, double h) => [
      Fence(w * 0.03, h * 0.22, w * 0.14),
      Fence(w * 0.78, h * 0.10, w * 0.18),
      Fence(w * 0.03, h * 0.45, w * 0.12),
    ];

class Campfire {
  const Campfire(this.x, this.y, this.r);
  final double x;
  final double y;
  final double r;
}

/// `campfires` (drawn in dark mode only).
List<Campfire> campfires(double w, double h) => [
      Campfire(w * 0.12, h * 0.58, 10),
      Campfire(w * 0.84, h * 0.46, 9),
      Campfire(w * 0.14, h * 0.75, 11),
      Campfire(w * 0.10, h * 0.32, 8),
      Campfire(w * 0.78, h * 0.20, 9),
    ];

class Bunting {
  const Bunting(this.p1, this.p2, this.p3, this.col);
  final Offset p1;
  final Offset p2;
  final Offset p3;
  final Color col;
}

/// `buntingItems`.
List<Bunting> buntingItems(int count, double w) {
  if (count == 0) return const [];
  final y = winBannerY(count, w) + 14, x1 = w * 0.18, x2 = w * 0.82;
  const n = 18, sz = 13.0;
  return [
    for (var i = 0; i < n; i++)
      () {
        final x = x1 + (x2 - x1) * (i / (n - 1));
        return Bunting(Offset(x, y), Offset(x - sz * 0.58, y + sz * 1.4),
            Offset(x + sz * 0.58, y + sz * 1.4), kBuntingCols[i % kBuntingCols.length]);
      }(),
  ];
}

/// Everything the roadmap SVG needs for one (count, size, theme).
class ClassMathScene {
  ClassMathScene({
    required this.count,
    required this.stageW,
    required this.stageH,
    required this.dark,
  })  : roadPath = buildSmoothPath(count, stageW),
        riverPath = buildRiverPath(count, stageW),
        bannerY = winBannerY(count, stageW),
        bgTreeItems = bgTrees(stageW, stageH, dark),
        roadTreeItems = roadTrees(count, stageW, dark),
        bushItems = bushes(count, stageW, dark),
        flowerItems = flowers(count, stageW, dark),
        houseItems = houses(count, stageW, stageH),
        barnItems = barns(count, stageW, stageH),
        tentItems = tents(stageW, stageH),
        fenceItems = fences(stageW, stageH),
        campfireItems = campfires(stageW, stageH),
        buntings = buntingItems(count, stageW);

  final int count;
  final double stageW;
  final double stageH;
  final bool dark;

  final SmoothPath roadPath;
  final SmoothPath riverPath;
  final double bannerY;
  final List<Tree> bgTreeItems;
  final List<Tree> roadTreeItems;
  final List<Bush> bushItems;
  final List<Flower> flowerItems;
  final List<House> houseItems;
  final List<Barn> barnItems;
  final List<Tent> tentItems;
  final List<Fence> fenceItems;
  final List<Campfire> campfireItems;
  final List<Bunting> buntings;

  bool sameAs(int count, double w, double h, bool dark) =>
      this.count == count && stageW == w && stageH == h && this.dark == dark;
}
