import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../core/utils/external_link.dart';

/// Replaces every `<iframe>` in the web app (activities, simulations,
/// signed-URL content, YouTube, PDF, raw HTML).
///
/// Backed by flutter_inappwebview: WKWebView on iOS/macOS, Android WebView,
/// and WebView2 on Windows.
class WebContentView extends StatefulWidget {
  const WebContentView({
    super.key,
    this.url,
    this.html,
    this.onLoaded,
    this.showOpenExternally = false,
  }) : assert(url != null || html != null, 'Provide url or html');

  final String? url;

  /// Raw HTML (e.g. Tiptap `html_content`), shown like the web's
  /// `IsolatedHtmlContent.vue` (`<iframe srcdoc>` on a white background with
  /// the browser's default styles; the web frame is 500px tall — the caller
  /// sizes this widget).
  final String? html;
  final VoidCallback? onLoaded;

  /// Shows a small "open in browser" button (useful on desktop).
  final bool showOpenExternally;

  @override
  State<WebContentView> createState() => _WebContentViewState();
}

class _WebContentViewState extends State<WebContentView> {
  String? _error;
  InAppWebViewController? _controller;

  static final _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    iframeAllowFullscreen: true,
    transparentBackground: true,
    supportZoom: true,
    useHybridComposition: true,
  );

  @override
  void didUpdateWidget(covariant WebContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.url != widget.url || oldWidget.html != widget.html) {
      _load();
    }
  }

  void _load() {
    final c = _controller;
    if (c == null) return;
    setState(() => _error = null);
    if (widget.html != null) {
      c.loadData(data: wrapHtml(widget.html!));
    } else if (widget.url != null) {
      c.loadUrl(urlRequest: URLRequest(url: WebUri(normalizeEmbedUrl(widget.url!))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // `.html-content-frame { background: white }`
        if (widget.html != null) const Positioned.fill(child: ColoredBox(color: Colors.white)),
        InAppWebView(
          initialSettings: _settings,
          initialUrlRequest: widget.url != null && widget.html == null
              ? URLRequest(url: WebUri(normalizeEmbedUrl(widget.url!)))
              : null,
          initialData: widget.html != null
              ? InAppWebViewInitialData(data: wrapHtml(widget.html!))
              : null,
          onWebViewCreated: (c) => _controller = c,
          onLoadStop: (_, _) => widget.onLoaded?.call(),
          onReceivedError: (_, request, error) {
            if (request.isForMainFrame ?? true) {
              setState(() => _error = error.description);
            }
          },
          onPermissionRequest: (_, request) async => PermissionResponse(
              resources: request.resources, action: PermissionResponseAction.GRANT),
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
        if (widget.showOpenExternally && widget.url != null)
          Positioned(
            right: 8,
            bottom: 8,
            child: FloatingActionButton.small(
              tooltip: 'Open in browser',
              onPressed: () => openExternal(widget.url),
              child: const Icon(Icons.open_in_new_rounded),
            ),
          ),
      ],
    );
  }
}

/// Turns YouTube watch/short links into embeddable URLs (the web app built
/// `https://www.youtube.com/embed/<id>` iframes the same way).
String normalizeEmbedUrl(String url) {
  final u = url.trim();
  final yt = RegExp(r'(?:youtube\.com/(?:watch\?v=|shorts/)|youtu\.be/)([A-Za-z0-9_-]{6,})')
      .firstMatch(u);
  if (yt != null) return 'https://www.youtube.com/embed/${yt.group(1)}';
  return u;
}

/// Wraps an HTML fragment like an `<iframe srcdoc>` does: the browser's
/// default styles (8px body margin, black serif text), no extra CSS. A full
/// document is passed through unchanged; a fragment only gets a viewport tag
/// so phones don't lay it out at 980px (an iframe uses its own width).
String wrapHtml(String fragment) {
  if (RegExp(r'<html[\s>]|<!doctype', caseSensitive: false).hasMatch(fragment)) return fragment;
  return '<html><head><meta charset="utf-8">'
      '<meta name="viewport" content="width=device-width, initial-scale=1"></head>'
      '<body>$fragment</body></html>';
}
