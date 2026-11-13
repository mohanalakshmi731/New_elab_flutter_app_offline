import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';
import 'class_course_logic.dart';

/// `courseForm` default (store state).
const Map<String, dynamic> initialCourseForm = {
  'institute_id': '',
  'curriculum_id': '',
  'instructor_id': '',
  'title': '',
  'allclass': '',
  'subject_id': '',
  'description': '',
  'short_name': '',
  'course_code': '',
  'image': null,
  'status': 'published',
  'is_math_zoro': false,
  'zone': '',
};

/// `contentForm` after `resetContentForm()` (`file` is an `UploadFile`).
const Map<String, dynamic> emptyContentForm = {
  'name': '',
  'type': '',
  'url': '',
  'file': null,
  'html_content': '',
  'order': '',
  'zslactvity': '',
};

/// `selectedContentDetails` default.
const Map<String, dynamic> emptySelectedContentDetails = {
  'id': null,
  'name': '',
  'type': '',
  'url': '',
  'html_content': '',
  'file': null,
  'order': '',
};

/// The course-outline slice of `useUserStore` used by `ClassCourseCreate.vue`:
/// `sections`, `chapters`, `contents`, `courses`, `curriculums`,
/// `instructors`, `courseForm`, `contentForm`, `selectedContentDetails`,
/// `allClasses`, `allsubject`, `course_id`, `section_id`, `chapter_id`,
/// `courseDetails`, `classCoursesDropdown`, `searchError`.
class ClassCourseState {
  const ClassCourseState({
    this.sections = const [],
    this.chapters = const [],
    this.contents = const [],
    this.courses = const [],
    this.curriculums = const [],
    this.instructors = const [],
    this.instructorCurrentPage = 1,
    this.allClasses = const [],
    this.allsubject = const [],
    this.courseForm = initialCourseForm,
    this.contentForm = emptyContentForm,
    this.selectedContentDetails = emptySelectedContentDetails,
    this.courseId,
    this.sectionId,
    this.chapterId,
    this.courseDetails,
    this.classCoursesDropdown = const [],
    this.searchError,
  });

  final List<Map<String, dynamic>> sections;
  final List<Map<String, dynamic>> chapters;
  final List<Map<String, dynamic>> contents;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> curriculums;
  final List<Map<String, dynamic>> instructors;

  /// `instructorPagination.current_page`
  final int instructorCurrentPage;
  final List<Map<String, dynamic>> allClasses;
  final List<Map<String, dynamic>> allsubject;
  final Map<String, dynamic> courseForm;
  final Map<String, dynamic> contentForm;
  final Map<String, dynamic> selectedContentDetails;
  final Object? courseId;
  final Object? sectionId;
  final Object? chapterId;
  final Map<String, dynamic>? courseDetails;
  final List<Map<String, dynamic>> classCoursesDropdown;
  final String? searchError;

  static const _unset = Object();

  ClassCourseState copyWith({
    List<Map<String, dynamic>>? sections,
    List<Map<String, dynamic>>? chapters,
    List<Map<String, dynamic>>? contents,
    List<Map<String, dynamic>>? courses,
    List<Map<String, dynamic>>? curriculums,
    List<Map<String, dynamic>>? instructors,
    int? instructorCurrentPage,
    List<Map<String, dynamic>>? allClasses,
    List<Map<String, dynamic>>? allsubject,
    Map<String, dynamic>? courseForm,
    Map<String, dynamic>? contentForm,
    Map<String, dynamic>? selectedContentDetails,
    Object? courseId = _unset,
    Object? sectionId = _unset,
    Object? chapterId = _unset,
    Object? courseDetails = _unset,
    List<Map<String, dynamic>>? classCoursesDropdown,
    Object? searchError = _unset,
  }) =>
      ClassCourseState(
        sections: sections ?? this.sections,
        chapters: chapters ?? this.chapters,
        contents: contents ?? this.contents,
        courses: courses ?? this.courses,
        curriculums: curriculums ?? this.curriculums,
        instructors: instructors ?? this.instructors,
        instructorCurrentPage: instructorCurrentPage ?? this.instructorCurrentPage,
        allClasses: allClasses ?? this.allClasses,
        allsubject: allsubject ?? this.allsubject,
        courseForm: courseForm ?? this.courseForm,
        contentForm: contentForm ?? this.contentForm,
        selectedContentDetails: selectedContentDetails ?? this.selectedContentDetails,
        courseId: identical(courseId, _unset) ? this.courseId : courseId,
        sectionId: identical(sectionId, _unset) ? this.sectionId : sectionId,
        chapterId: identical(chapterId, _unset) ? this.chapterId : chapterId,
        courseDetails:
            identical(courseDetails, _unset) ? this.courseDetails : courseDetails as Map<String, dynamic>?,
        classCoursesDropdown: classCoursesDropdown ?? this.classCoursesDropdown,
        searchError: identical(searchError, _unset) ? this.searchError : searchError as String?,
      );
}

