import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/pagination.dart';
import '../../widgets/skeleton.dart';
import '../institutes/institute_widgets.dart';

/// Tailwind v4 colours used by the class list (aliases of [Tw], kept so the
/// widgets read like the web classes), plus its arbitrary hex colours.
class ClassTw {
  ClassTw._();
  static const emerald300 = Tw.emerald300;
  static const emerald800 = Tw.emerald800;
  static const emerald950 = Tw.emerald950;
  static const rose100 = Tw.rose100;
  static const rose400 = Tw.rose400;
  static const rose700 = Tw.rose700;
  static const rose800 = Tw.rose800;
  static const rose950 = Tw.rose950;
  static const red50 = Tw.red50;
  static const red700 = Tw.red700;
  static const green50 = Tw.green50;
  static const orange50 = Tw.orange50;
  static const orange100 = Tw.orange100;
  static const orange950 = Tw.orange950;
  static const violet50 = Tw.violet50;
  static const violet100 = Tw.violet100;
  static const violet400 = Tw.violet400;
  static const violet950 = Tw.violet950;
  static const blue950 = Tw.blue950;
  static const purple50 = Tw.purple50;
  static const purple100 = Tw.purple100;
  static const purple200 = Tw.purple200;
  static const purple400 = Tw.purple400;
  static const purple950 = Tw.purple950;
  static const pink100 = Tw.pink100;
  static const pink950 = Tw.pink950;
  static const yellow50 = Tw.yellow50;
  static const yellow100 = Tw.yellow100;
  static const yellow600 = Tw.yellow600;
  static const yellow950 = Tw.yellow950;
  static const cyan50 = Tw.cyan50;
  static const cyan100 = Tw.cyan100;
  static const cyan400 = Tw.cyan400;
  static const cyan600 = Tw.cyan600;
  static const cyan700 = Tw.cyan700;
  static const cyan950 = Tw.cyan950;
  static const teal600 = Tw.teal600;

  /// `dark:bg-[#161e36]`
  static const navy = Color(0xFF161E36);

  /// `dark:bg-[#0d0d2b]`
  static const night = Color(0xFF0D0D2B);
}

/// Active (emerald) / Inactive (rose) pill with the leading dot.
class StatusPill extends StatelessWidget {
  const StatusPill({
    super.key,
    required this.active,
    this.pulse = false,
    this.bordered = true,
    this.gap = 6,
    this.rose450 = false,
  });
  final bool active;

  /// The inactive pill says `dark:text-rose-450` (not a Tailwind colour), so
  /// it keeps `text-rose-700` in dark mode.
  final bool rose450;

  /// `gap-1.5` (class detail tables) / `gap-1` (batch student tables).
  final double gap;

  /// `animate-pulse` on the dot (rendered static).
  final bool pulse;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final bg = active
        ? (dark ? ClassTw.emerald950.withValues(alpha: 0.3) : Tw.emerald50)
        : (dark ? ClassTw.rose950.withValues(alpha: 0.3) : Tw.rose50);
    final fg = active
        ? (dark ? Tw.emerald400 : Tw.emerald700)
        : (dark && !rose450 ? ClassTw.rose400 : ClassTw.rose700);
    final border = active
        ? (dark ? ClassTw.emerald800.withValues(alpha: 0.5) : Tw.emerald100)
        : (dark ? ClassTw.rose800.withValues(alpha: 0.5) : ClassTw.rose100);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
        border: bordered ? Border.all(color: border) : null,
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(shape: BoxShape.circle, color: active ? Tw.emerald500 : Tw.rose500),
        ),
        SizedBox(width: gap),
        Text(active ? 'Active' : 'Inactive', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
      ]),
    );
  }
}

/// Palette of the round `w-8 h-8 rounded-full` action buttons
/// (`bg-x-50 hover:bg-x-100 text-x-600 dark:bg-x-950/20 dark:text-x-400`).
class RoundTone {
  const RoundTone(this.bg, this.hover, this.fg, this.darkBg, this.darkFg);
  final Color bg;
  final Color hover;
  final Color fg;
  final Color darkBg;
  final Color darkFg;

