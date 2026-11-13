import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../data/services/services.dart';
import '../../state/providers.dart';
import '../../widgets/form_fields.dart' show AppSelectItem;
import '../../widgets/web_content_view.dart';
import 'library_controller.dart';
import 'library_logic.dart';
import 'library_widgets.dart';

/// Port of `src/components/new_ui_student_teacher_for_both_labs/newlibrarypage.vue`
/// (route `/newlibrary`, "Virtual Labs Library").
///
/// Class select + subject chips, chapter / topic selects, topic cards (or all
/// activities grouped by chapter) and the chapter reference. Opening a card
/// stores `selectedActivityContext` and goes to `/activitylibrary`.
class NewLibraryPage extends ConsumerStatefulWidget {
  const NewLibraryPage({super.key});

  @override
  ConsumerState<NewLibraryPage> createState() => _NewLibraryPageState();
}

class _NewLibraryPageState extends ConsumerState<NewLibraryPage> {
  // ── data() ──
  bool _loading = false;
  String? _error;
  Object? _selectedClassId;
  Object? _selectedSubjectId;
  Object? _selectedChapterId;
  Object? _selectedTopicId = 'all';
  List<Map<String, dynamic>> _allClasses = [];
  final Map<String, List<dynamic>> _chaptersCache = {};
  List<dynamic> _allActivitiesData = [];
  bool _showAllActivitiesInline = false;
  String? _chapterReferenceUrl;
  String? _chapterReferenceContent;
  bool _referenceLoading = false;
  bool _referenceExpanded = true;

  /// Read through the container: async handlers keep running after the page
  /// is left (like the web's component methods), when `ref` is unusable.
  late final ProviderContainer _container;

  LibraryController get _ctrl => _container.read(libraryControllerProvider.notifier);

  void _set(VoidCallback fn) {
    fn();
    if (mounted) setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _container = ProviderScope.containerOf(context, listen: false);
    Future.microtask(_fetchAllClasses);
  }

  // ── computed ──

  Object? get _instituteId => jsOr([_container.read(sessionProvider).userInfo?.instituteId, '']);

  Map<String, dynamic> get _selectedClass =>
      _allClasses.firstWhere((c) => c['id'] == _selectedClassId, orElse: () => <String, dynamic>{});

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

  List<Map<String, dynamic>> get _displayedActivities {
    if (jsTruthy(_selectedTopicId) && _selectedTopicId != 'all') {
      return _filteredTopics.where((t) => sameId(t['id'], _selectedTopicId)).toList();
    }
    return _filteredTopics;
  }

  Object? _subjectName() {
    for (final raw in _filteredSubjects) {
      final s = asMap(raw);
      if (s != null && s['id'] == _selectedSubjectId) return s['name'];
    }
    return null;
  }

  // ── methods ──

  void _selectSubject(Object? subjectId) {
    _set(() {
      _selectedSubjectId = subjectId;
      _selectedChapterId = null;
      _selectedTopicId = 'all';
    });
    _onSubjectChange();
  }

