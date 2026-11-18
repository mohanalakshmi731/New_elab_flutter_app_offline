// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Hierarchy of classification(five kingdom system)
// Converted from Cl9S-Ch12-A3-HierarchyAndFiveKingdom.html (gsap -> Flutter, three.js -> mini3d).

import 'dart:async';
import 'dart:math' as math;


import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
// BEGIN ACTIVITY-LOCAL RUNTIME — copied into this page for portability.



/// Supported UI languages.
enum _rt_AppLang { en, hi }

/// Global language state shared by the home screen and every activity.
///
/// Toggling it rebuilds everything listening through [_rt_LangBuilder] or
/// [ValueListenableBuilder], so the whole UI switches English <-> Hindi.
class _rt_AppLanguage extends ValueNotifier<_rt_AppLang> {
  _rt_AppLanguage._() : super(_rt_AppLang.en);

  static final _rt_AppLanguage instance = _rt_AppLanguage._();

  bool get isHindi => value == _rt_AppLang.hi;
  String get code => value.name;

  void toggle() => value = value == _rt_AppLang.en ? _rt_AppLang.hi : _rt_AppLang.en;
}

_rt_AppLanguage get _rt_appLanguage => _rt_AppLanguage.instance;

/// Picks the string for the current language from an `{en, hi}` pair.
String _rt_tr(String en, String hi) => _rt_appLanguage.isHindi ? hi : en;

/// Rebuilds [builder] whenever the language *or* the theme changes.
///
/// Every activity already wraps its `build` in this, so hooking the theme in
/// here is what makes a dark/light toggle reach all of them.
class _rt_LangBuilder extends StatelessWidget {
  const _rt_LangBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, _rt_AppLang lang) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_rt_LabThemeMode>(
      valueListenable: _rt_appTheme,
      builder: (context, _, _) => ValueListenableBuilder<_rt_AppLang>(
        valueListenable: _rt_appLanguage,
        builder: (context, lang, _) => builder(context, lang),
      ),
    );
  }
}

/// Read-only view over a translation table shaped like the HTML `LAB_TEXT`
/// objects: `{'en': {...}, 'hi': {...}}`.
///
/// Lookups use dotted paths, e.g. `t.s('tabs.explore')` or
/// `t.list('scenarios')`. Missing Hindi keys fall back to English so a gap in
/// a translation never crashes an activity.
class _rt_Tx {
  _rt_Tx(this.table);

  final Map<String, Map<String, dynamic>> table;

  Map<String, dynamic> get _cur => table[_rt_appLanguage.code] ?? table['en']!;
  Map<String, dynamic> get _en => table['en']!;

  dynamic _lookup(Map<String, dynamic> root, String path) {
    dynamic node = root;
    for (final part in path.split('.')) {
      if (node is Map) {
        node = node[part];
      } else if (node is List) {
        final i = int.tryParse(part);
        node = (i != null && i < node.length) ? node[i] : null;
      } else {
        return null;
      }
      if (node == null) return null;
    }
    return node;
  }

  /// Raw value at [path] (Map, List, String, num...).
  dynamic get(String path) => _lookup(_cur, path) ?? _lookup(_en, path);

  /// String at [path]; returns [path] itself if missing (easy to spot).
  String s(String path) => get(path)?.toString() ?? path;

  List<dynamic> list(String path) => (get(path) as List?) ?? const [];

  Map<String, dynamic> map(String path) =>
      (get(path) as Map?)?.cast<String, dynamic>() ?? const {};
}



/// Which school year an activity belongs to. Activities, chapter numbers and
/// chapter names all repeat across years, so everything is keyed by this.
enum _rt_SchoolClass {
  class8(8, 'Class 8', 'कक्षा 8'),
  class9(9, 'Class 9', 'कक्षा 9'),
  class10(10, 'Class 10', 'कक्षा 10');

  const _rt_SchoolClass(this.number, this.labelEn, this.labelHi);

  final int number;
  final String labelEn;
  final String labelHi;

  String get label => _rt_tr(labelEn, labelHi);
}

class _rt_ActivityInfo {
  const _rt_ActivityInfo({
    required this.schoolClass,
    required this.chapter,
    required this.code,
    required this.titleEn,
    required this.titleHi,
    required this.htmlFile,
    required this.builder,
  });

  final _rt_SchoolClass schoolClass;
  final int chapter;

  /// Chapter.activity, e.g. '11.3'. Only unique within a [schoolClass].
  final String code;
  final String titleEn;
  final String titleHi;

  /// Source HTML file this page was converted from.
  final String htmlFile;
  final WidgetBuilder builder;

  String get title => _rt_tr(titleEn, titleHi);

  /// Unique across every class, e.g. 'c10-11.3'.
  String get id => 'c${schoolClass.number}-$code';
}

class _rt_ChapterInfo {
  const _rt_ChapterInfo(this.schoolClass, this.number, this.nameEn, this.nameHi);

  final _rt_SchoolClass schoolClass;
  final int number;
  final String nameEn;
  final String nameHi;

  String get name => _rt_tr(nameEn, nameHi);
}



/// Dark / light appearance, mirroring the `--bg-*` / `--text-*` CSS custom
/// properties every source activity defines. The HTML labs open in dark, so
/// that is the default here too.
enum _rt_LabThemeMode { dark, light }

class _rt_AppTheme extends ValueNotifier<_rt_LabThemeMode> {
  _rt_AppTheme._() : super(_rt_LabThemeMode.dark);

  static final _rt_AppTheme instance = _rt_AppTheme._();

  bool get isDark => value == _rt_LabThemeMode.dark;

  void set(_rt_LabThemeMode mode) => value = mode;
  void toggle() => value = isDark ? _rt_LabThemeMode.light : _rt_LabThemeMode.dark;
}

_rt_AppTheme get _rt_appTheme => _rt_AppTheme.instance;

/// Semantic colours resolved against the current [_rt_appTheme].
///
/// Widgets should reach for these instead of a literal `Colors.white` or a
/// fixed `_rt_Tw.slate*` so a single toggle re-skins every activity. The names
/// follow the CSS variables in the source files.
class _rt_Lab {
  const _rt_Lab._();

  static bool get _d => _rt_appTheme.isDark;

  /// `--bg-panel-solid`: cards, sidebar rows, popups.
  static Color get surface => _d ? const Color(0xFF1E293B) : Colors.white;

  /// `--bg-base`: the sidebar and page background behind [surface].
  static Color get base => _d ? const Color(0xFF0F172A) : _rt_Tw.slate50;

  /// `--bg-overlay`: subtle fills inside a surface.
  static Color get overlay =>
      _d ? Colors.white.withValues(alpha: 0.06) : _rt_Tw.slate100;

  /// `--canvas-bg`: the simulation area behind a 2D station.
  static Color get canvas => _d ? const Color(0xFF020617) : _rt_Tw.slate100;

  /// `--text-main`, `--text-muted`, and a third step for captions.
  static Color get text => _d ? const Color(0xFFF8FAFC) : _rt_Tw.slate800;
  static Color get textMuted => _d ? const Color(0xFF94A3B8) : _rt_Tw.slate600;
  static Color get textFaint => _d ? const Color(0xFF64748B) : _rt_Tw.slate400;

  /// `--border-color`.
  static Color get border =>
      _d ? Colors.white.withValues(alpha: 0.16) : _rt_Tw.slate200;
  static Color get borderStrong =>
      _d ? Colors.white.withValues(alpha: 0.28) : _rt_Tw.slate300;

  /// Tinted card backgrounds that stay legible in both themes. [tint] is the
  /// light-theme fill (e.g. `_rt_Tw.green50`); in dark it becomes a low-alpha
  /// wash of [accent] over [surface].
  static Color tinted(Color tint, Color accent) =>
      _d ? Color.alphaBlend(accent.withValues(alpha: 0.18), surface) : tint;

  /// Border for a [tinted] surface.
  static Color tintedBorder(Color accent) =>
      _d ? accent.withValues(alpha: 0.45) : Color.lerp(accent, Colors.white, 0.8)!;

  /// Foreground for text sitting on a [tinted] background.
  static Color onTinted(Color darkAccent, Color lightAccent) =>
      _d ? Color.lerp(darkAccent, Colors.white, 0.45)! : lightAccent;

  /// Shadow strength; dark surfaces need a heavier, flatter shadow.
  static Color get shadow =>
      Colors.black.withValues(alpha: _d ? 0.45 : 0.16);
}

/// Rebuilds [builder] whenever the theme changes.
class _rt_ThemeBuilder extends StatelessWidget {
  const _rt_ThemeBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, _rt_LabThemeMode mode) builder;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<_rt_LabThemeMode>(
      valueListenable: _rt_appTheme,
      builder: (context, mode, _) => builder(context, mode),
    );
  }
}



/// Strings used by the shared shell and home screen (not activity content).
class _rt_CommonStrings {
  static String get appTitle => _rt_tr('Science _rt_Lab', 'विज्ञान प्रयोगशाला');

  /// Subtitle naming the class currently being browsed.
  static String appSubtitleFor(_rt_SchoolClass c) => _rt_tr(
        'Interactive 3D activities • NCERT ${c.labelEn}',
        'इंटरैक्टिव 3D गतिविधियाँ • एनसीईआरटी ${c.labelHi}',
      );
  static String get selectClass => _rt_tr('Select class', 'कक्षा चुनें');
  static String get footer =>
      _rt_tr('© ZeroScienceLab - Fall in love with math and Science',
          '© ZeroScienceLab - गणित और विज्ञान से प्यार करें');
  static String get langButton => _rt_tr('EN', 'हि');
  static String get switchLanguage => _rt_tr('Switch to Hindi', 'अंग्रेज़ी में बदलें');
  static String get restart => _rt_tr('Restart', 'पुनः आरंभ');
  static String get done => _rt_tr('Done', 'पूर्ण');
  static String get currentStep => _rt_tr('Current Step', 'वर्तमान चरण');
  static String get zoomIn => _rt_tr('Zoom in', 'ज़ूम इन');
  static String get zoomOut => _rt_tr('Zoom out', 'ज़ूम आउट');
  static String get resetView => _rt_tr('Reset view', 'दृश्य रीसेट करें');
  static String get close => _rt_tr('Close', 'बंद करें');
  static String get continueLabel => _rt_tr('Continue', 'जारी रखें');
  static String get wellDone => _rt_tr('Well Done!', 'बहुत बढ़िया!');
  static String get activities => _rt_tr('activities', 'गतिविधियाँ');
  static String get chapter => _rt_tr('Chapter', 'अध्याय');
  static String get activity => _rt_tr('Activity', 'गतिविधि');
  static String get open => _rt_tr('Open', 'खोलें');
  static String get search => _rt_tr('Search activities', 'गतिविधियाँ खोजें');
  static String get back => _rt_tr('Back', 'वापस');
  static String get resizeSidebar =>
      _rt_tr('Drag to resize • double-tap to reset', 'आकार बदलने के लिए खींचें • रीसेट के लिए डबल-टैप');
  static String get dragHint => _rt_tr(
        'Drag to rotate • Pinch or scroll to zoom',
        'घुमाने के लिए खींचें • ज़ूम के लिए पिंच या स्क्रॉल करें',
      );
}

// ---------------------------------------------------------------------------
// Activity-local feedback service. This page deliberately does not use the
// app-wide sound service or audio assets, so it can be moved independently.
enum _rt_Sfx { click, tap, toggle, scenario, correct, wrong, success, curtain, pop, magic }

class _rt_SoundService {
  _rt_SoundService._();
  static final _rt_SoundService instance = _rt_SoundService._();
  bool enabled = true;

  void preload() {}

  Future<void> play(_rt_Sfx sfx, {double volume = 1.0}) async {
    if (!enabled) return;
    await SystemSound.play(SystemSoundType.click);
  }

  Future<void> stop(_rt_Sfx sfx) async {}
}

void _rt_playSfx(_rt_Sfx sfx, {double volume = 1.0}) =>
    _rt_SoundService.instance.play(sfx, volume: volume);







/// Palette taken from the Tailwind classes used by the HTML activities.
class _rt_Tw {
  static const slate50 = Color(0xFFF8FAFC);
  static const slate100 = Color(0xFFF1F5F9);
  static const slate200 = Color(0xFFE2E8F0);
  static const slate300 = Color(0xFFCBD5E1);
  static const slate400 = Color(0xFF94A3B8);
  static const slate500 = Color(0xFF64748B);
  static const slate600 = Color(0xFF475569);
  static const slate700 = Color(0xFF334155);
  static const slate800 = Color(0xFF1E293B);
  static const slate900 = Color(0xFF0F172A);
  static const slate950 = Color(0xFF020617);
  static const gray50 = Color(0xFFF9FAFB);
  static const gray100 = Color(0xFFF3F4F6);
  static const gray200 = Color(0xFFE5E7EB);
  static const gray400 = Color(0xFF9CA3AF);
  static const gray500 = Color(0xFF6B7280);
  static const gray600 = Color(0xFF4B5563);
  static const gray700 = Color(0xFF374151);
  static const gray800 = Color(0xFF1F2937);
  static const teal50 = Color(0xFFF0FDFA);
  static const teal100 = Color(0xFFCCFBF1);
  static const teal200 = Color(0xFF99F6E4);
  static const teal400 = Color(0xFF2DD4BF);
  static const teal500 = Color(0xFF14B8A6);
  static const teal600 = Color(0xFF0D9488);
  static const teal700 = Color(0xFF0F766E);
  static const teal800 = Color(0xFF115E59);
  static const teal900 = Color(0xFF134E4A);
  static const cyan400 = Color(0xFF22D3EE);
  static const cyan500 = Color(0xFF06B6D4);
  static const cyan600 = Color(0xFF0891B2);
  static const sky400 = Color(0xFF38BDF8);
  static const sky500 = Color(0xFF0EA5E9);
  static const blue50 = Color(0xFFEFF6FF);
  static const blue100 = Color(0xFFDBEAFE);
  static const blue400 = Color(0xFF60A5FA);
  static const blue500 = Color(0xFF3B82F6);
  static const blue600 = Color(0xFF2563EB);
  static const blue700 = Color(0xFF1D4ED8);
  static const blue800 = Color(0xFF1E40AF);
  static const blue900 = Color(0xFF1E3A8A);
  static const indigo50 = Color(0xFFEEF2FF);
  static const indigo100 = Color(0xFFE0E7FF);
  static const indigo500 = Color(0xFF6366F1);
  static const indigo600 = Color(0xFF4F46E5);
  static const indigo700 = Color(0xFF4338CA);
  static const indigo900 = Color(0xFF312E81);
  static const violet500 = Color(0xFF8B5CF6);
  static const violet600 = Color(0xFF7C3AED);
  static const purple500 = Color(0xFFA855F7);
  static const purple600 = Color(0xFF9333EA);
  static const pink500 = Color(0xFFEC4899);
  static const rose500 = Color(0xFFF43F5E);
  static const red50 = Color(0xFFFEF2F2);
  static const red100 = Color(0xFFFEE2E2);
  static const red400 = Color(0xFFF87171);
  static const red500 = Color(0xFFEF4444);
  static const red600 = Color(0xFFDC2626);
  static const red700 = Color(0xFFB91C1C);
  static const orange50 = Color(0xFFFFF7ED);
  static const orange100 = Color(0xFFFFEDD5);
  static const orange400 = Color(0xFFFB923C);
  static const orange500 = Color(0xFFF97316);
  static const orange600 = Color(0xFFEA580C);
  static const orange800 = Color(0xFF9A3412);
  static const amber50 = Color(0xFFFFFBEB);
  static const amber100 = Color(0xFFFEF3C7);
  static const amber200 = Color(0xFFFDE68A);
  static const amber400 = Color(0xFFFBBF24);
  static const amber500 = Color(0xFFF59E0B);
  static const amber600 = Color(0xFFD97706);
  static const amber700 = Color(0xFFB45309);
  static const yellow400 = Color(0xFFFACC15);
  static const yellow500 = Color(0xFFEAB308);
  static const green50 = Color(0xFFF0FDF4);
  static const green100 = Color(0xFFDCFCE7);
  static const green400 = Color(0xFF4ADE80);
  static const green500 = Color(0xFF22C55E);
  static const green600 = Color(0xFF16A34A);
  static const green700 = Color(0xFF15803D);
  static const emerald50 = Color(0xFFECFDF5);
  static const emerald100 = Color(0xFFD1FAE5);
  static const emerald400 = Color(0xFF34D399);
  static const emerald500 = Color(0xFF10B981);
  static const emerald600 = Color(0xFF059669);
  static const emerald700 = Color(0xFF047857);
  static const lime500 = Color(0xFF84CC16);
}

/// Pill action button (the HTML `.action-btn`). Plays a click sound.
class _rt_ActionButton extends StatelessWidget {
  const _rt_ActionButton({
    super.key,
    required this.label,
    this.icon,
    this.onPressed,
    this.color = _rt_Tw.teal600,
    this.done = false,
    this.expand = false,
    this.sound = _rt_Sfx.click,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final Color color;
  final bool done;
  final bool expand;
  final _rt_Sfx? sound;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !done;
    final bg = done ? _rt_Tw.slate400 : (enabled ? color : color.withValues(alpha: 0.45));
    final child = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(done ? Icons.check : (icon ?? Icons.play_arrow), size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            (done ? _rt_CommonStrings.done : label).toUpperCase(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
    return Material(
      color: bg,
      shape: const StadiumBorder(),
      elevation: enabled ? 2 : 0,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: enabled
            ? () {
                if (sound != null) _rt_playSfx(sound!);
                onPressed!();
              }
            : null,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: child,
        ),
      ),
    );
  }
}

/// Scenario / objective header (the HTML `#scenario-header` with bullseye).
class _rt_ObjectiveCard extends StatelessWidget {
  const _rt_ObjectiveCard({
    super.key,
    required this.title,
    required this.desc,
    this.accent = _rt_Tw.teal600,
    this.icon = Icons.gps_fixed,
    this.trailing,
  });

  final String title;
  final String desc;
  final Color accent;
  final IconData icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(Color.lerp(accent, Colors.white, 0.92)!, accent),
        border: Border(
            bottom: BorderSide(
                color: _rt_Lab.tintedBorder(accent))),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 14, color: accent),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                title.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: _rt_Lab.onTinted(accent, Color.lerp(accent, Colors.black, 0.35)!),
                ),
              ),
            ),
            ?trailing,
          ]),
          const SizedBox(height: 6),
          Text(desc,
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: _rt_Lab.text, height: 1.25)),
        ],
      ),
    );
  }
}

/// Numbered step card with action button (the HTML `.step-card`).
class _rt_StepCard extends StatelessWidget {
  const _rt_StepCard({
    super.key,
    required this.number,
    required this.title,
    required this.desc,
    required this.actionLabel,
    required this.onAction,
    this.active = false,
    this.done = false,
    this.locked = false,
    this.accent = _rt_Tw.teal600,
    this.actionIcon,
    this.extra,
  });

  final int number;
  final String title;
  final String desc;
  final String actionLabel;
  final VoidCallback? onAction;
  final bool active;
  final bool done;
  final bool locked;
  final Color accent;
  final IconData? actionIcon;
  final Widget? extra;

  @override
  Widget build(BuildContext context) {
    final dim = !active && !done;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: active ? _rt_Lab.tinted(Color.lerp(accent, Colors.white, 0.93)!, accent) : _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: active ? accent : _rt_Lab.border, width: 2),
        boxShadow: active
            ? [BoxShadow(color: accent.withValues(alpha: 0.15), blurRadius: 6, offset: const Offset(0, 3))]
            : null,
      ),
      child: Opacity(
        opacity: dim ? 0.65 : 1,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _rt_Lab.tinted(Color.lerp(accent, Colors.white, 0.8)!, accent)
                      .withValues(alpha: active ? 1 : 0.5),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12), topRight: Radius.circular(10)),
                ),
                child: Text('$number',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: _rt_Lab.onTinted(accent, Color.lerp(accent, Colors.black, 0.3)!),
                        height: 1)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 34),
                    child: Text(title,
                        style: TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w800, color: _rt_Lab.text)),
                  ),
                  const SizedBox(height: 4),
                  Text(desc, style: TextStyle(fontSize: 12, color: _rt_Lab.textMuted, height: 1.3)),
                  ?extra,
                  const SizedBox(height: 10),
                  _rt_ActionButton(
                    label: actionLabel,
                    icon: actionIcon,
                    color: accent,
                    done: done,
                    onPressed: locked ? null : onAction,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Generic content card (challenges, explainers, definitions, outcomes).
class _rt_InfoCard extends StatelessWidget {
  const _rt_InfoCard({
    super.key,
    this.title,
    this.body,
    this.hint,
    this.tag,
    this.color = _rt_Tw.teal600,
    this.icon,
    this.child,
    this.leftBorder = false,
  });

  final String? title;
  final String? body;
  final String? hint;
  final String? tag;
  final Color color;
  final IconData? icon;
  final Widget? child;
  final bool leftBorder;

  @override
  Widget build(BuildContext context) {
    final bg = leftBorder
        ? _rt_Lab.surface
        : _rt_Lab.tinted(Color.lerp(color, Colors.white, 0.94)!, color);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: leftBorder
            ? Border(left: BorderSide(color: color, width: 4))
            : Border.all(color: _rt_Lab.tintedBorder(color)),
        boxShadow: leftBorder ? [BoxShadow(color: _rt_Lab.shadow, blurRadius: 4)] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tag != null)
            Text(tag!.toUpperCase(),
                style: TextStyle(
                    fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.8)),
          if (title != null)
            Row(children: [
              if (icon != null) ...[Icon(icon, size: 16, color: color), const SizedBox(width: 6)],
              Expanded(
                child: Text(title!,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: _rt_Lab.onTinted(color, Color.lerp(color, Colors.black, 0.35)!))),
              ),
            ]),
          if (body != null) ...[
            const SizedBox(height: 6),
            Text(body!, style: TextStyle(fontSize: 12.5, color: _rt_Lab.text, height: 1.4)),
          ],
          if (hint != null) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _rt_Lab.overlay,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: _rt_Lab.tintedBorder(color)),
              ),
              child: Text(hint!,
                  style: TextStyle(
                      fontSize: 11.5, color: _rt_Lab.textMuted, fontStyle: FontStyle.italic)),
            ),
          ],
          ?child,
        ],
      ),
    );
  }
}

/// HUD read-out card shown over the 3D view (the HTML `.hud-card`).
class _rt_HudCard extends StatelessWidget {
  const _rt_HudCard({super.key, required this.value, required this.label, this.color = _rt_Tw.teal700, this.minWidth = 90});

  final String value;
  final String label;
  final Color color;
  final double minWidth;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: minWidth),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.tintedBorder(color), width: 2),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 6)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(value,
            style: TextStyle(
                fontFamily: 'monospace',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: _rt_Lab.onTinted(color, color))),
        Text(label.toUpperCase(),
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: _rt_Lab.textMuted)),
      ]),
    );
  }
}

/// Small section heading inside the sidebar.
class _rt_SectionLabel extends StatelessWidget {
  const _rt_SectionLabel(this.text, {super.key, this.color, this.icon});

  final String text;

  /// Defaults to the theme's muted text colour.
  final Color? color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final color = this.color ?? _rt_Lab.textMuted;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(children: [
        if (icon != null) ...[Icon(icon, size: 14, color: color), const SizedBox(width: 6)],
        Expanded(
          child: Text(text.toUpperCase(),
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, color: color)),
        ),
      ]),
    );
  }
}

/// Labelled slider (HTML `<input type="range">`). Plays a tap on release.
class _rt_LabeledSlider extends StatelessWidget {
  const _rt_LabeledSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.valueText,
    this.color = _rt_Tw.teal600,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? valueText;
  final ValueChanged<double>? onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
            child: Text(label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: _rt_Lab.textMuted)),
          ),
          Text(valueText ?? value.toStringAsFixed(1),
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w900, color: color, fontFamily: 'monospace')),
        ]),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: color,
            thumbColor: color,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            onChanged: onChanged,
            onChangeEnd: onChanged == null ? null : (_) => _rt_playSfx(_rt_Sfx.tap, volume: 0.6),
          ),
        ),
      ],
    );
  }
}

/// Multiple-choice option button used in quizzes / challenges.
class _rt_ChoiceButton extends StatelessWidget {
  const _rt_ChoiceButton({
    super.key,
    required this.label,
    required this.onTap,
    this.state = _rt_ChoiceState.idle,
  });

  final String label;
  final VoidCallback? onTap;
  final _rt_ChoiceState state;

  @override
  Widget build(BuildContext context) {
    final (bg, border, fg) = switch (state) {
      _rt_ChoiceState.correct =>
        (_rt_Lab.tinted(_rt_Tw.green100, _rt_Tw.green500), _rt_Tw.green500, _rt_Lab.onTinted(_rt_Tw.green400, _rt_Tw.green700)),
      _rt_ChoiceState.wrong =>
        (_rt_Lab.tinted(_rt_Tw.red100, _rt_Tw.red500), _rt_Tw.red500, _rt_Lab.onTinted(_rt_Tw.red400, _rt_Tw.red700)),
      _rt_ChoiceState.selected =>
        (_rt_Lab.tinted(_rt_Tw.blue100, _rt_Tw.blue500), _rt_Tw.blue500, _rt_Lab.onTinted(_rt_Tw.blue400, _rt_Tw.blue700)),
      _rt_ChoiceState.idle => (_rt_Lab.surface, _rt_Lab.border, _rt_Lab.text),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: border, width: 2),
            ),
            child: Text(label,
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: fg)),
          ),
        ),
      ),
    );
  }
}

enum _rt_ChoiceState { idle, selected, correct, wrong }

/// Language-aware wrapper for a `{en, hi}` literal pair.
class _rt_L10nText extends StatelessWidget {
  const _rt_L10nText(this.en, this.hi, {super.key, this.style, this.textAlign});

  final String en;
  final String hi;
  final TextStyle? style;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) =>
      _rt_LangBuilder(builder: (_, _) => Text(_rt_tr(en, hi), style: style, textAlign: textAlign));
}

/// Builds [child] only once the available width reaches [minWidth].
///
/// The app starts in portrait and activity pages switch to landscape in
/// initState, so their first frames are laid out with the portrait width
/// minus the sidebar (about 110 dp on a phone). Wrapping a landscape-only
/// layout in this gate skips those frames instead of overflowing.
class _rt_MinWidthGate extends StatelessWidget {
  const _rt_MinWidthGate({super.key, this.minWidth = 200, required this.child});

  final double minWidth;
  final Widget child;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
      builder: (_, c) => c.maxWidth < minWidth ? const SizedBox.shrink() : child);
}

/// Floating back button pinned to the top-right of an activity screen.
///
/// Renders nothing when there is no route to pop (the home screen), so it is
/// safe to drop into any page unconditionally.
class _rt_FloatingBackButton extends StatelessWidget {
  const _rt_FloatingBackButton({super.key, this.onPressed});

  /// Overrides the default `Navigator.maybePop` (e.g. to confirm first).
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    if (!Navigator.canPop(context)) return const SizedBox.shrink();
    return Tooltip(
      message: _rt_CommonStrings.back,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: Colors.orangeAccent,
        iconSize: 28,
        onPressed: () {
          HapticFeedback.lightImpact();
          _rt_playSfx(_rt_Sfx.tap);
          if (onPressed != null) {
            onPressed!();
          } else {
            Navigator.maybePop(context);
          }
        },
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withValues(alpha: 0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.withValues(alpha: 0.8)),
          ),
        ),
      ),
    );
  }
}










/// Sidebar resize limits. [_rt_kSidebarDefaultWidth] is the original fixed width.
const double _rt_kSidebarMinWidth = 240;
const double _rt_kSidebarMaxWidth = 560;
const double _rt_kSidebarDefaultWidth = 300;

/// Width the user last dragged the sidebar to. Global so the choice carries
/// across activities for the session. Not persisted to disk -- assign to it on
/// startup (and read it after a resize) to remember the width between launches.
double _rt_rememberedSidebarWidth = _rt_kSidebarDefaultWidth;

/// One sidebar tab (Experiment, Challenges, Explainer, Definitions, ...).
class _rt_ShellTab {
  const _rt_ShellTab({required this.label, required this.icon, required this.builder});

  final String label;
  final IconData icon;

  /// Builds the tab body. It lives inside the sidebar's single scroll view, so
  /// it must not contain its own unbounded scrollables / Expanded widgets.
  final WidgetBuilder builder;
}

