import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../courses/course_list_view.dart';
import 'class_list_logic.dart';
import 'class_list_vm.dart';
import 'class_list_widgets.dart';
import 'class_ui_kit.dart';

/// LEFT PART of `classlist.vue`: the LMS switcher (Classes / Courses &
/// Curriculums), the classes grid and the embedded course list.
class ClassGridSection extends StatelessWidget {
  const ClassGridSection({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!vm.isCourseExpanded && vm.isAdminOrInstitute)
            Padding(
              // `mb-8` + `<Tabs>`'s `gap-2`.
              padding: const EdgeInsets.only(bottom: 40),
              child: context.isLg ? _LmsTabs(vm: vm) : _LmsSelect(vm: vm),
            ),
          if (vm.currentLmsTab == 'classes')
            _ClassesTab(vm: vm)
          else if (vm.currentLmsTab == 'courses')
            CourseListView(key: ValueKey(vm.courseListKey), onCourseExpanded: vm.handleCourseExpanded),
        ],
      ),
    );
  }
}

/// `lg:hidden w-full sm:w-64` select.
class _LmsSelect extends StatelessWidget {
  const _LmsSelect({required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final classes = vm.currentLmsTab == 'classes';
    final dark = context.isDark;
    final select = MenuSelect<String>(
      value: vm.currentLmsTab,
      // `h-11` loses to shadcn's `data-[size=default]:h-9`.
      radius: 16,
      hPad: 16,
      fontWeight: FontWeight.w500,
      shadow: shadowSm,
      itemRadius: 20,
      itemMargin: true,
      menuRadius: 16,
      menuBorder: dark ? Tw.slate700 : Tw.slate200,
      menuShadow: true,
      groupLabel: 'LMS Sections',
      onSelected: vm.setLmsTab,
      items: const [
        MenuSelectItem('classes', 'Classes', icon: BootstrapIcons.person_workspace),
        MenuSelectItem('courses', 'Courses & Curriculums', icon: BootstrapIcons.mortarboard),
      ],
      trigger: Row(children: [
        Icon(classes ? BootstrapIcons.person_workspace : BootstrapIcons.mortarboard,
            size: 16, color: context.colors.primary),
        const SizedBox(width: 10),
        Flexible(child: Text(classes ? 'Classes' : 'Courses & Curriculums', overflow: TextOverflow.ellipsis)),
      ]),
    );
    return Align(
      alignment: Alignment.centerLeft,
      child: SizedBox(width: context.isSm ? 256 : double.infinity, child: select),
    );
  }
}

/// `hidden lg:flex` underline tabs.
class _LmsTabs extends StatelessWidget {
  const _LmsTabs({required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: dark ? Tw.slate700 : Tw.slate200))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        _UnderlineTab(
          label: 'Classes',
          icon: BootstrapIcons.person_workspace,
          active: vm.currentLmsTab == 'classes',
          onTap: () => vm.setLmsTab('classes'),
        ),
        _UnderlineTab(
          label: 'Courses & Curriculums',
          icon: BootstrapIcons.mortarboard,
          active: vm.currentLmsTab == 'courses',
          onTap: () => vm.setLmsTab('courses'),
        ),
      ]),
    );
  }
}

class _UnderlineTab extends StatefulWidget {
  const _UnderlineTab({required this.label, required this.icon, required this.active, required this.onTap});
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  State<_UnderlineTab> createState() => _UnderlineTabState();
}

class _UnderlineTabState extends State<_UnderlineTab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final fg = widget.active
        ? primary
        : (_hover ? (dark ? Tw.slate200 : Tw.slate700) : (dark ? Tw.slate400 : Tw.slate500));
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: widget.active ? primary : Colors.transparent, width: 2)),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: widget.active ? primary.withValues(alpha: 0.1) : (dark ? Tw.slate800 : Tw.slate100),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(widget.icon, size: 14, color: widget.active ? primary : Tw.slate400),
            ),
            const SizedBox(width: 10),
            Text(widget.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: fg)),
          ]),
        ),
      ),
    );
  }
}