  Future<void> _loadChapterReference(Map<String, dynamic>? chapter) async {
    _set(() {
      _chapterReferenceUrl = null;
      _chapterReferenceContent = null;
    });
    if (chapter == null || !jsTruthy(chapter['id'])) return;

    if (chapter['chapter_reference_text'] != null) {
      _set(() {
        _chapterReferenceContent = jsString(chapter['chapter_reference_text']);
        _referenceExpanded = true;
      });
      return;
    }
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
      debugPrint('Failed to load chapter reference: $err');
    } finally {
      _set(() => _referenceLoading = false);
    }
  }

  Future<void> _onChapterChange() async {
    _ctrl.persistedChapterId = _selectedChapterId;
    _set(() => _selectedTopicId = 'all');

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
      final instituteId = _container.read(sessionProvider).userInfo?.instituteId;
      if (!jsTruthy(instituteId)) {
        _set(() => _error = 'No institute ID found. Please log in again.');
        return;
      }
      final data = asList(await _container.read(zslServiceProvider).getClass(instituteId, null));
      _set(() {
        _allClasses = [for (final c in data) asMap(c) ?? <String, dynamic>{}];
        if (_allClasses.isNotEmpty) {
          final savedId = _ctrl.persistedClassId;
          final exists = _allClasses.any((c) => sameId(c['id'], savedId));
          _selectedClassId = exists ? savedId : _allClasses.first['id'];
          _ctrl.persistedClassId = _selectedClassId;
          Future.microtask(_onClassChange);
        }
      });
    } catch (err) {
      _set(() => _error = 'Failed to load classes: ${jsErrorMessage(err)}');
    } finally {
      _set(() => _loading = false);
    }
  }

  Future<void> _onClassChange() async {
    if (jsTruthy(_selectedClassId)) _ctrl.persistedClassId = _selectedClassId;

    _set(() {
      _selectedSubjectId = jsOr([_ctrl.persistedSubjectId, null]);
      _selectedChapterId = null;
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
        final savedId = _ctrl.persistedChapterId;
        final exists = chapters.any((ch) => asMap(ch)?['id'] == savedId);
        _set(() => _selectedChapterId = exists ? savedId : asMap(chapters.first)?['id']);
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
    _ctrl.setActivityContext({
      'chapterId': _selectedChapterId,
      'chapterName': _selectedChapter['name'],
      'topicId': topic['id'],
      'topicName': topic['name'],
      'topicImage': jsOr([topic['file_path'], '']),
      'classId': _selectedClassId,
      'className': _selectedClass['name'],
      'subjectId': _selectedSubjectId,
      'subjectName': jsOr([_subjectName(), '']),
      'syllabus': jsOr([_selectedClass['syllabus'], '']),
      'instituteId': _instituteId,
      'allChaptersData': [
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
      ],
    });
    context.go('/activitylibrary');
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
    final chapterId = jsOr([parentTopic?['chapter_id'], activity['chapter_id'], _selectedChapterId]);
    final topicId = jsOr([parentTopic?['id'], activity['topic_id'], '']);
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
      'topicName': jsOr([parentTopic?['name'], activity['topic_name'], '']),
      'topicImage': jsOr([parentTopic?['file_path'], activity['file_path'], '']),
      'activityId': activity['id'],
      'classId': _selectedClassId,
      'className': jsOr([_selectedClass['name'], '']),
      'subjectId': _selectedSubjectId,
      'subjectName': jsOr([_subjectName(), '']),
      'syllabus': jsOr([_selectedClass['syllabus'], '']),
      'instituteId': _instituteId,
      'allChaptersData': const [],
    });
    context.go('/activitylibrary');
  }

  // ── template ──

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final lg = context.isLg;
    final hPad = lg ? 56.0 : (sm ? 40.0 : 24.0);

    // `max-w-screen-xl mx-auto` boxes (the padding is inside the 1280px).
    Widget constrained(Widget child, EdgeInsets padding) => Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1280),
            child: Padding(padding: padding, child: child),
          ),
        );

    final Widget body;
    if (_loading) {
      body = Padding(
        padding: const EdgeInsets.only(top: 96),
        child: Column(children: [
          const RingSpinner(size: 40, stroke: 4, color: LibColors.green),
          const SizedBox(height: 16),
          Pulse(
            child: Text('Activities loading, please wait...',
                textAlign: TextAlign.center,
                style: TextStyle(
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
            style: TextStyle(color: Tw.red500, fontSize: 14, height: twLeading(14))),
      );
    } else {
      body = constrained(_content(context), EdgeInsets.fromLTRB(hPad, 32, hPad, 64));
    }

    final titleSize = sm ? 36.0 : 30.0;
    final subSize = sm ? 16.0 : 14.0;
    return ColoredBox(
      color: dark ? LibColors.gray950 : LibColors.pageLight,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: dark ? Colors.white : Tw.gray800),
        child: SingleChildScrollView(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // ══ PAGE HEADER ══
            constrained(
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Virtual Labs Library',
                    style: TextStyle(
                      fontSize: titleSize,
                      height: twLeading(titleSize),
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.025 * titleSize,
                      color: dark ? Colors.white : Tw.gray900,
                    )),
                const SizedBox(height: 4),
                Text('Access 1000+ interactive ZSL simulations. Filter by curriculum hierarchy.',
                    style: TextStyle(
                        fontSize: subSize, height: twLeading(subSize), color: dark ? Tw.gray400 : Tw.gray500)),
              ]),
              EdgeInsets.fromLTRB(hPad, 32, hPad, 8),
            ),
            // ══ FILTER CARD ══
            constrained(_filterCard(context), EdgeInsets.fromLTRB(hPad, 24, hPad, 0)),
            body,
          ]),
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(text.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              height: 1.5,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
              color: context.isDark ? Tw.gray500 : Tw.gray400,
            )),
      );

  Widget _filterCard(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final lg = context.isLg;

    // `h-11 rounded-xl border-gray-200 dark:border-gray-700 bg-white
    // dark:bg-gray-800 px-4 shadow-none` — the kit's `data-[size=default]:h-9`
    // beats `h-11`, and its `dark:hover:bg-input/50` stays.
    BoxDecoration selectDeco(bool hover) => BoxDecoration(
          color: dark ? (hover ? AppColors.darkInput.withValues(alpha: 0.5) : Tw.gray800) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: dark ? Tw.gray700 : Tw.gray200),
        );
    final selectText = TextStyle(
        fontSize: 14, fontWeight: FontWeight.w500, color: dark ? Colors.white : Tw.gray900);
    const selectPadding = EdgeInsets.symmetric(horizontal: 16);

    // `<SelectContent class="rounded-xl border-gray-100 dark:border-gray-700
    // bg-white dark:bg-gray-800 shadow-xl">`, disabled items `text-gray-400`.
    LibrarySelect<Object?> select({
      required Object? value,
      required String placeholder,
      required List<AppSelectItem<Object?>> items,
      required ValueChanged<Object?> onChanged,
      bool enabled = true,
    }) =>
        LibrarySelect<Object?>(
          value: value,
          placeholder: placeholder,
          enabled: enabled,
          height: 36,
          padding: selectPadding,
          decoration: selectDeco(false),
          hoverDecoration: selectDeco(true),
          textStyle: selectText,
          menuRadius: 20,
          menuBackgroundColor: dark ? Tw.gray800 : Colors.white,
          menuBorderColor: dark ? Tw.gray700 : Tw.gray100,
          menuElevation: 6,
          disabledItemColor: Tw.gray400,
          items: items,
          onChanged: onChanged,
        );

    final classField = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _label('Class'),
      select(
        value: _selectedClassId,
        placeholder: 'Select Class',
        items: [
          for (final c in _allClasses) AppSelectItem<Object?>(c['id'], vueText(c['name'])),
          if (_loading && _allClasses.isEmpty)
            const AppSelectItem<Object?>('loading', 'Loading Classes...', enabled: false),
          if (!_loading && _allClasses.isEmpty)
            const AppSelectItem<Object?>('empty', 'No Classes Available', enabled: false),
        ],
        onChanged: (v) {
          setState(() => _selectedClassId = v);
          _onClassChange();
        },
      ),
    ]);

    final subjects = _filteredSubjects;
    final subjectField = Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label('Subject'),
      Wrap(spacing: 8, runSpacing: 8, children: [
        for (final raw in subjects)
          if (asMap(raw) case final s?)
            _SubjectChip(
              label: vueText(s['name']),
              active: _selectedSubjectId == s['id'],
              onTap: () => _selectSubject(s['id']),
            ),
        if (subjects.isEmpty && !_loading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text('Select a class to view subjects',
                style: TextStyle(fontSize: 14, height: twLeading(14), color: Tw.gray400)),
          ),
      ]),
    ]);

    final chapters = _filteredChapters;
    final chapterField = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _label('Chapter'),
      select(
        value: _selectedChapterId,
        placeholder: 'All Chapters',
        enabled: chapters.isNotEmpty,
        items: [
          const AppSelectItem<Object?>('all-activities', 'All Chapters'),
          for (final raw in chapters)
            if (asMap(raw) case final ch?) AppSelectItem<Object?>(ch['id'], vueText(ch['name'])),
          if (chapters.isEmpty) const AppSelectItem<Object?>('empty', 'Select Subject First', enabled: false),
        ],
        onChanged: (v) {
          setState(() => _selectedChapterId = v);
          _onChapterChange();
        },
      ),
    ]);

    final topics = _filteredTopics;
    final topicField = Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      _label('Topic'),
      select(
        value: _selectedTopicId,
        placeholder: 'All Topics',
        enabled: topics.isNotEmpty,
        items: [
          const AppSelectItem<Object?>('all', 'All Topics'),
          for (final t in topics) AppSelectItem<Object?>(t['id'], vueText(t['name'])),
        ],
        onChanged: (v) => setState(() => _selectedTopicId = v),
      ),
    ]);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: dark ? Tw.gray900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Tw.gray800 : Tw.gray100),
        boxShadow: AppShadows.sm,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        // ROW 1: Class + Subject
        if (lg)
          Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            SizedBox(width: 280, child: classField),
            const SizedBox(width: 40),
            Expanded(child: subjectField),
          ])
        else
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            classField,
            const SizedBox(height: 24),
            subjectField,
          ]),
        const SizedBox(height: 20),
        Divider(height: 1, thickness: 1, color: dark ? Tw.gray800 : Tw.gray100),
        const SizedBox(height: 20),
        // ROW 2: Chapter + Topic
        if (sm)
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: chapterField),
            const SizedBox(width: 24),
            Expanded(child: topicField),
          ])
        else
          Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            chapterField,
            const SizedBox(height: 16),
            topicField,
          ]),
      ]),
    );
  }

  Widget _content(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final cols = libGridColumns(context);
    final displayed = _displayedActivities;
    final headingSize = sm ? 20.0 : 18.0;

    final header = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(children: [
        const CustomPaint(size: Size.square(22), painter: _GridGlyphPainter()),
        const SizedBox(width: 10),
        Expanded(
          child: Text('Available Activities',
              style: TextStyle(
                fontSize: headingSize,
                height: twLeading(headingSize),
                fontWeight: FontWeight.w700,
                color: dark ? Colors.white : Tw.gray900,
              )),
        ),
        if (displayed.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: dark ? LibColors.greenDark.withValues(alpha: 0.2) : LibColors.greenTint,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text('${displayed.length} Found',
                style: TextStyle(
                  fontSize: 12,
                  height: twLeading(12),
                  fontWeight: FontWeight.w600,
                  color: dark ? LibColors.greenLight : LibColors.greenDark,
                )),
          ),
      ]),
    );

    final children = <Widget>[header];
    if (_showAllActivitiesInline) {
      for (final raw in _filteredChapters) {
        final chapter = asMap(raw);
        if (chapter == null) continue;
        final acts = activitiesForChapter(_allActivitiesData, chapter['id']);
        children.add(Padding(
          padding: const EdgeInsets.only(bottom: 40),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(children: [
                Container(
                  width: 4,
                  height: 20,
                  decoration:
                      BoxDecoration(color: LibColors.green, borderRadius: BorderRadius.circular(99)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(vueText(chapter['name']),
                      style: TextStyle(
                          fontSize: 16,
                          height: twLeading(16),
                          fontWeight: FontWeight.w600,
                          color: LibColors.green)),
                ),
              ]),
            ),
            if (acts.isNotEmpty)
              LibGrid(
                columns: cols,
                gap: 16,
                stretch: true,
                children: [
                  for (final a in acts)
                    _VlCard(
                      name: vueText(a['name']),
                      image: jsTruthy(a['file_path']) ? jsString(a['file_path']) : null,
                      imageHeight: 144,
                      onTap: () => _goToPopupActivity(a),
                    ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text('No activities in this chapter',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, height: twLeading(14), color: Tw.gray400)),
              ),
          ]),
        ));
      }
    } else if (displayed.isNotEmpty) {
      children.add(LibGrid(
        columns: cols,
        gap: sm ? 20 : 16,
        stretch: true,
        children: [
          for (final t in displayed)
            _VlCard(
              name: vueText(t['name']),
              image: jsTruthy(t['file_path']) ? jsString(t['file_path']) : null,
              imageHeight: 160,
              onTap: () => _goToActivity(t),
            ),
        ],
      ));
    } else {
      children.add(Padding(
        padding: const EdgeInsets.symmetric(vertical: 96),
        child: Column(children: [
          const Opacity(
            opacity: 0.4,
            child: CustomPaint(size: Size.square(48), painter: _LinesGlyphPainter(Tw.gray400)),
          ),
          const SizedBox(height: 12),
          Text(
            jsTruthy(_selectedChapterId)
                ? 'No topics available in this chapter.'
                : 'Please select a chapter to view topics.',
            style: TextStyle(fontSize: 14, height: twLeading(14), color: Tw.gray400),
          ),
        ]),
      ));
    }

    if ((_chapterReferenceUrl != null || jsTruthy(_chapterReferenceContent)) &&
        jsTruthy(_selectedChapterId) &&
        _selectedChapterId != 'all-activities') {
      children.add(_referencePanel(context));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children);
  }

  Widget _referencePanel(BuildContext context) {
    final dark = context.isDark;
    final sm = context.isSm;
    final h = MediaQuery.sizeOf(context).height;

    Widget body;
    if (_referenceLoading) {
      body = Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const RingSpinner(color: LibColors.green),
          const SizedBox(width: 12),
          Pulse(
            child: Text('Loading chapter reference...',
                style: TextStyle(fontSize: 14, height: twLeading(14), color: Tw.gray400)),
          ),
        ]),
      );
    } else if (_chapterReferenceUrl != null) {
      body = SizedBox(
        height: (h * 0.6).clamp(520.0, 780.0),
        child: WebContentView(url: _chapterReferenceUrl),
      );
    } else {
      // `p-5 sm:p-7 … overflow-auto` with `max-height: 60vh` (the WebView
      // needs a fixed height, so it is always 60vh).
      body = SizedBox(
        height: h * 0.6,
        child: WebContentView(
          html: libInlineHtmlPage(
            _chapterReferenceContent ?? '',
            dark: dark,
            color: dark ? Colors.white : Tw.gray800,
            background: dark ? Tw.gray900 : Colors.white,
            padding: sm ? 28 : 20,
            fontFamily: dark ? 'Inter, sans-serif' : "'Plus Jakarta Sans', sans-serif",
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(top: 32),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: dark ? Tw.gray900 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: dark ? Tw.gray800 : Tw.gray100),
        boxShadow: AppShadows.sm,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: dark ? LibColors.greenDark.withValues(alpha: 0.1) : LibColors.greenPanel,
            border: Border(bottom: BorderSide(color: dark ? Tw.gray800 : Tw.gray100)),
          ),
          child: Row(children: [
            Container(
              width: 4,
              height: 20,
              decoration: BoxDecoration(color: LibColors.green, borderRadius: BorderRadius.circular(99)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text('Chapter Reference',
                  style: TextStyle(
                      fontSize: 14, height: twLeading(14), fontWeight: FontWeight.w600, color: LibColors.green)),
            ),
            // `hover:opacity-70 transition-opacity`
            HoverLift(
              lift: 0,
              onTap: () => setState(() => _referenceExpanded = !_referenceExpanded),
              builder: (context, hover) => AnimatedOpacity(
                opacity: hover ? 0.7 : 1,
                duration: const Duration(milliseconds: 150),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(_referenceExpanded ? BootstrapIcons.chevron_up : BootstrapIcons.chevron_down,
                      size: 14, color: LibColors.green),
                  const SizedBox(width: 4),
                  Text(_referenceExpanded ? 'Collapse' : 'Expand',
                      style: TextStyle(
                          fontSize: 14,
                          height: twLeading(14),
                          fontWeight: FontWeight.w500,
                          color: LibColors.green)),
                ]),
              ),
            ),
          ]),
        ),
        Visibility(visible: _referenceExpanded, maintainState: true, child: body),
      ]),
    );
  }
}

