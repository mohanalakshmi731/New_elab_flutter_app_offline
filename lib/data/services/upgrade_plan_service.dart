import 'package:dio/dio.dart' show ListFormat, Options;

import '../../core/network/api_client.dart';

/// Port of src/service/upgradeplan.ts.
class UpgradePlanService {
  UpgradePlanService(this._api);
  final ApiClient _api;

  Future<dynamic> createPaymentOrder(Map<String, dynamic> payload) =>
      _api.post('/payment/create', data: payload);

  /// Note: [transactionId] is sent as `order_id`.
  Future<dynamic> getPaymentStatus(Object transactionId) =>
      _api.post('/payment/status', data: {'order_id': transactionId});

  /// [getPaymentStatus] without the automatic response/error toasts. Native
  /// only: used for the automatic re-check when the app regains focus after
  /// the external payment page (the web has no equivalent).
  Future<dynamic> getPaymentStatusSilent(Object transactionId) =>
      _api.post('/payment/status', data: {'order_id': transactionId}, silent: true);

  Future<dynamic> getPaymentList(Object instituteId, [Object? classesId]) =>
      _api.get('/payment/list', query: {
        'institute_id': instituteId,
        'classes_id': classesId,
      });

  Future<dynamic> getPaymentById(Object id) => _api.get('/payment/$id');

  /// Array params are serialised the axios way (`zsl_plan_ids[]=1&...`),
  /// not dio's default repeated-key format.
  Future<dynamic> validateReferralCode(Map<String, dynamic> payload) =>
      _api.get('/validate-referral-code',
          query: {
            'referral_code': payload['referral_code'],
            'platform': payload['platform'],
            'plan_type': payload['plan_type'],
            'zsl_plan_ids': payload['zsl_plan_ids'],
            'subscription_plan_ids': payload['subscription_plan_ids'],
            'app_store_bundle_id': payload['app_store_bundle_id'],
          },
          options: Options(listFormat: ListFormat.multiCompatible));
}
