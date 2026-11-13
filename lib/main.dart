import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/storage/secure_store.dart';
import 'state/providers.dart';
import 'state/session_controller.dart';

/// Port of `main.ts`: restores the persisted session (Pinia persisted state)
/// before the first frame, then mounts the app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _configureDesktopWindow();

  if (!Env.isConfigured) {
    runApp(const MissingConfigApp());
    return;
  }

  final store = SecureStore();
  final session = await SessionController.restore(store);
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        secureStoreProvider.overrideWithValue(store),
        initialSessionProvider.overrideWithValue(session),
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const ElabApp(),
    ),
  );
}

/// Windows / macOS: flavor-specific window title and a minimum size that
/// keeps the layout usable (the mobile layout kicks in below 768px).
Future<void> _configureDesktopWindow() async {
  if (kIsWeb || !(Platform.isWindows || Platform.isMacOS || Platform.isLinux)) return;
  await windowManager.ensureInitialized();
  await windowManager.waitUntilReadyToShow(
    const WindowOptions(
      title: Env.isMathzoro ? 'MathZoro' : 'eLabs',
      minimumSize: Size(400, 640),
      size: Size(1280, 800),
      center: true,
    ),
    () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );
}
