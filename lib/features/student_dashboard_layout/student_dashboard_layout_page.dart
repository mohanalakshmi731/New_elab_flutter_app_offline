import 'dart:async';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../dashboard/web_style.dart';
import '../exams/exams_controller.dart';
import '../teacher_dashboard/teacher_dashboard_controller.dart';
import '../teacher_dashboard/teacher_dashboard_logic.dart';
import '../teacher_dashboard/teachers_dashboard_widgets.dart'
    show BannerChip, DashedBorderPainter, HoverBuilder, LearningCardsRow, MetricCard, PulseDot, ScheduleBannerCard, TdTw, blackHeading;
import 'student_dashboard_layout_logic.dart';

/// Where "JOIN NOW" / "View All" / "Show All Schedules" go. The web pushes
/// `/newlayout/teacherschedules`, a route that exists in neither router
/// (blank page); the student schedules screen of the eLabs app is
/// `/schedules`.
const studentLayoutSchedulesRoute = '/schedules';

/// Where the exam cards / "View All" go. The web pushes `/newlayout/newexams`
/// (no such route); the eLabs exams screen is `/newexams`.
const studentLayoutExamsRoute = '/newexams';

/// Port of
/// `src/components/new_ui_student_teacher_for_both_labs/studentdashbaordlayout.vue`
/// (`/studentdashboardlayout`, inside the eLabs DashboardShell). A plain
/// page — it has no `<router-view>`.
///
/// Live/next-class banner (ongoing → today → none, refreshed every 30 s),
/// two metric cards (the "Total Students" one is static, as on the web),
/// "Available Exams" while a class is live, and the static "Teacher
/// Learning" cards.
///
/// [schedulesRoute] / [examsRoute]: where the schedule and exam buttons go
/// (see [studentLayoutSchedulesRoute]); configurable because the MathZoro
/// layout's student nav also links to `/newlayout/studentdashboardlayout`.
class StudentDashboardLayoutPage extends ConsumerStatefulWidget {
  const StudentDashboardLayoutPage({
    super.key,
    this.schedulesRoute = studentLayoutSchedulesRoute,
    this.examsRoute = studentLayoutExamsRoute,
  });

  final String schedulesRoute;
  final String examsRoute;

  @override
  ConsumerState<StudentDashboardLayoutPage> createState() => _StudentDashboardLayoutPageState();
}

