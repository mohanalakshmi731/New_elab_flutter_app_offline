import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_client.dart';
import '../../core/utils/json.dart';
import '../../state/lab_practice.dart';
import '../../state/providers.dart';
import '../offline/offline_runtime.dart';

/// Owns mode and selection for either activity player. A new identity gets a
/// fresh player, signed link, tracking key, and quiz state.
class LabActivityHost extends ConsumerStatefulWidget {
  const LabActivityHost({
    super.key,
    required this.builder,
    this.optionsLoader,
    this.recordUsage = true,
  });
  final Future<Map<String, dynamic>> Function(Map<String, dynamic>)?
  optionsLoader;
  final bool recordUsage;
  final Widget Function(Key key) builder;
  @override
  ConsumerState<LabActivityHost> createState() => _LabActivityHostState();
}

class _LabActivityHostState extends ConsumerState<LabActivityHost> {
  bool _practice = false;
  bool _loading = false;
  String? _error;
  int? _classId, _batchId, _studentId;
  int _revision = 0;
  int _request = 0;
  List<Map<String, dynamic>> _classes = [], _batches = [], _students = [];
  late final ProviderContainer _container;
  LabPractice? _owned;
  Timer? _usageTimer;

  @override
  void initState() {
    super.initState();
    _container = ProviderScope.containerOf(context, listen: false);
    _usageTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      final session = _container.read(sessionProvider);
      if (!widget.recordUsage ||
          !session.isLabAdmin ||
          !_practice ||
          _studentId == null)
        return;
      try {
        await _container
            .read(apiClientProvider)
            .post(
              '/usage-tracking/record',
              data: {'institute_id': session.instituteId},
              silent: true,
            );
      } catch (_) {
        // A failed heartbeat must not interrupt the activity.
      }
    });
  }

  void _publish() {
    final session = _container.read(sessionProvider);
    _owned = LabPractice(
      token: session.token,
      practice: _practice,
      classId: _classId,
      batchId: _batchId,
      student: _students.where((s) => asInt(s['id']) == _studentId).firstOrNull,
    );
    _container.read(labPracticeProvider.notifier).set(_owned);
    _revision++;
  }

  @override
  void dispose() {
    _usageTimer?.cancel();
    final owned = _owned;
    // Clear after widget teardown; never clear a newer host's identity.
    Future.microtask(() {
      if (owned != null &&
          identical(_container.read(labPracticeProvider), owned)) {
        _container.read(labPracticeProvider.notifier).set(null);
      }
    });
    super.dispose();
  }

  Future<void> _load() async {
    final request = ++_request;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final query = <String, dynamic>{
        'institute_id': _container.read(sessionProvider).instituteId,
        if (_classId != null) 'class_id': _classId,
        if (_batchId != null) 'batch_id': _batchId,
      };
      final result = widget.optionsLoader != null
          ? await widget.optionsLoader!(query)
          : asMap(
                  await _container
                      .read(apiClientProvider)
                      .get('/lab-admin/practice-options', query: query),
                ) ??
                {};
      if (!mounted || request != _request) return;
      List<Map<String, dynamic>> rows(String key) => asList(
        result[key],
      ).map(asMap).whereType<Map<String, dynamic>>().toList();
      setState(() {
        if (_classId == null) {
          _classes = rows('classes');
        } else if (_batchId == null) {
          _batches = rows('batches');
        } else {
          _students = rows('students');
        }
      });
    } catch (error) {
      if (mounted && request == _request) {
        setState(() => _error = ApiClient.messageOf(error));
      }
    } finally {
      if (mounted && request == _request) setState(() => _loading = false);
    }
  }

  Widget _select(
    String label,
    int? value,
    List<Map<String, dynamic>> rows,
    ValueChanged<int?> change,
  ) => SizedBox(
    width: 220,
    child: DropdownButtonFormField<int>(
      key: ValueKey('$label:$value:$_revision'),
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: 'Select ${label.toLowerCase()}',
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: const OutlineInputBorder(),
      ),
      items: rows
          .map(
            (r) => DropdownMenuItem(
              value: asInt(r['id']),
              child: Text(
                '${r['name'] ?? r['full_name'] ?? r['id']}',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          )
          .toList(),
      onChanged: _loading ? null : change,
    ),
  );

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(sessionProvider).isLabAdmin) {
      return widget.builder(const ValueKey('activity'));
    }
    return Column(
      // Routed activity pages use positioned stacks. Give them tight width
      // constraints, otherwise the workspace can shrink to zero width.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!ref.watch(offlineWorkspaceFocusProvider))
          Padding(
            padding: const EdgeInsets.all(12),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                SizedBox(
                  width: 230,
                  child: DropdownButtonFormField<bool>(
                    initialValue: _practice,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      hintText: 'Activity mode',
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: false,
                        child: Text('Presentation mode'),
                      ),
                      DropdownMenuItem(
                        value: true,
                        child: Text('Practice mode'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v == null || v == _practice) return;
                      setState(() {
                        _request++;
                        _loading = false;
                        _error = null;
                        _practice = v;
                        _classId = null;
                        _batchId = null;
                        _studentId = null;
                        _classes = [];
                        _batches = [];
                        _students = [];
                        _publish();
                      });
                      if (v) _load();
                    },
                  ),
                ),
                if (_practice) ...[
                  _select('Assigned class', _classId, _classes, (id) {
                    setState(() {
                      _classId = id;
                      _batchId = null;
                      _studentId = null;
                      _batches = [];
                      _students = [];
                      _publish();
                    });
                    _load();
                  }),
                  if (_classId != null)
                    _select('Batch', _batchId, _batches, (id) {
                      setState(() {
                        _batchId = id;
                        _studentId = null;
                        _students = [];
                        _publish();
                      });
                      _load();
                    }),
                  if (_batchId != null)
                    _select('Student', _studentId, _students, (id) {
                      setState(() {
                        _studentId = id;
                        _publish();
                      });
                    }),
                  if (_loading)
                    const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(),
                    ),
                  if (_error != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_error!),
                        TextButton(
                          onPressed: _load,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  if (!_loading &&
                      _error == null &&
                      ((_classId == null && _classes.isEmpty) ||
                          (_classId != null &&
                              _batchId == null &&
                              _batches.isEmpty) ||
                          (_batchId != null && _students.isEmpty)))
                    const Text('No assigned options available.'),
                ],
              ],
            ),
          ),
        Expanded(
          child: _practice && _studentId == null
              ? const Center(
                  child: Text(
                    'Select a class, batch, and student to begin practice.',
                  ),
                )
              : widget.builder(ValueKey(_revision)),
        ),
      ],
    );
  }
}
