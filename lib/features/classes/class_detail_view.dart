import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/session.dart';
import 'class_detail_tabs.dart';
import 'class_list_logic.dart';
import 'class_list_vm.dart';
import 'class_list_widgets.dart';
import 'class_ui_kit.dart';

/// "Class details display when selected": header + Admins / Batches /
/// Instructors / Courses tabs.
class ClassDetailView extends StatelessWidget {
  const ClassDetailView({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final header = Padding(
      padding: const EdgeInsets.all(8),
      child: _Header(vm: vm),
    );

    final tabContent = switch (vm.activeTab) {
      'admin' => AdminsTab(vm: vm),
      'batches' => BatchesTab(vm: vm),
      'instructors' => InstructorsTab(vm: vm),
      'courses' => CoursesTab(vm: vm),
      _ => const SizedBox.shrink(),
    };

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (!vm.isCourseExpanded) ...[header, const SizedBox(height: 16)],
      Padding(
        padding: EdgeInsets.symmetric(horizontal: vm.isCourseExpanded ? 0 : 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (!vm.isCourseExpanded)
            // `mb-4` / `mb-6` + `<Tabs>`'s `gap-2`.
            context.isLg
                ? Padding(padding: const EdgeInsets.only(bottom: 24), child: _CapsuleTabs(vm: vm))
                : Padding(padding: const EdgeInsets.only(bottom: 32), child: _SectionSelect(vm: vm)),
          tabContent,
        ]),
      ),
    ]);
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final title = Row(children: [
      BackSquareButton(tooltip: 'Back to classes', onTap: () => vm.run(vm.closeDrawer)),
      const SizedBox(width: 12),
      const HeaderIconTile(icon: BootstrapIcons.mortarboard_fill),
      const SizedBox(width: 12),
      Flexible(
        child: DetailHeading(
          title: Text(vueText(vm.classDetails?['name'])),
          subtitle: 'Manage administrators, batches, instructors, and courses.',
        ),
      ),
    ]);
    final create = vm.isAdminOrInstitute
        ? ClassButton(
            label: 'Create Class',
            icon: BootstrapIcons.plus_lg,
            iconSize: 12,
            fontSize: 12,
            gap: 6,
            height: 36,
            color: Tw.indigo600,
            hoverColor: Tw.indigo700,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            onPressed: vm.createInstitute,
          )
        : null;
    if (context.isMd) {
      return Row(children: [Expanded(child: title), ?create]);
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      title,
      if (create != null) ...[const SizedBox(height: 12), create],
    ]);
  }
}

String _tabLabel(String tab) => switch (tab) {
      'admin' => 'Admins',
      'batches' => 'Batches',
      'instructors' => 'Instructors',
      _ => 'Courses',
    };

IconData _tabIcon(String tab) => switch (tab) {
      'admin' => BootstrapIcons.shield,
      'batches' => BootstrapIcons.briefcase,
      'instructors' => BootstrapIcons.people,
      _ => BootstrapIcons.book,
    };

int _tabCount(ClassListVm vm, String tab) => switch (tab) {
      'admin' => vm.adminCount,
      'batches' => vm.s.batches.length,
      'instructors' => vm.instructorCount,
      _ => vm.courseCount,
    };

List<String> _tabs(ClassListVm vm) => [
      if (vm.showAdminsTab) 'admin',
      'batches',
      if (vm.role != Role.student) 'instructors',
      'courses',
    ];

