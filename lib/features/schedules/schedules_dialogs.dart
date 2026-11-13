part of 'schedules_page.dart';

/// Edit Schedule, the reference / assignment dialogs (create, edit, view),
/// the quiz dialog and the delete confirmation.
extension _DialogsUi on _SchedulesPageState {
  // ── Edit Schedule ────────────────────────────────────────────────────────

  Widget _buildEditDialog(BuildContext context) {
    final f = _editForm;
    final numberFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'));
    final instructorItems = <AppSelectItem<String>>[
      for (final i in _store.instructors)
        AppSelectItem(
          schString(i['id']),
          jsTruthy(dig(i, ['user', 'email'])) ? '${dig(i, ['user', 'email'])}' : vText(i['name']),
        ),
    ];
    return AppDialogFrame(
      // `max-w-3xl` loses to the dialog's own `sm:max-w-lg` on the web.
      maxWidth: 512,
      actions: [
        AppButton(label: 'Cancel', variant: AppButtonVariant.outline, onPressed: () => _closeDialog(_Dlg.edit)),
        AppButton(label: 'Save', onPressed: _submitEditForm),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _dialogHeader(context, 'Edit Schedule', description: 'Update the schedule details below.'),
          // The grid's `mt-4` + the dialog's `gap-4`; the same again before
          // the footer (`mt-4`).
          const SizedBox(height: 32),
          _editFields(context, f, numberFormatter, instructorItems),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// The Edit Schedule grid (`grid-cols-1 lg:grid-cols-2 gap-4`; each
  /// `<Label>` sits right on its control).
  Widget _editFields(
    BuildContext context,
    _EditForm f,
    TextInputFormatter numberFormatter,
    List<AppSelectItem<String>> instructorItems,
  ) =>
      FormGrid(
        columns: context.isLg ? 2 : 1,
        gap: 16,
        children: [
          _labeled(
            'Start Date',
            gap: 0,
            _DateButton(
              value: f.startDate,
              placeholder: 'Pick a start date',
              onChanged: (v) => _set(() => f.startDate = v),
            ),
          ),
          _labeled('Start Time', gap: 0, _TimeInput(value: f.startTime, onChanged: (v) => _set(() => f.startTime = v))),
          _labeled(
            'Duration (Minutes)',
            gap: 0,
            AppTextField(
              controller: f.duration,
              hint: 'Enter duration in minutes',
              keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
              inputFormatters: [numberFormatter],
            ),
          ),
          _labeled(
            'Subject',
            gap: 0,
            AppSelect<String>(
              value: f.subjectId.isEmpty ? null : f.subjectId,
              placeholder: 'Select a Subject',
              items: _subjectItems,
              onChanged: (v) => _set(() => f.subjectId = v ?? ''),
            ),
          ),
          _labeled(
            'Class Type',
            gap: 0,
            AppSelect<String>(
              value: f.classType.isEmpty ? null : f.classType,
              placeholder: 'Select Class Type',
              items: const [AppSelectItem('eClass', 'eClass')],
              onChanged: (v) => _set(() => f.classType = v ?? ''),
            ),
          ),
          _labeled('Title', gap: 0, AppTextField(controller: f.title, hint: 'Enter class title')),
          GridSpan(
            child: _labeled(
              'Instructor',
              gap: 0,
              AppSelect<String>(
                value: jsTruthy(f.instructorId) ? f.instructorId : null,
                placeholder: 'Select Instructor',
                items: instructorItems,
                onChanged: (v) => _set(() => f.instructorId = v),
              ),
            ),
          ),
        ],
      );

  // ── shared pieces ────────────────────────────────────────────────────────

  /// Title + "Link to LMS" toggle row of the reference / assignment dialogs
  /// (`mb-4` / `mb-6` plus the dialog's `gap-4`).
  Widget _lmsHeader(BuildContext context, String title, bool on, VoidCallback toggle, {double bottom = 32}) =>
      Padding(
        padding: EdgeInsets.only(bottom: bottom, right: 28),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 16,
          runSpacing: 8,
          children: [
            Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: context.colors.primary)),
            _LmsToggle(on: on, onToggle: toggle),
          ],
        ),
      );

  /// "Select LMS Content" (`classCoursesDropdown`).
  Widget _lmsSelect(BuildContext context, Object? value, ValueChanged<Object?> onChanged) => _fixedWidth(
        context,
        320,
        _labeled(
          'Select LMS Content',
          gap: 4,
          AppSelect<Object?>(
            value: jsTruthy(value) ? value : null,
            placeholder: 'Choose from LMS content',
            items: [for (final c in _classCoursesDropdown) AppSelectItem<Object?>(c['id'], vText(c['name']))],
            onChanged: onChanged,
          ),
        ),
      );

