import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/utils/json.dart';
import 'proctor_camera_html.dart';
import 'proctor_logic.dart';

/// An error reported by the camera page: `message` is `error.message` when
/// the JS value was an `Error`, otherwise null (the caller picks the web's
/// fallback text).
class CameraJsError implements Exception {
  const CameraJsError(this.message);
  final String? message;
  @override
  String toString() => message ?? 'CameraJsError';
}

/// One `captureFrame()` result.
class CapturedFrame {
  const CapturedFrame({required this.dataUrl, required this.stats});

  /// `canvas.toDataURL('image/jpeg', 0.78)`
  final String dataUrl;

  /// `captureSize` + the sampled pixels of `lastFrameData`.
  final FrameStats stats;
}

/// Result of starting the camera (`startCamera()`).
class CameraStartResult {
  const CameraStartResult({
    required this.ok,
    required this.finished,
    required this.micFailed,
    this.micError,
    this.error,
    this.audio,
  });

  final bool ok;
  final bool finished;

  /// The first `getUserMedia({ video, audio })` failed (→ video only).
  final bool micFailed;
  final String? micError;
  final String? error;

  /// `startAudioMonitor()` outcome: `ready` / `unavailable` / `unsupported`.
  final String? audio;
}

/// One Web-Audio analyser snapshot (`analyzeAudioWindow`).
class AudioSample {
  const AudioSample({
    required this.available,
    required this.resumeFailed,
    required this.running,
    this.sampleRate = 0,
    this.fftSize = 0,
    this.timeData,
    this.frequencyData,
  });

  /// An analyser exists (`this.audioAnalyser && this.audioContext`).
  final bool available;

  /// `audioContext.resume()` failed → `Mic paused`.
  final bool resumeFailed;

  /// `audioContext.state === 'running'`
  final bool running;
  final double sampleRate;
  final int fftSize;
  final Uint8List? timeData;
  final Uint8List? frequencyData;
}

/// Dart side of the camera page ([proctorCameraHtml]): start/stop/capture are
/// driven with `evaluateJavascript`, results come back through JS handlers.
class ProctorCameraController {
  InAppWebViewController? _web;
  Completer<void> _ready = Completer<void>();
  final _pending = <int, Completer<Map<String, dynamic>>>{};
  final _frames = <int, Completer<Map<String, dynamic>>>{};
  int _seq = 0;
  bool _disposed = false;

  /// Recorder chunk (`ondataavailable`) — bytes and MIME type.
  void Function(Uint8List bytes, String type)? onChunk;

  /// `window` `online` / `offline`.
  void Function(bool online)? onNetworkChanged;

  /// The page reported whether `getUserMedia` is reachable (secure context).
  bool? mediaSupported;

  bool get isReady => _ready.isCompleted;

  void _attach(InAppWebViewController web) {
    _web = web;
    web.addJavaScriptHandler(
      handlerName: 'ready',
      callback: (args) {
        final info = asMap(args.isNotEmpty ? args.first : null);
        mediaSupported = info?['media'] == true;
        if (!_ready.isCompleted) _ready.complete();
        return null;
      },
    );
    web.addJavaScriptHandler(
      handlerName: 'result',
      callback: (args) {
        final r = asMap(args.isNotEmpty ? args.first : null);
        final id = asInt(r?['id']);
        final c = id == null ? null : _pending.remove(id);
        if (c == null || c.isCompleted) return null;
        if (r?['ok'] == true) {
          c.complete(asMap(r?['value']) ?? <String, dynamic>{});
        } else {
          c.completeError(CameraJsError(asString(r?['error'])));
        }
        return null;
      },
    );
    web.addJavaScriptHandler(
      handlerName: 'frame',
      callback: (args) {
        final r = asMap(args.isNotEmpty ? args.first : null);
        final id = asInt(r?['id']);
        final c = id == null ? null : _frames.remove(id);
        if (c != null && !c.isCompleted) c.complete(r ?? <String, dynamic>{});
        return null;
      },
    );
    web.addJavaScriptHandler(
      handlerName: 'chunk',
      callback: (args) {
        final r = asMap(args.isNotEmpty ? args.first : null);
        final data = asString(r?['data']) ?? '';
        if (data.isEmpty) return null;
        try {
          onChunk?.call(base64Decode(data), asString(r?['type']) ?? '');
        } catch (_) {}
        return null;
      },
    );
    web.addJavaScriptHandler(
      handlerName: 'network',
      callback: (args) {
        final r = asMap(args.isNotEmpty ? args.first : null);
        onNetworkChanged?.call(r?['online'] != false);
        return null;
      },
    );
  }

