part of 'teacher_schedules_page.dart';

/// Class reference / class assignment / home assignment dialogs (create,
/// edit, view), the quiz dialog and the delete confirmation.
extension _ContentDialogs on _TeacherSchedulesPageState {
  // ── openers ──────────────────────────────────────────────────────────────

  /// `openQuizDialog()` + `watch: isQuizDialogOpen(false)`.
  void _openQuizDialog() => _openDialog('quiz', _buildQuizDialog, onClosed: () {
        _fetchExam();
        _fetchBasicInfo(jsString(_activeScheduleId));
      });

  /// `openClassReferenceDialog()` — `isLmsMode` is kept, like the web.
  void _openClassReferenceDialog() {
    _set(() {
      _classReferenceForm.reset();
      _selectedReferenceId = null;
    });
    _openDialog('classRef', _buildClassReferenceDialog);
  }

  /// `openClassActivityDialog()`
  void _openClassActivityDialog() {
    _set(() {
      _isClassActivityLms = false;
      _selectedClassActivityLms = '';
      _classActivityForm.reset();
      _selectedReferenceId = null;
    });
    _openDialog('classAct', _buildClassActivityDialog);
  }

  Object? _lmsName(Object? id) =>
      _classCoursesDropdown.map(asMap).where((c) => c != null && c['id'] == id).firstOrNull?['name'];

  /// `<Input type="file" accept="application/pdf">`. [clearOnCancel] mirrors
  /// `handleClassReferenceFile` (`files?.[0] || null`); the activity handlers
  /// only assign when a file was picked.
  Future<void> _pickPdf(_ContentForm form, {bool clearOnCancel = false}) async {
    final file = await pickUploadFile(allowedExtensions: const ['pdf']);
    if (file != null || clearOnCancel) _set(() => form.file = file);
  }

  // ── class reference ──────────────────────────────────────────────────────

  /// `submitClassReference()`
  Future<void> _submitClassReference() async {
    try {
      if (_isLmsMode) {
        await _ctrl.createScheduleReferenceActivity({
          'schedule_id': jsString(_activeScheduleId),
          'content_id': _selectedLmsContent,
          'name': orJs(_lmsName(_selectedLmsContent), 'LMS Content'),
          'type': 'course_content',
        });
        _closeDialog('classRef');
        _set(() {
          _isLmsMode = false;
          _selectedLmsContent = '';
        });
        await _fetchBasicInfo(jsString(_activeScheduleId));
        return;
      }
      final f = _classReferenceForm;
      final payload = <String, dynamic>{'schedule_id': _activeScheduleId, 'name': f.title.text, 'type': f.type};
      if (f.type == 'html') payload['html_content'] = f.content;
      if (f.type == 'url') payload['url'] = f.url.text;
      if (f.type == 'pdf') {
        if (f.file == null) {
          AppToast.error('Please select a PDF file!');
          return;
        }
        payload['file'] = f.file;
      }
      final res = await _ctrl.createScheduleReferenceActivity(payload);
      final created = asMap(res);
      if (created != null) _set(() => _classreference = [created, ..._classreference]);
      await _fetchBasicInfo(jsString(_activeScheduleId));
      _closeDialog('classRef');
      _set(() => _isLmsMode = false);
    } catch (_) {}
  }

  /// `viewClassReference(ref)`
  void _viewClassReference(Json ref) {
    _set(() => _viewedReference = viewableContent(ref));
    _openDialog('viewClassRef', (ctx) => _buildViewDialog('View Class Reference', _viewedReference, 'Open'));
  }

  /// `editClassReference(ref)`
  void _editClassReference(Json ref) {
    _set(() {
      _isLmsMode = ref['type'] == 'course_content';
      if (_isLmsMode) {
        _selectedLmsContent = lmsContentIdOf(ref);
      } else {
        _classReferenceForm.reset(
          title: '${orJs(ref['name'], '')}',
          type: '${orJs(ref['type'], 'html')}',
          content: '${orJs(ref['content'], '')}',
          url: '${orJs(ref['url'], '')}',
        );
      }
      _selectedReferenceId = ref['id'];
    });
    _openDialog('editClassRef', _buildEditClassReferenceDialog);
  }

