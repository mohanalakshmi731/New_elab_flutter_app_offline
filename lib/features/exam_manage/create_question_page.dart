import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/files.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/web_content_view.dart';
import '../common/lms_handoff.dart';
import 'exam_manage_controller.dart';
import 'exam_manage_logic.dart';
import 'exam_manage_widgets.dart';

part 'create_question_cards.dart';

/// Port of `src/pages/exams/createquestion.vue` — creates a question-bank
/// question (`/exams/createexam`, no [id]) or edits one
/// (`/exams/question/edit/:id`, [id] = the route param / Vue prop `id`).
///
/// Reads the store `courses` and `sections` through [lmsHandoffProvider]
/// (`chapters` / `contents` are derived from `sections`, as
/// `fetchCourseDetails` did).
class CreateQuestionPage extends ConsumerStatefulWidget {
  const CreateQuestionPage({super.key, this.id});

  /// The question id (edit mode when non-empty).
  final String? id;

  @override
  ConsumerState<CreateQuestionPage> createState() => _CreateQuestionPageState();
}

/// One entry of `form.options` (`{ label, text, correct, image, preview }`).
class _OptionForm {
  _OptionForm({required this.label, String text = '', this.correct = false, String image = '', this.preview = ''})
      : text = TextEditingController(text: text),
        image = TextEditingController(text: image);

  /// Shown in the disabled "Option Label" input.
  Object? label;
  final TextEditingController text;

  /// The read-only "Image URL" input (`opt.image`).
  final TextEditingController image;

  /// `opt.correct` — the raw API value until the switch is toggled.
  Object? correct;
  String preview;

  void dispose() {
    text.dispose();
    image.dispose();
  }
}

/// One entry of `form.images` (`{ url, caption, preview, order_index }`).
class _ImageForm {
  _ImageForm({String url = '', String caption = '', this.preview = '', required this.orderIndex})
      : url = TextEditingController(text: url),
        caption = TextEditingController(text: caption),
        orderText = TextEditingController(text: inputText(orderIndex));

  /// The read-only "Image URL" input (`img.url`).
  final TextEditingController url;
  final TextEditingController caption;
  final TextEditingController orderText;
  String preview;

  /// What `v-model` on the `type="number"` "Display Order" input holds.
  Object? orderIndex;

  void dispose() {
    url.dispose();
    caption.dispose();
    orderText.dispose();
  }
}

class _CreateQuestionPageState extends ConsumerState<CreateQuestionPage> {
  // ── data() ──────────────────────────────────────────────────────────────
  bool _loading = false;
  bool _hasLoadedEditQuestion = false;
  String _selectedCourseId = '';
  String _selectedChapterId = '';
  String _selectedContentId = '';
  final _tagsInput = TextEditingController();
  final _tagsFocus = FocusNode();
  String _defaultLocale = defaultExamLocale;

  // form
  final _code = TextEditingController();
  String _questionType = 'MCQ';
  final _stem = TextEditingController();
  String _difficulty = '';
  final _marks = TextEditingController(text: '1');
  Object? _marksValue = 1;
  final _negativeMarks = TextEditingController(text: '0.25');
  Object? _negativeMarksValue = 0.25;
  final _explanation = TextEditingController();
  Object? _isActive = true;
  final List<_OptionForm> _options = [_OptionForm(label: 'A'), _OptionForm(label: 'B')];
  final List<_ImageForm> _images = [];
  final _videoUrl = TextEditingController();
  List<String> _tags = [];

  ExamManageController get _ctrl => ref.read(examManageControllerProvider.notifier);
  Map<String, dynamic> get _handoff => ref.read(lmsHandoffProvider);

  /// `isEdit`
  bool get _isEdit => jsTruthy(widget.id);

