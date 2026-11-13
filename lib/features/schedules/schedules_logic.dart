/// Pure helpers for the schedules screen (`src/pages/schedules/schedules.vue`):
/// JavaScript coercions, the tab date ranges (date-fns), schedule grouping,
/// slot preview generation, chat / presence payload mapping and the media
/// preview checks. Kept free of Flutter so they can be unit tested.
library;

import 'dart:convert';

import 'package:intl/intl.dart';

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';

typedef SJson = Map<String, dynamic>;

/// `list.map(asMap)` without the non-map entries.
List<SJson> schMaps(Object? list) => [for (final e in asList(list)) ?asMap(e)];

// ── JavaScript coercions ───────────────────────────────────────────────────

/// `Number(x)` — `null`/`''`/whitespace → 0, booleans → 1/0, numeric strings
/// → the number (an int when integral), anything else → NaN.
num schNumber(Object? v) {
  if (v == null) return 0;
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  final s = v.toString().trim();
  if (s.isEmpty) return 0;
  final i = int.tryParse(s);
  if (i != null) return i;
  final d = double.tryParse(s);
  if (d == null) return double.nan;
  return d == d.truncateToDouble() && d.abs() < 1e15 ? d.toInt() : d;
}

/// `String(x)` (`null` → `'null'`, integral doubles without `.0`).
String schString(Object? v) {
  if (v == null) return 'null';
  if (v is double && v.isFinite && v == v.truncateToDouble()) return v.toInt().toString();
  return v.toString();
}

/// `{{ x }}` interpolation: `null`/`undefined` render as nothing.
String vText(Object? v) => v == null ? '' : schString(v);

/// `x?.[0]` — first element of an array or first character of a string.
Object? jsFirst(Object? v) {
  if (v is List) return v.isEmpty ? null : v.first;
  if (v is String) return v.isEmpty ? null : v[0];
  return null;
}

/// Store `cleanPayload(obj)`: drops `null`, `''` and whitespace-only strings.
SJson cleanPayload(SJson obj) => {
      for (final e in obj.entries)
        if (!(e.value == null || (e.value is String && (e.value as String).trim().isEmpty))) e.key: e.value,
    };

// ── tab date ranges (date-fns) ─────────────────────────────────────────────

final _ymd = DateFormat('yyyy-MM-dd');

DateTime _date(DateTime d) => DateTime(d.year, d.month, d.day);

/// `startOfWeek(d, { weekStartsOn: 1 })`
DateTime startOfWeekMon(DateTime d) => DateTime(d.year, d.month, d.day - (d.weekday - 1));

/// `endOfWeek(d, { weekStartsOn: 1 })` (as a date).
DateTime endOfWeekSun(DateTime d) => DateTime(d.year, d.month, d.day + (7 - d.weekday));

DateTime startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

DateTime endOfMonth(DateTime d) => DateTime(d.year, d.month + 1, 0);

/// `addWeeks(d, n)` / `subWeeks(d, -n)`
DateTime addWeeks(DateTime d, int n) => DateTime(d.year, d.month, d.day + 7 * n);

/// `subMonths(d, n)` — the day is clamped to the target month's length.
DateTime subMonths(DateTime d, int n) {
  final first = DateTime(d.year, d.month - n, 1);
  final last = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(first.year, first.month, d.day > last ? last : d.day);
}

typedef DateRange = ({String start, String end});

const _noRange = (start: '', end: '');

/// The `start_date` / `end_date` of a schedule tab, as computed by the
/// `activeTab` watcher and `reloadSchedules()` (empty strings = no filter).
/// `nextmonth` is the month of `now + 4 weeks`, exactly like the web.
DateRange scheduleRange(String tab, DateTime now) {
  String f(DateTime d) => _ymd.format(_date(d));
  switch (tab) {
    case 'today':
      return (start: f(now), end: f(now));
    case 'thisweek':
      return (start: f(startOfWeekMon(now)), end: f(endOfWeekSun(now)));
    case 'thismonth':
      return (start: f(startOfMonth(now)), end: f(endOfMonth(now)));
    case 'nextweek':
      final n = addWeeks(now, 1);
      return (start: f(startOfWeekMon(n)), end: f(endOfWeekSun(n)));
    case 'nextmonth':
      final n = addWeeks(now, 4);
      return (start: f(startOfMonth(n)), end: f(endOfMonth(n)));
    case 'pastweek':
      final p = addWeeks(now, -1);
      return (start: f(startOfWeekMon(p)), end: f(endOfWeekSun(p)));
    case 'pastmonth':
      final p = subMonths(now, 1);
      return (start: f(startOfMonth(p)), end: f(endOfMonth(p)));
  }
  return _noRange;
}

