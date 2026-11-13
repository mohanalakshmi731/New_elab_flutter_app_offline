import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/form_fields.dart';
import '../institutes/institute_widgets.dart';
import '../users/users_widgets.dart';
import 'class_form_bits.dart';
import 'class_list_vm.dart';
import 'class_list_widgets.dart';

/// ADD INSTRUCTOR DIALOG (`w-[95vw] sm:max-w-3xl`): step 1 searches the
/// institute's instructors, step 3 creates a new one. The step header and
/// step 2 ("Search User") are `hidden` in the web.
class AddInstructorDialog extends StatelessWidget {
  const AddInstructorDialog({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final w = context.screenWidth;
    final heading = Padding(
      padding: const EdgeInsets.only(right: 28, bottom: 16),
      child: Text('Add Instructor',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: context.colors.primary)),
    );
    final body = switch (vm.currentStep) {
      1 => _step1(context),
      2 => const SizedBox.shrink(),
      _ => _step3(context),
    };
    return AppDialogFrame(
      maxWidth: math.min(w * 0.95, 768),
      padding: EdgeInsets.all(context.isSm ? 24 : 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [heading, body]),
    );
  }

  Widget _step1(BuildContext context) {
    final showBox = vm.showResults && vm.searchQuery.text.trim().isNotEmpty;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AnchoredDropdown(
        show: showBox,
        anchor: WizardSearchRow(
          controller: vm.searchQuery,
          hint: 'Search by Instructor name, email, or phone...',
          searching: vm.isSearching,
          onSearch: () => vm.run(vm.searchUser),
          onChanged: (_) {
            vm.showResults = false;
            vm.touch();
          },
        ),
        dropdown: SearchResultsBox(
          searching: vm.isSearching,
          results: vm.searchResults,
          onPick: vm.selectResult,
          emptyActions: [AppButton(label: 'Create New', size: AppButtonSize.sm, onPressed: () => vm.goToStep(3))],
        ),
      ),
      const SizedBox(height: 8),
      if (vm.isExistingUser) readonlyName(vm.foundUser.fullName, hint: 'Full Name'),
      // `gap-4` + the footer's `mt-6`.
      const SizedBox(height: 40),
      SplitFooter(
        splitAt: 1024,
        left: [ghostPrimary(context, 'Create New Instead', () => vm.goToStep(3))],
        right: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.outline,
            onPressed: () => vm.setOpen(ClassDialog.instructor, false),
          ),
          if (vm.isExistingUser)
            AppButton(
              onPressed: !vm.isExistingUser || vm.isCreateBtnLoading ? null : () => vm.run(vm.searchinsattach),
              child: BusyText(busy: vm.isCreateBtnLoading, label: 'Attach', color: context.colors.onPrimary),
            ),
        ],
      ),
    ]);
  }

  Widget _step3(BuildContext context) {
    final f = vm.newInstructor;
    const gap = SizedBox(height: 16);
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      const Text('No existing user selected. Fill in details to create a new instructor.',
          style: TextStyle(fontSize: 14, color: Tw.gray600)),
      gap,
      twoCols(
        context,
        LabeledControl(label: 'First Name', required: true, child: AppTextField(controller: f.firstName, hint: 'First Name')),
        LabeledControl(label: 'Last Name', required: true, child: AppTextField(controller: f.lastName, hint: 'Last Name')),
      ),
      gap,
      twoCols(
        context,
        LabeledControl(
          label: 'Email',
          required: true,
          child: AppTextField(controller: f.email, hint: 'Email', keyboardType: TextInputType.emailAddress),
        ),
        LabeledControl(
          label: 'Phone',
          required: true,
          child: PhoneRow(
            vm: vm,
            code: f.countryCode,
            onCode: (v) {
              f.countryCode = v;
              vm.touch();
            },
            phone: f.phone,
            hint: 'Phone',
          ),
        ),
      ),
      gap,
      twoCols(
        context,
        LabeledControl(
          label: 'Gender',
          child: AppSelect<String>(
            value: f.gender.isEmpty ? null : f.gender,
            placeholder: 'Select gender',
            items: genderItems,
            onChanged: (v) {
              f.gender = v ?? '';
              vm.touch();
            },
          ),
        ),
        LabeledControl(
          label: 'DOB',
          child: AppDateField(
            value: f.dob,
            onChanged: (v) {
              f.dob = v;
              vm.touch();
            },
          ),
        ),
      ),
      gap,
      twoCols(
        context,
        LabeledControl(
          label: 'Joining Date',
          child: AppDateField(
            value: f.joiningDate,
            onChanged: (v) {
              f.joiningDate = v;
              vm.touch();
            },
          ),
        ),
        LabeledControl(label: 'Designation', child: AppTextField(controller: f.designation, hint: 'Designation')),
      ),
      gap,
      twoCols(
        context,
        LabeledControl(label: 'Password', child: PasswordInput(controller: f.password, hint: 'Enter your Password')),
        Padding(
          padding: EdgeInsets.only(top: context.isSm ? 32 : 0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: LabeledCheckbox(
              value: f.enableZoom == true,
              label: 'Enable Zoom',
              labelStyle: const TextStyle(fontWeight: FontWeight.w500),
              onChanged: (v) {
                f.enableZoom = v;
                vm.touch();
              },
            ),
          ),
        ),
      ),
      gap,
      PhotoField(photo: f.photo, onPick: () => vm.run(vm.onNewInstructorPhoto)),
      const SizedBox(height: 40),
      SplitFooter(
        splitAt: 640,
        reverseOnMobile: true,
        left: [ghostPrimary(context, 'Back to Search', () => vm.goToStep(1), size: AppButtonSize.sm)],
        right: [
          AppButton(
            label: 'Cancel',
            variant: AppButtonVariant.outline,
            onPressed: () => vm.setOpen(ClassDialog.instructor, false),
          ),
          AppButton(
            onPressed: vm.isCreateBtnLoading ? null : () => vm.run(vm.addNewInstructor),
            child: BusyText(busy: vm.isCreateBtnLoading, label: 'Create', color: context.colors.onPrimary),
          ),
        ],
      ),
    ]);
  }
}

