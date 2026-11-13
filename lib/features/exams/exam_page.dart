import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_table.dart';
import '../../widgets/form_fields.dart';
import 'exam_create_view.dart';
import 'exam_widgets.dart';
import 'exams_controller.dart';
import 'exams_logic.dart';

part 'exams_list_view.dart';

/// Port of `src/pages/exams/exam.vue` (`/exams`): the exams list
/// (`ExamsList.vue`) or the create form (`examcreate.vue`) in one card.
class ExamPage extends ConsumerStatefulWidget {
  const ExamPage({super.key});

  @override
  ConsumerState<ExamPage> createState() => _ExamPageState();
}

class _ExamPageState extends ConsumerState<ExamPage> {
  bool _showExamCreate = false;
  int _listKey = 0;

  /// `handleExamCreated`
  void _handleExamCreated() => setState(() {
        _showExamCreate = false;
        _listKey++;
      });

  @override
  Widget build(BuildContext context) {
    final role = ref.watch(sessionProvider).role;
    final staff = role != Role.student && role != Role.institute;

    final header = Row(
      children: [
        Expanded(
          child: Text(
            _showExamCreate ? 'Create Exam' : 'Exams',
            style: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600, color: context.colors.primary),
          ),
        ),
        Flexible(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!_showExamCreate && staff) ...[
                  AppButton(label: 'Create Exam', onPressed: () => setState(() => _showExamCreate = true)),
                  const SizedBox(width: 12),
                ],
                if (staff)
                  AppButton(
                    label: 'Back to List',
                    variant: AppButtonVariant.outline,
                    onPressed: () => setState(() => _showExamCreate = false),
                  ),
              ],
            ),
          ),
        ),
      ],
    );

    return SingleChildScrollView(
      child: ExamCard(
        margin: const EdgeInsets.all(8),
        padding: EdgeInsets.all(context.isSm ? 16 : 8),
        child: GapColumn(
          children: [
            header,
            if (!_showExamCreate)
              _ExamsListView(key: ValueKey(_listKey))
            else
              ExamCreateView(onExamCreated: _handleExamCreated, cardSpacing: 40),
          ],
        ),
      ),
    );
  }
}