/// The range used by the `'form.batch'` watcher, which (unlike the
/// `activeTab` watcher) has no `thisweek` / `thismonth` branches.
DateRange batchWatcherRange(String tab, DateTime now) =>
    tab == 'thisweek' || tab == 'thismonth' ? _noRange : scheduleRange(tab, now);

/// `{ ...(start ? { start_date } : {}), ...(end ? { end_date } : {}),
/// batch_id: form.batch?.[0] || undefined }`
SJson scheduleFilters(DateRange range, Object? batch) {
  final first = jsFirst(batch);
  return {
    if (range.start.isNotEmpty) 'start_date': range.start,
    if (range.end.isNotEmpty) 'end_date': range.end,
    'batch_id': jsTruthy(first) ? first : null,
  };
}

// ── schedule lists ─────────────────────────────────────────────────────────

/// `dataArray.filter((item) => item.start_date)` of the ongoing tab.
List<SJson> ongoingFrom(Object? response) {
  final list = response is List ? response : [response];
  return [
    for (final e in list)
      if (jsTruthy(asMap(e)?['start_date'])) asMap(e)!,
  ];
}

typedef ScheduleGroup = ({Object? className, Object? batchName, List<SJson> items});

/// `groupByClassBatch(schedules)` — keyed by `class name__batch name`.
List<ScheduleGroup> groupByClassBatch(Object? schedules) {
  final keys = <String>[];
  final groups = <String, ScheduleGroup>{};
  for (final item in schMaps(schedules)) {
    final batch = asMap(item['batch']);
    final className = dig(batch, ['classes', 'name']);
    final batchName = batch?['name'];
    final key = '${className ?? 'undefined'}__${batchName ?? 'undefined'}';
    final g = groups[key];
    if (g == null) {
      keys.add(key);
      groups[key] = (className: className, batchName: batchName, items: [item]);
    } else {
      g.items.add(item);
    }
  }
  return [for (final k in keys) groups[k]!];
}

/// The status badge colour of the other tabs: red for missed / canceled.
bool isBadStatus(Object? status) {
  final s = status?.toString().toLowerCase();
  return s == 'missed' || s == 'canceled';
}

// ── create drawer ──────────────────────────────────────────────────────────

/// One of `slotDetails` / `editingSlot` (`{ startAt, subject, instructor,
/// classType, title }`); subject / instructor hold the ids as strings.
class SlotDetail {
  SlotDetail({this.startAt = '', this.subject = '', this.instructor = '', this.classType = '', this.title = ''});
  String startAt;
  String subject;
  String instructor;
  String classType;
  String title;

  SlotDetail copy() =>
      SlotDetail(startAt: startAt, subject: subject, instructor: instructor, classType: classType, title: title);
}

/// One of `previewSlots` (`{ date, startAt, subject, instructor, classType,
/// title }`); subject is the course title, instructor the email.
class PreviewSlot {
  PreviewSlot({
    this.date = '',
    this.startAt = '',
    this.subject = '',
    this.instructor = '',
    this.classType = '',
    this.title = '',
  });
  String date;
  String startAt;
  String subject;
  String instructor;
  String classType;
  String title;
}

/// `validatePage1()` — the first failing message, or null when valid.
String? validatePage1({
  required String classType,
  required Object? selectedYear,
  required List<String> batch,
  required List<String> days,
  required String slots,
  required String minutesPerDay,
  required String startDate,
  required String endDate,
}) {
  if (classType.isEmpty) return 'Please select Class Type';
  if (!jsTruthy(selectedYear)) return 'Please select a Class';
  if (batch.isEmpty) return 'Please select at least one Batch';
  if (days.isEmpty) return 'Please select Days';
  if (slots.isEmpty || !(schNumber(slots) > 0)) return 'Please enter number of Slots';
  if (minutesPerDay.isEmpty || !(schNumber(minutesPerDay) > 0)) return 'Please enter Minutes per slot';
  if (startDate.isEmpty || endDate.isEmpty) return 'Please select Start and End Dates';
  return null;
}

