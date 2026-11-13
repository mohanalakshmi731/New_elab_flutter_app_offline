import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:toastification/toastification.dart';

import 'core/config/env.dart';
import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'state/providers.dart';

/// Port of `App.vue`: router outlet + global toaster + color mode.
class ElabApp extends ConsumerWidget {
  const ElabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return ToastificationWrapper(
      child: MaterialApp.router(
        title: Env.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ref.watch(themeModeProvider),
        routerConfig: router,
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
                Text('API configuration missing',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
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
