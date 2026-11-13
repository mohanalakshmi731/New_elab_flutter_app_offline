import 'dart:async';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart' show AppSelectItem;
import '../../widgets/skeleton.dart';
import 'institute_plan_controller.dart';
import 'institute_plan_widgets.dart';

/// Port of `src/pages/Institute/InstituteplanCreate.vue` (`/institutesplanCreate`):
/// the create form, the plans table, the plan view dialog and the delete
/// dialog.
class InstitutePlanCreatePage extends ConsumerStatefulWidget {
  const InstitutePlanCreatePage({super.key});

  @override
  ConsumerState<InstitutePlanCreatePage> createState() => _InstitutePlanCreatePageState();
}

class _InstitutePlanCreatePageState extends ConsumerState<InstitutePlanCreatePage> {
  // data() — create form
  final List<int> _fetchedPlanClasses = [];
  bool _isCreateBtnLoading = false;
  final Map<String, TextEditingController> _inputs = {
    for (final f in institutePlanFields) f.key: TextEditingController(),
  };

  // data() — list
  bool _isLoading = false;
  List<Map<String, dynamic>> _plans = const [];

  InstitutePlanController get _ctrl => ref.read(institutePlanControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(_mounted);
  }

  @override
  void dispose() {
    for (final c in _inputs.values) {
      c.dispose();
    }
    super.dispose();
  }

  /// `mounted()`: `resetPlan()`, `getAllClasses()` (not awaited), `loadPlans()`.
  Future<void> _mounted() async {
    if (!mounted) return;
    final ctrl = _ctrl;
    ctrl.resetPlan();
    _syncInputs(ctrl.current.subscriptionForm);
    ctrl.getAllClasses().ignore();
    await _loadPlans();
  }

  /// The inputs are `v-model`ed to the store form: refresh them whenever the
  /// store replaces it.
  void _syncInputs(InstitutePlanForm form) {
    for (final f in institutePlanFields) {
      final text = planText(form[f.key]);
      final c = _inputs[f.key]!;
      if (c.text != text) c.text = text;
    }
  }

  /// `watch: 'form.class_id'` — fetch the ZSL plans of newly selected
  /// classes (once per class), then sync `form.zsl_classes`.
  Future<void> _onClassIdsChanged(InstitutePlanController ctrl, List<int> newVal, List<int> oldVal) async {
    final added = [for (final id in newVal) if (!oldVal.contains(id)) id];
    for (final id in added) {
      if (!_fetchedPlanClasses.contains(id)) {
        try {
          await ctrl.fetchZslPlansByClass(id);
          _fetchedPlanClasses.add(id);
        } catch (_) {
          // Plan fetch failed for class (toasted by the API client).
        }
      }
    }
    ctrl.syncZslClassesForCreate(newVal);
  }

  /// Toggling an item of the `multiple` class select.
  void _toggleClass(int id) {
    final ctrl = _ctrl;
    final old = ctrl.current.subscriptionForm.classId;
    final next = old.contains(id) ? [for (final x in old) if (x != id) x] : [...old, id];
    ctrl.setClassIds(next);
    unawaited(_onClassIdsChanged(ctrl, next, old));
  }

  /// `getClassNameById(id)`
  String _classNameById(InstitutePlanState s, int id) {
    for (final c in s.allClasses) {
      if (asInt(c['id']) == id) return planText(c['name']);
    }
    return '';
  }

  /// `submitForm()`
  Future<void> _submitForm() async {
    final ctrl = _ctrl;
    setState(() => _isCreateBtnLoading = true);
    try {
      await ctrl.submitSubscriptionForm(ctrl.current.subscriptionForm);
      // The store reset the form (the `form.class_id` watcher that fires on
      // the web has nothing to do: no class is selected any more).
      if (mounted) _syncInputs(ctrl.current.subscriptionForm);
      await _loadPlans();
    } catch (_) {
      // API errors were toasted by the API client; the web doesn't catch.
    } finally {
      if (mounted) setState(() => _isCreateBtnLoading = false);
    }
  }