/// `form.slots` watcher: `Number(val) || 0` slots.
int slotCount(String slots) {
  final n = schNumber(slots);
  if (n.isNaN || n <= 0) return 0;
  return n.floor();
}

String _instructorEmail(List<SJson> instructors, String id) {
  for (final i in instructors) {
    if (schString(i['id']) == id) return asString(dig(i, ['user', 'email'])) ?? '';
  }
  return '';
}

SJson? _courseById(List<SJson> courses, String id) {
  for (final c in courses) {
    if (schString(c['id']) == id) return c;
  }
  return null;
}

typedef PreviewResult = ({String? error, List<PreviewSlot> slots});

/// `generatePreviewSlots()` — every selected weekday between the start and
/// end dates × every slot detail. Returns the toast message on failure.
///
/// The dates are iterated as calendar dates (the web's `new Date('YYYY-MM-DD')`
/// gives the same days in India's time zone).
PreviewResult buildPreviewSlots({
  required String startDate,
  required String endDate,
  required List<String> days,
  required List<SlotDetail> slotDetails,
  required List<SJson> instructors,
  required List<SJson> courses,
  required String classType,
  String classType2 = '',
}) {
  if (startDate.isEmpty || endDate.isEmpty) return (error: 'Select start and end dates', slots: const []);
  const dayMap = {
    'sunday': 0,
    'monday': 1,
    'tuesday': 2,
    'wednesday': 3,
    'thursday': 4,
    'friday': 5,
    'saturday': 6,
  };
  final selected = {for (final d in days) ?dayMap[d.toLowerCase().trim()]};
  final start = DateTime.tryParse(startDate);
  final end = DateTime.tryParse(endDate);
  final dates = <String>[];
  if (start != null && end != null) {
    final last = _date(end);
    for (var d = _date(start); !d.isAfter(last); d = DateTime(d.year, d.month, d.day + 1)) {
      if (selected.contains(d.weekday % 7)) dates.add(_ymd.format(d));
    }
  }

  final slots = <PreviewSlot>[];
  for (final date in dates) {
    for (final slot in slotDetails) {
      final instructorName = _instructorEmail(instructors, slot.instructor);
      final course = _courseById(courses, slot.subject);
      final conflict = slots.any((s) => s.date == date && s.instructor == instructorName && s.startAt == slot.startAt);
      if (conflict) {
        return (
          error: 'Conflict: $instructorName already has a slot on $date at ${slot.startAt}',
          slots: const <PreviewSlot>[],
        );
      }
      final type = [slot.classType, classType, classType2].firstWhere((t) => t.isNotEmpty, orElse: () => '');
      slots.add(PreviewSlot(
        date: date,
        startAt: slot.startAt,
        subject: asString(course?['title']) ?? '',
        instructor: instructorName,
        classType: type,
        title: slot.title,
      ));
    }
  }
  if (slots.isEmpty) return (error: 'No slots generated. Please select valid days and slots.', slots: const []);
  return (error: null, slots: slots);
}

/// `submitForm()` slots payload (`instructor_id` from the email, `course_id`
/// from the course title).
List<SJson> buildSlotsPayload({
  required List<PreviewSlot> previewSlots,
  required List<SJson> instructors,
  required List<SJson> courses,
  required String minutesPerDay,
  required String classType,
  String classType2 = '',
}) {
  final minutes = schNumber(minutesPerDay);
  return [
    for (final slot in previewSlots)
      {
        'date': slot.date,
        'start_time': slot.startAt,
        'duration': minutes.isNaN ? 0 : minutes,
        'instructor_id': () {
          for (final i in instructors) {
            if (dig(i, ['user', 'email']) == slot.instructor) return i['id']?.toString() ?? '';
          }
          return '';
        }(),
        'type': [slot.classType, classType, classType2].firstWhere((t) => t.isNotEmpty, orElse: () => ''),
        'title': slot.title,
        'course_id': () {
          for (final c in courses) {
            if (c['title'] == slot.subject) return c['id']?.toString() ?? '';
          }
          return '';
        }(),
      },
  ];
}

// ── attendance / participants ──────────────────────────────────────────────

