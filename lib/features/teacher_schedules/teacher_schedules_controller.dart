import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/upload_file.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';
import 'teacher_schedules_logic.dart';

/// The slice of `useUserStore` that `teacherschedules.vue` maps:
/// `institutes`, `batches`, `instructors`, `schedules`, `ongoingschedules`,
/// `getbyidschedules`, `scheduleStudents`, `attendanceRecords`, `sections`,
/// `contents`, `zoomMeetingData`, `meetingLink`, `activeScheduleIdss`.
///
/// `userInfo` / `role` / `batchDetails` / `classDetails` live in
/// [sessionProvider] (`fetchschedulesClassDetails` stores the whole class
/// response there, courses included, like the web). These store fields are
/// also published to [lmsHandoffProvider] for other screens: `institutes`
/// (getClasses), `sections` + `classCoursesDropdown` (fetchCourseDetails),
/// `activeScheduleIdss` (setActiveSchedule, read by ScheduleExamView) and
/// `zoomMeetingData` (setZoomMeetingData).
class TeacherSchedulesState {
  const TeacherSchedulesState({
    this.institutes = const [],
    this.batches = const [],
    this.instructors = const [],
    this.schedules = const [],
    this.ongoingschedules = const [],
    this.getbyidschedules = const [],
    this.scheduleStudents = const [],
    this.attendanceRecords = const [],
    this.sections = const [],
    this.contents = const [],
    this.zoomMeetingData,
    this.meetingLink = '',
    this.activeScheduleIdss,
  });

  /// `getClasses()` items: `{ id, year, c_id, students, batches, … }`.
  final List<Json> institutes;

  /// `getBatches()` items: `{ id, exam_batch_id, name, created_at, status, pivot }`.
  final List<Json> batches;
  final List<dynamic> instructors;
  final List<dynamic> schedules;
  final List<dynamic> ongoingschedules;
  final List<dynamic> getbyidschedules;

  /// `res?.data || res` of `/schedule/students` (normally a list).
  final dynamic scheduleStudents;
  final dynamic attendanceRecords;
  final List<dynamic> sections;
  final List<dynamic> contents;
  final dynamic zoomMeetingData;
  final String meetingLink;
  final int? activeScheduleIdss;

  static const _unset = Object();

  TeacherSchedulesState copyWith({
    List<Json>? institutes,
    List<Json>? batches,
    List<dynamic>? instructors,
    List<dynamic>? schedules,
    List<dynamic>? ongoingschedules,
    List<dynamic>? getbyidschedules,
    Object? scheduleStudents = _unset,
    Object? attendanceRecords = _unset,
    List<dynamic>? sections,
    List<dynamic>? contents,
    Object? zoomMeetingData = _unset,
    String? meetingLink,
    Object? activeScheduleIdss = _unset,
  }) =>
      TeacherSchedulesState(
        institutes: institutes ?? this.institutes,
        batches: batches ?? this.batches,
        instructors: instructors ?? this.instructors,
        schedules: schedules ?? this.schedules,
        ongoingschedules: ongoingschedules ?? this.ongoingschedules,
        getbyidschedules: getbyidschedules ?? this.getbyidschedules,
        scheduleStudents: identical(scheduleStudents, _unset) ? this.scheduleStudents : scheduleStudents,
        attendanceRecords: identical(attendanceRecords, _unset) ? this.attendanceRecords : attendanceRecords,
        sections: sections ?? this.sections,
        contents: contents ?? this.contents,
        zoomMeetingData: identical(zoomMeetingData, _unset) ? this.zoomMeetingData : zoomMeetingData,
        meetingLink: meetingLink ?? this.meetingLink,
        activeScheduleIdss: identical(activeScheduleIdss, _unset) ? this.activeScheduleIdss : activeScheduleIdss as int?,
      );
}

/// Store actions mapped by `teacherschedules.vue`, ported 1:1.
class TeacherSchedulesController extends Notifier<TeacherSchedulesState> {
  @override
  TeacherSchedulesState build() => const TeacherSchedulesState();

  int _batchRequestId = 0;

  SessionState get _session => ref.read(sessionProvider);
  int? get _instituteId => _session.userInfo?.instituteId;
  SchedulesService get _svc => ref.read(schedulesServiceProvider);
  LmsHandoff get _handoff => ref.read(lmsHandoffProvider.notifier);

  /// `if (!this.userInfo?.institute_id) throw new Error('Institute ID not available')`
  /// (also stands in for the web's `this.userInfo!.institute_id!.toString()` TypeErrors).
  String get _iidOrThrow {
    final id = _instituteId;
    if (id == null || id == 0) throw const ApiError('Institute ID not available');
    return '$id';
  }

  static List<Json> _maps(Object? list) => [for (final e in asList(list)) ?asMap(e)];

