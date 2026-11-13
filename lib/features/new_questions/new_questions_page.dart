import 'dart:convert';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/files.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/web_content_view.dart';
import '../questions/questions_controller.dart';
import '../questions/questions_logic.dart';
import '../questions/questions_widgets.dart';
import '../users/users_widgets.dart' show FormGrid;
import 'new_questions_widgets.dart';

part 'new_questions_view.dart';
part 'new_questions_form.dart';
part 'new_questions_dialogs.dart';

/// Port of `src/components/new_ui_student_teacher_for_both_labs/newquestions.vue`
/// (`/newquestions`): the "new UI" question bank — Course → Chapter → Content
/// filters, the question table, and dialogs for create / edit (in place, no
/// navigation), preview, delete, CSV/XLSX import and its report.
///
/// No route params.
class NewQuestionsPage extends ConsumerStatefulWidget {
  const NewQuestionsPage({super.key});

  @override
  ConsumerState<NewQuestionsPage> createState() => _NewQuestionsPageState();
}

class _NewQuestionsPageState extends ConsumerState<NewQuestionsPage> {
  // ── list / filter state ───────────────────────────────────────────────
  String _selectedCourseId = '';
  String _selectedChapterId = '';
  String _selectedContentId = '';
  List<Map<String, dynamic>> _questions = [];
  // `currentExamSectionId` / `currentExamChapterId` were set by
  // loadQuestions() but never read on this page, so they are not kept.

  // ── question form dialog ──────────────────────────────────────────────
  bool _questionFormDialog = false;
  String? _editingQuestionId;
  bool _qFormLoading = false;
  String _qFormCourseId = '';
  String _qFormChapterId = '';
  String _qFormContentId = '';
  _QForm _qForm = _QForm();

  /// Controllers of replaced forms / removed rows: a closing dialog may still
  /// be using them, so they are disposed with the page.
  final _disposeLater = <VoidCallback>[];

  /// `@blur="updateQFormTags"` on the tags input.
  final _tagsFocus = FocusNode();

  // ── preview ───────────────────────────────────────────────────────────
  PreviewQuestion? _previewQuestion;
  String _activeMedia = 'image';

  // ── delete ────────────────────────────────────────────────────────────
  bool _deleteDialog = false;
  Map<String, dynamic>? _questionToDelete;
  bool _deleting = false;

  // ── import ────────────────────────────────────────────────────────────
  bool _showImportDialog = false;
  String _importCourseId = '';
  String _importChapterId = '';
  String _importContentId = '';
  UploadFile? _importFile;
  bool _importing = false;
  bool _importResultDialog = false;
  Object? _importResult;

  /// Rebuilds open dialogs when page state they show changes.
  final _tick = ValueNotifier<int>(0);

  QuestionsController get _ctrl => ref.read(questionsControllerProvider.notifier);
  QuestionsState get _store => ref.read(questionsControllerProvider);
  String get _role => ref.read(sessionProvider).role;

  /// `this.language.name.toLowerCase().slice(0, 2)`
  String get _languageLocale => localeFromLanguageName(ref.read(sessionProvider).language.name);

  void _set(VoidCallback fn) {
    if (!mounted) {
      fn();
      return;
    }
    setState(fn);
    _tick.value++;
  }

  @override
  void initState() {
    super.initState();
    _tagsFocus.addListener(() {
      if (!_tagsFocus.hasFocus) _updateQFormTags();
    });
    Future.microtask(_mounted);
  }

  @override
  void dispose() {
    _tick.dispose();
    _tagsFocus.dispose();
    _qForm.dispose();
    for (final d in _disposeLater) {
      d();
    }
    super.dispose();
  }

  /// `mounted()`
  void _mounted() {
    if (!mounted) return;
    _ignore(_role == 'instructor' ? _ctrl.fetchCourse(1) : _ctrl.fetchCourse());
    _loadAllQuestionsOnPageLoad();
  }

  /// Fire-and-forget like the web's un-awaited store calls (API errors were
  /// already toasted by the API client).
  void _ignore(Future<void> f) => f.catchError((Object _) {});

  /// `Number(id)`
  static Object _numberish(String id) => int.tryParse(id) ?? num.tryParse(id) ?? id;

  // ── computed ──────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _filteredContents => contentsOfChapter(_store.contents, _selectedChapterId);
  List<Map<String, dynamic>> get _importFilteredContents => contentsOfChapter(_store.contents, _importChapterId);
  List<Map<String, dynamic>> get _qFormFilteredContents => contentsOfChapter(_store.contents, _qFormChapterId);