/// `<TabsContent value="classes">`
class _ClassesTab extends StatelessWidget {
  const _ClassesTab({required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final institutes = vm.s.institutes;
    final filtered = filterClassesByStatus(institutes, vm.status);

    final header = Row(children: [
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Classes',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.75,
                color: dark ? Colors.white : Tw.slate800,
              )),
          const SizedBox(height: 4),
          Text('Manage all your classes, instructors, and courses.',
              style: TextStyle(fontSize: 14, color: dark ? Tw.slate400 : null)),
        ]),
      ),
      if (vm.isAdminOrInstitute)
        ClassButton(
          label: 'Create Class',
          icon: BootstrapIcons.plus_lg,
          color: Tw.indigo600,
          hoverColor: Tw.indigo700,
          // shadcn `h-9` keeps the height; `px-6`.
          height: 36,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          onPressed: vm.createInstitute,
        ),
    ]);

    final search = IconSearchInput(
      controller: vm.searchQueryClass,
      hint: 'Search class...',
      onSubmitted: () => vm.run(vm.searchClassByName),
    );
    const statusItems = [
      MenuSelectItem('all', 'All classes'),
      MenuSelectItem('published', 'Active'),
      MenuSelectItem('draft', 'Inactive'),
      MenuSelectItem('archived', 'Archived'),
    ];
    final statusSelect = MenuSelect<String>(
      value: vm.status,
      textColor: dark ? Tw.slate300 : Tw.slate700,
      shadow: shadowSm,
      menuBg: dark ? ClassTw.night : null,
      menuBorder: dark ? Colors.white.withValues(alpha: 0.1) : null,
      items: statusItems,
      onSelected: (v) {
        vm.status = v;
        vm.touch();
      },
      trigger: SelectValueText(
        label: statusItems.where((i) => i.value == vm.status).firstOrNull?.label,
        placeholder: 'All classes',
      ),
    );
    final controls = context.isSm
        ? Row(children: [
            SizedBox(width: 288, child: search),
            const SizedBox(width: 12),
            SizedBox(width: 176, child: statusSelect),
          ])
        : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            search,
            const SizedBox(height: 12),
            statusSelect,
          ]);

    final columns = context.isXl ? 4 : (context.isLg ? 3 : (context.isMd ? 2 : 1));
    final cards = <Widget>[
      for (var i = 0; i < filtered.length; i++) _ClassCard(vm: vm, institute: filtered[i], index: i),
      if (vm.isAdminOrInstitute) _CreatePlaceholder(onTap: vm.createInstitute),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(padding: const EdgeInsets.only(bottom: 8), child: header),
      const SizedBox(height: 24),
      controls,
      const SizedBox(height: 32),
      EqualGrid(columns: columns, gap: 20, children: cards),
      if (institutes.isEmpty) ...[
        const SizedBox(height: 32),
        const _NoClasses(),
      ],
    ]);
  }
}

const _iconGradients = [
  [Tw.purple500, Tw.indigo600],
  [Tw.emerald400, ClassTw.teal600],
  [Tw.pink500, Tw.rose600],
  [Tw.amber400, Tw.orange600],
];

/// One class card of the grid.
class _ClassCard extends StatefulWidget {
  const _ClassCard({required this.vm, required this.institute, required this.index});
  final ClassListVm vm;
  final Json institute;
  final int index;

  @override
  State<_ClassCard> createState() => _ClassCardState();
}