class _StudentDashboardLayoutPageState extends ConsumerState<StudentDashboardLayoutPage> {
  // Schedule banner
  bool _bannerLoading = false;
  List<dynamic> _ongoingSchedules = const [];
  List<dynamic> _todaySchedules = const [];
  Timer? _refreshInterval;
  // Available exams
  bool _examsLoading = false;
  List<dynamic> _allExams = const [];
  List<dynamic> _studentAttempts = const [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      _fetchBannerSchedules(showLoader: true);
      _fetchAvailableExams();
    });
    _refreshInterval = Timer.periodic(const Duration(seconds: 30), (_) => _fetchBannerSchedules());
  }

  @override
  void dispose() {
    _refreshInterval?.cancel();
    super.dispose();
  }

  // ── computed ────────────────────────────────────────────────────────────

  String get _bannerStatus => bannerStatusOf(_ongoingSchedules, _todaySchedules);
  Map<String, dynamic>? get _activeSchedule =>
      _ongoingSchedules.isEmpty ? null : _ongoingSchedules.first as Map<String, dynamic>?;
  Map<String, dynamic>? get _todaySchedule =>
      _todaySchedules.isEmpty ? null : _todaySchedules.first as Map<String, dynamic>?;

  // ── data ────────────────────────────────────────────────────────────────

  /// `fetchBannerSchedules(showLoader)`
  Future<void> _fetchBannerSchedules({bool showLoader = false}) async {
    if (showLoader) setState(() => _bannerLoading = true);
    final ctrl = ref.read(teacherDashboardControllerProvider.notifier);
    try {
      final ongoingRes = await ctrl.getNextSchedules();
      if (!mounted) return;
      setState(() => _ongoingSchedules = _maps(ongoingFromResponse(ongoingRes)));

      // The store action returns nothing, so this list stays empty (as on
      // the web).
      final today = todayIso();
      final todayRes = await ctrl.getSchedules({'start_date': today, 'end_date': today});
      if (!mounted) return;
      setState(() => _todaySchedules = _maps(todayFromResponse(todayRes)));
    } catch (_) {
      // "Dashboard banner fetch error" — console only on the web.
    } finally {
      if (mounted) setState(() => _bannerLoading = false);
    }
  }

  /// `fetchAvailableExams()`
  Future<void> _fetchAvailableExams() async {
    setState(() => _examsLoading = true);
    final ctrl = ref.read(examsControllerProvider.notifier);
    try {
      final res = await ctrl.fetchExams();
      if (!mounted) return;
      setState(() => _allExams = examArrayOf(res));
      // the student's own attempts (no exam id = all)
      final aRes = await ctrl.fetchExamAttempts();
      if (!mounted) return;
      setState(() => _studentAttempts = examArrayOf(aRes));
    } catch (_) {
      if (mounted) {
        setState(() {
          _allExams = const [];
          _studentAttempts = const [];
        });
      }
    } finally {
      if (mounted) setState(() => _examsLoading = false);
    }
  }

  static List<dynamic> _maps(List<dynamic> list) =>
      [for (final e in list) if (e is Map) Map<String, dynamic>.from(e)];

  // ── navigation ──────────────────────────────────────────────────────────

  /// `handleStart(id)` emits `start` + `navigate`, which nothing listens to
  /// when the page is a route — a no-op, as on the web.
  void _handleStart(Object? scheduleId) {}

  void _goToSchedules() => context.go(widget.schedulesRoute);
  void _goToExams() => context.go(widget.examsRoute);

  // ── template ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final lg = context.isLg;
    // `p-3 … max-w-7xl mx-auto` (the max width includes the padding).
    return SingleChildScrollView(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1280),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _topRow(context),
                SizedBox(height: lg ? 32 : 24),
                _bottomRow(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // TOP ROW: Banner + Metric Cards
  Widget _topRow(BuildContext context) {
    final dark = context.isDark;
    final banner = _banner(context);
    final showAll = _ShowAllButton(onPressed: _goToSchedules);

    Widget caption(String text, {required Color color, IconData? icon}) => Row(
          children: [
            if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
            Flexible(
              child: Text(text,
                  style: TextStyle(
                      fontSize: context.isMd ? 12 : 10,
                      height: context.isMd ? TwLeading.xs : TwLeading.inherit,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ),
          ],
        );

    final totalStudents = MetricCard(
      label: 'Total Students',
      icon: BootstrapIcons.people_fill,
      iconColor: Tw.emerald400,
      iconBg: Tw.emerald500.withValues(alpha: 0.2),
      hoverBorder: Tw.emerald500.withValues(alpha: 0.5),
      value: '128',
      caption: caption('95% Active this week',
          color: dark ? Tw.emerald400 : Tw.emerald500, icon: BootstrapIcons.graph_up_arrow),
    );
    final todayClasses = MetricCard(
      label: "Today's Classes",
      icon: BootstrapIcons.calendar3,
      iconColor: TdTw.purple400,
      iconBg: Tw.purple500.withValues(alpha: 0.2),
      hoverBorder: Tw.purple500.withValues(alpha: 0.5),
      value: '${_todaySchedules.length}',
      caption: caption(todayClassesCaption(_todaySchedules.length), color: dark ? Tw.slate400 : Tw.slate500),
    );

    if (!context.isLg) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          banner,
          const SizedBox(height: 12),
          showAll,
          const SizedBox(height: 24),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: totalStudents),
                const SizedBox(width: 16),
                Expanded(child: todayClasses),
              ],
            ),
          ),
        ],
      );
    }

    // `grid-cols-3 gap-6`, banner `col-span-2`; both columns stretch to the
    // row height.
    return LayoutBuilder(builder: (context, c) {
      final col = (c.maxWidth - 48) / 3;
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: col * 2 + 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                // The banner cards are `flex-grow`; the skeleton is not.
                children: [
                  if (_bannerLoading) banner else Expanded(child: banner),
                  const SizedBox(height: 12),
                  showAll,
                ],
              ),
            ),
            const SizedBox(width: 24),
            SizedBox(
              width: col,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: totalStudents),
                  const SizedBox(height: 16),
                  Expanded(child: todayClasses),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _banner(BuildContext context) {
    if (_bannerLoading) return const _BannerSkeleton();

    final status = _bannerStatus;
    final active = _activeSchedule;
    // The unregistered `<Badge>` renders as a plain element with its classes
    // (no backdrop blur / shadow, `text-[10px]` at every width).
    if (status == 'ongoing' && active != null) {
      return ScheduleBannerCard(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF059669), Color(0xFF0284C7), Color(0xFF4F46E5)],
          stops: [0, 0.55, 1],
        ),
        // `shadow-xl shadow-emerald-900/30` → the plain style.css shadow-xl.
        shadow: WebShadow.xl,
        glowColor: Tw.emerald400.withValues(alpha: 0.2),
        chip: BannerChip(
          leading: const PulseDot(color: TdTw.emerald300),
          text: 'LIVE NOW • ${active['start_time'] ?? ''}',
          frosted: false,
          mdLarger: false,
        ),
        title: scheduleTitle(active, 'Live Class'),
        batchName: scheduleBatchName(active),
        className: scheduleClassName(active),
        subtitleColor: Tw.emerald100,
        buttonLabel: 'JOIN NOW',
        buttonTextColor: TdTw.emerald800,
        buttonHoverColor: Tw.emerald50,
        circleGap: 12,
        titleLetterSpacing: -0.025, // tracking-tight
        onPressed: _goToSchedules,
      );
    }

    final today = _todaySchedule;
    if (status == 'today' && today != null) {
      return ScheduleBannerCard(
        gradient: const LinearGradient(colors: [TdTw.cyan600, Tw.blue600]),
        shadow: WebShadow.xl,
        glowColor: TdTw.cyan400.withValues(alpha: 0.2),
        chip: BannerChip(
          leading: const Icon(BootstrapIcons.clock_fill, size: 9, color: Colors.white),
          text: 'UP NEXT • ${today['start_time'] ?? ''}',
          frosted: false,
          mdLarger: false,
        ),
        title: scheduleTitle(today, 'Upcoming Class'),
        batchName: scheduleBatchName(today),
        className: scheduleClassName(today),
        subtitleColor: TdTw.cyan100,
        buttonLabel: 'GO LIVE',
        buttonTextColor: TdTw.blue900,
        buttonHoverColor: TdTw.cyan50,
        circleGap: 16,
        titleLetterSpacing: -0.025,
        onPressed: () => _handleStart(today['id']),
      );
    }

    return _NoScheduleBanner(onViewAll: _goToSchedules);
  }

  /// BOTTOM ROW: `grid gap-6 md:gap-8`, `lg:grid-cols-2` only while a class
  /// is live (Available Exams + Teacher Learning). On desktop the grid row
  /// stretches both columns (the empty-exams card grows, the learning cards
  /// fill the height).
  Widget _bottomRow(BuildContext context) {
    final lg = context.isLg;
    final ongoing = _bannerStatus == 'ongoing';
    return LayoutBuilder(builder: (context, c) {
      final twoCols = ongoing && lg;
      final colWidth = twoCols ? (c.maxWidth - 32) / 2 : c.maxWidth;
      final learning = _teacherLearning(context, width: colWidth, stretch: twoCols);
      if (!ongoing) return learning;
      final exams = _availableExamsPanel(context, stretch: twoCols);
      if (!twoCols) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [exams, SizedBox(height: context.isMd ? 32 : 24), learning],
        );
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Expanded(child: exams), const SizedBox(width: 32), Expanded(child: learning)],
        ),
      );
    });
  }

  Widget _availableExamsPanel(BuildContext context, {required bool stretch}) {
    final dark = context.isDark;
    final exams = availableExams(_allExams, _studentAttempts);

    Widget body;
    var grow = false;
    if (_examsLoading) {
      body = Column(children: [
        for (var n = 0; n < 3; n++) ...[
          if (n > 0) const SizedBox(height: 12),
          _Pulse(
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: dark ? Colors.white.withValues(alpha: 0.05) : Tw.slate100,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ]);
    } else if (exams.isEmpty) {
      body = _NoExamsCard(onTap: _goToExams);
      grow = true; // `flex-grow`
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, exam) in exams.take(4).indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            _ExamCard(exam: exam, onTap: _goToExams),
          ],
          if (exams.length > 4) ...[
            const SizedBox(height: 12),
            _MoreExamsButton(count: exams.length - 4, onTap: _goToExams),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(
                child: _Heading(
                    icon: BootstrapIcons.journal_check, iconColor: Tw.blue500, text: 'Available Exams'),
              ),
              _ViewAllChip(onTap: _goToExams),
            ],
          ),
        ),
        if (stretch && grow) Expanded(child: body) else body,
      ],
    );
  }

  Widget _teacherLearning(BuildContext context, {required double width, required bool stretch}) {
    final dark = context.isDark;
    final row = LearningCardsRow(availableWidth: width, stretch: stretch, inlineBadge: true);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _Heading(
            icon: BootstrapIcons.book_half,
            iconColor: dark ? TdTw.cyan400 : Tw.cyan500,
            text: 'Teacher Learning',
          ),
        ),
        if (stretch) Expanded(child: row) else row,
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
//  Widgets
// ═══════════════════════════════════════════════════════════════════════════

