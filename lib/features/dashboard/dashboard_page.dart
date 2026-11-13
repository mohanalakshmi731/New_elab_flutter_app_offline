import 'dart:async';
import 'dart:math' as math;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart' show DateFormat;

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../../widgets/surface_card.dart';
import 'dashboard_data.dart';
import 'web_style.dart';

/// Port of `src/pages/DashboardPage.vue`.
///
/// The page asks for `font-[Nunito,sans-serif]` (Nunito is only loaded on the
/// web once a math/science zone page has injected the Google Fonts link);
/// the chart keeps chart.js' own default font.
class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

enum _Dataset { all, students, instructors }

const _studentsColor = Color(0xFF6E6ED6);
const _instructorsColor = Color(0xFF1D9E75);

/// Nunito with the right weight variant (google_fonts registers one family
/// per weight, so the weight must be passed in).
TextStyle _nu(double size,
        {FontWeight weight = FontWeight.w400, Color? color, double? height, double? letterSpacing}) =>
    GoogleFonts.nunito(
        fontSize: size, fontWeight: weight, color: color, height: height, letterSpacing: letterSpacing);

/// chart.js' default font (`'Helvetica Neue', 'Helvetica', 'Arial', sans-serif`).
TextStyle _chartFont(double size, {FontWeight weight = FontWeight.w400, Color? color}) => TextStyle(
      fontFamily: 'Helvetica Neue',
      fontFamilyFallback: const ['Helvetica', 'Arial'],
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: 1.2,
    );

class _DashboardPageState extends ConsumerState<DashboardPage> {
  UsageFilter _filter = UsageFilter.thisWeek;
  Object? _selectedClass;
  List<({Object id, String name})> _classes = const [];

  Map<String, num> _counts = const {};
  final List<UsagePoint> _instituteUsage = instituteStatic;
  List<UsagePoint> _instructorUsage = instructorStatic;
  List<UsagePoint> _studentUsage = const [];

  _Dataset _active = _Dataset.all;
  bool _transitioning = false;
  int _waveTick = 0;
  Color _waveColor = const Color(0x2E6E6ED6);

  /// chart.js grows the lines up from the x-axis on first render: the chart
  /// is built with zeros first and animates to the data.
  bool _chartIn = false;

  Timer? _recordUsageTimer;

