/// Pure logic of
/// `src/components/new_ui_student_teacher_for_both_labs/studentpayment.vue`
/// (computed values, template helpers and response normalisation), kept free
/// of Flutter so it can be unit tested.
library;

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../upgrade/upgrade_plan_logic.dart' show jsNumber, jsNumberString;

/// `a || b || c …` — the first truthy value, or `null`.
Object? firstTruthy(Iterable<Object?> values) {
  for (final v in values) {
    if (jsTruthy(v)) return v;
  }
  return null;
}

/// `{{ value }}` — Vue prints `null` as an empty string and numbers the JS way.
String jsDisplay(Object? v) {
  if (v == null) return '';
  if (v is num) return jsNumberString(v);
  return '$v';
}

/// JS `x.toFixed(digits)` (Dart's `toStringAsFixed` rounds the same way;
/// only `-0` and the non-finite values need care).
String jsToFixed(double x, int digits) {
  if (x.isNaN) return 'NaN';
  if (x.isInfinite) return x > 0 ? 'Infinity' : '-Infinity';
  if (x.abs() >= 1e21) return jsNumberString(x);
  if (x == 0) return 0.0.toStringAsFixed(digits);
  return x.toStringAsFixed(digits);
}

// ── plans ────────────────────────────────────────────────────────────────

/// `Array.isArray(res) ? res : res?.data || res?.plans || []`. Returns `null`
/// when the result is not an array (the web then fails on `raw.filter`).
List<dynamic>? rawPlansOf(dynamic res) {
  if (res is List) return res;
  final m = asMap(res);
  final raw = firstTruthy([m?['data'], m?['plans']]) ?? const [];
  return raw is List ? raw : null;
}

/// `loadPlans()` — only active paid plans, normalised to the shape the
/// template uses (`id`, `class_name`, `price`, `duration`, `full_access`,
/// `syllabus`, `allow_referral_code`).
List<Map<String, dynamic>> paidPlansOf(List<dynamic> raw) => [
      for (final e in raw)
        if (asMap(e) case final p? when p['plan_type'] == 'paid' && p['is_active'] == true)
          {
            'id': p['id'],
            'class_name': p['name'],
            'price': p['price'],
            'duration': p['days'],
            'full_access': p['all_classes'],
            'syllabus': jsTruthy(p['syllabus']) ? p['syllabus'] : null,
            'allow_referral_code': p['allow_referral_code'],
          },
    ];

/// `showReferralCodeSection`
bool showReferralCodeSection(List<Map<String, dynamic>> selectedPlans) =>
    selectedPlans.isNotEmpty && selectedPlans.every((p) => p['allow_referral_code'] != false);

/// `currentPlanName` — the plan whose id is the subscription's
/// `subscription_plan_id`, else "Active Plan".
String currentPlanName(dynamic getuserbyid, List<Map<String, dynamic>> allPlans) {
  final planId = dig(getuserbyid, const ['subscription', 'subscription_plan_id']);
  for (final p in allPlans) {
    if (p['id'] == planId) {
      return jsTruthy(p['class_name']) ? '${p['class_name']}' : 'Active Plan';
    }
  }
  return 'Active Plan';
}

/// `subtotal`, `discountAmount`, `subtotalAfterDiscount`, `gstAmount`,
/// `grandTotal`. The string values are the `toFixed(2)` results the template
/// prints.
class OrderTotals {
  const OrderTotals._(this.subtotal, this.discountAmount, this.subtotalAfterDiscount,
      this.gstAmount, this.grandTotal);

  /// [referralDiscount] is the percentage (`customer_discount`).
  factory OrderTotals.of(Iterable<Map<String, dynamic>> plans, double referralDiscount) {
    final subtotal = plans.fold<double>(0, (sum, p) => sum + jsNumber(p['price']));
    final discountAmount = jsToFixed(subtotal * (referralDiscount / 100), 2);
    final after = subtotal - jsNumber(discountAmount);
    final gstAmount = jsToFixed(after * 0.18, 2);
    final grandTotal = jsToFixed(after + jsNumber(gstAmount), 2);
    return OrderTotals._(subtotal, discountAmount, after, gstAmount, grandTotal);
  }

  final double subtotal;
  final String discountAmount;
  final double subtotalAfterDiscount;
  final String gstAmount;
  final String grandTotal;
}

// ── payment order / status ───────────────────────────────────────────────

/// `response?.payment_link || response?.url || response?.data?.url`
String? studentPaymentUrl(dynamic response) {
  final v = firstTruthy([
    dig(response, const ['payment_link']),
    dig(response, const ['url']),
    dig(response, const ['data', 'url']),
  ]);
  return v == null ? null : '$v';
}

const pollSuccessStatuses = {'success', 'completed', 'paid', 'done', 'buyed'};
const pollFailedStatuses = {'failed', 'failure', 'cancelled', 'expired', 'abandoned', 'abondand'};

enum PollOutcome { success, failed, pending }

