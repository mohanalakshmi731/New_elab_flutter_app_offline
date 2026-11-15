import 'dart:async';
import 'dart:io' show Platform;
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../state/lab_practice.dart';
import '../lab_admin/lab_activity_host.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/web_content_view.dart';
import '../institutes/institute_widgets.dart' show SpinIcon;
import '../mathzoro/mathzoro_controller.dart';
import '../mathzoro/mz_html_text.dart';
import '../mathzoro/mz_ui.dart' show CssLinearGradient, HoverBuilder, cssBackdrop, jsStr, jsDisplay;
import '../quiz/bridged_web_view.dart';
import '../quiz/quiz_exam.dart';
import 'student_activity_logic.dart';
import 'zsl_activity_controller.dart';

part 'student_activity_view.dart';
part 'student_activity_overlays.dart';

/// Port of `src/components/new_ui_student_teacher_for_both_labs/
/// studentactivitypage.vue` — the activity player (iframe + Why to Learn /
/// Instructions / Learning Outcome tabs, chapter/topic/activity sidebar,
/// all-activities popup, quiz, XP performance recording).
///
/// Routes: `/studentactivitypage` (eLabs DashboardShell) and
/// `/newlayout/studentactivitypage` (MathZoro shell). The page itself has no
/// flavor branches; everything comes from `selectedActivityContext`
/// (`{ classId, className, subjectId, subjectName, chapterId, chapterName,
/// topicId, topicName, topicImage, activityId, returnPath, … }`) which the
/// launching screen stores via `mathZoroProvider.notifier
/// .setSelectedActivityContext(...)` before navigating here.
class _StudentActivityPageContent extends ConsumerStatefulWidget {
  const _StudentActivityPageContent({super.key, this.fromPlayZone});

  /// `$route.query.fromPlayZone` — `'1'` when opened from the Play Zone
  /// (hides the folder button and the quiz tab).
  final String? fromPlayZone;

  @override
  ConsumerState<_StudentActivityPageContent> createState() => _StudentActivityPageState();
}

typedef _Json = Map<String, dynamic>;

class _TabDef {
  const _TabDef(this.key, this.label, this.icon);
  final String key;
  final String label;
  final IconData icon;
}

const _tabs = <_TabDef>[
  _TabDef('why-to-learn', 'Why to Learn', BootstrapIcons.lightbulb),
  _TabDef('teacher-guide', 'Instructions', BootstrapIcons.journal_text),
  _TabDef('learning-outcome', 'Learning Outcome', BootstrapIcons.eye),
  // _TabDef('quiz', 'Quiz', BootstrapIcons.patch_question),
];

/// `activeTabContent` (`{ text, url }`) — mutable like the web object, so a
/// late write lands on whichever object is current at that moment.
class _TabContent {
  String text = '';
  String url = '';
}

/// An open `fixed inset-0` layer (a route on the root navigator).
class _ModalSlot {
  Route<void>? route;
}

class _StudentActivityPageState extends ConsumerState<_StudentActivityPageContent> with WindowListener {
  bool _ready = false;

  // ── Quiz ──
  bool _quizSubmitted = false;
  dynamic _quizResult;
  List<dynamic> _quizExamQuestions = [];
  bool _quizStarted = false;
  bool _quizLoading = false;
  List<dynamic> _quizQuestions = [];

  // ── Tabs ──
  String? _activeTab = 'why-to-learn';
  _TabContent _activeTabContent = _TabContent();
  bool _tabContentLoading = false;

  // ── Activity context ──
  String _signedUrl = '';
  dynamic _trackingId;
  bool _loadingActivity = false;
  bool _pageLoading = true;
  bool _isFullscreen = false;

  dynamic _chapterId = '';
  String _chapterName = 'Unknown Chapter';
  dynamic _topicId = '';
  String _topicName = 'Unknown Topic';
  dynamic _classId = '';
  dynamic _subjectId = '';
  String _subjectName = 'Unknown Subject';
  dynamic _activityIdFromRoute = '';

  _Json? _selectedActivity;
  dynamic _selectedActivityId;
  List<_Json> _allChapters = [];
  final Map<String, dynamic> _signedUrls = {};
  String _selectedChapterId = '';
  final Map<String, List<_Json>> _chaptersCache = {};
  dynamic _selectedSubjectId = '';
  dynamic _selectedClassId = '';
  bool _loading = false;
  String? _error;
  List<_Json> _allactivities = [];

