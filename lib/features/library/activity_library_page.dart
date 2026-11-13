import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart' show AppSelectItem;
import '../../widgets/web_content_view.dart';
import '../institutes/institute_widgets.dart' show SpinIcon;
import '../mathzoro/mz_ui.dart' show CssLinearGradient;
import '../quiz/quiz_exam.dart';
import '../take_exam/exam_window.dart';
import 'library_controller.dart';
import 'library_logic.dart';
import 'library_widgets.dart';

part 'activity_library_workspace.dart';
part 'activity_library_sidebar.dart';

/// Port of `src/pages/library/activitylibrary.vue` (route `/activitylibrary`).
///
/// Reads the `selectedActivityContext` the library / zone pages stored
/// (lmsHandoff), loads the subject's chapters, the topic's activities and a
/// signed URL for the selected activity, and shows it with the Why to Learn /
/// Reference Video / Teacher Guide / Learning Outcome / How to play / Quiz
/// tabs. The folder button opens the chapter / topic / activity drawer and
/// the "All Activities" popup.
class ActivityLibraryPage extends ConsumerStatefulWidget {
  const ActivityLibraryPage({super.key});

  @override
  ConsumerState<ActivityLibraryPage> createState() => _ActivityLibraryPageState();
}

class _TabMeta {
  const _TabMeta(this.label, this.icon);
  final String label;
  final IconData icon;
}

const _tabMeta = <String, _TabMeta>{
  'activity': _TabMeta('Activity', BootstrapIcons.joystick),
  'why-to-learn': _TabMeta('Why to Learn', BootstrapIcons.lightbulb),
  'reference-video': _TabMeta('Reference Video', BootstrapIcons.play_circle),
  'teacher-guide': _TabMeta('Teacher Guide', BootstrapIcons.journal_text),
  'learning-outcome': _TabMeta('Learning Outcome', BootstrapIcons.eye),
  'how-to-play': _TabMeta('How to play', BootstrapIcons.play_btn),
  'quiz': _TabMeta('Quiz', BootstrapIcons.patch_question),
};

class _ActivityLibraryPageState extends ConsumerState<ActivityLibraryPage> {
  // ── data(): quiz ──
  bool _quizSubmitted = false;
  dynamic _quizResult;
  bool _showQuizExam = false;
  List<dynamic> _quizExamQuestions = [];
  dynamic _quizSysSession;
  String _quizSysSessionError = '';
  bool _quizSelectionLoading = false;
  bool _quizBatchLoading = false;
  List<dynamic> _quizClassOptions = [];
  List<dynamic> _quizBatchOptions = [];
  String _selectedQuizClassId = '';
  String _selectedQuizBatchId = '';
  bool _quizStarted = false;
  bool _quizLoading = false;

  // ── data(): tabs ──
  String _activeTab = 'activity';
  TabContent _activeTabContent = TabContent();
  bool _tabContentLoading = false;

  // ── data(): activity context ──
  String _signedUrl = '';
  Object? _trackingId;
  bool _loadingActivity = false;
  bool _pageLoading = true;
  bool _isFullscreen = false;
  bool _openNotesSidebar = false;
  bool _openActivityPopup = false;

  Object? _chapterId;
  Object? _chapterName;
  Object? _topicId;
  Object? _topicName;
  Object? _classId;
  Object? _batchId;
  Object? _batchName;
  Object? _subjectId;
  Object? _subjectName;
  Object? _activityIdFromRoute;

  Map<String, dynamic>? _selectedActivity;
  Object? _selectedActivityId;
  List<Map<String, dynamic>> _allChapters = [];
  final Map<String, dynamic> _signedUrls = {};
  String _selectedChapterId = '';
  final Map<String, List<dynamic>> _chaptersCache = {};
  Object? _selectedSubjectId;
  Object? _selectedClassId;
  bool _loading = false;
  String? _error;
  List<dynamic> _allactivities = [];

  Timer? _trackingInterval;

  /// Keeps the activity WebView alive when it moves into the fullscreen layer.
  final _activityViewKey = GlobalKey();
  final _popupPortal = OverlayPortalController();
  final _fullscreenPortal = OverlayPortalController();

