/// Pure helpers for the users / profile screens (payload builders and the
/// derived tables), kept free of Flutter so they can be unit tested.
library;

import 'package:dio/dio.dart';

import '../../core/network/upload_file.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';

/// `userForm` as reset by `usercreate.vue` `mounted()` and by the store after
/// a successful `createUser()`.
const Map<String, dynamic> emptyUserForm = {
  'firstName': '',
  'lastName': '',
  'email': '',
  'phone': '',
  'countryCode': '',
  'gender': '',
  'dob': '',
  'password': '',
  'designation': '',
  'confirmpassword': '',
  'photo': null,
};

/// `passwordForm: { oldPassword: '', newPassword: '', confirmPassword: '' }`.
const Map<String, String> emptyPasswordForm = {
  'oldPassword': '',
  'newPassword': '',
  'confirmPassword': '',
};

String _s(Object? v) => v == null ? '' : '$v';

/// `x || ''`
String _or(Object? v) => jsTruthy(v) ? '$v' : '';

/// The FormData `createUser()` builds from `userForm` (Userstore.ts).
Map<String, dynamic> buildCreateUserFields(Map<String, dynamic> f) {
  final photo = f['photo'];
  return {
    'first_name': _s(f['firstName']),
    'last_name': _s(f['lastName']),
    'email': _s(f['email']),
    'country_code': _s(f['countryCode']),
    'phone': _s(f['phone']),
    'gender': _or(f['gender']),
    'dob': _or(f['dob']),
    'password': _s(f['password']),
    'password_confirmation': _s(f['confirmpassword']),
    'designation': _or(f['designation']),
    if (photo is UploadFile) 'photo': photo,
  };
}

/// The FormData `updateInstituteDetails(instituteId, form)` builds: `_method`
/// spoofing, then every truthy field (`if (form.x) formData.append(...)`).
Map<String, dynamic> buildInstituteUpdateFields(Object instituteId, Map<String, dynamic> form) {
  final out = <String, dynamic>{
    '_method': 'PUT',
    'institute_id': '$instituteId',
  };
  void put(String key, Object? value) {
    if (jsTruthy(value)) out[key] = '$value';
  }

  put('name', form['name']);
  put('email', form['email']);
  put('phone', form['phone']);
  put('country_code', form['phone_code']);
  put('address', form['address']);
  put('address2', form['address2']);
  put('state_id', form['state_id']);
  put('city', form['city']);
  put('pincode', form['pincode']);
  put('country_id', form['country']);
  put('institute_website', form['website']);
  // `!== undefined` → `String(x)` (a present null is sent as 'null').
  if (form.containsKey('plan_id')) out['plan_id'] = '${form['plan_id']}';
  if (form.containsKey('user_id')) out['user_id'] = '${form['user_id']}';
  final image = form['image'];
  if (image is UploadFile) out['logo'] = image;
  return out;
}

/// One row of the "Zoom Scopes" table: `{ category, name, status }`.
typedef ZoomScopeRow = ({String category, String name, bool status});

/// One row of `manifestTable`: `{ type, current, expected, status, missing? }`.
typedef ZoomManifestRow = ({String type, Object? current, Object? expected, bool status, List<String> missing});

/// What `loadZoomDetails()` derives from the `/zoom/info` response.
class ZoomDetails {
  const ZoomDetails({required this.scopes, required this.manifest, this.config});

  /// `res.zoom_config` when truthy (fills the form and marks it fetched).
  final Map<String, dynamic>? config;

  /// `clientScopesTable` = scopes (deduplicated, missing ones last-write-wins)
  /// followed by the expected client-app event rows.
  final List<ZoomScopeRow> scopes;
  final List<ZoomManifestRow> manifest;
}

