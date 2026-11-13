part of 'schedules_page.dart';

/// The "Create Schedule" drawer (page 1: class, batches, days, slots, dates;
/// page 2: slot cards; page 3: generated preview) and its slot dialogs.
extension _CreateUi on _SchedulesPageState {
  // ── methods ──────────────────────────────────────────────────────────────

  /// `openCreateDrawer()` — the drawer keeps its last page (`drawerPage` is
  /// only reset after a submit, as on the web).
  void _openCreateDrawer() {
    _set(() {
      _selectedYear = '';
      _slotDetails = [];
    });
    _resetFilter();
    _form.reset();
    _set(() {});
    _touchFormBatch();
    _openDialog(_Dlg.drawer, _buildDrawer);
  }

  /// `resetForm()`
  void _resetForm() {
    _form.reset();
    _set(() {});
    _touchFormBatch();
  }

  /// `goToPage2()`
  void _goToPage2() {
    final error = validatePage1(
      classType: _form.classType,
      selectedYear: _selectedYear,
      batch: _form.batchList,
      days: _form.days,
      slots: _form.slots.text,
      minutesPerDay: _form.minutesPerDay.text,
      startDate: _form.startDate,
      endDate: _form.endDate,
    );
    if (error == null) {
      _set(() => _drawerPage = 2);
    } else {
      AppToast.info(error);
    }
  }

  /// `openSlotDialog(index)`
  void _openSlotDialog(int index) {
    _set(() {
      while (_slotDetails.length <= index) {
        _slotDetails.add(SlotDetail());
      }
      _editingSlot = _slotDetails[index].copy();
      _slotTitle.text = _editingSlot!.title;
      _selectedSlotIndex = index;
    });
    _openDialog(_Dlg.slot, _buildSlotDialog);
  }

  /// `closeSlotDialog()`
  void _closeSlotDialog() {
    _closeDialog(_Dlg.slot);
    _set(() {
      _selectedSlotIndex = null;
      _editingSlot = null;
    });
  }

  String _courseTitleById(String id) {
    for (final c in _courses) {
      if (schString(c['id']) == id) return vText(c['title']);
    }
    return '';
  }

  String _instructorEmailById(String id) {
    for (final i in _store.instructors) {
      if (schString(i['id']) == id) return vText(dig(i, ['user', 'email']));
    }
    return '';
  }

  /// `saveSlotDialog()` — also mirrors the slot into `previewSlots[index]`.
  void _saveSlotDialog() {
    final index = _selectedSlotIndex;
    final editing = _editingSlot;
    if (index == null || editing == null) return;
    editing.title = _slotTitle.text;
    _set(() {
      while (_slotDetails.length <= index) {
        _slotDetails.add(SlotDetail());
      }
      _slotDetails[index] = editing.copy();
      final slot = _slotDetails[index];
      while (_previewSlots.length <= index) {
        _previewSlots.add(PreviewSlot());
      }
      final prev = _previewSlots[index];
      _previewSlots[index] = PreviewSlot(
        startAt: slot.startAt,
        subject: _courseTitleById(slot.subject),
        instructor: _instructorEmailById(slot.instructor),
        classType: slot.classType,
        title: slot.title,
        date: prev.date.isNotEmpty ? prev.date : _form.startDate,
      );
    });
    _closeDialog(_Dlg.slot);
    _set(() {
      _selectedSlotIndex = null;
      _editingSlot = null;
    });
    AppToast.success('Slot updated successfully!');
  }

  /// `openPreviewSlotDialog(index)`
  void _openPreviewSlotDialog(int index) {
    _set(() {
      _selectedPreviewIndex = index;
      _previewTitle.text = _previewSlots[index].title;
    });
    _openDialog(_Dlg.preview, _buildPreviewDialog);
  }

  /// `closePreviewDialog()` — the fields were already edited in place.
  void _closePreviewDialog() {
    _closeDialog(_Dlg.preview);
    _set(() => _selectedPreviewIndex = null);
  }

