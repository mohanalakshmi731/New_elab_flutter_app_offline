import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/files.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart';
import '../common/lookups.dart';
import 'users_controller.dart';
import 'users_logic.dart';
import 'users_widgets.dart';

/// Port of `src/pages/user/UserProfile.vue` — `/MyProfile` (eLabs shell) and
/// `/newlayout/MyProfile` (MathZoro shell). The web template does not branch
/// on the layout; it only shows the institution / Zoom cards to institutes.
///
/// `userForm` and `passwordForm` are the shared store forms
/// ([UsersState.userForm] / [UsersState.passwordForm]); the institution and
/// Zoom forms are component state.
class UserProfilePage extends ConsumerStatefulWidget {
  const UserProfilePage({super.key});

  @override
  ConsumerState<UserProfilePage> createState() => _UserProfilePageState();
}

String _or(Object? v) => jsTruthy(v) ? '$v' : '';

class _UserProfilePageState extends ConsumerState<UserProfilePage> {
  // ── data() ──────────────────────────────────────────────────────────────
  // `hasScopeErrors`, `showManifest`, `missingScopesFromValidation` and
  // `clientEventsTable` are written by the web but never rendered or read,
  // so they are not ported.
  List<ZoomScopeRow> _clientScopesTable = const [];
  List<ZoomManifestRow> _manifestTable = const [];
  bool _zoomConfigFetched = false;

  /// `isLoading` — a counter so overlapping loads keep the overlay up.
  int _busy = 0;

  // instituteForm
  Object _instituteId = '';
  String _instituteState = '';
  String _logoPreview = '';
  UploadFile? _logoPreviewFile;
  String? _logoInputName;
  int? _countryId;
  UploadFile? _logo;
  String _address2 = '';
  final _inst = {
    for (final k in ['name', 'email', 'phone', 'phone_code', 'website', 'address', 'city', 'pincode'])
      k: TextEditingController(),
  };

  // zoomForm
  bool _zoomEnabled = false;
  final _zoom = {
    for (final k in [
      'account_id',
      'client_id',
      'client_secret',
      'client_app_id',
      'meeting_client_id',
      'meeting_client_secret',
      'meeting_app_id',
      'access_token',
    ])
      k: TextEditingController(),
  };

  late final MapTextBinding _userForm =
      MapTextBinding(const ['firstName', 'designation', 'email', 'phone'], ref.read(usersControllerProvider).userForm);
  late final MapTextBinding _passwordForm =
      MapTextBinding(const ['oldPassword', 'newPassword'], ref.read(usersControllerProvider).passwordForm);

  UsersController get _ctrl => ref.read(usersControllerProvider.notifier);
  UsersState get _state => ref.read(usersControllerProvider);
  bool get _isLoading => _busy > 0;

  /// `zoomDataExists`
  bool get _zoomDataExists => _zoomConfigFetched;

  @override
  void initState() {
    super.initState();
    Future.microtask(_mounted);
  }

