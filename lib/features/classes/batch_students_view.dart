import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/external_link.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../institutes/institute_widgets.dart';
import 'class_list_logic.dart';
import 'class_list_vm.dart';
import 'class_list_widgets.dart';
import 'class_ui_kit.dart';
import 'quizsys_pdf.dart';

/// "Batch Student List Inline View": header, actions bar, QR list, the
/// student table and the bulk upload / transfer / promote panels.
class BatchStudentsView extends StatelessWidget {
  const BatchStudentsView({super.key, required this.vm});
  final ClassListVm vm;

  bool get _plainList =>
      vm.bulkAction != 'Bulkpromote' && vm.bulkAction != 'Bulkupload' && vm.bulkAction != 'Bulktransfer';

  @override
  Widget build(BuildContext context) {
    final students = [for (final s in vm.s.students) asMap(s) ?? <String, dynamic>{}];
    final header = Padding(
      padding: const EdgeInsets.all(8),
      child: Row(children: [
        BackSquareButton(
          tooltip: 'Back',
          onTap: () {
            if (vm.bulkAction != '') {
              vm.run(vm.resetStudent);
            } else {
              vm.showBatchStudentsInline = false;
              vm.touch();
            }
          },
        ),
        const SizedBox(width: 12),
        const HeaderIconTile(icon: BootstrapIcons.people_fill),
        const SizedBox(width: 12),
        Flexible(
          child: DetailHeading(
            title: Text.rich(TextSpan(children: [
              const TextSpan(text: 'Students in '),
              TextSpan(text: vueText(vm.selectedBatch['name']), style: const TextStyle(fontWeight: FontWeight.w800)),
            ])),
            subtitle: 'Manage, enroll and transfer students in this batch.',
          ),
        ),
      ]),
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      header,
      const SizedBox(height: 16),
      Padding(
        padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _ActionsBar(vm: vm),
          if (vm.showQuizSysCardList) ...[const SizedBox(height: 16), _QrList(vm: vm)],
          // `gap-4`, plus the QR card's `mb-4` when it is shown.
          if (_plainList) ...[
            SizedBox(height: vm.showQuizSysCardList ? 32 : 16),
            _StudentTable(vm: vm, students: students),
          ],
          if (vm.bulkAction == 'Bulkupload') ...[const SizedBox(height: 32), _BulkUpload(vm: vm)],
          if (vm.bulkAction == 'Bulktransfer') ...[const SizedBox(height: 16), _BulkTransfer(vm: vm, students: students)],
          if (students.isNotEmpty && _plainList)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Align(
                alignment: Alignment.centerRight,
                child: ClassPagination(
                  meta: vm.s.studentPagination,
                  onPage: (p) => vm.run(() => vm.onStudentPageChange(p)),
                ),
              ),
            ),
          if (vm.bulkAction == 'Bulkpromote') ...[const SizedBox(height: 16), _BulkPromote(vm: vm, students: students)],
        ]),
      ),
    ]);
  }
}

