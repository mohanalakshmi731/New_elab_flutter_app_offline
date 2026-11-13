import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/form_fields.dart';
import '../common/lms_handoff.dart';
import '../users/users_widgets.dart' show FormGrid;
import 'schedule_exam_controller.dart';
import 'schedule_exam_logic.dart';
import 'schedule_exam_widgets.dart';

/// Port of `src/pages/schedules/scheduleexam.vue`, embedded (in a dialog) by
/// the schedules screens: `<scheduleexam :schedule-id :exam-id :batch-id
/// :course-id @created @close>`, and inline by `ScheduleExamListView`'s edit
/// button.
///
/// Create mode loads the course of [courseId]; edit mode ([examId] set)
/// loads the exam and maps its course (`exam_course_id`), sections, rules and
/// question pool back into the form.
///
/// Sizes itself to its content; when the parent gives it a bounded height
/// (a dialog without its own scroll view) it scrolls on its own. It has no
/// close button of its own (the dialog's X closes it, as on the web).
///
/// Store fields read through lmsHandoff: `sections` (course tree),
/// `courses`, `activeScheduleIdss`. The web saves with the store's
/// `activeScheduleIdss`, not the [scheduleId] prop; when the schedules
/// screen has not published it, [scheduleId] (the same value there) is used.
class ScheduleExamView extends ConsumerStatefulWidget {
  const ScheduleExamView({
    super.key,
    required this.scheduleId,
    this.examId,
    this.batchId,
    this.courseId,
    this.onCreated,
    this.onClose,
  });

  /// `scheduleId` (required, String | Number).
  final Object scheduleId;
  final Object? examId;
  final Object? batchId;
  final Object? courseId;

  /// `$emit('created')`
  final VoidCallback? onCreated;

  /// `$emit('close')`
  final VoidCallback? onClose;

  @override
  ConsumerState<ScheduleExamView> createState() => _ScheduleExamViewState();
}

/// One `rules[]` entry of a section (`v-model` targets).
class _RuleForm {
  _RuleForm(Map<String, dynamic> m)
      : topicUuid = m['topic_uuid'],
        topicId = jsTruthy(m['topic_id']) ? jsStr(m['topic_id']) : '',
        difficulty = asString(m['difficulty']),
        questionType = asString(m['question_type']),
        tags = TextEditingController(text: inputText(m['tags'])),
        pickCount = TextEditingController(text: inputText(m['pick_count']));

  /// `topic_uuid` (edit mode only; never sent).
  final Object? topicUuid;

  /// `topic_id` — `String(topic.exam_content_id)` of the chosen topic.
  String topicId;
  String? difficulty;
  String? questionType;
  final TextEditingController tags;

  /// `v-model.number="rule.pick_count"`
  final TextEditingController pickCount;

  Map<String, dynamic> toMap() => {
        if (topicUuid != null) 'topic_uuid': topicUuid,
        'topic_id': topicId,
        'difficulty': difficulty,
        'question_type': questionType,
        'tags': tags.text,
        'pick_count': vueNumberInput(pickCount.text),
      };

  void dispose() {
    tags.dispose();
    pickCount.dispose();
  }
}

/// One `sections[]` entry of the form.
class _SectionForm {
  _SectionForm(Map<String, dynamic> m)
      : name = TextEditingController(text: inputText(m['name'])),
        description = TextEditingController(text: inputText(m['description'])),
        questionCount = TextEditingController(text: inputText(m['question_count'])),
        marksPerQuestion = TextEditingController(text: inputText(m['marks_per_question'])),
        rules = [for (final r in asList(m['rules'])) _RuleForm(asMap(r) ?? const {})];

  final TextEditingController name;
  final TextEditingController description;

  /// `v-model.number`
  final TextEditingController questionCount;

  /// `v-model.number`
  final TextEditingController marksPerQuestion;
  final List<_RuleForm> rules;