  /// `loadPlans()`
  Future<void> _loadPlans() async {
    if (!mounted) return;
    final ctrl = _ctrl;
    setState(() => _isLoading = true);
    try {
      final plans = await ctrl.loadPlanList();
      if (mounted) setState(() => _plans = plans);
    } catch (_) {
      if (mounted) setState(() => _plans = const []);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _planUpdate(Map<String, dynamic> plan) => context.go('/institutesplanupdate/${planText(plan['id'])}');

  void _openDeleteDialog(Map<String, dynamic> plan) {
    showInstitutePlanDeleteDialog(
      context,
      planName: plan['name'],
      onDelete: (close) => _confirmDelete(plan, close),
    );
  }

  /// `confirmDelete()`
  Future<void> _confirmDelete(Map<String, dynamic> plan, VoidCallback close) async {
    final id = plan['id'];
    if (id == null) return;
    try {
      final res = await _ctrl.deletePlan(id as Object);
      institutePlanToastDeleted(res);
      close();
      await _loadPlans();
    } catch (_) {
      AppToast.error('Failed to delete plan');
    }
  }

  /// `openViewDialog(plan.id)`
  void _openViewDialog(Map<String, dynamic> plan) {
    final ctrl = _ctrl;
    final id = plan['id'] ?? 'undefined';
    showAppDialog<void>(
      context,
      builder: (_) => _PlanViewDialog(load: () => ctrl.fetchPlanDetails(id as Object)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(institutePlanControllerProvider);
    final primary = context.colors.primary;
    // `min-[1600px]:` variants.
    final big = context.screenWidth >= 1600;

    // `min-[1600px]:text-2xl min-[1600px]:p-7`: the 28px padding outgrows
    // `h-9`, so the button is 56px tall there.
    final createButton = AppButton(
      height: big ? 56 : null,
      padding: big ? const EdgeInsets.symmetric(horizontal: 28) : null,
      fontSize: big ? 24 : null,
      onPressed: _isCreateBtnLoading ? null : _submitForm,
      child: _isCreateBtnLoading ? InstitutePlanSpinner(size: big ? 24 : 14) : const Text('Create'),
    );

    final createCard = InstitutePlanCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Text(
            'Create Subscription Plan',
            style: TextStyle(
              fontSize: big ? 36 : 20,
              height: big ? 40 / 36 : 28 / 20,
              fontWeight: FontWeight.w600,
              color: primary,
            ),
          ),
        ),
        InstitutePlanGrid(
          columns: context.isXl ? 2 : 1,
          cells: [
            for (final f in institutePlanFields)
              InstitutePlanInput(
                spec: f,
                controller: _inputs[f.key]!,
                big: big,
                onChanged: (v) => _ctrl.setFormValue(f.key, v),
              ),
            _classField(s, big),
            const SizedBox.shrink(),
            const SizedBox.shrink(),
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [createButton]),
            ),
          ],
        ),
      ],
    );

    final listCard = InstitutePlanCard(
      padding: const EdgeInsets.all(8),
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(
            'Subscription Plan',
            style: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, color: primary),
          ),
        ),
        InstitutePlanTable(
          plans: _plans,
          loading: _isLoading,
          createdAtLabel: 'Created At',
          onNameTap: _openViewDialog,
          onEdit: _planUpdate,
          onDelete: _openDeleteDialog,
        ),
      ],
    );

    return LoadingOverlay(
      loading: _isLoading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [createCard, const SizedBox(height: 24), listCard],
        ),
      ),
    );
  }

  /// The `class_id` FormField: the multi-select plus the access panel.
  Widget _classField(InstitutePlanState s, bool big) {
    final form = s.subscriptionForm;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        InstitutePlanFieldLabel('All Class', required: true, big: big),
        const SizedBox(height: 8),
        // `<SelectTrigger class="overflow-hidden w-full p-[2%] text-[90%]">`,
        // `<SelectContent class="h-[200px] overflow-y-auto">`.
        InstitutePlanMultiSelect(
          items: [
            for (final c in s.allClasses)
              if (asInt(c['id']) != null) AppSelectItem(asInt(c['id'])!, planText(c['name'])),
          ],
          selected: form.classId,
          onToggle: _toggleClass,
          paddingFactor: 0.02,
          fixedMenuHeight: true,
        ),
        // The panel is another grid child of the FormItem: `gap-2` + `mt-6`.
        if (form.zslClasses.isNotEmpty) ...[
          const SizedBox(height: 32),
          _accessPanel(s),
        ],
      ],
    );
  }

  /// Access Control Panel
  Widget _accessPanel(InstitutePlanState s) {
    final dark = context.isDark;
    final wide = context.isSm;
    final primary = context.colors.primary;
    final border = institutePlanBorder(context);
    final rows = s.subscriptionForm.zslClasses;
    return Container(
      padding: EdgeInsets.all(wide ? 24 : 16),
      decoration: BoxDecoration(
        color: dark ? Tw.gray900 : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (wide)
                Container(
                  padding: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
                  child: DefaultTextStyle.merge(
                    style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: primary),
                    child: Row(
                      children: [
                        ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: w * 0.4),
                          child: const Text('Class Access'),
                        ),
                        const Spacer(),
                        SizedBox(width: w * 0.6, child: const Text('Class Access Type')),
                      ],
                    ),
                  ),
                ),
              for (final item in rows) ...[
                const SizedBox(height: 24),
                _accessRow(s, item, w, wide),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _accessRow(InstitutePlanState s, InstitutePlanClassAccess item, double w, bool wide) {
    final name = Text(
      _classNameById(s, item.classId),
      style: TextStyle(fontSize: 14, height: 20 / 14, color: context.isDark ? Tw.gray200 : Tw.gray700),
    );
    final select = institutePlanAccessSelect(
      plans: s.plansByClass(item.classId),
      value: item.zslPlanId,
      placeholder: 'Select class access',
      onChanged: (v) => _ctrl.setZslPlanId(item.classId, v),
    );
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [name, const SizedBox(height: 16), select],
      );
    }
    return Row(
      children: [
        ConstrainedBox(constraints: BoxConstraints(maxWidth: w * 0.4), child: name),
        const Spacer(),
        SizedBox(width: w * 0.6, child: select),
      ],
    );
  }
}

