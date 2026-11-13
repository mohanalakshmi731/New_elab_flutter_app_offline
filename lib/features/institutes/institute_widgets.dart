import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/form_fields.dart' show appMenuItemStyle;
import '../../widgets/lucide_icon.dart';

/// Small building blocks for the institute screens that the shared widgets
/// don't cover (multi-select, `<input type=file>`, `<TabsList>`, spinner).
/// Feature-local on purpose.

/// `<i class="bi bi-arrow-repeat animate-spin">`
class SpinIcon extends StatefulWidget {
  const SpinIcon({super.key, this.size = 16, this.color});
  final double size;
  final Color? color;

  @override
  State<SpinIcon> createState() => _SpinIconState();
}

class _SpinIconState extends State<SpinIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(
        turns: _c,
        child: Icon(BootstrapIcons.arrow_repeat, size: widget.size, color: widget.color),
      );
}

/// `<Label>Text <span class="text-red-500 [text-lg]">*</span></Label>` — the
/// label is `flex gap-2`, so the star sits 8px after the text.
class StarLabel extends StatelessWidget {
  const StarLabel(
    this.text, {
    super.key,
    this.star = true,
    this.bigStar = true,
    this.style,
    this.starLineHeight,
  });
  final String text;
  final bool star;

  /// `text-lg` star.
  final bool bigStar;
  final TextStyle? style;

  /// Line height (px) of the star. A `text-lg` span keeps its own 28px line
  /// inside a `leading-none` label (Tailwind's `--tw-leading` isn't
  /// inherited), which makes the label 28px tall; pass 28 for that. Default:
  /// the label's `leading-none`.
  final double? starLineHeight;

  @override
  Widget build(BuildContext context) {
    final base = const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1).merge(style);
    final starSize = bigStar ? 18.0 : 14.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(child: Text(text, style: base)),
        if (star) ...[
          const SizedBox(width: 8),
          Text(
            '*',
            style: base.copyWith(
              color: Tw.red500,
              fontSize: starSize,
              height: starLineHeight == null ? null : starLineHeight! / starSize,
            ),
          ),
        ],
      ],
    );
  }
}

/// shadcn `<Input type="file">`: "Choose File" + the picked file name.
class FilePickField extends StatelessWidget {
  const FilePickField({super.key, required this.onPick, this.fileName, this.height = 36});
  final VoidCallback onPick;
  final String? fileName;

