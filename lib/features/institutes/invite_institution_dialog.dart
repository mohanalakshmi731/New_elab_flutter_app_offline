import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/env.dart';
import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/files.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/html_editor.dart';
import '../common/lookups.dart';
import 'institute_payloads.dart';
import 'institute_widgets.dart';
import 'institutes_controller.dart';

/// `window.location.origin` of the web app (`WEB_APP_ORIGIN` in .env).
String get webAppOrigin => Env.webAppOrigin;

/// The `invitform` reset used by `openInviteDialog()`, `resetInviteEditor()`
/// and after a successful `sendInvite()` (`code` is left alone).
const Map<String, dynamic> emptyInvitation = {
  'first_name': '',
  'last_name': '',
  'email': '',
  'phone': '',
  'designation': '',
  'institute_plan_id': '',
  'country_code': '',
  'content': '',
};

/// The "Invite Institution" dialog of `Institutecreate.vue`: tabs
/// "User Details" (single invite + Tiptap message), "Bulk Upload" (template
/// download, `.csv/.xlsx` upload + message) and "Create invitation"
/// (code-based link).
///
/// `activeTab` and `bulkFile` are page data in the web and survive the
/// dialog closing, so they are handed in and reported back. The messages,
/// editor keys and generated link are reset whenever the dialog closes, so
/// they live here.
class InviteInstitutionDialog extends ConsumerStatefulWidget {
  const InviteInstitutionDialog({
    super.key,
    required this.initialTab,
    required this.onTabChanged,
    required this.bulkFile,
    required this.onBulkFileChanged,
  });

  final String initialTab;
  final ValueChanged<String> onTabChanged;
  final UploadFile? bulkFile;
  final ValueChanged<UploadFile?> onBulkFileChanged;

  @override
  ConsumerState<InviteInstitutionDialog> createState() => _InviteInstitutionDialogState();
}

class _InviteInstitutionDialogState extends ConsumerState<InviteInstitutionDialog> {
  late String _activeTab = widget.initialTab;
  late UploadFile? _bulkFile = widget.bulkFile;
  String _inviteMessage = '';
  String _bulkInviteMessage = '';
  int _tiptapKey = 0;
  int _bulkTiptapKey = 0;
  String _inviteLink = '';
  bool _isLoading = false;

  late final Map<String, TextEditingController> _fields;

  InstitutesController get _ctrl => ref.read(institutesControllerProvider.notifier);
  Map<String, dynamic> get _form => ref.read(institutesControllerProvider).invitform;

  @override
  void initState() {
    super.initState();
    final form = _form;
    _fields = {
      for (final k in ['code', 'first_name', 'last_name', 'email', 'phone', 'designation'])
        k: TextEditingController(text: asString(form[k]) ?? ''),
    };
  }

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// Mirrors programmatic `invitform` writes into the text fields.
  void _syncFromForm() {
    final form = _form;
    _fields.forEach((k, c) {
      final v = asString(form[k]) ?? '';
      if (c.text != v) c.text = v;
    });
  }

  void _setTab(String? tab) {
    if (tab == null) return;
    setState(() => _activeTab = tab);
    widget.onTabChanged(tab);
  }

  void _setBulkFile(UploadFile? file) {
    setState(() => _bulkFile = file);
    widget.onBulkFileChanged(file);
  }