class _ActionsBar extends StatelessWidget {
  const _ActionsBar({required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final manage = vm.canManageClass;
    // shadcn `h-9` + `px-4 py-2`.
    const pad = EdgeInsets.symmetric(horizontal: 16);
    final left = Wrap(spacing: 10, runSpacing: 10, crossAxisAlignment: WrapCrossAlignment.center, children: [
      if (manage)
        ClassButton(
          onPressed: () => vm.setOpen(ClassDialog.createStudent, true),
          icon: BootstrapIcons.person_plus_fill,
          label: 'Create Student',
          padding: pad,
          height: 36,
        ),
      if (manage)
        SizedBox(
          width: 176,
          child: MenuSelect<String>(
            value: vm.bulkAction.isEmpty ? null : vm.bulkAction,
            fontWeight: FontWeight.w500,
            shadow: shadowSm,
            menuRadius: 20,
            menuBorder: dark ? Tw.slate700 : Tw.slate200,
            groupLabel: 'Bulk actions',
            compactLabel: true,
            primaryIcons: false,
            itemRadius: 16,
            onSelected: vm.setBulkAction,
            items: const [
              MenuSelectItem('Bulkupload', 'Bulk upload', icon: BootstrapIcons.upload),
              MenuSelectItem('Bulkpromote', 'Bulk promote', icon: BootstrapIcons.arrow_up_circle),
              MenuSelectItem('Bulktransfer', 'Bulk transfer', icon: BootstrapIcons.arrow_left_right),
            ],
            trigger: Text(
              switch (vm.bulkAction) {
                'Bulkupload' => 'Bulk upload',
                'Bulkpromote' => 'Bulk promote',
                'Bulktransfer' => 'Bulk transfer',
                _ => 'Bulk Actions',
              },
              overflow: TextOverflow.ellipsis,
              // Global `[data-placeholder] { color: #9ca3af }`; no text colour otherwise.
              style: TextStyle(
                color: vm.bulkAction.isEmpty
                    ? AppColors.placeholder
                    : (dark ? AppColors.darkForeground : AppColors.foreground),
              ),
            ),
          ),
        ),
      if (manage)
        ClassButton(
          onPressed: () => vm.run(vm.openQuizSysGenerator),
          disabled: vm.isQuizSysLaunching || vm.isQuizSysCardsLoading,
          color: Tw.slate700,
          hoverColor: Tw.slate600,
          icon: BootstrapIcons.qr_code_scan,
          label: vm.isQuizSysLaunching ? 'Generating...' : 'Generate Missing QR',
          padding: pad,
          height: 36,
        ),
      if (manage)
        ClassButton(
          onPressed: () => vm.run(vm.openQuizSysCardList),
          disabled: vm.isQuizSysCardsLoading,
          color: ClassTw.cyan600,
          hoverColor: ClassTw.cyan700,
          padding: pad,
          height: 36,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (vm.isQuizSysCardsLoading)
              const SpinIcon(size: 14, color: Colors.white)
            else
              const Icon(BootstrapIcons.list_ul, size: 14, color: Colors.white),
            const SizedBox(width: 8),
            const Text('List QR'),
          ]),
        ),
    ]);

    final search = IconSearchInput(
      controller: vm.searchQueryStudent,
      hint: 'Search Student...',
      vPad: 9.5,
      darkIconColor: Tw.slate400,
      onSubmitted: vm.searchStudentsByName,
    );
    final searchButton = ClassButton(
      onPressed: vm.searchStudentsByName,
      label: 'Search',
      color: dark ? Tw.slate700 : Tw.slate800,
      hoverColor: dark ? Tw.slate600 : Tw.slate700,
      padding: pad,
      height: 36,
    );
    final right = Row(mainAxisSize: MainAxisSize.min, children: [
      Flexible(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 384), child: search)),
      const SizedBox(width: 8),
      searchButton,
    ]);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? ClassTw.navy.withValues(alpha: 0.4) : Tw.slate50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate100),
      ),
      child: context.isMd
          ? Row(children: [
              Flexible(child: left),
              const SizedBox(width: 12),
              Expanded(child: Align(alignment: Alignment.centerRight, child: right)),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              left,
              const SizedBox(height: 12),
              Row(children: [Expanded(child: search), const SizedBox(width: 8), searchButton]),
            ]),
    );
  }
}

/// `<Card v-if="showQuizSysCardList">` — "Batch QR List".
class _QrList extends StatelessWidget {
  const _QrList({required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final cards = vm.quizSysCards;
    final titles = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Batch QR List',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: dark ? Colors.white : Tw.slate800)),
      Text('Generated QR cards for students in this batch.',
          style: TextStyle(fontSize: 12, color: dark ? Tw.slate400 : Tw.slate500)),
    ]);
    final buttons = Wrap(spacing: 8, runSpacing: 8, children: [
      ClassButton(
        onPressed: () => vm.run(vm.downloadQuizSysCardsPdf),
        disabled: cards.isEmpty,
        icon: BootstrapIcons.file_earmark_pdf_fill,
        label: 'Download PDF',
        // Button `gap-2` + the icon's `mr-2`.
        gap: 16,
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 16),
      ),
      AppButton(
        label: 'Close',
        variant: AppButtonVariant.outline,
        onPressed: () {
          vm.showQuizSysCardList = false;
          vm.touch();
        },
      ),
    ]);

    Widget body;
    if (vm.isQuizSysCardsLoading) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          SpinIcon(size: 14, color: dark ? Tw.slate400 : Tw.slate500),
          const SizedBox(width: 8),
          Text('Loading QR cards...', style: TextStyle(fontSize: 14, color: dark ? Tw.slate400 : Tw.slate500)),
        ]),
      );
    } else if (cards.isEmpty) {
      body = DashedBox(
        color: dark ? Tw.slate800 : Tw.slate200,
        radius: 20,
        strokeWidth: 1,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text('No generated QR cards found for this batch.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: dark ? Tw.slate400 : Tw.slate500)),
        ),
      );
    } else {
      body = Container(
        constraints: const BoxConstraints(maxHeight: 320),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dark ? Tw.slate800 : Tw.slate100),
        ),
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: cards.length,
          separatorBuilder: (_, _) => Divider(height: 1, thickness: 1, color: dark ? Tw.slate800 : Tw.slate100),
          itemBuilder: (context, i) => _QrRow(vm: vm, card: cards[i]),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate100),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        if (context.isMd)
          Row(children: [Expanded(child: titles), buttons])
        else
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [titles, const SizedBox(height: 12), buttons]),
        // `mb-4` + the card's `gap-6`.
        const SizedBox(height: 40),
        body,
      ]),
    );
  }
}

