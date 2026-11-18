import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/json.dart';
import '../../state/lab_practice.dart';
import '../lab_admin/lab_activity_host.dart';
import 'offline_activity_page.dart';
import 'offline_service.dart';
import 'offline_runtime.dart';

/// Keeps the normal activity route and uses the durable native player offline.
class OfflineActivityEntry extends ConsumerStatefulWidget {
  const OfflineActivityEntry({super.key, required this.activityContext});
  final Map<String, dynamic> activityContext;
  @override
  ConsumerState<OfflineActivityEntry> createState() =>
      _OfflineActivityEntryState();
}

class _OfflineActivityEntryState extends ConsumerState<OfflineActivityEntry> {
  late final _content = _load();
  Future<Widget> _load() async {
    final service = ref.read(offlineServiceProvider);
    final catalog = await service.preparedCatalog();
    final ctx = widget.activityContext;
    final matches =
        <
          ({
            Map<String, dynamic> pack,
            List<Map<String, dynamic>> activities,
            String activityId,
          })
        >[];
    for (final entry in catalog.entries) {
      final candidates = entry.activities
          .where(
            (a) =>
                '${a['zsl_class_id']}' == '${ctx['classId']}' &&
                (ctx['chapterId'] == null ||
                    '${a['chapter_id']}' == '${ctx['chapterId']}') &&
                (ctx['subjectId'] == null ||
                    '${a['subject_id']}' == '${ctx['subjectId']}'),
          )
          .toList();
      final match = ctx['activityId'] == null || '${ctx['activityId']}'.isEmpty
          ? candidates.firstOrNull
          : candidates
                .where((a) => '${a['id']}' == '${ctx['activityId']}')
                .firstOrNull;
      if (match == null) continue;
      matches.add((
        pack: entry.pack,
        activities: entry.activities,
        activityId: '${match['id']}',
      ));
    }
    if (matches.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'This activity is not prepared for offline use. Connect to the internet and choose Prepare for offline use.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    for (final entry in matches) {
      await service.validateFiles(
        entry.activities.firstWhere((a) => '${a['id']}' == entry.activityId),
      );
    }
    final classIds = matches
        .map((entry) => '${entry.pack['class_id']}')
        .toSet();
    return LabActivityHost(
      recordUsage: false,
      optionsLoader: (query) async {
        final options = await service.practiceOptions(query);
        if (query['class_id'] == null) {
          return {
            'classes': asList(
              options['classes'],
            ).where((c) => classIds.contains('${asMap(c)?['id']}')).toList(),
          };
        }
        if (!classIds.contains('${query['class_id']}')) return {};
        return options;
      },
      builder: (key) {
        final practice = ref.read(labPracticeProvider);
        final entry =
            matches
                .where(
                  (entry) =>
                      '${entry.pack['class_id']}' == '${practice?.classId}',
                )
                .firstOrNull ??
            matches.first;
        return OfflineActivityPage(
          key: key,
          pack: entry.pack,
          activities: entry.activities,
          initialActivityId: entry.activityId,
          initialQuiz: ctx['offlineQuiz'] == true,
          backRoute: '${ctx['fromRoute'] ?? ctx['returnPath'] ?? '/library'}',
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Widget>(
    future: _content,
    builder: (context, snapshot) {
      if (snapshot.hasError)
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Unable to open prepared content. ${snapshot.error}'),
          ),
        );
      return snapshot.data ?? const Center(child: CircularProgressIndicator());
    },
  );
}

class OfflineAwareActivity extends ConsumerStatefulWidget {
  const OfflineAwareActivity({
    super.key,
    required this.readContext,
    required this.onlineBuilder,
  });
  final Map<String, dynamic> Function(WidgetRef) readContext;
  final WidgetBuilder onlineBuilder;
  @override
  ConsumerState<OfflineAwareActivity> createState() =>
      _OfflineAwareActivityState();
}

class _OfflineAwareActivityState extends ConsumerState<OfflineAwareActivity> {
  bool _localPlayback = false;
  @override
  Widget build(BuildContext context) {
    if (ref.watch(offlineBrowsingProvider)) _localPlayback = true;
    return _localPlayback
        ? OfflineActivityEntry(activityContext: widget.readContext(ref))
        : widget.onlineBuilder(context);
  }
}