  /// The right-aligned footer (`flex justify-end gap-3|space-x-2 pt-4
  /// mt-2|mt-4 border-t`). Its top margin collapses with the `space-y-*` gap
  /// of the column (16, or 20 in the reference form); [top] adds what the
  /// column's gap lacks.
  Widget _footer(BuildContext context, List<Widget> buttons, {bool border = true, double gap = 8, double top = 0}) =>
      Container(
        margin: EdgeInsets.only(top: top),
        padding: EdgeInsets.only(top: border ? 16 : 0),
        decoration: border ? BoxDecoration(border: Border(top: BorderSide(color: _borderColor(context)))) : null,
        child: Wrap(
          alignment: WrapAlignment.end,
          spacing: gap,
          runSpacing: 8,
          children: buttons,
        ),
      );

  Widget _gapColumn(List<Widget> children, double gap) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            children[i],
          ],
        ],
      );

  /// Attachment Title / Content Type / HTML · PDF · URL fields.
  List<Widget> _contentFields(
    BuildContext context,
    _ActivityForm f, {
    required double width,
    required String keyPrefix,
    bool htmlLabel = false,
    String urlHint = 'Enter URL',
  }) {
    final typeSelect = AppSelect<String>(
      value: f.type.isEmpty ? null : f.type,
      placeholder: 'Select content type',
      items: const [AppSelectItem('html', 'HTML'), AppSelectItem('pdf', 'PDF'), AppSelectItem('url', 'URL')],
      onChanged: (v) => _set(() => f.type = v ?? ''),
    );
    final gap = width == 320 ? 4.0 : 8.0;
    return [
      _fixedWidth(
        context,
        width,
        _labeled('Attachment Title', gap: gap, AppTextField(controller: f.title, hint: 'Enter attachment title')),
      ),
      _fixedWidth(context, width, _labeled('Content Type', gap: gap, typeSelect)),
      if (f.type == 'html')
        () {
          final editor = HtmlEditor(
            key: ValueKey('$keyPrefix-${f.version}'),
            initialHtml: f.content,
            onChanged: (v) => f.content = v,
          );
          return htmlLabel ? _labeled('HTML Content', gap: 4, editor) : editor;
        }()
      else if (f.type == 'pdf')
        _fixedWidth(
          context,
          width == 320 ? 320 : double.infinity,
          _labeled(
            'Choose PDF File',
            gap: width == 320 ? 4 : 0,
            FilePickField(onPick: () => _pickPdf(f), fileName: f.file?.name),
          ),
        )
      else if (f.type == 'url')
        _fixedWidth(
          context,
          width == 320 ? 320 : double.infinity,
          _labeled(
            'Attachment URL',
            gap: width == 320 ? 4 : 0,
            AppTextField(controller: f.url, hint: urlHint, keyboardType: TextInputType.url),
          ),
        ),
    ];
  }

  // ── class / home assignments ─────────────────────────────────────────────

  /// "Class Assignment" / "Add Home Assignments".
  Widget _buildActivityDialog(BuildContext context, {required bool home}) {
    final lms = home ? _isHomeActivityLms : _isClassActivityLms;
    final f = home ? _homeActivityForm : _classActivityForm;
    final dlg = home ? _Dlg.homeAct : _Dlg.classAct;
    void toggle() => _set(() {
          if (home) {
            _isHomeActivityLms = !_isHomeActivityLms;
          } else {
            _isClassActivityLms = !_isClassActivityLms;
          }
        });
    final Widget body;
    if (lms) {
      body = _gapColumn([
        _lmsSelect(context, home ? _selectedHomeActivityLms : _selectedClassActivityLms, (v) {
          _set(() {
            if (home) {
              _selectedHomeActivityLms = v;
            } else {
              _selectedClassActivityLms = v;
            }
          });
        }),
        _footer(context, [
          AppButton(
            label: 'Back',
            variant: AppButtonVariant.outline,
            onPressed: () => _set(() {
              if (home) {
                _isHomeActivityLms = false;
              } else {
                _isClassActivityLms = false;
              }
            }),
          ),
          AppButton(label: 'Submit', onPressed: () => _submitActivity(home: home)),
        ], gap: 12),
      ], 16);
    } else {
      body = _gapColumn([
        ..._contentFields(context, f, width: 288, keyPrefix: home ? 'home' : 'class'),
        _footer(context, [
          AppButton(label: 'Cancel', variant: AppButtonVariant.outline, onPressed: () => _closeDialog(dlg)),
          AppButton(label: 'Submit', onPressed: () => _submitActivity(home: home)),
        ], border: !home, top: home ? 8 : 0),
      ], home ? 8 : 16);
    }
    return AppDialogFrame(
      maxWidth: 896,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _lmsHeader(context, home ? 'Add Home Assignments' : 'Class Assignment', lms, toggle),
          body,
        ],
      ),
    );
  }

  /// "Edit Class Assignment" / "Home Assignment" (edit).
  Widget _buildEditActivityDialog(BuildContext context, {required bool home}) {
    final lms = home ? _isHomeActivityLms : _isClassActivityLms;
    final f = home ? _homeActivityForm : _classActivityForm;
    final dlg = home ? _Dlg.editHomeAct : _Dlg.editClassAct;
    void toggle() => _set(() {
          if (home) {
            _isHomeActivityLms = !_isHomeActivityLms;
          } else {
            _isClassActivityLms = !_isClassActivityLms;
          }
        });
    final buttons = [
      AppButton(label: 'Cancel', variant: AppButtonVariant.outline, onPressed: () => _closeDialog(dlg)),
      AppButton(label: 'Update', onPressed: () => _updateActivity(home: home)),
    ];
    final Widget body = lms
        ? _gapColumn([
            _lmsSelect(context, home ? _selectedHomeActivityLms : _selectedClassActivityLms, (v) {
              _set(() {
                if (home) {
                  _selectedHomeActivityLms = v;
                } else {
                  _selectedClassActivityLms = v;
                }
              });
            }),
            _footer(context, buttons, gap: 12),
          ], 16)
        : _gapColumn([
            ..._contentFields(context, f, width: 288, keyPrefix: home ? 'edit-home' : 'edit-class'),
            _footer(context, buttons),
          ], 16);
    return AppDialogFrame(
      maxWidth: 896,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _lmsHeader(context, home ? 'Home Assignment' : 'Edit Class Assignment', lms, toggle),
          body,
        ],
      ),
    );
  }

  // ── class references ─────────────────────────────────────────────────────

  Widget _referenceDialog(
    BuildContext context, {
    required String title,
    required _Dlg dlg,
    required String actionLabel,
    required VoidCallback onAction,
    required String keyPrefix,
  }) {
    final Widget body = _isLmsMode
        ? _gapColumn([
            _lmsSelect(context, _selectedLmsContent, (v) => _set(() => _selectedLmsContent = v)),
            _footer(context, [
              AppButton(
                label: 'Back',
                variant: AppButtonVariant.outline,
                onPressed: () => _set(() => _isLmsMode = false),
              ),
              AppButton(label: actionLabel, onPressed: onAction),
            ], gap: 12),
          ], 16)
        : _gapColumn([
            ..._contentFields(
              context,
              _classReferenceForm,
              width: 320,
              keyPrefix: keyPrefix,
              htmlLabel: true,
              urlHint: 'Enter a valid URL (https://example.com)',
            ),
            _footer(context, [
              AppButton(label: 'Cancel', variant: AppButtonVariant.outline, onPressed: () => _closeDialog(dlg)),
              AppButton(label: actionLabel, onPressed: onAction),
            ], gap: 12),
          ], 20);
    return AppDialogFrame(
      maxWidth: 896,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _lmsHeader(context, title, _isLmsMode, () => _set(() => _isLmsMode = !_isLmsMode), bottom: 40),
          body,
        ],
      ),
    );
  }

  /// "Class Reference" (create).
  Widget _buildClassReferenceDialog(BuildContext context) => _referenceDialog(
        context,
        title: 'Class Reference',
        dlg: _Dlg.classRef,
        actionLabel: 'Submit',
        onAction: _submitClassReference,
        keyPrefix: 'ref',
      );

  /// "Edit Class Reference"
  Widget _buildEditClassReferenceDialog(BuildContext context) => _referenceDialog(
        context,
        title: 'Edit Class Reference',
        dlg: _Dlg.editClassRef,
        actionLabel: 'Update',
        onAction: _updateClassReference,
        keyPrefix: 'edit-ref',
      );

  // ── view ─────────────────────────────────────────────────────────────────

  /// "View Class Reference" / "View Class Assignments" / "View Home Assignments".
  Widget _buildViewDialog(BuildContext context, String header, _Viewed? viewed, bool reference) => AppDialogFrame(
        maxWidth: 1152,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // `<DialogHeader>` holding plain text, then the dialog's `gap-4`.
            _dialogHeader(context, header, plain: true),
            const SizedBox(height: 16),
            if (viewed != null) _viewBody(context, viewed, reference: reference),
          ],
        ),
      );

  Widget _viewBody(BuildContext context, _Viewed v, {required bool reference}) {
    final h = MediaQuery.sizeOf(context).height;
    Widget framed(double height, Widget child, {bool border = true}) => Container(
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            border: border ? Border.all(color: _borderColor(context)) : null,
          ),
          child: child,
        );
    if (v.type == 'html') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: framed(h * 0.7, WebContentView(html: _previewHtml(v.content)), border: false),
      );
    }
    if (v.type == 'url') {
      final url = v.url;
      if (isImageUrl(url)) {
        // `w-full max-h-[80vh] object-contain` (+ `rounded` on assignments).
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: h * 0.8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(reference ? 0 : 4),
            child: Image.network(url, fit: BoxFit.contain, errorBuilder: (_, _, _) => const SizedBox.shrink()),
          ),
        );
      }
      if (isVideoUrl(url)) {
        return framed(
          h * 0.7,
          WebContentView(
            html: '<video controls style="width:100%;max-height:95vh;border-radius:4px">'
                '<source src="${_attr(url)}"></video>',
          ),
          border: false,
        );
      }
      if (isYouTubeUrl(url)) {
        return framed(h * 0.7, WebContentView(url: 'https://www.youtube.com/embed/${youTubeId(url)}'), border: false);
      }
      if (isVimeoUrl(url)) {
        return framed(h * 0.7, WebContentView(url: 'https://player.vimeo.com/video/${vimeoId(url)}'), border: false);
      }
      if (isPdfUrl(url)) return framed(h * 0.8, WebContentView(url: pdfFrameUrl(url), showOpenExternally: true));
      if (canEmbedUrl(url)) return framed(h * 0.8, WebContentView(url: url, showOpenExternally: true));
      final link = InkWell(
        onTap: () => openExternal(url),
        child: Text(
          reference ? 'Open' : 'Open in new tab',
          style: const TextStyle(color: Tw.blue600, decoration: TextDecoration.underline, decorationColor: Tw.blue600),
        ),
      );
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: reference
            ? Wrap(
                alignment: WrapAlignment.center,
                children: [const Text('Cannot preview this content. '), link],
              )
            : Column(children: [const Text('Cannot preview this website.'), link]),
      );
    }
    if (v.type == 'pdf') return framed(h * 0.8, WebContentView(url: pdfFrameUrl(v.url), showOpenExternally: true));
    return const Text('No preview available');
  }

  // ── quiz ─────────────────────────────────────────────────────────────────

  /// `<scheduleexam :schedule-id :batch-id :course-id @close>` in an
  /// `h-[80%] w-screen` dialog (the view scrolls inside the bounded box).
  Widget _buildQuizDialog(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return AppDialogFrame(
      maxWidth: size.width,
      child: SizedBox(
        height: math.max(200, size.height * 0.8 - 48),
        child: ScheduleExamView(
          scheduleId: _activeScheduleId ?? 'null',
          batchId: _examactiveBatchId,
          courseId: _examactiveCourseId,
          onClose: () => _closeDialog(_Dlg.quiz),
        ),
      ),
    );
  }

  // ── delete confirmation ──────────────────────────────────────────────────

  Widget _buildDeleteConfirmDialog(BuildContext context) => AppDialogFrame(
        maxWidth: 448,
        actions: [
          AppButton(label: 'Cancel', variant: AppButtonVariant.outline, onPressed: () => _closeDialog(_Dlg.deleteConfirm)),
          AppButton(
            label: 'Delete',
            backgroundColor: Tw.red600,
            foregroundColor: Colors.white,
            onPressed: _confirmDelete,
          ),
        ],
        // The header, then the footer's `mt-4` + the dialog's `gap-4`.
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _dialogHeader(
            context,
            _deleteConfirm.title,
            description: _deleteConfirm.message,
            titleColor: Tw.red600,
          ),
        ),
      );
}

String _attr(String v) => v.replaceAll('&', '&amp;').replaceAll('"', '&quot;').replaceAll('<', '&lt;');

/// `<div class="preview" v-html>` with the `.preview` heading / paragraph
/// styles of style.css.
String _previewHtml(String content) => '''
<style>
.preview h1{font-size:28px;font-weight:700;line-height:1.2;margin:.67em 0}
.preview h2{font-size:24px;font-weight:700;line-height:1.25;margin:.67em 0}
.preview h3{font-size:20px;font-weight:700;line-height:1.3;margin:.67em 0}
.preview h4{font-size:18px;font-weight:700;line-height:1.3;margin:.67em 0}
.preview h5{font-size:16px;font-weight:700;line-height:1.35;margin:.67em 0}
.preview h6{font-size:14px;font-weight:700;line-height:1.35;margin:.67em 0}
.preview p{font-size:15px;line-height:1.6}
.preview ul,.preview ol{padding-left:1.5rem;margin:.5rem 0}
</style>
<div class="preview">$content</div>''';
