import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart' show ApiError;
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
// JavaScript semantics the web code relies on (pure, unit-tested).
// ─────────────────────────────────────────────────────────────────────────────

final _decimal = RegExp(r'^(\d*)(?:\.(\d*))?(?:[eE]([+-]?\d+))?$');
final _radix = RegExp(r'^0([xXoObB])([0-9a-fA-F]+)$');

/// JS `Number(v)` as it ends up in a JSON payload: `null` → 0, `''` → 0,
/// `'12'` → 12, `'1.5'` → 1.5, `'0x10'` → 16, `true` → 1. `NaN`/`Infinity`
/// (e.g. `Number('abc')`) are serialised as `null` by `JSON.stringify`, so
/// they come back as `null`. Whole numbers are returned as [int] so they are
/// encoded as `12`, not `12.0`.
num? planNumber(Object? v) {
  final double d;
  if (v == null) {
    d = 0;
  } else if (v is bool) {
    d = v ? 1 : 0;
  } else if (v is num) {
    d = v.toDouble();
  } else if (v is String) {
    d = _parseJsNumber(v);
  } else {
    return null;
  }
  if (d.isNaN || d.isInfinite) return null;
  if (d == d.truncateToDouble() && d.abs() <= 9007199254740991) return d.toInt();
  return d;
}

double _parseJsNumber(String s) {
  var t = s.trim();
  if (t.isEmpty) return 0;
  var sign = 1.0;
  if (t.startsWith('+') || t.startsWith('-')) {
    final rest = t.substring(1);
    // Signs are only allowed on decimal literals / Infinity, not on 0x…
    if (_radix.hasMatch(rest)) return double.nan;
    if (t[0] == '-') sign = -1;
    t = rest;
  }
  if (t == 'Infinity') return sign * double.infinity;
  final radix = _radix.firstMatch(t);
  if (radix != null) {
    final base = switch (radix[1]!.toLowerCase()) { 'x' => 16, 'o' => 8, _ => 2 };
    final n = int.tryParse(radix[2]!, radix: base);
    return n == null ? double.nan : n.toDouble();
  }
  final m = _decimal.firstMatch(t);
  if (m == null) return double.nan;
  final whole = m[1] ?? '';
  final frac = m[2] ?? '';
  if (whole.isEmpty && frac.isEmpty) return double.nan;
  final exp = m[3] == null ? '' : 'e${m[3]}';
  final parsed = double.tryParse('${whole.isEmpty ? '0' : whole}.${frac.isEmpty ? '0' : frac}$exp');
  return parsed == null ? double.nan : sign * parsed;
}

/// Vue's `{{ v }}` / `String(v)` for the scalar values the API returns:
/// `null` → `''`, `1500.0` → `'1500'`.
String planText(Object? v) {
  if (v == null) return '';
  if (v is double) {
    if (v.isNaN) return 'NaN';
    if (v.isInfinite) return v > 0 ? 'Infinity' : '-Infinity';
    if (v == v.truncateToDouble() && v.abs() < 1e21) return v.toInt().toString();
  }
  return v.toString();
}

/// The property key a JS object uses for `obj[v]` (`obj[5]` and `obj['5']`
/// are the same entry) — `zslPlansByClass` is keyed this way.
String planKey(Object? v) => v is num ? planText(v) : '$v';

/// The value of an `<input type="number">`: the browser reports `''` while the
/// text is not a valid floating-point number.
String htmlNumberInputValue(String text) =>
    RegExp(r'^-?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?$').hasMatch(text) ? text : '';

/// Whether an API `message` (toasted automatically by the API client) is the
/// same text a page is about to toast (case, spacing and a trailing `.`/`!`
/// ignored).
bool isSameToastText(Object? apiMessage, String text) {
  if (apiMessage is! String) return false;
  String norm(String s) => s.trim().toLowerCase().replaceAll(RegExp(r'\s+'), ' ').replaceAll(RegExp(r'[.!]+$'), '');
  return norm(apiMessage) == norm(text);
}

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sept', 'Oct', 'Nov', 'Dec'];

/// `formatDate(dateStr)` of the plan pages:
/// `new Date(s).toLocaleString('en-IN', {year:'numeric', month:'short',
/// day:'2-digit', hour:'2-digit', minute:'2-digit'})` → `05 Nov 2025, 02:30 pm`
/// (local time). Empty → `''`, unparsable → `'Invalid Date'`.
String formatPlanDate(Object? value) {
  if (!jsTruthy(value)) return '';
  final parsed = DateTime.tryParse(planText(value));
  if (parsed == null) return 'Invalid Date';
  final d = parsed.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  final h12 = d.hour % 12 == 0 ? 12 : d.hour % 12;
  return '${two(d.day)} ${_months[d.month - 1]} ${d.year}, ${two(h12)}:${two(d.minute)} ${d.hour < 12 ? 'am' : 'pm'}';
}

