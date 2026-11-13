import 'package:flutter_test/flutter_test.dart';
import 'package:elab_app/features/exams/exams_logic.dart';
import 'package:elab_app/features/new_exams/new_exams_logic.dart';

void main() {
  group('JS value helpers', () {
    test('jsNum follows Number()', () {
      expect(jsNum(null), 0);
      expect(jsNum(''), 0);
      expect(jsNum(' 7 '), 7);
      expect(jsNum('2.5'), 2.5);
      expect(jsNum('abc').isNaN, isTrue);
      expect(jsNum('12abc').isNaN, isTrue);
      expect(jsNum(true), 1);
    });

    test('jsNumStr / jsStr / display', () {
      expect(jsNumStr(5.0), '5');
      expect(jsNumStr(2.5), '2.5');
      expect(jsNumStr(double.nan), 'NaN');
      expect(jsStr(3), '3');
      expect(jsStr(null), 'null');
      expect(display(null), '');
      expect(display(4.0), '4');
    });

    test('jsonNum / numberOrOne', () {
      expect(jsonNum(12.0), 12);
      expect(jsonNum(12.0), isA<int>());
      expect(jsonNum(double.nan), isNull);
      expect(numberOrOne(''), 1);
      expect(numberOrOne(0), 1);
      expect(numberOrOne('abc'), 1);
      expect(numberOrOne(3), 3);
      expect(numberOrOne('4'), 4);
    });

    test('number inputs', () {
      expect(htmlNumberValue(' 12 '), '12');
      expect(htmlNumberValue('1.2.3'), '');
      expect(htmlNumberValue('-'), '');
      expect(looseToNumber('12'), 12);
      expect(looseToNumber(''), '');
      expect(looseToNumber('1.5'), 1.5);
    });
  });

  group('unwrapExamArray', () {
    test('mirrors res?.data ?? res?.response ?? res, then .data', () {
      expect(unwrapExamArray([1, 2]), [1, 2]);
      expect(unwrapExamArray({'data': [1]}), [1]);
      expect(unwrapExamArray({
        'data': {'data': [2]},
      }), [2]);
      expect(unwrapExamArray({'response': [3]}), [3]);
      expect(unwrapExamArray(null), isEmpty);
      expect(unwrapExamArray({'foo': 1}), isNull);
    });
  });

  group('ExamsList.vue computed', () {
    final exams = <Json>[
      {'id': 1, 'exam_type': 'EXAM', 'status': 'SCHEDULED', 'max_attempts': 2, 'name': 'A'},
      {'id': 2, 'exam_type': 'quiz', 'status': 'scheduled', 'name': 'B'},
      {'id': 3, 'exam_type': 'EXAM', 'status': 'DRAFT', 'name': 'C'},
      {'id': 4, 'exam_type': 'OTHER', 'status': 'SCHEDULED', 'name': 'D'},
    ];

    test('filteredExams hides drafts from institutes only', () {
      expect(listFilteredExams(exams, 'instructor').map((e) => e['id']), [1, 2, 3]);
      expect(listFilteredExams(exams, 'institute').map((e) => e['id']), [1, 2]);
    });

    test('studentAttempts resolves exam ids and merges the listed exam', () {
      final attempts = normalizeStudentAttempts([
        {'id': 10, 'exam': {'id': '1', 'code': 'X'}, 'status': 'submitted', 'attempt_number': 1},
        {'id': 11, 'status': 'in_progress'},
      ], exams);
      expect(attempts, hasLength(1));
      expect(attempts.first['exam_id'], '1');
      expect(attempts.first['status'], 'SUBMITTED');
      expect(attempts.first['exam']['name'], 'A');
      expect(attempts.first['exam']['code'], 'X');
      expect(attempts.first['exam']['id'], '1');
    });

    test('available / in progress / completed / attempts left', () {
      final attempts = normalizeStudentAttempts([
        {'id': 10, 'exam_id': 1, 'status': 'SUBMITTED', 'attempt_number': 1},
        {'id': 11, 'exam_id': 2, 'status': 'IN_PROGRESS', 'attempt_number': 1},
        {'id': 12, 'exam_id': 2, 'status': 'SUBMITTED', 'attempt_number': 1},
      ], exams);
      // Exam 1: 1 of 2 attempts used → available. Exam 2: in progress → not.
      expect(listAvailableExams(exams, attempts).map((e) => e['id']), [1]);
      expect(listInProgressExams(attempts).single['attempt_id'], 11);
      // Exam 2 (max 1) used up → completed; exam 1 (max 2) is not.
      final completed = listCompletedExams(attempts);
      expect(completed.map((e) => e['id']), [2]);
      expect(completed.single['last_attempt_number'], 1);
      expect(listAttemptsLeft(attempts, 1, maxAttemptsOf(exams[0])), 1);
      expect(listAttemptsLeft(attempts, '1', 2), 1);
      expect(listAttemptsLeft(attempts, 9, 3), 3);
    });

    test('localeLabel', () {
      expect(localeLabel('te'), 'Telugu');
      expect(localeLabel('en'), 'English');
      expect(localeLabel(null), '-');
    });
  });

  group('dates', () {
    test('toLocaleString en-IN', () {
      expect(toLocaleStringEnIn('2025-01-15 15:45:07'), '15/1/2025, 3:45:07 pm');
      expect(toLocaleStringEnIn('2025-01-15 00:05:00'), '15/1/2025, 12:05:00 am');
      expect(toLocaleStringEnIn('garbage'), 'Invalid Date');
    });

    test('fmtDate (en-IN with time) / formatDate (en-GB)', () {
      expect(fmtDateTimeEnIn('2025-09-05 15:45:00'), '05 Sept 2025, 03:45 pm');
      expect(fmtDateTimeEnIn(null), '—');
      expect(formatDateEnGb('2025-01-15 10:00:00'), '15 Jan 2025');
      expect(formatDateEnGb(''), '—');
    });

    test('examTimeCell', () {
      expect(examTimeCell({'is_open_anytime': true, 'start_time': 'x'}, 'start_time'), 'Anytime');
      expect(examTimeCell({'is_open_anytime': false}, 'end_time'), '-');
    });
  });

  group('examcreate.vue', () {
    final sections = [
      {
        'exam_section_id': 'S1',
        'chapters': [
          {
            'id': 5,
            'exam_chapter_id': 'C5',
            'contents': [
              {'id': 50, 'exam_content_id': 'T50', 'name': 'Topic'},
            ],
          },
        ],
      },
      {
        'exam_section_id': 'S2',
        'chapters': [
          {'id': 6, 'exam_chapter_id': 6},
        ],
      },
    ];

    test('chapters, topics and the saveExam section lookup', () {
      expect(chaptersOf(sections).map((c) => c['id']), [5, 6]);
      expect(topicsOf(sections, 5).single['topic_id'], 'T50');
      expect(topicsOf(sections, null), isEmpty);
      // Compares exam_chapter_id with the chapter *id* the select stores.
      expect(sectionForChapter(sections, 5), isNull);
      expect(sectionForChapter(sections, 6)?['exam_section_id'], 'S2');
    });

    test('buildCreateExamPayload', () {
      final payload = buildCreateExamPayload(
        selectedCourseId: 'EC1',
        selectedSection: null,
        selectedBatchId: 'B1',
        name: 'Mid term',
        code: 'MT',
        description: '',
        examType: 'EXAM',
        durationMinutes: '30',
        randomizeQuestionOrder: true,
        randomizeOptionOrder: false,
        showImmediateFeedback: false,
        enableNegativeMarking: false,
        negativeMarks: '2',
        locale: 'en',
        imageUrl: 'https://x/y.png',
        imageOrder: '',
        maxAttempts: 0,
        sections: const [
          ExamSectionInput(
            questionCount: 0,
            marksPerQuestion: 2,
            rules: [
              ExamRuleInput(),
              ExamRuleInput(topicId: 'T50', pickCount: 3),
            ],
          ),
        ],
      );
      expect(payload.containsKey('exam_subject_id'), isFalse);
      expect(payload.containsKey('description'), isFalse);
      expect(payload['duration_minutes'], 30);
      expect(payload['default_negative_marks'], 0);
      expect(payload['is_open_anytime'], isTrue);
      expect(payload['max_attempts'], 1);
      expect(payload['images'], [
        {'image_url': 'https://x/y.png', 'caption': '', 'order_index': 1},
      ]);
      final section = (payload['sections'] as List).single as Map;
      expect(section['name'], 'Section 1');
      expect(section['question_count'], 1);
      expect(section['marks_per_question'], 2);
      expect(section.containsKey('description'), isFalse);
      expect(section['blueprints'], [
        {'topic_id': 'T50', 'difficulty_level': 'EASY', 'question_type': 'MCQ', 'questions_to_pick': 3},
      ]);

      final withSection = buildCreateExamPayload(
        selectedCourseId: '',
        selectedSection: const {'exam_section_id': 'S2'},
        selectedBatchId: '',
        name: '',
        code: '',
        description: 'd',
        examType: '',
        durationMinutes: '',
        randomizeQuestionOrder: false,
        randomizeOptionOrder: false,
        showImmediateFeedback: false,
        enableNegativeMarking: true,
        negativeMarks: '0.5',
        locale: 'te',
        imageUrl: '',
        imageOrder: 1,
        maxAttempts: 2,
        sections: const [],
      );
      expect(withSection['exam_subject_id'], 'S2');
      expect(withSection['description'], 'd');
      expect(withSection['duration_minutes'], 0);
      expect(withSection['default_negative_marks'], 0.5);
      expect(withSection['images'], isEmpty);
      expect(withSection['max_attempts'], 2);
    });

    test('uploadedImageUrl', () {
      expect(uploadedImageUrl({'url': 'a'}), 'a');
      expect(uploadedImageUrl({
        'data': {'url': 'b'},
      }), 'b');
      expect(uploadedImageUrl({'file_url': 'c'}), 'c');
      expect(uploadedImageUrl(null), isNull);
    });
  });

  group('newexams.vue computed', () {
    final exams = <Json>[
      {'id': 1, 'exam_type': 'EXAM', 'status': 'SCHEDULED', 'max_attempts': 2},
      {'id': 2, 'exam_type': 'QUIZ', 'status': 'SCHEDULED'},
      {'id': 3, 'exam_type': 'exam', 'status': 'DRAFT'},
      {'id': 4, 'exam_type': 'EXAM', 'status': 'SCHEDULED'},
    ];

    test('filteredExams: exams only, no drafts for institutes', () {
      expect(newFilteredExams(exams, 'admin').map((e) => e['id']), [1, 3, 4]);
      expect(newFilteredExams(exams, 'institute').map((e) => e['id']), [1, 4]);
    });

    test('available / completed / attempts left use strict ids', () {
      final attempts = <Json>[
        {'id': 1, 'exam_id': 1, 'status': 'SUBMITTED', 'attempt_number': 1, 'exam': {'id': 1}},
        {'id': 2, 'exam_id': '4', 'status': 'SUBMITTED', 'attempt_number': 5, 'exam': {'id': 4}},
        {'id': 3, 'exam_id': 4, 'status': 'IN_PROGRESS', 'exam': {'id': 4}},
      ];
      // Exam 4's numeric attempt has no attempt_number → NaN → unavailable.
      expect(newAvailableExams(exams, attempts).map((e) => e['id']), [1]);
      expect(newInProgressExams(attempts).single['attempt_id'], 3);
      expect(newCompletedExams(attempts).map((e) => e['last_attempt_number']), [1, 5]);
      expect(newAttemptsLeft(attempts, 1, 2), 1);
      expect(newAttemptsLeft(attempts, '1', 2), 2);
      expect(hasAttemptsLeft(newAttemptsLeft(attempts, 1, 1)), isFalse);
    });

    test('result counts', () {
      final attempt = <String, dynamic>{
        'attempt_questions': [
          {'max_marks': 1, 'response': {'final_score': 1, 'selected_option_ids': [3]}},
          {'max_marks': 2, 'response': {'final_score': 0, 'selected_option_ids': [4], 'answer_text': ''}},
          {'max_marks': 1, 'response': null},
          // null answer_text counts as answered on the web.
          {'max_marks': 1, 'response': {'final_score': 0, 'selected_option_ids': <int>[]}},
        ],
      };
      expect(resultTotalQuestions(attempt), 4);
      expect(resultCorrect(attempt), 1);
      expect(resultIncorrect(attempt), 2);
      expect(resultNotAnswered(attempt), 2);
      expect(optionSelected(attempt['attempt_questions'][0] as Json, 3), isTrue);
    });

    test('percent and locale helpers', () {
      expect(percentFixed2({'percentage': 45.5}), '45.50');
      expect(percentFixed2({}), 'NaN');
      expect(percentFixed2({'percentage': null}), '0.00');
      expect(percentTimes100({'percentage': 0.456}), '46');
      expect(localeFromLanguageName('ENGLISH'), 'en');
      expect(localeFromLanguageName('TELUGU'), 'te');
      expect(localeFromLanguageName(null), isNull);
    });
  });
}
