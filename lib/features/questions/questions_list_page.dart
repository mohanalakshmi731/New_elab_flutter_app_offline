import 'dart:convert';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/files.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_table.dart';
import '../../widgets/form_fields.dart';
import '../users/users_widgets.dart' show FormGrid, ShadCard;
import 'questions_controller.dart';
import 'questions_logic.dart';
import 'questions_widgets.dart';

part 'questions_list_dialogs.dart';

/// Port of `src/pages/exams/questionslist.vue` (`/questions`): the question
/// bank with Subject → Chapter → Content and Language filters, preview /
/// edit / delete per question, CSV/XLSX import and the template download.
///
/// No route params. "Add Question" goes to `/exams/createexam`, the pencil to
/// `/exams/question/edit/:id?course_id=…&exam_section_id=…&exam_chapter_id=…`.
class QuestionsListPage extends ConsumerStatefulWidget {
  const QuestionsListPage({super.key});

  @override
  ConsumerState<QuestionsListPage> createState() => _QuestionsListPageState();
}

class _QuestionsListPageState extends ConsumerState<QuestionsListPage> {
  // ── data() ────────────────────────────────────────────────────────────
  String _importLocale = '';
  String _selectedLocale = defaultQuestionLocale;
  String _activeMedia = 'image';
  Object? _importResult;
  PreviewQuestion? _previewQuestion;
  String _importCourseId = '';
  String _importChapterId = '';
  String _importContentId = '';
  Map<String, dynamic>? _questionToDelete;
  bool _deleting = false;
  String _selectedCourseId = '';
  String _selectedChapterId = '';
  String _selectedContentId = '';
  List<Map<String, dynamic>> _questions = [];
  UploadFile? _importFile;
  bool _importing = false;
  String _currentExamSectionId = '';
  String _currentExamChapterId = '';

  // `v-model:open` flags of the dialogs.
  bool _deleteDialog = false;
  bool _showImportDialog = false;
  bool _importResultDialog = false;

  /// Rebuilds open dialogs when page state they show changes.
  final _tick = ValueNotifier<int>(0);

