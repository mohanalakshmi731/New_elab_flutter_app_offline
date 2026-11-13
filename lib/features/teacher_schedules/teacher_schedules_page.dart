import 'dart:async';

import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/upload_file.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/external_link.dart';
import '../../core/utils/files.dart';
import '../../core/utils/json.dart';
import '../../core/utils/toast.dart';
import '../../data/models/session.dart';
import '../../data/services/js_compat.dart';
import '../../state/providers.dart';
import '../../widgets/app_dialog.dart';
import '../../widgets/app_loader.dart';
import '../../widgets/form_fields.dart';
import '../../widgets/html_editor.dart';
import '../../widgets/web_content_view.dart';
import '../common/lms_handoff.dart';
import '../institutes/institute_widgets.dart' show FilePickField;
import '../schedules/recordings_view.dart';
import '../schedules/schedule_exam_list_view.dart';
import '../schedules/schedule_exam_view.dart';
import 'teacher_schedules_controller.dart';
import 'teacher_schedules_logic.dart';
import 'teacher_schedules_widgets.dart';

part 'teacher_schedules_list.dart';
part 'teacher_schedules_create.dart';
part 'teacher_schedules_dialogs.dart';

/// Port of `src/components/new_ui_student_teacher_for_both_labs/teacherschedules.vue`
/// (component `TeacherSchedules`, route `/teacherschedules`).
///
/// Store state lives in [TeacherSchedulesController]; the component's
/// `data()` lives here. The schedule lists, the create drawer and the
/// reference / assignment dialogs are `part`s of this library.
///
/// Zoom: the web embedded the Zoom Meeting SDK ("Start" / "Join") or opened
/// `/zoom-full` in a new window ("Full"); both now open the meeting in the
/// installed Zoom app (or the browser) through [openZoomMeeting].
class TeacherSchedulesPage extends ConsumerStatefulWidget {
  const TeacherSchedulesPage({super.key});

  @override
  ConsumerState<TeacherSchedulesPage> createState() => _TeacherSchedulesPageState();
}

/// `classReferenceForm` / `classActivityForm` / `homeActivityForm`.
class _ContentForm {
  final title = TextEditingController();
  final url = TextEditingController();
  String type = 'html';
  String content = '';
  UploadFile? file;

  void reset({String title = '', String type = 'html', String content = '', String url = ''}) {
    this.title.text = title;
    this.type = type;
    this.content = content;
    this.url.text = url;
    file = null;
  }

  void dispose() {
    title.dispose();
    url.dispose();
  }
}

/// A dialog / drawer opened with `v-model:open`; [ctx] is its route context.
class _DialogRef {
  BuildContext? ctx;
}

class _TeacherSchedulesPageState extends ConsumerState<TeacherSchedulesPage> {
  // ── data() ──
  Object? _openAccordionId;
  Object? _openOtherAccordionId;
  bool _recordings = false;
  bool _isLoading = false;
  String _activeTab = 'ongoing';
  String _activetabs = 'BasicInfo';
  String _search = '';
  List<dynamic> _ongoingSchedules = [];
  Timer? _scheduleInterval;
  Object? _activeScheduleId;
  Object? _activeexamid = '';
  String _examactiveBatchId = '';
  String _examactiveCourseId = '';
  Map<String, Object?> _getScheduleForm = const {'startDate': '', 'duration': 0, 'classType': '', 'title': ''};

  // editForm
  Object? _editId;
  String _editStartDate = '';
  String _editStartTime = '';
  final _editDuration = TextEditingController(text: '0');
  String _editClassType = '';
  final _editTitle = TextEditingController();
  String _editInstructorId = '';
  String _editSubjectId = '';

  int _drawerPage = 1;
  bool _isSubmitting = false;
  String? _selectedYear;
  String? _filterBatchId;
  List<int> _slotsArray = [];
  List<Json> _slotDetails = [];
  int? _selectedSlotIndex;
  Json? _editingSlot;
  final _slotTitle = TextEditingController();
  List<Json> _previewSlots = [];
  int? _selectedPreviewIndex;
  final _previewTitle = TextEditingController();

  // form
  String _formClassType = '';
  List<String> _formBatch = [];
  List<String> _formDays = [];
  final _formSlots = TextEditingController();
  String _lastSlots = '';
  final _formMinutes = TextEditingController();
  DateTime? _formStartDate;
  DateTime? _formEndDate;

