import 'dart:math' as math;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/pagination.dart';
import '../../core/utils/toast.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/skeleton.dart';
import 'zsl_plan_controller.dart';
import 'zsl_plan_utils.dart';

// ─────────────────────────────── Card ───────────────────────────────

/// shadcn `<Card>` (`bg-card text-card-foreground rounded-xl border shadow-sm`),
/// which is not the dashboard `SurfaceCard` look. `rounded-xl` = 20px with
/// the app's `--radius`; `rounded-2xl` = 16px.
class PlanCard extends StatelessWidget {
  const PlanCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24),
    this.radius = 20,
    this.shadowMd = false,
    this.clip = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  /// `shadow-md` instead of the default `shadow-sm` (the theme's light
  /// `--shadow-*` values).
  final bool shadowMd;

  /// `overflow-hidden`. Without it (a plain `<Card class="p-0">`) the
  /// table header's square corners paint over the rounded border, like on
  /// the web.
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      padding: padding,
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCard : AppColors.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: context.borderColor),
        boxShadow: shadowMd ? AppShadows.md : AppShadows.sm,
      ),
      // `text-card-foreground`
      child: DefaultTextStyle.merge(style: TextStyle(color: context.fgColor), child: child),
    );
  }
}

// ─────────────────────────────── Grid ───────────────────────────────

/// One cell of a [PlanFormGrid]; [fullRow] = `md:col-span-2` / `col-span-2`.
class PlanGridCell {
  const PlanGridCell(this.child, {this.fullRow = false});
  final Widget child;
  final bool fullRow;
}

/// `grid grid-cols-1 md:grid-cols-2 gap-x-… gap-y-…` with CSS auto-placement
/// (a full-row cell after an odd cell leaves the right cell empty).
class PlanFormGrid extends StatelessWidget {
  const PlanFormGrid({
    super.key,
    required this.cells,
    required this.twoColumns,
    this.columnGap = 24,
    this.rowGap = 24,
    this.spanAtAllSizes = false,
  });

  final List<PlanGridCell> cells;
  final bool twoColumns;
  final double columnGap;
  final double rowGap;

  /// The full-row cells are a plain `col-span-2` (no `md:`): in the
  /// one-column layout they add an implicit, zero-width second column, so
  /// the other cells end [columnGap] short of the right edge (subscription.vue).
  final bool spanAtAllSizes;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    if (!twoColumns) {
      final ghostColumn = spanAtAllSizes && cells.any((c) => c.fullRow);
      rows.addAll(cells.map(
        (c) => ghostColumn && !c.fullRow ? Padding(padding: EdgeInsets.only(right: columnGap), child: c.child) : c.child,
      ));
    } else {
      Widget pair(Widget a, Widget? b) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: a),
              SizedBox(width: columnGap),
              Expanded(child: b ?? const SizedBox.shrink()),
            ],
          );
      Widget? pending;
      for (final c in cells) {
        if (c.fullRow) {
          if (pending != null) rows.add(pair(pending, null));
          pending = null;
          rows.add(c.child);
        } else if (pending == null) {
          pending = c.child;
        } else {
          rows.add(pair(pending, c.child));
          pending = null;
        }
      }
      if (pending != null) rows.add(pair(pending, null));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: rowGap),
          rows[i],
        ],
      ],
    );
  }
}

/// Width of the `Search Classess...` box + button from 640px up. The web
/// wraps it in `sm:w-auto` > `sm:w-[60%] md:w-[70%]`: the percentage
/// resolves against the wrapper's own max-content width, and the `flex-1`
/// input can't shrink below its default `size="20"` width (no `min-w-0`),
/// so the row always ends up at that natural width (≈ 200px input + `gap-2`
/// + the 38px button).
const zslSearchBarWidth = 250.0;

/// Characters an `<input type="number">` lets you type.
final planNumberInputFormatters = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'[0-9eE.+\-]')),
];

const planNumberKeyboard = TextInputType.numberWithOptions(signed: true, decimal: true);

