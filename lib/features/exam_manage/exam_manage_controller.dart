import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/upload_file.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';
import 'exam_manage_logic.dart';

/// The `useUserStore` slice used by the question / exam management pages
/// (`createquestion.vue`, `EditExams.vue`, `ViewExams.vue`,
/// `ExamAttempts.vue`, `ExamResults.vue`): `exams` (last `fetchExamById`),
/// `examattempts`, `attemptexam` and `batches`.
///
/// Like the Pinia store it outlives the pages, so a page shows the previous
/// exam / attempts until its own request returns (as on the web).
///
/// Store fields shared with other screens go through [lmsHandoffProvider]
/// under their web names: `courses` (`fetchCourse`), `sections` and
/// `classCoursesDropdown` (`fetchCourseDetails`), `institutes`
/// (`getClasses`). The store's `chapters` / `contents` are always derived
/// from `sections` by `fetchCourseDetails`, so the pages derive them too.
class ExamManageState {
  const ExamManageState({
    this.exams,
    this.examattempts = const [],
    this.attemptexam = const [],
    this.batches = const [],
  });

  /// `exams` — the exam object of `fetchExamById` (null until loaded).
  final dynamic exams;

  /// `examattempts` — the attempts array of `fetchExamAttempts`.
  final List<dynamic> examattempts;

  /// `attemptexam` — `res?.response || res` of `fetchAttemptById`
  /// (initially `[]` like the store).
  final dynamic attemptexam;

  /// `batches` — `getBatches(classId)` result.
  final List<Json> batches;

  static const _unset = Object();

  ExamManageState copyWith({
    Object? exams = _unset,
    List<dynamic>? examattempts,
    Object? attemptexam = _unset,
    List<Json>? batches,
  }) =>
      ExamManageState(
        exams: identical(exams, _unset) ? this.exams : exams,
        examattempts: examattempts ?? this.examattempts,
        attemptexam: identical(attemptexam, _unset) ? this.attemptexam : attemptexam,
        batches: batches ?? this.batches,
      );
}

class ExamManageController extends Notifier<ExamManageState> {
  @override
  ExamManageState build() => const ExamManageState();

  int _batchRequestId = 0;

  SessionState get _session => ref.read(sessionProvider);
  UserInfo? get _userInfo => _session.userInfo;
  int? get _instituteId => _userInfo?.instituteId;
  LmsHandoff get _handoff => ref.read(lmsHandoffProvider.notifier);

  /// `this.userInfo.institute_id.toString()` behind the store's
  /// `throw new Error(message)` guards.
  String _requireInstitute([String message = 'Institute ID not available']) {
    final id = _instituteId;
    if (!jsTruthy(id)) throw ApiError(message);
    return '$id';
  }

  // ── courses / classes / batches ─────────────────────────────────────────

  /// `fetchCourse(only_admin?)` → store `courses` (lmsHandoff `courses`).
  Future<void> fetchCourse([int? onlyAdmin]) async {
    final id = _instituteId;
    if (!jsTruthy(id)) return;
    final data = await ref.read(courseServiceProvider).getCourses(id!, onlyAdmin);
    _handoff.set('courses', data is List ? data : asList(data));
  }

  /// `fetchCourseDetails(courseId)` — replaces store `sections` and
  /// `classCoursesDropdown` (lmsHandoff, like the store did for every
  /// screen).
  Future<Json?> fetchCourseDetails(Object courseId) async {
    if (!jsTruthy(_instituteId)) throw const ApiError('User institute ID not set');
    final response = asMap(await ref.read(courseServiceProvider).getCourseDetails(courseId, {
      'institute_id': '$_instituteId',
      'with': 'content',
      'with_curriculums': true,
      'with_instructors': true,
    }));
    if (response == null) return null;
    final sections = mapsOf(response['sections']);
    final chapters = [for (final s in sections) ...mapsOf(s['chapters'])];
    final contents = [for (final c in chapters) ...mapsOf(c['contents'])];
    _handoff.set('sections', sections);
    _handoff.set('classCoursesDropdown', [...contents]);
    return response;
  }

  /// `getClasses()` — every class of the institute with its counts →
  /// store `institutes` (lmsHandoff `institutes`).
  Future<void> getClasses() async {
    final instituteId = _instituteId;
    if (!jsTruthy(instituteId)) return;
    final classService = ref.read(classServiceProvider);
    final data = mapsOf(await classService.getAllClasses(instituteId!));
    final mapped = await Future.wait(data.map((item) async {
      final counts = asMap(await classService.getClassesCount(instituteId, item['id']));
      return <String, dynamic>{
        'id': item['id'],
        'year': item['name'],
        'c_id': item['curricula_id'],
        'students': counts?['students_count'] ?? 0,
        'batches': counts?['batches_count'] ?? 0,
        'instructors': counts?['instructors_count'] ?? 0,
        'courses': counts?['courses_count'] ?? 0,
        'admins': counts?['admin_instructors_count'] ?? 0,
        'status': item['status'] ?? 'unknown',
        'class_level': item['class_level'],
        'is_admin': item['is_admin'] ?? false,
      };
    }));
    _handoff.set('institutes', mapped);
  }

