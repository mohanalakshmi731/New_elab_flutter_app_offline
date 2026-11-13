import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/files.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/html_editor.dart';
import '../../widgets/web_content_view.dart';
import '../institutes/institute_widgets.dart' show LabeledCheckbox, SpinIcon, StarLabel;
import '../users/users_widgets.dart' show FileInputField, FormGrid, UploadPreview;
import 'teacher_course_logic.dart';
import 'teacher_course_widgets.dart';

/// Dialogs of `teachercoursepage.vue`. Each keeps its own inputs and calls an
/// async `onSubmit` with the submit button showing the spinner
/// (`isCreateBtnLoading`); outside clicks / Escape are ignored meanwhile.
/// `onSubmit` returns `true` when the dialog should close.

/// The `<Input type="number">` order fields.
final _numberFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9eE.+\-]'));

/// Submit button with the `bi-arrow-repeat animate-spin` spinner (14px, in
/// the button's `text-primary-foreground`).
Widget _submitButton(String label, bool loading, VoidCallback onPressed) => Builder(
      builder: (context) => AppButton(
        onPressed: loading ? null : onPressed,
        child: loading ? SpinIcon(size: 14, color: context.colors.onPrimary) : Text(label),
      ),
    );

/// `<div class="flex flex-col gap-1.5"><Label>…</Label>…</div>`; a required
/// label is `Title <span class="text-red-500">*</span>` (the label is
/// `flex gap-2`, so the star sits 8px after the text).
Widget _labeled(String label, Widget child, {bool required = false}) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(alignment: Alignment.centerLeft, child: StarLabel(label, star: required, bigStar: false)),
        const SizedBox(height: 6),
        child,
      ],
    );

// ── New Course / Update Course ─────────────────────────────────────────────

/// Values edited by the course dialogs (`courseForm` + `createStatusString` /
/// `createIsMathPlay`, or `updateForm`).
class CourseDialogValues {
  const CourseDialogValues({
    this.title = '',
    this.shortName = '',
    this.courseCode = '',
    this.description = '',
    this.status = 'draft',
    this.image,
    this.existingImage = '',
    this.isMathPlay = false,
  });

  final String title;
  final String shortName;
  final String courseCode;
  final String description;
  final String status;
  final UploadFile? image;
  final String existingImage;
  final bool isMathPlay;
}

class CourseFormDialog extends StatefulWidget {
  const CourseFormDialog({
    super.key,
    required this.update,
    required this.initial,
    required this.onSubmit,
    this.load,
  });

  /// `false` = "New Course", `true` = "Update Course".
  final bool update;
  final CourseDialogValues initial;

  /// `openUpdateDialog` fills the form once the course details arrive.
  final Future<CourseDialogValues?> Function()? load;
  final Future<bool> Function(CourseDialogValues values) onSubmit;