/// A native `<input type="checkbox">` (`w-4 h-4` = 16, `w-5 h-5` = 20; no
/// margin after Tailwind's preflight). [activeColor] is `accent-…`; `null`
/// keeps the browser's default look from the theme (#0075ff).
class PlanCheckbox extends StatelessWidget {
  const PlanCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 16,
    this.activeColor,
  });

  final bool value;
  final ValueChanged<bool> onChanged;
  final double size;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Transform.scale(
        scale: size / 18,
        child: Checkbox(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
          activeColor: activeColor,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
          overlayColor: const WidgetStatePropertyAll(Colors.transparent),
          splashRadius: 0,
        ),
      ),
    );
  }
}

/// A shadcn `<Button>` whose label gets lucide `<Loader2 class="mr-2 h-4 w-4
/// animate-spin">` in front while [loading]: 16px between spinner and text
/// (`mr-2` + the button's `gap-2`) and `has-[>svg]:px-3` padding.
class PlanSpinnerButton extends StatelessWidget {
  const PlanSpinnerButton({
    super.key,
    required this.label,
    required this.loading,
    required this.onPressed,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
    this.hoverBackgroundColor,
  });

  final String label;
  final bool loading;
  final VoidCallback onPressed;

  /// The page's `px-…` (used while not loading).
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? hoverBackgroundColor;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: loading ? null : onPressed,
      padding: loading ? const EdgeInsets.symmetric(horizontal: 12) : padding,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      hoverBackgroundColor: hoverBackgroundColor,
      child: loading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [const AppSpinner(size: 16), const SizedBox(width: 16), Flexible(child: Text(label))],
            )
          : Text(label),
    );
  }
}

/// `<i class="bi bi-arrow-repeat animate-spin">` (sized by the surrounding
/// text: 14px inside a `text-sm` button).
class PlanSpinIcon extends StatefulWidget {
  const PlanSpinIcon({super.key, this.size = 14, this.color});
  final double size;
  final Color? color;

  @override
  State<PlanSpinIcon> createState() => _PlanSpinIconState();
}

class _PlanSpinIconState extends State<PlanSpinIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))
    ..repeat();

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

/// `<Button><i class="bi bi-arrow-repeat animate-spin mr-2" />{{ loading ?
/// loadingLabel : label }}</Button>`: the icon sits 16px (`mr-2` + `gap-2`)
/// before the text while [loading].
class PlanIconSpinnerButton extends StatelessWidget {
  const PlanIconSpinnerButton({
    super.key,
    required this.label,
    required this.loadingLabel,
    required this.loading,
    required this.onPressed,
  });

  final String label;
  final String loadingLabel;
  final bool loading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AppButton(
      onPressed: loading ? null : onPressed,
      child: loading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [const PlanSpinIcon(), const SizedBox(width: 16), Flexible(child: Text(loadingLabel))],
            )
          : Text(label),
    );
  }
}

// ─────────────────────────────── Table ───────────────────────────────

/// One `<TableHead>` of a [PlanDataTable].
class PlanTableColumn {
  const PlanTableColumn(this.label, {this.flex = 1, this.alignEnd = false});
  final String label;

  /// Relative width (HTML sizes the columns by their content).
  final double flex;

  /// `text-right`
  final bool alignEnd;
}

/// A shadcn `<Card class="p-0"><Table>` (`text-sm`, `whitespace-nowrap`
/// cells in an `overflow-auto` wrapper) as the plan pages build it:
/// - header: style.css's unlayered `thead th` rule (`bg-primary
///   text-primary-foreground`, `padding: .5rem 1rem`, `h-10`), which beats
///   the templates' `bg-slate-50 text-slate-900`;
/// - loading: 6 rows of one `colspan` cell (`py-3`) holding a full-width
///   `<Skeleton class="h-5 w-full rounded-md">`;
/// - empty: one centred `text-gray-500` row ([emptyPadding]);
/// - rows: `p-2` cells, `hover:bg-muted/50`, `border-b` except the last.
class PlanDataTable extends StatelessWidget {
  const PlanDataTable({
    super.key,
    required this.columns,
    required this.rows,
    required this.loading,
    required this.emptyText,
    this.emptyPadding = const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
    this.headerWeight = FontWeight.w500,
    this.minWidth = 600,
    this.clip = true,
  });

  final List<PlanTableColumn> columns;

