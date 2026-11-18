import 'dart:typed_data';
import 'package:sqlite3/sqlite3.dart';
import 'package:elab_app/features/offline/offline_database.dart';
import 'package:elab_app/features/offline/offline_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:elab_app/core/network/api_client.dart';
import 'package:elab_app/features/offline/prepared_catalog.dart';
import 'package:elab_app/data/services/zsl_service.dart';
import 'package:elab_app/data/models/session.dart';

class NoNetwork implements HttpClientAdapter {
  int calls = 0;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    calls++;
    throw StateError('Offline request reached network');
  }

  @override
  void close({bool force = false}) {}
}

PreparedCatalog sample() => PreparedCatalog([
  (
    pack: {
      'id': 'pack',
      'class_name': 'Class X - A',
      'chapters': [
        {
          'id': '221',
          'zsl_class_id': '58',
          'subject_id': '4',
          'subject_name': 'Math',
          'subject': {'id': 4, 'name': 'Math', 'syllabus': 'CBSE - 2026'},
          'name': 'Chapter 1 - Real Numbers',
        },
        {
          'id': '222',
          'zsl_class_id': '58',
          'subject_id': '5',
          'subject_name': 'Biology',
          'name': 'Life Processes',
        },
        {
          'id': '223',
          'zsl_class_id': '99',
          'subject_id': '6',
          'name': 'Unprepared',
        },
      ],
    },
    activities: [
      {
        'id': '833',
        'zsl_class_id': '58',
        'subject_id': '4',
        'chapter_id': '221',
        'topic_id': '7',
        'topic_name': 'Numbers',
        'topic': {'file_path': 'data:image/png;base64,AQID'},
        'zone': 'math',
      },
      {
        'id': '834',
        'zsl_class_id': '58',
        'subject_id': '4',
        'chapter_id': '221',
        'topic_id': '7',
        'topic_name': 'Numbers',
        'zone': 'math',
      },
      {
        'id': '835',
        'zsl_class_id': '58',
        'subject_id': '5',
        'chapter_id': '222',
        'topic_id': '8',
        'topic_name': 'Cells',
        'zone': 'science',
      },
    ],
  ),
]);

