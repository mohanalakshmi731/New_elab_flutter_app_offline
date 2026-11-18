// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Plant Classification (Kingdom Plantae)
// Converted from Cl9S-Ch12-A4-PlantClassificationPlantae.html (gsap -> Flutter, three.js -> mini3d).

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

// Strings the source hard-codes in its script (toasts, validation messages,
// tool tips, class names) rather than in its locale table. Kept here so the
// page is fully bilingual; spread into the locale maps below.
const _plantaeExtraEn = <String, dynamic>{
  'stepTag': 'STEP {n}/4',
  'remove': 'Remove',
  'classes': {
    'thallo': 'Thallophyta',
    'bryo': 'Bryophyta',
    'pteri': 'Pteridophyta',
    'gymno': 'Gymnosperm',
    'angio': 'Angiosperm',
  },
  'tools': {
    'lock': 'Lock/Unlock Camera Orbit & Pan',
    'zoomIn': 'Zoom In (Unlock to use)',
    'zoomOut': 'Zoom Out (Unlock to use)',
    'pan': 'Pan Mode (Unlock to use)',
    'labels': 'Toggle Visual Labels (Always Works)',
    'resetCam': 'Reset Camera View (Unlock to use)',
  },
  'msg': {
    'labReset': 'Lab completely reset to start.',
    'locked': 'Screen Locked: Camera fixed',
    'unlocked': 'Screen Unlocked: Orbit & Zoom enabled',
    'panOn': 'Pan Mode (Drag to move)',
    'panOff': 'Orbit Mode (Drag to rotate)',
    'labelsOn': 'Visual Labels: Visible',
    'labelsOff': 'Visual Labels: Hidden',
    'specToRung': '{name} -> {rung}',
    'assigned': 'Assigned "{trait}"',
    'selectStripFirst': 'Select a statement strip from the Tool Tray first!',
    'stripPlaced': 'Statement placed.',
    'selectChipFirst':
        'Select a label or caption chip from the Tool Tray first!',
    'placed': 'Placed "{text}"',
    'flowOn':
        'Microscope Vascular Transport Flow: Active (Xylem Upward / Phloem Bidirectional)',
    'flowOff': 'Transport Flow: Paused',
    's1Errors': {
      'spirogyra': 'Spirogyra (Thallophyta) is aquatic and belongs to Rung ①!',
      'marchantia': 'Marchantia (Bryophyta) is the plant amphibian on Rung ②!',
      'fern': 'Fern (Pteridophyta) has vascular tissues and belongs to Rung ③!',
      'pine': 'Pine (Gymnosperm) bears naked seeds and belongs to Rung ④!',
      'gulmohar':
          'Gulmohar (Angiosperm) produces flowers and belongs to Rung ⑤!',
    },
    's1Wrong': '❌ Incorrect Order: {error}',
    's1Ok':
        '✅ 3D Water-to-Land ladder correctly ordered! Advancing to Trait Matcher...',
    's1Incomplete':
        'Please place all 5 plant specimens onto their evolutionary rungs.',
    's2Ok': '✅ Diagnostic traits correctly grouped! Advancing to Table 12.3...',
    's2Wrong':
        '❌ Ensure each Plant Class column has its matching diagnostic traits assigned.',
    's3Ok': '✅ Table 12.3 reconstructed! Advancing to Microscope Station...',
    's3Check': 'Check highlighted red slots.',
    's3Wrong': '❌ {hint}',
    's4Wrong':
        '❌ Vessel ① (Inner Core): Xylem (Transports Water). Vessel ② (Outer Ring): Phloem (Transports Food).',
    'stepReset': 'Step reset.',
    'hintS2':
        'Thallophyta=Thallus in water; Bryophyta=Amphibians/Rhizoids; Pteridophyta=Vascular/No seeds; Gymnosperms=Naked seeds; Angiosperms=Flowers/Fruits.',
    'hintS3':
        'Table 12.3: Thallophytes cannot live on land; Bryophytes need moisture; Pteridophytes need water for reproduction.',
    'hintS4':
        'Xylem transports water and minerals from roots; Phloem translocates photosynthesized food.',
    'selTrait': 'Selected "{trait}" - Click a Class Column!',
    'selStrip': 'Selected strip - Click an Advantage or Challenge slot!',
    'selItem': 'Selected "{text}" - Click a slot on the microscope station!',
  },
};

const _plantaeExtraHi = <String, dynamic>{
  'stepTag': 'चरण {n}/4',
  'remove': 'हटाएं',
  'classes': {
    'thallo': 'थैलोफाइटा',
    'bryo': 'ब्रायोफाइटा',
    'pteri': 'टेरिडोफाइटा',
    'gymno': 'जिम्नोस्पर्म',
    'angio': 'एंजियोस्पर्म',
  },
  'tools': {
    'lock': 'कैमरा घुमाव व पैन लॉक/अनलॉक करें',
    'zoomIn': 'ज़ूम इन (उपयोग हेतु अनलॉक करें)',
    'zoomOut': 'ज़ूम आउट (उपयोग हेतु अनलॉक करें)',
    'pan': 'पैन मोड (उपयोग हेतु अनलॉक करें)',
    'labels': 'दृश्य लेबल दिखाएं/छिपाएं (सदैव कार्य करता है)',
    'resetCam': 'कैमरा दृश्य रीसेट करें (उपयोग हेतु अनलॉक करें)',
  },
  'msg': {
    'labReset': 'लैब पूरी तरह से प्रारंभिक स्थिति में रीसेट हो गई।',
    'locked': 'स्क्रीन लॉक: कैमरा स्थिर',
    'unlocked': 'स्क्रीन अनलॉक: घुमाव व ज़ूम सक्षम',
    'panOn': 'पैन मोड (खिसकाने के लिए खींचें)',
    'panOff': 'ऑर्बिट मोड (घुमाने के लिए खींचें)',
    'labelsOn': 'दृश्य लेबल: दिखाई दे रहे हैं',
    'labelsOff': 'दृश्य लेबल: छिपे हुए',
    'specToRung': '{name} -> {rung}',
    'assigned': '"{trait}" रखा गया',
    'selectStripFirst': 'पहले टूल ट्रे से एक कथन पट्टी चुनें!',
    'stripPlaced': 'कथन रखा गया।',
    'selectChipFirst': 'पहले टूल ट्रे से एक लेबल या कार्य चिप चुनें!',
    'placed': '"{text}" रखा गया',
    'flowOn':
        'सूक्ष्मदर्शी संवहनी परिवहन प्रवाह: सक्रिय (जाइलम ऊपर की ओर / फ्लोएम द्विदिशीय)',
    'flowOff': 'परिवहन प्रवाह: रुका हुआ',
    's1Errors': {
      'spirogyra': 'स्पाइरोगाइरा (थैलोफाइटा) जलीय है और पायदान ① पर आता है!',
      'marchantia':
          'मार्केन्शिया (ब्रायोफाइटा) पादप उभयचर है और पायदान ② पर आता है!',
      'fern':
          'फर्न (टेरिडोफाइटा) में संवहन ऊतक होते हैं और यह पायदान ③ पर आता है!',
      'pine': 'चीड़ (जिम्नोस्पर्म) नग्न बीज बनाता है और पायदान ④ पर आता है!',
      'gulmohar':
          'गुलमोहर (एंजियोस्पर्म) पुष्प बनाता है और पायदान ⑤ पर आता है!',
    },
    's1Wrong': '❌ गलत क्रम: {error}',
    's1Ok':
        '✅ 3D जल-से-स्थल सीढ़ी सही क्रम में है! लक्षण मिलान की ओर बढ़ रहे हैं...',
    's1Incomplete': 'कृपया सभी 5 पादप नमूनों को उनके विकासीय पायदानों पर रखें।',
    's2Ok': '✅ नैदानिक लक्षण सही समूहित हुए! सारणी 12.3 की ओर बढ़ रहे हैं...',
    's2Wrong':
        '❌ सुनिश्चित करें कि प्रत्येक पादप वर्ग कॉलम में उसके मेल खाते नैदानिक लक्षण रखे गए हैं।',
    's3Ok':
        '✅ सारणी 12.3 का पुनर्निर्माण हो गया! सूक्ष्मदर्शी स्टेशन की ओर बढ़ रहे हैं...',
    's3Check': 'लाल रंग से चिह्नित स्थानों की जाँच करें।',
    's3Wrong': '❌ {hint}',
    's4Wrong':
        '❌ वाहिका ① (आंतरिक क्रोड): जाइलम (जल का संवहन)। वाहिका ② (बाह्य वलय): फ्लोएम (भोजन का संवहन)।',
    'stepReset': 'चरण रीसेट हुआ।',
    'hintS2':
        'थैलोफाइटा = जल में थैलस; ब्रायोफाइटा = उभयचर/मूलाभास; टेरिडोफाइटा = संवहनी/बीजरहित; जिम्नोस्पर्म = नग्न बीज; एंजियोस्पर्म = पुष्प/फल।',
    'hintS3':
        'सारणी 12.3: थैलोफाइटा स्थल पर नहीं रह सकते; ब्रायोफाइटा को सदैव नमी चाहिए; टेरिडोफाइटा को जनन हेतु जल चाहिए।',
    'hintS4':
        'जाइलम जड़ों से जल और खनिजों का संवहन करता है; फ्लोएम प्रकाश-संश्लेषित भोजन का स्थानांतरण करता है।',
    'selTrait': '"{trait}" चुना गया - किसी वर्ग कॉलम पर क्लिक करें!',
    'selStrip': 'पट्टी चुनी गई - किसी लाभ या चुनौती स्थान पर क्लिक करें!',
    'selItem':
        '"{text}" चुना गया - सूक्ष्मदर्शी स्टेशन के किसी स्थान पर क्लिक करें!',
  },
};

