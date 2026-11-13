part of 'class_course_create_page.dart';

/// Arbitrary colours used by this screen (`text-[#4f46e5]`).
class _C {
  _C._();
  static const indigoText = Color(0xFF4F46E5);
}

// Shadows: `src/style.css` overrides Tailwind's `--shadow-*` scale, so these
// are the app's values, not Tailwind's defaults.

/// `shadow-xs`
const _shadowXs = [BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1))];

/// `shadow-sm` / `shadow`
const _shadowSm = [
  BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x1A000000), blurRadius: 2, spreadRadius: -1, offset: Offset(0, 1)),
];

/// `shadow-md`
const _shadowMd = [
  BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x1A000000), blurRadius: 4, spreadRadius: -1, offset: Offset(0, 2)),
];

/// `shadow-lg`
const _shadowLg = [
  BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x1A000000), blurRadius: 6, spreadRadius: -1, offset: Offset(0, 4)),
];

/// `shadow-xl`
const _shadowXl = [
  BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
  BoxShadow(color: Color(0x1A000000), blurRadius: 10, spreadRadius: -1, offset: Offset(0, 8)),
];

/// `shadow-2xl` (the dialogs' `shadow-indigo-950/15` has no effect on it).
const _shadow2xl = [BoxShadow(color: Color(0x40000000), blurRadius: 3, offset: Offset(0, 1))];

Color _borderColor(BuildContext context) => context.isDark ? AppColors.darkBorder : AppColors.border;

/// `text-muted-foreground`
Color _mutedFg(BuildContext context) => context.isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;

/// The outer `<Card class="dark:bg-primary-foreground">`. When a course is
/// expanded it becomes `border-none shadow-none bg-transparent rounded-none`
/// — but `dark:bg-primary-foreground` survives, so in dark mode it keeps its
/// background (`py-6` stays too).
class _OuterCard extends StatelessWidget {
  const _OuterCard({required this.expanded, required this.child});
  final bool expanded;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: expanded
          ? BoxDecoration(color: dark ? AppColors.darkPrimaryForeground : null)
          : BoxDecoration(
              color: dark ? AppColors.darkPrimaryForeground : AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _borderColor(context)),
              boxShadow: _shadowSm,
            ),
      child: child,
    );
  }
}

/// The inner `<Card class="w-full overflow-hidden p-1">` around the grid.
class _InnerCard extends StatelessWidget {
  const _InnerCard({required this.expanded, required this.child});
  final bool expanded;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (expanded) return child;
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(4),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _borderColor(context)),
        boxShadow: _shadowSm,
      ),
      child: child,
    );
  }
}

/// `grid grid-cols-N gap-x gap-y`: rows of [columns] equal-width cells with
/// equal heights per row.
class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.children, this.gap = 16, this.equalHeight = true});
  final int columns;
  final List<Widget> children;
  final double gap;
  final bool equalHeight;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final cells = <Widget>[];
      for (var j = 0; j < columns; j++) {
        if (j > 0) cells.add(SizedBox(width: gap));
        final k = i + j;
        cells.add(Expanded(child: k < children.length ? children[k] : const SizedBox.shrink()));
      }
      final row = Row(
        crossAxisAlignment: equalHeight ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
        children: cells,
      );
      rows.add(equalHeight && columns > 1 ? IntrinsicHeight(child: row) : row);
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
}

/// A round icon button (`w-7 h-7 rounded-full flex items-center
/// justify-center bg-x hover:bg-y text-z transition-colors`). The hover
/// colours replace the base ones, as on the web (null = no hover change).
class _RoundIconButton extends StatefulWidget {
  const _RoundIconButton({
    required this.icon,
    required this.background,
    required this.foreground,
    this.hoverBackground,
    this.hoverForeground,
    this.onTap,
    this.tooltip,
    this.size = 28,
    this.iconSize = 12,
    this.radius,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final Color? hoverBackground;
  final Color? hoverForeground;
  final VoidCallback? onTap;
  final String? tooltip;
  final double size;
  final double iconSize;

  /// null = circle.
  final double? radius;

  @override
  State<_RoundIconButton> createState() => _RoundIconButtonState();
}

class _RoundIconButtonState extends State<_RoundIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final w = widget;
    final bg = _hover ? (w.hoverBackground ?? w.background) : w.background;
    final fg = _hover ? (w.hoverForeground ?? w.foreground) : w.foreground;
    Widget button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: w.onTap ?? () {},
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: w.size,
          height: w.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            shape: w.radius == null ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: w.radius == null ? null : BorderRadius.circular(w.radius!),
          ),
          child: Icon(w.icon, size: w.iconSize, color: fg),
        ),
      ),
    );
    if (w.tooltip != null) button = Tooltip(message: w.tooltip!, child: button);
    return button;
  }
}

