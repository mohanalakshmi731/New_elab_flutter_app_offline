import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../dashboard/web_style.dart' show WebShadow;

/// Tailwind colours used by `teacherschedules.vue` that `Tw` lacks.
///
/// Radii follow the app's CSS tokens: `rounded-lg` 16, `rounded-xl` 20,
/// `rounded-2xl` 16, `rounded-3xl` 24.
class TsTw {
  TsTw._();
  static const cyan50 = Color(0xFFECFEFF);
  static const cyan100 = Color(0xFFCFFAFE);
  static const cyan200 = Color(0xFFA5F3FC);
  static const cyan300 = Color(0xFF67E8F9);
  static const cyan400 = Color(0xFF22D3EE);
  static const cyan600 = Color(0xFF0891B2);
  static const cyan700 = Color(0xFF0E7490);
  static const cyan800 = Color(0xFF155E75);
  static const cyan900 = Color(0xFF164E63);
  static const blue300 = Color(0xFF93C5FD);
  static const blue800 = Color(0xFF1E40AF);
  static const blue900 = Color(0xFF1E3A8A);
  static const emerald300 = Color(0xFF6EE7B7);
  static const emerald900 = Color(0xFF064E3B);
  static const rose100 = Color(0xFFFFE4E6);
  static const rose400 = Color(0xFFFB7185);
  static const rose900 = Color(0xFF881337);
  static const indigo900 = Color(0xFF312E81);
}

/// `shadow-sm` / `shadow-md` with the app's (light) CSS tokens. The tokens
/// are plain black, so `shadow-cyan-500/20` style colours don't apply.
const tsShadowSm = WebShadow.sm;
const tsShadowMd = WebShadow.md;

/// `<Input class="text-base">` keeps shadcn's `md:text-sm`: 16 px below
/// 768 px, 14 px above.
double tsInputFontSize(BuildContext context) => context.isMd ? 14 : 16;

/// `text-xs font-semibold text-slate-400 uppercase tracking-widest` labels
/// (the filter / basic-info captions).
class TsCaption extends StatelessWidget {
  const TsCaption(this.text, {super.key, this.bold = false, this.color});
  final String text;
  final bool bold;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          letterSpacing: 1.2,
          color: color ?? (context.isDark && !bold ? Tw.slate500 : Tw.slate400),
        ),
      );
}

/// `<Label class="text-sm font-semibold text-slate-600 dark:text-slate-400">`
/// with an optional red `*`.
class TsLabel extends StatelessWidget {
  const TsLabel(this.text, {super.key, this.required = false});
  final String text;
  final bool required;

  @override
  Widget build(BuildContext context) => Text.rich(
        TextSpan(children: [
          TextSpan(text: text),
          if (required) const TextSpan(text: ' *', style: TextStyle(color: Tw.red500)),
        ]),
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: context.isDark ? Tw.slate400 : Tw.slate600,
        ),
      );
}

/// A label above a control (`space-y-2` / `space-y-1.5`).
class TsField extends StatelessWidget {
  const TsField({super.key, required this.label, required this.child, this.gap = 8});
  final Widget label;
  final Widget child;
  final double gap;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [label, SizedBox(height: gap), child],
      );
}

/// Inputs / selects styled `h-10|h-11 rounded-xl border-slate-200
/// dark:border-slate-700 bg-slate-50 dark:bg-slate-800` (or white / slate-900).
class TsInputTheme extends StatelessWidget {
  const TsInputTheme({super.key, required this.child, this.height = 44, this.fill});
  final Widget child;
  final double height;

  /// Overrides the slate-50 / slate-800 fill.
  final Color? fill;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final theme = Theme.of(context);
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide(color: dark ? Tw.slate700 : Tw.slate200),
    );
    final vPad = ((height - 20) / 2).clamp(6.0, 16.0);
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          filled: true,
          fillColor: fill ?? (dark ? Tw.slate800 : Tw.slate50),
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: vPad),
          border: border,
          enabledBorder: border,
          disabledBorder: border,
          focusedBorder: border.copyWith(borderSide: const BorderSide(color: Tw.cyan500, width: 1.5)),
        ),
      ),
      child: child,
    );
  }
}

