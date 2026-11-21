import 'dart:convert';
import 'dart:io';

import 'package:elab_app/features/offline/activities/class6/math/registry.dart';
import 'package:elab_app/features/offline/activities/class6/science/registry.dart';
import 'package:elab_app/features/offline/prepared_catalog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'every Class 6 mapping resolves to its native activity and correct zone',
    () async {
      final catalog =
          jsonDecode(
                await rootBundle.loadString(
                  'assets/offline/class6_catalog.json',
                ),
              )
              as Map;
      expect(catalog['class_level'], 6);
      expect(class6MathActivityWidgets.length, 58);
      expect(class6ScienceActivityWidgets.length, 77);
      final widgets = {
        ...class6MathActivityWidgets,
        ...class6ScienceActivityWidgets,
      };
      final mappings = (catalog['activities'] as List).cast<Map>();
      expect(mappings.length, 135);
      expect(mappings.map((a) => a['mapping_id']).toSet().length, 135);
      for (final item in mappings) {
        expect(widgets[item['mapping_id']], isNotNull, reason: item.toString());
        expect(
          class6MathActivityWidgets.containsKey(item['mapping_id']),
          item['zone'] == 'math',
        );
        expect(
          class6ScienceActivityWidgets.containsKey(item['mapping_id']),
          item['zone'] == 'science',
        );
      }
      expect(widgets[999999], isNull);
      for (final grade in [7, 8, 9, 10]) {
        final existing =
            jsonDecode(
                  await rootBundle.loadString(
                    'assets/offline/class' + grade.toString() + '_catalog.json',
                  ),
                )
                as Map;
        for (final item in existing['activities'] as List) {
          expect(
            widgets.containsKey(item['mapping_id']),
            false,
            reason: 'Mapping must not overlap another grade',
          );
        }
      }
    },
  );

  test(
    'all Class 6 sounds are bundled and referenced without remote playback',
    () async {
      final files = Directory('lib/features/offline/activities/class6')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      final referenced = <String>{};
      for (final file in files) {
        final text = file.readAsStringSync();
        expect(text, isNot(contains('UrlSource(')), reason: file.path);
        expect(text, isNot(contains('NetworkImage(')), reason: file.path);
        referenced.addAll(
          RegExp(
            r'''["'](audio/class6/[^"'\r\n]+\.(?:mp3|ogg|wav))["']''',
          ).allMatches(text).map((match) => 'assets/' + match.group(1)!),
        );
      }
      expect(referenced.length, 35);
      final assets = Directory('assets/audio/class6')
          .listSync(recursive: true)
          .whereType<File>()
          .map((file) => file.path.replaceAll('\\', '/'))
          .toSet();
      expect(assets.length, 36);
      expect(assets, containsAll(referenced));
      for (final asset in assets) {
        final bytes = await rootBundle.load(asset);
        expect(bytes.lengthInBytes, greaterThan(1000), reason: asset);
      }
      expect(assets, contains('assets/audio/class6/math/click.mp3'));
      expect(assets, contains('assets/audio/class6/science/click.mp3'));
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      expect(manifest.listAssets(), containsAll(assets));
    },
  );

  test('Class 6 prepared content retains grade and activity mappings', () {
    final catalog = PreparedCatalog([
      (
        pack: {
          'id': 'six',
          'class_id': 6,
          'class_level': 6,
          'class_name': 'Class VI',
          'chapters': [
            {
              'id': 'chapter',
              'zsl_class_id': 'provider6',
              'subject_id': 'math6',
              'subject_name': 'Mathematics',
            },
          ],
        },
        activities: [
          {
            'id': 'activity',
            'mapping_id': 1977,
            'class_level': 6,
            'zone': 'math',
            'zsl_class_id': 'provider6',
            'subject_id': 'math6',
            'chapter_id': 'chapter',
            'topic_id': 'topic',
            'name': 'Introduction To Patterns In Mathematics',
          },
        ],
      ),
    ]);
    expect(
      (catalog.response('/zsl/classes', {}) as List).single['class_level'],
      6,
    );
    expect(class6MathActivityWidgets[1977], isNotNull);
  });
}
