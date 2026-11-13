part of 'class_course_create_page.dart';

/// "Confirm Delete" dialog (`<DialogContent class="bg-white
/// dark:bg-primary-foreground text-slate-900 dark:text-white">` with
/// `<DialogHeader>Confirm Delete</DialogHeader>`, the description with the
/// bold name, and No / Yes (`bg-primary text-white`)). [onYes] gets a `close`.
class _ConfirmDeleteDialog extends StatefulWidget {
  const _ConfirmDeleteDialog({required this.what, required this.name, required this.onYes});
  final String what;
  final String name;
  final Future<void> Function(VoidCallback close) onYes;

  @override
  State<_ConfirmDeleteDialog> createState() => _ConfirmDeleteDialogState();
}

class _ConfirmDeleteDialogState extends State<_ConfirmDeleteDialog> {
  bool _running = false;

  Future<void> _yes() async {
    if (_running) return;
    _running = true;
    final nav = Navigator.of(context);
    try {
      await widget.onYes(() {
        if (mounted) nav.pop();
      });
    } finally {
      _running = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return _CcDialog(
      solidLight: true,
      solidDark: true,
      textColor: dark ? Colors.white : Tw.slate900,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Text('Confirm Delete', textAlign: _headerAlign(context), style: const TextStyle(height: 1.5)),
          ),
          const SizedBox(height: 16),
          // `<DialogDescription>` sits outside the header: always left-aligned.
          Text.rich(
            TextSpan(
              style: TextStyle(fontSize: 14, height: 20 / 14, color: _mutedFg(context)),
              children: [
                TextSpan(text: '${widget.what} '),
                TextSpan(
                  text: '"${widget.name}" ',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: Tw.slate800),
                ),
                const TextSpan(text: '?'),
              ],
            ),
          ),
          // `gap-4` + `mt-4`
          const SizedBox(height: 32),
          _buttonRow([
            AppButton(label: 'No', variant: AppButtonVariant.outline, onPressed: () => Navigator.of(context).pop()),
            AppButton(label: 'Yes', foregroundColor: Colors.white, onPressed: _yes),
          ]),
        ],
      ),
    );
  }
}

/// "Confirm Detach" dialog (curriculum / instructor): `sm:max-w-md
/// rounded-2xl shadow-xl border-slate-250 dark:border-slate-850 p-6` (the
/// border colours don't exist, so `--border` shows), title `text-lg
/// font-bold`, description `mt-2 text-slate-500`, buttons `mt-6`: No
/// (`rounded-xl px-5`) / Yes (`bg-rose-600 hover:bg-rose-700 text-white
/// rounded-xl px-5 font-semibold`).
class _ConfirmDetachDialog extends StatefulWidget {
  const _ConfirmDetachDialog({required this.message, required this.onYes});
  final String message;
  final Future<void> Function(VoidCallback close) onYes;

  @override
  State<_ConfirmDetachDialog> createState() => _ConfirmDetachDialogState();
}

class _ConfirmDetachDialogState extends State<_ConfirmDetachDialog> {
  bool _running = false;

  Future<void> _yes() async {
    if (_running) return;
    _running = true;
    final nav = Navigator.of(context);
    try {
      await widget.onYes(() {
        if (mounted) nav.pop();
      });
    } finally {
      _running = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final align = _headerAlign(context);
    return _CcDialog(
      maxWidth: 448,
      radius: 16,
      shadow: _shadowXl,
      borderColor: _borderColor(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Text(
              'Confirm Detach',
              textAlign: align,
              style: TextStyle(
                  fontSize: 18, height: 1, fontWeight: FontWeight.w700, color: dark ? Colors.white : Tw.slate900),
            ),
          ),
          // header `gap-2` + `mt-2`
          const SizedBox(height: 16),
          Text(
            widget.message,
            textAlign: align,
            style: TextStyle(fontSize: 14, height: 20 / 14, color: dark ? Tw.slate400 : Tw.slate500),
          ),
          // `gap-4` + `mt-6`
          const SizedBox(height: 40),
          _buttonRow([
            AppButton(
              label: 'No',
              variant: AppButtonVariant.outline,
              radius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            AppButton(
              label: 'Yes',
              backgroundColor: Tw.rose600,
              hoverBackgroundColor: Tw.rose700,
              foregroundColor: Colors.white,
              radius: 20,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              fontWeight: FontWeight.w600,
              onPressed: _yes,
            ),
          ]),
        ],
      ),
    );
  }
}

