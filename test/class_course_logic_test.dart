import 'package:flutter_test/flutter_test.dart';
import 'package:elab_app/core/network/upload_file.dart';
import 'package:elab_app/features/class_course/class_course_logic.dart';

void main() {
  group('jsNumber / jsNumberString', () {
    test('follows JavaScript Number()', () {
      expect(jsNumber(''), 0);
      expect(jsNumber('  '), 0);
      expect(jsNumber(null), 0);
      expect(jsNumber('5'), 5);
      expect(jsNumber(' 7 '), 7);
      expect(jsNumber('2.5'), 2.5);
      expect(jsNumber('abc'), isNull); // NaN
      expect(jsNumber(3), 3);
    });

    test('stringifies like String(Number(x))', () {
      expect(jsNumberString('5'), '5');
      expect(jsNumberString('5.0'), '5');
      expect(jsNumberString(''), '0');
      expect(jsNumberString('x'), 'NaN');
      expect(jsNumberString(double.nan), 'NaN');
    });
  });

  test('dataOr mirrors res.data || res || []', () {
    expect(dataOr({'data': [1]}, const []), [1]);
    expect(dataOr({'data': []}, const ['fallback']), isEmpty); // [] is truthy
    expect(dataOr([2], const []), [2]);
    expect(dataOr(null, const []), const []);
  });

  test('mapCurriculums lower-cases the status with a draft fallback', () {
    final out = mapCurriculums([
      {'id': 1, 'institute_id': 9, 'name': 'A', 'status': 'Published', 'created_at': 'x'},
      {'id': 2, 'name': 'B', 'status': null},
      {'id': 3, 'name': 'C', 'status': ''},
    ]);
    expect(out.map((c) => c['status']), ['published', 'draft', 'draft']);
    expect(out.first['institute_id'], 9);
  });

  test('normalizeInstructors fills a missing user', () {
    final out = normalizeInstructors([
      {'id': 1, 'user': {'first_name': 'Ann'}},
      {'id': 2, 'user': null},
    ]);
    expect(out[0]['user'], {'first_name': 'Ann'});
    expect(out[1]['user'], containsPair('first_name', ''));
    expect(out[1]['user'], containsPair('email', ''));
  });

  group('mapSearchCourses', () {
    test('unwraps paginated and plain bodies', () {
      final paginated = {
        'data': {
          'data': [
            {'id': 1, 'name': 'Algebra', 'code': 'ALG', 'instructor': {'id': 4}},
            null,
          ],
        },
      };
      final out = mapSearchCourses(paginated);
      expect(out, hasLength(1));
      expect(out.first['title'], 'Algebra');
      expect(out.first['short_name'], 'ALG');
      expect(out.first['course_code'], 'ALG');
      expect(out.first['instructor_id'], 4);
      expect(out.first['status'], 'unknown');

      expect(mapSearchCourses([{'id': 2, 'title': 'T', 'status': 'draft'}]).first['status'], 'draft');
      expect(mapSearchCourses({'data': [{'id': 3}]}).first['title'], 'Untitled course');
      expect(mapSearchCourses({'message': 'none'}), isEmpty);
    });
  });

  test('flattenCourse flattens chapters and contents', () {
    final flat = flattenCourse({
      'sections': [
        {
          'id': 1,
          'chapters': [
            {'id': 10, 'contents': [{'id': 100}, {'id': 101}]},
            {'id': 11},
          ],
        },
        {'id': 2, 'chapters': [{'id': 20, 'contents': [{'id': 200}]}]},
      ],
    });
    expect(flat.sections.map((s) => s['id']), [1, 2]);
    expect(flat.chapters.map((c) => c['id']), [10, 11, 20]);
    expect(flat.contents.map((c) => c['id']), [100, 101, 200]);
    expect(flattenCourse({}).sections, isEmpty);
  });

  group('payloads', () {
    test('create course', () {
      final data = buildCreateCourseData(
        {
          'curriculum_id': '3',
          'instructor_id': 7,
          'allclass': '12',
          'subject_id': '',
          'title': 'T',
          'description': '',
          'short_name': 'S',
          'course_code': 'C',
          'image': null,
          'status': 'draft',
          'is_math_zoro': false,
          'zone': '',
        },
        instituteId: '5',
        classId: '9',
      );
      expect(data['institute_id'], '5');
      expect(data['instructor_id'], '7');
      expect(data['class_id'], '9');
      expect(data['zsl_class_id'], '12');
      expect(data['description'], '');
      expect(data['is_math_zoro'], false);
      expect(data['zone'], '');
    });

    test('update course', () {
      const file = UploadFile(name: 'a.png', path: 'a.png');
      final fields = buildUpdateCourseFields({
        'title': 'T',
        'short_name': null,
        'course_code': 'C',
        'description': '',
        'status': '',
        'curriculum_id': '3',
        'instructor_id': 4,
        'class_id': 12,
        'subject_id': '',
        'isMathPlay': true,
        'zone': 'mathzone',
        'attach': file,
      }, instituteId: '5');
      expect(fields['_method'], 'PUT');
      expect(fields['short_name'], '');
      expect(fields['status'], 'draft');
      expect(fields['instructor_id'], '4');
      expect(fields['zsl_class_id'], '12');
      expect(fields['is_math_zoro'], 'true');
      expect(fields['image'], same(file));
      expect(buildUpdateCourseFields({}, instituteId: '5').containsKey('image'), isFalse);
    });

    test('create content by type', () {
      Map<String, dynamic> build(Map<String, dynamic> form, {String? classId}) => buildCreateContentFields(
            form,
            instituteId: '1',
            courseId: '2',
            sectionId: '3',
            chapterId: '4',
            classId: classId,
          );
      final html = build({'name': 'N', 'type': 'html', 'order': '2', 'zslactvity': '', 'html_content': '<p>x</p>'},
          classId: '8');
      expect(html['html_content'], '<p>x</p>');
      expect(html['order'], '2');
      expect(html['class_id'], '8');
      expect(html.containsKey('url'), isFalse);

      final url = build({'name': 'N', 'type': 'url', 'order': '', 'zslactvity': '', 'url': 'https://x'});
      expect(url['url'], 'https://x');
      expect(url.containsKey('class_id'), isFalse);

      expect(() => build({'name': 'N', 'type': 'pdf', 'order': '', 'zslactvity': ''}), throwsStateError);
    });

    test('update content keeps NaN orders and only sends a picked pdf', () {
      final pdf = buildUpdateContentFields(
        {'name': 'N', 'type': 'pdf', 'order': double.nan, 'file': null, 'url': 'u'},
        instituteId: '1',
        chapterId: '2',
        courseId: '3',
      );
      expect(pdf['order'], 'NaN');
      expect(pdf.containsKey('file'), isFalse);
      expect(pdf.containsKey('url'), isFalse);

      final html = buildUpdateContentFields(
        {'name': 'N', 'type': 'html', 'order': 4, 'html_content': '<b>x</b>'},
        instituteId: '1',
        chapterId: '2',
        courseId: '3',
      );
      expect(html['order'], '4');
      expect(html['html_content'], '<b>x</b>');
    });
  });

  test('instructor labels', () {
    expect(instructorDisplayName(null), '');
    expect(instructorDisplayName({'name': 'Direct', 'user': {'first_name': 'A'}}), 'Direct');
    expect(instructorDisplayName({'user': {'first_name': 'A', 'last_name': 'B'}}), 'A B');
    expect(instructorDisplayName({'user': {'email': 'e@x.io'}}), 'e@x.io');
    expect(instructorDisplayName({}), 'Unnamed Instructor');
    expect(instructorOptionLabel({'user': {'first_name': 'A', 'last_name': null}}), 'A');
  });

  test('defaultZslClassId prefers zsl_class_id, then a name match', () {
    final classes = [
      {'id': 4, 'name': 'Grade 5'},
      {'id': 6, 'name': 'Grade 6 '},
    ];
    expect(defaultZslClassId({'zsl_class_id': 9, 'name': 'Grade 5'}, classes), '9');
    expect(defaultZslClassId({'zsl_class_id': null, 'name': ' grade 6'}, classes), '6');
    expect(defaultZslClassId({'name': 'Other'}, classes), '');
    expect(defaultZslClassId(null, classes), '');
  });

  test('statusLabel', () {
    expect(statusLabel('published'), 'Published');
    expect(statusLabel('draft'), 'UnPublished');
    expect(statusLabel('archived'), 'Archived');
    expect(statusLabel(null), 'Archived');
  });

  group('url preview helpers', () {
    test('detects kinds in template order', () {
      expect(urlPreviewKind('https://x.io/a.PNG'), UrlPreviewKind.image);
      expect(urlPreviewKind('https://x.io/v.mp4'), UrlPreviewKind.video);
      expect(urlPreviewKind('https://www.youtube.com/watch?v=abc123&t=1'), UrlPreviewKind.youTube);
      expect(urlPreviewKind('https://vimeo.com/76979871'), UrlPreviewKind.vimeo);
      expect(urlPreviewKind('https://x.io/doc.pdf'), UrlPreviewKind.pdf);
      expect(urlPreviewKind('https://example.com/page'), UrlPreviewKind.embed);
      expect(urlPreviewKind('https://github.com/x'), UrlPreviewKind.blocked);
      expect(urlPreviewKind(null), UrlPreviewKind.embed);
    });

    test('extracts ids', () {
      expect(getYouTubeId('https://www.youtube.com/watch?v=abc123&t=1'), 'abc123');
      expect(getYouTubeId('https://youtu.be/xyz?t=3'), 'xyz');
      expect(getYouTubeId('https://youtube.com/embed/q'), isNull);
      expect(getVimeoId('https://vimeo.com/76979871'), '76979871');
      expect(pdfViewerUrl('a.pdf'), 'a.pdf#toolbar=0&navpanes=0&scrollbar=0');
    });
  });

  test('previewHtml wraps the fragment in .preview', () {
    final html = previewHtml('<p>x</p>');
    expect(html, contains('<div class="preview"><p>x</p></div>'));
    expect(html, contains('.preview h1'));
    expect(previewHtml(null), contains('<div class="preview"></div>'));
  });
}
