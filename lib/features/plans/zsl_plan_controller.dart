import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/json.dart';
import '../../core/utils/pagination.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';

const _unset = Object();

/// The class-access-type (ZSL plan) slice of `useUserStore` shared by
/// `Zslplan.vue` and `Zslplanlist.vue`: `zslClasses`, `zslPagination`,
/// `searchzslclass`, `selectedZslPlan`, `states`, `allClasses`, `classesList`.
class ZslPlanState {
  const ZslPlanState({
    this.zslClasses = const [],
    this.zslPagination,
    this.searchZslClass = const [],
    this.selectedZslPlan,
    this.states = const [],
    this.allClasses = const [],
    this.classesList,
  });

  final List<Map<String, dynamic>> zslClasses;

  /// `null` when the list was loaded unpaginated (the web then shows no page numbers).
  final PageMeta? zslPagination;

  /// `searchzslclass`
  final List<Map<String, dynamic>> searchZslClass;
  final Map<String, dynamic>? selectedZslPlan;
  final List<Map<String, dynamic>> states;
  final List<Map<String, dynamic>> allClasses;

  /// `classesList` (set by `fetchZslClasses`; not rendered by these screens).
  final dynamic classesList;

  ZslPlanState copyWith({
    List<Map<String, dynamic>>? zslClasses,
    Object? zslPagination = _unset,
    List<Map<String, dynamic>>? searchZslClass,
    Object? selectedZslPlan = _unset,
    List<Map<String, dynamic>>? states,
    List<Map<String, dynamic>>? allClasses,
    Object? classesList = _unset,
  }) =>
      ZslPlanState(
        zslClasses: zslClasses ?? this.zslClasses,
        zslPagination:
            identical(zslPagination, _unset) ? this.zslPagination : zslPagination as PageMeta?,
        searchZslClass: searchZslClass ?? this.searchZslClass,
        selectedZslPlan: identical(selectedZslPlan, _unset)
            ? this.selectedZslPlan
            : selectedZslPlan as Map<String, dynamic>?,
        states: states ?? this.states,
        allClasses: allClasses ?? this.allClasses,
        classesList: identical(classesList, _unset) ? this.classesList : classesList,
      );
}

/// The store actions used by the class-access-type screens, ported 1:1.
class ZslPlanController extends Notifier<ZslPlanState> {
  @override
  ZslPlanState build() => const ZslPlanState();

  InstituteService get _institute => ref.read(instituteServiceProvider);

  List<Map<String, dynamic>> _maps(dynamic list) => [for (final e in asList(list)) ?asMap(e)];

  /// `loadStates()`: the array itself or `res.data` (errors propagate).
  Future<void> loadStates() async {
    final res = await ref.read(userServiceProvider).getStates();
    final inner = asMap(res)?['data'];
    state = state.copyWith(states: _maps(res is List ? res : inner is List ? inner : const []));
  }

  /// `getAllClasses()`: `response.data || response || []`; on failure the
  /// list is emptied and the error rethrown.
  Future<List<Map<String, dynamic>>> getAllClasses() async {
    try {
      final res = await ref.read(zslServiceProvider).getClassAll();
      final data = asMap(res)?['data'];
      final classes = _maps(jsTruthy(data) ? data : res);
      state = state.copyWith(allClasses: classes);
      return classes;
    } catch (_) {
      state = state.copyWith(allClasses: const []);
      rethrow;
    }
  }

  /// `fetchZslClassesplan(paginate, page)`: a Laravel paginator under `data`
  /// when paginating, otherwise the plain body. Errors are swallowed (logged
  /// on the web; the API client already toasted them).
  Future<void> fetchZslClassesplan(bool paginate, [int page = 1]) async {
    try {
      final response = await _institute.getzslclass(paginate, page);
      final meta = asMap(asMap(response)?['data']);
      if (paginate && meta != null && jsTruthy(meta['data'])) {
        state = state.copyWith(
          zslClasses: _maps(meta['data']),
          zslPagination: PageMeta.fromMap(meta),
        );
      } else {
        // `response || []` — a non-array body renders as "No plan data".
        state = state.copyWith(zslClasses: _maps(response), zslPagination: null);
      }
    } catch (_) {}
  }

  /// `fetchsearchZslClasses(search)`: `searchzslclass = data.data` (errors swallowed).
  Future<void> fetchsearchZslClasses(String search) async {
    try {
      final data = await _institute.searchzslclass(search);
      state = state.copyWith(searchZslClass: _maps(asMap(data)?['data']));
    } catch (_) {}
  }

  /// `fetchZslPlanById(id)`: `selectedZslPlan = data.data`; returns the body.
  Future<dynamic> fetchZslPlanById(Object id) async {
    final data = await _institute.getzslclassid(id);
    state = state.copyWith(selectedZslPlan: asMap(asMap(data)?['data']));
    return data;
  }

  /// `updateZslPlan(id, payload)`: merges the response body into the matching
  /// row of `zslClasses` (as the web does, whatever the body's shape).
  Future<dynamic> updateZslPlan(Object? id, Map<String, dynamic> payload) async {
    final updated = await _institute.updatezslid(payload, id ?? 'undefined');
    final index = state.zslClasses.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      final rows = [...state.zslClasses];
      rows[index] = {...rows[index], ...?asMap(updated)};
      state = state.copyWith(zslClasses: rows);
    }
    return updated;
  }

  /// `deleteZslPlan(id)`: removes the row from `zslClasses` (not from the
  /// search results — same as the web).
  Future<dynamic> deleteZslPlan(Object id) async {
    final res = await _institute.deleteZslPlan(id);
    state = state.copyWith(zslClasses: [for (final e in state.zslClasses) if (e['id'] != id) e]);
    return res;
  }

  /// `fetchZslClasses(syllabus)` → `classesList` (errors swallowed).
  Future<void> fetchZslClasses(String syllabus) async {
    try {
      final data = await _institute.zslClasses(syllabus);
      state = state.copyWith(classesList: data);
    } catch (_) {}
  }

  /// `createNewClass(classData)`: returns the response body, or `null` when
  /// the request failed (the web swallowed the error and returned undefined).
  Future<dynamic> createNewClass(Map<String, dynamic> classData) async {
    try {
      return await _institute.createClass(classData);
    } catch (_) {
      return null;
    }
  }
}

final zslPlanControllerProvider =
    NotifierProvider<ZslPlanController, ZslPlanState>(ZslPlanController.new);
