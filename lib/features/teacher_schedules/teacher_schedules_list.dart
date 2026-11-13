part of 'teacher_schedules_page.dart';

/// Header, tab navigator, the "On Going" and the period tabs, and the
/// accordion body (inner tabs, chat, participants / attendance).
extension _ListView on _TeacherSchedulesPageState {
  // ── header ───────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    final dark = context.isDark;
    final sm = context.isSm;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _recordings ? 'Class Recordings' : 'Schedules',
          style: TextStyle(
            // `text-3xl sm:text-4xl tracking-tight` (-0.025em).
            fontSize: sm ? 36 : 30,
            height: sm ? 40 / 36 : 36 / 30,
            fontWeight: FontWeight.w700,
            letterSpacing: sm ? -0.9 : -0.75,
            color: dark ? Colors.white : Tw.slate900,
          ),
        ),
        const SizedBox(height: 4),
        Text('Manage online sessions and calendar',
            style: TextStyle(fontSize: 16, color: dark ? Tw.slate400 : Tw.slate500)),
      ],
    );
    final buttons = Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (_role != Role.student && !_recordings)
          TsButton(
            label: 'New Class',
            icon: BootstrapIcons.plus_lg,
            iconSize: 18,
            shadow: true,
            onPressed: _openCreateDrawer,
          ),
        if (!_recordings)
          TsButton.outlined(
            context,
            label: 'Recordings',
            icon: BootstrapIcons.camera_video,
            onPressed: () => _set(() => _recordings = true),
          ),
        if (_recordings)
          TsButton.outlined(
            context,
            label: 'Back',
            icon: BootstrapIcons.arrow_left,
            onPressed: () => _set(() => _recordings = false),
          ),
      ],
    );
    if (sm) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [Expanded(child: title), const SizedBox(width: 16), buttons],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [title, const SizedBox(height: 16), buttons],
    );
  }

  // ── tab navigator ────────────────────────────────────────────────────────

  Widget _card({required Widget child, EdgeInsets padding = EdgeInsets.zero, Color? borderColor}) {
    final dark = context.isDark;
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: dark ? Tw.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? (dark ? Tw.slate700 : Tw.slate200)),
        boxShadow: tsShadowSm,
      ),
      child: child,
    );
  }

  Widget _navArrow(IconData icon, VoidCallback onTap) {
    final dark = context.isDark;
    return TsIconButton(
      icon: icon,
      onTap: onTap,
      size: 40,
      radius: 20,
      iconSize: 16,
      color: dark ? Tw.slate300 : Tw.slate600,
      background: dark ? Tw.slate800 : Tw.slate50,
      hoverBackground: dark ? Tw.slate700 : Tw.slate100,
    );
  }

  Widget _buildTabNavigator() {
    final dark = context.isDark;
    final showFilters = (_role == Role.institute || _role == Role.instructor) && _activeTab != 'ongoing';
    final institutes = _store.institutes;
    final batches = _store.batches;
    return _card(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            _navArrow(BootstrapIcons.chevron_left, _prevTab),
            const SizedBox(width: 12),
            Expanded(
              child: Column(children: [
                Text(tabLabelOf(_activeTab),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 18,
                        height: 1.25,
                        fontWeight: FontWeight.w700,
                        color: dark ? Colors.white : Tw.slate900)),
                const SizedBox(height: 2),
                Text(currentTabDate(_activeTab, DateTime.now()),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.35,
                        color: dark ? Tw.slate500 : Tw.slate400)),
              ]),
            ),
            const SizedBox(width: 12),
            _navArrow(BootstrapIcons.chevron_right, _nextTab),
          ]),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final tab in tsAllTabs)
                TsHover(
                  onTap: () => _setActiveTab(tab.value),
                  builder: (hover) {
                    final active = _activeTab == tab.value;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: active ? 24 : 10,
                      height: 10,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: active
                            ? Tw.cyan500
                            : hover
                                ? (dark ? Tw.slate600 : Tw.slate300)
                                : (dark ? Tw.slate700 : Tw.slate200),
                      ),
                    );
                  },
                ),
            ],
          ),
          if (showFilters) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.only(top: 4),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: dark ? Tw.slate800 : Tw.slate100))),
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.end,
                children: [
                  _filterSelect(
                    caption: 'Class',
                    child: TsSelect(
                      width: 176,
                      value: jsTruthy(_selectedYear) ? _selectedYear : null,
                      placeholder: 'Select class',
                      groupLabel: 'Classes',
                      items: [for (final inst in institutes) (jsString(inst['id']), vueText(inst['year']))],
                      onChanged: (v) {
                        _set(() => _selectedYear = v);
                        _onYearChange(v);
                      },
                    ),
                  ),
                  _filterSelect(
                    caption: 'Batch',
                    child: TsSelect(
                      width: 176,
                      value: _filterBatchId,
                      enabled: jsTruthy(_selectedYear),
                      placeholder: 'Select batch',
                      groupLabel: 'Batches',
                      items: [for (final b in batches) (jsString(b['id']), vueText(b['name']))],
                      onChanged: _setFilterBatchId,
                    ),
                  ),
                  TsIconButton(
                    icon: BootstrapIcons.arrow_clockwise,
                    onTap: _resetFilter,
                    size: 40,
                    radius: 20,
                    iconSize: 16,
                    color: dark ? Tw.slate400 : Tw.slate500,
                    hoverColor: dark ? Colors.white : Tw.slate900,
                    background: dark ? Tw.slate800 : Tw.slate50,
                    hoverBackground: dark ? Tw.slate700 : Tw.slate100,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// `space-y-1.5` caption + `w-44 h-10` select.
  Widget _filterSelect({required String caption, required Widget child}) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TsCaption(caption),
          const SizedBox(height: 6),
          TsInputTheme(height: 40, child: child),
        ],
      );

  // ── empty states ─────────────────────────────────────────────────────────

  Widget _emptyState({
    required IconData icon,
    required Color iconColor,
    required Color tileBg,
    required Color tileBorder,
    required String title,
    required String text,
    required double textMaxWidth,
    required String buttonLabel,
    Widget? extra,
    bool tileShadow = false,
  }) {
    final dark = context.isDark;
    return _card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: tileBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: tileBorder),
                boxShadow: tileShadow ? tsShadowSm : null,
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: dark ? Colors.white : Tw.slate900)),
            const SizedBox(height: 8),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: textMaxWidth),
              child: Text(text,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, height: 1.6, color: dark && extra != null ? Tw.slate400 : Tw.slate500)),
            ),
            ?extra,
            if (_role != Role.student) ...[
              const SizedBox(height: 24),
              TsButton(
                label: buttonLabel,
                icon: BootstrapIcons.plus_lg,
                hPad: 24,
                shadow: true,
                onPressed: _openCreateDrawer,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── timeline ─────────────────────────────────────────────────────────────

  /// Time column, indicator dot + line, and the card.
  Widget _timelineRow({required Widget time, required Widget dot, required Widget card}) {
    final dark = context.isDark;
    final sm = context.isSm;
    final timeWidth = sm ? 96.0 : 80.0;
    final gap = sm ? 20.0 : 12.0;
    return Stack(
      children: [
        Positioned(
          left: timeWidth + gap + 7.5,
          top: 16 + 16 + 8,
          bottom: 0,
          child: Container(width: 1, color: dark ? Tw.slate700 : Tw.slate200),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: timeWidth, child: Padding(padding: const EdgeInsets.only(top: 16), child: time)),
            SizedBox(width: gap),
            Padding(padding: const EdgeInsets.only(top: 16), child: dot),
            SizedBox(width: gap),
            Expanded(child: Padding(padding: const EdgeInsets.only(bottom: 12), child: card)),
          ],
        ),
      ],
    );
  }

  /// [tracking]: `tracking-wide` on the ongoing type label only.
  Widget _timeText(String main, String sub, Color mainColor, {bool tracking = false}) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(main,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: mainColor)),
          Text(sub.toUpperCase(),
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: tracking ? 0.3 : 0, color: Tw.slate400)),
        ],
      );

  Widget _editButton(Object? id) {
    final dark = context.isDark;
    return TsIconButton(
      icon: BootstrapIcons.pencil_square,
      onTap: () => _onEditSchedule(id),
      color: Tw.slate400,
      hoverColor: dark ? Tw.slate200 : Tw.slate700,
      hoverBackground: dark ? Tw.slate800 : Tw.slate50,
    );
  }

  Widget _deleteButton(Object? id) {
    final dark = context.isDark;
    return TsIconButton(
      icon: BootstrapIcons.trash,
      onTap: () => _deleteScheduleItem(id),
      color: TsTw.rose400,
      hoverColor: Tw.rose600,
      hoverBackground: dark ? TsTw.rose900.withValues(alpha: 0.2) : Tw.rose50,
    );
  }

  Widget _chevronButton(bool open, VoidCallback onTap) {
    final dark = context.isDark;
    return TsIconButton(
      icon: open ? BootstrapIcons.chevron_up : BootstrapIcons.chevron_down,
      onTap: onTap,
      color: Tw.slate400,
      hoverColor: Tw.cyan500,
      hoverBackground: dark ? Tw.slate800 : Tw.slate50,
    );
  }

  Widget _smallActionButton(String label, IconData icon, Color color, Color hover, VoidCallback onTap) => TsButton(
        label: label,
        icon: icon,
        onPressed: onTap,
        color: color,
        hoverColor: hover,
        height: 36,
        hPad: 16,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        gap: 6,
      );

  /// The clickable header of a schedule card (pills + actions).
  Widget _cardHeader({required List<Widget> pills, required List<Widget> actions, required VoidCallback onToggle, bool wrapActions = true}) {
    final dark = context.isDark;
    final sm = context.isSm;
    final pillWrap = Wrap(spacing: 8, runSpacing: 8, children: pills);
    // `@click.stop` — taps between the buttons don't toggle the accordion.
    final actionRow = GestureDetector(
      onTap: () {},
      behavior: HitTestBehavior.opaque,
      child: wrapActions
          ? Wrap(spacing: 8, runSpacing: 8, crossAxisAlignment: WrapCrossAlignment.center, children: actions)
          : Row(mainAxisSize: MainAxisSize.min, children: [
              for (var i = 0; i < actions.length; i++) ...[if (i > 0) const SizedBox(width: 8), actions[i]],
            ]),
    );
    return TsHover(
      onTap: onToggle,
      builder: (hover) => Container(
        padding: EdgeInsets.all(sm ? 20 : 16),
        decoration: BoxDecoration(
          color: hover ? (dark ? Tw.slate800.withValues(alpha: 0.4) : Tw.slate50) : null,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: sm
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Expanded(child: pillWrap), const SizedBox(width: 12), actionRow],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [pillWrap, const SizedBox(height: 12), actionRow],
              ),
      ),
    );
  }

  Widget _scheduleCard({required Color border, required Widget header, required bool open, required Widget Function() body}) {
    final dark = context.isDark;
    return Container(
      decoration: BoxDecoration(
        color: dark ? Tw.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: tsShadowSm,
      ),
      // shadcn `<Card>` keeps its `py-6` (the template only resets
      // CardContent's padding).
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          // `<Transition name="expand">` (simplified to a size animation).
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            alignment: Alignment.topCenter,
            child: open
                ? Container(
                    padding: EdgeInsets.fromLTRB(context.isSm ? 20 : 16, 20, context.isSm ? 20 : 16, 20),
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: dark ? Tw.slate800 : Tw.slate100))),
                    child: body(),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  // ── "On Going" tab ───────────────────────────────────────────────────────

  Widget _buildOngoingTab() {
    final dark = context.isDark;
    if (_ongoingSchedules.isEmpty) {
      return _emptyState(
        icon: BootstrapIcons.calendar_x,
        iconColor: TsTw.cyan400,
        tileBg: dark ? TsTw.cyan900.withValues(alpha: 0.2) : TsTw.cyan50,
        tileBorder: dark ? TsTw.cyan800 : TsTw.cyan100,
        title: 'No ongoing classes',
        text: 'There are no live sessions right now. Check back later or schedule a new class.',
        textMaxWidth: 384,
        buttonLabel: 'Schedule a class',
        tileShadow: true,
        extra: Container(
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: dark ? Tw.slate800 : Tw.slate50,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: dark ? Tw.slate700 : Tw.slate200),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            TsPulse(
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: dark ? Tw.slate600 : Tw.slate300, shape: BoxShape.circle),
              ),
            ),
            const SizedBox(width: 8),
            Text('Auto-refreshes every 10 minutes',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: dark ? Tw.slate400 : Tw.slate500)),
          ]),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < _ongoingSchedules.length; i++) ...[
          if (i > 0) const SizedBox(height: 16),
          _ongoingItem(asMap(_ongoingSchedules[i]) ?? const {}),
        ],
      ],
    );
  }

  Widget _ongoingItem(Json item) {
    final dark = context.isDark;
    final id = item['id'];
    final open = _openAccordionId == id;
    return _timelineRow(
      time: _timeText(vueText(item['start_time']), vueText(item['type']), dark ? TsTw.cyan400 : Tw.cyan500,
          tracking: true),
      dot: TsLiveDot(color: Tw.cyan500, borderColor: dark ? Tw.slate950 : Tw.slate50),
      card: _scheduleCard(
        border: dark ? TsTw.cyan800.withValues(alpha: 0.5) : TsTw.cyan100,
        open: open,
        header: _cardHeader(
          onToggle: () => _toggleAccordion(id),
          pills: [
            TsPill(
              text: vueText(dig(item, ['batch', 'classes', 'name'])),
              bg: dark ? TsTw.blue900.withValues(alpha: 0.3) : Tw.blue50,
              fg: dark ? TsTw.blue300 : Tw.blue700,
            ),
            TsPill(
              text: vueText(item['title']),
              bg: dark ? TsTw.indigo900.withValues(alpha: 0.3) : Tw.indigo50,
              fg: dark ? Tw.indigo300 : Tw.indigo700,
            ),
            TsPill(
              text: vueText(item['status']),
              bg: dark ? TsTw.emerald900.withValues(alpha: 0.3) : Tw.emerald50,
              fg: dark ? TsTw.emerald300 : Tw.emerald700,
              dot: Tw.emerald500,
              bold: true,
            ),
          ],
          actions: [
            if (_role != Role.student) ...[_editButton(id), _deleteButton(id)],
            if (_role == Role.instructor)
              _smallActionButton('Start', BootstrapIcons.play_fill, Tw.emerald500, Tw.emerald400, () => _handleStart(id)),
            if (_role == Role.student)
              _smallActionButton(
                  'Join', BootstrapIcons.box_arrow_in_right, Tw.emerald500, Tw.emerald400, () => _handleStart(id)),
            if (_role != Role.institute)
              _smallActionButton('Full', BootstrapIcons.fullscreen, Tw.blue500, Tw.blue400, () => _openFullClient(id)),
            _chevronButton(open, () => _toggleAccordion(id)),
          ],
        ),
        body: () => _expandedBody(ongoing: true),
      ),
    );
  }

  // ── period tabs ──────────────────────────────────────────────────────────

  Widget _buildOtherTab() {
    final dark = context.isDark;
    final schedules = _store.schedules;
    if (schedules.isEmpty) {
      return _emptyState(
        icon: BootstrapIcons.calendar3,
        iconColor: dark ? Tw.slate600 : Tw.slate300,
        tileBg: dark ? Tw.slate800 : Tw.slate50,
        tileBorder: dark ? Tw.slate700 : Tw.slate200,
        title: 'No schedules found',
        text: 'No schedules exist for this period.',
        textMaxWidth: 320,
        buttonLabel: 'Create schedule',
      );
    }
    final groups = groupByClassBatch(schedules);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var g = 0; g < groups.length; g++) ...[
          if (g > 0) const SizedBox(height: 32),
          Row(children: [
            Container(
              width: 6,
              height: 32,
              decoration: BoxDecoration(color: Tw.cyan500, borderRadius: BorderRadius.circular(999)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text.rich(
                TextSpan(children: [
                  TextSpan(text: '${groups[g].className} '),
                  // `<span class="text-slate-400 mx-2">›</span>`
                  const WidgetSpan(
                    alignment: PlaceholderAlignment.baseline,
                    baseline: TextBaseline.alphabetic,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('›',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Tw.slate400)),
                    ),
                  ),
                  TextSpan(text: ' ${groups[g].batchName}', style: const TextStyle(color: Tw.cyan500)),
                ]),
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: dark ? Colors.white : Tw.slate900),
              ),
            ),
          ]),
          const SizedBox(height: 16),
          for (var i = 0; i < groups[g].items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _otherItem(groups[g].items[i]),
          ],
        ],
      ],
    );
  }

  Widget _otherItem(Json item) {
    final dark = context.isDark;
    final id = item['id'];
    final open = _openOtherAccordionId == id;
    final missed = isMissedOrCanceled(item['status']);
    return _timelineRow(
      time: _timeText(vueText(item['start_time']), vueText(item['start_date']), dark ? Colors.white : Tw.slate900),
      dot: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          color: missed ? Tw.rose500 : Tw.amber400,
          shape: BoxShape.circle,
          border: Border.all(color: dark ? Tw.slate950 : Tw.slate50, width: 4),
        ),
      ),
      card: _scheduleCard(
        border: dark ? Tw.slate700 : Tw.slate200,
        open: open,
        header: _cardHeader(
          onToggle: () => _toggleOtherAccordion(id),
          wrapActions: false,
          pills: [
            TsPill(
              text: '${orJs(dig(item, ['course', 'title']), 'No Course')}',
              bg: dark ? TsTw.indigo900.withValues(alpha: 0.3) : Tw.indigo50,
              fg: dark ? Tw.indigo300 : Tw.indigo700,
            ),
            TsPill(
              text: vueText(item['title']),
              bg: dark ? Tw.slate800 : Tw.slate100,
              fg: dark ? Tw.slate300 : Tw.slate600,
            ),
            TsPill(
              text: vueText(item['status']),
              bg: missed
                  ? (dark ? TsTw.rose900.withValues(alpha: 0.3) : Tw.rose50)
                  : (dark ? TsTw.emerald900.withValues(alpha: 0.3) : Tw.emerald50),
              fg: missed ? (dark ? TsTw.rose400 : Tw.rose600) : (dark ? Tw.emerald400 : Tw.emerald700),
              bold: true,
            ),
          ],
          actions: [
            if (_role != Role.student) ...[_editButton(id), _deleteButton(id)],
            _chevronButton(open, () => _toggleOtherAccordion(id)),
          ],
        ),
        body: () => _expandedBody(ongoing: false),
      ),
    );
  }

  // ── accordion body ───────────────────────────────────────────────────────

  Widget _expandedBody({required bool ongoing}) {
    final xl = context.isXl;
    final chatHeight = ongoing ? 380.0 : 340.0;
    final inner = _innerPanel(ongoing: ongoing, minHeight: xl ? chatHeight : 0);
    final chat = _chatPanel(ongoing: ongoing, height: chatHeight);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (xl)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: inner),
              const SizedBox(width: 16),
              SizedBox(width: ongoing ? 320 : 288, child: chat),
            ],
          )
        else ...[
          inner,
          const SizedBox(height: 16),
          chat,
        ],
        const SizedBox(height: 16),
        if (ongoing) _participantsTable() else _attendanceTable(),
      ],
    );
  }

  Widget _innerPanel({required bool ongoing, required double minHeight}) {
    final dark = context.isDark;
    return Container(
      constraints: BoxConstraints(minHeight: minHeight, maxHeight: ongoing ? 480 : 460),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? Tw.slate950 : Tw.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Tw.slate700 : Tw.slate200),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: dark ? Tw.slate900 : Colors.white,
              border: Border(bottom: BorderSide(color: dark ? Tw.slate700 : Tw.slate200)),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [for (final t in tsInnerTabs) _innerTabButton(t, ongoing: ongoing)]),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _innerTabContent(ongoing: ongoing),
            ),
          ),
        ],
      ),
    );
  }

  Widget _innerTabButton(TabDef t, {required bool ongoing}) {
    final dark = context.isDark;
    final active = _activetabs == t.value;
    return TsHover(
      onTap: () => _selectInnerTab(t.value),
      builder: (hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: active && ongoing ? (dark ? TsTw.cyan900.withValues(alpha: 0.1) : TsTw.cyan50.withValues(alpha: 0.5)) : null,
          border: Border(bottom: BorderSide(color: active ? Tw.cyan500 : Colors.transparent, width: 2)),
        ),
        child: Text(
          t.label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: active
                ? (dark ? TsTw.cyan400 : TsTw.cyan600)
                : hover
                    ? (dark ? Colors.white : Tw.slate900)
                    : (dark ? Tw.slate400 : Tw.slate500),
          ),
        ),
      ),
    );
  }

  Widget _innerTabContent({required bool ongoing}) {
    switch (_activetabs) {
      case 'BasicInfo':
        return _basicInfo(ongoing: ongoing);
      case 'ClassReference':
        return _contentTable(
          addLabel: 'Add Reference',
          onAdd: ongoing ? _openClassReferenceDialog : () => _openDialog('classRef', _buildClassReferenceDialog),
          rows: _classreference,
          emptyText: ongoing ? 'No references found' : 'No references',
          onView: _viewClassReference,
          onEdit: _editClassReference,
          onDelete: (r) => _deleteClassReference(r['id']),
        );
      case 'ClassActivity':
        return _contentTable(
          addLabel: 'Add Assignment',
          onAdd: ongoing ? _openClassActivityDialog : () => _openDialog('classAct', _buildClassActivityDialog),
          rows: _classActivities,
          emptyText: ongoing ? 'No class assignments' : 'No assignments',
          onView: _viewClassAct,
          onEdit: _editClassActivity,
          onDelete: (a) => _deleteClassActivity(a['id']),
        );
      case 'HomeActivity':
        return _contentTable(
          addLabel: 'Add Assignment',
          onAdd: () => _openDialog('homeAct', _buildHomeActivityDialog),
          rows: _homeActivities,
          emptyText: ongoing ? 'No home assignments' : 'No assignments',
          onView: _viewHomeAct,
          onEdit: _editHomeActivity,
          onDelete: (a) => _deleteHomeActivity(a['id']),
        );
      case 'Quiz':
        return _quizTab(ongoing: ongoing);
      default:
        return const SizedBox.shrink();
    }
  }

  /// A disabled `<Input>` of the Basic Info tab (the period tabs don't set
  /// a border colour, so theirs is `border-input`).
  Widget _readonlyInput(String text, {required bool ongoing}) {
    final dark = context.isDark;
    final border = ongoing
        ? (dark ? Tw.slate700 : Tw.slate200)
        : (dark ? AppColors.darkInput : AppColors.input);
    return Opacity(
      opacity: 0.5,
      child: Container(
        height: 40,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: dark ? Tw.slate900 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: border),
          boxShadow: const [BoxShadow(color: Color(0x0D000000), blurRadius: 3, offset: Offset(0, 1))],
        ),
        child: Text(text,
            maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: tsInputFontSize(context))),
      ),
    );
  }

  Widget _basicInfo({required bool ongoing}) {
    Widget f(String label, Object? value) => TsField(
          gap: 6,
          label: TsCaption(label, color: Tw.slate400),
          child: _readonlyInput(vueText(value), ongoing: ongoing),
        );
    final start = f('Start Time', _getScheduleForm['startDate']);
    final duration = f('Duration (mins)', _getScheduleForm['duration']);
    final type = f('Class Type', _getScheduleForm['classType']);
    final title = f('Class Title', _getScheduleForm['title']);
    return TsGrid(
      columns: context.isSm ? 2 : 1,
      children: ongoing ? [start, duration, type, title] : [start, duration, title, type],
    );
  }

  bool get _canAddContent => _role != Role.institute && _role != Role.student;

  Widget _addButton(String label, VoidCallback onTap) => Align(
        alignment: Alignment.centerRight,
        child: TsButton(
          label: label,
          icon: BootstrapIcons.plus,
          onPressed: onTap,
          height: 36,
          hPad: 16,
          fontSize: 14,
          gap: 6,
        ),
      );

  Widget _bordered(Widget child, {Color? color}) {
    final dark = context.isDark;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? Tw.slate700 : Tw.slate200),
      ),
      child: child,
    );
  }

  Widget _contentTable({
    required String addLabel,
    required VoidCallback onAdd,
    required List<Json> rows,
    required String emptyText,
    required void Function(Json) onView,
    required void Function(Json) onEdit,
    required void Function(Json) onDelete,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_canAddContent) ...[_addButton(addLabel, onAdd), const SizedBox(height: 12)],
        _bordered(TsTable(
          columns: const ['ID', 'Name', 'Action'],
          flex: const [1, 3, 2],
          alignEnd: const {2},
          emptyText: emptyText,
          rows: [
            for (final r in rows)
              [
                Text(vueText(r['id'])),
                Text(vueText(r['name'])),
                TsRowActions(onView: () => onView(r), onEdit: () => onEdit(r), onDelete: () => onDelete(r)),
              ],
          ],
        )),
      ],
    );
  }

  Widget _quizTab({required bool ongoing}) {
    final dark = context.isDark;
    final hasQuiz = jsTruthy(_activeexamid) && jsTruthy(_activeScheduleId);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_canAddContent) ...[_addButton('Create Quiz', _openQuizDialog), const SizedBox(height: 12)],
        _bordered(
          Padding(
            padding: const EdgeInsets.all(16),
            child: hasQuiz
                ? ScheduleExamListView(
                    key: ValueKey(_activeScheduleId),
                    examId: _activeexamid!,
                    scheduleId: _activeScheduleId!,
                  )
                : SizedBox(
                    height: ongoing ? 96 : 80,
                    child: Center(
                      child: Text(ongoing ? 'No quiz created yet' : 'No quiz yet',
                          textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, color: Tw.slate400)),
                    ),
                  ),
          ),
          color: dark ? Tw.slate900 : Colors.white,
        ),
      ],
    );
  }

  // ── chat ─────────────────────────────────────────────────────────────────

  Widget _chatPanel({required bool ongoing, required double height}) {
    final dark = context.isDark;
    final divider = dark ? Tw.slate800 : Tw.slate100;
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: dark ? Tw.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Tw.slate700 : Tw.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(border: Border(bottom: BorderSide(color: divider))),
            child: Row(children: [
              const Icon(BootstrapIcons.chat_dots_fill, size: 18, color: Tw.cyan500),
              const SizedBox(width: 8),
              Text('Class Chat',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: dark ? Colors.white : Tw.slate900)),
            ]),
          ),
          Expanded(
            child: _chatMessages.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(12),
                    child: SizedBox(
                      height: ongoing ? 96 : 64,
                      child: const Center(
                        child: Text('No messages yet',
                            textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Tw.slate400)),
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, c) => ListView.separated(
                      padding: const EdgeInsets.all(12),
                      itemCount: _chatMessages.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _chatBubble(_chatMessages[i], maxWidth: c.maxWidth * 0.8 - 12, ongoing: ongoing),
                    ),
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(border: Border(top: BorderSide(color: divider))),
            child: Row(children: [
              Expanded(
                child: TsInputTheme(
                  height: 40,
                  child: TextField(
                    controller: _chatInput,
                    style: TextStyle(fontSize: tsInputFontSize(context)),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(hintText: ongoing ? 'Type a message...' : 'Type...'),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              TsIconButton(
                icon: BootstrapIcons.send_fill,
                onTap: _sendMessage,
                size: 40,
                radius: 20,
                iconSize: 14,
                bordered: false,
                color: Colors.white,
                background: Tw.cyan500,
                hoverBackground: TsTw.cyan400,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _chatBubble(Json msg, {required double maxWidth, required bool ongoing}) {
    final dark = context.isDark;
    final mine = msg['from'] == 'user';
    final fg = mine ? Colors.white : (dark ? Tw.slate200 : Tw.slate800);
    // The bubble is as wide as its widest line; the header row is
    // `justify-between`, so the time sits at the right edge.
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: IntrinsicWidth(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: mine ? Tw.cyan500 : (dark ? Tw.slate800 : Tw.slate100),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(mine ? 16 : 12),
                bottomRight: Radius.circular(mine ? 12 : 16),
              ),
              boxShadow: ongoing ? tsShadowSm : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  // `items-center` on the ongoing tab only.
                  crossAxisAlignment: ongoing ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(vueText(msg['sender']),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg.withValues(alpha: 0.8))),
                    ),
                    SizedBox(width: ongoing ? 12 : 8),
                    Text(vueText(msg['time']), style: TextStyle(fontSize: 12, color: fg.withValues(alpha: 0.6))),
                  ],
                ),
                const SizedBox(height: 2),
                Text(vueText(msg['text']), style: TextStyle(fontSize: 14, height: 1.625, color: fg)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── participants / attendance ────────────────────────────────────────────

  Widget _sectionBox({required Widget title, required Widget table}) {
    final dark = context.isDark;
    return _bordered(
      Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: dark ? Tw.slate800.withValues(alpha: 0.5) : Tw.slate50.withValues(alpha: 0.8),
              border: Border(bottom: BorderSide(color: dark ? Tw.slate800 : Tw.slate100)),
            ),
            child: title,
          ),
          table,
        ],
      ),
      color: dark ? Tw.slate900 : Colors.white,
    );
  }

  Widget _participantsTable() {
    final dark = context.isDark;
    final students = _store.scheduleStudents;
    final list = students is List ? students : const [];
    final heading = TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: dark ? Colors.white : Tw.slate900);
    return _sectionBox(
      title: Wrap(
        spacing: 12,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TsPulse(
            child: Container(
                width: 10, height: 10, decoration: const BoxDecoration(color: Tw.emerald500, shape: BoxShape.circle)),
          ),
          Text('Live Participants', style: heading),
          Text('(${onlineStudentCount(students, _onlineUsers)} active / ${list.length} students)',
              style: const TextStyle(fontSize: 14, color: Tw.slate500)),
        ],
      ),
      table: TsTable(
        columns: const ['Name', 'Email', 'In Class', 'Joined'],
        flex: const [3, 4, 2, 2],
        minWidth: 560,
        emptyText: 'No participants found',
        rows: [
          for (final raw in list)
            () {
              final s = asMap(raw) ?? const <String, dynamic>{};
              final u = asMap(s['user']);
              final online = isStudentOnline(s, _onlineUsers);
              final joined = joinedStudentIdsHas(s, _joinedStudentIds);
              final ok = dark ? Tw.emerald400 : Tw.emerald600;
              return <Widget>[
                Text('${orJs(u?['first_name'], '')} ${orJs(u?['last_name'], '')}'),
                Text('${orJs(u?['email'], 'N/A')}'),
                online
                    ? Row(mainAxisSize: MainAxisSize.min, children: [
                        TsPulse(
                          child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(color: Tw.emerald500, shape: BoxShape.circle)),
                        ),
                        const SizedBox(width: 6),
                        Text('Active', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ok)),
                      ])
                    : const Text('Inactive', style: TextStyle(fontSize: 14, color: Tw.slate400)),
                joined
                    ? Text('Joined', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: ok))
                    : const Text('Not joined', style: TextStyle(fontSize: 14, color: Tw.slate400)),
              ];
            }(),
        ],
      ),
    );
  }

  Widget _attendanceTable() {
    final dark = context.isDark;
    return _sectionBox(
      title: Text('Attendance List',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: dark ? Colors.white : Tw.slate900)),
      table: TsTable(
        columns: const ['Name', 'Email', 'Join', 'Leave', 'Duration', 'Status'],
        flex: const [3, 4, 2, 2, 2, 2],
        minWidth: 760,
        emptyText: 'No attendance records',
        rows: [
          for (final raw in _attendanceRecordsLocal)
            () {
              final rec = asMap(raw) ?? const <String, dynamic>{};
              final u = asMap(dig(rec, ['student', 'user']));
              final attended = jsNumber(rec['duration']) > 0;
              return <Widget>[
                Text('${orJs(u?['first_name'], 'Unknown')} ${orJs(u?['last_name'], '')}'),
                Text('${orJs(u?['email'], '-')}'),
                Text(formatAttendanceTime(rec['from'])),
                Text(formatAttendanceTime(rec['to'])),
                Text('${vueText(orJs(rec['duration'], 0))} mins'),
                Text(
                  attended ? 'Attended' : 'Absent',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: attended ? (dark ? Tw.emerald400 : Tw.emerald600) : Tw.rose500,
                  ),
                ),
              ];
            }(),
        ],
      ),
    );
  }
}
