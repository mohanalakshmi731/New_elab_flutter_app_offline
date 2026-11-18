import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/config/env.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../state/providers.dart';
import 'local_activity_registry.dart';
import 'prepared_catalog.dart';
import 'offline_database.dart';
import 'offline_material.dart';
import 'offline_runtime.dart';

final offlineDatabaseProvider = FutureProvider<OfflineDatabase>((ref) async {
  final database = await OfflineDatabase.open();
  ref.onDispose(database.close);
  return database;
});

final Provider<OfflineService> offlineServiceProvider =
    Provider<OfflineService>(
      (ref) => OfflineService(
        () => ref.read(sessionProvider),
        () => ref.read(apiClientProvider),
        () => ref.read(offlineDatabaseProvider.future),
      ),
    );

final preparedOfflineCatalogProvider = FutureProvider<PreparedCatalog>((ref) {
  ref.watch(offlineRuntimeProvider.select((s) => s.revision));
  ref.watch(
    sessionProvider.select(
      (s) => '${s.token}:${s.instituteId}:${s.userId}:${s.language.id}',
    ),
  );
  return ref.read(offlineServiceProvider).preparedCatalog();
});

class OfflineService {
  OfflineService(this.session, this.api, this.database);
  final SessionState Function() session;
  final ApiClient Function() api;
  final Future<OfflineDatabase> Function() database;
  bool _syncing = false;
  bool _preparing = false;

  String get scope {
    final s = session();
    if (!s.isLoggedIn || s.userId == null || s.instituteId == null) {
      throw StateError('Sign in online once before preparing offline content.');
    }
    return jsonEncode([Env.apiBaseUrl, s.instituteId, s.userId]);
  }

  void _checkScope(String expected) {
    if (scope != expected)
      throw StateError('Your account changed. Open Offline content again.');
  }

