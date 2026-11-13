import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../institutes/institute_widgets.dart';

/// A Tailwind-styled button (`bg-x hover:bg-y text-white rounded-xl px-… py-…`)
/// with optional leading icon and the `bi-arrow-repeat animate-spin` state.
class ClassButton extends StatefulWidget {
  const ClassButton({
    super.key,
    required this.onPressed,
    this.label,
    this.child,
    this.icon,
    this.iconSize = 14,
    this.color,
    this.hoverColor,
    this.gradient,
    this.foreground = Colors.white,
    this.radius = 20,
    this.height,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    this.fontSize = 14,
    this.fontWeight = FontWeight.w600,
    this.gap = 8,
    this.busy = false,
    this.disabled = false,
    this.expand = false,
    this.shadow = true,
    this.borderColor,
    this.tooltip,
  });

  final VoidCallback? onPressed;
  final String? label;
  final Widget? child;
  final IconData? icon;
  final double iconSize;

  /// Defaults to `bg-primary`.
  final Color? color;
  final Color? hoverColor;
  final Gradient? gradient;
  final Color foreground;
  final double radius;
  final double? height;
  final EdgeInsetsGeometry padding;
  final double fontSize;
  final FontWeight fontWeight;
  final double gap;

  /// Replaces the content with the spinner (the button stays enabled unless
  /// [disabled] is set, like most of the web's buttons).
  final bool busy;
  final bool disabled;
  final bool expand;
  final bool shadow;
  final Color? borderColor;
  final String? tooltip;

  @override
  State<ClassButton> createState() => _ClassButtonState();
}

class _ClassButtonState extends State<ClassButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final base = w.color ?? context.colors.primary;
    final bg = _hover && !w.disabled ? (w.hoverColor ?? base.withValues(alpha: 0.9)) : base;
    final textStyle = TextStyle(fontSize: w.fontSize, fontWeight: w.fontWeight, color: w.foreground);
    Widget content;
    if (w.busy) {
      content = SpinIcon(size: w.fontSize + 2, color: w.foreground);
    } else {
      content = Row(
        mainAxisSize: w.expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (w.icon != null) Icon(w.icon, size: w.iconSize, color: w.foreground),
          if (w.icon != null && (w.label != null || w.child != null)) SizedBox(width: w.gap),
          if (w.label != null)
            Flexible(child: Text(w.label!, style: textStyle, overflow: TextOverflow.ellipsis))
          else if (w.child != null)
            Flexible(child: DefaultTextStyle.merge(style: textStyle, child: w.child!)),
        ],
      );
    }
    Widget button = MouseRegion(
      cursor: w.disabled || w.onPressed == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: w.disabled ? null : w.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: w.height,
          padding: w.padding,
          alignment: w.height != null || w.expand ? Alignment.center : null,
          decoration: BoxDecoration(
            color: w.gradient == null ? bg : null,
            gradient: w.gradient,
            borderRadius: BorderRadius.circular(w.radius),
            border: w.borderColor == null ? null : Border.all(color: w.borderColor!),
            boxShadow: w.shadow
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3, offset: const Offset(0, 1))]
                : null,
          ),
          child: content,
        ),
      ),
    );
    if (w.disabled) button = Opacity(opacity: 0.5, child: button);
    if (w.expand) button = SizedBox(width: double.infinity, child: button);
    if (w.tooltip != null) button = Tooltip(message: w.tooltip!, child: button);
    return button;
  }
}

/// One item of a [MenuSelect].
class MenuSelectItem<T> {
  const MenuSelectItem(this.value, this.label, {this.icon, this.enabled = true});
  final T value;
  final String label;
  final IconData? icon;

  /// `<SelectItem disabled>` (`data-[disabled]:opacity-50`).
  final bool enabled;
}

/// The theme's `shadow-sm` (`0 1px 3px 0 hsl(0 0% 0% / .1), …`).
const shadowSm = [BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1))];

/// The theme's `shadow-xs` (`0 1px 3px 0 hsl(0 0% 0% / .05)`), shadcn's
/// default on select triggers.
const shadowXs = [BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1))];

