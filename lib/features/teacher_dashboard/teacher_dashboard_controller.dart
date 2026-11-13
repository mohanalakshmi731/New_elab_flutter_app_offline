import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';

/// The `useUserStore` slice used by `teachersdashboardpage.vue`:
/// `ongoingschedules` (`getNextSchedules`) and `schedules` (`getSchedules`).
class TeacherDashboardState {
  const TeacherDashboardState({this.ongoingschedules = const [], this.schedules = const []});

  final List<dynamic> ongoingschedules;
  final List<dynamic> schedules;

  TeacherDashboardState copyWith({List<dynamic>? ongoingschedules, List<dynamic>? schedules}) =>
      TeacherDashboardState(
        ongoingschedules: ongoingschedules ?? this.ongoingschedules,
        schedules: schedules ?? this.schedules,
      );
}

class TeacherDashboardController extends Notifier<TeacherDashboardState> {
  @override
  TeacherDashboardState build() => const TeacherDashboardState();

  SessionState get _session => ref.read(sessionProvider);

  /// `getNextSchedules()` — `GET /schedule/next`; never throws (errors give
  /// `[]`, the API client already toasted them).
  Future<List<dynamic>> getNextSchedules() async {
    final instituteId = _session.userInfo?.instituteId;
    if (!jsTruthy(instituteId)) return const [];
    try {
      final res = await ref.read(schedulesServiceProvider).getNext('$instituteId');
      final list = res is List ? res : [res];
      state = state.copyWith(ongoingschedules: list);
      return list;
    } catch (_) {
      return const [];
    }
  }

  /// `getSchedules(filters)` — `GET /schedule`; students always send their
  /// own batch. Like the store action it fills `schedules` and returns
  /// nothing (`undefined` → `null`).
  Future<Object?> getSchedules([Map<String, dynamic> filters = const {}]) async {
    final instituteId = _session.userInfo?.instituteId;
    if (!jsTruthy(instituteId)) return null;

    Object? batchIdToSend = filters['batch_id'];
    if (_session.role == Role.student) {
      batchIdToSend = _session.batchDetails?.id?.toString() ?? filters['batch_id'];
    }

    final params = <String, dynamic>{
      'institute_id': '$instituteId',
      ...filters,
      'batch_id': batchIdToSend,
    };

    final res = await ref.read(schedulesServiceProvider).get(params);
    final data = asMap(res)?['data'];
    state = state.copyWith(schedules: res is List ? res : (jsTruthy(data) ? asList(data) : const []));
    return null;
  }
}

final teacherDashboardControllerProvider =
    NotifierProvider<TeacherDashboardController, TeacherDashboardState>(TeacherDashboardController.new);
