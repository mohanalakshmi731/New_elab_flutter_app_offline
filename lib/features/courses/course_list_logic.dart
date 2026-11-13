/// Pure helpers ported from `src/pages/course/courselist.vue` and the
/// course/curriculum actions of `useUserStore` (kept free of Flutter so they
/// can be unit tested).
library;

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';

/// `x || ''` rendered as text.
String orBlank(Object? v) => jsTruthy(v) ? '$v' : '';

/// `{{ v }}` — Vue renders `null` / `undefined` as an empty string.
String vText(Object? v) => v == null ? '' : '$v';

/// JavaScript `Number(text)`: `''` / whitespace → `0`, invalid → `NaN`.
/// Integral values come back as [int] so `String(n)` matches the web.
num jsNumber(Object? v) {
  if (v == null) return 0;
  if (v is num) return v;
  final s = '$v'.trim();
  if (s.isEmpty) return 0;
  final n = num.tryParse(s);
  if (n == null) return double.nan;
  if (n is double && n.isFinite && n == n.truncateToDouble() && n.abs() < 9e15) return n.toInt();
  return n;
}

/// `JSON.stringify` of a number: `NaN` / `Infinity` become `null`.
Object? jsonNumber(num n) => n.isFinite ? n : null;

/// Builds a JSON payload the way `JSON.stringify` does with `undefined`
/// values (the key is dropped).
Map<String, dynamic> withoutUndefined(Map<String, dynamic> m) => {
  for (final e in m.entries)
    if (e.value != null) e.key: e.value,
};

/// `searchCurriculum` / `searchCourse`:
/// `const wrapper = raw?.data ?? raw;
///  Array.isArray(wrapper?.data) ? wrapper.data : Array.isArray(wrapper) ? wrapper : []`
List<dynamic> searchArray(dynamic raw) {
  final m = asMap(raw);
  final wrapper = (m != null && m['data'] != null) ? m['data'] : raw;
  final inner = asMap(wrapper)?['data'];
  if (inner is List) return inner;
  if (wrapper is List) return wrapper;
  return const [];
}

/// `filteredCourses`
List<Map<String, dynamic>> filterCoursesByStatus(List<Map<String, dynamic>> courses, String status) => [
  for (final c in courses)
    if (status == 'all' || c['status'] == status) c,
];

/// Status texts used by the pills (`'published' → 'Published'`,
/// `'draft' → draftLabel`, anything else `'Archived'`).
String statusLabel(Object? status, {String draftLabel = 'UnPublished'}) => status == 'published'
    ? 'Published'
    : status == 'draft'
    ? draftLabel
    : 'Archived';

/// The status cycle of the curriculum pill: published → draft → archived → published.
String nextCurriculumStatus(Object? status) => status == 'published'
    ? 'draft'
    : status == 'draft'
    ? 'archived'
    : 'published';

/// `instructorDisplayName(instructor)`
String instructorDisplayName(Map<String, dynamic>? instructor) {
  if (instructor == null) return '';
  final user = asMap(instructor['user']) ?? const {};
  final first = orBlank(user['first_name']);
  final last = orBlank(user['last_name']);
  final full = '$first $last'.trim();
  if (full.isNotEmpty) return full;
  final email = orBlank(user['email']);
  return email.isNotEmpty ? email : 'Unnamed Instructor';
}

/// `` `${inst.user?.first_name || ''} ${inst.user?.last_name || ''}`.trim() ``
String instructorOptionLabel(Map<String, dynamic> inst) {
  final user = asMap(inst['user']);
  return '${orBlank(user?['first_name'])} ${orBlank(user?['last_name'])}'.trim();
}

/// `{{ first_name?.[0]?.toUpperCase() || 'I' }}{{ last_name?.[0]?.toUpperCase() || '' }}`
String instructorInitials(Map<String, dynamic> instructor) {
  final user = asMap(instructor['user']);
  String firstChar(Object? v) {
    if (v is! String || v.isEmpty) return '';
    return v.substring(0, 1).toUpperCase();
  }

  final f = firstChar(user?['first_name']);
  return '${f.isEmpty ? 'I' : f}${firstChar(user?['last_name'])}';
}

