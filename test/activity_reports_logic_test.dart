import 'dart:async';

import 'package:dio/dio.dart';
import 'package:elab_app/core/network/api_client.dart' show ApiError;
import 'package:elab_app/features/activity_reports/activity_reports_controller.dart';
import 'package:elab_app/features/activity_reports/activity_reports_logic.dart';
import 'package:flutter_test/flutter_test.dart';

ReportSubjectOption _subject(String id, {String zc = '7', String zs = '3', String classId = '1'}) =>
    ReportSubjectOption(id: id, name: 'S$id', classId: classId, zslClassId: zc, zslSubjectId: zs);

DioException _dio(int? status, [Object? data]) {
  final req = RequestOptions(path: '/x');
  return DioException(
    requestOptions: req,
    response: status == null ? null : Response(requestOptions: req, statusCode: status, data: data),
  );
}

/// Fake services: classes 1 (batches 10, 11; course 100 mapped, course 101
/// needing details) and 2.
class _FakeApi implements ActivityReportsApi {
  final calls = <String>[];
  Completer<void>? classesGate;
  Object? quizError;

  @override
  Future<dynamic> getAllClasses(Object instituteId) async {
    calls.add('classes $instituteId');
    if (classesGate != null) await classesGate!.future;
    return {
      'data': [
        {'id': 1, 'name': 'Class 1'},
        {'id': 2, 'class_name': 'Class 2'},
      ],
    };
  }

  @override
  Future<dynamic> getBatches(Object classId, Object instituteId) async {
    calls.add('batches $classId');
    if (classId == 1) {
      return [
        {'id': 10, 'name': 'B10', 'classes_id': 1},
        {'id': 11, 'name': 'B11', 'classes_id': 1},
      ];
    }
    return {'data': <dynamic>[]};
  }

  @override
  Future<dynamic> getClassDetails(Object id, Map<String, dynamic> data) async {
    calls.add('class $id ${data['withCourses']}');
    if (id == '1') {
      return {
        'courses': [
          {'id': 100, 'title': 'Maths', 'zsl_class_id': 7, 'zsl_subject_id': 3},
          {'id': 101, 'title': 'Science'},
        ],
      };
    }
    return {'courses': <dynamic>[]};
  }

  @override
  Future<dynamic> getCourseDetails(Object courseId, Map<String, dynamic> data) async {
    calls.add('course $courseId');
    return {'id': courseId, 'zsl_class_id': 7, 'zsl_subject_id': 4};
  }

  @override
  Future<dynamic> getAllChapters(Object instituteId, Object classId, Object subjectId) async {
    calls.add('chapters $classId/$subjectId');
    return {
      'data': [
        {'id': subjectId == '3' ? 500 : 600, 'name': 'Ch$subjectId'},
      ],
    };
  }

  @override
  Future<dynamic> getQuizPerformance(Map<String, dynamic> payload) async {
    calls.add('quiz ${payload['subject_id']} ${payload['chapter_id']}');
    if (quizError != null) throw quizError!;
    return {
      'activities': [
        {'activity_id': 1, 'activity_name': 'Act 1', 'chapter_id': 500, 'total_questions': 5, 'has_quiz': true},
        {'activity_id': 2, 'activity_name': 'Act 2', 'chapter_id': 500, 'total_questions': 0, 'has_quiz': false},
      ],
      'students': [
        {
          'sub_user_id': 9001,
          'activities': [
            {'activity_id': 1, 'is_attempted': true, 'best_score': 3},
          ],
        },
      ],
    };
  }

  @override
  Future<dynamic> getStudents(Map<String, dynamic> params) async {
    calls.add('students ${params['class_id']} ${params['batch_id']} p${params['page']}');
    if (params['page'] == 1) {
      return {
        'data': [
          {
            'id': 1,
            'zsl_id': 9001,
            'institute_id': 5,
            'user': {'first_name': 'Asha', 'last_name': 'K'},
            'batches': [
              {'id': 10},
            ],
          },
        ],
        'last_page': 2,
        'batchName': null,
      };
    }
    return {
      'data': [
        {'id': 2, 'zsl_id': null, 'user': {'email': 'b@x.io'}, 'batches': <dynamic>[]},
      ],
      'last_page': 2,
      'batchName': null,
    };
  }
}

