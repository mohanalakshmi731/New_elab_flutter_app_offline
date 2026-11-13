import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';

/// The store actions studentpayment.vue maps that no other port has yet:
/// `mathzorogetAppSubscriptionPlans`, `getPaymentListAction`,
/// `getPaymentByIdAction` and `mathzorovalidateReferralCodeAction`.
///
/// The page maps them from `mathuseUserStore`, but both store files use the
/// id `'new-content'` and `useUserStore()` (main.ts) creates the instance
/// first, so at runtime these are the src/store/Userstore.ts actions; they
/// are ported from there. The other mapped actions are already ported:
/// `createPaymentOrderAction` / `getPaymentStatusAction`
/// ([upgradePlanControllerProvider]) and `getUserById` / `getuserbyid`
/// ([usersControllerProvider]).
class StudentPaymentController extends Notifier<void> {
  @override
  void build() {}

  UserInfo? get _userInfo => ref.read(sessionProvider).userInfo;

  /// `mathzorogetAppSubscriptionPlans(payload?)` — `GET /subscription/plan`
  /// for the institute and `userInfo.classes_id`.
  Future<dynamic> mathzorogetAppSubscriptionPlans([Map<String, dynamic>? payload]) async {
    final instituteId = _userInfo?.instituteId?.toString();
    final classId = _userInfo?.classesId;
    if (!jsTruthy(instituteId)) throw const ApiError('Institute ID not available');
    return ref.read(appSubscriptionServiceProvider).getAppPlans({
      'institute_id': instituteId,
      'classes_id': classId,
      ...?payload,
    });
  }

  /// `getPaymentListAction(classId?)` — `GET /payment/list`
  /// (`classId || userInfo.classes_id`).
  Future<dynamic> getPaymentListAction([String? classId]) async {
    final instituteId = _userInfo?.instituteId;
    if (!jsTruthy(instituteId)) throw const ApiError('Institute ID not available');
    final resolvedClassId =
        (classId != null && classId.isNotEmpty) ? classId : _userInfo?.classesId?.toString();
    return ref.read(upgradePlanServiceProvider).getPaymentList('$instituteId', resolvedClassId);
  }

  /// `getPaymentByIdAction(id)` — `GET /payment/{id}`.
  Future<dynamic> getPaymentByIdAction(String id) async {
    if (id.isEmpty) throw const ApiError('Payment ID is required');
    return ref.read(upgradePlanServiceProvider).getPaymentById(id);
  }

  /// `mathzorovalidateReferralCodeAction(payload)` —
  /// `GET /validate-referral-code`.
  Future<dynamic> mathzorovalidateReferralCodeAction(Map<String, dynamic> payload) =>
      ref.read(upgradePlanServiceProvider).validateReferralCode(payload);
}

final studentPaymentControllerProvider =
    NotifierProvider<StudentPaymentController, void>(StudentPaymentController.new);