  bool get _isEdit => jsTruthy(_editingQuestionId);

  String get _qFormSelectedCourseExamId => examCourseIdFor(_store.courses, _qFormCourseId);

  // ── watchers (as setters) ─────────────────────────────────────────────

  /// `watch: selectedCourseId`
  void _setSelectedCourseId(String value) {
    if (value == _selectedCourseId) return;
    _set(() => _selectedCourseId = value);
    if (value.isEmpty) return;
    _set(() => _selectedChapterId = '');
    _setSelectedContentId('');
    _ignore(_ctrl.fetchCourseDetails(_numberish(value)));
  }

  void _setSelectedChapterId(String value) => _set(() => _selectedChapterId = value);

  /// `watch: selectedContentId`
  void _setSelectedContentId(String value) {
    if (value == _selectedContentId) return;
    _set(() => _selectedContentId = value);
    if (value.isEmpty) return;
    _set(() => _questions = []);
    _ignore(_loadQuestions());
  }

  /// `watch: importCourseId`
  void _setImportCourseId(String value) {
    if (value == _importCourseId) return;
    _set(() => _importCourseId = value);
    if (value.isEmpty) return;
    _set(() {
      _importChapterId = '';
      _importContentId = '';
    });
    _ignore(_ctrl.fetchCourseDetails(_numberish(value)));
  }

  /// `watch: qFormCourseId` — applied after the synchronous assignments of
  /// the method that changed it (Vue runs watchers before the next render).
  void _setQFormCourseId(String value) {
    if (value == _qFormCourseId) return;
    _set(() => _qFormCourseId = value);
    _watchQFormCourseId(value);
  }

  void _watchQFormCourseId(String value) {
    if (value.isEmpty) return;
    _set(() {
      _qFormChapterId = '';
      _qFormContentId = '';
    });
    _ignore(_ctrl.fetchCourseDetails(_numberish(value)));
  }

  // ── data loading ──────────────────────────────────────────────────────

  Future<void> _loadAllQuestionsOnPageLoad() async {
    try {
      final res = await _ctrl.getExamQuestions({'default_locale': _languageLocale});
      _set(() => _questions = unwrapQuestions(res));
    } catch (_) {
      _set(() => _questions = []);
    }
  }

  Future<void> _loadQuestions() async {
    if (_selectedContentId.isEmpty) return;
    final ids = findExamIdsForContent(_store.sections, _selectedContentId);
    if (ids.examSectionId.isEmpty || ids.examChapterId.isEmpty) return;
    final res = await _ctrl.getExamQuestions({
      'exam_section_id': ids.examSectionId,
      'exam_chapter_id': ids.examChapterId,
    });
    _set(() => _questions = unwrapQuestions(res));
  }

  Future<void> _reload() => _selectedContentId.isNotEmpty ? _loadQuestions() : _loadAllQuestionsOnPageLoad();

  // ── preview ───────────────────────────────────────────────────────────

  void _openPreview(Map<String, dynamic> q) {
    final question = normalizePreview(q);
    _set(() {
      _activeMedia = question.images.isNotEmpty ? 'image' : (question.hasVideo ? 'video' : 'image');
      _previewQuestion = question;
    });
    showAppDialog<void>(context, builder: (_) => _PreviewDialog(s: this));
  }

  // ── create / edit dialog ──────────────────────────────────────────────

  /// `this.qForm = emptyQForm()`
  void _resetQForm() {
    _disposeLater.add(_qForm.dispose);
    _qForm = _QForm();
  }

  void _openCreateDialog() {
    final previousCourse = _qFormCourseId;
    _set(() {
      _editingQuestionId = null;
      _resetQForm();
      _qFormCourseId = _selectedCourseId;
      _qFormChapterId = _selectedChapterId;
      _qFormContentId = _selectedContentId;
      _qForm.tagsInput.text = '';
    });
    if (_qFormCourseId.isNotEmpty) _ignore(_ctrl.fetchCourseDetails(_numberish(_qFormCourseId)));
    // The qFormCourseId watcher runs after this method (and clears the
    // chapter/content just copied when the course changed).
    if (previousCourse != _qFormCourseId) _watchQFormCourseId(_qFormCourseId);
    _openFormDialog();
  }