  // deleteConfirmDialog
  String _deleteTitle = '';
  String _deleteMessage = '';
  Object? _deletePendingId;
  String _deleteType = '';

  List<Json> _classreference = [];
  final _classReferenceForm = _ContentForm();
  ({String type, String url, String content})? _viewedReference;
  Object? _selectedReferenceId;
  bool _isLmsMode = false;
  Object? _selectedLmsContent = '';

  List<Json> _classActivities = [];
  final _classActivityForm = _ContentForm();
  bool _isClassActivityLms = false;
  Object? _selectedClassActivityLms = '';

  List<Json> _homeActivities = [];
  final _homeActivityForm = _ContentForm();
  bool _isHomeActivityLms = false;
  Object? _selectedHomeActivityLms = '';
  ({String type, String url, String content})? _viewedActivity;

  List<Json> _chatMessages = [];
  final _chatInput = TextEditingController();
  List<Json> _onlineUsers = [];
  final List<String> _joinedStudentIds = [];
  final Set<String> _joinedChannels = {};
  final Map<String, Json> _presenceMembers = {};
  final List<StreamSubscription<dynamic>> _echoSubs = [];
  List<dynamic> _attendanceRecordsLocal = [];

  /// Re-renders the open dialogs / drawer (they read this state, like the
  /// web's reactive template).
  final _tick = ValueNotifier<int>(0);
  final Map<String, _DialogRef> _dialogs = {};

  TeacherSchedulesController get _ctrl => ref.read(teacherSchedulesControllerProvider.notifier);
  TeacherSchedulesState get _store => ref.read(teacherSchedulesControllerProvider);
  SessionState get _session => ref.read(sessionProvider);
  String get _role => _session.role;
  Object? get _myId => _session.userInfo?.id;

  /// `classDetails?.courses || []`
  List<dynamic> get _courses => asList(_session.classDetails?.extra['courses']);

  /// The store's `classCoursesDropdown`.
  List<dynamic> get _classCoursesDropdown => asList(ref.read(lmsHandoffProvider)['classCoursesDropdown']);

  /// `setState` for the `part` extensions; also refreshes open dialogs.
  void _set(VoidCallback fn) {
    if (!mounted) return;
    setState(fn);
    _tick.value++;
  }

  @override
  void initState() {
    super.initState();
    void bump(_, _) => _tick.value++;
    ref.listenManual(teacherSchedulesControllerProvider, bump);
    ref.listenManual(sessionProvider, bump);
    ref.listenManual(lmsHandoffProvider, bump);
    // `watch: activeTab` (immediate) + `mounted()`.
    Future.microtask(() {
      _onActiveTabChanged(_activeTab);
      _mounted();
    });
  }

  @override
  void dispose() {
    // `beforeUnmount()`
    _scheduleInterval?.cancel();
    for (final s in _echoSubs) {
      s.cancel();
    }
    final echo = ref.read(echoClientProvider);
    for (final ch in _joinedChannels) {
      try {
        echo.leave(ch);
      } catch (_) {}
    }
    _joinedChannels.clear();
    _editDuration.dispose();
    _editTitle.dispose();
    _formSlots.dispose();
    _formMinutes.dispose();
    _slotTitle.dispose();
    _previewTitle.dispose();
    _classReferenceForm.dispose();
    _classActivityForm.dispose();
    _homeActivityForm.dispose();
    _chatInput.dispose();
    _tick.dispose();
    super.dispose();
  }

  // ── dialog plumbing (`v-model:open`) ─────────────────────────────────────

