part of 'course_list_view.dart';

/// The component's dialogs (curriculum, section, chapter, concept CRUD,
/// detach / delete confirmations, concept preview). Each is opened with
/// [_CourseListViewState._showDialog] and rebuilt on every `_set`.
///
/// `<DialogContent>` is a `grid gap-4`, so every child's `mt-*` adds to a
/// 16px gap (a field with `mt-4` sits 32px below the previous one).
extension _DialogsUi on _CourseListViewState {
  /// `max-w-md` from the template loses to the kit's `sm:max-w-lg` on ≥640px.
  double get _mdDialogWidth => context.isSm ? 512 : 448;

  /// Header + fields + Cancel / submit (footer `mt-5`).
  Widget _formDialog(
    BuildContext ctx, {
    required Widget header,
    required List<Widget> fields,
    required Widget submit,
    double? maxWidth,
  }) => AppDialogFrame(
    maxWidth: maxWidth ?? _mdDialogWidth,
    actions: [_cancelButton(_closer(ctx)), submit],
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [header, ...fields, const SizedBox(height: 20)],
    ),
  );

  /// Delete / detach confirmation (`max-w-md`).
  Widget _dangerDialog(
    BuildContext ctx, {
    required IconData icon,
    required String title,
    required InlineSpan description,
    required IconData confirmIcon,
    required String confirmLabel,
    required VoidCallback onConfirm,
  }) => AppDialogFrame(
    maxWidth: _mdDialogWidth,
    actions: [
      _cancelButton(_closer(ctx)),
      _dangerButton(icon: confirmIcon, label: confirmLabel, onPressed: onConfirm),
    ],
    child: _DangerBody(icon: icon, title: title, description: description),
  );

  _DialogHeader _header(IconData icon, String title, {Color? color, Color? bg}) {
    final primary = context.colors.primary;
    return _DialogHeader(
      icon: icon,
      title: title,
      iconColor: color ?? primary,
      iconBg: bg ?? primary.withValues(alpha: 0.1),
    );
  }

  /// `bg-amber-100 dark:bg-amber-500/10` + `text-amber-600 dark:text-amber-400`
  _DialogHeader _amberHeader(IconData icon, String title) => _header(
    icon,
    title,
    color: context.isDark ? Tw.amber400 : Tw.amber600,
    bg: context.isDark ? Tw.amber500.withValues(alpha: 0.1) : _CC.amber100,
  );

  /// `<div class="mt-3 …"><label>Order</label><input placeholder="e.g. 1">`
  Widget _orderInput(TextEditingController controller) => _LabeledInput(
    label: 'Order',
    child: _WebInput(controller: controller, hint: 'e.g. 1'),
  );

  /// A `<Select>` / native `<select>` built from [_Dropdown] + [_OutlineTrigger].
  Widget _selectField({
    required String? value,
    required List<(String, String)> options,
    required ValueChanged<String> onChanged,
    String placeholder = '',
    String? disabledOption,
    double height = 36,
    double radius = 20,
    Color? background,
    Color? borderColor,
    List<BoxShadow>? shadow,
    TextStyle? textStyle,
    bool check = true,
  }) {
    final selected = options.where((o) => o.$1 == value).firstOrNull;
    return _Dropdown(
      items: [
        if (disabledOption != null)
          Opacity(
            opacity: 0.5,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Text(disabledOption, style: const TextStyle(fontSize: 14, height: 20 / 14)),
            ),
          ),
        for (final (v, label) in options)
          _menuItem(select: check, selected: v == value, onPressed: () => onChanged(v), child: Text(label)),
      ],
      trigger: (toggle, _) => _OutlineTrigger(
        onTap: toggle,
        button: false,
        spaceBetween: true,
        height: height,
        radius: radius,
        background: background,
        borderColor: borderColor,
        shadow: shadow,
        textStyle: textStyle,
        placeholder: selected == null,
        text: selected?.$2 ?? (value != null && value.isNotEmpty ? value : (disabledOption ?? placeholder)),
      ),
    );
  }

  // ── Curriculum ────────────────────────────────────────────────────────

  Widget _buildCurriculumCreateDialog(BuildContext ctx) => _formDialog(
    ctx,
    header: _header(BootstrapIcons.journal_plus, 'Create New Curriculum'),
    fields: [
      _LabeledInput(
        label: 'Curriculum Name',
        required: true,
        top: 32,
        child: _WebInput(controller: _newCurriculum, hint: 'Enter curriculum name'),
      ),
    ],
    submit: _SubmitButton(
      loading: _isCreateBtnLoading,
      icon: BootstrapIcons.check2,
      label: 'Create',
      loadingLabel: 'Creating...',
      onPressed: () => _fire(() => _createCurriculum(_closer(ctx))),
    ),
  );

  Widget _buildCurriculumUpdateDialog(BuildContext ctx) {
    final current = _cs.currentCurriculum;
    final status = asString(current['status']);
    return _formDialog(
      ctx,
      header: _amberHeader(BootstrapIcons.pencil_square, 'Edit Curriculum'),
      fields: [
        _LabeledInput(
          label: 'Curriculum Name',
          top: 32,
          child: _WebInput(
            controller: _curriculumName,
            hint: 'Enter curriculum name',
            onChanged: (v) => _ctrl.patchCurrentCurriculum({'name': v}),
          ),
        ),
        // `<SelectTrigger class="w-full rounded-xl">`
        _LabeledInput(
          label: 'Status',
          child: _selectField(
            value: status == null || status.isEmpty ? null : status,
            placeholder: 'Select status',
            options: const [('published', 'Published'), ('draft', 'UnPublished'), ('archived', 'Archived')],
            onChanged: (v) => _ctrl.patchCurrentCurriculum({'status': v}),
          ),
        ),
      ],
      submit: _SubmitButton(
        loading: _isCreateBtnLoading,
        icon: BootstrapIcons.check2,
        label: 'Save Changes',
        loadingLabel: 'Saving...',
        onPressed: () => _fire(() => _curriculumUpdate(_closer(ctx))),
      ),
    );
  }

  Widget _buildCurriculumDeleteDialog(BuildContext ctx) => _dangerDialog(
    ctx,
    icon: BootstrapIcons.exclamation_triangle,
    title: 'Delete Curriculum?',
    // The name `<span>` holds a trailing newline, hence `"name" ?`.
    description: TextSpan(
      children: [
        const TextSpan(text: 'Are you sure you want to delete '),
        _boldName(ctx, vText(_curriculumToDelete?['name'])),
        const TextSpan(text: ' ? This action cannot be undone.'),
      ],
    ),
    confirmIcon: BootstrapIcons.trash3,
    confirmLabel: 'Delete',
    onConfirm: () => _fire(() => _confirmDeleteCurriculum(_closer(ctx))),
  );

  // ── Detach ────────────────────────────────────────────────────────────

  Widget _buildDetachInstructorDialog(BuildContext ctx) => _dangerDialog(
    ctx,
    icon: BootstrapIcons.person_dash,
    title: 'Detach Instructor?',
    description: const TextSpan(text: 'Are you sure you want to detach this instructor from the course?'),
    confirmIcon: BootstrapIcons.person_dash,
    confirmLabel: 'Detach',
    onConfirm: () => _fire(() => _detachInstructor(_closer(ctx))),
  );

  Widget _buildDetachCurriculumDialog(BuildContext ctx) => _dangerDialog(
    ctx,
    icon: BootstrapIcons.journal_x,
    title: 'Detach Curriculum?',
    description: const TextSpan(text: 'Are you sure you want to detach this curriculum from the course?'),
    confirmIcon: BootstrapIcons.journal_x,
    confirmLabel: 'Detach',
    onConfirm: () => _fire(() => _detachCurriculum(_closer(ctx))),
  );

  // ── Section / chapter create ──────────────────────────────────────────

  Widget _buildChapterCreateDialog(BuildContext ctx) => _formDialog(
    ctx,
    header: _header(BootstrapIcons.collection, 'Create Chapter'),
    fields: [
      _LabeledInput(
        label: 'Chapter Name',
        required: true,
        top: 32,
        child: _WebInput(controller: _newChapter, hint: 'Enter chapter name'),
      ),
      _orderInput(_chapterOrder),
    ],
    submit: _SubmitButton(
      loading: _isCreateBtnLoading,
      icon: BootstrapIcons.plus_circle,
      label: 'Create',
      loadingLabel: 'Creating...',
      onPressed: () => _fire(() => _createChapter(_closer(ctx))),
    ),
  );

  Widget _buildSectionCreateDialog(BuildContext ctx) => _formDialog(
    ctx,
    header: _header(
      BootstrapIcons.layout_text_sidebar,
      'Create Section',
      color: context.isDark ? Tw.blue400 : Tw.blue600,
      bg: context.isDark ? Tw.blue500.withValues(alpha: 0.1) : Tw.blue100,
    ),
    fields: [
      _LabeledInput(
        label: 'Section Name',
        required: true,
        top: 32,
        child: _WebInput(controller: _newSection, hint: 'Enter section name'),
      ),
      _orderInput(_sectionOrder),
    ],
    submit: _SubmitButton(
      loading: _isCreateBtnLoading,
      icon: BootstrapIcons.plus_circle,
      label: 'Create',
      loadingLabel: 'Creating...',
      onPressed: () => _fire(() => _createSection(_closer(ctx))),
    ),
  );

  // ── Concept create ────────────────────────────────────────────────────

  Widget _buildContentCreateDialog(BuildContext ctx) {
    final dark = context.isDark;
    final form = _cs.contentForm;
    final type = asString(form['type']) ?? '';
    final file = form['file'];
    return _formDialog(
      ctx,
      maxWidth: 896,
      header: _header(
        BootstrapIcons.file_earmark_plus,
        'Create Concept',
        color: dark ? _CC.violet400 : Tw.violet600,
        bg: dark ? Tw.violet500.withValues(alpha: 0.1) : _CC.violet100,
      ),
      fields: [
        _LabeledInput(
          label: 'Concept Name',
          required: true,
          top: 32,
          child: _WebInput(
            controller: _contentName,
            hint: 'Enter concept name',
            maxLength: 255,
            onChanged: (v) => _ctrl.patchContentForm({'name': v}),
          ),
        ),
        _orderInput(_contentOrder),
        // Native `<select class="px-3 py-2.5 text-sm border-slate-200
        // dark:border-slate-700 rounded-xl bg-white dark:bg-primary-foreground
        // shadow-sm">`.
        _LabeledInput(
          label: 'Content Type',
          child: _selectField(
            value: type,
            disabledOption: 'Select content type',
            options: const [('html', 'HTML (Rich Text)'), ('pdf', 'PDF / File'), ('url', 'URL / Link')],
            onChanged: (v) => _ctrl.patchContentForm({'type': v}),
            height: 42,
            background: dark ? AppColors.darkPrimaryForeground : Colors.white,
            borderColor: dark ? Tw.slate700 : Tw.slate200,
            shadow: _CC.shadowSm,
            check: false,
          ),
        ),
        if (type == 'html')
          _LabeledInput(
            label: 'Content',
            top: 32,
            child: HtmlEditor(
              initialHtml: vText(form['html_content']),
              onChanged: (v) => _ctrl.patchContentForm({'html_content': v}),
            ),
          ),
        if (type == 'pdf')
          Padding(
            padding: const EdgeInsets.only(top: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                const _FieldLabel('Attach File'),
                const SizedBox(height: 8),
                // `flex flex-wrap items-center gap-3 p-3 border border-dashed
                // border-slate-200 dark:border-slate-800 rounded-xl
                // bg-slate-50/50 dark:bg-slate-800/30`
                _DashedBox(
                  color: dark ? Tw.slate800 : Tw.slate200,
                  fill: dark ? Tw.slate800.withValues(alpha: 0.3) : Tw.slate50.withValues(alpha: 0.5),
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      // `<label class="inline-flex items-center gap-2 bg-primary
                      // text-white text-sm px-4 py-2 rounded-lg hover:opacity-90">`
                      _Hover(
                        onTap: () => _fire(_onContentFileChange),
                        builder: (h) => Opacity(
                          opacity: h ? 0.9 : 1,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: context.colors.primary,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(BootstrapIcons.upload, size: 14, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Choose File',
                                  style: TextStyle(fontSize: 14, height: 20 / 14, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Text(
                        file is UploadFile ? file.name : 'No file chosen',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: dark ? Tw.slate400 : Tw.slate500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        if (type == 'url')
          _LabeledInput(
            label: 'URL',
            // `<i class="bi bi-link-45deg absolute left-3">` + `pl-8`.
            child: _WebInput(
              controller: _contentUrl,
              hint: 'https://...',
              prefixIcon: BootstrapIcons.link_45deg,
              textLeft: 32,
              padding: const EdgeInsets.fromLTRB(12, 10, 16, 10),
              onChanged: (v) => _ctrl.patchContentForm({'url': v}),
            ),
          ),
      ],
      submit: _SubmitButton(
        loading: _isCreateBtnLoading,
        icon: BootstrapIcons.plus_circle,
        label: 'Create',
        loadingLabel: 'Creating...',
        onPressed: () => _fire(() => _createContent(_closer(ctx))),
      ),
    );
  }

  // ── Concept preview ───────────────────────────────────────────────────

  Widget _buildContentPreviewDialog(BuildContext ctx) {
    final sm = context.isSm;
    final content = _selectedContent;
    final type = content?['type'];
    // Each body's own bottom margin (`mb-6`; the url box has none).
    final Widget body;
    if (type == 'html') {
      body = Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: SizedBox(
          height: _htmlHeight(context) * 0.8,
          child: WebContentView(html: vText(content?['content'])),
        ),
      );
    } else if (type == 'url') {
      body = _UrlPreviewBox(
        url: vText(content?['url']),
        maxWidth: 1200,
        // `h-[220px] xs:h-[280px] sm:h-[350px] md:h-[450px]`: the component's
        // unlayered `xs` rule (≥380px) beats the sm/md utilities.
        heights: const [220, 280, 280, 280, 280],
        blockedText: 'This website cannot be previewed.',
      );
    } else if (type == 'pdf') {
      body = Padding(padding: const EdgeInsets.only(bottom: 24), child: _pdfFrame(context, content?['url']));
    } else {
      body = const Padding(
        padding: EdgeInsets.only(bottom: 24),
        child: Text('No preview available', style: TextStyle(fontSize: 16, height: 1.5)),
      );
    }
    return AppDialogFrame(
      maxWidth: 1152,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // `<DialogHeader>` (`text-center sm:text-left`) > `<h3 class="text-lg
          // sm:text-xl font-semibold mb-4">`
          Padding(
            padding: EdgeInsets.only(bottom: 16, right: 28, left: sm ? 0 : 28),
            child: Text(
              vText(content?['name']),
              textAlign: sm ? TextAlign.left : TextAlign.center,
              style: TextStyle(fontSize: sm ? 20 : 18, height: 28 / (sm ? 20 : 18), fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          body,
          // grid `gap-4` + the button's `mt-6`.
          const SizedBox(height: 40),
          // `<Button class="px-6 py-2 mt-6 bg-blue-600 text-white rounded
          // hover:bg-blue-700 w-full sm:w-auto block mx-auto">`
          Center(
            child: SizedBox(
              width: sm ? null : double.infinity,
              child: _RoundedButton(
                label: 'Close',
                kind: _BtnKind.solid,
                background: Tw.blue600,
                hoverBackground: Tw.blue700,
                radius: 4,
                hPad: 24,
                onPressed: () => _closeContentDialog(_closer(ctx)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Deletes ───────────────────────────────────────────────────────────

  Widget _buildCourseDeleteDialog(BuildContext ctx) => _dangerDialog(
    ctx,
    icon: BootstrapIcons.exclamation_triangle,
    title: 'Delete Course?',
    description: TextSpan(
      children: [
        const TextSpan(text: 'Are you sure you want to delete '),
        _boldName(ctx, vText(_courseToDelete?['title'])),
        const TextSpan(text: '? This action cannot be undone.'),
      ],
    ),
    confirmIcon: BootstrapIcons.trash3,
    confirmLabel: 'Delete',
    onConfirm: () => _fire(() => _confirmDeleteCourse(_closer(ctx))),
  );

  Widget _buildSectionDeleteDialog(BuildContext ctx) => _dangerDialog(
    ctx,
    icon: BootstrapIcons.exclamation_triangle,
    title: 'Delete Section?',
    description: TextSpan(
      children: [
        const TextSpan(text: 'Are you sure you want to delete '),
        _boldName(ctx, vText(_sectionToDelete?['name'])),
        const TextSpan(text: '?'),
      ],
    ),
    confirmIcon: BootstrapIcons.trash3,
    confirmLabel: 'Delete',
    onConfirm: () => _fire(() => _confirmDeleteSection(_closer(ctx))),
  );

  Widget _buildChapterDeleteDialog(BuildContext ctx) => _dangerDialog(
    ctx,
    icon: BootstrapIcons.exclamation_triangle,
    title: 'Delete Chapter?',
    description: TextSpan(
      children: [
        const TextSpan(text: 'Are you sure you want to delete '),
        _boldName(ctx, vText(_chapterToDelete?['name'])),
        const TextSpan(text: '?'),
      ],
    ),
    confirmIcon: BootstrapIcons.trash3,
    confirmLabel: 'Delete',
    onConfirm: () => _fire(() => _confirmDeleteChapter(_closer(ctx))),
  );

  Widget _buildContentDeleteDialog(BuildContext ctx) => _dangerDialog(
    ctx,
    icon: BootstrapIcons.file_earmark_x,
    title: 'Delete Concept?',
    description: TextSpan(
      children: [
        const TextSpan(text: 'Are you sure you want to delete '),
        _boldName(ctx, vText(_contentToDelete?['name'])),
        const TextSpan(text: '?'),
      ],
    ),
    confirmIcon: BootstrapIcons.trash3,
    confirmLabel: 'Delete',
    onConfirm: () => _fire(() => _confirmDeleteContent(_closer(ctx))),
  );

  // ── Section / chapter edit ────────────────────────────────────────────

  Widget _buildSectionUpdateDialog(BuildContext ctx) {
    final section = _selectedSectionDetails;
    return _formDialog(
      ctx,
      header: _amberHeader(BootstrapIcons.layout_text_sidebar, 'Edit Section'),
      fields: [
        _LabeledInput(
          label: 'Section Name',
          top: 32,
          child: section == null
              ? const SizedBox.shrink()
              : _WebInput(controller: _sectionName, hint: 'Enter section name', onChanged: (v) => section['name'] = v),
        ),
        _orderInput(_updateSectionOrder),
      ],
      submit: _SubmitButton(
        loading: _isCreateBtnLoading,
        icon: BootstrapIcons.check2,
        label: 'Save Changes',
        loadingLabel: 'Saving...',
        onPressed: () => _fire(() => _sectionUpdate(_closer(ctx))),
      ),
    );
  }

  Widget _buildChapterUpdateDialog(BuildContext ctx) {
    final chapter = _selectedChapterDetails;
    return _formDialog(
      ctx,
      header: _amberHeader(BootstrapIcons.collection, 'Edit Chapter'),
      fields: [
        _LabeledInput(
          label: 'Chapter Name',
          top: 32,
          child: chapter == null
              ? const SizedBox.shrink()
              : _WebInput(controller: _chapterName, hint: 'Enter chapter name', onChanged: (v) => chapter['name'] = v),
        ),
        _orderInput(_updatechapterOrder),
      ],
      submit: _SubmitButton(
        loading: _isCreateBtnLoading,
        icon: BootstrapIcons.check2,
        label: 'Save Changes',
        loadingLabel: 'Saving...',
        onPressed: () => _fire(() => _chapterUpdate(_closer(ctx))),
      ),
    );
  }

  // ── Concept edit ──────────────────────────────────────────────────────

  /// `<Dialog v-if="selectedContentDetails.id" :key="selectedContentDetails.id">`
  Widget _buildContentUpdateDialog(BuildContext ctx) {
    final d = _cs.selectedContentDetails;
    final id = d['id'];
    if (id == null) return const SizedBox.shrink();
    final dark = context.isDark;
    final type = asString(d['type']) ?? '';
    final url = orBlank(d['url']);

    // `<label class="text-sm mb-2">` is inline (its margin does nothing); the
    // line box takes the 16px body text's 24px line.
    Widget plainLabel(String text) => SizedBox(
      height: 24,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(text, style: const TextStyle(fontSize: 14, height: 20 / 14)),
      ),
    );
    // Each block is `mt-4` + the grid's `gap-4`.
    Widget block(Widget label, Widget child) => Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [label, child],
      ),
    );
    // `class="border rounded-md p-2 w-full"`
    Widget plainInput(TextEditingController c, String hint, {ValueChanged<String>? onChanged, int? maxLength}) =>
        _WebInput(
          controller: c,
          hint: hint,
          plain: true,
          radius: 14,
          fontSize: 16,
          padding: const EdgeInsets.all(8),
          maxLength: maxLength,
          onChanged: onChanged,
        );

    return KeyedSubtree(
      key: ValueKey('content-update-$id'),
      child: AppDialogFrame(
        maxWidth: 896,
        actions: [
          _cancelButton(_closer(ctx), radius: 14),
          _SubmitButton(
            loading: _isCreateBtnLoading,
            label: 'Update',
            radius: 14,
            onPressed: () => _fire(() => _contentUpdate(id, _closer(ctx))),
          ),
        ],
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            // `<DialogHeader><DialogDescription>Edit Concept` (`text-muted-foreground text-sm`)
            Padding(
              padding: const EdgeInsets.only(right: 28),
              child: Text(
                'Edit Concept',
                textAlign: context.isSm ? TextAlign.left : TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  height: 20 / 14,
                  color: dark ? AppColors.darkMutedForeground : AppColors.mutedForeground,
                ),
              ),
            ),
            block(
              plainLabel('Name'),
              plainInput(
                _editContentName,
                'Enter Concept Name',
                maxLength: 255,
                onChanged: (v) => _ctrl.patchSelectedContentDetails({'name': v}),
              ),
            ),
            // `<Label class="mb-2">` (block, `leading-none font-medium`).
            block(
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text('Order Number', style: TextStyle(fontSize: 14, height: 1, fontWeight: FontWeight.w500)),
              ),
              plainInput(_updatecontentOrder, 'Enter Order Number'),
            ),
            block(
              plainLabel('Type'),
              _selectField(
                value: type,
                disabledOption: 'Select Concept Type',
                options: const [('html', 'HTML'), ('pdf', 'PDF'), ('url', 'URL')],
                onChanged: (v) => _ctrl.patchSelectedContentDetails({'type': v}),
                height: 42,
                radius: 14,
                background: Colors.transparent,
                borderColor: dark ? AppColors.darkBorder : AppColors.border,
                shadow: const [],
                textStyle: const TextStyle(fontSize: 16, height: 1.5),
                check: false,
              ),
            ),
            if (type == 'html')
              block(
                plainLabel('Concept'),
                HtmlEditor(
                  initialHtml: vText(d['html_content']),
                  onChanged: (v) => _ctrl.patchSelectedContentDetails({'html_content': v}),
                ),
              ),
            if (type == 'pdf')
              Padding(
                padding: const EdgeInsets.only(top: 32),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 768),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(bottom: 8),
                          child: Text('Attach file', style: TextStyle(fontSize: 14, height: 20 / 14)),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: url.isNotEmpty
                              ? Container(
                                  height: 400,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: const Color(0xFFCCCCCC)),
                                  ),
                                  child: WebContentView(url: _pdfViewerUrl(url), showOpenExternally: true),
                                )
                              : const Text('No PDF available', style: TextStyle(fontSize: 16, color: Tw.gray500)),
                        ),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // `<label class="cursor-pointer bg-blue-600 text-white
                            // px-4 py-2 rounded-md hover:bg-blue-700">`
                            _Hover(
                              onTap: () => _fire(_onContentFileChange),
                              builder: (h) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: h ? Tw.blue700 : Tw.blue600,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: const Text('Choose File', style: TextStyle(fontSize: 16, color: Colors.white)),
                              ),
                            ),
                            // `text-gray-700 truncate max-w-[300px]` (no dark variant).
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 300),
                              child: Text(
                                d['file'] != null ? vText(d['name']) : 'No file chosen',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 16, color: Tw.gray700),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (type == 'url')
              block(
                plainLabel('URL'),
                plainInput(
                  _editContentUrl,
                  'Paste an external URL',
                  onChanged: (v) => _ctrl.patchSelectedContentDetails({'url': v}),
                ),
              ),
            // Footer `mt-4` on top of the grid gap.
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
