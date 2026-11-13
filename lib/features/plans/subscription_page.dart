import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart';
import 'subscription_controller.dart';
import 'zsl_plan_utils.dart';
import 'zsl_plan_widgets.dart';

const _planTypes = <AppSelectItem<Object?>>[
  AppSelectItem('trial', 'Trial'),
  AppSelectItem('pilot', 'Pilot'),
  AppSelectItem('paid', 'Paid'),
];

/// Port of `src/pages/Institute/subscription.vue` (`/subscription`, "Role
/// wise Subscriptions"): create a role subscription plan, filter the plans of
/// an institute's class and edit them in a dialog.
class SubscriptionPage extends ConsumerStatefulWidget {
  const SubscriptionPage({super.key});

  @override
  ConsumerState<SubscriptionPage> createState() => _SubscriptionPageState();
}

class _SubscriptionPageState extends ConsumerState<SubscriptionPage> {
  // ---- Filter section ----
  Object? _filterInstituteId;
  Object? _selectedClassId;
  List<Map<String, dynamic>> _filterClassesList = const [];
  List<Map<String, dynamic>> _plansList = const [];

  // ---- Create form ----
  List<Map<String, dynamic>> _formClassesList = const [];

  // ---- UI flags ----
  bool _isLoading = false;
  bool _isCreateBtnLoading = false;

  Map<String, dynamic> _form = subscriptionEmptyForm();
  final _name = TextEditingController();
  final _days = TextEditingController();
  final _price = TextEditingController();
  final _appleProductId = TextEditingController();
  final _applePrice = TextEditingController();

  SubscriptionController get _ctrl => ref.read(subscriptionControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    // mounted(): getInstitutes(1, 10, false)
    Future.microtask(() => _ctrl.getInstitutes(1, 10, false).ignore());
  }

  @override
  void dispose() {
    _name.dispose();
    _days.dispose();
    _price.dispose();
    _appleProductId.dispose();
    _applePrice.dispose();
    super.dispose();
  }

  // ---- Watchers ----

  /// `watch: filterInstituteId`
  void _onFilterInstituteChanged(Object? id) {
    if (id == _filterInstituteId) return;
    setState(() => _filterInstituteId = id);
    if (!jsTruthy(id)) return;
    setState(() {
      _selectedClassId = null;
      _filterClassesList = const [];
      _plansList = const [];
    });
    _fetchFilterClasses(id!);
  }

  /// `watch: selectedClassId`
  void _onSelectedClassChanged(Object? id) {
    if (id == _selectedClassId) return;
    setState(() => _selectedClassId = id);
    if (!jsTruthy(id) || !jsTruthy(_filterInstituteId)) return;
    _loadPlans();
  }

  /// `watch: 'form.institute_id'`
  void _onFormInstituteChanged(Object? id) {
    if (id == _form['institute_id']) return;
    setState(() => _form['institute_id'] = id);
    if (!jsTruthy(id)) return;
    setState(() {
      _form['classes_id'] = null;
      _formClassesList = const [];
    });
    _fetchFormClasses(id!);
  }

  // ---- Methods ----

