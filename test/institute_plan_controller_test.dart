import 'package:elab_app/core/network/api_client.dart';
import 'package:elab_app/data/services/services.dart';
import 'package:elab_app/features/plans/institute_plan_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

ApiClient _api() => ApiClient(tokenReader: () => null, onUnauthorized: () async {});

class _FakeInstituteService extends InstituteService {
  _FakeInstituteService() : super(_api());

  final calls = <List<Object?>>[];
  dynamic planResponse;
  dynamic zslPlansResponse;

  @override
  Future<dynamic> createPlan(Map<String, dynamic> payload) async {
    calls.add(['createPlan', payload]);
    return {'status': true};
  }

  @override
  Future<dynamic> getPlanById(Object planId) async {
    calls.add(['getPlanById', planId]);
    return planResponse;
  }

  @override
  Future<dynamic> updatePlan(Object planId, Map<String, dynamic> payload) async {
    calls.add(['updatePlan', planId, payload]);
    return {'id': planId};
  }

  @override
  Future<dynamic> getZslPlans(Object instituteId, Object zslClassId) async {
    calls.add(['getZslPlans', instituteId, zslClassId]);
    return zslPlansResponse;
  }

  @override
  Future<dynamic> getPlans() async => {
        'data': {
          'data': [
            {'id': 1, 'name': 'Gold'},
          ],
        },
      };
}

class _FakeZslService extends ZslService {
  _FakeZslService(this.response) : super(_api(), () => throw UnimplementedError());
  final dynamic response;

  @override
  Future<dynamic> getClassAll() async => response;
}

InstitutePlanForm _form(Map<String, dynamic> values, {List<InstitutePlanClassAccess> zsl = const []}) =>
    InstitutePlanForm(values: {...InstitutePlanForm.empty().values, ...values}, zslClasses: zsl);

