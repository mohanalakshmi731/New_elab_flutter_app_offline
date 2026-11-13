import 'dart:async';
import 'dart:convert';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/external_link.dart';
import '../../core/utils/files.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/html_editor.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/web_content_view.dart';
import '../institutes/institute_widgets.dart' show LabeledCheckbox, SpinIcon;
import '../users/users_widgets.dart' show FileInputField, UploadPreview;
import 'course_list_logic.dart';
import 'courses_controller.dart';

part 'course_list_widgets.dart';
part 'course_list_tabs.dart';
part 'course_list_grid.dart';
part 'course_list_expanded.dart';
part 'course_list_outline.dart';
part 'course_list_preview.dart';
part 'course_list_dialogs.dart';
part 'course_list_course_update.dart';

/// Port of `src/pages/course/courselist.vue`, embedded by the class list
/// (`<CourseList :key :external-active-tab :hide-triggers @course-expanded>`).
///
/// Curriculum tab (table + create/edit/delete) and course tab (filters, card
/// grid, and the expanded course with its Overview / Manage / Preview tabs).
/// Store state lives in [coursesControllerProvider]; the component's
/// `data()` lives in the widget state, so re-keying the widget resets it.
///
/// The widget sizes itself to its content; when the parent gives it a
/// bounded height it scrolls on its own.
class CourseListView extends ConsumerStatefulWidget {
  const CourseListView({super.key, this.externalActiveTab = '', this.hideTriggers = false, this.onCourseExpanded});

  /// `externalActiveTab` prop (`''` = let the component pick).
  final String externalActiveTab;

  /// `hideTriggers` prop.
  final bool hideTriggers;

  /// `$emit('course-expanded', !!newVal)`.
  final ValueChanged<bool>? onCourseExpanded;

  @override
  ConsumerState<CourseListView> createState() => _CourseListViewState();
}

/// `previewItem: { type: 'course' | 'content', data }`
typedef _PreviewItem = ({String type, Map<String, dynamic>? data});

/// The edit-course `form` of `data()`.
class _CourseForm {
  final title = TextEditingController();
  final shortName = TextEditingController();
  final courseCode = TextEditingController();
  final description = TextEditingController();
  String status = 'published';
  UploadFile? attach;
  bool isMathPlay = false;
  String curriculumId = '';
  String instructorId = '';
  Object? classId;
  String subjectId = '';
  String zone = '';

  Map<String, dynamic> toMap() => {
    'title': title.text,
    'short_name': shortName.text,
    'course_code': courseCode.text,
    'description': description.text,
    'status': status,
    'attach': attach,
    'isMathPlay': isMathPlay,
    'curriculum_id': curriculumId,
    'instructor_id': instructorId,
    'class_id': classId,
    'subject_id': subjectId,
    'zone': zone,
  };

  void dispose() {
    for (final c in [title, shortName, courseCode, description]) {
      c.dispose();
    }
  }
}

class _CourseListViewState extends ConsumerState<CourseListView> {
  // ── data() ────────────────────────────────────────────────────────────
  late String _activeTab;
  bool _isLoading = false;
  bool _isListLoading = false;
  String? _expandedCourse;
  String _expandedSectionRow = '';
  String _expandedChapterRow = '';
  final _newCurriculum = TextEditingController();
  List<Map<String, dynamic>> _coursess = [];
  final Map<int, String> _activeTabs = {};
  String _selectedCurriculum = '';
  final _newSection = TextEditingController();
  final _sectionOrder = TextEditingController();
  final _updateSectionOrder = TextEditingController();
  final _newChapter = TextEditingController();
  final _chapterOrder = TextEditingController();
  final _updatechapterOrder = TextEditingController();
  Object? _selectedCourseId;
  final _contentOrder = TextEditingController();
  final _updatecontentOrder = TextEditingController();
  Object? _selectedChapterId;
  Map<String, dynamic>? _selectedContent;
  Map<String, dynamic>? _selectedCourseDetails;
  final _form = _CourseForm();
  List<Map<String, dynamic>> _editAllClassesData = [];
  List<Map<String, dynamic>> _editSubjectsList = [];

  /// `imagePreview` — a URL, or [_imagePreviewFile] for a picked image
  /// (`URL.createObjectURL(file)`).
  String _imagePreview = '';
  UploadFile? _imagePreviewFile;
  bool _isCourseDeleteOpen = false;
  Map<String, dynamic>? _selectedSectionDetails;
  Map<String, dynamic>? _selectedChapterDetails;
  Map<String, dynamic>? _courseForDelete;
  Map<String, dynamic>? _curriculumToDelete;
  Map<String, dynamic>? _instructorToDelete;
  String _statuscourse = 'all';
  Map<String, dynamic>? _courseToDelete;
  Map<String, dynamic>? _sectionToDelete;
  Map<String, dynamic>? _chapterToDelete;
  Map<String, dynamic>? _contentToDelete;
  _PreviewItem _previewItem = (type: 'course', data: null);
  final _searchQueryCurriculum = TextEditingController();
  final _searchQueryCourse = TextEditingController();
  bool _isCreateBtnLoading = false;
  bool _isAttachCurriculLoad = false;
  bool _isAttachINSLoad = false;
  Object? _expandedCourseId;
  int _expandedIndex = 0;
  Map<String, dynamic>? _selectedCourse;
  String _selectedPreviewSectionId = '';
  String _selectedPreviewChapterId = '';
  String _selectedPreviewContentId = '';

