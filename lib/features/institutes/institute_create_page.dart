import 'dart:async';
import 'dart:io';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/api_client.dart';
import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/files.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart';
import '../common/lookups.dart';
import 'institute_payloads.dart';
import 'institute_widgets.dart';
import 'institutes_controller.dart';
import 'invite_institution_dialog.dart';

/// Port of `src/pages/Institute/Institutecreate.vue` (`/Institutescreate`).
///
/// `instituteForm` / `invitform` are store state (they survive leaving the
/// page, e.g. via "Create user"), so they live in [InstitutesController];
/// everything from the component's `data()` lives here.
class InstituteCreatePage extends ConsumerStatefulWidget {
  const InstituteCreatePage({super.key});

  @override
  ConsumerState<InstituteCreatePage> createState() => _InstituteCreatePageState();
}

class _InstituteCreatePageState extends ConsumerState<InstituteCreatePage> {
  // ── data() ──
  String _activeTab = 'single';
  UploadFile? _bulkFile;
  UploadFile? _imageFile;
  bool _hasSearched = false;
  bool _isLoading = false;
  bool _isCreateBtnLoading = false;
  // Written like the web's data() but never displayed there either.
  // ignore: unused_field
  String _createdInstituteName = '';
  Map<String, dynamic>? _searchResult;
  List<ClassAccess> _selectedClassesWithAccess = [];

  /// Set by validation / API failures. The web never renders it (its
  /// template has no `errorMessage` binding), so neither does this port.
  // ignore: unused_field
  String _errorMessage = '';

  final _instituteSearchEmail = TextEditingController();
  final _searchResultName = TextEditingController();

  // `v-model="instituteForm.x"` text inputs.
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _address;

  Timer? _redirect;
  bool _successDialogOpen = false;

  InstitutesController get _ctrl => ref.read(institutesControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    final form = ref.read(institutesControllerProvider).instituteForm;
    _name = TextEditingController(text: asString(form['name']) ?? '');
    _email = TextEditingController(text: asString(form['email']) ?? '');
    _phone = TextEditingController(text: asString(form['phone']) ?? '');
    _address = TextEditingController(text: asString(form['address']) ?? '');
    Future.microtask(_mounted);
  }