class ClassCourseController extends Notifier<ClassCourseState> {
  @override
  ClassCourseState build() => const ClassCourseState();

  SessionState get _session => ref.read(sessionProvider);
  UserInfo? get _userInfo => _session.userInfo;

  /// `this.userInfo?.institute_id?.toString()`
  String? get _instituteId => _userInfo?.instituteId?.toString();

  /// `this.classDetails?.id?.toString()`
  String? get _classId => _session.classDetails?.id?.toString();

  LmsHandoff get _handoff => ref.read(lmsHandoffProvider.notifier);

  /// Store ids shared with the other classes/courses screens (lmsHandoff,
  /// web store field names `course_id`, `section_id`, `chapter_id`).
  Object? get _courseId => ref.read(lmsHandoffProvider)['course_id'];
  Object? get _sectionId => ref.read(lmsHandoffProvider)['section_id'];
  Object? get _chapterId => ref.read(lmsHandoffProvider)['chapter_id'];

  /// `courses = list` — also published as lmsHandoff `courses`.
  void _setCourses(List<Map<String, dynamic>> list) {
    state = state.copyWith(courses: list);
    _handoff.set('courses', list);
  }

  // ── ids (`setCourseId`, `setSectionId`, `chapter_id = …`) ────────────────
  // Mirrored into lmsHandoff under the web store field names so screens that
  // read `course_id` / `section_id` / `chapter_id` after navigating see them.

  void setCourseId(Object? id) {
    state = state.copyWith(courseId: id);
    _handoff.set('course_id', id);
  }

  void setSectionId(Object? id) {
    state = state.copyWith(sectionId: id);
    _handoff.set('section_id', id);
  }

  void setChapterId(Object? id) {
    state = state.copyWith(chapterId: id);
    _handoff.set('chapter_id', id);
  }

  // ── forms (v-model on store state) ───────────────────────────────────────

  void patchCourseForm(Map<String, dynamic> fields) =>
      state = state.copyWith(courseForm: {...state.courseForm, ...fields});

  void setContentForm(Map<String, dynamic> form) => state = state.copyWith(contentForm: {...form});

  void patchContentForm(Map<String, dynamic> fields) =>
      state = state.copyWith(contentForm: {...state.contentForm, ...fields});

  void setSelectedContentDetails(Map<String, dynamic> details) =>
      state = state.copyWith(selectedContentDetails: {...details});

  void patchSelectedContentDetails(Map<String, dynamic> fields) =>
      state = state.copyWith(selectedContentDetails: {...state.selectedContentDetails, ...fields});

  /// `resetContentForm()` / `resetUpdateContentForm()` (both reset `contentForm`).
  void resetContentForm() => state = state.copyWith(contentForm: emptyContentForm);

  // ── class ────────────────────────────────────────────────────────────────

  /// `fetchClassDetails(classId?)` — `GET /class/{id}?withCourses=yes` for the
  /// given class or the session's `classDetails.id`; stores the response as
  /// the session `classDetails` (with `c_id`). Returns null when the selected
  /// class changed while loading.
  Future<Map<String, dynamic>?> fetchClassDetails([Object? classId]) async {
    final instituteId = _instituteId;
    if (instituteId == null) throw const ApiError('Institute ID not available');
    final cid = classId?.toString() ?? _classId;
    if (cid == null) throw const ApiError('Class not selected');

    final res = await ref.read(classServiceProvider).getClassDetails(cid, {
      'institute_id': instituteId,
      'withCourses': 'yes',
    });
    if (cid != _classId) return null;

    final response = asMap(res);
    if (response != null) response['c_id'] = response['curricula_id'] ?? response['c_id'];
    ref.read(sessionProvider.notifier).setClassDetails(IdName.fromJson(response));
    return response;
  }

  /// `fetchCurriculums()`
  Future<void> fetchCurriculums() async {
    final instituteId = _userInfo?.instituteId;
    if (!jsTruthy(instituteId)) return;
    final data = await ref.read(classServiceProvider).getAllCurriculums(instituteId!);
    state = state.copyWith(curriculums: mapCurriculums(data));
  }

