import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';
import '../mathzoro/mathzoro_controller.dart';
import 'library_logic.dart';

/// The Activity Library slice of `useUserStore` (src/store/Userstore.ts),
/// ported 1:1.
///
/// Store fields shared with other screens live in [lmsHandoffProvider] under
/// the web field names:
/// * `selectedActivityContext` — written by the library pages (and the math /
///   science zones) before `router.push('/activitylibrary')`, read and
///   patched by the activity page;
/// * `persistedClassId` / `persistedSubjectId` / `persistedChapterId` — the
///   last class / subject / chapter picked in the library filters.
class LibraryController extends Notifier<void> {
  @override
  void build() {}

  SessionState get _session => ref.read(sessionProvider);
  UserInfo? get _ui => _session.userInfo;
  ZslService get _zsl => ref.read(zslServiceProvider);
  LmsHandoff get _handoff => ref.read(lmsHandoffProvider.notifier);

  // ── store state (lmsHandoff) ─────────────────────────────────────────────

  Object? get persistedClassId => _handoff.get('persistedClassId');
  set persistedClassId(Object? v) => _handoff.set('persistedClassId', v);

  Object? get persistedSubjectId => _handoff.get('persistedSubjectId');
  set persistedSubjectId(Object? v) => _handoff.set('persistedSubjectId', v);

  Object? get persistedChapterId => _handoff.get('persistedChapterId');
  set persistedChapterId(Object? v) => _handoff.set('persistedChapterId', v);

  /// `selectedActivityContext` (null until a library page opens an activity).
  Map<String, dynamic>? get selectedActivityContext {
    final v = _handoff.get('selectedActivityContext');
    return v is Map ? v.map((k, val) => MapEntry('$k', val)) : null;
  }

  /// `userStore.selectedClass` — only set by the MathZoro class selection.
  Map<String, dynamic>? get selectedClass => ref.read(mathZoroProvider).selectedClass;

  /// `setActivityContext(context)`.
  void setActivityContext(Map<String, dynamic> context) =>
      _handoff.set('selectedActivityContext', context);

  /// `setPersistedFilters(classId, subjectId, chapterId)`.
  void setPersistedFilters(Object? classId, Object? subjectId, Object? chapterId) {
    persistedClassId = classId;
    persistedSubjectId = subjectId;
    persistedChapterId = chapterId;
  }

  // ── actions ──────────────────────────────────────────────────────────────

  /// `getAllSubjects(instituteId, classId)` → `res.data || res || []`.
  Future<List<dynamic>> getAllSubjects(Object instituteId, Object classId) async =>
      dataOrSelf(await _zsl.getAllSubjects(instituteId, classId));

  /// `getallchpaters(instituteId, classId, subjectId)` → `res.data || res || []`.
  Future<List<dynamic>> getallchpaters(Object instituteId, Object classId, Object subjectId) async =>
      dataOrSelf(await _zsl.getAllChapters(instituteId, classId, subjectId));

  /// `getZslLinks(instituteId, chapterId, languageId?)` — topics of a chapter
  /// with their activities (`sub_user_id` = `userInfo.zsl`).
  Future<List<dynamic>> getZslLinks(Object? instituteId, Object? chapterId,
      [Object? languageId]) async {
    final zsl = _ui?.zsl;
    final subUserId = zsl == null ? null : jsString(zsl);
    if (!jsTruthy(instituteId) || !jsTruthy(chapterId)) {
      throw const ApiError('Institute ID and Chapter ID are required');
    }
    final res = await _zsl.getChapterLinks(
      jsString(instituteId),
      jsString(chapterId),
      jsTruthy(languageId) ? jsString(languageId) : null,
      subUserId,
    );
    return res is List ? res : const [];
  }

  String _instituteIdOrThrow() {
    final id = _ui?.instituteId;
    if (!jsTruthy(id)) throw const ApiError('Institute ID not available');
    return jsString(id);
  }

  /// `getChapterReferenceSignedLink(chapter_id)`.
  Future<dynamic> getChapterReferenceSignedLink(String chapterId) async {
    final instituteId = _instituteIdOrThrow();
    return _zsl.getChapterReferenceSignedLink(
        {'institute_id': instituteId, 'chapter_id': chapterId});
  }

  /// `generateSignedUrl(instituteId, sectionId, chapterId, topicId, activityId)`
  /// — the topic id is only logged by the web. `null` when the request failed.
  Future<dynamic> generateSignedUrl(Object instituteId, Object sectionId, Object chapterId,
          Object topicId, Object? activityId) =>
      _zsl.getSignedUrl(instituteId, sectionId, chapterId, activityId ?? '');

  /// `trackActivity(trackingId)` — errors are swallowed by the service.
  Future<void> trackActivity(String trackingId) async {
    await ref.read(activityTrackingServiceProvider).trackActivity(trackingId);
  }

  Future<dynamic> getWhyToLearnSignedUrl(String descriptionId) async =>
      _zsl.getWhyToLearnSignedUrl(_instituteIdOrThrow(), descriptionId);

  Future<dynamic> getAutopilotSignedUrl(String autopilotId) async =>
      _zsl.getAutopilotSignedUrl(_instituteIdOrThrow(), autopilotId);

  Future<dynamic> getTeacherGuideSignedUrl(String instructionId) async =>
      _zsl.getTeacherGuideSignedUrl(_instituteIdOrThrow(), instructionId);

  Future<dynamic> getLearningOutcomeSignedUrl(String observationId) async =>
      _zsl.getLearningOutcomeSignedUrl(_instituteIdOrThrow(), observationId);

  /// `getZslQuestions(activityId)` — in the session language.
  Future<dynamic> getZslQuestions(String activityId) async {
    final instituteId = _instituteIdOrThrow();
    final languageId = jsString(_session.language.id);
    return _zsl.getQuestions(instituteId, activityId, languageId);
  }

  /// `submitZslQuiz({ activity_id, answers, classes_id? })`.
  Future<dynamic> submitZslQuiz({
    required String activityId,
    required List<dynamic> answers,
    Object? classesId,
  }) async {
    final instituteId = firstTruthyString([_ui?.instituteId]);
    final zslStudentId = firstTruthyString([_ui?.zsl]);
    final selected = selectedClass;
    final mz = ref.read(mathZoroProvider);

    final classId = firstTruthyString([
      classesId,
      selected?['zsl_class_id'],
      selected?['classes_id'],
      persistedClassId,
      _session.classDetails?.id,
      _ui?.zslClassId,
      _ui?.classesId,
      selectedActivityContext?['classId'],
      mz.mathZoroCourses.isNotEmpty ? mz.mathZoroCourses.first['zsl_class_id'] : null,
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
}

final libraryControllerProvider =
    NotifierProvider<LibraryController, void>(LibraryController.new);
