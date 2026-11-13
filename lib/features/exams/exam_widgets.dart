import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';

/// Tailwind colours used by the exam screens (now the v4 values of [Tw];
/// kept as aliases for the screens that still refer to them).
class ExTw {
  ExTw._();
  static const sky200 = Tw.sky200;
  static const sky700 = Tw.sky700;
  static const sky800 = Tw.sky800;
  static const blue200 = Tw.blue200;
  static const blue800 = Tw.blue800;
  static const emerald800 = Tw.emerald800;
  static const amber100 = Tw.amber100;
  static const amber800 = Tw.amber800;
  static const orange100 = Tw.orange100;
  static const orange200 = Tw.orange200;
  static const orange700 = Tw.orange700;
  static const orange800 = Tw.orange800;
  static const rose100 = Tw.rose100;
  static const rose400 = Tw.rose400;
  static const rose700 = Tw.rose700;
  static const rose800 = Tw.rose800;
  static const violet50 = Tw.violet50;
  static const violet700 = Tw.violet700;
  static const cyan100 = Tw.cyan100;
  static const cyan200 = Tw.cyan200;
  static const cyan400 = Tw.cyan400;
  static const cyan600 = Tw.cyan600;
  static const red50 = Tw.red50;
  static const green50 = Tw.green50;
  static const green200 = Tw.green200;
  static const green700 = Tw.green700;
}

/// shadcn tokens (`src/style.css`) the exam screens use directly.
extension ExamTokens on BuildContext {
  /// `bg-card`
  Color get exCard => isDark ? AppColors.darkCard : AppColors.card;

  /// `bg-muted`
  Color get exMuted => isDark ? AppColors.darkMuted : AppColors.muted;

  /// `text-muted-foreground` (#1f2430 in light mode — same as the text).
  Color get exMutedFg => isDark ? AppColors.darkMutedForeground : AppColors.foreground;

  /// `text-foreground`
  Color get exFg => isDark ? AppColors.darkForeground : AppColors.foreground;

  /// `border` / `border-border`
  Color get exBorder => isDark ? AppColors.darkBorder : AppColors.border;
}

/// shadcn `<Card>`: `bg-card rounded-xl border shadow-sm` (+ the padding the
/// template sets). `flex flex-col gap-6` is left to the caller.
class ExamCard extends StatelessWidget {
  const ExamCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
    this.margin = EdgeInsets.zero,
    this.color,
    this.clip = false,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;

  /// Overrides `bg-card` (e.g. `bg-gray-50`, which has no dark variant).
  final Color? color;

  /// `overflow-hidden`
  final bool clip;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: color ?? context.exCard,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: context.exBorder),
        boxShadow: AppShadows.sm,
      ),
      child: DefaultTextStyle.merge(style: TextStyle(color: context.exFg), child: child),
    );
  }
}

/// `flex flex-col gap-N` — children separated by [gap].
class GapColumn extends StatelessWidget {
  const GapColumn({
    super.key,
    required this.children,
    this.gap = 24,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
  });

  final List<Widget> children;
  final double gap;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            children[i],
          ],
        ],
      );
}

/// The web's hand-made switch (`<input class="sr-only peer">` + a
/// `w-11 h-6 bg-gray-200 peer-checked:bg-blue-600` track). The knob's
/// `peer-checked:translate-x-5` never applies (the knob is not a sibling of
/// the input), so it stays on the left — kept from the web.
class WebToggle extends StatelessWidget {
  const WebToggle({super.key, required this.value, required this.onChanged, this.duration = 150});
  final bool value;
  final ValueChanged<bool> onChanged;

  /// `transition` (150 ms) or `duration-300`.
  final int duration;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        child: AnimatedContainer(
          duration: Duration(milliseconds: duration),
          width: 44,
          height: 24,
          padding: const EdgeInsets.all(2),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: value ? Tw.blue600 : Tw.gray200,
            borderRadius: BorderRadius.circular(999),
          ),
          // `w-5 h-5 bg-white rounded-full shadow`
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppShadows.base),
          ),
        ),
      ),
    );
  }
}

