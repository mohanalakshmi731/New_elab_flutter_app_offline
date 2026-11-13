import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/config/env.dart';
import '../data/models/session.dart';
import '../features/activity_reports/activity_reports_page.dart';
import '../features/auth/login_page.dart';
import '../features/batches/batch_list_page.dart';
import '../features/class_course/class_course_create_page.dart';
import '../features/classes/class_list_page.dart';
import '../features/class_course/class_create_page.dart';
import '../features/courses/course_create_page.dart';
import '../features/dashboard/dashboard_page.dart';
import '../features/exam_manage/create_question_page.dart';
import '../features/exam_manage/edit_exam_page.dart';
import '../features/exam_manage/exam_attempts_page.dart';
import '../features/exam_manage/exam_results_page.dart';
import '../features/exam_manage/view_exam_page.dart';
import '../features/exams/exam_page.dart';
import '../features/institutes/institute_create_page.dart';
import '../features/institutes/institute_list_page.dart';
import '../features/institutes/invitation_list_page.dart';
import '../features/library/activity_library_page.dart';
import '../features/library/library_page.dart';
import '../features/library/new_library_page.dart';
import '../features/math_play/class_math_page.dart';
import '../features/math_play/math_play_page.dart';
import '../features/mathzoro/mathzoro_class_change_page.dart';
import '../features/mathzoro/mathzoro_login_page.dart';
import '../features/mathzoro/mathzoro_shell.dart';
import '../features/mathzoro/student_dashboard_page.dart';
import '../features/new_exams/new_exams_page.dart';
import '../features/new_questions/new_questions_page.dart';
import '../features/mathzoro_zone/student_math_zone_page.dart';
import '../features/plans/institute_plan_create_page.dart';
import '../features/plans/institute_plan_list_page.dart';
import '../features/plans/institute_plan_update_page.dart';
import '../features/plans/subscription_page.dart';
import '../features/plans/zsl_plan_list_page.dart';
import '../features/plans/zsl_plan_page.dart';
import '../features/play_zone/play_zone_page.dart';
import '../features/questions/questions_list_page.dart';
import '../features/schedules/schedules_page.dart';
import '../features/shell/dashboard_shell.dart';
import '../features/signup/self_signup_page.dart';
import '../features/signup/signup_page.dart';
import '../features/student_activity/student_activity_page.dart';
import '../features/student_dashboard_layout/student_dashboard_layout_page.dart';
import '../features/student_payment/student_payment_page.dart';
import '../features/student_reports/student_reports_page.dart';
import '../features/student_science_zone/student_science_zone_page.dart';
import '../features/take_exam/start_exam_page.dart';
import '../features/teacher_dashboard/teachers_dashboard_page.dart';
import '../features/teacher_schedules/teacher_schedules_page.dart';
import '../features/teacher/teacher_course_page.dart';
import '../features/upgrade/upgrade_plan_page.dart';
import '../features/users/planwise_student_list_page.dart';
import '../features/zones/zones_page.dart';
import '../features/zoom/zoom_full_page.dart';
import '../features/users/user_activity_log_page.dart';
import '../features/users/user_create_page.dart';
import '../features/users/user_list_page.dart';
import '../features/users/user_profile_page.dart';
import '../state/providers.dart';

/// Port of `src/router/index.ts` + `src/router/mathzoro.ts`.
///
/// The flavor (`IS_MATHZORO`) decides which login/shell is registered,
/// exactly like `VITE_IS_MATHZORO` did on the web.
class AppRoutes {
  AppRoutes._();
  static const login = '/login';
  static const mathzoroLogin = '/mathzorostudentlogin';
  static const dashboard = '/dashboard';
  static const mathzoroHome = '/newlayout/studentdashboard';
  static const classChange = '/classchange';

  static String get loginPath => Env.isMathzoro ? mathzoroLogin : login;

  static String homeFor(SessionState s) {
    if (Env.isMathzoro) return mathzoroHome;
    if (s.role == Role.student && (s.userInfo?.isMathZoro ?? false)) return mathzoroHome;
    return dashboard;
  }
}

