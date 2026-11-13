/// Pure helpers shared by `questionslist.vue` (`/questions`) and
/// `newquestions.vue` (`/newquestions`), ported 1:1 from their `methods` /
/// `computed` so they can be unit-tested.
library;

import 'dart:convert';

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';

/// `Locale` from `src/types/enums.ts` (insertion order = `v-for` order).
const questionLocales = <String, String>{
  'All': 'all',
  'Telugu': 'te',
  'English': 'en',
};

/// `defaultLocale`
const defaultQuestionLocale = 'en';

/// Value of the disabled "No … available" row shown in an empty
/// `<SelectContent>` (never equal to a real id or to `''`).
const noOptionsValue = '\u0000none';

/// `getLocaleName(locale)` — the `Locale` key for a value, else the value.
String getLocaleName(Object? locale) {
  for (final e in questionLocales.entries) {
    if (e.value == locale) return e.key;
  }
  return displayValue(locale);
}

/// `truncate(text)` — first 60 UTF-16 units + `...` (raw HTML, like the web).
String? truncate(Object? text) {
  if (text is! String) return text?.toString();
  return text.length > 60 ? '${text.substring(0, 60)}...' : text;
}

/// What Vue's `{{ value }}` prints: `''` for null, JS number formatting
/// (`2`, not `2.0`), objects/arrays as indented JSON.
String displayValue(Object? v) {
  if (v == null) return '';
  if (v is String) return v;
  if (v is num) return jsNumString(v);
  if (v is Map || v is List) {
    try {
      return const JsonEncoder.withIndent('  ').convert(v);
    } catch (_) {
      return v.toString();
    }
  }
  return v.toString();
}

/// JS `String(n)` for a number.
String jsNumString(num n) {
  if (n is double) {
    if (n.isNaN) return 'NaN';
    if (n.isInfinite) return n > 0 ? 'Infinity' : '-Infinity';
    if (n == n.truncateToDouble() && n.abs() < 1e21) return n.toInt().toString();
  }
  return n.toString();
}

/// JS `Number(v)`.
num jsNumber(Object? v) {
  if (v == null) return 0;
  if (v is num) return v;
  if (v is bool) return v ? 1 : 0;
  final s = v.toString().trim();
  if (s.isEmpty) return 0;
  return num.tryParse(s) ?? double.nan;
}

/// A number as JSON would carry it from JS: integral values as ints (`2`, not
/// `2.0`) and NaN/Infinity as `null` (`JSON.stringify(NaN)`).
Object? jsonNumber(num n) {
  if (n is double) {
    if (n.isNaN || n.isInfinite) return null;
    if (n == n.truncateToDouble()) return n.toInt();
  }
  return n;
}

final _leadingFloat = RegExp(r'^\s*[+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?');

/// Vue's `looseToNumber` for `<input type="number" v-model>`: `parseFloat`,
/// or the raw string when that is NaN (e.g. `''` for a cleared input).
Object looseToNumber(String text) {
  final m = _leadingFloat.firstMatch(text);
  if (m == null) return text;
  final n = num.parse(m[0]!.trim());
  return jsonNumber(n) ?? text;
}

/// The message of a caught error as JS `e?.message` would read it: the
/// thrown `Error`'s text, or axios' `Request failed with status code N` /
/// `Network Error` for HTTP failures.
String? jsErrorMessage(Object? e) {
  if (e == null) return null;
  if (e is ApiError) return e.message;
  if (e is DioException) {
    final status = e.response?.statusCode;
    if (status != null) return 'Request failed with status code $status';
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'timeout exceeded';
    }
    return 'Network Error';
  }
  if (e is StateError) return e.message;
  if (e is ArgumentError) return e.message?.toString();
  return e.toString();
}

/// `res?.data ?? res ?? []` — the question list of a `/exam/question` body.
List<Map<String, dynamic>> unwrapQuestions(Object? res) {
  final m = asMap(res);
  final v = (m != null && m['data'] != null) ? m['data'] : res;
  return [for (final e in asList(v)) ?asMap(e)];
}

