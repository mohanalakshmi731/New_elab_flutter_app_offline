import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// Global toasts — replaces `vue-sonner`'s `toast.success / toast.error`.
///
/// Works without a BuildContext because the app is wrapped in
/// `ToastificationWrapper` (see app.dart).
class AppToast {
  AppToast._();

  static const _success = Color(0xFF28883F);
  static const _error = Color(0xFFFF000D);

  /// [background] overrides the fill, like the web's per-call
  /// `toast.success(msg, { style: { background } })`.
  static void success(String message, {Color? background}) => _show(message,
      background ?? _success, ToastificationType.success,
      Icons.check_circle_rounded);

  static void error(String message) =>
      _show(message, _error, ToastificationType.error, Icons.error_rounded);

  static void info(String message) => _show(message, const Color(0xFF4271B5),
      ToastificationType.info, Icons.info_rounded);

  static void _show(
      String message, Color bg, ToastificationType type, IconData icon) {
    if (message.trim().isEmpty) return;
    // In `fillColored`, toastification paints the fill with `primaryColor`
    // and uses `backgroundColor` as the *text/close-icon* colour (and ignores
    // `foregroundColor`). Passing `backgroundColor: bg` made the text the same
    // colour as the fill — invisible — so it must be white here.
    toastification.show(
      type: type,
      style: ToastificationStyle.fillColored,
      primaryColor: bg,
      backgroundColor: Colors.white,
      icon: Icon(icon, color: Colors.white),
      title: Text(
        message,
        style: const TextStyle(
            color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
      // The web's <Toaster> (components/ui/sonner/Sonner.vue) is position="top-right".
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 4),
      showProgressBar: false,
      dragToClose: true,
      closeOnClick: true,
    );
  }
}
