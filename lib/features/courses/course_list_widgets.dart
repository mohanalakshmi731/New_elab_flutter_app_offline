part of 'course_list_view.dart';

/// Tailwind colours / shadows used by the course list (colours forward to the
/// Tailwind v4 palette in [Tw]).
///
/// Radii in this app (`src/style.css` `@theme inline`): `rounded-sm` 12,
/// `rounded-md` 14, `rounded-lg` 16, `rounded-xl` 20, `rounded-2xl` 16,
/// `rounded` 4.
class _CC {
  _CC._();
  static const rose100 = Tw.rose100;
  static const rose400 = Tw.rose400;
  static const rose700 = Tw.rose700;
  static const rose950 = Tw.rose950;
  static const emerald950 = Tw.emerald950;
  static const amber100 = Tw.amber100;
  static const violet100 = Tw.violet100;
  static const violet400 = Tw.violet400;
  static const sky400 = Tw.sky400;
  static const sky600 = Tw.sky600;
  static const sky950 = Tw.sky950;
  static const orange50 = Tw.orange50;
  static const orange100 = Tw.orange100;
  static const orange950 = Tw.orange950;
  static const yellow50 = Tw.yellow50;
  static const yellow600 = Tw.yellow600;
  static const yellow950 = Tw.yellow950;
  static const red400 = Tw.red400;
  static const blue300 = Tw.blue300;

  static const _a05 = Color(0x0D000000);
  static const _a10 = Color(0x1A000000);

  /// `--shadow-xs: 0 1px 3px 0 hsl(0 0% 0% / .05)`
  static const shadowXs = [BoxShadow(color: _a05, blurRadius: 3, offset: Offset(0, 1))];

  /// `--shadow-sm` (also `shadow`): `0 1px 3px 0 /.1, 0 1px 2px -1px /.1`
  static const shadowSm = [
    BoxShadow(color: _a10, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _a10, blurRadius: 2, spreadRadius: -1, offset: Offset(0, 1)),
  ];

  /// `--shadow-md: 0 1px 3px 0 /.1, 0 2px 4px -1px /.1`
  static const shadowMd = [
    BoxShadow(color: _a10, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _a10, blurRadius: 4, spreadRadius: -1, offset: Offset(0, 2)),
  ];

  /// `--shadow-lg: 0 1px 3px 0 /.1, 0 4px 6px -1px /.1`
  static const shadowLg = [
    BoxShadow(color: _a10, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _a10, blurRadius: 6, spreadRadius: -1, offset: Offset(0, 4)),
  ];

  /// `--shadow-xl: 0 1px 3px 0 /.1, 0 8px 10px -1px /.1`
  static const shadowXl = [
    BoxShadow(color: _a10, blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: _a10, blurRadius: 10, spreadRadius: -1, offset: Offset(0, 8)),
  ];

  /// `ring-2 ring-primary/40` (focus ring of the plain inputs).
  static BoxShadow ring(Color primary) => BoxShadow(color: primary.withValues(alpha: 0.4), spreadRadius: 2);
}

/// `style.css`: `table .bi { font-size: 18px }` — an unlayered rule, so every
/// Bootstrap icon inside a `<table>` is 18px whatever its `text-*` class.
const double _kTableIconSize = 18;

/// Where a status pill is drawn — each place has its own palette on the web.
enum _PillKind { table, header, thumbnail }

/// `(background, text, border, dot)` of a status pill.
(Color, Color, Color, Color) _pillColors(Object? status, _PillKind kind, bool dark) {
  final published = status == 'published';
  final draft = status == 'draft';
  final dot = published ? Tw.emerald500 : (draft ? Tw.rose500 : Tw.slate400);
  if (kind == _PillKind.thumbnail) {
    if (published) return (Tw.emerald50.withValues(alpha: 0.9), Tw.emerald700, Tw.emerald200, dot);
    if (draft) return (Tw.rose50.withValues(alpha: 0.9), _CC.rose700, Tw.rose200, dot);
    return (Tw.slate100.withValues(alpha: 0.9), Tw.slate600, Tw.slate200, dot);
  }
  if (dark) {
    if (published) {
      return (Tw.emerald500.withValues(alpha: 0.1), Tw.emerald400, Tw.emerald500.withValues(alpha: 0.2), dot);
    }
    if (draft) return (Tw.rose500.withValues(alpha: 0.1), _CC.rose400, Tw.rose500.withValues(alpha: 0.2), dot);
    // header: `bg-slate-50 dark:bg-slate-850` (no such colour → stays slate-50).
    return kind == _PillKind.table
        ? (Tw.slate800, Tw.slate400, Tw.slate700, dot)
        : (Tw.slate50, Tw.slate400, Tw.slate800, dot);
  }
  if (published) return (Tw.emerald50, Tw.emerald700, Tw.emerald200, dot);
  if (draft) return (Tw.rose50, _CC.rose700, Tw.rose200, dot);
  return kind == _PillKind.table
      ? (Tw.slate100, Tw.slate600, Tw.slate200, dot)
      : (Tw.slate50, Tw.slate700, Tw.slate200, dot);
}

