part of 'class_course_create_page.dart';

/// The native `<select>` of concept types (with its disabled placeholder option).
const _conceptTypeItems = [
  AppSelectItem('', 'Select Concept Type', enabled: false),
  AppSelectItem('html', 'HTML'),
  AppSelectItem('pdf', 'PDF'),
  AppSelectItem('url', 'URL'),
];

/// Hidden file input + the `cursor-pointer bg-primary text-primary-foreground
/// px-4 py-2 rounded-md hover:bg-primary/90` "Choose File" label + the
/// picked file name (`text-gray-700 truncate max-w-[300px]`, no dark variant).
class _ChooseFileRow extends StatefulWidget {
  const _ChooseFileRow({required this.onPick, required this.text});
  final VoidCallback onPick;
  final String text;

  @override
  State<_ChooseFileRow> createState() => _ChooseFileRowState();
}

class _ChooseFileRowState extends State<_ChooseFileRow> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return Row(
      children: [
        MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => _hover = true),
          onExit: (_) => setState(() => _hover = false),
          child: GestureDetector(
            onTap: widget.onPick,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _hover ? primary.withValues(alpha: 0.9) : primary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text('Choose File',
                  style: TextStyle(fontSize: 16, height: 1.5, color: context.colors.onPrimary)),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 300),
            child: Text(
              widget.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16, height: 1.5, color: Tw.gray700),
            ),
          ),
        ),
      ],
    );
  }
}

/// A `mt-4` block of the concept dialogs: with the `gap-4` grid, 32px above.
Widget _block(Widget child) => Padding(padding: const EdgeInsets.only(top: 32), child: child);

/// `<Label class="mb-2">` + control.
Widget _labelBlock(String label, Widget control) => _block(Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [_ReqLabel(label), const SizedBox(height: 8), control],
    ));

/// Inline `<label class="text-sm mb-2">` (its margin has no effect) + control.
Widget _nativeBlock(String label, Widget control) => _block(Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [_nativeLabel(label), control],
    ));

/// `<label class="text-sm mb-2 block">Attach file</label>`.
Widget _attachLabel() => const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Text('Attach file', style: TextStyle(fontSize: 14, height: 20 / 14)),
    );

// ── Create Concept ─────────────────────────────────────────────────────────

/// `<DialogContent class="sm:max-w-4xl w-full max-h-[90vh] overflow-y-auto
/// dark:bg-primary-foreground">`.
class _CreateConceptDialog extends ConsumerStatefulWidget {
  const _CreateConceptDialog({required this.s});
  final _ClassCourseCreatePageState s;

  @override
  ConsumerState<_CreateConceptDialog> createState() => _CreateConceptDialogState();
}

class _CreateConceptDialogState extends ConsumerState<_CreateConceptDialog> {
  late final Map<String, dynamic> _initial = ref.read(classCourseControllerProvider).contentForm;
  late final _name = TextEditingController(text: _jsOrEmpty(_initial['name']));
  final _order = TextEditingController();
  late final _url = TextEditingController(text: _jsOrEmpty(_initial['url']));
  bool _busy = false;

  ClassCourseController get _ctrl => ref.read(classCourseControllerProvider.notifier);

  @override
  void dispose() {
    _name.dispose();
    _order.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final nav = Navigator.of(context);
    setState(() => _busy = true);
    var ok = false;
    try {
      ok = await widget.s._createContent(_order.text);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (ok && mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(classCourseControllerProvider).contentForm;
    final type = _jsOrEmpty(form['type']);
    final file = form['file'] is UploadFile ? form['file'] as UploadFile : null;
    final dark = context.isDark;

    return PopScope(
      canPop: !_busy,
      child: _CcDialog(
        maxWidth: 896,
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        solidDark: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dialogDescription(context, 'Create Concept'),
            _nativeBlock(
              'Name',
              _NativeInput(
                controller: _name,
                hint: 'Enter Concept Name',
                maxLength: 255,
                onChanged: (v) => _ctrl.patchContentForm({'name': v}),
              ),
            ),
            _labelBlock('Order Number', _NativeInput(controller: _order, hint: 'Enter Order Number')),
            _nativeBlock(
              'Type',
              _CcSelect(
                native: true,
                fill: dark ? AppColors.darkPrimaryForeground : null,
                value: type,
                placeholder: 'Select Concept Type',
                items: _conceptTypeItems,
                onChanged: (v) => _ctrl.patchContentForm({'type': v}),
              ),
            ),
            if (type == 'html')
              _nativeBlock(
                'Concept',
                HtmlEditor(
                  key: const ValueKey('create-concept-html'),
                  initialHtml: _jsOrEmpty(form['html_content']),
                  onChanged: (html) => _ctrl.patchContentForm({'html_content': html}),
                ),
              ),
            if (type == 'pdf')
              _block(Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 768),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _attachLabel(),
                      _ChooseFileRow(onPick: widget.s._onContentFileChange, text: file?.name ?? 'No file chosen'),
                    ],
                  ),
                ),
              )),
            if (type == 'url')
              _nativeBlock(
                'URL',
                _NativeInput(
                  controller: _url,
                  hint: 'Paste an external URL if this Concept is a URL',
                  onChanged: (v) => _ctrl.patchContentForm({'url': v}),
                ),
              ),
            _block(_buttonRow([
              AppButton(label: 'Cancel', variant: AppButtonVariant.outline, onPressed: () => Navigator.of(context).pop()),
              AppButton(onPressed: _busy ? null : _submit, child: _spinOr(context, _busy, 'Create')),
            ])),
          ],
        ),
      ),
    );
  }
}

