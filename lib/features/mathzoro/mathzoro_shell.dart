import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';
import '../shell/dashboard_shell.dart' show AppFooter;
import 'mathzoro_controller.dart';
import 'mz_ui.dart';
import '../offline/offline_runtime.dart';

/// Port of `newdashboardlayout.vue` — the `/newlayout` shell.
///
/// The layout renders its own `<aside>` sidebar (role-based
/// `currentNavItems`, NAV_STUDENT_MATHZORO for MathZoro students) except on
/// `/newlayout/studentupgradeplan` (`hideSidebar()`). From `lg` (1024) up it
/// sits beside the content and the header's ☰ button toggles it between
/// 260 px and a 68 px icon strip; below `lg` it is an off-canvas drawer over a
/// blurred backdrop that closes after a nav click. It starts open on `lg+`
/// and closed below, and resets whenever the window crosses that breakpoint.
class MathZoroShell extends ConsumerStatefulWidget {
  const MathZoroShell({super.key, required this.child, this.location = ''});

  final Widget child;

  /// Current path (`route.path`), used for the active nav item.
  final String location;

  @override
  ConsumerState<MathZoroShell> createState() => _MathZoroShellState();
}

// ─── Nav item configs (newdashboardlayout.vue) ──────────────────────────────

class MzNavItem {
  const MzNavItem(this.key, this.label, this.icon, this.route);
  final String key;
  final String label;
  final IconData icon;
  final String route;

  /// `<router-link custom v-slot="{ isActive }">` — the link's route or a
  /// route nested under it.
  bool isActive(String path) => path == route || path.startsWith('$route/');
}

const _navTeacher = [
  MzNavItem('dashboard', 'Dashboard', BootstrapIcons.grid_fill, '/dashboard'),
  MzNavItem(
    'activity-library',
    'Activity Library',
    BootstrapIcons.journal_bookmark_fill,
    '/activitylibrary',
  ),
];

const _navAdmin = [
  MzNavItem('dashboard', 'Dashboard', BootstrapIcons.grid_fill, '/dashboard'),
  MzNavItem('user-list', 'Users List', BootstrapIcons.people_fill, '/userlist'),
  MzNavItem(
    'user-activity',
    'User Activity Log',
    BootstrapIcons.clock_history,
    '/useractivitylog',
  ),
  MzNavItem(
    'institute-list',
    'Institute List',
    BootstrapIcons.building,
    '/instituteslist',
  ),
  MzNavItem(
    'invitations',
    'Invitation List',
    BootstrapIcons.envelope_fill,
    '/Invitationslist',
  ),
  MzNavItem(
    'plans',
    'Subscription Plans',
    BootstrapIcons.credit_card_fill,
    '/institutesplanCreate',
  ),
  MzNavItem(
    'subscriptions',
    'Role Subscriptions',
    BootstrapIcons.person_badge_fill,
    '/subscription',
  ),
  MzNavItem(
    'zsl-plan',
    'Class Access Types',
    BootstrapIcons.shield_lock_fill,
    '/zslplan',
  ),
];

const _navInstitute = [
  MzNavItem('dashboard', 'Dashboard', BootstrapIcons.grid_fill, '/dashboard'),
  MzNavItem('class-list', 'Classes', BootstrapIcons.book, '/classlist'),
  MzNavItem('course-list', 'Courses', BootstrapIcons.pc_display, '/courselist'),
  MzNavItem('exams', 'Exams', BootstrapIcons.pencil_square, '/exams'),
  MzNavItem(
    'questions',
    'Question Bank',
    BootstrapIcons.question_circle_fill,
    '/questions',
  ),
  MzNavItem(
    'library',
    'Activity Library',
    BootstrapIcons.journal_bookmark_fill,
    '/library',
  ),
];

const _navStudentMathZoro = [
  MzNavItem(
    'dashboard',
    'Dashboard',
    BootstrapIcons.grid_fill,
    '/newlayout/studentdashboard',
  ),
  MzNavItem(
    'math-zone',
    'Math Zone',
    BootstrapIcons.calculator_fill,
    '/newlayout/newmathzone',
  ),
  MzNavItem(
    'play-zone',
    'Play Zone',
    BootstrapIcons.controller,
    '/newlayout/playzone',
  ),
  MzNavItem(
    'reports',
    'Reports',
    BootstrapIcons.bar_chart_line_fill,
    '/newlayout/reports',
  ),
];

