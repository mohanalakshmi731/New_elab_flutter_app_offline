import 'package:flutter/foundation.dart';

import '../../core/network/api_client.dart' show ApiError;
import '../../data/services/batch_service.dart';
import '../../data/services/class_service.dart';
import '../../data/services/course_service.dart';
import '../../data/services/student_service.dart';
import '../../data/services/zsl_service.dart';
import 'activity_reports_logic.dart';

/// `loadFilters(level)` of ActivityReports.vue.
enum ReportFilterLevel { classLevel, subject, refresh }

/// The service calls the page makes (same names/arguments as the web's
/// `classService` / `batchService` / `courseService` / `zslService` /
/// `studentService`); an interface so the flow can be tested with fakes.
abstract class ActivityReportsApi {
  Future<dynamic> getAllClasses(Object instituteId);
  Future<dynamic> getBatches(Object classId, Object instituteId);
  Future<dynamic> getClassDetails(Object id, Map<String, dynamic> data);
  Future<dynamic> getCourseDetails(Object courseId, Map<String, dynamic> data);
  Future<dynamic> getAllChapters(Object instituteId, Object classId, Object subjectId);
  Future<dynamic> getQuizPerformance(Map<String, dynamic> payload);
  Future<dynamic> getStudents(Map<String, dynamic> params);
}

/// [ActivityReportsApi] backed by the real services.
class ServiceActivityReportsApi implements ActivityReportsApi {
  ServiceActivityReportsApi({
    required this.classService,
    required this.batchService,
    required this.courseService,
    required this.zslService,
    required this.studentService,
  });

  final ClassService classService;
  final BatchService batchService;
  final CourseService courseService;
  final ZslService zslService;
  final StudentService studentService;

  @override
  Future<dynamic> getAllClasses(Object instituteId) => classService.getAllClasses(instituteId);

  @override
  Future<dynamic> getBatches(Object classId, Object instituteId) =>
      batchService.getBatches(classId, instituteId);

  @override
  Future<dynamic> getClassDetails(Object id, Map<String, dynamic> data) =>
      classService.getClassDetails(id, data);

  @override
  Future<dynamic> getCourseDetails(Object courseId, Map<String, dynamic> data) =>
      courseService.getCourseDetails(courseId, data);

  @override
  Future<dynamic> getAllChapters(Object instituteId, Object classId, Object subjectId) =>
      zslService.getAllChapters(instituteId, classId, subjectId);

  @override
  Future<dynamic> getQuizPerformance(Map<String, dynamic> payload) =>
      zslService.getQuizPerformance(payload);

  @override
  Future<dynamic> getStudents(Map<String, dynamic> params) => studentService.getStudents(params);
}

/// `String(useUserStore().userInfo?.institute_id || '')`
String reportInstituteId(int? instituteId) =>
    instituteId == null || instituteId == 0 ? '' : '$instituteId';

/// The component state (`data()`), computed values and methods of
/// ActivityReports.vue. Owned by the page; [dispose] plays `beforeUnmount`
/// (bumps both request ids so late responses are dropped).
///
/// The Vue watchers on the four selects only act while `updatingFilters`
/// is false, i.e. on user input — the `select*` methods run them. Values set
/// by the fetches themselves never trigger a reload (on the web the
/// watchers flush while `updatingFilters` is still true).
class ActivityReportsController extends ChangeNotifier {
  ActivityReportsController({required this.api, required String Function() instituteId})
      : _instituteIdOf = instituteId;

  final ActivityReportsApi api;
  final String Function() _instituteIdOf;
  bool _disposed = false;

  // ── UI state ──
  bool isLoading = false;
  bool isRefreshing = false;
  String errorMessage = '';
  int scoreRequestId = 0;
  int filterRequestId = 0;
  bool updatingFilters = false;

  // ── filters ──
  String selectedClass = '';
  String selectedBatch = '';
  String selectedSubject = '';
  String selectedChapter = '';

  // ── data ──
  List<ReportClassOption> classes = [];
  List<ReportBatchOption> batches = [];
  List<ReportSubjectOption> subjects = [];
  List<ReportChapterOption> chapters = [];
  List<ReportActivity> activities = [];
  List<ReportStudent> students = [];

  // ── computed ──

  String get instituteId => _instituteIdOf();

  bool get hasActiveFilters =>
      hasActiveReportFilters(selectedClass, selectedBatch, selectedSubject, selectedChapter);

  List<ReportBatchOption> get filteredBatches => filterBatches(batches, selectedClass);
  List<ReportSubjectOption> get filteredSubjects => filterSubjects(subjects, selectedClass);
  List<ReportChapterOption> get filteredChapters => filterChapters(chapters, selectedSubject);
  List<ReportActivity> get displayedActivities => displayReportActivities(activities, selectedChapter);
  List<ReportStudent> get displayedStudents => displayReportStudents(students, selectedBatch);

