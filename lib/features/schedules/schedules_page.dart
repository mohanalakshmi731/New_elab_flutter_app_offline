import 'dart:async';
import 'dart:math' as math;

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/network/upload_file.dart';
import '../../core/realtime/echo_client.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/external_link.dart';
import '../../core/utils/files.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/html_editor.dart';
import '../../widgets/web_content_view.dart';
import '../common/lms_handoff.dart';
import '../institutes/institute_widgets.dart' show FilePickField;
import '../users/users_widgets.dart' show FormGrid, GridSpan, ShadCard;
import 'recordings_view.dart';
import 'schedule_exam_list_view.dart';
import 'schedule_exam_view.dart';
import 'schedules_controller.dart';
import 'schedules_logic.dart';

part 'schedules_realtime.dart';
part 'schedules_list.dart';
part 'schedules_detail.dart';
part 'schedules_create.dart';
part 'schedules_dialogs.dart';
part 'schedules_widgets.dart';

/// Port of `src/pages/schedules/schedules.vue` — the live / upcoming class
/// schedules of the institute (`/schedules`, inside the eLabs shell).
///
/// * Tabs: On Going (next schedules, live participants via the presence
///   channel) and Today / This Week / … / OverAll (grouped by class → batch,
///   with the attendance list).
/// * Per schedule: Basic Info, Class Reference, Class / Home Assignments
///   (HTML / PDF / URL / LMS content), Quiz (`ScheduleExamListView`,
///   `ScheduleExamView`) and the class chat (Echo presence channel
///   `schedule.{institute}.{schedule}`).
/// * Create Schedules drawer (class → batches → days → slots → preview),
///   edit / delete schedule, Recordings (`RecordingsView`).
/// * Start / Join / Full Client open the Zoom meeting in the Zoom app or the
///   browser (`openZoomMeeting`) instead of the web's embedded Meeting SDK.
class SchedulesPage extends ConsumerStatefulWidget {
  const SchedulesPage({super.key});

  @override
  ConsumerState<SchedulesPage> createState() => _SchedulesPageState();
}

/// The dialogs / drawer of the template (`v-model:open` flags).
enum _Dlg {
  drawer,
  slot,
  edit,
  preview,
  viewClassAct,
  editClassAct,
  classAct,
  homeAct,
  viewHomeAct,
  editHomeAct,
  classRef,
  viewClassRef,
  editClassRef,
  quiz,
  deleteConfirm,
}

class _DialogHandle {
  BuildContext? ctx;
}

/// `deleteConfirmDialog`
class _DeleteConfirm {
  const _DeleteConfirm({this.title = '', this.message = '', this.pendingId, this.type = ''});
  final String title;
  final String message;
  final Object? pendingId;

  /// `'reference' | 'classActivity' | 'homeActivity' | 'schedule' | ''`
  final String type;
}

/// `classReferenceForm` / `classActivityForm` / `homeActivityForm`.
class _ActivityForm {
  final title = TextEditingController();
  final url = TextEditingController();
  String type = 'html';
  String content = '';
  UploadFile? file;

  /// Bumped on every reset so the HTML editor reloads its content.
  int version = 0;

  void reset({String title = '', String type = 'html', String content = '', String url = ''}) {
    this.title.text = title;
    this.url.text = url;
    this.type = type;
    this.content = content;
    file = null;
    version++;
  }

  void dispose() {
    title.dispose();
    url.dispose();
  }
}

/// `editForm`
class _EditForm {
  Object? id;
  String startDate = '';
  String startTime = '';
  final duration = TextEditingController(text: '0');
  String classType = '';
  final title = TextEditingController();
  String? instructorId;
  String batchId = '';
  String subjectId = '';

  void dispose() {
    duration.dispose();
    title.dispose();
  }
}

/// `form` (create drawer + the class / batch filter).
class _CreateForm {
  String classType = '';

  /// `string[]` from the drawer's multi-select, a single id string from the
  /// filter's select.
  Object batch = <String>[];
  List<String> days = [];
  final slots = TextEditingController();
  final minutesPerDay = TextEditingController();
  String startDate = '';
  String endDate = '';
  String classType2 = '';

  List<String> get batchList => batch is List ? [for (final b in batch as List) '$b'] : const [];

  void reset() {
    classType = '';
    batch = <String>[];
    days = [];
    slots.text = '';
    minutesPerDay.text = '';
    startDate = '';
    endDate = '';
    classType2 = '';
  }

  void dispose() {
    slots.dispose();
    minutesPerDay.dispose();
  }
}

/// `viewedActivity` / `viewedReference`
typedef _Viewed = ({Object? type, String url, String content});

class _SchedulesPageState extends ConsumerState<SchedulesPage> {
  SchedulesController get _ctrl => ref.read(schedulesControllerProvider.notifier);
  SchedulesState get _store => ref.read(schedulesControllerProvider);
  SessionState get _session => ref.read(sessionProvider);
  String get _role => _session.role;
  UserInfo? get _userInfo => _session.userInfo;
  late final EchoClient _echo;

  /// Bumped on every state change so open dialogs rebuild with the page.
  final _rev = ValueNotifier<int>(0);

