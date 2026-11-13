import 'dart:io';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../widgets/app_table.dart';
import '../exams/exam_widgets.dart' show ExamNativeLabel;
import 'exam_manage_logic.dart';

/// Widgets shared by the question / exam management ports.

/// `text-muted-foreground` (`--muted-foreground`: #1f2430 light, #9db1d4 dark).
Color mutedFg(BuildContext context) =>
    context.isDark ? AppColors.darkMutedForeground : AppColors.foreground;

/// `bg-muted`
Color mutedBg(BuildContext context) => context.isDark ? AppColors.darkMuted : AppColors.muted;

/// `<input type="number">` keyboard + filter.
const exmNumberKeyboard = TextInputType.numberWithOptions(decimal: true, signed: true);
final exmNumberFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[0-9eE.+\-]'))];

/// shadcn `<Card>` (`bg-card flex flex-col gap-6 rounded-xl border py-6
/// shadow-sm`); pass [padding] for `p-4` / `p-6` / `p-0` and [color] for a
/// background override (`bg-gray-50`).
class ExmCard extends StatelessWidget {
  const ExmCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
    this.color,
    this.gap = 24,
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;
  final Color? color;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? (dark ? AppColors.darkCard : AppColors.card),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: context.borderColor),
        boxShadow: AppShadows.sm,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: dark ? AppColors.darkForeground : AppColors.foreground),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: gap),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// `<CardTitle>` (`leading-none font-semibold`, an `h3`), optionally
/// `text-primary` and with the red `after:content-['*'] after:ml-1`.
class ExmCardTitle extends StatelessWidget {
  const ExmCardTitle(this.text, {super.key, this.primary = false, this.required = false, this.style});

  final String text;
  final bool primary;
  final bool required;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: text,
        children: [
          if (required) ...[
            const WidgetSpan(child: SizedBox(width: 4)),
            const TextSpan(text: '*', style: TextStyle(color: Tw.red500)),
          ],
        ],
      ),
      style: TextStyle(
        fontSize: 16,
        height: 1,
        fontWeight: FontWeight.w600,
        color: primary ? context.colors.primary : null,
      ).merge(style),
    );
  }
}

/// A plain `<label class="text-sm font-medium">` followed by its control:
/// the inline label sits in a 24px line box (the parent's 16px / 24px
/// strut), and the control starts right below it.
class PlainLabeled extends StatelessWidget {
  const PlainLabeled({super.key, required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [ExamNativeLabel(label), child],
      );
}

/// shadcn `<Switch>` (reka-ui): `h-[1.15rem] w-8 border border-transparent
/// shadow-xs`, `bg-primary` when on, `bg-input` (dark `bg-input/80`) when
/// off; the `size-4` thumb is `bg-background` (dark: `bg-foreground` off,
/// `bg-primary-foreground` on). Truthy model values show as on.
class ShadSwitch extends StatelessWidget {
  const ShadSwitch({super.key, required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final track = value ? primary : (dark ? context.inputColor.withValues(alpha: 0.8) : context.inputColor);
    final thumb = dark ? (value ? AppColors.darkPrimaryForeground : AppColors.darkForeground) : AppColors.background;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 18.4,
          padding: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: track,
            borderRadius: BorderRadius.circular(999),
            boxShadow: AppShadows.xs,
          ),
          child: AnimatedAlign(
            duration: const Duration(milliseconds: 150),
            alignment: value ? Alignment.centerRight : Alignment.centerLeft,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(color: thumb, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }
}

/// The hand-made switch of `EditExams.vue`: a `<label class="inline-flex
/// items-center cursor-pointer">` holding the `w-11 h-6 bg-gray-200` track
/// (`peer-checked:bg-blue-600 transition duration-300`) and a `FormLabel`
/// (`text-sm leading-none font-medium`). The knob's
/// `peer-checked:translate-x-5` never applies on the web (the knob is not a
/// sibling of the checkbox), so only the track colour changes — kept.
/// [gap] is the label's `gap-*` (none on most toggles).
class WebToggle extends StatelessWidget {
  const WebToggle({
    super.key,
    required this.checked,
    required this.onChanged,
    required this.label,
    this.gap = 0,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final String label;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final track = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 44,
      height: 24,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: checked ? Tw.blue600 : Tw.gray200,
        borderRadius: BorderRadius.circular(999),
      ),
      // `w-5 h-5 bg-white rounded-full shadow`
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppShadows.base),
      ),
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!checked),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            track,
            SizedBox(width: gap),
            Flexible(
              child: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1)),
            ),
          ],
        ),
      ),
    );
  }
}

