import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/form_fields.dart';
import 'class_list_logic.dart';
import 'class_list_vm.dart';
import 'class_list_widgets.dart';

/// `{{ classDetails ? classDetails.name : 'No class selected' }} / {{ selectedBatch.name }}`
class _ClassBatchTitle extends StatelessWidget {
  const _ClassBatchTitle({required this.vm, required this.description});
  final ClassListVm vm;
  final String description;

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    final cd = vm.classDetails;
    final style = TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: primary);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Padding(
        padding: const EdgeInsets.only(right: 28),
        child: Text('${cd != null ? vueText(cd['name']) : 'No class selected'} / ${vueText(vm.selectedBatch['name'])}',
            style: style),
      ),
      const SizedBox(height: 16),
      // `<DialogHeader><DialogDescription>`: `text-muted-foreground`, centred below `sm`.
      Text(description,
          textAlign: context.isSm ? TextAlign.start : TextAlign.center,
          style: TextStyle(
              fontSize: 14, color: context.isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground)),
      // `gap-4` + the fields' `mt-4`.
      const SizedBox(height: 32),
    ]);
  }
}

double _md(BuildContext context) => context.isSm ? 448 : context.screenWidth - 32;

/// PROMOTE STUDENTS DIALOG
class PromoteStudentsDialog extends StatelessWidget {
  const PromoteStudentsDialog({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final cd = vm.classDetails;
    final classes = [
      for (final c in vm.promoteClassList)
        if (cd != null && c['id'] != cd['id']) c,
    ];
    final batches = vm.s.promoteBatchList;
    return AppDialogFrame(
      maxWidth: _md(context),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => vm.setOpen(ClassDialog.promote, false),
        ),
        AppButton(
          onPressed: () => vm.run(vm.onPromoteConfirm),
          child: BusyText(busy: vm.isCreateBtnLoading, label: 'Promote', color: context.colors.onPrimary),
        ),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _ClassBatchTitle(vm: vm, description: 'Select Class and Batch to promote students.'),
        const PlainLabel('Target Class', small: true),
        AppSelect<Object?>(
          value: vm.promoteTargetClass,
          placeholder: 'Choose Class',
          items: [for (final c in classes) AppSelectItem<Object?>(c['id'], vueText(c['year']))],
          onChanged: (v) => vm.run(() => vm.onClassChange(v)),
        ),
        const SizedBox(height: 16),
        const PlainLabel('Target Batch', small: true),
        AppSelect<Object?>(
          value: vm.promoteTargetBatch,
          placeholder: 'Choose Batch',
          enabled: batches.isNotEmpty,
          items: [for (final b in batches) AppSelectItem<Object?>(b['id'], vueText(b['name']))],
          onChanged: (v) {
            vm.promoteTargetBatch = v;
            vm.touch();
          },
        ),
        // `gap-4` + the footer's `mt-6` (the frame adds 16).
        const SizedBox(height: 24),
      ]),
    );
  }
}

/// TRANSFER STUDENTS DIALOG
class TransferStudentsDialog extends StatelessWidget {
  const TransferStudentsDialog({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final batches = vm.transferBatchList;
    return AppDialogFrame(
      maxWidth: _md(context),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => vm.setOpen(ClassDialog.transfer, false),
        ),
        AppButton(
          onPressed: vm.isCreateBtnLoading ? null : () => vm.run(vm.transferNow),
          child: BusyText(busy: vm.isCreateBtnLoading, label: 'Transfer', color: context.colors.onPrimary),
        ),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _ClassBatchTitle(vm: vm, description: 'Select Batch to transfer students.'),
        const PlainLabel('Target Batch', small: true),
        AppSelect<Object?>(
          value: vm.transferTargetBatch,
          placeholder: 'Choose Batch',
          enabled: batches.isNotEmpty,
          items: [for (final b in batches) AppSelectItem<Object?>(b['id'], vueText(b['name']))],
          onChanged: (v) {
            vm.transferTargetBatch = v;
            vm.touch();
          },
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}