/// The square / round icon buttons (`w-8 h-8 rounded-lg border …`,
/// `w-10 h-10 rounded-xl border bg-slate-50 …`).
class TsIconButton extends StatefulWidget {
  const TsIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.size = 32,
    this.radius = 16,
    this.iconSize = 14,
    this.color,
    this.hoverColor,
    this.background,
    this.hoverBackground,
    this.bordered = true,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final double size;
  final double radius;
  final double iconSize;
  final Color? color;
  final Color? hoverColor;
  final Color? background;
  final Color? hoverBackground;
  final bool bordered;
  final String? tooltip;

  @override
  State<TsIconButton> createState() => _TsIconButtonState();
}

class _TsIconButtonState extends State<TsIconButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final fg = _hover ? (widget.hoverColor ?? widget.color) : widget.color;
    final bg = _hover ? (widget.hoverBackground ?? widget.background) : widget.background;
    Widget w = MouseRegion(
      cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: widget.size,
          height: widget.size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg ?? Colors.transparent,
            borderRadius: BorderRadius.circular(widget.radius),
            border: widget.bordered ? Border.all(color: dark ? Tw.slate700 : Tw.slate200) : null,
          ),
          child: Icon(widget.icon, size: widget.iconSize, color: fg ?? (dark ? Tw.slate300 : Tw.slate600)),
        ),
      ),
    );
    if (widget.tooltip != null) w = Tooltip(message: widget.tooltip!, child: w);
    return w;
  }
}

/// The page's coloured buttons (`h-11 px-5 bg-cyan-500 hover:bg-cyan-400
/// text-white rounded-xl shadow-md shadow-cyan-500/20`) and their outline /
/// ghost-with-border variants.
class TsButton extends StatefulWidget {
  const TsButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.color = Tw.cyan500,
    this.hoverColor = TsTw.cyan400,
    this.foreground = Colors.white,
    this.hoverForeground,
    this.height = 44,
    this.hPad = 20,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w600,
    this.shadow = false,
    this.outline = false,
    this.loading = false,
    this.loadingLabel,
    this.iconSize,
    this.gap = 8,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final Color color;
  final Color hoverColor;
  final Color foreground;

  /// Text / icon colour on hover (defaults to [foreground]).
  final Color? hoverForeground;
  final double height;
  final double hPad;
  final double fontSize;
  final FontWeight fontWeight;
  final bool shadow;

  /// `variant="outline"` / `variant="ghost" border`: transparent (or white /
  /// slate-900) with a slate border; [color] is then the background.
  final bool outline;
  final bool loading;
  final String? loadingLabel;
  final double? iconSize;

  /// Icon–label spacing (`gap-2` / `mr-2` = 8, `gap-1.5` = 6).
  final double gap;

  /// The outline button (`border-slate-200 dark:border-slate-700 bg-white
  /// dark:bg-slate-900 text-slate-700 dark:text-slate-200`).
  static TsButton outlined(
    BuildContext context, {
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
    bool filled = true,
    double height = 44,
    double hPad = 20,
    FontWeight fontWeight = FontWeight.w600,
    Color? foreground,
  }) {
    final dark = context.isDark;
    final bg = filled ? (dark ? Tw.slate900 : Colors.white) : Colors.transparent;
    return TsButton(
      label: label,
      onPressed: onPressed,
      icon: icon,
      outline: true,
      color: bg,
      // shadcn outline / ghost keep `hover:bg-accent hover:text-accent-foreground`
      // (orange) in light mode; dark mode uses `dark:hover:bg-input/50`
      // (outline) or `dark:hover:bg-accent/50` (ghost) and keeps the
      // `dark:text-*` colour.
      hoverColor: dark
          ? (filled ? AppColors.darkInput.withValues(alpha: 0.5) : AppColors.accent.withValues(alpha: 0.5))
          : AppColors.accent,
      foreground: foreground ?? (dark ? Tw.slate200 : Tw.slate700),
      hoverForeground: dark ? null : AppColors.accentForeground,
      height: height,
      hPad: hPad,
      fontWeight: fontWeight,
    );
  }

