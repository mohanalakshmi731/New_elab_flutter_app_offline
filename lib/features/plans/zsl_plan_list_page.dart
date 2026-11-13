import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../data/services/js_compat.dart';
import '../../widgets/app_button.dart';
import '../../widgets/form_fields.dart';
import 'zsl_plan_controller.dart';
import 'zsl_plan_utils.dart';
import 'zsl_plan_widgets.dart';

/// Port of `src/pages/Institute/Zslplanlist.vue` (`/zslplanlist`, "Class
/// Access Types List"). Shares the store slice with `/zslplan` through
/// [zslPlanControllerProvider]; "Create New Plan" opens `/zslplan`.
class ZslPlanListPage extends ConsumerStatefulWidget {
  const ZslPlanListPage({super.key});

  @override
  ConsumerState<ZslPlanListPage> createState() => _ZslPlanListPageState();
}

class _ZslPlanListPageState extends ConsumerState<ZslPlanListPage> {
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
    Future.microtask(() => _loadData().ignore());
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// `loadData(page)`: the list, then states / all classes when still empty
  /// (needed by the update dialog).
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

  /// `handleSearch()` — not awaited on the web, so no skeleton for searches.
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
      title: 'Delete ZSL Plan',
      onConfirm: () async {
        if (!jsTruthy(id)) throw StateError('no pending id');
        await _ctrl.deleteZslPlan(id!);
      },
    );
  }

  /// `openUpdateDialog(id)` + `submitUpdate()`. Unlike `/zslplan` the list is
  /// not reloaded: `updateZslPlan` merges the response into the row.
  Future<void> _openUpdateDialog(Object? id) async {
    try {
      await _ctrl.fetchZslPlanById(id ?? 'undefined');
    } catch (_) {
      return;
    }
    final plan = _st.selectedZslPlan;
    if (plan == null || !mounted) return;
    await showZslPlanUpdateDialog(
      context,
      editForm: zslEditFormFrom(plan),
      title: 'Update ZSL Plan',
      expandSave: true,
      onSubmit: (form) => _ctrl.updateZslPlan(form['id'], zslUpdatePayload(form)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(zslPlanControllerProvider);
    final displayed = _search.text.trim().isNotEmpty ? s.searchZslClass : s.zslClasses;
    final wide = context.isSm;

    // `text-lg sm:text-2xl font-bold tracking-tight` (28 / 32px lines).
    final titleSize = wide ? 24.0 : 18.0;
    final title = Text(
      'ZSL Plan Classes',
      style: TextStyle(
        fontSize: titleSize,
        height: (wide ? 32 : 28) / titleSize,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.025 * titleSize,
      ),
    );
    final search = AppSearchBar(controller: _search, hint: 'Search Classess...', onSearch: _handleSearch);
    // `w-full sm:w-auto shadow-sm transition-all active:scale-95`
    final create = _PressScale(
      child: AppButton(
        label: 'Create New Plan',
        expand: !wide,
        shadow: AppShadows.sm,
        onPressed: () => context.go('/zslplan'),
      ),
    );

    final header = wide
        ? Row(
            children: [
              Expanded(child: Align(alignment: Alignment.centerLeft, child: title)),
              const SizedBox(width: 16),
              SizedBox(width: zslSearchBarWidth, child: search),
              const SizedBox(width: 12),
              create,
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              title,
              const SizedBox(height: 16),
              search,
              const SizedBox(height: 12),
              create,
            ],
          );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          const SizedBox(height: 24),
          ZslPlanTable(
            plans: displayed,
            loading: _isLoading,
            onEdit: (plan) => _openUpdateDialog(plan['id']),
            onDelete: (plan) => _openDeleteConfirm(plan['id']),
          ),
          ZslPagination(meta: s.zslPagination, onPageChanged: _changePage),
        ],
      ),
    );
  }
}

/// `transition-all active:scale-95`: shrinks to 95% while pressed (150ms).
class _PressScale extends StatefulWidget {
  const _PressScale({required this.child});
  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _down = false;

  void _set(bool v) {
    if (_down != v) setState(() => _down = v);
  }

  @override
  Widget build(BuildContext context) => Listener(
        onPointerDown: (_) => _set(true),
        onPointerUp: (_) => _set(false),
        onPointerCancel: (_) => _set(false),
        child: AnimatedScale(
          scale: _down ? 0.95 : 1,
          duration: const Duration(milliseconds: 150),
          curve: const Cubic(0.4, 0, 0.2, 1),
          child: widget.child,
        ),
      );
}