  /// One widget per column.
  final List<List<Widget>> rows;
  final bool loading;
  final String emptyText;
  final EdgeInsetsGeometry emptyPadding;

  /// `font-medium` (kit) or the page's `font-bold`.
  final FontWeight headerWeight;

  /// Below this width the table scrolls sideways.
  final double minWidth;

  /// The card's `overflow-hidden` (see [PlanCard.clip]).
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final border = context.borderColor;
    final scheme = context.colors;

    Widget cellRow(List<Widget> cells, EdgeInsets padding) => Row(
          children: [
            for (var i = 0; i < columns.length; i++)
              Expanded(
                flex: (columns[i].flex * 100).round(),
                child: Padding(
                  padding: padding,
                  child: Align(
                    alignment: columns[i].alignEnd ? Alignment.centerRight : Alignment.centerLeft,
                    child: cells[i],
                  ),
                ),
              ),
          ],
        );

    final header = Container(
      constraints: const BoxConstraints(minHeight: 40),
      decoration: BoxDecoration(
        color: scheme.primary,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: cellRow(
        [
          for (final c in columns)
            Text(
              c.label,
              maxLines: 1,
              softWrap: false,
              style: TextStyle(fontWeight: headerWeight, color: scheme.onPrimary),
            ),
        ],
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );

    final body = <Widget>[];
    if (loading) {
      for (var i = 0; i < 6; i++) {
        body.add(PlanHoverRow(
          border: i == 5 ? null : border,
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Skeleton(width: double.infinity, height: 20, radius: 14),
          ),
        ));
      }
    } else if (rows.isEmpty) {
      body.add(PlanHoverRow(
        child: Padding(
          padding: emptyPadding,
          child: Text(emptyText, textAlign: TextAlign.center, style: const TextStyle(color: Tw.gray500)),
        ),
      ));
    } else {
      for (var i = 0; i < rows.length; i++) {
        body.add(PlanHoverRow(
          border: i == rows.length - 1 ? null : border,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 36),
            child: cellRow(rows[i], const EdgeInsets.all(8)),
          ),
        ));
      }
    }

    return PlanCard(
      padding: EdgeInsets.zero,
      clip: clip,
      child: LayoutBuilder(
        builder: (context, c) {
          final width = c.maxWidth.isFinite ? math.max(c.maxWidth, minWidth) : minWidth;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: DefaultTextStyle.merge(
                // The table's `text-sm` (20px line).
                style: const TextStyle(fontSize: 14, height: 20 / 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [header, ...body],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// `<div class="flex justify-end gap-…">` of `<i class="bi …">` action icons
/// in a table cell (style.css's unlayered `table .bi` makes them 18px,
/// whatever `text-…` the icon has). [pointer] = `cursor-pointer`.
class PlanActionIcons extends StatelessWidget {
  const PlanActionIcons({super.key, required this.icons, required this.gap, this.pointer = true});

  final List<(IconData icon, Color color, VoidCallback onTap)> icons;
  final double gap;
  final bool pointer;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < icons.length; i++) ...[
          if (i > 0) SizedBox(width: gap),
          MouseRegion(
            cursor: pointer ? SystemMouseCursors.click : MouseCursor.defer,
            child: GestureDetector(
              onTap: icons[i].$3,
              behavior: HitTestBehavior.opaque,
              child: Icon(icons[i].$1, size: 18, color: icons[i].$2),
            ),
          ),
        ],
      ],
    );
  }
}

/// The plans table of Zslplan.vue / Zslplanlist.vue inside its
/// `<Card class="p-0 overflow-hidden">`: `font-bold` headers, "No plan data
/// available." (`py-8`) when empty, edit / delete icons (`gap-3`).
class ZslPlanTable extends StatelessWidget {
  const ZslPlanTable({
    super.key,
    required this.plans,
    required this.loading,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Map<String, dynamic>> plans;
  final bool loading;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final ValueChanged<Map<String, dynamic>> onDelete;

  static const _columns = [
    PlanTableColumn('Class Name', flex: 2),
    PlanTableColumn('Syllabus', flex: 1.2),
    PlanTableColumn('Duration (Days)', flex: 1.5),
    PlanTableColumn('Price'),
    PlanTableColumn('Actions', alignEnd: true),
  ];

  @override
  Widget build(BuildContext context) {
    return PlanDataTable(
      columns: _columns,
      loading: loading,
      headerWeight: FontWeight.w700,
      minWidth: 680,
      emptyText: 'No plan data available.',
      emptyPadding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
      rows: [
        for (final plan in plans)
          [
            Text(jsDisplay(plan['class_name']), style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(jsDisplay(plan['syllabus'])),
            Text(jsDisplay(plan['duration'])),
            // `font-mono` (ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas…)
            Text(
              jsDisplay(plan['price']),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontFamilyFallback: ['SF Mono', 'Menlo', 'Monaco', 'Consolas', 'Liberation Mono', 'Courier New'],
              ),
            ),
            PlanActionIcons(
              gap: 12,
              icons: [
                (BootstrapIcons.pencil_square, Tw.green600, () => onEdit(plan)),
                (BootstrapIcons.trash3_fill, Tw.red600, () => onDelete(plan)),
              ],
            ),
          ],
      ],
    );
  }
}

/// `<TableRow>`: `hover:bg-muted/50 border-b`.
class PlanHoverRow extends StatefulWidget {
  const PlanHoverRow({super.key, required this.child, this.border});
  final Widget child;

  /// Bottom border colour (`null` for the last row).
  final Color? border;

  @override
  State<PlanHoverRow> createState() => _PlanHoverRowState();
}

class _PlanHoverRowState extends State<PlanHoverRow> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final muted = context.isDark ? AppColors.darkMuted : AppColors.muted;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: _hovered ? muted.withValues(alpha: 0.5) : null,
          border: widget.border == null ? null : Border(bottom: BorderSide(color: widget.border!)),
        ),
        child: widget.child,
      ),
    );
  }
}

