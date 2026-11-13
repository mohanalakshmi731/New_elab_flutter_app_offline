import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/external_link.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../class_course/class_course_create_page.dart';
import 'class_list_logic.dart';
import 'class_list_vm.dart';
import 'class_list_widgets.dart';
import 'class_ui_kit.dart';

/// `bg-slate-50 dark:bg-[#161e36]/40 p-4 rounded-xl border … mb-6` toolbars.
class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.children, this.rowFrom = 768, this.gap = 16});
  final List<Widget> children;

  /// Width from which the toolbar is a row (`md:flex-row` / `sm:flex-row`).
  final double rowFrom;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final row = context.screenWidth >= rowFrom;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? ClassTw.navy.withValues(alpha: 0.4) : Tw.slate50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate100),
      ),
      child: row
          ? Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(width: gap), children[i]],
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              for (var i = 0; i < children.length; i++) ...[if (i > 0) SizedBox(height: gap), children[i]],
            ]),
    );
  }
}

/// Search inputs inside the detail toolbars (`dark:bg-[#0d0d2b]/60 border-white/10`).
Widget _toolbarSearch(BuildContext context, TextEditingController c, String hint, VoidCallback onSubmit) {
  final dark = context.isDark;
  return IconSearchInput(
    controller: c,
    hint: hint,
    onSubmitted: onSubmit,
    vPad: 9.5,
    darkIconColor: Tw.slate400,
    fillColor: dark ? ClassTw.night.withValues(alpha: 0.6) : Colors.white,
    borderColor: dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate200,
  );
}

/// Toolbar `<Select>` triggers: `bg-white dark:bg-[#0d0d2b]/60
/// border-slate-200 dark:border-white/10 rounded-xl` (no text colour), with
/// shadcn's default content.
MenuSelect<T> _toolbarSelect<T>(
  BuildContext context, {
  required T? value,
  required List<MenuSelectItem<T>> items,
  required ValueChanged<T> onSelected,
  required String placeholder,
  Widget? leading,
}) {
  final dark = context.isDark;
  return MenuSelect<T>(
    value: value,
    items: items,
    onSelected: onSelected,
    bg: dark ? ClassTw.night.withValues(alpha: 0.6) : Colors.white,
    borderColor: dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate200,
    textColor: dark ? AppColors.darkForeground : AppColors.foreground,
    trigger: SelectValueText(
      label: items.where((i) => i.value == value).firstOrNull?.label,
      placeholder: placeholder,
      leading: leading,
    ),
  );
}

String _fullName(Object? user, {String dash = '-'}) {
  final u = asMap(user);
  return '${vueText(orJs(u?['first_name'], dash))} ${vueText(orJs(u?['last_name'], dash))}';
}

/// Envelope link to Gmail.
RoundAction _mailAction(Object? email, {bool fill = false}) => RoundAction(
      icon: fill ? BootstrapIcons.envelope_fill : BootstrapIcons.envelope,
      tone: RoundTone.orange,
      tooltip: 'Compose email via Gmail',
      onTap: () => openExternal(gmailComposeUrl(email)),
    );

Widget _actions(List<Widget> children) => Row(mainAxisSize: MainAxisSize.min, children: [
      for (var i = 0; i < children.length; i++) ...[if (i > 0) const SizedBox(width: 8), children[i]],
    ]);

// ── ADMIN TAB ─────────────────────────────────────────────────────────────────

