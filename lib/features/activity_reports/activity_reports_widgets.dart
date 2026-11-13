import 'dart:math' as math;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/form_fields.dart' show AppSelectItem, appMenuItemStyle;
import '../../widgets/lucide_icon.dart';
import '../classes/class_ui_kit.dart' show DashedBox;
import '../library/library_widgets.dart' show HoverLift, LibColors, LibGrid, libGridColumns, libNunito;
import 'activity_reports_controller.dart';
import 'activity_reports_logic.dart';

/// Text in the page's `font-[Nunito,sans-serif]` with the real weight face
/// (a weight merged onto an inherited Nunito style would be a synthetic
/// bold of the regular face).
TextStyle arText({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
  double? height,
  double? letterSpacing,
  List<Shadow>? shadows,
}) =>
    libNunito(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
      shadows: shadows,
    );

/// Colours of ActivityReports.vue that depend on the theme.
class ArColors {
  ArColors._();

  /// `text-primary` / `bg-primary/10` (`--primary`: #4f46e5 / dark #9db1d4).
  static Color primary(BuildContext c) => LibColors.primary(c);

  /// `text-foreground dark:text-gray-100`
  static Color fg(BuildContext c) => c.isDark ? Tw.gray100 : AppColors.foreground;

  /// `text-muted-foreground dark:text-gray-400` (light `--muted-foreground`
  /// is #1f2430 in style.css).
  static Color muted(BuildContext c) => c.isDark ? Tw.gray400 : AppColors.foreground;

  /// `text-muted-foreground` without a dark override.
  static Color mutedRaw(BuildContext c) =>
      c.isDark ? AppColors.darkMutedForeground : AppColors.foreground;

  /// `border-slate-200/50 dark:border-slate-700/50`
  static Color line(BuildContext c) =>
      c.isDark ? Tw.slate700.withValues(alpha: 0.5) : Tw.slate200.withValues(alpha: 0.5);

  /// `bg-slate-100/50 dark:bg-slate-800/50`
  static Color softFill(BuildContext c) =>
      c.isDark ? Tw.slate800.withValues(alpha: 0.5) : Tw.slate100.withValues(alpha: 0.5);

  /// `bg-muted dark:bg-[#343a49]` (empty-state icon circles).
  static Color mutedCircle(BuildContext c) => c.isDark ? const Color(0xFF343A49) : AppColors.muted;

  static const red50 = Tw.red50;
  static const red200 = Tw.red200;
  static const red700 = Tw.red700;
  static const red950 = Tw.red950;

  /// `dark:border-[#414657]`
  static const darkTileBorder = Color(0xFF414657);

  /// Filter `<SelectContent>`: `dark:bg-[#252936]`, items
  /// `dark:focus:bg-[#363c4b]`.
  static const darkMenu = Color(0xFF252936);
  static const darkMenuHover = Color(0xFF363C4B);
}

/// This theme's radii (style.css `--radius: 1rem`): `rounded-lg` 16,
/// `rounded-xl` 20; `rounded-2xl` 16 and `rounded-3xl` 24 keep Tailwind's.
class ArRadius {
  ArRadius._();
  static const lg = 16.0;
  static const xl = 20.0;
  static const xl2 = 16.0;
  static const xl3 = 24.0;
}

/// `shadow-sm` (this theme's value).
final arShadowSm = AppShadows.sm;

/// The page's section card: `bg-white/60 dark:bg-slate-800/50 rounded-2xl
/// shadow-sm border border-slate-200/50 dark:border-slate-700/50` (the
/// backdrop blur is left out, as on the other library pages).
class ArCard extends StatelessWidget {
  const ArCard({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: context.isDark ? Tw.slate800.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(ArRadius.xl2),
          border: Border.all(color: ArColors.line(context)),
          boxShadow: arShadowSm,
        ),
        child: child,
      );
}

/// `animate-spin` (one turn per second).
class ArSpin extends StatefulWidget {
  const ArSpin({super.key, required this.child});
  final Widget child;

  @override
  State<ArSpin> createState() => _ArSpinState();
}

class _ArSpinState extends State<ArSpin> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => RotationTransition(turns: _c, child: widget.child);
}

