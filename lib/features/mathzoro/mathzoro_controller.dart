import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import 'mz_ui.dart';

/// MathZoro part of the shared Pinia store (`defineStore('new-content')`).
///
/// The web had two store files with the same id (Userstore.ts and
/// mathzorostore.ts). Pinia returns the instance that was created first —
/// `useUserStore()` in main.ts — so at runtime every `mathuseUserStore()`
/// call used the Userstore.ts actions. Everything below is ported from
/// src/store/Userstore.ts.
///
/// The web persisted the whole store to encrypted sessionStorage
/// (pinia-plugin-persistedstate), so the class selection survived a reload;
/// the persisted fields are kept in [SecureStore] under [storageKey].
class MathZoroState {
  const MathZoroState({
    this.instituteMeta,
    this.selectedClass,
    this.availableClasses = const [],
    this.mathZoroCourses = const [],
    this.lastOpenedChapter,
    this.selectedActivityContext,
    this.storedSubjectId,
    this.allsubject = const [],
    this.allchapters = const [],
    this.institutes = const [],
    this.classes = const [],
    this.ticketsUpdatedTick = 0,
  });

  /// `instituteMeta` — name / logo / plan of the institute (multi-class login).
  final Map<String, dynamic>? instituteMeta;

  /// `selectedClass` — see [MathZoroController.setSelectedClass].
  final Map<String, dynamic>? selectedClass;

  /// `availableClasses` — unique classes built at login.
  final List<Map<String, dynamic>> availableClasses;

  /// `math_zoro_courses`.
  final List<Map<String, dynamic>> mathZoroCourses;

  /// `lastOpenedChapter` — `{ id, name, chapterIndex }` (set by Math Zone).
  final Map<String, dynamic>? lastOpenedChapter;

  /// `selectedActivityContext` — set by the Math Zone screens; only read
  /// here as a class-id fallback.
  final Map<String, dynamic>? selectedActivityContext;

  /// `localStorage/sessionStorage.getItem('subjectId')`.
  final String? storedSubjectId;

  /// Raw result of `getAllSubjects` (`res.data || res || []`).
  final dynamic allsubject;

  /// Raw result of `getallchpaters` (`res.data || res || []`).
  final dynamic allchapters;

  /// `institutes` / `classes` — result of [MathZoroController.getClasses].
  final List<Map<String, dynamic>> institutes;
  final List<Map<String, dynamic>> classes;

  /// Bumped by `window.dispatchEvent(new CustomEvent('tickets-updated'))`.
  final int ticketsUpdatedTick;

  static const _unset = Object();

  MathZoroState copyWith({
    Object? instituteMeta = _unset,
    Object? selectedClass = _unset,
    List<Map<String, dynamic>>? availableClasses,
    List<Map<String, dynamic>>? mathZoroCourses,
    Object? lastOpenedChapter = _unset,
    Object? selectedActivityContext = _unset,
    Object? storedSubjectId = _unset,
    Object? allsubject = _unset,
    Object? allchapters = _unset,
    List<Map<String, dynamic>>? institutes,
    List<Map<String, dynamic>>? classes,
    int? ticketsUpdatedTick,
  }) =>
      MathZoroState(
        instituteMeta: identical(instituteMeta, _unset)
            ? this.instituteMeta
            : instituteMeta as Map<String, dynamic>?,
        selectedClass: identical(selectedClass, _unset)
            ? this.selectedClass
            : selectedClass as Map<String, dynamic>?,
        availableClasses: availableClasses ?? this.availableClasses,
        mathZoroCourses: mathZoroCourses ?? this.mathZoroCourses,
        lastOpenedChapter: identical(lastOpenedChapter, _unset)
            ? this.lastOpenedChapter
            : lastOpenedChapter as Map<String, dynamic>?,
        selectedActivityContext: identical(selectedActivityContext, _unset)
            ? this.selectedActivityContext
            : selectedActivityContext as Map<String, dynamic>?,
        storedSubjectId: identical(storedSubjectId, _unset)
            ? this.storedSubjectId
            : storedSubjectId as String?,
        allsubject: identical(allsubject, _unset) ? this.allsubject : allsubject,
        allchapters: identical(allchapters, _unset) ? this.allchapters : allchapters,
        institutes: institutes ?? this.institutes,
        classes: classes ?? this.classes,
        ticketsUpdatedTick: ticketsUpdatedTick ?? this.ticketsUpdatedTick,
      );