/// `{{ instructor.user?.first_name }} {{ instructor.user?.last_name }}`
String instructorFullName(Map<String, dynamic> instructor) {
  final user = asMap(instructor['user']);
  return '${vText(user?['first_name'])} ${vText(user?['last_name'])}';
}

// ── URL type helpers ────────────────────────────────────────────────────

bool isImageUrl(Object? url) => RegExp(r'\.(jpeg|jpg|gif|png|webp|bmp|svg)$', caseSensitive: false).hasMatch('$url');

bool isVideoUrl(Object? url) => RegExp(r'\.(mp4|webm|ogg)$', caseSensitive: false).hasMatch('$url');

bool isPdfUrl(Object? url) => RegExp(r'\.pdf$', caseSensitive: false).hasMatch('$url');

bool isYouTubeUrl(Object? url) => RegExp(r'youtube.com|youtu.be').hasMatch('$url');

String? youTubeId(Object? url) {
  final s = '$url';
  final m = RegExp(r'[?&]v=([^&]+)').firstMatch(s) ?? RegExp(r'youtu\.be/([^?&]+)').firstMatch(s);
  return m?.group(1);
}

bool isVimeoUrl(Object? url) => RegExp(r'vimeo.com').hasMatch('$url');

String? vimeoId(Object? url) => RegExp(r'vimeo.com/(\d+)').firstMatch('$url')?.group(1);

const _blockedDomains = [
  'tiptap.dev',
  'google.com',
  'github.com',
  'stackoverflow.com',
  'developer.mozilla.org',
  'nasa.gov',
];

bool canEmbedUrl(String url) => !_blockedDomains.any(url.contains);

/// What the `type === 'url'` preview box renders for [url].
enum UrlPreviewKind { image, video, youtube, vimeo, pdf, embed, blocked }

UrlPreviewKind urlPreviewKind(String url) {
  if (isImageUrl(url)) return UrlPreviewKind.image;
  if (isVideoUrl(url)) return UrlPreviewKind.video;
  if (isYouTubeUrl(url)) return UrlPreviewKind.youtube;
  if (isVimeoUrl(url)) return UrlPreviewKind.vimeo;
  if (isPdfUrl(url)) return UrlPreviewKind.pdf;
  if (canEmbedUrl(url)) return UrlPreviewKind.embed;
  return UrlPreviewKind.blocked;
}

// ── Preview tab (section → chapter → concept dropdowns) ───────────────────

List<Map<String, dynamic>> _maps(dynamic list) => [for (final e in asList(list)) ?asMap(e)];

/// `previewChapters`
List<Map<String, dynamic>> previewChaptersOf(Map<String, dynamic>? details, String sectionId) {
  final sections = details?['sections'];
  if (sections == null || sectionId.isEmpty) return const [];
  for (final s in _maps(sections)) {
    if ('${s['id']}' == sectionId) return _maps(s['chapters']);
  }
  return const [];
}

/// `previewContents`
List<Map<String, dynamic>> previewContentsOf(List<Map<String, dynamic>> chapters, String chapterId) {
  if (chapterId.isEmpty) return const [];
  for (final c in chapters) {
    if ('${c['id']}' == chapterId) return _maps(c['contents']);
  }
  return const [];
}

/// The auto-selection done by `onPreviewTabClick`: first section, its first
/// chapter and that chapter's first concept (`content` is the concept that
/// becomes the preview item, `null` = show the course).
typedef PreviewSelection = ({String sectionId, String chapterId, String contentId, Map<String, dynamic>? content});

PreviewSelection firstPreviewSelection(Map<String, dynamic> response) {
  final sections = _maps(response['sections']);
  if (sections.isEmpty) return (sectionId: '', chapterId: '', contentId: '', content: null);
  final firstSection = sections.first;
  final chapters = _maps(firstSection['chapters']);
  if (chapters.isEmpty) {
    return (sectionId: '${firstSection['id']}', chapterId: '', contentId: '', content: null);
  }
  final firstChapter = chapters.first;
  final contents = _maps(firstChapter['contents']);
  if (contents.isEmpty) {
    return (sectionId: '${firstSection['id']}', chapterId: '${firstChapter['id']}', contentId: '', content: null);
  }
  return (
    sectionId: '${firstSection['id']}',
    chapterId: '${firstChapter['id']}',
    contentId: '${contents.first['id']}',
    content: contents.first,
  );
}
