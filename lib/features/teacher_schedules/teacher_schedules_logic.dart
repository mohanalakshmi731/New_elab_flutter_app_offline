/// Pure helpers ported from `teacherschedules.vue` (computed props, date-fns
/// ranges, slot generation, chat / presence payload mapping). Kept free of
/// Flutter so they can be unit-tested.
library;

import 'dart:convert';
import 'dart:math' as math;

import 'package:intl/intl.dart';

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';

typedef Json = Map<String, dynamic>;

typedef TabDef = ({String value, String label});

/// `allTabs`
const List<TabDef> tsAllTabs = [
  (value: 'ongoing', label: 'On Going'),
  (value: 'today', label: 'Today'),
  (value: 'thisweek', label: 'This Week'),
  (value: 'nextweek', label: 'Next Week'),
  (value: 'pastweek', label: 'Past Week'),
  (value: 'thismonth', label: 'This Month'),
  (value: 'nextmonth', label: 'Next Month'),
  (value: 'pastmonth', label: 'Past Month'),
  (value: 'OverAll', label: 'Overall'),
];

/// `innerTabs`
const List<TabDef> tsInnerTabs = [
  (value: 'BasicInfo', label: 'Basic Info'),
  (value: 'ClassReference', label: 'Class Reference'),
  (value: 'ClassActivity', label: 'Class Assignment'),
  (value: 'HomeActivity', label: 'Home Assignment'),
  (value: 'Quiz', label: 'Quiz'),
];

/// The `<SelectItem>`s of the Days multi-select.
const List<(String, String)> tsDays = [
  ('monday', 'Monday'),
  ('tuesday', 'Tuesday'),
  ('wednesday', 'Wednesday'),
  ('thursday', 'Thursday'),
  ('friday', 'Friday'),
  ('saturday', 'Saturday'),
  ('sunday', 'Sunday'),
];

/// `prevTab()`
String prevTabOf(String active) {
  final idx = tsAllTabs.indexWhere((t) => t.value == active);
  return tsAllTabs[(idx - 1 + tsAllTabs.length) % tsAllTabs.length].value;
}

/// `nextTab()`
String nextTabOf(String active) {
  final idx = tsAllTabs.indexWhere((t) => t.value == active);
  return tsAllTabs[(idx + 1) % tsAllTabs.length].value;
}

/// `currentTabLabel`
String tabLabelOf(String active) => tsAllTabs.where((t) => t.value == active).firstOrNull?.label ?? '';

// ── JS semantics ───────────────────────────────────────────────────────────

/// `a || b`
Object? orJs(Object? a, Object? b) => jsTruthy(a) ? a : b;

/// `String(v)` (`null` → `'null'`, `5.0` → `'5'`).
String jsString(Object? v) {
  if (v == null) return 'null';
  if (v is double && v.isFinite && v == v.truncateToDouble()) return v.toInt().toString();
  return '$v';
}

/// `{{ v }}` in a template: `null` renders as `''`.
String vueText(Object? v) => v == null ? '' : jsString(v);

/// `Number(v)`
double jsNumber(Object? v) {
  if (v == null) return 0;
  if (v is num) return v.toDouble();
  if (v is bool) return v ? 1 : 0;
  final s = '$v'.trim();
  if (s.isEmpty) return 0;
  return double.tryParse(s) ?? double.nan;
}

/// `Number(v) || 0` as JSON (integral values become `int`).
num jsNumberOr0(Object? v) {
  final n = jsNumber(v);
  if (n.isNaN || n == 0) return 0;
  return n == n.truncateToDouble() && n.abs() < 9007199254740992 ? n.toInt() : n;
}

/// Vue's `v-model` on `<input type="number">` (`looseToNumber`): the parsed
/// number, or the raw string when it is not a number (`''` stays `''`).
Object looseToNumber(String s) {
  final n = double.tryParse(s.trim());
  if (n == null) return s;
  return n == n.truncateToDouble() && n.abs() < 9007199254740992 ? n.toInt() : n;
}