  /// `savePreviewDialog()` — copies the edited preview back into its slot.
  void _savePreviewDialog() {
    final index = _selectedPreviewIndex;
    if (index == null) return;
    final edited = _previewSlots[index];
    _set(() {
      if (index < _slotDetails.length) {
        final detail = _slotDetails[index];
        detail.startAt = edited.startAt;
        detail.subject = () {
          for (final c in _courses) {
            if (c['title'] == edited.subject) return c['id']?.toString() ?? '';
          }
          return '';
        }();
        detail.instructor = () {
          for (final i in _store.instructors) {
            if (dig(i, ['user', 'email']) == edited.instructor) return i['id']?.toString() ?? '';
          }
          return '';
        }();
        detail.classType = edited.classType;
        detail.title = edited.title;
      }
    });
    _closeDialog(_Dlg.preview);
    AppToast.success('Slot ${index + 1} updated!');
    _set(() => _selectedPreviewIndex = null);
  }

  /// `generatePreviewSlots()`
  void _generatePreviewSlots() {
    final r = buildPreviewSlots(
      startDate: _form.startDate,
      endDate: _form.endDate,
      days: _form.days,
      slotDetails: _slotDetails,
      instructors: _store.instructors,
      courses: _courses,
      classType: _form.classType,
      classType2: _form.classType2,
    );
    if (r.error != null) {
      AppToast.error(r.error!);
      return;
    }
    _set(() {
      _previewSlots = r.slots;
      _drawerPage = 3;
    });
  }

  /// `submitForm()`
  Future<void> _submitForm() async {
    if (_previewSlots.isEmpty) {
      AppToast.error('No slots generated. Please select valid days and slots.');
      return;
    }
    if (_previewSlots.any((s) => s.instructor.isEmpty)) {
      AppToast.error('Some slots do not have an instructor assigned. Please select an instructor.');
      return;
    }
    final slotsPayload = buildSlotsPayload(
      previewSlots: _previewSlots,
      instructors: _store.instructors,
      courses: _courses,
      minutesPerDay: _form.minutesPerDay.text,
      classType: _form.classType,
      classType2: _form.classType2,
    );
    if (slotsPayload.isEmpty) {
      AppToast.error('No valid slots to create.');
      return;
    }
    try {
      await _ctrl.createSchedule({'institute_id': '', 'batches': _form.batch, 'slots': slotsPayload});
      await _reloadSchedules();
    } catch (_) {
      return; // unhandled on the web: the drawer stays open
    }
    _closeDialog(_Dlg.drawer);
    _set(() => _drawerPage = 1);
    _resetForm();
    _set(() => _slotsArray = []);
  }

  // ── drawer ───────────────────────────────────────────────────────────────

