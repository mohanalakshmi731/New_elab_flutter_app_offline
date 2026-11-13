part of 'new_questions_page.dart';

// ── qForm (emptyQForm()) ───────────────────────────────────────────────────

/// One `qForm.options` entry: `{ label, text, correct, image, preview }`.
class _QOption {
  _QOption({required this.label, String text = '', this.correct = false, this.image = '', String? preview})
      : text = TextEditingController(text: text),
        preview = preview ?? image;

  String label;
  final TextEditingController text;

  /// The API's `is_correct` as-is until toggled (the web sent it unchanged).
  Object? correct;
  String image;
  String preview;

  void dispose() => text.dispose();
}

/// One `qForm.images` entry: `{ url, caption, preview, order_index }`.
class _QImage {
  _QImage({this.url = '', String caption = '', Object? orderIndex, String? preview})
      : caption = TextEditingController(text: caption),
        order = TextEditingController(text: displayValue(orderIndex)),
        preview = preview ?? url;

  String url;
  final TextEditingController caption;

  /// `order_index` (`<Input type="number" min="1">`).
  final TextEditingController order;
  String preview;

  void dispose() {
    caption.dispose();
    order.dispose();
  }
}

/// `emptyQForm()` plus `qFormTagsInput`.
class _QForm {
  final code = TextEditingController();
  String questionType = 'MCQ';
  final stem = TextEditingController();
  String difficulty = '';
  final marks = TextEditingController(text: '1');
  final negativeMarks = TextEditingController(text: '0.25');
  final explanation = TextEditingController();
  bool isActive = true;
  List<_QOption> options = [_QOption(label: 'A'), _QOption(label: 'B')];
  final images = <_QImage>[];
  final videoUrl = TextEditingController();
  List<String> tags = [];

  /// `qFormTagsInput`
  final tagsInput = TextEditingController();

  /// Replaces the two default options (not shown yet, so disposed at once).
  void replaceOptions(List<_QOption> next) {
    for (final o in options) {
      o.dispose();
    }
    options = next;
  }

  void dispose() {
    for (final c in [code, stem, marks, negativeMarks, explanation, videoUrl, tagsInput]) {
      c.dispose();
    }
    for (final o in options) {
      o.dispose();
    }
    for (final i in images) {
      i.dispose();
    }
  }
}

// ── CREATE / EDIT QUESTION DIALOG ──────────────────────────────────────────