  Map<String, dynamic> toJson() => {
        'instituteMeta': instituteMeta,
        'selectedClass': selectedClass,
        'availableClasses': availableClasses,
        'math_zoro_courses': mathZoroCourses,
        'lastOpenedChapter': lastOpenedChapter,
        'selectedActivityContext': selectedActivityContext,
        'subjectId': storedSubjectId,
      };

  factory MathZoroState.fromJson(Map<String, dynamic> j) => MathZoroState(
        instituteMeta: asMap(j['instituteMeta']),
        selectedClass: asMap(j['selectedClass']),
        availableClasses: _maps(j['availableClasses']),
        mathZoroCourses: _maps(j['math_zoro_courses']),
        lastOpenedChapter: asMap(j['lastOpenedChapter']),
        selectedActivityContext: asMap(j['selectedActivityContext']),
        storedSubjectId: asString(j['subjectId']),
      );

  static List<Map<String, dynamic>> _maps(dynamic v) =>
      asList(v).map(asMap).whereType<Map<String, dynamic>>().toList();
}

final mathZoroProvider =
    NotifierProvider<MathZoroController, MathZoroState>(MathZoroController.new);

class MathZoroController extends Notifier<MathZoroState> {
  static const storageKey = 'elab.mathzoro';

  final Completer<void> _ready = Completer<void>();
  bool _touched = false;

  /// Completes once the persisted state has been restored.
  Future<void> get ready => _ready.future;

  @override
  MathZoroState build() {
    // `logout()` → `this.$reset()` clears the MathZoro state as well.
    ref.listen<bool>(sessionProvider.select((s) => s.isLoggedIn), (prev, loggedIn) {
      if (prev == true && !loggedIn) reset();
    });
    _restore();
    return const MathZoroState();
  }

  Future<void> _restore() async {
    try {
      final json = await ref.read(secureStoreProvider).readJson(storageKey);
      if (json != null && !_touched && ref.read(sessionProvider).isLoggedIn) {
        state = MathZoroState.fromJson(json);
      }
    } catch (e) {
      debugPrint('MathZoro state restore failed: $e');
    } finally {
      if (!_ready.isCompleted) _ready.complete();
    }
  }

  void _set(MathZoroState next, {bool persist = true}) {
    _touched = true;
    state = next;
    if (persist) {
      ref.read(secureStoreProvider).writeJson(storageKey, next.toJson());
    }
  }

  /// `$reset()` / `sessionStorage.clear()` — called on logout and right
  /// before a new login (setUserInfo also set `selectedClass = null`).
  void reset() {
    _touched = true;
    state = const MathZoroState();
    ref.read(secureStoreProvider).delete(storageKey);
  }

  SessionState get _session => ref.read(sessionProvider);
  UserInfo? get _ui => _session.userInfo;

  ZslService get _zsl => ref.read(zslServiceProvider);

  // ── setters ──────────────────────────────────────────────────────────────

  void setAvailableClasses(List<dynamic> classes) => _set(state.copyWith(
      availableClasses: classes.map(asMap).whereType<Map<String, dynamic>>().toList()));

  /// `setMathZoroCourses(courses)` (also mirrored to sessionStorage on the web).
  void setMathZoroCourses(List<dynamic> courses) => _set(state.copyWith(
      mathZoroCourses: courses.map(asMap).whereType<Map<String, dynamic>>().toList()));

  void setInstituteMeta(Map<String, dynamic>? meta) =>
      _set(state.copyWith(instituteMeta: meta));

  /// `setLastOpenedChapter({ id, name, chapterIndex })`.
  void setLastOpenedChapter(Map<String, dynamic> chapter) =>
      _set(state.copyWith(lastOpenedChapter: chapter));

