import 'dart:convert';
import 'dart:io' show zlib;
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/utils/json.dart';
import '../../data/services/js_compat.dart';
import 'class_list_logic.dart';

// QuizSys QR cards: the web drew each card on a 1240×1754 <canvas> (the QR
// SVG through an <img>), encoded it as JPEG and wrote a tiny PDF by hand.
// Here the card is painted with dart:ui (the SVG through [MiniSvg]) and the
// raw RGB pixels go into the same PDF structure, Flate-compressed (Flutter
// has no JPEG encoder).

// ── mini SVG ─────────────────────────────────────────────────────────────────

/// One filled / stroked shape of a [MiniSvg].
class SvgShape {
  SvgShape(this.path, {this.fill, this.stroke, this.strokeWidth = 1});
  final Path path;
  final Color? fill;
  final Color? stroke;
  final double strokeWidth;
}

/// A small SVG renderer for server-generated QR / marker images: `rect`,
/// `circle`, `ellipse`, `line`, `polyline`, `polygon` and `path` (all
/// commands, arcs included), nested `g` with `transform`, presentation
/// attributes, `style="…"` and simple `<style>` class / tag rules.
class MiniSvg {
  MiniSvg(this.viewBox, this.shapes);

  final Rect viewBox;
  final List<SvgShape> shapes;

  static final _tagRe = RegExp(r'<\s*(/?)\s*([a-zA-Z][\w:.-]*)((?:[^>"\x27]|"[^"]*"|\x27[^\x27]*\x27)*?)(/?)\s*>');
  static final _attrRe = RegExp(r'([\w:.-]+)\s*=\s*(?:"([^"]*)"|\x27([^\x27]*)\x27)');
  static final _styleBlockRe = RegExp(r'<style[^>]*>([\s\S]*?)</style>', caseSensitive: false);
  static final _cssRuleRe = RegExp(r'([^{}]+)\{([^}]*)\}');

  /// Throws [FormatException] when [svg] has no `<svg>` root.
  static MiniSvg parse(String svg) {
    final source = svg.replaceAll(RegExp(r'<!--[\s\S]*?-->'), '');
    final css = <String, Map<String, String>>{};
    for (final block in _styleBlockRe.allMatches(source)) {
      final text = (block.group(1) ?? '').replaceAll(RegExp(r'/\*[\s\S]*?\*/'), '').replaceAll('<![CDATA[', '').replaceAll(']]>', '');
      for (final rule in _cssRuleRe.allMatches(text)) {
        final decl = parseStyleDeclarations(rule.group(2) ?? '');
        for (final sel in (rule.group(1) ?? '').split(',')) {
          final key = sel.trim();
          if (key.isEmpty) continue;
          css[key] = {...?css[key], ...decl};
        }
      }
    }

    Rect? viewBox;
    double? width;
    double? height;
    var sawRoot = false;
    final shapes = <SvgShape>[];
    final stack = <_Frame>[_Frame.root()];
    var skipDepth = 0;
    const containers = {'g', 'a', 'switch'};
    const skipped = {'defs', 'clippath', 'mask', 'symbol', 'pattern', 'lineargradient', 'radialgradient', 'marker', 'title', 'desc', 'metadata', 'style', 'text'};

    for (final m in _tagRe.allMatches(source)) {
      final closing = m.group(1) == '/';
      final name = (m.group(2) ?? '').toLowerCase().split(':').last;
      final selfClosing = m.group(4) == '/' || (m.group(3) ?? '').trimRight().endsWith('/');
      if (name.startsWith('?') || name.startsWith('!')) continue;

      if (closing) {
        if (skipDepth > 0) {
          if (skipped.contains(name)) skipDepth--;
          continue;
        }
        if ((containers.contains(name) || name == 'svg') && stack.length > 1) stack.removeLast();
        continue;
      }
      if (skipDepth > 0) {
        if (skipped.contains(name) && !selfClosing) skipDepth++;
        continue;
      }
      if (skipped.contains(name)) {
        if (!selfClosing) skipDepth++;
        continue;
      }

      final attrs = <String, String>{
        for (final a in _attrRe.allMatches(m.group(3) ?? '')) a.group(1)!.toLowerCase(): a.group(2) ?? a.group(3) ?? '',
      };
      final frame = stack.last.child(attrs, css, name);

      if (name == 'svg') {
        if (!sawRoot) {
          sawRoot = true;
          viewBox = _parseViewBox(attrs['viewbox']);
          width = _length(attrs['width']);
          height = _length(attrs['height']);
        }
        if (!selfClosing) stack.add(frame);
        continue;
      }
      if (containers.contains(name)) {
        if (!selfClosing) stack.add(frame);
        continue;
      }
      final path = _shapePath(name, attrs);
      if (path == null) continue;
      final transformed = frame.matrix == null ? path : path.transform(frame.matrix!);
      final fill = frame.fill;
      final stroke = frame.stroke;
      if (fill == null && stroke == null) continue;
      transformed.fillType = frame.evenOdd ? PathFillType.evenOdd : PathFillType.nonZero;
      shapes.add(SvgShape(transformed, fill: fill, stroke: stroke, strokeWidth: frame.strokeWidth));
    }
    if (!sawRoot) throw const FormatException('Unable to render QR SVG.');

    var vb = viewBox;
    if (vb == null && width != null && height != null && width > 0 && height > 0) {
      vb = Rect.fromLTWH(0, 0, width, height);
    }
    if (vb == null) {
      Rect? bounds;
      for (final s in shapes) {
        final b = s.path.getBounds();
        bounds = bounds == null ? b : bounds.expandToInclude(b);
      }
      vb = bounds ?? const Rect.fromLTWH(0, 0, 1, 1);
    }
    return MiniSvg(vb, shapes);
  }

