import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/json.dart';
import '../../core/utils/pagination.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';

// ───────────────────────── Pure form / payload helpers ─────────────────────────
//
// Dart has no `undefined`: in these form maps `null` stands for the web's
// `undefined` (which `JSON.stringify` drops from the request body).

/// `form` of subscription.vue (and the reset after creating).
Map<String, dynamic> subscriptionEmptyForm() => {
      'institute_id': null,
      'classes_id': null,
      'name': '',
      'days': null,
      'price': null,
      'max_classes': null,
      'all_classes': false,
      'is_active': false,
      'is_public': false,
      'plan_type': '',
      'has_full_access': false,
      'discount_price': null,
      'final_price': null,
      'apple_product_id': '',
      'apple_price': null,
      'is_one_time_purchase': false,
      'allow_referral_code': false,
    };

/// `editForm` of subscription.vue before a plan is loaded.
Map<String, dynamic> subscriptionEmptyEditForm() =>
    subscriptionEmptyForm()..remove('institute_id')..remove('classes_id');

/// `{...form, is_one_time_purchase: x ? 1 : 0, allow_referral_code: y ? 1 : 0}`
/// (`submitForm` and `submitEditForm`).
Map<String, dynamic> subscriptionWithPurchaseFlags(Map<String, dynamic> form) => {
      ...form,
      'is_one_time_purchase': jsTruthy(form['is_one_time_purchase']) ? 1 : 0,
      'allow_referral_code': jsTruthy(form['allow_referral_code']) ? 1 : 0,
    };

/// `createappSubscriptionPlan`: `{institute_id: userInfo.institute_id, ...payload}`.
/// The form always carries `institute_id`, so an unselected institute
/// (`undefined`) overrides the session's and is dropped with every other
/// undefined field.
Map<String, dynamic> subscriptionCreateRequest(int? sessionInstituteId, Map<String, dynamic> payload) =>
    {'institute_id': sessionInstituteId, ...payload}..removeWhere((_, v) => v == null);

/// `updateAppSubscriptionPlan`: `{institute_id: userInfo.institute_id, ...payload}`.
Map<String, dynamic> subscriptionUpdateRequest(int? sessionInstituteId, Map<String, dynamic> payload) =>
    {'institute_id': sessionInstituteId, ...payload};

/// `plan.x === true || plan.x === 1 || plan.x === 'true' || plan.x === '1'`
bool subscriptionFlag(Object? v) => v == true || v == 1 || v == 'true' || v == '1';

/// `openEditDialog`: the edit form built from the loaded plan. Keys the plan
/// lacks stay out (the web's `undefined`), `null`s are kept.
Map<String, dynamic> subscriptionEditFormFrom(Map<String, dynamic> plan) {
  Object? or(String key, Object fallback) => jsTruthy(plan[key]) ? plan[key] : fallback;
  return {
    'name': or('name', ''),
    if (plan.containsKey('days')) 'days': plan['days'],
    if (plan.containsKey('price')) 'price': plan['price'],
    if (plan.containsKey('discount_price')) 'discount_price': plan['discount_price'],
    if (plan.containsKey('final_price')) 'final_price': plan['final_price'],
    if (plan.containsKey('max_classes')) 'max_classes': plan['max_classes'],
    'all_classes': or('all_classes', false),
    'is_active': or('is_active', false),
    'is_public': or('is_public', false),
    'plan_type': or('plan_type', ''),
    'has_full_access': or('has_full_access', false),
    'apple_product_id': or('apple_product_id', ''),
    if (plan.containsKey('apple_price')) 'apple_price': plan['apple_price'],
    'is_one_time_purchase': subscriptionFlag(plan['is_one_time_purchase']),
    'allow_referral_code': subscriptionFlag(plan['allow_referral_code']),
  };
}

// ───────────────────────── Controller ─────────────────────────

/// The slice of `useUserStore` the role-wise subscription screen maps:
/// `ALLinstitutes` (+ `institutePagination`) and `classes`.
class SubscriptionState {
  const SubscriptionState({
    this.allInstitutes = const [],
    this.institutePagination = PageMeta.empty,
    this.classes = const [],
  });

  /// `ALLinstitutes`
  final List<Map<String, dynamic>> allInstitutes;
  final PageMeta institutePagination;

  /// `classes`: `{id, name, status}` of the last `getClasses` call.
  final List<Map<String, dynamic>> classes;

