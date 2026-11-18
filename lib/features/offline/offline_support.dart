import '../../core/utils/json.dart';

/// Uses the same field precedence as the online activity tabs.
List<String> offlineSupportTexts(Map<String, dynamic> activity, String group) {
  Object? raw = activity[group];
  bool empty(Object? value) =>
      value == null ||
      (value is String && value.trim().isEmpty) ||
      (value is Iterable && value.isEmpty) ||
      (value is Map && value.isEmpty);
  if (empty(raw)) raw = asMap(activity['activity_data'])?[group];
  final items = raw is List ? raw : [raw];
  final texts = <String>[];
  for (final item in items) {
    if (item is String) {
      if (item.trim().isNotEmpty) texts.add(item);
      continue;
    }
    final map = asMap(item);
    if (map == null) continue;
    final keys = group == 'description'
        ? ['content', 'text', 'description']
        : ['text', 'content', 'description'];
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        texts.add(value);
        break;
      }
    }
  }
  return texts;
}