  static const violet = RoundTone(ClassTw.violet50, ClassTw.violet100, Tw.violet600, ClassTw.violet950, ClassTw.violet400);
  static const orange = RoundTone(ClassTw.orange50, ClassTw.orange100, Tw.orange600, ClassTw.orange950, Tw.orange400);
  static const blue = RoundTone(Tw.blue50, Tw.blue100, Tw.blue600, ClassTw.blue950, Tw.blue400);
  static const purple = RoundTone(ClassTw.purple50, ClassTw.purple100, Tw.purple600, ClassTw.purple950, ClassTw.purple400);
  static const yellow = RoundTone(ClassTw.yellow50, ClassTw.yellow100, ClassTw.yellow600, ClassTw.yellow950, Tw.yellow400);
  static const cyan = RoundTone(ClassTw.cyan50, ClassTw.cyan100, ClassTw.cyan600, ClassTw.cyan950, ClassTw.cyan400);
  static const emerald = RoundTone(Tw.emerald50, Tw.emerald100, Tw.emerald600, ClassTw.emerald950, Tw.emerald400);
  static const slate = RoundTone(Tw.slate50, Tw.slate100, Tw.slate600, Tw.slate950, Tw.slate400);
  static const rose = RoundTone(Tw.rose50, ClassTw.rose100, Tw.rose600, ClassTw.rose950, ClassTw.rose400);

  /// `dark:text-rose-450` is not a Tailwind colour: rose-600 in dark mode too.
  static const rose450 = RoundTone(Tw.rose50, ClassTw.rose100, Tw.rose600, ClassTw.rose950, Tw.rose600);
}

/// A round 32px icon button in a table's Actions cell. Icons inside tables
/// are 18px (`table .bi { font-size: 18px }` in style.css).
class RoundAction extends StatefulWidget {
  const RoundAction({
    super.key,
    required this.icon,
    required this.tone,
    required this.tooltip,
    this.onTap,
    this.disabled = false,
    this.spinning = false,
  });

  final IconData icon;
  final RoundTone tone;
  final String tooltip;
  final VoidCallback? onTap;

  /// `disabled:opacity-40 disabled:cursor-not-allowed`
  final bool disabled;

  /// `bi-arrow-repeat animate-spin` instead of [icon].
  final bool spinning;

  @override
  State<RoundAction> createState() => _RoundActionState();
}

class _RoundActionState extends State<RoundAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final t = widget.tone;
    final bg = dark ? t.darkBg.withValues(alpha: _hover ? 0.4 : 0.2) : (_hover ? t.hover : t.bg);
    final fg = dark ? t.darkFg : t.fg;
    Widget w = MouseRegion(
      cursor: widget.disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.disabled ? null : widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: widget.spinning ? SpinIcon(size: 18, color: fg) : Icon(widget.icon, size: 18, color: fg),
        ),
      ),
    );
    if (widget.disabled) w = Opacity(opacity: 0.4, child: w);
    return Tooltip(message: widget.tooltip, child: w);
  }
}

/// One `<TableHead>` of a [ClassTable].
class ClassCol {
  const ClassCol(this.label, {this.flex = 1, this.alignEnd = false, this.width, this.header, this.left, this.right});
  final String label;

  /// Body-cell side padding overrides (`pl-6`, `pr-6`, `px-4`); the header
  /// keeps the global `thead th { padding: .5rem 1rem }`.
  final double? left;
  final double? right;

  /// Replaces the label (e.g. the select-all checkbox).
  final Widget? header;
  final double flex;
  final bool alignEnd;

  /// Fixed width (`w-12`, `w-[80px]`); overrides [flex].
  final double? width;
}

/// One body row of a [ClassTable].
class ClassRow {
  const ClassRow(this.cells, {this.dimmed = false});
  final List<Widget> cells;

  /// `opacity-65 pointer-events-none select-none`
  final bool dimmed;
}

/// The class list's `<Card class="p-0 …"><Table>`: global `thead th` primary
/// header (style.css), `text-sm` rows with a bottom border and hover tint,
/// optional full-width skeleton rows and a custom empty row.
///
/// Feature-local variant of `AppTable` (that one only takes an empty *text*
/// and per-column skeletons).
class ClassTable extends StatelessWidget {
  const ClassTable({
    super.key,
    required this.columns,
    required this.rows,
    this.loading = false,
    this.skeletonRows = 6,
    this.skeletonHeight = 24,
    this.empty,
    this.leading,
    this.showEmptyWhileLoading = false,
    this.minWidth = 640,
    this.card = true,
    this.cellVPad = 8,
    this.headerVPad = 8,
    this.headerColor,
    this.headerTextColor,
    this.radius = 16,
    this.cardColor,
    this.borderColor,
  });

  final List<ClassCol> columns;
  final List<ClassRow> rows;
  final bool loading;
  final int skeletonRows;
  final double skeletonHeight;