  SessionState get _session => ref.read(sessionProvider);
  String get _role => _session.role;
  String? get _instituteId => _session.instituteId?.toString();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _replayChartIntro();
      _init();
    });
  }

  @override
  void dispose() {
    _recordUsageTimer?.cancel();
    super.dispose();
  }

  void _replayChartIntro() {
    if (!mounted) return;
    setState(() => _chartIn = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _chartIn = true);
    });
  }

  /// The loads are independent (each catches its own errors), so they run
  /// in parallel instead of one after another.
  Future<void> _init() async {
    if (!mounted) return;
    final loads = <Future<void>>[_loadClasses()];
    if (_role == Role.institute) loads.add(_loadCounts());
    if (_role == Role.student || _role == Role.instructor) {
      loads.add(_loadUsageByFilter());
      unawaited(_recordUsage());
      _recordUsageTimer =
          Timer.periodic(const Duration(seconds: 10), (_) => _recordUsage());
    }
    await Future.wait(loads);
  }

  // ── data ────────────────────────────────────────────────────────────────

  /// getArchitectoCounts()
  Future<void> _loadCounts() async {
    final id = _session.instituteId;
    if (id == null) return;
    try {
      final res = asMap(await ref.read(dashboardServiceProvider).getCounts(id)) ?? {};
      if (!mounted) return;
      setState(() => _counts = {
            'students': asInt(res['students_count']) ?? 0,
            'instructors': asInt(res['instructors_count']) ?? 0,
            'courses': asInt(res['courses_count']) ?? 0,
            'classes': asInt(res['classes_count']) ?? 0,
          });
    } catch (e) {
      debugPrint('Error fetching counts: $e');
    }
  }

  /// getClasses('published') — only id/name are needed for the dropdown, so
  /// the per-class count requests the web app made are skipped.
  Future<void> _loadClasses() async {
    final id = _session.instituteId;
    if (id == null) return;
    try {
      final body = await ref.read(classServiceProvider).getAllClasses(id);
      final list = unwrapList(body)
          .map(asMap)
          .whereType<Map<String, dynamic>>()
          .where((c) => c['status'] == 'published')
          .map((c) => (id: c['id'] as Object, name: asString(c['name']) ?? ''))
          .toList();
      if (mounted) setState(() => _classes = list);
    } catch (e) {
      debugPrint('Error loading classes: $e');
    }
  }

  /// individualrecordUsageAction()
  Future<void> _recordUsage() async {
    final instituteId = _instituteId;
    if (instituteId == null) return;
    try {
      await ref.read(usageTrackingServiceProvider).recordUsage({
        'institute_id': instituteId,
        'instructor_id': _session.instructorId?.toString(),
        'student_id': _session.userInfo?.studentId?.toString(),
      });
    } catch (e) {
      debugPrint('[Dashboard] recordUsage error: $e');
    }
  }

  Future<void> _loadUsageByFilter() async {
    final instituteId = _instituteId;
    if (instituteId == null) return;
    final isInstructor = _role == Role.instructor;
    final params = <String, dynamic>{'institute_id': instituteId};
    if (_filter != UsageFilter.overall) {
      final r = dateRange(_filter);
      params['from'] = r.from;
      params['to'] = r.to;
    }
    try {
      final svc = ref.read(usageTrackingServiceProvider);
      final body = isInstructor
          ? await svc.getInstructorSelfUsage(params)
          : await svc.getStudentSelfUsage(params);
      final fmt = DateFormat('MMM d', 'en_US');
      final mapped = unwrapList(body).map(asMap).whereType<Map<String, dynamic>>().map((i) {
        final period = DateTime.tryParse(asString(i['period']) ?? '');
        final minutes = convertToMinutes(asString(i['total_usage']) ?? '');
        return UsagePoint(period == null ? '' : fmt.format(period),
            total: minutes, students: minutes);
      }).toList();
      if (!mounted) return;
      final wasEmpty = (isInstructor ? _instructorUsage : _studentUsage).isEmpty;
      setState(() {
        if (isInstructor) {
          _instructorUsage = mapped;
        } else {
          _studentUsage = mapped;
        }
      });
      if (wasEmpty && mapped.isNotEmpty) _replayChartIntro();
    } catch (e) {
      debugPrint('[Usage Chart Error] $e');
      if (mounted) setState(() => _studentUsage = const []);
    }
  }

  // ── drill-down ─────────────────────────────────────────────────────────

  void _switchDataset(_Dataset key) {
    if (_transitioning) return;
    if (_active == key) {
      _resetToAll();
      return;
    }
    _animateTo(key,
        key == _Dataset.instructors ? const Color(0x331D9E75) : const Color(0x336E6ED6));
  }

  void _resetToAll() {
    if (_transitioning) return;
    _animateTo(_Dataset.all, const Color(0x24A0A0A0));
  }

  void _animateTo(_Dataset key, Color wave) {
    setState(() {
      _waveColor = wave;
      _transitioning = true;
      _waveTick++;
    });
    Future.delayed(const Duration(milliseconds: 240), () {
      if (mounted) setState(() => _active = key);
    });
    Future.delayed(const Duration(milliseconds: 520), () {
      if (mounted) setState(() => _transitioning = false);
    });
  }

  List<Person> get _activePeople {
    if (_role == Role.student) return const [];
    return switch (_active) {
      _Dataset.students => staticStudents,
      _Dataset.instructors => staticInstructors,
      _Dataset.all => const [],
    };
  }

  // ── build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.watch(sessionProvider.select((s) => s.role));
    final dark = context.isDark;
    // `p-4 pb-10` + inner `pt-3 gap-6 max-w-7xl`; `bg-[#0d0d2b] text-white`
    // in dark mode, transparent / `text-gray-900` in light mode.
    return ColoredBox(
      color: dark ? AppColors.dashboardDark : Colors.transparent,
      child: DefaultTextStyle.merge(
        style: _nu(14, color: dark ? Colors.white : Tw.gray900),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16 + 12, 16, 40),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _statCards(),
                  const SizedBox(height: 24),
                  _chartCard(),
                  const SizedBox(height: 24),
                  _bottomColumns(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// `grid grid-cols-2 lg:grid-cols-4 gap-4`
  Widget _statCards() {
    final cards = [
      _StatCard(
          icon: BootstrapIcons.people_fill,
          color: Tw.indigo600,
          darkColor: Tw.indigo400,
          sparkColor: Tw.indigo500,
          value: _counts['students'] ?? 0,
          label: 'Total Students',
          trend: '+12% this month',
          spark: const [Offset(0, 25), Offset(20, 10), Offset(40, 22), Offset(80, 5), Offset(100, 12)]),
      _StatCard(
          icon: BootstrapIcons.person_fill_check,
          color: Tw.emerald600,
          darkColor: Tw.emerald400,
          sparkColor: Tw.emerald500,
          value: _counts['instructors'] ?? 0,
          label: 'Total Instructors',
          trend: '+8% this month',
          spark: const [Offset(0, 20), Offset(20, 5), Offset(40, 15), Offset(80, 10), Offset(100, 5)]),
      _StatCard(
          icon: BootstrapIcons.book_half,
          color: Tw.pink600,
          darkColor: Tw.pink400,
          sparkColor: Tw.pink500,
          value: _counts['courses'] ?? 0,
          label: 'Total Courses',
          trend: '+15% this month',
          spark: const [Offset(0, 15), Offset(20, 25), Offset(40, 10), Offset(80, 20), Offset(100, 15)]),
      _StatCard(
          icon: BootstrapIcons.display,
          color: Tw.blue600,
          darkColor: Tw.blue400,
          sparkColor: Tw.blue500,
          value: _counts['classes'] ?? 0,
          label: 'Total Classes',
          trend: '+5% this month',
          spark: const [Offset(0, 25), Offset(20, 12), Offset(40, 20), Offset(80, 8), Offset(100, 10)]),
    ];
    return _Grid(columns: context.isLg ? 4 : 2, spacing: 16, children: cards);
  }

  Widget _chartCard() {
    final dark = context.isDark;
    final role = _role;
    final showPeople = _active != _Dataset.all && role != Role.student;

    final selects = Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: [
      if (role != Role.student)
        _SmallSelect<Object?>(
          placeholder: 'Select Class',
          value: _selectedClass,
          items: [for (final c in _classes) (value: c.id, label: c.name)],
          onChanged: (v) => setState(() => _selectedClass = v),
        ),
      _SmallSelect<UsageFilter>(
        placeholder: 'This Week',
        value: _filter,
        items: [for (final f in UsageFilter.values) (value: f, label: f.label)],
        onChanged: (v) {
          if (v == null || v == _filter) return;
          setState(() => _filter = v);
          if (role == Role.student || role == Role.instructor) _loadUsageByFilter();
        },
      ),
    ]);

    final stats = Wrap(spacing: 8, runSpacing: 8, children: [
      for (final s in _chartStats(dark)) _StatCapsule(stat: s, dark: dark),
    ]);
    final legends = Wrap(spacing: 8, runSpacing: 8, children: [
      for (final l in _legends(dark))
        _LegendChip(
          legend: l,
          dimmed: !(_active == _Dataset.all || _active == l.key),
          selected: _active == l.key,
          onTap: () => _switchDataset(l.key),
        ),
    ]);

    return SurfaceCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // `flex flex-col sm:flex-row justify-between items-start
          // sm:items-center gap-4 pb-4 border-b`
          _CardHeader(
            title: 'Usage Overview',
            bottomPadding: 16,
            trailing: selects,
            stackBelowSm: true,
          ),
          // Card `gap-6` + `mt-4`.
          const SizedBox(height: 24 + 16),
          // `flex flex-col md:flex-row md:items-center justify-between gap-4`
          if (context.isMd)
            Row(children: [
              Expanded(child: Align(alignment: Alignment.centerLeft, child: stats)),
              const SizedBox(width: 16),
              legends,
            ])
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [stats, const SizedBox(height: 16), legends],
            ),
          // `mb-2` + Card `gap-6` + chart `pt-4`.
          const SizedBox(height: 8 + 24 + 16),
          SizedBox(
            height: 320,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Stack(children: [
                Positioned.fill(child: _lineChart(dark)),
                if (_transitioning)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _WaveOverlay(key: ValueKey(_waveTick), color: _waveColor),
                    ),
                  ),
              ]),
            ),
          ),
          // `<Transition name="slide-up">` people panel.
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            reverseDuration: const Duration(milliseconds: 200),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.topCenter,
              children: [...previous, ?current],
            ),
            transitionBuilder: (child, animation) => _SlideUpTransition(animation: animation, child: child),
            child: showPeople
                ? KeyedSubtree(key: const ValueKey('people'), child: _peoplePanel(dark))
                : const SizedBox(key: ValueKey('none'), width: double.infinity),
          ),
        ],
      ),
    );
  }

  List<_Legend> _legends(bool dark) {
    const studentBg = (Color(0xFFEEEDFE), Color(0xFF22254F));
    final students = _Legend(
      key: _Dataset.students,
      label: _role == Role.institute || _role == Role.instructor ? 'Students' : 'My Usage',
      bg: dark ? studentBg.$2 : studentBg.$1,
      text: dark ? const Color(0xFFA5A5FF) : const Color(0xFF3C3489),
      dot: _studentsColor,
    );
    if (_role == Role.institute) {
      return [
        students,
        _Legend(
          key: _Dataset.instructors,
          label: 'Instructors',
          bg: dark ? const Color(0xFF132F28) : const Color(0xFFE1F5EE),
          text: dark ? const Color(0xFF2DD4BF) : const Color(0xFF085041),
          dot: _instructorsColor,
        ),
      ];
    }
    return [students];
  }

  List<_Stat> _chartStats(bool dark) {
    final violet = _Stat.palette(dark, violet: true);
    final teal = _Stat.palette(dark, teal: true);
    final grey = _Stat.palette(dark);

    String peak(List<UsagePoint> d, num Function(UsagePoint) f) =>
        d.isEmpty ? '-' : d.reduce((a, b) => f(a) > f(b) ? a : b).name;
    num sum(List<UsagePoint> d, num Function(UsagePoint) f) =>
        d.fold<num>(0, (s, p) => s + f(p));

    if (_role == Role.institute) {
      final d = _instituteUsage;
      if (_active == _Dataset.students) {
        final total = sum(d, (p) => p.students);
        return [
          violet.withValue('Students Active', '$total'),
          violet.withValue('Monthly Avg', '${(total / 12).round()}'),
          grey.withValue('Peak Month', peak(d, (p) => p.students)),
        ];
      }
      if (_active == _Dataset.instructors) {
        final total = sum(d, (p) => p.instructors);
        return [
          teal.withValue('Instructors Active', '$total'),
          teal.withValue('Monthly Avg', '${(total / 12).round()}'),
          grey.withValue('Peak Month', peak(d, (p) => p.instructors)),
        ];
      }
      return [
        violet.withValue('Students Active', '${sum(d, (p) => p.students)}'),
        teal.withValue('Instructors Active', '${sum(d, (p) => p.instructors)}'),
        grey.withValue('Peak Month', peak(d, (p) => p.students + p.instructors)),
      ];
    }
    if (_role == Role.instructor) {
      final d = _instructorUsage;
      return [
        violet.withValue('Students', '${sum(d, (p) => p.students)}'),
        grey.withValue('Peak Month', peak(d, (p) => p.students)),
      ];
    }
    return [violet.withValue('My Usage Active', '${sum(_studentUsage, (p) => p.total)}')];
  }

  Widget _lineChart(bool dark) {
    final List<UsagePoint> data;
    final List<({Color color, String label, num Function(UsagePoint) value})> series;
    if (_role == Role.instructor) {
      data = _instructorUsage;
      series = [(color: _studentsColor, label: 'Students', value: (p) => p.students)];
    } else if (_role != Role.institute) {
      data = _studentUsage;
      series = [(color: _studentsColor, label: 'My Usage', value: (p) => p.total)];
    } else {
      data = _instituteUsage;
      series = switch (_active) {
        _Dataset.students => [(color: _studentsColor, label: 'Students', value: (p) => p.students)],
        _Dataset.instructors => [
            (color: _instructorsColor, label: 'Instructors', value: (p) => p.instructors)
          ],
        _Dataset.all => [
            (color: _studentsColor, label: 'Students', value: (p) => p.students),
            (color: _instructorsColor, label: 'Instructors', value: (p) => p.instructors),
          ],
      };
    }

    // Institute drill-down datasets use bigger points and a 10% fill.
    final drilled = _role == Role.institute && _active != _Dataset.all;
    final gridColor = dark ? Colors.white.withValues(alpha: 0.08) : const Color(0x14808080);
    const axisBorder = BorderSide(color: Color(0x1A000000)); // Chart.defaults.borderColor
    final tickStyle = _chartFont(12, color: dark ? Tw.gray400 : Tw.gray600);

    var dataMax = 0.0;
    for (final p in data) {
      for (final s in series) {
        dataMax = math.max(dataMax, s.value(p).toDouble());
      }
    }
    final scale = chartJsNiceScale(dataMax);
    final stepDecimals = scale.step >= 1 ? 0 : (-(math.log(scale.step) / math.ln10).floor());
    double clean(double v) => double.parse(v.toStringAsFixed(stepDecimals));

    // y-axis width: widest tick label + tick padding (3) + tick mark (8).
    double textWidth(String s) {
      final tp = TextPainter(text: TextSpan(text: s, style: tickStyle), textDirection: TextDirection.ltr)
        ..layout();
      final w = tp.width;
      tp.dispose();
      return w;
    }
    var yLabelWidth = 0.0;
    for (var v = 0.0; v <= scale.max + scale.step / 2; v += scale.step) {
      yLabelWidth = math.max(yLabelWidth, textWidth(formatMinutes(clean(v))));
    }
    final yReserved = yLabelWidth + 11;

    return LayoutBuilder(builder: (context, c) {
      // chart.js x-label rotation (max 50°) and auto-skip.
      final n = data.length;
      final plotWidth = math.max(1.0, c.maxWidth - yReserved - 8);
      var labelW = 0.0;
      for (final p in data) {
        labelW = math.max(labelW, textWidth(p.name));
      }
      const labelH = 12 * 1.2;
      final tickWidth = n > 1 ? plotWidth / (n - 1) : plotWidth;
      var rotation = 0.0;
      if (n > 1 && labelW + 6 > tickWidth) {
        rotation = math.min(50 * math.pi / 180, math.asin(math.min(1.0, (labelH + 6) / tickWidth)));
      }
      final w = labelW + 3, h = labelH + 3;
      final cos = math.cos(rotation).abs(), sin = math.sin(rotation).abs();
      final tickSize = rotation == 0 ? w : (h * cos > w * sin ? w / cos : h / sin);
      final maxTicks = math.max(1, (plotWidth / tickSize).floor());
      final skip = n > maxTicks ? (n / maxTicks).ceil() : 1;
      final xReserved = 11 + labelW * sin + labelH * cos + 2;

      List<FlSpot> spots(num Function(UsagePoint) f) => [
            for (var i = 0; i < n; i++) FlSpot(i.toDouble(), _chartIn ? f(data[i]).toDouble() : 0),
          ];

      return LineChart(
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeInOutQuart,
        LineChartData(
          minX: 0,
          maxX: n > 1 ? (n - 1).toDouble() : 1,
          minY: 0,
          maxY: scale.max,
          clipData: const FlClipData.none(),
          borderData: FlBorderData(show: true, border: const Border(left: axisBorder, bottom: axisBorder)),
          gridData: FlGridData(
            drawVerticalLine: n > 0,
            horizontalInterval: scale.step,
            verticalInterval: 1,
            getDrawingHorizontalLine: (_) => FlLine(color: gridColor, strokeWidth: 1),
            getDrawingVerticalLine: (_) => FlLine(color: gridColor, strokeWidth: 1),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: scale.step,
                reservedSize: yReserved,
                getTitlesWidget: (v, meta) => SideTitleWidget(
                  meta: meta,
                  space: 11,
                  child: Text(formatMinutes(clean(v)), style: tickStyle, textAlign: TextAlign.right),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: n > 0,
                interval: 1,
                reservedSize: xReserved,
                getTitlesWidget: (v, meta) {
                  final i = v.round();
                  if (i < 0 || i >= n || v != i.toDouble() || i % skip != 0) {
                    return const SizedBox.shrink();
                  }
                  return SideTitleWidget(
                    meta: meta,
                    space: 11,
                    angle: -rotation,
                    child: Text(data[i].name, style: tickStyle),
                  );
                },
              ),
            ),
          ),
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            // `interaction: { mode: 'index', intersect: false }`
            touchSpotThreshold: double.infinity,
            mouseCursorResolver: (event, response) =>
                _role == Role.institute && (response?.lineBarSpots?.isNotEmpty ?? false)
                    ? SystemMouseCursors.click
                    : SystemMouseCursors.basic,
            getTouchedSpotIndicator: (bar, indexes) => [
              for (final _ in indexes)
                TouchedSpotIndicatorData(
                  const FlLine(color: Colors.transparent, strokeWidth: 0),
                  FlDotData(
                    getDotPainter: (_, _, b, _) => FlDotCirclePainter(
                      radius: drilled ? 9 : 7, // pointHoverRadius
                      color: Color.lerp(b.color, Colors.black, 0.1)!,
                      strokeWidth: 1,
                      strokeColor: b.color ?? _studentsColor,
                    ),
                  ),
                ),
            ],
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => const Color(0xE00F0F1E), // rgba(15,15,30,.88)
              tooltipBorderRadius: BorderRadius.circular(8),
              tooltipPadding: const EdgeInsets.all(12),
              maxContentWidth: 220,
              fitInsideHorizontally: true,
              fitInsideVertically: true,
              getTooltipItems: (spots) => [
                for (final (k, s) in spots.indexed)
                  LineTooltipItem(
                    k == 0 && s.x.round() < n ? '${data[s.x.round()].name}\n' : '',
                    _chartFont(12, weight: FontWeight.w700, color: Colors.white),
                    textAlign: TextAlign.left,
                    children: [
                      if (k == 0) TextSpan(text: '\n', style: _chartFont(6)),
                      TextSpan(text: '■ ', style: _chartFont(12, color: s.bar.color)),
                      TextSpan(
                        text: '${s.barIndex < series.length ? series[s.barIndex].label : ''}: '
                            '${s.barIndex < series.length && s.x.round() < n ? series[s.barIndex].value(data[s.x.round()]) : s.y}',
                        style: _chartFont(12, color: Colors.white.withValues(alpha: 0.75)),
                      ),
                    ],
                  ),
              ],
            ),
            touchCallback: (event, response) {
              if (_role != Role.institute || _active != _Dataset.all) return;
              if (event is FlTapUpEvent && (response?.lineBarSpots?.isNotEmpty ?? false)) {
                // elems[0] is always dataset 0 in index mode → "students".
                final idx = response!.lineBarSpots!.first.barIndex;
                _switchDataset(idx == 0 ? _Dataset.students : _Dataset.instructors);
              }
            },
          ),
          lineBarsData: [
            if (n > 0)
              for (final s in series)
              LineChartBarData(
                spots: spots(s.value),
                isCurved: true,
                curveSmoothness: 0.4, // tension 0.4
                color: s.color,
                barWidth: 2.5,
                dotData: FlDotData(
                  getDotPainter: (_, _, _, _) => FlDotCirclePainter(
                      radius: drilled ? 5 : 4, color: s.color, strokeWidth: 1, strokeColor: s.color),
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: s.color.withValues(alpha: drilled ? 0.10 : 0.08),
                ),
              ),
          ],
        ),
      );
    });
  }

  /// Named people list shown after drill-in (`px-5 pb-5 pt-4 border-t`).
  Widget _peoplePanel(bool dark) {
    final isStudents = _active == _Dataset.students;
    final people = _activePeople;
    final maxScore =
        people.isEmpty ? 1 : people.map((p) => p.score).reduce((a, b) => a > b ? a : b);
    final accent = isStudents ? _studentsColor : _instructorsColor;
    // `grid-cols-1 xs:grid-cols-2 sm:grid-cols-3 lg:grid-cols-4` — `xs` is
    // not a Tailwind 4 breakpoint here, so phones get one column.
    final cols = context.isLg ? 4 : context.isSm ? 3 : 1;

    return Container(
      margin: const EdgeInsets.only(top: 24), // Card `gap-6`
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.sky100.withValues(alpha: 0.5))),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
              width: 10, height: 10, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Flexible(
            child: Text('${isStudents ? 'Students' : 'Instructors'} — Individual Overview',
                style: _nu(14, weight: FontWeight.w600, height: TwLeading.sm, color: context.colors.primary)),
          ),
        ]),
        const SizedBox(height: 12),
        _Grid(
          columns: cols,
          spacing: 12,
          children: [
            for (final p in people)
              _PersonCard(person: p, isStudents: isStudents, dark: dark, maxScore: maxScore),
          ],
        ),
      ]),
    );
  }

  /// `grid grid-cols-1 lg:grid-cols-2 gap-6` — Recent Activities + Top
  /// Classes (static content on the web).
  Widget _bottomColumns() {
    final dark = context.isDark;
    Widget card(String title, VoidCallback onViewAll, List<Widget> rows) => SurfaceCard(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _CardHeader(title: title, bottomPadding: 12, trailing: _ViewAll(onTap: onViewAll)),
            const SizedBox(height: 16),
            for (final (i, r) in rows.indexed) ...[if (i > 0) const SizedBox(height: 16), r],
          ]),
        );

    final recent = card('Recent Activities', () => context.go('/useractivitylog'), const [
      _ActivityRow(
          icon: BootstrapIcons.book_half,
          color: Tw.blue500,
          title: 'New course "Physics Fundamentals" created',
          meta: 'By John Doe · 2h ago'),
      _ActivityRow(
          icon: BootstrapIcons.person_fill_check,
          color: Tw.emerald500,
          title: 'Instructor Sarah Wilson added to Class 7B',
          meta: 'By Admin · 5h ago'),
      _ActivityRow(
          icon: BootstrapIcons.calendar3,
          color: Tw.pink500,
          title: 'Class 8A schedule updated',
          meta: 'By Admin · 1d ago'),
    ]);
    final top = card('Top Classes', () => context.go('/classlist'), [
      _TopClassRow(name: 'Class 7B', students: 32, grade: 'Grade 7', fraction: 0.70, dark: dark),
      _TopClassRow(name: 'Class 8A', students: 30, grade: 'Grade 8', fraction: 0.65, dark: dark),
      _TopClassRow(name: 'Class 9C', students: 25, grade: 'Grade 9', fraction: 0.55, dark: dark),
    ]);
    return _Grid(columns: context.isLg ? 2 : 1, spacing: 24, children: [recent, top]);
  }
}

