import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/config/env.dart';
import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import '../schedules/schedule_exam_logic.dart' show jsonNum;
import 'exam_window.dart';
import 'proctor_camera.dart';
import 'proctor_logic.dart';
import 'proctor_overlay_painter.dart';
import 'proctor_panel_view.dart';
import 'proctor_service.dart';

/// `this.$refs.proctorPanel` — lets the exam page call `finish(reason)`.
class ExamProctorPanelController {
  _ExamProctorPanelState? _state;

  /// `finish(reason)` — stops camera, analysis and recording and closes the
  /// remote session.
  Future<void> finish([String reason = 'finished']) async => _state?._finish(reason);
}

/// Port of `src/components/proctor/ExamProctorPanel.vue`.
///
/// Props → constructor args (`attemptId`, `examName`, `warningCount`,
/// `maxWarnings`, `leftConfirmed`); emits → callbacks (`ready`, `warning`,
/// `log`, `verification-error`). [onNetworkChanged] is a Flutter-only extra:
/// the camera page relays `window` `online` / `offline`, which the exam page
/// listened to on the web.
///
/// Height: with a bounded height (e.g. inside a `SizedBox`) the panel fills it
/// like the web's `h-[calc(100vh-210px)]` / `!h-full`; unbounded it takes its
/// natural height, at least 500.
class ExamProctorPanel extends ConsumerStatefulWidget {
  const ExamProctorPanel({
    super.key,
    this.controller,
    this.attemptId,
    this.examName = '',
    this.warningCount = 0,
    this.maxWarnings = 3,
    this.leftConfirmed = false,
    this.onReady,
    this.onWarning,
    this.onLog,
    this.onVerificationError,
    this.onNetworkChanged,
  });

  final ExamProctorPanelController? controller;
  final Object? attemptId;
  final String examName;
  final int warningCount;
  final int maxWarnings;
  final bool leftConfirmed;
  final VoidCallback? onReady;
  final ValueChanged<ProctorWarningPayload>? onWarning;
  final void Function(String kind, String message)? onLog;
  final ValueChanged<String>? onVerificationError;
  final ValueChanged<bool>? onNetworkChanged;

  @override
  ConsumerState<ExamProctorPanel> createState() => _ExamProctorPanelState();
}

class _ExamProctorPanelState extends ConsumerState<ExamProctorPanel> {
  late final ProctorService _service = ref.read(proctorServiceProvider);
  final _camera = ProctorCameraController();
  final _gate = ProctorWarningGate();
  static final _timeFormat = DateFormat('hh:mm:ss a');

  // data()
  late final bool _enabled = _service.isEnabled();
  bool _environmentConfirmed = false;
  String _status = 'idle';
  bool _cameraReady = false;
  String _cameraMessage = 'Starting camera...';
  bool _hasStream = false;

  /// `recorder.state` when the recorder was created (null = no recorder).
  String? _recorderState;
  String _sessionId = '';
  bool _recordingEnabled = false;
  String _referenceFrame = '';
  bool _referenceCaptured = false;
  Map<String, dynamic>? _latest;
  List<PanelLog> _logs = const [];
  int _nextLogId = 1;
  Timer? _analyzeTimer;
  bool _analyzing = false;
  bool _verifying = false;
  bool _finishing = false;
  bool _finished = false;
  FrameStats? _lastFrameData;
  List<Map<String, dynamic>> _localPhoneCandidates = const [];
  bool _audioMonitor = false;
  Timer? _audioTimer;
  int _audioSpeechActiveMs = 0;
  double? _audioLevel;
  String _audioStatus = 'Mic pending';
  List<Map<String, dynamic>> _latestAudioEvents = const [];
  int _lastAudioLogAt = 0;
  double? _latestMouthActivity;
  int _latestVisualAnalyzedAt = 0;
  String _lastHeadDirection = '';
  int _lastHeadLogAt = 0;
  OverlaySnapshot? _overlay;
  bool _disposed = false;

  static int get _now => DateTime.now().millisecondsSinceEpoch;

  /// `new Date().toISOString()`
  static String _isoNow() =>
      DateTime.fromMillisecondsSinceEpoch(_now, isUtc: true).toIso8601String();

