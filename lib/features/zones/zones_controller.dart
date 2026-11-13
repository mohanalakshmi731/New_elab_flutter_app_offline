import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';
import '../mathzoro/mathzoro_controller.dart';
import 'zones_logic.dart';

/// The slice of `useUserStore` (src/store/Userstore.ts) used by the eLabs
/// Math Zone / Science Zone pages, ported 1:1:
/// `getAllSubjects`, `getallchpaters`, `getZslLinks`, `getSubjectPerformance`,
/// `getZslQuestions`, `submitZslQuiz`, `setActivityContext` and the
/// `persistedClassId` / `persistedMathChapterId` / `persistedScienceChapterId`
/// fields.
///
/// Store fields that other screens read live in [lmsHandoffProvider] under
/// the web field names ([kPersistedClassId], [kPersistedMathChapterId],
/// [kPersistedScienceChapterId], [kSelectedActivityContext]). The web kept
/// them in the persisted (encrypted sessionStorage) store; here they last
/// for the app session.
class ZonesState {
  const ZonesState({this.allsubject = const [], this.allchapters = const []});

  /// `allsubject` — raw `getAllSubjects` result (`res.data || res || []`).
  final dynamic allsubject;

  /// `allchapters` — raw `getallchpaters` result.
  final dynamic allchapters;

  ZonesState copyWith({Object? allsubject = _unset, Object? allchapters = _unset}) => ZonesState(
        allsubject: identical(allsubject, _unset) ? this.allsubject : allsubject,
        allchapters: identical(allchapters, _unset) ? this.allchapters : allchapters,
      );

  static const _unset = Object();
}

/// lmsHandoff keys (web store field names).
const kPersistedClassId = 'persistedClassId';
const kPersistedMathChapterId = 'persistedMathChapterId';
const kPersistedScienceChapterId = 'persistedScienceChapterId';
const kSelectedActivityContext = 'selectedActivityContext';

final zonesControllerProvider =
    NotifierProvider<ZonesController, ZonesState>(ZonesController.new);

class ZonesController extends Notifier<ZonesState> {
  @override
  ZonesState build() => const ZonesState();

  SessionState get _session => ref.read(sessionProvider);
  UserInfo? get _ui => _session.userInfo;
  ZslService get _zsl => ref.read(zslServiceProvider);
  LmsHandoff get _handoff => ref.read(lmsHandoffProvider.notifier);

  /// The MathZoro part of the same Pinia store (`selectedClass`,
  /// `math_zoro_courses`) — only read as class-id fallbacks.
  MathZoroState get _mz => ref.read(mathZoroProvider);

  // ── persisted fields ─────────────────────────────────────────────────────

  dynamic get persistedClassId => _handoff.get(kPersistedClassId);
  set persistedClassId(dynamic v) => _handoff.set(kPersistedClassId, v);

  dynamic persistedChapterId(String key) => _handoff.get(key);
  void setPersistedChapterId(String key, dynamic v) => _handoff.set(key, v);

  Json? get selectedActivityContext => asMap(_handoff.get(kSelectedActivityContext));

  /// `setActivityContext(context)`.
  void setActivityContext(Json context) => _handoff.set(kSelectedActivityContext, context);

  // ── zsl service ──────────────────────────────────────────────────────────

  /// `zsl.getClass(instituteId, syllabus)` (called directly by the pages).
  Future<dynamic> getClass(Object? instituteId, [Object? zslId]) =>
      _zsl.getClass(instituteId, zslId);

  /// `getAllSubjects(instituteId, classId)` → `allsubject = res.data || res || []`.
  Future<dynamic> getAllSubjects(Object instituteId, Object classId) async {
    try {
      final res = await _zsl.getAllSubjects(instituteId, classId);
      final value = dataOr(res, const []);
      state = state.copyWith(allsubject: value);
      return value;
    } catch (e) {
      debugPrint('Error fetching Subjects: $e');
      state = state.copyWith(allsubject: const []);
      rethrow;
    }
  }

  /// `getallchpaters(instituteId, classId, subjectId)`.
  Future<dynamic> getallchpaters(Object instituteId, Object classId, Object subjectId) async {
    try {
      final res = await _zsl.getAllChapters(instituteId, classId, subjectId);
      final value = dataOr(res, const []);
      state = state.copyWith(allchapters: value);
      return value;
    } catch (e) {
      debugPrint('Error fetching Chapters: $e');
      state = state.copyWith(allchapters: const []);
      rethrow;
    }
  }

