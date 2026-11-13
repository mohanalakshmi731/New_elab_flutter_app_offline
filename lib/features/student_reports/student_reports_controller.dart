import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';

/// The two store actions studentreports.vue calls on `useUserStore()`
/// (src/store/Userstore.ts), ported 1:1. Neither writes store state.
class StudentReportsController extends Notifier<void> {
  @override
  void build() {}

  String _instituteId() {
    final id = ref.read(sessionProvider).userInfo?.instituteId?.toString();
    if (!jsTruthy(id)) throw const ApiError('Institute ID not available');
    return id!;
  }

  /// `mathzorogetStudentSelfUsage(from?, to?)` —
  /// `GET /usage-tracking/student-self-usage`; returns the body (the web's
  /// `res.data`): `[{ period, total_usage }]`.
  Future<dynamic> mathzorogetStudentSelfUsage([String? from, String? to]) async {
    final instituteId = _instituteId();
    return ref.read(usageTrackingServiceProvider).getStudentSelfUsage({
      'institute_id': instituteId,
      if (jsTruthy(from)) 'from': from,
      if (jsTruthy(to)) 'to': to,
    });
  }

  /// `mathzorogetActivityChartStats(payload?)` —
  /// `GET /tracking/activity/get/individual` with the truthy
  /// `from` / `to` / `type` / `user_id`.
  Future<dynamic> mathzorogetActivityChartStats([Map<String, dynamic>? payload]) async {
    final instituteId = _instituteId();
    return ref.read(zslServiceProvider).getAllStats({
      'institute_id': instituteId,
      if (jsTruthy(payload?['from'])) 'from': payload!['from'],
      if (jsTruthy(payload?['to'])) 'to': payload!['to'],
      if (jsTruthy(payload?['type'])) 'type': payload!['type'],
      if (jsTruthy(payload?['user_id'])) 'user_id': payload!['user_id'],
    });
  }
}

final studentReportsControllerProvider =
    NotifierProvider<StudentReportsController, void>(StudentReportsController.new);