class AdminsTab extends StatelessWidget {
  const AdminsTab({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final admins = vm.s.assignedInstructors;
    final instructors = [for (final i in vm.s.instructors) ?asMap(i)];

    Widget? attachRow;
    if (vm.showAdminsTab) {
      final items = instructors.isNotEmpty
          ? [
              for (final i in instructors)
                MenuSelectItem<Object?>(i['id'],
                    '${vueText(dig(i, ['user', 'first_name']))} ${vueText(dig(i, ['user', 'last_name']))}'),
            ]
          : const [MenuSelectItem<Object?>('none', 'No instructors available', enabled: false)];
      // `h-11` loses to shadcn's `data-[size=default]:h-9`.
      final select = MenuSelect<Object?>(
        value: vm.selectedInstructorId,
        items: items,
        fontWeight: FontWeight.w600,
        textColor: dark ? Tw.slate300 : Tw.slate700,
        borderColor: dark ? Tw.slate800 : Tw.slate200,
        shadow: shadowSm,
        menuBg: dark ? ClassTw.night : null,
        menuBorder: dark ? Colors.white.withValues(alpha: 0.1) : null,
        menuRadius: 20,
        itemRadius: 16,
        onSelected: (v) {
          vm.selectedInstructorId = v;
          vm.touch();
        },
        trigger: SelectValueText(
          label: items.where((i) => i.value == vm.selectedInstructorId).firstOrNull?.label,
          placeholder: 'Select Instructor to attach',
        ),
      );
      final button = ClassButton(
        onPressed: () => vm.run(vm.attachInstructor),
        disabled: vm.isCreateBtnLoading,
        busy: vm.isCreateBtnLoading,
        color: Tw.indigo600,
        hoverColor: Tw.indigo700,
        height: 44,
        fontWeight: FontWeight.w700,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        icon: BootstrapIcons.person_plus,
        iconSize: 18,
        gap: 6,
        label: 'Attach Admin',
        expand: !context.isSm,
      );
      attachRow = Container(
        margin: const EdgeInsets.only(bottom: 24),
        padding: const EdgeInsets.all(20),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            // `via-slate-50` has no dark variant, so the dark gradient keeps
            // the light middle stop (as rendered by the web).
            colors: dark
                ? [Tw.slate900.withValues(alpha: 0.5), Tw.slate50, Tw.indigo950.withValues(alpha: 0.1)]
                : [Tw.slate50.withValues(alpha: 0.5), Tw.slate50, Tw.indigo50.withValues(alpha: 0.15)],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate200.withValues(alpha: 0.6)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
        ),
        child: Stack(children: [
          if (context.isMd)
            const Positioned(
              right: 32,
              top: 0,
              bottom: 0,
              child: Center(
                child: Opacity(opacity: 0.15, child: Icon(BootstrapIcons.send, size: 56, color: Tw.indigo500)),
              ),
            ),
          context.isSm
              ? Row(children: [SizedBox(width: 288, child: select), const SizedBox(width: 16), button])
              : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  select,
                  const SizedBox(height: 16),
                  button,
                ]),
        ]),
      );
    }

    final table = ClassTable(
      loading: vm.isListLoading,
      skeletonRows: 5,
      skeletonHeight: 20,
      columns: const [
        ClassCol('Name', flex: 1.4),
        ClassCol('Email', flex: 1.8),
        ClassCol('Status'),
        ClassCol('Actions', alignEnd: true, flex: 1.2, right: 24),
      ],
      empty: TableEmptyIllustration(
        icon: BootstrapIcons.archive,
        iconColor: dark ? Tw.indigo600 : Tw.indigo400,
        circleColor: dark ? Tw.indigo950.withValues(alpha: 0.2) : Tw.indigo50.withValues(alpha: 0.5),
        title: 'No admins attached.',
        subtitle: 'Please attach an instructor to manage admins.',
      ),
      rows: [
        for (final inst in admins)
          ClassRow([
            Text(_fullName(inst['user']),
                style: TextStyle(fontWeight: FontWeight.w500, color: dark ? Colors.white : Tw.slate900)),
            Text(vueText(orJs(dig(inst, ['user', 'email']), '-')),
                style: TextStyle(color: dark ? Tw.slate400 : Tw.slate600)),
            StatusPill(active: dig(inst, ['user', 'status']) == true),
            _actions([
              if (jsTruthy(dig(inst, ['user', 'email']))) _mailAction(dig(inst, ['user', 'email'])),
              RoundAction(
                icon: BootstrapIcons.telephone,
                tone: RoundTone.blue,
                tooltip: 'Call',
                onTap: () => vm.openPhoneDialog(
                    '${jsMember(inst['user'], 'country_code')}${jsMember(inst['user'], 'phone')}'),
              ),
              RoundAction(
                icon: BootstrapIcons.trash,
                tone: RoundTone.rose,
                tooltip: 'Delete Admin',
                onTap: () => vm.openAdminDelete(
                  inst['id'],
                  '${vueText(orJs(dig(inst, ['user', 'first_name']), ''))} ${vueText(orJs(dig(inst, ['user', 'last_name']), ''))}',
                  vueText(orJs(dig(inst, ['user', 'email']), '')),
                ),
              ),
            ]),
          ]),
      ],
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [?attachRow, table]);
  }
}

