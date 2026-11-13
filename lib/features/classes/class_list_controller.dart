import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/network/upload_file.dart';
import '../../core/utils/external_link.dart';
import '../../core/utils/json.dart';
import '../../core/utils/pagination.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';
import 'class_list_logic.dart';

/// The classes slice of `useUserStore` used by `classlist.vue`
/// (`institutes`, `classes`, `curriculums`, `batches`, `promoteBatchList`,
/// `instructors`, `classInstructors`, `classInstructorPagination`,
/// `instructorPagination`, `students`, `studentPagination`,
/// `assignedInstructors`, `selectedInstructor`, `selectedStudent`,
/// `selectedBatch`, `searchError`, `selectedStudents`).
///
/// `classDetails` / `batchDetails` / `userInfo` live in [sessionProvider];
/// `courses` (shared with ClassCourseCreate / the course screens) lives in
/// [lmsHandoffProvider] under `'courses'`, and `institutes` is mirrored there.
class ClassListState {
  const ClassListState({
    this.institutes = const [],
    this.classes = const [],
    this.curriculums = const [],
    this.batches = const [],
    this.promoteBatchList = const [],
    this.instructors = const [],
    this.classInstructors = const [],
    this.classInstructorPagination = PageMeta.empty,
    this.instructorPagination = PageMeta.empty,
    this.students = const [],
    this.studentPagination = PageMeta.empty,
    this.assignedInstructors = const [],
    this.selectedInstructor,
    this.selectedStudent,
    this.selectedBatch,
    this.searchError,
    this.selectedStudents = const [],
  });

  /// Classes as the grid shows them (`{ id, year, c_id, students, … }`).
  final List<Json> institutes;
  final List<Json> classes;
  final List<Json> curriculums;
  final List<Json> batches;
  final List<Json> promoteBatchList;

  /// The "attach admin" dropdown (`getInstructorsdropdown`), also written by
  /// `searchInstructors` / `addInstructor` / `attachInstructor` / `attachstudent`.
  final List<dynamic> instructors;
  final List<Json> classInstructors;
  final PageMeta classInstructorPagination;

  /// Never refreshed by this screen (the web's instructor "Next" button reads it).
  final PageMeta instructorPagination;
  final List<dynamic> students;
  final PageMeta studentPagination;
  final List<Json> assignedInstructors;
  final dynamic selectedInstructor;
  final dynamic selectedStudent;
  final dynamic selectedBatch;
  final String? searchError;
  final List<Object?> selectedStudents;

  static const _unset = Object();

  ClassListState copyWith({
    List<Json>? institutes,
    List<Json>? classes,
    List<Json>? curriculums,
    List<Json>? batches,
    List<Json>? promoteBatchList,
    List<dynamic>? instructors,
    List<Json>? classInstructors,
    PageMeta? classInstructorPagination,
    List<dynamic>? students,
    PageMeta? studentPagination,
    List<Json>? assignedInstructors,
    Object? selectedInstructor = _unset,
    Object? selectedStudent = _unset,
    Object? selectedBatch = _unset,
    Object? searchError = _unset,
    List<Object?>? selectedStudents,
  }) =>
      ClassListState(
        institutes: institutes ?? this.institutes,
        classes: classes ?? this.classes,
        curriculums: curriculums ?? this.curriculums,
        batches: batches ?? this.batches,
        promoteBatchList: promoteBatchList ?? this.promoteBatchList,
        instructors: instructors ?? this.instructors,
        classInstructors: classInstructors ?? this.classInstructors,
        classInstructorPagination: classInstructorPagination ?? this.classInstructorPagination,
        instructorPagination: instructorPagination,
        students: students ?? this.students,
        studentPagination: studentPagination ?? this.studentPagination,
        assignedInstructors: assignedInstructors ?? this.assignedInstructors,
        selectedInstructor: identical(selectedInstructor, _unset) ? this.selectedInstructor : selectedInstructor,
        selectedStudent: identical(selectedStudent, _unset) ? this.selectedStudent : selectedStudent,
        selectedBatch: identical(selectedBatch, _unset) ? this.selectedBatch : selectedBatch,
        searchError: identical(searchError, _unset) ? this.searchError : searchError as String?,
        selectedStudents: selectedStudents ?? this.selectedStudents,
      );
}

