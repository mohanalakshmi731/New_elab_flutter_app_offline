import 'dart:math' as math;
import 'dart:ui';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/lucide_icon.dart';
import 'institute_plan_controller.dart';
import 'zsl_plan_widgets.dart';

/// Widgets shared by the institute subscription-plan pages
/// (`InstituteplanList.vue`, `InstituteplanCreate.vue`, `InstituteplanUpdate.vue`).

/// `text-muted-foreground` (`--muted-foreground`: #1f2430 / dark #9db1d4).
Color institutePlanMutedFg(BuildContext context) => context.mutedFgColor;

/// `border` (`--border`).
Color institutePlanBorder(BuildContext context) => context.borderColor;

// ─── Form field definitions (`formFields` in Create/Update) ───

class InstitutePlanFieldSpec {
  const InstitutePlanFieldSpec(this.key, this.label, this.type, this.placeholder, this.required);
  final String key;
  final String label;

  /// `text` | `number`
  final String type;
  final String placeholder;
  final bool required;

  bool get isNumber => type == 'number';
}

/// The 16 inputs of `formFields`, in order (the trailing `class_id` select is
/// built by each page).
const institutePlanFields = [
  InstitutePlanFieldSpec('name', 'Name', 'text', 'Enter Name', true),
  InstitutePlanFieldSpec('price', 'Price', 'text', 'Enter Price', true),
  InstitutePlanFieldSpec('days', 'Days', 'number', 'Enter Days', true),
  InstitutePlanFieldSpec('description', 'Description', 'text', 'Enter Description', true),
  InstitutePlanFieldSpec('students', 'No.of Students', 'number', 'Enter No.of Students', false),
  InstitutePlanFieldSpec('cost_per_student', 'Cost Per Student', 'number', 'Enter Price', false),
  InstitutePlanFieldSpec('instructors', 'No.of Teachers', 'number', 'Enter No.of Teachers', false),
  InstitutePlanFieldSpec('cost_per_instructor', 'Cost Per Teacher', 'number', 'Enter Price', false),
  InstitutePlanFieldSpec('classes', 'No.of Classes', 'number', 'Enter No.of Classes', false),
  InstitutePlanFieldSpec('cost_per_class', 'Cost Per Class', 'number', 'Enter Price', false),
  InstitutePlanFieldSpec('courses', 'No.of Courses', 'number', 'Enter No.of Courses', false),
  InstitutePlanFieldSpec('cost_per_course', 'Cost Per Course', 'number', 'Enter Price', false),
  InstitutePlanFieldSpec('books', 'No.of Books', 'number', 'Enter No.of Books', false),
  InstitutePlanFieldSpec('cost_per_book', 'Cost Per Book', 'number', 'Enter Price', false),
  InstitutePlanFieldSpec('display_price', 'Display Price', 'number', 'Enter Display Price', true),
  InstitutePlanFieldSpec('display_description', 'Display Description', 'text', 'Enter Display Description', true),
];

/// A ZSL plan option: `{{ plan.class_name }} ({{ plan.syllabus }}) - ₹{{ plan.price }}`.
String institutePlanZslLabel(Map<String, dynamic> plan) =>
    '${planText(plan['class_name'])} (${planText(plan['syllabus'])}) - ₹${planText(plan['price'])}';

/// `zslPlansByClass[classId]` as select options (plans without an `id` can't
/// be selected).
List<AppSelectItem<Object>> institutePlanZslItems(List<Map<String, dynamic>> plans) => [
      for (final p in plans)
        if (p['id'] != null) AppSelectItem<Object>(p['id'] as Object, institutePlanZslLabel(p)),
    ];

// ─── Layout ───

/// shadcn `<Card>`: `bg-card text-card-foreground flex flex-col gap-6
/// rounded-xl border py-6 shadow-sm` (pass the page's `px-*` / `p-*`
/// override as [padding]).
class InstitutePlanCard extends StatelessWidget {
  const InstitutePlanCard({
    super.key,
    required this.children,
    this.padding = const EdgeInsets.symmetric(vertical: 24),
  });