/// The filter `<Select>`s: the kit trigger merged with the page's `w-full
/// text-sm sm:text-base dark:text-white text-gray-800 bg-transparent border
/// border-slate-200/60 dark:border-slate-800 rounded-xl px-5 py-2.5`
/// (tailwind-merge keeps the kit's `h-9`, `shadow-xs`, `dark:bg-input/30
/// dark:hover:bg-input/50` and the focus-visible ring; the placeholder is
/// the global #9ca3af), and `<SelectContent class="min-w-[240px]
/// border-border bg-popover shadow-xl dark:border-[#414657]
/// dark:bg-[#252936] dark:text-gray-100">` whose items turn `bg-accent`
/// (`dark:focus:bg-[#363c4b]`) with `text-accent-foreground` when
/// highlighted. The menu is teleported to `<body>`, so it uses the app font,
/// not the page's Nunito.
class ReportSelect extends StatefulWidget {
  const ReportSelect({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.placeholder,
    this.enabled = true,
    this.menuMinWidth = 240,
  });

  final String? value;
  final List<AppSelectItem<String>> items;
  final ValueChanged<String> onChanged;
  final String placeholder;
  final bool enabled;

  /// `min-w-[240px]` (`min-w-[260px]` for chapters).
  final double menuMinWidth;

  @override
  State<ReportSelect> createState() => _ReportSelectState();
}

class _ReportSelectState extends State<ReportSelect> {
  final _menu = MenuController();
  bool _hovered = false;
  bool _focused = false;

  void _toggle() => _menu.isOpen ? _menu.close() : _menu.open();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final mutedFg = context.mutedFgColor;
    final enabled = widget.enabled;
    AppSelectItem<String>? selected;
    for (final it in widget.items) {
      if (it.value == widget.value) selected = it;
    }
    final fontSize = context.isSm ? 16.0 : 14.0;

    // Item colours: `text-popover-foreground dark:text-gray-100`, and the
    // highlighted `bg-accent dark:bg-[#363c4b] text-accent-foreground`.
    final itemFg = dark ? Tw.gray100 : AppColors.popoverForeground;
    bool hot(Set<WidgetState> s) =>
        s.contains(WidgetState.hovered) || s.contains(WidgetState.focused) || s.contains(WidgetState.pressed);
    ButtonStyle itemStyle(bool itemEnabled) => appMenuItemStyle(context).copyWith(
          backgroundColor: WidgetStateProperty.resolveWith(
              (s) => itemEnabled && hot(s) ? (dark ? ArColors.darkMenuHover : AppColors.accent) : Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith((s) => !itemEnabled
              ? mutedFg // `text-muted-foreground` on the disabled note
              : hot(s)
                  ? AppColors.accentForeground
                  : itemFg),
          mouseCursor: WidgetStatePropertyAll(itemEnabled ? SystemMouseCursors.click : SystemMouseCursors.basic),
        );

    return LayoutBuilder(builder: (context, c) {
      final width = c.maxWidth.isFinite ? c.maxWidth : 220.0;
      final screenW = MediaQuery.sizeOf(context).width;
      final minW = math.min(math.max(widget.menuMinWidth, width), math.max(128.0, screenW - 16));
      final maxW = math.max(minW, screenW - 16);

      final menu = MenuAnchor(
        controller: _menu,
        crossAxisUnconstrained: false,
        alignmentOffset: const Offset(0, 4),
        style: MenuStyle(
          minimumSize: WidgetStatePropertyAll(Size(minW, 0)),
          maximumSize: WidgetStatePropertyAll(Size(maxW, double.infinity)),
          backgroundColor: WidgetStatePropertyAll(dark ? ArColors.darkMenu : AppColors.popover),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
          // `shadow-xl` (0 1px 3px + 0 8px 10px -1px, 10% black).
          elevation: const WidgetStatePropertyAll(6),
          shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.35)),
          padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            side: BorderSide(color: dark ? ArColors.darkTileBorder : AppColors.border),
          )),
        ),
        menuChildren: [
          for (final it in widget.items)
            MenuItemButton(
              onPressed: it.enabled ? () => widget.onChanged(it.value) : null,
              style: itemStyle(it.enabled),
              overflowAxis: Axis.vertical,
              child: Opacity(
                // `data-[disabled]:opacity-50`
                opacity: it.enabled ? 1 : 0.5,
                child: Row(children: [
                  Expanded(child: Text(it.label)),
                  const SizedBox(width: 10),
                  // `absolute right-2 size-3.5` check indicator.
                  SizedBox.square(
                    dimension: 14,
                    child: it.value == widget.value
                        ? OverflowBox(
                            maxWidth: 16,
                            maxHeight: 16,
                            child: LucideIcon(Lucide.check, size: 16, color: mutedFg),
                          )
                        : null,
                  ),
                ]),
              ),
            ),
        ],
        builder: (context, controller, _) {
          final showRing = _focused && enabled;
          final input = context.inputColor;
          final border = showRing
              ? context.ringColor
              : (dark ? Tw.slate800 : Tw.slate200.withValues(alpha: 0.6));
          final fill = dark ? input.withValues(alpha: _hovered && enabled ? 0.5 : 0.3) : Colors.transparent;
          final textColor = selected == null ? AppColors.placeholder : (dark ? Colors.white : Tw.gray800);
          return FocusableActionDetector(
            enabled: enabled,
            mouseCursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
            onShowFocusHighlight: (v) => setState(() => _focused = v),
            onShowHoverHighlight: (v) => setState(() => _hovered = v),
            actions: {
              ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
                _toggle();
                return null;
              }),
            },
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: enabled ? _toggle : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 36,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(ArRadius.xl),
                  border: Border.all(color: border),
                  boxShadow: [
                    ...AppShadows.xs,
                    if (showRing) BoxShadow(color: context.ringColor.withValues(alpha: 0.5), spreadRadius: 3),
                  ],
                ),
                child: Row(children: [
                  Expanded(
                    child: Text(
                      selected?.label ?? widget.placeholder,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: arText(fontSize: fontSize, height: fontSize == 16 ? 1.5 : 20 / 14, color: textColor),
                    ),
                  ),
                  const SizedBox(width: 8),
                  LucideIcon(Lucide.chevronDown, size: 16, color: mutedFg.withValues(alpha: 0.5)),
                ]),
              ),
            ),
          );
        },
      );
      // `disabled:opacity-50`
      return enabled ? menu : Opacity(opacity: 0.5, child: menu);
    });
  }
}

