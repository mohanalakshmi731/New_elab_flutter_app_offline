import 'dart:convert';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/files.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../../widgets/form_fields.dart';
import '../common/lms_handoff.dart';
import '../exams/exam_widgets.dart'
    show
        ExamAddRuleButton,
        ExamDateButton,
        ExamFieldLabel,
        ExamFileInput,
        ExamImagePreview,
        ExamInfoNote,
        ExamTrashButton;
import 'exam_manage_controller.dart';
import 'exam_manage_logic.dart';
import 'exam_manage_widgets.dart';

part 'edit_exam_cards.dart';

/// Port of `src/pages/exams/EditExams.vue` (`/editexams/:id`, [id] = the
/// route param) — edits an exam's basic info, settings, course / chapter,
/// sections + question-selection rules and image.
///
/// Reads the store `courses` and `sections` through [lmsHandoffProvider].
/// The page's Vue watchers (`selectedCourseId`, `selectedSubjectId`,
/// `selectedClassId`, `imageUrl`) are emulated with Vue's timing — they
/// run when `mounted()` next awaits — because the web's load result depends
/// on it (see [_flushWatchers]).
class EditExamPage extends ConsumerStatefulWidget {
  const EditExamPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<EditExamPage> createState() => _EditExamPageState();
}

/// One rule (`{ topic_id, difficulty, question_type, tags, pick_count }`).
class _RuleForm {
  _RuleForm({this.topicId = '', this.difficulty = '', this.questionType = '', Object? tags = '', Object? pickCount = 0})
      : tags = TextEditingController(text: inputText(tags)),
        pickCount = TextEditingController(text: inputText(pickCount));

  factory _RuleForm.from(Json r) => _RuleForm(
        topicId: r['topic_id'],
        difficulty: vueText(r['difficulty']),
        questionType: vueText(r['question_type']),
        tags: r['tags'],
        pickCount: r['pick_count'],
      );

  /// The raw `topic_id` (API value until a topic is picked).
  Object? topicId;
  String difficulty;
  String questionType;
  final TextEditingController tags;
  final TextEditingController pickCount;

  Json toJson() => {
        'topic_id': topicId,
        'difficulty': difficulty,
        'question_type': questionType,
        'tags': tags.text,
        'pick_count': pickCount.text,
      };

  void dispose() {
    tags.dispose();
    pickCount.dispose();
  }
}

/// One section (`{ name, description, question_count, marks_per_question,
/// rules }`).
class _SectionForm {
  _SectionForm(Json s)
      : name = TextEditingController(text: inputText(s['name'])),
        description = TextEditingController(text: inputText(s['description'])),
        questionCount = TextEditingController(text: inputText(s['question_count'])),
        marksPerQuestion = TextEditingController(text: inputText(s['marks_per_question'])),
        rules = [for (final r in mapsOf(s['rules'])) _RuleForm.from(r)];

  final TextEditingController name;
  final TextEditingController description;
  final TextEditingController questionCount;
  final TextEditingController marksPerQuestion;
  final List<_RuleForm> rules;

  Json toJson() => {
        'name': name.text,
        'description': description.text,
        'question_count': questionCount.text,
        'marks_per_question': marksPerQuestion.text,
        'rules': [for (final r in rules) r.toJson()],
      };

  void dispose() {
    name.dispose();
    description.dispose();
    questionCount.dispose();
    marksPerQuestion.dispose();
    for (final r in rules) {
      r.dispose();
    }
  }
}

class _EditExamPageState extends ConsumerState<EditExamPage> {
  // ── data() ──────────────────────────────────────────────────────────────
  final _imageCaption = TextEditingController();
  final _imageOrder = TextEditingController(text: '0');
  String _selectedClassId = '';
  String _selectedBatchId = '';
  // `selectedChapterId` / `selectedContentId` are only ever cleared (by the
  // course watcher) and never read, so they are not kept.
  String _selectedSubjectId = '';
  String _selectedCourseId = '';

  // form
  String _locale = defaultExamLocale;
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _description = TextEditingController();
  String _examType = '';
  final _durationMinutes = TextEditingController(text: '0');
  final _negativeMarks = TextEditingController(text: '0');
  final _maxAttempts = TextEditingController(text: '0');
  Object? _randomizeQuestionOrder = false;
  Object? _randomizeOptionsOrder = false;
  Object? _enableNegativeMarking = false;
  bool _showImmediateFeedback = false;
  String _showResultsToStudentAt = '';
  Object? _isOpenAnytime = false;