/// `hover:bg-emerald-100` / `hover:bg-rose-100` / `hover:bg-slate-200` of the
/// clickable curriculum pill (light mode only).
Color? _pillHoverBg(Object? status, bool dark) {
  if (dark) return null;
  if (status == 'published') return Tw.emerald100;
  if (status == 'draft') return _CC.rose100;
  return Tw.slate200;
}

/// `inline-flex items-center gap-1.5 rounded-full border` status pill with
/// the coloured dot.
class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, required this.label, required this.kind, this.onTap, this.trailing});

  final Object? status;
  final String label;
  final _PillKind kind;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final (bg, fg, border, dot) = _pillColors(status, kind, dark);
    final thumb = kind == _PillKind.thumbnail;
    // table `px-3 py-1`, header `px-2.5 py-0.5`, thumbnail `px-2 py-0.5`.
    final padding = switch (kind) {
      _PillKind.table => const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      _PillKind.header => const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      _PillKind.thumbnail => const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    };
    Widget pill(bool hovered) => AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: padding,
      decoration: BoxDecoration(
        color: hovered ? (_pillHoverBg(status, dark) ?? bg) : bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
          ),
          SizedBox(width: thumb ? 4 : 6),
          Text(
            label,
            style: TextStyle(fontSize: thumb ? 11 : 12, fontWeight: FontWeight.w600, color: fg, height: 16 / 12),
          ),
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
        ],
      ),
    );
    if (onTap == null) return pill(false);
    return _Hover(onTap: onTap, builder: pill);
  }
}

/// Hover-aware builder (`hover:bg-…` classes).
class _Hover extends StatefulWidget {
  const _Hover({required this.builder, this.onTap, this.cursor = SystemMouseCursors.click});
  final Widget Function(bool hovered) builder;
  final VoidCallback? onTap;
  final MouseCursor cursor;

  @override
  State<_Hover> createState() => _HoverState();
}

class _HoverState extends State<_Hover> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final child = widget.builder(_hovered);
    return MouseRegion(
      cursor: widget.onTap == null ? MouseCursor.defer : widget.cursor,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: widget.onTap == null
          ? child
          : GestureDetector(behavior: HitTestBehavior.opaque, onTap: widget.onTap, child: child),
    );
  }
}

/// The square / round icon-only action buttons (`w-8 h-8 rounded-lg flex
/// items-center justify-center hover:bg-x text-y`). `rounded-lg` is 16px
/// here, so a `w-8` button is a circle.
class _IconAction extends StatelessWidget {
  const _IconAction({
    required this.icon,
    required this.color,
    required this.onTap,
    this.tooltip,
    this.hoverBg,
    this.hoverColor,
    this.bg,
    this.size = 32,
    this.iconSize = 16,
    this.radius = 16,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String? tooltip;
  final Color? hoverBg;

  /// `hover:text-…`
  final Color? hoverColor;
  final Color? bg;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    Widget w = _Hover(
      onTap: onTap,
      builder: (h) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: h ? (hoverBg ?? bg) : bg, borderRadius: BorderRadius.circular(radius)),
        child: Icon(icon, size: iconSize, color: h ? (hoverColor ?? color) : color),
      ),
    );
    if (tooltip != null) w = Tooltip(message: tooltip!, child: w);
    return w;
  }
}