/// Store actions mapped by `classlist.vue`, ported 1:1.
class ClassListController extends Notifier<ClassListState> {
  @override
  ClassListState build() {
    // `institutes` is read by ClassCourseCreate through the hand-off store.
    listenSelf((prev, next) {
      if (prev == null) return;
      final handoff = ref.read(lmsHandoffProvider.notifier);
      if (!identical(prev.institutes, next.institutes)) handoff.set('institutes', next.institutes);
    });
    return const ClassListState();
  }

  int _batchRequestId = 0;

  SessionState get _session => ref.read(sessionProvider);
  int? get _instituteId => _session.userInfo?.instituteId;

  /// `this.userInfo!.institute_id!.toString()` (throws like the web when missing).
  String get _instituteIdOrThrow {
    final id = _instituteId;
    if (id == null) throw const ApiError('Institute ID not available');
    return '$id';
  }

  /// `classDetails` as the web map (`{ id, name, c_id, courses, … }`).
  Json? get classDetailsMap => _session.classDetails?.toJson();
  int? get _classId => _session.classDetails?.id;
  int? get _batchId => _session.batchDetails?.id;

  List<Json> _maps(Object? list) => [for (final e in asList(list)) ?asMap(e)];

  // ── session setters ─────────────────────────────────────────────────────

  /// `setClassDetails(classInfo)` — any map (the web assigned whole responses).
  void setClassDetails(Object? classInfo) {
    final m = asMap(classInfo);
    ref.read(sessionProvider.notifier).setClassDetails(m == null ? null : IdName.fromJson(m));
  }

  /// `setBatchDetails(batchInfo)`
  void setBatchDetails(Object? batchInfo) {
    final m = asMap(batchInfo);
    ref.read(sessionProvider.notifier).setBatchDetails(m == null ? null : IdName.fromJson(m));
  }

  /// `clearClassDetailsData()`
  void clearClassDetailsData() {
    _batchRequestId++;
    _handoff.set('courses', const []);
    state = state.copyWith(
      batches: const [],
      classInstructors: const [],
      assignedInstructors: const [],
      students: const [],
      classInstructorPagination: PageMeta.empty,
    );
  }

  /// `clearCourseData()`
  void clearCourseData() {
    _handoff.set('courses', const []);
    state = state.copyWith(curriculums: const []);
  }

  /// The store's `courses` (hand-off key `'courses'`).
  List<dynamic> get courses => asList(ref.read(lmsHandoffProvider)['courses']);

  LmsHandoff get _handoff => ref.read(lmsHandoffProvider.notifier);

  /// `this.institutes[index] = { ...this.institutes[index], status }` (toggleClassStatus).
  void patchInstitute(Object? id, Json fields) {
    state = state.copyWith(institutes: [
      for (final i in state.institutes) i['id'] == id ? {...i, ...fields} : i,
    ]);
  }

  // ── classes ─────────────────────────────────────────────────────────────

  /// `fetchCurriculums()`
  Future<void> fetchCurriculums() async {
    final iid = _instituteId;
    if (iid == null) return;
    final data = await ref.read(classServiceProvider).getAllCurriculums(iid);
    state = state.copyWith(curriculums: [
      for (final item in _maps(data))
        {
          'id': item['id'],
          'institute_id': item['institute_id'],
          'name': item['name'],
          'status': orJs(item['status']?.toString().toLowerCase(), 'draft'),
          'created_at': item['created_at'],
        },
    ]);
  }

