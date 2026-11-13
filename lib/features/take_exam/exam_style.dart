import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

/// Colours used by `startexam.vue` / `ExamProctorPanel.vue`: the arbitrary
/// hex values, plus short names for the Tailwind (v4) shades they use.
class Ex {
  Ex._();

  // arbitrary values
  static const paper = Color(0xFFF5F4F0); // bg-[#f5f4f0]
  static const ink = Color(0xFF0F1117); // #0f1117
  static const line = Color(0xFFE2DFD8); // #e2dfd8
  static const blue = Color(0xFF2563EB); // #2563eb
  static const blueHover = Color(0xFF1D4ED8); // #1d4ed8
  static const blueSoft = Color(0xFFDBEAFE); // #dbeafe
  static const panelBg = Color(0xFFF7F6F2); // #f7f6f2
  static const panelBorder = Color(0xFFD8DCE7); // #d8dce7
  static const overlayCard = Color(0xFF1A1D27); // #1a1d27

  // Tailwind v4
  static const green100 = Tw.green100;
  static const green600 = Tw.green600;
  static const green700 = Tw.green700;
  static const yellow100 = Tw.yellow100;
  static const yellow800 = Tw.yellow800;
  static const red50 = Tw.red50;
  static const red100 = Tw.red100;
  static const red200 = Tw.red200;
  static const red300 = Tw.red300;
  static const red500 = Tw.red500;
  static const red700 = Tw.red700;
  static const red800 = Tw.red800;
  static const red900 = Tw.red900;
  static const amber100 = Tw.amber100;
  static const amber300 = Tw.amber300;
  static const amber400 = Tw.amber400;
  static const amber600 = Tw.amber600;
  static const amber700 = Tw.amber700;
  static const amber900 = Tw.amber900;
  static const blue50 = Tw.blue50;
  static const blue100 = Tw.blue100;
  static const gray100 = Tw.gray100;
  static const gray700 = Tw.gray700;
}

/// shadcn theme tokens the two components inherit (`bg-card`,
/// `text-card-foreground`, `text-muted-foreground`, `bg-border`). They follow
/// the app's dark mode while the hard-coded hex colours do not — as on the web.
extension ExamTokens on BuildContext {
  Color get exCard => isDark ? AppColors.darkCard : AppColors.card;
  Color get exCardForeground => isDark ? AppColors.darkForeground : AppColors.foreground;
  Color get exMuted => isDark ? AppColors.darkMutedForeground : AppColors.foreground;
  Color get exBorder => isDark ? AppColors.darkBorder : AppColors.border;
}

/// `shadow-sm` (the theme's `--shadow-sm`).
final exShadowSm = AppShadows.sm;
