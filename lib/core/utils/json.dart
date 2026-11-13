/// Small helpers for the loosely typed JSON the Laravel API returns
/// (ids arrive as int or string, flags as bool/int/string, lists are
/// sometimes wrapped in `{ data: [...] }`).
library;

int? asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v.trim());
  return null;
}

double? asDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v.trim());
  return null;
}

String? asString(dynamic v) {
  if (v == null) return null;
  return v.toString();
}

bool asBool(dynamic v, {bool fallback = false}) {
  if (v == null) return fallback;
  if (v is bool) return v;
  if (v is num) return v != 0;
  if (v is String) {
    final s = v.toLowerCase().trim();
    if (s == 'true' || s == '1') return true;
    if (s == 'false' || s == '0' || s.isEmpty) return false;
  }
  return fallback;
}

Map<String, dynamic>? asMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
  return null;
}

List<dynamic> asList(dynamic v) => v is List ? v : const [];

/// `Array.isArray(res) ? res : Array.isArray(res?.data) ? res.data : []`
List<dynamic> unwrapList(dynamic body) {
  if (body is List) return body;
  final m = asMap(body);
  if (m != null) {
    if (m['data'] is List) return m['data'] as List;
    final inner = asMap(m['data']);
    if (inner != null && inner['data'] is List) return inner['data'] as List;
  }
  return const [];
}

/// `res?.data ?? res`
dynamic unwrapData(dynamic body) {
  final m = asMap(body);
  if (m != null && m.containsKey('data')) return m['data'];
  return body;
}

/// Safe nested lookup: `dig(json, ['a', 'b', 0, 'c'])`.
dynamic dig(dynamic json, List<Object> path) {
  dynamic cur = json;
  for (final key in path) {
    if (cur == null) return null;
    if (key is int) {
      if (cur is List && key >= 0 && key < cur.length) {
        cur = cur[key];
      } else {
        return null;
      }
    } else {
      final m = asMap(cur);
      if (m == null) return null;
      cur = m[key];
    }
  }
  return cur;
}