  @override
  void dispose() {
    _userForm.dispose();
    _passwordForm.dispose();
    for (final c in [..._inst.values, ..._zoom.values]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<T> _loading<T>(Future<T> Function() fn) async {
    if (mounted) setState(() => _busy++);
    try {
      return await fn();
    } finally {
      if (mounted) setState(() => _busy--);
    }
  }

  // ── mounted() ───────────────────────────────────────────────────────────

  /// Loads everything in parallel; the Zoom pre-check only runs when all of
  /// them succeeded (`Promise.all` rejecting skips it — e.g. for roles
  /// without an institute, where `institute.id` throws).
  Future<void> _mounted() => _loading(() async {
        try {
          await Future.wait([
            _loadUserData(),
            _loadInstituteData(),
            _fetchDialCodes(),
            _ctrl.loadCountries(),
            _ctrl.loadStates(),
          ]);
          await _tryLoadZoomDetails();
        } catch (_) {
          // 'Failed to initialize profile page' (console only on the web).
        }
      });

  Future<void> _fetchDialCodes() => _loading(_ctrl.loadUserDialCodes);

  Future<void> _loadUserData() => _loading(() async {
        final user = await _ctrl.getUserById();
        if (jsTruthy(user)) {
          final u = asMap(user) ?? const {};
          _ctrl.patchUserForm({
            'firstName': _or(u['first_name']),
            'lastName': _or(u['last_name']),
            'email': _or(u['email']),
            'phone': _or(u['phone']),
            'countryCode': _or(u['country_code']),
            'designation': _or(u['designation']),
          });
        }
      });

  Future<void> _loadInstituteData() => _loading(() async {
        final institute = await _ctrl.profilegetInstituteById();
        // `this.instituteForm.id = institute.id` throws for a null institute.
        if (institute == null) throw StateError("Cannot read properties of null (reading 'id')");
        final m = asMap(institute) ?? const {};
        if (!mounted) return;
        final previousCountry = _countryId;
        setState(() {
          _instituteId = jsTruthy(m['id']) ? m['id'] as Object : '';
          _inst['name']!.text = _or(m['name']);
          _inst['email']!.text = _or(m['email']);
          _inst['phone']!.text = _or(m['phone']);
          _inst['website']!.text = _or(m['institute_website']);
          _inst['address']!.text = _or(m['address']);
          _instituteState = _or(m['state_id']);
          _logoPreview = _or(m['logo']);
          _logoPreviewFile = null;
          _inst['city']!.text = _or(m['city']);
          _inst['pincode']!.text = _or(m['pincode']);
          _address2 = _or(m['address2']);
          final country = asInt(m['country']);
          _countryId = country == 0 ? null : country;
          _inst['phone_code']!.text = _or(m['country_code']);
          // watch: 'instituteForm.country_id' (runs after the assignments).
          if (_countryId != previousCountry) _onCountryChanged(_countryId);
        });
      });

  /// `watch['instituteForm.country_id']`
  void _onCountryChanged(int? id) {
    final countries = ref.read(countriesProvider).valueOrNull ?? const [];
    for (final c in countries) {
      if ('${c['id']}' == '$id') {
        _inst['phone_code']!.text = '+${c['phone_code']}';
        return;
      }
    }
  }

  // ── institution ─────────────────────────────────────────────────────────

  /// `handleLogoUpload` — max 300×200 px.
  Future<void> _handleLogoUpload() async {
    final file = await pickImageFile();
    if (file == null) return;
    final int width;
    final int height;
    try {
      final image = await decodeImageFromList(await readUploadBytes(file));
      width = image.width;
      height = image.height;
      image.dispose();
    } catch (_) {
      return; // not an image: the web's img.onload never fires
    }
    if (!mounted) return;
    if (width > 300 || height > 200) {
      AppToast.error('Logo must be max 300px width and 200px height');
      setState(() {
        _logoInputName = null;
        _logo = null;
      });
      return;
    }
    setState(() {
      _logoInputName = file.name;
      _logo = file;
      _logoPreviewFile = file;
    });
  }

  Future<void> _updateInstituteData() => _loading(() async {
        try {
          final formPayload = <String, dynamic>{
            'id': _instituteId,
            'name': _inst['name']!.text,
            'email': _inst['email']!.text,
            'phone': _inst['phone']!.text,
            'phone_code': _inst['phone_code']!.text,
            'website': _inst['website']!.text,
            'country': _countryId,
            'address': _inst['address']!.text,
            'address2': _address2,
            'state_id': _instituteState,
            'city': _inst['city']!.text,
            'pincode': _inst['pincode']!.text,
            'image': _logo,
          };
          await _ctrl.updateInstituteDetails(_instituteId, formPayload);
          await _loadInstituteData();
        } catch (_) {
          // 'Failed to update institute' (console only on the web).
        }
      });

  // ── zoom ────────────────────────────────────────────────────────────────

  Future<void> _tryLoadZoomDetails() async {
    try {
      final res = await _ctrl.fetchZoomInfo();
      if (jsTruthy(asMap(res)?['zoom_config'])) {
        if (mounted) setState(() => _zoomConfigFetched = true);
        await _loadZoomDetails();
      } else if (mounted) {
        setState(() => _zoomConfigFetched = false);
      }
    } catch (_) {
      // 'Zoom pre-check failed'
    }
  }

  /// Toasts [message] unless the API client already showed the same text.
  void _toastSuccess(dynamic res, String message) {
    if (asMap(res)?['message'] != message) AppToast.success(message);
  }

  Future<void> _handleZoomAutoFix() => _loading(() async {
        try {
          final res = await _ctrl.zoomautofix();
          _toastSuccess(res, 'Zoom auto fix completed');
          await _loadZoomDetails();
        } catch (_) {
          // Unhandled on the web; the API client showed the error.
        }
      });

  void _copySingleScope(String name) {
    Clipboard.setData(ClipboardData(text: name)).catchError((_) {});
    AppToast.success('Scope copied to clipboard');
  }

  Future<void> _refreshZoomInfos() => _loading(() async {
        try {
          final res = await _ctrl.refreshZoomInfo();
          await _loadZoomDetails();
          _toastSuccess(res, 'Zoom restarted and synced');
        } catch (_) {
          // 'Refresh failed'
        }
      });

  Future<void> _loadZoomDetails() => _loading(() async {
        try {
          final res = await _ctrl.fetchZoomInfo();
          if (res == null) return; // `res.zoom_config` throws on the web
          final details = buildZoomDetails(asMap(res) ?? const {});
          if (!mounted) return;
          setState(() {
            final config = details.config;
            if (config != null) {
              _zoomEnabled = true;
              _zoomConfigFetched = true;
              for (final k in ['account_id', 'client_id', 'client_app_id', 'meeting_app_id', 'meeting_client_id']) {
                _zoom[k]!.text = _or(config[k]);
              }
            }
            _clientScopesTable = details.scopes;
            _manifestTable = details.manifest;
          });
        } catch (_) {
          // 'ZOOM INFO LOAD FAILED'
        }
      });

  Future<void> _saveZoomSettings() => _loading(() async {
        try {
          setState(() => _clientScopesTable = const []);
          final payload = {
            'account_id': _zoom['account_id']!.text,
            'client_id': _zoom['client_id']!.text,
            'client_secret': _zoom['client_secret']!.text,
            'client_app_id': _zoom['client_app_id']!.text,
            'meeting_app_id': _zoom['meeting_app_id']!.text,
            'meeting_client_id': _zoom['meeting_client_id']!.text,
            'meeting_client_secret': _zoom['meeting_client_secret']!.text,
            'client_app_feature_token': _zoom['access_token']!.text,
          };
          await _ctrl.validateZoomInfo(payload);
          if (mounted) setState(() => _zoomConfigFetched = true);
          await _loadZoomDetails();
        } catch (error) {
          final scopes = zoomScopesFromError(error);
          if (scopes != null && mounted) {
            setState(() {
              _zoomEnabled = true;
              _zoomConfigFetched = false;
              _clientScopesTable = [for (final s in scopes) (category: 'Client', name: s, status: false)];
            });
          }
        }
      });

  // ── user / password ─────────────────────────────────────────────────────

  Future<void> _updateUser() => _loading(() async {
        try {
          final f = _state.userForm;
          await _ctrl.updateUser(
            firstName: '${f['firstName'] ?? ''}',
            lastName: '${f['lastName'] ?? ''}',
            email: '${f['email'] ?? ''}',
            phone: '${f['phone'] ?? ''}',
            countryCode: '${f['countryCode'] ?? ''}',
            designation: '${f['designation'] ?? ''}',
          );
          // Not awaited on the web.
          _loadUserData().catchError((Object _) {});
        } catch (_) {
          // 'Failed to update user'
        }
      });

  Future<void> _handleChangePassword() async {
    final pf = _state.passwordForm;
    if ((pf['oldPassword'] ?? '').isEmpty || (pf['newPassword'] ?? '').isEmpty) {
      AppToast.error('Please enter both old and new passwords');
      return;
    }
    await _loading(() async {
      try {
        await _ctrl.changePassword();
      } catch (_) {
        AppToast.error('Error changing password');
      } finally {
        _ctrl.patchPasswordForm(const {'confirmPassword': ''});
      }
    });
  }

  // ── template ────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen<Map<String, dynamic>>(usersControllerProvider.select((s) => s.userForm), (_, next) {
      _userForm.sync(next);
    });
    ref.listen<Map<String, String>>(usersControllerProvider.select((s) => s.passwordForm), (_, next) {
      _passwordForm.sync(next);
    });
    final isInstitute = ref.watch(sessionProvider.select((s) => s.role)) == Role.institute;
    final showScopes = _clientScopesTable.isNotEmpty;
    final showManifest = (_zoomEnabled || !_zoomConfigFetched) && _clientScopesTable.isNotEmpty;
    const cardMargin = EdgeInsets.symmetric(horizontal: 8);

