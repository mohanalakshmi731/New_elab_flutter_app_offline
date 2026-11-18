import 'package:elab_app/features/offline/offline_workspace.dart';
import 'package:elab_app/features/offline/offline_activity_page.dart';
import 'package:elab_app/features/offline/offline_database.dart';
import 'package:elab_app/features/offline/offline_runtime.dart';
import 'package:elab_app/features/offline/offline_service.dart';
import 'package:elab_app/data/models/session.dart';
import 'package:elab_app/state/providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('player owns the learning chrome only while mounted', (
    tester,
  ) async {
    final db = OfflineDatabase(sqlite3.openInMemory());
    const session = SessionState(
      userInfo: UserInfo(
        id: 1,
        instituteId: 2,
        username: 'teacher',
        token: 'test',
        role: Role.instructor,
      ),
    );
    final service = OfflineService(
      () => session,
      () => throw StateError('No HTTP'),
      () async => db,
    );
    final container = ProviderContainer(
      overrides: [
        initialSessionProvider.overrideWithValue(session),
        offlineServiceProvider.overrideWithValue(service),
      ],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: OfflineActivityPage(
            pack: {
              'id': 'pack',
              'class_id': 22,
              'expires_at': DateTime.now()
                  .add(const Duration(days: 1))
                  .toIso8601String(),
            },
            activities: const [
              {
                'id': 1,
                'name': 'Saved activity',
                'chapter_name': 'Full chapter name',
                'mapping_id': -1,
              },
            ],
            initialActivityId: '1',
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(container.read(offlineWorkspaceOwnerProvider), isNotNull);
    expect(find.text('Saved activity'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(container.read(offlineWorkspaceOwnerProvider), isNull);
    expect(container.read(offlineWorkspaceFocusProvider), false);
    container.dispose();
    db.close();
  });

  for (final size in [
    const Size(1280, 800),
    const Size(800, 600),
    const Size(360, 640),
  ]) {
    testWidgets('learning viewport stays spacious at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var selected = -1;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineWorkspace(
              title: 'Explore chemical reactions',
              subtitle: 'Chapter 1 - Chemical Reactions and Equations',
              tabs: const [
                'Activity',
                'Why to Learn',
                'Reference Video',
                'Teacher Guide',
                'Learning Outcome',
                'How to Play',
                'Quiz',
              ],
              selectedTab: 0,
              onTab: (index) => selected = index,
              onBack: () {},
              onBrowse: () {},
              onFullscreen: () {},
              onRestart: () {},
              onFinish: () {},
              child: const ColoredBox(
                key: ValueKey('viewport'),
                color: Colors.white,
              ),
            ),
          ),
        ),
      );
      final viewport = tester.getSize(find.byKey(const ValueKey('viewport')));
      expect(viewport.height, greaterThan(size.height * .75));
      expect(viewport.width, greaterThan(size.width * .9));
      await tester.tap(find.text('Why to Learn'));
      expect(selected, 1);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('focus view uses the entire viewport and has an exit', (
    tester,
  ) async {
    var exits = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: OfflineWorkspace(
            title: 'Activity',
            subtitle: '',
            tabs: const ['Activity'],
            selectedTab: 0,
            onTab: (_) {},
            fullscreen: true,
            onBack: () {},
            onBrowse: () {},
            onFullscreen: () => exits++,
            onRestart: () {},
            onFinish: () {},
            child: const SizedBox.expand(key: ValueKey('focused-viewport')),
          ),
        ),
      ),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('focused-viewport'))),
      const Size(800, 600),
    );
    await tester.tap(find.text('Exit focus view'));
    expect(exits, 1);
  });

  testWidgets('supporting document fills its available height', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OfflineSupportWorkspace(
            panels: [SizedBox.expand(key: ValueKey('document'))],
            labels: ['Overview'],
          ),
        ),
      ),
    );
    expect(
      tester.getSize(find.byKey(const ValueKey('document'))),
      const Size(800, 600),
    );
  });
}