  /// Shown instead of rows when there are none (`<TableRow v-if="!x.length">`).
  final Widget? empty;

  /// A row always rendered above the body rows (the batches table's
  /// `v-if` / `v-else-if` rows, which sit beside its `v-for`).
  final Widget? leading;

  /// The student tables render the empty row *and* the skeletons.
  final bool showEmptyWhileLoading;
  final double minWidth;
  final bool card;
  final double cellVPad;
  final double headerVPad;
  final Color? headerColor;
  final Color? headerTextColor;
  final double radius;
  final Color? cardColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final border = borderColor ?? (dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate100);
    final rowBorder = dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate100;

    Widget table = LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth.isFinite ? (c.maxWidth < minWidth ? minWidth : c.maxWidth) : minWidth;
      final body = <Widget>[
        _HeaderRow(
          columns: columns,
          vPad: headerVPad,
          color: headerColor ?? context.colors.primary,
          textColor: headerTextColor ?? context.colors.onPrimary,
        ),
        ?leading,
        if (empty != null && rows.isEmpty && (!loading || showEmptyWhileLoading)) empty!,
        if (loading)
          for (var i = 0; i < skeletonRows; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Skeleton(width: double.infinity, height: skeletonHeight, radius: skeletonHeight >= 24 ? 16 : 14),
            )
        else
          for (var i = 0; i < rows.length; i++)
            _BodyRow(
              columns: columns,
              row: rows[i],
              vPad: cellVPad,
              border: i == rows.length - 1 ? null : rowBorder,
            ),
      ];
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: width,
          child: DefaultTextStyle.merge(
            style: const TextStyle(fontSize: 14),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: body),
          ),
        ),
      );
    });

    if (!card) return table;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: cardColor ?? (dark ? ClassTw.navy.withValues(alpha: 0.4) : Colors.white),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: table,
    );
  }
}

Widget _cell(ClassCol col, Widget child, EdgeInsets pad) {
  final aligned = Padding(
    padding: pad,
    child: Align(alignment: col.alignEnd ? Alignment.centerRight : Alignment.centerLeft, child: child),
  );
  if (col.width != null) return SizedBox(width: col.width, child: aligned);
  return Expanded(flex: (col.flex * 100).round(), child: aligned);
}

class _HeaderRow extends StatelessWidget {
  const _HeaderRow({required this.columns, required this.vPad, required this.color, required this.textColor});
  final List<ClassCol> columns;
  final double vPad;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final border = context.isDark ? AppColors.darkBorder : AppColors.border;
    return Container(
      constraints: const BoxConstraints(minHeight: 40),
      decoration: BoxDecoration(color: color, border: Border(bottom: BorderSide(color: border))),
      child: Row(children: [
        for (final col in columns)
          _cell(
            col,
            col.header ??
            Text(col.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textColor)),
            EdgeInsets.symmetric(horizontal: 16, vertical: vPad),
          ),
      ]),
    );
  }
}

class _BodyRow extends StatefulWidget {
  const _BodyRow({required this.columns, required this.row, required this.vPad, required this.border});
  final List<ClassCol> columns;
  final ClassRow row;
  final double vPad;
  final Color? border;

  @override
  State<_BodyRow> createState() => _BodyRowState();
}

class _BodyRowState extends State<_BodyRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    assert(widget.row.cells.length == widget.columns.length);
    final dark = context.isDark;
    final hoverBg = dark ? Tw.slate800.withValues(alpha: 0.2) : Tw.slate50.withValues(alpha: 0.5);
    Widget row = MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44),
        decoration: BoxDecoration(
          color: _hover ? hoverBg : null,
          border: widget.border == null ? null : Border(bottom: BorderSide(color: widget.border!)),
        ),
        child: Row(children: [
          for (var i = 0; i < widget.columns.length; i++)
            _cell(
              widget.columns[i],
              widget.row.cells[i],
              EdgeInsets.fromLTRB(
                  widget.columns[i].left ?? 8, widget.vPad, widget.columns[i].right ?? 8, widget.vPad),
            ),
        ]),
      ),
    );
    if (widget.row.dimmed) row = IgnorePointer(child: Opacity(opacity: 0.65, child: row));
    return row;
  }
}

