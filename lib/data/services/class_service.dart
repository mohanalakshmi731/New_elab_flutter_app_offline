import '../../core/network/api_client.dart';
import 'js_compat.dart';

/// Port of src/service/class.service.ts.
class ClassService {
  ClassService(this._api);
  final ApiClient _api;

  /// Note: the web sends `curriculum_id` as `curricula_id`.
  Future<dynamic> createClass(Map<String, dynamic> payload) =>
      _api.post('/class', data: {
        'institute_id': payload['institute_id'],
        'name': payload['name'],
        'status': payload['status'],
        'curricula_id': payload['curriculum_id'],
        // The web sends `class_level` too (omitted only when undefined).
        if (payload.containsKey('class_level')) 'class_level': payload['class_level'],
      });

  Future<dynamic> getAllClasses(Object instituteId) =>
      _api.get('/class', query: {'institute_id': instituteId});

  Future<dynamic> searchClassWithInstructor(Map<String, dynamic> params) =>
      _api.get('/search/class', query: {
        'institute_id': params['institute_id'],
        'term': params['term'],
        'instructor_id': jsTruthy(params['instructor_id'])
            ? params['instructor_id']
            : null,
      });

  Future<dynamic> createCurriculum(Map<String, dynamic> payload) =>
      _api.post('/curriculum', data: {
        'institute_id': payload['institute_id'],
        'name': payload['name'],
      });

  Future<dynamic> getAllCurriculums(Object instituteId) =>
      _api.get('/curriculum', query: {'institute_id': instituteId});

  Future<dynamic> getAllCurriculumById(Object curriculumId, Object instituteId) =>
      _api.get('/curriculum/$curriculumId',
          query: {'institute_id': instituteId});

  Future<dynamic> updateCurriculum(
          Object curriculumId, Map<String, dynamic> payload) =>
      _api.put('/curriculum/$curriculumId', data: {
        'institute_id': payload['institute_id'],
        'name': payload['name'],
        'status': payload['status'],
      });

  Future<dynamic> updateCurriculumStatus(
          Object curriculumId, Map<String, dynamic> payload) =>
      _api.put('/curriculum/$curriculumId/status', data: {
        'institute_id': payload['institute_id'],
        'value': payload['value'],
      });

  Future<dynamic> searchCurriculum(Object instituteId, String term) =>
      _api.get('/search/curriculum',
          query: {'institute_id': instituteId, 'term': term});

  Future<dynamic> getClassesCount(Object instituteId, Object classId) =>
      _api.post('/class/counts',
          data: {'institute_id': instituteId, 'class_id': classId});

  Future<dynamic> getClassDetails(Object id, Map<String, dynamic> data) =>
      _api.get('/class/$id', query: {
        'institute_id': data['institute_id'],
        'withCourses': data['withCourses'],
      });

  Future<dynamic> getClassCourses(Object instituteId, [Object? curriculumId]) =>
      _api.get('/course', query: {
        'institute_id': instituteId,
        'curriculum_id': curriculumId,
      });

  Future<dynamic> attachSelectedCourseToClass(Map<String, dynamic> data) =>
      _api.post('/class/course', data: data);

  Future<dynamic> updateClass(Object id, Map<String, dynamic> data) =>
      _api.put('/class/$id', data: data);

  Future<dynamic> updateClassStatus(Object id, Map<String, dynamic> data) =>
      _api.put('/class/$id/status', data: data);

  Future<dynamic> attachInstructorToClass(Map<String, dynamic> payload) =>
      _api.post('/class/instructor', data: payload);

  Future<dynamic> deleteInstructorfromClass(Map<String, dynamic> payload) =>
      _api.delete('/class/instructor', data: payload);

  /// Note: the web posts (not deletes) to `/class/student`.
  Future<dynamic> detachStudentFromClass(Map<String, dynamic> payload) =>
      _api.post('/class/student', data: payload);

  Future<dynamic> detachInstructorFromClass(Map<String, dynamic> payload) =>
      _api.delete('/class/instructor', data: payload);
}