/// `font-black text-lg md:text-xl` section heading; its icon inherits the
/// heading size.
class _Heading extends StatelessWidget {
  const _Heading({required this.icon, required this.iconColor, required this.text});
  final IconData icon;
  final Color iconColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    final size = context.isMd ? 20.0 : 18.0;
    return Row(
      children: [
        Icon(icon, size: size, color: iconColor),
        const SizedBox(width: 8),
        Flexible(
          child: Text(text,
              style: blackHeading(
                  size: size, height: 28 / size, color: context.isDark ? Colors.white : Tw.slate900)),
        ),
      ],
    );
  }
}

/// Banner skeleton: `rounded-3xl min-h-[150px] p-8 flex items-center
/// justify-between bg-gradient-to-r from-slate-200 to-slate-100
/// animate-pulse` with `w-32 h-5 rounded-full`, `w-64 h-9 rounded-xl`,
/// `w-44 h-4 rounded-lg` bars and a `w-28 h-11 rounded-full` button.
class _BannerSkeleton extends StatelessWidget {
  const _BannerSkeleton();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    // Fixed `w-*` widths on the web; here they may shrink on narrow screens.
    Widget bar(double w, double h, double r, Color light, Color darkColor) => Container(
          height: h,
          constraints: BoxConstraints(maxWidth: w),
          decoration: BoxDecoration(color: dark ? darkColor : light, borderRadius: BorderRadius.circular(r)),
        );
    return _Pulse(
      child: Container(
        constraints: const BoxConstraints(minHeight: 150),
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(colors: dark ? [Tw.slate800, Tw.slate700] : [Tw.slate200, Tw.slate100]),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  bar(128, 20, 999, Tw.slate300, Tw.slate600),
                  const SizedBox(height: 12),
                  bar(256, 36, 20, Tw.slate300, Tw.slate600),
                  const SizedBox(height: 12),
                  bar(176, 16, 16, Tw.slate200, Tw.slate700),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SizedBox(width: 112, child: bar(112, 44, 999, Tw.slate300, Tw.slate600)),
          ],
        ),
      ),
    );
  }
}

