import 'dart:async';
import 'dart:io';
import 'dart:typed_data' show BytesBuilder;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

/// The web's fonts (index.html loads Plus Jakarta Sans 300–800; `.dark`
/// switches `--font-sans` to Inter), registered as **one family per font
/// with every weight**, so `fontWeight: FontWeight.w700` picks the real bold
/// face anywhere in the app.
///
/// (`GoogleFonts.xTextTheme()` registers each weight as its own family —
/// `PlusJakartaSans_regular` — so a weight merged in later rendered a
/// synthetic bold of the regular face.)
///
/// The static TTFs are the Google Fonts files google_fonts uses, fetched
/// once from fonts.gstatic.com and cached in the app-support directory.
/// Until they are loaded, text uses the platform font.
class AppFonts {
  AppFonts._();

  static const plusJakartaSans = 'AppPlusJakartaSans';
  static const inter = 'AppInter';

  /// System fallbacks, like the CSS stacks (`ui-sans-serif, sans-serif, system-ui`).
  static const fallback = <String>['Segoe UI', 'Roboto', 'Helvetica Neue', 'Arial', 'sans-serif'];

  static const _files = <String, Map<int, String>>{
    plusJakartaSans: {
      200: '236b94978716a5b9532c5ab11f7d69ba195e1cacf00146a91ab46c507b7148a3',
      300: '98eea411373148b109f3cb8c85cbd9294707f2b56ace31774050d3353789f20c',
      400: '1306435ed883e4a1e6dad370e6d035955da71f4df9c07ca192833f7cb58a18d7',
      500: 'd4478b49f18c5b0db7bd8fbbb033595061dea8c03a86246710035d750e515130',
      600: '8590ab94f96850ab246d5795a9ba442e42f64036673bc329573dfe93efbc7c87',
      700: '5b6d946cf820c9851ff7b4776425ee43f5cf405c6f891a4a7fcb4a74d5e32d52',
      800: '9ab901a45e6afa0c663def7606b753bbdfb60fc73bf3277e8110c167ddb6bbc3',
    },
    inter: {
      300: '8641cf8fd5e04d0f94062395a2d1ab1ba5467831af690069e8f3ea0efe640d70',
      400: '15b294b67f2f8bbc04d990023ef4aec66502b87dc9040d84abe5f896ccb693de',
      500: '36a36ff7ac46dc2aeceac3a80a87a67e7b844b8fc936699259aac8fba9bcf734',
      600: '334bb2c51aeba5f566abac8d03a7e75ab3234d6926b52e92a85dc704129258b5',
      700: '76121a34a606cc8a0e1ef5a47d2b9ba9678c41f5c852d63eb28f62069373bfad',
      800: '6af943899936fd3fd15a5889db4a384cec311c9bfe33d74bcfd3e0ae56f1b1d1',
      900: 'd892b18d080d1200aa41ea8851da84dd8c24c33843d491fa034ac57b16f22973',
    },
  };

  static Future<void>? _loading;

  /// Starts loading both families (idempotent; errors only leave the
  /// platform font in place). Called when the theme is first built.
  static Future<void> ensureLoaded() {
    // Widget tests have no network; keep the platform font there.
    if (_isTest) return Future.value();
    return _loading ??= _loadAll();
  }

  static bool get _isTest => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  static Future<void> _loadAll() async {
    Directory? cache;
    try {
      cache = Directory('${(await getApplicationSupportDirectory()).path}/app_fonts');
      await cache.create(recursive: true);
    } catch (_) {
      cache = null;
    }
    await Future.wait([
      for (final e in _files.entries) _loadFamily(e.key, e.value, cache),
    ]);
  }

  static Future<void> _loadFamily(String family, Map<int, String> weights, Directory? cache) async {
    final faces = await Future.wait([for (final hash in weights.values) _bytes(hash, cache)]);
    final loader = FontLoader(family);
    var any = false;
    for (final f in faces) {
      if (f == null) continue;
      loader.addFont(Future.value(ByteData.sublistView(f)));
      any = true;
    }
    if (any) {
      try {
        await loader.load();
      } catch (_) {}
    }
  }

  static Future<Uint8List?> _bytes(String hash, Directory? cache) async {
    final file = cache == null ? null : File('${cache.path}/$hash.ttf');
    try {
      if (file != null && await file.exists()) return await file.readAsBytes();
    } catch (_) {}
    try {
      final client = HttpClient();
      try {
        final req = await client.getUrl(Uri.parse('https://fonts.gstatic.com/s/a/$hash.ttf'));
        final res = await req.close();
        if (res.statusCode != 200) return null;
        final builder = BytesBuilder(copy: false);
        await for (final chunk in res) {
          builder.add(chunk);
        }
        final bytes = builder.takeBytes();
        try {
          await file?.writeAsBytes(bytes, flush: true);
        } catch (_) {}
        return bytes;
      } finally {
        client.close();
      }
    } catch (_) {
      return null;
    }
  }
}
