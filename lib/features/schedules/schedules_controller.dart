import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';
import 'schedules_logic.dart';

/// The schedules slice of `useUserStore` mapped by `schedules.vue`
/// (`institutes`, `batches`, `instructors`, `schedules`, `ongoingschedules`,
/// `getbyidschedules`, `scheduleStudents`, `attendanceRecords`, `sections`,
/// `chapters`, `contents`, `zoomMeetingData`, `meetingLink`,
/// `activeScheduleIdss`).
///
/// `classDetails` / `userInfo` / `batchDetails` live in [sessionProvider]
/// (`fetchschedulesClassDetails` writes the whole class response there, like
/// the web). Fields other screens read go through [lmsHandoffProvider]:
/// `institutes`, `classCoursesDropdown`, `sections`, `activeScheduleIdss`,
/// `zoomMeetingData`.
class SchedulesState {
  const SchedulesState({
    this.institutes = const [],
    this.batches = const [],
    this.instructors = const [],
    this.schedules = const [],
    this.ongoingschedules = const [],
    this.getbyidschedules = const [],
    this.scheduleStudents,
    this.attendanceRecords,
    this.sections = const [],
    this.chapters = const [],
    this.contents = const [],
    this.zoomMeetingData,
    this.meetingLink = '',
    this.activeScheduleIdss,
  });

  /// Classes as `{ id, year, c_id, students, batches, … }`.
  final List<SJson> institutes;
  final List<SJson> batches;
  final List<SJson> instructors;
  final List<dynamic> schedules;
  final List<dynamic> ongoingschedules;
  final List<dynamic> getbyidschedules;

  /// `res?.data || res` of `/schedule/students` (normally a list).
  final dynamic scheduleStudents;
  final dynamic attendanceRecords;
  final List<SJson> sections;
  final List<SJson> chapters;
  final List<SJson> contents;
  final dynamic zoomMeetingData;
  final String meetingLink;
  final num? activeScheduleIdss;

  static const _unset = Object();

  SchedulesState copyWith({
    List<SJson>? institutes,
    List<SJson>? batches,
    List<SJson>? instructors,
    List<dynamic>? schedules,
    List<dynamic>? ongoingschedules,
    List<dynamic>? getbyidschedules,
    Object? scheduleStudents = _unset,
    Object? attendanceRecords = _unset,
    List<SJson>? sections,
    List<SJson>? chapters,
    List<SJson>? contents,
    Object? zoomMeetingData = _unset,
    String? meetingLink,
    Object? activeScheduleIdss = _unset,
  }) =>
      SchedulesState(
        institutes: institutes ?? this.institutes,
        batches: batches ?? this.batches,
        instructors: instructors ?? this.instructors,
        schedules: schedules ?? this.schedules,
        ongoingschedules: ongoingschedules ?? this.ongoingschedules,
        getbyidschedules: getbyidschedules ?? this.getbyidschedules,
        scheduleStudents: identical(scheduleStudents, _unset) ? this.scheduleStudents : scheduleStudents,
        attendanceRecords: identical(attendanceRecords, _unset) ? this.attendanceRecords : attendanceRecords,
        sections: sections ?? this.sections,
        chapters: chapters ?? this.chapters,
        contents: contents ?? this.contents,
        zoomMeetingData: identical(zoomMeetingData, _unset) ? this.zoomMeetingData : zoomMeetingData,
        meetingLink: meetingLink ?? this.meetingLink,
        activeScheduleIdss:
            identical(activeScheduleIdss, _unset) ? this.activeScheduleIdss : activeScheduleIdss as num?,
      );
}

/// Store actions mapped by `schedules.vue`, ported 1:1.
class SchedulesController extends Notifier<SchedulesState> {
  @override
  SchedulesState build() => const SchedulesState();

  int _batchRequestId = 0;

  SessionState get _session => ref.read(sessionProvider);
  UserInfo? get _userInfo => _session.userInfo;
  int? get _instituteId => _userInfo?.instituteId;
  LmsHandoff get _handoff => ref.read(lmsHandoffProvider.notifier);
  SchedulesService get _api => ref.read(schedulesServiceProvider);

  /// `this.userInfo!.institute_id!.toString()` / the explicit
  /// `throw new Error('Institute ID not available')` guards.
  String get _instituteIdOrThrow {
    final id = _instituteId;
    if (id == null) throw const ApiError('Institute ID not available');
    return '$id';
  }

  /// The store's `classCoursesDropdown` (hand-off key).
  List<SJson> get classCoursesDropdown => schMaps(ref.read(lmsHandoffProvider)['classCoursesDropdown']);

  // ── classes / batches / instructors ─────────────────────────────────────

