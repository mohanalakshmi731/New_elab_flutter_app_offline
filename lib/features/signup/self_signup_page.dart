import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/files.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/services/js_compat.dart';
import '../../router/app_router.dart';
import '../../widgets/app_button.dart';
import '../common/lookups.dart';
import 'signup_controller.dart';
import 'signup_payloads.dart';
import 'signup_widgets.dart';

/// Port of `src/pages/Institute/selfsignup.vue` (`/selfsignup`).
///
/// [code] is the `?code=` query parameter the web reads from
/// `window.location.search` to pre-fill the "Code" field.
class SelfSignupPage extends ConsumerStatefulWidget {
  const SelfSignupPage({super.key, this.code});
  final String? code;

  @override
  ConsumerState<SelfSignupPage> createState() => _SelfSignupPageState();
}

class _SelfSignupPageState extends ConsumerState<SelfSignupPage> {
  int _step = 1;
  bool _submitting = false;

  // ── signupform — Step 1 ──
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _phoneCode = TextEditingController();
  final _code = TextEditingController();
  final _website = TextEditingController();
  final _city = TextEditingController();
  final _address = TextEditingController();
  final _address2 = TextEditingController();
  final _pincode = TextEditingController();
  Object? _country; // '' on the web until a country is picked
  Object? _stateId;
  UploadFile? _logo;
  Uint8List? _logoPreview;

  // ── Step 2 (read-only, filled from the invitation code) ──
  final _name2 = TextEditingController();
  final _email2 = TextEditingController();
  final _phone2 = TextEditingController();
  final _designation = TextEditingController();

  /// The raw values (`null` stays `null` like the web's v-model data).
  Object? _email2Value = '';
  Object? _phone2Value = '';
  Object? _designationValue = '';

  List<TextEditingController> get _controllers => [
        _name,
        _email,
        _phone,
        _phoneCode,
        _code,
        _website,
        _city,
        _address,
        _address2,
        _pincode,
        _name2,
        _email2,
        _phone2,
        _designation,
      ];

