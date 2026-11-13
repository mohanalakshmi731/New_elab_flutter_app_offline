import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/form_fields.dart';
import '../questions/questions_widgets.dart' show TwSpinner, TwSpinnerShape, twLineHeight;

/// Styling blocks of `newquestions.vue` (the "new UI" family: slate/white
/// surfaces, `#1e1b4b` dark cards, cyan accents, `font-black` labels).

/// The page's arbitrary colours (`Tw` covers the Tailwind palette).
class NqTw {
  NqTw._();

  /// `dark:bg-[#1e1b4b]` (cards, dialogs)
  static const navy = Color(0xFF1E1B4B);

  /// `dark:!bg-[#0f0e2a]` (question form dialog)
  static const deepNavy = Color(0xFF0F0E2A);

  /// `white/N`
  static Color white(double alpha) => Colors.white.withValues(alpha: alpha);

  /// `border-slate-200 dark:border-white/10`
  static Color border(BuildContext context) => context.isDark ? white(0.1) : Tw.slate200;
}

/// `<label class="text-xs font-bold text-slate-500 dark:text-slate-400
/// uppercase tracking-wider">` (+ `<span class="text-rose-400">*</span>`).
///
/// The label is inline, so it sits on a line of the parent's 16px/24px strut
/// and the wrapper's `space-y-*` margin (on an inline box) has no effect.
class NqLabel extends StatelessWidget {
  const NqLabel(this.text, {super.key, this.required = false, this.size = 12, this.color, this.suffix});

  final String text;
  final bool required;
  final double size;
  final Color? color;

  /// e.g. `(comma separated)` in `font-normal normal-case text-slate-400`.
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final base = DefaultTextStyle.of(context).style;
    return Text.rich(
      TextSpan(
        text: text.toUpperCase(),
        children: [
          if (required) const TextSpan(text: ' *', style: TextStyle(color: Tw.rose400)),
          if (suffix != null)
            TextSpan(
              text: ' $suffix',
              style: const TextStyle(fontWeight: FontWeight.w400, color: Tw.slate400),
            ),
        ],
      ),
      strutStyle: StrutStyle(
        fontFamily: base.fontFamily,
        fontFamilyFallback: base.fontFamilyFallback,
        fontSize: 16,
        height: 1.5,
        leadingDistribution: TextLeadingDistribution.even,
      ),
      style: TextStyle(
        fontSize: size,
        height: (size == 12 ? 16 : size * 1.5) / size,
        leadingDistribution: TextLeadingDistribution.even,
        fontWeight: FontWeight.w700,
        letterSpacing: size * 0.05,
        color: color ?? (dark ? Tw.slate400 : Tw.slate500),
      ),
    );
  }
}

/// `<div class="space-y-1.5"><label>…</label><control/></div>`: the inline
/// label's line, then the control ([gap] stays 0 — see [NqLabel]).
class NqField extends StatelessWidget {
  const NqField({super.key, required this.label, required this.child, this.gap = 0});
  final Widget label;
  final Widget child;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [label, if (gap > 0) SizedBox(height: gap), child],
      );
}

/// `<SelectTrigger class="w-full h-10 rounded-xl border-slate-200
/// dark:border-white/10 !bg-slate-50 dark:!bg-white/5 !text-slate-900
/// dark:!text-white">` (or another [fill]). The kit's
/// `data-[size=default]:h-9` outranks `h-10`, so the trigger is 36px tall;
/// the `!bg` keeps it from changing on hover.
AppSelect<String> nqSelect(
  BuildContext context, {
  required String? value,
  required List<AppSelectItem<String>> items,
  required ValueChanged<String> onChanged,
  required String placeholder,
  bool enabled = true,
  Color? fill,
}) {
  final dark = context.isDark;
  return AppSelect<String>(
    value: value,
    items: items,
    enabled: enabled,
    placeholder: placeholder,
    onChanged: (v) => onChanged(v ?? ''),
    height: 36,
    radius: 20,
    borderColor: NqTw.border(context),
    fillColor: fill ?? (dark ? NqTw.white(0.05) : Tw.slate50),
    textColor: dark ? Colors.white : Tw.slate900,
  );
}

