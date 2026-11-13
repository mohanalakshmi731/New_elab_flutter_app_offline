import 'dart:async';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../dashboard/web_style.dart';
import 'teacher_dashboard_controller.dart';
import 'teacher_dashboard_logic.dart';
import 'teachers_dashboard_widgets.dart';

/// Port of
/// `src/components/new_ui_student_teacher_for_both_labs/teachersdashboardpage.vue`
/// (`/teachersdashboardpage`, inside the eLabs DashboardShell).
///
/// Dynamic schedule banner (live → today → none) refreshed every 30 s, the
/// metric cards, "AI Insights" and "Teacher Learning" (static content, as on
/// the web).
class TeachersDashboardPage extends ConsumerStatefulWidget {
  const TeachersDashboardPage({super.key});

  @override
  ConsumerState<TeachersDashboardPage> createState() => _TeachersDashboardPageState();
}

/// Where "JOIN NOW" / "View All" / "Show All Schedules" go. The web pushes
/// `/newlayout/teacherschedules`, a route that does not exist in the eLabs
/// build (blank page); the teacher schedules screen is `/teacherschedules`.
const _schedulesRoute = '/teacherschedules';

class _TeachersDashboardPageState extends ConsumerState<TeachersDashboardPage> {
  // ── state ───────────────────────────────────────────────────────────────
  bool _bannerLoading = false;
  List<dynamic> _ongoingSchedules = const [];
  List<dynamic> _todaySchedules = const [];
  Timer? _refreshInterval;

