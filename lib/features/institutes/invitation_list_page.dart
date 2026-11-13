import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/form_fields.dart';
import '../common/lookups.dart';
import 'institute_payloads.dart';
import 'institute_widgets.dart';
import 'institutes_controller.dart';

/// Port of `src/pages/Institute/invitationlist.vue` (`/Invitationslist`).
class InvitationListPage extends ConsumerStatefulWidget {
  const InvitationListPage({super.key, this.query = const {}});

  /// `route.query`, which the web router passes as a prop (the component
  /// itself never reads it).
  final Map<String, String> query;

  @override
  ConsumerState<InvitationListPage> createState() => _InvitationListPageState();
}

class _InvitationListPageState extends ConsumerState<InvitationListPage> {
  Object? _selectedInvitationId;

  InstitutesController get _ctrl => ref.read(institutesControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    // `mounted()`: three un-awaited loads (errors were already toasted).
    Future.microtask(() {
      _ctrl.fetchInvitations().catchError((_) => null);
      _ctrl.loadInstitutePlans().catchError((_) {});
      _ctrl.loadDialCodesForInstitute().catchError((_) => const <Map<String, dynamic>>[]);
    });
  }

  Future<void> _handleResend(Map<String, dynamic> item) async {
    try {
      _selectedInvitationId = item['id'];

      final res = await _ctrl.fetchInvitationById(item['id'] as Object);
      final data = asMap(jsOr(asMap(res)?['data'], res)) ?? const <String, dynamic>{};
      final dialCodes = ref.read(dialCodesProvider).valueOrNull ?? const [];
      _ctrl.setInvitationForm({
        'first_name': '',
        'last_name': '',
        'email': jsOr(data['recipient_email'], ''),
        'phone': '',
        'designation': '',
        // `undefined` is skipped by setInvitationForm.
        if (data.containsKey('institute_plan_id')) 'institute_plan_id': data['institute_plan_id'],
        'country_code': dialCodes.firstOrNull?['code'] ?? '',
      });
      if (jsTruthy(data['recipient_email'])) {
        final userRes = await _ctrl.searchInvitationUsers('${data['recipient_email']}');
        final users = jsOr(asMap(userRes)?['data'], userRes);
        if (users is List && users.isNotEmpty) {
          final user = asMap(users[0]) ?? const <String, dynamic>{};
          _ctrl.setInvitationForm({
            ...ref.read(institutesControllerProvider).invitform,
            'first_name': jsOr(user['first_name'], ''),
            'last_name': jsOr(user['last_name'], ''),
            'email': jsOr(user['email'], data['recipient_email']),
            'phone': jsOr(user['phone'], ''),
            'designation': jsOr(user['designation'], ''),
          });
        }
      }
      if (!mounted) return;
      await showAppDialog<void>(
        context,
        builder: (_) => _ResendInvitationDialog(invitationId: _selectedInvitationId),
      );
    } catch (_) {
      if (!mounted) return;
      // `alert('Failed to load invitation')`
      await showAppDialog<void>(
        context,
        builder: (ctx) => AppDialogFrame(
          description: 'Failed to load invitation',
          maxWidth: 384,
          actions: [AppButton(label: 'OK', onPressed: () => Navigator.of(ctx).pop())],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final invitations = ref.watch(institutesControllerProvider).invitations;
    final border = context.borderColor;

    // style.css's unlayered `thead th { background: var(--primary); color:
    // var(--primary-foreground); padding: .5rem 1rem; border-bottom: 1px
    // solid var(--border) }` beats the template's `bg-gray-100` / `p-3`.
    // `<th>` keeps the browser's bold; `text-left` (Action: `text-center`).
    Widget th(String text, {bool center = false}) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
          child: Text(
            text,
            textAlign: center ? TextAlign.center : TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.w700, color: context.colors.onPrimary),
          ),
        );
    Widget td(Widget child, {bool center = false}) => Padding(
          padding: const EdgeInsets.all(12),
          child: center ? Center(child: child) : Align(alignment: Alignment.centerLeft, child: child),
        );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Invitations List',
            style: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, color: context.colors.primary),
          ),
          const SizedBox(height: 16),
          // `rounded-2xl border shadow-sm overflow-hidden`
          Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
              boxShadow: AppShadows.sm,
            ),
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 14, height: 20 / 14),
              child: Table(
                columnWidths: const {
                  0: FlexColumnWidth(),
                  1: FlexColumnWidth(1.5),
                  2: IntrinsicColumnWidth(),
                  3: IntrinsicColumnWidth(),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    decoration: BoxDecoration(color: context.colors.primary),
                    children: [th('Code'), th('Email'), th('Status'), th('Action', center: true)],
                  ),
                  for (final item in invitations)
                    TableRow(children: [
                      td(Text('${item['code'] ?? ''}')),
                      td(Text('${jsOr(item['recipient_email'], '—')}')),
                      td(_StatusBadge(registered: jsTruthy(item['has_registered']))),
                      td(
                        _ReinviteButton(
                          disabled: jsTruthy(item['has_registered']),
                          onTap: () => _handleResend(item),
                        ),
                        center: true,
                      ),
                    ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// `px-2 py-1 rounded text-xs` badge.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.registered});
  final bool registered;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: registered ? Tw.green100 : Tw.red500,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          registered ? 'Active' : 'Pending',
          style: TextStyle(fontSize: 12, height: 16 / 12, color: registered ? Tw.green600 : Colors.white),
        ),
      );
}

