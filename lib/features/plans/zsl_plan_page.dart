import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../../widgets/form_fields.dart';
import 'zsl_plan_controller.dart';
import 'zsl_plan_utils.dart';
import 'zsl_plan_widgets.dart';

/// Port of `src/pages/Institute/Zslplan.vue` (`/zslplan`, "Class Access
/// Types"): the create form plus the paginated list with update / delete
/// dialogs.
class ZslPlanPage extends ConsumerStatefulWidget {
  const ZslPlanPage({super.key});

  @override
  ConsumerState<ZslPlanPage> createState() => _ZslPlanPageState();
}

class _ZslPlanPageState extends ConsumerState<ZslPlanPage> {
  // ── Create form state ──
  final _formKey = GlobalKey<FormState>();
  var _autovalidate = AutovalidateMode.disabled;
  bool _isSubmitting = false;
  Map<String, dynamic> _formData = zslEmptyCreateForm();
  final _className = TextEditingController();
  final _duration = TextEditingController();
  final _price = TextEditingController();

  // ── List state ──
  bool _isLoading = false;
  final _search = TextEditingController();
  static const _paginate = true;

  ZslPlanController get _ctrl => ref.read(zslPlanControllerProvider.notifier);
  ZslPlanState get _st => ref.read(zslPlanControllerProvider);

  @override
  void initState() {
    super.initState();
    // `displayedClasses` switches to the search results as soon as a term is typed.
    _search.addListener(() => setState(() {}));
    // mounted(): loadStates(); getAllClasses(); loadData(); — none awaited.
    Future.microtask(() {
      _ctrl.loadStates().ignore();
      _ctrl.getAllClasses().ignore();
      _loadData().ignore();
    });
  }

  @override
  void dispose() {
    _className.dispose();
    _duration.dispose();
    _price.dispose();
    _search.dispose();
    super.dispose();
  }

  // ── Create methods ──

  /// `onSyllabusChange()`: clears the name, class and price.
  void _onSyllabusChanged(Object? value) {
    if (value == _formData['syllabus']) return;
    setState(() {
      _formData['syllabus'] = value;
      _formData['class_name'] = '';
      _className.clear();
      _formData['class_id'] = null;
      _formData['price'] = null;
      _price.clear();
    });
  }

  /// `v-model="formData.class_id"` + `onClassNameChange()`.
  void _onClassChanged(Object? id) => setState(() => _formData['class_id'] = id);

