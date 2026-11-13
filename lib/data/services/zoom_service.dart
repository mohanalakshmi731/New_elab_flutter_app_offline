import '../../core/network/api_client.dart';

/// Port of src/service/zoom.service.ts.
class ZoomService {
  ZoomService(this._api);
  final ApiClient _api;

  Future<dynamic> getZoomInfo(Object instituteId) =>
      _api.get('/zoom/info', query: {'institute_id': instituteId});

  Future<dynamic> refreshZoomInfo(Map<String, dynamic> payload) =>
      _api.post('/zoom/info/refresh', data: payload);

  Future<dynamic> zoomautofix(Map<String, dynamic> payload) =>
      _api.post('/zoom/manifest/fix', data: payload);

  Future<dynamic> validateZoomInfo(Map<String, dynamic> payload) =>
      _api.post('/zoom/validate', data: payload);
}
