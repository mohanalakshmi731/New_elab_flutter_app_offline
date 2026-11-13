import 'package:elab_app/features/plans/subscription_controller.dart';
import 'package:elab_app/features/plans/zsl_plan_utils.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('JS number semantics', () {
    test('numberInputValue = sanitised <input type=number> + looseToNumber', () {
      expect(numberInputValue(''), '');
      expect(numberInputValue('30'), 30);
      expect(numberInputValue('30'), isA<int>());
      expect(numberInputValue('12.5'), 12.5);
      expect(numberInputValue('-4'), -4);
      expect(numberInputValue('.5'), 0.5);
      expect(numberInputValue('1e3'), 1000);
      expect(numberInputValue('1-2'), '');
      expect(numberInputValue('1..2'), '');
      expect(numberInputValue('-'), '');
    });

    test('jsNumber = Number(v), null for NaN', () {
      expect(jsNumber(null), 0);
      expect(jsNumber(''), 0);
      expect(jsNumber('  '), 0);
      expect(jsNumber('199.00'), 199);
      expect(jsNumber('199.00'), isA<int>());
      expect(jsNumber('12.5'), 12.5);
      expect(jsNumber(7), 7);
      expect(jsNumber(7.0), isA<int>());
      expect(jsNumber(true), 1);
      expect(jsNumber('abc'), isNull);
      expect(jsNumber(const {'a': 1}), isNull);
    });

    test('jsDisplay / numberInputText', () {
      expect(jsDisplay(null), '');
      expect(jsDisplay(12.0), '12');
      expect(jsDisplay(12.5), '12.5');
      expect(jsDisplay('199.00'), '199.00');
      expect(numberInputText(null), '');
      expect(numberInputText(30), '30');
      expect(numberInputText('30'), '30');
      expect(numberInputText('abc'), '');
    });
  });

  group('HTML5 validation messages', () {
    test('required text', () {
      expect(requiredTextError(''), kFillOutField);
      expect(requiredTextError(null), kFillOutField);
      expect(requiredTextError('  '), isNull);
      expect(requiredTextError('Gold'), isNull);
    });

    test('required number with the default step of 1', () {
      expect(numberFieldError('', required: true), kFillOutField);
      expect(numberFieldError(''), isNull);
      expect(numberFieldError('30', required: true), isNull);
      expect(numberFieldError('-5', required: true), isNull);
      expect(numberFieldError('1-2', required: true), kEnterNumber);
      expect(
        numberFieldError('2.5', required: true),
        'Please enter a valid value. The two nearest valid values are 2 and 3.',
      );
    });

    test('price: min 0, step 1', () {
      expect(numberFieldError('0', required: true, min: 0), isNull);
      expect(numberFieldError('-1', required: true, min: 0), 'Value must be greater than or equal to 0.');
      expect(
        numberFieldError('9.99', required: true, min: 0),
        'Please enter a valid value. The two nearest valid values are 9 and 10.',
      );
    });
  });

  group('zslVisiblePages (sliding window of 5)', () {
    test('no paginator', () {
      expect(zslVisiblePages(null, null), isEmpty);
      expect(zslVisiblePages(1, 0), isEmpty);
    });

    test('fewer than 5 pages', () {
      expect(zslVisiblePages(1, 1), [1]);
      expect(zslVisiblePages(2, 3), [1, 2, 3]);
    });

    test('window centred on the current page', () {
      expect(zslVisiblePages(1, 10), [1, 2, 3, 4, 5]);
      expect(zslVisiblePages(4, 10), [2, 3, 4, 5, 6]);
      expect(zslVisiblePages(6, 10), [4, 5, 6, 7, 8]);
    });

    test('window clamps at the end', () {
      expect(zslVisiblePages(10, 10), [6, 7, 8, 9, 10]);
      expect(zslVisiblePages(9, 10), [6, 7, 8, 9, 10]);
    });
  });

  group('ZSL plan forms', () {
    final classes = [
      {'id': 1, 'name': 'Class 1', 'syllabus': 'CBSE'},
      {'id': 2, 'name': 'Class 2', 'syllabus': 'STATE'},
      {'id': 3, 'name': 'Class 3', 'syllabus': 'CBSE'},
    ];

    test('classes are filtered by syllabus, none without one', () {
      expect(zslClassesForSyllabus(classes, ''), isEmpty);
      expect(zslClassesForSyllabus(classes, null), isEmpty);
      expect(zslClassesForSyllabus(classes, 'CBSE').map((c) => c['id']), [1, 3]);
    });

    test('create form defaults (resetForm)', () {
      expect(zslEmptyCreateForm(), {
        'class_id': null,
        'class_name': '',
        'syllabus': '',
        'state_id': '',
        'duration': null,
        'price': null,
        'has_full_access': false,
      });
    });

    test('edit form from selectedZslPlan', () {
      final form = zslEditFormFrom({
        'id': 9,
        'class_id': '4',
        'class_name': 'Gold',
        'syllabus': 'CBSE',
        'state_id': null,
        'duration': '30',
        'price': '199.00',
        'has_full_access': 1,
        'created_at': '2026-01-01',
      });
      expect(form['id'], 9);
      expect(form['class_id'], 4);
      expect(form['state_id'], isNull);
      expect(form['duration'], 30);
      expect(form['price'], 199);
      // The web reads `full_access`, so this plan opens unticked.
      expect(form['full_access'], isFalse);
      expect(form['created_at'], '2026-01-01');
    });

    test('missing duration / price become NaN (null), null ones 0', () {
      expect(zslEditFormFrom({'id': 1})['duration'], isNull);
      expect(zslEditFormFrom({'id': 1, 'price': null})['price'], 0);
      expect(zslEditFormFrom({'id': 1, 'full_access': 1})['full_access'], isTrue);
    });

    test('update guard and payload', () {
      final form = zslEditFormFrom({'id': 9, 'class_id': 4, 'syllabus': 'CBSE', 'state_id': 2, 'full_access': 0});
      expect(zslEditFormIncomplete(form), isFalse);
      expect(zslEditFormIncomplete({...form, 'state_id': null}), isTrue);
      expect(zslEditFormIncomplete({...form, 'syllabus': ''}), isTrue);

      final payload = zslUpdatePayload({...form, 'full_access': true});
      expect(payload.containsKey('full_access'), isFalse);
      expect(payload['has_full_access'], isTrue);
      expect(payload['id'], 9);
      expect(payload['class_id'], 4);
    });
  });

  group('role subscription payloads', () {
    test('create: unselected institute and untouched numbers are dropped', () {
      final payload = subscriptionWithPurchaseFlags(subscriptionEmptyForm());
      final req = subscriptionCreateRequest(5, payload);
      expect(req.containsKey('institute_id'), isFalse);
      expect(req.containsKey('days'), isFalse);
      expect(req.containsKey('max_classes'), isFalse);
      expect(req['name'], '');
      expect(req['plan_type'], '');
      expect(req['is_active'], false);
      expect(req['is_one_time_purchase'], 0);
      expect(req['allow_referral_code'], 0);
    });

    test('create: filled form', () {
      final form = subscriptionEmptyForm()
        ..['institute_id'] = 3
        ..['classes_id'] = 11
        ..['name'] = 'Teacher monthly'
        ..['days'] = 30
        ..['price'] = ''
        ..['is_one_time_purchase'] = true;
      final req = subscriptionCreateRequest(5, subscriptionWithPurchaseFlags(form));
      expect(req['institute_id'], 3);
      expect(req['classes_id'], 11);
      expect(req['days'], 30);
      expect(req['price'], '');
      expect(req['is_one_time_purchase'], 1);
    });

    test('edit form from a plan', () {
      final form = subscriptionEditFormFrom({
        'id': 1,
        'name': null,
        'days': 30,
        'price': null,
        'is_active': 1,
        'plan_type': 'paid',
        'is_one_time_purchase': '1',
        'allow_referral_code': 'yes',
      });
      expect(form['name'], '');
      expect(form['days'], 30);
      expect(form.containsKey('price'), isTrue);
      expect(form['price'], isNull);
      expect(form.containsKey('apple_price'), isFalse);
      expect(form.containsKey('id'), isFalse);
      expect(form['is_active'], 1);
      expect(form['is_public'], false);
      expect(form['plan_type'], 'paid');
      expect(form['apple_product_id'], '');
      expect(form['is_one_time_purchase'], isTrue);
      expect(form['allow_referral_code'], isFalse);
    });

    test('update request adds the session institute and keeps nulls', () {
      final req = subscriptionUpdateRequest(
        7,
        subscriptionWithPurchaseFlags({'name': 'x', 'price': null, 'allow_referral_code': true}),
      );
      expect(req['institute_id'], 7);
      expect(req.containsKey('price'), isTrue);
      expect(req['allow_referral_code'], 1);
      expect(req['is_one_time_purchase'], 0);
    });

    test('flag parsing', () {
      expect(subscriptionFlag(true), isTrue);
      expect(subscriptionFlag(1), isTrue);
      expect(subscriptionFlag('true'), isTrue);
      expect(subscriptionFlag('1'), isTrue);
      expect(subscriptionFlag(0), isFalse);
      expect(subscriptionFlag('yes'), isFalse);
      expect(subscriptionFlag(null), isFalse);
    });
  });
}