  SubscriptionState copyWith({
    List<Map<String, dynamic>>? allInstitutes,
    PageMeta? institutePagination,
    List<Map<String, dynamic>>? classes,
  }) =>
      SubscriptionState(
        allInstitutes: allInstitutes ?? this.allInstitutes,
        institutePagination: institutePagination ?? this.institutePagination,
        classes: classes ?? this.classes,
      );
}

/// Store actions used by `subscription.vue`, ported 1:1.
class SubscriptionController extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() => const SubscriptionState();

  int? get _instituteId => ref.read(sessionProvider).instituteId;
  AppSubscriptionService get _plans => ref.read(appSubscriptionServiceProvider);

  /// `getInstitutes(page, per_page, paginate)`
  Future<void> getInstitutes([int page = 1, int perPage = 10, bool paginate = true]) async {
    final res = await ref.read(instituteServiceProvider).getInstitutes(page, perPage, paginate);
    final m = asMap(res);
    final isPaginated = m != null && jsTruthy(m['data']);
    final data = asList(isPaginated ? m['data'] : res);

    state = state.copyWith(
      allInstitutes: [
        for (final e in data)
          if (asMap(e) case final inst?)
            {
              'id': inst['id'],
              'name': inst['name'],
              'phone': inst['phone'],
              'email': jsTruthy(inst['email']) ? inst['email'] : '',
              'expires_on': jsTruthy(inst['expires_on']) ? inst['expires_on'] : null,
              'instructors_count': jsTruthy(inst['instructors_count']) ? inst['instructors_count'] : '0',
              'students_count': jsTruthy(inst['students_count']) ? inst['students_count'] : '0',
              'plan_name': jsTruthy(asMap(inst['plan'])?['name']) ? asMap(inst['plan'])!['name'] : 'N/A',
            },
      ],
      institutePagination: PageMeta(
        currentPage: isPaginated ? asInt(m['current_page']) ?? 1 : 1,
        lastPage: isPaginated ? math.max(1, asInt(m['last_page']) ?? 1) : 1,
        total: isPaginated ? asInt(m['total']) ?? 0 : data.length,
        perPage: isPaginated ? asInt(m['per_page']) ?? perPage : data.length,
      ),
    );
  }

  /// `getClasses(institute_id_or_filter, filter)`: the institute's classes
  /// (optionally only `published`), each with its `/class/counts` request
  /// like the web, mapped to `classes = [{id, name, status}]`.
  Future<void> getClasses([Object? instituteIdOrFilter, String? filter]) async {
    Object? instituteId;
    String? finalFilter;
    if (instituteIdOrFilter == 'published') {
      instituteId = _instituteId;
      finalFilter = 'published';
    } else {
      instituteId = jsTruthy(instituteIdOrFilter) ? instituteIdOrFilter : _instituteId;
      finalFilter = filter;
    }
    if (instituteId == null || !jsTruthy(instituteId)) return;
    final Object id = instituteId;

    final classService = ref.read(classServiceProvider);
    final data = [for (final e in asList(await classService.getAllClasses(id))) ?asMap(e)];
    final filtered = finalFilter == 'published' ? data.where((c) => c['status'] == 'published') : data;

    final mapped = await Future.wait(filtered.map((item) async {
      // The counts feed the store's `institutes` rows (class list screens);
      // they are fetched here too because the web action always does.
      await classService.getClassesCount(id, item['id'] ?? '');
      return {
        'id': item['id'],
        'name': item['name'],
        'status': item['status'] ?? 'unknown',
      };
    }));

    state = state.copyWith(classes: mapped);
  }

  /// `createappSubscriptionPlan(payload)`
  Future<dynamic> createappSubscriptionPlan(Map<String, dynamic> payload) =>
      _plans.createappPlan(subscriptionCreateRequest(_instituteId, payload));

  /// `getAppSubscriptionPlans(payload)`: sends `institute_id`, `classes_id`
  /// (= `class_id`) and the payload itself as query parameters.
  Future<dynamic> getAppSubscriptionPlans([Map<String, dynamic>? payload]) => _plans.getAppPlans({
        'institute_id': payload?['institute_id'],
        'classes_id': payload?['class_id'],
        ...?payload,
      });

  /// `getAppSubscriptionPlanById(planId)`
  Future<dynamic> getAppSubscriptionPlanById(Object planId) => _plans.getAppPlanById(planId);

  /// `updateAppSubscriptionPlan(id, payload)`
  Future<dynamic> updateAppSubscriptionPlan(Object id, Map<String, dynamic> payload) =>
      _plans.updateAppPlan(id, subscriptionUpdateRequest(_instituteId, payload));
}

final subscriptionControllerProvider =
    NotifierProvider<SubscriptionController, SubscriptionState>(SubscriptionController.new);