    return LoadingOverlay(
      loading: _isLoading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ShadCard(
              margin: cardMargin,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(child: _heading(context, 'Profile Update', size: 24)),
                  const SizedBox(height: 4 + 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _userDetailsCard(context),
                        if (isInstitute) ...[const SizedBox(height: 24), _institutionCard(context)],
                        const SizedBox(height: 24),
                        _changePasswordCard(context),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isInstitute) ...[const SizedBox(height: 24), _zoomSettingsCard(context, cardMargin)],
            if (showScopes) ...[const SizedBox(height: 24), _zoomScopesCard(context, cardMargin)],
            if (showManifest) ...[const SizedBox(height: 24), _manifestCard(context, cardMargin)],
          ],
        ),
      ),
    );
  }

  /// `text-xl font-semibold text-primary` (`text-2xl` for the page title).
  Widget _heading(BuildContext context, String text, {double size = 20}) => Text(
        text,
        style: TextStyle(
          fontSize: size,
          height: (size == 24 ? 32 : 28) / size,
          fontWeight: FontWeight.w600,
          color: context.colors.primary,
        ),
      );

  /// An inner `<Card class="m-2 px-5 dark:border-(--border-color)">` with the
  /// `mb-5` heading and the card's `gap-6`.
  Widget _innerCard(String title, List<Widget> children, {EdgeInsetsGeometry margin = EdgeInsets.zero}) {
    return ShadCard(
      margin: margin,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      darkBorderColor: AppColors.sidebarText,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _heading(context, title),
          const SizedBox(height: 20 + 24),
          ...children,
        ],
      ),
    );
  }

  int get _cols => context.isSm ? 2 : 1;

  Widget _endButton(String label, VoidCallback onPressed) =>
      Align(alignment: Alignment.centerRight, child: AppButton(label: label, onPressed: onPressed));

  Widget _disabledInput(String label, TextEditingController c, String hint) => LabeledField(
        label: label,
        child: DisabledLook(child: AppTextField(controller: c, hint: hint, readOnly: true)),
      );

  Widget _userDetailsCard(BuildContext context) {
    final s = ref.watch(usersControllerProvider);
    final form = s.userForm;
    final codes = s.dailCodes;
    return _innerCard('User details', [
      FormGrid(columns: _cols, children: [
        AppTextField(
          controller: _userForm['firstName'],
          label: 'Full Name',
          hint: 'First name',
          onChanged: (v) => _ctrl.patchUserForm({'firstName': v}),
        ),
        AppTextField(
          controller: _userForm['designation'],
          label: 'Designation',
          hint: 'e.g., Senior Developer, Manager, Professor',
          onChanged: (v) => _ctrl.patchUserForm({'designation': v}),
        ),
      ]),
      const SizedBox(height: 24),
      FormGrid(columns: _cols, children: [
        _disabledInput('Email', _userForm['email'], 'Email'),
        LabeledField(
          label: 'Phone',
          child: LayoutBuilder(builder: (context, c) {
            // `sm:w-[18%] md:w-[25%] lg:w-[20%]`; below sm the kit's `w-fit`
            // sizes the trigger to the shown code (or the "+91" placeholder).
            final pct = context.isLg ? 0.20 : context.isMd ? 0.25 : context.isSm ? 0.18 : null;
            String shown = '+91';
            for (final code in codes) {
              if ('${code['code']}'.replaceFirst('+', '') == '${form['countryCode']}') shown = '${code['code']}';
            }
            final width = pct == null ? _fitSelectWidth(context, shown) : (c.maxWidth * pct).clamp(56.0, double.infinity);
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (codes.isNotEmpty) ...[
                  SizedBox(
                    width: width,
                    child: AppSelect<String>(
                      value: form['countryCode'] == null ? null : '${form['countryCode']}',
                      placeholder: '+91',
                      items: [
                        for (final code in codes)
                          AppSelectItem('${code['code']}'.replaceFirst('+', ''), '${code['code']}'),
                      ],
                      onChanged: (v) => _ctrl.patchUserForm({'countryCode': v}),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: AppTextField(
                    controller: _userForm['phone'],
                    hint: 'XXXXXXXXXX',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    onChanged: (v) => _ctrl.patchUserForm({'phone': v}),
                  ),
                ),
              ],
            );
          }),
        ),
      ]),
      const SizedBox(height: 24),
      _endButton('Update User', _updateUser),
    ]);
  }

  /// A `w-fit` select trigger: `px-3` + text-sm value + `gap-2` + chevron + border.
  double _fitSelectWidth(BuildContext context, String text) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: DefaultTextStyle.of(context).style.copyWith(fontSize: 14)),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    final w = tp.width;
    tp.dispose();
    return (24 + w + 8 + 16 + 2).ceilToDouble();
  }

  Widget _institutionCard(BuildContext context) {
    final countries = ref.watch(countriesProvider).valueOrNull ?? const [];
    final states = ref.watch(statesProvider).valueOrNull ?? const [];
    return _innerCard('Institution Details', [
      FormGrid(columns: _cols, children: [
        AppTextField(controller: _inst['name'], label: 'Name', hint: 'Enter Name'),
        _disabledInput('Email', _inst['email']!, 'Enter Email'),
        AppTextField(controller: _inst['website'], label: 'Website', hint: 'Enter Website'),
        // `disabled:bg-slate-50 disabled:opacity-50` (`dark:bg-input/30` wins in dark mode).
        AppSelect<int>(
          label: 'Country',
          enabled: false,
          fillColor: context.isDark ? null : Tw.slate50,
          value: _countryId,
          placeholder: 'Select Country',
          items: [
            for (final c in countries)
              if (asInt(c['id']) != null) AppSelectItem(asInt(c['id'])!, '${c['name'] ?? ''}'),
          ],
          onChanged: (v) {
            final previous = _countryId;
            setState(() => _countryId = v);
            if (v != previous) _onCountryChanged(v);
          },
        ),
        AppSelect<String>(
          label: 'State',
          enabled: false,
          fillColor: context.isDark ? null : Tw.slate50,
          value: _instituteState,
          placeholder: 'Select State',
          items: [for (final st in states) AppSelectItem('${st['id']}', '${st['name'] ?? ''}')],
          onChanged: (v) => setState(() => _instituteState = v ?? ''),
        ),
        AppTextField(controller: _inst['city'], label: 'City', hint: 'Enter City'),
        LabeledField(
          label: 'Phone',
          child: LayoutBuilder(builder: (context, c) {
            // A readonly shadcn `<Input class="w-[20%] lg:w-[10%] p-[1%]
            // text-center">` (h-9; `p-[1%]` replaces px-3 py-1).
            final width = (c.maxWidth * (context.isLg ? 0.10 : 0.20)).clamp(44.0, double.infinity);
            final style = appInputTextStyle(context);
            final line = style.fontSize! * style.height!;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: width,
                  child: TextField(
                    controller: _inst['phone_code'],
                    readOnly: true,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    style: style,
                    decoration: InputDecoration(
                      hintText: 'code',
                      hintStyle: style.copyWith(color: AppColors.placeholder),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: c.maxWidth * 0.01,
                        vertical: ((36 - line) / 2).clamp(0.0, 18.0),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextField(
                    controller: _inst['phone'],
                    hint: 'XXXXXXXXXX',
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
        AppTextField(
          controller: _inst['pincode'],
          label: 'Pin Code:',
          hint: 'Enter Pin Code',
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(6),
          ],
        ),
        GridSpan(
          child: LabeledField(
            label: 'Address',
            child: _PlainTextarea(controller: _inst['address']!, hint: 'Enter Address'),
          ),
        ),
        GridSpan(
          child: LabeledField(
            label: 'Logo',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FileInputField(fileName: _logoInputName, onTap: _handleLogoUpload),
                if (_logoPreviewFile != null || _logoPreview.isNotEmpty) ...[
                  // FormItem `gap-2` + the image's `mt-3`.
                  const SizedBox(height: 8 + 12),
                  _LogoPreview(file: _logoPreviewFile, url: _logoPreview),
                ],
              ],
            ),
          ),
        ),
      ]),
      const SizedBox(height: 16),
      _endButton('Update Institute', _updateInstituteData),
    ]);
  }

  Widget _changePasswordCard(BuildContext context) {
    return _innerCard('Change Password', [
      FormGrid(columns: _cols, children: [
        LabeledField(
          label: 'Old Password',
          child: PasswordInput(
            controller: _passwordForm['oldPassword'],
            hint: 'Enter old password',
            onChanged: (v) => _ctrl.patchPasswordForm({'oldPassword': v}),
          ),
        ),
        LabeledField(
          label: 'New Password',
          child: PasswordInput(
            controller: _passwordForm['newPassword'],
            hint: 'Enter new password',
            onChanged: (v) => _ctrl.patchPasswordForm({'newPassword': v}),
          ),
        ),
      ]),
      const SizedBox(height: 16),
      _endButton('Change Password', _handleChangePassword),
    ]);
  }

  /// The outer-level cards (`<Card class="m-2 px-5 mt-6">`).
  Widget _outerCard(EdgeInsetsGeometry margin, Widget header, List<Widget> children) => ShadCard(
        margin: margin,
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [header, const SizedBox(height: 20 + 24), ...children],
        ),
      );

  Widget _zoomSettingsCard(BuildContext context, EdgeInsetsGeometry margin) {
    Widget field(String key, String label, String hint) => LabeledField(
          label: label,
          child: DisabledLook(
            disabled: _zoomConfigFetched,
            child: AppTextField(controller: _zoom[key], hint: hint, readOnly: _zoomConfigFetched),
          ),
        );

    final fields = [
      field('account_id', 'Account ID', 'Enter Account ID'),
      field('client_id', 'Client ID', 'Enter Client ID'),
      field('client_secret', 'Client Secret', 'Enter Client Secret'),
      field('client_app_id', 'Client App ID', 'Enter Client App ID'),
      field('meeting_app_id', 'Meeting App ID', 'Enter Meeting App ID'),
      field('meeting_client_id', 'Meeting Client ID', 'Enter Meeting Client ID'),
      field('meeting_client_secret', 'Meeting Client Secret', 'Enter Meeting Client Secret'),
      field('access_token', 'Access Token', 'Enter Access Token'),
    ];

    return _outerCard(margin, _heading(context, 'Zoom Settings'), [
      Align(
        alignment: Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const FieldLabel('Zoom Enabled'),
            const SizedBox(height: 8),
            _ZoomSwitch(
              value: _zoomEnabled,
              onChanged: _zoomConfigFetched ? null : (v) => setState(() => _zoomEnabled = v),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16 + 24),
      if (_zoomEnabled) ...[
        for (var i = 0; i < fields.length; i++) ...[if (i > 0) const SizedBox(height: 16), fields[i]],
        const SizedBox(height: 24),
      ],
      const SizedBox(height: 20),
      if (!_zoomDataExists) _endButton('Validate Zoom INFO', _saveZoomSettings),
    ]);
  }

  Widget _zoomScopesCard(BuildContext context, EdgeInsetsGeometry margin) {
    final dark = context.isDark;
    final border = dark ? AppColors.darkBorder : AppColors.border;
    TableCell cell(Widget child, {bool header = false}) => TableCell(
          verticalAlignment: TableCellVerticalAlignment.middle,
          child: Padding(
            // style.css `thead th { padding: .5rem 1rem }` beats the th's `p-2`.
            padding: header ? const EdgeInsets.symmetric(horizontal: 16, vertical: 8) : const EdgeInsets.all(8),
            child: child,
          ),
        );
    // style.css `thead th { background: var(--primary); color:
    // var(--primary-foreground) }` hides the row's `bg-gray-100`; th is bold.
    final th = TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.bold, color: context.colors.onPrimary);
    const td = TextStyle(fontSize: 16, height: 1.5);

    return _outerCard(
      margin,
      Row(
        children: [
          Expanded(child: _heading(context, 'Zoom Scopes')),
          if (_zoomEnabled && _clientScopesTable.isNotEmpty) AppButton(label: 'Refresh', onPressed: _refreshZoomInfos),
        ],
      ),
      [
        if (_clientScopesTable.isNotEmpty)
          Table(
            border: TableBorder.all(color: border),
            columnWidths: const {0: FlexColumnWidth(1), 1: FlexColumnWidth(3), 2: FlexColumnWidth(1.2)},
            children: [
              TableRow(
                decoration: BoxDecoration(color: context.colors.primary),
                children: [
                  cell(Text('Type', style: th), header: true),
                  cell(Text('Scope Name', style: th), header: true),
                  cell(Text('Available?', style: th), header: true),
                ],
              ),
              for (final item in _clientScopesTable)
                TableRow(children: [
                  cell(Text(item.category, style: td)),
                  cell(Text(item.name, style: td)),
                  cell(Row(
                    children: [
                      // style.css `table .bi { font-size: 18px }`
                      Icon(
                        item.status ? BootstrapIcons.check_circle_fill : BootstrapIcons.x_circle_fill,
                        size: 18,
                        color: item.status ? Tw.green600 : Tw.red600,
                      ),
                      if (!item.status) ...[
                        const SizedBox(width: 8),
                        _CopyIcon(onTap: () => _copySingleScope(item.name)),
                      ],
                    ],
                  )),
                ]),
            ],
          )
        else
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 40),
            child: Text('No scope data found', textAlign: TextAlign.center, style: TextStyle(color: Tw.gray500)),
          ),
      ],
    );
  }

  Widget _manifestCard(BuildContext context, EdgeInsetsGeometry margin) {
    final failing = [for (final r in _manifestTable) if (!r.status) r];
    return _outerCard(margin, _heading(context, 'Meeting Manifest'), [
      if (failing.isNotEmpty) ...[
        for (final row in failing)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Tw.red50,
              border: Border.all(color: Tw.red300),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(BootstrapIcons.x_circle_fill, size: 18, color: Tw.red600),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${row.type} is disabled or incomplete',
                        style: const TextStyle(fontWeight: FontWeight.w600, color: Tw.red700),
                      ),
                      const Text(
                        'This manifest setting should be enabled in your Zoom Meeting App',
                        style: TextStyle(fontSize: 14, height: 20 / 14, color: Tw.red600),
                      ),
                      if (row.missing.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            'Missing Subscriptions: ${row.missing.join(', ')}',
                            style: const TextStyle(fontSize: 14, height: 20 / 14, color: Tw.red600),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        _endButton('Auto Fix', _handleZoomAutoFix),
      ] else
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Tw.green50,
            border: Border.all(color: Tw.green300),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              // An inline `<i class="text-2xl mb-2">`: a 32px line, and the
              // `mb-2` has no effect on an inline element.
              SizedBox(
                height: 32,
                child: Center(child: Icon(BootstrapIcons.check_circle_fill, size: 24, color: Tw.green700)),
              ),
              Text(
                'All manifest settings are correct',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.w600, color: Tw.green700),
              ),
            ],
          ),
        ),
    ]);
  }
}

