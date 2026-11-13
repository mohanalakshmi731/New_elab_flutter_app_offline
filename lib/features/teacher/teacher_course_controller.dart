import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/upload_file.dart';
import '../../core/utils/json.dart';
import '../../core/utils/pagination.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';
import '../courses/course_create_logic.dart';
import 'teacher_course_logic.dart';

/// The `useUserStore` slice `teachercoursepage.vue` maps: `curriculums`,
/// `instructors`, `institutes`, `courseForm`, `sections`, `chapters`,
/// `contents`, `courseDetails`.
///
/// `course_id` / `section_id` / `chapter_id` are shared with the course list
/// screens through `lmsHandoffProvider`; `classDetails` / `role` come from
/// the session.
class TeacherCourseState {
  const TeacherCourseState({
    this.curriculums = const [],
    this.instructors = const [],
    this.instructorPagination = PageMeta.empty,
    this.institutes = const [],
    this.courseForm = const {},
    this.sections = const [],
    this.chapters = const [],
    this.contents = const [],
    this.courseDetails,
  });

  final List<Map<String, dynamic>> curriculums;
  final List<Map<String, dynamic>> instructors;
  final PageMeta instructorPagination;

  /// `institutes` — the institute's classes from `getClasses()`:
  /// `{ id, year, c_id, students, batches, instructors, courses, admins,
  /// status, class_level, is_admin }`.
  final List<Map<String, dynamic>> institutes;
  final Map<String, dynamic> courseForm;
  final List<Map<String, dynamic>> sections;
  final List<Map<String, dynamic>> chapters;
  final List<Map<String, dynamic>> contents;
  final Map<String, dynamic>? courseDetails;

  static const _unset = Object();

  TeacherCourseState copyWith({
    List<Map<String, dynamic>>? curriculums,
    List<Map<String, dynamic>>? instructors,
    PageMeta? instructorPagination,
    List<Map<String, dynamic>>? institutes,
    Map<String, dynamic>? courseForm,
    List<Map<String, dynamic>>? sections,
    List<Map<String, dynamic>>? chapters,
    List<Map<String, dynamic>>? contents,
    Object? courseDetails = _unset,
  }) =>
      TeacherCourseState(
        curriculums: curriculums ?? this.curriculums,
        instructors: instructors ?? this.instructors,
        instructorPagination: instructorPagination ?? this.instructorPagination,
        institutes: institutes ?? this.institutes,
        courseForm: courseForm ?? this.courseForm,
        sections: sections ?? this.sections,
        chapters: chapters ?? this.chapters,
        contents: contents ?? this.contents,
        courseDetails:
            identical(courseDetails, _unset) ? this.courseDetails : courseDetails as Map<String, dynamic>?,
      );
}

/// Store actions used by `teachercoursepage.vue`, ported 1:1 from
/// `src/store/Userstore.ts`.
class TeacherCourseController extends Notifier<TeacherCourseState> {
  @override
  TeacherCourseState build() =>
      TeacherCourseState(courseForm: {...emptyCourseForm(), 'status': 'published'});

  SessionState get _session => ref.read(sessionProvider);
  LmsHandoff get _handoff => ref.read(lmsHandoffProvider.notifier);

  int? get _instituteId {
    final id = _session.userInfo?.instituteId;
    return id == null || id == 0 ? null : id;
  }

  /// `this.userInfo!.institute_id!.toString()` (throws when missing).
  String get _requiredInstituteId {
    final id = _instituteId;
    if (id == null) throw const ApiError('Institute ID not available');
    return '$id';
  }

  String? get _classId {
    final id = _session.classDetails?.id;
    return id == null || id == 0 ? null : '$id';
  }

  String? _handoffId(String key) {
    final v = _handoff.get(key);
    return jsTruthy(v) ? '$v' : null;
  }

  /// Store `course_id` (written by the course list screens and `createCourse`).
  String? get courseId => _handoffId('course_id');

  /// Store `section_id`.
  Object? get sectionId => _handoff.get('section_id');

  /// Store `chapter_id`.
  Object? get chapterId => _handoff.get('chapter_id');

  List<Map<String, dynamic>> _maps(dynamic list) => [for (final e in asList(list)) ?asMap(e)];

  // ── lookups ──────────────────────────────────────────────────────────────