  void _set(VoidCallback fn) {
    if (!mounted || _disposed) {
      fn();
      return;
    }
    setState(fn);
  }

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _camera.onChunk = _onRecorderChunk;
    _camera.onNetworkChanged = (online) => widget.onNetworkChanged?.call(online);
    // mounted() → start()
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _start();
    });
  }

  @override
  void didUpdateWidget(covariant ExamProctorPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller?._state == this) oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  void dispose() {
    // beforeUnmount() → finish('exam_screen_closed'). No setState from here on.
    _disposed = true;
    unawaited(_finish('exam_screen_closed'));
    _analyzeTimer?.cancel();
    _audioTimer?.cancel();
    if (widget.controller?._state == this) widget.controller?._state = null;
    super.dispose();
  }

  // ── computed ─────────────────────────────────────────────────────────────

  String get _statusLabel {
    if (!_enabled) return 'Disabled';
    if (!_referenceCaptured) return 'Verify';
    if (_status == 'error') return 'Action needed';
    if (_status == 'ready') return 'Active';
    if (_status == 'starting') return 'Starting';
    return 'Idle';
  }

  BadgeTone get _statusTone {
    if (!_enabled) return BadgeTone.gray;
    if (_status == 'error') return BadgeTone.red;
    if (_referenceCaptured && _status == 'ready') return BadgeTone.green;
    return BadgeTone.blue;
  }

  List<Map<String, dynamic>> get _visibleEvents => [...eventsOf(_latest), ..._latestAudioEvents];

  List<Map<String, dynamic>> get _topEvents =>
      _visibleEvents.where((e) => !isHeadPoseEvent(e)).take(2).toList();

  String get _latestLogTime => _logs.isNotEmpty ? _logs.first.time : '--';

  String get _recordingLabel {
    if (_recorderState == null) return _sessionId.isNotEmpty ? 'Session ready' : 'Pending';
    return _recorderState == 'recording' ? 'Active' : 'Paused';
  }

  int get _totalGadgetCount => asList(_latest?['gadgets']).length + _localPhoneCandidates.length;

  String get _audioLevelLabel {
    final level = _audioLevel;
    if (level == null) return _audioStatus;
    return '${(level * 100).round()}% $_audioStatus';
  }

  String get _headDirectionLabel => formatHeadDirection(extractHeadDirection(_latest) ?? 'front');

  bool get _captureDisabled =>
      !_cameraReady ||
      _status == 'starting' ||
      _verifying ||
      _analyzing ||
      !_environmentConfirmed ||
      !widget.leftConfirmed;

  String _msg(Object error, String fallback) {
    if (error is CameraJsError) return error.message ?? fallback;
    return errorMessage(error, fallback);
  }

  // ── methods ──────────────────────────────────────────────────────────────

  Future<void> _start() async {
    if (!_enabled) {
      _addLog('config', 'Proctor AI is disabled');
      widget.onReady?.call();
      return;
    }
    _set(() => _status = 'starting');
    _addLog('init', 'Starting proctor camera');
    try {
      await _startCamera();
      _set(() => _status = 'idle');
    } catch (error) {
      _set(() {
        _status = 'error';
        _cameraMessage = 'Camera or Proctor AI is unavailable';
      });
      _addLog('error', _msg(error, 'Unable to start proctoring'));
    }
  }

  Future<void> _captureReferenceAndStart() async {
    if (_finished ||
        _verifying ||
        _analyzing ||
        !_cameraReady ||
        !_environmentConfirmed ||
        !widget.leftConfirmed) {
      return;
    }
    _set(() => _verifying = true);
    try {
      await _ensureFullscreen();
      await _resumeAudioMonitor();
      final frame = await _captureFrame();
      validateCapturedPixels(_lastFrameData);
      final referenceData = await _analyzeReferenceFrame(frame);
      if (_finished) return;
      validateReferenceAnalysis(referenceData);
      await _startRemoteSession();
      if (_finished) return;
      await _startRecording();
      _set(() {
        _referenceFrame = frame;
        _referenceCaptured = true;
        _latest = referenceData;
        _latestMouthActivity = extractMouthActivity(referenceData);
        _latestVisualAnalyzedAt = _now;
        _localPhoneCandidates = detectPhoneLikeObjects(referenceData, null);
      });
      _drawOverlay(referenceData);
      _addLog('reference', 'Reference photo verified with one clear student face');
      _startAnalyzeLoop();
      _set(() => _status = 'ready');
      widget.onReady?.call();
    } catch (error) {
      final message = _msg(error, 'Reference capture failed');
      _set(() {
        _referenceCaptured = false;
        _referenceFrame = '';
        _status = 'error';
      });
      _addLog('reference', message);
      widget.onVerificationError?.call(message);
    } finally {
      _set(() => _verifying = false);
    }
  }

  Future<void> _ensureFullscreen() async {
    if (!await ExamWindow.ensureFullscreen()) {
      throw const ProctorError('Fullscreen is required to start the exam');
    }
  }

  Future<void> _startCamera() async {
    if (!await ProctorCameraController.requestPermissions()) {
      // What getUserMedia reports when the user blocks the camera.
      throw const CameraJsError('Permission denied');
    }
    final r = await _camera.start();
    if (r.micFailed) {
      _set(() => _audioStatus = 'Mic unavailable');
      _addLog('microphone',
          r.micError != null ? 'Microphone unavailable: ${r.micError}' : 'Microphone unavailable');
    }
    if (!r.ok) {
      if (_camera.mediaSupported == false && r.error == null) {
        throw const ProctorError('Camera access is not supported in this browser');
      }
      throw CameraJsError(r.error);
    }
    if (r.finished || _finished) {
      if (!r.finished) await _camera.stop();
      return;
    }
    _set(() => _hasStream = true);
    _startAudioMonitor(r.audio);
    _set(() => _cameraReady = true);
    _addLog('camera', 'Camera started');
  }

  Future<void> _startRemoteSession() async {
    try {
      final tracks = _hasStream
          ? await _camera.audioTracks()
          : const <String, dynamic>{'count': 0, 'tracks': <dynamic>[]};
      final session = await _service.startSession({
        'attemptId': widget.attemptId,
        'metadata': {
          'examName': widget.examName,
          'origin': Env.webAppOrigin,
          'microphoneAvailable': (asInt(tracks['count']) ?? 0) > 0,
          'audioTracks': _hasStream ? asList(tracks['tracks']) : const <dynamic>[],
        },
      });
      final sessionId = asString(session['sessionId']) ?? '';
      _set(() {
        _sessionId = sessionId;
        _recordingEnabled = jsTruthy(session['recordingEnabled']);
      });
      if (_finished) {
        await _service.finishSession(sessionId, {
          'kind': 'finish',
          'message': 'exam_screen_closed',
          'clientTime': _isoNow(),
        });
        return;
      }
      _addLog('session', 'Remote proctor session created');
    } catch (error) {
      _addLog('session', _msg(error, 'Remote recording session failed'));
    }
  }

  Future<void> _startRecording() async {
    if (!_recordingEnabled || _sessionId.isEmpty || !_hasStream) return;
    try {
      final r = await _camera.startRecording();
      if (r['skipped'] == true) return;
      if (r['created'] == true) _set(() => _recorderState = asString(r['state']) ?? 'inactive');
      if (r['failed'] == true) {
        _addLog('recording', asString(r['error']) ?? 'Recording unavailable');
        return;
      }
      _addLog('recording', 'Session recording started');
    } catch (error) {
      _addLog('recording', _msg(error, 'Recording unavailable'));
    }
  }

  /// `recorder.ondataavailable` → `appendVideoChunk`.
  void _onRecorderChunk(Uint8List bytes, String type) {
    if (bytes.isEmpty || _sessionId.isEmpty) return;
    _service.appendVideoChunk(_sessionId, bytes, type).catchError((Object error) {
      _addLog('recording', _msg(error, 'Video upload failed'));
    });
  }

  void _startAnalyzeLoop() {
    _stopAnalyzeLoop();
    _analyzeTimer = Timer.periodic(
      Duration(milliseconds: _service.getAnalyzeIntervalMs()),
      (_) => _analyzeOnce(),
    );
  }

  void _stopAnalyzeLoop() {
    _analyzeTimer?.cancel();
    _analyzeTimer = null;
  }

  /// `startAudioMonitor()` — the analyser itself lives in the camera page.
  void _startAudioMonitor(String? outcome) {
    _stopAudioMonitor();
    if (outcome == 'unsupported') {
      _set(() => _audioStatus = 'Mic unsupported');
      return;
    }
    if (outcome != 'ready') {
      _set(() {
        _audioStatus = 'Mic unavailable';
        _audioLevel = null;
      });
      return;
    }
    _set(() {
      _audioMonitor = true;
      _audioStatus = 'Mic ready';
    });
    _audioTimer = Timer.periodic(const Duration(milliseconds: 1000), (_) => _analyzeAudioWindow());
  }

  Future<void> _resumeAudioMonitor() async {
    if (!_audioMonitor) return;
    try {
      if (await _camera.resumeAudio()) _set(() => _audioStatus = 'Mic paused');
    } catch (_) {}
  }

  void _stopAudioMonitor() {
    _audioTimer?.cancel();
    _audioTimer = null;
    _audioMonitor = false;
    _audioSpeechActiveMs = 0;
  }

  Future<void> _analyzeAudioWindow() async {
    if (_finished || !_audioMonitor || !_referenceCaptured) return;
    final AudioSample sample;
    try {
      sample = await _camera.sampleAudio();
    } catch (_) {
      return;
    }
    if (!sample.available || _finished) return;
    if (sample.resumeFailed) _set(() => _audioStatus = 'Mic paused');
    if (!sample.running) return;

    final w = analyzeAudioSamples(sample.timeData ?? Uint8List(0),
        sample.frequencyData ?? Uint8List(0), sample.sampleRate, sample.fftSize);
    _audioSpeechActiveMs = nextSpeechActiveMs(_audioSpeechActiveMs, w.speechLike);

    try {
      final data = await _service.analyzeAudio({
        'rms': jsonNum(w.rms),
        'peak': jsonNum(w.peak),
        'speechRatio': jsonNum(w.shape.speechRatio),
        'lowFrequencyRatio': jsonNum(w.shape.lowFrequencyRatio),
        'highFrequencyRatio': jsonNum(w.shape.highFrequencyRatio),
        'zeroCrossingRate': jsonNum(w.zeroCrossingRate),
        'dominantFrequency': w.shape.dominantFrequency == null ? null : jsonNum(w.shape.dominantFrequency!),
        'durationMs': 1000,
        'activeMs': _audioSpeechActiveMs,
        'sampleRate': jsonNum(sample.sampleRate),
        'studentMouthActivity': _latestMouthActivity,
        'visualAgeMs': _latestVisualAnalyzedAt != 0 ? _now - _latestVisualAnalyzedAt : null,
        'attemptId': widget.attemptId,
      });
      if (_finished) return;
      final audioRms = asMap(data['audio'])?['rms'];
      _set(() {
        _audioLevel = audioRms is num ? audioRms.toDouble() : w.rms;
        _audioStatus = eventsOf(data).isNotEmpty ? 'Audio flagged' : 'Listening';
        _latestAudioEvents = eventsOf(data);
      });
      _emitAudioWarningIfNeeded(data);

      final now = _now;
      if (_latestAudioEvents.isNotEmpty || now - _lastAudioLogAt > 5000) {
        _lastAudioLogAt = now;
        _addLog('audio', audioSummaryText(data));
        await _appendRemoteLog('audio', true, 0, data);
      }
    } catch (error) {
      _set(() => _audioStatus = 'Mic check failed');
      _addLog('audio', _msg(error, 'Audio analyze failed'));
    }
  }

  Future<void> _analyzeOnce() async {
    if (_finished || _analyzing || !_cameraReady || !_referenceCaptured) return;
    _set(() => _analyzing = true);
    final started = Stopwatch()..start();
    try {
      final frame = await _captureFrame();
      final data = await _service.analyze({
        'frame': frame,
        'referenceFrame': _referenceFrame.isNotEmpty ? _referenceFrame : null,
        'checkIdentity': true,
        'detectGadgets': true,
        'closeOnMultipleFaces': true,
        'attemptId': widget.attemptId,
      });
      if (_finished) return;
      _set(() {
        _latest = data;
        _latestMouthActivity = extractMouthActivity(data);
        _latestVisualAnalyzedAt = _now;
      });
      _logHeadDirection(data);
      _set(() => _localPhoneCandidates = detectPhoneLikeObjects(data, null));
      _drawOverlay(data);
      final durationMs = started.elapsedMilliseconds;
      _addLog('analyze', summaryText(data, durationMs, _totalGadgetCount));
      await _appendRemoteLog('analyze', true, durationMs, data);
      _emitWarningIfNeeded(data);
    } catch (error) {
      _addLog('analyze', _msg(error, 'Analyze request failed'));
    } finally {
      _set(() => _analyzing = false);
    }
  }

  Future<Map<String, dynamic>> _analyzeReferenceFrame(String frame) async {
    if (_analyzing || !_cameraReady) {
      throw const ProctorError('Reference check is already running');
    }
    _set(() => _analyzing = true);
    final started = Stopwatch()..start();
    try {
      final data = await _service.analyze({
        'frame': frame,
        'referenceFrame': null,
        'referenceCapture': true,
        'checkIdentity': false,
        'detectGadgets': true,
        'closeOnMultipleFaces': true,
        'attemptId': widget.attemptId,
      });
      final durationMs = started.elapsedMilliseconds;
      _addLog('reference', referenceSummaryText(data, durationMs));
      await _appendRemoteLog('reference', true, durationMs, data);
      return data;
    } finally {
      _set(() => _analyzing = false);
    }
  }

  void _emitWarningIfNeeded(Map<String, dynamic> data) {
    final payload = visualWarningPayload(data, _localPhoneCandidates);
    if (payload == null) return;
    if (!_gate.allowVisual(payload.type, _now)) return;
    widget.onWarning?.call(payload);
  }

  void _emitAudioWarningIfNeeded(Map<String, dynamic> data) {
    final payload = audioWarningPayload(data);
    if (payload == null) return;
    if (!_gate.allowAudio(payload.type, _now)) return;
    widget.onWarning?.call(payload);
  }

  void _logHeadDirection(Map<String, dynamic> data) {
    final direction = extractHeadDirection(data);
    if (direction == null) return;
    final now = _now;
    if (direction == _lastHeadDirection && now - _lastHeadLogAt < 7000) return;
    _lastHeadDirection = direction;
    _lastHeadLogAt = now;
    _addLog('head', 'Head position: ${formatHeadDirection(direction)}');
  }

  /// `captureFrame()` — also updates `captureSize` / `lastFrameData`.
  Future<String> _captureFrame() async {
    final frame = await _camera.capture();
    _lastFrameData = frame.stats;
    return frame.dataUrl;
  }

  void _drawOverlay(Map<String, dynamic> data) {
    final size = _lastFrameData;
    if (size == null) return;
    _set(() => _overlay = OverlaySnapshot(
          width: size.width,
          height: size.height,
          boxes: overlayBoxes(data, _localPhoneCandidates),
        ));
  }

  Future<void> _appendRemoteLog(
      String kind, bool ok, int durationMs, Map<String, dynamic>? data) async {
    if (_sessionId.isEmpty) return;
    try {
      await _service.appendLog(_sessionId, {
        'kind': kind,
        'ok': ok,
        'durationMs': durationMs,
        'data': data,
        'clientTime': _isoNow(),
        'metadata': {'localPhoneCandidates': _localPhoneCandidates},
      });
    } catch (_) {
      // Local logs are kept even when remote log upload is unavailable.
    }
  }

  Future<void> _finish([String reason = 'finished']) async {
    if (_finishing || _finished) return;
    _finishing = true;
    _finished = true;
    _stopAnalyzeLoop();
    _stopAudioMonitor();
    try {
      final r = await _camera.stop();
      if (r['recorderFailed'] == true) {
        final m = asString(r['recorderError']);
        _addLog('recording', m != null && m.isNotEmpty ? m : 'Recording stop failed');
      }
    } catch (_) {}
    _set(() {
      _hasStream = false;
      _cameraReady = false;
    });

    if (_sessionId.isNotEmpty) {
      try {
        await _service.finishSession(_sessionId, {
          'kind': 'finish',
          'ok': true,
          'message': reason,
          'clientTime': _isoNow(),
          'data': _latest,
          'metadata': {
            'localPhoneCandidates': _localPhoneCandidates,
            'latestAudioEvents': _latestAudioEvents,
          },
        });
      } catch (error) {
        _addLog('finish', _msg(error, 'Remote session finish failed'));
      }
    }
  }

  void _addLog(String kind, String message) {
    final log = PanelLog(
      id: _nextLogId++,
      time: _timeFormat.format(DateTime.now()),
      kind: kind,
      message: message,
    );
    _set(() => _logs = [log, ..._logs].take(30).toList());
    if (!_disposed) widget.onLog?.call(kind, message);
  }

  // ── template ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return ProctorPanelView(
      statusLabel: _statusLabel,
      statusTone: _statusTone,
      warningCount: widget.warningCount,
      maxWarnings: widget.maxWarnings,
      activityLabel: _analyzing
          ? 'Analyzing'
          : _referenceCaptured
              ? 'Watching'
              : 'Waiting',
      camera: ProctorCameraView(controller: _camera),
      overlay: CustomPaint(painter: ProctorOverlayPainter(_overlay)),
      cameraReady: _cameraReady,
      cameraMessage: _cameraMessage,
      referenceCaptured: _referenceCaptured,
      environmentConfirmed: _environmentConfirmed,
      onEnvironmentConfirmed: (v) => setState(() => _environmentConfirmed = v),
      captureDisabled: _captureDisabled,
      captureLabel: _analyzing ? 'Checking photo...' : 'Capture Photo & Start Exam',
      onCapture: _captureReferenceAndStart,
      leftConfirmed: widget.leftConfirmed,
      faces: valueText(_latest?['faceCount']),
      persons: valueText(_latest?['personCount']),
      gadgets: '$_totalGadgetCount',
      head: _headDirectionLabel,
      audio: _audioLevelLabel,
      recording: _recordingLabel,
      latestLogTime: _latestLogTime,
      topEvents: _topEvents,
      showPhoneLike: _localPhoneCandidates.isNotEmpty,
      logs: _logs,
    );
  }
}