/// The hand-made toggle (`w-11 h-6 bg-gray-200 rounded-full
/// peer-checked:bg-blue-600`). The web knob uses `peer-checked:translate-x-5`
/// on an element that is not a sibling of the checkbox, so it never moves —
/// only the track colour changes. Kept as is.
class _ZoomSwitch extends StatelessWidget {
  const _ZoomSwitch({required this.value, required this.onChanged});
  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onChanged == null ? null : () => onChanged!(!value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 44,
          height: 24,
          padding: const EdgeInsets.all(2),
          alignment: Alignment.centerLeft,
          decoration: BoxDecoration(
            color: value ? Tw.blue600 : Tw.gray200,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Container(
            width: 20,
            height: 20,
            // `shadow` (the theme's --shadow).
            decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppShadows.sm),
          ),
        ),
      ),
    );
  }
}

/// `<i class="bi bi-clipboard text-blue-600 hover:text-blue-800" title="Copy scope">`
class _CopyIcon extends StatefulWidget {
  const _CopyIcon({required this.onTap});
  final VoidCallback onTap;

  @override
  State<_CopyIcon> createState() => _CopyIconState();
}

class _CopyIconState extends State<_CopyIcon> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Copy scope',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hover = true),
        onExit: (_) => setState(() => _hover = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Icon(BootstrapIcons.clipboard, size: 18, color: _hover ? Tw.blue800 : Tw.blue600),
        ),
      ),
    );
  }
}