  /// `getBatches(classId?)` — falls back to `classDetails.id`; stale
  /// responses (a newer request, or another institute) are dropped.
  Future<void> getBatches([Object? classId]) async {
    final requestId = ++_batchRequestId;
    state = state.copyWith(batches: const []);
    final cid = jsTruthy(classId) ? classId : _session.classDetails?.id;
    final iid = _instituteId;
    if (!jsTruthy(cid) || iid == null) return;
    final data = await ref.read(batchServiceProvider).getBatches(cid!, iid);
    if (requestId != _batchRequestId || iid != _instituteId) return;
    state = state.copyWith(batches: [
      for (final batch in mapsOf(data))
        {
          'id': batch['id'],
          'exam_batch_id': batch['exam_batch_id'],
          'name': batch['name'],
          'created_at': batch['created_at'],
          'status': batch['status']?.toString().toLowerCase() ?? 'unknown',
          'pivot': () {
            for (final s in mapsOf(batch['students'])) {
              if (dig(s, const ['pivot', 'status']) == true) return s['pivot'];
            }
            return null;
          }(),
        },
    ]);
  }

  // ── exams ───────────────────────────────────────────────────────────────

  /// `fetchExamById(examID)` → store `exams`.
  Future<dynamic> fetchExamById(Object examId) async {
    final id = _requireInstitute();
    final res = await ref.read(examsServiceProvider).getExamById(examId, id);
    state = state.copyWith(exams: res);
    return res;
  }

  /// `fetchExamAttempts(exam_id?, student_id?)` — students see their own
  /// attempts (`exam_user_id`, no exam filter); admins / institutes /
  /// instructors filter by [examId] (and the optional [studentId]).
  Future<dynamic> fetchExamAttempts([Object? examId, Object? studentId]) async {
    final instituteId = _instituteId?.toString();
    if (!jsTruthy(instituteId)) throw const ApiError('Institute ID not available');

    Object? finalStudentId;
    Object? finalExamId;
    final role = _session.role;
    if (role == Role.student) {
      finalStudentId = _userInfo?.examUserId?.toString();
      finalExamId = null;
    } else if (role == Role.admin || role == Role.institute || role == Role.instructor) {
      finalStudentId = studentId;
      finalExamId = examId;
    }

    final res = await ref.read(examsServiceProvider).getExamAttempts(finalExamId, finalStudentId, instituteId);
    final attempts = attemptsFromResponse(res);
    if (attempts == null) {
      throw const ApiError('Unexpected exam attempts response: expected an array of attempts');
    }
    state = state.copyWith(examattempts: attempts);
    return res;
  }

  /// `fetchAttemptById(attemptId)` → store `attemptexam`
  /// (`res?.response || res`).
  Future<dynamic> fetchAttemptById(Object attemptId) async {
    final id = _requireInstitute();
    final res = await ref.read(examsServiceProvider).getAttemptById(attemptId, id);
    final response = asMap(res)?['response'];
    state = state.copyWith(attemptexam: jsTruthy(response) ? response : res);
    return res;
  }

  /// `updateExam(examId, payload)` — `PATCH /exam/{id}` with `institute_id`.
  Future<dynamic> updateExam(Object examId, Json payload) async {
    final id = _requireInstitute();
    return ref.read(examsServiceProvider).updateExam(examId, {'institute_id': id, ...payload});
  }

  /// `uploadExamFile(file)`
  Future<dynamic> uploadExamFile(UploadFile file) async {
    final id = _requireInstitute('Institute not found');
    return ref.read(examsServiceProvider).uploadExamFile({'institute_id': id, 'file': file});
  }

  // ── questions ───────────────────────────────────────────────────────────

  /// `createExamQuestion(payload)` — only the store's listed keys are sent
  /// (see [createQuestionBody]).
  Future<dynamic> createExamQuestion(Json payload) async {
    final id = _requireInstitute();
    return ref.read(questionServiceProvider).createExamQuestion(createQuestionBody(id, payload));
  }

  /// `updateExamQuestion(questionId, payload)` — `PUT` with `institute_id`.
  Future<dynamic> updateExamQuestion(String questionId, Json payload) async {
    final id = _requireInstitute();
    return ref.read(questionServiceProvider).updateExamQuestion(questionId, {'institute_id': id, ...payload});
  }

  /// `getExamQuestions(payload)` — only `exam_section_id`, `exam_chapter_id`
  /// and `default_locale` are forwarded (when truthy); instructors also send
  /// `current_user = 1`.
  Future<dynamic> getExamQuestions([Json? payload]) async {
    final id = _requireInstitute();
    final requestPayload = <String, dynamic>{
      'institute_id': id,
      if (jsTruthy(payload?['exam_section_id'])) 'exam_section_id': payload!['exam_section_id'],
      if (jsTruthy(payload?['exam_chapter_id'])) 'exam_chapter_id': payload!['exam_chapter_id'],
      if (jsTruthy(payload?['default_locale'])) 'default_locale': payload!['default_locale'],
    };
    if (_session.role == Role.instructor) requestPayload['current_user'] = 1;
    return ref.read(questionServiceProvider).getExamQuestions(requestPayload);
  }
}

final examManageControllerProvider =
    NotifierProvider<ExamManageController, ExamManageState>(ExamManageController.new);