/// Subject tab: `px-5 py-2.5 rounded-xl text-sm font-semibold border`,
/// active `bg-[#1d9e75] text-white border-[#1d9e75] shadow-md`, otherwise
/// `bg-white dark:bg-gray-800 text-gray-600 dark:text-gray-300
/// border-gray-200 dark:border-gray-700 hover:border-[#1d9e75]
/// hover:text-[#1d9e75]`. (The `shadow-[#1d9e75]/20` colour has no effect.)
class _SubjectChip extends StatelessWidget {
  const _SubjectChip({required this.label, required this.active, required this.onTap});

  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return HoverLift(
      lift: 0,
      onTap: onTap,
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: active ? LibColors.green : (dark ? Tw.gray800 : Colors.white),
          borderRadius: BorderRadius.circular(20),
          // The `dark:` border / text colours beat `hover:…-[#1d9e75]`, so
          // only light mode reacts to the hover.
          border: Border.all(
            color: active ? LibColors.green : (dark ? Tw.gray700 : (hover ? LibColors.green : Tw.gray200)),
          ),
          boxShadow: active ? AppShadows.md : null,
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 14,
              height: twLeading(14),
              fontWeight: FontWeight.w600,
              color: active
                  ? Colors.white
                  : (dark ? Tw.gray300 : (hover ? LibColors.green : Tw.gray600)),
            )),
      ),
    );
  }
}