/// `<img :src="instituteForm.logoPreview" class="h-24 mt-3 rounded border">`
class _LogoPreview extends StatelessWidget {
  const _LogoPreview({required this.file, required this.url});
  final UploadFile? file;
  final String url;

  @override
  Widget build(BuildContext context) {
    final border = context.isDark ? AppColors.darkBorder : AppColors.border;
    final Widget image = file != null
        ? UploadPreview(file: file!, height: 96, fit: BoxFit.contain)
        : Image.network(
            url,
            height: 96,
            fit: BoxFit.contain,
            errorBuilder: (_, _, _) => const SizedBox(
              height: 96,
              width: 96,
              child: Icon(BootstrapIcons.image, size: 20),
            ),
          );
    return Container(
      decoration: BoxDecoration(border: Border.all(color: border), borderRadius: BorderRadius.circular(4)),
      child: ClipRRect(borderRadius: BorderRadius.circular(3), child: image),
    );
  }
}

/// The institution address: a plain `<textarea class="w-full border
/// rounded-md p-2" rows="3">` (not the shadcn Textarea): 16px text, no dark
/// fill, the base `outline-ring/50` focus outline.
class _PlainTextarea extends StatelessWidget {
  const _PlainTextarea({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(color: context.borderColor);
    RingInputBorder border({bool focused = false}) => RingInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: side,
          ringWidth: 2,
          ringColor: focused ? context.ringColor.withValues(alpha: 0.5) : Colors.transparent,
        );
    final style = TextStyle(fontSize: 16, height: 1.5, color: context.colors.onSurface);
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 3,
      keyboardType: TextInputType.multiline,
      style: style,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: style.copyWith(color: AppColors.placeholder),
        filled: true,
        fillColor: Colors.transparent,
        contentPadding: const EdgeInsets.all(8),
        border: border(),
        enabledBorder: border(),
        focusedBorder: border(focused: true),
      ),
    );
  }
}
