import 'package:elab_app/features/offline/offline_support.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elab_app/widgets/web_content_view.dart';

void main() {
  test('offline HTML preserves inline styling and blocks remote resources', () {
    final saved = wrapOfflineHtml(
      '<html><head><style>p { color: red; }</style></head><body><p>Guide</p><script>fetch("https://example.test")</script><img src="data:image/png;base64,AAAA"><img src="https://example.test/image.png"></body></html>',
    );
    expect(saved, contains('p { color: red; }'));
    expect(saved, contains('Content-Security-Policy'));
    expect(saved, contains('data:image/png;base64,AAAA'));
    expect(saved, isNot(contains('https://example.test')));
    expect(saved, isNot(contains('<script')));
  });

  test('support text follows online precedence and skips empty fields', () {
    final activity = {
      'description': {'content': '', 'text': '<p>Why we learn</p>'},
      'instructions': [
        {'content': '<p>Old</p>', 'text': '<p>Play this way</p>'},
      ],
      'autopilots': [],
      'activity_data': {
        'autopilots': [
          {'text': '<p>Step one</p>'},
          '<p>Step two</p>',
        ],
      },
    };
    expect(offlineSupportTexts(activity, 'description'), [
      '<p>Why we learn</p>',
    ]);
    expect(offlineSupportTexts(activity, 'instructions'), [
      '<p>Play this way</p>',
    ]);
    expect(offlineSupportTexts(activity, 'autopilots'), [
      '<p>Step one</p>',
      '<p>Step two</p>',
    ]);
  });
}
