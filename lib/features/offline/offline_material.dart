import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:html/parser.dart' as html;

/// Inline image bytes are part of the encrypted content snapshot, not remote
/// references that stop working when a signed URL expires.
class OfflineMaterial {
  OfflineMaterial(this.client);
  final Dio client;
  final _images = <String, String>{};
  static const _imageFields = {
    'file_path',
    'image',
    'image_url',
    'thumbnail',
    'thumbnail_url',
    'thumbnail_path',
    'cover_image',
    'preview_image',
  };

  Future<String> prepareThumbnail(String source, {Uri? base}) async {
    source = source.trim();
    if (source.isEmpty || source.startsWith('data:image/')) return source;
    var uri = Uri.tryParse(source);
    if (uri != null && !uri.hasScheme && base != null)
      uri = base.resolveUri(uri);
    if (uri == null || !['http', 'https'].contains(uri.scheme)) {
      throw const FormatException(
        'An image address could not be resolved. Please prepare again online.',
      );
    }
    final url = uri.toString();
    if (_images.containsKey(url)) return _images[url]!;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        final response = await client.get<List<int>>(
          url,
          options: Options(responseType: ResponseType.bytes),
        );
        final bytes = response.data;
        var mime =
            response.headers.value('content-type')?.split(';').first.trim() ??
            '';
        if (!mime.startsWith('image/') && bytes != null) {
          if (bytes.length >= 8 &&
              bytes[0] == 137 &&
              bytes[1] == 80 &&
              bytes[2] == 78 &&
              bytes[3] == 71) {
            mime = 'image/png';
          } else if (bytes.length >= 3 &&
              bytes[0] == 255 &&
              bytes[1] == 216 &&
              bytes[2] == 255) {
            mime = 'image/jpeg';
          } else if (bytes.length >= 6 &&
              ascii
                  .decode(bytes.take(6).toList(), allowInvalid: true)
                  .startsWith('GIF8')) {
            mime = 'image/gif';
          } else if (bytes.length >= 12 &&
              ascii.decode(bytes.sublist(0, 4), allowInvalid: true) == 'RIFF' &&
              ascii.decode(bytes.sublist(8, 12), allowInvalid: true) ==
                  'WEBP') {
            mime = 'image/webp';
          }
        }
        if (!mime.startsWith('image/') || bytes == null || bytes.isEmpty) {
          throw const FormatException(
            'An image could not be saved. Please prepare again online.',
          );
        }
        return _images[url] = 'data:$mime;base64,' + base64Encode(bytes);
      } on DioException catch (error) {
        if (error.response?.statusCode == 404) {
          // A missing server image cannot be repaired by retrying the whole
          // package. Keep the lesson, without storing a remote-only URL.
          return _images[url] = '';
        }
        if (attempt == 2) rethrow;
        await Future<void>.delayed(Duration(milliseconds: 200 * (attempt + 1)));
      }
    }
    throw StateError('Image preparation did not finish.');
  }

  Future<dynamic> prepare(dynamic value, {Uri? base}) async {
    if (value is Map) {
      final result = <String, dynamic>{};
      for (final entry in value.entries) {
        result['${entry.key}'] =
            _imageFields.contains('${entry.key}') &&
                entry.value is String &&
                !RegExp(
                  r'\.(pdf|html?|txt|mp4|webm|docx?)(\?|$)',
                  caseSensitive: false,
                ).hasMatch(entry.value as String)
            ? await prepareThumbnail(entry.value as String, base: base)
            : await prepare(entry.value, base: base);
      }
      return result;
    }
    if (value is List) {
      return Future.wait(value.map((item) => prepare(item, base: base)));
    }
    if (value is! String ||
        !RegExp(r'<img\b', caseSensitive: false).hasMatch(value))
      return value;
    final fullDocument = RegExp(
      r'<html[\s>]|<!doctype',
      caseSensitive: false,
    ).hasMatch(value);
    final fragment = html.parse(value);
    for (final image in fragment.querySelectorAll('img')) {
      final candidates = [
        image.attributes['data-src'],
        image.attributes['data-original'],
        image.attributes['data-lazy-src'],
        image.attributes['src'],
      ];
      var source =
          candidates
              .whereType<String>()
              .where((s) => s.trim().isNotEmpty)
              .firstOrNull ??
          '';
      if (source.isEmpty) {
        final srcset =
            image.attributes['data-srcset'] ?? image.attributes['srcset'] ?? '';
        source = srcset.split(',').first.trim().split(RegExp(r'\s+')).first;
      }
      image.attributes.remove('srcset');
      image.attributes.remove('data-srcset');
      final uri = Uri.tryParse(source);
      if (!source.startsWith('data:image/') &&
          (uri == null ||
              (!uri.hasScheme && base == null) ||
              (uri.hasScheme && !['http', 'https'].contains(uri.scheme)))) {
        image.replaceWith(
          html
              .parseFragment('<span>[Image unavailable offline]</span>')
              .nodes
              .first,
        );
        continue;
      }
      final prepared = await prepareThumbnail(source, base: base);
      if (prepared.isEmpty) {
        final placeholder = html.parseFragment('<span></span>').children.first
          ..text = image.attributes['alt']?.trim().isNotEmpty == true
              ? '[Image unavailable: ' + image.attributes['alt']! + ']'
              : '[Image unavailable]';
        image.replaceWith(placeholder);
      } else {
        image.attributes['src'] = prepared;
      }
    }
    return fullDocument ? fragment.outerHtml : fragment.body!.innerHtml;
  }

  Future<Uint8List> prepareFile(
    List<int> bytes,
    String extension,
    Uri source,
  ) async {
    if (!['html', 'htm', 'txt'].contains(extension))
      return Uint8List.fromList(bytes);
    return Uint8List.fromList(
      utf8.encode(await prepare(utf8.decode(bytes), base: source) as String),
    );
  }
}