// ── BATCHES TAB ───────────────────────────────────────────────────────────────

class BatchesTab extends StatelessWidget {
  const BatchesTab({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final batches = vm.s.batches;
    final rows = filterBatchesByStatus(batches, vm.statusbatch);

    // `<Input class="bg-white dark:bg-[#0d0d2b]/60 border-slate-200 dark:border-white/10 rounded-xl">` (h-9).
    final batchName = IconSearchInput(
      controller: vm.newBatchName,
      hint: 'Batch Name',
      icon: null,
      vPad: 8.5,
      onSubmitted: () {},
      fillColor: dark ? ClassTw.night.withValues(alpha: 0.6) : Colors.white,
      borderColor: dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate200,
    );
    final create = vm.canManageClass
        ? Row(mainAxisSize: context.isMd ? MainAxisSize.min : MainAxisSize.max, children: [
            if (context.isMd) SizedBox(width: 240, child: batchName) else Expanded(child: batchName),
            const SizedBox(width: 12),
            ClassButton(
              onPressed: () => vm.run(() => vm.createBatchHandler(vm.newBatchName.text)),
              disabled: vm.isCreateBtnLoading,
              busy: vm.isCreateBtnLoading,
              label: 'Create Batch',
              fontWeight: FontWeight.w500,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ])
        : null;

    final search = _toolbarSearch(context, vm.searchQueryBatch, 'Search Batch...', vm.searchBatchByName);
    final filter = vm.canManageClass
        ? _toolbarSelect<String>(
            context,
            value: vm.statusbatch,
            // `bi-funnel text-slate-400 mr-2` + the trigger's `gap-2`.
            leading: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(BootstrapIcons.funnel, size: 16, color: Tw.slate400),
            ),
            placeholder: 'Filter by status',
            items: const [
              MenuSelectItem('all', 'All Batches'),
              MenuSelectItem('published', 'Active'),
              MenuSelectItem('draft', 'Inactive'),
            ],
            onSelected: (v) {
              vm.statusbatch = v;
              vm.touch();
            },
          )
        : null;
    final right = context.isSm
        ? Row(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: 240, child: search),
            if (filter != null) ...[const SizedBox(width: 12), SizedBox(width: 176, child: filter)],
          ])
        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            search,
            if (filter != null) ...[const SizedBox(height: 12), filter],
          ]);

    Widget? leading;
    if (batches.isEmpty) {
      leading = TableEmptyIllustration(
        icon: BootstrapIcons.briefcase,
        iconColor: dark ? Tw.orange400 : Tw.orange500,
        circleColor: dark ? ClassTw.orange950.withValues(alpha: 0.2) : ClassTw.orange50.withValues(alpha: 0.5),
        title: 'No batches created.',
        subtitle: 'Please create a batch for this class.',
      );
    } else if (noBatchMatches(batches, vm.statusbatch, vm.canManageClass)) {
      leading = const Padding(
        padding: EdgeInsets.symmetric(vertical: 32, horizontal: 8),
        child: Column(children: [
          Icon(BootstrapIcons.clipboard2_x, size: 18, color: Tw.slate300),
          SizedBox(height: 4),
          Text('No batches match the selected filter.', style: TextStyle(fontSize: 12, color: Tw.slate400)),
        ]),
      );
    }

    final table = ClassTable(
      columns: const [
        ClassCol('Batch Name', flex: 1.4),
        ClassCol('Created At'),
        ClassCol('Status'),
        ClassCol('Actions', alignEnd: true, right: 24),
      ],
      leading: leading,
      rows: [
        for (final batch in rows)
          ClassRow([
            _LinkText(text: vueText(batch['name']), onTap: () => vm.run(() => vm.openStudentModal(batch))),
            Text(jsLocaleDateString(batch['created_at']), style: TextStyle(color: dark ? Tw.slate400 : null)),
            StatusPill(active: '${batch['status'] ?? ''}'.toLowerCase() == 'published'),
            // The Actions cell only exists for managers (the header always does).
            if (vm.canManageClass)
              _actions([
                RoundAction(
                  icon: BootstrapIcons.envelope,
                  tone: RoundTone.orange,
                  tooltip: 'Email batch students',
                  onTap: () => vm.run(() => vm.emailBatchStudents(batch)),
                ),
                RoundAction(
                  icon: BootstrapIcons.pencil_square,
                  tone: RoundTone.emerald,
                  tooltip: 'Edit Batch',
                  onTap: () => vm.run(() => vm.openBatchById(batch['id'])),
                ),
                RoundAction(
                  icon: BootstrapIcons.trash,
                  tone: RoundTone.rose,
                  tooltip: 'Delete Batch',
                  onTap: () => vm.openBatchDeleteDialog(batch['id']),
                ),
              ])
            else
              const SizedBox.shrink(),
          ]),
      ],
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _Toolbar(children: [?create, right]),
      table,
    ]);
  }
}