  /// Paints the image scaled into [dst] (`preserveAspectRatio="xMidYMid meet"`).
  void paint(Canvas canvas, Rect dst) {
    if (viewBox.width <= 0 || viewBox.height <= 0) return;
    final s = math.min(dst.width / viewBox.width, dst.height / viewBox.height);
    canvas.save();
    canvas.clipRect(dst);
    canvas.translate(dst.left + (dst.width - viewBox.width * s) / 2, dst.top + (dst.height - viewBox.height * s) / 2);
    canvas.scale(s);
    canvas.translate(-viewBox.left, -viewBox.top);
    for (final shape in shapes) {
      if (shape.fill != null) {
        canvas.drawPath(shape.path, Paint()..color = shape.fill!..isAntiAlias = false);
      }
      if (shape.stroke != null && shape.strokeWidth > 0) {
        canvas.drawPath(
          shape.path,
          Paint()
            ..color = shape.stroke!
            ..style = PaintingStyle.stroke
            ..strokeWidth = shape.strokeWidth,
        );
      }
    }
    canvas.restore();
  }

  static Rect? _parseViewBox(String? v) {
    if (v == null) return null;
    final n = parseSvgNumbers(v);
    if (n.length < 4 || n[2] <= 0 || n[3] <= 0) return null;
    return Rect.fromLTWH(n[0], n[1], n[2], n[3]);
  }

  static double? _length(String? v) {
    if (v == null || v.contains('%')) return null;
    final n = parseSvgNumbers(v);
    return n.isEmpty ? null : n.first;
  }

  static double _num(Map<String, String> a, String key) {
    final n = parseSvgNumbers(a[key] ?? '');
    return n.isEmpty ? 0 : n.first;
  }