  @override
  void dispose() {
    _redirect?.cancel();
    for (final c in [_instituteSearchEmail, _searchResultName, _name, _email, _phone, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  /// `mounted()`
  Future<void> _mounted() async {
    setState(() => _isLoading = true);
    try {
      await Future.wait([
        _ctrl.loadDialCodesForInstitute(),
        _ctrl.loadInstituteUsers(),
        _ctrl.loadInstitutePlans(),
        _ctrl.loadStates(),
        _ctrl.getAllClasses(),
      ]);
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _patch(Map<String, dynamic> patch) => _ctrl.patchInstituteForm(patch);

  /// `instituteForm.allclass` + its deep watcher.
  void _onClassesChanged(List<Object> next) {
    _patch({'allclass': next});
    final all = ref.read(institutesControllerProvider).allClasses;
    setState(() => _selectedClassesWithAccess = syncClassAccess(_selectedClassesWithAccess, next, all));
  }

  /// `openInviteDialog()` + the `invitedialog` watcher on close
  /// (`resetInviteEditor()`).
  Future<void> _openInviteDialog() async {
    _ctrl.setInvitationForm(emptyInvitation);
    await showAppDialog<void>(
      context,
      builder: (_) => InviteInstitutionDialog(
        initialTab: _activeTab,
        onTabChanged: (t) => _activeTab = t,
        bulkFile: _bulkFile,
        onBulkFileChanged: (f) => _bulkFile = f,
      ),
    );
    if (!mounted) return;
    _ctrl.setInvitationForm(emptyInvitation);
  }

  Future<void> _handleImageUpload() async {
    final file = await pickImageFile();
    if (file == null || !mounted) return;
    setState(() => _imageFile = file);
  }

  Future<void> _handleSearchInstitute() async {
    setState(() {
      _hasSearched = true;
      _errorMessage = '';
      _isCreateBtnLoading = true;
    });
    try {
      final email = _instituteSearchEmail.text;
      if (!isValidEmail(email)) {
        _errorMessage = 'Please enter a valid email address to search';
        return;
      }
      final result = await _ctrl.searchUserByEmailAction(email);
      final data = asMap(result)?['data'];
      _searchResult = jsTruthy(data) ? asMap(data) : null;
      final found = _searchResult;
      if (found != null && found['id'] != null) {
        _patch({'user_id': '${found['id']}'});
        _searchResultName.text = asString(found['full_name']) ?? '';
        _errorMessage = '';
      } else {
        _searchResult = null;
        _patch({'user_id': ''});
        _searchResultName.text = '';
        _errorMessage = 'No user found with this email address';
      }
    } catch (e) {
      _searchResult = null;
      _patch({'user_id': ''});
      _searchResultName.text = '';
      _errorMessage = ApiClient.messageOf(e, fallback: 'Failed to search user. Please try again.');
    } finally {
      if (mounted) setState(() => _isCreateBtnLoading = false);
    }
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isCreateBtnLoading = true;
      _errorMessage = '';
    });
    try {
      final form = ref.read(institutesControllerProvider).instituteForm;
      final validationError = validateInstituteForm(form);
      if (validationError != null) {
        _errorMessage = validationError;
        return;
      }
      final payload = buildCreateInstitutePayload(form, _selectedClassesWithAccess, _imageFile);
      await _ctrl.submitInstituteForm(payload);
      if (!mounted) return;

      // Read after the store reset, like the web (so it is always '').
      _createdInstituteName = asString(ref.read(institutesControllerProvider).instituteForm['name']) ?? '';
      _showSuccessDialog();
      _resetForm();
      _redirect = Timer(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        if (_successDialogOpen) Navigator.of(context, rootNavigator: true).pop();
        context.go('/instituteslist');
      });
    } catch (e) {
      _errorMessage = ApiClient.messageOf(e, fallback: 'Failed to create institute. Please try again.');
    } finally {
      if (mounted) setState(() => _isCreateBtnLoading = false);
    }
  }

  void _showSuccessDialog() {
    _successDialogOpen = true;
    showAppDialog<void>(
      context,
      builder: (ctx) => AppDialogFrame(
        title: 'Institute Created',
        description: 'Institute has been created successfully.',
        actions: [AppButton(label: 'OK', onPressed: () => Navigator.of(ctx).pop())],
      ),
    ).whenComplete(() => _successDialogOpen = false);
  }

  void _resetForm() {
    final codes = ref.read(dialCodesProvider).valueOrNull ?? const [];
    setState(() {
      _instituteSearchEmail.clear();
      _searchResult = null;
      _searchResultName.clear();
      _hasSearched = false;
      _imageFile = null;
      _errorMessage = '';
      _selectedClassesWithAccess = [];
      _name.clear();
      _email.clear();
      _phone.clear();
      _address.clear();
    });
    _patch({
      'user_id': '',
      'plan_id': '',
      'state_id': '',
      'name': '',
      'type': '',
      'client_code': '',
      'syllabus': '',
      'address': '',
      'country_code': codes.firstOrNull?['code'] ?? '',
      'phone': '',
      'email': '',
      'allclass': <Object>[],
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(institutesControllerProvider);
    final form = s.instituteForm;
    final states = ref.watch(statesProvider).valueOrNull ?? const <Map<String, dynamic>>[];
    final dialCodes = ref.watch(dialCodesProvider).valueOrNull ?? const <Map<String, dynamic>>[];
    final dark = context.isDark;
    final border = dark ? AppColors.darkBorder : AppColors.border;
    final selectedClasses = <Object>[for (final v in asList(form['allclass'])) ?v];

    // `flex justify-between flex-wrap`: the `mb-4` title and the buttons
    // (top-aligned in the stretched row).
    final header = Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.start,
      runSpacing: 0,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Create Institute',
            style: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, color: context.colors.primary),
          ),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            AppButton(label: 'Create user', onPressed: () => context.go('/userscreate')),
            AppButton(label: 'Invite Institution', onPressed: _openInviteDialog),
          ],
        ),
      ],
    );

    // `<i class="bi …">` icons take the button's 14px text size.
    final searchButton = AppButton(
      onPressed: _isCreateBtnLoading ? null : _handleSearchInstitute,
      child: _isCreateBtnLoading
          ? SpinIcon(size: 14, color: context.colors.onPrimary)
          : const Icon(BootstrapIcons.search, size: 14),
    );
    final searchInput = AppTextField(
      controller: _instituteSearchEmail,
      hint: 'Enter email to search User',
      keyboardType: TextInputType.emailAddress,
    );
    // `md:col-span-2 flex justify-center` around a content-sized FormItem
    // (the `w-full max-w-2xl` sits on the renderless FormField and is
    // dropped): the input is `sm:w-[280px]`, below 640px its `w-full`
    // resolves to Chrome's default 20-character width (≈ 216px).
    final searchBlock = LayoutBuilder(
      builder: (context, c) {
        final wanted = context.isSm ? 280.0 : 216.0;
        final inputW = c.maxWidth.isFinite && c.maxWidth - 54 < wanted ? c.maxWidth - 54 : wanted;
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const FieldLabel('Search User by Email'),
              const SizedBox(height: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [SizedBox(width: inputW, child: searchInput), const SizedBox(width: 8), searchButton],
              ),
            ],
          ),
        );
      },
    );

    final grid = FormGrid(
      twoColumns: context.isMd,
      items: [
        FormGridItem(searchBlock, fullRow: true),
        if (_hasSearched)
          FormGridItem(AppTextField(
            label: 'Admin Username',
            controller: _searchResultName,
            hint: 'No user found',
            readOnly: _searchResult != null,
            enabled: false,
          )),
        FormGridItem(AppTextField(
          label: 'Institute Name',
          controller: _name,
          hint: 'Institute Name',
          onChanged: (v) => _patch({'name': v}),
        )),
        FormGridItem(AppTextField(
          label: 'Institute Email',
          controller: _email,
          hint: 'Email',
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) => _patch({'email': v}),
        )),
        FormGridItem(LabeledField(
          label: 'Institute Phone',
          child: Row(
            children: [
              // `<Select class="w-24">` → the trigger stays `w-fit`.
              SizedBox(
                width: selectFitWidth(
                  context,
                  dialCodes.any((c) => '${c['code']}' == asString(form['country_code']))
                      ? asString(form['country_code'])!
                      : '+91',
                ),
                child: AppSelect<String>(
                  value: asString(form['country_code']),
                  placeholder: '+91',
                  items: [for (final c in dialCodes) AppSelectItem('${c['code']}', '${c['code']}')],
                  onChanged: (v) => _patch({'country_code': v}),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: AppTextField(
                  controller: _phone,
                  hint: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                  onChanged: (v) => _patch({'phone': v}),
                ),
              ),
            ],
          ),
        )),
        FormGridItem(AppTextField(
          label: 'Institute Address',
          controller: _address,
          hint: 'Address',
          onChanged: (v) => _patch({'address': v}),
        )),
        FormGridItem(AppSelect<Object>(
          label: 'State',
          value: form['state_id'] as Object?,
          placeholder: 'Select State',
          items: [
            for (final st in states)
              if (st['id'] != null) AppSelectItem(st['id'] as Object, '${st['name']}'),
          ],
          onChanged: (v) => _patch({'state_id': v}),
        )),
        FormGridItem(AppSelect<Object>(
          label: 'Subscription Plan',
          value: form['plan_id'] as Object?,
          placeholder: 'Select Plan',
          items: [
            for (final p in s.plans)
              if (p['id'] != null) AppSelectItem(p['id'] as Object, '${p['name']}'),
          ],
          onChanged: (v) => _patch({'plan_id': v}),
        )),
        FormGridItem(
          LabeledField(
            label: 'All Class',
            child: MultiSelectField<Object>(
              values: selectedClasses,
              text: selectedClassesText(selectedClasses, s.allClasses),
              isPlaceholder: !selectedClasses.any((id) => s.allClasses.any((c) => c['id'] == id)),
              items: [
                for (final c in s.allClasses)
                  if (c['id'] != null) (c['id'] as Object, '${c['name']} - ${c['syllabus']}'),
              ],
              onChanged: _onClassesChanged,
            ),
          ),
          fullRow: true,
        ),
        if (_selectedClassesWithAccess.isNotEmpty)
          FormGridItem(_classAccessControl(border), fullRow: true),
        // `w-5 h-5 accent-primary` checkbox + `<span class="text-sm">`.
        FormGridItem(LabeledCheckbox(
          value: jsTruthy(form['is_math_zoro']),
          label: 'Enable Math Zoro',
          size: 20,
          exactSize: true,
          onChanged: (v) => _patch({'is_math_zoro': v}),
        )),
      ],
    );

    final image = _imageFile;
    final logo = LabeledField(
      label: 'Institute Logo / Image',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FilePickField(onPick: _handleImageUpload, fileName: image?.name),
          if (image != null) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 80,
                height: 80,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: border),
                ),
                child: image.path != null
                    ? Image.file(File(image.path!), fit: BoxFit.cover)
                    : Image.memory(image.bytes!, fit: BoxFit.cover),
              ),
            ),
          ],
        ],
      ),
    );

    final submit = AppButton(
      expand: !context.isMd,
      onPressed: _isCreateBtnLoading ? null : _handleSubmit,
      child: _isCreateBtnLoading ? SpinIcon(size: 14, color: context.colors.onPrimary) : const Text('Create'),
    );

    // `<Card class="px-5">`: `py-6 gap-6 rounded-xl border shadow-sm`.
    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: border),
        boxShadow: AppShadows.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 24),
          grid,
          const SizedBox(height: 24),
          logo,
          const SizedBox(height: 24 + 16),
          Align(alignment: Alignment.centerRight, child: submit),
          const SizedBox(height: 16),
        ],
      ),
    );

    // `<div class="space-y-4">` with no margin of its own: the card spans
    // the content area (the shell adds the `md:pb-6`).
    return LoadingOverlay(
      loading: _isLoading,
      child: SingleChildScrollView(child: card),
    );
  }

  /// "Class Access Control" (`border rounded-md p-4 space-y-3`).
  Widget _classAccessControl(Color border) {
    final dark = context.isDark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Class Access Control',
            style: TextStyle(
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w600,
              color: dark ? context.colors.primary : Tw.gray600,
            ),
          ),
          for (final item in _selectedClassesWithAccess) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(item.className, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(width: 16),
                // A size-less `accent-primary` checkbox: Chrome's 13px box.
                LabeledCheckbox(
                  value: item.hasFullAccess,
                  label: 'Has Full Access',
                  size: 13,
                  exactSize: true,
                  onChanged: (v) => setState(() => item.hasFullAccess = v),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
