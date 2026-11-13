import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../core/utils/pagination.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lookups.dart';
import '../mathzoro/mathzoro_controller.dart';
import 'users_logic.dart';

/// The user-management slice of `useUserStore` (`allUsers`, `userPagination`,
/// `searchuser`, `lastpage`, `userForm`, `passwordForm`, `dailCodes`,
/// `getuserbyid`, `zoomMeetingData`) and its actions, ported 1:1.
class UsersState {
  const UsersState({
    this.allUsers = const [],
    this.searchUser = const [],
    this.userPagination = PageMeta.empty,
    this.lastPage,
    this.userForm = emptyUserForm,
    this.passwordForm = emptyPasswordForm,
    this.dailCodes = const [],
    this.getuserbyid,
    this.zoomMeetingData,
  });

  final List<Map<String, dynamic>> allUsers;
  final List<Map<String, dynamic>> searchUser;
  final PageMeta userPagination;
  final int? lastPage;

  /// `userForm` — shared by `usercreate.vue` and `UserProfile.vue`
  /// (`mapWritableState`). Keys: firstName, lastName, email, phone,
  /// countryCode, gender, dob, password, designation, confirmpassword, photo
  /// (an `UploadFile` or null).
  final Map<String, dynamic> userForm;

  /// `passwordForm` — oldPassword, newPassword, confirmPassword.
  final Map<String, String> passwordForm;

  /// `dailCodes` — `[{ code: '+91', country: … }]`.
  final List<Map<String, dynamic>> dailCodes;

  /// `getuserbyid` — last `/user/{id}` (or update) result.
  final dynamic getuserbyid;

  /// `zoomMeetingData` — last `/zoom/*` result.
  final dynamic zoomMeetingData;

  static const _unset = Object();

  UsersState copyWith({
    List<Map<String, dynamic>>? allUsers,
    List<Map<String, dynamic>>? searchUser,
    PageMeta? userPagination,
    int? lastPage,
    Map<String, dynamic>? userForm,
    Map<String, String>? passwordForm,
    List<Map<String, dynamic>>? dailCodes,
    Object? getuserbyid = _unset,
    Object? zoomMeetingData = _unset,
  }) =>
      UsersState(
        allUsers: allUsers ?? this.allUsers,
        searchUser: searchUser ?? this.searchUser,
        userPagination: userPagination ?? this.userPagination,
        lastPage: lastPage ?? this.lastPage,
        userForm: userForm ?? this.userForm,
        passwordForm: passwordForm ?? this.passwordForm,
        dailCodes: dailCodes ?? this.dailCodes,
        getuserbyid: identical(getuserbyid, _unset) ? this.getuserbyid : getuserbyid,
        zoomMeetingData: identical(zoomMeetingData, _unset) ? this.zoomMeetingData : zoomMeetingData,
      );
}

class UsersController extends Notifier<UsersState> {
  @override
  UsersState build() => const UsersState();

  List<Map<String, dynamic>> _maps(dynamic list) => [for (final e in asList(list)) ?asMap(e)];

  UserInfo? get _userInfo => ref.read(sessionProvider).userInfo;

  /// `loadUsers(page, per_page)`
  Future<void> loadUsers([int page = 1, int perPage = 10]) async {
    final res = asMap(await ref.read(userServiceProvider).getUsers(page, perPage)) ?? const {};
    final total = asInt(res['total']) ?? 0;
    final per = asInt(res['per_page']) ?? 10;
    final users = [
      for (final u in _maps(res['data']))
        {
          'id': u['id'],
          'first_name': u['first_name'],
          'last_name': u['last_name'],
          'email': u['email'],
          'country_code': u['country_code'] ?? '',
          'phone': u['phone'] ?? '',
          'status': u['status'] ?? true,
          'email_verified_at': u['email_verified_at'],
        },
    ];
    state = state.copyWith(
      allUsers: users,
      userPagination: PageMeta(
        currentPage: asInt(res['current_page']) ?? 1,
        lastPage: math.max(1, (total / (per == 0 ? 10 : per)).ceil()),
        total: total,
        perPage: per,
      ),
    );
  }

  /// `changeUserPage(page)`
  Future<void> changeUserPage(int page) async {
    if (page < 1 || page > state.userPagination.lastPage) return;
    await loadUsers(page, state.userPagination.perPage);
  }

  /// `deleteUser(id)`
  Future<void> deleteUser(Object id) async {
    await ref.read(userServiceProvider).userdelete(id);
    state = state.copyWith(allUsers: [for (final u in state.allUsers) if (u['id'] != id) u]);
  }