final _tx = _rt_Tx({
  'en': {
    'title': 'Plant Classification (Kingdom Plantae)',
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
    'placeOnRung': 'Place on Rung:',
    'specFeature': 'Specimen Feature',
    'gotIt': 'Got it',
    'showFlow': 'Show Flow',
    's4Title': 'Fern Stem Cross-Section (Activity 12.7)',
    'itemsPlaced': 'Items: {n}/5 Placed',

    'rung1_label': 'Rung ①: Aquatic',
    'rung2_label': 'Rung ②: Amphibious',
    'rung3_label': 'Rung ③: Vascular Land',
    'rung4_label': 'Rung ④: Naked Seed',
    'rung5_label': 'Rung ⑤: Flower & Fruit',

    'rungBtns': ['Rung 1', 'Rung 2', 'Rung 3', 'Rung 4', 'Rung 5'],

    'spirogyra': 'Spirogyra',
    'marchantia': 'Marchantia & Moss',
    'fern': 'Fern Frond',
    'pine': 'Pine with Cone',
    'gulmohar': 'Gulmohar Flower',

    'hud_s1':
        'Sort the 5 plant specimens onto the 3D Water-to-Land ladder in order of increasing complexity.',
    'hud_s2':
        'Sort each diagnostic trait card under its corresponding Plant Class column.',
    'hud_s3':
        'Rebuild Table 12.3: Place the Advantage and Challenge strips into each Plant Class.',
    'hud_s4':
        'Identify Xylem & Phloem on the stem cross-section and trigger the vascular transport flow.',

    's2_traits': [
      {'id': 't1', 'text': 'Simple Thallus Body', 'cls': 'thallo'},
      {'id': 't2', 'text': 'Found in Water', 'cls': 'thallo'},
      {'id': 't3', 'text': 'No True Roots/Stems', 'cls': 'thallo'},
      {'id': 't4', 'text': 'Rhizoids', 'cls': 'bryo'},
      {'id': 't5', 'text': '\'Amphibians\' of Plants', 'cls': 'bryo'},
      {'id': 't6', 'text': 'Needs Water for Reproduction', 'cls': 'bryo'},
      {'id': 't7', 'text': 'True Roots/Stems/Leaves', 'cls': 'pteri'},
      {'id': 't8', 'text': 'Vascular Tissue (Xylem/Phloem)', 'cls': 'pteri'},
      {'id': 't9', 'text': 'No Seeds', 'cls': 'pteri'},
      {'id': 't10', 'text': 'Needle-like Leaves', 'cls': 'gymno'},
      {'id': 't11', 'text': 'Seeds on Cones', 'cls': 'gymno'},
      {'id': 't12', 'text': 'Naked Seeds', 'cls': 'gymno'},
      {'id': 't13', 'text': 'Produces Flowers', 'cls': 'angio'},
      {'id': 't14', 'text': 'Seeds in Fruits', 'cls': 'angio'},
      {'id': 't15', 'text': 'Highly Diverse', 'cls': 'angio'},
    ],
    'dropTraitsHere': '[ Drop Traits Here ]',

    's3_table_title':
        'Table 12.3 Rebuild: Advantages vs Challenges for Survival',
    'advSlotLabel': '[ Advantage Slot ]',
    'chalSlotLabel': '[ Challenge Slot ]',
    's3_strips': {
      'thallo_adv':
          'Simple plant body facilitates survival and its dispersal in water.',
      'thallo_chal': 'They cannot live on land.',
      'bryo_adv':
          'They are plant amphibians. Their body is adapted to live on moist land.',
      'bryo_chal': 'They always need moisture.',
      'pteri_adv':
          'They live on land. They transport food and water to all parts of the plant.',
      'pteri_chal': 'Reproduction does not take place without water.',
      'gymno_adv':
          'Leaves are adapted for dry conditions. They do not require water for reproduction. They form seeds for continuity of life.',
      'gymno_chal': 'Seeds are not covered in the form of fruits.',
      'angio_adv':
          'They produce flowers, fruits and seeds. They have a well-developed system for reproduction. They produce seeds for continuity of life. Their seeds are covered.',
      'angio_chal':
          'Reproduction is dependent on pollination by different agents. They have complex processes through a well-developed tissue system.',
    },

    'vessel1Title': 'Vascular Vessel ① (Inner Core)',
    'vessel2Title': 'Vascular Vessel ② (Outer Ring)',
    'tissueSlotText': '[ Tissue Name ]',
    'funcSlotText': '[ Function ]',
    'phloemZoneText': 'Phloem Zone',
    'xylemCoreText': 'Xylem Core',
    's4_items': [
      {'id': 'xylem', 'text': 'Xylem', 'type': 'tissue'},
      {'id': 'phloem', 'text': 'Phloem', 'type': 'tissue'},
      {'id': 'water', 'text': 'Transports Water & Minerals', 'type': 'func'},
      {
        'id': 'food',
        'text': 'Transports Food (Photosynthates)',
        'type': 'func',
      },
    ],

    'callouts': {
      'spirogyra': {
        't': 'Spirogyra (Thallophyta)',
        'b':
            'Simple undifferentiated thallus body floating in water with spiral chloroplasts.',
      },
      'marchantia': {
        't': 'Marchantia & Moss (Bryophyta)',
        'b':
            'Lobed thallus with root-like rhizoids and stem/leaf-like structures; needs water for reproduction.',
      },
      'fern': {
        't': 'Fern Frond (Pteridophyta)',
        'b':
            'True roots, stems, leaves, and vascular tissues (xylem and phloem); produces spores, no seeds.',
      },
      'pine': {
        't': 'Pine Conifer (Gymnosperm)',
        'b':
            'Needle-like leaves adapted for dry conditions; produces naked seeds exposed on cones.',
      },
      'gulmohar': {
        't': 'Gulmohar (Angiosperm)',
        'b':
            'Most complex plant organisation; produces flowers for pollination and seeds enclosed in fruits.',
      },
    },

    'pedestalInfo': {
      '1':
          '<strong>Rung ① Criteria (Thallophyta):</strong><br>• Simplest plant forms mostly found in water.<br>• Simple undifferentiated thallus body.<br>• Direct exchange of gases, nutrients and water.<br><em>(Example: Spirogyra)</em>',
      '2':
          '<strong>Rung ② Criteria (Bryophyta):</strong><br>• Differentiated body with root-like rhizoids.<br>• Stem-like and leaf-like simple structures.<br>• Requires water for reproduction — \'amphibians of the plant kingdom.\'<br><em>(Examples: Marchantia and moss)</em>',
      '3':
          '<strong>Rung ③ Criteria (Pteridophyta):</strong><br>• Possess true roots, stems and leaves.<br>• Specialized vascular tissue: xylem and phloem.<br>• Requires aquatic conditions for reproduction; no seeds.<br><em>(Example: Ferns)</em>',
      '4':
          '<strong>Rung ④ Criteria (Gymnosperms):</strong><br>• Needle-like or scale-like leaves.<br>• Seeds are not enclosed in fruits (exposed on cones).<br>• Do not require aquatic conditions for fertilisation.<br><em>(Examples: Pines and cycads)</em>',
      '5':
          '<strong>Rung ⑤ Criteria (Angiosperms):</strong><br>• Most complex body organisation.<br>• Produce flowers to attract pollinators and fruits to spread seeds.<br>• Most diverse plant group on Earth.<br><em>(Example: Gulmohar / flowering plants)</em>',
    },

    'concTitle': 'Plant Kingdom Classification & Evolution',
    'concHead1': '1. The Water to Land Evolutionary Sequence',
    'concBody1':
        'From aquatic algae (Thallophyta) to amphibians of the plant kingdom (Bryophyta), vascular spore-bearing plants (Pteridophyta), naked seed conifers (Gymnosperms), and flowering plants (Angiosperms), plants evolved complex tissues and independence from water for reproduction.',
    'concHead2': '2. Vascular Transport Tissues (Xylem & Phloem)',
    'concBody2':
        'Pteridophytes, Gymnosperms, and Angiosperms possess specialized vascular tissues: Xylem conducts water and dissolved minerals from roots, while Phloem translocates photosynthesized food across the plant body.',
    'concHead3': '3. Seed & Fruit Adaptations',
    'concBody3':
        'Gymnosperms bear naked seeds on cones for dry land survival without requiring water for fertilization, while Angiosperms enclose seeds in fruits and use flowers to attract pollinators, becoming the most diverse plant group on Earth.',
    'evalMetrics': 'Evaluation Metrics',
    'metric1': 'Conceptual Understanding:',
    'metric2': 'Observation & Identification:',
    'metric3': 'Scientific Reasoning:',
    'metric4': 'Classification & Modeling:',

    's1_title': '1. Water-to-Land Ladder',
    's2_title': '2. Diagnostic Feature Matcher',
    's3_title': '3. Advantages vs Challenges Sorter',
    's4_title': '4. Xylem/Phloem Microscope Station',

    's1_obj':
        'Sort real plant forms onto the 3D Water-to-Land ladder from simplest aquatic algae to the most complex flowering plants.',
    's2_obj':
        'Match the 15 diagnostic traits under their proper Plant Class columns (Thallophyta to Angiosperms).',
    's3_obj':
        'Rebuild Table 12.3 by sorting the advantage and challenge strips for each class.',
    's4_obj':
        'Identify vascular tissues (xylem and phloem) on a fern stem cross-section and observe fluid transport flow.',

    's1_steps': [
      {
        't': 'Step 1: Aquatic Algae (Thallophyta)',
        'i': 'Inspect the Spirogyra filament and place it on Rung ① (Aquatic).',
        'o': 'Spirogyra is placed on Rung ①.',
        'c':
            'Thallophytes have an undifferentiated thallus body adapted to water.',
      },
      {
        't': 'Step 2: Plant Amphibians (Bryophyta)',
        'i':
            'Inspect Marchantia & moss with rhizoids and place on Rung ② (Amphibious).',
        'o': 'Marchantia & moss are placed on Rung ②.',
        'c':
            'Bryophytes live on moist land but still require water for sperm cells to swim.',
      },
      {
        't': 'Step 3: Vascular Spore Plants (Pteridophyta)',
        'i':
            'Inspect the fern frond with true roots & vascular tissue and place on Rung ③.',
        'o': 'Fern is placed on Rung ③.',
        'c':
            'Pteridophytes possess true vascular tissues (xylem/phloem) but produce no seeds.',
      },
      {
        't': 'Step 4: Naked Seed Conifers (Gymnosperms)',
        'i':
            'Inspect the pine tree with needle leaves & woody cone and place on Rung ④.',
        'o': 'Pine is placed on Rung ④.',
        'c':
            'Gymnosperms produce exposed seeds on cones without needing water for fertilization.',
      },
      {
        't': 'Step 5: Flowering Plants (Angiosperms)',
        'i':
            'Inspect the Gulmohar plant with flowers & fruits and place on Rung ⑤.',
        'o': 'Gulmohar is placed on Rung ⑤.',
        'c':
            'Angiosperms produce flowers and fruits, representing the most diverse plant group.',
      },
    ],
    's2_steps': [
      {
        't': 'Step 1: Class Columns Overview',
        'i': 'Examine the 5 Plant Class columns on the board.',
        'o': '5 Class dropzones active.',
        'c': 'Each class has unique cellular organisation and adaptations.',
      },
      {
        't': 'Step 2: Slot Trait Badges',
        'i':
            'Drag or click to assign each trait card from the tray into its proper class column.',
        'o': 'All 15 traits slotted.',
        'c':
            'Traits reflect the progressive evolutionary adaptation from water to dry land.',
      },
    ],
    's3_steps': [
      {
        't': 'Step 1: Table 12.3 Inspection',
        'i':
            'Examine the Advantage (Green) and Challenge (Amber) slots for all 5 classes.',
        'o': 'Table 12.3 matrix active.',
        'c':
            'Evolutionary transitions involve balancing adaptations against limitations.',
      },
      {
        't': 'Step 2: Place Advantage & Challenge Strips',
        'i':
            'Assign each strip into the correct class Advantage or Challenge slot.',
        'o': 'Table 12.3 reconstructed.',
        'c': 'Highlights survival strategies across the plant kingdom.',
      },
    ],
    's4_steps': [
      {
        't': 'Step 1: Histological Cross-Section',
        'i':
            'Observe the concentric xylem core and phloem ring in the fern stem.',
        'o': 'Microscope station active.',
        'c':
            'Vascular tissue enabled plants to grow tall and colonize inland habitats.',
      },
      {
        't': 'Step 2: Assign Labels & Simulate Flow',
        'i':
            'Slot \'Xylem\' (water) and \'Phloem\' (food), then click \'Show Flow\'.',
        'o': 'Transport flow simulated.',
        'c':
            'Xylem transports water unidirectionally; Phloem transports food bidirectionally.',
      },
    ],

    's1_learn':
        'Kingdom Plantae evolved in a sequence from water to land: Thallophyta → Bryophyta → Pteridophyta → Gymnosperm → Angiosperm.',
    's2_learn':
        'Bryophytes are plant amphibians because they live on land but need water for reproduction; Gymnosperms and Angiosperms produce seeds.',
    's3_learn':
        'Table 12.3 shows how plants evolved transport tissues, seeds, and flowers to overcome terrestrial challenges.',
    's4_learn':
        'Vascular tissues (Xylem for water, Phloem for food) distinguish vascular plants from simpler non-vascular plants.',
    ..._plantaeExtraEn,
  },
  'hi': {
    'title': 'पादप वर्गीकरण (जगत प्लांटी)',
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
    'placeOnRung': 'पायदान पर रखें:',
    'specFeature': 'नमूना विशेषता',
    'gotIt': 'समझ गया',
    'showFlow': 'प्रवाह दिखाएं',
    's4Title': 'फर्न तने का अनुप्रस्थ काट (क्रियाकलाप 12.7)',
    'itemsPlaced': 'वस्तुएं: {n}/5 रखी गईं',

    'rung1_label': 'पायदान ①: जलीय',
    'rung2_label': 'पायदान ②: उभयचर',
    'rung3_label': 'पायदान ③: संवहनी स्थल',
    'rung4_label': 'पायदान ④: नग्नबीजी',
    'rung5_label': 'पायदान ⑤: पुष्प व फल',

    'rungBtns': ['पायदान 1', 'पायदान 2', 'पायदान 3', 'पायदान 4', 'पायदान 5'],

    'spirogyra': 'स्पाइरोगाइरा',
    'marchantia': 'मार्केन्शिया व मॉस',
    'fern': 'फर्न का पत्ता',
    'pine': 'चीड़ (शंकु सहित)',
    'gulmohar': 'गुलमोहर पुष्प',

    'hud_s1':
        'पौधों के 5 नमूनों को 3D जल-से-स्थल सीढ़ी पर जटिलता के बढ़ते क्रम में रखें।',
    'hud_s2': 'प्रत्येक लक्षण कार्ड को उसके संबंधित पादप वर्ग कॉलम में रखें।',
    'hud_s3':
        'सारणी 12.3 का पुनर्निर्माण करें: लाभ और चुनौती पट्टियों को सही वर्ग में रखें।',
    'hud_s4':
        'फर्न तने के काट में जाइलम और फ्लोएम को पहचानें और संवहनी प्रवाह देखें।',

    's2_traits': [
      {'id': 't1', 'text': 'सरल थैलस काय', 'cls': 'thallo'},
      {'id': 't2', 'text': 'जल में पाए जाने वाले', 'cls': 'thallo'},
      {'id': 't3', 'text': 'वास्तविक जड़/तना अनुपस्थित', 'cls': 'thallo'},
      {'id': 't4', 'text': 'मूलाभास (राइजोइड्स)', 'cls': 'bryo'},
      {'id': 't5', 'text': '\'पादप जगत के उभयचर\'', 'cls': 'bryo'},
      {'id': 't6', 'text': 'जनन हेतु जल आवश्यक', 'cls': 'bryo'},
      {'id': 't7', 'text': 'वास्तविक जड़, तना व पत्तियां', 'cls': 'pteri'},
      {'id': 't8', 'text': 'संवहनी ऊतक (जाइलम/फ्लोएम)', 'cls': 'pteri'},
      {'id': 't9', 'text': 'बीजरहित', 'cls': 'pteri'},
      {'id': 't10', 'text': 'सुई जैसी पत्तियां', 'cls': 'gymno'},
      {'id': 't11', 'text': 'शंकुओं पर बीज', 'cls': 'gymno'},
      {'id': 't12', 'text': 'नग्न बीज', 'cls': 'gymno'},
      {'id': 't13', 'text': 'पुष्प उत्पन्न करते हैं', 'cls': 'angio'},
      {'id': 't14', 'text': 'फलों में बंद बीज', 'cls': 'angio'},
      {'id': 't15', 'text': 'अत्यधिक विविधतापूर्ण', 'cls': 'angio'},
    ],
    'dropTraitsHere': '[ यहां लक्षण रखें ]',

    's3_table_title': 'सारणी 12.3: जीवन संघर्ष हेतु लाभ एवं चुनौतियां',
    'advSlotLabel': '[ लाभ का स्थान ]',
    'chalSlotLabel': '[ चुनौती का स्थान ]',
    's3_strips': {
      'thallo_adv':
          'सरल पादप काय जल में जीवित रहने और प्रकीर्णन में सहायता करता है।',
      'thallo_chal': 'ये स्थल पर जीवित नहीं रह सकते।',
      'bryo_adv':
          'ये पादप उभयचर हैं। इनका शरीर नम भूमि पर रहने हेतु अनुकूलित है।',
      'bryo_chal': 'इन्हें सदैव नमी की आवश्यकता होती है।',
      'pteri_adv':
          'ये स्थल पर रहते हैं और पादप के सभी भागों में जल व भोजन का संवहन करते हैं।',
      'pteri_chal': 'जल के बिना जनन संभव नहीं होता।',
      'gymno_adv':
          'पत्तियां शुष्क परिस्थितियों हेतु अनुकूलित हैं। जनन हेतु जल की आवश्यकता नहीं होती। ये बीज बनाते हैं।',
      'gymno_chal': 'बीज फलों के रूप में ढके नहीं होते (नग्न होते हैं)।',
      'angio_adv':
          'ये पुष्प, फल और बीज बनाते हैं। इनमें सुविकसित जनन तंत्र होता है। इनके बीज फलों में ढके होते हैं।',
      'angio_chal':
          'जनन विभिन्न कारकों द्वारा परागण पर निर्भर करता है। इनमें सुविकसित ऊतक प्रणाली द्वारा जटिल प्रक्रियाएं होती हैं।',
    },

    'vessel1Title': 'संवहनी वाहिका ① (आंतरिक क्रोड/जाइलम)',
    'vessel2Title': 'संवहनी वाहिका ② (बाह्य वलय/फ्लोएम)',
    'tissueSlotText': '[ ऊतक का नाम ]',
    'funcSlotText': '[ कार्य ]',
    'phloemZoneText': 'फ्लोएम क्षेत्र',
    'xylemCoreText': 'जाइलम क्रोड',
    's4_items': [
      {'id': 'xylem', 'text': 'जाइलम', 'type': 'tissue'},
      {'id': 'phloem', 'text': 'फ्लोएम', 'type': 'tissue'},
      {'id': 'water', 'text': 'जल एवं खनिजों का संवहन', 'type': 'func'},
      {'id': 'food', 'text': 'भोजन का स्थानांतरण', 'type': 'func'},
    ],

    'callouts': {
      'spirogyra': {
        't': 'स्पाइरोगाइरा (थैलोफाइटा)',
        'b':
            'पानी में तैरता हुआ सरल थैलस काय, जिसमें सर्पिलाकार क्लोरोप्लास्ट होते हैं।',
      },
      'marchantia': {
        't': 'मार्केन्शिया व मॉस (ब्रायोफाइटा)',
        'b': 'मूलाभास (राइजोइड्स) युक्त काय; जनन हेतु जल की आवश्यकता होती है।',
      },
      'fern': {
        't': 'फर्न (टेरिडोफाइटा)',
        'b':
            'वास्तविक जड़, तना, पत्तियां और संवहन ऊतक (जाइलम/फ्लोएम); बीजरहित।',
      },
      'pine': {
        't': 'चीड़ (जिम्नोस्पर्म)',
        'b':
            'शुष्क परिस्थितियों हेतु अनुकूलित सुई जैसी पत्तियां; शंकु पर नग्न बीज।',
      },
      'gulmohar': {
        't': 'गुलमोहर (एंजियोस्पर्म)',
        'b': 'सर्वाधिक जटिल संगठन; परागण हेतु पुष्प और फल में बंद बीज।',
      },
    },

    'pedestalInfo': {
      '1':
          '<strong>पायदान ① मानदंड (थैलोफाइटा):</strong><br>• मुख्य रूप से जल में पाए जाने वाले सरलतम पादप।<br>• सरल अविभेदित थैलस शरीर।<br>• गैसों और जल का सीधा विनिमय।<br><em>(उदाहरण: स्पाइरोगाइरा)</em>',
      '2':
          '<strong>पायदान ② मानदंड (ब्रायोफाइटा):</strong><br>• मूलाभास (राइजोइड्स) युक्त विभेदित काय।<br>• तने और पत्ती जैसी सरल संरचनाएं।<br>• जनन हेतु जल अनिवार्य — \'पादप जगत के उभयचर\'।<br><em>(उदाहरण: मार्केन्शिया और मॉस)</em>',
      '3':
          '<strong>पायदान ③ मानदंड (टेरिडोफाइटा):</strong><br>• वास्तविक जड़, तना और पत्तियां।<br>• विशिष्ट संवहन ऊतक: जाइलम और फ्लोएम।<br>• जनन हेतु जल आवश्यक; बीज नहीं बनते।<br><em>(उदाहरण: फर्न)</em>',
      '4':
          '<strong>पायदान ④ मानदंड (जिम्नोस्पर्म):</strong><br>• सुई जैसी या शल्की पत्तियां।<br>• फलों में बंद न होकर शंकुओं पर नग्न बीज।<br>• निषेचन हेतु जल की आवश्यकता नहीं।<br><em>(उदाहरण: चीड़ और साइकस)</em>',
      '5':
          '<strong>पायदान ⑤ मानदंड (एंजियोस्पर्म):</strong><br>• सर्वाधिक जटिल शारीरिक संगठन।<br>• परागण हेतु पुष्प और बीजों को फैलाने हेतु फल।<br>• पृथ्वी पर सबसे विविध पादप समूह।<br><em>(उदाहरण: गुलमोहर / पुष्पी पादप)</em>',
    },

    'concTitle': 'पादप जगत वर्गीकरण एवं विकास',
    'concHead1': '1. जल से स्थल का विकासीय क्रम',
    'concBody1':
        'जलीय शैवाल (थैलोफाइटा) से लेकर पादप उभयचर (ब्रायोफाइटा), संवहनी बीजरहित पौधे (टेरिडोफाइटा), नग्नबीजी (जिम्नोस्पर्म) और पुष्पी पौधे (एंजियोस्पर्म) तक पौधों ने संवहन ऊतकों और जनन में जल से स्वतंत्रता का विकास किया।',
    'concHead2': '2. संवहनी परिवहन ऊतक (जाइलम एवं फ्लोएम)',
    'concBody2':
        'टेरिडोफाइटा, जिम्नोस्पर्म और एंजियोस्पर्म में संवहन ऊतक होते हैं: जाइलम जड़ों से जल व खनिजों का संवहन करता है, जबकि फ्लोएम पत्तियों से निर्मित भोजन का परिवहन करता है।',
    'concHead3': '3. बीज और फल अनुकूलन',
    'concBody3':
        'जिम्नोस्पर्म शुष्क स्थल पर बिना जल निषेचन के शंकुओं पर नग्न बीज बनाते हैं, जबकि एंजियोस्पर्म फलों में बंद बीज बनाते हैं और सर्वाधिक विविध समूह हैं।',
    'evalMetrics': 'मूल्यांकन मेट्रिक्स',
    'metric1': 'संकल्पनात्मक समझ:',
    'metric2': 'अवलोकन एवं पहचान:',
    'metric3': 'वैज्ञानिक तर्क:',
    'metric4': 'वर्गीकरण एवं मॉडलिंग:',

    's1_title': '1. जल-से-स्थल सीढ़ी',
    's2_title': '2. लक्षण मिलान बोर्ड',
    's3_title': '3. लाभ एवं चुनौतियां सारणी',
    's4_title': '4. जाइलम/फ्लोएम सूक्ष्मदर्शी स्टेशन',

    's1_obj': 'पादप जगत के 5 वर्गों को 3D जल-से-स्थल सीढ़ी पर व्यवस्थित करना।',
    's2_obj':
        '15 नैदानिक लक्षणों को उनके संबंधित पादप वर्ग में व्यवस्थित करना।',
    's3_obj': 'सारणी 12.3 को लाभ व चुनौतियों की पट्टियों से पूरा करना।',
    's4_obj': 'तने के काट में संवहन ऊतकों को पहचानना और परिवहन अनुकरण देखना।',

    's1_steps': [
      {
        't': 'कदम 1: जलीय शैवाल (थैलोफाइटा)',
        'i': 'स्पाइरोगाइरा को पायदान ① पर रखें।',
        'o': 'स्पाइरोगाइरा पायदान ① पर स्थापित।',
        'c': 'थैलोफाइटा का शरीर अविभेदित थैलस होता है।',
      },
      {
        't': 'कदम 2: पादप उभयचर (ब्रायोफाइटा)',
        'i': 'मार्केन्शिया व मॉस को पायदान ② पर रखें।',
        'o': 'मार्केन्शिया पायदान ② पर स्थापित।',
        'c': 'ब्रायोफाइटा नम स्थल पर रहते हैं किंतु जनन हेतु जल आवश्यक है।',
      },
      {
        't': 'कदम 3: संवहनी पादप (टेरिडोफाइटा)',
        'i': 'फर्न के पत्ते को पायदान ③ पर रखें।',
        'o': 'फर्न पायदान ③ पर स्थापित।',
        'c': 'टेरिडोफाइटा में जाइलम व फ्लोएम होते हैं किंतु बीज नहीं होते।',
      },
      {
        't': 'कदम 4: नग्नबीजी (जिम्नोस्पर्म)',
        'i': 'चीड़ के शंकु को पायदान ④ पर रखें।',
        'o': 'चीड़ पायदान ④ पर स्थापित।',
        'c': 'जिम्नोस्पर्म शंकुओं पर नग्न बीज बनाते हैं।',
      },
      {
        't': 'कदम 5: पुष्पी पादप (एंजियोस्पर्म)',
        'i': 'गुलमोहर के पौधे को पायदान ⑤ पर रखें।',
        'o': 'गुलमोहर पायदान ⑤ पर स्थापित।',
        'c': 'एंजियोस्पर्म पुष्प और फल बनाते हैं।',
      },
    ],
    's2_steps': [
      {
        't': 'कदम 1: वर्ग कॉलम अवलोकन',
        'i': '5 पादप वर्ग कॉलम देखें।',
        'o': '5 कॉलम सक्रिय।',
        'c': 'लक्षण पादप अनुकूलन को दर्शाते हैं।',
      },
      {
        't': 'कदम 2: लक्षण कार्ड्स का मिलान',
        'i': 'ट्रे से लक्षण कार्ड्स को संबंधित वर्ग में रखें।',
        'o': 'सभी 15 कार्ड्स व्यवस्थित।',
        'c': 'प्रत्येक वर्ग के विशिष्ट अनुकूलन होते हैं।',
      },
    ],
    's3_steps': [
      {
        't': 'कदम 1: सारणी 12.3 निरीक्षण',
        'i': 'लाभ व चुनौतियों के स्थान देखें।',
        'o': 'सारणी तैयार।',
        'c': 'विकास के साथ नए लाभ और सीमाएं आती हैं।',
      },
      {
        't': 'कदम 2: सारणी का निर्माण',
        'i': 'पट्टियों को सही कॉलम में रखें।',
        'o': 'सारणी 12.3 पूर्ण।',
        'c': 'अनुकूलन पादप जीवन को संतुलित करते हैं।',
      },
    ],
    's4_steps': [
      {
        't': 'कदम 1: संवहनी काट',
        'i': 'फर्न तने के काट में संवहन वलयों को देखें।',
        'o': 'सूक्ष्मदर्शी स्टेशन सक्रिय।',
        'c': 'संवहन ऊतकों ने पौधों को भूमि पर बढ़ने में मदद की।',
      },
      {
        't': 'कदम 2: जाइलम व फ्लोएम प्रवाह',
        'i': '\'जाइलम\' व \'फ्लोएम\' जोड़ें और प्रवाह देखें।',
        'o': 'ऊतक सत्यापित व प्रवाहित।',
        'c': 'जाइलम जल का तथा फ्लोएम भोजन का परिवहन करता है।',
      },
    ],

    's1_learn':
        'पादप जगत जल से स्थल की ओर विकसित हुआ: थैलोफाइटा → ब्रायोफाइटा → टेरिडोफाइटा → जिम्नोस्पर्म → एंजियोस्पर्म।',
    's2_learn':
        'ब्रायोफाइटा को पादप जगत का उभयचर कहते हैं क्योंकि इनका शरीर स्थल पर रहता है पर जनन हेतु जल चाहिए।',
    's3_learn':
        'सारणी 12.3 दर्शाती है कि प्रत्येक वर्ग कैसे लाभों और चुनौतियों का संतुलन बनाता है।',
    's4_learn':
        'संवहन ऊतक (जाइलम जल हेतु, फ्लोएम भोजन हेतु) पौधों को जटिल और लंबा बनने में सक्षम बनाते हैं।',
    ..._plantaeExtraHi,
  },
});

