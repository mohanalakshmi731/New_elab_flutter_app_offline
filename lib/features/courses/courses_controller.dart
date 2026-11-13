import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/upload_file.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';
import 'course_list_logic.dart';

/// `contentForm` initial value (store state).
const emptyContentForm = <String, dynamic>{
  'name': '',
  'type': '',
  'url': '',
  'zslactvity': '',
  'file': null,
  'html_content': '',
  'order': '',
};

/// `selectedContentDetails` initial value (store state).
const emptySelectedContentDetails = <String, dynamic>{
  'id': null,
  'name': '',
  'type': '',
  'url': '',
  'html_content': '',
  'file': null,
  'order': '',
};

/// `currentCurriculum` initial value (store state).
const emptyCurrentCurriculum = <String, dynamic>{'id': 0, 'institute_id': 0, 'name': '', 'status': ''};

/// The course / curriculum slice of `useUserStore` used by the course list
/// (`courselist.vue`): `curriculums`, `courses`, `instructors`,
/// `instructorPagination`, `sections`, `chapters`, `contents`,
/// `contentForm`, `selectedContentDetails`, `currentCurriculum`,
/// `courseDetails`, `allClasses`, `allsubject`, `searchError`.
///
/// `course_id`, `section_id`, `chapter_id` (and a copy of `courses`) are
/// shared with the other classes/courses screens through
/// [lmsHandoffProvider] under those web field names — see
/// [CoursesController.courseId] etc.
///
/// Like the Pinia store it outlives the widgets (re-keying the course list
/// keeps it). Lists hold the API maps as-is (the web mutated those objects
/// in place, e.g. `curriculum.status = newStatus`).
class CoursesState {
  const CoursesState({
    this.curriculums = const [],
    this.courses = const [],
    this.instructors = const [],
    this.instructorPagination = const {},
    this.sections = const [],
    this.chapters = const [],
    this.contents = const [],
    this.contentForm = emptyContentForm,
    this.selectedContentDetails = emptySelectedContentDetails,
    this.currentCurriculum = emptyCurrentCurriculum,
    this.courseDetails,
    this.allClasses = const [],
    this.allsubject = const [],
    this.searchError,
  });

  final List<Map<String, dynamic>> curriculums;
  final List<Map<String, dynamic>> courses;
  final List<Map<String, dynamic>> instructors;
  final Map<String, dynamic> instructorPagination;
  final List<Map<String, dynamic>> sections;
  final List<Map<String, dynamic>> chapters;
  final List<Map<String, dynamic>> contents;

  /// Keys: name, type, url, zslactvity, file (an [UploadFile] or null),
  /// html_content, order.
  final Map<String, dynamic> contentForm;

  /// Keys: id, name, type, url, html_content, file, order.
  final Map<String, dynamic> selectedContentDetails;

  /// Keys: id, institute_id, name, status (`/curriculum/{id}` body).
  final Map<String, dynamic> currentCurriculum;
  final Map<String, dynamic>? courseDetails;
  final List<Map<String, dynamic>> allClasses;
  final List<Map<String, dynamic>> allsubject;
  final String? searchError;

  static const _unset = Object();

  CoursesState copyWith({
    List<Map<String, dynamic>>? curriculums,
    List<Map<String, dynamic>>? courses,
    List<Map<String, dynamic>>? instructors,
    Map<String, dynamic>? instructorPagination,
    List<Map<String, dynamic>>? sections,
    List<Map<String, dynamic>>? chapters,
    List<Map<String, dynamic>>? contents,
    Map<String, dynamic>? contentForm,
    Map<String, dynamic>? selectedContentDetails,
    Map<String, dynamic>? currentCurriculum,
    Object? courseDetails = _unset,
    List<Map<String, dynamic>>? allClasses,
    List<Map<String, dynamic>>? allsubject,
    Object? searchError = _unset,
  }) => CoursesState(
    curriculums: curriculums ?? this.curriculums,
    courses: courses ?? this.courses,
    instructors: instructors ?? this.instructors,
    instructorPagination: instructorPagination ?? this.instructorPagination,
    sections: sections ?? this.sections,
    chapters: chapters ?? this.chapters,
    contents: contents ?? this.contents,
    contentForm: contentForm ?? this.contentForm,
    selectedContentDetails: selectedContentDetails ?? this.selectedContentDetails,
    currentCurriculum: currentCurriculum ?? this.currentCurriculum,
    courseDetails: identical(courseDetails, _unset) ? this.courseDetails : courseDetails as Map<String, dynamic>?,
    allClasses: allClasses ?? this.allClasses,
    allsubject: allsubject ?? this.allsubject,
    searchError: identical(searchError, _unset) ? this.searchError : searchError as String?,
  );
}