/// The page's buttons: shadcn `<Button>` with `!bg-… hover:!bg-… !text-…
/// font-… rounded-xl px-… py-… h-auto text-…` overrides — cyan
/// (`!bg-cyan-500 hover:!bg-cyan-400 !text-slate-900 font-black`), the white
/// bordered "ghost" ones ([NqButton.plain]), emerald (update) and rose
/// (delete).
class NqButton extends StatefulWidget {
  const NqButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.background = Tw.cyan500,
    this.hoverBackground = Tw.cyan400,
    this.foreground = Tw.slate900,
    this.borderColor,
    this.fontSize = 14,
    this.fontWeight = FontWeight.w900,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.radius = 20,
    this.shadow,
    this.hoverScale = false,
    this.minWidth = 0,
    this.loading = false,
    this.loadingLabel,
    this.iconSize,
    this.iconGap = 8,
  });

  /// `variant="ghost" class="!bg-white dark:!bg-white/5 border
  /// border-slate-200 dark:border-white/10 !text-slate-700
  /// [dark:!text-slate-300] font-bold rounded-xl"`. With [hover] the page's
  /// `hover:!bg-slate-50 dark:hover:!bg-white/10` applies; without it the
  /// `!bg` beats the ghost hover and nothing changes.
  factory NqButton.plain(
    BuildContext context, {
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    double fontSize = 14,
    EdgeInsets padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    bool darkText = true,
    bool hover = true,
    double iconGap = 8,
  }) {
    final dark = context.isDark;
    final bg = dark ? NqTw.white(0.05) : Colors.white;
    return NqButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      background: bg,
      hoverBackground: hover ? (dark ? NqTw.white(0.1) : Tw.slate50) : bg,
      foreground: dark && darkText ? Tw.slate300 : Tw.slate700,
      borderColor: NqTw.border(context),
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      padding: padding,
      shadow: const [],
      iconGap: iconGap,
    );
  }

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color background;
  final Color hoverBackground;
  final Color foreground;
  final Color? borderColor;
  final double fontSize;
  final FontWeight fontWeight;
  final EdgeInsets padding;
  final double radius;

  /// `shadow-…`; defaults to the default variant's `shadow-xs` (coloured
  /// `shadow-cyan-500/30` modifiers have no effect in this theme).
  final List<BoxShadow>? shadow;

  /// `hover:scale-105 active:scale-95`
  final bool hoverScale;
  final double minWidth;

  /// `:disabled` + the spinner SVG and [loadingLabel] (`gap-1.5`).
  final bool loading;
  final String? loadingLabel;

  /// Defaults to the text size (a `bi` icon inherits it).
  final double? iconSize;

  /// Space between the icon and the label: the button's `gap-2` (8) plus
  /// the icon's `me-*` margin.
  final double iconGap;

  @override
  State<NqButton> createState() => _NqButtonState();
}

class _NqButtonState extends State<NqButton> {
  bool _hover = false;
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final disabled = w.onPressed == null || w.loading;
    final bg = _hover && !disabled ? w.hoverBackground : w.background;
    final text = w.loading ? (w.loadingLabel ?? w.label) : w.label;
    final iconSize = w.iconSize ?? w.fontSize;
    final scale = !w.hoverScale || disabled ? 1.0 : (_down ? 0.95 : (_hover ? 1.05 : 1.0));
    Widget b = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: const Cubic(0.4, 0, 0.2, 1),
      constraints: BoxConstraints(minWidth: w.minWidth),
      padding: w.padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(w.radius),
        border: w.borderColor == null ? null : Border.all(color: w.borderColor!),
        boxShadow: w.shadow ?? AppShadows.xs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (w.loading) ...[
            TwSpinner(size: 14, color: w.foreground, shape: TwSpinnerShape.wedge),
            const SizedBox(width: 6),
          ] else if (w.icon != null) ...[
            Icon(w.icon, size: iconSize, color: w.foreground),
            SizedBox(width: w.iconGap),
          ],
          Flexible(
            child: Text(
              text,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: w.fontSize,
                height: twLineHeight(w.fontSize) / w.fontSize,
                fontWeight: w.fontWeight,
                color: w.foreground,
              ),
            ),
          ),
        ],
      ),
    );
    b = AnimatedScale(scale: scale, duration: const Duration(milliseconds: 150), child: b);
    b = MouseRegion(
      cursor: disabled ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() {
        _hover = false;
        _down = false;
      }),
      child: GestureDetector(
        onTap: disabled ? null : w.onPressed,
        onTapDown: disabled ? null : (_) => setState(() => _down = true),
        onTapUp: disabled ? null : (_) => setState(() => _down = false),
        onTapCancel: disabled ? null : () => setState(() => _down = false),
        child: b,
      ),
    );
    // `disabled:opacity-50`
    if (disabled) b = Opacity(opacity: 0.5, child: b);
    return b;
  }
}

/// A coloured square icon button (`w-7 h-7 rounded-lg bg-… text-… hover:bg-…`).
class NqIconButton extends StatefulWidget {
  const NqIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.color,
    required this.background,
    this.hoverBackground,
    this.hoverColor,
    this.size = 28,
    this.radius = 16,
    this.iconSize = 12,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color background;
  final Color? hoverBackground;
  final Color? hoverColor;
  final double size;
  final double radius;
  final double iconSize;

