part of 'create_question_page.dart';

/// The cards of `createquestion.vue` (`<Card class="mb-6">` with a
/// `<CardHeader>` and a `<CardContent class="space-y-5">`).
extension _CreateQuestionCards on _CreateQuestionPageState {
  /// `<Card>` → `<CardHeader>` (px-6) + `<CardContent>` (px-6).
  Widget _card({required Widget header, required List<Widget> content, double spacing = 20}) {
    return ExmCard(
      children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: header),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < content.length; i++) ...[
                if (i > 0) SizedBox(height: spacing),
                content[i],
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// `<CardHeader class="flex justify-between items-center">` with a small button.
  Widget _headerWithButton(String title, String button, VoidCallback onPressed) => Row(
        children: [
          Expanded(child: ExmCardTitle(title, primary: true)),
          AppButton(label: button, size: AppButtonSize.sm, onPressed: onPressed),
        ],
      );

  Widget _numberField(TextEditingController c, ValueChanged<Object?> onValue) => AppTextField(
        controller: c,
        keyboardType: exmNumberKeyboard,
        inputFormatters: exmNumberFormatters,
        onChanged: (t) => onValue(vueNumberInput(t)),
      );

  /// `rounded-lg border shadow h-[200px] w-full object-contain`
  Widget _previewBox(String src) {
    return Container(
      height: 200,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: context.borderColor),
        boxShadow: AppShadows.base,
      ),
      child: ExmImage(src, key: ValueKey(src)),
    );
  }

  /// `<Button size="sm" variant="ghost" class="text-red-500">Remove Image</Button>`
  Widget _removeImageButton(VoidCallback onPressed) => Align(
        alignment: Alignment.centerLeft,
        child: AppButton(
          label: 'Remove Image',
          size: AppButtonSize.sm,
          variant: AppButtonVariant.ghost,
          foregroundColor: Tw.red500,
          onPressed: onPressed,
        ),
      );

  /// `<label>…</label> <Button size="sm" variant="outline" class="mx-2">Choose Image</Button>`:
  /// both inline, so they share a line (a space + the button's `ml-2`).
  Widget _chooseImageRow(String label, VoidCallback onPressed) => Row(
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 20 / 14)),
          const SizedBox(width: 12),
          AppButton(
            label: 'Choose Image',
            size: AppButtonSize.sm,
            variant: AppButtonVariant.outline,
            onPressed: onPressed,
          ),
        ],
      );

  // ── Basic Information ────────────────────────────────────────────────────

  Widget _basicInformationCard() {
    return _card(
      header: const ExmCardTitle('Basic Information', primary: true),
      content: [
        PlainLabeled(
          label: 'Language',
          child: AppSelect<String>(
            value: _defaultLocale,
            placeholder: 'Select language',
            items: [for (final e in examLocales.entries) AppSelectItem(e.value, e.key)],
            onChanged: (v) => _set(() => _defaultLocale = v ?? _defaultLocale),
          ),
        ),
        PlainLabeled(
          label: 'Question Code',
          child: AppTextField(controller: _code, hint: 'Enter question code'),
        ),
        PlainLabeled(
          label: 'Question Type',
          child: AppSelect<String>(
            value: _questionType,
            placeholder: 'Select question type',
            items: const [AppSelectItem('MCQ', 'MCQ')],
            onChanged: (v) => _set(() => _questionType = v ?? _questionType),
          ),
        ),
        PlainLabeled(
          label: 'Question Text',
          // `field-sizing-content min-h-16`: `rows` has no effect.
          child: AppTextField(controller: _stem, hint: 'Enter question text', maxLines: null),
        ),
        PlainLabeled(
          label: 'Difficulty',
          child: AppSelect<String>(
            value: _difficulty,
            placeholder: 'Select difficulty',
            items: const [
              AppSelectItem('EASY', 'EASY'),
              AppSelectItem('MEDIUM', 'MEDIUM'),
              AppSelectItem('HARD', 'HARD'),
            ],
            onChanged: (v) => _set(() => _difficulty = v ?? _difficulty),
          ),
        ),
        PlainLabeled(label: 'Marks', child: _numberField(_marks, (v) => _marksValue = v)),
        PlainLabeled(label: 'Negative Marks', child: _numberField(_negativeMarks, (v) => _negativeMarksValue = v)),
        PlainLabeled(
          label: 'Explanation',
          child: AppTextField(controller: _explanation, maxLines: null),
        ),
        Row(
          children: [
            ShadSwitch(value: jsTruthy(_isActive), onChanged: (v) => _set(() => _isActive = v)),
            const SizedBox(width: 12),
            const Text('Active Question', style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  // ── Association ──────────────────────────────────────────────────────────

  Widget _associationCard(List<Json> courses, List<Json> chapters, List<Json> contents) {
    return _card(
      header: const ExmCardTitle('Association', primary: true),
      content: [
        PlainLabeled(
          label: 'Course',
          child: AppSelect<String>(
            value: _selectedCourseId,
            placeholder: 'Select course',
            items: [for (final c in courses) AppSelectItem(jsField(c, 'id'), vueText(c['title']))],
            onChanged: (v) => _setSelectedCourseId(v ?? ''),
          ),
        ),
        PlainLabeled(
          label: 'Chapter',
          child: AppSelect<String>(
            value: _selectedChapterId,
            enabled: _selectedCourseId.isNotEmpty,
            placeholder: 'Select chapter',
            items: [for (final ch in chapters) AppSelectItem(jsField(ch, 'id'), vueText(ch['name']))],
            onChanged: (v) => _set(() => _selectedChapterId = v ?? ''),
          ),
        ),
        PlainLabeled(
          label: 'Content',
          child: AppSelect<String>(
            value: _selectedContentId,
            enabled: _selectedChapterId.isNotEmpty,
            placeholder: 'Select content',
            items: [
              for (final c in contentsOfChapter(contents, _selectedChapterId))
                AppSelectItem(jsField(c, 'exam_content_id'), vueText(c['name'])),
            ],
            onChanged: (v) => _set(() => _selectedContentId = v ?? ''),
          ),
        ),
      ],
    );
  }

  // ── MCQ Options ──────────────────────────────────────────────────────────

  Widget _optionsCard() {
    final border = context.isDark ? AppColors.darkBorder : AppColors.border;
    return _card(
      header: _headerWithButton('Options', 'Add Option', _addOption),
      spacing: 16,
      content: [
        for (var index = 0; index < _options.length; index++)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: _optionBody(index),
          ),
      ],
    );
  }

  Widget _optionBody(int index) {
    final opt = _options[index];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlainLabeled(
          label: 'Option Label',
          child: AppTextField(
            key: ValueKey('option-label-$index-${opt.label}'),
            initialValue: vueText(opt.label),
            enabled: false,
          ),
        ),
        const SizedBox(height: 16),
        PlainLabeled(
          label: 'Option Text',
          child: AppTextField(controller: opt.text, hint: 'Enter option text'),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ShadSwitch(value: jsTruthy(opt.correct), onChanged: (v) => _set(() => opt.correct = v)),
            const SizedBox(width: 12),
            const Text('Correct Answer', style: TextStyle(fontSize: 14, height: 20 / 14)),
            const Spacer(),
            AppButton(
              size: AppButtonSize.icon,
              variant: AppButtonVariant.ghost,
              onPressed: () => _removeOption(index),
              child: const Text('✕'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // OPTION IMAGE (`space-y-2`): the label and the button share a line
        // whose `mb-2` adds to the URL input's `mt-2` (16); a preview between
        // them collapses that to 8 + 8.
        _chooseImageRow('Option Image', () => _chooseOptionImage(index)),
        if (opt.preview.isNotEmpty) ...[
          const SizedBox(height: 8),
          _previewBox(opt.preview),
          const SizedBox(height: 8),
        ] else
          const SizedBox(height: 16),
        AppTextField(controller: opt.image, hint: 'Image URL', readOnly: true),
        if (opt.preview.isNotEmpty) ...[
          const SizedBox(height: 8),
          _removeImageButton(() => _removeOptionImage(index)),
        ],
      ],
    );
  }

  // ── Images (question level) ──────────────────────────────────────────────

  Widget _imagesCard() {
    final border = context.isDark ? AppColors.darkBorder : AppColors.border;
    return _card(
      header: _headerWithButton('Images', 'Add Image', _addImage),
      spacing: 16,
      content: [
        for (var index = 0; index < _images.length; index++)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: _imageBody(index),
          ),
      ],
    );
  }

  Widget _imageBody(int index) {
    final img = _images[index];
    final shown = img.preview.isNotEmpty ? img.preview : img.url.text;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _chooseImageRow('Image', () => _chooseQuestionImage(index)),
        if (shown.isNotEmpty) ...[
          const SizedBox(height: 12),
          _previewBox(shown),
        ],
        const SizedBox(height: 12),
        PlainLabeled(
          label: 'Image URL',
          child: AppTextField(controller: img.url, hint: 'Image URL', readOnly: true),
        ),
        const SizedBox(height: 12),
        PlainLabeled(
          label: 'Caption',
          child: AppTextField(controller: img.caption, hint: 'Optional caption'),
        ),
        if (img.preview.isNotEmpty) ...[
          const SizedBox(height: 12),
          _removeImageButton(() => _removeQuestionImage(index)),
        ],
        const SizedBox(height: 12),
        PlainLabeled(
          label: 'Display Order',
          child: _numberField(img.orderText, (v) => img.orderIndex = v),
        ),
      ],
    );
  }

  // ── Video ────────────────────────────────────────────────────────────────

  Widget _videoCard() {
    final embed = videoEmbedUrl(_videoUrl.text);
    final dark = context.isDark;
    return _card(
      header: const ExmCardTitle('Video', primary: true),
      spacing: 16,
      content: [
        PlainLabeled(
          label: 'Video URL',
          child: AppTextField(controller: _videoUrl, hint: 'Paste video url (YouTube / Drive / CDN)'),
        ),
        if (embed.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 672),
                child: Container(
                  height: 288,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: dark ? AppColors.darkBorder : AppColors.border),
                    boxShadow: AppShadows.base,
                  ),
                  child: WebContentView(url: embed),
                ),
              ),
            ),
          ),
      ],
    );
  }

  // ── Tags ─────────────────────────────────────────────────────────────────

  Widget _tagsCard() {
    return _card(
      header: const ExmCardTitle('Tags', primary: true),
      content: [
        PlainLabeled(
          label: 'Tags (comma separated)',
          child: AppTextField(
            controller: _tagsInput,
            focusNode: _tagsFocus,
            hint: 'e.g. anatomy, mcq, exam',
          ),
        ),
      ],
    );
  }
}
