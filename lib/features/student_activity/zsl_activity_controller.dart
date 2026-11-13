import 'package:dio/dio.dart';
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
import '../mathzoro/mz_ui.dart' show jsStr, firstNonEmpty;

/// The ZSL activity actions of `useUserStore` (src/store/Userstore.ts) used
/// by `studentactivitypage.vue` and `studentsciencezone.vue` that
/// [MathZoroController] doesn't port. The shared ones (`getZslLinks`,
/// `getallchpaters`, `getAllSubjects`, `getZslQuestions`,
/// `getSubjectPerformance`, `setLastOpenedChapter`) are called on
/// `mathZoroProvider.notifier`.
///
/// Store state read:
/// * `selectedActivityContext` — [mathZoroProvider] and
///   `lmsHandoffProvider['selectedActivityContext']` (see
///   [selectedActivityContext]);
/// * `selectedClass`, `math_zoro_courses` — [mathZoroProvider];
/// * `persistedClassId` — `lmsHandoffProvider['persistedClassId']` (set by
///   the eLabs library / math & science zone pages);
/// * `userInfo`, `classDetails`, `language` — [sessionProvider].
class ZslActivityController extends Notifier<void> {
  @override
  void build() {}

  SessionState get _session => ref.read(sessionProvider);
  UserInfo? get _ui => _session.userInfo;
  MathZoroState get _mz => ref.read(mathZoroProvider);
  ZslService get _zsl => ref.read(zslServiceProvider);

  /// `selectedActivityContext` — one web store field kept in two places:
  /// [mathZoroProvider] (persisted; written by the MathZoro math/play zones
  /// and read by MathZoroController's class-id fallbacks) and
  /// `lmsHandoffProvider['selectedActivityContext']` (the eLabs library
  /// screens). [setActivityContext] writes both; reads prefer the MathZoro
  /// copy, which every screen that opens the activity page writes.
  Map<String, dynamic>? get selectedActivityContext =>
      _mz.selectedActivityContext ??
      asMap(ref.read(lmsHandoffProvider.notifier).get('selectedActivityContext'));

  /// `setActivityContext(context)` — replaces the whole context object.
  void setActivityContext(Map<String, dynamic> context) {
    ref.read(mathZoroProvider.notifier).setSelectedActivityContext(context);
    ref.read(lmsHandoffProvider.notifier).set('selectedActivityContext', context);
  }

  /// `generateSignedUrl(instituteId, sectionId, chapterId, topicId,
  /// activityId)` — the topic id is only logged; `null` when the request
  /// failed (zsl.getSignedUrl swallowed errors).
  Future<dynamic> generateSignedUrl(Object instituteId, Object sectionId, Object chapterId,
          Object topicId, Object activityId) =>
      _zsl.getSignedUrl(instituteId, sectionId, chapterId, activityId);

  /// `trackActivity(trackingId)` — errors are only logged.
  Future<void> trackActivity(String trackingId) async {
    try {
      await ref.read(activityTrackingServiceProvider).trackActivity(trackingId);
    } catch (e) {
      debugPrint('Error tracking activity: $e');
    }
  }

  String _requireInstitute() {
    final id = _ui?.instituteId;
    if (id == null || id == 0) throw const ApiError('Institute ID not available');
    return '$id';
  }

  /// `getWhyToLearnSignedUrl(descriptionId)`.
  Future<dynamic> getWhyToLearnSignedUrl(String descriptionId) async =>
      _zsl.getWhyToLearnSignedUrl(_requireInstitute(), descriptionId);

  /// `getTeacherGuideSignedUrl(instructionId)`.
  Future<dynamic> getTeacherGuideSignedUrl(String instructionId) async =>
      _zsl.getTeacherGuideSignedUrl(_requireInstitute(), instructionId);

  /// `getLearningOutcomeSignedUrl(observationId)`.
  Future<dynamic> getLearningOutcomeSignedUrl(String observationId) async =>
      _zsl.getLearningOutcomeSignedUrl(_requireInstitute(), observationId);