  // performanceModal
  bool _performanceVisible = false;
  String _performanceTitle = 'Activity Completed';
  String _performanceMessage = '';

  Timer? _trackingInterval;

  // selectedActivity watcher bookkeeping
  _Json? _selectedActivitySeen;
  bool _selectedActivityFlushQueued = false;

  // Layers shown above the shells (`fixed inset-0`).
  final _rev = ValueNotifier<int>(0);
  final _sidebarSlot = _ModalSlot();
  final _popupSlot = _ModalSlot();
  final _learningSlot = _ModalSlot();
  final _performanceSlot = _ModalSlot();

  // Fullscreen activity player (the iframe wrapper's requestFullscreen()).
  final _frameKey = GlobalKey(debugLabel: 'activity-frame');
  Route<void>? _fullscreenRoute;
  bool _windowFullscreen = false;

  MathZoroController get _mz => ref.read(mathZoroProvider.notifier);
  ZslActivityController get _zsl => ref.read(zslActivityProvider.notifier);

  void _set(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
    _rev.value++;
  }

  // ── computed ─────────────────────────────────────────────────────────────

  bool get _isFromPlayZone => widget.fromPlayZone == '1';

  /// `userInfo?.institute_id || userInfo?.instituteId || ''`.
  dynamic get _instituteId {
    final id = ref.read(sessionProvider).userInfo?.instituteId;
    return jsTruthy(id) ? id : '';
  }

  /// `this.language?.id ?? null`.
  int get _languageId => ref.read(sessionProvider).language.id;

  bool get _hasActivities => _allactivities.isNotEmpty && _signedUrl.isNotEmpty;

  List<_Json> get _filteredChapters {
    final key = jsStr(_selectedSubjectId) ?? '';
    if (!jsTruthy(_selectedSubjectId) || _chaptersCache[key] == null) return const [];
    return _chaptersCache[key]!;
  }

  _Json? get _selectedChapter {
    for (final c in _filteredChapters) {
      if (sameId(c['id'], _selectedChapterId)) return c;
    }
    return null;
  }

  List<_Json> get _topicsForSelectedChapter => _maps(_selectedChapter?['topics']);

  static List<_Json> _maps(dynamic v) => asList(v).map(asMap).whereType<_Json>().toList();

  /// Throws like `x.length` / `x.find` on a value that isn't an array.
  static List<dynamic> _requireList(dynamic v, String what) {
    if (v is List) return v;
    throw StateError('$what is not an array');
  }

  // ── lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // The persisted store state must be restored before data() reads it.
    await _mz.ready;
    if (!mounted) return;
    final ctx = _zsl.selectedActivityContext ?? const <String, dynamic>{};

    // data()
    _chapterId = jsTruthy(ctx['chapterId']) ? ctx['chapterId'] : '';
    _chapterName = jsTruthy(ctx['chapterName']) ? jsDisplay(ctx['chapterName']) : 'Unknown Chapter';
    _topicId = jsTruthy(ctx['topicId']) ? jsStr(ctx['topicId']) : '';
    _topicName = jsTruthy(ctx['topicName']) ? jsDisplay(ctx['topicName']) : 'Unknown Topic';
    _classId = jsTruthy(ctx['classId']) ? ctx['classId'] : '';
    _subjectId = jsTruthy(ctx['subjectId']) ? ctx['subjectId'] : '';
    _subjectName = jsTruthy(ctx['subjectName']) ? jsDisplay(ctx['subjectName']) : 'Unknown Subject';
    _activityIdFromRoute = jsTruthy(ctx['activityId']) ? ctx['activityId'] : '';
    _selectedChapterId = jsTruthy(ctx['chapterId']) ? jsStr(ctx['chapterId'])! : '';
    _selectedSubjectId = jsTruthy(ctx['subjectId']) ? ctx['subjectId'] : '';
    _selectedClassId = jsTruthy(ctx['classId']) ? ctx['classId'] : '';
    _set(() => _ready = true);