  TeacherDashboardController get _ctrl => ref.read(teacherDashboardControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (mounted) _fetchBannerSchedules(showLoader: true);
    });
    // Auto-refresh every 30s to catch new live classes.
    _refreshInterval = Timer.periodic(const Duration(seconds: 30), (_) => _fetchBannerSchedules());
  }

  @override
  void dispose() {
    _refreshInterval?.cancel();
    super.dispose();
  }

  /// `fetchBannerSchedules(showLoader)`
  Future<void> _fetchBannerSchedules({bool showLoader = false}) async {
    if (showLoader) setState(() => _bannerLoading = true);
    try {
      // 1. Fetch ongoing (live right now)
      final ongoingRes = await _ctrl.getNextSchedules();
      if (!mounted) return;
      setState(() => _ongoingSchedules = ongoingFromResponse(ongoingRes));

      // 2. Always fetch today for the metric card count. The store action
      // returns nothing, so `todayRes` is always empty (kept as on the web).
      final today = todayIso();
      final todayRes = await _ctrl.getSchedules({'start_date': today, 'end_date': today});
      if (!mounted) return;
      setState(() => _todaySchedules = todayFromResponse(todayRes));
    } catch (_) {
      // "Dashboard banner fetch error" — console only on the web.
    } finally {
      if (mounted) setState(() => _bannerLoading = false);
    }
  }

  /// `handleStart(scheduleId)` — emits `start` + `navigate`, which nothing
  /// listens to when the page is a route, so it does nothing (as on the web).
  void _handleStart(Object? scheduleId) {}

  /// `emit('navigate', 'visuals')` — no listener (no-op, as on the web).
  void _openVisualTool() {}

  /// `goToSchedules()`
  void _goToSchedules() => context.go(_schedulesRoute);

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

  // TOP ROW: Next Class Banner + Metric Cards
  Widget _topRow(BuildContext context) {
    final lg = context.isLg;
    final banner = _banner(context);
    final showAll = _ShowAllSchedulesButton(onPressed: _goToSchedules);

    final totalStudents = MetricCard(
      label: 'Total Students',
      icon: BootstrapIcons.people_fill,
      iconColor: Tw.emerald400,
      iconBg: Tw.emerald500.withValues(alpha: 0.2),
      hoverBorder: Tw.emerald500.withValues(alpha: 0.5),
      value: '128',
      caption: _caption(
        context,
        '95% Active this week',
        color: context.isDark ? Tw.emerald400 : Tw.emerald500,
        icon: BootstrapIcons.graph_up_arrow,
      ),
    );
    final todayClasses = MetricCard(
      label: "Today's Classes",
      icon: BootstrapIcons.calendar3,
      iconColor: TdTw.purple400,
      iconBg: Tw.purple500.withValues(alpha: 0.2),
      hoverBorder: Tw.purple500.withValues(alpha: 0.5),
      value: '${_todaySchedules.length}',
      caption: _caption(
        context,
        todayClassesCaption(_todaySchedules.length),
        color: context.isDark ? Tw.slate400 : Tw.slate500,
      ),
    );

    if (!lg) {
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

  Widget _caption(BuildContext context, String text, {required Color color, IconData? icon}) {
    // `text-[10px] md:text-xs font-bold mt-1 flex items-center gap-1`
    final size = context.isMd ? 12.0 : 10.0;
    return Row(
      children: [
        if (icon != null) ...[Icon(icon, size: 12, color: color), const SizedBox(width: 4)],
        Flexible(
          child: Text(text,
              style: TextStyle(
                  fontSize: size,
                  height: size == 12 ? TwLeading.xs : TwLeading.inherit,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ),
      ],
    );
  }

  /// DYNAMIC SCHEDULE BANNER — priority: ongoing → today → none.
  Widget _banner(BuildContext context) {
    if (_bannerLoading) return const BannerSkeleton();

    final status = bannerStatusOf(_ongoingSchedules, _todaySchedules);
    final active = _ongoingSchedules.isEmpty ? null : asMap(_ongoingSchedules.first);
    final todaySchedule = _todaySchedules.isEmpty ? null : asMap(_todaySchedules.first);

    if (status == 'ongoing' && active != null) {
      return ScheduleBannerCard(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Tw.emerald600, TdTw.sky600, Tw.indigo600],
          stops: [0, 0.55, 1],
        ),
        // `shadow-lg shadow-emerald-900/30` → the plain style.css shadow-lg.
        shadow: WebShadow.lg,
        glowColor: Tw.emerald400.withValues(alpha: 0.2),
        subtitleIconSize: 16,
        chip: BannerChip(
          leading: const PulseDot(color: TdTw.emerald300),
          text: 'LIVE NOW • ${_text(active['start_time'])}',
        ),
        title: scheduleTitle(active, 'Live Class'),
        batchName: scheduleBatchName(active),
        className: scheduleClassName(active),
        subtitleColor: Tw.emerald100,
        buttonLabel: 'JOIN NOW',
        buttonTextColor: TdTw.emerald800,
        buttonHoverColor: Tw.emerald50,
        onPressed: _goToSchedules,
      );
    }

    if (status == 'today' && todaySchedule != null) {
      return ScheduleBannerCard(
        gradient: const LinearGradient(colors: [TdTw.cyan600, Tw.blue600]),
        shadow: WebShadow.lg,
        glowColor: TdTw.cyan400.withValues(alpha: 0.2),
        subtitleIconSize: 16,
        chip: BannerChip(
          leading: const Icon(BootstrapIcons.clock_fill, size: 9, color: Colors.white),
          text: 'UP NEXT • ${_text(todaySchedule['start_time'])}',
        ),
        title: scheduleTitle(todaySchedule, 'Upcoming Class'),
        batchName: scheduleBatchName(todaySchedule),
        className: scheduleClassName(todaySchedule),
        subtitleColor: TdTw.cyan100,
        buttonLabel: 'GO LIVE',
        buttonTextColor: TdTw.blue900,
        buttonHoverColor: TdTw.cyan50,
        circleGap: 16,
        onPressed: () => _handleStart(todaySchedule['id']),
      );
    }

    return _EmptyBanner(onViewAll: _goToSchedules);
  }

  // BOTTOM ROW: AI Insights + Teacher Learning
  /// `grid grid-cols-1 lg:grid-cols-2 gap-6 md:gap-8`; on desktop the grid
  /// row stretches both panels (the AI card grows, the learning cards fill
  /// the height).
  Widget _bottomRow(BuildContext context) {
    final lg = context.isLg;
    return LayoutBuilder(builder: (context, c) {
      final colWidth = lg ? (c.maxWidth - 32) / 2 : c.maxWidth;
      final ai = _AiInsightsPanel(onOpenVisualTool: _openVisualTool, stretch: lg);
      final learning = _TeacherLearningPanel(width: colWidth, stretch: lg);
      if (!lg) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [ai, SizedBox(height: context.isMd ? 32 : 24), learning],
        );
      }
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [Expanded(child: ai), const SizedBox(width: 32), Expanded(child: learning)],
        ),
      );
    });
  }
}

/// `{{ value }}`
String _text(Object? v) => v == null ? '' : '$v';

