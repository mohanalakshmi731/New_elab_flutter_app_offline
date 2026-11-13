import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/json.dart';
import '../../core/utils/pagination.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';
import 'course_create_logic.dart';

/// The `useUserStore` slice `coursecreate.vue` maps: `courseForm`,
/// `curriculums`, `instructors` (+ `instructorPagination`), `allClasses`,
/// `allsubject`.
class CourseCreateState {
  const CourseCreateState({
    this.courseForm = const {},
    this.curriculums = const [],
    this.instructors = const [],
    this.instructorPagination = PageMeta.empty,
    this.allClasses = const [],
    this.allsubject = const [],
  });

  /// Keys as in the store: institute_id, curriculum_id, instructor_id, title,
  /// allclass, subject_id, description, short_name, course_code, image
  /// (`UploadFile?`), status, is_math_zoro, zone.
  final Map<String, dynamic> courseForm;
  final List<Map<String, dynamic>> curriculums;
  final List<Map<String, dynamic>> instructors;
  final PageMeta instructorPagination;
  final List<Map<String, dynamic>> allClasses;
  final List<Map<String, dynamic>> allsubject;

  CourseCreateState copyWith({
    Map<String, dynamic>? courseForm,
    List<Map<String, dynamic>>? curriculums,
    List<Map<String, dynamic>>? instructors,
    PageMeta? instructorPagination,
    List<Map<String, dynamic>>? allClasses,
    List<Map<String, dynamic>>? allsubject,
  }) => CourseCreateState(
    courseForm: courseForm ?? this.courseForm,
    curriculums: curriculums ?? this.curriculums,
    instructors: instructors ?? this.instructors,
    instructorPagination: instructorPagination ?? this.instructorPagination,
    allClasses: allClasses ?? this.allClasses,
    allsubject: allsubject ?? this.allsubject,
  );
}

/// Store actions used by `coursecreate.vue`, ported 1:1.
class CourseCreateController extends Notifier<CourseCreateState> {
  @override
  CourseCreateState build() => CourseCreateState(
    courseForm: {
      ...emptyCourseForm(),
      // The store's initial courseForm has status `published`.
      'status': 'published',
    },
  );

  int? get _instituteId => ref.read(sessionProvider).userInfo?.instituteId;

  /// `this.courseForm.x = …`
  void patchCourseForm(Map<String, dynamic> fields) =>
      state = state.copyWith(courseForm: {...state.courseForm, ...fields});

  /// `resetCourseForm()`
  void resetCourseForm() => state = state.copyWith(courseForm: emptyCourseForm());

  /// `fetchCurriculums()`
  Future<void> fetchCurriculums() async {
    final instituteId = _instituteId;
    if (instituteId == null || instituteId == 0) return;
    final data = await ref.read(classServiceProvider).getAllCurriculums(instituteId);
    state = state.copyWith(curriculums: mapCurriculums(data));
  }

  /// `getAllInstructors(page?)`
  Future<void> getAllInstructors([int? page]) async {
    final currentPage = page ?? state.instructorPagination.currentPage;
    final res = await ref.read(instructorServiceProvider).getallInstructors(currentPage);
    state = state.copyWith(instructors: mapInstructors(res), instructorPagination: instructorPageMeta(res));
  }

  /// `loadAllClasses()` — ZSL classes of the institute (`[]` and rethrow on
  /// failure).
  Future<List<Map<String, dynamic>>> loadAllClasses() async {
    final instituteId = _instituteId;
    if (instituteId == null || instituteId == 0) return const [];
    try {
      final response = await ref.read(zslServiceProvider).getClass(instituteId);
      final classes = dataOrSelfList(response);
      state = state.copyWith(allClasses: classes);
      return classes;
    } catch (_) {
      state = state.copyWith(allClasses: const []);
      rethrow;
    }
  }

  /// `getAllSubjects(instituteId, classId)`
  Future<List<Map<String, dynamic>>> getAllSubjects(Object instituteId, Object classId) async {
    try {
      final res = await ref.read(zslServiceProvider).getAllSubjects(instituteId, classId);
      final subjects = dataOrSelfList(res);
      state = state.copyWith(allsubject: subjects);
      return subjects;
    } catch (_) {
      state = state.copyWith(allsubject: const []);
      rethrow;
    }
  }

  /// `createCourse(classid?)` — multipart `POST /course` from `courseForm`.
  /// Stores the new id as the store's `course_id` (lmsHandoff) and resets the
  /// form when the API answers "Course created successfully".
  Future<bool> createCourse([String? classId]) async {
    final instituteId = _instituteId?.toString() ?? '';
    final form = {...state.courseForm, 'institute_id': instituteId};
    state = state.copyWith(courseForm: form);

    final response = await ref
        .read(courseServiceProvider)
        .createCourse(buildCreateCourseData(form, instituteId: instituteId, classId: classId));

    final newId = dig(response, ['data', 'id']);
    if (newId != null && newId != 0 && newId != '') {
      // `setCourseId(response.data.id)`
      ref.read(lmsHandoffProvider.notifier).set('course_id', asInt(newId) ?? newId);
    }
    if (isCourseCreated(response)) {
      state = state.copyWith(courseForm: createdCourseForm());
      return true;
    }
    return false;
  }
}

final courseCreateControllerProvider = NotifierProvider<CourseCreateController, CourseCreateState>(
  CourseCreateController.new,
);
