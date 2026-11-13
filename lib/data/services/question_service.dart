import '../../core/network/api_client.dart';
import '../../core/network/upload_file.dart';
import 'js_compat.dart';

/// Port of src/service/question.service.ts.
class QuestionService {
  QuestionService(this._api);
  final ApiClient _api;

  /// Note: `default_locale` is sent as the `locale` query param.
  Future<dynamic> getExamQuestions(Map<String, dynamic> payload) =>
      _api.get('/exam/question', query: {
        'institute_id': payload['institute_id'],
        'exam_section_id': payload['exam_section_id'],
        'exam_chapter_id': payload['exam_chapter_id'],
        'current_user': payload['current_user'],
        'locale': payload['default_locale'],
      });

  Future<dynamic> updateExamQuestion(Object id, Map<String, dynamic> payload) =>
      _api.put('/exam/question/$id', data: payload);

  Future<dynamic> createExamQuestion(Map<String, dynamic> payload) =>
      _api.post('/exam/question', data: payload);

  Future<dynamic> deleteExamQuestion(Object id, Object instituteId) =>
      _api.delete('/exam/question/$id', query: {'institute_id': instituteId});

  static const _allowedTypes = [
    'text/csv',
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    'application/vnd.ms-excel',
  ];

  /// The web checked the browser `File.type` (MIME). [UploadFile] has no MIME
  /// type, so it is derived from the file extension the way browsers do.
  static String _mimeTypeOf(String fileName) {
    final dot = fileName.lastIndexOf('.');
    final ext = dot < 0 ? '' : fileName.substring(dot + 1).toLowerCase();
    return switch (ext) {
      'csv' => 'text/csv',
      'xlsx' =>
        'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
      'xls' => 'application/vnd.ms-excel',
      _ => '',
    };
  }

  /// Throws [ApiError] for anything that is not CSV / Excel.
  ///
  /// Web path was `exam/question/import` (axios joins it to the base URL
  /// with a `/`).
  Future<dynamic> importBulkQuestions(
      Object instituteId,
      Object examCourseId,
      Object examSectionId,
      Object examChapterId,
      UploadFile file,
      [String? defaultLocale]) async {
    if (!_allowedTypes.contains(_mimeTypeOf(file.name))) {
      throw const ApiError('Only CSV or Excel (.xlsx) files are allowed');
    }

    return _api.postMultipart('/exam/question/import', {
      'file': file,
      'institute_id': instituteId,
      'exam_course_id': examCourseId,
      'exam_section_id': examSectionId,
      'exam_chapter_id': examChapterId,
      if (jsTruthy(defaultLocale)) 'import_locale': defaultLocale,
    });
  }
}
