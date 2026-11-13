import 'dart:typed_data';

import 'package:elab_app/core/network/upload_file.dart';
import 'package:elab_app/features/institutes/institute_payloads.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('cleanEditorHtml', () {
    test('empty / tag-only / nbsp-only content becomes empty', () {
      expect(cleanEditorHtml(null), '');
      expect(cleanEditorHtml(''), '');
      expect(cleanEditorHtml('<p></p>'), '');
      expect(cleanEditorHtml('<p>&nbsp; &nbsp;</p><br>'), '');
    });

    test('real text keeps the original html', () {
      const html = '<p>Hello <b>there</b></p>';
      expect(cleanEditorHtml(html), html);
    });
  });

  group('jsNumber / jsNumberString', () {
    test('follows JavaScript Number()', () {
      expect(jsNumber(''), 0);
      expect(jsNumber(null), 0);
      expect(jsNumber('12'), 12);
      expect(jsNumber(' 7 '), 7);
      expect(jsNumber('abc'), isNull);
      expect(jsNumberString('abc'), 'NaN');
      expect(jsNumberString(''), '0');
      expect(jsNumberString(5), '5');
      expect(jsNumberString(5.0), '5');
      expect(jsNumberString('2.5'), '2.5');
    });
  });

  test('isValidEmail uses the web regex', () {
    expect(isValidEmail('a@b.co'), isTrue);
    expect(isValidEmail('a@b'), isFalse);
    expect(isValidEmail('a b@c.d'), isFalse);
    expect(isValidEmail(' a@b.co'), isFalse);
  });

  group('parseInstitutesPage', () {
    test('paginated body', () {
      final r = parseInstitutesPage({
        'data': [
          {
            'id': 1,
            'name': 'A',
            'phone': '99',
            'email': null,
            'instructors_count': 0,
            'students_count': 4,
            'plan': {'name': 'Gold'},
          },
        ],
        'current_page': 2,
        'last_page': 3,
        'total': 21,
        'per_page': 10,
      });
      expect(r.rows.single, {
        'id': 1,
        'name': 'A',
        'phone': '99',
        'email': '',
        'expires_on': null,
        'instructors_count': '0',
        'students_count': 4,
        'plan_name': 'Gold',
      });
      expect(r.meta.currentPage, 2);
      expect(r.meta.lastPage, 3);
      expect(r.meta.total, 21);
      expect(r.meta.perPage, 10);
    });

    test('bare array body', () {
      final r = parseInstitutesPage([
        {'id': 1, 'name': 'A'},
        {'id': 2, 'name': 'B'},
      ]);
      expect(r.rows.length, 2);
      expect(r.rows.first['plan_name'], 'N/A');
      expect(r.meta.total, 2);
      expect(r.meta.lastPage, 1);
    });
  });

  group('syncClassAccess', () {
    final all = [
      {'id': 1, 'name': 'One'},
      {'id': 2, 'name': 'Two'},
      {'id': 3, 'name': 'Three'},
    ];

    test('adds new selections in order and keeps existing flags', () {
      var list = syncClassAccess([], [2, 1], all);
      expect(list.map((c) => c.classId), [2, 1]);
      list.first.hasFullAccess = true;
      list = syncClassAccess(list, [2, 1, 3], all);
      expect(list.map((c) => c.classId), [2, 1, 3]);
      expect(list.first.hasFullAccess, isTrue);
      expect(list.last.className, 'Three');
    });

    test('drops unselected classes and ignores unknown ids', () {
      final list = syncClassAccess(syncClassAccess([], [1, 2], all), [2, 9], all);
      expect(list.map((c) => c.classId), [2]);
    });
  });

  group('validateInstituteForm', () {
    Map<String, dynamic> form([Map<String, dynamic> over = const {}]) => {
          'user_id': '5',
          'name': 'Inst',
          'email': 'x@y.io',
          'plan_id': 3,
          'phone': '',
          ...over,
        };

    test('messages in web order', () {
      expect(validateInstituteForm(form({'user_id': ''})),
          'Please select an admin user by searching with email');
      expect(validateInstituteForm(form({'name': '  '})), 'Institute name is required');
      expect(validateInstituteForm(form({'email': ''})), 'Institute email is required');
      expect(validateInstituteForm(form({'email': 'bad'})), 'Please enter a valid email address');
      expect(validateInstituteForm(form({'plan_id': ''})), 'Please select a subscription plan');
      expect(validateInstituteForm(form({'phone': 'abc'})), 'Please enter a valid phone number');
      expect(validateInstituteForm(form()), isNull);
    });
  });

  test('create payload → multipart fields like submitInstituteForm', () {
    final logo = UploadFile(name: 'l.png', bytes: Uint8List(1));
    final payload = buildCreateInstitutePayload(
      {
        'name': ' Inst ',
        'email': ' a@b.co ',
        'phone': '',
        'country_code': '+91',
        'address': null,
        'state_id': '',
        'user_id': '12',
        'plan_id': 4,
        'is_math_zoro': true,
      },
      [
        ClassAccess(classId: 7, className: 'Seven', hasFullAccess: true),
        ClassAccess(classId: 8, className: 'Eight'),
      ],
      logo,
    );
    final fields = buildInstituteFormFields(payload);
    expect(fields.keys.toList(), [
      'name',
      'email',
      'phone',
      'country_code',
      'address',
      'state_id',
      'user_id',
      'plan_id',
      'classes[0][class_id]',
      'classes[0][has_full_access]',
      'classes[1][class_id]',
      'classes[1][has_full_access]',
      'logo',
      'is_math_zoro',
      'country',
    ]);
    expect(fields['name'], 'Inst');
    expect(fields['email'], 'a@b.co');
    expect(fields['phone'], '');
    expect(fields['address'], '');
    expect(fields['state_id'], '0');
    expect(fields['user_id'], '12');
    expect(fields['plan_id'], '4');
    expect(fields['classes[0][has_full_access]'], '1');
    expect(fields['classes[1][has_full_access]'], '0');
    expect(fields['classes[1][class_id]'], '8');
    expect(fields['logo'], same(logo));
    expect(fields['is_math_zoro'], '1');
    expect(fields['country'], 'ind');

    final noLogo = buildInstituteFormFields(buildCreateInstitutePayload({'country_code': null}, const [], null));
    expect(noLogo.containsKey('logo'), isFalse);
    expect(noLogo.containsKey('country_code'), isFalse);
    expect(noLogo['user_id'], '0');
  });

  test('update fields like updateInstitute', () {
    final f = buildUpdateInstituteFields({
      'id': 3,
      'name': 'N',
      'email': null,
      'phone': '123',
      'country_code': '++91',
      'address': '',
      'state_id': 9,
      'plan_id': null,
      'user_id': 2,
      'is_math_zoro': false,
      'image': null,
    });
    expect(f, {
      '_method': 'PUT',
      'name': 'N',
      'email': '',
      'phone': '123',
      'country_code': '++91',
      'address': '',
      'state_id': '9',
      'plan_id': '',
      'user_id': '2',
      'is_math_zoro': 'false',
    });
    final img = UploadFile(name: 'a.png', bytes: Uint8List(1));
    expect(buildUpdateInstituteFields({'name': 'N', 'is_math_zoro': true, 'image': img}),
        containsPair('logo', img));
  });

  test('invite link and class select text', () {
    expect(buildInviteLink('https://app.x', 'AB C&1'), 'https://app.x/signup?code=AB%20C%261');
    final all = [
      {'id': 1, 'name': 'One', 'syllabus': 'CBSE'},
      {'id': 2, 'name': 'Two', 'syllabus': 'ICSE'},
    ];
    expect(selectedClassesText(const [], all), 'Select Classes');
    expect(selectedClassesText(const [2, 1], all), 'Two - ICSE, One - CBSE');
    expect(selectedClassesText(const [5, 6], all), '2 classes selected');
  });
}
