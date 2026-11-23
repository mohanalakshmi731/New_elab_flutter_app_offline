import 'package:flutter/material.dart';
import '../../widgets/app_dialog.dart';

Future<void> showOfflineSavedDialog(
  BuildContext context, {
  required bool quiz,
}) => showGeneralDialog<void>(
  context: context,
  barrierDismissible: true,
  barrierLabel: 'Dismiss saved message',
  barrierColor: Colors.black.withValues(alpha: 0.28),
  transitionDuration: MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 220),
  transitionBuilder: (context, animation, _, child) => FadeTransition(
    opacity: animation,
    child: ScaleTransition(
      scale: animation.drive(
        Tween(
          begin: 0.95,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOutCubic)),
      ),
      child: child,
    ),
  ),
  pageBuilder: (context, _, _) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      child: AppDialogFrame(
        maxWidth: 400,
        radius: 28,
        showClose: false,
        padding: const EdgeInsets.all(28),
        backgroundColor: dark
            ? const Color(0xFF182139)
            : const Color(0xFFFCFBFF),
        borderColor: dark ? const Color(0xFF35415D) : const Color(0xFFE5E1F7),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withValues(alpha: 0.10),
              ),
              child: Icon(
                quiz ? Icons.task_alt_rounded : Icons.emoji_events_rounded,
                size: 38,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              quiz ? 'Your quiz is saved!' : 'Activity completed!',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: dark ? Colors.white : const Color(0xFF172033),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              quiz
                  ? 'Keep learning! Your answers are saved on this device and will sync automatically when you’re online again.'
                  : 'Great work! Your progress is saved and will update automatically when a connection is available.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.5,
                color: dark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.check_rounded),
                label: Text(quiz ? 'Got it' : 'Continue'),
                style: FilledButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  },
);