  /// `getClasses(institute_id_or_filter?, filter?)`
  Future<void> getClasses([Object? instituteIdOrFilter, String? filter]) async {
    Object? instituteId;
    String? finalFilter;
    if (instituteIdOrFilter == 'published') {
      instituteId = _instituteId;
      finalFilter = 'published';
    } else {
      instituteId = orJs(instituteIdOrFilter, _instituteId);
      finalFilter = filter;
    }
    if (!jsTruthy(instituteId)) return;

    final svc = ref.read(classServiceProvider);
    final data = _maps(await svc.getAllClasses(instituteId!));
    final filtered = finalFilter == 'published' ? data.where((c) => c['status'] == 'published').toList() : data;
    final mapped = await Future.wait(filtered.map((item) async {
      final counts = await svc.getClassesCount(instituteId!, item['id']);
      return mapClassItem(item, counts);
    }));
    state = state.copyWith(
      institutes: mapped,
      classes: [for (final m in mapped) {'id': m['id'], 'name': m['year'], 'status': m['status']}],
    );
  }

  /// `createClass(name, curriculumId, status, classLevel)`
  Future<void> createClass(String name, Object curriculumId, String status, int? classLevel) async {
    await ref.read(classServiceProvider).createClass({
      'institute_id': _instituteId ?? 1,
      'name': name,
      'status': status,
      'curriculum_id': curriculumId,
      'class_level': classLevel,
    });
    await getClasses();
  }

  /// `updateClass(id, payload)` — the response replaces `classDetails`.
  Future<dynamic> updateClass(String id, {required String? name, required Object? status, int? classLevel}) async {
    final data = {
      'institute_id': _instituteIdOrThrow,
      'name': name,
      'status': status,
      'class_level': classLevel,
    };
    final response = await ref.read(classServiceProvider).updateClass(id, data);
    setClassDetails(response);
    return response;
  }

  /// `updateClassStatus(id, { status })` — the response replaces `classDetails`.
  Future<dynamic> updateClassStatus(String id, String status) async {
    final response =
        await ref.read(classServiceProvider).updateClassStatus(id, {'institute_id': _instituteIdOrThrow, 'status': status});
    setClassDetails(response);
    return response;
  }

  /// `searchClassWithInstructor(term)`
  Future<void> searchClassWithInstructor(String term) async {
    final iid = _instituteId;
    if (iid == null) return;
    final instituteId = '$iid';
    final instructorId = _session.role == Role.instructor && jsTruthy(_session.instructorId)
        ? '${_session.instructorId}'
        : null;
    final svc = ref.read(classServiceProvider);
    final raw = await svc.searchClassWithInstructor({
      'institute_id': instituteId,
      'term': term,
      'instructor_id': instructorId,
    });
    final mapped = await Future.wait(searchClassRows(raw).map((item) async {
      Object? counts = const <String, dynamic>{};
      if (searchItemNeedsCounts(item)) {
        counts = await svc.getClassesCount(iid, jsNumber(item['id']) ?? item['id']);
      }
      return mapSearchClassItem(item, counts);
    }));
    state = state.copyWith(institutes: mapped);
  }

  /// `fetchClassDetails(classId?)` — ignores stale answers like the web.
  Future<dynamic> fetchClassDetails([Object? classId]) async {
    final instituteId = _instituteIdOrThrow;
    final cid = jsTruthy(classId) ? '$classId' : (_classId != null ? '$_classId' : null);
    if (cid == null) throw const ApiError('Class ID not available');
    final response = await ref
        .read(classServiceProvider)
        .getClassDetails(cid, {'institute_id': instituteId, 'withCourses': 'yes'});
    if (cid != (_classId == null ? null : '$_classId')) return null;
    final m = asMap(response);
    final next = m == null ? response : {...m, 'c_id': m['curricula_id'] ?? m['c_id']};
    setClassDetails(next);
    return next;
  }