  // `v-model` on store / data() objects (`currentCurriculum.name`,
  // `selectedSectionDetails.name`, `selectedChapterDetails.name`).
  final _curriculumName = TextEditingController();
  final _sectionName = TextEditingController();
  final _chapterName = TextEditingController();
  // `contentForm.name/url` and `selectedContentDetails.name/url`.
  final _contentName = TextEditingController();
  final _contentUrl = TextEditingController();
  final _editContentName = TextEditingController();
  final _editContentUrl = TextEditingController();

  // ── Flutter plumbing ──────────────────────────────────────────────────
  /// Bumped on every [_set] so open dialogs (separate routes) rebuild with
  /// the component state, like Vue re-rendering the dialog in place.
  final _refresh = ValueNotifier<int>(0);
  OverlayEntry? _loaderEntry;
  bool _courseDeleteShowing = false;
  String _lastCurriculumQuery = '';
  String _lastCourseQuery = '';

  CoursesController get _ctrl => ref.read(coursesControllerProvider.notifier);
  CoursesState get _cs => ref.read(coursesControllerProvider);
  String get _role => ref.read(sessionProvider).userInfo?.role ?? '';

  @override
  void initState() {
    super.initState();
    _activeTab = widget.externalActiveTab.isNotEmpty ? widget.externalActiveTab : 'curriculum';
    // created()
    if (_role == Role.student) _activeTab = 'course';
    _searchQueryCurriculum.addListener(_onCurriculumQueryChanged);
    _searchQueryCourse.addListener(_onCourseQueryChanged);
    Future.microtask(_mounted);
  }

