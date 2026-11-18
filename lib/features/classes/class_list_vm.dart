import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/upload_file.dart';
import '../../core/utils/external_link.dart';
import '../../core/utils/files.dart';
import '../../core/utils/json.dart';
import '../../core/utils/pagination.dart';
import '../../core/utils/toast.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../common/lms_handoff.dart';
import '../common/lookups.dart';
import '../courses/courses_controller.dart';
import 'class_list_controller.dart';
import 'class_list_logic.dart';
import 'quizsys_pdf.dart';

/// Every `v-model:open` dialog of `classlist.vue`.
enum ClassDialog {
  promote,
  transfer,
  deleteTarget,
  createClass,
  updateClass,
  skill,
  editBatch,
  instructor,
  updateInstructor,
  createStudent,
  updateStudent,
  phone,
  detachStudent,
  detachInstructor,
  adminDelete,
  deleteBatch,
  updateBatch,
}

/// `newInstructor` (shared by the Add / Update Instructor dialogs).
class InstructorForm {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final phone = TextEditingController();
  final password = TextEditingController();
  final designation = TextEditingController();
  String countryCode = '91';
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool status = false;
  bool enableZoom = false;
  bool isLabAdmin = false;
  String gender = '';
  String dob = '';

  /// An [UploadFile] when picked; the update dialog stores the user's photo URL.
  Object? photo;
  String joiningDate = '';

  /// `this.newInstructor = { … }`
  void assign({
    String firstName = '',
    String lastName = '',
    String email = '',
    String countryCode = '91',
    String phone = '',
    String password = '',
    bool status = false,
    bool enableZoom = false,
    bool isLabAdmin = false,
    String gender = '',
    String dob = '',
    Object? photo,
    String joiningDate = '',
    String designation = '',
  }) {
    this.firstName.text = firstName;
    this.lastName.text = lastName;
    this.email.text = email;
    this.countryCode = countryCode;
    this.phone.text = phone;
    this.password.text = password;
    showPassword = false;
    showConfirmPassword = false;
    this.status = status;
    this.enableZoom = enableZoom;
    this.isLabAdmin = isLabAdmin;
    this.gender = gender;
    this.dob = dob;
    this.photo = photo;
    this.joiningDate = joiningDate;
    this.designation.text = designation;
  }

  void dispose() {
    for (final c in [
      firstName,
      lastName,
      email,
      phone,
      password,
      designation,
    ]) {
      c.dispose();
    }
  }
}

/// `newStudent` (shared by the Add / Update Student dialogs).
class StudentForm {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final confirmpassword = TextEditingController();
  final phone = TextEditingController();
  String countryCode = '91';
  String gender = '';
  String dob = '';
  UploadFile? photo;

  void reset() {
    for (final c in [
      firstName,
      lastName,
      email,
      password,
      confirmpassword,
      phone,
    ]) {
      c.text = '';
    }
    countryCode = '91';
    gender = '';
    dob = '';
    photo = null;
  }

  void dispose() {
    for (final c in [
      firstName,
      lastName,
      email,
      password,
      confirmpassword,
      phone,
    ]) {
      c.dispose();
    }
  }
}

/// `foundUser` / `foundStudent`: `{ id, full_name, email }`.
class FoundUser {
  const FoundUser({this.id, this.fullName = '', this.email = ''});
  final Object? id;
  final String fullName;
  final String email;
}

/// A Vue `watch` on a data field: changes are compared and handled after the
/// current synchronous code (`flush: 'pre'` runs before the next render).
class _Watcher<T> {
  _Watcher(this._read, this._onChange) : _last = _read();
  final T Function() _read;
  final void Function(T value) _onChange;
  T _last;
  bool _scheduled = false;

  void poke() {
    if (_scheduled) return;
    _scheduled = true;
    scheduleMicrotask(() {
      _scheduled = false;
      final v = _read();
      if (v == _last) return;
      _last = v;
      _onChange(v);
    });
  }
}

/// The component state (`data()`), computed props, watchers and methods of
/// `classlist.vue`. Owned by the page's State; the page and every dialog
/// listen to it, so the dialogs (separate routes) share the same fields the
/// way the template does.
class ClassListVm extends ChangeNotifier {
  ClassListVm(this._container) {
    _subs.add(_container.listen(classListControllerProvider, (_, _) => _n()));
    _subs.add(_container.listen(sessionProvider, (_, _) => _n()));
    _subs.add(_container.listen(lmsHandoffProvider, (_, _) => _n()));

    _wSearchClass = _Watcher(() => searchQueryClass.text, (v) {
      if (v.trim().isEmpty) run(resetClass);
    });
    _wSearchBatch = _Watcher(() => searchQueryBatch.text, (v) {
      if (v.trim().isEmpty) run(resetBatch);
    });
    _wSearchStudent = _Watcher(() => searchQueryStudent.text, (v) {
      if (v.trim().isEmpty) run(studentsearchreset);
    });
    _wSearchInstructor = _Watcher(() => searchQueryInstructor.text, (v) {
      if (v.trim().isEmpty) run(resetInstructor);
    });
    searchQueryClass.addListener(_wSearchClass.poke);
    searchQueryBatch.addListener(_wSearchBatch.poke);
    searchQueryStudent.addListener(_wSearchStudent.poke);
    searchQueryInstructor.addListener(_wSearchInstructor.poke);

    _wBulk = _Watcher(() => bulkAction, (v) => run(() => _onBulkAction(v)));
    _wActiveTab = _Watcher(() => activeTab, (v) => run(() => _onActiveTab(v)));
    _wLmsTab = _Watcher(() => currentLmsTab, (v) => run(() => _onLmsTab(v)));
    _wStudentModal = _Watcher(() => isOpen(ClassDialog.createStudent), (v) {
      if (!v) resetStudentDialog();
    });
    _wInstructorModal = _Watcher(() => isOpen(ClassDialog.instructor), (v) {
      if (!v) resetInstructorDialog();
    });

    // Store / session watchers (immediate ones run once now).
    _wAssigned = _Watcher(
      () => s.assignedInstructors,
      (v) => _set(() => adminCount = v.length),
    );
    _wInstrPage = _Watcher(
      () => s.classInstructorPagination,
      (v) => _set(() => instructorCount = v.total),
    );
    _wClassDetails = _Watcher(
      () => session.classDetails,
      (_) => _set(() => courseCount = _coursesLength()),
    );
    _wCurriculum = _Watcher(() => classDetails?['c_id'], (v) {
      if (jsTruthy(v) && jsTruthy(session.userInfo?.instituteId)) {
        _set(() => isLoading = true);
        store.fetchClassCourse().whenComplete(
          () => _set(() => isLoading = false),
        );
      }
    });
    adminCount = s.assignedInstructors.length;
    instructorCount = s.classInstructorPagination.total;
    courseCount = _coursesLength();
    _subs.add(
      _container.listen(classListControllerProvider, (_, _) {
        _wAssigned.poke();
        _wInstrPage.poke();
      }),
    );
    _subs.add(
      _container.listen(sessionProvider, (_, _) {
        _wClassDetails.poke();
        _wCurriculum.poke();
      }),
    );

    for (final c in [
      searchQuery,
      globalQuery,
      studentQuery,
      studentGlobalQuery,
    ]) {
      c.addListener(_n);
    }
  }

  final ProviderContainer _container;
  final List<ProviderSubscription<dynamic>> _subs = [];
  final List<StreamSubscription<dynamic>> _echoSubs = [];
  final List<String> _echoChannels = [];
  Timer? _copiedTimer;
  bool _disposed = false;

