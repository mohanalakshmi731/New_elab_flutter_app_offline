import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/pagination.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_table.dart';
import '../../widgets/form_fields.dart';
import '../institutes/institute_widgets.dart' show LabeledCheckbox;
import 'batch_list_controller.dart';

/// Port of `src/pages/batch/batchlist.vue` (component `InstructorsTab`),
/// routed at `/instructorlist` (the web registers that path twice and
/// vue-router matches this component first).
class BatchListPage extends ConsumerStatefulWidget {
  const BatchListPage({super.key});

  @override
  ConsumerState<BatchListPage> createState() => _BatchListPageState();
}

/// `newInstructor` defaults.
Map<String, dynamic> _emptyInstructor() => {
  'firstName': '',
  'lastName': '',
  'email': '',
  'countryCode': '+91',
  'phone': '',
  'gender': '',
  'password': '',
  'enable_zoom': false,
  'is_labadmin': false,
  'dob': '',
  'photo': null,
  'joiningDate': '',
  'designation': '',
};

class _BatchListPageState extends ConsumerState<BatchListPage> {
  // ── data() ──
  Map<String, dynamic> _newInstructor = _emptyInstructor();
  List<Map<String, dynamic>> _dialCodes = const [];

  BatchListController get _ctrl => ref.read(batchListControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      // Neither call is awaited by the web's `mounted()`; failures were
      // already toasted by the API client.
      _loadDialCodes().catchError((_) {});
      _ctrl.getAllInstructors().catchError((_) {});
    });
  }

  /// `loadDialCodes()`
  Future<void> _loadDialCodes() async {
    final res = await ref.read(userServiceProvider).getDailCodes();
    if (!mounted) return;
    final codes = [for (final e in unwrapList(res)) ?asMap(e)];
    setState(() {
      _dialCodes = codes;
      if (codes.isNotEmpty) _newInstructor = {..._newInstructor, 'countryCode': '+${codes.first['code']}'};
    });
  }

  /// `changePage(page)` — the web calls `this.getInstructors(...)`, which this
  /// component never maps from the store, so the click throws a TypeError
  /// and nothing changes. Kept as a no-op (see the port report).
  Future<void> _changePage(int page) async {
    final classId = ref.read(sessionProvider).classDetails?.id;
    if (classId == null || classId == 0) return;
    final meta = ref.read(batchListControllerProvider).instructorPagination;
    if (page < 1 || page > meta.lastPage) return;
  }

  /// `openInstructorModal()` — its button is `hidden` in the web template.
  Future<void> _openInstructorModal() async {
    final result = await showAppDialog<Map<String, dynamic>>(
      context,
      builder: (_) => _AddInstructorDialog(
        initial: _newInstructor,
        dialCodes: _dialCodes,
        onCreate: (form) => _ctrl.addInstructor(form),
      ),
    );
    if (result != null && mounted) setState(() => _newInstructor = _emptyInstructor());
  }

  /// `openEditDialog(instructor)` — `window.alert('Edit instructor: ' + first_name)`.
  void _openEditDialog(Map<String, dynamic> instructor) {
    final first = dig(instructor, ['user', 'first_name']);
    showAppDialog<void>(
      context,
      builder: (ctx) => AppDialogFrame(
        description: 'Edit instructor: ${first ?? 'undefined'}',
        maxWidth: 384,
        actions: [AppButton(label: 'OK', onPressed: () => Navigator.of(ctx).pop())],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(batchListControllerProvider);
    final role = ref.watch(sessionProvider.select((x) => x.role));
    final meta = s.instructorPagination;

    String or(Object? v, String fallback) => v == null || v == '' ? fallback : '$v';

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (role == Role.institute)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              // `<div class="flex gap-2 ml-4 hidden"><Button>Create Instructor</Button></div>`
              child: Visibility(
                visible: false,
                child: AppButton(label: 'Create Instructor', onPressed: _openInstructorModal),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppTable(
              emptyText: 'No instructors. Please add one.',
              columns: const [
                AppTableColumn('ID', flex: 0.5),
                AppTableColumn('First Name'),
                AppTableColumn('Last Name'),
                AppTableColumn('Email', flex: 1.6),
                AppTableColumn('Phone', flex: 1.2),
                AppTableColumn('Status', flex: 0.8),
                AppTableColumn('Action', flex: 0.8),
              ],
              rows: [
                for (final inst in s.instructors)
                  [
                    Text('${inst['id'] ?? ''}'),
                    Text(or(dig(inst, ['user', 'first_name']), '-')),
                    Text(or(dig(inst, ['user', 'last_name']), '-')),
                    Text(or(dig(inst, ['user', 'email']), '-')),
                    Text('+${or(dig(inst, ['user', 'country_code']), '')} ${or(dig(inst, ['user', 'phone']), '')}'),
                    _status(asBool(inst['status'])),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      // `flex gap-4`; `table .bi` makes the icons 18px.
                      children: [
                        TableActionIcon(
                          icon: BootstrapIcons.pencil_square,
                          color: Tw.green600,
                          size: 18,
                          onTap: () => _openEditDialog(inst),
                        ),
                        const SizedBox(width: 8),
                        // No click handler in the web either.
                        const TableActionIcon(
                          icon: BootstrapIcons.trash3_fill,
                          color: Tw.red600,
                          size: 18,
                          onTap: null,
                        ),
                      ],
                    ),
                  ],
              ],
            ),
          ),
          // `mt-4 flex` > `ml-auto`; its `mt-4` collapses with the card's `m-4`.
          if (s.instructors.isNotEmpty)
            Align(
              alignment: Alignment.centerRight,
              child: _InstructorPagination(meta: meta, onPageChanged: _changePage),
            ),
        ],
      ),
    );
  }

  /// `text-green-600` Active / `text-red-600` Inactive.
  Widget _status(bool active) =>
      Text(active ? 'Active' : 'Inactive', style: TextStyle(color: active ? Tw.green600 : Tw.red600));
}