  void setSelectedActivityContext(Map<String, dynamic>? context) =>
      _set(state.copyWith(selectedActivityContext: context));

  /// `localStorage.setItem('subjectId', …)`.
  void setStoredSubjectId(String? subjectId) =>
      _set(state.copyWith(storedSubjectId: subjectId));

  /// `window.dispatchEvent(new CustomEvent('tickets-updated'))`.
  void dispatchTicketsUpdated() => _set(
      state.copyWith(ticketsUpdatedTick: state.ticketsUpdatedTick + 1),
      persist: false);

  /// Port of `setSelectedClass(classData)`: stores the selection and patches
  /// `userInfo`, `studentLoginData` and `batchDetails` exactly like the web.
  void setSelectedClass(dynamic classData) {
    final d = asMap(classData) ?? const <String, dynamic>{};
    final zslClassId = d['zsl_class_id'];
    final zslSubjectId = d['zsl_subject_id'];
    final courseId = d['course_id'];
    final courseTitle = d['course_title'];
    final batchId = d['batch_id'];
    final batchName = d['batch_name'];
    final classesId = d['classes_id'];
    final curriculaId = d['curricula_id'];
    final examBatchId = d['exam_batch_id'];
    final examCourseId = d['exam_course_id'];

    final selected = <String, dynamic>{
      'zsl_class_id': zslClassId,
      'zsl_subject_id': zslSubjectId,
      'course_id': courseId,
      'course_title': courseTitle,
      'batch_id': batchId,
      'batch_name': batchName,
      'classes_id': classesId,
      'curricula_id': curriculaId,
      'exam_batch_id': examBatchId,
      'exam_course_id': examCourseId,
      'mathzoroclassid': zslClassId,
    };

    ref.read(sessionProvider.notifier).patch((s) {
      var next = s;
      final ui = s.userInfo;
      if (ui != null) {
        next = next.copyWith(
            userInfo: _userInfoWithClass(ui, asInt(zslClassId), asInt(classesId)));
      }
      final sld = s.studentLoginData;
      if (sld != null) {
        next = next.copyWith(
          studentLoginData: StudentLoginData({
            ...sld.raw,
            'zsl_class_id': zslClassId,
            'zsl_subject_id': zslSubjectId,
            'course_id': courseId,
            'course_title': courseTitle,
            'batch_id': batchId,
            'batch_name': batchName,
            'classes_id': classesId,
            'curricula_id': curriculaId,
            'exam_batch_id': examBatchId,
            'exam_course_id': examCourseId,
          }),
        );
      }
      if (jsTruthy(batchId)) {
        next = next.copyWith(batchDetails: IdName(asInt(batchId), jsStr(batchName) ?? ''));
      }
      return next;
    });

    _set(state.copyWith(selectedClass: selected));
  }

  /// `storeAllClassData(item, instituteMeta, store)` from
  /// mathzorostudentloginpage.vue — used when the student has one class.
  void storeAllClassData(Map<String, dynamic> item, Map<String, dynamic> instituteMeta) {
    final selectedClass = <String, dynamic>{
      'zsl_class_id': item['zsl_class_id'],
      'zsl_subject_id': item['zsl_subject_id'],
      'course_id': item['course_id'],
      'course_title': item['course_title'],
      'batch_id': item['batch_id'],
      'batch_name': item['batch_name'],
      'classes_id': item['classes_id'],
      'curricula_id': item['curricula_id'],
      'exam_batch_id': item['exam_batch_id'],
      'exam_course_id': item['exam_course_id'],
      'mathzoroclassid': item['zsl_class_id'],
    };

    // setSelectedClass writes to store + sessionStorage (and userInfo).
    setSelectedClass(selectedClass);

    ref.read(sessionProvider.notifier).patch((s) {
      var next = s;
      final sld = s.studentLoginData;
      // Object.assign(store.studentLoginData, selectedClass)
      if (sld != null) {
        next = next.copyWith(studentLoginData: StudentLoginData({...sld.raw, ...selectedClass}));
      }
      return next.copyWith(
          batchDetails: IdName(asInt(item['batch_id']), jsStr(item['batch_name']) ?? ''));
    });

    final courses = asList(item['courses']);
    if (courses.isNotEmpty) {
      final plan = asMap(instituteMeta['plan']);
      setMathZoroCourses(courses.map((c) {
        final course = asMap(c) ?? const <String, dynamic>{};
        return <String, dynamic>{
          'course_id': course['id'],
          'title': course['title'],
          'zsl_class_id': course['zsl_class_id'],
          'zsl_subject_id': course['zsl_subject_id'],
          'is_math_zoro': course['is_math_zoro'] ?? false,
          'zone': course['zone'],
          'class_name': item['name'],
          'institute_name': instituteMeta['name'],
          'institute_logo': instituteMeta['logo'],
          'plan_id': plan?['id'] ?? instituteMeta['institute_plan_id'],
          'plan_name': plan?['name'],
          'plan_type': plan?['plan_type'],
          'start_date': plan?['start_date'],
          'end_date': plan?['end_date'],
        };
      }).toList());
    }
  }

