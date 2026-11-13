/// Pure helpers for the class-course screen (`ClassCourseCreate.vue`) and the
/// `useUserStore` course/section/chapter/content actions it maps. Kept free of
/// Flutter/Riverpod so they can be unit-tested.
library;

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';

/// `List<Map>` view of a JSON list (non-map entries dropped).
List<Map<String, dynamic>> mapsOf(dynamic list) => [for (final e in asList(list)) ?asMap(e)];

/// `data || []` for the `/section`, `/chapter`, `/content` lists (a wrapped
/// `{ data: [...] }` body is unwrapped instead of being iterated as an object).
List<Map<String, dynamic>> listOrEmpty(dynamic data) => mapsOf(data is List ? data : unwrapList(data));

/// `res.data || res || []`
dynamic dataOr(dynamic res, dynamic fallback) {
  final data = asMap(res)?['data'];
  if (jsTruthy(data)) return data;
  if (jsTruthy(res)) return res;
  return fallback;
}

/// JavaScript `Number(v)`; `null` stands for `NaN` (what `JSON.stringify`
/// sends for it). `Number('')` / `Number(null)` are 0.
num? jsNumber(Object? v) {
  if (v == null) return 0;
  if (v is num) return v.isNaN ? null : v;
  if (v is bool) return v ? 1 : 0;
  final s = v.toString().trim();
  if (s.isEmpty) return 0;
  final n = num.tryParse(s);
  if (n == null || n.isNaN) return null;
  return n;
}

/// JavaScript `String(Number(v))` for a FormData field (`'NaN'` when invalid).
String jsNumberString(Object? v) {
  final n = jsNumber(v);
  if (n == null) return 'NaN';
  if (n is double && n == n.truncateToDouble() && n.abs() < 1e21) return n.toInt().toString();
  return n.toString();
}

/// `String(x)` with JS `undefined`/`null` spelled out like the browser did.
String jsString(Object? v) => v == null ? 'null' : '$v';

// ── store mappers ──────────────────────────────────────────────────────────

/// `fetchCurriculums()` mapping.
List<Map<String, dynamic>> mapCurriculums(dynamic data) => [
      for (final item in mapsOf(data))
        {
          'id': item['id'],
          'institute_id': item['institute_id'],
          'name': item['name'],
          'status': _lowerOr(item['status'], 'draft'),
          'created_at': item['created_at'],
        },
    ];

String _lowerOr(Object? v, String fallback) {
  final s = v?.toString().toLowerCase() ?? '';
  return s.isEmpty ? fallback : s;
}

/// `getInstructorsdropdown` / `getAllInstructors`: `user: inst.user || {…}`.
List<Map<String, dynamic>> normalizeInstructors(dynamic list) => [
      for (final inst in mapsOf(list))
        {
          ...inst,
          'user': jsTruthy(inst['user'])
              ? inst['user']
              : <String, dynamic>{'first_name': '', 'last_name': '', 'email': '', 'phone': '', 'country_code': ''},
        },
    ];

/// `searchCourse(term)` result mapping.
List<Map<String, dynamic>> mapSearchCourses(dynamic raw) {
  final m = asMap(raw);
  final wrapper = m != null && m['data'] != null ? m['data'] : raw;
  final wm = asMap(wrapper);
  final List<dynamic> arr = wm != null && wm['data'] is List
      ? wm['data'] as List
      : wrapper is List
          ? wrapper
          : const [];
  return [
    for (final item in mapsOf(arr.where(jsTruthy).toList()))
      {
        'id': item['id'],
        'institute_id': item['institute_id'],
        'instructor_id': item['instructor_id'] ?? dig(item, ['instructor', 'id']),
        'title': item['title'] ?? item['name'] ?? 'Untitled course',
        'description': item['description'] ?? '',
        'short_name': item['short_name'] ?? item['code'] ?? '',
        'course_code': item['course_code'] ?? item['code'] ?? '',
        'image': item['image'],
        'status': '${item['status'] ?? 'unknown'}',
        'created_at': item['created_at'] ?? item['createdAt'],
        'updated_at': item['updated_at'] ?? item['updatedAt'],
        'instructor': item['instructor'],
      },
  ];
}

/// `fetchCourseDetails` derived lists: `sections`, flattened `chapters`
/// and flattened `contents`.
({List<Map<String, dynamic>> sections, List<Map<String, dynamic>> chapters, List<Map<String, dynamic>> contents})
    flattenCourse(Map<String, dynamic> response) {
  final sections = mapsOf(response['sections']);
  final chapters = [for (final s in sections) ...mapsOf(s['chapters'])];
  final contents = [for (final c in chapters) ...mapsOf(c['contents'])];
  return (sections: sections, chapters: chapters, contents: contents);
}

// ── payloads ───────────────────────────────────────────────────────────────