/// One `/payment/status` answer read the way the polling callback does:
/// `data = result?.data?.data || result?.data || result?.payment ||
/// result?.order || result || {}`, then
/// `(data.status || data.order_status || data.payment_status || '')`
/// lower-cased and trimmed.
class PollReading {
  const PollReading(this.status, this.data);

  factory PollReading.of(dynamic result) {
    final data = asMap(firstTruthy([
          dig(result, const ['data', 'data']),
          dig(result, const ['data']),
          dig(result, const ['payment']),
          dig(result, const ['order']),
          result,
        ])) ??
        const <String, dynamic>{};
    final s = firstTruthy([data['status'], data['order_status'], data['payment_status']]);
    return PollReading(s == null ? '' : '$s'.toLowerCase().trim(), data);
  }

  final String status;
  final Map<String, dynamic> data;

  PollOutcome get outcome {
    if (pollSuccessStatuses.contains(status)) return PollOutcome.success;
    if (pollFailedStatuses.contains(status)) return PollOutcome.failed;
    return PollOutcome.pending;
  }

  /// `data?.amount ?? data?.price`
  Object? get amount => data['amount'] ?? data['price'];

  /// `data?.transaction_id || orderId`
  String transactionId(String orderId) {
    final v = data['transaction_id'];
    return jsTruthy(v) ? '$v' : orderId;
  }

  /// `data?.message || 'Payment was not completed.'`
  String get failureMessage {
    final v = data['message'];
    return jsTruthy(v) ? '$v' : 'Payment was not completed.';
  }

  /// `status.includes('abandon') ? 'Payment abandoned.' : 'Payment failed.'`
  String get failureToast => status.contains('abandon') ? 'Payment abandoned.' : 'Payment failed.';
}

/// `paymentResult` — `{ status, amount?, message?, transaction_id }`.
class PaymentResult {
  const PaymentResult({required this.success, this.amount, this.message, this.transactionId});
  final bool success;
  final Object? amount;
  final String? message;
  final String? transactionId;
}

// ── payment history / invoice ────────────────────────────────────────────

/// `Array.isArray(res) ? res : res?.data || res?.results || res?.payments || []`
/// (newest first). `null` when the result is not iterable — the web's
/// `[...raw]` throws and the list keeps its previous value.
List<dynamic>? historyFromResponse(dynamic res) {
  List<dynamic>? raw;
  if (res is List) {
    raw = res;
  } else {
    final m = asMap(res);
    final v = firstTruthy([m?['data'], m?['results'], m?['payments']]) ?? const [];
    raw = v is List ? v : null;
  }
  return raw?.reversed.toList();
}

/// `txn.order_id || txn.id || txn.transaction_id`
String? invoiceOrderId(Map<String, dynamic> txn) {
  final v = firstTruthy([txn['order_id'], txn['id'], txn['transaction_id']]);
  return v == null ? null : jsDisplay(v);
}

/// `{ ...txn, ...(result?.data || result || {}) }`
Map<String, dynamic> mergeInvoice(Map<String, dynamic> txn, dynamic result) {
  final inner = firstTruthy([dig(result, const ['data']), result]);
  return {...txn, ...?asMap(inner)};
}

/// The status families used by `statusLabel` / `statusStyle` / `invoiceTheme`.
enum PayStatusKind { paid, failed, other }

String _statusOf(Map<String, dynamic>? item) {
  final v = firstTruthy([item?['status'], item?['order_status']]);
  return v == null ? '' : '$v'.toLowerCase();
}

PayStatusKind payStatusKind(Map<String, dynamic>? item) {
  final s = _statusOf(item);
  if (const {'success', 'completed', 'paid'}.contains(s)) return PayStatusKind.paid;
  if (const {'failed', 'cancelled'}.contains(s)) return PayStatusKind.failed;
  return PayStatusKind.other;
}

/// `statusLabel(item)`
String payStatusLabel(Map<String, dynamic>? item) {
  final s = _statusOf(item);
  if (const {'success', 'completed', 'paid'}.contains(s)) return 'Paid';
  if (const {'failed', 'cancelled'}.contains(s)) return 'Failed';
  if (s == 'pending') return 'Pending';
  if (s == 'initiated') return 'Initiated';
  if (s == 'abandoned' || s == 'abondand') return 'Abandoned';
  return s.isNotEmpty ? s : 'Unknown';
}

/// `totalWithGst(item)` — `final_amount` when present, else amount + 18 %.
String totalWithGst(Map<String, dynamic>? item) {
  final base = jsNumber(firstTruthy([item?['amount'], item?['price'], item?['final_amount']]) ?? 0);
  if (!jsTruthy(base)) return '—';
  if (jsTruthy(item?['final_amount'])) return jsToFixed(jsNumber(item!['final_amount']), 2);
  return jsToFixed(base * 1.18, 2);
}

/// `txn.plan_name || txn.class_name || txn.description || 'Subscription Plan'`
String historyTitle(Map<String, dynamic> txn) =>
    jsDisplay(firstTruthy([txn['plan_name'], txn['class_name'], txn['description']]) ??
        'Subscription Plan');

