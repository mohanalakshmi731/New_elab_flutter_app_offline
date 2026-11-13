import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:elab_app/features/zones/zone_widgets.dart' show ZoneSvg, parseSvgPathData;
import 'package:elab_app/features/zones/zones_logic.dart';

void main() {
  group('road geometry', () {
    test('buildMilestonePoints snakes between bottom and top rows', () {
      expect(buildMilestonePoints(0, 800), isEmpty);
      expect(buildMilestonePoints(1, 800), [const Offset(110, 280)]);
      expect(buildMilestonePoints(3, 800), const [
        Offset(110, 280),
        Offset(400, 110),
        Offset(690, 280),
      ]);
    });

    test('pathMinWidth keeps at least MIN_STEP between milestones', () {
      expect(pathMinWidth(0, 800), 800);
      expect(pathMinWidth(1, 640), 640);
      expect(pathMinWidth(3, 800), 800); // 2 * 276 + 220 = 772
      expect(pathMinWidth(5, 800), 4 * 276 + 220);
    });

    test('roadSegments uses mid-x control points', () {
      final segs = roadSegments(const [Offset(110, 280), Offset(400, 110)]);
      expect(segs, hasLength(1));
      expect(segs.first.$1, const Offset(255, 280));
      expect(segs.first.$2, const Offset(255, 110));
      expect(segs.first.$3, const Offset(400, 110));
      expect(roadSegments(const [Offset(1, 2)]), isEmpty);
    });
  });

  group('stars', () {
    test('ticketsToStars mirrors Math.min(5, Math.floor(Number(t)))', () {
      expect(ticketsToStars(null), 0);
      expect(ticketsToStars(0), 0);
      expect(ticketsToStars(''), 0);
      expect(ticketsToStars(-2), 0);
      expect(ticketsToStars(3.7), 3);
      expect(ticketsToStars('4'), 4);
      expect(ticketsToStars(9), 5);
      expect(ticketsToStars('abc').isNaN, isTrue);
    });

    test('starColor differs between math and science at 4-5 stars', () {
      expect(starColor(5, science: false), const Color(0xFFFACC15));
      expect(starColor(5, science: true), const Color(0xFF4ADE80));
      expect(starColor(4, science: false), const Color(0xFFFDE047));
      expect(starColor(4, science: true), const Color(0xFFFACC15));
      expect(starColor(3, science: true), const Color(0xFFFB923C));
      expect(starColor(2, science: false), const Color(0xFFF59E0B));
      expect(starColor(1, science: false), const Color(0xFFFDE047));
      expect(starColor(0, science: false).a, 0);
    });
  });

  group('performance', () {
    final perf = {
      'chapters': [
        {
          'chapter_id': '12',
          'earned_tickets': 7,
          'activities': [
            {'activity_id': 3, 'earned_tickets': 5},
            {'activity_id': '4', 'earned_tickets': 2},
          ],
        },
        {'chapter_id': 13, 'activities': []},
      ],
    };

    test('chapterPerformanceMap keys by Number(id)', () {
      final map = chapterPerformanceMap(perf);
      expect(map.keys, containsAll(['12', '13']));
      final activityMap = map['12']!['activityMap'] as Map;
      expect(activityMap.keys, containsAll(['3', '4']));
      expect(map[numKey(12)], isNotNull);
      expect(map[numKey(12.0)], isNotNull);
      expect(chapterPerformanceMap(null), isEmpty);
      expect(chapterPerformanceMap({'data': perf}), isEmpty); // unwrapped response only
    });

    test('chapterPct = round(earned / (activities * 5) * 100)', () {
      final map = chapterPerformanceMap(perf);
      expect(chapterPct(map['12']), 70);
      expect(chapterPct(map['13']), 0);
      expect(chapterPct(null), 0);
      expect(chapterPct({'activities': [1, 2, 3], 'earned_tickets': '1'}), 7); // 6.67
      expect(chapterPct({'activities': [1, 2], 'earned_tickets': 0.25}), 3); // 2.5 → 3
    });

    test('pct labels and bar fractions', () {
      expect(pctBadgeLabel(0), '0%');
      expect(pctBadgeLabel(double.nan), '0%');
      expect(pctBadgeLabel(42), '42%');
      expect(pctFraction(150), 1);
      expect(pctFraction(25), 0.25);
      expect(pctFraction(double.nan), 0);
      expect(jsNumDisplay(70), '70');
      expect(jsNumDisplay(double.nan), 'NaN');
    });
  });

  group('activities', () {
    test('flattenTopics copies topic fields and falls back to the topic image', () {
      final acts = flattenTopics([
        {
          'id': 1,
          'name': 'Fractions',
          'file_path': 'topic.png',
          'activities': [
            {'id': 10, 'name': 'A', 'file_path': ''},
            {'id': 11, 'name': 'B', 'file_path': 'b.png'},
          ],
        },
        {'id': 2, 'name': 'Empty'},
      ], 99);
      expect(acts, hasLength(2));
      expect(acts[0]['file_path'], 'topic.png');
      expect(acts[1]['file_path'], 'b.png');
      expect(acts[0]['topic_name'], 'Fractions');
      expect(acts[0]['topic_id'], 1);
      expect(acts[0]['chapter_id'], 99);
      expect(flattenTopics(null, 1), isEmpty);
      expect(() => flattenTopics({'data': []}, 1), throwsStateError);
    });

    test('flatOne / totalActivityCount', () {
      final flat = flatOne([
        [
          {'activities': [1, 2]},
          {'activities': null},
        ],
        {'activities': [1]},
        null,
      ]);
      expect(flat, hasLength(4));
      expect(totalActivityCount(flat), 3);
    });

    test('persistedChapterIndex falls back to the first chapter', () {
      final chapters = [
        {'id': 5},
        {'id': 7},
      ];
      expect(persistedChapterIndex(chapters, '7'), 1);
      expect(persistedChapterIndex(chapters, 7), 1);
      expect(persistedChapterIndex(chapters, null), 0);
      expect(persistedChapterIndex(chapters, '9'), 0);
    });

    test('dataOr mirrors res.data || res || fallback', () {
      expect(dataOr({'data': [1]}, const []), [1]);
      expect(dataOr({'data': null, 'x': 1}, const []), {'data': null, 'x': 1});
      expect(dataOr(null, const []), const []);
      expect(dataOr([], 'f'), []);
    });
  });

  group('inline SVG paths', () {
    test('the template icons parse inside the 24×24 viewBox', () {
      for (final d in [ZoneSvg.bulb, ZoneSvg.beaker, ZoneSvg.warning, ZoneSvg.question, ZoneSvg.close]) {
        // (getBounds includes curve control points)
        final b = parseSvgPathData(d).getBounds();
        expect(b.left, greaterThanOrEqualTo(0.5), reason: d);
        expect(b.top, greaterThanOrEqualTo(0.5), reason: d);
        expect(b.right, lessThanOrEqualTo(23.5), reason: d);
        expect(b.bottom, lessThanOrEqualTo(23.5), reason: d);
        expect(b.width, greaterThan(10), reason: d);
      }
      expect(parseSvgPathData(ZoneSvg.close).getBounds(), const Rect.fromLTRB(6, 6, 18, 18));
    });

    test('arc flags need no separators (`a2 2 0 11-4 0`)', () {
      final path = parseSvgPathData('M12 19a2 2 0 11-4 0');
      final metric = path.computeMetrics().single;
      final end = metric.getTangentForOffset(metric.length)!.position;
      expect(end.dx, closeTo(8, 1e-3));
      expect(end.dy, closeTo(19, 1e-3));
      // A half circle of radius 2 below the chord (sweep-flag 1), as two
      // quarter-circle cubics whose control points stay inside its box.
      expect(path.getBounds(), rectMoreOrLessEquals(const Rect.fromLTRB(8, 19, 12, 21), epsilon: 1e-6));
    });

    test('relative moves after z start from the closed subpath', () {
      final b = parseSvgPathData('M2 2h4v4h-4zm10 0h2').getBounds();
      expect(b, const Rect.fromLTRB(2, 2, 14, 6));
    });
  });
}
