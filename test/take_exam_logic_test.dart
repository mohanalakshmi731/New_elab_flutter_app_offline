import 'dart:typed_data';

import 'package:elab_app/features/take_exam/exam_security_logic.dart';
import 'package:elab_app/features/take_exam/proctor_logic.dart';
import 'package:elab_app/features/take_exam/proctor_service.dart';
import 'package:elab_app/features/take_exam/start_exam_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('startexam.vue helpers', () {
    final attempt = {
      'id': 77,
      'exam': {'name': 'Physics', 'duration_minutes': '1.5'},
      'attempt_questions': [
        {
          'id': 1,
          'question': {
            'id': 10,
            'question_type': 'MCQ',
            'stem': '<p>2+2?</p>',
            'options': [
              {'id': 101, 'display_label': 'A', 'option_text': '3'},
              {'id': 102, 'display_label': 'B', 'option_text': '4'},
            ],
            'images': [],
            'image_url': 'https://drive.google.com/file/d/1AbCdEfGhIjKlMnOpQrStUvWxYz012345/view',
          },
        },
        {
          'id': 2,
          'question': {'id': 20, 'question_type': 'SAQ', 'stem': 'Explain'},
        },
        {
          'id': 3,
          'question': {
            'id': 30,
            'question_type': 'MEQ',
            'images': [
              {'id': 5, 'image_url': 'x.png'},
            ],
          },
        },
        {
          'id': 4,
          'question': {'id': 40, 'question_type': 'TF'},
        },
      ],
    };

    test('mapAttemptQuestions mirrors mounted()', () {
      final qs = mapAttemptQuestions(attempt);
      expect(qs.map((q) => q.id), [1, 2, 3, 4]);
      expect(qs.map((q) => q.questionId), [10, 20, 30, 40]);
      expect(qs[0].images.single['id'], 'single-img');
      expect(qs[1].images, isEmpty);
      expect(qs[1].options, isEmpty);
      expect(qs[2].images.single['id'], 5);
      expect(mapAttemptQuestions(null), isEmpty);
    });

    test('duration, timer and format', () {
      expect(examDurationSeconds(attempt['exam']), 90);
      expect(examDurationSeconds({'duration_minutes': null}), 0);
      expect(examDurationSeconds({'duration_minutes': -3}), 0);
      expect(examDurationSeconds({'duration_minutes': 'abc'}), 0);
      expect(remainingSeconds(10000, 4100), 5);
      expect(remainingSeconds(10000, 12000), 0);
      expect(formatExamTime(59), '00:59');
      expect(formatExamTime(3599), '59:59');
      expect(formatExamTime(3661), '01:01:01');
      expect(isTimeWarning(300), isFalse);
      expect(isTimeWarning(299), isTrue);
      expect(isTimeWarning(60), isFalse);
      expect(isTimeCritical(60), isTrue);
      expect(isTimeCritical(0), isTrue);
    });

    test('isAnswered / answeredCount', () {
      final qs = mapAttemptQuestions(attempt);
      expect(isQuestionAnswered(qs[0], null), isFalse);
      expect(isQuestionAnswered(qs[0], 101), isTrue);
      expect(isQuestionAnswered(qs[1], '   '), isFalse);
      expect(isQuestionAnswered(qs[1], ' x '), isTrue);
      expect(isQuestionAnswered(qs[3], 'yes'), isFalse);
      expect(answeredCount(qs, {1: 102, 2: 'a', 3: ''}), 2);
    });

    test('getDirectImage', () {
      expect(getDirectImage(''), '');
      expect(getDirectImage('https://x.com/a.png'), 'https://x.com/a.png');
      expect(
        getDirectImage('https://drive.google.com/file/d/1AbCdEfGhIjKlMnOpQrStUvWxYz012345/view'),
        'https://lh3.googleusercontent.com/d/1AbCdEfGhIjKlMnOpQrStUvWxYz012345',
      );
    });

    test('return path', () {
      expect(resolveExamReturnPath(null), '/exams');
      expect(resolveExamReturnPath(''), '/exams');
      expect(resolveExamReturnPath('https://evil.com'), '/exams');
      expect(resolveExamReturnPath('/startexam?x=1'), '/exams');
      expect(resolveExamReturnPath('/ExamsList?page=2'), '/ExamsList?page=2');
      expect(resolveExamReturnPath('/myclasses'), '/myclasses?tab=Exams');
      expect(resolveExamReturnPath('/myclasses?id=4&tab=Live#top'), '/myclasses?id=4&tab=Exams#top');
    });

    test('buildAnswerSubmissions skips empty answers, stringifies question ids', () {
      final qs = mapAttemptQuestions(attempt);
      final out = buildAnswerSubmissions(77, qs, {1: 102, 2: '  ', 3: 'essay', 4: 'x'});
      expect(out, [
        {
          'exam_attempt_id': 77,
          'question_id': '10',
          'selected_option_ids': [102],
        },
        {'exam_attempt_id': 77, 'question_id': '30', 'answer_text': 'essay'},
      ]);
    });
  });

  group('exam lock-down rules', () {
    ExamKeyDecision key(String k, {bool alt = false, bool meta = false, bool ctrl = false, bool shift = false}) =>
        examKeyDecision(key: k, alt: alt, meta: meta, ctrl: ctrl, shift: shift);

    test('blockKeys', () {
      expect(key('F12').action, ExamKeyAction.block);
      expect(key('F5', alt: true).action, ExamKeyAction.block);
      expect(key('Alt', alt: true).action, ExamKeyAction.blockAndFlag);
      expect(key('Tab', alt: true).violation?.type, 'SYSTEM_SHORTCUT_ATTEMPT');
      expect(key('c', meta: true).action, ExamKeyAction.blockAndFlag);
      expect(key('i', ctrl: true, shift: true).action, ExamKeyAction.block);
      expect(key('a', ctrl: true).action, ExamKeyAction.block);
      expect(key('c', ctrl: true).action, ExamKeyAction.allow);
      expect(key('v', ctrl: true).action, ExamKeyAction.allow);
      expect(key('PrintScreen').violation,
          const ExamViolation('SCREENSHOT_ATTEMPT', 'Screenshot activity was detected.'));
      expect(key('x').action, ExamKeyAction.allow);
      expect(key('Escape').action, ExamKeyAction.allow);
    });

    test('heartbeat order', () {
      expect(
        heartbeatViolation(fullscreen: false, hidden: true, focused: false, width: 100, height: 100)?.type,
        'FULLSCREEN_EXITED',
      );
      expect(
        heartbeatViolation(fullscreen: true, hidden: false, focused: false, width: 100, height: 100)?.type,
        'BACKGROUND_ACTIVITY',
      );
      expect(
        heartbeatViolation(fullscreen: true, hidden: false, focused: true, width: 899, height: 800)?.type,
        'WINDOW_TOO_SMALL',
      );
      expect(
        heartbeatViolation(fullscreen: true, hidden: false, focused: true, width: 900, height: 560),
        isNull,
      );
      expect(defaultViolation(fullscreen: true).type, 'WINDOW_FOCUS_LOST');
      expect(defaultViolation(fullscreen: false).type, 'FULLSCREEN_EXITED');
    });

    test('warning ledger: throttle, limit, immediate close', () {
      final l = ExamWarningLedger();
      expect(l.register(immediateClose: false, nowMs: 10000), ExamWarningOutcome.counted);
      expect(l.register(immediateClose: false, nowMs: 11699), ExamWarningOutcome.throttled);
      expect(l.count, 1);
      expect(l.register(immediateClose: false, nowMs: 11700), ExamWarningOutcome.counted);
      expect(l.register(immediateClose: false, nowMs: 20000), ExamWarningOutcome.limitReached);
      expect(l.count, 3);
      expect(l.register(immediateClose: false, nowMs: 30000), ExamWarningOutcome.limitReached);
      expect(l.count, 3);

      final m = ExamWarningLedger();
      expect(m.register(immediateClose: true, nowMs: 5), ExamWarningOutcome.immediateClose);
      expect(m.count, 3);
      expect(m.lastAt, 5);
    });
  });

  group('proctor reference checks', () {
    FrameStats frame(List<int> sums) => FrameStats(width: 64, height: 48, sums: sums);

    test('validateCapturedPixels', () {
      expect(() => validateCapturedPixels(null), throwsA(isA<ProctorError>()));
      expect(
        () => validateCapturedPixels(frame(List.filled(48, 30))),
        throwsA(predicate((e) => '$e'.startsWith('Camera looks covered'))),
      );
      expect(
        () => validateCapturedPixels(frame(List.filled(48, 300))),
        throwsA(predicate((e) => '$e'.startsWith('Camera photo is not clear'))),
      );
      final varied = [for (var i = 0; i < 48; i++) i.isEven ? 150 : 450];
      expect(() => validateCapturedPixels(frame(varied)), returnsNormally);
    });

    Map<String, dynamic> face([double c = 0.9]) => {
          'confidence': c,
          'bbox': [10, 10, 50, 50],
        };

    test('validateReferenceAnalysis', () {
      String err(Map<String, dynamic> d) {
        try {
          validateReferenceAnalysis(d);
          return 'ok';
        } on ProctorError catch (e) {
          return e.message;
        }
      }

      expect(err({'ok': true, 'faceCount': 1, 'faces': [face()]}), 'ok');
      expect(err({'ok': false, 'faces': [face()]}),
          'Reference photo is not valid. Please capture a clear face photo.');
      expect(
        err({
          'ok': false,
          'events': [
            {'type': 'REFERENCE_LOW_LIGHT_X', 'message': 'Too dark'},
          ],
        }),
        'Too dark',
      );
      expect(
        err({
          'ok': true,
          'faces': [face()],
          'events': [
            {'type': 'FACE_NOT_CONFIRMED'},
          ],
        }),
        'Reference photo is not valid. Please capture a clear face photo.',
      );
      expect(err({'ok': true, 'faces': []}), startsWith('No face found'));
      expect(err({'ok': true, 'faceCount': 2}), startsWith('Multiple faces'));
      expect(err({'ok': true, 'faces': [face()], 'personCount': 2}), startsWith('Multiple persons'));
      expect(err({'ok': true, 'faces': [face(0.5)]}), startsWith('Face is not clear'));
      expect(
        err({
          'ok': true,
          'faces': [face()],
          'gadgets': [{}],
        }),
        startsWith('Remove electronic gadgets'),
      );
    });
  });

  group('proctor warnings', () {
    test('visual payload priority', () {
      expect(visualWarningPayload({'gadgets': [{}]}, const [])?.type, 'ELECTRONIC_GADGET_DETECTED');
      expect(visualWarningPayload({}, const [{}])?.source, 'local');
      final p = visualWarningPayload({
        'events': [
          {'type': 'FACE_TURNED_LEFT', 'message': 'turned'},
          {'type': 'MULTIPLE_FACES', 'message': 'Two faces'},
        ],
        'identityDistance': 0.9,
      }, const []);
      expect(p?.type, 'MULTIPLE_FACES');
      expect(p?.message, 'Two faces');
      final id = visualWarningPayload({'identityDistance': 0.42}, const []);
      expect(id?.type, 'IDENTITY_MISMATCH');
      expect(visualWarningPayload({'identityDistance': 0.41}, const []), isNull);
      final close = visualWarningPayload({'shouldClose': true}, const []);
      expect(close?.type, 'PROCTOR_WARNING');
      expect(close?.message, 'Proctor AI detected a warning.');
      expect(visualWarningPayload({'shouldClose': true, 'closeType': 'X', 'closeReason': 'Y'}, const [])?.message, 'Y');
    });

    test('audio payload rules', () {
      Map<String, dynamic> data(List<Map<String, dynamic>> events, {Object? mouth = 0.1, String ctx = 'active'}) => {
            'events': events,
            'audio': {'visualContext': ctx, 'studentMouthActivity': mouth},
          };
      expect(audioWarningPayload(data([]))?.type, isNull);
      expect(
        audioWarningPayload(data([
          {'type': 'LOUD_BACKGROUND_AUDIO', 'message': 'Loud'},
        ]))?.message,
        'Loud',
      );
      expect(
          audioWarningPayload(data([
            {'type': 'LOUD_BACKGROUND_AUDIO'},
          ], ctx: 'stale')),
          isNull);
      expect(
          audioWarningPayload(data([
            {'type': 'LOUD_BACKGROUND_AUDIO'},
          ], mouth: null)),
          isNull);
      final activity = {
        'type': 'AUDIO_ACTIVITY_DETECTED',
        'metadata': {'studentMouthActivity': 0.05, 'activeMs': 800},
      };
      expect(isSuspiciousAudioActivityEvent(activity), isTrue);
      expect(
          isSuspiciousAudioActivityEvent({
            'type': 'AUDIO_ACTIVITY_DETECTED',
            'metadata': {'studentMouthActivity': 0.2, 'activeMs': 900},
          }),
          isFalse);
      expect(audioWarningPayload(data([activity]))?.message, 'Suspicious background audio detected.');
    });

    test('warning gate', () {
      final g = ProctorWarningGate();
      expect(g.allowVisual('A', 10000), isTrue);
      expect(g.allowVisual('A', 11799), isFalse);
      expect(g.allowVisual('B', 11799), isTrue);
      expect(g.allowAudio('C', 12000), isTrue);
      expect(g.allowAudio('D', 19999), isFalse);
      expect(g.allowAudio('C', 20000), isTrue);
    });
  });

  group('audio features', () {
    test('frequency shape and zero crossings', () {
      final freq = Uint8List(1024)..[0] = 255;
      freq[10] = 255; // 10 * 48000 / 2048 ≈ 234 Hz → low
      freq[50] = 255; // ≈ 1172 Hz → speech
      final shape = calculateFrequencyShape(freq, 48000, 2048);
      expect(shape.lowFrequencyRatio, closeTo(1 / 3, 1e-9));
      expect(shape.speechRatio, closeTo(1 / 3, 1e-9));
      expect(shape.dominantFrequency, closeTo(10 * 48000 / 2048, 1e-9));
      expect(calculateFrequencyShape(Uint8List(8), 48000, 16).dominantFrequency, isNull);

      expect(calculateZeroCrossingRate(Uint8List.fromList([100, 200, 100, 200, 100])), 1);
      expect(calculateZeroCrossingRate(Uint8List.fromList([128])), 0);
    });

    test('rms / peak / speech-like / active ms', () {
      final time = Uint8List.fromList([128, 192, 128, 64]);
      final w = analyzeAudioSamples(time, Uint8List(4), 48000, 8);
      expect(w.peak, 0.5);
      expect(w.rms, closeTo(0.3535533906, 1e-9));
      expect(w.speechLike, isFalse);
      expect(nextSpeechActiveMs(0, true), 1000);
      expect(nextSpeechActiveMs(1000, false), 0);
      expect(nextSpeechActiveMs(3000, false), 1500);
    });
  });

  group('log texts and overlay', () {
    test('summaries', () {
      final data = {
        'faceCount': 1,
        'personCount': null,
        'events': [
          {'type': 'FACE_TURNED_LEFT'},
          {'type': 'FACE_MISSING', 'message': 'gone'},
        ],
        'faceQuality': {
          'faces': [
            {'headDirection': 'looking-left', 'mouthActivity': 0.25},
          ],
        },
      };
      expect(summaryText(data, 120, 2),
          'faces=1 persons=- gadgets=2 head=Looking Left events=FACE_MISSING time=120ms');
      expect(referenceSummaryText(data, 5),
          'reference check: faces=1 persons=0 gadgets=0 events=FACE_TURNED_LEFT, FACE_MISSING time=5ms');
      expect(extractMouthActivity(data), 0.25);
      expect(audioSummaryText({}), 'rms=0.000 speech=0.00 mouth=- activeMs=- events=listening');
      expect(
        audioSummaryText({
          'events': [
            {'type': 'LOUD', 'message': 'Noise'},
          ],
          'audio': {'rms': 0.01234, 'speechRatio': 0.5, 'studentMouthActivity': 0.1, 'activeMs': 2000},
        }),
        'Noise rms=0.012 speech=0.50 mouth=0.100 activeMs=2000 events=LOUD',
      );
    });

    test('overlay boxes', () {
      final boxes = overlayBoxes({
        'objects': [
          {'category': 'candidate', 'class': 'cup', 'confidence': 0.5, 'bbox': [1, 2, 3, 4]},
          {'category': 'candidate', 'ignoredReason': 'x', 'bbox': [1, 2, 3, 4]},
          {'category': 'person', 'bbox': [1, 2, 3, 4]},
        ],
        'persons': [
          {'bbox': [0, 0, 1, 1]},
        ],
        'faces': [
          {'confidence': 0.987, 'bbox': [5, 5, 5, 5]},
          {'bbox': [1, 2]},
        ],
        'gadgets': [
          {'class': 'phone', 'confidence': 0.7, 'bbox': [9, 9, 9, 9]},
        ],
      }, const []);
      expect(boxes.map((b) => b.label), ['cup 0.50', 'person 0.00', 'face 0.99', 'phone 0.70']);
      expect(boxes.map((b) => b.color), [0xFFB76B00, 0xFF20A060, 0xFF2563EB, 0xFFDC2626]);
    });

    test('overlapRatio and local phone heuristic', () {
      expect(overlapRatio([0, 0, 10, 10], [5, 5, 10, 10]), 0.25);
      expect(overlapRatio([0, 0, 0, 10], [0, 0, 10, 10]), 0);
      expect(overlapRatio(null, [0, 0, 1, 1]), 0);

      // 100x100 white frame with a dark 36x50 block.
      final px = Uint8List(100 * 100 * 4)..fillRange(0, 100 * 100 * 4, 255);
      for (var y = 20; y < 70; y++) {
        for (var x = 30; x < 66; x++) {
          final o = (y * 100 + x) * 4;
          px[o] = px[o + 1] = px[o + 2] = 20;
        }
      }
      final frame = RgbaFrame(width: 100, height: 100, data: px);
      expect(detectPhoneLikeObjects({}, frame), isEmpty); // disabled like the web
      final found = detectPhoneLikeObjects({}, frame, enabled: true);
      expect(found.single['bbox'], [30, 20, 36, 50]);
      expect(found.single['confidence'], 0.9);
    });

    test('formatHeadDirection', () {
      expect(formatHeadDirection('front'), 'Front');
      expect(formatHeadDirection('up-right'), 'Up Right');
    });
  });

  group('proctor service config', () {
    test('enabled flag', () {
      expect(ProctorService.parseEnabled(''), isTrue);
      expect(ProctorService.parseEnabled('YES'), isTrue);
      expect(ProctorService.parseEnabled('false'), isFalse);
      expect(ProctorService.parseEnabled('0'), isFalse);
    });

    test('analyze interval', () {
      expect(ProctorService.parseAnalyzeIntervalMs(''), 2500);
      expect(ProctorService.parseAnalyzeIntervalMs('abc'), 2500);
      expect(ProctorService.parseAnalyzeIntervalMs('500'), 1200);
      expect(ProctorService.parseAnalyzeIntervalMs('3000'), 3000);
      expect(ProctorService.parseAnalyzeIntervalMs('0'), 1200);
    });
  });
}