  /// `getInstructorsdropdown(classId)` — every page of the class's instructors.
  Future<void> getInstructorsdropdown(Object? classId) async {
    if (!jsTruthy(classId)) return;
    state = state.copyWith(instructors: const []);
    var currentPage = 1;
    var lastPage = 1;
    final all = <Map<String, dynamic>>[];
    try {
      do {
        final res = asMap(await ref.read(instructorServiceProvider).getInstructors(classId!, currentPage));
        all.addAll(normalizeInstructors(res?['data']));
        lastPage = asInt(res?['last_page']) ?? 1;
        currentPage++;
      } while (currentPage <= lastPage);
      state = state.copyWith(instructors: all);
    } catch (e) {
      debugPrint('Error loading instructors: $e');
    }
  }

  /// `getAllInstructors(page?)`
  Future<void> getAllInstructors([int? page]) async {
    final currentPage = page ?? state.instructorCurrentPage;
    final res = asMap(await ref.read(instructorServiceProvider).getallInstructors(currentPage));
    state = state.copyWith(
      instructors: normalizeInstructors(res?['data']),
      instructorCurrentPage: asInt(res?['current_page']) ?? currentPage,
    );
  }

  /// `loadAllClasses()` — the institute's ZSL classes (`allClasses`).
  Future<List<Map<String, dynamic>>> loadAllClasses() async {
    final instituteId = _userInfo?.instituteId;
    if (!jsTruthy(instituteId)) {
      debugPrint('No institute ID available');
      return const [];
    }
    try {
      final res = await ref.read(zslServiceProvider).getClass(instituteId);
      final classes = mapsOf(dataOr(res, const []));
      state = state.copyWith(allClasses: classes);
      return classes;
    } catch (e) {
      state = state.copyWith(allClasses: const []);
      rethrow;
    }
  }

  /// `getAllSubjects(instituteId, classId)`
  Future<List<Map<String, dynamic>>> getAllSubjects(Object instituteId, Object classId) async {
    try {
      final res = await ref.read(zslServiceProvider).getAllSubjects(instituteId, classId);
      final subjects = mapsOf(dataOr(res, const []));
      state = state.copyWith(allsubject: subjects);
      return subjects;
    } catch (e) {
      state = state.copyWith(allsubject: const []);
      rethrow;
    }
  }

  // ── course ───────────────────────────────────────────────────────────────

  /// `createCourse(classid)` — multipart `POST /course` from `courseForm`.
  /// Resets the form and returns true on "Course created successfully".
  Future<bool> createCourse([String? classId]) async {
    final instituteId = _instituteId ?? '';
    patchCourseForm({'institute_id': instituteId});
    final response = asMap(await ref
        .read(courseServiceProvider)
        .createCourse(buildCreateCourseData(state.courseForm, instituteId: instituteId, classId: classId)));

    final newId = dig(response, ['data', 'id']);
    if (jsTruthy(newId)) setCourseId(newId);

    if (response?['message'] == 'Course created successfully') {
      state = state.copyWith(courseForm: initialCourseForm);
      return true;
    }
    return false;
  }

  /// `fetchCourseDetails(courseId)` — the course with sections → chapters →
  /// contents, curriculums and instructors. Also fills `sections`,
  /// `chapters` / `contents` (flattened), `classCoursesDropdown` and the
  /// `courseForm` fields.
  Future<Map<String, dynamic>?> fetchCourseDetails(Object? courseId) async {
    final instituteId = _instituteId;
    if (!jsTruthy(_userInfo?.instituteId)) throw const ApiError('User institute ID not set');
    final res = await ref.read(courseServiceProvider).getCourseDetails(courseId ?? 'undefined', {
      'institute_id': instituteId,
      'with': 'content',
      'with_curriculums': true,
      'with_instructors': true,
    });
    final response = asMap(res);
    if (response == null) return null;

    final flat = flattenCourse(response);
    final curriculums = asList(response['curriculums']);
    final status = response['status']?.toString().toLowerCase() ?? '';
    state = state.copyWith(
      sections: flat.sections,
      chapters: flat.chapters,
      contents: flat.contents,
      classCoursesDropdown: [...flat.contents],
      courseDetails: response,
      courseForm: {
        ...state.courseForm,
        'title': response['title'],
        'description': jsTruthy(response['description']) ? response['description'] : '',
        'short_name': response['short_name'],
        'course_code': response['course_code'],
        'status': status.isEmpty ? 'draft' : status,
        'instructor_id': response['instructor_id']?.toString() ?? '',
        if (curriculums.isNotEmpty) 'curriculum_id': '${asMap(curriculums.first)?['id']}',
      },
    );
    _handoff.set('classCoursesDropdown', [...flat.contents]);
    return response;
  }

