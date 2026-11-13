import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/widgets.dart';

import '../../core/utils/json.dart';

/// Pure helpers of `teachercoursepage.vue` (module-level functions and the
/// small `methods` that only compute values).

/// One entry of `SUBJECT_THEMES`.
class SubjectTheme {
  const SubjectTheme(this.bg, this.color, this.icon);
  final Color bg;
  final Color color;
  final IconData icon;
}

const subjectThemes = <String, SubjectTheme>{
  'math': SubjectTheme(Color(0xFFDCFCE7), Color(0xFF15803D), BootstrapIcons.calculator_fill),
  'physics': SubjectTheme(Color(0xFFEDE9FE), Color(0xFF6D28D9), BootstrapIcons.lightning_charge_fill),
  'chem': SubjectTheme(Color(0xFFFEE2E2), Color(0xFFB91C1C), BootstrapIcons.eyedropper),
  'bio': SubjectTheme(Color(0xFFD1FAE5), Color(0xFF065F46), BootstrapIcons.flower1),
  'english': SubjectTheme(Color(0xFFDBEAFE), Color(0xFF1D4ED8), BootstrapIcons.book_fill),
  'history': SubjectTheme(Color(0xFFFEF3C7), Color(0xFF92400E), BootstrapIcons.hourglass_split),
  'geo': SubjectTheme(Color(0xFFFCE7F3), Color(0xFF9D174D), BootstrapIcons.globe),
  'cs': SubjectTheme(Color(0xFFE0F2FE), Color(0xFF0369A1), BootstrapIcons.laptop_fill),
  'default': SubjectTheme(Color(0xFFF1F5F9), Color(0xFF475569), BootstrapIcons.journal_text),
};

/// `getTheme(title)` — keyword match on the lower-cased course title.
SubjectTheme subjectThemeFor(Object? title) {
  final t = (title == null ? '' : '$title').toLowerCase();
  if (t.contains('math')) return subjectThemes['math']!;
  if (t.contains('physics')) return subjectThemes['physics']!;
  if (t.contains('chem')) return subjectThemes['chem']!;
  if (t.contains('bio')) return subjectThemes['bio']!;
  if (t.contains('english') || t.contains('literature')) return subjectThemes['english']!;
  if (t.contains('history') || t.contains('social')) return subjectThemes['history']!;
  if (t.contains('geo')) return subjectThemes['geo']!;
  if (t.contains('computer') || t.contains('cs') || t.contains('coding')) return subjectThemes['cs']!;
  return subjectThemes['default']!;
}

bool _truthy(Object? v) {
  if (v == null) return false;
  if (v is bool) return v;
  if (v is num) return v != 0 && !v.isNaN;
  if (v is String) return v.isNotEmpty;
  return true;
}

/// `getInstituteLabel(inst)` — `inst.name || inst.year || 'Class <id>'`.
String instituteLabel(Map<String, dynamic> inst) {
  if (_truthy(inst['name'])) return '${inst['name']}';
  if (_truthy(inst['year'])) return '${inst['year']}';
  return 'Class ${inst['id']}';
}

/// `getCourseCurriculum(course)`
String courseCurriculum(Map<String, dynamic> course) {
  final list = asList(course['curriculums']);
  if (list.isNotEmpty) {
    // `undefined || '—'` in the template, hence ''.
    final name = asMap(list.first)?['name'];
    return name == null ? '' : '$name';
  }
  final name = dig(course, ['curriculum', 'name']);
  if (_truthy(name)) return '$name';
  return '';
}

/// `filteredCourses` — search over title / short name / code, then the
/// (never set by the UI) curriculum and grade filters.
List<Map<String, dynamic>> filterCourses(
  List<Map<String, dynamic>> courses, {
  required String searchQuery,
  Object? selectedCurriculumId,
  Object? selectedGradeId,
}) {
  final q = searchQuery.toLowerCase();
  bool has(Object? v) => v != null && '$v'.toLowerCase().contains(q);
  return [
    for (final c in courses)
      if ((q.isEmpty || has(c['title']) || has(c['short_name']) || has(c['course_code'])) &&
          (!_truthy(selectedCurriculumId) ||
              asList(c['curriculums']).any((cur) => asMap(cur)?['id'] == selectedCurriculumId)) &&
          (!_truthy(selectedGradeId) ||
              c['allclass'] == selectedGradeId ||
              '${c['allclass']}' == '$selectedGradeId'))
        c,
  ];
}