void main() {
  test('offline metadata preserves full hyphenated names and syllabus', () {
    final catalog = sample();
    final chapters =
        catalog.response('/zsl/chapters', {
              'zsl_class_id': 58,
              'zsl_subject_id': 4,
            })
            as List;
    expect(chapters.first['name'], 'Chapter 1 - Real Numbers');
    final subjects =
        catalog.response('/zsl/subjects', {'zsl_class_id': 58}) as List;
    expect(subjects.first['syllabus'], 'CBSE - 2026');
    final topics =
        catalog.response('/zsl/chapter/links', {'zsl_chapter_id': 221}) as List;
    expect(topics.first['file_path'], 'data:image/png;base64,AQID');
  });
  test(
    'offline practice reads saved class, batch and student roster',
    () async {
      final db = OfflineDatabase(sqlite3.openInMemory());
      addTearDown(db.close);
      const session = SessionState(
        userInfo: UserInfo(
          id: 1,
          username: 'lab',
          token: 'test',
          instituteId: 2,
        ),
      );
      final service = OfflineService(
        () => session,
        () => throw StateError('No HTTP'),
        () async => db,
      );
      db.saveContext(service.scope, {
        'classes': [
          {
            'id': 22,
            'name': 'API class name',
            'batches': [
              {
                'id': 3,
                'name': 'Published batch',
                'students': [
                  {'id': 4, 'name': 'Student'},
                ],
              },
            ],
          },
        ],
      });
      expect(
        (await service.practiceOptions({'class_id': '22'}))['batches'],
        hasLength(1),
      );
      expect(
        (await service.practiceOptions({
          'class_id': 22,
          'batch_id': '3',
        }))['students'],
        [
          {'id': 4, 'name': 'Student'},
        ],
      );
      expect(
        (await service.practiceOptions({'class_id': 99}))['batches'],
        isEmpty,
      );
    },
  );

  test(
    'catalog selects only this account, language and unexpired installations',
    () async {
      final db = OfflineDatabase(sqlite3.openInMemory());
      addTearDown(db.close);
      const session = SessionState(
        userInfo: UserInfo(
          id: 1,
          username: 'test',
          token: 'token',
          instituteId: 2,
          role: Role.instructor,
        ),
      );
      final service = OfflineService(
        () => session,
        () => throw StateError('No network'),
        () async => db,
      );
      final entry = sample().entries.single;
      void install(
        String scope,
        String name,
        int classId,
        int language,
        DateTime expires,
      ) {
        db.install(scope, {
          ...entry.pack,
          'id': name,
          'class_id': classId,
          'language_id': language,
          'expires_at': expires.toUtc().toIso8601String(),
        }, entry.activities);
      }

      final future = DateTime.now().add(const Duration(days: 1));
      install(service.scope, 'valid', 10, 1, future);
      install(
        service.scope,
        'expired',
        11,
        1,
        DateTime.now().subtract(const Duration(days: 1)),
      );
      install(service.scope, 'other-language', 12, 2, future);
      install('another-account', 'other-user', 13, 1, future);
      final catalog = await service.preparedCatalog();
      expect(catalog.entries.map((entry) => entry.pack['id']), ['valid']);
    },
  );

  test(
    'same catalog screens receive prepared classes, subjects and chapters',
    () {
      final catalog = sample();
      expect(catalog.response('/zsl/classes', {}), [
        {'id': 58, 'name': 'Class X - A', 'class_level': 10},
      ]);
      final subjects =
          catalog.response('/zsl/subjects', {'zsl_class_id': 58}) as List;
      expect(subjects.map((s) => s['zone']), ['MATH_ZONE', 'SCIENCE_ZONE']);
      expect(
        catalog.response('/zsl/chapters', {
          'zsl_class_id': '58',
          'zsl_subject_id': 4,
        }),
        hasLength(1),
      );
      expect(catalog.response('/zsl/subjects', {'zsl_class_id': 99}), isEmpty);
    },
  );
  test(
    'chapter activities retain topic grouping and work with numeric IDs',
    () {
      final topics =
          sample().response('/zsl/chapter/links', {'zsl_chapter_id': 221})
              as List;
      expect(topics, hasLength(1));
      expect(topics.single['id'], 7);
      expect((topics.single['activities'] as List).map((a) => a['id']), [
        833,
        834,
      ]);
    },
  );
  test(
    'unprepared account has an empty catalog and unsupported requests are explicit',
    () {
      expect(PreparedCatalog([]).response('/zsl/classes', {}), isEmpty);
      expect(() => sample().response('/zsl/signed/link', {}), throwsStateError);
    },
  );
  test(
    'offline catalog bypasses HTTP and does not falsely report connectivity',
    () async {
      final network = NoNetwork();
      final reachability = <bool>[];
      final api = ApiClient(
        tokenReader: () => 'token',
        onUnauthorized: () async {},
        isOffline: () => true,
        readOffline: (path, query) async => sample().response(path, query),
        onReachabilityChanged: reachability.add,
      );
      api.dio.httpClientAdapter = network;
      final zsl = ZslService(api, () => const SessionState());
      expect(await zsl.getClass(70), hasLength(1));
      expect(await zsl.getAllSubjects(70, 58), hasLength(2));
      expect(await zsl.getAllChapters(70, 58, 4), hasLength(1));
      expect(await zsl.getChapterLinks(70, 221), hasLength(1));
      expect(network.calls, 0);
      expect(reachability, isEmpty);
      await expectLater(
        api.post('/zsl/signed/link', data: {}, silent: true),
        throwsA(isA<DioException>()),
      );
      expect(network.calls, 0);
      api.dio.close();
    },
  );
}
