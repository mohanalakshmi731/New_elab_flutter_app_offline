/// Pure helpers shared by the Activity Library screens
/// (`library.vue`, `activitylibrary.vue`, `newlibrarypage.vue`).
library;

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';

/// JavaScript `String(v)` for the scalar ids / labels these pages compare
/// (`String(a) === String(b)`). `null` (JS `null`/`undefined`) → `'null'`;
/// integral doubles print without `.0` like JS numbers.
String jsString(Object? v) {
  if (v == null) return 'null';
  if (v is double && v.isFinite && v == v.truncateToDouble()) return v.toInt().toString();
  return v.toString();
}

/// Vue `{{ value }}` text: `null`/`undefined` render as ''.
String vueText(Object? v) => v == null ? '' : jsString(v);

/// `String(a) === String(b)`.
bool sameId(Object? a, Object? b) => jsString(a) == jsString(b);

/// `a || b || c …` — the first JS-truthy value, else the last one.
Object? jsOr(List<Object?> values) {
  for (final v in values) {
    if (jsTruthy(v)) return v;
  }
  return values.isEmpty ? null : values.last;
}

/// `a || b || ''` as text (fields shown or loaded as strings).
String vueOr(List<Object?> values) {
  final v = jsOr([...values, '']);
  return v is String ? v : jsString(v);
}

/// `(a ? String(a) : '') || (b ? String(b) : '') || … || ''`.
String firstTruthyString(List<Object?> values) {
  for (final v in values) {
    if (jsTruthy(v)) return jsString(v);
  }
  return '';
}

/// `res.data || res || []` (store `getAllSubjects` / `getallchpaters`),
/// returned as a list (a non-list body gives `[]`; the web would have
/// failed on `.length`/`.some` and shown nothing either).
List<dynamic> dataOrSelf(dynamic res) {
  final m = asMap(res);
  if (m != null && jsTruthy(m['data'])) return asList(m['data']);
  return asList(res);
}

/// `normalizeApiList(response)` in activitylibrary.vue.
List<dynamic> normalizeApiList(dynamic response) => unwrapList(response);

/// `truncateTitle(text, limit)` in library.vue.
String truncateTitle(String text, int limit) {
  if (text.length <= limit) return text;
  return '${text.substring(0, limit)}...';
}

/// `getActivityTitle(activity)`:
/// `name || title || \`Activity ${order || ''}\`.trim() || 'Untitled Activity'`.
String activityTitle(Map<String, dynamic>? activity) {
  final name = activity?['name'];
  if (jsTruthy(name)) return jsString(name);
  final title = activity?['title'];
  if (jsTruthy(title)) return jsString(title);
  final order = activity?['order'];
  final fallback = 'Activity ${jsTruthy(order) ? jsString(order) : ''}'.trim();
  return fallback.isNotEmpty ? fallback : 'Untitled Activity';
}

/// `getActivitiesForChapter(chapterId)` — note the web's strict
/// `topic.chapter_id === chapterId` (a string/number mismatch matches nothing).
List<Map<String, dynamic>> activitiesForChapter(List<dynamic> allActivitiesData, Object? chapterId) {
  final out = <Map<String, dynamic>>[];
  for (final raw in allActivitiesData) {
    final topic = asMap(raw);
    if (topic == null || topic['chapter_id'] != chapterId) continue;
    for (final a in asList(topic['activities'])) {
      out.add({
        ...?asMap(a),
        'chapter_id': topic['chapter_id'],
        'topic_id': topic['id'],
        'topic_name': topic['name'],
      });
    }
  }
  return out;
}

/// `filteredTopics` — topics of the selected chapter (`String` compare);
/// empty when no chapter or "all-activities" is selected.
List<Map<String, dynamic>> topicsForChapter(List<dynamic> allActivitiesData, Object? selectedChapterId) {
  if (!jsTruthy(selectedChapterId) || selectedChapterId == 'all-activities') return const [];
  return [
    for (final t in allActivitiesData.map(asMap).whereType<Map<String, dynamic>>())
      if (sameId(t['chapter_id'], selectedChapterId)) t,
  ];
}

/// The `{ text, url }` the activity page's content tabs show.
class TabContent {
  TabContent([this.text = '', this.url = '']);
  String text;
  String url;
}

/// The seven workspace tabs (`tabs` in activitylibrary.vue).
const libraryTabKeys = [
  'activity',
  'why-to-learn',
  'reference-video',
  'teacher-guide',
  'learning-outcome',
  'how-to-play',
  'quiz',
];

/// `filteredTabs` — institute users get no Quiz tab.
List<String> visibleTabKeys(String? role) =>
    role == 'institute' ? libraryTabKeys.where((t) => t != 'quiz').toList() : libraryTabKeys;

/// `isInstructorQuizMode`.
bool isInstructorQuizRole(String? role) {
  final r = (role ?? '').toLowerCase();
  return r.contains('instructor') || r.contains('teacher') || r.contains('admin');
}

