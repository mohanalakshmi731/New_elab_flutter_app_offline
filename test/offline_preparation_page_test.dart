import 'package:elab_app/data/models/session.dart';
import 'package:elab_app/features/offline/offline_page.dart';
import 'package:elab_app/features/offline/offline_runtime.dart';
import 'package:elab_app/features/offline/offline_service.dart';
import 'package:elab_app/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const session = SessionState(
  userInfo: UserInfo(id: 1, instituteId: 2, username: 'test', token: 'test'),
  language: AppLanguage(id: 3, code: 'te', name: 'TELUGU'),
);

class ContextService extends OfflineService {
  ContextService()
    : super(
        () => session,
        () => throw UnimplementedError(),
        () => throw UnimplementedError(),
      );
  @override
  Future<Map<String, dynamic>> refreshContext() async => {
    'classes': [
      {'id': 22, 'name': 'Class 10'},
      {'id': '22', 'name': 'Class 10'},
    ],
  };
  @override
  Future<List<Map<String, dynamic>>> packs() async => [];
}

class OfflineStatus extends OfflineRuntime {
  @override
  OfflineRuntimeState build() => const OfflineRuntimeState(reachable: false);
}

void main() {
  testWidgets('preparation opens as a centered dialog', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialSessionProvider.overrideWithValue(session),
          offlineServiceProvider.overrideWithValue(ContextService()),
          offlineRuntimeProvider.overrideWith(OfflineStatus.new),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showOfflinePreparation(context),
                child: const Text('Open preparation'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open preparation'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsOneWidget);
    expect(tester.getCenter(find.byType(Dialog)), const Offset(400, 300));
    expect(tester.takeException(), isNull);
  });

  testWidgets('preparation preserves Telugu and can retry while offline', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialSessionProvider.overrideWithValue(session),
          offlineServiceProvider.overrideWithValue(ContextService()),
          offlineRuntimeProvider.overrideWith(OfflineStatus.new),
        ],
        child: const MaterialApp(home: Scaffold(body: OfflinePreparation())),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('TELUGU'), findsOneWidget);
    final fields = tester
        .widgetList<DropdownButtonFormField<int>>(
          find.byType(DropdownButtonFormField<int>),
        )
        .toList();
    expect(fields.first.initialValue, 22);
    expect(fields.last.initialValue, 3);
    final button = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Prepare for offline use'),
    );
    expect(button.onPressed, isNotNull);
  });
}