// ─────────────────────────────── Pagination ───────────────────────────────

/// The `<Pagination>` block of Zslplan.vue / Zslplanlist.vue
/// (`mt-4 flex justify-end` → `m-2`): ghost "Prev" / "Next"
/// (`PaginationPrevious`: `h-9 px-2.5`) and a sliding window of 5 pages
/// (`visiblePages()`), active page `bg-blue-600 text-white`.
///
/// Differs from the shared `AppPagination` (fixed groups of 5/10,
/// `bg-blue-500`), hence this private variant. Clicking the current page
/// reloads it, as on the web.
class ZslPagination extends StatelessWidget {
  const ZslPagination({super.key, required this.meta, required this.onPageChanged});

  /// `zslPagination` (`null` → no page numbers, Prev/Next disabled).
  final PageMeta? meta;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final m = meta;
    final current = m?.currentPage ?? 1;
    final last = m?.lastPage ?? 1;
    final pages = zslVisiblePages(m?.currentPage, m?.lastPage);

    // `changePage(page)`
    void go(int page) {
      if (m == null || page < 1 || page > m.lastPage) return;
      onPageChanged(page);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppButton(
                  label: 'Prev',
                  variant: AppButtonVariant.ghost,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  onPressed: current <= 1 ? null : () => go(current - 1),
                ),
                const SizedBox(width: 4),
                for (final p in pages) ...[
                  _PageChip(page: p, active: p == m?.currentPage, onTap: () => go(p)),
                  const SizedBox(width: 4),
                ],
                AppButton(
                  label: 'Next',
                  variant: AppButtonVariant.ghost,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  onPressed: current >= last ? null : () => go(current + 1),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// `<PaginationItem>`: a ghost `size-9` button (36×36, `rounded-md text-sm
/// font-medium`) with the page's classes. Inactive: `border
/// hover:bg-gray-100` (dark: the ghost's `hover:bg-accent/50`); active:
/// `bg-blue-600 text-white`, no border, and the ghost's `hover:bg-accent`
/// still applies. Hovered text is `text-accent-foreground` in both cases.
class _PageChip extends StatefulWidget {
  const _PageChip({required this.page, required this.active, required this.onTap});

  final int page;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_PageChip> createState() => _PageChipState();
}

class _PageChipState extends State<_PageChip> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final active = widget.active;
    final Color bg;
    if (_hover) {
      bg = dark ? AppColors.accent.withValues(alpha: 0.5) : (active ? AppColors.accent : Tw.gray100);
    } else {
      bg = active ? Tw.blue600 : Colors.transparent;
    }
    // Inactive and not hovered: the inherited text colour.
    final fg = _hover ? AppColors.accentForeground : (active ? Colors.white : null);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: active ? null : Border.all(color: context.borderColor),
          ),
          child: Text(
            '${widget.page}',
            softWrap: false,
            overflow: TextOverflow.visible,
            style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: fg),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────── Update dialog ───────────────────────────────

/// Opens the "Update …" dialog of Zslplan.vue / Zslplanlist.vue on a copy of
/// [editForm] (see `zslEditFormFrom`). [onSubmit] receives the edited form
/// once the required fields are filled; the dialog closes (resolving to
/// `true`) when it completes and stays open when it throws.
Future<bool> showZslPlanUpdateDialog(
  BuildContext context, {
  required Map<String, dynamic> editForm,
  required String title,
  required Future<void> Function(Map<String, dynamic> editForm) onSubmit,
  bool primaryTitle = false,
  bool showNameField = false,
  bool borderedCancel = false,
  bool expandSave = false,
}) async {
  final saved = await showAppDialog<bool>(
    context,
    builder: (_) => ZslPlanUpdateDialog(
      editForm: editForm,
      title: title,
      onSubmit: onSubmit,
      primaryTitle: primaryTitle,
      showNameField: showNameField,
      borderedCancel: borderedCancel,
      expandSave: expandSave,
    ),
  );
  return saved ?? false;
}

class ZslPlanUpdateDialog extends ConsumerStatefulWidget {
  const ZslPlanUpdateDialog({
    super.key,
    required this.editForm,
    required this.title,
    required this.onSubmit,
    this.primaryTitle = false,
    this.showNameField = false,
    this.borderedCancel = false,
    this.expandSave = false,
  });

  final Map<String, dynamic> editForm;
  final String title;
  final Future<void> Function(Map<String, dynamic> editForm) onSubmit;

  /// `text-primary` title (Zslplan.vue).
  final bool primaryTitle;

  /// The "Name" input (Zslplan.vue only).
  final bool showNameField;

  /// `<Button variant="ghost" class="border">` Cancel (Zslplan.vue).
  final bool borderedCancel;

  /// `w-full` Save button (Zslplanlist.vue).
  final bool expandSave;

  @override
  ConsumerState<ZslPlanUpdateDialog> createState() => _ZslPlanUpdateDialogState();
}

class _ZslPlanUpdateDialogState extends ConsumerState<ZslPlanUpdateDialog> {
  late final Map<String, dynamic> _form = {...widget.editForm};
  late final _name = TextEditingController(text: jsDisplay(_form['class_name']));
  late final _duration = TextEditingController(text: numberInputText(_form['duration']));
  late final _price = TextEditingController(text: numberInputText(_form['price']));
  bool _isUpdating = false;

  @override
  void dispose() {
    _name.dispose();
    _duration.dispose();
    _price.dispose();
    super.dispose();
  }

  /// `onEditSyllabusChange()`
  void _onSyllabusChanged(Object? value) {
    if (value == _form['syllabus']) return;
    setState(() {
      _form['syllabus'] = value;
      _form['class_id'] = null;
      _form['class_name'] = '';
      _name.text = '';
    });
  }

  /// `onEditClassNameChange(selectedId)`: also copies the class name.
  void _onClassChanged(Object? id, List<Map<String, dynamic>> allClasses) {
    setState(() {
      _form['class_id'] = id;
      if (!jsTruthy(id)) return;
      final wanted = jsNumber(id);
      for (final c in allClasses) {
        final cid = jsNumber(c['id']);
        if (cid != null && cid == wanted) {
          _form['class_id'] = c['id'];
          _form['class_name'] = c['name'];
          _name.text = jsDisplay(c['name']);
          break;
        }
      }
    });
  }

  /// `submitUpdate()`
  Future<void> _submit() async {
    if (zslEditFormIncomplete(_form)) {
      AppToast.error('Please fill in all required fields');
      return;
    }
    setState(() => _isUpdating = true);
    try {
      await widget.onSubmit({..._form});
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      // The API client already toasted the error; the dialog stays open.
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(zslPlanControllerProvider);
    final classes = zslClassesForSyllabus(s.allClasses, _form['syllabus']);
    final twoCols = context.isMd;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        PlanFormGrid(
          twoColumns: twoCols,
          columnGap: 16,
          rowGap: 16,
          cells: [
            PlanGridCell(AppSelect<Object?>(
              label: 'Syllabus',
              value: _form['syllabus'],
              placeholder: 'Select Syllabus',
              items: const [AppSelectItem('CBSE', 'CBSE'), AppSelectItem('STATE', 'STATE')],
              onChanged: _onSyllabusChanged,
            )),
            PlanGridCell(AppSelect<Object?>(
              label: 'Class Name',
              value: _form['class_id'],
              placeholder: 'Select Class',
              enabled: classes.isNotEmpty,
              items: [for (final c in classes) AppSelectItem<Object?>(c['id'], jsDisplay(c['name']))],
              onChanged: (v) => _onClassChanged(v, s.allClasses),
            )),
          ],
        ),
        if (widget.showNameField) ...[
          const SizedBox(height: 20),
          AppTextField(
            controller: _name,
            label: 'Name',
            hint: 'Enter name',
            onChanged: (v) => _form['class_name'] = v,
          ),
        ],
        const SizedBox(height: 20),
        AppSelect<Object?>(
          label: 'State',
          value: _form['state_id'],
          placeholder: 'Select State',
          items: [for (final st in s.states) AppSelectItem<Object?>(st['id'], jsDisplay(st['name']))],
          onChanged: (v) => setState(() => _form['state_id'] = v),
        ),
        const SizedBox(height: 20),
        PlanFormGrid(
          twoColumns: twoCols,
          columnGap: 16,
          rowGap: 16,
          cells: [
            PlanGridCell(AppTextField(
              controller: _duration,
              label: 'Duration (Days)',
              keyboardType: planNumberKeyboard,
              inputFormatters: planNumberInputFormatters,
              onChanged: (v) => _form['duration'] = numberInputValue(v),
            )),
            PlanGridCell(AppTextField(
              controller: _price,
              label: 'Price (₹)',
              keyboardType: planNumberKeyboard,
              inputFormatters: planNumberInputFormatters,
              onChanged: (v) => _form['price'] = numberInputValue(v),
            )),
          ],
        ),
        const SizedBox(height: 20),
        _FullAccessBox(
          value: jsTruthy(_form['full_access']),
          onChanged: (v) => setState(() => _form['full_access'] = v),
        ),
      ],
    );

    final wide = context.isSm;
    // `variant="ghost" class="w-full sm:w-auto border"` (Zslplan.vue) /
    // `variant="ghost" class="w-full sm:w-auto"` (Zslplanlist.vue).
    final cancel = AppButton(
      label: 'Cancel',
      variant: AppButtonVariant.ghost,
      borderColor: widget.borderedCancel ? context.borderColor : null,
      onPressed: () => Navigator.of(context).pop(false),
    );
    // `class="sm:px-8"` / `class="w-full sm:px-8"`.
    final save = PlanSpinnerButton(
      label: 'Save Changes',
      loading: _isUpdating,
      padding: wide ? const EdgeInsets.symmetric(horizontal: 32) : null,
      onPressed: _submit,
    );

    return _SectionedDialogFrame(
      title: widget.title,
      titleColor: widget.primaryTitle ? context.colors.primary : null,
      body: body,
      footer: wide
          ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                cancel,
                const SizedBox(width: 8),
                if (widget.expandSave) Expanded(child: save) else save,
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [save, const SizedBox(height: 8), cancel],
            ),
    );
  }
}