/// `rounded-full px-2.5 py-1 text-xs` pill of the filter summary / report
/// header.
class ArPill extends StatelessWidget {
  const ArPill(this.text, {super.key, this.primary = false, this.bold = false, this.maxWidth});
  final String text;

  /// `bg-primary/10 text-primary`; otherwise the slate pill.
  final bool primary;

  /// `font-semibold` instead of `font-medium`.
  final bool bold;

  /// `max-w-[220px] truncate`
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final color = ArColors.primary(context);
    Widget pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: primary ? color.withValues(alpha: 0.1) : ArColors.softFill(context),
        borderRadius: BorderRadius.circular(999),
        border: primary ? null : Border.all(color: ArColors.line(context)),
      ),
      child: Text(
        text,
        maxLines: maxWidth == null ? null : 1,
        softWrap: maxWidth == null,
        overflow: maxWidth == null ? null : TextOverflow.ellipsis,
        style: arText(
          fontSize: 12,
          height: 16 / 12,
          fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
          color: primary ? color : (dark ? Tw.gray200 : AppColors.foreground),
        ),
      ),
    );
    if (maxWidth != null) pill = ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth!), child: pill);
    return pill;
  }
}

/// `h3 font-semibold` + `p mt-1 text-xs sm:text-sm` section title.
class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.subtitle);
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title, style: arText(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: ArColors.fg(context))),
          const SizedBox(height: 4),
          Text(subtitle,
              style: arText(
                  fontSize: context.isSm ? 14 : 12,
                  height: context.isSm ? 20 / 14 : 16 / 12,
                  color: ArColors.muted(context))),
        ],
      );
}

/// The dashed empty-state boxes ("No activities available" / "No
/// performance data"): `rounded-xl border border-dashed`.
class _EmptyBox extends StatelessWidget {
  const _EmptyBox({
    required this.icon,
    required this.title,
    required this.message,
    required this.borderColor,
    required this.fill,
    required this.verticalPadding,
    required this.titleGap,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color borderColor;
  final Color fill;
  final double verticalPadding;
  final double titleGap;

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: DashedBox(
          color: borderColor,
          fill: fill,
          radius: ArRadius.xl,
          strokeWidth: 1,
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: ArColors.mutedCircle(context), shape: BoxShape.circle),
              child: Icon(icon, size: 20, color: ArColors.muted(context)),
            ),
            SizedBox(height: titleGap),
            Text(title,
                textAlign: TextAlign.center,
                style: arText(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: ArColors.fg(context))),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 448),
                child: Text(message,
                    textAlign: TextAlign.center,
                    style: arText(fontSize: 14, height: 20 / 14, color: ArColors.muted(context))),
              ),
            ),
          ]),
        ),
      );
}