  final List<Widget> children;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return PlanCard(
      padding: padding,
      clip: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 24),
            children[i],
          ],
        ],
      ),
    );
  }
}

/// CSS `grid grid-cols-N gap-4`: [cells] fill rows left to right.
class InstitutePlanGrid extends StatelessWidget {
  const InstitutePlanGrid({super.key, required this.columns, required this.cells, this.gap = 16});
  final int columns;
  final List<Widget> cells;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += columns) {
      if (i > 0) rows.add(SizedBox(height: gap));
      if (columns == 1) {
        rows.add(cells[i]);
        continue;
      }
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var j = 0; j < columns; j++) ...[
            if (j > 0) SizedBox(width: gap),
            Expanded(child: i + j < cells.length ? cells[i + j] : const SizedBox.shrink()),
          ],
        ],
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

// ─── Form controls ───

/// `<FormLabel>{{ label }} <span class="text-red-500 text-lg">*</span></FormLabel>`
/// (`flex items-center gap-2 text-sm font-medium leading-none`; the span's
/// `text-lg` inherits the `leading-none`; the create page bumps both to
/// `text-2xl` at ≥1600px).
class InstitutePlanFieldLabel extends StatelessWidget {
  const InstitutePlanFieldLabel(this.text, {super.key, this.required = false, this.big = false});
  final String text;
  final bool required;
  final bool big;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Flexible(
          child: Text(text, style: TextStyle(fontSize: big ? 24 : 14, fontWeight: FontWeight.w500, height: 1)),
        ),
        if (required) ...[
          const SizedBox(width: 8),
          Text(
            '*',
            style: TextStyle(color: Tw.red500, fontSize: big ? 24 : 18, fontWeight: FontWeight.w500, height: 1),
          ),
        ],
      ],
    );
  }
}

/// `<FormItem><FormLabel/><Input :type :placeholder v-model/></FormItem>`.
/// Number inputs report `''` while their text is not a valid number, like
/// the browser does.
class InstitutePlanInput extends StatelessWidget {
  const InstitutePlanInput({
    super.key,
    required this.spec,
    required this.controller,
    required this.onChanged,
    this.big = false,
  });

  final InstitutePlanFieldSpec spec;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  /// `min-[1600px]:p-7 min-[1600px]:text-2xl min-[1600px]:placeholder:text-2xl`
  /// (create page only): the 28px padding outgrows `h-9`, so the box is
  /// 58px tall (28 + 28 + border) with the 24px text centred.
  final bool big;