// ── small widgets ─────────────────────────────────────────────────────────

/// Card header row: bold `text-lg` title + trailing, `border-b
/// border-slate-50 dark:border-slate-800/80`. With [stackBelowSm] the
/// trailing goes under the title below 640 px (`flex-col sm:flex-row gap-4`).
class _CardHeader extends StatelessWidget {
  const _CardHeader({
    required this.title,
    required this.bottomPadding,
    required this.trailing,
    this.stackBelowSm = false,
  });
  final String title;
  final double bottomPadding;
  final Widget trailing;
  final bool stackBelowSm;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final heading = Text(title,
        style: _nu(18, weight: FontWeight.w700, height: TwLeading.lg, color: dark ? Colors.white : Tw.slate800));
    return Container(
      padding: EdgeInsets.only(bottom: bottomPadding),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate50)),
      ),
      child: stackBelowSm && !context.isSm
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [heading, const SizedBox(height: 16), trailing],
            )
          : Row(children: [
              Expanded(child: heading),
              const SizedBox(width: 16),
              trailing,
            ]),
    );
  }
}

/// Simple responsive grid (rows of equal-width cells, stretched to the row
/// height like CSS grid).
class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.spacing, required this.children});
  final int columns;
  final double spacing;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      final cells = <Widget>[];
      for (var j = 0; j < columns; j++) {
        if (j > 0) cells.add(SizedBox(width: spacing));
        final idx = i + j;
        cells.add(Expanded(child: idx < children.length ? children[idx] : const SizedBox()));
      }
      if (rows.isNotEmpty) rows.add(SizedBox(height: spacing));
      rows.add(IntrinsicHeight(
        child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }
}