/// `flex items-center gap-3 p-3 rounded-lg border` with a `w-4 h-4
/// accent-primary` checkbox and its `<Label for>` (`text-sm font-semibold
/// cursor-pointer`); only those two toggle the flag.
class _FullAccessBox extends StatelessWidget {
  const _FullAccessBox({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: PlanCheckbox(value: value, activeColor: context.colors.primary, onChanged: onChanged),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => onChanged(!value),
                child: const Text(
                  'Full Access Plan',
                  style: TextStyle(fontSize: 14, height: 1, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `<DialogContent class="w-[95vw] bg-white dark:bg-card sm:max-w-[500px] p-0
/// border-none shadow-2xl flex flex-col max-h-[90vh]">` (still the kit's
/// `gap-4`) with a bordered header (`p-6 border-b`; `text-xl` drops the
/// title's `leading-none`, so it has a 28px line), a scrolling body (`p-6`)
/// and a bordered footer (`p-6 border-t`). The shared `AppDialogFrame` is
/// frosted and unsectioned.
class _SectionedDialogFrame extends StatelessWidget {
  const _SectionedDialogFrame({
    required this.title,
    required this.body,
    required this.footer,
    this.titleColor,
  });

  final String title;
  final Color? titleColor;
  final Widget body;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final size = MediaQuery.sizeOf(context);
    final border = dark ? AppColors.darkBorder : AppColors.border;
    final width = math.min(size.width * 0.95, context.isSm ? 500.0 : size.width - 32);

    Widget frame = Container(
      width: width,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        // shadow-2xl (the theme's `0 1px 3px rgb(0 0 0/.25)`).
        boxShadow: AppShadows.xl2,
      ),
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
                child: Text(
                  title,
                  // DialogHeader: `text-center sm:text-left`.
                  textAlign: context.isSm ? TextAlign.left : TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 28 / 20, color: titleColor),
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: body,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(border: Border(top: BorderSide(color: border))),
                child: footer,
              ),
            ],
          ),
          // `<DialogClose class="absolute top-4 right-4 …">`
          const Positioned(top: 16, right: 16, child: DialogCloseButton()),
        ],
      ),
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
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: width, maxHeight: size.height * 0.9),
        child: frame,
      ),
    );
  }
}