  void _detach() {
    _disposed = true;
    _web = null;
    for (final c in [..._pending.values, ..._frames.values]) {
      if (!c.isCompleted) c.completeError(const CameraJsError('Camera preview is not ready'));
    }
    _pending.clear();
    _frames.clear();
    if (_ready.isCompleted) _ready = Completer<void>();
  }

  Future<InAppWebViewController> _page({Duration wait = const Duration(seconds: 20)}) async {
    if (_disposed) throw const ProctorError('Camera preview is not ready');
    try {
      await _ready.future.timeout(wait);
    } on TimeoutException {
      throw const ProctorError('Camera preview is not ready');
    }
    final web = _web;
    if (web == null || _disposed) throw const ProctorError('Camera preview is not ready');
    return web;
  }

  Future<Map<String, dynamic>> _run(String method, {Duration? timeout}) async {
    final web = await _page();
    final id = ++_seq;
    final c = Completer<Map<String, dynamic>>();
    _pending[id] = c;
    try {
      await web.evaluateJavascript(
          source: 'window.proctor && window.proctor.run(${jsonEncode(method)}, $id, null);');
      return timeout == null ? await c.future : await c.future.timeout(timeout);
    } finally {
      _pending.remove(id);
    }
  }

  /// Android / iOS: OS camera + microphone permission before the WebView asks
  /// (Windows: WebView2 grants via `onPermissionRequest`; macOS: the system
  /// prompt appears when the WebView opens the camera). Returns false when the
  /// camera permission was refused.
  static Future<bool> requestPermissions() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) return true;
    try {
      final camera = await Permission.camera.request();
      await Permission.microphone.request();
      return camera.isGranted || camera.isLimited;
    } catch (_) {
      return true;
    }
  }

  /// `getUserMedia` (video + audio, falling back to video only), preview,
  /// analyser.
  Future<CameraStartResult> start() async {
    final r = await _run('start');
    return CameraStartResult(
      ok: r['ok'] == true,
      finished: r['finished'] == true,
      micFailed: r['micFailed'] == true,
      micError: asString(r['micError']),
      error: asString(r['error']),
      audio: asString(r['audio']),
    );
  }

  /// `captureFrame()`
  Future<CapturedFrame> capture() async {
    final web = await _page(wait: const Duration(seconds: 5));
    final id = ++_seq;
    final c = Completer<Map<String, dynamic>>();
    _frames[id] = c;
    Map<String, dynamic> r;
    try {
      await web.evaluateJavascript(source: 'window.proctor && window.proctor.capture($id);');
      r = await c.future.timeout(const Duration(seconds: 8));
    } on TimeoutException {
      throw const ProctorError('Camera frame is not ready');
    } finally {
      _frames.remove(id);
    }
    if (r['ok'] != true) throw CameraJsError(asString(r['error']));
    final sums = [for (final v in asList(r['sums'])) asInt(v) ?? 0];
    return CapturedFrame(
      dataUrl: asString(r['dataUrl']) ?? '',
      stats: FrameStats(
        width: asInt(r['width']) ?? 0,
        height: asInt(r['height']) ?? 0,
        sums: sums,
      ),
    );
  }

  /// `resumeAudioMonitor()` — true when `resume()` failed (→ `Mic paused`).
  Future<bool> resumeAudio() async {
    final r = await _run('resumeAudio', timeout: const Duration(seconds: 4));
    return r['failed'] == true;
  }

  /// Analyser snapshot for `analyzeAudioWindow()`.
  Future<AudioSample> sampleAudio() async {
    final r = await _run('sampleAudio', timeout: const Duration(seconds: 4));
    Uint8List? bytes(Object? v) {
      final s = asString(v);
      return s == null ? null : base64Decode(s);
    }

    return AudioSample(
      available: r['available'] == true,
      resumeFailed: r['resumeFailed'] == true,
      running: r['running'] == true,
      sampleRate: asDouble(r['sampleRate']) ?? 0,
      fftSize: asInt(r['fftSize']) ?? 0,
      timeData: bytes(r['time']),
      frequencyData: bytes(r['freq']),
    );
  }

  /// `stream.getAudioTracks()` → `{ hasStream, count, tracks }`.
  Future<Map<String, dynamic>> audioTracks() => _run('tracks', timeout: const Duration(seconds: 4));

  /// `startRecording()` → `{ created, state, error, failed, skipped }`.
  Future<Map<String, dynamic>> startRecording() =>
      _run('startRecording', timeout: const Duration(seconds: 5));

  /// Stops analyser, recorder and tracks → `{ recorderFailed, recorderError }`.
  Future<Map<String, dynamic>> stop() async {
    if (!isReady || _web == null) return const {};
    return _run('stop', timeout: const Duration(seconds: 3));
  }
}