/// Create / edit dialog for a section or chapter: `<DialogDescription>`
/// heading, then `mt-4` blocks (`<Label class="mb-2">` + raw
/// `<input class="border rounded-md p-2 w-full">`) and the `mt-4` button row,
/// all in the `gap-4` grid. The edit dialogs ([solid]) are `bg-white
/// dark:bg-primary-foreground text-slate-900 dark:text-white`, the create
/// ones only `dark:bg-primary-foreground`.
class _NameOrderDialog extends StatefulWidget {
  const _NameOrderDialog({
    required this.heading,
    required this.nameLabel,
    required this.namePlaceholder,
    required this.submitLabel,
    required this.onSubmit,
    this.showName = true,
    this.initialName = '',
    this.initialOrder = '',
    this.solid = false,
  });

  /// The `<DialogDescription>` ("Create a Section", "Edit Chapter", …).
  final String heading;
  final String nameLabel;
  final String namePlaceholder;
  final String submitLabel;

  /// The name input is `v-if="selectedSectionDetails"` when editing.
  final bool showName;
  final String initialName;
  final String initialOrder;
  final bool solid;
  final Future<void> Function(String name, String order, VoidCallback close) onSubmit;

  @override
  State<_NameOrderDialog> createState() => _NameOrderDialogState();
}

class _NameOrderDialogState extends State<_NameOrderDialog> {
  late final _name = TextEditingController(text: widget.initialName);
  late final _order = TextEditingController(text: widget.initialOrder);
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _order.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    try {
      await widget.onSubmit(_name.text, _order.text, () {
        if (mounted) nav.pop();
      });
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return PopScope(
      canPop: !_busy,
      child: _CcDialog(
        solidLight: widget.solid,
        solidDark: true,
        textColor: widget.solid ? (dark ? Colors.white : Tw.slate900) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dialogDescription(context, widget.heading),
            const SizedBox(height: 32),
            _ReqLabel(widget.nameLabel),
            const SizedBox(height: 8),
            if (widget.showName) _NativeInput(controller: _name, hint: widget.namePlaceholder),
            const SizedBox(height: 32),
            const _ReqLabel('Order Number'),
            const SizedBox(height: 8),
            _NativeInput(controller: _order, hint: 'Enter Order Number'),
            const SizedBox(height: 32),
            _buttonRow([
              AppButton(label: 'Cancel', variant: AppButtonVariant.outline, onPressed: () => Navigator.of(context).pop()),
              AppButton(onPressed: _busy ? null : _submit, child: _spinOr(context, _busy, widget.submitLabel)),
            ]),
          ],
        ),
      ),
    );
  }
}

/// Selects: the status choices shared by the create / update dialogs.
const _statusItems = [
  AppSelectItem('published', 'Published'),
  AppSelectItem('draft', 'UnPublished'),
  AppSelectItem('archived', 'Archived'),
];

const _zoneItems = [
  AppSelectItem('mathzone', 'Math Zone'),
  AppSelectItem('mathplay', 'Math Play'),
  AppSelectItem('sciencezone', 'Science Zone'),
  AppSelectItem('scienceplay', 'Science Play'),
];

/// `<SelectLabel>Available Curriculums</SelectLabel>` inside the curriculum select.
const _groupLabel = '\u0000group-label';

/// `<Card class="p-2"><div class="w-full h-40 … bg-gray-50 rounded-md"><img/></div></Card>`
/// in a `mt-2 w-full max-w-xs` wrapper.
class _ImagePreviewCard extends StatelessWidget {
  const _ImagePreviewCard({this.file, this.url});
  final UploadFile? file;
  final String? url;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    Widget? image;
    if (file != null) {
      image = file!.bytes != null
          ? Image.memory(file!.bytes!, fit: BoxFit.contain)
          : Image.file(File(file!.path!), fit: BoxFit.contain);
    } else if (url != null && url!.isNotEmpty) {
      image = Image.network(url!, fit: BoxFit.contain, errorBuilder: (_, _, _) => const _AltText());
    }
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: dark ? AppColors.darkCard : AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _borderColor(context)),
              boxShadow: _shadowSm,
            ),
            child: Container(
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Tw.gray50, borderRadius: BorderRadius.circular(14)),
              child: image ?? const _AltText(),
            ),
          ),
        ),
      ),
    );
  }
}

class _AltText extends StatelessWidget {
  const _AltText();

  @override
  Widget build(BuildContext context) =>
      const Text('Preview', style: TextStyle(fontSize: 12, color: Tw.gray500));
}

