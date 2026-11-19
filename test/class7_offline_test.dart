import 'dart:convert';
import 'dart:io';

import 'package:elab_app/features/offline/activities/class7/math/registry.dart';
import 'package:elab_app/features/offline/activities/class7/science/registry.dart';
import 'package:elab_app/features/offline/prepared_catalog.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'every Class 7 mapping resolves to its native activity and correct zone',
    () async {
      final catalog =
          jsonDecode(
                await rootBundle.loadString(
                  'assets/offline/class7_catalog.json',
                ),
              )
              as Map;
      expect(catalog['class_level'], 7);
      expect(class7MathActivityWidgets.length, 89);
      expect(class7ScienceActivityWidgets.length, 65);
      final widgets = {
        ...class7MathActivityWidgets,
        ...class7ScienceActivityWidgets,
      };
      final mappings = (catalog['activities'] as List).cast<Map>();
      expect(mappings.length, 154);
      expect(mappings.map((a) => a['mapping_id']).toSet().length, 154);
      for (final item in mappings) {
        expect(widgets[item['mapping_id']], isNotNull, reason: item.toString());
        expect(
          class7MathActivityWidgets.containsKey(item['mapping_id']),
          item['zone'] == 'math',
        );
        expect(
          class7ScienceActivityWidgets.containsKey(item['mapping_id']),
          item['zone'] == 'science',
        );
      }
      expect(widgets[999999], isNull);
      for (final grade in [8, 9, 10]) {
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
    'all Class 7 sounds are bundled and referenced without remote playback',
    () async {
      final files = Directory('lib/features/offline/activities/class7')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      final referenced = <String>{};
      for (final file in files) {
        final text = file.readAsStringSync();
        expect(text, isNot(contains('UrlSource(')), reason: file.path);
        expect(text, isNot(contains('NetworkImage(')), reason: file.path);
        referenced.addAll(
          RegExp(r'''["']([^"'\r\n]+\.(?:mp3|ogg|wav))["']''')
              .allMatches(text)
              .map(
                (match) =>
                    'assets/audio/class7/' + match.group(1)!.split('/').last,
              ),
        );
      }
      expect(referenced, isNotEmpty);
      final assets = Directory('assets/audio/class7')
          .listSync()
          .whereType<File>()
          .map((file) => 'assets/audio/class7/' + file.uri.pathSegments.last)
          .toSet();
      expect(assets.length, 66);
      expect(assets, containsAll(referenced));
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

  test('Class 7 prepared content retains grade and activity mappings', () {
    final catalog = PreparedCatalog([
      (
        pack: {
          'id': 'seven',
          'class_id': 7,
          'class_level': 7,
          'class_name': 'Class VII',
          'chapters': [
            {
              'id': 'chapter',
              'zsl_class_id': 'provider7',
              'subject_id': 'math7',
              'subject_name': 'Mathematics',
            },
          ],
        },
        activities: [
          {
            'id': 'activity',
            'mapping_id': 2457,
            'class_level': 7,
            'zone': 'math',
            'zsl_class_id': 'provider7',
            'subject_id': 'math7',
            'chapter_id': 'chapter',
            'topic_id': 'topic',
            'name': 'Scale Of Lakh App',
          },
        ],
      ),
    ]);
    expect(
      (catalog.response('/zsl/classes', {}) as List).single['class_level'],
      7,
    );
    expect(class7MathActivityWidgets[2457], isNotNull);
  });
  test(
    'streaming BioDigital viewer is not offered as an offline activity',
    () async {
      expect(class7MathActivityWidgets[2326], isNull);
      expect(class7ScienceActivityWidgets[2326], isNull);
      expect(class7ScienceActivityWidgets[2320], isNull);
      expect(class7ScienceActivityWidgets[2324], isNull);
      final catalog =
          jsonDecode(
                await rootBundle.loadString(
                  'assets/offline/class7_catalog.json',
                ),
              )
              as Map;
      expect(
        (catalog['activities'] as List).any(
          (item) => item['mapping_id'] == 2326,
        ),
        false,
      );
    },
  );
  test(
    'all literal illustration assets used by active Class 7 activities are bundled',
    () async {
      final files = Directory('lib/features/offline/activities/class7')
          .listSync(recursive: true)
          .whereType<File>()
          .where((file) => file.path.endsWith('.dart'));
      final images = <String>{};
      for (final file in files) {
        images.addAll(
          RegExp(
            r'''["'](assets/[^"'\r\n]+\.(?:png|jpg|jpeg|webp))["']''',
          ).allMatches(file.readAsStringSync()).map((match) => match.group(1)!),
        );
      }
      for (final image in images) {
        expect(
          (await rootBundle.load(image)).lengthInBytes,
          greaterThan(0),
          reason: image,
        );
      }
    },
  );
}
