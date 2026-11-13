import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../router/app_router.dart';
import '../../widgets/app_button.dart';
import '../common/lookups.dart';
import 'signup_controller.dart';
import 'signup_payloads.dart';
import 'signup_widgets.dart';

/// Port of `src/pages/Institute/signup.vue` (`/signup` and `/signup/:code`).
///
/// [code] is the invite code (`route.params.code || route.query.code`); it
/// is sent as `code` (`signupform.institute_code`).
class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key, this.code});
  final String? code;

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  bool _isSubmitting = false;
  bool _loginEmailTouched = false;
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  int _step = 1;

  // ── signupform ──
  // Step 1 : institute
  final _name = TextEditingController();
  final _instituteEmail = TextEditingController();
  final _instituteWebsite = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  Object? _country; // '' on the web until a country is picked
  Object? _stateId;
  Object? _instituteCountryCode = '';
  String _instituteCode = '';
  // Step 2 : contact person
  final _contactFullname = TextEditingController();
  final _contactPhone = TextEditingController();
  final _contactEmail = TextEditingController();
  final _contactDesignation = TextEditingController();
  // Step 3 : user account
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirmation = TextEditingController();

  List<TextEditingController> get _controllers => [
        _name,
        _instituteEmail,
        _instituteWebsite,
        _city,
        _address,
        _contactFullname,
        _contactPhone,
        _contactEmail,
        _contactDesignation,
        _email,
        _password,
        _passwordConfirmation,
      ];

  @override
  void initState() {
    super.initState();
    // created(): invite code from the route.
    final inviteCode = widget.code;
    if (inviteCode != null && inviteCode.isNotEmpty) _instituteCode = inviteCode;
    // watch 'signupform.institute_email' → login email until it is edited.
    _instituteEmail.addListener(() {
      if (!_loginEmailTouched && _email.text != _instituteEmail.text) {
        _email.text = _instituteEmail.text;
      }
    });
    // mounted(): loadStates / loadCountries (retry if an earlier load failed).
    Future.microtask(() {
      if (!mounted) return;
      if (ref.read(statesProvider).hasError) ref.invalidate(statesProvider);
      if (ref.read(countriesProvider).hasError) ref.invalidate(countriesProvider);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  /// watch 'signupform.country'
  void _onCountryChanged(Object? id, List<Map<String, dynamic>> countries) {
    Map<String, dynamic>? country;
    for (final c in countries) {
      if (c['id'] == id || (asInt(c['id']) != null && asInt(c['id']) == asInt(id))) {
        country = c;
        break;
      }
    }
    setState(() {
      _country = id;
      _instituteCountryCode = country != null ? country['phone_code'] : '';
    });
  }

  void _nextStep() {
    if (_step == 1) {
      if (_name.text.trim().isEmpty) return AppToast.error('Institution Name is required');
      if (_instituteEmail.text.trim().isEmpty) return AppToast.error('Institution Email is required');
      if (!isValidSignupEmail(_instituteEmail.text)) {
        return AppToast.error('Please enter a valid Institution Email');
      }
      if (_country == null || _country == '') return AppToast.error('Please select a Country');
      if (_stateId == null || _stateId == '') return AppToast.error('Please select a State');
      setState(() => _step++);
    } else if (_step == 2) {
      if (_contactFullname.text.trim().isEmpty) return AppToast.error('Contact Full Name is required');
      if (_contactPhone.text.trim().isEmpty) return AppToast.error('Contact Phone is required');
      if (_contactEmail.text.trim().isEmpty) return AppToast.error('Contact Email is required');
      if (_contactDesignation.text.trim().isEmpty) {
        return AppToast.error('Contact Designation is required');
      }
      if (!isValidSignupEmail(_contactEmail.text)) {
        return AppToast.error('Please enter a valid Official Email');
      }
      setState(() {
        _step++;
        _showPassword = false;
        _showConfirmPassword = false;
      });
    }
  }

  void _prevStep() {
    if (_step > 1) setState(() => _step--);
  }

  Map<String, dynamic> get _signupform => {
        'is_mathzoro_institute': '0',
        'name': _name.text,
        'institute_email': _instituteEmail.text,
        'country': _country ?? '',
        'state_id': _stateId ?? '',
        'city': _city.text,
        'institute_country_code': _instituteCountryCode,
        'institute_phone': null,
        'address': _address.text,
        'address2': '',
        'dob': null,
        'gender': null,
        'institute_website': _instituteWebsite.text,
        'institute_code': _instituteCode,
        'contact_fullname': _contactFullname.text,
        'contact_phone': _contactPhone.text,
        'contact_email': _contactEmail.text,
        'contact_designation': _contactDesignation.text,
        'first_name': '',
        'last_name': '',
        'email': _email.text,
        'password': _password.text,
        'password_confirmation': _passwordConfirmation.text,
      };

  Future<void> _submitForm() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(signupControllerProvider.notifier).signform(_signupform);
      if (mounted) context.go(AppRoutes.loginPath);
    } catch (_) {
      // API errors are already toasted by the ApiClient interceptor.
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hPad = context.isMd ? 32.0 : (context.isSm ? 24.0 : 16.0);
    return SignupBackground(
      footer: const SignupFooter(responsive: true),
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 24),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 768), // max-w-3xl
            child: SignupGlassCard(
              title: 'Sign Up',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_step == 1) _stepInstitute(),
                  if (_step == 2) _stepContact(),
                  if (_step == 3) _stepAccount(),
                  const SizedBox(height: 20), // mt-5
                  _navButtons(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// `grid-cols-12` with `col-span-12 md:col-span-6` pairs.
  Widget _pair(Widget a, Widget b) =>
      SignupGrid(columns: context.isMd ? 2 : 1, children: [a, b]);

  // ===== STEP 1 : INSTITUTE DETAILS =====
  Widget _stepInstitute() {
    final countries = ref.watch(countriesProvider).valueOrNull ?? const [];
    final states = ref.watch(statesProvider).valueOrNull ?? const [];

    // `<Card class="bg-transparent shadow-md">`: rounded-xl, `border`
    // (--border), the theme's light shadow-md.
    final location = Container(
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 48), // Card py-6 + CardContent px-4 py-6
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppShadows.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          SignupGrid(columns: context.isMd ? 3 : 1, children: [
            GlassFormItem(
              label: 'Country',
              required: true,
              child: GlassSelect<Object>(
                value: _country,
                placeholder: 'Select Country',
                menuMaxHeight: 240,
                items: [
                  for (final c in countries)
                    if (c['id'] != null) GlassSelectItem<Object>(c['id'] as Object, '${c['name'] ?? ''}'),
                ],
                onChanged: (id) => _onCountryChanged(id, countries),
              ),
            ),
            GlassFormItem(
              label: 'State',
              required: true,
              child: GlassSelect<Object>(
                value: _stateId,
                placeholder: 'Select State',
                menuMaxHeight: 240,
                items: [
                  for (final s in states)
                    if (s['id'] != null) GlassSelectItem<Object>(s['id'] as Object, '${s['name'] ?? ''}'),
                ],
                onChanged: (id) => setState(() => _stateId = id),
              ),
            ),
            GlassFormItem(
              label: 'City',
              child: GlassInput(controller: _city, hint: 'Enter City'),
            ),
          ]),
          const SizedBox(height: 16),
          GlassFormItem(
            label: 'Address',
            child: GlassInput(controller: _address, textarea: true),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        _pair(
          GlassFormItem(
            label: 'Institution Name',
            required: true,
            child: GlassInput(controller: _name, hint: 'Enter Institute Name'),
          ),
          GlassFormItem(
            label: 'Institution Email',
            required: true,
            child: GlassInput(
              controller: _instituteEmail,
              hint: 'Enter Institute Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
        ),
        const SizedBox(height: 16),
        GlassFormItem(
          label: 'Institution Website',
          child: GlassInput(
            controller: _instituteWebsite,
            hint: 'Enter Website URL',
            keyboardType: TextInputType.url,
          ),
        ),
        // The "Mathzoro Institute" checkbox is `hidden` on the web.
        const SizedBox(height: 16),
        location,
      ],
    );
  }

  // ===== STEP 2 : CONTACT PERSON =====
  Widget _stepContact() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          'Institution Contact Details',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: AppColors.primary),
        ),
        const Padding(
          padding: EdgeInsets.only(top: 8, bottom: 16),
          child: Divider(height: 1, thickness: 1, color: AppColors.border),
        ),
        _pair(
          GlassFormItem(
            label: 'Full Name',
            required: true,
            child: GlassInput(controller: _contactFullname, hint: 'Enter Full Name'),
          ),
          GlassFormItem(
            label: 'Phone',
            required: true,
            child: GlassInput(
              controller: _contactPhone,
              hint: 'Enter Phone Number',
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        _pair(
          GlassFormItem(
            label: 'Official Email',
            required: true,
            child: GlassInput(
              controller: _contactEmail,
              hint: 'Enter Official Email',
              keyboardType: TextInputType.emailAddress,
            ),
          ),
          GlassFormItem(
            label: 'Designation',
            required: true,
            child: GlassInput(controller: _contactDesignation, hint: 'Enter Designation'),
          ),
        ),
      ],
    );
  }

  // ===== STEP 3 : USER ACCOUNT =====
  Widget _stepAccount() {
    // The form's only submit button is on this step, so Enter submits here.
    void submit(String _) => _submitForm();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        GlassFormItem(
          label: 'Login Email',
          child: GlassInput(
            controller: _email,
            hint: 'Enter Login Email',
            keyboardType: TextInputType.emailAddress,
            onChanged: (_) => _loginEmailTouched = true,
            onSubmitted: submit,
          ),
        ),
        const SizedBox(height: 16),
        GlassFormItem(
          label: 'Password',
          required: true,
          child: GlassInput(
            controller: _password,
            hint: 'Enter Password',
            password: true,
            obscured: !_showPassword,
            onToggleObscured: () => setState(() => _showPassword = !_showPassword),
            onSubmitted: submit,
          ),
        ),
        const SizedBox(height: 16),
        GlassFormItem(
          label: 'Confirm Password',
          required: true,
          child: GlassInput(
            controller: _passwordConfirmation,
            hint: 'Confirm Password',
            password: true,
            obscured: !_showConfirmPassword,
            onToggleObscured: () => setState(() => _showConfirmPassword = !_showConfirmPassword),
            onSubmitted: submit,
          ),
        ),
      ],
    );
  }

  // ===== NAVIGATION BUTTONS =====
  Widget _navButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_step > 1) AppButton(label: 'Back', onPressed: _prevStep),
        if (_step == 1) const Spacer(),
        if (_step < 3) AppButton(label: 'Next', onPressed: _nextStep),
        // `:disabled="isSubmitting"` with the `border-2 border-white
        // border-t-transparent animate-spin` ring and "Creating...".
        if (_step == 3)
          AppButton(
            onPressed: _isSubmitting ? null : _submitForm,
            child: _isSubmitting
                ? const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [BorderSpinner(), SizedBox(width: 8), Text('Creating...')],
                  )
                : const Text('Create Account'),
          ),
      ],
    );
  }
}