  /// `fetchClassCourse()`
  Future<void> fetchClassCourse() async {
    final iid = _instituteId;
    if (iid == null) return;
    final cd = classDetailsMap;
    final curriculumId = orJs(cd?['c_id'], cd?['curricula_id']);
    if (!jsTruthy(curriculumId)) return;
    try {
      final data = await ref.read(classServiceProvider).getClassCourses('$iid', '$curriculumId');
      _handoff.set('courses', data is List ? data : asList(data));
    } catch (_) {
      // console.error in the web.
    }
  }

  /// `attachSelectedCourseToClass(courseId)`
  Future<dynamic> attachSelectedCourseToClass(String courseId) async {
    final iid = _instituteId;
    final cid = _classId;
    if (iid == null || courseId.isEmpty || cid == null) {
      throw const ApiError('Missing institute_id, course_id or class_id');
    }
    final result = await ref
        .read(classServiceProvider)
        .attachSelectedCourseToClass({'institute_id': '$iid', 'course_id': courseId, 'class_id': '$cid'});
    await fetchClassCourse();
    await fetchClassDetails();
    return result;
  }

  // ── batches ─────────────────────────────────────────────────────────────

  /// `getBatches(classId?)` — newer calls win (`batchRequestId`).
  Future<void> getBatches([int? classId]) async {
    final requestId = ++_batchRequestId;
    state = state.copyWith(batches: const []);
    final cid = classId ?? _classId;
    final iid = _instituteId;
    if (cid == null || cid == 0 || iid == null) return;
    final data = await ref.read(batchServiceProvider).getBatches(cid, iid);
    if (requestId != _batchRequestId || iid != _instituteId) return;
    state = state.copyWith(batches: [for (final b in _maps(data)) mapBatch(b)]);
  }

  /// `getPromoteBatches(classId?)`
  Future<void> getPromoteBatches([int? classId]) async {
    final cid = classId ?? _classId;
    final iid = _instituteId;
    if (cid == null || cid == 0 || iid == null) return;
    final data = await ref.read(batchServiceProvider).getBatches(cid, iid);
    state = state.copyWith(promoteBatchList: [for (final b in _maps(data)) mapPromoteBatch(b)]);
  }

  /// `createBatch(name, classId?)`
  Future<void> createBatch(String batchName, [int? classId]) async {
    final cid = classId ?? _classId;
    final iid = _instituteId;
    if (cid == null || cid == 0 || iid == null) return;
    await ref.read(batchServiceProvider).createBatch({'name': batchName, 'institute_id': iid, 'class_id': cid});
    await getBatches(cid);
  }

  /// `fetchBatchesById(batchId)` — errors are logged (→ null) like the web.
  Future<dynamic> fetchBatchesById(Object? batchId) async {
    final iid = _instituteId;
    if (iid == null) throw const ApiError('Institute ID not available');
    try {
      final data = await ref.read(batchServiceProvider).getBatchById(batchId ?? '', iid);
      state = state.copyWith(selectedBatch: data);
      return data;
    } catch (_) {
      return null;
    }
  }

  /// `updateBatch(id, name, status)`
  Future<dynamic> updateBatch(Object? batchId, String? name, String? status) async {
    final iid = _instituteId;
    if (!jsTruthy(batchId) || iid == null || !jsTruthy(name) || !jsTruthy(status)) {
      throw const ApiError('Missing required fields for updating batch');
    }
    final updated = await ref.read(batchServiceProvider).updateBatch(batchId!, {
      'institute_id': '$iid',
      'name': name,
      'status': status!.toLowerCase(),
    });
    state = state.copyWith(selectedBatch: updated);
    return updated;
  }

  /// `deleteBatch(id)`
  Future<dynamic> deleteBatch(String batchId) {
    final iid = _instituteIdOrThrow;
    return ref.read(batchServiceProvider).deleteBatch(batchId, iid);
  }

