import 'package:elab_app/features/courses/course_list_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('jsNumber / jsonNumber', () {
    test('behaves like Number()', () {
      expect(jsNumber(''), 0);
      expect(jsNumber('  '), 0);
      expect(jsNumber(null), 0);
      expect(jsNumber(' 12 '), 12);
      expect(jsNumber('12'), isA<int>());
      expect(jsNumber('1.5'), 1.5);
      expect(jsNumber('2.0'), 2);
      expect(jsNumber('abc').isNaN, isTrue);
      expect('${jsNumber('3')}', '3');
      expect('${jsNumber('x')}', 'NaN');
    });

    test('NaN is serialised as null', () {
      expect(jsonNumber(double.nan), isNull);
      expect(jsonNumber(4), 4);
    });
  });

  test('withoutUndefined drops null values', () {
    expect(withoutUndefined({'a': 1, 'b': null, 'c': ''}), {'a': 1, 'c': ''});
  });

  group('searchArray', () {
    test('unwraps the shapes the store accepted', () {
      expect(searchArray([1, 2]), [1, 2]);
      expect(searchArray({'data': [1]}), [1]);
      expect(searchArray({'data': {'data': [3]}}), [3]);
      expect(searchArray({'data': null}), isEmpty);
      expect(searchArray('x'), isEmpty);
      expect(searchArray(null), isEmpty);
    });
  });

  test('filterCoursesByStatus', () {
    final courses = [
      {'id': 1, 'status': 'published'},
      {'id': 2, 'status': 'draft'},
    ];
    expect(filterCoursesByStatus(courses, 'all'), hasLength(2));
    expect(filterCoursesByStatus(courses, 'draft').single['id'], 2);
    expect(filterCoursesByStatus(courses, 'archived'), isEmpty);
  });

  test('status labels and cycle', () {
    expect(statusLabel('published'), 'Published');
    expect(statusLabel('draft'), 'UnPublished');
    expect(statusLabel('draft', draftLabel: 'Draft'), 'Draft');
    expect(statusLabel('unknown'), 'Archived');
    expect(nextCurriculumStatus('published'), 'draft');
    expect(nextCurriculumStatus('draft'), 'archived');
    expect(nextCurriculumStatus('archived'), 'published');
    expect(nextCurriculumStatus('unknown'), 'published');
  });

  group('instructor names', () {
    test('display name falls back to email, then a placeholder', () {
      expect(instructorDisplayName(null), '');
      expect(
        instructorDisplayName({
          'user': {'first_name': 'Ada', 'last_name': 'L'},
        }),
        'Ada L',
      );
      expect(
        instructorDisplayName({
          'user': {'first_name': '', 'last_name': null, 'email': 'a@b.c'},
        }),
        'a@b.c',
      );
      expect(instructorDisplayName({'user': {}}), 'Unnamed Instructor');
    });

    test('initials', () {
      expect(
        instructorInitials({
          'user': {'first_name': 'ada', 'last_name': 'lovelace'},
        }),
        'AL',
      );
      expect(instructorInitials({'user': null}), 'I');
    });

    test('option label', () {
      expect(instructorOptionLabel({'user': {'first_name': 'Ada'}}), 'Ada');
    });
  });

  group('URL helpers', () {
    test('kinds', () {
      expect(urlPreviewKind('https://x.com/a.PNG'), UrlPreviewKind.image);
      expect(urlPreviewKind('https://x.com/a.mp4'), UrlPreviewKind.video);
      expect(urlPreviewKind('https://www.youtube.com/watch?v=abc'), UrlPreviewKind.youtube);
      expect(urlPreviewKind('https://vimeo.com/123'), UrlPreviewKind.vimeo);
      expect(urlPreviewKind('https://x.com/doc.pdf'), UrlPreviewKind.pdf);
      expect(urlPreviewKind('https://example.org'), UrlPreviewKind.embed);
      expect(urlPreviewKind('https://github.com/x'), UrlPreviewKind.blocked);
    });

    test('ids', () {
      expect(youTubeId('https://www.youtube.com/watch?v=abc&t=1'), 'abc');
      expect(youTubeId('https://youtu.be/xyz?t=2'), 'xyz');
      expect(youTubeId('https://youtube.com/shorts/q'), isNull);
      expect(vimeoId('https://vimeo.com/987'), '987');
      expect(vimeoId('https://vimeo.com/channel'), isNull);
    });
  });

  group('preview pickers', () {
    final details = <String, dynamic>{
      'sections': [
        {
          'id': 1,
          'chapters': [
            {
              'id': 10,
              'contents': [
                {'id': 100, 'name': 'c1'},
                {'id': 101, 'name': 'c2'},
              ],
            },
          ],
        },
        {'id': 2, 'chapters': []},
      ],
    };

    test('chapters / contents of the selected ids', () {
      final chapters = previewChaptersOf(details, '1');
      expect(chapters.single['id'], 10);
      expect(previewChaptersOf(details, ''), isEmpty);
      expect(previewChaptersOf(null, '1'), isEmpty);
      expect(previewContentsOf(chapters, '10'), hasLength(2));
      expect(previewContentsOf(chapters, '11'), isEmpty);
    });

    test('first selection', () {
      final sel = firstPreviewSelection(details);
      expect(sel.sectionId, '1');
      expect(sel.chapterId, '10');
      expect(sel.contentId, '100');
      expect(sel.content?['name'], 'c1');

      final noChapters = firstPreviewSelection({
        'sections': [
          {'id': 2, 'chapters': []},
        ],
      });
      expect(noChapters.sectionId, '2');
      expect(noChapters.chapterId, '');
      expect(noChapters.content, isNull);

      final empty = firstPreviewSelection({'sections': []});
      expect(empty.sectionId, '');
      expect(empty.content, isNull);
    });
  });
}