/// `getVideoType(url)` → `{ type: 'video' | 'iframe' | 'link' | '', src }`.
({String type, String src}) getVideoType(Object? raw) {
  final url = raw is String ? raw : (raw == null ? '' : raw.toString());
  if (url.isEmpty) return (type: '', src: '');
  final lower = url.toLowerCase();
  if (lower.endsWith('.mp4') || lower.endsWith('.webm') || lower.endsWith('.ogg')) {
    return (type: 'video', src: url);
  }
  final ytShort = RegExp(r'youtu\.be/([^?]+)').firstMatch(url);
  if (ytShort != null) return (type: 'iframe', src: 'https://www.youtube.com/embed/${ytShort[1]}');
  final ytLong = RegExp(r'[?&]v=([^&]+)').firstMatch(url);
  if (ytLong != null) return (type: 'iframe', src: 'https://www.youtube.com/embed/${ytLong[1]}');
  final vimeo = RegExp(r'vimeo\.com/(\d+)').firstMatch(url);
  if (vimeo != null) return (type: 'iframe', src: 'https://player.vimeo.com/video/${vimeo[1]}');
  if (url.contains('drive.google.com')) {
    final m = RegExp(r'[-\w]{25,}').firstMatch(url);
    if (m != null) return (type: 'iframe', src: 'https://drive.google.com/file/d/${m[0]}/preview');
  }
  return (type: 'link', src: url);
}

/// `getDirectImage(url)` — Google Drive links → `lh3.googleusercontent.com`.
String getDirectImage(Object? raw) {
  final url = raw is String ? raw : (raw == null ? '' : raw.toString());
  if (url.isEmpty) return url;
  final m = RegExp(r'[-\w]{25,}').firstMatch(url);
  if (url.contains('drive.google.com') && m != null) return 'https://lh3.googleusercontent.com/d/${m[0]}';
  return url;
}

/// `convertDriveUrl(url)` (newquestions) — Drive links → `uc?export=view`.
String convertDriveUrl(String url) {
  if (url.isEmpty || !url.contains('drive.google.com')) return url;
  final id = RegExp(r'/d/([-\w]{25,})').firstMatch(url) ?? RegExp(r'[?&]id=([-\w]{25,})').firstMatch(url);
  if (id == null) return url;
  return 'https://drive.google.com/uc?export=view&id=${id[1]}';
}

/// `qFormVideoEmbedUrl` (newquestions).
String videoEmbedUrl(String raw) {
  final url = raw.trim();
  if (url.isEmpty) return '';
  final yt = RegExp(r'youtube\.com/watch\?v=([^&]+)').firstMatch(url) ?? RegExp(r'youtu\.be/([^?]+)').firstMatch(url);
  if (yt != null) return 'https://www.youtube.com/embed/${yt[1]}';
  final drive = RegExp(r'/d/([-\w]{25,})').firstMatch(url) ?? RegExp(r'[?&]id=([-\w]{25,})').firstMatch(url);
  if (drive != null) return 'https://drive.google.com/file/d/${drive[1]}/preview';
  if (url.endsWith('.mp4')) return url;
  return '';
}

/// The question shown by the preview dialog (`openPreview(q)`): `images`
/// falls back to `[{ id: 'single', image_url }]`, options sorted by
/// `order_index`, plus `videoData`.
class PreviewQuestion {
  const PreviewQuestion({
    required this.raw,
    required this.images,
    required this.options,
    required this.videoType,
    required this.videoSrc,
  });

  final Map<String, dynamic> raw;
  final List<Map<String, dynamic>> images;
  final List<Map<String, dynamic>> options;
  final String videoType;
  final String videoSrc;

  bool get hasVideo => videoSrc.isNotEmpty;
}

PreviewQuestion normalizePreview(Map<String, dynamic> q) {
  final rawImages = q['images'];
  final images = rawImages is List && rawImages.isNotEmpty
      ? [for (final e in rawImages) ?asMap(e)]
      : jsTruthy(q['image_url'])
          ? [
              {'id': 'single', 'image_url': q['image_url']},
            ]
          : <Map<String, dynamic>>[];
  final options = [for (final e in asList(q['options'])) ?asMap(e)];
  if (options.isNotEmpty) options.sort(compareOrderIndex);
  final video = getVideoType(q['video_url']);
  return PreviewQuestion(raw: q, images: images, options: options, videoType: video.type, videoSrc: video.src);
}

/// `(a, b) => a.order_index - b.order_index` (a NaN difference keeps order).
int compareOrderIndex(Map<String, dynamic> a, Map<String, dynamic> b) {
  final d = jsNumber(a['order_index']) - jsNumber(b['order_index']);
  if (d.isNaN || d == 0) return 0;
  return d < 0 ? -1 : 1;
}

