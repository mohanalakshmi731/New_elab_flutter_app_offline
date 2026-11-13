import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/toast.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_loader.dart';
import 'institute_plan_controller.dart';
import 'institute_plan_widgets.dart';

/// Port of `src/pages/Institute/InstituteplanList.vue` (`/institutesplanList`).
class InstitutePlanListPage extends ConsumerStatefulWidget {
  const InstitutePlanListPage({super.key});

  @override
  ConsumerState<InstitutePlanListPage> createState() => _InstitutePlanListPageState();
}

class _InstitutePlanListPageState extends ConsumerState<InstitutePlanListPage> {
  // data()
  bool _isLoading = false;
  List<Map<String, dynamic>> _plans = const [];

  InstitutePlanController get _ctrl => ref.read(institutePlanControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    Future.microtask(_loadPlans);
  }

  /// `loadPlans()`: errors were toasted by the API client; the web only logs.
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
      _loadPlans();
    } catch (_) {
      AppToast.error('Failed to delete plan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final wide = context.isSm;
    // `text-xl font-semibold` (28px line), outside any card.
    const title = Text('Subscription Types', style: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600));
    final create = AppButton(label: 'Create Subscription Type', onPressed: () => context.go('/institutesplanCreate'));

    return LoadingOverlay(
      loading: _isLoading,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wide)
              Row(children: [const Expanded(child: title), create])
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  title,
                  const SizedBox(height: 12),
                  Align(alignment: Alignment.centerRight, child: create),
                ],
              ),
            const SizedBox(height: 24),
            InstitutePlanTable(
              plans: _plans,
              loading: _isLoading,
              createdAtLabel: 'created At',
              onEdit: _planUpdate,
              onDelete: _openDeleteDialog,
            ),
          ],
        ),
      ),
    );
  }
}
