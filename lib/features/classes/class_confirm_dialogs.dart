import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/external_link.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../institutes/institute_widgets.dart';
import 'class_list_logic.dart';
import 'class_list_vm.dart';

/// "Call" dialog: number + copy + `tel:` link.
class PhoneDialog extends StatelessWidget {
  const PhoneDialog({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return AppDialogFrame(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.only(right: 28),
          child: Row(children: [
            Flexible(child: Text(vm.phoneNumber, style: const TextStyle(fontSize: 16))),
            const SizedBox(width: 8),
            Tooltip(
              message: 'Copy number',
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => vm.run(() => vm.copyToClipboard(vm.phoneNumber)),
                  child: const Icon(BootstrapIcons.clipboard, size: 16),
                ),
              ),
            ),
            if (vm.copied) ...[
              const SizedBox(width: 8),
              const Text('Copied!', style: TextStyle(fontSize: 16, color: Tw.green500, fontWeight: FontWeight.w600)),
            ],
          ]),
        ),
        // `mb-2` + the content's `gap-4` + the link's `mt-1`.
        const SizedBox(height: 28),
        Material(
          color: context.colors.primary,
          borderRadius: BorderRadius.circular(4),
          child: InkWell(
            borderRadius: BorderRadius.circular(4),
            onTap: () => openExternal('tel:${vm.phoneNumber}'),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text('Call with default app',
                  textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: context.colors.onPrimary)),
            ),
          ),
        ),
        // `gap-4` + `mt-2`.
        const SizedBox(height: 24),
        Align(
          alignment: Alignment.centerRight,
          child: _CloseLink(dark: dark, onTap: () => vm.setOpen(ClassDialog.phone, false)),
        ),
      ]),
    );
  }
}

class _CloseLink extends StatefulWidget {
  const _CloseLink({required this.dark, required this.onTap});
  final bool dark;
  final VoidCallback onTap;

  @override
  State<_CloseLink> createState() => _CloseLinkState();
}

class _CloseLinkState extends State<_CloseLink> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Text('Close', style: TextStyle(fontSize: 12, color: _hover ? Colors.black : Tw.gray500)),
        ),
      );
}

enum RemoveKind { student, instructor, admin }

/// "Remove Student" / "Remove Instructor" / "Remove Admin" confirmations.
class RemovePersonDialog extends StatelessWidget {
  const RemovePersonDialog({super.key, required this.vm, required this.kind});
  final ClassListVm vm;
  final RemoveKind kind;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final (title, dialog, onConfirm) = switch (kind) {
      RemoveKind.student => ('Remove Student', ClassDialog.detachStudent, vm.confirmDetachStudent),
      RemoveKind.instructor => ('Remove Instructor', ClassDialog.detachInstructor, vm.confirmDetachInstructor),
      RemoveKind.admin => ('Remove Admin', ClassDialog.adminDelete, vm.AdminDelete),
    };
    final strong = TextStyle(fontWeight: FontWeight.w700, color: dark ? Colors.white : Tw.gray900);

    final InlineSpan description = switch (kind) {
      RemoveKind.admin => TextSpan(children: [
          const TextSpan(text: 'Are you sure you want to detach the admin '),
          TextSpan(text: vueText(vm.adminDeleteTarget?['name']), style: strong),
          const TextSpan(text: ' ('),
          TextSpan(
              text: vueText(vm.adminDeleteTarget?['email']),
              style: TextStyle(fontWeight: FontWeight.w500, color: dark ? Tw.gray300 : Tw.gray600)),
          const TextSpan(text: ') from this class '),
          TextSpan(text: vueText(vm.classDetails?['name']), style: strong),
          const TextSpan(text: '? This action cannot be undone.'),
        ]),
      _ => TextSpan(children: [
          const TextSpan(text: 'Are you sure you want to remove '),
          TextSpan(
            text: vueText((kind == RemoveKind.student ? vm.detachStudentTarget : vm.detachInstructorTarget)?['name']),
            style: TextStyle(fontWeight: FontWeight.w600, color: dark ? Tw.gray200 : null),
          ),
          const TextSpan(text: ' from this class? This action cannot be undone.'),
        ]),
    };
    // `text-gray-550` is not a Tailwind colour: the admin text keeps
    // `text-muted-foreground`.
    final descColor = kind == RemoveKind.admin
        ? (dark ? AppColors.darkMutedForeground : AppColors.mutedForeground)
        : Tw.gray500;

    final cancel = AppButton(
      label: 'Cancel',
      variant: AppButtonVariant.outline,
      expand: true,
      onPressed: () => vm.setOpen(dialog, false),
    );
    final remove = AppButton(
      expand: true,
      backgroundColor: Tw.red600,
      foregroundColor: Colors.white,
      onPressed: () => vm.run(onConfirm),
      child: vm.isLoading
          ? const SpinIcon(size: 16, color: Colors.white)
          : const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(BootstrapIcons.trash3, size: 16, color: Colors.white),
              SizedBox(width: 8),
              Text('Remove'),
            ]),
    );

    return AppDialogFrame(
      maxWidth: context.isSm ? 448 : context.screenWidth - 32,
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Tw.red100),
            child: const Icon(BootstrapIcons.person_dash_fill, size: 24, color: Tw.red600),
          ),
        ),
        const SizedBox(height: 12),
        Text(title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: dark ? Colors.white : Tw.gray900)),
        const SizedBox(height: 12),
        Text.rich(description, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: descColor)),
        // `py-2` + the content's `gap-4` + the footer's `mt-2`.
        const SizedBox(height: 32),
        if (context.isSm)
          Row(children: [Expanded(child: cancel), const SizedBox(width: 8), Expanded(child: remove)])
        else
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [cancel, const SizedBox(height: 8), remove]),
      ]),
    );
  }
}