  /// `storeAllClassData(item, instituteMeta)` of mathzoroclasschange.vue.
  /// That component defines the method twice; JavaScript keeps the second
  /// definition, which assigns `selectedClass` directly (no
  /// `setSelectedClass`) and maps the courses without `?? null / ?? false`
  /// defaults.
  void applyClassChangeSelection(
      Map<String, dynamic> item, Map<String, dynamic> instituteMeta) {
    final selectedClass = <String, dynamic>{
      'zsl_class_id': item['zsl_class_id'],
      'zsl_subject_id': item['zsl_subject_id'],
      'course_id': item['course_id'],
      'course_title': item['course_title'],
      'batch_id': item['batch_id'],
      'batch_name': item['batch_name'],
      'classes_id': item['classes_id'],
      'curricula_id': item['curricula_id'],
      'exam_batch_id': item['exam_batch_id'],
      'exam_course_id': item['exam_course_id'],
      'mathzoroclassid': item['zsl_class_id'],
    };

    // userStore.selectedClass = selectedClass (+ sessionStorage selected_class)
    _set(state.copyWith(selectedClass: selectedClass));

    ref.read(sessionProvider.notifier).patch((s) {
      var next = s;
      final ui = s.userInfo;
      if (ui != null) {
        next = next.copyWith(
          userInfo: _userInfoWithClass(
              ui, asInt(item['zsl_class_id']), asInt(item['classes_id'])),
        );
      }
      final sld = s.studentLoginData;
      if (sld != null) {
        next = next.copyWith(
            studentLoginData: StudentLoginData({...sld.raw, ...selectedClass}));
      }
      return next.copyWith(
          batchDetails: IdName(asInt(item['batch_id']), jsStr(item['batch_name']) ?? ''));
    });

    final courses = asList(item['courses']);
    if (courses.isNotEmpty) {
      final plan = asMap(instituteMeta['plan']);
      setMathZoroCourses(courses.map((c) {
        final course = asMap(c) ?? const <String, dynamic>{};
        return <String, dynamic>{
          'course_id': course['id'],
          'title': course['title'],
          'zsl_class_id': course['zsl_class_id'],
          'zsl_subject_id': course['zsl_subject_id'],
          'is_math_zoro': course['is_math_zoro'],
          'zone': course['zone'],
          'class_name': item['name'],
          'institute_name': instituteMeta['name'],
          'institute_logo': instituteMeta['logo'],
          'plan_id': plan?['id'] ?? instituteMeta['institute_plan_id'],
          'plan_name': plan?['name'],
          'plan_type': plan?['plan_type'],
          'start_date': plan?['start_date'],
          'end_date': plan?['end_date'],
        };
      }).toList());
    }
  }