// ─────────────────────────────────────────────────────────────────────────────
// `subscriptionForm`
// ─────────────────────────────────────────────────────────────────────────────

/// Scalar keys of `useUserStore().subscriptionForm`, in store order.
const institutePlanFormKeys = [
  'id',
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
];

/// Keys the payload sends through `Number(...)`.
const _numericKeys = [
  'price',
  'days',
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
];

/// One `subscriptionForm.zsl_classes` entry: `{ class_id, zsl_plan_id }`.
class InstitutePlanClassAccess {
  const InstitutePlanClassAccess({required this.classId, this.zslPlanId});
  final int classId;

  /// The selected ZSL plan's `id` as the API returned it (or `null`).
  final Object? zslPlanId;

  @override
  bool operator ==(Object other) =>
      other is InstitutePlanClassAccess && other.classId == classId && other.zslPlanId == zslPlanId;

  @override
  int get hashCode => Object.hash(classId, zslPlanId);

  @override
  String toString() => '{class_id: $classId, zsl_plan_id: $zslPlanId}';
}

/// `useUserStore().subscriptionForm`. Scalar [values] keep whatever the user
/// typed or the API returned (string, number or null), like the web.
class InstitutePlanForm {
  const InstitutePlanForm({
    required this.values,
    this.zslClasses = const [],
    this.classId = const [],
    this.zslPlans = const [],
  });

  /// The `resetPlan()` / initial state: every scalar is `''`.
  factory InstitutePlanForm.empty() => InstitutePlanForm(values: {for (final k in institutePlanFormKeys) k: ''});

  /// `getPlanById(planId)`: maps the API plan onto the form.
  factory InstitutePlanForm.fromPlan(Map<String, dynamic> res) {
    final zslPlans = res['zsl_plans'];
    final plans = [for (final p in asList(zslPlans)) ?asMap(p)];
    int? classIdOf(Map<String, dynamic> p) => asInt(planNumber(p['class_id']));
    return InstitutePlanForm(
      values: {for (final k in institutePlanFormKeys) k: res[k]},
      zslClasses: jsTruthy(zslPlans)
          ? [
              for (final p in plans)
                if (classIdOf(p) != null) InstitutePlanClassAccess(classId: classIdOf(p)!, zslPlanId: p['id']),
            ]
          : const [],
      classId: zslPlans is List ? [for (final p in plans) ?classIdOf(p)] : const [],
      zslPlans: plans,
    );
  }

  final Map<String, dynamic> values;
  final List<InstitutePlanClassAccess> zslClasses;
  final List<int> classId;
  final List<Map<String, dynamic>> zslPlans;

  dynamic operator [](String key) => values[key];

  InstitutePlanForm copyWith({
    Map<String, dynamic>? values,
    List<InstitutePlanClassAccess>? zslClasses,
    List<int>? classId,
    List<Map<String, dynamic>>? zslPlans,
  }) =>
      InstitutePlanForm(
        values: values ?? this.values,
        zslClasses: zslClasses ?? this.zslClasses,
        classId: classId ?? this.classId,
        zslPlans: zslPlans ?? this.zslPlans,
      );
}

Map<String, dynamic> _scalarPayload(InstitutePlanForm f) => {
      for (final k in institutePlanFormKeys)
        if (k != 'id') k: _numericKeys.contains(k) ? planNumber(f[k]) : f[k],
    };

/// `submitSubscriptionForm(payload)` → the body POSTed to `institute/plan`:
/// every count/price through `Number()`, plus the selected ZSL plan ids
/// (also through `Number()`).
Map<String, dynamic> buildCreatePlanPayload(InstitutePlanForm f) => {
      ..._scalarPayload(f),
      'zsl_plan_ids': [
        for (final c in f.zslClasses)
          if (c.zslPlanId != null) planNumber(c.zslPlanId),
      ],
    };

/// `updatePlan()` → the body PUT to `/institute/plan/{id}` (the `id` itself is
/// destructured out; the ZSL plan ids are sent as-is, without `Number()`).
Map<String, dynamic> buildUpdatePlanPayload(InstitutePlanForm f) => {
      ..._scalarPayload(f),
      'zsl_plan_ids': [
        for (final c in f.zslClasses)
          if (c.zslPlanId != null) c.zslPlanId,
      ],
    };

