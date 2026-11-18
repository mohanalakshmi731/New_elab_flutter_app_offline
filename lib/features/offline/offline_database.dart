import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:uuid/uuid.dart';
import 'offline_cipher.dart';

/// Durable content and outbox. Every account row includes its backend/user scope.
class OfflineDatabase {
  OfflineDatabase(this.db, {this.cipher}) {
    db.execute('PRAGMA foreign_keys = ON');
    db.execute('PRAGMA busy_timeout = 5000');
    db.execute('''
      CREATE TABLE IF NOT EXISTS offline_packs (
        scope TEXT NOT NULL, id TEXT NOT NULL, class_id INTEGER NOT NULL,
        language_id INTEGER NOT NULL, active INTEGER NOT NULL, payload TEXT NOT NULL,
        PRIMARY KEY(scope,id));
      CREATE TABLE IF NOT EXISTS offline_activities (
        scope TEXT NOT NULL, pack_id TEXT NOT NULL, id TEXT NOT NULL, payload TEXT NOT NULL,
        PRIMARY KEY(scope,pack_id,id),
        FOREIGN KEY(scope,pack_id) REFERENCES offline_packs(scope,id) ON DELETE CASCADE);
      CREATE TABLE IF NOT EXISTS offline_events (
        scope TEXT NOT NULL, id TEXT NOT NULL, payload TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending', error TEXT,
        created_at TEXT NOT NULL, PRIMARY KEY(scope,id));
      CREATE INDEX IF NOT EXISTS offline_events_pending ON offline_events(scope,status);
      CREATE TABLE IF NOT EXISTS offline_attempts (
        scope TEXT NOT NULL, id TEXT NOT NULL, identity TEXT NOT NULL,
        pack_id TEXT NOT NULL, activity_id TEXT NOT NULL, payload TEXT NOT NULL,
        PRIMARY KEY(scope,id));
      CREATE TABLE IF NOT EXISTS offline_drafts (
        scope TEXT NOT NULL, identity TEXT NOT NULL, pack_id TEXT NOT NULL,
        activity_id TEXT NOT NULL, payload TEXT NOT NULL,
        PRIMARY KEY(scope,identity,pack_id,activity_id));
      CREATE TABLE IF NOT EXISTS offline_context (
        scope TEXT PRIMARY KEY, payload TEXT NOT NULL);
      CREATE TABLE IF NOT EXISTS offline_downloads (
        scope TEXT NOT NULL, class_id INTEGER NOT NULL, language_id INTEGER NOT NULL,
        payload TEXT NOT NULL, PRIMARY KEY(scope,class_id,language_id));
      CREATE TABLE IF NOT EXISTS offline_receipts (
        scope TEXT NOT NULL, id TEXT NOT NULL, payload TEXT NOT NULL, PRIMARY KEY(scope,id));
      PRAGMA user_version = 1;
    ''');
  }

  final Database db;
  final OfflineCipher? cipher;
  String encode(Object? value) => cipher?.encode(value) ?? jsonEncode(value);
  void _encryptLegacyRows() {
    if (cipher == null) return;
    var changed = false;
    transaction(() {
      for (final table in [
        'offline_packs',
        'offline_activities',
        'offline_events',
        'offline_attempts',
        'offline_drafts',
        'offline_context',
        'offline_downloads',
        'offline_receipts',
      ]) {
        for (final row in db.select('SELECT rowid,payload FROM $table')) {
          final payload = row['payload'] as String;
          if (!payload.startsWith('enc1:')) {
            changed = true;
            db.execute('UPDATE $table SET payload=? WHERE rowid=?', [
              encode(jsonDecode(payload)),
              row['rowid'],
            ]);
          }
        }
      }
    });
    if (!changed) return;
    db.execute('PRAGMA wal_checkpoint(TRUNCATE)');
    db.execute('VACUUM');
  }

  Map<String, dynamic>? download(String scope, int classId, int languageId) {
    final rows = db.select(
      'SELECT payload FROM offline_downloads WHERE scope=? AND class_id=? AND language_id=?',
      [scope, classId, languageId],
    );
    return rows.isEmpty ? null : decode(rows.first['payload']);
  }