/// shadcn `<Select>` with a custom-classed trigger (the class list's switchers,
/// toolbar filters and "Bulk Actions"). [trigger] is the whole trigger content.
///
/// The trigger keeps shadcn's `data-[size=default]:h-9` (36 px): it beats the
/// `h-11` / `h-12` classes the web adds. Items highlight with `focus:bg-accent`.
class MenuSelect<T> extends StatefulWidget {
  const MenuSelect({
    super.key,
    required this.value,
    required this.items,
    required this.onSelected,
    required this.trigger,
    this.groupLabel,
    this.compactLabel = false,
    this.primaryIcons = true,
    this.itemRadius = 12,
    this.itemMargin = false,
    this.hPad = 12,
    this.height = 36,
    this.radius = 20,
    this.fontWeight = FontWeight.w400,
    this.disabled = false,
    this.bg,
    this.borderColor,
    this.textColor,
    this.shadow = shadowXs,
    this.menuBg,
    this.menuBorder,
    this.menuRadius = 14,
    this.menuShadow = false,
  });

  final T? value;
  final List<MenuSelectItem<T>> items;
  final ValueChanged<T> onSelected;
  final Widget trigger;

  /// `<SelectLabel>` above the items (always `uppercase`).
  final String? groupLabel;

  /// `text-xs font-semibold tracking-wider px-2 py-1` ("Bulk actions")
  /// instead of `text-[10px] tracking-widest px-3 pt-2 pb-1` (font-medium).
  final bool compactLabel;

  /// Item icons `text-primary` with `font-medium` labels (the section
  /// switchers), or inheriting the item colour with `mr-2` ("Bulk Actions").
  final bool primaryIcons;

  /// `rounded-sm` (12, shadcn default) / `rounded-lg` (16) / `rounded-xl` (20).
  final double itemRadius;

  /// `mx-1 my-0.5` around the items (the section switchers).
  final bool itemMargin;

  /// Trigger side padding (`px-3` shadcn default / `px-4`).
  final double hPad;
  final double height;
  final double radius;
  final FontWeight fontWeight;
  final bool disabled;

  /// Trigger background; defaults to `bg-white dark:bg-slate-900`.
  final Color? bg;

  /// Trigger border; defaults to `border-slate-200 dark:border-slate-700`.
  final Color? borderColor;

  /// Trigger text; defaults to `text-slate-700 dark:text-slate-200`.
  final Color? textColor;
  final List<BoxShadow>? shadow;

  /// `<SelectContent>` background; defaults to `bg-popover`.
  final Color? menuBg;

  /// `<SelectContent>` border; defaults to the theme `border`.
  final Color? menuBorder;

  /// `rounded-md` (14, shadcn default) / `rounded-xl` / `rounded-2xl`.
  final double menuRadius;

  /// `shadow-xl` on the content (else shadcn's `shadow-md`).
  final bool menuShadow;

  @override
  State<MenuSelect<T>> createState() => _MenuSelectState<T>();
}

