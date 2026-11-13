import 'dart:collection';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../../widgets/web_content_view.dart' show normalizeEmbedUrl;

/// An `<iframe :src>` whose page can talk back to the app, like the web
/// iframes of `QuizExam.vue` (QuizSys scanner) and `studentactivitypage.vue`
/// (activity player):
///
/// * [onMessage] — `window.addEventListener('message', …)` on the web parent.
///   A top-level WebView has no parent, so `window.parent.postMessage(x)` in
///   the page lands on its own window; a document-start script forwards every
///   `message` event's `data` here (values JSON can't carry are dropped).
/// * [onXpChannel] — when set, `window.xpChannel = { postMessage }`,
///   `window.ActivityHandler.validate` and `window.Orchestrator.submit` are
///   installed after each load (the web injected them in `@load` of
///   same-origin iframes); `xpChannel.postMessage(m)` calls [onXpChannel].
///
/// Camera / microphone requests are granted (`allow="camera; microphone"`).
class BridgedWebView extends StatefulWidget {
  const BridgedWebView({
    super.key,
    required this.url,
    this.onMessage,
    this.onXpChannel,
    this.onLoaded,
  });

  final String url;
  final ValueChanged<dynamic>? onMessage;
  final ValueChanged<dynamic>? onXpChannel;
  final VoidCallback? onLoaded;

  @override
  State<BridgedWebView> createState() => _BridgedWebViewState();
}

const _messageHandler = 'elabMessage';
const _xpHandler = 'elabXpChannel';

/// Forwards `message` events to Flutter (idempotent).
const _bridgeJs = '''
(function(){
  if (window.__elabMessageBridge) return;
  window.__elabMessageBridge = true;
  window.addEventListener('message', function(e){
    try {
      var d = e.data;
      try { JSON.stringify(d); } catch (_) { return; }
      window.flutter_inappwebview.callHandler('$_messageHandler', d === undefined ? null : d);
    } catch (_) {}
  });
})();
''';

/// `iframe.contentWindow.xpChannel / ActivityHandler / Orchestrator = …`.
const _activityHandlersJs = '''
(function(){
  window.xpChannel = {
    postMessage: function(message){
      try { window.flutter_inappwebview.callHandler('$_xpHandler', message === undefined ? null : message); } catch (_) {}
    }
  };
  window.ActivityHandler = {
    validate: function(response){
      console.log('[Iframe JS Channel] (ActivityHandler.validate called from iframe):', response);
    }
  };
  window.Orchestrator = {
    submit: function(data){
      console.log('[Iframe JS Channel] (Orchestrator.submit called from iframe):', data);
    }
  };
})();
''';

class _BridgedWebViewState extends State<BridgedWebView> {
  InAppWebViewController? _controller;
  double _progress = 0;
  String? _error;

  static final _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    javaScriptCanOpenWindowsAutomatically: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllowFullscreen: true,
    supportZoom: false,
    useHybridComposition: true,
  );

  @override
  void didUpdateWidget(covariant BridgedWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url) _load();
  }

  void _load() {
    final c = _controller;
    if (c == null) return;
    setState(() => _error = null);
    c.loadUrl(urlRequest: URLRequest(url: WebUri(normalizeEmbedUrl(widget.url))));
  }

  void _attach(InAppWebViewController c) {
    _controller = c;
    c.addJavaScriptHandler(
      handlerName: _messageHandler,
      callback: (args) {
        widget.onMessage?.call(args.isEmpty ? null : args.first);
        return null;
      },
    );
    c.addJavaScriptHandler(
      handlerName: _xpHandler,
      callback: (args) {
        widget.onXpChannel?.call(args.isEmpty ? null : args.first);
        return null;
      },
    );
  }

  Future<void> _onLoadStop(InAppWebViewController c) async {
    try {
      // Platforms without document-start user scripts still get the bridge.
      await c.evaluateJavascript(source: _bridgeJs);
      if (widget.onXpChannel != null) {
        await c.evaluateJavascript(source: _activityHandlersJs);
      }
    } catch (e) {
      debugPrint('[Iframe JS Channel] Unable to inject handlers: $e');
    }
    widget.onLoaded?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        InAppWebView(
          initialSettings: _settings,
          initialUrlRequest: URLRequest(url: WebUri(normalizeEmbedUrl(widget.url))),
          initialUserScripts: UnmodifiableListView([
            UserScript(source: _bridgeJs, injectionTime: UserScriptInjectionTime.AT_DOCUMENT_START),
          ]),
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
          },
          onWebViewCreated: _attach,
          onProgressChanged: (_, p) {
            if (mounted) setState(() => _progress = p / 100);
          },
          onLoadStop: (c, _) => _onLoadStop(c),
          onReceivedError: (_, request, error) {
            if ((request.isForMainFrame ?? true) && mounted) {
              setState(() => _error = error.description);
            }
          },
          onPermissionRequest: (_, request) async => PermissionResponse(
              resources: request.resources, action: PermissionResponseAction.GRANT),
        ),
        if (_progress < 1 && _error == null)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(value: _progress == 0 ? null : _progress, minHeight: 2),
          ),
        if (_error != null)
          Positioned.fill(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.wifi_off_rounded, size: 40),
                    const SizedBox(height: 8),
                    Text('Could not load content', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(_error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// `typeof data === 'string' ? JSON.parse(data) : data` (null when the
/// string isn't JSON) — QuizExam's `parseScannerMessage`.
dynamic parseBridgeMessage(dynamic data) {
  if (data is String) {
    try {
      return jsonDecode(data);
    } catch (_) {
      return null;
    }
  }
  return data;
}
