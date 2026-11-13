import 'package:flutter/material.dart';

/// Renders the small HTML subset found in ZSL question stems
/// (`<div v-html="question.text">` on the web) as rich text:
/// `b/strong, i/em, u, sup, sub, br, p, div, li, h1–h6, img` + entities.
/// Unknown tags are dropped and their text kept.
class MzHtmlText extends StatelessWidget {
  const MzHtmlText(this.html, {super.key, required this.style});

  final String html;
  final TextStyle style;

  @override
  Widget build(BuildContext context) =>
      Text.rich(TextSpan(style: style, children: parseHtmlSpans(html, style)));
}

final _token = RegExp(r'<!--[\s\S]*?-->|<[^>]+>|[^<]+');
final _tagName = RegExp(r'^<\s*(/?)\s*([a-zA-Z0-9]+)');
final _srcAttr = RegExp(r'''src\s*=\s*["']([^"']+)["']''', caseSensitive: false);
final _space = RegExp(r'\s+');
final _entity = RegExp(r'&(#x[0-9a-fA-F]+|#[0-9]+|[a-zA-Z]+[0-9]*);');

const _named = <String, String>{
  'nbsp': ' ',
  'amp': '&',
  'lt': '<',
  'gt': '>',
  'quot': '"',
  'apos': "'",
  'times': '×',
  'divide': '÷',
  'minus': '−',
  'plusmn': '±',
  'deg': '°',
  'pi': 'π',
  'le': '≤',
  'ge': '≥',
  'ne': '≠',
  'frac12': '½',
  'frac14': '¼',
  'frac34': '¾',
  'sup2': '²',
  'sup3': '³',
  'radic': '√',
  'infin': '∞',
  'theta': 'θ',
  'alpha': 'α',
  'beta': 'β',
  'rarr': '→',
  'larr': '←',
  'hellip': '…',
  'ndash': '–',
  'mdash': '—',
  'rsquo': '’',
  'lsquo': '‘',
  'rdquo': '”',
  'ldquo': '“',
};

String decodeHtmlEntities(String s) => s.replaceAllMapped(_entity, (m) {
      final e = m[1]!;
      if (e.startsWith('#x')) {
        final code = int.tryParse(e.substring(2), radix: 16);
        return code == null ? m[0]! : String.fromCharCode(code);
      }
      if (e.startsWith('#')) {
        final code = int.tryParse(e.substring(1));
        return code == null ? m[0]! : String.fromCharCode(code);
      }
      return _named[e] ?? m[0]!;
    });

List<InlineSpan> parseHtmlSpans(String html, TextStyle base) {
  final spans = <InlineSpan>[];
  var bold = 0, italic = 0, underline = 0, sup = 0, sub = 0, skip = 0;
  var lastText = '';

  void newline() {
    if (lastText.isNotEmpty && !lastText.endsWith('\n')) {
      spans.add(const TextSpan(text: '\n'));
      lastText = '\n';
    }
  }

  TextStyle current() => TextStyle(
        fontWeight: bold > 0 ? FontWeight.w700 : null,
        fontStyle: italic > 0 ? FontStyle.italic : null,
        decoration: underline > 0 ? TextDecoration.underline : null,
      );

  for (final m in _token.allMatches(html)) {
    final tok = m[0]!;
    if (tok.startsWith('<!--')) continue;
    if (tok.startsWith('<')) {
      final t = _tagName.firstMatch(tok);
      if (t == null) continue;
      final closing = t[1] == '/';
      final name = t[2]!.toLowerCase();
      final delta = closing ? -1 : 1;
      switch (name) {
        case 'b' || 'strong':
          bold = (bold + delta).clamp(0, 99);
        case 'i' || 'em':
          italic = (italic + delta).clamp(0, 99);
        case 'u':
          underline = (underline + delta).clamp(0, 99);
        case 'sup':
          sup = (sup + delta).clamp(0, 99);
        case 'sub':
          sub = (sub + delta).clamp(0, 99);
        case 'script' || 'style':
          skip = (skip + delta).clamp(0, 99);
        case 'br':
          spans.add(const TextSpan(text: '\n'));
          lastText = '\n';
        case 'p' || 'div' || 'h1' || 'h2' || 'h3' || 'h4' || 'h5' || 'h6' || 'ul' || 'ol' || 'tr':
          newline();
        case 'li':
          newline();
          if (!closing) {
            spans.add(const TextSpan(text: '• '));
            lastText = '• ';
          }
        case 'img':
          final src = _srcAttr.firstMatch(tok)?[1];
          if (src != null && src.isNotEmpty) {
            spans.add(WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: Image.network(
                  src,
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ));
            lastText = 'img';
          }
      }
      continue;
    }
    if (skip > 0) continue;
    var text = decodeHtmlEntities(tok.replaceAll(_space, ' '));
    if (lastText.isEmpty || lastText.endsWith('\n')) text = text.trimLeft();
    if (text.isEmpty) continue;
    if (sup > 0 || sub > 0) {
      final size = (base.fontSize ?? 14) * 0.75;
      spans.add(WidgetSpan(
        alignment: PlaceholderAlignment.middle,
        child: Transform.translate(
          offset: Offset(0, sup > 0 ? -size * 0.45 : size * 0.3),
          child: Text(text, style: base.merge(current()).copyWith(fontSize: size)),
        ),
      ));
    } else {
      spans.add(TextSpan(text: text, style: current()));
    }
    lastText = text;
  }

  // Drop trailing line breaks.
  while (spans.isNotEmpty && spans.last is TextSpan && (spans.last as TextSpan).text == '\n') {
    spans.removeLast();
  }
  return spans;
}
