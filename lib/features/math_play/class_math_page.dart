import '../../widgets/content_image.dart';
import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../offline/offline_runtime.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../widgets/app_button.dart';
import '../../widgets/lucide_icon.dart';
import '../mathzoro/mathzoro_controller.dart';
import '../mathzoro/mz_ui.dart';
import '../quiz/quiz_exam.dart';
import 'class_math_painters.dart';
import 'class_math_scene.dart';
import 'math_play_store.dart';
import 'math_play_ui.dart';

part 'class_math_map.dart';
part 'class_math_sheet.dart';

/// Port of `src/components/Mathzoro/classmath.vue` (component `RoadmapView`)
/// — `/classmath` inside the eLabs DashboardShell.
///
/// No route params / query. Reads `selectedActivityContext.classId` /
/// `.subjectName` on mount and writes the class/subject (and, on Play/Exam,
/// the chapter/topic/activity) back with `setActivityContext` before going to
/// `/activitylibrary` — see [MathPlayStore] (lmsHandoff
/// `selectedActivityContext`, mirrored into [mathZoroProvider]).
///
/// Web bug NOT kept: `filteredChapters` is declared under `methods`, so the
/// template's `filteredChapters.length` is a function's arity (0) and the web
/// page always shows "No chapters yet" after loading. Here it is the computed
/// list it was meant to be (chapters whose `subject_id` matches the selected
/// subject), so the roadmap renders.
class ClassMathPage extends ConsumerStatefulWidget {
  const ClassMathPage({super.key});

  @override
  ConsumerState<ClassMathPage> createState() => _ClassMathPageState();
}

/// `cubic-bezier(.34,1.56,.64,1)` — the signIn / dotPop easing.
const _kBackOut = Cubic(0.34, 1.56, 0.64, 1);

TextStyle _nunito({
  double? size,
  FontWeight? weight,
  Color? color,
  double? height,
  double? spacing,
}) => GoogleFonts.nunito(
  fontSize: size,
  fontWeight: weight,
  color: color,
  height: height,
  letterSpacing: spacing,
);

TextStyle _fredoka({double? size, Color? color, double? spacing}) =>
    GoogleFonts.fredoka(
      fontSize: size,
      fontWeight: FontWeight.w600,
      color: color,
      letterSpacing: spacing,
    );