  static Path? _shapePath(String name, Map<String, String> a) {
    switch (name) {
      case 'rect':
        final w = _num(a, 'width');
        final h = _num(a, 'height');
        if (w <= 0 || h <= 0) return null;
        final r = Rect.fromLTWH(_num(a, 'x'), _num(a, 'y'), w, h);
        final rx = a.containsKey('rx') ? _num(a, 'rx') : _num(a, 'ry');
        final ry = a.containsKey('ry') ? _num(a, 'ry') : rx;
        return Path()..addRRect(RRect.fromRectXY(r, rx, ry));
      case 'circle':
        final r = _num(a, 'r');
        if (r <= 0) return null;
        return Path()..addOval(Rect.fromCircle(center: Offset(_num(a, 'cx'), _num(a, 'cy')), radius: r));
      case 'ellipse':
        final rx = _num(a, 'rx');
        final ry = _num(a, 'ry');
        if (rx <= 0 || ry <= 0) return null;
        return Path()
          ..addOval(Rect.fromCenter(center: Offset(_num(a, 'cx'), _num(a, 'cy')), width: rx * 2, height: ry * 2));
      case 'line':
        return Path()
          ..moveTo(_num(a, 'x1'), _num(a, 'y1'))
          ..lineTo(_num(a, 'x2'), _num(a, 'y2'));
      case 'polyline':
      case 'polygon':
        final n = parseSvgNumbers(a['points'] ?? '');
        if (n.length < 4) return null;
        final p = Path()..moveTo(n[0], n[1]);
        for (var i = 2; i + 1 < n.length; i += 2) {
          p.lineTo(n[i], n[i + 1]);
        }
        if (name == 'polygon') p.close();
        return p;
      case 'path':
        final d = a['d'];
        if (d == null || d.trim().isEmpty) return null;
        return parseSvgPathData(d);
    }
    return null;
  }
}

/// Inherited presentation state of an element.
class _Frame {
  _Frame(this.matrix, this.fillColor, this.strokeColor, this.strokeWidth, this.evenOdd, this.opacity, this.fillOpacity,
      this.strokeOpacity);
  _Frame.root() : this(null, const Color(0xFF000000), null, 1, false, 1, 1, 1);

  final Float64List? matrix;
  final Color? fillColor;
  final Color? strokeColor;
  final double strokeWidth;
  final bool evenOdd;

  /// Product of the ancestors' `opacity` (approximates group compositing).
  final double opacity;
  final double fillOpacity;
  final double strokeOpacity;

  Color? get fill => fillColor?.withValues(alpha: fillColor!.a * fillOpacity * opacity);
  Color? get stroke => strokeColor?.withValues(alpha: strokeColor!.a * strokeOpacity * opacity);

  _Frame child(Map<String, String> attrs, Map<String, Map<String, String>> css, String tag) {
    // Presentation attributes < CSS rules < style="".
    final props = <String, String>{
      for (final k in const ['fill', 'stroke', 'stroke-width', 'fill-rule', 'opacity', 'fill-opacity', 'stroke-opacity'])
        if (attrs[k] != null) k: attrs[k]!,
      ...?css['*'],
      ...?css[tag],
      for (final cls in (attrs['class'] ?? '').split(RegExp(r'\s+')))
        if (cls.isNotEmpty) ...?css['.$cls'],
      if (attrs['id'] != null) ...?css['#${attrs['id']}'],
      ...parseStyleDeclarations(attrs['style'] ?? ''),
    };

    var m = matrix;
    final t = attrs['transform'];
    if (t != null && t.trim().isNotEmpty) {
      final local = parseSvgTransform(t);
      m = m == null ? local : _multiply(m, local);
    }
    final swNums = parseSvgNumbers(props['stroke-width'] ?? '');
    final sw = swNums.isEmpty ? strokeWidth : swNums.first;
    return _Frame(
      m,
      props.containsKey('fill') ? parseSvgColor(props['fill']!, fallback: fillColor) : fillColor,
      props.containsKey('stroke') ? parseSvgColor(props['stroke']!, fallback: strokeColor) : strokeColor,
      sw,
      props['fill-rule'] != null ? props['fill-rule']!.trim() == 'evenodd' : evenOdd,
      opacity * (_opacity(props['opacity']) ?? 1),
      _opacity(props['fill-opacity']) ?? fillOpacity,
      _opacity(props['stroke-opacity']) ?? strokeOpacity,
    );
  }

