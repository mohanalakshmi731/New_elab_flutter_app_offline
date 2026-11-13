import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_loader.dart';
import '../courses/course_list_view.dart';
import 'batch_students_view.dart';
import 'class_confirm_dialogs.dart';
import 'class_detail_view.dart';
import 'class_dialog_host.dart';
import 'class_dialogs.dart';
import 'class_grid_view.dart';
import 'class_list_vm.dart';
import 'class_list_widgets.dart';
import 'instructor_dialogs.dart';
import 'promote_transfer_dialogs.dart';
import 'student_dialogs.dart';

/// Port of `src/pages/class/classlist.vue` (`/classlist`, `/courselist` →
/// `/classlist?tab=courses`).
///
/// The component's `data()`, computed props, watchers and methods live in
/// [ClassListVm] (owned here) so the dialogs — separate routes — share the
/// same state; the mapped store slice is [classListControllerProvider].
class ClassListPage extends ConsumerStatefulWidget {
  const ClassListPage({super.key, this.tab});

  /// `?tab=` (`courses` opens "Courses & Curriculums" for admins / institutes).
  final String? tab;

  @override
  ConsumerState<ClassListPage> createState() => _ClassListPageState();
}

class _ClassListPageState extends ConsumerState<ClassListPage> {
  late final ClassListVm _vm;
  final Set<ClassDialog> _shown = {};

  @override
  void initState() {
    super.initState();
    _vm = ClassListVm(ProviderScope.containerOf(context, listen: false));
    _vm.alert = (m) => showClassAlert(context, m);
    _vm.prompt = (m, v) => showClassPrompt(context, m, v);
    _vm.addListener(_onVm);
    Future.microtask(() => _vm.run(() => _vm.mounted(widget.tab)));
  }

  @override
  void didUpdateWidget(ClassListPage old) {
    super.didUpdateWidget(old);
    // `watch: '$route.query.tab'` (runs after the current build, like Vue's watcher flush).
    if (old.tab != widget.tab) {
      final tab = widget.tab;
      Future.microtask(() {
        if (mounted) _vm.onRouteTab(tab);
      });
    }
  }

  @override
  void dispose() {
    _vm.removeListener(_onVm);
    _vm.dispose();
    super.dispose();
  }

  void _onVm() {
    if (!mounted) return;
    setState(() {});
    for (final d in _vm.openDialogs) {
      if (_shown.add(d)) WidgetsBinding.instance.addPostFrameCallback((_) => _show(d));
    }
  }

  /// `<Dialog v-model:open>`: opens the dialog for [d]; closing it by any
  /// means clears the flag (which also runs the open-flag watchers).
  Future<void> _show(ClassDialog d) async {
    if (!mounted) return;
    final vm = _vm;
    final (builder, guard) = switch (d) {
      ClassDialog.promote => ((BuildContext _) => PromoteStudentsDialog(vm: vm), true),
      ClassDialog.transfer => ((BuildContext _) => TransferStudentsDialog(vm: vm), true),
      ClassDialog.deleteTarget => ((BuildContext _) => DeleteTargetDialog(vm: vm), false),
      ClassDialog.createClass => ((BuildContext _) => CreateClassDialog(vm: vm), true),
      ClassDialog.updateClass => ((BuildContext _) => UpdateClassDialog(vm: vm), false),
      ClassDialog.skill => ((BuildContext _) => SkillCategoriesDialog(vm: vm), false),
      ClassDialog.editBatch => ((BuildContext _) => EditBatchDialog(vm: vm), false),
      ClassDialog.instructor => ((BuildContext _) => AddInstructorDialog(vm: vm), true),
      ClassDialog.updateInstructor => ((BuildContext _) => UpdateInstructorDialog(vm: vm), true),
      ClassDialog.createStudent => ((BuildContext _) => AddStudentDialog(vm: vm), true),
      ClassDialog.updateStudent => ((BuildContext _) => UpdateStudentDialog(vm: vm), true),
      ClassDialog.phone => ((BuildContext _) => PhoneDialog(vm: vm), false),
      ClassDialog.detachStudent => ((BuildContext _) => RemovePersonDialog(vm: vm, kind: RemoveKind.student), false),
      ClassDialog.detachInstructor =>
        ((BuildContext _) => RemovePersonDialog(vm: vm, kind: RemoveKind.instructor), false),
      ClassDialog.adminDelete => ((BuildContext _) => RemovePersonDialog(vm: vm, kind: RemoveKind.admin), false),
      ClassDialog.deleteBatch => ((BuildContext _) => DeleteBatchDialog(vm: vm), false),
      ClassDialog.updateBatch => ((BuildContext _) => UpdateBatchDialog(vm: vm), true),
    };
    await showAppDialog<void>(
      context,
      builder: (_) => VmDialogHost(vm: vm, dialog: d, guardBusy: guard, builder: builder),
    );
    _shown.remove(d);
    if (!vm.isDisposed) vm.setOpen(d, false);
  }

