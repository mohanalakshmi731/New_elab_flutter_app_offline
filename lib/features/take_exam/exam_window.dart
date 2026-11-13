import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

/// Native stand-ins for the browser APIs `startexam.vue` and
/// `ExamProctorPanel.vue` use for the exam lock-down
/// (`requestFullscreen`, `document.fullscreenElement`, `document.hasFocus()`),
/// following `features/mathzoro/mathzoro_quiz.dart`:
///
/// * Windows / macOS: `window_manager` fullscreen + focus queries.
/// * Android / iOS: immersive-sticky system UI. A phone app is always
///   "fullscreen", so [isFullscreen] reports the requested state.
class ExamWindow {
  ExamWindow._();

  static bool get isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  static bool get isMobile => !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static bool _mobileFullscreen = false;

  /// Focus/lifecycle changes caused by our own fullscreen switch are ignored
  /// until this moment (same 1.5 s window as the MathZoro quiz).
  static DateTime ignoreLifecycleUntil = DateTime.fromMillisecondsSinceEpoch(0);

  static bool get ignoringLifecycle => DateTime.now().isBefore(ignoreLifecycleUntil);

  /// `document.documentElement.requestFullscreen()`
  static Future<void> enterFullscreen() async {
    ignoreLifecycleUntil = DateTime.now().add(const Duration(milliseconds: 1500));
    try {
      if (isDesktop) {
        if (!await windowManager.isFullScreen()) await windowManager.setFullScreen(true);
      } else if (isMobile) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
        _mobileFullscreen = true;
      }
    } catch (_) {}
  }

  /// `document.exitFullscreen()`
  static Future<void> exitFullscreen() async {
    try {
      if (isDesktop) {
        if (await windowManager.isFullScreen()) await windowManager.setFullScreen(false);
      } else if (isMobile) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
        _mobileFullscreen = false;
      }
    } catch (_) {}
  }

  /// `!!document.fullscreenElement`
  static Future<bool> isFullscreen() async {
    if (isDesktop) {
      try {
        return await windowManager.isFullScreen();
      } catch (_) {
        return false;
      }
    }
    if (isMobile) return _mobileFullscreen;
    return true;
  }

  /// Requests fullscreen and waits (up to ~1.5 s — the macOS animation) until
  /// the window reports it. Returns the final state.
  static Future<bool> ensureFullscreen() async {
    if (await isFullscreen()) return true;
    await enterFullscreen();
    for (var i = 0; i < 15; i++) {
      if (await isFullscreen()) return true;
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    return isFullscreen();
  }

  /// `document.hasFocus()` — desktop asks the window manager; on mobile the
  /// app-lifecycle state decides (see the page's lifecycle listener).
  static Future<bool> hasFocus() async {
    if (isDesktop) {
      try {
        return await windowManager.isFocused();
      } catch (_) {
        return true;
      }
    }
    return true;
  }

  /// `window.onbeforeunload` — desktop only: the window close button is
  /// intercepted while [prevent] is true (see `WindowListener.onWindowClose`).
  static Future<void> setPreventClose(bool prevent) async {
    if (!isDesktop) return;
    try {
      await windowManager.setPreventClose(prevent);
    } catch (_) {}
  }

  /// Closes the window after the user confirmed leaving.
  static Future<void> forceClose() async {
    if (!isDesktop) return;
    try {
      await windowManager.setPreventClose(false);
      await windowManager.close();
    } catch (_) {}
  }
}