/// The report card shown once all four filters are chosen: summary, the
/// chapter's activities and the student × activity stars table.
class ActivityReportView extends StatelessWidget {
  const ActivityReportView({super.key, required this.controller, required this.hoveredRow});

  final ActivityReportsController controller;

  /// Row under the mouse (`hover:bg-slate-100/50` of the table rows).
  final ValueNotifier<int?> hoveredRow;

  EdgeInsets _pad(BuildContext context) =>
      EdgeInsets.all(context.isLg ? 24 : (context.isSm ? 20 : 16));

  @override
  Widget build(BuildContext context) {
    final activities = controller.displayedActivities;
    final students = controller.displayedStudents;
    final divider = BoxDecoration(border: Border(bottom: BorderSide(color: ArColors.line(context))));
    return ArCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          decoration: divider,
          padding: _pad(context),
          child: _summary(context, students.length, activities.length),
        ),
        Container(
          decoration: divider,
          padding: _pad(context),
          child: _activitiesSection(context, activities),
        ),
        Padding(
          padding: _pad(context),
          child: _performanceSection(context, students, activities),
        ),
      ]),
    );
  }

  // ── report summary ──

  Widget _summary(BuildContext context, int studentCount, int activityCount) {
    final primary = ArColors.primary(context);
    final chapterName = controller.selectedChapterName;

    Widget contextItem(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: primary),
          const SizedBox(width: 6),
          Flexible(
            child: Text(text,
                style: arText(
                    fontSize: 14,
                    height: 20 / 14,
                    color: context.isDark ? Tw.gray300 : AppColors.foreground.withValues(alpha: 0.8))),
          ),
        ]);

    final info = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
        ArPill(chapterName, primary: true, bold: true),
        Text('Activity Progress Report',
            style: arText(fontSize: 12, height: 16 / 12, color: ArColors.muted(context))),
      ]),
      const SizedBox(height: 12),
      Text(chapterName,
          style: arText(
              fontSize: 20,
              height: 28 / 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: ArColors.fg(context))),
      const SizedBox(height: 12),
      Wrap(spacing: 20, runSpacing: 8, children: [
        contextItem(BootstrapIcons.book, controller.selectedSubjectName),
        contextItem(BootstrapIcons.mortarboard, controller.selectedClassName),
        contextItem(BootstrapIcons.people, controller.selectedBatchName),
      ]),
    ]);

    // `rounded-xl border … bg-slate-100/50 px-4 py-3 text-center`
    Widget stat(IconData icon, int value, String label) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: ArColors.softFill(context),
            borderRadius: BorderRadius.circular(ArRadius.xl),
            border: Border.all(color: ArColors.line(context)),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 14, color: primary),
              const SizedBox(width: 8),
              Text('$value',
                  style: arText(
                      fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w600, color: ArColors.fg(context))),
            ]),
            const SizedBox(height: 2),
            Text(label,
                textAlign: TextAlign.center,
                style: arText(fontSize: 12, height: 16 / 12, color: ArColors.muted(context))),
          ]),
        );

    final students = stat(BootstrapIcons.people, studentCount, 'Students');
    final activities = stat(BootstrapIcons.journal_check, activityCount, 'Activities');

    if (context.isLg) {
      return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(child: Align(alignment: Alignment.topLeft, child: info)),
        const SizedBox(width: 20),
        IntrinsicWidth(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: ConstrainedBox(constraints: const BoxConstraints(minWidth: 110), child: students)),
            const SizedBox(width: 12),
            Expanded(child: ConstrainedBox(constraints: const BoxConstraints(minWidth: 110), child: activities)),
          ]),
        ),
      ]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      info,
      const SizedBox(height: 20),
      Row(children: [
        Expanded(child: students),
        const SizedBox(width: 12),
        Expanded(child: activities),
      ]),
    ]);
  }

  // ── chapter activities ──

  Widget _activitiesSection(BuildContext context, List<ReportActivity> activities) {
    final dark = context.isDark;
    const title = _SectionTitle('Chapter Activities', 'Activities available in the selected chapter');
    final count = activities.isEmpty
        ? null
        : Text(activityCountLabel(activities.length),
            style: arText(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: ArColors.muted(context)));
    final header = context.isSm
        ? Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Expanded(child: Align(alignment: Alignment.centerLeft, child: title)),
            ?count,
          ])
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            title,
            if (count != null) ...[const SizedBox(height: 4), count],
          ]);

    final Widget body;
    if (activities.isEmpty) {
      body = _EmptyBox(
        icon: BootstrapIcons.journal_x,
        title: 'No activities available',
        message: 'There are no activities available for the selected chapter.',
        borderColor: dark ? ArColors.darkTileBorder : AppColors.border,
        fill: dark ? const Color(0xFF20232E) : AppColors.muted.withValues(alpha: 0.2),
        verticalPadding: 40,
        titleGap: 12,
      );
    } else {
      body = LibGrid(
        columns: libGridColumns(context),
        gap: 12,
        stretch: true,
        children: [for (final a in activities) _ActivityTile(activity: a)],
      );
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      header,
      const SizedBox(height: 16),
      body,
    ]);
  }

  // ── student performance ──

  Widget _performanceSection(
      BuildContext context, List<ReportStudent> students, List<ReportActivity> activities) {
    final dark = context.isDark;
    const title = _SectionTitle('Student Performance', 'Activity-wise performance for students in the selected batch');
    final legend = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: ArColors.softFill(context),
        borderRadius: BorderRadius.circular(ArRadius.lg),
        border: Border.all(color: ArColors.line(context)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(BootstrapIcons.star_fill, size: 12, color: Tw.yellow400),
        const SizedBox(width: 8),
        Text('1 star = 1 mark', style: arText(fontSize: 12, height: 16 / 12, color: ArColors.muted(context))),
      ]),
    );
    final header = context.isSm
        ? Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Expanded(child: Align(alignment: Alignment.centerLeft, child: title)),
            const SizedBox(width: 12),
            legend,
          ])
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [title, const SizedBox(height: 12), legend]);

    final hasData = students.isNotEmpty && activities.isNotEmpty;
    final Widget body = hasData
        ? _PerformanceTable(students: students, activities: activities, hoveredRow: hoveredRow)
        : _EmptyBox(
            icon: BootstrapIcons.inbox,
            title: 'No performance data',
            message: 'There are no students or activities available for the selected filters.',
            borderColor: dark ? Tw.slate700.withValues(alpha: 0.5) : Tw.slate300.withValues(alpha: 0.5),
            fill: dark ? Tw.slate800.withValues(alpha: 0.3) : Tw.slate50.withValues(alpha: 0.5),
            verticalPadding: 48,
            titleGap: 16,
          );

    final footerStyle = arText(fontSize: 12, height: 16 / 12, color: ArColors.muted(context));
    final showing = Text('Showing ${students.length} students', style: footerStyle);
    final count = Text(activityCountLabel(activities.length), style: footerStyle);

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      header,
      const SizedBox(height: 16),
      body,
      if (hasData) ...[
        const SizedBox(height: 16),
        if (context.isSm)
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [showing, count])
        else
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [showing, const SizedBox(height: 8), count]),
      ],
    ]);
  }
}