  @override
  State<TsButton> createState() => _TsButtonState();
}

class _TsButtonState extends State<TsButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final disabled = widget.onPressed == null || widget.loading;
    final bg = _hover && !disabled ? widget.hoverColor : widget.color;
    final fg = _hover && !disabled ? (widget.hoverForeground ?? widget.foreground) : widget.foreground;
    final text = widget.loading ? (widget.loadingLabel ?? widget.label) : widget.label;
    final iconSize = widget.iconSize ?? widget.fontSize;
    Widget w = MouseRegion(
      cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: disabled ? null : widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: widget.height,
          padding: EdgeInsets.symmetric(horizontal: widget.hPad),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: widget.outline ? Border.all(color: dark ? Tw.slate700 : Tw.slate200) : null,
            boxShadow: widget.shadow ? tsShadowMd : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.loading) ...[
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                ),
                const SizedBox(width: 8),
              ] else if (widget.icon != null) ...[
                Icon(widget.icon, size: iconSize, color: fg),
                SizedBox(width: widget.gap),
              ],
              Flexible(
                child: Text(
                  text,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: widget.fontSize, fontWeight: widget.fontWeight, color: fg),
                ),
              ),
              if (widget.trailingIcon != null && !widget.loading) ...[
                SizedBox(width: widget.gap),
                Icon(widget.trailingIcon, size: iconSize, color: fg),
              ],
            ],
          ),
        ),
      ),
    );
    if (disabled) w = Opacity(opacity: 0.5, child: w);
    return w;
  }
}

/// `inline-flex items-center px-3 py-1 rounded-full text-sm font-semibold`
/// badges (optionally with the pulsing status dot).
class TsPill extends StatelessWidget {
  const TsPill({super.key, required this.text, required this.bg, required this.fg, this.dot, this.bold = false});
  final String text;
  final Color bg;
  final Color fg;
  final Color? dot;
  final bool bold;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (dot != null) ...[
            TsPulse(child: Container(width: 6, height: 6, decoration: BoxDecoration(color: dot, shape: BoxShape.circle))),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(text,
                style: TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.w700 : FontWeight.w600, color: fg)),
          ),
        ]),
      );
}

/// Tailwind `animate-pulse` (opacity 1 → .5 → 1 every 2s).
class TsPulse extends StatefulWidget {
  const TsPulse({super.key, required this.child});
  final Widget child;

  @override
  State<TsPulse> createState() => _TsPulseState();
}

class _TsPulseState extends State<TsPulse> with SingleTickerProviderStateMixin {
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
        child: widget.child,
      );
}

/// `.live-pulse` — the cyan ring that grows around the ongoing-class dot.
class TsLiveDot extends StatefulWidget {
  const TsLiveDot({super.key, required this.color, required this.borderColor});
  final Color color;
  final Color borderColor;

  @override
  State<TsLiveDot> createState() => _TsLiveDotState();
}

class _TsLiveDotState extends State<TsLiveDot> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          final t = (_c.value / 0.7).clamp(0.0, 1.0);
          return Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              border: Border.all(color: widget.borderColor, width: 4),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.5 * (1 - t)),
                  spreadRadius: 8 * t,
                ),
              ],
            ),
          );
        },
      );
}

/// `hover:bg-…` on a plain area (the accordion header row).
class TsHover extends StatefulWidget {
  const TsHover({super.key, required this.builder, this.onTap});
  final Widget Function(bool hover) builder;
  final VoidCallback? onTap;

  @override
  State<TsHover> createState() => _TsHoverState();
}

class _TsHoverState extends State<TsHover> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: widget.builder(_hover),
        ),
      );
}

