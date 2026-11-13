import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import 'schedule_exam_logic.dart';

/// Widgets shared by the `scheduleexam.vue` / `scheduleexamlist.vue` ports.

/// `{{ value }}` — Vue renders null/undefined as ''.
String vueText(Object? v) => v == null ? '' : jsStr(v);

/// shadcn `<Card class="p-4">` (`flex flex-col gap-6 rounded-xl border
/// shadow-sm`) with an optional background override (`bg-gray-50`).
class ExamCard extends StatelessWidget {
  const ExamCard({super.key, required this.children, this.color});

  final List<Widget> children;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color ?? (dark ? AppColors.darkCard : AppColors.card),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? AppColors.darkBorder : AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3, offset: const Offset(0, 1)),
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 2,
              spreadRadius: -1,
              offset: const Offset(0, 1)),
        ],
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: dark ? AppColors.darkForeground : AppColors.foreground),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) const SizedBox(height: 24),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// `<CardTitle>` (`leading-none font-semibold`), optionally `text-primary`
/// and with the red `after:content-['*']`; [bottom] = `mb-4`.
class ExamCardTitle extends StatelessWidget {
  const ExamCardTitle(this.text, {super.key, this.primary = false, this.required = false, this.bottom = 0});

  final String text;
  final bool primary;
  final bool required;
  final double bottom;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: Text.rich(
        TextSpan(
          text: text,
          children: [
            if (required) const TextSpan(text: ' *', style: TextStyle(color: Tw.red500)),
          ],
        ),
        style: TextStyle(
          fontSize: 16,
          height: 1,
          fontWeight: FontWeight.w600,
          color: primary ? context.colors.primary : null,
        ),
      ),
    );
  }
}

/// `text-muted-foreground` (`--muted-foreground`: #1f2430 light, #9db1d4 dark).
Color examMuted(BuildContext context) =>
    context.isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;

/// `text-center text-sm text-muted-foreground py-6`
class ExamEmptyNote extends StatelessWidget {
  const ExamEmptyNote(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    final muted = examMuted(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: muted)),
    );
  }
}

/// `<Button variant="ghost" size="icon" class="hover:bg-gray-50|100"><i
/// class="bi bi-trash3-fill text-red-500"/>` ([hoverColor]: gray-50 on a
/// section, gray-100 on a rule).
class ExamTrashButton extends StatelessWidget {
  const ExamTrashButton({super.key, required this.onPressed, this.hoverColor = Tw.gray50});
  final VoidCallback onPressed;
  final Color hoverColor;

  @override
  Widget build(BuildContext context) => AppButton(
        icon: BootstrapIcons.trash3_fill,
        variant: AppButtonVariant.ghost,
        size: AppButtonSize.icon,
        foregroundColor: Tw.red500,
        hoverForegroundColor: Tw.red500,
        hoverBackgroundColor: context.isDark ? AppColors.accent.withValues(alpha: 0.5) : hoverColor,
        onPressed: onPressed,
      );
}

/// The hand-made switch (`w-11 h-6 bg-gray-200 peer-checked:bg-blue-600`).
/// On the web the knob's `peer-checked:translate-x-5` never applies (the
/// knob is not a sibling of the checkbox), so only the track colour changes
/// — kept as on the web.
class ExamWebToggle extends StatelessWidget {
  const ExamWebToggle({super.key, required this.value, required this.onChanged, required this.label});

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onChanged(!value),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 44,
              height: 24,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: value ? Tw.blue600 : Tw.gray200,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1), blurRadius: 3, offset: const Offset(0, 1)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

/// One selectable question of "Select Questions": `flex gap-4 items-start
/// border rounded-md p-4 bg-white hover:bg-blue-50`, `border-blue-500` when
/// selected (the selected `bg-blue-50` loses to `bg-white` in the Tailwind
/// output, so only the border changes). No dark variants on the web.
class ExamQuestionRow extends StatefulWidget {
  const ExamQuestionRow({super.key, required this.question, required this.selected, required this.onTap});

  final Map<String, dynamic> question;
  final bool selected;
  final VoidCallback onTap;

  @override
  State<ExamQuestionRow> createState() => _ExamQuestionRowState();
}

class _ExamQuestionRowState extends State<ExamQuestionRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final q = widget.question;
    final dark = context.isDark;
    final options = [for (final o in asList(q['options'])) ?asMap(o)];
    final border = widget.selected ? Tw.blue500 : (dark ? AppColors.darkBorder : AppColors.border);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _hover ? Tw.blue50 : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Custom BIG checkbox (`w-6 h-6 rounded-md border-2`).
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(top: 4),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: widget.selected ? Tw.blue600 : null,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: widget.selected ? Tw.blue600 : Tw.gray400, width: 2),
                ),
                child: widget.selected
                    ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(vueText(q['stem']),
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    DefaultTextStyle.merge(
                      style: const TextStyle(fontSize: 12, color: Tw.gray500),
                      child: Wrap(
                        spacing: 16,
                        children: [
                          Text('Type: ${vueText(q['question_type'])}'),
                          Text('Difficulty: ${vueText(q['difficulty_level'])}'),
                          Text('Marks: ${vueText(q['marks'])}'),
                        ],
                      ),
                    ),
                    if (options.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      for (var i = 0; i < options.length; i++)
                        Padding(
                          padding: EdgeInsets.only(top: i == 0 ? 0 : 4),
                          child: Text(
                            '${vueText(options[i]['option_label'])}. ${vueText(options[i]['option_text'])}',
                            style: jsTruthy(options[i]['is_correct'])
                                ? const TextStyle(
                                    fontSize: 14, color: Tw.green600, fontWeight: FontWeight.w500)
                                : const TextStyle(fontSize: 14),
                          ),
                        ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