  /// `fetchCurriculums()`
  Future<void> fetchCurriculums() async {
    final id = _instituteId;
    if (id == null) return;
    final data = await ref.read(classServiceProvider).getAllCurriculums(id);
    state = state.copyWith(curriculums: mapCurriculums(data));
  }

  /// `getAllInstructors(page?)`
  Future<void> getAllInstructors([int? page]) async {
    final currentPage = page ?? state.instructorPagination.currentPage;
    final res = await ref.read(instructorServiceProvider).getallInstructors(currentPage);
    state = state.copyWith(instructors: mapInstructors(res), instructorPagination: instructorPageMeta(res));
  }

  /// `getClasses()` — every class of the institute plus its counts.
  Future<void> getClasses() async {
    final instituteId = _instituteId;
    if (instituteId == null) return;
    final classService = ref.read(classServiceProvider);
    final data = await classService.getAllClasses(instituteId);
    final mapped = await Future.wait([
      for (final item in _maps(data))
        () async {
          final counts = asMap(await classService.getClassesCount(instituteId, item['id'] as Object));
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
        }(),
    ]);
    state = state.copyWith(institutes: mapped);
  }

  // ── class ────────────────────────────────────────────────────────────────

  /// `setClassDetails({ id, name, c_id })`
  void setClassDetails({required Object? id, required String name, Object? cId}) => ref
      .read(sessionProvider.notifier)
      .setClassDetails(IdName(asInt(id), name, extra: {'c_id': cId}));

  /// `fetchClassDetails(classId?)` — `GET /class/{id}?withCourses=yes`;
  /// returns `null` (and keeps the session untouched) when the selected class
  /// changed meanwhile.
  Future<Map<String, dynamic>?> fetchClassDetails([Object? classId]) async {
    final instituteId = _requiredInstituteId;
    final cid = jsTruthy(classId) ? '$classId' : _session.classDetails?.id?.toString();
    if (cid == null) throw const ApiError('Class ID not available');

    final response = await ref
        .read(classServiceProvider)
        .getClassDetails(cid, {'institute_id': instituteId, 'withCourses': 'yes'});
    if (cid != _session.classDetails?.id?.toString()) return null;

    final m = asMap(response);
    final details = m == null ? null : {...m, 'c_id': m['curricula_id'] ?? m['c_id']};
    ref.read(sessionProvider.notifier).setClassDetails(IdName.fromJson(details));
    return details;
  }

  // ── course ───────────────────────────────────────────────────────────────

  /// `resetCourseForm()`
  void resetCourseForm() => state = state.copyWith(courseForm: emptyCourseForm());

  /// `this.courseForm.x = …`
  void patchCourseForm(Map<String, dynamic> fields) =>
      state = state.copyWith(courseForm: {...state.courseForm, ...fields});

  /// `createCourse()` — see `CourseCreateController.createCourse`.
  Future<bool> createCourse([String? classId]) async {
    final instituteId = _instituteId?.toString() ?? '';
    final form = {...state.courseForm, 'institute_id': instituteId};
    state = state.copyWith(courseForm: form);
    final response = await ref
        .read(courseServiceProvider)
        .createCourse(buildCreateCourseData(form, instituteId: instituteId, classId: classId));
    final newId = dig(response, ['data', 'id']);
    if (jsTruthy(newId)) _handoff.set('course_id', asInt(newId) ?? newId);
    if (isCourseCreated(response)) {
      state = state.copyWith(courseForm: createdCourseForm());
      return true;
    }
    return false;
  }

  /// `fetchCourseDetails(courseId)` — also refreshes `sections`, the
  /// flattened `chapters` / `contents`, `courseForm` and `courseDetails`.
  Future<Map<String, dynamic>?> fetchCourseDetails(Object courseId) async {
    final instituteId = _instituteId;
    if (instituteId == null) throw const ApiError('User institute ID not set');
    final response = asMap(await ref.read(courseServiceProvider).getCourseDetails(courseId, {
      'institute_id': '$instituteId',
      'with': 'content',
      'with_curriculums': true,
      'with_instructors': true,
    }));
    if (response == null) return null;

    final sections = _maps(response['sections']);
    final chapters = [for (final s in sections) ..._maps(s['chapters'])];
    final contents = [for (final c in chapters) ..._maps(c['contents'])];
    final curriculums = asList(response['curriculums']);
    final status = response['status'];
    state = state.copyWith(
      sections: sections,
      chapters: chapters,
      contents: contents,
      courseDetails: response,
      courseForm: {
        ...state.courseForm,
        'title': response['title'],
        'description': jsTruthy(response['description']) ? response['description'] : '',
        'short_name': response['short_name'],
        'course_code': response['course_code'],
        'status': jsTruthy(status) ? '$status'.toLowerCase() : 'draft',
        'instructor_id': response['instructor_id']?.toString() ?? '',
        if (curriculums.isNotEmpty) 'curriculum_id': '${asMap(curriculums.first)?['id']}',
      },
    );
    return response;
  }