  /// `searchUsers(term, paginate)` — the web passes the page number as the
  /// `paginate` parameter when paging through search results.
  Future<void> searchUsers(String term, String paginate) async {
    final res = await ref.read(userServiceProvider).searchUser(term, paginate);
    final data = asMap(res)?['data'];
    state = state.copyWith(
      searchUser: _maps(data ?? res),
      allUsers: _maps(data),
    );
  }

  /// `filterUsersByStatus(status, page)` — errors are swallowed like the web
  /// (the API client already showed the toast).
  Future<void> filterUsersByStatus(String status, [int page = 1]) async {
    try {
      final res = asMap(await ref.read(userServiceProvider).statusUser(status, page)) ?? const {};
      final users = _maps(res['data']);
      final last = asInt(res['last_page']);
      state = state.copyWith(
        lastPage: last,
        allUsers: users,
        searchUser: users,
        userPagination: state.userPagination.copyWith(
          currentPage: asInt(res['current_page']) ?? page,
          lastPage: math.max(1, last ?? 1),
          total: asInt(res['total']) ?? 0,
        ),
      );
    } catch (_) {}
  }

  /// `lockUser(id)` → status false.
  Future<void> lockUser(Object id) async {
    await ref.read(userServiceProvider).lockUser(id);
    _setStatus(id, false);
  }

  /// `unlockUser(id)` → status true.
  Future<void> unlockUser(Object id) async {
    await ref.read(userServiceProvider).unlockUser(id);
    _setStatus(id, true);
  }

  /// The page flips the status before the API call (and back on failure).
  void setStatusLocally(Object id, bool status) => _setStatus(id, status);

  void _setStatus(Object id, bool status) {
    Map<String, dynamic> patch(Map<String, dynamic> u) => u['id'] == id ? {...u, 'status': status} : u;
    state = state.copyWith(
      allUsers: [for (final u in state.allUsers) patch(u)],
      searchUser: [for (final u in state.searchUser) patch(u)],
    );
  }

  // ── userForm / passwordForm (v-model on mapWritableState) ────────────────

  /// `this.userForm = { … }` (usercreate.vue `mounted`).
  void setUserForm(Map<String, dynamic> form) => state = state.copyWith(userForm: {...form});

  /// `this.userForm.x = …` for one or more fields.
  void patchUserForm(Map<String, dynamic> fields) {
    if (fields.entries.every((e) => state.userForm[e.key] == e.value)) return;
    state = state.copyWith(userForm: {...state.userForm, ...fields});
  }

  /// `this.passwordForm.x = …`
  void patchPasswordForm(Map<String, String> fields) {
    if (fields.entries.every((e) => state.passwordForm[e.key] == e.value)) return;
    state = state.copyWith(passwordForm: {...state.passwordForm, ...fields});
  }

  // ── lookups ──────────────────────────────────────────────────────────────

  /// Reads a cached lookup, refetching when the previous attempt failed (the
  /// web refetched on every mount).
  Future<List<Map<String, dynamic>>> _lookup(FutureProvider<List<Map<String, dynamic>>> p) {
    if (ref.read(p).hasError) ref.invalidate(p);
    return ref.read(p.future);
  }

  /// `loadUserDialCodes()` — also pre-selects the first code in `userForm`.
  Future<void> loadUserDialCodes() async {
    final codes = await _lookup(dialCodesProvider);
    state = state.copyWith(
      dailCodes: codes,
      userForm: codes.isNotEmpty ? {...state.userForm, 'countryCode': codes.first['code']} : null,
    );
  }

  /// `loadCountries()` — errors are logged (swallowed) by the web action.
  Future<void> loadCountries() async {
    try {
      await _lookup(countriesProvider);
    } catch (_) {}
  }

  /// `loadStates()`
  Future<void> loadStates() => _lookup(statesProvider);

  // ── create / profile ─────────────────────────────────────────────────────

  /// `createUser()` — multipart `POST /user` from `userForm`; resets the form
  /// and returns true when the API answers "User created successfully".
  Future<bool> createUser() async {
    final res = await ref.read(userServiceProvider).createUser(buildCreateUserFields(state.userForm));
    if (asMap(res)?['message'] == 'User created successfully') {
      state = state.copyWith(userForm: emptyUserForm);
      return true;
    }
    return false;
  }

  /// `getUserById()` — the logged-in user's record (`res.data || res`).
  /// When it has a `subscription`, the MathZoro courses get its dates.
  Future<dynamic> getUserById() async {
    final ui = _userInfo;
    if (!jsTruthy(ui?.id) || !jsTruthy(ui?.instituteId)) {
      throw const ApiError('User ID or Institute ID is missing in userInfo');
    }
    final res = await ref.read(userServiceProvider).getUserById('${ui!.id}', '${ui.instituteId}');
    final data = asMap(res)?['data'];
    final user = jsTruthy(data) ? data : res;
    state = state.copyWith(getuserbyid: user);

    final sub = asMap(user)?['subscription'];
    if (jsTruthy(sub)) {
      final mz = ref.read(mathZoroProvider);
      ref.read(mathZoroProvider.notifier).setMathZoroCourses([
        for (final c in mz.mathZoroCourses)
          {...c, 'start_date': dig(sub, ['start_date']), 'end_date': dig(sub, ['end_date'])},
      ]);
    }
    return user;
  }

