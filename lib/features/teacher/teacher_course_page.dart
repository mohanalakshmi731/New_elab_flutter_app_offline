import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/skeleton.dart';
import '../../widgets/web_content_view.dart';
import '../institutes/institute_widgets.dart' show SpinIcon;
import '../users/users_widgets.dart' show FormGrid;
import 'teacher_course_controller.dart';
import 'teacher_course_dialogs.dart';
import 'teacher_course_logic.dart';
import 'teacher_course_widgets.dart';

part 'teacher_course_list_view.dart';
part 'teacher_course_detail_view.dart';
part 'teacher_course_preview.dart';

/// Port of `src/components/new_ui_student_teacher_for_both_labs/teachercoursepage.vue`
/// (component `CourseLibrary`, route `/newcoursepage`).
///
/// Store state lives in [TeacherCourseController]; the component's `data()`
/// lives here. The list view, the course detail tabs and the preview tab are
/// `part`s of this library (extensions on the state class).
class TeacherCoursePage extends ConsumerStatefulWidget {
  const TeacherCoursePage({super.key});

  @override
  ConsumerState<TeacherCoursePage> createState() => _TeacherCoursePageState();
}

/// `previewItem` — `{ type: 'course' | 'content', data }`.
typedef _PreviewItem = ({String type, Map<String, dynamic>? data});

class _TeacherCoursePageState extends ConsumerState<TeacherCoursePage> {
  // ── data() ──
  bool _isLoading = false;
  bool _isListLoading = false;
  bool _isAttachCurriculLoad = false;
  bool _isAttachINSLoad = false;
  List<Map<String, dynamic>> _coursess = [];
  bool _mobileNavOpen = false;
  String _viewMode = 'grid';
  final _searchQuery = TextEditingController();
  Object? _selectedClassId;
  String _selectedClassName = '';
  // Never set by the UI (the web has no curriculum / grade filter controls).
  final Object? _selectedCurriculumId = null;
  final Object? _selectedGradeId = null;
  String? _expandedCourse;
  Map<String, dynamic>? _selectedCourse;
  Object? _selectedCourseId;
  Map<String, dynamic>? _selectedCourseDetails;
  String _activeCourseTab = 'overview';
  Map<String, dynamic> _updateForm = {
    'title': '',
    'short_name': '',
    'course_code': '',
    'description': '',
    'status': 'published',
    'attach': null,
    'isMathPlay': false,
    '_existingImage': '',
    'instructor_id': '',
    'allclass': null,
    'subject_id': '',
  };
  String _updateSectionOrder = '';
  Map<String, dynamic>? _selectedSectionDetails;
  String _expandedSectionRow = '';
  String _updatechapterOrder = '';
  Map<String, dynamic>? _selectedChapterDetails;
  Object? _selectedChapterId;
  String _expandedChapterRow = '';
  _PreviewItem _previewItem = (type: 'course', data: null);
  bool _sidebarOpen = true;
  bool _isMobile = false;
  Object? _openSectionId;
  Object? _openChapterId;

  double? _lastWidth;

  TeacherCourseController get _ctrl => ref.read(teacherCourseControllerProvider.notifier);
  TeacherCourseState get _store => ref.read(teacherCourseControllerProvider);

