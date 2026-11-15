import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/network/content_cache.dart';
import '../core/realtime/echo_client.dart';
import '../core/storage/secure_store.dart';
import '../data/models/session.dart';
import '../data/services/auth_service.dart';
import 'session_controller.dart';
import 'lab_practice.dart';

/// Core providers shared by the whole app.
///
/// `initialSessionProvider` and `sharedPreferencesProvider` are overridden in
/// `main()` after the persisted values are loaded.

final secureStoreProvider = Provider<SecureStore>((ref) => SecureStore());

final sharedPreferencesProvider = Provider<SharedPreferences>(
    (ref) => throw UnimplementedError('overridden in main()'));

final initialSessionProvider =
    Provider<SessionState>((ref) => const SessionState());

/// The logged-in session (Pinia `useUserStore` session fields).
final sessionProvider =
    NotifierProvider<SessionController, SessionState>(SessionController.new);

/// Shared HTTP client (src/service/Axios.ts).
final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient(
    prepareActivityPayload: (path, payload) {
      final session = ref.read(sessionProvider);
      final practice = ref.read(labPracticeProvider);
      if (!session.isLabAdmin ||
          practice == null ||
          practice.token != session.token ||
          !labIdentityPaths.contains(path)) {
        return payload;
      }
      return practice.apply(payload);
    },
    tokenReader: () => ref.read(sessionProvider).userInfo?.token,
    onUnauthorized: () => ref.read(sessionProvider.notifier).logout(callApi: false),
  );
});

/// Memory + disk cache for slow, rarely-changing reads (ZSL curriculum).
/// Cleared on logout.
final contentCacheProvider = Provider<ContentCache>((ref) => ContentCache());

final authServiceProvider =
    Provider<AuthService>((ref) => AuthService(ref.watch(apiClientProvider)));

/// Laravel Echo / Reverb client (`app.config.globalProperties.$echo`).
/// The socket opens lazily on the first channel subscription.
final echoClientProvider = Provider<EchoClient>((ref) {
  final echo = EchoClient(tokenReader: () => ref.read(sessionProvider).userInfo?.token);
  ref.onDispose(echo.disconnect);
  return echo;
});

// ── Color mode (store.colorMode: 'light' | 'dark' | 'system') ─────────────

enum ColorModePref { light, dark, system }

class ColorModeController extends Notifier<ColorModePref> {
  static const _key = 'elab.colorMode';

  @override
  ColorModePref build() {
    final raw = ref.read(sharedPreferencesProvider).getString(_key);
    return ColorModePref.values.firstWhere((m) => m.name == raw,
        orElse: () => ColorModePref.system);
  }

  void set(ColorModePref mode) {
    state = mode;
    ref.read(sharedPreferencesProvider).setString(_key, mode.name);
  }

  /// Top bar button: light → dark → system → light.
  void cycle() => set(switch (state) {
        ColorModePref.light => ColorModePref.dark,
        ColorModePref.dark => ColorModePref.system,
        ColorModePref.system => ColorModePref.light,
      });

  /// Sidebar button: toggles light ↔ dark only.
  void toggleLightDark() =>
      set(state == ColorModePref.dark ? ColorModePref.light : ColorModePref.dark);
}

final colorModeProvider =
    NotifierProvider<ColorModeController, ColorModePref>(ColorModeController.new);

final themeModeProvider = Provider<ThemeMode>((ref) {
  return switch (ref.watch(colorModeProvider)) {
    ColorModePref.light => ThemeMode.light,
    ColorModePref.dark => ThemeMode.dark,
    ColorModePref.system => ThemeMode.system,
  };
});