  /// `getZslLinks(instituteId, chapterId, languageId?)` — `sub_user_id` is
  /// always `userInfo.zsl`.
  Future<dynamic> getZslLinks(Object? instituteId, Object? chapterId, [Object? languageId]) async {
    final subUserId = jsStr(_ui?.zsl);
    if (!jsTruthy(instituteId) || !jsTruthy(chapterId)) {
      throw const ApiError('Institute ID and Chapter ID are required');
    }
    return _zsl.getChapterLinks(
      jsStr(instituteId)!,
      jsStr(chapterId)!,
      jsTruthy(languageId) ? jsStr(languageId) : null,
      subUserId,
    );
  }

  /// `getSubjectPerformance(subjectId, classesId?)`.
  Future<dynamic> getSubjectPerformance(Object? subjectId, [Object? classesId]) async {
    final instituteId = jsStr(_ui?.instituteId);
    final subUserId = jsStr(_ui?.zsl);
    final finalClassesId = _firstTruthy([
      classesId,
      jsStr(_mz.selectedClass?['zsl_class_id']),
      jsStr(selectedActivityContext?['classId']),
      jsStr(_ui?.zslClassId),
      jsStr(_ui?.classesId),
    ]);
    if (instituteId == null || instituteId.isEmpty) {
      throw const ApiError('Institute ID not available');
    }
    if (finalClassesId == null) throw const ApiError('Class ID not available');
    if (subUserId == null || subUserId.isEmpty) {
      throw const ApiError('Sub User ID not available');
    }
    return _zsl.getSubjectPerformance(instituteId, finalClassesId, subjectId ?? 'undefined', subUserId);
  }

  /// `getZslQuestions(activityId)` (the pages pass a second argument, `10`,
  /// which the store action ignores).
  Future<dynamic> getZslQuestions(String activityId) async {
    final instituteId = jsStr(_ui?.instituteId);
    final languageId = jsStr(_session.language.id);
    if (instituteId == null || instituteId.isEmpty) {
      throw const ApiError('Institute ID not available');
    }
    return _zsl.getQuestions(instituteId, activityId, languageId);
  }

  /// `submitZslQuiz({ activity_id, classes_id, answers })`.
  Future<dynamic> submitZslQuiz({
    String? activityId,
    Object? classesId,
    required List<Map<String, String>> answers,
  }) async {
    final instituteId = jsStr(_ui?.instituteId) ?? '';
    final zslStudentId = jsStr(_ui?.zsl) ?? '';
    final selected = _mz.selectedClass;
    final courses = _mz.mathZoroCourses;

    String truthy(dynamic v) => jsTruthy(v) ? jsStr(v)! : '';

    final classId = [
      truthy(classesId),
      truthy(selected?['zsl_class_id']),
      truthy(selected?['classes_id']),
      truthy(persistedClassId),
      truthy(_session.classDetails?.id),
      truthy(_ui?.zslClassId),
      truthy(_ui?.classesId),
      truthy(selectedActivityContext?['classId']),
      truthy(courses.isNotEmpty ? courses.first['zsl_class_id'] : null),
    ].firstWhere((v) => v.isNotEmpty, orElse: () => '');

    if (instituteId.isEmpty) throw const ApiError('Institute ID is missing');
    if (zslStudentId.isEmpty) throw const ApiError('Sub User ID (ZSL) is missing');
    if (classId.isEmpty) throw const ApiError('Class ID is missing for quiz submission');
    if (activityId == null || activityId.isEmpty) throw const ApiError('Activity ID is missing');
    if (answers.isEmpty) throw const ApiError('Answers are empty');

    return _zsl.submitQuiz({
      'institute_id': instituteId,
      'sub_user_id': zslStudentId,
      'classes_id': classId,
      'activity_id': activityId,
      'answers': answers,
    });
  }

  /// `a || b || c` — the first truthy value, as a string.
  static String? _firstTruthy(List<Object?> values) {
    for (final v in values) {
      if (jsTruthy(v)) return jsStr(v);
    }
    return null;
  }
}