/// A ported screen inside a shell (no transition, like the web's router-view).
GoRoute _page(String path, Widget Function(GoRouterState state) build) => GoRoute(
      path: path,
      pageBuilder: (context, state) => NoTransitionPage(key: state.pageKey, child: build(state)),
    );


final _rootKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  // Re-run redirects whenever the user logs in/out (or a 401 clears the session).
  final authChanged = ValueNotifier<bool>(ref.read(sessionProvider).isLoggedIn);
  ref.listen<bool>(sessionProvider.select((s) => s.isLoggedIn),
      (_, loggedIn) => authChanged.value = loggedIn);
  ref.onDispose(authChanged.dispose);

  final isMathzoro = Env.isMathzoro;

  final routes = <RouteBase>[
    GoRoute(path: '/', redirect: (_, _) => AppRoutes.loginPath),

    if (isMathzoro) ...[
      GoRoute(
        path: AppRoutes.mathzoroLogin,
        builder: (_, _) => const MathZoroLoginPage(),
      ),
      ShellRoute(
        builder: (context, state, child) =>
            MathZoroShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: '/newlayout',
            redirect: (_, state) =>
                state.uri.path == '/newlayout' ? AppRoutes.mathzoroHome : null,
            routes: [
              GoRoute(
                path: 'studentdashboard',
                pageBuilder: (_, state) => NoTransitionPage(
                    key: state.pageKey, child: const MathZoroStudentDashboardPage()),
              ),
              _page('MyProfile', (_) => const UserProfilePage()),
              _page('newmathzone', (_) => const StudentMathZonePage()),
              _page('playzone', (_) => const PlayZonePage()),
              _page('studentupgradeplan',
                  (s) => StudentPaymentPage(classId: s.uri.queryParameters['class_id'])),
              _page('reports', (_) => const StudentReportsPage()),
              _page('studentactivitypage',
                  (s) => StudentActivityPage(fromPlayZone: s.uri.queryParameters['fromPlayZone'])),
            ],
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.classChange,
        builder: (_, _) => const MathZoroClassChangePage(),
      ),
    ] else ...[
      GoRoute(path: AppRoutes.login, builder: (_, _) => const LoginPage()),
    ],

    // ── Common routes (both flavors) ──
    // `/signup/:code?` — the page reads params.code, then query.code.
    GoRoute(
      path: '/signup',
      builder: (_, s) => SignupPage(code: s.uri.queryParameters['code']),
      routes: [
        GoRoute(
          path: ':code',
          builder: (_, s) =>
              SignupPage(code: s.pathParameters['code'] ?? s.uri.queryParameters['code']),
        ),
      ],
    ),
    GoRoute(
      path: '/selfsignup',
      builder: (_, s) => SelfSignupPage(code: s.uri.queryParameters['code']),
    ),
    GoRoute(
      path: '/startexam',
      builder: (_, s) => StartExamPage(query: s.uri.queryParameters),
    ),

    // ── eLabs shell (DashboardLayout) ──
    if (!isMathzoro)
      ShellRoute(
        builder: (context, state, child) =>
            DashboardShell(location: state.uri.path, child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (_, state) =>
                NoTransitionPage(key: state.pageKey, child: const DashboardPage()),
          ),
          GoRoute(path: '/courselist', redirect: (_, _) => '/classlist?tab=courses'),
          // Phase 2 — users, institutes & plans
          _page('/userlist', (_) => const UserListPage()),
          _page('/userscreate', (_) => const UserCreatePage()),
          _page('/useractivitylog', (_) => const UserActivityLogPage()),
          _page('/MyProfile', (_) => const UserProfilePage()),
          _page('/studentslistplanwise',
              (s) => PlanwiseStudentListPage(query: s.uri.queryParameters)),
          _page('/instituteslist', (_) => const InstituteListPage()),
          _page('/Institutescreate', (_) => const InstituteCreatePage()),
          _page('/Invitationslist', (s) => InvitationListPage(query: s.uri.queryParameters)),
          _page('/institutesplanList', (_) => const InstitutePlanListPage()),
          _page('/institutesplanCreate', (_) => const InstitutePlanCreatePage()),
          _page('/institutesplanupdate/:id',
              (s) => InstitutePlanUpdatePage(id: s.pathParameters['id'] ?? '')),
          _page('/zslplan', (_) => const ZslPlanPage()),
          _page('/zslplanlist', (_) => const ZslPlanListPage()),
          _page('/subscription', (_) => const SubscriptionPage()),
          // Phase 3 — classes & courses
          _page('/classlist', (s) => ClassListPage(tab: s.uri.queryParameters['tab'])),
          // Web registers /instructorlist twice; vue-router matches the first (Batchlist).
          _page('/instructorlist', (_) => const BatchListPage()),
          _page('/coursecreate', (_) => const CourseCreatePage()),
          _page('/classcreate', (_) => const ClassCreatePage()),
          _page('/classcoursecreate', (_) => const ClassCourseCreatePage()),
          _page('/newcoursepage', (_) => const TeacherCoursePage()),
          // Phase 4 — schedules & live classes
          _page('/schedules', (_) => const SchedulesPage()),
          _page('/teachersdashboardpage', (_) => const TeachersDashboardPage()),
          _page('/teacherschedules', (_) => const TeacherSchedulesPage()),
          _page('/zoom-full',
              (s) => ZoomFullPage(meeting: s.extra is Map ? Map<String, dynamic>.from(s.extra as Map) : null)),
          // Phase 5 — exams & question bank
          _page('/exams', (_) => const ExamPage()),
          _page('/exams/createexam', (_) => const CreateQuestionPage()),
          _page('/exams/question/edit/:id', (s) => CreateQuestionPage(id: s.pathParameters['id'])),
          _page('/editexams/:id', (s) => EditExamPage(id: s.pathParameters['id'] ?? '')),
          _page('/viewexams/:id', (s) => ViewExamPage(id: s.pathParameters['id'] ?? '')),
          _page('/examattempts/:id', (s) => ExamAttemptsPage(id: s.pathParameters['id'] ?? '')),
          _page('/results/:attemptId',
              (s) => ExamResultsPage(attemptId: s.pathParameters['attemptId'] ?? '')),
          _page('/newexams', (_) => const NewExamsPage()),
          _page('/questions', (_) => const QuestionsListPage()),
          _page('/newquestions', (_) => const NewQuestionsPage()),
          // Phase 6 — library & zones
          _page('/library', (_) => const LibraryPage()),
          _page('/activitylibrary', (_) => const ActivityLibraryPage()),
          _page('/newlibrary', (_) => const NewLibraryPage()),
          _page('/classmath', (_) => const ClassMathPage()),
          _page('/mathplay', (_) => const MathPlayPage()),
          _page('/studentactivitypage',
              (s) => StudentActivityPage(fromPlayZone: s.uri.queryParameters['fromPlayZone'])),
          _page('/studentsciencezone', (_) => const StudentScienceZonePage()),
          _page('/studentupgradeplan',
              (s) => StudentPaymentPage(classId: s.uri.queryParameters['class_id'])),
          _page('/studentdashboardlayout', (_) => const StudentDashboardLayoutPage()),
          _page('/activityreport', (_) => const ActivityReportsPage()),
          _page('/elabsmathzone', (_) => const ElabsMathZonePage()),
          _page('/elabssciencezone', (_) => const ElabsScienceZonePage()),
          _page('/upgradeplan',
              (s) => UpgradePlanPage(transactionId: s.uri.queryParameters['transaction_id'])),
        ],
      ),
  ];

  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/',
    refreshListenable: authChanged,
    routes: routes,
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final path = state.uri.path;
      final loginPath = AppRoutes.loginPath;
      final isPublic = path == loginPath ||
          path == '/signup' ||
          path.startsWith('/signup/') ||
          path == '/selfsignup' ||
          path == '/startexam';

      if (!session.isLoggedIn) {
        return isPublic || path == '/' ? (path == '/' ? loginPath : null) : loginPath;
      }

      if (path == '/') return AppRoutes.homeFor(session);
      if (path == '/startexam') return null;

      // MathZoro students must stay inside /newlayout (router.beforeEach).
      if (session.role == Role.student && (session.userInfo?.isMathZoro ?? false)) {
        final allowed = path.startsWith('/newlayout') ||
            path == AppRoutes.classChange ||
            path == loginPath;
        if (!allowed) return AppRoutes.mathzoroHome;
      }
      return null;
    },
  );
});