class CoursesController extends Notifier<CoursesState> {
  @override
  CoursesState build() => const CoursesState();

  static List<Map<String, dynamic>> _maps(dynamic list) => [for (final e in asList(list)) ?asMap(e)];

  SessionState get _session => ref.read(sessionProvider);

  LmsHandoff get _handoff => ref.read(lmsHandoffProvider.notifier);

  /// `course_id` (shared store field, kept in [lmsHandoffProvider]).
  Object? get courseId => ref.read(lmsHandoffProvider)['course_id'];

  /// `section_id` (shared store field, kept in [lmsHandoffProvider]).
  Object? get sectionId => ref.read(lmsHandoffProvider)['section_id'];

  /// `chapter_id` (shared store field, kept in [lmsHandoffProvider]).
  Object? get chapterId => ref.read(lmsHandoffProvider)['chapter_id'];

  /// `this.courses = list` — also published as the `courses` handoff key.
  void _setCourses(List<Map<String, dynamic>> list) {
    state = state.copyWith(courses: list);
    _handoff.set('courses', list);
  }

  int? get _instituteId => _session.userInfo?.instituteId;

  /// `this.userInfo!.institute_id!.toString()`
  String _requireInstitute() {
    final id = _instituteId;
    if (id == null) throw StateError('institute_id is null');
    return '$id';
  }

  /// `this.classDetails?.id?.toString()`
  String? get _classId => _session.classDetails?.id?.toString();

  /// `x?.toString()` where `x` may be undefined.
  static String? _idStr(Object? v) => v?.toString();

  /// `(a || b)?.toString()`
  static String? _orStr(Object? a, Object? b) => jsTruthy(a) ? '$a' : b?.toString();

  // ── Simple setters (the web wrote these store fields directly) ─────────

  /// `userStore.course_id = id`
  void setCourseId(Object? id) => _handoff.set('course_id', id);

  /// `setSectionId(id)`
  void setSectionId(Object? id) => _handoff.set('section_id', id);

  /// `userStore.chapter_id = id`
  void setChapterId(Object? id) => _handoff.set('chapter_id', id);

  void setContentForm(Map<String, dynamic> form) => state = state.copyWith(contentForm: form);

  void patchContentForm(Map<String, dynamic> patch) =>
      state = state.copyWith(contentForm: {...state.contentForm, ...patch});

  void setSelectedContentDetails(Map<String, dynamic> details) =>
      state = state.copyWith(selectedContentDetails: details);

  void patchSelectedContentDetails(Map<String, dynamic> patch) =>
      state = state.copyWith(selectedContentDetails: {...state.selectedContentDetails, ...patch});

  void patchCurrentCurriculum(Map<String, dynamic> patch) =>
      state = state.copyWith(currentCurriculum: {...state.currentCurriculum, ...patch});

  /// `curriculum.status = newStatus` (the web mutated the list item).
  void setCurriculumStatusLocally(Object? id, String status) {
    state = state.copyWith(
      curriculums: [
        for (final c in state.curriculums)
          if (c['id'] == id) ({...c, 'status': status}) else c,
      ],
    );
  }

