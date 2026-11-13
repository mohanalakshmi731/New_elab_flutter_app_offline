import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Loads a value; [background] is true for a stale-while-revalidate refresh,
/// which must not show error toasts (pass it on as `silent:` to ApiClient).
typedef CacheLoader = Future<dynamic> Function({required bool background});

/// Read-through cache for slow API reads whose data rarely changes — the ZSL
/// curriculum (classes, subjects, chapters, chapter activities, languages).
/// Each of those requests goes app → backend → external ZSL content service,
/// so without a cache every screen visit paid that round trip again.
///
/// * Entry younger than `ttl` → returned at once, no request.
/// * Older entry (up to [maxStale]) → returned at once, and refreshed in the
///   background for next time (stale-while-revalidate).
/// * No entry → request; identical concurrent requests share one call.
///
/// Entries are kept in memory and as one small file each under the app
/// support directory, so they also survive app restarts. Every read returns a
/// freshly decoded copy, so callers may mutate what they get.
class ContentCache {
  ContentCache({Future<Directory?> Function()? directory, DateTime Function()? clock})
      : _directory = directory ?? _defaultDirectory,
        _now = clock ?? DateTime.now;

  /// Older entries are dropped and loaded again (blocking).
  static const maxStale = Duration(days: 7);

  /// Upper bound on files kept on disk; the oldest are pruned.
  static const maxFiles = 200;

  final Future<Directory?> Function() _directory;
  final DateTime Function() _now;

  final Map<String, _Entry> _memory = {};

  /// Running loads; completes with the value and its JSON copy (null when
  /// it could not be stored).
  final Map<String, Future<(dynamic, String?)>> _inFlight = {};
  Future<Directory?>? _dir;

  /// Bumped by [clear] so loads started before a logout don't write back.
  int _generation = 0;

  static Future<Directory?> _defaultDirectory() async {
    if (kIsWeb) return null;
    final base = await getApplicationSupportDirectory();
    return Directory('${base.path}${Platform.pathSeparator}content_cache');
  }

  /// Returns the cached value for [key] or loads it with [load].
  Future<dynamic> fetch(String key, CacheLoader load, {required Duration ttl}) async {
    // Captured before any await: a fetch started before [clear] (logout)
    // must not write its result back afterwards.
    final generation = _generation;
    final entry = _memory[key] ?? await _readFile(key);
    if (entry != null && generation == _generation) {
      _memory[key] = entry;
      final age = _now().difference(entry.savedAt);
      if (age <= ttl) return jsonDecode(entry.json);
      if (age <= maxStale) {
        if (!_inFlight.containsKey(key)) {
          unawaited(_load(key, () => load(background: true), generation).then<void>((_) {},
              onError: (Object e) => debugPrint('ContentCache refresh "$key" failed: $e')));
        }
        return jsonDecode(entry.json);
      }
    }
    final (value, json) = await _load(key, () => load(background: false), generation);
    // Each caller gets its own copy (concurrent callers share one load).
    return json == null ? value : jsonDecode(json);
  }

  Future<(dynamic, String?)> _load(String key, Future<dynamic> Function() load, int generation) {
    final running = _inFlight[key];
    if (running != null) return running;
    final completer = Completer<(dynamic, String?)>();
    final future = completer.future;
    _inFlight[key] = future;
    () async {
      try {
        final value = await load();
        final json = generation == _generation ? await _store(key, value) : null;
        completer.complete((value, json));
      } catch (e, s) {
        completer.completeError(e, s);
      } finally {
        if (identical(_inFlight[key], future)) _inFlight.remove(key);
      }
    }();
    return future;
  }

  /// Drops every entry whose key starts with [prefix] (e.g. after a quiz
  /// submission changes a student's activities).
  Future<void> invalidate(String prefix) async {
    _memory.removeWhere((k, _) => k.startsWith(prefix));
    final dir = await _safeDir();
    if (dir == null) return;
    try {
      await for (final f in dir.list()) {
        if (f is! File) continue;
        final key = await _readKey(f);
        if (key != null && key.startsWith(prefix)) await f.delete();
      }
    } catch (e) {
      debugPrint('ContentCache.invalidate failed: $e');
    }
  }

