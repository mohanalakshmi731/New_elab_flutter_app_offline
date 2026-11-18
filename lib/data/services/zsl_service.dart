import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart';
import '../../core/network/content_cache.dart';
import '../models/session.dart';
import 'js_compat.dart';

/// Port of src/service/zsl.ts (TS class `ZSL`).
///
/// The web read `useUserStore()` (role / userInfo) inside [getClass];
/// [_session] returns the current session for the same purpose.
///
/// The curriculum reads (all classes, subjects, chapters, chapter links) go
/// through [ContentCache]: each is proxied by the backend to the external ZSL
/// content service and was the main cost of opening the MathZoro / zone /
/// library screens again and again.
class ZslService {
  ZslService(this._api, this._session, {ContentCache? cache}) : _cache = cache;
  final ApiClient _api;
  final SessionState Function() _session;
  final ContentCache? _cache;

  static const _curriculumTtl = Duration(hours: 6);
  static const _chapterLinksTtl = Duration(minutes: 30);
  static const _chapterLinksKey = 'zsl/chapter/links';

  /// Cache key scoped to the logged-in user (null = don't cache).
  String? _key(String path, List<Object?> parts) {
    final userId = _session().userInfo?.id;
    if (_cache == null || userId == null) return null;
    return '$path|u$userId|${parts.map((p) => p ?? '').join('|')}';
  }

  Future<dynamic> _cached(
    String path,
    List<Object?> parts,
    Duration ttl,
    Future<dynamic> Function({required bool background}) load,
  ) {
    if (_api.isOffline?.call() == true) return load(background: false);
    final key = _key(path, parts);
    if (key == null) return load(background: false);
    return _cache!.fetch(key, load, ttl: ttl);
  }

  /// Get ALL classes without any filters.
  Future<dynamic> getClassAll() => _cached(
    'zsl/classes/all',
    const [],
    _curriculumTtl,
    ({required background}) => _api.get('/zsl/classes/all', silent: background),
  );

  /// Get classes filtered by institute; students of MathZoro also send
  /// `sub_user_id` ([zslId] or the session's `userInfo.zsl`).
  Future<dynamic> getClass([Object? instituteId, Object? zslId]) {
    final store = _session();
    final params = <String, dynamic>{};

    if (jsTruthy(instituteId)) {
      params['institute_id'] = instituteId;
      params['syllabus'] = null;
    }

    final role = store.role.toLowerCase();
    final isMathZoro = store.userInfo?.isMathZoro ?? false;

    final subUserId = zslId != null && zslId != ''
        ? zslId
        : store.userInfo?.zsl;

    if (role == 'student' && isMathZoro && jsTruthy(subUserId)) {
      params['sub_user_id'] = subUserId;
    }

    return _api.post('/zsl/classes', data: params);
  }

  Future<dynamic> getAllSubjects(Object instituteId, Object classId) => _cached(
    'zsl/subjects',
    [instituteId, classId],
    _curriculumTtl,
    ({required background}) => _api.post(
      '/zsl/subjects',
      silent: background,
      data: {'institute_id': instituteId, 'zsl_class_id': classId},
    ),
  );

  Future<dynamic> getAllChapters(
    Object instituteId,
    Object classId,
    Object subjectId,
  ) => _cached(
    'zsl/chapters',
    [instituteId, classId, subjectId],
    _curriculumTtl,
    ({required background}) => _api.post(
      '/zsl/chapters',
      silent: background,
      data: {
        'institute_id': instituteId,
        'zsl_class_id': classId,
        'zsl_subject_id': subjectId,
      },
    ),
  );

  /// Per student (`sub_user_id`), so kept fresh for a shorter time and
  /// dropped whenever a quiz / activity result is recorded.
  Future<dynamic> getChapterLinks(
    Object instituteId,
    Object chapterId, [
    Object? languageId,
    Object? subUserId,
  ]) => _cached(
    _chapterLinksKey,
    [instituteId, chapterId, languageId, subUserId],
    _chapterLinksTtl,
    ({required background}) => _api.post(
      '/zsl/chapter/links',
      silent: background,
      data: {
        'institute_id': instituteId,
        'zsl_chapter_id': chapterId,
        'language_id': languageId,
        'sub_user_id': subUserId,
      },
    ),
  );

  Future<void> _invalidateChapterLinks() async =>
      _cache?.invalidate(_chapterLinksKey);