  /// `h-9` = 36; pass 40 for `class="h-10"`.
  final double height;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final border = dark ? AppColors.darkBorder : AppColors.border;
    final muted = dark ? AppColors.darkMutedForeground : Tw.slate500;
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: height,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: dark ? AppColors.darkBorder.withValues(alpha: 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            const Text('Choose File', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                fileName ?? 'No file chosen',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, color: fileName == null ? muted : null),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// `<Select multiple>`: the menu stays open while toggling; selected items
/// show a check. [text] is what `<SelectValue>` displays.
///
/// Same trigger and menu as [AppSelect] (shadcn `<SelectTrigger class="w-full">`:
/// `h-9 rounded-md border-input px-3 text-sm shadow-xs`, dark `bg-input/30`
/// (hover `/50`), placeholder #9ca3af, lucide chevron `opacity-50`; content
/// `bg-popover rounded-md border p-1 shadow-md`, items turn `bg-accent`).
class MultiSelectField<T> extends StatefulWidget {
  const MultiSelectField({
    super.key,
    required this.values,
    required this.items,
    required this.onChanged,
    required this.text,
    this.isPlaceholder = false,
    this.menuMaxHeight = 320,
  });

  final List<T> values;
  final List<(T, String)> items;
  final ValueChanged<List<T>> onChanged;
  final String text;
  final bool isPlaceholder;
  final double menuMaxHeight;

  @override
  State<MultiSelectField<T>> createState() => _MultiSelectFieldState<T>();
}

class _MultiSelectFieldState<T> extends State<MultiSelectField<T>> {
  final _menu = MenuController();
  bool _focused = false;
  bool _hovered = false;

  void _toggle(T value) {
    final next = widget.values.contains(value)
        ? [for (final v in widget.values) if (v != value) v]
        : [...widget.values, value];
    widget.onChanged(next);
  }

  void _toggleMenu() => _menu.isOpen ? _menu.close() : _menu.open();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final mutedFg = context.mutedFgColor;
    final input = context.inputColor;
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth.isFinite ? c.maxWidth : 260.0;
        final screenW = MediaQuery.sizeOf(context).width;
        final minW = width < 128 ? 128.0 : width;
        final maxW = screenW - 16 > minW ? screenW - 16 : minW;
        return MenuAnchor(
          controller: _menu,
          crossAxisUnconstrained: false,
          alignmentOffset: const Offset(0, 4),
          style: MenuStyle(
            minimumSize: WidgetStatePropertyAll(Size(minW, 0)),
            maximumSize: WidgetStatePropertyAll(Size(maxW, widget.menuMaxHeight)),
            backgroundColor: WidgetStatePropertyAll(context.popoverColor),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            elevation: const WidgetStatePropertyAll(2),
            shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.5)),
            padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                side: BorderSide(color: context.borderColor),
              ),
            ),
          ),
          menuChildren: [
            for (final (value, label) in widget.items)
              MenuItemButton(
                closeOnActivate: false,
                onPressed: () => _toggle(value),
                style: appMenuItemStyle(context),
                overflowAxis: Axis.vertical,
                child: Row(
                  children: [
                    Expanded(child: Text(label)),
                    const SizedBox(width: 10),
                    // `absolute right-2 size-3.5` check indicator.
                    SizedBox.square(
                      dimension: 14,
                      child: widget.values.contains(value)
                          ? OverflowBox(
                              maxWidth: 16,
                              maxHeight: 16,
                              child: LucideIcon(Lucide.check, size: 16, color: mutedFg),
                            )
                          : null,
                    ),
                  ],
                ),
              ),
          ],
          builder: (context, controller, _) {
            final showRing = _focused;
            final textColor = widget.isPlaceholder ? AppColors.placeholder : context.colors.onSurface;
            return FocusableActionDetector(
              mouseCursor: SystemMouseCursors.click,
              onShowFocusHighlight: (v) => setState(() => _focused = v),
              onShowHoverHighlight: (v) => setState(() => _hovered = v),
              actions: {
                ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
                  _toggleMenu();
                  return null;
                }),
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _toggleMenu,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: dark ? input.withValues(alpha: _hovered ? 0.5 : 0.3) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: showRing ? context.ringColor : input),
                    boxShadow: [
                      ...AppShadows.xs,
                      if (showRing) BoxShadow(color: context.ringColor.withValues(alpha: 0.5), spreadRadius: 3),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.text,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: textColor),
                        ),
                      ),
                      const SizedBox(width: 8),
                      LucideIcon(Lucide.chevronDown, size: 16, color: mutedFg.withValues(alpha: 0.5)),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

/// shadcn `<TabsList class="grid grid-cols-N gap-2 p-1 h-10 bg-muted">`
/// (`rounded-lg` = 16) with `<TabsTrigger>`s (`rounded-md` = 14, `border
/// border-transparent`, `h-[calc(100%-1px)]`; active: `bg-background
/// shadow-sm`, dark: `bg-primary-foreground text-white border-input`).
class SectionTabs extends StatelessWidget {
  const SectionTabs({super.key, required this.tabs, required this.value, required this.onChanged});
  final List<(String, String)> tabs;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      height: 40,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkMuted : AppColors.muted,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Row(
        children: [
          for (var i = 0; i < tabs.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            Expanded(child: _trigger(context, tabs[i].$1, tabs[i].$2, dark)),
          ],
        ],
      ),
    );
  }

  Widget _trigger(BuildContext context, String v, String label, bool dark) {
    final active = v == value;
    final fg = active
        ? (dark ? Colors.white : AppColors.foreground)
        : (dark ? AppColors.darkMutedForeground : AppColors.foreground);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(v),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          // h-[calc(100%-1px)] of the 32px track, centred.
          margin: const EdgeInsets.symmetric(vertical: 0.5),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: active ? (dark ? AppColors.darkPrimaryForeground : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(color: active && dark ? AppColors.darkInput : Colors.transparent),
            boxShadow: active ? AppShadows.sm : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fg),
          ),
        ),
      ),
    );
  }
}