  /// `clearCourseData()` — called by the class list before re-keying the
  /// course list.
  void clearCourseData() {
    state = state.copyWith(curriculums: const []);
    _setCourses(const []);
  }

  // ── Curriculums ───────────────────────────────────────────────────────

  /// `fetchCurriculums()`
  Future<void> fetchCurriculums() async {
    final id = _instituteId;
    if (id == null) return;
    final data = await ref.read(classServiceProvider).getAllCurriculums(id);
    state = state.copyWith(
      curriculums: [
        for (final item in _maps(data))
          {
            'id': item['id'],
            'institute_id': item['institute_id'],
            'name': item['name'],
            'status': jsTruthy(item['status']) ? '${item['status']}'.toLowerCase() : 'draft',
            'created_at': item['created_at'],
          },
      ],
    );
  }

  /// `fetchCurriculumById(curriculumId)` — API errors are swallowed (the
  /// web only logged them).
  Future<dynamic> fetchCurriculumById(Object? curriculumId) async {
    final id = _instituteId;
    if (id == null) throw StateError('Institute ID not available');
    try {
      final data = await ref.read(classServiceProvider).getAllCurriculumById(curriculumId ?? '', id);
      state = state.copyWith(currentCurriculum: asMap(data) ?? const {});
      return data;
    } catch (_) {
      return null;
    }
  }

  /// `updateCurriculum({ id, institute_id, name, status })`
  Future<dynamic> updateCurriculum(Map<String, dynamic> curriculum) => ref.read(classServiceProvider).updateCurriculum(
    curriculum['id'] ?? '',
    {'institute_id': curriculum['institute_id'], 'name': curriculum['name'], 'status': curriculum['status']},
  );

  /// `updateCurriculumStatus({ id, institute_id, value })` — sends the
  /// session's institute id, like the web.
  Future<dynamic> updateCurriculumStatus(Map<String, dynamic> curriculum) {
    final id = _instituteId;
    if (id == null) throw StateError('Institute ID not available');
    return ref.read(classServiceProvider).updateCurriculumStatus(curriculum['id'] ?? '', {
      'institute_id': id,
      'value': curriculum['value'],
    });
  }

  /// `searchCurriculum(term)`
  Future<void> searchCurriculum(String term) async {
    final id = _instituteId;
    if (id == null) {
      state = state.copyWith(searchError: 'Institute ID not available');
      return;
    }
    state = state.copyWith(searchError: null);
    try {
      final raw = await ref.read(classServiceProvider).searchCurriculum('$id', term);
      state = state.copyWith(
        curriculums: [
          for (final item in _maps(searchArray(raw).where(jsTruthy).toList()))
            {
              'id': item['id'],
              'institute_id': item['institute_id'] ?? item['instituteId'],
              'name': item['name'] ?? item['label'] ?? 'Unnamed curriculum',
              'status': '${item['status'] ?? 'unknown'}',
              'created_at': item['created_at'] ?? item['createdAt'],
              'updated_at': item['updated_at'] ?? item['updatedAt'],
            },
        ],
      );
    } catch (e) {
      state = state.copyWith(searchError: 'Failed to search curriculum');
    }
  }

  /// `deleteCurriculum(curriculumId)`
  Future<void> deleteCurriculum(Object curriculumId) async {
    await ref.read(courseServiceProvider).deleteCurriculum({
      'institute_id': _requireInstitute(),
      'curriculum_id': '$curriculumId',
    });
    state = state.copyWith(
      curriculums: [
        for (final c in state.curriculums)
          if ('${c['id']}' != '$curriculumId') c,
      ],
    );
  }

  // ── Instructors ───────────────────────────────────────────────────────

