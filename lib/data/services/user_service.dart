import '../../core/network/api_client.dart';
import '../../core/network/upload_file.dart';
import '../models/session.dart';
import 'js_compat.dart';

/// Port of src/service/user.service.ts.
///
/// The web read `useUserStore()` (userInfo.institute_id) inside the service;
/// [_session] returns the current session for the same purpose.
class UserService {
  UserService(this._api, this._session);
  final ApiClient _api;
  final SessionState Function() _session;

  /// JSON `POST /user`.
  ///
  /// The web put the browser `File` into a JSON body, which `JSON.stringify`
  /// serialises as `{}` - the file itself was never uploaded. The same empty
  /// object is sent here; use [createUser] for a real multipart upload.
  Future<dynamic> createUsers(
          String firstName,
          String lastName,
          String email,
          Object? countryCode,
          String phone,
          String gender,
          String dob,
          UploadFile? photo) =>
      _api.post('/user', data: {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'country_code': '$countryCode',
        'phone': phone,
        'gender': gender,
        'dob': dob,
        if (photo != null) 'photo': const <String, dynamic>{},
        'institute_id': _session().userInfo?.instituteId,
      });

  /// The web accepted a ready-made `FormData`; pass the same keys the caller
  /// appended (files as [UploadFile]).
  ///
  /// Web returned the full AxiosResponse (callers used res.data); this returns the body.
  Future<dynamic> createUser(Map<String, dynamic> fields) =>
      _api.postMultipart('/user', fields);

  Future<dynamic> getUsers([int page = 1, int perPage = 10]) =>
      _api.get('/user', query: {'page': page, 'per_page': perPage});

  /// Web path was `dialCode` (axios joins it to the base URL with a `/`).
  Future<dynamic> getDailCodes() => _api.get('/dialCode');

  Future<dynamic> getStates() => _api.get('/state');

  Future<dynamic> searchByUser(String term, [Object? instituteId]) =>
      _api.get('/search/user', query: {
        'term': term,
        if (jsTruthy(instituteId)) 'institute_id': instituteId,
      });

  Future<dynamic> searchUserByEmail(String email, [Object? instituteId]) =>
      _api.get('/search/user/email', query: {
        'email': email,
        if (jsTruthy(instituteId)) 'institute_id': instituteId,
      });

  Future<dynamic> searchUserByIns(String term, [Object? instituteId]) =>
      _api.get('/search/instructor', query: {
        'term': term,
        if (jsTruthy(instituteId)) 'institute_id': instituteId,
      });

  Future<dynamic> searchUserByStu(String term, [Object? instituteId]) =>
      _api.get('/search/student', query: {
        'term': term,
        if (jsTruthy(instituteId)) 'institute_id': instituteId,
      });

  Future<dynamic> getUserById(Object userId, Object instituteId) =>
      _api.get('/user/$userId', query: {'institute_id': instituteId});

  Future<dynamic> updateUser(Object userId, Map<String, dynamic> payload) =>
      _api.put('/user/$userId', data: payload);

  /// `paginate` is always sent as a string (`String(paginate)`).
  Future<dynamic> searchUser(String term, Object? paginate) =>
      _api.get('/search/user', query: {'term': term, 'paginate': '$paginate'});

  Future<dynamic> statusUser(String status, [int page = 1]) =>
      _api.get('/search/user', query: {'status': status, 'page': page});

  Future<dynamic> userdelete(Object id) => _api.delete('/user/$id');

  Future<dynamic> changePassword(
          Object userId, String oldPassword, String newPassword) =>
      _api.post('/auth/password/change', data: {
        'user_id': userId,
        'old_password': oldPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      });

  Future<dynamic> lockUser(Object userId) => _api.post('/user/$userId/lock');

  Future<dynamic> unlockUser(Object userId) => _api.post('/user/$userId/unlock');
}
