import '../../core/utils/json.dart';

/// Reconstructs the existing curriculum responses from authorized saved packs.
class PreparedCatalog {
  PreparedCatalog(this.entries);
  final List<
    ({Map<String, dynamic> pack, List<Map<String, dynamic>> activities})
  >
  entries;
  static Object? id(Object? value) => int.tryParse('$value') ?? value;
  static bool same(Object? a, Object? b) => '$a' == '$b';
  List<Map<String, dynamic>> get activities => [
    for (final e in entries) ...e.activities,
  ];
  List<Map<String, dynamic>> get chapters {
    final result = <String, Map<String, dynamic>>{};
    for (final e in entries) {
      for (final raw in asList(e.pack['chapters'])) {
        final c = asMap(raw)!;
        if (!e.activities.any((a) => same(a['chapter_id'], c['id']))) continue;
        result['${c['zsl_class_id']}:${c['subject_id']}:${c['id']}'] = {
          ...c,
          'class_name': c['class_name'] ?? e.pack['class_name'],
          'class_level': e.pack['class_level'] ?? 10,
          'id': id(c['id']),
          'subject_id': id(c['subject_id']),
          'zsl_class_id': id(c['zsl_class_id']),
        };
      }
    }
    return result.values.toList();
  }

  dynamic response(String path, Map<String, dynamic> query) {
    final classId = query['zsl_class_id'] ?? query['class_id'];
    final subjectId = query['zsl_subject_id'] ?? query['subject_id'];
    if (path == '/zsl/classes' || path == '/zsl/classes/all') {
      final result = <String, Map<String, dynamic>>{};
      for (final c in chapters) {
        final key = '${c['zsl_class_id']}';
        result[key] = {
          'id': id(c['zsl_class_id']),
          'name': c['class_name'] ?? 'Class ${c['class_level']}',
          'class_level': c['class_level'],
        };
      }
      return result.values.toList();
    }
    if (path == '/zsl/subjects') {
      final result = <String, Map<String, dynamic>>{};
      for (final c in chapters.where((c) => same(c['zsl_class_id'], classId))) {
        final acts = activities.where(
          (a) =>
              same(a['chapter_id'], c['id']) &&
              same(a['zsl_class_id'], classId) &&
              same(a['subject_id'], c['subject_id']),
        );
        final math = acts.any((a) => a['zone'] == 'math');
        result['${c['subject_id']}'] = {
          ...?asMap(c['subject']),
          'id': id(c['subject_id']),
          'name': c['subject_name'],
          'zone': math ? 'MATH_ZONE' : 'SCIENCE_ZONE',
        };
      }
      return result.values.toList();
    }
    if (path == '/zsl/chapters') {
      return chapters
          .where(
            (c) =>
                same(c['zsl_class_id'], classId) &&
                same(c['subject_id'], subjectId),
          )
          .toList();
    }
    if (path == '/zsl/chapter/links') {
      final result = <String, Map<String, dynamic>>{};
      for (final a in activities.where(
        (a) => same(a['chapter_id'], query['zsl_chapter_id']),
      )) {
        final key = '${a['topic_id']}';
        final topic = result.putIfAbsent(
          key,
          () => {
            ...?asMap(a['topic']),
            'id': id(a['topic_id']),
            'name': a['topic_name'],
            'chapter_id': id(a['chapter_id']),
            'activities': <Map<String, dynamic>>[],
          },
        );
        final list = topic['activities'] as List<Map<String, dynamic>>;
        if (!list.any((saved) => same(saved['id'], a['id'])))
          list.add({...a, 'id': id(a['id'])});
      }
      return result.values.toList();
    }
    if (path == '/zsl/get-subject-performance' ||
        path == '/zsl/get-quiz-performance')
      return <String, dynamic>{};
    throw StateError(
      'Connect to the internet to use this feature. Prepared activities are available in Library, Math Zone and Science Zone.',
    );
  }
}