  /// `<DrawerContent class="p-5 max-h-[80vh]">` — `bg-background`, which
  /// `.dark` never redefines, so the drawer stays white in dark mode too.
  Widget _buildDrawer(BuildContext context) {
    final dark = context.isDark;
    // `<DrawerHeader class="mb-6">` (`flex flex-col gap-1.5 p-4`, left-aligned).
    final header = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Create Schedule',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: context.colors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            'Fill in the details to create a new schedule.',
            style: TextStyle(fontSize: 14, color: _mutedFg(context)),
          ),
        ],
      ),
    );
    final Widget body = switch (_drawerPage) {
      1 => _drawerPage1(context),
      2 => _drawerPage2(context),
      3 => _drawerPage3(context),
      _ => const SizedBox.shrink(),
    };
    final List<Widget> actions = switch (_drawerPage) {
      1 => [
          AppButton(label: 'Reset', variant: AppButtonVariant.outline, onPressed: _resetForm),
          AppButton(label: 'Next', onPressed: _goToPage2),
        ],
      2 => [
          AppButton(label: 'Back', variant: AppButtonVariant.outline, onPressed: () => _set(() => _drawerPage = 1)),
          AppButton(label: 'Preview', onPressed: _generatePreviewSlots),
        ],
      3 => [
          AppButton(label: 'Back', variant: AppButtonVariant.outline, onPressed: () => _set(() => _drawerPage = 2)),
          AppButton(label: 'Submit', onPressed: _submitForm),
        ],
      _ => const [],
    };
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 16),
              width: 100,
              height: 8,
              decoration: BoxDecoration(
                color: dark ? AppColors.darkMuted : AppColors.muted,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(padding: const EdgeInsets.only(bottom: 24), child: header),
          Flexible(child: SingleChildScrollView(child: body)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  actions[i],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerPage1(BuildContext context) {
    final s = _store;
    final published = [
      for (final b in s.batches)
        if (b['status'] == 'published') (schString(b['id']), vText(b['name'])),
    ];
    final selectedYear = _selectedYear is String ? _selectedYear as String : null;
    final numberFormatter = FilteringTextInputFormatter.allow(RegExp(r'[0-9.\-]'));
    final columns = context.isLg
        ? 3
        : context.isSm
            ? 2
            : 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormGrid(
          columns: columns,
          gap: 24,
          children: [
            _labeled(
              'Class Type',
              required: true,
              AppSelect<String>(
                value: _form.classType.isEmpty ? null : _form.classType,
                placeholder: 'Select Type',
                items: const [AppSelectItem('eClass', 'eClass')],
                onChanged: (v) => _set(() => _form.classType = v ?? ''),
              ),
            ),
            _labeled(
              'Select Class',
              required: true,
              AppSelect<String>(
                value: selectedYear,
                placeholder: 'Select a Class',
                items: [for (final i in s.institutes) AppSelectItem(schString(i['id']), vText(i['year']))],
                onChanged: (v) {
                  _set(() => _selectedYear = v);
                  _onYearChange(v);
                },
              ),
            ),
            _labeled(
              'Batch',
              required: true,
              _MultiSelect(
                values: _form.batchList,
                items: published,
                placeholder: 'Select Batches',
                emptyText: 'No batches available',
                onChanged: (v) {
                  _set(() => _form.batch = v);
                  _touchFormBatch();
                },
              ),
            ),
            _labeled(
              'Days',
              required: true,
              _MultiSelect(
                values: _form.days,
                placeholder: 'Select Days',
                groupLabel: 'Days',
                items: const [
                  ('monday', 'Monday'),
                  ('tuesday', 'Tuesday'),
                  ('wednesday', 'Wednesday'),
                  ('thursday', 'Thursday'),
                  ('friday', 'Friday'),
                  ('saturday', 'Saturday'),
                  ('sunday', 'sunday'),
                ],
                onChanged: (v) => _set(() => _form.days = v),
              ),
            ),
            _labeled(
              'Slots',
              required: true,
              AppTextField(
                controller: _form.slots,
                hint: 'Slots',
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                inputFormatters: [numberFormatter],
              ),
            ),
            _labeled(
              'Minutes Per Slot',
              required: true,
              AppTextField(
                controller: _form.minutesPerDay,
                hint: 'Minutes',
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                inputFormatters: [numberFormatter],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FormGrid(
          columns: context.isSm ? 2 : 1,
          gap: 24,
          children: [
            _labeled(
              'Start Date',
              required: true,
              _DateButton(
                value: _form.startDate,
                placeholder: 'Pick a start date',
                onChanged: (v) => _set(() => _form.startDate = v),
              ),
            ),
            _labeled(
              'End Date',
              required: true,
              _DateButton(
                value: _form.endDate,
                placeholder: 'Pick an end date',
                onChanged: (v) => _set(() => _form.endDate = v),
              ),
            ),
          ],
        ),
      ],
    );
  }

  int _cardColumns(BuildContext context) => context.isLg
      ? 4
      : context.isSm
          ? 2
          : 1;

  /// Page 2 — one card per slot (click to edit).
  Widget _drawerPage2(BuildContext context) {
    final activeInstructors = [for (final i in _store.instructors) if (i['status'] == true) i];
    return FormGrid(
      columns: _cardColumns(context),
      gap: 16,
      children: [
        for (final index in _slotsArray)
          () {
            final d = index < _slotDetails.length ? _slotDetails[index] : null;
            final subject = d == null ? '' : _courseTitleById(d.subject);
            String instructor = '—';
            for (final i in activeInstructors) {
              if (schString(i['id']) == d?.instructor) {
                final u = asMap(i['user']);
                instructor = '${u?['first_name'] ?? ''} ${u?['last_name'] ?? ''}'.trim();
                break;
              }
            }
            // `<Card class="cursor-pointer border-gray-200 bg-white">` (keeps the
            // card's `py-6 rounded-xl shadow-sm`) + `<CardContent class="p-5">`.
            return _HoverBorderCard(
              radius: 20,
              hoverBorder: false,
              onTap: () => _openSlotDialog(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 44),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Tw.gray200),
                  boxShadow: AppShadows.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text('Slot ${index + 1}',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600, color: context.colors.primary)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: context.colors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            d != null && d.classType.isNotEmpty ? d.classType : 'N/A',
                            style: TextStyle(fontSize: 12, color: context.colors.primary),
                          ),
                        ),
                      ],
                    ),
                    // The header's `mb-2` beats the zero-specificity `space-y-4`.
                    const SizedBox(height: 8),
                    _KeyValueRow('Title', d != null && d.title.isNotEmpty ? d.title : '—'),
                    const SizedBox(height: 8),
                    _KeyValueRow('Start Time', d != null && d.startAt.isNotEmpty ? d.startAt : '—'),
                    const SizedBox(height: 8),
                    _KeyValueRow('Subject', subject.isNotEmpty ? subject : '—'),
                    const SizedBox(height: 8),
                    _KeyValueRow('Instructor', instructor.isEmpty ? '—' : instructor),
                  ],
                ),
              ),
            );
          }(),
      ],
    );
  }

  /// Page 3 — the generated slots (click to edit one).
  Widget _drawerPage3(BuildContext context) => FormGrid(
        columns: _cardColumns(context),
        gap: 16,
        children: [
          for (var index = 0; index < _previewSlots.length; index++)
            () {
              final slot = _previewSlots[index];
              String or(String v) => v.isEmpty ? '-' : v;
              return _HoverBorderCard(
                radius: 16,
                onTap: () => _openPreviewSlotDialog(index),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Tw.gray200),
                    boxShadow: AppShadows.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text('Slot ${index + 1}',
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600, color: context.colors.primary)),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration:
                                BoxDecoration(color: Tw.blue100, borderRadius: BorderRadius.circular(999)),
                            child: Text(
                              slot.classType.isEmpty ? 'N/A' : slot.classType,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Tw.blue700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      for (final (i, (label, value)) in [
                        ('Title', or(slot.title)),
                        ('Date', or(slot.date)),
                        ('Start At', or(slot.startAt)),
                        ('Subject', or(slot.subject)),
                        ('Instructor', or(slot.instructor)),
                      ].indexed) ...[
                        if (i > 0) const SizedBox(height: 8),
                        _KeyValueRow(label, value, valueColor: Tw.gray800, bold: false, center: true),
                      ],
                    ],
                  ),
                ),
              );
            }(),
        ],
      );

  // ── slot dialogs ─────────────────────────────────────────────────────────

  List<AppSelectItem<String>> get _subjectItems =>
      [for (final c in _courses) AppSelectItem(schString(c['id']), vText(c['title']))];

  /// "Edit Slot N" (`editingSlot`).
  Widget _buildSlotDialog(BuildContext context) {
    final index = _selectedSlotIndex;
    final slot = _editingSlot;
    if (index == null) return const SizedBox.shrink();
    final columns = context.isLg ? 2 : 1;
    Widget? fields;
    if (slot != null) {
      final search = _search.text.toLowerCase();
      final filtered = [
        for (final i in _store.instructors)
          if (search.isEmpty || vText(dig(i, ['user', 'email'])).toLowerCase().contains(search)) i,
      ].take(5);
      String fullName(SJson i) =>
          '${dig(i, ['user', 'first_name']) ?? ''} ${dig(i, ['user', 'last_name']) ?? ''}'.trim();
      String? selectedLabel;
      for (final i in _store.instructors) {
        if (schString(i['id']) == slot.instructor) selectedLabel = fullName(i);
      }
      fields = FormGrid(
        columns: columns,
        gap: 16,
        children: [
          _labeled(
            'Title',
            gap: 0,
            AppTextField(
              controller: _slotTitle,
              hint: 'Enter Slot Title',
              onChanged: (v) => slot.title = v,
            ),
          ),
          _labeled(
            'Time',
            gap: 0,
            _TimeInput(value: slot.startAt, onChanged: (v) => _set(() => slot.startAt = v)),
          ),
          _labeled(
            'Subject',
            gap: 0,
            AppSelect<String>(
              value: slot.subject.isEmpty ? null : slot.subject,
              placeholder: 'Select a Subject',
              items: _subjectItems,
              onChanged: (v) => _set(() => slot.subject = v ?? ''),
            ),
          ),
          _labeled(
            'Instructor',
            gap: 0,
            _InstructorSelect(
              value: slot.instructor.isEmpty ? null : slot.instructor,
              selectedLabel: slot.instructor.isEmpty ? null : selectedLabel,
              options: [for (final i in filtered) (schString(i['id']), fullName(i))],
              search: _search,
              onChanged: (v) => _set(() => slot.instructor = v),
            ),
          ),
          GridSpan(
            child: _labeled(
              'Class Type',
              gap: 0,
              AppSelect<String>(
                value: slot.classType.isEmpty ? null : slot.classType,
                placeholder: 'Select Class Type',
                items: const [AppSelectItem('eClass', 'eClass')],
                onChanged: (v) => _set(() => slot.classType = v ?? ''),
              ),
            ),
          ),
        ],
      );
    }
    return _slotDialogFrame(
      context,
      'Edit Slot ${index + 1}',
      fields,
      onCancel: _closeSlotDialog,
      onSave: _saveSlotDialog,
    );
  }

  /// "Edit Preview Slot N" — edits `previewSlots[index]` in place.
  Widget _buildPreviewDialog(BuildContext context) {
    final index = _selectedPreviewIndex;
    if (index == null) return const SizedBox.shrink();
    final slot = index < _previewSlots.length ? _previewSlots[index] : null;
    Widget? fields;
    if (slot != null) {
      final emails = <String>[];
      for (final i in _store.instructors) {
        final e = vText(dig(i, ['user', 'email']));
        if (!emails.contains(e)) emails.add(e);
      }
      fields = FormGrid(
        columns: context.isLg ? 2 : 1,
        gap: 16,
        children: [
          _labeled(
            'Date',
            gap: 0,
            AppDateField(value: slot.date, onChanged: (v) => _set(() => slot.date = v)),
          ),
          GridSpan(
            child: _labeled(
              'Title',
              gap: 0,
              AppTextField(controller: _previewTitle, hint: 'Enter Slot Title', onChanged: (v) => slot.title = v),
            ),
          ),
          _labeled('Start At', gap: 0, _TimeInput(value: slot.startAt, onChanged: (v) => _set(() => slot.startAt = v))),
          _labeled(
            'Subject',
            gap: 0,
            AppSelect<String>(
              value: slot.subject.isEmpty ? null : slot.subject,
              placeholder: 'Select a Subject',
              items: [for (final c in _courses) AppSelectItem(vText(c['title']), vText(c['title']))],
              onChanged: (v) => _set(() => slot.subject = v ?? ''),
            ),
          ),
          _labeled(
            'Instructor',
            gap: 0,
            AppSelect<String>(
              value: slot.instructor.isEmpty ? null : slot.instructor,
              placeholder: 'Select Instructor',
              items: [for (final e in emails) AppSelectItem(e, e)],
              onChanged: (v) => _set(() => slot.instructor = v ?? ''),
            ),
          ),
          GridSpan(
            child: _labeled(
              'Class Type',
              gap: 0,
              AppSelect<String>(
                value: slot.classType.isEmpty ? null : slot.classType,
                placeholder: 'Select Type',
                items: const [AppSelectItem('eClass', 'eClass')],
                onChanged: (v) => _set(() => slot.classType = v ?? ''),
              ),
            ),
          ),
        ],
      );
    }
    return _slotDialogFrame(
      context,
      'Edit Preview Slot ${index + 1}',
      fields,
      onCancel: _closePreviewDialog,
      onSave: _savePreviewDialog,
    );
  }

  /// `<DialogContent class="p-6 max-w-md">` of the slot dialogs: the header,
  /// the fields and a plain `mt-4 flex justify-end gap-2` button row (a row
  /// on phones too; 16 + the grid's `gap-4` above it).
  Widget _slotDialogFrame(
    BuildContext context,
    String title,
    Widget? fields, {
    required VoidCallback onCancel,
    required VoidCallback onSave,
  }) =>
      AppDialogFrame(
        maxWidth: context.isSm ? 512 : 448,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dialogHeader(context, title),
            const SizedBox(height: 16),
            if (fields != null) ...[fields, const SizedBox(height: 16)],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AppButton(label: 'Cancel', variant: AppButtonVariant.outline, onPressed: onCancel),
                const SizedBox(width: 8),
                AppButton(label: 'Save', onPressed: onSave),
              ],
            ),
          ],
        ),
      );
}