// ---------------------------------------------------------------------------
// Activity data shared by the three.js ladder, the trays and the boards.

/// Specimen order = rung order = plant class order (water -> land).
const _kSpecimens = ['spirogyra', 'marchantia', 'fern', 'pine', 'gulmohar'];
const _kClassKeys = ['thallo', 'bryo', 'pteri', 'gymno', 'angio'];
const _kClassColors = [
  _rt_Tw.cyan500,
  _rt_Tw.emerald500,
  _rt_Tw.amber500,
  _rt_Tw.rose500,
  _rt_Tw.green500,
];
const _kClassIcons = [
  Icons.waves,
  Icons.grass,
  Icons.eco,
  Icons.park,
  Icons.local_florist,
];
const _kSpecimenHomeX = [-5.2, -2.6, 0.0, 2.6, 5.2];
const _kSpecimenSpin = [0.25, 0.15, 0.2, 0.2, 0.2];
const _kRungCircled = ['①', '②', '③', '④', '⑤'];
const _kS3Slots = [
  'thallo_adv',
  'thallo_chal',
  'bryo_adv',
  'bryo_chal',
  'pteri_adv',
  'pteri_chal',
  'gymno_adv',
  'gymno_chal',
  'angio_adv',
  'angio_chal',
];
const _kS4Items = ['xylem', 'phloem', 'water', 'food'];
const _kS4Expected = {
  'tissue1': 'xylem',
  'func1': 'water',
  'tissue2': 'phloem',
  'func2': 'food',
};