  /// `getAllInstructors(page?)`
  Future<void> getAllInstructors([int? page]) async {
    final currentPage = page ?? asInt(state.instructorPagination['current_page']) ?? 1;
    final res = asMap(await ref.read(instructorServiceProvider).getallInstructors(currentPage)) ?? const {};
    state = state.copyWith(
      instructors: [
        for (final inst in _maps(jsTruthy(res['data']) ? res['data'] : const []))
          {
            ...inst,
            'user':
                asMap(inst['user']) ??
                {'first_name': '', 'last_name': '', 'email': '', 'phone': '', 'country_code': ''},
          },
      ],
      instructorPagination: {
        'current_page': res['current_page'],
        'last_page': res['last_page'],
        'total': res['total'],
        'per_page': res['per_page'],
        'links': res['links'],
      },
    );
  }

  // ── Courses ───────────────────────────────────────────────────────────

  /// `fetchCourse(only_admin?)`
  Future<void> fetchCourse([int? onlyAdmin]) async {
    final id = _instituteId;
    if (id == null) return;
    final data = await ref.read(courseServiceProvider).getCourses(id, onlyAdmin);
    _setCourses(_maps(data));
  }

  /// `fetchClassCourse()` — courses of the curriculum in `classDetails.c_id`
  /// (or `curricula_id`). Errors are swallowed like the web.
  Future<void> fetchClassCourse() async {
    final id = _instituteId;
    if (id == null) return;
    final extra = _session.classDetails?.extra ?? const {};
    final curriculumId = jsTruthy(extra['c_id']) ? extra['c_id'] : extra['curricula_id'];
    if (!jsTruthy(curriculumId)) return;
    try {
      final data = await ref.read(classServiceProvider).getClassCourses('$id', '$curriculumId');
      _setCourses(_maps(data));
    } catch (_) {}
  }

  /// `fetchCourseDetails(courseId)` — also replaces `sections`, `chapters`
  /// (every section's chapters) and `contents` (every chapter's contents).
  Future<Map<String, dynamic>?> fetchCourseDetails(Object courseId) async {
    final id = _instituteId;
    if (id == null) throw StateError('User institute ID not set');
    final response = asMap(
      await ref.read(courseServiceProvider).getCourseDetails(courseId, {
        'institute_id': '$id',
        'with': 'content',
        'with_curriculums': true,
        'with_instructors': true,
      }),
    );
    if (response == null) return null;
    final sections = _maps(response['sections']);
    final chapters = [for (final s in sections) ..._maps(s['chapters'])];
    final contents = [for (final c in chapters) ..._maps(c['contents'])];
    state = state.copyWith(sections: sections, chapters: chapters, contents: contents, courseDetails: response);
    return response;
  }

  /// `updateCourse(courseId, form)` — multipart PUT (`_method`), then
  /// refreshes the course details.
  Future<dynamic> updateCourse(String courseId, Map<String, dynamic> form) async {
    final attach = form['attach'];
    final fields = <String, dynamic>{
      '_method': 'PUT',
      'institute_id': _requireInstitute(),
      'title': orBlank(form['title']),
      'short_name': orBlank(form['short_name']),
      'course_code': orBlank(form['course_code']),
      'description': orBlank(form['description']),
      'status': jsTruthy(form['status']) ? '${form['status']}' : 'draft',
      'curriculum_id': orBlank(form['curriculum_id']),
      'instructor_id': orBlank(form['instructor_id']),
      'zsl_class_id': orBlank(form['class_id']),
      'zsl_subject_id': orBlank(form['subject_id']),
      'is_math_zoro': jsTruthy(form['isMathPlay']) ? 'true' : 'false',
      'zone': orBlank(form['zone']),
      if (attach is UploadFile) 'image': attach,
    };
    final res = await ref.read(courseServiceProvider).updateCourse(courseId, fields);
    await fetchCourseDetails(int.tryParse(courseId) ?? courseId);
    return asMap(res)?['data'];
  }