/// `border border-dashed rounded-xl` box.
class _DashedBox extends StatelessWidget {
  const _DashedBox({required this.child, required this.color, this.radius = 20, this.padding = EdgeInsets.zero});
  final Widget child;
  final Color color;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _DashedRRectPainter(color: color, radius: radius),
        child: Padding(padding: padding, child: child),
      );
}

class _DashedRRectPainter extends CustomPainter {
  _DashedRRectPainter({required this.color, required this.radius});
  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius((Offset.zero & size).deflate(0.5), Radius.circular(radius));
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = color;
    const dash = 4.0, gap = 3.0;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, math.min(d + dash, metric.length)), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter old) => old.color != color || old.radius != radius;
}

/// Menu item style of shadcn `DropdownMenuItem` / `SelectItem`: `rounded-*
/// px-2 py-1.5 text-sm`, `focus:bg-accent focus:text-accent-foreground`.
ButtonStyle _menuItemStyle({required double width, required double radius, double rightPad = 8}) => ButtonStyle(
      minimumSize: WidgetStatePropertyAll(Size(width, 32)),
      padding: WidgetStatePropertyAll(EdgeInsets.only(left: 8, right: rightPad)),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius))),
      textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 14, height: 20 / 14)),
      backgroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.hovered) || s.contains(WidgetState.focused) ? AppColors.accent : null,
      ),
      foregroundColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.hovered) || s.contains(WidgetState.focused) ? AppColors.accentForeground : null,
      ),
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
    );

/// shadcn `DropdownMenu` whose trigger is the outline button (`w-full sm:w-72
/// justify-between bg-white dark:bg-slate-950 border-slate-200
/// dark:border-slate-800 rounded-xl px-4 text-sm font-medium shadow-sm`, h-9)
/// showing the current choice or the placeholder plus a `ChevronDown`, and
/// whose content (`w-72 rounded-xl`) is a label, a separator and the items.
class _MenuDropdown extends StatefulWidget {
  const _MenuDropdown({required this.text, required this.header, required this.items});
  final String text;
  final String header;
  final List<(String, VoidCallback)> items;

  @override
  State<_MenuDropdown> createState() => _MenuDropdownState();
}

class _MenuDropdownState extends State<_MenuDropdown> {
  final _menu = MenuController();
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final border = dark ? Tw.slate800 : Tw.slate200;
    // Outline variant hover: `hover:bg-accent hover:text-accent-foreground
    // dark:hover:bg-input/50`.
    final bg = _hover
        ? (dark ? AppColors.darkBorder.withValues(alpha: 0.5) : AppColors.accent)
        : (dark ? Tw.slate950 : Colors.white);
    final fg = _hover && !dark ? AppColors.accentForeground : (dark ? AppColors.darkForeground : AppColors.foreground);
    return MenuAnchor(
      controller: _menu,
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        minimumSize: const WidgetStatePropertyAll(Size(288, 0)),
        maximumSize: const WidgetStatePropertyAll(Size(288, 360)),
        backgroundColor: WidgetStatePropertyAll(dark ? AppColors.darkPopover : AppColors.popover),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        // `shadow-md`
        elevation: const WidgetStatePropertyAll(2),
        shadowColor: const WidgetStatePropertyAll(Color(0x33000000)),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: border)),
        ),
      ),
      menuChildren: [
        // `<DropdownMenuLabel class="text-xs text-slate-400 font-semibold px-2 py-1">`
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Text(widget.header,
              style: const TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: Tw.slate400)),
        ),
        Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 4), color: dark ? Tw.slate800 : Tw.slate100),
        for (final (label, onTap) in widget.items)
          MenuItemButton(
            onPressed: onTap,
            style: _menuItemStyle(width: 278, radius: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 262),
              child: Text(label, overflow: TextOverflow.ellipsis),
            ),
          ),
      ],
      builder: (context, controller, _) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () => controller.isOpen ? controller.close() : controller.open(),
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
              boxShadow: _shadowSm,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(widget.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fg)),
                ),
                const SizedBox(width: 8),
                Opacity(opacity: 0.5, child: Icon(BootstrapIcons.chevron_down, size: 16, color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The `bg-primary hover:bg-primary/95 text-white rounded-xl shadow-sm px-6
/// font-medium` "Attach" button (h-9) with the `bi-arrow-repeat animate-spin`
/// spinner instead of the label while loading.
class _AttachButton extends StatelessWidget {
  const _AttachButton({required this.loading, required this.onPressed, this.expand = false});
  final bool loading;
  final VoidCallback onPressed;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return AppButton(
      onPressed: loading ? null : onPressed,
      expand: expand,
      foregroundColor: Colors.white,
      hoverBackgroundColor: primary.withValues(alpha: 0.95),
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      shadow: _shadowSm,
      child: loading ? const SpinIcon(color: Colors.white, size: 14) : const Text('Attach'),
    );
  }
}

/// Spinner-or-label content for the dialog submit buttons
/// (`<i class="bi bi-arrow-repeat animate-spin">` / `<span>Create</span>`).
Widget _spinOr(BuildContext context, bool loading, String label, {Color? color}) =>
    loading ? SpinIcon(color: color ?? context.colors.onPrimary, size: 14) : Text(label);

/// The `animate-pulse` dot of the "Active" badge.
class _PulseDot extends StatefulWidget {
  const _PulseDot();

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))
    ..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: Tween<double>(begin: 1, end: 0.5).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
        child: Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
        ),
      );
}