  /// `getClasses(institute_id_or_filter?, filter?)` — every class with its
  /// counts, mapped to `{ id, year, c_id, students, … }`.
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
    final data = schMaps(await classService.getAllClasses(instituteId!));
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

  /// `getBatches(classId?)` — falls back to `classDetails.id`; stale responses
  /// (a newer request, or another institute) are dropped.
  Future<void> getBatches([Object? classId]) async {
    final requestId = ++_batchRequestId;
    state = state.copyWith(batches: const []);
    final cid = jsTruthy(classId) ? classId : _session.classDetails?.id;
    final iid = _instituteId;
    if (!jsTruthy(cid) || iid == null) return;
    final data = await ref.read(batchServiceProvider).getBatches(cid!, iid);
    if (requestId != _batchRequestId || iid != _instituteId) return;
    state = state.copyWith(batches: [
      for (final batch in schMaps(data))
        {
          'id': batch['id'],
          'exam_batch_id': batch['exam_batch_id'],
          'name': batch['name'],
          'created_at': batch['created_at'],
          'status': batch['status']?.toString().toLowerCase() ?? 'unknown',
          'pivot': () {
            for (final s in schMaps(batch['students'])) {
              if (dig(s, ['pivot', 'status']) == true) return s['pivot'];
            }
            return null;
          }(),
        },
    ]);
  }

  /// `getInstructorsdropdown(classId)` — every page of the class's
  /// instructors (`user` defaulted to empty fields). Errors are only logged.
  Future<void> getInstructorsdropdown(Object? classId) async {
    if (!jsTruthy(classId)) return;
    state = state.copyWith(instructors: const []);
    var currentPage = 1;
    var lastPage = 1;
    final all = <SJson>[];
    try {
      do {
        final res = asMap(await ref.read(instructorServiceProvider).getInstructors(classId!, currentPage));
        for (final inst in schMaps(res?['data'])) {
          all.add({
            ...inst,
            'user': inst['user'] ??
                {'first_name': '', 'last_name': '', 'email': '', 'phone': '', 'country_code': ''},
          });
        }
        lastPage = asInt(res?['last_page']) ?? 1;
        currentPage++;
      } while (currentPage <= lastPage);
      state = state.copyWith(instructors: all);
    } catch (e) {
      debugPrint('Error loading instructors: $e');
    }
  }

  /// `fetchschedulesClassDetails(classId)` — the class with its published
  /// courses; replaces the session's `classDetails`.
  Future<SJson?> fetchschedulesClassDetails(Object classId) async {
    final instituteId = _instituteIdOrThrow;
    final res = await ref.read(classServiceProvider).getClassDetails(schString(classId), {
      'institute_id': instituteId,
      'withCourses': 'yes',
    });
    final response = asMap(res) == null ? null : Map<String, dynamic>.from(asMap(res)!);
    if (response != null) {
      if (jsTruthy(response['courses'])) {
        response['courses'] = [
          for (final c in schMaps(response['courses']))
            if (c['status'] == 'published') c,
        ];
      }
      response['c_id'] = response['curricula_id'] ?? response['c_id'];
    }
    ref.read(sessionProvider.notifier).setClassDetails(response == null ? null : IdName.fromJson(response));
    return response;
  }

  /// `fetchCourseDetails(courseId)` — sections → chapters → contents; the
  /// flattened contents become `classCoursesDropdown` (the LMS pickers).
  Future<SJson?> fetchCourseDetails(Object? courseId) async {
    if (_userInfo?.instituteId == null) throw const ApiError('User institute ID not set');
    final res = await ref.read(courseServiceProvider).getCourseDetails(courseId ?? 'undefined', {
      'institute_id': '$_instituteId',
      'with': 'content',
      'with_curriculums': true,
      'with_instructors': true,
    });
    final response = asMap(res);
    if (response == null) return null;
    final sections = schMaps(response['sections']);
    final chapters = [for (final s in sections) ...schMaps(s['chapters'])];
    final contents = [for (final c in chapters) ...schMaps(c['contents'])];
    state = state.copyWith(sections: sections, chapters: chapters, contents: contents);
    _handoff.set('sections', sections);
    _handoff.set('classCoursesDropdown', [...contents]);
    return response;
  }

  // ── schedules ───────────────────────────────────────────────────────────

  /// `getNextSchedules()` — the ongoing / next schedules (`[]` on error).
  Future<List<dynamic>> getNextSchedules() async {
    final iid = _instituteId;
    if (iid == null) return const [];
    try {
      final res = await _api.getNext('$iid');
      final list = res is List ? res : [res];
      state = state.copyWith(ongoingschedules: list);
      return list;
    } catch (e) {
      debugPrint('Error fetching next schedules: $e');
      return const [];
    }
  }