/// `newVal.courses` / `details.courses` filtered for non-managers
/// (`String(c.status) === 'published'`). Maps are copied so the page can
/// tag them (`selectedCourseCurriculumName`, …) like the web mutates them.
List<Map<String, dynamic>> visibleCourses(dynamic courses, {required bool canManage}) => [
      for (final raw in asList(courses))
        if (asMap(raw) case final c? when canManage || '${c['status']}' == 'published') {...c},
    ];

/// `instructorDisplayName(instructor)`
String instructorDisplayName(Map<String, dynamic>? instructor) {
  if (instructor == null) return '';
  final user = asMap(instructor['user']) ?? const {};
  final full = '${_truthy(user['first_name']) ? user['first_name'] : ''} '
          '${_truthy(user['last_name']) ? user['last_name'] : ''}'
      .trim();
  if (full.isNotEmpty) return full;
  if (_truthy(instructor['name'])) return '${instructor['name']}';
  if (_truthy(user['email'])) return '${user['email']}';
  return 'Unnamed';
}

/// `` `${sections_count ?? 0} Module${sections_count !== 1 ? 's' : ''}` ``
String modulesLabel(Object? sectionsCount) {
  final n = sectionsCount ?? 0;
  return '$n Module${sectionsCount == 1 ? '' : 's'}';
}

/// CSS `text-transform: capitalize`.
String capitalizeWords(Object? v) {
  final s = v == null ? '' : '$v';
  return s.replaceAllMapped(RegExp(r'(^|\s)(\S)'), (m) => '${m[1]}${m[2]!.toUpperCase()}');
}

// ── media helpers (`isImage`, `isVideo`, …) ────────────────────────────────

bool isImageUrl(Object? url) =>
    RegExp(r'\.(jpeg|jpg|gif|png|webp|bmp|svg)$', caseSensitive: false).hasMatch('$url');

bool isVideoUrl(Object? url) => RegExp(r'\.(mp4|webm|ogg)$', caseSensitive: false).hasMatch('$url');

bool isPdfUrl(Object? url) => RegExp(r'\.pdf$', caseSensitive: false).hasMatch('$url');

bool isYouTubeUrl(Object? url) => RegExp(r'youtube\.com|youtu\.be').hasMatch('$url');

/// `getYouTubeId(url)` (`null` when nothing matches, rendered as "null").
String? youTubeId(String url) =>
    (RegExp(r'[?&]v=([^&]+)').firstMatch(url) ?? RegExp(r'youtu\.be/([^?&]+)').firstMatch(url))?.group(1);

bool isVimeoUrl(Object? url) => RegExp(r'vimeo\.com').hasMatch('$url');

String? vimeoId(String url) => RegExp(r'vimeo\.com/(\d+)').firstMatch(url)?.group(1);

const _blockedEmbeds = [
  'tiptap.dev',
  'google.com',
  'github.com',
  'stackoverflow.com',
  'developer.mozilla.org',
  'nasa.gov',
];

/// `canEmbedUrl(url)`
bool canEmbedUrl(String url) => !_blockedEmbeds.any(url.contains);

/// `` `${url}#toolbar=0&navpanes=0&scrollbar=0` ``
String pdfEmbedUrl(Object? url) => '$url#toolbar=0&navpanes=0&scrollbar=0';

// ── JS number coercion for the `order` inputs ─────────────────────────────

/// `Number(value)` → JSON (`NaN` serialises as `null`, `''` → 0).
Object? jsNumberJson(Object? value) {
  final n = jsNumber(value);
  if (n.isNaN) return null;
  return n == n.truncateToDouble() && n.abs() < 9007199254740992 ? n.toInt() : n;
}

/// `String(Number(value))` as sent in a `FormData`.
String jsNumberString(Object? value) {
  final n = jsNumber(value);
  if (n.isNaN) return 'NaN';
  if (n.isInfinite) return n.isNegative ? '-Infinity' : 'Infinity';
  return n == n.truncateToDouble() && n.abs() < 1e21 ? '${n.toInt()}' : '$n';
}

/// JS `Number(value)` for the values an `<input type="number">` v-model
/// holds (strings, numbers, null).
double jsNumber(Object? value) {
  if (value == null) return 0;
  if (value is num) return value.toDouble();
  if (value is bool) return value ? 1 : 0;
  final s = '$value'.trim();
  if (s.isEmpty) return 0;
  return double.tryParse(s) ?? double.nan;
}