// ── Dialog building blocks ──────────────────────────────────────────────────

/// shadcn `<DialogContent>` with this page's class overrides:
/// `bg-white/90 dark:bg-slate-900/90 backdrop-blur-xl border border-white/40
/// dark:border-slate-800/80 rounded-[20px] shadow-2xl p-6 w-full
/// max-w-[calc(100%-2rem)] sm:max-w-lg` and the close X at `top-4 right-4`.
///
/// [solidLight] = `bg-white`, [solidDark] = `dark:bg-primary-foreground`.
/// The content scrolls when taller than the screen (or [maxHeight]).
class _CcDialog extends StatelessWidget {
  const _CcDialog({
    required this.child,
    this.maxWidth = 512,
    this.padding = const EdgeInsets.all(24),
    this.radius = 20,
    this.solidLight = false,
    this.solidDark = false,
    this.borderColor,
    this.shadow = _shadow2xl,
    this.maxHeight,
    this.height,
    this.textColor,
    this.scroll = true,
  });

  final Widget child;

  /// `sm:max-w-*` (below 640 px the dialog is the screen width minus 2rem).
  final double maxWidth;
  final EdgeInsetsGeometry padding;
  final double radius;
  final bool solidLight;
  final bool solidDark;
  final Color? borderColor;
  final List<BoxShadow> shadow;

  /// `max-h-[90vh]` → pass `0.9 * screen height`.
  final double? maxHeight;

  /// `h-[90vh]`.
  final double? height;

  /// `text-slate-900 dark:text-white` etc. (default `text-foreground`).
  final Color? textColor;

