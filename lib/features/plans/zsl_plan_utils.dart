/// Pure helpers for the class-access-type screens (`Zslplan.vue`,
/// `Zslplanlist.vue`) and the role-wise subscription screen
/// (`subscription.vue`): the JavaScript number coercions the templates relied
/// on, the browser's HTML5 number validation, the sliding page window and the
/// ZSL plan payload builders. Free of Flutter so they can be unit-tested.
library;

import 'dart:math' as math;

import '../../data/services/js_compat.dart';

// ───────────────────────── JS number semantics ─────────────────────────

/// HTML "valid floating-point number" (what `<input type="number">` accepts).
final _validFloat = RegExp(r'^-?(?:\d+(?:\.\d+)?|\.\d+)(?:[eE][-+]?\d+)?$');

num _normalize(double d) =>
    d == d.truncateToDouble() && d.abs() < 9007199254740992 ? d.toInt() : d;

/// The value Vue's `v-model` / `v-model.number` stores for an
/// `<input type="number">`: the browser sanitises anything that is not a
/// valid floating-point number to `''`, then `looseToNumber` turns the rest
/// into a number. Returns a [num] or `''`.
Object numberInputValue(String text) {
  if (!_validFloat.hasMatch(text)) return '';
  final d = double.tryParse(text);
  return d == null || d.isNaN || d.isInfinite ? '' : _normalize(d);
}

/// JavaScript `Number(v)`. Returns `null` for `NaN` (which `JSON.stringify`
/// sends as `null` too).
num? jsNumber(Object? v) {
  if (v == null) return 0;
  if (v is bool) return v ? 1 : 0;
  if (v is num) return v.isNaN ? null : (v is double ? _normalize(v) : v);
  if (v is String) {
    final s = v.trim();
    if (s.isEmpty) return 0;
    final d = double.tryParse(s);
    if (d == null || d.isNaN) return null;
    return _normalize(d);
  }
  return null;
}

/// Vue's `{{ value }}` / an input's displayed value: `null` → `''`, integral
/// doubles without the trailing `.0` (JS prints `12`, not `12.0`).
String jsDisplay(Object? v) {
  if (v == null) return '';
  if (v is double) {
    if (v.isNaN) return 'NaN';
    return v == v.truncateToDouble() && v.isFinite ? v.toInt().toString() : v.toString();
  }
  return '$v';
}

/// The text an `<input type="number" v-model>` shows for [v] (`NaN`/`null` → empty).
String numberInputText(Object? v) {
  if (v == null) return '';
  if (v is num) return jsDisplay(v);
  final s = '$v';
  return _validFloat.hasMatch(s) ? s : '';
}

// ───────────────────────── HTML5 validation ─────────────────────────

/// Chrome's constraint-validation messages, shown when a `<form>` with
/// `required` / `min` / `step` inputs is submitted.
const kFillOutField = 'Please fill out this field.';
const kEnterNumber = 'Please enter a number.';

/// `<input type="text" required>`: only an empty value is "missing"
/// (whitespace passes).
String? requiredTextError(String? value) => (value ?? '').isEmpty ? kFillOutField : null;

/// `<input type="number" required min step>` (the default `step` is 1, so
/// decimals are rejected unless a step says otherwise).
String? numberFieldError(String? text, {bool required = false, num? min, num step = 1}) {
  final t = text ?? '';
  if (t.isEmpty) return required ? kFillOutField : null;
  final v = numberInputValue(t);
  if (v is! num) return kEnterNumber;
  if (min != null && v < min) {
    return 'Value must be greater than or equal to ${jsDisplay(min.toDouble())}.';
  }
  final base = min ?? 0;
  final q = (v - base) / step;
  if ((q - q.round()).abs() > 1e-9) {
    final lo = base + q.floor() * step;
    final hi = lo + step;
    return 'Please enter a valid value. The two nearest valid values are '
        '${jsDisplay(lo.toDouble())} and ${jsDisplay(hi.toDouble())}.';
  }
  return null;
}

// ───────────────────────── Pagination ─────────────────────────

/// `visiblePages()` of Zslplan.vue / Zslplanlist.vue: a sliding window of 5
/// pages around the current one (empty when there is no paginator).
List<int> zslVisiblePages(int? current, int? last) {
  if (last == null || last == 0) return const [];
  final cur = (current == null || current == 0) ? 1 : current;
  const range = 5;
  var start = math.max(1, cur - range ~/ 2);
  final end = math.min(last, start + range - 1);
  if (end - start + 1 < range) start = math.max(1, end - range + 1);
  return [for (var i = start; i <= end; i++) i];
}

// ───────────────────────── ZSL plan forms ─────────────────────────

/// `formData` of Zslplan.vue (and `resetForm()`).
Map<String, dynamic> zslEmptyCreateForm() => {
      'class_id': null,
      'class_name': '',
      'syllabus': '',
      'state_id': '',
      'duration': null,
      'price': null,
      'has_full_access': false,
    };

/// `filteredClasses` / `filteredEditClasses`: `allClasses` of the chosen
/// syllabus (none until a syllabus is picked).
List<Map<String, dynamic>> zslClassesForSyllabus(
  List<Map<String, dynamic>> allClasses,
  Object? syllabus,
) {
  if (!jsTruthy(syllabus)) return const [];
  return [for (final c in allClasses) if (c['syllabus'] == syllabus) c];
}

/// `openUpdateDialog`: the edit form built from `selectedZslPlan`.
///
/// Note the web reads `full_access` (not `has_full_access`) to pre-tick the
/// checkbox; kept as is.
Map<String, dynamic> zslEditFormFrom(Map<String, dynamic> plan) {
  num? numberOf(String key) =>
      // `Number(undefined)` is NaN (sent as null); `Number(null)` is 0.
      plan.containsKey(key) ? jsNumber(plan[key]) : null;
  return {
    ...plan,
    'class_id': jsTruthy(plan['class_id']) ? jsNumber(plan['class_id']) : null,
    'state_id': jsTruthy(plan['state_id']) ? jsNumber(plan['state_id']) : null,
    'duration': numberOf('duration'),
    'price': numberOf('price'),
    'full_access': jsTruthy(plan['full_access']),
  };
}

/// `submitUpdate()` guard: class, syllabus and state are required.
bool zslEditFormIncomplete(Map<String, dynamic> editForm) =>
    !jsTruthy(editForm['class_id']) ||
    !jsTruthy(editForm['syllabus']) ||
    !jsTruthy(editForm['state_id']);

/// `submitUpdate()` payload: `{...editForm, has_full_access: editForm.full_access}`
/// without `full_access`.
Map<String, dynamic> zslUpdatePayload(Map<String, dynamic> editForm) =>
    {...editForm, 'has_full_access': editForm['full_access']}..remove('full_access');
