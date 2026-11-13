import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/form_fields.dart';
import 'class_list_logic.dart';
import 'class_list_vm.dart';
import 'class_list_widgets.dart';

const _statusItems = [
  AppSelectItem<Object?>('published', 'Active'),
  AppSelectItem<Object?>('draft', 'InActive'),
  AppSelectItem<Object?>('archived', 'Archived'),
];

final _levelItems = [for (var l = 1; l <= 10; l++) AppSelectItem<int?>(l, 'Class Level $l')];

/// `sm:max-w-md`
double _md(BuildContext context) => context.isSm ? 448 : context.screenWidth - 32;

Widget _gap([double h = 16]) => SizedBox(height: h);

// ── CLASS CREATE ──────────────────────────────────────────────────────────────

class CreateClassDialog extends StatelessWidget {
  const CreateClassDialog({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final curriculums = [for (final c in vm.s.curriculums) if (c['status'] == 'published') c];
    return AppDialogFrame(
      maxWidth: _md(context),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => vm.setOpen(ClassDialog.createClass, false),
        ),
        AppButton(
          onPressed: vm.isCreateBtnLoading ? null : () => vm.run(vm.CreateClass),
          child: BusyText(busy: vm.isCreateBtnLoading, label: 'Create', color: context.colors.onPrimary),
        ),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const PrimaryDialogHeading('Create Class'),
        _gap(32),
        // An inline `<label class="mb-1">`: its `space-y-4` margin has no effect.
        const PlainLabel('Class Name', bottom: 0),
        AppTextField(controller: vm.newClassName, hint: 'Enter class name'),
        _gap(),
        const PlainLabel('Curriculum'),
        AppSelect<Object?>(
          value: vm.selectedCurriculumId,
          placeholder: 'Select Curriculum',
          items: [for (final c in curriculums) AppSelectItem<Object?>(c['id'], vueText(c['name']))],
          onChanged: (v) {
            vm.selectedCurriculumId = v;
            vm.touch();
          },
        ),
        _gap(),
        const PlainLabel('Class Level'),
        AppSelect<int?>(
          value: vm.selectedClassLevel,
          placeholder: 'Select class level',
          items: _levelItems,
          onChanged: (v) {
            vm.selectedClassLevel = v;
            vm.touch();
          },
        ),
        _gap(),
        const PlainLabel('Status'),
        AppSelect<Object?>(
          value: vm.classstatus,
          placeholder: 'Select status',
          items: _statusItems,
          onChanged: (v) {
            vm.classstatus = v;
            vm.touch();
          },
        ),
        // `gap-4` + the footer's `mt-6` (the frame adds 16).
        _gap(24),
      ]),
    );
  }
}

// ── CLASS UPDATE ──────────────────────────────────────────────────────────────

class UpdateClassDialog extends StatelessWidget {
  const UpdateClassDialog({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    return AppDialogFrame(
      maxWidth: _md(context),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => vm.setOpen(ClassDialog.updateClass, false),
        ),
        AppButton(label: 'Update', onPressed: () => vm.run(vm.ClassUpdate)),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const PrimaryDialogHeading('Update Class'),
        _gap(32),
        // An inline `<label class="mb-1">`: its `space-y-4` margin has no effect.
        const PlainLabel('Class Name', bottom: 0),
        AppTextField(controller: vm.newClassName, hint: 'Enter class name'),
        _gap(),
        const PlainLabel('Class Level'),
        AppSelect<int?>(
          value: vm.selectedClassLevel,
          placeholder: 'Select class level',
          items: _levelItems,
          onChanged: (v) {
            vm.selectedClassLevel = v;
            vm.touch();
          },
        ),
        _gap(),
        const PlainLabel('Status'),
        AppSelect<Object?>(
          value: vm.classstatus,
          placeholder: 'Select status',
          items: _statusItems,
          onChanged: (v) {
            vm.classstatus = v;
            vm.touch();
          },
        ),
        // `gap-4` + the footer's `mt-6` (the frame adds 16).
        _gap(24),
      ]),
    );
  }
}

// ── DELETE (deleteTarget) — never opened by the web ──────────────────────────

class DeleteTargetDialog extends StatelessWidget {
  const DeleteTargetDialog({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final muted = context.isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;
    return AppDialogFrame(
      maxWidth: _md(context),
      actions: [
        AppButton(label: 'Cancel', onPressed: () => vm.setOpen(ClassDialog.deleteTarget, false)),
        // No handler in the web.
        AppButton(label: 'Delete', onPressed: () {}),
      ],
      child: Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'Are you sure you want to delete '),
            TextSpan(text: vueText(vm.deleteTarget?['name']), style: const TextStyle(fontWeight: FontWeight.w700)),
            const TextSpan(text: '?'),
          ]),
          textAlign: context.isSm ? TextAlign.start : TextAlign.center,
          style: TextStyle(fontSize: 14, color: muted),
        ),
      ),
    );
  }
}