  Future<void> _openEditDialog(Map<String, dynamic> q) async {
    _set(() {
      _editingQuestionId = '${q['id']}';
      _resetQForm();
      final f = _qForm;
      f.tagsInput.text = '';

      // basic fields
      f.code.text = displayValue(q['code'] ?? '');
      f.questionType = displayValue(q['question_type'] ?? 'MCQ');
      f.stem.text = displayValue(q['stem'] ?? '');
      f.marks.text = jsNumString(jsNumber(q['marks'] ?? 1));
      f.negativeMarks.text = jsNumString(jsNumber(q['negative_marks'] ?? 0.25));
      f.explanation.text = displayValue(q['explanation'] ?? '');
      f.isActive = jsTruthy(q['is_active']);
      f.difficulty = jsTruthy(q['difficulty_level']) ? displayValue(q['difficulty_level']) : '';
      f.videoUrl.text = jsTruthy(q['video_url']) ? displayValue(q['video_url']) : '';
      f.tags = [for (final t in asList(q['tags'])) displayValue(asMap(t)?['tag'])];
      f.tagsInput.text = f.tags.join(', ');

      // options
      final options = [for (final o in asList(q['options'])) ?asMap(o)];
      if (options.isNotEmpty) {
        options.sort(compareOrderIndex);
        f.replaceOptions([
          for (final opt in options)
            _QOption(
              label: displayValue(opt['option_label']),
              text: jsTruthy(opt['option_text']) ? displayValue(opt['option_text']) : '',
              correct: opt['is_correct'],
              image: convertDriveUrl(jsTruthy(opt['image_url']) ? displayValue(opt['image_url']) : ''),
            ),
        ]);
      }

      // images
      final images = [for (final i in asList(q['images'])) ?asMap(i)];
      for (var i = 0; i < images.length; i++) {
        final img = images[i];
        final fixed = convertDriveUrl(jsTruthy(img['image_url']) ? displayValue(img['image_url']) : '');
        f.images.add(_QImage(
          url: fixed,
          caption: displayValue(img['caption'] ?? ''),
          orderIndex: img['order_index'] ?? i + 1,
        ));
      }
    });

    // course/chapter/content association
    final course = asMap(q['course']);
    final subject = asMap(q['subject']);
    final examCourseId = [q['course_id'], course?['id']].firstWhere(jsTruthy, orElse: () => subject?['course_id']);
    Map<String, dynamic>? matchedCourse;
    for (final c in _store.courses) {
      if ('${c['exam_course_id']}' == '$examCourseId') {
        matchedCourse = c;
        break;
      }
    }
    if (matchedCourse != null) {
      _setQFormCourseId('${matchedCourse['id']}');
      try {
        await _ctrl.fetchCourseDetails(_numberish('${matchedCourse['id']}'));
      } catch (_) {
        return; // the dialog never opens when the course details fail
      }
      if (!mounted) return;

      final subjectId = q['subject_id'];
      final topicId = q['topic_id'];
      for (final section in _store.sections) {
        if ('${section['exam_section_id']}' != '$subjectId') continue;
        for (final chapter in asList(section['chapters'])) {
          final ch = asMap(chapter);
          Map<String, dynamic>? matchedContent;
          for (final c in asList(ch?['contents'])) {
            final cm = asMap(c);
            if (cm != null && '${cm['exam_content_id']}' == '$topicId') {
              matchedContent = cm;
              break;
            }
          }
          if (matchedContent != null) {
            _set(() {
              _qFormChapterId = '${ch?['id']}';
              _qFormContentId = '${matchedContent!['exam_content_id']}';
            });
            break;
          }
        }
        break;
      }
    }
    if (!mounted) return;
    _openFormDialog();
  }

  Future<void> _openFormDialog() async {
    if (_questionFormDialog) return;
    _set(() => _questionFormDialog = true);
    await showAppDialog<void>(context, builder: (_) => _QuestionFormDialog(s: this));
    if (mounted) _set(() => _questionFormDialog = false);
  }

