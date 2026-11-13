import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/files.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart';
import '../institutes/institute_widgets.dart' show SpinIcon;
import '../users/users_widgets.dart' show FileInputField, FormGrid, ShadCard, UploadPreview;
import 'course_create_controller.dart';
import 'course_create_logic.dart';

/// Port of `src/pages/course/coursecreate.vue` (`/coursecreate`).
///
/// `courseForm` is store state, so it lives in [CourseCreateController]; the
/// component's `data()` lives here.
class CourseCreatePage extends ConsumerStatefulWidget {
  const CourseCreatePage({super.key});

  @override
  ConsumerState<CourseCreatePage> createState() => _CourseCreatePageState();
}

class _CourseCreatePageState extends ConsumerState<CourseCreatePage> {
  // ── data() ──
  String _courseZone = '';
  bool _isMathPlay = false;
  bool _isLoading = false;
  String _statusString = 'draft';
  String? _selectedCurriculumId;
  bool _isCreateBtnLoading = false;
  List<Map<String, dynamic>> _allClassesData = const [];

  final _title = TextEditingController();
  final _shortName = TextEditingController();
  final _courseCode = TextEditingController();
  final _description = TextEditingController();

  CourseCreateController get _ctrl => ref.read(courseCreateControllerProvider.notifier);
  Map<String, dynamic> get _form => ref.read(courseCreateControllerProvider).courseForm;

  @override
  void initState() {
    super.initState();
    _syncText();
    Future.microtask(_mounted);
  }

