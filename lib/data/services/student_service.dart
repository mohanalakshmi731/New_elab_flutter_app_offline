import '../../core/network/api_client.dart';
import '../../core/network/upload_file.dart';
import '../../core/utils/json.dart';
import '../models/session.dart';
import 'js_compat.dart';

/// Port of src/service/student.service.ts.
///
/// The web read `useUserStore()` (instituteId / batchId) inside the service;
/// [_session] returns the current session for the same purpose.
class StudentService {
  StudentService(this._api, this._session);
  final ApiClient _api;
  final SessionState Function() _session;

  /// JSON `POST /user`, or multipart when [photo] is given.
  Future<dynamic> createUsers(String firstName, String lastName, String email,
      String password, String confirmPassword,
      [Object? countryCode,
      String? phone,
      String? gender,
      String? dob,
      UploadFile? photo]) {
    final payload = <String, dynamic>{
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'password': password,
      'password_confirmation': confirmPassword,
      'institute_id': _session().instituteId,
    };

    if (jsTruthy(countryCode)) payload['country_code'] = '$countryCode';
    if (jsTruthy(phone)) payload['phone'] = phone;
    if (jsTruthy(gender)) payload['gender'] = gender;
    if (jsTruthy(dob)) payload['dob'] = dob;
    if (photo != null) {
      // null / undefined entries were skipped by the web as well.
      return _api.postMultipart('/user', {...payload, 'photo': photo});
    }
    return _api.post('/user', data: payload);
  }

  Future<dynamic> createStudent(Object userId) {
    final session = _session();
    return _api.post('/student', data: {
      'institute_id': session.instituteId,
      'user_id': userId,
      'batch_id': session.batchId,
    });
  }

  /// Web path was `batch/student` (axios joins it to the base URL with a `/`).
  Future<dynamic> attachStudent(Object studentId) {
    final session = _session();
    return _api.post('/batch/student', data: {
      'institute_id': session.instituteId,
      'student_id': studentId,
      'batch_id': session.batchId,
    });
  }

  /// Returns `{ ...res.data, batchName: undefined }` like the web. Spreading a
  /// bare list in JS gives index keys ("0", "1", …); ActivityReports reads the
  /// rows back from those.
  Future<dynamic> getStudents(Map<String, dynamic> params) async {
    final body = await _api.get('/student', query: params);
    return <String, dynamic>{
      ...?asMap(body),
      if (body is List)
        for (var i = 0; i < body.length; i++) '$i': body[i],
      'batchName': null,
    };
  }

  Future<dynamic> getStudentById(Object studentId) =>
      _api.get('/student/$studentId',
          query: {'institute_id': _session().instituteId});

  Future<dynamic> getQuizSysCards(Map<String, dynamic> payload) =>
      _api.post('/student/quizsys-cards', data: payload);

  Future<dynamic> setupQuizSysQuizSession(Map<String, dynamic> payload) =>
      _api.post('/student/quizsys-quiz-session', data: payload);

  /// Throws [ApiError] when [studentId] is falsy. `institute_id` always comes
  /// from the session (overriding any value in [payload]).
  Future<dynamic> updateStudent(
      Object? studentId, Map<String, dynamic> payload) async {
    if (!jsTruthy(studentId)) throw const ApiError('Student ID is required');

    final id = _session().instituteId;
    final instituteId = jsTruthy(id) ? '$id' : '';

    final finalPayload = {...payload, 'institute_id': instituteId};
    return _api.put('/student/$studentId', data: finalPayload);
  }

  Future<dynamic> searchStudents(
          Object instituteId, String term, Object? batchId) =>
      _api.get('/search/student', query: {
        'institute_id': instituteId,
        'term': term,
        'batch_id': batchId,
        'paginate': 0,
      });

  /// Web returned the full AxiosResponse (callers used res.data); this returns the body.
  Future<dynamic> importStudents(
          Object instituteId, Object batchId, UploadFile file) =>
      _api.postMultipart('/student/import', {
        'institute_id': '$instituteId',
        'batch_id': '$batchId',
        'file': file,
      });

  Future<dynamic> promoteStudents(Object instituteId, Object fromBatchId,
          Object toBatchId, List<dynamic> studentIds) =>
      _api.post('/student/promote', data: {
        'institute_id': '$instituteId',
        'from_batch_id': '$fromBatchId',
        'to_batch_id': '$toBatchId',
        'student_ids': studentIds.map((id) => '$id').toList(),
      });

  Future<dynamic> transferStudents(Object instituteId, Object fromBatchId,
          Object toBatchId, List<dynamic> studentIds) =>
      _api.post('/student/transfer', data: {
        'institute_id': '$instituteId',
        'from_batch_id': '$fromBatchId',
        'to_batch_id': '$toBatchId',
        'student_ids': studentIds.map((id) => '$id').toList(),
      });
}