/// The empty-state row with the round illustration and sparkles
/// (`bi-archive` / `bi-briefcase` / `bi-people`).
class TableEmptyIllustration extends StatelessWidget {
  const TableEmptyIllustration({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.circleColor,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final Color iconColor;
  final Color circleColor;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    // `table .bi { font-size: 18px }` overrides the text-3xl / text-lg sizes.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 8),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // The two `bi-sparkles` icons have no glyph in Bootstrap Icons, so
        // the web renders nothing for them.
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(shape: BoxShape.circle, color: circleColor),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(height: 16),
        Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: dark ? Tw.slate200 : Tw.slate700)),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 384),
          child: Text(subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: dark ? Tw.slate500 : Tw.slate400)),
        ),
      ]),
    );
  }
}

/// The class list's `<Pagination>`: Prev, every page (current
/// `bg-primary text-white`), Next — all `rounded-xl`.
///
/// Prev / Next are shadcn ghost buttons: `hover:bg-accent
/// hover:text-accent-foreground` (orange), `dark:hover:bg-accent/50`.
class ClassPagination extends StatelessWidget {
  const ClassPagination({super.key, required this.meta, required this.onPage, this.onNext, this.plainItems = false});
  final PageMeta meta;
  final ValueChanged<int> onPage;

  /// The instructors' "Next" reads a different paginator in the web.
  final VoidCallback? onNext;

  /// The instructors' page items: only `hover:bg-slate-100` (no text colour,
  /// the ghost `dark:hover:bg-accent/50` in dark mode).
  final bool plainItems;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final current = meta.currentPage;
    final last = meta.lastPage;
    final foreground = dark ? AppColors.darkForeground : AppColors.foreground;
    Widget nav(String label, bool enabled, VoidCallback onTap) => Opacity(
          opacity: enabled ? 1 : 0.5,
          child: DefaultTextStyle.merge(
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: foreground),
            child: _HoverBox(
              onTap: enabled ? onTap : null,
              radius: 20,
              hover: dark ? AppColors.accent.withValues(alpha: 0.5) : AppColors.accent,
              hoverText: AppColors.accentForeground,
              child: Container(
                height: 36,
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Text(label),
              ),
            ),
          ),
        );
    final itemText = plainItems ? foreground : (dark ? Tw.slate300 : Tw.slate700);
    final itemHover = plainItems
        ? (dark ? AppColors.accent.withValues(alpha: 0.5) : Tw.slate100)
        : (dark ? Tw.slate800 : Tw.slate100);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        nav('Prev', current > 1, () => onPage(current - 1)),
        const SizedBox(width: 4),
        for (var p = 1; p <= last; p++) ...[
          _HoverBox(
            onTap: () => onPage(p),
            radius: 20,
            color: p == current ? context.colors.primary : null,
            hover: p == current
                ? context.colors.primary.withValues(alpha: plainItems ? 0.9 : 0.95)
                : itemHover,
            child: SizedBox(
              width: 36,
              height: 36,
              child: Center(
                child: Text('$p',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: p == current ? Colors.white : itemText,
                    )),
              ),
            ),
          ),
          const SizedBox(width: 4),
        ],
        nav('Next', current < last, onNext ?? () => onPage(current + 1)),
      ]),
    );
  }
}

class _HoverBox extends StatefulWidget {
  const _HoverBox({
    required this.child,
    required this.onTap,
    required this.radius,
    required this.hover,
    this.color,
    this.hoverText,
  });
  final Widget child;
  final VoidCallback? onTap;
  final double radius;
  final Color hover;
  final Color? color;

  /// Text colour while hovered.
  final Color? hoverText;

  @override
  State<_HoverBox> createState() => _HoverBoxState();
}

class _HoverBoxState extends State<_HoverBox> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: widget.onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: _hover && widget.onTap != null ? widget.hover : widget.color,
              borderRadius: BorderRadius.circular(widget.radius),
            ),
            child: _hover && widget.onTap != null && widget.hoverText != null
                ? DefaultTextStyle.merge(style: TextStyle(color: widget.hoverText), child: widget.child)
                : widget.child,
          ),
        ),
      );
}

/// The `relative` search inputs with a `bi-search` icon on the left.
class IconSearchInput extends StatelessWidget {
  const IconSearchInput({
    super.key,
    required this.controller,
    required this.hint,
    required this.onSubmitted,
    this.fillColor,
    this.borderColor,
    this.radius = 20,
    this.vPad = 11,
    this.darkIconColor = Tw.slate500,
    this.icon = BootstrapIcons.search,
  });

  /// `null` for a plain `<Input>` (the batch name field).
  final IconData? icon;

  final TextEditingController controller;
  final String hint;
  final VoidCallback onSubmitted;
  final Color? fillColor;
  final Color? borderColor;
  final double radius;

