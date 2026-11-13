import '../../core/network/api_client.dart';

/// Port of src/service/dashboard.service.ts.
class DashboardService {
  DashboardService(this._api);
  final ApiClient _api;

  Future<dynamic> getCounts(Object instituteId) =>
      _api.get('/institute/$instituteId/counts',
          query: {'institute_id': instituteId});
}