  String get selectedClassName =>
      selectedOptionName(selectedClass, 'All Classes', classes, (c) => c.id, (c) => c.name);
  String get selectedBatchName =>
      selectedOptionName(selectedBatch, 'All Batches', batches, (b) => b.id, (b) => b.name);
  String get selectedSubjectName =>
      selectedOptionName(selectedSubject, 'All Subjects', subjects, (s) => s.id, (s) => s.name);
  String get selectedChapterName =>
      selectedOptionName(selectedChapter, 'All Chapters', chapters, (c) => c.id, (c) => c.name);

  // ── watchers (user input) ──

  void selectClass(String value) {
    if (value == selectedClass) return;
    selectedClass = value;
    _notify();
    if (!updatingFilters && selectedClass.isNotEmpty) loadFilters(ReportFilterLevel.classLevel);
  }

  void selectBatch(String value) {
    if (value == selectedBatch) return;
    selectedBatch = value;
    _notify();
    if (!updatingFilters) fetchScores();
  }

  void selectSubject(String value) {
    if (value == selectedSubject) return;
    selectedSubject = value;
    _notify();
    if (!updatingFilters && selectedSubject.isNotEmpty) loadFilters(ReportFilterLevel.subject);
  }

  void selectChapter(String value) {
    if (value == selectedChapter) return;
    selectedChapter = value;
    _notify();
    if (!updatingFilters) fetchScores();
  }

  /// `watch: instituteId()`
  void onInstituteChanged() {
    clearFilters();
    refreshData();
  }

  // ── methods ──

  /// Clear means: do not select "All" — the report disappears until the
  /// teacher selects the filters again. The class list is kept.
  void clearFilters() {
    filterRequestId++;
    scoreRequestId++;
    updatingFilters = false;
    isLoading = false;
    errorMessage = '';
    activities = [];
    students = [];
    batches = [];
    subjects = [];
    chapters = [];
    selectedClass = '';
    selectedBatch = '';
    selectedSubject = '';
    selectedChapter = '';
    _notify();
  }

  Future<void> refreshData() async {
    isRefreshing = true;
    _notify();
    try {
      await loadFilters(ReportFilterLevel.refresh);
    } finally {
      isRefreshing = false;
      _notify();
    }
  }

  Future<void> fetchClasses() async {
    final requestId = filterRequestId;
    final instituteId = this.instituteId;
    if (instituteId.isEmpty) return;

    final response = await api.getAllClasses(jsNumberOf(instituteId));
    if (requestId != filterRequestId) return;
    final rows = listOrDataList(response);
    classes = rows.isNotEmpty ? mapReportClasses(rows) : [];
    selectedClass =
        reconcileSelection(selectedClass, [for (final c in classes) c.id], keepAllWhenEmpty: false);
    _notify();
  }

  Future<void> fetchBatches() async {
    final requestId = filterRequestId;
    final instituteId = this.instituteId;
    if (instituteId.isEmpty || selectedClass.isEmpty) return;

    final List<dynamic> rows;
    if (selectedClass == 'all') {
      // Batches of every available class.
      final results = await Future.wait(
        [for (final c in classes) api.getBatches(jsNumberOf(c.id), jsNumberOf(instituteId))],
        eagerError: true,
      );
      rows = flatMapListOrData(results);
    } else {
      final res = await api.getBatches(jsNumberOf(selectedClass), jsNumberOf(instituteId));
      rows = listOrDataList(res);
    }

    if (requestId != filterRequestId) return;
    batches = rows.isNotEmpty ? mapReportBatches(rows, selectedClass) : [];
    selectedBatch = reconcileSelection(selectedBatch, [for (final b in batches) b.id]);
    _notify();
  }

  Future<void> fetchSubjects() async {
    final requestId = filterRequestId;
    final instituteId = this.instituteId;
    if (instituteId.isEmpty || selectedClass.isEmpty) return;

    final selectedClasses =
        selectedClass == 'all' ? classes : classes.where((c) => c.id == selectedClass).toList();
    final perClass = await Future.wait(
      [
        for (final item in selectedClasses)
          () async {
            final response = await api.getClassDetails(item.id, {
              'institute_id': instituteId,
              'withCourses': 'yes',
            });
            final courses = jsOr(jsProp(response, 'courses'), const <dynamic>[]);
            return Future.wait(
              [
                if (courses is List)
                  for (final course in courses)
                    () async {
                      final details = courseNeedsDetails(course)
                          ? await api.getCourseDetails(
                              courseDetailsId(course), {'institute_id': instituteId})
                          : course;
                      return mergeCourseDetails(course, details, item.id);
                    }(),
              ],
              eagerError: true,
            );
          }(),
      ],
      eagerError: true,
    );
    final coursesList = [for (final list in perClass) ...list];

    if (requestId != filterRequestId) return;
    subjects = coursesList.isNotEmpty ? mapReportSubjects(coursesList) : [];
    selectedSubject = reconcileSelection(selectedSubject, [for (final s in subjects) s.id]);
    _notify();
  }

