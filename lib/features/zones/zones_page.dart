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
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../widgets/app_loader.dart';
import '../mathzoro/mz_ui.dart' show CssLinearGradient;
import '../quiz/quiz_exam.dart';
import 'zone_widgets.dart';
import '../offline/offline_runtime.dart';
import 'zones_controller.dart';
import 'zones_logic.dart';

part 'zone_header.dart';
part 'zone_roadmap.dart';
part 'zone_board.dart';
part 'zone_dialogs.dart';

/// Port of `src/pages/library/elabsmathzone.vue` (`/elabsmathzone`, eLabs
/// sidebar "Math Zone").
class ElabsMathZonePage extends StatelessWidget {
  const ElabsMathZonePage({super.key});

  @override
  Widget build(BuildContext context) => const _ZonePage(kind: ZoneKind.math);
}

/// Port of `src/pages/library/elabssciencezone.vue` (`/elabssciencezone`,
/// eLabs sidebar "Science Zone").
class ElabsScienceZonePage extends StatelessWidget {
  const ElabsScienceZonePage({super.key});

  @override
  Widget build(BuildContext context) => const _ZonePage(kind: ZoneKind.science);
}

/// The two Vue pages are the same component with a handful of differences
/// (texts/colours in [ZoneStyle]; subject pick and loading flow in the
/// `_isMath` branches below).
class _ZonePage extends ConsumerStatefulWidget {
  const _ZonePage({required this.kind});
  final ZoneKind kind;

  @override
  ConsumerState<_ZonePage> createState() => _ZonePageState();
}

class _ZonePageState extends ConsumerState<_ZonePage> {
  // ── data() ──
  bool _isGrid = true;
  bool _loading = false;
  bool _sheetLoading = false;

  List<Json> _allClasses = [];
  dynamic _selectedClassId;
  String _selectedClassName = '';
  dynamic _selectedSubjectId;

  /// `selectedSyllabus` — never set by the page (always null).
  static const Object? _selectedSyllabus = null;

  final Map<String, List<Json>> _activitiesCache = {};
  List<dynamic> _allActivitiesData = [];

  List<Json> _chapters = [];
  late int _selectedChapterIndex = _isMath ? -1 : 0;
  Json? _activeChapter;
  List<Json> _currentChapterActivities = [];

  bool _classOpen = false;
  dynamic _subjectPerformance;

  /// `quizActivity` (the questions / title / `showQuiz` flag are passed
  /// straight to [showQuizExam]).
  Json? _quizActivity;

  final _roadmapScroll = ScrollController();
  final _classDropdown = OverlayPortalController();
  final _classDropdownLink = LayerLink();

