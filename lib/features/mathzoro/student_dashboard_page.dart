import '../../widgets/content_image.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';
import 'mathzoro_controller.dart';
import 'mathzoro_quiz.dart';
import 'mz_ui.dart';

/// Port of `studentdashboard.vue` (`/newlayout/studentdashboard`).
class MathZoroStudentDashboardPage extends ConsumerStatefulWidget {
  const MathZoroStudentDashboardPage({super.key});

  @override
  ConsumerState<MathZoroStudentDashboardPage> createState() =>
      _MathZoroStudentDashboardPageState();
}

typedef _Json = Map<String, dynamic>;

class _MathZoroStudentDashboardPageState extends ConsumerState<MathZoroStudentDashboardPage> {
  String _selectedSubjectName = '';
  Timer? _usageInterval;

  // Activities shown directly in Recent Explorations (banner chapter)
  List<_Json> _cardActivities = [];
  bool _cardActivitiesLoading = false;

  dynamic _subjectPerformance;

  // Quiz Arena drill-down
  bool _quizArenaOpen = false;
  bool _chaptersLoading = false;
  String? _chaptersError;
  List<_Json> _quizChapters = [];

  _Json? _selectedChapterForQuiz;
  bool _activitiesLoading = false;
  List<_Json> _chapterActivitiesForQuiz = [];
  Map<String, List<_Json>> _activitiesCache = {};

  String _resolvedClassId = '';
  String _resolvedSubjectId = '';

  // Quiz modal
  _Json? _quizActivity;

  // Toast
  bool _toastVisible = false;
  String _toastMsg = '';
  num _toastTickets = 0;
  int _toastSeq = 0;
  Timer? _toastTimer;

  String? _lastUri;

  /// The result toast is `fixed bottom-6 right-6` → painted in the root
  /// overlay, relative to the window (over the shell's footer).
  final _toastPortal = OverlayPortalController();

  MathZoroController get _mz => ref.read(mathZoroProvider.notifier);

