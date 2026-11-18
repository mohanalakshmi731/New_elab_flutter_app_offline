import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elab_app/features/offline/connection_transition_host.dart';

class Status {
  const Status(
    this.reachable, {
    this.session = 'user',
    this.prepared = true,
    this.network = false,
    this.localMode = false,
  });
  final bool? reachable;
  final String? session;
  final bool prepared, network, localMode;
}

Future<ValueNotifier<Status>> mount(
  WidgetTester tester, {
  Status initial = const Status(true),
  VoidCallback? onContinueOffline,
  VoidCallback? onSwitchOnline,
}) async {
  final status = ValueNotifier(initial);
  addTearDown(status.dispose);
  final navigator = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    ValueListenableBuilder<Status>(
      valueListenable: status,
      builder: (context, value, _) => MaterialApp(
        navigatorKey: navigator,
        builder: (context, child) => ConnectionTransitionHost(
          navigatorKey: navigator,
          sessionIdentity: value.session,
          reachable: value.reachable,
          hasPrepared: value.prepared,
          localMode: value.localMode,
          onContinueOffline: onContinueOffline,
          onSwitchOnline: onSwitchOnline,
          deviceHasNetwork: () async => value.network,
          child: child!,
        ),
        home: const Scaffold(body: Center(child: Text('Current activity'))),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return status;
}

Future<void> confirm(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('offline learners can choose either mode on reconnection', (
    tester,
  ) async {
    var staysOffline = 0, switchesOnline = 0;
    final status = await mount(
      tester,
      onContinueOffline: () => staysOffline++,
      onSwitchOnline: () => switchesOnline++,
    );
    status.value = const Status(false, localMode: true);
    await confirm(tester);
    await tester.tap(find.text('Continue offline learning'));
    await tester.pumpAndSettle();
    expect(staysOffline, 1);
    status.value = const Status(true, localMode: true);
    await confirm(tester);
    expect(find.text('Continue offline learning'), findsOneWidget);
    expect(find.text('Switch to online'), findsOneWidget);
    await tester.tap(find.text('Continue offline learning'));
    await tester.pumpAndSettle();
    expect(staysOffline, 2);
    status.value = const Status(false, localMode: true);
    await confirm(tester);
    status.value = const Status(true, localMode: true);
    await confirm(tester);
    await tester.tap(find.text('Switch to online'));
    await tester.pumpAndSettle();
    expect(switchesOnline, 1);
    expect(find.text('Current activity'), findsOneWidget);
  });

  testWidgets(
    'connection transitions appear once and dismissal keeps the current activity',
    (tester) async {
      final status = await mount(tester);
      expect(find.text('You’re back online!'), findsNothing);
      status.value = const Status(false);
      await confirm(tester);
      expect(find.text('You’re offline. Keep learning!'), findsOneWidget);
      await tester.tap(find.text('Continue offline learning'));
      await tester.pumpAndSettle();
      expect(find.text('Current activity'), findsOneWidget);
      status.value = const Status(false);
      await confirm(tester);
      expect(find.text('You’re offline. Keep learning!'), findsNothing);
      status.value = const Status(true);
      await confirm(tester);
      expect(find.text('You’re back online!'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Current activity'), findsOneWidget);
    },
  );
  testWidgets('brief connection flicker does not show a modal', (tester) async {
    final status = await mount(tester);
    status.value = const Status(false);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 800));
    status.value = const Status(true);
    await confirm(tester);
    expect(find.byType(FilledButton), findsNothing);
  });
  testWidgets(
    'a new transition updates the visible modal rather than stacking routes',
    (tester) async {
      final status = await mount(tester);
      status.value = const Status(false);
      await confirm(tester);
      status.value = const Status(true);
      await confirm(tester);
      expect(find.text('You’re back online!'), findsOneWidget);
      expect(find.text('You’re offline. Keep learning!'), findsNothing);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.byType(FilledButton), findsNothing);
      expect(find.text('Current activity'), findsOneWidget);
    },
  );
  testWidgets(
    'service failure is not labelled as device offline and no saved lessons are promised',
    (tester) async {
      final status = await mount(tester);
      status.value = const Status(false, prepared: false, network: true);
      await confirm(tester);
      expect(find.text('We can’t connect right now'), findsOneWidget);
      expect(find.text('Got it'), findsOneWidget);
      expect(
        find.textContaining('Your prepared lessons are available'),
        findsNothing,
      );
      await tester.tap(find.text('Got it'));
      await tester.pumpAndSettle();
    },
  );
  testWidgets(
    'logout cancels a pending notice and closes an existing connection modal',
    (tester) async {
      final status = await mount(tester);
      status.value = const Status(false);
      await confirm(tester);
      status.value = const Status(false, session: null);
      await tester.pumpAndSettle();
      expect(find.byType(FilledButton), findsNothing);
      status.value = const Status(true, session: null);
      await confirm(tester);
      expect(find.text('You’re back online!'), findsNothing);
    },
  );
  testWidgets('modal fits a narrow light-mode screen', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final status = await mount(tester);
    status.value = const Status(false, prepared: false);
    await confirm(tester);
    expect(find.text('You’re offline'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();
  });
}
