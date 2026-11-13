import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' show ImageFilter;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/external_link.dart';
import '../../core/utils/files.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/html_editor.dart';
import '../../widgets/web_content_view.dart';
import '../common/lms_handoff.dart';
import '../institutes/institute_widgets.dart' show FilePickField, LabeledCheckbox, SpinIcon;
import 'class_course_controller.dart';
import 'class_course_logic.dart';

part 'class_course_widgets.dart';
part 'class_course_grid.dart';
part 'class_course_detail.dart';
part 'class_course_outline.dart';
part 'class_course_preview.dart';
part 'class_course_dialogs.dart';
part 'class_course_content_dialogs.dart';

/// Port of `src/pages/class/ClassCourseCreate.vue` — the course grid of a
/// class, with create / edit / delete course, and per course the Overview
/// (curriculums & instructors), Manage (sections → chapters → concepts) and
/// Preview tabs.
///
/// Routed at `/classcoursecreate` (no route params; the class is the
/// session's `classDetails`), and embedded by the class list's Courses tab:
/// `ClassCourseCreatePage(embedded: true, classId: …, refresh: …,
/// canEdit: …, onCourseExpanded: …)` (= the Vue props `classId`, `refresh`,
/// `canEdit` and the `course-expanded` event).
class ClassCourseCreatePage extends ConsumerStatefulWidget {
  const ClassCourseCreatePage({
    super.key,
    this.classId,
    this.refresh = 0,
    this.canEdit = false,
    this.onCourseExpanded,
    this.embedded = false,
  });

  /// Vue prop `classId`; falls back to the session's `classDetails.id`.
  final Object? classId;

  /// Vue prop `refresh` — changing it reloads the class's courses.
  final int refresh;

  /// Vue prop `canEdit` (non-institute users who manage the class).
  final bool canEdit;

  /// `$emit('course-expanded', !!expandedCourse)`.
  final ValueChanged<bool>? onCourseExpanded;

  /// When embedded the page does not scroll by itself (the host scrolls).
  final bool embedded;

  @override
  ConsumerState<ClassCourseCreatePage> createState() => _ClassCourseCreatePageState();
}

/// `previewItem` — `{ type: 'course' | 'content', data }`.
class _PreviewItem {
  const _PreviewItem(this.type, this.data);
  final String type;
  final Map<String, dynamic>? data;
}

const Map<String, dynamic> _emptyUpdateForm = {
  'title': '',
  'short_name': '',
  'course_code': '',
  'description': '',
  'status': 'draft',
  'attach': null,
  'isMathPlay': false,
  'curriculum_id': '',
  'instructor_id': '',
  'class_id': null,
  'subject_id': '',
  'zone': '',
};

class _ClassCourseCreatePageState extends ConsumerState<ClassCourseCreatePage> {
  ClassCourseController get _ctrl => ref.read(classCourseControllerProvider.notifier);
  ClassCourseState get _store => ref.read(classCourseControllerProvider);

  String get _role => ref.read(sessionProvider).role;

  /// `role === Role.Institute || canEdit`
  bool get _canManage => _role == Role.institute || widget.canEdit;

  /// The `classId` prop (the route has none: the session's class is used).
  Object? get _classId => widget.classId ?? ref.read(sessionProvider).classDetails?.id;

  // ── data() ───────────────────────────────────────────────────────────────
  bool _isLoading = false;
  bool _isInitializing = false;
  String _expandedCourse = '';
  String _expandedSectionRow = '';
  String _expandedChapterRow = '';
  List<Map<String, dynamic>> _coursess = [];
  final Map<int, String> _activeTabs = {};
  Object? _selectedCurriculumId;
  String _courseZone = '';
  bool _isMathPlay = false;
  List<Map<String, dynamic>> _allClassesData = [];
  Object? _selectedCourseId;
  Object? _selectedChapterId;
  num? _openSectionId;
  num? _openChapterId;
  Map<String, dynamic>? _selectedCourseDetails;
  Map<String, dynamic>? _classDetails;
  bool _isLoadingCourseDetails = false;

  /// `previewUrl` — the image picked in the create dialog.
  UploadFile? _previewFile;
  String _statusString = 'draft';
  Map<String, dynamic> _form = {..._emptyUpdateForm};
  List<Map<String, dynamic>> _editAllClassesData = [];
  List<Map<String, dynamic>> _editSubjectsList = [];