  @override
  State<NqIconButton> createState() => _NqIconButtonState();
}

class _NqIconButtonState extends State<NqIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final r = widget.radius > widget.size / 2 ? widget.size / 2 : widget.radius;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hover ? (widget.hoverBackground ?? widget.background) : widget.background,
            borderRadius: BorderRadius.circular(r),
          ),
          child: Icon(widget.icon,
              size: widget.iconSize, color: _hover ? (widget.hoverColor ?? widget.color) : widget.color),
        ),
      ),
    );
  }
}

/// `w-8 h-8 rounded-xl bg-…/10` tile holding a header icon.
class NqIconTile extends StatelessWidget {
  const NqIconTile({super.key, required this.icon, required this.color, this.size = 32, this.iconSize = 14, this.bg});
  final IconData icon;
  final Color color;
  final double size;
  final double iconSize;
  final Color? bg;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bg ?? color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(size / 2 < 20 ? size / 2 : 20),
        ),
        child: Icon(icon, size: iconSize, color: color),
      );
}

/// `px-2 py-0.5 rounded-full text-[10px]` badge.
class NqPill extends StatelessWidget {
  const NqPill({super.key, required this.text, this.bg, this.fg, this.weight = FontWeight.w700});
  final String text;
  final Color? bg;
  final Color? fg;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
        child: Text(text, maxLines: 1, style: TextStyle(fontSize: 10, fontWeight: weight, color: fg)),
      );
}

/// The new-UI dialogs: shadcn `<DialogContent>` with `!bg-white
/// dark:!bg-[#1e1b4b] border border-slate-200 dark:border-white/10
/// rounded-2xl p-0 overflow-hidden` — still the kit's `grid gap-4` (16px
/// between [children]), `shadow-2xl`, zoom-in-95, and its close `X`
/// (`top-4 right-4`).
class NqDialogShell extends StatelessWidget {
  const NqDialogShell({
    super.key,
    required this.maxWidth,
    required this.children,
    this.insetPadding = const EdgeInsets.all(16),
    this.maxHeight,
  });

  final double maxWidth;

  /// Header / body / footer; a scrolling body should be [Flexible].
  final List<Widget> children;
  final EdgeInsets insetPadding;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    Widget frame = DecoratedBox(
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), boxShadow: AppShadows.xl2),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: dark ? NqTw.navy : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: NqTw.border(context)),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < children.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    children[i],
                  ],
                ],
              ),
              const Positioned(top: 16, right: 16, child: DialogCloseButton()),
            ],
          ),
        ),
      ),
    );
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
      insetPadding: insetPadding,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight ?? double.infinity),
        child: frame,
      ),
    );
  }
}

/// Dialog header row: icon tile + title (+ subtitle), on `bg-slate-50
/// dark:bg-white/3` (or [background]) with a bottom border.
class NqDialogHeader extends StatelessWidget {
  const NqDialogHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.background,
    this.titleColor,
    this.titleSize = 16,
    this.tileSize = 32,
    this.tileBg,
    this.iconSize = 14,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? background;
  final Color? titleColor;