class _MenuSelectState<T> extends State<MenuSelect<T>> {
  final _menu = MenuController();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final w = widget;
    final fg = dark ? AppColors.darkForeground : AppColors.foreground;
    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth.isFinite ? c.maxWidth : 224.0;
      final menuWidth = width < 128 ? 128.0 : width;
      final itemWidth = menuWidth - 8 - (w.itemMargin ? 8 : 0);
      return MenuAnchor(
        controller: _menu,
        style: MenuStyle(
          minimumSize: WidgetStatePropertyAll(Size(menuWidth, 0)),
          backgroundColor: WidgetStatePropertyAll(w.menuBg ?? (dark ? AppColors.darkPopover : AppColors.popover)),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          elevation: WidgetStatePropertyAll(w.menuShadow ? 8 : 4),
          shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.4)),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(w.menuRadius),
            side: BorderSide(color: w.menuBorder ?? (dark ? AppColors.darkBorder : AppColors.border)),
          )),
        ),
        menuChildren: [
          if (w.groupLabel != null)
            Padding(
              padding: w.compactLabel
                  ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
                  : const EdgeInsets.fromLTRB(12, 8, 12, 4),
              child: Text(w.groupLabel!.toUpperCase(),
                  style: TextStyle(
                      fontSize: w.compactLabel ? 12 : 10,
                      letterSpacing: w.compactLabel ? 0.6 : 1.0,
                      color: Tw.slate400,
                      fontWeight: w.compactLabel ? FontWeight.w600 : FontWeight.w500)),
            ),
          for (final it in w.items)
            Padding(
              padding: w.itemMargin ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2) : EdgeInsets.zero,
              child: MenuItemButton(
                onPressed: it.enabled ? () => w.onSelected(it.value) : null,
                style: ButtonStyle(
                  minimumSize: WidgetStatePropertyAll(Size(itemWidth, w.itemMargin ? 36 : 32)),
                  padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
                  shape: WidgetStatePropertyAll(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(w.itemRadius))),
                  overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                  // `focus:bg-accent focus:text-accent-foreground` (reka focuses the hovered item).
                  backgroundColor: WidgetStateProperty.resolveWith((s) =>
                      s.contains(WidgetState.hovered) || s.contains(WidgetState.focused) ? AppColors.accent : null),
                  foregroundColor: WidgetStateProperty.resolveWith((s) {
                    if (s.contains(WidgetState.disabled)) return fg.withValues(alpha: 0.5);
                    if (s.contains(WidgetState.hovered) || s.contains(WidgetState.focused)) {
                      return AppColors.accentForeground;
                    }
                    return fg;
                  }),
                  iconColor: WidgetStateProperty.resolveWith((s) {
                    if (s.contains(WidgetState.disabled)) return fg.withValues(alpha: 0.5);
                    if (s.contains(WidgetState.hovered) || s.contains(WidgetState.focused)) {
                      return AppColors.accentForeground;
                    }
                    return fg;
                  }),
                ),
                trailingIcon: it.value == w.value ? const Icon(Icons.check, size: 16) : null,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (it.icon != null) ...[
                    Icon(it.icon, size: 14, color: w.primaryIcons ? context.colors.primary : null),
                    SizedBox(width: w.primaryIcons ? 10 : 8),
                  ],
                  Text(it.label,
                      style:
                          TextStyle(fontSize: 14, fontWeight: w.primaryIcons ? FontWeight.w500 : FontWeight.w400)),
                ]),
              ),
            ),
        ],
        builder: (context, controller, _) => Opacity(
          opacity: w.disabled ? 0.5 : 1,
          child: InkWell(
            onTap: w.disabled ? null : () => controller.isOpen ? controller.close() : controller.open(),
            borderRadius: BorderRadius.circular(w.radius),
            child: Container(
              height: w.height,
              padding: EdgeInsets.symmetric(horizontal: w.hPad),
              decoration: BoxDecoration(
                color: w.bg ?? (dark ? Tw.slate900 : Colors.white),
                borderRadius: BorderRadius.circular(w.radius),
                border: Border.all(color: w.borderColor ?? (dark ? Tw.slate700 : Tw.slate200)),
                boxShadow: w.shadow,
              ),
              child: Row(children: [
                Expanded(
                  child: DefaultTextStyle.merge(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: w.fontWeight,
                        color: w.textColor ?? (dark ? Tw.slate200 : Tw.slate700)),
                    child: w.trigger,
                  ),
                ),
                const SizedBox(width: 8),
                // lucide `ChevronDown size-4 opacity-50`, `text-muted-foreground`.
                Icon(BootstrapIcons.chevron_down,
                    size: 14,
                    color: (dark ? AppColors.darkMutedForeground : AppColors.mutedForeground).withValues(alpha: 0.5)),
              ]),
            ),
          ),
        ),
      );
    });
  }
}