/// Intro "screen raiser" / curtain shown before the lab starts.
class _rt_IntroConfig {
  const _rt_IntroConfig({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    this.icon = Icons.science,
    this.footnote,
    this.buttonIcon = Icons.fingerprint,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final IconData icon;
  final IconData buttonIcon;
  final String? footnote;
}

/// Colours of one activity (header/footer gradient + accent).
class _rt_ShellTheme {
  const _rt_ShellTheme({
    this.accent = _rt_Tw.teal600,
    this.headerGradient = const [_rt_Tw.slate900, _rt_Tw.teal900],
    this.headerSubtitleColor = _rt_Tw.teal200,
  });

  final Color accent;
  final List<Color> headerGradient;
  final Color headerSubtitleColor;
}

/// Current-step hint shown at the bottom of the canvas when the sidebar is
/// collapsed (the HTML `#step-hint-box`).
class _rt_StepHint {
  const _rt_StepHint({required this.number, required this.text, this.label});

  final String number;
  final String text;
  final String? label;
}

/// Lets an activity show toasts and popups through the shell.
class _rt_ShellController {
  _ActivityShellState? _state;

  /// Top-right toast (the HTML `showToast`).
  void showToast(String message,
      {Color color = _rt_Tw.green500, IconData icon = Icons.check, int ms = 3000}) {
    _state?._showToast(message, color, icon, ms);
  }

  /// Scrollable success popup with sound.
  ///
  /// Completes with true when its button was pressed (false when it was
  /// dismissed by tapping outside or Back). [onClose] runs after any
  /// dismissal, [onConfirm] only after the button: use it for actions such as
  /// restarting the lab, which a stray tap outside must not trigger.
  Future<bool> showSuccess({
    required String title,
    String? message,
    Widget? body,
    String? buttonLabel,
    IconData icon = Icons.emoji_events,
    Color color = _rt_Tw.green500,
    VoidCallback? onClose,
    VoidCallback? onConfirm,
    _rt_Sfx sound = _rt_Sfx.success,
  }) async {
    final ctx = _state?.context;
    if (ctx == null) return false;
    _rt_playSfx(sound);
    final confirmed = await _rt_showShellPopup(
      ctx,
      title: title,
      message: message,
      body: body,
      icon: icon,
      color: color,
      buttonLabel: buttonLabel ?? _rt_CommonStrings.continueLabel,
    );
    onClose?.call();
    if (confirmed) onConfirm?.call();
    return confirmed;
  }

  bool get isSidebarOpen => _state?._isSidebarOpen ?? true;

  void setSidebarOpen(bool open) => _state?._setSidebar(open);

  /// Switches the sidebar to tab [index] (HTML `switchTab`).
}

/// Scrollable popup used for success / feedback / info dialogs.
///
/// The card can be dragged anywhere on screen (the sources' panels are
/// draggable too), so an observation never has to hide the simulation behind
/// it. It is clamped so it can always be grabbed again.
///
/// Completes with true when the default button was pressed.
Future<bool> _rt_showShellPopup(
  BuildContext context, {
  required String title,
  String? message,
  Widget? body,
  IconData icon = Icons.emoji_events,
  Color color = _rt_Tw.green500,
  String? buttonLabel,
  List<Widget>? actions,
  bool barrierDismissible = true,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    // A lighter scrim: the point of moving the card is to watch the canvas.
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (ctx) => _DraggablePopup(
      title: title,
      message: message,
      body: body,
      icon: icon,
      color: color,
      buttonLabel: buttonLabel,
      actions: actions,
    ),
  );
  return confirmed == true;
}

class _DraggablePopup extends StatefulWidget {
  const _DraggablePopup({
    required this.title,
    this.message,
    this.body,
    required this.icon,
    required this.color,
    this.buttonLabel,
    this.actions,
  });

  final String title;
  final String? message;
  final Widget? body;
  final IconData icon;
  final Color color;
  final String? buttonLabel;
  final List<Widget>? actions;

  @override
  State<_DraggablePopup> createState() => _DraggablePopupState();
}

class _DraggablePopupState extends State<_DraggablePopup> {
  /// Offset from the centred resting position.
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Landscape phones are short: cap the card and let its content scroll.
    final maxW = math.min(520.0, size.width - 32);
    final maxH = size.height * 0.86;
    // Keep at least a corner of the card on screen at all times.
    final limitX = math.max(0.0, (size.width - maxW) / 2 + maxW / 2 - 40);
    final limitY = math.max(0.0, (size.height - maxH) / 2 + maxH / 2 - 40);

    // Kept as a real Dialog so `find.byType(Dialog)` and the usual dialog
    // semantics keep working; the drag lives inside it.
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: EdgeInsets.zero,
      child: Transform.translate(
        offset: _offset,
        child: Material(
          color: _rt_Lab.surface,
          elevation: 12,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW, maxHeight: maxH),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle strip along the top of the card.
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (d) => setState(() {
                    _offset = Offset(
                      (_offset.dx + d.delta.dx).clamp(-limitX, limitX),
                      (_offset.dy + d.delta.dy).clamp(-limitY, limitY),
                    );
                  }),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    color: _rt_Lab.overlay,
                    alignment: Alignment.center,
                    child: Container(
                      width: 46,
                      height: 4,
                      decoration: BoxDecoration(
                        color: _rt_Lab.borderStrong,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: widget.color.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(color: widget.color, width: 3),
                          ),
                          child: Icon(widget.icon, color: widget.color, size: 34),
                        ),
                        const SizedBox(height: 12),
                        Text(widget.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w900, color: _rt_Lab.text)),
                        if (widget.message != null) ...[
                          const SizedBox(height: 8),
                          Text(widget.message!,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 14, color: _rt_Lab.textMuted, height: 1.4)),
                        ],
                        if (widget.body != null) ...[
                          const SizedBox(height: 12),
                          widget.body!,
                        ],
                        const SizedBox(height: 16),
                        if (widget.actions != null)
                          Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: widget.actions!)
                        else
                          _rt_ActionButton(
                            label: widget.buttonLabel ?? _rt_CommonStrings.close,
                            icon: Icons.check,
                            color: widget.color,
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Standard landscape activity layout:
///
/// * left sidebar = 300 px wide (screen width on narrower screens), slides over the canvas, fully
///   scrollable, holding header, tabs (with all step buttons) and footer;
/// * fixed menu button (top-left) toggling the sidebar, drawn above it;
/// * responsive centre canvas with zoom / reset toolbar, HUD overlays,
///   toasts and current-step hint;
/// * optional intro curtain.
class _rt_ActivityShell extends StatefulWidget {
  const _rt_ActivityShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.tabs,
    required this.canvas,
    required this.onRestart,
    this.controller,
    this.theme = const _rt_ShellTheme(),
    this.intro,
    this.onStart,
    this.canvasOverlays = const [],
    this.onZoomIn,
    this.onZoomOut,
    this.onResetView,
    this.toolbarExtras = const [],
    this.hint,
    this.initialTab = 0,
    this.onTabChanged,
    this.sidebarTop,
    this.canvasBackground,
  });

  final String title;
  final String subtitle;
  final List<_rt_ShellTab> tabs;

  /// The activity (usually a _rt_Scene3DView). Fills the area right of the
  /// sidebar and resizes responsively when the sidebar opens/closes.
  final Widget canvas;

  /// Extra widgets stacked over the canvas (HUD, legends, overlays). Use
  /// Positioned / Align children.
  final List<Widget> canvasOverlays;

  final VoidCallback onRestart;
  final _rt_ShellController? controller;
  final _rt_ShellTheme theme;
  final _rt_IntroConfig? intro;
  final VoidCallback? onStart;

  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onResetView;
  final List<Widget> toolbarExtras;

  final _rt_StepHint? hint;

  /// Ignored: the sidebar always shows the first (experiment) tab.
  final int initialTab;

  /// Ignored: there is no tab bar to switch with.
  final ValueChanged<int>? onTabChanged;

  /// Optional content above the tabs (e.g. scenario selector).
  final Widget? sidebarTop;
  final Color? canvasBackground;

  @override
  State<_rt_ActivityShell> createState() => _ActivityShellState();
}

class _ActivityShellState extends State<_rt_ActivityShell> with TickerProviderStateMixin {
  bool _isSidebarOpen = true;
  double _sidebarWidth = _rt_rememberedSidebarWidth;
  bool _isResizing = false;

  late bool _introVisible = widget.intro != null;
  late final AnimationController _curtain =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
  late final AnimationController _introContent =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500));

  String? _toast;
  Color _toastColor = _rt_Tw.green500;
  IconData _toastIcon = Icons.check;
  Timer? _toastTimer;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
  }

  /// The sidebar shows only the experiment tab -- the one carrying the steps
  /// needed to complete the activity. Every activity declares it first.
  _rt_ShellTab get _primaryTab => widget.tabs.first;

  @override
  void didUpdateWidget(_rt_ActivityShell old) {
    super.didUpdateWidget(old);
    widget.controller?._state = this;
  }

  @override
  void dispose() {
    if (widget.controller?._state == this) widget.controller?._state = null;
    _toastTimer?.cancel();
    _curtain.dispose();
    _introContent.dispose();
    _rt_SoundService.instance.stop(_rt_Sfx.curtain);
    super.dispose();
  }

  void _setSidebar(bool open) {
    if (open == _isSidebarOpen) return;
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _isSidebarOpen = open);
  }

  void _showToast(String m, Color c, IconData i, int ms) {
    _toastTimer?.cancel();
    setState(() {
      _toast = m;
      _toastColor = c;
      _toastIcon = i;
    });
    _toastTimer = Timer(Duration(milliseconds: ms), () {
      if (mounted) setState(() => _toast = null);
    });
  }

  Future<void> _start() async {
    _rt_playSfx(_rt_Sfx.click);
    await _introContent.forward();
    _rt_playSfx(_rt_Sfx.curtain, volume: 0.8);
    await _curtain.forward();
    _rt_SoundService.instance.stop(_rt_Sfx.curtain);
    if (mounted) setState(() => _introVisible = false);
    widget.onStart?.call();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    // Phones narrower than the minimum keep the old full-bleed sidebar and
    // cannot be resized -- there is no canvas left to trade width with.
    final isNarrow = size.width < _rt_kSidebarDefaultWidth;
    final maxWidth = math.min(_rt_kSidebarMaxWidth, size.width * 0.85);
    final sidebarWidth = isNarrow ? size.width : _sidebarWidth.clamp(_rt_kSidebarMinWidth, maxWidth);
    // Follow the finger exactly while dragging; animate only open/close.
    final dur = _isResizing ? Duration.zero : const Duration(milliseconds: 300);
    const curve = Curves.easeOutCubic;

    return _KeyboardLift(child: Scaffold(
      backgroundColor: widget.canvasBackground ?? _rt_Lab.canvas,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // ---------------------------------------------------- canvas ---
          AnimatedPositioned(
            duration: dur,
            curve: curve,
            left: _isSidebarOpen ? sidebarWidth : 0,
            top: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(child: _buildCanvasArea()),
          ),

          // --------------------------------------------------- sidebar ---
          AnimatedPositioned(
            duration: dur,
            curve: curve,
            left: _isSidebarOpen ? 0 : -sidebarWidth - 12,
            top: 0,
            bottom: 0,
            width: sidebarWidth,
            child: Stack(
              children: [
                Positioned.fill(child: _buildSidebar()),
                if (!isNarrow)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    // 12px matches the sidebar's content gutter, so the strip
                    // never sits on top of a full-width control.
                    width: 12,
                    child: _buildResizeHandle(sidebarWidth, maxWidth),
                  ),
              ],
            ),
          ),

          // Menu button: fixed position, above the sidebar.
          Positioned(
            top: 16,
            left: 16, // Fixed position, won't slide with sidebar
            child: IconButton(
              icon: Icon(_isSidebarOpen ? Icons.menu_open : Icons.menu),
              color: Colors.orangeAccent,
              iconSize: 28,
              onPressed: () {
                HapticFeedback.lightImpact();
                _rt_playSfx(_rt_Sfx.toggle);
                setState(() {
                  _isSidebarOpen = !_isSidebarOpen;
                });
              },
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.orange.withValues(alpha: 0.8)),
                ),
              ),
            ),
          ),

          if (_introVisible && widget.intro != null) _buildIntro(widget.intro!),

          // Back button: mirrors the menu button on the opposite corner. Last
          // in the stack so it stays tappable while the intro curtain is up.
          const Positioned(
            top: 16,
            right: 16,
            child: _rt_FloatingBackButton(),
          ),
        ],
      ),
    ));
  }

  // ------------------------------------------------------------ canvas ----
  Widget _buildCanvasArea() {
    final hasToolbar = widget.onZoomIn != null ||
        widget.onZoomOut != null ||
        widget.onResetView != null ||
        widget.toolbarExtras.isNotEmpty;
    return Stack(
      children: [
        Positioned.fill(child: widget.canvas),
        ...widget.canvasOverlays,
        if (hasToolbar)
          // Starts below the floating back button in the shell's outer Stack.
          Positioned(top: 68, right: 10, child: _buildToolbar()),
        // Toast (below HUDs, left of the vertical toolbar)
        Positioned(
          top: 140,
          right: hasToolbar ? 66 : 16,
          child: IgnorePointer(
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 300),
              offset: _toast == null ? const Offset(0.3, 0) : Offset.zero,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _toast == null ? 0 : 1,
                child: _buildToast(),
              ),
            ),
          ),
        ),
        // Current-step hint (visible while the sidebar is collapsed).
        if (widget.hint != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: IgnorePointer(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 400),
                opacity: _isSidebarOpen ? 0 : 1,
                child: Center(child: _buildHint(widget.hint!)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildToolbar() {
    Widget btn(IconData icon, String tip, VoidCallback? onTap) => Tooltip(
          message: tip,
          child: InkResponse(
            onTap: onTap == null
                ? null
                : () {
                    _rt_playSfx(_rt_Sfx.tap);
                    onTap();
                  },
            radius: 22,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: _rt_Lab.surface, shape: BoxShape.circle),
              child: Icon(icon, size: 18, color: _rt_Lab.textMuted),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 10)],
      ),
      // Vertical strip on the right edge keeps the top of the canvas free
      // for HUD overlays on narrow phones.
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...widget.toolbarExtras,
          if (widget.toolbarExtras.isNotEmpty) _divider(),
          if (widget.onZoomIn != null) btn(Icons.add, _rt_CommonStrings.zoomIn, widget.onZoomIn),
          if (widget.onZoomOut != null) ...[
            const SizedBox(height: 4),
            btn(Icons.remove, _rt_CommonStrings.zoomOut, widget.onZoomOut),
          ],
          if (widget.onResetView != null) ...[
            _divider(),
            btn(Icons.center_focus_strong, _rt_CommonStrings.resetView, widget.onResetView),
          ],
        ],
      ),
    );
  }

  Widget _divider() => Container(
      width: 24, height: 1, margin: const EdgeInsets.symmetric(vertical: 6), color: _rt_Lab.border);

  Widget _buildToast() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: _toastColor, width: 6)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 16)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(color: _toastColor.withValues(alpha: 0.15), shape: BoxShape.circle),
          child: Icon(_toastIcon, size: 16, color: _toastColor),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(_toast ?? '',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: _rt_Lab.text)),
        ),
      ]),
    );
  }

  Widget _buildHint(_rt_StepHint h) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 560),
      margin: const EdgeInsets.symmetric(horizontal: 90),
      padding: const EdgeInsets.fromLTRB(14, 10, 16, 10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
        border: Border(left: BorderSide(color: widget.theme.accent, width: 6)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 16)],
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _rt_Lab.tinted(
                Color.lerp(widget.theme.accent, Colors.white, 0.85)!, widget.theme.accent),
            shape: BoxShape.circle,
            border: Border.all(color: _rt_Lab.tintedBorder(widget.theme.accent), width: 2),
          ),
          child: Text(h.number,
              style: TextStyle(fontWeight: FontWeight.w900, color: widget.theme.accent, fontSize: 15)),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
            Text((h.label ?? _rt_CommonStrings.currentStep).toUpperCase(),
                style: TextStyle(
                    fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: widget.theme.accent)),
            Text(h.text,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _rt_Lab.text, height: 1.25)),
          ]),
        ),
      ]),
    );
  }

  // ----------------------------------------------------------- sidebar ----
  /// Grab strip on the sidebar's trailing edge. Drag to resize, double-tap to
  /// restore the default width.
  Widget _buildResizeHandle(double currentWidth, double maxWidth) {
    void commit() {
      _rt_rememberedSidebarWidth = _sidebarWidth;
    }

    return MouseRegion(
      key: const Key('sidebarResizeHandle'),
      cursor: SystemMouseCursors.resizeLeftRight,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        // Start from the width actually on screen, so a clamped value does not
        // make the sidebar jump on the first drag pixel.
        onHorizontalDragStart: (_) => setState(() {
          _sidebarWidth = currentWidth;
          _isResizing = true;
        }),
        onHorizontalDragUpdate: (d) => setState(() {
          _sidebarWidth = (_sidebarWidth + d.delta.dx).clamp(_rt_kSidebarMinWidth, maxWidth);
        }),
        onHorizontalDragEnd: (_) {
          commit();
          setState(() => _isResizing = false);
          _rt_playSfx(_rt_Sfx.tap);
        },
        onHorizontalDragCancel: () {
          commit();
          setState(() => _isResizing = false);
        },
        onDoubleTap: () {
          setState(() => _sidebarWidth = _rt_kSidebarDefaultWidth.clamp(_rt_kSidebarMinWidth, maxWidth));
          commit();
          _rt_playSfx(_rt_Sfx.toggle);
        },
        child: Tooltip(
          message: _rt_CommonStrings.resizeSidebar,
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 6,
              height: 56,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: _isResizing ? widget.theme.accent : _rt_Tw.gray400.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSidebar() {
    final t = widget.theme;
    return Material(
      elevation: 16,
      color: _rt_Lab.base.withValues(alpha: 0.99),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
            // Header (title, subtitle, language + restart buttons).
            Container(
              padding: const EdgeInsets.fromLTRB(12, 76, 12, 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: t.headerGradient),
                border: Border(bottom: BorderSide(color: t.accent, width: 4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: const TextStyle(
                          fontSize: 17, fontWeight: FontWeight.w900, color: Colors.white, height: 1.15)),
                  const SizedBox(height: 4),
                  Text(widget.subtitle,
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.w700, color: t.headerSubtitleColor)),
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    _headerButton(
                      icon: Icons.translate,
                      label: _rt_CommonStrings.langButton,
                      tooltip: _rt_CommonStrings.switchLanguage,
                      onTap: () {
                        _rt_playSfx(_rt_Sfx.click);
                        _rt_appLanguage.toggle();
                      },
                    ),
                    _headerButton(
                      icon: Icons.refresh,
                      label: _rt_CommonStrings.restart,
                      filled: true,
                      onTap: () {
                        _rt_playSfx(_rt_Sfx.scenario);
                        widget.onRestart();
                      },
                    ),
                  ]),
                ],
              ),
            ),
            ?widget.sidebarTop,
            // Active tab body
            Container(
              color: _rt_Lab.base,
              constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 0.4),
              child: Builder(builder: _primaryTab.builder),
            ),
                ],
              ),
            ),
          ),
          // Footer: pinned to the bottom, outside the scroll view.
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: t.headerGradient),
              border: Border(top: BorderSide(color: t.accent)),
            ),
            // The footer sits on the fixed dark header gradient, so its text
            // stays white in both themes rather than following _rt_Lab.text.
            child: Text(
              _rt_CommonStrings.footer,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    String? tooltip,
    bool filled = false,
  }) {
    final btn = Material(
      color: filled ? widget.theme.accent : Colors.white.withValues(alpha: 0.12),
      shape: StadiumBorder(side: BorderSide(color: Colors.white.withValues(alpha: 0.25))),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(label,
                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
          ]),
        ),
      ),
    );
    return tooltip == null ? btn : Tooltip(message: tooltip, child: btn);
  }


  // ------------------------------------------------------------- intro ----
  Widget _buildIntro(_rt_IntroConfig intro) {
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge([_curtain, _introContent]),
        builder: (context, _) {
          final shutter = Curves.easeInOutCubic.transform(_curtain.value);
          final content = _introContent.value;
          return Stack(
            children: [
              // Heavy shutter panel sliding up.
              FractionalTranslation(
                translation: Offset(0, -1.05 * shutter),
                child: const _ShutterPanel(),
              ),
              if (content < 1)
                Center(
                  child: Opacity(
                    opacity: 1 - content,
                    child: Transform.translate(
                      offset: Offset(0, 20 * content),
                      child: Transform.scale(
                        scale: 1 - 0.1 * content,
                        child: _introCard(intro),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _introCard(_rt_IntroConfig intro) {
    final accent = widget.theme.accent;
    final size = MediaQuery.sizeOf(context);
    // Compact variant for short landscape phones.
    final compact = size.height < 480;
    final gap = compact ? 8.0 : 18.0;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: compact ? 420 : 460, maxHeight: size.height - 16),
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: _rt_Lab.surface.withValues(alpha: 0.97),
          borderRadius: BorderRadius.circular(compact ? 22 : 30),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 50, offset: const Offset(0, 25))],
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: compact ? 22 : 28, vertical: compact ? 14 : 28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Transform.rotate(
              angle: -0.1,
              child: Container(
                width: compact ? 52 : 76,
                height: compact ? 52 : 76,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [accent, _rt_Tw.slate800],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(compact ? 16 : 22),
                  border: Border.all(color: Colors.white, width: compact ? 3 : 4),
                  boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 20)],
                ),
                child: Icon(intro.icon, color: Colors.white, size: compact ? 28 : 40),
              ),
            ),
            SizedBox(height: gap),
            Text(intro.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: compact ? 21 : 26, fontWeight: FontWeight.w900, color: _rt_Lab.text)),
            const SizedBox(height: 4),
            Text(intro.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: compact ? 13 : 15, fontWeight: FontWeight.w700, color: _rt_Tw.slate500)),
            SizedBox(height: gap + 4),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: _rt_Tw.slate900,
                  padding: EdgeInsets.symmetric(vertical: compact ? 12 : 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _introContent.isAnimating ? null : _start,
                icon: Icon(intro.buttonIcon, color: _rt_Tw.teal400),
                label: Text(intro.buttonLabel,
                    style: TextStyle(fontSize: compact ? 15 : 17, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
            ),
            if (intro.footnote != null) ...[
              SizedBox(height: compact ? 8 : 14),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.shield_outlined, size: 12, color: _rt_Tw.slate400),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(intro.footnote!.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: _rt_Tw.slate400)),
                ),
              ]),
            ],
          ]),
        ),
      ),
    );
  }
}

/// Slides the activity up while the soft keyboard covers a focused text field
/// inside it, far enough to show the field and the button usually below it.
///
/// The shell keeps its size when the keyboard opens (a landscape phone has no
/// height to re-lay out a lab into), so without this the keyboard hid the
/// calculator inputs drawn over the canvas. A paint offset leaves the layout
/// untouched; dialogs are separate routes and already avoid the keyboard.
class _KeyboardLift extends StatefulWidget {
  const _KeyboardLift({required this.child});

  final Widget child;

  @override
  State<_KeyboardLift> createState() => _KeyboardLiftState();
}

class _KeyboardLiftState extends State<_KeyboardLift> {
  /// Room kept below the field for its action button.
  static const double _buttonRoom = 64;

  double _lift = 0;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.addListener(_schedule);
  }

  @override
  void dispose() {
    FocusManager.instance.removeListener(_schedule);
    super.dispose();
  }

  void _schedule() => WidgetsBinding.instance.addPostFrameCallback((_) => _measure());

  /// Runs after layout: the field's position is only known then.
  void _measure() {
    if (!mounted) return;
    final keyboard = MediaQuery.viewInsetsOf(context).bottom;
    final focus = FocusManager.instance.primaryFocus;
    final field = focus?.context;
    var lift = 0.0;
    if (keyboard > 0 &&
        field != null &&
        field.mounted &&
        field.findAncestorStateOfType<_KeyboardLiftState>() == this) {
      // Measured with the current lift applied: undo it.
      final r = focus!.rect.shift(Offset(0, _lift));
      final keyboardTop = MediaQuery.sizeOf(context).height - keyboard;
      lift = (r.bottom + _buttonRoom - keyboardTop).clamp(0.0, math.max(0.0, r.top - 8));
    }
    if ((lift - _lift).abs() > 0.5) setState(() => _lift = lift);
  }

  @override
  Widget build(BuildContext context) {
    // Rebuilt on every keyboard animation frame through the inset dependency.
    if (MediaQuery.viewInsetsOf(context).bottom > 0 || _lift > 0) _schedule();
    return Transform.translate(offset: Offset(0, -_lift), child: widget.child);
  }
}

/// Dark mechanical shutter.
class _ShutterPanel extends StatelessWidget {
  const _ShutterPanel();

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(painter: _ShutterPainter()),
    );
  }
}

class _ShutterPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Slats: repeating 42px bands.
    for (var y = 0.0; y < size.height; y += 42) {
      final band = Rect.fromLTWH(0, y, size.width, 42);
      canvas.drawRect(
        band,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_rt_Tw.slate900, _rt_Tw.slate800, _rt_Tw.slate700, _rt_Tw.slate950],
            stops: [0, 0.48, 0.96, 1],
          ).createShader(band),
      );
    }
    // Side shading.
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = LinearGradient(colors: [
          Colors.black.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.05),
          Colors.black.withValues(alpha: 0.4),
        ]).createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


/// Mutable 3D vector (mirrors the parts of THREE.Vector3 the activities use).
class _rt_V3 {
  _rt_V3([this.x = 0, this.y = 0, this.z = 0]);

  factory _rt_V3.zero() => _rt_V3();
  factory _rt_V3.all(double v) => _rt_V3(v, v, v);

  double x, y, z;

  _rt_V3 clone() => _rt_V3(x, y, z);

  _rt_V3 set(double nx, double ny, double nz) {
    x = nx;
    y = ny;
    z = nz;
    return this;
  }

  _rt_V3 copy(_rt_V3 o) => set(o.x, o.y, o.z);

  _rt_V3 operator +(_rt_V3 o) => _rt_V3(x + o.x, y + o.y, z + o.z);
  _rt_V3 operator -(_rt_V3 o) => _rt_V3(x - o.x, y - o.y, z - o.z);
  _rt_V3 operator *(double s) => _rt_V3(x * s, y * s, z * s);
  _rt_V3 operator /(double s) => _rt_V3(x / s, y / s, z / s);
  _rt_V3 operator -() => _rt_V3(-x, -y, -z);

  _rt_V3 add(_rt_V3 o) => set(x + o.x, y + o.y, z + o.z);
  _rt_V3 sub(_rt_V3 o) => set(x - o.x, y - o.y, z - o.z);
  _rt_V3 scaleBy(double s) => set(x * s, y * s, z * s);
  _rt_V3 addScaled(_rt_V3 o, double s) => set(x + o.x * s, y + o.y * s, z + o.z * s);

  double dot(_rt_V3 o) => x * o.x + y * o.y + z * o.z;
  _rt_V3 cross(_rt_V3 o) => _rt_V3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);

  double get length => math.sqrt(x * x + y * y + z * z);
  double get lengthSq => x * x + y * y + z * z;
  double distanceTo(_rt_V3 o) => (this - o).length;

  _rt_V3 normalized() {
    final l = length;
    return l == 0 ? _rt_V3() : _rt_V3(x / l, y / l, z / l);
  }

  _rt_V3 normalize() {
    final l = length;
    if (l != 0) scaleBy(1 / l);
    return this;
  }

  _rt_V3 lerp(_rt_V3 to, double t) =>
      _rt_V3(x + (to.x - x) * t, y + (to.y - y) * t, z + (to.z - z) * t);

  _rt_V3 lerpTo(_rt_V3 to, double t) =>
      set(x + (to.x - x) * t, y + (to.y - y) * t, z + (to.z - z) * t);

  @override
  String toString() =>
      '_rt_V3(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)}, ${z.toStringAsFixed(2)})';
}

/// 3x3 matrix, row-major.
class _rt_M3 {
  _rt_M3(this.m);

  factory _rt_M3.identity() => _rt_M3([1, 0, 0, 0, 1, 0, 0, 0, 1]);

  /// Rotation matching THREE.Euler order 'XYZ': R = Rx * Ry * Rz.
  factory _rt_M3.eulerXYZ(double ax, double ay, double az) {
    final a = math.cos(ax), b = math.sin(ax);
    final c = math.cos(ay), d = math.sin(ay);
    final e = math.cos(az), f = math.sin(az);
    final ae = a * e, af = a * f, be = b * e, bf = b * f;
    return _rt_M3([
      c * e, -c * f, d, //
      af + be * d, ae - bf * d, -b * c,
      bf - ae * d, be + af * d, a * c,
    ]);
  }

  /// Rotation around an arbitrary unit [axis] by [angle].
  factory _rt_M3.axisAngle(_rt_V3 axis, double angle) {
    final n = axis.normalized();
    final c = math.cos(angle), s = math.sin(angle), t = 1 - c;
    final x = n.x, y = n.y, z = n.z;
    return _rt_M3([
      t * x * x + c, t * x * y - s * z, t * x * z + s * y, //
      t * x * y + s * z, t * y * y + c, t * y * z - s * x,
      t * x * z - s * y, t * y * z + s * x, t * z * z + c,
    ]);
  }

  /// Rotation that maps the unit vector [from] onto [to]
  /// (like THREE.Quaternion.setFromUnitVectors).
  factory _rt_M3.fromUnitVectors(_rt_V3 from, _rt_V3 to) {
    final f = from.normalized(), t = to.normalized();
    final d = f.dot(t);
    if (d > 0.999999) return _rt_M3.identity();
    if (d < -0.999999) {
      var axis = _rt_V3(1, 0, 0).cross(f);
      if (axis.length < 1e-6) axis = _rt_V3(0, 1, 0).cross(f);
      return _rt_M3.axisAngle(axis, math.pi);
    }
    return _rt_M3.axisAngle(f.cross(t), math.acos(d.clamp(-1.0, 1.0)));
  }