/// `createCourse(classid)` → `courseService.createCourse({...})`.
Map<String, dynamic> buildCreateCourseData(Map<String, dynamic> courseForm, {required String instituteId, String? classId}) =>
    {
      'institute_id': instituteId,
      'curriculum_id': courseForm['curriculum_id'],
      'instructor_id': courseForm['instructor_id']?.toString() ?? '',
      'class_id': classId,
      'zsl_class_id': courseForm['allclass'],
      'zsl_subject_id': courseForm['subject_id'],
      'title': courseForm['title'],
      'description': jsTruthy(courseForm['description']) ? courseForm['description'] : '',
      'short_name': courseForm['short_name'],
      'course_code': courseForm['course_code'],
      'image': courseForm['image'],
      'status': courseForm['status'],
      'is_math_zoro': jsTruthy(courseForm['is_math_zoro']),
      'zone': jsTruthy(courseForm['zone']) ? courseForm['zone'] : '',
    };

String _orEmpty(Object? v) => jsTruthy(v) ? '$v' : '';

/// `updateCourse(courseId, form)` FormData fields (`attach` is an
/// `UploadFile` or null).
Map<String, dynamic> buildUpdateCourseFields(Map<String, dynamic> form, {required String instituteId}) => {
      '_method': 'PUT',
      'institute_id': instituteId,
      'title': _orEmpty(form['title']),
      'short_name': _orEmpty(form['short_name']),
      'course_code': _orEmpty(form['course_code']),
      'description': _orEmpty(form['description']),
      'status': jsTruthy(form['status']) ? '${form['status']}' : 'draft',
      'curriculum_id': _orEmpty(form['curriculum_id']?.toString()),
      'instructor_id': _orEmpty(form['instructor_id']?.toString()),
      'zsl_class_id': _orEmpty(form['class_id']?.toString()),
      'zsl_subject_id': _orEmpty(form['subject_id']?.toString()),
      'is_math_zoro': form['isMathPlay'] == true ? 'true' : 'false',
      'zone': _orEmpty(form['zone']),
      if (form['attach'] != null) 'image': form['attach'],
    };

/// `createContent()` FormData fields from `contentForm`. Throws like the
/// store when the PDF file is missing.
Map<String, dynamic> buildCreateContentFields(
  Map<String, dynamic> contentForm, {
  required String instituteId,
  required String courseId,
  required String sectionId,
  required String chapterId,
  String? classId,
}) {
  final type = contentForm['type'];
  final fields = <String, dynamic>{
    'institute_id': instituteId,
    'course_id': courseId,
    'section_id': sectionId,
    'chapter_id': chapterId,
    'name': jsString(contentForm['name']),
    'type': jsString(type),
    'order': jsString(contentForm['order']),
    'zsl_activity_id': jsString(contentForm['zslactvity']),
    if (jsTruthy(classId)) 'class_id': classId,
  };
  if (type == 'pdf') {
    if (contentForm['file'] == null) throw StateError('Missing PDF file');
    fields['file'] = contentForm['file'];
  } else if (type == 'url') {
    fields['url'] = jsString(contentForm['url']);
  } else if (type == 'html') {
    fields['html_content'] = jsString(contentForm['html_content']);
  }
  return fields;
}

/// `updateContent(contentId)` FormData fields from `selectedContentDetails`.
Map<String, dynamic> buildUpdateContentFields(
  Map<String, dynamic> details, {
  required String instituteId,
  required String chapterId,
  required String courseId,
  String? classId,
}) {
  final type = details['type'];
  final fields = <String, dynamic>{
    '_method': 'PUT',
    'institute_id': instituteId,
    'chapter_id': chapterId,
    'course_id': courseId,
    'name': jsString(details['name']),
    'type': jsString(type),
    'order': details['order'] is num ? jsNumberString(details['order']) : jsString(details['order']),
    if (jsTruthy(classId)) 'class_id': classId,
  };
  if (type == 'pdf' && details['file'] != null) {
    fields['file'] = details['file'];
  } else if (type == 'url') {
    fields['url'] = jsString(details['url']);
  } else if (type == 'html') {
    fields['html_content'] = jsString(details['html_content']);
  }
  return fields;
}

// ── page helpers ───────────────────────────────────────────────────────────

/// `instructorDisplayName(instructor)`.
String instructorDisplayName(Map<String, dynamic>? instructor) {
  if (instructor == null) return '';
  final user = asMap(instructor['user']) ?? const {};
  final first = jsTruthy(user['first_name']) ? '${user['first_name']}' : '';
  final last = jsTruthy(user['last_name']) ? '${user['last_name']}' : '';
  final fallback = jsTruthy(instructor['name']) ? '${instructor['name']}' : '$first $last'.trim();
  if (fallback.isNotEmpty) return fallback;
  return jsTruthy(user['email']) ? '${user['email']}' : 'Unnamed Instructor';
}