class _LinkText extends StatefulWidget {
  const _LinkText({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  State<_LinkText> createState() => _LinkTextState();
}

class _LinkTextState extends State<_LinkText> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Text(widget.text,
              style: TextStyle(
                color: context.colors.primary,
                fontWeight: FontWeight.w600,
                decoration: _hover ? TextDecoration.underline : null,
                decorationColor: context.colors.primary,
              )),
        ),
      );
}

// ── INSTRUCTORS TAB ───────────────────────────────────────────────────────────

class InstructorsTab extends StatelessWidget {
  const InstructorsTab({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final manage = vm.canManageClass;
    final list = vm.s.classInstructors;

    final create = manage
        ? Align(
            alignment: context.isMd ? Alignment.centerLeft : Alignment.center,
            child: ClassButton(
              onPressed: vm.createInstructor,
              icon: BootstrapIcons.plus_lg,
              iconSize: 12,
              // Button `gap-2` + the icon's `mr-1`.
              gap: 12,
              label: 'Create Instructor',
              fontWeight: FontWeight.w500,
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          )
        : null;
    final search = _toolbarSearch(context, vm.searchQueryInstructor, 'Search Instructor...', vm.searchInstructorsByName);

    final table = ClassTable(
      loading: vm.isListLoading,
      skeletonRows: 4,
      skeletonHeight: 20,
      minWidth: 820,
      columns: [
        const ClassCol('ID', width: 80),
        const ClassCol('Name', flex: 1.4),
        if (manage) const ClassCol('Email', flex: 1.6),
        if (manage) const ClassCol('Phone', flex: 1.2),
        const ClassCol('Status'),
        if (manage) const ClassCol('Actions', alignEnd: true, flex: 1.4, right: 24),
      ],
      empty: TableEmptyIllustration(
        icon: BootstrapIcons.people,
        iconColor: dark ? Tw.emerald400 : Tw.emerald500,
        circleColor: dark ? ClassTw.emerald950.withValues(alpha: 0.2) : Tw.emerald50.withValues(alpha: 0.5),
        title: 'No instructors assigned.',
        subtitle: 'Please add an instructor to this class.',
      ),
      rows: [
        for (final ins in list)
          ClassRow([
            Text('#${vueText(ins['id'])}',
                style: const TextStyle(color: Tw.slate500, fontWeight: FontWeight.w500, fontFamily: 'monospace')),
            Text(_fullName(ins['user']),
                style: TextStyle(fontWeight: FontWeight.w600, color: dark ? Colors.white : Tw.slate900)),
            if (manage) Text(vueText(orJs(dig(ins, ['user', 'email']), '-'))),
            if (manage)
              Text('${vueText(orJs(dig(ins, ['user', 'country_code']), ''))} ${vueText(orJs(dig(ins, ['user', 'phone']), ''))}'),
            StatusPill(active: jsTruthy(ins['status'])),
            if (manage)
              _actions([
                _mailAction(dig(ins, ['user', 'email'])),
                RoundAction(
                  icon: BootstrapIcons.telephone,
                  tone: RoundTone.blue,
                  tooltip: 'Call',
                  onTap: () =>
                      vm.openPhoneDialog('${jsMember(ins['user'], 'country_code')}${jsMember(ins['user'], 'phone')}'),
                ),
                RoundAction(
                  icon: BootstrapIcons.pencil_square,
                  tone: RoundTone.emerald,
                  tooltip: 'Edit Instructor',
                  onTap: () => vm.run(() => vm.openUpdateInstructor(ins['id'])),
                ),
                RoundAction(
                  icon: BootstrapIcons.trash,
                  tone: RoundTone.rose,
                  tooltip: 'Detach Instructor',
                  onTap: () => vm.openDetachInstructorDialog(
                    vueText(ins['id']),
                    '${jsMember(ins['user'], 'first_name')} ${jsMember(ins['user'], 'last_name')}',
                  ),
                ),
              ]),
          ]),
      ],
    );

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _Toolbar(children: [
        ?create,
        if (context.isMd)
          SizedBox(width: 240, child: search)
        else if (context.isSm)
          Center(child: SizedBox(width: 240, child: search))
        else
          search,
      ]),
      table,
      if (list.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Align(
            alignment: Alignment.centerRight,
            child: ClassPagination(
              meta: vm.s.classInstructorPagination,
              plainItems: true,
              onPage: (p) => vm.run(() => vm.changeInstructorPage(p)),
              // The web's Next reads `instructorPagination` (never loaded here).
              onNext: () => vm.run(() => vm.changeInstructorPage(vm.s.instructorPagination.currentPage + 1)),
            ),
          ),
        ),
    ]);
  }
}