class _QrRow extends StatelessWidget {
  const _QrRow({required this.vm, required this.card});
  final ClassListVm vm;
  final Json card;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final info = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(vueText(card['name']),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: dark ? Colors.white : Tw.slate800)),
      Text(jsTruthy(card['email']) ? vueText(card['email']) : 'Student ID ${jsMember(card, 'student_id')}',
          maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
      const SizedBox(height: 4),
      Text('Marker ${vueText(card['marker_id'])}',
          style: TextStyle(fontSize: 10.4, fontWeight: FontWeight.w600, color: context.colors.primary)),
    ]);
    final download = ClassButton(
      onPressed: () => vm.run(() => vm.downloadQuizSysSingleCardPdf(card)),
      color: Tw.slate800,
      hoverColor: Tw.slate700,
      icon: BootstrapIcons.download,
      iconSize: 12,
      // Button `gap-2` + the icon's `mr-1.5`.
      gap: 14,
      fontSize: 12,
      label: 'Download',
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12),
    );
    return Container(
      color: dark ? Tw.slate950 : Tw.slate50,
      padding: const EdgeInsets.all(12),
      child: context.isSm
          ? Row(children: [
              QuizSysSvgThumb(svg: vueText(card['svg'])),
              const SizedBox(width: 12),
              Expanded(child: info),
              const SizedBox(width: 12),
              download,
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              QuizSysSvgThumb(svg: vueText(card['svg'])),
              const SizedBox(height: 12),
              info,
              const SizedBox(height: 12),
              download,
            ]),
    );
  }
}

