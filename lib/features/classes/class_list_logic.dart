/// Pure helpers for the class list port (`src/pages/class/classlist.vue` and
/// the `useUserStore` actions it maps). Kept free of Flutter so they can be
/// unit-tested.
library;

import 'package:intl/intl.dart';

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';

/// A JSON object as the web handled it.
typedef Json = Map<String, dynamic>;

// ── JavaScript semantics ───────────────────────────────────────────────────

/// `a || b`
Object? orJs(Object? a, Object? b) => jsTruthy(a) ? a : b;

/// `String(v)` for a JSON value (`5.0` → `'5'`, `null` → `'null'`).
String jsString(Object? v) {
  if (v == null) return 'null';
  if (v is double && v == v.truncateToDouble() && v.isFinite) return v.toInt().toString();
  return '$v';
}

/// `{{ v }}` in a Vue template: `null`/`undefined` render as an empty string.
String vueText(Object? v) => v == null ? '' : jsString(v);

/// `obj?.key` coerced by string concatenation (`a + b` in the template):
/// a missing object / key is `'undefined'`, a null value is `'null'`.
String jsMember(Object? obj, String key) {
  final m = asMap(obj);
  if (m == null || !m.containsKey(key)) return 'undefined';
  return jsString(m[key]);
}

/// `new Date(v).toLocaleDateString()` (en-US `M/d/yyyy`).
String jsLocaleDateString(Object? v) {
  DateTime? d;
  if (v == null) {
    d = DateTime.fromMillisecondsSinceEpoch(0);
  } else if (v is num) {
    d = DateTime.fromMillisecondsSinceEpoch(v.toInt());
  } else {
    d = DateTime.tryParse('$v')?.toLocal();
  }
  if (d == null) return 'Invalid Date';
  return DateFormat('M/d/yyyy').format(d);
}

/// `Number(v)` for ids (`NaN` → null).
int? jsNumber(Object? v) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is bool) return v ? 1 : 0;
  if (v is String) return v.trim().isEmpty ? 0 : num.tryParse(v.trim())?.toInt();
  return null;
}

// ── store mappings (useUserStore actions) ──────────────────────────────────

/// `getClasses()` item.
Map<String, dynamic> mapClassItem(Map<String, dynamic> item, Object? counts) {
  final c = asMap(counts) ?? const {};
  return {
    'id': item['id'],
    'year': item['name'],
    'c_id': item['curricula_id'],
    'students': c['students_count'] ?? 0,
    'batches': c['batches_count'] ?? 0,
    'instructors': c['instructors_count'] ?? 0,
    'courses': c['courses_count'] ?? 0,
    'admins': c['admin_instructors_count'] ?? 0,
    'status': item['status'] ?? 'unknown',
    'class_level': item['class_level'],
    'is_admin': item['is_admin'] ?? false,
  };
}

/// Whether `searchClassWithInstructor` has to fetch `/class/counts` for [item].
bool searchItemNeedsCounts(Map<String, dynamic> item) =>
    item['students_count'] == null &&
    item['instructors_count'] == null &&
    item['courses_count'] == null &&
    item['admin_instructors_count'] == null &&
    item['batches_count'] == null;

/// `searchClassWithInstructor()` item.
Map<String, dynamic> mapSearchClassItem(Map<String, dynamic> item, Object? counts) {
  final c = asMap(counts) ?? const {};
  return {
    'id': item['id'],
    'year': item['name'] ?? 'Unnamed class',
    'c_id': item['curricula_id'],
    'students': item['students_count'] ?? c['students_count'] ?? 0,
    'instructors': item['instructors_count'] ?? c['instructors_count'] ?? 0,
    'courses': item['courses_count'] ?? c['courses_count'] ?? 0,
    'admins': item['admin_instructors_count'] ?? c['admin_instructors_count'] ?? 0,
    'batches': item['batches_count'] ?? c['batches_count'] ?? 0,
    'is_admin': item['is_admin'] ?? false,
    'status': item['status'] ?? 'unknown',
  };
}

/// `searchClassWithInstructor`: `raw?.data ?? raw`, then `.data` or the array.
List<Map<String, dynamic>> searchClassRows(Object? raw) {
  final wrapper = asMap(raw)?['data'] ?? raw;
  final w = asMap(wrapper);
  final arr = (w != null && w['data'] is List) ? w['data'] as List : (wrapper is List ? wrapper : const []);
  return [for (final e in arr) if (jsTruthy(e)) ?asMap(e)];
}

