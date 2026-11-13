import '../../core/network/api_client.dart';
import 'js_compat.dart';

/// Port of src/service/usagetracking.ts.
class UsageTrackingService {
  UsageTrackingService(this._api);
  final ApiClient _api;

  /// Web returned the full AxiosResponse (callers used res.data); this returns the body.
  Future<dynamic> recordUsage(Map<String, dynamic> payload) =>
      _api.post('/usage-tracking/record', data: payload);

  /// Web returned the full AxiosResponse (callers used res.data); this returns the body.
  Future<dynamic> getStudentSelfUsage(Map<String, dynamic> params) =>
      _api.get('/usage-tracking/student-self-usage', query: params);

  /// Web returned the full AxiosResponse (callers used res.data); this returns the body.
  Future<dynamic> getInstructorSelfUsage(Map<String, dynamic> params) =>
      _api.get('/usage-tracking/instructor-self-usage', query: params);

  /// Optional filters are only sent when truthy.
  ///
  /// Web returned the full AxiosResponse (callers used res.data); this returns the body.
  Future<dynamic> getInstructorStudentsUsageV1(Map<String, dynamic> params) =>
      _api.get('/usage-tracking/instructor-students-usage', query: {
        'institute_id': params['institute_id'],
        if (jsTruthy(params['student_id'])) 'student_id': params['student_id'],
        if (jsTruthy(params['class_id'])) 'class_id': params['class_id'],
        if (jsTruthy(params['from'])) 'from': params['from'],
        if (jsTruthy(params['to'])) 'to': params['to'],
      });
}