  /// `fetchFilterClasses(id)` — snapshot of the store's `classes`.
  Future<void> _fetchFilterClasses(Object id) async {
    setState(() => _isLoading = true);
    try {
      await _ctrl.getClasses(id);
      if (mounted) setState(() => _filterClassesList = [...ref.read(subscriptionControllerProvider).classes]);
    } catch (_) {
      // Already toasted by the API client.
    } finally {
      // The web left the loader up when the request failed.
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// `fetchFormClasses(id)` — snapshot of the store's `classes`.
  Future<void> _fetchFormClasses(Object id) async {
    try {
      await _ctrl.getClasses(id);
      if (mounted) setState(() => _formClassesList = [...ref.read(subscriptionControllerProvider).classes]);
    } catch (_) {}
  }

  /// `loadPlans()`
  Future<void> _loadPlans() async {
    if (!jsTruthy(_filterInstituteId) || !jsTruthy(_selectedClassId)) return;
    setState(() => _isLoading = true);
    try {
      final res = await _ctrl.getAppSubscriptionPlans({
        'institute_id': _filterInstituteId,
        'class_id': _selectedClassId,
      });
      if (mounted) {
        setState(() => _plansList = [for (final p in unwrapList(res)) ?asMap(p)]);
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// `submitForm()` — no validation, like the web; the form is reset only
  /// after a successful create.
  Future<void> _submitForm() async {
    setState(() => _isCreateBtnLoading = true);
    try {
      await _ctrl.createappSubscriptionPlan(subscriptionWithPurchaseFlags(_form));
    } catch (_) {
      return;
    } finally {
      if (mounted) setState(() => _isCreateBtnLoading = false);
    }
    if (!mounted) return;
    setState(() {
      _form = subscriptionEmptyForm();
      _formClassesList = const [];
      for (final c in [_name, _days, _price, _appleProductId, _applePrice]) {
        c.clear();
      }
    });
  }

  /// `openEditDialog(planId)` + `submitEditForm()` (reloads the plans after saving).
  Future<void> _openEditDialog(Object? planId) async {
    final saved = await showAppDialog<bool>(context, builder: (_) => _EditPlanDialog(planId: planId));
    if (saved == true && mounted) await _loadPlans();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(subscriptionControllerProvider);
    final institutes = [
      for (final inst in s.allInstitutes) AppSelectItem<Object?>(inst['id'], jsDisplay(inst['name'])),
    ];
    final twoCols = context.isMd;
    // `text-xl … min-[1600px]:text-4xl`
    final h2Size = context.screenWidth >= 1600 ? 36.0 : 20.0;

    return LoadingOverlay(
      loading: _isLoading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _createCard(institutes, h2Size, twoCols),
            const SizedBox(height: 24),
            _filterCard(institutes, h2Size, twoCols),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ======================== CREATE FORM ========================
  Widget _createCard(List<AppSelectItem<Object?>> institutes, double h2Size, bool twoCols) {
    return PlanCard(
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Heading('Create Role Subscription', size: h2Size),
          // `mb-4` + the card's `gap-6`.
          const SizedBox(height: 40),
          PlanFormGrid(
            twoColumns: twoCols,
            spanAtAllSizes: true,
            cells: [
              PlanGridCell(_FormLabeled(
                'Institute',
                AppSelect<Object?>(
                  value: _form['institute_id'],
                  placeholder: 'Select Institute',
                  menuMaxHeight: 240,
                  items: institutes,
                  onChanged: _onFormInstituteChanged,
                ),
              )),
              PlanGridCell(_FormLabeled(
                'Class',
                AppSelect<Object?>(
                  value: _form['classes_id'],
                  placeholder: 'Select Class',
                  enabled: _formClassesList.isNotEmpty,
                  items: [
                    for (final c in _formClassesList) AppSelectItem<Object?>(c['id'], jsDisplay(c['name'])),
                  ],
                  onChanged: (v) => setState(() => _form['classes_id'] = v),
                ),
              )),
              PlanGridCell(_FormLabeled(
                'Name',
                AppTextField(
                  controller: _name,
                  hint: 'Subscription Name',
                  onChanged: (v) => _form['name'] = v,
                ),
              )),
              PlanGridCell(_FormLabeled('Days', _numberField(_days, 'Enter days', (v) => _form['days'] = v))),
              PlanGridCell(_FormLabeled('Price', _numberField(_price, 'Enter price', (v) => _form['price'] = v))),
              // Max Classes / Discount Price / Final Price are `hidden` on the web.
              PlanGridCell(_FormLabeled(
                'Plan Type',
                AppSelect<Object?>(
                  value: _form['plan_type'],
                  placeholder: 'Select Plan Type',
                  items: _planTypes,
                  onChanged: (v) => setState(() => _form['plan_type'] = v),
                ),
              )),
              PlanGridCell(_FormLabeled(
                'Apple Product ID',
                AppTextField(
                  controller: _appleProductId,
                  hint: 'Enter apple product id',
                  onChanged: (v) => _form['apple_product_id'] = v,
                ),
              )),
              PlanGridCell(_FormLabeled(
                'Apple Price',
                _numberField(_applePrice, 'Enter apple price', (v) => _form['apple_price'] = v),
              )),
              PlanGridCell(
                _FlagCheckboxes(
                  values: _form,
                  onChanged: (key, v) => setState(() => _form[key] = v),
                ),
                fullRow: true,
              ),
              PlanGridCell(
                Align(
                  alignment: Alignment.centerRight,
                  child: PlanIconSpinnerButton(
                    label: 'Create',
                    loadingLabel: 'Creating...',
                    loading: _isCreateBtnLoading,
                    onPressed: _submitForm,
                  ),
                ),
                fullRow: true,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ======================== FILTER + TABLE ========================
  Widget _filterCard(List<AppSelectItem<Object?>> institutes, double h2Size, bool twoCols) {
    return PlanCard(
      radius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Heading('Filter Subscription Plans', size: h2Size),
          const SizedBox(height: 40),
          PlanFormGrid(
            twoColumns: twoCols,
            cells: [
              PlanGridCell(_FormLabeled(
                'Select Institute',
                AppSelect<Object?>(
                  value: _filterInstituteId,
                  placeholder: 'Select Institute',
                  menuMaxHeight: 240,
                  items: institutes,
                  onChanged: _onFilterInstituteChanged,
                ),
              )),
              PlanGridCell(_FormLabeled(
                'Select Class',
                AppSelect<Object?>(
                  value: _selectedClassId,
                  placeholder: 'Select Class',
                  enabled: _filterClassesList.isNotEmpty,
                  items: [
                    for (final c in _filterClassesList) AppSelectItem<Object?>(c['id'], jsDisplay(c['name'])),
                  ],
                  onChanged: _onSelectedClassChanged,
                ),
              )),
            ],
          ),
          // `mb-6` + the card's `gap-6`.
          const SizedBox(height: 48),
          PlanCard(
            radius: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Heading('Subscription Plans', size: 20),
                const SizedBox(height: 40),
                _PlansTable(plans: _plansList, onEdit: (plan) => _openEditDialog(plan['id'])),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// `<Input v-model type="number">` (Vue casts the value to a number, `''` when empty).
  Widget _numberField(TextEditingController c, String hint, ValueChanged<Object> onValue) => AppTextField(
        controller: c,
        hint: hint,
        keyboardType: planNumberKeyboard,
        inputFormatters: planNumberInputFormatters,
        onChanged: (v) => onValue(numberInputValue(v)),
      );
}

/// `<h2 class="text-xl font-semibold text-primary">` (28px line; `text-4xl`
/// = 36px with a 40px line).
class _Heading extends StatelessWidget {
  const _Heading(this.text, {required this.size});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: TextStyle(
          fontSize: size,
          height: (size >= 36 ? 40 : 28) / size,
          fontWeight: FontWeight.w600,
          color: context.colors.primary,
        ),
      );
}

/// `<label class="form-label">` (`font-weight: 500; margin-bottom: 6px;
/// display: block`, the inherited 16px / 24px line) above a control.
class _FormLabeled extends StatelessWidget {
  const _FormLabeled(this.label, this.child);
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          child,
        ],
      );
}

/// Active / One-Time Purchase / Allow Referral Code: `col-span-2 flex gap-6`
/// (no wrapping: narrow screens squeeze the labels) of `<label class="flex
/// items-center gap-2">` around a plain `w-5 h-5` checkbox (the browser's
/// default colours); clicking the text toggles it too.
class _FlagCheckboxes extends StatelessWidget {
  const _FlagCheckboxes({required this.values, required this.onChanged});
  final Map<String, dynamic> values;
  final void Function(String key, bool value) onChanged;

  static const _flags = [
    ('is_active', 'Active'),
    ('is_one_time_purchase', 'One-Time Purchase'),
    ('allow_referral_code', 'Allow Referral Code'),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final (i, (key, label)) in _flags.indexed) ...[
          if (i > 0) const SizedBox(width: 24),
          Flexible(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(key, !jsTruthy(values[key])),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  PlanCheckbox(
                    value: jsTruthy(values[key]),
                    size: 20,
                    onChanged: (v) => onChanged(key, v),
                  ),
                  const SizedBox(width: 8),
                  Flexible(child: Text(label, style: const TextStyle(fontSize: 16, height: 1.5))),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// The plain `<table class="w-full border">` of plans (16px text, 24px
/// lines). Header cells follow the web's global `thead th` rule
/// (`bg-primary text-primary-foreground`, `padding: .5rem 1rem`,
/// `border-bottom`), which covers the row's `bg-gray-100`; `th` stays bold
/// and, because the row sets `text-left`, left-aligned.
class _PlansTable extends StatelessWidget {
  const _PlansTable({required this.plans, required this.onEdit});
  final List<Map<String, dynamic>> plans;
  final ValueChanged<Map<String, dynamic>> onEdit;

  static const _columns = [
    ('Name', 1.6),
    ('Plan Type', 1.1),
    ('Days', 0.8),
    ('Price', 1.0),
    ('Status', 1.0),
    ('Actions', 1.0),
  ];

  @override
  Widget build(BuildContext context) {
    final border = context.isDark ? AppColors.darkBorder : AppColors.border;
    final scheme = context.colors;

    Widget row(List<Widget> cells, EdgeInsets padding) => Row(
          children: [
            for (var i = 0; i < _columns.length; i++)
              Expanded(
                flex: (_columns[i].$2 * 100).round(),
                child: Padding(
                  padding: padding,
                  child: Align(alignment: Alignment.centerLeft, child: cells[i]),
                ),
              ),
          ],
        );

    final children = <Widget>[
      Container(
        decoration: BoxDecoration(
          color: scheme.primary,
          border: Border(bottom: BorderSide(color: border)),
        ),
        child: row(
          [
            for (final c in _columns)
              Text(c.$1, style: TextStyle(fontWeight: FontWeight.w700, color: scheme.onPrimary)),
          ],
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      for (final (i, plan) in plans.indexed)
        Container(
          // `border-t` (collapsed into the header's bottom border on the first row).
          decoration: BoxDecoration(border: i == 0 ? null : Border(top: BorderSide(color: border))),
          child: row(
            [
              Text(jsDisplay(plan['name'])),
              Text(jsDisplay(plan['plan_type'])),
              Text(jsDisplay(plan['days'])),
              Text('₹${jsDisplay(plan['price'])}'),
              Text(jsTruthy(plan['is_active']) ? 'Active' : 'Inactive'),
              // `variant="outline" size="sm"`: `<i class="bi bi-pencil mr-1" />
              // Edit` (14px icon, `mr-1` + `gap-1.5` before the text).
              AppButton(
                variant: AppButtonVariant.outline,
                size: AppButtonSize.sm,
                onPressed: () => onEdit(plan),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [Icon(BootstrapIcons.pencil, size: 14), SizedBox(width: 10), Text('Edit')],
                ),
              ),
            ],
            const EdgeInsets.all(8),
          ),
        ),
      if (plans.isEmpty)
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No plans found', textAlign: TextAlign.center, style: TextStyle(color: Tw.gray500)),
        ),
    ];

    return Container(
      decoration: BoxDecoration(border: Border.all(color: border)),
      child: LayoutBuilder(
        builder: (context, c) {
          // `w-full`; the web squeezes (wraps) the cells and only overflows
          // below the columns' min-content width, roughly this:
          final width = c.maxWidth.isFinite && c.maxWidth > 600 ? c.maxWidth : 600.0;
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: DefaultTextStyle.merge(
                style: const TextStyle(fontSize: 16, height: 1.5),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ======================== EDIT DIALOG ========================

/// "Edit Subscription Plan": loads the plan (spinner meanwhile), closes when
/// loading fails, resolves to `true` after a successful save.
class _EditPlanDialog extends ConsumerStatefulWidget {
  const _EditPlanDialog({required this.planId});
  final Object? planId;

  @override
  ConsumerState<_EditPlanDialog> createState() => _EditPlanDialogState();
}

class _EditPlanDialogState extends ConsumerState<_EditPlanDialog> {
  bool _isEditLoading = true;
  bool _isEditBtnLoading = false;
  Map<String, dynamic> _editForm = subscriptionEmptyEditForm();
  final _name = TextEditingController();
  final _days = TextEditingController();
  final _price = TextEditingController();
  final _appleProductId = TextEditingController();
  final _applePrice = TextEditingController();

  SubscriptionController get _ctrl => ref.read(subscriptionControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _days.dispose();
    _price.dispose();
    _appleProductId.dispose();
    _applePrice.dispose();
    super.dispose();
  }

  /// `openEditDialog(planId)`: `plan = res?.data || res`.
  Future<void> _load() async {
    try {
      final res = await _ctrl.getAppSubscriptionPlanById(widget.planId ?? 'undefined');
      final inner = asMap(res)?['data'];
      final plan = asMap(jsTruthy(inner) ? inner : res);
      if (!mounted) return;
      if (plan == null) {
        Navigator.of(context).pop();
        return;
      }
      final form = subscriptionEditFormFrom(plan);
      setState(() {
        _editForm = form;
        _name.text = jsDisplay(form['name']);
        _days.text = numberInputText(form['days']);
        _price.text = numberInputText(form['price']);
        _appleProductId.text = jsDisplay(form['apple_product_id']);
        _applePrice.text = numberInputText(form['apple_price']);
      });
    } catch (_) {
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isEditLoading = false);
    }
  }

  /// `submitEditForm()`
  Future<void> _submit() async {
    setState(() => _isEditBtnLoading = true);
    try {
      await _ctrl.updateAppSubscriptionPlan(
        widget.planId ?? 'undefined',
        subscriptionWithPurchaseFlags(_editForm),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      // Already toasted by the API client; the dialog stays open.
    } finally {
      if (mounted) setState(() => _isEditBtnLoading = false);
    }
  }

  Widget _numberField(TextEditingController c, String hint, String key) => AppTextField(
        controller: c,
        hint: hint,
        keyboardType: planNumberKeyboard,
        inputFormatters: planNumberInputFormatters,
        onChanged: (v) => _editForm[key] = numberInputValue(v),
      );

  @override
  Widget build(BuildContext context) {
    final body = _isEditLoading
        // `flex justify-center items-center py-10` around a `text-2xl` (32px
        // line) `text-primary` spinning icon.
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 40),
            child: SizedBox(
              height: 32,
              child: Center(child: PlanSpinIcon(size: 24, color: context.colors.primary)),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: PlanFormGrid(
              twoColumns: context.isMd,
              spanAtAllSizes: true,
              cells: [
                PlanGridCell(_FormLabeled(
                  'Name',
                  AppTextField(
                    controller: _name,
                    hint: 'Subscription Name',
                    onChanged: (v) => _editForm['name'] = v,
                  ),
                )),
                PlanGridCell(_FormLabeled('Days', _numberField(_days, 'Enter days', 'days'))),
                PlanGridCell(_FormLabeled('Price', _numberField(_price, 'Enter price', 'price'))),
                PlanGridCell(_FormLabeled(
                  'Plan Type',
                  AppSelect<Object?>(
                    value: _editForm['plan_type'],
                    placeholder: 'Select Plan Type',
                    items: _planTypes,
                    onChanged: (v) => setState(() => _editForm['plan_type'] = v),
                  ),
                )),
                PlanGridCell(_FormLabeled(
                  'Apple Product ID',
                  AppTextField(
                    controller: _appleProductId,
                    hint: 'Enter apple product id',
                    onChanged: (v) => _editForm['apple_product_id'] = v,
                  ),
                )),
                PlanGridCell(_FormLabeled(
                  'Apple Price',
                  _numberField(_applePrice, 'Enter apple price', 'apple_price'),
                )),
                PlanGridCell(
                  _FlagCheckboxes(
                    values: _editForm,
                    onChanged: (key, v) => setState(() => _editForm[key] = v),
                  ),
                  fullRow: true,
                ),
              ],
            ),
          );

    final wide = context.isSm;
    final screenH = MediaQuery.sizeOf(context).height;
    // `class="max-w-2xl max-h-[90vh]"`: `max-w-2xl` replaces the kit's
    // `max-w-[calc(100%-2rem)]`, so below 640px the dialog is the full
    // screen width (up to 672px); from 640px the kit's `sm:max-w-lg` applies.
    return AppDialogFrame(
      title: 'Edit Subscription Plan',
      description: 'Update the subscription plan details below.',
      maxWidth: wide ? 512 : 672,
      insetPadding: EdgeInsets.symmetric(horizontal: wide ? 16 : 0, vertical: screenH * 0.05),
      actions: [
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.outline,
          onPressed: () => Navigator.of(context).pop(),
        ),
        PlanIconSpinnerButton(
          label: 'Save Changes',
          loadingLabel: 'Saving...',
          loading: _isEditBtnLoading,
          onPressed: _submit,
        ),
      ],
      child: body,
    );
  }
}