  /// `text-base` (16/24) or `text-sm leading-tight` (14, ×1.25).
  final double titleSize;
  final double tileSize;
  final Color? tileBg;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final hPad = context.isSm ? 24.0 : 16.0;
    return Container(
      // The right padding keeps the title clear of the kit's close X.
      padding: EdgeInsets.fromLTRB(hPad, 16, 52, 16),
      decoration: BoxDecoration(
        color: background ?? (dark ? NqTw.white(0.03) : Tw.slate50),
        border: Border(bottom: BorderSide(color: NqTw.border(context))),
      ),
      child: Row(
        children: [
          NqIconTile(icon: icon, color: iconColor, size: tileSize, iconSize: iconSize, bg: tileBg),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleSize,
                    height: titleSize < 16 ? 1.25 : 1.5,
                    fontWeight: FontWeight.w900,
                    color: titleColor ?? (dark ? Colors.white : Tw.slate900),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate500)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog footer: `px-4 sm:px-6 py-3 border-t bg-slate-50 dark:bg-white/3
/// flex justify-end gap-2`.
class NqDialogFooter extends StatelessWidget {
  const NqDialogFooter({super.key, required this.children, this.background});
  final List<Widget> children;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final hPad = context.isSm ? 24.0 : 16.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
      decoration: BoxDecoration(
        color: background ?? (dark ? NqTw.white(0.03) : Tw.slate50),
        border: Border(top: BorderSide(color: NqTw.border(context))),
      ),
      child: Wrap(
        alignment: WrapAlignment.end,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: children,
      ),
    );
  }
}

/// A form section (`rounded-2xl border overflow-hidden` + a `px-4 py-3
/// bg-slate-50 dark:bg-white/5` header with an uppercase `font-black` title).
class NqSectionCard extends StatelessWidget {
  const NqSectionCard({super.key, required this.title, required this.child, this.action});
  final String title;
  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final border = NqTw.border(context);
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16), border: Border.all(color: border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: dark ? NqTw.white(0.05) : Tw.slate50,
              border: Border(bottom: BorderSide(color: border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      height: 16 / 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.6,
                      color: dark ? Tw.slate300 : Tw.slate600,
                    ),
                  ),
                ),
                ?action,
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

/// `animate-slide-up` (this page's scoped `slideUp`: 0.3s ease, fade + 12px
/// rise on mount).
class NqSlideUp extends StatelessWidget {
  const NqSlideUp({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
        builder: (context, t, child) => Opacity(
          opacity: t,
          child: Transform.translate(offset: Offset(0, 12 * (1 - t)), child: child),
        ),
        child: child,
      );
}

/// `<Input type="number">` characters.
final nqNumberFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9eE.+\-]'));

/// shadcn `<Input>` / `<Textarea>` with the page's `h-10 rounded-xl
/// border-slate-200 dark:border-white/10 !bg-slate-50 dark:!bg-white/5
/// !text-slate-900 dark:!text-white text-sm` (override [height],
/// [fontSize], [fill]). Keeps the kit's `shadow-xs`, `#9ca3af` placeholder
/// and `focus-visible:border-ring ring-[3px] ring-ring/50`.
class NqTextInput extends StatelessWidget {
  const NqTextInput({
    super.key,
    this.controller,
    this.initialValue,
    this.hint,
    this.height = 40,
    this.fontSize = 14,
    this.mdFontSize,
    this.fill,
    this.readOnly = false,
    this.textarea = false,
    this.number = false,
    this.strongText = true,
    this.focusNode,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final double height;
  final double fontSize;

  /// `text-xs` leaves the kit's `md:text-sm`: 14px from 768px up.
  final double? mdFontSize;
  final Color? fill;
  final bool readOnly;

  /// `<Textarea>`: `field-sizing-content min-h-16 py-2` (grows with the
  /// text; `rows` has no effect).
  final bool textarea;
  final bool number;

  /// `!text-slate-900 dark:!text-white`; otherwise the inherited foreground.
  final bool strongText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final size = (mdFontSize != null && context.isMd) ? mdFontSize! : fontSize;
    final lineHeight = twLineHeight(size);
    final ring = context.ringColor;
    RingInputBorder border({bool focused = false}) => RingInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: focused ? ring : NqTw.border(context)),
          ringColor: focused ? ring.withValues(alpha: 0.5) : Colors.transparent,
          shadows: AppShadows.xs,
        );
    final style = TextStyle(
      fontSize: size,
      height: lineHeight / size,
      leadingDistribution: TextLeadingDistribution.even,
      color: strongText ? (dark ? Colors.white : Tw.slate900) : context.fgColor,
    );
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      readOnly: readOnly,
      focusNode: focusNode,
      onChanged: onChanged,
      maxLines: textarea ? null : 1,
      minLines: textarea ? 1 : null,
      keyboardType: number
          ? const TextInputType.numberWithOptions(decimal: true, signed: true)
          : (textarea ? TextInputType.multiline : null),
      inputFormatters: number ? [nqNumberFormatter] : null,
      style: style,
      textAlignVertical: textarea ? TextAlignVertical.top : TextAlignVertical.center,
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        hintStyle: style.copyWith(color: AppColors.placeholder),
        filled: true,
        fillColor: fill ?? (dark ? NqTw.white(0.05) : Tw.slate50),
        hoverColor: Colors.transparent,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: textarea ? 8 : ((height - lineHeight) / 2).clamp(0.0, 24.0),
        ),
        constraints: textarea ? const BoxConstraints(minHeight: 64) : null,
        border: border(),
        enabledBorder: border(),
        disabledBorder: border(),
        focusedBorder: border(focused: true),
      ),
    );
  }
}

/// `border-2 border-dashed rounded-xl` box.
class NqDashedBox extends StatelessWidget {
  const NqDashedBox({super.key, required this.child, required this.color, this.fill, this.radius = 20});
  final Widget child;
  final Color color;
  final Color? fill;
  final double radius;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashedRRectPainter(color: color, radius: radius, fill: fill),
        child: child,
      );
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius, this.fill});
  final Color color;
  final double radius;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)).deflate(1);
    if (fill != null) canvas.drawRRect(rrect, Paint()..color = fill!);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + 6), paint);
        d += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter old) =>
      old.color != color || old.radius != radius || old.fill != fill;
}
