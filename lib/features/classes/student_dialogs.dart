import 'dart:math' as math;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/form_fields.dart';
import '../users/users_widgets.dart';
import 'class_form_bits.dart';
import 'class_list_vm.dart';
import 'class_list_widgets.dart';

Widget _ghost(String label, VoidCallback onTap, {IconData? leading, AppButtonSize size = AppButtonSize.normal}) =>
    AppButton(
      variant: AppButtonVariant.ghost,
      size: size,
      onPressed: onTap,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (leading != null) Icon(leading, size: 16),
        Text(label),
      ]),
    );

/// CREATE STUDENT DIALOG ("Add Student", `sm:max-w-3xl w-[90%]`): step 1
/// searches the institute's students, step 2 searches every user, step 3
/// creates a new one.
class AddStudentDialog extends StatelessWidget {
  const AddStudentDialog({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final w = context.screenWidth;
    final body = switch (vm.studentStep) {
      1 => _step1(context),
      2 => _step2(context),
      _ => _step3(context),
    };
    return AppDialogFrame(
      title: 'Add Student',
      maxWidth: context.isSm ? math.min(w * 0.9, 768) : w * 0.9,
      child: body,
    );
  }

  Widget _cancel() => AppButton(
        label: 'Cancel',
        variant: AppButtonVariant.outline,
        onPressed: () => vm.setOpen(ClassDialog.createStudent, false),
      );

  Widget _step1(BuildContext context) {
    final f = vm.foundStudent;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AnchoredDropdown(
        show: vm.showStudentResults,
        anchor: WizardSearchRow(
          controller: vm.studentQuery,
          hint: 'Search by student name, email, or phone...',
          searching: vm.isStudentSearching,
          onSearch: () => vm.run(vm.searchStudent),
        ),
        dropdown: SearchResultsBox(
          searching: vm.isStudentSearching,
          results: vm.studentResults,
          onPick: vm.selectStudentResult,
          emptyColor: Tw.gray500,
          emptyActions: [
            AppButton(
              label: 'Search User',
              size: AppButtonSize.sm,
              variant: AppButtonVariant.secondary,
              onPressed: () => vm.goToStudentStep(2),
            ),
            AppButton(label: 'Create New', size: AppButtonSize.sm, onPressed: () => vm.goToStudentStep(3)),
          ],
        ),
      ),
      const SizedBox(height: 8),
      if (vm.isExistingStudent && vm.studentQuery.text.trim().isNotEmpty) ...[
        // The search's `mb-2` + `gap-4`.
        const SizedBox(height: 16),
        readonlyName(f.fullName),
      ],
      const SizedBox(height: 16),
      SplitFooter(
        splitAt: 1024,
        left: [
          ghostPrimary(context, 'Search User Instead', () => vm.goToStudentStep(2),
              trailing: BootstrapIcons.arrow_right_short),
          ghostPrimary(context, 'Create New Instead', () => vm.goToStudentStep(3),
              trailing: BootstrapIcons.arrow_right_short),
        ],
        right: [
          _cancel(),
          if (vm.isExistingStudent)
            AppButton(
              onPressed: !vm.isExistingStudent || vm.isCreateBtnLoading ? null : () => vm.run(vm.attachExistingStudent),
              child: BusyText(busy: vm.isCreateBtnLoading, label: 'Attach', color: context.colors.onPrimary),
            ),
        ],
      ),
    ]);
  }

  Widget _step2(BuildContext context) {
    final f = vm.foundStudent;
    final showBox = vm.showStudentGlobalResults && vm.studentGlobalQuery.text.trim().isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AnchoredDropdown(
        show: showBox,
        anchor: WizardSearchRow(
          controller: vm.studentGlobalQuery,
          hint: 'Search user globally by name/email/phone...',
          searching: vm.isStudentSearchingGlobal,
          // No Enter handler in the web.
          submitOnEnter: false,
          onSearch: () => vm.run(vm.searchStudentGlobal),
          onChanged: (_) {
            vm.showStudentGlobalResults = false;
            vm.touch();
          },
        ),
        dropdown: SearchResultsBox(
          searching: vm.isStudentSearchingGlobal,
          results: vm.studentGlobalResults,
          onPick: vm.studentGlobalResultClick,
          emptyActions: [
            AppButton(label: 'Create New', size: AppButtonSize.sm, onPressed: () => vm.goToStudentStep(3)),
          ],
        ),
      ),
      const SizedBox(height: 8),
      if (vm.isExistingStudent) readonlyName(f.fullName),
      // `mb-2` + `gap-4` + the footer's `mt-6`.
      const SizedBox(height: 48),
      SplitFooter(
        splitAt: 1024,
        left: [_ghost('Back to Search', () => vm.goToStudentStep(1), leading: BootstrapIcons.arrow_left_short)],
        right: [
          _cancel(),
          AppButton(
            onPressed: !vm.isExistingStudent || vm.isCreateBtnLoading
                ? null
                : () => vm.run(() => vm.attachStudentFromGlobal(f.id)),
            child: BusyText(busy: vm.isCreateBtnLoading, label: 'Attach', color: context.colors.onPrimary),
          ),
        ],
      ),
    ]);
  }

  Widget _step3(BuildContext context) {
    final s = vm.newStudent;
    const gap = SizedBox(height: 16);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const SizedBox(height: 8),
      const Text('No existing user selected. Fill in details to create a new student.',
          style: TextStyle(fontSize: 14, color: Tw.gray600)),
      gap,
      LabeledControl(
          label: 'First Name', required: true, child: AppTextField(controller: s.firstName, hint: 'Enter first name')),
      gap,
      LabeledControl(
          label: 'Last Name', required: true, child: AppTextField(controller: s.lastName, hint: 'Enter last name')),
      gap,
      LabeledControl(
        label: 'Email',
        required: true,
        child: AppTextField(controller: s.email, hint: 'Enter email address', keyboardType: TextInputType.emailAddress),
      ),
      gap,
      LabeledControl(
          label: 'Password', required: true, child: PasswordInput(controller: s.password, hint: 'Enter password')),
      gap,
      LabeledControl(
        label: 'Confirm Password',
        required: true,
        child: PasswordInput(controller: s.confirmpassword, hint: 'Confirm your password'),
      ),
      gap,
      LabeledControl(
        label: 'Phone',
        required: true,
        child: PhoneRow(
          vm: vm,
          code: s.countryCode,
          onCode: (v) {
            s.countryCode = v;
            vm.touch();
          },
          phone: s.phone,
          hint: 'Enter phone number',
        ),
      ),
      gap,
      twoCols(
        context,
        LabeledControl(
          label: 'Gender',
          child: AppSelect<String>(
            value: s.gender.isEmpty ? null : s.gender,
            placeholder: 'Select gender',
            items: genderItems,
            onChanged: (v) {
              s.gender = v ?? '';
              vm.touch();
            },
          ),
        ),
        LabeledControl(
          label: 'DOB',
          child: AppDateField(
            value: s.dob,
            onChanged: (v) {
              s.dob = v;
              vm.touch();
            },
          ),
        ),
      ),
      gap,
      PhotoField(photo: s.photo, bordered: false, onPick: () => vm.run(vm.onNewStudentPhoto)),
      // `gap-4` + the footer's `mt-6`.
      const SizedBox(height: 40),
      SplitFooter(
        splitAt: 640,
        left: [
          _ghost('Back to Search User', () => vm.goToStudentStep(2),
              leading: BootstrapIcons.arrow_left_short, size: AppButtonSize.sm),
          _ghost('Back to Search', () => vm.goToStudentStep(1), size: AppButtonSize.sm),
        ],
        right: [
          _cancel(),
          AppButton(
            onPressed: vm.isCreateBtnLoading ? null : () => vm.run(vm.addNewStudent),
            child: BusyText(busy: vm.isCreateBtnLoading, label: 'Create', color: context.colors.onPrimary),
          ),
        ],
      ),
    ]);
  }
}

