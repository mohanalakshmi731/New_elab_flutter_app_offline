// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Archimedes' Buoyancy Lab
// Converted from Cl9S-Ch9-A5-Archimedes__Buoyancy_Lab.html (three.js -> mini3d).




// --- 1. DATA & LOCALIZATION (LAB_TEXT) ---

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
    'intro': {'title': "Archimedes' Buoyancy _rt_Lab", 'subtitle': 'Class 9 • Gravitation', 'button': 'Enter _rt_Lab'},
    'title': "Archimedes' _rt_Lab",
    'subtitle': 'Class 9 • Gravitation',
    'tabs': {'why': 'Why Learn?', 'explore': 'Explore', 'outcomes': 'Outcomes'},
    'lbl_inst': 'INSTRUCTION',
    'lbl_obs': 'OBSERVATION',
    'ui_protocol': 'PROTOCOL',
    'ui_data': 'DATA',
    'ui_object': 'Object',
    'ui_force_g': 'Force (G)',
    'ui_force_b': 'Force (B)',
    'ui_net_force': 'Net Force',
    'ui_ready': 'READY',
    'btn_analyze': 'ANALYZE',
    'lbl_less_dense': 'Density < Water',
    'lbl_more_dense': 'Density > Water',
    'msg_next_phase': 'Analysis Complete. Now try the Bottle Experiment.',
    'lbl_balance': 'Balance',
    'btn_lower_balance': 'LOWER BALANCE',
    'ui_calc_loss': 'Calculate Loss',
    'ui_calc_hint': 'W(air) − W(water) = ?',
    'btn_check': 'CHECK',
    'msg_try_again': 'Incorrect. Try 5 - 3',
    'lbl_scale': 'Digital Scale',
    'btn_reshape': 'RESHAPE',
    'msg_success': 'SUCCESS',
    'msg_hull_float': 'The Hull displaces more water -> Higher Buoyancy -> It Floats!',
    'msg_force_detected': 'Force Detected! Now RELEASE it!',
    'lbl_action': 'ACTION',
    'lbl_setup_complete': 'SETUP COMPLETE',
    'lbl_measurement': 'MEASUREMENT',
    'lbl_error': 'ERROR',
    'lbl_force': 'FORCE',
    'lbl_upthrust': 'UPTHRUST',
    'welcome': 'Welcome to the _rt_Lab',
    'ui_discovery': 'Discovery Complete!',
    'conclusion': [
      {
        'icon': 'scale',
        'b': 'Weight Loss:',
        't': 'The stone weighed 5N in air but only 3N in water. Apparent loss = 2N.',
      },
      {'icon': 'drip', 'b': 'Displacement:', 't': 'The water displaced into the beaker weighs exactly 2N.'},
      {
        'icon': 'check',
        'b': "Archimedes' Principle Verified:",
        't': 'Buoyant Force (2N) = Weight of Displaced Fluid (2N).',
      },
      {
        'icon': 'ship',
        'b': 'Application:',
        't': 'Reshaping iron into a hull increases volume, displacing more water, allowing it to float!',
      },
    ],
    'btn_restart': 'Restart _rt_Lab',
    'labels': {
      'tank': 'Water Tank',
      'nail': 'Iron Nail',
      'cork': 'Cork',
      'bench': 'Bench',
      'bottle': 'Water Bottle',
      'overflow': 'Overflow Can',
      'balance': 'Spring Balance',
      'stone': 'Stone',
      'beaker': 'Beaker',
      'scale': 'Digital Scale',
      'block': 'Iron Block',
      'hull': 'Iron Hull',
    },
    'tools': {'lock': 'Unlock Camera', 'unlock': 'Lock Camera', 'labels': 'Toggle Labels'},
    'why_title': 'Why Learn This?',
    'why': [
      {
        'e': '🚢',
        'title': 'Steel Ships',
        'desc':
            "How can a massive steel ship float while a tiny steel nail sinks? It's all about density and displacement.",
      },
      {
        'e': '🛥️',
        'title': 'Submarines',
        'desc': 'Submarines use ballast tanks to change their density, allowing them to dive deep or surface at will.',
      },
      {
        'e': '🎈',
        'title': 'Hot Air Balloons',
        'desc': "Archimedes' principle applies to air too! Hot air is less dense than cool air, creating lift.",
      },
    ],
    'outcomes_title': 'Learning Outcomes',
    'outcomes_intro': 'By completing this lab, you have achieved the following:',
    'outcomes': [
      {
        'title': 'Understanding Density',
        'desc':
            'You learnt that density determines whether an object sinks or floats. Specifically, if an object is denser than the fluid (like the Iron Nail > Water), it will sink.',
      },
      {
        'title': 'Gravity vs. Buoyancy',
        'desc':
            'You observed that for heavy objects, the downward pull of Gravity (Fg) is stronger than the upward Buoyant Force (Fb), causing net downward acceleration.',
      },
      {
        'title': 'Practical Observation',
        'desc':
            'You successfully set up a lab environment and experimentally verified the sinking behavior of iron in water, reinforcing theoretical concepts with visual proof.',
      },
    ],
    'workflow': [
      {
        'title': '_rt_Lab Preparation',
        'desc':
            'Action: Drag the Water Tank, Iron Nail, and Cork from the side shelf to the beige bench. Result: Objects ready for testing.',
        'obs': 'The workspace is set. We can now test material properties.',
        'btn': 'Setup _rt_Lab',
      },
      {
        'title': 'The Sinking Test',
        'desc':
            'Action: Drag the Iron Nail over the water surface and release it. Result: The nail sinks to the bottom.',
        'obs': 'Iron is denser than water (7.8 > 1.0), so Gravity > Buoyancy.',
        'btn': 'Test Nail',
      },
      {
        'title': 'The Floating Test',
        'desc': 'Action: Drag the Cork onto the water surface and release it. Result: The cork floats and bobs gently.',
        'obs': 'Cork is less dense than water (0.2 < 1.0), so Buoyancy balances Gravity.',
        'btn': 'Test Cork',
      },
      {
        'title': 'Density Analysis',
        'desc': 'Action: Click ANALYZE to compare the objects. Result: Visual density comparison.',
        'obs': 'Sinking vs. Floating is determined by density relative to the fluid.',
        'btn': 'Analyze',
      },
      {
        'title': 'Feel the Force',
        'desc': 'Action: Drag the Empty Bottle deep underwater and HOLD it there. Result: The red Force Meter rises.',
        'obs': 'You feel the Upthrust! The deeper you go, the harder the water pushes back.',
        'btn': 'Feel Force',
      },
      {
        'title': 'The Release',
        'desc': 'Action: Release the mouse button. Result: The bottle shoots upwards rapidly.',
        'obs': 'Potential energy converts to kinetic energy. The strong buoyant force accelerates the bottle.',
        'btn': 'Release',
      },
      {
        'title': 'Archimedes Setup',
        'desc': 'Action: Drag Overflow Can, Balance, Stone, and Beaker to the bench. Result: Quantitative rig ready.',
        'obs': 'We are now ready to measure the exact value of the Buoyant Force.',
        'btn': 'Setup Rig',
      },
      {
        'title': 'Weight in Air',
        'desc': 'Action: Drag the Stone to the Spring Balance hook. Result: Reading is 5.0 N.',
        'obs': 'This is the real weight (W(air)) of the stone.',
        'btn': 'Weigh Air',
      },
      {
        'title': 'Displacement',
        'desc': "Action: Click 'LOWER BALANCE' to submerge the stone. Result: Reading drops to 3.0 N. Water overflows.",
        'obs': 'Weight lost = 2N. This lost weight appears as displaced water in the beaker!',
        'btn': 'Submerge',
      },
      {
        'title': 'Analysis',
        'desc': 'Action: Calculate W(air) − W(water). Result: Archimedes Principle confirmed.',
        'obs': 'Loss in Weight (2N) = Weight of Displaced Fluid (2N).',
        'btn': 'Check',
      },
      {
        'title': 'Verification',
        'desc': 'Action: Drag the Beaker with water to the Digital Scale.',
        'obs': 'Scale reads 2.0N. The Upthrust (2N) equals the Weight of Displaced Water (2N).',
        'btn': 'Verify',
      },
      {
        'title': 'Iron Ship',
        'desc': 'Action: Drag Iron Block to water (Sinks). Then click ACTION to Reshape.',
        'obs': 'Reshaping to a hull increases volume -> increases displacement -> It floats!',
        'btn': 'Ship',
      },
    ],
  },
  'hi': {
    'intro': {
      'title': 'आर्किमिडीज उत्प्लावकता लैब',
      'subtitle': 'कक्षा 9 • गुरुत्वाकर्षण',
      'button': 'लैब में प्रवेश करें',
    },
    'title': 'आर्किमिडीज लैब',
    'subtitle': 'कक्षा 9 • गुरुत्वाकर्षण',
    'tabs': {'why': 'क्यों सीखें?', 'explore': 'प्रयोगशाला', 'outcomes': 'परिणाम'},
    'lbl_inst': 'निर्देश',
    'lbl_obs': 'अवलोकन',
    'ui_protocol': 'प्रोटोकॉल',
    'ui_data': 'डेटा',
    'ui_object': 'वस्तु',
    'ui_force_g': 'बल (G)',
    'ui_force_b': 'बल (B)',
    'ui_net_force': 'कुल बल',
    'ui_ready': 'तैयार',
    'btn_analyze': 'विश्लेषण करें',
    'lbl_less_dense': 'घनत्व < पानी',
    'lbl_more_dense': 'घनत्व > पानी',
    'msg_next_phase': 'विश्लेषण पूर्ण। अब बोतल प्रयोग का प्रयास करें।',
    'lbl_balance': 'बैलेंस',
    'btn_lower_balance': 'बैलेंस नीचे करें',
    'ui_calc_loss': 'हानि की गणना करें',
    'ui_calc_hint': 'W(हवा) − W(पानी) = ?',
    'btn_check': 'जांचें',
    'msg_try_again': 'गलत। 5 - 3 का प्रयास करें',
    'lbl_scale': 'डिजिटल तराजू',
    'btn_reshape': 'आकार बदलें',
    'msg_success': 'सफल',
    'msg_hull_float': 'जहाज का ढांचा अधिक पानी विस्थापित करता है -> उच्च उत्प्लावकता -> यह तैरता है!',
    'msg_force_detected': 'बल का पता चला! अब इसे छोड़ें!',
    'lbl_action': 'कार्रवाई',
    'lbl_setup_complete': 'सेटअप पूर्ण',
    'lbl_measurement': 'मापन',
    'lbl_error': 'त्रुटि',
    'lbl_force': 'बल',
    'lbl_upthrust': 'उत्प्लावन',
    'welcome': 'लैब में आपका स्वागत है',
    'ui_discovery': 'खोज पूर्ण!',
    'conclusion': [
      {
        'icon': 'scale',
        'b': 'वजन कम होना:',
        't': 'हवा में पत्थर का वजन 5N था लेकिन पानी में केवल 3N। आभासी हानि = 2N।',
      },
      {'icon': 'drip', 'b': 'विस्थापन:', 't': 'बीकर में विस्थापित पानी का वजन ठीक 2N है।'},
      {
        'icon': 'check',
        'b': 'आर्किमिडीज का सिद्धांत सत्यापित:',
        't': 'उत्प्लावक बल (2N) = विस्थापित द्रव का वजन (2N)।',
      },
      {
        'icon': 'ship',
        'b': 'अनुप्रयोग:',
        't': 'लोहे को जहाज के ढांचे में बदलने से आयतन बढ़ता है, अधिक पानी विस्थापित होता है, जिससे यह तैरता है!',
      },
    ],
    'btn_restart': 'लैब पुनरारंभ करें',
    'labels': {
      'tank': 'पानी की टंकी',
      'nail': 'लोहे की कील',
      'cork': 'कॉर्क',
      'bench': 'बेंच',
      'bottle': 'खाली बोतल',
      'overflow': 'ओवरफ्लो कैन',
      'balance': 'स्प्रिंग बैलेंस',
      'stone': 'पत्थर',
      'beaker': 'बीकर',
      'scale': 'डिजिटल तराजू',
      'block': 'लोहे का ब्लॉक',
      'hull': 'जहाज का ढांचा',
    },
    'tools': {'lock': 'कैमरा अनलॉक करें', 'unlock': 'कैमरा लॉक करें', 'labels': 'लेबल दिखाएँ/छिपाएँ'},
    'why_title': 'यह क्यों सीखें?',
    'why': [
      {
        'e': '🚢',
        'title': 'स्टील के जहाज',
        'desc':
            'एक विशाल स्टील का जहाज कैसे तैरता है जबकि एक छोटी स्टील की कील डूब जाती है? यह सब घनत्व और विस्थापन के बारे में है।',
      },
      {
        'e': '🛥️',
        'title': 'पनडुब्बियां',
        'desc':
            'पनडुब्बियां अपने घनत्व को बदलने के लिए गिट्टी टैंकों का उपयोग करती हैं, जिससे वे गहराई में गोता लगा सकती हैं या सतह पर आ सकती हैं।',
      },
      {
        'e': '🎈',
        'title': 'हॉट एयर बैलून',
        'desc':
            'आर्किमिडीज का सिद्धांत हवा पर भी लागू होता है! गर्म हवा ठंडी हवा की तुलना में कम घनी होती है, जिससे लिफ्ट पैदा होती है।',
      },
    ],
    'outcomes_title': 'सीखने के परिणाम',
    'outcomes_intro': 'इस प्रयोगशाला को पूरा करके, आपने निम्नलिखित हासिल किया है:',
    'outcomes': [
      {
        'title': 'घनत्व को समझना',
        'desc':
            'आपने सीखा कि घनत्व यह निर्धारित करता है कि कोई वस्तु डूबती है या तैरती है। विशेष रूप से, यदि कोई वस्तु द्रव से अधिक घनी है (जैसे लोहे की कील > पानी), तो वह डूब जाएगी।',
      },
      {
        'title': 'गुरुत्वाकर्षण बनाम उत्प्लावकता',
        'desc':
            'आपने देखा कि भारी वस्तुओं के लिए, गुरुत्वाकर्षण का नीचे की ओर खिंचाव (Fg) ऊपर की ओर उत्प्लावक बल (Fb) से अधिक मजबूत होता है, जिससे नीचे की ओर त्वरण होता है।',
      },
      {
        'title': 'व्यावहारिक अवलोकन',
        'desc':
            'आपने सफलतापूर्वक एक प्रयोगशाला वातावरण स्थापित किया और प्रयोगात्मक रूप से पानी में लोहे के डूबने के व्यवहार को सत्यापित किया, जिससे दृश्य प्रमाण के साथ सैद्धांतिक अवधारणाओं को बल मिला।',
      },
    ],
    'workflow': [
      {
        'title': 'लैब की तैयारी',
        'desc':
            'कार्य: पानी की टंकी, लोहे की कील और कॉर्क को किनारे से बेज बेंच पर खींचें। परिणाम: वस्तुएं परीक्षण के लिए तैयार।',
        'obs': 'कार्यस्थल तैयार है। अब हम पदार्थों के गुणों का परीक्षण कर सकते हैं।',
        'btn': 'लैब सेटअप',
      },
      {
        'title': 'डूबने का परीक्षण',
        'desc': 'कार्य: लोहे की कील को पानी की सतह के ऊपर खींचें और छोड़ दें। परिणाम: कील तली में डूब जाती है।',
        'obs': 'लोहा पानी से अधिक घना है (7.8 > 1.0), इसलिए गुरुत्वाकर्षण > उत्प्लावकता।',
        'btn': 'कील का परीक्षण',
      },
      {
        'title': 'तैरने का परीक्षण',
        'desc':
            'कार्य: कॉर्क को पानी की सतह पर खींचें और छोड़ दें। परिणाम: कॉर्क तैरता है और धीरे-धीरे ऊपर-नीचे होता है।',
        'obs': 'कॉर्क पानी से कम घना है (0.2 < 1.0), इसलिए उत्प्लावकता गुरुत्वाकर्षण को संतुलित करती है।',
        'btn': 'कॉर्क का परीक्षण',
      },
      {
        'title': 'घनत्व विश्लेषण',
        'desc': 'कार्य: वस्तुओं की तुलना के लिए "विश्लेषण करें" पर क्लिक करें। परिणाम: घनत्व की दृश्य तुलना।',
        'obs': 'डूबना या तैरना द्रव की तुलना में घनत्व से निर्धारित होता है।',
        'btn': 'विश्लेषण',
      },
      {
        'title': 'बल महसूस करें',
        'desc': 'कार्य: खाली बोतल को पानी में गहराई तक खींचें और वहीं पकड़े रखें। परिणाम: लाल बल मीटर ऊपर उठता है।',
        'obs': 'आप उत्प्लावन बल महसूस करते हैं! जितना गहरा, पानी उतना ही अधिक पीछे धकेलता है।',
        'btn': 'बल महसूस करें',
      },
      {
        'title': 'रिहाई',
        'desc': 'कार्य: बोतल को छोड़ दें। परिणाम: बोतल तेजी से ऊपर की ओर उछलती है।',
        'obs': 'स्थितिज ऊर्जा गतिज ऊर्जा में बदलती है। प्रबल उत्प्लावक बल बोतल को त्वरित करता है।',
        'btn': 'रिहाई',
      },
      {
        'title': 'आर्किमिडीज सेटअप',
        'desc': 'कार्य: ओवरफ्लो कैन, स्प्रिंग बैलेंस, पत्थर और बीकर को बेंच पर खींचें। परिणाम: मापन उपकरण तैयार।',
        'obs': 'अब हम उत्प्लावक बल का सटीक मान मापने के लिए तैयार हैं।',
        'btn': 'सेटअप',
      },
      {
        'title': 'हवा में वजन',
        'desc': 'कार्य: पत्थर को स्प्रिंग बैलेंस के हुक पर खींचें। परिणाम: पाठ्यांक 5.0 N है।',
        'obs': 'यह पत्थर का वास्तविक वजन (W(हवा)) है।',
        'btn': 'वजन (हवा)',
      },
      {
        'title': 'विस्थापन',
        'desc':
            "कार्य: पत्थर को डुबोने के लिए 'बैलेंस नीचे करें' पर क्लिक करें। परिणाम: पाठ्यांक घटकर 3.0 N हो जाता है। पानी बाहर बहता है।",
        'obs': 'वजन में कमी = 2N। यह कमी बीकर में विस्थापित पानी के रूप में दिखाई देती है!',
        'btn': 'डुबोएँ',
      },
      {
        'title': 'विश्लेषण',
        'desc': 'कार्य: W(हवा) − W(पानी) की गणना करें। परिणाम: आर्किमिडीज का सिद्धांत पुष्ट।',
        'obs': 'वजन में हानि (2N) = विस्थापित द्रव का वजन (2N)।',
        'btn': 'जांचें',
      },
      {
        'title': 'सत्यापन',
        'desc': 'कार्य: पानी वाले बीकर को डिजिटल तराजू पर खींचें।',
        'obs': 'तराजू 2.0N दिखाता है। उत्प्लावन बल (2N) विस्थापित पानी के वजन (2N) के बराबर है।',
        'btn': 'सत्यापन',
      },
      {
        'title': 'लोहे का जहाज',
        'desc': 'कार्य: लोहे के ब्लॉक को पानी में खींचें (डूबता है)। फिर आकार बदलने के लिए ACTION पर क्लिक करें।',
        'obs': 'ढांचे का आकार आयतन बढ़ाता है -> विस्थापन बढ़ता है -> यह तैरता है!',
        'btn': 'जहाज',
      },
    ],
  },
});

