import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:elab_app/core/network/api_client.dart';
import 'package:flutter_test/flutter_test.dart';

class DisconnectedAdapter implements HttpClientAdapter {
  int calls = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    throw DioException(
      requestOptions: options,
      type: DioExceptionType.connectionError,
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('local backend responses cannot prove internet connectivity', () async {
    final reports = <bool>[];
    final client = ApiClient(
      baseUrl: 'http://127.0.0.1:8010/api/v1',
      tokenReader: () => 'test',
      onUnauthorized: () async {},
      onReachabilityChanged: reports.add,
    );
    addTearDown(() => client.dio.close(force: true));
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          handler.resolve(
            Response(requestOptions: request, statusCode: 200, data: []),
            true,
          );
        },
      ),
    );
    await client.get('/lab-admin/practice-options', silent: true);
    expect(reports, isEmpty);
    await client.post('/zsl/classes', silent: true);
    expect(reports, isEmpty);
  });

  test(
    'curriculum server failure uses prepared data without claiming internet loss',
    () async {
      final reports = <bool>[];
      final client = ApiClient(
        baseUrl: 'http://127.0.0.1:8010/api/v1',
        tokenReader: () => 'test',
        onUnauthorized: () async {},
        onReachabilityChanged: reports.add,
        readOffline: (path, query) async => [
          {'id': 58},
        ],
      );
      addTearDown(() => client.dio.close(force: true));
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            handler.reject(
              DioException(
                requestOptions: request,
                type: DioExceptionType.badResponse,
                response: Response(requestOptions: request, statusCode: 503),
              ),
              true,
            );
          },
        ),
      );
      expect(
        (await client.post('/zsl/classes', silent: true)).single['id'],
        58,
      );
      expect(reports, isEmpty);
    },
  );

  test('provider DNS failure switches curriculum to local mode', () async {
    final reachability = <bool>[];
    final client = ApiClient(
      baseUrl: 'https://example.test',
      tokenReader: () => 'test',
      onUnauthorized: () async {},
      onReachabilityChanged: reachability.add,
      readOffline: (path, query) async => [
        {'id': 58},
      ],
    );
    addTearDown(() => client.dio.close(force: true));
    client.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (request, handler) {
          handler.reject(
            DioException(
              requestOptions: request,
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: request,
                statusCode: 417,
                data: {
                  'message':
                      'cURL error 6: Could not resolve host: content.example',
                },
              ),
            ),
            true,
          );
        },
      ),
    );
    final classes = await client.post('/zsl/classes', silent: true);
    expect(classes.single['id'], 58);
    expect(reachability, [true]);
  });

  test(
    'preparation reaches dev backend even when curriculum is offline',
    () async {
      var localReads = 0;
      final paths = <String>[];
      final client = ApiClient(
        baseUrl: 'http://127.0.0.1:8010/api/v1',
        tokenReader: () => 'test',
        onUnauthorized: () async {},
        isOffline: () => true,
        readOffline: (path, query) async {
          localReads++;
          return [];
        },
      );
      addTearDown(() => client.dio.close(force: true));
      client.dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            paths.add(request.path);
            expect(request.headers['Authorization'], 'Bearer test');
            handler.resolve(
              Response(
                requestOptions: request,
                statusCode: 200,
                data: {'id': 'pack'},
              ),
            );
          },
        ),
      );
      await client.get('/offline/context', silent: true);
      await client.post(
        '/offline/packages',
        data: {'class_id': 22, 'language_id': 3},
        silent: true,
      );
      expect(paths, ['/offline/context', '/offline/packages']);
      expect(localReads, 0);
    },
  );

  test(
    'first disconnected class request falls back and subsequent reads stay local',
    () async {
      var offline = false;
      final localPaths = <String>[];
      final client = ApiClient(
        baseUrl: 'https://example.test',
        tokenReader: () => 'test',
        onUnauthorized: () async {},
        isOffline: () => offline,
        onReachabilityChanged: (reachable) => offline = !reachable,
        readOffline: (path, query) async {
          localPaths.add(path);
          return [
            {'id': 58, 'name': 'Class 10'},
          ];
        },
      );
      final adapter = DisconnectedAdapter();
      client.dio.httpClientAdapter = adapter;
      addTearDown(() => client.dio.close(force: true));

      final classes = await client.post(
        '/zsl/classes',
        data: {'institute_id': 1},
      );
      expect(classes.single['id'], 58);
      expect(offline, isTrue);
      await client.post('/zsl/subjects', data: {'zsl_class_id': 58});
      expect(localPaths, ['/zsl/classes', '/zsl/subjects']);
      expect(adapter.calls, 1);
      expect(offline, isTrue);
    },
  );
}