// ── SKILL DIALOG — opened only by `createSkill()`, which nothing calls ───────

class SkillCategoriesDialog extends StatelessWidget {
  const SkillCategoriesDialog({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    return AppDialogFrame(
      title: 'Add Skill Categories',
      maxWidth: _md(context),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => vm.setOpen(ClassDialog.skill, false),
        ),
        AppButton(label: 'Close', onPressed: () => vm.setOpen(ClassDialog.skill, false)),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _gap(),
        AppTextField(controller: vm.newSkill, hint: 'Skill Name'),
        _gap(),
        Align(alignment: Alignment.centerLeft, child: AppButton(label: 'Add', onPressed: () => vm.run(vm.addSkill))),
        _gap(),
        for (var i = 0; i < vm.skills.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(children: [
              Expanded(child: Text(vm.skills[i])),
              AppButton(icon: BootstrapIcons.gear, onPressed: () => vm.run(() => vm.editSkill(i))),
              const SizedBox(width: 8),
              // Only the icon (not the button) has the click handler in the web.
              AppButton(
                onPressed: () {},
                child: GestureDetector(onTap: () => vm.run(vm.showAlert), child: const Icon(BootstrapIcons.trash)),
              ),
            ]),
          ),
      ]),
    );
  }
}

// ── EDIT BATCH — never opened by the web ─────────────────────────────────────

class EditBatchDialog extends StatelessWidget {
  const EditBatchDialog({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    return AppDialogFrame(
      title: 'Edit Batch',
      description: 'Select the class year and batch you want to update.',
      maxWidth: _md(context),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => vm.setOpen(ClassDialog.editBatch, false),
        ),
        AppButton(label: 'Submit', onPressed: vm.submitBatchEdit),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _gap(),
        const PlainLabel('Select Year', small: true),
        AppSelect<Object?>(
          value: vm.editBatch['year'],
          placeholder: 'Choose Year',
          items: [for (final i in vm.s.institutes) AppSelectItem<Object?>(i['year'], vueText(i['year']))],
          onChanged: (v) {
            vm.editBatch = {...vm.editBatch, 'year': v};
            vm.touch();
          },
        ),
        _gap(),
        const PlainLabel('Select Batch', small: true),
        AppSelect<Object?>(
          value: vm.editBatch['name'],
          placeholder: 'Choose Batch',
          items: [for (final b in vm.s.batches) AppSelectItem<Object?>(b['name'], vueText(b['name']))],
          onChanged: (v) {
            vm.editBatch = {...vm.editBatch, 'name': v};
            vm.touch();
          },
        ),
        _gap(24),
      ]),
    );
  }
}

// ── BATCH UPDATE ──────────────────────────────────────────────────────────────

class UpdateBatchDialog extends StatelessWidget {
  const UpdateBatchDialog({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    return AppDialogFrame(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // `<DialogHeader><DialogDescription>`: centred below `sm`.
        Padding(
          padding: const EdgeInsets.only(right: 28),
          child: Text('Update Batch',
              textAlign: context.isSm ? TextAlign.start : TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: context.isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground)),
        ),
        _gap(),
        AppTextField(controller: vm.updateBatchName, hint: 'Update Batch Name'),
        _gap(),
        const PlainLabel('Status'),
        AppSelect<Object?>(
          value: vm.batchstatus,
          placeholder: 'Select status',
          items: _statusItems,
          onChanged: (v) {
            vm.batchstatus = asString(v);
            vm.touch();
          },
        ),
        _gap(32),
        Align(
          alignment: Alignment.centerRight,
          child: AppButton(
            onPressed: () => vm.run(vm.BatchUpdate),
            child: BusyText(busy: vm.isCreateBtnLoading, label: 'Update', color: context.colors.onPrimary),
          ),
        ),
      ]),
    );
  }
}

// ── BATCH DELETE ──────────────────────────────────────────────────────────────

class DeleteBatchDialog extends StatelessWidget {
  const DeleteBatchDialog({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final muted = context.isDark ? AppColors.darkMutedForeground : AppColors.mutedForeground;
    return AppDialogFrame(
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: const EdgeInsets.only(right: 28),
          child: Text('Confirm Delete',
              textAlign: context.isSm ? TextAlign.start : TextAlign.center, style: const TextStyle(fontSize: 16)),
        ),
        _gap(),
        Text('Are you sure you want to delete this Batch?', style: TextStyle(fontSize: 14, color: muted)),
        _gap(32),
        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
          AppButton(
            label: 'No',
            variant: AppButtonVariant.outline,
            onPressed: () => vm.setOpen(ClassDialog.deleteBatch, false),
          ),
          const SizedBox(width: 8),
          // `bg-primary text-white` (white in dark mode too).
          AppButton(label: 'Yes', foregroundColor: Colors.white, onPressed: () => vm.run(vm.batchDelete)),
        ]),
      ]),
    );
  }
}