/// The workspace `:style` height rule: `true` → `calc(85dvh)`,
/// `false` → `auto` (content decides; min 350px unless TG/LO with url + text).
bool workspaceHasFixedHeight(String tab, TabContent content) {
  if ((tab == 'teacher-guide' || tab == 'learning-outcome') &&
      content.url.isNotEmpty &&
      content.text.isNotEmpty) {
    return false;
  }
  return const ['activity', 'reference-video', 'teacher-guide', 'learning-outcome'].contains(tab);
}

/// "How to play": autopilots with an id and a content path; the one in the
/// current language, else the first.
Map<String, dynamic>? pickAutopilot(dynamic autopilots, Object? languageId) {
  final list = [
    for (final a in asList(autopilots).map(asMap).whereType<Map<String, dynamic>>())
      if (jsTruthy(a['id']) && jsTruthy(a['content_path'])) a,
  ];
  for (final a in list) {
    if (sameId(a['language_id'], languageId)) return a;
  }
  return list.isEmpty ? null : list.first;
}

/// `x.map(i => i.text || i.content || '').join('\n\n')` for the
/// instructions / observations arrays.
String joinTexts(dynamic items) => asList(items).map((raw) {
      final x = asMap(raw);
      final v = jsOr([x?['text'], x?['content'], '']);
      return v is String ? v : jsString(v);
    }).join('\n\n');

/// Builds the Reference Video tab HTML exactly like the web: YouTube /
/// Vimeo links become embed iframes, raw `<iframe>` snippets are kept.
/// Throws [FormatException] where `new URL(video)` would throw.
String referenceVideosHtml(List<dynamic> videos) {
  final buf = StringBuffer();
  for (final raw in videos) {
    final item = asMap(raw);
    final v = item?['video'];
    var video = jsTruthy(v) ? jsString(v) : '';

    if (!video.contains('<iframe')) {
      if (video.contains('youtube.com') || video.contains('youtu.be')) {
        String id;
        if (video.contains('youtu.be/')) {
          id = video.split('youtu.be/')[1].split('?')[0];
        } else {
          final uri = Uri.parse(video);
          if (!uri.hasScheme) throw FormatException('Invalid URL', video);
          id = uri.queryParameters['v'] ?? 'null';
        }
        video = '''

          <iframe
            src="https://www.youtube.com/embed/$id"
            allowfullscreen>
          </iframe>
        ''';
      }

      if (video.contains('vimeo.com')) {
        final id = video.split('/').last;
        video = '''

          <iframe
            src="https://player.vimeo.com/video/$id"
            allowfullscreen>
          </iframe>
        ''';
      }
    }

    buf.write('''

      <div class="reference-video-item">
        $video
      </div>
    ''');
  }
  return buf.toString();
}

/// The `<style>` block of activitylibrary.vue for the video wrapper
/// (`.video-wrapper` + `.reference-video-item`), plus what
/// `styleVideoIframe()` forced inline (full-size, border-less iframes).
const referenceVideoCss = '''
<style>
  html,body{height:100%;margin:0;padding:0;background:transparent;}
  .video-wrapper{display:flex;flex-direction:column;gap:20px;width:100%;height:100%;padding:16px;overflow-y:auto;overflow-x:hidden;box-sizing:border-box;}
  .reference-video-item{width:100%;aspect-ratio:16/9;min-height:320px;border-radius:12px;overflow:hidden;background:#000;flex-shrink:0;}
  .reference-video-item iframe,.reference-video-item video,.reference-video-item embed,.reference-video-item object{width:100%!important;height:100%!important;max-width:none!important;max-height:none!important;display:block;border:0!important;border-radius:12px;}
  .reference-video-item p,.reference-video-item div{margin:0;padding:0;width:100%;height:100%;}
  @media (max-width:640px){.video-wrapper{padding:10px;gap:14px;}.reference-video-item{min-height:220px;}}
  @media (min-width:641px) and (max-width:1024px){.reference-video-item{min-height:300px;}}
  @media (min-width:1025px){.reference-video-item{min-height:420px;}}
</style>
''';

/// The page `WebContentView(html:)` gets for the Reference Video tab.
String referenceVideoPage(String itemsHtml) =>
    '$referenceVideoCss<div class="video-wrapper">$itemsHtml</div>';

/// JS `err.message` for `'Failed to load classes: ' + (err.message || 'Unknown error')`.
String jsErrorMessage(Object error) {
  if (error is DioException) {
    final status = error.response?.statusCode;
    if (status != null) return 'Request failed with status code $status';
    return error.message ?? 'Network Error';
  }
  if (error is ApiError) return error.message;
  return 'Unknown error';
}

/// `error?.response?.data?.message || error?.message || fallback`.
String responseMessage(Object error, String fallback) {
  if (error is DioException) {
    final m = dig(error.response?.data, ['message']);
    if (jsTruthy(m)) return jsString(m);
    return jsErrorMessage(error);
  }
  if (error is ApiError && error.message.isNotEmpty) return error.message;
  return fallback;
}