  void saveDownload(
    String scope,
    int classId,
    int languageId,
    Map<String, dynamic> pack,
  ) => db.execute('INSERT OR REPLACE INTO offline_downloads VALUES (?,?,?,?)', [
    scope,
    classId,
    languageId,
    encode(pack),
  ]);
  void finishDownload(String scope, int classId, int languageId) => db.execute(
    'DELETE FROM offline_downloads WHERE scope=? AND class_id=? AND language_id=?',
    [scope, classId, languageId],
  );
  static Future<OfflineDatabase> open() async {
    final directory = await getApplicationSupportDirectory();
    await Directory(directory.path).create(recursive: true);
    final db = sqlite3.open('${directory.path}/elab_offline.sqlite');
    db.execute('PRAGMA journal_mode = WAL');
    db.execute('PRAGMA secure_delete = ON');
    final result = OfflineDatabase(db, cipher: await OfflineCipher.open());
    result._encryptLegacyRows();
    final files = Directory('${directory.path}/offline_files');
    if (await files.exists()) {
      await for (final file in files.list(
        recursive: true,
        followLinks: false,
      )) {
        if (file is! File || file.path.endsWith('.writing')) continue;
        final bytes = await file.readAsBytes();
        if (!result.cipher!.isProtected(bytes))
          await result.cipher!.write(file, bytes);
      }
    }
    return result;
  }

  T transaction<T>(T Function() action) {
    db.execute('BEGIN IMMEDIATE');
    try {
      final value = action();
      db.execute('COMMIT');
      return value;
    } catch (_) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }

  Map<String, dynamic> decode(Object? json) => Map<String, dynamic>.from(
    (cipher?.decode(json as String) ?? jsonDecode(json as String)) as Map,
  );

  void install(
    String scope,
    Map<String, dynamic> pack,
    List<Map<String, dynamic>> activities,
  ) {
    if (activities.isEmpty ||
        activities.map((a) => '${a['id']}').toSet().length !=
            activities.length) {
      throw const FormatException(
        'The content package is empty or contains duplicate activities.',
      );
    }
    transaction(() {
      db.execute(
        'UPDATE offline_packs SET active=0 WHERE scope=? AND class_id=? AND language_id=?',
        [scope, pack['class_id'], pack['language_id']],
      );
      db.execute('INSERT OR REPLACE INTO offline_packs VALUES (?,?,?,?,1,?)', [
        scope,
        pack['id'],
        pack['class_id'],
        pack['language_id'],
        encode(pack),
      ]);
      for (final activity in activities) {
        db.execute('INSERT INTO offline_activities VALUES (?,?,?,?)', [
          scope,
          pack['id'],
          '${activity['id']}',
          encode(activity),
        ]);
      }
    });
  }

  List<Map<String, dynamic>> packs(String scope) => db
      .select(
        'SELECT payload FROM offline_packs WHERE scope=? AND active=1 ORDER BY class_id,language_id',
        [scope],
      )
      .map((r) => decode(r['payload']))
      .toList();

  List<Map<String, dynamic>> activities(String scope, String packId) => db
      .select(
        'SELECT payload FROM offline_activities WHERE scope=? AND pack_id=? ORDER BY rowid',
        [scope, packId],
      )
      .map((r) => decode(r['payload']))
      .toList();

  void saveContext(String scope, Map<String, dynamic> context) => db.execute(
    'INSERT OR REPLACE INTO offline_context VALUES (?,?)',
    [scope, encode(context)],
  );
  Map<String, dynamic>? context(String scope) {
    final rows = db.select(
      'SELECT payload FROM offline_context WHERE scope=?',
      [scope],
    );
    return rows.isEmpty ? null : decode(rows.first['payload']);
  }

  String enqueue(String scope, Map<String, dynamic> event, {String? id}) {
    id ??= const Uuid().v4();
    final body = {...event, 'id': id};
    db.execute(
      'INSERT INTO offline_events(scope,id,payload,created_at) VALUES (?,?,?,?)',
      [scope, id, encode(body), DateTime.now().toUtc().toIso8601String()],
    );
    return id;
  }