  /// `getChapterReferenceSignedLink(chapter_id)`.
  Future<dynamic> getChapterReferenceSignedLink(String chapterId) async =>
      _zsl.getChapterReferenceSignedLink(
          {'institute_id': _requireInstitute(), 'chapter_id': chapterId});

  /// `submitZslQuiz({ activity_id, answers, classes_id? })` with the full
  /// class-id fallback chain of Userstore.ts (incl. `persistedClassId`).
  Future<dynamic> submitZslQuiz({
    required String activityId,
    required List<Map<String, String>> answers,
    Object? classesId,
  }) async {
    final instituteId = jsStr(_ui?.instituteId) ?? '';
    final zslStudentId = jsStr(_ui?.zsl) ?? '';
    final selected = _mz.selectedClass;
    final courses = _mz.mathZoroCourses;

    String truthy(dynamic v) => jsTruthy(v) ? jsStr(v)! : '';

    final classId = firstNonEmpty([
      truthy(classesId),
      truthy(selected?['zsl_class_id']),
      truthy(selected?['classes_id']),
      truthy(ref.read(lmsHandoffProvider.notifier).get('persistedClassId')),
      truthy(_session.classDetails?.id),
      truthy(_ui?.zslClassId),
      truthy(_ui?.classesId),
      truthy(selectedActivityContext?['classId']),
      truthy(courses.isNotEmpty ? courses.first['zsl_class_id'] : null),
    ]);

    if (instituteId.isEmpty) throw const ApiError('Institute ID is missing');
    if (zslStudentId.isEmpty) throw const ApiError('Sub User ID (ZSL) is missing');
    if (classId.isEmpty) throw const ApiError('Class ID is missing for quiz submission');
    if (activityId.isEmpty) throw const ApiError('Activity ID is missing');
    if (answers.isEmpty) throw const ApiError('Answers are empty');

    return _zsl.submitQuiz({
      'institute_id': instituteId,
      'sub_user_id': zslStudentId,
      'classes_id': classId,
      'activity_id': activityId,
      'answers': answers,
    });
  }

  /// `recordZslActivityPerformance(activityId, classId?)`.
  Future<dynamic> recordZslActivityPerformance(String activityId, [Object? classId]) async {
    final instituteId = jsStr(_ui?.instituteId) ?? '';
    final subUserId = jsStr(_ui?.zsl) ?? '';
    final courses = _mz.mathZoroCourses;
    // `x?.toString() || …` — any present value (even 0) stringifies truthy.
    final resolvedClassId = firstNonEmpty([
      jsStr(courses.isNotEmpty ? courses.first['zsl_class_id'] : null),
      jsStr(classId),
      jsStr(_mz.selectedClass?['zsl_class_id']),
      jsStr(selectedActivityContext?['classId']),
      jsStr(_session.classDetails?.id),
      jsStr(_ui?.zslClassId),
      jsStr(_ui?.classesId),
    ]);
    final payload = <String, dynamic>{
      'institute_id': instituteId,
      'sub_user_id': subUserId,
      'activity_id': activityId,
    };
    if (resolvedClassId.isNotEmpty) payload['classes_id'] = resolvedClassId;
    return _zsl.recordActivityPerformance(payload);
  }
}

final zslActivityProvider =
    NotifierProvider<ZslActivityController, void>(ZslActivityController.new);

/// `err?.response?.data?.msg || err?.response?.data?.message || err?.message
/// || fallback`.
String zslErrorMessage(Object error, String fallback) {
  if (error is DioException) {
    final data = asMap(error.response?.data);
    final msg = data?['msg'];
    if (jsTruthy(msg)) return '$msg';
    final message = data?['message'];
    if (jsTruthy(message)) return '$message';
    final m = error.message;
    if (m != null && m.isNotEmpty) return m;
    return fallback;
  }
  if (error is ApiError) return error.message.isEmpty ? fallback : error.message;
  final s = error.toString();
  return s.isEmpty ? fallback : s;
}
