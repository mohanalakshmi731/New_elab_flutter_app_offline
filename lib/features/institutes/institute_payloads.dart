/// Pure helpers behind the institute screens, ported from
/// `src/pages/Institute/Institutecreate.vue`, `Institutelist.vue` and the
/// matching `useUserStore` actions (`getInstitutes`, `submitInstituteForm`,
/// `updateInstitute`). Kept free of Flutter/Riverpod so they can be unit
/// tested.
library;

import 'dart:math' as math;

import '../../core/network/upload_file.dart';
import '../../core/utils/json.dart';
import '../../core/utils/pagination.dart';
import '../../data/services/js_compat.dart';

final _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// `/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v)`
bool isValidEmail(String v) => _emailRe.hasMatch(v);

/// `cleanEditorHtml(html)`: an editor holding only tags / `&nbsp;` is sent as
/// `''`; anything with real text is sent unchanged.
String cleanEditorHtml(String? html) {
  if (html == null || html.isEmpty) return '';
  final text = html.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', '').trim();
  if (text.isEmpty) return '';
  return html;
}

/// JavaScript `Number(v)`; `null` stands for `NaN`.
num? jsNumber(Object? v) {
  if (v == null) return 0;
  if (v is bool) return v ? 1 : 0;
  if (v is num) return v.isNaN ? null : v;
  final s = v.toString().trim();
  if (s.isEmpty) return 0;
  return num.tryParse(s);
}

/// `String(Number(v))` — what `formData.append(k, Number(v).toString())` sends.
String jsNumberString(Object? v) {
  final n = jsNumber(v);
  if (n == null) return 'NaN';
  if (n is double && n.isFinite && n == n.truncateToDouble()) return n.toInt().toString();
  return n.toString();
}

/// `a || b`
Object? jsOr(Object? a, Object? b) => jsTruthy(a) ? a : b;

/// The store's `ALLinstitutes` row built in `getInstitutes()`.
Map<String, dynamic> mapInstituteRow(Map<String, dynamic> inst) => {
      'id': inst['id'],
      'name': inst['name'],
      'phone': inst['phone'],
      'email': jsOr(inst['email'], ''),
      'expires_on': jsOr(inst['expires_on'], null),
      'instructors_count': jsOr(inst['instructors_count'], '0'),
      'students_count': jsOr(inst['students_count'], '0'),
      'plan_name': jsOr(dig(inst, ['plan', 'name']), 'N/A'),
    };

/// `getInstitutes()`: the body is either a Laravel paginator (`{data, total,
/// per_page, current_page, last_page}`) or a bare array.
({List<Map<String, dynamic>> rows, PageMeta meta}) parseInstitutesPage(dynamic res) {
  final m = asMap(res);
  final isPaginated = m != null && jsTruthy(m['data']);
  final data = isPaginated ? asList(m['data']) : asList(res);
  final rows = [for (final e in data) ?asMap(e)].map(mapInstituteRow).toList();
  final meta = isPaginated
      ? PageMeta(
          currentPage: asInt(m['current_page']) ?? 1,
          lastPage: math.max(1, asInt(m['last_page']) ?? 1),
          total: asInt(m['total']) ?? 0,
          perPage: asInt(m['per_page']) ?? 10,
        )
      : PageMeta(currentPage: 1, lastPage: 1, total: data.length, perPage: data.length);
  return (rows: rows, meta: meta);
}

/// One entry of `selectedClassesWithAccess` (Institutecreate.vue).
class ClassAccess {
  ClassAccess({required this.classId, required this.className, this.hasFullAccess = false});

  final Object classId;
  final String className;
  bool hasFullAccess;

  @override
  String toString() => 'ClassAccess($classId, $className, $hasFullAccess)';
}

/// The `instituteForm.allclass` watcher: adds newly selected classes (in
/// selection order, `has_full_access: false`) and drops unselected ones,
/// keeping the existing entries (and their checkbox) untouched.
List<ClassAccess> syncClassAccess(
  List<ClassAccess> current,
  List<Object?> selectedIds,
  List<Map<String, dynamic>> allClasses,
) {
  final next = [...current];
  for (final id in selectedIds) {
    final n = jsNumber(id);
    if (next.any((c) => c.classId == n)) continue;
    final classObj = allClasses.where((c) => c['id'] == n && n != null).firstOrNull;
    if (classObj != null) {
      next.add(ClassAccess(
        classId: classObj['id'] as Object,
        className: '${classObj['name']}',
      ));
    }
  }
  return [for (final c in next) if (selectedIds.contains(c.classId)) c];
}

