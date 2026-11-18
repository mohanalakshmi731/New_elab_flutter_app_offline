import '../../core/network/api_client.dart';
import '../../core/network/upload_file.dart';
import '../models/session.dart';
import 'js_compat.dart';

/// Port of src/service/instructor.service.ts.
///
/// The web read `useUserStore()` (instituteId / classId) inside the service;
/// [_session] returns the current session for the same purpose.
class InstructorService {
  InstructorService(this._api, this._session);
  final ApiClient _api;
  final SessionState Function() _session;

  /// multipart `POST /user` (always multipart, unlike StudentService).
  Future<dynamic> createUser(
    String firstName,
    String lastName,
    String email, [
    Object? countryCode,
    String? phone,
    String? gender,
    String? dob,
    UploadFile? photo,
    String? password,
    String? designation,
    bool enableZoom = false,
  ]) {
    final hasPassword = password != null && password.trim().isNotEmpty;
    return _api.postMultipart('/user', {
      'enable_zoom': enableZoom ? '1' : '0',
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'institute_id': '${_session().instituteId}',
      if (hasPassword) 'password': password,
      if (hasPassword) 'password_confirmation': password,
      if (jsTruthy(countryCode)) 'country_code': '$countryCode',
      if (jsTruthy(phone)) 'phone': phone,
      if (jsTruthy(gender)) 'gender': gender,
      if (jsTruthy(dob)) 'dob': dob,
      if (jsTruthy(designation)) 'designation': designation,
      'photo': ?photo,
    });
  }

  Future<dynamic> createInstructor(
    Object userId, [
    String? joiningDate,
    String? designation,
    bool enableZoom = false,
    bool isLabAdmin = false,
  ]) {
    final session = _session();
    final payload = <String, dynamic>{
      'institute_id': session.instituteId,
      'user_id': userId,
      'enable_zoom': enableZoom,
      'is_labadmin': isLabAdmin,
    };

    if (jsTruthy(session.classId)) payload['class_id'] = session.classId;
    if (jsTruthy(joiningDate)) payload['joining_date'] = joiningDate;
    if (jsTruthy(designation)) payload['designation'] = designation;

    return _api.post('/instructor', data: payload);
  }

  Future<dynamic> getInstructors(Object classId, int page) => _api.get(
    '/instructor',
    query: {
      'class_id': classId,
      'institute_id': _session().instituteId,
      'page': page,
    },
  );

  Future<dynamic> getallInstructors(int page) => _api.get(
    '/instructor',
    query: {'institute_id': _session().instituteId, 'page': page},
  );

  Future<dynamic> assignInstructorToAdmin(Map<String, dynamic> payload) =>
      _api.post('/class/admin', data: payload);

  Future<dynamic> getAssignedInstructors(
    Object instituteId,
    Object classId, [
    int page = 1,
  ]) => _api.get(
    '/class/admin',
    query: {'institute_id': instituteId, 'class_id': classId, 'page': page},
  );

  Future<dynamic> getInstructorById(Object instructorId) => _api.get(
    '/instructor/$instructorId',
    query: {'institute_id': _session().instituteId},
  );

  Future<dynamic> updateInstructor(
    Object instructorId,
    Map<String, dynamic> payload,
  ) => _api.put(
    '/instructor/$instructorId',
    data: payload,
    query: {'institute_id': _session().instituteId},
  );

  Future<dynamic> deleteClassAdmin(
    Object id,
    Object instituteId,
    Object classId,
  ) => _api.delete(
    '/class/admin/$id',
    data: {'institute_id': instituteId, 'class_id': classId},
  );

  Future<dynamic> searchInstructors(
    Object instituteId,
    String term, [
    Object? classId,
  ]) => _api.get(
    '/search/instructor',
    query: {
      'institute_id': instituteId,
      'term': term,
      if (jsTruthy(classId)) 'class_id': classId,
    },
  );

  /// Web returned the full AxiosResponse (callers used res.data); this returns the body.
  Future<dynamic> importBulkInstructors(
    Object instituteId,
    Object classId,
    UploadFile file,
  ) => _api.postMultipart('/instructor/import', {
    'institute_id': instituteId,
    'class_id': classId,
    'file': file,
  });
}