/// The `<Popover><Calendar>` trigger: an outline button with a calendar icon
/// and the picked date (`YYYY-MM-DD`) or [placeholder].
class TsDateButton extends StatelessWidget {
  const TsDateButton({super.key, required this.text, required this.onPicked, this.initial});
  final String text;
  final DateTime? initial;
  final ValueChanged<DateTime> onPicked;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    // `variant="outline"`: hover is `bg-accent text-accent-foreground`
    // (light) / `bg-input/50` (dark).
    return TsHover(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDatePicker(
          context: context,
          initialDate: initial ?? now,
          firstDate: DateTime(now.year - 50),
          lastDate: DateTime(now.year + 50),
        );
        if (picked != null) onPicked(picked);
      },
      builder: (hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: hover
              ? (dark ? AppColors.darkInput.withValues(alpha: 0.5) : AppColors.accent)
              : (dark ? Tw.slate800 : Tw.slate50),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dark ? Tw.slate700 : Tw.slate200),
        ),
        child: Row(children: [
          const Icon(BootstrapIcons.calendar3, size: 16, color: Tw.slate400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontSize: 16,
                    color: dark ? Tw.slate300 : (hover ? AppColors.accentForeground : Tw.slate700))),
          ),
        ]),
      ),
    );
  }
}

/// `<Input type="time">` — the value is `HH:mm` (`''` when empty).
class TsTimeField extends StatelessWidget {
  const TsTimeField({super.key, required this.value, required this.onChanged});
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final parts = value.split(':');
    final h = parts.isNotEmpty ? int.tryParse(parts[0]) : null;
    final m = parts.length > 1 ? int.tryParse(parts[1]) : null;
    final initial = h != null && m != null ? TimeOfDay(hour: h, minute: m) : null;
    final shown = initial == null
        ? '--:-- --'
        : DateFormat('hh:mm a', 'en_US').format(DateTime(2000, 1, 1, initial.hour, initial.minute));
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () async {
        final picked = await showTimePicker(context: context, initialTime: initial ?? TimeOfDay.now());
        if (picked == null) return;
        String two(int n) => n.toString().padLeft(2, '0');
        onChanged('${two(picked.hour)}:${two(picked.minute)}');
      },
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: dark ? Tw.slate800 : Tw.slate50,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dark ? Tw.slate700 : Tw.slate200),
        ),
        child: Row(children: [
          Expanded(
            child: Text(shown,
                style: TextStyle(fontSize: 16, color: initial == null ? Tw.slate400 : (dark ? Colors.white : Tw.slate900))),
          ),
          Icon(BootstrapIcons.clock, size: 14, color: dark ? Tw.slate400 : Tw.slate500),
        ]),
      ),
    );
  }
}

