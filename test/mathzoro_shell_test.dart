import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:elab_app/core/storage/secure_store.dart';
import 'package:elab_app/features/mathzoro/mathzoro_controller.dart';
import 'package:elab_app/features/mathzoro/mathzoro_shell.dart';
import 'package:elab_app/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// `newdashboardlayout.vue` after the web dropped `<LeftSidebar />` and
/// started rendering its own `<aside>` (hideSidebar only on the upgrade page).

class _MemoryStore extends SecureStore {
  final Map<String, Map<String, dynamic>> data = {};

  @override
  Future<Map<String, dynamic>?> readJson(String key) async => data[key];

  @override
  Future<void> writeJson(String key, Map<String, dynamic> value) async => data[key] = value;

  @override
  Future<void> delete(String key) async => data.remove(key);
}

/// No network: the shell's mount-time requests return nothing.
class _OfflineMathZoro extends MathZoroController {
  @override
  Future<dynamic> getZslTickets() async => null;

  @override
  Future<dynamic> getZslLanguages() async => const [];

  @override
  Future<dynamic> profilegetInstituteById() async => null;
}

Map<String, dynamic> _mathZoroStudentLogin() => {
      'token': 'tok',
      'user': {'id': 7, 'first_name': 'Asha', 'last_name': 'Rao'},
      'institutes': [
        {
          'id': 5,
          'is_default': true,
          'is_math_zoro': 1,
          'roles': [
            {'name': 'student'}
          ],
          'student': {'id': 44, 'batches': const []},
        },
      ],
    };

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  Future<ProviderContainer> pumpShell(WidgetTester tester,
      {required Size size, String initial = '/newlayout/studentdashboard'}) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Build the logged-in session once, then start the app with it.
    final login = ProviderContainer(overrides: [
      secureStoreProvider.overrideWithValue(_MemoryStore()),
    ]);
    login.read(sessionProvider.notifier).setUserInfo(_mathZoroStudentLogin());
    final session = login.read(sessionProvider);
    login.dispose();
    expect(session.userInfo?.isMathZoro, isTrue);

    GoRoute page(String path, String text) =>
        GoRoute(path: path, builder: (_, _) => Text('PAGE $text'));
    final router = GoRouter(
      initialLocation: initial,
      routes: [
        ShellRoute(
          builder: (_, state, child) => MathZoroShell(location: state.uri.path, child: child),
          routes: [
            page('/newlayout/studentdashboard', 'dashboard'),
            page('/newlayout/newmathzone', 'mathzone'),
            page('/newlayout/playzone', 'playzone'),
            page('/newlayout/reports', 'reports'),
            page('/newlayout/studentupgradeplan', 'upgrade'),
          ],
        ),
      ],
    );

    await tester.pumpWidget(ProviderScope(
      overrides: [
        initialSessionProvider.overrideWithValue(session),
        secureStoreProvider.overrideWithValue(_MemoryStore()),
        sharedPreferencesProvider.overrideWithValue(prefs),
        mathZoroProvider.overrideWith(_OfflineMathZoro.new),
      ],
      child: MaterialApp.router(routerConfig: router),
    ));
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(tester.element(find.byType(MathZoroShell)));
  }

  final menuButton = find.byIcon(BootstrapIcons.list);

  testWidgets('lg+: sidebar starts open and the menu button collapses it to icons',
      (tester) async {
    final container = await pumpShell(tester, size: const Size(1280, 800));

    for (final label in ['Dashboard', 'Math Zone', 'Play Zone', 'Reports', 'Appearance']) {
      expect(find.text(label).hitTestable(), findsOneWidget, reason: label);
    }
    expect(find.text('Science Zone'), findsNothing, reason: 'MathZoro student nav');

    await tester.tap(menuButton);
    await tester.pumpAndSettle();
    expect(find.text('Math Zone'), findsNothing);
    expect(find.text('Appearance'), findsNothing);
    expect(find.byIcon(BootstrapIcons.calculator_fill).hitTestable(), findsOneWidget);

    // Collapsed strip still navigates and stays collapsed on desktop.
    await tester.tap(find.byIcon(BootstrapIcons.calculator_fill));
    await tester.pumpAndSettle();
    expect(find.text('PAGE mathzone'), findsOneWidget);
    expect(find.text('Math Zone'), findsNothing);

    // Appearance cycles the colour mode (system → light).
    await tester.tap(menuButton);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Appearance'));
    await tester.pumpAndSettle();
    expect(container.read(colorModeProvider), ColorModePref.light);
  });

  testWidgets('below lg: off-canvas drawer opens from the menu button and closes on nav',
      (tester) async {
    await pumpShell(tester, size: const Size(400, 800));

    expect(find.text('Math Zone').hitTestable(), findsNothing, reason: 'starts closed');

    await tester.tap(menuButton);
    await tester.pumpAndSettle();
    expect(find.text('Math Zone').hitTestable(), findsOneWidget);

    await tester.tap(find.text('Play Zone'));
    await tester.pumpAndSettle();
    expect(find.text('PAGE playzone'), findsOneWidget);
    expect(find.text('Math Zone').hitTestable(), findsNothing, reason: 'closed after nav');

    // Tapping the backdrop closes it too.
    await tester.tap(menuButton);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(350, 400));
    await tester.pumpAndSettle();
    expect(find.text('Math Zone').hitTestable(), findsNothing);
  });

  testWidgets('the upgrade-plan page has no sidebar and no menu button', (tester) async {
    await pumpShell(tester,
        size: const Size(1280, 800), initial: '/newlayout/studentupgradeplan');

    expect(find.text('PAGE upgrade'), findsOneWidget);
    expect(menuButton, findsNothing);
    expect(find.text('Math Zone'), findsNothing);
  });
}