/// Port of the table building in `UserProfile.vue` `loadZoomDetails()`.
ZoomDetails buildZoomDetails(Map<String, dynamic> res) {
  // `new Map()` keeps the first insertion position when a key is set again.
  final scopeMap = <String, ZoomScopeRow>{};
  for (final s in asList(res['client_app_scopes'])) {
    scopeMap['$s'] = (category: 'Client', name: '$s', status: true);
  }
  for (final s in asList(res['missing_client_app_scopes'])) {
    scopeMap['$s'] = (category: 'Client', name: '$s', status: false);
  }

  final ev = asMap(res['expected_client_app_event']);
  final events = <ZoomScopeRow>[
    if (jsTruthy(ev?['subscription_name']))
      (category: 'Client', name: '${ev!['subscription_name']}', status: true),
    for (final e in asList(jsTruthy(ev?['event_types']) ? ev!['event_types'] : const []))
      (category: 'Client', name: '$e', status: true),
    if (jsTruthy(ev?['development_webhook_url']))
      (category: 'Client', name: '${ev!['development_webhook_url']}', status: true),
  ];

  final current = jsTruthy(res['meeting_app_manifest']) ? res['meeting_app_manifest'] : const {};
  final expected =
      jsTruthy(res['expected_meeting_app_manifest']) ? res['expected_meeting_app_manifest'] : const {};
  final currentEnable = dig(current, ['features', 'embed', 'meeting_sdk', 'enable']) ?? false;
  final expectedEnable = dig(expected, ['features', 'embed', 'meeting_sdk', 'enable']) ?? false;
  // `currentEnable && expectedEnable` is only ever used for its truthiness.
  final sdkStatus = jsTruthy(currentEnable) && jsTruthy(expectedEnable);
  final isValid = dig(res, ['zoom_config', 'is_valid']) ?? false;

  final config = asMap(res['zoom_config']);
  return ZoomDetails(
    config: jsTruthy(res['zoom_config']) ? (config ?? const {}) : null,
    scopes: [...scopeMap.values, ...events],
    manifest: [
      (
        type: 'Meeting SDK Enabled',
        current: currentEnable,
        expected: expectedEnable,
        status: sdkStatus,
        missing: const <String>[],
      ),
      (
        type: 'Zoom Config Valid',
        current: isValid,
        expected: true,
        status: jsTruthy(isValid),
        missing: const <String>[],
      ),
    ],
  );
}

/// `error?.response?.data?.errors?.scopes` when it is a non-empty array.
List<String>? zoomScopesFromError(Object error) {
  if (error is! DioException) return null;
  final scopes = dig(error.response?.data, ['errors', 'scopes']);
  if (scopes is List && scopes.isNotEmpty) return [for (final s in scopes) '$s'];
  return null;
}

final _isoDateOnly = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// JS `new Date(str)`: a date-only ISO string is UTC midnight, anything else
/// is parsed as given (local when it has no offset). `null` = Invalid Date.
DateTime? parseJsDate(String? str) {
  if (str == null) return null;
  final s = str.trim();
  if (_isoDateOnly.hasMatch(s)) {
    final p = s.split('-').map(int.parse).toList();
    return DateTime.utc(p[0], p[1], p[2]);
  }
  return DateTime.tryParse(s);
}

/// `planwisestudentlist.vue` `isExpiringSoon(dateStr)`:
/// `Math.ceil((expiry - today) / 1 day) <= 7` (false for an invalid date).
bool isExpiringSoon(String? dateStr, {DateTime? now}) {
  final expiry = parseJsDate(dateStr);
  if (expiry == null) return false;
  final today = now ?? DateTime.now();
  const day = 1000 * 60 * 60 * 24;
  final diffDays =
      ((expiry.millisecondsSinceEpoch - today.millisecondsSinceEpoch) / day).ceil();
  return diffDays <= 7;
}

/// `planwisestudentlist.vue` `saveUpdate()`: today + `days` calendar days,
/// then `toISOString().split('T')[0]` (the UTC date).
String planExpiryDate(int days, {DateTime? now}) {
  final n = now ?? DateTime.now();
  final shifted = n.isUtc
      ? DateTime.utc(n.year, n.month, n.day + days, n.hour, n.minute, n.second, n.millisecond)
      : DateTime(n.year, n.month, n.day + days, n.hour, n.minute, n.second, n.millisecond);
  final u = shifted.toUtc();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${u.year.toString().padLeft(4, '0')}-${two(u.month)}-${two(u.day)}';
}
