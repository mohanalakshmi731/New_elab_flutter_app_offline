import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import 'skeleton.dart';

/// One `<TableHead>` of an [AppTable].
class AppTableColumn {
  const AppTableColumn(
    this.label, {
    this.flex = 1,
    this.alignEnd = false,
    this.skeletonWidth = 80,
  });

  final String label;

  /// Relative width. HTML tables size columns by content; give wide columns
  /// (name, email) a bigger flex than ids and actions.
  final double flex;

  /// `text-right` (usually the Actions column).
  final bool alignEnd;

  /// Width of the placeholder bar while loading (`<Skeleton class="h-4 w-20">` → 80).
  final double skeletonWidth;
}

/// shadcn `<Card class="p-0 overflow-x-auto"><Table class="min-w-[700px]">`
/// with the loading-skeleton rows and the "No data" row every web list has.
///
/// Header cells follow style.css's unlayered `thead th` rule (`bg-primary
/// text-primary-foreground px-4 py-2`, 40px tall); body cells are `p-2`
/// with `hover:bg-muted/50` rows and `border-b` between them.
///
/// `rows` holds one widget per column. Cells get `text-xs sm:text-sm` by
/// default, so plain `Text('...')` matches the web.
class AppTable extends StatelessWidget {
  const AppTable({
    super.key,
    required this.columns,
    required this.rows,
    this.loading = false,
    this.skeletonRows = 6,
    this.emptyText = 'No data',
    this.minWidth = 700,
    this.onRowTap,
    this.card = true,
    this.fontSize,
    this.emptyTextColor,
    this.emptyPadding = const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
  });

  final List<AppTableColumn> columns;
  final List<List<Widget>> rows;
  final bool loading;
  final int skeletonRows;
  final String emptyText;

  /// `min-w-[700px]`: below this the table scrolls horizontally.
  final double minWidth;
  final ValueChanged<int>? onRowTap;

  /// Wraps the table in the shadcn card (`rounded-xl border shadow-sm`).
  final bool card;

  /// Cell text size; default `text-xs sm:text-sm` (pass 14 for tables whose
  /// cells keep the table's `text-sm` at every width).
  final double? fontSize;

  /// "No data" colour (default `text-gray-500`).
  final Color? emptyTextColor;

  /// "No data" cell padding (default `py-4 px-2`).
  final EdgeInsetsGeometry emptyPadding;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final border = dark ? AppColors.darkBorder : AppColors.border;
    final fontSize = this.fontSize ?? (context.isSm ? 14.0 : 12.0);
    // `text-sm` (20px line) / `text-xs` (16px line).
    final lineHeight = fontSize == 12 ? 16.0 : (fontSize == 14 ? 20.0 : fontSize * 1.5);

    Widget table = LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth.isFinite ? math.max(c.maxWidth, minWidth) : minWidth;
        final body = <Widget>[
          // style.css: `thead th { background: var(--primary);
          // color: var(--primary-foreground); padding: .5rem 1rem }` — an
          // unlayered rule, so it beats the templates' Tailwind classes.
          _row(
            context,
            [
              for (final col in columns)
                Text(col.label,
                    style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w500,
                        color: context.colors.onPrimary)),
            ],
            border: border,
            header: true,
            lineHeight: lineHeight,
          ),
          if (loading)
            for (var i = 0; i < skeletonRows; i++)
              _row(
                context,
                [for (final col in columns) Skeleton(width: col.skeletonWidth, height: 16)],
                border: border,
                last: i == skeletonRows - 1,
                lineHeight: lineHeight,
              )
          else if (rows.isEmpty)
            Padding(
              padding: emptyPadding,
              child: Text(
                emptyText,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: fontSize, color: emptyTextColor ?? Tw.gray500),
              ),
            )
          else
            for (var i = 0; i < rows.length; i++)
              _row(
                context,
                rows[i],
                border: border,
                last: i == rows.length - 1,
                lineHeight: lineHeight,
                onTap: onRowTap == null ? null : () => onRowTap!(i),
              ),
        ];
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: width,
            child: DefaultTextStyle.merge(
              style: TextStyle(fontSize: fontSize, height: lineHeight / fontSize),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: body),
            ),
          ),
        );
      },
    );

    if (!card) return table;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: border),
        boxShadow: AppShadows.sm,
      ),
      child: table,
    );
  }

  Widget _row(
    BuildContext context,
    List<Widget> cells, {
    required Color border,
    bool header = false,
    bool last = false,
    double lineHeight = 20,
    VoidCallback? onTap,
  }) {
    assert(cells.length == columns.length,
        'AppTable row has ${cells.length} cells for ${columns.length} columns');
    return _HoverRow(
      hover: !header,
      onTap: onTap,
      decoration: BoxDecoration(
        color: header ? context.colors.primary : null,
        border: last ? null : Border(bottom: BorderSide(color: border)),
      ),
      child: ConstrainedBox(
        // th `h-10`; td `p-2` around one line of text.
        constraints: BoxConstraints(minHeight: header ? 40 : 16 + lineHeight),
        child: Row(
          children: [
            for (var i = 0; i < columns.length; i++)
              Expanded(
                flex: (columns[i].flex * 100).round(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: header ? 16 : 8, vertical: 8),
                  child: Align(
                    alignment: columns[i].alignEnd ? Alignment.centerRight : Alignment.centerLeft,
                    child: cells[i],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// `hover:bg-muted/50`
class _HoverRow extends StatefulWidget {
  const _HoverRow({required this.child, required this.decoration, this.hover = true, this.onTap});
  final Widget child;
  final BoxDecoration decoration;
  final bool hover;
  final VoidCallback? onTap;

  @override
  State<_HoverRow> createState() => _HoverRowState();
}

class _HoverRowState extends State<_HoverRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final muted = context.isDark ? AppColors.darkMuted : AppColors.muted;
    Widget row = AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      decoration: widget.decoration.copyWith(
        color: widget.hover && _hovered ? muted.withValues(alpha: 0.5) : null,
      ),
      child: widget.child,
    );
    if (widget.onTap != null) {
      row = GestureDetector(onTap: widget.onTap, behavior: HitTestBehavior.opaque, child: row);
    }
    if (!widget.hover) return row;
    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: row,
    );
  }
}

/// `text-green-500` Active / `text-red-500` Inactive, the status cell used by
/// the user and institute lists.
class StatusText extends StatelessWidget {
  const StatusText(this.active, {super.key, this.activeLabel = 'Active', this.inactiveLabel = 'Inactive'});
  final bool active;
  final String activeLabel;
  final String inactiveLabel;

  @override
  Widget build(BuildContext context) => Text(
        active ? activeLabel : inactiveLabel,
        style: TextStyle(color: active ? Tw.green500 : Tw.red500),
      );
}

/// A clickable icon in an Actions cell (`<i class="bi bi-trash text-red-600 cursor-pointer">`;
/// style.css sizes `table .bi` at 18px).
class TableActionIcon extends StatelessWidget {
  const TableActionIcon({
    super.key,
    required this.icon,
    required this.onTap,
    this.color,
    this.tooltip,
    this.size = 18,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final Color? color;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    Widget w = MouseRegion(
      cursor: onTap == null ? MouseCursor.defer : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Icon(icon, size: size, color: color),
      ),
    );
    if (tooltip != null) w = Tooltip(message: tooltip!, child: w);
    return w;
  }
}