  /// Opens dialog [name] (no-op when already open); [onClosed] runs however
  /// it is closed (the web's `watch: isXOpen(false)`).
  Future<void> _openDialog(String name, WidgetBuilder builder, {VoidCallback? onClosed, bool sheet = false}) async {
    if (_dialogs.containsKey(name)) return;
    final handle = _DialogRef();
    _dialogs[name] = handle;
    Widget wrap(BuildContext ctx) {
      handle.ctx = ctx;
      return ListenableBuilder(listenable: _tick, builder: (c, _) => builder(c));
    }

    if (sheet) {
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        // `max-h-[95vh]` loses to DrawerContent's
        // `data-[vaul-drawer-direction=bottom]:max-h-[80vh]`.
        constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.8),
        builder: wrap,
      );
    } else {
      await showAppDialog<void>(context, builder: wrap);
    }
    if (identical(_dialogs[name], handle)) _dialogs.remove(name);
    if (mounted) onClosed?.call();
  }

  /// `isXOpen = false`
  void _closeDialog(String name) {
    final ctx = _dialogs.remove(name)?.ctx;
    if (ctx == null || !ctx.mounted) return;
    final route = ModalRoute.of(ctx);
    if (route == null) return;
    final nav = Navigator.of(ctx);
    if (route.isCurrent) {
      nav.pop();
    } else if (route.isActive) {
      nav.removeRoute(route);
    }
  }

  // ── lifecycle ────────────────────────────────────────────────────────────

  /// `mounted()` — the loader is always cleared (the web left it on when a
  /// request failed).
  Future<void> _mounted() async {
    _set(() => _isLoading = true);
    try {
      await _ctrl.getClasses('published');
      await _ctrl.getBatches();
      await _ctrl.getNextSchedules();
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
    if (!mounted) return;
    _scheduleInterval = Timer.periodic(const Duration(minutes: 10), (_) async {
      if (_activeTab != 'ongoing') return;
      final response = await _ctrl.getNextSchedules();
      // `splice` — mutates in place, so the `ongoingSchedules` watcher does not fire.
      _set(() => _ongoingSchedules = ongoingFrom(response));
    });
  }

  /// `watch: activeTab` (immediate).
  Future<void> _onActiveTabChanged(String val) async {
    _set(() => _isLoading = true);
    if (val == 'ongoing') {
      try {
        final response = await _ctrl.getNextSchedules();
        _set(() => _ongoingSchedules = ongoingFrom(response));
      } catch (_) {
        _set(() => _ongoingSchedules = []);
      }
      _set(() => _isLoading = false);
      // The `ongoingSchedules` watcher runs after this handler (nextTick).
      _onOngoingSchedulesAssigned();
      return;
    }
    try {
      await _ctrl.getSchedules(scheduleFilters(scheduleRange(val, DateTime.now()), _filterBatchId));
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  void _setActiveTab(String val) {
    if (val == _activeTab) return;
    _set(() => _activeTab = val);
    _onActiveTabChanged(val);
  }

  /// `watch: filterBatchId` (it has no `thismonth` branch, like the web).
  Future<void> _setFilterBatchId(String? val) async {
    if (val == _filterBatchId) return;
    _set(() => _filterBatchId = val);
    if (_activeTab.isEmpty || _activeTab == 'ongoing') return;
    _set(() => _isLoading = true);
    try {
      await _ctrl.getSchedules(
          scheduleFilters(scheduleRange(_activeTab, DateTime.now(), withThisMonth: false), val));
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  /// `watch: ongoingSchedules` — opens the first live class.
  void _onOngoingSchedulesAssigned() {
    if (_ongoingSchedules.isEmpty) return;
    final first = asMap(_ongoingSchedules.first);
    _set(() => _openAccordionId = first?['id']);
    _fetchBasicInfo(first?['id']);
  }

  /// `prevTab()` / `nextTab()`
  void _prevTab() => _setActiveTab(prevTabOf(_activeTab));
  void _nextTab() => _setActiveTab(nextTabOf(_activeTab));

  /// `toggleAccordion(id)`
  void _toggleAccordion(Object? id) {
    if (_openAccordionId == id) {
      _set(() => _openAccordionId = null);
    } else {
      _set(() => _openAccordionId = id);
      _fetchBasicInfo(jsString(id));
    }
  }

  /// `toggleOtherAccordion(id)`
  void _toggleOtherAccordion(Object? id) {
    if (_openOtherAccordionId == id) {
      _set(() => _openOtherAccordionId = null);
    } else {
      _set(() => _openOtherAccordionId = id);
      _fetchBasicInfo(jsString(id));
    }
  }

  /// `resetFilter()`
  void _resetFilter() {
    _set(() => _selectedYear = null);
    _setFilterBatchId(null);
  }

  /// `onYearChange(value)`
  Future<void> _onYearChange(String? value) async {
    if (value == null) return;
    final classId = int.tryParse(value);
    try {
      await _ctrl.getBatches(classId);
      await _ctrl.getInstructorsdropdown(classId);
      await _ctrl.fetchschedulesClassDetails(classId ?? value);
    } catch (_) {}
  }

  /// `reloadSchedules()`
  Future<void> _reloadSchedules() async {
    final val = _activeTab;
    if (val == 'ongoing') {
      final response = await _ctrl.getNextSchedules();
      _set(() => _ongoingSchedules = ongoingFrom(response));
      _onOngoingSchedulesAssigned();
      return;
    }
    await _ctrl.getSchedules(scheduleFilters(scheduleRange(val, DateTime.now()), _filterBatchId));
  }

  // ── accordion details ────────────────────────────────────────────────────

  /// `fetchBasicInfo(scheduleId)`
  Future<void> _fetchBasicInfo(Object? scheduleId) async {
    _set(() {
      _isLoading = true;
      _activeScheduleId = scheduleId;
    });
    _ctrl.setActiveSchedule(asInt(scheduleId));
    final id = jsString(scheduleId);
    try {
      if (_activeTab == 'ongoing') {
        await _ctrl.fetchscheduleStudents(id);
        _set(() => _joinedStudentIds.clear());
      } else {
        final attendanceResponse = await _ctrl.scheduleAttendance(id);
        _set(() => _attendanceRecordsLocal = flattenAttendance(attendanceResponse));
      }
      final schedule = asMap(await _ctrl.getScheduleById(id)) ?? const <String, dynamic>{};
      // The web reads `schedule.batch.exam_batch_id` / `schedule.course.id`
      // unguarded: a schedule without batch / course stops here (kept).
      _set(() => _activeexamid = schedule['exam_id']);
      final batch = asMap(schedule['batch']);
      if (batch == null) throw StateError('schedule without batch');
      _set(() => _examactiveBatchId = batch['exam_batch_id']?.toString() ?? '');
      final course = asMap(schedule['course']);
      if (course == null) throw StateError('schedule without course');
      _set(() {
        _examactiveCourseId = course['id']?.toString() ?? '';
        _classreference = [for (final r in asList(schedule['references'])) ?asMap(r)];
        _classActivities = [for (final a in asList(dig(schedule, ['activities', 'class']))) ?asMap(a)];
        _homeActivities = [for (final a in asList(dig(schedule, ['activities', 'home']))) ?asMap(a)];
      });
      final classId = dig(batch, ['classes', 'id']);
      if (jsTruthy(classId)) {
        await _ctrl.getInstructorsdropdown(asInt(classId));
        await _ctrl.fetchschedulesClassDetails(classId as Object);
      }
      _set(() => _getScheduleForm = {
            'startDate': orJs(schedule['start_time'], ''),
            'duration': orJs(schedule['duration'], 0),
            'classType': orJs(schedule['type'], ''),
            'title': orJs(schedule['title'], ''),
          });
      await _loadChatMessages(id);
      final instituteId = _session.userInfo?.instituteId;
      if (jsTruthy(instituteId)) _joinPresenceChannel(instituteId!, id);
    } catch (_) {
    } finally {
      _set(() => _isLoading = false);
    }
  }

  /// `fetchExam()`
  Future<void> _fetchExam() async {
    try {
      final res = await _ctrl.getScheduleById(jsString(_activeScheduleId));
      _set(() => _activeexamid = asMap(res)?['exam_id']);
    } catch (_) {}
  }

  /// `activetabs = t.value; if (t.value === 'Quiz') fetchExam()`
  void _selectInnerTab(String value) {
    _set(() => _activetabs = value);
    if (value == 'Quiz') _fetchExam();
  }

  // ── chat & presence ──────────────────────────────────────────────────────

  /// `loadChatMessages(scheduleId)`
  Future<void> _loadChatMessages(String scheduleId) async {
    try {
      final messages = await _ctrl.getScheduleMessages(scheduleId);
      if (messages is List) {
        _set(() => _chatMessages = [
              for (final m in messages)
                if (asMap(m) != null) mapChatMessage(asMap(m)!, _myId),
            ]);
      }
    } catch (_) {}
  }

  /// `sendMessage()` — the message comes back through the `.message` event.
  Future<void> _sendMessage() async {
    final message = _chatInput.text.trim();
    if (message.isEmpty) return;
    try {
      await _ctrl.ScheduleMessages(jsString(_activeScheduleId), message);
      _chatInput.clear();
    } catch (_) {}
  }

  /// `joinPresenceChannel(instituteId, scheduleId)` — `presence-schedule.{institute}.{schedule}`.
  /// Echo's `.here / .joining / .leaving` are rebuilt from the raw Pusher
  /// presence events (the shared EchoClient has no presence callbacks).
  void _joinPresenceChannel(Object instituteId, Object scheduleId) {
    final channelName = 'schedule.$instituteId.${jsString(scheduleId)}';
    if (_joinedChannels.contains(channelName)) return;
    final chan = ref.read(echoClientProvider).join(channelName);
    _echoSubs
      ..add(chan.listen('.pusher:subscription_succeeded', (data) {
        final users = presenceHere(data);
        final hash = asMap(dig(data, ['presence', 'hash'])) ?? const {};
        for (final e in hash.entries) {
          final info = asMap(e.value);
          if (info != null) _presenceMembers[e.key] = info;
        }
        _set(() => _onlineUsers = users);
      }))
      ..add(chan.listen('.pusher:member_added', (data) {
        final user = presenceJoining(data);
        final uid = presenceUserId(data);
        if (user == null) return;
        if (uid != null) _presenceMembers[uid] = user;
        if (!_onlineUsers.any((u) => u['id'] == user['id'])) _set(() => _onlineUsers = [..._onlineUsers, user]);
      }))
      ..add(chan.listen('.pusher:member_removed', (data) {
        final uid = presenceUserId(data);
        final user = uid == null ? null : _presenceMembers.remove(uid);
        final userId = user != null ? user['id'] : uid;
        _set(() => _onlineUsers = _onlineUsers.where((u) => u['id'] != userId && jsString(u['id']) != uid).toList());
      }))
      ..add(chan.listen('.message', _handleIncomingMessage))
      ..add(chan.listen('.user.join', (p) {
        final id = joinPayloadId(p);
        if (jsTruthy(id) && !_joinedStudentIds.contains(jsString(id))) {
          _set(() => _joinedStudentIds.add(jsString(id)));
        }
      }))
      ..add(chan.listen('.user.left', (p) {
        final id = joinPayloadId(p);
        if (jsTruthy(id)) _set(() => _joinedStudentIds.remove(jsString(id)));
      }));
    _joinedChannels.add(channelName);
  }

  /// `handleIncomingMessage(event)`
  void _handleIncomingMessage(Map<String, dynamic>? event) {
    final msg = incomingChatMessage(event, _chatMessages, _myId);
    if (msg != null) _set(() => _chatMessages = [..._chatMessages, msg]);
  }

  // ── delete confirmation ──────────────────────────────────────────────────

  /// `openDeleteConfirm(id, type)`
  void _openDeleteConfirm(Object? id, String type) {
    const labels = {
      'reference': ('Delete Class Reference', 'Are you sure you want to delete this reference?'),
      'classActivity': ('Delete Class Assignment', 'Are you sure you want to delete this assignment?'),
      'homeActivity': ('Delete Home Assignment', 'Are you sure you want to delete this assignment?'),
      'schedule': ('Delete Schedule', 'Are you sure you want to delete this schedule?'),
    };
    _set(() {
      _deleteTitle = labels[type]?.$1 ?? '';
      _deleteMessage = labels[type]?.$2 ?? '';
      _deletePendingId = id;
      _deleteType = type;
    });
    _openDialog('delete', _buildDeleteDialog);
  }

  void _deleteScheduleItem(Object? id) => _openDeleteConfirm(id, 'schedule');
  void _deleteClassReference(Object? id) => _openDeleteConfirm(id, 'reference');
  void _deleteClassActivity(Object? id) => _openDeleteConfirm(id, 'classActivity');
  void _deleteHomeActivity(Object? id) => _openDeleteConfirm(id, 'homeActivity');

  /// `confirmDelete()`
  Future<void> _confirmDelete() async {
    final pendingId = _deletePendingId;
    final type = _deleteType;
    if (!jsTruthy(pendingId) || type.isEmpty) return;
    _closeDialog('delete');
    _set(() => _isLoading = true);
    try {
      if (type == 'reference') {
        await _ctrl.deleteclassScheduleReference(jsString(pendingId));
        _set(() => _classreference = _classreference.where((r) => r['id'] != pendingId).toList());
        await _fetchBasicInfo(jsString(_activeScheduleId));
      } else if (type == 'classActivity') {
        await _ctrl.deleteclassScheduleActivity(jsString(pendingId));
        _set(() => _classActivities = _classActivities.where((i) => i['id'] != pendingId).toList());
        await _fetchBasicInfo(jsString(_activeScheduleId));
      } else if (type == 'homeActivity') {
        await _ctrl.deleteclassScheduleActivity(jsString(pendingId));
        _set(() => _homeActivities = _homeActivities.where((i) => i['id'] != pendingId).toList());
        await _fetchBasicInfo(jsString(_activeScheduleId));
      } else if (type == 'schedule') {
        await _ctrl.deleteSchedule(jsString(pendingId));
        await _reloadSchedules();
      }
    } catch (_) {
      AppToast.error('Delete failed. Please try again.');
    } finally {
      _set(() {
        _isLoading = false;
        _deleteTitle = '';
        _deleteMessage = '';
        _deletePendingId = null;
        _deleteType = '';
      });
    }
  }

  // ── zoom ─────────────────────────────────────────────────────────────────

  /// `openFullClient(scheduleId)` — the web opened `/zoom-full` (Meeting SDK
  /// full client) in a new window; the meeting now opens in the Zoom app.
  Future<void> _openFullClient(Object? scheduleId) async {
    try {
      final res = await _ctrl.startSchedule(jsString(scheduleId));
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
    } catch (_) {}
  }

  Future<bool> _openMeeting(Json meeting) => openZoomMeeting(
        joinUrl: jsTruthy(meeting['meeting_link']) ? '${meeting['meeting_link']}' : null,
        meetingNumber: jsString(meeting['meeting_number']),
        password: jsTruthy(meeting['passcode']) ? '${meeting['passcode']}' : null,
      );

  /// `handleStart(scheduleId)` — Start (instructor) / Join (student). The web
  /// joined through the embedded Meeting SDK and drove cloud recording; here
  /// the meeting opens externally and the non-SDK steps (student attendance,
  /// presence channel, chat reload) still run.
  Future<void> _handleStart(Object? scheduleId) async {
    final id = jsString(scheduleId);
    try {
      final res = await _ctrl.startSchedule(id);
      final meeting = asMap(asMap(res)?['data']);
      if (!jsTruthy(meeting?['meeting_number'])) {
        AppToast.error('Meeting info missing');
        return;
      }
      await _openMeeting(meeting!);
      try {
        final userInfo = _session.userInfo;
        if (userInfo?.role == Role.student) {
          final studentId = jsTruthy(userInfo?.studentId) ? '${userInfo!.studentId}' : null;
          await _ctrl.markScheduleAttendance(id, null, studentId);
          AppToast.success('Attendance recorded');
        }
      } catch (_) {}
      final instituteId = _session.userInfo?.instituteId;
      if (jsTruthy(instituteId)) _joinPresenceChannel(instituteId!, asInt(id) ?? id);
      final messages = await _ctrl.getScheduleMessages(id);
      if (messages is List) {
        _set(() => _chatMessages = [
              for (final m in messages)
                if (asMap(m) != null) mapChatMessageOnStart(asMap(m)!, _myId),
            ]);
      }
    } catch (_) {}
  }

  // ── build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    ref.watch(teacherSchedulesControllerProvider);
    ref.watch(sessionProvider);
    ref.watch(lmsHandoffProvider);
    final dark = context.isDark;
    final pad = context.isLg ? 32.0 : (context.isSm ? 24.0 : 16.0);
    return LoadingOverlay(
      loading: _isLoading,
      child: ColoredBox(
        color: dark ? Tw.slate950 : Tw.slate50,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(pad),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  if (_recordings)
                    const RecordingsView()
                  else ...[
                    _buildTabNavigator(),
                    // `<Tabs class="gap-2">` + `<TabsContent class="mt-4">`.
                    const SizedBox(height: 24),
                    if (_activeTab == 'ongoing') _buildOngoingTab() else _buildOtherTab(),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
