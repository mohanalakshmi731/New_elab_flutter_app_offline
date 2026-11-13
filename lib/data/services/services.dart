/// Barrel for every HTTP service (ports of `src/service/*.ts`) plus one
/// Riverpod provider per service.
///
/// `authServiceProvider` lives in `lib/state/providers.dart`.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../state/providers.dart'
    show apiClientProvider, contentCacheProvider, sessionProvider;
import 'activity_tracking_service.dart';
import 'app_subscription_service.dart';
import 'batch_service.dart';
import 'class_service.dart';
import 'course_service.dart';
import 'dashboard_service.dart';
import 'exams_service.dart';
import 'game_tokens_service.dart';
import 'institute_service.dart';
import 'instructor_service.dart';
import 'invitation_service.dart';
import 'question_service.dart';
import 'schedules_service.dart';
import 'student_service.dart';
import 'upgrade_plan_service.dart';
import 'usage_tracking_service.dart';
import 'user_service.dart';
import 'zoom_service.dart';
import 'zsl_service.dart';

export 'activity_tracking_service.dart';
export 'app_subscription_service.dart';
export 'auth_service.dart';
export 'batch_service.dart';
export 'class_service.dart';
export 'course_service.dart';
export 'dashboard_service.dart';
export 'exams_service.dart';
export 'game_tokens_service.dart';
export 'institute_service.dart';
export 'instructor_service.dart';
export 'invitation_service.dart';
export 'question_service.dart';
export 'schedules_service.dart';
export 'student_service.dart';
export 'upgrade_plan_service.dart';
export 'usage_tracking_service.dart';
export 'user_service.dart';
export 'zoom_service.dart';
export 'zsl_service.dart';

final classServiceProvider =
    Provider<ClassService>((ref) => ClassService(ref.watch(apiClientProvider)));

final courseServiceProvider = Provider<CourseService>(
    (ref) => CourseService(ref.watch(apiClientProvider)));

final schedulesServiceProvider = Provider<SchedulesService>(
    (ref) => SchedulesService(ref.watch(apiClientProvider)));

/// Reads the session lazily (the web called `useUserStore()` per request).
final studentServiceProvider = Provider<StudentService>((ref) => StudentService(
    ref.watch(apiClientProvider), () => ref.read(sessionProvider)));

/// Reads the session lazily (the web called `useUserStore()` per request).
final instructorServiceProvider = Provider<InstructorService>((ref) =>
    InstructorService(
        ref.watch(apiClientProvider), () => ref.read(sessionProvider)));

/// Reads the session lazily (the web called `useUserStore()` per request).
final userServiceProvider = Provider<UserService>((ref) =>
    UserService(ref.watch(apiClientProvider), () => ref.read(sessionProvider)));

final examsServiceProvider =
    Provider<ExamsService>((ref) => ExamsService(ref.watch(apiClientProvider)));

final questionServiceProvider = Provider<QuestionService>(
    (ref) => QuestionService(ref.watch(apiClientProvider)));

final batchServiceProvider =
    Provider<BatchService>((ref) => BatchService(ref.watch(apiClientProvider)));

final invitationServiceProvider = Provider<InvitationService>(
    (ref) => InvitationService(ref.watch(apiClientProvider)));

final instituteServiceProvider = Provider<InstituteService>(
    (ref) => InstituteService(ref.watch(apiClientProvider)));

/// Reads the session lazily (the web called `useUserStore()` per request).
final zslServiceProvider = Provider<ZslService>((ref) => ZslService(
    ref.watch(apiClientProvider), () => ref.read(sessionProvider),
    cache: ref.watch(contentCacheProvider)));

final upgradePlanServiceProvider = Provider<UpgradePlanService>(
    (ref) => UpgradePlanService(ref.watch(apiClientProvider)));

final activityTrackingServiceProvider = Provider<ActivityTrackingService>(
    (ref) => ActivityTrackingService(ref.watch(apiClientProvider),
        cache: ref.watch(contentCacheProvider)));

final usageTrackingServiceProvider = Provider<UsageTrackingService>(
    (ref) => UsageTrackingService(ref.watch(apiClientProvider)));

final zoomServiceProvider =
    Provider<ZoomService>((ref) => ZoomService(ref.watch(apiClientProvider)));

final gameTokensServiceProvider = Provider<GameTokensService>(
    (ref) => GameTokensService(ref.watch(apiClientProvider)));

final appSubscriptionServiceProvider = Provider<AppSubscriptionService>(
    (ref) => AppSubscriptionService(ref.watch(apiClientProvider)));

final dashboardServiceProvider = Provider<DashboardService>(
    (ref) => DashboardService(ref.watch(apiClientProvider)));
