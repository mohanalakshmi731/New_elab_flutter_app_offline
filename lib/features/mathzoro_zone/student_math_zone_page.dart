import '../../widgets/content_image.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import '../offline/offline_runtime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/json.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../widgets/web_content_view.dart';
import '../mathzoro/mathzoro_controller.dart';
import '../mathzoro/mathzoro_quiz.dart';
import '../mathzoro/mz_html_text.dart';
import '../mathzoro/mz_ui.dart' show jsStr, jsDisplay, jsNumKey;
import '../student_activity/zsl_activity_controller.dart';
import 'math_zone_logic.dart';
import 'mz_zone_ui.dart';

part 'student_math_zone_banner.dart';
part 'student_math_zone_roadmap.dart';
part 'student_math_zone_board.dart';
part 'student_math_zone_dialogs.dart';

/// Port of `src/components/new_ui_student_teacher_for_both_labs/studentmathzone.vue`
/// (`/newlayout/newmathzone`, MathZoro sidebar "Math Zone").
///
/// Reads from the MathZoro store (`mathZoroProvider`): `selectedClass`,
/// `math_zoro_courses`, `lastOpenedChapter`; `selectedActivityContext`
/// (initial class / subject names) through `zslActivityProvider`; from the
/// session: `userInfo` (institute id, `mathzoroclassid` / `zsl_class_id`
/// fallback, `is_math_zoro`) and `language`. Writes `lastOpenedChapter` and,
/// on LAUNCH, `selectedActivityContext` (`zslActivityProvider.setActivityContext`).
///
/// The quiz is `mathzoroquiz.vue` (imported as `QuizExam`), i.e.
/// [showMathZoroQuiz], not the shared `QuizExam.vue`.
class StudentMathZonePage extends ConsumerStatefulWidget {
  const StudentMathZonePage({super.key});

  @override
  ConsumerState<StudentMathZonePage> createState() =>
      _StudentMathZonePageState();
}

/// `whyModal`.
class _WhyModal {
  const _WhyModal({
    this.open = false,
    this.activity,
    this.content = '',
    this.contentType = 'html',
    this.loading = false,
  });

  final bool open;
  final Json? activity;
  final String content;
  final String contentType;
  final bool loading;

  _WhyModal copyWith({
    bool? open,
    String? content,
    String? contentType,
    bool? loading,
  }) => _WhyModal(
    open: open ?? this.open,
    activity: activity,
    content: content ?? this.content,
    contentType: contentType ?? this.contentType,
    loading: loading ?? this.loading,
  );
}

/// `chapterRefModal`.
class _ChapterRefModal {
  const _ChapterRefModal({
    this.open = false,
    this.loading = false,
    this.url,
    this.htmlContent,
    this.chapterName = '',
  });

  final bool open;
  final bool loading;
  final String? url;
  final dynamic htmlContent;

  /// `activeChapter?.name` shown in the header.
  final String chapterName;

  _ChapterRefModal copyWith({
    bool? open,
    bool? loading,
    String? url,
    Object? htmlContent,
  }) => _ChapterRefModal(
    open: open ?? this.open,
    loading: loading ?? this.loading,
    url: url ?? this.url,
    htmlContent: htmlContent ?? this.htmlContent,
    chapterName: chapterName,
  );
}

/// `noQuestionsModal`.
class _NoQuestionsModal {
  const _NoQuestionsModal({this.open = false, this.activityName = ''});
  final bool open;
  final String activityName;
}

class _StudentMathZonePageState extends ConsumerState<StudentMathZonePage> {
  // ── data() ──
  String _selectedClassId = '';
  String _selectedSubjectId = '';
  String _selectedClassName = '';
  String _selectedSubjectName = '';

  List<Json> _chapters = [];
  Map<String, List<Json>> _chaptersCache = {};
  bool _loading = false;
  String? _error;

  int _selectedChapterIndex = 0;
  Json? _activeChapter;
  bool _sheetLoading = false;
  List<Json> _chapterActivities = [];

  dynamic _subjectPerformance;
  String _resolvedClassId = '';
  String _resolvedSubjectId = '';

  final _whyModal = ValueNotifier<_WhyModal>(const _WhyModal());
  final _chapterRefModal = ValueNotifier<_ChapterRefModal>(
    const _ChapterRefModal(),
  );
  final _noQuestionsModal = ValueNotifier<_NoQuestionsModal>(
    const _NoQuestionsModal(),
  );

  Json? _quizActivity;

