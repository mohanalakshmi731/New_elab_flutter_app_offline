import 'dart:async';
import 'dart:io';

import 'package:elab_app/core/network/content_cache.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory tmp;
  late DateTime now;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('content_cache_test');
    now = DateTime(2026, 1, 1, 12);
  });
  tearDown(() async {
    // A background refresh may still be writing (Windows locks open files).
    for (var i = 0; i < 20 && await tmp.exists(); i++) {
      try {
        await tmp.delete(recursive: true);
      } on FileSystemException {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      }
    }
  });

  ContentCache newCache() => ContentCache(
        directory: () async => Directory('${tmp.path}/cache'),
        clock: () => now,
      );

  CacheLoader counting(List<bool> calls, Object? Function() value) =>
      ({required bool background}) async {
        calls.add(background);
        return value();
      };

  test('fresh entry is served without a second request', () async {
    final cache = newCache();
    final calls = <bool>[];
    final load = counting(calls, () => {'v': 1});
    expect(await cache.fetch('k', load, ttl: const Duration(hours: 1)), {'v': 1});
    now = now.add(const Duration(minutes: 30));
    expect(await cache.fetch('k', load, ttl: const Duration(hours: 1)), {'v': 1});
    expect(calls, [false]);
  });

  test('survives a restart (new instance reads the disk copy)', () async {
    final calls = <bool>[];
    await newCache().fetch('k', counting(calls, () => [1, 2, 3]), ttl: const Duration(hours: 1));
    final again = await newCache()
        .fetch('k', counting(calls, () => 'network'), ttl: const Duration(hours: 1));
    expect(again, [1, 2, 3]);
    expect(calls, [false]);
  });

  test('stale entry is returned at once and refreshed silently in the background', () async {
    final cache = newCache();
    final calls = <bool>[];
    var value = 'old';
    final load = counting(calls, () => value);
    await cache.fetch('k', load, ttl: const Duration(minutes: 5));
    now = now.add(const Duration(minutes: 10));
    value = 'new';
    expect(await cache.fetch('k', load, ttl: const Duration(minutes: 5)), 'old');
    await pumpEventQueue();
    expect(calls, [false, true]); // background refresh is silent
    expect(await cache.fetch('k', load, ttl: const Duration(minutes: 5)), 'new');
    expect(calls.length, 2);
  });

  test('entries older than maxStale are loaded again (blocking)', () async {
    final cache = newCache();
    final calls = <bool>[];
    var value = 'old';
    final load = counting(calls, () => value);
    await cache.fetch('k', load, ttl: const Duration(hours: 1));
    now = now.add(ContentCache.maxStale + const Duration(days: 1));
    value = 'new';
    expect(await cache.fetch('k', load, ttl: const Duration(hours: 1)), 'new');
    expect(calls, [false, false]);
  });

  test('concurrent identical requests share one call', () async {
    final cache = newCache();
    var calls = 0;
    final gate = Completer<void>();
    Future<dynamic> load({required bool background}) async {
      calls++;
      await gate.future;
      return 'v';
    }

    final a = cache.fetch('k', load, ttl: const Duration(hours: 1));
    final b = cache.fetch('k', load, ttl: const Duration(hours: 1));
    gate.complete();
    expect(await Future.wait([a, b]), ['v', 'v']);
    expect(calls, 1);
  });

  test('errors are not cached', () async {
    final cache = newCache();
    var fail = true;
    Future<dynamic> load({required bool background}) async {
      if (fail) throw StateError('offline');
      return 'ok';
    }

    await expectLater(cache.fetch('k', load, ttl: const Duration(hours: 1)), throwsStateError);
    fail = false;
    expect(await cache.fetch('k', load, ttl: const Duration(hours: 1)), 'ok');
  });

  test('callers get their own copy', () async {
    final cache = newCache();
    var calls = 0;
    Future<dynamic> load({required bool background}) async {
      calls++;
      return <dynamic>[
        <String, dynamic>{'a': 1}
      ];
    }

    // Two concurrent callers share one request but not one object.
    final both = await Future.wait([
      cache.fetch('k', load, ttl: const Duration(hours: 1)),
      cache.fetch('k', load, ttl: const Duration(hours: 1)),
    ]);
    expect(calls, 1);
    expect(identical(both[0], both[1]), isFalse);
    final first = both[0] as List;
    (first.first as Map)['a'] = 99;
    first.add('junk');
    expect(await cache.fetch('k', load, ttl: const Duration(hours: 1)), [
      {'a': 1}
    ]);
  });

  test('invalidate drops matching keys from memory and disk', () async {
    final calls = <String>[];
    CacheLoader load(String tag) => ({required bool background}) async {
          calls.add(tag);
          return tag;
        };
    final cache = newCache();
    await cache.fetch('zsl/chapter/links|u1|a', load('links'), ttl: const Duration(hours: 1));
    await cache.fetch('zsl/subjects|u1|a', load('subjects'), ttl: const Duration(hours: 1));
    await cache.invalidate('zsl/chapter/links');

    final fresh = newCache(); // also checks the disk copy is gone
    await fresh.fetch('zsl/chapter/links|u1|a', load('links'), ttl: const Duration(hours: 1));
    await fresh.fetch('zsl/subjects|u1|a', load('subjects'), ttl: const Duration(hours: 1));
    expect(calls, ['links', 'subjects', 'links']);
  });

  test('clear drops everything and ignores loads that finish afterwards', () async {
    final cache = newCache();
    final gate = Completer<void>();
    var calls = 0;
    Future<dynamic> slow({required bool background}) async {
      calls++;
      await gate.future;
      return 'before-logout';
    }

    final pending = cache.fetch('k', slow, ttl: const Duration(hours: 1));
    await cache.clear();
    gate.complete();
    await pending;
    Future<dynamic> after({required bool background}) async {
      calls++;
      return 'after';
    }

    expect(await cache.fetch('k', after, ttl: const Duration(hours: 1)), 'after');
    expect(calls, 2);
  });

  test('works without a disk (memory only)', () async {
    final cache = ContentCache(directory: () async => null, clock: () => now);
    var calls = 0;
    Future<dynamic> load({required bool background}) async => ++calls;
    expect(await cache.fetch('k', load, ttl: const Duration(hours: 1)), 1);
    expect(await cache.fetch('k', load, ttl: const Duration(hours: 1)), 1);
  });
}
