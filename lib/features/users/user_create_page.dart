import 'dart:math' as math;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/files.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart';
import 'users_controller.dart';
import 'users_logic.dart';
import 'users_widgets.dart';

/// Port of `src/pages/user/usercreate.vue` (`/userscreate`).
///
/// The form lives in the shared `userForm` ([UsersState.userForm]); the web
/// has no client-side validation (the `*` are cosmetic) — the API validates.
class UserCreatePage extends ConsumerStatefulWidget {
  const UserCreatePage({super.key});

  @override
  ConsumerState<UserCreatePage> createState() => _UserCreatePageState();
}

class _UserCreatePageState extends ConsumerState<UserCreatePage> {
  static const _textKeys = [
    'firstName',
    'lastName',
    'email',
    'phone',
    'password',
    'confirmpassword',
    'designation',
  ];

  // data()
  bool _isLoading = false;
  bool _isCreateBtnLoading = false;

  late final MapTextBinding _form = MapTextBinding(_textKeys, ref.read(usersControllerProvider).userForm);

  UsersController get _ctrl => ref.read(usersControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(_mounted);
  }

  @override
  void dispose() {
    _form.dispose();
    super.dispose();
  }

  Future<void> _mounted() async {
    _ctrl.setUserForm(emptyUserForm);
    await _fetchDialCodes();
  }