  /// `updateCourse(courseId, form)` — multipart `PUT` (spoofed) then refreshes
  /// the course details. Returns `res.data`.
  Future<dynamic> updateCourse(String courseId, Map<String, dynamic> form) async {
    final res = await ref
        .read(courseServiceProvider)
        .updateCourse(courseId, buildUpdateCourseFields(form, instituteId: _instituteId ?? 'undefined'));
    await fetchCourseDetails(jsNumber(courseId));
    return asMap(res)?['data'];
  }

  /// `deleteCourse(courseId)`
  Future<void> deleteCourse(Object courseId) async {
    try {
      await ref.read(courseServiceProvider).deleteCourse({
        'institute_id': _instituteId,
        'course_id': '$courseId',
      });
      final shared = mapsOf(ref.read(lmsHandoffProvider)['courses'] ?? state.courses);
      _setCourses([for (final c in shared) if ('${c['id']}' != '$courseId') c]);
    } catch (e) {
      debugPrint('Failed to delete course: $e');
      rethrow;
    }
  }

  /// `searchCourse(term)` — institute-wide course search into `courses`.
  Future<void> searchCourse(String term) async {
    final instituteId = _instituteId;
    if (!jsTruthy(_userInfo?.instituteId)) {
      state = state.copyWith(searchError: 'Institute ID not available');
      return;
    }
    state = state.copyWith(searchError: null);
    try {
      final raw = await ref.read(courseServiceProvider).searchCourse(instituteId!, term.trim());
      _setCourses(mapSearchCourses(raw));
    } catch (e) {
      state = state.copyWith(searchError: e is ApiError ? e.message : 'Failed to search course');
      debugPrint('Error searching course: $e');
    }
  }

  // ── curriculum / instructor on a course ──────────────────────────────────

  /// `attachCurriculumToCourse(curriculumId, courseId)` — errors are only logged.
  Future<void> attachCurriculumToCourse(Object? curriculumId, String courseId) async {
    try {
      await ref.read(courseServiceProvider).AddCurriculumtoCourse({
        'institute_id': _instituteId,
        'curriculum_id': ?curriculumId,
        'course_id': courseId,
      });
    } catch (e) {
      debugPrint('$e');
    }
  }

  /// `removeCurriculumFromCourse(curriculumId, courseId)`
  Future<void> removeCurriculumFromCourse(String curriculumId, String courseId) async {
    final instituteId = _instituteId;
    if (instituteId == null) throw const ApiError('Missing institute ID');
    await ref.read(courseServiceProvider).deleteCurriculumFromCourse({
      'institute_id': instituteId,
      'curriculum_id': curriculumId,
      'course_id': courseId,
    });
  }

  /// `attachInstructorToCourse(courseId, instructorId)`
  Future<dynamic> attachInstructorToCourse(String courseId, String? instructorId) {
    final instituteId = _instituteId;
    if (instituteId == null) throw const ApiError('Missing institute ID');
    return ref.read(courseServiceProvider).assignInstructorToCourse({
      'institute_id': instituteId,
      'course_id': courseId,
      'instructor_id': ?instructorId,
    });
  }

  /// `removeInstructorFromCourse(instructorId, courseId)`
  Future<void> removeInstructorFromCourse(String instructorId, String courseId) async {
    final instituteId = _instituteId;
    if (instituteId == null) throw const ApiError('Missing institute ID');
    await ref.read(courseServiceProvider).deleteInstructorFromCourse({
      'institute_id': instituteId,
      'course_id': courseId,
      'instructor_id': instructorId,
    });
  }

  // ── sections ─────────────────────────────────────────────────────────────

  Map<String, dynamic> _outlinePayload(String name, num? order) {
    final instituteId = _instituteId;
    final courseId = _courseId?.toString();
    if (!jsTruthy(instituteId) || !jsTruthy(courseId)) {
      throw const ApiError('Institute ID or Course ID not set');
    }
    return {
      'institute_id': instituteId,
      'course_id': courseId,
      'class_id': ?_classId,
      'name': name,
      'order': order,
    };
  }