const _navStudentNormal = [
  MzNavItem(
    'dashboard',
    'Dashboard',
    BootstrapIcons.grid_fill,
    '/newlayout/studentdashboardlayout',
  ),
  MzNavItem(
    'math-zone',
    'Math Zone',
    BootstrapIcons.calculator_fill,
    '/newlayout/newmathzone',
  ),
  MzNavItem(
    'science-zone',
    'Science Zone',
    BootstrapIcons.eyedropper,
    '/newlayout/studentsciencezone',
  ),
  MzNavItem(
    'exams',
    'Exams',
    BootstrapIcons.check2_square,
    '/newlayout/newexams',
  ),
  MzNavItem(
    'reports',
    'Reports',
    BootstrapIcons.bar_chart_line_fill,
    '/newlayout/reports',
  ),
];

List<MzNavItem> _currentNavItems(String role, bool isMathZoro) {
  final r = role.toLowerCase();
  if (r == 'student')
    return isMathZoro ? _navStudentMathZoro : _navStudentNormal;
  if (r == 'instructor' || r == 'teacher') return _navTeacher;
  if (r == 'admin') return _navAdmin;
  if (r == 'institute') return _navInstitute;
  return const [];
}

// ─── Shell ──────────────────────────────────────────────────────────────────

class _MathZoroShellState extends ConsumerState<MathZoroShell> {
  dynamic _tickets;
  bool _loadingTickets = false;
  List<Map<String, dynamic>> _languages = const [];
  num _studentPoints = 0;
  bool _loadingPoints = false;
  String _studentClass = '';
  List<Map<String, dynamic>> _teacherClasses = const [];
  bool _loadingClasses = false;

  /// `sidebarOpen` — set from the breakpoint in [didChangeDependencies].
  bool _sidebarOpen = false;
  bool? _wasMobileOrMedium;

  SessionState get _session => ref.read(sessionProvider);
  MathZoroController get _mz => ref.read(mathZoroProvider.notifier);