  Future<void> _fetchDialCodes() async {
    setState(() => _isLoading = true);
    try {
      await _ctrl.loadUserDialCodes();
    } catch (_) {
      // The API client already toasted the error.
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _set(String key, Object? value) => _ctrl.patchUserForm({key: value});

  Future<void> _onPhotoChange() async {
    final file = await pickImageFile();
    if (file != null) _set('photo', file);
  }

  Future<void> _submitForm() async {
    if (_isCreateBtnLoading) return;
    setState(() => _isCreateBtnLoading = true);
    var success = false;
    try {
      success = await _ctrl.createUser();
    } catch (_) {
      // Validation / server errors were toasted by the API client.
    } finally {
      if (mounted) setState(() => _isCreateBtnLoading = false);
    }
    if (success && mounted) await _openDialog();
  }

  /// `<Dialog v-model:open="isDialogOpen">` — only "OK" navigates away.
  Future<void> _openDialog() async {
    final ok = await showAppDialog<bool>(
      context,
      builder: (ctx) => AppDialogFrame(
        title: 'Email Sent',
        description: 'Credentials have been sent to mail',
        maxWidth: 448,
        actions: [AppButton(label: 'OK', onPressed: () => Navigator.of(ctx).pop(true))],
      ),
    );
    if (ok == true && mounted) context.go('/userlist');
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Map<String, dynamic>>(
      usersControllerProvider.select((s) => s.userForm),
      (_, next) => _form.sync(next),
    );
    final s = ref.watch(usersControllerProvider);
    final form = s.userForm;
    // `grid-cols-1 sm:grid-cols-2 md:grid-cols-1`
    final cols = context.isSm && !context.isMd ? 2 : 1;
    // `min-[1600px]:text-2xl` (24px) on the labels, inputs, selects and the
    // button, `min-[1600px]:p-7` on the controls (the 28px padding beats
    // `h-9`, so they grow to 58px). The Designation field has neither.
    final huge = context.screenWidth >= 1600;
    final double? fieldFont = huge ? 24 : null;
    final double? fieldHeight = huge ? 58 : null;
    final photo = form['photo'];

    // `<FormLabel class="min-[1600px]:text-2xl">`
    Widget labeled(String label, Widget child, {bool required = false}) {
      Widget l = FieldLabel(label, required: required);
      if (huge) {
        l = MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(24 / 14)),
          child: l,
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(alignment: AlignmentDirectional.centerStart, child: l),
          const SizedBox(height: 8),
          child,
        ],
      );
    }

    // Controls without a size parameter (date, file input) are scaled.
    Widget scaled(Widget child) => huge
        ? MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaler: const TextScaler.linear(24 / 14)),
            child: child,
          )
        : child;

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormGrid(columns: cols, children: [
          labeled(
            'First Name',
            required: true,
            AppTextField(
              controller: _form['firstName'],
              hint: 'First name',
              fontSize: fieldFont,
              height: fieldHeight,
              onChanged: (v) => _set('firstName', v),
            ),
          ),
          labeled(
            'Last Name',
            required: true,
            AppTextField(
              controller: _form['lastName'],
              hint: 'Last name',
              fontSize: fieldFont,
              height: fieldHeight,
              onChanged: (v) => _set('lastName', v),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        FormGrid(columns: cols, children: [
          labeled(
            'Email',
            required: true,
            AppTextField(
              controller: _form['email'],
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
              fontSize: fieldFont,
              height: fieldHeight,
              onChanged: (v) => _set('email', v),
            ),
          ),
          labeled(
            'Phone',
            required: true,
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // `w-24 min-[1600px]:w-26`
                SizedBox(
                  width: huge ? 104 : 96,
                  child: AppSelect<String>(
                    value: form['countryCode'] == null || '${form['countryCode']}'.isEmpty
                        ? null
                        : '${form['countryCode']}',
                    placeholder: 'Code',
                    fontSize: fieldFont ?? 14,
                    height: fieldHeight ?? 36,
                    items: [
                      for (final c in s.dailCodes) AppSelectItem('${c['code']}', '${c['code']}'),
                    ],
                    onChanged: (v) => _set('countryCode', v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  // The web types the digits at `min-[1600px]:text-6xl` but
                  // keeps the placeholder at text-2xl; the field uses 24px.
                  child: AppTextField(
                    controller: _form['phone'],
                    hint: 'XXXXXXXXXX',
                    keyboardType: TextInputType.phone,
                    fontSize: fieldFont,
                    height: fieldHeight,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (v) => _set('phone', v),
                  ),
                ),
              ],
            ),
          ),
        ]),
        const SizedBox(height: 16),
        FormGrid(columns: cols, children: [
          labeled(
            'Gender',
            AppSelect<String>(
              value: '${form['gender'] ?? ''}'.isEmpty ? null : '${form['gender']}',
              placeholder: 'Select gender',
              fontSize: fieldFont ?? 14,
              height: fieldHeight ?? 36,
              items: const [
                AppSelectItem('male', 'Male'),
                AppSelectItem('female', 'Female'),
                AppSelectItem('other', 'Other'),
              ],
              onChanged: (v) => _set('gender', v),
            ),
          ),
          labeled(
            'DOB',
            scaled(AppDateField(
              value: '${form['dob'] ?? ''}',
              onChanged: (v) => _set('dob', v),
            )),
          ),
        ]),
        const SizedBox(height: 16),
        labeled(
          'Photo',
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              scaled(FileInputField(
                fileName: photo is UploadFile ? photo.name : null,
                onTap: _onPhotoChange,
              )),
              // `<div class="mt-2"><img class="w-20 h-20 object-cover rounded-md">`
              // (FormItem's gap-2 + mt-2).
              if (photo is UploadFile) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: UploadPreview(file: photo, width: 80, height: 80),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        FormGrid(columns: cols, children: [
          labeled(
            'Password',
            required: true,
            _PasswordField(
              controller: _form['password'],
              hint: 'Enter password',
              fontSize: fieldFont,
              height: fieldHeight,
              onChanged: (v) => _set('password', v),
            ),
          ),
          labeled(
            'Confirm Password',
            required: true,
            _PasswordField(
              controller: _form['confirmpassword'],
              hint: 'Enter Confirm password',
              fontSize: fieldFont,
              height: fieldHeight,
              onChanged: (v) => _set('confirmpassword', v),
            ),
          ),
          // `<div class="mt-2"><FormItem><Label>Designation:</Label>` — no
          // 1600px classes, so it keeps the default size.
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: AppTextField(
              controller: _form['designation'],
              label: 'Designation:',
              hint: 'Enter Designation',
              onChanged: (v) => _set('designation', v),
            ),
          ),
        ]),
        // Card `gap-6` + the button row's `mt-5`.
        const SizedBox(height: 24 + 20),
        Align(
          alignment: Alignment.centerRight,
          // `min-[1600px]:text-2xl! min-[1600px]:p-7` (56px tall).
          child: AppButton(
            onPressed: _submitForm,
            height: huge ? 56 : null,
            padding: huge ? const EdgeInsets.symmetric(horizontal: 28) : null,
            fontSize: huge ? 24 : null,
            child: _isCreateBtnLoading
                ? _SpinningIcon(BootstrapIcons.arrow_repeat, size: huge ? 24 : 14)
                : const Text('Create'),
          ),
        ),
      ],
    );

    return LoadingOverlay(
      loading: _isLoading,
      child: SingleChildScrollView(
        child: Padding(
          // `m-2`
          padding: const EdgeInsets.all(8),
          // `<Card class="m-2 px-5">`: py-6, gap-6.
          child: ShadCard(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'User Create',
                  style: TextStyle(
                    fontSize: huge ? 30 : 20,
                    height: huge ? 36 / 30 : 28 / 20,
                    fontWeight: FontWeight.w600,
                    color: context.colors.primary,
                  ),
                ),
                // `mb-5` + the card's gap-6.
                const SizedBox(height: 20 + 24),
                body,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The password inputs: `<div class="relative"><Input :type>` with the
/// `bi-eye` / `bi-eye-slash` toggle (`absolute right-3 text-gray-500`, 16px).
/// A local copy of [PasswordInput] that also takes the 1600px size.
class _PasswordField extends StatefulWidget {
  const _PasswordField({
    required this.controller,
    required this.hint,
    this.onChanged,
    this.fontSize,
    this.height,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final double? fontSize;
  final double? height;

  @override
  State<_PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<_PasswordField> {
  bool _show = false;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: widget.controller,
      hint: widget.hint,
      obscureText: !_show,
      onChanged: widget.onChanged,
      fontSize: widget.fontSize,
      height: widget.height,
      suffix: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => setState(() => _show = !_show),
          child: Icon(_show ? BootstrapIcons.eye_slash : BootstrapIcons.eye, size: 16, color: Tw.gray500),
        ),
      ),
    );
  }
}

/// `<i class="bi bi-arrow-repeat animate-spin" />`
class _SpinningIcon extends StatefulWidget {
  const _SpinningIcon(this.icon, {this.size = 14});
  final IconData icon;

  /// The button's `text-sm` (14px).
  final double size;

  @override
  State<_SpinningIcon> createState() => _SpinningIconState();
}

class _SpinningIconState extends State<_SpinningIcon> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(seconds: 1))
    ..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, child) => Transform.rotate(angle: _c.value * 2 * math.pi, child: child),
        child: Icon(widget.icon, size: widget.size),
      );
}