  /// `createSection(name, order)` — `order` null = JS `NaN`.
  Future<dynamic> createSection(String name, num? order) =>
      ref.read(courseServiceProvider).createSection(_outlinePayload(name, order));

  /// `fetchSections(course_id)`
  Future<void> fetchSections(Object courseId) async {
    final instituteId = _userInfo?.instituteId;
    if (!jsTruthy(instituteId)) return;
    final data = await ref.read(courseServiceProvider).getSections(instituteId!, courseId);
    state = state.copyWith(sections: listOrEmpty(data));
  }

  /// `updateSection(sectionId, name, order)`
  Future<dynamic> updateSection(Object sectionId, String name, num? order) =>
      ref.read(courseServiceProvider).updateSection(sectionId, _outlinePayload(name, order));

  // ── chapters ─────────────────────────────────────────────────────────────

  /// `createChapter(name, order)` — in the store's `section_id`; refreshes
  /// `chapters` and remembers the new `chapter_id`.
  Future<dynamic> createChapter(String name, num? order) async {
    final instituteId = _instituteId;
    final sectionId = _sectionId?.toString();
    final courseId = _courseId?.toString();
    if (!jsTruthy(instituteId) || !jsTruthy(sectionId) || !jsTruthy(courseId)) {
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
    await fetchChapters(_sectionId!);
    return result;
  }

  /// `fetchChapters(section_id)`
  Future<void> fetchChapters(Object sectionId) async {
    final instituteId = _userInfo?.instituteId;
    if (!jsTruthy(instituteId)) return;
    final data = await ref.read(courseServiceProvider).getChapters(instituteId!, sectionId);
    state = state.copyWith(chapters: listOrEmpty(data));
  }

  /// `updateChapter(chapterId, name, order)`
  Future<dynamic> updateChapter(Object chapterId, String name, num? order) =>
      ref.read(courseServiceProvider).updateChapter(chapterId, _outlinePayload(name, order));

  // ── contents (concepts) ──────────────────────────────────────────────────

  /// `createContent(sectionId?, chapterId?)` — multipart `POST /content` from
  /// `contentForm`; refreshes `contents` and resets the form.
  Future<dynamic> createContent([Object? sectionIdParam, Object? chapterIdParam]) async {
    final instituteId = _instituteId;
    final sectionId = (jsTruthy(sectionIdParam) ? sectionIdParam : _sectionId)?.toString();
    final chapterId = (jsTruthy(chapterIdParam) ? chapterIdParam : _chapterId)?.toString();
    final courseId = _courseId?.toString();
    if (!jsTruthy(instituteId) || !jsTruthy(sectionId) || !jsTruthy(chapterId) || !jsTruthy(courseId)) {
      throw const ApiError('Missing institute / course / section / chapter');
    }
    final chapter = chapterId!;
    final fields = buildCreateContentFields(
      state.contentForm,
      instituteId: instituteId!,
      courseId: courseId!,
      sectionId: sectionId!,
      chapterId: chapter,
      classId: _classId,
    );
    final result = await ref.read(courseServiceProvider).createContent(fields);
    await fetchContents(jsNumber(chapter) ?? chapter);
    resetContentForm();
    return result;
  }

  /// `fetchContents(chapter_id)`
  Future<void> fetchContents(Object chapterId) async {
    final instituteId = _userInfo?.instituteId;
    if (!jsTruthy(instituteId)) return;
    final data = await ref.read(courseServiceProvider).getContents(instituteId!, chapterId);
    state = state.copyWith(contents: listOrEmpty(data));
  }

  /// `updateContent(contentId)` — multipart `PUT` (spoofed) from
  /// `selectedContentDetails`.
  Future<dynamic> updateContent(Object? contentId) async {
    final instituteId = _instituteId;
    final chapterId = _chapterId?.toString();
    final courseId = _courseId?.toString();
    if (!jsTruthy(instituteId) || !jsTruthy(chapterId) || !jsTruthy(courseId)) {
      throw const ApiError('Institute ID or Chapter ID missing');
    }
    final fields = buildUpdateContentFields(
      state.selectedContentDetails,
      instituteId: instituteId!,
      chapterId: chapterId!,
      courseId: courseId!,
      classId: _classId,
    );
    final result = await ref.read(courseServiceProvider).updateContent(contentId ?? 'undefined', fields);
    resetContentForm();
    return result;
  }
}

final classCourseControllerProvider =
    NotifierProvider<ClassCourseController, ClassCourseState>(ClassCourseController.new);
