import 'package:dio/dio.dart';
import 'package:elab_app/core/network/api_client.dart';
import 'package:elab_app/features/questions/questions_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('getLocaleName / displayValue / truncate', () {
    test('maps locale values to the enum keys, else echoes the value', () {
      expect(getLocaleName('en'), 'English');
      expect(getLocaleName('te'), 'Telugu');
      expect(getLocaleName('all'), 'All');
      expect(getLocaleName('hi'), 'hi');
      expect(getLocaleName(null), '');
    });

    test('displayValue prints like Vue interpolation', () {
      expect(displayValue(null), '');
      expect(displayValue(2.0), '2');
      expect(displayValue(0.25), '0.25');
      expect(displayValue(3), '3');
      expect(displayValue(true), 'true');
      expect(displayValue({'a': 1}), '{\n  "a": 1\n}');
    });

    test('truncate keeps 60 chars and appends ...', () {
      final long = 'x' * 61;
      expect(truncate(long), '${'x' * 60}...');
      expect(truncate('x' * 60), 'x' * 60);
      expect(truncate(null), isNull);
    });
  });

  group('numbers', () {
    test('jsNumber follows Number()', () {
      expect(jsNumber(null), 0);
      expect(jsNumber(''), 0);
      expect(jsNumber('2.50'), 2.5);
      expect(jsNumber(true), 1);
      expect(jsNumber('abc').isNaN, isTrue);
    });

    test('jsonNumber drops .0 and NaN', () {
      expect(jsonNumber(2.0), 2);
      expect(jsonNumber(2.0), isA<int>());
      expect(jsonNumber(0.25), 0.25);
      expect(jsonNumber(double.nan), isNull);
    });

    test('looseToNumber parses a leading float or keeps the string', () {
      expect(looseToNumber('1'), 1);
      expect(looseToNumber('0.25'), 0.25);
      expect(looseToNumber('3abc'), 3);
      expect(looseToNumber(''), '');
      expect(looseToNumber('-'), '-');
      expect(looseToNumber('1e2'), 100);
    });
  });

  test('jsErrorMessage mirrors e.message', () {
    expect(jsErrorMessage(const ApiError('Institute ID not available')), 'Institute ID not available');
    final opts = RequestOptions(path: '/exam/question/import');
    expect(
      jsErrorMessage(DioException(requestOptions: opts, response: Response(requestOptions: opts, statusCode: 422))),
      'Request failed with status code 422',
    );
    expect(jsErrorMessage(DioException(requestOptions: opts, type: DioExceptionType.connectionError)), 'Network Error');
  });

  test('unwrapQuestions: res?.data ?? res ?? []', () {
    expect(unwrapQuestions({
      'data': [
        {'id': 1},
      ],
    }), [
      {'id': 1},
    ]);
    expect(unwrapQuestions([
      {'id': 2},
    ]), [
      {'id': 2},
    ]);
    expect(unwrapQuestions(null), isEmpty);
    expect(unwrapQuestions({'data': null}), isEmpty);
  });

  group('media urls', () {
    test('getVideoType', () {
      expect(getVideoType(''), (type: '', src: ''));
      expect(getVideoType('https://cdn.x/a.MP4'), (type: 'video', src: 'https://cdn.x/a.MP4'));
      expect(getVideoType('https://youtu.be/abc123?t=1'), (type: 'iframe', src: 'https://www.youtube.com/embed/abc123'));
      expect(getVideoType('https://www.youtube.com/watch?v=dQw4w9WgXcQ&x=1'),
          (type: 'iframe', src: 'https://www.youtube.com/embed/dQw4w9WgXcQ'));
      expect(getVideoType('https://vimeo.com/12345'), (type: 'iframe', src: 'https://player.vimeo.com/video/12345'));
      const id = '1AbCdEfGhIjKlMnOpQrStUvWxYz';
      expect(getVideoType('https://drive.google.com/file/d/$id/view'),
          (type: 'iframe', src: 'https://drive.google.com/file/d/$id/preview'));
      expect(getVideoType('https://example.com/page'), (type: 'link', src: 'https://example.com/page'));
    });

    test('getDirectImage / convertDriveUrl / videoEmbedUrl', () {
      const id = '1AbCdEfGhIjKlMnOpQrStUvWxYz';
      expect(getDirectImage('https://drive.google.com/file/d/$id/view'), 'https://lh3.googleusercontent.com/d/$id');
      expect(getDirectImage('https://x.com/a.png'), 'https://x.com/a.png');
      expect(convertDriveUrl('https://drive.google.com/file/d/$id/view'),
          'https://drive.google.com/uc?export=view&id=$id');
      expect(convertDriveUrl('https://drive.google.com/open?id=$id'),
          'https://drive.google.com/uc?export=view&id=$id');
      expect(convertDriveUrl('https://x.com/a.png'), 'https://x.com/a.png');
      expect(videoEmbedUrl(' https://www.youtube.com/watch?v=abc&t=2 '), 'https://www.youtube.com/embed/abc');
      expect(videoEmbedUrl('https://drive.google.com/file/d/$id/view'), 'https://drive.google.com/file/d/$id/preview');
      expect(videoEmbedUrl('https://cdn.x/v.mp4'), 'https://cdn.x/v.mp4');
      expect(videoEmbedUrl('https://cdn.x/v.MP4'), '');
      expect(videoEmbedUrl('https://vimeo.com/1'), '');
    });
  });

  test('normalizePreview falls back to image_url and sorts options', () {
    final p = normalizePreview({
      'image_url': 'https://x/a.png',
      'video_url': 'https://youtu.be/v1',
      'options': [
        {'id': 2, 'order_index': 2},
        {'id': 1, 'order_index': 1},
      ],
    });
    expect(p.images, [
      {'id': 'single', 'image_url': 'https://x/a.png'},
    ]);
    expect(p.options.map((o) => o['id']), [1, 2]);
    expect(p.videoType, 'iframe');
    expect(p.hasVideo, isTrue);
    expect(normalizePreview({'images': <dynamic>[]}).images, isEmpty);
  });

  group('course / section mapping', () {
    final courses = [
      {'id': 5, 'exam_course_id': 50},
      {'id': 6},
    ];
    final sections = [
      {
        'id': 1,
        'exam_section_id': 10,
        'chapters': [
          {
            'id': 100,
            'contents': [
              {'id': 1000, 'exam_content_id': 9000},
            ],
          },
        ],
      },
      {
        'id': 2,
        'chapters': [
          {
            'id': 200,
            'contents': [
              {'id': 2000, 'exam_content_id': 9100},
            ],
          },
        ],
      },
    ];

    test('examCourseIdFor', () {
      expect(examCourseIdFor(courses, '5'), '50');
      expect(examCourseIdFor(courses, '6'), '6');
      expect(examCourseIdFor(courses, '7'), '');
    });

    test('findExamIdsForContent', () {
      expect(findExamIdsForContent(sections, '1000'), (examSectionId: '10', examChapterId: '9000'));
      // A section without exam_section_id gives String(undefined), like the web.
      expect(findExamIdsForContent(sections, '2000'), (examSectionId: 'null', examChapterId: '9100'));
      expect(findExamIdsForContent(sections, '1'), (examSectionId: '', examChapterId: ''));
    });

    test('examSectionIdForChapter uses exam_section_id ?? id', () {
      expect(examSectionIdForChapter(sections, '100'), '10');
      expect(examSectionIdForChapter(sections, '200'), '2');
      expect(examSectionIdForChapter(sections, '300'), '');
    });

    test('contentsOfChapter', () {
      final contents = [
        {'id': 1, 'chapter_id': 100},
        {'id': 2, 'chapter_id': '200'},
      ];
      expect(contentsOfChapter(contents, ''), isEmpty);
      expect(contentsOfChapter(contents, '200').single['id'], 2);
    });
  });

  test('isCsvOrXlsx', () {
    expect(isCsvOrXlsx('a.CSV'), isTrue);
    expect(isCsvOrXlsx('a.xlsx'), isTrue);
    expect(isCsvOrXlsx('a.xls'), isFalse);
    expect(isCsvOrXlsx('noext'), isFalse);
  });

  test('buildTemplateCsv matches the web output', () {
    final csv = buildTemplateCsv(videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
    final lines = csv.split('\n');
    expect(lines, hasLength(2));
    expect(lines[0].split(',').first, 'code');
    expect(lines[0].split(',').last, 'video_url');
    expect(lines[0].split(','), hasLength(27));
    expect(
      lines[1],
      'Q001,What is the capital of France?,MCQ,MEDIUM,1,0.25,Paris is the capital of France,"geography,capital",'
      'A,London,,false,B,Paris,,true,C,Berlin,,false,D,Madrid,,false,,,https://www.youtube.com/watch?v=dQw4w9WgXcQ',
    );
    expect(buildTemplateCsv(videoUrl: '').endsWith(',,,'), isTrue);
  });

  test('localeFromLanguageName / uploadedFileUrl', () {
    expect(localeFromLanguageName('ENGLISH'), 'en');
    expect(localeFromLanguageName('TELUGU'), 'te');
    expect(localeFromLanguageName('X'), 'x');
    expect(uploadedFileUrl({'data': {'file_url': 'a'}}), 'a');
    expect(uploadedFileUrl({'file_url': 'b'}), 'b');
    expect(uploadedFileUrl({'url': 'c'}), 'c');
    expect(uploadedFileUrl({'data': {'file_url': ''}, 'url': 'd'}), 'd');
    expect(uploadedFileUrl(null), '');
  });
}
