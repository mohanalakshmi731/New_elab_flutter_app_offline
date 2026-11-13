import 'dart:math' as math;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart' show AppSelectItem;
import '../../widgets/web_content_view.dart';
import '../mathzoro/mz_ui.dart' show CssLinearGradient;
import 'library_controller.dart';
import 'library_logic.dart';
import 'library_widgets.dart';

part 'library_page_views.dart';

/// Port of `src/pages/library/library.vue` (component `ViewToggle`,
/// route `/library`, "Activity Library").
///
/// Class → subject → chapter filters over the ZSL catalogue; topics (or every
/// activity of the subject with "Show all Activities") in a grid or a list,
/// plus the chapter reference. Opening a topic / activity stores
/// `selectedActivityContext` and goes to `/activitylibrary`.
class LibraryPage extends ConsumerStatefulWidget {
  const LibraryPage({super.key});

  @override
  ConsumerState<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends ConsumerState<LibraryPage> {
  // ── data() ──
  bool _showAllActivitiesInline = false;
  bool _isGrid = true;
  bool _loading = false;
  String? _error;
  Object? _selectedClassId;
  Object? _selectedSubjectId;
  Object? _selectedChapterId;
  List<Map<String, dynamic>> _allClasses = [];
  Object? _instituteId;
  Object? _selectedSyllabus;
  List<dynamic> _allClassesData = [];

  /// `chaptersCache[subjectId]` (JS object → string keys).
  final Map<String, List<dynamic>> _chaptersCache = {};
  List<dynamic> _allActivitiesData = [];

  // Chapter reference
  String? _chapterReferenceUrl;
  String? _chapterReferenceContent;
  bool _referenceLoading = false;
  bool _referenceExpanded = true;

  /// Read through the container: async handlers keep running after the page
  /// is left (like the web's component methods), when `ref` is unusable.
  late final ProviderContainer _container;

  LibraryController get _ctrl => _container.read(libraryControllerProvider.notifier);

  /// Applies [fn] and rebuilds if still mounted (async actions keep running
  /// after the page is left, like the web's component methods).
  void _set(VoidCallback fn) {
    fn();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _container = ProviderScope.containerOf(context, listen: false);
    Future.microtask(_initializeFilters);
  }

  // ── computed ──

  Map<String, dynamic> get _selectedClass =>
      _allClasses.firstWhere((c) => c['id'] == _selectedClassId, orElse: () => <String, dynamic>{});

  Object? get _selectedBatchId {
    final c = _selectedClass;
    return jsOr([
      c['batch_id'],
      dig(c, ['batch', 'id']),
      dig(c, ['active_batch', 'id']),
      dig(c, ['batches', 0, 'id']),
      null,
    ]);
  }

  Object? get _selectedBatchName {
    final c = _selectedClass;
    return jsOr([
      c['batch_name'],
      dig(c, ['batch', 'name']),
      dig(c, ['active_batch', 'name']),
      dig(c, ['batches', 0, 'name']),
      null,
    ]);
  }

  List<dynamic> get _filteredSubjects => asList(_selectedClass['subjects']);

  List<dynamic> get _filteredChapters {
    if (!jsTruthy(_selectedSubjectId)) return const [];
    return _chaptersCache[jsString(_selectedSubjectId)] ?? const [];
  }

  Map<String, dynamic> get _selectedChapter {
    for (final raw in _filteredChapters) {
      final c = asMap(raw);
      if (c != null && c['id'] == _selectedChapterId) return c;
    }
    return const {};
  }

  List<Map<String, dynamic>> get _filteredTopics =>
      topicsForChapter(_allActivitiesData, _selectedChapterId);

  // ── methods ──

  Object? _getInstituteId() => _container.read(sessionProvider).userInfo?.instituteId;

  void _initializeFilters() {
    _instituteId = _getInstituteId();
    // `syllabusOptions` / `onSyllabusChange` have no control in the template.
    // The web's `instituteId` watcher fetched the classes a second time here.
    _fetchAllClasses();
  }

  Future<void> _loadChapterReference(Map<String, dynamic>? chapter) async {
    _set(() {
      _chapterReferenceUrl = null;
      _chapterReferenceContent = null;
    });
    if (chapter == null || !jsTruthy(chapter['id'])) return;

    // CASE 1: HTML text content is present → render inline
    if (chapter['chapter_reference_text'] != null) {
      _set(() {
        _chapterReferenceContent = jsString(chapter['chapter_reference_text']);
        _referenceExpanded = true;
      });
      return;
    }

    // CASE 2: no HTML text, but a reference URL path exists → signed link
    if (!jsTruthy(chapter['chapter_reference_url'])) return;
    try {
      _set(() => _referenceLoading = true);
      final res = await _ctrl.getChapterReferenceSignedLink(jsString(chapter['id']));
      final url = dig(res, ['url']);
      if (jsTruthy(url)) {
        _set(() {
          _chapterReferenceUrl = jsString(url);
          _referenceExpanded = true;
        });
      }
    } catch (err) {
      debugPrint('Failed to load chapter reference signed link: $err');
    } finally {
      _set(() => _referenceLoading = false);
    }
  }

  Future<void> _onChapterChange() async {
    _ctrl.persistedChapterId = _selectedChapterId;

    if (_selectedChapterId == 'all-activities') {
      _set(() {
        _chapterReferenceUrl = null;
        _chapterReferenceContent = null;
        _loading = true;
      });
      try {
        await _fetchAllActivities();
        _set(() => _showAllActivitiesInline = true);
      } finally {
        _set(() => _loading = false);
      }
      return;
    }

    _set(() => _showAllActivitiesInline = false);
    Map<String, dynamic>? chapter;
    for (final raw in _filteredChapters) {
      final c = asMap(raw);
      if (c != null && sameId(c['id'], _selectedChapterId)) {
        chapter = c;
        break;
      }
    }
    if (chapter != null) await _loadChapterReference(chapter);
  }

  void _goToPopupActivity(Map<String, dynamic> activity) {
    Map<String, dynamic>? parentTopic;
    for (final raw in _allActivitiesData) {
      final t = asMap(raw);
      if (t != null && asList(t['activities']).any((a) => sameId(asMap(a)?['id'], activity['id']))) {
        parentTopic = t;
        break;
      }
    }

    final chapterId = jsOr([
      parentTopic?['chapter_id'],
      activity['chapter_id'],
      activity['zsl_chapter_id'],
      _selectedChapterId,
    ]);
    final topicId = jsOr([parentTopic?['id'], activity['topic_id'], activity['zsl_topic_id'], '']);
    final topicName = jsOr([parentTopic?['name'], activity['topic_name'], '']);
    final topicImage = jsOr([parentTopic?['file_path'], activity['file_path'], '']);

    Object? chapterName;
    for (final raw in _filteredChapters) {
      final c = asMap(raw);
      if (c != null && sameId(c['id'], chapterId)) {
        chapterName = c['name'];
        break;
      }
    }

    _ctrl.setActivityContext({
      'chapterId': chapterId,
      'chapterName': jsOr([chapterName, '']),
      'topicId': topicId,
      'topicName': topicName,
      'topicImage': topicImage,
      'activityId': activity['id'],
      'classId': _selectedClassId,
      'className': jsOr([_selectedClass['name'], '']),
      'batchId': _selectedBatchId,
      'batchName': _selectedBatchName,
      'subjectId': _selectedSubjectId,
      'subjectName': jsOr([_subjectName(), '']),
      'syllabus': jsOr([_selectedSyllabus, '']),
      'instituteId': _instituteId,
      'allChaptersData': const [],
    });
    context.go('/activitylibrary');
  }

  /// `filteredSubjects.find(s => s.id === selectedSubjectId)?.name`.
  Object? _subjectName() {
    for (final raw in _filteredSubjects) {
      final s = asMap(raw);
      if (s != null && s['id'] == _selectedSubjectId) return s['name'];
    }
    return null;
  }

  Future<void> _fetchAllActivities() async {
    try {
      final chapters = _filteredChapters;
      if (!jsTruthy(_instituteId) || chapters.isEmpty) return;
      final responses = await Future.wait(
          chapters.map((ch) => _ctrl.getZslLinks(_instituteId, asMap(ch)?['id'])));
      _set(() => _allActivitiesData = responses.expand((r) => r).toList());
    } catch (err) {
      debugPrint('fetchAllActivities failed: $err');
      _set(() => _error = 'Failed to load activities');
    }
  }

  Future<void> _fetchAllClasses() async {
    _set(() {
      _loading = true;
      _error = null;
    });
    try {
      _instituteId = _getInstituteId();
      if (!jsTruthy(_instituteId)) {
        _set(() {
          _error = 'No institute ID found. Please log in again.';
          _loading = false;
        });
        return;
      }
      final data = await _container.read(zslServiceProvider).getClass(_instituteId, _selectedSyllabus);
      _allClassesData = asList(data);
      _filterClassesBySyllabus();
    } catch (err) {
      _set(() {
        _error = 'Failed to load classes: ${jsErrorMessage(err)}';
        _allClassesData = [];
        _allClasses = [];
        _selectedClassId = null;
        _selectedSubjectId = null;
        _selectedChapterId = null;
      });
    } finally {
      _set(() => _loading = false);
    }
  }

  void _filterClassesBySyllabus() {
    _set(() {
      _allClasses = [for (final c in _allClassesData) asMap(c) ?? <String, dynamic>{}];
      if (_allClasses.isNotEmpty) {
        final classToSelect =
            jsOr([_selectedClassId, _ctrl.persistedClassId, _allClasses.first['id']]);
        final exists = _allClasses.any((c) => sameId(c['id'], classToSelect));
        _selectedClassId = exists ? classToSelect : _allClasses.first['id'];
        _ctrl.persistedClassId = _selectedClassId;
        // this.$nextTick(() => this.onClassChange())
        Future.microtask(_onClassChange);
      } else {
        _selectedClassId = null;
        _selectedSubjectId = null;
        _selectedChapterId = null;
      }
    });
  }

  Future<void> _onClassChange() async {
    if (jsTruthy(_selectedClassId)) _ctrl.persistedClassId = _selectedClassId;

    final syllabus = _selectedClass['syllabus'];
    if (jsTruthy(syllabus) && syllabus != _selectedSyllabus) _selectedSyllabus = syllabus;

    _set(() {
      if (jsTruthy(_ctrl.persistedSubjectId)) {
        _selectedSubjectId = _ctrl.persistedSubjectId;
      } else {
        _selectedSubjectId = null;
        _selectedChapterId = null;
      }
    });

    try {
      if (jsTruthy(_selectedClassId) && jsTruthy(_instituteId)) {
        _set(() => _loading = true);
        final classId = _selectedClassId!;
        final subjects = await _ctrl.getAllSubjects(_instituteId!, classId);
        final idx = _allClasses.indexWhere((c) => c['id'] == classId);
        if (idx != -1) _allClasses[idx]['subjects'] = subjects;

        if (subjects.isNotEmpty) {
          final exists = subjects.any((s) => sameId(asMap(s)?['id'], _selectedSubjectId));
          if (!jsTruthy(_selectedSubjectId) || !exists) {
            _selectedSubjectId = asMap(subjects.first)?['id'];
            _ctrl.persistedSubjectId = _selectedSubjectId;
          }
          Future.microtask(_onSubjectChange);
        }
      }
    } catch (err) {
      debugPrint('Error fetching subjects: $err');
      _set(() => _error = 'Failed to load subjects');
    } finally {
      _set(() => _loading = false);
    }
  }

  Future<void> _onSubjectChange() async {
    if (!jsTruthy(_selectedSubjectId) || !jsTruthy(_instituteId) || !jsTruthy(_selectedClassId)) {
      return;
    }
    final subjectId = _selectedSubjectId!;
    _ctrl.persistedSubjectId = subjectId;

    try {
      _set(() => _loading = true);
      final chapters = await _ctrl.getallchpaters(_instituteId!, _selectedClassId!, subjectId);
      _chaptersCache[jsString(subjectId)] = chapters;

      if (chapters.isNotEmpty) {
        final saved = _ctrl.persistedChapterId;
        final exists = chapters.any((ch) => asMap(ch)?['id'] == saved);
        _set(() => _selectedChapterId = exists ? saved : asMap(chapters.first)?['id']);
        await _onChapterChange();
        await _fetchAllActivities();
      } else {
        _set(() {
          _selectedChapterId = null;
          _chapterReferenceUrl = null;
          _chapterReferenceContent = null;
        });
      }
    } catch (err) {
      debugPrint('Error fetching chapters: $err');
      _set(() => _error = 'Failed to load chapters');
    } finally {
      _set(() => _loading = false);
    }
  }

  void _goToActivity(Map<String, dynamic> topic) {
    _ctrl.setPersistedFilters(_selectedClassId, _selectedSubjectId, _selectedChapterId);

    final allChaptersForSubject = [
      for (final raw in _filteredChapters)
        if (asMap(raw) case final ch?)
          {
            'id': ch['id'],
            'name': ch['name'],
            'topics': [
              for (final t in asList(ch['topics']))
                {
                  'id': asMap(t)?['id'],
                  'name': asMap(t)?['name'],
                  'file_path': asMap(t)?['file_path'],
                  'activities': jsTruthy(asMap(t)?['activities']) ? asMap(t)!['activities'] : const [],
                },
            ],
          },
    ];

    _ctrl.setActivityContext({
      'chapterId': _selectedChapterId,
      'chapterName': _selectedChapter['name'],
      'topicId': topic['id'],
      'topicName': topic['name'],
      'topicImage': jsOr([topic['file_path'], '']),
      'classId': _selectedClassId,
      'className': _selectedClass['name'],
      'batchId': _selectedBatchId,
      'batchName': _selectedBatchName,
      'subjectId': _selectedSubjectId,
      'subjectName': jsOr([_subjectName(), '']),
      'syllabus': _selectedSyllabus,
      'instituteId': _instituteId,
      'allChaptersData': allChaptersForSubject,
    });
    context.go('/activitylibrary');
  }

  // ── template ──

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final md = context.isMd;

    final Widget body;
    if (_loading) {
      body = Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(children: [
          const BrainLoader(),
          const SizedBox(height: 20),
          Pulse(
            child: Text('Activities Loading Please wait ...',
                textAlign: TextAlign.center,
                style: libNunito(
                  fontSize: 14,
                  height: twLeading(14),
                  fontWeight: FontWeight.w500,
                  color: Tw.gray400,
                  letterSpacing: 1.4,
                )),
          ),
        ]),
      );
    } else if (_error != null) {
      body = Padding(
        padding: const EdgeInsets.fromLTRB(16, 40, 16, 0),
        child: Text(_error!,
            textAlign: TextAlign.center,
            style: libNunito(
                color: Tw.red500, fontSize: sm ? 16 : 14, height: twLeading(sm ? 16 : 14))),
      );
    } else {
      body = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const SizedBox(height: 24),
        if (_isGrid) _gridView(context) else _listView(context),
        if ((_chapterReferenceUrl != null || jsTruthy(_chapterReferenceContent)) &&
            jsTruthy(_selectedChapterId) &&
            _selectedChapterId != 'all-activities')
          _referencePanel(context),
      ]);
    }

    return LoadingOverlay(
      loading: _loading,
      child: DefaultTextStyle.merge(
        style: GoogleFonts.nunito(),
        child: Container(
          color: dark ? AppColors.dashboardDark : Colors.transparent,
          child: Stack(children: [
            // Ambient glow blobs (`fixed`, behind the content).
            Positioned(
              top: -200,
              right: -100,
              child: GlowBlob(
                  size: 600, color: _brandIndigo.withValues(alpha: dark ? 0.05 : 0.1), opacity: 0.2),
            ),
            Positioned(
              bottom: 0,
              left: -100,
              child: GlowBlob(
                size: 400,
                color: dark ? Tw.indigo950.withValues(alpha: 0.2) : Tw.indigo300.withValues(alpha: 0.1),
                opacity: 0.1,
              ),
            ),
            Positioned.fill(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: sm ? 16 : 8, vertical: sm ? 24 : 16),
                child: Container(
                  decoration: libGlassContainer(context),
                  padding: EdgeInsets.all(md ? 24 : (sm ? 20 : 16)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    _banner(context),
                    // gap-6 + the banner's mb-6, then the filter bar's my-4 sm:my-5.
                    const SizedBox(height: 24 + 24),
                    SizedBox(height: sm ? 20 : 16),
                    _filterBar(context),
                    SizedBox(height: sm ? 20 : 16),
                    const SizedBox(height: 24),
                    body,
                  ]),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _banner(BuildContext context) {
    final sm = context.isSm;
    final md = context.isMd;
    final lg = context.isLg;
    final titleSize = lg ? 30.0 : (sm ? 24.0 : 20.0);

    final iconBox = Container(
      width: sm ? 48 : 44,
      height: sm ? 48 : 44,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: AppShadows.lg,
      ),
      child: const Icon(BootstrapIcons.collection_play_fill, size: 20, color: Colors.white),
    );

    final texts = Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Pulse(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(
              width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('RESOURCE HUB',
              style: libNunito(
                  fontSize: 9, height: 1.5, fontWeight: FontWeight.w900, letterSpacing: 0.9, color: Tw.indigo100)),
        ]),
      ),
      const SizedBox(height: 2),
      Text('Activity Library',
          style: libNunito(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.25,
            letterSpacing: -0.025 * titleSize,
            // drop-shadow-sm: `0 1px 2px rgb(0 0 0 / .15)`; the CSS blur is a
            // standard deviation (2) → blurRadius (2 - 0.5) / 0.57735 ≈ 2.6.
            shadows: const [Shadow(color: Color(0x26000000), blurRadius: 2.6, offset: Offset(0, 1))],
          )),
      const SizedBox(height: 2),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 448),
        child: Text(
          'Explore interactive lessons, virtual labs, and activities designed to reinforce learning.',
          style: libNunito(
              fontSize: sm ? 12 : 11,
              height: sm ? twLeading(12) : 1.5,
              fontWeight: FontWeight.w500,
              color: Tw.indigo50),
        ),
      ),
    ]);

    final left = Row(mainAxisSize: MainAxisSize.min, children: [
      iconBox,
      SizedBox(width: sm ? 16 : 12),
      Flexible(child: texts),
    ]);

    Widget toggleBtn(bool grid) {
      final active = _isGrid == grid;
      return _ToggleButton(
        active: active,
        icon: grid ? BootstrapIcons.grid_3x3_gap_fill : BootstrapIcons.calendar2_event,
        label: grid ? 'Grid' : 'List',
        showLabel: sm,
        onTap: () => setState(() => _isGrid = grid),
      );
    }

    final toggle = Container(
      padding: const EdgeInsets.all(4),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [toggleBtn(true), const SizedBox(width: 4), toggleBtn(false)]),
    );

    final content = sm
        ? Row(children: [Expanded(child: Align(alignment: Alignment.centerLeft, child: left)), toggle])
        : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [left, const SizedBox(height: 16), toggle]);

    final shapes = Opacity(opacity: 0.2, child: _FloatingShapes(sm: sm, md: md));

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        gradient: CssLinearGradient(
          corner: Alignment.bottomRight,
          colors: [_brandIndigo, _brandIndigo.withValues(alpha: 0.9), Tw.indigo700],
        ),
        boxShadow: AppShadows.lg,
      ),
      child: Stack(clipBehavior: Clip.hardEdge, children: [
        const Positioned.fill(child: CustomPaint(painter: DotPatternPainter())),
        const Positioned(top: -150, left: -100, child: GlowBlob(size: 400, color: _brandIndigo, opacity: 0.4)),
        const Positioned(
            bottom: -150, right: -50, child: GlowBlob(size: 350, color: Color(0xFF818CF8), opacity: 0.3)),
        // `absolute right-10` with no top: the flex static position — centred
        // in the row layout, at the top padding in the column layout.
        Positioned(
          right: 40,
          top: sm ? 0 : 16,
          bottom: sm ? 0 : null,
          child: IgnorePointer(child: sm ? Center(child: shapes) : shapes),
        ),
        Padding(padding: EdgeInsets.all(md ? 24 : (sm ? 20 : 16)), child: content),
      ]),
    );
  }

  Widget _filterBar(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final lg = context.isLg;
    final fontSize = sm ? 16.0 : 14.0;

    final classItems = <AppSelectItem<Object?>>[
      for (final c in _allClasses) AppSelectItem<Object?>(c['id'], vueText(c['name'])),
      if (_loading && _allClasses.isEmpty)
        const AppSelectItem<Object?>('loading', 'Loading Classes...', enabled: false),
      if (!_loading && _allClasses.isEmpty)
        const AppSelectItem<Object?>('empty', 'No Classes Available', enabled: false),
    ];
    final subjects = _filteredSubjects;
    final subjectItems = <AppSelectItem<Object?>>[
      for (final raw in subjects)
        if (asMap(raw) case final s?)
          AppSelectItem<Object?>(s['id'], '${vueText(s['name'])} - ${vueText(s['syllabus'])}'),
      if (subjects.isEmpty) const AppSelectItem<Object?>('empty', 'No Subjects Available', enabled: false),
    ];
    final chapters = _filteredChapters;
    final chapterItems = <AppSelectItem<Object?>>[
      for (final raw in chapters)
        if (asMap(raw) case final ch?) AppSelectItem<Object?>(ch['id'], vueText(ch['name'])),
      const AppSelectItem<Object?>('all-activities', 'Show all Activities'),
      if (chapters.isEmpty) const AppSelectItem<Object?>('empty', 'Select Subject First', enabled: false),
    ];

    // The kit trigger keeps `h-9` (the page's py-… do not change the height)
    // and `dark:bg-input/30 dark:hover:bg-input/50` under the page's classes.
    final input = AppColors.darkInput;

    // CLASS: `rounded-xl bg-gradient-to-r from-indigo-50 to-indigo-100/50
    // dark:from-indigo-950/40 dark:to-indigo-900/20 border-indigo-100
    // dark:border-indigo-900/30 shadow-sm hover:shadow-md hover:from-indigo-100
    // hover:to-indigo-200/50 dark:hover:from-indigo-900/30 dark:hover:to-indigo-900/10`
    BoxDecoration classDeco(bool hover) {
      final List<Color> stops;
      if (dark) {
        final under = input.withValues(alpha: hover ? 0.5 : 0.3);
        stops = [
          hover ? Tw.indigo900.withValues(alpha: 0.3) : Tw.indigo950.withValues(alpha: 0.4),
          Tw.indigo900.withValues(alpha: hover ? 0.1 : 0.2),
        ].map((c) => Color.alphaBlend(c, under)).toList();
      } else {
        stops = hover
            ? [Tw.indigo100, Tw.indigo200.withValues(alpha: 0.5)]
            : [Tw.indigo50, Tw.indigo100.withValues(alpha: 0.5)];
      }
      return BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(colors: stops),
        border: Border.all(color: dark ? Tw.indigo900.withValues(alpha: 0.3) : Tw.indigo100),
        boxShadow: hover ? AppShadows.md : AppShadows.sm,
      );
    }

    // SUBJECT / CHAPTER: `bg-transparent border-slate-200/60
    // dark:border-slate-800 lg:border-none rounded-xl px-5` (+ kit shadow-xs).
    BoxDecoration plainDeco(bool hover) => BoxDecoration(
          color: dark ? input.withValues(alpha: hover ? 0.5 : 0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: lg ? null : Border.all(color: dark ? Tw.slate800 : Tw.slate200.withValues(alpha: 0.6)),
          boxShadow: AppShadows.xs,
        );
    final plainText = libNunito(fontSize: fontSize, color: dark ? Colors.white : Tw.gray800);
    const pad = EdgeInsets.symmetric(horizontal: 20);

    final classSelect = LibrarySelect<Object?>(
      value: _selectedClassId,
      items: classItems,
      placeholder: 'Select Class',
      height: 36,
      padding: pad,
      decoration: classDeco(false),
      hoverDecoration: classDeco(true),
      textStyle: libNunito(
          fontSize: fontSize, fontWeight: FontWeight.w600, color: dark ? Tw.indigo300 : Tw.indigo600),
      onChanged: (v) {
        setState(() => _selectedClassId = v);
        _onClassChange();
      },
    );
    final subjectSelect = LibrarySelect<Object?>(
      value: _selectedSubjectId,
      items: subjectItems,
      placeholder: 'Select Subject',
      enabled: subjects.isNotEmpty,
      height: 36,
      padding: pad,
      decoration: plainDeco(false),
      hoverDecoration: plainDeco(true),
      textStyle: plainText,
      onChanged: (v) {
        setState(() => _selectedSubjectId = v);
        _onSubjectChange();
      },
    );
    final chapterSelect = LibrarySelect<Object?>(
      value: _selectedChapterId,
      items: chapterItems,
      placeholder: 'Select Chapter',
      enabled: chapters.isNotEmpty,
      height: 36,
      padding: pad,
      decoration: plainDeco(false),
      hoverDecoration: plainDeco(true),
      textStyle: plainText,
      onChanged: (v) {
        setState(() => _selectedChapterId = v);
        _onChapterChange();
      },
    );

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: dark ? Tw.slate900.withValues(alpha: 0.85) : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: dark ? Tw.slate800.withValues(alpha: 0.6) : Colors.white.withValues(alpha: 0.2)),
        boxShadow: AppShadows.xs,
      ),
      child: lg
          ? Row(children: [
              Expanded(flex: 34, child: classSelect),
              const SizedBox(width: 8),
              Expanded(flex: 34, child: subjectSelect),
              const SizedBox(width: 8),
              Expanded(flex: 32, child: chapterSelect),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              classSelect,
              const SizedBox(height: 8),
              subjectSelect,
              const SizedBox(height: 8),
              chapterSelect,
            ]),
    );
  }
}

