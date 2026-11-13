import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// The exam page's `vue-sonner` calls with their inline styles
/// (`AppToast` has no warning variant and uses a different error red).
class ExamToast {
  ExamToast._();

  /// `toast.success(…, { backgroundColor: '#28883fff', color: 'white', fontSize: '1rem' })`
  static void success(String message) => _show(message, const Color(0xFF28883F), Colors.white,
      ToastificationType.success, Icons.check_circle_rounded);

  /// `toast.warning(…, { backgroundColor: '#f59e0b', color: '#111827' })`
  static void warning(String message) => _show(message, const Color(0xFFF59E0B),
      const Color(0xFF111827), ToastificationType.warning, Icons.warning_rounded);

  /// `toast.error(…, { backgroundColor: '#dc2626', color: 'white' })`
  static void error(String message) => _show(message, const Color(0xFFDC2626), Colors.white,
      ToastificationType.error, Icons.error_rounded);

  static void _show(String message, Color bg, Color fg, ToastificationType type, IconData icon) {
    if (message.trim().isEmpty) return;
    toastification.show(
      type: type,
      style: ToastificationStyle.fillColored,
      primaryColor: bg,
      // fillColored: `backgroundColor` is the text / close-icon colour.
      backgroundColor: fg,
      icon: Icon(icon, color: fg),
      title: Text(
        message,
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: fg),
        maxLines: 4,
        overflow: TextOverflow.ellipsis,
      ),
      // `<Toaster position="top-right">` (components/ui/sonner/Sonner.vue).
      alignment: Alignment.topRight,
      autoCloseDuration: const Duration(seconds: 4),
      showProgressBar: false,
      dragToClose: true,
      closeOnClick: true,
    );
  }
}
