import 'package:dio/dio.dart';
import 'package:elab_app/core/network/api_client.dart';
import 'package:elab_app/core/network/upload_file.dart';
import 'package:elab_app/data/models/session.dart';
import 'package:elab_app/features/signup/signup_payloads.dart';
import 'package:elab_app/features/upgrade/upgrade_plan_logic.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('signform (signup.vue)', () {
    Map<String, dynamic> form([Map<String, dynamic> overrides = const {}]) => {
          'is_mathzoro_institute': '0',
          'name': 'Acme School',
          'institute_email': 'office@acme.edu',
          'country': 101,
          'state_id': 7,
          'city': '',
          'institute_country_code': 91,
          'address': 'Main road',
          'address2': '',
          'institute_website': '',
          'institute_code': 'INV42',
          'contact_fullname': 'Ravi Kumar Rao',
          'contact_phone': '9876543210',
          'contact_email': 'ravi@acme.edu',
          'contact_designation': 'Principal',
          'email': 'office@acme.edu',
          'password': 'secret123',
          'password_confirmation': 'secret123',
          ...overrides,
        };

    test('builds the multipart fields like the store action', () {
      final f = buildSignformFields(form());
      expect(f['first_name'], 'Ravi');
      expect(f['last_name'], 'Kumar Rao');
      expect(f['email'], 'office@acme.edu');
      expect(f['code'], 'INV42');
      // The second `name` append (institute name) is the one PHP keeps.
      expect(f['name'], 'Acme School');
      expect(f['designation'], 'Principal');
      expect(f['phone'], '9876543210');
      expect(f['institute_phone'], '9876543210');
      expect(f['country_code'], '91');
      expect(f['institute_country_code'], '91');
      expect(f['country'], '101');
      expect(f['state_id'], '7');
      expect(f['city'], '');
      expect(f['institute_website'], '');
      expect(f['is_math_zoro'], '0');
    });

    test('falls back to Admin / User / Administrator / +91', () {
      final f = buildSignformFields(form({
        'contact_fullname': '',
        'contact_designation': '',
        'institute_country_code': '',
        'is_mathzoro_institute': true,
      }));
      expect(f['first_name'], 'Admin');
      expect(f['last_name'], 'User');
      expect(f['designation'], 'Administrator');
      expect(f['country_code'], '+91');
      expect(f['institute_country_code'], '+91');
      expect(f['is_math_zoro'], '1');
    });

    test('keeps the JS split quirk for double spaces', () {
      final f = buildSignformFields(form({'contact_fullname': 'Ravi  Rao'}));
      expect(f['first_name'], 'Ravi');
      expect(f['last_name'], ' Rao');
    });
  });

  group('signupform (selfsignup.vue)', () {
    test('sends the image only when set and skips a null state', () {
      final base = {...defaultSignupInstitute, 'name': 'Acme', 'country': 5, 'phone_code': '+91'};
      final f = buildSelfSignupFields(base);
      expect(f.containsKey('image'), isFalse);
      expect(f.containsKey('state_id'), isFalse);
      expect(f['country'], '5');
      expect(f['country_code'], '+91');
      expect(f['pincode'], '');

      const logo = UploadFile(name: 'logo.png', path: '/tmp/logo.png');
      final g = buildSelfSignupFields({...base, 'image': logo, 'state_id': 3, 'phone2': null});
      expect(g['image'], same(logo));
      expect(g['state_id'], '3');
      expect(g['phone2'], isNull); // omitted by buildFormData
    });

    test('template values follow JS', () {
      expect(jsTemplateValue({'a': null}, 'a'), 'null');
      expect(jsTemplateValue({'a': 'x'}, 'a'), 'x');
      expect(jsTemplateValue({}, 'a'), 'undefined');
    });

    test('email and digit filters', () {
      expect(isValidSignupEmail('a.b@c.co'), isTrue);
      expect(isValidSignupEmail('a..b@c.co'), isFalse);
      expect(isValidSignupEmail('a@b'), isFalse);
      expect(digitsOnly('98-76 54x3210999', 10), '9876543210');
      expect(digitsOnly('56a00', 6), '5600');
    });
  });

  group('upgrade plan totals', () {
    test('getPlanId order', () {
      expect(planIdOf({'plan_id': 3, 'id': 2, 'class_id': 1}), 3);
      expect(planIdOf({'id': 2, 'class_id': 1}), 2);
      expect(planIdOf({'class_id': 1}), 1);
      expect(planIdOf({}), isNull);
    });

    test('Number() / Math.round / String()', () {
      expect(jsNumber('999.50'), 999.5);
      expect(jsNumber(''), 0);
      expect(jsNumber(null), 0);
      expect(jsNumber('abc').isNaN, isTrue);
      expect(jsNumber('NaN').isNaN, isTrue);
      expect(jsRound(2.5), 3);
      expect(jsRound(-2.5), -2);
      expect(jsNumberString(2498.0), '2498');
      expect(jsNumberString(2498.5), '2498.5');
      expect(jsNumberString(double.nan), 'NaN');
    });

    test('subtotal, 18% GST rounded, grand total', () {
      final t = PlanTotals.of([
        {'price': '999'},
        {'price': 1499.5},
      ]);
      expect(t.totalText, '2498.5');
      expect(t.gstText, '450'); // Math.round(449.73)
      expect(t.grandText, '2948.5');
      expect(PlanTotals.of(const []).grandText, '0');
    });
  });

  group('payment', () {
    const user = UserInfo(
      id: 1,
      username: 'admin',
      token: 't',
      instituteId: 12,
      email: 'a@b.co',
      phone: '99',
    );

    test('create-order payload', () {
      final p = buildPaymentOrderPayload(user,
          type: 'zsl_plan', zslPlanIds: zslPlanIdsOf([
            {'id': 4},
            {'plan_id': 'x9'},
          ]));
      expect(p, {
        'institute_id': 12,
        'type': 'zsl_plan',
        'name': 'admin',
        'email': 'a@b.co',
        'phone': '99',
        'referral_code': '',
        'zsl_plan_ids': ['4', 'x9'],
      });
    });

    test('requires an institute', () {
      expect(
        () => buildPaymentOrderPayload(const UserInfo(id: 1, username: 'u', token: 't'), type: 'zsl_plan'),
        throwsA(isA<ApiError>().having((e) => e.message, 'message', 'Institute ID not available')),
      );
    });

    test('redirect url and order id extraction', () {
      expect(paymentRedirectUrl({'url': '', 'payment_link': 'https://pay/x'}), 'https://pay/x');
      expect(paymentRedirectUrl({'url': 'https://pay/u'}), 'https://pay/u');
      expect(paymentRedirectUrl({}), isNull);
      expect(paymentOrderId({'payment': {'order_id': 'ORD1'}, 'order_id': 'X'}), 'ORD1');
      expect(paymentOrderId({'data': {'order_id': 77}}), '77');
      expect(paymentOrderId({'url': 'u'}), isNull);
    });

    test('status classification', () {
      expect(isUpgradePaymentSuccess({'status': 'success'}), isTrue);
      expect(isUpgradePaymentSuccess({'payment_status': 'SUCCESS'}), isTrue);
      expect(isUpgradePaymentSuccess({'status': 'SUCCESS'}), isFalse);
      expect(classifyPaymentStatus({'payment_status': 'SUCCESS'}), PaymentOutcome.success);
      expect(classifyPaymentStatus({'data': {'status': 'PAID'}}), PaymentOutcome.success);
      expect(classifyPaymentStatus({'data': {'order_status': 'Cancelled'}}), PaymentOutcome.failed);
      expect(classifyPaymentStatus({'payment': {'status': 'pending'}}), PaymentOutcome.pending);
      expect(classifyPaymentStatus(null), PaymentOutcome.pending);
    });

    test('payment error text', () {
      final opts = RequestOptions(path: '/payment/create');
      expect(
        paymentErrorText(DioException(
          requestOptions: opts,
          response: Response(requestOptions: opts, statusCode: 422, data: {'message': 'Invalid plan'}),
        )),
        'Invalid plan',
      );
      expect(
        paymentErrorText(DioException(
          requestOptions: opts,
          response: Response(requestOptions: opts, statusCode: 500, data: '<html>'),
        )),
        'Request failed with status code 500',
      );
      expect(paymentErrorText(DioException(requestOptions: opts)), 'Network Error');
      expect(paymentErrorText(const ApiError('Institute ID not available')), 'Institute ID not available');
      expect(paymentErrorText(StateError('x')), 'Something went wrong. Please try again.');
    });
  });
}