  /// `imagePreview` — a URL, or the picked file ([_imagePreviewFile]).
  String _imagePreview = '';
  UploadFile? _imagePreviewFile;
  Map<String, dynamic>? _selectedSectionDetails;
  Map<String, dynamic>? _selectedChapterDetails;
  Object? _updateSectionOrder = '';
  Object? _updatechapterOrder = '';
  Object? _updatecontentOrder = '';
  _PreviewItem _previewItem = const _PreviewItem('course', null);
  final _searchQueryCourse = TextEditingController();
  String _lastSearch = '';
  bool _isAttachCurriculLoad = false;
  bool _isAttachINSLoad = false;

  /// Store `institutes` (class rows with `is_admin`) from lmsHandoff.
  List<dynamic> _institutes = const [];

  @override
  void initState() {
    super.initState();
    _searchQueryCourse.addListener(_onSearchQueryChanged);
    Future.microtask(_mountedHook);
  }

  @override
  void didUpdateWidget(covariant ClassCourseCreatePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // watch: classId
    if (widget.classId != oldWidget.classId && jsTruthy(widget.classId)) {
      _expandedSectionRow = '';
      _expandedChapterRow = '';
      _selectedCourseId = null;
      _openSectionId = null;
      _openChapterId = null;
      _setSelectedCourseDetails(null);
      _setExpandedCourse('');
      _guard(_fetchClassDetails);
    }
    // watch: refresh
    if (widget.refresh != oldWidget.refresh) _guard(_fetchClassDetails);
  }

  @override
  void dispose() {
    _searchQueryCourse.dispose();
    super.dispose();
  }

  /// `setState` for the part files' helpers.
  void _set(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  /// Runs [fn] ignoring errors — the API client already toasted them and the
  /// web only logged them.
  Future<void> _guard(Future<void> Function() fn) async {
    try {
      await fn();
    } catch (_) {}
  }

  // ── watchers ─────────────────────────────────────────────────────────────

  /// watch: statusString → courseForm.status
  void _setStatusString(String v) {
    if (v == _statusString) return;
    _statusString = v;
    _ctrl.patchCourseForm({'status': v});
  }

  /// watch: selectedCurriculumId → courseForm.curriculum_id
  void _setSelectedCurriculumId(Object? v) {
    if (v == _selectedCurriculumId) return;
    _selectedCurriculumId = v;
    _ctrl.patchCourseForm({'curriculum_id': v?.toString() ?? ''});
  }

  /// watch: expandedCourse → emit('course-expanded')
  void _setExpandedCourse(String v) {
    if (v == _expandedCourse) return;
    _expandedCourse = v;
    widget.onCourseExpanded?.call(v.isNotEmpty);
  }

  /// watch: selectedCourseDetails (immediate) → reset the preview selection.
  void _setSelectedCourseDetails(Map<String, dynamic>? v) {
    _selectedCourseDetails = v;
    _openSectionId = null;
    _openChapterId = null;
    _previewItem = _PreviewItem('course', v);
  }

  /// watch: searchQueryCourse — clearing the box reloads the class courses.
  void _onSearchQueryChanged() {
    final text = _searchQueryCourse.text;
    if (text == _lastSearch) return;
    _lastSearch = text;
    if (text.trim().isEmpty) _guard(_resetCourse);
  }

  // ── computed ─────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _filteredClasses {
    final instituteId = ref.read(sessionProvider).userInfo?.instituteId;
    if (!jsTruthy(instituteId) || _allClassesData.isEmpty) return const [];
    return _allClassesData;
  }

  List<Map<String, dynamic>> get _currentSectionChapters {
    if (_selectedCourseDetails == null || _openSectionId == null) return const [];
    for (final s in mapsOf(_selectedCourseDetails!['sections'])) {
      if (s['id'] == _openSectionId) return mapsOf(s['chapters']);
    }
    return const [];
  }

  List<Map<String, dynamic>> get _currentChapterContents {
    if (_openChapterId == null) return const [];
    for (final c in _currentSectionChapters) {
      if (c['id'] == _openChapterId) return mapsOf(c['contents']);
    }
    return const [];
  }

  Object? get _selectedConceptId {
    if (_previewItem.type != 'content') return null;
    return _previewItem.data?['id'];
  }