/// Stat card. The shadcn Card's `flex-col` survives tailwind-merge, so the
/// icon + numbers group and the sparkline are stacked and centred
/// (`items-center justify-between gap-6`).
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.color,
    required this.darkColor,
    required this.sparkColor,
    required this.value,
    required this.label,
    required this.trend,
    required this.spark,
  });

  final IconData icon;
  final Color color;
  final Color darkColor;
  final Color sparkColor;
  final num value;
  final String label;
  final String trend;

  /// M p0 Q p1 p2 T p3 T p4 (the web inline SVG sparkline).
  final List<Offset> spark;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    // Phones: the web lets the row overflow the card; here the texts
    // ellipsize instead.
    final group = Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, size: 24, color: dark ? darkColor : color),
      ),
      const SizedBox(width: 16),
      Flexible(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('$value',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _nu(24, weight: FontWeight.w700, height: TwLeading.x2l, color: dark ? Colors.white : Tw.slate800)),
          const SizedBox(height: 2),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _nu(12, weight: FontWeight.w600, height: TwLeading.xs, color: dark ? Tw.slate500 : Tw.slate400)),
          const SizedBox(height: 4),
          SizedBox(
            height: 20,
            child: Row(children: [
              const Icon(BootstrapIcons.arrow_up_short, size: 14, color: Tw.emerald500),
              const SizedBox(width: 2),
              Flexible(
                child: Text(trend,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _nu(10, weight: FontWeight.w700, color: Tw.emerald500)),
              ),
            ]),
          ),
        ]),
      ),
    ]);

    return SurfaceCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          group,
          if (context.isSm) ...[
            const SizedBox(height: 24),
            SizedBox(
              width: 64,
              height: 32,
              child: CustomPaint(painter: _SparklinePainter(spark, sparkColor)),
            ),
          ],
        ],
      ),
    );
  }
}

