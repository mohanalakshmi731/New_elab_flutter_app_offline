import '../../core/network/api_client.dart';

/// Port of src/service/appsubscription.ts.
class AppSubscriptionService {
  AppSubscriptionService(this._api);
  final ApiClient _api;

  Future<dynamic> createappPlan(Map<String, dynamic> payload) =>
      _api.post('/subscription/plan', data: payload);

  Future<dynamic> getAppPlans([Map<String, dynamic>? params]) =>
      _api.get('/subscription/plan', query: params);

  Future<dynamic> getAppPlanById(Object planId) =>
      _api.get('/subscription/plan/$planId');

  /// Update subscription plan.
  Future<dynamic> updateAppPlan(Object id, Map<String, dynamic> payload) =>
      _api.patch('/subscription/plan/$id', data: payload);
}