  static double? _opacity(String? v) {
    if (v == null) return null;
    final t = v.trim();
    if (t.endsWith('%')) return (double.tryParse(t.substring(0, t.length - 1)) ?? 100) / 100;
    return double.tryParse(t);
  }

  static Float64List _multiply(Float64List a, Float64List b) {
    final r = Matrix4.fromFloat64List(a)..multiply(Matrix4.fromFloat64List(b));
    return r.storage;
  }
}

/// `fill:#000; stroke : none` → `{fill: '#000', stroke: 'none'}`.
Map<String, String> parseStyleDeclarations(String style) {
  final out = <String, String>{};
  for (final part in style.split(';')) {
    final i = part.indexOf(':');
    if (i <= 0) continue;
    final k = part.substring(0, i).trim().toLowerCase();
    final v = part.substring(i + 1).replaceAll('!important', '').trim();
    if (k.isNotEmpty && v.isNotEmpty) out[k] = v;
  }
  return out;
}

final _numberRe = RegExp(r'[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?');

/// Every number in [s] (`"1.5.5-2e1"` → `[1.5, .5, -20]`).
List<double> parseSvgNumbers(String s) => [for (final m in _numberRe.allMatches(s)) double.parse(m.group(0)!)];

const _namedColors = {
  'black': 0xFF000000,
  'white': 0xFFFFFFFF,
  'red': 0xFFFF0000,
  'green': 0xFF008000,
  'lime': 0xFF00FF00,
  'blue': 0xFF0000FF,
  'yellow': 0xFFFFFF00,
  'gray': 0xFF808080,
  'grey': 0xFF808080,
  'silver': 0xFFC0C0C0,
  'navy': 0xFF000080,
  'orange': 0xFFFFA500,
};

/// SVG paint → colour; `none` / `transparent` → null. Unknown values (url(),
/// unsupported names) fall back to [fallback] … or black like `currentColor`.
Color? parseSvgColor(String value, {Color? fallback}) {
  final v = value.trim().toLowerCase();
  if (v == 'none' || v == 'transparent') return null;
  if (v == 'currentcolor' || v == 'inherit') return fallback ?? const Color(0xFF000000);
  if (v.startsWith('#')) {
    var hex = v.substring(1);
    if (hex.length == 3 || hex.length == 4) hex = hex.split('').map((c) => '$c$c').join();
    final n = int.tryParse(hex, radix: 16);
    if (n != null && hex.length == 6) return Color(0xFF000000 | n);
    if (n != null && hex.length == 8) return Color(((n & 0xFF) << 24) | (n >> 8));
  }
  if (v.startsWith('rgb')) {
    final n = parseSvgNumbers(v);
    if (n.length >= 3) {
      final pct = v.contains('%');
      int c(double x) => (pct ? x * 2.55 : x).round().clamp(0, 255);
      final a = n.length >= 4 ? (n[3] > 1 ? n[3] / 100 : n[3]) : 1.0;
      return Color.fromARGB((a * 255).round().clamp(0, 255), c(n[0]), c(n[1]), c(n[2]));
    }
  }
  final named = _namedColors[v];
  if (named != null) return Color(named);
  return fallback ?? const Color(0xFF000000);
}

/// `transform="translate(4 4) scale(2) matrix(…) rotate(…)"` → Matrix4 storage.
Float64List parseSvgTransform(String t) {
  final m = Matrix4.identity();
  for (final f in RegExp(r'(matrix|translate|scale|rotate|skewX|skewY)\s*\(([^)]*)\)').allMatches(t)) {
    final n = parseSvgNumbers(f.group(2) ?? '');
    switch (f.group(1)) {
      case 'matrix':
        if (n.length >= 6) {
          m.multiply(Matrix4(n[0], n[1], 0, 0, n[2], n[3], 0, 0, 0, 0, 1, 0, n[4], n[5], 0, 1));
        }
      case 'translate':
        if (n.isNotEmpty) m.multiply(Matrix4.translationValues(n[0], n.length > 1 ? n[1] : 0, 0));
      case 'scale':
        if (n.isNotEmpty) m.multiply(Matrix4.diagonal3Values(n[0], n.length > 1 ? n[1] : n[0], 1));
      case 'rotate':
        if (n.isNotEmpty) {
          final a = n[0] * math.pi / 180;
          if (n.length >= 3) m.multiply(Matrix4.translationValues(n[1], n[2], 0));
          m.multiply(Matrix4.rotationZ(a));
          if (n.length >= 3) m.multiply(Matrix4.translationValues(-n[1], -n[2], 0));
        }
      case 'skewX':
        if (n.isNotEmpty) m.multiply(Matrix4.skewX(n[0] * math.pi / 180));
      case 'skewY':
        if (n.isNotEmpty) m.multiply(Matrix4.skewY(n[0] * math.pi / 180));
    }
  }
  return m.storage;
}