  @override
  void dispose() {
    for (final c in [_title, _shortName, _courseCode, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncText() {
    final f = _form;
    String s(String k) => f[k] == null ? '' : '${f[k]}';
    if (_title.text != s('title')) _title.text = s('title');
    if (_shortName.text != s('short_name')) _shortName.text = s('short_name');
    if (_courseCode.text != s('course_code')) _courseCode.text = s('course_code');
    if (_description.text != s('description')) _description.text = s('description');
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

  /// `mounted()`
  Future<void> _mounted() async {
    setState(() => _isLoading = true);
    try {
      final instituteId = ref.read(sessionProvider).userInfo?.instituteId;
      if (instituteId == null || instituteId == 0) {
        await _alert('Please log in and select an institute first');
        return;
      }
      await _ctrl.fetchCurriculums();
      await _ctrl.getAllInstructors();
      _ctrl.resetCourseForm();
      _syncText();

      await _ctrl.loadAllClasses();
      final s = ref.read(courseCreateControllerProvider);
      _allClassesData = s.allClasses;

      _setStatus(asStatus(s.courseForm['status']));
      final curriculumId = s.courseForm['curriculum_id'];
      if (curriculumId != null && curriculumId != '') {
        _setCurriculum('$curriculumId');
      } else {
        _setCurriculum(null);
      }
    } catch (_) {
      if (mounted) await _alert('Failed to load data. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  static String asStatus(Object? v) => v == null ? '' : '$v';

  /// `watch: statusString`
  void _setStatus(String v) {
    setState(() => _statusString = v);
    _ctrl.patchCourseForm({'status': v});
  }

  /// `watch: selectedCurriculumId`
  void _setCurriculum(String? v) {
    setState(() => _selectedCurriculumId = v);
    _ctrl.patchCourseForm({'curriculum_id': v ?? ''});
  }

  /// `filteredClasses`
  List<Map<String, dynamic>> get _filteredClasses {
    final instituteId = ref.read(sessionProvider).userInfo?.instituteId;
    if (instituteId == null || instituteId == 0 || _allClassesData.isEmpty) return const [];
    return _allClassesData;
  }

  /// `handleFile(e)`
  Future<void> _handleFile() async {
    final file = await pickImageFile();
    if (file == null) return;
    _ctrl.patchCourseForm({'image': file});
  }

  /// `loadSubjectsForSelectedClasses()` — errors are only logged by the web.
  Future<void> _loadSubjectsForSelectedClasses() async {
    try {
      final instituteId = ref.read(sessionProvider).userInfo?.instituteId;
      if (instituteId == null || instituteId == 0) return;
      final firstClassId = _form['allclass'];
      await _ctrl.getAllSubjects(instituteId, firstClassId ?? '');
    } catch (_) {}
  }

  /// `onSubmit()`
  Future<void> _onSubmit() async {
    if (!hasRequiredCourseFields(_form, _selectedCurriculumId)) {
      await _alert('Please fill in all required fields marked with *');
      return;
    }
    _ctrl.patchCourseForm({'is_math_zoro': _isMathPlay, 'zone': _courseZone});
    setState(() => _isCreateBtnLoading = true);
    try {
      final success = await _ctrl.createCourse();
      if (!mounted) return;
      if (success) {
        setState(() {
          _selectedCurriculumId = null;
          _isMathPlay = false;
          _courseZone = '';
        });
        context.go('/courselist');
      } else {
        await _alert('Failed to create course');
      }
    } catch (_) {
      if (mounted) await _alert('Error creating course');
    } finally {
      if (mounted) setState(() => _isCreateBtnLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(courseCreateControllerProvider);
    final form = s.courseForm;
    final twoCols = context.isMd;
    final image = form['image'] is UploadFile ? form['image'] as UploadFile : null;
    final allclass = form['allclass'];
    final hasClass = allclass != null && allclass != '';

    Widget grid(List<Widget> children) => FormGrid(columns: twoCols ? 2 : 1, children: children);

    final title = _Item(
      label: 'Title',
      required: true,
      child: AppTextField(
        controller: _title,
        hint: 'Enter Course Title',
        onChanged: (v) => _ctrl.patchCourseForm({'title': v}),
      ),
    );
    final shortName = _Item(
      label: 'Course Short Name',
      required: true,
      child: AppTextField(
        controller: _shortName,
        hint: 'Enter short name',
        onChanged: (v) => _ctrl.patchCourseForm({'short_name': v}),
      ),
    );
    final curriculum = _Item(
      label: 'Curriculum',
      required: true,
      child: AppSelect<String>(
        value: _selectedCurriculumId,
        placeholder: 'Select Curriculum',
        items: [
          // `<SelectLabel>Available Curriculums</SelectLabel>`
          const AppSelectItem('__label__', 'Available Curriculums', enabled: false),
          for (final c in publishedCurriculums(s.curriculums)) AppSelectItem('${c['id']}', '${c['name'] ?? ''}'),
        ],
        onChanged: (v) {
          if (v != null && v != '__label__') _setCurriculum(v);
        },
      ),
    );
    final courseCode = _Item(
      label: 'Course Code',
      required: true,
      child: AppTextField(
        controller: _courseCode,
        hint: 'Enter course code',
        onChanged: (v) => _ctrl.patchCourseForm({'course_code': v}),
      ),
    );
    final imageField = _Item(
      label: 'Image',
      child: FileInputField(fileName: image?.name, onTap: _handleFile),
    );
    final status = _Item(
      label: 'Status',
      child: AppSelect<String>(
        value: _statusString,
        placeholder: 'Select status',
        items: const [
          AppSelectItem('published', 'Published'),
          AppSelectItem('draft', 'UnPublished'),
          AppSelectItem('archived', 'Archived'),
        ],
        onChanged: (v) {
          if (v != null) _setStatus(v);
        },
      ),
    );
    final instructors = _Item(
      label: 'Instructors',
      required: true,
      child: AppSelect<String>(
        value: form['instructor_id'] == null || form['instructor_id'] == '' ? null : '${form['instructor_id']}',
        placeholder: 'Select Instructor',
        items: [for (final inst in s.instructors) AppSelectItem('${inst['id']}', instructorOptionLabel(inst))],
        onChanged: (v) => _ctrl.patchCourseForm({'instructor_id': v ?? ''}),
      ),
    );
    final classes = _filteredClasses;
    final allClass = _Item(
      label: 'All Class',
      child: _W170(
        child: AppSelect<String>(
          value: hasClass ? '$allclass' : null,
          placeholder: 'Select Class',
          items: [for (final c in classes) AppSelectItem('${c['id']}', '${c['name'] ?? ''}')],
          onChanged: (v) {
            if (v == null) return;
            final picked = classes.firstWhere((c) => '${c['id']}' == v, orElse: () => const {});
            _ctrl.patchCourseForm({'allclass': picked['id'] ?? v});
            _loadSubjectsForSelectedClasses();
          },
        ),
      ),
    );
    final subjects = _Item(
      label: 'Subjects',
      child: _W170(
        child: AppSelect<String>(
          value: form['subject_id'] == null || form['subject_id'] == '' ? null : '${form['subject_id']}',
          placeholder: 'Select Subject',
          enabled: hasClass,
          items: [for (final sub in s.allsubject) AppSelectItem('${sub['id']}', '${sub['name'] ?? ''}')],
          onChanged: (v) => _ctrl.patchCourseForm({'subject_id': v ?? ''}),
        ),
      ),
    );
    final zone = _Item(
      label: 'Course Zone',
      child: AppSelect<String>(
        value: _courseZone.isEmpty ? null : _courseZone,
        placeholder: 'Select Course Zone',
        enabled: hasClass,
        items: const [
          AppSelectItem('mathzone', 'Math Zone'),
          AppSelectItem('mathplay', 'Math Play'),
          AppSelectItem('sciencezone', 'Science Zone'),
          AppSelectItem('scienceplay', 'Science Play'),
        ],
        onChanged: (v) => setState(() => _courseZone = v ?? ''),
      ),
    );
    final description = _Item(
      label: 'Description',
      child: AppTextField(
        controller: _description,
        hint: 'Type your message here',
        maxLines: null,
        minLines: 3,
        onChanged: (v) => _ctrl.patchCourseForm({'description': v}),
      ),
    );

    final submit = Align(
      alignment: Alignment.centerRight,
      // `mt-4` + the form's `gap-4` (the hidden checkbox row takes no gap).
      child: Padding(
        padding: const EdgeInsets.only(top: 32),
        child: AppButton(
          onPressed: _isCreateBtnLoading ? null : _onSubmit,
          child: _isCreateBtnLoading ? const SpinIcon(color: Colors.white) : const Text('Create'),
        ),
      ),
    );

    const gap = SizedBox(height: 16);
    return LoadingOverlay(
      loading: _isLoading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ShadCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => context.go('/courselist'),
                      customBorder: const CircleBorder(),
                      child: Icon(BootstrapIcons.arrow_left_circle_fill, size: 16, color: context.colors.primary),
                    ),
                    const SizedBox(width: 8),
                    const Text('Create Course', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    grid([title, shortName]),
                    gap,
                    grid([curriculum, courseCode]),
                    gap,
                    grid([imageField, status]),
                    if (image != null) ...[
                      gap,
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _ImagePreviewCard(file: image),
                        ),
                      ),
                    ],
                    gap,
                    grid([instructors, allClass]),
                    gap,
                    subjects,
                    gap,
                    zone,
                    gap,
                    description,
                    // The "Math Play Course" checkbox is `hidden` in the web.
                    submit,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// `<FormItem><FormLabel>Text<span class="text-red-500">*</span></FormLabel>…`
class _Item extends StatelessWidget {
  const _Item({required this.label, required this.child, this.required = false});
  final String label;
  final bool required;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        // `<FormLabel>` is a `flex gap-2` label, so the star sits 8px away.
        Row(
          children: [
            Flexible(child: Text(label, style: style)),
            if (required) ...[const SizedBox(width: 8), Text('*', style: style.copyWith(color: Tw.red500))],
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// `<div class="mt-2 w-full max-w-xs"><Card class="p-2"><div class="h-40 bg-gray-50 …"><img object-contain>`
class _ImagePreviewCard extends StatelessWidget {
  const _ImagePreviewCard({required this.file});
  final UploadFile file;

  @override
  Widget build(BuildContext context) => ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 320),
    child: ShadCard(
      padding: const EdgeInsets.all(8),
      child: Container(
        height: 160,
        width: double.infinity,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Tw.gray50, borderRadius: BorderRadius.circular(14)),
        child: UploadPreview(file: file, fit: BoxFit.contain),
      ),
    ),
  );
}

/// `<SelectTrigger class="w-170">`: Tailwind v4 reads `w-170` as 680px. The
/// web lets the trigger overflow narrower cells; here it is capped at the
/// available width.
class _W170 extends StatelessWidget {
  const _W170({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) => Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(width: c.maxWidth < 680 ? c.maxWidth : 680, child: child),
    ),
  );
}