/// The 100×30 `viewBox` scaled into 64×32 (`preserveAspectRatio` meet:
/// uniform 0.64, centred vertically; stroke 2.5 scales with it).
class _SparklinePainter extends CustomPainter {
  _SparklinePainter(this.pts, this.color);
  final List<Offset> pts;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final k = math.min(size.width / 100, size.height / 30);
    final dx = (size.width - 100 * k) / 2, dy = (size.height - 30 * k) / 2;
    Offset s(Offset o) => Offset(dx + o.dx * k, dy + o.dy * k);
    final path = Path()..moveTo(s(pts[0]).dx, s(pts[0]).dy);
    var ctrl = pts[1];
    var end = pts[2];
    path.quadraticBezierTo(s(ctrl).dx, s(ctrl).dy, s(end).dx, s(end).dy);
    for (var i = 3; i < pts.length; i++) {
      ctrl = end * 2 - ctrl; // SVG "T": reflect the previous control point
      end = pts[i];
      path.quadraticBezierTo(s(ctrl).dx, s(ctrl).dy, s(end).dx, s(end).dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5 * k
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter old) => old.color != color;
}

/// shadcn `<Select>` with `<SelectTrigger class="h-9 rounded-xl text-xs">`
/// (the trigger is `w-fit`; the `w-full sm:w-36` on `<Select>` is dropped
/// because SelectRoot renders no element).
class _SmallSelect<T> extends StatefulWidget {
  const _SmallSelect({
    required this.placeholder,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String placeholder;
  final T? value;
  final List<({T value, String label})> items;
  final ValueChanged<T?> onChanged;

  @override
  State<_SmallSelect<T>> createState() => _SmallSelectState<T>();
}

class _SmallSelectState<T> extends State<_SmallSelect<T>> {
  final _menu = MenuController();
  final _triggerKey = GlobalKey();
  bool _hover = false;
  double _triggerWidth = 128;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    String? selected;
    for (final i in widget.items) {
      if (i.value == widget.value) selected = i.label;
    }
    final fg = dark ? WebColors.foregroundDark : WebColors.foreground;
    final muted = dark ? WebColors.mutedForegroundDark : WebColors.mutedForeground;
    final border = dark ? WebColors.inputDark : WebColors.input;

    return MenuAnchor(
      controller: _menu,
      alignmentOffset: const Offset(0, 4),
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(dark ? WebColors.popoverDark : Colors.white),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        // `shadow-md`
        shadowColor: const WidgetStatePropertyAll(Color(0x66000000)),
        elevation: const WidgetStatePropertyAll(2),
        padding: const WidgetStatePropertyAll(EdgeInsets.all(4)),
        minimumSize: WidgetStatePropertyAll(Size(math.max(128, _triggerWidth), 0)),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: border),
        )),
      ),
      menuChildren: [
        for (final i in widget.items)
          _SelectItem(
            label: i.label,
            selected: i.value == widget.value,
            dark: dark,
            onTap: () {
              _menu.close();
              widget.onChanged(i.value);
            },
          ),
      ],
      builder: (context, controller, _) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: () {
            final box = _triggerKey.currentContext?.findRenderObject() as RenderBox?;
            if (box != null) setState(() => _triggerWidth = box.size.width);
            controller.isOpen ? controller.close() : controller.open();
          },
          child: Container(
            key: _triggerKey,
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: dark ? WebColors.inputDark.withValues(alpha: _hover ? 0.5 : 0.3) : Colors.transparent,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
              boxShadow: WebShadow.xs,
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Flexible(
                child: Text(selected ?? widget.placeholder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: _nu(12, height: TwLeading.xs, color: selected == null ? WebColors.placeholder : fg)),
              ),
              const SizedBox(width: 8),
              Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: muted.withValues(alpha: 0.5)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// `<SelectItem>`: `py-1.5 pr-8 pl-2 text-sm rounded-sm`, highlighted with
/// `bg-accent text-accent-foreground`, check mark on the selected one.
class _SelectItem extends StatefulWidget {
  const _SelectItem({required this.label, required this.selected, required this.dark, required this.onTap});
  final String label;
  final bool selected;
  final bool dark;
  final VoidCallback onTap;

  @override
  State<_SelectItem> createState() => _SelectItemState();
}

class _SelectItemState extends State<_SelectItem> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final fg = _hover
        ? WebColors.accentForeground
        : (widget.dark ? WebColors.foregroundDark : WebColors.foreground);
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(8, 6, 32, 6),
          decoration: BoxDecoration(
            color: _hover ? WebColors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(clipBehavior: Clip.none, children: [
            Text(widget.label, style: _nu(14, height: TwLeading.sm, color: fg)),
            if (widget.selected)
              Positioned(
                right: -24,
                top: 2,
                child: Icon(Icons.check_rounded, size: 16, color: fg),
              ),
          ]),
        ),
      ),
    );
  }
}