/// `<label class="text-sm font-medium text-slate-700 dark:text-slate-300">`
/// with the optional `<span class="text-rose-500">*</span>`.
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text, {this.required = false});
  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) => Text.rich(
    TextSpan(
      text: text,
      children: [
        if (required)
          const TextSpan(
            text: ' *',
            style: TextStyle(color: Tw.rose500),
          ),
      ],
    ),
    style: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      height: 20 / 14,
      color: context.isDark ? Tw.slate300 : Tw.slate700,
    ),
  );
}

/// `<div class="mt-4 flex flex-col gap-1.5"><label/>…</div>` — [top] includes
/// the `<DialogContent>` grid's `gap-4` (16) on top of the `mt-*`.
class _LabeledInput extends StatelessWidget {
  const _LabeledInput({required this.label, required this.child, this.required = false, this.top = 28});
  final String label;
  final Widget child;
  final bool required;
  final double top;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: top),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FieldLabel(label, required: required),
        const SizedBox(height: 6),
        child,
      ],
    ),
  );
}

/// The dialogs' header: tinted `w-9 h-9 rounded-xl` icon box +
/// `DialogDescription` title, with the wrapper's `mb-1`.
class _DialogHeader extends StatelessWidget {
  const _DialogHeader({required this.icon, required this.iconColor, required this.iconBg, required this.title});
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(right: 28, bottom: 4),
    child: Row(
      children: [
        Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(20)),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: context.isDark ? Tw.slate200 : Tw.slate800,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Kind of [_RoundedButton] (shadcn `<Button variant>`).
enum _BtnKind { primary, outline, solid }

/// shadcn `<Button>` with the radius the template sets (`rounded-xl` = 20 by
/// default, `rounded` = 4). `AppButton` has a fixed `rounded-md` radius.
class _RoundedButton extends StatefulWidget {
  const _RoundedButton({
    required this.onPressed,
    this.label,
    this.leading,
    this.kind = _BtnKind.primary,
    this.radius = 20,
    this.background,
    this.hoverBackground,
    this.gap = 8,
    this.hPad = 16,
    this.shadow,
  });

  final VoidCallback? onPressed;
  final String? label;

  /// Icon / spinner before the label.
  final Widget? leading;
  final _BtnKind kind;
  final double radius;

  /// [_BtnKind.solid] colours (`bg-rose-600 hover:bg-rose-700 text-white`).
  final Color? background;
  final Color? hoverBackground;

  /// Space between [leading] and the label (`gap-2` + any `mr-1` on the icon).
  final double gap;
  final double hPad;

  /// Defaults to `shadow-xs` (filled / outline buttons).
  final List<BoxShadow>? shadow;

  @override
  State<_RoundedButton> createState() => _RoundedButtonState();
}

class _RoundedButtonState extends State<_RoundedButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final scheme = context.colors;
    final enabled = widget.onPressed != null;
    final hovered = enabled && _hovered;

    Color bg;
    Color fg;
    BorderSide side = BorderSide.none;
    switch (widget.kind) {
      case _BtnKind.primary:
        // `bg-primary text-primary-foreground hover:bg-primary/90`
        bg = hovered ? scheme.primary.withValues(alpha: 0.9) : scheme.primary;
        fg = scheme.onPrimary;
      case _BtnKind.outline:
        // `border bg-background hover:bg-accent hover:text-accent-foreground
        // dark:bg-input/30 dark:border-input dark:hover:bg-input/50`
        bg = dark
            ? AppColors.darkInput.withValues(alpha: hovered ? 0.5 : 0.3)
            : (hovered ? AppColors.accent : AppColors.background);
        fg = hovered ? AppColors.accentForeground : scheme.onSurface;
        side = BorderSide(color: dark ? AppColors.darkInput : AppColors.border);
      case _BtnKind.solid:
        bg = hovered ? (widget.hoverBackground ?? widget.background!) : widget.background!;
        fg = Colors.white;
    }

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.leading != null)
          IconTheme.merge(
            data: IconThemeData(color: fg, size: 14),
            child: widget.leading!,
          ),
        if (widget.leading != null && widget.label != null) SizedBox(width: widget.gap),
        if (widget.label != null)
          Flexible(
            child: Text(
              widget.label!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fg, height: 20 / 14),
            ),
          ),
      ],
    );

    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 36,
      padding: EdgeInsets.symmetric(horizontal: widget.hPad),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(widget.radius),
        border: side == BorderSide.none ? null : Border.fromBorderSide(side),
        boxShadow: widget.shadow ?? _CC.shadowXs,
      ),
      child: content,
    );
    if (!enabled) return Opacity(opacity: 0.5, child: button);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: widget.onPressed, child: button),
    );
  }
}