  /// `updateUser(payload)` — `PUT /user/{id}`; renames the session user when
  /// the response is the logged-in user.
  Future<dynamic> updateUser({
    required String firstName,
    required String lastName,
    required String email,
    required String countryCode,
    required String phone,
    required String designation,
  }) async {
    final ui = _userInfo;
    final updated = await ref.read(userServiceProvider).updateUser(ui?.id?.toString() ?? '', {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'country_code': countryCode,
      'phone': phone,
      'designation': designation,
      'institute_id': ui?.instituteId ?? '',
    });
    state = state.copyWith(getuserbyid: updated);
    final u = asMap(updated);
    if (ui != null && u != null && ui.id != null && ui.id == u['id']) {
      final username = '${u['first_name']} ${u['last_name']}';
      ref.read(sessionProvider.notifier).patch((s) {
        final current = s.userInfo;
        if (current == null) return s;
        return s.copyWith(userInfo: UserInfo.fromJson({...current.toJson(), 'username': username}));
      });
    }
    return updated;
  }

  /// `changePassword()` — uses `passwordForm`; clears old/new on success.
  /// Errors are swallowed (false) like the web action.
  Future<bool> changePassword() async {
    final ui = _userInfo;
    if (!jsTruthy(ui?.id)) return false;
    final oldPassword = state.passwordForm['oldPassword'] ?? '';
    final newPassword = state.passwordForm['newPassword'] ?? '';
    if (oldPassword.isEmpty || newPassword.isEmpty) return false;
    try {
      final res = await ref.read(userServiceProvider).changePassword(ui!.id!, oldPassword, newPassword);
      final message = asMap(res)?['message'];
      if (message is String && message.toLowerCase().contains('success')) {
        patchPasswordForm(const {'oldPassword': '', 'newPassword': ''});
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// `profilegetInstituteById()` — only admins / institutes with an institute.
  Future<dynamic> profilegetInstituteById() async {
    final ui = _userInfo;
    if (jsTruthy(ui?.instituteId) && (ui?.role == 'admin' || ui?.role == 'institute')) {
      return ref.read(instituteServiceProvider).getInstituteById(ui!.instituteId!);
    }
    return null;
  }

  /// `updateInstituteDetails(instituteId, form)` → `res.data`.
  Future<dynamic> updateInstituteDetails(Object? instituteId, Map<String, dynamic> form) async {
    if (!jsTruthy(instituteId)) throw const ApiError('Institute ID is required');
    final res = await ref
        .read(instituteServiceProvider)
        .updateInstitute(instituteId!, buildInstituteUpdateFields(instituteId, form));
    return asMap(res)?['data'];
  }

  // ── zoom ────────────────────────────────────────────────────────────────

  String _instituteIdOrThrow() {
    final id = _userInfo?.instituteId;
    if (!jsTruthy(id)) throw const ApiError('Institute ID not available');
    return '$id';
  }

  /// `refreshZoomInfo()`
  Future<dynamic> refreshZoomInfo() async {
    final id = _instituteIdOrThrow();
    final res = await ref.read(zoomServiceProvider).refreshZoomInfo({'institute_id': id});
    state = state.copyWith(zoomMeetingData: res);
    return res;
  }

  /// `zoomautofix()`
  Future<dynamic> zoomautofix() async {
    final id = _instituteIdOrThrow();
    final res = await ref.read(zoomServiceProvider).zoomautofix({'institute_id': id});
    state = state.copyWith(zoomMeetingData: res);
    return res;
  }

  /// `fetchZoomInfo()`
  Future<dynamic> fetchZoomInfo() async {
    final id = _instituteIdOrThrow();
    final res = await ref.read(zoomServiceProvider).getZoomInfo(id);
    state = state.copyWith(zoomMeetingData: res);
    return res;
  }

  /// `validateZoomInfo(payload)` — adds `institute_id`.
  Future<dynamic> validateZoomInfo(Map<String, dynamic> payload) async {
    final id = _instituteIdOrThrow();
    final res = await ref.read(zoomServiceProvider).validateZoomInfo({...payload, 'institute_id': id});
    state = state.copyWith(zoomMeetingData: res);
    return res;
  }
}

final usersControllerProvider = NotifierProvider<UsersController, UsersState>(UsersController.new);