/// A native-looking `<input type="checkbox" class="accent-primary">` + label.
class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
    this.size = 16,
    this.labelStyle,
    this.nativeStyle = false,
    this.exactSize = false,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;

  /// `h-4 w-4` = 16, `w-5 h-5` = 20.
  final double size;
  final TextStyle? labelStyle;

  /// A plain `<input type="checkbox">` without `accent-primary`: the theme's
  /// native look (#0075ff when checked, 2px corners).
  final bool nativeStyle;

  /// Draws the box at [size] (Material always paints an 18px box, centred in
  /// [size]).
  final bool exactSize;

  @override
  Widget build(BuildContext context) {
    Widget box = Checkbox(
      value: value,
      onChanged: (v) => onChanged(v ?? false),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      activeColor: nativeStyle ? null : context.colors.primary,
      checkColor: nativeStyle ? null : context.colors.onPrimary,
      shape: nativeStyle ? null : RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
    );
    if (exactSize) box = Transform.scale(scale: size / 18, child: box);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: box,
            ),
            const SizedBox(width: 8),
            Flexible(child: Text(label, style: const TextStyle(fontSize: 14).merge(labelStyle))),
          ],
        ),
      ),
    );
  }
}

/// One cell of a [FormGrid]; [fullRow] = `md:col-span-2`.
class FormGridItem {
  const FormGridItem(this.child, {this.fullRow = false});
  final Widget child;
  final bool fullRow;
}

/// `grid grid-cols-1 md:grid-cols-2 gap-4` with CSS auto-placement: a
/// full-row item never shares a row, leaving a hole after a lone item.
class FormGrid extends StatelessWidget {
  const FormGrid({super.key, required this.items, required this.twoColumns, this.gap = 16});
  final List<FormGridItem> items;
  final bool twoColumns;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    if (!twoColumns) {
      rows.addAll(items.map((e) => e.child));
    } else {
      Widget? pending;
      void flush() {
        if (pending == null) return;
        rows.add(_pair(pending!, const SizedBox.shrink()));
        pending = null;
      }

      for (final item in items) {
        if (item.fullRow) {
          flush();
          rows.add(item.child);
        } else if (pending == null) {
          pending = item.child;
        } else {
          rows.add(_pair(pending!, item.child));
          pending = null;
        }
      }
      flush();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          rows[i],
        ],
      ],
    );
  }

  Widget _pair(Widget a, Widget b) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: a), SizedBox(width: gap), Expanded(child: b)],
      );
}

/// `<DialogFooter>`: `flex-col-reverse gap-2 sm:flex-row sm:justify-end`.
class DialogFooterBar extends StatelessWidget {
  const DialogFooterBar({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (context.isSm) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            children[i],
          ],
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = children.length - 1; i >= 0; i--) ...[
          children[i],
          if (i > 0) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Width of a shadcn `<SelectTrigger>` without `w-full` (its default
/// `w-fit`) showing [text]: `px-3` + text (`text-sm`) + `gap-2` + the 16px
/// chevron + `px-3` + the 1px borders. (A `class="w-24"` on `<Select>` itself
/// is dropped by the renderless root, so these triggers are content-sized.)
double selectFitWidth(BuildContext context, String text) {
  final painter = TextPainter(
    text: TextSpan(text: text, style: DefaultTextStyle.of(context).style.merge(const TextStyle(fontSize: 14))),
    textDirection: TextDirection.ltr,
    textScaler: MediaQuery.textScalerOf(context),
    maxLines: 1,
  )..layout();
  final w = painter.width;
  painter.dispose();
  return (w + 50).ceilToDouble();
}

/// Width of a dialog styled `w-[95%] sm:w-[90%] md:w-[x%] …` on top of the
/// shadcn default `max-w-[calc(100%-2rem)] sm:max-w-lg` (512px).
double responsiveDialogWidth(BuildContext context, {required double Function(double w) percent}) {
  final w = context.screenWidth;
  final wanted = percent(w) * w;
  if (w < 640) return wanted;
  return wanted < 512 ? wanted : 512;
}