  static UserInfo _userInfoWithClass(UserInfo u, int? zslClassId, int? classesId) => UserInfo(
        id: u.id,
        username: u.username,
        token: u.token,
        role: u.role,
    isLabAdmin: u.isLabAdmin,
        instituteId: u.instituteId,
        fullName: u.fullName,
        email: u.email,
        studentId: u.studentId,
        examUserId: u.examUserId,
        institutePlanId: u.institutePlanId,
        zsl: u.zsl,
        classesId: classesId,
        zslClassId: zslClassId,
        isMathZoro: u.isMathZoro,
        phone: u.phone,
        mathzoroClassId: zslClassId,
      );

  // ── auth (forgotPassword / resetPassword) ────────────────────────────────

  Future<dynamic> forgotPassword(String email) =>
      ref.read(authServiceProvider).forgotPassword(email);

  Future<dynamic> resetPassword({
    required String email,
    required String otp,
    required String password,
    required String passwordConfirmation,
  }) =>
      ref.read(authServiceProvider).resetPassword(email, otp, password, passwordConfirmation);

  // ── ZSL content ──────────────────────────────────────────────────────────

  /// `getAllSubjects(instituteId, classId)` → `allsubject = res.data || res || []`.
  Future<dynamic> getAllSubjects(Object instituteId, Object classId) async {
    try {
      final res = await _zsl.getAllSubjects(instituteId, classId);
      final value = _dataOr(res, const []);
      _set(state.copyWith(allsubject: value), persist: false);
      return value;
    } catch (e) {
      debugPrint('Error fetching Subjects: $e');
      _set(state.copyWith(allsubject: const []), persist: false);
      rethrow;
    }
  }

  /// `getallchpaters(instituteId, classId, subjectId)`.
  Future<dynamic> getallchpaters(Object instituteId, Object classId, Object subjectId) async {
    try {
      final res = await _zsl.getAllChapters(instituteId, classId, subjectId);
      final value = _dataOr(res, const []);
      _set(state.copyWith(allchapters: value), persist: false);
      return value;
    } catch (e) {
      debugPrint('Error fetching Chapters: $e');
      _set(state.copyWith(allchapters: const []), persist: false);
      rethrow;
    }
  }

  /// `getZslLinks(instituteId, chapterId, languageId)` — `sub_user_id` is
  /// always taken from `userInfo.zsl`.
  Future<dynamic> getZslLinks(Object? instituteId, Object? chapterId,
      [Object? languageId]) async {
    final subUserId = jsStr(_ui?.zsl);
    if (!jsTruthy(instituteId) || !jsTruthy(chapterId)) {
      throw const ApiError('Institute ID and Chapter ID are required');
    }
    return _zsl.getChapterLinks(
      jsStr(instituteId)!,
      jsStr(chapterId)!,
      jsTruthy(languageId) ? jsStr(languageId) : null,
      subUserId,
    );
  }

  /// `getZslQuestions(activityId)`.
  Future<dynamic> getZslQuestions(String activityId) async {
    final instituteId = jsStr(_ui?.instituteId);
    final languageId = jsStr(_session.language.id);
    if (instituteId == null || instituteId.isEmpty) {
      throw const ApiError('Institute ID not available');
    }
    return _zsl.getQuestions(instituteId, activityId, languageId);
  }

  /// `submitZslQuiz({ activity_id, answers, classes_id? })`.
  Future<dynamic> submitZslQuiz({
    required String activityId,
    required List<Map<String, String>> answers,
    Object? classesId,
  }) async {
    final instituteId = jsStr(_ui?.instituteId) ?? '';
    final zslStudentId = jsStr(_ui?.zsl) ?? '';
    final selected = state.selectedClass;

    String truthy(dynamic v) => jsTruthy(v) ? jsStr(v)! : '';

    // persistedClassId is only set by eLabs library pages (not in this flavor).
    final classId = firstNonEmpty([
      truthy(classesId),
      truthy(selected?['zsl_class_id']),
      truthy(selected?['classes_id']),
      truthy(_session.classDetails?.id),
      truthy(_ui?.zslClassId),
      truthy(_ui?.classesId),
      truthy(state.selectedActivityContext?['classId']),
      truthy(state.mathZoroCourses.isNotEmpty
          ? state.mathZoroCourses.first['zsl_class_id']
          : null),
    ]);

    if (instituteId.isEmpty) throw const ApiError('Institute ID is missing');
    if (zslStudentId.isEmpty) throw const ApiError('Sub User ID (ZSL) is missing');
    if (classId.isEmpty) throw const ApiError('Class ID is missing for quiz submission');
    if (activityId.isEmpty) throw const ApiError('Activity ID is missing');
    if (answers.isEmpty) throw const ApiError('Answers are empty');

    return _zsl.submitQuiz({
      'institute_id': instituteId,
      'sub_user_id': zslStudentId,
      'classes_id': classId,
      'activity_id': activityId,
      'answers': answers,
    });
  }

