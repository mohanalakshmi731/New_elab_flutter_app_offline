import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/json.dart';
import '../../core/utils/pagination.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lookups.dart';
import 'institute_payloads.dart';

/// `instituteForm` initial value in `useUserStore`.
const Map<String, dynamic> initialInstituteForm = {
  'user_id': '',
  'plan_id': '',
  'state_id': '',
  'name': '',
  'type': '',
  'client_code': '',
  'syllabus': '',
  'address': '',
  'country_code': '',
  'phone': '',
  'country_id': null,
  'email': '',
  'allclass': <Object>[],
  'is_math_zoro': '',
  'country': '',
};

/// `invitform` initial value in `useUserStore`.
const Map<String, dynamic> initialInvitform = {
  'code': '',
  'first_name': '',
  'last_name': '',
  'email': '',
  'phone': '',
  'designation': '',
  'institute_plan_id': '',
  'country_code': '',
  'content': '',
};

/// The institutes / invitations slice of `useUserStore` (`ALLinstitutes`,
/// `institutePagination`, `searchedInstitutes`, `isSearching`, `plans`,
/// `allClasses`, `instituteForm`, `invitform`, `invitations`).
///
/// `states`, `countries` and `dailCodes` come from the shared lookups in
/// `features/common/lookups.dart`.
class InstitutesState {
  const InstitutesState({
    this.allInstitutes = const [],
    this.institutePagination = PageMeta.empty,
    this.searchedInstitutes = const [],
    this.isSearching = false,
    this.plans = const [],
    this.allClasses = const [],
    this.instituteForm = initialInstituteForm,
    this.invitform = initialInvitform,
    this.invitations = const [],
  });

  final List<Map<String, dynamic>> allInstitutes;
  final PageMeta institutePagination;
  final List<Map<String, dynamic>> searchedInstitutes;
  final bool isSearching;
  final List<Map<String, dynamic>> plans;
  final List<Map<String, dynamic>> allClasses;
  final Map<String, dynamic> instituteForm;
  final Map<String, dynamic> invitform;
  final List<Map<String, dynamic>> invitations;

  InstitutesState copyWith({
    List<Map<String, dynamic>>? allInstitutes,
    PageMeta? institutePagination,
    List<Map<String, dynamic>>? searchedInstitutes,
    bool? isSearching,
    List<Map<String, dynamic>>? plans,
    List<Map<String, dynamic>>? allClasses,
    Map<String, dynamic>? instituteForm,
    Map<String, dynamic>? invitform,
    List<Map<String, dynamic>>? invitations,
  }) =>
      InstitutesState(
        allInstitutes: allInstitutes ?? this.allInstitutes,
        institutePagination: institutePagination ?? this.institutePagination,
        searchedInstitutes: searchedInstitutes ?? this.searchedInstitutes,
        isSearching: isSearching ?? this.isSearching,
        plans: plans ?? this.plans,
        allClasses: allClasses ?? this.allClasses,
        instituteForm: instituteForm ?? this.instituteForm,
        invitform: invitform ?? this.invitform,
        invitations: invitations ?? this.invitations,
      );
}

class InstitutesController extends Notifier<InstitutesState> {
  @override
  InstitutesState build() => const InstitutesState();

  List<Map<String, dynamic>> _maps(dynamic list) => [for (final e in asList(list)) ?asMap(e)];

  InstituteService get _institutes => ref.read(instituteServiceProvider);
  InvitationService get _invitations => ref.read(invitationServiceProvider);

  /// Reads a cached lookup, retrying it when the previous load failed.
  Future<List<Map<String, dynamic>>> _lookup(FutureProvider<List<Map<String, dynamic>>> p) {
    if (ref.read(p).hasError) ref.invalidate(p);
    return ref.read(p.future);
  }

  // ───────────── form state (v-model on the store objects) ─────────────

  /// Writes fields of `instituteForm` (the page's `v-model`s).
  void patchInstituteForm(Map<String, dynamic> patch) =>
      state = state.copyWith(instituteForm: {...state.instituteForm, ...patch});

  /// Writes one field of `invitform` directly (`v-model="invitform.code"`).
  void setInvitField(String key, Object? value) =>
      state = state.copyWith(invitform: {...state.invitform, key: value});

  /// `setInvitationForm(payload)`: copies only the known keys that are present
  /// (`code` is never touched).
  void setInvitationForm(Map<String, dynamic> payload) {
    const keys = [
      'first_name',
      'last_name',
      'email',
      'phone',
      'designation',
      'country_code',
      'institute_plan_id',
      'content',
    ];
    state = state.copyWith(invitform: {
      ...state.invitform,
      for (final k in keys)
        if (payload.containsKey(k)) k: payload[k],
    });
  }

  // ───────────── lookups ─────────────

  /// `loadDialCodesForInstitute()`: also pre-selects the first code in
  /// `instituteForm.country_code`.
  Future<List<Map<String, dynamic>>> loadDialCodesForInstitute() async {
    final codes = await _lookup(dialCodesProvider);
    if (codes.isNotEmpty) patchInstituteForm({'country_code': codes.first['code']});
    return codes;
  }

  /// `loadStates()`
  Future<List<Map<String, dynamic>>> loadStates() => _lookup(statesProvider);

  /// `loadCountries()` — errors are swallowed like the store.
  Future<void> loadCountries() async {
    try {
      await _lookup(countriesProvider);
    } catch (_) {}
  }

