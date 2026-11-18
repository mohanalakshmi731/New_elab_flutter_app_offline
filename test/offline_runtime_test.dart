import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:elab_app/core/network/api_client.dart';
import 'package:elab_app/data/models/session.dart';
import 'package:elab_app/features/offline/offline_cipher.dart';
import 'package:elab_app/features/offline/offline_database.dart';
import 'package:elab_app/features/offline/offline_material.dart';
import 'package:elab_app/features/offline/offline_runtime.dart';
import 'package:elab_app/features/offline/offline_service.dart';
import 'package:elab_app/state/providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

class FakeOfflineService extends OfflineService {
  FakeOfflineService()
    : super(
        () => const SessionState(
          userInfo: UserInfo(
            id: 1,
            instituteId: 2,
            username: 'lab',
            token: 'test',
          ),
        ),
        () => ApiClient(tokenReader: () => 'test', onUnauthorized: () async {}),
        () async => throw UnimplementedError(),
      );
  int preparations = 0, uploads = 0;
  void Function()? onSync;
  final finished = Completer<void>();
  @override
  Future<Map<String, dynamic>> refreshContext() async => {};
  @override
  Future<void> sync() async {
    uploads++;
    onSync?.call();
  }

  @override
  Future<void> prepare(
    int classId,
    int languageId,
    void Function(String) progress, {
    bool Function()? cancelled,
  }) async {
    preparations++;
    progress('Preparing supporting content');
    await finished.future;
  }
}

class BlockingSyncService extends FakeOfflineService {
  final uploadFinished = Completer<void>();
  @override
  Future<void> sync() async {
    if (uploads > 0) return;
    uploads++;
    await uploadFinished.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'reconnect sync keeps the prepared catalog revision stable during local learning',
    (tester) async {
      final service = FakeOfflineService();
      var online = false;
      final container = ProviderContainer(
        overrides: [
          initialSessionProvider.overrideWithValue(service.session()),
          offlineServiceProvider.overrideWithValue(service),
          offlineNetworkAdaptersProvider.overrideWithValue(
            () async => 'Wi-Fi:192.168.1.2',
          ),
          offlineReachabilityProvider.overrideWithValue(() async => online),
        ],
      );
      final runtime = container.read(offlineRuntimeProvider.notifier);
      container.read(offlineLocalModeProvider.notifier).state = true;
      await tester.pump();
      final revision = container.read(offlineRuntimeProvider).revision;
      online = true;
      await runtime.check();
      await runtime.check();
      await runtime.check();
      expect(service.uploads, 3);
      expect(
        container.read(offlineRuntimeProvider).revision,
        revision,
        reason:
            'Background uploads must not remount the prepared learning screen',
      );
      expect(container.read(offlineBrowsingProvider), true);
      container.dispose();
    },
  );

  testWidgets(
    'one slow probe during preparation does not change connection mode',
    (tester) async {
      final service = FakeOfflineService();
      var online = true;
      final container = ProviderContainer(
        overrides: [
          initialSessionProvider.overrideWithValue(service.session()),
          offlineServiceProvider.overrideWithValue(service),
          offlineNetworkAdaptersProvider.overrideWithValue(
            () async => 'Wi-Fi:192.168.1.2',
          ),
          offlineReachabilityProvider.overrideWithValue(() async => online),
          offlineNoticeProvider.overrideWithValue((_, _) {}),
        ],
      );
      final runtime = container.read(offlineRuntimeProvider.notifier);
      await tester.pump();
      final preparing = runtime.prepare(10, 1);
      await tester.pump();
      online = false;
      await runtime.check();
      expect(container.read(offlineRuntimeProvider).reachable, true);
      expect(container.read(offlineRuntimeProvider).preparing, true);
      online = true;
      runtime.reportReachability(true);
      await runtime.check();
      expect(container.read(offlineRuntimeProvider).reachable, true);
      service.finished.complete();
      await preparing;
      container.dispose();
    },
  );

  testWidgets(
    'repeated independent probe failures confirm offline and success recovers',
    (tester) async {
      final service = FakeOfflineService();
      var online = true;
      final container = ProviderContainer(
        overrides: [
          initialSessionProvider.overrideWithValue(service.session()),
          offlineServiceProvider.overrideWithValue(service),
          offlineNetworkAdaptersProvider.overrideWithValue(
            () async => 'Wi-Fi:192.168.1.2',
          ),
          offlineReachabilityProvider.overrideWithValue(() async => online),
        ],
      );
      final runtime = container.read(offlineRuntimeProvider.notifier);
      await tester.pump();
      online = false;
      runtime.reportReachability(false);
      await tester.pump();
      expect(container.read(offlineRuntimeProvider).reachable, true);
      await runtime.check();
      expect(container.read(offlineRuntimeProvider).reachable, false);
      runtime.reportReachability(true);
      online = true;
      await tester.pump();
      expect(container.read(offlineRuntimeProvider).reachable, true);
      container.dispose();
    },
  );

