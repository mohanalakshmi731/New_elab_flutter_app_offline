import 'package:elab_app/features/quiz/quiz_exam.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toastification/toastification.dart';

void main() {
  for (final (hasKey, choice) in [
    (true, 'Four'),
    (true, 'Five'),
    (false, 'Four'),
  ]) {
    testWidgets(
      'offline quiz shows immediate feedback with answer key $hasKey and choice $choice',
      (tester) async {
        Map<String, dynamic>? draft;
        await tester.pumpWidget(
          ProviderScope(
            child: ToastificationWrapper(
              child: MaterialApp(
                home: QuizExamView(
                  offline: true,
                  questions: [
                    {
                      'id': 1,
                      'text': 'Two plus two?',
                      'options': [
                        {
                          'id': 10,
                          'text': 'Four',
                          if (hasKey) 'is_correct': true,
                          'remarks': 'Two and two make four.',
                        },
                        {
                          'id': 11,
                          'text': 'Five',
                          if (hasKey) 'is_correct': false,
                        },
                      ],
                    },
                  ],
                  onAnswersChanged: (value) => draft = value,
                  onClose: () {},
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text(choice));
        await tester.pump(const Duration(milliseconds: 300));
        expect(draft, {'1': choice == 'Four' ? 10 : 11});
        if (hasKey) {
          expect(
            find.textContaining(
              choice == 'Four' ? 'Correct answer!' : 'Wrong answer.',
            ),
            findsWidgets,
          );
          expect(find.text('Two and two make four.'), findsOneWidget);
        } else {
          expect(
            find.textContaining('Grading will be available after sync.'),
            findsWidgets,
          );
          expect(find.textContaining('Wrong answer.'), findsNothing);
        }
        toastification.dismissAll(delayForAnimation: false);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
      },
    );
  }
}