  /// `py-2.5` → 11, `py-2` → 9.5 (Flutter's 14px line box is ~3px shorter
  /// than `text-sm`'s 20px line height).
  final double vPad;

  /// The search icon in dark mode (`dark:text-slate-500`, or `text-slate-400`
  /// only).
  final Color darkIconColor;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final border = borderColor ?? (dark ? Tw.slate700 : Tw.slate200);
    OutlineInputBorder b(Color c, [double w = 1]) =>
        OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: c, width: w));
    return TextField(
      controller: controller,
      onSubmitted: (_) => onSubmitted(),
      textInputAction: TextInputAction.search,
      style: TextStyle(fontSize: 14, color: dark ? Tw.slate100 : Tw.slate900),
      decoration: InputDecoration(
        isDense: true,
        hintText: hint,
        // Global `input::placeholder { color: #9ca3af }` beats `placeholder-slate-400`.
        hintStyle: const TextStyle(fontSize: 14, color: AppColors.placeholder),
        filled: true,
        fillColor: fillColor ?? (dark ? Tw.slate900 : Colors.white),
        prefixIcon: icon == null ? null : Icon(icon, size: 14, color: dark ? darkIconColor : Tw.slate400),
        prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 20),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: vPad),
        border: b(border),
        enabledBorder: b(border),
        focusedBorder: b(context.colors.primary),
      ),
    );
  }
}

/// A `<label>` without Tailwind text classes (16px, normal weight).
class PlainLabel extends StatelessWidget {
  const PlainLabel(this.text, {super.key, this.small = false, this.bottom = 4});
  final String text;

  /// `text-sm font-medium`
  final bool small;
  final double bottom;

  @override
  Widget build(BuildContext context) => Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: Text(text,
            style: TextStyle(fontSize: small ? 14 : 16, fontWeight: small ? FontWeight.w500 : FontWeight.w400)),
      );
}

/// Button content that swaps to the spinner while [busy]
/// (`<i v-if="loading" class="bi bi-arrow-repeat animate-spin"/><span v-else>…</span>`).
class BusyText extends StatelessWidget {
  const BusyText({super.key, required this.busy, required this.label, this.icon, this.color});
  final bool busy;
  final String label;
  final IconData? icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (busy) return SpinIcon(size: 16, color: color);
    if (icon == null) return Text(label);
    return Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: color), const SizedBox(width: 8), Text(label)]);
  }
}

/// `<DialogFooter class="flex flex-col … gap-4">` with a left and a right
/// group (`flex flex-col sm:flex-row gap-2`).
///
/// * [splitAt]: width from which the two groups sit on one row with
///   `justify-between` (640 for `sm:`, 1024 for `lg:`); between 640 and it
///   they sit on one row aligned right (shadcn's `sm:flex-row sm:justify-end`).
/// * [reverseOnMobile]: `flex-col-reverse` below 640 (right group first).
class SplitFooter extends StatelessWidget {
  const SplitFooter({
    super.key,
    required this.left,
    required this.right,
    this.splitAt = 1024,
    this.reverseOnMobile = false,
  });

  final List<Widget> left;
  final List<Widget> right;
  final double splitAt;
  final bool reverseOnMobile;

  Widget _group(BuildContext context, List<Widget> items) {
    if (context.isSm) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < items.length; i++) ...[if (i > 0) const SizedBox(width: 8), items[i]],
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < items.length; i++) ...[if (i > 0) const SizedBox(height: 8), items[i]],
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final w = context.screenWidth;
    final l = _group(context, left);
    final r = _group(context, right);
    if (!context.isSm) {
      final first = reverseOnMobile ? r : l;
      final second = reverseOnMobile ? l : r;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [first, const SizedBox(height: 16), second],
      );
    }
    return Row(
      mainAxisAlignment: w >= splitAt ? MainAxisAlignment.spaceBetween : MainAxisAlignment.end,
      children: [l, const SizedBox(width: 16), r],
    );
  }
}

/// `text-primary font-bold text-[1.2rem]` dialog headers (Create / Update
/// Class); `<DialogHeader>` centres its text below `sm`.
class PrimaryDialogHeading extends StatelessWidget {
  const PrimaryDialogHeading(this.text, {super.key, this.size = 19.2, this.weight = FontWeight.w700});
  final String text;
  final double size;
  final FontWeight weight;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 28),
        child: Text(text,
            textAlign: context.isSm ? TextAlign.start : TextAlign.center,
            style: TextStyle(fontSize: size, fontWeight: weight, color: context.colors.primary)),
      );
}