  @override
  void initState() {
    super.initState();
    _toastPortal.show();
    WidgetsBinding.instance.addPostFrameCallback((_) => _mounted());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // '$route' watcher — reload when the dashboard route changes (query etc.)
    final uri = GoRouterState.of(context).uri;
    final key = uri.toString();
    final previous = _lastUri;
    _lastUri = key;
    if (previous != null && previous != key && uri.path == AppRoutes.mathzoroHome) {
      _activitiesCache = {};
      _cardActivities = [];
      _quizChapters = [];
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _loadChapters().then((_) => _loadBannerChapterActivities());
      });
    }
  }

  Future<void> _mounted() async {
    await _mz.ready;
    if (!mounted) return;
    await _loadChapters();
    // After chapters load, load activities for the banner chapter directly
    await _loadBannerChapterActivities();
    if (!mounted) return;
    _startUsageTracking();
    debugPrint('bannerChapterId: ${_bannerChapterId()}');
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    _usageInterval?.cancel();
    super.dispose();
  }

  void _startUsageTracking() {
    // call immediately once, then every 10 s
    _recordUsage();
    _usageInterval = Timer.periodic(const Duration(seconds: 10), (_) => _recordUsage());
  }

  Future<void> _recordUsage() async {
    try {
      await _mz.individualrecordUsageAction();
    } catch (e) {
      debugPrint('individualrecordUsageAction failed: $e');
    }
  }

  // ── computed ─────────────────────────────────────────────────────────────

  String get _instituteId {
    final id = ref.read(sessionProvider).instituteId;
    return jsTruthy(id) ? jsStr(id)! : '';
  }

  _Json? get _lastOpenedChapter => ref.read(mathZoroProvider).lastOpenedChapter;

  String _currentGoalChapterName(_Json? last) {
    if (jsTruthy(last?['name'])) return jsDisplay(last!['name']);
    if (_quizChapters.isNotEmpty) return jsDisplay(_quizChapters.first['name']);
    return 'Loading...';
  }

  double _bannerChapterId([_Json? last]) {
    final ch = last ?? _lastOpenedChapter;
    if (ch != null) return jsNumber(ch['id'] ?? ch['chapter_id'] ?? 0);
    final first = _quizChapters.isNotEmpty ? _quizChapters.first : null;
    return jsNumber(first?['id'] ?? 0);
  }

  Map<String, _Json> get _chapterPerformanceMap {
    final map = <String, _Json>{};
    final chapters = asList(asMap(_subjectPerformance)?['chapters']);
    for (final raw in chapters) {
      final ch = asMap(raw);
      if (ch == null) continue;
      final activityMap = <String, _Json>{};
      for (final a in asList(ch['activities'])) {
        final am = asMap(a);
        if (am != null) activityMap[jsNumKey(am['activity_id'])] = am;
      }
      map[jsNumKey(ch['chapter_id'])] = {...ch, 'activityMap': activityMap};
    }
    return map;
  }

  static int _ticketsToStars(dynamic tickets) {
    final t = jsNumber(tickets);
    if (t.isNaN || t <= 0) return 0;
    return math.min(5, t.floor());
  }

  /// earned_tickets / (activities.length * 5) * 100 (NaN / Infinity like JS).
  static double _chapterPct(_Json? perf) {
    final earned = jsNumber(perf?['earned_tickets'] ?? 0);
    final total = asList(perf?['activities']).length * 5;
    return earned / total * 100;
  }

  int _bannerChapterPercentage(Map<String, _Json> perfMap, double bannerId) {
    final perf = perfMap[jsNumKey(bannerId)];
    if (perf == null) return 0;
    final totalTickets = asList(perf['activities']).length * 5;
    if (totalTickets == 0) return 0;
    final earned = jsNumber(jsTruthy(perf['earned_tickets']) ? perf['earned_tickets'] : 0);
    return (earned / totalTickets * 100).round();
  }

  int _bannerChapterFiveStarCount(Map<String, _Json> perfMap, double bannerId) {
    final perf = perfMap[jsNumKey(bannerId)];
    final activityMap = perf?['activityMap'] as Map<String, _Json>?;
    if (activityMap == null) return 0;
    return activityMap.values.where((a) => _ticketsToStars(a['earned_tickets'] ?? 0) >= 5).length;
  }

  String get _overallEarnedTickets =>
      jsDisplay(dig(_subjectPerformance, ['overall', 'earned_tickets']) ?? 0);

  /// getActivityStarClass(chapterId, activityId, starPos, map)
  static (IconData, Color) _activityStar(
      Map<String, _Json> map, dynamic chapterId, dynamic activityId, int starPos) {
    final perf = map[jsNumKey(chapterId)];
    final actPerf = (perf?['activityMap'] as Map<String, _Json>?)?[jsNumKey(activityId)];
    final filled = _ticketsToStars(actPerf?['earned_tickets'] ?? 0);
    if (starPos > filled) return (BootstrapIcons.star, Tw.slate200);
    if (filled >= 4) return (BootstrapIcons.star_fill, Tw.amber400);
    if (filled >= 2) return (BootstrapIcons.star_fill, Mz.amber300);
    return (BootstrapIcons.star_fill, Tw.amber200);
  }

  // ── data ─────────────────────────────────────────────────────────────────

  List<_Json> _flattenTopics(dynamic topics, Object chapterId) {
    if (topics == null) return [];
    if (topics is! List) throw StateError('topics is not a list');
    return [
      for (final t in topics.map(asMap).whereType<_Json>())
        for (final a in asList(t['activities']).map(asMap).whereType<_Json>())
          {
            ...a,
            'file_path': jsTruthy(a['file_path'])
                ? a['file_path']
                : (jsTruthy(t['file_path']) ? t['file_path'] : ''),
            'topic_name': t['name'],
            'topic_id': t['id'],
            'chapter_id': chapterId,
          },
    ];
  }

  Future<void> _loadBannerChapterActivities() async {
    final last = _lastOpenedChapter;
    final targetChapter = last ?? (_quizChapters.isNotEmpty ? _quizChapters.first : null);
    if (targetChapter == null) return;

    final chapterId = jsStr(targetChapter['id'] ?? targetChapter['chapter_id'] ?? '') ?? '';
    if (chapterId.isEmpty) return;

    // Use cache if available
    final cached = _activitiesCache[chapterId];
    if (cached != null) {
      setState(() => _cardActivities = cached);
      return;
    }

    setState(() {
      _cardActivitiesLoading = true;
      _cardActivities = [];
    });
    try {
      final langId = ref.read(sessionProvider).language.id;
      final topics = await _mz.getZslLinks(_instituteId, chapterId, langId);
      final acts = _flattenTopics(topics, chapterId);
      if (!mounted) return;
      setState(() {
        _activitiesCache = {..._activitiesCache, chapterId: acts};
        _cardActivities = acts;
      });
    } catch (e) {
      debugPrint('[Dashboard] failed to load banner chapter activities $e');
      if (mounted) setState(() => _cardActivities = []);
    } finally {
      if (mounted) setState(() => _cardActivitiesLoading = false);
    }
  }

  Future<void> _openQuizArena() async {
    if (_quizArenaOpen) {
      setState(() => _quizArenaOpen = false);
      return;
    }
    setState(() => _quizArenaOpen = true);
    if (_quizChapters.isEmpty) await _loadChapters();
  }

  void _closeQuizArena() => setState(() {
        _quizArenaOpen = false;
        _selectedChapterForQuiz = null;
        _chapterActivitiesForQuiz = [];
      });

  void _showQuizResultToast({required String msg, required num tickets}) {
    _toastTimer?.cancel();
    setState(() {
      _toastVisible = true;
      _toastMsg = msg;
      _toastTickets = tickets;
      _toastSeq++;
    });
    _toastTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => _toastVisible = false);
    });
  }

  Future<void> _loadChapters() async {
    final mzState = ref.read(mathZoroProvider);
    final session = ref.read(sessionProvider);

    final mathZoroClassId = session.userInfo?.mathzoroClassId ??
        mzState.selectedClass?['mathzoroclassid'] ??
        mzState.selectedClass?['zsl_class_id'] ??
        session.userInfo?.zslClassId ??
        session.studentLoginData?['zsl_class_id'];

    debugPrint('STORE CLASS ID => $mathZoroClassId');

    if (_instituteId.isEmpty) {
      setState(() => _chaptersError = 'Missing institute information.');
      return;
    }
    if (!jsTruthy(mathZoroClassId)) {
      setState(() => _chaptersError = 'No class selected.');
      return;
    }

    setState(() {
      _chaptersLoading = true;
      _chaptersError = null;
    });

    try {
      _resolvedClassId = jsStr(mathZoroClassId)!;

      await _mz.getAllSubjects(_instituteId, _resolvedClassId);

      final raw = ref.read(mathZoroProvider).allsubject;
      if (raw is! List) throw StateError('subjects is not a list');
      final subjects = raw.map(asMap).whereType<_Json>().toList();

      String subjectName(_Json s) =>
          jsDisplay(jsTruthy(s['name']) ? s['name'] : s['course_title']).toLowerCase().trim();
      String subjectKey(_Json s) =>
          jsStr(jsTruthy(s['zsl_subject_id']) ? s['zsl_subject_id'] : s['id']) ?? 'undefined';

      final filteredSubjects = subjects.where((s) => !subjectName(s).contains('play')).toList();

      // 1. Check localStorage / sessionStorage
      final storedSubjectId = ref.read(mathZoroProvider).storedSubjectId;
      _Json? finalSubject;
      if (storedSubjectId != null && storedSubjectId.isNotEmpty) {
        finalSubject = filteredSubjects.where((s) => subjectKey(s) == storedSubjectId).firstOrNull;
      }

      // 2. If not found, take is_math_zoro === false
      if (finalSubject == null) {
        final nonMathCourse = ref
            .read(mathZoroProvider)
            .mathZoroCourses
            .where((c) => c['is_math_zoro'] == false)
            .firstOrNull;
        if (jsTruthy(nonMathCourse?['zsl_subject_id'])) {
          final wanted = jsStr(nonMathCourse!['zsl_subject_id']);
          finalSubject = filteredSubjects.where((s) => subjectKey(s) == wanted).firstOrNull;
        }
      }

      // 3. Fallback
      finalSubject ??= filteredSubjects.isNotEmpty
          ? filteredSubjects.first
          : (subjects.isNotEmpty ? subjects.first : null);

      if (finalSubject == null) {
        if (mounted) setState(() => _chaptersError = 'No subjects available.');
        return;
      }

      _resolvedSubjectId =
          jsStr(finalSubject['zsl_subject_id'] ?? finalSubject['id'] ?? '') ?? '';
      _selectedSubjectName = jsTruthy(finalSubject['name'])
          ? jsDisplay(finalSubject['name'])
          : jsDisplay(finalSubject['course_title']);

      debugPrint('FINAL SUBJECT => $_selectedSubjectName '
          '(class $_resolvedClassId, subject $_resolvedSubjectId)');

      final chsResult =
          await _mz.getallchpaters(_instituteId, _resolvedClassId, _resolvedSubjectId);
      if (!mounted) return;
      setState(() {
        _quizChapters =
            chsResult is List ? chsResult.map(asMap).whereType<_Json>().toList() : [];
      });

      // Not awaited: the banner activities (loaded next) don't depend on it,
      // so both requests run at the same time.
      unawaited(_loadSubjectPerformance());
    } catch (e) {
      debugPrint('$e');
      if (mounted) setState(() => _chaptersError = 'Failed to load chapters.');
    } finally {
      if (mounted) setState(() => _chaptersLoading = false);
    }
  }

  Future<void> _loadSubjectPerformance() async {
    try {
      final perf = await _mz.getSubjectPerformance(_resolvedSubjectId, _resolvedClassId);
      final inner = asMap(perf)?['data'];
      if (mounted) {
        setState(() => _subjectPerformance = jsTruthy(inner) ? inner : perf);
      }
    } catch (perfError) {
      debugPrint('Performance load failed: $perfError');
    }
  }

  Future<void> _toggleChapterActivities(_Json chapter) async {
    if (_selectedChapterForQuiz != null && _selectedChapterForQuiz!['id'] == chapter['id']) {
      setState(() {
        _selectedChapterForQuiz = null;
        _chapterActivitiesForQuiz = [];
      });
      return;
    }

    final key = jsStr(chapter['id']) ?? 'undefined';
    setState(() {
      _selectedChapterForQuiz = chapter;
      _chapterActivitiesForQuiz = [];
    });

    final cached = _activitiesCache[key];
    if (cached != null) {
      setState(() => _chapterActivitiesForQuiz = cached);
      return;
    }

    setState(() => _activitiesLoading = true);
    try {
      final langId = ref.read(sessionProvider).language.id;
      final topics = await _mz.getZslLinks(_instituteId, chapter['id'], langId);
      final acts = _flattenTopics(topics, chapter['id']);
      if (!mounted) return;
      setState(() {
        _activitiesCache = {..._activitiesCache, key: acts};
        _chapterActivitiesForQuiz = acts;
      });
    } catch (e) {
      debugPrint('$e');
      if (mounted) setState(() => _chapterActivitiesForQuiz = []);
    } finally {
      if (mounted) setState(() => _activitiesLoading = false);
    }
  }

  static String _activityTitle(_Json activity) => jsTruthy(activity['name'])
      ? jsDisplay(activity['name'])
      : jsDisplay(activity['topic_name']);

  Future<void> _openQuizForActivity(_Json activity) async {
    try {
      final res = await _mz.getZslQuestions(jsStr(activity['id']) ?? 'undefined');
      final inner = asMap(res)?['data'];
      final questions = jsTruthy(inner) ? inner : (jsTruthy(res) ? res : const []);

      if (questions is! List || questions.isEmpty) {
        if (mounted) _showNoQuestions(_activityTitle(activity));
        return;
      }

      _quizActivity = activity;
      if (!mounted) return;
      await showMathZoroQuiz(
        context,
        questions: questions,
        quizTitle: _activityTitle(activity),
        onSubmitted: (s) => _onQuizSubmitted(s.answersPayload),
      );
      _onQuizClose();
    } catch (e) {
      debugPrint('$e');
      if (mounted) _showNoQuestions(_activityTitle(activity));
    }
  }

  Future<void> _onQuizSubmitted(List<Map<String, String>> answersPayload) async {
    try {
      final res = await _mz.submitZslQuiz(
        activityId: jsStr(_quizActivity?['id']) ?? 'undefined',
        answers: answersPayload,
      );
      final inner = asMap(res)?['data'];
      final result = asMap(jsTruthy(inner) ? inner : res) ?? const <String, dynamic>{};

      if (!mounted) return;
      _showQuizResultToast(
        msg: jsDisplay(result['msg'] ?? 'Quiz submitted!'),
        tickets: asDouble(result['tickets'] ?? 0) ?? 0,
      );

      // Refresh dashboard performance
      if (_resolvedClassId.isNotEmpty && _resolvedSubjectId.isNotEmpty) {
        final perf = await _mz.getSubjectPerformance(_resolvedSubjectId, _resolvedClassId);
        final perfInner = asMap(perf)?['data'];
        final value = jsTruthy(perfInner) ? perfInner : (jsTruthy(perf) ? perf : const {});
        if (mounted) setState(() => _subjectPerformance = {...?asMap(value)});
      }

      // Refresh navbar ticket count
      _mz.dispatchTicketsUpdated();

      // Clear cache
      if (!mounted) return;
      setState(() => _activitiesCache = {});

      // Reload dashboard activities
      await _loadBannerChapterActivities();

      // Reload opened chapter activities
      final opened = _selectedChapterForQuiz;
      if (opened != null && jsTruthy(opened['id']) && mounted) {
        setState(() => _selectedChapterForQuiz = null);
        await _toggleChapterActivities(
            _quizChapters.where((c) => c['id'] == opened['id']).firstOrNull ?? opened);
      }
    } catch (e) {
      debugPrint('Quiz submit failed: $e');
      if (mounted) _showQuizResultToast(msg: 'Quiz submitted!', tickets: 0);
    }
  }

  void _onQuizClose() {
    _quizActivity = null;
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final last = ref.watch(mathZoroProvider.select((s) => s.lastOpenedChapter));
    final perfMap = _chapterPerformanceMap;
    final goalName = _currentGoalChapterName(last);
    final bannerId = _bannerChapterId(last);
    final px = context.isMd ? 32.0 : 16.0;

    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(
            color: dark ? const Color(0xFF161233) : Tw.slate100,
            child: DefaultTextStyle.merge(
              style: TextStyle(color: dark ? Colors.white : Tw.gray900),
              child: SingleChildScrollView(
                // py-8 + the layout's pb-6
                padding: EdgeInsets.fromLTRB(px, 32, px, 56),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _row1(goalName, last, perfMap, bannerId),
                    const SizedBox(height: 32),
                    _row2(goalName),
                    const SizedBox(height: 32),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: _slideDown,
                      child: _quizArenaOpen
                          ? KeyedSubtree(key: const ValueKey('arena'), child: _row4(perfMap))
                          : KeyedSubtree(
                              key: const ValueKey('activities'),
                              child: _row3(goalName, last, perfMap, bannerId)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        OverlayPortal(
          controller: _toastPortal,
          overlayLocation: OverlayChildLocation.rootOverlay,
          overlayChildBuilder: (_) =>
              Positioned(right: 24, bottom: 24, child: _resultToast()),
        ),
      ],
    );
  }

  static Widget _slideDown(Widget child, Animation<double> a) => FadeTransition(
        opacity: a,
        child: AnimatedBuilder(
          animation: a,
          builder: (_, c) => Transform.translate(offset: Offset(0, -8 * (1 - a.value)), child: c),
          child: child,
        ),
      );

  int get _cols => context.isLg ? 3 : (context.isMd ? 2 : 1);

  /// `grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3` — rows stretch their items.
  Widget _grid(List<Widget> children, double gap, {int? cols}) {
    final n = cols ?? _cols;
    if (n == 1) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            children[i],
          ],
        ],
      );
    }
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += n) {
      if (rows.isNotEmpty) rows.add(SizedBox(height: gap));
      rows.add(IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var j = 0; j < n; j++) ...[
              if (j > 0) SizedBox(width: gap),
              Expanded(child: i + j < children.length ? children[i + j] : const SizedBox()),
            ],
          ],
        ),
      ));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows);
  }

  // shadcn Card `shadow-sm`
  static const _shadowSm = [
    BoxShadow(color: Color(0x1A000000), blurRadius: 3, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x1A000000), blurRadius: 2, spreadRadius: -1, offset: Offset(0, 1)),
  ];

  Color get _cardBg => context.isDark ? Mz.darkCard : Colors.white;
  Color get _cardBorder => context.isDark ? Colors.white.withValues(alpha: 0.1) : Tw.slate200;
  Color get _strong => context.isDark ? Colors.white : Tw.slate900;
  Color get _muted => context.isDark ? Tw.slate300 : Tw.slate500;
  Color get _text => context.isDark ? Colors.white : Tw.gray900;

  // ── ROW 1 — HERO + QUICK STATS ──

  Widget _row1(String goalName, _Json? last, Map<String, _Json> perfMap, double bannerId) {
    final hero = _heroCard(goalName, last);
    final stats = _quickStats(goalName, perfMap, bannerId);
    if (context.isXl) {
      // grid-cols-3 gap-6 with the hero spanning 2 columns (+ the gap).
      return LayoutBuilder(
        builder: (context, c) {
          final col = (c.maxWidth - 48) / 3;
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: hero),
                const SizedBox(width: 24),
                SizedBox(width: col, child: stats),
              ],
            ),
          );
        },
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [hero, const SizedBox(height: 24), stats],
    );
  }

  Widget _heroCard(String goalName, _Json? last) {
    final md = context.isMd;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        // bg-gradient-to-br (CSS `to bottom right` on a wide card).
        gradient: const CssLinearGradient(
          corner: Alignment.bottomRight,
          colors: [Tw.indigo600, Tw.purple600, Tw.indigo800],
        ),
        // shadow-2xl → the theme's `--shadow-2xl` (0 1px 3px rgb(0 0 0/.25)).
        boxShadow: MzShadow.xl2,
      ),
      child: Stack(
        children: [
          if (md)
            Positioned(
              right: -40,
              top: 0,
              bottom: 0,
              width: 320,
              child: IgnorePointer(
                child: Opacity(
                  opacity: 0.2,
                  child: Center(
                    child: OverflowBox(
                      maxHeight: 320,
                      child: Transform.rotate(
                        angle: 12 * math.pi / 180,
                        child: const Icon(BootstrapIcons.calculator, size: 160, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(32, 56, 32, 56),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: md ? 2 / 3 : 1,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // An inline <span> → sits in a 24 px line box.
                    SizedBox(
                      height: 24,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: const Text('CURRENT GOAL',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(goalName,
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w900,
                            height: 1.25,
                            color: Colors.white)),
                    const SizedBox(height: 12),
                    Text(
                      goalName != 'Loading...'
                          ? 'Continue where you left off — keep going!'
                          : 'Select a chapter in Math Zone to track your progress here.',
                      style: const TextStyle(fontSize: 14, height: 1.43, color: Mz.indigo100),
                    ),
                    const SizedBox(height: 24),
                    HoverBuilder(
                      onTap: () => context.go('/newlayout/newmathzone'),
                      builder: (context, hover) => AnimatedScale(
                        duration: const Duration(milliseconds: 150),
                        scale: hover ? 1.05 : 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            // The kit's `hover:bg-primary/90` survives the
                            // `bg-white` override (text stays indigo-700).
                            color: hover
                                ? Mz.primary(context.isDark).withValues(alpha: 0.9)
                                : Colors.white,
                            // rounded-xl = 20 px in this theme.
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: const [
                              BoxShadow(color: Color(0x33000000), blurRadius: 20, offset: Offset(0, 10)),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(last != null ? 'Resume Learning' : 'Start Learning',
                                  style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: Tw.indigo700)),
                              const SizedBox(width: 8),
                              const Icon(BootstrapIcons.arrow_right, size: 16, color: Tw.indigo700),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickStats(String goalName, Map<String, _Json> perfMap, double bannerId) {
    final dark = context.isDark;
    final pct = _bannerChapterPercentage(perfMap, bannerId);
    final fiveStars = _bannerChapterFiveStarCount(perfMap, bannerId);
    final tileBg = dark ? Colors.white.withValues(alpha: 0.05) : Tw.slate50;
    final tileBorder = dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate200;
    final labelStyle =
        TextStyle(fontSize: 10, fontWeight: FontWeight.w700, height: 1.5, color: _muted);

    Widget tile(Widget child) => Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: tileBorder),
          ),
          child: child,
        );

    Widget statTile(IconData icon, Color iconColor, String value, String label) => tile(Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // `<i class="… text-xl">` → a 28 px line box.
            SizedBox(height: 28, child: Center(child: Icon(icon, size: 20, color: iconColor))),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w900, height: 1.33, color: _strong)),
            const SizedBox(height: 4),
            Text(label, style: labelStyle),
          ],
        ));

    return _blurCard(
      radius: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CardTitle's `leading-none` is dropped by tailwind-merge
                  // (`text-xl` comes later) → text-xl's 28 px line height.
                  Text('Quick Stats',
                      style: TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w900, height: 1.4, color: _strong)),
                  const SizedBox(height: 6),
                  Text(goalName != 'Loading...' ? goalName : 'Your progress this week',
                      style: TextStyle(fontSize: 14, height: 20 / 14, color: _muted)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: statTile(BootstrapIcons.graph_up_arrow, Mz.green400,
                              pct > 0 ? '$pct%' : '—', 'CHAPTER PROGRESS'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: statTile(BootstrapIcons.star_fill, Mz.mathYellow, '$fiveStars',
                              '5-STAR ACTIVITIES'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  tile(Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_overallEarnedTickets,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                    height: 1.4,
                                    color: _strong)),
                            Text('TICKETS EARNED', style: labelStyle),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 48, // 2rem icon in a 1.5 line box
                        child: Center(
                          child: Icon(BootstrapIcons.ticket_perforated_fill,
                              size: 32, color: Tw.pink500.withValues(alpha: 0.8)),
                        ),
                      ),
                    ],
                  )),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Card surface: white / `bg-[rgba(38,32,75,0.7)] backdrop-blur-md`.
  Widget _blurCard({
    required double radius,
    required Widget child,
    List<BoxShadow>? extraShadow,
    Color? background,
    bool cardShadow = true,
  }) {
    final dark = context.isDark;
    final box = Container(
      decoration: BoxDecoration(
        color: background ?? _cardBg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: _cardBorder),
      ),
      child: child,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [if (cardShadow) ..._shadowSm, ...?extraShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: dark
            ? BackdropFilter(filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12), child: box)
            : box,
      ),
    );
  }

  // ── ROW 2 — RECENT EXPLORATIONS ──

  /// `h4.text-xl.font-black.flex.items-center.gap-2` — icon, title and the
  /// `<span class="text-sm font-semibold opacity-50 ml-1">— …</span>` are
  /// separate flex items (gap 8 + ml-1).
  Widget _sectionTitle(IconData icon, Color iconColor, String text, {String? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(text,
                style: TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w900, height: 1.4, color: _strong)),
          ),
          if (suffix != null) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text('— $suffix',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      height: 20 / 14,
                      color: _strong.withValues(alpha: 0.5))),
            ),
          ],
        ],
      ),
    );
  }

  Widget _row2(String goalName) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(BootstrapIcons.clock_history, Tw.indigo400, 'Recent Explorations'),
        _grid([
          _explorationCard(
            icon: BootstrapIcons.triangle,
            color: Mz.mathYellow,
            label: 'MATH ZONE',
            title: goalName,
            truncate: true,
            onTap: () => context.go('/newlayout/newmathzone'),
          ),
          _explorationCard(
            icon: BootstrapIcons.clipboard_check,
            color: Mz.cyan400,
            label: 'QUIZ ARENA',
            title: goalName,
            ring: _quizArenaOpen,
            trailing: Icon(
              _quizArenaOpen ? BootstrapIcons.chevron_up : BootstrapIcons.chevron_down,
              size: 16,
              color: Mz.cyan400,
            ),
            onTap: _openQuizArena,
          ),
        ], 24),
      ],
    );
  }

  /// The `border-l-4 border-[#ffde3b]` / `border-cyan-400` accents are
  /// overridden by the later `border-slate-200` / `border-white/10` classes
  /// (tailwind-merge in shadcn `Card`), so the thick left edge renders in
  /// the card's border colour — reproduced as rendered.
  Widget _explorationCard({
    required IconData icon,
    required Color color,
    required String label,
    required String title,
    required VoidCallback onTap,
    bool truncate = false,
    bool ring = false,
    Widget? trailing,
  }) {
    final dark = context.isDark;
    return HoverBuilder(
      onTap: onTap,
      builder: (context, hover) {
        final bg = hover
            ? (dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate50)
            : _cardBg;
        return AccentBorderBox(
          radius: 24,
          borderColor: _cardBorder,
          leftColor: _cardBorder,
          color: bg,
          boxShadow: [
            ..._shadowSm,
            if (ring) const BoxShadow(color: Mz.cyan400, spreadRadius: 2),
          ],
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 44, 20, 44),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(icon, size: 24, color: color),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                              height: 1.5,
                              color: _muted)),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        maxLines: truncate ? 1 : null,
                        overflow: truncate ? TextOverflow.ellipsis : null,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            height: 20 / 14,
                            color: _strong),
                      ),
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 16), trailing],
              ],
            ),
          ),
        );
      },
    );
  }

  // ── ROW 3 — ACTIVITIES FOR BANNER CHAPTER ──

  Widget _row3(String goalName, _Json? last, Map<String, _Json> perfMap, double bannerId) {
    final dark = context.isDark;
    final Widget body;
    if (_cardActivitiesLoading) {
      body = _loadingRow('Loading activities…');
    } else if (_cardActivities.isEmpty) {
      body = _emptyState(BootstrapIcons.inbox, 'No activities found',
          color: dark ? Colors.white : Tw.slate600);
    } else {
      body = _grid([
        for (final act in _cardActivities)
          _activityTile(act, perfMap, bannerId),
      ], 16);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(
          BootstrapIcons.play_circle,
          Tw.pink400,
          last != null ? 'Resume Learning' : 'Activities',
          suffix: goalName.isNotEmpty && goalName != 'Loading...' ? goalName : null,
        ),
        body,
      ],
    );
  }

  Widget _loadingRow(String text, {bool small = false}) => Padding(
        padding: EdgeInsets.symmetric(vertical: small ? 32 : 56),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MzSpinner(size: small ? 24 : 36, stroke: small ? 2 : 3),
            const SizedBox(width: 12),
            Text(text,
                style: TextStyle(
                    fontSize: small ? 12 : 14,
                    fontWeight: FontWeight.w700,
                    color: _text.withValues(alpha: 0.4))),
          ],
        ),
      );

  Widget _emptyState(IconData icon, String text,
          {required Color color, bool small = false}) =>
      Opacity(
        opacity: 0.4,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: small ? 32 : 56),
          child: Column(
            children: [
              Icon(icon, size: small ? 30 : 36, color: color),
              SizedBox(height: small ? 8 : 12),
              Text(text,
                  style: TextStyle(
                      fontSize: small ? 12 : 14, fontWeight: FontWeight.w600, color: color)),
            ],
          ),
        ),
      );

  Widget _thumb(_Json act, double size) {
    final dark = context.isDark;
    final path = jsDisplay(act['file_path']);
    return Container(
      width: size,
      height: size,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? Colors.black.withValues(alpha: 0.2) : Tw.slate100,
        borderRadius: BorderRadius.circular(20), // rounded-xl (20 px in this theme)
        border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate200),
      ),
      child: path.isNotEmpty
          ? contentImage(
              path,
              fit: BoxFit.cover,
              width: size,
              height: size,
              // @error → display:none
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            )
          : Opacity(
              opacity: 0.3,
              child: Icon(BootstrapIcons.play_circle,
                  size: size == 48 ? 18 : 16, color: dark ? Colors.white : Tw.slate400),
            ),
    );
  }

  Widget _stars(Map<String, _Json> perfMap, dynamic chapterId, dynamic activityId, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var star = 1; star <= 5; star++) ...[
          if (star > 1) const SizedBox(width: 2),
          Builder(builder: (_) {
            final (icon, color) = _activityStar(perfMap, chapterId, activityId, star);
            return Icon(icon, size: size, color: color);
          }),
        ],
      ],
    );
  }

  Widget _activityTile(_Json act, Map<String, _Json> perfMap, double chapterId) {
    final dark = context.isDark;
    return HoverBuilder(
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          // hover:bg-white/5 replaces the dark card colour.
          color: hover ? (dark ? Colors.white.withValues(alpha: 0.05) : Tw.slate50) : _cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _cardBorder),
        ),
        child: Row(
          children: [
            _thumb(act, 48),
            const SizedBox(width: 12),
            Expanded(child: _activityInfo(act, perfMap, chapterId, large: true)),
            const SizedBox(width: 12),
            _QuizButton(onTap: () => _openQuizForActivity(act)),
          ],
        ),
      ),
    );
  }

  Widget _activityInfo(_Json act, Map<String, _Json> perfMap, dynamic chapterId,
      {required bool large}) {
    final dark = context.isDark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(jsDisplay(act['name']),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: large ? 14 : 12,
                fontWeight: FontWeight.w700,
                color: dark ? Colors.white : Tw.slate800)),
        Text(jsDisplay(act['topic_name']),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontSize: 10,
                height: 1.5,
                color: _text.withValues(alpha: 0.5))),
        const SizedBox(height: 4),
        _stars(perfMap, chapterId, act['id'], large ? 11 : 10),
      ],
    );
  }

  // ── ROW 4 — QUIZ ARENA DRILL-DOWN ──

  Widget _row4(Map<String, _Json> perfMap) {
    final dark = context.isDark;
    final Widget body;
    if (_chaptersLoading) {
      body = _loadingRow('Loading chapters…');
    } else if (_chaptersError != null) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            const Icon(BootstrapIcons.exclamation_triangle, size: 30, color: Mz.rose400),
            const SizedBox(height: 12),
            Text(_chaptersError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w600, color: Mz.rose400)),
            const SizedBox(height: 12),
            HoverBuilder(
              onTap: _loadChapters,
              builder: (context, hover) => AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: hover ? Mz.cyan600 : Mz.cyan500,
                  borderRadius: BorderRadius.circular(20), // rounded-xl
                  boxShadow: MzShadow.xs,
                ),
                // gap-1.5 + the icon's mr-2
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(BootstrapIcons.arrow_clockwise, size: 14, color: Colors.white),
                  SizedBox(width: 14),
                  Text('Retry',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 20 / 14,
                          color: Colors.white)),
                ]),
              ),
            ),
          ],
        ),
      );
    } else if (_quizChapters.isNotEmpty) {
      body = _grid([
        for (final (ci, chapter) in _quizChapters.indexed) _chapterCard(ci, chapter, perfMap),
      ], 20);
    } else {
      body = _emptyState(BootstrapIcons.journal_x, 'No chapters available',
          color: dark ? Colors.white : Tw.slate600);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 12,
          runSpacing: 12,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(BootstrapIcons.controller, size: 24, color: Mz.cyan400),
                const SizedBox(width: 8),
                Text('Quiz Arena',
                    style: TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w900, height: 1.33, color: _strong)),
                const SizedBox(width: 16),
                // <Badge> is not registered in the component → plain inline text.
                Text('${_quizChapters.length} Chapters',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _strong)),
              ],
            ),
            // Button ghost/sm. The kit's `hover:text-accent-foreground` (light)
            // and `dark:hover:bg-accent/50` (dark) survive tailwind-merge.
            HoverBuilder(
              onTap: _closeQuizArena,
              builder: (context, hover) {
                final fg = dark
                    ? (hover ? Colors.white : Colors.white.withValues(alpha: 0.5))
                    : (hover ? Mz.accentForeground : Tw.slate400);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  height: 32,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: hover
                        ? (dark ? Mz.accent.withValues(alpha: 0.5) : Tw.slate100)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14), // rounded-md
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(BootstrapIcons.x_lg, size: 14, color: fg),
                    const SizedBox(width: 10), // gap-1.5 + mr-1
                    Text('Close',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: fg)),
                  ]),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 20),
        body,
      ],
    );
  }

  Widget _chapterCard(int ci, _Json chapter, Map<String, _Json> perfMap) {
    final dark = context.isDark;
    final selected =
        _selectedChapterForQuiz != null && _selectedChapterForQuiz!['id'] == chapter['id'];
    final perf = perfMap[jsNumKey(chapter['id'])];
    final pct = _chapterPct(perf);
    final barFraction = pct.isNaN ? 0.0 : (pct / 100).clamp(0.0, 1.0);
    final unit = jsTruthy(chapter['unit']) ? jsDisplay(chapter['unit']) : 'Chapter';

    // A plain <div> (not a Card) → no shadow-sm.
    return _blurCard(
      radius: 32,
      cardShadow: false,
      extraShadow: selected
          ? const [
              BoxShadow(color: Mz.cyan400, spreadRadius: 2),
              BoxShadow(color: Color.fromRGBO(34, 211, 238, 0.15), blurRadius: 20),
            ]
          : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          HoverBuilder(
            onTap: () => _toggleChapterActivities(chapter),
            builder: (context, hover) => AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.all(20),
              color: hover
                  ? (dark ? Colors.white.withValues(alpha: 0.05) : Tw.slate50)
                  : Colors.transparent,
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: dark ? Mz.cyan400.withValues(alpha: 0.1) : Mz.cyan50,
                      borderRadius: BorderRadius.circular(20), // rounded-xl
                      border: Border.all(
                          color: dark ? Mz.cyan400.withValues(alpha: 0.3) : Mz.cyan200),
                    ),
                    child: Text('${ci + 1}',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: dark ? Mz.cyan400 : Mz.cyan600)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(jsDisplay(chapter['name']),
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                height: 1.375,
                                color: _strong)),
                        const SizedBox(height: 2),
                        Text(unit.toUpperCase(),
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                                color: _text.withValues(alpha: 0.5))),
                        const SizedBox(height: 8),
                        // Progress bar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: Container(
                            height: 6,
                            color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate200,
                            alignment: Alignment.centerLeft,
                            child: TweenAnimationBuilder<double>(
                              tween: Tween(end: barFraction),
                              duration: const Duration(milliseconds: 500),
                              builder: (_, v, _) => FractionallySizedBox(
                                widthFactor: v,
                                heightFactor: 1,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: pct >= 100 ? Mz.green400 : Mz.cyan400,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Opacity(
                          opacity: 0.5,
                          child: Text('${jsRoundLabel(pct)}%',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: dark ? Colors.white : Tw.slate600)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    selected ? BootstrapIcons.chevron_up : BootstrapIcons.chevron_down,
                    size: 16,
                    color: dark ? Colors.white.withValues(alpha: 0.3) : Tw.slate300,
                  ),
                ],
              ),
            ),
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            transitionBuilder: _slideDown,
            child: selected
                ? KeyedSubtree(
                    key: ValueKey('open-${chapter['id']}'),
                    child: _chapterActivities(chapter, perfMap),
                  )
                : const SizedBox.shrink(key: ValueKey('closed')),
          ),
        ],
      ),
    );
  }

  Widget _chapterActivities(_Json chapter, Map<String, _Json> perfMap) {
    final dark = context.isDark;
    final Widget body;
    if (_activitiesLoading) {
      body = _loadingRow('Loading activities…', small: true);
    } else if (_chapterActivitiesForQuiz.isEmpty) {
      body = _emptyState(BootstrapIcons.inbox, 'No activities in this chapter',
          color: dark ? Colors.white : Tw.slate500, small: true);
    } else {
      final divider = dark ? Colors.white.withValues(alpha: 0.05) : Tw.slate100;
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final (i, act) in _chapterActivitiesForQuiz.indexed) ...[
            if (i > 0) Container(height: 1, color: divider),
            HoverBuilder(
              builder: (context, hover) => AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                color: hover
                    ? (dark ? Colors.white.withValues(alpha: 0.05) : Tw.slate50)
                    : Colors.transparent,
                child: Row(
                  children: [
                    _thumb(act, 40),
                    const SizedBox(width: 12),
                    Expanded(child: _activityInfo(act, perfMap, chapter['id'], large: false)),
                    const SizedBox(width: 12),
                    _QuizButton(onTap: () => _openQuizForActivity(act)),
                  ],
                ),
              ),
            ),
          ],
        ],
      );
    }
    return Container(
      decoration: BoxDecoration(
        border: Border(
            top: BorderSide(
                color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate100)),
      ),
      child: body,
    );
  }

  // ── QUIZ RESULT TOAST ──

  Widget _resultToast() {
    final dark = context.isDark;
    final tickets = _toastTickets;
    final won = tickets > 0;
    final stars = _ticketsToStars(tickets);
    final fg = won ? Colors.white : (dark ? Colors.white : Tw.slate900);

    final content = Container(
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: won
            ? const CssLinearGradient(
                corner: Alignment.bottomRight,
                colors: [Tw.amber400, Tw.orange400],
              )
            : null,
        color: won ? null : (dark ? Mz.darkDialog : Colors.white),
        borderRadius: BorderRadius.circular(16),
        border: won
            ? null
            : Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate200),
        // shadow-2xl (the light "submitted" variant's later shadow-xl wins).
        boxShadow: !won && !dark ? MzShadow.xl : MzShadow.xl2,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: fg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: won
                      ? Colors.white.withValues(alpha: 0.2)
                      : Tw.amber400.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  won ? BootstrapIcons.trophy_fill : BootstrapIcons.patch_check,
                  size: 18,
                  color: won ? Colors.white : Tw.amber400,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(won ? '🎉 Quiz Complete!' : 'Quiz Submitted!',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w900, height: 1.25)),
                  const SizedBox(height: 2),
                  Text(_toastMsg,
                      style: TextStyle(
                          fontSize: 12,
                          height: 16 / 12,
                          color: won
                              ? Colors.white.withValues(alpha: 0.8)
                              : fg.withValues(alpha: 0.55))),
                  const SizedBox(height: 10),
                  Row(children: [
                    Icon(BootstrapIcons.ticket_perforated_fill,
                        size: 16, color: won ? Colors.white : Tw.amber400),
                    const SizedBox(width: 6),
                    Text(jsDisplay(tickets),
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w900, height: 1)),
                    const SizedBox(width: 6),
                    Text('ticket${tickets != 1 ? 's' : ''} earned',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: won
                                ? Colors.white.withValues(alpha: 0.7)
                                : fg.withValues(alpha: 0.5))),
                  ]),
                  const SizedBox(height: 6),
                  Row(children: [
                    for (var s = 1; s <= 5; s++) ...[
                      if (s > 1) const SizedBox(width: 2),
                      Icon(
                        s <= stars ? BootstrapIcons.star_fill : BootstrapIcons.star,
                        size: 12,
                        color: s <= stars
                            ? (won ? Colors.white : Tw.amber400)
                            : (won ? Colors.white.withValues(alpha: 0.35) : Tw.slate300),
                      ),
                    ],
                  ]),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Container(
                      height: 2,
                      color: won
                          ? Colors.white.withValues(alpha: 0.2)
                          : (dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate200),
                      alignment: Alignment.centerLeft,
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(_toastSeq),
                        tween: Tween(begin: 1, end: 0),
                        duration: const Duration(seconds: 5),
                        builder: (_, v, _) => FractionallySizedBox(
                          widthFactor: v,
                          heightFactor: 1,
                          child: ColoredBox(
                              color: won ? Colors.white.withValues(alpha: 0.6) : Tw.amber400),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            HoverBuilder(
              onTap: () => setState(() => _toastVisible = false),
              builder: (context, hover) => Padding(
                padding: const EdgeInsets.only(top: 2),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: hover ? 1 : 0.4,
                  child: Icon(BootstrapIcons.x_lg, size: 14, color: fg),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // toast-pop transition
    return IgnorePointer(
      ignoring: !_toastVisible,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: _toastVisible ? 300 : 220),
        opacity: _toastVisible ? 1 : 0,
        child: AnimatedSlide(
          duration: Duration(milliseconds: _toastVisible ? 350 : 220),
          curve: _toastVisible ? const Cubic(0.34, 1.56, 0.64, 1) : Curves.ease,
          offset: _toastVisible ? Offset.zero : const Offset(0, 0.15),
          child: AnimatedScale(
            duration: Duration(milliseconds: _toastVisible ? 350 : 220),
            curve: _toastVisible ? const Cubic(0.34, 1.56, 0.64, 1) : Curves.ease,
            scale: _toastVisible ? 1 : 0.94,
            child: content,
          ),
        ),
      ),
    );
  }

  // ── NO QUESTIONS DIALOG ──

  void _showNoQuestions(String activityName) {
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (dialogContext, _, _) => _NoQuestionsDialog(activityName: activityName),
      transitionBuilder: (_, anim, _, child) {
        final forward = anim.status != AnimationStatus.reverse;
        final curved = CurvedAnimation(
            parent: anim, curve: forward ? const Cubic(0.34, 1.56, 0.64, 1) : Curves.ease);
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim, curve: Curves.ease),
          child: AnimatedBuilder(
            animation: curved,
            builder: (_, c) => Transform.translate(
              offset: Offset(0, (forward ? 24 : 12) * (1 - curved.value)),
              child: Transform.scale(
                scale: (forward ? 0.94 : 0.97) + (forward ? 0.06 : 0.03) * curved.value,
                child: c,
              ),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

/// Blue "Quiz" button used on every activity row.
class _QuizButton extends StatelessWidget {
  const _QuizButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => HoverBuilder(
        onTap: onTap,
        builder: (context, hover) => AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: hover ? Tw.blue600 : Tw.blue500,
            borderRadius: BorderRadius.circular(20), // rounded-xl
            boxShadow: MzShadow.md,
          ),
          // gap-1.5 + the icon's mr-1; text-[10px] keeps the 1.5 line height.
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(BootstrapIcons.pencil_square, size: 10, color: Colors.white),
            SizedBox(width: 10),
            Text('Quiz',
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w900, height: 1.5, color: Colors.white)),
          ]),
        ),
      );
}