  /// `updateClassReference()`
  Future<void> _updateClassReference() async {
    if (!jsTruthy(_selectedReferenceId)) {
      AppToast.error('Reference ID missing!');
      return;
    }
    if (!jsTruthy(_activeScheduleId)) {
      AppToast.error('Schedule ID missing!');
      return;
    }
    _set(() => _isLoading = true);
    try {
      if (_isLmsMode) {
        await _ctrl.updateScheduleReference(jsString(_selectedReferenceId), {
          'schedule_id': jsString(_activeScheduleId),
          'name': orJs(_lmsName(_selectedLmsContent), 'LMS Content'),
          'type': 'course_content',
          'content_id': _selectedLmsContent,
        });
        _closeDialog('editClassRef');
        _set(() {
          _isLmsMode = false;
          _selectedLmsContent = '';
        });
      } else {
        final f = _classReferenceForm;
        final payload = <String, dynamic>{
          'schedule_id': jsString(_activeScheduleId),
          'name': f.title.text,
          'type': f.type,
        };
        if (f.type == 'html') payload['html_content'] = f.content;
        if (f.type == 'url') payload['url'] = f.url.text;
        if (f.type == 'pdf') {
          if (f.file == null) {
            AppToast.error('Please select a PDF file!');
            _set(() => _isLoading = false);
            return;
          }
          payload['file'] = f.file;
        }
        await _ctrl.updateScheduleReference(jsString(_selectedReferenceId), payload);
        _closeDialog('editClassRef');
      }
      await _fetchBasicInfo(jsString(_activeScheduleId));
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  // ── class / home assignments ─────────────────────────────────────────────

  /// `submitClassActivity()` / `submitHomeActivity()`
  Future<void> _submitActivity({required bool home}) async {
    if (!jsTruthy(_activeScheduleId)) {
      AppToast.error('Schedule ID is missing!');
      return;
    }
    final lms = home ? _isHomeActivityLms : _isClassActivityLms;
    final form = home ? _homeActivityForm : _classActivityForm;
    final dialog = home ? 'homeAct' : 'classAct';
    _set(() => _isLoading = true);
    try {
      if (lms) {
        final selected = home ? _selectedHomeActivityLms : _selectedClassActivityLms;
        await _ctrl.createScheduleActivity({
          'schedule_id': jsString(_activeScheduleId),
          'activity_type': home ? 'home' : 'class',
          'content_id': selected,
          'name': orJs(_lmsName(selected), 'LMS Content'),
          'type': 'course_content',
        });
        _set(() {
          if (home) {
            _isHomeActivityLms = false;
            _selectedHomeActivityLms = '';
          } else {
            _isClassActivityLms = false;
            _selectedClassActivityLms = '';
          }
        });
        _closeDialog(dialog);
      } else {
        final payload = <String, dynamic>{
          'schedule_id': jsString(_activeScheduleId),
          'activity_type': home ? 'home' : 'class',
          'name': form.title.text,
          'type': form.type,
        };
        if (form.type == 'html') payload['html_content'] = form.content;
        if (form.type == 'pdf') {
          if (form.file == null) {
            AppToast.error('Please select a PDF file.');
            return;
          }
          payload['file'] = form.file;
        }
        if (form.type == 'url') payload['url'] = form.url.text;
        await _ctrl.createScheduleActivity(payload);
        _set(form.reset);
        _closeDialog(dialog);
      }
      await _fetchBasicInfo(jsString(_activeScheduleId));
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  /// `viewClassAct(item)` / `viewHomeAct(item)`
  void _viewClassAct(Json item) {
    _set(() => _viewedActivity = viewableContent(item));
    _openDialog('viewClassAct', (ctx) => _buildViewDialog('View Class Assignment', _viewedActivity, 'Open in new tab'));
  }

  void _viewHomeAct(Json item) {
    _set(() => _viewedActivity = viewableContent(item));
    _openDialog('viewHomeAct', (ctx) => _buildViewDialog('View Home Assignment', _viewedActivity, 'Open in new tab'));
  }

  /// `editClassActivity(activity)` / `editHomeActivity(activity)` — LMS
  /// items reload the class (`getcourses(classDetails.id || 0)`) first.
  Future<void> _editActivity(Json activity, {required bool home}) async {
    final lms = activity['type'] == 'course_content';
    _set(() {
      _selectedReferenceId = activity['id'];
      if (home) {
        _isHomeActivityLms = lms;
      } else {
        _isClassActivityLms = lms;
      }
    });
    if (lms) {
      _set(() {
        if (home) {
          _selectedHomeActivityLms = lmsContentIdOf(activity);
        } else {
          _selectedClassActivityLms = lmsContentIdOf(activity);
        }
      });
      try {
        await _ctrl.fetchschedulesClassDetails(orJs(_session.classDetails?.id, 0) ?? 0);
      } catch (_) {
        return;
      }
    } else {
      _set(() => (home ? _homeActivityForm : _classActivityForm).reset(
            title: '${orJs(activity['name'], '')}',
            type: '${orJs(activity['type'], 'html')}',
            content: '${orJs(activity['content'], '')}',
            url: '${orJs(activity['url'], '')}',
          ));
    }
    if (home) {
      _openDialog('editHomeAct', _buildEditHomeActivityDialog);
    } else {
      _openDialog('editClassAct', _buildEditClassActivityDialog);
    }
  }

  void _editClassActivity(Json a) => _editActivity(a, home: false);
  void _editHomeActivity(Json a) => _editActivity(a, home: true);

  /// `updateClassActivity()` / `updateHomeActivity()`
  Future<void> _updateActivity({required bool home}) async {
    if (!jsTruthy(_selectedReferenceId)) {
      AppToast.error('Activity ID missing!');
      return;
    }
    if (!jsTruthy(_activeScheduleId)) {
      AppToast.error('Schedule ID missing!');
      return;
    }
    final lms = home ? _isHomeActivityLms : _isClassActivityLms;
    final form = home ? _homeActivityForm : _classActivityForm;
    final dialog = home ? 'editHomeAct' : 'editClassAct';
    _set(() => _isLoading = true);
    try {
      if (lms) {
        final selected = home ? _selectedHomeActivityLms : _selectedClassActivityLms;
        await _ctrl.updateScheduleActivity(jsString(_selectedReferenceId), {
          'schedule_id': jsString(_activeScheduleId),
          'activity_type': home ? 'home' : 'class',
          'name': orJs(_lmsName(selected), 'LMS Content'),
          'type': 'course_content',
          'content_id': selected,
        });
        _closeDialog(dialog);
        _set(() {
          if (home) {
            _isHomeActivityLms = false;
            _selectedHomeActivityLms = '';
          } else {
            _isClassActivityLms = false;
            _selectedClassActivityLms = '';
          }
        });
      } else {
        final payload = <String, dynamic>{
          'schedule_id': jsString(_activeScheduleId),
          'activity_type': home ? 'home' : 'class',
          'name': form.title.text,
          'type': form.type,
        };
        if (form.type == 'html') payload['html_content'] = form.content;
        if (form.type == 'url') payload['url'] = form.url.text;
        if (form.type == 'pdf') {
          if (form.file == null) {
            AppToast.error('Please select a PDF file!');
            _set(() => _isLoading = false);
            return;
          }
          payload['file'] = form.file;
        }
        await _ctrl.updateScheduleActivity(jsString(_selectedReferenceId), payload);
        _closeDialog(dialog);
      }
      await _fetchBasicInfo(jsString(_activeScheduleId));
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  // ── dialog UI ────────────────────────────────────────────────────────────

  /// `text-sm font-semibold text-slate-500 hover:text-slate-900
  /// dark:hover:text-white` with a `text-2xl` toggle icon.
  Widget _lmsToggle(bool on, VoidCallback onTap) => TsHover(
        onTap: onTap,
        builder: (hover) => Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(on ? BootstrapIcons.toggle_on : BootstrapIcons.toggle_off,
              size: 24, color: on ? Tw.emerald500 : Tw.slate400),
          const SizedBox(width: 8),
          Text('Link to LMS',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: hover ? (context.isDark ? Colors.white : Tw.slate900) : Tw.slate500,
              )),
        ]),
      );

  Widget _dialogFooterRow(List<Widget> children) {
    final dark = context.isDark;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: dark ? Tw.slate700 : Tw.slate200))),
      child: Wrap(alignment: WrapAlignment.end, spacing: 12, runSpacing: 8, children: children),
    );
  }

  Widget _dialogPrimary(String label, VoidCallback onTap) =>
      TsButton(label: label, onPressed: onTap, hPad: 24, fontWeight: FontWeight.w700);

  /// `variant="ghost"` keeps the Button's `font-medium`.
  Widget _dialogSecondary(String label, VoidCallback onTap) =>
      TsButton.outlined(context, label: label, onPressed: onTap, filled: false, fontWeight: FontWeight.w500);

  /// The shared body of the six reference / assignment dialogs.
  Widget _contentDialog({
    required String dialogName,
    required String title,
    required bool lms,
    required VoidCallback onToggleLms,
    required Object? lmsValue,
    required ValueChanged<Object?> onLmsChanged,
    required String lmsLeftLabel,
    required VoidCallback onLmsLeft,
    required String submitLabel,
    required VoidCallback onSubmit,
    required _ContentForm form,
    required VoidCallback onCancel,
    required VoidCallback onPickPdf,
    String? titleHint,
    String? pdfLabel,
    String? urlLabel,
    String? urlHint,
  }) {
    final dark = context.isDark;
    // `<SelectItem :value="content.id">` — keyed by the id's text.
    final ids = <String, Object?>{
      for (final c in _classCoursesDropdown)
        if (asMap(c) != null) jsString(asMap(c)!['id']): asMap(c)!['id'],
    };
    final options = [
      for (final c in _classCoursesDropdown)
        if (asMap(c) != null) (jsString(asMap(c)!['id']), vueText(asMap(c)!['name'])),
    ];
    final lmsKey = jsTruthy(lmsValue) && ids.containsKey(jsString(lmsValue)) ? jsString(lmsValue) : null;
    final Widget body;
    if (lms) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TsField(
            label: const TsLabel('Select LMS Content'),
            child: TsSelect(
              value: lmsKey,
              placeholder: 'Choose from LMS content',
              items: options,
              onChanged: (k) => onLmsChanged(ids[k]),
            ),
          ),
          _dialogFooterRow([_dialogSecondary(lmsLeftLabel, onLmsLeft), _dialogPrimary(submitLabel, onSubmit)]),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TsField(
            label: const TsLabel('Attachment Title'),
            child: _plainInput(form.title, hint: titleHint),
          ),
          const SizedBox(height: 16),
          TsField(
            label: const TsLabel('Content Type'),
            child: TsSelect(
              value: const ['html', 'pdf', 'url'].contains(form.type) ? form.type : null,
              placeholder: 'Select content type',
              items: const [('html', 'HTML'), ('pdf', 'PDF'), ('url', 'URL')],
              onChanged: (v) => _set(() => form.type = v),
            ),
          ),
          if (form.type == 'html') ...[
            const SizedBox(height: 16),
            HtmlEditor(
              key: ValueKey('$dialogName-html'),
              initialHtml: form.content,
              onChanged: (html) => form.content = html,
            ),
          ] else if (form.type == 'pdf') ...[
            const SizedBox(height: 16),
            if (pdfLabel != null) ...[TsLabel(pdfLabel), const SizedBox(height: 6)],
            FilePickField(onPick: onPickPdf, fileName: form.file?.name),
          ] else if (form.type == 'url') ...[
            const SizedBox(height: 16),
            if (urlLabel != null) ...[TsLabel(urlLabel), const SizedBox(height: 6)],
            _plainInput(form.url, hint: urlHint, keyboardType: TextInputType.url),
          ],
          _dialogFooterRow([_dialogSecondary('Cancel', onCancel), _dialogPrimary(submitLabel, onSubmit)]),
        ],
      );
    }
    // `sm:max-w-2xl`; the title row is `justify-between`, so on wide dialogs
    // "Link to LMS" sits under the close ✕ (as on the web). `DialogHeader
    // mb-4` + the content's `gap-4` = 32 px.
    return TsDialogFrame(
      maxWidth: 672,
      child: TsInputTheme(
        fill: dark ? Tw.slate900 : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 32),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 12,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 20,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          color: dark ? Colors.white : Tw.slate900)),
                  _lmsToggle(lms, onToggleLms),
                ],
              ),
            ),
            body,
          ],
        ),
      ),
    );
  }

  Widget _buildClassReferenceDialog(BuildContext ctx) => _contentDialog(
        dialogName: 'classRef',
        title: 'Class Reference',
        lms: _isLmsMode,
        onToggleLms: () => _set(() => _isLmsMode = !_isLmsMode),
        lmsValue: _selectedLmsContent,
        onLmsChanged: (v) => _set(() => _selectedLmsContent = v),
        lmsLeftLabel: 'Back',
        onLmsLeft: () => _set(() => _isLmsMode = false),
        submitLabel: 'Submit',
        onSubmit: _submitClassReference,
        form: _classReferenceForm,
        onCancel: () => _closeDialog('classRef'),
        onPickPdf: () => _pickPdf(_classReferenceForm, clearOnCancel: true),
        titleHint: 'Enter attachment title',
        pdfLabel: 'Choose PDF File',
        urlLabel: 'Attachment URL',
        urlHint: 'https://example.com',
      );

  Widget _buildEditClassReferenceDialog(BuildContext ctx) => _contentDialog(
        dialogName: 'editClassRef',
        title: 'Edit Class Reference',
        lms: _isLmsMode,
        onToggleLms: () => _set(() => _isLmsMode = !_isLmsMode),
        lmsValue: _selectedLmsContent,
        onLmsChanged: (v) => _set(() => _selectedLmsContent = v),
        lmsLeftLabel: 'Back',
        onLmsLeft: () => _set(() => _isLmsMode = false),
        submitLabel: 'Update',
        onSubmit: _updateClassReference,
        form: _classReferenceForm,
        onCancel: () => _closeDialog('editClassRef'),
        onPickPdf: () => _pickPdf(_classReferenceForm, clearOnCancel: true),
        pdfLabel: 'Choose PDF File',
        urlLabel: 'Attachment URL',
      );

  Widget _buildClassActivityDialog(BuildContext ctx) => _contentDialog(
        dialogName: 'classAct',
        title: 'Class Assignment',
        lms: _isClassActivityLms,
        onToggleLms: () => _set(() => _isClassActivityLms = !_isClassActivityLms),
        lmsValue: _selectedClassActivityLms,
        onLmsChanged: (v) => _set(() => _selectedClassActivityLms = v),
        lmsLeftLabel: 'Back',
        onLmsLeft: () => _set(() => _isClassActivityLms = false),
        submitLabel: 'Submit',
        onSubmit: () => _submitActivity(home: false),
        form: _classActivityForm,
        onCancel: () => _closeDialog('classAct'),
        onPickPdf: () => _pickPdf(_classActivityForm),
        titleHint: 'Enter attachment title',
        urlHint: 'Enter URL',
      );

  Widget _buildEditClassActivityDialog(BuildContext ctx) => _contentDialog(
        dialogName: 'editClassAct',
        title: 'Edit Class Assignment',
        lms: _isClassActivityLms,
        onToggleLms: () => _set(() => _isClassActivityLms = !_isClassActivityLms),
        lmsValue: _selectedClassActivityLms,
        onLmsChanged: (v) => _set(() => _selectedClassActivityLms = v),
        lmsLeftLabel: 'Cancel',
        onLmsLeft: () => _closeDialog('editClassAct'),
        submitLabel: 'Update',
        onSubmit: () => _updateActivity(home: false),
        form: _classActivityForm,
        onCancel: () => _closeDialog('editClassAct'),
        onPickPdf: () => _pickPdf(_classActivityForm),
      );

  Widget _buildHomeActivityDialog(BuildContext ctx) => _contentDialog(
        dialogName: 'homeAct',
        title: 'Add Home Assignment',
        lms: _isHomeActivityLms,
        onToggleLms: () => _set(() => _isHomeActivityLms = !_isHomeActivityLms),
        lmsValue: _selectedHomeActivityLms,
        onLmsChanged: (v) => _set(() => _selectedHomeActivityLms = v),
        lmsLeftLabel: 'Back',
        onLmsLeft: () => _set(() => _isHomeActivityLms = false),
        submitLabel: 'Submit',
        onSubmit: () => _submitActivity(home: true),
        form: _homeActivityForm,
        onCancel: () => _closeDialog('homeAct'),
        onPickPdf: () => _pickPdf(_homeActivityForm),
      );

  Widget _buildEditHomeActivityDialog(BuildContext ctx) => _contentDialog(
        dialogName: 'editHomeAct',
        title: 'Edit Home Assignment',
        lms: _isHomeActivityLms,
        onToggleLms: () => _set(() => _isHomeActivityLms = !_isHomeActivityLms),
        lmsValue: _selectedHomeActivityLms,
        onLmsChanged: (v) => _set(() => _selectedHomeActivityLms = v),
        lmsLeftLabel: 'Cancel',
        onLmsLeft: () => _closeDialog('editHomeAct'),
        submitLabel: 'Update',
        onSubmit: () => _updateActivity(home: true),
        form: _homeActivityForm,
        onCancel: () => _closeDialog('editHomeAct'),
        onPickPdf: () => _pickPdf(_homeActivityForm),
      );

  // ── view dialogs ─────────────────────────────────────────────────────────

  Widget _buildViewDialog(String title, ({String type, String url, String content})? viewed, String openLabel) {
    final h = MediaQuery.sizeOf(context).height;
    Widget box(Widget child, double height, {bool border = false}) => Container(
          height: height,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: border ? Border.all(color: Tw.slate200) : null,
          ),
          child: child,
        );
    Widget? content;
    if (viewed != null) {
      final url = viewed.url;
      if (viewed.type == 'html') {
        // `<div class="preview" v-html>` → rendered in a web view.
        content = Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: box(WebContentView(html: viewed.content), h * 0.6),
        );
      } else if (viewed.type == 'url') {
        if (isImageUrl(url)) {
          content = ConstrainedBox(
            constraints: BoxConstraints(maxHeight: h * 0.7),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(url,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const Icon(BootstrapIcons.image, size: 30, color: Tw.slate400)),
            ),
          );
        } else if (isVideoUrl(url)) {
          content = box(
            WebContentView(
              html: '<video controls style="width:100%;max-height:96vh"><source src="${_htmlAttr(url)}"></video>',
            ),
            h * 0.6,
          );
        } else if (isYouTubeUrl(url)) {
          content = box(WebContentView(url: 'https://www.youtube.com/embed/${youTubeId(url)}'), h * 0.6);
        } else if (isPdfUrl(url)) {
          content = box(WebContentView(url: '$url#toolbar=0', showOpenExternally: true), h * 0.7, border: true);
        } else {
          content = Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text.rich(
              TextSpan(children: [
                const TextSpan(text: 'Cannot preview. '),
                WidgetSpan(
                  alignment: PlaceholderAlignment.baseline,
                  baseline: TextBaseline.alphabetic,
                  child: InkWell(
                    onTap: () => openExternal(url),
                    child: Text(openLabel,
                        style: const TextStyle(
                            fontSize: 16,
                            color: TsTw.cyan600,
                            decoration: TextDecoration.underline,
                            decorationColor: TsTw.cyan600)),
                  ),
                ),
              ]),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          );
        }
      } else if (viewed.type == 'pdf') {
        content = box(WebContentView(url: '$url#toolbar=0', showOpenExternally: true), h * 0.7, border: true);
      }
    }
    final dark = context.isDark;
    // `sm:max-w-4xl`, border not overridden (`border-white/40
    // dark:border-slate-800/80`); `DialogHeader` centres the title below
    // 640 px; `gap-4` + `mt-4` above the content.
    return TsDialogFrame(
      maxWidth: 896,
      borderColor: dark ? Tw.slate800.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(title,
              textAlign: context.isSm ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                  fontSize: 20, height: 1, fontWeight: FontWeight.w700, color: dark ? Colors.white : Tw.slate900)),
          if (content != null) ...[const SizedBox(height: 32), content],
        ],
      ),
    );
  }

  /// `<Input class="h-11 text-base rounded-xl">` (border-input, transparent).
  Widget _plainInput(TextEditingController controller, {String? hint, TextInputType? keyboardType}) => TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: tsInputFontSize(context)),
        decoration: InputDecoration(hintText: hint),
      );

  static String _htmlAttr(String s) => s.replaceAll('&', '&amp;').replaceAll('"', '&quot;');

  // ── quiz ─────────────────────────────────────────────────────────────────

  /// `w-[calc(100vw-1rem)] max-w-screen-lg` — shadcn's `sm:max-w-lg` still
  /// wins from 640 px, so the dialog is 512 wide there.
  Widget _buildQuizDialog(BuildContext ctx) => TsDialogFrame(
        maxWidth: context.isSm ? 512 : 1024,
        horizontalInset: 8,
        borderColor: context.isDark ? Tw.slate800.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.4),
        child: ScheduleExamView(
          scheduleId: _activeScheduleId ?? '',
          batchId: _examactiveBatchId,
          courseId: _examactiveCourseId,
          onClose: () => _closeDialog('quiz'),
        ),
      );

  // ── delete confirmation ──────────────────────────────────────────────────

  Widget _buildDeleteDialog(BuildContext ctx) {
    final dark = context.isDark;
    // `max-w-sm`, but shadcn's `sm:max-w-lg` wins from 640 px.
    return TsDialogShell(
      maxWidth: context.isSm ? 512 : 384,
      headerColor: dark ? TsTw.rose900.withValues(alpha: 0.1) : Tw.rose50,
      header: Row(children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: dark ? TsTw.rose900.withValues(alpha: 0.3) : TsTw.rose100,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(BootstrapIcons.exclamation_triangle_fill, size: 20, color: Tw.rose500),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text(_deleteTitle,
                style: TextStyle(
                    fontSize: 18, height: 1.25, fontWeight: FontWeight.w700, color: dark ? TsTw.rose400 : Tw.rose600)),
            const SizedBox(height: 2),
            const Text('This action cannot be undone.', style: TextStyle(fontSize: 16, color: Tw.slate500)),
          ]),
        ),
      ]),
      body: Text(_deleteMessage,
          style: TextStyle(fontSize: 16, height: 1.6, color: dark ? Tw.slate300 : Tw.slate600)),
      footer: [
        TsButton.outlined(context, label: 'Cancel', onPressed: () => _closeDialog('delete'), filled: false),
        TsButton(
          label: 'Delete',
          icon: BootstrapIcons.trash,
          onPressed: _confirmDelete,
          color: Tw.rose500,
          hoverColor: Tw.rose600,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}