/// The "Add Instructor" `<Dialog>` (`sm:max-w-3xl`). Pops with the submitted
/// form once `addInstructor` succeeded; stays open on failure like the web.
class _AddInstructorDialog extends StatefulWidget {
  const _AddInstructorDialog({required this.initial, required this.dialCodes, required this.onCreate});

  final Map<String, dynamic> initial;
  final List<Map<String, dynamic>> dialCodes;
  final Future<void> Function(Map<String, dynamic> form) onCreate;

  @override
  State<_AddInstructorDialog> createState() => _AddInstructorDialogState();
}

class _AddInstructorDialogState extends State<_AddInstructorDialog> {
  late final Map<String, dynamic> _form = {...widget.initial};
  late final _first = TextEditingController(text: '${_form['firstName'] ?? ''}');
  late final _last = TextEditingController(text: '${_form['lastName'] ?? ''}');
  late final _email = TextEditingController(text: '${_form['email'] ?? ''}');
  late final _phone = TextEditingController(text: '${_form['phone'] ?? ''}');

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _phone]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _create() async {
    final form = {
      ..._form,
      'firstName': _first.text,
      'lastName': _last.text,
      'email': _email.text,
      'phone': _phone.text,
    };
    try {
      await widget.onCreate(form);
    } catch (_) {
      return;
    }
    if (mounted) Navigator.of(context).pop(form);
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: 16);
    return AppDialogFrame(
      title: 'Add Instructor',
      maxWidth: 768,
      actions: [
        AppButton(label: 'Cancel', variant: AppButtonVariant.outline, onPressed: () => Navigator.of(context).pop()),
        AppButton(label: 'Create', onPressed: _create),
      ],
      // body `mt-4`; footer `mt-6` + the grid's `gap-4`.
      child: Padding(
        padding: const EdgeInsets.only(top: 16, bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(controller: _first, hint: 'First Name'),
            gap,
            AppTextField(controller: _last, hint: 'Last Name'),
            gap,
            AppTextField(controller: _email, hint: 'Email', keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 24),
            Row(
              children: [
                SizedBox(
                  width: 112,
                  child: AppSelect<String>(
                    value: _form['countryCode'] as String?,
                    placeholder: '+91',
                    items: [for (final c in widget.dialCodes) AppSelectItem('+${c['code']}', '+${c['code']}')],
                    onChanged: (v) => setState(() => _form['countryCode'] = v),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: AppTextField(controller: _phone, hint: 'Phone', keyboardType: TextInputType.phone),
                ),
              ],
            ),
            gap,
            LabeledCheckbox(value: _form['is_labadmin'] == true, label: 'Lab Admin', onChanged: (v) => setState(() => _form['is_labadmin'] = v)),
            Align(
              alignment: Alignment.centerLeft,
              child: LabeledCheckbox(
                value: _form['enable_zoom'] == true,
                label: 'Enable Zoom',
                onChanged: (v) => setState(() => _form['enable_zoom'] = v),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The page's own `<Pagination>`: `Prev` / every page / `Next`, all ghost
/// buttons (`hover:bg-accent`); the current page adds `bg-blue-500
/// text-white`. Prev/Next are disabled (`opacity-50`) at the ends.
class _InstructorPagination extends StatelessWidget {
  const _InstructorPagination({required this.meta, required this.onPageChanged});
  final PageMeta meta;
  final ValueChanged<int> onPageChanged;

  @override
  Widget build(BuildContext context) {
    final current = meta.currentPage;
    final last = meta.lastPage;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _GhostButton(
            label: 'Prev',
            enabled: current > 1,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            onTap: () => onPageChanged(current - 1),
          ),
          for (var page = 1; page <= last; page++) ...[
            if (page > 1) const SizedBox(width: 4),
            _GhostButton(label: '$page', width: 36, active: page == current, onTap: () => onPageChanged(page)),
          ],
          _GhostButton(
            label: 'Next',
            enabled: current < last,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            onTap: () => onPageChanged(current + 1),
          ),
        ],
      ),
    );
  }
}

/// shadcn ghost `<Button>` (`h-9 rounded-md text-sm font-medium
/// hover:bg-accent hover:text-accent-foreground dark:hover:bg-accent/50`).
class _GhostButton extends StatefulWidget {
  const _GhostButton({
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.active = false,
    this.width,
    this.padding = EdgeInsets.zero,
  });

  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool active;
  final double? width;
  final EdgeInsets padding;

  @override
  State<_GhostButton> createState() => _GhostButtonState();
}

class _GhostButtonState extends State<_GhostButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final hovered = widget.enabled && _hovered;
    final Color? bg = hovered
        ? (dark ? AppColors.accent.withValues(alpha: 0.5) : AppColors.accent)
        : (widget.active ? Tw.blue500 : null);
    final Color fg = hovered ? AppColors.accentForeground : (widget.active ? Colors.white : context.colors.onSurface);
    Widget button = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 36,
      width: widget.width,
      padding: widget.padding,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: Text(
        widget.label,
        style: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: fg),
      ),
    );
    if (!widget.enabled) return Opacity(opacity: 0.5, child: button);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: widget.onTap, child: button),
    );
  }
}