/// `#4f46e5` (`from-[#4f46e5]`, `bg-[#4f46e5]/10`) — Tailwind 4's indigo-600 differs.
const _brandIndigo = Color(0xFF4F46E5);

/// Grid / List view toggle: `px-3.5 py-1.5 text-xs sm:text-sm font-black
/// rounded-lg`, active `bg-white text-indigo-600 shadow-sm`, otherwise
/// `text-white/60 hover:text-white hover:bg-white/10`.
class _ToggleButton extends StatefulWidget {
  const _ToggleButton({
    required this.active,
    required this.icon,
    required this.label,
    required this.showLabel,
    required this.onTap,
  });

  final bool active;
  final IconData icon;
  final String label;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  State<_ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<_ToggleButton> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final fg = active
        ? Tw.indigo600
        : (_hover ? Colors.white : Colors.white.withValues(alpha: 0.6));
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: active
                ? Colors.white
                : (_hover ? Colors.white.withValues(alpha: 0.1) : Colors.transparent),
            borderRadius: BorderRadius.circular(16),
            boxShadow: active ? AppShadows.sm : null,
          ),
          // The `bi` icon's line box (text-sm → 20px) sets the height.
          child: SizedBox(
            height: 20,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(widget.icon, size: 14, color: fg),
              if (widget.showLabel) ...[
                const SizedBox(width: 6),
                Text(widget.label,
                    style: libNunito(
                        fontSize: context.isSm ? 14 : 12, fontWeight: FontWeight.w900, color: fg)),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}

/// The banner's floating outline shapes (star, dashed circle on sm+,
/// rounded square on md+), each bobbing `translateY(-15px) rotate(5deg)`
/// over 4s, ease-in-out, 1.2s apart.
class _FloatingShapes extends StatefulWidget {
  const _FloatingShapes({required this.sm, required this.md});

  final bool sm;
  final bool md;

  @override
  State<_FloatingShapes> createState() => _FloatingShapesState();
}

class _FloatingShapesState extends State<_FloatingShapes> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 4))..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Widget _shape(_ShapeKind kind, double size, double delaySeconds) {
    final p = (_c.value - delaySeconds / 4) % 1.0;
    final w = Curves.easeInOut.transform(p < 0.5 ? p * 2 : (1 - p) * 2);
    return Transform.translate(
      offset: Offset(0, -15 * w),
      child: Transform.rotate(
        angle: 5 * math.pi / 180 * w,
        child: CustomPaint(size: Size.square(size), painter: _ShapePainter(kind)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _c,
        builder: (context, _) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _shape(_ShapeKind.star, 56, 0),
            if (widget.sm) ...[const SizedBox(width: 24), _shape(_ShapeKind.circle, 40, 1.2)],
            if (widget.md) ...[const SizedBox(width: 24), _shape(_ShapeKind.square, 64, 2.4)],
          ],
        ),
      );
}