  bool ownsScope(String expected) {
    try {
      return scope == expected;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> refreshContext() async {
    final owner = scope;
    final response = asMap(
      await api().get(
        '/offline/context',
        silent: true,
        query: {'institute_id': session().instituteId},
      ),
    )!;
    _checkScope(owner);
    (await database()).saveContext(owner, response);
    return response;
  }

  Future<Map<String, dynamic>> savedContext() async =>
      (await database()).context(scope) ?? {};

  Future<Map<String, dynamic>> practiceOptions(
    Map<String, dynamic> query,
  ) async {
    final context = await savedContext();
    final classes = asList(
      context['classes'],
    ).map(asMap).whereType<Map<String, dynamic>>().toList();
    if (query['class_id'] == null) return {'classes': classes};
    final cls = classes
        .where((c) => '${c['id']}' == '${query['class_id']}')
        .firstOrNull;
    final batches = asList(
      cls?['batches'],
    ).map(asMap).whereType<Map<String, dynamic>>().toList();
    if (query['batch_id'] == null) return {'batches': batches};
    final batch = batches
        .where((b) => '${b['id']}' == '${query['batch_id']}')
        .firstOrNull;
    return {'students': asList(batch?['students'])};
  }

  Future<List<Map<String, dynamic>>> packs() async =>
      (await database()).packs(scope);

  Future<void> prepare(
    int classId,
    int languageId,
    void Function(String) progress, {
    bool Function()? cancelled,
  }) async {
    if (_preparing) throw StateError('A download is already running.');
    final owner = scope;
    _preparing = true;
    Directory? staging;
    final media = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(minutes: 3),
      ),
    );
    final materialPreparer = OfflineMaterial(media);
    try {
      final db = await database();
      var pack = db.download(owner, classId, languageId);
      if (pack != null &&
          DateTime.parse('${pack['expires_at']}').isBefore(DateTime.now()))
        pack = null;
      if (pack != null) {
        try {
          pack = asMap(
            await api().get(
              '/offline/packages/${pack['id']}',
              silent: true,
              query: {'institute_id': session().instituteId},
            ),
          )!;
        } on DioException catch (error) {
          if (error.response?.statusCode != 404) rethrow;
          // A restored database or cleaned-up server can lose a resumable
          // package. Recreate it without deleting installed lessons or events.
          pack = null;
        }
      }
      progress('Getting your class ready...');
      pack ??= asMap(
        await api().post(
          '/offline/packages',
          silent: true,
          data: {
            'institute_id': session().instituteId,
            'class_id': classId,
            'language_id': languageId,
          },
        ),
      )!;
      _checkScope(owner);
      db.saveDownload(owner, classId, languageId, pack);
      final activities = <Map<String, dynamic>>[];
      var skipped = 0;
      for (final raw in asList(pack['chapters'])) {
        _checkScope(owner);
        if (cancelled?.call() == true)
          throw StateError('Download paused. Prepare again to resume.');
        final chapter = asMap(raw)!;
        progress('Getting your lessons ready...');
        final result = asMap(
          await api().get(
            '/offline/packages/${pack['id']}/chapters/${chapter['key']}',
            silent: true,
            query: {'institute_id': session().instituteId},
          ),
        )!;
        for (final value in asList(result['activities'])) {
          final activity = asMap(value)!;
          if (supportsLocalActivity(activity)) {
            activities.add({
              ...activity,
              'mapping_id': localMappingId(activity),
              'zone': localActivityZone(activity),
            });
          } else {
            skipped++;
          }
        }
      }
      if (activities.isEmpty)
        throw StateError(
          'This assigned class has no activities supported by the offline player in this app. You can continue using its activities online.',
        );
      final base = await getApplicationSupportDirectory();
      staging = Directory('${base.path}/offline_files/${pack['id']}');
      await staging.create(recursive: true);
      final downloaded = <Map<String, dynamic>>[];
      for (var index = 0; index < activities.length; index++) {
        _checkScope(owner);
        if (cancelled?.call() == true)
          throw StateError(
            'Download cancelled. Your previous package is unchanged.',
          );
        final activity = activities[index];
        progress(
          'Getting your content ready · ${index + 1} of ${activities.length}',
        );
        final cached = File(
          '${staging.path}/activity_${Uri.encodeComponent('${activity['id']}')}.json',
        );
        if (await cached.exists()) {
          try {
            final saved = asMap(
              jsonDecode(utf8.decode(await readFile(cached))),
            )!;
            if (saved['preparation_version'] != 5)
              throw const FormatException('Refresh supporting images.');
            await validateFiles(saved);
            downloaded.add(saved);
            continue;
          } catch (_) {
            /* Re-download incomplete material. */
          }
        }
        final material = asMap(
          await api().get(
            '/offline/packages/${pack['id']}/activities/${activity['id']}',
            silent: true,
            query: {'institute_id': session().instituteId},
          ),
        )!;
        final files = <Map<String, dynamic>>[];
        for (final raw in asList(material['files'])) {
          final file = asMap(raw)!;
          final url = '${file['url']}';
          final uri = Uri.tryParse(url);
          if (uri == null || !['http', 'https'].contains(uri.scheme))
            throw const FormatException('Invalid content file URL.');
          final name = '${file['name'] ?? uri.path}';
          final extension = name.contains('.')
              ? name.split('.').last.toLowerCase()
              : uri.path.split('.').last.toLowerCase();
          final safeExtension = RegExp(r'^[a-z0-9]{1,8}$').hasMatch(extension)
              ? extension
              : 'bin';
          final result = await media.get<List<int>>(
            url,
            options: Options(responseType: ResponseType.bytes),
          );
          final bytes = await materialPreparer.prepareFile(
            result.data!,
            safeExtension,
            uri,
          );
          final digest = sha256.convert(bytes).toString();
          final path = '${staging.path}/$digest.$safeExtension';
          await writeFile(File(path), bytes);
          files.add({
            ...file,
            'url': null,
            'path': path,
            'size': bytes.length,
            'sha256': digest,
          });
        }
        downloaded.add({
          ...Map<String, dynamic>.from(
            await materialPreparer.prepare(
                  activity,
                  base: Uri.tryParse(Env.apiBaseUrl),
                )
                as Map,
          ),
          'questions': await materialPreparer.prepare(
            material['questions'] ?? [],
            base: Uri.tryParse(Env.apiBaseUrl),
          ),
          'preparation_version': 5,
          'files': files,
          'downloaded_at': DateTime.now().toUtc().toIso8601String(),
        });
        await writeFile(cached, utf8.encode(jsonEncode(downloaded.last)));
      }
      _checkScope(owner);
      if (cancelled?.call() == true) throw StateError('Download cancelled.');
      if (DateTime.parse('${pack['expires_at']}').isBefore(DateTime.now())) {
        throw StateError(
          'This preparation expired. Prepare the class again online.',
        );
      }
      db.install(owner, {
        ...Map<String, dynamic>.from(
          await materialPreparer.prepare(
                pack,
                base: Uri.tryParse(Env.apiBaseUrl),
              )
              as Map,
        ),
        'directory': staging.path,
        'activity_count': downloaded.length,
        'unsupported_count': skipped,
      }, downloaded);
      db.finishDownload(owner, classId, languageId);
      progress('You’re ready to learn offline!');
    } finally {
      media.close(force: true);
      _preparing = false;
    }
  }

  Future<Uint8List> readFile(File file) async {
    final cipher = (await database()).cipher;
    return cipher == null ? file.readAsBytes() : cipher.read(file);
  }

