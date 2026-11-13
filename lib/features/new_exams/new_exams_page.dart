import 'dart:math' as math;
import 'dart:ui';

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
import '../../widgets/form_fields.dart';
import '../../widgets/lucide_icon.dart';
import '../exams/exam_create_view.dart';
import '../exams/exam_widgets.dart';
import '../exams/exams_controller.dart';
import '../exams/exams_logic.dart';
import 'new_exams_logic.dart';

part 'new_exams_widgets.dart';
part 'new_exams_list.dart';
part 'new_exams_detail.dart';
part 'new_exams_dialogs.dart';

/// Port of `src/components/new_ui_student_teacher_for_both_labs/newexams.vue`
/// (`/newexams`): one page with four inline views — the exam card grid
/// (`list`), the create form (`create`, embeds [ExamCreateView]), an exam's
/// attempts table (`attempts`) and an attempt's result (`result`) — plus
/// the delete and preview dialogs.
class NewExamsPage extends ConsumerStatefulWidget {
  const NewExamsPage({super.key});

  @override
  ConsumerState<NewExamsPage> createState() => _NewExamsPageState();
}

class _NewExamsPageState extends ConsumerState<NewExamsPage> {
  // ── data() ──
  /// `'list' | 'create' | 'attempts' | 'result'`
  String _currentView = 'list';
  bool _loading = false;
  List<Json> _exams = const [];
  String _activeTab = 'available';
  String _selectedYear = 'all';
  Object _selectedBatch = 'all';
  Json? _examToDelete;
  Json? _previewExam;
  String? _publishing;
  Json? _selectedExam;
  bool _loadingAttempts = false;
  Json? _selectedAttempt;
  String? _loadingResult;

  ExamsController get _ctrl => ref.read(examsControllerProvider.notifier);

  /// `setState` for the part-file extensions.
  void _set(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(_mounted);
  }

  /// `mounted()` — an error in one step stops the rest, like the web.
  Future<void> _mounted() async {
    try {
      await _ctrl.getClasses('published');
      await _loadExams();
      if (ref.read(sessionProvider).role == Role.student) {
        await _ctrl.fetchExamAttempts();
      }
    } catch (_) {}
  }

  // ── computed ──


  /// `studentAttempts` — the raw store `examattempts`.
  List<Json> get _studentAttempts => examMaps(ref.read(examsControllerProvider).examattempts);

  List<Json> get _availableExams => newAvailableExams(_exams, _studentAttempts);
  List<Json> get _inProgressExams => newInProgressExams(_studentAttempts);
  List<Json> get _completedExams => newCompletedExams(_studentAttempts);

  List<Json> get _activeTabExams => switch (_activeTab) {
        'available' => _availableExams,
        'inprogress' => _inProgressExams,
        _ => _completedExams,
      };

  String get _activeTabLabel => switch (_activeTab) {
        'available' => 'Available',
        'inprogress' => 'In Progress',
        'completed' => 'Completed',
        _ => '',
      };

  Object _getAttemptsLeft(Object? examId, Object max) => newAttemptsLeft(_studentAttempts, examId, max);

  // ── methods ──

  Future<void> _loadExams() async {
    try {
      _set(() => _loading = true);
      final locale = localeFromLanguageName(ref.read(sessionProvider).language.name);
      final classId = _selectedYear != 'all' && _selectedYear.isNotEmpty ? jsonNum(jsNum(_selectedYear)) : null;
      final batchId = _selectedBatch != 'all' && jsTruthy(_selectedBatch) ? _selectedBatch : null;
      final res = await _ctrl.fetchExams(locale, classId, batchId);
      _set(() => _exams = examMaps(res));
    } catch (_) {
      _set(() => _exams = const []);
    } finally {
      _set(() => _loading = false);
    }
  }

  /// `watch: selectedBatch`
  void _setBatch(Object v) {
    if (v == _selectedBatch) return;
    _set(() => _selectedBatch = v);
    _loadExams();
  }

  /// `v-model="selectedYear"` + `onYearChange`
  Future<void> _onYearChange(String? value) async {
    _set(() => _selectedYear = value ?? '');
    _setBatch('all');
    final val = value ?? '';
    try {
      if (val.isNotEmpty && val != 'all' && val != 'null') {
        await _ctrl.getBatches(jsonNum(jsNum(val)));
      }
    } catch (_) {
      return;
    }
    await _loadExams();
  }

  Future<void> _publishExam(String examId) async {
    try {
      _set(() => _publishing = examId);
      await _ctrl.examStatus(examId);
      await _loadExams();
    } catch (_) {
    } finally {
      _set(() => _publishing = null);
    }
  }

  void _openDeleteDialog(Json exam) {
    _examToDelete = exam;
    showAppDialog<void>(
      context,
      builder: (_) => _NxDeleteDialog(exam: exam, onConfirm: _confirmDelete),
    );
  }

  /// `confirmDelete` — closes the dialog once the exam is deleted.
  Future<void> _confirmDelete(BuildContext dialogCtx, ValueSetter<bool> setDeleting) async {
    final exam = _examToDelete;
    if (exam == null) return;
    try {
      setDeleting(true);
      await _ctrl.examDelete(exam['id'] ?? 'undefined');
      if (dialogCtx.mounted) Navigator.of(dialogCtx).pop();
      _examToDelete = null;
      await _loadExams();
    } catch (_) {
    } finally {
      setDeleting(false);
    }
  }

  void _openPreview(Json exam) {
    _previewExam = {...exam};
    showAppDialog<void>(context, builder: (_) => _NxPreviewDialog(exam: _previewExam!));
  }

  /// The web pushes the named route `edit-exam`, which the router doesn't
  /// define; this goes to `/editexams/:id` (the `EditExams` route) instead.
  void _editExam(Json exam) => context.go('/editexams/${exam['id']}');

  /// `openExamAttempts` / `openStudentAttempts` (identical): the attempts
  /// table inline. Students always get all of their own attempts.
  Future<void> _openAttempts(Json exam) async {
    _set(() {
      _selectedExam = exam;
      _loadingAttempts = true;
      _currentView = 'attempts';
    });
    try {
      await _ctrl.fetchExamAttempts(exam['id']);
    } catch (_) {
    } finally {
      _set(() => _loadingAttempts = false);
    }
  }

  /// `viewResult(attemptId)` — the attempt's result inline.
  Future<void> _viewResult(String attemptId) async {
    try {
      _set(() => _loadingResult = attemptId);
      await _ctrl.fetchAttemptById(attemptId);
      _set(() {
        _selectedAttempt = asMap(ref.read(examsControllerProvider).attemptexam);
        _currentView = 'result';
      });
    } catch (_) {
    } finally {
      _set(() => _loadingResult = null);
    }
  }

  /// `startexam(examId)` → `/startexam` (attempt handed over through
  /// lmsHandoff `currentExamAttempt`).
  Future<void> _startexam(Object? examId) async {
    dynamic res;
    try {
      res = await _ctrl.startExam(examId ?? 'undefined');
    } catch (_) {
      return;
    }
    if (jsTruthy(res) && mounted) context.go('/startexam');
  }

  void _handleExamCreated() {
    _set(() => _currentView = 'list');
    _loadExams();
  }

  // ── template ──

  @override
  Widget build(BuildContext context) {
    // Re-render when the store's attempts / classes / batches change.
    ref.watch(examsControllerProvider);
    final Widget view = switch (_currentView) {
      'result' => _resultView(),
      'attempts' => _attemptsView(),
      'create' => _createView(),
      _ => _listView(),
    };
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 24),
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: _EnterAnimation(child: view),
          ),
        ),
      ),
    );
  }
}