  /// `loadInstitutePlans()` (store version):
  /// `Array.isArray(res?.data) ? res.data : Array.isArray(res) ? res : []`.
  Future<void> loadInstitutePlans() async {
    final res = await _institutes.getPlans();
    final data = asMap(res)?['data'];
    state = state.copyWith(plans: data is List ? _maps(data) : _maps(res));
  }

  /// `loadInstituteUsers()` — the store kept the result in `allUsers`, which
  /// none of these screens read; only the request is replayed.
  Future<void> loadInstituteUsers() async {
    await ref.read(userServiceProvider).getUsers();
  }

  /// `getAllClasses()`: `response.data || response || []`.
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

  // ───────────── institutes ─────────────

  /// `getInstitutes(page, per_page, paginate)`
  Future<void> getInstitutes([int page = 1, int perPage = 10, bool paginate = true]) async {
    final res = await _institutes.getInstitutes(page, perPage, paginate);
    final parsed = parseInstitutesPage(res);
    state = state.copyWith(allInstitutes: parsed.rows, institutePagination: parsed.meta);
  }

  /// `getInstituteById(id)`: falls back to the session's institute; returns
  /// the response body (the institute).
  Future<dynamic> getInstituteById([Object? instituteId]) async {
    final id = jsTruthy(instituteId) ? instituteId : ref.read(sessionProvider).instituteId;
    if (!jsTruthy(id)) return null;
    return _institutes.getInstituteById(jsNumber(id) ?? id!);
  }

  /// `searchInstitutes(term)`: `searchedInstitutes = res.data || res`.
  Future<void> searchInstitutes(String term) async {
    state = state.copyWith(isSearching: true);
    try {
      final res = await _institutes.searchInstitute(term);
      state = state.copyWith(searchedInstitutes: _maps(unwrapList(res)));
    } finally {
      state = state.copyWith(isSearching: false);
    }
  }

  /// `deleteInstitute(id)`
  Future<void> deleteInstitute(Object id) async {
    await _institutes.deleteInstitute(id);
    state = state.copyWith(allInstitutes: [for (final u in state.allInstitutes) if (u['id'] != id) u]);
  }

  /// `updateInstitute(form)`: multipart PUT; returns `res.data`.
  Future<dynamic> updateInstitute(Map<String, dynamic> form) async {
    if (!jsTruthy(form['id'])) throw StateError('Institute ID is required');
    final res = await _institutes.updateInstitute(form['id'] as Object, buildUpdateInstituteFields(form));
    return asMap(res)?['data'];
  }

  /// `submitInstituteForm(payload)`: posts the multipart form, then resets
  /// `instituteForm` (country code back to the first dial code).
  Future<dynamic> submitInstituteForm(Map<String, dynamic> payload) async {
    final response = await _institutes.createInstitute(buildInstituteFormFields(payload), asFormData: true);
    final codes = ref.read(dialCodesProvider).valueOrNull ?? const [];
    state = state.copyWith(instituteForm: {
      ...initialInstituteForm,
      'allclass': <Object>[],
      'country_code': codes.firstOrNull?['code'] ?? '',
    });
    return response;
  }

  /// `searchUserByEmailAction(email)`
  Future<dynamic> searchUserByEmailAction(String email) {
    final instituteId = ref.read(sessionProvider).instituteId?.toString();
    return ref.read(userServiceProvider).searchUserByEmail(email, instituteId);
  }

  // ───────────── invitations ─────────────

  /// `downloadBulkTemplateAction()`
  Future<Uint8List> downloadBulkTemplateAction() => _institutes.downloadBulkTemplate();

  /// `sendBulkInvitationAction(formData)`
  Future<dynamic> sendBulkInvitationAction(Map<String, dynamic> fields) =>
      _institutes.sendBulkInvitation(fields);

  /// `createInvitationCodeAction()`: `{code, institute_plan_id: Number(...)}`.
  Future<dynamic> createInvitationCodeAction() => _institutes.createInvitationByCode({
        'code': state.invitform['code'],
        'institute_plan_id': jsNumber(state.invitform['institute_plan_id']),
      });

  /// `sendInvitationAction()`: posts the whole `invitform` (incl. `code`).
  Future<dynamic> sendInvitationAction() => _institutes.sendInvitation({...state.invitform});

  /// `fetchInvitations()`: `invitations = res?.data || res`.
  Future<dynamic> fetchInvitations() async {
    final res = await _invitations.getInvitations();
    final data = asMap(res)?['data'];
    state = state.copyWith(invitations: _maps(jsTruthy(data) ? data : res));
    return res;
  }

  /// `fetchInvitationById(id)`
  Future<dynamic> fetchInvitationById(Object id) => _invitations.getInvitationById(id);

  /// `searchInvitationUsers(term)` — returns the body. The store also copied
  /// the result into the user list's `searchuser` / `allUsers`; that side
  /// effect is not replayed (the user list reloads on open anyway).
  Future<dynamic> searchInvitationUsers(String term) => _invitations.searchUsers(term);

  /// `resendInvitationAction(id, data)`
  Future<dynamic> resendInvitationAction(Object id, Map<String, dynamic> data) =>
      _invitations.resendInvitation(id, data);
}

final institutesControllerProvider =
    NotifierProvider<InstitutesController, InstitutesState>(InstitutesController.new);