/// Trigger content for a [MenuSelect] with a `<SelectValue placeholder>`:
/// the selected label, or the placeholder in the global `[data-placeholder]`
/// colour (#9ca3af).
class SelectValueText extends StatelessWidget {
  const SelectValueText({super.key, required this.label, required this.placeholder, this.leading});
  final String? label;
  final String placeholder;

  /// e.g. the batches filter's `bi-funnel text-slate-400 mr-2`.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final text = Text(label ?? placeholder,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: label == null ? const TextStyle(color: AppColors.placeholder) : null);
    if (leading == null) return text;
    return Row(children: [leading!, Flexible(child: text)]);
  }
}

/// `border-2 border-dashed` box (Flutter has no dashed borders).
class DashedBox extends StatelessWidget {
  const DashedBox({
    super.key,
    required this.child,
    required this.color,
    this.radius = 24,
    this.strokeWidth = 2,
    this.fill,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final Color color;
  final double radius;
  final double strokeWidth;
  final Color? fill;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashedPainter(color, radius, strokeWidth, fill),
        child: Padding(padding: padding, child: child),
      );
}

class _DashedPainter extends CustomPainter {
  _DashedPainter(this.color, this.radius, this.strokeWidth, this.fill);
  final Color color;
  final double radius;
  final double strokeWidth;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius((Offset.zero & size).deflate(strokeWidth / 2), Radius.circular(radius));
    if (fill != null) canvas.drawRRect(rrect, Paint()..color = fill!);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final path = Path()..addRRect(rrect);
    const dash = 6.0;
    const gap = 4.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) =>
      old.color != color || old.radius != radius || old.fill != fill || old.strokeWidth != strokeWidth;
}

/// The `w-9 h-9 rounded-xl` back button of the detail headers.
class BackSquareButton extends StatefulWidget {
  const BackSquareButton({super.key, required this.onTap, required this.tooltip});
  final VoidCallback onTap;
  final String tooltip;

  @override
  State<BackSquareButton> createState() => _BackSquareButtonState();
}

class _BackSquareButtonState extends State<BackSquareButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _hover
                  ? (dark ? Tw.indigo950.withValues(alpha: 0.2) : Tw.indigo50)
                  : (dark ? Tw.slate900 : Colors.white),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: dark ? Tw.slate800 : Tw.slate200.withValues(alpha: 0.6)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
            ),
            child: Icon(BootstrapIcons.arrow_left,
                size: 16, color: _hover ? Tw.indigo600 : (dark ? Tw.slate300 : Tw.slate700)),
          ),
        ),
      ),
    );
  }
}

/// The 44px icon tile next to the detail headers (`bi-mortarboard-fill`,
/// `bi-people-fill`).
class HeaderIconTile extends StatelessWidget {
  const HeaderIconTile({super.key, required this.icon});
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: dark ? Tw.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? Tw.slate800 : Tw.slate100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      alignment: Alignment.center,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Tw.indigo500.withValues(alpha: dark ? 0.2 : 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 16, color: dark ? Tw.indigo400 : Tw.indigo600),
      ),
    );
  }
}

/// A heading + subtitle block used by the detail headers.
class DetailHeading extends StatelessWidget {
  const DetailHeading({super.key, required this.title, required this.subtitle});
  final Widget title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      DefaultTextStyle.merge(
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.375, color: dark ? Colors.white : null),
        child: title,
      ),
      const SizedBox(height: 2),
      Text(subtitle,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: dark ? Tw.slate400 : null)),
    ]);
  }
}

/// `grid grid-cols-N gap-x` with rows stretched to the tallest cell.
class EqualGrid extends StatelessWidget {
  const EqualGrid({super.key, required this.columns, required this.children, this.gap = 20});
  final int columns;
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final slice = children.sublist(i, i + columns > children.length ? children.length : i + columns);
      rows.add(IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          for (var j = 0; j < columns; j++) ...[
            if (j > 0) SizedBox(width: gap),
            Expanded(child: j < slice.length ? slice[j] : const SizedBox.shrink()),
          ],
        ]),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      for (var i = 0; i < rows.length; i++) ...[if (i > 0) SizedBox(height: gap), rows[i]],
    ]);
  }
}
