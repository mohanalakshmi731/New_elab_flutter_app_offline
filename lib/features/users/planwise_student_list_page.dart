import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_table.dart';
import '../../widgets/form_fields.dart';
import 'users_logic.dart';
import 'users_widgets.dart';

/// Port of `src/components/planwisestudentlist.vue` (`/studentslistplanwise`).
///
/// The router passes `route.query` as a prop, but the web component never
/// declares or reads it; the screen is a static mock (hard-coded students and
/// plans, updates are local only). Both are kept as is.
class PlanwiseStudentListPage extends StatefulWidget {
  const PlanwiseStudentListPage({super.key, this.query = const {}});

  /// `route.query` (unused by the web component).
  final Map<String, String> query;

  @override
  State<PlanwiseStudentListPage> createState() => _PlanwiseStudentListPageState();
}

class _Plan {
  const _Plan(this.id, this.name, this.days);
  final int id;
  final String name;
  final int days;
}

class _PlanwiseStudentListPageState extends State<PlanwiseStudentListPage> {
  // data()
  final List<Map<String, dynamic>> _students = [
    {'id': 1, 'name': 'Ravi Kumar', 'email': 'ravi@gmail.com', 'plan_id': 1, 'expire_date': '2026-05-01'},
    {'id': 2, 'name': 'Anjali Sharma', 'email': 'anjali@gmail.com', 'plan_id': 2, 'expire_date': '2026-06-15'},
    {'id': 3, 'name': 'Rahul Reddy', 'email': 'rahul@gmail.com', 'plan_id': 3, 'expire_date': '2026-04-30'},
  ];

  static const _plans = [
    _Plan(1, 'Trial Plan', 7),
    _Plan(2, 'Pilot Plan', 30),
    _Plan(3, 'Paid Plan', 90),
  ];

  int? _editingId;
  int? _selectedPlanId;

  _Plan? _plan(Object? id) {
    for (final p in _plans) {
      if (p.id == id) return p;
    }
    return null;
  }

  String _getPlanName(Object? planId) => _plan(planId)?.name ?? '-';

  /// `getPlanBadgeClass(planId)` → (background, text).
  (Color, Color) _getPlanBadgeColors(Object? planId) => switch (planId) {
        1 => (Tw.yellow100, Tw.yellow700), // Trial
        2 => (Tw.blue100, Tw.blue700), // Pilot
        3 => (Tw.green100, Tw.green700), // Paid
        _ => (Tw.gray100, Tw.gray600),
      };

  void _startEdit(Map<String, dynamic> student) => setState(() {
        _editingId = student['id'] as int?;
        _selectedPlanId = student['plan_id'] as int?;
      });

  void _cancelEdit() => setState(() {
        _editingId = null;
        _selectedPlanId = null;
      });

  void _saveUpdate(Map<String, dynamic> student) {
    final plan = _plan(_selectedPlanId);
    if (plan == null) return;
    setState(() {
      student['plan_id'] = plan.id;
      student['expire_date'] = planExpiryDate(plan.days);
    });
    _cancelEdit();
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ShadCard(
        padding: const EdgeInsets.all(24),
        radius: 16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Students List',
              style: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, color: context.colors.primary),
            ),
            // mb-4 + the card's gap-6
            const SizedBox(height: 16 + 24),
            // `<Card class="p-0 rounded-2xl">` (border, shadow-sm).
            Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: dark ? AppColors.darkCard : AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: dark ? AppColors.darkBorder : AppColors.border),
                boxShadow: AppShadows.sm,
              ),
              // A shadcn `<Table>` (`text-sm`, `whitespace-nowrap` cells):
              // it scrolls once the row content is wider than the card, which
              // happens sooner while a row shows the plan select.
              child: AppTable(
                card: false,
                fontSize: 14,
                minWidth: _editingId == null ? 600 : 820,
                emptyText: 'No students found',
                emptyPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                columns: const [
                  AppTableColumn('#', flex: 0.4),
                  AppTableColumn('Name', flex: 1.2),
                  AppTableColumn('Email', flex: 1.5),
                  AppTableColumn('Plan'),
                  AppTableColumn('Expire Date'),
                  AppTableColumn('Actions', flex: 3.2),
                ],
                rows: [
                  for (var i = 0; i < _students.length; i++) _row(i, _students[i]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _row(int index, Map<String, dynamic> student) {
    final (badgeBg, badgeFg) = _getPlanBadgeColors(student['plan_id']);
    final expire = '${student['expire_date'] ?? ''}';
    final soon = isExpiringSoon(expire);
    return [
      Text('${index + 1}'),
      Text('${student['name'] ?? ''}'),
      Text('${student['email'] ?? ''}'),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: badgeBg, borderRadius: BorderRadius.circular(999)),
        child: Text(
          _getPlanName(student['plan_id']),
          style: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: badgeFg),
        ),
      ),
      Text(
        expire,
        style: soon ? const TextStyle(color: Tw.red500, fontWeight: FontWeight.w500) : null,
      ),
      _editingId != student['id']
          ? AppButton(label: 'Update', size: AppButtonSize.sm, onPressed: () => _startEdit(student))
          // `flex gap-2 items-center`
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 160,
                  child: AppSelect<int>(
                    value: _selectedPlanId,
                    placeholder: 'Select Plan',
                    items: [for (final p in _plans) AppSelectItem(p.id, '${p.name} (${p.days} days)')],
                    onChanged: (v) => setState(() => _selectedPlanId = v),
                  ),
                ),
                const SizedBox(width: 8),
                AppButton(label: 'Save', size: AppButtonSize.sm, onPressed: () => _saveUpdate(student)),
                const SizedBox(width: 8),
                AppButton(
                  label: 'Cancel',
                  size: AppButtonSize.sm,
                  variant: AppButtonVariant.outline,
                  onPressed: _cancelEdit,
                ),
              ],
            ),
    ];
  }
}