  // ── mounted() ────────────────────────────────────────────────────────────

  Future<void> _mountedHook() async {
    _set(() => _isLoading = true);
    try {
      await _fetchClassDetails();
      if (_role != 'student') {
        await _ctrl.fetchCurriculums();
        await _ctrl.getAllInstructors();
        await _ctrl.loadAllClasses();
        _allClassesData = _store.allClasses;
      }
      _setStatusString(jsTruthy(_store.courseForm['status']) ? 'draft' : 'published');
      final curriculumId = _store.courseForm['curriculum_id'];
      if (jsTruthy(curriculumId)) {
        _setSelectedCurriculumId(jsNumber(curriculumId));
      } else if (_store.curriculums.isNotEmpty) {
        final first = _store.curriculums.first['id'];
        _setSelectedCurriculumId(first);
        _ctrl.patchCourseForm({'curriculum_id': '$first'});
      }
    } catch (_) {
      // Unhandled on the web; the API client already toasted.
    } finally {
      _set(() => _isLoading = false);
    }
  }

  // ── methods ──────────────────────────────────────────────────────────────

  /// Component `fetchClassDetails()` — the class's courses (all of them for
  /// managers, only published ones otherwise).
  Future<void> _fetchClassDetails() async {
    final response = await _ctrl.fetchClassDetails();
    final courses = [for (final c in mapsOf(response?['courses'])) Map<String, dynamic>.from(c)];
    _set(() {
      _classDetails = response;
      _coursess = _canManage ? courses : [for (final c in courses) if (c['status'] == 'published') c];
    });
  }

  /// Shows `alert(message)`.
  Future<void> _alert(String message) => showAppDialog<void>(
        context,
        builder: (ctx) => AppDialogFrame(
          description: message,
          maxWidth: 384,
          actions: [AppButton(label: 'OK', onPressed: () => Navigator.of(ctx).pop())],
        ),
      );

  // create course

  Future<void> _openCreateCourseDialog() async {
    _isInitializing = true;
    _ctrl.patchCourseForm({
      'title': '',
      'short_name': '',
      'course_code': '',
      'instructor_id': '',
      'description': '',
      'status': 'draft',
    });
    final cid = _classDetails?['curricula_id'];
    _setSelectedCurriculumId(jsTruthy(cid) ? jsNumber(cid) : null);
    _ctrl.patchCourseForm({
      'curriculum_id': jsTruthy(_selectedCurriculumId) ? '$_selectedCurriculumId' : '',
      'allclass': defaultZslClassId(_classDetails, _filteredClasses),
      'image': null,
    });
    _isInitializing = false;
    _previewFile = null;
    _courseZone = '';
    _isMathPlay = false;
    _ctrl.getInstructorsdropdown(_classId);
    await showAppDialog<void>(context, builder: (_) => _CreateCourseDialog(s: this));
  }

  /// `loadSubjectsForSelectedClasses()` (on picking a class in the create dialog).
  Future<void> _loadSubjectsForSelectedClasses() async {
    if (_isInitializing) return;
    try {
      final instituteId = ref.read(sessionProvider).userInfo?.instituteId;
      if (!jsTruthy(instituteId)) return;
      await _ctrl.getAllSubjects(instituteId!, _store.courseForm['allclass'] ?? '');
    } catch (_) {}
  }

  /// `onSubmit()` — returns true when the dialog should close.
  Future<bool> _onSubmit() async {
    if (jsTruthy(_selectedCurriculumId)) {
      _ctrl.patchCourseForm({'curriculum_id': '$_selectedCurriculumId'});
    } else if (_classDetails != null && _classDetails!.containsKey('curricula_id')) {
      // `classDetails.curricula_id.toString()` (throws on null like the web).
      final c = _classDetails!['curricula_id'];
      if (c == null) return false;
      _ctrl.patchCourseForm({'curriculum_id': '$c'});
    } else {
      return false; // 'Curriculum ID is missing'
    }
    _ctrl.patchCourseForm({'is_math_zoro': _isMathPlay, 'zone': _courseZone});

    final success = await _ctrl.createCourse('${_classId ?? 'undefined'}');
    if (!success) return false;
    await _guard(_fetchClassDetails);
    _setSelectedCurriculumId(null);
    _set(() {
      _previewFile = null;
      _isMathPlay = false;
      _courseZone = '';
    });
    return true;
  }