  /// Read through the container: async handlers keep running after the page
  /// is left (like the web's component methods), when `ref` is unusable.
  late final ProviderContainer _container;

  LibraryController get _ctrl => _container.read(libraryControllerProvider.notifier);
  SessionState get _session => _container.read(sessionProvider);
  AppLanguage get _language => _session.language;

  void _set(VoidCallback fn) {
    fn();
    if (mounted) setState(() {});
  }

  /// Runs an async handler the template fires without awaiting; failures
  /// were unhandled promise rejections (console only) on the web.
  Future<void> _guard(Future<void> Function() fn) async {
    try {
      await fn();
    } catch (e) {
      debugPrint('ActivityLibrary: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _container = ProviderScope.containerOf(context, listen: false);
    final ctx = _ctrl.selectedActivityContext ?? const <String, dynamic>{};
    final selectedClass = _ctrl.selectedClass;
    final batchDetails = _session.batchDetails;

    _chapterId = jsOr([ctx['chapterId'], '']);
    _chapterName = jsOr([ctx['chapterName'], 'Unknown Chapter']);
    _topicId = jsTruthy(ctx['topicId']) ? jsString(ctx['topicId']) : '';
    _topicName = jsOr([ctx['topicName'], 'Unknown Topic']);
    _classId = jsOr([ctx['classId'], '']);
    _batchId = jsOr([ctx['batchId'], ctx['batch_id'], selectedClass?['batch_id'], batchDetails?.id, '']);
    _batchName =
        jsOr([ctx['batchName'], ctx['batch_name'], selectedClass?['batch_name'], batchDetails?.name, '']);
    _subjectId = jsOr([ctx['subjectId'], '']);
    _subjectName = jsOr([ctx['subjectName'], 'Unknown Subject']);
    _activityIdFromRoute = jsOr([ctx['activityId'], '']);
    _selectedChapterId = jsTruthy(ctx['chapterId']) ? jsString(ctx['chapterId']) : '';
    _selectedSubjectId = jsOr([ctx['subjectId'], '']);
    _selectedClassId = jsOr([ctx['classId'], '']);

    // watch: language (deep) — closed automatically on dispose.
    ref.listenManual<AppLanguage>(
      sessionProvider.select((s) => s.language),
      (_, next) => _onLanguageChanged(next),
    );

    Future.microtask(_mounted);
  }

  Future<void> _mounted() async {
    await _guard(_fetchAllChapters);
    if (!mounted) return;
    _trackingInterval = Timer.periodic(const Duration(seconds: 5), (_) {
      if (jsTruthy(_trackingId)) _ctrl.trackActivity(jsString(_trackingId));
    });
  }

  @override
  void dispose() {
    _trackingInterval?.cancel();
    _trackingInterval = null;
    if (_isFullscreen) ExamWindow.exitFullscreen();
    super.dispose();
  }

  // ── computed ──

  Map<String, dynamic>? get _selectedActivityContext => _ctrl.selectedActivityContext;

  Object? get _instituteId => jsOr([_session.userInfo?.instituteId, '']);

  bool get _isInstructorQuizMode => isInstructorQuizRole(_session.userInfo?.role);

  String get _quizSysScannerTitle {
    final label = jsOr([dig(_quizSysSession, ['batch_name']), _batchName, 'Batch']);
    return 'QuizSys Scanner - ${vueText(label)}';
  }

  bool get _quizStartDisabled =>
      _quizLoading ||
      (_isInstructorQuizMode &&
          (_quizSelectionLoading ||
              _quizBatchLoading ||
              _selectedQuizClassId.isEmpty ||
              _selectedQuizBatchId.isEmpty));

  bool get _hasActivities => _allactivities.isNotEmpty && _signedUrl.isNotEmpty;

  List<dynamic> get _filteredChapters {
    if (!jsTruthy(_selectedSubjectId)) return const [];
    return _chaptersCache[jsString(_selectedSubjectId)] ?? const [];
  }

  Map<String, dynamic>? get _selectedChapter {
    for (final raw in _filteredChapters) {
      final c = asMap(raw);
      if (c != null && sameId(c['id'], _selectedChapterId)) return c;
    }
    return null;
  }

  List<dynamic> get _topicsForSelectedChapter => asList(_selectedChapter?['topics']);

  List<String> get _filteredTabs => visibleTabKeys(_session.userInfo?.role);

  String get _pageTitle => _selectedActivity != null
      ? activityTitle(_selectedActivity)
      : 'Topic - ${vueText(_topicName)}';

  // ── watchers ──

  /// `this.selectedActivity = value` + `watch: selectedActivity`.
  void _setSelectedActivity(Map<String, dynamic>? activity) {
    if (identical(activity, _selectedActivity)) return;
    _selectedActivity = activity;
    if (activity != null) {
      _selectedActivityId = activity['id'];
      if (_activeTab != 'quiz' && _activeTab != 'activity') _guard(() => _loadTabContent(_activeTab));
    } else {
      _selectedActivityId = null;
    }
  }

  void _onLanguageChanged(AppLanguage newLang) {
    if (!jsTruthy(newLang.id)) return;
    if (jsTruthy(_chapterId) && jsTruthy(_topicId)) _guard(() => _fetchChapterLinks(newLang.id));
    if (_activeTab != 'quiz' && _activeTab != 'activity') _guard(() => _loadTabContent(_activeTab));
  }

  // ── navigation ──

  void _goBack() {
    final fromRoute = _selectedActivityContext?['fromRoute'];
    if (jsTruthy(fromRoute)) {
      context.go(jsString(fromRoute));
    } else {
      context.go('/library');
    }
  }

  // ── quiz ──

  void _resetQuiz() => _set(() {
        _quizSubmitted = false;
        _quizResult = null;
        _quizStarted = false;
        _quizSysSession = null;
        _quizSysSessionError = '';
      });

  Future<void> _ensureQuizClassOptions() async {
    if (!_isInstructorQuizMode || _quizClassOptions.isNotEmpty || !jsTruthy(_instituteId)) return;

    _set(() {
      _quizSelectionLoading = true;
      _quizSysSessionError = '';
    });
    try {
      final response =
          await _container.read(classServiceProvider).getAllClasses(asInt(_instituteId) ?? _instituteId!);
      final options = normalizeApiList(response);
      final contextClassId = jsString(jsOr([_selectedActivityContext?['classId'], _classId, '']));
      Object? matching;
      for (final c in options) {
        if (jsString(asMap(c)?['id']) == contextClassId) {
          matching = asMap(c)?['id'];
          break;
        }
      }
      _set(() {
        _quizClassOptions = options;
        _selectedQuizClassId = jsString(jsOr([
          matching,
          options.isNotEmpty ? (asMap(options.first)?['id']) : null,
          '',
        ]));
      });
      if (_selectedQuizClassId.isNotEmpty) await _loadQuizBatches();
    } catch (error) {
      debugPrint('Failed to load quiz classes: $error');
      _set(() {
        _quizClassOptions = [];
        _quizBatchOptions = [];
        _selectedQuizClassId = '';
        _selectedQuizBatchId = '';
        _quizSysSessionError = responseMessage(error, 'Failed to load classes.');
      });
    } finally {
      _set(() => _quizSelectionLoading = false);
    }
  }

  Future<void> _loadQuizBatches() async {
    if (_selectedQuizClassId.isEmpty || !jsTruthy(_instituteId)) {
      _set(() {
        _quizBatchOptions = [];
        _selectedQuizBatchId = '';
      });
      return;
    }

    _set(() {
      _quizBatchLoading = true;
      _quizSysSessionError = '';
    });
    try {
      final response = await _container.read(batchServiceProvider).getBatches(
          asInt(_selectedQuizClassId) ?? _selectedQuizClassId, asInt(_instituteId) ?? _instituteId!);
      final options = normalizeApiList(response);
      final contextBatchId = jsString(jsOr([_selectedActivityContext?['batchId'], _batchId, '']));
      Object? matching;
      for (final b in options) {
        if (jsString(asMap(b)?['id']) == contextBatchId) {
          matching = asMap(b)?['id'];
          break;
        }
      }
      _set(() {
        _quizBatchOptions = options;
        _selectedQuizBatchId = jsString(jsOr([
          matching,
          options.isNotEmpty ? (asMap(options.first)?['id']) : null,
          '',
        ]));
      });
    } catch (error) {
      debugPrint('Failed to load quiz batches: $error');
      _set(() {
        _quizBatchOptions = [];
        _selectedQuizBatchId = '';
        _quizSysSessionError = responseMessage(error, 'Failed to load batches.');
      });
    } finally {
      _set(() => _quizBatchLoading = false);
    }
  }

  Future<void> _onQuizClassChange() async {
    _set(() => _selectedQuizBatchId = '');
    await _loadQuizBatches();
  }

  Future<void> _startQuiz() async {
    try {
      if (_isInstructorQuizMode) {
        await _ensureQuizClassOptions();
        if (_selectedQuizClassId.isEmpty || _selectedQuizBatchId.isEmpty) {
          _set(() => _quizSysSessionError = 'Select class and batch before starting the quiz.');
          return;
        }
      }

      _set(() {
        _quizLoading = true;
        _quizStarted = true;
        _quizSysSession = null;
        _quizSysSessionError = '';
      });

      final activityId = jsOr([_selectedActivity?['id'], _selectedActivityId, _activityIdFromRoute]);

      if (!jsTruthy(activityId)) {
        _set(() {
          _quizStarted = false;
          _quizSysSessionError = 'Activity ID is missing for this quiz.';
        });
        debugPrint('Activity ID missing');
        return;
      }

      final res = await _ctrl.getZslQuestions(jsString(activityId));
      final questions = asList(jsOr([dig(res, ['data']), res, const []]));

      if (questions.isEmpty) {
        _set(() {
          _quizStarted = false;
          _quizSysSessionError = 'No quiz questions found for this activity.';
        });
        return;
      }

      _quizExamQuestions = questions;

      if (_isInstructorQuizMode) {
        final setup = await _container.read(studentServiceProvider).setupQuizSysQuizSession({
          'institute_id': _instituteId,
          'class_id': _selectedQuizClassId,
          'batch_id': _selectedQuizBatchId,
          'questions': questions,
        });
        _quizSysSession = jsOr([dig(setup, ['data']), setup]);
      }

      _set(() => _showQuizExam = true);
      _openQuizExam();
    } catch (error) {
      debugPrint('Quiz load failed: $error');
      _set(() {
        _quizStarted = false;
        _quizSysSession = null;
        _quizSysSessionError = responseMessage(error, 'Failed to start QuizSys scanner.');
      });
    } finally {
      _set(() => _quizLoading = false);
    }
  }

  /// `<QuizExam :visible="showQuizExam" …>`.
  void _openQuizExam() {
    if (!mounted || !_showQuizExam) return;
    showQuizExam(
      context,
      questions: _quizExamQuestions,
      quizTitle: _selectedActivity != null ? activityTitle(_selectedActivity) : vueText(_topicName),
      scannerUrl: firstTruthyString([dig(_quizSysSession, ['scanner_url'])]),
      scannerTitle: _quizSysScannerTitle,
      onSubmitted: (payload) => _guard(() => _onQuizSubmitted(payload)),
      onClose: _onQuizClose,
    );
  }

  Future<void> _onQuizSubmitted(Map<String, dynamic> payload) async {
    try {
      final activityId =
          jsString(jsOr([_selectedActivity?['id'], _selectedActivityId, _activityIdFromRoute]));
      final res = await _ctrl.submitZslQuiz(
        activityId: activityId,
        answers: asList(payload['answersPayload']),
      );
      _set(() {
        _quizSubmitted = true;
        _quizResult = res;
        _showQuizExam = false;
      });
    } catch (error) {
      debugPrint('Quiz submission failed: $error');
      _set(() {
        _quizSubmitted = false;
        _quizResult = {'msg': 'Quiz submission failed', 'tickets': 0};
      });
    }
  }

  void _onQuizClose() => _set(() {
        _showQuizExam = false;
        _quizExamQuestions = [];
        _quizStarted = false;
        _quizLoading = false;
        _quizSysSession = null;
        _quizSysSessionError = '';
      });

  // ── tabs ──

  Future<void> _handleTabClick(String tabKey) async {
    _set(() => _activeTab = tabKey);
    if (tabKey == 'quiz') {
      await _ensureQuizClassOptions();
      return;
    }
    if (tabKey == 'activity') return;
    await _loadTabContent(tabKey);
  }

  Future<void> _loadTabContent(String tabKey) async {
    _set(() {
      _tabContentLoading = true;
      _activeTabContent = TabContent();
    });

    try {
      final langId = _language.id;
      var links = const <dynamic>[];
      if (jsTruthy(_instituteId) && jsTruthy(_chapterId)) {
        links = await _ctrl.getZslLinks(_instituteId, _chapterId, langId);
      }

      Map<String, dynamic>? topicLink;
      for (final l in links) {
        if (sameId(asMap(l)?['id'], _topicId)) {
          topicLink = asMap(l);
          break;
        }
      }
      final acts = asList(topicLink?['activities']);
      Map<String, dynamic>? activity;
      for (final a in acts) {
        if (sameId(asMap(a)?['id'], _selectedActivityId)) {
          activity = asMap(a);
          break;
        }
      }
      activity ??= acts.isNotEmpty ? asMap(acts.first) : null;

      if (activity == null) {
        debugPrint('No activity found');
        return;
      }

      if (tabKey == 'why-to-learn') {
        final desc = asMap(activity['description']);
        _set(() => _activeTabContent.text = vueOr([desc?['content'], desc?['text']]));
        if (jsTruthy(desc?['content_path'])) {
          final id = jsOr([desc?['description_id'], desc?['id']]);
          if (jsTruthy(id)) {
            final r = await _ctrl.getWhyToLearnSignedUrl(jsString(id));
            _set(() => _activeTabContent.url = vueOr([dig(r, ['signed_url']), dig(r, ['url'])]));
          }
        }
      } else if (tabKey == 'how-to-play') {
        final autopilot = pickAutopilot(activity['autopilots'], langId);
        if (autopilot != null) {
          final r = await _ctrl.getAutopilotSignedUrl(jsString(autopilot['id']));
          if (_activeTab == tabKey) {
            _set(() => _activeTabContent.url = vueOr([dig(r, ['signed_url']), dig(r, ['url'])]));
          }
        }
      } else if (tabKey == 'reference-video') {
        final videos = asList(activity['reference_video']);
        if (videos.isEmpty) {
          _set(() => _activeTabContent = TabContent());
          return;
        }
        final html = referenceVideosHtml(videos);
        _set(() => _activeTabContent = TabContent(html, ''));
      } else if (tabKey == 'teacher-guide') {
        final items = asList(activity['instructions']);
        final inst = items.isNotEmpty ? asMap(items.first) : null;
        _set(() => _activeTabContent.text = joinTexts(activity!['instructions']));
        if (jsTruthy(inst?['content_path'])) {
          final id = jsOr([inst?['instruction_id'], inst?['id']]);
          if (jsTruthy(id)) {
            final r = await _ctrl.getTeacherGuideSignedUrl(jsString(id));
            _set(() => _activeTabContent.url = vueOr([dig(r, ['signed_url']), dig(r, ['url'])]));
          }
        }
      } else if (tabKey == 'learning-outcome') {
        final items = asList(activity['observations']);
        final obs = items.isNotEmpty ? asMap(items.first) : null;
        _set(() => _activeTabContent.text = joinTexts(activity!['observations']));
        if (jsTruthy(obs?['content_path'])) {
          final id = jsOr([obs?['observation_id'], obs?['id']]);
          if (jsTruthy(id)) {
            final r = await _ctrl.getLearningOutcomeSignedUrl(jsString(id));
            _set(() => _activeTabContent.url = vueOr([dig(r, ['signed_url']), dig(r, ['url'])]));
          }
        }
      }
    } catch (err) {
      debugPrint('Failed to load tab content: $err');
      _set(() => _activeTabContent = TabContent());
    } finally {
      _set(() => _tabContentLoading = false);
    }
  }

  // ── chapters / topics / activities ──

  Future<void> _fetchAllChaptersWithActivities(List<dynamic> chapters) async {
    try {
      final langId = _language.id;
      final results = await Future.wait(
          chapters.map((ch) => _ctrl.getZslLinks(_instituteId, asMap(ch)?['id'], langId)));
      _set(() {
        _allChapters = [
          for (var i = 0; i < chapters.length; i++)
            {
              'id': asMap(chapters[i])?['id'],
              'name': asMap(chapters[i])?['name'],
              'topics': [
                for (final raw in results[i])
                  {
                    'id': asMap(raw)?['id'],
                    'name': asMap(raw)?['name'],
                    'file_path': jsOr([asMap(raw)?['file_path'], '']),
                    'chapter_id': asMap(raw)?['chapter_id'],
                    'activities': jsTruthy(asMap(raw)?['activities']) ? asMap(raw)!['activities'] : const [],
                  },
              ],
            },
        ];
      });
    } catch (err) {
      debugPrint('fetchAllChaptersWithActivities failed: $err');
    }
  }

  Future<void> _fetchAllChapters() async {
    if (!jsTruthy(_instituteId) || !jsTruthy(_selectedClassId) || !jsTruthy(_selectedSubjectId)) return;
    try {
      _set(() => _loading = true);
      final subjectId = _selectedSubjectId!;
      final chapters = await _ctrl.getallchpaters(_instituteId!, _selectedClassId!, subjectId);
      _chaptersCache[jsString(subjectId)] = chapters;
      _fetchAllChaptersWithActivities(chapters);
      if (chapters.isNotEmpty) {
        if (jsTruthy(_chapterId)) {
          final match = chapters.any((ch) => jsString(asMap(ch)?['id']) == jsString(_chapterId));
          _selectedChapterId = jsString(match ? _chapterId : asMap(chapters.first)?['id']);
        } else {
          _selectedChapterId = jsString(asMap(chapters.first)?['id']);
        }
        await _handleChapterChange();
      }
    } catch (error) {
      debugPrint('Error fetching chapters: $error');
      _set(() => _error = 'Failed to load chapters');
    } finally {
      _set(() => _loading = false);
    }
  }

  Future<void> _fetchChapterLinks([Object? languageId]) async {
    if (!jsTruthy(_instituteId) || !jsTruthy(_chapterId)) return;
    _set(() => _pageLoading = true);
    final langId = languageId ?? _language.id;
    try {
      final links = await _ctrl.getZslLinks(_instituteId, _chapterId, langId);
      Map<String, dynamic>? topicLink;
      for (final l in links) {
        if (jsString(asMap(l)?['id']) == jsString(_topicId)) {
          topicLink = asMap(l);
          break;
        }
      }
      final acts = asList(topicLink?['activities']);
      if (topicLink == null || acts.isEmpty) {
        _set(() {
          _allactivities = [];
          _setSelectedActivity(null);
          _selectedActivityId = null;
          _signedUrl = '';
        });
        return;
      }
      _set(() => _allactivities = acts);

      if (jsTruthy(_activityIdFromRoute)) {
        Map<String, dynamic>? forced;
        for (final a in acts) {
          if (jsString(asMap(a)?['id']) == jsString(_activityIdFromRoute)) {
            forced = asMap(a);
            break;
          }
        }
        if (forced != null) {
          _set(() {
            _setSelectedActivity(forced);
            _selectedActivityId = forced!['id'];
          });
          await _generateActivitySignedUrl(forced);
          _set(() => _activeTab = 'activity');
          return;
        }
      }

      final first = asMap(acts.first);
      _set(() {
        _setSelectedActivity(first);
        _selectedActivityId = first?['id'];
      });
      await _generateActivitySignedUrl(_selectedActivity);
      _set(() => _activeTab = 'activity');
    } catch (err) {
      debugPrint('Activity load failed $err');
      _set(() {
        _allactivities = [];
        _setSelectedActivity(null);
        _selectedActivityId = null;
        _signedUrl = '';
      });
    } finally {
      _set(() => _pageLoading = false);
    }
  }

  /// Drawer chapter select.
  void _onChapterChange(String? newVal) {
    if (!jsTruthy(newVal)) return;
    _set(() {
      _selectedChapterId = newVal!;
      _topicId = '';
    });
    _guard(_handleChapterChange);
  }

  Future<dynamic> _generateActivitySignedUrl(Map<String, dynamic>? activity, [String? dataType]) async {
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
      final cacheKey = '${vueText(activityId)}_${dataType ?? 'default'}';
      dynamic signed;
      if (_signedUrls.containsKey(cacheKey)) {
        signed = _signedUrls[cacheKey];
      } else {
        signed = await _ctrl.generateSignedUrl(
            _instituteId!, _subjectId!, _chapterId!, _topicId!, activityId);
        _signedUrls[cacheKey] = signed;
        // `signedUrl.tracking_id` on `undefined` threw on the web.
        if (signed == null) throw StateError('No signed URL for activity $activityId');
        final tid = dig(signed, ['tracking_id']);
        if (jsTruthy(tid)) _trackingId = tid;
      }
      if (signed == null) throw StateError('No signed URL for activity $activityId');
      final url = dig(signed, ['url']);
      _set(() => _signedUrl = url == null ? '' : jsString(url));
      try {
        activity['signed_url'] = url;
      } catch (_) {}
      return signed;
    } catch (error) {
      debugPrint('Error generating signed URL: $error');
      rethrow;
    } finally {
      _set(() => _loadingActivity = false);
    }
  }

  Future<void> _onActivityChange() async {
    if (!jsTruthy(_selectedActivityId)) return;
    Map<String, dynamic>? activity;
    for (final a in _allactivities) {
      if (jsString(asMap(a)?['id']) == jsString(_selectedActivityId)) {
        activity = asMap(a);
        break;
      }
    }
    if (activity == null) return;
    _set(() => _setSelectedActivity(activity));
    _ctrl.setActivityContext({...?_ctrl.selectedActivityContext, 'activityId': activity['id']});
    await _generateActivitySignedUrl(activity);
    _set(() => _activeTab = 'activity');
  }

  /// `toggleFullscreen()` — the activity panel fills the screen (desktop
  /// window fullscreen / immersive mode on phones).
  void _toggleFullscreen() {
    if (_isFullscreen) {
      _set(() {
        _isFullscreen = false;
        _fullscreenPortal.hide();
      });
      ExamWindow.exitFullscreen();
    } else {
      _set(() {
        _isFullscreen = true;
        _fullscreenPortal.show();
      });
      ExamWindow.enterFullscreen();
    }
  }

  Future<void> _handleChapterChange() async {
    final selectedChapter = _selectedChapter;
    if (selectedChapter == null) return;
    final isChapterChanging = jsString(_chapterId) != jsString(selectedChapter['id']);
    _set(() {
      _selectedChapterId = jsString(selectedChapter['id']);
      _chapterId = selectedChapter['id'];
      _chapterName = selectedChapter['name'];
    });
    final ctx = _ctrl.selectedActivityContext;
    _ctrl.setActivityContext({
      ...?ctx,
      'chapterId': selectedChapter['id'],
      'chapterName': selectedChapter['name'],
      'activityId': isChapterChanging ? null : ctx?['activityId'],
    });
    final topics = asList(selectedChapter['topics']);
    if (topics.isNotEmpty) {
      final inNewChapter = topics.any((t) => sameId(asMap(t)?['id'], _topicId));
      if (!jsTruthy(_topicId) || !inNewChapter) {
        await _handleTopicClick(asMap(topics.first));
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

  Future<void> _handleTopicClick(Map<String, dynamic>? topic) async {
    if (topic == null) return;
    final isTopicChanging = jsString(_topicId) != jsString(topic['id']);
    _set(() {
      _topicId = topic['id'];
      _topicName = topic['name'];
      _setSelectedActivity(null);
      _selectedActivityId = null;
      _signedUrl = '';
      _allactivities = [];
    });
    final ctx = _ctrl.selectedActivityContext;
    _ctrl.setActivityContext({
      ...?ctx,
      'topicId': topic['id'],
      'topicName': topic['name'],
      'topicImage': jsOr([topic['file_path'], '']),
      'activityId': isTopicChanging ? null : ctx?['activityId'],
    });
    await _fetchChapterLinks();
  }

  Future<void> _handleActivityFromPopup(Map<String, dynamic> topic, Map<String, dynamic> activity) async {
    _set(() {
      _topicId = jsString(topic['id']);
      _topicName = topic['name'];
      _activityIdFromRoute = jsString(activity['id']);
    });
    Map<String, dynamic>? parentChapter;
    for (final ch in _allChapters) {
      if (asList(ch['topics']).any((t) => sameId(asMap(t)?['id'], topic['id']))) {
        parentChapter = ch;
        break;
      }
    }
    final pc = parentChapter;
    if (pc != null && !sameId(pc['id'], _chapterId)) {
      _set(() {
        _chapterId = pc['id'];
        _chapterName = pc['name'];
        _selectedChapterId = jsString(pc['id']);
      });
    }
    _ctrl.setActivityContext({
      ...?_ctrl.selectedActivityContext,
      'chapterId': _chapterId,
      'chapterName': _chapterName,
      'topicId': topic['id'],
      'topicName': topic['name'],
      'topicImage': jsOr([topic['file_path'], '']),
      'activityId': activity['id'],
    });
    _set(() {
      _openActivityPopup = false;
      _popupPortal.hide();
      _allactivities = [];
      _setSelectedActivity(null);
      _selectedActivityId = null;
      _signedUrl = '';
    });
    await _fetchChapterLinks();
  }

  void _setPopup(bool open) => _set(() {
        _openActivityPopup = open;
        if (open) {
          _popupPortal.show();
        } else {
          _popupPortal.hide();
        }
      });

  // ── template ──

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final md = context.isMd;
    final size = MediaQuery.sizeOf(context);

    final page = SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: sm ? 16 : 8, vertical: sm ? 24 : 16),
      child: Container(
        decoration: libGlassContainer(context),
        padding: EdgeInsets.all(md ? 24 : (sm ? 20 : 16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          _topNav(context),
          const SizedBox(height: 16),
          _mainContent(context),
        ]),
      ),
    );

    return PopScope(
      canPop: !_isFullscreen && !_openActivityPopup && !_openNotesSidebar,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_isFullscreen) {
          _toggleFullscreen();
        } else if (_openActivityPopup) {
          _setPopup(false);
        } else if (_openNotesSidebar) {
          _set(() => _openNotesSidebar = false);
        }
      },
      child: LoadingOverlay(
        loading: _pageLoading,
        child: DefaultTextStyle.merge(
          style: GoogleFonts.nunito(),
          child: Stack(children: [
            Positioned.fill(child: ColoredBox(color: dark ? AppColors.dashboardDark : Colors.transparent)),
            // Ambient glow blobs
            Positioned(
              top: size.height * 0.25 - size.width * 0.15,
              left: size.width / 3 - size.width * 0.15,
              child: GlowBlob(
                  size: size.width * 0.6,
                  color: dark ? Tw.indigo500.withValues(alpha: 0.15) : Tw.indigo400.withValues(alpha: 0.1)),
            ),
            Positioned(
              bottom: size.height / 3 - size.width * 0.125,
              right: size.width / 4 - size.width * 0.125,
              child: GlowBlob(
                  size: size.width * 0.5,
                  color: dark ? Tw.purple500.withValues(alpha: 0.1) : Tw.violet400.withValues(alpha: 0.1)),
            ),
            Positioned.fill(child: page),
            // ===== OVERLAY =====
            if (_openNotesSidebar)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => _set(() => _openNotesSidebar = false),
                  child: const ColoredBox(color: Color(0x66000000)),
                ),
              ),
            // ===== RIGHT SIDEBAR =====
            _sidebar(context),
            OverlayPortal(
              controller: _popupPortal,
              overlayChildBuilder: _allActivitiesPopup,
              child: const SizedBox.shrink(),
            ),
            OverlayPortal(
              controller: _fullscreenPortal,
              overlayChildBuilder: _fullscreenLayer,
              child: const SizedBox.shrink(),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _fullscreenLayer(BuildContext context) => Positioned.fill(
        child: CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.escape): () {
              if (_isFullscreen) _toggleFullscreen();
            },
          },
          child: Focus(
            autofocus: true,
            child: Material(
              color: Colors.black,
              child: SafeArea(child: _panelBody(context, fill: true)),
            ),
          ),
        ),
      );
}