/// A shadcn `<Table>` whose header gets the global `thead th` rule
/// (`bg-primary text-primary-foreground`) while keeping the template's
/// `text-xs font-semibold uppercase tracking-wider`.
class TsTable extends StatelessWidget {
  const TsTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.emptyText,
    this.flex,
    this.alignEnd = const {},
    this.minWidth = 0,
  });

  final List<String> columns;
  final List<List<Widget>> rows;
  final String emptyText;
  final List<int>? flex;
  final Set<int> alignEnd;

  /// Below this width the table scrolls horizontally (`overflow-x-auto`).
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final divider = dark ? Tw.slate800 : Tw.slate100;
    // `thead th { padding: .5rem 1rem }` / `<TableCell class="p-2">`.
    Widget cell(int i, Widget child, {required bool header}) => Expanded(
          flex: flex?[i] ?? 1,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: header ? 16 : 8, vertical: 8),
            child: Align(alignment: alignEnd.contains(i) ? Alignment.centerRight : Alignment.centerLeft, child: child),
          ),
        );
    final table = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          color: context.colors.primary,
          constraints: const BoxConstraints(minHeight: 40),
          child: Row(children: [
            for (var i = 0; i < columns.length; i++)
              cell(
                i,
                Text(columns[i].toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.6,
                      color: context.colors.onPrimary,
                    )),
                header: true,
              ),
          ]),
        ),
        if (rows.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
            child: Text(emptyText,
                textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Tw.slate400)),
          )
        else
          for (var r = 0; r < rows.length; r++)
            TsHover(
              builder: (hover) => Container(
                decoration: BoxDecoration(
                  color: hover ? (dark ? Tw.slate800.withValues(alpha: 0.5) : Tw.slate50) : null,
                  border: Border(top: BorderSide(color: divider)),
                ),
                child: Row(children: [
                  for (var i = 0; i < columns.length; i++) cell(i, rows[r][i], header: false),
                ]),
              ),
            ),
      ],
    );
    return DefaultTextStyle.merge(
      style: TextStyle(fontSize: 16, height: 1.5, color: dark ? Tw.slate300 : Tw.slate700),
      child: minWidth <= 0
          ? table
          : LayoutBuilder(
              builder: (context, c) {
                final w = c.maxWidth.isFinite && c.maxWidth > minWidth ? c.maxWidth : minWidth;
                return SingleChildScrollView(scrollDirection: Axis.horizontal, child: SizedBox(width: w, child: table));
              },
            ),
    );
  }
}

/// The row of eye / pencil / trash buttons in the reference & assignment tables.
class TsRowActions extends StatelessWidget {
  const TsRowActions({super.key, required this.onView, required this.onEdit, required this.onDelete});
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    Widget b(IconData icon, Color color, Color hoverBg, VoidCallback onTap) => TsIconButton(
          icon: icon,
          onTap: onTap,
          bordered: false,
          color: color,
          hoverBackground: hoverBg,
        );
    return Row(mainAxisSize: MainAxisSize.min, children: [
      b(BootstrapIcons.eye_fill, Tw.blue500, dark ? TsTw.blue900.withValues(alpha: 0.2) : Tw.blue50, onView),
      const SizedBox(width: 8),
      b(BootstrapIcons.pencil_square, Tw.emerald500, dark ? TsTw.emerald900.withValues(alpha: 0.2) : Tw.emerald50,
          onEdit),
      const SizedBox(width: 8),
      b(BootstrapIcons.trash3_fill, Tw.rose500, dark ? TsTw.rose900.withValues(alpha: 0.2) : Tw.rose50, onDelete),
    ]);
  }
}

/// The custom dialogs (Edit Schedule, Edit Slot, Preview Slot, Delete):
/// `DialogContent p-0 rounded-2xl` with a tinted header strip, a scrolling
/// body and a footer strip.
class TsDialogShell extends StatelessWidget {
  const TsDialogShell({
    super.key,
    required this.header,
    required this.footer,
    this.body,
    this.maxWidth = 448,
    this.headerColor,
    this.bodyMaxHeightFactor = 0.6,
  });

  final Widget header;
  final Widget? body;
  final List<Widget> footer;
  final double maxWidth;
  final Color? headerColor;
  final double bodyMaxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final border = dark ? Tw.slate700 : Tw.slate200;
    final strip = dark ? Tw.slate800.withValues(alpha: 0.5) : Tw.slate50;
    return Dialog(
      backgroundColor: dark ? Tw.slate900 : Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      elevation: 1,
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16), side: BorderSide(color: border)),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Stack(
          children: [
            // `DialogContent` is a `grid gap-4`: 16 px between the strips.
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: BoxDecoration(
                    color: headerColor ?? strip,
                    border: Border(bottom: BorderSide(color: border)),
                  ),
                  child: header,
                ),
                const SizedBox(height: 16),
                if (body != null) ...[
                  ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * bodyMaxHeightFactor),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: body,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(color: strip, border: Border(top: BorderSide(color: border))),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    spacing: 12,
                    runSpacing: 8,
                    children: footer,
                  ),
                ),
              ],
            ),
            const Positioned(top: 16, right: 16, child: TsDialogClose()),
          ],
        ),
      ),
    );
  }
}