/// A labelled control: `<FormItem>` (`grid gap-2`) in the create dialog,
/// `flex flex-col gap-1` in the update dialog.
Widget _field(String label, Widget control, {bool required = false, double gap = 8}) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [_ReqLabel(label, required: required), SizedBox(height: gap), control],
    );

// ── Create Course ──────────────────────────────────────────────────────────

/// `<DialogContent class="sm:max-w-6xl w-[95%] sm:w-[90%] max-h-[90vh] flex
/// flex-col p-0 overflow-hidden">`: a fixed header (`px-6 pt-6 pb-2 border-b`)
/// over the scrolling form (`p-6`, `flex flex-col gap-4`).
class _CreateCourseDialog extends ConsumerStatefulWidget {
  const _CreateCourseDialog({required this.s});
  final _ClassCourseCreatePageState s;

  @override
  ConsumerState<_CreateCourseDialog> createState() => _CreateCourseDialogState();
}

class _CreateCourseDialogState extends ConsumerState<_CreateCourseDialog> {
  late final Map<String, dynamic> _initial = ref.read(classCourseControllerProvider).courseForm;
  late final _title = TextEditingController(text: _jsOrEmpty(_initial['title']));
  late final _shortName = TextEditingController(text: _jsOrEmpty(_initial['short_name']));
  late final _courseCode = TextEditingController(text: _jsOrEmpty(_initial['course_code']));
  late final _description = TextEditingController(text: _jsOrEmpty(_initial['description']));
  bool _busy = false;

  _ClassCourseCreatePageState get s => widget.s;
  ClassCourseController get _ctrl => ref.read(classCourseControllerProvider.notifier);

  @override
  void dispose() {
    _title.dispose();
    _shortName.dispose();
    _courseCode.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await pickImageFile();
    if (file == null || !mounted) return;
    _ctrl.patchCourseForm({'image': file});
    setState(() => s._previewFile = file);
  }