  /// `getSchedules(filters)` — students always filter by their own batch.
  Future<void> getSchedules([SJson filters = const {}]) async {
    final iid = _instituteId;
    if (iid == null) return;
    var batchIdToSend = filters['batch_id'];
    if (_session.role == Role.student) {
      batchIdToSend = _session.batchDetails?.id?.toString() ?? filters['batch_id'];
    }
    final params = {'institute_id': '$iid', ...filters, 'batch_id': batchIdToSend};
    final res = await _api.get(params);
    state = state.copyWith(
      schedules: res is List ? res : (jsTruthy(asMap(res)?['data']) ? asList(asMap(res)!['data']) : const []),
    );
  }

  /// `getScheduleById(id)` — also loads the schedule's course details.
  Future<dynamic> getScheduleById(Object? scheduleId) async {
    final instituteId = _instituteId?.toString() ?? '';
    final schedule = await _api.getById(schString(scheduleId), instituteId);
    final id = asMap(schedule)?['id'];
    final list = [...state.getbyidschedules];
    final index = list.indexWhere((s) => asMap(s)?['id'] == id);
    if (index != -1) {
      list[index] = schedule;
    } else {
      list.add(schedule);
    }
    state = state.copyWith(getbyidschedules: list);

    final courseId = dig(schedule, ['course', 'id']);
    if (jsTruthy(courseId)) {
      try {
        await fetchCourseDetails(schNumber(courseId));
      } catch (e) {
        debugPrint('Failed to fetch course details for course $courseId: $e');
      }
    }
    return schedule;
  }

  /// `createSchedule({ batches, slots })`
  Future<dynamic> createSchedule(SJson payload) async {
    final instituteId = _instituteIdOrThrow;
    return _api.create({
      'institute_id': instituteId,
      'batches': payload['batches'],
      'slots': payload['slots'],
    });
  }

  /// `updateSchedule(id, payload)` — the response replaces (or is appended to)
  /// `getbyidschedules` and `schedules`.
  Future<dynamic> updateSchedule(Object id, SJson payload) async {
    final res = await _api.update(id, {'institute_id': _instituteIdOrThrow, ...payload});
    final resId = asMap(res)?['id'];
    List<dynamic> put(List<dynamic> src) {
      final list = [...src];
      final i = list.indexWhere((s) => asMap(s)?['id'] == resId);
      if (i >= 0) {
        list[i] = res;
      } else {
        list.add(res);
      }
      return list;
    }

    state = state.copyWith(getbyidschedules: put(state.getbyidschedules), schedules: put(state.schedules));
    return res;
  }

  /// `deleteSchedule(id)`
  Future<dynamic> deleteSchedule(String scheduleId) async {
    final res = await _api.deleteSchedule(scheduleId, _instituteIdOrThrow);
    bool keep(dynamic s) => schString(asMap(s)?['id']) != scheduleId;
    state = state.copyWith(
      schedules: state.schedules.where(keep).toList(),
      getbyidschedules: state.getbyidschedules.where(keep).toList(),
    );
    return res;
  }

  /// `startSchedule(id)` — `res.data` is the meeting (`meeting_number`,
  /// `signature`, `passcode`, `user_name`, `zak`, `meeting_link`).
  Future<dynamic> startSchedule(String scheduleId) async {
    final instituteId = _instituteIdOrThrow;
    final res = await _api.start(instituteId, scheduleId, _userInfo?.email ?? '');
    final link = dig(res, ['data', 'meeting_link']);
    if (jsTruthy(link)) state = state.copyWith(meetingLink: '$link');
    return res;
  }

  /// `setZoomMeetingData(data)` (read by the web's `/zoom-full` page).
  void setZoomMeetingData(dynamic data) {
    state = state.copyWith(zoomMeetingData: data);
    _handoff.set('zoomMeetingData', data);
  }

  /// `setActiveSchedule(id)` (read by `scheduleexam` as `activeScheduleId`).
  void setActiveSchedule(num? scheduleId) {
    state = state.copyWith(activeScheduleIdss: scheduleId);
    _handoff.set('activeScheduleIdss', scheduleId);
  }

  // ── attendance / students / chat ────────────────────────────────────────

  /// `scheduleAttendance(id)`
  Future<dynamic> scheduleAttendance(String scheduleId) async {
    final res = await _api.scheduleAttendance(_instituteIdOrThrow, scheduleId);
    final data = asMap(res)?['data'];
    state = state.copyWith(attendanceRecords: jsTruthy(data) ? data : res);
    return res;
  }