  /// `updateCourse(courseId, form)` — multipart `PUT` (method spoofing) from
  /// the page's `updateForm`; refetches the course details afterwards.
  Future<dynamic> updateCourse(String courseId, Map<String, dynamic> form) async {
    String str(String key) => jsTruthy(form[key]) ? '${form[key]}' : '';
    final fields = <String, dynamic>{
      '_method': 'PUT',
      'institute_id': _requiredInstituteId,
      'title': str('title'),
      'short_name': str('short_name'),
      'course_code': str('course_code'),
      'description': str('description'),
      'status': jsTruthy(form['status']) ? '${form['status']}' : 'draft',
      'curriculum_id': form['curriculum_id']?.toString() ?? '',
      'instructor_id': form['instructor_id']?.toString() ?? '',
      // The store reads `form.class_id`, which `updateForm` never has.
      'zsl_class_id': form['class_id']?.toString() ?? '',
      'zsl_subject_id': form['subject_id']?.toString() ?? '',
      'is_math_zoro': jsTruthy(form['isMathPlay']) ? 'true' : 'false',
      'zone': str('zone'),
      if (form['attach'] is UploadFile) 'image': form['attach'],
    };
    final res = await ref.read(courseServiceProvider).updateCourse(courseId, fields);
    await fetchCourseDetails(asInt(courseId) ?? courseId);
    return asMap(res)?['data'];
  }

  /// `deleteCourse(courseId)` — also drops it from the store's `courses`
  /// when the course list keeps them in lmsHandoff.
  Future<void> deleteCourse(Object courseId) async {
    await ref
        .read(courseServiceProvider)
        .deleteCourse({'institute_id': _requiredInstituteId, 'course_id': '$courseId'});
    final courses = _handoff.get('courses');
    if (courses is List) {
      _handoff.set('courses', [
        for (final c in courses)
          if ('${asMap(c)?['id']}' != '$courseId') c,
      ]);
    }
  }

  // ── curriculum / instructor attachments ─────────────────────────────────

  /// `attachCurriculumToCourse(curriculumId, courseId)` — errors are
  /// swallowed by the store (the API client already toasted them).
  Future<void> attachCurriculumToCourse(Object? curriculumId, String courseId) async {
    try {
      await ref.read(courseServiceProvider).AddCurriculumtoCourse({
        // axios drops `undefined` keys from the JSON body.
        'institute_id': ?_instituteId?.toString(),
        'curriculum_id': ?curriculumId,
        'course_id': courseId,
      });
    } catch (_) {}
  }

  /// `removeCurriculumFromCourse(curriculumId, courseId)`
  Future<void> removeCurriculumFromCourse(String curriculumId, String courseId) async {
    final instituteId = _instituteId;
    if (instituteId == null) throw const ApiError('Missing institute ID');
    await ref.read(courseServiceProvider).deleteCurriculumFromCourse({
      'institute_id': '$instituteId',
      'curriculum_id': curriculumId,
      'course_id': courseId,
    });
  }

  /// `attachInstructorToCourse(courseId, instructorId)`
  Future<dynamic> attachInstructorToCourse(String? courseId, String? instructorId) async {
    final instituteId = _instituteId;
    if (instituteId == null) throw const ApiError('Missing institute ID');
    return ref.read(courseServiceProvider).assignInstructorToCourse({
      'institute_id': '$instituteId',
      'course_id': ?courseId,
      'instructor_id': ?instructorId,
    });
  }