  /// Drops everything (logout).
  Future<void> clear() async {
    _generation++;
    _memory.clear();
    _inFlight.clear();
    final dir = await _safeDir();
    if (dir == null) return;
    try {
      if (await dir.exists()) await dir.delete(recursive: true);
    } catch (e) {
      debugPrint('ContentCache.clear failed: $e');
    }
  }

  // ── storage ──────────────────────────────────────────────────────────────

  /// Saves [value]; returns its JSON, or null when it is not JSON data.
  Future<String?> _store(String key, dynamic value) async {
    final String json;
    try {
      json = jsonEncode(value);
    } catch (_) {
      return null; // not JSON data — don't cache
    }
    final entry = _Entry(_now(), json);
    _memory[key] = entry;
    final dir = await _safeDir();
    if (dir == null) return json;
    try {
      await dir.create(recursive: true);
      // key \n savedAt \n json — the key is stored to rule out hash collisions.
      await _file(dir, key)
          .writeAsString('$key\n${entry.savedAt.millisecondsSinceEpoch}\n$json', flush: true);
      await _prune(dir);
    } catch (e) {
      debugPrint('ContentCache write failed: $e');
    }
    return json;
  }

  Future<_Entry?> _readFile(String key) async {
    final dir = await _safeDir();
    if (dir == null) return null;
    try {
      final file = _file(dir, key);
      if (!await file.exists()) return null;
      final text = await file.readAsString();
      final a = text.indexOf('\n');
      final b = a < 0 ? -1 : text.indexOf('\n', a + 1);
      if (b < 0 || text.substring(0, a) != key) return null;
      final ms = int.tryParse(text.substring(a + 1, b));
      if (ms == null) return null;
      return _Entry(DateTime.fromMillisecondsSinceEpoch(ms), text.substring(b + 1));
    } catch (e) {
      debugPrint('ContentCache read failed: $e');
      return null;
    }
  }

  Future<String?> _readKey(File f) async {
    try {
      final text = await f.readAsString();
      final i = text.indexOf('\n');
      return i < 0 ? null : text.substring(0, i);
    } catch (_) {
      return null;
    }
  }

  Future<void> _prune(Directory dir) async {
    try {
      final files = await dir.list().where((e) => e is File).cast<File>().toList();
      if (files.length <= maxFiles) return;
      final dated = [for (final f in files) (f, await f.lastModified())]
        ..sort((x, y) => x.$2.compareTo(y.$2));
      for (final (f, _) in dated.take(files.length - maxFiles)) {
        await f.delete();
      }
    } catch (e) {
      debugPrint('ContentCache prune failed: $e');
    }
  }

  Future<Directory?> _safeDir() async {
    try {
      return await (_dir ??= _directory());
    } catch (e) {
      // e.g. no path_provider plugin in unit tests — memory only.
      return null;
    }
  }

  static File _file(Directory dir, String key) =>
      File('${dir.path}${Platform.pathSeparator}${_fnv1a(key)}.json');

  /// Stable 64-bit FNV-1a hash (String.hashCode is not stable across runs).
  static String _fnv1a(String s) {
    var hash = BigInt.parse('cbf29ce484222325', radix: 16);
    final prime = BigInt.parse('100000001b3', radix: 16);
    final mask = (BigInt.one << 64) - BigInt.one;
    for (final unit in utf8.encode(s)) {
      hash = ((hash ^ BigInt.from(unit)) * prime) & mask;
    }
    return hash.toRadixString(16).padLeft(16, '0');
  }
}

class _Entry {
  const _Entry(this.savedAt, this.json);
  final DateTime savedAt;
  final String json;
}
