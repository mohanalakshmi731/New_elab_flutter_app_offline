import 'dart:async';
import 'dart:ui' as ui;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../mathzoro/mathzoro_controller.dart';
import '../mathzoro/mz_ui.dart' show jsStr, jsDisplay;
import '../mathzoro_zone/math_zone_logic.dart' show findZoneCourse, findZoneSubject, zoneSubjectId;
import '../mathzoro_zone/mz_zone_ui.dart';
import '../student_activity/zsl_activity_controller.dart';
import 'play_zone_logic.dart';

part 'play_zone_cards.dart';
part 'play_zone_dialogs.dart';

/// Port of `src/components/new_ui_student_teacher_for_both_labs/playzone.vue`
/// (`/newlayout/playzone`, MathZoro sidebar "Play Zone").
///
/// Reads from the MathZoro store (`mathZoroProvider`): `selectedClass`,
/// `math_zoro_courses`; `selectedActivityContext` (initial class / subject
/// names) through `zslActivityProvider`; from the session: `userInfo`
/// (institute id, `mathzoroclassid` / `zsl_class_id` fallback) and
/// `language`. Writes `selectedActivityContext` before opening an activity.
///
/// The level dropdown and the per-card quiz button are `hidden` on the web
/// and are not rendered here (the quiz handler `goToQuiz` called an
/// undefined `mathuseUserStore()`).
class PlayZonePage extends ConsumerStatefulWidget {
  const PlayZonePage({super.key});

  @override
  ConsumerState<PlayZonePage> createState() => _PlayZonePageState();
}

/// `unlockModal`.
class _UnlockModal {
  const _UnlockModal({this.visible = false, this.activity, this.loading = false, this.error});
  final bool visible;
  final Json? activity;
  final bool loading;
  final String? error;

  static const _unset = Object();

  _UnlockModal copyWith({bool? visible, bool? loading, Object? error = _unset}) => _UnlockModal(
    visible: visible ?? this.visible,
    activity: activity,
    loading: loading ?? this.loading,
    error: identical(error, _unset) ? this.error : error as String?,
  );
}

/// `toast`.
class _PlayToast {
  const _PlayToast({this.visible = false, this.type = 'success', this.message = ''});
  final bool visible;
  final String type;
  final String message;
}

class _PlayZonePageState extends ConsumerState<PlayZonePage> {
  // ── Context (re-hydrated by autoSelectAndLoad on refresh) ──
  String _selectedClassId = '';
  String _selectedSubjectId = '';
  String _selectedClassName = '';
  String _selectedSubjectName = '';

  List<Json> _chapters = [];
  List<Json> _allActivities = [];
  bool _loading = false;
  String? _error;

  // ── Filters ──
  String _selectedChapterId = 'all';
  final String _selectedLevel = 'all';
  String _selectedLockFilter = 'all';
  bool _chapterOpen = false;

  // ── Unlock modal ──
  final _unlockModal = ValueNotifier<_UnlockModal>(const _UnlockModal());
  List<dynamic> _unlockingIds = [];

  // ── Toast ──
  _PlayToast _toast = const _PlayToast();
  Timer? _toastTimer;
  final _toastPortal = OverlayPortalController();

  // ── XP ──
  dynamic _xp;

  /// Taps inside the filters bar / dropdown don't close it (`@click.stop`).
  final Object _filtersTapGroup = Object();

  MathZoroController get _mz => ref.read(mathZoroProvider.notifier);