  final List<_SectionForm> _sections = [_SectionForm(newEditSection())];

  final _imageUrl = TextEditingController();
  final _imageUrlFocus = FocusNode();
  String _imagePreview = '';
  DateTime? _startDate;
  DateTime? _endDate;
  String _startAt = '';
  String _endAt = '';

  ExamManageController get _ctrl => ref.read(examManageControllerProvider.notifier);
  Map<String, dynamic> get _handoff => ref.read(lmsHandoffProvider);

  @override
  void initState() {
    super.initState();
    // `@blur="imagePreview = imageUrl || ''"`
    _imageUrlFocus.addListener(() {
      if (!_imageUrlFocus.hasFocus) _set(() => _imagePreview = _imageUrl.text);
    });
    Future.microtask(_mounted);
  }

  @override
  void dispose() {
    for (final c in [
      _imageCaption,
      _imageOrder,
      _name,
      _code,
      _description,
      _durationMinutes,
      _negativeMarks,
      _maxAttempts,
      _imageUrl,
    ]) {
      c.dispose();
    }
    _imageUrlFocus.dispose();
    for (final s in _sections) {
      s.dispose();
    }
    super.dispose();
  }

  /// `setState` for the card builders in the part file.
  void _set(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  // ── Vue watchers ─────────────────────────────────────────────────────────

  static const _wSubject = 'selectedSubjectId';
  static const _wClass = 'selectedClassId';
  static const _wCourse = 'selectedCourseId';
  static const _wImageUrl = 'imageUrl';

  /// Each watcher's `oldValue` (the value it last ran with).
  final _watchOld = <String, String>{_wSubject: '', _wClass: '', _wCourse: '', _wImageUrl: ''};

  /// Watchers triggered since the last flush, in trigger order.
  final _watchQueue = <String>[];

  String _watched(String key) => switch (key) {
        _wSubject => _selectedSubjectId,
        _wClass => _selectedClassId,
        _wCourse => _selectedCourseId,
        _ => _imageUrl.text,
      };

  /// Assigns a watched field (queues its watcher like a reactive write).
  void _assign(String key, String value) {
    switch (key) {
      case _wSubject:
        _selectedSubjectId = value;
      case _wClass:
        _selectedClassId = value;
      case _wCourse:
        _selectedCourseId = value;
      default:
        if (_imageUrl.text != value) _imageUrl.text = value;
    }
    if (!_watchQueue.contains(key)) _watchQueue.add(key);
  }

  /// Vue's pre-flush: every queued watcher whose value changed runs once,
  /// in trigger order (a watcher triggered while running is queued again).
  /// The async parts (`fetchCourseDetails`, `getBatches`) are not awaited.
  void _flushWatchers() {
    while (_watchQueue.isNotEmpty) {
      final key = _watchQueue.removeAt(0);
      final value = _watched(key);
      if (value == _watchOld[key]) continue;
      _watchOld[key] = value;
      _runWatcher(key, value);
    }
    _set(() {});
  }

  void _runWatcher(String key, String value) {
    final courses = mapsOf(_handoff['courses']);
    switch (key) {
      case _wSubject:
        // `selectedSubjectId(subjectId)`
        if (value.isEmpty || _selectedCourseId.isEmpty) return;
        final course = courseByExamKey(courses, _selectedCourseId);
        if (course == null) return;
        _ctrl.fetchCourseDetails(course['id'] ?? 'undefined').catchError((Object _) => null);
      case _wClass:
        // `selectedClassId(classId)`
        _selectedBatchId = '';
        if (value.isEmpty) return;
        _ctrl.getBatches(jsNumber(value)).catchError((Object _) {});
      case _wCourse:
        // `selectedCourseId(courseExamId)` — note the strict `===` lookup.
        _assign(_wSubject, '');
        if (value.isEmpty) return;
        Json? course;
        for (final c in courses) {
          if (c['exam_course_id'] == value) {
            course = c;
            break;
          }
        }
        if (course == null) return;
        _ctrl.fetchCourseDetails(course['id'] ?? 'undefined').catchError((Object _) => null);
      default:
        // `imageUrl(val)`
        if (value.isNotEmpty) _imagePreview = value;
    }
  }

  // ── mounted() ────────────────────────────────────────────────────────────

  Future<void> _mounted() async {
    try {
      await _ctrl.fetchCourse();
      await Future.wait([_ctrl.fetchCourse(), _ctrl.getClasses()]);

      final res = await _ctrl.fetchExamById(widget.id);
      if (!mounted || res == null) return;
      final exam = asMap(res) ?? <String, dynamic>{};

      // BASIC INFO + SETTINGS
      final f = editExamFormFrom(exam);
      _locale = jsStr(f['locale']);
      _name.text = inputText(f['name']);
      _code.text = inputText(f['code']);
      _description.text = inputText(f['description']);
      _examType = vueText(f['exam_type']);
      _durationMinutes.text = inputText(f['duration_minutes']);
      _maxAttempts.text = inputText(f['max_attempts']);
      _enableNegativeMarking = f['enable_negative_marking'];
      _negativeMarks.text = inputText(f['negative_marks']);
      _randomizeQuestionOrder = f['randomize_question_order'];
      _randomizeOptionsOrder = f['randomize_options_order'];
      _showImmediateFeedback = f['show_immediate_feedback'] == true;
      _showResultsToStudentAt = vueText(f['show_results_to_student_at']);

      // ASSOCIATION (CLASS/BATCH/COURSE/CHAPTER)
      _assign(_wClass, jsTruthy(dig(exam, const ['course', 'id'])) ? jsField(exam, 'course_id') : '');
      _selectedBatchId = jsTruthy(dig(exam, const ['batch', 'id'])) ? jsField(exam, 'batch_id') : '';
      _assign(_wCourse, jsTruthy(exam['course_id']) ? jsStr(exam['course_id']) : '');
      _assign(_wSubject, jsTruthy(exam['subject_id']) ? jsStr(exam['subject_id']) : '');
      _set(() {});

      if (_selectedClassId.isNotEmpty) {
        final batches = _ctrl.getBatches(jsNumber(_selectedClassId));
        // The queued watchers run as soon as mounted() awaits.
        _flushWatchers();
        await batches;
        if (!mounted) return;
      }

      _isOpenAnytime = f['is_open_anytime'];
      if (jsTruthy(exam['start_time'])) {
        final start = jsDate(exam['start_time']);
        _startDate = start;
        _startAt = start == null ? 'NaN:NaN' : hhmm(start);
      }
      if (jsTruthy(exam['end_time'])) {
        final end = jsDate(exam['end_time']);
        _endDate = end;
        _endAt = end == null ? 'NaN:NaN' : hhmm(end);
      }

      final sections = [for (final s in editSectionsFromExam(exam)) _SectionForm(s)];
      for (final s in _sections) {
        s.dispose();
      }
      _sections
        ..clear()
        ..addAll(sections);

      final images = asList(exam['images']);
      if (jsTruthy(exam['images']) && images.isNotEmpty) {
        final img = asMap(images.first) ?? const <String, dynamic>{};
        _assign(_wImageUrl, vueText(img['image_url']));
        _imagePreview = vueText(img['image_url']);
        _imageCaption.text = vueText(img['caption'] ?? '');
        _imageOrder.text = inputText(img['order_index'] ?? 1);
      }

      // Map the blueprint topics onto the (current) store sections.
      final subject = mapExamTopics(exam, mapsOf(_handoff['sections']));
      if (subject != null) _assign(_wSubject, subject);

      _flushWatchers();
    } catch (_) {
      // Errors were toasted by the API client; the web left mounted() rejected.
    }
  }

  // ── methods ──────────────────────────────────────────────────────────────

  /// `v-model="selectedCourseId"`
  void _onCourseChanged(String? value) {
    _assign(_wCourse, value ?? '');
    _flushWatchers();
  }

  /// `v-model="selectedSubjectId"` (the Chapter select)
  void _onSubjectChanged(String? value) {
    _assign(_wSubject, value ?? '');
    _flushWatchers();
  }

  /// `v-model="imageUrl"` (typing in "Image URL")
  void _onImageUrlTyped(String value) {
    _assign(_wImageUrl, value);
    _flushWatchers();
  }

  /// `onImageUpload` — the web previews (and later saves) a local
  /// `URL.createObjectURL(file)` blob URL without uploading the file; the
  /// native equivalent is the picked file's local URI.
  Future<void> _onImageUpload() async {
    final file = await pickImageFile();
    if (file == null || !mounted) return;
    final local = file.path != null
        ? Uri.file(file.path!).toString()
        : 'data:${mimeTypeFor(file.name)};base64,${base64Encode(file.bytes!)}';
    _imagePreview = local;
    _assign(_wImageUrl, local);
    _flushWatchers();
  }

  /// `removeImage()`
  void _removeImage() {
    _imagePreview = '';
    _assign(_wImageUrl, '');
    _imageCaption.text = '';
    _flushWatchers();
  }

  void _addSection() => _set(() => _sections.add(_SectionForm(newEditSection())));

  void _removeSection(int index) => _set(() => _sections.removeAt(index).dispose());

  void _addRule(_SectionForm section) => _set(() => section.rules.add(_RuleForm.from(newEditRule())));

  void _removeRule(_SectionForm section, int index) => _set(() => section.rules.removeAt(index).dispose());

  /// `updateExamHandler()`
  Future<void> _updateExamHandler() async {
    try {
      final payload = buildUpdateExamPayload(
        locale: _locale,
        name: _name.text,
        code: _code.text,
        description: _description.text,
        examType: _examType,
        durationMinutes: _durationMinutes.text,
        maxAttempts: _maxAttempts.text,
        enableNegativeMarking: _enableNegativeMarking,
        negativeMarks: _negativeMarks.text,
        randomizeQuestionOrder: _randomizeQuestionOrder,
        randomizeOptionsOrder: _randomizeOptionsOrder,
        showImmediateFeedback: _showImmediateFeedback,
        showResultsToStudentAt: _showResultsToStudentAt,
        selectedCourseId: _selectedCourseId,
        selectedSubjectId: _selectedSubjectId,
        selectedBatchId: _selectedBatchId,
        isOpenAnytime: _isOpenAnytime,
        sections: [for (final s in _sections) s.toJson()],
        imageUrl: _imageUrl.text,
        imageCaption: _imageCaption.text,
        imageOrder: _imageOrder.text,
      );
      await _ctrl.updateExam(widget.id, payload);
      AppToast.success('Exam updated successfully',
          background: const Color(0xFF16A34A));
      if (mounted) context.go('/exams');
    } catch (_) {
      // console.error on the web; API errors were already toasted.
    }
  }

  /// `backtoList()`
  void _backToList() => context.go('/exams');

  Future<void> _pickDate(bool start) async {
    final current = start ? _startDate : _endDate;
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: current ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 50),
    );
    if (picked == null) return;
    _set(() {
      if (start) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _pickTime(bool start) async {
    final value = start ? _startAt : _endAt;
    final m = RegExp(r'^(\d{1,2}):(\d{2})').firstMatch(value);
    final picked = await showTimePicker(
      context: context,
      initialTime: m == null
          ? TimeOfDay.now()
          : TimeOfDay(hour: int.parse(m.group(1)!), minute: int.parse(m.group(2)!)),
    );
    if (picked == null) return;
    final text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    _set(() {
      if (start) {
        _startAt = text;
      } else {
        _endAt = text;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(lmsHandoffProvider.select((m) => (m['courses'], m['sections'])));
    final courses = mapsOf(store.$1);
    final courseSections = mapsOf(store.$2);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _basicInformationCard(),
          const SizedBox(height: 16),
          _settingsCard(),
          const SizedBox(height: 16),
          _associationCard(courses, courseSections),
          const SizedBox(height: 16),
          _scheduleCard(),
          const SizedBox(height: 16),
          _examSectionsCard(courseSections),
          const SizedBox(height: 16),
          _examImagesCard(),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(
                label: 'Cancel',
                backgroundColor: Tw.gray100,
                foregroundColor: Colors.black,
                onPressed: _backToList,
              ),
              const SizedBox(width: 16),
              AppButton(label: 'Update', onPressed: _updateExamHandler),
            ],
          ),
        ],
      ),
    );
  }
}