const _brandTeal = Color(0xFF0D9488);
const _brandWarn = Color(0xFFF59E0B);
const _waterLevel = 12.0;

class Cl9Ch09A5ArchimedesBuoyancyLabPage extends StatefulWidget {
  const Cl9Ch09A5ArchimedesBuoyancyLabPage({super.key});

  @override
  State<Cl9Ch09A5ArchimedesBuoyancyLabPage> createState() => _Cl9Ch09A5ArchimedesBuoyancyLabPageState();
}

class _Cl9Ch09A5ArchimedesBuoyancyLabPageState extends State<Cl9Ch09A5ArchimedesBuoyancyLabPage> {
  // --- 3D SCENE SETUP ---
  final _rt_Scene3D _scene = _rt_Scene3D(backgroundGradient: const [Color(0xFF1E293B), Color(0xFF020617)]);
  final _rt_Camera3D _camera = _rt_Camera3D(fov: 45, position: _rt_V3(0, 25, 45), target: _rt_V3(0, 5, 0));
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner();
  final _rt_ShellController _shell = _rt_ShellController();
  final math.Random _rng = math.Random();

  // Scene objects (by HTML id).
  final Map<String, _rt_Node3D> _obj = {};
  final Map<String, _rt_Label3D> _labels = {};
  late _rt_Mesh3D _beakerWater;
  late _rt_Mesh3D _waterStream;