/// Submit button with the `bi-arrow-repeat animate-spin` / icon swap and a
/// loading text (`:disabled="isCreateBtnLoading"`). The icons carry `mr-1`
/// on top of the button's `gap-2`.
class _SubmitButton extends StatelessWidget {
  const _SubmitButton({
    required this.loading,
    required this.label,
    required this.onPressed,
    this.loadingLabel,
    this.icon,
    this.radius = 20,
    this.hPad = 16,
    this.shadow,
  });

  final bool loading;
  final String label;
  final String? loadingLabel;
  final IconData? icon;
  final VoidCallback onPressed;
  final double radius;
  final double hPad;
  final List<BoxShadow>? shadow;

  @override
  Widget build(BuildContext context) {
    final showText = !loading || loadingLabel != null;
    return _RoundedButton(
      onPressed: loading ? null : onPressed,
      radius: radius,
      hPad: hPad,
      shadow: shadow,
      gap: 12,
      leading: loading ? const SpinIcon(size: 14) : (icon == null ? null : Icon(icon)),
      label: showText ? (loading ? loadingLabel : label) : null,
    );
  }
}

/// Body of the delete / detach confirmations: red icon circle, bold title,
/// centred description. The extra 16 below is the `<DialogContent>` grid
/// `gap-4` before the footer's `mt-4`.
class _DangerBody extends StatelessWidget {
  const _DangerBody({required this.icon, required this.title, required this.description});
  final IconData icon;
  final String title;
  final InlineSpan description;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: dark ? Tw.rose500.withValues(alpha: 0.1) : _CC.rose100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: Tw.rose500),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: dark ? Tw.slate200 : Tw.slate800),
          ),
          const SizedBox(height: 12),
          Text.rich(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 14, color: Tw.slate500),
          ),
        ],
      ),
    );
  }
}

/// `"<span class="font-semibold text-slate-700 dark:text-slate-300">name</span>"`
TextSpan _boldName(BuildContext context, String name) => TextSpan(
  text: '"$name"',
  style: TextStyle(fontWeight: FontWeight.w600, color: context.isDark ? Tw.slate300 : Tw.slate700),
);

/// shadcn `<DropdownMenu>` / `<Select>` popup anchored to a custom trigger
/// (`bg-popover rounded-md border p-1 shadow-md`). [width] `null` = as wide
/// as the trigger.
class _Dropdown extends StatefulWidget {
  const _Dropdown({required this.trigger, required this.items, this.width, this.radius = 14});
  final Widget Function(VoidCallback toggle, bool open) trigger;
  final List<Widget> items;
  final double? width;
  final double radius;

  @override
  State<_Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<_Dropdown> {
  final _menu = MenuController();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return LayoutBuilder(
      builder: (context, c) {
        final width = widget.width ?? (c.maxWidth.isFinite ? c.maxWidth : 240.0);
        return MenuAnchor(
          controller: _menu,
          crossAxisUnconstrained: false,
          alignmentOffset: const Offset(0, 4),
          style: MenuStyle(
            minimumSize: WidgetStatePropertyAll(Size(width, 0)),
            maximumSize: WidgetStatePropertyAll(Size(width, 360)),
            backgroundColor: WidgetStatePropertyAll(dark ? AppColors.darkPopover : AppColors.popover),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            shadowColor: const WidgetStatePropertyAll(Color(0x33000000)),
            elevation: const WidgetStatePropertyAll(3),
            padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(widget.radius),
                side: BorderSide(color: dark ? AppColors.darkBorder : AppColors.border),
              ),
            ),
          ),
          menuChildren: widget.items,
          builder: (context, controller, _) =>
              widget.trigger(() => controller.isOpen ? controller.close() : controller.open(), controller.isOpen),
        );
      },
    );
  }
}