void main() {
  group('js coercions', () {
    test('Number()', () {
      expect(jsNumberOf('12'), 12);
      expect(jsNumberOf(' 2.5 '), 2.5);
      expect(jsNumberOf(null), 0);
      expect(jsNumberOf(''), 0);
      expect(jsNumberOf(jsUndefined).isNaN, isTrue);
      expect(jsNumberOf('abc').isNaN, isTrue);
      expect(jsNumberOf(true), 1);
      expect(jsNumberOf(const [5]), 5);
    });

    test('String() and {{ }}', () {
      expect(jsStringOf(5.0), '5');
      expect(jsStringOf(null), 'null');
      expect(jsStringOf(jsUndefined), 'undefined');
      expect(jsStringOf(double.nan), 'NaN');
      expect(vueDisplay(null), '');
      expect(vueDisplay(jsUndefined), '');
      expect(vueDisplay(7), '7');
    });

    test('|| and keys', () {
      expect(jsOr(0, 'x'), 'x');
      expect(jsOr('', null), isNull);
      expect(jsOr(const <dynamic>[], 'x'), isEmpty);
      expect(jsNumberKey(1.0), '1');
      expect(jsNumberKey(double.nan), 'NaN');
    });
  });

  group('option lists', () {
    test('classes: id / name fallbacks, no de-duplication', () {
      final classes = mapReportClasses([
        {'id': 1, 'name': 'One'},
        {'id': 0, 'zsl_class_id': 9, 'class_name': 'Nine'},
        {'year': 2024},
        {'id': 1, 'name': 'Dup'},
      ]);
      expect(classes.map((c) => c.id), ['1', '9', 'undefined', '1']);
      expect(classes.map((c) => c.name), ['One', 'Nine', '2024', 'Dup']);
      expect(mapReportClasses([<String, dynamic>{}]).single.name, 'Unnamed Class');
    });

    test('list unwrapping', () {
      expect(listOrDataList([1, 2]), [1, 2]);
      expect(listOrDataList({'data': [3]}), [3]);
      // A paginator object in `data` has no length → treated as empty.
      expect(listOrDataList({'data': {'data': [3]}}), isEmpty);
      expect(listOrDataList(null), isEmpty);
      // flatMap keeps a non-array `data` as a single element.
      final flat = flatMapListOrData([
        [1],
        {'data': [2, 3]},
        {'data': {'x': 1}},
        {'data': null},
      ]);
      expect(flat.length, 4);
      expect(flat.last, {'x': 1});
    });

    test('batches: de-duplicated by id, classId falls back to the selection', () {
      final batches = mapReportBatches([
        {'id': 10, 'name': 'A', 'classes_id': 1},
        {'id': 11},
        {'id': '10', 'name': 'A2', 'classes_id': 1},
      ], 'all');
      expect(batches.map((b) => b.id), ['10', '11']);
      expect(batches.first.name, 'A2');
      expect(batches.last.name, 'Unnamed Batch');
      expect(batches.last.classId, 'all');
    });

    test('subjects: merged course details and ZSL mapping', () {
      final course = {'course_id': 5, 'name': 'Course 5'};
      expect(courseNeedsDetails(course), isTrue);
      expect(courseNeedsDetails({'zsl_class_id': 1, 'zsl_subject_id': 2}), isFalse);
      expect(courseDetailsId(course), 5);
      expect(courseDetailsId(<String, dynamic>{}), 'undefined');
      final merged = mergeCourseDetails(course, {'id': 5, 'title': 'T', 'zsl_class_id': 0}, '1');
      final subjects = mapReportSubjects([
        merged,
        mergeCourseDetails({'id': 6, 'zsl_class_id': 4, 'zsl_subject_id': '8'}, null, '2'),
      ]);
      expect(subjects.first.id, '5');
      expect(subjects.first.name, 'T');
      expect(subjects.first.zslClassId, '');
      expect(subjects.first.hasZslMapping, isFalse);
      expect(subjects.last.classId, '2');
      expect(subjects.last.name, 'Unnamed Course');
      expect(subjects.last.hasZslMapping, isTrue);
    });

    test('chapters', () {
      expect(chapterPayload({'data': [1]}), [1]);
      expect(chapterPayload([2]), [2]);
      expect(chapterPayload({'data': null, 'x': 1}), {'data': null, 'x': 1});
      final chapters = mapReportChapters([
        ...tagChapters([
          {'id': 1, 'name': 'A'},
          {'id': 2},
        ], '100'),
        ...tagChapters([
          {'id': 1, 'name': 'A again'},
        ], '101'),
      ]);
      expect(chapters.map((c) => c.id), ['1', '2']);
      expect(chapters.first.subjectId, '101');
      expect(chapters.last.name, 'Unnamed Chapter');
    });

    test('reconcileSelection', () {
      expect(reconcileSelection('', ['a', 'b']), 'a');
      expect(reconcileSelection('b', ['a', 'b']), 'b');
      expect(reconcileSelection('z', ['a', 'b']), 'a');
      expect(reconcileSelection('all', ['a']), 'all');
      expect(reconcileSelection('all', const []), 'all');
      expect(reconcileSelection('a', const []), '');
      expect(reconcileSelection('all', const [], keepAllWhenEmpty: false), '');
    });
  });

  group('computed', () {
    const batches = [
      ReportBatchOption(id: '10', name: 'B10', classId: '1'),
      ReportBatchOption(id: '20', name: 'B20', classId: '2'),
    ];
    test('filters and names', () {
      expect(filterBatches(batches, 'all').length, 2);
      expect(filterBatches(batches, '2').single.id, '20');
      expect(hasActiveReportFilters('all', 'all', 'all', 'all'), isTrue);
      expect(hasActiveReportFilters('1', '', 'all', 'all'), isFalse);
      String name(String sel) => selectedOptionName(sel, 'All Batches', batches, (b) => b.id, (b) => b.name);
      expect(name('all'), 'All Batches');
      expect(name('20'), 'B20');
      expect(name('99'), '');
      expect(activityCountLabel(1), '1 activity');
      expect(activityCountLabel(0), '0 activities');
    });

    test('displayed students / activities', () {
      final students = [
        ReportStudent(id: 1, name: 'A', zslId: '', batchIds: const ['10']),
        ReportStudent(id: 2, name: 'B', zslId: '', batchIds: const ['11']),
      ];
      expect(displayReportStudents(students, 'all').length, 2);
      expect(displayReportStudents(students, '11').single.id, 2);
      final activities = mapReportActivities([
        {'activity_id': 1, 'chapter_id': 5},
        {'activity_id': 2, 'chapter_id': 6},
      ]);
      expect(displayReportActivities(activities, '6').single.code, 'A2');
      expect(displayReportActivities(activities, 'all').length, 2);
    });

    test('stars', () {
      expect(starCount(3), 3);
      expect(starCount(0), 0);
      expect(starCount(2.5), 3);
      expect(ReportStudent(id: 1, name: 'Émile', zslId: '', batchIds: const []).initial, 'É');
      expect(ReportStudent(id: 1, name: '', zslId: '', batchIds: const []).initial, '');
    });
  });

  group('quizPerformancePayloads', () {
    final subjects = [_subject('100'), _subject('101', zs: '4'), _subject('102', zc: '', zs: '')];
    const chapters = [
      ReportChapterOption(id: '500', name: 'C', subjectId: '100'),
      ReportChapterOption(id: '600', name: 'D', subjectId: '101'),
    ];

    List<Map<String, dynamic>> payloads(String cls, String subject, String chapter, [List<ReportSubjectOption>? s]) =>
        quizPerformancePayloads(
          instituteId: '5',
          selectedClass: cls,
          selectedSubject: subject,
          selectedChapter: chapter,
          subjects: s ?? subjects,
          chapters: chapters,
        );

    test('institute-wide for all / all / all', () {
      expect(payloads('all', 'all', 'all'), [
        {'institute_id': '5'},
      ]);
    });

    test('one subject + chapter', () {
      expect(payloads('1', '100', '500'), [
        {'institute_id': '5', 'classes_id': '7', 'subject_id': '3', 'chapter_id': '500'},
      ]);
    });

    test('a specific chapter narrows "All Subjects" to its subject', () {
      expect(payloads('1', 'all', '600'), [
        {'institute_id': '5', 'classes_id': '7', 'subject_id': '4', 'chapter_id': '600'},
      ]);
    });

    test('duplicates collapse', () {
      final p = payloads('1', 'all', 'all', [_subject('100'), _subject('103')]);
      expect(p, [
        {'institute_id': '5', 'classes_id': '7', 'subject_id': '3'},
      ]);
    });

    test('errors', () {
      expect(() => payloads('1', '100', '999'),
          throwsA(isA<ApiError>().having((e) => e.message, 'message', invalidChapterMessage)));
      expect(() => payloads('1', '102', 'all'),
          throwsA(isA<ApiError>().having((e) => e.message, 'message', invalidSubjectMappingMessage)));
      // Web quirk: "All Subjects" fails when any course lacks a mapping.
      expect(() => payloads('1', 'all', 'all'), throwsA(isA<ApiError>()));
    });
  });

  group('responses', () {
    test('merge: format check, activities de-duplicated by Number(id)', () {
      expect(() => mergeQuizResponses([
            {'activities': <dynamic>[]},
          ]), throwsA(isA<ApiError>().having((e) => e.message, 'm', unexpectedFormatMessage)));
      final merged = mergeQuizResponses([
        {
          'activities': [
            {'activity_id': 1, 'activity_name': 'first'},
            {'activity_id': 2},
          ],
          'students': [1],
        },
        {
          'activities': [
            {'activity_id': '1', 'activity_name': 'last'},
          ],
          'students': [2],
        },
      ]);
      expect(merged.activities.length, 2);
      expect((merged.activities.first as Map)['activity_name'], 'last');
      expect(merged.students, [1, 2]);
    });

    test('activities', () {
      final a = mapReportActivities([
        {'activity_id': '4', 'activity_name': 'X', 'chapter_id': 9, 'total_questions': '5', 'has_quiz': true},
        {'activity_id': 5, 'total_questions': -2, 'has_quiz': 1},
        {'activity_id': 6, 'total_questions': 'abc', 'has_quiz': 'true'},
      ]);
      expect(a.map((x) => x.code), ['A1', 'A2', 'A3']);
      expect(a.first.id, 4);
      expect(a.first.chapterId, '9');
      expect(a.first.marks, 5);
      expect(activityMarksLabel(a.first), '5 marks');
      expect(a[1].marks, 0);
      expect(a[1].hasQuiz, isFalse);
      expect(a[1].name, '');
      expect(a[1].chapterId, 'undefined');
      expect(a[2].hasQuiz, isFalse);
      expect(activityMarksLabel(a[2]), 'No quiz');
    });

    test('student pages', () {
      expect(studentPageRows({'data': [1, 2]}), [1, 2]);
      expect(
          studentPageRows({
            '0': {'id': 1},
            '1': {'x': 2},
            'batchName': null,
          }),
          [
            {'id': 1},
          ]);
      expect(studentLastPage({'last_page': 3}), 3);
      expect(studentLastPage({'last_page': 0}), 1);
      expect(studentLastPage(<String, dynamic>{}), 1);
    });

    test('institute students', () {
      final students = mapInstituteStudents([
        {
          'id': 1,
          'zsl_id': 77,
          'institute_id': 5,
          'user': {'first_name': 'Asha', 'last_name': null},
          'batches': [
            {'id': 10},
          ],
        },
        {'id': 2, 'institute_id': 6},
        {'id': 'x'},
        {
          'id': '1',
          'user': {'email': 'a@x.io'},
          'batches': [
            {'id': 12},
          ],
        },
        {'id': 3, 'institute_id': '5', 'user': <String, dynamic>{}},
      ], '5', '11');
      expect(students.map((s) => s.id), [1, 3]);
      expect(students.first.name, 'a@x.io');
      expect(students.first.zslId, '');
      expect(students.first.batchIds, ['10', '11', '12']);
      expect(students.last.name, 'Unnamed student');
      expect(students.last.batchIds, ['11']);
    });

    test('scores: best attempted score of listed activities', () {
      final activities = mapReportActivities([
        {'activity_id': 1, 'has_quiz': true},
        {'activity_id': 2, 'has_quiz': true},
      ]);
      final students = [
        ReportStudent(id: 1, name: 'A', zslId: '77', batchIds: const []),
        ReportStudent(id: 2, name: 'B', zslId: '', batchIds: const []),
      ];
      applyReportScores(students, [
        {
          'sub_user_id': 77,
          'activities': [
            {'activity_id': 1, 'is_attempted': true, 'best_score': 2},
          ],
        },
        {
          'sub_user_id': '77',
          'activities': [
            {'activity_id': '1', 'is_attempted': true, 'best_score': '4'},
            {'activity_id': 1, 'is_attempted': true, 'best_score': 1},
            {'activity_id': 2, 'is_attempted': 1, 'best_score': 5},
            {'activity_id': 3, 'is_attempted': true, 'best_score': 5},
          ],
        },
        {'sub_user_id': 'x', 'activities': null},
      ], activities);
      expect(reportScore(students.first, activities.first), 4);
      expect(reportScore(students.first, activities.last), isNull);
      expect(students.first.scores.length, 1);
      expect(students.last.scores, isEmpty);

      // `best_score: null` counts as 0; a missing best_score is skipped.
      final s = [ReportStudent(id: 1, name: 'A', zslId: '1', batchIds: const [])];
      applyReportScores(s, [
        {
          'sub_user_id': 1,
          'activities': [
            {'activity_id': 1, 'is_attempted': true, 'best_score': null},
            {'activity_id': 2, 'is_attempted': true},
          ],
        },
      ], activities);
      expect(reportScore(s.single, activities.first), 0);
      expect(reportScore(s.single, activities.last), isNull);
    });
  });

  group('errors', () {
    test('score errors', () {
      expect(
          scoreErrorMessage(_dio(422, {
            'errors': {
              'a': ['one', 'two'],
              'b': ['three'],
            },
            'message': 'ignored',
          })),
          'one two three');
      expect(scoreErrorMessage(_dio(500, {'message': 'Boom'})), 'Boom');
      expect(scoreErrorMessage(_dio(500, {'msg': 'Oops'})), 'Oops');
      expect(scoreErrorMessage(_dio(404, '<html>')), 'Request failed with status code 404');
      expect(scoreErrorMessage(_dio(null)), 'Network Error');
      expect(scoreErrorMessage(const ApiError(invalidChapterMessage)), invalidChapterMessage);
      expect(scoreErrorMessage(StateError('x')), 'Unable to load activity reports.');
    });

    test('filter errors', () {
      expect(filterErrorMessage(_dio(500, {'message': 'Boom'})), 'Request failed with status code 500');
      expect(filterErrorMessage(const ApiError(missingMappingMessage)), missingMappingMessage);
      expect(filterErrorMessage(StateError('x')), 'Unable to load report filters.');
    });
  });

  group('controller flow', () {
    test('refresh picks the first class/batch/subject/chapter and loads scores', () async {
      final api = _FakeApi();
      final c = ActivityReportsController(api: api, instituteId: () => '5');
      await c.refreshData();

      expect(c.errorMessage, '');
      expect(c.isLoading, isFalse);
      expect(c.isRefreshing, isFalse);
      expect(c.updatingFilters, isFalse);
      expect(c.classes.map((x) => x.name), ['Class 1', 'Class 2']);
      expect(c.selectedClass, '1');
      expect(c.selectedBatch, '10');
      expect(c.subjects.map((s) => s.id), ['100', '101']);
      expect(c.subjects.last.zslSubjectId, '4');
      expect(c.selectedSubject, '100');
      expect(c.selectedChapter, '500');
      expect(c.hasActiveFilters, isTrue);
      expect(c.selectedChapterName, 'Ch3');
      expect(c.displayedActivities.map((a) => a.code), ['A1', 'A2']);
      // Both pages are loaded; the selected batch is added to every row's
      // batch ids, so the page-2 student (no batches) is listed too.
      expect(c.students.length, 2);
      expect(c.displayedStudents.map((s) => s.name), ['Asha K', 'b@x.io']);
      expect(reportScore(c.displayedStudents.first, c.displayedActivities.first), 3);
      expect(reportScore(c.displayedStudents.last, c.displayedActivities.first), isNull);
      expect(api.calls, contains('course 101'));
      expect(api.calls, contains('students 1 10 p2'));
      expect(api.calls, contains('quiz 3 500'));
      c.dispose();
    });

    test('changing the class reloads batches/subjects/chapters', () async {
      final api = _FakeApi();
      final c = ActivityReportsController(api: api, instituteId: () => '5');
      await c.refreshData();
      api.calls.clear();
      c.selectClass('2');
      await pumpEventQueue();
      expect(c.selectedBatch, '');
      expect(c.selectedSubject, '');
      expect(c.selectedChapter, '');
      expect(c.hasActiveFilters, isFalse);
      expect(c.isLoading, isFalse);
      expect(api.calls, ['batches 2', 'class 2 yes']);
      c.dispose();
    });

    test('batch change refetches scores only; score errors are shown', () async {
      final api = _FakeApi();
      final c = ActivityReportsController(api: api, instituteId: () => '5');
      await c.refreshData();
      api.calls.clear();
      api.quizError = _dio(422, {
        'errors': {
          'chapter_id': ['Bad chapter'],
        },
      });
      c.selectBatch('all');
      await pumpEventQueue();
      expect(c.errorMessage, 'Bad chapter');
      expect(c.isLoading, isFalse);
      expect(c.activities, isEmpty);
      expect(api.calls.where((x) => x.startsWith('class')), isEmpty);
      c.dispose();
    });

    test('no institute → error', () async {
      final c = ActivityReportsController(api: _FakeApi(), instituteId: () => '');
      await c.refreshData();
      expect(c.errorMessage, instituteRequiredMessage);
      expect(c.isLoading, isFalse);
      c.dispose();
    });

    test('clearFilters drops an in-flight refresh', () async {
      final api = _FakeApi()..classesGate = Completer<void>();
      final c = ActivityReportsController(api: api, instituteId: () => '5');
      final refresh = c.refreshData();
      expect(c.isLoading, isTrue);
      c.clearFilters();
      expect(c.isLoading, isFalse);
      api.classesGate!.complete();
      await refresh;
      expect(c.classes, isEmpty);
      expect(c.selectedClass, '');
      expect(c.isRefreshing, isFalse);
      expect(api.calls, ['classes 5']);
      c.dispose();
    });

    test('reportInstituteId', () {
      expect(reportInstituteId(null), '');
      expect(reportInstituteId(0), '');
      expect(reportInstituteId(12), '12');
    });
  });
}