    // mounted()
    await _fetchAllChapters();
    if (!mounted) return;
    _trackingInterval = Timer.periodic(Duration(seconds: ref.read(labPracticeProvider)?.practice == true ? 10 : 5), (_) {
      if (jsTruthy(_trackingId)) _zsl.trackActivity(jsStr(_trackingId)!);
    });
  }

  @override
  void dispose() {
    _trackingInterval?.cancel();
    _trackingInterval = null;
    if (_windowFullscreen) _setWindowFullscreen(false);
    if (_isDesktop) windowManager.removeListener(this);
    final fullscreen = _fullscreenRoute;
    _fullscreenRoute = null;
    if (fullscreen != null && fullscreen.isActive) fullscreen.navigator?.removeRoute(fullscreen);
    for (final slot in [_sidebarSlot, _popupSlot, _learningSlot, _performanceSlot]) {
      final r = slot.route;
      slot.route = null;
      if (r != null && r.isActive) r.navigator?.removeRoute(r);
    }
    _rev.dispose();
    super.dispose();
  }

  /// `watch: language` (deep).
  void _onLanguageChanged(AppLanguage newLang) {
    if (!_ready || newLang.id == 0) return;
    if (jsTruthy(_chapterId) && jsTruthy(_topicId)) _fetchChapterLinks(newLang.id);
    if (_activeTab != null && _activeTab != 'quiz') _loadTabContent(_activeTab!);
  }

  /// `this.selectedActivity = a` + its watcher (which runs after the
  /// current synchronous code, like Vue's pre-flush watchers).
  void _setSelectedActivity(_Json? a) {
    _selectedActivity = a;
    if (_selectedActivityFlushQueued) return;
    _selectedActivityFlushQueued = true;
    scheduleMicrotask(() {
      _selectedActivityFlushQueued = false;
      if (!mounted) return;
      final current = _selectedActivity;
      if (identical(current, _selectedActivitySeen)) return;
      _selectedActivitySeen = current;
      if (current != null) {
        _set(() => _selectedActivityId = current['id']);
        if (_activeTab != null && _activeTab != 'quiz') _loadTabContent(_activeTab!);
      } else {
        _set(() => _selectedActivityId = null);
      }
    });
  }

  /// `userStore.setActivityContext({ ...userStore.selectedActivityContext, ...patch })`.
  void _patchActivityContext(Map<String, dynamic> patch) {
    _zsl.setActivityContext({...?_zsl.selectedActivityContext, ...patch});
  }

  /// Runs an async handler the template fires without awaiting.
  void _fire(Future<void> Function() action) {
    action().catchError((Object e) => debugPrint('StudentActivityPage: $e'));
  }

  // ── Quiz ─────────────────────────────────────────────────────────────────

  void _resetQuiz() => _set(() {
        _quizSubmitted = false;
        _quizResult = null;
        _quizStarted = false;
      });

  Future<void> _startQuiz() async {
    try {
      _set(() {
        _quizLoading = true;
        _quizStarted = true;
      });

      final activityId =
          firstTruthy([_selectedActivity?['id'], _selectedActivityId, _activityIdFromRoute]);

      if (!jsTruthy(activityId)) {
        debugPrint('❌ Activity ID missing');
        return;
      }

      final res = await _mz.getZslQuestions(jsStr(activityId)!);
      final questions = dataOrSelfList(res);

      if (questions.isEmpty) {
        _set(() => _quizQuestions = []);
        return;
      }

      // Hand off to fullscreen QuizExam component
      _set(() => _quizExamQuestions = questions);
      if (mounted) {
        unawaited(showQuizExam(
          context,
          questions: _quizExamQuestions,
          quizTitle: _selectedActivity != null ? activityTitle(_selectedActivity) : _topicName,
          onSubmitted: _onQuizSubmitted,
          onClose: _onQuizClose,
        ));
      }
    } catch (error) {
      debugPrint('Quiz load failed: $error');
      _set(() => _quizQuestions = []);
    } finally {
      _set(() => _quizLoading = false);
    }
  }

  // ← ONLY ONE onQuizSubmitted — calls submitZslQuiz store action
  Future<void> _onQuizSubmitted(Map<String, dynamic> payload) async {
    if (!mounted) return;
    try {
      final activityId = jsTemplate(
          firstTruthy([_selectedActivity?['id'], _selectedActivityId, _activityIdFromRoute]));
      final answers = asList(payload['answersPayload'])
          .map((e) => Map<String, String>.from(asMap(e) ?? const {}))
          .toList();

      final res = await _zsl.submitZslQuiz(activityId: activityId, answers: answers);

      _set(() {
        _quizSubmitted = true;
        _quizResult = res;
      });
    } catch (error) {
      debugPrint('❌ Quiz submission failed: $error');
      _set(() {
        _quizSubmitted = false;
        _quizResult = {'msg': 'Quiz submission failed', 'tickets': 0};
      });
    }
  }

  // ← ONLY ONE onQuizClose
  void _onQuizClose() => _set(() {
        _quizExamQuestions = [];
        _quizStarted = false;
        _quizLoading = false;
      });

  // ── Tabs ─────────────────────────────────────────────────────────────────

  Future<void> _handleTabClick(String tabKey) async {
    if (_activeTab == tabKey) {
      _set(() {
        _activeTab = null;
        _activeTabContent = _TabContent();
      });
      return;
    }
    _set(() => _activeTab = tabKey);
    if (tabKey != 'quiz') await _loadTabContent(tabKey);
  }

  Future<void> _loadTabContent(String tabKey) async {
    _set(() {
      _tabContentLoading = true;
      _activeTabContent = _TabContent();
    });

    try {
      final langId = _languageId;
      List<dynamic> links = [];

      if (jsTruthy(_instituteId) && jsTruthy(_chapterId)) {
        links = _requireList(await _mz.getZslLinks(_instituteId, _chapterId, langId), 'links');
      }

      final topicLink = _maps(links).where((l) => sameId(l['id'], _topicId)).firstOrNull;
      final acts = _maps(topicLink?['activities']);
      final activity = acts.where((a) => sameId(a['id'], _selectedActivityId)).firstOrNull ??
          acts.firstOrNull;

      if (activity == null) {
        debugPrint('No activity found');
        return;
      }

      if (tabKey == 'why-to-learn') {
        final desc = asMap(activity['description']);
        _set(() => _activeTabContent.text = descriptionText(desc));
        if (jsTruthy(desc?['content_path'])) {
          final id = jsTruthy(desc!['description_id']) ? desc['description_id'] : desc['id'];
          if (jsTruthy(id)) {
            final r = await _zsl.getWhyToLearnSignedUrl(jsStr(id)!);
            _set(() => _activeTabContent.url = signedUrlOf(r));
          }
        }
      } else if (tabKey == 'teacher-guide') {
        final list = activity['instructions'];
        final inst = list is List && list.isNotEmpty ? asMap(list.first) : null;
        _set(() => _activeTabContent.text = joinItemTexts(list));
        if (jsTruthy(inst?['content_path'])) {
          final id = jsTruthy(inst!['instruction_id']) ? inst['instruction_id'] : inst['id'];
          if (jsTruthy(id)) {
            final r = await _zsl.getTeacherGuideSignedUrl(jsStr(id)!);
            _set(() => _activeTabContent.url = signedUrlOf(r));
          }
        }
      } else if (tabKey == 'learning-outcome') {
        final list = activity['observations'];
        final obs = list is List && list.isNotEmpty ? asMap(list.first) : null;
        _set(() => _activeTabContent.text = joinItemTexts(list));
        if (jsTruthy(obs?['content_path'])) {
          final id = jsTruthy(obs!['observation_id']) ? obs['observation_id'] : obs['id'];
          if (jsTruthy(id)) {
            final r = await _zsl.getLearningOutcomeSignedUrl(jsStr(id)!);
            _set(() => _activeTabContent.url = signedUrlOf(r));
          }
        }
      }
    } catch (err) {
      debugPrint('Failed to load tab content: $err');
      _set(() => _activeTabContent = _TabContent());
    } finally {
      _set(() => _tabContentLoading = false);
    }
  }

  // ── Chapters / Topics / Activities ───────────────────────────────────────

  Future<void> _fetchAllChaptersWithActivities(List<_Json> chapters) async {
    try {
      final langId = _languageId;
      final results = await Future.wait(
          chapters.map((ch) => _mz.getZslLinks(_instituteId, ch['id'], langId)));
      final all = <_Json>[];
      for (var i = 0; i < chapters.length; i++) {
        final ch = chapters[i];
        final topics = results[i] == null ? const [] : _requireList(results[i], 'topics');
        all.add({
          'id': ch['id'],
          'name': ch['name'],
          'topics': [
            for (final topic in _maps(topics))
              {
                'id': topic['id'],
                'name': topic['name'],
                'file_path': jsTruthy(topic['file_path']) ? topic['file_path'] : '',
                'chapter_id': topic['chapter_id'],
                'activities': topic['activities'] ?? const [],
              },
          ],
        });
      }
      _set(() => _allChapters = all);
    } catch (err) {
      debugPrint('fetchAllChaptersWithActivities failed: $err');
    }
  }

  Future<void> _fetchAllChapters() async {
    if (!jsTruthy(_instituteId) || !jsTruthy(_selectedClassId) || !jsTruthy(_selectedSubjectId)) {
      return;
    }
    try {
      _set(() => _loading = true);
      final chapters = _maps(_requireList(
          await _mz.getallchpaters(_instituteId, _selectedClassId, _selectedSubjectId),
          'chapters'));
      _chaptersCache[jsStr(_selectedSubjectId)!] = chapters;
      unawaited(_fetchAllChaptersWithActivities(chapters));
      if (chapters.isNotEmpty) {
        if (jsTruthy(_chapterId)) {
          final queryChapter = chapters.where((ch) => sameId(ch['id'], _chapterId)).firstOrNull;
          _selectedChapterId = jsStr(queryChapter != null ? _chapterId : chapters[0]['id']) ?? '';
        } else {
          _selectedChapterId = jsStr(chapters[0]['id']) ?? '';
        }
        _set(() {});
        await _handleChapterChange();
      }
    } catch (error) {
      debugPrint('Error fetching chapters: $error');
      _set(() => _error = 'Failed to load chapters');
    } finally {
      _set(() => _loading = false);
    }
  }

  void _clearActivities() {
    _allactivities = [];
    _setSelectedActivity(null);
    _selectedActivityId = null;
    _signedUrl = '';
  }

  Future<void> _fetchChapterLinks([int? languageId]) async {
    if (!jsTruthy(_instituteId) || !jsTruthy(_chapterId)) return;
    _set(() => _pageLoading = true);
    final langId = languageId ?? _languageId;
    try {
      final links = _maps(_requireList(await _mz.getZslLinks(_instituteId, _chapterId, langId), 'links'));
      final topicLink = links.where((l) => sameId(l['id'], _topicId)).firstOrNull;
      final acts = _maps(topicLink?['activities']);
      if (topicLink == null || acts.isEmpty) {
        _set(_clearActivities);
        return;
      }
      _set(() => _allactivities = acts);

      if (jsTruthy(_activityIdFromRoute)) {
        final forced = acts.where((a) => sameId(a['id'], _activityIdFromRoute)).firstOrNull;
        if (forced != null) {
          _set(() {
            _setSelectedActivity(forced);
            _selectedActivityId = forced['id'];
          });
          await _generateActivitySignedUrl(forced);
          await _loadTabContent('why-to-learn');
          return;
        }
      }

      final first = acts[0];
      _set(() {
        _setSelectedActivity(first);
        _selectedActivityId = first['id'];
      });
      await _generateActivitySignedUrl(first);
      await _loadTabContent('why-to-learn');
    } catch (err) {
      debugPrint('Activity load failed $err');
      _set(_clearActivities);
    } finally {
      _set(() => _pageLoading = false);
    }
  }

  void _onChapterChange(String? newVal) {
    if (newVal == null || newVal.isEmpty) return;
    _set(() {
      _selectedChapterId = newVal;
      _topicId = '';
    });
    _fire(_handleChapterChange);
  }

  Future<dynamic> _generateActivitySignedUrl(_Json? activity) async {
    if (activity == null ||
        !jsTruthy(_instituteId) ||
        !jsTruthy(_subjectId) ||
        !jsTruthy(_chapterId) ||
        !jsTruthy(_topicId)) {
      return null;
    }
    final activityId = activity['id'];
    _set(() => _loadingActivity = true);
    try {
      final cacheKey = '${jsTemplate(activityId)}_default';
      dynamic signedUrl;
      if (_signedUrls.containsKey(cacheKey)) {
        signedUrl = _signedUrls[cacheKey];
      } else {
        signedUrl = await _zsl.generateSignedUrl(
            _instituteId, _subjectId, _chapterId, _topicId, activityId ?? '');
        _signedUrls[cacheKey] = signedUrl;
        final tracking = _property(signedUrl, 'tracking_id');
        if (jsTruthy(tracking)) _trackingId = tracking;
      }
      final url = _property(signedUrl, 'url');
      _set(() => _signedUrl = jsTruthy(url) ? jsDisplay(url) : '');
      activity['signed_url'] = url;
      return signedUrl;
    } catch (error) {
      debugPrint('Error generating signed URL: $error');
      rethrow;
    } finally {
      _set(() => _loadingActivity = false);
    }
  }

  /// `value.prop` — throws on null/undefined like JavaScript.
  static dynamic _property(dynamic value, String prop) {
    if (value == null) {
      throw StateError("Cannot read properties of undefined (reading '$prop')");
    }
    return asMap(value)?[prop];
  }

  Future<void> _onActivityChange() async {
    if (!jsTruthy(_selectedActivityId)) return;
    final activity = _allactivities.where((a) => sameId(a['id'], _selectedActivityId)).firstOrNull;
    if (activity == null) return;
    _set(() => _setSelectedActivity(activity));
    _patchActivityContext({'activityId': activity['id']});
    await _generateActivitySignedUrl(activity);
    if (_activeTab != null && _activeTab != 'quiz') {
      await _loadTabContent(_activeTab!);
    }
  }

  Future<void> _handleChapterChange() async {
    final selectedChapter =
        _filteredChapters.where((ch) => sameId(ch['id'], _selectedChapterId)).firstOrNull;
    if (selectedChapter == null) return;
    final isChapterChanging = !sameId(_chapterId, selectedChapter['id']);
    _set(() {
      _selectedChapterId = jsStr(selectedChapter['id']) ?? '';
      _chapterId = selectedChapter['id'];
      _chapterName = jsDisplay(selectedChapter['name']);
    });
    _patchActivityContext({
      'chapterId': selectedChapter['id'],
      'chapterName': selectedChapter['name'],
      'activityId': isChapterChanging ? null : _zsl.selectedActivityContext?['activityId'],
    });
    final topics = _maps(selectedChapter['topics']);
    if (topics.isNotEmpty) {
      final isCurrentTopicInNewChapter = topics.any((t) => sameId(t['id'], _topicId));
      if (!jsTruthy(_topicId) || !isCurrentTopicInNewChapter) {
        await _handleTopicClick(topics[0]);
      } else {
        await _fetchChapterLinks();
      }
    } else {
      _set(() {
        _topicId = '';
        _allactivities = [];
        _signedUrl = '';
      });
    }
  }

  Future<void> _handleTopicClick(_Json? topic) async {
    if (topic == null) return;
    final isTopicChanging = !sameId(_topicId, topic['id']);
    _set(() {
      _topicId = topic['id'];
      _topicName = jsDisplay(topic['name']);
      _setSelectedActivity(null);
      _selectedActivityId = null;
      _signedUrl = '';
      _allactivities = [];
    });
    _patchActivityContext({
      'topicId': topic['id'],
      'topicName': topic['name'],
      'topicImage': jsTruthy(topic['file_path']) ? topic['file_path'] : '',
      'activityId': isTopicChanging ? null : _zsl.selectedActivityContext?['activityId'],
    });
    await _fetchChapterLinks();
  }

  Future<void> _handleActivityFromPopup(_Json topic, _Json activity) async {
    _set(() {
      _topicId = jsStr(topic['id']);
      _topicName = jsDisplay(topic['name']);
      _activityIdFromRoute = jsStr(activity['id']);
      final parentChapter = _allChapters
          .where((ch) => _maps(ch['topics']).any((t) => sameId(t['id'], topic['id'])))
          .firstOrNull;
      if (parentChapter != null && !sameId(parentChapter['id'], _chapterId)) {
        _chapterId = parentChapter['id'];
        _chapterName = jsDisplay(parentChapter['name']);
        _selectedChapterId = jsStr(parentChapter['id']) ?? '';
      }
    });
    _patchActivityContext({
      'chapterId': _chapterId,
      'chapterName': _chapterName,
      'topicId': topic['id'],
      'topicName': topic['name'],
      'topicImage': jsTruthy(topic['file_path']) ? topic['file_path'] : '',
      'activityId': activity['id'],
    });
    _closeModal(_popupSlot);
    _set(() {
      _allactivities = [];
      _setSelectedActivity(null);
      _selectedActivityId = null;
      _signedUrl = '';
    });
    await _fetchChapterLinks();
  }

  // ── Fullscreen ───────────────────────────────────────────────────────────

  static bool get _isDesktop =>
      !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);

  Future<void> _setWindowFullscreen(bool on) async {
    _windowFullscreen = on;
    try {
      if (_isDesktop) {
        if (on) {
          windowManager.addListener(this);
          await windowManager.setFullScreen(true);
        } else {
          windowManager.removeListener(this);
          if (await windowManager.isFullScreen()) await windowManager.setFullScreen(false);
        }
      } else if (!kIsWeb) {
        await SystemChrome.setEnabledSystemUIMode(
            on ? SystemUiMode.immersiveSticky : SystemUiMode.edgeToEdge);
      }
    } catch (_) {
      // Fullscreen may be unavailable; the in-app layer still covers the shell.
    }
  }

  /// `toggleFullscreen()` — the player is moved (not reloaded) into a
  /// full-window route over the whole app, and the window goes full screen.
  /// Dialogs opened meanwhile (the xpChannel alert, the performance dialog)
  /// stack above it. Back / Escape leave fullscreen.
  void _toggleFullscreen() {
    if (_isFullscreen) {
      _exitFullscreen();
      return;
    }
    final route = PageRouteBuilder<void>(
      opaque: true,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      pageBuilder: (_, _, _) => ValueListenableBuilder<int>(
        valueListenable: _rev,
        builder: (context, _, _) => _fullscreenLayer(context),
      ),
    );
    _fullscreenRoute = route;
    Navigator.of(context, rootNavigator: true).push(route).then((_) {
      if (identical(_fullscreenRoute, route)) _fullscreenRoute = null;
      if (_isFullscreen) {
        _set(() => _isFullscreen = false);
        if (_windowFullscreen) _setWindowFullscreen(false);
      }
    });
    _set(() => _isFullscreen = true);
    _setWindowFullscreen(true);
  }

  void _exitFullscreen() {
    final r = _fullscreenRoute;
    _fullscreenRoute = null;
    // The flag flips first, so the page and the route never both hold the
    // player (it is keyed with a GlobalKey).
    _set(() => _isFullscreen = false);
    if (_windowFullscreen) _setWindowFullscreen(false);
    if (r == null || !r.isActive) return;
    if (r.isCurrent) {
      r.navigator?.pop();
    } else {
      r.navigator?.removeRoute(r);
    }
  }

  /// `fullscreenchange` → `isFullscreen = !!document.fullscreenElement`.
  @override
  void onWindowLeaveFullScreen() {
    _windowFullscreen = false;
    if (_isFullscreen) _exitFullscreen();
  }

  // ── iframe channel ───────────────────────────────────────────────────────

  /// `iframe.contentWindow.xpChannel.postMessage(message)`.
  Future<void> _onXpChannelMessage(dynamic message) async {
    debugPrint('[xpChannel Message] Received from activity iframe: $message');
    if (mounted) {
      // alert(`[xpChannel Message] Received: ${message}`)
      await showDialog<void>(
        context: context,
        useRootNavigator: true,
        builder: (ctx) => AlertDialog(
          content: Text('[xpChannel Message] Received: ${jsTemplate(message)}'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
          ],
        ),
      );
    }
    // If message is "true", trigger performance recording API
    if (isXpChannelSuccess(message)) _recordPerformance();
  }

  /// `handleIframeMessage(event)`.
  void _handleIframeMessage(dynamic data) {
    if (data == null) return;
    debugPrint('[Iframe JS Channel Message] Received payload: $data');
    if (isXpSuccessMessage(data)) _recordPerformance();
  }

  void _recordPerformance() {
    if (!mounted) return;
    final activityId = jsTruthy(_selectedActivityId) ? _selectedActivityId : _activityIdFromRoute;
    if (!jsTruthy(activityId)) return;
    _zsl.recordZslActivityPerformance(jsTemplate(activityId), _classId).then((res) {
      final m = asMap(res);
      _showPerformanceModal(
        'Success!',
        jsTruthy(m?['msg'])
            ? jsDisplay(m!['msg'])
            : jsTruthy(m?['message'])
                ? jsDisplay(m!['message'])
                : 'Your performance has been successfully recorded!',
      );
    }).catchError((Object err) {
      debugPrint('Failed to record performance: $err');
      _showPerformanceModal('Failed to Record',
          zslErrorMessage(err, 'Failed to record performance. Please try again.'));
    });
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.listen<AppLanguage>(sessionProvider.select((s) => s.language), (_, next) {
      _onLanguageChanged(next);
    });
    return _buildPage(context);
  }
}

class StudentActivityPage extends StatelessWidget {
  const StudentActivityPage({super.key, this.fromPlayZone});
  final String? fromPlayZone;
  @override
  Widget build(BuildContext context) => LabActivityHost(
    builder: (key) =>
        _StudentActivityPageContent(key: key, fromPlayZone: fromPlayZone),
  );
}
