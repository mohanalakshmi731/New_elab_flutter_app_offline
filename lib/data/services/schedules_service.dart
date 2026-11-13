import 'package:dio/dio.dart' show Options;

import '../../core/network/api_client.dart';
import '../../core/network/upload_file.dart';
import 'js_compat.dart';

/// Port of src/service/schedules.service.ts.
class SchedulesService {
  SchedulesService(this._api);
  final ApiClient _api;

  Future<dynamic> create(Map<String, dynamic> payload) =>
      _api.post('/schedule', data: payload);

  Future<dynamic> get(Map<String, dynamic> params) =>
      _api.get('/schedule', query: params);

  Future<dynamic> getById(Object id, Object instituteId) =>
      _api.get('/schedule/$id', query: {'institute_id': instituteId});

  Future<dynamic> update(Object id, Map<String, dynamic> payload) =>
      _api.put('/schedule/$id', data: payload);

  Future<dynamic> getNext(Object instituteId) =>
      _api.get('/schedule/next', query: {'institute_id': instituteId});

  Future<dynamic> start(Object instituteId, Object scheduleId, String email) =>
      _api.post('/schedule/start', data: {
        'institute_id': instituteId,
        'schedule_id': scheduleId,
        'email': email,
      });

  /// multipart/form-data. `payload['file']` is an [UploadFile].
  Future<dynamic> createActivity(Map<String, dynamic> payload) =>
      _api.postMultipart('/schedule/activity', {
        'institute_id': payload['institute_id'],
        'schedule_id': payload['schedule_id'],
        'activity_type': payload['activity_type'],
        'name': payload['name'],
        'type': payload['type'],
        if (jsTruthy(payload['html_content']))
          'html_content': payload['html_content'],
        if (jsTruthy(payload['url'])) 'url': payload['url'],
        if (payload['file'] != null) 'file': payload['file'],
        if (jsTruthy(payload['content_id'])) 'content_id': payload['content_id'],
      });

  // ignore: non_constant_identifier_names
  Future<dynamic> ScheduleMessages(
          Object instituteId, Object scheduleId, String message) =>
      _api.post('/schedule/message', data: {
        'institute_id': instituteId,
        'schedule_id': scheduleId,
        'message': message,
      });

  Future<dynamic> getScheduleMessages(Object scheduleId, Object instituteId) =>
      _api.get('/schedule/message',
          query: {'schedule_id': scheduleId, 'institute_id': instituteId});

  Future<dynamic> scheduleAttendance(Object instituteId, Object scheduleId) =>
      _api.get('/schedule/attendance',
          query: {'institute_id': instituteId, 'schedule_id': scheduleId});

  Future<dynamic> fetchscheduleStudents(Object instituteId, Object scheduleId) =>
      _api.post('/schedule/students',
          data: {'institute_id': instituteId, 'schedule_id': scheduleId});

  Future<dynamic> markAttendance(Map<String, dynamic> payload) =>
      _api.post('/schedule/attendance', data: payload);

  /// multipart/form-data. `payload['file']` is an [UploadFile].
  Future<dynamic> referenceActivity(Map<String, dynamic> payload) =>
      _api.postMultipart('/schedule/reference', {
        'institute_id': payload['institute_id'],
        'schedule_id': payload['schedule_id'],
        'name': payload['name'],
        'type': payload['type'],
        if (jsTruthy(payload['content_id'])) 'content_id': payload['content_id'],
        if (jsTruthy(payload['html_content']))
          'html_content': payload['html_content'],
        if (jsTruthy(payload['url'])) 'url': payload['url'],
        if (payload['file'] != null) 'file': payload['file'],
      });

  /// Real HTTP PUT with a multipart body (no `_method` spoofing), exactly as
  /// the web did. Every key of [payload] is appended (JS `String()` coercion,
  /// null values skipped).
  Future<dynamic> updateActivity(Object id, Map<String, dynamic> payload) async =>
      _api.put('/schedule/activity/$id',
          data: await buildFormData(jsFormFields(payload)),
          options: Options(contentType: 'multipart/form-data'));

  /// Real HTTP PUT with a multipart body (no `_method` spoofing), exactly as
  /// the web did. Every key of [payload] is appended (JS `String()` coercion,
  /// null values skipped).
  Future<dynamic> updateReference(Object id, Map<String, dynamic> payload) async =>
      _api.put('/schedule/reference/$id',
          data: await buildFormData(jsFormFields(payload)),
          options: Options(contentType: 'multipart/form-data'));

  Future<dynamic> createExam(Map<String, dynamic> payload) =>
      _api.post('/schedule/exam', data: payload);

  Future<dynamic> updateScheduleExam(
          Object scheduleId, Map<String, dynamic> payload) =>
      _api.put('/schedule/exam/$scheduleId', data: payload);

  Future<dynamic> deleteReference(Object id, Object instituteId) =>
      _api.delete('/schedule/reference/$id',
          query: {'institute_id': instituteId});

  Future<dynamic> deleteActivity(Object id, Object instituteId) =>
      _api.delete('/schedule/activity/$id', query: {'institute_id': instituteId});

  Future<dynamic> deleteSchedule(Object id, Object instituteId) =>
      _api.delete('/schedule/$id', query: {'institute_id': instituteId});
}
