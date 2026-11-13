/// Small helpers that reproduce the JavaScript semantics the web services
/// relied on (truthiness checks and `FormData.append` string coercion).
library;

import '../../core/network/upload_file.dart';

/// JavaScript truthiness (`if (x)`, `x || y`, `...(x && { x })`):
/// `null`, `false`, `0`, `NaN` and `''` are falsy, everything else is truthy
/// (including empty lists and maps).
bool jsTruthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// The value `formData.append(key, value)` sends for an arbitrary [v]:
/// files as-is, everything else as JS `String(value)` (`true` → `'true'`,
/// arrays comma-joined). `null` stays `null` and is therefore skipped by
/// [buildFormData] (the browser would have sent the literal `'null'` /
/// `'undefined'`).
Object? jsFormValue(Object? v) {
  if (v == null || v is UploadFile) return v;
  if (v is List) {
    return v.map((e) => e == null ? '' : '${jsFormValue(e)}').join(',');
  }
  return '$v';
}

/// `Object.keys(payload).forEach(k => formData.append(k, payload[k]))`.
Map<String, dynamic> jsFormFields(Map<String, dynamic> payload) =>
    payload.map((k, v) => MapEntry(k, jsFormValue(v)));
