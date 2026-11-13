import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/upload_file.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';

/// The `useUserStore` slice used by `scheduleexam.vue` and
/// `scheduleexamlist.vue`: `exams` (last `fetchExamById` result) and
/// `currentExamAttempt` (last `startExam` result).
///
/// Store fields shared with other screens go through [lmsHandoffProvider]
/// under their web names: `courses` (`fetchCourse`), `sections` and
/// `classCoursesDropdown` (`fetchCourseDetails`), `currentExamAttempt`
/// (read by `/startexam`), and `activeScheduleIdss` (set by the schedules
/// screens' `setActiveSchedule`, read here).
class ScheduleExamState {
  const ScheduleExamState({this.exams, this.currentExamAttempt});

  /// `exams` — the exam shown by `scheduleexamlist.vue`.
  final dynamic exams;

  /// `currentExamAttempt`
  final dynamic currentExamAttempt;

  static const _unset = Object();

  ScheduleExamState copyWith({Object? exams = _unset, Object? currentExamAttempt = _unset}) =>
      ScheduleExamState(
        exams: identical(exams, _unset) ? this.exams : exams,
        currentExamAttempt:
            identical(currentExamAttempt, _unset) ? this.currentExamAttempt : currentExamAttempt,
      );
}

class ScheduleExamController extends Notifier<ScheduleExamState> {
  @override
  ScheduleExamState build() => const ScheduleExamState();

  SessionState get _session => ref.read(sessionProvider);
  UserInfo? get _userInfo => _session.userInfo;
  LmsHandoff get _handoff => ref.read(lmsHandoffProvider.notifier);

  /// `this.userInfo.institute_id.toString()` — throws like the web's
  /// `throw new Error(message)` when the institute is not known.
  String _requireInstitute([String message = 'Institute ID not available']) {
    final id = _userInfo?.instituteId;
    if (!jsTruthy(id)) throw ApiError(message);
    return '$id';
  }

  // ── courses ─────────────────────────────────────────────────────────────

  /// `fetchCourse(only_admin?)` → store `courses` (lmsHandoff `courses`).
  Future<void> fetchCourse([Object? onlyAdmin]) async {
    final id = _userInfo?.instituteId;
    if (!jsTruthy(id)) return;
    final data = await ref.read(courseServiceProvider).getCourses(id!, onlyAdmin);
    _handoff.set('courses', data is List ? data : asList(data));
  }

  /// `fetchCourseDetails(courseId)` — replaces store `sections` and
  /// `classCoursesDropdown` (lmsHandoff, like the store did for every screen).
  Future<Map<String, dynamic>?> fetchCourseDetails(Object courseId) async {
    if (!jsTruthy(_userInfo?.instituteId)) throw const ApiError('User institute ID not set');
    final instituteId = '${_userInfo!.instituteId}';
    final response = asMap(await ref.read(courseServiceProvider).getCourseDetails(courseId, {
      'institute_id': instituteId,
      'with': 'content',
      'with_curriculums': true,
      'with_instructors': true,
    }));
    if (response == null) return null;

    final sections = [for (final s in asList(response['sections'])) ?asMap(s)];
    final chapters = [for (final s in sections) for (final c in asList(s['chapters'])) ?asMap(c)];
    final contents = [for (final c in chapters) for (final x in asList(c['contents'])) ?asMap(x)];
    _handoff.set('sections', sections);
    _handoff.set('classCoursesDropdown', [...contents]);
    return response;
  }

  // ── exams ───────────────────────────────────────────────────────────────

  /// `uploadExamFile(file)`
  Future<dynamic> uploadExamFile(UploadFile file) async {
    final id = _requireInstitute('Institute not found');
    return ref.read(examsServiceProvider).uploadExamFile({'institute_id': id, 'file': file});
  }

  /// `createScheduleExam(payload)` — adds `institute_id` and posts to
  /// `/schedule/exam`.
  Future<dynamic> createScheduleExam(Map<String, dynamic> payload) async {
    final id = _requireInstitute();
    final finalPayload = {'institute_id': id, ...payload};
    return ref.read(schedulesServiceProvider).createExam(finalPayload);
  }

  /// `updateScheduleExam(schedule_id, data)` — `PUT /schedule/exam/{id}`.
  Future<dynamic> updateScheduleExam(String scheduleId, Map<String, dynamic> data) async {
    final id = _requireInstitute();
    final payload = {'institute_id': id, ...data};
    return ref.read(schedulesServiceProvider).updateScheduleExam(scheduleId, payload);
  }

  /// `getExamQuestions(payload)` — only `exam_section_id`, `exam_chapter_id`
  /// and `default_locale` are forwarded (when truthy); instructors also send
  /// `current_user = 1`.
  Future<dynamic> getExamQuestions([Map<String, dynamic>? payload]) async {
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

  /// `fetchExamById(examID)` → store `exams`.
  Future<dynamic> fetchExamById(Object examId) async {
    final id = _requireInstitute();
    final res = await ref.read(examsServiceProvider).getExamById(examId, id);
    state = state.copyWith(exams: res);
    return res;
  }

  /// `examStatus(exam_id)` — always sets the exam to `SCHEDULED`.
  Future<dynamic> examStatus(String examId) async {
    final id = _requireInstitute();
    return ref.read(examsServiceProvider).examStatus({
      'institute_id': id,
      'exam_id': examId,
      'status': 'SCHEDULED',
    });
  }

  /// `startExam(exam_id)` → store `currentExamAttempt` (also lmsHandoff
  /// `currentExamAttempt` for `/startexam`).
  Future<dynamic> startExam(String examId) async {
    final payload = {
      'institute_id': _userInfo?.instituteId?.toString() ?? '',
      'exam_id': examId,
      'student_id': _userInfo?.examUserId?.toString() ?? '',
    };
    final res = await ref.read(examsServiceProvider).startExam(payload);
    state = state.copyWith(currentExamAttempt: res);
    _handoff.set('currentExamAttempt', res);
    return res;
  }
}

final scheduleExamControllerProvider =
    NotifierProvider<ScheduleExamController, ScheduleExamState>(ScheduleExamController.new);
