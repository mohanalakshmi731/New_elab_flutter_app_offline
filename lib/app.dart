import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'core/config/env.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'state/providers.dart';
import 'features/offline/offline_runtime.dart';
import 'features/offline/offline_page.dart';
import 'features/offline/offline_learning_banner.dart';
import 'features/offline/offline_service.dart';
import 'features/offline/connection_transition_host.dart';

/// Port of `App.vue`: router outlet + global toaster + color mode.
class ElabApp extends ConsumerWidget {
  const ElabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final offline = ref.watch(offlineRuntimeProvider);
    final loggedIn = ref.watch(sessionProvider.select((s) => s.isLoggedIn));
    final hasPrepared =
        loggedIn &&
        (ref
                .watch(preparedOfflineCatalogProvider)
                .valueOrNull
                ?.entries
                .isNotEmpty ??
            false);
    final browsingOffline = ref.watch(offlineBrowsingProvider);
    void prepare() {
      ref.read(offlineLocalModeProvider.notifier).state = false;
      final pageContext = router.routerDelegate.navigatorKey.currentContext;
      if (pageContext != null) showOfflinePreparation(pageContext);
    }

    return ToastificationWrapper(
      child: MaterialApp.router(
        title: Env.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ref.watch(themeModeProvider),
        routerConfig: router,
        builder: (context, child) => ConnectionTransitionHost(
          navigatorKey: router.routerDelegate.navigatorKey,
          sessionIdentity: loggedIn
              ? '${ref.watch(sessionProvider).userId}:${ref.watch(sessionProvider).instituteId}'
              : null,
          reachable: offline.reachable,
          hasPrepared: hasPrepared,
          localMode: ref.watch(offlineLocalModeProvider),
          onOfflineDetected: () =>
              ref.read(offlineLocalModeProvider.notifier).state = true,
          onContinueOffline: () =>
              ref.read(offlineLocalModeProvider.notifier).state = true,
          onSwitchOnline: () =>
              ref.read(offlineLocalModeProvider.notifier).state = false,
          deviceHasNetwork: () async =>
              (await ref.read(offlineNetworkAdaptersProvider)()).isNotEmpty,
          child: Column(
            children: [
              if (loggedIn && ref.watch(offlineWorkspaceOwnerProvider) == null)
                OfflineLearningBanner(
                  offline: browsingOffline,
                  localMode:
                      ref.watch(offlineLocalModeProvider) &&
                      offline.reachable == true,
                  hasPrepared: hasPrepared,
                  onSwitchOnline: offline.reachable == true
                      ? () =>
                            ref.read(offlineLocalModeProvider.notifier).state =
                                false
                      : null,
                  onUpdate: offline.reachable == true ? prepare : null,
                  checking: offline.reachable == null,
                  preparing: offline.preparing,
                  message: offline.message,
                  onAction: () {
                    if (browsingOffline || hasPrepared) {
                      if (hasPrepared) {
                        ref.read(offlineLocalModeProvider.notifier).state =
                            true;
                      }
                      router.go(
                        Env.isMathzoro ? '/newlayout/newmathzone' : '/library',
                      );
                    } else {
                      prepare();
                    }
                  },
                ),
              Expanded(child: child ?? const SizedBox.shrink()),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shown when the app is started without `--dart-define-from-file`.
class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.settings_suggest_rounded, size: 48),
                SizedBox(height: 16),
                Text(
                  'API configuration missing',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 12),
                SelectableText(
                  'Run the app with an environment file, for example:\n\n'
                  'flutter run --dart-define-from-file=.env\n\n'
                  'Create a .env file in the project root with BASE_URL\n'
                  'and the REVERB_* values (see README.md).',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