  /// false when [child] manages its own scrolling (header + scrolling body).
  final bool scroll;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final translucent = dark ? !solidDark : !solidLight;
    final bg = dark
        ? (solidDark ? AppColors.darkPrimaryForeground : Tw.slate900.withValues(alpha: 0.9))
        : (solidLight ? Colors.white : Colors.white.withValues(alpha: 0.9));
    final border = borderColor ?? (dark ? Tw.slate800.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.4));
    final fg = textColor ?? (dark ? AppColors.darkForeground : AppColors.foreground);

    Widget body = Padding(padding: padding, child: child);
    if (scroll) body = SingleChildScrollView(child: body);

    Widget surface = Container(
      height: height,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
      ),
      child: Stack(
        children: [
          body,
          const Positioned(top: 16, right: 16, child: _DialogClose()),
        ],
      ),
    );
    if (translucent) {
      surface = BackdropFilter(filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24), child: surface);
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.isSm ? maxWidth : double.infinity,
          maxHeight: maxHeight ?? double.infinity,
        ),
        child: SizedBox(
          width: double.infinity,
          child: DecoratedBox(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(radius), boxShadow: shadow),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: DefaultTextStyle.merge(
                style: TextStyle(fontSize: 16, color: fg),
                child: IconTheme.merge(data: IconThemeData(color: fg), child: surface),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// `<DialogClose>`: `rounded-xl p-1.5 text-slate-400 hover:text-slate-700
/// dark:text-slate-500 dark:hover:text-slate-200 hover:bg-slate-100
/// dark:hover:bg-slate-800/50` with a 16px X.
class _DialogClose extends StatelessWidget {
  const _DialogClose();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return _RoundIconButton(
      icon: BootstrapIcons.x_lg,
      iconSize: 14,
      size: 28,
      radius: 12,
      tooltip: 'Close',
      background: Colors.transparent,
      hoverBackground: dark ? Tw.slate800.withValues(alpha: 0.5) : Tw.slate100,
      foreground: dark ? Tw.slate500 : Tw.slate400,
      hoverForeground: dark ? Tw.slate200 : Tw.slate700,
      onTap: () => Navigator.of(context).maybePop(),
    );
  }
}

/// `<DialogHeader>` text: `text-center sm:text-left`.
TextAlign _headerAlign(BuildContext context) => context.isSm ? TextAlign.left : TextAlign.center;

/// `<DialogDescription>` used as a heading (`text-muted-foreground text-sm`).
Widget _dialogDescription(BuildContext context, String text, {double fontSize = 14}) => SizedBox(
      width: double.infinity,
      child: Padding(
        // Keeps the text clear of the close X.
        padding: const EdgeInsets.only(right: 24),
        child: Text(
          text,
          textAlign: _headerAlign(context),
          style: TextStyle(fontSize: fontSize, height: 20 / 14, color: _mutedFg(context)),
        ),
      ),
    );

/// `<div class="flex justify-end space-x-2">` with the dialog buttons (a plain
/// row, not the stacking `<DialogFooter>`).
Widget _buttonRow(List<Widget> buttons, {double gap = 8}) => Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (var i = 0; i < buttons.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          buttons[i],
        ],
      ],
    );

/// `<Label class="mb-2">` (`text-sm leading-none font-medium`) + optional
/// `<span class="text-red-500">*</span>` (the label is `flex gap-2`).
class _ReqLabel extends StatelessWidget {
  const _ReqLabel(this.text, {this.required = false});
  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 14, height: 1, fontWeight: FontWeight.w500);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(child: Text(text, style: style)),
        if (required) ...[
          const SizedBox(width: 8),
          Text('*', style: style.copyWith(color: Tw.red500)),
        ],
      ],
    );
  }
}

/// A native `<label class="text-sm">` placed inline before a full-width
/// control: it sits on its own 24px line box, normal weight.
Widget _nativeLabel(String text) => SizedBox(
      height: 24,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontSize: 14, height: 20 / 14)),
      ),
    );

/// A raw `<input type="text">` styled by the page: `border rounded-md p-2
/// w-full` (16px text, 42px tall, browser focus ring in `ring/50`), or the
/// header search box with [horizontalPadding] 12, a [fill] and a
/// `focus:ring-2 focus:ring-primary/20` [ring].
class _NativeInput extends StatefulWidget {
  const _NativeInput({
    required this.controller,
    this.hint,
    this.maxLength,
    this.onChanged,
    this.fill,
    this.horizontalPadding = 8,
    this.ring,
  });

  final TextEditingController controller;
  final String? hint;
  final int? maxLength;
  final ValueChanged<String>? onChanged;
  final Color? fill;
  final double horizontalPadding;
  final Color? ring;

  @override
  State<_NativeInput> createState() => _NativeInputState();
}

class _NativeInputState extends State<_NativeInput> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final fg = DefaultTextStyle.of(context).style.color ?? (dark ? AppColors.darkForeground : AppColors.foreground);
    final ring = widget.ring ?? (dark ? AppColors.darkRing : AppColors.ring).withValues(alpha: 0.5);
    final side = BorderSide(color: _borderColor(context));
    final shape = OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: side);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: _focus.hasFocus ? [BoxShadow(color: ring, spreadRadius: 2)] : null,
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focus,
        maxLength: widget.maxLength,
        onChanged: widget.onChanged,
        style: TextStyle(fontSize: 16, height: 1.5, color: fg),
        cursorColor: fg,
        decoration: InputDecoration(
          isDense: true,
          hintText: widget.hint,
          hintStyle: TextStyle(fontSize: 16, height: 1.5, color: fg.withValues(alpha: 0.5)),
          counterText: '',
          filled: widget.fill != null,
          fillColor: widget.fill,
          hoverColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: widget.horizontalPadding + 1, vertical: 9),
          border: shape,
          enabledBorder: shape,
          focusedBorder: shape,
        ),
      ),
    );
  }
}

