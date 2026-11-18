import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:elab_app/features/offline/offline_activity_entry.dart';
import 'package:elab_app/features/offline/offline_runtime.dart';
import 'package:elab_app/features/offline/offline_service.dart';
import 'package:elab_app/features/offline/prepared_catalog.dart';
import 'package:elab_app/data/models/session.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elab_app/features/offline/offline_learning_banner.dart';

class ManualRuntime extends OfflineRuntime {
  @override
  OfflineRuntimeState build() => const OfflineRuntimeState(reachable: true);
  void reachable(bool value) => state = OfflineRuntimeState(reachable: value);
}

class EmptyPreparedService extends OfflineService {
  EmptyPreparedService()
    : super(
        () => const SessionState(),
        () => throw StateError('No network'),
        () => throw StateError('No database'),
      );
  @override
  Future<PreparedCatalog> preparedCatalog() async => PreparedCatalog([]);
}

void main() {
  testWidgets('header updates immediately when the learner switches online', (
    tester,
  ) async {
    final local = ValueNotifier(true);
    addTearDown(local.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<bool>(
            valueListenable: local,
            builder: (context, offline, _) => OfflineLearningBanner(
              offline: offline,
              localMode: offline,
              hasPrepared: true,
              preparing: false,
              message: 'Old preparation message',
              onAction: () => local.value = true,
              onSwitchOnline: () => local.value = false,
            ),
          ),
        ),
      ),
    );
    expect(find.text('Offline learning · Internet available'), findsOneWidget);
    await tester.tap(find.text('Switch to online'));
    await tester.pump();
    expect(find.text('Online learning'), findsOneWidget);
    expect(
      find.text('You can explore all available online lessons.'),
      findsOneWidget,
    );
    expect(find.text('Old preparation message'), findsNothing);
    await tester.tap(find.text('Learn offline'));
    await tester.pump();
    expect(find.text('Offline learning · Internet available'), findsOneWidget);
  });

  test('learning locally can be selected while backend is online', () {
    final container = ProviderContainer(
      overrides: [offlineRuntimeProvider.overrideWith(ManualRuntime.new)],
    );
    addTearDown(container.dispose);
    expect(container.read(offlineBrowsingProvider), false);
    container.read(offlineLocalModeProvider.notifier).state = true;
    expect(container.read(offlineRuntimeProvider).reachable, true);
    expect(container.read(offlineBrowsingProvider), true);
  });

  testWidgets('prepared content offers learning and update actions online', (
    tester,
  ) async {
    var learns = 0, updates = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OfflineLearningBanner(
            offline: false,
            preparing: false,
            hasPrepared: true,
            message: '',
            onAction: () => learns++,
            onUpdate: () => updates++,
          ),
        ),
      ),
    );
    expect(find.text('Prepare for offline use'), findsNothing);
    await tester.tap(find.text('Learn offline'));
    await tester.tap(find.text('Update offline content'));
    expect(learns, 1);
    expect(updates, 1);
  });

  testWidgets('an offline activity route remains local after reconnecting', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        offlineRuntimeProvider.overrideWith(ManualRuntime.new),
        offlineServiceProvider.overrideWithValue(EmptyPreparedService()),
      ],
    );
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            body: OfflineAwareActivity(
              readContext: (_) => {},
              onlineBuilder: (_) => const Text('Online player'),
            ),
          ),
        ),
      ),
    );
    expect(find.text('Online player'), findsOneWidget);
    final runtime =
        container.read(offlineRuntimeProvider.notifier) as ManualRuntime;
    runtime.reachable(false);
    await tester.pumpAndSettle();
    expect(find.byType(OfflineActivityEntry), findsOneWidget);
    runtime.reachable(true);
    await tester.pumpAndSettle();
    expect(find.byType(OfflineActivityEntry), findsOneWidget);
    expect(find.text('Online player'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
    'Learn offline remains readable and clickable on a narrow screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var clicked = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineLearningBanner(
              offline: true,
              hasPrepared: true,
              preparing: false,
              message: '',
              onAction: () => clicked++,
            ),
          ),
        ),
      );
      expect(find.text('Offline learning'), findsOneWidget);
      expect(find.text('Continue offline learning'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Continue offline learning'));
      expect(clicked, 1);
      expect(find.text('Local records'), findsNothing);
    },
  );
}
