import 'package:dio/dio.dart';
import 'package:elab_app/features/offline/offline_material.dart';
import 'package:elab_app/widgets/content_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'activity and topic thumbnails are embedded once and render from memory',
    () async {
      final client = Dio();
      addTearDown(() => client.close(force: true));
      var downloads = 0;
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            downloads++;
            handler.resolve(
              Response<List<int>>(
                requestOptions: request,
                data: [1, 2, 3],
                headers: Headers.fromMap({
                  'content-type': ['image/png'],
                }),
              ),
            );
          },
        ),
      );
      final result =
          await OfflineMaterial(client).prepare({
                'file_path': 'https://images.example/thumbnail.png',
                'topic': {'file_path': 'https://images.example/thumbnail.png'},
              })
              as Map;
      expect(downloads, 1);
      expect(result['file_path'], 'data:image/png;base64,AQID');
      expect(result['topic']['file_path'], result['file_path']);
      expect(
        contentImage(result['file_path'] as String).image,
        isA<MemoryImage>(),
      );
    },
  );
  test(
    'relative and lazy images use the document base and missing MIME is detected',
    () async {
      final client = Dio();
      addTearDown(() => client.close(force: true));
      final urls = <String>[];
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            urls.add(options.uri.toString());
            handler.resolve(
              Response<List<int>>(
                requestOptions: options,
                data: [137, 80, 78, 71, 13, 10, 26, 10],
              ),
            );
          },
        ),
      );
      final result =
          await OfflineMaterial(client).prepare({
                'thumbnail': '/images/thumb.png',
                'description':
                    '<img src="placeholder.png" data-src="lesson.png"><img srcset="other.png 1x, large.png 2x">',
              }, base: Uri.parse('https://content.example/guide/page.html'))
              as Map;
      expect(urls, [
        'https://content.example/images/thumb.png',
        'https://content.example/guide/lesson.png',
        'https://content.example/guide/other.png',
      ]);
      expect(result['thumbnail'], startsWith('data:image/png;base64,'));
      expect(result['description'], isNot(contains('src="placeholder.png"')));
      expect(result['description'], contains('src="data:image/png;base64,'));
    },
  );

  test(
    'failed thumbnails retry and do not silently save remote URLs',
    () async {
      final client = Dio();
      addTearDown(() => client.close(force: true));
      var attempts = 0;
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            attempts++;
            handler.reject(
              DioException(
                requestOptions: options,
                type: DioExceptionType.connectionError,
              ),
            );
          },
        ),
      );
      await expectLater(
        OfflineMaterial(
          client,
        ).prepareThumbnail('https://content.example/a.png'),
        throwsA(isA<DioException>()),
      );
      expect(attempts, 3);
    },
  );
  test('missing images do not block lessons or store remote URLs', () async {
    final client = Dio();
    addTearDown(() => client.close(force: true));
    var calls = 0;
    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          calls++;
          handler.reject(
            DioException(
              requestOptions: request,
              response: Response(requestOptions: request, statusCode: 404),
              type: DioExceptionType.badResponse,
            ),
          );
        },
      ),
    );
    final material = OfflineMaterial(client);
    final result =
        await material.prepare({
              'thumbnail': 'https://content.example/missing.png',
              'description':
                  '<p>Lesson text</p><img src="https://content.example/missing.png" alt="Diagram"><p>Next step</p>',
            })
            as Map;
    expect(calls, 1);
    expect(result['thumbnail'], '');
    expect(
      contentImage(result['thumbnail'] as String).image,
      isA<MemoryImage>(),
    );
    expect(result['description'], contains('Lesson text'));
    expect(result['description'], contains('[Image unavailable: Diagram]'));
    expect(result['description'], contains('Next step'));
    expect(result['description'], isNot(contains('https://')));
  });
}