// ─── VIEW DIALOG ───

/// `<Dialog v-model:open="isViewDialogOpen">`: loads the plan, shows the
/// skeleton meanwhile, and closes with a toast when loading fails.
class _PlanViewDialog extends StatefulWidget {
  const _PlanViewDialog({required this.load});
  final Future<dynamic> Function() load;

  @override
  State<_PlanViewDialog> createState() => _PlanViewDialogState();
}

class _PlanViewDialogState extends State<_PlanViewDialog> {
  bool _isViewLoading = true;
  Map<String, dynamic>? _viewPlan;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await widget.load();
      if (mounted) setState(() => _viewPlan = asMap(res));
    } catch (_) {
      AppToast.error('Failed to load plan details');
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isViewLoading = false);
    }
  }

  /// `{{ v ?? '—' }}`
  static String _orDash(Object? v) => v == null ? '—' : planText(v);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final plan = _viewPlan;
    final Widget content;
    if (_isViewLoading) {
      content = _skeleton();
    } else if (plan != null) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(plan),
          Flexible(child: SingleChildScrollView(child: _body(plan))),
          _footer(),
        ],
      );
    } else {
      content = const SizedBox(height: 60);
    }
    return InstitutePlanDialogShell(
      // `w-full sm:max-w-[80%] max-h-[90vh]`
      width: context.isSm ? size.width * 0.8 : size.width - 32,
      maxHeight: size.height * 0.9,
      child: content,
    );
  }

  Widget _skeleton() {
    const bars = [(0.5, 20.0), (1.0, 16.0), (0.75, 16.0), (1.0, 16.0), (2 / 3, 16.0)];
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, (factor, height)) in bars.indexed) ...[
            if (i > 0) const SizedBox(height: 12),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: factor,
              child: Skeleton(height: height, radius: 4),
            ),
          ],
        ],
      ),
    );
  }

  Widget _header(Map<String, dynamic> plan) {
    final dark = context.isDark;
    final primary = context.colors.primary;
    final muted = institutePlanMutedFg(context);
    final border = institutePlanBorder(context);
    final mutedBg = dark ? AppColors.darkMuted : AppColors.muted;
    final active = jsTruthy(plan['is_active']);
    final pillFg = active ? (dark ? Tw.green400 : Tw.green700) : muted;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: mutedBg.withValues(alpha: 0.3),
        border: Border(bottom: BorderSide(color: border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(BootstrapIcons.box, size: 18, color: primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PLAN DETAILS',
                        style: TextStyle(fontSize: 11, height: 1.5, letterSpacing: 1.1, color: primary),
                      ),
                      const SizedBox(height: 4),
                      // `text-lg font-semibold truncate`: the page's `text-lg`
                      // drops the kit's `leading-none` (28px line).
                      Text(
                        planText(plan['name']),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 28 / 18),
                      ),
                      const SizedBox(height: 4),
                      DefaultTextStyle.merge(
                        style: TextStyle(fontSize: 12, height: 16 / 12, color: muted),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 4,
                          children: [
                            _meta(BootstrapIcons.hash, planText(plan['slug']), muted),
                            _meta(BootstrapIcons.calendar3, formatPlanDate(plan['created_at']), muted),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: active ? (dark ? Tw.green900.withValues(alpha: 0.2) : Tw.green50) : mutedBg,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: active ? (dark ? Tw.green800 : Tw.green200) : border),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(BootstrapIcons.circle_fill, size: 6, color: pillFg),
                const SizedBox(width: 4),
                Text(active ? 'Active' : 'Inactive', style: TextStyle(fontSize: 11, height: 1.5, color: pillFg)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _meta(IconData icon, String text, Color color) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [Icon(icon, size: 12, color: color), const SizedBox(width: 4), Text(text)],
      );

  Widget _body(Map<String, dynamic> plan) {
    final primary = context.colors.primary;
    final muted = institutePlanMutedFg(context);
    final border = institutePlanBorder(context);
    final divider = Border(bottom: BorderSide(color: border));
    final sectionLabel =
        TextStyle(fontSize: 11, height: 1.5, letterSpacing: 1.1, color: primary, fontWeight: FontWeight.w700);

    Widget metric(String label, String value) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              Text(label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, height: 1.5, color: primary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(
                value,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, height: 28 / 18, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        );

    Widget limit(String label, Object? count, Object? cost) => Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(border: Border.all(color: border), borderRadius: BorderRadius.circular(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(fontSize: 12, height: 16 / 12, color: muted, fontWeight: FontWeight.w700)),
              Text(planText(count), style: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text('₹${planText(cost)} / each', style: TextStyle(fontSize: 11, height: 20 / 14, color: muted)),
            ],
          ),
        );

    Widget about(String label, Object? value) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(fontSize: 12, height: 16 / 12, color: muted)),
            const SizedBox(height: 4),
            Text(_orDash(value), style: const TextStyle(fontSize: 14, height: 20 / 14)),
          ],
        );

    final zslPlans = [for (final p in asList(plan['zsl_plans'])) ?asMap(p)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Metrics
        Container(
          decoration: BoxDecoration(border: divider),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: metric('Price', '₹${_orDash(plan['price'])}')),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: border), right: BorderSide(color: border)),
                    ),
                    child: metric('Display', _orDash(plan['display_price'])),
                  ),
                ),
                Expanded(child: metric('Days', _orDash(plan['days']))),
              ],
            ),
          ),
        ),

        // Usage limits
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(border: divider),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('USAGE LIMITS', style: sectionLabel),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: limit('Students', plan['students'], plan['cost_per_student'])),
                    const SizedBox(width: 12),
                    Expanded(child: limit('Teachers', plan['instructors'], plan['cost_per_instructor'])),
                    const SizedBox(width: 12),
                    Expanded(child: limit('Classes', plan['classes'], plan['cost_per_class'])),
                  ],
                ),
              ),
            ],
          ),
        ),

        // About
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          decoration: BoxDecoration(border: divider),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // `<h1>` (preflight: the inherited 16px / 24px line).
              Text('ABOUT',
                  style: TextStyle(
                      fontSize: 16, height: 1.5, letterSpacing: 1.6, color: primary, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              about('Description', plan['description']),
              const SizedBox(height: 16),
              about('Display Description', plan['display_description']),
            ],
          ),
        ),

        // Class access
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('CLASS ACCESS', style: TextStyle(fontSize: 11, height: 1.5, letterSpacing: 1.1, color: muted)),
              const SizedBox(height: 12),
              if (zslPlans.isNotEmpty)
                for (var i = 0; i < zslPlans.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _classAccessRow(zslPlans[i]),
                ]
              else
                Text('No classes assigned', style: TextStyle(fontSize: 14, height: 20 / 14, color: muted)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _classAccessRow(Map<String, dynamic> p) {
    final dark = context.isDark;
    final muted = institutePlanMutedFg(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: institutePlanBorder(context)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: dark ? AppColors.darkMuted : AppColors.muted,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(BootstrapIcons.mortarboard_fill, size: 16, color: muted),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  planText(p['class_name']),
                  style: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${planText(p['syllabus'])} • ${planText(p['duration'])} days',
                  style: TextStyle(fontSize: 11, height: 1.5, color: muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${planText(p['price'])}',
                style: const TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500),
              ),
              if (jsTruthy(p['full_access']))
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: Tw.blue50, borderRadius: BorderRadius.circular(999)),
                  child: const Text('Full access', style: TextStyle(fontSize: 10, color: Tw.blue600)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footer() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: institutePlanBorder(context)))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            AppButton(
              variant: AppButtonVariant.outline,
              onPressed: () => Navigator.of(context).pop(),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [Icon(BootstrapIcons.x_lg, size: 11), SizedBox(width: 8), Text('Close')],
              ),
            ),
          ],
        ),
      );
}