  late final _Watcher<String> _wSearchClass;
  late final _Watcher<String> _wSearchBatch;
  late final _Watcher<String> _wSearchStudent;
  late final _Watcher<String> _wSearchInstructor;
  late final _Watcher<String> _wBulk;
  late final _Watcher<String> _wActiveTab;
  late final _Watcher<String> _wLmsTab;
  late final _Watcher<bool> _wStudentModal;
  late final _Watcher<bool> _wInstructorModal;
  late final _Watcher<List<Json>> _wAssigned;
  late final _Watcher<PageMeta> _wInstrPage;
  late final _Watcher<IdName?> _wClassDetails;
  late final _Watcher<Object?> _wCurriculum;

  /// Shows `window.alert(message)`; set by the page.
  Future<void> Function(String message) alert = (_) async {};

  /// Shows `window.prompt(message, initial)`; set by the page.
  Future<String?> Function(String message, String initial) prompt =
      (_, _) async => null;

  // ── store / session access ───────────────────────────────────────────────

  ClassListController get store =>
      _container.read(classListControllerProvider.notifier);
  ClassListState get s => _container.read(classListControllerProvider);
  SessionState get session => _container.read(sessionProvider);

  /// `classDetails` as the web object (null when unset).
  Json? get classDetails => session.classDetails?.toJson();
  int? get classId => session.classDetails?.id;
  bool get hasClass => classId != null && classId != 0;

  int _coursesLength() {
    final c = classDetails?['courses'];
    return c is List ? c.length : 0;
  }

  // ── computed ──────────────────────────────────────────────────────────────

  String get role => session.role;
  bool get isAdminOrInstitute => role == Role.institute || role == Role.admin;
  bool get canManageClass =>
      role == Role.institute || role == Role.admin || isClassAdmin;
  bool get showAdminsTab => role != Role.instructor && canManageClass;
  bool get isExistingUser => jsTruthy(foundUser.id);
  bool get isExistingStudent => jsTruthy(foundStudent.id);

  /// `studentStatusString` (get/set on `selectedStudent.status`).
  String get studentStatusString =>
      jsTruthy(selectedStudent['status']) ? 'true' : 'false';
  set studentStatusString(String v) =>
      _set(() => selectedStudent = {...selectedStudent, 'status': v == 'true'});

  /// `statusString` (get/set on `newInstructor.status`).
  String get statusString => newInstructor.status ? 'true' : 'false';
  set statusString(String v) => _set(() => newInstructor.status = v == 'true');

  // ── data() ────────────────────────────────────────────────────────────────

  bool isCourseExpanded = false;
  String currentLmsTab = 'classes';
  final String courseActiveTab = 'curriculum';
  bool isCreateBtnLoading = false;
  bool isClassAdmin = false;
  Json? detachInstructorTarget;
  Json? detachStudentTarget;
  List<Object?> transferStudents = [];
  Object? transferTargetBatch;
  List<Json> transferBatchList = [];
  List<Json> transferClassList = [];
  bool isImportStarted = false;
  bool isQuizSysLaunching = false;
  bool isQuizSysCardsLoading = false;
  List<int> quizSysGeneratingStudentIds = [];
  List<Json> quizSysCards = [];
  bool showQuizSysCardList = false;
  bool importCompleted = false;
  List<Json> importRows = [];
  UploadFile? selectedFile;
  List<Object?> promoteStudents = [];
  String bulkAction = '';
  int studentStep = 1;
  bool isStudentSearchingGlobal = false;
  bool showStudentGlobalResults = false;
  final studentGlobalQuery = TextEditingController();
  List<SearchHit> studentGlobalResults = [];
  int currentStep = 1;
  bool isSearchingGlobal = false;
  bool showGlobalResults = false;
  final globalQuery = TextEditingController();
  List<SearchHit> globalResults = [];
  final studentQuery = TextEditingController();
  bool isStudentSearching = false;
  bool showStudentResults = false;
  List<SearchHit> studentResults = [];
  FoundUser foundStudent = const FoundUser();
  final searchQuery = TextEditingController();
  bool isSearching = false;
  bool showResults = false;
  List<SearchHit> searchResults = [];
  FoundUser foundUser = const FoundUser();
  String studentSearchQuery = '';
  String activeTab = '';
  Object? selectedInstructorId = '';
  bool isLoading = false;
  final newBatchName = TextEditingController();
  String? batchstatus = '';
  final updateBatchName = TextEditingController();
  String statusbatch = 'all';
  final Set<ClassDialog> _open = {};
  bool showBatchStudentsInline = false;
  final newStudent = StudentForm();
  final newInstructor = InstructorForm();
  final newSkill = TextEditingController();
  final newClassName = TextEditingController();
  Object? classstatus = '';
  int? selectedClassLevel;
  Object? selectedCurriculumId;
  Json editBatch = {'year': '', 'name': ''};
  Json? deleteTarget;
  List<String> skills = [];
  List<Json> dailCodes = [];
  Json selectedStudent = {};
  Json selectedBatch = {};
  int adminCount = 0;
  int instructorCount = 0;
  int courseCount = 0;
  Object? selectedCourseId;
  Object? expandedCourseId;
  Map<Object, dynamic> courseDetails = {};
  Object? openSectionId;
  Object? openChapterId;
  Object? pdfPreviewId;
  Json? adminDeleteTarget;
  Object? batchDeleteTargetId;
  String status = 'all';
  final searchQueryInstructor = TextEditingController();
  final searchQueryStudent = TextEditingController();
  String phoneNumber = '';
  bool copied = false;
  Object? promoteTargetClass;
  Object? promoteTargetBatch;
  List<Json> promoteClassList = [];
  int courseRefreshKey = 0;
  int courseListKey = 0;
  Json? savedSelectedClass;
  final searchQueryClass = TextEditingController();
  final searchQueryBatch = TextEditingController();
  bool isListLoading = false;
  bool showConfirmPassword = false;
  bool showPassword = false;

  // ── plumbing ──────────────────────────────────────────────────────────────

  void _n() {
    if (!_disposed) notifyListeners();
  }

  void _set(void Function() fn) {
    fn();
    _n();
  }

  /// Rebuild after a field was changed in place (v-model).
  void touch() => _n();

  /// Runs an event handler. Errors were already toasted by the API client
  /// (the web only logged its unhandled rejections).
  void run(Future<void> Function() fn) {
    fn().catchError((Object _) {});
  }

  bool get isDisposed => _disposed;

  bool isOpen(ClassDialog d) => _open.contains(d);
  Set<ClassDialog> get openDialogs => Set.unmodifiable(_open);

  /// `isXxxOpen = value`
  void setOpen(ClassDialog d, bool value) {
    final changed = value ? _open.add(d) : _open.remove(d);
    if (!changed) return;
    _wStudentModal.poke();
    _wInstructorModal.poke();
    _n();
  }

  void setLmsTab(String tab) => _set(() {
    currentLmsTab = tab;
    _wLmsTab.poke();
  });

  void setActiveTab(String tab) => _set(() {
    activeTab = tab;
    _wActiveTab.poke();
  });

  void setBulkAction(String value) => _set(() {
    bulkAction = value;
    _wBulk.poke();
  });