  /// `handleSubmit()` — runs only once the browser-style validation passes
  /// (`@submit.prevent` on a form with `required` / `min` / `step` inputs).
  Future<void> _handleSubmit() async {
    if (_isSubmitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) {
      setState(() => _autovalidate = AutovalidateMode.onUserInteraction);
      return;
    }
    setState(() => _isSubmitting = true);
    try {
      final response = await _ctrl.createNewClass({..._formData});
      if (jsTruthy(response)) {
        _resetForm();
        await _loadData();
      }
    } catch (_) {
      // Logged on the web; the API client already toasted it.
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// `resetForm()`
  void _resetForm() {
    if (!mounted) return;
    _formKey.currentState?.reset();
    setState(() {
      _formData = zslEmptyCreateForm();
      _className.clear();
      _duration.clear();
      _price.clear();
      _autovalidate = AutovalidateMode.disabled;
    });
  }

  // ── List methods ──

  /// `loadData(page)`: the list, then states / all classes when still empty.
  Future<void> _loadData([int page = 1]) async {
    setState(() => _isLoading = true);
    try {
      await _ctrl.fetchZslClassesplan(_paginate, page);
      if (_st.states.isEmpty) await _ctrl.loadStates();
      if (_st.allClasses.isEmpty) await _ctrl.getAllClasses();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// `changePage(page)`
  void _changePage(int page) {
    final p = _st.zslPagination;
    if (p == null || page < 1 || page > p.lastPage) return;
    _loadData(page).ignore();
  }

  /// `handleSearch()` — the web fires the request without awaiting it, so
  /// the skeleton never shows for a search.
  void _handleSearch() {
    final query = _search.text.trim();
    if (query.isEmpty) {
      _ctrl.fetchZslClassesplan(_paginate).ignore();
    } else {
      _ctrl.fetchsearchZslClasses(query).ignore();
    }
  }

  /// `openDeleteConfirm(id)` + `confirmDeletePlan()`
  Future<void> _openDeleteConfirm(Object? id) async {
    await showZslPlanDeleteDialog(
      context,
      title: 'Delete Class Access Type',
      onConfirm: () async {
        if (!jsTruthy(id)) throw StateError('no pending id');
        await _ctrl.deleteZslPlan(id!);
      },
    );
  }

  /// `openUpdateDialog(id)` + `submitUpdate()` (reloads the current page after saving).
  Future<void> _openUpdateDialog(Object? id) async {
    try {
      await _ctrl.fetchZslPlanById(id ?? 'undefined');
    } catch (_) {
      return;
    }
    final plan = _st.selectedZslPlan;
    if (plan == null || !mounted) return;
    final saved = await showZslPlanUpdateDialog(
      context,
      editForm: zslEditFormFrom(plan),
      title: 'Update Class Access Type',
      primaryTitle: true,
      showNameField: true,
      borderedCancel: true,
      onSubmit: (form) => _ctrl.updateZslPlan(form['id'], zslUpdatePayload(form)),
    );
    if (saved && mounted) {
      try {
        await _loadData(_st.zslPagination?.currentPage ?? 1);
      } catch (_) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(zslPlanControllerProvider);
    final displayed = _search.text.trim().isNotEmpty ? s.searchZslClass : s.zslClasses;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _createCard(s),
          const SizedBox(height: 24),
          _listCard(s, displayed),
        ],
      ),
    );
  }

  // ─── CARD 1: CREATE ───
  Widget _createCard(ZslPlanState s) {
    final filteredClasses = zslClassesForSyllabus(s.allClasses, _formData['syllabus']);
    final hasClass = jsTruthy(_formData['class_id']);

    final planAccess = AppSelect<Object?>(
      value: _formData['has_full_access'],
      placeholder: 'Select Plan Access',
      items: const [AppSelectItem(true, 'Full Access'), AppSelectItem(false, 'Demo Access')],
      onChanged: (v) => setState(() => _formData['has_full_access'] = v),
    );

    return PlanCard(
      shadowMd: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Create Class Access Types',
            style: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w700, color: context.colors.primary),
          ),
          // `mb-6` + the card's `gap-6`.
          const SizedBox(height: 48),
          Form(
            key: _formKey,
            autovalidateMode: _autovalidate,
            child: PlanFormGrid(
              twoColumns: context.isMd,
              columnGap: 24,
              rowGap: 16,
              cells: [
                PlanGridCell(AppSelect<Object?>(
                  label: 'Syllabus',
                  value: _formData['syllabus'],
                  placeholder: 'Select Syllabus',
                  items: const [AppSelectItem('CBSE', 'CBSE'), AppSelectItem('STATE', 'STATE')],
                  onChanged: _onSyllabusChanged,
                )),
                PlanGridCell(AppSelect<Object?>(
                  label: 'Class Name',
                  value: _formData['class_id'],
                  enabled: filteredClasses.isNotEmpty,
                  placeholder: filteredClasses.isNotEmpty ? 'Select Class' : 'Select Syllabus first',
                  items: [
                    for (final c in filteredClasses) AppSelectItem<Object?>(c['id'], jsDisplay(c['name'])),
                  ],
                  onChanged: _onClassChanged,
                )),
                PlanGridCell(AppTextField(
                  controller: _className,
                  label: 'Name',
                  hint: 'Enter name',
                  validator: requiredTextError,
                  onChanged: (v) => _formData['class_name'] = v,
                  onSubmitted: (_) => _handleSubmit(),
                )),
                PlanGridCell(AppSelect<Object?>(
                  label: 'State',
                  value: _formData['state_id'],
                  placeholder: 'Select State',
                  items: [for (final st in s.states) AppSelectItem<Object?>(st['id'], jsDisplay(st['name']))],
                  onChanged: (v) => setState(() => _formData['state_id'] = v),
                )),
                PlanGridCell(AppTextField(
                  controller: _duration,
                  label: 'Duration (Days)',
                  hint: 'Enter days',
                  keyboardType: planNumberKeyboard,
                  inputFormatters: planNumberInputFormatters,
                  validator: (v) => numberFieldError(v, required: true),
                  onChanged: (v) => _formData['duration'] = numberInputValue(v),
                  onSubmitted: (_) => _handleSubmit(),
                )),
                PlanGridCell(AppTextField(
                  controller: _price,
                  label: 'Price (₹)',
                  hint: 'Enter price',
                  enabled: hasClass,
                  keyboardType: planNumberKeyboard,
                  inputFormatters: planNumberInputFormatters,
                  // Disabled inputs are skipped by the browser's validation.
                  validator: (v) => hasClass ? numberFieldError(v, required: true, min: 0, step: 1) : null,
                  onChanged: (v) => _formData['price'] = numberInputValue(v),
                  onSubmitted: (_) => _handleSubmit(),
                )),
                PlanGridCell(
                  LabeledField(
                    label: 'Plan Access',
                    child: context.isSm
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(widthFactor: 0.5, child: planAccess),
                          )
                        : planAccess,
                  ),
                  fullRow: true,
                ),
                PlanGridCell(
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Align(
                      alignment: Alignment.centerRight,
                      // `w-full md:w-auto`; while submitting: `<span class="flex
                      // items-center gap-2"><i class="bi bi-arrow-repeat
                      // animate-spin" /> Creating...</span>`.
                      child: AppButton(
                        expand: !context.isMd,
                        onPressed: _isSubmitting ? null : _handleSubmit,
                        child: _isSubmitting
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [PlanSpinIcon(), SizedBox(width: 8), Flexible(child: Text('Creating...'))],
                              )
                            : const Text('Create'),
                      ),
                    ),
                  ),
                  fullRow: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── CARD 2: LIST ───
  Widget _listCard(ZslPlanState s, List<Map<String, dynamic>> displayed) {
    // `<h2 class="text-xl font-bold mb-6 text-primary">` (the `mb-6` stays
    // inside the flex item, so the row centres title + margin).
    final title = Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Text(
        'Class Access Types',
        style: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w700, color: context.colors.primary),
      ),
    );
    final search = AppSearchBar(controller: _search, hint: 'Search Classess...', onSearch: _handleSearch);

    return PlanCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (context.isSm)
            Row(
              children: [
                Expanded(child: Align(alignment: Alignment.centerLeft, child: title)),
                const SizedBox(width: 16),
                SizedBox(width: zslSearchBarWidth, child: search),
              ],
            )
          else ...[
            title,
            const SizedBox(height: 16),
            search,
          ],
          // The card's `gap-6`.
          const SizedBox(height: 24),
          ZslPlanTable(
            plans: displayed,
            loading: _isLoading,
            onEdit: (plan) => _openUpdateDialog(plan['id']),
            onDelete: (plan) => _openDeleteConfirm(plan['id']),
          ),
          const SizedBox(height: 24),
          ZslPagination(meta: s.zslPagination, onPageChanged: _changePage),
        ],
      ),
    );
  }
}
