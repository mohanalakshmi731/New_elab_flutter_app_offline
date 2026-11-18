import 'package:dio/dio.dart';
import 'package:elab_app/core/network/api_client.dart';
import 'package:elab_app/data/models/session.dart';
import 'package:elab_app/features/offline/offline_database.dart';
import 'package:elab_app/features/offline/offline_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

class PackageApi extends ApiClient {
  PackageApi(this.status)
    : super(tokenReader: () => 'test', onUnauthorized: () async {});
  final int status;
  int creations = 0;
  @override
  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? query,
    bool silent = false,
    Options? options,
  }) async {
    final request = RequestOptions(path: path);
    throw DioException(
      requestOptions: request,
      response: Response(requestOptions: request, statusCode: status),
      type: DioExceptionType.badResponse,
    );
  }

  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool silent = false,
    Options? options,
  }) async {
    creations++;
    return {
      'id': 'replacement',
      'class_id': 10,
      'language_id': 1,
      'expires_at': DateTime.now()
          .add(const Duration(days: 1))
          .toIso8601String(),
      'chapters': [],
    };
  }
}

void main() {
  for (final status in [404, 403, 503]) {
    test(
      'resuming package HTTP $status recreates only a missing package and preserves installed content',
      () async {
        final db = OfflineDatabase(sqlite3.openInMemory());
        addTearDown(db.close);
        final api = PackageApi(status);
        addTearDown(() => api.dio.close(force: true));
        final service = OfflineService(
          () => const SessionState(
            userInfo: UserInfo(
              id: 1,
              instituteId: 2,
              username: 'test',
              token: 'test',
            ),
          ),
          () => api,
          () async => db,
        );
        final pack = {
          'id': 'old',
          'class_id': 10,
          'language_id': 1,
          'expires_at': DateTime.now()
              .add(const Duration(days: 1))
              .toIso8601String(),
        };
        db.saveDownload(service.scope, 10, 1, pack);
        db.install(service.scope, pack, [
          {'id': 101},
        ]);
        final event = db.enqueue(service.scope, {
          'pack_id': 'old',
          'kind': 'completion',
        });
        // Empty replacement chapters stop preparation before writing any files.
        await expectLater(
          service.prepare(10, 1, (_) {}),
          status == 404 ? throwsStateError : throwsA(isA<DioException>()),
        );
        expect(api.creations, status == 404 ? 1 : 0);
        expect(
          db.download(service.scope, 10, 1)?['id'],
          status == 404 ? 'replacement' : 'old',
        );
        expect(db.activities(service.scope, 'old').single['id'], 101);
        expect(db.pending(service.scope).single['id'], event);
      },
    );
  }
}
