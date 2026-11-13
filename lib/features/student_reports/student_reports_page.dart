import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' show NumberFormat;

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/lucide_icon.dart';
import '../mathzoro_zone/mz_zone_ui.dart' show ZonePress, ZoneRingSpinner, ZoneSvgIcon;
import '../student_payment/student_payment_logic.dart' show jsErrorMessage;
import 'student_reports_controller.dart';
import 'student_reports_logic.dart';

/// Colours of studentreports.vue.
class _Rc {
  _Rc._();
  static const pageDark = Color(0xFF161233);
  static const pageLight = Color(0xFFF1F5F9);

  /// `bg-[#26204b]/70`
  static const cardDark = Color(0xB326204B);

  /// `bg-[#1e1842]` (dropdown / point fill in dark mode)
  static const menuDark = Color(0xFF1E1842);
  static const indigo = Color(0xFF6366F1);
  static const amber = Color(0xFFF59E0B);
  static const green = Color(0xFF4ADE80);

  /// Chart.js `defaults.borderColor` (the axis lines, both modes).
  static const chartBorder = Color(0x1A000000);
}

/// Chart.js's default font stack (`'Helvetica Neue', 'Helvetica', 'Arial',
/// sans-serif`) — the charts don't use the page font.
TextStyle _chartFont(double size, Color color, {FontWeight weight = FontWeight.w400}) => TextStyle(
  fontFamily: 'Helvetica Neue',
  fontFamilyFallback: const ['Helvetica', 'Arial', 'sans-serif'],
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: 1.2,
);

/// lucide `clock`, `calendar-days` and `circle-alert` path data.
class _LucidePaths {
  _LucidePaths._();
  static const circle = 'M22 12a10 10 0 1 1-20 0a10 10 0 1 1 20 0z';
  static const clock = [circle, 'M12 6v6l4 2'];
  static const calendarDays = [
    'M8 2v4',
    'M16 2v4',
    'M5 4h14a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2V6a2 2 0 0 1 2-2z',
    'M3 10h18',
    'M8 14h.01',
    'M12 14h.01',
    'M16 14h.01',
    'M8 18h.01',
    'M12 18h.01',
    'M16 18h.01',
  ];
  static const circleAlert = [circle, 'M12 8v4', 'M12 16h.01'];
}

/// Port of
/// `src/components/new_ui_student_teacher_for_both_labs/studentreports.vue`
/// (`/newlayout/reports`, inside the MathZoro shell).
///
/// Visible on the web: the "Total Usage (This Year)" KPI card, the "Usage
/// Time" line chart with its date-range dropdown and the "Activity Usage"
/// line chart (always "This Week") with its summary pills. The radar/donut
/// row, the activity usage table (+ CSV export) and the activity type /
/// range dropdowns carry the `hidden` attribute on the web and are not
/// rendered, so they are not ported.
class StudentReportsPage extends ConsumerStatefulWidget {
  const StudentReportsPage({super.key});

  @override
  ConsumerState<StudentReportsPage> createState() => _StudentReportsPageState();
}

class _StudentReportsPageState extends ConsumerState<StudentReportsPage> {
  bool _usageLoading = false;
  String _usageError = '';
  String _selectedRangeKey = 'this_week';
  bool _dropdownOpen = false;

  List<String> _usageChartLabels = const [];
  List<int> _usageChartData = const [];
  int _totalMinutes = 0;

  bool _activityChartLoading = false;
  String _activityChartError = '';
  // The activity range / type dropdowns are hidden on the web, so these
  // never change.
  final String _selectedActivityRangeKey = 'this_week';
  final String _selectedActivityType = '';

  List<String> _activityChartLabels = const [];
  List<double> _activityChartMinutes = const [];
  List<ActivityPill> _activitySummary = const [];