  final List<double> m;

  _rt_M3 operator *(_rt_M3 o) {
    final r = List<double>.filled(9, 0);
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        r[i * 3 + j] =
            m[i * 3] * o.m[j] + m[i * 3 + 1] * o.m[3 + j] + m[i * 3 + 2] * o.m[6 + j];
      }
    }
    return _rt_M3(r);
  }

  _rt_V3 apply(_rt_V3 v) => _rt_V3(
        m[0] * v.x + m[1] * v.y + m[2] * v.z,
        m[3] * v.x + m[4] * v.y + m[5] * v.z,
        m[6] * v.x + m[7] * v.y + m[8] * v.z,
      );

  _rt_M3 scaled(_rt_V3 s) => _rt_M3([
        m[0] * s.x, m[1] * s.y, m[2] * s.z, //
        m[3] * s.x, m[4] * s.y, m[5] * s.z,
        m[6] * s.x, m[7] * s.y, m[8] * s.z,
      ]);
}

/// Affine transform: p' = m * p + t.
class _rt_Xf {
  _rt_Xf(this.m, this.t);

  factory _rt_Xf.identity() => _rt_Xf(_rt_M3.identity(), _rt_V3());

  final _rt_M3 m;
  final _rt_V3 t;

  _rt_V3 apply(_rt_V3 p) {
    final r = m.apply(p);
    return r..add(t);
  }

  _rt_Xf operator *(_rt_Xf o) => _rt_Xf(m * o.m, m.apply(o.t)..add(t));

  /// Approximate uniform scale factor (used for sphere / label sizes).
  double get maxScale {
    final sx = math.sqrt(m.m[0] * m.m[0] + m.m[3] * m.m[3] + m.m[6] * m.m[6]);
    final sy = math.sqrt(m.m[1] * m.m[1] + m.m[4] * m.m[4] + m.m[7] * m.m[7]);
    final sz = math.sqrt(m.m[2] * m.m[2] + m.m[5] * m.m[5] + m.m[8] * m.m[8]);
    return math.max(sx, math.max(sy, sz));
  }
}

double _rt_degToRad(double d) => d * math.pi / 180;
double _rt_radToDeg(double r) => r * 180 / math.pi;

/// Easing helpers matching the curves used in the HTML activities.
class _rt_Ease {
  static double linear(double t) => t;
  static double outCubic(double t) => 1 - math.pow(1 - t, 3).toDouble();
  static double inCubic(double t) => t * t * t;
  static double inOutCubic(double t) =>
      t < 0.5 ? 4 * t * t * t : 1 - math.pow(-2 * t + 2, 3).toDouble() / 2;
  static double inOutQuad(double t) =>
      t < 0.5 ? 2 * t * t : 1 - math.pow(-2 * t + 2, 2).toDouble() / 2;
  static double outQuad(double t) => 1 - (1 - t) * (1 - t);
  static double inQuad(double t) => t * t;
  static double outBack(double t) {
    const c1 = 1.70158, c3 = c1 + 1;
    return 1 + c3 * math.pow(t - 1, 3) + c1 * math.pow(t - 1, 2);
  }

  static double outBounce(double t) {
    const n1 = 7.5625, d1 = 2.75;
    if (t < 1 / d1) return n1 * t * t;
    if (t < 2 / d1) return n1 * (t -= 1.5 / d1) * t + 0.75;
    if (t < 2.5 / d1) return n1 * (t -= 2.25 / d1) * t + 0.9375;
    return n1 * (t -= 2.625 / d1) * t + 0.984375;
  }

  static double outElastic(double t) {
    const c4 = (2 * math.pi) / 3;
    if (t == 0 || t == 1) return t;
    return math.pow(2, -10 * t) * math.sin((t * 10 - 0.75) * c4) + 1;
  }
}




/// Polygon mesh. Faces are lists of vertex indices wound counter-clockwise
/// when viewed from the outside (same convention as three.js), so the face
/// normal points outward.
///
/// Builders mirror the three.js geometry constructors and their axes:
/// cylinders/cones/lathes stand on the Y axis, planes/circles/rings/torus lie
/// in the XY plane facing +Z.
class _rt_Geometry3D {
  _rt_Geometry3D(this.vertices, this.faces, [this.faceGroups]);

  final List<_rt_V3> vertices;
  final List<List<int>> faces;

  /// Optional material index per face (for per-face colours, e.g. dice/boxes).
  final List<int>? faceGroups;