class _NoQuestionsDialog extends StatelessWidget {
  const _NoQuestionsDialog({required this.activityName});
  final String activityName;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    void close() => Navigator.of(context).pop();

    final strong = dark ? Colors.white : Tw.slate900;
    final barBg = dark ? Colors.white.withValues(alpha: 0.05) : Tw.slate50;
    final barBorder = dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate100;
    final radius = sm
        ? BorderRadius.circular(32)
        : const BorderRadius.vertical(top: Radius.circular(32));

    final dialog = Material(
      type: MaterialType.transparency,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: dark ? Mz.darkDialog : Colors.white,
          borderRadius: radius,
          border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.1) : Tw.slate200),
          boxShadow: MzShadow.xl2,
        ),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: strong),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  color: barBg,
                  border: Border(bottom: BorderSide(color: barBorder)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: dark ? Tw.amber500.withValues(alpha: 0.2) : Tw.amber50,
                        borderRadius: BorderRadius.circular(20), // rounded-xl
                        border: Border.all(
                            color: dark ? Tw.amber500.withValues(alpha: 0.3) : Tw.amber200),
                      ),
                      child: Icon(BootstrapIcons.exclamation_triangle,
                          size: 14, color: dark ? Tw.amber400 : Tw.amber500),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Opacity(
                            opacity: 0.4,
                            child: Text('QUIZ UNAVAILABLE',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1,
                                    color: strong)),
                          ),
                          const SizedBox(height: 2),
                          Text(activityName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                  height: 1.25,
                                  color: strong)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    HoverBuilder(
                      onTap: close,
                      builder: (context, hover) => AnimatedScale(
                        duration: const Duration(milliseconds: 150),
                        scale: hover ? 1.1 : 1,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dark
                                ? Colors.white.withValues(alpha: hover ? 0.2 : 0.1)
                                : (hover ? Tw.slate200 : Tw.slate100),
                            border: Border.all(
                                color: dark ? Colors.white.withValues(alpha: 0.2) : Tw.slate200),
                          ),
                          child: Icon(BootstrapIcons.x_lg,
                              size: 12, color: dark ? Colors.white : Tw.slate600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Body
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: dark ? Tw.amber500.withValues(alpha: 0.1) : Tw.amber50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: dark
                                ? Tw.amber500.withValues(alpha: 0.2)
                                : const Color(0xFFFEF3C7)),
                      ),
                      child: const Icon(BootstrapIcons.question_circle,
                          size: 30, color: Tw.amber400),
                    ),
                    const SizedBox(height: 16),
                    Text('No Questions Yet',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w900, height: 28 / 18, color: strong)),
                    const SizedBox(height: 8),
                    Text(
                      "Quiz questions for this activity haven't been added yet. "
                      'Please check back later or try a different activity.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 14,
                          height: 1.625,
                          color: dark ? Colors.white.withValues(alpha: 0.5) : Tw.slate500),
                    ),
                  ],
                ),
              ),
              // Footer
              Container(
                padding: EdgeInsets.fromLTRB(
                    20, 16, 20, 16 + (sm ? 0 : MediaQuery.paddingOf(context).bottom)),
                decoration: BoxDecoration(
                  color: barBg,
                  border: Border(top: BorderSide(color: barBorder)),
                ),
                child: Center(
                  child: HoverBuilder(
                    onTap: close,
                    builder: (context, hover) => AnimatedScale(
                      duration: const Duration(milliseconds: 150),
                      scale: hover ? 1.05 : 1,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: hover ? 0.9 : 1, // hover:opacity-90
                        child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                        decoration: BoxDecoration(
                          color: hover ? Mz.cyan600 : Mz.cyan500,
                          borderRadius: BorderRadius.circular(20), // rounded-xl
                          boxShadow: MzShadow.md,
                        ),
                        child: const Text('Got it',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: Colors.white)),
                      ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Stack(
      children: [
        // @click.self → close; bg-black/60 + backdrop-filter: blur(8px)
        Positioned.fill(
          child: GestureDetector(
            onTap: close,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: const ColoredBox(color: Color(0x99000000)),
            ),
          ),
        ),
        Align(
          alignment: sm ? Alignment.center : Alignment.bottomCenter,
          child: Padding(
            padding: EdgeInsets.all(sm ? 16 : 0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: sm ? 384 : double.infinity),
              child: dialog,
            ),
          ),
        ),
      ],
    );
  }
}