class Cl9Ch12A4PlantClassificationPlantaePage extends StatefulWidget {
  const Cl9Ch12A4PlantClassificationPlantaePage({super.key});

  @override
  State<Cl9Ch12A4PlantClassificationPlantaePage> createState() =>
      _Cl9Ch12A4PlantClassificationPlantaePageState();
}

class _Cl9Ch12A4PlantClassificationPlantaePageState
    extends State<Cl9Ch12A4PlantClassificationPlantaePage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(background: const Color(0xFF020617));
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 45,
    position: _rt_V3(0, 6, 17.5),
    target: _rt_V3(1, 3, 0),
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  // Restart/dispose abandon a specimen hop instead of letting it finish.
  final _rt_TweenRunner _tweens = _rt_TweenRunner(resumeOnCancel: false);
  final _rt_ShellController _shell = _rt_ShellController();
  final math.Random _rng = math.Random();

  /// Bumped every rendered frame: drives the projected 3D labels and the
  /// microscope pulse / flow animations.
  final ValueNotifier<int> _frameTick = ValueNotifier(0);

  late final _rt_Node3D _ladder;
  late final _rt_Mesh3D _table;
  final Map<String, _rt_Node3D> _specimenNodes = {};
  final List<_rt_V3> _rungTargets = [
    _rt_V3(-4.4, 0.45, -2.1),
    _rt_V3(-2.2, 1.35, -2.1),
    _rt_V3(0, 2.25, -2.1),
    _rt_V3(2.2, 3.15, -2.1),
    _rt_V3(4.4, 4.05, -2.1),
  ];
  final Map<String, int> _moveTokens = {};
  Size _viewSize = Size.zero;
  Size? _fittedSize;
  double _time = 0;

  // --- LAB STATE ---
  int _scenario = 1;
  int? _openStep = 0;
  bool _locked = true;
  bool _panMode = false;
  bool _labelsVisible = true;
  bool _sidebarOpen = true;
  Offset _hudOffset = Offset.zero;

  // Scenario 1: specimen -> rung (0 = still on the table).
  final Map<String, int> _s1 = {for (final s in _kSpecimens) s: 0};
  String _activeSpecimen = 'spirogyra';
  bool _specimenPicked = false;
  String? _callout;

  // Scenario 2: class -> trait ids.
  final Map<String, List<String>> _s2 = {
    for (final c in _kClassKeys) c: <String>[],
  };
  List<int> _s2Order = [];
  String? _selTrait;

  // Scenario 3: slot -> strip key.
  final Map<String, String> _s3 = {};
  final Map<String, bool> _s3Verdict = {};
  String? _selStrip;

  // Scenario 4: slot -> item id.
  final Map<String, String> _s4 = {};
  final Map<String, bool> _s4Verdict = {};
  List<String> _s4Order = [];
  String? _selItem;
  bool _flowOn = false;

  // Timers (setTimeout) - cancelled on restart / dispose.
  final List<Timer> _timers = [];
  int _gen = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _camera.maxPolarAngle = math.pi / 2 + 0.02;
    _camera.enablePan = false;
    _buildScene();
    _shuffleS2();
    _shuffleS4();
    _applyVisibility();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    for (final t in _timers) {
      t.cancel();
    }
    _tweens.cancelAll();
    _viewCtrl.dispose();
    _frameTick.dispose();
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

  // ------------------------------------------------------------ helpers ---
  bool get _dark => _rt_appTheme.isDark;
  Color get _glass => _dark ? const Color(0xEB0F172A) : const Color(0xF7FFFFFF);
  Color get _tokenBg => _dark ? _rt_Tw.slate800 : Colors.white;
  Color get _zoneBg => _dark ? const Color(0xCC0F172A) : _rt_Tw.slate50;

  /// Accent text that stays legible on both themes (Tailwind 300 / 700).
  Color _tone(Color c) => _dark
      ? Color.lerp(c, Colors.white, 0.3)!
      : Color.lerp(c, Colors.black, 0.3)!;

  String _f(String key, Map<String, String> vars) {
    var s = _tx.s(key);
    vars.forEach((k, v) => s = s.replaceAll('{$k}', v));
    return s;
  }

  String _traitText(String id) {
    for (final t in _tx.list('s2_traits')) {
      if (t is Map && t['id'] == id) return t['text'] as String;
    }
    return id;
  }

  String _itemText(String id) {
    for (final t in _tx.list('s4_items')) {
      if (t is Map && t['id'] == id) return t['text'] as String;
    }
    return id;
  }

  void _toast(
    String msg, {
    Color color = _rt_Tw.emerald500,
    IconData icon = Icons.check_circle,
  }) => _shell.showToast(msg, color: color, icon: icon, ms: 2600);

  void _toastError(String msg) =>
      _toast(msg, color: _rt_Tw.rose500, icon: Icons.error_outline);

  void _toastInfo(String msg) =>
      _toast(msg, color: _rt_Tw.amber500, icon: Icons.lightbulb);

  void _toastSelect(String msg) =>
      _toast(msg, color: _rt_Tw.blue500, icon: Icons.touch_app);

  void _shuffleS2() {
    _s2Order = List<int>.generate(15, (i) => i)..shuffle(_rng);
  }

  void _shuffleS4() {
    _s4Order = List<String>.of(_kS4Items)..shuffle(_rng);
  }

  // ------------------------------------------------------------- scene ---
  _rt_Material3D _std(int rgb, {double opacity = 1, double shininess = 0}) =>
      _rt_Material3D(
        color: Color(0xFF000000 | rgb),
        opacity: opacity,
        shininess: shininess,
      );

  _rt_Material3D _basic(int rgb) =>
      _rt_Material3D(color: Color(0xFF000000 | rgb), unlit: true);

  void _buildScene() {
    _scene.setLights([
      _rt_Light3D.hemisphere(
        color: const Color(0xFFE0F2FE),
        groundColor: const Color(0xFF0F172A),
        intensity: 0.75,
      ),
      _rt_Light3D.directional(_rt_V3(8, 16, 10), intensity: 0.7),
    ]);

    // THREE.GridHelper(28, 28, 0x10b981, 0x1e293b): floor, always behind.
    final minor = <_rt_V3>[], major = <_rt_V3>[];
    for (var i = -14; i <= 14; i++) {
      final d = i.toDouble();
      (i == 0 ? major : minor).addAll([
        _rt_V3(d, 0, -14),
        _rt_V3(d, 0, 14),
        _rt_V3(-14, 0, d),
        _rt_V3(14, 0, d),
      ]);
    }
    _scene.add(
      _rt_Line3D(
          minor,
          color: const Color(0xFF1E293B),
          width: 1,
          segments: true,
        )
        ..depthBias = 1000
        ..pickable = false,
    );
    _scene.add(
      _rt_Line3D(
          major,
          color: const Color(0xFF10B981),
          width: 1.4,
          segments: true,
        )
        ..depthBias = 1000
        ..pickable = false,
    );

    // Specimen bench in front of the ladder.
    _table = _rt_Mesh3D(_rt_Geometry3D.box(12.5, 0.35, 2.2), _std(0x1e293b))
      ..position.set(0, 0.175, 3.5);
    _scene.add(_table);

    // Inclined water-to-land ladder: two rails + five colour-coded rungs.
    _ladder = _rt_Node3D(name: 'ladder');
    final railMat = _std(0x78350f);
    for (final z in [-3.2, -1.0]) {
      _ladder.add(
        _rt_Mesh3D(_rt_Geometry3D.cylinder(0.1, 0.1, 12, segments: 10), railMat)
          ..rotation.z = -math.pi / 4.8
          ..position.set(0, 2.2, z),
      );
    }
    final padMat = _std(0x1e293b);
    for (var i = 0; i < 5; i++) {
      final holder = _rt_Node3D(name: 'rung$i')..position.copy(_rungTargets[i]);
      holder.add(
        _rt_Mesh3D(
          _rt_Geometry3D.cylinder(0.08, 0.08, 2.3, segments: 10),
          railMat,
        )..rotation.x = math.pi / 2,
      );
      holder.add(
        _rt_Mesh3D(_rt_Geometry3D.cylinder(0.7, 0.7, 0.1, segments: 24), padMat)
          ..position.y = 0.1,
      );
      holder.add(
        _rt_Mesh3D(
            _rt_Geometry3D.torus(
              0.68,
              0.04,
              radialSegments: 4,
              tubularSegments: 32,
            ),
            _rt_Material3D(color: _kClassColors[i], unlit: true),
          )
          ..rotation.x = math.pi / 2
          ..position.y = 0.16,
      );
      _ladder.add(holder);
    }
    _scene.add(_ladder);

    _addSpecimen('spirogyra', _buildSpirogyra());
    _addSpecimen('marchantia', _buildMarchantia());
    _addSpecimen('fern', _buildFern());
    _addSpecimen('pine', _buildPine());
    _addSpecimen('gulmohar', _buildGulmohar());
  }

  _rt_V3 _homeOf(String name) =>
      _rt_V3(_kSpecimenHomeX[_kSpecimens.indexOf(name)], 0.45, 3.5);

  void _addSpecimen(String name, _rt_Node3D g) {
    g.position.copy(_homeOf(name));
    _scene.add(g);
    _specimenNodes[name] = g;
  }

  _rt_Mesh3D _soil() => _rt_Mesh3D(
    _rt_Geometry3D.cylinder(0.8, 0.9, 0.2, segments: 24),
    _std(0x451a03),
  )..position.y = 0.1;

  // 1. Spirogyra (Thallophyta): floating spiral-chloroplast filament.
  _rt_Node3D _buildSpirogyra() {
    final g = _rt_Node3D(name: 'spirogyra');
    g.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.85, 0.85, 0.04, segments: 24),
        _std(0x0284c7, opacity: 0.45),
      )..position.y = 0.05,
    );
    final cellMat = _std(0xa7f3d0, opacity: 0.75, shininess: 0.4);
    final cellGeo = _rt_Geometry3D.cylinder(0.18, 0.18, 0.7, segments: 14);
    final ribMat = _basic(0x15803d);
    final ribGeo = _rt_Geometry3D.torus(
      0.14,
      0.02,
      radialSegments: 4,
      tubularSegments: 14,
    );
    for (var i = 0; i < 3; i++) {
      g.add(
        _rt_Mesh3D(cellGeo, cellMat)
          ..position.set(0, 0.4 + i * 0.65, i.isEven ? 0.05 : -0.05),
      );
      for (var j = 0; j < 5; j++) {
        g.add(
          _rt_Mesh3D(ribGeo, ribMat)
            ..rotation.x = math.pi / 3
            ..rotation.z = j * 0.6
            ..position.set(0, 0.2 + i * 0.65 + j * 0.1, 0),
        );
      }
    }
    return g;
  }

  // 2. Marchantia & moss (Bryophyta): lobed thallus, rhizoids, stalks.
  _rt_Node3D _buildMarchantia() {
    final g = _rt_Node3D(name: 'marchantia')..add(_soil());
    final thallusMat = _std(0x15803d);
    final thallusGeo = _rt_Geometry3D.box(0.45, 0.04, 0.3);
    for (var i = 0; i < 4; i++) {
      g.add(
        _rt_Mesh3D(thallusGeo, thallusMat)
          ..position.set(
            math.cos(i * 1.5) * 0.25,
            0.22,
            math.sin(i * 1.5) * 0.25,
          )
          ..rotation.y = i * 1.5,
      );
    }
    final rhizoMat = _basic(0x78350f);
    final rhizoGeo = _rt_Geometry3D.cylinder(0.012, 0.012, 0.18, segments: 4);
    for (var i = 0; i < 8; i++) {
      g.add(
        _rt_Mesh3D(rhizoGeo, rhizoMat)
          ..position.set(
            (_rng.nextDouble() - 0.5) * 0.5,
            0.05,
            (_rng.nextDouble() - 0.5) * 0.5,
          ),
      );
    }
    final stalkMat = _basic(0x22c55e);
    final stalkGeo = _rt_Geometry3D.cylinder(0.015, 0.015, 0.55, segments: 6);
    final capMat = _std(0x854d0e);
    for (var i = 0; i < 3; i++) {
      final x = -0.15 + i * 0.15;
      g.add(_rt_Mesh3D(stalkGeo, stalkMat)..position.set(x, 0.45, 0));
      g.add(_rt_Sphere3D(0.05, capMat)..position.set(x, 0.72, 0));
    }
    return g;
  }

  // 3. Fern frond (Pteridophyta): rachis with paired pinnae.
  _rt_Node3D _buildFern() {
    final g = _rt_Node3D(name: 'fern')..add(_soil());
    g.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(0.04, 0.06, 1.4, segments: 10),
          _std(0x166534),
        )
        ..position.set(0, 0.75, 0)
        ..rotation.z = -0.15,
    );
    final pinnaMat = _std(0x22c55e);
    final pinnaGeo = _rt_Geometry3D.box(0.28, 0.02, 0.1);
    for (var i = 0; i < 6; i++) {
      final y = 0.35 + i * 0.18;
      g.add(
        _rt_Mesh3D(pinnaGeo, pinnaMat)
          ..position.set(-0.15, y, 0)
          ..rotation.z = 0.25,
      );
      g.add(
        _rt_Mesh3D(pinnaGeo, pinnaMat)
          ..position.set(0.15, y, 0)
          ..rotation.z = -0.25,
      );
    }
    return g;
  }

  // 4. Pine conifer (Gymnosperm): needle layers + woody cone.
  _rt_Node3D _buildPine() {
    final g = _rt_Node3D(name: 'pine');
    g.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.08, 0.14, 1.3, segments: 12),
        _std(0x78350f),
      )..position.y = 0.65,
    );
    final needleMat = _std(0x14532d);
    for (var i = 0; i < 3; i++) {
      g.add(
        _rt_Mesh3D(
          _rt_Geometry3D.cone(0.55 - i * 0.12, 0.5, segments: 12),
          needleMat,
        )..position.set(0, 0.65 + i * 0.35, 0),
      );
    }
    g.add(
      _rt_Mesh3D(_rt_Geometry3D.cone(0.12, 0.28, segments: 8), _std(0x92400e))
        ..rotation.z = math.pi
        ..position.set(0.22, 0.65, 0.1),
    );
    return g;
  }

  // 5. Gulmohar (Angiosperm): stem, five-petal flower, seed pod.
  _rt_Node3D _buildGulmohar() {
    final g = _rt_Node3D(name: 'gulmohar');
    g.add(
      _rt_Mesh3D(
        _rt_Geometry3D.cylinder(0.06, 0.1, 1.35, segments: 12),
        _std(0x15803d),
      )..position.y = 0.65,
    );
    final flower = _rt_Node3D(name: 'flower')..position.y = 1.35;
    final petalMat = _std(0xf97316, shininess: 0.3);
    final petalGeo = _rt_Geometry3D.cylinder(0.18, 0.22, 0.05, segments: 12);
    for (var i = 0; i < 5; i++) {
      final a = i * math.pi * 2 / 5;
      flower.add(
        _rt_Mesh3D(petalGeo, petalMat)
          ..rotation.x = math.pi / 4
          ..rotation.y = a
          ..position.set(math.cos(a) * 0.12, 0, math.sin(a) * 0.12),
      );
    }
    g.add(flower);
    g.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(0.04, 0.04, 0.65, segments: 8),
          _std(0x713f12),
        )
        ..position.set(-0.25, 0.8, 0)
        ..rotation.z = -0.45,
    );
    return g;
  }

  /// Ladder, bench and specimens exist only in scenario 1 (HTML `setStep`).
  void _applyVisibility() {
    final s1 = _scenario == 1;
    _ladder.visible = s1;
    _table.visible = s1;
    for (final n in _specimenNodes.values) {
      n.visible = s1;
    }
  }

  /// HTML `cameraReset` home view. The source camera assumes a desktop
  /// canvas, so this keeps its viewing direction (the desktop one from
  /// 768 px, the mobile one below) and solves distance + pan so the ladder
  /// and the bench fill the area the HUD card and tool stack leave free.
  void _fitCamera(Size size) {
    if (size.width < 60 || size.height < 60) return;
    final key = Size(size.width.roundToDouble(), size.height.roundToDouble());
    if (_fittedSize == key) return;
    final first = _fittedSize == null;
    _fittedSize = key;

    final hudBottom =
        8.0 + (size.width < 420 ? 78.0 : (size.width < 700 ? 58.0 : 50.0));
    final band = Rect.fromLTRB(
      12,
      math.min(hudBottom + 6, size.height * 0.45),
      size.width - 70,
      size.height - 12,
    );
    final dir = (size.width >= 768 ? _rt_V3(0, 4.8, 13) : _rt_V3(0, 4.8, 17.5))
        .normalized();
    // (point, horizontal margin, vertical margin) in screen pixels.
    final points = <(_rt_V3, double, double)>[
      for (final r in _rungTargets) (r + _rt_V3(0, 0.85, 0), 10, 12),
      for (final x in _kSpecimenHomeX) (_rt_V3(x, -0.2, 3.5), 24, 10),
      for (final x in [-6.25, 6.25])
        for (final z in [2.4, 4.6]) (_rt_V3(x, 0.35, z), 0, 0),
    ];
    final probe = _rt_Camera3D(fov: _camera.fov);

    Rect? bounds(_rt_ProjectionFrame pf) {
      var l = double.infinity, t = double.infinity;
      var r = double.negativeInfinity, b = double.negativeInfinity;
      for (final (p, mx, my) in points) {
        final s = pf.project(p);
        if (s == null) return null;
        l = math.min(l, s.dx - mx);
        r = math.max(r, s.dx + mx);
        t = math.min(t, s.dy - my);
        b = math.max(b, s.dy + my);
      }
      return Rect.fromLTRB(l, t, r, b);
    }

    (bool, _rt_V3) attempt(double dist) {
      var target = _rt_V3(0.3, 2.0, 0.6);
      for (var pass = 0; pass < 4; pass++) {
        probe.target.copy(target);
        probe.position.copy(target + dir * dist);
        final pf = probe.frame(size);
        final b = bounds(pf);
        if (b == null) return (false, target);
        final shift = band.center - b.center;
        final ppu = pf.focal / dist;
        target =
            target + pf.right * (-shift.dx / ppu) + pf.up * (shift.dy / ppu);
      }
      probe.target.copy(target);
      probe.position.copy(target + dir * dist);
      final b = bounds(probe.frame(size));
      final fits =
          b != null && b.width <= band.width && b.height <= band.height;
      return (fits, target);
    }

    var lo = 5.0, hi = 80.0;
    for (var i = 0; i < 18; i++) {
      final mid = (lo + hi) / 2;
      if (attempt(mid).$1) {
        hi = mid;
      } else {
        lo = mid;
      }
    }
    final target = attempt(hi).$2;
    final keepPos = _camera.position.clone();
    final keepTarget = _camera.target.clone();
    _camera.target.copy(target);
    _camera.position.copy(target + dir * hi);
    _camera.saveHome();
    if (!first && !_locked) {
      // An unlocked, user-moved view stays put; only "reset view" changes.
      _camera.position.copy(keepPos);
      _camera.target.copy(keepTarget);
    }
  }

  void _onFrame(double dt) {
    _tweens.update(dt);
    _time += dt;
    final t = _time * 1.5;
    for (var i = 0; i < _kSpecimens.length; i++) {
      _specimenNodes[_kSpecimens[i]]?.rotation.y = t * _kSpecimenSpin[i];
    }
    final open = _shell.isSidebarOpen;
    if (open != _sidebarOpen && mounted) setState(() => _sidebarOpen = open);
    _frameTick.value++;
  }

  void _moveSpecimen(String name, _rt_V3 to, {bool animate = true}) {
    final node = _specimenNodes[name];
    if (node == null) return;
    final token = (_moveTokens[name] ?? 0) + 1;
    _moveTokens[name] = token;
    if (!animate) {
      node.position.copy(to);
      return;
    }
    final from = node.position.clone();
    // gsap.to(mesh.position, {duration: 0.6, ease: "back.out(1.7)"}).
    _tweens.run(600, (t) {
      if (_moveTokens[name] != token) return;
      node.position.set(
        from.x + (to.x - from.x) * t,
        from.y + (to.y - from.y) * t,
        from.z + (to.z - from.z) * t,
      );
    }, ease: _rt_Ease.outBack);
  }

  // ------------------------------------------------------ module select ---
  void _setScenario(int n, {bool sound = true}) {
    if (sound) _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _scenario = n;
      _openStep = 0;
      _selTrait = null;
      _selStrip = null;
      _selItem = null;
    });
    _applyVisibility();
    _camera.reset();
  }

  // -------------------------------------------------------- 3D tools ---
  void _toggleLock() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _locked = !_locked);
    _toast(
      _tx.s(_locked ? 'msg.locked' : 'msg.unlocked'),
      icon: _locked ? Icons.lock : Icons.lock_open,
    );
  }

  void _togglePan() {
    if (_locked) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _panMode = !_panMode);
    _camera.enablePan = _panMode;
    _viewCtrl.setMode(_panMode ? _rt_DragMode.pan : _rt_DragMode.rotate);
    _toast(_tx.s(_panMode ? 'msg.panOn' : 'msg.panOff'), icon: Icons.pan_tool);
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _labelsVisible = !_labelsVisible);
    _toast(
      _tx.s(_labelsVisible ? 'msg.labelsOn' : 'msg.labelsOff'),
      icon: Icons.label,
    );
  }

  void _zoom(double factor) {
    if (_locked) return;
    _camera.dolly(factor);
  }

  void _resetCamera() {
    if (_locked) return;
    _camera.reset();
  }

  void _showPedestalInfo(int n) {
    _rt_playSfx(_rt_Sfx.tap);
    _rt_showShellPopup(
      context,
      // The rung's own label, so compact rung badges still reveal it.
      title: _tx.s('rung${n}_label'),
      body: Align(
        alignment: Alignment.centerLeft,
        child: _htmlText(_tx.s('pedestalInfo.$n')),
      ),
      icon: Icons.info,
      color: _rt_Tw.emerald500,
      buttonLabel: _tx.s('gotIt'),
    );
  }

  /// Renders the `<strong>`, `<em>` and `<br>` markup of `pedestalInfo`.
  Widget _htmlText(String html) {
    final spans = <InlineSpan>[];
    final tag = RegExp(r'<(/?)(strong|em|br)\s*/?>');
    var bold = false, italic = false, index = 0;
    void push(String text) {
      if (text.isEmpty) return;
      spans.add(
        TextSpan(
          text: text,
          style: TextStyle(
            fontWeight: bold ? FontWeight.w900 : FontWeight.w500,
            fontStyle: italic ? FontStyle.italic : FontStyle.normal,
            color: bold ? _rt_Lab.text : _rt_Lab.textMuted,
          ),
        ),
      );
    }

    for (final m in tag.allMatches(html)) {
      push(html.substring(index, m.start));
      final closing = m.group(1) == '/';
      switch (m.group(2)) {
        case 'br':
          spans.add(const TextSpan(text: '\n'));
        case 'strong':
          bold = !closing;
        case 'em':
          italic = !closing;
      }
      index = m.end;
    }
    push(html.substring(index));
    return Text.rich(
      TextSpan(children: spans),
      style: const TextStyle(fontSize: 13, height: 1.5),
    );
  }

  // -------------------------------------------------------- scenario 1 ---
  void _selectSpecimen(String name) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _activeSpecimen = name;
      _specimenPicked = true;
      _callout = name;
    });
  }

  void _assignSpecimenToRung(int rung) {
    _rt_playSfx(_rt_Sfx.pop);
    final name = _activeSpecimen;
    setState(() => _s1[name] = rung);
    _moveSpecimen(name, _rungTargets[rung - 1] + _rt_V3(0, 0.85, 0));
    _toast(
      _f('msg.specToRung', {
        'name': _tx.s(name),
        'rung': _tx.s('rungBtns.${rung - 1}'),
      }),
      icon: Icons.stairs,
    );
  }

  void _resetS1() {
    for (final s in _kSpecimens) {
      _s1[s] = 0;
      _moveSpecimen(s, _homeOf(s), animate: false);
    }
    _specimenPicked = false;
  }

  // -------------------------------------------------------- scenario 2 ---
  void _selectTrait(String id) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _selTrait = id);
    _toastSelect(_f('msg.selTrait', {'trait': _traitText(id)}));
  }

  void _assignTrait(String id, String cls) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      final list = _s2[cls]!;
      if (!list.contains(id)) list.add(id);
    });
    _toast(_f('msg.assigned', {'trait': _traitText(id)}));
  }

  // -------------------------------------------------------- scenario 3 ---
  void _selectStrip(String key) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _selStrip = key);
    _toastSelect(_tx.s('msg.selStrip'));
  }

  void _quickAssignS3(String slot) {
    final key = _selStrip;
    if (key == null) {
      _toastInfo(_tx.s('msg.selectStripFirst'));
      return;
    }
    _placeStrip(key, slot);
  }

  void _placeStrip(String key, String slot) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      // A strip lives in one slot at a time (used strips leave the tray).
      final previous = [
        for (final e in _s3.entries)
          if (e.value == key) e.key,
      ];
      for (final p in previous) {
        _s3.remove(p);
        _s3Verdict.remove(p);
      }
      _s3[slot] = key;
      _s3Verdict.remove(slot);
      if (_selStrip == key) _selStrip = null;
    });
    _toast(_tx.s('msg.stripPlaced'));
  }

  void _clearS3(String slot) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _s3.remove(slot);
      _s3Verdict.remove(slot);
    });
  }

  // -------------------------------------------------------- scenario 4 ---
  void _selectItem(String id) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _selItem = id);
    _toastSelect(_f('msg.selItem', {'text': _itemText(id)}));
  }

  void _quickAssignS4(String slot) {
    final id = _selItem;
    if (id == null) {
      _toastInfo(_tx.s('msg.selectChipFirst'));
      return;
    }
    _placeItem(id, slot);
  }

  void _placeItem(String id, String slot) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _s4[slot] = id;
      _s4Verdict.remove(slot);
      if (_selItem == id) _selItem = null;
    });
    _toast(_f('msg.placed', {'text': _itemText(id)}));
  }

  void _clearS4(String slot) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _s4.remove(slot);
      _s4Verdict.remove(slot);
    });
  }

  void _toggleFlow() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _flowOn = !_flowOn);
    _toast(
      _tx.s(_flowOn ? 'msg.flowOn' : 'msg.flowOff'),
      color: _flowOn ? _rt_Tw.cyan500 : _rt_Tw.slate500,
      icon: Icons.swap_vert,
    );
  }

  // -------------------------------------------------------- validation ---
  void _validate() {
    switch (_scenario) {
      case 1:
        _validateS1();
      case 2:
        _validateS2();
      case 3:
        _validateS3();
      default:
        _validateS4();
    }
  }

  void _validateS1() {
    String? firstError;
    var correct = true;
    for (var i = 0; i < _kSpecimens.length; i++) {
      final name = _kSpecimens[i];
      final rung = _s1[name]!;
      if (rung != i + 1) correct = false;
      if (rung != 0 && rung != i + 1) {
        firstError ??= _tx.s('msg.s1Errors.$name');
      }
    }
    if (firstError != null) {
      _rt_playSfx(_rt_Sfx.wrong);
      _toastError(_f('msg.s1Wrong', {'error': firstError}));
      return;
    }
    if (correct) {
      _rt_playSfx(_rt_Sfx.correct);
      _toast(_tx.s('msg.s1Ok'));
      _after(1200, () => _setScenario(2));
    } else {
      _rt_playSfx(_rt_Sfx.tap);
      _toastInfo(_tx.s('msg.s1Incomplete'));
    }
  }

  void _validateS2() {
    // Source rule: every class column holds at least two trait cards.
    final ok = _kClassKeys.every((c) => _s2[c]!.length >= 2);
    if (ok) {
      _rt_playSfx(_rt_Sfx.correct);
      _toast(_tx.s('msg.s2Ok'));
      _after(1200, () => _setScenario(3));
    } else {
      _rt_playSfx(_rt_Sfx.wrong);
      _toastError(_tx.s('msg.s2Wrong'));
    }
  }

  void _validateS3() {
    final verdict = <String, bool>{};
    var wrong = 0;
    for (final slot in _kS3Slots) {
      final key = _s3[slot];
      if (key == null) {
        wrong++;
        continue;
      }
      final ok = key == slot;
      verdict[slot] = ok;
      if (!ok) wrong++;
    }
    setState(() {
      _s3Verdict
        ..clear()
        ..addAll(verdict);
    });
    bool ok(String slot) => verdict[slot] ?? false;
    if (wrong == 0) {
      _rt_playSfx(_rt_Sfx.correct);
      _toast(_tx.s('msg.s3Ok'));
      _after(1200, () => _setScenario(4));
      return;
    }
    _rt_playSfx(_rt_Sfx.wrong);
    var hint = _tx.s('msg.s3Check');
    if (!ok('pteri_chal')) {
      hint = _tx.s('s3_strips.pteri_chal');
    } else if (!ok('bryo_chal')) {
      hint = _tx.s('s3_strips.bryo_chal');
    } else if (!ok('thallo_chal')) {
      hint = _tx.s('s3_strips.thallo_chal');
    } else if (!ok('gymno_chal')) {
      hint = _tx.s('s3_strips.gymno_chal');
    }
    _toastError(_f('msg.s3Wrong', {'hint': hint}));
  }

  void _validateS4() {
    final verdict = {
      for (final e in _kS4Expected.entries) e.key: _s4[e.key] == e.value,
    };
    setState(() {
      _s4Verdict
        ..clear()
        ..addAll(verdict);
    });
    if (verdict.values.every((v) => v)) {
      if (!_flowOn) _toggleFlow();
      _showConclusion();
    } else {
      _rt_playSfx(_rt_Sfx.wrong);
      _toastError(_tx.s('msg.s4Wrong'));
    }
  }

  void _resetStep() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      switch (_scenario) {
        case 1:
          _resetS1();
        case 2:
          for (final l in _s2.values) {
            l.clear();
          }
          _selTrait = null;
          _shuffleS2();
        case 3:
          _s3.clear();
          _s3Verdict.clear();
          _selStrip = null;
        default:
          _s4.clear();
          _s4Verdict.clear();
          _selItem = null;
          _shuffleS4();
      }
    });
    _toast(_tx.s('msg.stepReset'), color: _rt_Tw.slate500, icon: Icons.replay);
  }

  void _showHint() {
    _rt_playSfx(_rt_Sfx.tap);
    switch (_scenario) {
      case 1:
        _showPedestalInfo(1);
      case 2:
        _toastInfo(_tx.s('msg.hintS2'));
      case 3:
        _toastInfo(_tx.s('msg.hintS3'));
      default:
        _toastInfo(_tx.s('msg.hintS4'));
    }
  }

  Future<void> _showConclusion() async {
    await _shell.showSuccess(
      title: _tx.s('concTitle'),
      icon: Icons.check_circle,
      color: _rt_Tw.emerald500,
      buttonLabel: _tx.s('btnReplay'),
      body: _conclusionBody(),
      onConfirm: () {
        if (mounted) _restart(); // a tap outside just closes the popup
      },
    );
  }

  /// HTML `resetLab`.
  void _restart() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _gen++;
    _tweens.cancelAll();
    _camera.enablePan = false;
    _viewCtrl.setMode(_rt_DragMode.rotate);
    setState(() {
      _locked = true;
      _panMode = false;
      _labelsVisible = true;
      _hudOffset = Offset.zero;
      _resetS1();
      _callout = null;
      for (final l in _s2.values) {
        l.clear();
      }
      _selTrait = null;
      _s3.clear();
      _s3Verdict.clear();
      _selStrip = null;
      _s4.clear();
      _s4Verdict.clear();
      _selItem = null;
      _flowOn = false;
      _shuffleS2();
      _shuffleS4();
    });
    _setScenario(1, sound: false);
    _toast(_tx.s('msg.labReset'), icon: Icons.replay);
  }

  // --------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: _rt_LangBuilder(
        builder: (context, lang) {
          _scene.background = _dark
              ? const Color(0xFF020617)
              : const Color(0xFFF8FAFC);
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.emerald600,
              headerGradient: [_rt_Tw.slate950, Color(0xFF064E3B)],
              headerSubtitleColor: _rt_Tw.emerald400,
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('title'),
              subtitle: _tx.s('subtitle'),
              buttonLabel: _tx.s('enterLab'),
              icon: Icons.spa,
              buttonIcon: Icons.rocket_launch,
            ),
            onRestart: _restart,
            sidebarTop: _moduleSelect(),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('missionObj'),
                icon: Icons.science,
                builder: (_) => _boardTab(),
              ),
            ],
            canvasBackground: _scene.background,
            canvas: _rt_MinWidthGate(minWidth: 240, child: _canvas()),
          );
        },
      ),
    );
  }

  BoxDecoration _panelDecoration({Color? border, double radius = 14}) =>
      BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: border ?? _rt_Lab.border),
        boxShadow: [
          BoxShadow(
            color: _rt_Lab.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      );

  Widget _panel({
    required Widget child,
    Color? border,
    EdgeInsets padding = const EdgeInsets.all(8),
  }) => Container(
    padding: padding,
    decoration: _panelDecoration(border: border),
    child: child,
  );

  Widget _divider({double top = 5, double bottom = 5}) => Container(
    height: 1,
    margin: EdgeInsets.only(top: top, bottom: bottom),
    color: _rt_Lab.border,
  );

  Widget _clearButton(VoidCallback onTap) => Tooltip(
    message: _tx.s('remove'),
    child: InkResponse(
      radius: 14,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(Icons.close, size: 13, color: _rt_Lab.textMuted),
      ),
    ),
  );

  // ---------------------------------------------------- sidebar: top ---
  Widget _moduleSelect() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        border: Border(bottom: BorderSide(color: _rt_Lab.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.science, size: 14, color: _rt_Tw.emerald500),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _tx.s('moduleSel').toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.4,
                    color: _rt_Tw.emerald500,
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
              border: Border.all(color: _rt_Lab.borderStrong, width: 2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _scenario,
                isExpanded: true,
                dropdownColor: _rt_Lab.surface,
                borderRadius: BorderRadius.circular(12),
                iconEnabledColor: _rt_Lab.textMuted,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: _rt_Lab.text,
                ),
                items: [
                  for (var i = 1; i <= 4; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(
                        _tx.s('s${i}_title'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) _setScenario(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------- sidebar: teacher board ---
  Widget _boardTab() {
    final p = 's$_scenario';
    final steps = _tx.list('${p}_steps');
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_SectionLabel(
            _tx.s('missionObj'),
            icon: Icons.gps_fixed,
            color: _rt_Tw.emerald500,
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _rt_Lab.overlay,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rt_Lab.border),
            ),
            child: Text(
              _tx.s('${p}_obj'),
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: _rt_Lab.textMuted,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _rt_SectionLabel(
            _tx.s('detailedSteps'),
            icon: Icons.format_list_numbered,
            color: _rt_Tw.emerald500,
          ),
          for (var i = 0; i < steps.length; i++) _accordion(i, steps[i] as Map),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _rt_Lab.tinted(_rt_Tw.emerald50, _rt_Tw.emerald500),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _rt_Lab.tintedBorder(_rt_Tw.emerald500),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.lightbulb,
                      size: 15,
                      color: _tone(_rt_Tw.emerald500),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _tx.s('what_we_learn').toUpperCase(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1,
                          color: _tone(_rt_Tw.emerald500),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _tx.s('${p}_learn'),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _tone(_rt_Tw.emerald500),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _accordion(int i, Map step) {
    final open = _openStep == i;
    Widget block(
      IconData icon,
      Color color,
      String label,
      String body,
      Color bodyColor,
    ) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.6,
                  color: color,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          body,
          style: TextStyle(fontSize: 11.5, color: bodyColor, height: 1.4),
        ),
      ],
    );
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: open
              ? _rt_Tw.emerald500.withValues(alpha: 0.5)
              : _rt_Lab.border,
        ),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InkWell(
              onTap: () {
                _rt_playSfx(_rt_Sfx.click);
                setState(() => _openStep = open ? null : i);
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _rt_Tw.emerald500.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          color: _tone(_rt_Tw.emerald500),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        step['t'] as String,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _rt_Lab.text,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: open ? 0.5 : 0,
                      duration: const Duration(milliseconds: 250),
                      child: Icon(
                        Icons.expand_more,
                        size: 18,
                        color: _rt_Lab.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (open)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _rt_Lab.overlay,
                  border: Border(top: BorderSide(color: _rt_Lab.border)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    block(
                      Icons.play_arrow,
                      _tone(_rt_Tw.emerald500),
                      _tx.s('taskInstr'),
                      step['i'] as String,
                      _rt_Lab.text,
                    ),
                    const SizedBox(height: 10),
                    block(
                      Icons.visibility,
                      _rt_Tw.blue400,
                      _tx.s('expOut'),
                      step['o'] as String,
                      _rt_Lab.textMuted,
                    ),
                    const SizedBox(height: 10),
                    block(
                      Icons.lightbulb,
                      _tone(_rt_Tw.emerald500),
                      _tx.s('conceptLearned'),
                      step['c'] as String,
                      _tone(_rt_Tw.emerald500),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------ canvas ---
  Widget _canvas() {
    return LayoutBuilder(
      builder: (context, c) {
        final trayMax = (c.maxHeight * (_scenario == 1 ? 0.38 : 0.36)).clamp(
          92.0,
          176.0,
        );
        return Column(
          children: [
            Expanded(child: _stage()),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: trayMax),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(child: _tray()),
                    const SizedBox(width: 6),
                    _actions(),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _stage() {
    // The floating menu button covers the canvas' top-left corner only while
    // the sidebar is collapsed; the back button always covers the top-right.
    final hudLeft = _sidebarOpen ? 8.0 : 70.0;
    return Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, c) {
              _viewSize = c.biggest;
              _fitCamera(c.biggest);
              return _rt_Scene3DView(
                scene: _scene,
                camera: _camera,
                controller: _viewCtrl,
                cameraControls: !_locked && _scenario == 1,
                onFrame: _onFrame,
              );
            },
          ),
        ),
        if (_scenario == 1) ...[
          if (_labelsVisible) Positioned.fill(child: _projectedLabels()),
          Positioned(top: 64, right: 6, bottom: 6, child: _toolStack()),
          Positioned(
            top: 8,
            left: 8,
            right: 70,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: hudLeft - 8),
                  child: _hudCard(),
                ),
                // Specimen feature callout at the left edge under the HUD
                // (below the menu button): the ladder rises to the right,
                // leaving this corner free.
                if (_labelsVisible && _callout != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _calloutCard(_callout!),
                    ),
                  ),
              ],
            ),
          ),
        ] else
          Positioned.fill(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(hudLeft, 8, 70, 6),
                  child: _hudCard(),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(8, 2, 8, 8),
                    child: switch (_scenario) {
                      2 => _s2Board(),
                      3 => _s3Board(),
                      _ => _s4Board(),
                    },
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // --- DRAGGABLE TOP HUD CARD ---
  Widget _hudCard() {
    return Transform.translate(
      offset: _hudOffset,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: _panelDecoration(),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(height: 3, color: _rt_Tw.emerald500),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onPanUpdate: (d) => setState(() {
                    final o = _hudOffset + d.delta;
                    _hudOffset = Offset(
                      o.dx.clamp(-600.0, 600.0),
                      o.dy.clamp(-8.0, 400.0),
                    );
                  }),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.drag_indicator,
                              size: 12,
                              color: _tone(_rt_Tw.emerald500),
                            ),
                            const SizedBox(width: 3),
                            ValueListenableBuilder<int>(
                              valueListenable: _frameTick,
                              builder: (context, _, _) {
                                final ping = (_time % 1.0);
                                return Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: _rt_Tw.emerald400.withValues(
                                      alpha: 1 - ping * 0.7,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _rt_Tw.emerald400.withValues(
                                          alpha: 0.6 * (1 - ping),
                                        ),
                                        blurRadius: 2 + 6 * ping,
                                        spreadRadius: 3 * ping,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                _tx.s('labProgress').toUpperCase(),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: _rt_Lab.text,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _f('stepTag', {'n': '$_scenario'}),
                              style: TextStyle(
                                fontSize: 9,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w800,
                                color: _tone(_rt_Tw.emerald500),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _tx.s('hud_s$_scenario'),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: _tone(_rt_Tw.emerald500),
                          ),
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

  // --- Floating 3D tools stack (lock by default, zoom, pan, labels, reset) ---
  Widget _toolStack() {
    Widget b(
      IconData icon,
      String tip, {
      required bool enabled,
      bool active = false,
      required VoidCallback onTap,
    }) => Tooltip(
      message: tip,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: InkResponse(
          radius: 20,
          onTap: enabled ? onTap : null,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: _glass,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: active
                    ? _rt_Tw.emerald500.withValues(alpha: 0.6)
                    : _rt_Lab.border,
              ),
              boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 6)],
            ),
            child: Icon(
              icon,
              size: 15,
              color: active ? _tone(_rt_Tw.emerald500) : _rt_Lab.textMuted,
            ),
          ),
        ),
      ),
    );
    final buttons = [
      b(
        _locked ? Icons.lock : Icons.lock_open,
        _tx.s('tools.lock'),
        enabled: true,
        active: _locked,
        onTap: _toggleLock,
      ),
      b(
        Icons.add,
        _tx.s('tools.zoomIn'),
        enabled: !_locked,
        onTap: () => _zoom(0.85),
      ),
      b(
        Icons.remove,
        _tx.s('tools.zoomOut'),
        enabled: !_locked,
        onTap: () => _zoom(1.15),
      ),
      b(
        Icons.pan_tool,
        _tx.s('tools.pan'),
        enabled: !_locked,
        active: _panMode && !_locked,
        onTap: _togglePan,
      ),
      b(
        Icons.label,
        _tx.s('tools.labels'),
        enabled: true,
        active: _labelsVisible,
        onTap: _toggleLabels,
      ),
      b(
        Icons.center_focus_strong,
        _tx.s('tools.resetCam'),
        enabled: !_locked,
        onTap: _resetCamera,
      ),
    ];
    return Align(
      alignment: Alignment.topRight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.topRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var r = 0; r < 3; r++) ...[
              if (r > 0) const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  buttons[r * 2],
                  const SizedBox(width: 4),
                  buttons[r * 2 + 1],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Projected 3D anchors (rung targets + specimen tags) ---
  Widget _projectedLabels() {
    return ValueListenableBuilder<int>(
      valueListenable: _frameTick,
      builder: (context, _, _) {
        if (_viewSize.isEmpty) return const SizedBox.shrink();
        final pf = _camera.frame(_viewSize);
        final kids = <Widget>[];
        void place(Offset? p, Widget child) {
          if (p == null) return;
          kids.add(
            Positioned(
              key: child.key,
              left: p.dx,
              top: p.dy,
              child: FractionalTranslation(
                translation: const Offset(-0.5, -0.5),
                child: child,
              ),
            ),
          );
        }

        // HTML anchors: rung position + 0.85 (where a specimen lands).
        final anchors = [
          for (final r in _rungTargets) pf.project(r + _rt_V3(0, 0.85, 0)),
        ];
        // The full "Rung n: ..." cards only fit when the ladder is large
        // enough on screen; small phone canvases get compact rung badges.
        var fullLabels = !anchors.contains(null);
        for (var i = 0; fullLabels && i < anchors.length; i++) {
          for (var j = i + 1; j < anchors.length; j++) {
            final d = anchors[i]! - anchors[j]!;
            if (d.dx.abs() < 130 && d.dy.abs() < 21) {
              fullLabels = false;
              break;
            }
          }
        }

        // Specimen tags shrink to the bench spacing so they do not pile up.
        var spacing = double.infinity;
        Offset? prev;
        for (final x in _kSpecimenHomeX) {
          final p = pf.project(_rt_V3(x, -0.2, 3.5));
          if (p != null && prev != null) {
            spacing = math.min(spacing, (p.dx - prev.dx).abs());
          }
          prev = p;
        }
        final tagWidth = (spacing - 6).clamp(36.0, 130.0);
        for (var i = 0; i < 5; i++) {
          final name = _kSpecimens[i];
          final node = _specimenNodes[name];
          if (node == null) continue;
          // With compact badges a seated specimen is identified by the badge
          // in its tray button instead of a tag piled onto the ladder.
          if (!fullLabels && _s1[name]! > 0) continue;
          place(
            pf.project(node.position - _rt_V3(0, 0.65, 0)),
            _specimenLabel(i, tagWidth),
          );
        }
        for (var i = 0; i < 5; i++) {
          if (fullLabels) {
            place(anchors[i], _rungLabel(i));
          } else {
            place(
              pf.project(_rungTargets[i] + _rt_V3(-0.95, 0.15, 0)),
              _rungBadge(i),
            );
          }
        }
        return Stack(clipBehavior: Clip.none, children: kids);
      },
    );
  }

  Widget _rungLabel(int i) {
    final c = _kClassColors[i];
    return Container(
      key: ValueKey('rung-label-$i'),
      padding: const EdgeInsets.fromLTRB(7, 3, 3, 3),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withValues(alpha: 0.5)),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 6)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _tx.s('rung${i + 1}_label'),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: _tone(c),
            ),
          ),
          const SizedBox(width: 4),
          Material(
            color: c.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
            child: InkWell(
              borderRadius: BorderRadius.circular(6),
              onTap: () => _showPedestalInfo(i + 1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.help_outline, size: 10, color: _tone(c)),
                    const SizedBox(width: 2),
                    Text(
                      _tx.s('hint'),
                      style: TextStyle(
                        fontSize: 8.5,
                        fontWeight: FontWeight.w800,
                        color: _tone(c),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Compact rung target: circled number; tap opens the rung criteria.
  Widget _rungBadge(int i) {
    final c = _kClassColors[i];
    return Tooltip(
      key: ValueKey('rung-badge-$i'),
      message: _tx.s('rung${i + 1}_label'),
      child: Material(
        color: _glass,
        shape: CircleBorder(side: BorderSide(color: c, width: 1.5)),
        elevation: 2,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _showPedestalInfo(i + 1),
          child: SizedBox(
            width: 22,
            height: 22,
            child: Center(
              child: Text(
                _kRungCircled[i],
                style: TextStyle(
                  fontSize: 12,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  color: _tone(c),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _specimenLabel(int i, double maxWidth) {
    final c = _kClassColors[i];
    return ConstrainedBox(
      key: ValueKey('specimen-label-$i'),
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 96),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: _glass,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: c.withValues(alpha: 0.4)),
            boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 6)],
          ),
          child: Text(
            _tx.s(_kSpecimens[i]),
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(
              fontSize: 9,
              height: 1.2,
              fontWeight: FontWeight.w900,
              color: _tone(c),
            ),
          ),
        ),
      ),
    );
  }

  // --- Specimen feature callout ---
  Widget _calloutCard(String name) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 190),
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 8),
      decoration: _panelDecoration(
        border: _rt_Tw.cyan500.withValues(alpha: 0.4),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tx.s('callouts.$name.t').toUpperCase(),
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: _tone(_rt_Tw.cyan500),
                  ),
                ),
              ),
              InkResponse(
                radius: 14,
                onTap: () {
                  _rt_playSfx(_rt_Sfx.click);
                  setState(() => _callout = null);
                },
                child: Icon(Icons.close, size: 14, color: _rt_Lab.textMuted),
              ),
            ],
          ),
          _divider(top: 4, bottom: 4),
          Text(
            _tx.s('callouts.$name.b'),
            style: TextStyle(
              fontSize: 10,
              height: 1.4,
              fontWeight: FontWeight.w500,
              color: _rt_Lab.text,
            ),
          ),
        ],
      ),
    );
  }

  // --- Canvas action buttons (Hint, Reset, Verify) ---
  Widget _actions() {
    Widget btn(
      IconData icon,
      String label,
      VoidCallback onTap, {
      bool primary = false,
      Color? fg,
    }) {
      final color = primary ? _rt_Tw.slate950 : (fg ?? _rt_Lab.text);
      return SizedBox(
        width: 92,
        height: 30,
        child: Material(
          color: primary ? _rt_Tw.emerald500 : _glass,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: primary ? BorderSide.none : BorderSide(color: _rt_Lab.border),
          ),
          elevation: primary ? 4 : 1,
          shadowColor: primary ? _rt_Tw.emerald500 : null,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 15, color: color),
                  const SizedBox(width: 4),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        primary ? label.toUpperCase() : label,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: primary
                              ? FontWeight.w900
                              : FontWeight.w800,
                          letterSpacing: primary ? 0.6 : 0,
                          color: color,
                        ),
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

    return SizedBox(
      width: 92,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.bottomRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            btn(
              Icons.lightbulb,
              _tx.s('hint'),
              _showHint,
              fg: _tone(_rt_Tw.amber500),
            ),
            const SizedBox(height: 5),
            btn(
              Icons.replay,
              _tx.s('resetStep'),
              _resetStep,
              fg: _rt_Lab.textMuted,
            ),
            const SizedBox(height: 5),
            btn(
              Icons.check_circle,
              _tx.s('verifyStep'),
              _validate,
              primary: true,
            ),
          ],
        ),
      ),
    );
  }

  // --- Compact tool tray ---
  Widget _tray() {
    final placed = _s1.values.where((v) => v > 0).length;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: _panelDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.drag_indicator,
                size: 13,
                color: _tone(_rt_Tw.emerald500),
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  _tx.s('trayTitle').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: _tone(_rt_Tw.emerald500),
                  ),
                ),
              ),
              if (_scenario == 1)
                Text(
                  _f('itemsPlaced', {'n': '$placed'}),
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: 'monospace',
                    color: _rt_Lab.textMuted,
                  ),
                ),
            ],
          ),
          _divider(top: 5, bottom: 0),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 6),
              child: switch (_scenario) {
                1 => _s1Tray(),
                2 => _s2Tray(),
                3 => _s3Tray(),
                _ => _s4Tray(),
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Draggable token (GSAP Draggable). A short hold starts the drag so a
  /// quick swipe still scrolls the tray; a tap selects it for tap-to-place.
  Widget _dragToken({
    required String data,
    required Widget child,
    required Widget feedback,
  }) {
    return LongPressDraggable<String>(
      data: data,
      delay: const Duration(milliseconds: 150),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(scale: 1.06, child: feedback),
      ),
      childWhenDragging: Opacity(opacity: 0.35, child: child),
      onDragStarted: () => _rt_playSfx(_rt_Sfx.click),
      child: child,
    );
  }

  Widget _chip(
    String text, {
    required bool selected,
    double fontSize = 9.5,
    bool bold = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: selected ? _rt_Tw.emerald500.withValues(alpha: 0.2) : _tokenBg,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: selected ? _rt_Tw.emerald500 : _rt_Lab.borderStrong,
          width: selected ? 1.6 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: _rt_Tw.emerald500.withValues(alpha: 0.5),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          height: 1.25,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          color: _rt_Lab.text,
        ),
      ),
    );
  }

  Widget _s1Tray() {
    final label = _specimenPicked
        ? '${_tx.s(_activeSpecimen)}: ${_tx.s('placeOnRung')}'
        : _tx.s('placeOnRung');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            for (var i = 0; i < 5; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _specimenButton(i),
                ),
              ),
          ],
        ),
        const SizedBox(height: 5),
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: _zoneBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _rt_Lab.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  color: _rt_Lab.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  for (var r = 1; r <= 5; r++)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: _rungButton(r),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _specimenButton(int i) {
    final name = _kSpecimens[i];
    final c = _kClassColors[i];
    final selected = _specimenPicked && _activeSpecimen == name;
    final rung = _s1[name]!;
    return Material(
      color: selected ? _rt_Tw.emerald500.withValues(alpha: 0.2) : _tokenBg,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => _selectSpecimen(name),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? _rt_Tw.emerald500 : c.withValues(alpha: 0.45),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(_kClassIcons[i], size: 17, color: _tone(c)),
                  const SizedBox(height: 2),
                  Text(
                    _tx.s(name),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 8,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                      color: _rt_Lab.text,
                    ),
                  ),
                ],
              ),
              // Which rung this specimen currently sits on.
              if (rung > 0)
                Positioned(
                  top: -3,
                  right: 0,
                  child: Text(
                    _kRungCircled[rung - 1],
                    style: TextStyle(
                      fontSize: 10,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: _tone(_kClassColors[rung - 1]),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rungButton(int r) {
    final c = _kClassColors[r - 1];
    return Material(
      color: _tokenBg,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        splashColor: c.withValues(alpha: 0.35),
        highlightColor: c.withValues(alpha: 0.25),
        onTap: () => _assignSpecimenToRung(r),
        child: Container(
          height: 24,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _rt_Lab.borderStrong),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              _tx.s('rungBtns.${r - 1}'),
              maxLines: 1,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: _rt_Lab.text,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _s2Tray() {
    final traits = _tx.list('s2_traits');
    return Wrap(
      spacing: 5,
      runSpacing: 5,
      children: [
        for (final idx in _s2Order)
          if (idx < traits.length) _traitToken(traits[idx] as Map),
      ],
    );
  }

  Widget _traitToken(Map trait) {
    final id = trait['id'] as String;
    final text = trait['text'] as String;
    final chip = _chip(text, selected: _selTrait == id);
    return _dragToken(
      data: 'trait:$id',
      feedback: _chip(text, selected: true),
      child: GestureDetector(onTap: () => _selectTrait(id), child: chip),
    );
  }

  Widget _s3Tray() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final key in _kS3Slots) ...[
          _stripToken(key),
          const SizedBox(height: 5),
        ],
      ],
    );
  }

  Widget _stripToken(String key) {
    final text = _tx.s('s3_strips.$key');
    if (_s3.containsValue(key)) {
      // Used strips stay listed but dimmed and inert (HTML renderS3Tray).
      return Opacity(
        opacity: 0.45,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: _zoneBg,
            borderRadius: BorderRadius.circular(9),
            border: Border.all(color: _rt_Lab.border),
          ),
          child: Text(
            text,
            style: TextStyle(
              fontSize: 9,
              height: 1.25,
              color: _rt_Lab.textFaint,
            ),
          ),
        ),
      );
    }
    return _dragToken(
      data: 'strip:$key',
      feedback: SizedBox(
        width: 240,
        child: _chip(text, selected: true, fontSize: 9, bold: false),
      ),
      child: GestureDetector(
        onTap: () => _selectStrip(key),
        child: _chip(
          text,
          selected: _selStrip == key,
          fontSize: 9,
          bold: false,
        ),
      ),
    );
  }

  Widget _s4Tray() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        for (final id in _s4Order)
          _dragToken(
            data: 'item:$id',
            feedback: _chip(_itemText(id), selected: true, fontSize: 11),
            child: GestureDetector(
              onTap: () => _selectItem(id),
              child: _chip(
                _itemText(id),
                selected: _selItem == id,
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  // --- Generic drop zone (tap to place the selected token, or drop) ---
  Widget _dropZone({
    required String prefix,
    required void Function(String id) onDrop,
    required VoidCallback onTap,
    required Color color,
    required Widget child,
    Color okColor = _rt_Tw.emerald500,
    bool occupied = false,
    bool? verdict,
    double minHeight = 40,
    AlignmentGeometry alignment = Alignment.center,
  }) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => d.data.startsWith(prefix),
      onAcceptWithDetails: (d) => onDrop(d.data.substring(prefix.length)),
      builder: (context, candidates, _) {
        final hover = candidates.isNotEmpty;
        final Color edge = hover
            ? _rt_Tw.emerald500
            : verdict == true
            ? okColor
            : verdict == false
            ? _rt_Tw.rose500
            : color;
        final Color fill = hover
            ? _rt_Tw.emerald500.withValues(alpha: 0.3)
            : verdict == false
            ? _rt_Tw.rose500.withValues(alpha: 0.2)
            : occupied
            ? color.withValues(alpha: 0.16)
            : _zoneBg;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: AnimatedScale(
            scale: hover ? 1.03 : 1,
            duration: const Duration(milliseconds: 150),
            child: CustomPaint(
              foregroundPainter: _PlantaeZoneBorderPainter(
                color: edge,
                dashed: !occupied && !hover && verdict == null,
                width: verdict == null ? 1.6 : 2.2,
              ),
              child: Container(
                constraints: BoxConstraints(minHeight: minHeight),
                padding: const EdgeInsets.all(6),
                alignment: alignment,
                decoration: BoxDecoration(
                  color: fill,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------- scenario 2: trait matcher tree ---
  Widget _s2Board() {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final cols = w >= 620 ? 5 : (w >= 430 ? 3 : 2);
        final itemW = ((w - (cols - 1) * 8) / cols).floorToDouble();
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (var i = 0; i < 5; i++)
              SizedBox(width: itemW, child: _classColumn(i)),
          ],
        );
      },
    );
  }

  Widget _classColumn(int i) {
    final key = _kClassKeys[i];
    final c = _kClassColors[i];
    final items = _s2[key]!;
    return _panel(
      border: c.withValues(alpha: 0.45),
      padding: const EdgeInsets.all(7),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(_kClassIcons[i], size: 14, color: _tone(c)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _tx.s('classes.$key').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: _tone(c),
                  ),
                ),
              ),
            ],
          ),
          _divider(),
          _dropZone(
            prefix: 'trait:',
            onDrop: (id) => _assignTrait(id, key),
            onTap: () {
              final sel = _selTrait;
              if (sel != null) _assignTrait(sel, key);
            },
            color: c.withValues(alpha: 0.55),
            minHeight: 64,
            alignment: items.isEmpty ? Alignment.center : Alignment.topCenter,
            child: items.isEmpty
                ? Text(
                    _tx.s('dropTraitsHere'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: _rt_Lab.textFaint,
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (final id in items)
                        Container(
                          margin: const EdgeInsets.only(bottom: 4),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _tokenBg,
                            borderRadius: BorderRadius.circular(7),
                            border: Border.all(
                              color: _rt_Tw.emerald500.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            _traitText(id),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: _tone(_rt_Tw.emerald500),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------- scenario 3: Table 12.3 rebuild ---
  Widget _s3Board() {
    return _panel(
      border: _rt_Tw.emerald500.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _tx.s('s3_table_title').toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: _tone(_rt_Tw.emerald500),
            ),
          ),
          _divider(bottom: 0),
          for (var i = 0; i < 5; i++) _s3Row(i),
        ],
      ),
    );
  }

  Widget _s3Row(int i) {
    final key = _kClassKeys[i];
    final c = _kClassColors[i];
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: LayoutBuilder(
        builder: (context, box) {
          final name = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_kClassIcons[i], size: 15, color: _tone(c)),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  _tx.s('classes.$key'),
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: _tone(c),
                  ),
                ),
              ),
            ],
          );
          final adv = _s3Slot('${key}_adv', isAdvantage: true);
          final chal = _s3Slot('${key}_chal', isAdvantage: false);
          if (box.maxWidth >= 480) {
            return Row(
              children: [
                SizedBox(width: box.maxWidth * 0.22, child: name),
                const SizedBox(width: 6),
                Expanded(child: adv),
                const SizedBox(width: 6),
                Expanded(child: chal),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              name,
              const SizedBox(height: 5),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: adv),
                  const SizedBox(width: 6),
                  Expanded(child: chal),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _s3Slot(String slot, {required bool isAdvantage}) {
    final c = isAdvantage ? _rt_Tw.emerald500 : _rt_Tw.amber500;
    final key = _s3[slot];
    return _dropZone(
      prefix: 'strip:',
      onDrop: (k) => _placeStrip(k, slot),
      onTap: () => _quickAssignS3(slot),
      color: key == null ? c.withValues(alpha: 0.6) : c,
      occupied: key != null,
      verdict: _s3Verdict[slot],
      minHeight: 42,
      child: key == null
          ? Text(
              _tx.s(isAdvantage ? 'advSlotLabel' : 'chalSlotLabel'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: _rt_Lab.textFaint,
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    _tx.s('s3_strips.$key'),
                    style: TextStyle(
                      fontSize: 9,
                      height: 1.25,
                      fontWeight: FontWeight.w700,
                      color: _rt_Lab.text,
                    ),
                  ),
                ),
                const SizedBox(width: 2),
                _clearButton(() => _clearS3(slot)),
              ],
            ),
    );
  }

  // ------------------------------- scenario 4: microscope stem station ---
  Widget _s4Board() {
    return _panel(
      border: _rt_Tw.emerald500.withValues(alpha: 0.4),
      padding: const EdgeInsets.all(10),
      child: LayoutBuilder(
        builder: (context, c) {
          final cards = _s4Cards();
          if (c.maxWidth >= 520) {
            return Row(
              children: [
                _stemSection(170),
                const SizedBox(width: 12),
                Expanded(child: cards),
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: _stemSection(132)),
              const SizedBox(height: 10),
              cards,
            ],
          );
        },
      ),
    );
  }

  Widget _s4Cards() {
    final flowFg = _flowOn ? _rt_Tw.slate950 : _tone(_rt_Tw.emerald500);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.biotech, size: 16, color: _tone(_rt_Tw.emerald500)),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _tx.s('s4Title').toUpperCase(),
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: _tone(_rt_Tw.emerald500),
                ),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: _flowOn
                  ? _rt_Tw.emerald500
                  : _rt_Tw.emerald500.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: _toggleFlow,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.swap_vert, size: 13, color: flowFg),
                      const SizedBox(width: 3),
                      Text(
                        _tx.s('showFlow'),
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: flowFg,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        _divider(top: 6, bottom: 8),
        _vesselCard(1),
        const SizedBox(height: 8),
        _vesselCard(2),
      ],
    );
  }

  Widget _vesselCard(int n) {
    final c = n == 1 ? _rt_Tw.cyan500 : _rt_Tw.amber500;
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(Color.lerp(c, Colors.white, 0.92)!, c),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _tx.s('vessel${n}Title').toUpperCase(),
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: _tone(c),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _s4Slot('tissue$n', c, isTissue: true)),
              const SizedBox(width: 6),
              Expanded(child: _s4Slot('func$n', c, isTissue: false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _s4Slot(String slot, Color c, {required bool isTissue}) {
    final id = _s4[slot];
    return _dropZone(
      prefix: 'item:',
      onDrop: (i) => _placeItem(i, slot),
      onTap: () => _quickAssignS4(slot),
      color: c,
      okColor: c,
      occupied: id != null,
      verdict: _s4Verdict[slot],
      minHeight: 40,
      child: id == null
          ? Text(
              _tx.s(isTissue ? 'tissueSlotText' : 'funcSlotText'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.w800,
                color: _rt_Lab.textFaint,
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: Text(
                    _itemText(id),
                    style: isTissue
                        ? TextStyle(
                            fontSize: 11,
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w900,
                            color: _tone(c),
                          )
                        : TextStyle(
                            fontSize: 9,
                            height: 1.25,
                            fontWeight: FontWeight.w800,
                            color: _tone(c),
                          ),
                  ),
                ),
                _clearButton(() => _clearS4(slot)),
              ],
            ),
    );
  }

  /// Fern stem cross-section: cortex, phloem ring, pulsing xylem core and
  /// the bouncing transport arrow shown while "Show Flow" is active.
  Widget _stemSection(double s) {
    Widget pill(String text, Color bg) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text.toUpperCase(),
        maxLines: 1,
        style: const TextStyle(
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.4,
          color: _rt_Tw.slate950,
        ),
      ),
    );
    return ValueListenableBuilder<int>(
      valueListenable: _frameTick,
      builder: (context, _, _) {
        // pulse-ring: 2 s ease-in-out loop; animate-bounce: 1 s loop.
        final pulse = 0.5 - 0.5 * math.cos((_time % 2.0) / 2.0 * 2 * math.pi);
        final bounce = math.sin((_time % 1.0) * math.pi);
        final core = s * 0.39;
        return SizedBox(
          width: s,
          height: s,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: s,
                height: s,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _dark ? _rt_Tw.slate950 : _rt_Tw.slate50,
                  border: Border.all(
                    color: _dark ? _rt_Tw.slate700 : _rt_Tw.slate300,
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _rt_Tw.emerald500.withValues(alpha: 0.2),
                      blurRadius: 30,
                    ),
                  ],
                ),
              ),
              Container(
                width: s * 0.92,
                height: s * 0.92,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _dark ? const Color(0x99022C22) : _rt_Tw.emerald50,
                  border: Border.all(
                    color: _rt_Tw.emerald500.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
              ),
              Container(
                width: s * 0.72,
                height: s * 0.72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: _rt_Tw.amber500.withValues(alpha: 0.7),
                    width: 3.5,
                  ),
                ),
              ),
              Positioned(
                top: s * 0.14 - 7,
                left: 0,
                right: 0,
                child: Center(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: pill(_tx.s('phloemZoneText'), _rt_Tw.amber500),
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.98 + 0.04 * pulse,
                child: Opacity(
                  opacity: 0.8 + 0.2 * pulse,
                  child: Container(
                    width: core,
                    height: core,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0x66083344),
                      border: Border.all(color: _rt_Tw.cyan400, width: 3.5),
                      boxShadow: [
                        BoxShadow(
                          color: _rt_Tw.sky400.withValues(alpha: 0.8 * pulse),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: pill(_tx.s('xylemCoreText'), _rt_Tw.cyan400),
                      ),
                    ),
                  ),
                ),
              ),
              if (_flowOn)
                Transform.translate(
                  offset: Offset(0, -core * 0.3 - 6 * bounce),
                  child: const Icon(
                    Icons.arrow_upward,
                    size: 18,
                    color: _rt_Tw.cyan400,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  // ------------------------------------------- scientific conclusion ---
  Widget _conclusionBody() {
    Widget section(IconData icon, Color c, String head, String body) =>
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _rt_Lab.tinted(Color.lerp(c, Colors.white, 0.92)!, c),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 15, color: _tone(c)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      head,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: _tone(c),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                body,
                style: TextStyle(
                  fontSize: 11.5,
                  height: 1.45,
                  color: _rt_Lab.textMuted,
                ),
              ),
            ],
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        section(
          Icons.account_tree,
          _rt_Tw.emerald500,
          _tx.s('concHead1'),
          _tx.s('concBody1'),
        ),
        section(
          Icons.water_drop,
          _rt_Tw.cyan500,
          _tx.s('concHead2'),
          _tx.s('concBody2'),
        ),
        section(
          Icons.local_florist,
          _rt_Tw.amber500,
          _tx.s('concHead3'),
          _tx.s('concBody3'),
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _rt_Lab.overlay,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _rt_Lab.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _tx.s('evalMetrics').toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: _rt_Lab.text,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 6,
                children: [
                  for (var m = 1; m <= 4; m++)
                    SizedBox(
                      width: 200,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${_tx.s('metric$m')} ',
                              style: TextStyle(color: _rt_Lab.textMuted),
                            ),
                            TextSpan(
                              text: '10/10',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: _tone(_rt_Tw.emerald500),
                              ),
                            ),
                          ],
                        ),
                        style: const TextStyle(fontSize: 11.5),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Rounded drop-zone outline: dashed while empty (`border-dashed`), solid
/// once occupied or verified.
class _PlantaeZoneBorderPainter extends CustomPainter {
  _PlantaeZoneBorderPainter({
    required this.color,
    required this.dashed,
    required this.width,
  });

  final Color color;
  final bool dashed;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(width / 2);
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(10)));
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;
    if (!dashed) {
      canvas.drawPath(path, paint);
      return;
    }
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + 5, metric.length)),
          paint,
        );
        d += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PlantaeZoneBorderPainter old) =>
      old.color != color || old.dashed != dashed || old.width != width;
}