/// The tail of `InstituteplanCreate.vue`'s `form.class_id` watcher: append an
/// entry for every newly selected class that exists in `allclasses`, then drop
/// the entries whose class is no longer selected.
List<InstitutePlanClassAccess> syncCreateZslClasses(
  List<InstitutePlanClassAccess> current,
  List<int> newIds,
  List<Map<String, dynamic>> allClasses,
) {
  final out = [...current];
  for (final id in newIds) {
    if (out.any((c) => c.classId == id)) continue;
    for (final cls in allClasses) {
      final clsId = asInt(cls['id']);
      if (clsId == id) {
        out.add(InstitutePlanClassAccess(classId: clsId!));
        break;
      }
    }
  }
  return [for (final c in out) if (newIds.contains(c.classId)) c];
}

/// The tail of `InstituteplanUpdate.vue`'s `form.class_id` watcher: one entry
/// per selected class (in selection order), keeping existing selections.
List<InstitutePlanClassAccess> syncUpdateZslClasses(
  List<InstitutePlanClassAccess> current,
  List<int> newIds,
) =>
    [
      for (final id in newIds)
        current.firstWhere((c) => c.classId == id, orElse: () => InstitutePlanClassAccess(classId: id)),
    ];

// ─────────────────────────────────────────────────────────────────────────────
// Store slice
// ─────────────────────────────────────────────────────────────────────────────

/// The institute-plan slice of `useUserStore`: `subscriptionForm`,
/// `allClasses`, `zslPlansByClass` and `plan`.
class InstitutePlanState {
  const InstitutePlanState({
    required this.subscriptionForm,
    this.allClasses = const [],
    this.zslPlansByClass = const {},
    this.plan,
  });

  final InstitutePlanForm subscriptionForm;
  final List<Map<String, dynamic>> allClasses;

  /// `zslPlansByClass[classId]`, keyed by [planKey] like a JS object.
  final Map<String, List<Map<String, dynamic>>> zslPlansByClass;

  /// `store.plan` (the last `getPlanById` / `updatePlan` response).
  final dynamic plan;

  /// `getPlansByClass(classId)`: `zslPlansByClass[classId] || []`.
  List<Map<String, dynamic>> plansByClass(Object? classId) => zslPlansByClass[planKey(classId)] ?? const [];

  InstitutePlanState copyWith({
    InstitutePlanForm? subscriptionForm,
    List<Map<String, dynamic>>? allClasses,
    Map<String, List<Map<String, dynamic>>>? zslPlansByClass,
    dynamic plan,
  }) =>
      InstitutePlanState(
        subscriptionForm: subscriptionForm ?? this.subscriptionForm,
        allClasses: allClasses ?? this.allClasses,
        zslPlansByClass: zslPlansByClass ?? this.zslPlansByClass,
        plan: plan ?? this.plan,
      );
}

class InstitutePlanController extends Notifier<InstitutePlanState> {
  @override
  InstitutePlanState build() => InstitutePlanState(subscriptionForm: InstitutePlanForm.empty());

  /// Current state for code that outlives the page (the web's async watchers
  /// keep mutating the store after the component is gone).
  InstitutePlanState get current => state;

  static List<Map<String, dynamic>> _maps(dynamic list) => [for (final e in asList(list)) ?asMap(e)];

  /// `res?.data || res || []`
  static dynamic _dataOr(dynamic res) {
    final data = asMap(res)?['data'];
    if (jsTruthy(data)) return data;
    if (jsTruthy(res)) return res;
    return const [];
  }

  InstitutePlanForm get _form => state.subscriptionForm;

  void _setForm(InstitutePlanForm form) => state = state.copyWith(subscriptionForm: form);

  void _setPlansFor(Object? classId, List<Map<String, dynamic>> plans) =>
      state = state.copyWith(zslPlansByClass: {...state.zslPlansByClass, planKey(classId): plans});

  // ── Store actions ──

  /// `resetPlan()`
  void resetPlan() => _setForm(InstitutePlanForm.empty());

  /// `getAllClasses()` → `zsl.getClassAll()`; `response.data || response || []`.
  Future<List<Map<String, dynamic>>> getAllClasses() async {
    try {
      final res = await ref.read(zslServiceProvider).getClassAll();
      final classes = _maps(_dataOr(res));
      state = state.copyWith(allClasses: classes);
      return classes;
    } catch (_) {
      state = state.copyWith(allClasses: const []);
      rethrow;
    }
  }

