import 'dart:ui';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'app_button.dart';
import 'lucide_icon.dart';

/// shadcn `<DialogContent>` (`src/components/ui/dialog/DialogContent.vue`):
/// frosted `bg-white/90 dark:bg-slate-900/90 backdrop-blur-xl`, `border
/// border-white/40 dark:border-slate-800/80`, `rounded-[20px]`, `p-6`,
/// `gap-4`, `sm:max-w-lg`, `shadow-2xl`, zoom-in-95 on open, and the close
/// button top-right (`top-4 right-4 rounded-xl p-1.5`, X 16px).
///
/// [title]/[description] form the `<DialogHeader>` (`gap-2`, centred below
/// 640px). [child] scrolls when the dialog is taller than the screen;
/// [actions] are the `<DialogFooter>` (right-aligned on ≥640px, stacked
/// below with the last action on top).
class AppDialogFrame extends StatelessWidget {
  const AppDialogFrame({
    super.key,
    this.title,
    this.description,
    this.child,
    this.actions = const [],
    this.maxWidth = 512,
    this.showClose = true,
    this.padding = const EdgeInsets.all(24),
    this.backgroundColor,
    this.borderColor,
    this.radius = 20,
    this.widthFactor,
    this.stackActionsOnMobile = true,
    this.actionsGap = 16,
    this.centerHeaderOnMobile,
    this.shadow,
    this.insetPadding = const EdgeInsets.all(16),
  });

  final String? title;
  final String? description;
  final Widget? child;
  final List<Widget> actions;

  /// `sm:max-w-lg` = 512. Pass e.g. 384 for `sm:max-w-sm`, 672 for `max-w-2xl`.
  final double maxWidth;
  final bool showClose;
  final EdgeInsetsGeometry padding;

  /// `bg-…` / `dark:bg-…` override for the current mode (e.g. the delete
  /// dialogs' `dark:bg-primary-foreground`). A solid colour drops the frost.
  final Color? backgroundColor;

  /// `border-…` override for the current mode.
  final Color? borderColor;

  /// `rounded-…` override (e.g. 16 for `rounded-2xl`).
  final double radius;

  /// `w-[90%]` etc.: the dialog is this fraction of the screen width
  /// (still capped by [maxWidth]).
  final double? widthFactor;

  /// `false` when the page puts its buttons in a plain `flex justify-end gap-2`
  /// row instead of a `<DialogFooter>` (no stacking on phones).
  final bool stackActionsOnMobile;

  /// Space above [actions] (`gap-4` = 16; a `mt-4` on the button row adds 16).
  final double actionsGap;

  /// `<DialogHeader>` centres its text below 640px; defaults to on when
  /// there is a [title] (a bare `<DialogDescription>` isn't centred).
  final bool? centerHeaderOnMobile;

  /// `shadow-…` override (default `shadow-2xl` = `0 1px 3px rgb(0 0 0/.25)`).
  final List<BoxShadow>? shadow;

  /// Space kept around the dialog (`max-w-[calc(100%-2rem)]` = 16); pass
  /// [EdgeInsets.zero] for full-screen dialogs (`!w-full !h-screen !m-0`).
  final EdgeInsets insetPadding;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final muted = context.mutedFgColor;
    final wide = context.isSm;
    final centered = !wide && (centerHeaderOnMobile ?? title != null);
    final align = centered ? CrossAxisAlignment.center : CrossAxisAlignment.start;
    final textAlign = centered ? TextAlign.center : TextAlign.start;

    Widget? footer;
    if (actions.isNotEmpty) {
      footer = wide || !stackActionsOnMobile
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  actions[i],
                ],
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // flex-col-reverse: the last action on top.
                for (var i = actions.length - 1; i >= 0; i--) ...[
                  actions[i],
                  if (i > 0) const SizedBox(height: 8),
                ],
              ],
            );
    }

    final bg = backgroundColor ?? (dark ? Tw.slate900.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.9));
    final frosted = bg.a < 1;
    final screenW = MediaQuery.sizeOf(context).width;
    final width = widthFactor == null ? null : screenW * widthFactor!;
    final hasHeader = title != null || description != null;

    Widget frame = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor ?? (dark ? Tw.slate800.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.4)),
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasHeader)
                  Column(
                    crossAxisAlignment: align,
                    children: [
                      if (title != null)
                        Padding(
                          padding: EdgeInsets.only(right: showClose && !centered ? 28 : 0),
                          child: Text(
                            title!,
                            textAlign: textAlign,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1),
                          ),
                        ),
                      if (description != null) ...[
                        if (title != null) const SizedBox(height: 8),
                        Padding(
                          padding: EdgeInsets.only(right: title == null && showClose ? 28 : 0),
                          child: Text(
                            description!,
                            textAlign: textAlign,
                            style: TextStyle(fontSize: 14, height: 20 / 14, color: muted),
                          ),
                        ),
                      ],
                    ],
                  ),
                if (child != null) ...[
                  if (hasHeader) const SizedBox(height: 16),
                  Flexible(child: SingleChildScrollView(child: child)),
                ],
                if (footer != null) ...[
                  if (hasHeader || child != null) SizedBox(height: actionsGap),
                  footer,
                ],
              ],
            ),
          ),
          if (showClose) const Positioned(top: 16, right: 16, child: DialogCloseButton()),
        ],
      ),
    );
    if (frosted) {
      frame = ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        // backdrop-blur-xl (24px)
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24), child: frame),
      );
    }

    // shadow-2xl (style.css: `0 1px 3px 0 rgb(0 0 0 / .25)`).
    frame = DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), boxShadow: shadow ?? AppShadows.xl2),
      child: frame,
    );

    // zoom-in-95 (the route itself fades in).
    final animation = ModalRoute.of(context)?.animation;
    if (animation != null) {
      frame = ScaleTransition(
        scale: Tween(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: frame,
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      // max-w-[calc(100%-2rem)]
      insetPadding: insetPadding,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: width == null ? frame : SizedBox(width: width, child: frame),
      ),
    );
  }
}