/// "No classes scheduled today" — dashed card with a "View All →" button.
class _NoScheduleBanner extends StatelessWidget {
  const _NoScheduleBanner({required this.onViewAll});
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final pad = context.isMd ? 32.0 : 24.0;
    return CustomPaint(
      painter: DashedBorderPainter(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate200),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: pad, vertical: 24 + pad),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: dark ? Colors.white.withValues(alpha: 0.05) : Tw.slate100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(BootstrapIcons.calendar_x, size: 24, color: dark ? Tw.slate500 : Tw.slate400),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No classes scheduled today',
                      style: TextStyle(
                          fontSize: 16, height: TwLeading.base, fontWeight: FontWeight.w700, color: dark ? Tw.slate300 : Tw.slate600)),
                  const SizedBox(height: 4),
                  Text('Enjoy the break — your next class will appear here automatically',
                      style: TextStyle(fontSize: 14, height: TwLeading.sm, color: dark ? Tw.slate500 : Tw.slate400)),
                ],
              ),
            ),
            const SizedBox(width: 20),
            HoverBuilder(
              cursor: SystemMouseCursors.click,
              builder: (context, hover) => GestureDetector(
                onTap: onViewAll,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: dark
                        ? Colors.white.withValues(alpha: hover ? 0.1 : 0.05)
                        : (hover ? Tw.slate200 : Tw.slate100),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate200),
                  ),
                  child: Text('View All →',
                      style: TextStyle(
                          fontSize: 14,
                          height: TwLeading.sm,
                          fontWeight: FontWeight.w700,
                          // the ghost variant keeps `hover:text-accent-foreground`
                          color: hover ? WebColors.accentForeground : (dark ? Tw.slate300 : Tw.slate600))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// "Show All Schedules →" (`bg-white/5 border-white/10 rounded-2xl`).
class _ShowAllButton extends StatelessWidget {
  const _ShowAllButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hover) {
        final fg = hover ? (dark ? Colors.white : Tw.slate900) : (dark ? Tw.slate300 : Tw.slate600);
        return GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(vertical: context.isMd ? 16 : 12),
            decoration: BoxDecoration(
              // the ghost variant keeps `dark:hover:bg-accent/50`
              color: hover && dark ? WebColors.accent.withValues(alpha: 0.5) : Colors.white.withValues(alpha: hover ? 0.1 : 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: WebShadow.sm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Show All Schedules',
                    style: TextStyle(fontSize: 14, height: TwLeading.sm, fontWeight: FontWeight.w700, color: fg)),
                const SizedBox(width: 8),
                Icon(BootstrapIcons.arrow_right, size: 16, color: fg),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// "View All →" chip of the Available Exams header.
class _ViewAllChip extends StatelessWidget {
  const _ViewAllChip({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => HoverBuilder(
        cursor: SystemMouseCursors.click,
        builder: (context, hover) => GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              // the ghost variant keeps `dark:hover:bg-accent/50`
              color: hover && context.isDark
                  ? WebColors.accent.withValues(alpha: 0.5)
                  : Tw.blue500.withValues(alpha: hover ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text('View All',
                  style: TextStyle(
                      fontSize: 12, height: TwLeading.xs, fontWeight: FontWeight.w700, color: hover ? Tw.blue600 : Tw.blue500)),
              const SizedBox(width: 4),
              Icon(BootstrapIcons.arrow_right, size: 12, color: hover ? Tw.blue600 : Tw.blue500),
            ]),
          ),
        ),
      );
}

/// "No exams scheduled — Go to Exams →" (dashed, clickable).
class _NoExamsCard extends StatelessWidget {
  const _NoExamsCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hover) {
        final iconBg = dark
            ? Tw.blue500.withValues(alpha: hover ? 0.2 : 0.1)
            : (hover ? Tw.blue100 : Tw.blue50);
        Widget box(double size, double radius, IconData icon, double iconSize) => Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(radius)),
              child: Icon(icon, size: iconSize, color: Tw.blue400),
            );
        return GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              color: dark ? TdTw.deepIndigo : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: hover ? WebShadow.md : WebShadow.sm,
            ),
            child: CustomPaint(
              painter: DashedBorderPainter(
                radius: 16,
                color: hover
                    ? (dark ? Tw.blue400.withValues(alpha: 0.5) : Tw.blue400)
                    : (dark ? Tw.blue500.withValues(alpha: 0.2) : const Color(0xFFBFDBFE)),
              ),
              child: Padding(
                // Card `py-6` + CardContent `p-6`.
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 80),
                  child: Row(
                    children: [
                      box(44, 20, BootstrapIcons.journal_check, 18),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('No exams scheduled',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: dark ? Tw.slate300 : Tw.slate600)),
                            const SizedBox(height: 2),
                            const Text('Go to Exams →',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Tw.blue500)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      box(32, 16, BootstrapIcons.arrow_right, 14),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// An available exam (type strip, icon, status/type, name, duration/batch,
/// footer with the timing and "Start Exam").
class _ExamCard extends StatelessWidget {
  const _ExamCard({required this.exam, required this.onTap});
  final Map<String, dynamic> exam;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final kind = examTypeKind(exam);
    final (stripColors, accent) = switch (kind) {
      ExamTypeKind.quiz => (const [Color(0xFFA78BFA), Tw.purple500], Tw.violet500),
      ExamTypeKind.practice => (const [Tw.emerald400, Tw.teal500], Tw.emerald500),
      ExamTypeKind.exam => (const [Tw.blue500, Tw.cyan500], Tw.blue500),
    };
    final (statusBg, statusFg) = switch (examStatusKind(exam['status'])) {
      ExamStatusKind.scheduled => (Tw.blue100, Tw.blue700),
      ExamStatusKind.ongoing => (Tw.emerald100, Tw.emerald700),
      ExamStatusKind.completed => (Tw.slate100, Tw.slate600),
      ExamStatusKind.draft => (const Color(0xFFFEF3C7), const Color(0xFFB45309)),
      ExamStatusKind.other => (Tw.slate100, Tw.slate500),
    };
    final muted = dark ? Tw.slate500 : Tw.slate400;
    final batchName = dig(exam, const ['batch', 'name']);
    final hasBatch = jsTruthy(batchName);
    final startTime = exam['start_time'];

    final Widget timing;
    if (jsTruthy(exam['is_open_anytime'])) {
      timing = const Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(BootstrapIcons.infinity, size: 9, color: Tw.emerald500),
        SizedBox(width: 4),
        Text('Open anytime', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Tw.emerald500)),
      ]);
    } else if (jsTruthy(startTime)) {
      timing = Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(BootstrapIcons.calendar3, size: 9, color: muted),
        const SizedBox(width: 4),
        Text(fmtExamDate(startTime), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: muted)),
      ]);
    } else {
      timing = Text('—', style: TextStyle(fontSize: 10, color: muted));
    }

    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hover) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          // Card `py-6` around the CardContent.
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: dark ? TdTw.deepIndigo : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.05) : Tw.slate200),
            boxShadow: hover ? WebShadow.md : WebShadow.sm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(height: 4, decoration: BoxDecoration(gradient: LinearGradient(colors: stripColors))),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(BootstrapIcons.file_earmark_text_fill, size: 16, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration:
                                  BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
                              child: Text('${exam['status'] ?? ''}'.toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 0.9, color: statusFg)),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text('${exam['exam_type'] ?? ''}'.toUpperCase(),
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: muted)),
                            ),
                          ]),
                          const SizedBox(height: 2),
                          Text('${exam['name'] ?? ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14,
                                  height: 1.375,
                                  fontWeight: FontWeight.w700,
                                  color: dark ? Colors.white : Tw.slate800)),
                          const SizedBox(height: 4),
                          Row(children: [
                            Icon(BootstrapIcons.clock, size: 9, color: muted),
                            const SizedBox(width: 4),
                            Text(examDurationLabel(exam), style: TextStyle(fontSize: 10, color: muted)),
                            if (hasBatch) ...[
                              const SizedBox(width: 12),
                              Icon(BootstrapIcons.people, size: 9, color: muted),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text('$batchName',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 10, color: muted)),
                              ),
                            ],
                          ]),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: hover
                            ? (dark ? Tw.blue500.withValues(alpha: 0.2) : Tw.blue100)
                            : (dark ? Colors.white.withValues(alpha: 0.05) : Tw.slate100),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(BootstrapIcons.arrow_right, size: 12, color: hover ? Tw.blue500 : Tw.slate400),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: dark ? Colors.white.withValues(alpha: 0.05) : AppColors.border),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(child: Align(alignment: Alignment.centerLeft, child: timing)),
                    const Text('Start Exam',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Tw.blue500)),
                    const SizedBox(width: 4),
                    const Icon(BootstrapIcons.play_fill, size: 9, color: Tw.blue500),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "+N more exams → View All"
class _MoreExamsButton extends StatelessWidget {
  const _MoreExamsButton({required this.count, required this.onTap});
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hover) => GestureDetector(
        onTap: onTap,
        // `rounded-xl border border-dashed`; the ghost variant keeps
        // `hover:bg-accent dark:hover:bg-accent/50`.
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          decoration: BoxDecoration(
            color: hover ? (dark ? WebColors.accent.withValues(alpha: 0.5) : WebColors.accent) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: CustomPaint(
            painter: DashedBorderPainter(
              radius: 20,
              strokeWidth: 1,
              color: hover ? const Color(0xFF93C5FD) : (dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate200),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text('+$count more exams → View All',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    height: TwLeading.xs,
                    fontWeight: FontWeight.w700,
                    color: hover ? Tw.blue500 : (dark ? Tw.slate400 : Tw.slate500),
                  )),
            ),
          ),
        ),
      ),
    );
  }
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
