import 'dart:async';
import 'dart:ui' as ui;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/network/api_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../mathzoro/mathzoro_controller.dart';
import '../mathzoro/mz_ui.dart';
import '../quiz/quiz_exam.dart';
import 'math_play_store.dart';
import 'math_play_ui.dart';

part 'math_play_card.dart';
part 'math_play_overlays.dart';
part 'math_play_widgets.dart';

/// Port of `src/components/Mathzoro/mathplay.vue` (component `SubjectPlay`)
/// — `/mathplay` inside the eLabs DashboardShell.
///
/// No route params / query. Reads `math_zoro_courses` (first course with
/// `is_math_zoro === false`, else the first) from [mathZoroProvider] and
/// `selectedActivityContext.{classId,subjectId,className,subjectName}` via
/// [MathPlayStore]; Play / Quiz write the activity back with
/// `setActivityContext` (lmsHandoff + MathZoro copy); Play then opens
/// `/activitylibrary`.
class MathPlayPage extends ConsumerStatefulWidget {
  const MathPlayPage({super.key});

  @override
  ConsumerState<MathPlayPage> createState() => _MathPlayPageState();
}

TextStyle _nunito({double? size, FontWeight? weight, Color? color, double? height, double? spacing}) =>
    GoogleFonts.nunito(
        fontSize: size, fontWeight: weight, color: color, height: height, letterSpacing: spacing);

/// The page's arbitrary hex colours (Tailwind palette colours come from [Tw]).
abstract final class _C {
  static const ink = Color(0xFF0D0D2B); // bg-[#0d0d2b]
  static const card = Color(0xFF13133A); // bg-[#13133a]
  static const cardLocked = Color(0xFF0F0F30); // bg-[#0f0f30]
  static const cardFallback = Color(0xFF1A1A45); // from-[#1a1a45]
}

/// `TOPIC_COLORS` (bg-green-500, bg-pink-500, …).
const List<Color> _kTopicColors = [
  Tw.green500, Tw.pink500, Tw.orange500, Tw.purple500, Tw.cyan500, Tw.rose500, Tw.indigo500, Tw.teal500,
];

/// An [OverlayPortalController] with enter / leave transitions; the portal is
/// hidden once the leave transition finishes (Vue `<Transition>`).
class _AnimatedPortal {
  _AnimatedPortal(TickerProvider vsync,
      {required Duration enter, required Duration exit, Curve curve = kTwEaseOut, Curve reverseCurve = kTwEaseIn})
      : anim = AnimationController(vsync: vsync, duration: enter, reverseDuration: exit) {
    curved = CurvedAnimation(parent: anim, curve: curve, reverseCurve: reverseCurve);
    anim.addStatusListener((s) {
      if (s == AnimationStatus.dismissed) portal.hide();
    });
  }

  final portal = OverlayPortalController();
  final AnimationController anim;
  late final CurvedAnimation curved;

  void open() {
    portal.show();
    anim.forward();
  }

  void close() {
    if (portal.isShowing) anim.reverse();
  }

  void dispose() {
    curved.dispose();
    anim.dispose();
  }
}

class _MathPlayPageState extends ConsumerState<MathPlayPage> with TickerProviderStateMixin {
  // ── data() ──
  String _selectedClassId = '';
  String _selectedSubjectId = '';
  String _selectedClassName = '';
  String _selectedSubjectName = '';

  List<Json> _chapters = [];
  List<Json> _allActivities = [];
  bool _loading = false;
  String? _error;

  String _selectedChapterId = 'all';
  String _selectedLevel = 'all';
  String _selectedLockFilter = 'all';
  bool _chapterOpen = false;
  bool _levelOpen = false;

  Json? _quizActivity;
  String _quizTitle = '';
  List<dynamic> _quizExamQuestions = [];

  // unlockModal
  bool _modalVisible = false;
  Json? _modalActivity;
  bool _modalLoading = false;
  String? _modalError;

  List<dynamic> _unlockingIds = [];