  List<Map<String, dynamic>> pending(String scope, {int limit = 100}) => db
      .select(
        "SELECT payload FROM offline_events WHERE scope=? AND status='pending' ORDER BY created_at LIMIT ?",
        [scope, limit],
      )
      .map((r) => decode(r['payload']))
      .toList();
  List<Map<String, dynamic>> records(String scope) => db
      .select(
        'SELECT payload,status,error FROM offline_events WHERE scope=? ORDER BY created_at DESC LIMIT 300',
        [scope],
      )
      .map(
        (r) => {
          ...decode(r['payload']),
          'sync_status': r['status'],
          'sync_error': r['error'],
        },
      )
      .toList();
  void acknowledge(
    String scope,
    String id,
    String status, [
    String? error,
    Map<String, dynamic>? result,
  ]) {
    transaction(() {
      db.execute(
        'UPDATE offline_events SET status=?,error=? WHERE scope=? AND id=?',
        [status, error, scope, id],
      );
      if (result != null)
        db.execute('INSERT OR REPLACE INTO offline_receipts VALUES (?,?,?)', [
          scope,
          id,
          encode(result),
        ]);
    });
  }

  List<String> awaitingConfirmation(String scope) => db
      .select(
        "SELECT id FROM offline_events WHERE scope=? AND status IN ('uploaded','sending','uncertain') ORDER BY created_at",
        [scope],
      )
      .map((r) => r['id'] as String)
      .toList();

  Map<String, dynamic> draft(
    String scope,
    String identity,
    String packId,
    String activityId,
  ) {
    final rows = db.select(
      'SELECT payload FROM offline_drafts WHERE scope=? AND identity=? AND pack_id=? AND activity_id=?',
      [scope, identity, packId, activityId],
    );
    return rows.isEmpty ? {} : decode(rows.first['payload']);
  }

  void saveDraft(
    String scope,
    String identity,
    String packId,
    String activityId,
    Map<String, dynamic> answers,
  ) => db.execute('INSERT OR REPLACE INTO offline_drafts VALUES (?,?,?,?,?)', [
    scope,
    identity,
    packId,
    activityId,
    encode(answers),
  ]);
  void saveAttempt(
    String scope,
    String identity,
    Map<String, dynamic> event,
    Map<String, dynamic> result,
  ) {
    transaction(() {
      final id = enqueue(scope, event);
      db.execute('INSERT INTO offline_attempts VALUES (?,?,?,?,?,?)', [
        scope,
        id,
        identity,
        event['pack_id'],
        '${event['activity_id']}',
        encode(result),
      ]);
      db.execute(
        'DELETE FROM offline_drafts WHERE scope=? AND identity=? AND pack_id=? AND activity_id=?',
        [scope, identity, event['pack_id'], '${event['activity_id']}'],
      );
    });
  }

  List<Map<String, dynamic>> attempts(
    String scope,
    String identity,
    String activityId,
  ) => db
      .select(
        'SELECT a.payload,e.status,r.payload AS receipt FROM offline_attempts a LEFT JOIN offline_events e ON e.scope=a.scope AND e.id=a.id LEFT JOIN offline_receipts r ON r.scope=a.scope AND r.id=a.id WHERE a.scope=? AND a.identity=? AND a.activity_id=? ORDER BY a.rowid DESC',
        [scope, identity, activityId],
      )
      .map(
        (r) => {
          ...decode(r['payload']),
          'sync_status': r['status'],
          'receipt': r['receipt'] == null ? null : decode(r['receipt']),
        },
      )
      .toList();
  void removePack(String scope, String packId) {
    if (pending(scope, limit: 100000).any((e) => e['pack_id'] == packId)) {
      throw StateError(
        'Sync the pending results before removing this package.',
      );
    }
    db.execute('DELETE FROM offline_packs WHERE scope=? AND id=?', [
      scope,
      packId,
    ]);
  }

  void close() => db.close();
}