  @override
  Widget build(BuildContext context) {
    final keyboard = spec.isNumber ? const TextInputType.numberWithOptions(decimal: true, signed: true) : null;
    final formatters = spec.isNumber ? [FilteringTextInputFormatter.allow(RegExp(r'[0-9.eE+\-]'))] : null;
    void changed(String t) => onChanged(spec.isNumber ? htmlNumberInputValue(t) : t);

    final Widget input;
    if (!big) {
      input = AppTextField(
        controller: controller,
        hint: spec.placeholder,
        keyboardType: keyboard,
        inputFormatters: formatters,
        onChanged: changed,
      );
    } else {
      final style = appInputTextStyle(context, fontSize: 24);
      final lineHeight = style.fontSize! * style.height!;
      input = TextField(
        controller: controller,
        keyboardType: keyboard,
        inputFormatters: formatters,
        onChanged: changed,
        style: style,
        textAlignVertical: TextAlignVertical.center,
        decoration: InputDecoration(
          hintText: spec.placeholder,
          hintStyle: style.copyWith(color: AppColors.placeholder),
          contentPadding: EdgeInsets.symmetric(horizontal: 28, vertical: math.max(0, (58 - lineHeight) / 2)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        InstitutePlanFieldLabel(spec.label, required: spec.required, big: big),
        const SizedBox(height: 8),
        input,
      ],
    );
  }
}

/// The class `<Select multiple>` of the create / update forms: what
/// [AppSelect] lacks is `multiple` (the trigger lists the selected labels
/// joined by `, `, the menu stays open while toggling) and the pages'
/// percentage sizing.
///
/// Trigger: the kit's `h-9 rounded-md border border-input shadow-xs
/// bg-transparent dark:bg-input/30 dark:hover:bg-input/50`, placeholder
/// #9ca3af, `ChevronDown size-4 opacity-50`, plus the page's
/// `p-[2%]` / `p-[1%]` (a percentage of the form item's width, on all
/// sides — a large one makes the box taller than `h-9`), `w-full` /
/// `w-[50%]` and `text-[90%]` (of the inherited 16px). Menu: `bg-popover
/// border rounded-md p-1 shadow-md`, 4px below the trigger; items
/// `text-[95%]` (15.2px, the inherited 1.5 line height).
class InstitutePlanMultiSelect extends StatefulWidget {
  const InstitutePlanMultiSelect({
    super.key,
    required this.items,
    required this.selected,
    required this.onToggle,
    this.placeholder = 'Select Classes',
    this.widthFactor = 1,
    this.paddingFactor = 0.02,
    this.fixedMenuHeight = false,
    this.menuHeight = 200,
  });

  final List<AppSelectItem<int>> items;
  final List<int> selected;
  final ValueChanged<int> onToggle;
  final String placeholder;

  /// `w-full` (1) / `w-[50%]` (0.5) of the form item.
  final double widthFactor;

  /// `p-[2%]` (0.02) / `p-[1%]` (0.01) of the form item's width.
  final double paddingFactor;

  /// `h-[200px]` (true) vs `max-h-[200px]` (false) on the menu.
  final bool fixedMenuHeight;
  final double menuHeight;

  @override
  State<InstitutePlanMultiSelect> createState() => _InstitutePlanMultiSelectState();
}

class _InstitutePlanMultiSelectState extends State<InstitutePlanMultiSelect> {
  final _menu = MenuController();
  bool _focused = false;
  bool _hovered = false;

  void _toggleMenu() => _menu.isOpen ? _menu.close() : _menu.open();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final input = context.inputColor;
    final mutedFg = context.mutedFgColor;
    // `SelectValue`: the selected items' text in model order.
    final labels = <String>[];
    for (final v in widget.selected) {
      for (final it in widget.items) {
        if (it.value == v) {
          if (it.label.isNotEmpty) labels.add(it.label);
          break;
        }
      }
    }
    final placeholder = labels.isEmpty;

    return LayoutBuilder(
      builder: (context, c) {
        final itemWidth = c.maxWidth.isFinite ? c.maxWidth : 220.0;
        final width = itemWidth * widget.widthFactor;
        final pad = itemWidth * widget.paddingFactor;
        final height = math.max(36.0, 2 * pad + 2);
        final screenW = MediaQuery.sizeOf(context).width;
        final minW = math.max(128.0, width);
        final maxW = math.max(minW, screenW - 16);
        final itemStyle = appMenuItemStyle(context).copyWith(
          textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 15.2, height: 1.5)),
        );

        final menu = MenuAnchor(
          controller: _menu,
          crossAxisUnconstrained: false,
          alignmentOffset: const Offset(0, 4),
          style: MenuStyle(
            minimumSize: WidgetStatePropertyAll(Size(minW, widget.fixedMenuHeight ? widget.menuHeight : 0)),
            maximumSize: WidgetStatePropertyAll(Size(maxW, widget.menuHeight)),
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
            for (final it in widget.items)
              MenuItemButton(
                closeOnActivate: false,
                onPressed: it.enabled ? () => widget.onToggle(it.value) : null,
                style: itemStyle,
                overflowAxis: Axis.vertical,
                child: Row(
                  children: [
                    Expanded(child: Text(it.label)),
                    const SizedBox(width: 10),
                    // `absolute right-2 size-3.5` check indicator.
                    SizedBox.square(
                      dimension: 14,
                      child: widget.selected.contains(it.value)
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
            final ring = context.ringColor;
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
                  width: width,
                  height: height,
                  padding: EdgeInsets.symmetric(horizontal: pad),
                  decoration: BoxDecoration(
                    color: dark ? input.withValues(alpha: _hovered ? 0.5 : 0.3) : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    border: Border.all(color: _focused ? ring : input),
                    boxShadow: [
                      ...AppShadows.xs,
                      if (_focused) BoxShadow(color: ring.withValues(alpha: 0.5), spreadRadius: 3),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          placeholder ? widget.placeholder : labels.join(', '),
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14.4,
                            color: placeholder ? AppColors.placeholder : context.colors.onSurface,
                          ),
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
        return Align(alignment: Alignment.centerLeft, child: menu);
      },
    );
  }
}

/// The single `<Select v-model="item.zsl_plan_id">` of a class-access row:
/// the kit's `w-full` trigger, `max-h-[200px]` menu and, without plans, the
/// `py-3 text-center text-gray-400 text-sm` "No Plans Available" note.
Widget institutePlanAccessSelect({
  required List<Map<String, dynamic>> plans,
  required Object? value,
  required String placeholder,
  required ValueChanged<Object?> onChanged,
}) {
  final items = institutePlanZslItems(plans);
  return AppSelect<Object>(
    value: value,
    placeholder: placeholder,
    menuMaxHeight: 200,
    items: plans.isEmpty
        ? const [
            AppSelectItem<Object>.message(
              '',
              'No Plans Available',
              messagePadding: EdgeInsets.symmetric(vertical: 12),
              messageColor: Tw.gray400,
            ),
          ]
        : items,
    onChanged: onChanged,
  );
}

/// `<i class="bi bi-arrow-repeat animate-spin" />` inside the submit buttons
/// (14px = the button's `text-sm`; 24px at ≥1600px on the create page).
class InstitutePlanSpinner extends StatelessWidget {
  const InstitutePlanSpinner({super.key, this.size = 14});
  final double size;

  @override
  Widget build(BuildContext context) => PlanSpinIcon(size: size);
}

// ─── Plans table ───

/// The plans `<Card class="p-0"><Table>` of the list and create pages (no
/// `overflow-hidden`: the header's square corners show over the card's
/// rounded border, as on the web).
class InstitutePlanTable extends StatelessWidget {
  const InstitutePlanTable({
    super.key,
    required this.plans,
    required this.loading,
    required this.createdAtLabel,
    required this.onEdit,
    required this.onDelete,
    this.onNameTap,
  });

  final List<Map<String, dynamic>> plans;
  final bool loading;

  /// `created At` on the list page, `Created At` on the create page.
  final String createdAtLabel;
  final ValueChanged<Map<String, dynamic>> onEdit;
  final ValueChanged<Map<String, dynamic>> onDelete;

  /// Create page only: the name is an underlined link opening the view dialog.
  final ValueChanged<Map<String, dynamic>>? onNameTap;

  @override
  Widget build(BuildContext context) {
    return PlanDataTable(
      loading: loading,
      clip: false,
      minWidth: 600,
      emptyText: 'No data',
      columns: [
        const PlanTableColumn('Plan Name', flex: 1.4),
        PlanTableColumn(createdAtLabel, flex: 1.4),
        const PlanTableColumn('Days', flex: 0.6),
        const PlanTableColumn('Status', flex: 0.8),
        const PlanTableColumn('Actions', flex: 0.8, alignEnd: true),
      ],
      rows: [
        for (final plan in plans)
          [
            onNameTap == null
                ? Text(planText(plan['name']))
                : _LinkText(planText(plan['name']), onTap: () => onNameTap!(plan)),
            Text(formatPlanDate(plan['created_at'])),
            Text(planText(plan['days'])),
            Text(jsTruthy(plan['is_active']) ? 'Active' : 'Inactive'),
            // `flex justify-end gap-2`; the icons have no `cursor-pointer`.
            PlanActionIcons(
              gap: 8,
              pointer: false,
              icons: [
                (BootstrapIcons.pencil_square, Tw.green600, () => onEdit(plan)),
                (BootstrapIcons.trash, Tw.red600, () => onDelete(plan)),
              ],
            ),
          ],
      ],
    );
  }
}

/// `cursor-pointer text-primary underline underline-offset-2 hover:opacity-70
/// transition-opacity`
class _LinkText extends StatefulWidget {
  const _LinkText(this.text, {required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  State<_LinkText> createState() => _LinkTextState();
}

class _LinkTextState extends State<_LinkText> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: _hover ? 0.7 : 1,
          child: Text(
            widget.text,
            style: TextStyle(color: primary, decoration: TextDecoration.underline, decorationColor: primary),
          ),
        ),
      ),
    );
  }
}

/// `toast.success('Plan deleted successfully')` after a delete — skipped when
/// the API's own `message` (already toasted by the API client) says the same.
void institutePlanToastDeleted(dynamic res) {
  const text = 'Plan deleted successfully';
  if (!isSameToastText(asMap(res)?['message'], text)) AppToast.success(text);
}

// ─── Dialogs ───

/// `<DialogContent class="… p-0 overflow-hidden dark:bg-card">`: the kit's
/// frosted `bg-white/90` (opaque `bg-card` in dark mode), `border-white/40
/// dark:border-slate-800/80`, `rounded-[20px]`, `shadow-2xl`, zoom-in-95,
/// close button at `top-4 right-4` (painted over the content).
/// [width] is the resolved `w-full max-w-*`.
class InstitutePlanDialogShell extends StatelessWidget {
  const InstitutePlanDialogShell({super.key, required this.child, required this.width, this.maxHeight});
  final Widget child;
  final double width;
  final double? maxHeight;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final radius = BorderRadius.circular(20);
    Widget frame = Container(
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCard : Colors.white.withValues(alpha: 0.9),
        borderRadius: radius,
        border: Border.all(color: dark ? Tw.slate800.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.4)),
      ),
      child: Stack(
        children: [
          child,
          const Positioned(top: 16, right: 16, child: DialogCloseButton()),
        ],
      ),
    );
    frame = ClipRRect(
      borderRadius: radius,
      // backdrop-blur-xl (no visible effect behind the opaque dark card).
      child: dark ? frame : BackdropFilter(filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24), child: frame),
    );
    frame = DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: AppShadows.xl2),
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
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: width,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight ?? double.infinity),
          child: frame,
        ),
      ),
    );
  }
}