  /// `removeInstructorFromCourse(instructorId, courseId)`
  Future<void> removeInstructorFromCourse(String instructorId, String courseId) async {
    final instituteId = _instituteId;
    if (instituteId == null) throw const ApiError('Missing institute ID');
    await ref.read(courseServiceProvider).deleteInstructorFromCourse({
      'institute_id': '$instituteId',
      'course_id': courseId,
      'instructor_id': instructorId,
    });
  }

  // ── sections ─────────────────────────────────────────────────────────────

  /// `fetchSections(course_id)`
  Future<void> fetchSections(Object courseId) async {
    final id = _instituteId;
    if (id == null) return;
    final data = await ref.read(courseServiceProvider).getSections(id, courseId);
    state = state.copyWith(sections: _maps(data));
  }

  /// `setSectionId(id)`
  void setSectionId(Object? id) => _handoff.set('section_id', id);

  /// `this.userStore.chapter_id = id`
  void setChapterId(Object? id) => _handoff.set('chapter_id', id);

  /// `createSection(name, order)` — uses the store's `course_id`.
  Future<dynamic> createSection(String name, Object? order) {
    final instituteId = _instituteId?.toString();
    final courseId = this.courseId;
    if (instituteId == null || courseId == null) throw const ApiError('Institute ID or Course ID not set');
    return ref.read(courseServiceProvider).createSection({
      'institute_id': instituteId,
      'course_id': courseId,
      'class_id': ?_classId,
      'name': name,
      'order': order,
    });
  }

  /// `updateSection(sectionId, name, order)`
  Future<dynamic> updateSection(Object sectionId, String name, Object? order) {
    final instituteId = _instituteId?.toString();
    final courseId = this.courseId;
    if (instituteId == null || courseId == null) throw const ApiError('Institute ID or Course ID not set');
    return ref.read(courseServiceProvider).updateSection(sectionId, {
      'institute_id': instituteId,
      'course_id': courseId,
      'class_id': ?_classId,
      'name': name,
      'order': order,
    });
  }

  /// `deleteSection(sectionId)`
  Future<void> deleteSection(Object sectionId) async {
    await ref
        .read(courseServiceProvider)
        .deleteSection({'institute_id': _requiredInstituteId, 'section_id': '$sectionId'});
    state = state.copyWith(sections: [
      for (final s in state.sections)
        if ('${s['id']}' != '$sectionId') s,
    ]);
  }

  // ── chapters ─────────────────────────────────────────────────────────────

  /// `fetchChapters(section_id)`
  Future<void> fetchChapters(Object sectionId) async {
    final id = _instituteId;
    if (id == null) return;
    final data = await ref.read(courseServiceProvider).getChapters(id, sectionId);
    state = state.copyWith(chapters: _maps(data));
  }

  /// `createChapter(name, order)` — uses the store's `section_id` /
  /// `course_id`, then reloads that section's chapters.
  Future<dynamic> createChapter(String name, Object? order) async {
    final instituteId = _instituteId?.toString();
    final sectionId = jsTruthy(this.sectionId) ? '${this.sectionId}' : null;
    final courseId = this.courseId;
    if (instituteId == null || sectionId == null || courseId == null) {
      throw const ApiError('Institute ID or Section ID not set');
    }
    if (name.isEmpty) throw const ApiError('Chapter name is required');
    final result = await ref.read(courseServiceProvider).createChapter({
      'institute_id': instituteId,
      'section_id': sectionId,
      'name': name,
      'course_id': courseId,
      'class_id': ?_classId,
      'order': order,
    });
    final newId = dig(result, ['data', 'id']);
    if (jsTruthy(newId)) setChapterId(newId);
    await fetchChapters(this.sectionId!);
    return result;
  }

  /// `updateChapter(chapterId, name, order)`
  Future<dynamic> updateChapter(Object chapterId, String name, Object? order) {
    final instituteId = _instituteId?.toString();
    final courseId = this.courseId;
    if (instituteId == null || courseId == null) throw const ApiError('Institute ID or Course ID not set');
    return ref.read(courseServiceProvider).updateChapter(chapterId, {
      'institute_id': instituteId,
      'course_id': courseId,
      'class_id': ?_classId,
      'name': name,
      'order': order,
    });
  }