  // update course

  Future<void> _openUpdateCourseDialog(Object? courseId) async {
    _selectedCourseId = courseId;
    _imagePreview = '';
    _imagePreviewFile = null;
    _isLoadingCourseDetails = true;
    var open = false;

    await _guard(_ctrl.fetchCurriculums);
    await _guard(_ctrl.getAllInstructors);
    try {
      await _ctrl.loadAllClasses();
      _editAllClassesData = _store.allClasses;
    } catch (_) {
      _editAllClassesData = [];
    }

    try {
      final details = await _ctrl.fetchCourseDetails(courseId);
      if (details != null) {
        final status = details['status'];
        _form = {
          ..._form,
          'title': _jsOrEmpty(details['title']),
          'short_name': _jsOrEmpty(details['short_name']),
          'course_code': _jsOrEmpty(details['course_code']),
          'description': _jsOrEmpty(details['description']),
          'zone': _jsOrEmpty(details['zone']),
          'status': const ['published', 'draft', 'archived'].contains(status) ? status : 'draft',
          'instructor_id': details['instructor_id']?.toString() ?? '',
          'curriculum_id': dig(details, ['curriculums', 0, 'id'])?.toString() ?? '',
          'isMathPlay': details['is_math_zoro'] == true,
          'attach': null,
          'class_id': details['zsl_class_id'],
        };
        _imagePreview = _jsOrEmpty(jsTruthy(details['image']) ? details['image'] : details['attach']);
        if (jsTruthy(_form['class_id'])) {
          try {
            await _loadEditSubjects(_form['class_id']);
            _form['subject_id'] = details['zsl_subject_id']?.toString() ?? '';
          } catch (_) {
            _form['subject_id'] = '';
          }
        } else {
          _form['subject_id'] = '';
        }
        _set(() => _setSelectedCourseDetails(Map<String, dynamic>.from(details)));
        open = true;
      }
    } catch (_) {
    } finally {
      _isLoadingCourseDetails = false;
    }
    if (!open || !mounted) return;
    await showAppDialog<void>(context, builder: (_) => _UpdateCourseDialog(s: this));
  }

  /// `loadEditSubjects(classId)`
  Future<void> _loadEditSubjects(Object? classId) async {
    try {
      final instituteId = ref.read(sessionProvider).userInfo?.instituteId;
      if (!jsTruthy(instituteId) || !jsTruthy(classId)) return;
      _editSubjectsList = await _ctrl.getAllSubjects(instituteId!, classId!);
    } catch (_) {
      _editSubjectsList = [];
    }
  }

  /// `onEditClassChange(classId)`
  Future<void> _onEditClassChange(Object? classId) async {
    if (_isLoadingCourseDetails) return;
    _form['subject_id'] = '';
    _editSubjectsList = [];
    if (jsTruthy(classId)) await _loadEditSubjects(classId);
  }

  /// `CourseUpdate()` — returns true when the dialog should close.
  Future<bool> _courseUpdate() async {
    if (!jsTruthy(_selectedCourseId)) return false;
    try {
      await _ctrl.updateCourse('$_selectedCourseId', _form);
      _imagePreview = '';
      _imagePreviewFile = null;
      _guard(_fetchClassDetails);
      return true;
    } catch (_) {
      return false;
    }
  }

  // delete course

  void _openDeleteCourseDialog(Map<String, dynamic> course) {
    showAppDialog<void>(
      context,
      builder: (_) => _ConfirmDeleteDialog(
        what: 'Are you sure you want to detach this Course',
        name: '${course['title'] ?? ''}',
        onYes: (close) async {
          try {
            await _ctrl.deleteCourse(course['id'] as Object);
            close();
            await _guard(_fetchClassDetails);
          } catch (_) {}
        },
      ),
    );
  }

  // curriculum on a course