/// shadcn `DialogContent`'s close button (`absolute top-4 right-4 rounded-xl
/// p-1.5 text-slate-400 hover:bg-slate-100` with a 16 px ✕).
class TsDialogClose extends StatelessWidget {
  const TsDialogClose({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return TsIconButton(
      icon: BootstrapIcons.x_lg,
      tooltip: 'Close',
      onTap: () => Navigator.of(context).maybePop(),
      bordered: false,
      size: 28,
      radius: 20,
      iconSize: 16,
      color: dark ? Tw.slate500 : Tw.slate400,
      hoverColor: dark ? Tw.slate200 : Tw.slate700,
      hoverBackground: dark ? Tw.slate800.withValues(alpha: 0.5) : Tw.slate100,
    );
  }
}

/// A plain shadcn `<DialogContent class="bg-white dark:bg-slate-900 rounded-2xl
/// max-h-[90vh] overflow-y-auto">` (padding 24, close ✕, the whole content
/// scrolls). [borderColor] defaults to `border-slate-200 dark:border-slate-700`.
class TsDialogFrame extends StatelessWidget {
  const TsDialogFrame({
    super.key,
    required this.child,
    this.maxWidth = 512,
    this.borderColor,
    this.horizontalInset = 16,
  });

  final Widget child;
  final double maxWidth;
  final Color? borderColor;

  /// `w-[calc(100vw-2rem)]` = 16, `w-[calc(100vw-1rem)]` = 8.
  final double horizontalInset;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Dialog(
      backgroundColor: dark ? Tw.slate900 : Colors.white,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withValues(alpha: 0.25),
      elevation: 1,
      insetPadding: EdgeInsets.symmetric(horizontal: horizontalInset, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: borderColor ?? (dark ? Tw.slate700 : Tw.slate200)),
      ),
      clipBehavior: Clip.antiAlias,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: MediaQuery.sizeOf(context).height * 0.9),
        child: Stack(
          children: [
            SingleChildScrollView(padding: const EdgeInsets.all(24), child: child),
            const Positioned(top: 16, right: 16, child: TsDialogClose()),
          ],
        ),
      ),
    );
  }
}

/// The `w-10 h-10 rounded-2xl bg-cyan-50 border border-cyan-100` icon tile of
/// the dialog / drawer headers.
class TsIconTile extends StatelessWidget {
  const TsIconTile({
    super.key,
    required this.icon,
    this.color = Tw.cyan500,
    this.bg = TsTw.cyan50,
    this.border = TsTw.cyan100,
    this.darkBg,
    this.darkBorder = TsTw.cyan800,
    this.size = 40,
    this.iconSize = 18,
    this.radius = 16,
  });

  final IconData icon;
  final Color color;
  final Color bg;
  final Color? border;
  final Color? darkBg;
  final Color? darkBorder;
  final double size;
  final double iconSize;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final b = dark ? darkBorder : border;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: dark ? (darkBg ?? TsTw.cyan900.withValues(alpha: 0.2)) : bg,
        borderRadius: BorderRadius.circular(radius),
        border: b == null ? null : Border.all(color: b),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}

/// `grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4`-style grid; the
/// column count is picked by the caller from the breakpoints.
class TsGrid extends StatelessWidget {
  const TsGrid({super.key, required this.columns, required this.children, this.gap = 16});
  final int columns;
  final List<Widget> children;
  final double gap;

  @override
  Widget build(BuildContext context) {
    if (columns <= 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(height: gap), children[i]],
        ],
      );
    }
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      if (i > 0) rows.add(SizedBox(height: gap));
      // No IntrinsicHeight: the selects inside use LayoutBuilder.
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var c = 0; c < columns; c++) ...[
            if (c > 0) SizedBox(width: gap),
            Expanded(child: i + c < children.length ? children[i + c] : const SizedBox.shrink()),
          ],
        ],
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

