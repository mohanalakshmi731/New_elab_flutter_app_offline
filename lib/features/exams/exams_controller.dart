import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/upload_file.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';
import 'exams_logic.dart';

/// The exams slice of `useUserStore` used by `exam.vue`, `ExamsList.vue`,
/// `examcreate.vue` and `newexams.vue`: `examslist`, `examattempts`,
/// `attemptexam`, `exams`, `institutes`, `batches`, `courses`, `sections`
/// (+ `chapters`, `contents`), `currentExamAttempt`.
///
/// Fields other screens read are mirrored into [lmsHandoffProvider] under
/// the web field names: `institutes`, `courses`, `sections`,
/// `classCoursesDropdown` and `currentExamAttempt` (read by `/startexam`).
class ExamsState {
  const ExamsState({
    this.examslist = const [],
    this.examattempts = const [],
    this.attemptexam,
    this.exams,
    this.institutes = const [],
    this.batches = const [],
    this.courses = const [],
    this.sections = const [],
    this.chapters = const [],
    this.contents = const [],
    this.currentExamAttempt,
  });

  /// `examslist` (raw exam rows).
  final List<dynamic> examslist;

  /// `examattempts` (raw attempt rows).
  final List<dynamic> examattempts;

  /// `attemptexam` — `res?.response || res` of `/exam/attempt/{id}`.
  final dynamic attemptexam;

  /// `exams` — last `fetchExamById` result.
  final dynamic exams;

  /// Classes as `{ id, year, c_id, students, … }`.
  final List<Json> institutes;

  /// `{ id, exam_batch_id, name, created_at, status, pivot }`.
  final List<Json> batches;

  /// `courses` — the raw `/course` response.
  final List<dynamic> courses;
  final List<Json> sections;
  final List<Json> chapters;
  final List<Json> contents;
  final dynamic currentExamAttempt;

  static const _unset = Object();

  ExamsState copyWith({
    List<dynamic>? examslist,
    List<dynamic>? examattempts,
    Object? attemptexam = _unset,
    Object? exams = _unset,
    List<Json>? institutes,
    List<Json>? batches,
    List<dynamic>? courses,
    List<Json>? sections,
    List<Json>? chapters,
    List<Json>? contents,
    Object? currentExamAttempt = _unset,
  }) =>
      ExamsState(
        examslist: examslist ?? this.examslist,
        examattempts: examattempts ?? this.examattempts,
        attemptexam: identical(attemptexam, _unset) ? this.attemptexam : attemptexam,
        exams: identical(exams, _unset) ? this.exams : exams,
        institutes: institutes ?? this.institutes,
        batches: batches ?? this.batches,
        courses: courses ?? this.courses,
        sections: sections ?? this.sections,
        chapters: chapters ?? this.chapters,
        contents: contents ?? this.contents,
        currentExamAttempt: identical(currentExamAttempt, _unset) ? this.currentExamAttempt : currentExamAttempt,
      );
}

/// Store actions used by the exam screens, ported 1:1.
class ExamsController extends Notifier<ExamsState> {
  @override
  ExamsState build() => const ExamsState();

  int _batchRequestId = 0;

  SessionState get _session => ref.read(sessionProvider);
  UserInfo? get _userInfo => _session.userInfo;
  int? get _instituteId => _userInfo?.instituteId;
  String get _role => _session.role;
  LmsHandoff get _handoff => ref.read(lmsHandoffProvider.notifier);

  /// `if (!this.userInfo?.institute_id) throw new Error('Institute ID not available')`
  String _requireInstitute([String message = 'Institute ID not available']) {
    final id = _instituteId;
    if (id == null || id == 0) throw ApiError(message);
    return '$id';
  }

  // ── exams ────────────────────────────────────────────────────────────

  /// `fetchExams(default_locale?, class_id?, exam_batch_id?)` → the list.
  Future<List<dynamic>> fetchExams([String? defaultLocale, Object? classId, Object? examBatchId]) async {
    final instituteId = _requireInstitute();
    final res = await ref.read(examsServiceProvider).getExams(instituteId, defaultLocale, classId, examBatchId);
    final exams = unwrapExamArray(res);
    if (exams == null) {
      throw const ApiError('Unexpected exam list response: expected an array of exams');
    }
    state = state.copyWith(examslist: exams);
    return exams;
  }

  /// `fetchExamAttempts(exam_id?, student_id_from_component?)` — students
  /// always get their own attempts (the exam id is ignored).
  Future<dynamic> fetchExamAttempts([Object? examId, Object? studentIdFromComponent]) async {
    final instituteId = _instituteId?.toString();
    if (instituteId == null || instituteId.isEmpty) throw const ApiError('Institute ID not available');

    Object? finalStudentId;
    Object? finalExamId;
    if (_role == Role.student) {
      finalStudentId = _userInfo?.examUserId?.toString();
      finalExamId = null;
    } else if (_role == Role.admin || _role == Role.institute || _role == Role.instructor) {
      finalStudentId = studentIdFromComponent;
      finalExamId = examId;
    }

    final res = await ref.read(examsServiceProvider).getExamAttempts(finalExamId, finalStudentId, instituteId);
    final attempts = unwrapExamArray(res);
    if (attempts == null) {
      throw const ApiError('Unexpected exam attempts response: expected an array of attempts');
    }
    state = state.copyWith(examattempts: attempts);
    return res;
  }

