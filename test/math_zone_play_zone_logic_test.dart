import 'dart:ui' show Color, Offset;

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:elab_app/core/network/api_client.dart';
import 'package:elab_app/features/mathzoro_zone/math_zone_logic.dart';
import 'package:elab_app/features/play_zone/play_zone_logic.dart' as play;

void main() {
  group('Math Zone road geometry', () {
    test('milestones alternate bottom/top rows across the usable width', () {
      final pts = mzMilestonePoints(3, 800);
      expect(pts, const [Offset(110, 300), Offset(400, 120), Offset(690, 300)]);
      expect(mzMilestonePoints(0, 800), isEmpty);
      expect(mzMilestonePoints(1, 800), const [Offset(110, 300)]);
    });

    test('path width grows by 280px per chapter beyond the container', () {
      expect(mzPathMinWidth(1, 500), 500);
      expect(mzPathMinWidth(3, 500), 2 * 280 + 220);
      expect(mzPathMinWidth(3, 1200), 1200);
    });

    test('road segments use the horizontal mid-point as control x', () {
      final segs = mzRoadSegments(const [Offset(0, 300), Offset(100, 120)]);
      expect(segs.single, (const Offset(50, 300), const Offset(50, 120), const Offset(100, 120)));
    });
  });

  group('Math Zone performance', () {
    final perf = {
      'chapters': [
        {
          'chapter_id': '7',
          'earned_tickets': 6,
          'activities': [
            {'activity_id': 1, 'earned_tickets': 5},
            {'activity_id': '2', 'earned_tickets': 1.7},
          ],
        },
      ],
    };

    test('maps chapters and activities by Number(id)', () {
      final map = mzChapterPerformanceMap(perf);
      expect(map.keys, ['7']);
      final acts = map['7']!['activityMap'] as Map<String, Json>;
      expect(acts.keys, ['1', '2']);
    });

    test('chapter pct = round(earned / (activities * 5) * 100)', () {
      final map = mzChapterPerformanceMap(perf);
      expect(mzChapterPct(map['7']), 60);
      expect(mzChapterPct(null), 0);
      expect(mzChapterPct({'activities': [], 'earned_tickets': 3}), 0);
      expect(
        mzChapterPct({
          'activities': [{}],
          'earned_tickets': 'x',
        }).isNaN,
        isTrue,
      );
    });

    test('tickets → stars', () {
      expect(mzTicketsToStars(null), 0);
      expect(mzTicketsToStars(-2), 0);
      expect(mzTicketsToStars(1.7), 1);
      expect(mzTicketsToStars('9'), 5);
      expect(mzTicketsToStars('abc').isNaN, isTrue);
    });

    test('flag colours and badge label', () {
      expect(mzFlagColor(100, 0, 4).fill, const Color(0xFF4ADE80));
      expect(mzFlagColor(20, 0, 4).fill, const Color(0xFFFACC15));
      expect(mzFlagColor(0, 1, 4).fill, const Color(0xFF94A3B8));
      expect(mzFlagColor(0, 2, 4).fill, const Color(0xFFF43F5E));
      expect(mzFlagColor(0, 2, 5).fill, const Color(0xFF94A3B8));
      expect(mzFlagBadgeLabel(0), '?');
      expect(mzFlagBadgeLabel(39.5), '40%');
      expect(mzFlagBadgeLabel(double.nan), '?');
    });

    test('isMath accent switch', () {
      expect(mzIsMath(''), isTrue);
      expect(mzIsMath('Mathematics'), isTrue);
      expect(mzIsMath('Mental Arithmetic'), isTrue);
      expect(mzIsMath('Science'), isFalse);
    });
  });

  group('Math Zone activities', () {
    test('flattens topics with file_path fallback and description preview', () {
      final acts = mzFlattenTopics([
        {
          'id': 3,
          'name': 'Topic',
          'file_path': 't.png',
          'activities': [
            {
              'id': 9,
              'file_path': '',
              'description': {'content': '<p>Hello <b>world</b></p>'},
            },
            {'id': 10, 'file_path': 'a.png'},
          ],
        },
        {'id': 4, 'name': 'Empty', 'activities': null},
      ], 12);
      expect(acts.length, 2);
      expect(acts[0]['file_path'], 't.png');
      expect(acts[0]['topic_id'], 3);
      expect(acts[0]['chapter_id'], 12);
      expect(acts[0]['description_preview'], 'Hello world');
      expect(acts[1]['file_path'], 'a.png');
      expect(acts[1]['description_preview'], '');
      expect(mzFlattenTopics(null, 1), isEmpty);
      expect(() => mzFlattenTopics({'x': 1}, 1), throwsStateError);
    });
  });

  group('class / subject resolution', () {
    final courses = <Json>[
      {'zone': 'MATHPLAY', 'zsl_class_id': 5, 'zsl_subject_id': 21},
      {'zone': 'MathZone', 'zsl_class_id': '5', 'zsl_subject_id': 20},
      {'zone': null, 'zsl_class_id': 5},
    ];

    test('finds the zone course for the class (case-insensitive zone)', () {
      expect(findZoneCourse(courses, 'mathzone', '5')?['zsl_subject_id'], 20);
      expect(findZoneCourse(courses, 'mathplay', '5')?['zsl_subject_id'], 21);
      expect(findZoneCourse(courses, 'mathzone', '6'), isNull);
    });

    test('matches subjects by zsl_subject_id ?? id', () {
      final subjects = [
        {'id': 1, 'zsl_subject_id': 20, 'name': 'Maths'},
        {'id': 21, 'name': 'Play'},
      ];
      expect(findZoneSubject(subjects, 20)?['name'], 'Maths');
      expect(findZoneSubject(subjects, '21')?['name'], 'Play');
      expect(findZoneSubject(subjects, 1), isNull);
      expect(zoneSubjectId({'id': 21}), '21');
    });
  });

  group('Play Zone', () {
    test('inferLevel from the activity name', () {
      expect(play.inferLevel({'name': 'Count (Expert)'}), 'expert');
      expect(play.inferLevel({'name': 'Add (advanced)'}), 'intermediate');
      expect(play.inferLevel({'name': 'Start (BEGINNER)'}), 'beginner');
      expect(play.inferLevel({'name': 'Plain'}), isNull);
      expect(play.inferLevel({}), isNull);
      expect(() => play.inferLevel({'name': null}), throwsStateError);
    });

    test('topic colour hash matches the JS (hash * 31 + c) | 0', () {
      // 'ab' → 97 * 31 + 98 = 3105 → 3105 % 8 = 1
      expect(play.topicColorIndex('ab'), 1);
      expect(play.topicColorIndex(''), 0);
      // Overflows 32 bits and wraps like `| 0`.
      const long = 'Fractions and decimals practice';
      var h = 0;
      for (final c in long.codeUnits) {
        h = (h * 31 + c).toSigned(32);
      }
      expect(play.topicColorIndex(long), h.abs() % 8);
    });

    test('flattens activities with level and unlock state', () {
      final acts = play.playFlattenTopics(
        [
          {
            'id': 1,
            'name': 'T',
            'activities': [
              {'id': 1, 'name': 'A (Expert)', 'required_tickets_to_unlock': 0},
              {'id': 2, 'name': 'B', 'level': 'beginner', 'required_tickets_to_unlock': '0'},
              {'id': 3, 'name': 'C', 'is_unlocked': true, 'required_tickets_to_unlock': 5},
            ],
          },
        ],
        44,
        2,
      );
      expect(acts.map((a) => a['level']), ['expert', 'beginner', null]);
      expect(acts.map((a) => a['is_unlocked']), [true, false, true]);
      expect(acts.first['chapterNumber'], 2);
      expect(acts.first['chapter_id'], 44);
    });

    test('filters by chapter and lock state', () {
      final all = <Json>[
        {'id': 1, 'chapter_id': 4, 'is_unlocked': true},
        {'id': 2, 'chapter_id': 4, 'is_unlocked': false},
        {'id': 3, 'chapter_id': 5, 'is_unlocked': false},
      ];
      List<dynamic> ids(List<Json> l) => l.map((a) => a['id']).toList();
      expect(ids(play.filterPlayActivities(all, chapterId: 'all', level: 'all', lock: 'all')), [
        1,
        2,
        3,
      ]);
      expect(ids(play.filterPlayActivities(all, chapterId: '4', level: 'all', lock: 'locked')), [
        2,
      ]);
      expect(
        ids(play.filterPlayActivities(all, chapterId: 'all', level: 'all', lock: 'unlocked')),
        [1],
      );
    });

    test('parses XP like the web', () {
      expect(play.parseXp({'xp': 12}), 12);
      expect(play.parseXp({'xp': null, 'total_xp': 3}), isNull);
      expect(play.parseXp({'total_xp': 3}), 3);
      expect(
        play.parseXp({
          'data': {'xp': 7},
        }),
        7,
      );
      expect(
        play.parseXp({
          'data': {'total_xp': 8},
        }),
        8,
      );
      expect(play.parseXp({'status': true}), 0);
      expect(play.parseXp(42), 42);
      expect(play.parseXp(null), 0);
      expect(play.parseXp([1]), 0);
    });

    test('unlock error message order: msg, message, error.message', () {
      DioException err(dynamic data, int status) {
        final req = RequestOptions(path: '/zsl/unlock-activity');
        return DioException(
          requestOptions: req,
          response: Response(requestOptions: req, statusCode: status, data: data),
          type: DioExceptionType.badResponse,
        );
      }

      expect(
        play.unlockErrorMessage(err({'msg': 'Not enough tickets', 'message': 'x'}, 400)),
        'Not enough tickets',
      );
      expect(play.unlockErrorMessage(err({'message': 'Nope'}, 422)), 'Nope');
      expect(play.unlockErrorMessage(err('oops', 500)), 'Request failed with status code 500');
      expect(
        play.unlockErrorMessage(const ApiError('Class ID not available')),
        'Class ID not available',
      );
      expect(play.capitalise('beginner'), 'Beginner');
      expect(play.capitalise(''), '');
    });
  });
}