class _StudentTable extends StatelessWidget {
  const _StudentTable({required this.vm, required this.students});
  final ClassListVm vm;
  final List<Json> students;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final manage = vm.canManageClass;
    final primary = context.colors.primary;
    return ClassTable(
      loading: vm.isListLoading,
      showEmptyWhileLoading: true,
      radius: 16,
      cardColor: dark ? Tw.slate900 : Colors.white,
      borderColor: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate100,
      cellVPad: 12,
      minWidth: manage ? 1040 : 480,
      columns: [
        const ClassCol('Student Name', flex: 1.3),
        const ClassCol('Status', flex: 0.7),
        if (manage) const ClassCol('Email', flex: 1.3),
        if (manage) const ClassCol('Actions', alignEnd: true, flex: 2.8, right: 24),
      ],
      empty: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 8),
        child: Column(children: [
          Icon(BootstrapIcons.people, size: 18, color: dark ? Tw.slate700 : Tw.slate300),
          const SizedBox(height: 8),
          Text('No students found. Create one to get started.',
              textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: dark ? Tw.slate500 : Tw.slate400)),
        ]),
      ),
      rows: [
        for (final st in students)
          ClassRow(dimmed: st['pivot_status'] == false, [
            Row(children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(shape: BoxShape.circle, color: primary.withValues(alpha: 0.15)),
                alignment: Alignment.center,
                child: Text(
                  jsTruthy(st['name']) ? vueText(st['name']).substring(0, 1).toUpperCase() : 'S',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: primary),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(vueText(st['name']),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w600, color: dark ? Tw.slate200 : Tw.slate800)),
              ),
            ]),
            StatusPill(active: isStudentActive(st['status']), pulse: true, gap: 4, rose450: true),
            if (manage)
              Text(vueText(st['email']),
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.w500, color: dark ? Tw.slate400 : null)),
            if (manage) _studentActions(st),
          ]),
      ],
    );
  }

  Widget _studentActions(Json st) {
    final generating = vm.isQuizSysStudentGenerating(st['id']);
    final hasCard = studentHasQuizSysCard(st);
    final buttons = <Widget>[
      // No handler in the web either.
      const RoundAction(icon: BootstrapIcons.calendar2_event_fill, tone: RoundTone.violet, tooltip: 'Calendar Event'),
      RoundAction(
        icon: BootstrapIcons.envelope_fill,
        tone: RoundTone.orange,
        tooltip: 'Compose email via Gmail',
        onTap: () => openExternal(gmailComposeUrl(st['email'])),
      ),
      RoundAction(
        icon: BootstrapIcons.telephone_fill,
        tone: RoundTone.blue,
        tooltip: 'Call',
        onTap: () => vm.openPhoneDialog('${jsMember(st, 'country_code')}${jsMember(st, 'phone')}'),
      ),
      RoundAction(
        icon: BootstrapIcons.arrow_left_right,
        tone: RoundTone.purple,
        tooltip: 'Transfer Batch',
        onTap: () => vm.openSingleStudentTransfer(st['id']),
      ),
      RoundAction(
        icon: BootstrapIcons.arrow_up_circle_fill,
        tone: RoundTone.yellow,
        tooltip: 'Promote Student',
        onTap: () => vm.openSinglePromote(st['id']),
      ),
      RoundAction(
        icon: BootstrapIcons.qr_code,
        tone: RoundTone.cyan,
        tooltip: hasCard ? 'QR already generated' : 'Generate QR',
        disabled: hasCard || generating,
        spinning: generating,
        onTap: () => vm.run(() => vm.generateQuizSysCardForStudent(st['id'])),
      ),
      RoundAction(
        icon: BootstrapIcons.pencil_square,
        tone: RoundTone.emerald,
        tooltip: 'Update Student',
        onTap: () => vm.run(() => vm.openStudentUpdateDialog(st['id'])),
      ),
      // No handler in the web either.
      const RoundAction(icon: BootstrapIcons.telephone_x_fill, tone: RoundTone.slate, tooltip: 'Call block'),
      RoundAction(
        icon: BootstrapIcons.trash3_fill,
        tone: RoundTone.rose450,
        tooltip: 'Detach Student',
        onTap: () => vm.openDetachStudentDialog(vueText(st['id']), vueText(st['name'])),
      ),
    ];
    return Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < buttons.length; i++) ...[if (i > 0) const SizedBox(width: 8), buttons[i]],
    ]);
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.subtitle);
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: Column(children: [
            Text(title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: dark ? Colors.white : null)),
            const SizedBox(height: 4),
            Text(subtitle,
                textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: dark ? Tw.slate400 : null)),
          ]),
        ),
      ),
    );
  }
}

class _BulkUpload extends StatelessWidget {
  const _BulkUpload({required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final picker = Container(
      constraints: const BoxConstraints(maxWidth: 448),
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900.withValues(alpha: 0.5) : Tw.slate50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Tw.slate800 : Tw.slate100),
      ),
      child: Column(children: [
        ClassButton(
          onPressed: () => vm.run(vm.downloadstudentxl),
          color: Tw.emerald600,
          hoverColor: Tw.emerald700,
          icon: BootstrapIcons.file_earmark_excel,
          label: 'Download Template',
          fontWeight: FontWeight.w500,
          // `py-2.5` doesn't override shadcn's `h-9`.
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        const SizedBox(height: 24),
        // The web never shows the chosen file's name.
        _DropZone(onTap: () => vm.run(vm.onFileSelect)),
        const SizedBox(height: 16),
        ClassButton(
          onPressed: () => vm.run(vm.submitImport),
          expand: true,
          label: 'Submit',
          height: 36,
          padding: EdgeInsets.zero,
        ),
      ]),
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle('Bulk Upload Students', 'Easily import new students via spreadsheet upload.'),
      if (!vm.isImportStarted) Center(child: picker),
      if (vm.isImportStarted) _ImportTable(rows: vm.importRows),
    ]);
  }
}