/// `x?.toString() || ''` / `x?.toString() ?? ''`
String idString(Object? v) => v == null ? '' : jsString(v);

// ── date-fns ports (`weekStartsOn: 1`) ─────────────────────────────────────

DateTime startOfWeekMon(DateTime d) => DateTime(d.year, d.month, d.day - (d.weekday - 1));

DateTime endOfWeekMon(DateTime d) => DateTime(d.year, d.month, d.day - (d.weekday - 1) + 6);

DateTime addWeeks(DateTime d, int n) => DateTime(d.year, d.month, d.day + 7 * n, d.hour, d.minute);

DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

DateTime endOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);

/// date-fns `subMonths` (the day is clamped to the target month's length).
DateTime subMonths(DateTime d, int n) {
  final lastDay = DateTime(d.year, d.month - n + 1, 0).day;
  return DateTime(d.year, d.month - n, math.min(d.day, lastDay), d.hour, d.minute);
}

/// `format(d, 'yyyy-MM-dd')`
String ymd(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

/// The `start_date` / `end_date` filters the `activeTab` watcher and
/// `reloadSchedules()` send. `null` for `ongoing` (which calls
/// `getNextSchedules` instead); empty strings mean "no filter" (`OverAll`).
///
/// The `filterBatchId` watcher has no `thismonth` branch — pass
/// [withThisMonth] `false` to reproduce it (that tab then loads every date).
({String start, String end})? scheduleRange(String tab, DateTime now, {bool withThisMonth = true}) {
  if (tab == 'ongoing') return null;
  switch (tab) {
    case 'today':
      return (start: ymd(now), end: ymd(now));
    case 'thisweek':
      return (start: ymd(startOfWeekMon(now)), end: ymd(endOfWeekMon(now)));
    case 'thismonth':
      return withThisMonth ? (start: ymd(startOfMonth(now)), end: ymd(endOfMonth(now))) : (start: '', end: '');
    case 'nextweek':
      final d = addWeeks(now, 1);
      return (start: ymd(startOfWeekMon(d)), end: ymd(endOfWeekMon(d)));
    case 'nextmonth':
      // `addWeeks(now, 4)` — 28 days ahead, which can still be this month.
      final d = addWeeks(now, 4);
      return (start: ymd(startOfMonth(d)), end: ymd(endOfMonth(d)));
    case 'pastweek':
      final d = addWeeks(now, -1);
      return (start: ymd(startOfWeekMon(d)), end: ymd(endOfWeekMon(d)));
    case 'pastmonth':
      final d = subMonths(now, 1);
      return (start: ymd(startOfMonth(d)), end: ymd(endOfMonth(d)));
    default:
      return (start: '', end: '');
  }
}

/// `getschedules({ ...(start && { start_date }), ...(end && { end_date }),
/// ...(batch && { batch_id }) })`
Map<String, dynamic> scheduleFilters(({String start, String end})? range, String? batchId) => {
      if (range != null && range.start.isNotEmpty) 'start_date': range.start,
      if (range != null && range.end.isNotEmpty) 'end_date': range.end,
      if (batchId != null && batchId.isNotEmpty) 'batch_id': batchId,
    };

/// `toLocaleDateString('en-US', { month: 'short', day: 'numeric', year: 'numeric' }).toUpperCase()`
String _fmtTabDate(DateTime d) => DateFormat('MMM d, y', 'en_US').format(d).toUpperCase();

/// `currentTabDate`
String currentTabDate(String tab, DateTime now) {
  String range(DateTime a, DateTime b) => '${_fmtTabDate(a)} – ${_fmtTabDate(b)}';
  switch (tab) {
    case 'ongoing':
      return 'Live now';
    case 'today':
      return _fmtTabDate(now);
    case 'thisweek':
      return range(startOfWeekMon(now), endOfWeekMon(now));
    case 'nextweek':
      final d = addWeeks(now, 1);
      return range(startOfWeekMon(d), endOfWeekMon(d));
    case 'pastweek':
      final d = addWeeks(now, -1);
      return range(startOfWeekMon(d), endOfWeekMon(d));
    case 'thismonth':
      return range(startOfMonth(now), endOfMonth(now));
    case 'nextmonth':
      final d = addWeeks(now, 4);
      return range(startOfMonth(d), endOfMonth(d));
    case 'pastmonth':
      final d = subMonths(now, 1);
      return range(startOfMonth(d), endOfMonth(d));
    case 'OverAll':
      return 'All time';
    default:
      return '';
  }
}

// ── schedules list ─────────────────────────────────────────────────────────

typedef ScheduleGroup = ({String className, String batchName, List<Json> items});

/// `groupByClassBatch(schedules)` — grouped by `batch.classes.name` +
/// `batch.name`, in first-seen order. (The web throws on a schedule without
/// a batch; here the names are just empty.)
List<ScheduleGroup> groupByClassBatch(List<dynamic> schedules) {
  final map = <String, ScheduleGroup>{};
  for (final raw in schedules) {
    final item = asMap(raw);
    if (item == null) continue;
    final className = vueText(dig(item, ['batch', 'classes', 'name']));
    final batchName = vueText(dig(item, ['batch', 'name']));
    final key = '${className}__$batchName';
    map.putIfAbsent(key, () => (className: className, batchName: batchName, items: <Json>[])).items.add(item);
  }
  return map.values.toList();
}

/// `['missed','canceled'].includes(item.status?.toLowerCase())`
bool isMissedOrCanceled(Object? status) {
  final s = status?.toString().toLowerCase();
  return s == 'missed' || s == 'canceled';
}

/// `Array.isArray(response) ? response : [response]` filtered on `start_date`.
List<dynamic> ongoingFrom(Object? response) {
  final list = response is List ? response : [response];
  return [
    for (final i in list)
      if (jsTruthy(asMap(i)?['start_date'])) i,
  ];
}

/// The attendance response flattened like `fetchBasicInfo` does: an array
/// as-is, otherwise every array value of the object concatenated.
List<dynamic> flattenAttendance(Object? response) {
  if (response is List) return [...response];
  final m = asMap(response);
  if (m == null) return [];
  return [
    for (final v in m.values)
      if (v is List) ...v,
  ];
}

/// `formatAttendanceTime(raw)` — `toLocaleString('en-IN', { timeZone:
/// 'Asia/Kolkata', hour: '2-digit', minute: '2-digit' })`, e.g. `02:30 pm`.
String formatAttendanceTime(Object? raw) {
  if (!jsTruthy(raw)) return '-';
  var iso = '$raw';
  if (!iso.contains('T') && !iso.endsWith('Z')) iso = '${iso.replaceFirst(' ', 'T')}Z';
  final parsed = DateTime.tryParse(iso);
  if (parsed == null) return 'Invalid Date';
  final ist = parsed.toUtc().add(const Duration(hours: 5, minutes: 30));
  return DateFormat('hh:mm a', 'en_US').format(ist).toLowerCase();
}

/// `new Date(x).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })`
String localTime(Object? raw) {
  final parsed = raw == null ? null : DateTime.tryParse('$raw');
  if (parsed == null) return 'Invalid Date';
  return DateFormat('hh:mm a', 'en_US').format(parsed.toLocal());
}

// ── chat ───────────────────────────────────────────────────────────────────

String _userName(Object? user) {
  final u = asMap(user);
  return '${u?['first_name'] ?? ''} ${u?['last_name'] ?? ''}'.trim();
}

/// `loadChatMessages()` item → `{ id, sender, text, time, from }`.
Json mapChatMessage(Json m, Object? myId) {
  final isMe = jsString(m['user_id']) == jsString(myId);
  final user = asMap(m['user']);
  final name = _userName(user);
  return {
    'id': m['id'],
    'sender': isMe
        ? 'You'
        : (name.isNotEmpty ? name : (jsTruthy(user?['email']) ? '${user!['email']}' : 'User #${vueTextOrUndefined(m['user_id'])}')),
    'text': m['message'],
    'time': localTime(m['created_at']),
    'from': isMe ? 'user' : 'other',
  };
}

/// The mapping `handleStart()` uses after joining (`user.full_name || email`).
Json mapChatMessageOnStart(Json m, Object? myId) {
  final user = asMap(m['user']);
  return {
    'id': m['id'],
    'sender': jsTruthy(user?['full_name'])
        ? '${user!['full_name']}'
        : (jsTruthy(user?['email']) ? '${user!['email']}' : 'Unknown'),
    'text': m['message'],
    'time': localTime(m['created_at']),
    'from': user?['id'] != null && user!['id'] == myId ? 'user' : 'other',
  };
}

/// Template-literal coercion: `undefined` / `null` stay visible.
String vueTextOrUndefined(Object? v) => v == null ? 'undefined' : jsString(v);

/// `handleIncomingMessage(event)` → the message to append, or `null` when it
/// is empty or already shown.
Json? incomingChatMessage(Map<String, dynamic>? event, List<Json> current, Object? myId) {
  if (event == null) return null;
  Json parsed = event;
  final data = event['data'];
  if (data is String) {
    try {
      parsed = asMap(jsonDecode(data)) ?? const {};
    } catch (_) {
      return null;
    }
  }
  final msgText = parsed['message'];
  if (!jsTruthy(msgText)) return null;
  final messageId = parsed['id'] ?? '${vueTextOrUndefined(parsed['user_id'])}_${vueTextOrUndefined(parsed['created_at'])}';
  if (current.any((m) => jsString(m['id']) == jsString(messageId))) return null;
  final sender = asMap(parsed['user']);
  final senderId = parsed['user_id'];
  final isMe = jsString(senderId) == jsString(myId);
  final name = _userName(sender);
  return {
    'id': messageId,
    'sender': isMe
        ? 'You'
        : (name.isNotEmpty ? name : (jsTruthy(sender?['email']) ? '${sender!['email']}' : 'User #${vueTextOrUndefined(senderId)}')),
    'text': '$msgText',
    'time': jsTruthy(parsed['created_at']) ? localTime(parsed['created_at']) : '',
    'from': isMe ? 'user' : 'other',
  };
}

// ── presence ───────────────────────────────────────────────────────────────

/// Echo's `.here(users)`: the user infos of `pusher:subscription_succeeded`
/// (`{ presence: { ids, hash: { id: info }, count } }`).
List<Json> presenceHere(Map<String, dynamic>? data) {
  final hash = asMap(dig(data, ['presence', 'hash']));
  if (hash == null) return [];
  return [for (final v in hash.values) ?asMap(v)];
}

/// Echo's `.joining(user)`: `user_info` of `pusher:member_added`.
Json? presenceJoining(Map<String, dynamic>? data) => asMap(data?['user_info']);

/// `user_id` of `pusher:member_removed` / `pusher:member_added`.
String? presenceUserId(Map<String, dynamic>? data) => data?['user_id']?.toString();

/// `p?.student_id ?? p?.user_id ?? p?.user?.id` of `.user.join` / `.user.left`.
Object? joinPayloadId(Map<String, dynamic>? p) => p?['student_id'] ?? p?['user_id'] ?? dig(p, ['user', 'id']);

String _email(Object? v) => (v?.toString() ?? '').trim().toLowerCase();

/// The "In Class" cell: `onlineUsers.some(u => u.email?.trim().toLowerCase()
/// === student.user?.email?.trim().toLowerCase())`.
bool isStudentOnline(Json student, List<Json> onlineUsers) {
  final email = dig(student, ['user', 'email']);
  return onlineUsers.any((u) {
    final ue = u['email'];
    if (ue == null && email == null) return true; // undefined === undefined
    if (ue == null || email == null) return false;
    return _email(ue) == _email(email);
  });
}

/// `onlineStudentCount`
int onlineStudentCount(Object? scheduleStudents, List<Json> onlineUsers) {
  if (scheduleStudents is! List) return 0;
  var n = 0;
  for (final s in scheduleStudents) {
    final email = _email(dig(s, ['user', 'email']));
    if (email.isEmpty) continue;
    if (onlineUsers.any((u) => u['email'] != null && _email(u['email']) == email)) n++;
  }
  return n;
}

/// `joinedStudentIdsHas(student)`
bool joinedStudentIdsHas(Object? student, List<String> joinedIds) {
  final s = asMap(student);
  final sid = dig(s, ['user', 'id']) ?? s?['user_id'] ?? s?['id'];
  if (!jsTruthy(sid)) return false;
  return joinedIds.contains(jsString(sid));
}

// ── create-schedule drawer ─────────────────────────────────────────────────

/// `filteredInstructors`
List<Json> filteredInstructors(List<dynamic> instructors, String search) {
  final all = [for (final i in instructors) ?asMap(i)];
  if (search.isEmpty) return all.take(5).toList();
  final q = search.toLowerCase();
  return all.where((i) => '${dig(i, ['user', 'email']) ?? ''}'.toLowerCase().contains(q)).take(5).toList();
}

/// `` `${inst.user?.first_name || ''} ${inst.user?.last_name || ''}`.trim() ``
String instructorFullName(Json inst) {
  final u = asMap(inst['user']);
  return '${orJs(u?['first_name'], '')} ${orJs(u?['last_name'], '')}'.trim();
}

/// `validatePage1()` — `null` when the first step is complete.
String? validatePage1({
  required String classType,
  required Object? selectedYear,
  required List<String> batch,
  required List<String> days,
  required String slots,
  required String minutesPerDay,
  required DateTime? startDate,
  required DateTime? endDate,
}) {
  if (classType.isEmpty) return 'Please select Class Type';
  if (!jsTruthy(selectedYear)) return 'Please select a Class';
  if (batch.isEmpty) return 'Please select at least one Batch';
  if (days.isEmpty) return 'Please select Days';
  if (slots.isEmpty || jsNumber(slots) <= 0) return 'Please enter number of Slots';
  if (minutesPerDay.isEmpty || jsNumber(minutesPerDay) <= 0) return 'Please enter Minutes per slot';
  if (startDate == null || endDate == null) return 'Please select Start and End Dates';
  return null;
}

/// A fresh `slotDetails` entry.
Json emptySlotDetail() => {'startAt': '', 'subject': '', 'instructor': '', 'classType': '', 'title': ''};

/// `watch: 'form.slots'` — `slotsArray` and the grown `slotDetails`
/// (never shrunk, like the web).
({List<int> slotsArray, List<Json> slotDetails}) applySlotsCount(String slots, List<Json> slotDetails) {
  final n = jsNumber(slots);
  final count = n.isNaN || n <= 0 ? 0 : n.floor();
  final details = [...slotDetails];
  for (var i = details.length; i < count; i++) {
    details.add(emptySlotDetail());
  }
  return (slotsArray: List<int>.generate(count, (i) => i), slotDetails: details);
}

const _dayIndex = {'sunday': 0, 'monday': 1, 'tuesday': 2, 'wednesday': 3, 'thursday': 4, 'friday': 5, 'saturday': 6};

/// `generatePreviewSlots()` — the preview cards for every selected weekday
/// between the dates × every `slotDetails` entry, or the error toast text.
({String? error, List<Json> slots}) generatePreviewSlots({
  required DateTime? startDate,
  required DateTime? endDate,
  required List<String> days,
  required List<Json> slotDetails,
  required List<dynamic> instructors,
  required List<dynamic> courses,
  required String formClassType,
}) {
  if (startDate == null || endDate == null) return (error: 'Select start and end dates', slots: const []);
  final selectedDays = [for (final d in days) _dayIndex[d.toLowerCase().trim()]];
  final allDates = <String>[];
  final end = DateTime(endDate.year, endDate.month, endDate.day);
  for (var d = DateTime(startDate.year, startDate.month, startDate.day);
      !d.isAfter(end);
      d = DateTime(d.year, d.month, d.day + 1)) {
    if (selectedDays.contains(d.weekday % 7)) allDates.add(ymd(d));
  }
  final slots = <Json>[];
  for (final date in allDates) {
    for (final slot in slotDetails) {
      final instructor = instructors.map(asMap).where((i) => i != null && jsString(i['id']) == '${slot['instructor']}').firstOrNull;
      final instructorName = '${orJs(dig(instructor, ['user', 'email']), '')}';
      final course = courses.map(asMap).where((c) => c != null && jsString(c['id']) == '${slot['subject']}').firstOrNull;
      final conflict = slots.any((s) => s['date'] == date && s['instructor'] == instructorName && s['startAt'] == slot['startAt']);
      if (conflict) {
        return (error: 'Conflict: $instructorName already has a slot on $date at ${vueTextOrUndefined(slot['startAt'])}', slots: const []);
      }
      slots.add({
        'date': date,
        'startAt': slot['startAt'],
        'subject': '${orJs(course?['title'], '')}',
        'instructor': instructorName,
        'classType': '${orJs(orJs(slot['classType'], formClassType), '')}',
        'title': '${orJs(slot['title'], '')}',
      });
    }
  }
  if (slots.isEmpty) return (error: 'No slots generated.', slots: const []);
  return (error: null, slots: slots);
}

/// The `slots` payload `submitForm()` sends.
List<Json> buildSlotsPayload({
  required List<Json> previewSlots,
  required List<dynamic> instructors,
  required List<dynamic> courses,
  required String minutesPerDay,
  required String formClassType,
}) =>
    [
      for (final slot in previewSlots)
        () {
          final inst = instructors.map(asMap).where((i) => i != null && dig(i, ['user', 'email']) == slot['instructor']).firstOrNull;
          final courseId = courses.map(asMap).where((c) => c != null && c['title'] == slot['subject']).firstOrNull?['id'];
          return <String, dynamic>{
            'date': slot['date'],
            'start_time': slot['startAt'],
            'duration': jsNumberOr0(minutesPerDay),
            'instructor_id': idString(inst?['id']),
            'type': '${orJs(orJs(slot['classType'], formClassType), '')}',
            'title': '${orJs(slot['title'], '')}',
            'course_id': idString(courseId),
          };
        }(),
    ];

// ── references / activities ────────────────────────────────────────────────

/// `viewClassReference(ref)` / `viewClassAct(item)`: `course_content`
/// entries show their linked content.
({String type, String url, String content}) viewableContent(Json item) {
  var type = '${item['type'] ?? ''}';
  var url = '${orJs(item['url'], '')}';
  var content = '${orJs(item['content'], '')}';
  final cc = asMap(item['course_content']);
  if (item['type'] == 'course_content' && cc != null) {
    type = '${cc['type'] ?? ''}';
    url = '${orJs(cc['url'], '')}';
    content = '${orJs(cc['content'], '')}';
  }
  return (type: type, url: url, content: content);
}

/// `ref.content_id || ref.course_content?.id || ''` (the LMS select value).
Object lmsContentIdOf(Json item) =>
    orJs(item['content_id'], orJs(dig(item, ['course_content', 'id']), '')) ?? '';

bool isImageUrl(String url) => RegExp(r'\.(jpeg|jpg|gif|png|webp|bmp|svg)$', caseSensitive: false).hasMatch(url);

bool isVideoUrl(String url) => RegExp(r'\.(mp4|webm|ogg)$', caseSensitive: false).hasMatch(url);

bool isPdfUrl(String url) => RegExp(r'\.pdf$', caseSensitive: false).hasMatch(url);

bool isYouTubeUrl(String url) => RegExp(r'youtube\.com|youtu\.be').hasMatch(url);

/// `getYouTubeId(url)`
String youTubeId(String url) =>
    (RegExp(r'[?&]v=([^&]+)').firstMatch(url) ?? RegExp(r'youtu\.be/([^?&]+)').firstMatch(url))?.group(1) ?? '';

/// `cleanPayload(obj)` — drops null / empty / blank-string values.
Map<String, dynamic> cleanPayload(Map<String, dynamic> obj) => {
      for (final e in obj.entries)
        if (e.value != null && !(e.value is String && (e.value as String).trim().isEmpty)) e.key: e.value,
    };
