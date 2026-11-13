import '../../core/network/api_client.dart';

/// Port of src/service/gametokkens.ts.
class GameTokensService {
  GameTokensService(this._api);
  final ApiClient _api;

  Future<dynamic> getTickets(Object instituteId, Object classId, Object subUserId) =>
      _api.get('/zsl/get-tickets', query: {
        'institute_id': instituteId,
        'classes_id': classId,
        'sub_user_id': subUserId,
      });

  /// POST with an empty (null) body; everything travels as query params.
  Future<dynamic> unlockActivity(
          Object instituteId, Object activityId, Object subUserId) =>
      _api.post('/zsl/unlock-activity', query: {
        'institute_id': instituteId,
        'activity_id': activityId,
        'sub_user_id': subUserId,
      });
}