/// `batch.status?.toString().toLowerCase() || 'unknown'`
String batchStatus(Object? status) {
  final s = status?.toString().toLowerCase() ?? '';
  return s.isEmpty ? 'unknown' : s;
}

Object? _activePivot(Map<String, dynamic> batch) {
  for (final s in asList(batch['students'])) {
    final pivot = asMap(asMap(s)?['pivot']);
    if (pivot?['status'] == true) return pivot;
  }
  return null;
}

/// `getBatches()` item.
Map<String, dynamic> mapBatch(Map<String, dynamic> batch) => {
      'id': batch['id'],
      'exam_batch_id': batch['exam_batch_id'],
      'name': batch['name'],
      'created_at': batch['created_at'],
      'status': batchStatus(batch['status']),
      'pivot': _activePivot(batch),
    };

/// `getPromoteBatches()` item.
Map<String, dynamic> mapPromoteBatch(Map<String, dynamic> batch) => {
      'id': batch['id'],
      'name': batch['name'],
      'created_at': batch['created_at'],
      'status': batchStatus(batch['status']),
      'pivot': _activePivot(batch),
    };

/// `searchBatch()` item.
Map<String, dynamic> mapSearchBatch(Map<String, dynamic> item) => {
      'id': item['id'],
      'exam_batch_id': item['exam_batch_id'],
      'classes_id': item['classes_id'] ?? item['class_id'],
      'institute_id': item['institute_id'],
      'name': item['name'] ?? item['label'] ?? 'Unnamed batch',
      'status': jsString(item['status'] ?? 'unknown'),
      'created_at': item['created_at'] ?? item['createdAt'],
      'updated_at': item['updated_at'] ?? item['updatedAt'],
      'pivot': item['pivot'],
    };

const _emptyUser = {'first_name': '', 'last_name': '', 'email': '', 'phone': '', 'country_code': ''};

/// `{ ...inst, user: inst.user || { first_name: '', … } }` (getInstructors).
Map<String, dynamic> withUserFallback(Map<String, dynamic> inst) => {
      ...inst,
      'user': jsTruthy(inst['user']) ? inst['user'] : Map<String, dynamic>.of(_emptyUser),
    };

/// `getAssignedInstructors()` item.
Map<String, dynamic> mapAssignedInstructor(Map<String, dynamic> inst) {
  final u = asMap(inst['user']);
  String f(String k) => asString(orJs(u?[k], '')) ?? '';
  return {
    'id': inst['id'],
    'institute_id': inst['institute_id'],
    'user_id': inst['user_id'],
    'status': inst['status'],
    'zoom_invite': inst['zoom_invite'],
    'zoom_integration': inst['zoom_integration'],
    'zoom_id': inst['zoom_id'],
    'created_at': inst['created_at'],
    'updated_at': inst['updated_at'],
    'pivot': orJs(inst['pivot'], <String, dynamic>{}),
    'user': {
      'first_name': f('first_name'),
      'last_name': f('last_name'),
      'email': f('email'),
      'country_code': f('country_code'),
      'phone': f('phone'),
      'status': inst['status'],
    },
  };
}

String _studentName(Map<String, dynamic> s) {
  final u = asMap(s['user']);
  return '${orJs(u?['first_name'], '')} ${orJs(u?['last_name'], '')}'.trim();
}

/// `getStudents()` item.
Map<String, dynamic> mapStudent(Map<String, dynamic> s) {
  final u = asMap(s['user']);
  final batch = asMap(dig(s, ['batches', 0]));
  final name = _studentName(s);
  return {
    'id': s['id'],
    'name': name.isEmpty ? 'N/A' : name,
    'status': jsTruthy(s['status']),
    'email': orJs(u?['email'], 'N/A'),
    'phone': orJs(u?['phone'], ''),
    'country_code': orJs(u?['country_code'], ''),
    'batch': orJs(batch?['name'], 'N/A'),
    'pivot_status': asMap(batch?['pivot'])?['status'],
  };
}

/// `Object.values(res).filter(s => s && typeof s === 'object' && 'id' in s)`
/// — the unpaginated (`paginate: 0`) student response.
List<Map<String, dynamic>> objectValuesWithId(Object? res) {
  final Iterable<dynamic> values = res is List ? res : (asMap(res)?.values ?? const []);
  return [
    for (final v in values)
      if (asMap(v) case final Map<String, dynamic> m when m.containsKey('id')) m,
  ];
}