/// A plain `<button class="px-3 py-1 text-xs rounded">`: no hover state and
/// Tailwind 4's default arrow cursor; grey, disabled and `cursor-not-allowed`
/// once registered.
class _ReinviteButton extends StatelessWidget {
  const _ReinviteButton({required this.disabled, required this.onTap});
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => MouseRegion(
        cursor: disabled ? SystemMouseCursors.forbidden : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: disabled ? null : onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: disabled ? Tw.gray300 : Tw.blue600,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Reinvite',
              style: TextStyle(fontSize: 12, height: 16 / 12, color: disabled ? Tw.gray500 : Colors.white),
            ),
          ),
        ),
      );
}

/// "Resend Invitation" (`w-[95%] sm:w-[90%] md:w-[70%] px-[3%]`), bound to
/// the store's `invitform`.
class _ResendInvitationDialog extends ConsumerStatefulWidget {
  const _ResendInvitationDialog({required this.invitationId});
  final Object? invitationId;

  @override
  ConsumerState<_ResendInvitationDialog> createState() => _ResendInvitationDialogState();
}

class _ResendInvitationDialogState extends ConsumerState<_ResendInvitationDialog> {
  late final Map<String, TextEditingController> _fields;
  List<Map<String, dynamic>> _searchResults = const [];

