import '../../widgets/content_image.dart';
import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import '../offline/offline_runtime.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../../widgets/web_content_view.dart';
import '../mathzoro/mathzoro_controller.dart';
import '../mathzoro/mz_html_text.dart';
import '../mathzoro/mz_ui.dart'
    show CssLinearGradient, HoverBuilder, jsStr, jsDisplay, jsNumKey;
import '../quiz/quiz_exam.dart';
import '../student_activity/student_activity_logic.dart'
    show dataOrSelfList, descriptionText, sameId, signedUrlOf;
import '../student_activity/zsl_activity_controller.dart';
import 'science_zone_logic.dart';

part 'science_zone_view.dart';
part 'science_zone_dialogs.dart';

/// Port of `src/components/new_ui_student_teacher_for_both_labs/
/// studentsciencezone.vue` (`/studentsciencezone`, eLabs DashboardShell):
/// banner, "Your Learning Path" milestone road (one flag per chapter of the
/// class's Physics/Science/Chemistry subject), activity board with stars,
/// Why Learn / Chapter Reference dialogs, quiz and LAUNCH (→ the activity
/// page).
class StudentScienceZonePage extends ConsumerStatefulWidget {
  const StudentScienceZonePage({super.key});

  @override
  ConsumerState<StudentScienceZonePage> createState() =>
      _StudentScienceZonePageState();
}

typedef _Json = Map<String, dynamic>;

/// Science accent colours.
const _accent = Color(0xFF4ADE80); // accentColor
const _accentSecondary = Color(0xFF06B6D4); // accentSecondary
const _bannerBg = Color(0xFF003A1D);

/// `whyModal` — mutated in place like the web object.
class _WhyModal {
  bool open = false;
  _Json? activity;
  String content = '';
  String contentType = 'html';
  bool loading = false;
}

/// `chapterRefModal`.
class _ChapterRefModal {
  bool open = false;
  bool loading = false;
  String? url;
  String? htmlContent;
}