  Future<void> fetchChapters() async {
    final requestId = filterRequestId;
    final instituteId = this.instituteId;
    if (instituteId.isEmpty || selectedClass.isEmpty || selectedSubject.isEmpty) return;

    final targets = selectedSubject == 'all'
        ? subjects.where((s) => s.hasZslMapping).toList()
        : subjects.where((s) => s.id == selectedSubject).toList();
    final lists = await Future.wait(
      [
        for (final subject in targets)
          () async {
            if (!subject.hasZslMapping) throw const ApiError(missingMappingMessage);
            final response =
                await api.getAllChapters(instituteId, subject.zslClassId, subject.zslSubjectId);
            final chapters = chapterPayload(response);
            if (chapters is! List) throw const ApiError(unreadableChaptersMessage);
            return tagChapters(chapters, subject.id);
          }(),
      ],
      eagerError: true,
    );
    final chapterList = [for (final list in lists) ...list];

    if (requestId != filterRequestId) return;
    chapters = chapterList.isNotEmpty ? mapReportChapters(chapterList) : [];
    selectedChapter = reconcileSelection(selectedChapter, [for (final c in chapters) c.id]);
    _notify();
  }

  Future<void> loadFilters(ReportFilterLevel level) async {
    final requestId = ++filterRequestId;
    scoreRequestId++;
    updatingFilters = true;
    isLoading = true;
    errorMessage = '';
    activities = [];
    students = [];
    _notify();
    try {
      if (instituteId.isEmpty) throw const ApiError(instituteRequiredMessage);
      if (level == ReportFilterLevel.refresh) await fetchClasses();
      if (requestId != filterRequestId) return;
      if (level != ReportFilterLevel.subject) {
        if (level == ReportFilterLevel.classLevel) {
          selectedBatch = '';
          selectedSubject = '';
        }
        batches = [];
        subjects = [];
        _notify();
        // Promise.allSettled: both run to the end, then the first failure
        // (batches before subjects) is raised.
        final failures = await Future.wait([
          for (final f in [fetchBatches(), fetchSubjects()])
            f.then<Object?>((_) => null, onError: (Object e) => e),
        ]);
        for (final failure in failures) {
          if (failure != null) throw failure;
        }
      }
      if (requestId != filterRequestId) return;
      if (level != ReportFilterLevel.refresh) selectedChapter = '';
      chapters = [];
      _notify();
      await fetchChapters();
      if (requestId != filterRequestId) return;
      await fetchScores();
    } catch (error) {
      if (requestId == filterRequestId) errorMessage = filterErrorMessage(error);
    } finally {
      if (requestId == filterRequestId) {
        updatingFilters = false;
        isLoading = false;
      }
      _notify();
    }
  }

  Future<List<ReportStudent>> fetchInstituteStudents() async {
    final instituteId = this.instituteId;
    if (instituteId.isEmpty) throw const ApiError('An institute is required to load students.');
    final classIds = selectedClass == 'all' ? [for (final c in classes) c.id] : [selectedClass];
    final batchId = selectedBatch == 'all' ? null : selectedBatch;
    final results = await Future.wait(
      [
        for (final classId in classIds.where((id) => id.isNotEmpty))
          () async {
            final rows = <dynamic>[];
            var page = 1;
            num lastPage = 1;
            do {
              final response = await api.getStudents({
                'institute_id': instituteId,
                'class_id': classId,
                if (batchId != null && batchId.isNotEmpty) 'batch_id': batchId,
                'page': page,
              });
              rows.addAll(studentPageRows(response));
              lastPage = studentLastPage(response);
              page++;
            } while (page <= lastPage);
            return rows;
          }(),
      ],
      eagerError: true,
    );
    return mapInstituteStudents([for (final rows in results) ...rows], instituteId, batchId);
  }

  Future<void> fetchScores() async {
    final requestId = ++scoreRequestId;
    final instituteId = this.instituteId;
    activities = [];
    students = [];
    errorMessage = '';
    if (instituteId.isEmpty || !hasActiveFilters) {
      isLoading = false;
      _notify();
      return;
    }
    isLoading = true;
    _notify();
    try {
      final payloads = quizPerformancePayloads(
        instituteId: instituteId,
        selectedClass: selectedClass,
        selectedSubject: selectedSubject,
        selectedChapter: selectedChapter,
        subjects: subjects,
        chapters: chapters,
      );
      final results = await Future.wait<Object?>([
        Future.wait([for (final p in payloads) api.getQuizPerformance(p)], eagerError: true),
        fetchInstituteStudents(),
      ], eagerError: true);
      final merged = mergeQuizResponses(results[0] as List<dynamic>);
      final students = results[1] as List<ReportStudent>;
      if (requestId != scoreRequestId || instituteId != this.instituteId) return;
      activities = mapReportActivities(merged.activities);
      this.students = applyReportScores(students, merged.students, activities);
    } catch (error) {
      if (requestId == scoreRequestId) errorMessage = scoreErrorMessage(error);
    } finally {
      if (requestId == scoreRequestId) isLoading = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    scoreRequestId++;
    filterRequestId++;
    _disposed = true;
    super.dispose();
  }
}