/// `JSON.parse(JSON.stringify(res))` → an array as-is, or every array value
/// of an object concatenated.
List<dynamic> flattenAttendance(Object? response) {
  if (response is List) return [...response];
  final m = asMap(response);
  if (m == null) return [];
  return [
    for (final v in m.values)
      if (v is List) ...v,
  ];
}

/// `formatAttendanceTime(raw)` — the time in Asia/Kolkata as `en-IN`
/// `hh:mm am/pm`; `'-'` when empty. A UTC suffix is added to
/// `YYYY-MM-DD HH:mm:ss` values.
String formatAttendanceTime(Object? raw) {
  if (!jsTruthy(raw)) return '-';
  var iso = raw.toString();
  if (!iso.contains('T') && !iso.endsWith('Z')) iso = '${iso.replaceFirst(' ', 'T')}Z';
  final d = DateTime.tryParse(iso);
  if (d == null) return 'Invalid Date';
  final ist = d.toUtc().add(const Duration(hours: 5, minutes: 30));
  return DateFormat('hh:mm a', 'en_US').format(ist).toLowerCase();
}

/// `new Date(x).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })`
String chatTime(Object? createdAt) {
  final d = createdAt == null ? null : DateTime.tryParse(createdAt.toString());
  if (d == null) return 'Invalid Date';
  return DateFormat('hh:mm a', 'en_US').format(d.toLocal());
}

bool _sameEmail(Object? a, Object? b) {
  if (!jsTruthy(a) || !jsTruthy(b)) return false;
  return a.toString().trim().toLowerCase() == b.toString().trim().toLowerCase();
}

/// `onlineUsers.some(u => u.email && student.user?.email && …)` (In Class).
bool isStudentOnline(Object? student, List<SJson> onlineUsers) {
  final email = dig(student, ['user', 'email']);
  return onlineUsers.any((u) => _sameEmail(u['email'], email));
}

/// `onlineStudentCount`
int onlineStudentCount(Object? scheduleStudents, List<SJson> onlineUsers) {
  if (scheduleStudents is! List) return 0;
  return scheduleStudents.where((s) => isStudentOnline(s, onlineUsers)).length;
}

/// `joinedStudentIdsHas(student)`
bool joinedStudentIdsHas(Object? student, List<String> joinedIds) {
  final sid = dig(student, ['user', 'id']) ?? asMap(student)?['user_id'] ?? asMap(student)?['id'];
  if (!jsTruthy(sid)) return false;
  return joinedIds.contains(schString(sid));
}

/// The id of a `user.join` / `user.left` broadcast (`student_id ?? user_id ?? user.id`).
String? joinedIdOf(Object? raw) {
  final m = asMap(raw);
  final id = m?['student_id'] ?? m?['user_id'] ?? dig(m, ['user', 'id']);
  if (!jsTruthy(id)) return null;
  return schString(id);
}

// ── presence (Echo `.here` / `.joining` / `.leaving`) ──────────────────────

/// `pusher:subscription_succeeded` → `{ id: user_info }` of the members.
Map<String, SJson> presenceMembers(Object? data) {
  final hash = asMap(dig(data, ['presence', 'hash']));
  if (hash == null) return {};
  return {
    for (final e in hash.entries)
      if (asMap(e.value) != null) e.key: asMap(e.value)!,
  };
}

/// `pusher:member_added` → `user_info` (Echo's `.joining(user)`).
SJson? presenceJoining(Object? data) => asMap(asMap(data)?['user_info']);

/// `user_id` of `pusher:member_added` / `pusher:member_removed`.
String? presenceUserId(Object? data) => asMap(data)?['user_id']?.toString();

// ── chat ───────────────────────────────────────────────────────────────────

/// A `chatMessages` entry (`{ id, sender, text, time, from: 'user' | 'other' }`).
class ChatMessage {
  const ChatMessage({required this.id, required this.sender, required this.text, required this.time, required this.from});
  final Object? id;
  final String sender;
  final Object? text;
  final String time;
  final String from;

  bool get mine => from == 'user';
}

/// `${obj.key}` in a template literal: a missing key is `'undefined'`, a
/// null value `'null'`.
String jsTpl(SJson m, String key) => m.containsKey(key) ? schString(m[key]) : 'undefined';

String _fullName(Object? user) {
  final u = asMap(user);
  return '${u?['first_name'] ?? ''} ${u?['last_name'] ?? ''}'.trim();
}