  @override
  State<CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _title = TextEditingController();
  final _shortName = TextEditingController();
  final _code = TextEditingController();
  final _description = TextEditingController();
  late String _status;
  UploadFile? _image;
  late String _existingImage;
  late bool _isMathPlay;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _apply(widget.initial);
    final load = widget.load;
    if (load != null) {
      load().then((v) {
        if (v != null && mounted) setState(() => _apply(v));
      }, onError: (_) {});
    }
  }

  void _apply(CourseDialogValues v) {
    _title.text = v.title;
    _shortName.text = v.shortName;
    _code.text = v.courseCode;
    _description.text = v.description;
    _status = v.status;
    _image = v.image;
    _existingImage = v.existingImage;
    _isMathPlay = v.isMathPlay;
  }

  @override
  void dispose() {
    for (final c in [_title, _shortName, _code, _description]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pick() async {
    final file = await pickImageFile();
    if (file != null && mounted) setState(() => _image = file);
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final ok = await widget.onSubmit(CourseDialogValues(
      title: _title.text,
      shortName: _shortName.text,
      courseCode: _code.text,
      description: _description.text,
      status: _status,
      image: _image,
      existingImage: _existingImage,
      isMathPlay: _isMathPlay,
    ));
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final update = widget.update;
    final hasPreview = _image != null || (update && _existingImage.isNotEmpty);
    return PopScope(
      canPop: !_loading,
      child: AppDialogFrame(
        title: update ? 'Update Course' : 'New Course',
        description: update ? 'Edit course details below.' : 'Fill in the details to create a new course.',
        maxWidth: 672,
        // `<div class="p-1 flex flex-col gap-4 mt-2">` + the footer, both
        // scrolling in the `max-h-[90vh] overflow-y-auto` content.
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FormGrid(columns: context.isSm ? 2 : 1, children: [
                    _labeled('Title', AppTextField(controller: _title, hint: 'Course Title'), required: true),
                    _labeled('Short Name', AppTextField(controller: _shortName, hint: 'Short name'), required: true),
                    _labeled('Course Code', AppTextField(controller: _code, hint: 'e.g. MATH101'), required: true),
                    _labeled(
                      'Status',
                      AppSelect<String>(
                        value: _status,
                        placeholder: 'Select status',
                        items: [
                          const AppSelectItem('published', 'Published'),
                          AppSelectItem('draft', update ? 'Unpublished' : 'Draft'),
                          const AppSelectItem('archived', 'Archived'),
                        ],
                        onChanged: (v) => setState(() => _status = v ?? _status),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  _labeled(
                    'Description',
                    AppTextField(controller: _description, hint: 'Course description...', maxLines: null, minLines: 3),
                  ),
                  const SizedBox(height: 16),
                  _labeled('Cover Image', FileInputField(fileName: _image?.name, onTap: _pick)),
                  if (hasPreview)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(top: 8),
                        width: 160,
                        height: 96,
                        clipBehavior: Clip.antiAlias,
                        // `rounded-xl border border-slate-200` (no dark variant)
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Tw.slate200),
                        ),
                        child: _image != null
                            ? UploadPreview(file: _image!, width: 160, height: 96)
                            : Image.network(_existingImage,
                                fit: BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox.shrink()),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: LabeledCheckbox(
                      value: _isMathPlay,
                      label: 'Math Play Course',
                      onChanged: (v) => setState(() => _isMathPlay = v),
                    ),
                  ),
                ],
              ),
            ),
            tcDialogFooter([
              AppButton(
                label: 'Cancel',
                variant: AppButtonVariant.outline,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
              _submitButton(update ? 'Update Course' : 'Create Course', _loading, _submit),
            ]),
          ],
        ),
      ),
    );
  }
}

// ── Sections / chapters ───────────────────────────────────────────────────

/// "Create Section" / "Edit Section" / "Create Chapter" / "Edit Chapter".
class NameOrderDialog extends StatefulWidget {
  const NameOrderDialog({
    super.key,
    required this.title,
    required this.nameLabel,
    required this.namePlaceholder,
    required this.submitLabel,
    required this.onSubmit,
    this.initialName = '',
    this.initialOrder = '',
    this.load,
  });

  final String title;
  final String nameLabel;
  final String namePlaceholder;
  final String submitLabel;

  /// `null` hides the name input (`v-if="selectedSectionDetails"`) until
  /// [load] provides one.
  final String? initialName;
  final String initialOrder;
  final Future<(String, String)?> Function()? load;
  final Future<bool> Function(String name, String order) onSubmit;

  @override
  State<NameOrderDialog> createState() => _NameOrderDialogState();
}