  /// `getSubjectPerformance(subjectId, classesId?)`.
  Future<dynamic> getSubjectPerformance(String subjectId, [String? classesId]) async {
    final instituteId = jsStr(_ui?.instituteId);
    final subUserId = jsStr(_ui?.zsl);
    final finalClassesId = firstNonEmpty([
      classesId,
      jsStr(state.selectedClass?['zsl_class_id']),
      jsStr(state.selectedActivityContext?['classId']),
      jsStr(_ui?.zslClassId),
      jsStr(_ui?.classesId),
    ]);
    if (instituteId == null || instituteId.isEmpty) {
      throw const ApiError('Institute ID not available');
    }
    if (finalClassesId.isEmpty) throw const ApiError('Class ID not available');
    if (subUserId == null || subUserId.isEmpty) {
      throw const ApiError('Sub User ID not available');
    }
    return _zsl.getSubjectPerformance(instituteId, finalClassesId, subjectId, subUserId);
  }

  /// `getZslTickets()`.
  Future<dynamic> getZslTickets() async {
    final instituteId = jsStr(_ui?.instituteId);
    final subUserId = jsStr(_ui?.zsl);
    final classId = firstNonEmpty([
      jsStr(state.selectedClass?['zsl_class_id']),
      jsStr(state.selectedActivityContext?['classId']),
      jsStr(_ui?.zslClassId),
      jsStr(_session.classDetails?.id),
      jsStr(_ui?.classesId),
    ]);
    if (instituteId == null || instituteId.isEmpty) {
      throw const ApiError('Institute ID not available');
    }
    if (classId.isEmpty) throw const ApiError('Class ID not available');
    if (subUserId == null || subUserId.isEmpty) {
      throw const ApiError('Sub User ID not available');
    }
    return ref.read(gameTokensServiceProvider).getTickets(instituteId, classId, subUserId);
  }

  /// `individualrecordUsageAction(instructorId?, studentId?)`.
  Future<dynamic> individualrecordUsageAction([String? instructorId, String? studentId]) async {
    final instituteId = jsStr(_ui?.instituteId);
    if (instituteId == null || instituteId.isEmpty) {
      throw const ApiError('Institute ID not available');
    }
    return ref.read(usageTrackingServiceProvider).recordUsage({
      'institute_id': instituteId,
      'instructor_id': instructorId ?? jsStr(_session.instructorId),
      'student_id': studentId ?? jsStr(_ui?.studentId),
    });
  }

  // ── shell helpers ────────────────────────────────────────────────────────

  /// `getZslLanguages()`.
  Future<dynamic> getZslLanguages() =>
      ref.read(activityTrackingServiceProvider).getZslLanguages();

  /// `setLanguage(lang)`.
  void setLanguage(AppLanguage lang) => ref.read(sessionProvider.notifier).setLanguage(lang);

  /// `setClassDetails({ id, name, c_id })`.
  void setClassDetails({required Object? id, required String name, Object? cId}) =>
      ref.read(sessionProvider.notifier).setClassDetails(
          IdName(asInt(id), name, extra: {'c_id': cId}));

  /// `profilegetInstituteById()` — admins / institutes only, otherwise null.
  Future<dynamic> profilegetInstituteById() async {
    final ui = _ui;
    final id = ui?.instituteId;
    if (id != null && id != 0 && (ui?.role == Role.admin || ui?.role == Role.institute)) {
      return ref.read(instituteServiceProvider).getInstituteById(id);
    }
    return null;
  }