  /// `searchBatch(term)`
  Future<void> searchBatch(String term) async {
    final iid = _instituteId;
    if (iid == null) {
      state = state.copyWith(searchError: 'Institute ID not available');
      return;
    }
    final cid = _classId;
    if (cid == null) {
      state = state.copyWith(searchError: 'Class ID not available');
      return;
    }
    state = state.copyWith(searchError: null);
    try {
      final raw = await ref.read(batchServiceProvider).searchBatch('$iid', term, '$cid');
      final arr = raw is List ? raw : const [];
      state = state.copyWith(batches: [
        for (final item in arr)
          if (jsTruthy(item) && asMap(item) != null) mapSearchBatch(asMap(item)!),
      ]);
    } catch (e) {
      state = state.copyWith(searchError: e is ApiError ? e.message : 'Failed to search batch');
    }
  }

  // ── instructors ─────────────────────────────────────────────────────────

  /// `searchInstructors(term)` — note: writes the admin dropdown list.
  Future<void> searchInstructors(String term) async {
    final iid = _instituteId;
    if (iid == null) {
      state = state.copyWith(searchError: 'Institute ID not available');
      return;
    }
    final cid = _classId;
    if (cid == null) {
      state = state.copyWith(searchError: 'Class ID not available');
      return;
    }
    state = state.copyWith(searchError: null);
    try {
      final response = await ref.read(instructorServiceProvider).searchInstructors('$iid', term, '$cid');
      state = state.copyWith(instructors: [for (final i in asList(response ?? const [])) ?i]);
    } catch (e) {
      state = state.copyWith(searchError: e is ApiError ? e.message : 'Failed to search instructors');
    }
  }

  /// `getAssignedInstructors(classId?)`
  Future<void> getAssignedInstructors([Object? classId]) async {
    final iid = _instituteId;
    final cid = jsTruthy(classId) ? '$classId' : (_classId == null ? null : '$_classId');
    if (iid == null || cid == null) return;
    final res = await ref.read(instructorServiceProvider).getAssignedInstructors('$iid', cid);
    if (cid != (_classId == null ? null : '$_classId')) return;
    state = state.copyWith(assignedInstructors: [for (final i in _maps(res ?? const [])) mapAssignedInstructor(i)]);
  }

  /// `assignInstructorToAdmin(instructorId)`
  Future<dynamic> assignInstructorToAdmin(String instructorId) {
    final iid = _instituteId;
    final cid = _classId;
    if (iid == null || cid == null || instructorId.isEmpty) {
      throw const ApiError('All parameters are required');
    }
    return ref
        .read(instructorServiceProvider)
        .assignInstructorToAdmin({'institute_id': '$iid', 'class_id': '$cid', 'instructor_id': instructorId});
  }

  /// `deleteClassAdminById(adminId, instituteId, classId)`
  Future<dynamic> deleteClassAdminById(String adminId, String instituteId, String classId) =>
      ref.read(instructorServiceProvider).deleteClassAdmin(adminId, instituteId, classId);

  /// `getInstructors(classId, page?)`
  Future<void> getInstructors(int? classId, [int? page]) async {
    if (classId == null || classId == 0) return;
    final currentPage = page ?? state.classInstructorPagination.currentPage;
    final res = asMap(await ref.read(instructorServiceProvider).getInstructors(classId, currentPage)) ?? const {};
    if (classId != _classId) return;
    state = state.copyWith(
      classInstructors: [for (final i in _maps(res['data'])) withUserFallback(i)],
      classInstructorPagination: PageMeta.fromMap(res),
    );
  }

