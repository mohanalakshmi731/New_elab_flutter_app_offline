import 'dart:convert';

import 'package:elab_app/features/schedules/schedule_exam_logic.dart';
import 'package:elab_app/features/teacher_dashboard/teacher_dashboard_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JS coercions', () {
    test('jsNumber mirrors Number()', () {
      expect(jsNumber(''), 0);
      expect(jsNumber('  '), 0);
      expect(jsNumber(null), 0);
      expect(jsNumber('12'), 12);
      expect(jsNumber('2.5'), 2.5);
      expect(jsNumber(true), 1);
      expect(jsNumber('abc').isNaN, isTrue);
      expect(jsNumber(7), 7);
    });

    test('vueNumberInput casts like v-model on type=number', () {
      expect(vueNumberInput(''), '');
      expect(vueNumberInput('0'), 0);
      expect(vueNumberInput('1.5'), 1.5);
      expect(vueNumberInput('-'), '-');
    });

    test('jsonNum drops NaN and integral doubles', () {
      expect(jsonNum(double.nan), isNull);
      expect(jsonNum(3.0), 3);
      expect(jsonNum(3.0), isA<int>());
      expect(jsonNum(2.5), 2.5);
    });

    test('jsStr / jsField', () {
      expect(jsStr(12), '12');
      expect(jsStr(12.0), '12');
      expect(jsStr(null), 'null');
      expect(jsField({'a': 1}, 'a'), '1');
      expect(jsField({'a': null}, 'a'), 'null');
      expect(jsField({'a': 1}, 'b'), 'undefined');
      expect(jsField(null, 'b'), 'undefined');
    });

    test('inputText', () {
      expect(inputText(null), '');
      expect(inputText(double.nan), '');
      expect(inputText(5), '5');
      expect(inputText('x'), 'x');
    });
  });

  final courseSections = <Map<String, dynamic>>[
    {
      'id': 1,
      'exam_section_id': 'sec-1',
      'chapters': [
        {
          'id': 10,
          'name': 'Ch 10',
          'contents': [
            {'id': 100, 'name': 'Topic A', 'exam_content_id': 'uuid-a'},
            {'id': 101, 'name': 'Topic B', 'exam_content_id': 'uuid-b'},
          ],
        },
      ],
    },
    {
      'id': 2,
      'exam_section_id': 'sec-2',
      'chapters': [
        {
          'id': 20,
          'name': 'Ch 20',
          'contents': [
            {'id': 200, 'name': 'Topic C', 'exam_content_id': 'uuid-c'},
          ],
        },
      ],
    },
  ];

  group('course tree lookups', () {
    test('chapter dropdown only lists the first section', () {
      expect(firstSectionChapters(courseSections).map((c) => c['id']), [10]);
      expect(firstSectionChapters(const []), isEmpty);
    });

    test('topics of a chapter are searched in every section', () {
      expect(topicsOfChapter(courseSections, '20').map((t) => t['name']), ['Topic C']);
      expect(topicsOfChapter(courseSections, ''), isEmpty);
      expect(topicsOfChapter(courseSections, '99'), isEmpty);
    });

    test('section lookups', () {
      expect(sectionOfChapter(courseSections, '20')?['id'], 2);
      expect(sectionOfChapter(courseSections, 'x'), isNull);
      expect(sectionOfTopic(courseSections, 'uuid-b')?['id'], 1);
      expect(sectionOfTopic(courseSections, 'nope'), isNull);
    });

    test('locateTopic matches content id or exam_content_id', () {
      final byUuid = locateTopic(courseSections, 'uuid-c');
      expect(byUuid?.examContentId, 'uuid-c');
      expect(byUuid?.chapterId, '20');
      final byId = locateTopic(courseSections, 101);
      expect(byId?.examContentId, 'uuid-b');
      expect(byId?.chapterId, '10');
      expect(locateTopic(courseSections, 'missing'), isNull);
    });
  });

  group('edit mode mapping', () {
    final exam = <String, dynamic>{
      'sections': [
        {
          'name': 'S1',
          'description': null,
          'question_count': '5',
          'marks_per_question': null,
          'blueprints': [
            {'topic_id': 'uuid-a', 'difficulty_level': 'HARD', 'question_type': 'MCQ', 'tag': 'x', 'questions_to_pick': 2},
            {'topic_id': 'uuid-c', 'difficulty_level': 'EASY', 'question_type': 'MCQ'},
          ],
          'question_pool': [
            {'question_id': 'q1'},
            {'question_id': null},
            {'question_id': 7},
          ],
        },
      ],
    };

    test('sectionsFromExam', () {
      final s = sectionsFromExam(exam);
      expect(s, hasLength(1));
      expect(s.first['name'], 'S1');
      expect(s.first['description'], '');
      expect(s.first['question_count'], 5);
      expect(s.first['marks_per_question'], 1);
      final rules = s.first['rules'] as List;
      expect(rules.first, {
        'topic_uuid': 'uuid-a',
        'topic_id': '',
        'difficulty': 'HARD',
        'question_type': 'MCQ',
        'tags': 'x',
        'pick_count': 2,
      });
      expect((rules[1] as Map)['tags'], '');
      expect((rules[1] as Map)['pick_count'], 1);
    });

    test('pool ids and first topic', () {
      expect(poolQuestionIdsOf(exam), ['q1', '7']);
      expect(firstTopicUuidOf(exam), 'uuid-a');
      expect(firstTopicUuidOf(const {'sections': []}), isNull);
    });
  });

  group('applyRuleFilter', () {
    final questions = [
      {'id': 'a', 'difficulty_level': 'easy', 'question_type': 'MCQ', 'tags': 'Algebra, linear'},
      {'id': 'b', 'difficulty_level': 'HARD', 'question_type': 'MCQ', 'tags': 'geometry'},
      {'id': 'c', 'difficulty_level': 'EASY', 'question_type': 'SAQ', 'tags': null},
      {'id': 'd', 'difficulty_level': 'EASY', 'question_type': 'MCQ'},
    ];

    List<Map<String, dynamic>> sectionsWith(Map<String, dynamic> rule) => [
          {
            'rules': [rule, newExamRule()],
          },
        ];

    test('filters by the first rule only (case-insensitive)', () {
      final r = filterQuestionsByRule(questions, sectionsWith(newExamRule()));
      expect(r!.map((q) => (q as Map)['id']), ['a', 'd']);
    });

    test('tags match by substring of any comma-separated tag', () {
      final rule = {...newExamRule(), 'tags': ' ALGEBRA , trig'};
      expect(filterQuestionsByRule(questions, sectionsWith(rule))!.map((q) => (q as Map)['id']), ['a']);
    });

    test('empty difficulty/type skip those filters', () {
      final rule = {...newExamRule(), 'difficulty': null, 'question_type': ''};
      expect(filterQuestionsByRule(questions, sectionsWith(rule)), hasLength(4));
    });

    test('no section, no rule or non-array questions leave questions untouched', () {
      expect(filterQuestionsByRule(questions, const []), isNull);
      expect(filterQuestionsByRule(questions, [{'rules': []}]), isNull);
      expect(filterQuestionsByRule({'data': questions}, sectionsWith(newExamRule())), isNull);
    });
  });

  group('buildScheduleExamPayload', () {
    Map<String, dynamic> build({
      bool negative = false,
      Object? maxAttempts = 1,
      List<Map<String, dynamic>>? sections,
    }) =>
        buildScheduleExamPayload(
          locale: 'en',
          activeScheduleId: 42,
          selectedSection: const {'exam_section_id': 'sec-1'},
          durationMinutes: '',
          maxAttempts: maxAttempts,
          enableNegativeMarking: negative,
          negativeMarks: 0.25,
          randomizeQuestionOrder: true,
          randomizeOptionsOrder: false,
          imageUrl: '',
          imageCaption: '',
          sections: sections ??
              [
                {
                  'name': '',
                  'description': '',
                  'question_count': 0,
                  'marks_per_question': '',
                  'rules': [
                    {'topic_id': 'uuid-a', 'difficulty': 'EASY', 'question_type': 'MCQ', 'tags': '', 'pick_count': ''},
                    {'topic_id': '', 'difficulty': 'HARD', 'question_type': 'MCQ', 'tags': 'x', 'pick_count': 3},
                  ],
                },
              ],
          selectedQuestionIds: const ['q1', 'q2'],
        );

    test('matches the web payload', () {
      final p = build();
      expect(p, {
        'locale': 'en',
        'is_open_anytime': true,
        'exam_type': 'QUIZ',
        'schedule_id': '42',
        'exam_subject_id': 'sec-1',
        'duration_minutes': 0,
        'max_attempts': 1,
        'allow_negative_marking': false,
        'randomize_question_order': true,
        'randomize_option_order': false,
        'images': const [],
        'sections': [
          {
            'name': 'Section 1',
            'question_count': 1,
            'marks_per_question': 1,
            'section_order': 1,
            'selected_question_ids': ['q1', 'q2'],
            'blueprints': [
              {
                'topic_id': 'uuid-a',
                'difficulty_level': 'EASY',
                'question_type': 'MCQ',
                'questions_to_pick': 1,
              },
            ],
          },
        ],
      });
      // Encodable as JSON (no NaN / non-JSON values).
      expect(() => jsonEncode(p), returnsNormally);
    });

    test('negative marks only when enabled; max_attempts 0 falls back to 1', () {
      final p = build(negative: true, maxAttempts: 0);
      expect(p['default_negative_marks'], 0.25);
      expect(p['max_attempts'], 1);
    });

    test('description and tags are sent only when set', () {
      final p = build(sections: [
        {
          'name': 'Main',
          'description': 'desc',
          'question_count': 4,
          'marks_per_question': 2,
          'rules': [
            {'topic_id': 'uuid-b', 'difficulty': 'HARD', 'question_type': 'MCQ', 'tags': 'alg', 'pick_count': 2},
          ],
        },
      ]);
      final sec = (p['sections'] as List).first as Map;
      expect(sec['name'], 'Main');
      expect(sec['description'], 'desc');
      expect(sec['question_count'], 4);
      expect(sec['marks_per_question'], 2);
      expect((sec['blueprints'] as List).first, {
        'topic_id': 'uuid-b',
        'difficulty_level': 'HARD',
        'question_type': 'MCQ',
        'questions_to_pick': 2,
        'tags': 'alg',
      });
    });
  });

  group('teacher dashboard', () {
    test('ongoing / today unwrapping keeps items with a start_date', () {
      expect(ongoingFromResponse(null), isEmpty);
      expect(ongoingFromResponse({'id': 1, 'start_date': '2026-01-01'}), hasLength(1));
      expect(ongoingFromResponse({'id': 1}), isEmpty);
      expect(
        ongoingFromResponse([
          {'start_date': 'x'},
          null,
          {'start_date': ''},
        ]),
        hasLength(1),
      );
      expect(todayFromResponse(null), isEmpty);
      expect(
        todayFromResponse({
          'data': [
            {'start_date': 'x'},
          ],
        }),
        hasLength(1),
      );
    });

    test('banner status and captions', () {
      expect(bannerStatusOf(const [1], const [1]), 'ongoing');
      expect(bannerStatusOf(const [], const [1]), 'today');
      expect(bannerStatusOf(const [], const []), 'none');
      expect(todayClassesCaption(0), 'None today');
      expect(todayClassesCaption(1), '1 class scheduled');
      expect(todayClassesCaption(3), '3 classes scheduled');
    });

    test('schedule labels', () {
      final s = {
        'title': '',
        'batch': {
          'name': 'B1',
          'classes': {'name': 'Grade 8'},
        },
      };
      expect(scheduleTitle(s, 'Live Class'), 'Grade 8');
      expect(scheduleTitle(const {}, 'Live Class'), 'Live Class');
      expect(scheduleBatchName(s), 'B1');
      expect(scheduleBatchName(const {}), 'Batch');
      expect(scheduleClassName(s), 'Grade 8');
      expect(scheduleClassName(const {}), isNull);
      expect(todayIso(DateTime(2026, 3, 7)), '2026-03-07');
    });
  });
}