/// The `<video>` preview: an [InAppWebView] showing [proctorCameraHtml].
///
/// The page must be a secure context for `getUserMedia`:
/// * Android / iOS / macOS load it as `initialData` with an
///   `https://localhost/` base URL.
/// * Windows (WebView2's `NavigateToString` gives an `about:blank` origin)
///   navigates to the same `https://localhost/…` URL and serves the page from
///   `shouldInterceptRequest`, so nothing touches the network.
class ProctorCameraView extends StatefulWidget {
  const ProctorCameraView({super.key, required this.controller});

  final ProctorCameraController controller;

  @override
  State<ProctorCameraView> createState() => _ProctorCameraViewState();
}

class _ProctorCameraViewState extends State<ProctorCameraView> {
  static const _pageUrl = 'https://localhost/proctor-camera.html';

  static bool get _isWindows => !kIsWeb && Platform.isWindows;

  static final _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    transparentBackground: false,
    supportZoom: false,
    disableContextMenu: true,
    disableHorizontalScroll: true,
    disableVerticalScroll: true,
    useHybridComposition: true,
    useShouldInterceptRequest: !kIsWeb && Platform.isWindows,
    isInspectable: false,
  );

  @override
  void dispose() {
    widget.controller._detach();
    super.dispose();
  }

  Future<WebResourceResponse?> _intercept(
      InAppWebViewController _, WebResourceRequest request) async {
    final url = request.url.toString();
    if (url.startsWith(_pageUrl)) {
      return WebResourceResponse(
        contentType: 'text/html',
        contentEncoding: 'utf-8',
        statusCode: 200,
        reasonPhrase: 'OK',
        data: Uint8List.fromList(utf8.encode(proctorCameraHtml)),
      );
    }
    if (request.url.host == 'localhost') {
      return WebResourceResponse(
        contentType: 'text/plain',
        statusCode: 404,
        reasonPhrase: 'Not Found',
        data: Uint8List(0),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: InAppWebView(
        initialSettings: _settings,
        initialUrlRequest: _isWindows ? URLRequest(url: WebUri(_pageUrl)) : null,
        initialData: _isWindows
            ? null
            : InAppWebViewInitialData(data: proctorCameraHtml, baseUrl: WebUri(_pageUrl)),
        shouldInterceptRequest: _isWindows ? _intercept : null,
        onWebViewCreated: widget.controller._attach,
        onPermissionRequest: (_, request) async => PermissionResponse(
            resources: request.resources, action: PermissionResponseAction.GRANT),
      ),
    );
  }
}