  /// `getInstructorsdropdown(classId)` — every page; errors are logged.
  Future<void> getInstructorsdropdown(int? classId) async {
    if (classId == null || classId == 0) return;
    state = state.copyWith(instructors: const []);
    var currentPage = 1;
    var lastPage = 1;
    final all = <dynamic>[];
    try {
      do {
        final res = asMap(await ref.read(instructorServiceProvider).getInstructors(classId, currentPage)) ?? const {};
        all.addAll([for (final i in _maps(res['data'])) withUserFallback(i)]);
        lastPage = asInt(res['last_page']) ?? 1;
        currentPage++;
      } while (currentPage <= lastPage);
      state = state.copyWith(instructors: all);
    } catch (_) {}
  }

  /// `addInstructor(payload)` — `POST /user` then `POST /instructor`.
  Future<void> addInstructor({
    required String firstName,
    required String lastName,
    required String email,
    required String countryCode,
    required String phone,
    required String gender,
    required String dob,
    required UploadFile? photo,
    required String password,
    required String designation,
    required String joiningDate,
    required bool enableZoom,
  }) async {
    final svc = ref.read(instructorServiceProvider);
    final res = await svc.createUser(
        firstName, lastName, email, countryCode, phone, gender, dob, photo, password, designation, enableZoom);
    final userId = dig(res, ['data', 'id']);
    if (!jsTruthy(userId)) return;
    final instructorRes = await svc.createInstructor(userId, joiningDate, designation, enableZoom);
    state = state.copyWith(instructors: [...state.instructors, instructorRes]);
  }

  /// `attachInstructor(userId)` — errors are logged.
  Future<void> attachInstructor(Object userId) async {
    try {
      final res = await ref.read(instructorServiceProvider).createInstructor(userId);
      final data = asMap(res)?['data'];
      if (jsTruthy(data)) state = state.copyWith(instructors: [...state.instructors, data]);
    } catch (_) {}
  }

  /// `attachstudent(student_Id)` — the web pushes the answer into
  /// `instructors` too (kept). Errors are logged.
  Future<void> attachstudent(Object studentId) async {
    try {
      final res = await ref.read(studentServiceProvider).attachStudent(studentId);
      final data = asMap(res)?['data'];
      if (jsTruthy(data)) state = state.copyWith(instructors: [...state.instructors, data]);
    } catch (_) {}
  }

  /// `attachInstructorToCurrentClass(instructorId, is_admin)`
  Future<dynamic> attachInstructorToCurrentClass(String instructorId, [bool isAdmin = false]) {
    final iid = _instituteId;
    final cid = _classId;
    if (iid == null) throw const ApiError('Institute ID not available');
    if (cid == null) throw const ApiError('Class ID not selected');
    if (instructorId.isEmpty) throw const ApiError('Instructor ID is required');
    return ref.read(classServiceProvider).attachInstructorToClass({
      'institute_id': '$iid',
      'class_id': '$cid',
      'instructor_id': instructorId,
      'is_admin': isAdmin,
    });
  }

  /// `fetchInstructorById(id)`
  Future<dynamic> fetchInstructorById(Object? instructorId) async {
    if (!jsTruthy(instructorId)) throw const ApiError('Instructor ID is required');
    final instructor = await ref.read(instructorServiceProvider).getInstructorById(instructorId!);
    state = state.copyWith(selectedInstructor: instructor);
    return instructor;
  }

  /// `updateInstructor(id, data)`
  Future<dynamic> updateInstructor(Object? instructorId, Json data) async {
    if (!jsTruthy(instructorId)) throw const ApiError('Instructor id is required');
    final instructor = await ref.read(instructorServiceProvider).updateInstructor(instructorId!, data);
    state = state.copyWith(selectedInstructor: instructor);
    return instructor;
  }

  /// `detachInstructorFromClass(instructorId, classId)`
  Future<dynamic> detachInstructorFromClass(String instructorId, String classId) async {
    final res = await ref.read(classServiceProvider).detachInstructorFromClass({
      'institute_id': _instituteIdOrThrow,
      'class_id': classId,
      'instructor_id': instructorId,
    });
    state = state.copyWith(instructors: [
      for (final i in state.instructors)
        if ('${asMap(i)?['id']}' != instructorId) i,
    ]);
    return res;
  }

