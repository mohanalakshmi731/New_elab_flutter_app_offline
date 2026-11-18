import 'package:flutter/material.dart';

class OfflineLearningBanner extends StatelessWidget {
  const OfflineLearningBanner({
    super.key,
    required this.offline,
    required this.preparing,
    required this.message,
    required this.onAction,
    this.checking = false,
    this.hasPrepared = false,
    this.localMode = false,
    this.onUpdate,
    this.onSwitchOnline,
  });
  final bool offline, preparing;
  final bool checking;
  final bool hasPrepared;
  final bool localMode;
  final VoidCallback? onUpdate, onSwitchOnline;
  final String message;
  final VoidCallback onAction;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final headingColor = dark
        ? const Color(0xFFF1F5F9)
        : const Color(0xFF0F172A);
    final bodyColor = dark ? const Color(0xFFCBD5E1) : const Color(0xFF334155);
    final heading = Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(
            offline ? Icons.cloud_off_rounded : Icons.offline_bolt_rounded,
            color: colors.primary,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                checking
                    ? 'Checking content connection…'
                    : offline
                    ? localMode
                          ? 'Offline learning · Internet available'
                          : 'Offline learning'
                    : preparing
                    ? 'Getting ready for offline learning'
                    : 'Online learning',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: headingColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                checking
                    ? 'Checking whether online content is available.'
                    : offline
                    ? localMode
                          ? 'You’re using your prepared lessons. Your progress updates automatically.'
                          : hasPrepared
                          ? 'Keep learning with your prepared lessons.'
                          : 'Connect to prepare lessons for offline learning.'
                    : preparing
                    ? message
                    : 'You can explore all available online lessons.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: bodyColor, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
    final action = FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
      ),
      onPressed: localMode && onSwitchOnline != null
          ? onSwitchOnline
          : checking || offline && !hasPrepared
          ? null
          : onAction,
      icon: Icon(
        offline || hasPrepared
            ? Icons.play_arrow_rounded
            : preparing
            ? Icons.hourglass_top_rounded
            : Icons.offline_bolt_outlined,
        size: 18,
      ),
      label: Text(
        localMode && onSwitchOnline != null
            ? 'Switch to online'
            : preparing
            ? 'View preparation'
            : offline
            ? hasPrepared
                  ? 'Continue offline learning'
                  : 'Connect to prepare lessons'
            : hasPrepared
            ? 'Learn offline'
            : 'Prepare for offline use',
      ),
    );
    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (hasPrepared && onUpdate != null && !preparing)
          TextButton.icon(
            onPressed: onUpdate,
            icon: const Icon(Icons.refresh),
            label: const Text('Update offline content'),
          ),
        action,
      ],
    );
    return Material(
      color: dark ? const Color(0xFF18243B) : const Color(0xFFEFF6FF),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: LayoutBuilder(
            builder: (context, constraints) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (constraints.maxWidth < 600) ...[
                  heading,
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerRight, child: actions),
                ] else
                  Row(
                    children: [
                      Expanded(child: heading),
                      const SizedBox(width: 16),
                      actions,
                    ],
                  ),
                if (preparing) ...[
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(minHeight: 2),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