  /// `saveQuestion()` — [dialogContext] closes the form on success.
  Future<void> _saveQuestion(BuildContext dialogContext) async {
    // The browser blurs the tags input (→ updateQFormTags) before the click.
    if (_tagsFocus.hasFocus) {
      _updateQFormTags();
      _tagsFocus.unfocus();
    }
    _set(() => _qFormLoading = true);
    try {
      final f = _qForm;
      final examSectionId = examSectionIdForChapter(_store.sections, _qFormChapterId);

      final payload = <String, dynamic>{
        'code': f.code.text,
        'title': f.stem.text,
        'type': f.questionType,
        'exam_section_id': examSectionId,
        'difficulty_level': f.difficulty,
        'marks': looseToNumber(f.marks.text),
        'negative_marks': looseToNumber(f.negativeMarks.text),
        'explanation': f.explanation.text,
        'is_active': f.isActive,
        'exam_chapter_id': _qFormContentId,
        'exam_course_id': _qFormSelectedCourseExamId,
        'video_url': convertDriveUrl(f.videoUrl.text),
        if (f.questionType == 'MCQ')
          'options': [
            for (var i = 0; i < f.options.length; i++)
              {
                'label': f.options[i].label,
                'text': f.options[i].text.text,
                'is_correct': f.options[i].correct,
                'order_index': i + 1,
                'image_url': convertDriveUrl(f.options[i].image),
              },
          ],
        'images': () {
          final withUrl = [for (final img in f.images) if (img.url.isNotEmpty) img];
          return [
            for (var i = 0; i < withUrl.length; i++)
              {
                'image_url': convertDriveUrl(withUrl[i].url),
                'caption': withUrl[i].caption.text,
                'order_index': jsonNumber(() {
                  final raw = looseToNumber(withUrl[i].order.text);
                  return jsTruthy(raw) ? jsNumber(raw) : i + 1;
                }()),
              },
          ];
        }(),
        'tags': [...f.tags],
        'default_locale': _languageLocale,
      };

      if (_isEdit) {
        await _ctrl.updateExamQuestion(_editingQuestionId!, payload);
        AppToast.success('Question updated successfully!');
      } else {
        await _ctrl.createExamQuestion(payload);
        AppToast.success('Question created successfully!');
      }

      if (_questionFormDialog && dialogContext.mounted) Navigator.of(dialogContext).pop();
      await _reload();
    } catch (e) {
      // HTTP errors were toasted by the API client already.
      if (e is! DioException) {
        final message = jsErrorMessage(e);
        AppToast.error((message == null || message.isEmpty) ? 'Failed to save question' : message);
      }
    } finally {
      _set(() => _qFormLoading = false);
    }
  }

  // ── option helpers ────────────────────────────────────────────────────

  void _addOption() => _set(() {
        final label = String.fromCharCode(65 + _qForm.options.length);
        _qForm.options.add(_QOption(label: label));
      });

  void _removeOption(int index) => _set(() {
        _disposeLater.add(_qForm.options.removeAt(index).dispose);
        for (var i = 0; i < _qForm.options.length; i++) {
          _qForm.options[i].label = String.fromCharCode(65 + i);
        }
      });

  /// `v-model="opt.correct"` + `onCorrectToggle(index, val)`.
  void _setCorrect(int index, bool value) => _set(() {
        _qForm.options[index].correct = value;
        if (value) {
          for (var i = 0; i < _qForm.options.length; i++) {
            if (i != index) _qForm.options[i].correct = false;
          }
        }
      });

  Future<void> _onOptionFileChange(int index) async {
    final form = _qForm;
    final file = await pickImageFile();
    if (file == null) return;
    try {
      final res = await _ctrl.uploadExamFile(file);
      final imageUrl = uploadedFileUrl(res);
      if (index >= form.options.length) return;
      _set(() {
        form.options[index].preview = imageUrl;
        form.options[index].image = imageUrl;
      });
    } catch (_) {
      // console.error('Option image upload failed', e)
    }
  }

  void _removeOptionImage(int index) => _set(() {
        _qForm.options[index].preview = '';
        _qForm.options[index].image = '';
      });

  // ── image helpers ─────────────────────────────────────────────────────

  void _addImage() => _set(() => _qForm.images.add(_QImage(orderIndex: _qForm.images.length + 1)));

  void _removeImage(int index) => _set(() => _disposeLater.add(_qForm.images.removeAt(index).dispose));

  Future<void> _onQuestionImageChange(int index) async {
    final form = _qForm;
    final file = await pickImageFile();
    if (file == null) return;
    try {
      final res = await _ctrl.uploadExamFile(file);
      final imageUrl = uploadedFileUrl(res);
      if (index >= form.images.length) return;
      _set(() {
        form.images[index].preview = imageUrl;
        form.images[index].url = imageUrl;
      });
    } catch (_) {
      // un-handled on the web; the API client toasted the error
    }
  }

