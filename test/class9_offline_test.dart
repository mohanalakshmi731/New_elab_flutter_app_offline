import 'dart:io';

import 'package:elab_app/features/offline/activities/class9/math/registry.dart';
import 'package:elab_app/features/offline/activities/class9/science/registry.dart';
import 'package:elab_app/features/offline/activities/math/registry.dart';
import 'package:elab_app/features/offline/activities/science/registry.dart';
import 'package:elab_app/features/offline/local_activity_registry.dart';
import 'package:elab_app/features/offline/offline_service.dart';
import 'package:elab_app/features/offline/prepared_catalog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'every Class 9 mapping resolves to its native activity and correct zone',
    () async {
      final catalog = await OfflineService.bundledCatalog(classLevel: 9);
      expect(catalog['class_level'], 9);
      expect(class9MathActivityWidgets.length, 46);
      expect(class9ScienceActivityWidgets.length, 54);
      final mappings = (catalog['activities'] as List).cast<Map>();
      expect(mappings.length, 100);
      expect(mappings.map((a) => a['mapping_id']).toSet().length, 100);
      for (final item in mappings) {
        final activity = Map<String, dynamic>.from(item);
        expect(supportsLocalActivity(activity), true, reason: item.toString());
        expect(localActivityZone(activity), item['zone']);
        expect(mathActivityWidgets.containsKey(item['mapping_id']), false);
        expect(scienceActivityWidgets.containsKey(item['mapping_id']), false);
        expect(
          localActivity({
            'id': 999999,
            'activity_data': {'mapping_id': item['mapping_id']},
          }),
          same(localActivity(activity)),
        );
      }
      final ten = await OfflineService.bundledCatalog();
      expect(ten['class_level'], 10);
      for (final item in ten['activities'] as List) {
        expect(
          supportsLocalActivity(Map<String, dynamic>.from(item as Map)),
          true,
        );
      }
    },
  );

  test(
    'all Class 9 sounds are bundled and referenced without remote playback',
    () async {
      final files = Directory('lib/features/offline/activities/class9')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      final assets = <String>{};
      for (final file in files) {
        final text = file.readAsStringSync();
        expect(text, isNot(contains('UrlSource(')), reason: file.path);
        assets.addAll(
          RegExp(
            r'''["'](?:assets/)?(audio/class9/[^"']+)["']''',
          ).allMatches(text).map((m) => 'assets/' + m.group(1)!),
        );
      }
      expect(assets.length, 14);
      for (final asset in assets) {
        final bytes = await rootBundle.load(asset);
        expect(bytes.lengthInBytes, greaterThan(1000), reason: asset);
      }
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      expect(manifest.listAssets(), containsAll(assets));
    },
  );

  test('Class 9 prepared content retains grade and activity mappings', () {
    final catalog = PreparedCatalog([
      (
        pack: {
          'id': 'nine',
          'class_id': 9,
          'class_level': 9,
          'class_name': 'Class IX',
          'chapters': [
            {
              'id': 'chapter',
              'zsl_class_id': 'provider9',
              'subject_id': 'math9',
              'subject_name': 'Mathematics',
            },
          ],
        },
        activities: [
          {
            'id': 'activity',
            'mapping_id': 3945,
            'class_level': 9,
            'zone': 'math',
            'zsl_class_id': 'provider9',
            'subject_id': 'math9',
            'chapter_id': 'chapter',
            'topic_id': 'topic',
            'name': 'Grid Builder',
          },
        ],
      ),
    ]);
    expect(
      (catalog.response('/zsl/classes', {}) as List).single['class_level'],
      9,
    );
    expect(localActivity({'mapping_id': 3945}), isNotNull);
  });
}