/// shadcn `<Label>` (`text-sm leading-none font-medium`), optionally with the
/// red `after:content-['*'] after:ml-1`. The kit's label is `flex gap-2`, so
/// the asterisk sits 12px after the text; with `class="block"` only the
/// `ml-1` (4px) remains ([block]).
class ExamFieldLabel extends StatelessWidget {
  const ExamFieldLabel(this.text, {super.key, this.required = false, this.block = false, this.color});

  final String text;
  final bool required;
  final bool block;

  /// e.g. `text-muted-foreground`.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1, color: color);
    if (!required) return Text(text, style: style);
    return Text.rich(
      TextSpan(children: [
        TextSpan(text: text),
        WidgetSpan(child: SizedBox(width: block ? 4 : 12)),
        const TextSpan(text: '*', style: TextStyle(color: Tw.red500)),
      ]),
      style: style,
    );
  }
}

/// A native `<label class="text-sm font-medium">` on a line of its own: the
/// line box keeps the parent's 16px / 24px strut, so it is 24px tall and
/// the control follows right below it.
class ExamNativeLabel extends StatelessWidget {
  const ExamNativeLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 24,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14)),
        ),
      );
}

/// `<Button variant="ghost" size="icon" class="hover:bg-gray-50">` with
/// `<i class="bi bi-trash3-fill text-red-500">` (14px, the button's
/// `text-sm`). The page's `hover:bg-gray-50` replaces the light hover;
/// dark mode keeps the kit's `dark:hover:bg-accent/50`.
class ExamTrashButton extends StatelessWidget {
  const ExamTrashButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppButton(
        icon: BootstrapIcons.trash3_fill,
        iconSize: 14,
        variant: AppButtonVariant.ghost,
        size: AppButtonSize.icon,
        foregroundColor: Tw.red500,
        hoverForegroundColor: Tw.red500,
        hoverBackgroundColor: context.isDark ? AppColors.accent.withValues(alpha: 0.5) : Tw.gray50,
        onPressed: onPressed,
      );
}

/// `<Button variant="ghost" class="flex items-center gap-1 text-primary
/// hover:bg-blue-100 px-2 py-1 rounded-sm"><i class="bi bi-plus text-lg"/>
/// Add Rule</Button>`.
class ExamAddRuleButton extends StatelessWidget {
  const ExamAddRuleButton({super.key, required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppButton(
        variant: AppButtonVariant.ghost,
        foregroundColor: context.colors.primary,
        hoverBackgroundColor: context.isDark ? AppColors.accent.withValues(alpha: 0.5) : Tw.blue100,
        radius: AppTheme.radiusSm,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        onPressed: onPressed,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(BootstrapIcons.plus, size: 18),
            SizedBox(width: 4),
            Flexible(child: Text('Add Rule', maxLines: 1, overflow: TextOverflow.ellipsis)),
          ],
        ),
      );
}

/// The date pickers' trigger: `<Button variant="outline" class="w-full
/// justify-start text-left font-normal">`.
class ExamDateButton extends StatelessWidget {
  const ExamDateButton({super.key, required this.text, required this.onPressed});
  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => AppButton(
        variant: AppButtonVariant.outline,
        expand: true,
        fontWeight: FontWeight.w400,
        onPressed: onPressed,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      );
}

/// `<input type="file" accept="image/*">`. Tailwind's preflight strips the
/// "Choose File" button to plain text (`margin-inline-end: 4px`).
///
/// * default: the page's native input (`class="border rounded-md p-2
///   w-full"`, inherited 16px text);
/// * [shadcn]: the kit's `<Input type="file">` (`h-9 px-3 py-1 shadow-xs`,
///   `file:text-sm file:font-medium`, `text-base md:text-sm`).
class ExamFileInput extends StatelessWidget {
  const ExamFileInput({super.key, required this.onPick, this.fileName, this.shadcn = false});
  final VoidCallback onPick;
  final String? fileName;
  final bool shadcn;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final textSize = shadcn ? (context.isMd ? 14.0 : 16.0) : 16.0;
    final row = Row(
      children: [
        Text(
          'Choose File',
          style: shadcn
              ? const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14)
              : const TextStyle(fontSize: 16, height: 1.5),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            fileName ?? 'No file chosen',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: textSize, height: textSize == 14 ? 20 / 14 : 1.5),
          ),
        ),
      ],
    );
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onPick,
        behavior: HitTestBehavior.opaque,
        child: Container(
          height: shadcn ? 36 : null,
          padding: shadcn ? const EdgeInsets.symmetric(horizontal: 12) : const EdgeInsets.all(8),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: shadcn && dark ? context.inputColor.withValues(alpha: 0.3) : null,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: shadcn ? context.inputColor : context.borderColor),
            boxShadow: shadcn ? AppShadows.xs : null,
          ),
          child: DefaultTextStyle.merge(style: TextStyle(color: context.fgColor), child: row),
        ),
      ),
    );
  }
}