  final _roadScroll = ScrollController();

  MathZoroController get _mz => ref.read(mathZoroProvider.notifier);

  @override
  void initState() {
    super.initState();
    _initFromContext();
    WidgetsBinding.instance.addPostFrameCallback((_) => _mounted());
  }

  /// `data()` — the class / subject of the last activity context.
  void _initFromContext() {
    final ctx =
        ref.read(zslActivityProvider.notifier).selectedActivityContext ??
        const <String, dynamic>{};
    _selectedClassId = jsTruthy(ctx['classId']) ? jsStr(ctx['classId'])! : '';
    _selectedSubjectId = jsTruthy(ctx['subjectId'])
        ? jsStr(ctx['subjectId'])!
        : '';
    _selectedClassName = jsTruthy(ctx['className'])
        ? jsDisplay(ctx['className'])
        : '';
    _selectedSubjectName = jsTruthy(ctx['subjectName'])
        ? jsDisplay(ctx['subjectName'])
        : '';
  }

  Future<void> _mounted() async {
    // The web store was rehydrated synchronously from sessionStorage.
    await _mz.ready;
    if (!mounted) return;
    setState(_initFromContext);
    await _autoSelectAndLoad();
  }

  @override
  void dispose() {
    _roadScroll.dispose();
    // The modal notifiers are not disposed: an open modal route (root
    // navigator) may outlive the page and still listens to them.
    super.dispose();
  }

  // ── computed ──

  /// `userInfo?.institute_id || userInfo?.instituteId || ''`.
  Object get _instituteId {
    final id = ref.read(sessionProvider).userInfo?.instituteId;
    return jsTruthy(id) ? id! : '';
  }

  bool get _isMath => mzIsMath(_selectedSubjectName);
  Color get _accent =>
      _isMath ? const Color(0xFFFFDE3B) : const Color(0xFF4ADE80);
  Color get _accentSecondary =>
      _isMath ? const Color(0xFFF59E0B) : const Color(0xFF06B6D4);

  Map<String, Json> get _perfMap =>
      mzChapterPerformanceMap(_subjectPerformance);

  Json? _chapterPerfByIndex(Map<String, Json> perfMap, int i) {
    if (i < 0 || i >= _chapters.length) return null;
    return perfMap[jsNumKey(_chapters[i]['id'])];
  }

  double _chapterPctByIndex(Map<String, Json> perfMap, int i) =>
      mzChapterPct(_chapterPerfByIndex(perfMap, i));

  /// `chapterProgress` computed.
  double _chapterProgress(Map<String, Json> perfMap) {
    final ch = _activeChapter;
    if (ch == null) return 0;
    return mzChapterPct(perfMap[jsNumKey(ch['id'])]);
  }

  /// `getActivityStars(act)`.
  double _activityStars(Map<String, Json> perfMap, Json act) {
    final ch = _activeChapter;
    if (ch == null) return 0;
    final activityMap = asMap(perfMap[jsNumKey(ch['id'])]?['activityMap']);
    final perf = asMap(activityMap?[jsNumKey(act['id'])]);
    return mzTicketsToStars(perf?['earned_tickets'] ?? 0);
  }

  String get _langId => jsStr(ref.read(sessionProvider).language.id)!;

  // ── methods ──

  Future<void> _selectChapter(Json? chapter, int index) async {
    if (chapter == null) return;
    setState(() {
      _selectedChapterIndex = index;
      _activeChapter = chapter;
    });
    _mz.setLastOpenedChapter({
      'id': chapter['id'],
      'name': chapter['name'],
      'chapterIndex': index,
    });
    await _loadChapterActivities(chapter['id']);
  }

  Future<void> _loadChapterActivities(dynamic chapterId) async {
    final key = cacheKey(chapterId);
    final cached = _chaptersCache[key];
    if (cached != null) {
      setState(() => _chapterActivities = cached);
      return;
    }
    setState(() => _sheetLoading = true);
    try {
      final topics = await _mz.getZslLinks(_instituteId, chapterId, _langId);
      final acts = mzFlattenTopics(topics, chapterId);
      if (!mounted) return;
      setState(() {
        _chaptersCache = {..._chaptersCache, key: acts};
        _chapterActivities = acts;
      });
    } catch (e) {
      debugPrint('$e');
      if (mounted) setState(() => _chapterActivities = []);
    } finally {
      if (mounted) setState(() => _sheetLoading = false);
    }
  }

