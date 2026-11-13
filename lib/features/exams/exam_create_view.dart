import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/files.dart';
import '../../core/utils/toast.dart';
import '../../widgets/app_button.dart';
import '../../widgets/form_fields.dart';
import 'exam_widgets.dart';
import 'exams_controller.dart';
import 'exams_logic.dart';

part 'exam_create_sections.dart';

/// Port of `src/pages/exams/examcreate.vue` — the create-exam form embedded
/// by `exam.vue` (`/exams`) and `newexams.vue` (`/newexams`).
///
/// `$emit('exam-created')` → [onExamCreated] (also fired by Cancel, like the
/// web's `backtoList`). The view does not scroll on its own; the parent page
/// scrolls.
class ExamCreateView extends ConsumerStatefulWidget {
  const ExamCreateView({super.key, this.onExamCreated, this.cardSpacing = 16});

  /// `@exam-created`
  final VoidCallback? onExamCreated;

  /// Space between the form's cards: `mb-4` (16), plus the parent card's
  /// `gap-6` when embedded in `exam.vue`'s flex column (40).
  final double cardSpacing;

  @override
  ConsumerState<ExamCreateView> createState() => _ExamCreateViewState();
}

/// One `rules[]` entry (`{ topic_id, difficulty, question_type, tags,
/// pick_count }`; `tags` is never bound in the template).
class _RuleDraft {
  String topicId = '';
  String difficulty = '';
  String questionType = '';

  /// `v-model.number="rule.pick_count"` (starts at 0).
  final pickCount = TextEditingController(text: '0');

  ExamRuleInput toInput() => ExamRuleInput(
        topicId: topicId,
        difficulty: difficulty,
        questionType: questionType,
        pickCount: looseToNumber(htmlNumberValue(pickCount.text)),
      );

  void dispose() => pickCount.dispose();
}

/// One `sections[]` entry.
class _SectionDraft {
  _SectionDraft({bool withRule = false}) {
    if (withRule) rules.add(_RuleDraft());
  }

  final name = TextEditingController();
  final description = TextEditingController();

  /// `v-model.number` fields (start at 0 / 1).
  final questionCount = TextEditingController(text: '0');
  final marksPerQuestion = TextEditingController(text: '1');
  final rules = <_RuleDraft>[];

  ExamSectionInput toInput() => ExamSectionInput(
        name: name.text,
        description: description.text,
        questionCount: looseToNumber(htmlNumberValue(questionCount.text)),
        marksPerQuestion: looseToNumber(htmlNumberValue(marksPerQuestion.text)),
        rules: [for (final r in rules) r.toInput()],
      );

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

/// `<input type="number">`: digits, sign, decimal point and exponent.
final _numberInput = FilteringTextInputFormatter.allow(RegExp(r'[0-9eE.+\-]'));
const _numberKeyboard = TextInputType.numberWithOptions(decimal: true, signed: true);

class _ExamCreateViewState extends ConsumerState<ExamCreateView> {
  // ── data() ──
  bool _loading = false;
  String _selectedClassId = '';
  String _selectedBatchId = '';
  String _selectedCourseId = '';

  /// `selectedSubjectId` — the chosen chapter's `id`.
  Object? _selectedSubjectId;

  // form
  String _defaultLocale = defaultExamLocale;
  final _name = TextEditingController();
  final _code = TextEditingController();
  final _description = TextEditingController();
  String _examType = '';
  final _durationMinutes = TextEditingController(text: '0');
  bool _randomizeQuestionOrder = false;
  bool _randomizeOptionOrder = false;
  final _negativeMarks = TextEditingController(text: '0');
  bool _enableNegativeMarking = false;
  final _maxAttempts = TextEditingController(text: '1');
  bool _showImmediateFeedback = false;

  final _sections = <_SectionDraft>[_SectionDraft(withRule: true)];

  final _imageUrl = TextEditingController();
  String _lastImageUrl = '';
  String _imagePreview = '';
  final _imageOrder = TextEditingController(text: '1');
  String? _pickedImageName;

  // Schedule card (shown, but never sent: the payload is always "open anytime").
  bool _openAnytimeUi = false;
  String _startDate = '';
  String _endDate = '';
  String _startAt = '';
  String _endAt = '';

  ExamsController get _ctrl => ref.read(examsControllerProvider.notifier);

