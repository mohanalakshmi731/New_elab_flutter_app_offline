import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:html/parser.dart' as html;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/json.dart';
import '../../data/models/session.dart';
import '../../state/lab_practice.dart';
import '../../state/providers.dart';
import '../../widgets/web_content_view.dart';
import 'local_activity_registry.dart';
import 'offline_database.dart';
import 'offline_service.dart';
import 'offline_support.dart';
import 'offline_workspace.dart';
import 'offline_saved_dialog.dart';
import 'offline_runtime.dart';
import '../quiz/quiz_exam.dart';

class OfflineActivityPage extends ConsumerStatefulWidget {
  const OfflineActivityPage({
    super.key,
    required this.pack,
    required this.activities,
    required this.initialActivityId,
    this.initialQuiz = false,
    this.backRoute = '/library',
  });
  final Map<String, dynamic> pack;
  final List<Map<String, dynamic>> activities;
  final String initialActivityId;
  final bool initialQuiz;
  final String backRoute;
  @override
  ConsumerState<OfflineActivityPage> createState() =>
      _OfflineActivityPageState();
}

class _OfflineActivityPageState extends ConsumerState<OfflineActivityPage>
    with WidgetsBindingObserver {
  late OfflineService _service;
  OfflineDatabase? _db;
  late String _scope;
  late String _identity;
  late Map<String, dynamic> _actor;
  late int _index;
  int _tab = 0, _restart = 0;
  String _sessionId = const Uuid().v4();
  int _sequence = 0;
  bool _active = true, _fullscreen = false, _completed = false;
  bool _ready = false, _submitting = false;
  bool _disposing = false;
  String? _error;
  Map<String, dynamic> _answers = {};
  List<Map<String, dynamic>> _attempts = [];
  final _watch = Stopwatch();
  Timer? _timer;
  DateTime _intervalStart = DateTime.now().toUtc();
  final _playerKey = GlobalKey();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _workspaceOwner = Object();
  late ProviderContainer _workspaceContainer;

  Map<String, dynamic> get _activity => widget.activities[_index];
  String get _id => '${_activity['id']}';
  String get _packId => '${widget.pack['id']}';
  bool get _student => _actor['student_id'] != null;
  bool get _shouldTrack => _ready && _active && _tab == 0 && !_submitting;
  List<Map<String, dynamic>> get _questions => asList(
    _activity['questions'],
  ).map(asMap).whereType<Map<String, dynamic>>().toList();

  @override
  void initState() {
    super.initState();
    ref.listenManual(offlineLocalModeProvider, (previous, next) {
      if (previous == true && !next && _ready) _flush();
    });
    WidgetsBinding.instance.addObserver(this);
    _workspaceContainer = ProviderScope.containerOf(context, listen: false);
    Future.microtask(() {
      if (mounted)
        _workspaceContainer.read(offlineWorkspaceOwnerProvider.notifier).state =
            _workspaceOwner;
    });
    _service = ref.read(offlineServiceProvider);
    _scope = _service.scope;
    _index = widget.activities.indexWhere(
      (a) => '${a['id']}' == widget.initialActivityId,
    );
    if (_index < 0) _index = 0;
    final session = ref.read(sessionProvider);
    final practice = ref.read(labPracticeProvider);
    _actor = {
      'student_id': session.userInfo?.studentId,
      'batch_id': session.batchId,
    };
    if (session.isLabAdmin && practice?.practice == true) {
      _actor = {
        'student_id': practice!.student?['id'],
        'batch_id': practice.batchId,
      };
      if (practice.classId != asInt(widget.pack['class_id'])) {
        _error = 'Select the class belonging to this downloaded package.';
      }
    }
    if (widget.initialQuiz && _student) _tab = 6;
    _identity =
        '${_actor['student_id'] ?? 'presentation'}:${_actor['batch_id'] ?? ''}';
    Future.microtask(_initialize);
  }

  Future<void> _initialize() async {
    try {
      _db = await _service.database();
      if (ref.read(sessionProvider).role == Role.student) {
        final context = await _service.savedContext();
        final classes = asList(
          context['classes'],
        ).map(asMap).whereType<Map<String, dynamic>>();
        final cls = classes
            .where((c) => '${c['id']}' == '${widget.pack['class_id']}')
            .firstOrNull;
        final batches = asList(
          cls?['batches'],
        ).map(asMap).whereType<Map<String, dynamic>>();
        final candidates = <Map<String, dynamic>>[];
        for (final batch in batches) {
          for (final raw in asList(batch['students'])) {
            final student = asMap(raw)!;
            if ('${student['user_id']}' ==
                '${ref.read(sessionProvider).userId}') {
              candidates.add({
                'student_id': student['id'],
                'batch_id': batch['id'],
              });
            }
          }
        }
        final actor =
            candidates
                .where(
                  (a) => a['batch_id'] == ref.read(sessionProvider).batchId,
                )
                .firstOrNull ??
            candidates.firstOrNull;
        if (actor == null)
          throw StateError(
            'Refresh your assigned classes online before using this package.',
          );
        _actor = actor;
        _identity = '${_actor['student_id']}:${_actor['batch_id']}';
      }
      if (widget.initialQuiz && _student) _tab = 6;
      _restoreQuiz();
      if (!mounted) return;
      setState(() => _ready = _error == null);
      _intervalStart = DateTime.now().toUtc();
      _watch.start();
      _timer = Timer.periodic(const Duration(seconds: 10), (_) => _flush());
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  void _restoreQuiz() {
    _answers = _db!.draft(_scope, _identity, _packId, _id);
    _attempts = _db!.attempts(_scope, _identity, _id);
  }

  Map<String, dynamic> _event(
    String kind, {
    int seconds = 0,
    DateTime? start,
  }) => {
    'session_id': _sessionId,
    'sequence': _sequence++,
    'pack_id': _packId,
    'activity_id': _id,
    'activity_name': _activity['name'],
    'kind': kind,
    ..._actor,
    'duration_seconds': seconds,
    'started_at': (start ?? DateTime.now().toUtc()).toIso8601String(),
    'ended_at': DateTime.now().toUtc().toIso8601String(),
  };

  void _flush() {
    if (_db == null || !_ready) return;
    if (DateTime.parse(
          '${widget.pack['expires_at']}',
        ).isBefore(DateTime.now()) ||
        !_service.ownsScope(_scope)) {
      _watch.stop();
      _ready = false;
      _error =
          'Offline access expired or your account changed. Reopen offline learning.';
      if (mounted && !_disposing) setState(() {});
      return;
    }
    final seconds = _watch.elapsed.inSeconds.clamp(0, 600);
    if (seconds > 0) {
      try {
        // The actor and scope were captured at activity start, never read from
        // the currently selected student when a delayed write completes.
        _db!.enqueue(
          _scope,
          _event('session', seconds: seconds, start: _intervalStart),
        );
      } catch (e) {
        _watch.stop();
        if (mounted && !_disposing)
          setState(() {
            _ready = false;
            _error = 'Could not save activity usage: $e';
          });
        return;
      }
      _watch.reset();
    }
    _intervalStart = DateTime.now().toUtc();
    if (_shouldTrack) {
      _watch.start();
    } else {
      _watch.stop();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _flush();
    _active = state == AppLifecycleState.resumed;
    if (_shouldTrack) {
      _watch.start();
    } else {
      _watch.stop();
    }
    _intervalStart = DateTime.now().toUtc();
  }

  @override
  void dispose() {
    _disposing = true;
    Future.microtask(() {
      try {
        if (identical(
          _workspaceContainer.read(offlineWorkspaceOwnerProvider),
          _workspaceOwner,
        )) {
          _workspaceContainer
                  .read(offlineWorkspaceOwnerProvider.notifier)
                  .state =
              null;
          _workspaceContainer
                  .read(offlineWorkspaceFocusProvider.notifier)
                  .state =
              false;
        }
      } on StateError {
        /* App scope has already closed. */
      }
    });
    _flush();
    _timer?.cancel();
    _watch.stop();
    WidgetsBinding.instance.removeObserver(this);
    if (_fullscreen &&
        (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      unawaited(windowManager.setFullScreen(false));
    }
    super.dispose();
  }

  void _changeTab(int index) {
    _flush();
    setState(() => _tab = index);
    if (_shouldTrack) {
      _watch.start();
    } else {
      _watch.stop();
    }
  }

  Future<void> _switch(int index) async {
    if (!_ready ||
        _submitting ||
        index < 0 ||
        index >= widget.activities.length ||
        index == _index)
      return;
    _flush();
    try {
      await _service.validateFiles(widget.activities[index]);
      if (!mounted) return;
      setState(() {
        _index = index;
        _tab = 0;
        _restart++;
        _completed = false;
        _sessionId = const Uuid().v4();
        _sequence = 0;
        _restoreQuiz();
        _intervalStart = DateTime.now().toUtc();
        _watch.reset();
        _watch.start();
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  void _finish() {
    if (!_ready || _completed || _submitting) return;
    _flush();
    if (!_ready) return;
    try {
      _db!.enqueue(_scope, _event('completion'));
      setState(() => _completed = true);
      unawaited(showOfflineSavedDialog(context, quiz: false));
    } catch (e) {
      setState(() => _error = '$e');
    }
  }

  Future<void> _toggleFullscreen() async {
    final full = !_fullscreen;
    try {
      if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
        await windowManager.setFullScreen(full);
      }
    } catch (_) {
      // Keep the in-app focus view usable if OS fullscreen is unavailable.
    }
    if (mounted) {
      ref.read(offlineWorkspaceFocusProvider.notifier).state = full;
      setState(() => _fullscreen = full);
    }
  }

  void _submitQuiz() {
    if (_submitting || !_ready) return;
    _flush();
    if (!_ready) return;
    setState(() => _submitting = true);
    try {
      final result = gradeOfflineQuiz(_questions, _answers);
      final event = {
        ..._event('quiz'),
        'answers': [
          for (final q in _questions)
            {
              'question_id': '${q['id']}',
              'option_id': '${_answers['${q['id']}']}',
            },
        ],
      };
      _db!.saveAttempt(_scope, _identity, event, result);
      setState(() {
        _answers = {};
        _attempts = _db!.attempts(_scope, _identity, _id);
      });
      unawaited(showOfflineSavedDialog(context, quiz: true));
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final native = localActivity(_activity);
    final reachable = ref.exists(offlineRuntimeProvider)
        ? ref.watch(offlineRuntimeProvider.select((state) => state.reachable))
        : null;
    final localMode = ref.watch(offlineLocalModeProvider);
    final tabs = [
      'Activity',
      'Why to Learn',
      'Reference Video',
      'Teacher Guide',
      'Learning Outcome',
      'How to Play',
      if (_student) 'Quiz',
    ];
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            children: [
              const ListTile(title: Text('Chapters and activities')),
              for (var i = 0; i < widget.activities.length; i++)
                ListTile(
                  selected: i == _index,
                  title: Text('${widget.activities[i]['name']}'),
                  subtitle: Text('${widget.activities[i]['chapter_name']}'),
                  onTap: () {
                    Navigator.pop(context);
                    _switch(i);
                  },
                ),
            ],
          ),
        ),
      ),
      body: OfflineWorkspace(
        learningStatus: reachable != true
            ? 'Offline learning · Progress saved automatically'
            : localMode
            ? 'Offline learning · Internet available'
            : 'Online selected · This activity stays saved locally until you leave',
        onSwitchOnline: reachable == true && localMode
            ? () => ref.read(offlineLocalModeProvider.notifier).state = false
            : null,
        title: '${_activity['name']}',
        subtitle:
            '${_activity['chapter_name'] ?? widget.pack['class_name'] ?? ''}',
        tabs: tabs,
        selectedTab: _tab,
        onTab: (index) {
          if (_ready) _changeTab(index);
        },
        fullscreen: _fullscreen,
        completed: _completed,
        error: _error,
        onBack: () => context.go(widget.backRoute),
        onBrowse: () => _scaffoldKey.currentState?.openDrawer(),
        onFullscreen: _toggleFullscreen,
        onRestart: () {
          if (_ready && !_submitting) setState(() => _restart++);
        },
        onFinish: () {
          if (!_submitting && !_completed) _finish();
        },
        onPrevious: _index > 0 ? () => _switch(_index - 1) : null,
        onNext: _index + 1 < widget.activities.length
            ? () => _switch(_index + 1)
            : null,
        child: !_ready
            ? Center(
                child: _error != null
                    ? Text(_error!)
                    : const CircularProgressIndicator(),
              )
            : IndexedStack(
                index: _tab,
                children: [
                  KeyedSubtree(
                    key: _playerKey,
                    child: KeyedSubtree(
                      key: ValueKey('$_id:$_restart'),
                      child:
                          native ??
                          const Center(
                            child: Text('Activity requires an app update.'),
                          ),
                    ),
                  ),
                  _tab == 1 ? _support('description') : const SizedBox.shrink(),
                  _tab == 2
                      ? _support('reference_video')
                      : const SizedBox.shrink(),
                  _tab == 3
                      ? _support('instructions')
                      : const SizedBox.shrink(),
                  _tab == 4
                      ? _support('observations')
                      : const SizedBox.shrink(),
                  _tab == 5 ? _support('autopilots') : const SizedBox.shrink(),
                  if (_student) _quiz(),
                ],
              ),
      ),
    );
  }

  Widget _support(String key) {
    final texts = offlineSupportTexts(_activity, key);
    final files = asList(_activity['files'])
        .map(asMap)
        .whereType<Map<String, dynamic>>()
        .where((file) => file['group'] == key)
        .toList();
    if (key == 'reference_video' && files.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.wifi_rounded, size: 40),
              SizedBox(height: 16),
              Text(
                'This video needs an internet connection.',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8),
              Text(
                'Your saved activity and learning materials are available in the other tabs.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8),
      child: OfflineSupportWorkspace(
        key: ValueKey('$_id:$key'),
        panels: [
          for (final text in texts) WebContentView(html: text, offline: true),
          for (final file in files) _OfflineFile(file: file),
        ],
        labels: [
          for (var i = 0; i < texts.length; i++)
            texts.length == 1 ? 'Overview' : 'Notes ${i + 1}',
          for (final file in files) '${file['name'] ?? 'Document'}',
        ],
      ),
    );
  }

  Widget _quiz() {
    if (_questions.isEmpty) {
      return const Center(
        child: Text(
          'No quiz is saved for this activity. Update offline content while online.',
        ),
      );
    }
    return QuizExamView(
      key: ValueKey('quiz:$_id:${_attempts.length}'),
      questions: _questions,
      quizTitle: '${_activity['name']} ? Quiz',
      offline: true,
      embedded: true,
      initialAnswers: _answers,
      onAnswersChanged: (answers) {
        setState(() => _answers = answers);
        _db?.saveDraft(_scope, _identity, _packId, _id, _answers);
      },
      onSubmitted: (payload) {
        _answers = asMap(payload['answers']) ?? {};
        _submitQuiz();
      },
      onClose: () => _changeTab(0),
    );
  }
}

/// Never asks the network to render downloaded explanatory text.
class OfflineHtml extends StatelessWidget {
  const OfflineHtml({super.key, required this.data});
  final String data;
  @override
  Widget build(BuildContext context) {
    final fragment = html.parseFragment(data);
    for (final element in fragment.querySelectorAll(
      'script,iframe,object,embed,link,style,video,audio',
    )) {
      element.remove();
    }
    for (final image in fragment.querySelectorAll('img')) {
      image.attributes.remove('srcset');
      if (!(image.attributes['src'] ?? '').startsWith('data:image/')) {
        image.replaceWith(
          html
              .parseFragment('<span>[Image unavailable offline]</span>')
              .nodes
              .first,
        );
      }
    }
    for (final element in fragment.querySelectorAll('*')) {
      element.attributes.removeWhere(
        (key, value) =>
            '$key'.startsWith('on') ||
            ('$key' == 'style' && value.contains('url(')),
      );
    }
    final safe = fragment.outerHtml;
    return Html(data: safe);
  }
}

class _OfflineFile extends ConsumerStatefulWidget {
  const _OfflineFile({required this.file});
  final Map<String, dynamic> file;
  @override
  ConsumerState<_OfflineFile> createState() => _OfflineFileState();
}

class _OfflineFileState extends ConsumerState<_OfflineFile> {
  late final Future<Uint8List> _bytes;
  Future<String>? _view;
  Directory? _temporary;
  bool _disposed = false;
  @override
  void initState() {
    super.initState();
    _bytes = ref
        .read(offlineServiceProvider)
        .readFile(File('${widget.file['path']}'));
  }

  Future<String> _viewPath(Uint8List bytes, String extension) async {
    final directory = await Directory.systemTemp.createTemp(
      'elab-offline-view-',
    );
    _temporary = directory;
    final file = File('${directory.path}/content.$extension');
    await file.writeAsBytes(bytes, flush: true);
    if (_disposed) {
      await _cleanup();
      throw StateError('Viewer closed.');
    }
    return file.path;
  }

  Future<void> _cleanup() async {
    final directory = _temporary;
    if (directory == null || !await directory.exists()) return;
    try {
      await for (final entry in directory.list()) {
        if (entry is File) await entry.delete();
      }
      await directory.delete();
    } catch (_) {
      /* The native viewer may still be releasing its file. */
    }
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(
      _bytes
          .then((_) async {
            await Future<void>.delayed(const Duration(seconds: 1));
            await _cleanup();
          })
          .catchError((_) {}),
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<Uint8List>(
    future: _bytes,
    builder: (context, result) {
      if (result.hasError)
        return const Text(
          'Prepared file is unavailable. Prepare content again while online.',
        );
      if (!result.hasData)
        return const Center(child: CircularProgressIndicator());
      final bytes = result.data!;
      final extension = '${widget.file['path']}'.split('.').last.toLowerCase();
      if (['png', 'jpg', 'jpeg', 'gif', 'webp'].contains(extension))
        return Image.memory(bytes, fit: BoxFit.contain);
      if (['html', 'htm'].contains(extension)) {
        return WebContentView(html: utf8.decode(bytes), offline: true);
      }
      if (extension == 'txt')
        return SingleChildScrollView(
          child: OfflineHtml(data: utf8.decode(bytes)),
        );
      if (['pdf', 'mp4', 'webm'].contains(extension)) {
        _view ??= _viewPath(bytes, extension);
        return FutureBuilder<String>(
          future: _view,
          builder: (_, value) => value.hasData
              ? WebContentView(url: Uri.file(value.data!).toString())
              : const Center(child: CircularProgressIndicator()),
        );
      }
      return ListTile(
        title: Text('${widget.file['name']}'),
        subtitle: const Text('Preview is unavailable for this file type.'),
      );
    },
  );
}
