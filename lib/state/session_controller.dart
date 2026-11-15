import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/storage/secure_store.dart';
import '../core/utils/json.dart';
import '../data/models/session.dart';
import '../data/services/auth_service.dart';
import 'providers.dart';

/// Session part of the Pinia `useUserStore` (src/store/Userstore.ts):
/// `userInfo`, `studentLoginData`, `setUserInfo`, `logout`, `language`, ...
///
/// Every change is persisted to [SecureStore] so the user stays signed in
/// across app restarts (the web app used encrypted sessionStorage).
class SessionController extends Notifier<SessionState> {
  static const storageKey = 'elab.session';

  @override
  SessionState build() => ref.read(initialSessionProvider);

  SecureStore get _store => ref.read(secureStoreProvider);
  AuthService get _auth => ref.read(authServiceProvider);

  void _commit(SessionState next) {
    state = next;
    _store.writeJson(storageKey, next.toJson());
  }

  /// Port of `setUserInfo(response)` — builds the session from the
  /// `/auth/login` (or 2FA verify) response.
  void setUserInfo(dynamic response) {
    final res = asMap(response) ?? const {};
    final user = asMap(res['user']) ?? const {};
    String? role;
    if (user['isAdmin'] == true) role = Role.admin;

    final institutes = asList(res['institutes']);
    final institute = asMap(institutes.cast<dynamic>().firstWhere(
              (i) => asBool(asMap(i)?['is_default']),
              orElse: () => institutes.isNotEmpty ? institutes.first : null,
            )) ??
        const <String, dynamic>{};

    final instituteId = asInt(institute['id']);
    final student = asMap(institute['student']);
    final instructor = asMap(institute['instructor']);
    final instructorId = asInt(instructor?['id']);

    // Pick the ACTIVE batch (pivot.status === true first)
    final batches = asList(student?['batches']);
    final activeBatch = asMap(batches.cast<dynamic>().firstWhere(
          (b) => dig(b, ['pivot', 'status']) == true,
          orElse: () => batches.isNotEmpty ? batches.first : null,
        ));

    final studentId = asInt(student?['id']);
    final examUserId =
        asString(student?['exam_user_id'] ?? instructor?['exam_user_id']);
    final zslId = student?['zsl_id'] ?? instructor?['zsl_id'];
    final batchId = asInt(activeBatch?['id']);
    final classesId = asInt(activeBatch?['classes_id']);

    final firstCourse = asMap(dig(activeBatch, ['classes', 'courses', 0]));
    final zslClassId = asInt(firstCourse?['zsl_class_id']);

    role ??= asString(dig(institute, ['roles', 0, 'name']));

    final first = asString(user['first_name']) ?? '';
    final last = asString(user['last_name']) ?? '';
    final username = (asString(user['username'])?.isNotEmpty ?? false)
        ? asString(user['username'])!
        : (asString(user['full_name'])?.isNotEmpty ?? false)
            ? asString(user['full_name'])!
            : '$first $last';

    final userInfo = UserInfo(
      id: asInt(user['id']),
      username: username,
      token: asString(res['token2'] ?? res['token']) ?? '',
      role: role,
      isLabAdmin: asBool(instructor?['is_labadmin']) || role == Role.labAdmin,
      instituteId: instituteId,
      email: asString(user['email']) ?? '',
      studentId: studentId,
      examUserId: examUserId,
      institutePlanId: asInt(institute['institute_plan_id']),
      zsl: zslId,
      classesId: classesId,
      zslClassId: zslClassId,
      isMathZoro: asBool(institute['is_math_zoro']),
      phone: asString(user['phone']) ?? '',
      fullName: username,
      mathzoroClassId: zslClassId,
    );

    IdName? batchDetails = state.batchDetails;
    IdName? classDetails = state.classDetails;
    StudentLoginData? studentLoginData;

    if (role == Role.student && batchId != null) {
      batchDetails = IdName(batchId, asString(activeBatch?['name']) ?? '');
    }
    final cls = asMap(activeBatch?['classes']);
    if (role == Role.student && cls != null) {
      classDetails = IdName(asInt(cls['id']), asString(cls['name']) ?? '', extra: {
        'c_id': asString(cls['curricula_id']),
        'institute_id': asInt(cls['institute_id']),
      });
    }
    if (role == Role.student && student != null) {
      studentLoginData = StudentLoginData({
        'id': studentId,
        'institute_id': asInt(student['institute_id']),
        'user_id': asInt(student['user_id']),
        'status': asBool(student['status']),
        'exam_user_id': asString(student['exam_user_id']),
        'zsl_id': asInt(student['zsl_id']),
        'zsl_key': asString(student['zsl_key']),
        'syllabus': asString(student['syllabus']),
        'state_id': asInt(student['state_id']),
        'batch_id': batchId,
        'batch_name': asString(activeBatch?['name']),
        'exam_batch_id': asString(activeBatch?['exam_batch_id']),
        'classes_id': classesId,
        'class_name': asString(cls?['name']),
        'curricula_id': asInt(cls?['curricula_id']),
        'course_id': asInt(firstCourse?['id']),
        'course_title': asString(firstCourse?['title']),
        'zsl_class_id': zslClassId,
        'zsl_subject_id': asInt(firstCourse?['zsl_subject_id']),
        'exam_course_id': asString(firstCourse?['exam_course_id']),
      });
    }

    _commit(state.copyWith(
      userInfo: userInfo,
      expiresOn: asString(institute['expires_on']),
      instructorId: instructorId,
      rawStudentBatches: batches,
      batchDetails: batchDetails,
      classDetails: classDetails,
      studentLoginData: studentLoginData,
    ));
  }

  void setBatchDetails(IdName? batch) => _commit(state.copyWith(batchDetails: batch));

  void setClassDetails(IdName? cls) => _commit(state.copyWith(classDetails: cls));

  void setLanguage(AppLanguage lang) => _commit(state.copyWith(language: lang));

  /// Updates the MathZoro class selection stored on userInfo.
  void setMathzoroClassId(int? zslClassId) {
    final ui = state.userInfo;
    if (ui == null) return;
    _commit(state.copyWith(
        userInfo: ui.copyWith(mathzoroClassId: zslClassId, zslClassId: zslClassId)));
  }

  /// Applies [update] to the session and persists the result. Used by the
  /// MathZoro `setSelectedClass` port, which patches `userInfo` and
  /// `studentLoginData` in place like the web store did.
  void patch(SessionState Function(SessionState current) update) =>
      _commit(update(state));

  /// Port of `logout()` — calls the API (non-fatal) and clears the session.
  /// The router redirect then sends the user to the login screen.
  Future<void> logout({bool callApi = true}) async {
    if (!state.isLoggedIn) return;
    if (callApi) {
      try {
        await _auth.logout();
      } catch (e) {
        debugPrint('Logout API call failed (non-fatal): $e');
      }
    }
    ref.read(echoClientProvider).disconnect();
    unawaited(ref.read(contentCacheProvider).clear());
    // Keep the language preference, reset everything else (store.$reset()).
    final keep = state.language;
    state = SessionState(language: keep);
    await _store.writeJson(storageKey, state.toJson());
  }

  /// Loads the persisted session before the app starts.
  static Future<SessionState> restore(SecureStore store) async {
    final json = await store.readJson(storageKey);
    if (json == null) return const SessionState();
    try {
      return SessionState.fromJson(json);
    } catch (e) {
      debugPrint('Session restore failed: $e');
      return const SessionState();
    }
  }
}