  Future<void> _openWhyToLearn(Json activity) async {
    _whyModal.value = _WhyModal(open: true, activity: activity, loading: true);
    _showWhyModal();
    try {
      final topics = await _mz.getZslLinks(
        _instituteId,
        activity['chapter_id'],
        _langId,
      );
      // topics?.find(t => String(t.id) === String(activity.topic_id))
      if (jsTruthy(topics) && topics is! List)
        throw StateError('topics.find is not a function');
      final topicLink = asList(topics)
          .map(asMap)
          .firstWhere(
            (t) => jsStr(t?['id']) == jsStr(activity['topic_id']),
            orElse: () => null,
          );
      final acts = topicLink?['activities'];
      if (jsTruthy(acts) && acts is! List)
        throw StateError('activities.find is not a function');
      final act = asList(acts)
          .map(asMap)
          .firstWhere(
            (a) => jsStr(a?['id']) == jsStr(activity['id']),
            orElse: () => null,
          );
      final desc = asMap(act?['description']);

      var content = jsTruthy(desc?['content'])
          ? jsDisplay(desc!['content'])
          : (jsTruthy(desc?['text']) ? jsDisplay(desc!['text']) : '');
      var contentType = 'html';

      if (content.isEmpty && jsTruthy(desc?['content_path'])) {
        final descId = jsTruthy(desc!['description_id'])
            ? desc['description_id']
            : desc['id'];
        if (jsTruthy(descId)) {
          final r = asMap(await _mz.getWhyToLearnSignedUrl(jsStr(descId)!));
          final url = jsTruthy(r?['signed_url']) ? r!['signed_url'] : r?['url'];
          if (jsTruthy(url)) {
            content = jsDisplay(url);
            contentType = 'iframe';
          }
        }
      }
      _whyModal.value = _whyModal.value.copyWith(
        content: content,
        contentType: contentType,
      );
    } catch (e) {
      debugPrint('$e');
      _whyModal.value = _whyModal.value.copyWith(
        content: '',
        contentType: 'html',
      );
    } finally {
      _whyModal.value = _whyModal.value.copyWith(loading: false);
    }
  }

  Future<void> _openChapterReferenceDialog() async {
    final chapter = _activeChapter;
    if (chapter == null) return;
    _chapterRefModal.value = _ChapterRefModal(
      open: true,
      loading: true,
      chapterName: jsDisplay(chapter['name']),
    );
    _showChapterRefModal();
    try {
      if (chapter['chapter_reference_text'] != null) {
        _chapterRefModal.value = _chapterRefModal.value.copyWith(
          htmlContent: chapter['chapter_reference_text'],
          loading: false,
        );
        return;
      }
      if (jsTruthy(chapter['chapter_reference_url'])) {
        final res = asMap(
          await _mz.getChapterReferenceSignedLink(
            jsStr(chapter['id']) ?? 'undefined',
          ),
        );
        if (jsTruthy(res?['url'])) {
          _chapterRefModal.value = _chapterRefModal.value.copyWith(
            url: jsDisplay(res!['url']),
          );
        }
      }
    } catch (e) {
      debugPrint('Failed to load chapter reference: $e');
    } finally {
      _chapterRefModal.value = _chapterRefModal.value.copyWith(loading: false);
    }
  }

  String _activityTitle(Json activity) {
    if (jsTruthy(activity['name'])) return jsDisplay(activity['name']);
    if (jsTruthy(activity['topic_name']))
      return jsDisplay(activity['topic_name']);
    return '';
  }

  void _showNoQuestions(Json activity) {
    _noQuestionsModal.value = _NoQuestionsModal(
      open: true,
      activityName: _activityTitle(activity),
    );
    _showNoQuestionsModal();
  }