  @override
  void dispose() {
    _disposed = true;
    for (final sub in _subs) {
      sub.close();
    }
    for (final sub in _echoSubs) {
      sub.cancel();
    }
    final echo = _container.read(echoClientProvider);
    for (final ch in _echoChannels) {
      echo.leave(ch);
    }
    _copiedTimer?.cancel();
    for (final c in [
      studentGlobalQuery,
      globalQuery,
      studentQuery,
      searchQuery,
      newBatchName,
      updateBatchName,
      newSkill,
      newClassName,
      searchQueryInstructor,
      searchQueryStudent,
      searchQueryClass,
      searchQueryBatch,
    ]) {
      c.dispose();
    }
    newStudent.dispose();
    newInstructor.dispose();
    super.dispose();
  }

  // ── watchers ──────────────────────────────────────────────────────────────

  /// `watch: currentLmsTab`
  Future<void> _onLmsTab(String newTab) async {
    _set(() {
      isCourseExpanded = false;
      showBatchStudentsInline = false;
    });
    if (newTab == 'courses') {
      if (hasClass) savedSelectedClass = {...?classDetails};
      store.clearClassDetailsData();
      store.clearCourseData();
      // The course list keeps its own copy of the store's courses/curriculums.
      _container.read(coursesControllerProvider.notifier).clearCourseData();
      _set(() => courseListKey++);
    } else if (newTab == 'classes') {
      store.clearClassDetailsData();
      _set(() => isLoading = true);
      try {
        await store.getClasses();
        final target = savedSelectedClass ?? classDetails;
        if (jsTruthy(target?['id'])) {
          Json? current;
          for (final c in s.institutes) {
            if (c['id'] == target!['id']) current = c;
          }
          if (current != null) await selectClass(current);
        }
      } catch (_) {
        // console.error in the web.
      } finally {
        _set(() => isLoading = false);
      }
    }
  }

  /// `watch: bulkAction`
  Future<void> _onBulkAction(String newVal) async {
    _set(() => isListLoading = true);
    try {
      if (newVal == 'Bulkpromote' || newVal == 'Bulktransfer')
        await store.pivotStudents();
    } finally {
      _set(() => isListLoading = false);
    }
  }

  /// `watch: activeTab`
  Future<void> _onActiveTab(String newTab) async {
    if (newTab == 'courses') {
      _set(() => isLoading = true);
      try {
        await store.fetchClassCourse();
      } finally {
        _set(() => isLoading = false);
      }
    } else if (newTab == 'admin') {
      if (hasClass && showAdminsTab) {
        _set(() => isLoading = true);
        try {
          await store.getInstructorsdropdown(classId);
        } finally {
          _set(() => isLoading = false);
        }
      }
    }
  }

  /// `watch: '$route.query.tab'`
  void onRouteTab(String? tab) {
    _set(() => isCourseExpanded = false);
    setLmsTab(tab == 'courses' && isAdminOrInstitute ? 'courses' : 'classes');
  }

  // ── lifecycle ─────────────────────────────────────────────────────────────

  /// `mounted()`
  Future<void> mounted(String? routeTab) async {
    setLmsTab(
      routeTab == 'courses' && isAdminOrInstitute ? 'courses' : 'classes',
    );
    _set(() => isLoading = true);
    try {
      setActiveTab(isAdminOrInstitute ? 'admin' : 'batches');
      if (isAdminOrInstitute) await store.fetchCurriculums();
      await loadDailCodes();
      if (role == Role.student || role == Role.instructor) {
        await store.getClasses('published');
      } else {
        await store.getClasses();
      }
    } finally {
      _set(() => isLoading = false);
    }
  }

  void handleCourseExpanded(bool expanded) =>
      _set(() => isCourseExpanded = expanded);

  // ── detach / remove ───────────────────────────────────────────────────────

  void openDetachInstructorDialog(String instructorId, String instructorName) {
    detachInstructorTarget = {'id': instructorId, 'name': instructorName};
    setOpen(ClassDialog.detachInstructor, true);
  }

  Future<void> confirmDetachInstructor() async {
    final target = detachInstructorTarget;
    if (target == null) return;
    _set(() => isLoading = true);
    try {
      await store.detachInstructorFromClass('${target['id']}', '${classId!}');
      await store.getInstructors(classId, 1);
      setOpen(ClassDialog.detachInstructor, false);
      detachInstructorTarget = null;
      await store.getClasses();
    } finally {
      _set(() => isLoading = false);
    }
  }

  void openDetachStudentDialog(String studentId, String studentName) {
    detachStudentTarget = {'id': studentId, 'name': studentName};
    setOpen(ClassDialog.detachStudent, true);
  }

  Future<void> confirmDetachStudent() async {
    final target = detachStudentTarget;
    if (target == null) return;
    _set(() => isLoading = true);
    try {
      await store.detachStudentFromClass('${target['id']}', '${classId!}');
      await store.getStudents();
      setOpen(ClassDialog.detachStudent, false);
      detachStudentTarget = null;
    } finally {
      _set(() => isLoading = false);
    }
  }

  /// `removeStudentFromClass(studentId)` (not wired in the template).
  Future<void> removeStudentFromClass(String studentId) async {
    if (!hasClass) return;
    _set(() => isLoading = true);
    try {
      await store.detachStudentFromClass(studentId, '$classId');
      await store.getStudents();
    } finally {
      _set(() => isLoading = false);
    }
  }

  // ── search result clicks ──────────────────────────────────────────────────

  void globalResultClick(SearchHit u) => _set(() {
    foundUser = FoundUser(id: u.id, fullName: u.fullName, email: u.email);
    showGlobalResults = false;
  });

  void studentGlobalResultClick(SearchHit u) => _set(() {
    foundStudent = FoundUser(id: u.id, fullName: u.fullName, email: u.email);
    showStudentGlobalResults = false;
  });

  Future<void> onNewInstructorPhoto() async {
    final file = await pickImageFile();
    if (file != null) _set(() => newInstructor.photo = file);
  }

  Future<void> onNewStudentPhoto() async {
    final file = await pickImageFile();
    if (file != null) _set(() => newStudent.photo = file);
  }

  // ── batch emails / QuizSys ────────────────────────────────────────────────

  Future<void> emailBatchStudents(Json batch) async {
    store.setBatchDetails(batch);
    _set(() => isListLoading = true);
    try {
      await store.getStudents();
    } finally {
      _set(() => isListLoading = false);
    }
    final emails = activeStudentEmails([for (final x in s.students) ?asMap(x)]);
    if (emails.isEmpty) {
      AppToast.error('No active students found in this batch.');
      return;
    }
    await openExternal(
      'https://mail.google.com/mail/?view=cm&to=${emails.join(',')}',
    );
  }

  Future<void> openQuizSysGenerator() async {
    _set(() => isQuizSysLaunching = true);
    try {
      await loadQuizSysCards(true);
    } finally {
      _set(() => isQuizSysLaunching = false);
    }
  }

  Future<void> openQuizSysCardList() async {
    _set(() => showQuizSysCardList = true);
    await loadQuizSysCards(false);
  }

  bool isQuizSysStudentGenerating(Object? studentId) =>
      quizSysGeneratingStudentIds.contains(jsNumber(studentId));

  Future<void> generateQuizSysCardForStudent(Object? studentId) async {
    if (isQuizSysStudentGenerating(studentId)) return;
    final id = jsNumber(studentId);
    _set(
      () => quizSysGeneratingStudentIds = [...quizSysGeneratingStudentIds, ?id],
    );
    try {
      await loadQuizSysCards(true, [?studentId]);
    } finally {
      _set(
        () => quizSysGeneratingStudentIds = [
          for (final x in quizSysGeneratingStudentIds)
            if (x != id) x,
        ],
      );
    }
  }