  // ── students ────────────────────────────────────────────────────────────

  /// `searchStudents(term)` (batch scoped).
  Future<void> searchStudents(String term) async {
    final iid = _instituteId;
    if (iid == null) {
      state = state.copyWith(searchError: 'Institute ID not available');
      return;
    }
    final bid = _batchId;
    if (bid == null || bid == 0) {
      state = state.copyWith(searchError: 'Batch ID not available');
      return;
    }
    state = state.copyWith(searchError: null);
    try {
      final response = await ref.read(studentServiceProvider).searchStudents('$iid', term, '$bid');
      state = state.copyWith(students: [for (final s in dataOrArray(response)) if (asMap(s) case final m?) mapSearchStudent(m)]);
    } catch (e) {
      state = state.copyWith(searchError: e is ApiError ? e.message : 'Failed to search students');
    }
  }

  /// `getStudents(page = 1, paginate?)`
  Future<void> getStudents([int page = 1, Object? paginate]) async {
    final iid = _instituteId;
    final cid = _classId;
    if (iid == null || iid == 0 || cid == null || cid == 0) return;
    final res = asMap(await ref.read(studentServiceProvider).getStudents({
          'institute_id': iid,
          'class_id': cid,
          'batch_id': _batchId,
          'page': page,
          'paginate': paginate,
        })) ??
        const {};
    state = state.copyWith(
      students: [for (final s in _maps(res['data'])) mapStudent(s)],
      studentPagination: PageMeta.fromMap(res),
    );
  }

  /// `pivotStudents(page = 1)` — unpaginated, active pivots only.
  Future<void> pivotStudents([int page = 1]) async {
    final iid = _instituteId;
    final cid = _classId;
    final bid = _batchId;
    if (iid == null || cid == null || bid == null || bid == 0) return;
    final res = await ref.read(studentServiceProvider).getStudents({
      'institute_id': iid,
      'class_id': cid,
      'batch_id': bid,
      'page': page,
      'paginate': 0,
    });
    final students = pivotStudentList(res, bid);
    state = state.copyWith(
      students: students,
      selectedStudents: [
        for (final id in state.selectedStudents)
          if (students.any((s) => s['id'] == id)) id,
      ],
    );
  }

  /// `getAllStudents()`
  Future<void> getAllStudents() async {
    state = state.copyWith(students: const []);
    final iid = _instituteId;
    final cid = _classId;
    if (iid == null || cid == null) return;
    final res = await ref.read(studentServiceProvider).getStudents({
      'institute_id': iid,
      'class_id': cid,
      'batch_id': _batchId,
      'paginate': 0,
    });
    state = state.copyWith(students: [for (final s in objectValuesWithId(res)) mapAllStudent(s)]);
  }

  /// `addStudent(payload)` — `POST /user`, `POST /student`, then reload.
  Future<void> addStudent({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String confirmpassword,
    required String countryCode,
    required String phone,
    required String gender,
    required String dob,
    required UploadFile? photo,
  }) async {
    final svc = ref.read(studentServiceProvider);
    final res =
        await svc.createUsers(firstName, lastName, email, password, confirmpassword, countryCode, phone, gender, dob, photo);
    final userId = dig(res, ['data', 'id']);
    if (!jsTruthy(userId)) return;
    final studentRes = await svc.createStudent(userId);
    state = state.copyWith(students: [...state.students, studentRes]);
    // Not awaited in the web either.
    getStudents().ignore();
  }

  /// `addStudentFromExistingUser(userId)`
  Future<void> addStudentFromExistingUser(Object userId) async {
    await ref.read(studentServiceProvider).createStudent(userId);
    await getStudents();
  }