  /// `deleteChapter(chapterId)`
  Future<void> deleteChapter(Object chapterId) async {
    await ref
        .read(courseServiceProvider)
        .deleteChapter({'institute_id': _requiredInstituteId, 'chapter_id': '$chapterId'});
    state = state.copyWith(chapters: [
      for (final c in state.chapters)
        if ('${c['id']}' != '$chapterId') c,
    ]);
  }

  // ── contents ("concepts") ────────────────────────────────────────────────

  /// `fetchContents(chapter_id)`
  Future<void> fetchContents(Object chapterId) async {
    final id = _instituteId;
    if (id == null) return;
    final data = await ref.read(courseServiceProvider).getContents(id, chapterId);
    state = state.copyWith(contents: _maps(data));
  }

  /// `createContent(sectionId?, chapterId?)` from [contentForm] (`name`,
  /// `type`, `url`, `zslactvity`, `file` (UploadFile), `html_content`,
  /// `order`). Reloads the chapter's contents.
  Future<dynamic> createContent(Object? sectionIdParam, Object? chapterIdParam, Map<String, dynamic> contentForm) async {
    final instituteId = _instituteId?.toString();
    final sectionRaw = jsTruthy(sectionIdParam) ? sectionIdParam : sectionId;
    final chapterRaw = jsTruthy(chapterIdParam) ? chapterIdParam : chapterId;
    final section = sectionRaw?.toString();
    final chapter = chapterRaw?.toString();
    final courseId = this.courseId;
    final classId = _classId;
    if (instituteId == null || !jsTruthy(section) || !jsTruthy(chapter) || courseId == null) {
      throw const ApiError('Missing institute / course / section / chapter');
    }

    final type = contentForm['type'];
    final fields = <String, dynamic>{
      'institute_id': instituteId,
      'course_id': courseId,
      'section_id': section,
      'chapter_id': chapter,
      'name': jsFormValue(contentForm['name']),
      'type': jsFormValue(type),
      'order': '${contentForm['order']}',
      'zsl_activity_id': jsFormValue(contentForm['zslactvity']),
      'class_id': ?classId,
    };
    if (type == 'pdf') {
      if (contentForm['file'] is! UploadFile) throw const ApiError('Missing PDF file');
      fields['file'] = contentForm['file'];
    } else if (type == 'url') {
      fields['url'] = jsFormValue(contentForm['url']);
    } else if (type == 'html') {
      fields['html_content'] = jsFormValue(contentForm['html_content']);
    }

    final result = await ref.read(courseServiceProvider).createContent(fields);
    await fetchContents(asInt(chapter) ?? chapter!);
    return result;
  }

  /// `updateContent(contentId)` from the page's `selectedContentDetails`
  /// (`name`, `type`, `url`, `html_content`, `file`, `order`). Uses the
  /// store's `chapter_id`.
  Future<dynamic> updateContent(Object? contentId, Map<String, dynamic> details) {
    final instituteId = _instituteId?.toString();
    final chapter = jsTruthy(chapterId) ? '$chapterId' : null;
    final courseId = this.courseId;
    final classId = _classId;
    if (instituteId == null || chapter == null || courseId == null) {
      throw const ApiError('Institute ID or Chapter ID missing');
    }
    final type = details['type'];
    final fields = <String, dynamic>{
      '_method': 'PUT',
      'institute_id': instituteId,
      'chapter_id': chapter,
      'course_id': courseId,
      'name': jsFormValue(details['name']),
      'type': jsFormValue(type),
      'order': jsNumberString(details['order']),
      'class_id': ?classId,
    };
    if (type == 'pdf' && details['file'] is UploadFile) {
      fields['file'] = details['file'];
    } else if (type == 'url') {
      fields['url'] = jsFormValue(details['url']);
    } else if (type == 'html') {
      fields['html_content'] = jsFormValue(details['html_content']);
    }
    return ref.read(courseServiceProvider).updateContent('$contentId', fields);
  }

  /// `deleteContent(contentId)`
  Future<void> deleteContent(Object contentId) async {
    await ref
        .read(courseServiceProvider)
        .deleteContent({'institute_id': _requiredInstituteId, 'content_id': '$contentId'});
    state = state.copyWith(contents: [
      for (final c in state.contents)
        if ('${c['id']}' != '$contentId') c,
    ]);
  }
}

final teacherCourseControllerProvider =
    NotifierProvider<TeacherCourseController, TeacherCourseState>(TeacherCourseController.new);