  StudentReportsController get _ctrl => ref.read(studentReportsControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      _fetchUsageData();
      _fetchActivityChartStats();
      _fetchYearlyUsage();
    });
  }

  // ── data ────────────────────────────────────────────────────────────────

  void _selectRange(String key) {
    setState(() {
      _selectedRangeKey = key;
      _dropdownOpen = false;
    });
    _fetchUsageData();
  }

  Future<void> _fetchUsageData() async {
    final range = reportRange(_selectedRangeKey, DateTime.now());
    setState(() {
      _usageLoading = true;
      _usageError = '';
    });
    try {
      final data = await _ctrl.mathzorogetStudentSelfUsage(range.from, range.to);
      final mapped = mapUsageResponse(data);
      if (!mounted) return;
      setState(() {
        _usageChartLabels = mapped.labels;
        _usageChartData = mapped.minutes;
      });
    } catch (e) {
      if (mounted) setState(() => _usageError = jsErrorMessage(e, 'Failed to load usage data.'));
    } finally {
      if (mounted) setState(() => _usageLoading = false);
    }
  }

  Future<void> _fetchYearlyUsage() async {
    try {
      final range = yearRange(DateTime.now());
      final data = await _ctrl.mathzorogetStudentSelfUsage(range.from, range.to);
      if (mounted) setState(() => _totalMinutes = yearlyTotalMinutes(data));
    } catch (_) {
      // "Yearly usage error" — console only on the web.
    }
  }

  Future<void> _fetchActivityChartStats() async {
    final range = reportRange(_selectedActivityRangeKey, DateTime.now());
    setState(() {
      _activityChartLoading = true;
      _activityChartError = '';
    });
    try {
      final data = await _ctrl.mathzorogetActivityChartStats({
        'from': range.from,
        'to': range.to,
        if (_selectedActivityType.isNotEmpty) 'type': _selectedActivityType,
      });
      final report = mapActivityResponse(data);
      if (!mounted) return;
      setState(() {
        _activityChartLabels = report.labels;
        _activityChartMinutes = report.minutes;
        _activitySummary = report.summary;
      });
    } catch (e) {
      if (mounted) setState(() => _activityChartError = jsErrorMessage(e, 'Failed to load activity data.'));
    } finally {
      if (mounted) setState(() => _activityChartLoading = false);
    }
  }

  // ── template ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final px = context.isMd ? 32.0 : 16.0;
    return ColoredBox(
      color: dark ? _Rc.pageDark : _Rc.pageLight,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: dark ? Colors.white : Tw.gray900),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: px, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _kpiRow(context),
              const SizedBox(height: 24),
              _usageCard(context),
              const SizedBox(height: 24),
              _activityCard(context),
            ],
          ),
        ),
      ),
    );
  }

  // ROW 1: KPI cards (`grid-cols-1 md:grid-cols-3`, one card).
  Widget _kpiRow(BuildContext context) {
    final card = _KpiCard(
      label: 'Total Usage (This Year)',
      hours: _totalMinutes ~/ 60,
      minutes: _totalMinutes % 60,
      loading: _usageLoading,
    );
    if (!context.isMd) return card;
    return LayoutBuilder(
      builder: (context, c) => Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(width: (c.maxWidth - 48) / 3, child: card),
      ),
    );
  }

  // ROW 4: Usage Time line chart.
  Widget _usageCard(BuildContext context) {
    final dark = context.isDark;
    return _ReportCard(
      title: 'Usage Time',
      descriptionLead: 'Daily time spent — ',
      descriptionRange: reportRangeLabel(_selectedRangeKey),
      descriptionTail: ' (in minutes).',
      trailing: _RangeDropdown(
        selectedKey: _selectedRangeKey,
        open: _dropdownOpen,
        onOpenChanged: (v) => setState(() => _dropdownOpen = v),
        onSelected: _selectRange,
      ),
      children: [
        SizedBox(
          height: 250,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _usageLoading ? 0 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: _ReportLineChart(
                    labels: _usageChartLabels,
                    values: [for (final v in _usageChartData) v.toDouble()],
                    color: _Rc.indigo,
                    axis: usageAxis(_usageChartData),
                    yLabel: _numberLabel,
                  ),
                ),
              ),
              if (_usageLoading)
                const Positioned.fill(child: _ChartLoading(color: _Rc.indigo, text: 'Fetching usage data…')),
            ],
          ),
        ),
        if (_usageError.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ErrorBox(message: _usageError, dark: dark, onRetry: _fetchUsageData),
        ],
      ],
    );
  }

  // ROW 5: Activity chart stats.
  Widget _activityCard(BuildContext context) {
    final dark = context.isDark;
    return _ReportCard(
      title: 'Activity Usage',
      descriptionLead: 'Activity-wise breakdown — ',
      descriptionRange: reportRangeLabel(_selectedActivityRangeKey),
      descriptionTail: ' (count & time).',
      children: [
        SizedBox(
          height: 280,
          child: Stack(
            children: [
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _activityChartLoading ? 0 : 1,
                  duration: const Duration(milliseconds: 150),
                  child: _ReportLineChart(
                    labels: _activityChartLabels,
                    values: _activityChartMinutes,
                    color: _Rc.amber,
                    axis: activityAxis(_activityChartMinutes),
                    yLabel: formatReportMinutes,
                    includeMaxTick: true,
                  ),
                ),
              ),
              if (_activityChartLoading)
                const Positioned.fill(child: _ChartLoading(color: _Rc.amber, text: 'Fetching activity data…')),
            ],
          ),
        ),
        if (!_activityChartLoading && _activitySummary.isNotEmpty) ...[
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [for (final pill in _activitySummary) _SummaryPill(pill: pill, dark: dark)],
          ),
        ],
        if (_activityChartError.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ErrorBox(message: _activityChartError, dark: dark, onRetry: _fetchActivityChartStats),
        ],
      ],
    );
  }

  static final _numberFormat = NumberFormat('#,##0.###', 'en_US');
  static String _numberLabel(num v) => _numberFormat.format(v);
}