  @override
  Widget build(BuildContext context) {
    final vm = _vm;
    final dark = context.isDark;
    final hasClass = vm.hasClass;
    final leftVisible = (vm.currentLmsTab == 'courses' || !vm.isCourseExpanded) && !hasClass;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // LEFT PART (v-show): classes grid / courses view.
        Offstage(
          offstage: !leftVisible,
          child: TickerMode(enabled: leftVisible, child: ClassGridSection(vm: vm)),
        ),
        // RIGHT PART: the selected class.
        if (hasClass)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
            child: vm.currentLmsTab == 'classes'
                ? (vm.showBatchStudentsInline ? BatchStudentsView(vm: vm) : ClassDetailView(vm: vm))
                : CourseListView(
                    key: ValueKey(vm.courseListKey),
                    externalActiveTab: vm.courseActiveTab,
                    hideTriggers: true,
                    onCourseExpanded: vm.handleCourseExpanded,
                  ),
          ),
      ],
    );

    // The large glass card wrapping the page (`bg-white/75 … rounded-[32px]`).
    final card = Container(
      padding: EdgeInsets.all(context.isMd ? 32 : (context.isSm ? 24 : 16)),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          width: 2,
          color: dark ? Tw.slate800.withValues(alpha: 0.8) : Colors.white.withValues(alpha: 0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.15),
            blurRadius: 50,
            spreadRadius: -12,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: content,
    );

    return LoadingOverlay(
      loading: vm.isLoading,
      child: ColoredBox(
        color: dark ? ClassTw.night : Colors.transparent,
        child: Stack(
          children: [
            const Positioned.fill(child: _MeshBlobs()),
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: context.isSm ? 16 : 8,
                  vertical: context.isSm ? 24 : 16,
                ),
                child: card,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The three glowing background blobs (`blur-[120px] animate-pulse`),
/// rendered as static radial gradients.
class _MeshBlobs extends StatelessWidget {
  const _MeshBlobs();

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    Widget blob(double size, Color color) => Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
          ),
        );
    return IgnorePointer(
      child: LayoutBuilder(builder: (context, c) {
        final w = c.maxWidth;
        final h = c.maxHeight;
        return ClipRect(
          child: Stack(children: [
            Positioned(
              top: h * 0.05,
              left: -w * 0.10,
              child: blob(500, dark ? Tw.indigo950.withValues(alpha: 0.15) : Tw.indigo200.withValues(alpha: 0.25)),
            ),
            Positioned(
              top: h * 0.30,
              right: -w * 0.15,
              child: blob(600, dark ? ClassTw.purple950.withValues(alpha: 0.10) : ClassTw.purple200.withValues(alpha: 0.20)),
            ),
            Positioned(
              bottom: h * 0.05,
              left: w * 0.20,
              child: blob(550, dark ? ClassTw.pink950.withValues(alpha: 0.08) : ClassTw.pink100.withValues(alpha: 0.20)),
            ),
          ]),
        );
      }),
    );
  }
}