/// A select whose trigger takes the page's classes: the Preview tab's
/// `<SelectTrigger class="bg-white dark:bg-slate-950 border-slate-200
/// dark:border-slate-800 rounded-xl">` (h-9 still wins) or, with [native],
/// a raw `<select class="border rounded-md p-2 w-full">`.
class _CcSelect extends StatefulWidget {
  const _CcSelect({
    required this.value,
    required this.items,
    required this.onChanged,
    required this.placeholder,
    this.enabled = true,
    this.native = false,
    this.fill,
  });

  final String value;
  final List<AppSelectItem<String>> items;
  final ValueChanged<String>? onChanged;
  final String placeholder;
  final bool enabled;
  final bool native;

  /// Native select background (`dark:bg-primary-foreground`).
  final Color? fill;

  @override
  State<_CcSelect> createState() => _CcSelectState();
}

class _CcSelectState extends State<_CcSelect> {
  final _menu = MenuController();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final native = widget.native;
    final fg = DefaultTextStyle.of(context).style.color ?? (dark ? AppColors.darkForeground : AppColors.foreground);
    AppSelectItem<String>? selected;
    for (final it in widget.items) {
      if (it.value == widget.value) selected = it;
    }
    final menuBg = native
        ? (dark ? AppColors.darkPopover : AppColors.popover)
        : (dark ? Tw.slate950 : AppColors.popover);
    final menuBorder = native ? _borderColor(context) : (dark ? Tw.slate800 : AppColors.border);

    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth.isFinite ? c.maxWidth : 240.0;
        return MenuAnchor(
          controller: _menu,
          crossAxisUnconstrained: false,
          alignmentOffset: const Offset(0, 4),
          style: MenuStyle(
            minimumSize: WidgetStatePropertyAll(Size(width, 0)),
            maximumSize: WidgetStatePropertyAll(Size(width, 320)),
            backgroundColor: WidgetStatePropertyAll(menuBg),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            elevation: const WidgetStatePropertyAll(2),
            shadowColor: const WidgetStatePropertyAll(Color(0x33000000)),
            padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14), side: BorderSide(color: menuBorder)),
            ),
          ),
          menuChildren: [
            for (final it in widget.items)
              MenuItemButton(
                onPressed: it.enabled ? () => widget.onChanged?.call(it.value) : null,
                style: _menuItemStyle(width: width - 8, radius: 12, rightPad: 8),
                trailingIcon: it.value == widget.value && it.enabled ? const Icon(Icons.check, size: 16) : null,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: math.max(0, width - 48)),
                  child: Text(it.label, overflow: TextOverflow.ellipsis),
                ),
              ),
          ],
          builder: (context, controller, _) {
            final placeholder = selected == null;
            final text = selected?.label ?? widget.placeholder;
            final Widget trigger = native
                ? Container(
                    height: 42,
                    padding: const EdgeInsets.symmetric(horizontal: 9),
                    decoration: BoxDecoration(
                      color: widget.fill,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: _borderColor(context)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 16, color: fg)),
                        ),
                        Icon(BootstrapIcons.chevron_down, size: 12, color: fg),
                      ],
                    ),
                  )
                : Container(
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: dark ? Tw.slate950 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: dark ? Tw.slate800 : Tw.slate200),
                      boxShadow: _shadowXs,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(text,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 14, color: placeholder ? _mutedFg(context) : fg)),
                        ),
                        const SizedBox(width: 8),
                        Opacity(
                          opacity: 0.5,
                          child: Icon(BootstrapIcons.chevron_down, size: 16, color: _mutedFg(context)),
                        ),
                      ],
                    ),
                  );
            return Opacity(
              opacity: widget.enabled ? 1 : 0.5,
              child: MouseRegion(
                cursor: widget.enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
                child: GestureDetector(
                  onTap: widget.enabled && widget.onChanged != null
                      ? () => controller.isOpen ? controller.close() : controller.open()
                      : null,
                  child: trigger,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