  Future<void> loadQuizSysCards([
    bool generateMissing = false,
    List<Object> studentIds = const [],
  ]) async {
    if (!jsTruthy(selectedBatch['id'])) {
      if (generateMissing)
        AppToast.error('Please open a batch before generating QR codes.');
      return;
    }
    final instituteId = session.userInfo?.instituteId;
    if (!jsTruthy(instituteId)) {
      AppToast.error('Institute ID missing.');
      return;
    }
    final currentPage = s.studentPagination.currentPage;
    _set(() => isQuizSysCardsLoading = true);
    try {
      final response = await store.getQuizSysCards({
        'institute_id': instituteId,
        'batch_id': selectedBatch['id'],
        'generate_missing': generateMissing,
        if (studentIds.isNotEmpty) 'student_ids': studentIds,
      });
      _set(
        () => quizSysCards = [
          for (final c in asList(dig(response, ['data', 'cards']))) ?asMap(c),
        ],
      );
      if (generateMissing) {
        final generatedCount =
            jsNumber(orJs(dig(response, ['data', 'generated_count']), 0)) ?? 0;
        if (generatedCount == 0) {
          AppToast.success(
            studentIds.isNotEmpty
                ? 'This student already has a QR card.'
                : 'All active students already have QR cards.',
          );
        }
        await store.getStudents(currentPage);
      }
    } catch (_) {
      // console.error in the web.
    } finally {
      _set(() => isQuizSysCardsLoading = false);
    }
  }

  Future<void> downloadQuizSysCardsPdf() => downloadQuizSysCardsAsPdf(
    quizSysCards,
    '${orJs(selectedBatch['name'], 'batch')}-quizsys-qr-cards.pdf',
  );

  Future<void> downloadQuizSysSingleCardPdf(Json card) =>
      downloadQuizSysCardsAsPdf([
        card,
      ], '${safeFileName(orJs(card['name'], 'student'))}-quizsys-qr-card.pdf');

  Future<void> downloadQuizSysCardsAsPdf([
    List<Json>? cards,
    String filename = 'quizsys-student-cards.pdf',
  ]) async {
    final toDownload = cards ?? quizSysCards;
    if (toDownload.isEmpty) {
      AppToast.error('Generate QR cards before downloading.');
      return;
    }
    try {
      final bytes = await buildQuizSysCardsPdf(toDownload);
      final saved = await saveBytesAs(
        bytes,
        pdfFileName(safeFileName(filename, 'quizsys-student-cards.pdf')),
        mimeType: 'application/pdf',
      );
      if (saved)
        AppToast.success(
          toDownload.length == 1
              ? 'QR card downloaded.'
              : 'QR cards PDF downloaded.',
        );
    } catch (_) {
      AppToast.error('Failed to download QR PDF.');
    }
  }

  // ── promote / transfer ────────────────────────────────────────────────────

  /// Note: `this.promoteBatchList = []` writes a read-only `mapState` getter
  /// in the web (a no-op), so the previous target batches stay listed.
  void openSinglePromote(Object? studentId) {
    _set(() {
      promoteStudents = [studentId];
      promoteTargetClass = null;
      promoteTargetBatch = null;
    });
    setOpen(ClassDialog.promote, true);
    run(loadPromoteClasses);
  }

  void openSingleStudentTransfer(Object? studentId) {
    _set(() {
      transferStudents = [studentId];
      transferTargetBatch = null;
      transferBatchList = [];
    });
    setOpen(ClassDialog.transfer, true);
    run(loadTransferBatches);
  }

  Future<void> onPromoteConfirm() async {
    if (!jsTruthy(promoteTargetClass)) {
      AppToast.error('Please select a target class');
      return;
    }
    if (!jsTruthy(promoteTargetBatch)) {
      AppToast.error('Please select a target batch');
      return;
    }
    if (promoteStudents.isEmpty) {
      AppToast.error('Please select students');
      return;
    }
    final fromBatchId = selectedBatch['id'];
    if (fromBatchId == null) {
      AppToast.error('Source batch ID is missing');
      return;
    }
    final toBatchId = promoteTargetBatch;
    if (toBatchId == null) {
      AppToast.error('Target batch ID is missing');
      return;
    }
    await store.promoteStudents(
      jsNumber(fromBatchId) ?? fromBatchId,
      jsNumber(toBatchId) ?? toBatchId,
      promoteStudents,
    );
    setOpen(ClassDialog.promote, false);
  }

  void openTransferDialog() {
    _set(() {
      transferTargetBatch = null;
      transferBatchList = [];
    });
    setOpen(ClassDialog.transfer, true);
    run(loadTransferBatches);
  }

  Future<void> loadTransferBatches() async {
    if (!hasClass) return;
    await store.getBatches(classId);
    _set(
      () => transferBatchList = [
        for (final b in s.batches)
          if (b['id'] != selectedBatch['id']) b,
      ],
    );
  }

  /// `loadTransferClasses()` (not wired in the template).
  Future<void> loadTransferClasses() async {
    await store.getClasses();
    _set(() => transferClassList = s.institutes);
  }

  /// `onTransferClassChange(val)` (not wired in the template).
  Future<void> onTransferClassChange(Object? val) async {
    if (!jsTruthy(val)) {
      _set(() => transferBatchList = []);
      return;
    }
    await store.getBatches(jsNumber(val));
    _set(() => transferBatchList = s.batches);
  }

  void toggleTransferSelectAll() => _set(() {
    transferStudents = transferStudents.length == s.students.length
        ? []
        : [for (final st in s.students) jsNumber(asMap(st)?['id'])];
  });

  Future<void> transferNow() async {
    if (transferStudents.isEmpty) {
      AppToast.error('No students selected');
      return;
    }
    final fromBatchId = selectedBatch['id'];
    if (!jsTruthy(fromBatchId)) {
      AppToast.error('Source batch ID missing');
      return;
    }
    final toBatchId = transferTargetBatch;
    if (!jsTruthy(toBatchId)) {
      AppToast.error('Target batch ID missing');
      return;
    }
    try {
      _set(() => isCreateBtnLoading = true);
      await store.transferStudents(
        jsNumber(fromBatchId) ?? fromBatchId,
        jsNumber(toBatchId) ?? toBatchId!,
        transferStudents,
      );
      setOpen(ClassDialog.transfer, false);
      setBulkAction('');
      await store.getStudents();
    } catch (_) {
      // console.error in the web.
    } finally {
      _set(() => isCreateBtnLoading = false);
    }
  }

  // ── bulk upload ───────────────────────────────────────────────────────────

  Future<void> onFileSelect() async {
    final file = await pickUploadFile();
    // `event.target.files[0]` — cancelling clears the selection.
    _set(() => selectedFile = file);
  }

  Future<void> submitImport() async {
    _set(() => isImportStarted = true);
    final res = await store.importStudents(selectedFile);
    _set(() => selectedFile = null);
    final channel = dig(res, ['data', 'broadcast_channel']);
    if (channel == null) throw StateError('broadcast_channel missing');
    listenToImportChannel('$channel');
  }

  void listenToImportChannel(String channelName) {
    final channel = _container.read(echoClientProvider).private(channelName);
    _echoChannels.add(channelName);
    _echoSubs.add(
      channel.listen(
        '.update',
        (e) => _set(() => importRows = applyImportUpdate(importRows, e)),
      ),
    );
    _echoSubs.add(
      channel.listen('.complete', (_) => _set(() => importCompleted = true)),
    );
  }

  Future<void> downloadstudentxl() => store.downloadTemplate();

  Future<void> openPromoteDialog() async {
    _set(() {
      promoteTargetClass = null;
      promoteTargetBatch = null;
    });
    setOpen(ClassDialog.promote, true);
    await loadPromoteClasses();
  }

