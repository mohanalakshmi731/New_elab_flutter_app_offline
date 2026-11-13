import 'dart:typed_data';

import '../../core/network/api_client.dart';
import 'js_compat.dart';

/// Port of src/service/institute.service.ts (TS class `PlanService`).
class InstituteService {
  InstituteService(this._api);
  final ApiClient _api;

  /// Web path was `institute/plan` (axios joins it to the base URL with a `/`).
  Future<dynamic> createPlan(Map<String, dynamic> payload) =>
      _api.post('/institute/plan', data: payload);

  Future<dynamic> getPlans() => _api.get('/institute/plan');

  Future<dynamic> getPlanById(Object planId) =>
      _api.get('/institute/plan/$planId');

  Future<dynamic> updatePlan(Object planId, Map<String, dynamic> payload) =>
      _api.put('/institute/plan/$planId', data: payload);

  Future<dynamic> deletePlan(Object planId) =>
      _api.delete('/institute/plan/$planId');

  Future<dynamic> deleteInstitute(Object id) => _api.delete('/institute/$id');

  /// The web accepted either a `FormData` (file upload) or a plain object.
  ///
  /// * `asFormData: true` → multipart; pass the same keys the caller appended
  ///   to FormData (files as `UploadFile`).
  /// * otherwise → JSON body built from [data] exactly like the web
  ///   (`allclass` is sent as `classes`, `country_code` stringified).
  Future<dynamic> createInstitute(Map<String, dynamic> data,
      {bool asFormData = false}) {
    if (asFormData) {
      return _api.postMultipart('/institute', data);
    }
    final payload = {
      'user_id': data['user_id'],
      'plan_id': data['plan_id'],
      'state_id': data['state_id'],
      'name': data['name'],
      'type': data['type'],
      'client_code': data['client_code'],
      'syllabus': data['syllabus'],
      'address': data['address'],
      'country_code': '${data['country_code']}',
      'phone': data['phone'],
      'email': data['email'],
      'classes': jsTruthy(data['allclass']) ? data['allclass'] : <dynamic>[],
    };
    return _api.post('/institute', data: payload);
  }

  /// `responseType: 'blob'` → raw bytes.
  ///
  /// Web returned the full AxiosResponse (callers used res.data); this returns the body.
  Future<Uint8List> downloadBulkTemplate() =>
      _api.getBytes('/invitation/invitations/template', silent: false);

  /// The web accepted a ready-made `FormData`; pass the same keys the caller
  /// appended (files as `UploadFile`).
  Future<dynamic> sendBulkInvitation(Map<String, dynamic> fields) =>
      _api.postMultipart('/invitation/invitations/bulk-upload', fields);

  Future<dynamic> searchInstitute(String term) =>
      _api.get('/search/institute', query: {'term': term});

  /// Web returned the full AxiosResponse (callers used res.data); this returns the body.
  Future<dynamic> createInvitationByCode(Map<String, dynamic> payload) =>
      _api.post('/invitation/invitations', data: payload);

  Future<dynamic> sendInvitation(Map<String, dynamic> payload) =>
      _api.post('/invitation/institute', data: payload);

  Future<dynamic> fetchCountries() => _api.get('/countries');

  /// Web returned the full AxiosResponse (callers used res.data); this returns the body.
  Future<dynamic> dialcode() => _api.get('/dialCode');

  Future<dynamic> fetchCountryById() => _api.get('/countries/phone-code');

  Future<dynamic> code(String code) => _api.get('/invitation/institute/$code');

  /// The web accepted a ready-made `FormData`; pass the same keys the caller
  /// appended (files as `UploadFile`).
  Future<dynamic> signupform(Map<String, dynamic> fields) =>
      _api.postMultipart('/signup/signup', fields);

  /// The web accepted a ready-made `FormData` (axios sent it as
  /// multipart); pass the same keys the caller appended.
  Future<dynamic> signup(Map<String, dynamic> fields) =>
      _api.postMultipart('/signup/institute', fields);

  /// `paginate` is always sent as the string `"true"` or `"false"`.
  Future<dynamic> getInstitutes(
          [int page = 1, int perPage = 10, bool? paginate]) =>
      _api.get('/institute', query: {
        'page': page,
        'per_page': perPage,
        'paginate': jsTruthy(paginate) ? 'true' : 'false',
      });

  Future<dynamic> getInstituteById(Object instituteId) =>
      _api.get('/institute/$instituteId',
          query: {'institute_id': instituteId});

  /// The web accepted a ready-made `FormData`; pass the same keys the caller
  /// appended (including any `_method` spoofing, files as `UploadFile`).
  Future<dynamic> updateInstitute(
          Object instituteId, Map<String, dynamic> fields) =>
      _api.postMultipart('/institute/$instituteId', fields);

  /// Returns `res.data.data` (the inner `data` of the body).
  Future<dynamic> zslClasses(Object syllabus) async {
    final dynamic body = await _api.get('/zsl-plans/syllabus/$syllabus');
    return body['data'];
  }

  Future<dynamic> getzslclass(bool paginate, [int page = 1]) =>
      _api.get('/zsl-plans/all', query: {
        'paginate': paginate ? 1 : 0,
        'page': page,
      });

  Future<dynamic> searchzslclass(String search) =>
      _api.get('/zsl-plans/search', query: {'search': search});

  Future<dynamic> getzslclassid(Object id) => _api.get('/zsl-plans/$id');

  /// Note the web argument order: payload first, then id.
  Future<dynamic> updatezslid(Map<String, dynamic> playload, Object id) =>
      _api.put('/zsl-plans/$id', data: playload);

  Future<dynamic> createClass(Map<String, dynamic> classData) =>
      _api.post('/zsl-plans', data: classData);

  Future<dynamic> getZslPlans(Object instituteId, Object zslClassId) =>
      _api.get('/zsl-plans', query: {
        'institute_id': instituteId,
        'zsl_class_id': zslClassId,
      });

  Future<dynamic> deleteZslPlan(Object id) => _api.delete('/zsl-plans/$id');
}
