import 'dart:convert';
import 'dart:io';

import 'package:elab_app/features/offline/activities/class8/math/registry.dart';
import 'package:elab_app/features/offline/activities/class8/science/registry.dart';
import 'package:elab_app/features/offline/prepared_catalog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'every Class 8 mapping resolves to its native activity and correct zone',
    () async {
      final catalog =
          jsonDecode(
                await rootBundle.loadString(
                  'assets/offline/class8_catalog.json',
                ),
              )
              as Map;
      expect(catalog['class_level'], 8);
      expect(class8MathActivityWidgets.length, 74);
      expect(class8ScienceActivityWidgets.length, 65);
      final widgets = {
        ...class8MathActivityWidgets,
        ...class8ScienceActivityWidgets,
      };
      final mappings = (catalog['activities'] as List).cast<Map>();
      expect(mappings.length, 139);
      expect(mappings.map((a) => a['mapping_id']).toSet().length, 139);
      for (final item in mappings) {
        expect(widgets[item['mapping_id']], isNotNull, reason: item.toString());
        expect(
          class8MathActivityWidgets.containsKey(item['mapping_id']),
          item['zone'] == 'math',
        );
        expect(
          class8ScienceActivityWidgets.containsKey(item['mapping_id']),
          item['zone'] == 'science',
        );
      }
      expect(widgets[999999], isNull);
      for (final grade in [9, 10]) {
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
    'all Class 8 sounds are bundled and referenced without remote playback',
    () async {
      final files = Directory('lib/features/offline/activities/class8')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      final assets = <String>{};
      for (final file in files) {
        final text = file.readAsStringSync();
        expect(text, isNot(contains('UrlSource(')), reason: file.path);
        expect(text, isNot(contains('NetworkImage(')), reason: file.path);
        assets.addAll(
          RegExp(
            r'''["'](?:assets/)?(audio/class8/[^"']+)["']''',
          ).allMatches(text).map((m) => 'assets/' + m.group(1)!),
        );
      }
      expect(assets.length, 23);
      for (final asset in assets) {
        final bytes = await rootBundle.load(asset);
        expect(bytes.lengthInBytes, greaterThan(1000), reason: asset);
      }
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      expect(manifest.listAssets(), containsAll(assets));
      expect(
        manifest.listAssets(),
        contains('assets/images/offline_texture.png'),
      );
      expect(
        (await rootBundle.load(
          'assets/images/offline_texture.png',
        )).lengthInBytes,
        greaterThan(0),
      );
    },
  );

  test('Class 8 prepared content retains grade and activity mappings', () {
    final catalog = PreparedCatalog([
      (
        pack: {
          'id': 'eight',
          'class_id': 8,
          'class_level': 8,
          'class_name': 'Class VIII',
          'chapters': [
            {
              'id': 'chapter',
              'zsl_class_id': 'provider8',
              'subject_id': 'math8',
              'subject_name': 'Mathematics',
            },
          ],
        },
        activities: [
          {
            'id': 'activity',
            'mapping_id': 2661,
            'class_level': 8,
            'zone': 'math',
            'zsl_class_id': 'provider8',
            'subject_id': 'math8',
            'chapter_id': 'chapter',
            'topic_id': 'topic',
            'name': 'Cube Roots',
          },
        ],
      ),
    ]);
    expect(
      (catalog.response('/zsl/classes', {}) as List).single['class_level'],
      8,
    );
    expect(class8MathActivityWidgets[2661], isNotNull);
  });
}