/// `pivotStudents()` item (before the pivot filter).
Map<String, dynamic> mapPivotStudent(Map<String, dynamic> s, Object? batchId) {
  final u = asMap(s['user']);
  Map<String, dynamic>? batch;
  for (final b in asList(s['batches'])) {
    final m = asMap(b);
    if (m != null && jsNumber(m['id']) == jsNumber(batchId)) {
      batch = m;
      break;
    }
  }
  final pivot = asMap(batch?['pivot']);
  return {
    'id': s['id'],
    'name': _studentName(s),
    'email': orJs(u?['email'], 'N/A'),
    'status': s['status'],
    'batch': orJs(batch?['name'], 'N/A'),
    'pivot_status': pivot?['status'],
    'transfer_type': pivot?['transfer_type'],
    'to_batch_id': pivot?['to_batch_id'],
  };
}

/// `pivotStudents()`: keeps students whose pivot status is neither false nor null.
List<Map<String, dynamic>> pivotStudentList(Object? res, Object? batchId) => [
      for (final s in objectValuesWithId(res))
        if (mapPivotStudent(s, batchId) case final m when m['pivot_status'] != false && m['pivot_status'] != null) m,
    ];

/// `getAllStudents()` item.
Map<String, dynamic> mapAllStudent(Map<String, dynamic> s) {
  final u = asMap(s['user']);
  final name = _studentName(s);
  return {
    'id': s['id'],
    'name': name.isEmpty ? 'N/A' : name,
    'status': jsTruthy(s['status']),
    'email': orJs(u?['email'], 'N/A'),
    'phone': orJs(u?['phone'], ''),
    'country_code': orJs(u?['country_code'], ''),
    'batch': orJs(asMap(s['batch'])?['name'], 'N/A'),
  };
}

/// `searchStudents()` item.
Map<String, dynamic> mapSearchStudent(Map<String, dynamic> s) {
  final u = asMap(s['user']);
  final name = _studentName(s);
  return {
    'id': s['id'],
    'name': name.isEmpty ? 'N/A' : name,
    'status': jsTruthy(s['status']) ? 'true' : 'false',
    'email': orJs(u?['email'], 'N/A'),
    'batch': orJs(orJs(asMap(s['batch'])?['name'], dig(s, ['batches', 0, 'name'])), 'N/A'),
  };
}

/// `Array.isArray(r?.data) ? r.data : Array.isArray(r) ? r : []`
List<dynamic> dataOrArray(Object? r) {
  final d = asMap(r)?['data'];
  if (d is List) return d;
  if (r is List) return r;
  return const [];
}

// ── user search (instructor / student wizards) ─────────────────────────────

/// One row of the search dropdowns: `{ id, full_name, email, raw }`.
class SearchHit {
  const SearchHit({required this.id, required this.fullName, required this.email, required this.raw});
  final Object? id;
  final String fullName;
  final String email;
  final Object? raw;
}

/// `const payload = response?.data ?? response; const rows = …` shared by the
/// four search methods.
List<dynamic> searchRows(Object? response) {
  final payload = asMap(response)?['data'] ?? response;
  final p = asMap(payload);
  if (p != null && p['data'] is List) return p['data'] as List;
  final inner = asMap(p?['data']);
  if (inner != null && inner['data'] is List) return inner['data'] as List;
  if (payload is List) return payload;
  return const [];
}

/// `searchStudent` / `searchStudentGlobal` / `searchUserGlobal`: matches name,
/// email or phone of `row.user || row`; the hit id is the user id.
List<SearchHit> filterUserRows(List<dynamic> rows, String query) {
  final q = query.trim().toLowerCase();
  final hits = <SearchHit>[];
  for (final row in rows) {
    final u = asMap(orJs(asMap(row)?['user'], orJs(row, <String, dynamic>{}))) ?? const {};
    final name = '${orJs(u['first_name'], '')} ${orJs(u['last_name'], '')}'.trim();
    final email = '${orJs(u['email'], '')}';
    final phone = '${orJs(u['phone'], '')}'.toLowerCase();
    if (name.toLowerCase().contains(q) || email.toLowerCase().contains(q) || phone.contains(q)) {
      hits.add(SearchHit(id: u['id'], fullName: name, email: email, raw: row));
    }
  }
  return hits;
}

/// `searchUser` (instructors): matches `row.user` name or email only.
List<SearchHit> filterInstructorRows(List<dynamic> rows, String query) {
  final q = query.trim().toLowerCase();
  final hits = <SearchHit>[];
  for (final row in rows) {
    final u = asMap(orJs(asMap(row)?['user'], <String, dynamic>{})) ?? const {};
    final name = '${orJs(u['first_name'], '')} ${orJs(u['last_name'], '')}'.trim();
    final email = '${orJs(u['email'], '')}';
    if (name.toLowerCase().contains(q) || email.toLowerCase().contains(q)) {
      hits.add(SearchHit(id: u['id'], fullName: name, email: email, raw: row));
    }
  }
  return hits;
}