class _DropZone extends StatefulWidget {
  const _DropZone({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_DropZone> createState() => _DropZoneState();
}

class _DropZoneState extends State<_DropZone> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: DashedBox(
          color: _hover ? context.colors.primary.withValues(alpha: 0.5) : (dark ? Tw.slate800 : Tw.slate200),
          fill: dark ? Tw.slate950 : Colors.white,
          radius: 20,
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: double.infinity,
            child: Column(children: [
              const Icon(BootstrapIcons.cloud_arrow_up, size: 30, color: Tw.slate400),
              const SizedBox(height: 8),
              // `dark:text-slate-350` is not a Tailwind colour: slate-700 in both modes.
              const Text('Choose a file to upload',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Tw.slate700)),
              const SizedBox(height: 8),
              const Text('XLS or XLSX format', style: TextStyle(fontSize: 12, color: Tw.slate400)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _ImportTable extends StatelessWidget {
  const _ImportTable({required this.rows});
  final List<Json> rows;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    const italic = TextStyle(color: Tw.slate400, fontStyle: FontStyle.italic);
    return ClassTable(
      minWidth: 0,
      radius: 16,
      cardColor: dark ? Tw.slate900 : Colors.white,
      borderColor: dark ? Tw.slate800 : Tw.slate100,
      cellVPad: 12,
      // `text-xs uppercase tracking-wider` heads, `px-4 py-3` cells.
      columns: const [
        ClassCol('', header: _ImportHead('Email'), left: 16, right: 16),
        ClassCol('', header: _ImportHead('User Status'), left: 16, right: 16),
        ClassCol('', header: _ImportHead('Student Status'), left: 16, right: 16),
      ],
      leading: rows.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(children: [
                Expanded(child: Padding(padding: EdgeInsets.all(8), child: Text('Processing…', style: italic))),
                Expanded(child: Padding(padding: EdgeInsets.all(8), child: Text('Waiting...', style: italic))),
                Expanded(child: Padding(padding: EdgeInsets.all(8), child: Text('Waiting...', style: italic))),
              ]),
            )
          : null,
      rows: [
        for (final r in rows)
          ClassRow([
            Text(vueText(r['email']), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            _StageCell(stage: asMap(r['userStage']), student: false),
            _StageCell(stage: asMap(r['studentStage']), student: true),
          ]),
      ],
    );
  }
}

class _StageCell extends StatelessWidget {
  const _StageCell({required this.stage, required this.student});
  final Json? stage;

  /// The student column greys the badge when the stage is missing; the user
  /// column only for `skipped`.
  final bool student;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final status = stage?['status'];
    final (Color? bg, Color? fg) = switch (status) {
      'processing' => (dark ? ClassTw.yellow950.withValues(alpha: 0.2) : ClassTw.yellow50, dark ? Tw.yellow400 : null),
      'completed' => (dark ? ClassTw.emerald950.withValues(alpha: 0.2) : ClassTw.green50, dark ? Tw.emerald400 : null),
      'failed' => (dark ? ClassTw.rose950.withValues(alpha: 0.2) : ClassTw.red50, dark ? ClassTw.rose400 : null),
      _ when (student ? stage == null : status == 'skipped') =>
        (dark ? Tw.slate800.withValues(alpha: 0.2) : Tw.slate50, dark ? Tw.slate400 : Tw.slate600),
      _ => (null, null),
    };
    final message = stage?['message'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(4)),
        child: Text(jsTruthy(status) ? vueText(status) : 'Waiting...',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
      ),
      if (jsTruthy(message))
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(vueText(message), style: const TextStyle(fontSize: 12, color: Tw.slate400)),
        ),
    ]);
  }
}

