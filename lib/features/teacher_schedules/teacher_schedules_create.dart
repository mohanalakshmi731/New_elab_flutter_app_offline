part of 'teacher_schedules_page.dart';

/// The "Create Schedule" drawer (3 steps), its slot / preview dialogs and
/// the "Edit Schedule" dialog.
extension _CreateView on _TeacherSchedulesPageState {
  // ── actions ──────────────────────────────────────────────────────────────

  /// `watch: 'form.slots'`
  void _setFormSlots(String value) {
    if (value == _lastSlots) return;
    _lastSlots = value;
    final r = applySlotsCount(value, _slotDetails);
    _set(() {
      _slotsArray = r.slotsArray;
      _slotDetails = r.slotDetails;
    });
  }

  /// The `form = { … }` reset (`openCreateDrawer` / `resetForm`).
  void _clearForm() {
    _set(() {
      _formClassType = '';
      _formBatch = [];
      _formDays = [];
      _formStartDate = null;
      _formEndDate = null;
    });
    _formMinutes.text = '';
    _formSlots.text = '';
    _setFormSlots('');
  }

  /// `openCreateDrawer()` — `drawerPage` is kept, like the web.
  void _openCreateDrawer() {
    _set(() => _slotDetails = []);
    _clearForm();
    _openDialog('drawer', _buildDrawer, sheet: true, onClosed: () {
      // `watch: openDrawer(false)`
      _set(() => _selectedYear = '');
      _resetFilter();
    });
  }

  /// `resetForm()`
  void _resetForm() => _clearForm();

  /// `goToPage2()`
  void _goToPage2() {
    final v = validatePage1(
      classType: _formClassType,
      selectedYear: _selectedYear,
      batch: _formBatch,
      days: _formDays,
      slots: _formSlots.text,
      minutesPerDay: _formMinutes.text,
      startDate: _formStartDate,
      endDate: _formEndDate,
    );
    if (v == null) {
      _set(() => _drawerPage = 2);
    } else {
      AppToast.error(v);
    }
  }

  /// `openSlotDialog(index)`
  void _openSlotDialog(int index) {
    _set(() {
      while (_slotDetails.length <= index) {
        _slotDetails.add(emptySlotDetail());
      }
      _editingSlot = {..._slotDetails[index]};
      _selectedSlotIndex = index;
    });
    _slotTitle.text = '${_editingSlot!['title'] ?? ''}';
    _openDialog('slot', _buildSlotDialog);
  }

  /// `closeSlotDialog()`
  void _closeSlotDialog() {
    _set(() => _selectedSlotIndex = null);
    _closeDialog('slot');
    _set(() => _editingSlot = null);
  }

  /// `saveSlotDialog()`
  void _saveSlotDialog() {
    final index = _selectedSlotIndex;
    final editing = _editingSlot;
    if (index == null || editing == null) return;
    _set(() => _slotDetails[index] = {...editing});
    _closeDialog('slot');
    _set(() {
      _selectedSlotIndex = null;
      _editingSlot = null;
    });
    AppToast.success('Slot updated!');
  }

  /// `openPreviewSlotDialog(index)`
  void _openPreviewSlotDialog(int index) {
    _set(() => _selectedPreviewIndex = index);
    _previewTitle.text = '${_previewSlots[index]['title'] ?? ''}';
    _openDialog('preview', _buildPreviewDialog);
  }

  /// `closePreviewDialog()` — edits were applied live (v-model), like the web.
  void _closePreviewDialog() {
    _set(() => _selectedPreviewIndex = null);
    _closeDialog('preview');
  }

  /// `savePreviewDialog()`
  void _savePreviewDialog() {
    _closeDialog('preview');
    _set(() => _selectedPreviewIndex = null);
    AppToast.success('Slot updated!');
  }