  @override
  void initState() {
    super.initState();
    final codeFromUrl = widget.code;
    if (codeFromUrl != null && codeFromUrl.isNotEmpty) _code.text = codeFromUrl;
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

  /// watch 'signupform.country' (`c.id == id`, no reset when not found).
  void _onCountryChanged(Object? id, List<Map<String, dynamic>> countries) {
    setState(() => _country = id);
    for (final c in countries) {
      if ('${c['id']}' == '$id') {
        _phoneCode.text = '+${c['phone_code']}';
        return;
      }
    }
  }

  /// `handleFile(event)`: only images up to 300×200 px are accepted.
  Future<void> _handleFile() async {
    final file = await pickImageFile();
    if (file == null) return;
    Uint8List bytes;
    int width;
    int height;
    try {
      bytes = await readUploadBytes(file);
      final image = await _decode(bytes);
      width = image.width;
      height = image.height;
      image.dispose();
    } catch (_) {
      // Not a decodable image: the web's `img.onload` never fires.
      return;
    }
    if (!mounted) return;
    if (width > 300 || height > 200) {
      AppToast.error('Logo must be max 300px width and 200px height');
      setState(() {
        _logo = null;
        _logoPreview = null;
      });
      return;
    }
    setState(() {
      _logo = file;
      _logoPreview = bytes;
    });
  }

  static Future<ui.Image> _decode(Uint8List bytes) async {
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    codec.dispose();
    return frame.image;
  }

  Future<void> _nextStep() async {
    if (_step != 1) return;
    if (!jsTruthy(_name.text) ||
        !jsTruthy(_email.text) ||
        !jsTruthy(_phone.text) ||
        !jsTruthy(_stateId) ||
        !jsTruthy(_code.text) ||
        !jsTruthy(_country)) {
      AppToast.error('Please fill all required fields!');
      return;
    }

    try {
      final data = await ref.read(signupControllerProvider.notifier).fetchInstituteByCode(_code.text);
      final user = asMap(asMap(data)?['user']);
      if (user == null) throw StateError('data.user is undefined');
      if (!mounted) return;
      setState(() {
        _name2.text = '${jsTemplateValue(user, 'first_name')} ${jsTemplateValue(user, 'last_name')}';
        _email2Value = user['email'];
        _phone2Value = user['phone'];
        _designationValue = user['designation'];
        _email2.text = _display(_email2Value);
        _phone2.text = _display(_phone2Value);
        _designation.text = _display(_designationValue);
        // ✅ MOVE TO STEP 2
        _step = 2;
      });
    } catch (_) {
      AppToast.error('Invalid Code or API failed');
    }
  }

  /// `<Input v-model>` shows `null` / `undefined` as an empty field.
  static String _display(Object? v) => v == null ? '' : '$v';

  void _prevStep() {
    if (_step > 1) setState(() => _step--);
  }

  Map<String, dynamic> get _signupform => {
        'name': _name.text,
        'email': _email.text,
        'phone': _phone.text,
        'logo': _logo,
        'state_id': _stateId,
        'phone_code': _phoneCode.text,
        'code': _code.text,
        'website': _website.text,
        'country': _country ?? '',
        'city': _city.text,
        'address': _address.text,
        'address2': _address2.text,
        'pincode': _pincode.text,
        'name2': _name2.text,
        'email2': _email2Value,
        'phone2': _phone2Value,
        'designation': _designationValue,
      };

  void _resetForm() {
    for (final c in _controllers) {
      c.clear();
    }
    _country = null;
    _stateId = null;
    _logo = null;
    _logoPreview = null;
    _email2Value = '';
    _phone2Value = '';
    _designationValue = '';
    _step = 1;
  }

  Future<void> _submitForm() async {
    if (_submitting) return;
    _submitting = true;
    try {
      final ctrl = ref.read(signupControllerProvider.notifier);
      ctrl.setSignupInstitute({..._signupform, 'image': _logo});
      await ctrl.signupform();
      AppToast.success('Form submitted successfully!');
      if (!mounted) return;
      setState(_resetForm);
      context.go(AppRoutes.loginPath);
    } catch (_) {
      // API errors are already toasted by the ApiClient interceptor.
    } finally {
      _submitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = context.screenWidth;
    final sm = context.isSm;
    // `px-[10%] py-[10%] sm:px-[5%] sm:py-[7%]` (percentages of the width)
    // and `pt-2 md:pt-0` on the centre area.
    final padding = EdgeInsets.fromLTRB(
      width * (sm ? 0.05 : 0.10),
      width * (sm ? 0.07 : 0.10) + (context.isMd ? 0 : 8),
      width * (sm ? 0.05 : 0.10),
      width * (sm ? 0.07 : 0.10),
    );
    return SignupBackground(
      scrollWholePage: true,
      footer: const SignupFooter(),
      child: Center(
        child: Padding(
          padding: padding,
          child: ConstrainedBox(
            // The web card shrink-wraps its two-column grid.
            constraints: const BoxConstraints(maxWidth: 820),
            child: SignupGlassCard(
              title: 'Sign Up',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_step == 1) _stepOne(),
                  if (_step == 2) _stepTwo(),
                  const SizedBox(height: 20), // mt-5
                  Row(
                    mainAxisAlignment:
                        _step == 1 ? MainAxisAlignment.end : MainAxisAlignment.spaceBetween,
                    children: [
                      if (_step > 1) AppButton(label: 'Back', onPressed: _prevStep),
                      if (_step < 2) AppButton(label: 'Next', onPressed: _nextStep),
                      if (_step == 2) AppButton(label: 'Submit', onPressed: _submitForm),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _item(String label, Widget child, {bool required = false}) =>
      GlassFormItem(label: label, required: required, starSize: 20, child: child);

  Widget _stepOne() {
    final countries = ref.watch(countriesProvider).valueOrNull ?? const [];
    final states = ref.watch(statesProvider).valueOrNull ?? const [];
    final digits = FilteringTextInputFormatter.digitsOnly;

    return SignupGrid(
      columns: context.isSm ? 2 : 1,
      children: [
        _item('Institute Name:', GlassInput(controller: _name, hint: 'Enter Institute name'),
            required: true),
        _item(
          'Institute Email:',
          GlassInput(
            controller: _email,
            hint: 'Enter Institute email',
            keyboardType: TextInputType.emailAddress,
          ),
          required: true,
        ),
        _item(
          'Institute Website URL:',
          GlassInput(controller: _website, hint: 'Enter Website URL', keyboardType: TextInputType.url),
        ),
        _item(
          'Country:',
          GlassSelect<Object>(
            value: _country,
            placeholder: 'Select Country',
            items: [
              for (final c in countries)
                if (c['id'] != null) GlassSelectItem<Object>(c['id'] as Object, '${c['name'] ?? ''}'),
            ],
            onChanged: (id) => _onCountryChanged(id, countries),
          ),
          required: true,
        ),
        _item(
          'State:',
          GlassSelect<Object>(
            value: _stateId,
            placeholder: 'Select State',
            items: [
              for (final s in states)
                if (s['id'] != null) GlassSelectItem<Object>(s['id'] as Object, '${s['name'] ?? ''}'),
            ],
            onChanged: (id) => setState(() => _stateId = id),
          ),
          required: true,
        ),
        _item('City:', GlassInput(controller: _city, hint: 'Enter City')),
        _item(
          'Phone Number:',
          LayoutBuilder(builder: (context, c) {
            // `w-[20%] lg:w-[10%] p-[1%] text-center` (still h-9).
            final style = glassInputTextStyle(context);
            final line = style.fontSize! * style.height!;
            return Row(
              children: [
                SizedBox(
                  width: c.maxWidth * (context.isLg ? 0.10 : 0.20),
                  child: GlassInput(
                    controller: _phoneCode,
                    hint: 'code',
                    readOnly: true,
                    textAlign: TextAlign.center,
                    contentPadding: EdgeInsets.symmetric(horizontal: c.maxWidth * 0.01, vertical: (36 - line) / 2),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: GlassInput(
                    controller: _phone,
                    hint: 'Phone Number',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [digits, LengthLimitingTextInputFormatter(10)],
                  ),
                ),
              ],
            );
          }),
          required: true,
        ),
        _item('Code:', GlassInput(controller: _code, hint: 'Enter Code'), required: true),
        _item(
          'Pin Code:',
          GlassInput(
            controller: _pincode,
            hint: 'Enter Pin Code',
            keyboardType: TextInputType.number,
            inputFormatters: [digits, LengthLimitingTextInputFormatter(6)],
          ),
        ),
        // `<Textarea class="h-[5px] resize-none">`: held at `min-h-16`.
        _item('Address:',
            GlassInput(controller: _address, hint: 'Enter Address', textarea: true, fixedTextareaHeight: 64)),
        _item('Address 2:',
            GlassInput(controller: _address2, hint: 'Enter Address 2', textarea: true, fixedTextareaHeight: 64)),
        _item('Institute Logo:', _FilePickerField(fileName: _logo?.name, onTap: _handleFile)),
        if (_logoPreview != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: SizedBox(
              height: 100,
              child: Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 300, maxHeight: 100),
                  child: Image.memory(_logoPreview!, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _stepTwo() {
    return SignupGrid(
      columns: context.isSm ? 2 : 1,
      children: [
        _item('Name:', GlassInput(controller: _name2, hint: 'Enter Name', readOnly: true)),
        _item('Email:', GlassInput(controller: _email2, hint: 'Enter Email', readOnly: true)),
        _item('Phone Number:', GlassInput(controller: _phone2, readOnly: true)),
        _item('Designation:', GlassInput(controller: _designation, hint: 'Enter Designation', readOnly: true)),
      ],
    );
  }
}

/// `<Input type="file">` inside `.glass-cards`: the glass input (white
/// "No file chosen") with the kit's `file:text-foreground file:text-sm
/// file:font-medium` "Choose File" button, which keeps the dark foreground.
class _FilePickerField extends StatelessWidget {
  const _FilePickerField({required this.fileName, required this.onTap});
  final String? fileName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: InputDecorator(
          decoration: glassInputDecoration(context),
          child: Row(
            children: [
              const Text('Choose File',
                  style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: AppColors.foreground)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  fileName ?? 'No file chosen',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: glassInputTextStyle(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