  /// `setState` for the `part` extensions.
  void _set(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  /// `canManage`
  bool get _canManage {
    final role = ref.read(sessionProvider).role;
    return role == Role.institute || _store.institutes.any((i) => jsTruthy(i['is_admin']));
  }

  @override
  void initState() {
    super.initState();
    _searchQuery.addListener(() => _set(() {}));
    // `watch: classDetails` (deep).
    ref.listenManual(sessionProvider.select((s) => s.classDetails), (_, next) {
      if (next == null || !jsTruthy(next.id)) return;
      _set(() {
        if (next.name.isNotEmpty) _selectedClassName = next.name;
        final courses = next.extra['courses'];
        if (courses is List) _coursess = visibleCourses(courses, canManage: _canManage);
      });
    });
    Future.microtask(_mounted);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // `checkScreen()` on mount and on every window resize.
    final width = MediaQuery.sizeOf(context).width;
    if (width != _lastWidth) {
      _lastWidth = width;
      _isMobile = width < 1024;
      _sidebarOpen = !_isMobile;
    }
  }

  @override
  void dispose() {
    _searchQuery.dispose();
    super.dispose();
  }

  /// `window.alert(message)`
  Future<void> _alert(String message) => showAppDialog<void>(
        context,
        builder: (ctx) => AppDialogFrame(
          description: message,
          maxWidth: 384,
          actions: [AppButton(label: 'OK', onPressed: () => Navigator.of(ctx).pop())],
        ),
      );

  // ── list ─────────────────────────────────────────────────────────────────

  /// `mounted()`
  Future<void> _mounted() async {
    _set(() => _isListLoading = true);
    try {
      await Future.wait([_ctrl.fetchCurriculums(), _ctrl.getAllInstructors(), _ctrl.getClasses()]);
      final cd = ref.read(sessionProvider).classDetails;
      if (cd != null && jsTruthy(cd.id)) {
        _set(() {
          _selectedClassId = cd.id;
          _selectedClassName = cd.name;
        });
        await _loadCoursesViaClassDetails();
      } else if (_store.institutes.isNotEmpty) {
        await _onClassFilter(_store.institutes.first);
      } else {
        _set(() => _coursess = []);
      }
    } catch (_) {
    } finally {
      _set(() => _isListLoading = false);
    }
  }

  /// `_loadCoursesViaClassDetails()`
  Future<void> _loadCoursesViaClassDetails() async {
    try {
      final response = await _ctrl.fetchClassDetails();
      final details = response ?? ref.read(sessionProvider).classDetails?.toJson();
      if (details == null) {
        _set(() => _coursess = []);
        return;
      }
      _set(() => _coursess = visibleCourses(details['courses'], canManage: _canManage));
    } catch (_) {
      _set(() => _coursess = []);
    }
  }

  /// `onClassSelectChange(value)`
  Future<void> _onClassSelectChange(String? value) async {
    if (value == null || value.isEmpty || value == 'all') {
      await _onClassFilter(null);
    } else {
      final inst = _store.institutes.where((i) => '${i['id']}' == value).firstOrNull;
      if (inst != null) await _onClassFilter(inst);
    }
  }

  /// `onClassFilter(inst)`
  Future<void> _onClassFilter(Map<String, dynamic>? inst) async {
    if (inst == null) {
      _set(() {
        _selectedClassId = null;
        _selectedClassName = '';
        _coursess = [];
      });
      return;
    }
    final label = instituteLabel(inst);
    _set(() {
      _selectedClassId = inst['id'];
      _selectedClassName = label;
      _isListLoading = true;
    });
    try {
      _ctrl.setClassDetails(id: inst['id'], name: label, cId: inst['c_id'] ?? inst['curricula_id'] ?? inst['id']);
      await _loadCoursesViaClassDetails();
    } catch (_) {
      _set(() => _coursess = []);
    } finally {
      _set(() => _isListLoading = false);
    }
  }

  /// `clearAllFilters()`
  void _clearAllFilters() {
    _searchQuery.clear();
    final institutes = _store.institutes;
    if (institutes.isNotEmpty) {
      _onClassFilter(institutes.first);
    } else {
      _set(() {
        _selectedClassId = null;
        _selectedClassName = '';
        _coursess = [];
      });
    }
  }

  /// `_refreshCourseList()`
  Future<void> _refreshCourseList() async {
    if (jsTruthy(_selectedClassId)) {
      await _loadCoursesViaClassDetails();
    } else {
      _set(() => _coursess = []);
    }
  }

  // ── open / close a course ────────────────────────────────────────────────

  /// `openCourse(course, idx)`
  Future<void> _openCourse(Map<String, dynamic> course, int idx) async {
    _set(() {
      _selectedCourse = course;
      _selectedCourseId = course['id'];
      _expandedCourse = 'course-$idx';
      _activeCourseTab = 'overview';
      _expandedSectionRow = '';
      _expandedChapterRow = '';
      _openSectionId = null;
      _openChapterId = null;
      _isLoading = true;
    });
    try {
      final details = await _ctrl.fetchCourseDetails(course['id'] as Object);
      // The web throws on `null.createdInstructorName` and stops here.
      if (details == null) return;
      final user = asMap(dig(details, ['instructor', 'user']));
      final d = <String, dynamic>{
        ...details,
        'createdInstructorName':
            user != null ? '${user['first_name'] ?? 'undefined'} ${user['last_name'] ?? 'undefined'}' : 'N/A',
        'instructors': details['instructors'] is List ? details['instructors'] : const [],
      };
      _set(() {
        _selectedCourseDetails = d;
        _previewItem = (type: 'course', data: d);
      });
      await _ctrl.fetchSections(course['id'] as Object);
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  /// `closeCourse()`
  void _closeCourse() => _set(() {
        _expandedCourse = null;
        _selectedCourse = null;
        _selectedCourseId = null;
        _selectedCourseDetails = null;
        _expandedSectionRow = '';
        _expandedChapterRow = '';
      });

  /// `onPreviewTabClick()`
  Future<void> _onPreviewTabClick() async {
    final id = _selectedCourseId;
    if (!jsTruthy(id)) return;
    _set(() => _isLoading = true);
    try {
      final details = await _ctrl.fetchCourseDetails(id!);
      _set(() {
        _selectedCourseDetails = details;
        _previewItem = (type: 'course', data: details);
        _openSectionId = null;
        _openChapterId = null;
      });
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  // ── create / update / delete course ──────────────────────────────────────

  /// `openCreateDialog()`
  void _openCreateDialog() {
    if (!_canManage) return;
    _ctrl.resetCourseForm();
    if (jsTruthy(_selectedClassId)) _ctrl.patchCourseForm({'allclass': '$_selectedClassId'});
    showAppDialog<void>(
      context,
      builder: (_) => CourseFormDialog(
        update: false,
        initial: const CourseDialogValues(status: 'draft'),
        onSubmit: _submitCreateCourse,
      ),
    );
  }

  /// `submitCreateCourse()`
  Future<bool> _submitCreateCourse(CourseDialogValues v) async {
    if (!_canManage) return false;
    _ctrl.patchCourseForm({
      'title': v.title,
      'short_name': v.shortName,
      'course_code': v.courseCode,
      'description': v.description,
      'image': v.image,
      'status': v.status,
      'is_math_zoro': v.isMathPlay,
    });
    try {
      final success = await _ctrl.createCourse();
      if (success) {
        unawaited(_refreshCourseList());
        return true;
      }
      if (mounted) await _alert('Failed to create course');
      return false;
    } catch (_) {
      return false;
    }
  }

  CourseDialogValues _updateValues() => CourseDialogValues(
        title: '${_updateForm['title'] ?? ''}',
        shortName: '${_updateForm['short_name'] ?? ''}',
        courseCode: '${_updateForm['course_code'] ?? ''}',
        description: '${_updateForm['description'] ?? ''}',
        status: '${_updateForm['status'] ?? 'draft'}',
        image: _updateForm['attach'] is UploadFile ? _updateForm['attach'] as UploadFile : null,
        existingImage: '${_updateForm['_existingImage'] ?? ''}',
        isMathPlay: _updateForm['isMathPlay'] == true,
      );

  /// `openUpdateDialog(courseId)`
  void _openUpdateDialog(Object? courseId) {
    if (!_canManage) return;
    _set(() => _selectedCourseId = courseId);
    showAppDialog<void>(
      context,
      builder: (_) => CourseFormDialog(
        update: true,
        initial: _updateValues(),
        load: () async {
          try {
            final details = await _ctrl.fetchCourseDetails(courseId ?? '');
            if (details == null) return null;
            const statuses = ['published', 'draft', 'archived'];
            _updateForm = {
              ..._updateForm,
              'title': details['title'] ?? '',
              'short_name': details['short_name'] ?? '',
              'course_code': details['course_code'] ?? '',
              'description': details['description'] ?? '',
              'status': statuses.contains(details['status']) ? details['status'] : 'draft',
              'attach': null,
              'isMathPlay': jsTruthy(details['is_math_play']),
              '_existingImage': details['image'] ?? '',
              'instructor_id': dig(details, ['instructor', 'id'])?.toString() ?? '',
              'allclass': details['allclass'],
              'subject_id': details['subject_id']?.toString() ?? '',
            };
            return _updateValues();
          } catch (_) {
            return null;
          }
        },
        onSubmit: _submitUpdateCourse,
      ),
    );
  }

  /// `submitUpdateCourse()`
  Future<bool> _submitUpdateCourse(CourseDialogValues v) async {
    final id = _selectedCourseId;
    if (!_canManage || !jsTruthy(id)) return false;
    _updateForm = {
      ..._updateForm,
      'title': v.title,
      'short_name': v.shortName,
      'course_code': v.courseCode,
      'description': v.description,
      'status': v.status,
      'attach': v.image,
      'isMathPlay': v.isMathPlay,
    };
    try {
      await _ctrl.updateCourse('$id', {..._updateForm});
      await _refreshCourseList();
      final current = _selectedCourseId;
      if (_expandedCourse != null && jsTruthy(current)) {
        final details = await _ctrl.fetchCourseDetails(current!);
        _set(() => _selectedCourseDetails = details);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// `openDeleteCourseDialog(course)` + `confirmDeleteCourse()`
  void _openDeleteCourseDialog(Map<String, dynamic> course) {
    if (!_canManage) return;
    showTcConfirm(
      context,
      title: 'Confirm Delete',
      confirmLabel: 'Yes, Delete',
      message: TextSpan(children: [
        const TextSpan(text: 'Are you sure you want to delete '),
        _bold('"${course['title'] ?? ''}"', colored: true),
        const TextSpan(text: '?'),
      ]),
      onConfirm: () async {
        final id = course['id'];
        if (!_canManage || !jsTruthy(id)) return false;
        _set(() => _isLoading = true);
        try {
          await _ctrl.deleteCourse(id as Object);
          _set(() => _coursess = [for (final c in _coursess) if (c['id'] != id) c]);
          if (_selectedCourseId == id) _closeCourse();
          return true;
        } catch (_) {
          return false;
        } finally {
          _set(() => _isLoading = false);
        }
      },
    );
  }

  /// `<span class="font-semibold">` in a dialog description; only the course
  /// delete dialog adds `text-slate-800 dark:text-white` ([colored]).
  TextSpan _bold(String text, {bool colored = false}) => TextSpan(
        text: text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: colored ? (context.isDark ? Colors.white : Tw.slate800) : null,
        ),
      );

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.watch(teacherCourseControllerProvider);
    ref.watch(sessionProvider.select((s) => s.role));
    final dark = context.isDark;
    final pad = context.isMd ? 24.0 : (context.isSm ? 16.0 : 12.0);

    final main = SingleChildScrollView(
      padding: EdgeInsets.all(pad),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: _expandedCourse == null
              ? _buildListView()
              : _EnterTransition(key: ValueKey(_expandedCourse), child: _buildDetailView()),
        ),
      ),
    );

    return LoadingOverlay(
      loading: _isLoading,
      child: ColoredBox(
        color: dark ? Tw.slate900 : Tw.slate50,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [_buildTopBar(), Expanded(child: main)],
            ),
            if (_mobileNavOpen)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _set(() => _mobileNavOpen = false),
                  child: ClipRect(
                    child: BackdropFilter(
                      // `backdrop-blur-sm` = blur(8px)
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: ColoredBox(color: Colors.black.withValues(alpha: 0.4)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// The sticky `<header>`. Tailwind v4 ignores the `xs:` variants used here
  /// (no `xs` breakpoint is configured), so "Course Library", the "Back" /
  /// "New Course" labels and the "View Only" pill never show on the web.
  Widget _buildTopBar() {
    final dark = context.isDark;
    final sm = context.isSm;
    final canManage = _canManage;
    final badge = sm ? 36.0 : 32.0;
    return Container(
      height: sm ? 64 : 56,
      padding: EdgeInsets.symmetric(horizontal: sm ? 20 : 12),
      decoration: BoxDecoration(
        color: dark ? Tw.slate800 : Colors.white,
        border: Border(bottom: BorderSide(color: dark ? Tw.slate700 : Tw.slate200)),
        boxShadow: TcShadows.sm,
      ),
      child: Row(
        children: [
          if (!context.isMd) ...[
            SizedBox(
              width: badge,
              height: badge,
              child: AppButton(
                variant: AppButtonVariant.outline,
                size: AppButtonSize.icon,
                icon: BootstrapIcons.list,
                onPressed: () => _set(() => _mobileNavOpen = !_mobileNavOpen),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            width: badge,
            height: badge,
            alignment: Alignment.center,
            // `rounded-lg` (16px) `shadow-lg` — the `shadow-emerald-*`
            // colour can't apply to the theme's var() shadow.
            decoration: const BoxDecoration(
              gradient: emeraldGradient,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              boxShadow: TcShadows.lg,
            ),
            child: const Icon(BootstrapIcons.mortarboard_fill, size: 14, color: Colors.white),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Courses',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: dark ? Colors.white : Tw.slate900),
            ),
          ),
          // `justify-between gap-2`
          const SizedBox(width: 8),
          // "Back" is `hidden xs:inline`, so only the arrow shows
          // (`text-[12px] sm:text-[13px]`).
          if (_expandedCourse != null)
            SizedBox(
              height: sm ? 36 : 32,
              child: AppButton(
                variant: AppButtonVariant.outline,
                onPressed: _closeCourse,
                child: Icon(BootstrapIcons.arrow_left, size: sm ? 13 : 12),
              ),
            ),
          if (_expandedCourse == null && canManage) _GradientPillButton(label: 'New', onTap: _openCreateDialog),
        ],
      ),
    );
  }
}

/// `rounded-full bg-gradient-to-br from-emerald-500 to-emerald-700 text-white
/// shadow-lg font-semibold` "+ New" button. The header one (`gap-1 px-3
/// sm:px-4 h-8 sm:h-9 text-[12px] sm:text-[13.5px]`) also has
/// `hover:from-emerald-600 hover:to-emerald-800 hover:-translate-y-0.5`; the
/// empty-state one ([fontSize] given: `gap-1.5 text-[13px]`, `h-9 px-4`) has
/// no hover change (its `hover:bg-primary/90` sits under the gradient).
class _GradientPillButton extends StatefulWidget {
  const _GradientPillButton({required this.label, required this.onTap, this.fontSize});
  final String label;
  final VoidCallback onTap;
  final double? fontSize;

  @override
  State<_GradientPillButton> createState() => _GradientPillButtonState();
}

class _GradientPillButtonState extends State<_GradientPillButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final sm = context.isSm;
    final header = widget.fontSize == null;
    final hover = header && _hover;
    final fontSize = widget.fontSize ?? (sm ? 13.5 : 12.0);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          transform: Matrix4.translationValues(0, hover ? -2 : 0, 0),
          height: header ? (sm ? 36 : 32) : 36,
          padding: EdgeInsets.symmetric(horizontal: header && !sm ? 12 : 16),
          decoration: BoxDecoration(
            gradient: hover
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Tw.emerald600, TcTw.emerald800],
                  )
                : emeraldGradient,
            borderRadius: BorderRadius.circular(999),
            boxShadow: TcShadows.lg,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(BootstrapIcons.plus_lg, size: fontSize, color: Colors.white),
              SizedBox(width: header ? 4 : 6),
              Text(widget.label,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: fontSize)),
            ],
          ),
        ),
      ),
    );
  }
}

/// The detail view's `<Transition>` enter: `opacity-0 translate-y-4` →
/// visible over 300ms with `ease-[cubic-bezier(0.34,1.56,0.64,1)]`.
class _EnterTransition extends StatelessWidget {
  const _EnterTransition({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: const Cubic(0.34, 1.56, 0.64, 1),
        child: child,
        builder: (context, t, child) => Opacity(
          opacity: t.clamp(0.0, 1.0),
          child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: child),
        ),
      );
}