/// `selectResult(item)`: first / last name of `item.raw.user ?? item.raw`.
({String first, String last}) splitResultName(Map<String, dynamic>? u) {
  final fullName = u?['full_name'];
  final first = u?['first_name'] ?? (jsTruthy(fullName) ? '$fullName'.split(' ').first : '');
  final last = u?['last_name'] ?? (jsTruthy(fullName) ? '$fullName'.split(' ').skip(1).join(' ') : '');
  return (first: jsString(first), last: jsString(last));
}

// ── template helpers ───────────────────────────────────────────────────────

/// `student.status === true || student.status?.toString().toLowerCase() === 'true'`
bool isStudentActive(Object? status) => status == true || status?.toString().toLowerCase() == 'true';

/// `studentHasQuizSysCard(student)`
bool studentHasQuizSysCard(Map<String, dynamic>? s) =>
    s != null && s['quizsys_marker_id'] != null && jsTruthy(s['quizsys_qr_svg']);

/// Rows of the batch table: `statusbatch === 'all' ? true : batch.status === statusbatch`.
List<Map<String, dynamic>> filterBatchesByStatus(List<Map<String, dynamic>> batches, String statusbatch) =>
    [for (final b in batches) if (statusbatch == 'all' || b['status'] == statusbatch) b];

/// The "No batches match the selected filter." condition (also hides
/// unpublished batches from non-managers — the rows themselves don't).
bool noBatchMatches(List<Map<String, dynamic>> batches, String statusbatch, bool canManage) => !batches.any(
    (b) => (statusbatch == 'all' || b['status'] == statusbatch) && (canManage || b['status'] == 'published'));

/// `institutes.filter(i => status === 'all' ? true : i.status === status)`
List<Map<String, dynamic>> filterClassesByStatus(List<Map<String, dynamic>> classes, String status) =>
    [for (final c in classes) if (status == 'all' || c['status'] == status) c];

/// `BatchUpdate()` status normalisation.
String normalizeBatchUpdateStatus(String? s) => s == 'published' ? 'published' : (s == 'archived' ? 'archived' : 'draft');

/// `v.replace(/\D/g, '').slice(0, 10)`
String digitsMax10(String v) {
  final d = v.replaceAll(RegExp(r'\D'), '');
  return d.length > 10 ? d.substring(0, 10) : d;
}

/// `safeFileName(value, fallback)`
String safeFileName(Object? value, [String fallback = 'download.pdf']) {
  final cleaned = (jsTruthy(value) ? '$value' : '')
      .trim()
      .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '-')
      .replaceAll(RegExp(r'\s+'), '-')
      .replaceAll(RegExp(r'-+'), '-')
      .replaceAll(RegExp(r'^-|-$'), '');
  return cleaned.isEmpty ? fallback : cleaned;
}

/// `downloadBlob`: appends `.pdf` unless present.
String pdfFileName(String name) => name.toLowerCase().endsWith('.pdf') ? name : '$name.pdf';

/// Gmail compose link used by the envelope buttons.
String gmailComposeUrl(Object? to, {bool fs = true}) =>
    'https://mail.google.com/mail/?view=cm${fs ? '&fs=1' : ''}&to=${jsString(to)}';

/// `emailBatchStudents`: emails of active students with an active pivot.
List<String> activeStudentEmails(List<Map<String, dynamic>> students) => [
      for (final s in students)
        if (s['status'] == true && s['pivot_status'] == true && jsTruthy(s['email'])) '${s['email']}',
    ];

/// Import progress row update from the Echo `.update` event.
List<Map<String, dynamic>> applyImportUpdate(List<Map<String, dynamic>> rows, Map<String, dynamic>? e) {
  final stages = asMap(e?['stages']);
  final idx = rows.indexWhere((r) => r['email'] == e?['email']);
  if (idx >= 0) {
    final next = [...rows];
    next[idx] = {
      ...rows[idx],
      'status': e?['status'],
      'userStage': stages?['user'],
      'studentStage': stages?['student'],
    };
    return next;
  }
  return [
    ...rows,
    {'email': e?['email'], 'status': e?['status'], 'userStage': stages?['user'], 'studentStage': stages?['student']},
  ];
}