/// `validateForm()` of Institutecreate.vue.
String? validateInstituteForm(Map<String, dynamic> form) {
  if (!jsTruthy(form['user_id'])) {
    return 'Please select an admin user by searching with email';
  }
  if (!jsTruthy(asString(form['name'])?.trim())) return 'Institute name is required';
  if (!jsTruthy(asString(form['email'])?.trim())) return 'Institute email is required';
  if (!isValidEmail(asString(form['email']) ?? '')) return 'Please enter a valid email address';
  if (!jsTruthy(form['plan_id'])) return 'Please select a subscription plan';
  final phone = asString(form['phone']) ?? '';
  if (phone.isNotEmpty && !RegExp(r'^\d+$').hasMatch(phone.replaceAll(RegExp(r'\D'), ''))) {
    return 'Please enter a valid phone number';
  }
  return null;
}

/// The `payload` `handleSubmit()` hands to `submitInstituteForm`.
Map<String, dynamic> buildCreateInstitutePayload(
  Map<String, dynamic> form,
  List<ClassAccess> classes,
  UploadFile? logo,
) =>
    {
      'name': (asString(form['name']) ?? '').trim(),
      'email': (asString(form['email']) ?? '').trim(),
      'phone': jsOr(form['phone'], ''),
      'country_code': form['country_code'],
      'address': jsOr(form['address'], ''),
      // `Number(x)`; FormData later stringifies it (NaN → 'NaN').
      'state_id': jsNumberString(form['state_id']),
      'user_id': jsNumberString(form['user_id']),
      'plan_id': jsNumberString(form['plan_id']),
      'classes': [
        for (final c in classes) {'class_id': c.classId, 'has_full_access': c.hasFullAccess},
      ],
      'logo': logo,
      'is_math_zoro': jsTruthy(form['is_math_zoro']) ? 1 : 0,
      'country': 'ind',
    };

/// `submitInstituteForm(payload)`: the FormData it posts. `classes` become
/// `classes[i][class_id]` / `classes[i][has_full_access]` ('1'/'0'), the logo
/// is sent only when it is a file, `null` values are skipped and everything
/// else is stringified (`Number` NaN → `'NaN'`).
Map<String, dynamic> buildInstituteFormFields(Map<String, dynamic> payload) {
  final fields = <String, dynamic>{};
  payload.forEach((key, value) {
    if (key == 'classes' && value is List) {
      for (var i = 0; i < value.length; i++) {
        final item = asMap(value[i]) ?? const <String, dynamic>{};
        fields['classes[$i][class_id]'] = '${item['class_id']}';
        fields['classes[$i][has_full_access]'] = jsTruthy(item['has_full_access']) ? '1' : '0';
      }
    } else if (key == 'logo' && value is UploadFile) {
      fields['logo'] = value;
    } else if (value != null && key != 'classes') {
      fields[key] = value is num ? jsNumberString(value) : jsFormValue(value);
    }
  });
  return fields;
}

/// `updateInstitute(form)`: the FormData posted to `/institute/{id}` with
/// `_method: PUT`. `is_math_zoro` is the string `'true'` / `'false'` here.
Map<String, dynamic> buildUpdateInstituteFields(Map<String, dynamic> form) => {
      '_method': 'PUT',
      'name': '${form['name']}',
      'email': '${jsOr(form['email'], '')}',
      'phone': '${jsOr(form['phone'], '')}',
      'country_code': '${jsOr(form['country_code'], '')}',
      'address': '${jsOr(form['address'], '')}',
      'state_id': '${jsOr(form['state_id'], '')}',
      'plan_id': '${jsOr(form['plan_id'], '')}',
      'user_id': '${jsOr(form['user_id'], '')}',
      'is_math_zoro': jsTruthy(form['is_math_zoro']) ? 'true' : 'false',
      if (form['image'] is UploadFile) 'logo': form['image'],
    };

/// `${window.location.origin}/signup?code=${encodeURIComponent(code)}`
String buildInviteLink(String origin, String code) =>
    '$origin/signup?code=${Uri.encodeComponent(code)}';

/// The `<SelectValue>` text of the "All Class" multi-select: the selected
/// items' labels joined with `, ` (reka-ui), or the placeholder from
/// `getSelectedClassesText()` when nothing is selected.
String selectedClassesText(List<Object?> selected, List<Map<String, dynamic>> allClasses) {
  final labels = [
    for (final id in selected)
      for (final c in allClasses)
        if (c['id'] == id) '${c['name']} - ${c['syllabus']}',
  ];
  if (labels.isNotEmpty) return labels.join(', ');
  if (selected.isEmpty) return 'Select Classes';
  return '${selected.length} class${selected.length > 1 ? 'es' : ''} selected';
}
