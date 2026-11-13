import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/upload_file.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';

/// The `useUserStore` slice used by `questionslist.vue` and
/// `newquestions.vue`: `courses`, `sections`, `chapters`, `contents`.
///
/// `courses` and `sections` are store fields every classes/courses/exams
/// screen shares, so they live in [lmsHandoffProvider] under those names;
/// this state mirrors them (and derives `chapters` / `contents` the way
/// `fetchCourseDetails` did) so both pages can `ref.watch` it.
class QuestionsState {
  const QuestionsState({
    this.courses = const [],
    this.sections = const [],
    this.chapters = const [],
    this.contents = const [],
  });

  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> sections;

  /// `sections.flatMap(sec => sec.chapters ?? [])`
  final List<Map<String, dynamic>> chapters;

  /// `chapters.flatMap(ch => ch.contents ?? [])`
  final List<Map<String, dynamic>> contents;
}

class QuestionsController extends Notifier<QuestionsState> {
  @override
  QuestionsState build() {
    // Another screen may refresh the shared store fields while this one is
    // alive (Pinia had a single store), so keep following them.
    ref.listen<Map<String, dynamic>>(lmsHandoffProvider, (prev, next) {
      if (!identical(prev?['courses'], next['courses']) || !identical(prev?['sections'], next['sections'])) {
        state = _fromHandoff(next);
      }
    });
    return _fromHandoff(ref.read(lmsHandoffProvider));
  }

  static List<Map<String, dynamic>> _maps(dynamic list) => [for (final e in asList(list)) ?asMap(e)];

  static QuestionsState _fromHandoff(Map<String, dynamic> h) {
    final sections = _maps(h['sections']);
    final chapters = [for (final s in sections) ..._maps(s['chapters'])];
    final contents = [for (final c in chapters) ..._maps(c['contents'])];
    return QuestionsState(courses: _maps(h['courses']), sections: sections, chapters: chapters, contents: contents);
  }

  SessionState get _session => ref.read(sessionProvider);
  UserInfo? get _userInfo => _session.userInfo;
  LmsHandoff get _handoff => ref.read(lmsHandoffProvider.notifier);

  /// `if (!this.userInfo?.institute_id) throw new Error(message)`
  String _requireInstitute([String message = 'Institute ID not available']) {
    final id = _userInfo?.instituteId;
    if (!jsTruthy(id)) throw ApiError(message);
    return '$id';
  }

  // ── courses ─────────────────────────────────────────────────────────────

  /// `fetchCourse(only_admin?)` → store `courses`.
  Future<void> fetchCourse([Object? onlyAdmin]) async {
    final id = _userInfo?.instituteId;
    if (!jsTruthy(id)) return;
    final data = await ref.read(courseServiceProvider).getCourses(id!, onlyAdmin);
    _handoff.set('courses', data is List ? data : asList(data));
  }

  /// `fetchCourseDetails(courseId)` — replaces store `sections` (and with it
  /// `chapters` / `contents`) and `classCoursesDropdown`. The store also
  /// filled `courseForm` / `courseDetails`, which these screens never read.
  Future<Map<String, dynamic>?> fetchCourseDetails(Object courseId) async {
    final instituteId = _requireInstitute('User institute ID not set');
    final response = asMap(await ref.read(courseServiceProvider).getCourseDetails(courseId, {
      'institute_id': instituteId,
      'with': 'content',
      'with_curriculums': true,
      'with_instructors': true,
    }));
    if (response == null) return null;

    final sections = _maps(response['sections']);
    final chapters = [for (final s in sections) ..._maps(s['chapters'])];
    final contents = [for (final c in chapters) ..._maps(c['contents'])];
    _handoff.set('sections', sections);
    _handoff.set('classCoursesDropdown', [...contents]);
    return response;
  }

  // ── questions ───────────────────────────────────────────────────────────

  /// `getExamQuestions(payload?)` — only non-empty `exam_section_id`,
  /// `exam_chapter_id`, `default_locale` are sent; instructors add
  /// `current_user: 1`. Returns the body (`res?.data ?? res` is the list).
  Future<dynamic> getExamQuestions([Map<String, dynamic>? payload]) async {
    final id = _requireInstitute();
    final requestPayload = <String, dynamic>{
      'institute_id': id,
      if (jsTruthy(payload?['exam_section_id'])) 'exam_section_id': payload!['exam_section_id'],
      if (jsTruthy(payload?['exam_chapter_id'])) 'exam_chapter_id': payload!['exam_chapter_id'],
      if (jsTruthy(payload?['default_locale'])) 'default_locale': payload!['default_locale'],
    };
    if (_session.role == 'instructor') requestPayload['current_user'] = 1;
    return ref.read(questionServiceProvider).getExamQuestions(requestPayload);
  }

  /// `deleteExamQuestion(id)`
  Future<dynamic> deleteExamQuestion(Object id) async {
    final instituteId = _requireInstitute();
    return ref.read(questionServiceProvider).deleteExamQuestion(id, instituteId);
  }

  /// `importBulkExamQuestions({ file, exam_course_id, exam_section_id,
  /// exam_chapter_id, default_locale })` — multipart `exam/question/import`.
  Future<dynamic> importBulkExamQuestions({
    required UploadFile file,
    required String examCourseId,
    required String examSectionId,
    required String examChapterId,
    String? defaultLocale,
  }) async {
    final instituteId = _requireInstitute();
    return ref
        .read(questionServiceProvider)
        .importBulkQuestions(instituteId, examCourseId, examSectionId, examChapterId, file, defaultLocale);
  }

  /// `createExamQuestion(payload)` — only the listed keys are forwarded
  /// (so `tags` is dropped, like the web). A key missing from [payload] is
  /// JS `undefined` and left out of the JSON.
  Future<dynamic> createExamQuestion(Map<String, dynamic> payload) async {
    final instituteId = _requireInstitute();
    const keys = [
      'code',
      'title',
      'type',
      'exam_section_id',
      'exam_chapter_id',
      'exam_course_id',
      'difficulty_level',
      'marks',
      'negative_marks',
      'explanation',
      'is_active',
      'topic_id',
      'options',
      'images',
      'video_url',
      'default_locale',
    ];
    return ref.read(questionServiceProvider).createExamQuestion({
      'institute_id': instituteId,
      for (final k in keys)
        if (payload.containsKey(k)) k: payload[k],
    });
  }

  /// `updateExamQuestion(questionId, payload)` — `{ institute_id, ...payload }`.
  Future<dynamic> updateExamQuestion(String questionId, Map<String, dynamic> payload) async {
    final instituteId = _requireInstitute();
    return ref.read(questionServiceProvider).updateExamQuestion(questionId, {'institute_id': instituteId, ...payload});
  }

  /// `uploadExamFile(file)` — multipart `/exam/file`.
  Future<dynamic> uploadExamFile(UploadFile file) async {
    final instituteId = _requireInstitute('Institute not found');
    return ref.read(examsServiceProvider).uploadExamFile({'institute_id': instituteId, 'file': file});
  }
}

final questionsControllerProvider =
    NotifierProvider<QuestionsController, QuestionsState>(QuestionsController.new);