  /// Errors are swallowed and `null` is returned, like the web.
  Future<dynamic> getSignedUrl(
    Object instituteId,
    Object sectionId,
    Object chapterId,
    Object contentId,
  ) async {
    try {
      return await _api.post(
        '/zsl/signed/link',
        data: {
          'institute_id': instituteId,
          'section_id': sectionId,
          'chapter_id': chapterId,
          'content_id': contentId,
        },
      );
    } catch (e) {
      debugPrint('$e');
      return null;
    }
  }

  /// Get states filtered by state code.
  Future<dynamic> getAllStatus(String stateCode) =>
      _api.get('/zsl/states', query: {'state': stateCode});

  /// Get activity chart statistics.
  Future<dynamic> getAllStats(Map<String, dynamic>? params) =>
      _api.get('/tracking/activity/get/individual', query: params);

  /// Web path was `zsl/signed/link/chapter-reference` (axios joins it to the
  /// base URL with a `/`). Sent both as body and as query params.
  Future<dynamic> getChapterReferenceSignedLink(Map<String, dynamic> payload) =>
      _api.post(
        '/zsl/signed/link/chapter-reference',
        data: payload,
        query: {
          'institute_id': payload['institute_id'],
          'chapter_id': payload['chapter_id'],
        },
      );

  Future<dynamic> getWhyToLearnSignedUrl(
    Object instituteId,
    Object descriptionId,
  ) => _api.post(
    '/zsl/signed/link/description',
    data: {'institute_id': instituteId, 'description_id': descriptionId},
    query: {'institute_id': instituteId, 'description_id': descriptionId},
  );

  Future<dynamic> getTeacherGuideSignedUrl(
    Object instituteId,
    Object instructionId,
  ) => _api.post(
    '/zsl/signed/link/instruction',
    data: {'institute_id': instituteId, 'instruction_id': instructionId},
    query: {'institute_id': instituteId, 'instruction_id': instructionId},
  );

  Future<dynamic> getLearningOutcomeSignedUrl(
    Object instituteId,
    Object observationId,
  ) => _api.post(
    '/zsl/signed/link/observation',
    data: {'institute_id': instituteId, 'observation_id': observationId},
    query: {'institute_id': instituteId, 'observation_id': observationId},
  );

  /// "How to play" (autopilot) signed link — body and query params.
  Future<dynamic> getAutopilotSignedUrl(
    Object instituteId,
    Object autopilotId,
  ) {
    final payload = {'institute_id': instituteId, 'autopilot_id': autopilotId};
    return _api.post(
      '/zsl/signed/link/autopilot',
      data: payload,
      query: payload,
    );
  }

  Future<dynamic> getQuestions(
    Object instituteId,
    Object activityId, [
    Object? languageId,
  ]) => _api.post(
    '/zsl/questions',
    data: {
      'institute_id': instituteId,
      'activity_id': activityId,
      'language_id': languageId,
    },
  );

  Future<dynamic> submitQuiz(Map<String, dynamic> payload) async {
    final res = await _api.post('/zsl/attempt-quiz', data: payload);
    await _invalidateChapterLinks();
    return res;
  }

  Future<dynamic> getSubjectPerformance(
    Object instituteId,
    Object classesId,
    Object subjectId,
    Object subUserId,
  ) => _api.get(
    '/zsl/get-subject-performance',
    query: {
      'institute_id': instituteId,
      'classes_id': classesId,
      'subject_id': subjectId,
      'sub_user_id': subUserId,
    },
  );

  Future<dynamic> recordActivityPerformance(
    Map<String, dynamic> payload,
  ) async {
    final res = await _api.post(
      '/zsl/record-activity-performance',
      data: payload,
    );
    await _invalidateChapterLinks();
    return res;
  }

  Future<dynamic> getXp(
    Object instituteId,
    Object classesId,
    Object subUserId,
  ) => _api.get(
    '/zsl/get-xp',
    query: {
      'institute_id': instituteId,
      'classes_id': classesId,
      'sub_user_id': subUserId,
    },
  );

  /// Activity quiz performance (`GET /zsl/get-quiz-performance`, used by the
  /// Activity Reports page). [payload] keys as on the web: `institute_id`
  /// (required) plus optional `classes_id`, `subject_id`, `chapter_id`,
  /// `topic_id`, `activity_id`. Like the TS method it fails (without a
  /// request) when `institute_id` is blank.
  Future<dynamic> getQuizPerformance(Map<String, dynamic> payload) async {
    final instituteId = payload['institute_id'];
    if (instituteId == null || '$instituteId'.trim().isEmpty) {
      throw const ApiError(
        'An institute is required to load quiz performance.',
      );
    }
    return _api.get('/zsl/get-quiz-performance', query: payload);
  }
}
