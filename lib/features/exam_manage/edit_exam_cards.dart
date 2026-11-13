part of 'edit_exam_page.dart';

/// The cards of `EditExams.vue` (`<Card class="p-4 mb-4">`).
extension _EditExamCards on _EditExamPageState {
  static const _p4 = EdgeInsets.all(16);

  /// `<Label class="mb-2">` (+ the red `after:content-['*'] after:ml-1`)
  /// above [child]; [block] for `<Label class="block …">`.
  Widget _labeled(String label, Widget child, {bool required = false, double gap = 8, bool block = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [ExamFieldLabel(label, required: required, block: block), SizedBox(height: gap), child],
      );

  /// `bg-white` on a trigger / input (dark mode keeps the kit's
  /// `dark:bg-input/30`, which is more specific).
  Color? get _bgWhite => context.isDark ? null : Colors.white;

  Widget _numberInput(TextEditingController c, String hint, {bool white = false}) => AppTextField(
        controller: c,
        hint: hint,
        keyboardType: exmNumberKeyboard,
        inputFormatters: exmNumberFormatters,
        fillColor: white ? _bgWhite : null,
      );

  /// `<Textarea>`: `field-sizing-content min-h-16` (`rows` has no effect).
  Widget _textarea(TextEditingController c, String hint) => AppTextField(controller: c, hint: hint, maxLines: null);

  /// `grid gap-4 sm:grid-cols-2 lg:grid-cols-N`
  Widget _grid(List<Widget> cells, {int sm = 2, int? lg, double gap = 16}) {
    final columns = context.isLg && lg != null ? lg : (context.isSm ? sm : 1);
    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += columns) {
      final row = cells.sublist(i, i + columns > cells.length ? cells.length : i + columns);
      rows.add(columns == 1
          ? row.first
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var j = 0; j < columns; j++) ...[
                  if (j > 0) SizedBox(width: gap),
                  Expanded(child: j < row.length ? row[j] : const SizedBox.shrink()),
                ],
              ],
            ));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) SizedBox(height: gap),
          rows[i],
        ],
      ],
    );
  }

  // ── Basic Information ────────────────────────────────────────────────────

  Widget _basicInformationCard() {
    return ExmCard(
      padding: _p4,
      children: [
        const ExmCardTitle('Basic Information', primary: true),
        _labeled(
          'Language',
          AppSelect<String>(
            value: _locale,
            placeholder: 'Select Language',
            items: [for (final o in examLanguageOptions) AppSelectItem(o.value, o.key)],
            onChanged: (v) => _set(() => _locale = v ?? _locale),
          ),
        ),
        _labeled('Exam Name', AppTextField(controller: _name, hint: 'Exam Name'), required: true),
        _labeled('Exam Code', AppTextField(controller: _code, hint: 'Exam Code'), required: true),
        // A native `<label class="text-sm font-medium">` (no margin).
        PlainLabeled(label: 'Description', child: _textarea(_description, 'Enter Description text')),
        _labeled(
          'Select Exam Type',
          AppSelect<String>(
            value: _examType,
            placeholder: 'Select Exam Type',
            fillColor: _bgWhite,
            items: const [AppSelectItem('EXAM', 'Exam'), AppSelectItem('QUIZ', 'Quiz')],
            onChanged: (v) => _set(() => _examType = v ?? _examType),
          ),
          required: true,
        ),
        _labeled('Duration', _numberInput(_durationMinutes, 'Duration (minutes)'), required: true),
        _labeled('Max Attempts', AppTextField(controller: _maxAttempts, hint: 'Max Attempts')),
      ],
    );
  }

  // ── Settings ─────────────────────────────────────────────────────────────

  Widget _settingsCard() {
    Widget cell(Widget child) => Align(alignment: Alignment.centerLeft, child: child);
    return ExmCard(
      padding: _p4,
      children: [
        const ExmCardTitle('Settings', primary: true),
        // `flex items-center gap-3 mb-4` → a `<FormItem>` (`grid gap-2`) as wide
        // as its content: the toggle and, when on, `mt-4` + the marks input.
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: IntrinsicWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  cell(WebToggle(
                    checked: vueChecked(_enableNegativeMarking),
                    label: 'Enable Negative Marking',
                    onChanged: (v) => _set(() => _enableNegativeMarking = v),
                  )),
                  if (jsTruthy(_enableNegativeMarking)) ...[
                    const SizedBox(height: 24),
                    _labeled(
                      'Negative Marks Per Wrong Answer',
                      _numberInput(_negativeMarks, 'Enter negative marks', white: true),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        _grid(
          [
            cell(WebToggle(
              checked: vueChecked(_randomizeQuestionOrder),
              label: 'Randomize Question Order',
              onChanged: (v) => _set(() => _randomizeQuestionOrder = v),
            )),
            cell(WebToggle(
              checked: vueChecked(_randomizeOptionsOrder),
              label: 'Randomize Option Order (for MCQ) ',
              onChanged: (v) => _set(() => _randomizeOptionsOrder = v),
            )),
            cell(WebToggle(
              checked: _showImmediateFeedback,
              label: 'Show Immediate Feedback',
              onChanged: (v) => _set(() => _showImmediateFeedback = v),
            )),
          ],
          lg: 3,
        ),
      ],
    );
  }

  // ── Association ──────────────────────────────────────────────────────────

  Widget _associationCard(List<Json> courses, List<Json> courseSections) {
    return ExmCard(
      padding: _p4,
      children: [
        const ExmCardTitle('Association', primary: true),
        _labeled(
          'Course / Subject',
          AppSelect<String>(
            value: _selectedCourseId,
            placeholder: 'Select Course',
            fillColor: _bgWhite,
            items: [for (final c in courses) AppSelectItem(jsField(c, 'exam_course_id'), vueText(c['title']))],
            onChanged: _onCourseChanged,
          ),
        ),
        _labeled(
          'Chapter',
          AppSelect<String>(
            value: _selectedSubjectId,
            enabled: _selectedCourseId.isNotEmpty,
            placeholder: 'Select Chapter',
            fillColor: _bgWhite,
            items: [
              for (final ch in firstSectionChapters(courseSections))
                AppSelectItem(jsField(ch, 'exam_chapter_id'), vueText(ch['name'])),
            ],
            onChanged: _onSubjectChanged,
          ),
        ),
        // `h-px bg-border my-2`
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Container(height: 1, color: context.borderColor),
        ),
      ],
    );
  }

  // ── Schedule ─────────────────────────────────────────────────────────────

  /// `<Input type="time" class="w-full">`
  Widget _timeInput(String value, VoidCallback onTap) => AppTextField(
        key: ValueKey('time-$value'),
        initialValue: timeInputDisplay(value),
        hint: '--:-- --',
        readOnly: true,
        onTap: onTap,
        suffix: const Icon(BootstrapIcons.clock, size: 14),
      );

  Widget _scheduleCard() {
    return ExmCard(
      padding: _p4,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ExmCardTitle('Schedule', primary: true),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Align(
            alignment: Alignment.centerLeft,
            child: WebToggle(
              checked: vueChecked(_isOpenAnytime),
              gap: 12,
              label: 'Open Anytime (Students can take this exam anytime without time restrictions)',
              onChanged: (v) => _set(() => _isOpenAnytime = v),
            ),
          ),
        ),
        if (jsTruthy(_isOpenAnytime))
          const ExamInfoNote(
            'This exam will be available for students to take at any time. Perfect for practice tests and '
            'self-paced learning.',
          )
        else
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _scheduleGrid([
                _labeled(
                  'Start Date',
                  ExamDateButton(
                    text: _startDate == null ? 'Pick a start date' : jsLocaleDateString(_startDate!),
                    onPressed: () => _pickDate(true),
                  ),
                  required: true,
                ),
                _labeled('Start Time', _timeInput(_startAt, () => _pickTime(true)), gap: 0),
              ]),
              const SizedBox(height: 24),
              _scheduleGrid([
                _labeled(
                  'End Date',
                  ExamDateButton(
                    text: _endDate == null ? 'Pick an end date' : jsLocaleDateString(_endDate!),
                    onPressed: () => _pickDate(false),
                  ),
                  required: true,
                ),
                _labeled('End Time', _timeInput(_endAt, () => _pickTime(false)), gap: 0),
              ]),
            ],
          ),
      ],
    );
  }

  /// `grid grid-cols-1 lg:grid-cols-2 gap-4`
  Widget _scheduleGrid(List<Widget> cells) => _grid(cells, sm: 1, lg: 2);

  // ── Exam Sections ────────────────────────────────────────────────────────

  Widget _examSectionsCard(List<Json> courseSections) {
    final muted = mutedFg(context);
    return ExmCard(
      padding: _p4,
      children: [
        Row(
          children: [
            const Expanded(child: ExmCardTitle('Exam Sections', primary: true, required: true)),
            AppButton(label: 'Add Section', onPressed: _addSection),
          ],
        ),
        if (_sections.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Text(
              'No sections added. Add at least one section to generate questions for the exam.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, height: 20 / 14, color: muted),
            ),
          ),
        for (var i = 0; i < _sections.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: _sectionCard(i, topicsOfSubject(courseSections, _selectedSubjectId)),
          ),
      ],
    );
  }

  Widget _sectionCard(int sectionIndex, List<Json> topics) {
    final section = _sections[sectionIndex];
    final muted = mutedFg(context);
    return ExmCard(
      padding: _p4,
      children: [
        Row(
          children: [
            Expanded(child: ExmCardTitle('Section ${sectionIndex + 1}', required: true)),
            ExamTrashButton(onPressed: () => _removeSection(sectionIndex)),
          ],
        ),
        // `space-y-4`
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _labeled(
              'Section Name',
              AppTextField(controller: section.name, hint: 'Section Name'),
              required: true,
              block: true,
            ),
            const SizedBox(height: 16),
            _labeled('Description', _textarea(section.description, 'Description'), block: true),
            const SizedBox(height: 16),
            _grid([
              _labeled(
                'Number of Questions',
                AppTextField(controller: section.questionCount, hint: 'Number of Questions'),
                required: true,
                block: true,
              ),
              _labeled(
                'Marks Per Question',
                AppTextField(controller: section.marksPerQuestion, hint: 'Marks Per Question'),
                block: true,
              ),
            ]),
            const SizedBox(height: 16),
            // Rules header (`flex items-center justify-between pt-2`)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  const Expanded(child: ExamFieldLabel('Question Selection Rules')),
                  ExamAddRuleButton(onPressed: () => _addRule(section)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (section.rules.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < section.rules.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    _ruleCard(section, i, topics),
                  ],
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  'No rules found for this section.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, height: 20 / 14, color: muted),
                ),
              ),
          ],
        ),
      ],
    );
  }

  /// `<Card class="p-4 bg-gray-50">` (no dark variant on the web).
  Widget _ruleCard(_SectionForm section, int index, List<Json> topics) {
    final rule = section.rules[index];
    final topicId = rule.topicId;
    return ExmCard(
      padding: _p4,
      color: Tw.gray50,
      children: [
        Row(
          children: [
            Expanded(child: ExmCardTitle('Rule ${index + 1}')),
            ExamTrashButton(onPressed: () => _removeRule(section, index)),
          ],
        ),
        // The triggers' `h-10` loses to the kit's `data-[size=default]:h-9`.
        _grid(
          [
            _labeled(
              'Topic',
              AppSelect<String>(
                value: topicId is String ? topicId : null,
                placeholder: 'Select Topic',
                fillColor: _bgWhite,
                items: [
                  for (final t in topics) AppSelectItem(jsField(t, 'exam_content_id'), vueText(t['name'])),
                ],
                onChanged: (v) => _set(() => rule.topicId = v ?? ''),
              ),
            ),
            _labeled(
              'Difficulty',
              AppSelect<String>(
                value: rule.difficulty,
                placeholder: 'Difficulty',
                fillColor: _bgWhite,
                items: const [
                  AppSelectItem('EASY', 'Easy'),
                  AppSelectItem('MEDIUM', 'Medium'),
                  AppSelectItem('HARD', 'Hard'),
                ],
                onChanged: (v) => _set(() => rule.difficulty = v ?? ''),
              ),
            ),
            _labeled(
              'Question Type',
              AppSelect<String>(
                value: rule.questionType,
                placeholder: 'Question Type',
                fillColor: _bgWhite,
                items: const [
                  AppSelectItem('SAQ', 'SAQ'),
                  AppSelectItem('MCQ', 'MCQ'),
                  AppSelectItem('MEQ', 'MEQ'),
                  AppSelectItem('IMAGE_BASED', 'Image Based'),
                  AppSelectItem('OSCE_CHECKLIST', 'OSCE Checklist'),
                ],
                onChanged: (v) => _set(() => rule.questionType = v ?? ''),
              ),
            ),
            _labeled('Tags', AppTextField(controller: rule.tags, hint: 'Tags', fillColor: _bgWhite)),
            _labeled('Pick Count', _numberInput(rule.pickCount, 'Pick Count', white: true)),
          ],
          lg: 5,
        ),
      ],
    );
  }

  // ── Exam Images ──────────────────────────────────────────────────────────

  Widget _examImagesCard() {
    return ExmCard(
      padding: _p4,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: ExmCardTitle('Exam Images', primary: true),
        ),
        // Upload / URL inputs (only when NO image exists)
        if (_imagePreview.isEmpty)
          _grid([
            // The kit's `<Input type="file" accept="image/*">`.
            _labeled('Upload Image', ExamFileInput(onPick: _onImageUpload, shadcn: true)),
            _labeled(
              'Image URL',
              AppTextField(
                controller: _imageUrl,
                focusNode: _imageUrlFocus,
                hint: 'https://example.com/image.jpg',
                onChanged: _onImageUrlTyped,
              ),
            ),
          ])
        else
          // Preview Image (`mt-4 space-y-2`, `<Label class="block">`)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _labeled(
              'Preview',
              ExamImagePreview(
                onRemove: _removeImage,
                image: ExmImage(_imagePreview, key: ValueKey(_imagePreview)),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _labeled('Image Order', _numberInput(_imageOrder, 'Order (1, 2, 3...)', white: true)),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: _labeled('Caption', AppTextField(controller: _imageCaption, hint: 'Caption', fillColor: _bgWhite)),
        ),
      ],
    );
  }
}
