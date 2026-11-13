import 'package:flutter_test/flutter_test.dart';

import 'package:elab_app/features/library/library_logic.dart';

void main() {
  group('jsString / sameId', () {
    test('mirrors JS String()', () {
      expect(jsString(null), 'null');
      expect(jsString(12), '12');
      expect(jsString(12.0), '12');
      expect(jsString('7'), '7');
      expect(sameId(5, '5'), isTrue);
      expect(sameId(5, 6), isFalse);
    });

    test('vueText renders null as empty', () {
      expect(vueText(null), '');
      expect(vueText(3), '3');
    });

    test('jsOr / firstTruthyString / vueOr', () {
      expect(jsOr([null, '', 0, 'x']), 'x');
      expect(jsOr([null, '']), '');
      expect(firstTruthyString([null, 0, 42]), '42');
      expect(firstTruthyString([null, '']), '');
      expect(vueOr([null, 'b']), 'b');
      expect(vueOr([null, null]), '');
    });
  });

  test('dataOrSelf = res.data || res || []', () {
    expect(dataOrSelf({'data': [1, 2]}), [1, 2]);
    expect(dataOrSelf([3]), [3]);
    expect(dataOrSelf({'data': []}), isEmpty);
    expect(dataOrSelf({'foo': 1}), isEmpty);
    expect(dataOrSelf(null), isEmpty);
  });

  test('truncateTitle', () {
    expect(truncateTitle('Short', 20), 'Short');
    expect(truncateTitle('ABCDEFGHIJKLMNOPQRSTUV', 20), 'ABCDEFGHIJKLMNOPQRST...');
  });

  test('activityTitle', () {
    expect(activityTitle({'name': 'Lens'}), 'Lens');
    expect(activityTitle({'title': 'T'}), 'T');
    expect(activityTitle({'order': 3}), 'Activity 3');
    // `Activity ${''}`.trim() is 'Activity' (truthy), never 'Untitled Activity'.
    expect(activityTitle({}), 'Activity');
    expect(activityTitle(null), 'Activity');
  });

  group('activitiesForChapter / topicsForChapter', () {
    final data = [
      {
        'id': 10,
        'name': 'Topic A',
        'chapter_id': 1,
        'activities': [
          {'id': 100, 'name': 'A1'},
          {'id': 101, 'name': 'A2'},
        ],
      },
      {'id': 11, 'name': 'Topic B', 'chapter_id': 2, 'activities': null},
      {'id': 12, 'name': 'Topic C', 'chapter_id': '1', 'activities': [{'id': 102}]},
    ];

    test('flattens activities with topic info, strict chapter compare', () {
      final acts = activitiesForChapter(data, 1);
      expect(acts.map((a) => a['id']), [100, 101]);
      expect(acts.first['topic_id'], 10);
      expect(acts.first['topic_name'], 'Topic A');
      expect(acts.first['chapter_id'], 1);
      expect(activitiesForChapter(data, 2), isEmpty);
    });

    test('topics of the selected chapter use a String compare', () {
      expect(topicsForChapter(data, 1).map((t) => t['id']), [10, 12]);
      expect(topicsForChapter(data, 'all-activities'), isEmpty);
      expect(topicsForChapter(data, null), isEmpty);
    });
  });

  test('visibleTabKeys / isInstructorQuizRole', () {
    expect(visibleTabKeys('institute'), isNot(contains('quiz')));
    expect(visibleTabKeys('instructor'), contains('quiz'));
    expect(isInstructorQuizRole('Instructor'), isTrue);
    expect(isInstructorQuizRole('admin'), isTrue);
    expect(isInstructorQuizRole('student'), isFalse);
    expect(isInstructorQuizRole(null), isFalse);
  });

  test('workspaceHasFixedHeight', () {
    expect(workspaceHasFixedHeight('activity', TabContent()), isTrue);
    expect(workspaceHasFixedHeight('reference-video', TabContent()), isTrue);
    expect(workspaceHasFixedHeight('teacher-guide', TabContent('t', '')), isTrue);
    expect(workspaceHasFixedHeight('teacher-guide', TabContent('t', 'u')), isFalse);
    expect(workspaceHasFixedHeight('why-to-learn', TabContent('t', 'u')), isFalse);
    expect(workspaceHasFixedHeight('quiz', TabContent()), isFalse);
  });

  test('pickAutopilot prefers the current language, ignores incomplete items', () {
    final autopilots = [
      {'id': 1, 'content_path': 'a', 'language_id': 1},
      {'id': 2, 'content_path': 'b', 'language_id': 2},
      {'id': 3, 'content_path': null, 'language_id': 3},
    ];
    expect(pickAutopilot(autopilots, 2)?['id'], 2);
    expect(pickAutopilot(autopilots, 3)?['id'], 1);
    expect(pickAutopilot(null, 1), isNull);
  });

  test('joinTexts', () {
    expect(
        joinTexts([
          {'text': 'a'},
          {'content': 'b'},
          {},
        ]),
        'a\n\nb\n\n');
    expect(joinTexts(null), '');
  });

  group('referenceVideosHtml', () {
    test('youtu.be and watch links become embeds', () {
      final html = referenceVideosHtml([
        {'video': 'https://youtu.be/abc123?t=4'},
        {'video': 'https://www.youtube.com/watch?v=xyz789'},
      ]);
      expect(html, contains('https://www.youtube.com/embed/abc123'));
      expect(html, contains('https://www.youtube.com/embed/xyz789'));
      expect('reference-video-item'.allMatches(html).length, 2);
    });

    test('vimeo links and raw iframes', () {
      final html = referenceVideosHtml([
        {'video': 'https://vimeo.com/55555'},
        {'video': '<iframe src="https://x.test"></iframe>'},
      ]);
      expect(html, contains('https://player.vimeo.com/video/55555'));
      expect(html, contains('<iframe src="https://x.test"></iframe>'));
    });

    test('a watch link without v= embeds "null"; relative URLs throw', () {
      expect(referenceVideosHtml([
        {'video': 'https://www.youtube.com/channel/abc'}
      ]), contains('/embed/null'));
      expect(() => referenceVideosHtml([
            {'video': 'youtube.com/watch?v=1'}
          ]), throwsFormatException);
    });
  });
}