/// Topic / activity card of the Virtual Labs grid: `bg-white
/// dark:bg-gray-900 rounded-2xl border border-gray-100 dark:border-gray-800
/// hover:-translate-y-1 hover:shadow-lg transition-all duration-200`.
///
/// The web's `<ActivityPlaceholderIcon>` is a runtime-template component,
/// which the runtime-only Vue build never renders, so a card without an
/// image shows an empty grey box there; kept.
class _VlCard extends StatelessWidget {
  const _VlCard({required this.name, required this.image, required this.imageHeight, required this.onTap});

  final String name;
  final String? image;
  final double imageHeight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    return HoverLift(
      duration: const Duration(milliseconds: 200),
      onTap: onTap,
      builder: (context, hover) => AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: dark ? Tw.gray900 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: dark ? Tw.gray800 : Tw.gray100),
          boxShadow: hover ? AppShadows.lg : const [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(
            height: imageHeight,
            color: dark ? Tw.gray800 : Tw.gray50,
            clipBehavior: Clip.hardEdge,
            child: AnimatedScale(
              scale: hover && image != null ? 1.05 : 1,
              duration: const Duration(milliseconds: 300),
              child: LibImage(image, fallback: const SizedBox.shrink()),
            ),
          ),
          // `p-4 flex flex-col gap-3`: the button follows the name (the
          // stretched card leaves the spare height below it).
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.375,
                    fontWeight: FontWeight.w500,
                    color: dark ? Colors.white : Tw.gray800,
                  )),
              const SizedBox(height: 12),
              // `bg-[#1d9e75] hover:bg-[#0f6e56] text-xs font-semibold py-2 rounded-lg`
              HoverLift(
                lift: 0,
                builder: (context, btnHover) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: btnHover ? LibColors.greenDark : LibColors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text('Go to Activity',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, height: twLeading(12), fontWeight: FontWeight.w600, color: Colors.white)),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// The 2×2 rounded-squares SVG next to "Available Activities" (24 view box
/// drawn at 22px, `text-[#1d9e75]`).
class _GridGlyphPainter extends CustomPainter {
  const _GridGlyphPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    void sq(double x, double y, double opacity) => canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromLTWH(x, y, 7, 7), const Radius.circular(1.5)),
          Paint()..color = LibColors.green.withValues(alpha: opacity),
        );
    sq(2, 3, 1);
    sq(10, 3, 0.4);
    sq(2, 12, 0.4);
    sq(10, 12, 0.7);
  }

  @override
  bool shouldRepaint(covariant _GridGlyphPainter oldDelegate) => false;
}

/// Empty-state SVG: `M3 7h18M3 12h18M3 17h12`, `stroke-width="1.2"`.
class _LinesGlyphPainter extends CustomPainter {
  const _LinesGlyphPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color;
    canvas.drawLine(const Offset(3, 7), const Offset(21, 7), p);
    canvas.drawLine(const Offset(3, 12), const Offset(21, 12), p);
    canvas.drawLine(const Offset(3, 17), const Offset(15, 17), p);
  }

  @override
  bool shouldRepaint(covariant _LinesGlyphPainter old) => old.color != color;
}