  Future<void> _submit() async {
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    var ok = false;
    try {
      ok = await s._onSubmit();
    } catch (_) {
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (ok && mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(classCourseControllerProvider);
    final cf = st.courseForm;
    final dark = context.isDark;
    final w = context.screenWidth;
    final cols = context.isMd ? 2 : 1;
    final hasClass = jsTruthy(cf['allclass']);
    final image = cf['image'] is UploadFile ? cf['image'] as UploadFile : null;

    Widget grid(List<Widget> children) => _Grid(columns: cols, equalHeight: false, children: children);

    final fields = <Widget>[
      grid([
        _field(
          'Title',
          required: true,
          AppTextField(
            controller: _title,
            hint: 'Enter Course Title',
            onChanged: (v) => _ctrl.patchCourseForm({'title': v}),
          ),
        ),
        _field(
          'Course Short Name',
          required: true,
          AppTextField(
            controller: _shortName,
            hint: 'Enter short name',
            onChanged: (v) => _ctrl.patchCourseForm({'short_name': v}),
          ),
        ),
      ]),
      grid([
        _field(
          'Curriculum',
          required: true,
          AppSelect<Object>(
            value: s._selectedCurriculumId,
            placeholder: 'Select Curriculum',
            items: [
              const AppSelectItem<Object>(_groupLabel, 'Available Curriculums', enabled: false),
              for (final c in st.curriculums)
                if (c['status'] == 'published' && c['id'] != null)
                  AppSelectItem<Object>(c['id'] as Object, '${c['name']}'),
            ],
            onChanged: (v) => setState(() => s._setSelectedCurriculumId(v)),
          ),
        ),
        _field(
          'Course Code',
          required: true,
          AppTextField(
            controller: _courseCode,
            hint: 'Enter course code',
            onChanged: (v) => _ctrl.patchCourseForm({'course_code': v}),
          ),
        ),
      ]),
      grid([
        _field('Image', FilePickField(onPick: _pickImage, fileName: image?.name)),
        _field(
          'Status',
          AppSelect<String>(
            value: s._statusString,
            placeholder: 'Select status',
            items: _statusItems,
            onChanged: (v) => setState(() => s._setStatusString(v ?? '')),
          ),
        ),
      ]),
      if (s._previewFile != null) _ImagePreviewCard(file: s._previewFile),
      grid([
        _field(
          'Instructors',
          required: true,
          AppSelect<String>(
            value: _jsOrEmpty(cf['instructor_id']),
            placeholder: 'Select Instructor',
            items: st.instructors.isEmpty
                ? const [AppSelectItem('none', 'No instructors available', enabled: false)]
                : [for (final inst in st.instructors) AppSelectItem('${inst['id']}', instructorOptionLabel(inst))],
            onChanged: (v) => _ctrl.patchCourseForm({'instructor_id': v}),
          ),
        ),
        _field(
          'All Class',
          AppSelect<String>(
            value: _jsOrEmpty(cf['allclass']),
            placeholder: 'Select Class',
            items: [for (final c in s._filteredClasses) AppSelectItem('${c['id']}', '${c['name'] ?? ''}')],
            onChanged: (v) {
              _ctrl.patchCourseForm({'allclass': v});
              s._loadSubjectsForSelectedClasses();
            },
          ),
        ),
      ]),
      grid([
        _field(
          'Subjects',
          AppSelect<String>(
            value: _jsOrEmpty(cf['subject_id']),
            placeholder: 'Select Subject',
            enabled: hasClass,
            items: [for (final sub in st.allsubject) AppSelectItem('${sub['id']}', '${sub['name'] ?? ''}')],
            onChanged: (v) => _ctrl.patchCourseForm({'subject_id': v}),
          ),
        ),
        _field(
          'Course Zone',
          AppSelect<String>(
            value: s._courseZone,
            placeholder: 'Select Course Zone',
            enabled: hasClass,
            items: _zoneItems,
            onChanged: (v) => setState(() => s._courseZone = v ?? ''),
          ),
        ),
      ]),
      _field(
        'Description',
        AppTextField(
          controller: _description,
          hint: 'Type your message here',
          minLines: 3,
          maxLines: null,
          onChanged: (v) => _ctrl.patchCourseForm({'description': v}),
        ),
      ),
      // `mt-4` on top of the form's `gap-4`.
      Padding(
        padding: const EdgeInsets.only(top: 16),
        child: _buttonRow(gap: 16, [
          AppButton(label: 'Close', variant: AppButtonVariant.outline, onPressed: () => Navigator.of(context).pop()),
          AppButton(onPressed: _busy ? null : _submit, child: _spinOr(context, _busy, 'Create')),
        ]),
      ),
    ];

    return PopScope(
      canPop: !_busy,
      child: _CcDialog(
        maxWidth: math.min(w * 0.9, 1152.0),
        padding: EdgeInsets.zero,
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        scroll: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate100)),
              ),
              child: Text(
                'Create Course',
                textAlign: _headerAlign(context),
                style: const TextStyle(fontSize: 20, height: 1, fontWeight: FontWeight.w700),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (var i = 0; i < fields.length; i++) ...[
                      if (i > 0) const SizedBox(height: 16),
                      fields[i],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Update Course ──────────────────────────────────────────────────────────

/// Update dialog (`sm:max-w-3xl max-h-[90vh] overflow-y-auto
/// dark:bg-primary-foreground`): a `text-lg` DialogDescription heading, the
/// `p-4 flex flex-col gap-4` fields (labels `gap-1` above their control) and
/// the `mt-4 px-4 pb-4` button row.
class _UpdateCourseDialog extends ConsumerStatefulWidget {
  const _UpdateCourseDialog({required this.s});
  final _ClassCourseCreatePageState s;

  @override
  ConsumerState<_UpdateCourseDialog> createState() => _UpdateCourseDialogState();
}

class _UpdateCourseDialogState extends ConsumerState<_UpdateCourseDialog> {
  _ClassCourseCreatePageState get s => widget.s;
  Map<String, dynamic> get _form => s._form;

  late final _title = TextEditingController(text: _jsOrEmpty(_form['title']));
  late final _shortName = TextEditingController(text: _jsOrEmpty(_form['short_name']));
  late final _courseCode = TextEditingController(text: _jsOrEmpty(_form['course_code']));
  late final _description = TextEditingController(text: _jsOrEmpty(_form['description']));
  bool _busy = false;

  @override
  void dispose() {
    _title.dispose();
    _shortName.dispose();
    _courseCode.dispose();
    _description.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final file = await pickImageFile();
    if (file == null || !mounted) return;
    setState(() {
      _form['attach'] = file;
      s._imagePreviewFile = file;
    });
  }

  Future<void> _submit() async {
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    var ok = false;
    try {
      ok = await s._courseUpdate();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (ok && mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(classCourseControllerProvider);
    final cols = context.isMd ? 2 : 1;
    Widget grid(List<Widget> children) => _Grid(columns: cols, equalHeight: false, children: children);
    Widget f(String label, Widget control, {bool required = false}) =>
        _field(label, control, required: required, gap: 4);
    final pickedImage = _form['attach'] is UploadFile ? _form['attach'] as UploadFile : null;

    final fields = <Widget>[
      grid([
        f(
          'Title',
          required: true,
          AppTextField(controller: _title, hint: 'Enter Course Title', onChanged: (v) => _form['title'] = v),
        ),
        f(
          'Course Short Name',
          required: true,
          AppTextField(controller: _shortName, hint: 'Enter short name', onChanged: (v) => _form['short_name'] = v),
        ),
      ]),
      grid([
        f(
          'Course Code',
          required: true,
          AppTextField(controller: _courseCode, hint: 'Enter course code', onChanged: (v) => _form['course_code'] = v),
        ),
        f(
          'Status',
          AppSelect<String>(
            value: _jsOrEmpty(_form['status']),
            placeholder: 'Select status',
            items: _statusItems,
            onChanged: (v) => setState(() => _form['status'] = v),
          ),
        ),
      ]),
      grid([
        f(
          'Curriculum',
          AppSelect<String>(
            value: _jsOrEmpty(_form['curriculum_id']),
            placeholder: 'Select Curriculum',
            items: [
              for (final c in st.curriculums)
                if (c['status'] == 'published') AppSelectItem('${c['id']}', '${c['name'] ?? ''}'),
            ],
            onChanged: (v) => setState(() => _form['curriculum_id'] = v),
          ),
        ),
        f(
          'Instructor',
          AppSelect<String>(
            value: _jsOrEmpty(_form['instructor_id']),
            placeholder: 'Select Instructor',
            items: [for (final inst in st.instructors) AppSelectItem('${inst['id']}', instructorOptionLabel(inst))],
            onChanged: (v) => setState(() => _form['instructor_id'] = v),
          ),
        ),
      ]),
      grid([
        f(
          'All Class',
          AppSelect<Object>(
            value: _form['class_id'] as Object?,
            placeholder: 'Select Class',
            items: [
              for (final c in s._editAllClassesData)
                if (c['id'] != null) AppSelectItem<Object>(c['id'] as Object, '${c['name'] ?? ''}'),
            ],
            onChanged: (v) async {
              setState(() => _form['class_id'] = v);
              await s._onEditClassChange(v);
              if (mounted) setState(() {});
            },
          ),
        ),
        f(
          'Subject',
          AppSelect<String>(
            value: _jsOrEmpty(_form['subject_id']),
            placeholder: 'Select Subject',
            items: [for (final sub in s._editSubjectsList) AppSelectItem('${sub['id']}', '${sub['name'] ?? ''}')],
            onChanged: (v) => setState(() => _form['subject_id'] = v),
          ),
        ),
        f(
          'Course Zone',
          AppSelect<String>(
            value: _jsOrEmpty(_form['zone']),
            placeholder: 'Select Course Zone',
            items: _zoneItems,
            onChanged: (v) => setState(() => _form['zone'] = v),
          ),
        ),
      ]),
      grid([f('Image', FilePickField(onPick: _pickImage, fileName: pickedImage?.name))]),
      _ImagePreviewCard(
        file: s._imagePreviewFile,
        url: s._imagePreview.isNotEmpty ? s._imagePreview : _jsOrEmpty(s._selectedCourseDetails?['image']),
      ),
      f(
        'Description',
        AppTextField(
          controller: _description,
          hint: 'Type your description here',
          minLines: 3,
          maxLines: null,
          onChanged: (v) => _form['description'] = v,
        ),
      ),
      // `flex items-center gap-2 mt-2`
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: LabeledCheckbox(
          value: _form['isMathPlay'] == true,
          label: 'Math Play Course',
          labelStyle: const TextStyle(fontSize: 14, height: 20 / 14),
          onChanged: (v) => setState(() => _form['isMathPlay'] = v),
        ),
      ),
    ];

    return PopScope(
      canPop: !_busy,
      child: _CcDialog(
        maxWidth: 768,
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        solidDark: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dialogDescription(context, 'Update Course', fontSize: 18),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < fields.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    fields[i],
                  ],
                ],
              ),
            ),
            // `gap-4` + `mt-4`, then `px-4 pb-4`.
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 32, 16, 16),
              child: _buttonRow([
                AppButton(label: 'Cancel', variant: AppButtonVariant.outline, onPressed: () => Navigator.of(context).pop()),
                AppButton(onPressed: _busy ? null : _submit, child: _spinOr(context, _busy, 'Update')),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