/// `<DialogClose>`: `rounded-xl p-1.5 text-slate-400 hover:text-slate-700
/// hover:bg-slate-100` (dark: `text-slate-500 hover:text-slate-200
/// hover:bg-slate-800/50`) with lucide `X` (16px).
class DialogCloseButton extends StatefulWidget {
  const DialogCloseButton({super.key, this.onPressed});

  /// Defaults to popping the dialog.
  final VoidCallback? onPressed;

  @override
  State<DialogCloseButton> createState() => _DialogCloseButtonState();
}

class _DialogCloseButtonState extends State<DialogCloseButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final color = _hover ? (dark ? Tw.slate200 : Tw.slate700) : (dark ? Tw.slate500 : Tw.slate400);
    return Semantics(
      button: true,
      label: 'Close',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onPressed ?? () => Navigator.of(context).maybePop(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _hover ? (dark ? Tw.slate800.withValues(alpha: 0.5) : Tw.slate100) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
            ),
            child: LucideIcon(Lucide.x, size: 16, color: color),
          ),
        ),
      ),
    );
  }
}

/// Opens a [AppDialogFrame]-style dialog over the shadcn `<DialogOverlay>`
/// (`bg-black/45 dark:bg-black/65 backdrop-blur-xs`, 200ms). Use a
/// `StatefulBuilder` (or a StatefulWidget) inside [builder] when the dialog
/// has its own state. Esc and a click outside close it (when
/// [barrierDismissible]).
Future<T?> showAppDialog<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool barrierDismissible = true,
}) {
  final dark = context.isDark;
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    barrierColor: Colors.black.withValues(alpha: dark ? 0.65 : 0.45),
    animationStyle: const AnimationStyle(duration: Duration(milliseconds: 200)),
    builder: (ctx) => Stack(
      children: [
        // backdrop-blur-xs (4px); taps go through to the barrier.
        Positioned.fill(
          child: IgnorePointer(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
              child: const SizedBox.expand(),
            ),
          ),
        ),
        builder(ctx),
      ],
    ),
  );
}

/// The delete/confirm dialogs used across the web lists:
/// `<DialogContent class="w-[90%] sm:max-w-sm dark:bg-primary-foreground">`
/// with a `<DialogDescription>` and a `flex justify-end gap-2 mt-4` row of
/// `Cancel` (outline) + `Delete` (`bg-red-600 text-white`).
/// Resolves to `true` only when confirmed.
Future<bool> showConfirmDialog(
  BuildContext context, {
  required String message,
  String? title,
  String confirmLabel = 'Delete',
  String cancelLabel = 'Cancel',
  bool destructive = true,
  double maxWidth = 384,
}) async {
  final ok = await showAppDialog<bool>(
    context,
    builder: (ctx) => AppDialogFrame(
      title: title,
      description: message,
      maxWidth: maxWidth,
      widthFactor: 0.9,
      backgroundColor: ctx.isDark ? AppColors.darkPrimaryForeground : null,
      stackActionsOnMobile: false,
      actionsGap: 32,
      actions: [
        AppButton(
          label: cancelLabel,
          variant: AppButtonVariant.outline,
          onPressed: () => Navigator.of(ctx).pop(false),
        ),
        AppButton(
          label: confirmLabel,
          backgroundColor: destructive ? Tw.red600 : null,
          foregroundColor: destructive ? Colors.white : null,
          onPressed: () => Navigator.of(ctx).pop(true),
        ),
      ],
    ),
  );
  return ok ?? false;
}