final _pathTokenRe = RegExp(r'[MmLlHhVvCcSsQqTtAaZz]|[-+]?(?:\d*\.\d+|\d+\.?)(?:[eE][-+]?\d+)?');

/// Splits SVG path data into commands and numbers.
List<Object> tokenizeSvgPath(String d) => [
      for (final m in _pathTokenRe.allMatches(d))
        if (RegExp(r'^[A-Za-z]$').hasMatch(m.group(0)!)) m.group(0)! else double.parse(m.group(0)!),
    ];

/// SVG `d` → [Path].
Path parseSvgPathData(String d) {
  final tokens = tokenizeSvgPath(d);
  final path = Path();
  var i = 0;
  var cmd = '';
  var cx = 0.0, cy = 0.0, sx = 0.0, sy = 0.0;
  double? lastCtrlX, lastCtrlY;
  var lastCmd = '';

  bool hasNum() => i < tokens.length && tokens[i] is double;
  double nextNum() => tokens[i++] as double;

  while (i < tokens.length) {
    if (tokens[i] is String) {
      cmd = tokens[i++] as String;
    } else if (cmd.isEmpty) {
      i++;
      continue;
    }
    final rel = cmd == cmd.toLowerCase();
    final c = cmd.toUpperCase();
    if (c == 'Z') {
      path.close();
      cx = sx;
      cy = sy;
      lastCmd = 'Z';
      lastCtrlX = null;
      continue;
    }
    var firstPair = true;
    while (hasNum()) {
      switch (c) {
        case 'M':
          if (i + 1 >= tokens.length || tokens[i + 1] is! double) {
            i++;
            break;
          }
          final x = nextNum() + (rel ? cx : 0);
          final y = nextNum() + (rel ? cy : 0);
          // Extra coordinate pairs after a moveto are implicit linetos.
          if (firstPair) {
            path.moveTo(x, y);
            sx = x;
            sy = y;
          } else {
            path.lineTo(x, y);
          }
          firstPair = false;
          cx = x;
          cy = y;
          lastCmd = 'M';
          lastCtrlX = null;
          continue;
        case 'L':
          if (i + 1 >= tokens.length || tokens[i + 1] is! double) {
            i++;
            break;
          }
          cx = nextNum() + (rel ? cx : 0);
          cy = nextNum() + (rel ? cy : 0);
          path.lineTo(cx, cy);
          lastCmd = 'L';
          lastCtrlX = null;
          continue;
        case 'H':
          cx = nextNum() + (rel ? cx : 0);
          path.lineTo(cx, cy);
          lastCmd = 'H';
          lastCtrlX = null;
          continue;
        case 'V':
          cy = nextNum() + (rel ? cy : 0);
          path.lineTo(cx, cy);
          lastCmd = 'V';
          lastCtrlX = null;
          continue;
        case 'C':
          if (i + 5 >= tokens.length) {
            i = tokens.length;
            break;
          }
          final x1 = nextNum() + (rel ? cx : 0), y1 = nextNum() + (rel ? cy : 0);
          final x2 = nextNum() + (rel ? cx : 0), y2 = nextNum() + (rel ? cy : 0);
          final x = nextNum() + (rel ? cx : 0), y = nextNum() + (rel ? cy : 0);
          path.cubicTo(x1, y1, x2, y2, x, y);
          lastCtrlX = x2;
          lastCtrlY = y2;
          cx = x;
          cy = y;
          lastCmd = 'C';
          continue;
        case 'S':
          if (i + 3 >= tokens.length) {
            i = tokens.length;
            break;
          }
          final x1 = (lastCmd == 'C' || lastCmd == 'S') && lastCtrlX != null ? 2 * cx - lastCtrlX : cx;
          final y1 = (lastCmd == 'C' || lastCmd == 'S') && lastCtrlY != null ? 2 * cy - lastCtrlY : cy;
          final x2 = nextNum() + (rel ? cx : 0), y2 = nextNum() + (rel ? cy : 0);
          final x = nextNum() + (rel ? cx : 0), y = nextNum() + (rel ? cy : 0);
          path.cubicTo(x1, y1, x2, y2, x, y);
          lastCtrlX = x2;
          lastCtrlY = y2;
          cx = x;
          cy = y;
          lastCmd = 'S';
          continue;
        case 'Q':
          if (i + 3 >= tokens.length) {
            i = tokens.length;
            break;
          }
          final x1 = nextNum() + (rel ? cx : 0), y1 = nextNum() + (rel ? cy : 0);
          final x = nextNum() + (rel ? cx : 0), y = nextNum() + (rel ? cy : 0);
          path.quadraticBezierTo(x1, y1, x, y);
          lastCtrlX = x1;
          lastCtrlY = y1;
          cx = x;
          cy = y;
          lastCmd = 'Q';
          continue;
        case 'T':
          if (i + 1 >= tokens.length) {
            i = tokens.length;
            break;
          }
          final x1 = (lastCmd == 'Q' || lastCmd == 'T') && lastCtrlX != null ? 2 * cx - lastCtrlX : cx;
          final y1 = (lastCmd == 'Q' || lastCmd == 'T') && lastCtrlY != null ? 2 * cy - lastCtrlY : cy;
          final x = nextNum() + (rel ? cx : 0), y = nextNum() + (rel ? cy : 0);
          path.quadraticBezierTo(x1, y1, x, y);
          lastCtrlX = x1;
          lastCtrlY = y1;
          cx = x;
          cy = y;
          lastCmd = 'T';
          continue;
        case 'A':
          if (i + 6 >= tokens.length) {
            i = tokens.length;
            break;
          }
          final rx = nextNum().abs(), ry = nextNum().abs(), rot = nextNum();
          final large = nextNum() != 0, sweep = nextNum() != 0;
          final x = nextNum() + (rel ? cx : 0), y = nextNum() + (rel ? cy : 0);
          if (rx == 0 || ry == 0) {
            path.lineTo(x, y);
          } else {
            path.arcToPoint(Offset(x, y),
                radius: Radius.elliptical(rx, ry), rotation: rot, largeArc: large, clockwise: sweep);
          }
          cx = x;
          cy = y;
          lastCmd = 'A';
          lastCtrlX = null;
          continue;
        default:
          i++;
      }
    }
  }
  return path;
}