class _ClassCardState extends State<_ClassCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final inst = widget.institute;
    final dark = context.isDark;
    final selected = vm.classId != null && vm.classId == asInt(inst['id']);
    final indigo = dark ? Tw.indigo400 : Tw.indigo500;

    final borderColor = selected
        ? indigo
        : (_hover ? Tw.indigo400.withValues(alpha: 0.8) : (dark ? Tw.slate800 : Tw.slate200));
    final bg = selected
        ? (dark ? Tw.slate900.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.75))
        : (_hover
            ? (dark ? Tw.slate900.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.6))
            : (dark ? Tw.slate900.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.5)));
    final glow = dark ? const Color(0xFF818CF8) : const Color(0xFF6366F1);
    final shadows = selected
        ? [
            BoxShadow(color: glow.withValues(alpha: dark ? 0.5 : 0.4), spreadRadius: 3),
            BoxShadow(color: glow.withValues(alpha: dark ? 0.25 : 0.35), blurRadius: 45, spreadRadius: -12, offset: const Offset(0, 20)),
          ]
        : [
            BoxShadow(color: glow.withValues(alpha: _hover ? (dark ? 0.3 : 0.2) : (dark ? 0.15 : 0.08)), spreadRadius: _hover ? 2 : 1),
            BoxShadow(
              color: dark ? Colors.black.withValues(alpha: _hover ? 0.5 : 0.3) : glow.withValues(alpha: _hover ? 0.18 : 0.08),
              blurRadius: _hover ? 40 : 30,
              spreadRadius: _hover ? -12 : -10,
              offset: Offset(0, _hover ? 20 : 10),
            ),
          ];

    final banner = SizedBox(
      height: 112,
      child: Stack(fit: StackFit.expand, children: [
        // `group-hover:scale-105` (500ms).
        AnimatedScale(
          scale: _hover ? 1.05 : 1,
          duration: const Duration(milliseconds: 500),
          child: Image.asset('assets/images/class_thumbnail.jpg', fit: BoxFit.cover),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Tw.slate900.withValues(alpha: 0.3), Colors.transparent, Colors.transparent],
            ),
          ),
        ),
        Positioned(left: 16, top: 16, child: _StatusBadge(vm: vm, institute: inst)),
        if (vm.isAdminOrInstitute)
          Positioned(
            right: 16,
            top: 16,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              _CardAction(
                icon: BootstrapIcons.pencil,
                tooltip: 'Edit Class',
                fg: dark ? Tw.indigo400 : Tw.indigo600,
                hoverBg: dark ? Tw.indigo500 : Tw.indigo600,
                onTap: () => vm.run(() => vm.openUpdateClassDialog('${inst['id']}')),
              ),
              const SizedBox(width: 6),
              _CardAction(
                icon: BootstrapIcons.trash,
                tooltip: 'Delete Class',
                // `dark:text-rose-450` is not a Tailwind colour: rose-600 in both modes.
                fg: Tw.rose600,
                hoverBg: dark ? Tw.rose500 : Tw.rose600,
                onTap: () => vm.run(vm.openDeleteClassDialog),
              ),
            ]),
          ),
      ]),
    );

    Widget stat(Object? value, String label) => Column(children: [
          Text(vueText(value),
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1, color: dark ? Tw.slate200 : Tw.slate800)),
          const SizedBox(height: 2),
          Text(label.toUpperCase(),
              style: TextStyle(
                  fontSize: 10, fontWeight: FontWeight.w500, letterSpacing: 0.5, color: dark ? Tw.slate500 : Tw.slate400)),
        ]);

    final body = Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(vueText(inst['year']),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: _hover ? (dark ? Tw.indigo400 : Tw.indigo600) : (dark ? Tw.slate100 : null),
            )),
        const SizedBox(height: 4),
        Text('Grade ${widget.index + 5}',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: dark ? Tw.slate400 : Tw.slate500)),
        const Spacer(),
        Container(
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.only(top: 16),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate100)),
          ),
          child: Row(children: [
            Expanded(child: stat(inst['students'], 'Students')),
            const SizedBox(width: 6),
            Expanded(child: stat(inst['admins'], 'Admins')),
            const SizedBox(width: 6),
            Expanded(child: stat(inst['courses'], 'Courses')),
            const SizedBox(width: 6),
            Expanded(child: stat(inst['instructors'], 'Teachers')),
          ]),
        ),
      ]),
    );

    final grad = _iconGradients[widget.index % 4];
    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: borderColor),
        boxShadow: shadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(31),
        child: Stack(children: [
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [banner, Expanded(child: body)]),
          Positioned(
            left: 16,
            top: 84,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: grad),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(width: 4, color: dark ? Tw.slate900.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.8)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 4))],
              ),
              child: const Icon(BootstrapIcons.mortarboard_fill, size: 18, color: Colors.white),
            ),
          ),
        ]),
      ),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: () => vm.run(() => vm.openDrawer({'id': inst['id'], 'year': inst['year'], 'c_id': inst['c_id']})),
        child: Opacity(
          opacity: inst['status'] == 'draft' ? 0.85 : 1,
          // `hover:-translate-y-1 hover:scale-[1.01]`.
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            transformAlignment: Alignment.center,
            transform: _hover
                ? (Matrix4.translationValues(0, -4, 0)..multiply(Matrix4.diagonal3Values(1.01, 1.01, 1)))
                : Matrix4.identity(),
            constraints: const BoxConstraints(minHeight: 236),
            child: card,
          ),
        ),
      ),
    );
  }
}