  /// `generatePreviewSlots()`
  void _generatePreviewSlots() {
    final r = generatePreviewSlots(
      startDate: _formStartDate,
      endDate: _formEndDate,
      days: _formDays,
      slotDetails: _slotDetails,
      instructors: _store.instructors,
      courses: _courses,
      formClassType: _formClassType,
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
      AppToast.error('No slots generated.');
      return;
    }
    if (_previewSlots.any((s) => !jsTruthy(s['instructor']))) {
      AppToast.error('Some slots do not have an instructor.');
      return;
    }
    _set(() => _isSubmitting = true);
    try {
      final slotsPayload = buildSlotsPayload(
        previewSlots: _previewSlots,
        instructors: _store.instructors,
        courses: _courses,
        minutesPerDay: _formMinutes.text,
        formClassType: _formClassType,
      );
      await _ctrl.createSchedule(batches: _formBatch, slots: slotsPayload);
      await _reloadSchedules();
      _closeDialog('drawer');
      _set(() {
        _drawerPage = 1;
        _slotsArray = [];
      });
      _resetForm();
      AppToast.success('Schedules created successfully!');
    } catch (_) {
      AppToast.error('Failed to create schedules.');
    } finally {
      _set(() => _isSubmitting = false);
    }
  }

  /// `onEditSchedule(scheduleId)`
  Future<void> _onEditSchedule(Object? scheduleId) async {
    try {
      _set(() => _isLoading = true);
      final schedule = asMap(await _ctrl.getScheduleById(jsString(scheduleId))) ?? const <String, dynamic>{};
      final classId = dig(schedule, ['batch', 'classes', 'id']);
      if (jsTruthy(classId)) {
        await _ctrl.getBatches(asInt(classId));
        await _ctrl.getInstructorsdropdown(asInt(classId));
        await _ctrl.fetchschedulesClassDetails(classId as Object);
      }
      _set(() {
        _editId = schedule['id'];
        _editStartDate = vueText(schedule['start_date']);
        _editStartTime = vueText(schedule['start_time']);
        _editClassType = vueText(schedule['type']);
        _editInstructorId = vueText(schedule['instructor_id']);
        _editSubjectId = vueText(schedule['course_id']);
      });
      _editDuration.text = vueText(schedule['duration'] ?? 0);
      _editTitle.text = vueText(schedule['title']);
      _openDialog('edit', _buildEditDialog);
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  /// `submitEditForm()` — the date and subject are not sent (web behaviour).
  Future<void> _submitEditForm() async {
    if (!jsTruthy(_editId)) {
      AppToast.error('Schedule ID is missing!');
      return;
    }
    try {
      _set(() => _isLoading = true);
      final t = _editStartTime;
      await _ctrl.updateSchedule(jsString(_editId), {
        'start_time': t.isNotEmpty ? t.substring(0, t.length < 5 ? t.length : 5) : '00:00',
        'duration': looseToNumber(_editDuration.text),
        'instructor_id': _editInstructorId.isEmpty ? null : _editInstructorId,
        'type': _editClassType,
        'title': _editTitle.text,
      });
      await _reloadSchedules();
      _closeDialog('edit');
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  // ── shared bits ──────────────────────────────────────────────────────────

  List<(String, String)> get _classTypeItems => const [('eClass', 'eClass')];

  List<(String, String)> get _subjectItems => [
        for (final c in _courses)
          if (asMap(c) != null) (jsString(asMap(c)!['id']), vueText(asMap(c)!['title'])),
      ];

  /// Edit Schedule `w-[calc(100vw-2rem)] max-w-2xl`: shadcn's `sm:max-w-lg`
  /// still applies from 640 px.
  double get _editDialogWidth => context.isSm ? 512 : 672;

  /// Slot dialogs `max-w-md`, likewise `sm:max-w-lg` from 640 px.
  double get _slotDialogWidth => context.isSm ? 512 : 448;

  Widget _drawerSection(String title, Widget grid) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [TsCaption(title, bold: true), const SizedBox(height: 12), grid],
      );

  int get _cols3 => context.isLg ? 3 : (context.isSm ? 2 : 1);

  Widget _numberField(TextEditingController controller, String hint, {ValueChanged<String>? onChanged}) => AppTextField(
        controller: controller,
        hint: hint,
        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.eE+\-]'))],
        onChanged: onChanged,
      );

  // ── drawer ───────────────────────────────────────────────────────────────

  Widget _buildDrawer(BuildContext ctx) {
    final dark = context.isDark;
    final border = dark ? Tw.slate700 : Tw.slate200;
    final stepName = _drawerPage == 1 ? 'Basic Setup' : (_drawerPage == 2 ? 'Configure Slots' : 'Review & Submit');
    return Container(
      margin: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900 : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)), // rounded-t-lg
        border: Border(top: BorderSide(color: border)),
      ),
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
          Container(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 16,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(mainAxisSize: MainAxisSize.min, children: [
                      const TsIconTile(icon: BootstrapIcons.calendar_plus),
                      const SizedBox(width: 12),
                      Text('Create Schedule',
                          style: TextStyle(
                              fontSize: 24, fontWeight: FontWeight.w700, color: dark ? Colors.white : Tw.slate900)),
                    ]),
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 52),
                      child: Text.rich(
                        TextSpan(children: [
                          TextSpan(text: 'Step $_drawerPage of 3 — '),
                          TextSpan(
                            text: stepName,
                            style: TextStyle(fontWeight: FontWeight.w600, color: dark ? Tw.slate300 : Tw.slate700),
                          ),
                        ]),
                        style: TextStyle(fontSize: 16, color: dark ? Tw.slate400 : Tw.slate500),
                      ),
                    ),
                  ],
                ),
                Row(mainAxisSize: MainAxisSize.min, children: [
                  for (var s = 1; s <= 3; s++) ...[
                    if (s > 1) const SizedBox(width: 8),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 8,
                      decoration: BoxDecoration(
                        color: s <= _drawerPage ? Tw.cyan500 : (dark ? Tw.slate700 : Tw.slate200),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ]),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: switch (_drawerPage) {
                1 => _drawerPage1(),
                2 => _drawerPage2(),
                3 => _drawerPage3(),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: border))),
            child: SafeArea(top: false, child: _drawerFooter()),
          ),
        ],
      ),
    );
  }

  Widget _drawerPage1() {
    final published = [for (final b in _store.batches) if (b['status'] == 'published') b];
    final batchNames = {for (final b in published) jsString(b['id']): vueText(b['name'])};
    final institutes = _store.institutes;
    return TsInputTheme(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _drawerSection(
            'Class Configuration',
            TsGrid(columns: _cols3, children: [
              TsField(
                label: const TsLabel('Class Type', required: true),
                child: TsSelect(
                  value: _formClassType.isEmpty ? null : _formClassType,
                  placeholder: 'Select type',
                  items: _classTypeItems,
                  onChanged: (v) => _set(() => _formClassType = v),
                ),
              ),
              TsField(
                label: const TsLabel('Select Class', required: true),
                child: TsSelect(
                  value: jsTruthy(_selectedYear) ? _selectedYear : null,
                  placeholder: 'Select a class',
                  groupLabel: 'Classes',
                  items: [for (final inst in institutes) (jsString(inst['id']), vueText(inst['year']))],
                  onChanged: (v) {
                    _set(() => _selectedYear = v);
                    _onYearChange(v);
                  },
                ),
              ),
              TsField(
                label: const TsLabel('Batch', required: true),
                child: TsSelect(
                  values: _formBatch,
                  placeholder: 'Select batches',
                  items: [for (final e in batchNames.entries) (e.key, e.value)],
                  emptyText: 'No batches available',
                  onChangedMulti: (v) => _set(() => _formBatch = v),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 28),
          _drawerSection(
            'Schedule Settings',
            TsGrid(columns: _cols3, children: [
              TsField(
                label: const TsLabel('Days', required: true),
                child: TsSelect(
                  values: _formDays,
                  placeholder: 'Select days',
                  groupLabel: 'Days',
                  items: tsDays,
                  onChangedMulti: (v) => _set(() => _formDays = v),
                ),
              ),
              TsField(
                label: const TsLabel('Slots', required: true),
                child: _numberField(_formSlots, 'e.g. 3', onChanged: _setFormSlots),
              ),
              TsField(
                label: const TsLabel('Minutes / Slot', required: true),
                child: _numberField(_formMinutes, 'e.g. 60'),
              ),
            ]),
          ),
          const SizedBox(height: 28),
          _drawerSection(
            'Date Range',
            TsGrid(columns: context.isSm ? 2 : 1, children: [
              TsField(
                label: const TsLabel('Start Date', required: true),
                child: TsDateButton(
                  text: _formStartDate != null ? ymd(_formStartDate!) : 'Pick a start date',
                  initial: _formStartDate,
                  onPicked: (d) => _set(() => _formStartDate = d),
                ),
              ),
              TsField(
                label: const TsLabel('End Date', required: true),
                child: TsDateButton(
                  text: _formEndDate != null ? ymd(_formEndDate!) : 'Pick an end date',
                  initial: _formEndDate,
                  onPicked: (d) => _set(() => _formEndDate = d),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  int get _cols4 => context.isXl ? 4 : (context.isLg ? 3 : (context.isSm ? 2 : 1));

  Widget _hint(String text) => Text(text,
      style: TextStyle(fontSize: 16, color: context.isDark ? Tw.slate400 : Tw.slate500));

  Widget _kv(String label, String value) {
    final dark = context.isDark;
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Tw.slate500)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: dark ? Colors.white : Tw.slate800)),
        ),
      ]),
    );
  }

  /// A clickable slot card with the hover "Edit" overlay.
  Widget _slotCard({
    required int index,
    required Widget badge,
    required List<Widget> rows,
    required Color border,
    required String overlayLabel,
    required VoidCallback onTap,
  }) {
    final dark = context.isDark;
    return TsHover(
      onTap: onTap,
      builder: (hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: dark ? Tw.slate800 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: hover ? (dark ? Tw.cyan500.withValues(alpha: 0.5) : TsTw.cyan400) : border),
          boxShadow: hover ? tsShadowMd : tsShadowSm,
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    Expanded(child: TsCaption('Slot ${index + 1}', bold: true)),
                    badge,
                  ]),
                  const SizedBox(height: 4),
                  ...rows,
                ],
              ),
            ),
            // `absolute inset-0 opacity-0 group-hover:opacity-100 transition-opacity`
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: hover ? 1 : 0,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: Tw.cyan500.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Tw.cyan500,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: tsShadowMd,
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(BootstrapIcons.pencil_fill, size: 12, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(overlayLabel,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white)),
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _badge(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
        child: Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
      );

  Widget _drawerPage2() {
    final dark = context.isDark;
    final courses = _courses;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hint('Click a slot card to configure its details.'),
        const SizedBox(height: 16),
        TsGrid(columns: _cols4, children: [
          for (final index in _slotsArray)
            () {
              final slot = index < _slotDetails.length ? _slotDetails[index] : null;
              final classType = '${slot?['classType'] ?? ''}';
              final subject = courses
                  .map(asMap)
                  .where((c) => c != null && jsString(c['id']) == '${slot?['subject']}')
                  .firstOrNull?['title'];
              return _slotCard(
                index: index,
                border: jsTruthy(slot?['title'])
                    ? (dark ? TsTw.cyan700 : TsTw.cyan200)
                    : (dark ? Tw.slate700 : Tw.slate200),
                badge: classType.isNotEmpty
                    ? _badge(classType, dark ? TsTw.cyan900.withValues(alpha: 0.3) : TsTw.cyan50,
                        dark ? TsTw.cyan300 : TsTw.cyan700)
                    : _badge('N/A', dark ? Tw.slate700 : Tw.slate100, Tw.slate400),
                rows: [
                  _kv('Title', '${orJs(slot?['title'], '—')}'),
                  _kv('Time', '${orJs(slot?['startAt'], '—')}'),
                  _kv('Subject', '${orJs(subject, '—')}'),
                ],
                overlayLabel: 'Edit Slot',
                onTap: () => _openSlotDialog(index),
              );
            }(),
        ]),
      ],
    );
  }

  Widget _drawerPage3() {
    final dark = context.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _hint('Review all generated slots. Click any card to edit.'),
        const SizedBox(height: 16),
        TsGrid(columns: _cols4, children: [
          for (var index = 0; index < _previewSlots.length; index++)
            _slotCard(
              index: index,
              border: dark ? Tw.slate700 : Tw.slate200,
              badge: _badge('${orJs(_previewSlots[index]['classType'], 'N/A')}',
                  dark ? TsTw.blue900.withValues(alpha: 0.3) : Tw.blue50, dark ? TsTw.blue300 : Tw.blue700),
              rows: [
                _kv('Title', '${orJs(_previewSlots[index]['title'], '-')}'),
                _kv('Date', '${orJs(_previewSlots[index]['date'], '-')}'),
                _kv('Time', '${orJs(_previewSlots[index]['startAt'], '-')}'),
                _kv('Instructor', '${orJs(_previewSlots[index]['instructor'], '-')}'),
              ],
              overlayLabel: 'Edit',
              onTap: () => _openPreviewSlotDialog(index),
            ),
        ]),
      ],
    );
  }

  Widget _ghostButton(String label, IconData icon, VoidCallback onTap) {
    final dark = context.isDark;
    return TsButton.outlined(
      context,
      label: label,
      icon: icon,
      onPressed: onTap,
      filled: false,
      foreground: dark ? Tw.slate400 : Tw.slate600,
    );
  }

  Widget _drawerFooter() {
    final Widget primary = switch (_drawerPage) {
      1 => TsButton(
          label: 'Next',
          trailingIcon: BootstrapIcons.arrow_right,
          onPressed: _goToPage2,
          hPad: 24,
          fontWeight: FontWeight.w700,
          shadow: true,
        ),
      2 => TsButton(
          label: 'Preview',
          trailingIcon: BootstrapIcons.eye,
          onPressed: _generatePreviewSlots,
          hPad: 24,
          fontWeight: FontWeight.w700,
          shadow: true,
        ),
      _ => TsButton(
          label: 'Submit',
          icon: BootstrapIcons.check_lg,
          loading: _isSubmitting,
          loadingLabel: 'Submitting...',
          onPressed: _submitForm,
          color: Tw.emerald500,
          hoverColor: Tw.emerald400,
          hPad: 24,
          fontWeight: FontWeight.w700,
          shadow: true,
        ),
    };
    return Row(children: [
      if (_drawerPage == 1) _ghostButton('Reset', BootstrapIcons.arrow_counterclockwise, _resetForm),
      if (_drawerPage > 1) _ghostButton('Back', BootstrapIcons.arrow_left, () => _set(() => _drawerPage--)),
      const Spacer(),
      primary,
    ]);
  }

  // ── dialog chrome ────────────────────────────────────────────────────────

  Widget _dialogTitle(String title, {String? description}) {
    final dark = context.isDark;
    final t = Text(title,
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: dark ? Colors.white : Tw.slate900));
    if (description == null) return t;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      t,
      const SizedBox(height: 2),
      Text(description, style: const TextStyle(fontSize: 16, color: Tw.slate500)),
    ]);
  }

  Widget _dialogHeader(Widget tile, Widget title) =>
      Row(children: [tile, const SizedBox(width: 16), Expanded(child: title)]);

  Widget _cancelButton(VoidCallback onTap) => TsButton.outlined(context, label: 'Cancel', onPressed: onTap, filled: false);

  Widget _saveButton(String label, VoidCallback onTap, {bool shadow = false}) => TsButton(
        label: label,
        icon: BootstrapIcons.check_lg,
        onPressed: onTap,
        hPad: 24,
        fontWeight: FontWeight.w700,
        shadow: shadow,
      );

  // ── slot dialog (page 2) ─────────────────────────────────────────────────

  Widget _buildSlotDialog(BuildContext ctx) {
    final editing = _editingSlot;
    final instructors = [for (final i in _store.instructors) ?asMap(i)];
    final filtered = filteredInstructors(_store.instructors, _search);
    return TsDialogShell(
      header: _dialogHeader(
        const TsIconTile(icon: BootstrapIcons.grid_3x2_gap),
        _dialogTitle('Edit Slot ${(_selectedSlotIndex ?? 0) + 1}'),
      ),
      body: editing == null
          ? null
          : TsInputTheme(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TsGrid(columns: 2, children: [
                    TsField(
                      label: const TsLabel('Title'),
                      child: AppTextField(
                        controller: _slotTitle,
                        hint: 'Slot title',
                        onChanged: (v) => editing['title'] = v,
                      ),
                    ),
                    TsField(
                      label: const TsLabel('Time'),
                      child: TsTimeField(
                        value: '${editing['startAt'] ?? ''}',
                        onChanged: (v) => _set(() => editing['startAt'] = v),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  TsField(
                    label: const TsLabel('Subject'),
                    child: TsSelect(
                      value: jsTruthy(editing['subject']) ? '${editing['subject']}' : null,
                      placeholder: 'Select subject',
                      groupLabel: 'Subjects',
                      items: _subjectItems,
                      onChanged: (v) => _set(() => editing['subject'] = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TsField(
                    label: const TsLabel('Instructor'),
                    child: TsSelect(
                      value: jsTruthy(editing['instructor']) ? '${editing['instructor']}' : null,
                      placeholder: 'Select instructor',
                      searchHint: 'Search instructor...',
                      emptyText: 'No instructor found',
                      search: _search,
                      onSearch: (v) => _set(() => _search = v),
                      allLabels: {for (final i in instructors) jsString(i['id']): instructorFullName(i)},
                      items: [for (final i in filtered) (jsString(i['id']), instructorFullName(i))],
                      onChanged: (v) => _set(() => editing['instructor'] = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TsField(
                    label: const TsLabel('Class Type'),
                    child: TsSelect(
                      value: jsTruthy(editing['classType']) ? '${editing['classType']}' : null,
                      placeholder: 'Select class type',
                      items: _classTypeItems,
                      onChanged: (v) => _set(() => editing['classType'] = v),
                    ),
                  ),
                ],
              ),
            ),
      maxWidth: _slotDialogWidth,
      footer: [_cancelButton(_closeSlotDialog), _saveButton('Save Slot', _saveSlotDialog)],
    );
  }

  // ── preview slot dialog (page 3) ─────────────────────────────────────────

  Widget _buildPreviewDialog(BuildContext ctx) {
    final idx = _selectedPreviewIndex;
    final slot = idx != null && idx < _previewSlots.length ? _previewSlots[idx] : null;
    final courseTitles = [
      for (final c in _courses)
        if (asMap(c) != null) vueText(asMap(c)!['title']),
    ];
    final emails = [
      for (final i in _store.instructors)
        if (asMap(i) != null) vueText(dig(i, ['user', 'email'])),
    ];
    return TsDialogShell(
      header: _dialogHeader(
        TsIconTile(
          icon: BootstrapIcons.eye,
          color: Tw.blue500,
          bg: Tw.blue50,
          border: Tw.blue100,
          darkBg: TsTw.blue900.withValues(alpha: 0.2),
          darkBorder: TsTw.blue800,
        ),
        _dialogTitle('Edit Preview Slot ${(idx ?? 0) + 1}'),
      ),
      body: slot == null
          ? null
          : TsInputTheme(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TsField(
                    label: const TsLabel('Title'),
                    child: AppTextField(
                      controller: _previewTitle,
                      hint: 'Enter slot title',
                      onChanged: (v) => _set(() => slot['title'] = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TsGrid(columns: 2, children: [
                    TsField(
                      label: const TsLabel('Date'),
                      child: AppDateField(
                        value: '${slot['date'] ?? ''}',
                        onChanged: (v) => _set(() => slot['date'] = v),
                      ),
                    ),
                    TsField(
                      label: const TsLabel('Start At'),
                      child: TsTimeField(
                        value: '${slot['startAt'] ?? ''}',
                        onChanged: (v) => _set(() => slot['startAt'] = v),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  TsField(
                    label: const TsLabel('Subject'),
                    child: TsSelect(
                      value: jsTruthy(slot['subject']) ? '${slot['subject']}' : null,
                      placeholder: 'Select subject',
                      items: [for (final t in courseTitles) (t, t)],
                      onChanged: (v) => _set(() => slot['subject'] = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TsField(
                    label: const TsLabel('Instructor'),
                    child: TsSelect(
                      value: jsTruthy(slot['instructor']) ? '${slot['instructor']}' : null,
                      placeholder: 'Select instructor',
                      items: [for (final e in emails) (e, e)],
                      onChanged: (v) => _set(() => slot['instructor'] = v),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TsField(
                    label: const TsLabel('Class Type'),
                    child: TsSelect(
                      value: jsTruthy(slot['classType']) ? '${slot['classType']}' : null,
                      placeholder: 'Select type',
                      items: _classTypeItems,
                      onChanged: (v) => _set(() => slot['classType'] = v),
                    ),
                  ),
                ],
              ),
            ),
      maxWidth: _slotDialogWidth,
      footer: [
        _cancelButton(_closePreviewDialog),
        TsButton(
          label: 'Save',
          icon: BootstrapIcons.check_lg,
          onPressed: _savePreviewDialog,
          hPad: 24,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }

  // ── edit schedule dialog ─────────────────────────────────────────────────

  Widget _buildEditDialog(BuildContext ctx) {
    final instructors = [for (final i in _store.instructors) ?asMap(i)];
    final cols = context.isSm ? 2 : 1;
    return TsDialogShell(
      maxWidth: _editDialogWidth,
      header: _dialogHeader(
        const TsIconTile(icon: BootstrapIcons.pencil_square),
        _dialogTitle('Edit Schedule', description: 'Update the details for this class session.'),
      ),
      body: TsInputTheme(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _drawerSection(
              'Date & Time',
              TsGrid(columns: cols, children: [
                TsField(
                  label: const TsLabel('Start Date'),
                  child: TsDateButton(
                    text: _editStartDate.isNotEmpty ? _editStartDate : 'Pick a date',
                    initial: DateTime.tryParse(_editStartDate),
                    onPicked: (d) => _set(() => _editStartDate = ymd(d)),
                  ),
                ),
                TsField(
                  label: const TsLabel('Start Time'),
                  child: TsTimeField(value: _editStartTime, onChanged: (v) => _set(() => _editStartTime = v)),
                ),
                TsField(
                  label: const TsLabel('Duration (minutes)'),
                  child: _numberField(_editDuration, ''),
                ),
              ]),
            ),
            const SizedBox(height: 20),
            _drawerSection(
              'Class Details',
              TsGrid(columns: cols, children: [
                TsField(
                  label: const TsLabel('Class Type'),
                  child: TsSelect(
                    value: _editClassType.isEmpty ? null : _editClassType,
                    placeholder: 'Select class type',
                    items: _classTypeItems,
                    onChanged: (v) => _set(() => _editClassType = v),
                  ),
                ),
                TsField(
                  label: const TsLabel('Title'),
                  child: AppTextField(controller: _editTitle, hint: 'Enter class title'),
                ),
                TsField(
                  label: const TsLabel('Subject'),
                  child: TsSelect(
                    value: _editSubjectId.isEmpty ? null : _editSubjectId,
                    placeholder: 'Select subject',
                    groupLabel: 'Subjects',
                    items: _subjectItems,
                    onChanged: (v) => _set(() => _editSubjectId = v),
                  ),
                ),
                TsField(
                  label: const TsLabel('Instructor'),
                  child: TsSelect(
                    value: _editInstructorId.isEmpty ? null : _editInstructorId,
                    placeholder: 'Select instructor',
                    items: [
                      for (final i in instructors)
                        (jsString(i['id']), '${orJs(dig(i, ['user', 'email']), i['name']) ?? ''}'),
                    ],
                    onChanged: (v) => _set(() => _editInstructorId = v),
                  ),
                ),
              ]),
            ),
          ],
        ),
      ),
      footer: [
        _cancelButton(() => _closeDialog('edit')),
        _saveButton('Save Changes', _submitEditForm, shadow: true),
      ],
    );
  }
}