  @override
  void initState() {
    super.initState();
    // `@blur="updateTags"`
    _tagsFocus.addListener(() {
      if (!_tagsFocus.hasFocus) _updateTags();
    });
    // `videoEmbedUrl` is computed from `form.video_url`.
    _videoUrl.addListener(_rebuild);
    // `watch: courses` — the store's course list was replaced.
    ref.listenManual(lmsHandoffProvider.select((m) => m['courses']), (_, next) => _onCoursesChanged(next));
    Future.microtask(_mounted);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  /// `setState` for the card builders in the part file.
  void _set(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void dispose() {
    for (final c in [_tagsInput, _code, _stem, _marks, _negativeMarks, _explanation, _videoUrl]) {
      c.dispose();
    }
    _tagsFocus.dispose();
    for (final o in _options) {
      o.dispose();
    }
    for (final i in _images) {
      i.dispose();
    }
    super.dispose();
  }

  /// `mounted()` — instructors only get their own courses.
  Future<void> _mounted() async {
    try {
      if (ref.read(sessionProvider).role == Role.instructor) {
        await _ctrl.fetchCourse(1);
      } else {
        await _ctrl.fetchCourse();
      }
    } catch (_) {
      // Already toasted by the API client; the web left the rejection unhandled.
    }
  }

  /// `watch: courses(newCourses)` — loads the question once, in edit mode.
  void _onCoursesChanged(Object? newCourses) {
    if (!_isEdit) return;
    if (asList(newCourses).isEmpty) return;
    if (_hasLoadedEditQuestion) return;
    _hasLoadedEditQuestion = true;
    _loadQuestionForEdit();
  }

  /// `v-model="selectedCourseId"` + `watch: selectedCourseId` (runs only when
  /// the value changes).
  void _setSelectedCourseId(String value) {
    if (value == _selectedCourseId) return;
    setState(() => _selectedCourseId = value);
    if (value.isEmpty) return;
    _ctrl.fetchCourseDetails(jsNumber(value)).catchError((Object _) => null);
  }

  // ── methods ─────────────────────────────────────────────────────────────

  /// `alert(message)`
  Future<void> _alert(String message) => showAppDialog<void>(
        context,
        builder: (ctx) => AppDialogFrame(
          maxWidth: 420,
          description: message,
          actions: [AppButton(label: 'OK', onPressed: () => Navigator.of(ctx).pop())],
        ),
      );

  /// `loadQuestionForEdit()` — finds the question in the full question list,
  /// fills the form, then selects its course → chapter → content.
  Future<void> _loadQuestionForEdit() async {
    final dynamic res;
    try {
      res = await _ctrl.getExamQuestions(const {});
    } catch (_) {
      return;
    }
    if (!mounted) return;
    final questions = asMap(res)?['data'] ?? res ?? const [];
    // `questions.find` throws on the web when the body is not an array.
    if (questions is! List) return;
    Json? q;
    for (final item in questions) {
      if (jsField(item, 'id') == jsStr(widget.id)) {
        q = asMap(item) ?? <String, dynamic>{};
        break;
      }
    }
    if (q == null) {
      await _alert('Question not found');
      return;
    }

    // BASIC FORM
    final f = questionFormFrom(q);
    setState(() {
      _code.text = f.code;
      _questionType = f.questionType;
      _stem.text = f.stem;
      _marksValue = f.marks;
      _marks.text = inputText(f.marks);
      _negativeMarksValue = f.negativeMarks;
      _negativeMarks.text = inputText(f.negativeMarks);
      _explanation.text = f.explanation;
      _isActive = f.isActive;
      _difficulty = f.difficulty;
      _videoUrl.text = f.videoUrl;
      _tags = f.tags;
      _tagsInput.text = f.tagsInput;
      _defaultLocale = f.defaultLocale;
    });

    // STEP 1 — the course whose `exam_course_id` is the question's course.
    final matchedCourse = courseByExamKey(mapsOf(_handoff['courses']), questionExamCourseKey(q));
    if (matchedCourse == null) return; // console.warn('Course mapping failed')

    // The direct call starts first, then the `selectedCourseId` watcher's.
    final details = _ctrl.fetchCourseDetails(jsNumber(matchedCourse['id']));
    _setSelectedCourseId(jsField(matchedCourse, 'id'));
    try {
      await details;
    } catch (_) {
      return;
    }
    if (!mounted) return;

    final located = locateQuestionTopic(mapsOf(_handoff['sections']), q);

    // OPTIONS
    final rawOptions = q['options'];
    final options = rawOptions is List && rawOptions.isNotEmpty
        ? [
            for (final opt in sortedByOrderIndex(mapsOf(rawOptions)))
              () {
                final fixed = convertDriveUrl(jsTruthy(opt['image_url']) ? jsStr(opt['image_url']) : '');
                return _OptionForm(
                  label: opt['option_label'],
                  text: jsTruthy(opt['option_text']) ? jsStr(opt['option_text']) : '',
                  correct: opt['is_correct'],
                  image: fixed,
                  preview: fixed,
                );
              }(),
          ]
        : null;

    // IMAGES
    final rawImages = asList(q['images']);
    final images = [
      for (var i = 0; i < rawImages.length; i++)
        () {
          final img = asMap(rawImages[i]) ?? const <String, dynamic>{};
          final fixedUrl = convertDriveUrl(jsTruthy(img['image_url']) ? jsStr(img['image_url']) : '');
          return _ImageForm(
            url: fixedUrl,
            preview: fixedUrl,
            caption: img['caption'] == null ? '' : jsStr(img['caption']),
            orderIndex: img['order_index'] ?? i + 1,
          );
        }(),
    ];

    setState(() {
      if (located != null) {
        _selectedChapterId = located.chapterId;
        _selectedContentId = located.contentId;
      }
      if (options != null) {
        for (final o in _options) {
          o.dispose();
        }
        _options
          ..clear()
          ..addAll(options);
      }
      for (final i in _images) {
        i.dispose();
      }
      _images
        ..clear()
        ..addAll(images);
    });
  }

  /// `saveQuestion()`
  Future<void> _saveQuestion() async {
    // Clicking the button blurs the tags input first on the web.
    if (_tagsFocus.hasFocus) {
      _updateTags();
      _tagsFocus.unfocus();
    }
    setState(() => _loading = true);
    try {
      final sections = mapsOf(_handoff['sections']);
      final courses = mapsOf(_handoff['courses']);
      final payload = buildQuestionPayload(
        code: _code.text,
        stem: _stem.text,
        questionType: _questionType,
        examSectionId: examSectionIdFor(sections, _selectedChapterId),
        difficulty: _difficulty,
        marks: _marksValue,
        negativeMarks: _negativeMarksValue,
        explanation: _explanation.text,
        isActive: _isActive,
        selectedContentId: _selectedContentId,
        selectedCourseExamId: selectedCourseExamId(courses, _selectedCourseId),
        videoUrl: _videoUrl.text,
        options: [
          for (final o in _options) (label: o.label, text: o.text.text, correct: o.correct, image: o.image.text),
        ],
        images: [
          for (final i in _images) (url: i.url.text, caption: i.caption.text, orderIndex: i.orderIndex),
        ],
        tags: _tags,
        defaultLocale: _defaultLocale,
      );

      if (_isEdit) {
        await _ctrl.updateExamQuestion(widget.id!, payload);
        AppToast.success('Question updated successfully!',
            background: const Color(0xFF16A34A));
      } else {
        await _ctrl.createExamQuestion(payload);
        AppToast.success('Question created successfully!',
            background: const Color(0xFF16A34A));
      }
      _goBack();
    } catch (_) {
      // The API client already showed the error.
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// `triggerOptionFile(index)` + `onOptionFileChange` — uploads the image
  /// and stores its URL (errors are only logged on the web).
  Future<void> _chooseOptionImage(int index) async {
    final file = await pickImageFile();
    if (file == null) return;
    try {
      final url = uploadedFileUrl(await _ctrl.uploadExamFile(file)) ?? '';
      if (!mounted || index >= _options.length) return;
      setState(() {
        _options[index].preview = url;
        _options[index].image.text = url;
      });
    } catch (_) {}
  }

  /// `removeOptionImage(index)` — only hides the preview; the URL is kept
  /// (and still saved), as on the web.
  void _removeOptionImage(int index) => setState(() => _options[index].preview = '');

  /// `triggerQuestionImageFile(index)` + `onQuestionImageChange`.
  Future<void> _chooseQuestionImage(int index) async {
    final file = await pickImageFile();
    if (file == null) return;
    try {
      final url = uploadedFileUrl(await _ctrl.uploadExamFile(file)) ?? '';
      if (!mounted || index >= _images.length) return;
      setState(() {
        _images[index].preview = url;
        _images[index].url.text = url;
      });
    } catch (_) {}
  }

  /// `removeQuestionImage(index)` — only clears `preview`; the preview box
  /// still shows `img.url`, as on the web.
  void _removeQuestionImage(int index) => setState(() => _images[index].preview = '');

  /// `addOption()`
  void _addOption() => setState(() => _options.add(_OptionForm(label: optionLabel(_options.length))));

  /// `removeOption(index)` — relabels A, B, C…
  void _removeOption(int index) {
    setState(() {
      _options.removeAt(index).dispose();
      for (var i = 0; i < _options.length; i++) {
        _options[i].label = optionLabel(i);
      }
    });
  }

  /// `addImage()`
  void _addImage() => setState(() => _images.add(_ImageForm(orderIndex: _images.length + 1)));

  /// `updateTags()`
  void _updateTags() => _tags = parseTags(_tagsInput.text);

  /// `goBack()`
  void _goBack() {
    if (mounted) context.go('/questions');
  }

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(lmsHandoffProvider.select((m) => (m['courses'], m['sections'])));
    final courses = mapsOf(store.$1);
    final sections = mapsOf(store.$2);
    final chapters = [for (final s in sections) ...mapsOf(s['chapters'])];
    final contents = [for (final c in chapters) ...mapsOf(c['contents'])];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  _isEdit ? 'Edit Question' : 'Create Question',
                  style: TextStyle(
                    fontSize: 24,
                    height: 32 / 24,
                    fontWeight: FontWeight.w600,
                    color: context.colors.primary,
                  ),
                ),
              ),
              AppButton(label: 'Questions List', onPressed: _goBack),
            ],
          ),
          const SizedBox(height: 24),
          _basicInformationCard(),
          const SizedBox(height: 24),
          _associationCard(courses, chapters, contents),
          const SizedBox(height: 24),
          if (_questionType == 'MCQ') ...[
            _optionsCard(),
            const SizedBox(height: 24),
          ],
          _imagesCard(),
          const SizedBox(height: 24),
          _videoCard(),
          const SizedBox(height: 24),
          _tagsCard(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppButton(label: 'Cancel', variant: AppButtonVariant.outline, onPressed: _goBack),
              const SizedBox(width: 12),
              AppButton(
                label: _isEdit ? 'Update Question' : 'Create Question',
                loading: _loading,
                loadingLabel: _isEdit ? 'Updating...' : 'Creating...',
                onPressed: _saveQuestion,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