  bool get _isStudent => _session.role.toLowerCase() == 'student';
  bool get _isInstructor =>
      ['instructor', 'teacher'].contains(_session.role.toLowerCase());
  bool get _isMathZoro => _session.userInfo?.isMathZoro ?? false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  /// `isMobileOrMedium` = window narrower than 1024. mounted():
  /// `sidebarOpen = !isMobileOrMedium`; watch(isMobileOrMedium): same.
  bool get _isMobileOrMedium => !context.isLg;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mobile = _isMobileOrMedium;
    if (_wasMobileOrMedium != mobile) {
      _wasMobileOrMedium = mobile;
      _sidebarOpen = !mobile;
    }
  }

  /// `hideSidebar()` — the upgrade-plan page has no sidebar (and no ☰).
  bool get _hideSidebar => widget.location == '/newlayout/studentupgradeplan';

  Future<void> _init() async {
    await _mz.ready;
    if (!mounted) return;
    unawaited(_langu());
    unawaited(_loadInstituteData());

    if (_isMathZoro) {
      unawaited(_loadTickets());
      if (_isStudent) unawaited(_loadStudentPoints());
    }
    if (_isInstructor) unawaited(_loadTeacherClasses());
  }

  // ── data ─────────────────────────────────────────────────────────────────

  Future<void> _loadTickets() async {
    setState(() => _loadingTickets = true);
    try {
      debugPrint(
        'STORE MATHZORO CLASS ID => ${_session.userInfo?.mathzoroClassId}',
      );
      final res = await _mz.getZslTickets();
      final inner = asMap(res)?['data'];
      if (mounted) setState(() => _tickets = jsTruthy(inner) ? inner : res);
    } catch (e) {
      debugPrint('Tickets error: $e');
    } finally {
      if (mounted) setState(() => _loadingTickets = false);
    }
  }

  /// `getStudentPoints` is mapped to `getZslTickets` on the web as well.
  Future<void> _loadStudentPoints() async {
    setState(() => _loadingPoints = true);
    try {
      final res = await _mz.getZslTickets();
      final data = asMap(asMap(res)?['data'] ?? res);
      final points =
          data?['points'] ??
          data?['total_points'] ??
          data?['score'] ??
          data?['xp'] ??
          0;
      if (mounted) {
        setState(() {
          _studentPoints = points is num ? points : (asDouble(points) ?? 0);
          // userInfo has no class_name / grade in the session model.
          _studentClass = '';
        });
      }
    } catch (e) {
      debugPrint('Points error: $e');
      if (mounted) setState(() => _studentPoints = 0);
    } finally {
      if (mounted) setState(() => _loadingPoints = false);
    }
  }

  Future<void> _langu() async {
    try {
      final res = await _mz.getZslLanguages();
      final inner = asMap(res)?['data'];
      final list = asList(
        jsTruthy(inner) ? inner : res,
      ).map(asMap).whereType<Map<String, dynamic>>().toList();
      if (!mounted) return;
      setState(() => _languages = list);
      if (list.isNotEmpty) {
        final current = _session.language.code;
        final valid = list.any((l) => asString(l['code']) == current);
        if (!valid) _mz.setLanguage(AppLanguage.fromJson(list.first));
      }
    } catch (e) {
      debugPrint('$e');
    }
  }

  /// `instituteData` is never rendered by the web template; the request is
  /// kept for parity (it returns null for students).
  Future<void> _loadInstituteData() async {
    try {
      await _mz.profilegetInstituteById();
    } catch (e) {
      debugPrint('Failed to fetch institute data $e');
    }
  }

  Future<void> _loadTeacherClasses() async {
    setState(() => _loadingClasses = true);
    try {
      await _mz.getClasses();
      if (mounted)
        setState(() => _teacherClasses = ref.read(mathZoroProvider).institutes);
    } catch (e) {
      debugPrint('Failed to load teacher classes: $e');
    } finally {
      if (mounted) setState(() => _loadingClasses = false);
    }
  }

  void _onClassSelect(Map<String, dynamic> cls) {
    _mz.setSelectedClass(cls);
    _mz.setClassDetails(
      id: cls['id'],
      name: jsStr(jsTruthy(cls['year']) ? cls['year'] : cls['name']) ?? '',
      cId: jsTruthy(cls['c_id']) ? cls['c_id'] : '',
    );
  }

  Future<void> _logout() async {
    await ref.read(sessionProvider.notifier).logout();
    AppToast.success('Logged out successfully!');
    if (mounted) context.go(AppRoutes.mathzoroLogin);
  }

  void _profile() => context.go('/newlayout/MyProfile');

  void _upgradePlan() {
    var target = '/upgradeplan';
    if (_isStudent) {
      target = _isMathZoro
          ? '/newlayout/studentupgradeplan'
          : '/studentpayment';
    }
    context.go(target);
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // window.addEventListener('tickets-updated', this.loadTickets)
    ref.listen<int>(mathZoroProvider.select((s) => s.ticketsUpdatedTick), (
      _,
      _,
    ) {
      _loadTickets();
    });

    final dark = context.isDark;
    final mobile = _isMobileOrMedium;
    final learning = ref.watch(offlineWorkspaceOwnerProvider) != null;
    final session = ref.watch(sessionProvider);
    final isStudent = session.role.toLowerCase() == 'student';
    final items = _currentNavItems(
      session.role,
      session.userInfo?.isMathZoro ?? false,
    );

    Widget sidebar() => _MzSidebar(
      items: items,
      location: widget.location,
      open: _sidebarOpen,
      mobileOrMedium: mobile,
      isStudent: isStudent,
      username: session.username,
      role: session.role,
      // lg+: the logo is painted by the overlay below.
      showLogo: mobile,
      onNavigate: (item) {
        context.go(item.route);
        if (mobile) setState(() => _sidebarOpen = false);
      },
    );
    final desktopSidebar = !_hideSidebar && !mobile && !learning;
    // Built here (it ref.watch-es) rather than inside the width tween's builder.
    final header = _header(session);

    return Scaffold(
      backgroundColor: dark ? Mz.gray950 : Tw.gray50,
      body: Container(
        decoration: dark
            ? null
            : const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/dashboard_bg.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: dark ? Colors.white : Tw.gray900),
          child: SafeArea(
            bottom: false,
            // lg+: static sidebar, 260 px open / 68 px collapsed
            // (`transition-all duration-300`).
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: _sidebarOpen ? 260 : 68),
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              builder: (context, sw, _) => Stack(
                children: [
                  Positioned.fill(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (desktopSidebar)
                          SizedBox(width: sw, child: sidebar()),
                        Expanded(
                          // Keeps the routed page's state when the sidebar
                          // comes and goes (breakpoint, upgrade-plan page).
                          key: const ValueKey('mz-main'),
                          child: Column(
                            children: [
                              if (!learning) header,
                              Expanded(
                                key: const ValueKey('mz-page-content'),
                                child: Container(
                                  color: dark ? Mz.gray950 : Colors.transparent,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: learning ? 0 : 8,
                                  ),
                                  child: widget.child,
                                ),
                              ),
                              if (!learning) const AppFooter(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // lg+ logo (`h-15 w-auto`, 160×60): centred on the sidebar and,
                  // like on the web, overflowing the 68 px strip over the header
                  // (the <aside> is z-40). Click-through here so ☰ stays usable.
                  if (desktopSidebar)
                    Positioned(
                      left: sw / 2 - 80,
                      top: 6,
                      width: 160,
                      height: 60,
                      child: IgnorePointer(
                        child: Image.asset(
                          'assets/images/zsl_logo.png',
                          fit: BoxFit.contain,
                          semanticLabel: 'Zero Science Lab',
                        ),
                      ),
                    ),
                  // Below lg: backdrop (bg-black/50 backdrop-blur-sm) …
                  Positioned.fill(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _sidebarOpen && mobile && !learning
                          ? GestureDetector(
                              onTap: () => setState(() => _sidebarOpen = false),
                              child: SizedBox.expand(
                                child: ClipRect(
                                  child: BackdropFilter(
                                    filter: ImageFilter.blur(
                                      sigmaX: 8,
                                      sigmaY: 8,
                                    ),
                                    child: ColoredBox(
                                      color: Colors.black.withValues(
                                        alpha: 0.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ),
                  // … and the 260 px drawer sliding in from the left.
                  if (!_hideSidebar && mobile && !learning)
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                      left: _sidebarOpen ? 0 : -260,
                      top: 0,
                      bottom: 0,
                      width: 260,
                      child: sidebar(),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(SessionState session) {
    final isStudent = session.role.toLowerCase() == 'student';
    final courses = ref.watch(
      mathZoroProvider.select((s) => s.mathZoroCourses),
    );
    final className = courses.isNotEmpty
        ? jsDisplay(courses.first['class_name'])
        : '';
    final daysLeft = _daysUntilExpiry(session.expiresOn);
    final dark = context.isDark;

    return SizedBox(
      height: 72,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // LEFT
            Expanded(
              child: Row(
                children: [
                  if (!_hideSidebar) ...[
                    HoverBuilder(
                      onTap: () => setState(() => _sidebarOpen = !_sidebarOpen),
                      builder: (context, hover) => AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: hover
                              ? (dark ? Tw.gray800 : Tw.gray100)
                              : Colors.transparent,
                          // rounded-md → calc(var(--radius) - 2px) = 14 px.
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          BootstrapIcons.list,
                          size: 20,
                          color: dark
                              ? (hover ? Colors.white : Tw.gray400)
                              : Tw.gray500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  if (jsTruthy(_tickets)) ...[
                    _TicketsBadge(tickets: _tickets, loading: _loadingTickets),
                    const SizedBox(width: 10),
                  ],
                  if (className.isNotEmpty) ...[
                    const Icon(
                      BootstrapIcons.mortarboard_fill,
                      size: 14,
                      color: Tw.green500,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        className,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  if (session.role == Role.institute &&
                      daysLeft != null &&
                      daysLeft <= 3)
                    _ExpiryBadge(daysLeft: daysLeft),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // RIGHT
            Row(
              mainAxisSize: MainAxisSize.min,
              children: isStudent
                  ? _studentRight(session)
                  : _staffRight(session),
            ),
          ],
        ),
      ),
    );
  }

  static int? _daysUntilExpiry(String? expiresOn) {
    if (expiresOn == null || expiresOn.isEmpty) return null;
    final expiry = DateTime.tryParse(expiresOn);
    if (expiry == null) return null;
    final diffMs = expiry.difference(DateTime.now()).inMilliseconds;
    return (diffMs / Duration.millisecondsPerDay).ceil();
  }

  List<Widget> _studentRight(SessionState session) {
    final name = session.username.isNotEmpty ? session.username : 'Student';
    final dark = context.isDark;
    return [
      const _BellButton(),
      const SizedBox(width: 6),
      // Points badge carries the `hidden` attribute on the web.
      Visibility(
        visible: false,
        child: _PointsBadge(points: _studentPoints, loading: _loadingPoints),
      ),
      _UserMenu(
        header: name.toUpperCase(),
        entries: [
          _MenuEntry(
            'upgrade',
            'Upgrade Plan',
            BootstrapIcons.arrow_up_circle,
            Tw.green500,
            _upgradePlan,
          ),
          _MenuEntry(
            'profile',
            'Profile',
            BootstrapIcons.person_fill,
            null,
            _profile,
          ),
          null,
          _MenuEntry(
            'logout',
            'Logout',
            BootstrapIcons.box_arrow_right,
            Tw.red500,
            _logout,
          ),
        ],
        // `hover:bg-gray-55` is not a Tailwind colour → no light hover.
        hoverColor: dark ? Tw.gray800 : null,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (context.isSm) ...[
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 200),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      name,
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                        color: dark ? Colors.white : Tw.gray800,
                      ),
                    ),
                    // `<p hidden>{{ studentClass || 'CLASS 10' }}</p>`
                    Visibility(
                      visible: false,
                      child: Text(
                        _studentClass.isNotEmpty ? _studentClass : 'CLASS 10',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
            // `d-inline-flex … rounded-circle bg-light mt-2` are Bootstrap
            // classes (not loaded) → a plain 40×40 box with the icon.
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(BootstrapIcons.person_circle, size: 18),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _staffRight(SessionState session) {
    final dark = context.isDark;
    final role = session.role;
    final name = session.username.toUpperCase();
    return [
      if (_isInstructor) ...[
        _TeacherClassSelect(
          classes: _teacherClasses,
          loading: _loadingClasses,
          selectedClass: ref.watch(
            mathZoroProvider.select((s) => s.selectedClass),
          ),
          onSelect: _onClassSelect,
        ),
        const SizedBox(width: 6),
      ],
      _LanguageSelect(languages: _languages),
      const SizedBox(width: 6),
      const _ColorModeButton(),
      const SizedBox(width: 6),
      const _BellButton(),
      const SizedBox(width: 6),
      _UserMenu(
        header: name,
        entries: [
          if (role != Role.admin)
            _MenuEntry(
              'profile',
              'Profile',
              BootstrapIcons.person_fill,
              null,
              _profile,
            ),
          if (role == Role.institute)
            _MenuEntry(
              'upgrade',
              'Upgrade Plan',
              BootstrapIcons.arrow_up_circle,
              null,
              _upgradePlan,
            ),
          if (role != Role.admin) null,
          _MenuEntry(
            'logout',
            'Logout',
            BootstrapIcons.box_arrow_right,
            Tw.red500,
            _logout,
          ),
        ],
        hoverColor: dark ? Tw.gray800 : Tw.gray100,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (context.isSm) ...[
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: dark ? Colors.white : Tw.gray800,
                ),
              ),
              const SizedBox(width: 8),
            ],
            Icon(
              BootstrapIcons.person_circle,
              size: 20,
              color: dark ? Colors.white : Tw.gray600,
            ),
          ],
        ),
      ),
    ];
  }
}

/// Points badge — rendered with the `hidden` attribute on the web.
class _PointsBadge extends StatelessWidget {
  const _PointsBadge({required this.points, required this.loading});
  final num points;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: dark ? Tw.yellow500.withValues(alpha: 0.1) : Mz.yellow50,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: dark ? Tw.yellow500.withValues(alpha: 0.3) : Mz.yellow200,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⭐', style: TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(
            loading
                ? '...'
                : '${NumberFormat.decimalPattern().format(points)} pts',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: dark ? Tw.yellow400 : Mz.yellow600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Header widgets ─────────────────────────────────────────────────────────

class _TicketsBadge extends StatelessWidget {
  const _TicketsBadge({required this.tickets, required this.loading});
  final dynamic tickets;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final t = asMap(tickets);
    final count =
        t?['total_tickets'] ?? t?['total_tokens'] ?? t?['tokens'] ?? 0;
    return HoverBuilder(
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: dark ? Tw.gray800 : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: dark ? Tw.gray600 : Tw.gray300),
          // shadow-sm hover:shadow-md (light only)
          boxShadow: dark ? null : (hover ? MzShadow.md : MzShadow.sm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              BootstrapIcons.ticket_perforated,
              size: 14,
              color: Tw.blue500,
            ),
            const SizedBox(width: 6),
            if (!loading)
              Text(
                jsDisplay(count),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: dark ? Colors.white : Tw.gray800,
                ),
              )
            else
              const _Pulse(
                child: Text(
                  '...',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Tw.gray400,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// `animate-pulse`.
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});
  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
    lowerBound: 0.5,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      FadeTransition(opacity: _c, child: widget.child);
}

class _ExpiryBadge extends StatelessWidget {
  const _ExpiryBadge({required this.daysLeft});
  final int daysLeft;

  @override
  Widget build(BuildContext context) {
    final d = daysLeft;
    final text = d > 0
        ? 'Expires in $d day${d == 1 ? '' : 's'}'
        : d == 0
        ? 'Expires today'
        : 'Expired';
    final dark = context.isDark;
    final fg = dark ? Tw.red300 : Tw.red600;
    return _Pulse(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: dark ? Tw.red900.withValues(alpha: 0.4) : Tw.red100,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(BootstrapIcons.clock_history, size: 12, color: fg),
            const SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return HoverBuilder(
      onTap: () {},
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: hover ? (dark ? Tw.gray800 : Tw.gray100) : Colors.transparent,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              BootstrapIcons.bell_fill,
              size: 15,
              color: dark ? Tw.gray400 : Tw.gray500,
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: Tw.red500,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: dark ? Tw.gray900 : Colors.white,
                    width: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuEntry {
  const _MenuEntry(this.key, this.label, this.icon, this.iconColor, this.onTap);
  final String key;
  final String label;
  final IconData icon;
  final Color? iconColor;
  final VoidCallback onTap;
}

/// shadcn `DropdownMenu` (align end, w-44). `null` entries are separators.
/// The trigger is `rounded-lg` (16 px in this theme).
class _UserMenu extends StatelessWidget {
  const _UserMenu({
    required this.header,
    required this.entries,
    required this.child,
    required this.padding,
    this.hoverColor,
  });

  final String header;
  final List<_MenuEntry?> entries;
  final Widget child;
  final EdgeInsets padding;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    final byKey = {for (final e in entries.whereType<_MenuEntry>()) e.key: e};
    return Builder(
      builder: (anchor) => HoverBuilder(
        onTap: () async {
          final k = await showMzMenu<String>(
            anchor,
            width: 176,
            items: [
              // `<DropdownMenuItem class="sm:hidden font-bold text-xs">` — an
              // item without a handler (closes the menu).
              if (!anchor.isSm)
                MzMenuItem<String>(
                  textStyle: const TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w700,
                  ),
                  child: Text(header),
                ),
              for (final e in entries)
                if (e == null)
                  const MzMenuSeparator<String>()
                else
                  MzMenuItem<String>(
                    value: e.key,
                    // `<i class="bi … mr-2" />` inside the item's `gap-2`.
                    child: Row(
                      children: [
                        Icon(e.icon, color: e.iconColor),
                        const SizedBox(width: 16),
                        Flexible(child: Text(e.label)),
                      ],
                    ),
                  ),
            ],
          );
          if (k != null) byKey[k]?.onTap();
        },
        builder: (context, hover) => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: padding,
          decoration: BoxDecoration(
            color: hover && hoverColor != null
                ? hoverColor
                : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// shadcn `SelectTrigger` restyled by the header (`h-8 text-xs gap-1 px-2
/// rounded-lg border`, white / gray-800). The kit's `data-[size=default]:h-9`
/// out-ranks `h-8`, so it is 36 px tall; `dark:bg-input/30` out-ranks
/// `bg-gray-800`. Ends with the kit's ChevronDown (`size-4 opacity-50`).
class _SelectTrigger extends StatelessWidget {
  const _SelectTrigger({
    required this.children,
    required this.onTap,
    this.width,
    this.minWidth = 0,
    this.maxWidth = double.infinity,
  });

  final List<Widget> children;
  final ValueChanged<BuildContext> onTap;
  final double? width;
  final double minWidth;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    const input = Color(0xFF303540); // --input (dark)
    final fg = dark ? Colors.white : Tw.gray900;
    return Builder(
      builder: (anchor) => HoverBuilder(
        onTap: () => onTap(anchor),
        cursor: SystemMouseCursors.basic,
        builder: (context, hover) => Container(
          height: 36,
          width: width,
          constraints: BoxConstraints(minWidth: minWidth, maxWidth: maxWidth),
          padding: const EdgeInsets.only(left: 8, right: 6),
          decoration: BoxDecoration(
            color: dark
                ? input.withValues(alpha: hover ? 0.5 : 0.3)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dark ? Tw.gray700 : Tw.gray200),
            boxShadow: MzShadow.xs,
          ),
          child: DefaultTextStyle.merge(
            style: TextStyle(fontSize: 12, color: fg),
            child: IconTheme.merge(
              data: IconThemeData(size: 14, color: fg),
              child: Row(
                mainAxisSize: width == null
                    ? MainAxisSize.min
                    : MainAxisSize.max,
                children: [
                  ...children,
                  const SizedBox(width: 4),
                  Opacity(
                    opacity: 0.5,
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: Mz.mutedForeground(dark),
                    ),
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

class _TeacherClassSelect extends StatelessWidget {
  const _TeacherClassSelect({
    required this.classes,
    required this.loading,
    required this.selectedClass,
    required this.onSelect,
  });

  final List<Map<String, dynamic>> classes;
  final bool loading;
  final Map<String, dynamic>? selectedClass;
  final ValueChanged<Map<String, dynamic>> onSelect;

  static String _label(Map<String, dynamic> c) {
    for (final k in ['year', 'name']) {
      if (jsTruthy(c[k])) return jsDisplay(c[k]);
    }
    return 'Class ${jsDisplay(c['id'])}';
  }

  @override
  Widget build(BuildContext context) {
    // selectedClassId = String(selectedClass?.id || '')
    final selectedId = jsTruthy(selectedClass?['id'])
        ? jsStr(selectedClass!['id'])!
        : '';
    var selectedName = '';
    if (selectedId.isNotEmpty) {
      for (final c in classes) {
        if (jsStr(c['id']) == selectedId) {
          selectedName = jsTruthy(c['year'])
              ? jsDisplay(c['year'])
              : (jsTruthy(c['name']) ? jsDisplay(c['name']) : '');
          break;
        }
      }
    }

    return _SelectTrigger(
      minWidth: 130,
      maxWidth: 160,
      onTap: (anchor) async {
        final i = await showMzMenu<int>(
          anchor,
          minWidth: 160,
          maxHeight: 240, // max-h-60
          items: [
            for (var i = 0; i < classes.length; i++)
              MzMenuItem<int>(
                value: i,
                checked: jsStr(classes[i]['id']) == selectedId,
                child: Row(
                  children: [
                    const Icon(BootstrapIcons.journal_text, color: Tw.sky500),
                    const SizedBox(width: 8),
                    Flexible(child: Text(_label(classes[i]))),
                  ],
                ),
              ),
            if (classes.isEmpty && !loading)
              const MzMenuNote<int>(
                child: Text(
                  'No classes found',
                  style: TextStyle(fontSize: 12, color: Tw.gray400),
                ),
              ),
            if (loading)
              const MzMenuNote<int>(
                child: _Pulse(
                  child: Text(
                    'Loading...',
                    style: TextStyle(fontSize: 12, color: Tw.gray400),
                  ),
                ),
              ),
          ],
        );
        if (i != null) onSelect(classes[i]);
      },
      children: [
        const Icon(BootstrapIcons.book),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            selectedName.isNotEmpty ? selectedName : 'Select Class',
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _LanguageSelect extends ConsumerWidget {
  const _LanguageSelect({required this.languages});
  final List<Map<String, dynamic>> languages;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(sessionProvider.select((s) => s.language.code));
    final selectedCode = selected.isNotEmpty ? selected : 'en';
    Map<String, dynamic>? found;
    for (final l in languages) {
      if (asString(l['code']) == selectedCode) {
        found = l;
        break;
      }
    }
    final code = (jsTruthy(found?['code']) ? asString(found!['code'])! : 'EN')
        .toUpperCase();

    return _SelectTrigger(
      width: 64, // w-16
      onTap: (anchor) async {
        final val = await showMzMenu<String>(
          anchor,
          minWidth: 128,
          height: MediaQuery.sizeOf(context).height * 0.4, // h-[40vh]
          items: [
            for (final l in languages)
              MzMenuItem<String>(
                value: jsTruthy(l['code'])
                    ? asString(l['code'])
                    : jsStr(l['id']),
                checked: asString(l['code']) == selectedCode,
                child: Row(
                  children: [
                    const Icon(BootstrapIcons.translate),
                    const SizedBox(width: 4),
                    Flexible(child: Text(jsDisplay(l['name']))),
                  ],
                ),
              ),
          ],
        );
        if (val == null) return;
        for (final l in languages) {
          if (asString(l['code']) == val) {
            ref
                .read(mathZoroProvider.notifier)
                .setLanguage(AppLanguage.fromJson(l));
            return;
          }
        }
      },
      children: [
        const Icon(BootstrapIcons.translate),
        const SizedBox(width: 4),
        Text(
          code.length > 2 ? code.substring(0, 2) : code,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

/// 3-way color mode toggle (light → dark → system).
class _ColorModeButton extends ConsumerWidget {
  const _ColorModeButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(colorModeProvider);
    final dark = context.isDark;
    final (icon, color, label) = switch (mode) {
      ColorModePref.light => (
        BootstrapIcons.sun_fill,
        Tw.yellow500,
        'Light Mode',
      ),
      ColorModePref.dark => (BootstrapIcons.moon_fill, Tw.blue400, 'Dark Mode'),
      ColorModePref.system => (
        BootstrapIcons.laptop,
        Tw.gray400,
        'System Mode',
      ),
    };
    return MzTooltip(
      message: label,
      child: HoverBuilder(
        onTap: () => ref.read(colorModeProvider.notifier).cycle(),
        builder: (context, hover) => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: hover
                ? (dark ? Tw.gray800 : Tw.gray100)
                : Colors.transparent,
          ),
          child: Icon(icon, size: 15, color: color),
        ),
      ),
    );
  }
}

// ─── <aside> sidebar ────────────────────────────────────────────────────────

class _MzSidebar extends ConsumerWidget {
  const _MzSidebar({
    required this.items,
    required this.location,
    required this.open,
    required this.mobileOrMedium,
    required this.isStudent,
    required this.username,
    required this.role,
    required this.onNavigate,
    this.showLogo = true,
  });

  final List<MzNavItem> items;
  final String location;
  final bool open;
  final bool mobileOrMedium;
  final bool isStudent;
  final String username;
  final String role;
  final ValueChanged<MzNavItem> onNavigate;

  /// Draw the ZSL logo in the 72 px logo row (the lg+ shell paints it as an
  /// overlay instead, see [_MathZoroShellState.build]).
  final bool showLogo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dark = context.isDark;
    final divider = dark ? Tw.gray800 : Tw.gray100;
    // Nav labels are `lg:hidden` while the lg+ sidebar is collapsed.
    final showLabels = open || mobileOrMedium;
    final collapsedDesktop = !open && !mobileOrMedium;

    return Container(
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        color: dark ? Tw.gray900 : Colors.white,
        border: Border(
          right: BorderSide(color: dark ? Tw.gray800 : Tw.gray200),
        ),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          // While the lg+ sidebar widens, lay the content out at its final
          // width and let the animating box clip it.
          final w = open ? math.max(c.maxWidth, 259.0) : c.maxWidth;
          return OverflowBox(
            alignment: Alignment.topLeft,
            minWidth: w,
            maxWidth: w,
            child: SafeArea(
              top: false,
              left: false,
              right: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Container(
                    height: 72,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border(bottom: BorderSide(color: divider)),
                    ),
                    child: showLogo
                        ? Center(
                            child: Image.asset(
                              'assets/images/zsl_logo.png',
                              height: 60,
                              fit: BoxFit.contain,
                              semanticLabel: 'Zero Science Lab',
                            ),
                          )
                        : null,
                  ),
                  // Nav links
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 20,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < items.length; i++) ...[
                            if (i > 0) const SizedBox(height: 4),
                            _SidebarButton(
                              icon: items[i].icon,
                              label: showLabels ? items[i].label : null,
                              tooltip: open ? null : items[i].label,
                              active: items[i].isActive(location),
                              isStudent: isStudent,
                              onTap: () => onNavigate(items[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (isStudent)
                    // Student: Appearance toggle at bottom
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: divider)),
                      ),
                      child: _SidebarButton(
                        icon: BootstrapIcons.sun_fill,
                        iconColor: Tw.amber400,
                        label: open ? 'Appearance' : null,
                        isStudent: isStudent,
                        onTap: () =>
                            ref.read(colorModeProvider.notifier).cycle(),
                      ),
                    )
                  else
                    // Teacher/Admin/Institute: user profile at bottom
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        border: Border(top: BorderSide(color: divider)),
                      ),
                      child: collapsedDesktop
                          // justify-center: the 40 px avatar overflows the
                          // 27 px strip evenly on both sides.
                          ? const SizedBox(
                              height: 40,
                              child: OverflowBox(
                                minWidth: 40,
                                maxWidth: 40,
                                child: _SidebarAvatar(),
                              ),
                            )
                          : Row(
                              children: [
                                const _SidebarAvatar(),
                                if (open) ...[
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          username,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            height: 1.25,
                                            color: dark
                                                ? Colors.white
                                                : Tw.gray800,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          role.toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            letterSpacing: 0.5,
                                            color: Tw.sky500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// `https://i.pravatar.cc/40?img=12` with `ring-2 ring-sky-400/30`.
class _SidebarAvatar extends StatelessWidget {
  const _SidebarAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Mz.sky400.withValues(alpha: 0.3), spreadRadius: 2),
        ],
      ),
      child: ClipOval(
        child: Image.network(
          'https://i.pravatar.cc/40?img=12',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          semanticLabel: 'Avatar',
          errorBuilder: (_, _, _) => const SizedBox(width: 40, height: 40),
        ),
      ),
    );
  }
}

/// A sidebar row (`rounded-xl px-5 py-3.5 text-[15px] font-medium`): nav
/// links and the student "Appearance" toggle. [label] null hides the text.
class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.icon,
    required this.onTap,
    required this.isStudent,
    this.label,
    this.tooltip,
    this.active = false,
    this.iconColor,
  });

  final IconData icon;
  final String? label;

  /// `:title="!sidebarOpen ? item.label : ''"`.
  final String? tooltip;
  final bool active;
  final bool isStudent;
  final Color? iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final button = HoverBuilder(
      onTap: onTap,
      builder: (context, hover) {
        final Color fg;
        final Color bg;
        if (active) {
          fg = dark
              ? (isStudent ? Mz.green400 : Mz.sky400)
              : (isStudent ? Tw.green600 : Mz.sky600);
          bg = isStudent
              ? Colors.transparent
              : (dark ? Tw.sky500.withValues(alpha: 0.1) : Tw.sky50);
        } else {
          fg = dark
              ? (hover ? Tw.gray200 : Tw.gray400)
              : (hover ? Tw.gray700 : Tw.gray500);
          bg = hover ? (dark ? Tw.gray800 : Tw.gray50) : Colors.transparent;
        }
        return Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              // The 19 px icon overflows the 4 px content box of the 68 px
              // strip on the web; only the left padding is kept here.
              padding: EdgeInsets.fromLTRB(20, 14, label != null ? 20 : 0, 14),
              // rounded-xl → calc(var(--radius) + 4px) = 20 px in this theme.
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SizedBox(
                height: 28,
                child: Row(
                  children: [
                    Icon(icon, size: 19, color: iconColor ?? fg),
                    if (label != null) ...[
                      const SizedBox(width: 16),
                      Flexible(
                        child: Text(
                          label!,
                          maxLines: 1,
                          softWrap: false,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            color: fg,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            // Active bar: students on the right in green, staff on the left in sky.
            if (active)
              Positioned(
                top: 8,
                bottom: 8,
                left: isStudent ? null : 0,
                right: isStudent ? 0 : null,
                width: 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: isStudent ? Tw.green500 : Tw.sky500,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
          ],
        );
      },
    );
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}