  InstitutesController get _ctrl => ref.read(institutesControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    final form = ref.read(institutesControllerProvider).invitform;
    _fields = {
      for (final k in ['first_name', 'last_name', 'email', 'phone', 'designation'])
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

  /// `@input` on the email field.
  Future<void> _handleSearch(String email) async {
    if (email.isEmpty) {
      setState(() => _searchResults = const []);
      return;
    }
    try {
      final res = await _ctrl.searchInvitationUsers(email);
      final list = jsOr(asMap(res)?['data'], res);
      if (!mounted) return;
      setState(() => _searchResults = [for (final e in asList(list)) ?asMap(e)]);
    } catch (_) {}
  }

  void _selectUser(Map<String, dynamic> user) {
    final email = asString(user['email']) ?? '';
    _ctrl.setInvitField('email', user['email']);
    _fields['email']!.text = email;
    setState(() => _searchResults = const []);
  }

  Future<void> _submitResend() async {
    final id = widget.invitationId;
    if (!jsTruthy(id)) return;
    final form = ref.read(institutesControllerProvider).invitform;
    final ctrl = _ctrl;
    final nav = Navigator.of(context);
    try {
      await ctrl.resendInvitationAction(id!, {
        'name': '${form['first_name']} ${form['last_name']}',
        'content': 'Resending invitation',
      });
      nav.pop();
      ctrl.fetchInvitations().catchError((_) => null);
    } catch (_) {}
  }

  Widget _input(String key, {String? hint, ValueChanged<String>? onChanged}) => AppTextField(
        controller: _fields[key],
        hint: hint,
        onChanged: (v) {
          _ctrl.setInvitField(key, v);
          onChanged?.call(v);
        },
      );

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(institutesControllerProvider);
    final dialCodes = ref.watch(dialCodesProvider).valueOrNull ?? const <Map<String, dynamic>>[];
    final w = context.screenWidth;
    final maxWidth = responsiveDialogWidth(
      context,
      percent: (w) => w >= 768 ? 0.7 : (w >= 640 ? 0.9 : 0.95),
    );
    final code = asString(s.invitform['country_code']);
    final codeItems = [for (final c in dialCodes) AppSelectItem('${c['code']}', '${c['code']}')];
    final codeLabel = codeItems.where((i) => i.value == code).firstOrNull?.label ?? 'code';
    final planItems = [
      for (final p in s.plans)
        if (p['id'] != null) AppSelectItem<Object>(p['id'] as Object, '${p['name']}'),
    ];
    final planLabel =
        planItems.where((i) => i.value == s.invitform['institute_plan_id']).firstOrNull?.label ?? 'Select Plan';

    Widget item(double top, String label, Widget field, {double gap = 4}) => Padding(
          padding: EdgeInsets.only(top: top),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [FieldLabel(label), SizedBox(height: gap), field],
          ),
        );

    return AppDialogFrame(
      maxWidth: maxWidth,
      padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.only(right: context.isSm ? 28 : 0),
            child: Text(
              'Resend Invitation',
              textAlign: context.isSm ? TextAlign.left : TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1, color: context.colors.primary),
            ),
          ),
          const SizedBox(height: 16),
          FormGrid(
            twoColumns: context.isSm,
            items: [
              FormGridItem(item(8, 'First name *', _input('first_name'))),
              FormGridItem(item(8, 'Last Name *', _input('last_name'))),
              FormGridItem(item(
                12,
                'Email *',
                _EmailSearchField(
                  results: _searchResults,
                  onSelect: _selectUser,
                  child: _input('email', hint: 'Search email...', onChanged: _handleSearch),
                ),
              )),
              FormGridItem(item(
                8,
                'Phone *',
                Row(
                  children: [
                    // `<Select class="w-24">` → the trigger stays `w-fit`.
                    SizedBox(
                      width: selectFitWidth(context, codeLabel),
                      child: AppSelect<String>(
                        value: code,
                        placeholder: 'code',
                        items: codeItems,
                        onChanged: (v) => _ctrl.setInvitField('country_code', v),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: _input('phone')),
                  ],
                ),
              )),
              FormGridItem(item(8, 'Designation *', _input('designation'), gap: 0)),
              // `<SelectTrigger>` without `w-full`: content-sized.
              FormGridItem(item(
                16,
                'Subscription Plan *',
                Align(
                  alignment: Alignment.centerLeft,
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final fit = selectFitWidth(context, planLabel);
                      return SizedBox(
                        width: c.maxWidth.isFinite && fit > c.maxWidth ? c.maxWidth : fit,
                        child: AppSelect<Object>(
                          value: s.invitform['institute_plan_id'] as Object?,
                          placeholder: 'Select Plan',
                          items: planItems,
                          onChanged: (v) => _ctrl.setInvitField('institute_plan_id', v),
                        ),
                      );
                    },
                  ),
                ),
                gap: 0,
              )),
            ],
          ),
          // `gap-4` + the footer's `mt-6`
          const SizedBox(height: 16 + 24),
          AppButton(label: 'Resend Invitation', expand: true, onPressed: _submitResend),
        ],
      ),
    );
  }
}

/// The email input with the absolutely positioned results dropdown
/// (`absolute bg-white border w-full mt-1 rounded shadow z-50 max-h-40`).
class _EmailSearchField extends StatefulWidget {
  const _EmailSearchField({required this.child, required this.results, required this.onSelect});
  final Widget child;
  final List<Map<String, dynamic>> results;
  final ValueChanged<Map<String, dynamic>> onSelect;

  @override
  State<_EmailSearchField> createState() => _EmailSearchFieldState();
}

class _EmailSearchFieldState extends State<_EmailSearchField> {
  final _link = LayerLink();
  final _portal = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _portal.show();
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth.isFinite ? c.maxWidth : 240.0;
        return CompositedTransformTarget(
          link: _link,
          child: OverlayPortal(
            controller: _portal,
            overlayChildBuilder: (_) {
              if (widget.results.isEmpty) return const SizedBox.shrink();
              return CompositedTransformFollower(
                link: _link,
                showWhenUnlinked: false,
                targetAnchor: Alignment.bottomLeft,
                offset: const Offset(0, 4),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: width,
                    child: _ResultsList(results: widget.results, onSelect: widget.onSelect),
                  ),
                ),
              );
            },
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _ResultsList extends StatelessWidget {
  const _ResultsList({required this.results, required this.onSelect});
  final List<Map<String, dynamic>> results;
  final ValueChanged<Map<String, dynamic>> onSelect;

  @override
  Widget build(BuildContext context) {
    final border = context.isDark ? AppColors.darkBorder : AppColors.border;
    return Material(
      color: Colors.white,
      elevation: 0,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 160),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3, offset: const Offset(0, 1)),
          ],
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          children: [
            for (final user in results)
              InkWell(
                onTap: () => onSelect(user),
                hoverColor: Tw.gray100,
                // `p-2`; the dialog's 16px body text.
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text('${user['email'] ?? ''}', style: const TextStyle(fontSize: 16, height: 1.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
