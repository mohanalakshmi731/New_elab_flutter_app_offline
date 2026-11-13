import 'dart:ui';

import 'package:elab_app/features/quiz/quiz_exam_logic.dart';
import 'package:elab_app/features/student_activity/student_activity_logic.dart';
import 'package:elab_app/features/student_science_zone/science_zone_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuizExam logic', () {
    test('isOptionCorrect accepts the web truthy forms only', () {
      for (final o in [
        {'is_correct': true},
        {'is_correct': 'true'},
        {'is_correct': 1},
        {'is_correct': '1'},
        {'isCorrect': true},
        {'correct': true},
      ]) {
        expect(quizOptionIsCorrect(o), isTrue, reason: '$o');
      }
      for (final o in [
        {'is_correct': false},
        {'is_correct': 0},
        {'is_correct': 'yes'},
        {'isCorrect': 1},
        <String, dynamic>{},
      ]) {
        expect(quizOptionIsCorrect(o), isFalse, reason: '$o');
      }
    });

    test('answers enumerate like Object.keys (integer keys first, ascending)', () {
      final answers = <String, dynamic>{'b': 1, '10': 2, '2': 3, 'a': 4, '01': 5};
      expect(jsObjectKeys(answers), ['2', '10', 'b', 'a', '01']);
      expect(jsOrderedAnswers(answers).keys.toList(), ['2', '10', 'b', 'a', '01']);
    });

    test('buildAnswersPayload stringifies ids', () {
      expect(buildQuizAnswersPayload({'12': 5, '3': 'x'}), [
        {'question_id': '3', 'option_id': 'x'},
        {'question_id': '12', 'option_id': '5'},
      ]);
    });

    test('labels, texts and progress', () {
      expect(quizOptionLabel({'display_label': 'iv'}, 0), 'iv');
      expect(quizOptionLabel({}, 0), 'A');
      expect(quizOptionLabel({}, 3), 'D');
      expect(quizOptionText({'text': '', 'option_text': 'B'}), 'B');
      expect(quizQuestionHtml({'stem': '<b>x</b>'}), '<b>x</b>');
      expect(quizOptionRemarks({}), 'No explanation provided.');
      expect(quizStepLabel(3), '03');
      expect(quizStepLabel(12), '12');
      expect(quizKey(7), '7');
      expect(quizKey(7.0), '7');
      expect(quizProgressPercent(1, 4), 25);
      expect(quizProgressPercent(0, 0), 0);
      expect(quizStepFraction(2, 4), 0.5);
    });
  });

  group('studentactivitypage logic', () {
    test('getActivityTitle', () {
      expect(activityTitle({'name': 'Lens'}), 'Lens');
      expect(activityTitle({'title': 'T'}), 'T');
      expect(activityTitle({'order': 2}), 'Activity 2');
      expect(activityTitle({}), 'Activity');
      expect(activityTitle(null), 'Activity');
    });

    test('iframe XP success messages', () {
      expect(isXpSuccessMessage('true'), isTrue);
      expect(isXpSuccessMessage({'message': true}), isTrue);
      expect(isXpSuccessMessage({'message': 'true'}), isTrue);
      expect(isXpSuccessMessage({'is10XpAchieved': 'true'}), isTrue);
      expect(isXpSuccessMessage({'is10XpAchieved': true}), isTrue);
      expect(isXpSuccessMessage({'type': 'vite:update', 'message': 'true'}), isFalse);
      expect(isXpSuccessMessage('false'), isFalse);
      expect(isXpSuccessMessage(null), isFalse);
      expect(isXpSuccessMessage(''), isFalse);
      expect(isXpChannelSuccess(true), isTrue);
      expect(isXpChannelSuccess('true'), isTrue);
      expect(isXpChannelSuccess(1), isFalse);
    });

    test('tab content helpers', () {
      expect(descriptionText({'content': '<p>a</p>', 'text': 'b'}), '<p>a</p>');
      expect(descriptionText({'text': 'b'}), 'b');
      expect(descriptionText(null), '');
      expect(joinItemTexts([
        {'text': 'a'},
        {'content': 'b'},
        {},
      ]), 'a\n\nb\n\n');
      expect(joinItemTexts(null), '');
      expect(signedUrlOf({'signed_url': 's', 'url': 'u'}), 's');
      expect(signedUrlOf({'url': 'u'}), 'u');
      expect(signedUrlOf(null), '');
    });

    test('misc JS semantics', () {
      expect(jsTemplate(true), 'true');
      expect(jsTemplate(3.0), '3');
      expect(jsTemplate({'a': 1}), '[object Object]');
      expect(jsTemplate([1, null, 'x']), '1,,x');
      expect(jsTemplate(null), 'null');
      expect(sameId(5, '5'), isTrue);
      expect(sameId(5.0, '5'), isTrue);
      expect(sameId(null, ''), isFalse);
      expect(dataOrSelfList({
        'data': [1]
      }), [1]);
      expect(dataOrSelfList([2]), [2]);
      expect(dataOrSelfList({'x': 1}), isEmpty);
      expect(dataOrSelfList(null), isEmpty);
      expect(firstTruthy([null, 0, '', 'a', 'b']), 'a');
      expect(firstTruthy([null, 0, '']), '');
    });
  });

  group('studentsciencezone logic', () {
    test('road geometry', () {
      expect(pathMinWidth(0, 800), 800);
      expect(pathMinWidth(1, 800), 800);
      expect(pathMinWidth(5, 800), 1340);
      expect(pathMinWidth(2, 900), 900);

      final pts = buildMilestonePoints(3, 1340);
      expect(pts, const [Offset(110, 300), Offset(670, 120), Offset(1230, 300)]);
      expect(buildMilestonePoints(1, 800), const [Offset(110, 300)]);
      expect(buildMilestonePoints(0, 800), isEmpty);

      final curves = roadCurves(pts);
      expect(curves, hasLength(2));
      expect(curves.first.c1, const Offset(390, 300));
      expect(curves.first.c2, const Offset(390, 120));
      expect(curves.first.end, const Offset(670, 120));
    });

    test('inline SVG icon paths', () {
      // Compact arc flags (`a2 2 0 012-2`) and relative commands.
      final arc = svgPath('M3 5a2 2 0 012-2h5').getBounds();
      expect(arc.left, closeTo(3, 1e-6));
      expect(arc.top, closeTo(3, 1e-6));
      expect(arc.right, closeTo(10, 1e-6));
      expect(arc.bottom, closeTo(5, 1e-6));
      // Numbers run together (`.707.293`).
      final rel = svgPath('M0 0l.707.293').getBounds();
      expect(rel.right, closeTo(0.707, 1e-6));
      expect(rel.bottom, closeTo(0.293, 1e-6));
      expect(svgPath(HeroPaths.x).getBounds(), const Rect.fromLTRB(6, 6, 18, 18));
      expect(svgPath(HeroPaths.play).getBounds(), const Rect.fromLTRB(8, 5, 19, 19));
      // Every template icon stays inside its 24×24 view box.
      for (final d in [
        HeroPaths.table,
        HeroPaths.flag,
        HeroPaths.document,
        HeroPaths.inbox,
        HeroPaths.playCircle,
        HeroPaths.lightBulb,
        HeroPaths.star,
      ]) {
        final b = svgPath(d).getBounds();
        expect(b.left >= 0 && b.top >= 0 && b.right <= 24 && b.bottom <= 24, isTrue, reason: d);
        expect(b.width > 10 && b.height > 10, isTrue, reason: d);
      }
    });

    test('findPhysicsSubject', () {
      expect(findPhysicsSubject([]), isNull);
      expect(
          findPhysicsSubject([
            {'id': 1, 'name': 'Maths'},
            {'id': 2, 'name': 'General Science'},
          ])?['id'],
          2);
      expect(
          findPhysicsSubject([
            {'id': 1, 'name': 'Physics'},
            {'id': 2, 'name': ' chemistrysss '},
          ])?['id'],
          2);
      expect(findPhysicsSubject([
        {'id': 1, 'name': 'Maths'}
      ]), isNull);
      expect(() => findPhysicsSubject([{'id': 1}]), throwsStateError);
    });

    test('stars and colours', () {
      expect(ticketsToStars(null), 0);
      expect(ticketsToStars(0), 0);
      expect(ticketsToStars(-2), 0);
      expect(ticketsToStars(3.7), 3);
      expect(ticketsToStars('2'), 2);
      expect(ticketsToStars(9), 5);
      expect(ticketsToStars('abc'), 0);
      expect(currentStarColor(5), const Color(0xFF4ADE80));
      expect(currentStarColor(1), const Color(0xFFFDE047));
      expect(currentStarColor(0).a, 0);

      expect(flagColor(100, 0, 4).fill, const Color(0xFF4ADE80));
      expect(flagColor(40, 3, 4).fill, const Color(0xFFFACC15));
      expect(flagColor(0, 1, 4).fill, const Color(0xFF94A3B8));
      expect(flagColor(0, 2, 4).fill, const Color(0xFFF43F5E));
      expect(flagColor(0, 2, 5).fill, const Color(0xFF94A3B8));
    });

    test('performance map, preview and rounding', () {
      final map = chapterPerformanceMap({
        'chapters': [
          {
            'chapter_id': '5',
            'percentage': 50,
            'activities': [
              {'activity_id': 9, 'earned_tickets': 3},
            ],
          },
        ],
      });
      expect(map.keys, ['5']);
      final activityMap = map['5']!['activityMap'] as Map;
      expect((activityMap['9'] as Map)['earned_tickets'], 3);
      expect(chapterPerformanceMap(null), isEmpty);

      expect(descriptionPreview({
        'description': {'content': '<p>Hello <b>world</b></p>'}
      }), 'Hello world');
      expect(descriptionPreview({
        'description': {'content': 'x' * 150}
      }).length, 100);
      expect(descriptionPreview({}), '');

      expect(jsRound(49.5), 50);
      expect(jsRound('33.3'), 33);
      expect(jsRound(null), 0);
      expect(jsRound('n/a'), 0);
    });
  });
}