  // ── data() ───────────────────────────────────────────────────────────────
  _DeleteConfirm _deleteConfirm = const _DeleteConfirm();
  Object? _activeexamid = '';
  String _examactiveBatchId = '';
  String _examactiveCourseId = '';
  bool _recordings = false;
  Object? _selectedReferenceId;
  bool _isHomeActivityLms = false;
  Object? _selectedHomeActivityLms = '';
  bool _isClassActivityLms = false;
  Object? _selectedClassActivityLms = '';
  bool _isLmsMode = false;
  Object? _selectedLmsContent = '';
  final _classReferenceForm = _ActivityForm();
  _Viewed? _viewedReference;
  String _activetabs = 'BasicInfo';
  String _openAccordion = '';
  final _search = TextEditingController();
  Timer? _scheduleInterval;
  int? _selectedPreviewIndex;
  SlotDetail? _editingSlot;
  final _slotTitle = TextEditingController();
  final _previewTitle = TextEditingController();
  List<PreviewSlot> _previewSlots = [];
  List<SJson> _ongoingSchedules = [];
  final _editForm = _EditForm();
  bool _isLoading = false;
  String _activeTab = 'ongoing';
  int? _selectedSlotIndex;
  List<int> _slotsArray = [];
  List<SlotDetail> _slotDetails = [];
  Object? _selectedYear;
  int _drawerPage = 1;
  final _form = _CreateForm();
  SJson _getScheduleForm = const {
    'startDate': '',
    'endDate': '',
    'duration': 0,
    'classType': '',
    'title': '',
    'instructorId': '',
    'batchId': '',
    'subjectId': '',
  };
  final _classActivityForm = _ActivityForm();
  final _homeActivityForm = _ActivityForm();
  Object? _activeScheduleId;
  List<SJson> _classActivities = [];
  List<SJson> _classreference = [
    {'id': 0, 'name': '', 'review_status': false, 'type': '', 'url': '', 'content': ''},
  ];
  _Viewed? _viewedActivity;
  List<SJson> _homeActivities = [];
  List<SJson> _onlineUsers = [];
  List<String> _joinedStudentIds = [];
  List<ChatMessage> _chatMessages = [];
  final _chatInput = TextEditingController();
  // ignore: unused_field
  bool _chatEnabled = false;
  List<dynamic> _attendanceRecordsLocal = [];

  /// Open/closed state of each class → batch group's accordion on the
  /// non-ongoing tabs (each group is its own `<Accordion type="single">`).
  final Map<int, String> _groupAccordion = {};

  // realtime (`joinedChannels`, `messageHandlers`, `publicChannel`)
  final Set<String> _joinedChannels = {};
  final Map<String, List<StreamSubscription<dynamic>>> _channelSubs = {};

  /// Presence members per channel (`id → user_info`), so `.leaving` can hand
  /// out the member's info like Echo does.
  final Map<String, Map<String, SJson>> _presenceMembers = {};
  String? _publicChannel;

  @override
  void initState() {
    super.initState();
    _echo = ref.read(echoClientProvider);
    _form.slots.addListener(_onSlotsText);
    _search.addListener(() => _set(() {}));
    // Store / session changes must reach the open dialogs too.
    ref.listenManual(schedulesControllerProvider, (_, _) => _rev.value++);
    ref.listenManual(sessionProvider, (_, _) => _rev.value++);
    ref.listenManual(lmsHandoffProvider, (_, _) => _rev.value++);
    Future.microtask(() {
      if (!mounted) return;
      // watch: activeTab (immediate) — runs before mounted() on the web.
      _onActiveTabChanged(_activeTab);
      _mountedHook();
    });
  }

  @override
  void dispose() {
    _beforeUnmount();
    _loaderEntry
      ?..remove()
      ..dispose();
    _loaderEntry = null;
    _rev.dispose();
    _classReferenceForm.dispose();
    _classActivityForm.dispose();
    _homeActivityForm.dispose();
    _editForm.dispose();
    _form.dispose();
    _search.dispose();
    _slotTitle.dispose();
    _previewTitle.dispose();
    _chatInput.dispose();
    super.dispose();
  }

  // ── plumbing ─────────────────────────────────────────────────────────────

  /// `setState` that also refreshes open dialogs and the loader.
  void _set(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
    _rev.value++;
    _syncLoader();
  }

  /// Runs [fn] ignoring errors — the API client already toasted them and the
  /// web only logged them (or left the promise unhandled).
  Future<void> _guard(Future<void> Function() fn) async {
    try {
      await fn();
    } catch (_) {}
  }

  /// `<Loader :loading="isLoading" />` is `fixed` above every dialog on the
  /// web, so it lives in the root overlay here.
  OverlayEntry? _loaderEntry;