class _NameOrderDialogState extends State<NameOrderDialog> {
  late final _name = TextEditingController(text: widget.initialName ?? '');
  late final _order = TextEditingController(text: widget.initialOrder);
  late bool _showName = widget.initialName != null;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final load = widget.load;
    if (load != null) {
      load().then((v) {
        if (v == null || !mounted) return;
        setState(() {
          _name.text = v.$1;
          _order.text = v.$2;
          _showName = true;
        });
      }, onError: (_) {});
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _order.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final ok = await widget.onSubmit(_name.text, _order.text);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_loading,
      child: AppDialogFrame(
        title: widget.title,
        // `<div class="flex flex-col gap-3 mt-2">` + the footer.
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _labeled(
                widget.nameLabel,
                _showName ? AppTextField(controller: _name, hint: widget.namePlaceholder) : const SizedBox.shrink(),
              ),
              const SizedBox(height: 12),
              _labeled(
                'Order',
                AppTextField(
                  controller: _order,
                  hint: 'Order number',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: [_numberFormatter],
                ),
              ),
              tcDialogFooter([
                AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                _submitButton(widget.submitLabel, _loading, _submit),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Concepts (contents) ────────────────────────────────────────────────────

/// `contentForm` (create) / `selectedContentDetails` (edit).
class ConceptValues {
  const ConceptValues({
    this.name = '',
    this.order = '',
    this.type = '',
    this.htmlContent = '',
    this.url = '',
    this.file,
  });

  final String name;
  final String order;
  final String type;
  final String htmlContent;
  final String url;
  final UploadFile? file;
}

class ConceptDialog extends StatefulWidget {
  const ConceptDialog({super.key, required this.edit, required this.initial, required this.onSubmit});

  /// `false` = "Create Concept", `true` = "Edit Concept".
  final bool edit;
  final ConceptValues initial;
  final Future<bool> Function(ConceptValues values) onSubmit;

  @override
  State<ConceptDialog> createState() => _ConceptDialogState();
}

class _ConceptDialogState extends State<ConceptDialog> {
  late final _name = TextEditingController(text: widget.initial.name);
  late final _order = TextEditingController(text: widget.initial.order);
  late final _url = TextEditingController(text: widget.initial.url);
  late String _type = widget.initial.type;
  late String _html = widget.initial.htmlContent;
  late UploadFile? _file = widget.initial.file;
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_name, _order, _url]) {
      c.dispose();
    }
    super.dispose();
  }

  /// `onContentFileChange` (`accept="*/*"`).
  Future<void> _pick() async {
    final file = await pickUploadFile();
    if (file != null && mounted) setState(() => _file = file);
  }

  Future<void> _submit() async {
    setState(() => _loading = true);
    final ok = await widget.onSubmit(ConceptValues(
      name: _name.text,
      order: _order.text,
      type: _type,
      htmlContent: _html,
      url: _url.text,
      file: _file,
    ));
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final edit = widget.edit;
    final existingUrl = widget.initial.url;

    // `<label class="cursor-pointer bg-emerald-600 text-white px-4 py-2
    // rounded-md hover:bg-emerald-700 text-[13px]">` + `text-slate-500
    // text-[12px]` file name.
    final chooseFile = Row(
      children: [
        Material(
          color: Tw.emerald600,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: _pick,
            hoverColor: Tw.emerald700,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(edit ? 'Replace File' : 'Choose File',
                  style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.5)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: edit ? double.infinity : 200),
            child: Text(
              // The edit dialog shows the concept name, not the file name.
              edit
                  ? (_file != null ? _name.text : 'No new file chosen')
                  : (_file != null ? _file!.name : 'No file chosen'),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: Tw.slate500),
            ),
          ),
        ),
      ],
    );

