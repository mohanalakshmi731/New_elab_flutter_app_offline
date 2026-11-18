import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/json.dart';
import '../../state/providers.dart';
import '../../data/models/session.dart';
import 'offline_runtime.dart';
import 'offline_service.dart';

Future<void> showOfflinePreparation(BuildContext context) => showDialog<void>(
  context: context,
  useSafeArea: true,
  builder: (_) => Dialog(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: const OfflinePreparation(),
    ),
  ),
);

/// One explicit preparation action; browsing and records stay in normal screens.
class OfflinePreparation extends ConsumerStatefulWidget {
  const OfflinePreparation({super.key});
  @override
  ConsumerState<OfflinePreparation> createState() => _OfflinePreparationState();
}

class _OfflinePreparationState extends ConsumerState<OfflinePreparation> {
  List<Map<String, dynamic>> _classes = [];
  Set<String> _prepared = {};
  int? _classId;
  late int _languageId;
  bool _loading = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    final languageId = ref.read(sessionProvider).language.id;
    _languageId = languageId;
    Future.microtask(_load);
  }

  Future<void> _load() async {
    try {
      final service = ref.read(offlineServiceProvider);
      final data = await service.refreshContext();
      final packs = await service.packs();
      if (!mounted) return;
      setState(() {
        // Assignments can repeat a class; dropdown values must be unique.
        final classesById = <int, Map<String, dynamic>>{};
        for (final raw in asList(data['classes'])) {
          final cls = asMap(raw);
          final id = asInt(cls?['id']);
          if (cls != null && id != null) {
            classesById.putIfAbsent(id, () => {...cls, 'id': id});
          }
        }
        _classes = classesById.values.toList();
        _classId = _classes.isEmpty ? null : asInt(_classes.first['id']);
        _prepared = {
          for (final pack in packs)
            if (DateTime.tryParse(
                  '${pack['expires_at']}',
                )?.isAfter(DateTime.now()) ==
                true)
              '${pack['class_id']}:${pack['language_id']}',
        };
        _loading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = offlinePreparationError(e);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final runtime = ref.watch(offlineRuntimeProvider);
    final updating = _prepared.contains('$_classId:$_languageId');
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        24 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(Icons.offline_bolt_rounded),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  updating
                      ? 'Update offline content'
                      : 'Get ready to learn offline',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Save your class content so you can keep learning without an internet connection. Choose your class and language to get started.',
          ),
          const SizedBox(height: 20),
          if (_loading)
            const LinearProgressIndicator()
          else if (_error != null) ...[
            Text(_error!),
            TextButton(
              onPressed: () {
                setState(() {
                  _loading = true;
                  _error = null;
                });
                _load();
              },
              child: const Text('Try again'),
            ),
          ] else if (_classes.isEmpty)
            const Text(
              'No eligible assigned classes were returned for this account. Check that your class and batch assignments are published. Offline play is available for activities included in this app.',
            )
          else ...[
            DropdownButtonFormField<int>(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
              initialValue: _classId,
              isExpanded: true,
              decoration: const InputDecoration(hintText: 'Select class'),
              items: _classes
                  .map(
                    (c) => DropdownMenuItem(
                      value: asInt(c['id']),
                      child: Text(
                        '${c['name']}',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: runtime.preparing
                  ? null
                  : (id) => setState(() => _classId = id),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontSize: 16,
              ),
              dropdownColor: Theme.of(context).colorScheme.surface,
              initialValue: _languageId,
              isExpanded: true,
              decoration: const InputDecoration(hintText: 'Content language'),
              items: [
                const DropdownMenuItem(value: 1, child: Text('English')),
                const DropdownMenuItem(value: 2, child: Text('Hindi')),
                if (ref.read(sessionProvider).language.id != 1 &&
                    ref.read(sessionProvider).language.id != 2)
                  DropdownMenuItem(
                    value: ref.read(sessionProvider).language.id,
                    child: Text(ref.read(sessionProvider).language.name),
                  ),
              ],
              onChanged: runtime.preparing
                  ? null
                  : (id) => setState(() => _languageId = id ?? 1),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: runtime.preparing || _classId == null
                  ? null
                  : () {
                      final language = ref.read(sessionProvider).language;
                      if (language.id != _languageId) {
                        ref
                            .read(sessionProvider.notifier)
                            .setLanguage(
                              AppLanguage(
                                id: _languageId,
                                code: _languageId == 2 ? 'hi' : 'en',
                                name: _languageId == 2 ? 'HINDI' : 'ENGLISH',
                              ),
                            );
                      }
                      unawaited(
                        ref
                            .read(offlineRuntimeProvider.notifier)
                            .prepare(_classId!, _languageId),
                      );
                      Navigator.pop(context);
                    },
              icon: const Icon(Icons.offline_bolt_outlined),
              label: Text(
                runtime.preparing
                    ? 'Preparing content...'
                    : updating
                    ? 'Update offline content'
                    : 'Prepare for offline use',
              ),
            ),
          ],
          if (runtime.preparing) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
            const SizedBox(height: 8),
            Text(runtime.message),
          ],
          const SizedBox(height: 12),
          const Text(
            'You can continue using the app while we get your content ready. We’ll let you know when it’s ready.',
          ),
        ],
      ),
    );
  }
}