  void _syncLoader() {
    final want = _isLoading && mounted;
    if (want == (_loaderEntry != null)) return;
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncLoader());
      return;
    }
    if (want) {
      final entry = OverlayEntry(builder: (_) => const LoadingOverlay(loading: true, child: SizedBox.expand()));
      Overlay.of(context, rootOverlay: true).insert(entry);
      _loaderEntry = entry;
    } else {
      _loaderEntry
        ?..remove()
        ..dispose();
      _loaderEntry = null;
    }
  }

  void _setLoading(bool v) => _set(() => _isLoading = v);

  final Map<_Dlg, _DialogHandle> _dialogs = {};

  bool _isOpen(_Dlg d) => _dialogs.containsKey(d);

  /// Opens dialog [d] (no-op when already open). Its content is rebuilt on
  /// every page state change; [_onDialogClosed] runs however it closes.
  Future<void> _openDialog(_Dlg d, WidgetBuilder build) async {
    if (_isOpen(d) || !mounted) return;
    final handle = _DialogHandle();
    _dialogs[d] = handle;
    Widget content(BuildContext ctx) {
      handle.ctx = ctx;
      return ListenableBuilder(listenable: _rev, builder: (c, _) => build(c));
    }

    if (d == _Dlg.drawer) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        // `<DrawerOverlay>`: `bg-black/80`.
        barrierColor: Colors.black.withValues(alpha: 0.8),
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        builder: content,
      );
    } else {
      await showAppDialog<void>(context, builder: content);
    }
    if (identical(_dialogs[d], handle)) _dialogs.remove(d);
    if (mounted) _onDialogClosed(d);
  }

  /// `isXOpen = false`
  void _closeDialog(_Dlg d) {
    final handle = _dialogs.remove(d);
    final ctx = handle?.ctx;
    if (ctx == null || !ctx.mounted) return;
    final route = ModalRoute.of(ctx);
    if (route == null) return;
    if (route.isCurrent) {
      Navigator.of(ctx).pop();
    } else {
      Navigator.of(ctx).removeRoute(route);
    }
  }

  /// The watchers on the dialog flags.
  void _onDialogClosed(_Dlg d) {
    switch (d) {
      case _Dlg.drawer:
        // watch: openDrawer(false)
        _set(() => _selectedYear = '');
        _resetFilter();
      case _Dlg.quiz:
        // watch: isQuizDialogOpen(false)
        _guard(_fetchExam);
        _fetchBasicInfo(schString(_activeScheduleId));
      default:
        _set(() {});
    }
  }

  // ── watchers ─────────────────────────────────────────────────────────────

  /// `activeTab` setter (v-model of the tabs / select).
  void _setActiveTab(String v) {
    if (v == _activeTab) return;
    _set(() {
      _activeTab = v;
      // The tab contents (and their accordions) are re-mounted.
      _groupAccordion.clear();
    });
    _onActiveTabChanged(v);
  }

  /// watch: activeTab — loads the tab's schedules.
  Future<void> _onActiveTabChanged(String val) async {
    _setLoading(true);
    final now = DateTime.now();
    try {
      if (val == 'ongoing') {
        try {
          final response = await _ctrl.getNextSchedules();
          _assignOngoingSchedules(ongoingFrom(response));
        } catch (_) {
          _assignOngoingSchedules([]);
        }
        return;
      }
      if (val == 'OverAll') {
        try {
          await _ctrl.getSchedules({});
          // The web then ran `this.schedules = this.schedules.filter(sch =>
          // sch.status?.toLowerCase() === 'OverAll')` — a write to a read-only
          // `mapState` computed, i.e. a no-op: every schedule stays listed.
          return;
        } catch (_) {
          // falls through to the plain fetch below, like the web
        }
      }
      await _ctrl.getSchedules(scheduleFilters(scheduleRange(val, now), _form.batch));
    } catch (_) {
      // unhandled on the web; the API client already toasted
    } finally {
      _setLoading(false);
    }
  }

  /// `this.ongoingSchedules = …` — the (non-deep) watcher re-opens the first
  /// schedule and loads its details on the next tick.
  void _assignOngoingSchedules(List<SJson> v) {
    _set(() => _ongoingSchedules = v);
    if (v.isEmpty) return;
    Future.microtask(() {
      if (!mounted) return;
      _set(() => _openAccordion = _itemKey(v.first['id']));
      _fetchBasicInfo(v.first['id']);
    });
  }

  bool _batchWatchQueued = false;

  /// `form.batch` changed (deep watcher; several changes in one tick run it once).
  void _touchFormBatch() {
    if (_batchWatchQueued) return;
    _batchWatchQueued = true;
    scheduleMicrotask(() {
      _batchWatchQueued = false;
      if (mounted) _formBatchWatcher();
    });
  }

  /// watch: 'form.batch' — reloads the active tab (without the this-week /
  /// this-month ranges, exactly like the web).
  Future<void> _formBatchWatcher() async {
    final val = _activeTab;
    if (val.isEmpty) return;
    _setLoading(true);
    try {
      if (val == 'ongoing') {
        try {
          final response = await _ctrl.getNextSchedules();
          _assignOngoingSchedules(ongoingFrom(response));
        } catch (_) {
          _assignOngoingSchedules([]);
        }
        return;
      }
      await _ctrl.getSchedules(scheduleFilters(batchWatcherRange(val, DateTime.now()), _form.batch));
    } catch (_) {
      // unhandled on the web
    } finally {
      _setLoading(false);
    }
  }

  String _lastSlots = '';

  /// watch: 'form.slots' — one card per slot; `slotDetails` only grows.
  void _onSlotsText() {
    final v = _form.slots.text;
    if (v == _lastSlots) return;
    _lastSlots = v;
    final n = slotCount(v);
    _set(() {
      _slotsArray = List.generate(n, (i) => i);
      while (_slotDetails.length < n) {
        _slotDetails.add(SlotDetail());
      }
    });
  }

  // ── lifecycle ────────────────────────────────────────────────────────────

  /// `mounted()`
  Future<void> _mountedHook() async {
    _setLoading(true);
    try {
      await _ctrl.getClasses('published');
      await _ctrl.getBatches();
      await _ctrl.getNextSchedules();
    } catch (_) {
      // The web's mounted() rejected here (loader left on, no polling).
      _setLoading(false);
      return;
    }
    if (!mounted) return;
    _setLoading(false);
    _scheduleInterval = Timer.periodic(const Duration(seconds: 10), (_) => _pollOngoing());

    final instituteId = _userInfo?.instituteId;
    if (jsTruthy(_activeScheduleId) && instituteId != null) {
      await _loadChatMessages(schString(_activeScheduleId));
      if (!mounted) return;
      _joinPresenceChannel(instituteId, schNumber(_activeScheduleId));
    }
  }

  /// The 10 s refresh of the ongoing list (no watcher: the open schedule stays).
  Future<void> _pollOngoing() async {
    if (!mounted || _activeTab != 'ongoing') return;
    final response = await _ctrl.getNextSchedules();
    if (!mounted) return;
    _set(() => _ongoingSchedules = ongoingFrom(response));
  }

  /// `beforeUnmount()` — leaves every presence channel and stops the timers.
  void _beforeUnmount() {
    for (final name in _joinedChannels.toList()) {
      for (final s in _channelSubs.remove(name) ?? const <StreamSubscription<dynamic>>[]) {
        s.cancel();
      }
      try {
        _echo.leave(name);
      } catch (_) {}
    }
    _joinedChannels.clear();
    _presenceMembers.clear();
    _scheduleInterval?.cancel();
    _scheduleInterval = null;
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  String _itemKey(Object? id) => 'item-${id == null ? 'undefined' : schString(id)}';

  List<SJson> get _courses => schMaps(_session.classDetails?.toJson()['courses']);

  List<SJson> get _classCoursesDropdown => schMaps(ref.read(lmsHandoffProvider)['classCoursesDropdown']);

  SJson? _findContent(Object? id) {
    for (final c in _classCoursesDropdown) {
      if (c['id'] == id) return c;
    }
    return null;
  }

  /// `Number(x) || 0` style numbers from a number input (`''` when empty).
  Object _numOrEmpty(String text) {
    if (text.trim().isEmpty) return '';
    final n = schNumber(text);
    return n.isNaN ? '' : n;
  }

  // ── delete confirmation ──────────────────────────────────────────────────

  void _deleteScheduleItem(Object? id) => _openDeleteConfirm(id, 'schedule');
  void _deleteClassReference(Object? id) => _openDeleteConfirm(id, 'reference');
  void _deleteClassActivity(Object? id) => _openDeleteConfirm(id, 'classActivity');

  void _openDeleteConfirm(Object? id, String type) {
    const labels = {
      'reference': (
        'Delete Class Reference',
        'Are you sure you want to delete this reference? This action cannot be undone.'
      ),
      'classActivity': (
        'Delete Class Assignment',
        'Are you sure you want to delete this class assignment? This action cannot be undone.'
      ),
      'homeActivity': (
        'Delete Home Assignment',
        'Are you sure you want to delete this home assignment? This action cannot be undone.'
      ),
      'schedule': (
        'Delete Schedule',
        'Are you sure you want to delete this schedule? This action cannot be undone.'
      ),
    };
    final l = labels[type]!;
    _set(() => _deleteConfirm = _DeleteConfirm(title: l.$1, message: l.$2, pendingId: id, type: type));
    _openDialog(_Dlg.deleteConfirm, _buildDeleteConfirmDialog);
  }

  Future<void> _confirmDelete() async {
    final pendingId = _deleteConfirm.pendingId;
    final type = _deleteConfirm.type;
    if (!jsTruthy(pendingId) || type.isEmpty) return;
    _closeDialog(_Dlg.deleteConfirm);
    _setLoading(true);
    try {
      final id = schString(pendingId);
      if (type == 'reference') {
        await _ctrl.deleteclassScheduleReference(id);
        _set(() => _classreference = [for (final r in _classreference) if (r['id'] != pendingId) r]);
        await _fetchBasicInfo(schString(_activeScheduleId));
      } else if (type == 'classActivity') {
        await _ctrl.deleteclassScheduleActivity(id);
        _set(() => _classActivities = [for (final a in _classActivities) if (a['id'] != pendingId) a]);
        await _fetchBasicInfo(schString(_activeScheduleId));
      } else if (type == 'homeActivity') {
        await _ctrl.deleteclassScheduleActivity(id);
        _set(() => _homeActivities = [for (final a in _homeActivities) if (a['id'] != pendingId) a]);
        await _fetchBasicInfo(schString(_activeScheduleId));
      } else if (type == 'schedule') {
        await _ctrl.deleteSchedule(id);
        await _reloadSchedules();
      }
    } catch (_) {
      AppToast.error('Failed to delete. Please try again.');
    } finally {
      _set(() {
        _isLoading = false;
        _deleteConfirm = const _DeleteConfirm();
      });
    }
  }

  // ── schedules ────────────────────────────────────────────────────────────

  /// `reloadSchedules()` — re-fetches the active tab.
  Future<void> _reloadSchedules() async {
    final val = _activeTab;
    if (val == 'ongoing') {
      final response = await _ctrl.getNextSchedules();
      _assignOngoingSchedules(ongoingFrom(response));
      return;
    }
    await _ctrl.getSchedules(scheduleFilters(scheduleRange(val, DateTime.now()), _form.batch));
  }

  /// `resetFilter()`
  void _resetFilter() {
    _set(() {
      _selectedYear = null;
      _form.batch = <String>[];
    });
    _touchFormBatch();
  }

  /// `onYearChange(value)` — the class's batches, instructors and courses.
  Future<void> _onYearChange(Object? value) async {
    if (value == null) return;
    final classId = schNumber(value);
    try {
      await _ctrl.getBatches(classId);
      await _ctrl.getInstructorsdropdown(classId);
      await _ctrl.fetchschedulesClassDetails(classId);
    } catch (_) {}
    _set(() {});
  }

  /// `fetchBasicInfo(scheduleId)` — participants / attendance, the schedule's
  /// references, assignments and quiz, the class's instructors and courses,
  /// the chat history; then joins the schedule's presence channel.
  Future<void> _fetchBasicInfo(Object? scheduleId) async {
    _setLoading(true);
    _ctrl.setActiveSchedule(schNumber(scheduleId));
    _set(() => _activeScheduleId = scheduleId);
    final id = schString(scheduleId);
    try {
      if (_activeTab == 'ongoing') {
        await _ctrl.fetchscheduleStudents(id);
        _set(() => _joinedStudentIds = []);
      } else {
        final attendanceResponse = await _ctrl.scheduleAttendance(id);
        _set(() => _attendanceRecordsLocal = flattenAttendance(attendanceResponse));
      }

      final schedule = asMap(await _ctrl.getScheduleById(id));
      // The web read `schedule.exam_id`, `schedule.batch.exam_batch_id` and
      // `schedule.course.id` unguarded: a missing object ended the method there.
      if (schedule == null) return;
      _set(() => _activeexamid = schedule['exam_id']);
      final batch = asMap(schedule['batch']);
      if (batch == null) return;
      _set(() => _examactiveBatchId = batch['exam_batch_id']?.toString() ?? '');
      final course = asMap(schedule['course']);
      if (course == null) return;
      _set(() {
        _examactiveCourseId = course['id']?.toString() ?? '';
        _classreference = [...schMaps(schedule['references'])];
        _classActivities = schMaps(dig(schedule, ['activities', 'class']));
        _homeActivities = schMaps(dig(schedule, ['activities', 'home']));
      });

      final classId = dig(batch, ['classes', 'id']);
      if (!jsTruthy(classId)) {
        debugPrint('Class ID not found');
        return;
      }
      await _ctrl.getInstructorsdropdown(classId);
      await _ctrl.fetchschedulesClassDetails(classId!);

      String s(Object? v) => jsTruthy(v) ? '$v' : '';
      _set(() => _getScheduleForm = {
            'startDate': s(schedule['start_time']),
            'endDate': s(schedule['end_date']),
            'duration': jsTruthy(schedule['duration']) ? schedule['duration'] : 0,
            'classType': s(schedule['type']),
            'title': s(schedule['title']),
            'instructorId': s(schedule['instructor_id']?.toString()),
            'batchId': s(schedule['batch_id']?.toString()),
            'subjectId': s(schedule['course_id']?.toString()),
          });

      _loadChatMessages(id);
      final instituteId = _userInfo?.instituteId;
      if (instituteId != null) _joinPresenceChannel(instituteId, scheduleId);
    } catch (e) {
      debugPrint('Error fetching basic info: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// `fetchExam()` — the schedule's `exam_id` (the `'activeTab'` branch can
  /// never match, as on the web).
  Future<void> _fetchExam() async {
    if (_activetabs == 'activeTab') {
      final res = await _ctrl.getNextSchedules();
      _set(() => _activeexamid = res.isNotEmpty ? (asMap(res.first)?['exam_id']) : null);
    } else {
      final res = await _ctrl.getScheduleById(schString(_activeScheduleId));
      _set(() => _activeexamid = asMap(res)?['exam_id']);
    }
  }

  /// `onEditSchedule(scheduleId)` — loads the schedule and its class lists,
  /// then opens the Edit Schedule dialog.
  Future<void> _onEditSchedule(Object? scheduleId) async {
    try {
      _setLoading(true);
      final schedule = asMap(await _ctrl.getScheduleById(schString(scheduleId))) ?? const <String, dynamic>{};
      final classId = dig(schedule, ['batch', 'classes', 'id']);
      if (jsTruthy(classId)) {
        await _ctrl.getBatches(classId);
        await _ctrl.getInstructorsdropdown(classId);
        await _ctrl.fetchschedulesClassDetails(classId!);
      }
      _set(() {
        _editForm
          ..id = schedule['id']
          ..startDate = schedule['start_date']?.toString() ?? ''
          ..startTime = schedule['start_time']?.toString() ?? ''
          ..classType = schedule['type']?.toString() ?? ''
          ..instructorId = schedule['instructor_id']?.toString() ?? ''
          ..batchId = schedule['batch_id']?.toString() ?? ''
          ..subjectId = schedule['course_id']?.toString() ?? '';
        _editForm.duration.text = vText(schedule['duration'] ?? 0);
        _editForm.title.text = schedule['title']?.toString() ?? '';
      });
      _openDialog(_Dlg.edit, _buildEditDialog);
    } catch (_) {
      // unhandled on the web
    } finally {
      _setLoading(false);
    }
  }

  /// `submitEditForm()`
  Future<void> _submitEditForm() async {
    if (!jsTruthy(_editForm.id)) {
      AppToast.info('Schedule ID is missing!');
      return;
    }
    try {
      _setLoading(true);
      final t = _editForm.startTime;
      final payload = <String, dynamic>{
        'start_date': _editForm.startDate,
        'start_time': t.isNotEmpty ? t.substring(0, math.min(5, t.length)) : '00:00',
        'duration': _numOrEmpty(_editForm.duration.text),
        'instructor_id': jsTruthy(_editForm.instructorId) ? _editForm.instructorId : null,
        'type': _editForm.classType,
        'title': _editForm.title.text,
        'course_id': jsTruthy(_editForm.subjectId) ? _editForm.subjectId : null,
      };
      await _ctrl.updateSchedule(_editForm.id!, payload);
      await _reloadSchedules();
      _closeDialog(_Dlg.edit);
    } catch (_) {
      // unhandled on the web; the dialog stays open
    } finally {
      _setLoading(false);
    }
  }

  // ── Zoom ─────────────────────────────────────────────────────────────────

  /// Opens the meeting from `/schedule/start`'s `data` in the Zoom app (or
  /// the browser) — replaces the web's embedded Meeting SDK client.
  Future<bool> _openMeeting(SJson meeting) => openZoomMeeting(
        joinUrl: jsTruthy(meeting['meeting_link']) ? '${meeting['meeting_link']}' : null,
        meetingNumber: schString(meeting['meeting_number']),
        password: jsTruthy(meeting['passcode']) ? '${meeting['passcode']}' : null,
      );

  /// `handleStart(scheduleId)` (Start / Join). The meeting opens externally;
  /// students then get their attendance marked, join the presence channel
  /// and load the chat, like after the web's SDK join.
  Future<void> _handleStart(Object? scheduleId) async {
    try {
      final res = await _ctrl.startSchedule(schString(scheduleId));
      final meeting = asMap(asMap(res)?['data']);
      if (!jsTruthy(meeting?['meeting_number'])) {
        AppToast.error('Meeting info missing');
        return;
      }
      final opened = await _openMeeting(meeting!);
      if (!opened || !mounted) return;

      // Only students continue (the web `return`ed here for everyone else).
      if (_userInfo?.role != Role.student) return;
      try {
        final sid = _userInfo?.studentId;
        await _ctrl.markScheduleAttendance(schString(scheduleId), null, sid == null ? null : '$sid');
        AppToast.success('Attendance recorded');
      } catch (e) {
        debugPrint('Attendance API failed: $e');
      }

      final instituteId = _userInfo?.instituteId;
      final numericScheduleId = schNumber(scheduleId);
      _set(() {
        _activeScheduleId = numericScheduleId;
        _chatEnabled = true;
        _chatMessages = [];
      });
      _joinPresenceChannel(instituteId, numericScheduleId);
      final messages = await _ctrl.getScheduleMessages(schString(numericScheduleId));
      if (messages is List) {
        final myId = _userInfo?.id;
        _set(() => _chatMessages = [for (final m in schMaps(messages)) chatFromStart(m, myId)]);
      }
    } catch (e) {
      debugPrint('Error starting meeting: $e');
    }
  }

  /// `openFullClient(scheduleId)` — the web stored the meeting for its
  /// `/zoom-full` page and opened it in a new tab; here the meeting opens in
  /// the Zoom app / browser.
  Future<void> _openFullClient(Object? scheduleId) async {
    try {
      final res = await _ctrl.startSchedule(schString(scheduleId));
      final meeting = asMap(asMap(res)?['data']);
      if (!jsTruthy(meeting?['meeting_number'])) {
        AppToast.error('No meeting number found');
        return;
      }
      _ctrl.setZoomMeetingData({
        'meetingNumber': meeting!['meeting_number'],
        'signature': meeting['signature'],
        'passcode': meeting['passcode'],
        'userName': meeting['user_name'],
        'zak': dig(meeting, ['zak', 'token']),
      });
      await _openMeeting(meeting);
    } catch (_) {
      // unhandled on the web
    }
  }

  // ── class references ─────────────────────────────────────────────────────

  /// `openClassReferenceDialog()` (ongoing tab).
  void _openClassReferenceDialog() {
    _set(() {
      _classReferenceForm.reset();
      _selectedReferenceId = null;
    });
    _openDialog(_Dlg.classRef, _buildClassReferenceDialog);
  }

  /// The other tabs' button: `isClassReferenceOpen = true`.
  void _showClassReferenceDialog() => _openDialog(_Dlg.classRef, _buildClassReferenceDialog);

  /// `submitClassReference()`
  Future<void> _submitClassReference() async {
    try {
      if (_isLmsMode) {
        final selected = _findContent(_selectedLmsContent);
        await _ctrl.createScheduleReferenceActivity({
          'schedule_id': schString(_activeScheduleId),
          'content_id': _selectedLmsContent,
          'name': jsTruthy(selected?['name']) ? selected!['name'] : 'LMS Content',
          'type': 'course_content',
        });
        _closeReferenceDialog();
        return;
      }
      final f = _classReferenceForm;
      final payload = <String, dynamic>{
        'schedule_id': _activeScheduleId,
        'name': f.title.text,
        'type': f.type,
        if (f.type == 'html') 'html_content': f.content,
        if (f.type == 'url') 'url': f.url.text,
        if (f.type == 'pdf') 'file': f.file,
      };
      final res = await _ctrl.createScheduleReferenceActivity(payload);
      final created = asMap(res);
      if (jsTruthy(res) && created != null) _set(() => _classreference = [created, ..._classreference]);
      await _fetchBasicInfo(schString(_activeScheduleId));
      _closeReferenceDialog();
    } catch (e) {
      debugPrint('Failed: $e');
    }
  }

  /// `closeDialog()` of the Class Reference dialog.
  void _closeReferenceDialog() {
    _closeDialog(_Dlg.classRef);
    _set(() {
      _isLmsMode = false;
      _classReferenceForm.reset();
      _selectedLmsContent = '';
    });
  }

  /// `editClassReference(ref)`
  void _editClassReference(SJson ref) {
    _set(() {
      _isLmsMode = false;
      if (ref['type'] == 'course_content') {
        _isLmsMode = true;
        final cid = ref['content_id'];
        final ccId = dig(ref, ['course_content', 'id']);
        _selectedLmsContent = jsTruthy(cid) ? cid : (jsTruthy(ccId) ? ccId : '');
      } else {
        _classReferenceForm.reset(
          title: vText(ref['name']),
          type: jsTruthy(ref['type']) ? '${ref['type']}' : 'html',
          content: jsTruthy(ref['content']) ? '${ref['content']}' : '',
          url: jsTruthy(ref['url']) ? '${ref['url']}' : '',
        );
      }
      _selectedReferenceId = ref['id'];
    });
    _openDialog(_Dlg.editClassRef, _buildEditClassReferenceDialog);
  }

  /// `viewClassReference(ref)`
  void _viewClassReference(SJson ref) {
    _set(() => _viewedReference = viewedFields(ref));
    _openDialog(_Dlg.viewClassRef, (c) => _buildViewDialog(c, 'View Class Reference', _viewedReference, true));
  }

  /// `updateClassReference()`
  Future<void> _updateClassReference() async {
    if (!jsTruthy(_selectedReferenceId)) {
      AppToast.error('Reference ID missing!');
      return;
    }
    if (!jsTruthy(_activeScheduleId)) {
      AppToast.error('Schedule ID missing!');
      return;
    }
    _setLoading(true);
    try {
      if (_isLmsMode) {
        final selected = _findContent(_selectedLmsContent);
        await _ctrl.updateScheduleReference(schString(_selectedReferenceId), {
          'schedule_id': schString(_activeScheduleId),
          'name': jsTruthy(selected?['name']) ? selected!['name'] : 'LMS Content',
          'type': 'course_content',
          'content_id': _selectedLmsContent,
        });
        _closeDialog(_Dlg.editClassRef);
        _set(() {
          _isLmsMode = false;
          _selectedLmsContent = '';
        });
        await _fetchBasicInfo(schString(_activeScheduleId));
        return;
      }
      final f = _classReferenceForm;
      final payload = <String, dynamic>{
        'schedule_id': schString(_activeScheduleId),
        'name': f.title.text,
        'type': f.type,
        if (f.type == 'html') 'html_content': f.content,
        if (f.type == 'url') 'url': f.url.text,
      };
      if (f.type == 'pdf') {
        if (f.file == null) {
          AppToast.error('Please select a PDF file!');
          return;
        }
        payload['file'] = f.file;
      }
      await _ctrl.updateScheduleReference(schString(_selectedReferenceId), payload);
      _closeDialog(_Dlg.editClassRef);
      await _fetchBasicInfo(schString(_activeScheduleId));
    } catch (e) {
      debugPrint('Update failed: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ── class / home assignments ─────────────────────────────────────────────

  /// `openClassActivityDialog()` (ongoing tab).
  void _openClassActivityDialog() {
    _set(() {
      _isClassActivityLms = false;
      _selectedClassActivityLms = '';
      _classActivityForm.reset();
      _selectedReferenceId = null;
    });
    _closeDialog(_Dlg.editClassAct);
    _openDialog(_Dlg.classAct, (c) => _buildActivityDialog(c, home: false));
  }

  /// The other tabs' button: `isClassActivityOpen = true`.
  void _showClassActivityDialog() => _openDialog(_Dlg.classAct, (c) => _buildActivityDialog(c, home: false));

  /// `isHomeActivityOpen = true`
  void _showHomeActivityDialog() => _openDialog(_Dlg.homeAct, (c) => _buildActivityDialog(c, home: true));

  /// `submitClassActivity()` / `submitHomeActivity()`
  Future<void> _submitActivity({required bool home}) async {
    if (!jsTruthy(_activeScheduleId)) {
      AppToast.info('Schedule ID is missing!');
      return;
    }
    final lms = home ? _isHomeActivityLms : _isClassActivityLms;
    final selectedLms = home ? _selectedHomeActivityLms : _selectedClassActivityLms;
    final f = home ? _homeActivityForm : _classActivityForm;
    final activityType = home ? 'home' : 'class';
    final dlg = home ? _Dlg.homeAct : _Dlg.classAct;
    _setLoading(true);
    try {
      if (lms) {
        final selected = _findContent(selectedLms);
        await _ctrl.createScheduleActivity({
          'schedule_id': schString(_activeScheduleId),
          'activity_type': activityType,
          'content_id': selectedLms,
          'name': jsTruthy(selected?['name']) ? selected!['name'] : 'LMS Content',
          'type': 'course_content',
        });
        _set(() {
          if (home) {
            _isHomeActivityLms = false;
            _selectedHomeActivityLms = '';
          } else {
            _isClassActivityLms = false;
            _selectedClassActivityLms = '';
          }
        });
        _closeDialog(dlg);
        await _fetchBasicInfo(schString(_activeScheduleId));
        return;
      }
      final payload = <String, dynamic>{
        'schedule_id': schString(_activeScheduleId),
        'activity_type': activityType,
        'name': f.title.text,
        'type': f.type,
        if (f.type == 'html') 'html_content': f.content,
      };
      if (f.type == 'pdf') {
        if (f.file == null) {
          AppToast.info('Please select a PDF file.');
          return;
        }
        payload['file'] = f.file;
      }
      if (f.type == 'url') payload['url'] = f.url.text;
      await _ctrl.createScheduleActivity(payload);
      _set(f.reset);
      _closeDialog(dlg);
      await _fetchBasicInfo(schString(_activeScheduleId));
    } catch (_) {
      // unhandled on the web
    } finally {
      _setLoading(false);
    }
  }

  /// `updateClassActivity()` / `updateHomeActivity()`
  Future<void> _updateActivity({required bool home}) async {
    if (!jsTruthy(_selectedReferenceId)) {
      AppToast.error('Activity ID missing!');
      return;
    }
    if (!jsTruthy(_activeScheduleId)) {
      AppToast.error('Schedule ID missing!');
      return;
    }
    final lms = home ? _isHomeActivityLms : _isClassActivityLms;
    final selectedLms = home ? _selectedHomeActivityLms : _selectedClassActivityLms;
    final f = home ? _homeActivityForm : _classActivityForm;
    final activityType = home ? 'home' : 'class';
    final dlg = home ? _Dlg.editHomeAct : _Dlg.editClassAct;
    _setLoading(true);
    try {
      if (lms) {
        final selected = _findContent(selectedLms);
        await _ctrl.updateScheduleActivity(schString(_selectedReferenceId), {
          'schedule_id': schString(_activeScheduleId),
          'activity_type': activityType,
          'name': jsTruthy(selected?['name']) ? selected!['name'] : 'LMS Content',
          'type': 'course_content',
          'content_id': selectedLms,
        });
        _closeDialog(dlg);
        _set(() {
          if (home) {
            _isHomeActivityLms = false;
            _selectedHomeActivityLms = '';
          } else {
            _isClassActivityLms = false;
            _selectedClassActivityLms = '';
          }
        });
        await _fetchBasicInfo(schString(_activeScheduleId));
        return;
      }
      final payload = <String, dynamic>{
        'schedule_id': schString(_activeScheduleId),
        'activity_type': activityType,
        'name': f.title.text,
        'type': f.type,
        if (f.type == 'html') 'html_content': f.content,
        if (f.type == 'url') 'url': f.url.text,
      };
      if (f.type == 'pdf') {
        if (f.file == null) {
          AppToast.error('Please select a PDF file!');
          return;
        }
        payload['file'] = f.file;
      }
      await _ctrl.updateScheduleActivity(schString(_selectedReferenceId), payload);
      _closeDialog(dlg);
      await _fetchBasicInfo(schString(_activeScheduleId));
    } catch (_) {
      // unhandled on the web
    } finally {
      _setLoading(false);
    }
  }

  /// `viewClassAct(item)` / `viewHomeAct(item)`
  void _viewActivity(SJson item, {required bool home}) {
    _set(() => _viewedActivity = viewedFields(item));
    _openDialog(
      home ? _Dlg.viewHomeAct : _Dlg.viewClassAct,
      (c) => _buildViewDialog(c, home ? 'View Home Assignments' : 'View Class Assignments', _viewedActivity, false),
    );
  }

  /// `editClassActivity(activity)` / `editHomeActivity(activity)` — LMS links
  /// reload the class's courses first.
  Future<void> _editActivity(SJson activity, {required bool home}) async {
    _set(() {
      _selectedReferenceId = activity['id'];
      if (home) {
        _isHomeActivityLms = false;
      } else {
        _isClassActivityLms = false;
      }
    });
    final dlg = home ? _Dlg.editHomeAct : _Dlg.editClassAct;
    Widget build(BuildContext c) => _buildEditActivityDialog(c, home: home);
    if (activity['type'] == 'course_content') {
      final cid = activity['content_id'];
      final ccId = dig(activity, ['course_content', 'id']);
      final selected = jsTruthy(cid) ? cid : (jsTruthy(ccId) ? ccId : '');
      _set(() {
        if (home) {
          _isHomeActivityLms = true;
          _selectedHomeActivityLms = selected;
        } else {
          _isClassActivityLms = true;
          _selectedClassActivityLms = selected;
        }
      });
      try {
        final classId = _session.classDetails?.id;
        await _ctrl.fetchschedulesClassDetails(schNumber(jsTruthy(classId) ? classId : 0));
      } catch (_) {
        return; // unhandled on the web: the dialog never opened
      }
      _openDialog(dlg, build);
      return;
    }
    _set(() => (home ? _homeActivityForm : _classActivityForm).reset(
          title: vText(activity['name']),
          type: jsTruthy(activity['type']) ? '${activity['type']}' : 'html',
          content: jsTruthy(activity['content']) ? '${activity['content']}' : '',
          url: jsTruthy(activity['url']) ? '${activity['url']}' : '',
        ));
    _openDialog(dlg, build);
  }

  /// `<input type="file" accept="application/pdf">`
  Future<void> _pickPdf(_ActivityForm f) async {
    final file = await pickUploadFile(allowedExtensions: const ['pdf']);
    if (file == null) {
      // The reference form's handler cleared the file on an empty selection.
      if (identical(f, _classReferenceForm)) _set(() => f.file = null);
      return;
    }
    _set(() => f.file = file);
  }

  // ── quiz ─────────────────────────────────────────────────────────────────

  /// `openQuizDialog()`
  void _openQuizDialog() => _openDialog(_Dlg.quiz, _buildQuizDialog);

  /// `openRecordingDrawer()`
  void _openRecordingDrawer() => _set(() => _recordings = true);

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.watch(schedulesControllerProvider);
    ref.watch(sessionProvider);
    ref.watch(lmsHandoffProvider);
    final dark = context.isDark;
    final sm = context.isSm;
    return ColoredBox(
      color: dark ? AppColors.dashboardDark : Colors.transparent,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: sm ? 16 : 8, vertical: sm ? 24 : 16),
        child: _PageCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: 24),
              if (_recordings) const RecordingsView() else _buildTabs(context),
            ],
          ),
        ),
      ),
    );
  }
}