/// The `Confirm Delete` dialog of the list and create pages:
/// `<DialogContent class="sm:max-w-sm dark:bg-card">`, a `<DialogHeader>`
/// whose description has the plan name in `<strong>`, then a plain `flex
/// justify-end gap-2 mt-4` row (not stacked on phones) of two default
/// (primary) buttons. [onDelete] receives a callback that closes the dialog
/// (the web keeps it open when the delete fails).
Future<void> showInstitutePlanDeleteDialog(
  BuildContext context, {
  required Object? planName,
  required Future<void> Function(VoidCallback close) onDelete,
}) {
  return showAppDialog<void>(
    context,
    builder: (ctx) {
      // DialogHeader: `text-center sm:text-left`.
      final centered = !ctx.isSm;
      final align = centered ? TextAlign.center : TextAlign.start;
      return AppDialogFrame(
        maxWidth: 384,
        backgroundColor: ctx.isDark ? AppColors.darkCard : null,
        stackActionsOnMobile: false,
        // The kit's `gap-4` + the row's `mt-4`.
        actionsGap: 32,
        actions: [
          AppButton(label: 'Cancel', onPressed: () => Navigator.of(ctx).pop()),
          AppButton(label: 'Delete', onPressed: () => onDelete(() => Navigator.of(ctx).pop())),
        ],
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              // Room for the close button (as AppDialogFrame's own title).
              padding: EdgeInsets.only(right: centered ? 0 : 28),
              child: Text(
                'Confirm Delete',
                textAlign: align,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1),
              ),
            ),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(
                text: 'Are you sure you want to delete ',
                children: [
                  TextSpan(text: planText(planName), style: const TextStyle(fontWeight: FontWeight.w700)),
                  const TextSpan(text: '?'),
                ],
              ),
              textAlign: align,
              style: TextStyle(fontSize: 14, height: 20 / 14, color: ctx.mutedFgColor),
            ),
          ],
        ),
      );
    },
  );
}