Widget _checkbox(BuildContext context, bool value, ValueChanged<bool> onChanged) => SizedBox(
      width: 18,
      height: 18,
      child: Checkbox(
        value: value,
        onChanged: (v) => onChanged(v ?? false),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
        activeColor: context.colors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    );

class _BulkTransfer extends StatelessWidget {
  const _BulkTransfer({required this.vm, required this.students});
  final ClassListVm vm;
  final List<Json> students;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final allChecked = vm.transferStudents.length == students.length && students.isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle('Bulk Transfer Students', 'Select one or more students to transfer to another batch.'),
      ClassTable(
        radius: 16,
        cardColor: dark ? Tw.slate900 : Colors.white,
        borderColor: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate100,
        cellVPad: 12,
        columns: [
          ClassCol('', width: 56, left: 24, header: _HeaderCheckbox(value: allChecked, onTap: vm.toggleTransferSelectAll)),
          const ClassCol('Student Name'),
          const ClassCol('Status'),
          const ClassCol('Email'),
        ],
        empty: const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: Text('No student data available.', style: TextStyle(color: Tw.slate400))),
        ),
        rows: [
          for (final st in students)
            ClassRow([
              _checkbox(context, vm.transferStudents.contains(jsNumber(st['id'])),
                  (v) => vm.toggleTransferStudent(st['id'], v)),
              Text(vueText(st['name']),
                  style: TextStyle(fontWeight: FontWeight.w600, color: dark ? Tw.slate200 : Tw.slate800)),
              StatusPill(active: st['status'] == true, gap: 4),
              Text(vueText(st['email']), style: TextStyle(fontWeight: FontWeight.w500, color: dark ? Tw.slate400 : null)),
            ]),
        ],
      ),
      const SizedBox(height: 32),
      Align(
        alignment: Alignment.centerRight,
        child: ClassButton(
          onPressed: vm.openTransferDialog,
          disabled: vm.transferStudents.isEmpty,
          icon: BootstrapIcons.arrow_left_right,
          label: 'Transfer Selected Students',
          fontWeight: FontWeight.w500,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    ]);
  }
}

class _BulkPromote extends StatelessWidget {
  const _BulkPromote({required this.vm, required this.students});
  final ClassListVm vm;
  final List<Json> students;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final manage = vm.canManageClass;
    final allChecked = vm.promoteStudents.length == students.length && students.isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const _SectionTitle(
          'Bulk Promote Students', 'Select one or more students to promote to another class and batch.'),
      ClassTable(
        loading: vm.isListLoading,
        showEmptyWhileLoading: true,
        radius: 16,
        cardColor: dark ? Tw.slate900 : Colors.white,
        borderColor: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate100,
        cellVPad: 12,
        columns: [
          ClassCol('', width: 56, left: 24, header: _HeaderCheckbox(value: allChecked, onTap: vm.toggleSelectAll)),
          const ClassCol('Student Name'),
          const ClassCol('Status'),
          if (manage) const ClassCol('Email'),
        ],
        empty: const Padding(
          padding: EdgeInsets.symmetric(vertical: 32),
          child: Center(child: Text('No student data available.')),
        ),
        rows: [
          for (final st in students)
            ClassRow([
              _checkbox(context, vm.promoteStudents.contains(st['id']), (v) => vm.togglePromoteStudent(st['id'], v)),
              Text(vueText(st['name']),
                  style: TextStyle(fontWeight: FontWeight.w600, color: dark ? Tw.slate200 : Tw.slate800)),
              StatusPill(active: isStudentActive(st['status']), gap: 4, rose450: true),
              if (manage)
                Text(vueText(st['email']),
                    style: TextStyle(fontWeight: FontWeight.w500, color: dark ? Tw.slate400 : null)),
            ]),
        ],
      ),
      const SizedBox(height: 32),
      Align(
        alignment: Alignment.centerRight,
        child: ClassButton(
          onPressed: () => vm.run(vm.openPromoteDialog),
          disabled: vm.promoteStudents.isEmpty,
          icon: BootstrapIcons.arrow_up_circle_fill,
          label: 'Promote Selected Students',
          fontWeight: FontWeight.w500,
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
      ),
    ]);
  }
}

class _ImportHead extends StatelessWidget {
  const _ImportHead(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => Text(label.toUpperCase(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.6, color: context.colors.onPrimary));
}

/// The select-all checkbox in the first header cell.
class _HeaderCheckbox extends StatelessWidget {
  const _HeaderCheckbox({required this.value, required this.onTap});
  final bool value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 18,
          height: 18,
          child: Checkbox(
            value: value,
            onChanged: (_) => onTap(),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            side: const BorderSide(color: Colors.white, width: 1.5),
            activeColor: Colors.white,
            checkColor: context.colors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      );
}
