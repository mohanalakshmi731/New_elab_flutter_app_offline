import 'package:elab_app/core/theme/app_theme.dart';
import 'package:elab_app/features/offline/offline_workspace.dart';
import 'package:flutter/material.dart';
import 'package:elab_app/widgets/form_fields.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final dark in [false, true]) {
    testWidgets(
      'offline tabs remain readable and selectable in ${dark ? 'dark' : 'light'} mode',
      (tester) async {
        final theme = dark ? AppTheme.dark() : AppTheme.light();
        var selected = 0;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return OfflineWorkspace(
                    title: 'Pattern workshop',
                    subtitle: '',
                    tabs: const ['Activity', 'Why to learn', 'Quiz'],
                    selectedTab: selected,
                    onTab: (index) => setState(() => selected = index),
                    onBack: () {},
                    onBrowse: () {},
                    onFullscreen: () {},
                    onRestart: () {},
                    onFinish: () {},
                    child: const SizedBox.expand(),
                  );
                },
              ),
            ),
          ),
        );

        void check(String label) {
          final text = tester.widget<Text>(find.text(label));
          final button = tester.widget<TextButton>(
            find.ancestor(
              of: find.text(label),
              matching: find.byType(TextButton),
            ),
          );
          final background = button.style!.backgroundColor!.resolve({});
          final foreground = text.style!.color!;
          final contrast =
              (background!.computeLuminance() + .05) /
              (foreground.computeLuminance() + .05);
          expect(
            contrast < 1 ? 1 / contrast : contrast,
            greaterThanOrEqualTo(4.5),
          );
        }

        check('Activity');
        await tester.tap(find.text('Quiz'));
        await tester.pumpAndSettle();
        expect(selected, 2);
        check('Quiz');
        expect(
          tester.widget<Text>(find.text('Activity')).style!.color,
          theme.colorScheme.onSurfaceVariant,
        );
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets(
      'practice selectors open below their fields in ${dark ? 'dark' : 'light'} mode',
      (tester) async {
        final theme = dark ? AppTheme.dark() : AppTheme.light();
        var practice = false;
        int? selectedClass;
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: StatefulBuilder(
                builder: (context, setState) {
                  return Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 230,
                          child: AppSelect<bool>(
                            value: practice,
                            height: 44,
                            items: const [
                              AppSelectItem(false, 'Presentation mode'),
                              AppSelectItem(true, 'Practice mode'),
                            ],
                            onChanged: (value) =>
                                setState(() => practice = value!),
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (practice)
                          SizedBox(
                            width: 220,
                            child: AppSelect<int>(
                              value: selectedClass,
                              placeholder: 'Select assigned class',
                              height: 44,
                              items: const [AppSelectItem(1, 'Class A')],
                              onChanged: (value) =>
                                  setState(() => selectedClass = value),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
        await tester.tap(find.text('Presentation mode'));
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(find.text('Practice mode')).dy,
          greaterThan(tester.getBottomLeft(find.byType(AppSelect<bool>)).dy),
        );
        await tester.tap(find.text('Practice mode'));
        await tester.pumpAndSettle();
        expect(practice, isTrue);
        await tester.tap(find.text('Select assigned class'));
        await tester.pumpAndSettle();
        expect(
          tester.getTopLeft(find.text('Class A')).dy,
          greaterThan(tester.getBottomLeft(find.byType(AppSelect<int>)).dy),
        );
        await tester.tap(find.text('Class A'));
        await tester.pumpAndSettle();
        expect(selectedClass, 1);
        expect(find.text('Select assigned class'), findsNothing);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
