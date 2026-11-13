part of 'exam_create_view.dart';

/// "Exam Sections", "Exam Images" and the Cancel / Create buttons of
/// `examcreate.vue`.
extension _ExamCreateSections on _ExamCreateViewState {
  // ── Exam Sections ──

  Widget _sectionsCard(ExamsState s) {
    final topics = topicsOf(s.sections, _selectedSubjectId);
    return _card([
      Row(
        children: [
          Expanded(child: _cardTitle('Exam Sections', primary: true, required: true)),
          AppButton(
            label: 'Add Section',
            onPressed: () => _set(() => _sections.add(_SectionDraft())),
          ),
        ],
      ),
      if (_sections.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24),
          child: Text(
            'No sections added. Add at least one section to generate questions for the exam.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 20 / 14, color: context.exMutedFg),
          ),
        ),
      // `<Card class="p-4 mb-4">` per section.
      for (var i = 0; i < _sections.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _sectionCard(i, topics),
        ),
    ]);
  }

  Widget _sectionCard(int sectionIndex, List<Json> topics) {
    final section = _sections[sectionIndex];
    final rules = section.rules;
    return ExamCard(
      padding: const EdgeInsets.all(16),
      child: GapColumn(children: [
        Row(
          children: [
            Expanded(child: _cardTitle('Section ${sectionIndex + 1}', required: true)),
            ExamTrashButton(onPressed: () => _set(() => _disposeLater(_sections.removeAt(sectionIndex).dispose))),
          ],
        ),
        // `space-y-4`
        GapColumn(gap: 16, children: [
          _field(
            'Section Name',
            AppTextField(controller: section.name, hint: 'Section Name'),
            required: true,
            block: true,
          ),
          _field('Description', _textarea(section.description, 'Description'), block: true),
          _grid([
            _field(
              'Number of Questions',
              _numberField(section.questionCount, 'Number of Questions'),
              required: true,
              block: true,
            ),
            _field('Marks Per Question', _numberField(section.marksPerQuestion, 'Marks Per Question'), block: true),
          ], context.isSm ? 2 : 1),
          // `flex items-center justify-between pt-2`
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                const Expanded(child: ExamFieldLabel('Question Selection Rules')),
                ExamAddRuleButton(onPressed: () => _set(() => rules.add(_RuleDraft()))),
              ],
            ),
          ),
          // `text-muted-foreground … text-red-500`: the red wins.
          if (rules.length <= 1)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text(
                'No rules added. Add a rule to select questions, or leave empty to select any questions.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, height: 20 / 14, color: Tw.red500),
              ),
            ),
          // The first rule is never shown (`rules.slice(1)`), and the trash
          // button removes `rules[index]` — the rule *before* the card. Kept.
          if (rules.isNotEmpty)
            GapColumn(gap: 16, children: [
              for (var index = 0; index < rules.length - 1; index++) _ruleCard(sectionIndex, rules, index, topics),
            ]),
        ]),
      ]),
    );
  }

  Widget _ruleCard(int sectionIndex, List<_RuleDraft> rules, int index, List<Json> topics) {
    final rule = rules[index + 1];
    final cols = context.isLg ? 5 : (context.isSm ? 2 : 1);
    return ExamCard(
      padding: const EdgeInsets.all(16),
      // `bg-gray-50` replaces `bg-card` in both modes (no dark variant).
      color: Tw.gray50,
      child: GapColumn(children: [
        Row(
          children: [
            Expanded(child: _cardTitle('Rule ${index + 1}')),
            ExamTrashButton(onPressed: () => _set(() => _disposeLater(rules.removeAt(index).dispose))),
          ],
        ),
        // `grid gap-4 sm:grid-cols-2 lg:grid-cols-5`; the triggers' `h-10`
        // loses to the kit's `data-[size=default]:h-9`.
        _grid([
          _field(
            'Topic',
            _select<String>(
              value: rule.topicId.isEmpty ? null : rule.topicId,
              placeholder: 'Select Topic',
              items: [for (final t in topics) AppSelectItem(jsStr(t['exam_content_id']), display(t['name']))],
              onChanged: (v) => _set(() => rule.topicId = v ?? ''),
            ),
          ),
          _field(
            'Difficulty',
            _select<String>(
              value: rule.difficulty.isEmpty ? null : rule.difficulty,
              placeholder: 'Difficulty',
              items: const [
                AppSelectItem('EASY', 'Easy'),
                AppSelectItem('MEDIUM', 'Medium'),
                AppSelectItem('HARD', 'Hard'),
              ],
              onChanged: (v) => _set(() => rule.difficulty = v ?? ''),
            ),
          ),
          _field(
            'Question Type',
            _select<String>(
              value: rule.questionType.isEmpty ? null : rule.questionType,
              placeholder: 'Question Type',
              items: const [AppSelectItem('MCQ', 'MCQ')],
              onChanged: (v) => _set(() => rule.questionType = v ?? ''),
            ),
          ),
          // Not bound to the rule on the web (typed text stays with the card slot).
          _field(
            'Tags',
            AppTextField(key: ValueKey('tags-$sectionIndex-$index'), hint: 'Tags', fillColor: _bgWhite),
          ),
          _field('Pick Count', _numberField(rule.pickCount, 'Pick Count', white: true)),
        ], cols),
      ]),
    );
  }

  // ── Exam Images ──

  Widget _imagesCard() {
    return _card([
      Padding(padding: const EdgeInsets.only(bottom: 16), child: _cardTitle('Exam Images', primary: true)),
      _grid([
        // `<input type="file" accept="image/*" class="border rounded-md p-2 w-full">`
        if (_imageUrl.text.isEmpty)
          _field('Upload Image', ExamFileInput(onPick: _onImageUpload, fileName: _pickedImageName)),
        if (_imagePreview.isEmpty)
          _field('Image URL', AppTextField(controller: _imageUrl, hint: 'https://example.com/image.jpg')),
      ], context.isSm ? 2 : 1),
      if (_imagePreview.isNotEmpty)
        // `mt-4`; `<Label class="mb-2 block">Preview</Label>`
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _field(
            'Preview',
            ExamImagePreview(
              onRemove: _removeImage,
              image: Image.network(
                _imagePreview,
                fit: BoxFit.contain,
                errorBuilder: (_, _, _) => const Icon(BootstrapIcons.image, size: 32, color: Tw.gray400),
              ),
            ),
          ),
        ),
      _field('Image Order', _numberField(_imageOrder, 'Image Order', white: true)),
      // Not bound on the web; the payload always sends `caption: ''`.
      _field('Caption', AppTextField(hint: 'Caption', fillColor: _bgWhite)),
    ]);
  }

  // ── Cancel / Create ──

  /// `flex gap-4 justify-end`. Cancel is `bg-gray-100 text-black`, which
  /// keeps the default variant's `hover:bg-primary/90`.
  Widget _buttons() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          AppButton(
            label: 'Cancel',
            backgroundColor: Tw.gray100,
            foregroundColor: Colors.black,
            onPressed: widget.onExamCreated,
          ),
          const SizedBox(width: 16),
          AppButton(
            label: 'Create',
            loadingLabel: 'Creating...',
            loading: _loading,
            onPressed: _saveExam,
          ),
        ],
      );
}