  Future<void> loadPromoteClasses() async {
    await store.getClasses();
    _set(() => promoteClassList = s.institutes);
  }

  /// `@update:model-value="onClassChange"` on the target-class select.
  Future<void> onClassChange(Object? value) async {
    _set(() => promoteTargetClass = value);
    if (!jsTruthy(value)) return;
    await store.getPromoteBatches(jsNumber(value));
  }

  void toggleSelectAll() => _set(() {
    promoteStudents = promoteStudents.length == s.students.length
        ? []
        : [for (final st in s.students) asMap(st)?['id']];
  });

  void togglePromoteStudent(Object? id, bool checked) => _set(() {
    promoteStudents = checked
        ? [...promoteStudents, id]
        : [
            for (final x in promoteStudents)
              if (x != id) x,
          ];
  });

  void toggleTransferStudent(Object? id, bool checked) => _set(() {
    final n = jsNumber(id);
    transferStudents = checked
        ? [...transferStudents, n]
        : [
            for (final x in transferStudents)
              if (x != n) x,
          ];
  });

  // ── add student wizard ────────────────────────────────────────────────────

  void goToStudentStep(int n) => _set(() {
    studentStep = n;
    showStudentResults = false;
    showStudentGlobalResults = false;
    studentQuery.text = '';
    studentGlobalQuery.text = '';
    studentResults = [];
    studentGlobalResults = [];
    isStudentSearching = false;
    isStudentSearchingGlobal = false;
    foundStudent = const FoundUser();
    newStudent.firstName.text = '';
    newStudent.lastName.text = '';
    newStudent.email.text = '';
    newStudent.countryCode = '91';
    newStudent.phone.text = '';
  });

  /// `getAllStudents()` (not wired in the template).
  Future<void> getAllStudents() async {
    _set(() => isLoading = true);
    try {
      await store.getAllStudents();
    } finally {
      _set(() => isLoading = false);
    }
  }

  Future<void> searchStudentGlobal() async {
    _set(() {
      isStudentSearchingGlobal = true;
      showStudentGlobalResults = true;
    });
    try {
      final response = await store.searchByUser(studentGlobalQuery.text.trim());
      final hits = filterUserRows(
        searchRows(response),
        studentGlobalQuery.text,
      );
      _set(() => studentGlobalResults = hits);
    } finally {
      _set(() => isStudentSearchingGlobal = false);
    }
  }

  Future<void> attachStudentFromGlobal(Object? item) async {
    final studentId = jsNumber(item) ?? 0;
    _set(() => isCreateBtnLoading = true);
    try {
      await store.addStudentFromExistingUser(studentId);
      await store.getStudents();
      setOpen(ClassDialog.createStudent, false);
      _set(() {
        studentGlobalQuery.text = '';
        showStudentGlobalResults = false;
        studentGlobalResults = [];
      });
      clearStudentCreateMode();
    } finally {
      _set(() => isCreateBtnLoading = false);
    }
  }

  // ── add instructor wizard ─────────────────────────────────────────────────

  void goToStep(int step) => _set(() {
    final currentEnableZoom = newInstructor.enableZoom;
    currentStep = step;
    newInstructor.assign(enableZoom: currentEnableZoom);
  });

  /// `attachFromGlobal(item)` (step 2 is hidden in the web).
  Future<void> attachFromGlobal(FoundUser item) async {
    final userId = jsNumber(item.id) ?? 0;
    _set(() => isLoading = true);
    try {
      await store.attachInstructor(userId);
      await store.getInstructors(classId, 1);
      _set(() => instructorCount = s.classInstructors.length);
      setOpen(ClassDialog.instructor, false);
      _set(() {
        globalQuery.text = '';
        showGlobalResults = false;
        globalResults = [];
      });
      clearCreateMode();
    } catch (_) {
      // console.error in the web.
    } finally {
      _set(() => isLoading = false);
    }
  }

  /// `searchUserGlobal()` (step 2 is hidden in the web).
  Future<void> searchUserGlobal() async {
    if (globalQuery.text.trim().isEmpty) {
      AppToast.info('Please enter a name or email to search.');
      return;
    }
    _set(() {
      isSearchingGlobal = true;
      showGlobalResults = true;
    });
    try {
      final response = await store.searchByUser(globalQuery.text.trim());
      final hits = filterUserRows(searchRows(response), globalQuery.text);
      _set(() => globalResults = hits);
    } finally {
      _set(() => isSearchingGlobal = false);
    }
  }

  /// `selectResultFromGlobal(item)` (not wired in the template).
  void selectResultFromGlobal(SearchHit item) {
    selectResult(item);
    _set(() => showGlobalResults = false);
  }

  void selectResult(SearchHit item) => _set(() {
    final row = item.raw ?? item;
    final u = asMap(asMap(row)?['user'] ?? row);
    final names = splitResultName(u);
    foundUser = FoundUser(
      id: u?['id'],
      fullName: '${names.first} ${names.last}'.trim(),
      email: '${orJs(u?['email'], '')}',
    );
    newInstructor.firstName.text = names.first;
    newInstructor.lastName.text = names.last;
    newInstructor.email.text = '${orJs(u?['email'], '')}';
    newInstructor.countryCode = jsString(
      u?['country_code'] ?? newInstructor.countryCode,
    );
    newInstructor.phone.text = u?['phone'] != null ? jsString(u!['phone']) : '';
    showResults = false;
  });

  void clearCreateMode() => _set(() {
    foundUser = const FoundUser();
    newInstructor.assign();
  });

  Future<void> searchUser() async {
    if (searchQuery.text.trim().isEmpty) {
      AppToast.info('Please enter a name or email to search.');
      return;
    }
    _set(() {
      isSearching = true;
      showResults = true;
    });
    try {
      final response = await store.searchUserByIns(searchQuery.text.trim());
      final hits = filterInstructorRows(searchRows(response), searchQuery.text);
      _set(() => searchResults = hits);
    } finally {
      _set(() => isSearching = false);
    }
  }

  Future<void> searchinsattach() async {
    if (!jsTruthy(foundUser.id)) {
      AppToast.info('Please search and select a user first.');
      return;
    }
    if (!hasClass) {
      AppToast.info('Open a class first to attach an instructor.');
      return;
    }
    _set(() => isCreateBtnLoading = true);
    try {
      SearchHit? picked;
      for (final u in searchResults) {
        if (dig(u.raw, ['user', 'id']) == foundUser.id) {
          picked = u;
          break;
        }
      }
      final instructorId = asMap(picked?.raw)?['id'];
      if (!jsTruthy(instructorId)) {
        AppToast.info('Instructor ID missing from selected record.');
        return;
      }
      await store.attachInstructorToCurrentClass('$instructorId');
      await store.getInstructors(classId, 1);
      _set(() => instructorCount = s.classInstructors.length);
      setOpen(ClassDialog.instructor, false);
      _set(() {
        searchQuery.text = '';
        showResults = false;
      });
      clearCreateMode();
      AppToast.info('Instructor attached.');
    } finally {
      _set(() => isCreateBtnLoading = false);
    }
  }

  void resetInstructorDialog() => _set(() {
    currentStep = 1;
    globalQuery.text = '';
    isSearchingGlobal = false;
    showGlobalResults = false;
    globalResults = [];
  });