  /// `searchCourse(term)`
  Future<void> searchCourse(String term) async {
    final id = _instituteId;
    if (id == null) {
      state = state.copyWith(searchError: 'Institute ID not available');
      return;
    }
    state = state.copyWith(searchError: null);
    try {
      final raw = await ref.read(courseServiceProvider).searchCourse('$id', term.trim());
      _setCourses([
        for (final item in _maps(searchArray(raw).where(jsTruthy).toList()))
          {
            'id': item['id'],
            'institute_id': item['institute_id'],
            'instructor_id': item['instructor_id'] ?? asMap(item['instructor'])?['id'],
            'title': item['title'] ?? item['name'] ?? 'Untitled course',
            'description': item['description'] ?? '',
            'short_name': item['short_name'] ?? item['code'] ?? '',
            'course_code': item['course_code'] ?? item['code'] ?? '',
            'image': item['image'],
            'status': '${item['status'] ?? 'unknown'}',
            'created_at': item['created_at'] ?? item['createdAt'],
            'updated_at': item['updated_at'] ?? item['updatedAt'],
            'instructor': item['instructor'],
          },
      ]);
    } catch (_) {
      state = state.copyWith(searchError: 'Failed to search course');
    }
  }

  /// `deleteCourse(courseId)`
  Future<void> deleteCourse(Object courseId) async {
    await ref.read(courseServiceProvider).deleteCourse({'institute_id': _requireInstitute(), 'course_id': '$courseId'});
    _setCourses([
      for (final c in state.courses)
        if ('${c['id']}' != '$courseId') c,
    ]);
  }

  // ── Course ↔ curriculum / instructor ──────────────────────────────────

  /// `attachCurriculumToCourse(curriculumId, courseId)` — errors swallowed.
  Future<void> attachCurriculumToCourse(Object? curriculumId, String courseId) async {
    try {
      await ref
          .read(courseServiceProvider)
          .AddCurriculumtoCourse(
            withoutUndefined({
              'institute_id': _instituteId?.toString(),
              'curriculum_id': curriculumId,
              'course_id': courseId,
            }),
          );
    } catch (_) {}
  }

  /// `removeCurriculumFromCourse(curriculumId, courseId)`
  Future<void> removeCurriculumFromCourse(String curriculumId, String courseId) async {
    final id = _instituteId;
    if (id == null) throw StateError('Missing institute ID');
    await ref.read(courseServiceProvider).deleteCurriculumFromCourse({
      'institute_id': '$id',
      'curriculum_id': curriculumId,
      'course_id': courseId,
    });
  }

  /// `attachInstructorToCourse(courseId, instructorId)`
  Future<dynamic> attachInstructorToCourse(String? courseId, String? instructorId) {
    final id = _instituteId;
    if (id == null) throw StateError('Missing institute ID');
    return ref
        .read(courseServiceProvider)
        .assignInstructorToCourse(
          withoutUndefined({'institute_id': '$id', 'course_id': courseId, 'instructor_id': instructorId}),
        );
  }

  /// `removeInstructorFromCourse(instructorId, courseId)`
  Future<void> removeInstructorFromCourse(String instructorId, String courseId) async {
    final id = _instituteId;
    if (id == null) throw StateError('Missing institute ID');
    await ref.read(courseServiceProvider).deleteInstructorFromCourse({
      'institute_id': '$id',
      'course_id': courseId,
      'instructor_id': instructorId,
    });
  }

  // ── Sections ──────────────────────────────────────────────────────────

  Map<String, dynamic> _outlinePayload(String name, num? order) {
    final instituteId = _instituteId?.toString();
    final courseId = _idStr(this.courseId);
    if (instituteId == null || courseId == null) {
      throw StateError('Institute ID or Course ID not set');
    }
    final payload = withoutUndefined({
      'institute_id': instituteId,
      'course_id': courseId,
      'class_id': _classId,
      'name': name,
    });
    // `order: Number(x)` — NaN is serialised as null; undefined is dropped.
    if (order != null) payload['order'] = jsonNumber(order);
    return payload;
  }

  /// `createSection(name, order)` — `order` is `Number(sectionOrder)`.
  Future<dynamic> createSection(String name, [num? order]) =>
      ref.read(courseServiceProvider).createSection(_outlinePayload(name, order));