/// `invoiceData.final_amount ?? totalWithGst(invoiceData)`
String invoiceTotal(Map<String, dynamic> data) =>
    data['final_amount'] != null ? jsDisplay(data['final_amount']) : totalWithGst(data);

/// `invoiceData.gst_percentage ?? 18`
String invoiceGstPercentage(Map<String, dynamic> data) => jsDisplay(data['gst_percentage'] ?? 18);

/// `Number(gst_amount) > 0 ? '₹' + Number(gst_amount).toFixed(2) : '₹0.00'`
String invoiceGstAmount(Map<String, dynamic> data) {
  final n = jsNumber(data['gst_amount']);
  return n > 0 ? '₹${jsToFixed(n, 2)}' : '₹0.00';
}

/// `invoiceData.subscription_plans?.[0]?.name || invoiceData.plan_name || 'Subscription Plan'`
String invoicePlanName(Map<String, dynamic> data) => jsDisplay(firstTruthy([
      dig(data, const ['subscription_plans', 0, 'name']),
      data['plan_name'],
    ]) ??
    'Subscription Plan');

/// What an `invoiceRows` entry looks like (icons and colours are picked by
/// the widget from [key]).
class InvoiceRowData {
  const InvoiceRowData(this.key, this.label, this.value);
  final String key;
  final String label;

  /// Already formatted; the row is shown only when it is truthy.
  final Object? value;
  bool get visible => jsTruthy(value);
}

/// `invoiceRows(data)`
List<InvoiceRowData> invoiceRows(Map<String, dynamic> data, {DateTime Function(DateTime)? toLocal}) => [
      InvoiceRowData('invoice', 'Invoice No.', data['invoice_number']),
      InvoiceRowData('order', 'Order ID', data['order_id']),
      InvoiceRowData('transaction', 'Transaction ID', data['transaction_id']),
      InvoiceRowData('bank', 'Bank Ref. No.', data['bank_ref_no']),
      InvoiceRowData('tracking', 'Tracking ID', data['tracking_id']),
      InvoiceRowData('date', 'Date',
          formatPaymentDate(firstTruthy([data['transaction_date'], data['created_at']]), toLocal: toLocal)),
      InvoiceRowData('gateway', 'Gateway', data['gateway']),
      InvoiceRowData('mode', 'Payment Mode', firstTruthy([data['payment_mode'], data['payment_method']])),
      InvoiceRowData('currency', 'Currency', firstTruthy([data['currency']]) ?? 'INR'),
      InvoiceRowData('status', 'Status', payStatusLabel(data)),
      InvoiceRowData('status_message', 'Status Message', data['status_message']),
      InvoiceRowData('failure', 'Failure Reason', data['failure_message']),
      InvoiceRowData('referral', 'Referral Code', data['referral_code']),
    ];

// ── dates ────────────────────────────────────────────────────────────────

/// `new Date(str)` for the strings the API sends: ISO date-only strings are
/// UTC (like JS), date-times without an offset are local. `null` = Invalid
/// Date.
DateTime? jsParseDate(String s) {
  final t = s.trim();
  final dateOnly = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(t);
  if (dateOnly != null) {
    return DateTime.utc(
      int.parse(dateOnly.group(1)!),
      int.parse(dateOnly.group(2)!),
      int.parse(dateOnly.group(3)!),
    );
  }
  return DateTime.tryParse(t);
}

/// `en-IN` short month names (CLDR — September is "Sept").
const enInShortMonths = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec',
];

/// `formatDate(dateStr)` — `Intl.DateTimeFormat('en-IN', { day: 'numeric',
/// month: 'short', year: 'numeric', hour: '2-digit', minute: '2-digit' })`
/// → `12 Nov 2026, 03:45 pm`; an unparsable value is returned as is.
/// [toLocal] is only for tests (defaults to the device time zone).
String formatPaymentDate(Object? dateStr, {DateTime Function(DateTime)? toLocal}) {
  if (!jsTruthy(dateStr)) return '';
  final parsed = jsParseDate('$dateStr');
  if (parsed == null) return '$dateStr';
  final d = toLocal != null ? toLocal(parsed) : parsed.toLocal();
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.day} ${enInShortMonths[d.month - 1]} ${d.year}, ${two(h12)}:${two(d.minute)} '
      '${d.hour < 12 ? 'am' : 'pm'}';
}

// ── errors ───────────────────────────────────────────────────────────────

/// `err?.message || fallback` for what the web can throw: axios errors
/// ("Request failed with status code N" / "Network Error") and
/// `new Error(text)`.
String jsErrorMessage(Object error, String fallback) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status != null) return 'Request failed with status code $status';
    return 'Network Error';
  }
  if (error is ApiError) return error.message.isNotEmpty ? error.message : fallback;
  return fallback;
}

/// `error?.response?.data?.message || error?.message || 'Invalid referral code'`
String referralErrorText(Object error) {
  if (error is DioException) {
    final message = dig(error.response?.data, const ['message']);
    if (jsTruthy(message)) return '$message';
  }
  return jsErrorMessage(error, 'Invalid referral code');
}