class _StudentScienceZonePageState
    extends ConsumerState<StudentScienceZonePage> {
  String _selectedClassId = '';
  String _selectedSubjectId =
      ''; // always resolved fresh — never from persisted context
  String _selectedClassName = '';
  String _selectedSubjectName = '';

  List<_Json> _chapters = [];
  Map<String, List<_Json>> _chaptersCache = {};
  bool _loading = false;
  String? _error;

  int _selectedChapterIndex = 0;
  _Json? _activeChapter;
  bool _sheetLoading = false;
  List<_Json> _chapterActivities = [];
  int _chapterProgressFallback = 0;

  // ── Performance data ──
  dynamic _subjectPerformance;
  String _resolvedClassId = '';
  String _resolvedSubjectId = '';

  _WhyModal _whyModal = _WhyModal();
  _ChapterRefModal _chapterRefModal = _ChapterRefModal();
  Route<void>? _whyRoute;
  Route<void>? _chapterRefRoute;

  String _quizTitle = '';
  List<dynamic> _quizExamQuestions = [];
  _Json? _quizActivity;

  final _roadScroll = ScrollController();
  final _rev = ValueNotifier<int>(0);

  MathZoroController get _mz => ref.read(mathZoroProvider.notifier);
  ZslActivityController get _zsl => ref.read(zslActivityProvider.notifier);

  void _set(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
    _rev.value++;
  }

  // ── computed ─────────────────────────────────────────────────────────────

  /// `userInfo?.institute_id || userInfo?.instituteId || ''`.
  dynamic get _instituteId {
    final id = ref.read(sessionProvider).userInfo?.instituteId;
    return jsTruthy(id) ? id : '';
  }

  int get _languageId => ref.read(sessionProvider).language.id;

  List<_Json> get _filteredChapters => _chapters;

  Map<String, Map<String, dynamic>> get _chapterPerformanceMap =>
      chapterPerformanceMap(_subjectPerformance);

  Map<String, dynamic>? get _activeChapterPerf {
    final ch = _activeChapter;
    if (ch == null) return null;
    return _chapterPerformanceMap[jsNumKey(ch['id'])];
  }

  int get _chapterProgress {
    final perf = _activeChapterPerf;
    if (perf != null) return jsRound(perf['percentage']);
    return _chapterProgressFallback;
  }

  Map<String, dynamic>? _getChapterPerfByIndex(int i) {
    if (i < 0 || i >= _filteredChapters.length) return null;
    return _chapterPerformanceMap[jsNumKey(_filteredChapters[i]['id'])];
  }

  int _getChapterPctByIndex(int i) =>
      jsRound(_getChapterPerfByIndex(i)?['percentage']);

  Map<String, dynamic>? _getActivityPerf(_Json act) {
    final ch = _activeChapter;
    if (ch == null) return null;
    final chPerf = _chapterPerformanceMap[jsNumKey(ch['id'])];
    final activityMap = chPerf?['activityMap'];
    if (activityMap is! Map) return null;
    return asMap(activityMap[jsNumKey(act['id'])]);
  }

  int _getActivityStars(_Json act) =>
      ticketsToStars(_getActivityPerf(act)?['earned_tickets'] ?? 0);

  // ── lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _mz.ready;
    if (!mounted) return;
    // data()
    final ctx = _zsl.selectedActivityContext ?? const <String, dynamic>{};
    _selectedClassId = jsTruthy(ctx['classId']) ? jsStr(ctx['classId'])! : '';
    _selectedClassName = jsTruthy(ctx['className'])
        ? jsDisplay(ctx['className'])
        : '';
    // mounted()
    await _autoSelectAndLoad();
  }

  @override
  void dispose() {
    for (final r in [_whyRoute, _chapterRefRoute]) {
      if (r != null && r.isActive) r.navigator?.removeRoute(r);
    }
    _whyRoute = null;
    _chapterRefRoute = null;
    _roadScroll.dispose();
    _rev.dispose();
    super.dispose();
  }

  void _fire(Future<void> Function() action) {
    action().catchError((Object e) => debugPrint('StudentScienceZonePage: $e'));
  }

  void _scrollPathRight() {
    if (!_roadScroll.hasClients) return;
    final pos = _roadScroll.position;
    _roadScroll.animateTo(
      math.min(pos.maxScrollExtent, pos.pixels + 300),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // ── Chapter selection ────────────────────────────────────────────────────

  Future<void> _selectChapter(_Json? chapter, int index) async {
    if (chapter == null) return;
    _set(() {
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
    final key = jsStr(chapterId) ?? 'undefined';
    final cached = _chaptersCache[key];
    if (cached != null) {
      _set(() {
        _chapterActivities = cached;
        _chapterProgressFallback = cached.isNotEmpty ? 100 : 0;
      });
      return;
    }
    _set(() => _sheetLoading = true);
    try {
      final topics = await _mz.getZslLinks(
        _instituteId,
        chapterId,
        _languageId,
      );
      if (topics != null && topics is! List)
        throw StateError('topics.flatMap is not a function');
      final acts = <_Json>[
        for (final t in asList(topics).map(asMap).whereType<_Json>())
          for (final a in asList(t['activities']).map(asMap).whereType<_Json>())
            {
              ...a,
              'file_path': jsTruthy(a['file_path'])
                  ? a['file_path']
                  : (jsTruthy(t['file_path']) ? t['file_path'] : ''),
              'topic_name': t['name'],
              'topic_id': t['id'],
              'chapter_id': chapterId,
              'description_preview': descriptionPreview(a),
            },
      ];
      _set(() {
        _chaptersCache = {..._chaptersCache, key: acts};
        _chapterActivities = acts;
        _chapterProgressFallback = acts.isNotEmpty ? 100 : 0;
      });
    } catch (e) {
      debugPrint('$e');
      _set(() {
        _chapterActivities = [];
        _chapterProgressFallback = 0;
      });
    } finally {
      _set(() => _sheetLoading = false);
    }
  }

  // ── Why to Learn ─────────────────────────────────────────────────────────

  Future<void> _openWhyToLearn(_Json activity) async {
    final modal = _WhyModal()
      ..open = true
      ..activity = activity
      ..loading = true;
    _set(() => _whyModal = modal);
    _showWhyRoute();
    try {
      final topics = await _mz.getZslLinks(
        _instituteId,
        activity['chapter_id'],
        _languageId,
      );
      if (topics != null && topics is! List)
        throw StateError('topics.find is not a function');
      final topicLink = asList(topics)
          .map(asMap)
          .whereType<_Json>()
          .where((t) => sameId(t['id'], activity['topic_id']))
          .firstOrNull;
      final act = asList(topicLink?['activities'])
          .map(asMap)
          .whereType<_Json>()
          .where((a) => sameId(a['id'], activity['id']))
          .firstOrNull;
      final desc = asMap(act?['description']);

      var content = descriptionText(desc);
      var contentType = 'html';

      if (content.isEmpty && jsTruthy(desc?['content_path'])) {
        final descId = jsTruthy(desc!['description_id'])
            ? desc['description_id']
            : desc['id'];
        if (jsTruthy(descId)) {
          final r = await _zsl.getWhyToLearnSignedUrl(jsStr(descId)!);
          final url = signedUrlOf(r);
          if (url.isNotEmpty) {
            content = url;
            contentType = 'iframe';
          }
        }
      }
      _set(() {
        _whyModal.content = content;
        _whyModal.contentType = contentType;
      });
    } catch (e) {
      debugPrint('$e');
      _set(() {
        _whyModal.content = '';
        _whyModal.contentType = 'html';
      });
    } finally {
      _set(() => _whyModal.loading = false);
    }
  }

  // ── Chapter Reference ────────────────────────────────────────────────────

  Future<void> _openChapterReferenceDialog() async {
    final chapter = _activeChapter;
    if (chapter == null) return;
    final modal = _ChapterRefModal()
      ..open = true
      ..loading = true;
    _set(() => _chapterRefModal = modal);
    _showChapterRefRoute();
    try {
      if (chapter['chapter_reference_text'] != null) {
        _set(() {
          _chapterRefModal.htmlContent = jsDisplay(
            chapter['chapter_reference_text'],
          );
          _chapterRefModal.loading = false;
        });
        return;
      }
      if (jsTruthy(chapter['chapter_reference_url'])) {
        final res = await _zsl.getChapterReferenceSignedLink(
          jsStr(chapter['id']) ?? 'undefined',
        );
        final url = asMap(res)?['url'];
        if (jsTruthy(url)) _set(() => _chapterRefModal.url = jsDisplay(url));
      }
    } catch (err) {
      debugPrint('Failed to load chapter reference: $err');
    } finally {
      _set(() => _chapterRefModal.loading = false);
    }
  }

  // ── Quiz ─────────────────────────────────────────────────────────────────

  Future<void> _openQuiz(_Json activity) async {
    if (ref.read(offlineBrowsingProvider)) {
      _launchActivity({...activity, 'offlineQuiz': true});
      return;
    }
    try {
      final res = await _mz.getZslQuestions(
        jsStr(activity['id']) ?? 'undefined',
      );
      final questions = dataOrSelfList(res);
      if (questions.isEmpty) return;
      _set(() {
        _quizExamQuestions = questions;
        _quizActivity = activity;
        _quizTitle = jsTruthy(activity['name'])
            ? jsDisplay(activity['name'])
            : (jsTruthy(activity['topic_name'])
                  ? jsDisplay(activity['topic_name'])
                  : '');
      });
      if (!mounted) return;
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

  Future<void> _onQuizSubmitted(Map<String, dynamic> payload) async {
    try {
      final answers = asList(
        payload['answersPayload'],
      ).map((e) => Map<String, String>.from(asMap(e) ?? const {})).toList();
      await _zsl.submitZslQuiz(
        activityId: jsStr(_quizActivity?['id']) ?? 'undefined',
        answers: answers,
      );
      await _refreshPerformance();
    } catch (e) {
      debugPrint('$e');
    }
  }

  void _onQuizClose() => _set(() {
    _quizActivity = null;
    _quizExamQuestions = [];
  });

  // ── Performance refresh after quiz ───────────────────────────────────────

  Future<void> _refreshPerformance() async {
    if (_resolvedSubjectId.isEmpty || _resolvedClassId.isEmpty) return;
    try {
      final perf = await _mz.getSubjectPerformance(
        _resolvedSubjectId,
        _resolvedClassId,
      );
      _set(() => _subjectPerformance = _perfData(perf));

      final chapterId = _quizActivity?['chapter_id'];
      if (jsTruthy(chapterId)) {
        final cid = jsStr(chapterId)!;
        _set(() => _chaptersCache = {..._chaptersCache}..remove(cid));
      }
    } catch (e) {
      debugPrint('Performance refresh failed: $e');
    }
  }

  /// `perf?.data || perf || null`.
  static dynamic _perfData(dynamic perf) {
    final inner = asMap(perf)?['data'];
    if (jsTruthy(inner)) return inner;
    return jsTruthy(perf) ? perf : null;
  }

  // ── Launch ───────────────────────────────────────────────────────────────

  void _launchActivity(_Json activity) {
    _zsl.setActivityContext({
      ...?_zsl.selectedActivityContext,
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
      'returnPath': '/newlayout/newsciencezone',
    });
    // router.push('studentactivitypage') — relative to the current path.
    final path = GoRouterState.of(context).uri.path;
    final base = path.contains('/')
        ? path.substring(0, path.lastIndexOf('/'))
        : '';
    context.go('$base/studentactivitypage');
  }

  // ── Bootstrap ────────────────────────────────────────────────────────────

  Future<void> _autoSelectAndLoad() async {
    _set(() {
      _selectedClassId = '';
      _selectedClassName = '';
      _selectedSubjectId = '';
      _selectedSubjectName = '';
      _chapters = [];
      _chaptersCache = {};
      _activeChapter = null;
      _selectedChapterIndex = 0;
      _chapterActivities = [];
      _chapterProgressFallback = 0;
      _subjectPerformance = null;
    });

    if (!jsTruthy(_instituteId)) {
      _set(() => _error = 'Missing institute information.');
      return;
    }

    try {
      _set(() {
        _loading = true;
        _error = null;
      });

      // 1. Classes
      final classRes = await ref
          .read(zslServiceProvider)
          .getClass(_instituteId, null);
      final classes = classRes is List
          ? classRes
          : _listOf(classRes, 'classes');

      if (classes.isEmpty) {
        _set(() => _error = 'No classes available.');
        return;
      }

      final matchedClass =
          asMap(
            classes
                .where((c) => sameId(asMap(c)?['id'], _selectedClassId))
                .firstOrNull,
          ) ??
          asMap(classes[0]);
      _set(() {
        _selectedClassId = jsStr(matchedClass?['id']) ?? 'undefined';
        _selectedClassName = jsDisplay(matchedClass?['name']);
        _resolvedClassId = _selectedClassId;
      });

      // 2. Subjects — always fresh, never persisted subjectId
      final subjectRes = await _mz.getAllSubjects(
        _instituteId,
        _selectedClassId,
      );
      final subjects = subjectRes is List
          ? subjectRes
          : _listOf(subjectRes, 'subjects');

      if (subjects.isEmpty) {
        _set(() => _error = 'No subjects available.');
        return;
      }

      // 3. Find Physics/Science/Chemistry
      final physicsSubject = findPhysicsSubject(subjects);
      if (physicsSubject == null) {
        _set(
          () => _error = 'Physics / Science subject not found for this class.',
        );
        debugPrint(
          '[ClassScienceView] Subjects available: '
          '${subjects.map((s) => '${jsDisplay(asMap(s)?['id'])}:${jsDisplay(asMap(s)?['name'])}').toList()}',
        );
        return;
      }

      _set(() {
        _selectedSubjectId = jsStr(physicsSubject['id']) ?? 'undefined';
        _selectedSubjectName = jsDisplay(physicsSubject['name']);
        _resolvedSubjectId = _selectedSubjectId;
      });
    } catch (e) {
      debugPrint('[ClassScienceView] autoSelectAndLoad error: $e');
      _set(() => _error = 'Failed to load class/subject data.');
      return;
    } finally {
      _set(() => _loading = false);
    }

    await _fetchAllChaptersAndPerformance();
  }

  /// `res?.data || res?.[key] || []` (anything but an array counts as empty).
  static List<dynamic> _listOf(dynamic res, String key) {
    final m = asMap(res);
    final v = jsTruthy(m?['data'])
        ? m!['data']
        : (jsTruthy(m?[key]) ? m![key] : const []);
    return v is List ? v : const [];
  }

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
      _set(() => _error = 'Missing context.');
      return;
    }
    try {
      _set(() {
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
      final (perfOk, perfValue) = results[0];
      final (chsOk, chsValue) = results[1];

      _set(() {
        if (perfOk) {
          _subjectPerformance = _perfData(perfValue);
        } else {
          debugPrint('Performance load failed: $perfValue');
          _subjectPerformance = null;
        }

        _chapters = chsOk && chsValue is List
            ? chsValue.map(asMap).whereType<_Json>().toList()
            : [];

        if (!chsOk) _error = 'Failed to load chapters.';
      });

      if (_chapters.isNotEmpty) {
        final saved = ref.read(mathZoroProvider).lastOpenedChapter;
        final savedIndex = saved != null
            ? _chapters.indexWhere((ch) => sameId(ch['id'], saved['id']))
            : -1;

        final targetIndex = savedIndex != -1 ? savedIndex : 0;
        final targetChapter = _chapters[targetIndex];

        _set(() {
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
      debugPrint('[ClassScienceView] fetchAllChaptersAndPerformance error: $e');
      _set(() => _error = 'Failed to load chapters.');
    } finally {
      _set(() => _loading = false);
    }
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) => _buildPage(context);
}