/// The Active / Inactive badge (a button for admins / institutes).
class _StatusBadge extends StatefulWidget {
  const _StatusBadge({required this.vm, required this.institute});
  final ClassListVm vm;
  final Json institute;

  @override
  State<_StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<_StatusBadge> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final vm = widget.vm;
    final published = widget.institute['status'] == 'published';
    final button = vm.isAdminOrInstitute;
    // `bg-slate-505/90` is not a Tailwind colour: the inactive badge has no
    // background in the web (only the button's `hover:bg-slate-600`).
    final Color? bg = published
        ? (button && _hover ? Tw.emerald600 : Tw.emerald500)
        : (button && _hover ? Tw.slate600 : null);
    final badge = AnimatedScale(
      scale: button && _hover ? 1.05 : 1,
      duration: const Duration(milliseconds: 150),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          boxShadow: bg != null
              ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))]
              : null,
        ),
        child: Text(published ? 'ACTIVE' : 'INACTIVE',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: Colors.white)),
      ),
    );
    if (!button) return badge;
    return Tooltip(
      message: 'Click to toggle Class status',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(onTap: () => vm.run(() => vm.toggleClassStatus(widget.institute)), child: badge),
      ),
    );
  }
}

class _CardAction extends StatefulWidget {
  const _CardAction({required this.icon, required this.tooltip, required this.fg, required this.hoverBg, required this.onTap});
  final IconData icon;
  final String tooltip;
  final Color? fg;
  final Color hoverBg;
  final VoidCallback onTap;

  @override
  State<_CardAction> createState() => _CardActionState();
}

class _CardActionState extends State<_CardAction> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            // `hover:scale-105`.
            transformAlignment: Alignment.center,
            transform: Matrix4.diagonal3Values(_hover ? 1.05 : 1, _hover ? 1.05 : 1, 1),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _hover ? widget.hoverBg : (dark ? Tw.slate900 : Colors.white).withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate200.withValues(alpha: 0.6)),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
            ),
            child: Icon(widget.icon, size: 12, color: _hover ? Colors.white : widget.fg),
          ),
        ),
      ),
    );
  }
}

/// The dotted "Create class" tile inside the grid.
class _CreatePlaceholder extends StatefulWidget {
  const _CreatePlaceholder({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_CreatePlaceholder> createState() => _CreatePlaceholderState();
}

class _CreatePlaceholderState extends State<_CreatePlaceholder> {
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
        child: AnimatedScale(
          // `hover:scale-[1.01]`.
          scale: _hover ? 1.01 : 1,
          duration: const Duration(milliseconds: 300),
            child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 220),
            child: DashedBox(
              color: _hover
                  ? (dark ? Tw.indigo500.withValues(alpha: 0.5) : Tw.indigo400)
                  : (dark ? Tw.slate800 : Tw.slate200),
              fill: _hover
                  ? (dark ? Tw.slate900.withValues(alpha: 0.1) : Tw.indigo50.withValues(alpha: 0.2))
                  : (dark ? Tw.slate900.withValues(alpha: 0.1) : Tw.slate50.withValues(alpha: 0.2)),
              radius: 24,
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Tw.indigo500.withValues(alpha: _hover ? 0.2 : 0.1),
                    ),
                    child: const Icon(BootstrapIcons.plus_lg, size: 20, color: Tw.indigo600),
                  ),
                  const SizedBox(height: 12),
                  Text('Create class',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _hover ? Tw.indigo600 : (dark ? Tw.slate500 : Tw.slate400),
                      )),
                  const SizedBox(height: 4),
                  Text('Click to add a new class',
                      style: TextStyle(fontSize: 12, color: dark ? Tw.slate600 : Tw.slate300)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NoClasses extends StatelessWidget {
  const _NoClasses();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64),
      child: Column(children: [
        Container(
          width: 80,
          height: 80,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(shape: BoxShape.circle, color: dark ? Tw.slate800 : Tw.slate100),
          child: Icon(BootstrapIcons.clipboard2_x, size: 36, color: dark ? Tw.slate600 : Tw.slate300),
        ),
        const SizedBox(height: 12),
        Text('No classes created yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: dark ? Tw.slate400 : Tw.slate500)),
        const SizedBox(height: 12),
        Text('Get started by creating your first class.',
            style: TextStyle(fontSize: 14, color: dark ? Tw.slate500 : Tw.slate400)),
      ]),
    );
  }
}