/// `loadChatMessages()` mapping.
ChatMessage chatFromHistory(SJson m, Object? myUserId) {
  final isMe = schString(m['user_id']) == schString(myUserId);
  final name = _fullName(m['user']);
  final email = dig(m, ['user', 'email']);
  return ChatMessage(
    id: m['id'],
    sender: isMe
        ? 'You'
        : name.isNotEmpty
            ? name
            : jsTruthy(email)
                ? '$email'
                : 'User #${jsTpl(m, 'user_id')}',
    text: m['message'],
    time: chatTime(m['created_at']),
    from: isMe ? 'user' : 'other',
  );
}

/// The message mapping of `handleStart()` (after joining the meeting).
ChatMessage chatFromStart(SJson m, Object? myUserId) {
  final fullName = dig(m, ['user', 'full_name']);
  final email = dig(m, ['user', 'email']);
  final uid = dig(m, ['user', 'id']);
  return ChatMessage(
    id: m['id'],
    sender: jsTruthy(fullName)
        ? '$fullName'
        : jsTruthy(email)
            ? '$email'
            : 'Unknown',
    text: m['message'],
    time: chatTime(m['created_at']),
    from: uid != null && uid == myUserId ? 'user' : 'other',
  );
}

/// `handleIncomingMessage(event)` — null when the event carries no message.
ChatMessage? chatFromEvent(SJson? event, Object? myUserId) {
  if (event == null) return null;
  SJson parsed = event;
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
  final createdAt = parsed['created_at'];
  final senderId = parsed['user_id'];
  final isMe = schString(senderId) == schString(myUserId);
  final name = _fullName(parsed['user']);
  final email = dig(parsed, ['user', 'email']);
  return ChatMessage(
    id: parsed['id'] ?? '${jsTpl(parsed, 'user_id')}_${jsTpl(parsed, 'created_at')}',
    sender: isMe
        ? 'You'
        : name.isNotEmpty
            ? name
            : jsTruthy(email)
                ? '$email'
                : 'User #${jsTpl(parsed, 'user_id')}',
    text: msgText,
    time: jsTruthy(createdAt) ? chatTime(createdAt) : '',
    from: isMe ? 'user' : 'other',
  );
}

// ── activity / reference previews ──────────────────────────────────────────

/// `viewClassReference` / `viewClassAct` / `viewHomeAct`: LMS links show the
/// linked content's type, url and content.
({Object? type, String url, String content}) viewedFields(SJson item) {
  Object? type = item['type'];
  var url = jsTruthy(item['url']) ? '${item['url']}' : '';
  var content = jsTruthy(item['content']) ? '${item['content']}' : '';
  final cc = asMap(item['course_content']);
  if (item['type'] == 'course_content' && cc != null) {
    type = cc['type'];
    url = jsTruthy(cc['url']) ? '${cc['url']}' : '';
    content = jsTruthy(cc['content']) ? '${cc['content']}' : '';
  }
  return (type: type, url: url, content: content);
}

bool isImageUrl(String url) => RegExp(r'\.(jpeg|jpg|gif|png|webp|bmp|svg)$', caseSensitive: false).hasMatch(url);
bool isVideoUrl(String url) => RegExp(r'\.(mp4|webm|ogg)$', caseSensitive: false).hasMatch(url);
bool isPdfUrl(String url) => RegExp(r'\.pdf$', caseSensitive: false).hasMatch(url);
bool isYouTubeUrl(String url) => RegExp(r'youtube\.com|youtu\.be').hasMatch(url);
bool isVimeoUrl(String url) => RegExp(r'vimeo\.com').hasMatch(url);

String youTubeId(String url) {
  final m = RegExp(r'[?&]v=([^&]+)').firstMatch(url) ?? RegExp(r'youtu\.be/([^?&]+)').firstMatch(url);
  return m?.group(1) ?? '';
}

String vimeoId(String url) => RegExp(r'vimeo\.com/(\d+)').firstMatch(url)?.group(1) ?? '';

bool canEmbedUrl(String url) {
  if (url.isEmpty) return false;
  const blocked = ['google.com', 'github.com', 'stackoverflow.com'];
  return !blocked.any(url.contains);
}

/// `url + '#toolbar=0&navpanes=0&scrollbar=0'`
String pdfFrameUrl(String url) => '$url#toolbar=0&navpanes=0&scrollbar=0';