  testWidgets('a stalled upload cannot prevent disconnect detection', (
    tester,
  ) async {
    final service = BlockingSyncService();
    var online = true;
    final container = ProviderContainer(
      overrides: [
        initialSessionProvider.overrideWithValue(service.session()),
        offlineServiceProvider.overrideWithValue(service),
        offlineNetworkAdaptersProvider.overrideWithValue(
          () async => 'Virtual adapter:192.168.1.2',
        ),
        offlineReachabilityProvider.overrideWithValue(() async => online),
      ],
    );
    final runtime = container.read(offlineRuntimeProvider.notifier);
    await tester.pump();
    expect(service.uploads, 1);
    online = false;
    await runtime.check();
    await runtime.check();
    expect(container.read(offlineRuntimeProvider).reachable, false);
    service.uploadFinished.complete();
    await tester.pump();
    expect(container.read(offlineRuntimeProvider).reachable, false);
    container.dispose();
  });

  test(
    'internet checks reject captive portals and try a fallback endpoint',
    () async {
      final client = Dio();
      addTearDown(() => client.close(force: true));
      var calls = 0;
      var connected = true;
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (request, handler) {
            calls++;
            expect(request.headers['Authorization'], isNull);
            handler.resolve(
              Response<void>(
                requestOptions: request,
                statusCode: connected && request.uri.host == 'cp.cloudflare.com'
                    ? 204
                    : 200,
              ),
            );
          },
        ),
      );
      expect(await checkOfflineInternet(client), true);
      expect(calls, 2);
      connected = false;
      expect(await checkOfflineInternet(client), false);
    },
  );

  testWidgets('adapter disconnect and Ethernet reconnect update status', (
    tester,
  ) async {
    final service = FakeOfflineService();
    var adapters = 'Wi-Fi:192.168.1.2';
    final container = ProviderContainer(
      overrides: [
        initialSessionProvider.overrideWithValue(service.session()),
        offlineServiceProvider.overrideWithValue(service),
        offlineNetworkAdaptersProvider.overrideWithValue(() async => adapters),
        offlineReachabilityProvider.overrideWithValue(() async => true),
      ],
    );
    final runtime = container.read(offlineRuntimeProvider.notifier);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    adapters = '';
    await tester.pump(const Duration(seconds: 2));
    expect(container.read(offlineRuntimeProvider).reachable, false);
    runtime.reportReachability(true);
    expect(container.read(offlineRuntimeProvider).reachable, false);
    adapters = 'Ethernet:192.168.1.3';
    await tester.pump(const Duration(seconds: 2));
    await tester.pump();
    expect(container.read(offlineRuntimeProvider).reachable, true);
    container.dispose();
  });

  for (final staleOnline in [true, false]) {
    testWidgets(
      'stale probe $staleOnline cannot overwrite newer network evidence',
      (tester) async {
        final service = FakeOfflineService();
        final probe = Completer<bool>();
        final container = ProviderContainer(
          overrides: [
            initialSessionProvider.overrideWithValue(service.session()),
            offlineServiceProvider.overrideWithValue(service),
            offlineReachabilityProvider.overrideWithValue(() => probe.future),
          ],
        );
        final runtime = container.read(offlineRuntimeProvider.notifier);
        await tester.pump();
        runtime.reportReachability(!staleOnline, confirmed: true);
        probe.complete(staleOnline);
        await tester.pump();
        expect(container.read(offlineRuntimeProvider).reachable, !staleOnline);
        container.dispose();
      },
    );
  }

  testWidgets('sync completion does not undo a disconnect', (tester) async {
    final service = FakeOfflineService();
    final container = ProviderContainer(
      overrides: [
        initialSessionProvider.overrideWithValue(service.session()),
        offlineServiceProvider.overrideWithValue(service),
        offlineReachabilityProvider.overrideWithValue(() async => true),
      ],
    );
    final runtime = container.read(offlineRuntimeProvider.notifier);
    service.onSync = () => runtime.reportReachability(false, confirmed: true);
    await tester.pump();
    expect(container.read(offlineRuntimeProvider).reachable, false);
    container.dispose();
  });

  test('preparation preserves server errors instead of blaming connectivity', () {
    final request = RequestOptions(path: '/offline/packages');
    final error = DioException(
      requestOptions: request,
      type: DioExceptionType.badResponse,
      response: Response(
        requestOptions: request,
        statusCode: 503,
        data: {
          'message':
              'Offline storage is not installed. The offline migration must be deployed by an administrator.',
        },
      ),
    );
    expect(offlinePreparationError(error), contains('migration'));
    expect(offlinePreparationError(error), isNot(contains('connection')));
    expect(
      offlinePreparationError(StateError('No matching activities.')),
      'No matching activities.',
    );
    expect(
      offlinePreparationError(
        DioException(
          requestOptions: request,
          type: DioExceptionType.connectionError,
        ),
      ),
      contains('internet connection'),
    );
  });

  testWidgets(
    'login checks connectivity and syncs but never prepares without a click',
    (tester) async {
      final service = FakeOfflineService();
      var reachable = false;
      final notices = <String>[];
      final container = ProviderContainer(
        overrides: [
          initialSessionProvider.overrideWithValue(service.session()),
          offlineServiceProvider.overrideWithValue(service),
          offlineReachabilityProvider.overrideWithValue(() async => reachable),
          offlineNoticeProvider.overrideWithValue(
            (text, _) => notices.add(text),
          ),
        ],
      );
      final runtime = container.read(offlineRuntimeProvider.notifier);
      await tester.pump();
      expect(service.preparations, 0);
      expect(service.uploads, 0);
      await runtime.check();
      expect(container.read(offlineRuntimeProvider).reachable, false);
      reachable = true;
      await runtime.check();
      expect(service.uploads, 1);
      expect(service.preparations, 0);
      final task = runtime.prepare(10, 1);
      await tester.pump();
      expect(container.read(offlineRuntimeProvider).preparing, true);
      expect(service.preparations, 1);
      await runtime.prepare(10, 1);
      expect(service.preparations, 1);
      // The app-owned job is independent of the preparation screen.
      await tester.pumpWidget(const SizedBox.shrink());
      service.finished.complete();
      await task;
      expect(container.read(offlineRuntimeProvider).preparing, false);
      expect(notices.first, contains('getting your content ready'));
      expect(notices.last, contains('ready'));
      container.dispose();
    },
  );

  test(
    'sensitive SQLite payloads use authenticated encryption and random nonces',
    () {
      final cipher = OfflineCipher(List.filled(32, 7));
      final db = OfflineDatabase(sqlite3.openInMemory(), cipher: cipher);
      db.saveContext('account', {'student_name': 'Private Student'});
      final raw =
          db.db.select('SELECT payload FROM offline_context').single['payload']
              as String;
      expect(raw, startsWith('enc1:'));
      expect(raw, isNot(contains('Private Student')));
      expect(db.context('account')!['student_name'], 'Private Student');
      expect(cipher.encode({'a': 1}), isNot(cipher.encode({'a': 1})));
      final damaged = cipher.seal(utf8.encode('private'));
      damaged[15] ^= 1;
      expect(() => cipher.unseal(damaged), throwsA(anything));
      db.close();
    },
  );

  test(
    'supporting files are protected on disk and can be replaced and reopened',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'elab-cipher-test-',
      );
      final file = File('${directory.path}/guide.html');
      final cipher = OfflineCipher(List.filled(32, 17));
      try {
        await cipher.write(file, utf8.encode('First guide'));
        await cipher.write(file, utf8.encode('Private guide'));
        expect(
          await file.readAsBytes(),
          isNot(containsAllInOrder(utf8.encode('Private guide'))),
        );
        expect(utf8.decode(await cipher.read(file)), 'Private guide');
        final damaged = await file.readAsBytes();
        damaged[20] ^= 1;
        await file.writeAsBytes(damaged);
        await expectLater(cipher.read(file), throwsA(anything));
      } finally {
        await file.delete();
        await directory.delete();
      }
    },
  );

  test(
    'embedded data images remain available and unsupported image references are removed',
    () async {
      final material = OfflineMaterial(Dio());
      final result = await material.prepare(
        '<p>Guide</p><img src="data:image/png;base64,AAAA"><img src="relative.png">',
      );
      expect(result, contains('data:image/png;base64,AAAA'));
      expect(result, contains('Image unavailable offline'));
      expect(result, isNot(contains('relative.png')));
    },
  );
  test(
    'remote supporting images are downloaded once and embedded in the saved snapshot',
    () async {
      final client = Dio();
      var requests = 0;
      client.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) {
            requests++;
            handler.resolve(
              Response<List<int>>(
                requestOptions: options,
                data: [1, 2, 3],
                headers: Headers.fromMap({
                  'content-type': ['image/png'],
                }),
              ),
            );
          },
        ),
      );
      final material = OfflineMaterial(client);
      final saved = await material.prepare({
        'description': '<img src="https://content.example/image.png">',
        'questions': [
          {'text': '<img src="https://content.example/image.png">'},
        ],
      });
      expect(requests, 1);
      expect(jsonEncode(saved), contains('data:image/png;base64,AQID'));
      expect(
        jsonEncode(saved),
        isNot(contains('https://content.example/image.png')),
      );
      client.close();
    },
  );
}