  /// `setState` for the part-file extensions.
  void _set(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  /// Disposes controllers of removed sections / rules once the rebuild that
  /// drops their fields is done.
  void _disposeLater(VoidCallback dispose) => WidgetsBinding.instance.addPostFrameCallback((_) => dispose());

  @override
  void initState() {
    super.initState();
    _imageUrl.addListener(_onImageUrlChanged);
    Future.microtask(_mounted);
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _description.dispose();
    _durationMinutes.dispose();
    _negativeMarks.dispose();
    _maxAttempts.dispose();
    for (final s in _sections) {
      s.dispose();
    }
    _imageUrl.dispose();
    _imageOrder.dispose();
    super.dispose();
  }

  /// `mounted()` — the web loads the courses twice (kept).
  Future<void> _mounted() async {
    try {
      await _ctrl.fetchCourse();
      await Future.wait([_ctrl.fetchCourse(), _ctrl.getClasses()]);
    } catch (_) {
      // Unhandled on the web; the API client already showed the error.
    }
  }

  // ── watchers ──

  /// `watch: imageUrl` — any non-empty value becomes the preview.
  void _onImageUrlChanged() {
    final v = _imageUrl.text;
    if (v == _lastImageUrl) return;
    _lastImageUrl = v;
    if (v.isNotEmpty && mounted) setState(() => _imagePreview = v);
  }

  /// `watch: selectedClassId`
  Future<void> _onClassChanged(String? value) async {
    final v = value ?? '';
    if (v == _selectedClassId) return;
    setState(() {
      _selectedClassId = v;
      _selectedBatchId = '';
    });
    if (v.isEmpty) return;
    try {
      await _ctrl.getBatches(jsonNum(jsNum(v)));
    } catch (_) {}
  }

  /// `watch: selectedCourseId` — resets the chapter and the sections, then
  /// loads the course's sections → chapters → contents.
  Future<void> _onCourseChanged(String? value) async {
    final v = value ?? '';
    if (v == _selectedCourseId) return;
    setState(() {
      _selectedCourseId = v;
      _selectedSubjectId = null;
      for (final s in _sections) {
        _disposeLater(s.dispose);
      }
      _sections
        ..clear()
        ..add(_SectionDraft(withRule: true));
    });
    if (v.isEmpty) return;
    Json? course;
    for (final c in examMaps(ref.read(examsControllerProvider).courses)) {
      if (jsStr(c['exam_course_id']) == v) {
        course = c;
        break;
      }
    }
    if (course == null) return;
    try {
      await _ctrl.fetchCourseDetails(course['id']);
    } catch (_) {}
  }

  // ── methods ──

  Future<void> _saveExam() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final selectedSection = sectionForChapter(ref.read(examsControllerProvider).sections, _selectedSubjectId);
      final payload = buildCreateExamPayload(
        selectedCourseId: _selectedCourseId,
        selectedSection: selectedSection,
        selectedBatchId: _selectedBatchId,
        name: _name.text,
        code: _code.text,
        description: _description.text,
        examType: _examType,
        durationMinutes: htmlNumberValue(_durationMinutes.text),
        randomizeQuestionOrder: _randomizeQuestionOrder,
        randomizeOptionOrder: _randomizeOptionOrder,
        showImmediateFeedback: _showImmediateFeedback,
        enableNegativeMarking: _enableNegativeMarking,
        negativeMarks: htmlNumberValue(_negativeMarks.text),
        locale: _defaultLocale,
        imageUrl: _imageUrl.text,
        imageOrder: looseToNumber(htmlNumberValue(_imageOrder.text)),
        maxAttempts: looseToNumber(htmlNumberValue(_maxAttempts.text)),
        sections: [for (final s in _sections) s.toInput()],
      );
      await _ctrl.createExam(payload);
      AppToast.success('Exam created successfully ');
      widget.onExamCreated?.call();
    } catch (_) {
      // console.error on the web; API errors were already toasted.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// `onImageUpload` — uploads right away and uses the returned URL.
  Future<void> _onImageUpload() async {
    final file = await pickImageFile();
    if (file == null || !mounted) return;
    setState(() => _pickedImageName = file.name);
    dynamic res;
    try {
      res = await _ctrl.uploadExamFile(file);
    } catch (_) {
      return;
    }
    if (!mounted) return;
    final url = uploadedImageUrl(res) ?? '';
    _imageUrl.text = url;
    setState(() => _imagePreview = url);
  }

  void _removeImage() {
    setState(() => _imagePreview = '');
    _imageUrl.text = '';
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(examsControllerProvider);
    final cards = <Widget>[
      _basicInfoCard(),
      _settingsCard(),
      _associationCard(s),
      _scheduleCard(),
      _sectionsCard(s),
      _imagesCard(),
      _buttons(),
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) SizedBox(height: widget.cardSpacing),
          cards[i],
        ],
      ],
    );
  }

  // ── shared bits ──

  /// `<CardTitle>` (`leading-none font-semibold`, an `h3`), optionally
  /// `text-primary` and with the red `after:content-['*'] after:ml-1`.
  Widget _cardTitle(String text, {bool primary = false, bool required = false}) => Text.rich(
        TextSpan(text: text, children: [
          if (required) ...[
            const WidgetSpan(child: SizedBox(width: 4)),
            const TextSpan(text: '*', style: TextStyle(color: Tw.red500)),
          ],
        ]),
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1,
          color: primary ? context.colors.primary : context.exFg,
        ),
      );

  /// `<Label class="mb-2">` (or a `space-y-2` cell's `<Label>`) + control;
  /// [block] for `<Label class="block …">`.
  Widget _field(String label, Widget child, {bool required = false, double gap = 8, bool block = false}) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ExamFieldLabel(label, required: required, block: block),
          SizedBox(height: gap),
          child,
        ],
      );

  /// `bg-white` on a trigger / input (dark mode keeps the kit's
  /// `dark:bg-input/30`, which is more specific).
  Color? get _bgWhite => context.isDark ? null : Colors.white;

  Widget _numberField(TextEditingController c, String hint, {bool white = false}) => AppTextField(
        controller: c,
        hint: hint,
        keyboardType: _numberKeyboard,
        inputFormatters: [_numberInput],
        fillColor: white ? _bgWhite : null,
      );

  /// `<Textarea>`: `field-sizing-content min-h-16` (the `rows` attribute
  /// has no effect), so it starts 64px tall and grows with the text.
  Widget _textarea(TextEditingController c, String hint) => AppTextField(controller: c, hint: hint, maxLines: null);

  /// `<Select>` whose trigger is `w-full bg-white`.
  Widget _select<T>({
    required T? value,
    required String placeholder,
    required List<AppSelectItem<T>> items,
    required ValueChanged<T?> onChanged,
    bool enabled = true,
  }) =>
      AppSelect<T>(
        value: value,
        placeholder: placeholder,
        items: items,
        onChanged: onChanged,
        enabled: enabled,
        fillColor: _bgWhite,
      );

  /// `grid gap-4` with [columns] columns.
  Widget _grid(List<Widget> children, int columns, {double gap = 16}) {
    if (columns <= 1) return GapColumn(gap: gap, children: children);
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += columns) {
      rows.add(Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var j = 0; j < columns; j++) ...[
            if (j > 0) SizedBox(width: gap),
            Expanded(child: i + j < children.length ? children[i + j] : const SizedBox.shrink()),
          ],
        ],
      ));
    }
    return GapColumn(gap: gap, children: rows);
  }

  ExamCard _card(List<Widget> children) => ExamCard(
        padding: const EdgeInsets.all(16),
        child: GapColumn(children: children),
      );

  // ── Basic Information ──

  Widget _basicInfoCard() => _card([
        _cardTitle('Basic Information', primary: true),
        _field(
          'Language',
          _select<String>(
            value: _defaultLocale,
            placeholder: 'Select Language',
            items: [for (final (key, value) in localeOptions) AppSelectItem(value, key)],
            onChanged: (v) => setState(() => _defaultLocale = v ?? _defaultLocale),
          ),
        ),
        _field('Exam Name', AppTextField(controller: _name, hint: 'Exam Name'), required: true),
        _field('Exam Code', AppTextField(controller: _code, hint: 'Exam Code'), required: true),
        // A native `<label class="text-sm font-medium">` (no margin).
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ExamNativeLabel('Description'),
            _textarea(_description, 'Enter Description text'),
          ],
        ),
        _field(
          'Select Exam Type',
          _select<String>(
            value: _examType.isEmpty ? null : _examType,
            placeholder: 'Select Exam Type',
            items: const [AppSelectItem('EXAM', 'Exam')],
            onChanged: (v) => setState(() => _examType = v ?? ''),
          ),
          required: true,
        ),
        _field('Duration', _numberField(_durationMinutes, 'Duration (minutes)'), required: true),
        _field('Max Attempts', _numberField(_maxAttempts, 'Max Attempts')),
      ]);

  // ── Settings ──

  /// `flex items-center gap-3`: the toggle's `<label>` and a `<span>`.
  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          WebToggle(value: value, onChanged: onChanged),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 16, height: 1.5)),
        ],
      );

  Widget _settingsCard() => _card([
        Padding(padding: const EdgeInsets.only(bottom: 16), child: _cardTitle('Settings', primary: true)),
        Wrap(
          spacing: 32,
          runSpacing: 32,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _toggle('Negative Marking', _enableNegativeMarking, (v) => setState(() => _enableNegativeMarking = v)),
            if (_enableNegativeMarking) SizedBox(width: 160, child: _numberField(_negativeMarks, 'Marks', white: true)),
            _toggle('Randomize Questions', _randomizeQuestionOrder, (v) => setState(() => _randomizeQuestionOrder = v)),
            _toggle('Randomize Options', _randomizeOptionOrder, (v) => setState(() => _randomizeOptionOrder = v)),
            _toggle('Immediate Feedback', _showImmediateFeedback, (v) => setState(() => _showImmediateFeedback = v)),
          ],
        ),
      ]);

  // ── Association ──

  Widget _associationCard(ExamsState s) {
    final chaptersList = chaptersOf(s.sections);
    final courses = examMaps(s.courses);
    return _card([
      _cardTitle('Association', primary: true),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _field(
          'Class',
          _select<String>(
            value: _selectedClassId.isEmpty ? null : _selectedClassId,
            placeholder: 'Select Class',
            items: [for (final cls in s.institutes) AppSelectItem(jsStr(cls['id']), display(cls['year']))],
            onChanged: _onClassChanged,
          ),
          required: true,
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _field(
          'Batch',
          _select<String>(
            value: _selectedBatchId.isEmpty ? null : _selectedBatchId,
            placeholder: 'Select Batch',
            enabled: _selectedClassId.isNotEmpty,
            items: [for (final b in s.batches) AppSelectItem(jsStr(b['exam_batch_id']), display(b['name']))],
            onChanged: (v) => setState(() => _selectedBatchId = v ?? ''),
          ),
          required: true,
        ),
      ),
      // `class="required"` has no CSS behind it → no asterisk.
      _field(
        'Course / Subject',
        _select<String>(
          value: _selectedCourseId.isEmpty ? null : _selectedCourseId,
          placeholder: 'Select Course',
          items: [for (final c in courses) AppSelectItem(jsStr(c['exam_course_id']), display(c['title']))],
          onChanged: _onCourseChanged,
        ),
      ),
      _field(
        'Chapter',
        _select<Object>(
          value: _selectedSubjectId,
          placeholder: 'Select Chapter',
          enabled: _selectedCourseId.isNotEmpty,
          items: [
            for (final ch in chaptersList)
              if (ch['id'] != null) AppSelectItem<Object>(ch['id'] as Object, display(ch['name'])),
          ],
          onChanged: (v) => setState(() => _selectedSubjectId = v),
        ),
      ),
    ]);
  }

  // ── Schedule ──

  Future<void> _pickDate(String current, ValueChanged<String> set) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(current) ?? now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 50),
    );
    if (picked == null || !mounted) return;
    String two(int n) => n.toString().padLeft(2, '0');
    setState(() => set('${picked.year.toString().padLeft(4, '0')}-${two(picked.month)}-${two(picked.day)}'));
  }

  Future<void> _pickTime(String current, ValueChanged<String> set) async {
    final parts = current.split(':');
    final initial = parts.length == 2
        ? TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0)
        : TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null || !mounted) return;
    String two(int n) => n.toString().padLeft(2, '0');
    setState(() => set('${two(picked.hour)}:${two(picked.minute)}'));
  }

  /// `<Button variant="outline" class="w-full justify-start text-left font-normal">`
  Widget _dateButton(String text, VoidCallback onTap) => ExamDateButton(text: text, onPressed: onTap);

  Widget _timeField(String value, ValueChanged<String> set) {
    final parts = value.split(':');
    final text = parts.length == 2
        ? TimeOfDay(hour: int.tryParse(parts[0]) ?? 0, minute: int.tryParse(parts[1]) ?? 0).format(context)
        : '';
    return AppTextField(
      key: ValueKey(value),
      initialValue: text,
      hint: '--:-- --',
      readOnly: true,
      suffix: const Icon(BootstrapIcons.clock, size: 14),
      onTap: () => _pickTime(value, set),
    );
  }

  Widget _scheduleCard() {
    final cols = context.isLg ? 2 : 1;
    return _card([
      Padding(padding: const EdgeInsets.only(bottom: 16), child: _cardTitle('Schedule', primary: true)),
      // `<label class="relative inline-flex items-center cursor-pointer gap-3">`
      // (`mb-6`): the track (`duration-300`) and a `<FormLabel>`.
      Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => setState(() => _openAnytimeUi = !_openAnytimeUi),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  WebToggle(
                    value: _openAnytimeUi,
                    duration: 300,
                    onChanged: (v) => setState(() => _openAnytimeUi = v),
                  ),
                  const SizedBox(width: 12),
                  const Flexible(
                    child: Text(
                      'Open Anytime (Students can take this exam anytime without time restrictions)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: _grid([
          _field(
            'Start Date',
            _dateButton(_startDate.isNotEmpty ? _startDate : 'Pick a start date',
                () => _pickDate(_startDate, (v) => _startDate = v)),
            required: true,
          ),
          _field('Start Time', _timeField(_startAt, (v) => _startAt = v), gap: 0),
        ], cols),
      ),
      _grid([
        _field(
          'End Date',
          _dateButton(_endDate.isNotEmpty ? _endDate : 'Pick an end date', () => _pickDate(_endDate, (v) => _endDate = v)),
          required: true,
        ),
        _field('End Time', _timeField(_endAt, (v) => _endAt = v), gap: 0),
      ], cols),
    ]);
  }
}