class _QuestionFormDialog extends ConsumerWidget {
  const _QuestionFormDialog({required this.s});
  final _NewQuestionsPageState s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(questionsControllerProvider);
    return ValueListenableBuilder<int>(
      valueListenable: s._tick,
      builder: (context, _, _) => _frame(context, store),
    );
  }

  Widget _frame(BuildContext context, QuestionsState store) {
    final dark = context.isDark;
    final lg = context.isLg;
    final hPad = context.isSm ? 24.0 : 16.0;
    final edit = s._isEdit;
    final border = NqTw.border(context);

    final header = Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 16),
      decoration: BoxDecoration(
        color: dark ? NqTw.navy : Colors.white,
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        children: [
          NqIconTile(
            icon: edit ? BootstrapIcons.pencil_square : BootstrapIcons.plus_circle,
            color: edit ? Tw.emerald500 : Tw.cyan500,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  edit ? 'Edit Question' : 'Create Question',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    fontWeight: FontWeight.w900,
                    color: dark ? Colors.white : Tw.slate900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  edit ? 'Update the question details below.' : 'Fill in the details to add a new question.',
                  style: const TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate500),
                ),
              ],
            ),
          ),
          NqIconButton(
            icon: BootstrapIcons.x_lg,
            color: Tw.slate500,
            background: dark ? NqTw.white(0.1) : Tw.slate100,
            hoverBackground: dark ? NqTw.white(0.2) : Tw.slate200,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
    );

    final footer = Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
      decoration: BoxDecoration(
        color: dark ? NqTw.navy : Colors.white,
        border: Border(top: BorderSide(color: border)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // `!bg-white … !text-slate-700` beat the ghost hover: no change.
          NqButton.plain(
            context,
            label: 'Cancel',
            fontSize: 12,
            darkText: false,
            hover: false,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const SizedBox(width: 8),
          // `<i class="me-1.5 …" /> {{ label }}` inside a `<span>`: the margin
          // plus a collapsed space.
          NqButton(
            label: edit ? 'Update Question' : 'Create Question',
            icon: edit ? BootstrapIcons.check_lg : BootstrapIcons.plus_lg,
            iconGap: 9,
            loading: s._qFormLoading,
            loadingLabel: edit ? 'Updating...' : 'Creating...',
            background: edit ? Tw.emerald500 : Tw.cyan500,
            hoverBackground: edit ? Tw.emerald400 : Tw.cyan400,
            foreground: edit ? Colors.white : Tw.slate900,
            shadow: AppShadows.lg,
            fontSize: 12,
            minWidth: 130,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            onPressed: () => s._saveQuestion(context),
          ),
        ],
      ),
    );

    final body = Container(
      color: dark ? NqTw.deepNavy : Tw.slate50,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _basicInformation(context),
            const SizedBox(height: 20),
            _association(context, store),
            if (s._qForm.questionType == 'MCQ') ...[
              const SizedBox(height: 20),
              _options(context),
            ],
            const SizedBox(height: 20),
            _images(context),
            const SizedBox(height: 20),
            _video(context),
            const SizedBox(height: 20),
            _tags(context),
          ],
        ),
      ),
    );

    // DialogContent keeps the kit's `gap-4` between header, body and footer
    // (the `!bg-white dark:!bg-[#0f0e2a]` shows through) and its own close X
    // (`top-4 right-4`), drawn over the header's close button.
    Widget content = Stack(
      children: [
        Column(
          children: [
            header,
            const SizedBox(height: 16),
            Expanded(child: body),
            const SizedBox(height: 16),
            footer,
          ],
        ),
        const Positioned(top: 16, right: 16, child: DialogCloseButton()),
      ],
    );
    if (!lg) content = SafeArea(child: content);

    // `!w-full lg:!w-[80vw] !h-screen` — full screen below lg, a centred
    // 80vw × 100vh rounded panel (`lg:border`, kit `shadow-2xl`) from lg up.
    final radius = BorderRadius.circular(lg ? 16 : 0);
    Widget frame = DecoratedBox(
      decoration: BoxDecoration(borderRadius: radius, boxShadow: AppShadows.xl2),
      child: Container(
        width: lg ? MediaQuery.sizeOf(context).width * 0.8 : double.infinity,
        height: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: dark ? NqTw.deepNavy : Colors.white,
          borderRadius: radius,
          border: lg ? Border.all(color: border) : null,
        ),
        child: Material(type: MaterialType.transparency, child: content),
      ),
    );
    // zoom-in-95
    final animation = ModalRoute.of(context)?.animation;
    if (animation != null) {
      frame = ScaleTransition(
        scale: Tween(begin: 0.95, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
        child: frame,
      );
    }
    return Dialog(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: frame,
    );
  }

  Widget _grid(BuildContext context, int columns, List<Widget> children, {double gap = 16}) =>
      FormGrid(columns: context.isSm ? columns : 1, gap: gap, children: children);

  Widget _select(
    BuildContext context,
    String? value,
    List<AppSelectItem<String>> items,
    ValueChanged<String> onChanged, {
    required String placeholder,
    bool enabled = true,
  }) =>
      nqSelect(
        context,
        value: value,
        items: items,
        onChanged: onChanged,
        placeholder: placeholder,
        enabled: enabled,
      );

  // ── BASIC INFORMATION ──

  Widget _basicInformation(BuildContext context) {
    final dark = context.isDark;
    final f = s._qForm;
    return NqSectionCard(
      title: 'Basic Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _grid(context, 2, [
            NqField(
              label: const NqLabel('Question Code', required: true),
              child: NqTextInput(controller: f.code, hint: 'e.g. Q001'),
            ),
            NqField(
              label: const NqLabel('Question Type', required: true),
              child: _select(
                context,
                f.questionType,
                const [AppSelectItem('MCQ', 'MCQ'), AppSelectItem('SAQ', 'SAQ'), AppSelectItem('MEQ', 'MEQ')],
                (v) => s._set(() => f.questionType = v),
                placeholder: 'Select type',
              ),
            ),
          ]),
          const SizedBox(height: 16),
          NqField(
            label: const NqLabel('Question Text', required: true),
            child: NqTextInput(controller: f.stem, textarea: true, hint: 'Enter question text'),
          ),
          const SizedBox(height: 16),
          _grid(context, 3, [
            NqField(
              label: const NqLabel('Difficulty', required: true),
              child: _select(
                context,
                f.difficulty,
                const [AppSelectItem('EASY', 'Easy'), AppSelectItem('MEDIUM', 'Medium'), AppSelectItem('HARD', 'Hard')],
                (v) => s._set(() => f.difficulty = v),
                placeholder: 'Select',
              ),
            ),
            NqField(
              label: const NqLabel('Marks', required: true),
              child: NqTextInput(controller: f.marks, number: true),
            ),
            NqField(
              label: const NqLabel('Negative Marks'),
              child: NqTextInput(controller: f.negativeMarks, number: true),
            ),
          ]),
          const SizedBox(height: 16),
          NqField(
            label: const NqLabel('Explanation'),
            child: NqTextInput(controller: f.explanation, textarea: true, hint: 'Optional explanation'),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: dark ? NqTw.white(0.05) : Tw.slate50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: NqTw.border(context)),
            ),
            child: Row(
              children: [
                ShadSwitch(value: f.isActive, onChanged: (v) => s._set(() => f.isActive = v)),
                const SizedBox(width: 12),
                Text(
                  'Active Question',
                  style: TextStyle(
                    fontSize: 14,
                    height: 20 / 14,
                    fontWeight: FontWeight.w500,
                    color: dark ? Tw.slate300 : Tw.slate700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ASSOCIATION ──

  Widget _association(BuildContext context, QuestionsState store) {
    final contents = s._qFormFilteredContents;
    return NqSectionCard(
      title: 'Association',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NqField(
            label: const NqLabel('Course', required: true),
            child: _select(
              context,
              s._qFormCourseId,
              [for (final c in store.courses) AppSelectItem('${c['id']}', displayValue(c['title']))],
              s._setQFormCourseId,
              placeholder: 'Select course',
            ),
          ),
          const SizedBox(height: 16),
          NqField(
            label: const NqLabel('Chapter', required: true),
            child: _select(
              context,
              s._qFormChapterId,
              [for (final c in store.chapters) AppSelectItem('${c['id']}', displayValue(c['name']))],
              (v) => s._set(() => s._qFormChapterId = v),
              placeholder: 'Select chapter',
              enabled: s._qFormCourseId.isNotEmpty,
            ),
          ),
          const SizedBox(height: 16),
          NqField(
            label: const NqLabel('Content', required: true),
            child: _select(
              context,
              s._qFormContentId,
              [for (final c in contents) AppSelectItem('${c['exam_content_id']}', displayValue(c['name']))],
              (v) => s._set(() => s._qFormContentId = v),
              placeholder: 'Select content',
              enabled: s._qFormChapterId.isNotEmpty,
            ),
          ),
        ],
      ),
    );
  }

  // ── MCQ OPTIONS ──

  /// `<Button size="sm" class="!bg-cyan-500 hover:!bg-cyan-400
  /// !text-slate-900 font-bold rounded-lg px-3 py-1.5 h-auto text-xs">` with
  /// `<i class="bi bi-plus-lg me-1" />` (`gap-1.5` + 4px).
  Widget _addButton(String label, VoidCallback onPressed) => NqButton(
        label: label,
        icon: BootstrapIcons.plus_lg,
        iconGap: 10,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        radius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        onPressed: onPressed,
      );

  /// `<Button size="sm" variant="outline" class="rounded-lg text-xs h-8 px-3
  /// border-slate-200 dark:border-white/10">` + `<i class="bi bi-image
  /// me-1.5" />` (`gap-1.5` + 6px); outline hover is `bg-accent`.
  Widget _chooseImageButton(BuildContext context, VoidCallback onPressed) => AppButton(
        variant: AppButtonVariant.outline,
        size: AppButtonSize.sm,
        radius: 16,
        borderColor: NqTw.border(context),
        fontSize: 12,
        onPressed: onPressed,
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(BootstrapIcons.image, size: 12),
            SizedBox(width: 12),
            Text('Choose Image', style: TextStyle(height: 16 / 12)),
          ],
        ),
      );

  /// `<Button size="sm" variant="ghost" class="rounded-lg text-xs h-8 px-2
  /// text-rose-500"><i class="bi bi-trash text-xs" /></Button>` (ghost hover:
  /// `bg-accent text-accent-foreground`).
  Widget _trashButton(BuildContext context, VoidCallback onTap) => AppButton(
        variant: AppButtonVariant.ghost,
        size: AppButtonSize.sm,
        radius: 16,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        foregroundColor: Tw.rose500,
        icon: BootstrapIcons.trash,
        iconSize: 12,
        onPressed: onTap,
      );

  Widget _options(BuildContext context) {
    final f = s._qForm;
    return NqSectionCard(
      title: 'Options',
      action: _addButton('Add Option', s._addOption),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < f.options.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            KeyedSubtree(key: ObjectKey(f.options[i]), child: _option(context, i, f.options[i])),
          ],
        ],
      ),
    );
  }

  Widget _option(BuildContext context, int index, _QOption opt) {
    final dark = context.isDark;
    final correct = jsTruthy(opt.correct);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: correct
            ? (dark ? Tw.emerald900.withValues(alpha: 0.1) : Tw.emerald50.withValues(alpha: 0.5))
            : (dark ? NqTw.white(0.03) : Tw.slate50),
        border: Border.all(
          color: correct ? (dark ? Tw.emerald500.withValues(alpha: 0.3) : Tw.emerald200) : NqTw.border(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: correct ? Tw.emerald500 : (dark ? NqTw.white(0.1) : Tw.slate200),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  opt.label,
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w900,
                    color: correct ? Colors.white : (dark ? Tw.slate400 : Tw.slate600),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NqTextInput(
                  controller: opt.text,
                  height: 36,
                  fill: dark ? NqTw.white(0.05) : Colors.white,
                  hint: 'Option ${opt.label} text',
                ),
              ),
              const SizedBox(width: 8),
              NqIconButton(
                icon: BootstrapIcons.x_lg,
                color: Tw.rose400,
                hoverColor: Tw.rose600,
                background: dark ? Tw.rose900.withValues(alpha: 0.2) : Tw.rose50,
                onTap: () => s._removeOption(index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              ShadSwitch(value: correct, onChanged: (v) => s._setCorrect(index, v)),
              const SizedBox(width: 10),
              Text(
                correct ? 'Correct Answer' : 'Mark as correct',
                style: TextStyle(
                  fontSize: 12,
                  height: 16 / 12,
                  fontWeight: FontWeight.w500,
                  color: correct ? (dark ? Tw.emerald400 : Tw.emerald600) : Tw.slate500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _chooseImageButton(context, () => s._onOptionFileChange(index)),
              if (opt.preview.isNotEmpty) ...[
                const SizedBox(width: 8),
                _trashButton(context, () => s._removeOptionImage(index)),
              ],
            ],
          ),
          if (opt.preview.isNotEmpty) ...[
            const SizedBox(height: 8),
            QuestionImage(url: opt.preview, maxHeight: 128, radius: 20, borderColor: NqTw.border(context)),
          ],
          if (opt.image.isNotEmpty) ...[
            const SizedBox(height: 8),
            // `h-8 text-xs` (kit `md:text-sm` stays), no `!text-…`.
            NqTextInput(
              key: ValueKey('opt-image-${opt.image}'),
              initialValue: opt.image,
              readOnly: true,
              height: 32,
              fontSize: 12,
              mdFontSize: 14,
              strongText: false,
              fill: dark ? NqTw.white(0.05) : Colors.white,
              hint: 'Image URL',
            ),
          ],
        ],
      ),
    );
  }

  // ── QUESTION IMAGES ──

  Widget _images(BuildContext context) {
    final f = s._qForm;
    return NqSectionCard(
      title: 'Images',
      action: _addButton('Add Image', s._addImage),
      child: f.images.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'No images added yet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate400),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < f.images.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  KeyedSubtree(key: ObjectKey(f.images[i]), child: _image(context, i, f.images[i])),
                ],
              ],
            ),
    );
  }

  Widget _image(BuildContext context, int index, _QImage img) {
    final dark = context.isDark;
    final fill = dark ? NqTw.white(0.05) : Colors.white;
    final shown = img.preview.isNotEmpty ? img.preview : img.url;
    Widget small(String label, Widget child) => NqField(
          label: NqLabel(label, size: 10, color: Tw.slate400),
          child: child,
        );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? NqTw.white(0.03) : Tw.slate50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: NqTw.border(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Image ${index + 1}',
                  style: TextStyle(
                    fontSize: 12,
                    height: 16 / 12,
                    fontWeight: FontWeight.w700,
                    color: dark ? Tw.slate400 : Tw.slate500,
                  ),
                ),
              ),
              NqIconButton(
                icon: BootstrapIcons.x_lg,
                size: 24,
                iconSize: 10,
                color: Tw.rose400,
                hoverColor: Tw.rose600,
                background: dark ? Tw.rose900.withValues(alpha: 0.2) : Tw.rose50,
                onTap: () => s._removeImage(index),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _chooseImageButton(context, () => s._onQuestionImageChange(index)),
              if (img.preview.isNotEmpty) ...[
                const SizedBox(width: 8),
                _trashButton(context, () => s._removeQuestionImage(index)),
              ],
            ],
          ),
          if (shown.isNotEmpty) ...[
            const SizedBox(height: 12),
            QuestionImage(
              url: shown,
              maxHeight: 160,
              radius: 20,
              fullWidth: true,
              borderColor: NqTw.border(context),
            ),
          ],
          const SizedBox(height: 12),
          _grid(context, 2, gap: 8, [
            small(
              'Image URL',
              NqTextInput(
                key: ValueKey('img-url-${img.url}'),
                initialValue: img.url,
                readOnly: true,
                height: 32,
                fontSize: 12,
                mdFontSize: 14,
                strongText: false,
                fill: fill,
                hint: 'Image URL',
              ),
            ),
            small(
              'Caption',
              NqTextInput(
                controller: img.caption,
                height: 32,
                fontSize: 12,
                mdFontSize: 14,
                fill: fill,
                hint: 'Optional caption',
              ),
            ),
            small(
              'Display Order',
              NqTextInput(controller: img.order, height: 32, fontSize: 12, mdFontSize: 14, fill: fill, number: true),
            ),
          ]),
        ],
      ),
    );
  }

  // ── VIDEO ──

  Widget _video(BuildContext context) {
    final f = s._qForm;
    final embed = videoEmbedUrl(f.videoUrl.text);
    return NqSectionCard(
      title: 'Video',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NqField(
            label: const NqLabel('Video URL'),
            child: NqTextInput(
              controller: f.videoUrl,
              hint: 'Paste YouTube / Drive / CDN URL',
              onChanged: (_) => s._set(() {}),
            ),
          ),
          if (embed.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: NqTw.border(context)),
                boxShadow: AppShadows.sm,
              ),
              child: AspectRatio(aspectRatio: 16 / 9, child: WebContentView(url: embed)),
            ),
          ],
        ],
      ),
    );
  }

  // ── TAGS ──

  Widget _tags(BuildContext context) => NqSectionCard(
        title: 'Tags',
        child: NqField(
          label: const NqLabel('Tags', suffix: '(comma separated)'),
          child: NqTextInput(
            controller: s._qForm.tagsInput,
            focusNode: s._tagsFocus,
            hint: 'e.g. anatomy, mcq, exam',
          ),
        ),
      );
}
