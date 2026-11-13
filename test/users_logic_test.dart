import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:elab_app/core/network/upload_file.dart';
import 'package:elab_app/features/users/users_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('buildCreateUserFields', () {
    test('maps userForm to the FormData keys and defaults optional fields', () {
      final photo = UploadFile(name: 'a.png', bytes: Uint8List(1));
      final fields = buildCreateUserFields({
        ...emptyUserForm,
        'firstName': 'Ann',
        'lastName': 'Lee',
        'email': 'a@b.c',
        'countryCode': '+91',
        'phone': '9999999999',
        'password': 'p1',
        'confirmpassword': 'p2',
        'gender': null,
        'photo': photo,
      });
      expect(fields, {
        'first_name': 'Ann',
        'last_name': 'Lee',
        'email': 'a@b.c',
        'country_code': '+91',
        'phone': '9999999999',
        'gender': '',
        'dob': '',
        'password': 'p1',
        'password_confirmation': 'p2',
        'designation': '',
        'photo': photo,
      });
    });

    test('omits photo when none was picked', () {
      expect(buildCreateUserFields(emptyUserForm).containsKey('photo'), isFalse);
    });
  });

  group('buildInstituteUpdateFields', () {
    test('sends _method PUT, institute_id and only truthy fields', () {
      final fields = buildInstituteUpdateFields(7, {
        'id': 7,
        'name': 'Inst',
        'email': '',
        'phone': '12345',
        'phone_code': '+91',
        'website': 'x.com',
        'country': 101,
        'address': 'Street',
        'address2': '',
        'state_id': '',
        'city': 'Hyd',
        'pincode': '500001',
        'image': null,
      });
      expect(fields, {
        '_method': 'PUT',
        'institute_id': '7',
        'name': 'Inst',
        'phone': '12345',
        'country_code': '+91',
        'address': 'Street',
        'city': 'Hyd',
        'pincode': '500001',
        'country_id': '101',
        'institute_website': 'x.com',
      });
    });

    test('a null country is skipped, a picked logo is sent as logo', () {
      final logo = UploadFile(name: 'l.png', bytes: Uint8List(1));
      final fields = buildInstituteUpdateFields('3', {'country': null, 'state_id': '4', 'image': logo});
      expect(fields.containsKey('country_id'), isFalse);
      expect(fields['state_id'], '4');
      expect(fields['logo'], same(logo));
      expect(fields.containsKey('plan_id'), isFalse);
    });
  });

  group('buildZoomDetails', () {
    test('dedupes scopes (missing wins, first position kept) and appends events', () {
      final d = buildZoomDetails({
        'zoom_config': {'account_id': 'acc', 'is_valid': true},
        'client_app_scopes': ['a', 'b'],
        'missing_client_app_scopes': ['a', 'c'],
        'expected_client_app_event': {
          'subscription_name': 'sub',
          'event_types': ['e1'],
          'development_webhook_url': 'https://hook',
        },
        'meeting_app_manifest': {
          'features': {
            'embed': {
              'meeting_sdk': {'enable': true}
            }
          }
        },
        'expected_meeting_app_manifest': {
          'features': {
            'embed': {
              'meeting_sdk': {'enable': true}
            }
          }
        },
      });
      expect(d.config?['account_id'], 'acc');
      expect([for (final s in d.scopes) '${s.name}:${s.status}'],
          ['a:false', 'b:true', 'c:false', 'sub:true', 'e1:true', 'https://hook:true']);
      expect([for (final m in d.manifest) '${m.type}:${m.status}'],
          ['Meeting SDK Enabled:true', 'Zoom Config Valid:true']);
    });

    test('missing config / manifest give no config and failing rows', () {
      final d = buildZoomDetails({});
      expect(d.config, isNull);
      expect(d.scopes, isEmpty);
      expect([for (final m in d.manifest) m.status], [false, false]);
    });
  });

  test('zoomScopesFromError reads response.data.errors.scopes', () {
    final req = RequestOptions(path: '/zoom/validate');
    final err = DioException(
      requestOptions: req,
      response: Response(requestOptions: req, statusCode: 422, data: {
        'errors': {
          'scopes': ['meeting:read', 'user:read']
        }
      }),
    );
    expect(zoomScopesFromError(err), ['meeting:read', 'user:read']);
    expect(
      zoomScopesFromError(DioException(
        requestOptions: req,
        response: Response(requestOptions: req, statusCode: 422, data: {
          'errors': {'scopes': []}
        }),
      )),
      isNull,
    );
    expect(zoomScopesFromError(StateError('x')), isNull);
  });

  group('planwise dates', () {
    final now = DateTime.utc(2026, 11, 11, 10);

    test('isExpiringSoon: date-only strings are UTC midnight, ceil(days) <= 7', () {
      expect(isExpiringSoon('2026-05-01', now: now), isTrue); // already expired
      expect(isExpiringSoon('2026-11-18', now: now), isTrue); // ceil(6.58) = 7
      expect(isExpiringSoon('2026-11-19', now: now), isFalse); // ceil(7.58) = 8
      expect(isExpiringSoon('not a date', now: now), isFalse);
      expect(isExpiringSoon(null, now: now), isFalse);
    });

    test('planExpiryDate adds calendar days and returns the UTC date', () {
      expect(planExpiryDate(7, now: now), '2026-11-18');
      expect(planExpiryDate(90, now: now), '2027-02-09');
      expect(planExpiryDate(30, now: DateTime.utc(2026, 1, 31, 23, 59)), '2026-03-02');
    });
  });
}