  @override
  void initState() {
    super.initState();
    _initFromContext();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _toastPortal.show();
      _mounted();
    });
  }

  void _initFromContext() {
    final ctx =
        ref.read(zslActivityProvider.notifier).selectedActivityContext ?? const <String, dynamic>{};
    _selectedClassId = jsTruthy(ctx['classId']) ? jsStr(ctx['classId'])! : '';
    _selectedSubjectId = jsTruthy(ctx['subjectId']) ? jsStr(ctx['subjectId'])! : '';
    _selectedClassName = jsTruthy(ctx['className']) ? jsDisplay(ctx['className']) : '';
    _selectedSubjectName = jsTruthy(ctx['subjectName']) ? jsDisplay(ctx['subjectName']) : '';
  }

  Future<void> _mounted() async {
    await _mz.ready;
    if (!mounted) return;
    setState(_initFromContext);
    await _autoSelectAndLoad();
  }

  @override
  void dispose() {
    _toastTimer?.cancel();
    // `_unlockModal` is not disposed: an open modal route (root navigator)
    // may outlive the page and still listens to it.
    super.dispose();
  }

  // ── computed ──

  Object get _instituteId {
    final id = ref.read(sessionProvider).userInfo?.instituteId;
    return jsTruthy(id) ? id! : '';
  }

  String get _langId => jsStr(ref.read(sessionProvider).language.id)!;

  List<({String value, String label})> get _chapterOptions => [
    (value: 'all', label: 'All Chapters'),
    for (final ch in _chapters)
      (value: jsStr(ch['id']) ?? 'undefined', label: jsDisplay(ch['name'])),
  ];

  String get _selectedChapterLabel {
    for (final c in _chapterOptions) {
      if (c.value == _selectedChapterId) return c.label.isEmpty ? 'All Chapters' : c.label;
    }
    return 'All Chapters';
  }

  List<Json> get _filteredActivities => filterPlayActivities(
    _allActivities,
    chapterId: _selectedChapterId,
    level: _selectedLevel,
    lock: _selectedLockFilter,
  );

  int get _lockedCount => _allActivities.where((a) => !jsTruthy(a['is_unlocked'])).length;
  int get _unlockedCount => _allActivities.where((a) => jsTruthy(a['is_unlocked'])).length;

  // ── methods ──

  void _selectChapter(String val) {
    setState(() {
      _selectedChapterId = val;
      _chapterOpen = false;
    });
    if (val != 'all') {
      _fetchChapterActivities(val);
    } else {
      // Re-fetch all chapters
      _fetchData();
    }
  }

  Future<void> _fetchChapterActivities(String chapterId) async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final chIdx = _chapters.indexWhere((ch) => jsStr(ch['id']) == chapterId);
      if (chIdx == -1) return;
      final chapter = _chapters[chIdx];

      final topics = await _mz.getZslLinks(_instituteId, chapter['id'], _langId);
      final activities = playFlattenTopics(topics, chapter['id'], chIdx + 1);

      // Replace only this chapter's activities, keep others
      _allActivities = [
        ..._allActivities.where((a) => (jsStr(a['chapter_id']) ?? 'undefined') != chapterId),
        ...activities,
      ];
    } catch (e) {
      debugPrint('$e');
      _error = 'Failed to load chapter activities.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _closeAll() {
    if (_chapterOpen) setState(() => _chapterOpen = false);
  }

  /// `a || b || ''`, displayed.
  static String _or(List<dynamic> values) {
    for (final v in values) {
      if (jsTruthy(v)) return jsDisplay(v);
    }
    return '';
  }

  // ── Bootstrap — always runs, re-fetches class + subject on refresh ──
  Future<void> _autoSelectAndLoad() async {
    if (!jsTruthy(_instituteId)) {
      setState(() => _error = 'Missing institute information.');
      return;
    }

    try {
      setState(() {
        _loading = true;
        _error = null;
        _allActivities = [];
        _chapters = [];
        _selectedChapterId = 'all';
      });

      // `store.selectedClass` (the sessionStorage 'selected_class' fallback is
      // covered by mathZoroProvider's persistence).
      Json? selectedClass = ref.read(mathZoroProvider).selectedClass;

      // Single-class login fallback
      if (!jsTruthy(selectedClass?['zsl_class_id'])) {
        final ui = ref.read(sessionProvider).userInfo;
        final fallbackClassId = jsTruthy(ui?.mathzoroClassId)
            ? ui?.mathzoroClassId
            : ui?.zslClassId;
        if (jsTruthy(fallbackClassId)) selectedClass = {'zsl_class_id': fallbackClassId};
      }

      if (!jsTruthy(selectedClass?['zsl_class_id'])) {
        _error = 'No class selected.';
        return;
      }

      _selectedClassId = jsStr(selectedClass!['zsl_class_id'])!;

      // Find MATHPLAY course matching this class
      final mathPlayCourse = findZoneCourse(
        ref.read(mathZoroProvider).mathZoroCourses,
        'mathplay',
        _selectedClassId,
      );
      if (!jsTruthy(mathPlayCourse?['zsl_subject_id'])) {
        _error = 'No MathPlay course found for this class.';
        return;
      }

      // Load subjects for selected class
      final subjects = await _mz.getAllSubjects(_instituteId, _selectedClassId);
      if (subjects is! List || subjects.isEmpty) {
        _error = 'No subjects found.';
        return;
      }

      final selectedSubject = findZoneSubject(subjects, mathPlayCourse!['zsl_subject_id']);
      if (selectedSubject == null) {
        _error =
            'MathPlay subject not found. Subject Id = ${jsDisplay(mathPlayCourse['zsl_subject_id'])}';
        return;
      }

      _selectedSubjectId = zoneSubjectId(selectedSubject);
      _selectedSubjectName = _or([selectedSubject['name'], mathPlayCourse['title']]);

      await _fetchData();
      await _fetchXp();
    } catch (e) {
      debugPrint('$e');
      _error = 'Failed to load class/subject data.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Fetch all chapters then all activities in parallel ──
  Future<void> _fetchData() async {
    if (!jsTruthy(_instituteId) || _selectedClassId.isEmpty || _selectedSubjectId.isEmpty) {
      setState(() => _error = 'Missing context. Please go back and select a subject.');
      return;
    }
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final chs = await _mz.getallchpaters(_instituteId, _selectedClassId, _selectedSubjectId);
      _chapters = chs is List ? chs.map(asMap).whereType<Map<String, dynamic>>().toList() : [];

      final langId = _langId;
      final results = await Future.wait([
        for (var chIdx = 0; chIdx < _chapters.length; chIdx++)
          _settledActivities(_chapters[chIdx], chIdx, langId),
      ]);

      // Replace allActivities entirely so only this subject's activities show
      _allActivities = [for (final r in results) ...r];
    } catch (e) {
      debugPrint('$e');
      _error = 'Failed to load. Please try again.';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// One `Promise.allSettled` entry — a rejected chapter contributes nothing.
  Future<List<Json>> _settledActivities(Json ch, int chIdx, String langId) async {
    try {
      final topics = await _mz.getZslLinks(_instituteId, ch['id'], langId);
      return playFlattenTopics(topics, ch['id'], chIdx + 1);
    } catch (e) {
      debugPrint('$e');
      return const [];
    }
  }

  // ── Unlock flow ──────────────────────────────────────────────

  void _onUnlockRequest(Json activity) {
    _unlockModal.value = _UnlockModal(visible: true, activity: activity);
    _showUnlockModal();
  }

  void _closeUnlockModal() {
    if (_unlockModal.value.loading) return;
    _unlockModal.value = const _UnlockModal();
  }

  Future<void> _confirmUnlock() async {
    final activity = _unlockModal.value.activity;
    if (activity == null) return;
    final mz = _mz;

    _unlockModal.value = _unlockModal.value.copyWith(loading: true, error: null);

    final id = activity['id'];
    if (!_unlockingIds.contains(id)) setState(() => _unlockingIds = [..._unlockingIds, id]);

    try {
      await mz.unlockZslActivity(jsStr(id) ?? 'undefined');

      final idx = _allActivities.indexWhere((a) => a['id'] == id);
      if (idx != -1) {
        final next = [..._allActivities];
        next[idx] = {...next[idx], 'is_unlocked': true};
        if (mounted) setState(() => _allActivities = next);
      }

      // Refresh the navbar tickets
      mz.dispatchTicketsUpdated();

      _unlockModal.value = _unlockModal.value.copyWith(visible: false);

      // `$emit('unlock-requested', activity)` — no listener on the route.

      _showToast(
        'success',
        '"${jsTruthy(activity['name']) ? jsDisplay(activity['name']) : 'Activity'}" is now unlocked and ready to play!',
      );
    } catch (err) {
      _unlockModal.value = _unlockModal.value.copyWith(error: unlockErrorMessage(err));
    } finally {
      _unlockModal.value = _unlockModal.value.copyWith(loading: false);
      if (mounted) {
        setState(() => _unlockingIds = _unlockingIds.where((x) => x != id).toList());
      }
    }
  }

  void _showToast(String type, String message) {
    _toastTimer?.cancel();
    if (!mounted) return;
    setState(() => _toast = _PlayToast(visible: true, type: type, message: message));
    _toastTimer = Timer(const Duration(seconds: 4), _hideToast);
  }

  /// `toast.visible = false`.
  void _hideToast() {
    if (!mounted) return;
    setState(() => _toast = _PlayToast(type: _toast.type, message: _toast.message));
  }

  // ── Navigation ───────────────────────────────────────────────

  void _goToActivity(Json activity) {
    if (!jsTruthy(activity['is_unlocked'])) return;
    final store = ref.read(zslActivityProvider.notifier);
    store.setActivityContext({
      ...?store.selectedActivityContext,
      'classId': _selectedClassId,
      'className': _selectedClassName,
      'subjectId': _selectedSubjectId,
      'subjectName': _selectedSubjectName,
      'chapterId': activity['chapter_id'],
      'topicId': activity['topic_id'],
      'topicName': activity['topic_name'],
      'topicImage': jsTruthy(activity['file_path']) ? activity['file_path'] : '',
      'activityId': activity['id'],
      'returnPath': '/newlayout/playzone',
    });
    context.go('/newlayout/studentactivitypage?fromPlayZone=1');
  }

  Future<void> _fetchXp() async {
    if (_selectedClassId.isEmpty) return;
    try {
      final res = await _mz.getZslXp(_selectedClassId);
      if (mounted) setState(() => _xp = parseXp(res));
    } catch (err) {
      debugPrint('Failed to load ZSL XP: $err');
      if (mounted) setState(() => _xp = 0);
    }
  }

  // ── template ──

  /// `font-[Nunito,sans-serif]`.
  TextStyle _t(double size, FontWeight weight, Color? color, {double? height, double? spacing}) =>
      GoogleFonts.nunito(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
        letterSpacing: spacing,
      );

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    // `@click="closeAll"` on the root: taps outside the filters bar / the
    // dropdown close it (see [_filters]).
    return Stack(
      children: [
        Positioned.fill(
          child: ColoredBox(color: dark ? const Color(0xFF0D0D2B) : const Color(0xFFF0F0F8)),
        ),
        // Dot grid background
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: ZoneDotGridPainter(
                color: dark
                    ? Colors.white.withValues(alpha: 0.04)
                    : Colors.black.withValues(alpha: 0.06),
                spacing: 32,
                radius: 1,
              ),
            ),
          ),
        ),
        // Ambient glow blobs
        Positioned.fill(
          child: IgnorePointer(
            child: ClipRect(
              child: Stack(
                children: [
                  Positioned(
                    top: -200 - 120,
                    right: -100 - 120,
                    child: ZoneGlow(
                      color: dark ? Tw.purple700 : Tw.purple300,
                      diameter: 600,
                      blur: 120,
                      opacity: 0.2,
                    ),
                  ),
                  Positioned(
                    bottom: 0 - 100,
                    left: -100 - 100,
                    child: ZoneGlow(
                      color: dark ? Tw.indigo600 : Tw.indigo200,
                      diameter: 400,
                      blur: 100,
                      opacity: 0.1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(dark),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [_filters(dark), _content(dark)],
                  ),
                ),
              ),
            ],
          ),
        ),
        // `fixed bottom-6 left-1/2 -translate-x-1/2`: centred in the window,
        // not in the content area beside the sidebar.
        OverlayPortal(
          controller: _toastPortal,
          overlayLocation: OverlayChildLocation.rootOverlay,
          overlayChildBuilder: (context) =>
              Positioned(left: 0, right: 0, bottom: 24, child: _toastView(context.isDark)),
          child: const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ══════════ HEADER ══════════
  Widget _header(bool dark) {
    final badges = <Widget>[
      if (_xp != null)
        _Badge(
          icon: BootstrapIcons.lightning_charge_fill,
          label: '${jsDisplay(_xp)} XP',
          fg: dark ? Tw.cyan400 : Tw.cyan700,
          bg: dark ? op(Tw.cyan400, 0.1) : Tw.cyan50,
          border: dark ? op(Tw.cyan400, 0.25) : Tw.cyan200,
          shadow: !dark,
          text: _t,
        ),
      _ActivitiesBadge(count: _filteredActivities.length, dark: dark, text: _t),
      if (_lockedCount > 0)
        _Badge(
          icon: BootstrapIcons.lock_fill,
          label: '$_lockedCount locked',
          fg: dark ? Tw.yellow400 : Tw.amber700,
          bg: dark ? op(Tw.yellow400, 0.1) : Tw.amber50,
          border: dark ? op(Tw.yellow400, 0.25) : Tw.amber200,
          text: _t,
        ),
      if (_unlockedCount > 0)
        _Badge(
          icon: BootstrapIcons.unlock_fill,
          label: '$_unlockedCount unlocked',
          fg: dark ? Tw.green400 : Tw.green700,
          bg: dark ? op(Tw.green400, 0.1) : Tw.green50,
          border: dark ? op(Tw.green400, 0.25) : Tw.green200,
          text: _t,
        ),
    ];

    return ClipRect(
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(
          decoration: BoxDecoration(
            color: dark ? const Color(0xF20D0D2B) : Colors.white.withValues(alpha: 0.95),
            border: Border(
              bottom: BorderSide(
                color: dark
                    ? Colors.white.withValues(alpha: 0.07)
                    : Colors.black.withValues(alpha: 0.07),
              ),
            ),
            // shadow-sm (the theme's value)
            boxShadow: dark ? null : AppShadows.sm,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: LayoutBuilder(
            builder: (context, c) => Row(
              children: [
                // Left: Logo + Subject Name
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: dark
                                ? [op(Tw.yellow400, 0.2), op(Tw.amber500, 0.2)]
                                : const [Tw.yellow400, Tw.amber500],
                          ),
                          border: dark ? Border.all(color: op(Tw.yellow400, 0.3)) : null,
                          // shadow-lg (the theme's value; `shadow-amber-200`
                          // has no effect)
                          boxShadow: AppShadows.lg,
                        ),
                        child: Icon(
                          BootstrapIcons.play_fill,
                          size: 18,
                          color: dark ? Tw.yellow400 : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'NOW PLAYING',
                              style: _t(
                                10,
                                FontWeight.w900,
                                dark ? Tw.yellow400 : Tw.yellow600,
                                height: 1,
                                spacing: 2.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Only show selectedSubjectName — no generic fallback
                            Text(
                              _selectedSubjectName,
                              maxLines: 1,
                              softWrap: false,
                              overflow: TextOverflow.ellipsis,
                              style: _t(
                                16,
                                FontWeight.w900,
                                dark ? Colors.white : Tw.gray900,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right: Badges
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: (c.maxWidth - 120).clamp(0, double.infinity),
                  ),
                  child: Wrap(
                    alignment: WrapAlignment.end,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: badges,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ══════════ FILTERS BAR ══════════
  Widget _filters(bool dark) {
    final dropdown = _ChapterDropdown(
      open: _chapterOpen,
      options: _chapterOptions,
      selected: _selectedChapterId,
      label: _selectedChapterLabel,
      tapGroup: _filtersTapGroup,
      text: _t,
      onToggle: () => setState(() => _chapterOpen = !_chapterOpen),
      onSelect: _selectChapter,
    );
    final pill = _LockFilterPill(
      selected: _selectedLockFilter,
      text: _t,
      onSelect: (v) => setState(() => _selectedLockFilter = v),
    );

    return TapRegion(
      groupId: _filtersTapGroup,
      onTapOutside: (_) => _closeAll(),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: LayoutBuilder(
          builder: (context, c) {
            // `flex-1 min-w-[180px]` + the shrink-0 pill (≈ 232px) wrap together.
            if (c.maxWidth >= 180 + 12 + 232) {
              return Row(
                children: [
                  Expanded(child: dropdown),
                  const SizedBox(width: 12),
                  pill,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                dropdown,
                const SizedBox(height: 12),
                Align(alignment: Alignment.centerLeft, child: pill),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _content(bool dark) {
    // ══════════ LOADING ══════════
    if (_loading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 128),
        child: Column(
          children: [
            ZoneRingSpinner(
              size: 56,
              stroke: 4,
              track: op(Tw.yellow400, dark ? 0.2 : 0.3),
              head: Tw.yellow400,
            ),
            const SizedBox(height: 20),
            Text(
              'Loading activities…',
              style: _t(
                14,
                FontWeight.w700,
                dark ? Tw.slate500 : Tw.gray400,
                height: 20 / 14,
                spacing: 0.35,
              ),
            ),
          ],
        ),
      );
    }

    // ══════════ ERROR ══════════
    final error = _error;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 128),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: dark ? op(Tw.red500, 0.1) : Tw.red50,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: dark ? op(Tw.red500, 0.25) : Tw.red200),
              ),
              child: const Icon(
                BootstrapIcons.exclamation_triangle_fill,
                size: 24,
                color: Tw.red400,
              ),
            ),
            const SizedBox(height: 16),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 320),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: _t(14, FontWeight.w700, Tw.red400, height: 20 / 14),
              ),
            ),
            const SizedBox(height: 16),
            ZonePress(
              onTap: _autoSelectAndLoad,
              builder: (context, hover, pressed) => AnimatedScale(
                scale: pressed ? 0.95 : 1,
                duration: const Duration(milliseconds: 150),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: hover ? Tw.yellow300 : Tw.yellow400,
                    // rounded-xl (20px in this theme), shadow-lg (theme value)
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppShadows.lg,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        BootstrapIcons.arrow_clockwise,
                        size: 14,
                        color: Color(0xFF0D0D2B),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Retry',
                        style: _t(14, FontWeight.w900, const Color(0xFF0D0D2B), height: 20 / 14),
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

    final acts = _filteredActivities;

    // ══════════ EMPTY ══════════
    if (acts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 128),
        child: Column(
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: dark ? Colors.white.withValues(alpha: 0.04) : Tw.gray100,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: dark ? Colors.white.withValues(alpha: 0.07) : Tw.gray200),
              ),
              child: Icon(BootstrapIcons.inbox, size: 24, color: dark ? Tw.slate600 : Tw.gray300),
            ),
            const SizedBox(height: 12),
            Text(
              'No activities found${_selectedSubjectName.isNotEmpty ? ' for $_selectedSubjectName' : ''}',
              textAlign: TextAlign.center,
              style: _t(14, FontWeight.w900, dark ? Tw.slate500 : Tw.gray400, height: 20 / 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Try adjusting your filters',
              style: _t(12, FontWeight.w600, dark ? Tw.slate600 : Tw.gray400, height: 16 / 12),
            ),
          ],
        ),
      );
    }

    // ══════════ CARD GRID ══════════
    final cols = context.isXl ? 4 : (context.isLg ? 3 : (context.isSm ? 2 : 1));
    const gap = 20.0;
    final rows = <Widget>[];
    for (var start = 0; start < acts.length; start += cols) {
      final cells = <Widget>[];
      for (var c = 0; c < cols; c++) {
        if (c > 0) cells.add(const SizedBox(width: gap));
        final i = start + c;
        if (i >= acts.length) {
          cells.add(const Expanded(child: SizedBox.shrink()));
          continue;
        }
        final act = acts[i];
        cells.add(
          Expanded(
            child: _PlayActivityCard(
              key: ValueKey(act['id'] ?? i),
              activity: act,
              unlocking: _unlockingIds.contains(act['id']),
              text: _t,
              onPlay: () => _goToActivity(act),
              onUnlock: () => _onUnlockRequest(act),
            ),
          ),
        );
      }
      if (rows.isNotEmpty) rows.add(const SizedBox(height: gap));
      rows.add(
        IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: cells),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 48),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: rows),
    );
  }
}