    return PopScope(
      canPop: !_loading,
      child: AppDialogFrame(
        title: edit ? 'Edit Concept' : 'Create Concept',
        maxWidth: 896,
        // `<div class="flex flex-col gap-4 mt-2">` + the footer.
        child: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _labeled('Name', AppTextField(controller: _name, hint: 'Concept name', maxLength: 255)),
              const SizedBox(height: 16),
              _labeled(
                'Order',
                AppTextField(
                  controller: _order,
                  hint: 'Order number',
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  inputFormatters: [_numberFormatter],
                ),
              ),
              const SizedBox(height: 16),
              _labeled(
                'Type',
                AppSelect<String>(
                  value: _type.isEmpty ? null : _type,
                  placeholder: 'Select type',
                  items: const [
                    AppSelectItem('html', 'HTML'),
                    AppSelectItem('pdf', 'PDF'),
                    AppSelectItem('url', 'URL'),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? _type),
                ),
              ),
              if (_type == 'html') ...[
                const SizedBox(height: 16),
                _labeled('Content', HtmlEditor(initialHtml: _html, onChanged: (v) => _html = v)),
              ],
              if (_type == 'pdf') ...[
                const SizedBox(height: 16),
                _labeled(
                  'File',
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // `<object :data="url#toolbar=0…" type="application/pdf" height="300px">`
                      // (the web swapped in the picked file's blob URL).
                      if (edit && existingUrl.isNotEmpty && _file == null)
                        Container(
                          height: 300,
                          margin: const EdgeInsets.only(bottom: 12),
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16), // `border rounded-lg`
                            border: Border.all(color: context.isDark ? AppColors.darkBorder : AppColors.border),
                          ),
                          child: WebContentView(url: pdfEmbedUrl(existingUrl), showOpenExternally: true),
                        ),
                      chooseFile,
                    ],
                  ),
                ),
              ],
              if (_type == 'url') ...[
                const SizedBox(height: 16),
                _labeled('URL', AppTextField(controller: _url, hint: 'https://...', keyboardType: TextInputType.url)),
              ],
              tcDialogFooter([
                AppButton(
                  label: 'Cancel',
                  variant: AppButtonVariant.outline,
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
                _submitButton(edit ? 'Update' : 'Create', _loading, _submit),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

// ── previews ──────────────────────────────────────────────────────────────

/// "Content Preview — available to everyone" (`isContentPreviewOpen`).
class ContentPreviewDialog extends StatelessWidget {
  const ContentPreviewDialog({super.key, required this.content});
  final Map<String, dynamic> content;

  @override
  Widget build(BuildContext context) {
    final type = content['type'];
    final url = '${content['url']}';
    final vh = MediaQuery.sizeOf(context).height;
    final Widget body;
    if (type == 'html') {
      // `<div class="preview break-words" v-html="content">` — a web view
      // needs a fixed height.
      body = SizedBox(
        height: vh * 0.6,
        child: WebContentView(html: previewHtml(content['content'], dark: context.isDark, breakWords: true)),
      );
    } else if (type == 'url') {
      body = UrlMediaBox(
        url: url,
        height: context.isSm ? 450 : 350,
        cannotPreviewText: 'Cannot preview this website.',
      );
    } else if (type == 'pdf') {
      body = Container(
        height: vh * 0.7,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20), // `border rounded-xl`
          border: Border.all(color: context.isDark ? AppColors.darkBorder : AppColors.border),
        ),
        child: WebContentView(url: pdfEmbedUrl(content['url']), showOpenExternally: true),
      );
    } else {
      body = const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text('No preview available.',
            style: TextStyle(color: Tw.slate400, fontStyle: FontStyle.italic, fontSize: 13)),
      );
    }
    return AppDialogFrame(
      title: '${content['name'] ?? ''}',
      maxWidth: 896,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          body,
          tcDialogFooter([AppButton(label: 'Close', onPressed: () => Navigator.of(context).pop())]),
        ],
      ),
    );
  }
}

/// `isPDFopen` — the preview tab's "Full Screen" PDF (`sm:max-w-6xl h-[90vh]`).
class PdfFullScreenDialog extends StatelessWidget {
  const PdfFullScreenDialog({super.key, required this.url});
  final Object? url;

  @override
  Widget build(BuildContext context) {
    final vh = MediaQuery.sizeOf(context).height;
    final height = math.max(120.0, math.min(vh * 0.9, vh - 32) - 48);
    return AppDialogFrame(
      maxWidth: 1152,
      child: SizedBox(
        height: height,
        child: url == null || url == ''
            ? const SizedBox.shrink()
            : Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20), // `border rounded-xl`
                  border: Border.all(color: context.isDark ? AppColors.darkBorder : AppColors.border),
                ),
                child: WebContentView(url: pdfEmbedUrl(url), showOpenExternally: true),
              ),
      ),
    );
  }
}
