part of 'new_questions_page.dart';

/// Rebuilds [builder] whenever the page state changes (`_tick`) or the store
/// slice does.
class _Live extends ConsumerWidget {
  const _Live({required this.s, required this.builder});
  final _NewQuestionsPageState s;
  final Widget Function(BuildContext context, QuestionsState store) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final store = ref.watch(questionsControllerProvider);
    return ValueListenableBuilder<int>(
      valueListenable: s._tick,
      builder: (context, _, _) => builder(context, store),
    );
  }
}

/// `px-4 sm:px-6 py-4`
EdgeInsets _bodyPadding(BuildContext context) =>
    EdgeInsets.symmetric(horizontal: context.isSm ? 24 : 16, vertical: 16);

/// `variant="ghost" class="!bg-white dark:!bg-white/5 !text-slate-700
/// font-bold rounded-xl px-4 py-2 h-auto border … text-xs"` — the `!`
/// colours beat the ghost hover, so it never changes.
Widget _cancelButton(BuildContext context) => NqButton.plain(
      context,
      label: 'Cancel',
      fontSize: 12,
      darkText: false,
      hover: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onPressed: () => Navigator.of(context).pop(),
    );

// ── DELETE DIALOG ──────────────────────────────────────────────────────────

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({required this.s});
  final _NewQuestionsPageState s;

  @override
  Widget build(BuildContext context) {
    return _Live(
      s: s,
      builder: (context, _) {
        final dark = context.isDark;
        final sm = context.isSm;
        final q = s._questionToDelete;
        // `w-[calc(100vw-2rem)] max-w-sm`, but the kit's `sm:max-w-lg` still
        // wins from 640px.
        return NqDialogShell(
          maxWidth: sm ? 512 : 384,
          children: [
            NqDialogHeader(
              icon: BootstrapIcons.exclamation_triangle_fill,
              iconColor: Tw.rose500,
              iconSize: 16,
              tileSize: 36,
              tileBg: dark ? Tw.rose900.withValues(alpha: 0.3) : Tw.rose100,
              title: 'Delete Question',
              titleSize: 14,
              titleColor: dark ? Tw.rose400 : Tw.rose600,
              subtitle: 'This action cannot be undone.',
              background: dark ? Tw.rose900.withValues(alpha: 0.1) : Tw.rose50,
            ),
            if (q != null)
              Flexible(
                child: SingleChildScrollView(
                  padding: _bodyPadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Are you sure you want to delete this question?',
                        style: TextStyle(
                          fontSize: sm ? 14 : 12,
                          height: sm ? 20 / 14 : 16 / 12,
                          color: dark ? Tw.slate300 : Tw.slate600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: dark ? NqTw.white(0.05) : Tw.slate50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: NqTw.border(context)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text.rich(
                              TextSpan(children: [
                                const TextSpan(
                                  text: 'Code: ',
                                  style: TextStyle(fontWeight: FontWeight.w700, color: Tw.slate500),
                                ),
                                TextSpan(
                                  text: displayValue(q['code']),
                                  style: TextStyle(color: dark ? Tw.slate200 : Tw.slate800),
                                ),
                              ]),
                              style: TextStyle(fontSize: 12, height: 16 / 12, color: context.fgColor),
                            ),
                            const SizedBox(height: 4),
                            HtmlText(
                              truncate(q['stem']),
                              style: TextStyle(fontSize: 12, height: 16 / 12, color: dark ? Tw.slate300 : Tw.slate700),
                              prefix: const TextSpan(
                                text: 'Question: ',
                                style: TextStyle(fontWeight: FontWeight.w700, color: Tw.slate500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            NqDialogFooter(
              children: [
                _cancelButton(context),
                // `!bg-rose-500 hover:!bg-rose-600 !text-white font-black
                // rounded-xl px-4 py-2 text-xs` + `<i class="bi bi-trash
                // me-1.5" />` (`gap-2` + 6px).
                NqButton(
                  label: 'Delete',
                  icon: BootstrapIcons.trash,
                  iconGap: 14,
                  background: Tw.rose500,
                  hoverBackground: Tw.rose600,
                  foreground: Colors.white,
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  onPressed: s._deleting ? null : () => s._confirmDelete(context),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ── IMPORT DIALOG ──────────────────────────────────────────────────────────

class _ImportDialog extends StatelessWidget {
  const _ImportDialog({required this.s});
  final _NewQuestionsPageState s;

  @override
  Widget build(BuildContext context) {
    return _Live(
      s: s,
      builder: (context, store) {
        final dark = context.isDark;
        // `text-slate-600 dark:text-slate-400` labels.
        final labelColor = dark ? Tw.slate400 : Tw.slate600;
        final courses = store.courses;
        final chapters = store.chapters;
        final contents = s._importFilteredContents;
        return NqDialogShell(
          maxWidth: 512,
          children: [
            const NqDialogHeader(
              icon: BootstrapIcons.upload,
              iconColor: Tw.cyan500,
              title: 'Import Questions',
              subtitle: 'Upload a CSV or Excel file to bulk import.',
            ),
            // `space-y-3 overflow-y-auto max-h-[60vh]`
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.6),
                child: SingleChildScrollView(
                  padding: _bodyPadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      NqField(
                        label: NqLabel('Course', color: labelColor),
                        child: nqSelect(
                          context,
                          value: s._importCourseId,
                          items: courses.isNotEmpty
                              ? [for (final c in courses) AppSelectItem('${c['id']}', displayValue(c['title']))]
                              : const [AppSelectItem(noOptionsValue, 'No courses available', enabled: false)],
                          onChanged: s._setImportCourseId,
                          placeholder: 'Select Course',
                        ),
                      ),
                      const SizedBox(height: 12),
                      NqField(
                        label: NqLabel('Chapter', color: labelColor),
                        child: nqSelect(
                          context,
                          value: s._importChapterId,
                          items: chapters.isNotEmpty
                              ? [for (final c in chapters) AppSelectItem('${c['id']}', displayValue(c['name']))]
                              : const [AppSelectItem.message(noOptionsValue, 'No chapters found', messageColor: Tw.slate400)],
                          onChanged: (v) => s._set(() => s._importChapterId = v),
                          placeholder: 'Select Chapter',
                          enabled: s._importCourseId.isNotEmpty,
                        ),
                      ),
                      const SizedBox(height: 12),
                      NqField(
                        label: NqLabel('Content', color: labelColor),
                        child: nqSelect(
                          context,
                          value: s._importContentId,
                          items: contents.isNotEmpty
                              ? [
                                  for (final c in contents)
                                    AppSelectItem('${c['exam_content_id']}', displayValue(c['name'])),
                                ]
                              : const [AppSelectItem(noOptionsValue, 'No content available', enabled: false)],
                          onChanged: (v) => s._set(() => s._importContentId = v),
                          placeholder: 'Select Content',
                          enabled: s._importChapterId.isNotEmpty,
                        ),
                      ),
                      const SizedBox(height: 12),
                      NqField(
                        label: NqLabel('File (CSV or XLSX)', color: labelColor),
                        // `rounded-xl border-2 border-dashed … p-4 text-center`
                        child: NqDashedBox(
                          color: NqTw.border(context),
                          fill: dark ? NqTw.white(0.05) : Tw.slate50,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // `bi … text-2xl block mb-2`: a 32px line.
                                SizedBox(
                                  height: 32,
                                  child: Center(
                                    child: Icon(
                                      BootstrapIcons.file_earmark_spreadsheet,
                                      size: 24,
                                      color: dark ? Tw.slate600 : Tw.slate300,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Drag & drop or click to browse',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12, height: 16 / 12, color: Tw.slate500),
                                ),
                                const SizedBox(height: 8),
                                // `<Input type="file" class="text-xs">` (the
                                // kit's `md:text-sm` stays).
                                ShadFileInput(
                                  onPick: s._onFileChange,
                                  fileName: s._importFile?.name,
                                  fontSize: context.isMd ? 14 : 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            NqDialogFooter(
              children: [
                _cancelButton(context),
                // `<span><i class="bi bi-upload me-1.5" />Import</span>`;
                // importing: `<span class="flex gap-1.5"><svg/>Uploading...`.
                NqButton(
                  label: 'Import',
                  icon: BootstrapIcons.upload,
                  iconGap: 6,
                  loading: s._importing,
                  loadingLabel: 'Uploading...',
                  fontSize: 12,
                  minWidth: 100,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  onPressed: () => s._handleImport(context),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ── QUESTION PREVIEW DIALOG ────────────────────────────────────────────────

class _PreviewDialog extends StatelessWidget {
  const _PreviewDialog({required this.s});
  final _NewQuestionsPageState s;

  @override
  Widget build(BuildContext context) {
    return _Live(
      s: s,
      builder: (context, _) {
        final p = s._previewQuestion;
        final sm = context.isSm;
        // `w-[calc(100vw-1rem)] sm:max-w-3xl max-h-[90vh]`; below 640px the
        // kit's `max-w-[calc(100%-2rem)]` still applies.
        return NqDialogShell(
          maxWidth: sm ? 768 : double.infinity,
          insetPadding: EdgeInsets.all(sm ? 8 : 16),
          maxHeight: MediaQuery.sizeOf(context).height * 0.9,
          children: [
            const NqDialogHeader(icon: BootstrapIcons.eye_fill, iconColor: Tw.blue500, title: 'Question Preview'),
            if (p != null)
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: sm ? 24 : 16, vertical: 20),
                  child: _body(context, p),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _body(BuildContext context, PreviewQuestion p) {
    final dark = context.isDark;
    final q = p.raw;
    final hasImages = p.images.isNotEmpty;
    final border = NqTw.border(context);

    // `px-3 py-1.5 rounded-lg text-xs font-bold transition`, active
    // `!bg-cyan-500 !text-slate-900`, else `bg-slate-100 dark:bg-white/10
    // text-slate-600 dark:text-slate-400` (no hover style).
    Widget tab(String key, String label) {
      final active = s._activeMedia == key;
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => s._set(() => s._activeMedia = key),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: active ? Tw.cyan500 : (dark ? NqTw.white(0.1) : Tw.slate100),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w700,
                color: active ? Tw.slate900 : (dark ? Tw.slate400 : Tw.slate600),
              ),
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: dark ? NqTw.white(0.05) : Tw.slate50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: border),
          ),
          child: HtmlText(
            displayValue(q['stem']),
            style: TextStyle(fontSize: 14, height: 1.625, color: dark ? Tw.slate200 : Tw.slate800),
          ),
        ),
        const SizedBox(height: 20),
        if (hasImages || p.hasVideo) ...[
          if (hasImages && p.hasVideo) ...[
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
              child: Row(children: [tab('image', 'Image'), const SizedBox(width: 4), tab('video', 'Video')]),
            ),
            const SizedBox(height: 12),
          ],
          if (s._activeMedia == 'image' && hasImages)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < p.images.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  QuestionImage(
                    url: getDirectImage(p.images[i]['image_url']),
                    maxHeight: 288,
                    radius: 20,
                    borderColor: border,
                  ),
                ],
              ],
            ),
          if (s._activeMedia == 'video' && p.hasVideo)
            QuestionVideoView(
              type: p.videoType,
              src: p.videoSrc,
              radius: 20,
              videoMaxHeight: 380,
              borderColor: border,
            ),
          const SizedBox(height: 20),
        ],
        if (q['question_type'] == 'MCQ')
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < p.options.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _option(context, p.options[i]),
              ],
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dark ? NqTw.white(0.05) : Tw.slate50,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: const Text(
              'Student will type their answer here (SAQ / MEQ)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, height: 16 / 12, fontStyle: FontStyle.italic, color: Tw.slate400),
            ),
          ),
      ],
    );
  }

  Widget _option(BuildContext context, Map<String, dynamic> opt) {
    final dark = context.isDark;
    final correct = jsTruthy(opt['is_correct']);
    final text = opt['option_text'];
    final image = opt['image_url'];
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: correct
            ? (dark ? Tw.emerald900.withValues(alpha: 0.2) : Tw.emerald50)
            : (dark ? NqTw.white(0.05) : Colors.white),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: correct ? (dark ? Tw.emerald500.withValues(alpha: 0.3) : Tw.emerald200) : NqTw.border(context),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            margin: const EdgeInsets.only(top: 2),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: correct ? Tw.emerald500 : (dark ? NqTw.white(0.1) : Tw.slate100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              displayValue(opt['option_label']),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: correct ? Colors.white : (dark ? Tw.slate400 : Tw.slate600),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (jsTruthy(text))
                  Text(
                    displayValue(text),
                    style: TextStyle(fontSize: 12, height: 16 / 12, color: dark ? Tw.slate300 : Tw.slate700),
                  ),
                if (jsTruthy(image)) ...[
                  if (jsTruthy(text)) const SizedBox(height: 6),
                  QuestionImage(
                    url: getDirectImage(image),
                    maxHeight: 128,
                    radius: 16,
                    shadow: false,
                    borderColor: NqTw.border(context),
                  ),
                ],
                if (correct) ...[
                  if (jsTruthy(text) || jsTruthy(image)) const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(BootstrapIcons.check_circle_fill, size: 10, color: dark ? Tw.emerald400 : Tw.emerald600),
                      const SizedBox(width: 4),
                      Text(
                        'Correct Answer',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: dark ? Tw.emerald400 : Tw.emerald600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── IMPORT RESULT DIALOG ───────────────────────────────────────────────────

class _ImportResultDialog extends StatelessWidget {
  const _ImportResultDialog({required this.s});
  final _NewQuestionsPageState s;

  Widget _stat(BuildContext context, String label, Object? value, {required bool success}) {
    final dark = context.isDark;
    final fg = success ? (dark ? Tw.emerald400 : Tw.emerald600) : (dark ? Tw.rose400 : Tw.rose600);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: success
            ? (dark ? Tw.emerald900.withValues(alpha: 0.2) : Tw.emerald50)
            : (dark ? Tw.rose900.withValues(alpha: 0.2) : Tw.rose50),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: success
              ? (dark ? Tw.emerald500.withValues(alpha: 0.3) : Tw.emerald200)
              : (dark ? Tw.rose500.withValues(alpha: 0.3) : Tw.rose200),
        ),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 10, height: 1.5, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: fg),
          ),
          const SizedBox(height: 4),
          Text(
            displayValue(value),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 30, height: 36 / 30, fontWeight: FontWeight.w900, color: fg),
          ),
        ],
      ),
    );
  }

  Widget _list(
    BuildContext context,
    String title,
    List<dynamic> items, {
    required Color titleColor,
    required Color bg,
    required Color border,
    required Color fg,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(fontSize: 10, height: 1.5, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: titleColor),
          ),
          const SizedBox(height: 8),
          Container(
            constraints: const BoxConstraints(maxHeight: 144),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: border),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < items.length; i++) ...[
                    if (i > 0) const SizedBox(height: 4),
                    Text('• ${displayValue(items[i])}', style: TextStyle(fontSize: 12, height: 16 / 12, color: fg)),
                  ],
                ],
              ),
            ),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return _Live(
      s: s,
      builder: (context, _) {
        final dark = context.isDark;
        final r = asMap(s._importResult);
        final errors = asList(r?['errors']);
        final failedImages = asList(r?['failedImageUrls']);
        return NqDialogShell(
          maxWidth: 512,
          children: [
            const NqDialogHeader(icon: BootstrapIcons.clipboard_data, iconColor: Tw.indigo500, title: 'Import Report'),
            if (s._importResult != null)
              Flexible(
                child: SingleChildScrollView(
                  padding: _bodyPadding(context),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _stat(context, 'Imported', r?['success'], success: true)),
                          const SizedBox(width: 12),
                          Expanded(child: _stat(context, 'Failed', r?['failed'], success: false)),
                        ],
                      ),
                      if (errors.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _list(
                          context,
                          'Row Errors',
                          errors,
                          titleColor: Tw.rose500,
                          bg: dark ? Tw.rose900.withValues(alpha: 0.2) : Tw.rose50,
                          border: dark ? Tw.rose500.withValues(alpha: 0.3) : Tw.rose200,
                          fg: dark ? Tw.rose300 : Tw.rose700,
                        ),
                      ],
                      if (failedImages.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _list(
                          context,
                          'Failed Image URLs',
                          failedImages,
                          titleColor: Tw.amber500,
                          bg: dark ? Tw.amber900.withValues(alpha: 0.2) : Tw.amber50,
                          border: dark ? Tw.amber500.withValues(alpha: 0.3) : Tw.amber200,
                          fg: dark ? Tw.amber300 : Tw.amber700,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            NqDialogFooter(
              children: [
                // `<i class="bi bi-check-lg me-1.5" />Done` (`gap-2` + 6px).
                NqButton(
                  label: 'Done',
                  icon: BootstrapIcons.check_lg,
                  iconGap: 14,
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