  Map<String, dynamic> toMap() => {
        'name': name.text,
        'description': description.text,
        'question_count': vueNumberInput(questionCount.text),
        'marks_per_question': vueNumberInput(marksPerQuestion.text),
        'rules': [for (final r in rules) r.toMap()],
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

class _ScheduleExamViewState extends ConsumerState<ScheduleExamView> {
  // ── data() ──────────────────────────────────────────────────────────────
  // (`currentScheduleId` and `selectedBatchId` are assigned but never read
  // on the web, so they are not kept.)
  List<String> _poolQuestionIds = [];
  List<dynamic> _questions = [];
  Object? _allQuestions = const [];
  List<Object?> _selectedQuestionIds = [];

  String _selectedSubjectId = '';
  String _selectedCourseId = '';

  // form
  String _locale = defaultScheduleExamLocale;
  final _duration = TextEditingController(text: '0');
  final _maxAttempts = TextEditingController(text: '1');
  final _negativeMarks = TextEditingController(text: '0');
  bool _randomizeQuestionOrder = false;
  bool _randomizeOptionsOrder = false;
  bool _enableNegativeMarking = false;

  List<_SectionForm> _sections = [
    _SectionForm({
      ...newExamSection(),
      'rules': [newExamRule()],
    }),
  ];

  // The "Schedule" and "Exam Images" cards are `class="hidden"` on the web,
  // so the image fields never change; they still feed the payload.
  static const _imageUrl = '';
  static const _imageCaption = '';

  ScheduleExamController get _ctrl => ref.read(scheduleExamControllerProvider.notifier);

  // ── computed ────────────────────────────────────────────────────────────

  /// `isEdit` — `!!this.examId`
  bool get _isEdit => jsTruthy(widget.examId);

  /// Store `sections` (`courseSections`).
  List<Map<String, dynamic>> get _courseSections =>
      [for (final s in asList(ref.read(lmsHandoffProvider)['sections'])) ?asMap(s)];

  /// Store `courses`.
  List<Map<String, dynamic>> get _courses =>
      [for (final c in asList(ref.read(lmsHandoffProvider)['courses'])) ?asMap(c)];

  /// Store `activeScheduleIdss` (falls back to the `scheduleId` prop).
  Object? get _activeScheduleId =>
      ref.read(lmsHandoffProvider)['activeScheduleIdss'] ?? widget.scheduleId;

  List<Map<String, dynamic>> _sectionMaps() => [for (final s in _sections) s.toMap()];

  // ── lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      // `watch: examId { immediate: true }` starts before `mounted()`.
      _onExamId(widget.examId);
      _mounted();
    });
  }

  @override
  void didUpdateWidget(covariant ScheduleExamView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.examId != widget.examId) _onExamId(widget.examId);
  }

  @override
  void dispose() {
    _duration.dispose();
    _maxAttempts.dispose();
    _negativeMarks.dispose();
    for (final s in _sections) {
      s.dispose();
    }
    super.dispose();
  }

  /// Disposes text controllers after the frame that removed their fields.
  void _disposeLater(VoidCallback dispose) =>
      WidgetsBinding.instance.addPostFrameCallback((_) => dispose());

  /// `mounted()`
  Future<void> _mounted() async {
    try {
      await _ctrl.fetchCourse();
    } catch (_) {
      // API errors were already toasted; the web only logged them.
    }
    if (!mounted) return;

    if (!_isEdit && jsTruthy(widget.courseId)) {
      setState(() => _selectedCourseId = jsStr(widget.courseId));
      try {
        await _ctrl.fetchCourseDetails(jsNumber(widget.courseId));
      } catch (_) {}
    }
  }

  /// `watch: examId` — loads the exam and maps it back into the form.
  Future<void> _onExamId(Object? id) async {
    if (!jsTruthy(id)) return;
    try {
      final res = asMap(await _ctrl.fetchExamById(jsStr(id)));
      if (!mounted) return;
      // The web reads `res.schedule_id` before its null check (and would
      // throw on an empty response); guarded here.
      if (res == null) return;
      setState(() {
        _duration.text = inputText(res['duration_minutes'] ?? 0);
        _maxAttempts.text = inputText(res['max_attempts'] ?? 1);
        _enableNegativeMarking = jsTruthy(res['allow_negative_marking'] ?? false);
        _negativeMarks.text = inputText(
            jsNumber(jsTruthy(res['default_negative_marks']) ? res['default_negative_marks'] : 0));
        _randomizeQuestionOrder = jsTruthy(res['randomize_question_order'] ?? false);
        _randomizeOptionsOrder = jsTruthy(res['randomize_option_order'] ?? false);
      });

      if (_courses.isEmpty) await _ctrl.fetchCourse();
      if (!mounted) return;

      final wanted = jsField(res, 'course_id');
      Map<String, dynamic>? localCourse;
      for (final c in _courses) {
        if (jsField(c, 'exam_course_id') == wanted) {
          localCourse = c;
          break;
        }
      }
      if (localCourse == null) return; // "Course not found" (console only)

      setState(() => _selectedCourseId = jsField(localCourse, 'id'));

      // load course details (chapters, topics)
      await _ctrl.fetchCourseDetails(jsNumber(localCourse['id']));
      if (!mounted) return;

      // build sections + rules from the response
      final old = _sections;
      setState(() {
        _sections = [for (final s in sectionsFromExam(res)) _SectionForm(s)];
        _poolQuestionIds = poolQuestionIdsOf(res);
      });
      _disposeLater(() {
        for (final s in old) {
          s.dispose();
        }
      });

      final firstTopicUuid = firstTopicUuidOf(res);
      if (firstTopicUuid == null) return;

      final found = locateTopic(_courseSections, firstTopicUuid);
      if (found == null) return; // "Cannot map topic -> exam_content_id/chapter"

      setState(() {
        _selectedSubjectId = found.chapterId;
        if (_sections.isNotEmpty && _sections.first.rules.isNotEmpty) {
          _sections.first.rules.first.topicId = found.examContentId;
        }
      });
      await _onTopicSelect(found.examContentId);
      if (!mounted) return;
      setState(() => _selectedQuestionIds = [..._poolQuestionIds]);
    } catch (_) {
      // Unhandled on the web (console only); API errors were toasted.
    }
  }

  // ── methods ─────────────────────────────────────────────────────────────

  /// `toggleQuestion(id)`
  void _toggleQuestion(Object? id) {
    setState(() {
      final index = _selectedQuestionIds.indexOf(id);
      if (index == -1) {
        _selectedQuestionIds.add(id);
      } else {
        _selectedQuestionIds.removeAt(index);
      }
    });
  }

  /// `onTopicSelect(topicId)`
  Future<void> _onTopicSelect(String? topicId) async {
    if (topicId == null || topicId.isEmpty) return;

    if (!_isEdit) setState(() => _selectedQuestionIds = []);

    final foundSection = sectionOfTopic(_courseSections, topicId);
    if (foundSection == null) return;

    // `exam_content_id` is passed, but the store only forwards
    // exam_section_id / exam_chapter_id / default_locale.
    final payload = <String, dynamic>{
      'institute_id': ref.read(sessionProvider).userInfo?.instituteId,
      'exam_section_id': jsField(foundSection, 'exam_section_id'),
      'exam_content_id': topicId,
    };
    try {
      final res = await _ctrl.getExamQuestions(payload);
      if (!mounted) return;
      _allQuestions = jsTruthy(res) ? res : const [];
      _applyRuleFilter();
    } catch (_) {}
  }

  /// `applyRuleFilter()`
  void _applyRuleFilter() {
    final filtered = filterQuestionsByRule(_allQuestions, _sectionMaps());
    if (filtered == null) return;
    setState(() => _questions = filtered);
  }

  /// `saveExam()`
  Future<void> _saveExam() async {
    final selectedSection = sectionOfChapter(_courseSections, _selectedSubjectId);
    // "No section found for selected chapter" — the web only logs it.
    if (selectedSection == null) return;

    final payload = buildScheduleExamPayload(
      locale: _locale,
      activeScheduleId: _activeScheduleId,
      selectedSection: selectedSection,
      durationMinutes: vueNumberInput(_duration.text),
      maxAttempts: vueNumberInput(_maxAttempts.text),
      enableNegativeMarking: _enableNegativeMarking,
      negativeMarks: vueNumberInput(_negativeMarks.text),
      randomizeQuestionOrder: _randomizeQuestionOrder,
      randomizeOptionsOrder: _randomizeOptionsOrder,
      imageUrl: _imageUrl,
      imageCaption: _imageCaption,
      sections: _sectionMaps(),
      selectedQuestionIds: _selectedQuestionIds,
    );

    try {
      if (_isEdit && jsTruthy(widget.examId)) {
        await _ctrl.updateScheduleExam(jsStr(widget.examId), payload);
        AppToast.success('quiz updated successfully');
      } else {
        await _ctrl.createScheduleExam(payload);
        AppToast.success('quiz created successfully');
      }
      widget.onCreated?.call();
      widget.onClose?.call();
    } catch (_) {
      // "Save failed" — the API client already showed the error.
    }
  }

  void _addSection() => setState(() => _sections.add(_SectionForm(newExamSection())));

  void _removeSection(int index) {
    final removed = _sections[index];
    setState(() => _sections.removeAt(index));
    _disposeLater(removed.dispose);
  }

  void _addRule(_SectionForm section) => setState(() => section.rules.add(_RuleForm(newExamRule())));

  void _removeRule(_SectionForm section, int index) {
    final removed = section.rules[index];
    setState(() => section.rules.removeAt(index));
    _disposeLater(removed.dispose);
  }

  // ── template ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    // Re-render when the store's `sections` / `courses` change.
    ref.watch(lmsHandoffProvider.select((m) => (m['sections'], m['courses'])));

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _basicInformationCard(context),
        const SizedBox(height: 16),
        _examSectionsCard(context),
        const SizedBox(height: 16),
        if (_questions.isNotEmpty) ...[
          _selectQuestionsCard(context),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(label: _isEdit ? 'Update' : 'Create', onPressed: _saveExam),
          ],
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, c) => c.hasBoundedHeight ? SingleChildScrollView(child: content) : content,
    );
  }

  static final _numberFormatters = [FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'))];
  static const _numberKeyboard = TextInputType.numberWithOptions(decimal: true, signed: true);

  Widget _numberField(TextEditingController c, String hint,
          {String? label, bool required = false, ValueChanged<String>? onChanged}) =>
      AppTextField(
        controller: c,
        label: label,
        required: required,
        hint: hint,
        keyboardType: _numberKeyboard,
        inputFormatters: _numberFormatters,
        onChanged: onChanged,
      );

  Widget _basicInformationCard(BuildContext context) {
    final chapters = firstSectionChapters(_courseSections);
    final columns = context.isLg ? 3 : (context.isSm ? 2 : 1);

    return ExamCard(
      children: [
        const ExamCardTitle('Basic Information', primary: true, bottom: 16),
        FormGrid(
          columns: columns,
          children: [
            LabeledField(
              label: 'Language',
              child: AppSelect<String>(
                value: _locale,
                placeholder: 'Select Language',
                items: [
                  for (final e in scheduleExamLocales.entries) AppSelectItem(e.value, e.key),
                ],
                onChanged: (v) => setState(() => _locale = v ?? _locale),
              ),
            ),
            LabeledField(
              label: 'Chapter',
              child: AppSelect<String>(
                value: _selectedSubjectId.isEmpty ? null : _selectedSubjectId,
                placeholder: 'Select Chapter',
                enabled: _selectedCourseId.isNotEmpty,
                items: [
                  for (final ch in chapters) AppSelectItem(jsField(ch, 'id'), vueText(ch['name'])),
                ],
                onChanged: (v) => setState(() => _selectedSubjectId = v ?? ''),
              ),
            ),
            _numberField(_duration, 'Duration (minutes)', label: 'Duration', required: true),
            _numberField(_maxAttempts, 'Max Attempts', label: 'Max Attempts'),
          ],
        ),
        const ExamCardTitle('Settings', primary: true, bottom: 16),
        Wrap(
          spacing: 24,
          runSpacing: 24,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            ExamWebToggle(
              value: _enableNegativeMarking,
              label: 'Enable Negative Marking',
              onChanged: (v) => setState(() => _enableNegativeMarking = v),
            ),
            ExamWebToggle(
              value: _randomizeQuestionOrder,
              label: 'Randomize Question Order',
              onChanged: (v) => setState(() => _randomizeQuestionOrder = v),
            ),
            ExamWebToggle(
              value: _randomizeOptionsOrder,
              label: 'Randomize Option Order',
              onChanged: (v) => setState(() => _randomizeOptionsOrder = v),
            ),
          ],
        ),
        if (_enableNegativeMarking)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _numberField(_negativeMarks, 'Enter negative marks',
                label: 'Negative Marks Per Wrong Answer'),
          ),
      ],
    );
  }

  Widget _examSectionsCard(BuildContext context) {
    return ExamCard(
      children: [
        Row(
          children: [
            const Expanded(child: ExamCardTitle('Exam Sections', primary: true, required: true)),
            AppButton(label: 'Add Section', onPressed: _addSection),
          ],
        ),
        if (_sections.isEmpty)
          const ExamEmptyNote(
              'No sections added. Add at least one section to generate questions for the exam.'),
        for (var i = 0; i < _sections.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _sectionCard(context, _sections[i], i),
          ),
      ],
    );
  }

  Widget _sectionCard(BuildContext context, _SectionForm section, int sectionIndex) {
    return ExamCard(
      children: [
        Row(
          children: [
            Expanded(child: ExamCardTitle('Section ${sectionIndex + 1}', required: true)),
            ExamTrashButton(onPressed: () => _removeSection(sectionIndex)),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: section.name,
              label: 'Section Name',
              required: true,
              hint: 'Section Name',
            ),
            const SizedBox(height: 16),
            // `<Textarea rows="4">` is `field-sizing-content min-h-16`: it
            // starts about two lines tall and grows with the text.
            AppTextField(
              controller: section.description,
              label: 'Description',
              hint: 'Description',
              maxLines: null,
              minLines: 2,
            ),
            const SizedBox(height: 16),
            FormGrid(
              columns: context.isSm ? 2 : 1,
              children: [
                _numberField(section.questionCount, 'Number of Questions',
                    label: 'Number of Questions', required: true),
                _numberField(section.marksPerQuestion, 'Marks Per Question', label: 'Marks Per Question'),
              ],
            ),
            const SizedBox(height: 16),
            // Rules section (`pt-2`)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Expanded(child: FieldLabel('Question Selection Rules')),
                  // `variant="ghost" class="gap-1 text-primary hover:bg-blue-100
                  // px-2 py-1 rounded-sm"` + `bi-plus text-lg`.
                  AppButton(
                    variant: AppButtonVariant.ghost,
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    radius: 12,
                    foregroundColor: context.colors.primary,
                    hoverForegroundColor: AppColors.accentForeground,
                    hoverBackgroundColor:
                        context.isDark ? AppColors.accent.withValues(alpha: 0.5) : Tw.blue100,
                    onPressed: () => _addRule(section),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(BootstrapIcons.plus, size: 18),
                      SizedBox(width: 4),
                      Text('Add Rule', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (section.rules.isEmpty)
              const ExamEmptyNote('No rules added. Add a rule to select questions.')
            else
              for (var i = 0; i < section.rules.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                _ruleCard(context, section, i),
              ],
          ],
        ),
      ],
    );
  }

  Widget _ruleCard(BuildContext context, _SectionForm section, int index) {
    final rule = section.rules[index];
    final topics = topicsOfChapter(_courseSections, _selectedSubjectId);

    Widget field(String label, Widget child) => Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: LabeledField(label: label, child: child),
        );

    return ExamCard(
      // `bg-gray-50` (no dark variant on the web).
      color: Tw.gray50,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Row(
            children: [
              Expanded(child: ExamCardTitle('Rule ${index + 1}')),
              ExamTrashButton(hoverColor: Tw.gray100, onPressed: () => _removeRule(section, index)),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            field(
              'Topic',
              AppSelect<String>(
                value: rule.topicId.isEmpty ? null : rule.topicId,
                placeholder: 'Select Topic',
                items: [
                  for (final t in topics)
                    AppSelectItem(jsField(t, 'exam_content_id'), vueText(t['name'])),
                ],
                onChanged: (v) {
                  setState(() => rule.topicId = v ?? '');
                  _onTopicSelect(v);
                },
              ),
            ),
            field(
              'Difficulty',
              AppSelect<String>(
                value: rule.difficulty,
                placeholder: 'Difficulty',
                items: const [
                  AppSelectItem('EASY', 'Easy'),
                  AppSelectItem('MEDIUM', 'Medium'),
                  AppSelectItem('HARD', 'Hard'),
                ],
                onChanged: (v) {
                  setState(() => rule.difficulty = v);
                  _applyRuleFilter();
                },
              ),
            ),
            field(
              'Question Type',
              AppSelect<String>(
                value: rule.questionType,
                placeholder: 'Question Type',
                items: const [AppSelectItem('MCQ', 'MCQ')],
                onChanged: (v) {
                  setState(() => rule.questionType = v);
                  _applyRuleFilter();
                },
              ),
            ),
            field(
              'Tags',
              AppTextField(
                controller: rule.tags,
                hint: 'comma,separated,tags',
                onChanged: (_) => _applyRuleFilter(),
              ),
            ),
            field(
              'Pick Count',
              _numberField(rule.pickCount, 'Pick Count', onChanged: (_) => _applyRuleFilter()),
            ),
          ],
        ),
      ],
    );
  }

  Widget _selectQuestionsCard(BuildContext context) {
    final muted = examMuted(context);
    return ExamCard(
      children: [
        const ExamCardTitle('Select Questions', primary: true, bottom: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final q in _questions)
              ExamQuestionRow(
                question: asMap(q) ?? const {},
                selected: _selectedQuestionIds.contains(asMap(q)?['id']),
                onTap: () => _toggleQuestion(asMap(q)?['id']),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text(
            'Selected ${_selectedQuestionIds.length} / ${_questions.length} questions',
            style: TextStyle(fontSize: 14, color: muted),
          ),
        ),
      ],
    );
  }
}