// ─────────────────────────────── Delete dialog ───────────────────────────────

/// The "Delete …" confirmation of Zslplan.vue / Zslplanlist.vue
/// (`sm:max-w-md`, red title, ghost Cancel, `bg-red-600 hover:bg-red-700`
/// Delete with spinner; the `<DialogFooter class="… mt-4">` keeps the kit's
/// `flex-col-reverse` below 640px). [onConfirm] runs while the spinner
/// shows; the dialog closes when it completes and stays open when it throws.
Future<void> showZslPlanDeleteDialog(
  BuildContext context, {
  required String title,
  required Future<void> Function() onConfirm,
}) =>
    showAppDialog<void>(
      context,
      builder: (_) => _ZslDeleteDialog(title: title, onConfirm: onConfirm),
    );

class _ZslDeleteDialog extends StatefulWidget {
  const _ZslDeleteDialog({required this.title, required this.onConfirm});
  final String title;
  final Future<void> Function() onConfirm;

  @override
  State<_ZslDeleteDialog> createState() => _ZslDeleteDialogState();
}

class _ZslDeleteDialogState extends State<_ZslDeleteDialog> {
  bool _isDeleting = false;

  /// `confirmDeletePlan()`
  Future<void> _confirm() async {
    setState(() => _isDeleting = true);
    try {
      await widget.onConfirm();
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      // Already toasted by the API client; the dialog stays open.
    } finally {
      if (mounted) setState(() => _isDeleting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = context.isSm;
    // DialogHeader is centred below 640px.
    final align = wide ? TextAlign.left : TextAlign.center;
    return AppDialogFrame(
      maxWidth: 448,
      // The kit's `gap-4` + the footer's `mt-4`.
      actionsGap: 32,
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.ghost,
          onPressed: () => Navigator.of(context).pop(),
        ),
        PlanSpinnerButton(
          label: 'Delete',
          loading: _isDeleting,
          backgroundColor: Tw.red600,
          foregroundColor: Colors.white,
          hoverBackgroundColor: Tw.red700,
          onPressed: _confirm,
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            // Room for the close button (as AppDialogFrame's own title).
            padding: EdgeInsets.only(right: wide ? 28 : 0),
            child: Text(
              widget.title,
              textAlign: align,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1, color: Tw.red600),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Are you sure you want to delete this plan? This action cannot be undone.',
            textAlign: align,
            style: TextStyle(fontSize: 14, height: 20 / 14, color: context.mutedFgColor),
          ),
        ],
      ),
    );
  }
}