class _Stat {
  const _Stat(this.label, this.value, this.bg, this.dot, this.valueColor);
  final String label;
  final String value;
  final Color bg;
  final Color dot;
  final Color valueColor;

  static _Stat palette(bool dark, {bool violet = false, bool teal = false}) {
    if (violet) {
      return _Stat('', '', dark ? const Color(0xFF22254F) : const Color(0xFFEEEDFE),
          _studentsColor, dark ? const Color(0xFFA5A5FF) : const Color(0xFF3C3489));
    }
    if (teal) {
      return _Stat('', '', dark ? const Color(0xFF132F28) : const Color(0xFFE1F5EE),
          _instructorsColor, dark ? const Color(0xFF2DD4BF) : const Color(0xFF085041));
    }
    return _Stat(
        '',
        '',
        dark ? const Color(0xFF2A2B36) : const Color(0xFFF1EFE8),
        dark ? const Color(0xFF55545C) : const Color(0xFF888780),
        dark ? const Color(0xFFE2E2E5) : const Color(0xFF2C2C2A));
  }

  _Stat withValue(String label, String value) => _Stat(label, value, bg, dot, valueColor);
}

/// `flex items-center gap-2 px-4 py-2 rounded-full text-xs font-bold border`
class _StatCapsule extends StatelessWidget {
  const _StatCapsule({required this.stat, required this.dark});
  final _Stat stat;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: stat.bg,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
            color: dark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 8, height: 8, decoration: BoxDecoration(color: stat.dot, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Text(stat.value,
            style: _nu(14, weight: FontWeight.w800, height: TwLeading.sm, color: stat.valueColor)),
        const SizedBox(width: 8),
        Text(stat.label,
            style: _nu(12,
                weight: FontWeight.w600, height: TwLeading.xs, color: stat.valueColor.withValues(alpha: 0.8))),
      ]),
    );
  }
}