void main() {
  group('planNumber (JS Number() → JSON)', () {
    test('empty / null / booleans', () {
      expect(planNumber(null), 0);
      expect(planNumber(''), 0);
      expect(planNumber('   '), 0);
      expect(planNumber(true), 1);
      expect(planNumber(false), 0);
    });

    test('decimal strings, whole numbers become int', () {
      expect(planNumber(' 12 '), isA<int>().having((v) => v, 'value', 12));
      expect(planNumber('1500.00'), isA<int>().having((v) => v, 'value', 1500));
      expect(planNumber('1.5'), 1.5);
      expect(planNumber('5.'), 5);
      expect(planNumber('.5'), 0.5);
      expect(planNumber('-3'), -3);
      expect(planNumber('+7'), 7);
      expect(planNumber('1e3'), 1000);
      expect(planNumber(12.0), isA<int>());
      expect(planNumber(2.25), 2.25);
    });

    test('radix literals', () {
      expect(planNumber('0x10'), 16);
      expect(planNumber('0b101'), 5);
      expect(planNumber('0o17'), 15);
      expect(planNumber('-0x10'), isNull);
    });

    test('NaN / Infinity serialise as null', () {
      expect(planNumber('abc'), isNull);
      expect(planNumber('1,000'), isNull);
      expect(planNumber('e5'), isNull);
      expect(planNumber('.'), isNull);
      expect(planNumber('Infinity'), isNull);
      expect(planNumber('1e400'), isNull);
      expect(planNumber(const {'a': 1}), isNull);
    });
  });

  test('planText / planKey follow JS String()', () {
    expect(planText(null), '');
    expect(planText(1500.0), '1500');
    expect(planText(12.5), '12.5');
    expect(planText(7), '7');
    expect(planText('x'), 'x');
    expect(planKey(5), '5');
    expect(planKey(5.0), '5');
    expect(planKey('5'), '5');
  });

  test('htmlNumberInputValue sanitises like <input type="number">', () {
    expect(htmlNumberInputValue('12'), '12');
    expect(htmlNumberInputValue('-1.5'), '-1.5');
    expect(htmlNumberInputValue('2e3'), '2e3');
    expect(htmlNumberInputValue('1e'), '');
    expect(htmlNumberInputValue('-'), '');
    expect(htmlNumberInputValue('1.2.3'), '');
  });

  test('formatPlanDate matches en-IN toLocaleString', () {
    expect(formatPlanDate(null), '');
    expect(formatPlanDate(''), '');
    expect(formatPlanDate('not a date'), 'Invalid Date');
    expect(formatPlanDate('2025-09-05 14:07:00'), '05 Sept 2025, 02:07 pm');
    expect(formatPlanDate('2025-01-01 00:05:00'), '01 Jan 2025, 12:05 am');
    expect(formatPlanDate('2025-03-10 12:30:00'), '10 Mar 2025, 12:30 pm');
  });

  test('isSameToastText', () {
    expect(isSameToastText('Plan deleted successfully.', 'Plan deleted successfully'), isTrue);
    expect(isSameToastText(' plan  DELETED successfully ', 'Plan deleted successfully'), isTrue);
    expect(isSameToastText('Deleted', 'Plan deleted successfully'), isFalse);
    expect(isSameToastText(null, 'Plan deleted successfully'), isFalse);
  });

  group('payload builders', () {
    test('create: Number() on counts/prices and zsl ids, no id key, store key order', () {
      final form = _form(
        {
          'id': 99,
          'name': 'Gold',
          'price': '1500.50',
          'days': '30',
          'description': 'desc',
          'cost_per_book': 'abc',
          'display_price': '999',
          'display_description': 'shown',
        },
        zsl: const [
          InstitutePlanClassAccess(classId: 1, zslPlanId: 7),
          InstitutePlanClassAccess(classId: 2),
          InstitutePlanClassAccess(classId: 3, zslPlanId: '9'),
        ],
      );
      final p = buildCreatePlanPayload(form);
      expect(p.keys.toList(), [
        'name',
        'price',
        'days',
        'description',
        'students',
        'cost_per_student',
        'instructors',
        'cost_per_instructor',
        'classes',
        'cost_per_class',
        'courses',
        'cost_per_course',
        'books',
        'cost_per_book',
        'display_price',
        'display_description',
        'zsl_plan_ids',
      ]);
      expect(p['name'], 'Gold');
      expect(p['price'], 1500.5);
      expect(p['days'], 30);
      expect(p['students'], 0);
      expect(p['cost_per_book'], isNull);
      expect(p['display_price'], 999);
      expect(p['display_description'], 'shown');
      expect(p['zsl_plan_ids'], [7, 9]);
    });

    test('update: raw zsl ids, API values through Number()', () {
      final form = _form(
        {'id': 3, 'name': 'P', 'price': '10.00', 'days': 30, 'students': null, 'description': null},
        zsl: const [
          InstitutePlanClassAccess(classId: 1, zslPlanId: 7),
          InstitutePlanClassAccess(classId: 2),
          InstitutePlanClassAccess(classId: 3, zslPlanId: '9'),
        ],
      );
      final p = buildUpdatePlanPayload(form);
      expect(p.containsKey('id'), isFalse);
      expect(p['price'], 10);
      expect(p['days'], 30);
      expect(p['students'], 0);
      expect(p['description'], isNull);
      expect(p['zsl_plan_ids'], [7, '9']);
    });
  });

  group('form / zsl_classes sync', () {
    test('fromPlan maps zsl_plans to class_id + zsl_classes', () {
      final f = InstitutePlanForm.fromPlan({
        'id': 3,
        'name': 'P',
        'price': '10.00',
        'zsl_plans': [
          {'id': 11, 'class_id': '4', 'class_name': 'C4'},
          {'id': 12, 'class_id': 5},
        ],
      });
      expect(f['id'], 3);
      expect(f['price'], '10.00');
      expect(f['students'], isNull);
      expect(f.classId, [4, 5]);
      expect(f.zslClasses, const [
        InstitutePlanClassAccess(classId: 4, zslPlanId: 11),
        InstitutePlanClassAccess(classId: 5, zslPlanId: 12),
      ]);
      expect(f.zslPlans, hasLength(2));

      final empty = InstitutePlanForm.fromPlan({'id': 1, 'zsl_plans': null});
      expect(empty.classId, isEmpty);
      expect(empty.zslClasses, isEmpty);
    });

    test('create watcher: append known classes, drop deselected ones', () {
      const classes = [
        {'id': 1, 'name': 'A'},
        {'id': 2, 'name': 'B'},
      ];
      expect(
        syncCreateZslClasses(const [InstitutePlanClassAccess(classId: 1, zslPlanId: 7)], [1, 2, 3], classes),
        const [InstitutePlanClassAccess(classId: 1, zslPlanId: 7), InstitutePlanClassAccess(classId: 2)],
      );
      expect(
        syncCreateZslClasses(
          const [InstitutePlanClassAccess(classId: 1, zslPlanId: 7), InstitutePlanClassAccess(classId: 2)],
          [2],
          classes,
        ),
        const [InstitutePlanClassAccess(classId: 2)],
      );
    });

    test('update watcher: one row per selected class in selection order', () {
      expect(
        syncUpdateZslClasses(
          const [InstitutePlanClassAccess(classId: 1, zslPlanId: 7), InstitutePlanClassAccess(classId: 2, zslPlanId: 8)],
          [2, 3],
        ),
        const [InstitutePlanClassAccess(classId: 2, zslPlanId: 8), InstitutePlanClassAccess(classId: 3)],
      );
    });
  });

  group('InstitutePlanController', () {
    late _FakeInstituteService institute;
    late ProviderContainer container;

    setUp(() {
      institute = _FakeInstituteService();
      container = ProviderContainer(overrides: [
        instituteServiceProvider.overrideWithValue(institute),
        zslServiceProvider.overrideWithValue(_FakeZslService({
          'data': [
            {'id': 1, 'name': 'Class 1'},
          ],
        })),
      ]);
    });

    tearDown(() => container.dispose());

    InstitutePlanController ctrl() => container.read(institutePlanControllerProvider.notifier);
    InstitutePlanState state() => container.read(institutePlanControllerProvider);

    test('getAllClasses / fetchZslPlansByClass unwrap `data || res` (institute 1)', () async {
      await ctrl().getAllClasses();
      expect(state().allClasses.single['name'], 'Class 1');

      institute.zslPlansResponse = [
        {'id': 7, 'class_id': 1},
      ];
      await ctrl().fetchZslPlansByClass(1);
      expect(institute.calls.last, ['getZslPlans', 1, 1]);
      expect(state().plansByClass(1).single['id'], 7);
      expect(state().plansByClass('1').single['id'], 7);
    });

    test('getPlanById fills the form; updatePlan PUTs it without the id', () async {
      institute.planResponse = {
        'id': 3,
        'name': 'Silver',
        'price': '10.00',
        'zsl_plans': [
          {'id': 11, 'class_id': 4, 'class_name': 'C4'},
        ],
      };
      await ctrl().getPlanById(3);
      expect(state().subscriptionForm['name'], 'Silver');
      expect(state().subscriptionForm.classId, [4]);

      ctrl().cachePlanIfMissing({'id': 11, 'class_id': 4});
      ctrl().cachePlanIfMissing({'id': 12, 'class_id': 4});
      expect(state().plansByClass(4).map((p) => p['id']), [11]);

      ctrl().setFormValue('name', 'Gold');
      ctrl().setZslPlanId(4, 12);
      await ctrl().updatePlan();
      final call = institute.calls.last;
      expect(call[0], 'updatePlan');
      expect(call[1], 3);
      final payload = call[2]! as Map<String, dynamic>;
      expect(payload['name'], 'Gold');
      expect(payload['price'], 10);
      expect(payload['zsl_plan_ids'], [12]);
      expect(payload.containsKey('id'), isFalse);
    });

    test('updatePlan without an id throws before calling the API', () async {
      await expectLater(ctrl().updatePlan(), throwsA(isA<ApiError>()));
      expect(institute.calls, isEmpty);
    });

    test('submitSubscriptionForm posts and resets the form', () async {
      ctrl().setFormValue('name', 'New');
      ctrl().setFormValue('days', '15');
      await ctrl().submitSubscriptionForm(state().subscriptionForm);
      final payload = institute.calls.last[1]! as Map<String, dynamic>;
      expect(payload['name'], 'New');
      expect(payload['days'], 15);
      expect(state().subscriptionForm['name'], '');
    });

    test('loadPlanList unwraps res.data.data', () async {
      final plans = await ctrl().loadPlanList();
      expect(plans.single['name'], 'Gold');
    });
  });
}