/// Update STUDENT DIALOG (`sm:max-w-3xl`).
class UpdateStudentDialog extends StatelessWidget {
  const UpdateStudentDialog({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final s = vm.newStudent;
    const gap = SizedBox(height: 16);
    return AppDialogFrame(
      title: 'Update Student',
      maxWidth: context.isSm ? 768 : context.screenWidth - 32,
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => vm.setOpen(ClassDialog.updateStudent, false),
        ),
        AppButton(
          onPressed: vm.isCreateBtnLoading ? null : () => vm.run(vm.StudentUpdate),
          child: BusyText(busy: vm.isCreateBtnLoading, label: 'Update', color: context.colors.onPrimary),
        ),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // `gap-4` + the fields' `mt-4` (the frame adds 16).
        gap,
        LabeledControl(label: 'First Name', child: AppTextField(controller: s.firstName, hint: 'First Name')),
        gap,
        LabeledControl(label: 'Last Name', child: AppTextField(controller: s.lastName, hint: 'Last Name')),
        gap,
        LabeledControl(label: 'Email', child: AppTextField(controller: s.email, hint: 'Email', enabled: false)),
        gap,
        LabeledControl(
          label: 'Phone',
          gap: 16,
          child: PhoneRow(
            vm: vm,
            code: s.countryCode,
            enabled: false,
            onCode: (v) {
              s.countryCode = v;
              vm.touch();
            },
            phone: s.phone,
            hint: 'Phone',
          ),
        ),
        gap,
        LabeledControl(
          label: 'Status',
          gap: 12,
          child: AppSelect<String>(
            value: vm.studentStatusString,
            placeholder: 'Select status',
            items: const [AppSelectItem('true', 'Active'), AppSelectItem('false', 'InActive')],
            onChanged: (v) {
              if (v != null) vm.studentStatusString = v;
            },
          ),
        ),
        const SizedBox(height: 24),
      ]),
    );
  }
}
