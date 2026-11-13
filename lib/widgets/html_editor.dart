import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/files.dart';

/// Reads / replaces the content of an [HtmlEditor] from outside (the web did
/// this by re-keying `<Tiptap :key>` or writing its `v-model`).
class HtmlEditorController {
  InAppWebViewController? _web;
  String _html = '';

  /// Latest HTML reported by the editor (`''` when empty).
  String get html => _html;

  Future<void> setHtml(String html) async {
    _html = html;
    await _web?.evaluateJavascript(source: 'window.editorApi && editorApi.setHtml(${jsonEncode(html)})');
  }

  /// Asks the page for its current HTML (falls back to the last reported value).
  Future<String> getHtml() async {
    final r = await _web?.evaluateJavascript(source: 'editorApi.getHtml()');
    if (r is String) _html = r;
    return _html;
  }
}

/// Rich-text editor replacing `src/components/Tiptap.vue` — HTML in, HTML out.
///
/// It's a small editor page (`assets/editor/editor.html`) in a WebView with
/// the web's toolbar (same order, icons and 34px buttons): undo/redo,
/// paragraph/headings, font family & size, bold/italic/strike, lists, code
/// block, image upload (inserted as a data URL, like Tiptap) or by URL, text
/// and highlight colour, alignment, link and iframe embed — and the same
/// white 240px-min editing area and Insert/Cancel modals.
///
/// The frame is `.tiptap-shell`: `border #e6e9ef rounded-[10px] p-3
/// bg-(--primary-foreground) max-w-[960px] my-5 mx-auto`; it grows with the
/// content like the web component (pass [autoHeight] `false` for a fixed
/// [height]).
///
/// Empty content is reported as `''` (Tiptap gave `<p></p>`).
class HtmlEditor extends StatefulWidget {
  const HtmlEditor({
    super.key,
    this.initialHtml = '',
    this.onChanged,
    this.controller,
    this.height = 320,
    this.placeholder = '',
    this.enabled = true,
    this.autoHeight = true,
    this.margin = const EdgeInsets.symmetric(vertical: 20),
  });

  final String initialHtml;
  final ValueChanged<String>? onChanged;
  final HtmlEditorController? controller;

  /// Total height incl. toolbar. With [autoHeight] this is only the height
  /// used until the page has measured its content.
  final double height;

  /// Shown while empty (the web's Tiptap has none).
  final String placeholder;
  final bool enabled;

  /// Grow with the content (the web component has no fixed height).
  final bool autoHeight;

  /// `.tiptap-shell { margin: 20px auto }`.
  final EdgeInsetsGeometry margin;

  @override
  State<HtmlEditor> createState() => _HtmlEditorState();
}

class _HtmlEditorState extends State<HtmlEditor> {
  static Future<String>? _page;
  late final HtmlEditorController _controller = widget.controller ?? HtmlEditorController();
  InAppWebViewController? _web;
  bool? _dark;
  bool _ready = false;
  double? _contentHeight;

  static final _settings = InAppWebViewSettings(
    javaScriptEnabled: true,
    transparentBackground: false,
    supportZoom: false,
    useHybridComposition: true,
    disableContextMenu: false,
  );

  @override
  void initState() {
    super.initState();
    _controller._html = widget.initialHtml;
    _page ??= rootBundle.loadString('assets/editor/editor.html');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final dark = context.isDark;
    if (_dark != null && _dark != dark && _ready) {
      _web?.evaluateJavascript(source: 'editorApi.setDark($dark)');
    }
    _dark = dark;
  }

  @override
  void didUpdateWidget(covariant HtmlEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled && _ready) {
      _web?.evaluateJavascript(source: 'editorApi.setEditable(${widget.enabled})');
    }
  }

  Future<void> _init(InAppWebViewController c) async {
    // The content goes in through JS, not the page source: WebView2's
    // NavigateToString is limited to 2 MB and pasted images are data URLs.
    final opts = jsonEncode({
      'html': _controller._html,
      'dark': context.isDark,
      'placeholder': widget.placeholder,
      'editable': widget.enabled,
    });
    await c.evaluateJavascript(source: 'editorApi.init($opts)');
    _ready = true;
  }

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    // + the 1px border on each side.
    final height = widget.autoHeight && _contentHeight != null ? _contentHeight! + 2 : widget.height;
    final frame = Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        // var(--primary-foreground)
        color: dark ? AppColors.darkPrimaryForeground : AppColors.primaryForeground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE6E9EF)),
      ),
      child: FutureBuilder<String>(
        future: _page,
        builder: (context, snap) {
          if (!snap.hasData) return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          return InAppWebView(
            initialSettings: _settings,
            initialData: InAppWebViewInitialData(data: snap.data!),
            gestureRecognizers: {
              Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
            },
            onWebViewCreated: (c) {
              _web = c;
              _controller._web = c;
              c.addJavaScriptHandler(
                handlerName: 'change',
                callback: (args) {
                  final html = args.isNotEmpty && args.first is String ? args.first as String : '';
                  _controller._html = html;
                  widget.onChanged?.call(html);
                  return null;
                },
              );
              c.addJavaScriptHandler(
                handlerName: 'height',
                callback: (args) {
                  final h = args.isNotEmpty && args.first is num ? (args.first as num).toDouble() : null;
                  if (h != null && h > 0 && mounted && h != _contentHeight) setState(() => _contentHeight = h);
                  return null;
                },
              );
              c.addJavaScriptHandler(
                handlerName: 'pickImage',
                callback: (_) async {
                  final file = await pickImageFile();
                  if (file == null) return null;
                  return toDataUrl(file);
                },
              );
            },
            onLoadStop: (c, _) => _init(c),
          );
        },
      ),
    );
    // `max-width: 960px; margin: 20px auto`
    return Padding(
      padding: widget.margin,
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 1,
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 960), child: frame),
      ),
    );
  }

  @override
  void dispose() {
    if (_controller._web == _web) _controller._web = null;
    super.dispose();
  }
}