class _Legend {
  const _Legend(
      {required this.key,
      required this.label,
      required this.bg,
      required this.text,
      required this.dot});
  final _Dataset key;
  final String label;
  final Color bg;
  final Color text;
  final Color dot;
}

/// `flex items-center gap-1.5 px-3.5 py-1.5 rounded-full text-xs font-bold
/// cursor-pointer transition-all duration-200`
class _LegendChip extends StatelessWidget {
  const _LegendChip(
      {required this.legend, required this.dimmed, required this.selected, required this.onTap});
  final _Legend legend;
  final bool dimmed;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedScale(
          scale: selected ? 1.05 : 1,
          duration: const Duration(milliseconds: 200),
          child: AnimatedOpacity(
            opacity: dimmed ? 0.35 : 1,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                  color: legend.bg, borderRadius: BorderRadius.circular(999)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(color: legend.dot, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(legend.label,
                    style: _nu(12, weight: FontWeight.w700, height: TwLeading.xs, color: legend.text)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// `.chart-wave-overlay`: a coloured ellipse growing from the bottom centre
/// (`clip-path: ellipse(… at 50% 110%)`) and fading out, 0.52 s.
class _WaveOverlay extends StatefulWidget {
  const _WaveOverlay({super.key, required this.color});
  final Color color;

  @override
  State<_WaveOverlay> createState() => _WaveOverlayState();
}

class _WaveOverlayState extends State<_WaveOverlay> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 520))..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => CustomPaint(painter: _WavePainter(_c.value, widget.color)),
      );
}

class _WavePainter extends CustomPainter {
  _WavePainter(this.t, this.color);
  final double t;
  final Color color;

  // keyframe: (offset, opacity, rx %, ry %)
  static const _frames = [(0.0, 0.0, 0.0, 0.0), (0.35, 1.0, 1.3, 0.75), (0.6, 1.0, 1.6, 1.3), (1.0, 0.0, 1.8, 1.8)];
  static const _ease = Cubic(0.22, 1, 0.36, 1);

  @override
  void paint(Canvas canvas, Size size) {
    var i = 0;
    while (i < _frames.length - 2 && t > _frames[i + 1].$1) {
      i++;
    }
    final a = _frames[i], b = _frames[i + 1];
    final u = _ease.transform(((t - a.$1) / (b.$1 - a.$1)).clamp(0.0, 1.0));
    double lerp(double x, double y) => x + (y - x) * u;
    final opacity = lerp(a.$2, b.$2);
    final rx = lerp(a.$3, b.$3) * size.width, ry = lerp(a.$4, b.$4) * size.height;
    canvas.drawOval(
      Rect.fromCenter(center: Offset(size.width / 2, size.height * 1.1), width: rx * 2, height: ry * 2),
      Paint()..color = color.withValues(alpha: color.a * opacity),
    );
  }

