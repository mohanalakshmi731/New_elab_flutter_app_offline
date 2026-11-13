import '../../core/network/api_client.dart';
import 'js_compat.dart';

/// Port of src/service/exams.service.ts.
class ExamsService {
  ExamsService(this._api);
  final ApiClient _api;

  Future<dynamic> createExam(Map<String, dynamic> payload) =>
      _api.post('/exam', data: payload);

  Future<dynamic> getExams(Object instituteId,
          [String? locale, Object? classId, Object? examBatchId]) =>
      _api.get('/exam', query: {
        'institute_id': instituteId,
        'class_id': classId,
        'exam_batch_id': examBatchId,
        'locale': locale,
      });

  Future<dynamic> startExam(Map<String, dynamic> payload) =>
      _api.post('/exam/start', data: payload);

  Future<dynamic> submitExamAnswer(Map<String, dynamic> payload) =>
      _api.post('/exam/submit/answer', data: payload);

  Future<dynamic> submitExamAttempt(Map<String, dynamic> payload) =>
      _api.post('/exam/submit', data: payload);

  Future<dynamic> examStatus(Map<String, dynamic> payload) =>
      _api.patch('/exam/status', data: payload);

  Future<dynamic> getExamById(Object examId, Object instituteId) =>
      _api.get('/exam/$examId', query: {'institute_id': instituteId});

  Future<dynamic> getExamAttempts(
          [Object? examId, Object? studentId, Object? instituteId]) =>
      _api.get('/exam/attempts', query: {
        'institute_id': instituteId,
        'exam_id': examId,
        if (jsTruthy(studentId)) 'student_id': studentId,
      });

  Future<dynamic> getAttemptById(Object attemptId, Object instituteId) =>
      _api.get('/exam/attempt/$attemptId', query: {'institute_id': instituteId});

  Future<dynamic> updateExam(Object examId, Map<String, dynamic> payload) =>
      _api.patch('/exam/$examId', data: payload);

  Future<dynamic> deleteExam(Object examId, Object instituteId) =>
      _api.delete('/exam/$examId', query: {'institute_id': instituteId});

  /// multipart/form-data. `payload['file']` is an [UploadFile].
  Future<dynamic> uploadExamFile(Map<String, dynamic> payload) =>
      _api.postMultipart('/exam/file', {
        'institute_id': payload['institute_id'],
        'file': payload['file'],
      });
}
