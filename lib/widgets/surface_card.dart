import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

/// The card style used across the new UI:
/// `bg-white dark:bg-[#161e36] rounded-[24px] border border-slate-100
///  dark:border-slate-800 shadow-md dark:shadow-none`.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 24,
    this.color,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (dark ? AppColors.cardDark : Colors.white),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: dark ? Tw.slate800 : Tw.slate100),
        // `shadow-md shadow-slate-100/5 dark:shadow-none` (the colour
        // modifier has no effect on style.css's shadow variables).
        boxShadow: dark ? null : AppShadows.md,
      ),
      child: child,
    );
    if (onTap == null) return card;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(onTap: onTap, child: card),
    );
  }
}

/// Section header used inside cards: bold title + optional trailing action,
/// with the `border-b border-slate-50` divider underneath.
class CardHeaderRow extends StatelessWidget {
  const CardHeaderRow({super.key, required this.title, this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: dark ? Tw.slate800 : Tw.slate50, width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(title,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: dark ? Colors.white : Tw.slate800)),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