class _ClassMathPageState extends ConsumerState<ClassMathPage>
    with TickerProviderStateMixin {
  // ── data() ──
  String _selectedClassId = '';
  String _selectedSubjectName = '';
  String _selectedSubjectId = '';

  /// Not declared in data() on the web (undefined until a class is picked).
  String? _selectedClassName;

  List<Json> _chapters = [];
  Map<String, List<Json>> _chaptersCache = {};
  bool _loading = false;
  String? _error;

  bool _sheetOpen = false;
  ChapterNode? _activeChapter;
  bool _sheetLoading = false;
  List<Json> _sheetActivities = [];

  Json? _quizActivity;
  String _quizTitle = '';
  List<dynamic> _quizExamQuestions = [];

  // ── Flutter-side state ──
  final _scroll = ScrollController();
  final _sheetPortal = OverlayPortalController();
  late final AnimationController _sheetAnim =
      AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 500),
        reverseDuration: const Duration(milliseconds: 300),
      )..addStatusListener((s) {
        if (s == AnimationStatus.dismissed) _sheetPortal.hide();
      });

  /// Sign / dot entrance animations (`signIn`, `dotPop`).
  late final AnimationController _entrance = AnimationController(vsync: this);
  bool _mapShown = false;

  /// Seconds for the dark-mode campfire / window / smoke animations.
  final _time = ValueNotifier<double>(0);
  late final Ticker _ticker = createTicker((elapsed) {
    _time.value = elapsed.inMicroseconds / Duration.microsecondsPerSecond;
  });

  ClassMathScene? _scene;

  MathZoroController get _mz => ref.read(mathZoroProvider.notifier);
  MathPlayStore get _store => ref.read(mathPlayStoreProvider);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _mounted());
  }

  Future<void> _mounted() async {
    // data(): the store was hydrated before the component was created.
    await _mz.ready;
    if (!mounted) return;
    final ctx = _store.selectedActivityContext ?? const <String, dynamic>{};
    setState(() {
      _selectedClassId = jsTruthy(ctx['classId']) ? jsStr(ctx['classId'])! : '';
      _selectedSubjectName = jsTruthy(ctx['subjectName'])
          ? jsDisplay(ctx['subjectName'])
          : '';
    });
    await _autoSelectAndLoad();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    _sheetAnim.dispose();
    _entrance.dispose();
    _scroll.dispose();
    super.dispose();
  }

  // ── computed ─────────────────────────────────────────────────────────────

  String get _instituteId => _store.instituteId;

  /// `filteredChapters` — see the class doc.
  List<Json> get _filteredChapters =>
      filterChaptersBySubject(_chapters, _selectedSubjectId);

  /// JS object key of `chaptersCache[id]`.
  static String _cacheKey(dynamic id) => jsStr(id) ?? 'null';

  int _chapterActivityCount(dynamic chapterId) =>
      (_chaptersCache[_cacheKey(chapterId)] ?? const []).length;

  // ── methods ──────────────────────────────────────────────────────────────

  void _scrollToBottom() {
    if (_scroll.hasClients) _scroll.jumpTo(_scroll.position.maxScrollExtent);
  }

  Future<void> _openSheet(ChapterNode chapter) async {
    final key = _cacheKey(chapter.id);
    setState(() {
      _activeChapter = chapter;
      _sheetActivities = _chaptersCache[key] ?? [];
      _sheetOpen = true;
    });
    _sheetPortal.show();
    _sheetAnim.forward();
    if (!_chaptersCache.containsKey(key)) {
      setState(() => _sheetLoading = true);
      await _prefetchActivities(chapter.id, _store.languageId);
      if (!mounted) return;
      setState(() {
        _sheetActivities = _chaptersCache[key] ?? [];
        _sheetLoading = false;
      });
    }
  }

  void _onSheetOpenChange(bool val) {
    setState(() {
      _sheetOpen = val;
      if (!val) {
        _activeChapter = null;
        _sheetActivities = [];
      }
    });
    if (!val) _sheetAnim.reverse();
  }

  Future<void> _autoSelectAndLoad() async {
    if (_instituteId.isEmpty) {
      setState(() => _error = 'Missing institute information.');
      return;
    }
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final classRes = await ref
          .read(zslServiceProvider)
          .getClass(_instituteId, null);
      final classes = arrayOr(classRes, 'classes');
      if (!hasItems(classes)) {
        if (mounted) {
          setState(() {
            _error = 'No classes available.';
            _loading = false;
          });
        }
        return;
      }

      final matchedClass = pickClass(classes as List, _selectedClassId);
      _selectedClassId = jsStringOf(matchedClass, 'id');
      _selectedClassName = jsStr(matchedClass['name']);

      final subjectRes = await _mz.getAllSubjects(
        _instituteId,
        _selectedClassId,
      );
      final subjects = arrayOr(subjectRes, 'subjects');
      if (!hasItems(subjects)) {
        if (mounted) {
          setState(() {
            _error = 'No subjects available.';
            _loading = false;
          });
        }
        return;
      }

      // Always force Mathematics — never trust persisted subjectId
      final mathSubject = pickMathSubject(subjects as List);
      _selectedSubjectId = jsStringOf(mathSubject, 'id');
      _selectedSubjectName = jsDisplay(mathSubject['name']);

      _store.setActivityContext({
        'classId': _selectedClassId,
        'className': _selectedClassName,
        'subjectId': _selectedSubjectId,
        'subjectName': mathSubject['name'],
      });
    } catch (e) {
      debugPrint('$e');
      if (mounted) {
        setState(() {
          _error = 'Failed to load class/subject data.';
          _loading = false;
        });
      }
      return;
    }

    await _fetchAllChapters();
    // this.$nextTick(() => this.scrollToBottom())
    if (mounted)
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  Future<void> _fetchAllChapters() async {
    if (_instituteId.isEmpty ||
        _selectedClassId.isEmpty ||
        _selectedSubjectId.isEmpty) {
      setState(() => _error = 'Missing context.');
      return;
    }
    try {
      setState(() {
        _loading = true;
        _error = null;
      });
      final chs = await _mz.getallchpaters(
        _instituteId,
        _selectedClassId,
        _selectedSubjectId,
      );
      if (!mounted) return;
      setState(() {
        _chapters = [
          if (chs is List)
            for (final c in chs) asMap(c) ?? <String, dynamic>{},
        ];
      });
      for (final ch in _chapters) {
        _prefetchActivities(ch['id'], _store.languageId);
      }
    } catch (e) {
      debugPrint('$e');
      if (mounted) setState(() => _error = 'Failed to load chapters.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _prefetchActivities(dynamic chapterId, int? langId) async {
    final key = _cacheKey(chapterId);
    if (_chaptersCache.containsKey(key)) return;
    try {
      final topics = await _mz.getZslLinks(_instituteId, chapterId, langId);
      final acts = flattenTopicActivities(topics, chapterId);
      if (!mounted) return;
      setState(() {
        _chaptersCache = {..._chaptersCache, key: acts};
        if (_activeChapter != null && _activeChapter!.id == chapterId)
          _sheetActivities = acts;
      });
    } catch (e) {
      debugPrint('$e');
      if (mounted)
        setState(() => _chaptersCache = {..._chaptersCache, key: const []});
    }
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
    'offlineQuiz': activity['offlineQuiz'] == true,
    'fromRoute': GoRouterState.of(context).uri.path,
  };

  void _goToActivity(Json activity) {
    _store.setActivityContext(_activityContextPatch(activity));
    context.go('/activitylibrary');
  }

  Future<void> _goToQuiz(Json activity) async {
    if (ref.read(offlineBrowsingProvider)) {
      _goToActivity({...activity, 'offlineQuiz': true});
      return;
    }
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
            : (jsTruthy(activity['topic_name'])
                  ? jsDisplay(activity['topic_name'])
                  : 'Quiz');
      });
      unawaited(
        showQuizExam(
          context,
          questions: _quizExamQuestions,
          quizTitle: _quizTitle,
          onSubmitted: _onQuizSubmitted,
          onClose: _onQuizClose,
        ),
      );
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

  // ── animations ───────────────────────────────────────────────────────────

  void _syncTicker(bool run) {
    if (run && !_ticker.isActive) {
      _ticker.start();
    } else if (!run && _ticker.isActive) {
      _ticker.stop();
    }
  }

  /// signIn: .55s + idx × .09s delay; dotPop: .45s.
  static double _entranceSeconds(int count) =>
      math.max(0.55 + (count - 1) * 0.09, 0.45);

  void _onMapVisibility(bool visible, int count) {
    if (visible == _mapShown) return;
    _mapShown = visible;
    if (!visible) {
      _entrance.value = 0;
      return;
    }
    _entrance.duration = Duration(
      milliseconds: (_entranceSeconds(count) * 1000).round(),
    );
    _entrance.forward(from: 0);
  }

  // ── UI ───────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final filtered = _filteredChapters;
    final mapVisible = !_loading && _error == null && filtered.isNotEmpty;

    final needsTicker = dark && mapVisible;
    if (needsTicker != _ticker.isActive || mapVisible != _mapShown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _syncTicker(needsTicker);
        _onMapVisibility(mapVisible, filtered.length);
      });
    }

    final Widget body;
    if (_loading) {
      body = _buildLoading(dark);
    } else if (_error != null) {
      body = _buildError(dark);
    } else if (filtered.isEmpty && !_loading) {
      body = Center(
        child: Text(
          'No chapters yet',
          style: _nunito(
            size: 14,
            weight: FontWeight.w600,
            height: TwLeading.sm,
            color: dark
                ? Tw.slate500
                : AppColors.primaryForeground.withValues(alpha: 0.5),
          ),
        ),
      );
    } else {
      body = _buildMap(context, dark, filtered);
    }

    return PopScope(
      canPop: !_sheetOpen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _sheetOpen) _onSheetOpenChange(false);
      },
      child: OverlayPortal(
        controller: _sheetPortal,
        overlayLocation: OverlayChildLocation.rootOverlay,
        overlayChildBuilder: (ctx) => _buildSheet(ctx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: kTwEase,
          color: dark ? Tw.slate950 : AppColors.primary,
          child: SizedBox.expand(child: body),
        ),
      ),
    );
  }

  Widget _buildLoading(bool dark) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // `rounded-full border-[3px] animate-spin` + `border-t-*`
        BorderSpinner(
          size: 44,
          stroke: 3,
          track: dark
              ? Tw.slate800
              : AppColors.primaryForeground.withValues(alpha: 0.2),
          head: dark ? AppColors.darkPrimary : AppColors.primaryForeground,
        ),
        const SizedBox(height: 16),
        Text(
          'Loading chapters…',
          style: _nunito(
            size: 14,
            weight: FontWeight.w700,
            spacing: 0.35,
            height: TwLeading.sm,
            color: dark
                ? Tw.slate400
                : AppColors.primaryForeground.withValues(alpha: 0.7),
          ),
        ),
      ],
    ),
  );

  Widget _buildError(bool dark) {
    final destructive = dark
        ? AppColors.darkDestructive
        : AppColors.destructive;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: dark
                    ? Tw.slate900
                    : AppColors.primaryForeground.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: dark
                      ? Tw.slate800
                      : AppColors.primaryForeground.withValues(alpha: 0.2),
                ),
              ),
              child: SvgIcon(
                SvgGlyph.alertCircle,
                size: 24,
                color: destructive,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? '',
              textAlign: TextAlign.center,
              style: _nunito(
                size: 14,
                weight: FontWeight.w600,
                height: TwLeading.sm,
                color: destructive,
              ),
            ),
            const SizedBox(height: 16),
            AppButton(
              label: 'Retry',
              variant: AppButtonVariant.outline,
              size: AppButtonSize.sm,
              onPressed: _autoSelectAndLoad,
            ),
          ],
        ),
      ),
    );
  }
}