/// NO SCHEDULE — empty state (`border-2 border-dashed`).
class _EmptyBanner extends StatelessWidget {
  const _EmptyBanner({required this.onViewAll});
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final inner = context.isMd ? 32.0 : 24.0;
    return CustomPaint(
      painter: DashedBorderPainter(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate200),
      child: Padding(
        // Card `py-6` + CardContent `p-6 md:p-8`.
        padding: EdgeInsets.symmetric(horizontal: inner, vertical: 24 + inner),
        child: Align(
          alignment: Alignment.centerLeft,
          heightFactor: 1,
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
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
                  mainAxisSize: MainAxisSize.min,
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
                            fontSize: 14, height: TwLeading.sm, fontWeight: FontWeight.w700, color: dark ? Tw.slate300 : Tw.slate600)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Show All Schedules" (`bg-white/5 hover:bg-white/10 border-white/10
/// rounded-2xl`).
class _ShowAllSchedulesButton extends StatelessWidget {
  const _ShowAllSchedulesButton({required this.onPressed});
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
              color: Colors.white.withValues(alpha: hover ? 0.1 : 0.05),
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

/// AI Insights Panel (static content on the web).
///
/// The card's `border-l-4 border-l-amber-500` is dropped by tailwind-merge
/// (the later `border-slate-200` / `dark:border-white/5` wins), so the 4 px
/// left border has the normal border colour.
class _AiInsightsPanel extends StatelessWidget {
  const _AiInsightsPanel({required this.onOpenVisualTool, this.stretch = false});
  final VoidCallback onOpenVisualTool;

  /// Fill the stretched grid row (`flex-grow`, content `justify-between`).
  final bool stretch;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final strong = dark ? Colors.white : Tw.slate900;
    final borderColor = dark ? Colors.white.withValues(alpha: 0.05) : Tw.slate200;

    final icon = Container(
      margin: const EdgeInsets.only(top: 4),
      width: 48,
      height: 48,
      decoration: BoxDecoration(color: Tw.amber500.withValues(alpha: 0.1), shape: BoxShape.circle),
      child: const Icon(BootstrapIcons.exclamation_triangle_fill, size: 20, color: Tw.amber500),
    );
    final texts = Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Intervention Recommended',
                style: TextStyle(fontSize: 16, height: 1.25, fontWeight: FontWeight.w700, color: strong)),
            const SizedBox(height: 8),
            Text.rich(
              TextSpan(children: [
                TextSpan(text: '75% of Grade 8', style: TextStyle(fontWeight: FontWeight.w700, color: strong)),
                const TextSpan(
                    text: " students struggled with the 'Factorisation' module in MathZoro yesterday. "
                        "The NCF core competency 'Procedural Fluency' is lagging."),
              ]),
              style: TextStyle(fontSize: 14, height: 1.625, color: dark ? Tw.slate300 : Tw.slate600),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _OpenVisualToolButton(onPressed: onOpenVisualTool),
        ),
      ],
    );

    final card = HoverBuilder(
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        // Card `py-6` + CardContent `p-5`.
        padding: const EdgeInsets.fromLTRB(20, 24 + 20, 20, 24 + 20),
        decoration: BoxDecoration(
          color: hover ? (dark ? TdTw.deepIndigoHover : Tw.slate50) : (dark ? TdTw.deepIndigo : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border(
            left: BorderSide(color: borderColor, width: 4),
            top: BorderSide(color: borderColor),
            right: BorderSide(color: borderColor),
            bottom: BorderSide(color: borderColor),
          ),
          boxShadow: WebShadow.md,
        ),
        child: Row(
          crossAxisAlignment: stretch ? CrossAxisAlignment.stretch : CrossAxisAlignment.start,
          children: [
            if (stretch) Align(alignment: Alignment.topCenter, child: icon) else icon,
            const SizedBox(width: 16),
            Expanded(child: texts),
          ],
        ),
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const PanelHeading(icon: BootstrapIcons.stars, iconColor: Tw.amber400, text: 'AI Insights', iconSize: 18),
        if (stretch) Expanded(child: card) else card,
      ],
    );
  }
}

class _OpenVisualToolButton extends StatelessWidget {
  const _OpenVisualToolButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return HoverBuilder(
      cursor: SystemMouseCursors.click,
      builder: (context, hover) {
        final fg = hover ? (dark ? TdTw.amber300 : Tw.amber600) : (dark ? Tw.amber400 : Tw.amber500);
        return GestureDetector(
          onTap: onPressed,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Tw.amber500.withValues(alpha: hover ? 0.2 : 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Open Visual Tool',
                    style: TextStyle(fontSize: 14, height: TwLeading.sm, fontWeight: FontWeight.w700, color: fg)),
                const SizedBox(width: 4),
                Icon(BootstrapIcons.arrow_right, size: 16, color: fg),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Teacher Learning Panel (static cards on the web).
class _TeacherLearningPanel extends StatelessWidget {
  const _TeacherLearningPanel({required this.width, this.stretch = false});
  final double width;
  final bool stretch;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final row = LearningCardsRow(availableWidth: width, stretch: stretch);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PanelHeading(
          icon: BootstrapIcons.book_half,
          iconColor: dark ? TdTw.cyan400 : Tw.cyan500,
          text: 'Teacher Learning',
          iconSize: 18,
        ),
        if (stretch) Expanded(child: row) else row,
      ],
    );
  }
}