/// The shadcn `<Select>` as this page uses it:
/// - the trigger is `w-fit` (sized to its text) unless [width] is given
///   (`w-44` = 176), with `text-base` text and the muted placeholder;
/// - the menu (`SelectContent`, at least as wide as the trigger) has an
///   optional `<SelectLabel>` [groupLabel], an optional search box
///   ([search] / [onSearch], the slot dialog's instructor select) and
///   `text-base` items with the accent (orange) highlight and a check mark;
/// - [values] instead of [value] makes it `<Select multiple>`: the menu
///   stays open and the trigger lists the labels joined by ", ".
///
/// [items] are `(value, label)` pairs; [allLabels] names values that the
/// search filtered out of [items].
class TsSelect extends StatefulWidget {
  const TsSelect({
    super.key,
    required this.items,
    this.value,
    this.values,
    this.onChanged,
    this.onChangedMulti,
    this.placeholder = 'Select',
    this.groupLabel,
    this.width,
    this.enabled = true,
    this.emptyText,
    this.search,
    this.onSearch,
    this.searchHint = 'Search...',
    this.allLabels,
  });

  final List<(String, String)> items;
  final String? value;
  final List<String>? values;
  final ValueChanged<String>? onChanged;
  final ValueChanged<List<String>>? onChangedMulti;
  final String placeholder;
  final String? groupLabel;
  final double? width;
  final bool enabled;

  /// Shown when [items] is empty (`No batches available` /
  /// `No instructor found`).
  final String? emptyText;
  final String? search;
  final ValueChanged<String>? onSearch;
  final String searchHint;
  final Map<String, String>? allLabels;

  @override
  State<TsSelect> createState() => _TsSelectState();
}

class _TsSelectState extends State<TsSelect> {
  final _menu = MenuController();
  final _triggerKey = GlobalKey();
  late final _searchCtrl = TextEditingController(text: widget.search ?? '');
  double _menuWidth = 128;

  bool get _multi => widget.values != null;