/// Mobile `lg:hidden` section select.
class _SectionSelect extends StatelessWidget {
  const _SectionSelect({required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    return MenuSelect<String>(
      value: vm.activeTab,
      // `h-12` loses to shadcn's `data-[size=default]:h-9`.
      radius: 16,
      hPad: 16,
      fontWeight: FontWeight.w600,
      shadow: shadowSm,
      itemRadius: 20,
      itemMargin: true,
      menuRadius: 16,
      menuBorder: dark ? Tw.slate700 : Tw.slate200,
      menuShadow: true,
      groupLabel: 'Navigate Sections',
      onSelected: vm.setActiveTab,
      items: [for (final t in _tabs(vm)) MenuSelectItem(t, _tabLabel(t), icon: _tabIcon(t))],
      trigger: Row(children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
          child: Icon(_tabIcon(vm.activeTab), size: 14, color: primary),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(_tabLabel(vm.activeTab),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontWeight: FontWeight.w700, color: dark ? Tw.slate100 : Tw.slate800)),
        ),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
          decoration: BoxDecoration(color: dark ? Tw.slate800 : Tw.slate100, borderRadius: BorderRadius.circular(999)),
          child: Text('${_tabCount(vm, vm.activeTab)}',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: dark ? Tw.slate400 : Tw.slate500)),
        ),
      ]),
    );
  }
}

/// Desktop capsule switcher.
class _CapsuleTabs extends StatelessWidget {
  const _CapsuleTabs({required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final tabs = _tabs(vm);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: dark ? Tw.slate950.withValues(alpha: 0.6) : Tw.slate100.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dark ? Tw.slate800.withValues(alpha: 0.8) : Tw.slate200),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))],
      ),
      child: Row(children: [
        for (var i = 0; i < tabs.length; i++) ...[
          if (i > 0) const SizedBox(width: 2),
          Expanded(
            child: _CapsuleTab(
              label: _tabLabel(tabs[i]),
              icon: _tabIcon(tabs[i]),
              count: _tabCount(vm, tabs[i]),
              active: vm.activeTab == tabs[i],
              big: tabs[i] == 'courses',
              // Batches uses `hover:text-slate-750`, which is not a Tailwind colour.
              hoverText: tabs[i] != 'batches',
              onTap: () => vm.setActiveTab(tabs[i]),
            ),
          ),
        ],
      ]),
    );
  }
}

class _CapsuleTab extends StatefulWidget {
  const _CapsuleTab({
    required this.label,
    required this.icon,
    required this.count,
    required this.active,
    required this.big,
    required this.hoverText,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final int count;
  final bool active;

  /// The Courses tab uses `text-base` icon and a wider `text-[10px]` pill.
  final bool big;
  final bool hoverText;
  final VoidCallback onTap;

  @override
  State<_CapsuleTab> createState() => _CapsuleTabState();
}

class _CapsuleTabState extends State<_CapsuleTab> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final active = widget.active;
    final fg = active
        ? (dark ? Tw.indigo400 : Tw.indigo600)
        : (_hover && widget.hoverText && !dark ? Tw.slate700 : (dark ? Tw.slate400 : Tw.slate500));
    final bg = active
        ? (dark ? Tw.slate900 : Colors.white)
        : (_hover ? (dark ? Tw.slate900 : Colors.white).withValues(alpha: 0.4) : Colors.transparent);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: active
                  ? (dark ? Tw.slate800.withValues(alpha: 0.5) : Tw.slate200.withValues(alpha: 0.4))
                  : Colors.transparent,
            ),
            boxShadow: active
                ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2, offset: const Offset(0, 1))]
                : null,
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(widget.icon, size: widget.big ? 16 : 14, color: fg),
            const SizedBox(width: 6),
            Flexible(
              child: Text(widget.label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: fg)),
            ),
            const SizedBox(width: 6),
            Container(
              padding: EdgeInsets.symmetric(horizontal: widget.big ? 8 : 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: active
                    ? (dark ? Tw.indigo950.withValues(alpha: 0.5) : Tw.indigo50)
                    : (dark ? ClassTw.navy.withValues(alpha: 0.6) : Tw.slate200.withValues(alpha: 0.6)),
              ),
              child: Text('${widget.count}',
                  style: TextStyle(
                    fontSize: widget.big ? 10 : 9,
                    fontWeight: FontWeight.w900,
                    color: active ? (dark ? Tw.indigo300 : Tw.indigo600) : (dark ? Tw.slate400 : Tw.slate500),
                  )),
            ),
          ]),
        ),
      ),
    );
  }
}