/// `` `${inst.user?.first_name || ''} ${inst.user?.last_name || ''}`.trim() ``
String instructorOptionLabel(Map<String, dynamic> inst) {
  final first = dig(inst, ['user', 'first_name']);
  final last = dig(inst, ['user', 'last_name']);
  return '${jsTruthy(first) ? first : ''} ${jsTruthy(last) ? last : ''}'.trim();
}

/// The zsl class pre-selected by `openCreateCourseDialog`: the class's own
/// `zsl_class_id`, else the ZSL class whose name matches the class name.
String defaultZslClassId(Map<String, dynamic>? classDetails, List<Map<String, dynamic>> filteredClasses) {
  if (classDetails != null && classDetails.containsKey('zsl_class_id') && jsTruthy(classDetails['zsl_class_id'])) {
    return '${classDetails['zsl_class_id']}';
  }
  final current = (classDetails?['name'] ?? '').toString().toLowerCase().trim();
  for (final c in filteredClasses) {
    final name = c['name'];
    if (name != null && name.toString().toLowerCase().trim() == current) return '${c['id']}';
  }
  return '';
}

/// Status label used by the disabled status select in the Overview tab.
String statusLabel(Object? status) => status == 'published'
    ? 'Published'
    : status == 'draft'
        ? 'UnPublished'
        : 'Archived';

// ── URL preview helpers (component methods) ─────────────────────────────────

final _image = RegExp(r'\.(jpeg|jpg|gif|png|webp|bmp|svg)$', caseSensitive: false);
final _video = RegExp(r'\.(mp4|webm|ogg)$', caseSensitive: false);
final _pdf = RegExp(r'\.pdf$', caseSensitive: false);
final _youTube = RegExp(r'youtube.com|youtu.be');
final _vimeo = RegExp(r'vimeo.com');

bool isImage(String? url) => _image.hasMatch(url ?? 'undefined');
bool isVideo(String? url) => _video.hasMatch(url ?? 'undefined');
bool isPdf(String? url) => _pdf.hasMatch(url ?? 'undefined');
bool isYouTube(String? url) => _youTube.hasMatch(url ?? 'undefined');
bool isVimeo(String? url) => _vimeo.hasMatch(url ?? 'undefined');

String? getYouTubeId(String url) {
  final m = RegExp(r'[?&]v=([^&]+)').firstMatch(url) ?? RegExp(r'youtu\.be/([^?&]+)').firstMatch(url);
  return m?.group(1);
}

String? getVimeoId(String url) => RegExp(r'vimeo.com/(\d+)').firstMatch(url)?.group(1);

const _blockedDomains = [
  'tiptap.dev',
  'google.com',
  'github.com',
  'stackoverflow.com',
  'developer.mozilla.org',
  'nasa.gov',
];

bool canEmbedUrl(String url) => !_blockedDomains.any(url.contains);

/// What the URL-type preview shows, in the template's `v-if` order.
enum UrlPreviewKind { image, video, youTube, vimeo, pdf, embed, blocked }

UrlPreviewKind urlPreviewKind(String? url) {
  if (isImage(url)) return UrlPreviewKind.image;
  if (isVideo(url)) return UrlPreviewKind.video;
  if (isYouTube(url)) return UrlPreviewKind.youTube;
  if (isVimeo(url)) return UrlPreviewKind.vimeo;
  if (isPdf(url)) return UrlPreviewKind.pdf;
  if (canEmbedUrl(url ?? 'undefined')) return UrlPreviewKind.embed;
  return UrlPreviewKind.blocked;
}

/// `` `${url}#toolbar=0&navpanes=0&scrollbar=0` ``
String pdfViewerUrl(Object? url) => '${url ?? 'undefined'}#toolbar=0&navpanes=0&scrollbar=0';

/// The global `.preview` rules from `src/style.css`, so `v-html` content
/// rendered in a WebView looks like the web.
const previewCss = '''
.preview h1{font-size:28px;font-weight:700;line-height:1.2;margin:.67em 0}
.preview h2{font-size:24px;font-weight:700;line-height:1.25;margin:.67em 0}
.preview h3{font-size:20px;font-weight:700;line-height:1.3;margin:.67em 0}
.preview h4{font-size:18px;font-weight:700;line-height:1.3;margin:.67em 0}
.preview h5{font-size:16px;font-weight:700;line-height:1.35;margin:.67em 0}
.preview h6{font-size:14px;font-weight:700;line-height:1.35;margin:.67em 0}
.preview p{font-size:15px;line-height:1.6}
.preview ul,.preview ol{padding-left:1.5rem;margin:.5rem 0}
.preview{overflow-wrap:break-word;white-space:normal}
''';

/// `<div class="preview" v-html="html">` as a fragment for `WebContentView(html:)`.
String previewHtml(Object? html) => '<style>$previewCss</style><div class="preview">${html ?? ''}</div>';