  Future<void> writeFile(File file, List<int> bytes) async {
    final cipher = (await database()).cipher;
    if (cipher == null) {
      await file.writeAsBytes(bytes, flush: true);
    } else {
      await cipher.write(file, bytes);
    }
  }

  Future<void> validateFiles(Map<String, dynamic> activity) async {
    for (final item in asList(
      activity['files'],
    ).map(asMap).whereType<Map<String, dynamic>>()) {
      final file = File('${item['path']}');
      if (!await file.exists())
        throw StateError('A prepared file is missing. Prepare content again.');
      final bytes = await readFile(file);
      if (bytes.length != item['size'] ||
          sha256.convert(bytes).toString() != item['sha256']) {
        throw StateError(
          'A downloaded file is missing or damaged. Prepare this package again.',
        );
      }
    }
  }

  Future<void> sync() async {
    if (_syncing) return;
    final owner = scope;
    _syncing = true;
    try {
      final db = await database();
      while (true) {
        _checkScope(owner);
        final pending = db.pending(owner);
        if (pending.isEmpty) break;
        final response = asMap(
          await api().post(
            '/offline/events',
            data: {'institute_id': session().instituteId, 'events': pending},
            silent: true,
          ),
        )!;
        _checkScope(owner);
        var count = 0;
        for (final raw in asList(response['events'])) {
          final event = asMap(raw)!;
          final status = '${event['status']}';
          if ([
            'saved',
            'pending',
            'sending',
            'forwarded',
            'uncertain',
            'rejected',
          ].contains(status)) {
            db.acknowledge(
              owner,
              '${event['id']}',
              status == 'pending' ? 'uploaded' : status,
              asString(event['error']),
              asMap(event['result']),
            );
            count++;
          }
        }
        if (count == 0)
          throw StateError(
            'The server did not acknowledge the pending records.',
          );
      }
      final awaiting = db.awaitingConfirmation(owner);
      for (var offset = 0; offset < awaiting.length; offset += 100) {
        final uploaded = awaiting.skip(offset).take(100).toList();
        _checkScope(owner);
        final response = asMap(
          await api().post(
            '/offline/events/status',
            data: {'institute_id': session().instituteId, 'ids': uploaded},
            silent: true,
          ),
        )!;
        _checkScope(owner);
        for (final raw in asList(response['events'])) {
          final event = asMap(raw)!;
          final status = '${event['status']}';
          db.acknowledge(
            owner,
            '${event['id']}',
            status == 'pending' ? 'uploaded' : status,
            asString(event['error']),
            asMap(event['result']),
          );
        }
      }
    } finally {
      _syncing = false;
    }
  }

  Future<PreparedCatalog> preparedCatalog() async {
    final db = await database();
    final owner = scope;
    final language = session().language.id;
    final entries =
        <
          ({Map<String, dynamic> pack, List<Map<String, dynamic>> activities})
        >[];
    for (final pack in db.packs(owner)) {
      if (asInt(pack['language_id']) != language) continue;
      final expiry = DateTime.tryParse('${pack['expires_at']}');
      if (expiry == null || !expiry.isAfter(DateTime.now())) continue;
      entries.add((
        pack: pack,
        activities: db.activities(owner, '${pack['id']}'),
      ));
    }
    return PreparedCatalog(entries);
  }

  static Future<Map<String, dynamic>> bundledCatalog({
    int classLevel = 10,
  }) async => asMap(
    jsonDecode(
      await rootBundle.loadString(
        'assets/offline/class${classLevel}_catalog.json',
      ),
    ),
  )!;
}

Map<String, dynamic> gradeOfflineQuiz(
  List<Map<String, dynamic>> questions,
  Map<String, dynamic> answers,
) {
  var correct = 0;
  var canGrade = true;
  if (questions.isEmpty) throw StateError('No downloaded quiz questions.');
  for (final question in questions) {
    final options = asList(
      question['options'],
    ).map(asMap).whereType<Map<String, dynamic>>().toList();
    final selected = options
        .where((o) => '${o['id']}' == '${answers['${question['id']}']}')
        .firstOrNull;
    if (selected == null)
      throw StateError('Answer every question before submitting.');
    canGrade =
        canGrade &&
        options.any(
          (o) =>
              o.containsKey('is_correct') ||
              o.containsKey('isCorrect') ||
              o.containsKey('correct'),
        );
    if (asBool(
      selected['is_correct'] ?? selected['isCorrect'] ?? selected['correct'],
    ))
      correct++;
  }
  return {
    'correct': canGrade ? correct : null,
    'total': questions.length,
    'provisional': true,
    'submitted_at': DateTime.now().toUtc().toIso8601String(),
  };
}