// ═══════════════════════════════════════════════════════════════════════════
//  Widgets
// ═══════════════════════════════════════════════════════════════════════════

BoxDecoration _cardDecoration(bool dark, double radius, {bool shadowXl = false}) => BoxDecoration(
      color: dark ? _Rc.cardDark : Colors.white,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: dark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.1),
      ),
      // shadow-xl / shadow-sm (the theme's light values)
      boxShadow: shadowXl ? AppShadows.xl : AppShadows.sm,
    );

/// A KPI card (`p-6 rounded-[2rem]` with the coloured icon box).
class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, required this.hours, required this.minutes, required this.loading});
  final String label;
  final int hours;
  final int minutes;
  final bool loading;

  static const _bg = Color(0x1A4ADE80); // rgba(74,222,128,0.1)
  static const _border = Color(0x334ADE80); // rgba(74,222,128,0.2)

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final valueColor = dark ? Colors.white : Tw.gray900;
    final unit = TextStyle(fontSize: 14, color: valueColor.withValues(alpha: 0.6));
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(dark, 32),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _border),
            ),
            child: const ZoneSvgIcon(_LucidePaths.clock, size: 28, round: true, color: _Rc.green),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    height: 1.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: dark ? Colors.white.withValues(alpha: 0.4) : Tw.gray400,
                  ),
                ),
                const SizedBox(height: 2),
                if (loading)
                  const _Pulse(
                    child: SizedBox(
                      width: 96,
                      height: 28,
                      child: DecoratedBox(
                        // rounded-lg (16px in this theme) on a 28px box
                        decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.all(Radius.circular(14))),
                      ),
                    ),
                  )
                else
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(text: '$hours'),
                      TextSpan(text: 'h', style: unit),
                      TextSpan(text: ' $minutes'),
                      TextSpan(text: 'm', style: unit),
                    ]),
                    style: TextStyle(fontSize: 24, height: 1, fontWeight: FontWeight.w900, color: valueColor),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A chart card: title, description with the selected range, optional