  void _removeQuestionImage(int index) => _set(() {
        _qForm.images[index].preview = '';
        _qForm.images[index].url = '';
      });

  void _updateQFormTags() {
    _qForm.tags = [
      for (final t in _qForm.tagsInput.text.split(','))
        if (t.trim().isNotEmpty) t.trim(),
    ];
  }

  // ── delete ────────────────────────────────────────────────────────────

  Future<void> _openDeleteDialog(Map<String, dynamic> q) async {
    _set(() {
      _questionToDelete = q;
      _deleteDialog = true;
    });
    await showAppDialog<void>(context, builder: (_) => _DeleteDialog(s: this));
    if (mounted) _set(() => _deleteDialog = false);
  }

  Future<void> _confirmDelete(BuildContext dialogContext) async {
    final q = _questionToDelete;
    if (q == null) return;
    try {
      _set(() => _deleting = true);
      await _ctrl.deleteExamQuestion(q['id'] as Object);
      AppToast.success('Question deleted successfully!');
      if (_deleteDialog && dialogContext.mounted) Navigator.of(dialogContext).pop();
      _set(() => _questionToDelete = null);
      await _reload();
    } catch (_) {
      // console.log(e)
    } finally {
      _set(() => _deleting = false);
    }
  }

  // ── import ────────────────────────────────────────────────────────────

  Future<void> _onFileChange() async {
    final file = await pickUploadFile(allowedExtensions: const ['xlsx', 'csv']);
    if (file == null || !mounted) return;
    if (!isCsvOrXlsx(file.name)) {
      await showAlertMessage(context, 'Only CSV or XLSX files allowed');
      return;
    }
    _set(() => _importFile = file);
  }

  String _getImportExamCourseId() => examCourseIdFor(_store.courses, _importCourseId);

  Future<void> _openImportDialog() async {
    _set(() => _showImportDialog = true);
    await showAppDialog<void>(context, builder: (_) => _ImportDialog(s: this));
    if (mounted) _set(() => _showImportDialog = false);
  }

  Future<void> _openImportResultDialog(Object? result) async {
    _set(() => _importResult = result);
    if (_importResultDialog) return;
    _set(() => _importResultDialog = true);
    await showAppDialog<void>(context, builder: (_) => _ImportResultDialog(s: this));
    if (mounted) _set(() => _importResultDialog = false);
  }

  /// `handleImport()` — [dialogContext] closes the import dialog on success.
  Future<void> _handleImport(BuildContext dialogContext) async {
    if (_importFile == null || _importCourseId.isEmpty || _importChapterId.isEmpty || _importContentId.isEmpty) {
      _openImportResultDialog({
        'success': 0,
        'failed': 0,
        'errors': ['Please fill all fields and select a file'],
      });
      return;
    }
    final examSectionId = examSectionIdForChapter(_store.sections, _importChapterId);
    final examChapterId = examSectionId.isEmpty ? '' : _importContentId;
    final examCourseId = _getImportExamCourseId();
    if (examCourseId.isEmpty || examSectionId.isEmpty || examChapterId.isEmpty) {
      _openImportResultDialog({
        'success': 0,
        'failed': 0,
        'errors': ['Course/Section/Chapter mapping failed'],
      });
      return;
    }
    try {
      _set(() => _importing = true);
      final res = await _ctrl.importBulkExamQuestions(
        file: _importFile!,
        examCourseId: examCourseId,
        examSectionId: examSectionId,
        examChapterId: examChapterId,
        defaultLocale: _languageLocale,
      );
      if (_showImportDialog && dialogContext.mounted) Navigator.of(dialogContext).pop();
      _openImportResultDialog(res);
      await _reload();
    } catch (e) {
      final message = jsErrorMessage(e);
      _openImportResultDialog({
        'success': 0,
        'failed': 1,
        'errors': [(message == null || message.isEmpty) ? 'Import failed' : message],
      });
    } finally {
      _set(() => _importing = false);
    }
  }

  Future<void> _downloadTemplate() async {
    final csv = buildTemplateCsv(videoUrl: '');
    await saveBytesAs(utf8.encode(csv), 'question_import_template.csv', mimeType: 'text/csv;charset=utf-8;');
  }

  @override
  Widget build(BuildContext context) => _buildPage(context);
}