  /// `fetchSections(course_id)`
  Future<void> fetchSections(Object courseId) async {
    final id = _instituteId;
    if (id == null) return;
    final data = await ref.read(courseServiceProvider).getSections(id, courseId);
    state = state.copyWith(sections: _maps(data));
  }

  /// `updateSection(sectionId, name, order)`
  Future<dynamic> updateSection(Object sectionId, String name, [num? order]) =>
      ref.read(courseServiceProvider).updateSection(sectionId, _outlinePayload(name, order));

  /// `deleteSection(sectionId)`
  Future<void> deleteSection(Object sectionId) async {
    await ref.read(courseServiceProvider).deleteSection({
      'institute_id': _requireInstitute(),
      'section_id': '$sectionId',
    });
    state = state.copyWith(
      sections: [
        for (final s in state.sections)
          if ('${s['id']}' != '$sectionId') s,
      ],
    );
  }

  // ── Chapters ──────────────────────────────────────────────────────────

  /// `createChapter(name, order)` — in the section of `section_id`.
  Future<dynamic> createChapter(String name, [num? order]) async {
    final instituteId = _instituteId?.toString();
    final sectionId = _idStr(this.sectionId);
    final courseId = _idStr(this.courseId);
    if (instituteId == null || sectionId == null || courseId == null) {
      throw StateError('Institute ID or Section ID not set');
    }
    if (name.isEmpty) throw StateError('Chapter name is required');
    final payload = withoutUndefined({
      'institute_id': instituteId,
      'section_id': sectionId,
      'name': name,
      'course_id': courseId,
      'class_id': _classId,
    });
    if (order != null) payload['order'] = jsonNumber(order);
    final result = await ref.read(courseServiceProvider).createChapter(payload);
    final newId = dig(result, ['data', 'id']);
    if (jsTruthy(newId)) setChapterId(newId);
    await fetchChapters(this.sectionId!);
    return result;
  }

  /// `fetchChapters(section_id)`
  Future<void> fetchChapters(Object sectionId) async {
    final id = _instituteId;
    if (id == null) return;
    final data = await ref.read(courseServiceProvider).getChapters(id, sectionId);
    state = state.copyWith(chapters: _maps(data));
  }

  /// `updateChapter(chapterId, name, order)`
  Future<dynamic> updateChapter(Object chapterId, String name, [num? order]) =>
      ref.read(courseServiceProvider).updateChapter(chapterId, _outlinePayload(name, order));

  /// `deleteChapter(chapterId)`
  Future<void> deleteChapter(Object chapterId) async {
    await ref.read(courseServiceProvider).deleteChapter({
      'institute_id': _requireInstitute(),
      'chapter_id': '$chapterId',
    });
    state = state.copyWith(
      chapters: [
        for (final c in state.chapters)
          if ('${c['id']}' != '$chapterId') c,
      ],
    );
  }

  // ── Contents (concepts) ───────────────────────────────────────────────

  /// `createContent(sectionId?, chapterId?)` — multipart from `contentForm`.
  Future<dynamic> createContent([Object? sectionIdParam, Object? chapterIdParam]) async {
    final instituteId = _instituteId?.toString();
    final sectionId = _orStr(sectionIdParam, this.sectionId);
    final chapterId = _orStr(chapterIdParam, this.chapterId);
    final courseId = _idStr(this.courseId);
    final classId = _classId;
    if (instituteId == null || sectionId == null || chapterId == null || courseId == null) {
      throw StateError('Missing institute / course / section / chapter');
    }
    final f = state.contentForm;
    final type = f['type'];
    final fields = <String, dynamic>{
      'institute_id': instituteId,
      'course_id': courseId,
      'section_id': sectionId,
      'chapter_id': chapterId,
      'name': jsFormValue(f['name']),
      'type': jsFormValue(type),
      'order': '${f['order']}',
      'zsl_activity_id': jsFormValue(f['zslactvity']),
      if (jsTruthy(classId)) 'class_id': classId,
    };
    if (type == 'pdf') {
      if (f['file'] == null) throw StateError('Missing PDF file');
      fields['file'] = f['file'];
    } else if (type == 'url') {
      fields['url'] = jsFormValue(f['url']);
    } else if (type == 'html') {
      fields['html_content'] = jsFormValue(f['html_content']);
    }
    final result = await ref.read(courseServiceProvider).createContent(fields);
    await fetchContents(int.tryParse(chapterId) ?? chapterId);
    resetContentForm();
    return result;
  }