  Future<void> _attachCurriculum(Map<String, dynamic> course) async {
    final curriculumId = course['selectedCourseCurriculumId'];
    final courseId = _selectedCourseId?.toString() ?? course['id']?.toString() ?? '';
    _set(() => _isAttachCurriculLoad = true);
    try {
      await _ctrl.attachCurriculumToCourse(curriculumId, courseId);
      final details = _selectedCourseDetails;
      if (details == null) throw StateError('selectedCourseDetails is null');
      Map<String, dynamic>? attached;
      for (final c in _store.curriculums) {
        if (c['id'] == curriculumId) attached = c;
      }
      if (attached != null && details['curriculums'] is List) {
        details['curriculums'] = [...asList(details['curriculums']), attached];
      } else {
        details['curriculums'] = [attached];
      }
      course['selectedCourseCurriculumId'] = null;
      course['selectedCourseCurriculumName'] = '';
      final fresh = await _ctrl.fetchCourseDetails(courseId);
      _set(() => _setSelectedCourseDetails(fresh == null ? null : Map<String, dynamic>.from(fresh)));
    } catch (_) {
    } finally {
      _set(() => _isAttachCurriculLoad = false);
    }
  }

  void _openDeleteCurriculumDialog(Map<String, dynamic> course, Map<String, dynamic> curriculum) {
    showAppDialog<void>(
      context,
      builder: (_) => _ConfirmDetachDialog(
        message: 'Are you sure you want to detach this curriculum from the course?',
        onYes: (close) => _detachCurriculum(course, curriculum, close),
      ),
    );
  }