// ── PDF ──────────────────────────────────────────────────────────────────────

/// One full-page image of [buildImagePdf] (`width × height` RGB pixels).
class PdfImagePage {
  const PdfImagePage(this.width, this.height, this.rgb);
  final int width;
  final int height;
  final Uint8List rgb;
}

/// `createPdfFromCanvases`: A4 pages (595.28 × 841.89 pt), each a single
/// image XObject stretched over the page. Objects: 1 catalog, 2 pages, then
/// page / content / image per page (3 + 3i, 4 + 3i, 5 + 3i).
Uint8List buildImagePdf(List<PdfImagePage> pages) {
  const pageWidth = 595.28;
  const pageHeight = 841.89;
  final out = BytesBuilder(copy: false);
  final offsets = <int, int>{};

  void ascii(String s) => out.add(latin1.encode(s));
  void object(int n, String body) {
    offsets[n] = out.length;
    ascii('$n 0 obj\n$body\nendobj\n');
  }

  out.add([...latin1.encode('%PDF-1.4\n%'), 0xFF, 0xFF, 0xFF, 0xFF, 0x0A]);
  object(1, '<< /Type /Catalog /Pages 2 0 R >>');
  final kids = [for (var i = 0; i < pages.length; i++) '${3 + i * 3} 0 R'].join(' ');
  object(2, '<< /Type /Pages /Count ${pages.length} /Kids [$kids] >>');

  for (var i = 0; i < pages.length; i++) {
    final p = pages[i];
    final pageObj = 3 + i * 3, contentObj = 4 + i * 3, imageObj = 5 + i * 3;
    object(pageObj,
        '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 $pageWidth $pageHeight] /Resources << /XObject << /Im$i $imageObj 0 R >> >> /Contents $contentObj 0 R >>');
    final content = 'q\n$pageWidth 0 0 $pageHeight 0 0 cm\n/Im$i Do\nQ';
    object(contentObj, '<< /Length ${latin1.encode(content).length} >>\nstream\n$content\nendstream');
    final data = zlib.encode(p.rgb);
    offsets[imageObj] = out.length;
    ascii('$imageObj 0 obj\n<< /Type /XObject /Subtype /Image /Width ${p.width} /Height ${p.height} '
        '/ColorSpace /DeviceRGB /BitsPerComponent 8 /Filter /FlateDecode /Length ${data.length} >>\nstream\n');
    out.add(data);
    ascii('\nendstream\nendobj\n');
  }

  final xref = out.length;
  final count = 2 + pages.length * 3;
  ascii('xref\n0 ${count + 1}\n0000000000 65535 f \n');
  for (var n = 1; n <= count; n++) {
    ascii('${'${offsets[n]}'.padLeft(10, '0')} 00000 n \n');
  }
  ascii('trailer\n<< /Size ${count + 1} /Root 1 0 R >>\nstartxref\n$xref\n%%EOF');
  return out.takeBytes();
}