  bool get _isMath => widget.kind == ZoneKind.math;
  ZoneStyle get _style => ZoneStyle.of(widget.kind);
  ZonesController get _ctrl => ref.read(zonesControllerProvider.notifier);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _initializeFilters();
    });
  }

  @override
  void dispose() {
    _roadmapScroll.dispose();
    super.dispose();
  }

  /// `setState` for the part-file extensions (setState is protected).
  void _update(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  // ── computed ─────────────────────────────────────────────────────────────

  /// `userInfo?.institute_id || userInfo?.instituteId || ''`.
  Object get _instituteId {
    final id = ref.read(sessionProvider).userInfo?.instituteId;
    return jsTruthy(id) ? id! : '';
  }

  dynamic _perfSource;
  Map<String, Json> _perfMap = const {};

  /// `chapterPerformanceMap` (recomputed when `subjectPerformance` changes).
  Map<String, Json> get _chapterPerformanceMap {
    if (!identical(_perfSource, _subjectPerformance)) {
      _perfSource = _subjectPerformance;
      _perfMap = chapterPerformanceMap(_subjectPerformance);
    }
    return _perfMap;
  }

  int get _totalActivityCount => totalActivityCount(_allActivitiesData);

  double get _chapterProgress {
    final active = _activeChapter;
    if (active == null) return 0;
    return chapterPct(_chapterPerformanceMap[numKey(active['id'])]);
  }

  Json? _getChapterPerfByIndex(int i) {
    if (i < 0 || i >= _chapters.length) return null;
    return _chapterPerformanceMap[numKey(_chapters[i]['id'])];
  }

  double _getChapterPctByIndex(int i) => chapterPct(_getChapterPerfByIndex(i));

  Json? _getActivityPerf(Json activity) {
    final active = _activeChapter;
    if (active == null) return null;
    final chPerf = _chapterPerformanceMap[numKey(active['id'])];
    return asMap(asMap(chPerf?['activityMap'])?[numKey(activity['id'])]);
  }

  double _getActivityStars(Json activity) =>
      ticketsToStars(_getActivityPerf(activity)?['earned_tickets'] ?? 0);

  Color _currentStarColor(double filled) =>
      starColor(filled, science: !_isMath);

  /// `flagColor(i)`.
  ({Color fill, Color stroke}) _flagColor(int i, ColorScheme colors) {
    if (_selectedChapterIndex == i)
      return (fill: colors.primary, stroke: colors.secondary);
    if (i < _selectedChapterIndex)
      return (fill: colors.secondary, stroke: colors.primary);
    return (fill: const Color(0xFF94A3B8), stroke: const Color(0xFF475569));
  }

  static List<Json> _maps(dynamic v) => [for (final e in asList(v)) ?asMap(e)];

  // ── performance ──────────────────────────────────────────────────────────

  Future<void> _refreshPerformance() async {
    if (!jsTruthy(_selectedSubjectId) || !jsTruthy(_selectedClassId)) return;
    try {
      final perf = await _ctrl.getSubjectPerformance(
        _selectedSubjectId,
        _selectedClassId,
      );
      _update(() => _subjectPerformance = dataOr(perf, null));
    } catch (e) {
      debugPrint('Performance refresh failed: $e');
    }
  }

  // ── quiz ─────────────────────────────────────────────────────────────────

  /// `goToQuiz(activity)` → start-quiz confirmation modal.
  void _goToQuiz(Json activity) => _openStartQuizConfirm(activity);

  /// `confirmStartQuiz()` (the modal has already closed itself).
  Future<void> _confirmStartQuiz(Json? activity) async {
    if (activity != null) await _startQuiz(activity);
  }

  static String _activityLabel(Json activity) => jsTruthy(activity['name'])
      ? jsStr(activity['name'])!
      : (jsTruthy(activity['topic_name'])
            ? jsStr(activity['topic_name'])!
            : '');

  Future<void> _startQuiz(Json activity) async {
    if (ref.read(offlineBrowsingProvider)) {
      _goToActivity({...activity, 'offlineQuiz': true});
      return;
    }
    List<dynamic> questions;
    try {
      final response = await _ctrl.getZslQuestions(
        jsStr(activity['id']) ?? 'undefined',
      );
      final q = dataOr(response, const []);
      if (q is! List || q.isEmpty) {
        _openNoQuestions(_activityLabel(activity));
        return;
      }
      questions = q;
      _quizActivity = activity;
    } catch (e) {
      debugPrint('$e');
      _openNoQuestions(_activityLabel(activity));
      return;
    }
    if (!mounted) return;
    // `showQuiz = true`
    await showQuizExam(
      context,
      questions: questions,
      quizTitle: jsTruthy(activity['name']) ? jsStr(activity['name'])! : '',
      onSubmitted: _onQuizSubmitted,
      onClose: _onQuizClose,
    );
  }

  Future<void> _onQuizSubmitted(Map<String, dynamic> payload) async {
    final activity = _quizActivity;
    try {
      final answers = [
        for (final a in asList(payload['answersPayload']))
          if (asMap(a) case final m?)
            {
              'question_id': jsStr(m['question_id']) ?? 'undefined',
              'option_id': jsStr(m['option_id']) ?? 'undefined',
            },
      ];
      await _ctrl.submitZslQuiz(
        activityId: jsTruthy(activity?['id']) ? jsStr(activity!['id']) : null,
        classesId: jsTruthy(_selectedClassId) ? jsStr(_selectedClassId) : null,
        answers: answers,
      );
      await _refreshPerformance();
    } catch (e) {
      debugPrint('SUBMIT ERROR $e');
    }
  }

  void _onQuizClose() => _quizActivity = null;

  // ── scroll ───────────────────────────────────────────────────────────────

  /// `scrollPathRight()` — `scrollBy({ left: 300, behavior: 'smooth' })`.
  void _scrollPathRight() {
    if (!_roadmapScroll.hasClients) return;
    final pos = _roadmapScroll.position;
    final target = (pos.pixels + 300).clamp(
      pos.minScrollExtent,
      pos.maxScrollExtent,
    );
    _roadmapScroll.animateTo(
      target,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  // ── data fetching ────────────────────────────────────────────────────────

  Future<void> _initializeFilters() async {
    // Keep selected chapter state active when navigating back from activitylibrary
    await _fetchAllClasses();
  }

  Future<void> _fetchAllClasses() async {
    _update(() => _loading = true);
    try {
      if (!jsTruthy(_instituteId)) {
        debugPrint('No institute ID found. Please log in again.');
        return;
      }
      final data = await _ctrl.getClass(_instituteId, _selectedSyllabus);
      if (!mounted) return;
      final list = jsTruthy(data) ? data : const [];
      // `[...this.allClassesData]` throws for a non-iterable response.
      if (list is! List) throw StateError('allClassesData is not iterable');
      _update(
        () => _allClasses = [
          for (final c in list) asMap(c) ?? <String, dynamic>{},
        ],
      );

      if (_allClasses.isNotEmpty) {
        final persisted = _ctrl.persistedClassId;
        final persistedKey = jsStr(persisted) ?? 'null';
        final exists = _allClasses.any(
          (c) => (jsStr(c['id']) ?? 'undefined') == persistedKey,
        );
        final selectedId = exists ? persisted : _allClasses.first['id'];
        // `find(c => c.id === this.selectedClassId)` — strict equality.
        final cls = _allClasses.where((c) => c['id'] == selectedId).firstOrNull;
        _update(() {
          _selectedClassId = selectedId;
          _selectedClassName = jsTruthy(cls?['name'])
              ? jsStr(cls!['name'])!
              : '';
        });
        _ctrl.persistedClassId = selectedId;
        await _onClassChange();
      }
    } catch (e) {
      debugPrint('Failed to load classes: $e');
    } finally {
      _update(() => _loading = false);
    }
  }

  Future<void> _selectClass(dynamic classId) async {
    final cls = _allClasses.where((c) => c['id'] == classId).firstOrNull;
    _update(() {
      _classOpen = false; // the panel leaves with its transition
      _selectedClassId = classId;
      _selectedClassName = jsTruthy(cls?['name']) ? jsStr(cls!['name'])! : '';
      _selectedSubjectId = null;
      _chapters = [];
      _activeChapter = null;
      _currentChapterActivities = [];
      _allActivitiesData = [];
    });
    // Clear persisted chapter on class change to default to the first chapter of the new class
    _ctrl.setPersistedChapterId(_style.persistedChapterKey, null);
    await _onClassChange();
  }

  Future<void> _onClassChange() async {
    if (jsTruthy(_selectedClassId)) _ctrl.persistedClassId = _selectedClassId;
    _update(() {
      _selectedSubjectId = null;
      _activeChapter = null;
      _currentChapterActivities = [];
    });

    try {
      if (!jsTruthy(_selectedClassId) || !jsTruthy(_instituteId)) return;
      _update(() => _loading = true);

      final subjects = asList(
        await _ctrl.getAllSubjects(_instituteId, _selectedClassId),
      );
      if (!mounted || subjects.isEmpty) return;

      if (_isMath) {
        final mathZone = subjects
            .where((s) => asMap(s)?['zone'] == 'MATH_ZONE')
            .firstOrNull;
        final subjectId = mathZone != null
            ? asMap(mathZone)!['id']
            : asMap(subjects.first)?['id'];
        _update(() => _selectedSubjectId = subjectId);
      } else {
        final scienceSubject = subjects
            .where((s) => asMap(s)?['zone'] == 'SCIENCE_ZONE')
            .firstOrNull;
        if (scienceSubject == null) {
          debugPrint('No SCIENCE_ZONE subject found');
          return;
        }
        _update(() => _selectedSubjectId = asMap(scienceSubject)!['id']);
      }

      await _onSubjectChange();
    } catch (e) {
      debugPrint('Error fetching subjects: $e');
    } finally {
      // loading = false here, AFTER onSubjectChange fully completes
      _update(() => _loading = false);

      // Math Zone: wait for the canvas to paint, then re-confirm the selection.
      if (_isMath &&
          mounted &&
          _chapters.isNotEmpty &&
          _activeChapter != null) {
        final idx = _chapters.indexWhere(
          (ch) => ch['id'] == _activeChapter!['id'],
        );
        if (idx >= 0) _update(() => _selectedChapterIndex = idx);
      }
    }
  }

  Future<void> _onSubjectChange() async {
    if (!jsTruthy(_selectedSubjectId) ||
        !jsTruthy(_instituteId) ||
        !jsTruthy(_selectedClassId)) {
      return;
    }
    try {
      if (_isMath) {
        // Reset cleanly
        _update(() {
          _chapters = [];
          _selectedChapterIndex = -1;
          _activeChapter = null;
          _currentChapterActivities = [];
        });
      } else {
        _update(() => _loading = true);
      }

      final chapters = await _ctrl.getallchpaters(
        _instituteId,
        _selectedClassId,
        _selectedSubjectId as Object,
      );
      if (!mounted) return;
      _update(() => _chapters = _maps(chapters));

      try {
        final perf = await _ctrl.getSubjectPerformance(
          _selectedSubjectId,
          _selectedClassId,
        );
        _update(() => _subjectPerformance = perf);
      } catch (e) {
        debugPrint('Error fetching subject performance: $e');
      }
      if (!mounted) return;

      if (_chapters.isNotEmpty) {
        final saved = _ctrl.persistedChapterId(_style.persistedChapterKey);
        final targetIdx = persistedChapterIndex(_chapters, saved);
        _update(() {
          _selectedChapterIndex = targetIdx;
          _activeChapter = _chapters[targetIdx];
        });

        if (_isMath) {
          // load activities in background — don't block
          unawaited(_loadChapterActivities(_activeChapter!['id']));
          unawaited(_fetchAllActivities());
        } else {
          await _loadChapterActivities(_activeChapter!['id']);
          await _fetchAllActivities();
        }
      }
    } catch (e) {
      debugPrint('Error fetching chapters: $e');
    } finally {
      // Math Zone: no loading flag here — onClassChange owns it.
      if (!_isMath) _update(() => _loading = false);
    }
  }

  Future<void> _selectChapter(Json? chapter, int index) async {
    if (chapter == null) return;
    _update(() {
      _selectedChapterIndex = index;
      _activeChapter = chapter;
    });
    _ctrl.setPersistedChapterId(
      _style.persistedChapterKey,
      jsStr(chapter['id']) ?? 'undefined',
    );
    await _loadChapterActivities(chapter['id']);
  }

  Future<void> _loadChapterActivities(dynamic chapterId) async {
    final key = jsStr(chapterId) ?? 'undefined';
    final cached = _activitiesCache[key];
    if (cached != null) {
      _update(() => _currentChapterActivities = cached);
      return;
    }
    _update(() {
      _sheetLoading = true;
      _currentChapterActivities = [];
    });
    try {
      final topics = await _ctrl.getZslLinks(_instituteId, chapterId);
      final acts = flattenTopics(topics, chapterId);
      _activitiesCache[key] = acts;
      _update(() => _currentChapterActivities = acts);
    } catch (e) {
      debugPrint('$e');
      _update(() => _currentChapterActivities = []);
    } finally {
      _update(() => _sheetLoading = false);
    }
  }

  Future<void> _fetchAllActivities() async {
    try {
      if (!jsTruthy(_instituteId) || _chapters.isEmpty) return;
      final responses = await Future.wait(
        _chapters.map((ch) => _ctrl.getZslLinks(_instituteId, ch['id'])),
      );
      _update(() => _allActivitiesData = flatOne(responses));
    } catch (e) {
      debugPrint('fetchAllActivities failed: $e');
    }
  }

  /// `goToActivity(activity)` — stores the activity context and opens
  /// `/activitylibrary`.
  void _goToActivity(Json activity) {
    final chapterId = jsTruthy(activity['chapter_id'])
        ? activity['chapter_id']
        : _activeChapter?['id'];
    final wanted = jsStr(chapterId) ?? 'undefined';
    final chapter = _chapters
        .where((ch) => (jsStr(ch['id']) ?? 'undefined') == wanted)
        .firstOrNull;
    _ctrl.setActivityContext({
      'chapterId': chapterId,
      'chapterName': jsTruthy(chapter?['name']) ? chapter!['name'] : '',
      'topicId': jsTruthy(activity['topic_id']) ? activity['topic_id'] : '',
      'topicName': jsTruthy(activity['topic_name'])
          ? activity['topic_name']
          : '',
      'topicImage': jsTruthy(activity['file_path'])
          ? activity['file_path']
          : '',
      'activityId': activity['id'],
      'offlineQuiz': activity['offlineQuiz'] == true,
      'classId': _selectedClassId,
      'className': _selectedClassName,
      'subjectId': _selectedSubjectId,
      'subjectName': '',
      'syllabus': _selectedSyllabus ?? '',
      'instituteId': _instituteId,
      'allChaptersData': <dynamic>[],
      'fromRoute': _style.route,
    });
    context.go('/activitylibrary');
  }

  // ── template ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final isStudent = session.role == Role.student;
    final dark = context.isDark;
    final sm = context.isSm;
    final md = context.isMd;
    final glow = dark ? context.colors.primary : context.colors.secondary;

    final card = Container(
      padding: EdgeInsets.all(md ? 24 : (sm ? 20 : 16)),
      decoration: BoxDecoration(
        color: dark
            ? Tw.slate900.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          width: 2,
          color: dark
              ? Tw.slate800.withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.4),
        ),
        // shadow-[0_20px_50px_-12px_rgba(99,102,241,0.15)]
        boxShadow: [
          cssShadow(0, 20, 50, -12, const Color.fromRGBO(99, 102, 241, 0.15)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildBanner(),
          const SizedBox(height: 24 + 16),
          _buildClassRow(isStudent),
          const SizedBox(height: 24 + 16),
          _buildRoadmap(isStudent),
          const SizedBox(height: 24 + 16),
          _buildBoard(isStudent),
          const SizedBox(height: 16),
        ],
      ),
    );

    return LoadingOverlay(
      loading: _loading,
      child: ColoredBox(
        color: dark ? AppColors.dashboardDark : Colors.transparent,
        child: Stack(
          children: [
            // Ambient glow blobs (`fixed inset-0 overflow-hidden`, behind the
            // content).
            Positioned.fill(
              child: IgnorePointer(
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      top: -200,
                      right: -100,
                      child: GlowBlob(
                        color: glow,
                        opacity: 0.2,
                        diameter: 600,
                        blur: 120,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: -100,
                      child: GlowBlob(
                        color: glow,
                        opacity: 0.1,
                        diameter: 400,
                        blur: 100,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: sm ? 16 : 8,
                vertical: sm ? 24 : 16,
              ),
              child: card,
            ),
          ],
        ),
      ),
    );
  }
}
