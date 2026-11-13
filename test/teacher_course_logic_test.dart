import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:elab_app/features/courses/course_create_logic.dart';
import 'package:elab_app/features/teacher/teacher_course_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('teacher course page helpers', () {
    test('subjectThemeFor matches keywords in order', () {
      expect(subjectThemeFor('Applied Mathematics').icon, BootstrapIcons.calculator_fill);
      expect(subjectThemeFor('PHYSICS 101').icon, BootstrapIcons.lightning_charge_fill);
      expect(subjectThemeFor('Biochemistry').icon, BootstrapIcons.eyedropper); // 'chem' before 'bio'
      expect(subjectThemeFor('Social studies').icon, BootstrapIcons.hourglass_split);
      expect(subjectThemeFor('Physics (cs)').icon, BootstrapIcons.lightning_charge_fill);
      expect(subjectThemeFor('Basics').icon, BootstrapIcons.laptop_fill); // contains 'cs'
      expect(subjectThemeFor(null).icon, BootstrapIcons.journal_text);
    });

    test('instituteLabel falls back name → year → Class id', () {
      expect(instituteLabel({'id': 3, 'name': 'Grade 3', 'year': 'x'}), 'Grade 3');
      expect(instituteLabel({'id': 3, 'year': '2024'}), '2024');
      expect(instituteLabel({'id': 3, 'year': ''}), 'Class 3');
    });

    test('courseCurriculum prefers curriculums[0].name', () {
      expect(courseCurriculum({
        'curriculums': [
          {'name': 'CBSE'},
        ],
        'curriculum': {'name': 'ICSE'},
      }), 'CBSE');
      expect(courseCurriculum({'curriculums': [], 'curriculum': {'name': 'ICSE'}}), 'ICSE');
      expect(courseCurriculum({}), '');
    });

    test('filterCourses searches title, short name and code case-insensitively', () {
      final courses = [
        {'id': 1, 'title': 'Algebra', 'short_name': 'ALG', 'course_code': 'M1'},
        {'id': 2, 'title': 'Biology', 'short_name': null, 'course_code': 'B2'},
      ];
      expect(filterCourses(courses, searchQuery: '').length, 2);
      expect(filterCourses(courses, searchQuery: 'alg').map((c) => c['id']), [1]);
      expect(filterCourses(courses, searchQuery: 'b2').map((c) => c['id']), [2]);
      expect(filterCourses(courses, searchQuery: 'zzz'), isEmpty);
    });

    test('visibleCourses keeps only published for viewers and copies the maps', () {
      final source = [
        {'id': 1, 'status': 'published'},
        {'id': 2, 'status': 'draft'},
      ];
      final viewer = visibleCourses(source, canManage: false);
      expect(viewer.map((c) => c['id']), [1]);
      final manager = visibleCourses(source, canManage: true);
      expect(manager.length, 2);
      manager.first['tag'] = true;
      expect(source.first.containsKey('tag'), isFalse);
      expect(visibleCourses(null, canManage: true), isEmpty);
    });

    test('instructorDisplayName fallbacks', () {
      expect(instructorDisplayName({'user': {'first_name': 'Ada', 'last_name': 'L'}}), 'Ada L');
      expect(instructorDisplayName({'name': 'N', 'user': {}}), 'N');
      expect(instructorDisplayName({'user': {'email': 'a@b.c'}}), 'a@b.c');
      expect(instructorDisplayName({}), 'Unnamed');
      expect(instructorDisplayName(null), '');
    });

    test('modulesLabel / capitalizeWords', () {
      expect(modulesLabel(1), '1 Module');
      expect(modulesLabel(3), '3 Modules');
      expect(modulesLabel(null), '0 Modules');
      expect(capitalizeWords('published'), 'Published');
      expect(capitalizeWords('in review'), 'In Review');
      expect(capitalizeWords(null), '');
    });

    test('media helpers mirror the web regexes', () {
      expect(isImageUrl('https://x/a.PNG'), isTrue);
      expect(isImageUrl('https://x/a.png?x=1'), isFalse);
      expect(isVideoUrl('https://x/v.mp4'), isTrue);
      expect(isPdfUrl('https://x/doc.pdf'), isTrue);
      expect(isYouTubeUrl('https://youtu.be/abc123'), isTrue);
      expect(youTubeId('https://www.youtube.com/watch?v=abc123&t=2'), 'abc123');
      expect(youTubeId('https://youtu.be/xyz?t=1'), 'xyz');
      expect(youTubeId('https://youtube.com/'), isNull);
      expect(vimeoId('https://vimeo.com/12345'), '12345');
      expect(canEmbedUrl('https://www.google.com/maps'), isFalse);
      expect(canEmbedUrl('https://example.org'), isTrue);
      expect(pdfEmbedUrl('u.pdf'), 'u.pdf#toolbar=0&navpanes=0&scrollbar=0');
    });

    test('JS Number coercion for order inputs', () {
      expect(jsNumberJson(''), 0);
      expect(jsNumberJson('3'), 3);
      expect(jsNumberJson('2.5'), 2.5);
      expect(jsNumberJson('abc'), isNull);
      expect(jsNumberJson(4), 4);
      expect(jsNumberString('7'), '7');
      expect(jsNumberString(''), '0');
      expect(jsNumberString('x'), 'NaN');
      expect(jsNumberString('1.50'), '1.5');
    });
  });

  group('course create helpers', () {
    test('emptyCourseForm / createdCourseForm statuses', () {
      expect(emptyCourseForm()['status'], 'draft');
      expect(createdCourseForm()['status'], 'published');
      expect(emptyCourseForm()['image'], isNull);
    });

    test('buildCreateCourseData maps courseForm like createCourse()', () {
      final data = buildCreateCourseData({
        'curriculum_id': '4',
        'instructor_id': 9,
        'allclass': 12,
        'subject_id': '5',
        'title': 'T',
        'description': '',
        'short_name': 'S',
        'course_code': 'C',
        'image': null,
        'status': 'draft',
        'is_math_zoro': null,
        'zone': '',
      }, instituteId: '7');
      expect(data['institute_id'], '7');
      expect(data['instructor_id'], '9');
      expect(data['zsl_class_id'], 12);
      expect(data['zsl_subject_id'], '5');
      expect(data['description'], '');
      expect(data['is_math_zoro'], false);
      expect(data['zone'], '');
      expect(data['class_id'], isNull);
      expect(buildCreateCourseData({'instructor_id': null}, instituteId: '1')['instructor_id'], '');
    });

    test('isCourseCreated checks the exact API message', () {
      expect(isCourseCreated({'message': 'Course created successfully'}), isTrue);
      expect(isCourseCreated({'message': 'Created'}), isFalse);
      expect(isCourseCreated(null), isFalse);
    });

    test('mapCurriculums lower-cases status with a draft default', () {
      final list = mapCurriculums([
        {'id': 1, 'name': 'A', 'status': 'Published', 'institute_id': 2, 'extra': 'x'},
        {'id': 2, 'name': 'B', 'status': null},
      ]);
      expect(list.first['status'], 'published');
      expect(list.first.containsKey('extra'), isFalse);
      expect(list.last['status'], 'draft');
      expect(publishedCurriculums(list).map((c) => c['id']), [1]);
      expect(mapCurriculums({'data': []}), isEmpty);
    });

    test('mapInstructors fills a missing user and reads pagination', () {
      final res = {
        'data': [
          {'id': 1, 'user': {'first_name': 'A', 'last_name': 'B'}},
          {'id': 2, 'user': null},
        ],
        'current_page': 2,
        'last_page': 3,
        'total': 25,
        'per_page': 10,
      };
      final list = mapInstructors(res);
      expect(list.length, 2);
      expect((list.last['user'] as Map)['first_name'], '');
      expect(instructorOptionLabel(list.first), 'A B');
      expect(instructorOptionLabel(list.last), '');
      final meta = instructorPageMeta(res);
      expect([meta.currentPage, meta.lastPage, meta.total, meta.perPage], [2, 3, 25, 10]);
    });

    test('dataOrSelfList: response.data || response || []', () {
      expect(dataOrSelfList({'data': [{'id': 1}]}).length, 1);
      expect(dataOrSelfList([{'id': 1}, {'id': 2}]).length, 2);
      expect(dataOrSelfList(null), isEmpty);
    });

    test('hasRequiredCourseFields mirrors the onSubmit guard', () {
      final form = {'title': 'T', 'short_name': 'S', 'course_code': 'C', 'instructor_id': '3'};
      expect(hasRequiredCourseFields(form, '1'), isTrue);
      expect(hasRequiredCourseFields(form, null), isFalse);
      expect(hasRequiredCourseFields({...form, 'title': ''}, '1'), isFalse);
      expect(hasRequiredCourseFields({...form, 'instructor_id': ''}, '1'), isFalse);
    });
  });
}