/// RGBA → RGB (drops alpha; the card background is opaque white).
Uint8List rgbaToRgb(Uint8List rgba) {
  final px = rgba.length ~/ 4;
  final rgb = Uint8List(px * 3);
  for (var i = 0, j = 0; i < px; i++, j += 3) {
    rgb[j] = rgba[i * 4];
    rgb[j + 1] = rgba[i * 4 + 1];
    rgb[j + 2] = rgba[i * 4 + 2];
  }
  return rgb;
}

// ── card rendering ───────────────────────────────────────────────────────────

const _cardW = 1240.0;
const _cardH = 1754.0;

void _text(Canvas canvas, String text, TextStyle style, {required double x, required double y, bool middle = false, double? maxWidth, int? maxLines, double? height}) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: style.copyWith(fontFamily: 'Arial', height: height)),
    textAlign: TextAlign.center,
    textDirection: TextDirection.ltr,
    maxLines: maxLines,
  );
  if (maxWidth != null) {
    tp.layout(minWidth: maxWidth, maxWidth: maxWidth);
    tp.paint(canvas, Offset(x - maxWidth / 2, middle ? y - tp.height / 2 : y));
  } else {
    tp.layout();
    tp.paint(canvas, Offset(x - tp.width / 2, middle ? y - tp.height / 2 : y));
  }
  tp.dispose();
}

