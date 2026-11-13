/// Pure helpers of `studentactivitypage.vue` (unit-tested).
library;

import 'dart:convert';

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../mathzoro/mz_ui.dart' show jsStr, jsDisplay;

/// `getActivityTitle(activity)`:
/// `activity?.name || activity?.title || \`Activity ${activity?.order || ''}\`.trim() || 'Untitled Activity'`.
String activityTitle(Map<String, dynamic>? activity) {
  if (jsTruthy(activity?['name'])) return jsDisplay(activity!['name']);
  if (jsTruthy(activity?['title'])) return jsDisplay(activity!['title']);
  final order = activity?['order'];
  final s = 'Activity ${jsTruthy(order) ? jsDisplay(order) : ''}'.trim();
  return s.isNotEmpty ? s : 'Untitled Activity';
}

/// JavaScript template-literal / `String(x)` rendering (`${message}`).
String jsTemplate(dynamic v) {
  if (v == null) return 'null';
  if (v is bool) return v ? 'true' : 'false';
  if (v is num) return jsStr(v)!;
  if (v is String) return v;
  if (v is List) return v.map((e) => e == null ? '' : jsTemplate(e)).join(',');
  if (v is Map) return '[object Object]';
  return v.toString();
}

/// `handleIframeMessage(event)`: dev-tool noise is ignored, then the XP
/// achievement checks (`'true'`, `{ message: 'true' | true }`,
/// `{ is10XpAchieved: true | 'true' }`).
bool isXpSuccessMessage(dynamic data) {
  if (!jsTruthy(data)) return false;
  String dataStr;
  if (data is String) {
    dataStr = data;
  } else {
    try {
      dataStr = jsonEncode(data);
    } catch (_) {
      dataStr = '';
    }
  }
  if (dataStr.contains('vite') ||
      dataStr.contains('webpack') ||
      dataStr.contains('react-devtools') ||
      dataStr.contains('vue-devtools')) {
    return false;
  }
  if (data == 'true') return true;
  final m = asMap(data);
  if (m == null) return false;
  return m['message'] == 'true' ||
      m['message'] == true ||
      m['is10XpAchieved'] == true ||
      m['is10XpAchieved'] == 'true';
}

/// `xpChannel.postMessage(message)` success check (`'true'` or `true`).
bool isXpChannelSuccess(dynamic message) => message == 'true' || message == true;

/// `desc?.content || desc?.text || ''`.
String descriptionText(dynamic desc) {
  final d = asMap(desc);
  if (jsTruthy(d?['content'])) return jsDisplay(d!['content']);
  if (jsTruthy(d?['text'])) return jsDisplay(d!['text']);
  return '';
}

/// `list?.map((x) => x.text || x.content || '').join('\n\n') || ''`.
String joinItemTexts(dynamic list) {
  if (list is! List) return '';
  return list.map((x) {
    final m = asMap(x);
    if (jsTruthy(m?['text'])) return jsDisplay(m!['text']);
    if (jsTruthy(m?['content'])) return jsDisplay(m!['content']);
    return '';
  }).join('\n\n');
}

/// `r?.signed_url || r?.url || ''`.
String signedUrlOf(dynamic r) {
  final m = asMap(r);
  if (jsTruthy(m?['signed_url'])) return jsDisplay(m!['signed_url']);
  if (jsTruthy(m?['url'])) return jsDisplay(m!['url']);
  return '';
}

/// `String(a) === String(b)` for ids (null/undefined render as text).
bool sameId(dynamic a, dynamic b) => (jsStr(a) ?? 'null') == (jsStr(b) ?? 'null');

/// `res?.data || res || []` — the question list handed to the quiz (only an
/// array is usable; anything else counts as "no questions").
List<dynamic> dataOrSelfList(dynamic res) {
  final inner = asMap(res)?['data'];
  final v = jsTruthy(inner) ? inner : res;
  return v is List ? v : const [];
}

/// `a || b || c` over raw values.
dynamic firstTruthy(Iterable<dynamic> values) {
  dynamic last;
  for (final v in values) {
    if (jsTruthy(v)) return v;
    last = v;
  }
  return last;
}