  Future<void> _detachCurriculum(Map<String, dynamic> course, Map<String, dynamic> curriculum, VoidCallback close) async {
    if (!jsTruthy(course['id']) || !jsTruthy(curriculum['id'])) {
      await _alert('Missing course or curriculum ID.');
      return;
    }
    _set(() => _isLoading = true);
    try {
      await _ctrl.removeCurriculumFromCourse('${curriculum['id']}', '${course['id']}');
      final details = _selectedCourseDetails;
      if (details != null && details['curriculums'] is List) {
        details['curriculums'] = [
          for (final c in asList(details['curriculums']))
            if (asMap(c)?['id'] != curriculum['id']) c,
        ];
      }
      close();
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  // instructor on a course

  void _selectInstructorForCourse(Map<String, dynamic> course, Map<String, dynamic> instructor) => _set(() {
        course['selectedInstructorId'] = instructor['id'];
        course['selectedInstructorName'] = instructorDisplayName(instructor);
      });

  Future<void> _attachInstructor(Map<String, dynamic> course) async {
    final instructorId = course['selectedInstructorId']?.toString();
    final courseId = _selectedCourseId?.toString() ?? course['id']?.toString() ?? 'undefined';
    _set(() => _isAttachINSLoad = true);
    try {
      await _ctrl.attachInstructorToCourse(courseId, instructorId);
      course['selectedInstructorId'] = null;
      course['selectedInstructorName'] = '';
      final fresh = await _ctrl.fetchCourseDetails(courseId);
      _set(() => _setSelectedCourseDetails(fresh == null ? null : Map<String, dynamic>.from(fresh)));
    } catch (_) {
    } finally {
      _set(() => _isAttachINSLoad = false);
    }
  }

  void _openDeleteInstructorDialog(Map<String, dynamic> instructor) {
    showAppDialog<void>(
      context,
      builder: (_) => _ConfirmDetachDialog(
        message: 'Are you sure you want to detach this instructor?',
        onYes: (close) => _detachInstructor(instructor, close),
      ),
    );
  }

  Future<void> _detachInstructor(Map<String, dynamic> instructor, VoidCallback close) async {
    if (!jsTruthy(_selectedCourseId)) {
      await _alert('Missing instructor or course');
      return;
    }
    _set(() => _isLoading = true);
    try {
      await _ctrl.removeInstructorFromCourse('${instructor['id']}', '$_selectedCourseId');
      final details = _selectedCourseDetails;
      if (details != null && details['instructors'] is List) {
        details['instructors'] = [
          for (final i in asList(details['instructors']))
            if (asMap(i)?['id'] != instructor['id']) i,
        ];
      }
      close();
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  // course selection / tabs

  /// Normalises a `fetchCourseDetails` response the way the page did.
  Map<String, dynamic> _withStatus(Map<String, dynamic> response) {
    final details = Map<String, dynamic>.from(response);
    final status = '${response['status'] ?? 'draft'}'.toLowerCase();
    details['status'] = status;
    details['selectedStatus'] = status;
    return details;
  }

  Future<void> _onCourseSelect(Map<String, dynamic> course, int idx) async {
    _selectedCourseId = course['id'];
    _ctrl.setCourseId(course['id']);
    _set(() {
      _expandedSectionRow = '';
      _expandedChapterRow = '';
      _openSectionId = null;
      _openChapterId = null;
      _setExpandedCourse('course-$idx');
      _isLoading = true;
    });
    try {
      final response = await _ctrl.fetchCourseDetails(course['id']);
      final details = _withStatus(response!);
      final user = asMap(dig(response, ['instructor', 'user']));
      details['createdInstructorName'] = user != null ? '${user['first_name']} ${user['last_name']}' : 'N/A';
      details['instructors'] = response['instructors'] is List ? response['instructors'] : <dynamic>[];
      _set(() => _setSelectedCourseDetails(details));
      await _ctrl.fetchSections(course['id'] as Object);
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  Future<void> _onPreviewTabClick(Object? courseId, int idx) async {
    _set(() {
      _activeTabs[idx] = 'preview';
      _isLoading = true;
    });
    try {
      final response = await _ctrl.fetchCourseDetails(courseId);
      final details = _withStatus(response!);
      details['instructors'] = response['instructors'] is List ? response['instructors'] : <dynamic>[];
      _set(() => _setSelectedCourseDetails(details));
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  // sections

  void _openCreateSectionDialog() {
    showAppDialog<void>(
      context,
      builder: (_) => _NameOrderDialog(
        heading: 'Create a Section',
        nameLabel: 'Section Name',
        namePlaceholder: 'Enter Section Name',
        submitLabel: 'Create',
        onSubmit: (name, order, close) async {
          try {
            await _ctrl.createSection(name, jsNumber(order));
            if (_selectedCourseId != null) await _ctrl.fetchSections(_selectedCourseId!);
            close();
          } catch (_) {}
        },
      ),
    );
  }

  Future<void> _openSectionUpdateDialog(Object? courseId, Object? sectionId) async {
    if (!jsTruthy(courseId) || !jsTruthy(sectionId)) return;
    _set(() => _isLoading = true);
    try {
      final details = await _ctrl.fetchCourseDetails(courseId);
      Map<String, dynamic>? section;
      for (final s in mapsOf(details!['sections'])) {
        if (s['id'] == sectionId) section = s;
      }
      _selectedSectionDetails = section;
      if (section != null) _updateSectionOrder = section['order'];
    } catch (_) {
      _selectedSectionDetails = null;
    } finally {
      _set(() => _isLoading = false);
    }
    if (!mounted) return;
    final section = _selectedSectionDetails;
    await showAppDialog<void>(
      context,
      builder: (_) => _NameOrderDialog(
        heading: 'Edit Section',
        nameLabel: 'Section Name',
        namePlaceholder: 'Enter Section Name',
        submitLabel: 'Update',
        solid: true,
        showName: section != null,
        initialName: '${section?['name'] ?? ''}',
        initialOrder: '${_updateSectionOrder ?? ''}',
        onSubmit: (name, order, close) async {
          final current = _selectedSectionDetails;
          if (current == null || !jsTruthy(current['id'])) return; // 'No section selected to update'
          current['name'] = name;
          _updateSectionOrder = order;
          try {
            await _ctrl.updateSection(current['id'] as Object, name, jsNumber(order));
            close();
            if (_selectedCourseId != null) await _ctrl.fetchSections(_selectedCourseId!);
          } catch (_) {}
        },
      ),
    );
  }

  Future<void> _onSectionSelect(Map<String, dynamic> section) async {
    _ctrl.setSectionId(section['id']);
    _set(() => _isLoading = true);
    try {
      await _ctrl.fetchChapters(section['id'] as Object);
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  void _openDeleteSectionDialog(Map<String, dynamic> section) => _openWipDeleteDialog(
        'Are you sure you want to delete this Section',
        '${section['name'] ?? ''}',
      );

  /// The section / chapter / concept delete dialogs only `alert('work in progress....')`.
  void _openWipDeleteDialog(String what, String name) {
    showAppDialog<void>(
      context,
      builder: (_) => _ConfirmDeleteDialog(
        what: what,
        name: name,
        onYes: (close) async {
          await _alert('work in progress....');
          close();
        },
      ),
    );
  }

  // chapters

  void _openCreateChapterDialog() {
    showAppDialog<void>(
      context,
      builder: (_) => _NameOrderDialog(
        heading: 'Create a Chapter',
        nameLabel: 'Chapter Name',
        namePlaceholder: 'Enter Chapter Name',
        submitLabel: 'Create',
        onSubmit: (name, order, close) async {
          try {
            await _ctrl.createChapter(name, jsNumber(order));
            close();
          } catch (_) {}
        },
      ),
    );
  }

  Future<void> _openChapterUpdateDialog(Object? courseId, Object? sectionId, Object? chapterId) async {
    if (jsTruthy(courseId) && jsTruthy(sectionId) && jsTruthy(chapterId)) {
      try {
        final details = await _ctrl.fetchCourseDetails(courseId);
        Map<String, dynamic>? section;
        for (final s in mapsOf(details!['sections'])) {
          if (s['id'] == sectionId) section = s;
        }
        if (section != null) {
          _selectedSectionDetails = section;
          for (final c in mapsOf(section['chapters'])) {
            if (c['id'] == chapterId) {
              _selectedChapterDetails = c;
              _updatechapterOrder = c['order'];
            }
          }
        }
      } catch (_) {}
    }
    if (!mounted) return;
    final chapter = _selectedChapterDetails;
    await showAppDialog<void>(
      context,
      builder: (_) => _NameOrderDialog(
        heading: 'Edit Chapter',
        nameLabel: 'Chapter Name',
        namePlaceholder: 'Enter Chapter Name',
        submitLabel: 'Update',
        solid: true,
        showName: chapter != null,
        initialName: '${chapter?['name'] ?? ''}',
        initialOrder: '${_updatechapterOrder ?? ''}',
        onSubmit: (name, order, close) async {
          final current = _selectedChapterDetails;
          if (current == null || !jsTruthy(current['id'])) return; // 'No chapter selected for update'
          current['name'] = name;
          _updatechapterOrder = order;
          try {
            await _ctrl.updateChapter(current['id'] as Object, name, jsNumber(order));
            final sectionId = _selectedSectionDetails?['id'];
            if (jsTruthy(sectionId)) await _ctrl.fetchChapters(sectionId as Object);
            close();
          } catch (_) {}
        },
      ),
    );
  }

  Future<void> _onChapterSelect(Map<String, dynamic> chapter) async {
    _selectedChapterId = chapter['id'];
    _ctrl.setChapterId(chapter['id']);
    _set(() => _isLoading = true);
    try {
      await _ctrl.fetchContents(chapter['id'] as Object);
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  void _openDeleteChapterDialog(Map<String, dynamic> chapter) => _openWipDeleteDialog(
        'Are you sure you want to delete the chapter',
        '${chapter['name'] ?? ''}',
      );

  // concepts (contents)

  void _openConceptDialog(Map<String, dynamic> chapter) {
    _selectedChapterId = chapter['id'];
    _ctrl.setChapterId(chapter['id']);
    _ctrl.setContentForm(const {
      'name': '',
      'type': 'html',
      'url': '',
      'file': null,
      'zslactvity': '',
      'html_content': '',
      'order': '',
    });
    showAppDialog<void>(context, builder: (_) => _CreateConceptDialog(s: this));
  }

  /// `onContentFileChange` — shared by the create and edit concept dialogs.
  Future<void> _onContentFileChange() async {
    final file = await pickUploadFile();
    if (file == null) return;
    _ctrl.patchContentForm({'file': file});
    _ctrl.patchSelectedContentDetails({
      'file': file,
      'url': file.path != null ? Uri.file(file.path!).toString() : '',
    });
  }

  /// `createContent()` — returns true when the dialog should close.
  Future<bool> _createContent(String order) async {
    try {
      _ctrl.patchContentForm({'order': order});
      await _ctrl.createContent();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _openContentUpdateDialog(Object? courseId, Object? sectionId, Object? chapterId, Object? contentId) async {
    if (jsTruthy(courseId) && jsTruthy(sectionId) && jsTruthy(chapterId) && jsTruthy(contentId)) {
      try {
        final details = await _ctrl.fetchCourseDetails(courseId);
        Map<String, dynamic>? content;
        for (final s in mapsOf(details!['sections'])) {
          if (s['id'] != sectionId) continue;
          for (final c in mapsOf(s['chapters'])) {
            if (c['id'] != chapterId) continue;
            for (final ct in mapsOf(c['contents'])) {
              if (ct['id'] == contentId) content = ct;
            }
          }
        }
        if (content != null) {
          _updatecontentOrder = content['order'];
          _ctrl.setSelectedContentDetails({
            'id': content['id'],
            'name': _jsOrEmpty(content['name']),
            'type': _jsOrEmpty(content['type']),
            'url': _jsOrEmpty(content['url']),
            'html_content': _jsOrEmpty(content['content']),
            'order': '',
            'file': null,
          });
        }
      } catch (_) {}
    }
    // `<Dialog v-if="selectedContentDetails.id">`
    if (!mounted || _store.selectedContentDetails['id'] == null) return;
    await showAppDialog<void>(
      context,
      builder: (_) => _UpdateConceptDialog(
        key: ValueKey(_store.selectedContentDetails['id']),
        s: this,
      ),
    );
  }

  /// `contentUpdate(contentId)` — the dialog closes afterwards either way.
  Future<void> _contentUpdate(Object? contentId, String order) async {
    _updatecontentOrder = order;
    final n = jsNumber(order);
    _ctrl.patchSelectedContentDetails({'order': n ?? double.nan});
    try {
      await _ctrl.updateContent(contentId);
      if (_selectedChapterId != null) await _ctrl.fetchContents(_selectedChapterId!);
    } catch (_) {}
  }

  void _openDeleteContentDialog(Map<String, dynamic> content) => _openWipDeleteDialog(
        'Are you sure you want to delete the concept',
        '${content['name'] ?? ''}',
      );

  void _handleContentClick(Map<String, dynamic> content) {
    showAppDialog<void>(context, builder: (_) => _ContentPreviewDialog(content: content));
  }

  // preview tab selects

  void _handleSectionSelect(String? val) => _set(() {
        _openSectionId = num.tryParse(val ?? '');
        _openChapterId = null;
        _previewItem = _PreviewItem('course', _selectedCourseDetails);
      });

  void _handleChapterSelect(String? val) => _set(() {
        _openChapterId = num.tryParse(val ?? '');
        _previewItem = _PreviewItem('course', _selectedCourseDetails);
      });

  void _handleConceptSelect(String? val) {
    final id = num.tryParse(val ?? '');
    for (final c in _currentChapterContents) {
      if (c['id'] == id) {
        _set(() => _previewItem = _PreviewItem('content', c));
        return;
      }
    }
  }

  // search

  Future<void> _searchCourseByName() async {
    if (_searchQueryCourse.text.trim().isEmpty) return;
    try {
      await _ctrl.searchCourse(_searchQueryCourse.text);
    } catch (_) {}
    _set(() => _coursess = [for (final c in _store.courses) Map<String, dynamic>.from(c)]);
  }

  Future<void> _resetCourse() async {
    _searchQueryCourse.text = '';
    await _fetchClassDetails();
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.watch(classCourseControllerProvider);
    ref.watch(sessionProvider.select((s) => s.role));
    // `institutes` (the class list rows) are written by the class list screen.
    _institutes = asList(ref.watch(lmsHandoffProvider)['institutes']);
    final expanded = _expandedCourse.isNotEmpty;
    final dark = context.isDark;

    final body = _OuterCard(
      expanded: expanded,
      child: Padding(
        padding: EdgeInsets.all(expanded ? 0 : 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!expanded) ...[
              _CourseHeader(s: this),
              const SizedBox(height: 24),
            ],
            _InnerCard(
              expanded: expanded,
              child: _coursess.isEmpty
                  ? _EmptyCourses(s: this)
                  : expanded
                      ? _expandedView()
                      : _CourseGrid(s: this),
            ),
          ],
        ),
      ),
    );

    final content = widget.embedded
        ? body
        : SingleChildScrollView(
            padding: EdgeInsets.all(context.isSm ? 24 : 12),
            child: body,
          );
    return DefaultTextStyle.merge(
      style: TextStyle(color: dark ? AppColors.darkForeground : AppColors.foreground),
      child: LoadingOverlay(loading: _isLoading, child: content),
    );
  }

  Widget _expandedView() {
    final idx = int.tryParse(_expandedCourse.replaceFirst('course-', ''));
    if (idx == null || idx < 0 || idx >= _coursess.length) return const SizedBox.shrink();
    return _CourseDetail(s: this, course: _coursess[idx], idx: idx);
  }
}

/// `x || ''` for a template string.
String _jsOrEmpty(Object? v) => jsTruthy(v) ? '$v' : '';