/// The exam image preview: `relative w-full h-48 border rounded-md bg-white
/// flex items-center justify-center` with the image (`max-h-full max-w-full
/// object-contain`) and the `absolute top-2 right-2 text-red-500
/// hover:text-red-700` trash button (`title="Remove image"`, 18px icon).
class ExamImagePreview extends StatelessWidget {
  const ExamImagePreview({super.key, required this.image, required this.onRemove});
  final Widget image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 192,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: context.borderColor),
      ),
      child: Stack(
        children: [
          Positioned.fill(child: Padding(padding: const EdgeInsets.all(1), child: Center(child: image))),
          Positioned(top: 8, right: 8, child: _RemoveImageButton(onTap: onRemove)),
        ],
      ),
    );
  }
}

class _RemoveImageButton extends StatefulWidget {
  const _RemoveImageButton({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_RemoveImageButton> createState() => _RemoveImageButtonState();
}

class _RemoveImageButtonState extends State<_RemoveImageButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => Tooltip(
        message: 'Remove image',
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: widget.onTap,
            child: Icon(BootstrapIcons.trash3_fill, size: 18, color: _hover ? Tw.red700 : Tw.red500),
          ),
        ),
      );
}

/// shadcn `<TabsList class="w-full h-12 p-1">` (`bg-muted rounded-lg`) with
/// `flex-1` `<TabsTrigger>`s: `rounded-md border border-transparent px-2
/// py-1 text-sm font-medium`; the active one `bg-background shadow-sm`
/// (dark: `bg-input/30 border-input text-foreground`), the others
/// `text-foreground` (dark: `text-muted-foreground`).
class ExamTabs extends StatelessWidget {
  const ExamTabs({super.key, required this.tabs, required this.value, required this.onChanged});

  /// (value, label)
  final List<(String, String)> tabs;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: context.mutedColor, borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
      child: Row(
        children: [
          for (final (v, label) in tabs)
            Expanded(
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onChanged(v),
                  child: Align(
                    alignment: Alignment.topCenter,
                    // `h-[calc(100%-1px)]`
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 39,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: v == value
                            ? (dark ? context.inputColor.withValues(alpha: 0.3) : AppColors.background)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        border: Border.all(color: v == value && dark ? context.inputColor : Colors.transparent),
                        boxShadow: v == value ? AppShadows.sm : null,
                      ),
                      child: Text(
                        label,
                        maxLines: 1,
                        softWrap: false,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          height: 20 / 14,
                          fontWeight: FontWeight.w500,
                          color: dark
                              ? (v == value ? AppColors.darkForeground : AppColors.darkMutedForeground)
                              : AppColors.foreground,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// `bg-blue-50 border border-blue-300 rounded-sm p-2 flex gap-2` +
/// `bi-info-circle-fill text-blue-400 text-xl` + `text-blue-500` text (no
/// dark variants on the web).
class ExamInfoNote extends StatelessWidget {
  const ExamInfoNote(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Tw.blue50,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(color: Tw.blue300),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // A 20px glyph on the 28px line of `text-xl`.
          const SizedBox(
            height: 28,
            child: Center(child: Icon(BootstrapIcons.info_circle_fill, size: 20, color: Tw.blue400)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 16, color: Tw.blue500, height: 1.5))),
        ],
      ),
    );
  }
}