  Future<void> _copyInviteLink() async {
    if (_inviteLink.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: _inviteLink));
    AppToast.success('Link copied to clipboard');
  }

  Future<void> _handleCreateInvitationCode() async {
    if (!jsTruthy(_form['code'])) {
      AppToast.error('Please enter the code.');
      return;
    }
    if (!jsTruthy(_form['institute_plan_id'])) {
      AppToast.error('Please select a plan.');
      return;
    }
    setState(() => _isLoading = true);
    try {
      await _ctrl.createInvitationCodeAction();
      if (!mounted) return;
      setState(() => _inviteLink = buildInviteLink(webAppOrigin, '${_form['code']}'));
    } catch (_) {
      // API client already showed the error; the web only logged it.
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleBulkFile() async {
    final file = await pickUploadFile(allowedExtensions: const ['csv', 'xlsx']);
    if (file == null || !mounted) return;
    _setBulkFile(file);
  }

  Future<void> _sendBulkInvite() async {
    final file = _bulkFile;
    if (file == null) {
      AppToast.error('Please upload file');
      return;
    }
    final cleanedContent = cleanEditorHtml(_bulkInviteMessage);
    try {
      await _ctrl.sendBulkInvitationAction({'file': file, 'content': cleanedContent});
      if (!mounted) return;
      _setBulkFile(null);
      setState(() {
        _bulkInviteMessage = '';
        _bulkTiptapKey++;
      });
    } catch (_) {}
  }

  Future<void> _downloadTemplate() async {
    try {
      final bytes = await _ctrl.downloadBulkTemplateAction();
      await saveBytesAs(bytes, 'invite_template.xlsx');
    } catch (_) {}
  }

  Future<void> _sendInvite() async {
    final form = _form;
    String trim(Object? v) => (asString(v) ?? '').trim();
    _ctrl.setInvitationForm({
      'first_name': trim(form['first_name']),
      'last_name': trim(form['last_name']),
      'email': trim(form['email']),
      'phone': trim(form['phone']),
      'country_code': '${jsOr(form['country_code'], '')}'.trim(),
      'designation': trim(form['designation']),
      'institute_plan_id': form['institute_plan_id'],
      'content': cleanEditorHtml(_inviteMessage),
    });
    _syncFromForm();
    try {
      await _ctrl.sendInvitationAction();
      if (!mounted) return;
      _ctrl.setInvitationForm(emptyInvitation);
      _syncFromForm();
      setState(() {
        _inviteMessage = '';
        _tiptapKey++;
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(institutesControllerProvider);
    final dialCodes = ref.watch(dialCodesProvider).valueOrNull ?? const <Map<String, dynamic>>[];
    final w = context.screenWidth;
    final maxWidth = responsiveDialogWidth(
      context,
      percent: (w) => w >= 1280 ? 0.6 : (w >= 768 ? 0.8 : (w >= 640 ? 0.9 : 0.95)),
    );

    final planSelect = AppSelect<Object>(
      value: s.invitform['institute_plan_id'] as Object?,
      placeholder: 'Select Plan',
      items: [
        for (final p in s.plans)
          if (p['id'] != null) AppSelectItem(p['id'] as Object, '${p['name']}'),
      ],
      onChanged: (v) => _ctrl.setInvitField('institute_plan_id', v),
    );

    final Widget tabContent = switch (_activeTab) {
      'code' => _codeTab(planSelect),
      'bulk' => _bulkTab(),
      _ => _singleTab(planSelect, s.invitform, dialCodes),
    };

    final tabs = context.isMd
        ? SectionTabs(
            tabs: const [('single', 'User Details'), ('bulk', 'Bulk Upload'), ('code', 'Create invitation')],
            value: _activeTab,
            onChanged: _setTab,
          )
        : Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Choose Section', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1)),
                const SizedBox(height: 8),
                AppSelect<String>(
                  value: _activeTab,
                  placeholder: 'Select Section',
                  items: const [
                    AppSelectItem('single', 'User Details'),
                    AppSelectItem('bulk', 'Bulk Upload'),
                    AppSelectItem('code', 'Create Invitation'),
                  ],
                  onChanged: _setTab,
                ),
              ],
            ),
          );

    // `… dark:bg-primary-foreground max-h-[90%] overflow-auto px-[3%] md:px-[2%]`
    // (the page doesn't override `sm:max-w-lg`, so it is at most 512px wide).
    return LoadingOverlay(
      loading: _isLoading,
      child: AppDialogFrame(
        maxWidth: maxWidth,
        padding: EdgeInsets.symmetric(horizontal: w * (context.isMd ? 0.02 : 0.03), vertical: 24),
        backgroundColor: context.isDark ? AppColors.darkPrimaryForeground : null,
        insetPadding: EdgeInsets.symmetric(horizontal: 16, vertical: MediaQuery.sizeOf(context).height * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(right: context.isSm ? 28 : 0),
              child: Text(
                'Invite Institution',
                textAlign: context.isSm ? TextAlign.left : TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1),
              ),
            ),
            const SizedBox(height: 16),
            tabs,
            const SizedBox(height: 8),
            tabContent,
          ],
        ),
      ),
    );
  }

  Widget _input(String key, String hint, {List<TextInputFormatter>? formatters, TextInputType? type}) =>
      AppTextField(
        controller: _fields[key],
        hint: hint,
        keyboardType: type,
        inputFormatters: formatters,
        onChanged: (v) => _ctrl.setInvitField(key, v),
      );

  Widget _codeTab(Widget planSelect) {
    final dark = context.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        const _Label('Code :'),
        const SizedBox(height: 4),
        _input('code', 'Enter Code'),
        const SizedBox(height: 24),
        // The `<Select>` follows the `<Label>` directly (no margin).
        const _Label('Subscription Plan :'),
        planSelect,
        if (_inviteLink.isNotEmpty) ...[
          const SizedBox(height: 32),
          // `mt-4 border rounded-lg p-4 bg-muted/50 space-y-2`
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: (dark ? AppColors.darkMuted : AppColors.muted).withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: dark ? AppColors.darkBorder : AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Invitation Link Generated',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1, color: context.colors.primary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    // `flex-1 text-sm font-medium` (the weight isn't
                    // available on AppTextField).
                    Expanded(
                      child: AppTextField(
                        key: ValueKey(_inviteLink),
                        initialValue: _inviteLink,
                        readOnly: true,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AppButton(label: 'Copy', variant: AppButtonVariant.secondary, onPressed: _copyInviteLink),
                  ],
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 24),
        // `<DialogFooter><Button class="w-full">` — full width at every size.
        AppButton(label: 'Create Invitation', expand: true, onPressed: _handleCreateInvitationCode),
      ],
    );
  }

  Widget _singleTab(Widget planSelect, Map<String, dynamic> form, List<Map<String, dynamic>> dialCodes) {
    Widget item(double top, List<Widget> children) => Padding(
          padding: EdgeInsets.only(top: top),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
        );

    final code = asString(form['country_code']);
    final phone = Row(
      children: [
        // `<Select class="w-24">` → the trigger stays `w-fit`.
        SizedBox(
          width: selectFitWidth(context, dialCodes.any((c) => '${c['code']}' == code) ? code! : 'code'),
          child: AppSelect<String>(
            value: code,
            placeholder: 'code',
            items: [
              for (final c in dialCodes) AppSelectItem('${c['code']}', '${c['code']}'),
            ],
            onChanged: (v) => _ctrl.setInvitField('country_code', v),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _input(
            'phone',
            'Phone Number',
            type: TextInputType.phone,
            formatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
          ),
        ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FormGrid(
          twoColumns: context.isSm,
          items: [
            FormGridItem(item(8, [
              const _Label('First name :'),
              const SizedBox(height: 4),
              _input('first_name', 'Enter First name'),
            ])),
            FormGridItem(item(8, [
              const _Label('Last Name :'),
              const SizedBox(height: 4),
              _input('last_name', 'Enter Last name'),
            ])),
            FormGridItem(item(12, [
              const _Label('Email :'),
              const SizedBox(height: 4),
              _input('email', 'Enter email', type: TextInputType.emailAddress),
            ])),
            FormGridItem(item(8, [const _Label('Phone Number:'), const SizedBox(height: 8), phone])),
            FormGridItem(item(8, [
              const _Label('Designation:'),
              const SizedBox(height: 8),
              _input('designation', 'Enter Designation'),
            ])),
            FormGridItem(item(16, [const _Label('Subscription Plan :'), planSelect])),
          ],
        ),
        // The editor's own `my-5`; it collapses with the footer's `mt-4`.
        HtmlEditor(
          key: ValueKey('single-$_tiptapKey'),
          initialHtml: _inviteMessage,
          onChanged: (html) => _inviteMessage = html,
        ),
        DialogFooterBar(children: [AppButton(label: 'Send Institution', onPressed: _sendInvite)]),
      ],
    );
  }

  Widget _bulkTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        Row(
          children: [
            const Expanded(child: FieldLabel('Download Template')),
            const SizedBox(width: 8),
            AppButton(label: 'Download', onPressed: _downloadTemplate),
          ],
        ),
        const SizedBox(height: 16),
        const FieldLabel('Upload Excel File'),
        const SizedBox(height: 8),
        FilePickField(onPick: _handleBulkFile, fileName: _bulkFile?.name),
        const SizedBox(height: 24),
        const StarLabel('Email Message', bigStar: false),
        // The editor's own `my-5`; it collapses with the footer's `mt-4`.
        HtmlEditor(
          key: ValueKey('bulk-$_bulkTiptapKey'),
          initialHtml: _bulkInviteMessage,
          onChanged: (html) => _bulkInviteMessage = html,
        ),
        DialogFooterBar(children: [
          AppButton(label: 'Upload & Send', onPressed: _bulkFile == null ? null : _sendBulkInvite),
        ]),
      ],
    );
  }
}

/// `<Label>Text : <span class="text-red-500 text-lg">*</span></Label>`: the
/// `text-lg` star keeps its 28px line, so the label is 28px tall.
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => StarLabel(text, starLineHeight: 28);
}
