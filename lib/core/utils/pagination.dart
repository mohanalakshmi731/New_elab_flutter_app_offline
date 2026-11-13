import 'dart:math' as math;

import 'json.dart';

/// Laravel paginator metadata — the `{current_page, last_page, per_page, total}`
/// objects the web stores in `userPagination`, `institutePagination`, …
class PageMeta {
  const PageMeta({
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
  });

  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;

  static const empty = PageMeta();

  factory PageMeta.fromMap(Map<String, dynamic> m, {int fallbackPerPage = 10}) =>
      PageMeta(
        currentPage: asInt(m['current_page']) ?? 1,
        lastPage: math.max(1, asInt(m['last_page']) ?? 1),
        perPage: asInt(m['per_page']) ?? fallbackPerPage,
        total: asInt(m['total']) ?? 0,
      );

  /// Finds the paginator in a response body: at the root
  /// (`{current_page, data: [...]}`), under `data` (`{data: {current_page, …}}`)
  /// or under `meta` (API resources). Returns `null` for unpaginated lists.
  static PageMeta? find(dynamic body, {int fallbackPerPage = 10}) {
    final candidates = [
      asMap(body),
      asMap(asMap(body)?['data']),
      asMap(asMap(body)?['meta']),
      asMap(asMap(asMap(body)?['data'])?['meta']),
    ];
    for (final m in candidates) {
      if (m != null && m.containsKey('current_page')) {
        return PageMeta.fromMap(m, fallbackPerPage: fallbackPerPage);
      }
    }
    return null;
  }

  PageMeta copyWith({int? currentPage, int? lastPage, int? perPage, int? total}) =>
      PageMeta(
        currentPage: currentPage ?? this.currentPage,
        lastPage: lastPage ?? this.lastPage,
        perPage: perPage ?? this.perPage,
        total: total ?? this.total,
      );

  @override
  String toString() =>
      'PageMeta(page $currentPage/$lastPage, perPage $perPage, total $total)';
}

/// The page numbers the web lists render (`visiblePages()` in userlist.vue and
/// friends): pages are shown in fixed groups of [perGroup] — 5 on phones
/// (`window.innerWidth < 640`), 10 otherwise — containing [current].
List<int> visiblePageGroup(int current, int last, int perGroup) {
  if (last <= 1) return const [1];
  final c = current.clamp(1, last);
  final start = ((c - 1) ~/ perGroup) * perGroup + 1;
  final end = math.min(start + perGroup - 1, last);
  return [for (var i = start; i <= end; i++) i];
}
