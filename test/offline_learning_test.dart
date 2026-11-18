import 'dart:io';

import 'package:elab_app/core/network/api_client.dart';
import 'package:elab_app/data/models/session.dart';
import 'package:elab_app/features/offline/offline_database.dart';
import 'package:elab_app/features/offline/offline_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:elab_app/features/offline/offline_activity_page.dart';
import 'package:elab_app/state/providers.dart';
import 'package:elab_app/state/lab_practice.dart';

class RecordingApi extends ApiClient {
  RecordingApi()
    : super(tokenReader: () => 'test', onUnauthorized: () async {});
  bool fail = true;
  final requests = <dynamic>[];
  @override
  Future<dynamic> post(
    String path, {
    Object? data,
    Map<String, dynamic>? query,
    bool silent = false,
    options,
  }) async {
    requests.add(data);
    if (fail) throw StateError('Disconnected');
    final body = data as Map<String, dynamic>;
    return {
      'events': [
        for (final event in body['events'] as List)
          {'id': event['id'], 'status': 'saved'},
      ],
    };
  }
}

void main() {
  late OfflineDatabase db;
  setUp(() => db = OfflineDatabase(sqlite3.openInMemory()));
  tearDown(() => db.close());

  test(
    'content and unsent events survive closing and reopening SQLite',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'elab-offline-test-',
      );
      final file = File('${directory.path}/offline.sqlite');
      var disk = OfflineDatabase(sqlite3.open(file.path));
      try {
        disk.install(
          'a',
          {'id': 'pack', 'class_id': 10, 'language_id': 1},
          [
            {'id': 100},
          ],
        );
        final id = disk.enqueue('a', {
          'pack_id': 'pack',
          'kind': 'session',
          'student_id': 17,
        });
        disk.close();
        disk = OfflineDatabase(sqlite3.open(file.path));
        expect(disk.activities('a', 'pack').single['id'], 100);
        expect(disk.pending('a').single['id'], id);
        expect(disk.pending('a').single['student_id'], 17);
      } finally {
        disk.close();
        await file.delete();
        await directory.delete();
      }
    },
  );

  test(
    'failed upload retains exact UUID, student and payload for retry',
    () async {
      final api = RecordingApi();
      final service = OfflineService(
        () => const SessionState(
          userInfo: UserInfo(
            id: 1,
            username: 'lab',
            token: 'test',
            instituteId: 2,
          ),
        ),
        () => api,
        () async => db,
      );
      final id = db.enqueue(service.scope, {
        'kind': 'session',
        'student_id': 17,
        'batch_id': 4,
        'session_id': 'session',
        'sequence': 0,
        'duration_seconds': 10,
      });
      await expectLater(service.sync(), throwsStateError);
      expect(db.pending(service.scope).single['id'], id);
      api.fail = false;
      await service.sync();
      expect(api.requests[0], api.requests[1]);
      expect(db.pending(service.scope), isEmpty);
      expect(db.records(service.scope).single['student_id'], 17);
      expect(db.records(service.scope).single['sync_status'], 'saved');
    },
  );

  test('SQLite content, drafts and outbox are isolated between accounts', () {
    db.install(
      'a',
      {'id': 'pack', 'class_id': 10, 'language_id': 1},
      [
        {'id': 100},
      ],
    );
    db.saveDraft('a', 'student17', 'pack', '100', {'11': '22'});
    db.enqueue('a', {'pack_id': 'pack', 'kind': 'session'});
    expect(db.packs('b'), isEmpty);
    expect(db.activities('b', 'pack'), isEmpty);
    expect(db.draft('b', 'student17', 'pack', '100'), isEmpty);
    expect(db.pending('b'), isEmpty);
    expect(() => db.removePack('a', 'pack'), throwsStateError);
  });

  test('failed installation keeps previous active package', () {
    db.install(
      'a',
      {'id': 'old', 'class_id': 10, 'language_id': 1},
      [
        {'id': 100},
      ],
    );
    expect(
      () => db.install(
        'a',
        {'id': 'new', 'class_id': 10, 'language_id': 1},
        [
          {'id': 100},
          {'id': 100},
        ],
      ),
      throwsFormatException,
    );
    expect(db.packs('a').single['id'], 'old');
  });

  test(
    'quiz submission saves attempt and outbox atomically and clears only its draft',
    () {
      db.saveDraft('a', 'student17', 'pack', '100', {'11': '22'});
      db.saveDraft('a', 'student18', 'pack', '100', {'11': '23'});
      db.saveAttempt(
        'a',
        'student17',
        {
          'kind': 'quiz',
          'pack_id': 'pack',
          'activity_id': '100',
          'student_id': 17,
        },
        {'correct': 1, 'total': 1},
      );
      expect(db.draft('a', 'student17', 'pack', '100'), isEmpty);
      expect(db.draft('a', 'student18', 'pack', '100'), {'11': '23'});
      final event = db.pending('a').single;
      db.acknowledge('a', event['id'], 'forwarded', null, {'confirmed': true});
      expect(db.attempts('a', 'student17', '100').single['receipt'], {
        'confirmed': true,
      });
    },
  );

  test(
    'quiz without an answer key stays provisional instead of showing a false score',
    () {
      final questions = <Map<String, dynamic>>[
        {
          'id': 11,
          'options': [
            {'id': 22},
            {'id': 23},
          ],
        },
      ];
      expect(gradeOfflineQuiz(questions, {'11': '22'})['correct'], isNull);
      expect(() => gradeOfflineQuiz(questions, {'11': '99'}), throwsStateError);
    },
  );

  testWidgets(
    'offline completion freezes selected student and supplies session protocol fields',
    (tester) async {
      const session = SessionState(
        userInfo: UserInfo(
          id: 1,
          username: 'lab',
          token: 'test',
          instituteId: 2,
          isLabAdmin: true,
          role: Role.instructor,
        ),
      );
      final service = OfflineService(
        () => session,
        () => RecordingApi(),
        () async => db,
      );
      final container = ProviderContainer(
        overrides: [
          initialSessionProvider.overrideWithValue(session),
          offlineServiceProvider.overrideWithValue(service),
        ],
      );
      container
          .read(labPracticeProvider.notifier)
          .set(
            const LabPractice(
              token: 'test',
              practice: true,
              classId: 10,
              batchId: 4,
              student: {'id': 17},
            ),
          );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: OfflineActivityPage(
              pack: {
                'id': 'pack',
                'class_id': 10,
                'expires_at': DateTime.now()
                    .add(const Duration(days: 1))
                    .toUtc()
                    .toIso8601String(),
              },
              activities: const [
                {'id': 100, 'name': 'Activity', 'questions': []},
              ],
              initialActivityId: '100',
            ),
          ),
        ),
      );
      await tester.pump();
      container
          .read(labPracticeProvider.notifier)
          .set(
            const LabPractice(
              token: 'test',
              practice: true,
              classId: 10,
              batchId: 4,
              student: {'id': 18},
            ),
          );
      await tester.tap(find.byTooltip('Learning options'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Finish activity'));
      await tester.pump();
      final completion = db
          .pending(service.scope)
          .where((e) => e['kind'] == 'completion')
          .single;
      expect(completion['student_id'], 17);
      expect(completion['batch_id'], 4);
      expect(completion['session_id'], matches(RegExp(r'^[0-9a-f-]{36}$')));
      expect(completion['sequence'], isA<int>());
      await tester.pumpWidget(const SizedBox.shrink());
      container.dispose();
    },
  );
}