/// `createQuizSysCardCanvas(card)` → RGB pixels.
Future<PdfImagePage> renderQuizSysCard(Map<String, dynamic> card) async {
  final svg = MiniSvg.parse(asString(card['svg']) ?? '');
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, _cardW, _cardH));
  canvas.drawRect(const Rect.fromLTWH(0, 0, _cardW, _cardH), Paint()..color = Colors.white);

  final name = jsTruthy(card['name']) ? jsString(card['name']) : 'Student';
  _text(canvas, name, const TextStyle(fontSize: 54, fontWeight: FontWeight.w700, color: Color(0xFF111827)),
      x: _cardW / 2, y: 170, maxWidth: 980, maxLines: 2, height: 62 / 54);
  _text(canvas, 'Student ID: ${vueTextOrUndefined(card, 'student_id')}',
      const TextStyle(fontSize: 34, fontWeight: FontWeight.w400, color: Color(0xFF374151)),
      x: _cardW / 2, y: 285);

  const wrapSize = 820.0;
  const markerSize = 640.0;
  const wrapX = (_cardW - wrapSize) / 2;
  const wrapY = 470.0;
  const markerX = wrapX + (wrapSize - markerSize) / 2;
  const markerY = wrapY + (wrapSize - markerSize) / 2;

  const letter = TextStyle(fontSize: 56, fontWeight: FontWeight.w700, color: Color(0xFF10B981));
  _text(canvas, 'A', letter, x: _cardW / 2, y: wrapY + 42, middle: true);
  _text(canvas, 'B', letter, x: wrapX + wrapSize - 42, y: wrapY + wrapSize / 2, middle: true);
  _text(canvas, 'C', letter, x: _cardW / 2, y: wrapY + wrapSize - 42, middle: true);
  _text(canvas, 'D', letter, x: wrapX + 42, y: wrapY + wrapSize / 2, middle: true);

  const frame = Rect.fromLTWH(markerX - 16, markerY - 16, markerSize + 32, markerSize + 32);
  canvas.drawRect(frame, Paint()..color = Colors.white);
  canvas.drawRect(
    frame,
    Paint()
      ..color = const Color(0xFF111827)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3,
  );
  svg.paint(canvas, const Rect.fromLTWH(markerX, markerY, markerSize, markerSize));

  _text(canvas, 'Marker ${vueTextOrUndefined(card, 'marker_id')}',
      const TextStyle(fontSize: 24, fontWeight: FontWeight.w400, color: Color(0xFF6B7280)),
      x: _cardW / 2, y: 1370, middle: true);

  final picture = recorder.endRecording();
  final image = await picture.toImage(_cardW.toInt(), _cardH.toInt());
  picture.dispose();
  try {
    final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (data == null) throw StateError('Canvas is not supported.');
    return PdfImagePage(image.width, image.height, rgbaToRgb(data.buffer.asUint8List()));
  } finally {
    image.dispose();
  }
}

/// `${card.x}` inside a template literal (`undefined` when missing).
String vueTextOrUndefined(Map<String, dynamic> card, String key) => jsMember(card, key);

/// `downloadQuizSysCardsAsPdf` minus the download: one page per card.
Future<Uint8List> buildQuizSysCardsPdf(List<Map<String, dynamic>> cards) async {
  final pages = <PdfImagePage>[];
  for (final card in cards) {
    pages.add(await renderQuizSysCard(card));
  }
  return buildImagePdf(pages);
}

/// `<div class="w-16 h-16 bg-white rounded-lg border border-slate-200 p-1" v-html="card.svg">`.
class QuizSysSvgThumb extends StatefulWidget {
  const QuizSysSvgThumb({super.key, required this.svg});
  final String svg;

  @override
  State<QuizSysSvgThumb> createState() => _QuizSysSvgThumbState();
}

class _QuizSysSvgThumbState extends State<QuizSysSvgThumb> {
  MiniSvg? _svg;

  @override
  void initState() {
    super.initState();
    _parse();
  }

  @override
  void didUpdateWidget(QuizSysSvgThumb old) {
    super.didUpdateWidget(old);
    if (old.svg != widget.svg) _parse();
  }

  void _parse() {
    try {
      _svg = MiniSvg.parse(widget.svg);
    } catch (_) {
      _svg = null;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        width: 64,
        height: 64,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: _svg == null ? null : CustomPaint(painter: _SvgPainter(_svg!)),
      );
}

class _SvgPainter extends CustomPainter {
  _SvgPainter(this.svg);
  final MiniSvg svg;

  @override
  void paint(Canvas canvas, Size size) => svg.paint(canvas, Offset.zero & size);

  @override
  bool shouldRepaint(_SvgPainter old) => old.svg != svg;
}
