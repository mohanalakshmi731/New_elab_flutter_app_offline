import 'package:flutter_test/flutter_test.dart';
import 'package:elab_app/features/math_play/class_math_scene.dart';
import 'package:elab_app/features/math_play/math_play_store.dart';

/// Expected values were produced by running the original JavaScript of
/// classmath.vue / mathplay.vue in Node.
void main() {
  Matcher near(double v) => closeTo(v, 1e-9);

  group('classmath.vue scene', () {
    test('seeded(42) reproduces the JS LCG', () {
      final rng = seeded(42);
      const expected = [
        0.25234517484259444,
        0.08812504543180695,
        0.5772811983659121,
        0.22255426603894546,
        0.37566019719831184,
      ];
      for (final e in expected) {
        expect(rng(), near(e));
      }
    });

    test('chapterNodes for 5 chapters on an 800px stage', () {
      final chapters = [for (var i = 0; i < 5; i++) <String, dynamic>{'id': i + 1, 'name': 'Ch $i'}];
      final nodes = chapterNodes(chapters, 800);
      const expected = [
        [624.0, 1380.0, 403.1755518689474, 1325.0],
        [175.99999999999997, 1120.0, 229.99999999999997, 1065.0],
        [624.0, 860.0, 402.0, 805.0],
        [175.99999999999997, 600.0, 229.99999999999997, 545.0],
        [624.0, 340.0, 403.1755518689474, 285.0],
      ];
      for (var i = 0; i < 5; i++) {
        expect(nodes[i].number, i + 1);
        expect(nodes[i].x, near(expected[i][0]));
        expect(nodes[i].y, near(expected[i][1]));
        expect(nodes[i].signX, near(expected[i][2]));
        expect(nodes[i].signY, near(expected[i][3]));
      }
    });

    test('decorations for 5 chapters (800 × 1560)', () {
      expect(stageHeight(5, 700), 1560);
      final s = ClassMathScene(count: 5, stageW: 800, stageH: 1560, dark: false);
      expect(s.roadTreeItems.length, 30);
      expect(s.bushItems.length, 20);
      expect(s.flowerItems.length, 70);

      final rt = s.roadTreeItems;
      expect(rt[0].x, near(555.5238635338206));
      expect(rt[0].y, near(1380.5264839057902));
      expect(rt[0].sz, 26);
      expect(rt[1].x, near(692.4761364661794));
      expect(rt[2].y, near(1420.8273318519562));
      expect(rt[2].sz, 31);

      expect(s.bushItems[0].x, near(579.0013960365108));
      expect(s.bushItems[0].r, 13);
      expect(s.bushItems[2].y, near(1413.8468230842566));
      expect(s.bushItems[2].r, 20);

      expect(s.flowerItems[0].x, near(575.088473952729));
      expect(s.flowerItems[0].r, 4);
      expect(s.flowerItems.last.y, near(332.37605993270734));
      expect(s.flowerItems.last.r, 5);

      expect(s.bgTreeItems[0].x, near(32));
      expect(s.bgTreeItems[0].y, near(156));
      expect(s.bgTreeItems[0].sz, near(51.06566489559265));
      expect(s.bgTreeItems[1].sz, near(46.467501272090594));

      expect(s.bannerY, 200);
      expect(s.buntings.length, 18);
      expect(s.houseItems.length, 8);
      expect(s.barnItems.length, 3);
    });

    test('3 chapters on a 1280px stage', () {
      final s = ClassMathScene(count: 3, stageW: 1280, stageH: 1040, dark: true);
      expect(s.roadTreeItems.length, 18);
      expect(s.bushItems.length, 12);
      expect(s.flowerItems.length, 42);
      expect(s.bannerY, 200);
      final nodes = chapterNodes([
        for (var i = 0; i < 3; i++) <String, dynamic>{'id': i},
      ], 1280);
      expect(nodes[0].x, near(998.4000000000001));
      expect(nodes[0].signX, near(779.265286178857));
      expect(nodes[1].signX, near(335.59999999999997));
    });

    test('one chapter: no river, road is a lone point', () {
      final s = ClassMathScene(count: 1, stageW: 400, stageH: 900, dark: false);
      expect(s.riverPath.start, isNull);
      expect(s.roadPath.segments, isEmpty);
      expect(s.roadTreeItems.length, 6);
      expect(s.roadTreeItems.every((t) => t.x == 312), isTrue);
    });

    test('road path is sampled 20 segments per gap', () {
      expect(buildSmoothPath(4, 800).segments.length, 60);
      expect(buildRiverPath(4, 800).segments.length, 60);
    });
  });

  group('classmath.vue selection', () {
    test('pickMathSubject prefers exact "Mathematics", then math-but-not-play, then first', () {
      expect(
          pickMathSubject([
            {'id': 1, 'name': 'Math Play'},
            {'id': 2, 'name': ' mathematics '},
          ])['id'],
          2);
      expect(
          pickMathSubject([
            {'id': 1, 'name': 'Math Play'},
            {'id': 3, 'name': 'Maths'},
          ])['id'],
          3);
      expect(
          pickMathSubject([
            {'id': 5, 'name': 'Science'},
          ])['id'],
          5);
    });

    test('pickClass matches String(id) or falls back to the first class', () {
      final classes = [
        {'id': 7, 'name': 'A'},
        {'id': 9, 'name': 'B'},
      ];
      expect(pickClass(classes, '9')['name'], 'B');
      expect(pickClass(classes, '')['name'], 'A');
    });

    test('filteredChapters keeps only matching subject_id', () {
      final chapters = [
        {'id': 1, 'subject_id': 4},
        {'id': 2, 'subject_id': '4'},
        {'id': 3, 'subject_id': 5},
        {'id': 4},
      ];
      expect(filterChaptersBySubject(chapters, '4').map((c) => c['id']), [1, 2]);
      expect(filterChaptersBySubject(chapters, ''), isEmpty);
    });

    test('arrayOr', () {
      expect(arrayOr([1], 'classes'), [1]);
      expect(arrayOr({'data': [2]}, 'classes'), [2]);
      expect(arrayOr({'classes': [3]}, 'classes'), [3]);
      expect(arrayOr(null, 'classes'), isEmpty);
    });
  });

  group('mathplay.vue helpers', () {
    test('topicColorIndex matches the JS 32-bit hash', () {
      expect(topicColorIndex(''), 0);
      expect(topicColorIndex('Addition'), 4);
      expect(topicColorIndex('Fractions & Decimals'), 3);
      expect(topicColorIndex('Very long topic name for overflow testing 123456789'), 0);
      expect(topicColorIndex('ÄÖ ünïcödé'), 1);
    });

    test('inferLevel', () {
      expect(inferLevel({'name': 'Shapes (Expert)'}), 'expert');
      expect(inferLevel({'name': 'Shapes (advanced)'}), 'intermediate');
      expect(inferLevel({'name': 'Shapes (BEGINNER)'}), 'beginner');
      expect(inferLevel({'name': 'Shapes'}), isNull);
      expect(inferLevel({}), isNull);
      expect(() => inferLevel({'name': null}), throwsStateError);
    });

    test('activity extras: level and is_unlocked', () {
      expect(mathPlayActivityExtras({'level': 'expert', 'name': 'x'}, 2),
          {'chapterNumber': 2, 'level': 'expert', 'is_unlocked': false});
      expect(mathPlayActivityExtras({'name': 'A (Beginner)', 'required_tickets_to_unlock': 0}, 1)['is_unlocked'],
          isTrue);
      expect(mathPlayActivityExtras({'name': 'A', 'required_tickets_to_unlock': '0'}, 1)['is_unlocked'], isFalse);
      expect(mathPlayActivityExtras({'name': 'A', 'is_unlocked': true, 'required_tickets_to_unlock': 5}, 1)
          ['is_unlocked'], isTrue);
    });

    test('flattenTopicActivities', () {
      final topics = [
        {
          'id': 10,
          'name': 'T1',
          'file_path': 'topic.png',
          'activities': [
            {'id': 1, 'name': 'A1'},
            {'id': 2, 'name': 'A2', 'file_path': 'a2.png'},
          ],
        },
        {'id': 11, 'name': 'T2', 'activities': null},
      ];
      final acts = flattenTopicActivities(topics, 99, (a) => mathPlayActivityExtras(a, 3));
      expect(acts.length, 2);
      expect(acts[0]['file_path'], 'topic.png');
      expect(acts[1]['file_path'], 'a2.png');
      expect(acts[0]['topic_name'], 'T1');
      expect(acts[0]['topic_id'], 10);
      expect(acts[0]['chapter_id'], 99);
      expect(acts[0]['chapterNumber'], 3);
      expect(flattenTopicActivities(null, 1), isEmpty);
      expect(() => flattenTopicActivities({'data': []}, 1), throwsStateError);
    });

    test('filterMathPlayActivities', () {
      final all = [
        {'id': 1, 'chapter_id': 1, 'level': 'beginner', 'is_unlocked': true},
        {'id': 2, 'chapter_id': 1, 'level': 'expert', 'is_unlocked': false},
        {'id': 3, 'chapter_id': 2, 'level': null, 'is_unlocked': false},
      ];
      List<dynamic> ids(String ch, String lv, String lock) =>
          filterMathPlayActivities(all, chapterId: ch, level: lv, lockFilter: lock).map((a) => a['id']).toList();
      expect(ids('all', 'all', 'all'), [1, 2, 3]);
      expect(ids('1', 'all', 'all'), [1, 2]);
      expect(ids('all', 'expert', 'all'), [2]);
      expect(ids('all', 'all', 'unlocked'), [1]);
      expect(ids('all', 'all', 'locked'), [2, 3]);
    });

    test('capitalise / jsStringOf / answersPayloadOf', () {
      expect(capitalise('beginner'), 'Beginner');
      expect(capitalise(null), '');
      expect(jsStringOf({'id': 5}, 'id'), '5');
      expect(jsStringOf({}, 'id'), 'undefined');
      expect(jsStringOf(null, 'id'), 'undefined');
      expect(jsStringOf({'id': null}, 'id'), 'null');
      expect(
          answersPayloadOf({
            'answersPayload': [
              {'question_id': 1, 'option_id': '2'},
            ],
          }),
          [
            {'question_id': '1', 'option_id': '2'},
          ]);
    });

    test('dataOrSelf / hasItems', () {
      expect(dataOrSelf({'data': [1]}), [1]);
      expect(dataOrSelf(null), isEmpty);
      expect(hasItems([1]), isTrue);
      expect(hasItems({'a': 1}), isFalse);
    });
  });
}