  /// `getClasses(institute_id_or_filter?, filter?)` — fills `institutes`
  /// (`{ id, year, c_id, students, … }`) and `classes`.
  Future<void> getClasses([Object? instituteIdOrFilter, String? filter]) async {
    Object? instituteId;
    String? finalFilter;
    if (instituteIdOrFilter == 'published') {
      instituteId = _ui?.instituteId;
      finalFilter = 'published';
    } else {
      instituteId = jsTruthy(instituteIdOrFilter) ? instituteIdOrFilter : _ui?.instituteId;
      finalFilter = filter;
    }
    if (!jsTruthy(instituteId)) return;

    final classService = ref.read(classServiceProvider);
    final data = asList(await classService.getAllClasses(instituteId!));
    final filtered = finalFilter == 'published'
        ? data.where((c) => asMap(c)?['status'] == 'published').toList()
        : data;

    final mapped = await Future.wait(filtered.map((raw) async {
      final item = asMap(raw) ?? const <String, dynamic>{};
      final counts = asMap(await classService.getClassesCount(instituteId!, item['id']));
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
        'is_admin': item['is_admin'] ?? false,
      };
    }));

    _set(
      state.copyWith(
        institutes: mapped,
        classes: [
          for (final m in mapped) {'id': m['id'], 'name': m['year'], 'status': m['status']}
        ],
      ),
      persist: false,
    );
  }

  /// `res.data || res || fallback`.
  static dynamic _dataOr(dynamic res, dynamic fallback) {
    final inner = asMap(res)?['data'];
    if (jsTruthy(inner)) return inner;
    if (jsTruthy(res)) return res;
    return fallback;
  }

  // ── Math Zone / Play Zone (studentmathzone.vue, playzone.vue) ────────────

  /// `getWhyToLearnSignedUrl(descriptionId)`.
  Future<dynamic> getWhyToLearnSignedUrl(String descriptionId) async {
    final instituteId = _ui?.instituteId;
    if (!jsTruthy(instituteId)) throw const ApiError('Institute ID not available');
    return _zsl.getWhyToLearnSignedUrl(jsStr(instituteId)!, descriptionId);
  }

  /// `getChapterReferenceSignedLink(chapter_id)`.
  Future<dynamic> getChapterReferenceSignedLink(String chapterId) async {
    final instituteId = _ui?.instituteId;
    if (!jsTruthy(instituteId)) throw const ApiError('Institute ID not available');
    return _zsl.getChapterReferenceSignedLink({
      'institute_id': jsStr(instituteId),
      'chapter_id': chapterId,
    });
  }

  /// `unlockZslActivity(activityId)` — the class id is only validated, the
  /// request itself does not send it (same as the web).
  Future<dynamic> unlockZslActivity(String activityId) async {
    final instituteId = jsStr(_ui?.instituteId);
    final subUserId = jsStr(_ui?.zsl);
    final classId = firstNonEmpty([
      jsStr(state.selectedActivityContext?['classId']),
      jsStr(_session.classDetails?.id),
      jsStr(_ui?.classesId),
    ]);
    if (instituteId == null || instituteId.isEmpty) {
      throw const ApiError('Institute ID not available');
    }
    if (classId.isEmpty) throw const ApiError('Class ID not available');
    if (subUserId == null || subUserId.isEmpty) {
      throw const ApiError('Sub User ID not available');
    }
    return ref.read(gameTokensServiceProvider).unlockActivity(instituteId, activityId, subUserId);
  }

  /// `getZslXp(classId?)`.
  Future<dynamic> getZslXp([Object? classId]) async {
    final instituteId = jsStr(_ui?.instituteId) ?? '';
    final subUserId = jsStr(_ui?.zsl) ?? '';
    final ctxClassId = state.selectedActivityContext?['classId'];
    final Object resolvedClassId =
        jsTruthy(classId) ? classId! : (jsTruthy(ctxClassId) ? ctxClassId as Object : '');
    return _zsl.getXp(instituteId, resolvedClassId, subUserId);
  }
}