/// `<DropdownMenuItem>` / `<SelectItem>` (`rounded-sm px-2 py-1.5 text-sm
/// focus:bg-accent focus:text-accent-foreground`). A leading `<i class="mr-2">`
/// sits 16px from the text (`gap-2` + `mr-2`); a [select] item keeps `pr-8`
/// for the check drawn at `right-2` when [selected]. [width] = the content
/// width for `w-full justify-between` rows.
Widget _menuItem({
  required Widget child,
  required VoidCallback onPressed,
  IconData? icon,
  Color? iconColor,
  bool selected = false,
  bool select = false,
  double? width,
}) => Builder(
  builder: (context) {
    final fg = context.colors.onSurface;
    Widget content = icon == null
        ? child
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 16),
              Flexible(child: child),
            ],
          );
    if (select) {
      content = Row(
        mainAxisSize: width == null ? MainAxisSize.min : MainAxisSize.max,
        children: [
          if (width == null) Flexible(child: content) else Expanded(child: content),
          const SizedBox(width: 8),
          SizedBox(width: 16, child: selected ? const Icon(Icons.check, size: 16) : null),
        ],
      );
    }
    content = width != null
        ? SizedBox(width: width, child: content)
        // Long names wrap instead of overflowing the fixed-width menu.
        : ConstrainedBox(constraints: const BoxConstraints(maxWidth: 240), child: content);
    return MenuItemButton(
      onPressed: onPressed,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size(0, 32)),
        padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 8)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 14, height: 20 / 14)),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
        backgroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.hovered) || s.contains(WidgetState.focused)
              ? AppColors.accent
              : Colors.transparent,
        ),
        foregroundColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.hovered) || s.contains(WidgetState.focused) ? AppColors.accentForeground : fg,
        ),
        iconColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.hovered) || s.contains(WidgetState.focused) ? AppColors.accentForeground : fg,
        ),
      ),
      child: content,
    );
  },
);

/// `<DropdownMenuLabel>` / `<SelectLabel>` (`px-2 py-1.5 text-sm font-medium`).
Widget _menuLabel(String text) => Padding(
  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
  child: Text(
    text,
    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14),
  ),
);

/// `<DropdownMenuSeparator>` (`bg-border -mx-1 my-1 h-px`)
Widget _menuSeparator() => Builder(
  builder: (context) => Container(
    height: 1,
    margin: const EdgeInsets.symmetric(vertical: 4),
    color: context.isDark ? AppColors.darkBorder : AppColors.border,
  ),
);

/// Trigger of the dropdowns: an outline `<Button>` with a trailing
/// `<ChevronDown>` ([button] — `hover:bg-accent hover:text-accent-foreground`,
/// chevron in the text colour) or a `<SelectTrigger>` (only
/// `dark:hover:bg-input/50`, muted chevron and placeholder).
class _OutlineTrigger extends StatelessWidget {
  const _OutlineTrigger({
    required this.onTap,
    required this.text,
    this.leading,
    this.maxTextWidth,
    this.height = 36,
    this.radius = 20,
    this.background,
    this.borderColor,
    this.textStyle,
    this.trailingBadge,
    this.spaceBetween = false,
    this.button = true,
    this.placeholder = false,
    this.enabled = true,
    this.chevronSize = 16,
    this.chevronGap = 8,
    this.shadow,
    this.center = false,
  });

  final VoidCallback onTap;
  final String text;
  final Widget? leading;
  final double? maxTextWidth;
  final double height;
  final double radius;
  final Color? background;
  final Color? borderColor;
  final TextStyle? textStyle;

  /// Badge right after the text (`ml-1` + `gap-2`).
  final Widget? trailingBadge;

  /// `justify-between` (chevron at the far right).
  final bool spaceBetween;

  /// `<Button variant="outline">` (vs `<SelectTrigger>`).
  final bool button;

  /// `data-[placeholder]:text-muted-foreground`
  final bool placeholder;
  final bool enabled;
  final double chevronSize;
  final double chevronGap;

  /// Defaults to `shadow-xs`.
  final List<BoxShadow>? shadow;

  /// A stretched `<Button>` (`justify-center`): content centred. Only with a
  /// tight width.
  final bool center;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final muted = dark ? AppColors.darkMutedForeground : AppColors.mutedForeground;
    final baseBg = background ?? (dark ? AppColors.darkInput.withValues(alpha: 0.3) : AppColors.background);

