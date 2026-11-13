part of 'schedules_page.dart';

/// Header, schedule-type tabs, class / batch filters and the schedule lists.
extension _ListUi on _SchedulesPageState {
  Widget _buildHeader(BuildContext context) {
    final title = Text(
      _recordings ? 'Class Recordings' : 'Schedules list',
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        color: context.isDark ? Colors.white : null,
      ),
    );
    final buttons = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (_role != Role.student && !_recordings) AppButton(label: 'Create Schedules', onPressed: _openCreateDrawer),
        if (!_recordings) AppButton(label: 'Recordings', onPressed: _openRecordingDrawer),
        if (_recordings) AppButton(label: 'Back', onPressed: () => _set(() => _recordings = false)),
      ],
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 16,
        runSpacing: 8,
        children: [title, buttons],
      ),
    );
  }

  Widget _buildTabs(BuildContext context) {
    final institute = _role == Role.institute;
    final desktop = context.screenWidth >= 1536;
    final tabs = <(String, String)>[
      ('ongoing', 'On Going'),
      ('today', 'Today'),
      ('thisweek', 'This Week'),
      if (institute) ...[
        ('nextweek', 'Next Week'),
        ('pastweek', 'Past Week'),
        ('thismonth', 'This Month'),
        ('nextmonth', 'Next Month'),
        ('pastmonth', 'Past Month'),
      ],
      ('OverAll', 'OverAll'),
    ];
    // The < 2xl select lists every type, whatever the role.
    const selectItems = [
      AppSelectItem('ongoing', 'On Going'),
      AppSelectItem('today', 'Today'),
      AppSelectItem('thisweek', 'This Week'),
      AppSelectItem('nextweek', 'Next Week'),
      AppSelectItem('pastweek', 'Past Week'),
      AppSelectItem('thismonth', 'This Month'),
      AppSelectItem('nextmonth', 'Next Month'),
      AppSelectItem('pastmonth', 'Past Month'),
      AppSelectItem('OverAll', 'OverAll'),
    ];
    // `<SelectTrigger class="w-full">` in a content-sized flex item: as wide
    // as the selected type.
    var selectedLabel = 'Select Schedule Type';
    for (final t in selectItems) {
      if (t.value == _activeTab) selectedLabel = t.label;
    }
    final selector = desktop
        ? _OuterTabs(tabs: tabs, value: _activeTab, onChanged: _setActiveTab)
        : SizedBox(
            width: _selectFitWidth(context, selectedLabel),
            child: AppSelect<String>(
              value: _activeTab,
              items: selectItems,
              placeholder: 'Select Schedule Type',
              onChanged: (v) {
                if (v != null) _setActiveTab(v);
              },
            ),
          );
    final known = {for (final t in selectItems) t.value};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SingleChildScrollView(scrollDirection: Axis.horizontal, child: selector),
        ),
        // Tabs root `gap-2`: the type row's `mb-6` + 8, the (possibly empty)
        // filter row, then 8 + the content's `mt-4`.
        const SizedBox(height: 32),
        if (_role == Role.institute || _role == Role.instructor) _buildFilters(context),
        const SizedBox(height: 24),
        if (_activeTab == 'ongoing')
          _buildOngoing(context)
        else if (known.contains(_activeTab))
          _buildOtherTab(context),
      ],
    );
  }

  /// "Select Class" / "Batch" filters and the reset icon.
  Widget _buildFilters(BuildContext context) {
    final s = _store;
    final selectedYear = _selectedYear is String ? _selectedYear as String : null;
    final batch = _form.batch is String ? _form.batch as String : null;
    final classItems = [for (final i in s.institutes) AppSelectItem(schString(i['id']), vText(i['year']))];
    final batchItems = [for (final b in s.batches) AppSelectItem(schString(b['id']), vText(b['name']))];
    String shown(List<AppSelectItem<String>> items, String? v, String placeholder) {
      for (final it in items) {
        if (it.value == v) return it.label;
      }
      return placeholder;
    }

    // `space-y-2` flex items sized to their label / select trigger.
    double width(String label, String text) => math.max(
          _textWidth(context, label, const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          _selectFitWidth(context, text),
        );
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.start,
      children: [
        SizedBox(
          width: width('Select Class', shown(classItems, selectedYear, 'Select a Class')),
          child: _labeled(
            'Select Class',
            AppSelect<String>(
              value: selectedYear,
              placeholder: 'Select a Class',
              items: classItems,
              onChanged: (v) {
                _set(() => _selectedYear = v);
                _onYearChange(v);
              },
            ),
          ),
        ),
        SizedBox(
          width: width('Batch', shown(batchItems, batch, 'Select Batch')),
          child: _labeled(
            'Batch',
            AppSelect<String>(
              value: batch,
              placeholder: 'Select Batch',
              enabled: jsTruthy(_selectedYear),
              items: batchItems,
              onChanged: (v) {
                _set(() => _form.batch = v ?? '');
                _touchFormBatch();
              },
            ),
          ),
        ),
        // `<div class="mt-7" @click="resetFilter"><i class="bi …"/></div>`
        // (no pointer cursor; the 16 px glyph sits in a 24 px line).
        Padding(
          padding: const EdgeInsets.only(top: 32),
          child: _IconAction(BootstrapIcons.bootstrap_reboot, onTap: _resetFilter, size: 16, pointer: false),
        ),
      ],
    );
  }

  // ── On Going ─────────────────────────────────────────────────────────────

  Widget _buildOngoing(BuildContext context) {
    if (_ongoingSchedules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Text('No ongoing schedules.', style: TextStyle(fontSize: 16, color: Tw.gray500)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final item in _ongoingSchedules) ...[
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: item['year'] == null
                ? const SizedBox.shrink()
                : Text(
                    vText(item['year']),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: context.colors.primary),
                  ),
          ),
          _AccordionItem(
            open: _openAccordion == _itemKey(item['id']),
            onToggle: () {
              final key = _itemKey(item['id']);
              _set(() => _openAccordion = _openAccordion == key ? '' : key);
              _fetchBasicInfo(item['id']);
            },
            header: (open) => _ongoingHeader(context, item),
            content: () => _buildDetail(context, ongoing: true),
          ),
          const Divider(height: 16, thickness: 1, color: Tw.gray300),
        ],
      ],
    );
  }

  Widget _ongoingHeader(BuildContext context, SJson item) {
    final sm = context.isSm;
    Widget chevron() => sm
        ? const Icon(BootstrapIcons.chevron_right, size: 14, color: Tw.gray400)
        : const SizedBox.shrink();
    final left = Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _Pill(vText(dig(item, ['batch', 'classes', 'name'])), bg: Tw.blue100, fg: Tw.blue800),
        if (sm) chevron(),
        _Pill(vText(item['title']), bg: Tw.indigo100, fg: Tw.indigo800),
        if (sm) chevron(),
        _Pill(vText(item['start_time']), bg: Tw.gray100, fg: Tw.gray700),
        if (sm) chevron(),
        _Pill(vText(item['type']), bg: Tw.gray100, fg: Tw.gray700),
        if (sm) chevron(),
        _Pill(vText(item['status']), bg: Tw.green100, fg: Tw.green800, bold: true),
      ],
    );
    // `<Button class="bg-green-500 text-white px-3 py-1 rounded">` (still
    // `h-9`, and the variant's `hover:bg-primary/90`).
    Widget green(String label, VoidCallback onTap) => AppButton(
          label: label,
          backgroundColor: Tw.green500,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          radius: 4,
          onPressed: onTap,
        );
    final right = Wrap(
      spacing: 12,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        if (_role != Role.student)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _IconAction(BootstrapIcons.pencil_square, onTap: () => _onEditSchedule(item['id'])),
              const SizedBox(width: 16),
              _IconAction(BootstrapIcons.trash, onTap: () => _deleteScheduleItem(item['id'])),
            ],
          ),
        if (_role == Role.instructor) green('Start', () => _handleStart(item['id'])),
        if (_role == Role.student) green('Join', () => _handleStart(item['id'])),
        if (_role != Role.institute) green('Full Client', () => _openFullClient(item['id'])),
      ],
    );
    if (!context.isMd) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [left, const SizedBox(height: 16), Align(alignment: Alignment.centerRight, child: right)],
      );
    }
    return Row(children: [Expanded(child: left), const SizedBox(width: 16), right]);
  }

  // ── Today / This Week / … / OverAll ──────────────────────────────────────

  Widget _buildOtherTab(BuildContext context) {
    final schedules = _store.schedules;
    if (schedules.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Text('No schedules available .',
            textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Tw.gray500)),
      );
    }
    final groups = groupByClassBatch(schedules);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var g = 0; g < groups.length; g++)
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Text.rich(
                    TextSpan(children: [
                      TextSpan(text: vText(groups[g].className)),
                      const WidgetSpan(
                        alignment: PlaceholderAlignment.middle,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(BootstrapIcons.arrow_right_circle, size: 19.2, color: Colors.black),
                        ),
                      ),
                      TextSpan(text: vText(groups[g].batchName)),
                    ]),
                    style: TextStyle(fontSize: 19.2, fontWeight: FontWeight.w700, color: context.colors.primary),
                  ),
                ),
                for (var i = 0; i < groups[g].items.length; i++)
                  _otherItem(context, g, groups[g].items[i], last: i == groups[g].items.length - 1),
                const Divider(height: 16, thickness: 1, color: Tw.gray300),
              ],
            ),
          ),
      ],
    );
  }

  Widget _otherItem(BuildContext context, int group, SJson item, {required bool last}) {
    final key = _itemKey(item['id']);
    return _AccordionItem(
      open: _groupAccordion[group] == key,
      bottomBorder: !last,
      onToggle: () {
        _set(() => _groupAccordion[group] = _groupAccordion[group] == key ? '' : key);
        _fetchBasicInfo(item['id']);
      },
      header: (open) {
        final course = dig(item, ['course', 'title']);
        final bad = isBadStatus(item['status']);
        final left = Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _Badge(jsTruthy(course) ? '$course' : 'No Course',
                bg: Tw.indigo100, fg: Tw.indigo800, hoverBg: Tw.indigo200),
            _Badge(vText(item['title']), bg: Tw.indigo100, fg: Tw.indigo800, hoverBg: Tw.indigo200),
            _Badge(vText(item['start_time']), bg: Tw.gray100, fg: Tw.gray700),
            _Badge(vText(item['type']), bg: Tw.gray100, fg: Tw.gray700),
            _Badge(vText(item['start_date']), bg: Tw.gray100, fg: Tw.gray700),
            _Badge(vText(item['status']),
                bg: bad ? Tw.red100 : Tw.green100, fg: bad ? Tw.red800 : Tw.green800, bold: true),
          ],
        );
        final right = _role == Role.student
            ? const SizedBox.shrink()
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _IconAction(BootstrapIcons.pencil_square, onTap: () => _onEditSchedule(item['id'])),
                  const SizedBox(width: 16),
                  _IconAction(BootstrapIcons.trash, color: Tw.red500, onTap: () => _deleteScheduleItem(item['id'])),
                ],
              );
        return Row(children: [Expanded(child: left), const SizedBox(width: 12), right]);
      },
      content: () => _buildDetail(context, ongoing: false),
    );
  }
}