// ── COURSES TAB ───────────────────────────────────────────────────────────────

class CoursesTab extends StatelessWidget {
  const CoursesTab({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final published = [
      for (final c in vm.store.courses)
        if (asMap(c) case final Map<String, dynamic> m when m['status'] == 'published') m,
    ];
    final select = _toolbarSelect<Object?>(
      context,
      value: vm.selectedCourseId,
      placeholder: 'Select course to attach',
      items: [for (final c in published) MenuSelectItem<Object?>(c['id'], vueText(c['title']))],
      onSelected: (v) {
        vm.selectedCourseId = v;
        vm.touch();
      },
    );
    final button = ClassButton(
      onPressed: () => vm.run(vm.attachCourses),
      label: 'Attach Course',
      fontWeight: FontWeight.w500,
      expand: !context.isSm,
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 20),
    );
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (vm.canManageClass && !vm.isCourseExpanded)
        _Toolbar(
          rowFrom: 640,
          gap: 12,
          children: context.isSm
              ? [
                  Row(children: [SizedBox(width: 288, child: select), const SizedBox(width: 12), button]),
                ]
              : [select, button],
        ),
      Padding(
        padding: EdgeInsets.only(top: vm.isCourseExpanded ? 0 : 8),
        child: vm.hasClass
            ? ClassCourseCreatePage(
                embedded: true,
                classId: vm.classId,
                refresh: vm.courseRefreshKey,
                canEdit: vm.canManageClass,
                onCourseExpanded: vm.handleCourseExpanded,
              )
            : const SizedBox.shrink(),
      ),
    ]);
  }
}