  /// `fetchStudentById(id)`
  Future<dynamic> fetchStudentById(Object? studentId) async {
    if (!jsTruthy(studentId)) throw const ApiError('Student ID is required');
    final student = await ref.read(studentServiceProvider).getStudentById(studentId!);
    state = state.copyWith(selectedStudent: student);
    return student;
  }

  /// `updateStudent(id, data)`
  Future<dynamic> updateStudent(Object? studentId, Json data) async {
    if (!jsTruthy(studentId)) throw const ApiError('Student ID is required');
    final result = await ref
        .read(studentServiceProvider)
        .updateStudent(studentId, {'institute_id': _instituteId == null ? '' : '$_instituteId', ...data});
    state = state.copyWith(selectedStudent: result);
    return result;
  }

  /// `detachStudentFromClass(studentId, classId)`
  Future<dynamic> detachStudentFromClass(String studentId, String classId) async {
    final res = await ref.read(classServiceProvider).detachStudentFromClass({
      'institute_id': _instituteIdOrThrow,
      'class_id': classId,
      'student_id': studentId,
    });
    state = state.copyWith(students: [
      for (final s in state.students)
        if ('${asMap(s)?['id']}' != studentId) s,
    ]);
    return res;
  }

  /// `transferStudents(from, to, ids)`
  Future<dynamic> transferStudents(Object fromBatchId, Object toBatchId, List<Object?> studentIds) async {
    final iid = _instituteId;
    if (iid == null) throw const ApiError('Institute ID not available');
    final res = await ref.read(studentServiceProvider).transferStudents(iid, fromBatchId, toBatchId, studentIds);
    await pivotStudents();
    return res;
  }

  /// `promoteStudents(from, to, ids)`
  Future<dynamic> promoteStudents(Object fromBatchId, Object toBatchId, List<Object?> studentIds) async {
    final iid = _instituteId;
    if (iid == null) throw const ApiError('Institute ID not available');
    final res = await ref.read(studentServiceProvider).promoteStudents(iid, fromBatchId, toBatchId, studentIds);
    await pivotStudents();
    return res;
  }

  /// `importStudents(file)` — returns the response body (the web returned the
  /// AxiosResponse and read `res.data.data.broadcast_channel`). Without a
  /// file the web still posted the form (`file: null`); the server's
  /// validation error is toasted by the API client.
  Future<dynamic> importStudents(UploadFile? file) {
    final iid = jsTruthy(_instituteId) ? _instituteId! : '';
    final bid = jsTruthy(_batchId) ? _batchId! : '';
    if (file == null) {
      return ref
          .read(apiClientProvider)
          .postMultipart('/student/import', {'institute_id': '$iid', 'batch_id': '$bid', 'file': 'null'});
    }
    return ref.read(studentServiceProvider).importStudents(iid, bid, file);
  }

  /// `downloadTemplate()` — opens the template site.
  Future<void> downloadTemplate() async {
    await openExternal('https://new-elab-e4akcrhfetbfdkh0.centralindia-01.azurewebsites.net');
  }

  /// `getQuizSysCards` (called from the page through `studentService`).
  Future<dynamic> getQuizSysCards(Json payload) => ref.read(studentServiceProvider).getQuizSysCards(payload);

  // ── user search ─────────────────────────────────────────────────────────

  /// `searchByUser(term)`
  Future<dynamic> searchByUser(String term) => ref.read(userServiceProvider).searchByUser(term, _instituteId?.toString());

  /// `searchUserByIns(term)`
  Future<dynamic> searchUserByIns(String term) =>
      ref.read(userServiceProvider).searchUserByIns(term, _instituteId?.toString());

  /// `searchUserByStu(term)`
  Future<dynamic> searchUserByStu(String term) =>
      ref.read(userServiceProvider).searchUserByStu(term, _instituteId?.toString());
}

final classListControllerProvider =
    NotifierProvider<ClassListController, ClassListState>(ClassListController.new);