  // toast
  bool _toastVisible = false;
  String _toastType = 'success';
  String _toastMessage = '';
  Timer? _toastTimer;

  // ── Flutter-side ──
  late final _chapterMenu =
      _AnimatedPortal(this, enter: const Duration(milliseconds: 150), exit: const Duration(milliseconds: 100));
  late final _levelMenu =
      _AnimatedPortal(this, enter: const Duration(milliseconds: 150), exit: const Duration(milliseconds: 100));
  late final _modal =
      _AnimatedPortal(this, enter: const Duration(milliseconds: 200), exit: const Duration(milliseconds: 150));
  late final _toast =
      _AnimatedPortal(this, enter: const Duration(milliseconds: 300), exit: const Duration(milliseconds: 200));

  /// The modal's last rendered content, kept during its leave transition.
  Widget? _modalContent;

  MathZoroController get _mz => ref.read(mathZoroProvider.notifier);
  MathPlayStore get _store => ref.read(mathPlayStoreProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _mounted());
  }

  Future<void> _mounted() async {
    // data(): the persisted store was hydrated before the component existed.
    await _mz.ready;
    if (!mounted) return;
    final ctx = _store.selectedActivityContext ?? const <String, dynamic>{};
    setState(() {
      _selectedClassId = jsTruthy(ctx['classId']) ? jsStr(ctx['classId'])! : '';
      _selectedSubjectId = jsTruthy(ctx['subjectId']) ? jsStr(ctx['subjectId'])! : '';
      _selectedClassName = jsTruthy(ctx['className']) ? jsDisplay(ctx['className']) : '';
      _selectedSubjectName = jsTruthy(ctx['subjectName']) ? jsDisplay(ctx['subjectName']) : '';
    });
    await _fetchData();
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _chapterMenu.dispose();
    _levelMenu.dispose();
    _modal.dispose();
    _toast.dispose();
    super.dispose();
  }

  // ── computed ─────────────────────────────────────────────────────────────

  String get _instituteId => _store.instituteId;

  List<({String value, String label})> get _chapterOptions => [
        (value: 'all', label: 'All Chapters'),
        for (final ch in _chapters) (value: jsStringOf(ch, 'id'), label: jsDisplay(ch['name'])),
      ];

  String get _selectedChapterLabel {
    for (final c in _chapterOptions) {
      if (c.value == _selectedChapterId) return c.label.isEmpty ? 'All Chapters' : c.label;
    }
    return 'All Chapters';
  }

  ({String value, String label, String emoji})? get _levelOption {
    for (final l in kLevelOptions) {
      if (l.value == _selectedLevel) return l;
    }
    return null;
  }

  String get _selectedLevelLabel => _levelOption?.label ?? 'All Levels';
  String get _levelEmoji => _levelOption?.emoji ?? '🌐';

  List<Json> get _filteredActivities => filterMathPlayActivities(
        _allActivities,
        chapterId: _selectedChapterId,
        level: _selectedLevel,
        lockFilter: _selectedLockFilter,
      );

  int get _lockedCount => _allActivities.where((a) => !jsTruthy(a['is_unlocked'])).length;
  int get _unlockedCount => _allActivities.where((a) => jsTruthy(a['is_unlocked'])).length;

  // ── methods ──────────────────────────────────────────────────────────────

  void _setMenus({required bool chapter, required bool level}) {
    setState(() {
      _chapterOpen = chapter;
      _levelOpen = level;
    });
    chapter ? _chapterMenu.open() : _chapterMenu.close();
    level ? _levelMenu.open() : _levelMenu.close();
  }

  void _selectChapter(String val) {
    setState(() => _selectedChapterId = val);
    _setMenus(chapter: false, level: _levelOpen);
  }

  void _selectLevel(String val) {
    setState(() => _selectedLevel = val);
    _setMenus(chapter: _chapterOpen, level: false);
  }

  void _selectLockFilter(String val) => setState(() => _selectedLockFilter = val);

  void _closeAll() {
    if (!_chapterOpen && !_levelOpen) return;
    _setMenus(chapter: false, level: false);
  }

  Future<void> _fetchData() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final courses = ref.read(mathZoroProvider).mathZoroCourses;
      debugPrint('math_zoro_courses => $courses');
      debugPrint('selectedActivityContext => ${_store.selectedActivityContext}');

      // First take NON MathZoro course, fallback to the first one
      Json? selectedCourse;
      for (final c in courses) {
        if (c['is_math_zoro'] == false) {
          selectedCourse = c;
          break;
        }
      }
      selectedCourse ??= courses.isNotEmpty ? courses.first : null;

      if (selectedCourse == null) {
        _error = 'No course found';
        return;
      }

      // Force class/subject from store
      _selectedClassId = jsTruthy(selectedCourse['zsl_class_id']) ? jsStr(selectedCourse['zsl_class_id'])! : '';
      _selectedSubjectId =
          jsTruthy(selectedCourse['zsl_subject_id']) ? jsStr(selectedCourse['zsl_subject_id'])! : '';

      if (_selectedClassId.isEmpty || _selectedSubjectId.isEmpty) {
        _error = 'Missing class or subject';
        return;
      }

      // Chapters API
      final chapters = await _mz.getallchpaters(_instituteId, _selectedClassId, _selectedSubjectId);
      if (!mounted) return;
      setState(() {
        _chapters = [
          if (chapters is List)
            for (final c in chapters) asMap(c) ?? <String, dynamic>{},
        ];
      });

      final langId = _store.languageId;
      final chapterList = _chapters;
      // Promise.allSettled — a failed chapter contributes no activities.
      final results = await Future.wait([
        for (var chIdx = 0; chIdx < chapterList.length; chIdx++)
          () async {
            final ch = chapterList[chIdx];
            try {
              final topics = await _mz.getZslLinks(_instituteId, ch['id'], langId);
              return flattenTopicActivities(
                  topics, ch['id'], (a) => mathPlayActivityExtras(a, chIdx + 1));
            } catch (e) {
              debugPrint('$e');
              return <Json>[];
            }
          }(),
      ]);

      if (!mounted) return;
      setState(() => _allActivities = [for (final r in results) ...r]);
    } catch (e) {
      debugPrint('Fetch Error => $e');
      _error = 'Failed to load chapters';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onUnlockRequest(Json activity) {
    setState(() {
      _modalActivity = activity;
      _modalError = null;
      _modalLoading = false;
      _modalVisible = true;
    });
    _modal.open();
    // the toast (z-60) stays above the modal (z-50)
    if (_toast.portal.isShowing) _toast.portal.show();
  }

  void _closeUnlockModal() {
    if (_modalLoading) return;
    setState(() {
      _modalVisible = false;
      _modalActivity = null;
      _modalError = null;
    });
    _modal.close();
  }

  Future<void> _confirmUnlock() async {
    final activity = _modalActivity;
    if (activity == null) return;

    setState(() {
      _modalLoading = true;
      _modalError = null;
      if (!_unlockingIds.contains(activity['id'])) {
        _unlockingIds = [..._unlockingIds, activity['id']];
      }
    });

    try {
      await _store.unlockZslActivity(jsStringOf(activity, 'id'));
      if (!mounted) return;

      setState(() {
        final idx = _allActivities.indexWhere((a) => a['id'] == activity['id']);
        if (idx != -1) {
          _allActivities = [..._allActivities]..[idx] = {..._allActivities[idx], 'is_unlocked': true};
        }
        _modalVisible = false;
      });
      _modal.close();
      // this.$emit('unlock-requested', activity) — no listener on the route.
      _showToast('success',
          '"${jsTruthy(activity['name']) ? jsDisplay(activity['name']) : 'Activity'}" is now unlocked and ready to play!');
    } catch (err) {
      final msg = ApiClient.messageOf(err, fallback: 'Something went wrong. Please try again.');
      if (!mounted) return;
      setState(() => _modalError = msg);
      _showToast('error', msg);
    } finally {
      if (mounted) {
        setState(() {
          _modalLoading = false;
          _unlockingIds = _unlockingIds.where((id) => id != activity['id']).toList();
        });
      }
    }
  }

  void _showToast(String type, String message) {
    _toastTimer?.cancel();
    setState(() {
      _toastType = type;
      _toastMessage = message;
      _toastVisible = true;
    });
    _toast.open();
    _toastTimer = Timer(const Duration(seconds: 4), _hideToast);
  }

  void _hideToast() {
    if (!mounted) return;
    setState(() => _toastVisible = false);
    _toast.close();
  }

  Json _activityContextPatch(Json activity) => {
        'classId': _selectedClassId,
        'className': _selectedClassName,
        'subjectId': _selectedSubjectId,
        'subjectName': _selectedSubjectName,
        'chapterId': activity['chapter_id'],
        'topicId': activity['topic_id'],
        'topicName': activity['topic_name'],
        'topicImage': jsTruthy(activity['file_path']) ? activity['file_path'] : '',
        'activityId': activity['id'],
      };

  void _goToActivity(Json activity) {
    if (!jsTruthy(activity['is_unlocked'])) return;
    _store.setActivityContext(_activityContextPatch(activity));
    context.go('/activitylibrary');
  }

  Future<void> _goToQuiz(Json activity) async {
    if (!jsTruthy(activity['is_unlocked'])) return;
    _store.setActivityContext(_activityContextPatch(activity));
    try {
      final res = await _mz.getZslQuestions(jsStringOf(activity, 'id'));
      final questions = dataOrSelf(res);
      if (!hasItems(questions)) return;
      if (!mounted) return;
      setState(() {
        _quizExamQuestions = questions as List;
        _quizActivity = activity;
        _quizTitle = jsTruthy(activity['name'])
            ? jsDisplay(activity['name'])
            : (jsTruthy(activity['topic_name']) ? jsDisplay(activity['topic_name']) : 'Quiz');
      });
      unawaited(showQuizExam(
        context,
        questions: _quizExamQuestions,
        quizTitle: _quizTitle,
        onSubmitted: _onQuizSubmitted,
        onClose: _onQuizClose,
      ));
    } catch (e) {
      debugPrint('$e');
    }
  }

  Future<void> _onQuizSubmitted(Map<String, dynamic> event) async {
    final activityId = jsStringOf(_quizActivity, 'id');
    try {
      await _mz.submitZslQuiz(
        activityId: activityId,
        answers: answersPayloadOf(event),
        classesId: _store.zslQuizClassId(),
      );
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _onQuizClose() {
    if (!mounted) return;
    setState(() {
      _quizActivity = null;
      _quizExamQuestions = [];
    });
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final filtered = _filteredActivities;

    final Widget content;
    if (_loading) {
      content = _buildLoading(dark);
    } else if (_error != null) {
      content = _buildError(dark);
    } else if (filtered.isEmpty) {
      content = _buildEmpty(dark);
    } else {
      content = _buildGrid(context, dark, filtered);
    }

    final page = GestureDetector(
      // root @click="closeAll"
      onTap: _closeAll,
      child: ColoredBox(
        color: dark ? _C.ink : const Color(0xFFF0F0F8),
        child: Stack(
          children: [
            Positioned.fill(child: _PageBackdrop(dark: dark)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(dark, filtered.length),
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(child: _buildFilters(context, dark)),
                      content,
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    return PopScope(
      canPop: !_modalVisible,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _modalVisible) _closeUnlockModal();
      },
      child: OverlayPortal(
        controller: _modal.portal,
        overlayLocation: OverlayChildLocation.rootOverlay,
        overlayChildBuilder: (ctx) => _buildUnlockModal(ctx),
        child: OverlayPortal(
          controller: _toast.portal,
          overlayLocation: OverlayChildLocation.rootOverlay,
          overlayChildBuilder: (ctx) => _buildToast(ctx),
          child: page,
        ),
      ),
    );
  }
}