  /// `fetchZslPlansByClass(zslClassId)` — the web hard-codes `instituteId = 1`.
  Future<List<Map<String, dynamic>>> fetchZslPlansByClass(int zslClassId) async {
    const instituteId = 1;
    try {
      final res = await ref.read(instituteServiceProvider).getZslPlans(instituteId, zslClassId);
      final plans = _maps(_dataOr(res));
      _setPlansFor(zslClassId, plans);
      return plans;
    } catch (_) {
      _setPlansFor(zslClassId, const []);
      rethrow;
    }
  }

  /// `submitSubscriptionForm(payload)`: POST, then reset the form.
  Future<void> submitSubscriptionForm(InstitutePlanForm payload) async {
    await ref.read(instituteServiceProvider).createPlan(buildCreatePlanPayload(payload));
    _setForm(InstitutePlanForm.empty());
  }

  /// `getPlanById(planId)`: loads the plan into `subscriptionForm` and `plan`.
  Future<dynamic> getPlanById(Object planId) async {
    final res = await ref.read(instituteServiceProvider).getPlanById(planId);
    // The web reads `res.id` straight away, which throws on a null body.
    if (res == null) throw const ApiError('Plan not found');
    state = state.copyWith(
      subscriptionForm: InstitutePlanForm.fromPlan(asMap(res) ?? const {}),
      plan: res,
    );
    return res;
  }

  /// `updatePlan()`: PUT `subscriptionForm` (without its `id`).
  Future<dynamic> updatePlan() async {
    final id = _form['id'];
    if (!jsTruthy(id)) throw const ApiError('Plan ID missing');
    final res = await ref.read(instituteServiceProvider).updatePlan(id as Object, buildUpdatePlanPayload(_form));
    state = state.copyWith(plan: res);
    return res;
  }

  /// `deletePlan(planId)`
  Future<dynamic> deletePlan(Object planId) => ref.read(instituteServiceProvider).deletePlan(planId);

  // ── Direct writes the components make to store state (v-model etc.) ──

  /// `v-model="form[key]"`
  void setFormValue(String key, dynamic value) => _setForm(_form.copyWith(values: {..._form.values, key: value}));

  /// `v-model="form.class_id"` (the multi-select).
  void setClassIds(List<int> ids) => _setForm(_form.copyWith(classId: ids));

  /// `v-model="item.zsl_plan_id"` of the `zsl_classes` row for [classId]
  /// (rows are keyed by `class_id`).
  void setZslPlanId(int classId, Object? zslPlanId) {
    final list = [..._form.zslClasses];
    final index = list.indexWhere((c) => c.classId == classId);
    if (index < 0) return;
    list[index] = InstitutePlanClassAccess(classId: classId, zslPlanId: zslPlanId);
    _setForm(_form.copyWith(zslClasses: list));
  }

  /// Create page watcher tail (see [syncCreateZslClasses]).
  void syncZslClassesForCreate(List<int> newIds) =>
      _setForm(_form.copyWith(zslClasses: syncCreateZslClasses(_form.zslClasses, newIds, state.allClasses)));

  /// Update page watcher tail (see [syncUpdateZslClasses]).
  void syncZslClassesForUpdate(List<int> newIds) =>
      _setForm(_form.copyWith(zslClasses: syncUpdateZslClasses(_form.zslClasses, newIds)));

  /// Update page `mounted`: `if (!zslPlansByClass[plan.class_id])
  /// zslPlansByClass[plan.class_id] = [plan]`.
  void cachePlanIfMissing(Map<String, dynamic> plan) {
    final key = planKey(plan['class_id']);
    if (state.zslPlansByClass.containsKey(key)) return;
    _setPlansFor(plan['class_id'], [plan]);
  }

  // ── Component-level service calls (not store actions) ──

  /// `loadPlans()` of the list/create pages: `instituteService.getPlans()`,
  /// then `res.data.data` / `res.data` / `res`, whichever is an array.
  Future<List<Map<String, dynamic>>> loadPlanList() async =>
      _maps(unwrapList(await ref.read(instituteServiceProvider).getPlans()));

  /// `openViewDialog(id)`: `instituteService.getPlanById(id)`, `res?.data ?? res`.
  Future<dynamic> fetchPlanDetails(Object id) async {
    final res = await ref.read(instituteServiceProvider).getPlanById(id);
    return asMap(res)?['data'] ?? res;
  }
}

final institutePlanControllerProvider =
    NotifierProvider<InstitutePlanController, InstitutePlanState>(InstitutePlanController.new);