  /// `fetchscheduleStudents(id)`
  Future<dynamic> fetchscheduleStudents(String scheduleId) async {
    final res = await _api.fetchscheduleStudents(_instituteIdOrThrow, scheduleId);
    final data = asMap(res)?['data'];
    state = state.copyWith(scheduleStudents: jsTruthy(data) ? data : res);
    return res;
  }

  /// `markScheduleAttendance(schedule_id, participant_uuid?, student_id?)`
  Future<dynamic> markScheduleAttendance(String scheduleId, [String? participantUuid, String? studentId]) async {
    final instituteId = _instituteIdOrThrow;
    if (scheduleId.isEmpty) throw const ApiError('Schedule ID is required');
    final finalStudentId = jsTruthy(studentId) ? studentId : _userInfo?.studentId?.toString();
    final payload = <String, dynamic>{
      'institute_id': instituteId,
      'schedule_id': scheduleId,
      if (jsTruthy(participantUuid)) 'participant_uuid': participantUuid,
      if (jsTruthy(finalStudentId)) 'student_id': finalStudentId,
    };
    final res = await _api.markAttendance(payload);
    final attendanceData = asMap(res)?['data'] ?? res;
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

  /// `ScheduleMessages(scheduleId, message)` — posts a chat message.
  // ignore: non_constant_identifier_names
  Future<dynamic> ScheduleMessages(String scheduleId, String message) =>
      _api.ScheduleMessages(_instituteIdOrThrow, scheduleId, message);

  /// `getScheduleMessages(scheduleId)` — `[]` without an institute or on error.
  Future<dynamic> getScheduleMessages(String scheduleId) async {
    final iid = _instituteId;
    if (iid == null) return const [];
    try {
      return await _api.getScheduleMessages(scheduleId, '$iid');
    } catch (e) {
      debugPrint('Error fetching messages: $e');
      return const [];
    }
  }

  // ── references / activities ─────────────────────────────────────────────

  /// `createScheduleActivity(payload)` (multipart; `file` only when set).
  Future<dynamic> createScheduleActivity(SJson payload) async {
    final body = {...payload, 'institute_id': _instituteIdOrThrow};
    if (payload['file'] == null) body.remove('file');
    return _api.createActivity(body);
  }

  /// `createScheduleReferenceActivity(payload)` (multipart).
  Future<dynamic> createScheduleReferenceActivity(SJson payload) async {
    final body = <String, dynamic>{
      'institute_id': _instituteIdOrThrow,
      'schedule_id': payload['schedule_id'],
      'name': payload['name'],
      'type': payload['type'],
      if (jsTruthy(payload['content_id'])) 'content_id': payload['content_id'],
      if (jsTruthy(payload['html_content'])) 'html_content': payload['html_content'],
      if (jsTruthy(payload['url'])) 'url': payload['url'],
      if (payload['file'] != null) 'file': payload['file'],
    };
    return _api.referenceActivity(body);
  }

  /// `updateScheduleActivity(activityId, payload)` (multipart `PUT`, empty
  /// fields dropped by `cleanPayload`).
  Future<dynamic> updateScheduleActivity(Object activityId, SJson payload) async {
    final body = cleanPayload({
      'institute_id': _instituteIdOrThrow,
      'schedule_id': schString(payload['schedule_id']),
      'activity_type': payload['activity_type'],
      'name': payload['name'],
      'type': payload['type'],
      'html_content': payload['html_content'],
      'url': payload['url'],
      'file': payload['file'],
      'content_id': payload['content_id']?.toString(),
    });
    return _api.updateActivity(schString(activityId), body);
  }

  /// `updateScheduleReference(id, payload)` (multipart `PUT`).
  Future<dynamic> updateScheduleReference(String id, SJson payload) async {
    final body = cleanPayload({
      'institute_id': _instituteIdOrThrow,
      'schedule_id': payload['schedule_id'],
      'name': payload['name'],
      'type': payload['type'],
      'html_content': payload['html_content'],
      'url': payload['url'],
      'file': payload['file'],
      'content_id': payload['content_id'],
    });
    return _api.updateReference(id, body);
  }

  /// `deleteclassScheduleReference(id)`
  Future<dynamic> deleteclassScheduleReference(String id) =>
      ref.read(schedulesServiceProvider).deleteReference(id, _instituteIdOrThrow);

  /// `deleteclassScheduleActivity(id)`
  Future<dynamic> deleteclassScheduleActivity(String id) =>
      ref.read(schedulesServiceProvider).deleteActivity(id, _instituteIdOrThrow);
}

final schedulesControllerProvider =
    NotifierProvider<SchedulesController, SchedulesState>(SchedulesController.new);