  /// `fetchAttemptById(attemptId)` → `attemptexam = res?.response || res`.
  Future<dynamic> fetchAttemptById(Object attemptId) async {
    final instituteId = _requireInstitute();
    final res = await ref.read(examsServiceProvider).getAttemptById(attemptId, instituteId);
    state = state.copyWith(attemptexam: jsOr(asMap(res)?['response'], res));
    return res;
  }

  /// `fetchExamById(examID)` → `exams`.
  Future<dynamic> fetchExamById(Object examId) async {
    final instituteId = _requireInstitute();
    final res = await ref.read(examsServiceProvider).getExamById(examId, instituteId);
    state = state.copyWith(exams: res);
    return res;
  }

  /// `examStatus(exam_id)` — always publishes (`SCHEDULED`).
  Future<dynamic> examStatus(Object examId) async {
    final instituteId = _requireInstitute();
    return ref.read(examsServiceProvider).examStatus({
      'institute_id': instituteId,
      'exam_id': examId,
      'status': 'SCHEDULED',
    });
  }

  /// `examDelete(examId)`
  Future<dynamic> examDelete(Object examId) async {
    final instituteId = _requireInstitute();
    return ref.read(examsServiceProvider).deleteExam(examId, instituteId);
  }

  /// `startExam(exam_id)` → `currentExamAttempt` (also lmsHandoff
  /// `currentExamAttempt`, read by `/startexam`).
  Future<dynamic> startExam(Object examId) async {
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

  /// `createExam(payload)` — `{ institute_id, ...payload }`.
  Future<dynamic> createExam(Json payload) async {
    final instituteId = _requireInstitute();
    return ref.read(examsServiceProvider).createExam({'institute_id': instituteId, ...payload});
  }

  /// `uploadExamFile(file)`
  Future<dynamic> uploadExamFile(UploadFile file) async {
    final instituteId = _requireInstitute('Institute not found');
    return ref.read(examsServiceProvider).uploadExamFile({'institute_id': instituteId, 'file': file});
  }

  // ── classes / batches ────────────────────────────────────────────────

  /// `getClasses(institute_id_or_filter?, filter?)` — every class (or the
  /// published ones) with its counts, as `{ id, year, c_id, … }`.
  Future<void> getClasses([Object? instituteIdOrFilter, String? filter]) async {
    Object? instituteId;
    String? finalFilter;
    if (instituteIdOrFilter == 'published') {
      instituteId = _instituteId;
      finalFilter = 'published';
    } else {
      instituteId = jsTruthy(instituteIdOrFilter) ? instituteIdOrFilter : _instituteId;
      finalFilter = filter;
    }
    if (!jsTruthy(instituteId)) return;

    final classService = ref.read(classServiceProvider);
    final data = examMaps(await classService.getAllClasses(instituteId!));
    final filtered = finalFilter == 'published' ? data.where((c) => c['status'] == 'published').toList() : data;

    final mapped = await Future.wait(filtered.map((item) async {
      final counts = asMap(await classService.getClassesCount(instituteId!, item['id']));
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
    state = state.copyWith(institutes: mapped);
    _handoff.set('institutes', mapped);
  }

  /// `getBatches(classId?)` — falls back to `classDetails.id`; responses of
  /// an older request (or another institute) are dropped.
  Future<void> getBatches([Object? classId]) async {
    final requestId = ++_batchRequestId;
    state = state.copyWith(batches: const []);
    final cid = jsTruthy(classId) ? classId : _session.classDetails?.id;
    final iid = _instituteId;
    if (!jsTruthy(cid) || iid == null) return;
    final data = await ref.read(batchServiceProvider).getBatches(cid!, iid);
    if (requestId != _batchRequestId || iid != _instituteId) return;
    state = state.copyWith(batches: [
      for (final batch in examMaps(data))
        {
          'id': batch['id'],
          'exam_batch_id': batch['exam_batch_id'],
          'name': batch['name'],
          'created_at': batch['created_at'],
          'status': batch['status']?.toString().toLowerCase() ?? 'unknown',
          'pivot': () {
            for (final s in examMaps(batch['students'])) {
              if (dig(s, ['pivot', 'status']) == true) return s['pivot'];
            }
            return null;
          }(),
        },
    ]);
  }

  // ── courses ──────────────────────────────────────────────────────────

  /// `fetchCourse(only_admin?)` → `courses`.
  Future<void> fetchCourse([int? onlyAdmin]) async {
    final id = _instituteId;
    if (id == null || id == 0) return;
    final data = await ref.read(courseServiceProvider).getCourses(id, onlyAdmin);
    final list = asList(data);
    state = state.copyWith(courses: list);
    _handoff.set('courses', list);
  }

  /// `fetchCourseDetails(courseId)` — sections → chapters → contents; the
  /// flattened contents also become `classCoursesDropdown`.
  Future<Json?> fetchCourseDetails(Object? courseId) async {
    final id = _instituteId;
    if (id == null || id == 0) throw const ApiError('User institute ID not set');
    final response = asMap(await ref.read(courseServiceProvider).getCourseDetails(courseId ?? 'undefined', {
      'institute_id': '$id',
      'with': 'content',
      'with_curriculums': true,
      'with_instructors': true,
    }));
    if (response == null) return null;
    final sections = examMaps(response['sections']);
    final chapters = [for (final s in sections) ...examMaps(s['chapters'])];
    final contents = [for (final c in chapters) ...examMaps(c['contents'])];
    state = state.copyWith(sections: sections, chapters: chapters, contents: contents);
    _handoff.set('sections', sections);
    _handoff.set('classCoursesDropdown', [...contents]);
    return response;
  }
}

final examsControllerProvider = NotifierProvider<ExamsController, ExamsState>(ExamsController.new);