  Future<void> _openQuiz(Json activity) async {
    if (ref.read(offlineBrowsingProvider)) {
      _launchActivity({...activity, 'offlineQuiz': true});
      return;
    }
    try {
      final res = await _mz.getZslQuestions(
        jsStr(activity['id']) ?? 'undefined',
      );
      final questions = dataOr(res, const []);
      if (questions is! List || questions.isEmpty) {
        if (mounted) _showNoQuestions(activity);
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
      if (mounted) _showNoQuestions(activity);
    }
  }

  Future<void> _onQuizSubmitted(
    List<Map<String, String>> answersPayload,
  ) async {
    final mz = _mz;
    try {
      await mz.submitZslQuiz(
        activityId: jsStr(_quizActivity?['id']) ?? 'undefined',
        answers: answersPayload,
      );
      // Refresh ticket count in navbar
      mz.dispatchTicketsUpdated();
      await _refreshPerformance();
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _onQuizClose() => _quizActivity = null;

  Future<void> _refreshPerformance() async {
    if (_resolvedSubjectId.isEmpty || _resolvedClassId.isEmpty) return;
    try {
      final perf = await _mz.getSubjectPerformance(
        _resolvedSubjectId,
        _resolvedClassId,
      );
      if (!mounted) return;
      setState(() {
        _subjectPerformance = dataOr(perf, null);
        final chapterId = _quizActivity?['chapter_id'];
        if (jsTruthy(chapterId)) {
          _chaptersCache = {..._chaptersCache}..remove(cacheKey(chapterId));
        }
      });
    } catch (e) {
      debugPrint('Performance refresh failed: $e');
    }
  }

  void _launchActivity(Json activity) {
    final store = ref.read(zslActivityProvider.notifier);
    final ctx = store.selectedActivityContext;
    store.setActivityContext({
      ...?ctx,
      'classId': _selectedClassId,
      'className': _selectedClassName,
      'subjectId': _selectedSubjectId,
      'subjectName': _selectedSubjectName,
      'chapterId': activity['chapter_id'],
      'topicId': activity['topic_id'],
      'topicName': activity['topic_name'],
      'topicImage': jsTruthy(activity['file_path'])
          ? activity['file_path']
          : '',
      'activityId': activity['id'],
      'offlineQuiz': activity['offlineQuiz'] == true,
      'fromRoute': GoRouterState.of(context).uri.path,
      'returnPath': '/newlayout/newmathzone',
    });
    context.go('/newlayout/studentactivitypage');
  }

  /// The first truthy value of `a || b || c || ''`, displayed.
  static String _or(List<dynamic> values) {
    for (final v in values) {
      if (jsTruthy(v)) return jsDisplay(v);
    }
    return '';
  }

  Future<void> _autoSelectAndLoad() async {
    if (!jsTruthy(_instituteId)) {
      setState(() => _error = 'Missing institute information.');
      return;
    }

    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final store = ref.read(mathZoroProvider);
      // `store.selectedClass` (+ the sessionStorage 'selected_class' fallback:
      // mathZoroProvider persists selectedClass across restarts).
      Json? selectedClass = store.selectedClass;

      // Single-class login fallback
      if (!jsTruthy(selectedClass?['zsl_class_id'])) {
        final ui = ref.read(sessionProvider).userInfo;
        final fallbackClassId = jsTruthy(ui?.mathzoroClassId)
            ? ui?.mathzoroClassId
            : ui?.zslClassId;
        if (jsTruthy(fallbackClassId))
          selectedClass = {'zsl_class_id': fallbackClassId};
      }

      if (!jsTruthy(selectedClass?['zsl_class_id'])) {
        _error = 'No class selected.';
        return;
      }

      _selectedClassId = jsStr(selectedClass!['zsl_class_id'])!;
      _resolvedClassId = _selectedClassId;

      // Load subjects for selected class
      await _mz.getAllSubjects(_instituteId, _selectedClassId);
      final raw = ref.read(mathZoroProvider).allsubject;
      final subjects = jsTruthy(raw) ? raw : const [];
      if (subjects is! List || subjects.isEmpty) {
        _error = 'No subjects found.';
        return;
      }

      // Find MATHZONE course matching this class
      final mathZoneCourse = findZoneCourse(
        ref.read(mathZoroProvider).mathZoroCourses,
        'mathzone',
        _selectedClassId,
      );
      if (!jsTruthy(mathZoneCourse?['zsl_subject_id'])) {
        _error = 'No MathZone course found for this class.';
        return;
      }

      final selectedSubject = findZoneSubject(
        subjects,
        mathZoneCourse!['zsl_subject_id'],
      );
      if (selectedSubject == null) {
        _error =
            'MathZone subject not found. Subject Id = ${jsDisplay(mathZoneCourse['zsl_subject_id'])}';
        return;
      }

      _selectedSubjectId = zoneSubjectId(selectedSubject);
      _selectedSubjectName = _or([
        selectedSubject['name'],
        selectedSubject['course_title'],
        mathZoneCourse['title'],
      ]);
      _resolvedSubjectId = _selectedSubjectId;

      await _fetchAllChaptersAndPerformance();
    } catch (e) {
      debugPrint('$e');
      _error = 'Failed to load class/subject data.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// `Promise.allSettled` entry.
  static Future<(bool, dynamic)> _settle(Future<dynamic> f) async {
    try {
      return (true, await f);
    } catch (e) {
      return (false, e);
    }
  }

  Future<void> _fetchAllChaptersAndPerformance() async {
    if (!jsTruthy(_instituteId) ||
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

      final results = await Future.wait([
        _settle(
          _mz.getSubjectPerformance(_resolvedSubjectId, _resolvedClassId),
        ),
        _settle(
          _mz.getallchpaters(
            _instituteId,
            _selectedClassId,
            _selectedSubjectId,
          ),
        ),
      ]);
      if (!mounted) return;
      final (perfOk, perf) = results[0];
      final (chsOk, chs) = results[1];

      if (perfOk) {
        _subjectPerformance = dataOr(perf, null);
      } else {
        debugPrint('Performance load failed: $perf');
        _subjectPerformance = null;
      }

      _chapters = chsOk && chs is List
          ? chs.map(asMap).whereType<Map<String, dynamic>>().toList()
          : <Json>[];

      if (!chsOk) _error = 'Failed to load chapters.';
      setState(() {});

      if (_chapters.isNotEmpty) {
        final saved = ref.read(mathZoroProvider).lastOpenedChapter;
        final savedIndex = saved != null
            ? _chapters.indexWhere(
                (ch) => jsStr(ch['id']) == jsStr(saved['id']),
              )
            : -1;

        final targetIndex = savedIndex != -1 ? savedIndex : 0;
        final targetChapter = _chapters[targetIndex];

        setState(() {
          _activeChapter = targetChapter;
          _selectedChapterIndex = targetIndex;
        });

        _mz.setLastOpenedChapter({
          'id': targetChapter['id'],
          'name': targetChapter['name'],
          'chapterIndex': targetIndex,
        });

        await _loadChapterActivities(targetChapter['id']);
      }
    } catch (e) {
      debugPrint('$e');
      _error = 'Failed to load chapters.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── template ──

  /// `.classmathzone { font-family: 'Inter', … }` (the app's Inter family,
  /// every weight registered — see [AppFonts]).
  TextStyle _t(
    double size,
    FontWeight weight,
    Color? color, {
    double? height,
    double? spacing,
    List<Shadow>? shadows,
  }) => TextStyle(
    fontFamily: AppFonts.inter,
    fontFamilyFallback: AppFonts.fallback,
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
    letterSpacing: spacing,
    shadows: shadows,
  );

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final ui = ref.watch(sessionProvider.select((s) => s.userInfo));
    final banner = _MzBanner(
      isMath: _isMath,
      accent: _accent,
      accentSecondary: _accentSecondary,
      showBack: !(ui?.isMathZoro ?? false),
      onBack: () => context.go('/newlayout/teachersdashboardpage'),
      text: _t,
    );

    final Widget body;
    if (_loading) {
      body = Column(
        children: [
          banner,
          Expanded(child: _loadingView()),
        ],
      );
    } else if (_error != null) {
      body = Column(
        children: [
          banner,
          Expanded(child: _errorView(_error!)),
        ],
      );
    } else {
      final perfMap = _perfMap;
      body = SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [banner, _roadmap(perfMap), _board(perfMap)],
        ),
      );
    }

    return ColoredBox(
      color: dark ? const Color(0xFF161233) : const Color(0xFFF1F5F9),
      child: DefaultTextStyle.merge(
        style: _t(14, FontWeight.w400, dark ? Colors.white : Tw.gray900),
        child: body,
      ),
    );
  }

  Widget _loadingView() => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ZoneRingSpinner(
          size: 44,
          stroke: 3,
          track: _accent.withValues(alpha: 0x33 / 255),
          head: _accent,
        ),
        const SizedBox(height: 16),
        Opacity(
          opacity: 0.5,
          child: Text(
            'Loading chapters…',
            style: _t(
              14,
              FontWeight.w700,
              null,
              height: 20 / 14,
              spacing: 0.35,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _errorView(String error) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            error,
            textAlign: TextAlign.center,
            style: _t(14, FontWeight.w600, Tw.red400, height: 20 / 14),
          ),
          const SizedBox(height: 16),
          ZonePress(
            onTap: _autoSelectAndLoad,
            builder: (context, _, _) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _accent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'Retry',
                style: _t(
                  14,
                  FontWeight.w700,
                  const Color(0xFF1A1200),
                  height: 20 / 14,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