    Widget paint(bool h) {
      final hovered = enabled && h;
      final Color bg;
      if (!hovered) {
        bg = baseBg;
      } else if (dark) {
        bg = AppColors.darkInput.withValues(alpha: 0.5);
      } else {
        bg = button ? AppColors.accent : baseBg;
      }
      final fg = hovered && button ? AppColors.accentForeground : (placeholder ? muted : context.colors.onSurface);
      final chevronColor = (button ? fg : muted).withValues(alpha: 0.5);
      Widget label = Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 14, height: 20 / 14, color: fg).merge(textStyle),
      );
      if (maxTextWidth != null) {
        label = ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxTextWidth!),
          child: label,
        );
      }
      final Widget textRow = trailingBadge == null
          ? label
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: label),
                const SizedBox(width: 12),
                trailingBadge!,
              ],
            );
      return AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        alignment: center ? Alignment.center : null,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor ?? (dark ? AppColors.darkInput : AppColors.border)),
          boxShadow: shadow ?? _CC.shadowXs,
        ),
        child: IconTheme.merge(
          data: IconThemeData(color: fg, size: 14),
          child: Row(
            mainAxisSize: spaceBetween ? MainAxisSize.max : MainAxisSize.min,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              if (spaceBetween) Expanded(child: textRow) else Flexible(child: textRow),
              SizedBox(width: chevronGap),
              Icon(BootstrapIcons.chevron_down, size: chevronSize * 0.8, color: chevronColor),
            ],
          ),
        ),
      );
    }

    final trigger = _Hover(onTap: enabled ? onTap : null, builder: paint);
    return enabled
        ? trigger
        : Opacity(
            opacity: 0.5,
            child: MouseRegion(cursor: SystemMouseCursors.forbidden, child: trigger),
          );
  }
}

/// `rounded-full px-2 py-0.5 text-[10px] font-bold` count badge.
class _CountBadge extends StatelessWidget {
  const _CountBadge(this.count, {this.bg, this.fg, this.fontSize = 10, this.bold = true});
  final Object count;
  final Color? bg;
  final Color? fg;
  final double fontSize;
  final bool bold;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: bg ?? (context.isDark ? Tw.slate800 : Tw.slate200),
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      '$count',
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        color: fg,
        height: 1.4,
      ),
    ),
  );
}

