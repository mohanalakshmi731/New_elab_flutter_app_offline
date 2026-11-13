part of 'course_list_view.dart';

/// "Update Course" dialog (`isCourseUpdateOpen`) — all fields of the create
/// form. Lives outside the card on the web, so it opens from the grid too.
extension _CourseUpdateUi on _CourseListViewState {
  /// shadcn `<Label>Title <span class="text-red-500">*</span></Label>`
  Widget _shadLabel(String text, {bool star = false}) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(
        child: Text(text, style: const TextStyle(fontSize: 14, height: 1, fontWeight: FontWeight.w500)),
      ),
      if (star) ...[
        const SizedBox(width: 8),
        const Text(
          '*',
          style: TextStyle(fontSize: 14, height: 1, fontWeight: FontWeight.w500, color: Tw.red500),
        ),
      ],
    ],
  );

  /// `<div class="flex flex-col gap-1"><Label/>…</div>`
  Widget _shadField(String label, Widget child, {bool star = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      _shadLabel(label, star: star),
      const SizedBox(height: 4),
      child,
    ],
  );

  Widget _buildCourseUpdateDialog(BuildContext ctx) {
    final sm = context.isSm;
    final md = context.isMd;
    final dark = context.isDark;
    final cs = _cs;
    final form = _form;
    final cols = md ? 2 : 1;

    final published = [
      for (final c in cs.curriculums)
        if (c['status'] == 'published') c,
    ];

    final row1 = _Grid(
      columns: cols,
      children: [
        _shadField('Title', AppTextField(controller: form.title, hint: 'Enter Course Title'), star: true),
        _shadField('Course Short Name', AppTextField(controller: form.shortName, hint: 'Enter short name'), star: true),
      ],
    );

    final row2 = _Grid(
      columns: cols,
      children: [
        _shadField('Course Code', AppTextField(controller: form.courseCode, hint: 'Enter course code'), star: true),
        _shadField(
          'Status',
          AppSelect<String>(
            value: form.status.isEmpty ? null : form.status,
            placeholder: 'Select status',
            items: const [
              AppSelectItem('published', 'Published'),
              AppSelectItem('draft', 'UnPublished'),
              AppSelectItem('archived', 'Archived'),
            ],
            onChanged: (v) => _set(() => form.status = v ?? ''),
          ),
        ),
      ],
    );

    final row3 = _Grid(
      columns: cols,
      children: [
        _shadField(
          'Curriculum',
          AppSelect<String>(
            value: form.curriculumId.isEmpty ? null : form.curriculumId,
            placeholder: 'Select Curriculum',
            items: [for (final c in published) AppSelectItem('${c['id']}', vText(c['name']))],
            onChanged: (v) => _set(() => form.curriculumId = v ?? ''),
          ),
        ),
        _shadField(
          'Instructor',
          AppSelect<String>(
            value: form.instructorId.isEmpty ? null : form.instructorId,
            placeholder: 'Select Instructor',
            items: [for (final inst in cs.instructors) AppSelectItem('${inst['id']}', instructorOptionLabel(inst))],
            onChanged: (v) => _set(() => form.instructorId = v ?? ''),
          ),
        ),
      ],
    );

    final row4 = _Grid(
      columns: cols,
      children: [
        _shadField(
          'All Class',
          AppSelect<Object>(
            value: form.classId,
            placeholder: 'Select Class',
            items: [
              for (final c in _editAllClassesData)
                if (c['id'] != null) AppSelectItem<Object>(c['id'] as Object, vText(c['name'])),
            ],
            onChanged: (v) => _fire(() => _onEditClassChange(v)),
          ),
        ),
        _shadField(
          'Subject',
          AppSelect<String>(
            value: form.subjectId.isEmpty ? null : form.subjectId,
            placeholder: 'Select Subject',
            items: [for (final s in _editSubjectsList) AppSelectItem('${s['id']}', vText(s['name']))],
            onChanged: (v) => _set(() => form.subjectId = v ?? ''),
          ),
        ),
        _shadField(
          'Course Zone',
          AppSelect<String>(
            value: form.zone.isEmpty ? null : form.zone,
            placeholder: 'Select Course Zone',
            items: const [
              AppSelectItem('mathzone', 'Math Zone'),
              AppSelectItem('mathplay', 'Math Play'),
              AppSelectItem('sciencezone', 'Science Zone'),
              AppSelectItem('scienceplay', 'Science Play'),
            ],
            onChanged: (v) => _set(() => form.zone = v ?? ''),
          ),
        ),
      ],
    );

    final row5 = _Grid(
      columns: cols,
      children: [
        _shadField('Image', FileInputField(fileName: form.attach?.name, onTap: () => _fire(_handleImageChange))),
      ],
    );

    // `:src="imagePreview || selectedCourseDetails?.image || ''"`
    final networkSrc = _imagePreview.isNotEmpty && _imagePreviewFile == null
        ? _imagePreview
        : orBlank(_selectedCourseDetails?['image']);
    const altText = Text('Preview', style: TextStyle(fontSize: 12, color: Tw.gray500));
    final Widget previewImage = _imagePreviewFile != null
        ? UploadPreview(file: _imagePreviewFile!, fit: BoxFit.contain)
        : networkSrc.isNotEmpty
        ? Image.network(networkSrc, fit: BoxFit.contain, errorBuilder: (_, _, _) => altText)
        : altText;

    final preview = Padding(
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
              border: Border.all(color: dark ? AppColors.darkBorder : AppColors.border),
              boxShadow: _CC.shadowSm,
            ),
            child: Container(
              height: 160,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Tw.gray50, borderRadius: BorderRadius.circular(14)),
              child: previewImage,
            ),
          ),
        ),
      ),
    );

    final rows = <Widget>[
      row1,
      row2,
      row3,
      row4,
      row5,
      preview,
      _shadField(
        'Description',
        AppTextField(controller: form.description, hint: 'Type your description here', maxLines: null, minLines: 3),
      ),
      Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Align(
          alignment: Alignment.centerLeft,
          child: LabeledCheckbox(
            value: form.isMathPlay,
            label: 'Math Play Course',
            onChanged: (v) => _set(() => form.isMathPlay = v),
          ),
        ),
      ),
    ];

    // `<div class="flex flex-col-reverse sm:flex-row justify-end gap-2 mt-4
    // px-2 sm:px-4 pb-4">` (default `rounded-md` buttons).
    final cancel = _cancelButton(_closer(ctx), radius: 14);
    final submit = _SubmitButton(
      loading: _isCreateBtnLoading,
      label: 'Update',
      radius: 14,
      onPressed: () => _fire(() => _courseUpdate(_closer(ctx))),
    );
    final footer = Padding(
      padding: EdgeInsets.fromLTRB(sm ? 16 : 8, 32, sm ? 16 : 8, 16),
      child: sm
          ? Row(mainAxisAlignment: MainAxisAlignment.end, children: [cancel, const SizedBox(width: 8), submit])
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [submit, const SizedBox(height: 8), cancel],
            ),
    );

    return AppDialogFrame(
      maxWidth: 768,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 28),
            // `<DialogDescription class="text-lg">` (`text-muted-foreground`)
            child: Text(
              'Update Course',
              textAlign: sm ? TextAlign.left : TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                height: 28 / 18,
                color: dark ? AppColors.darkMutedForeground : AppColors.mutedForeground,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.all(sm ? 16 : 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var i = 0; i < rows.length; i++) ...[if (i > 0) const SizedBox(height: 16), rows[i]],
              ],
            ),
          ),
          footer,
        ],
      ),
    );
  }
}