/// Update INSTRUCTOR DIALOG (`sm:max-w-3xl`).
class UpdateInstructorDialog extends StatelessWidget {
  const UpdateInstructorDialog({super.key, required this.vm});
  final ClassListVm vm;

  @override
  Widget build(BuildContext context) {
    final f = vm.newInstructor;
    const gap = SizedBox(height: 16);
    return AppDialogFrame(
      title: 'Update Instructor',
      maxWidth: context.isSm ? 768 : context.screenWidth - 32,
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => vm.setOpen(ClassDialog.updateInstructor, false),
        ),
        AppButton(
          onPressed: vm.isCreateBtnLoading ? null : () => vm.run(vm.InstructorUpdate),
          child: BusyText(busy: vm.isCreateBtnLoading, label: 'Update', color: context.colors.onPrimary),
        ),
      ],
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // `gap-4` + the fields' `mt-4` (the frame adds 16).
        gap,
        LabeledControl(label: 'First Name', child: AppTextField(controller: f.firstName, hint: 'First Name')),
        gap,
        LabeledControl(label: 'Last Name', child: AppTextField(controller: f.lastName, hint: 'Last Name')),
        gap,
        LabeledControl(label: 'Email', child: AppTextField(controller: f.email, hint: 'Email', enabled: false)),
        gap,
        LabeledControl(
          label: 'Phone',
          gap: 16,
          child: PhoneRow(
            vm: vm,
            code: f.countryCode,
            enabled: false,
            onCode: (v) {
              f.countryCode = v;
              vm.touch();
            },
            phone: f.phone,
            hint: 'Phone',
          ),
        ),
        gap,
        twoCols(
          context,
          LabeledControl(
            label: 'Joining Date',
            child: AppDateField(
              value: f.joiningDate,
              onChanged: (v) {
                f.joiningDate = v;
                vm.touch();
              },
            ),
          ),
          LabeledControl(label: 'Designation', child: AppTextField(controller: f.designation, hint: 'Designation')),
        ),
        gap,
        LabeledControl(
          label: 'Status',
          gap: 12,
          child: AppSelect<String>(
            value: vm.statusString,
            placeholder: 'Select status',
            items: const [AppSelectItem('true', 'Active'), AppSelectItem('false', 'InActive')],
            onChanged: (v) {
              if (v != null) vm.statusString = v;
            },
          ),
        ),
        // `gap-4` + the footer's `mt-6` (the frame adds 16).
        const SizedBox(height: 24),
      ]),
    );
  }
}