  void selectStudentResult(SearchHit item) => _set(() {
    final row = asMap(item.raw ?? item);
    final user = asMap(row?['user']);
    foundStudent = FoundUser(
      id: row?['id'],
      fullName: '${user?['first_name'] ?? ''} ${user?['last_name'] ?? ''}'
          .trim(),
      email: '${orJs(user?['email'], '')}',
    );
    newStudent.firstName.text = '${orJs(user?['first_name'], '')}';
    newStudent.lastName.text = '${orJs(user?['last_name'], '')}';
    newStudent.email.text = '${orJs(user?['email'], '')}';
    newStudent.countryCode = jsString(user?['country_code'] ?? '91');
    newStudent.phone.text = jsTruthy(user?['phone'])
        ? jsString(user!['phone'])
        : '';
    showStudentResults = false;
  });

  void clearStudentCreateMode() => _set(() {
    foundStudent = const FoundUser();
    newStudent.reset();
  });

  Future<void> searchStudent() async {
    if (studentQuery.text.trim().isEmpty) return;
    _set(() {
      isStudentSearching = true;
      showStudentResults = true;
    });
    try {
      final response = await store.searchUserByStu(studentQuery.text.trim());
      final hits = filterUserRows(searchRows(response), studentQuery.text);
      _set(() => studentResults = hits);
    } finally {
      _set(() => isStudentSearching = false);
    }
  }

  Future<void> attachExistingStudent() async {
    if (!jsTruthy(foundStudent.id)) {
      AppToast.info('Please search and select a user first.');
      return;
    }
    _set(() => isCreateBtnLoading = true);
    try {
      await store.attachstudent(foundStudent.id!);
      await store.getStudents();
      setOpen(ClassDialog.createStudent, false);
      _set(() {
        studentQuery.text = '';
        showStudentResults = false;
      });
      clearStudentCreateMode();
    } finally {
      _set(() => isCreateBtnLoading = false);
    }
  }

  void resetStudentDialog() => _set(() {
    newStudent.reset();
    if (dailCodes.isNotEmpty)
      newStudent.countryCode = '${orJs(dailCodes.first['code'], '91')}';
  });

  /// `attachFoundStudent()` (its template is commented out in the web).
  Future<void> attachFoundStudent() async {
    if (!jsTruthy(foundStudent.id)) return;
    _set(() => isLoading = true);
    try {
      await store.attachstudent(foundStudent.id!);
      _set(() {
        foundStudent = const FoundUser(id: 0);
        studentSearchQuery = '';
      });
      await store.getStudents();
    } finally {
      _set(() => isLoading = false);
    }
  }

  // ── courses / admins ──────────────────────────────────────────────────────

  Future<void> attachCourses() async {
    if (!jsTruthy(selectedCourseId)) {
      await alert('Please select a course first.');
      return;
    }
    _set(() => isLoading = true);
    try {
      await store.attachSelectedCourseToClass('$selectedCourseId');
      await Future.wait([store.fetchClassCourse(), store.fetchClassDetails()]);
      _set(() {
        courseRefreshKey++;
        courseCount = _coursesLength();
        selectedCourseId = null;
      });
      await store.getClasses();
    } catch (_) {
      // console.error in the web.
    } finally {
      _set(() => isLoading = false);
    }
  }

  /// "Attach Admin"
  Future<void> attachInstructor() async {
    if (!jsTruthy(selectedInstructorId)) return;
    try {
      _set(() => isCreateBtnLoading = true);
      await store.assignInstructorToAdmin('$selectedInstructorId');
      await store.getAssignedInstructors();
      _set(() {
        adminCount = s.assignedInstructors.length;
        selectedInstructorId = '';
      });
      await store.getClasses();
    } finally {
      _set(() => isCreateBtnLoading = false);
    }
  }

  void openAdminDelete(Object? instructorId, String name, String email) {
    adminDeleteTarget = {'id': instructorId, 'name': name, 'email': email};
    setOpen(ClassDialog.adminDelete, true);
  }

  // ignore: non_constant_identifier_names
  Future<void> AdminDelete() async {
    final instructorId = adminDeleteTarget?['id'];
    if (!jsTruthy(instructorId)) return;
    _set(() => isLoading = true);
    try {
      final instituteId = session.userInfo?.instituteId?.toString();
      final cid = classId?.toString();
      if (instituteId == null || cid == null) return;
      await store.deleteClassAdminById('$instructorId', instituteId, cid);
      await store.getAssignedInstructors();
      _set(() => adminCount = s.assignedInstructors.length);
      setOpen(ClassDialog.adminDelete, false);
      adminDeleteTarget = null;
      await store.getClasses();
    } catch (_) {
      // console.error in the web.
    } finally {
      _set(() => isLoading = false);
    }
  }

  Future<void> onStudentPageChange(int newPage) async {
    if (newPage < 1 || newPage > s.studentPagination.lastPage) return;
    _set(() => isLoading = true);
    try {
      await store.getStudents(newPage);
    } finally {
      _set(() => isLoading = false);
    }
  }

  Future<void> changeInstructorPage(int page) async {
    if (page < 1 || page > s.classInstructorPagination.lastPage) return;
    if (!hasClass) return;
    _set(() => isListLoading = true);
    try {
      await store.getInstructors(classId, page);
    } finally {
      _set(() => isListLoading = false);
    }
  }

  // ── classes ───────────────────────────────────────────────────────────────