  QuestionsController get _ctrl => ref.read(questionsControllerProvider.notifier);
  QuestionsState get _store => ref.read(questionsControllerProvider);
  String get _role => ref.read(sessionProvider).role;

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
    Future.microtask(_mounted);
  }

  @override
  void dispose() {
    _tick.dispose();
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

  // ── computed ──────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _importFilteredContents => contentsOfChapter(_store.contents, _importChapterId);

  List<Map<String, dynamic>> get _filteredContents => contentsOfChapter(_store.contents, _selectedChapterId);

  // ── watchers (as setters) ─────────────────────────────────────────────

  /// `watch: selectedLocale`
  void _setSelectedLocale(String value) {
    if (value == _selectedLocale) return;
    _set(() => _selectedLocale = value);
    _ignore(() async {
      final params = <String, dynamic>{
        if (value != 'all') 'default_locale': value,
      };
      if (_currentExamSectionId.isNotEmpty && _currentExamChapterId.isNotEmpty) {
        params['exam_section_id'] = _currentExamSectionId;
        params['exam_chapter_id'] = _currentExamChapterId;
      }
      final res = await _ctrl.getExamQuestions(params);
      _set(() => _questions = unwrapQuestions(res));
    }());
  }

  /// `watch: selectedCourseId`
  void _setSelectedCourseId(String value) {
    if (value == _selectedCourseId) return;
    _set(() => _selectedCourseId = value);
    if (value.isEmpty) return;
    _set(() {
      _selectedChapterId = '';
      _questions = [];
    });
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

  /// `Number(id)`
  static Object _numberish(String id) => int.tryParse(id) ?? num.tryParse(id) ?? id;

  // ── methods ───────────────────────────────────────────────────────────

  void _resetImportForm() {
    _set(() {
      _importFile = null;
      _importChapterId = '';
      _importContentId = '';
      _importLocale = '';
    });
    _setImportCourseId('');
  }

  void _openPreview(Map<String, dynamic> q) {
    final question = normalizePreview(q);
    _set(() {
      if (question.images.isNotEmpty) {
        _activeMedia = 'image';
      } else if (question.hasVideo) {
        _activeMedia = 'video';
      }
      _previewQuestion = question;
    });
    showAppDialog<void>(context, builder: (_) => _PreviewDialog(s: this));
  }

  Future<void> _loadAllQuestionsOnPageLoad() async {
    try {
      final res = await _ctrl.getExamQuestions({
        'default_locale': _selectedLocale != 'all' ? _selectedLocale : 'en',
      });
      _set(() => _questions = unwrapQuestions(res));
    } catch (_) {
      _set(() => _questions = []);
    }
  }

  String _getImportExamCourseId() => examCourseIdFor(_store.courses, _importCourseId);

  Future<void> _onFileChange() async {
    final file = await pickUploadFile(allowedExtensions: const ['xlsx', 'csv']);
    if (file == null || !mounted) return;
    if (!isCsvOrXlsx(file.name)) {
      await showAlertMessage(context, 'Only CSV or XLSX files allowed');
      return;
    }
    const allowedTypes = ['text/csv', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'];
    final type = mimeTypeFor(file.name);
    if (!allowedTypes.contains(type) && type.isNotEmpty) {
      await showAlertMessage(context, 'Invalid file format');
      return;
    }
    _set(() => _importFile = file);
  }

  void _editQuestion(Map<String, dynamic> q) {
    context.go(Uri(
      path: '/exams/question/edit/${q['id']}',
      queryParameters: {
        'course_id': _selectedCourseId,
        'exam_section_id': _currentExamSectionId,
        'exam_chapter_id': _currentExamChapterId,
      },
    ).toString());
  }

  Future<void> _loadQuestions() async {
    if (_selectedContentId.isEmpty) return;
    final ids = findExamIdsForContent(_store.sections, _selectedContentId);
    if (ids.examSectionId.isEmpty || ids.examChapterId.isEmpty) return;
    _set(() {
      _currentExamSectionId = ids.examSectionId;
      _currentExamChapterId = ids.examChapterId;
    });
    final res = await _ctrl.getExamQuestions({
      'exam_section_id': ids.examSectionId,
      'exam_chapter_id': ids.examChapterId,
    });
    _set(() => _questions = unwrapQuestions(res));
  }

  Future<void> _downloadTemplate() async {
    final csv = buildTemplateCsv(videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ');
    await saveBytesAs(utf8.encode(csv), 'question_import_template.csv', mimeType: 'text/csv;charset=utf-8;');
  }

  void _goCreate() => context.go('/exams/createexam');

  Future<void> _openImportDialog() async {
    _set(() => _showImportDialog = true);
    await showAppDialog<void>(context, builder: (_) => _ImportDialog(s: this));
    if (!mounted) return;
    _set(() => _showImportDialog = false);
    _resetImportForm();
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
    if (_importLocale.isEmpty) {
      _openImportResultDialog({
        'success': 0,
        'failed': 0,
        'errors': ['Please select language'],
      });
      return;
    }
    if (_importFile == null) {
      _openImportResultDialog({
        'success': 0,
        'failed': 0,
        'errors': ['Please select a file'],
        'failedImageUrls': <String>[],
      });
      return;
    }
    if (_importCourseId.isEmpty || _importChapterId.isEmpty || _importContentId.isEmpty) {
      _openImportResultDialog({
        'success': 0,
        'failed': 0,
        'errors': ['Please select Course, Chapter and Content'],
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
        defaultLocale: _importLocale,
      );
      if (_showImportDialog && dialogContext.mounted) Navigator.of(dialogContext).pop();
      _openImportResultDialog(res);
      if (_selectedContentId.isNotEmpty) {
        await _loadQuestions();
      } else {
        await _loadAllQuestionsOnPageLoad();
      }
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
      showRedSuccessToast('Question deleted successfully!');
      if (_deleteDialog && dialogContext.mounted) Navigator.of(dialogContext).pop();
      _set(() => _questionToDelete = null);
      if (_selectedContentId.isNotEmpty) {
        await _loadQuestions();
      } else {
        await _loadAllQuestionsOnPageLoad();
      }
    } catch (_) {
      // console.log(e)
    } finally {
      _set(() => _deleting = false);
    }
  }

  // ── template ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final store = ref.watch(questionsControllerProvider);
    final role = ref.watch(sessionProvider.select((s) => s.role));
    final instructor = role == 'instructor';
    final sm = context.isSm;
    final primary = context.colors.primary;

    final header = [
      // `text-xl sm:text-2xl font-semibold text-primary`
      Text(
        'Questions',
        style: TextStyle(
          fontSize: sm ? 24 : 20,
          height: sm ? 32 / 24 : 28 / 20,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
      ),
      // `role === Role.Instructor && hasCourses`
      if (instructor && store.courses.isNotEmpty)
        Wrap(
          spacing: sm ? 12 : 8,
          runSpacing: sm ? 12 : 8,
          children: [
            AppButton(label: 'Import Questions', onPressed: _openImportDialog),
            AppButton(label: 'Download Template', variant: AppButtonVariant.outline, onPressed: _downloadTemplate),
            AppButton(label: 'Add Question', onPressed: _goCreate),
          ],
        ),
    ];

    return SingleChildScrollView(
      child: ShadCard(
        child: Padding(
          padding: EdgeInsets.all(sm ? 24 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (role != 'student') ...[
                if (sm)
                  Row(
                    children: [
                      header.first,
                      if (header.length > 1) ...[
                        const SizedBox(width: 16),
                        Expanded(child: Align(alignment: Alignment.centerRight, child: header[1])),
                      ],
                    ],
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      header.first,
                      if (header.length > 1) ...[const SizedBox(height: 16), header[1]],
                    ],
                  ),
                const SizedBox(height: 24),
              ],
              _filters(store),
              const SizedBox(height: 24 + 16),
              _table(instructor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _labeled(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [FieldLabel(label), child],
      );

  Widget _filters(QuestionsState store) {
    final courses = store.courses;
    final chapters = store.chapters;
    final contents = _filteredContents;
    return FormGrid(
      columns: context.isLg ? 4 : (context.isSm ? 2 : 1),
      children: [
        _labeled(
          'Subjects',
          AppSelect<String>(
            value: _selectedCourseId,
            enabled: courses.isNotEmpty,
            placeholder: courses.isNotEmpty ? 'Select Subject' : 'No subjects available',
            items: courses.isNotEmpty
                ? [for (final c in courses) AppSelectItem('${c['id']}', displayValue(c['title']))]
                : const [AppSelectItem(noOptionsValue, 'No courses available', enabled: false)],
            onChanged: (v) => _setSelectedCourseId(v ?? ''),
          ),
        ),
        _labeled(
          'Chapter',
          AppSelect<String>(
            value: _selectedChapterId,
            enabled: _selectedCourseId.isNotEmpty && chapters.isNotEmpty,
            placeholder: _selectedCourseId.isEmpty
                ? 'Select Subject first'
                : chapters.isNotEmpty
                    ? 'Select Chapter'
                    : 'No chapters available',
            items: chapters.isNotEmpty
                ? [for (final c in chapters) AppSelectItem('${c['id']}', displayValue(c['name']))]
                : const [AppSelectItem.message(noOptionsValue, 'No chapters found')],
            onChanged: (v) => _setSelectedChapterId(v ?? ''),
          ),
        ),
        _labeled(
          'Content',
          AppSelect<String>(
            value: _selectedContentId,
            enabled: _selectedChapterId.isNotEmpty && contents.isNotEmpty,
            placeholder: _selectedChapterId.isEmpty
                ? 'Select chapter first'
                : contents.isNotEmpty
                    ? 'Select Content'
                    : 'No content available',
            items: contents.isNotEmpty
                ? [for (final c in contents) AppSelectItem('${c['id']}', displayValue(c['name']))]
                : const [AppSelectItem(noOptionsValue, 'No content available', enabled: false)],
            onChanged: (v) => _setSelectedContentId(v ?? ''),
          ),
        ),
        _labeled(
          'Language',
          AppSelect<String>(
            value: _selectedLocale,
            placeholder: 'All Languages',
            items: [for (final e in questionLocales.entries) AppSelectItem(e.value, e.key)],
            onChanged: (v) => _setSelectedLocale(v ?? ''),
          ),
        ),
      ],
    );
  }

  Widget _table(bool instructor) {
    // `<Table>` is `text-sm` at every width.
    const cellStyle = TextStyle(fontSize: 14);
    // `<TableHead class="w-[…]">` widths act as column minimums.
    final minWidth = instructor ? 1170.0 : 1030.0;
    return LayoutBuilder(
      builder: (context, c) {
        // The empty row's cell is `colspan="6"`: with the Actions column
        // (7 columns) its text is centred over the first six only.
        final tableWidth = c.maxWidth.isFinite ? (c.maxWidth - 2 < minWidth ? minWidth : c.maxWidth - 2) : minWidth;
        final actionsWidth = instructor ? tableWidth * 140 / minWidth : 0.0;
        return _tableFor(instructor, cellStyle, minWidth, actionsWidth);
      },
    );
  }

  Widget _tableFor(bool instructor, TextStyle cellStyle, double minWidth, double actionsWidth) {
    return AppTable(
      minWidth: minWidth,
      fontSize: 14,
      // `<TableCell colspan="6" class="text-center py-10 text-muted-foreground">`
      emptyText: 'No questions found',
      emptyTextColor: context.mutedFgColor,
      emptyPadding: EdgeInsets.fromLTRB(8, 40, 8 + actionsWidth, 40),
      columns: [
        const AppTableColumn('Language', flex: 1.1),
        const AppTableColumn('Code', flex: 1.2),
        const AppTableColumn('Question', flex: 4.2),
        const AppTableColumn('Type', flex: 1.4),
        const AppTableColumn('Difficulty', flex: 1.4),
        const AppTableColumn('Marks', flex: 1),
        if (instructor) const AppTableColumn('Actions', flex: 1.4, alignEnd: true),
      ],
      rows: [
        for (final q in _questions)
          [
            Text(getLocaleName(q['default_locale'])),
            Text(displayValue(q['code']), style: const TextStyle(fontWeight: FontWeight.w500)),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: HtmlText(truncate(q['stem']), style: cellStyle, maxLines: 3, softWrap: false),
            ),
            Text(displayValue(q['question_type'])),
            Text(displayValue(q['difficulty_level'])),
            Text(displayValue(q['marks'])),
            if (instructor)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  HoverScaleIcon(
                    icon: BootstrapIcons.eye_fill,
                    color: Tw.blue600,
                    onTap: () => _openPreview(q),
                  ),
                  const SizedBox(width: 12),
                  HoverScaleIcon(
                    icon: BootstrapIcons.pencil_square,
                    color: Tw.green600,
                    onTap: () => _editQuestion(q),
                  ),
                  const SizedBox(width: 12),
                  HoverScaleIcon(
                    icon: BootstrapIcons.trash3_fill,
                    color: Tw.red600,
                    onTap: () => _openDeleteDialog(q),
                  ),
                ],
              ),
          ],
      ],
    );
  }
}
