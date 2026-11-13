/// Pure helpers behind `teachersdashboardpage.vue`.
library;

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';

/// `i?.start_date` truthy.
bool hasStartDate(Object? item) => jsTruthy(asMap(item)?['start_date']);

/// `Array.isArray(res) ? res : res ? [res] : []`, keeping items with a
/// `start_date`.
List<dynamic> ongoingFromResponse(Object? res) {
  final arr = res is List ? res : (jsTruthy(res) ? [res] : const []);
  return [for (final i in arr) if (hasStartDate(i)) i];
}

/// `Array.isArray(res) ? res : (res?.data ?? [])`, keeping items with a
/// `start_date`.
List<dynamic> todayFromResponse(Object? res) {
  final arr = res is List ? res : asList(asMap(res)?['data']);
  return [for (final i in arr) if (hasStartDate(i)) i];
}

/// `bannerStatus`: ongoing → today → none.
String bannerStatusOf(List<dynamic> ongoing, List<dynamic> today) {
  if (ongoing.isNotEmpty) return 'ongoing';
  if (today.isNotEmpty) return 'today';
  return 'none';
}

/// The "Today's Classes" caption.
String todayClassesCaption(int count) {
  if (count == 1) return '1 class scheduled';
  if (count > 1) return '$count classes scheduled';
  return 'None today';
}

/// `s.title || s.batch?.classes?.name || fallback`
String scheduleTitle(Map<String, dynamic> s, String fallback) {
  if (jsTruthy(s['title'])) return '${s['title']}';
  final className = dig(s, const ['batch', 'classes', 'name']);
  if (jsTruthy(className)) return '$className';
  return fallback;
}

/// `s.batch?.name || 'Batch'`
String scheduleBatchName(Map<String, dynamic> s) {
  final name = dig(s, const ['batch', 'name']);
  return jsTruthy(name) ? '$name' : 'Batch';
}

/// `s.batch?.classes?.name` when truthy (shown as `• name`).
String? scheduleClassName(Map<String, dynamic> s) {
  final name = dig(s, const ['batch', 'classes', 'name']);
  return jsTruthy(name) ? '$name' : null;
}

/// `format(new Date(), 'yyyy-MM-dd')` (local date).
String todayIso([DateTime? now]) {
  final d = now ?? DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-${two(d.month)}-${two(d.day)}';
}