/// Disabled `<Input>` / `<SelectTrigger>` of the Overview tab
/// (`rounded-md bg-slate-50 border-slate-200 text-slate-500
/// cursor-not-allowed disabled:opacity-50`).
class _DisabledBox extends StatelessWidget {
  const _DisabledBox({required this.text, this.chevron = false});
  final String text;
  final bool chevron;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Opacity(
      opacity: 0.5,
      child: MouseRegion(
        cursor: SystemMouseCursors.forbidden,
        child: Container(
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: dark ? Tw.slate900.withValues(alpha: 0.5) : Tw.slate50,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: dark ? Tw.slate800 : Tw.slate200),
            boxShadow: _CC.shadowXs,
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, color: dark ? Tw.slate400 : Tw.slate500),
                ),
              ),
              if (chevron)
                Icon(
                  BootstrapIcons.chevron_down,
                  size: 13,
                  color: (dark ? Tw.slate400 : Tw.slate500).withValues(alpha: 0.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A plain `<input>` / `<select>` styled with Tailwind classes, e.g.
/// `px-3 py-2.5 text-sm border border-slate-200 dark:border-slate-700
/// rounded-xl bg-white dark:bg-card shadow-sm focus:ring-2
/// focus:ring-primary/40 focus:border-primary` (the defaults).
class _WebInput extends StatefulWidget {
  const _WebInput({
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.prefixIconSize = 16,
    this.textLeft = 36,
    this.onChanged,
    this.onSubmitted,
    this.maxLength,
    this.radius = 20,
    this.fontSize = 14,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    this.plain = false,
  });

  final TextEditingController controller;
  final String? hint;

  /// Absolutely placed icon at `left-3` (`text-slate-400`).
  final IconData? prefixIcon;
  final double prefixIconSize;

  /// `pl-9` (36) / `pl-8` (32) when there is a [prefixIcon].
  final double textLeft;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final int? maxLength;
  final double radius;
  final double fontSize;
  final EdgeInsets padding;

  /// `border rounded-md p-2 w-full` — default border colour, transparent,
  /// no shadow or focus ring (the edit-concept dialog).
  final bool plain;

  @override
  State<_WebInput> createState() => _WebInputState();
}

class _WebInputState extends State<_WebInput> {
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted && _focused != _focus.hasFocus) setState(() => _focused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final fg = context.colors.onSurface;
    final plain = widget.plain;
    final ring = _focused && !plain;
    final Color border = ring
        ? primary
        : plain
        ? (dark ? AppColors.darkBorder : AppColors.border)
        : (dark ? Tw.slate700 : Tw.slate200);
    final lineHeight = widget.fontSize >= 16 ? 24.0 : 20.0;
    final icon = widget.prefixIcon;
    final pad = widget.padding;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: plain ? Colors.transparent : (dark ? AppColors.darkCard : Colors.white),
        borderRadius: BorderRadius.circular(widget.radius),
        border: Border.all(color: border),
        boxShadow: plain ? null : [if (ring) _CC.ring(primary), ..._CC.shadowSm],
      ),
      child: Row(
        children: [
          if (icon != null)
            Padding(
              padding: EdgeInsets.only(left: 12, right: widget.textLeft - 12 - widget.prefixIconSize),
              child: Icon(icon, size: widget.prefixIconSize, color: Tw.slate400),
            ),
          Expanded(
            child: TextField(
              controller: widget.controller,
              focusNode: _focus,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              maxLength: widget.maxLength,
              cursorColor: fg,
              style: TextStyle(fontSize: widget.fontSize, height: lineHeight / widget.fontSize, color: fg),
              decoration: InputDecoration(
                isDense: true,
                filled: false,
                counterText: '',
                hintText: widget.hint,
                hintStyle: TextStyle(
                  fontSize: widget.fontSize,
                  height: lineHeight / widget.fontSize,
                  color: fg.withValues(alpha: 0.5),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding: icon == null ? pad : pad.copyWith(left: 0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `border border-dashed … rounded-xl` box (Flutter has no dashed borders).
class _DashedBox extends StatelessWidget {
  const _DashedBox({required this.child, required this.color, this.fill, this.padding = EdgeInsets.zero});

  final Widget child;
  final Color color;

  /// `rounded-xl`
  static const double radius = 20;
  final Color? fill;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _DashedPainter(color, radius, fill),
    child: Padding(padding: padding, child: child),
  );
}

class _DashedPainter extends CustomPainter {
  _DashedPainter(this.color, this.radius, this.fill);
  final Color color;
  final double radius;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius((Offset.zero & size).deflate(0.5), Radius.circular(radius));
    if (fill != null) canvas.drawRRect(rrect, Paint()..color = fill!);
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final path = Path()..addRRect(rrect);
    // Browsers draw 1px dashes about 3px long with 3px gaps.
    const dash = 3.0;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedPainter old) => old.color != color || old.radius != radius || old.fill != fill;
}

/// Lays [children] out [columns] per row with [gap] (`grid grid-cols-n`).
/// A child wrapped in [_Span] fills a whole row.
class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.children, this.gap = 16});
  final int columns;
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    var pending = <Widget>[];
    void flush() {
      if (pending.isEmpty) return;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < columns; i++) ...[
              if (i > 0) SizedBox(width: gap),
              Expanded(child: i < pending.length ? pending[i] : const SizedBox.shrink()),
            ],
          ],
        ),
      );
      pending = [];
    }

    for (final c in children) {
      if (columns <= 1) {
        rows.add(c);
      } else if (c is _Span) {
        flush();
        rows.add(c);
      } else {
        pending.add(c);
        if (pending.length == columns) flush();
      }
    }
    flush();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rows.length; i++) ...[if (i > 0) SizedBox(height: gap), rows[i]],
      ],
    );
  }
}

/// A [_Grid] cell spanning the whole row (`col-span-full`).
class _Span extends StatelessWidget {
  const _Span({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// `<Button variant="outline" class="rounded-xl w-full sm:w-auto">Cancel</Button>`
Widget _cancelButton(VoidCallback close, {String label = 'Cancel', double radius = 20}) =>
    _RoundedButton(label: label, kind: _BtnKind.outline, radius: radius, onPressed: close);

/// `<Button class="rounded-xl bg-rose-600 hover:bg-rose-700 text-white"><i class="mr-1"/> …`
Widget _dangerButton({required IconData icon, required String label, required VoidCallback onPressed}) =>
    _RoundedButton(
      leading: Icon(icon),
      label: label,
      gap: 12,
      kind: _BtnKind.solid,
      background: Tw.rose600,
      hoverBackground: Tw.rose700,
      onPressed: onPressed,
    );