// ── Edit Concept ───────────────────────────────────────────────────────────

/// `<DialogContent class="sm:max-w-4xl w-full max-h-[90vh] overflow-y-auto
/// bg-white dark:bg-primary-foreground text-slate-900 dark:text-white">`.
class _UpdateConceptDialog extends ConsumerStatefulWidget {
  const _UpdateConceptDialog({super.key, required this.s});
  final _ClassCourseCreatePageState s;

  @override
  ConsumerState<_UpdateConceptDialog> createState() => _UpdateConceptDialogState();
}

class _UpdateConceptDialogState extends ConsumerState<_UpdateConceptDialog> {
  late final Map<String, dynamic> _initial = ref.read(classCourseControllerProvider).selectedContentDetails;
  late final _name = TextEditingController(text: _jsOrEmpty(_initial['name']));
  late final _order = TextEditingController(text: '${widget.s._updatecontentOrder ?? ''}');
  late final _url = TextEditingController(text: _jsOrEmpty(_initial['url']));
  bool _busy = false;

  ClassCourseController get _ctrl => ref.read(classCourseControllerProvider.notifier);

  @override
  void dispose() {
    _name.dispose();
    _order.dispose();
    _url.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    await widget.s._onContentFileChange();
    if (!mounted) return;
    _url.text = _jsOrEmpty(ref.read(classCourseControllerProvider).selectedContentDetails['url']);
  }

  Future<void> _submit() async {
    final nav = Navigator.of(context);
    final id = ref.read(classCourseControllerProvider).selectedContentDetails['id'];
    setState(() => _busy = true);
    try {
      await widget.s._contentUpdate(id, _order.text);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (mounted) nav.pop();
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(classCourseControllerProvider).selectedContentDetails;
    final type = _jsOrEmpty(details['type']);
    final url = _jsOrEmpty(details['url']);
    final dark = context.isDark;

    return PopScope(
      canPop: !_busy,
      child: _CcDialog(
        maxWidth: 896,
        maxHeight: MediaQuery.sizeOf(context).height * 0.9,
        solidLight: true,
        solidDark: true,
        textColor: dark ? Colors.white : Tw.slate900,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dialogDescription(context, 'Edit Concept'),
            _nativeBlock(
              'Content Name',
              _NativeInput(
                controller: _name,
                hint: 'Enter Concept Name',
                maxLength: 255,
                onChanged: (v) => _ctrl.patchSelectedContentDetails({'name': v}),
              ),
            ),
            _labelBlock('Order Number', _NativeInput(controller: _order, hint: 'Enter Order Number')),
            _nativeBlock(
              'Type',
              _CcSelect(
                native: true,
                value: type,
                placeholder: 'Select Concept Type',
                items: _conceptTypeItems,
                onChanged: (v) => _ctrl.patchSelectedContentDetails({'type': v}),
              ),
            ),
            if (type == 'html')
              _nativeBlock(
                'Concept',
                HtmlEditor(
                  key: ValueKey('edit-concept-html-${details['id']}'),
                  initialHtml: _jsOrEmpty(details['html_content']),
                  onChanged: (html) => _ctrl.patchSelectedContentDetails({'html_content': html}),
                ),
              ),
            if (type == 'pdf')
              _block(Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 768),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _attachLabel(),
                      // `<object height="400px" style="border: 1px solid #ccc; border-radius: 6px">`
                      if (url.isNotEmpty)
                        Container(
                          height: 400,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: const Color(0xFFCCCCCC)),
                          ),
                          child: WebContentView(url: pdfViewerUrl(url), showOpenExternally: true),
                        )
                      else
                        const Text('No PDF available', style: TextStyle(height: 1.5, color: Tw.gray500)),
                      const SizedBox(height: 16),
                      _ChooseFileRow(
                        onPick: _pickFile,
                        // The web shows the concept name (not the file name) once a file is picked.
                        text: details['file'] != null ? _jsOrEmpty(details['name']) : 'No file chosen',
                      ),
                    ],
                  ),
                ),
              )),
            if (type == 'url')
              _nativeBlock(
                'URL',
                _NativeInput(
                  controller: _url,
                  hint: 'Paste an external URL if this content is a URL',
                  onChanged: (v) => _ctrl.patchSelectedContentDetails({'url': v}),
                ),
              ),
            _block(_buttonRow([
              AppButton(label: 'Cancel', variant: AppButtonVariant.outline, onPressed: () => Navigator.of(context).pop()),
              AppButton(onPressed: _busy ? null : _submit, child: _spinOr(context, _busy, 'Update')),
            ])),
          ],
        ),
      ),
    );
  }
}
