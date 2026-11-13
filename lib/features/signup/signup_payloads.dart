/// Pure payload builders for the two sign-up screens, ported from the
/// `signform` / `signupform` actions in `src/store/Userstore.ts`.
///
/// Values follow `FormData.append` coercion via [jsFormValue] (project
/// convention: `null` is omitted instead of being sent as `'null'`), except
/// where the web wraps a value in `String(...)` explicitly.
library;

import '../../data/services/js_compat.dart';

/// `x || fallback` for a FormData value.
String _or(Object? v, String fallback) => jsTruthy(v) ? '$v' : fallback;

/// `signupinstitute` initial state in the store (used by selfsignup.vue).
const Map<String, dynamic> defaultSignupInstitute = {
  'name': '',
  'email': '',
  'phone': '',
  'code': '',
  'image': null,
  'state_id': null,
  'city': '',
  'address': '',
  'address2': '',
  'pincode': '',
  'name2': '',
  'email2': '',
  'phone2': '',
  'designation': '',
  'website': '',
  'country': '',
  'phone_code': '',
};

/// `signform(form)` → the multipart fields of `POST /signup/signup`, built
/// from signup.vue's `signupform`.
///
/// The web appends `name` twice (contact full name first, institute name
/// second). PHP/Laravel keeps the last value of a repeated non-array key, so
/// a map holding only the institute name is equivalent on the server.
Map<String, dynamic> buildSignformFields(Map<String, dynamic> form) {
  final fullName = _or(form['contact_fullname'], '').trim();
  final parts = fullName.split(' ');
  final firstName = parts.first.isNotEmpty ? parts.first : 'Admin';
  final rest = parts.skip(1).join(' ');
  final lastName = rest.isNotEmpty ? rest : 'User';
  final mz = form['is_mathzoro_institute'];

  final fields = <String, dynamic>{
    'first_name': firstName,
    'last_name': lastName,
    'email': jsFormValue(form['email']),
    'password': jsFormValue(form['password']),
    'password_confirmation': jsFormValue(form['password_confirmation']),
    'code': jsFormValue(form['institute_code']),
    'name': jsFormValue(form['contact_fullname']),
    'designation': _or(form['contact_designation'], 'Administrator'),
    'phone': jsFormValue(form['contact_phone']),
    'country_code': _or(form['institute_country_code'], '+91'),
  };
  // Second `fd.append('name', form.name)` — the value the server keeps.
  fields['name'] = jsFormValue(form['name']);
  fields.addAll({
    'institute_email': jsFormValue(form['institute_email']),
    'institute_phone': jsFormValue(form['contact_phone']),
    'institute_country_code': _or(form['institute_country_code'], '+91'),
    // `String(form.country)` / `String(form.state_id)`: explicit coercion.
    'country': '${form['country']}',
    'state_id': '${form['state_id']}',
    'city': _or(form['city'], ''),
    'address': _or(form['address'], ''),
    'address2': _or(form['address2'], ''),
    'institute_website': _or(form['institute_website'], ''),
    'is_math_zoro': mz == '1' || mz == true ? '1' : '0',
  });
  return fields;
}

/// `signupform()` → the multipart fields of `POST /signup/institute`, built
/// from the store's `signupinstitute` (selfsignup.vue sets it to
/// `{...signupform, image: signupform.logo}` before calling the action).
Map<String, dynamic> buildSelfSignupFields(Map<String, dynamic> s) {
  final fields = <String, dynamic>{
    'name': jsFormValue(s['name']),
    'email': jsFormValue(s['email']),
    'phone': jsFormValue(s['phone']),
    'code': jsFormValue(s['code']),
    'pincode': jsFormValue(s['pincode']),
  };
  if (jsTruthy(s['image'])) fields['image'] = s['image'];
  if (s['state_id'] != null) fields['state_id'] = '${s['state_id']}';
  fields.addAll({
    'name2': jsFormValue(s['name2']),
    'email2': jsFormValue(s['email2']),
    'phone2': jsFormValue(s['phone2']),
    'designation': jsFormValue(s['designation']),
    'website': jsFormValue(s['website']),
    'country': jsFormValue(s['country']),
    'country_code': jsFormValue(s['phone_code']),
    'city': jsFormValue(s['city']),
    'address': jsFormValue(s['address']),
    'address2': jsFormValue(s['address2']),
  });
  return fields;
}

/// `` `${v}` `` in a template literal: `undefined` for a missing key,
/// `'null'` for null.
String jsTemplateValue(Map<String, dynamic>? m, String key) {
  if (m == null || !m.containsKey(key)) return 'undefined';
  return '${m[key]}';
}

/// signup.vue `isValidEmail`.
bool isValidSignupEmail(String email) =>
    RegExp(r'^(?!.*\.\.)[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);

/// The `@input` filters: `value.replace(/\D/g, '').slice(0, max)`.
String digitsOnly(String value, int max) {
  final digits = value.replaceAll(RegExp(r'\D'), '');
  return digits.length > max ? digits.substring(0, max) : digits;
}