/// One card of the "Chapter Activities" grid (`rounded-xl border p-3.5
/// transition-all hover:-translate-y-0.5 hover:bg-muted/50 hover:shadow-sm`).
class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});
  final ReportActivity activity;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final primary = ArColors.primary(context);
    return HoverLift(
      lift: 2,
      duration: const Duration(milliseconds: 150),
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: dark
              ? (hover ? const Color(0xFF353B4A) : const Color(0xFF2D3240))
              : AppColors.muted.withValues(alpha: hover ? 0.5 : 0.2),
          borderRadius: BorderRadius.circular(ArRadius.xl),
          border: Border.all(color: dark ? ArColors.darkTileBorder : AppColors.border),
          boxShadow: hover ? arShadowSm : null,
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // `h-10 w-10 rounded-lg` (16px radius).
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(ArRadius.lg)),
            child: Text(activity.code,
                maxLines: 1, style: arText(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w700, color: primary)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(activity.name,
                  style: arText(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: ArColors.fg(context))),
              const SizedBox(height: 6),
              Row(children: [
                Icon(BootstrapIcons.star, size: 12, color: primary),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(activityMarksLabel(activity),
                      style: arText(fontSize: 12, height: 16 / 12, color: ArColors.muted(context))),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// The `<Table class="min-w-max">` of student rows × activity columns
/// (`overflow-x-auto`; the student name column is not sticky).
///
/// Header cells follow style.css's unlayered `thead th` rule, which beats
/// the template's classes: `bg-primary text-primary-foreground`, `padding:
/// .5rem 1rem` and a `border-bottom: 1px solid var(--border)`; the row's
/// own `bg-slate-100/50` stays hidden behind the cells.
class _PerformanceTable extends StatelessWidget {
  const _PerformanceTable({required this.students, required this.activities, required this.hoveredRow});

  final List<ReportStudent> students;
  final List<ReportActivity> activities;
  final ValueNotifier<int?> hoveredRow;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final line = ArColors.line(context);
    final nameMin = sm ? 220.0 : 190.0;
    final colMin = sm ? 120.0 : 100.0;
    final fg = ArColors.fg(context);
    final primary = ArColors.primary(context);
    final headFg = dark ? AppColors.darkPrimaryForeground : AppColors.primaryForeground;

    Widget headCell(String text, {bool center = false}) => SizedBox(
          height: 40,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: center ? Alignment.center : Alignment.centerLeft,
              child: Text(text,
                  softWrap: false,
                  textAlign: center ? TextAlign.center : TextAlign.left,
                  style: arText(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: headFg)),
            ),
          ),
        );

    Widget hoverable(int index, Widget child) => MouseRegion(
          onEnter: (_) => hoveredRow.value = index,
          onExit: (_) {
            if (hoveredRow.value == index) hoveredRow.value = null;
          },
          child: child,
        );

    Widget scoreCell(ReportStudent student, ReportActivity activity) {
      final Widget content;
      final score = reportScore(student, activity);
      if (!activity.hasQuiz) {
        content = Text('No quiz',
            softWrap: false, style: arText(fontSize: 12, height: 16 / 12, color: ArColors.mutedRaw(context)));
      } else if (score == null) {
        content = Tooltip(
          message: 'Not attempted',
          child: Text('—',
              style: arText(fontSize: 14, height: 20 / 14, color: dark ? Tw.gray500 : AppColors.foreground)),
        );
      } else {
        final stars = starCount(score);
        content = Tooltip(
          message: '${jsNumberText(score)} marks',
          // `flex items-center justify-center gap-0.5`
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            for (var i = 0; i < stars; i++) ...[
              if (i > 0) const SizedBox(width: 2),
              const Icon(BootstrapIcons.star_fill, size: 14, color: Tw.yellow400),
            ],
            if (score == 0)
              Text('0', style: arText(fontSize: 14, height: 20 / 14, color: ArColors.mutedRaw(context))),
          ]),
        );
      }
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Center(child: content),
      );
    }

    Widget studentCell(ReportStudent student) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Text(student.initial,
                  style: arText(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w600, color: primary)),
            ),
            const SizedBox(width: 12),
            Text(student.name,
                softWrap: false,
                style: arText(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: fg)),
          ]),
        );

    final widths = <int, TableColumnWidth>{
      0: MaxColumnWidth(FixedColumnWidth(nameMin), const IntrinsicColumnWidth()),
      for (var i = 0; i < activities.length; i++)
        i + 1: MaxColumnWidth(FixedColumnWidth(colMin), const IntrinsicColumnWidth()),
    };
    final hoverColor = dark ? Tw.slate700.withValues(alpha: 0.5) : Tw.slate100.withValues(alpha: 0.5);

    // `w-full overflow-x-auto rounded-xl border border-slate-200/50
    // dark:border-slate-700/50`
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(ArRadius.xl), border: Border.all(color: line)),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: ValueListenableBuilder<int?>(
              valueListenable: hoveredRow,
              builder: (context, hovered, _) => Table(
                columnWidths: widths,
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      color: primary,
                      border: Border(bottom: BorderSide(color: context.borderColor)),
                    ),
                    children: [
                      headCell('Student Name'),
                      for (final a in activities) headCell(a.code, center: true),
                    ],
                  ),
                  for (var r = 0; r < students.length; r++)
                    TableRow(
                      decoration: BoxDecoration(
                        color: hovered == r ? hoverColor : null,
                        // `[&_tr:last-child]:border-0`
                        border: r == students.length - 1 ? null : Border(bottom: BorderSide(color: line)),
                      ),
                      children: [
                        hoverable(r, studentCell(students[r])),
                        for (final a in activities)
                          TableCell(
                            verticalAlignment: TableCellVerticalAlignment.fill,
                            child: hoverable(r, scoreCell(students[r], a)),
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
