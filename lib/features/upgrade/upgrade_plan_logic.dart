/// Pure logic of `src/components/Upgradeplan.vue` and the payment actions it
/// maps (`createPaymentOrderAction`, `getPaymentStatusAction`), kept free of
/// Flutter so it can be unit tested.
library;

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';

/// `getPlanId(plan)`: `plan?.plan_id ?? plan?.id ?? plan?.class_id ?? null`.
Object? planIdOf(Map<String, dynamic>? plan) =>
    plan?['plan_id'] ?? plan?['id'] ?? plan?['class_id'];

/// JavaScript `Number(v)`.
double jsNumber(Object? v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  if (v is bool) return v ? 1 : 0;
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return 0;
    final hex = RegExp(r'^0[xX][0-9a-fA-F]+$');
    if (hex.hasMatch(s)) return int.parse(s.substring(2), radix: 16).toDouble();
    if (s == 'Infinity' || s == '+Infinity') return double.infinity;
    if (s == '-Infinity') return double.negativeInfinity;
    // Dart accepts forms JS does not ("NaN", "1e", trailing "d"…) – guard them.
    if (!RegExp(r'^[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$').hasMatch(s)) return double.nan;
    return double.parse(s);
  }
  return double.nan;
}

/// JavaScript `Math.round` (halves round towards +∞).
double jsRound(double x) {
  if (x.isNaN || x.isInfinite) return x;
  final r = x.roundToDouble(); // halves away from zero
  if (x < 0 && r - x == -0.5) return r + 1;
  return r;
}

/// JavaScript `String(n)` for a number (`2498` not `2498.0`).
String jsNumberString(num n) {
  if (n is int) return '$n';
  final d = n.toDouble();
  if (d.isNaN) return 'NaN';
  if (d.isInfinite) return d > 0 ? 'Infinity' : '-Infinity';
  if (d == d.truncateToDouble() && d.abs() < 1e21) return d.toInt().toString();
  return d.toString();
}

/// `totalPrice`, `gstAmount` and `grandTotal`.
class PlanTotals {
  const PlanTotals(this.total, this.gst, this.grand);

  factory PlanTotals.of(Iterable<Map<String, dynamic>> plans) {
    final total = plans.fold<double>(0, (sum, p) => sum + jsNumber(p['price']));
    final gst = jsRound(total * 0.18);
    return PlanTotals(total, gst, total + gst);
  }

  final double total;
  final double gst;
  final double grand;

  String get totalText => jsNumberString(total);
  String get gstText => jsNumberString(gst);
  String get grandText => jsNumberString(grand);
}

/// `createPaymentOrderAction(payload)` → the JSON body of
/// `POST /payment/create`. Throws [ApiError] like the web's
/// `throw new Error('Institute ID not available')`.
///
/// No return / redirect URL is sent: the backend decides where the payment
/// gateway sends the browser afterwards.
Map<String, dynamic> buildPaymentOrderPayload(
  UserInfo? userInfo, {
  required String type,
  List<String>? subscriptionPlanIds,
  List<String>? zslPlanIds,
  String? referralCode,
}) {
  final instituteId = userInfo?.instituteId;
  if (!jsTruthy(instituteId)) throw const ApiError('Institute ID not available');

  String firstTruthy(List<Object?> values) {
    for (final v in values) {
      if (jsTruthy(v)) return '$v';
    }
    return '';
  }

  final payload = <String, dynamic>{
    'institute_id': instituteId,
    'type': type,
    // User Details
    'name': firstTruthy([userInfo?.fullName, userInfo?.username]),
    'email': firstTruthy([userInfo?.email]),
    'phone': firstTruthy([userInfo?.phone]),
    // Referral Code
    'referral_code': firstTruthy([referralCode]),
  };
  if (type == 'subscription_plan') {
    payload['subscription_plan_ids'] = subscriptionPlanIds ?? const <String>[];
  } else if (type == 'zsl_plan') {
    payload['zsl_plan_ids'] = zslPlanIds ?? const <String>[];
  }
  return payload;
}

/// Upgradeplan.vue `proceedToPayment` payload:
/// `{type: 'zsl_plan', zsl_plan_ids: selectedPlans.map(p => String(getPlanId(p)))}`.
List<String> zslPlanIdsOf(Iterable<Map<String, dynamic>> plans) =>
    [for (final p in plans) '${planIdOf(p)}'];

/// `response?.url || response?.payment_link`
String? paymentRedirectUrl(dynamic response) {
  for (final v in [dig(response, ['url']), dig(response, ['payment_link'])]) {
    if (jsTruthy(v)) return '$v';
  }
  return null;
}

/// The order id to verify the payment with. Upgradeplan.vue gets it back from
/// the gateway as `?transaction_id=`; the native app cannot be redirected
/// to, so it takes it from the create-order response the way
/// studentpayment.vue does: `response?.payment?.order_id || response?.order_id
/// || response?.data?.order_id`.
String? paymentOrderId(dynamic response) {
  for (final v in [
    dig(response, ['payment', 'order_id']),
    dig(response, ['order_id']),
    dig(response, ['data', 'order_id']),
  ]) {
    if (jsTruthy(v)) return '$v';
  }
  return null;
}

enum PaymentOutcome { success, failed, pending }

/// Upgradeplan.vue `checkPaymentStatus`:
/// `res?.status === 'success' || res?.payment_status === 'SUCCESS'`.
bool isUpgradePaymentSuccess(dynamic res) {
  final m = asMap(res);
  return m != null && (m['status'] == 'success' || m['payment_status'] == 'SUCCESS');
}

const _successStatuses = {'success', 'completed', 'paid', 'done', 'buyed'};
const _failedStatuses = {'failed', 'failure', 'cancelled', 'expired', 'abandoned', 'abondand'};

/// Three-way reading of a `/payment/status` response for the native re-check
/// (the payment may still be in progress when the app regains focus):
/// Upgradeplan.vue's success rule first, then studentpayment.vue's
/// normalisation (`data.data || data || payment || order || res`, then
/// `status || order_status || payment_status`, lower-cased).
PaymentOutcome classifyPaymentStatus(dynamic res) {
  if (isUpgradePaymentSuccess(res)) return PaymentOutcome.success;
  dynamic data;
  for (final v in [
    dig(res, ['data', 'data']),
    dig(res, ['data']),
    dig(res, ['payment']),
    dig(res, ['order']),
    res,
  ]) {
    if (jsTruthy(v)) {
      data = v;
      break;
    }
  }
  final m = asMap(data);
  var status = '';
  for (final v in [m?['status'], m?['order_status'], m?['payment_status']]) {
    if (jsTruthy(v)) {
      status = '$v';
      break;
    }
  }
  status = status.toLowerCase().trim();
  if (_successStatuses.contains(status)) return PaymentOutcome.success;
  if (_failedStatuses.contains(status)) return PaymentOutcome.failed;
  return PaymentOutcome.pending;
}

/// `error?.response?.data?.message || error?.message || 'Something went wrong. Please try again.'`
/// (`error.message` of an axios error is "Request failed with status code N"
/// or "Network Error").
String paymentErrorText(Object error) {
  const fallback = 'Something went wrong. Please try again.';
  if (error is DioException) {
    final message = dig(error.response?.data, ['message']);
    if (jsTruthy(message)) return '$message';
    final status = error.response?.statusCode;
    if (status != null) return 'Request failed with status code $status';
    return 'Network Error';
  }
  if (error is ApiError) return error.message.isNotEmpty ? error.message : fallback;
  return fallback;
}
