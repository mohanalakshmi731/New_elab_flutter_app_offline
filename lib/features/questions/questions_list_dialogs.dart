part of 'questions_list_page.dart';

/// Rebuilds [builder] whenever the page state changes (`_tick`) or the store
/// slice does.
class _Live extends ConsumerWidget {
  const _Live({required this.s, required this.builder});
  final _QuestionsListPageState s;
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

// ── DELETE DIALOG ──────────────────────────────────────────────────────────

class _DeleteDialog extends StatelessWidget {
  const _DeleteDialog({required this.s});
  final _QuestionsListPageState s;

  @override
  Widget build(BuildContext context) {
    return _Live(
      s: s,
      builder: (context, _) {
        final dark = context.isDark;
        final q = s._questionToDelete;
        return AppDialogFrame(
          maxWidth: 448,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(color: Tw.red100, shape: BoxShape.circle),
                    child: const Icon(BootstrapIcons.trash3_fill, color: Tw.red600, size: 20),
                  ),
                  const SizedBox(height: 12),
                  // `<DialogTitle class="text-lg font-semibold text-gray-900">`
                  // (the later `text-lg` drops the kit's `leading-none`).
                  const Text(
                    'Delete Question',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w600, color: Tw.gray900),
                  ),
                  const SizedBox(height: 12),
                  const Text.rich(
                    TextSpan(
                      text: 'Are you sure you want to delete this question?\n',
                      children: [
                        TextSpan(
                          text: 'This action cannot be undone.',
                          style: TextStyle(color: Tw.red500, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: 1.625, color: Tw.gray600),
                  ),
                ],
              ),
              // DialogContent `grid gap-4` + the box's `mt-4`.
              if (q != null)
                Container(
                  margin: const EdgeInsets.only(top: 32),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dark ? AppColors.darkMuted : AppColors.muted,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: dark ? AppColors.darkBorder : AppColors.border),
                  ),
                  child: DefaultTextStyle.merge(
                    style: const TextStyle(fontSize: 14, height: 20 / 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(TextSpan(children: [
                          const TextSpan(text: 'Code:', style: TextStyle(fontWeight: FontWeight.w700)),
                          TextSpan(text: ' ${displayValue(q['code'])}'),
                        ])),
                        const SizedBox(height: 8),
                        HtmlText(
                          truncate(q['stem']),
                          style: const TextStyle(fontSize: 14, height: 20 / 14),
                          prefix: const TextSpan(text: 'Question: ', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ),
              // `gap-4` + the actions' `mt-6`.
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 100),
                    child: AppButton(
                      label: 'No',
                      variant: AppButtonVariant.outline,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 100),
                    child: AppButton(
                      label: s._deleting ? 'Deleting...' : 'Yes',
                      backgroundColor: Tw.red600,
                      hoverBackgroundColor: Tw.red700,
                      foregroundColor: Colors.white,
                      onPressed: s._deleting ? null : () => s._confirmDelete(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── IMPORT DIALOG ──────────────────────────────────────────────────────────

class _ImportDialog extends StatelessWidget {
  const _ImportDialog({required this.s});
  final _QuestionsListPageState s;

  Widget _field(String label, Widget child) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [FieldLabel(label), child],
      );

  @override
  Widget build(BuildContext context) {
    return _Live(
      s: s,
      builder: (context, store) {
        final courses = store.courses;
        final chapters = store.chapters;
        final contents = s._importFilteredContents;
        return AppDialogFrame(
          maxWidth: 512,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // `<h3 class="text-lg font-semibold mb-4 text-primary">`; its
              // `mb-4` adds to the dialog's `gap-4`.
              Padding(
                padding: const EdgeInsets.only(right: 28, bottom: 32),
                child: Text(
                  'Import Questions',
                  style: TextStyle(
                    fontSize: 18,
                    height: 28 / 18,
                    fontWeight: FontWeight.w600,
                    color: context.colors.primary,
                  ),
                ),
              ),
              _field(
                'Language',
                AppSelect<String>(
                  value: s._importLocale,
                  placeholder: 'Select Language',
                  items: [for (final e in questionLocales.entries) AppSelectItem(e.value, e.key)],
                  onChanged: (v) => s._set(() => s._importLocale = v ?? ''),
                ),
              ),
              const SizedBox(height: 16),
              _field(
                'Course',
                AppSelect<String>(
                  value: s._importCourseId,
                  placeholder: 'Select Course',
                  items: courses.isNotEmpty
                      ? [for (final c in courses) AppSelectItem('${c['id']}', displayValue(c['title']))]
                      : const [AppSelectItem(noOptionsValue, 'No courses available', enabled: false)],
                  onChanged: (v) => s._setImportCourseId(v ?? ''),
                ),
              ),
              const SizedBox(height: 16),
              _field(
                'Chapter',
                AppSelect<String>(
                  value: s._importChapterId,
                  enabled: s._importCourseId.isNotEmpty,
                  placeholder: 'Select Chapter',
                  items: chapters.isNotEmpty
                      ? [for (final c in chapters) AppSelectItem('${c['id']}', displayValue(c['name']))]
                      : const [AppSelectItem.message(noOptionsValue, 'No chapters found')],
                  onChanged: (v) => s._set(() => s._importChapterId = v ?? ''),
                ),
              ),
              const SizedBox(height: 16),
              _field(
                'Content',
                AppSelect<String>(
                  value: s._importContentId,
                  enabled: s._importChapterId.isNotEmpty,
                  placeholder: 'Select Content',
                  items: contents.isNotEmpty
                      ? [
                          for (final c in contents)
                            AppSelectItem('${c['exam_content_id']}', displayValue(c['name'])),
                        ]
                      : const [AppSelectItem(noOptionsValue, 'No content available', enabled: false)],
                  onChanged: (v) => s._set(() => s._importContentId = v ?? ''),
                ),
              ),
              const SizedBox(height: 16),
              _field(
                'Select Excel or CSV file',
                ShadFileInput(onPick: s._onFileChange, fileName: s._importFile?.name),
              ),
              // `gap-4` + the buttons' `mt-6`.
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    label: 'Cancel',
                    variant: AppButtonVariant.outline,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(minWidth: 110),
                    // `:disabled="importing"`: the spinner SVG + "Uploading...".
                    child: AppButton(
                      label: s._importing ? null : 'Import',
                      onPressed: s._importing ? null : () => s._handleImport(context),
                      child: s._importing
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TwSpinner(shape: TwSpinnerShape.arrow),
                                SizedBox(width: 8),
                                Text('Uploading...'),
                              ],
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── QUESTION PREVIEW ───────────────────────────────────────────────────────

class _PreviewDialog extends StatelessWidget {
  const _PreviewDialog({required this.s});
  final _QuestionsListPageState s;

  @override
  Widget build(BuildContext context) {
    return _Live(
      s: s,
      builder: (context, _) {
        final dark = context.isDark;
        final border = dark ? AppColors.darkBorder : AppColors.border;
        final primary = context.colors.primary;
        final p = s._previewQuestion;
        final height = MediaQuery.sizeOf(context).height * 0.9;
        // `w-[95vw] sm:max-w-3xl h-[90vh] p-0 flex flex-col` (+ the kit's
        // `max-w-[calc(100%-2rem)]` and `gap-4`).
        return AppDialogFrame(
          maxWidth: context.isSm ? 768 : double.infinity,
          widthFactor: 0.95,
          padding: EdgeInsets.zero,
          child: SizedBox(
            height: height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(24, 16, 52, 16),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
                  child: Text(
                    'Question Preview',
                    style: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, color: primary),
                  ),
                ),
                const SizedBox(height: 16),
                if (p != null)
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                      child: _body(context, p, border),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _body(BuildContext context, PreviewQuestion p, Color border) {
    final dark = context.isDark;
    final q = p.raw;
    final hasImages = p.images.isNotEmpty;
    final muted = dark ? AppColors.darkMuted : AppColors.muted;

    // `px-4 py-2 rounded-md text-sm font-medium transition`, active
    // `bg-primary text-white`, else `bg-muted hover:bg-muted/70`.
    Widget tab(String key, String label) {
      final active = s._activeMedia == key;
      return _HoverBox(
        onTap: () => s._set(() => s._activeMedia = key),
        builder: (hover) => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: active ? context.colors.primary : (hover ? muted.withValues(alpha: 0.7) : muted),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w500,
              color: active ? Colors.white : context.fgColor,
            ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HtmlText(displayValue(q['stem']), style: const TextStyle(fontSize: 16, height: 1.625)),
        const SizedBox(height: 24),
        if (hasImages || p.hasVideo) ...[
          if (hasImages && p.hasVideo) ...[
            Container(
              padding: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
              child: Row(children: [tab('image', 'Image'), const SizedBox(width: 8), tab('video', 'Video')]),
            ),
            const SizedBox(height: 16),
          ],
          if (s._activeMedia == 'image' && hasImages)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < p.images.length; i++) ...[
                  if (i > 0) const SizedBox(height: 16),
                  QuestionImage(url: getDirectImage(p.images[i]['image_url']), maxHeight: 320),
                ],
              ],
            ),
          if (s._activeMedia == 'video' && p.hasVideo)
            QuestionVideoView(
              type: p.videoType,
              src: p.videoSrc,
              radius: 16,
              videoMaxHeight: 420,
              showLinkFallback: true,
            ),
          const SizedBox(height: 24),
        ],
        if (q['question_type'] == 'MCQ')
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < p.options.length; i++) ...[
                if (i > 0) const SizedBox(height: 12),
                _option(context, p.options[i], border),
              ],
            ],
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
            child: Text(
              'Student will type answer here (SAQ / MEQ)',
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                fontStyle: FontStyle.italic,
                color: context.mutedFgColor,
              ),
            ),
          ),
      ],
    );
  }

  Widget _option(BuildContext context, Map<String, dynamic> opt, Color border) {
    final text = opt['option_text'];
    final image = opt['image_url'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: border)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${displayValue(opt['option_label'])}.',
              style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (jsTruthy(text)) Text(displayValue(text), style: const TextStyle(fontSize: 16, height: 1.5)),
                if (jsTruthy(image)) ...[
                  if (jsTruthy(text)) const SizedBox(height: 8),
                  // `max-h-40 rounded border`: bare `rounded` is 0.25rem (not the theme radius).
                  QuestionImage(url: getDirectImage(image), maxHeight: 160, radius: 4, shadow: false),
                ],
                if (jsTruthy(opt['is_correct'])) ...[
                  if (jsTruthy(text) || jsTruthy(image)) const SizedBox(height: 8),
                  const Text(
                    'Correct Answer',
                    style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w600, color: Tw.green600),
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

// ── IMPORT REPORT ──────────────────────────────────────────────────────────

class _ImportResultDialog extends StatelessWidget {
  const _ImportResultDialog({required this.s});
  final _QuestionsListPageState s;

  Widget _stat(String label, Object? value, Color bg, Color border, Color labelColor, Color valueColor) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border),
        ),
        child: Column(
          children: [
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 20 / 14, color: labelColor)),
            Text(
              displayValue(value),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w700, color: valueColor),
            ),
          ],
        ),
      );

  Widget _list(String title, Color titleColor, List<dynamic> items, Color bg, BuildContext context) {
    final border = context.isDark ? AppColors.darkBorder : AppColors.border;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: titleColor)),
        const SizedBox(height: 8),
        Container(
          constraints: const BoxConstraints(maxHeight: 160),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 4),
                  Text('• ${displayValue(items[i])}', style: const TextStyle(fontSize: 14, height: 20 / 14)),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _Live(
      s: s,
      builder: (context, _) {
        final r = asMap(s._importResult);
        final errors = asList(r?['errors']);
        final failedImages = asList(r?['failedImageUrls']);
        return AppDialogFrame(
          maxWidth: 576,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // `<h3 class="text-xl font-semibold text-primary mb-4">` (+ `gap-4`).
              Padding(
                padding: const EdgeInsets.only(right: 28, bottom: 32),
                child: Text(
                  'Import Report',
                  style: TextStyle(
                    fontSize: 20,
                    height: 28 / 20,
                    fontWeight: FontWeight.w600,
                    color: context.colors.primary,
                  ),
                ),
              ),
              if (s._importResult != null) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _stat('Successfully Uploaded', r?['success'], Tw.green50, Tw.green200,
                          Tw.green700, Tw.green600),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _stat('Failed', r?['failed'], Tw.red50, Tw.red200, Tw.red700, Tw.red600),
                    ),
                  ],
                ),
                if (errors.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _list('Row Errors', Tw.red600, errors, Tw.red50, context),
                ],
                if (failedImages.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _list('Failed Image URLs', Tw.orange600, failedImages, Tw.orange50, context),
                ],
              ],
              // `gap-4` + the row's `mt-6`.
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerRight,
                child: AppButton(label: 'Close', onPressed: () => Navigator.of(context).pop()),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A hover-aware tap target without Material ink (a plain `<button>`).
class _HoverBox extends StatefulWidget {
  const _HoverBox({required this.onTap, required this.builder});
  final VoidCallback onTap;
  final Widget Function(bool hover) builder;

  @override
  State<_HoverBox> createState() => _HoverBoxState();
}

class _HoverBoxState extends State<_HoverBox> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(onTap: widget.onTap, child: widget.builder(_hover)),
      );
}