/// control on the right, then the content.
class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.title,
    required this.descriptionLead,
    required this.descriptionRange,
    required this.descriptionTail,
    required this.children,
    this.trailing,
  });

  final String title;
  final String descriptionLead;
  final String descriptionRange;
  final String descriptionTail;
  final Widget? trailing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w900, color: dark ? Colors.white : Tw.gray900)),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(children: [
            TextSpan(text: descriptionLead),
            TextSpan(
              text: descriptionRange,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: dark ? Colors.white.withValues(alpha: 0.8) : Tw.gray700),
            ),
            TextSpan(text: descriptionTail),
          ]),
          style: TextStyle(
              fontSize: 14, height: 20 / 14, color: dark ? Colors.white.withValues(alpha: 0.5) : Tw.gray500),
        ),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: _cardDecoration(dark, 40, shadowXl: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // `flex flex-wrap justify-between items-center gap-4 mb-6`
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 16,
            children: [header, ?trailing],
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

/// The date-range dropdown (`min-w-[160px]` button + an `absolute right-0
/// mt-2 w-48` menu with a check on the selected option). Clicks outside the
/// button and menu close it (`onClickOutside`).
class _RangeDropdown extends StatefulWidget {
  const _RangeDropdown({
    required this.selectedKey,
    required this.open,
    required this.onOpenChanged,
    required this.onSelected,
  });

  final String selectedKey;
  final bool open;
  final ValueChanged<bool> onOpenChanged;
  final ValueChanged<String> onSelected;

  @override
  State<_RangeDropdown> createState() => _RangeDropdownState();
}

class _RangeDropdownState extends State<_RangeDropdown> with SingleTickerProviderStateMixin {
  final _link = LayerLink();
  final _portal = OverlayPortalController();
  final _group = Object();
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 150),
    reverseDuration: const Duration(milliseconds: 100),
    value: widget.open ? 1 : 0,
  );
  bool _hover = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _portal.show();
    });
  }

  @override
  void didUpdateWidget(_RangeDropdown old) {
    super.didUpdateWidget(old);
    if (old.open != widget.open) {
      widget.open ? _anim.forward() : _anim.reverse();
    }
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final iconColor = dark ? Colors.white.withValues(alpha: 0.4) : Tw.gray400;
    final button = MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => widget.onOpenChanged(!widget.open),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          constraints: const BoxConstraints(minWidth: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: dark
                ? Colors.white.withValues(alpha: _hover ? 0.1 : 0.05)
                : (_hover ? Tw.gray100 : Tw.gray50),
            // rounded-xl (20px in this theme)
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ZoneSvgIcon(_LucidePaths.calendarDays, size: 16, round: true, color: iconColor),
                  const SizedBox(width: 8),
                  Text(
                    reportRangeLabel(widget.selectedKey),
                    style: TextStyle(
                      fontSize: 14,
                      height: 20 / 14,
                      fontWeight: FontWeight.w700,
                      color: dark ? Colors.white.withValues(alpha: 0.7) : Tw.gray700,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              AnimatedRotation(
                turns: widget.open ? 0.5 : 0,
                duration: const Duration(milliseconds: 200),
                child: LucideIcon(Lucide.chevronDown, size: 16, color: iconColor),
              ),
            ],
          ),
        ),
      ),
    );

    return TapRegion(
      groupId: _group,
      onTapOutside: (_) {
        if (widget.open) widget.onOpenChanged(false);
      },
      child: CompositedTransformTarget(
        link: _link,
        child: OverlayPortal(controller: _portal, overlayChildBuilder: _menu, child: button),
      ),
    );
  }

  /// enter: ease-out 150ms from `opacity-0 scale-95 -translate-y-1`;
  /// leave: ease-in 100ms back to it.
  Widget _menu(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        if (_anim.value == 0 && !widget.open) return const SizedBox.shrink();
        final forward = _anim.status != AnimationStatus.reverse;
        final v = (forward ? const Cubic(0, 0, 0.2, 1) : const Cubic(0.4, 0, 1, 1)).transform(_anim.value);
        return Align(
          alignment: Alignment.topLeft,
          child: CompositedTransformFollower(
            link: _link,
            showWhenUnlinked: false,
            targetAnchor: Alignment.bottomRight,
            followerAnchor: Alignment.topRight,
            offset: const Offset(0, 8),
            child: TapRegion(
              groupId: _group,
              child: IgnorePointer(
                ignoring: !widget.open,
                child: Opacity(
                  opacity: v.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, -4 * (1 - v)),
                    child: Transform.scale(scale: 0.95 + 0.05 * v, child: _menuBox(context)),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _menuBox(BuildContext context) {
    final dark = context.isDark;
    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: 192,
        clipBehavior: Clip.antiAlias,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          color: dark ? _Rc.menuDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200),
          // shadow-2xl (the theme's value)
          boxShadow: AppShadows.xl2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final o in reportRangeOptions)
              ZonePress(
                onTap: () => widget.onSelected(o.key),
                builder: (context, hover, _) => AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  color: hover
                      ? (dark ? Colors.white.withValues(alpha: 0.05) : Tw.gray50)
                      : Colors.transparent,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      Expanded(
                        // The selected option's `text-[#6366f1] font-bold`
                        // loses to `text-gray-700` / `text-white/70` and
                        // `font-medium` in the web's CSS order, so only the
                        // check mark is indigo.
                        child: Text(
                          o.label,
                          style: TextStyle(
                            fontSize: 14,
                            height: 20 / 14,
                            fontWeight: FontWeight.w500,
                            color: dark ? Colors.white.withValues(alpha: 0.7) : Tw.gray700,
                          ),
                        ),
                      ),
                      if (widget.selectedKey == o.key)
                        const LucideIcon(Lucide.check, size: 16, color: _Rc.indigo),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// A Chart.js-style smooth line chart with a gradient fill (`tension: 0.4`,
/// `pointRadius: 4`, no legend, no x grid).
class _ReportLineChart extends StatelessWidget {
  const _ReportLineChart({
    required this.labels,
    required this.values,
    required this.color,
    required this.axis,
    required this.yLabel,
    this.includeMaxTick = false,
  });

  final List<String> labels;
  final List<double> values;
  final Color color;
  final ReportAxis axis;
  final String Function(num value) yLabel;

  /// Chart.js adds the fixed `max` as the last tick (activity chart).
  final bool includeMaxTick;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final textColor = dark ? Colors.white.withValues(alpha: 0.4) : Tw.slate500;
    final gridColor = dark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.06);
    final pointBg = dark ? _Rc.menuDark : Colors.white;
    final tickStyle = _chartFont(11, textColor);
    final n = values.length;

    // The y axis is as wide as its longest label + `ticks.padding` (3) +
    // the 8px tick marks (`grid.drawTicks`).
    final yTicks = <double>[
      if (axis.interval > 0)
        for (var v = 0.0; v <= axis.max + 1e-9; v += axis.interval) v,
      if (includeMaxTick && (axis.max / axis.interval - (axis.max / axis.interval).round()).abs() > 1e-6)
        axis.max,
    ];
    var labelWidth = 0.0;
    for (final v in yTicks) {
      final tp = TextPainter(
        text: TextSpan(text: yLabel(v), style: tickStyle),
        textDirection: TextDirection.ltr,
        textScaler: MediaQuery.textScalerOf(context),
      )..layout();
      if (tp.width > labelWidth) labelWidth = tp.width;
      tp.dispose();
    }
    final yAxisWidth = labelWidth.ceilToDouble() + 3 + 8;

    return LayoutBuilder(builder: (context, c) {
      // Chart.js auto-skips crowded x labels.
      final every = n <= 1 ? 1 : ((n * 44) / (c.maxWidth - yAxisWidth)).ceil().clamp(1, n);
      return LineChart(
        duration: const Duration(milliseconds: 400),
        LineChartData(
          minX: 0,
          maxX: n <= 1 ? 1 : (n - 1).toDouble(),
          minY: 0,
          maxY: axis.max,
          clipData: const FlClipData.all(),
          // Both axes keep Chart.js's `border` line (`defaults.borderColor`).
          borderData: FlBorderData(
            show: true,
            border: const Border(
              left: BorderSide(color: _Rc.chartBorder),
              bottom: BorderSide(color: _Rc.chartBorder),
            ),
          ),
          gridData: FlGridData(
            drawVerticalLine: false,
            horizontalInterval: axis.interval,
            getDrawingHorizontalLine: (_) => FlLine(color: gridColor, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: axis.interval,
                reservedSize: yAxisWidth,
                getTitlesWidget: (v, meta) {
                  final onStep = (v / axis.interval - (v / axis.interval).round()).abs() < 1e-6;
                  final isMax = (v - axis.max).abs() < 1e-6;
                  if (!onStep && !(includeMaxTick && isMax)) return const SizedBox.shrink();
                  return SideTitleWidget(
                    meta: meta,
                    space: 0,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(yLabel(v), style: tickStyle),
                        const SizedBox(width: 3),
                        // The grid line's 8px tick mark.
                        SizedBox(width: 8, height: 1, child: ColoredBox(color: gridColor)),
                      ],
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                // tick length (8) + padding (3) + one 11px line
                reservedSize: 26,
                getTitlesWidget: (v, meta) {
                  final i = v.round();
                  if (i < 0 || i >= labels.length || v != i.toDouble() || i % every != 0) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(meta: meta, space: 11, child: Text(labels[i], style: tickStyle));
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            // Chart.js hover: the point keeps radius 4 (border 1), no
            // vertical indicator line.
            getTouchedSpotIndicator: (bar, indexes) => [
              for (final _ in indexes)
                TouchedSpotIndicatorData(
                  const FlLine(color: Colors.transparent, strokeWidth: 0),
                  FlDotData(
                    getDotPainter: (_, _, _, _) =>
                        FlDotCirclePainter(radius: 4, color: pointBg, strokeWidth: 1, strokeColor: color),
                  ),
                ),
            ],
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => Colors.black.withValues(alpha: 0.8),
              tooltipBorderRadius: BorderRadius.circular(6),
              tooltipPadding: const EdgeInsets.all(6),
              getTooltipItems: (spots) => [
                for (final s in spots)
                  LineTooltipItem(
                    '${s.x.round() < labels.length ? labels[s.x.round()] : ''}\n',
                    _chartFont(12, Colors.white, weight: FontWeight.w700),
                    textAlign: TextAlign.left,
                    children: [
                      TextSpan(
                        text: 'Minutes Spent: ${_StudentReportsPageState._numberLabel(s.y)}',
                        style: _chartFont(12, Colors.white),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          lineBarsData: [
            if (n > 0)
              LineChartBarData(
                spots: [
                  for (var i = 0; i < n; i++)
                    values[i].isNaN ? FlSpot.nullSpot : FlSpot(i.toDouble(), values[i]),
                ],
                isCurved: true,
                curveSmoothness: 0.4,
                preventCurveOverShooting: true,
                color: color,
                barWidth: 3,
                dotData: FlDotData(
                  getDotPainter: (_, _, _, _) =>
                      FlDotCirclePainter(radius: 4, color: pointBg, strokeWidth: 2, strokeColor: color),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color.withValues(alpha: 0.35), color.withValues(alpha: 0)],
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }
}

/// The spinner shown over a chart while it loads.
class _ChartLoading extends StatelessWidget {
  const _ChartLoading({required this.color, required this.text});
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // `rounded-full border-2 border-[c] border-t-transparent animate-spin`
          ZoneRingSpinner(size: 32, stroke: 2, track: color, head: Colors.transparent),
          const SizedBox(height: 12),
          Text(text,
              style: TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w500,
                color: dark ? Colors.white.withValues(alpha: 0.4) : Tw.gray400,
              )),
        ],
      ),
    );
  }
}

/// The red error line with "Retry".
class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.message, required this.dark, required this.onRetry});
  final String message;
  final bool dark;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final fg = dark ? Tw.red400 : Tw.red500;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: dark ? Tw.red500.withValues(alpha: 0.1) : Tw.red50,
        // rounded-xl (20px in this theme)
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? Tw.red500.withValues(alpha: 0.3) : Tw.red200),
      ),
      child: Row(
        children: [
          ZoneSvgIcon(_LucidePaths.circleAlert, size: 16, round: true, color: fg),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: fg),
            ),
          ),
          const SizedBox(width: 8),
          ZonePress(
            onTap: onRetry,
            builder: (context, hover, _) => AnimatedOpacity(
              opacity: hover ? 0.7 : 1,
              duration: const Duration(milliseconds: 150),
              // underline underline-offset-2
              child: Container(
                padding: const EdgeInsets.only(bottom: 1),
                decoration: BoxDecoration(border: Border(bottom: BorderSide(color: fg))),
                child: Text(
                  'Retry',
                  style: TextStyle(fontSize: 12, height: 1, fontWeight: FontWeight.w500, color: fg),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A summary pill under the activity chart.
class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.pill, required this.dark});
  final ActivityPill pill;
  final bool dark;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: dark ? Colors.white.withValues(alpha: 0.05) : Tw.gray50,
          // rounded-xl (20px) on a 30px-high pill
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.gray200),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: Color(pill.color), shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(pill.label,
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w700,
                  color: dark ? Colors.white.withValues(alpha: 0.6) : Tw.gray500,
                )),
            const SizedBox(width: 8),
            Text(pill.value,
                style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w900,
                    color: dark ? Colors.white : Tw.gray900)),
          ],
        ),
      );
}

/// Tailwind `animate-pulse`.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
        opacity: TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.5), weight: 1),
          TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.0), weight: 1),
        ]).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut)),
        child: widget.child,
      );
}
