import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart' show AppSelectItem;
import 'institute_plan_controller.dart';
import 'institute_plan_widgets.dart';

/// Port of `src/pages/Institute/InstituteplanUpdate.vue`
/// (`/institutesplanupdate/:id`). [id] is the `:id` route param.
class InstitutePlanUpdatePage extends ConsumerStatefulWidget {
  const InstitutePlanUpdatePage({super.key, required this.id});
  final String id;

  @override
  ConsumerState<InstitutePlanUpdatePage> createState() => _InstitutePlanUpdatePageState();
}

class _InstitutePlanUpdatePageState extends ConsumerState<InstitutePlanUpdatePage> {
  // data()
  bool _isLoading = false;
  bool _isCreateBtnLoading = false;
  List<int> _fetchedPlanClasses = [];
  final Map<String, TextEditingController> _inputs = {};

  InstitutePlanController get _ctrl => ref.read(institutePlanControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    // Like the web, the inputs show whatever the store form holds until the
    // plan has loaded.
    final form = ref.read(institutePlanControllerProvider).subscriptionForm;
    for (final f in institutePlanFields) {
      _inputs[f.key] = TextEditingController(text: planText(form[f.key]));
    }
    Future.microtask(_mounted);
  }

  @override
  void dispose() {
    for (final c in _inputs.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _syncInputs(InstitutePlanForm form) {
    for (final f in institutePlanFields) {
      final text = planText(form[f.key]);
      final c = _inputs[f.key]!;
      if (c.text != text) c.text = text;
    }
  }

  /// `mounted()`
  Future<void> _mounted() async {
    if (!mounted) return;
    final ctrl = _ctrl;
    setState(() => _isLoading = true);
    try {
      // 1. Load classes first so getClassNameById works
      await ctrl.getAllClasses();

      final id = widget.id;
      if (id.isNotEmpty) {
        final oldClassIds = ctrl.current.subscriptionForm.classId;
        final res = await ctrl.getPlanById(planNumber(id) ?? 'NaN');
        if (mounted) _syncInputs(ctrl.current.subscriptionForm);

        // Replacing the store form fires the `form.class_id` watcher on the
        // web *before* the rest of mounted() runs, so it starts fetching the
        // plans of the first newly listed class while `fetchedPlanClasses`
        // is still empty; the classes after it are then skipped because of
        // step 3. Same order here.
        unawaited(_onClassIdsChanged(ctrl, ctrl.current.subscriptionForm.classId, oldClassIds));

        // 2. Populate the plans cache so dropdowns aren't empty
        final zslPlans = asMap(res)?['zsl_plans'];
        if (jsTruthy(zslPlans)) {
          for (final p in asList(zslPlans)) {
            final plan = asMap(p);
            if (plan != null) ctrl.cachePlanIfMissing(plan);
          }
        }

        // 3. Set the tracking array to prevent watcher from re-fetching
        _fetchedPlanClasses = [...ctrl.current.subscriptionForm.classId];
      }
    } catch (_) {
      // Failed to load data (API errors were toasted by the API client).
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// `watch: 'form.class_id'` — fetch the ZSL plans of newly selected
  /// classes not fetched yet, then rebuild `zsl_classes` keeping selections.
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
    ctrl.syncZslClassesForUpdate(newVal);
  }

  /// Toggling an item of the `multiple` class select.
  void _toggleClass(int id) {
    final ctrl = _ctrl;
    final old = ctrl.current.subscriptionForm.classId;
    final next = old.contains(id) ? [for (final x in old) if (x != id) x] : [...old, id];
    ctrl.setClassIds(next);
    unawaited(_onClassIdsChanged(ctrl, next, old));
  }

  /// `getClassNameById(id)`: the plan's own `zsl_plans` first, then
  /// `allclasses`, else a loading text.
  String _classNameById(InstitutePlanState s, int id) {
    for (final p in s.subscriptionForm.zslPlans) {
      if (asInt(planNumber(p['class_id'])) == id) {
        if (jsTruthy(p['class_name'])) return planText(p['class_name']);
        break;
      }
    }
    if (s.allClasses.isNotEmpty) {
      for (final c in s.allClasses) {
        if (asInt(planNumber(c['id'])) == id) return planText(c['name']);
      }
    }
    return 'Loading Class Name...';
  }

  /// `updateForm()`
  Future<void> _updateForm() async {
    final ctrl = _ctrl;
    setState(() {
      _isLoading = true;
      _isCreateBtnLoading = true;
    });
    try {
      await ctrl.updatePlan();
      if (mounted) context.go('/institutesplanCreate');
    } catch (_) {
      // Update failed — logged only on the web (API errors were toasted).
    } finally {
      if (mounted) {
        setState(() {
          _isCreateBtnLoading = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(institutePlanControllerProvider);
    final form = s.subscriptionForm;
    final primary = context.colors.primary;

    final classField = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const InstitutePlanFieldLabel('All Class', required: true),
        const SizedBox(height: 8),
        // `<SelectTrigger class="p-[1%] w-[50%] text-[90%]">`,
        // `<SelectContent class="max-h-[200px] overflow-y-auto">`.
        InstitutePlanMultiSelect(
          items: [
            for (final c in s.allClasses)
              if (asInt(planNumber(c['id'])) != null) AppSelectItem(asInt(planNumber(c['id']))!, planText(c['name'])),
          ],
          selected: form.classId,
          onToggle: _toggleClass,
          widthFactor: 0.5,
          paddingFactor: 0.01,
        ),
      ],
    );

    // No page wrapper on the web: the card sits directly in the layout's
    // scroll area (whose `md:pb-6` the shell already adds).
    return LoadingOverlay(
      loading: _isLoading,
      child: SingleChildScrollView(
        child: InstitutePlanCard(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Update Subscription Plan',
                style: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, color: primary),
              ),
            ),

            // FORM GRID (`md:grid-cols-3`, the class select spans all columns)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InstitutePlanGrid(
                  columns: context.isMd ? 3 : 1,
                  cells: [
                    for (final f in institutePlanFields)
                      InstitutePlanInput(
                        spec: f,
                        controller: _inputs[f.key]!,
                        onChanged: (v) => _ctrl.setFormValue(f.key, v),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                classField,
              ],
            ),

            // CLASS ACCESS SECTION
            if (form.zslClasses.isNotEmpty)
              Padding(padding: const EdgeInsets.only(top: 24), child: _accessPanel(s)),

            // UPDATE BUTTON
            Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppButton(
                    onPressed: _isCreateBtnLoading ? null : _updateForm,
                    child: _isCreateBtnLoading ? const InstitutePlanSpinner() : const Text('Update'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

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
              // HEADER
              if (wide)
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: border))),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    // `text-sm sm:text-base font-semibold … text-primary` (the
                    // header only shows from 640px: 16px / 24px line).
                    child: DefaultTextStyle.merge(
                      style: TextStyle(fontSize: 16, height: 1.5, fontWeight: FontWeight.w600, color: primary),
                      child: Row(
                        children: [
                          const Expanded(child: Text('Class Access')),
                          SizedBox(width: w * 0.6, child: const Text('Class Access Type')),
                        ],
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              // CLASS PLAN LIST
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0) const SizedBox(height: 16),
                _accessRow(s, rows[i], w, wide, last: i == rows.length - 1),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _accessRow(InstitutePlanState s, InstitutePlanClassAccess item, double w, bool wide, {required bool last}) {
    final name = Text(
      _classNameById(s, item.classId),
      style: TextStyle(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w500,
        color: context.isDark ? Tw.gray200 : Tw.gray700,
      ),
    );
    final select = institutePlanAccessSelect(
      plans: s.plansByClass(item.classId),
      value: item.zslPlanId,
      placeholder: 'Select Plan',
      onChanged: (v) => _ctrl.setZslPlanId(item.classId, v),
    );
    return Container(
      padding: const EdgeInsets.only(bottom: 16),
      // `border-b sm:border-none last:border-none`
      decoration: BoxDecoration(
        border: !wide && !last ? Border(bottom: BorderSide(color: institutePlanBorder(context))) : null,
      ),
      child: wide
          ? Row(
              children: [
                ConstrainedBox(constraints: BoxConstraints(maxWidth: w * 0.4), child: name),
                const Spacer(),
                SizedBox(width: w * 0.6, child: select),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [name, const SizedBox(height: 12), select],
            ),
    );
  }
}