enum _ShapeKind { star, circle, square }

/// The inline SVGs (24×24 view box, `stroke-width="1.5"`, white).
class _ShapePainter extends CustomPainter {
  const _ShapePainter(this.kind);
  final _ShapeKind kind;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..color = Colors.white;
    switch (kind) {
      case _ShapeKind.star:
        const pts = [
          Offset(12, 2), Offset(15.09, 8.26), Offset(22, 9.27), Offset(17, 14.14), Offset(18.18, 21.02), //
          Offset(12, 17.77), Offset(5.82, 21.02), Offset(7, 14.14), Offset(2, 9.27), Offset(8.91, 8.26),
        ];
        canvas.drawPath(Path()..addPolygon(pts, true), paint);
      case _ShapeKind.circle:
        // r=10, stroke-dasharray="4 4" from 3 o'clock, clockwise.
        const r = 10.0;
        const dash = 4 / r;
        final rect = Rect.fromCircle(center: const Offset(12, 12), radius: r);
        for (var a = 0.0; a < 2 * math.pi; a += 2 * dash) {
          canvas.drawArc(rect, a, math.min(dash, 2 * math.pi - a), false, paint);
        }
      case _ShapeKind.square:
        canvas.drawRRect(
            RRect.fromRectAndRadius(const Rect.fromLTWH(3, 3, 18, 18), const Radius.circular(2)), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter old) => old.kind != kind;
}