  @override
  void didUpdateWidget(covariant TsSelect oldWidget) {
    super.didUpdateWidget(oldWidget);
    final s = widget.search ?? '';
    if (s != _searchCtrl.text) _searchCtrl.text = s;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  String? _labelOf(String v) {
    final known = widget.allLabels?[v];
    if (known != null) return known;
    for (final (value, label) in widget.items) {
      if (value == v) return label;
    }
    return null;
  }

  String? get _text {
    if (_multi) {
      final vs = widget.values!;
      return vs.isEmpty ? null : vs.map((v) => _labelOf(v) ?? v).join(', ');
    }
    final v = widget.value;
    return v == null ? null : _labelOf(v);
  }

  bool _selected(String v) => _multi ? widget.values!.contains(v) : widget.value == v;

  void _toggleMenu() {
    if (_menu.isOpen) {
      _menu.close();
      return;
    }
    final box = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
    var w = box != null && box.hasSize ? box.size.width : 128.0;
    // `min-w-[8rem]`, at least the trigger, and wide enough for the
    // longest item (padding 8 + label + gap 8 + check 16 + padding 8, panel 8).
    for (final (_, label) in widget.items) {
      final tp = TextPainter(
        text: TextSpan(text: label, style: const TextStyle(fontSize: 16)),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      if (tp.width + 48 > w) w = tp.width + 48;
      tp.dispose();
    }
    final screen = MediaQuery.sizeOf(context).width - 32;
    setState(() => _menuWidth = (w < 128 ? 128.0 : w) > screen ? screen : (w < 128 ? 128.0 : w));
    _menu.open();
  }

  void _pick(String v) {
    if (_multi) {
      final next = [...widget.values!];
      if (!next.remove(v)) next.add(v);
      widget.onChangedMulti?.call(next);
    } else {
      widget.onChanged?.call(v);
      _menu.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final fg = dark ? AppColors.darkForeground : AppColors.foreground;
    final muted = dark ? AppColors.darkMutedForeground : AppColors.mutedForeground;
    final text = _text;

    Widget trigger = InkWell(
      key: _triggerKey,
      onTap: widget.enabled ? _toggleMenu : null,
      borderRadius: BorderRadius.circular(20),
      child: InputDecorator(
        isEmpty: text == null,
        isFocused: _menu.isOpen,
        // SelectTrigger's `data-[size=default]:h-9` beats the template's
        // `h-10` / `h-11`, so every trigger is 36 px tall (`px-3 py-2`).
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          suffixIcon: Icon(BootstrapIcons.chevron_down, size: 14, color: muted.withValues(alpha: 0.5)),
          suffixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 20),
        ),
        child: Text(
          text ?? widget.placeholder,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 16, height: 1.25, color: text == null ? muted : fg),
        ),
      ),
    );
    trigger = widget.width != null
        ? SizedBox(width: widget.width, child: trigger)
        : Align(alignment: Alignment.centerLeft, child: IntrinsicWidth(child: trigger));

    return Opacity(
      opacity: widget.enabled ? 1 : 0.5,
      child: MenuAnchor(
        controller: _menu,
        crossAxisUnconstrained: false,
        onOpen: () {
          if (mounted) setState(() {});
        },
        onClose: () {
          if (mounted) setState(() {});
        },
        style: MenuStyle(
          minimumSize: WidgetStatePropertyAll(Size(_menuWidth, 0)),
          maximumSize: WidgetStatePropertyAll(Size(_menuWidth, 384)),
          backgroundColor: WidgetStatePropertyAll(dark ? AppColors.darkPopover : AppColors.popover),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.3)),
          elevation: const WidgetStatePropertyAll(3),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: BorderSide(color: dark ? AppColors.darkBorder : AppColors.border),
          )),
        ),
        menuChildren: [
          if (widget.search != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
              child: SizedBox(
                width: _menuWidth - 24,
                child: TextField(
                  controller: _searchCtrl,
                  autofocus: true,
                  onChanged: widget.onSearch,
                  style: TextStyle(fontSize: 16, color: dark ? Colors.white : Tw.slate900),
                  decoration: InputDecoration(
                    hintText: widget.searchHint,
                    filled: false,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: dark ? Tw.slate700 : Tw.slate200),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide(color: dark ? Tw.slate700 : Tw.slate200),
                    ),
                  ),
                ),
              ),
            ),
          if (widget.groupLabel != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(widget.groupLabel!, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fg)),
            ),
          for (final (value, label) in widget.items)
            _TsSelectItem(
              label: label,
              selected: _selected(value),
              width: _menuWidth - 8,
              onTap: () => _pick(value),
            ),
          if (widget.items.isEmpty && widget.emptyText != null)
            SizedBox(
              width: _menuWidth - 8,
              child: Padding(
                padding: widget.search != null ? const EdgeInsets.all(12) : const EdgeInsets.symmetric(vertical: 16),
                child: Text(widget.emptyText!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: widget.search != null ? Tw.slate500 : Tw.slate400)),
              ),
            ),
        ],
        child: trigger,
      ),
    );
  }
}

/// `<SelectItem class="text-base">`: `py-1.5 pl-2 pr-8`, the check mark at
/// `right-2`, `focus:bg-accent focus:text-accent-foreground`.
class _TsSelectItem extends StatefulWidget {
  const _TsSelectItem({
    required this.label,
    required this.selected,
    required this.width,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final double width;
  final VoidCallback onTap;

  @override
  State<_TsSelectItem> createState() => _TsSelectItemState();
}

class _TsSelectItemState extends State<_TsSelectItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final fg = _hover ? AppColors.accentForeground : (dark ? AppColors.darkForeground : AppColors.foreground);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: SizedBox(
          width: widget.width,
          child: Container(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            decoration: BoxDecoration(
              color: _hover ? AppColors.accent : null,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(children: [
              Expanded(
                child: Text(widget.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 16, height: 1.5, color: fg)),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 16,
                child: widget.selected ? Icon(Icons.check, size: 16, color: fg) : null,
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