  /// `watch: externalActiveTab(newVal) { if (newVal) this.activeTab = newVal }`
  @override
  void didUpdateWidget(covariant CourseListView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.externalActiveTab != oldWidget.externalActiveTab && widget.externalActiveTab.isNotEmpty) {
      _activeTab = widget.externalActiveTab;
    }
  }

  @override
  void dispose() {
    _loaderEntry?.remove();
    _loaderEntry = null;
    for (final c in [
      _newCurriculum,
      _newSection,
      _sectionOrder,
      _updateSectionOrder,
      _newChapter,
      _chapterOrder,
      _updatechapterOrder,
      _contentOrder,
      _updatecontentOrder,
      _searchQueryCurriculum,
      _searchQueryCourse,
      _curriculumName,
      _sectionName,
      _chapterName,
      _contentName,
      _contentUrl,
      _editContentName,
      _editContentUrl,
    ]) {
      c.dispose();
    }
    _form.dispose();
    _refresh.dispose();
    super.dispose();
  }

  /// setState + refresh the open dialogs + show/hide the `<Loader>`.
  void _set(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
    _refresh.value++;
    _syncLoader();
  }

  /// `<Loader :loading="isLoading" />` is `position: fixed; inset: 0` on the
  /// web, so it covers the whole window (and open dialogs), not just this
  /// embedded widget.
  void _syncLoader() {
    if (_isLoading && _loaderEntry == null) {
      final entry = OverlayEntry(
        builder: (_) => const Positioned.fill(child: LoadingOverlay(loading: true, child: SizedBox.expand())),
      );
      Overlay.of(context, rootOverlay: true).insert(entry);
      _loaderEntry = entry;
    } else if (!_isLoading && _loaderEntry != null) {
      _loaderEntry!.remove();
      _loaderEntry = null;
    }
  }

  /// Runs [fn] and swallows its error (the API client already toasted it;
  /// the web only logged or left it unhandled).
  void _fire(Future<void> Function() fn) {
    fn().catchError((Object _) {});
  }

  /// `watch: expandedCourse(newVal) { this.$emit('course-expanded', !!newVal) }`
  void _setExpandedCourse(String? value) {
    final was = _expandedCourse;
    _expandedCourse = value;
    if (was == value) return;
    final cb = widget.onCourseExpanded;
    if (cb == null) return;
    scheduleMicrotask(() {
      if (mounted) cb(value != null && value.isNotEmpty);
    });
  }

  /// `selectedCourseDetails = x` + its watcher, which runs after the
  /// current synchronous code (Vue's pre-flush) and resets the preview to
  /// the course.
  void _assignSelectedCourseDetails(Map<String, dynamic>? value) {
    final changed = !identical(value, _selectedCourseDetails);
    _selectedCourseDetails = value;
    if (!changed) return;
    scheduleMicrotask(() {
      if (!mounted) return;
      _set(() => _previewItem = (type: 'course', data: _selectedCourseDetails));
    });
  }

  /// Opens one of the component's dialogs. [guard] = the web's
  /// `@pointer-down-outside / @escape-key-down` prevention while
  /// `isCreateBtnLoading`.
  Future<void> _showDialog(Widget Function(BuildContext ctx) builder, {bool guard = false}) {
    return showAppDialog<void>(
      context,
      builder: (_) => ListenableBuilder(
        listenable: _refresh,
        builder: (ctx, _) => Consumer(
          builder: (ctx, ref, _) {
            ref.watch(coursesControllerProvider);
            return PopScope(canPop: !(guard && _isCreateBtnLoading), child: builder(ctx));
          },
        ),
      ),
    );
  }

  /// `this.isXOpen = false` for the dialog that [ctx] belongs to (no-op when
  /// the user already closed it).
  VoidCallback _closer(BuildContext ctx) => () {
    if (!ctx.mounted) return;
    final route = ModalRoute.of(ctx);
    if (route == null || !route.isActive) return;
    if (route.isCurrent) {
      Navigator.of(ctx).pop();
    } else {
      Navigator.of(ctx).removeRoute(route);
    }
  };

  // ── mounted() ─────────────────────────────────────────────────────────

  Future<void> _mounted() async {
    _set(() => _isListLoading = true);
    try {
      final role = _role;
      if (role == Role.institute || role == Role.instructor) {
        await _ctrl.fetchCurriculums();
        await _ctrl.getAllInstructors();
      }
      if (_selectedCurriculum.isEmpty) {
        await _ctrl.fetchCourse();
      } else {
        await _ctrl.fetchClassCourse();
      }
      _set(() {
        _coursess = List.of(_cs.courses);
        for (var i = 0; i < _coursess.length; i++) {
          if (role == Role.student) {
            _activeTabs[i] = 'preview';
          } else {
            _activeTabs.putIfAbsent(i, () => 'overview');
          }
        }
      });
    } catch (_) {
    } finally {
      _set(() => _isListLoading = false);
    }
  }

  // ── watchers on the search boxes ──────────────────────────────────────

  /// `watch: searchQueryCurriculum(v) { if (!v.trim()) fetchCurriculums() }`
  void _onCurriculumQueryChanged() {
    final v = _searchQueryCurriculum.text;
    if (v == _lastCurriculumQuery) return;
    _lastCurriculumQuery = v;
    if (v.trim().isEmpty) scheduleMicrotask(() => _fire(_ctrl.fetchCurriculums));
  }

  /// `watch: searchQueryCourse(v) { if (!v.trim()) resetCourse() }`
  void _onCourseQueryChanged() {
    final v = _searchQueryCourse.text;
    if (v == _lastCourseQuery) return;
    _lastCourseQuery = v;
    if (v.trim().isEmpty) scheduleMicrotask(() => _fire(_resetCourse));
  }

  List<Map<String, dynamic>> get _filteredCourses => filterCoursesByStatus(_coursess, _statuscourse);

  List<Map<String, dynamic>> get _previewChapters =>
      previewChaptersOf(_selectedCourseDetails, _selectedPreviewSectionId);

  List<Map<String, dynamic>> get _previewContents => previewContentsOf(_previewChapters, _selectedPreviewChapterId);

  // ── Update course dialog ──────────────────────────────────────────────

  /// `openUpdateCourseDialog(courseId)`
  Future<void> _openUpdateCourseDialog(Object? courseId) async {
    _set(() {
      _selectedCourseId = courseId;
      _imagePreview = '';
      _imagePreviewFile = null;
    });
    unawaited(_showDialog(_buildCourseUpdateDialog, guard: true));
    try {
      await _ctrl.fetchCurriculums();
      await _ctrl.getAllInstructors();
      await _ctrl.loadAllClasses();
      _set(() => _editAllClassesData = _cs.allClasses);
      final details = await _ctrl.fetchCourseDetails(courseId ?? '');
      if (details == null) return;
      final form = _form;
      _set(() {
        form.title.text = orBlank(details['title']);
        form.shortName.text = orBlank(details['short_name']);
        form.courseCode.text = orBlank(details['course_code']);
        form.description.text = orBlank(details['description']);
        form.zone = orBlank(details['zone']);
        final status = details['status'];
        form.status = const ['published', 'draft', 'archived'].contains(status) ? status as String : 'draft';
        form.instructorId = orBlank(details['instructor_id']);
        form.curriculumId = orBlank(dig(details, ['curriculums', 0, 'id']));
        form.isMathPlay = details['is_math_zoro'] == true;
        form.attach = null;
        _imagePreviewFile = null;
        _imagePreview = jsTruthy(details['image'])
            ? '${details['image']}'
            : jsTruthy(details['attach'])
            ? '${details['attach']}'
            : '';
        form.classId = details['zsl_class_id'];
      });
      if (jsTruthy(form.classId)) {
        await _loadEditSubjects(form.classId!);
        _set(() => form.subjectId = orBlank(details['zsl_subject_id']));
      } else {
        _set(() => form.subjectId = '');
      }
      _set(() => _assignSelectedCourseDetails(details));
    } catch (_) {}
  }

  /// `loadEditSubjects(classId)`
  Future<void> _loadEditSubjects(Object classId) async {
    try {
      final instituteId = ref.read(sessionProvider).userInfo?.instituteId;
      if (instituteId == null || !jsTruthy(classId)) return;
      final subjects = await _ctrl.getAllSubjects(instituteId, classId);
      _set(() => _editSubjectsList = subjects);
    } catch (_) {
      _set(() => _editSubjectsList = []);
    }
  }

  /// `onEditClassChange(classId)`
  Future<void> _onEditClassChange(Object? classId) async {
    _set(() {
      _form.classId = classId;
      _form.subjectId = '';
      _editSubjectsList = [];
    });
    if (jsTruthy(classId)) await _loadEditSubjects(classId!);
  }

  /// `CourseUpdate()`
  Future<void> _courseUpdate(VoidCallback close) async {
    if (!jsTruthy(_selectedCourseId)) return;
    _set(() => _isCreateBtnLoading = true);
    try {
      await _ctrl.updateCourse('$_selectedCourseId', _form.toMap());
      await _ctrl.fetchCourse();
      _set(() {
        _coursess = List.of(_cs.courses);
        _imagePreview = '';
        _imagePreviewFile = null;
      });
      close();
    } catch (_) {
    } finally {
      _set(() => _isCreateBtnLoading = false);
    }
  }

  /// `handleImageChange(event)`
  Future<void> _handleImageChange() async {
    final file = await pickImageFile();
    if (file == null) return;
    _set(() {
      _form.attach = file;
      _imagePreviewFile = file;
      _imagePreview = file.name;
    });
  }

  // ── Curriculum CRUD ───────────────────────────────────────────────────

  /// `createCurriculum()`
  Future<void> _createCurriculum(VoidCallback close) async {
    _set(() => _isCreateBtnLoading = true);
    try {
      await ref.read(classServiceProvider).createCurriculum({
        // `Number(userStore.instituteId)` (the getter yields null → 0).
        'institute_id': ref.read(sessionProvider).userInfo?.instituteId ?? 0,
        'name': _newCurriculum.text,
      });
      _newCurriculum.clear();
      await _ctrl.fetchCurriculums();
      close();
    } catch (_) {
    } finally {
      _set(() => _isCreateBtnLoading = false);
    }
  }

  /// `openUpdateCurriculum(curriculumId)`
  Future<void> _openUpdateCurriculum(Object? curriculumId) async {
    _curriculumName.text = vText(_cs.currentCurriculum['name']);
    unawaited(_showDialog(_buildCurriculumUpdateDialog));
    _set(() => _isLoading = true);
    try {
      await _ctrl.fetchCurriculumById(curriculumId);
      _curriculumName.text = vText(_cs.currentCurriculum['name']);
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  /// `curriculumUpdate()`
  Future<void> _curriculumUpdate(VoidCallback close) async {
    _set(() => _isCreateBtnLoading = true);
    try {
      final c = _cs.currentCurriculum;
      await _ctrl.updateCurriculum({
        'id': c['id'],
        'institute_id': c['institute_id'],
        'name': c['name'],
        'status': c['status'],
      });
      await _ctrl.fetchCurriculums();
      close();
    } catch (_) {
    } finally {
      _set(() => _isCreateBtnLoading = false);
    }
  }

  /// `handleCurriculumStatusChange(curriculum)` — flips locally first, no
  /// revert on failure (like the web).
  Future<void> _handleCurriculumStatusChange(Map<String, dynamic> curriculum) async {
    try {
      final newStatus = nextCurriculumStatus(curriculum['status']);
      _ctrl.setCurriculumStatusLocally(curriculum['id'], newStatus);
      await _ctrl.updateCurriculumStatus({
        'id': curriculum['id'],
        'institute_id': curriculum['institute_id'],
        'value': newStatus,
      });
    } catch (_) {}
  }

  /// `openDeleteDialog(curriculum)`
  void _openDeleteDialog(Map<String, dynamic> curriculum) {
    _set(() => _curriculumToDelete = curriculum);
    unawaited(_showDialog(_buildCurriculumDeleteDialog));
  }

  /// `confirmDeleteCurriculum()` — the dialog stays open when it fails.
  Future<void> _confirmDeleteCurriculum(VoidCallback close) async {
    try {
      await _ctrl.deleteCurriculum(_curriculumToDelete!['id'] as Object);
      close();
      _set(() => _curriculumToDelete = null);
    } catch (_) {}
  }

  // ── Course selection / expand ─────────────────────────────────────────

  /// `createCourse()`
  void _createCourse() => context.go('/coursecreate');

  /// `openCourse(course, idx)` (`handleCardClick`).
  void _openCourse(Map<String, dynamic> course, int idx) {
    _set(() {
      _selectedCourse = course;
      _expandedIndex = idx;
      _setExpandedCourse('course-$idx');
      _expandedCourseId = course['id'];
    });
    _syncCourseDeleteDialog();
    if (_role == Role.student) {
      _fire(() => _onPreviewTabClick(course['id'], idx));
    } else {
      _fire(() => _onCourseSelect(course));
    }
  }

  /// `onCurriculumSelect(curriculum)` — also writes `classDetails`
  /// (session) with the curriculum, like the web.
  Future<void> _onCurriculumSelect(Map<String, dynamic>? curriculum) async {
    final id = curriculum?['id'];
    _set(() => _selectedCurriculum = orBlank(curriculum?['name']));
    ref
        .read(sessionProvider.notifier)
        .setClassDetails(
          IdName(
            asInt(jsTruthy(id) ? id : null),
            orBlank(curriculum?['name']),
            extra: {'c_id': jsTruthy(id) ? id : null},
          ),
        );
    _set(() => _isLoading = true);
    try {
      if (curriculum != null && jsTruthy(id)) {
        await _ctrl.fetchClassCourse();
      } else {
        await _ctrl.fetchCourse();
      }
      _set(() => _coursess = List.of(_cs.courses));
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  /// Lower-cases `status` and normalises `instructors` on a course-details
  /// response (mutated in place, like the web).
  static void _normalizeDetails(Map<String, dynamic> r) {
    r['status'] = '${r['status'] ?? 'draft'}'.toLowerCase();
    r['instructors'] = r['instructors'] is List ? r['instructors'] : <dynamic>[];
  }

  /// `onCourseSelect(course)`
  Future<void> _onCourseSelect(Map<String, dynamic> course) async {
    _ctrl.setCourseId(course['id']);
    _set(() {
      _selectedCourseId = course['id'];
      _expandedSectionRow = '';
      _expandedChapterRow = '';
      _isLoading = true;
    });
    try {
      final response = await _ctrl.fetchCourseDetails(course['id'] ?? '');
      final r = response!;
      _set(() {
        _assignSelectedCourseDetails(r);
        _normalizeDetails(r);
        final user = asMap(asMap(r['instructor'])?['user']);
        r['createdInstructorName'] = user != null ? '${user['first_name']} ${user['last_name']}' : 'N/A';
      });
      await _ctrl.fetchSections(course['id'] ?? '');
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  /// `onPreviewTabClick(courseId, idx)` — picks the first section / chapter /
  /// concept. (The `selectedCourseDetails` watcher then resets the preview
  /// item to the course, as on the web.)
  Future<void> _onPreviewTabClick(Object? courseId, int idx) async {
    _set(() {
      _activeTabs[idx] = 'preview';
      _isLoading = true;
    });
    try {
      final response = (await _ctrl.fetchCourseDetails(courseId ?? ''))!;
      _set(() {
        _assignSelectedCourseDetails(response);
        _normalizeDetails(response);
        final sel = firstPreviewSelection(response);
        _selectedPreviewSectionId = sel.sectionId;
        _selectedPreviewChapterId = sel.chapterId;
        _selectedPreviewContentId = sel.contentId;
        _previewItem = sel.content != null
            ? (type: 'content', data: sel.content)
            : (type: 'course', data: _selectedCourseDetails);
      });
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  /// `onPreviewSectionChange(val)`
  void _onPreviewSectionChange(String? val) {
    if (val == null) return;
    _set(() {
      _selectedPreviewSectionId = val;
      _selectedPreviewChapterId = '';
      _selectedPreviewContentId = '';
    });
    final chapters = _previewChapters;
    if (chapters.isNotEmpty) {
      _onPreviewChapterChange('${chapters.first['id']}');
    } else {
      _set(() => _previewItem = (type: 'course', data: _selectedCourseDetails));
    }
  }

  /// `onPreviewChapterChange(val)`
  void _onPreviewChapterChange(String? val) {
    if (val == null) return;
    _set(() {
      _selectedPreviewChapterId = val;
      _selectedPreviewContentId = '';
    });
    final contents = _previewContents;
    if (contents.isNotEmpty) {
      _onPreviewContentChange('${contents.first['id']}');
    } else {
      _set(() => _previewItem = (type: 'course', data: _selectedCourseDetails));
    }
  }

  /// `onPreviewContentChange(val)`
  void _onPreviewContentChange(String? val) {
    if (val == null) return;
    _set(() {
      _selectedPreviewContentId = val;
      for (final c in _previewContents) {
        if ('${c['id']}' == val) {
          _previewItem = (type: 'content', data: c);
          break;
        }
      }
    });
  }

  // ── Delete confirmations ──────────────────────────────────────────────

  /// `confirmDeleteCourse()`
  Future<void> _confirmDeleteCourse(VoidCallback close) async {
    final del = _courseToDelete;
    if (del == null || !jsTruthy(del['id'])) return;
    _set(() => _isLoading = true);
    try {
      await _ctrl.deleteCourse(del['id'] as Object);
      _set(() {
        _coursess = [
          for (final c in _coursess)
            if ('${c['id']}' != '${del['id']}') c,
        ];
        if (_expandedCourseId == del['id']) {
          _setExpandedCourse(null);
          _expandedCourseId = null;
          _selectedCourse = null;
          _assignSelectedCourseDetails(null);
        }
      });
    } catch (_) {
    } finally {
      _set(() {
        _isLoading = false;
        _isCourseDeleteOpen = false;
        _courseToDelete = null;
      });
      close();
    }
  }

  /// `confirmDeleteSection()`
  Future<void> _confirmDeleteSection(VoidCallback close) async {
    final del = _sectionToDelete;
    if (del == null || !jsTruthy(del['id'])) return;
    _set(() => _isLoading = true);
    try {
      await _ctrl.deleteSection(del['id'] as Object);
      if (_expandedSectionRow.isNotEmpty) _set(() => _expandedSectionRow = '');
      if (_selectedCourseId != null) await _ctrl.fetchSections(_selectedCourseId!);
    } catch (_) {
    } finally {
      _set(() {
        _isLoading = false;
        _sectionToDelete = null;
      });
      close();
    }
  }

  /// `confirmDeleteChapter()` — refetches the chapters of `section_id`.
  Future<void> _confirmDeleteChapter(VoidCallback close) async {
    final del = _chapterToDelete;
    if (del == null || !jsTruthy(del['id'])) return;
    _set(() => _isLoading = true);
    try {
      await _ctrl.deleteChapter(del['id'] as Object);
      if (_expandedChapterRow.isNotEmpty) _set(() => _expandedChapterRow = '');
      final sectionId = _ctrl.sectionId;
      if (sectionId != null) await _ctrl.fetchChapters(sectionId);
    } catch (_) {
    } finally {
      _set(() {
        _isLoading = false;
        _chapterToDelete = null;
      });
      close();
    }
  }

  /// `confirmDeleteContent()`
  Future<void> _confirmDeleteContent(VoidCallback close) async {
    final del = _contentToDelete;
    if (del == null || !jsTruthy(del['id'])) return;
    _set(() => _isLoading = true);
    try {
      await _ctrl.deleteContent(del['id'] as Object);
      if (_selectedChapterId != null) await _ctrl.fetchContents(_selectedChapterId!);
    } catch (_) {
    } finally {
      _set(() {
        _isLoading = false;
        _contentToDelete = null;
      });
      close();
    }
  }

  /// `openDeleteCourseDialog(course)`. On the web the "Delete Course?"
  /// dialog lives inside the expanded-course panel, so from the card grid
  /// it only opens once a course is expanded — kept as is.
  void _openDeleteCourseDialog(Map<String, dynamic> course) {
    _set(() {
      _courseToDelete = course;
      _isCourseDeleteOpen = true;
    });
    _syncCourseDeleteDialog();
  }

  /// Shows the course delete dialog when `isCourseDeleteOpen` and the panel
  /// that holds it (`v-if="expandedCourse"`) are both there.
  void _syncCourseDeleteDialog() {
    if (!_isCourseDeleteOpen || _expandedCourse == null || _courseDeleteShowing) return;
    _courseDeleteShowing = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      await _showDialog(_buildCourseDeleteDialog);
      _courseDeleteShowing = false;
      _set(() => _isCourseDeleteOpen = false);
    });
  }

  void _openDeleteSectionDialog(Map<String, dynamic> section) {
    _set(() => _sectionToDelete = section);
    unawaited(_showDialog(_buildSectionDeleteDialog));
  }

  void _openDeleteChapterDialog(Map<String, dynamic> chapter) {
    _set(() => _chapterToDelete = chapter);
    unawaited(_showDialog(_buildChapterDeleteDialog));
  }

  void _openDeleteContentDialog(Map<String, dynamic> content) {
    _set(() => _contentToDelete = content);
    unawaited(_showDialog(_buildContentDeleteDialog));
  }

  // ── Curriculum attach / detach ────────────────────────────────────────

  /// `curriculumSelected(curriculum)` — stored on the course object.
  void _curriculumSelected(Map<String, dynamic> curriculum) => _set(() {
    final c = _selectedCourse;
    if (c == null) return;
    c['selectedCourseCurriculumId'] = curriculum['id'];
    c['selectedCourseCurriculumName'] = curriculum['name'];
  });

  /// `attachCurriculum(course)`
  Future<void> _attachCurriculum(Map<String, dynamic> course) async {
    final curriculumId = course['selectedCourseCurriculumId'];
    final courseId = jsTruthy(_selectedCourseId) ? '$_selectedCourseId' : orBlank(course['id']);
    _set(() => _isAttachCurriculLoad = true);
    try {
      await _ctrl.attachCurriculumToCourse(curriculumId, courseId);
      final details = await _ctrl.fetchCourseDetails(jsNumber(courseId));
      _set(() {
        _assignSelectedCourseDetails(details);
        course['selectedCourseCurriculumId'] = null;
        course['selectedCourseCurriculumName'] = '';
      });
    } catch (_) {
    } finally {
      _set(() => _isAttachCurriculLoad = false);
    }
  }

  /// `openDeleteCurriculumDialog(course, curriculum)`
  void _openDeleteCurriculumDialog(Map<String, dynamic>? course, Map<String, dynamic> curriculum) {
    _set(() {
      _courseForDelete = course;
      _curriculumToDelete = curriculum;
    });
    unawaited(_showDialog(_buildDetachCurriculumDialog));
  }

  /// `DetachCurriculum()`
  Future<void> _detachCurriculum(VoidCallback close) async {
    final course = _courseForDelete;
    final cur = _curriculumToDelete;
    if (course == null || !jsTruthy(course['id']) || cur == null || !jsTruthy(cur['id'])) return;
    _set(() => _isLoading = true);
    try {
      await _ctrl.removeCurriculumFromCourse('${cur['id']}', '${course['id']}');
      _set(() {
        final details = _selectedCourseDetails;
        if (details != null && details['curriculums'] != null) {
          details['curriculums'] = [
            for (final c in asList(details['curriculums']))
              if (asMap(c)?['id'] != cur['id']) c,
          ];
        }
        _curriculumToDelete = null;
        _courseForDelete = null;
      });
      close();
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  // ── Instructor attach / detach ────────────────────────────────────────

  /// `selectInstructorForCourse(course, instructor)`
  void _selectInstructorForCourse(Map<String, dynamic>? course, Map<String, dynamic> instructor) => _set(() {
    if (course == null) return;
    course['selectedInstructorId'] = instructor['id'];
    course['selectedInstructorName'] = instructorDisplayName(instructor);
  });

  /// `attachInstructor(course)`
  Future<void> _attachInstructor(Map<String, dynamic> course) async {
    final instructorId = course['selectedInstructorId']?.toString();
    final courseId = jsTruthy(_selectedCourseId) ? '$_selectedCourseId' : course['id']?.toString();
    _set(() => _isAttachINSLoad = true);
    try {
      await _ctrl.attachInstructorToCourse(courseId, instructorId);
      _set(() {
        course['selectedInstructorId'] = null;
        course['selectedInstructorName'] = '';
      });
      final details = await _ctrl.fetchCourseDetails(jsNumber(courseId));
      _set(() => _assignSelectedCourseDetails(details));
    } catch (_) {
    } finally {
      _set(() => _isAttachINSLoad = false);
    }
  }

  /// `openDeleteInstructorDialog(instructor)`
  void _openDeleteInstructorDialog(Map<String, dynamic> instructor) {
    _set(() => _instructorToDelete = instructor);
    unawaited(_showDialog(_buildDetachInstructorDialog));
  }

  /// `DetachInstructor()` — refreshes the store's `courses` (not the
  /// visible list), like the web.
  Future<void> _detachInstructor(VoidCallback close) async {
    final inst = _instructorToDelete;
    if (inst == null || !jsTruthy(_selectedCourseId)) return;
    _set(() => _isLoading = true);
    try {
      await _ctrl.removeInstructorFromCourse('${inst['id']}', '$_selectedCourseId');
      _set(() {
        final details = _selectedCourseDetails;
        if (details != null && details['instructors'] != null) {
          details['instructors'] = [
            for (final i in asList(details['instructors']))
              if (asMap(i)?['id'] != inst['id']) i,
          ];
        }
      });
      await _ctrl.fetchCourse();
      close();
      _set(() => _instructorToDelete = null);
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  // ── Section CRUD ──────────────────────────────────────────────────────

  /// `openCreateSectionDialog()`
  void _openCreateSectionDialog() {
    _newSection.clear();
    _sectionOrder.clear();
    unawaited(_showDialog(_buildSectionCreateDialog, guard: true));
  }

  /// `createSection()`
  Future<void> _createSection(VoidCallback close) async {
    _set(() => _isCreateBtnLoading = true);
    try {
      await _ctrl.createSection(_newSection.text, jsNumber(_sectionOrder.text));
      _newSection.clear();
      _sectionOrder.clear();
      if (_selectedCourseId != null) await _ctrl.fetchSections(_selectedCourseId!);
      close();
    } catch (_) {
    } finally {
      _set(() => _isCreateBtnLoading = false);
    }
  }

  /// `openSectionUpdateDialog(courseId, sectionId)`
  Future<void> _openSectionUpdateDialog(Object? courseId, Object? sectionId) async {
    if (!jsTruthy(courseId) || !jsTruthy(sectionId)) return;
    unawaited(_showDialog(_buildSectionUpdateDialog, guard: true));
    _set(() => _isLoading = true);
    try {
      final details = await _ctrl.fetchCourseDetails(courseId!);
      Map<String, dynamic>? section;
      for (final s in asList(details!['sections'])) {
        if (asMap(s)?['id'] == sectionId) {
          section = asMap(s);
          break;
        }
      }
      if (section == null) {
        _set(() => _selectedSectionDetails = null);
        return;
      }
      final found = section;
      _set(() {
        _selectedSectionDetails = found;
        _sectionName.text = vText(found['name']);
        _updateSectionOrder.text = vText(found['order']);
      });
    } catch (_) {
      _set(() => _selectedSectionDetails = null);
    } finally {
      _set(() => _isLoading = false);
    }
  }

  /// `sectionUpdate()`
  Future<void> _sectionUpdate(VoidCallback close) async {
    final section = _selectedSectionDetails;
    if (section == null || !jsTruthy(section['id'])) return;
    _set(() => _isCreateBtnLoading = true);
    try {
      await _ctrl.updateSection(section['id'] as Object, vText(section['name']), jsNumber(_updateSectionOrder.text));
      close();
      if (_selectedCourseId != null) await _ctrl.fetchSections(_selectedCourseId!);
    } catch (_) {
    } finally {
      _set(() => _isCreateBtnLoading = false);
    }
  }

  /// `onSectionSelect(section)` (accordion trigger click).
  Future<void> _onSectionSelect(Map<String, dynamic> section) async {
    _ctrl.setSectionId(section['id']);
    _set(() => _isLoading = true);
    try {
      await _ctrl.fetchChapters(section['id'] ?? '');
    } finally {
      _set(() => _isLoading = false);
    }
  }

  // ── Chapter CRUD ──────────────────────────────────────────────────────

  /// `openCreateChapterDialog()` — the chapter goes to `section_id` (the
  /// last section opened), not necessarily the row clicked, like the web.
  void _openCreateChapterDialog() {
    _newChapter.clear();
    _chapterOrder.clear();
    unawaited(_showDialog(_buildChapterCreateDialog, guard: true));
  }

  /// `createChapter()`
  Future<void> _createChapter(VoidCallback close) async {
    _set(() => _isCreateBtnLoading = true);
    try {
      await _ctrl.createChapter(_newChapter.text, jsNumber(_chapterOrder.text));
      _newChapter.clear();
      _chapterOrder.clear();
      close();
    } catch (_) {
    } finally {
      _set(() => _isCreateBtnLoading = false);
    }
  }

  /// `openChapterUpdateDialog(courseId, sectionId, chapterId)`
  Future<void> _openChapterUpdateDialog(Object? courseId, Object? sectionId, Object? chapterId) async {
    if (!jsTruthy(courseId) || !jsTruthy(sectionId) || !jsTruthy(chapterId)) return;
    unawaited(_showDialog(_buildChapterUpdateDialog, guard: true));
    try {
      final details = await _ctrl.fetchCourseDetails(courseId!);
      final section = _findById(details!['sections'], sectionId);
      if (section == null) return;
      final chapter = _findById(section['chapters'], chapterId);
      if (chapter == null) return;
      _set(() {
        _selectedChapterDetails = chapter;
        _chapterName.text = vText(chapter['name']);
        _updatechapterOrder.text = vText(chapter['order']);
      });
    } catch (_) {}
  }

  /// `list.find((x) => x.id === id)`
  static Map<String, dynamic>? _findById(dynamic list, Object? id) {
    for (final e in asList(list)) {
      final m = asMap(e);
      if (m != null && m['id'] == id) return m;
    }
    return null;
  }

  /// `chapterUpdate()` — refetches the chapters of `selectedSectionDetails`
  /// (the section last opened in "Edit Section"), like the web.
  Future<void> _chapterUpdate(VoidCallback close) async {
    final chapter = _selectedChapterDetails;
    if (chapter == null || !jsTruthy(chapter['id'])) return;
    _set(() => _isCreateBtnLoading = true);
    try {
      await _ctrl.updateChapter(chapter['id'] as Object, vText(chapter['name']), jsNumber(_updatechapterOrder.text));
      final sectionId = _selectedSectionDetails?['id'];
      if (jsTruthy(sectionId)) await _ctrl.fetchChapters(sectionId as Object);
      close();
    } catch (_) {
    } finally {
      _set(() => _isCreateBtnLoading = false);
    }
  }

  /// `onChapterSelect(chapter)` (accordion trigger click).
  Future<void> _onChapterSelect(Map<String, dynamic> chapter) async {
    _ctrl.setChapterId(chapter['id']);
    _set(() {
      _selectedChapterId = chapter['id'];
      _isLoading = true;
    });
    try {
      await _ctrl.fetchContents(chapter['id'] ?? '');
    } finally {
      _set(() => _isLoading = false);
    }
  }

  // ── Content / concept CRUD ────────────────────────────────────────────

  /// `openConceptDialog(chapter)`
  void _openConceptDialog(Map<String, dynamic> chapter) {
    _ctrl
      ..setChapterId(chapter['id'])
      ..setContentForm({
        'name': '',
        'type': 'html',
        'url': '',
        'zslactvity': '',
        'file': null,
        'html_content': '',
        'order': '',
      });
    _contentName.clear();
    _contentUrl.clear();
    _set(() {
      _selectedChapterId = chapter['id'];
      _contentOrder.clear();
    });
    unawaited(_showDialog(_buildContentCreateDialog, guard: true));
  }

  /// `onContentFileChange(e)` — shared by the create and edit dialogs.
  Future<void> _onContentFileChange() async {
    final file = await pickUploadFile();
    if (file == null) return;
    final url = file.path != null ? Uri.file(file.path!).toString() : '';
    _editContentUrl.text = url;
    _ctrl
      ..patchContentForm({'file': file})
      ..patchSelectedContentDetails({
        'file': file,
        // `URL.createObjectURL(file)` → a local file URL when there is one.
        'url': url,
      });
  }

  /// `createContent()`
  Future<void> _createContent(VoidCallback close) async {
    _set(() => _isCreateBtnLoading = true);
    try {
      _ctrl.patchContentForm({'order': _contentOrder.text});
      await _ctrl.createContent(_ctrl.sectionId, _selectedChapterId);
      close();
    } catch (_) {
    } finally {
      _set(() => _isCreateBtnLoading = false);
    }
  }

  /// `openContentUpdateDialog(courseId, sectionId, chapterId, contentId)`.
  /// The web dialog is `v-if="selectedContentDetails.id"`: it only appears
  /// once a concept has been loaded.
  Future<void> _openContentUpdateDialog(
    Object? courseId,
    Object? sectionId,
    Object? chapterId,
    Object? contentId,
  ) async {
    if (!jsTruthy(courseId) || !jsTruthy(sectionId) || !jsTruthy(chapterId) || !jsTruthy(contentId)) return;
    final hadId = _cs.selectedContentDetails['id'] != null;
    if (hadId) unawaited(_showDialog(_buildContentUpdateDialog, guard: true));
    try {
      final details = await _ctrl.fetchCourseDetails(courseId!);
      final section = _findById(details!['sections'], sectionId);
      if (section == null) return;
      final chapter = _findById(section['chapters'], chapterId);
      if (chapter == null) return;
      final content = _findById(chapter['contents'], contentId);
      if (content == null) return;
      _updatecontentOrder.text = vText(content['order']);
      _editContentName.text = orBlank(content['name']);
      _editContentUrl.text = orBlank(content['url']);
      _ctrl.setSelectedContentDetails({
        'id': content['id'],
        'name': orBlank(content['name']),
        'type': orBlank(content['type']),
        'url': orBlank(content['url']),
        'html_content': orBlank(content['content']),
        'order': '',
        'file': null,
      });
      _set(() {});
      if (!hadId && mounted) unawaited(_showDialog(_buildContentUpdateDialog, guard: true));
    } catch (_) {}
  }

  /// `contentUpdate(contentId)`
  Future<void> _contentUpdate(Object? contentId, VoidCallback close) async {
    _set(() => _isCreateBtnLoading = true);
    try {
      _ctrl.patchSelectedContentDetails({'order': jsNumber(_updatecontentOrder.text)});
      await _ctrl.updateContent(contentId ?? '');
      close();
      if (_selectedChapterId != null) await _ctrl.fetchContents(_selectedChapterId!);
    } catch (_) {
    } finally {
      _set(() => _isCreateBtnLoading = false);
    }
  }

  /// `handleContentClick(content)`
  void _handleContentClick(Map<String, dynamic> content) {
    _set(() => _selectedContent = content);
    unawaited(_showDialog(_buildContentPreviewDialog));
  }

  /// `closeContentDialog()`
  void _closeContentDialog(VoidCallback close) {
    close();
    _set(() => _selectedContent = null);
  }

  // ── Search ────────────────────────────────────────────────────────────

  /// `searchCurriculumByName()`
  void _searchCurriculumByName() {
    if (_searchQueryCurriculum.text.trim().isEmpty) return;
    _fire(() => _ctrl.searchCurriculum(_searchQueryCurriculum.text));
  }

  /// `searchCourseByName()`
  Future<void> _searchCourseByName() async {
    if (_searchQueryCourse.text.trim().isEmpty) return;
    try {
      await _ctrl.searchCourse(_searchQueryCourse.text);
      _set(() => _coursess = List.of(_cs.courses));
    } catch (_) {}
  }

  /// `resetCourse()`
  Future<void> _resetCourse() async {
    _searchQueryCourse.text = '';
    await _ctrl.fetchCourse();
    _set(() => _coursess = List.of(_cs.courses));
  }

  // ── build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(sessionProvider.select((s) => s.userInfo?.role)) ?? '';
    final cs = ref.watch(coursesControllerProvider);
    final dark = context.isDark;
    final plain = widget.hideTriggers || _expandedCourse != null;
    final showBanner = widget.hideTriggers && _expandedCourse == null;

    final content = Padding(
      padding: _expandedCourse != null ? EdgeInsets.zero : EdgeInsets.all(context.isSm ? 24 : 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (role != Role.student && !widget.hideTriggers && _expandedCourse == null)
            context.isLg ? _buildDesktopTabs(cs) : _buildMobileTabSelect(cs),
          if (_activeTab == 'curriculum') _buildCurriculumTab(cs),
          if (_activeTab == 'course') _buildCourseTab(cs, role),
        ],
      ),
    );

    final card = Container(
      margin: plain ? EdgeInsets.zero : EdgeInsets.all(context.isSm ? 8 : 4),
      clipBehavior: plain ? Clip.none : Clip.antiAlias,
      decoration: plain
          ? null
          : BoxDecoration(
              color: dark ? AppColors.darkCard : AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: dark ? Tw.slate800 : Tw.slate200),
              boxShadow: _CC.shadowSm,
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showBanner) ...[_buildBanner(), const SizedBox(height: 24)],
          content,
        ],
      ),
    );

    return LayoutBuilder(builder: (context, c) => c.maxHeight.isFinite ? SingleChildScrollView(child: card) : card);
  }
}