  // ignore: non_constant_identifier_names
  Future<void> CreateClass() async {
    _set(() => isCreateBtnLoading = true);
    try {
      await store.createClass(
        newClassName.text,
        orJs(selectedCurriculumId, 0)!,
        '${classstatus ?? ''}',
        selectedClassLevel,
      );
      _set(() {
        newClassName.text = '';
        classstatus = '';
        selectedClassLevel = null;
        selectedCurriculumId = null;
      });
      setOpen(ClassDialog.createClass, false);
    } finally {
      _set(() => isCreateBtnLoading = false);
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> ClassUpdate() async {
    if (!hasClass) return;
    _set(() => isLoading = true);
    try {
      await store.updateClass(
        '$classId',
        name: newClassName.text,
        status: classstatus,
        classLevel: selectedClassLevel,
      );
      _set(() {
        newClassName.text = '';
        classstatus = '';
        selectedClassLevel = null;
      });
      setOpen(ClassDialog.updateClass, false);
      await store.getClasses();
    } catch (_) {
      // console.error in the web.
    } finally {
      _set(() => isLoading = false);
    }
  }

  Future<void> toggleClassStatus(Json institute) async {
    if (isLoading) return;
    _set(() => isLoading = true);
    try {
      final newStatus = institute['status'] == 'published'
          ? 'draft'
          : 'published';
      await store.updateClassStatus('${institute['id']}', newStatus);
      store.patchInstitute(institute['id'], {'status': newStatus});
    } catch (_) {
      // console.error in the web.
    } finally {
      _set(() => isLoading = false);
    }
  }

  Future<void> createBatchHandler(String batchName) async {
    _set(() => isCreateBtnLoading = true);
    try {
      await store.createBatch(batchName);
      newBatchName.text = '';
      await store.getBatches();
      await store.getClasses();
    } finally {
      _set(() => isCreateBtnLoading = false);
    }
  }

  Future<void> openBatchById(Object? batchId) async {
    setOpen(ClassDialog.updateBatch, true);
    _set(() => isLoading = true);
    try {
      final batchData = await store.fetchBatchesById(batchId);
      final m = asMap(batchData);
      if (m == null) throw StateError('batch not loaded');
      _set(() {
        selectedBatch = m;
        updateBatchName.text = vueText(m['name']);
        batchstatus = asString(m['status']);
      });
    } finally {
      _set(() => isLoading = false);
    }
  }

  void openBatchDeleteDialog(Object? batchId) {
    batchDeleteTargetId = batchId;
    setOpen(ClassDialog.deleteBatch, true);
  }

  Future<void> batchDelete() async {
    final batchId = batchDeleteTargetId;
    if (!jsTruthy(batchId)) return;
    _set(() => isLoading = true);
    try {
      await store.deleteBatch('$batchId');
      await store.getBatches();
      setOpen(ClassDialog.deleteBatch, false);
      batchDeleteTargetId = null;
      await store.getClasses();
    } catch (_) {
      // console.error in the web.
    } finally {
      _set(() => isLoading = false);
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> BatchUpdate() async {
    if (!jsTruthy(selectedBatch['id'])) return;
    _set(() => isCreateBtnLoading = true);
    try {
      final normalized = normalizeBatchUpdateStatus(batchstatus);
      await store.updateBatch(
        selectedBatch['id'],
        updateBatchName.text,
        normalized,
      );
      setOpen(ClassDialog.updateBatch, false);
      await store.getBatches();
    } finally {
      _set(() => isCreateBtnLoading = false);
    }
  }

  /// `onBatchPageChange()` (not wired in the template).
  void onBatchPageChange() {
    _set(() => isLoading = true);
    try {
      run(store.getBatches);
    } finally {
      _set(() => isLoading = false);
    }
  }

  void createInstructor() => setOpen(ClassDialog.instructor, true);

  Future<void> openUpdateInstructor(Object? instructorId) async {
    setOpen(ClassDialog.updateInstructor, true);
    _set(() => isLoading = true);
    try {
      await store.fetchInstructorById(instructorId);
      final instructor = asMap(s.selectedInstructor) ?? const {};
      final user = asMap(instructor['user']);
      String str(Object? v) => vueText(v);
      _set(
        () => newInstructor.assign(
          firstName: str(orJs(user?['first_name'], '')),
          lastName: str(orJs(user?['last_name'], '')),
          email: str(orJs(user?['email'], '')),
          countryCode: str(orJs(user?['country_code'], '91')),
          phone: str(orJs(user?['phone'], '')),
          status: jsTruthy(instructor['status']),
          photo: orJs(user?['photo'], null),
          password: str(orJs(instructor['password'], '')),
          gender: str(orJs(user?['gender'], '')),
          dob: str(orJs(user?['dob'], '')),
          joiningDate: str(orJs(instructor['joining_date'], '')),
          designation: str(orJs(instructor['designation'], '')),
          enableZoom: jsTruthy(instructor['enable_zoom']),
          isLabAdmin: jsTruthy(instructor['is_labadmin']),
        ),
      );
    } finally {
      _set(() => isLoading = false);
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> InstructorUpdate() async {
    _set(() => isCreateBtnLoading = true);
    try {
      await store.updateInstructor(asMap(s.selectedInstructor)?['id'], {
        'first_name': newInstructor.firstName.text,
        'last_name': newInstructor.lastName.text,
        'email': newInstructor.email.text,
        'country_code': newInstructor.countryCode,
        'phone': newInstructor.phone.text,
        'status': newInstructor.status,
        'is_labadmin': newInstructor.isLabAdmin,
        'joining_date': newInstructor.joiningDate,
        'designation': newInstructor.designation.text,
      });
      setOpen(ClassDialog.updateInstructor, false);
      await store.getInstructors(classId ?? 0);
    } finally {
      _set(() => isCreateBtnLoading = false);
    }
  }

  Future<void> addNewInstructor() async {
    _set(() => isCreateBtnLoading = true);
    try {
      final f = newInstructor;
      final photo = f.photo;
      await store.addInstructor(
        firstName: f.firstName.text,
        lastName: f.lastName.text,
        email: f.email.text,
        countryCode: f.countryCode,
        phone: f.phone.text,
        gender: f.gender,
        dob: f.dob,
        photo: photo is UploadFile ? photo : null,
        password: f.password.text,
        designation: f.designation.text,
        joiningDate: f.joiningDate,
        enableZoom: f.enableZoom,
        isLabAdmin: f.isLabAdmin,
      );
      _set(() => newInstructor.assign());
      await changeInstructorPage(s.classInstructorPagination.currentPage);
      _set(() => instructorCount = s.classInstructors.length);
      if (hasClass) await store.getInstructorsdropdown(classId);
      setOpen(ClassDialog.instructor, false);
    } catch (_) {
      // console.error in the web.
    } finally {
      _set(() => isCreateBtnLoading = false);
    }
  }

  Future<void> addNewStudent() async {
    final f = newStudent;
    if (f.password.text != f.confirmpassword.text) {
      AppToast.error('Passwords do not match');
      return;
    }
    if (f.password.text.isEmpty) {
      AppToast.error('Password is required');
      return;
    }
    _set(() => isCreateBtnLoading = true);
    try {
      await store.addStudent(
        firstName: f.firstName.text,
        lastName: f.lastName.text,
        email: f.email.text,
        password: f.password.text,
        confirmpassword: f.confirmpassword.text,
        countryCode: f.countryCode,
        phone: f.phone.text,
        gender: f.gender,
        dob: f.dob,
        photo: f.photo,
      );
      _set(f.reset);
      await store.getStudents();
      setOpen(ClassDialog.createStudent, false);
    } catch (_) {
      // console.error in the web.
    } finally {
      _set(() => isCreateBtnLoading = false);
    }
  }

  Future<void> openStudentUpdateDialog(Object? studentId) async {
    if (!jsTruthy(studentId)) return;
    _set(() => isLoading = true);
    try {
      final student = await store.fetchStudentById(studentId);
      _set(() {
        selectedStudent = asMap(student) ?? {};
        final user = asMap(selectedStudent['user']) ?? const {};
        newStudent.firstName.text = '${orJs(user['first_name'], '')}';
        newStudent.lastName.text = '${orJs(user['last_name'], '')}';
        newStudent.email.text = '${orJs(user['email'], '')}';
        newStudent.countryCode = '${orJs(user['country_code'], '91')}';
        newStudent.phone.text = '${orJs(user['phone'], '')}';
      });
      studentStatusString = jsTruthy(selectedStudent['status'])
          ? 'true'
          : 'false';
      setOpen(ClassDialog.updateStudent, true);
    } catch (_) {
      AppToast.error('Something went wrong while fetching student details');
    } finally {
      _set(() => isLoading = false);
    }
  }

  // ignore: non_constant_identifier_names
  Future<void> StudentUpdate() async {
    try {
      final studentId = selectedStudent['id'];
      if (!jsTruthy(studentId)) throw StateError('Student ID not found');
      _set(() => isCreateBtnLoading = true);
      await store.updateStudent(studentId, {
        'first_name': newStudent.firstName.text,
        'last_name': newStudent.lastName.text,
        'email': newStudent.email.text,
        'country_code': newStudent.countryCode,
        'phone': newStudent.phone.text,
        'status': studentStatusString == 'true',
      });
      await store.getStudents(s.studentPagination.currentPage);
      setOpen(ClassDialog.updateStudent, false);
    } catch (_) {
      // console.error in the web.
    } finally {
      _set(() => isCreateBtnLoading = false);
    }
  }

  Future<void> openStudentModal(Json batch) async {
    _set(() {
      selectedBatch = batch;
      showBatchStudentsInline = true;
      searchQueryStudent.text = '';
      quizSysCards = [];
      showQuizSysCardList = false;
    });
    if (jsTruthy(batch['id'])) {
      store.setBatchDetails({'id': batch['id'], 'name': batch['name']});
      _set(() => isListLoading = true);
      try {
        await store.getStudents();
        await loadQuizSysCards(false);
      } finally {
        _set(() => isListLoading = false);
        run(resetStudent);
      }
    }
  }

  Future<void> _openClass(Json institute) async {
    _set(() {
      showBatchStudentsInline = false;
      savedSelectedClass = {...institute};
    });
    store.clearClassDetailsData();
    store.setClassDetails({
      'id': institute['id'],
      'name': institute['year'],
      'c_id': institute['c_id'],
    });
    final id = jsNumber(institute['id']);
    await store.getBatches(id);
    if (activeTab == 'courses') await store.fetchClassCourse();
    Json? selectedClass;
    for (final c in s.institutes) {
      if (c['id'] == institute['id']) selectedClass = c;
    }
    _set(() {
      isClassAdmin = selectedClass?['is_admin'] == true;
      adminCount = asInt(selectedClass?['admins']) ?? 0;
      instructorCount = asInt(selectedClass?['instructors']) ?? 0;
      courseCount = asInt(selectedClass?['courses']) ?? 0;
    });
    await store.getInstructors(id, 1);
    if (canManageClass) {
      await store.getAssignedInstructors(id);
      await store.getInstructorsdropdown(id);
    }
    await store.fetchClassDetails(id);
    await store.getClasses();
  }

  /// Card click (`openDrawer({ id, year, c_id })`).
  Future<void> openDrawer(Json institute) async {
    _set(() => isListLoading = true);
    try {
      await _openClass(institute);
    } finally {
      _set(() => isListLoading = false);
    }
  }

  Future<void> selectClass(Json institute) async {
    _set(() {
      isCourseExpanded = false;
      isListLoading = true;
    });
    try {
      await _openClass(institute);
    } finally {
      _set(() => isListLoading = false);
    }
  }

  /// "Back to classes"
  Future<void> closeDrawer() async {
    _set(() {
      showBatchStudentsInline = false;
      selectedBatch = {'name': '', 'status': ''};
      adminCount = 0;
      instructorCount = 0;
      courseCount = 0;
      selectedCourseId = null;
      expandedCourseId = null;
      courseDetails = {};
      openSectionId = null;
      openChapterId = null;
      pdfPreviewId = null;
      searchQueryBatch.text = '';
      newBatchName.text = '';
      searchQueryInstructor.text = '';
      searchQueryStudent.text = '';
      isLoading = true;
    });
    store.setClassDetails(const <String, dynamic>{});
    try {
      await store.getClasses();
    } finally {
      _set(() => isLoading = false);
    }
  }

  Future<void> loadDailCodes() async {
    if (_container.read(dialCodesProvider).hasError)
      _container.invalidate(dialCodesProvider);
    final codes = await _container.read(dialCodesProvider.future);
    _set(() {
      dailCodes = codes;
      if (codes.isNotEmpty)
        newInstructor.countryCode = '${codes.first['code']}';
    });
  }

  // ── skills / misc dialogs ─────────────────────────────────────────────────

  /// `createSkill()` — nothing in the template calls it.
  void createSkill() => setOpen(ClassDialog.skill, true);

  Future<void> addSkill() async {
    if (newSkill.text.trim().isEmpty) {
      await alert('Skill name cannot be empty.');
      return;
    }
    _set(() {
      skills = [...skills, newSkill.text.trim()];
      newSkill.text = '';
    });
  }

  Future<void> editSkill(int index) async {
    final updated = await prompt('Edit skill name:', skills[index]);
    if (updated != null && updated.trim().isNotEmpty) {
      _set(() => skills = [...skills]..[index] = updated.trim());
    }
  }

  void submitBatchEdit() => setOpen(ClassDialog.editBatch, false);

  /// "Create Class"
  void createInstitute() {
    _set(() {
      newClassName.text = '';
      selectedCurriculumId = null;
      classstatus = '';
      selectedClassLevel = null;
    });
    setOpen(ClassDialog.createClass, true);
  }

  Future<void> openUpdateClassDialog(String classIdStr) async {
    if (classIdStr.isEmpty) return;
    final id = int.tryParse(classIdStr);
    if (id == null) return;
    store.setClassDetails({'id': id, 'name': '', 'c_id': ''});
    try {
      final response = await store.fetchClassDetails();
      final cls = asMap(response ?? classDetails) ?? const {};
      _set(() {
        newClassName.text = vueText(cls['name'] ?? '');
        selectedCurriculumId = cls['curricula_id'] ?? '';
        classstatus = cls['status'];
        selectedClassLevel = asInt(cls['class_level']);
      });
      setOpen(ClassDialog.updateClass, true);
    } catch (_) {
      // console.error in the web.
    }
  }

  /// Delete Class: `alert('work in progress....')`.
  Future<void> openDeleteClassDialog() => alert('work in progress....');

  Future<void> showAlert() => alert('work in progress');

  void toggleSection(Object? sectionId) =>
      _set(() => openSectionId = openSectionId == sectionId ? null : sectionId);
  void toggleChapter(Object? chapterId) =>
      _set(() => openChapterId = openChapterId == chapterId ? null : chapterId);
  void togglePdfPreview(Object? id) =>
      _set(() => pdfPreviewId = pdfPreviewId == id ? null : id);

  // ── search ────────────────────────────────────────────────────────────────

  void searchInstructorsByName() {
    if (searchQueryInstructor.text.trim().isEmpty) return;
    run(() => store.searchInstructors(searchQueryInstructor.text));
  }

  void searchStudentsByName() {
    if (searchQueryStudent.text.trim().isEmpty) return;
    run(() => store.searchStudents(searchQueryStudent.text));
  }

  Future<void> resetInstructor() async {
    searchQueryInstructor.text = '';
    await store.getInstructors(classId ?? 0);
  }

  Future<void> studentsearchreset() async {
    searchQueryStudent.text = '';
    await store.getStudents();
  }

  Future<void> resetStudent() async {
    _set(() {
      promoteStudents = [];
      isImportStarted = false;
      importRows = [];
      studentQuery.text = '';
      isStudentSearching = false;
      showStudentResults = false;
      studentResults = [];
      foundStudent = const FoundUser();
      promoteTargetClass = null;
      promoteTargetBatch = null;
      promoteClassList = [];
      transferStudents = [];
      transferTargetBatch = null;
      transferClassList = [];
      transferBatchList = [];
    });
    setBulkAction('');
    await store.getStudents();
  }

  Future<void> searchClassByName() async {
    final term = searchQueryClass.text.trim();
    if (term.isEmpty) return;
    _set(() => isListLoading = true);
    await store.searchClassWithInstructor(term);
    _set(() => isListLoading = false);
  }

  Future<void> resetClass() async {
    searchQueryClass.text = '';
    await store.getClasses();
  }

  void searchBatchByName() {
    if (searchQueryBatch.text.trim().isEmpty) return;
    run(() => store.searchBatch(searchQueryBatch.text));
  }

  Future<void> resetBatch() async {
    searchQueryBatch.text = '';
    await store.getBatches();
  }

  void openPhoneDialog(String number) {
    _set(() {
      phoneNumber = number;
      copied = false;
    });
    setOpen(ClassDialog.phone, true);
  }

  Future<void> copyToClipboard(String number) async {
    await Clipboard.setData(ClipboardData(text: number));
    _set(() => copied = true);
    _copiedTimer?.cancel();
    _copiedTimer = Timer(
      const Duration(milliseconds: 1200),
      () => _set(() => copied = false),
    );
  }
}