  static List<dynamic> _replaceOrAppend(List<dynamic> list, Object? item) {
    final id = asMap(item)?['id'];
    final idx = list.indexWhere((s) => asMap(s)?['id'] == id);
    final next = [...list];
    if (idx >= 0) {
      next[idx] = item;
    } else {
      next.add(item);
    }
    return next;
  }

  // ── classes / batches / instructors ──────────────────────────────────────

  /// `getClasses(institute_id_or_filter?, filter?)`
  Future<void> getClasses([Object? instituteIdOrFilter, String? filter]) async {
    Object? instituteId;
    String? finalFilter;
    if (instituteIdOrFilter == 'published') {
      instituteId = _instituteId;
      finalFilter = 'published';
    } else {
      instituteId = orJs(instituteIdOrFilter, _instituteId);
      finalFilter = filter;
    }
    if (!jsTruthy(instituteId)) return;

    final svc = ref.read(classServiceProvider);
    final data = _maps(await svc.getAllClasses(instituteId!));
    final filtered = finalFilter == 'published' ? data.where((c) => c['status'] == 'published').toList() : data;
    final mapped = await Future.wait(filtered.map((item) async {
      final counts = asMap(await svc.getClassesCount(instituteId!, item['id']));
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

  /// `getBatches(classId?)` — newer calls win (`batchRequestId`).
  Future<void> getBatches([int? classId]) async {
    final requestId = ++_batchRequestId;
    state = state.copyWith(batches: const []);
    final cid = (classId != null && classId != 0) ? classId : _session.classDetails?.id;
    final iid = _instituteId;
    if (cid == null || cid == 0 || iid == null) return;
    final data = await ref.read(batchServiceProvider).getBatches(cid, iid);
    if (requestId != _batchRequestId || iid != _instituteId) return;
    state = state.copyWith(batches: [
      for (final b in _maps(data))
        {
          'id': b['id'],
          'exam_batch_id': b['exam_batch_id'],
          'name': b['name'],
          'created_at': b['created_at'],
          'status': orJs(b['status']?.toString().toLowerCase(), 'unknown'),
          'pivot': asList(b['students'])
              .map((s) => asMap(asMap(s)?['pivot']))
              .where((p) => p != null && p['status'] == true)
              .firstOrNull,
        },
    ]);
  }

  /// `getInstructorsdropdown(classId)` — every page; errors are logged.
  Future<void> getInstructorsdropdown(int? classId) async {
    if (classId == null || classId == 0) return;
    state = state.copyWith(instructors: const []);
    var currentPage = 1;
    var lastPage = 1;
    final all = <dynamic>[];
    try {
      do {
        final res = asMap(await ref.read(instructorServiceProvider).getInstructors(classId, currentPage)) ?? const {};
        all.addAll([
          for (final i in _maps(res['data']))
            {
              ...i,
              'user': jsTruthy(i['user'])
                  ? i['user']
                  : {'first_name': '', 'last_name': '', 'email': '', 'phone': '', 'country_code': ''},
            },
        ]);
        lastPage = asInt(res['last_page']) ?? 1;
        currentPage++;
      } while (currentPage <= lastPage);
      state = state.copyWith(instructors: all);
    } catch (_) {}
  }

  /// `fetchschedulesClassDetails(classId)` — published courses only; the
  /// response becomes the session `classDetails`.
  Future<dynamic> fetchschedulesClassDetails(Object classId) async {
    final iid = _iidOrThrow;
    final raw = await ref.read(classServiceProvider).getClassDetails('$classId', {
      'institute_id': iid,
      'withCourses': 'yes',
    });
    final response = asMap(raw) == null ? null : Map<String, dynamic>.of(asMap(raw)!);
    if (response != null) {
      if (response['courses'] is List) {
        response['courses'] = [
          for (final c in response['courses'] as List)
            if (asMap(c)?['status'] == 'published') c,
        ];
      }
      response['c_id'] = response['curricula_id'] ?? response['c_id'];
    }
    ref.read(sessionProvider.notifier).setClassDetails(response == null ? null : IdName.fromJson(response));
    return response;
  }

  /// `fetchCourseDetails(courseId)` — the part this screen relies on:
  /// `sections` → `chapters` → `contents` → `classCoursesDropdown`.
  Future<dynamic> fetchCourseDetails(Object courseId) async {
    final iid = _iidOrThrow;
    final response = asMap(await ref.read(courseServiceProvider).getCourseDetails(courseId, {
      'institute_id': iid,
      'with': 'content',
      'with_curriculums': true,
      'with_instructors': true,
    }));
    if (response == null) return null;
    final sections = asList(response['sections']);
    final chapters = [for (final s in sections) ...asList(asMap(s)?['chapters'])];
    final contents = [for (final c in chapters) ...asList(asMap(c)?['contents'])];
    state = state.copyWith(sections: sections, contents: contents);
    _handoff
      ..set('sections', sections)
      ..set('classCoursesDropdown', [...contents]);
    return response;
  }

  // ── schedules ────────────────────────────────────────────────────────────

  /// `getSchedules(filters)` — students always filter on their batch.
  Future<void> getSchedules([Map<String, dynamic> filters = const {}]) async {
    final iid = _instituteId;
    if (iid == null || iid == 0) return;
    Object? batchIdToSend = filters['batch_id'];
    if (_session.role == 'student') {
      batchIdToSend = _session.batchDetails?.id?.toString() ?? filters['batch_id'];
    }
    final params = <String, dynamic>{
      'institute_id': '$iid',
      ...filters,
      'batch_id': batchIdToSend,
    }..removeWhere((_, v) => v == null);
    final res = await _svc.get(params);
    state = state.copyWith(schedules: res is List ? res : asList(orJs(asMap(res)?['data'], const [])));
  }

  /// `getScheduleById(scheduleId)` — also loads the schedule's course
  /// (`fetchCourseDetails`, failures only logged).
  Future<dynamic> getScheduleById(Object scheduleId) async {
    final instituteId = _instituteId?.toString() ?? '';
    final schedule = await _svc.getById(scheduleId, instituteId);
    state = state.copyWith(getbyidschedules: _replaceOrAppend(state.getbyidschedules, schedule));
    final courseId = dig(schedule, ['course', 'id']);
    if (jsTruthy(courseId)) {
      try {
        await fetchCourseDetails(asInt(courseId) ?? courseId);
      } catch (_) {}
    }
    return schedule;
  }

  /// `getNextSchedules()` — `[]` on errors.
  Future<List<dynamic>> getNextSchedules() async {
    final iid = _instituteId;
    if (iid == null || iid == 0) return [];
    try {
      final res = await _svc.getNext('$iid');
      final list = res is List ? [...res] : [res];
      state = state.copyWith(ongoingschedules: list);
      return list;
    } catch (_) {
      return [];
    }
  }

  /// `updateSchedule(scheduleId, payload)`
  Future<dynamic> updateSchedule(Object scheduleId, Map<String, dynamic> payload) async {
    final res = await _svc.update(scheduleId, {'institute_id': _iidOrThrow, ...payload});
    state = state.copyWith(
      getbyidschedules: _replaceOrAppend(state.getbyidschedules, res),
      schedules: _replaceOrAppend(state.schedules, res),
    );
    return res;
  }

  /// `deleteSchedule(scheduleId)`
  Future<dynamic> deleteSchedule(Object scheduleId) async {
    final res = await _svc.deleteSchedule(scheduleId, _iidOrThrow);
    bool keep(Object? s) => jsString(asMap(s)?['id']) != '$scheduleId';
    state = state.copyWith(
      schedules: state.schedules.where(keep).toList(),
      getbyidschedules: state.getbyidschedules.where(keep).toList(),
    );
    return res;
  }

  /// `startSchedule(scheduleId)` — keeps `res.data.meeting_link`.
  Future<dynamic> startSchedule(Object scheduleId) async {
    final res = await _svc.start(_iidOrThrow, scheduleId, _session.userInfo?.email ?? '');
    final link = dig(res, ['data', 'meeting_link']);
    if (jsTruthy(link)) state = state.copyWith(meetingLink: '$link');
    return res;
  }

  /// `createSchedule({ batches, slots })`
  Future<dynamic> createSchedule({required List<String> batches, required List<Json> slots}) =>
      _svc.create({'institute_id': _iidOrThrow, 'batches': batches, 'slots': slots});

  // ── references / activities ──────────────────────────────────────────────

  /// `createScheduleActivity(payload)` — `file` dropped when empty.
  Future<dynamic> createScheduleActivity(Map<String, dynamic> payload) {
    final body = <String, dynamic>{...payload, 'institute_id': _iidOrThrow};
    if (payload['file'] is! UploadFile) body.remove('file');
    return _svc.createActivity(body);
  }

  /// `createScheduleReferenceActivity(payload)`
  Future<dynamic> createScheduleReferenceActivity(Map<String, dynamic> payload) {
    final body = <String, dynamic>{
      'institute_id': _iidOrThrow,
      'schedule_id': payload['schedule_id'],
      'name': payload['name'],
      'type': payload['type'],
      if (jsTruthy(payload['content_id'])) 'content_id': payload['content_id'],
      if (jsTruthy(payload['html_content'])) 'html_content': payload['html_content'],
      if (jsTruthy(payload['url'])) 'url': payload['url'],
      if (payload['file'] is UploadFile) 'file': payload['file'],
    };
    return _svc.referenceActivity(body);
  }

  /// `updateScheduleActivity(activityId, payload)` (`cleanPayload` applied).
  Future<dynamic> updateScheduleActivity(Object activityId, Map<String, dynamic> payload) {
    final body = cleanPayload({
      'institute_id': _iidOrThrow,
      'schedule_id': '${payload['schedule_id']}',
      'activity_type': payload['activity_type'],
      'name': payload['name'],
      'type': payload['type'],
      'html_content': payload['html_content'],
      'url': payload['url'],
      'file': payload['file'],
      'content_id': payload['content_id'] == null ? null : jsString(payload['content_id']),
    });
    return _svc.updateActivity('$activityId', body);
  }

  /// `updateScheduleReference(id, payload)` (`cleanPayload` applied).
  Future<dynamic> updateScheduleReference(Object id, Map<String, dynamic> payload) {
    final body = cleanPayload({
      'institute_id': _iidOrThrow,
      'schedule_id': payload['schedule_id'],
      'name': payload['name'],
      'type': payload['type'],
      'html_content': payload['html_content'],
      'url': payload['url'],
      'file': payload['file'],
      'content_id': payload['content_id'],
    });
    return _svc.updateReference(id, body);
  }

  /// `deleteclassScheduleReference(id)`
  Future<dynamic> deleteclassScheduleReference(Object id) => _svc.deleteReference(id, _iidOrThrow);

  /// `deleteclassScheduleActivity(id)`
  Future<dynamic> deleteclassScheduleActivity(Object id) => _svc.deleteActivity(id, _iidOrThrow);

  // ── chat / attendance / students ─────────────────────────────────────────

  /// `ScheduleMessages(scheduleId, message)`
  // ignore: non_constant_identifier_names
  Future<dynamic> ScheduleMessages(Object scheduleId, String message) =>
      _svc.ScheduleMessages(_iidOrThrow, scheduleId, message);

  /// `getScheduleMessages(scheduleId)` — `[]` without an institute or on errors.
  Future<dynamic> getScheduleMessages(Object scheduleId) async {
    final iid = _instituteId;
    if (iid == null || iid == 0) return [];
    try {
      return await _svc.getScheduleMessages(scheduleId, '$iid');
    } catch (_) {
      return [];
    }
  }

  /// `scheduleAttendance(scheduleId)`
  Future<dynamic> scheduleAttendance(Object scheduleId) async {
    final res = await _svc.scheduleAttendance(_iidOrThrow, scheduleId);
    state = state.copyWith(attendanceRecords: orJs(asMap(res)?['data'], res));
    return res;
  }

  /// `fetchscheduleStudents(scheduleId)`
  Future<dynamic> fetchscheduleStudents(Object scheduleId) async {
    final res = await _svc.fetchscheduleStudents(_iidOrThrow, scheduleId);
    state = state.copyWith(scheduleStudents: orJs(asMap(res)?['data'], res));
    return res;
  }

  /// `markScheduleAttendance(schedule_id, participant_uuid?, student_id?)`
  Future<dynamic> markScheduleAttendance(String scheduleId, [String? participantUuid, String? studentId]) async {
    final iid = _iidOrThrow;
    if (scheduleId.isEmpty) throw const ApiError('Schedule ID is required');
    final finalStudentId = jsTruthy(studentId) ? studentId : _session.userInfo?.studentId?.toString();
    final payload = <String, dynamic>{
      'institute_id': iid,
      'schedule_id': scheduleId,
      if (jsTruthy(participantUuid)) 'participant_uuid': participantUuid,
      if (jsTruthy(finalStudentId)) 'student_id': finalStudentId,
    };
    final res = await _svc.markAttendance(payload);
    final m = asMap(res);
    final attendanceData = m != null && m['data'] != null ? m['data'] : res;
    if (jsTruthy(attendanceData)) {
      final List<dynamic> normalized;
      if (attendanceData is List) {
        normalized = attendanceData;
      } else if (asMap(attendanceData) != null) {
        normalized = [
          for (final entry in asMap(attendanceData)!.values)
            if (entry is List) ...entry else entry,
        ];
      } else {
        normalized = [attendanceData];
      }
      state = state.copyWith(attendanceRecords: normalized);
    }
    return res;
  }

  /// `setZoomMeetingData(data)` — also published as `zoomMeetingData`.
  void setZoomMeetingData(Object? data) {
    state = state.copyWith(zoomMeetingData: data);
    _handoff.set('zoomMeetingData', data);
  }

  /// `setActiveSchedule(scheduleId)` — also published as `activeScheduleIdss`
  /// (ScheduleExamView saves with it).
  void setActiveSchedule(int? scheduleId) {
    state = state.copyWith(activeScheduleIdss: scheduleId);
    _handoff.set('activeScheduleIdss', scheduleId);
  }
}

final teacherSchedulesControllerProvider =
    NotifierProvider<TeacherSchedulesController, TeacherSchedulesState>(TeacherSchedulesController.new);