/// `String(course?.exam_course_id ?? course?.id ?? '')` for the course whose
/// `id` is [courseId] (`getExamCourseId` / `getImportExamCourseId` /
/// `qFormSelectedCourseExamId`).
String examCourseIdFor(List<Map<String, dynamic>> courses, String courseId) {
  Map<String, dynamic>? course;
  for (final c in courses) {
    if ('${c['id']}' == courseId) {
      course = c;
      break;
    }
  }
  return displayValue(course?['exam_course_id'] ?? course?['id'] ?? '');
}

/// `loadQuestions()` mapping: the content's `exam_section_id` (of its
/// section) and `exam_content_id`. Like the web, `break` only leaves the
/// chapter loop, so a later section with the same content id wins.
({String examSectionId, String examChapterId}) findExamIdsForContent(
    List<Map<String, dynamic>> sections, String contentId) {
  var sectionId = '';
  var chapterId = '';
  for (final section in sections) {
    for (final chapter in asList(section['chapters'])) {
      Map<String, dynamic>? content;
      for (final c in asList(asMap(chapter)?['contents'])) {
        final cm = asMap(c);
        if (cm != null && '${cm['id']}' == contentId) {
          content = cm;
          break;
        }
      }
      if (content != null) {
        sectionId = '${section['exam_section_id']}';
        chapterId = '${content['exam_content_id']}';
        break;
      }
    }
  }
  return (examSectionId: sectionId, examChapterId: chapterId);
}

/// `String(section.exam_section_id ?? section.id)` of the first section that
/// has the chapter [chapterId] (`handleImport` / `saveQuestion`), or `''`.
String examSectionIdForChapter(List<Map<String, dynamic>> sections, String chapterId) {
  for (final section in sections) {
    final chapters = section['chapters'];
    if (chapters is! List) continue;
    for (final ch in chapters) {
      if ('${asMap(ch)?['id']}' == chapterId) {
        return displayValue(section['exam_section_id'] ?? section['id']);
      }
    }
  }
  return '';
}

/// `contents.filter(c => String(c.chapter_id) === chapterId)` (empty when no
/// chapter is selected).
List<Map<String, dynamic>> contentsOfChapter(List<Map<String, dynamic>> contents, String chapterId) {
  if (chapterId.isEmpty) return const [];
  return [for (final c in contents) if ('${c['chapter_id']}' == chapterId) c];
}

/// `onFileChange` extension check: `csv` / `xlsx` only.
bool isCsvOrXlsx(String fileName) {
  final dot = fileName.lastIndexOf('.');
  if (dot < 0) return false;
  final ext = fileName.substring(dot + 1).toLowerCase();
  return ext == 'csv' || ext == 'xlsx';
}

/// `downloadTemplate()` — the one-row CSV (`question_import_template.csv`).
/// `questionslist.vue` puts a YouTube link in `video_url`, `newquestions.vue`
/// leaves it empty.
String buildTemplateCsv({required String videoUrl}) {
  final row = <String, Object>{
    'code': 'Q001',
    'stem': 'What is the capital of France?',
    'question_type': 'MCQ',
    'difficulty_level': 'MEDIUM',
    'marks': 1,
    'negative_marks': 0.25,
    'explanation': 'Paris is the capital of France',
    'tags': 'geography,capital',
    'option_a_label': 'A',
    'option_a_text': 'London',
    'option_a_image_url': '',
    'option_a_correct': 'false',
    'option_b_label': 'B',
    'option_b_text': 'Paris',
    'option_b_image_url': '',
    'option_b_correct': 'true',
    'option_c_label': 'C',
    'option_c_text': 'Berlin',
    'option_c_image_url': '',
    'option_c_correct': 'false',
    'option_d_label': 'D',
    'option_d_text': 'Madrid',
    'option_d_image_url': '',
    'option_d_correct': 'false',
    'question_image_1_url': '',
    'question_image_1_caption': '',
    'video_url': videoUrl,
  };
  final headers = row.keys.toList();
  final values = [
    for (final h in headers)
      switch (row[h]) {
        final String s when s.contains(',') => '"$s"',
        final Object v => displayValue(v),
        null => '',
      },
  ];
  return [headers.join(','), values.join(',')].join('\n');
}

/// `language.name.toLowerCase().slice(0, 2)`
String localeFromLanguageName(String name) {
  final lower = name.toLowerCase();
  return lower.length > 2 ? lower.substring(0, 2) : lower;
}

/// `res?.data?.file_url || res?.file_url || res?.url` (uploadExamFile).
String uploadedFileUrl(Object? res) {
  final m = asMap(res);
  final v = [asMap(m?['data'])?['file_url'], m?['file_url'], m?['url']].firstWhere(jsTruthy, orElse: () => null);
  return v == null ? '' : displayValue(v);
}
