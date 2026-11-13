import '../../core/network/api_client.dart';
import 'js_compat.dart';

/// Port of src/service/course.service.ts.
class CourseService {
  CourseService(this._api);
  final ApiClient _api;

  /// multipart/form-data. `courseData['image']` is an [UploadFile].
  Future<dynamic> createCourse(Map<String, dynamic> courseData) =>
      _api.postMultipart('/course', {
        'institute_id': courseData['institute_id'],
        'curriculum_id': courseData['curriculum_id'],
        if (jsTruthy(courseData['instructor_id']))
          'instructor_id': courseData['instructor_id'],
        if (jsTruthy(courseData['class_id'])) 'class_id': courseData['class_id'],
        'title': courseData['title'],
        if (jsTruthy(courseData['description']))
          'description': courseData['description'],
        'short_name': courseData['short_name'],
        'course_code': courseData['course_code'],
        if (courseData['image'] != null) 'image': courseData['image'],
        'status': courseData['status'],
        'zsl_class_id': courseData['zsl_class_id'],
        'zsl_subject_id': courseData['zsl_subject_id'],
        'is_math_zoro': jsTruthy(courseData['is_math_zoro']) ? 'true' : 'false',
        'zone': jsTruthy(courseData['zone']) ? courseData['zone'] : '',
      });

  Future<dynamic> getCourses(Object instituteId, [Object? onlyAdmin]) =>
      _api.get('/course', query: {
        'institute_id': instituteId,
        'only_admin': onlyAdmin,
      });

  Future<dynamic> createSection(Map<String, dynamic> data) =>
      _api.post('/section', data: data);

  Future<dynamic> getSections(Object instituteId, Object courseId) =>
      _api.get('/section',
          query: {'institute_id': instituteId, 'course_id': courseId});

  Future<dynamic> createChapter(Map<String, dynamic> data) =>
      _api.post('/chapter', data: data);

  Future<dynamic> getChapters(Object instituteId, Object sectionId) =>
      _api.get('/chapter',
          query: {'institute_id': instituteId, 'section_id': sectionId});

  /// The web accepted a ready-made `FormData`; pass the same keys the caller
  /// appended (files as [UploadFile]).
  Future<dynamic> createContent(Map<String, dynamic> fields) =>
      _api.postMultipart('/content', fields);

  Future<dynamic> getContents(Object instituteId, Object chapterId) =>
      _api.get('/content',
          query: {'institute_id': instituteId, 'chapter_id': chapterId});

  // ignore: non_constant_identifier_names
  Future<dynamic> AddCurriculumtoCourse(Map<String, dynamic> data) =>
      _api.post('/course/curriculum', data: data);

  Future<dynamic> deleteCurriculum(Map<String, dynamic> data) =>
      _api.delete('/curriculum/${data['curriculum_id']}',
          query: {'institute_id': data['institute_id']});

  Future<dynamic> deleteCurriculumFromCourse(Map<String, dynamic> data) =>
      _api.delete('/course/curriculum', data: data);

  /// Note: the web always sends `with_curriculums=1&with_instructors=1`,
  /// ignoring the matching keys of [data].
  Future<dynamic> getCourseDetails(Object courseId, Map<String, dynamic> data) =>
      _api.get('/course/$courseId', query: {
        'institute_id': data['institute_id'],
        'with': data['with'],
        'with_curriculums': 1,
        'with_instructors': 1,
      });

  /// The web accepted a ready-made `FormData`; pass the same keys the caller
  /// appended (including any `_method` spoofing, files as [UploadFile]).
  Future<dynamic> updateCourse(Object courseId, Map<String, dynamic> fields) =>
      _api.postMultipart('/course/$courseId', fields);

  Future<dynamic> searchCourse(Object instituteId, String term) =>
      _api.get('/search/course',
          query: {'institute_id': instituteId, 'term': term});

  Future<dynamic> updateSection(Object sectionId, Map<String, dynamic> data) =>
      _api.put('/section/$sectionId', data: data);

  Future<dynamic> updateChapter(Object chapterId, Map<String, dynamic> data) =>
      _api.put('/chapter/$chapterId', data: data);

  /// The web accepted a ready-made `FormData`; pass the same keys the caller
  /// appended (including any `_method` spoofing, files as [UploadFile]).
  Future<dynamic> updateContent(Object contentId, Map<String, dynamic> fields) =>
      _api.postMultipart('/content/$contentId', fields);

  Future<dynamic> assignInstructorToCourse(Map<String, dynamic> data) =>
      _api.post('/course/instructor', data: data);

  Future<dynamic> deleteInstructorFromCourse(Map<String, dynamic> data) =>
      _api.delete('/course/instructor', data: data);

  Future<dynamic> deleteCourse(Map<String, dynamic> data) =>
      _api.delete('/course/${data['course_id']}',
          query: {'institute_id': data['institute_id']});

  Future<dynamic> deleteSection(Map<String, dynamic> data) =>
      _api.delete('/section/${data['section_id']}',
          query: {'institute_id': data['institute_id']});

  Future<dynamic> deleteChapter(Map<String, dynamic> data) =>
      _api.delete('/chapter/${data['chapter_id']}',
          query: {'institute_id': data['institute_id']});

  Future<dynamic> deleteContent(Map<String, dynamic> data) =>
      _api.delete('/content/${data['content_id']}',
          query: {'institute_id': data['institute_id']});
}