  bool _labelsVisible = true;
  bool _isLocked = true;
  int _gen = 0;

  // --- 4. ACTIVITY LOGIC (act) ---
  int _step = 1;
  bool _simulating = false;
  double _velocity = 0;
  int _holdTimer = 0;
  double _corkTime = 0;
  bool _splashed = false;
  double _step6Time = 0;
  bool _stoneAttached = false;
  bool _beakerOnScale = false;
  bool _blockDropped = false;
  bool _assistHold = false;
  bool _started = false;

  // Drag state
  _rt_Node3D? _selected;
  _rt_V3 _planePoint = _rt_V3();
  _rt_V3 _planeNormal = _rt_V3(0, 1, 0);
  _rt_V3 _dragOffset = _rt_V3();

  // UI state
  bool _analyzeVisible = false;
  String? _actionBtn; // 'lower' | 'reshape'
  bool _calcVisible = false;
  bool _forceMeterVisible = false;
  double _forcePct = 0;
  final TextEditingController _calcInput = TextEditingController();
  String Function() _hudTitle = () => _tx.s('lbl_inst');
  String Function() _hudMsg = () => _tx.s('welcome');
  bool _hudShown = false;
  String? _dataObjKey;
  double? _g, _b, _n;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _applyLock();
    _init3D();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gen++;
    _tweens.cancelAll();
    _viewCtrl.dispose();
    _calcInput.dispose();
    super.dispose();
  }

  void _later(int ms, VoidCallback fn) {
    final g = _gen;
    Future.delayed(Duration(milliseconds: ms), () {
      if (!mounted || g != _gen) return;
      fn();
    });
  }

  void _applyLock() {
    _camera.enableRotate = !_isLocked;
    _camera.enablePan = !_isLocked;
  }

  // ------------------------------------------------------------ materials ---
  _rt_Material3D get _water => _rt_Material3D(color: const Color(0xFF0EA5E9), opacity: 0.7, shininess: 0.6);
  _rt_Material3D get _glass => _rt_Material3D(color: const Color(0xFFA5F3FC), opacity: 0.3, doubleSided: true, shininess: 0.5);
  _rt_Material3D get _stoneMat => _rt_Material3D(color: const Color(0xFF78716C));
  _rt_Material3D get _iron => _rt_Material3D(color: const Color(0xFF94A3B8), metalness: 0.8, shininess: 0.5);
  _rt_Material3D get _corkMat => _rt_Material3D(color: const Color(0xFFD2A679));
  _rt_Material3D get _wood => _rt_Material3D(color: const Color(0xFF5C4033));
  _rt_Material3D get _metal => _rt_Material3D(color: const Color(0xFFCBD5E1), metalness: 0.8, shininess: 0.7);

  /// Invisible but pickable hit box (the HTML `MeshBasicMaterial({visible:false})` boxes).
  _rt_Mesh3D _hitBox(double w, double h, double d) =>
      _rt_Mesh3D(_rt_Geometry3D.box(w, h, d), _rt_Material3D(opacity: 0, doubleSided: true))..depthBias = 1000;

  _rt_Node3D _mk(String id, _rt_V3 start, _rt_V3? target) {
    final n = _rt_Node3D(name: id);
    n.userData = {'id': id, 'startPos': start, 'targetPos': target, 'onBench': false};
    n.position.copy(start);
    return n;
  }

  void _init3D() {
    _scene.setLights([_rt_Light3D.ambient(intensity: 0.8), _rt_Light3D.directional(_rt_V3(20, 50, 20), intensity: 1.2)]);
    _createBench();
    _createObjects();
    _syncLabels();
  }

  void _createBench() {
    final bench = _rt_Node3D(name: 'bench');
    bench.add(_rt_Mesh3D(_rt_Geometry3D.box(30, 1, 15), _wood)..position.y = 5);
    final legGeo = _rt_Geometry3D.cylinder(0.5, 0.5, 5, segments: 10);
    for (final p in [(-14.0, -6.5), (14.0, -6.5), (-14.0, 6.5), (14.0, 6.5)]) {
      bench.add(_rt_Mesh3D(legGeo, _wood)..position.set(p.$1, 2.5, p.$2));
    }
    bench.traverse((n) => n.pickable = false);
    _scene.add(bench);
    _obj['bench'] = bench;
    _createLabel('bench');
  }

  void _createObjects() {
    // 1. Water Tank
    final tank = _mk('tank', _rt_V3(-10, 5, 14), _rt_V3(0, 10.5, 0));
    tank.add(_rt_Mesh3D(_rt_Geometry3D.box(12, 10, 8), _glass));
    tank.add(_rt_Mesh3D(_rt_Geometry3D.box(11.6, 7, 7.6), _water)..position.y = -1.4);
    _scene.add(tank);
    _obj['tank'] = tank;
    _createLabel('tank');

    // 2. Iron Nail
    final nail = _mk('nail', _rt_V3(-4, 0.5, 14), _rt_V3(8, 6.0, 2));
    nail.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.15, 0.15, 3, segments: 12), _iron)..rotation.x = math.pi / 2);
    nail.add(
      _rt_Mesh3D(_rt_Geometry3D.cylinder(0.5, 0.5, 0.1, segments: 16), _iron)
        ..rotation.x = math.pi / 2
        ..position.z = -1.5,
    );
    nail.add(
      _rt_Mesh3D(_rt_Geometry3D.cone(0.15, 0.5, segments: 12), _iron)
        ..rotation.x = -math.pi / 2
        ..position.z = 1.75,
    );
    nail.add(_hitBox(4, 4, 6));
    _scene.add(nail);
    _obj['nail'] = nail;
    _createLabel('nail');

    // 3. Cork
    final cork = _mk('cork', _rt_V3(4, 1, 14), _rt_V3(8, 6.5, -2));
    cork.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(1.2, 0.9, 2, segments: 24), _corkMat));
    cork.add(_hitBox(5, 5, 5));
    _scene.add(cork);
    _obj['cork'] = cork;
    _createLabel('cork');

    // 4. Bottle
    final bottle = _mk('bottle', _rt_V3(10, 2.5, 14), _rt_V3(-10, 8, 0));
    final plastic = _rt_Material3D(color: const Color(0xFF60A5FA), opacity: 0.9, shininess: 0.8);
    bottle.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(1.4, 1.4, 4.5, segments: 24), plastic)..position.y = 2.25);
    for (var i = 0; i < 4; i++) {
      bottle.add(
        _rt_Mesh3D(_rt_Geometry3D.torus(1.35, 0.1, radialSegments: 6, tubularSegments: 24), plastic)
          ..rotation.x = math.pi / 2
          ..position.y = 0.8 + i * 0.9,
      );
    }
    bottle.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.6, 1.4, 1.5, segments: 24), plastic)..position.y = 5.25);
    bottle.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.6, 0.6, 0.5, segments: 16), plastic)..position.y = 6.25);
    bottle.add(
      _rt_Mesh3D(_rt_Geometry3D.cylinder(0.65, 0.65, 0.6, segments: 16), _rt_Material3D(color: const Color(0xFF2563EB)))
        ..position.y = 6.6,
    );
    bottle.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(1.42, 1.42, 1.8, segments: 24, openEnded: true, thetaLength: 3.5),
          _rt_Material3D(color: Colors.white, unlit: true),
        )
        ..position.y = 3.5
        ..rotation.y = -1.5,
    );
    bottle.add(
      _rt_Mesh3D(
          _rt_Geometry3D.sphere(0.4, widthSegments: 10, heightSegments: 8),
          _rt_Material3D(color: const Color(0xFF2563EB), unlit: true),
        )
        ..scale.set(0.6, 1, 0.2)
        ..position.set(0, 3.5, 1.45),
    );
    bottle.add(_hitBox(5, 10, 5));
    _scene.add(bottle);
    _obj['bottle'] = bottle;
    _createLabel('bottle');

    // --- STEP 7 OBJECTS ---
    // 5. Overflow Can
    final can = _mk('overflow', _rt_V3(-14, 3, 16), _rt_V3(-4, 5.5, 0));
    can.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(3, 3, 6, segments: 24, openEnded: true), _glass)..position.y = 3);
    can.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(3, 3, 0.2, segments: 24), _glass)..position.y = 0.1);
    can.add(
      _rt_Mesh3D(_rt_Geometry3D.cylinder(0.3, 0.3, 2.5, segments: 12), _glass)
        ..position.set(2.5, 5, 0)
        ..rotation.z = -math.pi / 3,
    );
    can.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(2.9, 2.9, 5.0, segments: 24), _water)..position.y = 2.6);
    can.add(_hitBox(8, 8, 8)..position.y = 3);
    can.visible = false;
    _scene.add(can);
    _obj['overflow'] = can;
    _createLabel('overflow');

    // 6. Spring Balance
    final balance = _mk('balance', _rt_V3(-8, 3, 16), _rt_V3(-4, 18, 0));
    balance.add(_rt_Mesh3D(_rt_Geometry3D.box(2, 6, 1), _rt_Material3D(color: const Color(0xFFF59E0B))));
    balance.add(
      _rt_Mesh3D(_rt_Geometry3D.torus(0.5, 0.1, radialSegments: 6, tubularSegments: 16), _metal)
        ..position.y = -3.5
        ..rotation.y = math.pi / 2,
    );
    balance.add(_hitBox(4, 8, 4));
    balance.visible = false;
    _scene.add(balance);
    _obj['balance'] = balance;
    _createLabel('balance');

    // 7. Stone
    final stone = _mk('stone', _rt_V3(-2, 1.5, 14), _rt_V3(8, 7, 0));
    stone.add(_rt_Mesh3D(_rt_Geometry3D.icosahedron(1.5), _stoneMat));
    stone.add(_hitBox(4, 4, 4));
    stone.visible = false;
    _scene.add(stone);
    _obj['stone'] = stone;
    _createLabel('stone');

    // 8. Beaker (target x = 2.5 is beside the overflow can)
    final beaker = _mk('beaker', _rt_V3(6, 2, 16), _rt_V3(2.5, 6, 0));
    beaker.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(2, 2, 4, segments: 24, openEnded: true), _glass)..position.y = 2);
    _beakerWater = _rt_Mesh3D(_rt_Geometry3D.cylinder(1.9, 1.9, 0.1, segments: 24), _water)
      ..position.y = 0.1
      ..visible = false;
    beaker.add(_beakerWater);
    beaker.add(_hitBox(6, 6, 6)..position.y = 2);
    beaker.visible = false;
    _scene.add(beaker);
    _obj['beaker'] = beaker;
    _createLabel('beaker');

    // 9. Water Stream
    _waterStream = _rt_Mesh3D(_rt_Geometry3D.cylinder(0.15, 0.15, 6, segments: 8), _water)
      ..position.set(2.5, 9, 0)
      ..visible = false
      ..pickable = false;
    _scene.add(_waterStream);

    // 10. Digital Scale
    final scale = _rt_Node3D(name: 'scale');
    scale.add(_rt_Mesh3D(_rt_Geometry3D.box(6, 1, 6), _rt_Material3D(color: const Color(0xFF334155))));
    scale.add(
      _rt_Mesh3D(_rt_Geometry3D.box(4, 0.1, 2), _rt_Material3D(color: Colors.black, unlit: true))..position.set(0, 0.51, 1.5),
    );
    scale.position.set(0, 6, 0);
    scale.visible = false;
    scale.traverse((n) => n.pickable = false);
    _scene.add(scale);
    _obj['scale'] = scale;
    _createLabel('scale');

    // 11. Iron Block & Hull
    final block = _mk('block', _rt_V3(-10, 7, 0), null);
    block.add(_rt_Mesh3D(_rt_Geometry3D.box(3, 3, 3), _iron));
    block.add(_hitBox(5, 5, 5));
    block.visible = false;
    _scene.add(block);
    _obj['block'] = block;
    _createLabel('block');

    final hull = _rt_Node3D(name: 'hull');
    hull.add(
      _rt_Mesh3D(
          _rt_Geometry3D.cylinder(3, 3, 3, segments: 24, openEnded: true, thetaLength: math.pi),
          _rt_Material3D(color: const Color(0xFFEF4444), metalness: 0.6, shininess: 0.5, doubleSided: true),
        )
        ..rotation.z = math.pi / 2
        ..scale.y = 1.5,
    );
    hull.position.set(0, 10.5, 0);
    hull.visible = false;
    hull.traverse((n) => n.pickable = false);
    _scene.add(hull);
    _obj['hull'] = hull;
    _createLabel('hull');
  }

  void _createLabel(String key) {
    final l = _rt_Label3D(
      '',
      pixelHeight: 10,
      background: const Color(0xF20F172A),
      borderColor: _brandTeal,
      color: Colors.white,
    )..pickable = false;
    _scene.add(l);
    _labels[key] = l;
  }

  void _syncLabels() {
    for (final e in _labels.entries) {
      final key = e.key;
      var txt = _tx.s('labels.$key');
      if (_step >= 4 && key == 'cork') txt = '$txt\n${_tx.s('lbl_less_dense')}';
      if (_step >= 4 && key == 'nail') txt = '$txt\n${_tx.s('lbl_more_dense')}';
      if (key == 'balance') {
        var reading = '0.0 N';
        if (_stoneAttached) reading = '5.0 N';
        if (_step >= 9 && _obj['balance']!.position.y < 16) reading = '3.0 N';
        txt = '${_tx.s('lbl_balance')}\n$reading';
      } else if (key == 'scale') {
        var reading = '0.0 N';
        if (_step >= 11 && _beakerOnScale) reading = '2.0 N';
        txt = '${_tx.s('lbl_scale')}\n$reading';
      }
      e.value.text = txt;
    }
  }

  void _updateLabels() {
    for (final e in _labels.entries) {
      final o = _obj[e.key];
      final l = e.value;
      if (o == null || !_labelsVisible || !o.isVisibleInTree) {
        l.visible = false;
        continue;
      }
      l.visible = true;
      final v = o.worldPosition;
      final off = switch (e.key) {
        'tank' => 6.2,
        'bench' => 1.8,
        'balance' => 4.4,
        'scale' => 2.2,
        'beaker' => 5.4,
        'bottle' => 8.2,
        'overflow' => 7.6,
        _ => 2.4,
      };
      l.position.set(v.x, v.y + off, v.z);
    }
  }

  // ------------------------------------------------------------- drag ---
  static const _dragAllowed = {
    1: ['tank', 'nail', 'cork'],
    2: ['nail'],
    3: ['cork'],
    5: ['bottle'],
    7: ['overflow', 'balance', 'stone', 'beaker'],
    8: ['stone'],
    11: ['beaker'],
    12: ['block'],
  };

  bool _onPointerDown(_rt_SceneEvent e) {
    final allowed = _dragAllowed[_step];
    if (allowed == null || _simulating || _assistHold) return false;
    if (_step == 12 && _blockDropped) return false;
    if (_step == 11 && _beakerOnScale) return false;
    final hit = e.hitWhere(
      (n) => n.userData['id'] != null && allowed.contains(n.userData['id']) && n.parent == _scene.root,
    );
    if (hit == null) return false;
    if (_step == 1 && hit.userData['onBench'] == true) return false;
    if (_step == 7 && hit.userData['onBench'] == true) return false;
    _startDrag(hit, e);
    return true;
  }

  void _startDrag(_rt_Node3D obj, _rt_SceneEvent e) {
    _selected = obj;
    _planePoint = obj.position.clone();
    _planeNormal = _rt_V3(0, 1, 0); // Default horizontal plane
    if (_step == 5 || _step == 8) {
      _planeNormal = (_camera.target - _camera.position).normalized();
    }
    final p =
        e.ray.intersectPlane(_planePoint, _planeNormal) ??
        e.ray.intersectPlane(_planePoint, -_planeNormal) ??
        obj.position.clone();
    _dragOffset = obj.position - p;
  }

  void _onPointerMove(_rt_SceneEvent e) {
    final obj = _selected;
    if (obj == null) return;
    final p = e.ray.intersectPlane(_planePoint, _planeNormal) ?? e.ray.intersectPlane(_planePoint, -_planeNormal);
    if (p == null) return;
    final np = p + _dragOffset;
    if (_step == 5 && obj.userData['id'] == 'bottle') {
      np.x = np.x.clamp(-4.0, 4.0);
      np.z = np.z.clamp(-3.0, 3.0);
      np.y = np.y.clamp(6.0, 16.0);
    }
    obj.position.copy(np);
  }

  void _onPointerUp(_rt_SceneEvent e) {
    final obj = _selected;
    if (obj == null) return;
    _selected = null;
    final id = obj.userData['id'];
    if (_step == 5 && id == 'bottle') {
      _triggerRelease();
    } else if (_step == 8 && id == 'stone') {
      _checkStoneAttach();
    } else if (_step == 11 && id == 'beaker') {
      _checkScaleWeigh();
    } else if (_step == 12 && id == 'block') {
      _checkBlockSink();
    } else {
      _checkDrop(obj);
    }
  }

  // --------------------------------------------------------- animation ---
  void _onFrame(double dt) {
    _tweens.update(dt);
    if (_started) {
      final frames = (dt * 60).round().clamp(1, 8);
      for (var i = 0; i < frames; i++) {
        _update();
      }
      if (_step == 6) {
        _step6Time += dt;
        // Safety: settle the bottle if it keeps bobbing for too long.
        if (_step6Time > 12 && _step == 6) {
          _obj['bottle']!.position.y = _waterLevel;
          _setStep(7);
        }
      }
    }
    _syncLabels();
    _updateLabels();
  }

  void _update() {
    final nail = _obj['nail']!, cork = _obj['cork']!, bottle = _obj['bottle']!;
    final balance = _obj['balance']!, block = _obj['block']!, hull = _obj['hull']!;

    // STEP 2: Nail Sinking
    if (_step == 2 && _simulating) {
      _velocity += 0.005;
      nail.position.y -= _velocity;
      if (nail.position.y <= 6) {
        nail.position.y = 6;
        _simulating = false;
        _rt_playSfx(_rt_Sfx.correct);
        _hud(() => _tx.s('workflow.1.obs'), () => _tx.s('lbl_obs'));
        _updateData(10, 0.1, 0.01, 0.09);
        _later(2000, () => _setStep(3));
      }
    }

    // STEP 3: Cork Floating (Smoothed)
    if (_step == 3 && _simulating) {
      if (cork.position.y > _waterLevel && _corkTime == 0) {
        _velocity += 0.005;
        cork.position.y -= _velocity;
      } else {
        _corkTime += 0.05;
        final amplitude = 0.5 * math.exp(-_corkTime * 0.5);
        cork.position.y = _waterLevel - (math.cos(_corkTime) * amplitude);
        if (_corkTime > 8) {
          _simulating = false;
          cork.position.y = _waterLevel;
          _rt_playSfx(_rt_Sfx.correct);
          _hud(() => _tx.s('workflow.2.obs'), () => _tx.s('lbl_obs'));
          _updateData(10, 0.1, 0.1, 0.0);
          _later(2000, () {
            _setStep(4);
            setState(() => _analyzeVisible = true);
          });
        }
      }
    }

    // STEP 5: Force
    if (_step == 5 && ((_selected != null && _selected!.userData['id'] == 'bottle') || _assistHold)) {
      final depth = _waterLevel - bottle.position.y;
      if (depth > 0) {
        bottle.position.x += (_rng.nextDouble() - 0.5) * 0.05;
        final pct = math.min(100.0, depth * 25);
        if (!_forceMeterVisible || (pct - _forcePct).abs() > 0.5) {
          setState(() {
            _forceMeterVisible = true;
            _forcePct = pct;
          });
        }
        if (pct > 60) {
          _holdTimer++;
          if (_holdTimer % 20 == 0) _rt_playSfx(_rt_Sfx.tap, volume: 0.4);
          if (_holdTimer == 121) _hud(() => _tx.s('msg_force_detected'), () => _tx.s('lbl_action'));
        }
      } else {
        if (_forceMeterVisible) setState(() => _forceMeterVisible = false);
        _holdTimer = 0;
      }
    } else if (_step == 5 && _forceMeterVisible) {
      setState(() => _forceMeterVisible = false);
    }

    // STEP 6: Rocket
    if (_step == 6) {
      if (bottle.position.y < _waterLevel) {
        _velocity += 0.04;
        _velocity *= 0.98;
      } else {
        _velocity -= 0.015;
      }
      bottle.position.y += _velocity;
      if (bottle.position.y > _waterLevel && _velocity > 0.2 && !_splashed) {
        _splashed = true;
        _rt_playSfx(_rt_Sfx.pop);
      }
      if (bottle.position.y < _waterLevel && _velocity.abs() < 0.01) {
        bottle.position.y = _waterLevel;
        _setStep(7); // Auto advance to setup
      }
    }

    // STEP 9: Water Displacement Animation
    if (_step == 9 && _simulating) {
      if (balance.position.y > 13) {
        balance.position.y -= 0.04;
        // Effects start when stone enters water (around Balance y=16)
        if (balance.position.y < 16) {
          _waterStream.visible = true;
          _beakerWater.visible = true;
          if (_beakerWater.scale.y < 20) {
            _beakerWater.scale.y += 0.15;
            _beakerWater.position.y = 0.1 + (_beakerWater.scale.y * 0.05);
          }
        }
      } else {
        _waterStream.visible = false;
        _simulating = false;
        _hud(() => _tx.s('workflow.8.obs'), () => _tx.s('lbl_obs'));
        _rt_playSfx(_rt_Sfx.correct);
        _later(2000, () => _setStep(10));
      }
    }

    // STEP 12: Block Sink
    if (_step == 12 && _simulating) {
      if (block.visible) {
        block.position.y -= 0.1;
        if (block.position.y <= 6) {
          block.position.y = 6;
          _simulating = false;
          setState(() => _actionBtn = 'reshape');
        }
      } else {
        // Hull Float
        if (hull.position.y < _waterLevel) hull.position.y += 0.05;
      }
    }
  }

  // ------------------------------------------------------------ steps ---
  void _setStep(int id) {
    final o = _obj;
    setState(() {
      _step = id;
      _forceMeterVisible = false;
      _actionBtn = null;
      _calcVisible = false;
    });
    _updateText(id);
    _rt_playSfx(_rt_Sfx.scenario, volume: 0.6);

    if (id == 7) {
      for (final k in ['tank', 'nail', 'cork', 'bottle']) {
        o[k]!.visible = false;
      }
      for (final k in ['overflow', 'balance', 'stone', 'beaker']) {
        // Reset to shelf positions for manual drag
        o[k]!
          ..visible = true
          ..position.copy(o[k]!.userData['startPos'] as _rt_V3);
      }
    }
    if (id == 9) setState(() => _actionBtn = 'lower');
    if (id == 10) {
      _calcInput.clear();
      setState(() => _calcVisible = true);
    }
    if (id == 11) {
      o['overflow']!.visible = false;
      o['balance']!.visible = false;
      o['stone']!.visible = false;
      o['scale']!.visible = true;
      // Reset beaker to a clear position on the bench for dragging
      o['beaker']!.position.set(8, 6, 0);
      (o['beaker']!.userData['targetPos'] as _rt_V3).set(8, 6, 0);
      // Ensure beaker water is full for this visual
      _beakerWater.visible = true;
      _beakerWater.scale.y = 20;
      _beakerWater.position.y = 0.1 + (_beakerWater.scale.y * 0.05);
    }
    if (id == 12) {
      o['scale']!.visible = false;
      o['beaker']!.visible = false;
      o['tank']!
        ..visible = true
        ..position.set(0, 10.5, 0);
      o['block']!.visible = true;
    }
  }

  void _triggerAnalysis() {
    setState(() => _analyzeVisible = false);
    _setStep(5);
    _obj['bottle']!.position.set(0, 16, 0);
    _hud(() => _tx.s('msg_next_phase'), () => _tx.s('ui_ready'));
  }

  void _triggerRelease() {
    final bottle = _obj['bottle']!;
    if (bottle.position.y < 10) {
      setState(() {
        _step = 6;
        _forceMeterVisible = false;
      });
      _splashed = false;
      _velocity = 0;
      _step6Time = 0;
      _updateText(6);
      _rt_playSfx(_rt_Sfx.correct);
    }
  }

  void _triggerAction() {
    if (_step == 9 && !_simulating) {
      _simulating = true;
      setState(() => _actionBtn = null);
    }
    if (_step == 12 && _actionBtn == 'reshape') {
      // Reshape Action
      _obj['block']!.visible = false;
      _obj['hull']!
        ..visible = true
        ..position.set(0, 6, 0);
      _simulating = true;
      setState(() => _actionBtn = null);
      _rt_playSfx(_rt_Sfx.magic);
      _hud(() => _tx.s('msg_hull_float'), () => _tx.s('msg_success'));
      _later(3000, _showConclusion);
    }
  }

  void _verifyCalculation() {
    final val = double.tryParse(_calcInput.text.trim());
    if (val == 2) {
      _rt_playSfx(_rt_Sfx.correct);
      setState(() => _calcVisible = false);
      _setStep(11);
    } else {
      _rt_playSfx(_rt_Sfx.wrong);
      _hud(() => _tx.s('msg_try_again'), () => _tx.s('lbl_error'));
    }
  }

  void _checkDrop(_rt_Node3D obj) {
    final ud = obj.userData;
    final id = ud['id'];
    if (_step == 1) {
      // Generous drop zone for bench
      if (obj.position.x.abs() < 20 && obj.position.z.abs() < 15) {
        obj.position.copy(ud['targetPos'] as _rt_V3);
        ud['onBench'] = true;
        _rt_playSfx(_rt_Sfx.pop);
        if (['tank', 'nail', 'cork'].every((k) => _obj[k]!.userData['onBench'] == true)) {
          _hud(() => _tx.s('workflow.0.obs'), () => _tx.s('lbl_obs'));
          _later(1500, () => _setStep(2));
        }
      } else {
        obj.position.copy(ud['startPos'] as _rt_V3);
      }
    } else if (_step == 2 && id == 'nail') {
      if (obj.position.x.abs() < 8 && obj.position.z.abs() < 6) {
        obj.position.set(0, 11, 0);
        _simulating = true;
        _velocity = 0;
        _rt_playSfx(_rt_Sfx.pop);
      } else {
        obj.position.copy(ud['targetPos'] as _rt_V3);
      }
    } else if (_step == 3 && id == 'cork') {
      if (obj.position.x.abs() < 8 && obj.position.z.abs() < 6) {
        obj.position.set(2, 14, 0);
        _simulating = true;
        _velocity = 0;
        _corkTime = 0;
        _rt_playSfx(_rt_Sfx.pop);
      } else {
        obj.position.copy(ud['targetPos'] as _rt_V3);
      }
    } else if (_step == 7) {
      // Expanded bench area check
      if (obj.position.x.abs() < 25 && obj.position.z.abs() < 20) {
        obj.position.copy(ud['targetPos'] as _rt_V3);
        ud['onBench'] = true;
        _rt_playSfx(_rt_Sfx.pop);
        if (['overflow', 'balance', 'stone', 'beaker'].every((k) => _obj[k]!.userData['onBench'] == true)) {
          _hud(() => _tx.s('workflow.6.obs'), () => _tx.s('lbl_setup_complete'));
          _later(1500, () => _setStep(8));
        }
      } else {
        obj.position.copy(ud['startPos'] as _rt_V3);
      }
    }
  }

  void _checkStoneAttach() {
    final stone = _obj['stone']!, balance = _obj['balance']!;
    // Check if stone is near balance hook
    final hook = _rt_V3(balance.position.x, balance.position.y - 4, balance.position.z);
    if (stone.position.distanceTo(hook) < 15) {
      _stoneAttached = true;
      balance.add(stone);
      stone.position.set(0, -5, 0);
      _rt_playSfx(_rt_Sfx.pop);
      // Move setup to center, HIGH enough so stone is OUT of water
      balance.position.set(-4, 20, 0);
      _hud(() => _tx.s('workflow.7.obs'), () => _tx.s('lbl_measurement'));
      _later(2000, () => _setStep(9));
    } else {
      stone.position.copy(stone.userData['startPos'] as _rt_V3);
    }
  }

  void _checkScaleWeigh() {
    final beaker = _obj['beaker']!, scale = _obj['scale']!;
    if (beaker.position.distanceTo(scale.position) < 8) {
      beaker.position.set(0, 6.5, 0);
      _beakerOnScale = true;
      _rt_playSfx(_rt_Sfx.correct);
      _hud(() => _tx.s('workflow.10.obs'), () => _tx.s('lbl_obs'));
      _later(3000, () => _setStep(12));
    } else {
      beaker.position.copy(beaker.userData['targetPos'] as _rt_V3);
    }
  }

  void _checkBlockSink() {
    final block = _obj['block']!;
    if (block.position.x.abs() < 8) {
      block.position.set(0, 11, 0);
      _blockDropped = true;
      _simulating = true;
      _rt_playSfx(_rt_Sfx.pop);
    } else {
      block.position.copy(block.userData['startPos'] as _rt_V3);
    }
  }

  // Sidebar / quick-action assist (the HTML `btn` of each workflow step):
  // performs the drag interaction automatically for touch users.
  Future<void> _assist() async {
    final o = _obj;
    switch (_step) {
      case 1:
        for (final k in ['tank', 'nail', 'cork']) {
          if (o[k]!.userData['onBench'] != true) {
            o[k]!.position.set(0, o[k]!.position.y, 0);
            _checkDrop(o[k]!);
          }
        }
      case 2:
      case 3:
        if (_simulating) return;
        final n = o[_step == 2 ? 'nail' : 'cork']!;
        n.position.set(0, n.position.y, 0);
        _checkDrop(n);
      case 4:
        _triggerAnalysis();
      case 5:
        if (_assistHold) return;
        final bottle = o['bottle']!;
        final g = _gen;
        setState(() => _assistHold = true);
        final sy = bottle.position.y;
        await _tweens.run(1200, (t) => bottle.position.y = sy + (7 - sy) * t, ease: _rt_Ease.inOutQuad);
        await _tweens.wait(2300);
        if (!mounted || g != _gen) return;
        setState(() => _assistHold = false);
        _triggerRelease();
      case 7:
        for (final k in ['overflow', 'balance', 'stone', 'beaker']) {
          if (o[k]!.userData['onBench'] != true) {
            o[k]!.position.set(0, o[k]!.position.y, 0);
            _checkDrop(o[k]!);
          }
        }
      case 8:
        if (_stoneAttached) return;
        final b = o['balance']!.position;
        o['stone']!.position.set(b.x, b.y - 4, b.z);
        _checkStoneAttach();
      case 9:
        _triggerAction();
      case 10:
        _verifyCalculation();
      case 11:
        if (_beakerOnScale) return;
        o['beaker']!.position.copy(o['scale']!.position);
        _checkScaleWeigh();
      case 12:
        if (!_blockDropped) {
          final bl = o['block']!;
          bl.position.set(0, bl.position.y, 0);
          _checkBlockSink();
        } else if (_actionBtn == 'reshape') {
          _triggerAction();
        }
    }
  }

  bool get _assistEnabled {
    switch (_step) {
      case 2:
      case 3:
        return !_simulating;
      case 5:
        return !_assistHold;
      case 6:
        return false;
      case 8:
        return !_stoneAttached;
      case 9:
        return _actionBtn == 'lower';
      case 10:
        return _calcVisible;
      case 11:
        return !_beakerOnScale;
      case 12:
        return !_blockDropped || _actionBtn == 'reshape';
    }
    return true;
  }

  // ---------------------------------------------------------------- ui ---
  void _updateText(int id) {
    _hud(() => _tx.s('workflow.${id - 1}.desc'), () => _tx.s('lbl_inst'));
  }

  void _hud(String Function() m, String Function() t) {
    setState(() {
      _hudMsg = m;
      _hudTitle = t;
      _hudShown = true;
    });
  }

  void _updateData(double m, double g, double b, double n) {
    setState(() {
      _dataObjKey = _step == 2 ? 'nail' : (_step == 3 ? 'cork' : null);
      _g = g;
      _b = b;
      _n = n;
    });
  }

  Future<void> _showConclusion() async {
    const icons = {
      'scale': (Icons.balance, _brandWarn),
      'drip': (Icons.format_color_fill, _rt_Tw.blue400),
      'check': (Icons.done_all, _rt_Tw.green400),
      'ship': (Icons.directions_boat, _rt_Tw.purple500),
    };
    await _shell.showSuccess(
      title: _tx.s('ui_discovery'),
      icon: Icons.science,
      color: _brandTeal,
      buttonLabel: _tx.s('btn_restart'),
      onConfirm: _restart, // a tap outside just closes the popup
      body: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _rt_Tw.slate50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _rt_Tw.slate200),
        ),
        child: Column(
          children: [
            for (final c in _tx.list('conclusion'))
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(icons[c['icon']]!.$1, color: icons[c['icon']]!.$2, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: '${c['b']} ',
                              style: const TextStyle(fontWeight: FontWeight.w900),
                            ),
                            TextSpan(text: c['t'] as String),
                          ],
                        ),
                        style: const TextStyle(fontSize: 13.5, color: _rt_Tw.slate700, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _restart() {
    _gen++;
    _tweens.cancelAll();
    _scene.clear();
    _obj.clear();
    _labels.clear();
    _camera.reset();
    _calcInput.clear();
    setState(() {
      _step = 1;
      _simulating = false;
      _velocity = 0;
      _holdTimer = 0;
      _corkTime = 0;
      _splashed = false;
      _stoneAttached = false;
      _beakerOnScale = false;
      _blockDropped = false;
      _assistHold = false;
      _selected = null;
      _analyzeVisible = false;
      _actionBtn = null;
      _calcVisible = false;
      _forceMeterVisible = false;
      _forcePct = 0;
      _dataObjKey = null;
      _g = _b = _n = null;
    });
    _init3D();
    _updateText(1);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: _rt_LangBuilder(
        builder: (context, lang) {
          _syncLabels();
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            theme: const _rt_ShellTheme(
              accent: _brandTeal,
              headerGradient: [_rt_Tw.slate900, _rt_Tw.slate800],
              headerSubtitleColor: _rt_Tw.slate400,
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.subtitle'),
              buttonLabel: _tx.s('intro.button'),
              icon: Icons.waves,
              buttonIcon: Icons.arrow_forward,
            ),
            onStart: () {
              _started = true;
              _updateText(1);
            },
            onRestart: _restart,
            onZoomIn: _camera.zoomIn,
            onZoomOut: _camera.zoomOut,
            onResetView: _camera.reset,
            toolbarExtras: [
              if (!_isLocked) ...[
                _rt_RotatePanToggle(controller: _viewCtrl, accent: _brandTeal),
                const SizedBox(height: 4),
              ],
              _toolBtn(
                _isLocked ? Icons.lock : Icons.lock_open,
                _tx.s(_isLocked ? 'tools.lock' : 'tools.unlock'),
                active: _isLocked,
                color: _isLocked ? _rt_Tw.red400 : _rt_Tw.green500,
                onTap: () => setState(() {
                  _isLocked = !_isLocked;
                  _applyLock();
                }),
              ),
              const SizedBox(height: 4),
              _toolBtn(
                _labelsVisible ? Icons.visibility : Icons.visibility_off,
                _tx.s('tools.labels'),
                active: _labelsVisible,
                color: _brandTeal,
                onTap: () => setState(() => _labelsVisible = !_labelsVisible),
              ),
            ],
            initialTab: 1,
            tabs: [
              _rt_ShellTab(label: _tx.s('tabs.explore'), icon: Icons.science, builder: (_) => _exploreTab()),
          ],
            canvas: _rt_Scene3DView(
              scene: _scene,
              camera: _camera,
              controller: _viewCtrl,
              onFrame: _onFrame,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
            ),
            canvasOverlays: [Positioned.fill(child: LayoutBuilder(builder: (context, c) => _overlays(c)))],
          );
        },
      ),
    );
  }

  Widget _toolBtn(
    IconData icon,
    String tip, {
    required bool active,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tip,
      child: InkResponse(
        radius: 22,
        onTap: () {
          _rt_playSfx(_rt_Sfx.tap);
          onTap();
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? color : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          child: Icon(icon, size: 18, color: active ? Colors.white : color),
        ),
      ),
    );
  }

  Widget _overlays(BoxConstraints c) {
    final small = c.maxHeight < 380 || c.maxWidth < 560;
    final meterH = math.min(200.0, c.maxHeight - 200);
    return Stack(
      children: [
        // Notebook / Data Display (Top Right)
        Positioned(top: 12, right: 60, width: math.min(220.0, c.maxWidth * 0.4), child: _dataHud(small)),
        // HUD Notification
        Positioned(
          left: 76,
          right: 60,
          bottom: 14,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _hudShown ? 1 : 0,
              child: Center(child: _hudBox(small)),
            ),
          ),
        ),
        // Force Meter (Step 5)
        if (_forceMeterVisible)
          Positioned(
            left: 20,
            top: (c.maxHeight - meterH) / 2 - 10,
            child: IgnorePointer(child: _forceMeter(meterH)),
          ),
        // ANALYZE BUTTON
        if (_analyzeVisible && _step == 4)
          Positioned.fill(
            child: Center(child: _pillButton(_tx.s('btn_analyze'), _brandTeal, null, _triggerAnalysis, big: !small)),
          ),
        // ACTION BUTTON (STEP 9 & 12)
        if (_actionBtn != null)
          Positioned(
            left: 60,
            right: 60,
            bottom: small ? 64 : 90,
            child: Center(
              child: _pillButton(
                _actionBtn == 'lower' ? _tx.s('btn_lower_balance') : _tx.s('btn_reshape'),
                _brandWarn,
                _actionBtn == 'lower' ? Icons.arrow_downward : Icons.directions_boat,
                _triggerAction,
              ),
            ),
          ),
        // CALCULATION INPUT (STEP 10)
        if (_calcVisible)
          Positioned.fill(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: math.min(320, c.maxWidth - 24), maxHeight: c.maxHeight - 16),
                child: SingleChildScrollView(child: _calcOverlay(small)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _pillButton(String label, Color color, IconData? icon, VoidCallback onTap, {bool big = false}) {
    return Material(
      color: color,
      shape: const StadiumBorder(),
      elevation: 8,
      shadowColor: color,
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: () {
          _rt_playSfx(_rt_Sfx.click);
          onTap();
        },
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: big ? 36 : 24, vertical: big ? 14 : 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 8)],
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: big ? 18 : 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dataHud(bool small) {
    final fs = small ? 10.0 : 11.5;
    Widget row(String l, String v, Color c, {bool bold = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              l,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: fs,
                fontFamily: 'monospace',
                color: bold ? _rt_Tw.slate200 : _rt_Tw.slate400,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              v,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: bold ? fs + 1 : fs,
                fontFamily: 'monospace',
                color: c,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
    String f(double? v) => v == null ? '0.0 N' : '${v.toStringAsFixed(3)} N';
    return IgnorePointer(
      child: Container(
        padding: EdgeInsets.all(small ? 8 : 12),
        decoration: BoxDecoration(
          color: const Color(0xE60F172A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _brandTeal.withValues(alpha: 0.3)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.balance, size: fs + 2, color: _brandTeal),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _tx.s('ui_data'),
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: fs, fontWeight: FontWeight.bold, color: _rt_Tw.slate300, letterSpacing: 1.5),
                  ),
                ),
                // Flexible: the status badge can be wider than a narrow HUD.
                Flexible(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: _rt_Tw.slate800,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _rt_Tw.slate600),
                    ),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(_tx.s('ui_ready'), style: const TextStyle(fontSize: 9.5, color: _brandTeal)),
                    ),
                  ),
                ),
              ],
            ),
            Divider(height: 10, color: _brandTeal.withValues(alpha: 0.3)),
            row(_tx.s('ui_object'), _dataObjKey == null ? '--' : _tx.s('labels.$_dataObjKey'), Colors.white),
            row(_tx.s('ui_force_g'), f(_g), _brandWarn),
            row(_tx.s('ui_force_b'), f(_b), _brandTeal),
            const Divider(height: 8, color: _rt_Tw.slate700),
            row(_tx.s('ui_net_force'), f(_n), Colors.white, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _hudBox(bool small) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 20)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(small ? 18 : 26),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: small ? 14 : 20, vertical: small ? 6 : 8),
          decoration: const BoxDecoration(
            color: Color(0xF20F172A),
            border: Border(top: BorderSide(color: _brandWarn, width: 3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _hudTitle(),
                style: const TextStyle(color: _brandWarn, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
              ),
              Container(width: 1, height: 16, margin: const EdgeInsets.symmetric(horizontal: 10), color: _rt_Tw.slate600),
              Flexible(
                child: Text(
                  _hudMsg(),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: _rt_Tw.slate100, fontSize: small ? 11.5 : 13, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _forceMeter(double h) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: h,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _rt_Tw.slate700, width: 2),
          ),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: (h - 4) * _forcePct / 100,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [_brandWarn, _rt_Tw.red500],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 6,
                left: 0,
                right: 0,
                child: Text(
                  _tx.s('lbl_force'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _tx.s('lbl_upthrust'),
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _calcOverlay(bool small) {
    const mono = TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 16);
    return Container(
      padding: EdgeInsets.all(small ? 14 : 22),
      decoration: BoxDecoration(
        color: const Color(0xF20F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _brandTeal, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.8), blurRadius: 40)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _tx.s('ui_calc_loss').toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
          ),
          const SizedBox(height: 6),
          Text(_tx.s('ui_calc_hint'), style: const TextStyle(color: _rt_Tw.slate400, fontSize: 12)),
          const SizedBox(height: 10),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('5N - 3N = ', style: mono),
                SizedBox(
                  width: 84,
                  child: TextField(
                    key: const ValueKey('calc-input'),
                    controller: _calcInput,
                    textAlign: TextAlign.center,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 18),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: '?',
                      hintStyle: const TextStyle(color: _rt_Tw.slate400),
                      filled: true,
                      fillColor: _rt_Tw.slate700,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _rt_Tw.slate600),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: _brandTeal),
                      ),
                    ),
                  ),
                ),
                const Text(' N', style: mono),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _rt_ActionButton(label: _tx.s('btn_check'), icon: Icons.check, color: _brandTeal, onPressed: _verifyCalculation),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- sidebar ---
  Widget _exploreTab() {
    final wf = _tx.list('workflow');
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 6),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: _rt_Tw.slate300)),
            ),
            child: Text(
              _tx.s('ui_protocol'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: _brandWarn),
            ),
          ),
          for (var i = 0; i < wf.length; i++) _stepItem(i + 1, wf[i] as Map),
        ],
      ),
    );
  }

  Widget _stepItem(int n, Map s) {
    final a = n == _step;
    final d = n < _step;
    return Opacity(
      opacity: a ? 1 : (d ? 0.65 : 0.8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: a ? _rt_Tw.teal50 : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border(left: BorderSide(color: a ? _brandTeal : (d ? _rt_Tw.emerald500 : _rt_Tw.slate300), width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 3)],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$n. ${s['title']}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: a ? _brandTeal : _rt_Tw.slate600),
                  ),
                ),
                if (d) const Icon(Icons.check, size: 16, color: _rt_Tw.green500),
              ],
            ),
            const SizedBox(height: 3),
            Text(s['desc'] as String, style: const TextStyle(fontSize: 11.5, color: _rt_Tw.slate500, height: 1.3)),
            if (a && _started) ...[
              const SizedBox(height: 8),
              _rt_ActionButton(
                label: s['btn'] as String,
                icon: Icons.touch_app,
                color: _brandTeal,
                onPressed: _assistEnabled ? _assist : null,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ignore: unused_element — kept for reference; tab removed from sidebar
  Widget _whyTab() {
    const colors = [_brandTeal, _brandWarn, _rt_Tw.purple500];
    final list = _tx.list('why');
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_SectionLabel(_tx.s('why_title'), color: _rt_Tw.slate700, icon: Icons.lightbulb),
          for (var i = 0; i < list.length; i++)
            _rt_InfoCard(title: '${list[i]['e']}  ${list[i]['title']}', body: list[i]['desc'] as String, color: colors[i]),
        ],
      ),
    );
  }

  // ignore: unused_element — kept for reference; tab removed from sidebar
  Widget _outcomesTab() {
    const colors = [_brandTeal, _brandWarn, _rt_Tw.purple500];
    const icons = [Icons.psychology, Icons.arrow_downward, Icons.visibility];
    final list = _tx.list('outcomes');
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_SectionLabel(_tx.s('outcomes_title'), color: _rt_Tw.slate700, icon: Icons.school),
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(_tx.s('outcomes_intro'), style: const TextStyle(fontSize: 12, color: _rt_Tw.slate500)),
          ),
          for (var i = 0; i < list.length; i++)
            _rt_InfoCard(
              title: list[i]['title'] as String,
              body: list[i]['desc'] as String,
              icon: icons[i],
              color: colors[i],
              leftBorder: true,
            ),
        ],
      ),
    );
  }
}
