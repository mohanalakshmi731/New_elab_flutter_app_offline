import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elab_app/features/offline/offline_saved_dialog.dart';

void main() {
  for (final dark in [false, true]) {
    for (final quiz in [false, true]) {
      testWidgets(
        'saved popup closes without leaving the activity quiz=$quiz dark=$dark',
        (tester) async {
          tester.view.physicalSize = const Size(320, 700);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          await tester.pumpWidget(
            MaterialApp(
              theme: ThemeData(
                brightness: dark ? Brightness.dark : Brightness.light,
              ),
              home: Scaffold(
                body: Builder(
                  builder: (context) => TextButton(
                    onPressed: () =>
                        showOfflineSavedDialog(context, quiz: quiz),
                    child: const Text('Current activity'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Current activity'));
          await tester.pumpAndSettle();
          expect(
            find.text(quiz ? 'Your answers are saved!' : 'Activity completed!'),
            findsOneWidget,
          );
          expect(find.byType(SnackBar), findsNothing);
          expect(tester.takeException(), isNull);
          await tester.tap(find.text('Continue'));
          await tester.pumpAndSettle();
          expect(find.text('Current activity'), findsOneWidget);
          expect(find.text('Continue'), findsNothing);
        },
      );
    }
  }
}