  /// Merges several geometries, each placed with its own transform.
  factory _rt_Geometry3D.merge(List<(_rt_Geometry3D, _rt_Xf)> parts) {
    final verts = <_rt_V3>[];
    final faces = <List<int>>[];
    for (final (g, xf) in parts) {
      final base = verts.length;
      verts.addAll(g.vertices.map(xf.apply));
      faces.addAll(g.faces.map((f) => f.map((i) => i + base).toList()));
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.BoxGeometry(w, h, d). Face groups: 0 +x, 1 -x, 2 +y, 3 -y, 4 +z, 5 -z
  /// (the three.js material-array order).
  factory _rt_Geometry3D.box(double w, double h, double d) {
    final x = w / 2, y = h / 2, z = d / 2;
    final v = [
      _rt_V3(-x, -y, -z), _rt_V3(x, -y, -z), _rt_V3(x, y, -z), _rt_V3(-x, y, -z), //
      _rt_V3(-x, -y, z), _rt_V3(x, -y, z), _rt_V3(x, y, z), _rt_V3(-x, y, z),
    ];
    return _rt_Geometry3D(v, [
      [5, 1, 2, 6], // +x
      [0, 4, 7, 3], // -x
      [7, 6, 2, 3], // +y
      [0, 1, 5, 4], // -y
      [4, 5, 6, 7], // +z
      [1, 0, 3, 2], // -z
    ], [0, 1, 2, 3, 4, 5]);
  }

  /// THREE.CylinderGeometry(radiusTop, radiusBottom, height, radialSegments,
  /// heightSegments=1, openEnded, thetaStart, thetaLength).
  factory _rt_Geometry3D.cylinder(
    double radiusTop,
    double radiusBottom,
    double height, {
    int segments = 24,
    bool openEnded = false,
    double thetaStart = 0,
    double thetaLength = math.pi * 2,
  }) {
    final hy = height / 2;
    final verts = <_rt_V3>[];
    final faces = <List<int>>[];
    final full = (thetaLength - math.pi * 2).abs() < 1e-6;
    final count = full ? segments : segments + 1;
    for (var i = 0; i < count; i++) {
      final th = thetaStart + i / segments * thetaLength;
      final s = math.sin(th), c = math.cos(th);
      verts.add(_rt_V3(radiusTop * s, hy, radiusTop * c)); // top i -> 2i
      verts.add(_rt_V3(radiusBottom * s, -hy, radiusBottom * c)); // bottom -> 2i+1
    }
    for (var i = 0; i < segments; i++) {
      final a = i, b = full ? (i + 1) % segments : i + 1;
      faces.add([2 * a + 1, 2 * b + 1, 2 * b, 2 * a]);
    }
    if (!openEnded) {
      if (radiusTop > 0) {
        final top = [for (var i = 0; i < count; i++) 2 * i];
        if (!full) {
          verts.add(_rt_V3(0, hy, 0));
          top.insert(0, verts.length - 1);
        }
        faces.add(top);
      }
      if (radiusBottom > 0) {
        final bottom = [for (var i = count - 1; i >= 0; i--) 2 * i + 1];
        if (!full) {
          verts.add(_rt_V3(0, -hy, 0));
          bottom.add(verts.length - 1);
        }
        faces.add(bottom);
      }
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.ConeGeometry(radius, height, radialSegments).
  factory _rt_Geometry3D.cone(double radius, double height,
          {int segments = 24, bool openEnded = false}) =>
      _rt_Geometry3D.cylinder(0, radius, height, segments: segments, openEnded: openEnded);

  /// THREE.SphereGeometry(radius, widthSegments, heightSegments, phiStart,
  /// phiLength, thetaStart, thetaLength). Use for partial spheres (bowls,
  /// domes); full spheres render faster and smoother with [_rt_Sphere3D].
  factory _rt_Geometry3D.sphere(
    double radius, {
    int widthSegments = 20,
    int heightSegments = 14,
    double phiStart = 0,
    double phiLength = math.pi * 2,
    double thetaStart = 0,
    double thetaLength = math.pi,
  }) {
    final verts = <_rt_V3>[];
    final grid = <List<int>>[];
    for (var iy = 0; iy <= heightSegments; iy++) {
      final row = <int>[];
      final v = iy / heightSegments;
      for (var ix = 0; ix <= widthSegments; ix++) {
        final u = ix / widthSegments;
        final phi = phiStart + u * phiLength;
        final theta = thetaStart + v * thetaLength;
        verts.add(_rt_V3(
          -radius * math.cos(phi) * math.sin(theta),
          radius * math.cos(theta),
          radius * math.sin(phi) * math.sin(theta),
        ));
        row.add(verts.length - 1);
      }
      grid.add(row);
    }
    final faces = <List<int>>[];
    for (var iy = 0; iy < heightSegments; iy++) {
      for (var ix = 0; ix < widthSegments; ix++) {
        final a = grid[iy][ix + 1], b = grid[iy][ix];
        final c = grid[iy + 1][ix], d = grid[iy + 1][ix + 1];
        final theta0 = thetaStart + iy / heightSegments * thetaLength;
        final theta1 = thetaStart + (iy + 1) / heightSegments * thetaLength;
        if (theta0.abs() < 1e-9) {
          faces.add([a, c, d]); // top pole
        } else if ((theta1 - math.pi).abs() < 1e-9) {
          faces.add([a, b, c]); // bottom pole
        } else {
          faces.add([a, b, c, d]);
        }
      }
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.TorusGeometry(radius, tube, radialSegments, tubularSegments, arc).
  factory _rt_Geometry3D.torus(
    double radius,
    double tube, {
    int radialSegments = 10,
    int tubularSegments = 36,
    double arc = math.pi * 2,
  }) {
    final verts = <_rt_V3>[];
    for (var j = 0; j <= radialSegments; j++) {
      for (var i = 0; i <= tubularSegments; i++) {
        final u = i / tubularSegments * arc;
        final v = j / radialSegments * math.pi * 2;
        verts.add(_rt_V3(
          (radius + tube * math.cos(v)) * math.cos(u),
          (radius + tube * math.cos(v)) * math.sin(u),
          tube * math.sin(v),
        ));
      }
    }
    final faces = <List<int>>[];
    for (var j = 1; j <= radialSegments; j++) {
      for (var i = 1; i <= tubularSegments; i++) {
        final a = (tubularSegments + 1) * j + i - 1;
        final b = (tubularSegments + 1) * (j - 1) + i - 1;
        final c = (tubularSegments + 1) * (j - 1) + i;
        final d = (tubularSegments + 1) * j + i;
        faces.add([a, b, c, d]);
      }
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.PlaneGeometry(width, height, wSegs, hSegs) in the XY plane facing +Z.
  factory _rt_Geometry3D.plane(double width, double height,
      {int widthSegments = 1, int heightSegments = 1}) {
    final verts = <_rt_V3>[];
    for (var iy = 0; iy <= heightSegments; iy++) {
      for (var ix = 0; ix <= widthSegments; ix++) {
        verts.add(_rt_V3(-width / 2 + ix / widthSegments * width,
            -height / 2 + iy / heightSegments * height, 0));
      }
    }
    final faces = <List<int>>[];
    final w = widthSegments + 1;
    for (var iy = 0; iy < heightSegments; iy++) {
      for (var ix = 0; ix < widthSegments; ix++) {
        final a = iy * w + ix;
        faces.add([a, a + 1, a + 1 + w, a + w]);
      }
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.CircleGeometry(radius, segments, thetaStart, thetaLength), XY plane.
  factory _rt_Geometry3D.circle(double radius,
      {int segments = 32, double thetaStart = 0, double thetaLength = math.pi * 2}) {
    final full = (thetaLength - math.pi * 2).abs() < 1e-6;
    final verts = <_rt_V3>[];
    if (!full) verts.add(_rt_V3());
    final count = full ? segments : segments + 1;
    for (var i = 0; i < count; i++) {
      final th = thetaStart + i / segments * thetaLength;
      verts.add(_rt_V3(radius * math.cos(th), radius * math.sin(th), 0));
    }
    return _rt_Geometry3D(verts, [List.generate(verts.length, (i) => i)]);
  }

  /// THREE.RingGeometry(innerRadius, outerRadius, segments, ...), XY plane.
  factory _rt_Geometry3D.ring(double innerRadius, double outerRadius,
      {int segments = 32, double thetaStart = 0, double thetaLength = math.pi * 2}) {
    final verts = <_rt_V3>[];
    for (var i = 0; i <= segments; i++) {
      final th = thetaStart + i / segments * thetaLength;
      final c = math.cos(th), s = math.sin(th);
      verts.add(_rt_V3(outerRadius * c, outerRadius * s, 0)); // 2i
      verts.add(_rt_V3(innerRadius * c, innerRadius * s, 0)); // 2i+1
    }
    final faces = <List<int>>[];
    for (var i = 0; i < segments; i++) {
      faces.add([2 * i, 2 * (i + 1), 2 * (i + 1) + 1, 2 * i + 1]);
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.LatheGeometry(points, segments, phiStart, phiLength). Each point is
  /// (radius, y); list them bottom -> top for outward-facing normals.
  factory _rt_Geometry3D.lathe(List<Offset> points,
      {int segments = 24, double phiStart = 0, double phiLength = math.pi * 2}) {
    final verts = <_rt_V3>[];
    for (var i = 0; i <= segments; i++) {
      final phi = phiStart + i / segments * phiLength;
      final s = math.sin(phi), c = math.cos(phi);
      for (final p in points) {
        verts.add(_rt_V3(p.dx * s, p.dy, p.dx * c));
      }
    }
    final n = points.length;
    final faces = <List<int>>[];
    for (var i = 0; i < segments; i++) {
      for (var j = 0; j < n - 1; j++) {
        final a = i * n + j, b = a + n, c = a + n + 1, d = a + 1;
        faces.add([a, b, c, d]);
      }
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// Capsule standing on Y: total height = length + 2 * radius.
  factory _rt_Geometry3D.capsule(double radius, double length,
      {int segments = 16, int capSegments = 6}) {
    final pts = <Offset>[];
    for (var i = 0; i <= capSegments; i++) {
      final a = -math.pi / 2 + i / capSegments * math.pi / 2;
      pts.add(Offset(radius * math.cos(a), -length / 2 + radius * math.sin(a)));
    }
    for (var i = 0; i <= capSegments; i++) {
      final a = i / capSegments * math.pi / 2;
      pts.add(Offset(radius * math.cos(a), length / 2 + radius * math.sin(a)));
    }
    return _rt_Geometry3D.lathe(pts, segments: segments);
  }

  /// Extrudes a 2D polygon (XY, counter-clockwise) along +Z from 0 to [depth]
  /// (THREE.ExtrudeGeometry without bevel).
  factory _rt_Geometry3D.extrude(List<Offset> shape, double depth) {
    final n = shape.length;
    final verts = <_rt_V3>[
      for (final p in shape) _rt_V3(p.dx, p.dy, 0),
      for (final p in shape) _rt_V3(p.dx, p.dy, depth),
    ];
    final faces = <List<int>>[
      [for (var i = n - 1; i >= 0; i--) i], // back
      [for (var i = 0; i < n; i++) n + i], // front
      for (var i = 0; i < n; i++) [i, (i + 1) % n, n + (i + 1) % n, n + i],
    ];
    return _rt_Geometry3D(verts, faces);
  }

  /// Round tube following a polyline (THREE.TubeGeometry for wires, pipes).
  factory _rt_Geometry3D.tube(List<_rt_V3> path, double radius,
      {int radialSegments = 8, bool closed = false}) {
    final verts = <_rt_V3>[];
    final faces = <List<int>>[];
    var prevNormal = _rt_V3(0, 1, 0);
    for (var i = 0; i < path.length; i++) {
      final prev = path[i == 0 ? (closed ? path.length - 1 : 0) : i - 1];
      final next = path[i == path.length - 1 ? (closed ? 0 : i) : i + 1];
      var tangent = (next - prev).normalized();
      if (tangent.lengthSq == 0) tangent = _rt_V3(1, 0, 0);
      var normal = prevNormal - tangent * prevNormal.dot(tangent);
      if (normal.lengthSq < 1e-8) {
        normal = _rt_V3(0, 0, 1).cross(tangent);
        if (normal.lengthSq < 1e-8) normal = _rt_V3(1, 0, 0).cross(tangent);
      }
      normal.normalize();
      prevNormal = normal;
      final binormal = tangent.cross(normal);
      for (var j = 0; j < radialSegments; j++) {
        final a = j / radialSegments * math.pi * 2;
        verts.add(path[i] +
            normal * (radius * math.cos(a)) +
            binormal * (radius * math.sin(a)));
      }
    }
    final rings = closed ? path.length : path.length - 1;
    for (var i = 0; i < rings; i++) {
      final i2 = (i + 1) % path.length;
      for (var j = 0; j < radialSegments; j++) {
        final j2 = (j + 1) % radialSegments;
        faces.add([
          i * radialSegments + j,
          i * radialSegments + j2,
          i2 * radialSegments + j2,
          i2 * radialSegments + j,
        ]);
      }
    }
    return _rt_Geometry3D(verts, faces);
  }

  /// THREE.OctahedronGeometry(radius).
  factory _rt_Geometry3D.octahedron(double r) {
    final v = [_rt_V3(r, 0, 0), _rt_V3(-r, 0, 0), _rt_V3(0, r, 0), _rt_V3(0, -r, 0), _rt_V3(0, 0, r), _rt_V3(0, 0, -r)];
    return _rt_Geometry3D(v, [
      [0, 2, 4], [0, 4, 3], [0, 3, 5], [0, 5, 2], //
      [1, 2, 5], [1, 5, 3], [1, 3, 4], [1, 4, 2],
    ]);
  }

  /// THREE.TetrahedronGeometry(radius).
  factory _rt_Geometry3D.tetrahedron(double r) {
    final k = r / math.sqrt(3);
    final v = [_rt_V3(k, k, k), _rt_V3(-k, -k, k), _rt_V3(-k, k, -k), _rt_V3(k, -k, -k)];
    return _rt_Geometry3D(v, [
      [2, 1, 0], [0, 3, 2], [1, 3, 0], [2, 3, 1],
    ]);
  }

  /// THREE.IcosahedronGeometry(radius) (detail 0).
  factory _rt_Geometry3D.icosahedron(double r) {
    final t = (1 + math.sqrt(5)) / 2;
    final raw = [
      _rt_V3(-1, t, 0), _rt_V3(1, t, 0), _rt_V3(-1, -t, 0), _rt_V3(1, -t, 0), //
      _rt_V3(0, -1, t), _rt_V3(0, 1, t), _rt_V3(0, -1, -t), _rt_V3(0, 1, -t),
      _rt_V3(t, 0, -1), _rt_V3(t, 0, 1), _rt_V3(-t, 0, -1), _rt_V3(-t, 0, 1),
    ];
    final v = raw.map((p) => p.normalized()..scaleBy(r)).toList();
    return _rt_Geometry3D(v, [
      [0, 11, 5], [0, 5, 1], [0, 1, 7], [0, 7, 10], [0, 10, 11], //
      [1, 5, 9], [5, 11, 4], [11, 10, 2], [10, 7, 6], [7, 1, 8],
      [3, 9, 4], [3, 4, 2], [3, 2, 6], [3, 6, 8], [3, 8, 9],
      [4, 9, 5], [2, 4, 11], [6, 2, 10], [8, 6, 7], [9, 8, 1],
    ]);
  }
}





/// Surface appearance (covers MeshBasic / Lambert / Phong / Standard /
/// Physical materials closely enough for the activities).
class _rt_Material3D {
  _rt_Material3D({
    this.color = const Color(0xFFFFFFFF),
    this.opacity = 1.0,
    this.unlit = false,
    this.doubleSided = false,
    this.emissive,
    this.emissiveIntensity = 1.0,
    this.shininess = 0.0,
    this.metalness = 0.0,
    this.wireframe = false,
    this.edgeColor,
    this.edgeWidth = 1.0,
    this.faceColors,
    this.visible = true,
  });

  /// Base colour (THREE `color`).
  Color color;

  /// 0..1 (THREE `opacity` with `transparent: true`).
  double opacity;

  /// MeshBasicMaterial: ignores lights.
  bool unlit;

  /// THREE.DoubleSide.
  bool doubleSided;

  /// Glow colour added regardless of lighting.
  Color? emissive;
  double emissiveIntensity;

  /// 0..1 highlight strength (Phong/Standard shine; also sphere gloss).
  double shininess;

  /// 0..1 (MeshStandardMaterial `metalness`): darkens diffuse lighting.
  double metalness;

  /// Draws only polygon outlines.
  bool wireframe;

  /// Optional outline drawn around every face (EdgesGeometry look).
  Color? edgeColor;
  double edgeWidth;

  /// Per-face-group colours, e.g. box sides (THREE material arrays).
  List<Color>? faceColors;

  /// THREE `material.visible`.
  bool visible;

  _rt_Material3D copyWith({Color? color, double? opacity}) => _rt_Material3D(
        color: color ?? this.color,
        opacity: opacity ?? this.opacity,
        unlit: unlit,
        doubleSided: doubleSided,
        emissive: emissive,
        emissiveIntensity: emissiveIntensity,
        shininess: shininess,
        metalness: metalness,
        wireframe: wireframe,
        edgeColor: edgeColor,
        edgeWidth: edgeWidth,
        faceColors: faceColors,
        visible: visible,
      );
}

/// Scene-graph node (THREE.Object3D / THREE.Group).
class _rt_Node3D {
  _rt_Node3D({this.name, _rt_V3? position, _rt_V3? rotation, _rt_V3? scale})
      : position = position ?? _rt_V3(),
        rotation = rotation ?? _rt_V3(),
        scale = scale ?? _rt_V3(1, 1, 1);

  String? name;
  final _rt_V3 position;

  /// Euler angles in radians, order XYZ (THREE default).
  final _rt_V3 rotation;
  final _rt_V3 scale;

  /// When set, replaces [rotation] (use for arbitrary orientations, e.g.
  /// [pointAlong] or quaternion-driven code).
  _rt_M3? rotationMatrix;

  bool visible = true;

  /// Can be returned by hit tests (raycasting).
  bool pickable = true;

  /// Added to the sort depth; negative values draw on top (render order).
  double depthBias = 0;

  /// Arbitrary data (THREE `userData`).
  Map<String, dynamic> userData = {};

  _rt_Node3D? parent;
  final List<_rt_Node3D> children = [];

  T add<T extends _rt_Node3D>(T child) {
    child.parent?.children.remove(child);
    child.parent = this;
    children.add(child);
    return child;
  }

  void addAll(Iterable<_rt_Node3D> nodes) => nodes.forEach(add);

  void remove(_rt_Node3D child) {
    if (children.remove(child)) child.parent = null;
  }

  void removeFromParent() => parent?.remove(this);

  void clear() {
    for (final c in children) {
      c.parent = null;
    }
    children.clear();
  }

  _rt_Xf get localTransform {
    final r = rotationMatrix ?? _rt_M3.eulerXYZ(rotation.x, rotation.y, rotation.z);
    return _rt_Xf(r.scaled(scale), position.clone());
  }

  _rt_Xf get worldTransform {
    final local = localTransform;
    return parent == null ? local : parent!.worldTransform * local;
  }

  _rt_V3 get worldPosition => worldTransform.t;

  /// Rotates so the local +Y axis points along [dir] (cylinders, arrows).
  void pointAlong(_rt_V3 dir) {
    rotationMatrix = _rt_M3.fromUnitVectors(_rt_V3(0, 1, 0), dir);
  }

  /// Rotates so the local +Z axis faces [target] (THREE Object3D.lookAt).
  void lookAt(_rt_V3 target) {
    final wp = worldPosition;
    rotationMatrix = _rt_M3.fromUnitVectors(_rt_V3(0, 0, 1), target - wp);
  }

  /// True if this node and all its ancestors are visible.
  bool get isVisibleInTree => visible && (parent?.isVisibleInTree ?? true);

  /// Depth-first search by [name].
  _rt_Node3D? find(String n) {
    if (name == n) return this;
    for (final c in children) {
      final r = c.find(n);
      if (r != null) return r;
    }
    return null;
  }

  void traverse(void Function(_rt_Node3D) fn) {
    fn(this);
    for (final c in List.of(children)) {
      c.traverse(fn);
    }
  }
}

/// Polygon mesh (THREE.Mesh).
class _rt_Mesh3D extends _rt_Node3D {
  _rt_Mesh3D(this.geometry, this.material, {super.name, super.position, super.rotation, super.scale});

  _rt_Geometry3D geometry;
  _rt_Material3D material;
}

/// Smooth sphere drawn as a shaded disc (fast and perfectly round). Use
/// `_rt_Mesh3D(_rt_Geometry3D.sphere(...))` for partial spheres.
class _rt_Sphere3D extends _rt_Node3D {
  _rt_Sphere3D(this.radius, this.material, {super.name, super.position});

  double radius;
  _rt_Material3D material;
}

/// Polyline in 3D (THREE.Line / LineSegments). Width is in screen pixels.
class _rt_Line3D extends _rt_Node3D {
  _rt_Line3D(this.points,
      {this.color = const Color(0xFFFFFFFF),
      this.width = 2,
      this.opacity = 1,
      this.dashed = false,
      this.segments = false,
      this.closed = false,
      super.name});

  List<_rt_V3> points;
  Color color;
  double width;
  double opacity;
  bool dashed;

  /// Treat points as pairs (THREE.LineSegments).
  bool segments;
  bool closed;
}

/// Point cloud (THREE.Points). Size is in screen pixels, scaled by
/// perspective when [sizeAttenuation] is true.
class _rt_Points3D extends _rt_Node3D {
  _rt_Points3D(this.points,
      {this.color = const Color(0xFFFFFFFF),
      this.size = 4,
      this.opacity = 1,
      this.sizeAttenuation = true,
      this.colors,
      super.name});

  List<_rt_V3> points;
  Color color;
  List<Color>? colors;
  double size;
  double opacity;
  bool sizeAttenuation;
}

/// Billboard text (THREE.Sprite with a canvas texture, or CSS2D labels).
class _rt_Label3D extends _rt_Node3D {
  _rt_Label3D(
    this.text, {
    super.position,
    super.name,
    this.worldHeight = 1.0,
    this.pixelHeight,
    this.color = const Color(0xFFFFFFFF),
    this.background,
    this.borderColor,
    this.bold = true,
    this.alwaysOnTop = true,
  });

  String text;

  /// Text height in world units (scales with distance like a sprite).
  double worldHeight;

  /// If set, fixed on-screen font size instead of [worldHeight].
  double? pixelHeight;
  Color color;
  Color? background;
  Color? borderColor;
  bool bold;

  /// THREE `depthTest: false` — drawn above all geometry.
  bool alwaysOnTop;
}

/// THREE.ArrowHelper: shaft + cone head from [origin] along [dir].
class _rt_Arrow3D extends _rt_Node3D {
  _rt_Arrow3D({
    required _rt_V3 dir,
    required double length,
    _rt_V3? origin,
    Color color = const Color(0xFFFFFF00),
    double? headLength,
    double? headWidth,
    this.shaftRadius = 0.06,
    super.name,
  }) : _color = color {
    if (origin != null) position.copy(origin);
    _shaft = add(_rt_Mesh3D(_rt_Geometry3D.cylinder(1, 1, 1, segments: 10), _rt_Material3D(color: color)));
    _head = add(_rt_Mesh3D(_rt_Geometry3D.cone(1, 1, segments: 14), _rt_Material3D(color: color)));
    setDirection(dir);
    setLength(length, headLength: headLength, headWidth: headWidth);
  }

  late final _rt_Mesh3D _shaft;
  late final _rt_Mesh3D _head;
  Color _color;
  double shaftRadius;
  double _length = 1;

  double get length => _length;
  Color get color => _color;

  void setDirection(_rt_V3 dir) {
    if (dir.lengthSq == 0) return;
    pointAlong(dir);
  }

  void setLength(double length, {double? headLength, double? headWidth}) {
    _length = length;
    final visibleArrow = length.abs() > 1e-4;
    _shaft.visible = visibleArrow;
    _head.visible = visibleArrow;
    final hl = headLength ?? math.min(0.2 * length.abs(), 1.2);
    final hw = headWidth ?? hl * 0.5;
    final shaftLen = math.max(length.abs() - hl, 0.0001);
    _shaft.scale.set(shaftRadius, shaftLen, shaftRadius);
    _shaft.position.set(0, shaftLen / 2, 0);
    _head.scale.set(hw, hl, hw);
    _head.position.set(0, shaftLen + hl / 2, 0);
  }

  void setColor(Color c) {
    _color = c;
    _shaft.material.color = c;
    _head.material.color = c;
  }
}

/// Lights. Ambient + directional + point lights are supported (Lambert).
class _rt_Light3D {
  _rt_Light3D.ambient({this.color = const Color(0xFFFFFFFF), this.intensity = 0.6})
      : kind = _rt_LightKind.ambient,
        position = _rt_V3();
  _rt_Light3D.directional(this.position,
      {this.color = const Color(0xFFFFFFFF), this.intensity = 0.8})
      : kind = _rt_LightKind.directional;
  _rt_Light3D.point(this.position,
      {this.color = const Color(0xFFFFFFFF), this.intensity = 1.0, this.distance = 0})
      : kind = _rt_LightKind.point;
  _rt_Light3D.hemisphere(
      {this.color = const Color(0xFFFFFFFF),
      this.groundColor = const Color(0xFF444444),
      this.intensity = 0.6})
      : kind = _rt_LightKind.hemisphere,
        position = _rt_V3(0, 1, 0);

  final _rt_LightKind kind;
  _rt_V3 position;
  Color color;
  Color groundColor = const Color(0xFF444444);
  double intensity;
  double distance = 0;
  bool enabled = true;
}

enum _rt_LightKind { ambient, directional, point, hemisphere }

/// Root container: node tree + lights + background.
class _rt_Scene3D {
  _rt_Scene3D({this.background, this.backgroundGradient}) {
    lights.addAll([
      _rt_Light3D.ambient(intensity: 0.6),
      _rt_Light3D.directional(_rt_V3(10, 20, 10), intensity: 0.8),
    ]);
  }

  final _rt_Node3D root = _rt_Node3D(name: 'root');
  final List<_rt_Light3D> lights = [];

  /// Solid background; null = transparent.
  Color? background;

  /// Radial gradient [centre, edge] (the CSS backgrounds of #canvas-container).
  List<Color>? backgroundGradient;

  T add<T extends _rt_Node3D>(T n) => root.add(n);
  void remove(_rt_Node3D n) => root.remove(n);
  void clear() => root.clear();
  _rt_Node3D? find(String name) => root.find(name);

  /// Replaces the default lights.
  void setLights(List<_rt_Light3D> l) {
    lights
      ..clear()
      ..addAll(l);
  }
}




/// Perspective (or orthographic) camera with built-in OrbitControls
/// behaviour: drag to rotate, two fingers to pan, pinch / wheel / buttons to
/// zoom. Mirrors THREE.PerspectiveCamera + THREE.OrbitControls.
class _rt_Camera3D {
  _rt_Camera3D({
    this.fov = 45,
    _rt_V3? position,
    _rt_V3? target,
    this.near = 0.1,
    this.far = 5000,
    this.orthographic = false,
    this.orthoHeight = 20,
  })  : position = position ?? _rt_V3(0, 10, 30),
        target = target ?? _rt_V3() {
    saveHome();
  }

  /// Vertical field of view in degrees.
  double fov;
  final _rt_V3 position;

  /// OrbitControls.target (the point the camera looks at).
  final _rt_V3 target;
  double near;
  double far;

  /// THREE camera.zoom (scales the image without moving the camera).
  double zoom = 1;

  bool orthographic;

  /// Visible world height for the orthographic camera at zoom 1.
  double orthoHeight;

  // --- OrbitControls settings ---
  bool enableRotate = true;
  bool enablePan = true;
  bool enableZoom = true;
  double rotateSpeed = 1;
  double minDistance = 0.5;
  double maxDistance = 2000;
  double minPolarAngle = 0.001;
  double maxPolarAngle = math.pi - 0.001;
  double minAzimuthAngle = double.negativeInfinity;
  double maxAzimuthAngle = double.infinity;
  double minZoom = 0.2;
  double maxZoom = 8;

  /// OrbitControls.autoRotate / autoRotateSpeed (2.0 = one turn per 30 s).
  bool autoRotate = false;
  double autoRotateSpeed = 2.0;

  late _rt_V3 _homePos;
  late _rt_V3 _homeTarget;
  late double _homeZoom;
  late double _homeFov;

  /// Remembers the current view for [reset] (call after positioning).
  void saveHome() {
    _homePos = position.clone();
    _homeTarget = target.clone();
    _homeZoom = zoom;
    _homeFov = fov;
  }

  /// Restores the view saved by [saveHome] (the "reset camera" button).
  void reset() {
    position.copy(_homePos);
    target.copy(_homeTarget);
    zoom = _homeZoom;
    fov = _homeFov;
  }

  void lookAt(_rt_V3 t) => target.copy(t);

  double get distance => position.distanceTo(target);

  // ---------------------------------------------------------------- basis ---
  late _rt_V3 _right, _up, _fwd;

  void _basis() {
    _fwd = (target - position).normalized();
    if (_fwd.lengthSq == 0) _fwd = _rt_V3(0, 0, -1);
    var worldUp = _rt_V3(0, 1, 0);
    if (_fwd.cross(worldUp).lengthSq < 1e-8) worldUp = _rt_V3(0, 0, -1);
    _right = _fwd.cross(worldUp).normalized();
    _up = _right.cross(_fwd);
  }

  double _focal(Size size) => orthographic
      ? size.height / (orthoHeight / zoom)
      : (size.height / 2) / math.tan(_rt_degToRad(fov) / 2) * zoom;

  /// Prepares the per-frame projection (called by the renderer).
  _rt_ProjectionFrame frame(Size size) {
    _basis();
    return _rt_ProjectionFrame._(this, size, _right, _up, _fwd, _focal(size));
  }

  // --------------------------------------------------------- orbit / pan ---
  void _toSpherical(void Function(double r, double theta, double phi) fn) {
    final off = position - target;
    final r = off.length;
    final theta = math.atan2(off.x, off.z);
    final phi = math.acos((off.y / (r == 0 ? 1 : r)).clamp(-1.0, 1.0));
    fn(r, theta, phi);
  }

  void _fromSpherical(double r, double theta, double phi) {
    final s = math.sin(phi);
    position.set(
      target.x + r * s * math.sin(theta),
      target.y + r * math.cos(phi),
      target.z + r * s * math.cos(theta),
    );
  }

  /// Rotates around the target by a screen drag of ([dx], [dy]) pixels.
  void orbit(double dx, double dy, double viewportHeight) {
    if (!enableRotate) return;
    _toSpherical((r, theta, phi) {
      theta -= 2 * math.pi * dx / viewportHeight * rotateSpeed;
      phi -= 2 * math.pi * dy / viewportHeight * rotateSpeed;
      theta = theta.clamp(minAzimuthAngle, maxAzimuthAngle);
      phi = phi.clamp(minPolarAngle, maxPolarAngle);
      _fromSpherical(r, theta, phi);
    });
  }

  /// Rotates by angles directly (radians).
  void rotateBy(double dTheta, double dPhi) {
    _toSpherical((r, theta, phi) {
      _fromSpherical(r, (theta + dTheta).clamp(minAzimuthAngle, maxAzimuthAngle),
          (phi + dPhi).clamp(minPolarAngle, maxPolarAngle));
    });
  }

  /// Moves camera + target by a screen drag of ([dx], [dy]) pixels.
  void pan(double dx, double dy, Size size) {
    if (!enablePan) return;
    _basis();
    final worldPerPixel = orthographic
        ? (orthoHeight / zoom) / size.height
        : 2 * distance * math.tan(_rt_degToRad(fov) / 2) / size.height / zoom;
    final move = _right * (-dx * worldPerPixel) + _up * (dy * worldPerPixel);
    position.add(move);
    target.add(move);
  }

  /// Zoom by [factor] (< 1 zooms in). Perspective cameras dolly toward the
  /// target; orthographic cameras change [zoom].
  void dolly(double factor) {
    if (!enableZoom) return;
    if (orthographic) {
      zoom = (zoom / factor).clamp(minZoom, maxZoom);
      return;
    }
    final off = position - target;
    final r = (off.length * factor).clamp(minDistance, maxDistance);
    position.copy(target + off.normalized() * r);
  }

  void zoomIn() => dolly(0.85);
  void zoomOut() => dolly(1 / 0.85);

  /// Per-frame update (auto-rotate).
  void update(double dt) {
    if (autoRotate) rotateBy(-2 * math.pi / 60 * autoRotateSpeed * dt, 0);
  }
}

/// Screen projection for one frame.
class _rt_ProjectionFrame {
  _rt_ProjectionFrame._(this.camera, this.size, this.right, this.up, this.fwd, this.focal)
      : eye = camera.position.clone(),
        cx = size.width / 2,
        cy = size.height / 2;

  final _rt_Camera3D camera;
  final Size size;
  final _rt_V3 right, up, fwd, eye;
  final double focal, cx, cy;

  /// Camera-space depth (distance along view direction).
  double depthOf(_rt_V3 p) =>
      (p.x - eye.x) * fwd.x + (p.y - eye.y) * fwd.y + (p.z - eye.z) * fwd.z;

  /// Projects a world point; null if behind the near plane.
  Offset? project(_rt_V3 p) {
    final dx = p.x - eye.x, dy = p.y - eye.y, dz = p.z - eye.z;
    final z = dx * fwd.x + dy * fwd.y + dz * fwd.z;
    if (!camera.orthographic && z < camera.near) return null;
    final x = dx * right.x + dy * right.y + dz * right.z;
    final y = dx * up.x + dy * up.y + dz * up.z;
    final k = camera.orthographic ? focal : focal / z;
    return Offset(cx + x * k, cy - y * k);
  }

  /// Screen pixels per world unit at depth [z].
  double pixelsPerUnit(double z) =>
      camera.orthographic ? focal : focal / math.max(z, camera.near);

  /// World-space ray through a screen point (for raycasting / dragging).
  _rt_Ray3 ray(Offset screen) {
    final x = (screen.dx - cx) / focal;
    final y = -(screen.dy - cy) / focal;
    if (camera.orthographic) {
      final origin = eye + right * x + up * y;
      return _rt_Ray3(origin, fwd.clone());
    }
    final dir = (fwd + right * x + up * y).normalized();
    return _rt_Ray3(eye.clone(), dir);
  }
}

class _rt_Ray3 {
  _rt_Ray3(this.origin, this.direction);

  final _rt_V3 origin;
  final _rt_V3 direction;

  _rt_V3 at(double t) => origin + direction * t;

  /// Intersection with the plane through [point] with [normal]; null if
  /// parallel or behind the ray.
  _rt_V3? intersectPlane(_rt_V3 point, _rt_V3 normal) {
    final denom = normal.dot(direction);
    if (denom.abs() < 1e-9) return null;
    final t = (point - origin).dot(normal) / denom;
    if (t < 0) return null;
    return at(t);
  }

  /// Intersection with the horizontal plane y = [y].
  _rt_V3? intersectY(double y) => intersectPlane(_rt_V3(0, y, 0), _rt_V3(0, 1, 0));

  /// Intersection with the vertical plane z = [z].
  _rt_V3? intersectZ(double z) => intersectPlane(_rt_V3(0, 0, z), _rt_V3(0, 0, 1));
}







/// Pick record kept from the last painted frame (used for raycast hits).
class _Pickable {
  _Pickable.path(this.node, this.path, this.depth) : center = null, radius = 0;
  _Pickable.circle(this.node, Offset c, this.radius, this.depth)
      : center = c,
        path = null;

  final _rt_Node3D node;
  final Path? path;
  final Offset? center;
  final double radius;
  final double depth;

  bool contains(Offset p) =>
      path != null ? path!.contains(p) : (p - center!).distance <= radius;
}

/// Shared state between the painter and the view (projection + picking).
class _rt_RenderState {
  _rt_ProjectionFrame? frame;
  List<_Pickable> _picks = const [];

  /// Nearest pickable node under [p] in the last frame.
  _rt_Node3D? hitTest(Offset p) {
    _Pickable? best;
    for (final k in _picks) {
      if (k.contains(p) && (best == null || k.depth < best.depth)) best = k;
    }
    return best?.node;
  }

  /// All pickable nodes under [p], nearest first.
  List<_rt_Node3D> hitTestAll(Offset p) {
    final hits = _picks.where((k) => k.contains(p)).toList()
      ..sort((a, b) => a.depth.compareTo(b.depth));
    return [for (final h in hits) h.node];
  }
}

class _Item {
  _Item(this.depth, this.draw);
  final double depth;
  final void Function(Canvas c) draw;
}

class _LabelCache {
  _LabelCache(this.key, this.painter);
  final String key;
  final TextPainter painter;
}

final Expando<_LabelCache> _labelCache = Expando();

/// Paints a [_rt_Scene3D] from a [_rt_Camera3D]. Repaints whenever [repaint] ticks.
class _rt_ScenePainter extends CustomPainter {
  _rt_ScenePainter({
    required this.scene,
    required this.camera,
    required this.state,
    super.repaint,
  });

  final _rt_Scene3D scene;
  final _rt_Camera3D camera;
  final _rt_RenderState state;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    canvas.save();
    canvas.clipRect(Offset.zero & size);
    _paintBackground(canvas, size);

    final pf = camera.frame(size);
    state.frame = pf;
    final items = <_Item>[];
    final overlay = <_Item>[];
    final picks = <_Pickable>[];

    void visit(_rt_Node3D n, _rt_Xf parentXf) {
      if (!n.visible) return;
      final xf = parentXf * n.localTransform;
      if (n is _rt_Mesh3D) {
        _mesh(n, xf, pf, items, picks);
      } else if (n is _rt_Sphere3D) {
        _sphere(n, xf, pf, items, picks);
      } else if (n is _rt_Line3D) {
        _line(n, xf, pf, items);
      } else if (n is _rt_Points3D) {
        _points(n, xf, pf, items);
      } else if (n is _rt_Label3D) {
        _label(n, xf, pf, n.alwaysOnTop ? overlay : items, picks);
      }
      for (final c in n.children) {
        visit(c, xf);
      }
    }

    visit(scene.root, _rt_Xf.identity());

    items.sort((a, b) => b.depth.compareTo(a.depth));
    for (final it in items) {
      it.draw(canvas);
    }
    overlay.sort((a, b) => b.depth.compareTo(a.depth));
    for (final it in overlay) {
      it.draw(canvas);
    }
    state._picks = picks;
    canvas.restore();
  }

  void _paintBackground(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final g = scene.backgroundGradient;
    if (g != null && g.length >= 2) {
      canvas.drawRect(
        rect,
        Paint()
          ..shader = ui.Gradient.radial(
            size.center(Offset.zero),
            math.max(size.width, size.height) * 0.75,
            g,
          ),
      );
    } else if (scene.background != null) {
      canvas.drawRect(rect, Paint()..color = scene.background!);
    }
  }

  // ------------------------------------------------------------ shading ---
  Color _shade(_rt_Material3D m, Color base, _rt_V3 n, _rt_V3 p, _rt_V3 view) {
    var r = 0.0, g = 0.0, b = 0.0;
    var sr = 0.0, sg = 0.0, sb = 0.0;
    if (m.unlit) {
      r = g = b = 1;
    } else {
      for (final l in scene.lights) {
        if (!l.enabled) continue;
        final lc = l.color;
        switch (l.kind) {
          case _rt_LightKind.ambient:
            r += lc.r * l.intensity;
            g += lc.g * l.intensity;
            b += lc.b * l.intensity;
          case _rt_LightKind.hemisphere:
            final w = 0.5 * n.y + 0.5;
            final gc = l.groundColor;
            r += (gc.r + (lc.r - gc.r) * w) * l.intensity;
            g += (gc.g + (lc.g - gc.g) * w) * l.intensity;
            b += (gc.b + (lc.b - gc.b) * w) * l.intensity;
          case _rt_LightKind.directional:
          case _rt_LightKind.point:
            _rt_V3 dir;
            var atten = 1.0;
            if (l.kind == _rt_LightKind.directional) {
              dir = l.position.normalized();
            } else {
              final d = l.position - p;
              final dist = d.length;
              dir = d / (dist == 0 ? 1 : dist);
              if (l.distance > 0) {
                atten = math.pow(math.max(0.0, 1 - dist / l.distance), 2).toDouble();
              }
            }
            final ndl = math.max(0.0, n.dot(dir)) * l.intensity * atten;
            r += lc.r * ndl;
            g += lc.g * ndl;
            b += lc.b * ndl;
            if (m.shininess > 0 && ndl > 0) {
              final h = (dir + view).normalized();
              final spec = math.pow(math.max(0.0, n.dot(h)), 8 + m.shininess * 56) *
                  m.shininess *
                  l.intensity *
                  atten;
              sr += lc.r * spec;
              sg += lc.g * spec;
              sb += lc.b * spec;
            }
        }
      }
    }
    final diffuse = 1 - 0.6 * m.metalness;
    var cr = base.r * r * diffuse + sr,
        cg = base.g * g * diffuse + sg,
        cb = base.b * b * diffuse + sb;
    final e = m.emissive;
    if (e != null) {
      cr += e.r * m.emissiveIntensity;
      cg += e.g * m.emissiveIntensity;
      cb += e.b * m.emissiveIntensity;
    }
    return Color.from(
      alpha: (base.a * m.opacity).clamp(0.0, 1.0),
      red: cr.clamp(0.0, 1.0),
      green: cg.clamp(0.0, 1.0),
      blue: cb.clamp(0.0, 1.0),
    );
  }

  // -------------------------------------------------------------- meshes ---
  void _mesh(_rt_Mesh3D n, _rt_Xf xf, _rt_ProjectionFrame pf, List<_Item> items, List<_Pickable> picks) {
    final m = n.material;
    if (!m.visible) return;
    final g = n.geometry;
    final world = [for (final v in g.vertices) xf.apply(v)];
    final screen = [for (final v in world) pf.project(v)];
    final depths = [for (final v in world) pf.depthOf(v)];
    final pickable = n.pickable && n.isVisibleInTree;

    for (var fi = 0; fi < g.faces.length; fi++) {
      final f = g.faces[fi];
      if (f.length < 3) continue;
      var clipped = false;
      for (final i in f) {
        if (screen[i] == null) {
          clipped = true;
          break;
        }
      }
      // Faces crossing the near plane are clipped instead of dropped, so big
      // floors/tables never vanish when the camera gets close.
      final List<Offset> pts;
      if (clipped) {
        pts = _clipNear([for (final i in f) world[i]], pf);
        if (pts.length < 3) continue;
      } else {
        pts = [for (final i in f) screen[i]!];
      }

      // Newell normal (robust for quads and degenerate polygons).
      var nx = 0.0, ny = 0.0, nz = 0.0, cx = 0.0, cy = 0.0, cz = 0.0, depth = 0.0;
      for (var k = 0; k < f.length; k++) {
        final a = world[f[k]], b = world[f[(k + 1) % f.length]];
        nx += (a.y - b.y) * (a.z + b.z);
        ny += (a.z - b.z) * (a.x + b.x);
        nz += (a.x - b.x) * (a.y + b.y);
        cx += a.x;
        cy += a.y;
        cz += a.z;
        depth += depths[f[k]];
      }
      final inv = 1 / f.length;
      final center = _rt_V3(cx * inv, cy * inv, cz * inv);
      depth *= inv;
      var normal = _rt_V3(nx, ny, nz).normalize();
      final view = camera.orthographic ? -pf.fwd : (pf.eye - center).normalize();
      final facing = normal.dot(view) >= 0;
      if (!facing && !m.doubleSided && !m.wireframe) continue;
      if (!facing) normal = -normal;

      final gi = g.faceGroups != null && fi < g.faceGroups!.length ? g.faceGroups![fi] : 0;
      final base = (m.faceColors != null && gi < m.faceColors!.length)
          ? m.faceColors![gi]
          : m.color;
      final color = _shade(m, base, normal, center, view);

      final path = Path()..addPolygon(pts, true);

      final d = depth + n.depthBias;
      items.add(_Item(d, (c) {
        if (m.wireframe) {
          c.drawPath(
              path,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = m.edgeWidth
                ..color = color);
          return;
        }
        final fill = Paint()
          ..color = color
          ..isAntiAlias = true;
        c.drawPath(path, fill);
        if (color.a >= 0.99) {
          // Hide hairline seams between neighbouring opaque faces.
          c.drawPath(
              path,
              fill
                ..style = PaintingStyle.stroke
                ..strokeWidth = 0.7);
        }
        if (m.edgeColor != null) {
          c.drawPath(
              path,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = m.edgeWidth
                ..color = m.edgeColor!);
        }
      }));
      if (pickable) picks.add(_Pickable.path(n, path, d));
    }
  }

  /// Sutherland–Hodgman clip of a world-space polygon against the near
  /// plane, returning projected screen points.
  List<Offset> _clipNear(List<_rt_V3> poly, _rt_ProjectionFrame pf) {
    final near = camera.near * 1.01;
    final out = <_rt_V3>[];
    for (var k = 0; k < poly.length; k++) {
      final a = poly[k], b = poly[(k + 1) % poly.length];
      final da = pf.depthOf(a) - near, db = pf.depthOf(b) - near;
      if (da >= 0) out.add(a);
      if ((da >= 0) != (db >= 0)) out.add(a.lerp(b, da / (da - db)));
    }
    final res = <Offset>[];
    for (final p in out) {
      final s = pf.project(p);
      if (s != null) res.add(s);
    }
    return res;
  }

  // ------------------------------------------------------------- spheres ---
  void _sphere(_rt_Sphere3D n, _rt_Xf xf, _rt_ProjectionFrame pf, List<_Item> items, List<_Pickable> picks) {
    final m = n.material;
    if (!m.visible) return;
    final c = xf.t;
    final z = pf.depthOf(c);
    if (!camera.orthographic && z < camera.near) return;
    final sp = pf.project(c);
    if (sp == null) return;
    final r = n.radius * xf.maxScale * pf.pixelsPerUnit(z);
    if (r < 0.3) return;
    final view = camera.orthographic ? -pf.fwd : (pf.eye - c).normalize();
    final lit = _shade(m, m.color, view, c, view);
    final d = z + n.depthBias;

    items.add(_Item(d, (canvas) {
      if (m.wireframe) {
        canvas.drawCircle(
            sp,
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..color = lit);
        return;
      }
      if (m.unlit) {
        canvas.drawCircle(sp, r, Paint()..color = lit);
      } else {
        final hi = Color.lerp(lit, Colors.white.withValues(alpha: lit.a),
            0.35 + m.shininess * 0.4)!;
        final lo = Color.lerp(lit, Colors.black.withValues(alpha: lit.a), 0.45)!;
        canvas.drawCircle(
          sp,
          r,
          Paint()
            ..shader = ui.Gradient.radial(
              sp + Offset(-r * 0.35, -r * 0.4),
              r * 1.35,
              [hi, lit, lo],
              const [0.0, 0.45, 1.0],
            ),
        );
      }
      if (m.edgeColor != null) {
        canvas.drawCircle(
            sp,
            r,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = m.edgeWidth
              ..color = m.edgeColor!);
      }
    }));
    if (n.pickable && n.isVisibleInTree) picks.add(_Pickable.circle(n, sp, r, d));
  }

  // --------------------------------------------------------------- lines ---
  void _line(_rt_Line3D n, _rt_Xf xf, _rt_ProjectionFrame pf, List<_Item> items) {
    if (n.points.length < 2) return;
    final world = [for (final p in n.points) xf.apply(p)];
    final color = n.color.withValues(alpha: n.color.a * n.opacity);
    final pairs = <(int, int)>[];
    if (n.segments) {
      for (var i = 0; i + 1 < world.length; i += 2) {
        pairs.add((i, i + 1));
      }
    } else {
      for (var i = 0; i + 1 < world.length; i++) {
        pairs.add((i, i + 1));
      }
      if (n.closed) pairs.add((world.length - 1, 0));
    }
    for (final (i, j) in pairs) {
      final a = pf.project(world[i]), b = pf.project(world[j]);
      if (a == null || b == null) continue;
      final d = (pf.depthOf(world[i]) + pf.depthOf(world[j])) / 2 + n.depthBias;
      items.add(_Item(d, (c) {
        final p = Paint()
          ..color = color
          ..strokeWidth = n.width
          ..strokeCap = StrokeCap.round;
        if (!n.dashed) {
          c.drawLine(a, b, p);
        } else {
          final len = (b - a).distance;
          const dash = 8.0, gap = 6.0;
          final dir = (b - a) / (len == 0 ? 1 : len);
          for (var t = 0.0; t < len; t += dash + gap) {
            c.drawLine(a + dir * t, a + dir * math.min(t + dash, len), p);
          }
        }
      }));
    }
  }

  // -------------------------------------------------------------- points ---
  void _points(_rt_Points3D n, _rt_Xf xf, _rt_ProjectionFrame pf, List<_Item> items) {
    for (var i = 0; i < n.points.length; i++) {
      final w = xf.apply(n.points[i]);
      final s = pf.project(w);
      if (s == null) continue;
      final z = pf.depthOf(w);
      final base = n.colors != null && i < n.colors!.length ? n.colors![i] : n.color;
      final col = base.withValues(alpha: base.a * n.opacity);
      final r = n.sizeAttenuation
          ? math.max(0.5, n.size * pf.pixelsPerUnit(z) * 0.05)
          : n.size / 2;
      items.add(_Item(z + n.depthBias, (c) => c.drawCircle(s, r, Paint()..color = col)));
    }
  }

  // -------------------------------------------------------------- labels ---
  void _label(_rt_Label3D n, _rt_Xf xf, _rt_ProjectionFrame pf, List<_Item> items, List<_Pickable> picks) {
    if (n.text.isEmpty) return;
    final w = xf.t;
    final s = pf.project(w);
    if (s == null) return;
    final z = pf.depthOf(w);
    final fontSize = (n.pixelHeight ?? n.worldHeight * xf.maxScale * pf.pixelsPerUnit(z) * 0.6)
        .clamp(5.0, 72.0);
    final key = '${n.text}|${fontSize.toStringAsFixed(1)}|${n.color.toARGB32()}|${n.bold}';
    var cache = _labelCache[n];
    if (cache == null || cache.key != key) {
      final tp = TextPainter(
        text: TextSpan(
          text: n.text,
          style: TextStyle(
            color: n.color,
            fontSize: fontSize,
            fontWeight: n.bold ? FontWeight.w800 : FontWeight.w500,
            height: 1.1,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      cache = _LabelCache(key, tp);
      _labelCache[n] = cache;
    }
    final tp = cache.painter;
    final padH = fontSize * 0.45, padV = fontSize * 0.25;
    final rect = Rect.fromCenter(
        center: s, width: tp.width + padH * 2, height: tp.height + padV * 2);
    final d = z + n.depthBias;
    items.add(_Item(d, (c) {
      if (n.background != null) {
        final rr = RRect.fromRectAndRadius(rect, Radius.circular(fontSize * 0.35));
        c.drawRRect(rr, Paint()..color = n.background!);
        if (n.borderColor != null) {
          c.drawRRect(
              rr,
              Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 1.2
                ..color = n.borderColor!);
        }
      }
      tp.paint(c, s - Offset(tp.width / 2, tp.height / 2));
    }));
    if (n.pickable && n.isVisibleInTree) {
      picks.add(_Pickable.path(n, Path()..addRect(rect), n.alwaysOnTop ? -1e9 : d));
    }
  }

  @override
  bool shouldRepaint(covariant _rt_ScenePainter old) =>
      old.scene != scene || old.camera != camera;
}









/// Pointer info handed to activity callbacks (THREE.Raycaster equivalent).
class _rt_SceneEvent {
  _rt_SceneEvent(this.position, this.hit, this.ray, this.frame, this.hits);

  /// Local position inside the view.
  final Offset position;

  /// Nearest node under the pointer (mesh / sphere / label), if any.
  final _rt_Node3D? hit;

  /// All nodes under the pointer, nearest first.
  final List<_rt_Node3D> hits;

  /// World-space ray through the pointer.
  final _rt_Ray3 ray;
  final _rt_ProjectionFrame frame;

  /// Walks up from [hit] to the first node matching [test] (e.g. a named
  /// group), like checking `object.parent` chains after raycasting.
  _rt_Node3D? hitWhere(bool Function(_rt_Node3D n) test) {
    for (final h in hits) {
      _rt_Node3D? n = h;
      while (n != null) {
        if (test(n)) return n;
        n = n.parent;
      }
    }
    return null;
  }

  _rt_Node3D? hitNamed(String name) => hitWhere((n) => n.name == name);
}

enum _rt_DragMode { rotate, pan }

/// Controller so parents (e.g. zoom buttons) can talk to the view.
class _rt_Scene3DController extends ChangeNotifier {
  _rt_DragMode mode = _rt_DragMode.rotate;
  void setMode(_rt_DragMode m) {
    mode = m;
    notifyListeners();
  }
}

/// Interactive 3D viewport: renders [scene] through [camera] every frame
/// (like three.js' `requestAnimationFrame` render loop) and provides
/// OrbitControls-style gestures:
///
/// * one finger / left mouse drag: rotate (or pan in [_rt_DragMode.pan])
/// * two fingers: pinch to zoom, drag to pan
/// * mouse wheel / trackpad: zoom; right mouse drag: pan
///
/// If [onPointerDown] returns true, that gesture is captured by the activity
/// (for dragging objects) and the camera does not move.
class _rt_Scene3DView extends StatefulWidget {
  const _rt_Scene3DView({
    super.key,
    required this.scene,
    required this.camera,
    this.controller,
    this.onFrame,
    this.onTap,
    this.onPointerDown,
    this.onPointerMove,
    this.onPointerUp,
    this.onHover,
    this.cameraControls = true,
  });

  final _rt_Scene3D scene;
  final _rt_Camera3D camera;
  final _rt_Scene3DController? controller;

  /// Called every frame with the elapsed seconds (animation loop).
  final void Function(double dt)? onFrame;
  final void Function(_rt_SceneEvent e)? onTap;
  final bool Function(_rt_SceneEvent e)? onPointerDown;
  final void Function(_rt_SceneEvent e)? onPointerMove;
  final void Function(_rt_SceneEvent e)? onPointerUp;
  final void Function(_rt_SceneEvent e)? onHover;

  /// Set false to disable orbit/pan/zoom gestures entirely.
  final bool cameraControls;

  @override
  State<_rt_Scene3DView> createState() => _Scene3DViewState();
}

class _Scene3DViewState extends State<_rt_Scene3DView> with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<int> _tick = ValueNotifier(0);
  final _rt_RenderState _render = _rt_RenderState();
  Duration _last = Duration.zero;
  Size _size = Size.zero;

  final Map<int, Offset> _pointers = {};
  int? _captured;
  Offset? _downPos;
  DateTime? _downTime;
  double _moved = 0;
  double? _pinchDist;
  Offset? _pinchCenter;
  int _buttons = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration elapsed) {
    var dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    if (dt > 0.1) dt = 0.1; // clamp after pauses
    widget.camera.update(dt);
    widget.onFrame?.call(dt);
    _tick.value++;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _tick.dispose();
    super.dispose();
  }

  _rt_SceneEvent _event(Offset p) {
    final frame = _render.frame ?? widget.camera.frame(_size);
    final hits = _render.hitTestAll(p);
    return _rt_SceneEvent(p, hits.isEmpty ? null : hits.first, frame.ray(p), frame, hits);
  }

  void _down(PointerDownEvent e) {
    _pointers[e.pointer] = e.localPosition;
    _buttons = e.buttons;
    if (_pointers.length == 1) {
      _downPos = e.localPosition;
      _downTime = DateTime.now();
      _moved = 0;
      if (widget.onPointerDown?.call(_event(e.localPosition)) ?? false) {
        _captured = e.pointer;
      }
    } else {
      _startPinch();
    }
  }

  void _startPinch() {
    if (_pointers.length < 2) return;
    final ps = _pointers.values.take(2).toList();
    _pinchDist = (ps[0] - ps[1]).distance;
    _pinchCenter = (ps[0] + ps[1]) / 2;
  }

  void _move(PointerMoveEvent e) {
    final prev = _pointers[e.pointer];
    if (prev == null) return;
    _pointers[e.pointer] = e.localPosition;
    final delta = e.localPosition - prev;
    _moved += delta.distance;

    if (_captured == e.pointer) {
      widget.onPointerMove?.call(_event(e.localPosition));
      return;
    }
    if (_captured != null || !widget.cameraControls) return;
    final cam = widget.camera;

    if (_pointers.length >= 2) {
      final ps = _pointers.values.take(2).toList();
      final dist = (ps[0] - ps[1]).distance;
      final center = (ps[0] + ps[1]) / 2;
      if (_pinchDist != null && dist > 0) cam.dolly(_pinchDist! / dist);
      if (_pinchCenter != null) {
        final d = center - _pinchCenter!;
        cam.pan(d.dx, d.dy, _size);
      }
      _pinchDist = dist;
      _pinchCenter = center;
      return;
    }

    final panMode = (widget.controller?.mode == _rt_DragMode.pan) ||
        (_buttons & kSecondaryMouseButton) != 0 ||
        (_buttons & kMiddleMouseButton) != 0;
    if (panMode) {
      cam.pan(delta.dx, delta.dy, _size);
    } else {
      cam.orbit(delta.dx, delta.dy, _size.height);
    }
  }

  void _up(PointerEvent e, {bool cancelled = false}) {
    _pointers.remove(e.pointer);
    if (_captured == e.pointer) {
      _captured = null;
      widget.onPointerUp?.call(_event(e.localPosition));
    }
    if (!cancelled &&
        _pointers.isEmpty &&
        _downPos != null &&
        _moved < 10 &&
        DateTime.now().difference(_downTime!).inMilliseconds < 400) {
      widget.onTap?.call(_event(e.localPosition));
    }
    if (_pointers.length < 2) {
      _pinchDist = null;
      _pinchCenter = null;
    } else {
      _startPinch();
    }
    if (_pointers.isEmpty) _downPos = null;
  }

  void _signal(PointerSignalEvent e) {
    if (!widget.cameraControls) return;
    if (e is PointerScrollEvent) {
      GestureBinding.instance.pointerSignalResolver.register(e, (ev) {
        final dy = (ev as PointerScrollEvent).scrollDelta.dy;
        widget.camera.dolly(dy > 0 ? 1.08 : 1 / 1.08);
      });
    } else if (e is PointerScaleEvent) {
      widget.camera.dolly(1 / e.scale);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      _size = c.biggest;
      return Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: _down,
        onPointerMove: _move,
        onPointerUp: _up,
        onPointerCancel: (e) => _up(e, cancelled: true),
        onPointerSignal: _signal,
        onPointerHover: widget.onHover == null
            ? null
            : (e) => widget.onHover!(_event(e.localPosition)),
        onPointerPanZoomUpdate: (e) {
          if (!widget.cameraControls) return;
          if (e.scale != 1) widget.camera.dolly(1 / e.scale.clamp(0.9, 1.1));
        },
        child: RepaintBoundary(
          child: CustomPaint(
            size: c.biggest,
            painter: _rt_ScenePainter(
              scene: widget.scene,
              camera: widget.camera,
              state: _render,
              repaint: _tick,
            ),
          ),
        ),
      );
    });
  }
}

/// Simple tween runner for step animations (the HTML `animateProp` helper):
///
/// ```dart
/// await tweens.run(2000, (t) => water.scale.y = 0.01 + t * 0.99);
/// ```
///
/// Advance it from the view's `onFrame` callback: `tweens.update(dt)`.
class _rt_TweenRunner {
  /// [resumeOnCancel] false makes [cancelAll] abandon the awaiting code
  /// instead of resuming it, so a step interrupted by Restart or by leaving
  /// the page cannot finish later against the reset (or disposed) lab.
  _rt_TweenRunner({this.resumeOnCancel = true});

  final bool resumeOnCancel;
  final List<_Tween> _active = [];

  bool get isBusy => _active.isNotEmpty;

  /// Runs [update] with eased progress 0..1 over [ms] milliseconds.
  Future<void> run(int ms, void Function(double t) update,
      {double Function(double) ease = _rt_Ease.outCubic}) {
    final tw = _Tween(ms / 1000.0, update, ease);
    _active.add(tw);
    return tw.done.future;
  }

  /// Waits [ms] milliseconds (in animation time).
  Future<void> wait(int ms) => run(ms, (_) {}, ease: _rt_Ease.linear);

  void update(double dt) {
    for (final t in List.of(_active)) {
      t.elapsed += dt;
      final p = (t.elapsed / t.duration).clamp(0.0, 1.0);
      t.update(t.ease(p));
      if (p >= 1) {
        _active.remove(t);
        t.done.complete();
      }
    }
  }

  /// Stops all tweens. Their futures complete (so awaiting code resumes)
  /// only when [resumeOnCancel] is true; otherwise they never complete.
  void cancelAll() {
    if (resumeOnCancel) {
      for (final t in _active) {
        if (!t.done.isCompleted) t.done.complete();
      }
    }
    _active.clear();
  }
}

class _Tween {
  _Tween(this.duration, this.update, this.ease);
  final double duration;
  final void Function(double) update;
  final double Function(double) ease;
  double elapsed = 0;
  final Completer<void> done = Completer<void>();
}







/// Rotate / Pan mode buttons for the (vertical) canvas toolbar (HTML `setMode`).
class _rt_RotatePanToggle extends StatelessWidget {
  const _rt_RotatePanToggle({super.key, required this.controller, this.accent = _rt_Tw.teal600});

  final _rt_Scene3DController controller;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        Widget b(_rt_DragMode m, IconData icon, String tip) {
          final active = controller.mode == m;
          return Tooltip(
            message: tip,
            child: InkResponse(
              radius: 22,
              onTap: () {
                _rt_playSfx(_rt_Sfx.tap);
                controller.setMode(m);
              },
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: active ? accent : _rt_Lab.surface,
                  shape: BoxShape.circle,
                  boxShadow: active
                      ? [BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 6)]
                      : null,
                ),
                child: Icon(icon, size: 18, color: active ? Colors.white : _rt_Lab.textMuted),
              ),
            ),
          );
        }

        return Column(mainAxisSize: MainAxisSize.min, children: [
          b(_rt_DragMode.rotate, Icons.threesixty, _rt_tr('Rotate', 'घुमाएँ')),
          const SizedBox(height: 4),
          b(_rt_DragMode.pan, Icons.pan_tool_outlined, _rt_tr('Pan', 'खिसकाएँ')),
        ]);
      },
    );
  }
}

// END ACTIVITY-LOCAL RUNTIME

final _tx = _rt_Tx({
  'en': {
    'title': 'Hierarchy of classification(five kingdom system)',
    'subtitle': 'Class 9 • Diversity in Living Organism',
    'enterLab': 'ENTER VIRTUAL LAB',
    'moduleSel': 'Module Select',
    'missionObj': 'Mission Objective',
    'detailedSteps': 'Detailed Explanation of Steps',
    'what_we_learn': 'What we learn',
    'taskInstr': 'How to perform:',
    'expOut': 'Expected Outcome:',
    'conceptLearned': 'Concept Learned:',
    'hint': 'Hint',
    'resetStep': 'Reset',
    'verifyStep': 'Verify',
    'btnReplay': 'Replay Lab',
    'settings': 'Settings',
    'visTheme': 'Visual Theme',
    'dark': 'Dark',
    'light': 'Light',
    'txtScale': 'Text Scaling',
    'labProgress': 'Lab Progress',
    'trayTitle': 'Tool Tray',
    'placeOnPed': 'Place on Pedestal:',
    'exampleChipsLabel': 'Example Organism Chips:',
    'specFeature': 'Specimen Feature',
    'gotIt': 'Got it',
    'genusSlot': 'Genus Slot',
    'speciesSlot': 'Species Slot',
    'tigerFigurine': 'Tiger Figurine',
    'mangoFruit': 'Mango Fruit',
    'tigerRungsLabel': '8 Rungs (Sub-phylum)',
    'peaRungsLabel': '7 Standard Ranks',
    'itemsPlaced': 'Items: {n}/10 Placed',
    'bacterium': 'Bacteria',
    'amoeba': 'Amoeba',
    'mushroom': 'Fungi',
    'rose': 'Plant',
    'frog': 'Animal',
    'ped1_label': 'Pedestal 1: Monera',
    'ped2_label': 'Pedestal 2: Protista',
    'ped3_label': 'Pedestal 3: Fungi',
    'ped4_label': 'Pedestal 4: Plantae',
    'ped5_label': 'Pedestal 5: Animalia',
    'tigerLadder': 'Tiger Track',
    'peaLadder': 'Pea Track',
    'rulesConfirm': 'Rule Checkboxes:',
    'rule1': '1. Two parts: Genus name first, species name second.',
    'rule2': '2. Genus begins with Capital letter; species in small letters.',
    'rule3': '3. Italicised when printed, or underlined when handwritten.',
    'hud_s1': 'Assign 5 specimens & 5 example chips to pedestals by kingdom criteria.',
    'hud_s2': 'Construct complete taxonomic hierarchy address ladders for Tiger and Pea.',
    'hud_s3': 'Construct binomial scientific names and verify Linnaean nomenclature rules.',
    'callouts': {
      'bacterium': {
        't': 'Bacterium Specimen',
        'b': 'Capsule-shaped, unmembraned DNA (Nucleoid), unicellular prokaryote without nuclear membrane.',
      },
      'amoeba': {
        't': 'Amoeba Specimen',
        'b': 'Unicellular eukaryote with pseudopodia lobes and membrane-bound true nucleus & organelles.',
      },
      'mushroom': {
        't': 'Mushroom Specimen',
        'b': 'Multicellular decomposer with chitin cell wall and absorptive heterotrophic nutrition.',
      },
      'rose': {
        't': 'Rose Plant Specimen',
        'b': 'Multicellular autotroph with cellulose cell wall, chlorophyll, and active photosynthesis.',
      },
      'frog': {
        't': 'Frog Specimen',
        'b': 'Multicellular ingestive heterotroph with completely absent cell wall and active locomotion.',
      },
    },
    'chips': {
      'c_monera': 'Bacteria, Archaea, Cyanobacteria',
      'c_protista': 'Amoeba, Paramecium, Euglena',
      'c_fungi': 'Mushroom, Yeast, Aspergillus',
      'c_plantae': 'Mosses, Ferns, Pines, Roses',
      'c_animalia': 'Bird, Cat, Human, Frog',
    },
    'concTitle': 'Scientific Conclusion & Concept Summary',
    'concHead1': '1. Five Kingdom System (Whittaker, 1969)',
    'concBody1':
        'Living organisms are systematically classified into Monera, Protista, Fungi, Plantae, and Animalia based on 4 structural criteria: Cell Type, Cell Structure, Organisation, and Mode of Nutrition.',
    'concHead2': '2. Taxonomic Address Ladder',
    'concBody2':
        'Biological classification operates like a universal postal address: Kingdom → Phylum → (Sub-phylum Vertebrata in Tiger) → Class → Order → Family → Genus → Species. Each lower tier shares increasingly specific shared characteristics.',
    'concHead3': '3. Universal Binomial Nomenclature (Linnaeus)',
    'concBody3':
        'Eliminates vernacular multilingual confusion by assigning each unique species an exact two-part Latinized scientific name: Panthera tigris (Tiger) and Mangifera indica (Mango), where the Genus is capitalized, species is lowercase, and the name is printed in italics.',
    's1_title': '1. Five Kingdoms by Criteria',
    's2_title': '2. Classification Address Ladder',
    's3_title': '3. Construct Binomial Names',
    's1_obj':
        'Classify organisms into the Five Kingdoms (Monera, Protista, Fungi, Plantae, Animalia) using the 4 fundamental criteria: Cell type, Cell wall structure, Organisation, and Nutrition.',
    's2_obj':
        'Construct complete taxonomic hierarchy address ladders for Tiger (8 levels with Sub-phylum Vertebrata) and Pea (7 standard levels without Sub-phylum), demonstrating how classification acts like a postal address.',
    's3_obj':
        'Assemble the universal two-part binomial scientific names (Panthera tigris and Mangifera indica) and confirm the 3 Linnaean nomenclature rules.',
    's1_steps': [
      {
        't': 'Step 1: Cell Type & Nuclear Organization',
        'i':
            'Inspect the 3D Bacterium model. Note the absence of a defined membrane-bound nucleus and assign it to Pedestal 1.',
        'o': 'Bacterium is positioned on Pedestal 1.',
        'c': 'Prokaryotic unicellular organisms lacking defined membrane-bound nuclei form Kingdom Monera.',
      },
      {
        't': 'Step 2: Unicellular Eukaryote with Organelles',
        'i': 'Inspect the 3D Amoeba model. Observe its true nucleus and pseudopodia, and assign it to Pedestal 2.',
        'o': 'Amoeba is positioned on Pedestal 2.',
        'c': 'Unicellular eukaryotes possessing membrane-bound nuclei and organelles belong to Kingdom Protista.',
      },
      {
        't': 'Step 3: Absorptive Heterotrophic Decomposers',
        'i':
            'Inspect the 3D Mushroom model. Examine its chitin cell wall and absorptive feeding, and assign it to Pedestal 3.',
        'o': 'Mushroom is positioned on Pedestal 3.',
        'c':
            'Heterotrophic multicellular eukaryotes with chitinous cell walls that absorb nutrients form Kingdom Fungi.',
      },
      {
        't': 'Step 4: Autotrophic Photosynthetic Producers',
        'i':
            'Inspect the 3D Rose Plant model. Check its cellulose cell wall and chloroplasts, and assign it to Pedestal 4.',
        'o': 'Rose plant is positioned on Pedestal 4.',
        'c': 'Multicellular autotrophs with cellulose cell walls capable of photosynthesis constitute Kingdom Plantae.',
      },
      {
        't': 'Step 5: Ingestive Multicellular Heterotrophs',
        'i': 'Inspect the 3D Frog model. Confirm the complete absence of a cell wall, and assign it to Pedestal 5.',
        'o': 'Frog is positioned on Pedestal 5.',
        'c': 'Multicellular heterotrophs without cell walls that ingest food actively belong to Kingdom Animalia.',
      },
      {
        't': 'Step 6: Example Organism Chips',
        'i': 'Click each example chip in the tray, then click its matching Pedestal button (Ped 1-5) to assign.',
        'o': 'All 10 items (5 specimens + 5 chip sets) are slotted.',
        'c': 'Every living organism maps systematically to a kingdom based on these 4 structural criteria.',
      },
    ],
    's2_steps': [
      {
        't': 'Step 1: Hierarchy as a Postal Address',
        'i': 'Understand that classification narrows down step-by-step from broad Kingdom to individual Species.',
        'o': 'Dual ladder tracks activated.',
        'c': 'Each successive rank down the ladder shares a larger number of specific common characteristics.',
      },
      {
        't': 'Step 2: Tiger Hierarchy (8 Rungs)',
        'i':
            'Drag or assign rank and value tokens for Tiger: Kingdom Animalia → Phylum Chordata → Sub-phylum Vertebrata → Class Mammalia → Order Carnivora → Family Felidae → Genus Panthera → Species P. tigris.',
        'o': 'Tiger address ladder completed with Sub-phylum Vertebrata.',
        'c': 'Vertebrates possess an internal vertebral column, placing them in Sub-phylum Vertebrata within Chordata.',
      },
      {
        't': 'Step 3: Pea Hierarchy (7 Standard Rungs)',
        'i':
            'Drag or assign rank and value tokens for Pea: Kingdom Plantae → Phylum Magnoliophyta → Class Magnoliopsida → Order Fabales → Family Fabaceae → Genus Pisum → Species P. sativum.',
        'o': 'Pea address ladder completed without sub-phylum.',
        'c':
            'The standard hierarchy has 7 primary ranks; intermediate ranks like sub-phylum are used only when necessary.',
      },
      {
        't': 'Step 4: Verification',
        'i': 'Click Verify on the canvas to check that both ladders match the textbook hierarchy.',
        'o': 'Both ladders verified.',
        'c': 'Species represents the basic unit of classification capable of interbreeding.',
      },
    ],
    's3_steps': [
      {
        't': 'Step 1: The Multilingual Dilemma',
        'i':
            'A tiger is called bagh in Hindi, puli in Tamil, tiger in English, and tigre in French. Binomial nomenclature solves this with one universal name.',
        'o': 'Binomial constructor ready.',
        'c': 'Common vernacular names vary across languages, requiring standardized scientific nomenclature.',
      },
      {
        't': 'Step 2: Build Tiger Binomial Name',
        'i': "Select 'Panthera' from the tray and click the Genus slot; select 'tigris' and click the Species slot.",
        'o': 'Tiger name forms Panthera tigris.',
        'c': 'The first word denotes the Genus (capitalized) and the second denotes the species (small letters).',
      },
      {
        't': 'Step 3: Build Mango Binomial Name',
        'i': "Select 'Mangifera' from the tray and click the Genus slot; select 'indica' and click the Species slot.",
        'o': 'Mango name forms Mangifera indica.',
        'c': 'Each unique biological species has an exclusive two-part Latinized scientific name.',
      },
      {
        't': 'Step 4: Confirm 3 Linnaean Rules',
        'i': 'Toggle the 3 rule checkboxes to confirm universal nomenclature rules and view the italicized formatting.',
        'o': 'Scientific names dynamically format in italics.',
        'c': 'Scientific names are italicized in print or underlined separately when written by hand.',
      },
    ],
    's1_learn':
        'Living organisms are grouped by 4 fundamental criteria: Cell type, Cell structure, Level of organisation, and Mode of nutrition into Monera, Protista, Fungi, Plantae, and Animalia.',
    's2_learn':
        'Taxonomic hierarchy works like a postal address: Kingdom → Phylum → (Sub-phylum in Tiger) → Class → Order → Family → Genus → Species. At each lower level, organisms share more specific features.',
    's3_learn':
        'Binomial nomenclature gives every organism a unique two-part scientific name: Genus (capitalized) + species (lowercase), printed in italics (*Panthera tigris*, *Mangifera indica*).',
    // The HTML stores these as <strong>/<br>/<em> markup; kept as head / bullet lines / footnote.
    'pedestalInfo': {
      '1': {
        'head': 'Pedestal 1 Criteria:',
        'lines': [
          'Cell Type: Prokaryotic (no nuclear envelope)',
          'Organisation: Unicellular',
          'Cell Wall: Present in most (peptidoglycan)',
          'Nutrition: Autotrophic or Heterotrophic',
        ],
        'foot': '(Kingdom Monera: Bacteria, Cyanobacteria, Archaea)',
      },
      '2': {
        'head': 'Pedestal 2 Criteria:',
        'lines': [
          'Cell Type: Eukaryotic (true nucleus & organelles)',
          'Organisation: Unicellular',
          'Locomotion: Cilia, flagella, or pseudopodia',
          'Nutrition: Autotrophic or Heterotrophic',
        ],
        'foot': '(Kingdom Protista: Amoeba, Paramecium, Euglena)',
      },
      '3': {
        'head': 'Pedestal 3 Criteria:',
        'lines': [
          'Cell Type: Eukaryotic',
          'Organisation: Multicellular (except Yeast)',
          'Cell Wall: Present, made of Chitin',
          'Nutrition: Absorptive Heterotrophic (Saprophytic)',
        ],
        'foot': '(Kingdom Fungi: Mushroom, Yeast, Aspergillus)',
      },
      '4': {
        'head': 'Pedestal 4 Criteria:',
        'lines': [
          'Cell Type: Eukaryotic',
          'Organisation: Multicellular',
          'Cell Wall: Present, made of Cellulose',
          'Nutrition: Autotrophic (Photosynthetic)',
        ],
        'foot': '(Kingdom Plantae: Mosses, Ferns, Pines, Flowering Plants)',
      },
      '5': {
        'head': 'Pedestal 5 Criteria:',
        'lines': [
          'Cell Type: Eukaryotic',
          'Organisation: Multicellular',
          'Cell Wall: Completely ABSENT',
          'Nutrition: Ingestive Heterotrophic (Holozoic)',
        ],
        'foot': '(Kingdom Animalia: Bird, Cat, Human, Frog)',
      },
    },
    // Strings hard-coded in the HTML script / attributes (not in its locale table).
    'ui': {
      'stepTag': 'STEP {n}/3',
      'criteria': 'Criteria',
      'chip': 'Chip',
      'ped': 'Ped {n}',
      'rungRank': 'Rung {n}: Rank',
      'value': 'Value',
    },
    'tools': {
      'lock': 'Lock/Unlock Camera Orbit & Pan',
      'zoomIn': 'Zoom In (Unlock to use)',
      'zoomOut': 'Zoom Out (Unlock to use)',
      'pan': 'Pan Mode (Unlock to use)',
      'labels': 'Toggle Visual Labels (Always Works)',
      'resetCam': 'Reset Camera View (Unlock to use)',
    },
    'toasts': {
      'reset': 'Lab completely reset to start.',
      'locked': 'Screen Locked: Camera fixed',
      'unlocked': 'Screen Unlocked: Orbit & Zoom enabled',
      'panOn': 'Pan Mode (Drag to move)',
      'panOff': 'Orbit Mode (Drag to rotate)',
      'labelsOn': 'Visual Labels: Visible',
      'labelsOff': 'Visual Labels: Hidden',
      'chipSelected': 'Selected Chip - Click a Pedestal button (Ped 1-5)',
      'specimenAssigned': '{name} -> Pedestal {n}',
      'chipAssigned': 'Chip assigned to Pedestal {n}',
      'selectTileFirst': 'Select a word tile from the Tool Tray first!',
      'tileSelected': 'Selected "{text}" - Now click a slot!',
      'placedQuoted': 'Placed "{text}"',
      'placed': 'Placed {text}',
      'incorrectPlacement': 'Incorrect Placement: {err}',
      's1Success': 'Five kingdoms correctly sorted! Advancing to Ladder...',
      's1SpecimensOk': 'Specimens correct! Now click & assign the 5 example chips below.',
      's1Incomplete': 'Check pedestal criteria hints and assign all 10 items.',
      's2Success': 'Classification address ladders verified! Advancing to Naming...',
      's2Fail': 'Some ladder rungs are incorrect or empty! Complete them as per textbook.',
      's3NameFail': 'Incorrect Name Construction! Genus must be Capitalized and species in lowercase.',
      's3RulesFail': 'Please confirm all 3 Linnaean rule checkboxes!',
      'stepReset': 'Step reset.',
      'hintS2': 'Order: Kingdom -> Phylum -> (Sub-phylum in Tiger) -> Class -> Order -> Family -> Genus -> Species',
      'hintS3': 'Genus is capitalized and comes first; species is in lowercase; printed in italics.',
    },
    'errors': {
      'bacterium': 'Bacterium is a Prokaryote (Monera -> Pedestal 1)!',
      'amoeba': 'Amoeba is a Unicellular Eukaryote (Protista -> Pedestal 2)!',
      'mushroom': 'Mushroom has chitin cell walls (Fungi -> Pedestal 3)!',
      'rose': 'Rose Plant is an autotroph with cellulose walls (Plantae -> Pedestal 4)!',
      'frog': 'Frog has no cell walls (Animalia -> Pedestal 5)!',
      'c_monera': 'Bacteria/Archaea chip belongs to Monera (Pedestal 1)!',
      'c_protista': 'Amoeba/Euglena chip belongs to Protista (Pedestal 2)!',
      'c_fungi': 'Mushroom/Yeast chip belongs to Fungi (Pedestal 3)!',
      'c_plantae': 'Mosses/Roses chip belongs to Plantae (Pedestal 4)!',
      'c_animalia': 'Bird/Cat/Frog chip belongs to Animalia (Pedestal 5)!',
    },
  },
  'hi': {
    'title': 'वर्गीकरण का पदानुक्रम (पांच जगत प्रणाली)',
    'subtitle': 'कक्षा 9 • जीवों में विविधता',
    'enterLab': 'वर्चुअल लैब में प्रवेश करें',
    'moduleSel': 'मॉड्यूल का चयन करें',
    'missionObj': 'मिशन उद्देश्य',
    'detailedSteps': 'चरणों का विस्तृत विवरण',
    'what_we_learn': 'हमने क्या सीखा',
    'taskInstr': 'गतिविधि कैसे करें:',
    'expOut': 'अपेक्षित परिणाम:',
    'conceptLearned': 'सीखा गया सिद्धांत:',
    'hint': 'संकेत',
    'resetStep': 'रीसेट',
    'verifyStep': 'सत्यापित करें',
    'btnReplay': 'पुनः चलाएं',
    'settings': 'सेटिंग्स',
    'visTheme': 'दृश्य थीम',
    'dark': 'डार्क',
    'light': 'लाइट',
    'txtScale': 'टेक्स्ट स्केलिंग',
    'labProgress': 'लैब प्रगति',
    'trayTitle': 'टूल ट्रे',
    'placeOnPed': 'मंच पर रखें:',
    'exampleChipsLabel': 'उदाहरण जीव चिप्स:',
    'specFeature': 'नमूना विशेषता',
    'gotIt': 'समझ गया',
    'genusSlot': 'जीनस स्लॉट',
    'speciesSlot': 'स्पीशीज स्लॉट',
    'tigerFigurine': 'बाघ का खिलौना',
    'mangoFruit': 'आम का फल',
    'tigerRungsLabel': '8 पायदान (उप-संघ)',
    'peaRungsLabel': '7 मानक पायदान',
    'itemsPlaced': 'वस्तुएं: {n}/10 रखी गईं',
    'bacterium': 'जीवाणु',
    'amoeba': 'अमीबा',
    'mushroom': 'कवक',
    'rose': 'पादप',
    'frog': 'जंतु',
    'ped1_label': 'मंच 1: मोनेरा',
    'ped2_label': 'मंच 2: प्रोटिस्टा',
    'ped3_label': 'मंच 3: फंजाई',
    'ped4_label': 'मंच 4: प्लांटी',
    'ped5_label': 'मंच 5: एनिमेलिया',
    'tigerLadder': 'बाघ ट्रैक',
    'peaLadder': 'मटर ट्रैक',
    'rulesConfirm': 'नियम चेकबॉक्स:',
    'rule1': '1. दो भाग: जीनस का नाम पहले, स्पीशीज का नाम दूसरे स्थान पर।',
    'rule2': '2. जीनस बड़े अक्षर (Capital) से शुरू होता है; स्पीशीज छोटे अक्षरों में।',
    'rule3': '3. छपाई में इटैलिक (तिरछा) या हाथ से लिखने पर रेखांकित किया जाता है।',
    'hud_s1': 'जगत मानदंडों के आधार पर 5 नमूनों और 5 उदाहरण चिप्स को मंचों पर रखें।',
    'hud_s2': 'बाघ और मटर के लिए पूर्ण वर्गीकरण पदानुक्रम पता सीढ़ी का निर्माण करें।',
    'hud_s3': 'द्विपद वैज्ञानिक नाम बनाएं और लिनियस के नामकरण नियमों को सत्यापित करें।',
    'callouts': {
      'bacterium': {
        't': 'जीवाणु नमूना',
        'b': 'कैप्सूल आकार, बिना केंद्रक झिल्ली का डीएनए (न्यूक्लियॉइड), एककोशिकीय प्रोकैरियोट।',
      },
      'amoeba': {'t': 'अमीबा नमूना', 'b': 'कूटपाद युक्त एककोशिकीय यूकैरियोट जिसमें सुस्पष्ट केंद्रक और अंगक होते हैं।'},
      'mushroom': {'t': 'मशरूम (कवक)', 'b': 'काइटिन कोशिका भित्ति युक्त बहुकोशिकीय अपघटक और अवशोषक परपोषी पोषण।'},
      'rose': {'t': 'गुलाब का पौधा', 'b': 'सेलूलोज़ भित्ति युक्त बहुकोशिकीय स्वपोषी, क्लोरोफिल और प्रकाश संश्लेषण।'},
      'frog': {'t': 'मेंढक नमूना', 'b': 'बिना कोशिका भित्ति वाला बहुकोशिकीय परपोषी जंतु और सक्रिय गमन।'},
    },
    'chips': {
      'c_monera': 'जीवाणु, आर्किया, सायनोबैक्टीरिया',
      'c_protista': 'अमीबा, पैरामीशियम, यूग्लीना',
      'c_fungi': 'मशरूम, यीस्ट, एस्परजिलस',
      'c_plantae': 'मॉस, फर्न, चीड़, गुलाब',
      'c_animalia': 'पक्षी, बिल्ली, मानव, मेंढक',
    },
    'concTitle': 'वैज्ञानिक निष्कर्ष और अवधारणा सारांश',
    'concHead1': '1. पांच जगत प्रणाली (व्हिटेकर, 1969)',
    'concBody1':
        'सजीवों को 4 मूलभूत संरचनात्मक मानदंडों: कोशिका प्रकार, कोशिका संरचना, संगठन का स्तर, और पोषण की विधि के आधार पर मोनेरा, प्रोटिस्टा, फंजाई, प्लांटी और एनिमेलिया में वर्गीकृत किया गया है।',
    'concHead2': '2. वर्गीकरण पता सीढ़ी',
    'concBody2':
        'जैविक वर्गीकरण एक सार्वभौमिक डाक पते की तरह काम करता है: जगत → संघ → (बाघ में उप-संघ Vertebrata) → वर्ग → गण → कुल → जीनस → स्पीशीज। प्रत्येक निचला स्तर अधिक विशिष्ट साझे लक्षण प्रकट करता है।',
    'concHead3': '3. सार्वभौमिक द्विपद नामकरण (लिनियस)',
    'concBody3':
        'स्थानीय भाषाओं के भ्रम को दूर करते हुए प्रत्येक जीव को एक सटीक दो-भाग लैटिन वैज्ञानिक नाम दिया जाता है: Panthera tigris (बाघ) और Mangifera indica (आम), जिसमें जीनस Capital में और स्पीशीज छोटे अक्षरों में इटैलिक में छपा होता है।',
    's1_title': '1. मानदंडों द्वारा पांच जगत',
    's2_title': '2. वर्गीकरण पता सीढ़ी',
    's3_title': '3. द्विपद वैज्ञानिक नाम',
    's1_obj':
        'कोशिका प्रकार, कोशिका संरचना, संगठन का स्तर, और पोषण की विधि के आधार पर जीवों को पांच जगतों में वर्गीकृत करना।',
    's2_obj':
        'बाघ (8 स्तर उप-संघ सहित) और मटर (7 मानक स्तर) के लिए पूर्ण वर्गीकरण पदानुक्रम पता सीढ़ी का निर्माण करना।',
    's3_obj':
        'बाघ (Panthera tigris) और आम (Mangifera indica) के द्विपद नाम बनाना और लिनियस के सार्वभौमिक नियमों को सत्यापित करना।',
    's1_steps': [
      {
        't': 'कदम 1: कोशिका प्रकार और केंद्रक संगठन',
        'i': 'जीवाणु मॉडल का निरीक्षण करें। केंद्रक झिल्ली का अभाव देखकर मंच 1 पर रखें।',
        'o': 'जीवाणु मंच 1 पर स्थित हुआ।',
        'c': 'केंद्रक झिल्ली रहित एककोशिकीय प्रोकैरियोट मोनेरा जगत बनाते हैं।',
      },
      {
        't': 'कदम 2: अंगकों युक्त एककोशिकीय यूकैरियोट',
        'i': 'अमीबा मॉडल का निरीक्षण करें। इसके सुस्पष्ट केंद्रक को देखकर मंच 2 पर रखें।',
        'o': 'अमीबा मंच 2 पर स्थित हुआ।',
        'c': 'सुस्पष्ट केंद्रक वाले एककोशिकीय यूकैरियोट प्रोटिस्टा जगत में आते हैं।',
      },
      {
        't': 'कदम 3: अवशोषक परपोषी अपघटक',
        'i': 'मशरूम (कवक) का निरीक्षण करें। इसकी काइटिन भित्ति देखकर मंच 3 पर रखें।',
        'o': 'मशरूम मंच 3 पर स्थित हुआ।',
        'c': 'काइटिन भित्ति वाले अवशोषक परपोषी फंजाई (कवक) जगत बनाते हैं।',
      },
      {
        't': 'कदम 4: स्वपोषी प्रकाश संश्लेषक उत्पादक',
        'i': 'गुलाब के पौधे का निरीक्षण करें। इसकी सेलूलोज़ भित्ति देखकर मंच 4 पर रखें।',
        'o': 'गुलाब मंच 4 पर स्थित हुआ।',
        'c': 'सेलूलोज़ भित्ति वाले बहुकोशिकीय स्वपोषी प्लांटी जगत में आते हैं।',
      },
      {
        't': 'कदम 5: बहुकोशिकीय परपोषी जंतु',
        'i': 'मेंढक का निरीक्षण करें। कोशिका भित्ति के पूर्ण अभाव को देखकर मंच 5 पर रखें।',
        'o': 'मेंढक मंच 5 पर स्थित हुआ।',
        'c': 'बिना कोशिका भित्ति वाले बहुकोशिकीय परपोषी एनिमेलिया जगत बनाते हैं।',
      },
      {
        't': 'कदम 6: उदाहरण चिप्स का मिलान',
        'i': 'टूल ट्रे से उदाहरण जीवों के चिप्स पर क्लिक करें और संबंधित मंच (Ped 1-5) पर रखें।',
        'o': 'सभी 10 आइटम सुमेलित हुए।',
        'c': 'प्रत्येक जीव इन 4 मानदंडों के आधार पर एक जगत में आता है।',
      },
    ],
    's2_steps': [
      {
        't': 'कदम 1: पदानुक्रम पता सादृश्य',
        'i': 'समझें कि वर्गीकरण व्यापक जगत से संकीर्ण होकर विशिष्ट स्पीशीज तक कैसे पहुंचता है।',
        'o': 'दोनों सीढ़ियां सक्रिय हुईं।',
        'c': 'प्रत्येक निचले स्तर पर जीव अधिक विशिष्ट लक्षण साझा करते हैं।',
      },
      {
        't': 'कदम 2: बाघ का पदानुक्रम (8 पायदान)',
        'i':
            'बाघ के टोकन रखें: जगत Animalia → संघ Chordata → उप-संघ Vertebrata → वर्ग Mammalia → गण Carnivora → कुल Felidae → जीनस Panthera → स्पीशीज P. tigris।',
        'o': 'बाघ की पता सीढ़ी पूर्ण हुई।',
        'c': 'कशेरुक दंड की उपस्थिति बाघ को उप-संघ Vertebrata में रखती है।',
      },
      {
        't': 'कदम 3: मटर का पदानुक्रम (7 पायदान)',
        'i':
            'मटर के टोकन रखें: जगत Plantae → संघ Magnoliophyta → वर्ग Magnoliopsida → गण Fabales → कुल Fabaceae → जीनस Pisum → स्पीशीज P. sativum।',
        'o': 'मटर की पता सीढ़ी पूर्ण हुई।',
        'c': 'मानक पदानुक्रम में 7 प्राथमिक पायदान होते हैं।',
      },
      {
        't': 'कदम 4: सत्यापन',
        'i': 'कैनवास पर सत्यापित करें पर क्लिक करके पुष्टि करें।',
        'o': 'दोनों सीढ़ियां सत्यापित हुईं।',
        'c': 'स्पीशीज वर्गीकरण की सबसे बुनियादी प्रजनन योग्य इकाई है।',
      },
    ],
    's3_steps': [
      {
        't': 'कदम 1: बहुभाषी भ्रम और समाधान',
        'i': 'बाघ को विभिन्न भाषाओं में विभिन्न नामों से जाना जाता है। द्विपद नामकरण एक वैश्विक नाम देता है।',
        'o': 'निर्माता तैयार।',
        'c': 'स्थानीय नामों की विविधता को दूर करने हेतु वैज्ञानिक नामकरण आवश्यक है।',
      },
      {
        't': 'कदम 2: बाघ का वैज्ञानिक नाम बनाएं',
        'i': "'Panthera' को जीनस स्लॉट में और 'tigris' को स्पीशीज स्लॉट में रखें।",
        'o': 'Panthera tigris बना।',
        'c': 'पहला शब्द जीनस (Capital) और दूसरा स्पीशीज (छोटे अक्षर) होता है।',
      },
      {
        't': 'कदम 3: आम का वैज्ञानिक नाम बनाएं',
        'i': "'Mangifera' को जीनस स्लॉट में और 'indica' को स्पीशीज स्लॉट में रखें।",
        'o': 'Mangifera indica बना।',
        'c': 'प्रत्येक प्रजाति का अनूठा दो-भाग वैज्ञानिक नाम होता है।',
      },
      {
        't': 'कदम 4: 3 लिनियस नियमों की पुष्टि',
        'i': 'तीनों नियमों के बॉक्स को चेक करें।',
        'o': 'वैज्ञानिक नाम इटैलिक रूप में प्रदर्शित हुए।',
        'c': 'वैज्ञानिक नामों को छपाई में इटैलिक या हाथ से लिखने पर रेखांकित किया जाता है।',
      },
    ],
    's1_learn': 'सजीवों को 4 मूलभूत मानदंडों के आधार पर पांच जगतों में वर्गीकृत किया जाता है।',
    's2_learn': 'वर्गीकरण पदानुक्रम डाक पते की तरह है: जगत → संघ → (उप-संघ) → वर्ग → गण → कुल → जीनस → स्पीशीज।',
    's3_learn':
        'द्विपद नामकरण प्रत्येक जीव को एक अनूठा दो-भाग वैज्ञानिक नाम देता है: जीनस (Capital) + स्पीशीज (छोटा अक्षर)।',
    'pedestalInfo': {
      '1': {
        'head': 'मंच 1 मानदंड:',
        'lines': ['कोशिका प्रकार: प्रोकैरियोटिक (केंद्रक झिल्ली नहीं)', 'संगठन: एककोशिकीय', 'पोषण: स्वपोषी या परपोषी'],
        'foot': '(मोनेरा: जीवाणु, सायनोबैक्टीरिया)',
      },
      '2': {
        'head': 'मंच 2 मानदंड:',
        'lines': [
          'कोशिका प्रकार: यूकैरियोटिक (सुस्पष्ट केंद्रक)',
          'संगठन: एककोशिकीय',
          'गमन: कूटपाद, कशाभिका या पक्ष्माभ',
        ],
        'foot': '(प्रोटिस्टा: अमीबा, पैरामीशियम)',
      },
      '3': {
        'head': 'मंच 3 मानदंड:',
        'lines': ['कोशिका प्रकार: यूकैरियोटिक', 'कोशिका भित्ति: काइटिन युक्त', 'पोषण: अवशोषक परपोषी (मृतोपजीवी)'],
        'foot': '(फंजाई: कवक, मशरूम, यीस्ट)',
      },
      '4': {
        'head': 'मंच 4 मानदंड:',
        'lines': ['कोशिका प्रकार: यूकैरियोटिक', 'कोशिका भित्ति: सेलूलोज़ युक्त', 'पोषण: स्वपोषी (प्रकाश संश्लेषण)'],
        'foot': '(प्लांटी: पादप, गुलाब, फर्न)',
      },
      '5': {
        'head': 'मंच 5 मानदंड:',
        'lines': ['कोशिका प्रकार: यूकैरियोटिक', 'कोशिका भित्ति: पूर्णतः अनुपस्थित', 'पोषण: परपोषी (भोजन निगलने वाले)'],
        'foot': '(एनिमेलिया: जंतु, मेंढक, पक्षी)',
      },
    },
    'ui': {
      'stepTag': 'चरण {n}/3',
      'criteria': 'मानदंड',
      'chip': 'चिप',
      'ped': 'Ped {n}',
      'rungRank': 'पायदान {n}: श्रेणी',
      'value': 'मान',
    },
    'tools': {
      'lock': 'कैमरा ऑर्बिट और पैन लॉक/अनलॉक करें',
      'zoomIn': 'ज़ूम इन (उपयोग के लिए अनलॉक करें)',
      'zoomOut': 'ज़ूम आउट (उपयोग के लिए अनलॉक करें)',
      'pan': 'पैन मोड (उपयोग के लिए अनलॉक करें)',
      'labels': 'दृश्य लेबल दिखाएँ/छिपाएँ (हमेशा काम करता है)',
      'resetCam': 'कैमरा दृश्य रीसेट करें (उपयोग के लिए अनलॉक करें)',
    },
    'toasts': {
      'reset': 'लैब पूरी तरह से प्रारंभ में रीसेट हो गई।',
      'locked': 'स्क्रीन लॉक: कैमरा स्थिर',
      'unlocked': 'स्क्रीन अनलॉक: घुमाना और ज़ूम सक्षम',
      'panOn': 'पैन मोड (खिसकाने के लिए खींचें)',
      'panOff': 'ऑर्बिट मोड (घुमाने के लिए खींचें)',
      'labelsOn': 'दृश्य लेबल: दिखाई दे रहे हैं',
      'labelsOff': 'दृश्य लेबल: छिपे हुए',
      'chipSelected': 'चिप चुनी गई - किसी मंच बटन (Ped 1-5) पर क्लिक करें',
      'specimenAssigned': '{name} -> मंच {n}',
      'chipAssigned': 'चिप मंच {n} पर रखी गई',
      'selectTileFirst': 'पहले टूल ट्रे से कोई शब्द टाइल चुनें!',
      'tileSelected': '"{text}" चुना गया - अब किसी स्लॉट पर क्लिक करें!',
      'placedQuoted': '"{text}" रखा गया',
      'placed': '{text} रखा गया',
      'incorrectPlacement': 'गलत स्थान: {err}',
      's1Success': 'पांचों जगत सही ढंग से छांटे गए! सीढ़ी की ओर बढ़ रहे हैं...',
      's1SpecimensOk': 'नमूने सही हैं! अब नीचे दिए 5 उदाहरण चिप्स पर क्लिक करके उन्हें रखें।',
      's1Incomplete': 'मंच मानदंड संकेत देखें और सभी 10 आइटम रखें।',
      's2Success': 'वर्गीकरण पता सीढ़ियां सत्यापित हुईं! नामकरण की ओर बढ़ रहे हैं...',
      's2Fail': 'कुछ सीढ़ी पायदान गलत या खाली हैं! इन्हें पाठ्यपुस्तक के अनुसार पूरा करें।',
      's3NameFail': 'गलत नाम निर्माण! जीनस Capital अक्षर से और स्पीशीज छोटे अक्षरों में होनी चाहिए।',
      's3RulesFail': 'कृपया लिनियस के तीनों नियम चेकबॉक्स की पुष्टि करें!',
      'stepReset': 'चरण रीसेट हुआ।',
      'hintS2': 'क्रम: जगत -> संघ -> (बाघ में उप-संघ) -> वर्ग -> गण -> कुल -> जीनस -> स्पीशीज',
      'hintS3': 'जीनस Capital अक्षर से शुरू होकर पहले आता है; स्पीशीज छोटे अक्षरों में; छपाई में इटैलिक।',
    },
    'errors': {
      'bacterium': 'जीवाणु एक प्रोकैरियोट है (मोनेरा -> मंच 1)!',
      'amoeba': 'अमीबा एक एककोशिकीय यूकैरियोट है (प्रोटिस्टा -> मंच 2)!',
      'mushroom': 'मशरूम में काइटिन की कोशिका भित्ति होती है (फंजाई -> मंच 3)!',
      'rose': 'गुलाब का पौधा सेलूलोज़ भित्ति वाला स्वपोषी है (प्लांटी -> मंच 4)!',
      'frog': 'मेंढक में कोशिका भित्ति नहीं होती (एनिमेलिया -> मंच 5)!',
      'c_monera': 'जीवाणु/आर्किया चिप मोनेरा (मंच 1) की है!',
      'c_protista': 'अमीबा/यूग्लीना चिप प्रोटिस्टा (मंच 2) की है!',
      'c_fungi': 'मशरूम/यीस्ट चिप फंजाई (मंच 3) की है!',
      'c_plantae': 'मॉस/गुलाब चिप प्लांटी (मंच 4) की है!',
      'c_animalia': 'पक्षी/बिल्ली/मेंढक चिप एनिमेलिया (मंच 5) की है!',
    },
  },
});

const _accent = _rt_Tw.emerald500;
const _accentDeep = _rt_Tw.emerald600;

const _specimenKeys = ['bacterium', 'amoeba', 'mushroom', 'rose', 'frog'];
const _chipKeys = ['c_monera', 'c_protista', 'c_fungi', 'c_plantae', 'c_animalia'];

/// Correct pedestal for every specimen / example chip (HTML validateStep).
const _specimenTargets = {'bacterium': 1, 'amoeba': 2, 'mushroom': 3, 'rose': 4, 'frog': 5};
const _chipTargets = {'c_monera': 1, 'c_protista': 2, 'c_fungi': 3, 'c_plantae': 4, 'c_animalia': 5};

/// Specimen spots on the bench: initial build / resetLab, and the slightly
/// tighter row the HTML `resetStep` uses for scenario 1.
const _specimenHome = {
  'bacterium': (-5.2, 0.45, 3.5),
  'amoeba': (-2.6, 0.45, 3.5),
  'mushroom': (0.0, 0.45, 3.5),
  'rose': (2.6, 0.45, 3.5),
  'frog': (5.2, 0.45, 3.5),
};
const _specimenStepReset = {
  'bacterium': (-4.2, 0.4, 3.2),
  'amoeba': (-2.1, 0.4, 3.2),
  'mushroom': (0.0, 0.4, 3.2),
  'rose': (2.1, 0.4, 3.2),
  'frog': (4.2, 0.4, 3.2),
};

/// Five pedestals in a wide arc (no overlap).
const _pedestalPositions = [(-5.2, 0.0, -1.6), (-2.6, 0.0, -2.0), (0.0, 0.0, -2.2), (2.6, 0.0, -2.0), (5.2, 0.0, -1.6)];

// Kingdom colours / icons in pedestal order (cyan, emerald, amber, rose, green).
const _kingdomIcons = [Icons.medication, Icons.water_drop, Icons.eco, Icons.local_florist, Icons.pets];
const _kingdom300 = [Color(0xFF67E8F9), Color(0xFF6EE7B7), Color(0xFFFCD34D), Color(0xFFFDA4AF), Color(0xFF86EFAC)];
const _kingdom400 = [Color(0xFF22D3EE), Color(0xFF34D399), Color(0xFFFBBF24), Color(0xFFFB7185), Color(0xFF4ADE80)];
const _kingdom500 = [Color(0xFF06B6D4), Color(0xFF10B981), Color(0xFFF59E0B), Color(0xFFF43F5E), Color(0xFF22C55E)];
const _kingdom700 = [Color(0xFF0E7490), Color(0xFF047857), Color(0xFFB45309), Color(0xFFBE123C), Color(0xFF15803D)];

/// Textbook ladders checked by Verify (scenario 2).
const _tigerRankAnswer = ['Kingdom', 'Phylum', 'Sub-phylum', 'Class', 'Order', 'Family', 'Genus', 'Species'];
const _tigerValueAnswer = [
  'Animalia',
  'Chordata',
  'Vertebrata',
  'Mammalia',
  'Carnivora',
  'Felidae',
  'Panthera',
  'P. tigris',
];
const _peaRankAnswer = ['Kingdom', 'Phylum', 'Class', 'Order', 'Family', 'Genus', 'Species'];
const _peaValueAnswer = ['Plantae', 'Magnoliophyta', 'Magnoliopsida', 'Fabales', 'Fabaceae', 'Pisum', 'P. sativum'];

/// Scenario 2 token palette (data-val, data-category).
const _ladderTokenDefs = [
  ('Kingdom', 'rank'),
  ('Phylum', 'rank'),
  ('Sub-phylum', 'rank'),
  ('Class', 'rank'),
  ('Order', 'rank'),
  ('Family', 'rank'),
  ('Genus', 'rank'),
  ('Species', 'rank'),
  ('Animalia', 'value'),
  ('Chordata', 'value'),
  ('Vertebrata', 'value'),
  ('Mammalia', 'value'),
  ('Carnivora', 'value'),
  ('Felidae', 'value'),
  ('Panthera', 'value'),
  ('P. tigris', 'value'),
  ('Plantae', 'value'),
  ('Magnoliophyta', 'value'),
  ('Magnoliopsida', 'value'),
  ('Fabales', 'value'),
  ('Fabaceae', 'value'),
  ('Pisum', 'value'),
  ('P. sativum', 'value'),
];

/// Scenario 3 word tiles (text, type); decoys break the capitalisation rule.
const _wordTileDefs = [
  ('Panthera', 'genus-tiger'),
  ('tigris', 'species-tiger'),
  ('Mangifera', 'genus-mango'),
  ('indica', 'species-mango'),
  ('panthera', 'decoy'),
  ('TIGRIS', 'decoy'),
  ('mangifera', 'decoy'),
  ('Indica', 'decoy'),
];

/// A ladder token being dragged (HTML data-val / data-category).
typedef _LadderToken = ({String val, String cat});

class Cl9Ch12A3HierarchyFiveKingdomsPage extends StatefulWidget {
  const Cl9Ch12A3HierarchyFiveKingdomsPage({super.key});

  @override
  State<Cl9Ch12A3HierarchyFiveKingdomsPage> createState() => _Cl9Ch12A3HierarchyFiveKingdomsPageState();
}

class _Cl9Ch12A3HierarchyFiveKingdomsPageState extends State<Cl9Ch12A3HierarchyFiveKingdomsPage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(background: const Color(0xFF020617));
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 45,
    position: _rt_V3(0, 6, 13),
    target: _rt_V3(0, 1.2, 0),
    near: 0.1,
    far: 100,
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  // Restart/dispose abandon a running move instead of letting it finish.
  final _rt_TweenRunner _tweens = _rt_TweenRunner(resumeOnCancel: false);
  final _rt_ShellController _shell = _rt_ShellController();
  final math.Random _rng = math.Random();

  final Map<String, _rt_Node3D> _specimenMeshes = {};
  final List<_rt_Node3D> _pedestals = [];
  final List<_rt_Label3D> _pedLabels = [];
  final Map<String, _rt_Label3D> _specLabels = {};
  late _rt_Mesh3D _table;
  late _rt_Node3D _s2Group, _s3Group;
  final Map<String, int> _moveTokens = {};
  double _time = 0;

  /// Camera distance for the current canvas shape (HTML: 13 desktop / 17.5 mobile).
  double _homeZ = 13;

  // --- LAB STATE ---
  int _step = 1;
  bool _locked = true; // camera locked by default
  bool _panMode = false;
  bool _labelsVisible = true;

  // Scenario 1
  String _activeItemType = 'specimen';
  String _activeSpecimen = 'bacterium';
  String? _activeChip;

  /// Tray token with the `.selected` look: `spec:KEY` or `chip:KEY`.
  String? _selectedToken;

  /// Subject of the "Place on Pedestal:" label: a specimen key, 'chip' or null.
  String? _assignFor;
  final Map<String, int> _s1Specimens = {for (final k in _specimenKeys) k: 0};
  final Map<String, int> _s1Chips = {for (final k in _chipKeys) k: 0};
  String? _calloutKey;
  final Set<String> _errorChips = {};
  int _errorToken = 0;

  // Scenario 2
  final List<String?> _tigerRanks = List<String?>.filled(8, null);
  final List<String?> _tigerValues = List<String?>.filled(8, null);
  final List<String?> _peaRanks = List<String?>.filled(7, null);
  final List<String?> _peaValues = List<String?>.filled(7, null);

  // Scenario 3
  String? _selectedTile;
  String? _tigerGenus, _tigerSpecies, _mangoGenus, _mangoSpecies;
  bool _rule1 = false, _rule2 = false, _rule3 = false;
  List<(String, String)> _wordTiles = [];

  // UI
  int? _openAccordion = 0;
  Offset _hudOffset = Offset.zero;
  Offset _trayOffset = Offset.zero;
  bool _trayCollapsed = false;
  // Mirrors the shell sidebar (the menu button covers the canvas corner when it is closed).
  bool _sidebarOpen = true;

  // Timers (setTimeout) - cancelled on restart / dispose.
  final List<Timer> _timers = [];
  final ScrollController _trayScroll = ScrollController();
  int _gen = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _init3D();
    _shuffleTiles();
    _applyStepVisibility();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    for (final t in _timers) {
      t.cancel();
    }
    _tweens.cancelAll();
    _viewCtrl.dispose();
    _trayScroll.dispose();
    super.dispose();
  }

  void _after(int ms, VoidCallback fn) {
    final g = _gen;
    _timers.add(
      Timer(Duration(milliseconds: ms), () {
        if (!mounted || g != _gen) return;
        fn();
      }),
    );
  }

  bool get _dark => _rt_appTheme.isDark;

  String _fmt(String template, Map<String, String> values) {
    var out = template;
    values.forEach((k, v) => out = out.replaceAll('{$k}', v));
    return out;
  }

  void _toast(String msg, {Color color = _rt_Tw.emerald500, IconData icon = Icons.check_circle}) {
    _shell.showToast(msg, color: color, icon: icon, ms: 2600);
  }

  void _errorToast(String msg) => _toast(msg, color: _rt_Tw.red500, icon: Icons.cancel);

  void _hintToast(String msg) => _toast(msg, color: _rt_Tw.amber500, icon: Icons.lightbulb);

  // ------------------------------------------------------------ scene ---
  void _init3D() {
    _scene.setLights([
      _rt_Light3D.hemisphere(color: const Color(0xFFE0F2FE), groundColor: const Color(0xFF0F172A), intensity: 0.8),
      _rt_Light3D.directional(_rt_V3(8, 15, 10), intensity: 0.8),
    ]);
    _camera.maxPolarAngle = math.pi / 2 + 0.02;

    // THREE.GridHelper(26, 26, 0x10b981, 0x1e293b) on the floor, always behind.
    final grid = <_rt_V3>[];
    for (var i = -13; i <= 13; i++) {
      if (i == 0) continue;
      final d = i.toDouble();
      grid
        ..add(_rt_V3(d, 0, -13))
        ..add(_rt_V3(d, 0, 13))
        ..add(_rt_V3(-13, 0, d))
        ..add(_rt_V3(13, 0, d));
    }
    _scene.add(
      _rt_Line3D(grid, color: const Color(0xFF1E293B), width: 1, segments: true)
        ..depthBias = 1000
        ..pickable = false,
    );
    _scene.add(
      _rt_Line3D(
          [_rt_V3(0, 0, -13), _rt_V3(0, 0, 13), _rt_V3(-13, 0, 0), _rt_V3(13, 0, 0)],
          color: const Color(0xFF10B981),
          width: 1.2,
          segments: true,
        )
        ..depthBias = 999
        ..pickable = false,
    );

    // Specimen bench in front.
    _table = _rt_Mesh3D(_rt_Geometry3D.box(12.5, 0.35, 2.2), _rt_Material3D(color: const Color(0xFF1E293B)))
      ..position.set(0, 0.175, 3.5)
      ..pickable = false;
    _scene.add(_table);

    // Five pedestals with glowing rings.
    final baseGeo = _rt_Geometry3D.cylinder(0.85, 1.05, 0.35, segments: 24);
    final ringGeo = _rt_Geometry3D.torus(0.82, 0.035, radialSegments: 4, tubularSegments: 40);
    final baseMat = _rt_Material3D(color: const Color(0xFF1E293B));
    final ringMat = _rt_Material3D(color: const Color(0xFF10B981), unlit: true);
    for (var i = 0; i < 5; i++) {
      final (x, y, z) = _pedestalPositions[i];
      final ped = _rt_Node3D(name: 'ped-${i + 1}')..position.set(x, y, z);
      ped.add(_rt_Mesh3D(baseGeo, baseMat)..position.y = 0.175);
      ped.add(
        _rt_Mesh3D(ringGeo, ringMat)
          ..rotation.x = math.pi / 2
          ..position.y = 0.36,
      );
      _scene.add(ped);
      _pedestals.add(ped);
    }

    _specimenMeshes['bacterium'] = _buildBacterium();
    _specimenMeshes['amoeba'] = _buildAmoeba();
    _specimenMeshes['mushroom'] = _buildMushroom();
    _specimenMeshes['rose'] = _buildRose();
    _specimenMeshes['frog'] = _buildFrog();
    for (final k in _specimenKeys) {
      final (x, y, z) = _specimenHome[k]!;
      _scene.add(_specimenMeshes[k]!..position.set(x, y, z));
    }
    _buildMascots();

    // Attached labels (the HTML projected-label overlay).
    for (var i = 0; i < 5; i++) {
      final l = _rt_Label3D('', name: 'ped-label-${i + 1}', pixelHeight: 10);
      _scene.add(l);
      _pedLabels.add(l);
    }
    for (final k in _specimenKeys) {
      final l = _rt_Label3D('', name: 'spec-label-$k', pixelHeight: 10)..pickable = false;
      _scene.add(l);
      _specLabels[k] = l;
    }
    _placeLabels();
  }

  /// Uniform Catmull-Rom samples through [pts] (THREE.CatmullRomCurve3).
  List<_rt_V3> _catmullRom(List<_rt_V3> pts, int samples) {
    final out = <_rt_V3>[];
    final n = pts.length - 1;
    for (var s = 0; s <= samples; s++) {
      final u = s / samples * n;
      final i = math.min(u.floor(), n - 1);
      final t = u - i;
      final p0 = pts[math.max(i - 1, 0)], p1 = pts[i], p2 = pts[i + 1], p3 = pts[math.min(i + 2, n)];
      double f(double a, double b, double c, double d) =>
          0.5 * (2 * b + (-a + c) * t + (2 * a - 5 * b + 4 * c - d) * t * t + (-a + 3 * b - 3 * c + d) * t * t * t);
      out.add(_rt_V3(f(p0.x, p1.x, p2.x, p3.x), f(p0.y, p1.y, p2.y, p3.y), f(p0.z, p1.z, p2.z, p3.z)));
    }
    return out;
  }

  /// Capsule + coiled chromatin + pili + flagella.
  _rt_Node3D _buildBacterium() {
    final g = _rt_Node3D(name: 'bacterium');
    final capMat = _rt_Material3D(color: const Color(0xFF0891B2), opacity: 0.75, shininess: 0.6, metalness: 0.1);
    // Cylinder body + two hemispheres, tilted 45 degrees.
    g.add(
      _rt_Mesh3D(_rt_Geometry3D.capsule(0.38, 1.1, segments: 16, capSegments: 5), capMat)..rotation.z = math.pi / 4,
    );

    // Glowing red DNA coils (nucleoid) inside.
    final dnaGeo = _rt_Geometry3D.torus(0.12, 0.025, radialSegments: 4, tubularSegments: 12);
    final dnaMat = _rt_Material3D(color: const Color(0xFFF43F5E), unlit: true);
    for (var i = 0; i < 9; i++) {
      g.add(
        _rt_Mesh3D(dnaGeo, dnaMat)
          ..position.set(
            (_rng.nextDouble() - 0.5) * 0.3,
            (_rng.nextDouble() - 0.5) * 0.3,
            (_rng.nextDouble() - 0.5) * 0.15,
          )
          ..rotation.set(_rng.nextDouble() * math.pi, _rng.nextDouble() * math.pi, _rng.nextDouble() * math.pi),
      );
    }

    // Radial pili / fimbriae (thin cylinders -> line segments).
    final pili = <_rt_V3>[];
    for (var i = 0; i < 28; i++) {
      final u = _rng.nextDouble() * math.pi * 2;
      final v = (_rng.nextDouble() - 0.5) * math.pi;
      final p = _rt_V3(math.cos(u) * 0.42, math.sin(v) * 0.5, math.sin(u) * 0.42);
      final dir = _rt_M3.eulerXYZ(u, v, 0).apply(_rt_V3(0, 1, 0));
      pili
        ..add(p - dir * 0.11)
        ..add(p + dir * 0.11);
    }
    g.add(_rt_Line3D(pili, color: const Color(0xFF67E8F9), width: 1, segments: true)..pickable = false);

    // Curved flagella strands.
    for (var i = 0; i < 3; i++) {
      final pts = _catmullRom([
        _rt_V3(-0.55, -0.35, i * 0.05),
        _rt_V3(-0.85, -0.55, i * 0.08 + 0.1),
        _rt_V3(-1.15, -0.75, i * 0.08 - 0.1),
        _rt_V3(-1.45, -0.95, i * 0.05),
      ], 18);
      g.add(_rt_Line3D(pts, color: const Color(0xFF06B6D4), width: 1.6)..pickable = false);
    }
    return g;
  }

  /// Endoplasm + pseudopodia lobes + true nucleus + vacuoles.
  _rt_Node3D _buildAmoeba() {
    final g = _rt_Node3D(name: 'amoeba');
    final mat = _rt_Material3D(color: const Color(0xFF10B981), opacity: 0.8, shininess: 0.5, metalness: 0.05);
    g.add(_rt_Mesh3D(_rt_Geometry3D.sphere(0.68, widthSegments: 16, heightSegments: 12), mat));

    final lobeGeo = _rt_Geometry3D.sphere(0.3, widthSegments: 12, heightSegments: 8);
    const lobes = [
      (0.55, 0.2, 0.15, 1.3, 0.7, 0.8),
      (-0.5, 0.35, -0.1, 1.2, 0.8, 0.7),
      (0.2, -0.45, 0.2, 0.8, 1.4, 0.7),
      (-0.35, -0.3, -0.2, 1.1, 0.9, 1.2),
      (0.1, 0.5, -0.15, 0.9, 1.2, 0.9),
      (-0.15, 0.1, 0.45, 0.9, 0.8, 1.3),
    ];
    for (final (x, y, z, sx, sy, sz) in lobes) {
      g.add(
        _rt_Mesh3D(lobeGeo, mat)
          ..position.set(x, y, z)
          ..scale.set(sx, sy, sz),
      );
    }

    // True nucleus, nucleolus, contractile & food vacuoles.
    g.add(
      _rt_Sphere3D(0.24, _rt_Material3D(color: const Color(0xFF7C3AED), shininess: 0.4))..position.set(0.12, 0.1, 0.05),
    );
    g.add(
      _rt_Sphere3D(0.09, _rt_Material3D(color: const Color(0xFFF43F5E), unlit: true))..position.set(0.14, 0.12, 0.1),
    );
    g.add(
      _rt_Sphere3D(0.15, _rt_Material3D(color: const Color(0xFFA7F3D0), unlit: true))..position.set(-0.25, -0.18, 0.12),
    );
    final foodMat = _rt_Material3D(color: const Color(0xFFFDE047), unlit: true);
    for (var i = 0; i < 5; i++) {
      g.add(
        _rt_Sphere3D(0.06, foodMat)
          ..position.set(
            (_rng.nextDouble() - 0.5) * 0.4,
            (_rng.nextDouble() - 0.5) * 0.4,
            (_rng.nextDouble() - 0.5) * 0.3,
          ),
      );
    }
    return g;
  }

  /// Agaricus: stipe, annulus ring, spore gills and cap.
  _rt_Node3D _buildMushroom() {
    final g = _rt_Node3D(name: 'mushroom');
    g.add(
      _rt_Mesh3D(_rt_Geometry3D.cylinder(0.16, 0.25, 1.2, segments: 16), _rt_Material3D(color: const Color(0xFFF8FAFC)))
        ..position.y = 0.55,
    );
    g.add(
      _rt_Mesh3D(
          _rt_Geometry3D.torus(0.22, 0.04, radialSegments: 6, tubularSegments: 20),
          _rt_Material3D(color: const Color(0xFFE2E8F0)),
        )
        ..rotation.x = math.pi / 2
        ..position.y = 0.75,
    );
    g.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.74, 0.22, 0.12, segments: 20),
        _rt_Material3D(color: const Color(0xFF92400E)),
      )..position.y = 1.05,
    );
    g.add(
      _rt_Mesh3D(
        _rt_Geometry3D.sphere(0.78, widthSegments: 20, heightSegments: 8, thetaLength: math.pi / 2),
        _rt_Material3D(color: const Color(0xFFD97706), shininess: 0.4),
      )..position.y = 1.1,
    );
    return g;
  }

  /// Stem, chloroplast leaves and concentric petals.
  _rt_Node3D _buildRose() {
    final g = _rt_Node3D(name: 'rose');
    g.add(
      _rt_Mesh3D(_rt_Geometry3D.cylinder(0.06, 0.08, 1.35, segments: 8), _rt_Material3D(color: const Color(0xFF15803D)))
        ..position.y = 0.65,
    );
    final leafGeo = _rt_Geometry3D.box(0.35, 0.03, 0.2);
    final leafMat = _rt_Material3D(color: const Color(0xFF22C55E), shininess: 0.3);
    for (var i = 0; i < 4; i++) {
      g.add(
        _rt_Mesh3D(leafGeo, leafMat)
          ..position.set(i.isEven ? 0.2 : -0.2, 0.35 + i * 0.22, 0)
          ..rotation.set(0, i * 0.3, i.isEven ? -0.4 : 0.4),
      );
    }
    final flower = _rt_Node3D()..position.y = 1.35;
    final bloomMat = _rt_Material3D(color: const Color(0xFFE11D48), shininess: 0.4);
    flower.add(_rt_Sphere3D(0.2, bloomMat));
    final petalGeo = _rt_Geometry3D.cylinder(0.24, 0.28, 0.08, segments: 12);
    for (var i = 0; i < 6; i++) {
      final a = i * math.pi / 3;
      flower.add(
        _rt_Mesh3D(petalGeo, bloomMat)
          ..rotation.set(math.pi / 4, a, 0)
          ..position.set(math.cos(a) * 0.12, 0, math.sin(a) * 0.12),
      );
    }
    g.add(flower);
    return g;
  }

  /// Contoured torso, snout, golden eyes with slit pupils, limbs.
  _rt_Node3D _buildFrog() {
    final g = _rt_Node3D(name: 'frog');
    final frogMat = _rt_Material3D(color: const Color(0xFF16A34A), shininess: 0.5, metalness: 0.05);
    g.add(
      _rt_Mesh3D(_rt_Geometry3D.sphere(0.52, widthSegments: 16, heightSegments: 12), frogMat)
        ..scale.set(1.15, 0.65, 1.4),
    );
    g.add(
      _rt_Mesh3D(_rt_Geometry3D.cone(0.48, 0.5, segments: 12), frogMat)
        ..rotation.x = math.pi / 2
        ..scale.set(1.0, 1.0, 0.5)
        ..position.set(0, 0.08, 0.7),
    );
    final eyeMat = _rt_Material3D(color: const Color(0xFFFACC15), shininess: 0.8, metalness: 0.2);
    final pupilGeo = _rt_Geometry3D.box(0.13, 0.035, 0.06);
    final pupilMat = _rt_Material3D(color: const Color(0xFF000000), unlit: true);
    for (final x in [-0.24, 0.24]) {
      g.add(_rt_Sphere3D(0.13, eyeMat)..position.set(x, 0.35, 0.48));
      g.add(_rt_Mesh3D(pupilGeo, pupilMat)..position.set(x, 0.37, 0.59));
    }
    final limbMat = _rt_Material3D(color: const Color(0xFF15803D), shininess: 0.3);
    final armGeo = _rt_Geometry3D.cylinder(0.06, 0.06, 0.45, segments: 8);
    final legGeo = _rt_Geometry3D.torus(0.28, 0.09, radialSegments: 6, tubularSegments: 12, arc: math.pi);
    for (final side in [-1.0, 1.0]) {
      g.add(
        _rt_Mesh3D(armGeo, limbMat)
          ..position.set(0.4 * side, -0.1, 0.45)
          ..rotation.z = -0.3 * side,
      );
      g.add(
        _rt_Mesh3D(legGeo, limbMat)
          ..position.set(0.44 * side, -0.05, -0.22)
          ..rotation.y = -math.pi / 3 * side,
      );
    }
    return g;
  }

  void _buildMascots() {
    _s2Group = _rt_Node3D(name: 's2')..visible = false;
    _s2Group.add(
      _rt_Mesh3D(_rt_Geometry3D.box(1.4, 0.9, 2.0), _rt_Material3D(color: const Color(0xFFF59E0B)))
        ..position.set(-4.5, 2, 0),
    );
    _s2Group.add(
      _rt_Mesh3D(_rt_Geometry3D.cylinder(0.1, 0.15, 2.6, segments: 12), _rt_Material3D(color: const Color(0xFF22C55E)))
        ..position.set(4.5, 2, 0),
    );
    _scene.add(_s2Group);

    _s3Group = _rt_Node3D(name: 's3')..visible = false;
    _s3Group.add(
      _rt_Mesh3D(
          _rt_Geometry3D.sphere(1.0, widthSegments: 18, heightSegments: 12),
          _rt_Material3D(color: const Color(0xFFFBBF24), shininess: 0.5),
        )
        ..scale.set(0.8, 1.3, 0.9)
        ..position.set(-4.2, 2, 0),
    );
    _scene.add(_s3Group);
  }

  Color _kingdomText(int i) => _dark ? _kingdom300[i] : _kingdom700[i];

  /// Keeps the attached labels translated and themed.
  void _updateLabels() {
    final bg = _dark ? const Color(0xEB0F172A) : const Color(0xF7FFFFFF);
    for (var i = 0; i < 5; i++) {
      _pedLabels[i]
        ..text = '${_tx.s('ped${i + 1}_label')}   (? ${_tx.s('hint')})'
        ..color = _kingdomText(i)
        ..background = bg
        ..borderColor = _kingdom500[i].withValues(alpha: 0.5);
      _specLabels[_specimenKeys[i]]!
        ..text = _tx.s(_specimenKeys[i])
        ..color = _kingdomText(i)
        ..background = bg
        ..borderColor = _kingdom500[i].withValues(alpha: 0.4);
    }
  }

  /// Pedestal labels 0.85 above the ring, specimen labels under each model.
  void _placeLabels() {
    final show = _step == 1 && _labelsVisible;
    for (var i = 0; i < 5; i++) {
      final p = _pedestals[i].position;
      _pedLabels[i]
        ..visible = show
        ..position.set(p.x, p.y + 0.85, p.z);
    }
    for (final k in _specimenKeys) {
      final m = _specimenMeshes[k]!.position;
      _specLabels[k]!
        ..visible = show
        ..position.set(m.x, m.y - 0.65, m.z);
    }
  }

  void _onFrame(double dt) {
    _time += dt;
    _tweens.update(dt);
    final t = _time * 1.5; // Date.now() * 0.0015
    _specimenMeshes['bacterium']?.rotation.y = t * 0.3;
    _specimenMeshes['amoeba']?.rotation.z = t * 0.2;
    _specimenMeshes['mushroom']?.rotation.y = t * 0.15;
    _specimenMeshes['rose']?.rotation.y = t * 0.2;
    _specimenMeshes['frog']?.rotation.y = t * 0.25;
    _placeLabels();
    final open = _shell.isSidebarOpen;
    if (open != _sidebarOpen && mounted) setState(() => _sidebarOpen = open);
  }

  void _onSceneTap(_rt_SceneEvent e) {
    if (_step != 1 || !_labelsVisible) return;
    final hit = e.hitWhere((n) => n.name?.startsWith('ped-label-') ?? false);
    final num = int.tryParse(hit?.name?.substring('ped-label-'.length) ?? '');
    if (num != null) _showPedestalInfo(num);
  }

  /// Keeps the whole bench in view on narrow canvases (HTML isMob ? 17.5 : 13).
  void _fitCamera(Size s) {
    if (s.width <= 0 || s.height <= 0) return;
    final z = (3.5 + 17.0 / (s.width / s.height)).clamp(13.0, 26.0);
    if ((z - _homeZ).abs() < 0.05) return;
    _homeZ = z;
    if (_locked) _cameraReset();
  }

  void _cameraReset() {
    _camera.position.set(0, 6, _homeZ);
    _camera.target.set(0, 1.2, 0);
    _camera.zoom = 1;
  }

  void _resetSpecimenPositions(Map<String, (double, double, double)> spots) {
    for (final k in _specimenKeys) {
      _moveTokens[k] = (_moveTokens[k] ?? 0) + 1; // stop a running move
      final (x, y, z) = spots[k]!;
      _specimenMeshes[k]!.position.set(x, y, z);
    }
  }

  /// gsap.to(mesh.position, {pedestal + 1.25 up, 0.6 s, back.out(1.7)}).
  void _moveSpecimenTo(String key, int ped) {
    final mesh = _specimenMeshes[key];
    if (mesh == null) return;
    final target = _pedestals[ped - 1].position;
    final from = mesh.position.clone();
    final tx = target.x, ty = target.y + 1.25, tz = target.z;
    final token = (_moveTokens[key] ?? 0) + 1;
    _moveTokens[key] = token;
    unawaited(
      _tweens.run(600, (t) {
        if (_moveTokens[key] != token) return;
        mesh.position.set(from.x + (tx - from.x) * t, from.y + (ty - from.y) * t, from.z + (tz - from.z) * t);
      }, ease: _rt_Ease.outBack),
    );
  }

  // -------------------------------------------------------- navigation ---
  void _applyStepVisibility() {
    for (final m in _specimenMeshes.values) {
      m.visible = _step == 1;
    }
    for (final p in _pedestals) {
      p.visible = _step == 1;
    }
    _table.visible = _step == 1;
    _s2Group.visible = _step == 2;
    _s3Group.visible = _step == 3;
    _placeLabels();
  }

  void _setStep(int n, {bool sound = true}) {
    if (sound) _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _step = n;
      _openAccordion = 0;
    });
    _applyStepVisibility();
    _cameraReset();
  }

  // -------------------------------------------------------- 3D tools ---
  void _toggleLock() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _locked = !_locked);
    _toast(_tx.s(_locked ? 'toasts.locked' : 'toasts.unlocked'), icon: _locked ? Icons.lock : Icons.lock_open);
  }

  void _cameraZoom(int delta) {
    if (_locked) return;
    _camera.dolly(delta > 0 ? 0.85 : 1.15);
  }

  void _togglePanMode() {
    if (_locked) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _panMode = !_panMode);
    _viewCtrl.setMode(_panMode ? _rt_DragMode.pan : _rt_DragMode.rotate);
    _toast(_tx.s(_panMode ? 'toasts.panOn' : 'toasts.panOff'), icon: Icons.pan_tool);
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _labelsVisible = !_labelsVisible);
    _placeLabels();
    _toast(_tx.s(_labelsVisible ? 'toasts.labelsOn' : 'toasts.labelsOff'), icon: Icons.sell);
  }

  // ------------------------------------------------------- scenario 1 ---
  void _selectSpecimen(String name) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _activeItemType = 'specimen';
      _activeSpecimen = name;
      _activeChip = null;
      _selectedToken = 'spec:$name';
      _assignFor = name;
      _calloutKey = name; // specimen feature callout
    });
  }

  void _selectChip(String id) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _activeItemType = 'chip';
      _activeChip = id;
      _selectedToken = 'chip:$id';
      _assignFor = 'chip';
    });
    _toast(_tx.s('toasts.chipSelected'), icon: Icons.touch_app);
  }

  void _assignCurrentItem(int ped) {
    _rt_playSfx(_rt_Sfx.pop);
    if (_activeItemType == 'specimen') {
      final key = _activeSpecimen;
      setState(() => _s1Specimens[key] = ped);
      _moveSpecimenTo(key, ped);
      _toast(_fmt(_tx.s('toasts.specimenAssigned'), {'name': _tx.s(key), 'n': '$ped'}));
    } else if (_activeItemType == 'chip' && _activeChip != null) {
      setState(() => _s1Chips[_activeChip!] = ped);
      _toast(_fmt(_tx.s('toasts.chipAssigned'), {'n': '$ped'}));
    }
  }

  int get _placedCount => _s1Specimens.values.where((v) => v > 0).length + _s1Chips.values.where((v) => v > 0).length;

  void _highlightErrors() {
    final bad = {
      for (final k in _chipKeys)
        if (_s1Chips[k]! != 0 && _s1Chips[k] != _chipTargets[k]) k,
    };
    if (bad.isEmpty) return;
    final token = ++_errorToken;
    setState(() {
      _errorChips
        ..clear()
        ..addAll(bad);
    });
    _after(1200, () {
      if (token == _errorToken) setState(_errorChips.clear);
    });
  }

  void _resetS1State() {
    _s1Specimens.updateAll((k, v) => 0);
    _s1Chips.updateAll((k, v) => 0);
    _activeItemType = 'specimen';
    _activeSpecimen = 'bacterium';
    _activeChip = null;
    _selectedToken = null;
    _assignFor = null;
    _calloutKey = null;
    _errorChips.clear();
    _errorToken++;
  }

  // ------------------------------------------------------- scenario 2 ---
  void _dropLadderToken(_LadderToken token, String ladder, String type, int idx) {
    _rt_playSfx(_rt_Sfx.pop);
    if (token.cat != type) return; // rank tokens only fit rank rungs, values only value rungs
    setState(() {
      final target = ladder == 'tiger'
          ? (type == 'rank' ? _tigerRanks : _tigerValues)
          : (type == 'rank' ? _peaRanks : _peaValues);
      target[idx] = token.val;
    });
    _toast(_fmt(_tx.s('toasts.placed'), {'text': token.val}));
  }

  void _resetS2State() {
    for (final l in [_tigerRanks, _tigerValues, _peaRanks, _peaValues]) {
      l.fillRange(0, l.length, null);
    }
  }

  // ------------------------------------------------------- scenario 3 ---
  void _shuffleTiles() {
    _wordTiles = List.of(_wordTileDefs)..shuffle(_rng);
  }

  void _selectTile(String text) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _selectedTile = text);
    _toast(_fmt(_tx.s('toasts.tileSelected'), {'text': text}), icon: Icons.touch_app);
  }

  void _setSlot(String slot, String text) {
    switch (slot) {
      case 'genus-tiger':
        _tigerGenus = text;
      case 'species-tiger':
        _tigerSpecies = text;
      case 'genus-mango':
        _mangoGenus = text;
      case 'species-mango':
        _mangoSpecies = text;
    }
  }

  /// Tap a slot after selecting a tile (HTML quickAssignSlot).
  void _quickAssignSlot(String slot) {
    final text = _selectedTile;
    if (text == null) {
      _hintToast(_tx.s('toasts.selectTileFirst'));
      return;
    }
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _setSlot(slot, text);
      _selectedTile = null;
    });
    _toast(_fmt(_tx.s('toasts.placedQuoted'), {'text': text}));
  }

  /// Drag a tile onto a slot (HTML handleTokenDrop, scenario 3).
  void _dropTile(String text, String slot) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() => _setSlot(slot, text));
    _toast(_fmt(_tx.s('toasts.placed'), {'text': text}));
  }

  void _setRule(int i, bool v) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      switch (i) {
        case 1:
          _rule1 = v;
        case 2:
          _rule2 = v;
        default:
          _rule3 = v;
      }
    });
  }

  void _resetS3State() {
    _selectedTile = null;
    _tigerGenus = _tigerSpecies = _mangoGenus = _mangoSpecies = null;
    _rule1 = _rule2 = _rule3 = false;
    _shuffleTiles();
  }

  // ------------------------------------------------- verify / reset ---
  void _validateStep() {
    if (_step == 1) {
      final errors = <String>[
        for (final k in _specimenKeys)
          if (_s1Specimens[k] != _specimenTargets[k] && _s1Specimens[k] != 0) _tx.s('errors.$k'),
        for (final k in _chipKeys)
          if (_s1Chips[k] != _chipTargets[k] && _s1Chips[k] != 0) _tx.s('errors.$k'),
      ];
      final sCorrect = _specimenKeys.every((k) => _s1Specimens[k] == _specimenTargets[k]);
      final cCorrect = _chipKeys.every((k) => _s1Chips[k] == _chipTargets[k]);

      if (errors.isNotEmpty) {
        _rt_playSfx(_rt_Sfx.wrong);
        _errorToast(_fmt(_tx.s('toasts.incorrectPlacement'), {'err': errors.first}));
        _highlightErrors();
        return;
      }
      if (sCorrect && cCorrect) {
        _rt_playSfx(_rt_Sfx.success);
        _toast(_tx.s('toasts.s1Success'));
        _after(1200, () => _setStep(2));
      } else if (sCorrect) {
        _rt_playSfx(_rt_Sfx.magic);
        _hintToast(_tx.s('toasts.s1SpecimensOk'));
      } else {
        _rt_playSfx(_rt_Sfx.magic);
        _hintToast(_tx.s('toasts.s1Incomplete'));
      }
    } else if (_step == 2) {
      bool matches(List<String?> got, List<String> want) =>
          got.length == want.length && List.generate(want.length, (i) => got[i] == want[i]).every((ok) => ok);
      final tOk = matches(_tigerRanks, _tigerRankAnswer) && matches(_tigerValues, _tigerValueAnswer);
      final pOk = matches(_peaRanks, _peaRankAnswer) && matches(_peaValues, _peaValueAnswer);
      if (tOk && pOk) {
        _rt_playSfx(_rt_Sfx.success);
        _toast(_tx.s('toasts.s2Success'));
        _after(1200, () => _setStep(3));
      } else {
        _rt_playSfx(_rt_Sfx.wrong);
        _errorToast(_tx.s('toasts.s2Fail'));
      }
    } else {
      final tOk = _tigerGenus == 'Panthera' && _tigerSpecies == 'tigris';
      final mOk = _mangoGenus == 'Mangifera' && _mangoSpecies == 'indica';
      final rOk = _rule1 && _rule2 && _rule3;
      if (tOk && mOk && rOk) {
        _showConclusion();
      } else {
        _rt_playSfx(_rt_Sfx.wrong);
        _errorToast(_tx.s(!tOk || !mOk ? 'toasts.s3NameFail' : 'toasts.s3RulesFail'));
      }
    }
  }

  void _resetStep() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      if (_step == 1) {
        _resetS1State();
        _resetSpecimenPositions(_specimenStepReset);
      } else if (_step == 2) {
        _resetS2State();
      } else {
        _resetS3State();
      }
    });
    _toast(_tx.s('toasts.stepReset'), icon: Icons.restart_alt);
  }

  void _showHint() {
    if (_step == 1) {
      _showPedestalInfo(1);
    } else if (_step == 2) {
      _hintToast(_tx.s('toasts.hintS2'));
    } else {
      _hintToast(_tx.s('toasts.hintS3'));
    }
  }

  /// HTML resetLab (shell Restart / "Replay Lab").
  void _restart() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _gen++;
    _tweens.cancelAll();
    setState(() {
      _locked = true;
      _panMode = false;
      _labelsVisible = true;
      _resetS1State();
      _resetS2State();
      _resetS3State();
    });
    _viewCtrl.setMode(_rt_DragMode.rotate);
    _resetSpecimenPositions(_specimenHome);
    _setStep(1, sound: false);
    _toast(_tx.s('toasts.reset'), icon: Icons.restart_alt);
  }

  // ----------------------------------------------------------- popups ---
  Future<void> _showPedestalInfo(int n) async {
    _rt_playSfx(_rt_Sfx.magic);
    final info = _tx.map('pedestalInfo.$n');
    final lines = (info['lines'] as List? ?? const []).cast<String>();
    await _rt_showShellPopup(
      context,
      title: '${_tx.s('ped${n}_label')} ${_tx.s('ui.criteria')}',
      icon: Icons.info,
      color: _accentDeep,
      buttonLabel: _tx.s('gotIt'),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _rt_Lab.tinted(_rt_Tw.emerald50, _accent),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _rt_Lab.tintedBorder(_accent)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              info['head'] as String? ?? '',
              style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: _rt_Lab.text),
            ),
            const SizedBox(height: 6),
            for (final l in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text('• $l', style: TextStyle(fontSize: 12.5, color: _rt_Lab.textMuted, height: 1.35)),
              ),
            const SizedBox(height: 6),
            Text(
              info['foot'] as String? ?? '',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w600,
                color: _rt_Lab.onTinted(_rt_Tw.emerald400, _rt_Tw.emerald700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Scientific Conclusion & Concept Summary (+ confetti -> success popup).
  Future<void> _showConclusion() async {
    Widget card(Color c, IconData icon, String head, String body) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(Color.lerp(c, Colors.white, 0.9)!, c),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.tintedBorder(c)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 15, color: c),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  head,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.onTinted(c, Color.lerp(c, Colors.black, 0.35)!),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(body, style: TextStyle(fontSize: 12, color: _rt_Lab.textMuted, height: 1.4)),
        ],
      ),
    );
    await _shell.showSuccess(
      title: _tx.s('concTitle'),
      icon: Icons.check_circle,
      color: _accentDeep,
      buttonLabel: _tx.s('btnReplay'),
      body: Column(
        children: [
          card(_rt_Tw.emerald500, Icons.account_tree, _tx.s('concHead1'), _tx.s('concBody1')),
          card(_rt_Tw.amber500, Icons.stairs, _tx.s('concHead2'), _tx.s('concBody2')),
          card(_rt_Tw.cyan500, Icons.edit_note, _tx.s('concHead3'), _tx.s('concBody3')),
        ],
      ),
      onConfirm: () {
        if (mounted) _restart(); // a tap outside just closes the popup
      },
    );
  }

  // --------------------------------------------------------------- UI ---
  Color get _glass => _dark ? const Color(0xEB0F172A) : const Color(0xF7FFFFFF);
  Color get _glassBorder => _dark ? _rt_Tw.slate700 : _rt_Tw.slate300;
  Color get _tokenBg => _dark ? _rt_Tw.slate800 : _rt_Tw.slate200;
  Color get _tokenBorder => _dark ? _rt_Tw.slate700 : _rt_Tw.slate400;
  Color get _zoneBg => _dark ? _rt_Tw.slate900 : _rt_Tw.slate100;
  Color get _accentText => _dark ? _rt_Tw.emerald400 : _rt_Tw.emerald700;

  List<BoxShadow> get _panelShadow => [BoxShadow(color: _rt_Lab.shadow, blurRadius: 18, offset: const Offset(0, 6))];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: _rt_LangBuilder(
        builder: (context, lang) {
          _updateLabels();
          _scene.background = _dark ? const Color(0xFF020617) : const Color(0xFFF1F5F9);
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            theme: const _rt_ShellTheme(
              accent: _accentDeep,
              headerGradient: [_rt_Tw.slate950, Color(0xFF064E3B)],
              headerSubtitleColor: _rt_Tw.emerald400,
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('title'),
              subtitle: _tx.s('subtitle'),
              buttonLabel: _tx.s('enterLab'),
              icon: Icons.account_tree,
              buttonIcon: Icons.rocket_launch,
            ),
            onRestart: _restart,
            toolbarExtras: _toolButtons(),
            sidebarTop: _moduleSelect(),
            tabs: [
              _rt_ShellTab(label: _tx.s('detailedSteps'), icon: Icons.account_tree, builder: (_) => _teacherTab()),
            ],
            canvasBackground: _scene.background,
            canvas: LayoutBuilder(
              builder: (context, c) {
                _fitCamera(c.biggest);
                return _rt_Scene3DView(
                  scene: _scene,
                  camera: _camera,
                  controller: _viewCtrl,
                  cameraControls: !_locked,
                  onFrame: _onFrame,
                  onTap: _onSceneTap,
                );
              },
            ),
            canvasOverlays: [Positioned.fill(child: LayoutBuilder(builder: (context, c) => _overlayLayer(c.biggest)))],
          );
        },
      ),
    );
  }

  // --- 3D TOOLS (lock, zoom in/out, pan, labels, reset camera) ---
  List<Widget> _toolButtons() {
    Widget btn({
      required IconData icon,
      required String tip,
      required VoidCallback onTap,
      bool active = false,
      bool enabled = true,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.5),
        child: Tooltip(
          message: tip,
          child: Opacity(
            opacity: enabled ? 1 : 0.4,
            child: InkResponse(
              radius: 20,
              onTap: enabled ? onTap : null,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _rt_Lab.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: active ? _accent.withValues(alpha: 0.6) : Colors.transparent, width: 1.5),
                ),
                child: Icon(icon, size: 17, color: active ? _accentText : _rt_Lab.textMuted),
              ),
            ),
          ),
        ),
      );
    }

    return [
      btn(icon: _locked ? Icons.lock : Icons.lock_open, tip: _tx.s('tools.lock'), active: _locked, onTap: _toggleLock),
      btn(icon: Icons.add, tip: _tx.s('tools.zoomIn'), enabled: !_locked, onTap: () => _cameraZoom(1)),
      btn(icon: Icons.remove, tip: _tx.s('tools.zoomOut'), enabled: !_locked, onTap: () => _cameraZoom(-1)),
      btn(icon: Icons.pan_tool, tip: _tx.s('tools.pan'), enabled: !_locked, active: _panMode, onTap: _togglePanMode),
      btn(icon: Icons.sell, tip: _tx.s('tools.labels'), active: _labelsVisible, onTap: _toggleLabels),
      btn(icon: Icons.center_focus_strong, tip: _tx.s('tools.resetCam'), enabled: !_locked, onTap: _cameraReset),
    ];
  }

  // --- CANVAS OVERLAYS ---
  Widget _overlayLayer(Size size) {
    // Skip the portrait frames before the landscape switch.
    if (size.width < 240 || size.height < 200) return const SizedBox.shrink();
    final w = size.width, h = size.height;
    final hudLeft = _sidebarOpen ? 8.0 : 72.0; // clear of the shell menu button
    const hudRight = 72.0; // clear of the back button
    const contentTop = 72.0;
    final wide = w >= 560;
    final trayBottom = wide ? 8.0 : 54.0; // narrow: above the action buttons
    final trayWidth = wide ? math.min(380.0, w - 16 - 262) : w - 16 - 52;
    // The tray sizes to its content; it may use everything below the HUD.
    final trayMaxH = math.max(96.0, h - trayBottom - contentTop);
    final reservedBottom = (_trayCollapsed ? 44.0 : trayMaxH) + trayBottom + 12;

    return Stack(
      children: [
        // Keyed so the ladder and notebook never share one scroll position.
        if (_step == 2)
          Positioned(
            key: const ValueKey('s2-ladders'),
            top: contentTop,
            left: 8,
            right: 56,
            bottom: 0,
            child: _ladderOverlay(reservedBottom),
          ),
        if (_step == 3)
          Positioned(
            key: const ValueKey('s3-notebook'),
            top: contentTop,
            left: 8,
            right: 56,
            bottom: 0,
            child: _notebookOverlay(reservedBottom),
          ),
        if (_step == 1 && _labelsVisible && _calloutKey != null)
          Positioned(top: contentTop, right: 58, child: _specimenCallout()),
        Positioned(
          top: 8 + _hudOffset.dy,
          left: hudLeft + _hudOffset.dx,
          right: hudRight - _hudOffset.dx,
          child: Center(child: _hud(size, hudLeft, hudRight)),
        ),
        Positioned(
          left: 8 + _trayOffset.dx,
          bottom: trayBottom - _trayOffset.dy,
          width: trayWidth,
          child: _tray(size, trayWidth, trayBottom, trayMaxH),
        ),
        Positioned(right: 10, bottom: 8, child: _actionButtons()),
      ],
    );
  }

  // Draggable top HUD (Lab Progress / STEP n/3 / instruction).
  Widget _hud(Size size, double left, double right) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: _glass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _glassBorder),
          boxShadow: _panelShadow,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 4, 12, 6),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: _accent, width: 3)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (d) => setState(() {
                  _hudOffset = Offset(
                    (_hudOffset.dx + d.delta.dx).clamp(-left, right),
                    (_hudOffset.dy + d.delta.dy).clamp(-8.0, math.max(0.0, size.height - 80)),
                  );
                }),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.drag_indicator, size: 13, color: _accentText),
                    const SizedBox(width: 4),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(color: _rt_Tw.emerald400, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _tx.s('labProgress').toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: _rt_Lab.text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _fmt(_tx.s('ui.stepTag'), {'n': '$_step'}),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: _accentText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _tx.s('hud_s$_step'),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, height: 1.2, color: _accentText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Specimen feature callout (scenario 1).
  Widget _specimenCallout() {
    final c = _tx.map('callouts.$_calloutKey');
    final titleColor = _dark ? _rt_Tw.cyan400 : _kingdom700[0];
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 10),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Tw.cyan500.withValues(alpha: 0.4)),
        boxShadow: _panelShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  (c['t'] as String? ?? _tx.s('specFeature')).toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: titleColor),
                ),
              ),
              InkResponse(
                radius: 14,
                onTap: () {
                  _rt_playSfx(_rt_Sfx.tap);
                  setState(() => _calloutKey = null);
                },
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(Icons.close, size: 15, color: _rt_Lab.textMuted),
                ),
              ),
            ],
          ),
          Divider(height: 8, color: _glassBorder),
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Text(
              c['b'] as String? ?? '',
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w500, height: 1.35, color: _rt_Lab.text),
            ),
          ),
        ],
      ),
    );
  }

  // Hint / Reset / Verify (canvas action buttons).
  Widget _actionButtons() {
    Widget glassPill(IconData icon, String label, Color color, VoidCallback onTap) => Material(
      color: _glass,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: _glassBorder),
      ),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ),
      ),
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        glassPill(Icons.lightbulb, _tx.s('hint'), _dark ? _rt_Tw.amber400 : _rt_Tw.amber700, _showHint),
        const SizedBox(width: 6),
        glassPill(Icons.restart_alt, _tx.s('resetStep'), _rt_Lab.textMuted, _resetStep),
        const SizedBox(width: 6),
        Material(
          color: _accent,
          borderRadius: BorderRadius.circular(14),
          elevation: 6,
          shadowColor: _accent.withValues(alpha: 0.6),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: _validateStep,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle, size: 16, color: _rt_Tw.slate950),
                  const SizedBox(width: 6),
                  Text(
                    _tx.s('verifyStep').toUpperCase(),
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1,
                      color: _rt_Tw.slate950,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- FLOATING TOOL TRAY ---
  Widget _tray(Size size, double width, double bottom, double maxH) {
    final header = GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: (d) => setState(() {
        _trayOffset = Offset(
          (_trayOffset.dx + d.delta.dx).clamp(-8.0, math.max(-8.0, size.width - 8 - width)),
          (_trayOffset.dy + d.delta.dy).clamp(math.min(bottom, bottom - (size.height - 60)), bottom),
        );
      }),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(Icons.drag_indicator, size: 15, color: _accentText),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                _tx.s('trayTitle').toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1, color: _accentText),
              ),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                _fmt(_tx.s('itemsPlaced'), {'n': '$_placedCount'}),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 9.5, fontFamily: 'monospace', color: _rt_Lab.textMuted),
              ),
            ),
            InkResponse(
              radius: 16,
              onTap: () {
                _rt_playSfx(_rt_Sfx.tap);
                setState(() => _trayCollapsed = !_trayCollapsed);
              },
              child: Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(_trayCollapsed ? Icons.expand_less : Icons.expand_more, size: 20, color: _rt_Lab.textMuted),
              ),
            ),
          ],
        ),
      ),
    );

    final Widget body = switch (_step) {
      1 => _s1TrayBody(),
      2 => _s2TrayBody(),
      _ => _s3TrayBody(),
    };

    return Container(
      constraints: BoxConstraints(maxHeight: maxH),
      padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _glassBorder),
        boxShadow: _panelShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          if (!_trayCollapsed) ...[
            Divider(height: 6, color: _glassBorder),
            const SizedBox(height: 4),
            // Only scrolls on very small canvases; the draggable thumb works even
            // though the tokens themselves capture drags.
            Flexible(
              child: Scrollbar(
                controller: _trayScroll,
                thumbVisibility: true,
                interactive: true,
                child: SingleChildScrollView(controller: _trayScroll, child: body),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _s1TrayBody() {
    final assignLabel = switch (_assignFor) {
      null => _tx.s('placeOnPed'),
      'chip' => '${_tx.s('ui.chip')}: ${_tx.s('placeOnPed')}',
      final k => '${_tx.s(k)}: ${_tx.s('placeOnPed')}',
    };
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var i = 0; i < 5; i++)
              Expanded(
                child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: _specimenButton(i)),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.fromLTRB(6, 4, 4, 4),
          decoration: BoxDecoration(
            color: _zoneBg.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _glassBorder.withValues(alpha: 0.6)),
          ),
          child: LayoutBuilder(
            builder: (context, c) {
              final label = Text(
                assignLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: _rt_Lab.textMuted, height: 1.15),
              );
              final buttons = [
                for (var n = 1; n <= 5; n++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: SizedBox(width: 42, child: _pedestalButton(n)),
                  ),
              ];
              // Label and Ped 1-5 on one line when there is room, stacked otherwise.
              if (c.maxWidth >= 320) {
                return Row(
                  children: [
                    Expanded(child: label),
                    ...buttons,
                  ],
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  label,
                  const SizedBox(height: 3),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [for (final b in buttons) Flexible(child: b)],
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 5),
        Text(
          _tx.s('exampleChipsLabel').toUpperCase(),
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: _rt_Lab.textMuted),
        ),
        const SizedBox(height: 3),
        Wrap(spacing: 4, runSpacing: 4, children: [for (final id in _chipKeys) _chipToken(id)]),
      ],
    );
  }

  Widget _specimenButton(int i) {
    final key = _specimenKeys[i];
    final selected = _selectedToken == 'spec:$key';
    return Material(
      color: selected ? _accent.withValues(alpha: 0.2) : _tokenBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _selectSpecimen(key),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: selected ? _accent : _tokenBorder, width: selected ? 1.6 : 1),
            boxShadow: selected ? [BoxShadow(color: _accent.withValues(alpha: 0.55), blurRadius: 10)] : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_kingdomIcons[i], size: 16, color: _dark ? _kingdom400[i] : _kingdom700[i]),
              const SizedBox(height: 1),
              Text(
                _tx.s(key),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: _rt_Lab.text),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pedestalButton(int n) {
    return Material(
      color: _tokenBg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        hoverColor: _rt_Tw.emerald600,
        splashColor: _rt_Tw.emerald600.withValues(alpha: 0.5),
        onTap: () => _assignCurrentItem(n),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _tokenBorder),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _fmt(_tx.s('ui.ped'), {'n': '$n'}),
              style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: _rt_Lab.text),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chipToken(String id) {
    final placed = _s1Chips[id]!;
    final selected = _selectedToken == 'chip:$id';
    final error = _errorChips.contains(id);
    final highlight = selected || placed > 0;
    final border = error ? _rt_Tw.red500 : (highlight ? _accent : _tokenBorder);
    final bg = error ? _rt_Tw.red500.withValues(alpha: 0.25) : (highlight ? _accent.withValues(alpha: 0.2) : _tokenBg);
    final chip = Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _selectChip(id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: selected || error ? 1.6 : 1),
            boxShadow: selected ? [BoxShadow(color: _accent.withValues(alpha: 0.55), blurRadius: 10)] : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _tx.s('chips.$id'),
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: _rt_Lab.text),
                ),
              ),
              if (placed > 0) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    _fmt(_tx.s('ui.ped'), {'n': '$placed'}),
                    style: const TextStyle(fontSize: 8.5, fontWeight: FontWeight.w900, color: _rt_Tw.slate950),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    if (!error) return chip;
    // .is-error shake.
    return TweenAnimationBuilder<double>(
      key: ValueKey('shake-$id-$_errorToken'),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, t, child) =>
          Transform.translate(offset: Offset(math.sin(t * math.pi * 4) * 6 * (1 - t), 0), child: child),
      child: chip,
    );
  }

  Widget _ladderTokenChip((String, String) def, {bool dragging = false}) {
    final rank = def.$2 == 'rank';
    final c = rank ? _rt_Tw.cyan500 : _rt_Tw.amber500;
    final text = rank ? (_dark ? _kingdom300[0] : _kingdom700[0]) : (_dark ? _kingdom300[2] : _kingdom700[2]);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: _tokenBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.5)),
        boxShadow: dragging ? [const BoxShadow(color: Color(0x99000000), blurRadius: 20, offset: Offset(0, 10))] : null,
      ),
      child: Text(
        def.$1,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          fontStyle: rank ? FontStyle.normal : FontStyle.italic,
          color: text,
        ),
      ),
    );
  }

  Widget _s2TrayBody() {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: [
        for (final def in _ladderTokenDefs)
          Draggable<_LadderToken>(
            data: (val: def.$1, cat: def.$2),
            feedback: Material(
              color: Colors.transparent,
              child: Transform.scale(scale: 1.06, child: _ladderTokenChip(def, dragging: true)),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: _ladderTokenChip(def)),
            onDragStarted: () => _rt_playSfx(_rt_Sfx.click),
            child: _ladderTokenChip(def),
          ),
      ],
    );
  }

  Widget _wordTile(String text, {bool dragging = false}) {
    final selected = _selectedTile == text;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _tokenBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? _accent : (_dark ? _rt_Tw.slate600 : _rt_Tw.slate400), width: 2),
        boxShadow: [
          if (selected) BoxShadow(color: _accent.withValues(alpha: 0.6), blurRadius: 12),
          if (dragging) const BoxShadow(color: Color(0x99000000), blurRadius: 20, offset: Offset(0, 10)),
        ],
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
          fontSize: 11.5,
          color: _dark ? Colors.white : _rt_Tw.slate900,
        ),
      ),
    );
  }

  Widget _s3TrayBody() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final (text, _) in _wordTiles)
          Draggable<String>(
            data: text,
            feedback: Material(
              color: Colors.transparent,
              child: Transform.scale(scale: 1.06, child: _wordTile(text, dragging: true)),
            ),
            childWhenDragging: Opacity(opacity: 0.3, child: _wordTile(text)),
            onDragStarted: () => _rt_playSfx(_rt_Sfx.click),
            child: GestureDetector(onTap: () => _selectTile(text), child: _wordTile(text)),
          ),
      ],
    );
  }

  // --- SCENARIO 2: ADDRESS LADDERS ---
  Widget _ladderOverlay(double reservedBottom) {
    return LayoutBuilder(
      builder: (context, c) {
        final twoCol = c.maxWidth >= 460;
        final tiger = _ladderCard(tiger: true);
        final pea = _ladderCard(tiger: false);
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: reservedBottom),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 768),
              child: twoCol
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: tiger),
                        const SizedBox(width: 10),
                        Expanded(child: pea),
                      ],
                    )
                  : Column(children: [tiger, const SizedBox(height: 10), pea]),
            ),
          ),
        );
      },
    );
  }

  Widget _ladderCard({required bool tiger}) {
    final c = tiger ? _rt_Tw.amber500 : _rt_Tw.emerald500;
    final titleColor = tiger ? (_dark ? _rt_Tw.amber400 : _rt_Tw.amber700) : _accentText;
    final valueColor = tiger ? (_dark ? _rt_Tw.amber400 : _rt_Tw.amber700) : _accentText;
    final ranks = tiger ? _tigerRanks : _peaRanks;
    final values = tiger ? _tigerValues : _peaValues;
    final ladder = tiger ? 'tiger' : 'pea';
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 6),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: c.withValues(alpha: 0.4)),
        boxShadow: _panelShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tx.s(tiger ? 'tigerLadder' : 'peaLadder').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, color: titleColor),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: c.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: c.withValues(alpha: 0.2)),
                ),
                child: Text(
                  _tx.s(tiger ? 'tigerRungsLabel' : 'peaRungsLabel'),
                  style: TextStyle(fontSize: 9, fontFamily: 'monospace', color: titleColor.withValues(alpha: 0.85)),
                ),
              ),
            ],
          ),
          Divider(height: 12, color: _glassBorder),
          for (var i = 0; i < ranks.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                children: [
                  Expanded(child: _ladderZone(ladder, 'rank', i, ranks[i], _rt_Lab.textFaint)),
                  const SizedBox(width: 6),
                  Expanded(child: _ladderZone(ladder, 'value', i, values[i], valueColor.withValues(alpha: 0.8))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _ladderZone(String ladder, String type, int idx, String? value, Color emptyColor) {
    return DragTarget<_LadderToken>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) => _dropLadderToken(d.data, ladder, type, idx),
      builder: (context, candidates, _) {
        final over = candidates.isNotEmpty;
        final filled = value != null;
        return AnimatedScale(
          duration: const Duration(milliseconds: 200),
          scale: over ? 1.03 : 1,
          child: Container(
            height: 30,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: over ? _accent.withValues(alpha: 0.3) : (filled ? _accent.withValues(alpha: 0.2) : _zoneBg),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: over || filled ? _accent : _tokenBorder.withValues(alpha: 0.8),
                width: over ? 1.6 : 1,
              ),
              boxShadow: over ? [BoxShadow(color: _accent.withValues(alpha: 0.45), blurRadius: 14)] : null,
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                filled ? value : (type == 'rank' ? _fmt(_tx.s('ui.rungRank'), {'n': '${idx + 1}'}) : _tx.s('ui.value')),
                style: filled
                    ? TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _dark ? Colors.white : _rt_Tw.slate900,
                      )
                    : TextStyle(fontSize: 9.5, fontWeight: FontWeight.bold, color: emptyColor),
              ),
            ),
          ),
        );
      },
    );
  }

  // --- SCENARIO 3: LAB NOTEBOOK ---
  Widget _notebookOverlay(double reservedBottom) {
    return LayoutBuilder(
      builder: (context, c) {
        final twoCol = c.maxWidth >= 520;
        final tiger = _nameEntry(tiger: true);
        final mango = _nameEntry(tiger: false);
        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: reservedBottom),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 672),
              child: Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _rt_Tw.slate200, width: 2),
                  boxShadow: const [BoxShadow(color: Color(0x80000000), blurRadius: 30, offset: Offset(0, 14))],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 30, child: CustomPaint(painter: _NotebookSpiralPainter())),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (twoCol)
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: tiger),
                                const SizedBox(width: 10),
                                Expanded(child: mango),
                              ],
                            )
                          else ...[
                            tiger,
                            const SizedBox(height: 10),
                            mango,
                          ],
                          const SizedBox(height: 10),
                          _rulesBox(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _nameEntry({required bool tiger}) {
    final bg = tiger ? const Color(0xCCFFFBEB) : const Color(0xCCECFDF5); // amber/emerald-50
    final border = tiger ? const Color(0xFFFDE68A) : const Color(0xFFA7F3D0); // -200
    final deep = tiger ? const Color(0xFF78350F) : const Color(0xFF064E3B); // -900
    final icon = tiger ? const Color(0xFFD97706) : const Color(0xFF059669); // -600
    final tag = tiger ? const Color(0xFFB45309) : const Color(0xFF047857); // -700
    final slotBorder = tiger ? const Color(0xFFFCD34D) : const Color(0xFF6EE7B7); // -300
    final previewBg = tiger ? const Color(0xB3FEF3C7) : const Color(0xB3D1FAE5); // -100/70
    final genus = tiger ? _tigerGenus : _mangoGenus;
    final species = tiger ? _tigerSpecies : _mangoSpecies;
    final preview = '${genus ?? '______'} ${species ?? '______'}';
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(tiger ? Icons.pets : Icons.eco, size: 15, color: icon),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _tx.s(tiger ? 'tigerFigurine' : 'mangoFruit').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: deep),
                ),
              ),
              Text(
                tiger ? 'Animalia' : 'Plantae',
                style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: tag),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _nameSlot(tiger ? 'genus-tiger' : 'genus-mango', genus, deep, slotBorder)),
              const SizedBox(width: 8),
              Expanded(child: _nameSlot(tiger ? 'species-tiger' : 'species-mango', species, deep, slotBorder)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(color: previewBg, borderRadius: BorderRadius.circular(8)),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                preview,
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: _rule3 ? 14.5 : 13,
                  fontStyle: _rule3 ? FontStyle.italic : FontStyle.normal,
                  fontWeight: _rule3 ? FontWeight.bold : FontWeight.normal,
                  color: _rule3 ? deep : _rt_Tw.slate600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _nameSlot(String slot, String? value, Color deep, Color border) {
    final label = _tx.s(slot.startsWith('genus') ? 'genusSlot' : 'speciesSlot').toUpperCase();
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (d) => _dropTile(d.data, slot),
      builder: (context, candidates, _) {
        final over = candidates.isNotEmpty;
        return GestureDetector(
          onTap: () => _quickAssignSlot(slot),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: over ? 1.03 : 1,
            child: Container(
              constraints: const BoxConstraints(minHeight: 46),
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: over ? _accent.withValues(alpha: 0.3) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: over ? _accent : border, width: 2),
                boxShadow: over ? [BoxShadow(color: _accent.withValues(alpha: 0.45), blurRadius: 14)] : null,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: value == null
                    ? Text(
                        '[ $label ]',
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: _rt_Tw.slate400,
                        ),
                      )
                    : Text(
                        value,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: deep,
                        ),
                      ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _rulesBox() {
    Widget rule(int i, bool value) => InkWell(
      borderRadius: BorderRadius.circular(6),
      onTap: () => _setRule(i, !value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: Checkbox(
                value: value,
                onChanged: (v) => _setRule(i, v ?? false),
                activeColor: _rt_Tw.emerald600,
                checkColor: Colors.white,
                side: const BorderSide(color: _rt_Tw.slate500, width: 1.5),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_tx.s('rule$i'), style: const TextStyle(fontSize: 11.5, color: _rt_Tw.slate700, height: 1.3)),
            ),
          ],
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Tw.slate50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Tw.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tx.s('rulesConfirm').toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: _rt_Tw.slate800,
            ),
          ),
          const SizedBox(height: 6),
          rule(1, _rule1),
          rule(2, _rule2),
          rule(3, _rule3),
        ],
      ),
    );
  }

  // --- SIDEBAR: module select + teacher board ---
  Widget _moduleSelect() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.base,
        border: Border(bottom: BorderSide(color: _rt_Lab.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.science, size: 14, color: _accentDeep),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _tx.s('moduleSel').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: _accentDeep,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _rt_Lab.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rt_Lab.border, width: 2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _step,
                isExpanded: true,
                dropdownColor: _rt_Lab.surface,
                iconEnabledColor: _rt_Lab.textMuted,
                borderRadius: BorderRadius.circular(12),
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _rt_Lab.text),
                items: [
                  for (var i = 1; i <= 3; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(_tx.s('s${i}_title'), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) {
                  if (v != null && v != _step) _setStep(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// `*text*` segments of the "What we learn" copy are shown in italics.
  List<TextSpan> _italicSpans(String s) {
    final parts = s.split('*');
    return [
      for (var i = 0; i < parts.length; i++)
        TextSpan(
          text: parts[i],
          style: i.isOdd ? const TextStyle(fontStyle: FontStyle.italic) : null,
        ),
    ];
  }

  Widget _teacherTab() {
    final steps = _tx.list('s${_step}_steps');
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_SectionLabel(_tx.s('missionObj'), icon: Icons.gps_fixed, color: _accentDeep),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _rt_Lab.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rt_Lab.border),
            ),
            child: Text(
              _tx.s('s${_step}_obj'),
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, height: 1.45, color: _rt_Lab.textMuted),
            ),
          ),
          const SizedBox(height: 14),
          _rt_SectionLabel(_tx.s('detailedSteps'), icon: Icons.format_list_numbered, color: _accentDeep),
          for (var i = 0; i < steps.length; i++) _accordionItem(i, (steps[i] as Map).cast<String, dynamic>()),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _rt_Lab.tinted(_rt_Tw.emerald50, _accent),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _rt_Lab.tintedBorder(_accent)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb, size: 15, color: _accentText),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _tx.s('what_we_learn').toUpperCase(),
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: _accentText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text.rich(
                  TextSpan(children: _italicSpans(_tx.s('s${_step}_learn'))),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                    color: _rt_Lab.onTinted(_rt_Tw.emerald400, const Color(0xFF065F46)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accordionItem(int idx, Map<String, dynamic> s) {
    final open = _openAccordion == idx;
    Widget section(IconData icon, String head, Color headColor, String body, Color bodyColor) => Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: headColor),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  head.toUpperCase(),
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.6, color: headColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            body,
            style: TextStyle(fontSize: 11.5, height: 1.4, fontWeight: FontWeight.w500, color: bodyColor),
          ),
        ],
      ),
    );

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: open ? _accent.withValues(alpha: 0.5) : _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              _rt_playSfx(_rt_Sfx.click);
              setState(() => _openAccordion = open ? null : idx);
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: _accent.withValues(alpha: 0.2), shape: BoxShape.circle),
                    child: Text(
                      '${idx + 1}',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _accentText),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s['t'] as String? ?? '',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _rt_Lab.text),
                    ),
                  ),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(Icons.expand_more, size: 18, color: _rt_Lab.textMuted),
                  ),
                ],
              ),
            ),
          ),
          if (open)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              decoration: BoxDecoration(
                color: _rt_Lab.base,
                border: Border(top: BorderSide(color: _rt_Lab.border)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  section(Icons.play_arrow, _tx.s('taskInstr'), _accentDeep, s['i'] as String? ?? '', _rt_Lab.text),
                  section(
                    Icons.visibility,
                    _tx.s('expOut'),
                    _dark ? _rt_Tw.blue400 : _rt_Tw.blue600,
                    s['o'] as String? ?? '',
                    _rt_Lab.textMuted,
                  ),
                  section(
                    Icons.lightbulb,
                    _tx.s('conceptLearned'),
                    _accentText,
                    s['c'] as String? ?? '',
                    _rt_Lab.onTinted(_rt_Tw.emerald400, _rt_Tw.emerald700),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Spiral-bound header of the scenario 3 lab notebook (CSS .spiral-header).
class _NotebookSpiralPainter extends CustomPainter {
  const _NotebookSpiralPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = _rt_Tw.slate100);
    // Punched holes every 24 px.
    final hole = Paint()..color = _rt_Tw.slate700.withValues(alpha: 0.6);
    final cy = size.height / 2;
    final count = (size.width / 24).floor();
    final start = (size.width - (count - 1) * 24) / 2;
    for (var i = 0; i < count; i++) {
      canvas.drawCircle(Offset(start + i * 24, cy), 5.5, hole);
    }
    // Dashed bottom border.
    final dash = Paint()
      ..color = _rt_Tw.slate300
      ..strokeWidth = 2;
    final y = size.height - 1;
    for (var x = 0.0; x < size.width; x += 10) {
      canvas.drawLine(Offset(x, y), Offset(math.min(x + 6, size.width), y), dash);
    }
  }

  @override
  bool shouldRepaint(covariant _NotebookSpiralPainter oldDelegate) => false;
}