  @override
  bool shouldRepaint(covariant _WavePainter old) => old.t != t || old.color != color;
}

/// `slide-up` transition: enter fades in from 16 px below (0.35 s, overshoot
/// curve), leave fades out moving 8 px down (0.2 s).
class _SlideUpTransition extends StatelessWidget {
  const _SlideUpTransition({required this.animation, required this.child});
  final Animation<double> animation;
  final Widget child;

  static const _enter = Cubic(0.34, 1.3, 0.64, 1);

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation,
        child: child,
        builder: (context, child) {
          final entering = animation.status == AnimationStatus.forward ||
              animation.status == AnimationStatus.completed;
          final v = animation.value;
          final dy = entering ? 16 * (1 - _enter.transform(v)) : 8 * (1 - Curves.ease.transform(v));
          final opacity = Curves.ease.transform(v).clamp(0.0, 1.0);
          return Opacity(
            opacity: opacity,
            child: Transform.translate(offset: Offset(0, dy), child: child),
          );
        },
      );
}

class _PersonCard extends StatefulWidget {
  const _PersonCard(
      {required this.person, required this.isStudents, required this.dark, required this.maxScore});
  final Person person;
  final bool isStudents;
  final bool dark;
  final int maxScore;

  @override
  State<_PersonCard> createState() => _PersonCardState();
}

class _PersonCardState extends State<_PersonCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final isStudents = widget.isStudents;
    final person = widget.person;
    final accent = isStudents ? _studentsColor : _instructorsColor;
    final bg = dark
        ? (isStudents ? const Color(0xFF181D30) : const Color(0xFF112220))
        : (isStudents ? const Color(0xFFFAFAFE) : const Color(0xFFF5FDFB));
    final avatarBg = dark
        ? (isStudents ? const Color(0xFF22254F) : const Color(0xFF132F28))
        : (isStudents ? const Color(0xFFEEEDFE) : const Color(0xFFE1F5EE));
    final avatarFg = dark
        ? (isStudents ? const Color(0xFF9A9AFF) : const Color(0xFF2DD4BF))
        : (isStudents ? const Color(0xFF534AB7) : const Color(0xFF0F6E56));
    final muted = dark ? WebColors.mutedForegroundDark : WebColors.mutedForeground;
    final primary = context.colors.primary;

    // `rounded-xl p-3 border hover:shadow-sm`, `.person-card:hover
    // { transform: translateY(-2px) }`, `transition-all duration-200`.
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, _hover ? -2 : 0, 0),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.sky100.withValues(alpha: 0.5)),
          boxShadow: _hover ? WebShadow.sm : const [],
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: avatarBg, shape: BoxShape.circle),
            child: Text(initials(person.name),
                style: _nu(14, weight: FontWeight.w700, height: TwLeading.sm, color: avatarFg)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(person.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _nu(14, weight: FontWeight.w500, height: TwLeading.sm, color: primary)),
              Text(person.sub,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _nu(11, height: TwLeading.inherit, color: muted)),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 6,
                      color: dark ? Tw.gray800 : Tw.gray100,
                      alignment: Alignment.centerLeft,
                      child: AnimatedFractionallySizedBox(
                        duration: const Duration(milliseconds: 700),
                        widthFactor: (person.score / widget.maxScore * 100).round() / 100,
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(999)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Text('${person.score}',
                    style: _nu(10, weight: FontWeight.w500, height: TwLeading.inherit, color: avatarFg)),
              ]),
              const SizedBox(height: 6),
              // An inline badge: its line box is the 24 px body strut.
              SizedBox(
                height: 24,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                        color: badgeBg(person.badge), borderRadius: BorderRadius.circular(999)),
                    child: Text(person.badge,
                        style: _nu(10, weight: FontWeight.w500, height: 1.3, color: badgeText(person.badge))),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// `text-xs font-bold text-indigo-600 dark:text-indigo-400 hover:underline`
class _ViewAll extends StatefulWidget {
  const _ViewAll({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_ViewAll> createState() => _ViewAllState();
}

class _ViewAllState extends State<_ViewAll> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final color = context.isDark ? Tw.indigo400 : Tw.indigo600;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Text('View All →',
            style: _nu(12, weight: FontWeight.w700, height: TwLeading.xs, color: color).copyWith(
              decoration: _hover ? TextDecoration.underline : null,
              decorationColor: color,
            )),
      ),
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow(
      {required this.icon, required this.color, required this.title, required this.meta});
  final IconData icon;
  final Color color;
  final String title;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)), // rounded-xl
        child: Icon(icon, size: 18, color: color),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: _nu(14, weight: FontWeight.w700, height: 1.25, color: dark ? Colors.white : Tw.slate800)),
          const SizedBox(height: 4),
          Text(meta,
              style: _nu(12, weight: FontWeight.w600, height: TwLeading.xs, color: dark ? Tw.slate500 : Tw.slate400)),
        ]),
      ),
    ]);
  }
}

class _TopClassRow extends StatelessWidget {
  const _TopClassRow(
      {required this.name,
      required this.students,
      required this.grade,
      required this.fraction,
      required this.dark});
  final String name;
  final int students;
  final String grade;
  final double fraction;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(
          child: Text(name,
              style: _nu(14, weight: FontWeight.w700, height: TwLeading.sm, color: dark ? Colors.white : Tw.slate800)),
        ),
        Text('$students Students',
            style: _nu(12, weight: FontWeight.w700, height: TwLeading.xs, color: dark ? Tw.indigo400 : Tw.indigo600)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 8,
          color: dark ? Tw.slate800 : Tw.slate100,
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: fraction,
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Tw.indigo600, borderRadius: BorderRadius.circular(999)),
            ),
          ),
        ),
      ),
      const SizedBox(height: 4),
      Text(grade,
          style: _nu(10, weight: FontWeight.w700, height: TwLeading.inherit, color: dark ? Tw.slate500 : Tw.slate400)),
    ]);
  }
}