/// `<img :src>` for a remote URL, a `file://` URI (picked locally) or a
/// `data:` URL; a broken image shows the browser-like broken icon.
class ExmImage extends StatelessWidget {
  const ExmImage(this.src, {super.key, this.fit = BoxFit.contain});
  final String src;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    Widget broken(BuildContext _, Object _, StackTrace? _) =>
        const Center(child: Icon(Icons.broken_image_outlined, size: 32, color: Tw.gray400));
    if (src.startsWith('file://')) {
      return Image.file(File(Uri.parse(src).toFilePath()), fit: fit, errorBuilder: broken);
    }
    if (src.startsWith('data:')) {
      try {
        final bytes = UriData.parse(src).contentAsBytes();
        return Image.memory(bytes, fit: fit, errorBuilder: broken);
      } catch (_) {
        return broken(context, const FormatException(), null);
      }
    }
    final uri = Uri.tryParse(src);
    if (uri == null || !uri.hasScheme) return broken(context, const FormatException(), null);
    return Image.network(src, fit: fit, errorBuilder: broken);
  }
}

/// The "Student Attempts" table of `ViewExams.vue` / `ExamAttempts.vue`
/// (inside `<Card class="m-4 p-0">`; the table keeps `text-sm` at every
/// width). The web reads `attempt.student.*` unguarded (a missing student
/// breaks the page); here it renders blanks.
class ExamAttemptsTable extends StatelessWidget {
  const ExamAttemptsTable({super.key, required this.attempts, required this.onView});

  final List<dynamic> attempts;
  final ValueChanged<Object?> onView;

  @override
  Widget build(BuildContext context) {
    return AppTable(
      fontSize: 14,
      emptyText: 'No attempts found',
      // `text-center py-6 text-gray-500`
      emptyPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      columns: const [
        AppTableColumn('Student', flex: 1.8),
        AppTableColumn('Attempt', flex: 0.8),
        AppTableColumn('Score'),
        AppTableColumn('Status'),
        AppTableColumn('Started', flex: 1.6),
        AppTableColumn('Submitted', flex: 1.6),
        AppTableColumn('Actions', flex: 0.8),
      ],
      rows: [
        for (final raw in attempts)
          () {
            final a = asMap(raw) ?? const <String, dynamic>{};
            final student = asMap(a['student']);
            return <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${vueText(student?['first_name'])} ${vueText(student?['last_name'])}'),
                  // `text-sm text-gray-500`
                  Text(vueText(student?['email']), style: const TextStyle(fontSize: 14, color: Tw.gray500)),
                ],
              ),
              Text(vueText(a['attempt_number'])),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${vueText(a['total_score'])} / ${vueText(a['max_score'])}'),
                  Text('${jsToFixed(jsNumberField(a, 'percentage') * 100, 0)}%'),
                ],
              ),
              Text(vueText(a['status'])),
              Text(jsLocaleStringField(a, 'start_time')),
              Text(jsLocaleStringField(a, 'end_time')),
              // `<i class="bi bi-eye-fill text-blue-600 cursor-pointer">` (18px in a table).
              TableActionIcon(
                icon: BootstrapIcons.eye_fill,
                color: Tw.blue600,
                onTap: () => onView(a['id']),
              ),
            ];
          }(),
      ],
    );
  }
}