  /// `resetContentForm()`
  void resetContentForm() => state = state.copyWith(contentForm: emptyContentForm);

  /// `fetchContents(chapter_id)`
  Future<void> fetchContents(Object chapterId) async {
    final id = _instituteId;
    if (id == null) return;
    final data = await ref.read(courseServiceProvider).getContents(id, chapterId);
    state = state.copyWith(contents: _maps(data));
  }

  /// `updateContent(contentId)` — multipart PUT from `selectedContentDetails`
  /// (chapter = `chapter_id`). Like the web it then resets `contentForm`,
  /// not `selectedContentDetails`.
  Future<dynamic> updateContent(Object contentId) async {
    final instituteId = _instituteId?.toString();
    final chapterId = _idStr(this.chapterId);
    final courseId = _idStr(this.courseId);
    final classId = _classId;
    if (instituteId == null || chapterId == null || courseId == null) {
      throw StateError('Institute ID or Chapter ID missing');
    }
    final d = state.selectedContentDetails;
    final type = d['type'];
    final fields = <String, dynamic>{
      '_method': 'PUT',
      'institute_id': instituteId,
      'chapter_id': chapterId,
      'course_id': courseId,
      'name': jsFormValue(d['name']),
      'type': jsFormValue(type),
      'order': '${d['order']}',
      if (jsTruthy(classId)) 'class_id': classId,
    };
    if (type == 'pdf' && d['file'] != null) {
      fields['file'] = d['file'];
    } else if (type == 'url') {
      fields['url'] = jsFormValue(d['url']);
    } else if (type == 'html') {
      fields['html_content'] = jsFormValue(d['html_content']);
    }
    final result = await ref.read(courseServiceProvider).updateContent(contentId, fields);
    resetContentForm();
    return result;
  }

  /// `deleteContent(contentId)`
  Future<void> deleteContent(Object contentId) async {
    await ref.read(courseServiceProvider).deleteContent({
      'institute_id': _requireInstitute(),
      'content_id': '$contentId',
    });
    state = state.copyWith(
      contents: [
        for (final c in state.contents)
          if ('${c['id']}' != '$contentId') c,
      ],
    );
  }

  // ── ZSL classes / subjects (course edit dialog) ────────────────────────

  /// `res.data || res || []`
  static List<Map<String, dynamic>> _dataOrSelf(dynamic res) {
    final d = asMap(res)?['data'];
    return _maps(jsTruthy(d) ? d : (jsTruthy(res) ? res : const []));
  }

  /// `loadAllClasses()`
  Future<List<Map<String, dynamic>>> loadAllClasses() async {
    final id = _instituteId;
    if (id == null) return const [];
    try {
      final response = await ref.read(zslServiceProvider).getClass(id);
      final all = _dataOrSelf(response);
      state = state.copyWith(allClasses: all);
      return all;
    } catch (_) {
      state = state.copyWith(allClasses: const []);
      rethrow;
    }
  }

  /// `getAllSubjects(instituteId, classId)`
  Future<List<Map<String, dynamic>>> getAllSubjects(Object instituteId, Object classId) async {
    try {
      final res = await ref.read(zslServiceProvider).getAllSubjects(instituteId, classId);
      final all = _dataOrSelf(res);
      state = state.copyWith(allsubject: all);
      return all;
    } catch (_) {
      state = state.copyWith(allsubject: const []);
      rethrow;
    }
  }
}

final coursesControllerProvider = NotifierProvider<CoursesController, CoursesState>(CoursesController.new);
