import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../core/utils/pagination.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import 'upgrade_plan_logic.dart';

/// The `zslClasses` / `zslPagination` slice of `useUserStore` used by
/// Upgradeplan.vue.
class UpgradePlanState {
  const UpgradePlanState({this.zslClasses = const [], this.zslPagination});

  final List<Map<String, dynamic>> zslClasses;
  final PageMeta? zslPagination;
}

/// `fetchZslClassesplan`, `createPaymentOrderAction` and
/// `getPaymentStatusAction`, ported 1:1.
class UpgradePlanController extends Notifier<UpgradePlanState> {
  @override
  UpgradePlanState build() => const UpgradePlanState();

  List<Map<String, dynamic>> _maps(dynamic list) => [for (final e in asList(list)) ?asMap(e)];

  /// `fetchZslClassesplan(paginate, page)` — errors are swallowed like the
  /// web (the API client already showed the toast).
  Future<void> fetchZslClassesplan(bool paginate, [int page = 1]) async {
    try {
      final response = await ref.read(instituteServiceProvider).getzslclass(paginate, page);
      final meta = asMap(asMap(response)?['data']);
      if (paginate && meta != null && jsTruthy(meta['data'])) {
        state = UpgradePlanState(
          zslClasses: _maps(meta['data']),
          zslPagination: PageMeta(
            currentPage: asInt(meta['current_page']) ?? 1,
            lastPage: asInt(meta['last_page']) ?? 1,
            perPage: asInt(meta['per_page']) ?? 10,
            total: asInt(meta['total']) ?? 0,
          ),
        );
      } else {
        // Web: `this.zslClasses = response || []`. A non-array body would
        // break the page's `.filter`, so take the list out of it.
        state = UpgradePlanState(zslClasses: _maps(unwrapList(response)));
      }
    } catch (_) {}
  }

  /// `createPaymentOrderAction(payload)` — `POST /payment/create`.
  Future<dynamic> createPaymentOrderAction({
    required String type,
    List<String>? subscriptionPlanIds,
    List<String>? zslPlanIds,
    String? referralCode,
  }) async {
    final payload = buildPaymentOrderPayload(
      ref.read(sessionProvider).userInfo,
      type: type,
      subscriptionPlanIds: subscriptionPlanIds,
      zslPlanIds: zslPlanIds,
      referralCode: referralCode,
    );
    return await ref.read(upgradePlanServiceProvider).createPaymentOrder(payload);
  }

  /// `getPaymentStatusAction(transaction_id)` — `POST /payment/status`
  /// (`{order_id: transaction_id}`). [silent] skips the API client toasts
  /// (native automatic re-check only).
  Future<dynamic> getPaymentStatusAction(String transactionId, {bool silent = false}) async {
    if (transactionId.isEmpty) throw const ApiError('Transaction ID is required');
    final service = ref.read(upgradePlanServiceProvider);
    return silent
        ? await service.getPaymentStatusSilent(transactionId)
        : await service.getPaymentStatus(transactionId);
  }
}

final upgradePlanControllerProvider =
    NotifierProvider<UpgradePlanController, UpgradePlanState>(UpgradePlanController.new);
