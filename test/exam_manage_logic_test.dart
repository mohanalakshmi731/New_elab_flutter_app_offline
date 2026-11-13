import 'dart:convert';

import 'package:elab_app/features/exam_manage/exam_manage_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JS coercions', () {
    test('jsNumber / jsNumberField / jsToFixed', () {
      expect(jsNumber(''), 0);
      expect(jsNumber(null), 0);
      expect(jsNumber('2.5'), 2.5);
      expect(jsNumber('abc').isNaN, isTrue);
      expect(jsNumberField({'a': null}, 'a'), 0);
      expect(jsNumberField({}, 'a').isNaN, isTrue);
      expect(jsToFixed(double.nan, 2), 'NaN');
      expect(jsToFixed(0.856 * 100, 0), '86');
      expect(jsToFixed(5, 2), '5.00');
    });

    test('vueChecked mirrors looseEqual(value, true)', () {
      expect(vueChecked(true), isTrue);
      expect(vueChecked(false), isFalse);
      expect(vueChecked(1), isFalse);
      expect(vueChecked('true'), isTrue);
      expect(vueChecked(null), isFalse);
    });

    test('jsField distinguishes undefined and null', () {
      expect(jsField({'a': null}, 'a'), 'null');
      expect(jsField({}, 'a'), 'undefined');
      expect(jsField({'a': 3.0}, 'a'), '3');
    });
  });

  group('dates', () {
    test('toLocaleString of attempts', () {
      final local = DateTime(2025, 1, 15, 10, 30, 5);
      expect(jsLocaleStringField({'t': local.toIso8601String()}, 't'), '1/15/2025, 10:30:05 AM');
      expect(jsLocaleStringField({}, 't'), 'Invalid Date');
      expect(jsLocaleStringField({'t': 'nope'}, 't'), 'Invalid Date');
      // `new Date(null)` is the epoch.
      expect(jsLocaleStringField({'t': null}, 't'), isNot('Invalid Date'));
    });

    test('en-IN medium/short', () {
      final local = DateTime(2025, 1, 15, 22, 5);
      expect(enInMediumShort(local.toIso8601String()), '15 Jan 2025, 10:05 pm');
    });

    test('time input display', () {
      expect(timeInputDisplay(''), '');
      expect(timeInputDisplay('09:05'), '09:05 AM');
      expect(timeInputDisplay('00:30'), '12:30 AM');
      expect(timeInputDisplay('13:45'), '01:45 PM');
      expect(hhmm(DateTime(2025, 1, 1, 7, 3)), '07:03');
    });
  });

  group('createquestion', () {
    const id = 'abcdefghijklmnopqrstuvwxyz12';

    test('convertDriveUrl', () {
      expect(convertDriveUrl(''), '');
      expect(convertDriveUrl('https://x.com/a.png'), 'https://x.com/a.png');
      expect(convertDriveUrl('https://drive.google.com/file/d/$id/view'),
          'https://drive.google.com/uc?export=view&id=$id');
      expect(convertDriveUrl('https://drive.google.com/open?id=$id'),
          'https://drive.google.com/uc?export=view&id=$id');
      expect(convertDriveUrl('https://drive.google.com/short'), 'https://drive.google.com/short');
    });

    test('videoEmbedUrl', () {
      expect(videoEmbedUrl(''), '');
      expect(videoEmbedUrl(' https://www.youtube.com/watch?v=abc123&t=4 '), 'https://www.youtube.com/embed/abc123');
      expect(videoEmbedUrl('https://youtu.be/xyz?si=1'), 'https://www.youtube.com/embed/xyz');
      expect(videoEmbedUrl('https://drive.google.com/file/d/$id/view'),
          'https://drive.google.com/file/d/$id/preview');
      expect(videoEmbedUrl('https://cdn.x/v.mp4'), 'https://cdn.x/v.mp4');
      expect(videoEmbedUrl('https://cdn.x/v.mov'), '');
    });

    test('uploadedFileUrl / parseTags / optionLabel', () {
      expect(uploadedFileUrl({'data': {'file_url': 'a'}}), 'a');
      expect(uploadedFileUrl({'file_url': 'b'}), 'b');
      expect(uploadedFileUrl({'url': 'c'}), 'c');
      expect(uploadedFileUrl({}), isNull);
      expect(parseTags(' a, ,b ,'), ['a', 'b']);
      expect(optionLabel(0), 'A');
      expect(optionLabel(2), 'C');
    });

    final sections = [
      {
        'id': 1,
        'exam_section_id': 'S1',
        'chapters': [
          {
            'id': 10,
            'contents': [
              {'id': 100, 'chapter_id': 10, 'exam_content_id': 'C100', 'name': 'Heart'},
            ],
          },
        ],
      },
      {
        'id': 2,
        'chapters': [
          {
            'id': 20,
            'contents': [
              {'id': 200, 'chapter_id': 20, 'exam_content_id': 'C200'},
            ],
          },
        ],
      },
    ];

    test('association lookups', () {
      expect(examSectionIdFor(sections, '10'), 'S1');
      expect(examSectionIdFor(sections, '20'), '2'); // falls back to section.id
      expect(examSectionIdFor(sections, '99'), '');
      final contents = [
        {'chapter_id': 10, 'exam_content_id': 'C100'},
        {'chapter_id': 20, 'exam_content_id': 'C200'},
      ];
      expect(contentsOfChapter(contents, '20').single['exam_content_id'], 'C200');
      expect(contentsOfChapter(contents, ''), isEmpty);
      final courses = [
        {'id': 5, 'exam_course_id': 'EC5', 'title': 'Bio'},
        {'id': 6, 'title': 'No exam id'},
      ];
      expect(selectedCourseExamId(courses, '5'), 'EC5');
      expect(selectedCourseExamId(courses, '6'), '');
      expect(selectedCourseExamId(courses, ''), '');
    });

    test('buildQuestionPayload + createQuestionBody', () {
      final payload = buildQuestionPayload(
        code: 'Q1',
        stem: 'What?',
        questionType: 'MCQ',
        examSectionId: 'S1',
        difficulty: 'EASY',
        marks: 2,
        negativeMarks: double.nan,
        explanation: '',
        isActive: true,
        selectedContentId: 'C100',
        selectedCourseExamId: 'EC5',
        videoUrl: 'https://drive.google.com/file/d/$id/view',
        options: [
          (label: 'A', text: 'x', correct: true, image: ''),
          (label: 'B', text: 'y', correct: 1, image: 'https://drive.google.com/open?id=$id'),
        ],
        images: [
          (url: '', caption: 'skip', orderIndex: 1),
          (url: 'u1', caption: '', orderIndex: ''),
          (url: 'u2', caption: 'c', orderIndex: 7),
        ],
        tags: ['t1'],
        defaultLocale: 'en',
      );
      expect(payload['title'], 'What?');
      expect(payload['negative_marks'], isNull); // NaN → null in JSON
      expect(payload['video_url'], 'https://drive.google.com/uc?export=view&id=$id');
      final options = payload['options'] as List;
      expect(options[1], {
        'label': 'B',
        'text': 'y',
        'is_correct': 1,
        'order_index': 2,
        'image_url': 'https://drive.google.com/uc?export=view&id=$id',
      });
      expect(payload['images'], [
        {'image_url': 'u1', 'caption': '', 'order_index': 1},
        {'image_url': 'u2', 'caption': 'c', 'order_index': 7},
      ]);
      expect(payload['tags'], ['t1']);
      expect(() => jsonEncode(payload), returnsNormally);

      final body = createQuestionBody('9', payload);
      expect(body['institute_id'], '9');
      expect(body.containsKey('tags'), isFalse); // the store drops tags on create
      expect(body.containsKey('topic_id'), isFalse);
      expect(body['default_locale'], 'en');
    });

    test('non-MCQ omits options', () {
      final payload = buildQuestionPayload(
        code: '',
        stem: '',
        questionType: 'SAQ',
        examSectionId: '',
        difficulty: '',
        marks: '',
        negativeMarks: 0,
        explanation: '',
        isActive: false,
        selectedContentId: '',
        selectedCourseExamId: '',
        videoUrl: '',
        options: const [],
        images: const [],
        tags: const [],
        defaultLocale: 'te',
      );
      expect(payload.containsKey('options'), isFalse);
      expect(payload['marks'], '');
    });

    test('loadQuestionForEdit helpers', () {
      final q = {
        'id': 3,
        'code': 'C',
        'stem': 'S',
        'marks': '2',
        'is_active': 0,
        'difficulty_level': null,
        'tags': [
          {'tag': 'a'},
          {'tag': 'b'},
        ],
        'subject_id': 'S1',
        'topic_id': 'C100',
        'subject': {'course_id': 'EC5'},
      };
      final f = questionFormFrom(q);
      expect(f.marks, 2);
      expect(f.negativeMarks, 0);
      expect(f.isActive, isFalse);
      expect(f.difficulty, '');
      expect(f.questionType, 'MCQ');
      expect(f.tagsInput, 'a, b');
      expect(f.defaultLocale, 'en');

      expect(questionExamCourseKey(q), 'EC5');
      expect(questionExamCourseKey({'course': {'id': 0}}), 'undefined');
      expect(courseByExamKey([{'id': 1, 'exam_course_id': 'EC5'}], 'EC5')?['id'], 1);
      // A course without exam_course_id matches the 'undefined' key, like the web.
      expect(courseByExamKey([{'id': 2}], 'undefined')?['id'], 2);

      expect(locateQuestionTopic(sections, q), (chapterId: '10', contentId: 'C100'));
      // Only the first section with the matching exam_section_id is searched.
      expect(locateQuestionTopic(sections, {'subject_id': 'S1', 'topic_id': 'C200'}), isNull);
    });

    test('sortedByOrderIndex matches V8 (NaN compares as 0, stable)', () {
      final sorted = sortedByOrderIndex([
        {'k': 'c', 'order_index': 3},
        {'k': 'a', 'order_index': '1'},
        {'k': 'x'},
        {'k': 'b', 'order_index': 2},
      ]);
      expect(sorted.map((e) => e['k']).toList(), ['a', 'b', 'c', 'x']);
      expect(sortedByOrderIndex(const []), isEmpty);
      final plain = sortedByOrderIndex([
        {'k': 'b', 'order_index': 2},
        {'k': 'a', 'order_index': 1},
        {'k': 'c', 'order_index': 2},
      ]);
      expect(plain.map((e) => e['k']).toList(), ['a', 'b', 'c']);
    });
  });

  group('EditExams', () {
    final courseSections = [
      {
        'chapters': [
          {
            'exam_chapter_id': 'CH1',
            'name': 'One',
            'contents': [
              {'exam_content_id': 'T1', 'name': 'Topic 1'},
            ],
          },
        ],
      },
      {
        'chapters': [
          {
            'exam_chapter_id': 'CH2',
            'contents': [
              {'exam_content_id': 'T2'},
            ],
          },
        ],
      },
    ];

    test('chapters of the first section / topics of the subject', () {
      expect(firstSectionChapters(courseSections).single['exam_chapter_id'], 'CH1');
      expect(firstSectionChapters(const []), isEmpty);
      expect(topicsOfSubject(courseSections, 'CH2').single['exam_content_id'], 'T2');
      expect(topicsOfSubject(courseSections, ''), isEmpty);
      expect(topicsOfSubject(courseSections, 'nope'), isEmpty);
    });

    test('form / sections from the exam', () {
      final exam = {
        'name': 'Mid',
        'default_negative_marks': '0.5',
        'allow_negative_marking': 1,
        'show_immediate_feedback': 'true',
        'show_results_to_student_at': 'AFTER_EXAM',
        'sections': [
          {
            'name': 'S',
            'question_count': '4',
            'marks_per_question': null,
            'blueprints': [
              {'topic_id': 'T2', 'difficulty_level': 'HARD', 'tag': 'x', 'questions_to_pick': 3},
            ],
          },
          {'name': 'Empty'},
        ],
      };
      final f = editExamFormFrom(exam);
      expect(f['locale'], 'en');
      expect(f['exam_type'], 'EXAM');
      expect(f['negative_marks'], 0.5);
      expect(f['enable_negative_marking'], 1);
      expect(f['show_immediate_feedback'], isTrue);
      expect(f['show_results_to_student_at'], 'afterexam');
      expect(f['description'], '');

      final sections = editSectionsFromExam(exam);
      expect(sections[0]['question_count'], 4);
      expect(sections[0]['marks_per_question'], 0);
      expect(sections[0]['description'], '');
      expect(sections[0]['rules'], [
        {'topic_id': 'T2', 'difficulty': 'HARD', 'question_type': '', 'tags': 'x', 'pick_count': 3},
      ]);
      expect(sections[1]['rules'], isEmpty);
    });

    test('mapExamTopics picks the chapter of the last mapped topic', () {
      final exam = {
        'sections': [
          {
            'blueprints': [
              {'topic_id': 'T1'},
              {'topic_id': ''},
              {'topic_id': 'T2'},
              {'topic_id': 'missing'},
            ],
          },
        ],
      };
      expect(mapExamTopics(exam, courseSections), 'CH2');
      expect(mapExamTopics(exam, const []), isNull);
      expect(mapExamTopics({'sections': null}, courseSections), isNull);
    });

    test('buildUpdateExamPayload', () {
      final payload = buildUpdateExamPayload(
        locale: 'te',
        name: 'N',
        code: 'C',
        description: 'D',
        examType: 'QUIZ',
        durationMinutes: '45',
        maxAttempts: '',
        enableNegativeMarking: true,
        negativeMarks: '0.25',
        randomizeQuestionOrder: false,
        randomizeOptionsOrder: 1,
        showImmediateFeedback: false,
        showResultsToStudentAt: 'afterexam',
        selectedCourseId: 'EC5',
        selectedSubjectId: '',
        selectedBatchId: '',
        isOpenAnytime: false,
        sections: [
          {
            'name': 'S1',
            'description': '',
            'question_count': '5',
            'marks_per_question': 'x',
            'rules': [
              {'topic_id': '', 'difficulty': '', 'question_type': '', 'tags': '', 'pick_count': '0'},
              {'topic_id': 12, 'difficulty': 'HARD', 'question_type': 'SAQ', 'tags': 'a', 'pick_count': '3'},
            ],
          },
        ],
        imageUrl: 'https://img',
        imageCaption: '',
        imageOrder: '0',
      );
      expect(payload['duration_minutes'], 45);
      expect(payload['max_attempts'], 0);
      expect(payload['default_negative_marks'], 0.25);
      expect(payload['show_results_to_student_at'], 'AFTEREXAM');
      expect(payload['course_id'], 'EC5');
      expect(payload['subject_id'], isNull);
      expect(payload['batch_id'], isNull);
      final section = (payload['sections'] as List).single as Map;
      expect(section['question_count'], 5);
      expect(section['marks_per_question'], isNull); // NaN
      expect(section['section_order'], 1);
      expect(section['blueprints'], [
        {'topic_id': '', 'difficulty_level': 'EASY', 'question_type': 'MCQ', 'tag': null, 'questions_to_pick': 1},
        {'topic_id': 12, 'difficulty_level': 'HARD', 'question_type': 'SAQ', 'tag': 'a', 'questions_to_pick': 3},
      ]);
      expect(payload['images'], [
        {'image_url': 'https://img', 'caption': null, 'order_index': 1},
      ]);
      expect(() => jsonEncode(payload), returnsNormally);

      final noImage = buildUpdateExamPayload(
        locale: 'en',
        name: '',
        code: '',
        description: '',
        examType: '',
        durationMinutes: '0',
        maxAttempts: '0',
        enableNegativeMarking: false,
        negativeMarks: '0',
        randomizeQuestionOrder: false,
        randomizeOptionsOrder: false,
        showImmediateFeedback: true,
        showResultsToStudentAt: '',
        selectedCourseId: '',
        selectedSubjectId: 'CH1',
        selectedBatchId: 'B',
        isOpenAnytime: true,
        sections: const [],
        imageUrl: '',
        imageCaption: 'c',
        imageOrder: '2',
      );
      expect(noImage['images'], isEmpty);
      expect(noImage['course_id'], isNull);
      expect(noImage['subject_id'], 'CH1');
      expect(noImage['show_results_to_student_at'], '');
    });
  });

  group('attempts & results', () {
    test('attemptsFromResponse', () {
      expect(attemptsFromResponse([1]), [1]);
      expect(attemptsFromResponse({'data': [2]}), [2]);
      expect(attemptsFromResponse({'response': [3]}), [3]);
      expect(attemptsFromResponse({'data': {'data': [4]}}), [4]);
      expect(attemptsFromResponse(null), isEmpty);
      expect(attemptsFromResponse({'data': {'x': 1}}), isNull);
    });

    test('selectedIncludes', () {
      expect(selectedIncludes([1, 2], 2), isTrue);
      expect(selectedIncludes(['1'], 1), isFalse);
      expect(selectedIncludes('[12,3]', 1), isTrue); // String.prototype.includes
      expect(selectedIncludes(null, 1), isFalse);
    });

    test('scoreAboveZero', () {
      expect(scoreAboveZero('1.00'), isTrue);
      expect(scoreAboveZero(0), isFalse);
      expect(scoreAboveZero(null), isFalse);
      expect(scoreAboveZero('abc'), isFalse);
    });

    test('attemptCounts', () {
      final attempt = {
        'attempt_questions': [
          // correct: full score
          {
            'max_marks': 2,
            'response': {'final_score': '2.00', 'selected_option_ids': [1]},
          },
          // incorrect: answered, below max
          {
            'max_marks': 2,
            'response': {'final_score': 0, 'selected_option_ids': [3]},
          },
          // not answered: no response
          {'max_marks': 1, 'response': null},
          // not answered: empty answer text, max from question.marks
          {
            'question': {'marks': 3},
            'response': {'auto_score': 0, 'answer_text': '   '},
          },
          // answered SAQ, auto score reaches max 1 (fallback)
          {
            'response': {'final_score': null, 'auto_score': 1, 'answer_text': 'ok'},
          },
        ],
      };
      final c = attemptCounts(attempt);
      expect(c.total, 5);
      expect(c.correct, 2);
      expect(c.incorrect, 1);
      expect(c.notAnswered, 2);

      final empty = attemptCounts(const []);
      expect(empty.total, 0);
      expect(empty.notAnswered, 0);
    });
  });
}
