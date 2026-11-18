// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Subatomic Particle Lab (Particle Discovery Lab)
// Converted from Cl9S-Ch4-A1-The_Subatomic_particle_Discovery_Lab.html (three.js -> mini3d).




// --- 1. DATA ENGINE (LAB_TEXT) ---

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
    'intro': {
      'title': 'Particle Discovery _rt_Lab',
      'subtitle': 'Class 9 • Structure of the Atom',
      'button': 'Enter Laboratory',
    },
    'title': 'Subatomic Particle _rt_Lab',
    'subtitle': 'Class 9 • Structure of the Atom',
    'hudLabel': 'Current Mission',
    'pumpButton': 'Start Pump',
    'runbook': '_rt_Lab Runbook',
    'complete': '_rt_Lab Complete!',
    'takeaways': 'Key Takeaways',
    'tabs': {'why': 'Why Learn?', 'explore': 'Virtual _rt_Lab', 'post': 'Post Activity'},
    'whyToLearn': [
      {
        'title': 'Behind the Screen',
        'icon': 'tv',
        'desc':
            "Old CRT televisions worked by firing beams of Electrons at a screen to create images. Without discovering electrons, we wouldn't have had the video revolution!",
      },
      {
        'title': 'The Neon Glow',
        'icon': 'bolt',
        'desc':
            'Neon signs glow because electricity strips electrons from gas atoms, creating plasma. This lab simulates that exact discharge process.',
      },
      {
        'title': "Nature's Fury",
        'icon': 'storm',
        'desc':
            'Lightning is a massive static discharge. Understanding charge (Step 1 & 2) helps us understand weather phenomena and safety.',
      },
    ],
    'postActivity': {
      'summary': 'You have successfully deconstructed the atom!',
      'points': [
        {'b': 'Electrons:', 't': 'Negatively charged, extremely light particles found by J.J. Thomson.'},
        {
          'b': 'Protons:',
          't': 'Positively charged, heavy particles (approx 2000x heavier than electrons) found by E. Goldstein.'
        },
        {'b': 'Conclusion:', 't': 'Atoms are divisible and made of charged parts.'},
      ],
    },
    'steps': [
      {
        'title': 'Step 1: The Static Prelude',
        'desc': 'Rub the comb through hair to generate static.',
        'action': 'Rub Comb',
        'hint': 'Drag the comb near paper to test charge.',
        'successMsg':
            'Success! The friction transferred electrons to the comb, giving it a negative charge that attracted the paper.',
      },
      {
        'title': 'Step 2: Building Apparatus',
        'desc': 'Assemble the Discharge Tube on the stand.',
        'action': 'Assemble',
        'hint': 'Connect wires to the induction coil.',
        'successMsg': 'Circuit Complete! The discharge tube is connected to the high voltage induction coil.',
      },
      {
        'title': 'Step 3: Creating Vacuum',
        'desc': 'Reduce pressure to 0.001 mm Hg.',
        'action': 'Pump Vacuum',
        'hint': 'Use the slider to lower pressure.',
        'successMsg': 'Vacuum Established! Low pressure allows electricity to flow through gases.',
      },
      {
        'title': 'Step 4: Discovery (Electrons)',
        'desc': 'Turn on High Voltage to see Cathode Rays.',
        'action': 'Fire HV',
        'hint': 'Switch on power to see green glow.',
        'successMsg': 'Cathode Rays Observed! The green glow proves invisible rays are hitting the glass.',
      },
      {
        'title': 'Step 5: Testing Charge (e-)',
        'desc': 'Prove rays are negative with a Positive Plate.',
        'action': 'Test Charge',
        'hint': 'Observe beam deflection upwards.',
        'successMsg':
            'Deflection Confirmed! The rays bent towards the positive plate, proving they are negatively charged electrons.',
      },
      {
        'title': 'Step 6: Reconfigure (Protons)',
        'desc': 'Swap for Perforated Cathode.',
        'action': 'Swap Cathode',
        'hint': 'Install the disc with holes.',
        'successMsg': 'Setup Modified! The perforated cathode will allow rays to pass through it.',
      },
      {
        'title': 'Step 7: Discovery (Canal Rays)',
        'desc': 'Fire HV to see rays go backwards.',
        'action': 'Fire HV',
        'hint': 'Observe red rays through the holes.',
        'successMsg': 'Canal Rays Found! Red rays traveling backwards prove the existence of positive particles.',
      },
      {
        'title': 'Step 8: Testing Charge (p+)',
        'desc': 'Prove rays are positive with Negative Plate.',
        'action': 'Test Charge',
        'hint': 'Observe beam deflection downwards.',
        'successMsg':
            'Positive Charge Confirmed! The rays bent towards the negative plate, identifying them as Protons.',
      },
      {
        'title': 'Step 9: Mass Balance',
        'desc': 'Weigh 1 Proton vs Electrons.',
        'action': 'Start Weighing',
        'hint': 'Stack electrons to balance the scale.',
        'successMsg': 'Mass Balanced! It took about 1840 electrons to equal the mass of just one proton.',
      },
      {
        'title': 'Step 10: Structural Location',
        'desc': 'Locate particles in the atom model.',
        'action': 'Examine Atom',
        'hint': 'Click Nucleus (p+) and Electrons (e-) to test stability.',
        'successMsg':
            'Structure Analyzed! Electrons are on the outside and easy to remove, while Protons are locked deep in the nucleus.',
      },
      {
        'title': 'Step 11: Neutrality Meter',
        'desc': 'Balance charge to create a neutral atom.',
        'action': 'Balance Charge',
        'hint': 'Add Electrons to balance the Positive charge.',
        'successMsg': 'Atom Neutralized! Equal numbers of protons and electrons create a stable, neutral atom.',
      },
      {
        'title': 'Step 12: Summary',
        'desc': 'Consolidate your learning.',
        'action': 'Finish',
        'hint': 'Review the discoveries.',
        'successMsg': '_rt_Lab Complete! You have successfully explored the fundamental subatomic particles.',
      },
    ],
    'cards': {
      'e': {
        'title': 'Electron Discovered',
        'desc': 'J.J. Thomson (1897) identified these negatively charged particles. Mass is negligible (1/2000 u).',
        'name': 'J.J. Thomson',
      },
      'p': {
        'title': 'Proton Discovered',
        'desc': 'E. Goldstein (1886) observed these positive canal rays. Mass is approx 1 u (2000x electron).',
        'name': 'Goldstein',
      },
    },
    'ui': {
      'nextStep': 'Next Step',
      'initialize': 'Initialize',
      'assembling': 'Assembling...',
      'swapping': 'Swapping...',
      'stepComplete': 'Step Complete!',
      'stepCompleted': 'Step Completed!',
      'continue': 'Continue',
      'hint': 'Hint',
      'massTitle': 'Mass Balance _rt_Lab',
      'massDesc': 'Drag the leveler to add electrons until the scale balances.',
      'electrons': 'Electrons',
      'verify': 'Verify & Submit',
      'vacTitle': 'Vacuum Pressure',
      'torrLow': '0.01 torr',
      'torrHigh': '760 torr',
      'pressure': 'Pressure',
      'lowPressure': 'Low pressure reached',
      'neutralTitle': 'Neutrality Meter',
      'neutralDesc': 'Add Electrons (-) to balance the Positive (+) charge.',
      'neg': '-ve',
      'pos': '+ve',
      'neutral': 'Neutral',
      'addElectron': 'Add Electron',
      'addProton': 'Add Proton',
      'finish': 'Finish Activity',
      'completeTitle': 'Activity Completed!',
      'completeMsg': 'You have successfully discovered Electrons and Protons.',
      'restart': 'Restart Activity',
      'closeObs': 'Close Observation',
      'autoRotate': 'Auto Rotate',
      'labels': 'Toggle Labels',
      'useControls': 'Use the controls on the lab screen.',
    },
    'labels': {
      'comb': 'Plastic Comb',
      'anode': 'Anode (+)',
      'cathode': 'Cathode (-)',
      'coil': 'Induction Coil (HV)',
      'tube': 'Discharge Tube',
      'tubeCanal': 'Perforated Cathode Tube',
      'pump': 'Vacuum Pump',
      'plus': '+ Plate',
      'minus': '- Plate',
      'atom': 'Helium Atom Model',
    },
  },
  'hi': {
    'intro': {
      'title': 'कण खोज प्रयोगशाला',
      'subtitle': 'कक्षा 9 • परमाणु की संरचना',
      'button': 'प्रयोगशाला में प्रवेश करें',
    },
    'title': 'उपपरमाण्विक कण प्रयोगशाला',
    'subtitle': 'कक्षा 9 • परमाणु की संरचना',
    'hudLabel': 'वर्तमान मिशन',
    'pumpButton': 'पंप शुरू करें',
    'runbook': 'प्रयोगशाला रनबुक',
    'complete': 'प्रयोगशाला पूर्ण!',
    'takeaways': 'मुख्य निष्कर्ष',
    'tabs': {'why': 'क्यों सीखें?', 'explore': 'आभासी प्रयोगशाला', 'post': 'गतिविधि के बाद'},
    'whyToLearn': [
      {
        'title': 'स्क्रीन के पीछे',
        'icon': 'tv',
        'desc':
            'पुरानी सीआरटी टीवी चित्र बनाने के लिए स्क्रीन पर इलेक्ट्रॉनों की किरणें छोड़ती थीं। इलेक्ट्रॉनों की खोज के बिना वीडियो क्रांति संभव नहीं होती!',
      },
      {
        'title': 'नियॉन चमक',
        'icon': 'bolt',
        'desc':
            'नियॉन संकेत चमकते हैं क्योंकि बिजली गैस परमाणुओं से इलेक्ट्रॉनों को अलग करती है, जिससे प्लाज्मा बनता है। यह प्रयोगशाला ठीक उसी विसर्जन प्रक्रिया का अनुकरण करती है।',
      },
      {
        'title': 'प्रकृति का प्रकोप',
        'icon': 'storm',
        'desc':
            'आकाशीय बिजली एक विशाल स्थिर विसर्जन है। आवेश को समझने (चरण 1 और 2) से हमें मौसम की घटनाओं और सुरक्षा को समझने में मदद मिलती है।',
      },
    ],
    'postActivity': {
      'summary': 'आपने परमाणु की संरचना को सफलतापूर्वक समझ लिया है!',
      'points': [
        {'b': 'इलेक्ट्रॉन:', 't': 'ऋणावेशित, अत्यंत हल्के कण जिनकी खोज जे.जे. थॉमसन ने की।'},
        {'b': 'प्रोटॉन:', 't': 'धनावेशित, भारी कण (इलेक्ट्रॉन से लगभग 2000 गुना भारी) जिनकी खोज ई. गोल्डस्टीन ने की।'},
        {'b': 'निष्कर्ष:', 't': 'परमाणु विभाज्य हैं और आवेशित कणों से बने हैं।'},
      ],
    },
    'steps': [
      {
        'title': 'चरण 1: स्थिर प्रस्तावना',
        'desc': 'स्थिर आवेश उत्पन्न करने के लिए कंघी को बालों में रगड़ें।',
        'action': 'कंघी रगड़ें',
        'hint': 'आवेश जाँचने के लिए कंघी को कागज़ के पास ले जाएँ।',
        'successMsg':
            'सफलता! घर्षण ने इलेक्ट्रॉनों को कंघी में स्थानांतरित कर दिया, जिससे उसे ऋणात्मक आवेश मिला और कागज़ आकर्षित हुआ।',
      },
      {
        'title': 'चरण 2: उपकरण निर्माण',
        'desc': 'डिस्चार्ज ट्यूब को स्टैंड पर असेंबल करें।',
        'action': 'इकट्ठा करें',
        'hint': 'तारों को प्रेरण कुंडली से जोड़ें।',
        'successMsg': 'सर्किट पूरा हुआ! डिस्चार्ज ट्यूब उच्च वोल्टेज प्रेरण कुंडली से जुड़ गई है।',
      },
      {
        'title': 'चरण 3: निर्वात बनाना',
        'desc': 'दबाव को 0.001 mm Hg तक कम करें।',
        'action': 'वैक्यूम पंप',
        'hint': 'दबाव कम करने के लिए स्लाइडर का उपयोग करें।',
        'successMsg': 'निर्वात स्थापित! कम दबाव गैसों में से बिजली को प्रवाहित होने देता है।',
      },
      {
        'title': 'चरण 4: खोज (इलेक्ट्रॉन)',
        'desc': 'कैथोड किरणें देखने के लिए उच्च वोल्टेज चालू करें।',
        'action': 'एचवी चालू करें',
        'hint': 'हरी चमक देखने के लिए बिजली चालू करें।',
        'successMsg': 'कैथोड किरणें देखी गईं! हरी चमक साबित करती है कि अदृश्य किरणें काँच से टकरा रही हैं।',
      },
      {
        'title': 'चरण 5: आवेश परीक्षण (e-)',
        'desc': 'धनात्मक प्लेट से किरणों को ऋणात्मक साबित करें।',
        'action': 'आवेश परीक्षण',
        'hint': 'बीम का ऊपर की ओर विक्षेपण देखें।',
        'successMsg':
            'विक्षेपण की पुष्टि! किरणें धनात्मक प्लेट की ओर मुड़ गईं, जिससे सिद्ध होता है कि वे ऋणावेशित इलेक्ट्रॉन हैं।',
      },
      {
        'title': 'चरण 6: पुनः व्यवस्था (प्रोटॉन)',
        'desc': 'छिद्रित कैथोड लगाएँ।',
        'action': 'कैथोड बदलें',
        'hint': 'छेद वाली डिस्क स्थापित करें।',
        'successMsg': 'सेटअप संशोधित! छिद्रित कैथोड किरणों को अपने में से गुजरने देगा।',
      },
      {
        'title': 'चरण 7: खोज (कैनाल किरणें)',
        'desc': 'एचवी चालू करके किरणों को पीछे की ओर जाते देखें।',
        'action': 'एचवी चालू करें',
        'hint': 'छेदों से निकलती लाल किरणें देखें।',
        'successMsg': 'कैनाल किरणें मिलीं! पीछे की ओर जाती लाल किरणें धनात्मक कणों के अस्तित्व को सिद्ध करती हैं।',
      },
      {
        'title': 'चरण 8: आवेश परीक्षण (p+)',
        'desc': 'ऋणात्मक प्लेट से किरणों को धनात्मक साबित करें।',
        'action': 'आवेश परीक्षण',
        'hint': 'बीम का नीचे की ओर विक्षेपण देखें।',
        'successMsg': 'धनात्मक आवेश की पुष्टि! किरणें ऋणात्मक प्लेट की ओर मुड़ गईं, जिससे प्रोटॉन की पहचान हुई।',
      },
      {
        'title': 'चरण 9: द्रव्यमान संतुलन',
        'desc': '1 प्रोटॉन बनाम इलेक्ट्रॉनों का वजन करें।',
        'action': 'वजन शुरू करें',
        'hint': 'तराजू संतुलित करने के लिए इलेक्ट्रॉनों का ढेर लगाएँ।',
        'successMsg': 'द्रव्यमान संतुलित! एक प्रोटॉन के द्रव्यमान के बराबर होने में लगभग 1840 इलेक्ट्रॉन लगे।',
      },
      {
        'title': 'चरण 10: संरचनात्मक स्थान',
        'desc': 'परमाणु मॉडल में कणों का पता लगाएँ।',
        'action': 'परमाणु की जाँच',
        'hint': 'स्थिरता जाँचने के लिए नाभिक (p+) और इलेक्ट्रॉन (e-) पर क्लिक करें।',
        'successMsg':
            'संरचना का विश्लेषण! इलेक्ट्रॉन बाहर हैं और आसानी से हटाए जा सकते हैं, जबकि प्रोटॉन नाभिक में गहराई से बंद हैं।',
      },
      {
        'title': 'चरण 11: तटस्थता मीटर',
        'desc': 'उदासीन परमाणु बनाने के लिए आवेश संतुलित करें।',
        'action': 'आवेश संतुलन',
        'hint': 'धनात्मक आवेश को संतुलित करने के लिए इलेक्ट्रॉन जोड़ें।',
        'successMsg': 'परमाणु उदासीन! प्रोटॉन और इलेक्ट्रॉन की समान संख्या एक स्थिर, उदासीन परमाणु बनाती है।',
      },
      {
        'title': 'चरण 12: सारांश',
        'desc': 'अपनी सीख को समेकित करें।',
        'action': 'समाप्त',
        'hint': 'खोजों की समीक्षा करें।',
        'successMsg': 'प्रयोगशाला पूर्ण! आपने मूलभूत उपपरमाण्विक कणों का सफलतापूर्वक अन्वेषण किया है।',
      },
    ],
    'cards': {
      'e': {
        'title': 'इलेक्ट्रॉन की खोज',
        'desc': 'जे.जे. थॉमसन (1897) ने इन ऋणावेशित कणों की पहचान की। इनका द्रव्यमान नगण्य है (1/2000 u)।',
        'name': 'जे.जे. थॉमसन',
      },
      'p': {
        'title': 'प्रोटॉन की खोज',
        'desc': 'ई. गोल्डस्टीन (1886) ने इन धनात्मक कैनाल किरणों को देखा। द्रव्यमान लगभग 1 u (इलेक्ट्रॉन का 2000 गुना) है।',
        'name': 'गोल्डस्टीन',
      },
    },
    'ui': {
      'nextStep': 'अगला चरण',
      'initialize': 'प्रारंभ करें',
      'assembling': 'जोड़ा जा रहा है...',
      'swapping': 'बदला जा रहा है...',
      'stepComplete': 'चरण पूर्ण!',
      'stepCompleted': 'चरण पूरा हुआ!',
      'continue': 'जारी रखें',
      'hint': 'संकेत',
      'massTitle': 'द्रव्यमान संतुलन प्रयोगशाला',
      'massDesc': 'तराजू संतुलित होने तक इलेक्ट्रॉन जोड़ने के लिए लीवर खिसकाएँ।',
      'electrons': 'इलेक्ट्रॉन',
      'verify': 'जाँचें और जमा करें',
      'vacTitle': 'निर्वात दबाव',
      'torrLow': '0.01 torr',
      'torrHigh': '760 torr',
      'pressure': 'दबाव',
      'lowPressure': 'कम दबाव प्राप्त हुआ',
      'neutralTitle': 'तटस्थता मीटर',
      'neutralDesc': 'धनात्मक (+) आवेश को संतुलित करने के लिए इलेक्ट्रॉन (-) जोड़ें।',
      'neg': '-ve',
      'pos': '+ve',
      'neutral': 'उदासीन',
      'addElectron': 'इलेक्ट्रॉन जोड़ें',
      'addProton': 'प्रोटॉन जोड़ें',
      'finish': 'गतिविधि समाप्त करें',
      'completeTitle': 'गतिविधि पूर्ण!',
      'completeMsg': 'आपने इलेक्ट्रॉन और प्रोटॉन की सफलतापूर्वक खोज की है।',
      'restart': 'गतिविधि पुनः आरंभ करें',
      'closeObs': 'अवलोकन बंद करें',
      'autoRotate': 'स्वतः घुमाएँ',
      'labels': 'लेबल दिखाएँ/छिपाएँ',
      'useControls': 'प्रयोगशाला स्क्रीन पर दिए नियंत्रणों का उपयोग करें।',
    },
    'labels': {
      'comb': 'प्लास्टिक कंघी',
      'anode': 'एनोड (+)',
      'cathode': 'कैथोड (-)',
      'coil': 'प्रेरण कुंडली (HV)',
      'tube': 'डिस्चार्ज ट्यूब',
      'tubeCanal': 'छिद्रित कैथोड ट्यूब',
      'pump': 'वैक्यूम पंप',
      'plus': '+ प्लेट',
      'minus': '- प्लेट',
      'atom': 'हीलियम परमाणु मॉडल',
    },
  },
});

/// A DOM-style scene label that follows an object (HTML `addLabel`).
class _SceneLabel {
  _SceneLabel(this.key, this.obj, this.label, this.leader, this.side, this.anchorOffset);
  final String key;
  _rt_Node3D obj;
  final _rt_Label3D label;

  /// Leader line from the object to the label (the CSS ::after line).
  final _rt_Line3D leader;

  /// +1 = label to the right of the object, -1 = `label-left`.
  final double side;
  final _rt_V3 anchorOffset;
  double textWidth = 0;
}

const double _labelFont = 11;

double _measureLabel(String text) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: const TextStyle(fontSize: _labelFont, fontWeight: FontWeight.w800, height: 1.1)),
    textDirection: TextDirection.ltr,
  )..layout();
  return tp.width + _labelFont * 0.9;
}

class Cl9Ch04A1SubatomicParticleLabPage extends StatefulWidget {
  const Cl9Ch04A1SubatomicParticleLabPage({super.key});

  @override
  State<Cl9Ch04A1SubatomicParticleLabPage> createState() => _Cl9Ch04A1SubatomicParticleLabPageState();
}

class _Cl9Ch04A1SubatomicParticleLabPageState extends State<Cl9Ch04A1SubatomicParticleLabPage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF1E3A8A), Color(0xFF020617)],
  );
  final _rt_Camera3D _camera = _rt_Camera3D(fov: 45, position: _rt_V3(0, 15, 30), target: _rt_V3(0, 5, 0), far: 100);
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner();
  final _rt_ShellController _shell = _rt_ShellController();
  final math.Random _rng = math.Random();

  final Map<String, _rt_Node3D> _items = {};
  final List<_SceneLabel> _labels = [];

  // --- STATE ---
  int _currentStepIdx = 0;
  bool _showLabels = true;
  bool _modalOpen = false;
  double _time = 0;
  double _viewH = 400;
  bool _massView = false;

  // scenarioState
  String _mode = 'none';
  int _subState = 0;
  String? _deflect;
  bool _waitingForAssembly = false;
  bool _animatingWires = false;
  double _wireProgress = 0;
  bool _waitingForSwap = false;
  bool _animatingSwap = false;
  double _swapProgress = 0;
  bool _swapped = false;
  int _electronCount = 0;
  int _charge = 0;
  double _vacuum = 100;
  bool _pumping = false; // sidebar "Pump Vacuum" is running the pump

  /// Mirrors the shell sidebar: the step-3 vacuum panel moves above the
  /// shell's step hint while the sidebar is collapsed.
  bool _sidebarOpen = true;

  /// Overrides the main action caption ('nextStep' / 'assembling' / 'swapping').
  String? _mainBtnKey;

  // Wire paths (full length) for the assembly animation.
  List<_rt_V3> _wire1Path = const [];
  List<_rt_V3> _wire2Path = const [];

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _init3D();
    _loadStep(0);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _tweens.cancelAll();
    _viewCtrl.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------- 3D setup ---
  void _init3D() {
    _scene.setLights([
      _rt_Light3D.ambient(intensity: 0.5),
      _rt_Light3D.directional(_rt_V3(10, 20, 10), intensity: 1.0),
    ]);
    // Brushed silver table.
    // The top is a tessellated plane so it never disappears when a corner
    // falls behind the camera; both parts are painted beneath the apparatus.
    final mat = _rt_Material3D(color: const Color(0xFFB4BECB), shininess: 0.5, metalness: 0.6);
    final table = _rt_Mesh3D(_rt_Geometry3D.box(60, 0.98, 30), mat, name: 'table')
      ..position.y = -0.5
      ..depthBias = 1000;
    table.pickable = false;
    final top = _rt_Mesh3D(_rt_Geometry3D.plane(60, 30, widthSegments: 15, heightSegments: 8), mat, name: 'tableTop')
      ..rotation.x = -math.pi / 2
      ..depthBias = 500;
    top.pickable = false;
    _scene.add(table);
    _scene.add(top);
  }

  // --- 3D ASSET GENERATORS (AssetFactory) ---
  _rt_Node3D _createComb() {
    final group = _rt_Node3D(name: 'comb');
    final mat = _rt_Material3D(color: const Color(0xFF9333EA), shininess: 0.3);
    group.add(_rt_Mesh3D(_rt_Geometry3D.box(8, 2, 0.5), mat));
    final toothGeo = _rt_Geometry3D.box(0.3, 2, 0.5);
    for (var i = 0; i < 15; i++) {
      group.add(_rt_Mesh3D(toothGeo, mat)..position.set(-3.5 + i * 0.5, -2, 0));
    }
    return group;
  }

  _rt_Node3D _createCathode(bool perforated) {
    final mat = _rt_Material3D(color: const Color(0xFF333333), metalness: 0.8, shininess: 0.5);
    final geo = _rt_Geometry3D.cylinder(1.8, 1.8, 0.5, segments: 32);
    if (!perforated) {
      return _rt_Mesh3D(geo, mat, name: 'Cathode')
        ..rotation.z = math.pi / 2
        ..position.x = -5.5;
    }
    final cathode = _rt_Node3D(name: 'Cathode');
    cathode.add(_rt_Mesh3D(geo, mat)..rotation.z = math.pi / 2);
    final holeMat = _rt_Material3D(color: Colors.black, unlit: true, doubleSided: true);
    final holeGeo = _rt_Geometry3D.circle(0.2, segments: 16);
    for (final y in [0.0, 0.8, -0.8]) {
      for (final z in [0.0, 0.8, -0.8]) {
        cathode.add(_rt_Mesh3D(holeGeo, holeMat)
          ..rotation.y = -math.pi / 2
          ..position.set(-0.26, y, z)
          ..depthBias = -0.3);
      }
    }
    cathode.position.x = -5.5;
    return cathode;
  }

  _rt_Node3D _createDischargeTube(bool perforated) {
    final group = _rt_Node3D(name: 'tube');
    // Glass Tube
    final glass = _rt_Mesh3D(
      _rt_Geometry3D.cylinder(2, 2, 12, segments: 32, openEnded: true),
      _rt_Material3D(color: Colors.white, opacity: 0.3, doubleSided: true, shininess: 0.9),
    )..rotation.z = math.pi / 2;
    glass.pickable = false;
    group.add(glass);
    // Electrodes
    final anode = _rt_Mesh3D(
      _rt_Geometry3D.cylinder(1.8, 1.8, 0.5, segments: 32),
      _rt_Material3D(color: const Color(0xFFFF0000), metalness: 0.8, shininess: 0.5),
      name: 'Anode',
    )
      ..rotation.z = math.pi / 2
      ..position.x = 5.5;
    group.add(anode);
    group.add(_createCathode(perforated));
    return group;
  }

  _rt_Node3D _createBalanceScale() {
    final group = _rt_Node3D(name: 'scale');
    group.add(_rt_Mesh3D(_rt_Geometry3D.box(8, 1, 4), _rt_Material3D(color: const Color(0xFF333333))));
    group.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.5, 0.5, 10, segments: 16), _rt_Material3D(color: const Color(0xFF888888)))
      ..position.y = 5);
    final beam = _rt_Mesh3D(_rt_Geometry3D.box(14, 0.5, 1), _rt_Material3D(color: const Color(0xFFAAAAAA)), name: 'beam')
      ..position.y = 10;
    group.add(beam);
    _items['beam'] = beam;
    return group;
  }

  _rt_Node3D _createPan() {
    final g = _rt_Node3D();
    g.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.05, 0.05, 6, segments: 6), _rt_Material3D(color: Colors.black, unlit: true))
      ..position.y = -3);
    g.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(2, 1.5, 1, segments: 32, openEnded: true),
        _rt_Material3D(color: const Color(0xFFDDDDDD), doubleSided: true))
      ..position.y = -6);
    return g;
  }

  _rt_Node3D _createVacuumPump() {
    final group = _rt_Node3D(name: 'pump');
    group.add(_rt_Mesh3D(_rt_Geometry3D.box(4, 3, 3), _rt_Material3D(color: const Color(0xFF475569))));
    group.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.5, 0.5, 0.5, segments: 16), _rt_Material3D(color: const Color(0xFFFF0000)),
        name: 'PumpButtonAnchor')
      ..position.y = 1.5);
    final path = _catmullRom([_rt_V3(0, 1, 0), _rt_V3(0, 4, 0), _rt_V3(4, 5, -2), _rt_V3(8, 7.5, -5)], 20);
    group.add(_rt_Mesh3D(_rt_Geometry3D.tube(path, 0.2, radialSegments: 8), _rt_Material3D(color: const Color(0xFF1E293B))));
    return group;
  }

  _rt_Node3D _createAtomModel() {
    final group = _rt_Node3D(name: 'atom');
    // Nucleus
    final nGroup = _rt_Node3D(name: 'nucleus');
    final pMat = _rt_Material3D(color: const Color(0xFFFF0000), shininess: 0.4);
    final nMat = _rt_Material3D(color: const Color(0xFF888888), shininess: 0.4);
    for (var i = 0; i < 8; i++) {
      final p = _rt_Sphere3D(0.8, pMat)
        ..position.set(_rng.nextDouble() - 0.5, _rng.nextDouble() - 0.5, _rng.nextDouble() - 0.5);
      p.userData = {'type': 'proton'};
      nGroup.add(p);
      nGroup.add(_rt_Sphere3D(0.8, nMat)
        ..position.set(_rng.nextDouble() - 0.5, _rng.nextDouble() - 0.5, _rng.nextDouble() - 0.5));
    }
    group.add(nGroup);
    // Electrons
    final electrons = _rt_Node3D(name: 'electrons');
    final eMat = _rt_Material3D(color: const Color(0xFF00FF00), shininess: 0.4);
    for (var i = 0; i < 3; i++) {
      final e = _rt_Sphere3D(0.4, eMat)..position.set(5 * math.cos(i * 2.0), 0, 5 * math.sin(i * 2.0));
      e.userData = {'type': 'electron', 'angle': i * 2.0};
      electrons.add(e);
    }
    group.add(electrons);
    group.userData = {'electrons': electrons, 'nucleus': nGroup};
    return group;
  }

  /// THREE.CatmullRomCurve3(points).getPoints(samples).
  List<_rt_V3> _catmullRom(List<_rt_V3> pts, int samples) {
    final n = pts.length;
    final out = <_rt_V3>[];
    for (var s = 0; s <= samples; s++) {
      final t = s / samples * (n - 1);
      var i = t.floor();
      if (i >= n - 1) i = n - 2;
      final u = t - i;
      final p0 = i == 0 ? pts[0] * 2 - pts[1] : pts[i - 1];
      final p1 = pts[i], p2 = pts[i + 1];
      final p3 = i + 2 < n ? pts[i + 2] : pts[n - 1] * 2 - pts[n - 2];
      final u2 = u * u, u3 = u2 * u;
      out.add((p1 * 2 +
              (p2 - p0) * u +
              (p0 * 2 - p1 * 5 + p2 * 4 - p3) * u2 +
              (p1 * 3 - p0 - p2 * 3 + p3) * u3) *
          0.5);
    }
    return out;
  }

  // ------------------------------------------------------------ helpers ---
  T _add<T extends _rt_Node3D>(String id, T n) {
    _scene.add(n);
    _items[id] = n;
    return n;
  }

  void _clearScene() {
    for (final obj in _items.values) {
      obj.removeFromParent();
    }
    _items.clear();
    for (final l in _labels) {
      l.label.removeFromParent();
      l.leader.removeFromParent();
    }
    _labels.clear();
  }

  void _addLabel(_rt_Node3D obj, String key, {bool left = false, _rt_V3? anchorOffset}) {
    final l = _rt_Label3D(
      _tx.s('labels.$key'),
      pixelHeight: _labelFont,
      background: const Color(0xD90F172A),
      borderColor: const Color(0xFF3B82F6),
      color: const Color(0xFFE2E8F0),
    );
    l.pickable = false;
    final leader = _rt_Line3D([], color: const Color(0x803B82F6), width: 1.2)..depthBias = -1000;
    _scene.add(leader);
    _scene.add(l);
    _labels.add(_SceneLabel(key, obj, l, leader, left ? -1 : 1, anchorOffset ?? _rt_V3())
      ..textWidth = _measureLabel(l.text));
  }

  void _updateLabelTexts() {
    for (final l in _labels) {
      final t = _tx.s('labels.${l.key}');
      if (t != l.label.text) {
        l.label.text = t;
        l.textWidth = _measureLabel(t);
      }
    }
  }

  /// Keeps every label 30 px beside its object like the HTML DOM labels.
  void _positionLabels() {
    final cam = _camera;
    final fwd = (cam.target - cam.position).normalized();
    var right = fwd.cross(_rt_V3(0, 1, 0));
    if (right.lengthSq < 1e-8) right = _rt_V3(1, 0, 0);
    right.normalize();
    final focal = (_viewH / 2) / math.tan(_rt_degToRad(cam.fov) / 2) * cam.zoom;
    for (final l in _labels) {
      final inScene = l.obj.parent != null && l.obj.isVisibleInTree;
      final show = _showLabels && inScene;
      l.label.visible = show;
      l.leader.visible = show;
      if (!show) continue;
      final anchor = l.obj.worldPosition + l.anchorOffset;
      final depth = math.max((anchor - cam.position).dot(fwd), 0.5);
      final perPx = depth / focal; // world units per pixel at this depth
      final edge = anchor + right * (l.side * 30 * perPx);
      l.label.position.copy(edge + right * (l.side * l.textWidth / 2 * perPx));
      l.leader.points = [anchor, edge];
    }
  }

  // --- SCENARIO HANDLERS ---
  void _loadStep(int idx) {
    if (idx < 0 || idx >= _steps.length) return;
    _setMassView(idx == 8);
    _mainBtnKey = null;
    _animatingWires = false;
    _animatingSwap = false;
    _waitingForAssembly = false;
    _waitingForSwap = false;

    if (idx == 0) {
      _setupStatic(); // Step 1
    } else if (idx == 1) {
      // Step 2: Setup — wires hidden initially for the assembly animation.
      _setupDischarge(false);
      _subState = 0;
      final w1 = _items['wire1'], w2 = _items['wire2'];
      if (w1 is _rt_Line3D && w2 is _rt_Line3D) {
        w1.points = [];
        w2.points = [];
        _waitingForAssembly = true;
      }
    } else if (idx == 2) {
      // Step 3: Vacuum
      if (!_items.containsKey('tube')) _setupDischarge(false);
      _vacuum = 100;
    } else if (idx == 3) {
      // Step 4: HV (e-)
      if (!_items.containsKey('tube')) _setupDischarge(false);
      _subState = 2; // Fire
      _rt_playSfx(_rt_Sfx.magic);
    } else if (idx == 4) {
      // Step 5: Deflect e-
      if (!_items.containsKey('tube')) _setupDischarge(false);
      _subState = 2;
      _deflect = 'up';
      _addPlate('positive');
    } else if (idx == 5) {
      // Step 6: Swap Cathode — start with the standard cathode.
      _setupDischarge(false);
      _subState = 0;
      _waitingForSwap = true;
    } else if (idx == 6) {
      // Step 7: Canal Rays
      final tube = _items['tube'];
      if (tube == null || tube.userData['type'] != 'canal') _setupDischarge(true);
      _mode = 'canal';
      _subState = 2;
      _rt_playSfx(_rt_Sfx.magic);
    } else if (idx == 7) {
      // Step 8: Deflect p+
      if (!_items.containsKey('tube')) _setupDischarge(true);
      _mode = 'canal';
      _subState = 2;
      _deflect = 'down';
      _addPlate('negative');
    } else if (idx == 8) {
      // Step 9: Mass
      _setupMass();
    } else if (idx == 9) {
      // Step 10: Atom
      _setupAtom();
    } else if (idx == 10) {
      // Step 11: Neutrality
      _clearScene();
      _charge = 3; // Start with +3 charge
      _mode = 'neutral';
    } else if (idx == 11) {
      // Step 12: Summary
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showCompletion();
      });
    }
  }

  /// The mass balance panel covers the lower canvas, so step 9 looks at the
  /// scale from slightly lower (camera raised target) to keep it visible.
  void _setMassView(bool on) {
    if (on == _massView) return;
    _massView = on;
    if (on) {
      _camera.position.set(0, 12, 32);
      _camera.target.set(0, 1.5, 0);
    } else {
      _camera.position.set(0, 15, 30);
      _camera.target.set(0, 5, 0);
    }
    _camera.saveHome();
  }

  void _setupStatic() {
    _clearScene();
    _mode = 'static';
    _subState = 0;
    final comb = _add('comb', _createComb())..position.set(0, 5, 0);
    final bits = _rt_Node3D(name: 'bits');
    final bitGeo = _rt_Geometry3D.plane(0.4, 0.4);
    final bitMat = _rt_Material3D(color: Colors.white, unlit: true, doubleSided: true);
    for (var i = 0; i < 30; i++) {
      bits.add(_rt_Mesh3D(bitGeo, bitMat)
        ..rotation.x = -math.pi / 2
        ..position.set((_rng.nextDouble() - 0.5) * 6, 0.1, (_rng.nextDouble() - 0.5) * 4));
    }
    _add('bits', bits);
    _addLabel(comb, 'comb');
  }

  void _setupDischarge(bool isCanal) {
    _clearScene();
    _mode = isCanal ? 'canal' : 'cathode';
    _subState = 0;
    _deflect = null;

    _add('stand', _rt_Mesh3D(_rt_Geometry3D.box(4, 8, 2), _rt_Material3D(color: const Color(0xFF333333)))..position.set(0, 4, 0));

    final tube = _add('tube', _createDischargeTube(isCanal))..position.set(0, 9, 0);
    tube.userData['type'] = isCanal ? 'canal' : 'standard';

    // Rays & Particles
    final cRay = _add(
        'cRay',
        _rt_Mesh3D(_rt_Geometry3D.cylinder(0.5, 0.1, 10, segments: 16),
            _rt_Material3D(color: const Color(0xFF00FF00), opacity: 0, unlit: true)))
      ..rotation.z = math.pi / 2
      ..position.set(0, 9, 0);
    cRay.pickable = false;
    final nRay = _add(
        'nRay',
        _rt_Mesh3D(_rt_Geometry3D.cylinder(0.1, 0.8, 4, segments: 16),
            _rt_Material3D(color: const Color(0xFFFF0000), opacity: 0, unlit: true)))
      ..rotation.z = math.pi / 2
      ..position.set(-8, 9, 0);
    nRay.pickable = false;

    // Electrons (neon green "-" sprites).
    final eFlow = _rt_Node3D(name: 'eFlow')..position.set(0, 9, 0);
    final eMat = _rt_Material3D(color: const Color(0xFF39FF14), unlit: true, edgeColor: Colors.white, edgeWidth: 1);
    for (var i = 0; i < 150; i++) {
      eFlow.add(_rt_Sphere3D(0.28, eMat)
        ..position.set((_rng.nextDouble() - 0.5) * 10, (_rng.nextDouble() - 0.5) * 0.5, (_rng.nextDouble() - 0.5) * 0.5)
        ..depthBias = -50
        ..pickable = false);
    }
    eFlow.visible = false;
    _add('eFlow', eFlow);

    // Protons
    final pFlow = _rt_Node3D(name: 'pFlow')..position.set(0, 8.5, 0);
    final pMat = _rt_Material3D(color: const Color(0xFFFF4444), unlit: true);
    for (var i = 0; i < 60; i++) {
      pFlow.add(_rt_Sphere3D(0.12, pMat)
        ..position.set((_rng.nextDouble() - 0.5) * 10, (_rng.nextDouble() - 0.5) * 0.5, (_rng.nextDouble() - 0.5) * 0.5)
        ..depthBias = -50
        ..pickable = false);
    }
    pFlow.visible = false;
    _add('pFlow', pFlow);

    // Labels & Extras
    final anodeObj = tube.find('Anode');
    final cathodeObj = tube.find('Cathode');
    if (anodeObj != null) _addLabel(anodeObj, 'anode');
    if (cathodeObj != null) _addLabel(cathodeObj, 'cathode', left: true);

    // Coil Box
    final coil = _add('coil', _rt_Mesh3D(_rt_Geometry3D.box(4, 3, 4), _rt_Material3D(color: const Color(0xFF1E293B))))
      ..position.set(8, 1.5, 5);
    _addLabel(coil, 'coil');
    _addLabel(tube, isCanal ? 'tubeCanal' : 'tube', anchorOffset: _rt_V3(0, 2.2, 0));

    // --- CONNECTION WIRES ---
    // Cathode Wire (Black/Negative): Cathode (-5.5, 9, 0) -> Coil.
    _wire1Path = _catmullRom([_rt_V3(-5.5, 9, 0), _rt_V3(-7, 8, 0), _rt_V3(-7, 1.5, 5), _rt_V3(6, 1.5, 5)], 40);
    _add('wire1', _rt_Line3D(List.of(_wire1Path), color: const Color(0xFF222222), width: 2.5));
    // Anode Wire (Red/Positive): Anode (5.5, 9, 0) -> Coil.
    _wire2Path = _catmullRom([_rt_V3(5.5, 9, 0), _rt_V3(7, 8, 0), _rt_V3(7, 1.5, 5), _rt_V3(10, 1.5, 5)], 40);
    _add('wire2', _rt_Line3D(List.of(_wire2Path), color: const Color(0xFFCC0000), width: 2.5));

    // Vacuum Pump
    final pump = _add('pump', _createVacuumPump())..position.set(-8, 1.5, 5);
    _addLabel(pump, 'pump');
  }

  void _addPlate(String type) {
    _items.remove('plate')?.removeFromParent();
    _labels.removeWhere((l) {
      final p = l.key == 'plus' || l.key == 'minus';
      if (p) {
        l.label.removeFromParent();
        l.leader.removeFromParent();
      }
      return p;
    });
    final positive = type == 'positive';
    final plate = _add(
        'plate',
        _rt_Mesh3D(_rt_Geometry3D.box(4, 0.5, 4),
            _rt_Material3D(color: positive ? const Color(0xFFFF0000) : const Color(0xFF0000FF)),
            name: 'DeflectionPlate'))
      ..position.set(0, positive ? 13 : 5, 0); // Top or Bottom
    _addLabel(plate, positive ? 'plus' : 'minus');
  }

  void _setupMass() {
    _clearScene();
    _mode = 'mass';
    _subState = 0;
    _electronCount = 0;
    _add('scale', _createBalanceScale());
    _add('leftPan', _createPan());
    _add('rightPan', _createPan());
    _add('proton', _rt_Sphere3D(1, _rt_Material3D(color: const Color(0xFF3B82F6), shininess: 0.4)));
    _add('pile', _rt_Sphere3D(1, _rt_Material3D(color: const Color(0xFFFACC15), shininess: 0.4)))
      ..scale.set(0, 0, 0)
      ..visible = false;
    _updateMassScene(1);
  }

  void _setupAtom() {
    _clearScene();
    _mode = 'atom';
    final atom = _add('atom', _createAtomModel())..position.set(0, 5, 0);
    _addLabel(atom, 'atom');
  }

  // ---------------------------------------------------------- animate ---
  void _onFrame(double dt) {
    _tweens.update(dt);
    final open = _shell.isSidebarOpen;
    if (open != _sidebarOpen && mounted) setState(() => _sidebarOpen = open);
    _time += dt * 2; // Date.now() * 0.002
    final k = dt * 60; // per-frame increments assume 60 fps

    if (_mode == 'static_active') {
      final comb = _items['comb'];
      final bits = _items['bits'];
      if (comb != null && bits != null) {
        comb.position.x = math.sin(_time * 5) * 2;
        final f = 1 - math.pow(0.9, k).toDouble();
        for (final bit in bits.children) {
          final target = (comb.position.x - bit.position.x).abs() < 2 ? 4.0 : 0.1;
          bit.position.y += (target - bit.position.y) * f;
        }
      }
    }

    // Wire Animation Logic
    if (_animatingWires) {
      _wireProgress += 0.02 * k;
      final progress = math.min(_wireProgress, 1.0);
      final w1 = _items['wire1'], w2 = _items['wire2'];
      if (w1 is _rt_Line3D) w1.points = _wire1Path.sublist(0, (_wire1Path.length * progress).floor());
      if (w2 is _rt_Line3D) w2.points = _wire2Path.sublist(0, (_wire2Path.length * progress).floor());
      if (progress >= 1) {
        _animatingWires = false;
        Future.microtask(_completeStep);
      }
    }

    // Cathode Swap Animation
    if (_animatingSwap) {
      _swapProgress += 0.02 * k;
      final p = _swapProgress;
      final tube = _items['tube'];
      if (tube != null) {
        var cathode = tube.find('Cathode');
        if (p < 0.5) {
          // Phase 1: Shrink old
          cathode?.scale.set(1 - p * 2, 1 - p * 2, 1 - p * 2);
        } else if (!_swapped) {
          // Swap moment
          cathode?.removeFromParent();
          final newC = _createCathode(true)..scale.set(0, 0, 0);
          tube.add(newC);
          for (final l in _labels) {
            if (l.key == 'cathode') l.obj = newC;
          }
          // Important: update tube type so Step 7 doesn't reset.
          tube.userData['type'] = 'canal';
          _swapped = true;
        } else {
          // Phase 2: Grow new
          cathode = tube.find('Cathode');
          final s = ((p - 0.5) * 2).clamp(0.0, 1.0);
          cathode?.scale.set(s, s, s);
        }
      }
      if (p >= 1) {
        _animatingSwap = false;
        Future.microtask(_completeStep);
      }
    }

    // Ray Logic
    final cRay = _items['cRay'];
    if (cRay is _rt_Mesh3D) {
      final eFlow = _items['eFlow'];
      final pFlow = _items['pFlow'];
      final nRay = _items['nRay'];
      if (_subState == 2) {
        cRay.visible = true;
        cRay.material.opacity = 0.4 + math.sin(_time * 15) * 0.1;
        final anode = _items['tube']?.find('Anode');
        if (anode is _rt_Mesh3D) {
          anode.material.emissive = const Color(0xFF39FF14);
          anode.material.emissiveIntensity = 0.8 + math.sin(_time * 20) * 0.2;
        }
        if (eFlow != null) {
          eFlow.visible = true;
          for (final e in eFlow.children) {
            final pos = e.position;
            pos.x += 0.3 * k; // Move Right
            // BENDING LOGIC (Step 5)
            if (_deflect == 'up' && pos.x > -2 && pos.x < 2) pos.y += 0.1 * k;
            if (pos.x > 5.5 || pos.y > 3) {
              pos.x = -5.5;
              pos.y = (_rng.nextDouble() - 0.5) * 0.5;
            }
          }
        }
        if (pFlow != null && _mode == 'canal') {
          pFlow.visible = true;
          if (nRay is _rt_Mesh3D) {
            nRay.visible = true;
            nRay.material.opacity = 0.35 + math.sin(_time * 15) * 0.1;
          }
          for (final pr in pFlow.children) {
            final pos = pr.position;
            pos.x -= 0.4 * k; // Move Left
            // BENDING LOGIC (Step 8)
            if (_deflect == 'down' && pos.x > -2 && pos.x < 2) pos.y -= 0.1 * k;
            if (pos.x < -7 || pos.y < -3) {
              pos.x = 5;
              pos.y = (_rng.nextDouble() - 0.5) * 0.5;
            }
          }
        } else {
          pFlow?.visible = false;
          nRay?.visible = false;
        }
      } else {
        cRay.visible = false;
        eFlow?.visible = false;
        pFlow?.visible = false;
        nRay?.visible = false;
      }
    }

    // Atom Animation
    final atom = _items['atom'];
    if (atom != null) {
      final electrons = atom.userData['electrons'] as _rt_Node3D?;
      if (electrons != null) {
        for (var i = 0; i < electrons.children.length; i++) {
          final e = electrons.children[i];
          final a = (e.userData['angle'] as double) + (0.02 + i * 0.01) * k;
          e.userData['angle'] = a;
          e.position.x = 5 * math.cos(a);
          e.position.z = 5 * math.sin(a);
        }
      }
    }

    // Mass logic
    if (_mode == 'mass') _updateMassScene(1 - math.pow(0.95, k).toDouble());

    // Label update logic (follow objects).
    _positionLabels();
  }

  void _updateMassScene(double lerp) {
    final beam = _items['beam'];
    final leftPan = _items['leftPan'];
    final rightPan = _items['rightPan'];
    final proton = _items['proton'];
    final pile = _items['pile'];
    if (beam == null || leftPan == null || rightPan == null || proton == null || pile == null) return;
    final diff = 1840 - _electronCount;
    // Heavier side goes down: proton (left) heavier -> beam tilts left-down.
    var targetAngle = 0.0;
    if (diff > 50) {
      targetAngle = 0.3;
    } else if (diff < -50) {
      targetAngle = -0.3;
    }
    beam.rotation.z += (targetAngle - beam.rotation.z) * lerp;
    final theta = beam.rotation.z;
    leftPan.position.set(-7 * math.cos(theta), 10 - 7 * math.sin(theta), 0);
    proton.position.set(leftPan.position.x, leftPan.position.y - 5.5, 0);
    rightPan.position.set(7 * math.cos(theta), 10 + 7 * math.sin(theta), 0);
    pile.position.set(rightPan.position.x, rightPan.position.y - 5.5, 0);
    final s = (_electronCount / 2000).clamp(0.1, 1.2);
    if (_electronCount == 0) {
      pile.visible = false;
    } else {
      pile.visible = true;
      pile.scale.set(s, s, s);
    }
  }

  void _onCanvasTap(_rt_SceneEvent e) {
    if (_currentStepIdx != 9) return; // Only Step 10 (index 9)
    final obj = e.hitWhere((n) => n.userData['type'] != null);
    if (obj == null) return;
    if (obj.userData['type'] == 'electron') {
      obj.visible = false;
      _rt_playSfx(_rt_Sfx.pop);
      // Respawn after delay
      Future.delayed(const Duration(milliseconds: 2000), () {
        if (!mounted) return;
        obj.visible = true;
      });
    } else if (obj.userData['type'] == 'proton') {
      // Shake nucleus
      _rt_playSfx(_rt_Sfx.click);
      final nucleus = _items['atom']?.userData['nucleus'] as _rt_Node3D?;
      if (nucleus != null) {
        _tweens.run(300, (t) => nucleus.position.x = math.sin(t * math.pi * 6) * 0.15 * (1 - t),
            ease: _rt_Ease.linear);
      }
    }
  }

  // ---------------------------------------------------------------- UI ---
  List<dynamic> get _steps => _tx.list('steps');

  void _updateVacuum(double val) {
    setState(() {
      _vacuum = val;
      // Threshold at 10%
      _subState = val < 10 ? 1 : 0;
    });
  }

  Future<void> _startPump() async {
    _rt_playSfx(_rt_Sfx.magic, volume: 0.5);
    final start = _vacuum;
    await _tweens.run(1500, (t) {
      if (!mounted || _currentStepIdx != 2) return;
      _updateVacuum(start * (1 - t));
    });
  }

  /// Sidebar "Pump Vacuum": pumps down (as "Start Pump" does) before the
  /// vacuum step can complete.
  Future<void> _pumpThenComplete() async {
    setState(() => _pumping = true);
    await _startPump();
    if (!mounted) return;
    setState(() => _pumping = false);
    if (_currentStepIdx == 2 && _vacuum < 10) _completeStep();
  }

  void _updateMass(double val) {
    setState(() => _electronCount = val.round());
  }

  bool get _massOk => _electronCount >= 1800 && _electronCount <= 1880;

  void _verifyMass() {
    _rt_playSfx(_rt_Sfx.magic);
    _completeStep();
  }

  void _addCharge(String type) {
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _charge += type == 'p' ? 1 : -1);
    if (_charge == 0) _rt_playSfx(_rt_Sfx.correct);
  }

  Future<void> _completeStep() async {
    if (!mounted || _modalOpen) return;
    _modalOpen = true;
    final idx = _currentStepIdx;
    final step = _steps[idx] as Map;
    await _shell.showSuccess(
      title: _tx.s('ui.stepComplete'),
      message: (step['successMsg'] as String?) ?? _tx.s('ui.stepCompleted'),
      buttonLabel: _tx.s('ui.continue'),
      icon: Icons.check_circle,
      color: _rt_Tw.amber500,
      sound: _rt_Sfx.correct,
    );
    if (!mounted) return;
    // Discovery observation cards (electron after step 4, proton after step 7).
    if (idx == 3 || idx == 6) await _showCard(idx == 3 ? 'e' : 'p');
    if (!mounted) return;
    _modalOpen = false;
    _nextStep();
  }

  Future<void> _showCard(String key) {
    _rt_playSfx(_rt_Sfx.magic);
    return _rt_showShellPopup(
      context,
      title: _tx.s('cards.$key.title'),
      message: _tx.s('cards.$key.desc'),
      icon: Icons.person,
      color: _rt_Tw.blue500,
      buttonLabel: _tx.s('ui.closeObs'),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _rt_Tw.slate800,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _rt_Tw.blue500, width: 2),
        ),
        child: Text(_tx.s('cards.$key.name'),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 12)),
      ),
    );
  }

  void _nextStep() {
    if (_currentStepIdx < 11) {
      setState(() {
        _currentStepIdx++;
        _loadStep(_currentStepIdx);
      });
    } else {
      _showCompletion();
    }
  }

  Future<void> _showCompletion() async {
    if (_modalOpen) return;
    _modalOpen = true;
    _rt_playSfx(_rt_Sfx.success);
    await _rt_showShellPopup(
      context,
      title: _tx.s('ui.completeTitle'),
      message: _tx.s('ui.completeMsg'),
      icon: Icons.workspace_premium,
      color: _rt_Tw.amber500,
      actions: [
        Builder(
          builder: (ctx) => _rt_ActionButton(
            label: _tx.s('ui.restart'),
            icon: Icons.refresh,
            color: _rt_Tw.teal600,
            onPressed: () {
              Navigator.of(ctx).pop();
              _restartLab();
            },
          ),
        ),
      ],
    );
    _modalOpen = false;
  }

  void _handleMainAction() {
    if (_modalOpen || _animatingWires || _animatingSwap || _pumping) return;
    // Step 3: Vacuum -- run the pump first while the pressure is still high.
    if (_currentStepIdx == 2 && _vacuum >= 10) {
      _pumpThenComplete();
      return;
    }
    // Step 1: Static (need to activate first)
    if (_currentStepIdx == 0 && _mode == 'static') {
      setState(() {
        _mode = 'static_active';
        _mainBtnKey = 'nextStep';
      });
      return;
    }
    // Step 2: Assemble Animation
    if (_currentStepIdx == 1 && _waitingForAssembly) {
      setState(() {
        _waitingForAssembly = false;
        _animatingWires = true;
        _wireProgress = 0;
        _mainBtnKey = 'assembling';
      });
      return; // Don't complete step yet
    }
    // Step 6: Swap Cathode Animation
    if (_currentStepIdx == 5 && _waitingForSwap) {
      setState(() {
        _waitingForSwap = false;
        _animatingSwap = true;
        _swapProgress = 0;
        _swapped = false;
        _mainBtnKey = 'swapping';
      });
      _rt_playSfx(_rt_Sfx.magic);
      return; // Don't complete step yet
    }
    // Steps that auto-complete via main button (Mass and Neutrality handle their own completion).
    if (_currentStepIdx != 8 && _currentStepIdx != 10) _completeStep();
  }

  void _goToStep(int i) {
    if (_modalOpen || i >= _currentStepIdx) return;
    _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _currentStepIdx = i;
      _loadStep(i);
    });
  }

  void _restartLab() {
    _tweens.cancelAll();
    _camera.reset();
    _camera.autoRotate = false;
    setState(() {
      _modalOpen = false;
      _currentStepIdx = 0;
      _loadStep(0);
    });
  }

  String get _mainBtnText =>
      _mainBtnKey != null ? _tx.s('ui.$_mainBtnKey') : (_steps[_currentStepIdx]['action'] as String);

  bool get _fabHidden => _currentStepIdx == 8 || _currentStepIdx == 10;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: _rt_LangBuilder(builder: (context, lang) {
        _viewH = MediaQuery.sizeOf(context).height;
        _updateLabelTexts();
        final step = _steps[_currentStepIdx] as Map;
        return _rt_ActivityShell(
          controller: _shell,
          title: _tx.s('title'),
          subtitle: _tx.s('subtitle'),
          theme: const _rt_ShellTheme(
            accent: _rt_Tw.blue500,
            headerGradient: [_rt_Tw.slate900, _rt_Tw.blue900],
            headerSubtitleColor: _rt_Tw.amber500,
          ),
          canvasBackground: _rt_Tw.slate950,
          intro: _rt_IntroConfig(
            title: _tx.s('intro.title'),
            subtitle: _tx.s('intro.subtitle'),
            buttonLabel: _tx.s('intro.button'),
            icon: Icons.blur_circular,
            buttonIcon: Icons.login,
          ),
          onRestart: _restartLab,
          onZoomIn: _camera.zoomIn,
          onZoomOut: _camera.zoomOut,
          onResetView: _camera.reset,
          toolbarExtras: [
            _rt_RotatePanToggle(controller: _viewCtrl, accent: _rt_Tw.blue500),
            const SizedBox(height: 4),
            _toolButton(Icons.sync, _tx.s('ui.autoRotate'), _camera.autoRotate, () {
              setState(() => _camera.autoRotate = !_camera.autoRotate);
            }),
            const SizedBox(height: 4),
            _toolButton(Icons.sell, _tx.s('ui.labels'), _showLabels, () {
              setState(() => _showLabels = !_showLabels);
            }),
          ],
          hint: _fabHidden
              ? null
              : _rt_StepHint(
                  number: '${_currentStepIdx + 1}',
                  text: step['title'] as String,
                  label: _tx.s('hudLabel'),
                ),
          initialTab: 1,
          tabs: [
            _rt_ShellTab(label: _tx.s('tabs.explore'), icon: Icons.science, builder: (_) => _exploreTab()),
          ],
          canvas: _rt_Scene3DView(
            scene: _scene,
            camera: _camera,
            controller: _viewCtrl,
            onFrame: _onFrame,
            onTap: _onCanvasTap,
          ),
          canvasOverlays: [
            if (_currentStepIdx == 2)
              Positioned(right: 66, bottom: _sidebarOpen ? 16 : 84, child: _vacuumOverlay()),
            if (_currentStepIdx == 8)
              Positioned(left: 8, right: 8, bottom: 10, child: Center(child: _massControls())),
            if (_currentStepIdx == 10)
              Positioned(left: 8, right: 8, bottom: 10, child: Center(child: _neutralOverlay())),
          ],
        );
      }),
    );
  }

  Widget _toolButton(IconData icon, String tip, bool active, VoidCallback onTap) {
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
          decoration: BoxDecoration(color: active ? _rt_Tw.amber500 : Colors.white, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: active ? Colors.white : _rt_Tw.gray500),
        ),
      ),
    );
  }

  // --- canvas panels ---
  BoxDecoration get _panelDeco => BoxDecoration(
        color: _rt_Tw.slate900.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rt_Tw.blue500),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)],
      );

  Widget _vacuumOverlay() {
    final torr = math.max(0.01, _vacuum / 100 * 760);
    final low = _vacuum < 10;
    return Container(
      width: 220,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: _panelDeco,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(_tx.s('ui.vacTitle').toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1)),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 4,
            activeTrackColor: _rt_Tw.blue500,
            inactiveTrackColor: _rt_Tw.slate700,
            thumbColor: _rt_Tw.yellow400,
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            key: const ValueKey('vacSlider'),
            value: _vacuum,
            min: 0,
            max: 100,
            onChanged: _updateVacuum,
            onChangeEnd: (_) => _rt_playSfx(_rt_Sfx.tap, volume: 0.6),
          ),
        ),
        Row(children: [
          Text(_tx.s('ui.torrLow'),
              style: const TextStyle(color: _rt_Tw.green400, fontSize: 10, fontFamily: 'monospace')),
          const Spacer(),
          Text(_tx.s('ui.torrHigh'), style: const TextStyle(color: _rt_Tw.red400, fontSize: 10, fontFamily: 'monospace')),
        ]),
        const SizedBox(height: 4),
        Text('${_tx.s('ui.pressure')}: ${torr < 1 ? torr.toStringAsFixed(2) : torr.toStringAsFixed(0)} torr',
            style: TextStyle(
                color: low ? _rt_Tw.green400 : _rt_Tw.slate300,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                fontFamily: 'monospace')),
        if (low)
          Text(_tx.s('ui.lowPressure'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: _rt_Tw.green400, fontSize: 10, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        _rt_ActionButton(
          label: _tx.s('pumpButton'),
          icon: Icons.air,
          color: _rt_Tw.blue600,
          onPressed: _vacuum <= 0 ? null : _startPump,
        ),
      ]),
    );
  }

  Widget _massControls() {
    const mono = TextStyle(color: _rt_Tw.slate500, fontSize: 9, fontFamily: 'monospace');
    return Container(
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      decoration: _panelDeco,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.balance, color: _rt_Tw.amber500, size: 15),
          const SizedBox(width: 6),
          Flexible(
            child: Text(_tx.s('ui.massTitle').toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
          ),
        ]),
        Text(_tx.s('ui.massDesc'),
            textAlign: TextAlign.center, style: const TextStyle(color: _rt_Tw.slate400, fontSize: 9.5)),
        Row(children: [
          const Text('0', style: mono),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                activeTrackColor: _rt_Tw.amber500,
                inactiveTrackColor: _rt_Tw.slate700,
                thumbColor: _rt_Tw.yellow400,
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: SizedBox(
                height: 28,
                child: Slider(
                  key: const ValueKey('massSlider'),
                  value: _electronCount.toDouble(),
                  min: 0,
                  max: 2500,
                  onChanged: _updateMass,
                  onChangeEnd: (_) => _rt_playSfx(_rt_Sfx.tap, volume: 0.6),
                ),
              ),
            ),
          ),
          const Text('2500', style: mono),
        ]),
        Row(children: [
          Text.rich(
            TextSpan(children: [
              TextSpan(
                  text: '$_electronCount ',
                  style: const TextStyle(
                      color: _rt_Tw.amber500, fontSize: 17, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
              const TextSpan(text: 'e⁻', style: TextStyle(color: _rt_Tw.slate500, fontSize: 11)),
            ]),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _rt_ActionButton(
              label: _tx.s('ui.verify'),
              icon: Icons.check_circle,
              color: _rt_Tw.green600,
              expand: true,
              sound: null,
              onPressed: _massOk ? _verifyMass : null,
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _neutralOverlay() {
    final val = _charge;
    final color = val == 0 ? _rt_Tw.green400 : (val > 0 ? _rt_Tw.red500 : _rt_Tw.blue500);
    final text = val == 0 ? _tx.s('ui.neutral') : (val > 0 ? '+$val' : '$val');
    // Centre is 50%; max range +/- 10, constrained between 5% and 95%.
    final pct = (50 + val * 5).clamp(5, 95) / 100;
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      decoration: _panelDeco,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(_tx.s('ui.neutralTitle'),
            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
        Text(_tx.s('ui.neutralDesc'),
            textAlign: TextAlign.center, style: const TextStyle(color: _rt_Tw.slate400, fontSize: 10)),
        const SizedBox(height: 8),
        LayoutBuilder(builder: (context, c) {
          final w = math.min(c.maxWidth, 256.0);
          return Container(
            width: w,
            height: 24,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: _rt_Tw.slate800,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white24),
            ),
            child: Stack(children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(children: [
                    Text(_tx.s('ui.neg'),
                        style: const TextStyle(color: _rt_Tw.slate500, fontSize: 10, fontFamily: 'monospace')),
                    const Spacer(),
                    Text(_tx.s('ui.pos'),
                        style: const TextStyle(color: _rt_Tw.slate500, fontSize: 10, fontFamily: 'monospace')),
                  ]),
                ),
              ),
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                left: w * pct - 4,
                top: 0,
                bottom: 0,
                width: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    boxShadow: [BoxShadow(color: color, blurRadius: 12)],
                  ),
                ),
              ),
            ]),
          );
        }),
        const SizedBox(height: 8),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _chargeButton('addElectron', '-', _rt_Tw.green500, () => _addCharge('e')),
          const SizedBox(width: 14),
          AnimatedScale(
            key: ValueKey('net$val'),
            duration: const Duration(milliseconds: 200),
            scale: val == 0 ? 1.1 : 1,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 1.5, end: 1),
              duration: const Duration(milliseconds: 200),
              builder: (context, s, child) => Transform.scale(scale: s, child: child),
              child: Text(text,
                  style: TextStyle(
                      color: val == 0 ? _rt_Tw.green400 : (val > 0 ? _rt_Tw.red400 : _rt_Tw.blue400),
                      fontSize: val == 0 ? 22 : 20,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'monospace')),
            ),
          ),
          const SizedBox(width: 14),
          _chargeButton('addProton', '+', _rt_Tw.red500, () => _addCharge('p')),
        ]),
        if (val == 0) ...[
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: _rt_ActionButton(
              label: _tx.s('ui.finish'),
              icon: Icons.arrow_forward,
              color: _rt_Tw.blue500,
              expand: true,
              onPressed: _completeStep,
            ),
          ),
        ],
      ]),
    );
  }

  Widget _chargeButton(String key, String sign, Color color, VoidCallback onTap) {
    return Tooltip(
      message: _tx.s('ui.$key'),
      child: Material(
        key: ValueKey(key),
        color: color,
        shape: const CircleBorder(side: BorderSide(color: Colors.white24, width: 2)),
        elevation: 3,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: Text(sign,
                  style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            ),
          ),
        ),
      ),
    );
  }

  // --- sidebar tabs ---
  // ignore: unused_element — kept for reference; tab removed from sidebar
  Widget _whyTab() {
    IconData icon(String k) => switch (k) {
          'tv' => Icons.tv,
          'bolt' => Icons.bolt,
          _ => Icons.thunderstorm,
        };
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        for (final item in _tx.list('whyToLearn'))
          _rt_InfoCard(
            title: item['title'] as String,
            body: item['desc'] as String,
            icon: icon(item['icon'] as String),
            color: _rt_Tw.amber600,
          ),
      ]),
    );
  }

  Widget _exploreTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_SectionLabel(_tx.s('runbook'), color: _rt_Tw.blue600, icon: Icons.menu_book),
          for (var i = 0; i < _steps.length; i++) _stepTile(i, _steps[i] as Map),
        ],
      ),
    );
  }

  Widget _stepTile(int i, Map s) {
    final isActive = i == _currentStepIdx;
    final isPast = i < _currentStepIdx;
    final isFuture = i > _currentStepIdx;
    final busy = _animatingWires || _animatingSwap || _pumping;
    final tile = AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isActive ? _rt_Tw.blue50 : (isFuture ? _rt_Tw.slate100 : Colors.white),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isActive ? _rt_Tw.blue500 : _rt_Tw.slate200, width: isActive ? 2 : 1),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? _rt_Tw.blue500 : (isPast ? _rt_Tw.green500 : _rt_Tw.slate300),
            shape: BoxShape.circle,
          ),
          child: isPast
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : isFuture
                  ? const Icon(Icons.lock, size: 11, color: _rt_Tw.slate500)
                  : Text('${i + 1}',
                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(s['title'] as String,
                style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: isActive ? _rt_Tw.slate800 : _rt_Tw.slate600)),
            const SizedBox(height: 2),
            Text(s['desc'] as String, style: const TextStyle(fontSize: 11, color: _rt_Tw.slate500, height: 1.3)),
            if (isActive) ...[
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _rt_Tw.blue100),
                ),
                child: Text('${_tx.s('ui.hint')}: ${s['hint']}',
                    style: const TextStyle(fontSize: 10.5, color: _rt_Tw.slate500, fontStyle: FontStyle.italic)),
              ),
              const SizedBox(height: 8),
              if (_fabHidden)
                Row(children: [
                  const Icon(Icons.touch_app, size: 14, color: _rt_Tw.amber600),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(_tx.s('ui.useControls'),
                        style: const TextStyle(fontSize: 10.5, color: _rt_Tw.amber700, fontWeight: FontWeight.w700)),
                  ),
                ])
              else
                _rt_ActionButton(
                  label: _mainBtnText,
                  icon: _mainBtnKey == 'nextStep' ? Icons.arrow_forward : Icons.play_arrow,
                  color: _rt_Tw.blue500,
                  onPressed: busy || _modalOpen ? null : _handleMainAction,
                ),
            ],
          ]),
        ),
      ]),
    );
    return Opacity(
      opacity: isFuture ? 0.45 : (isPast ? 0.75 : 1),
      child: isPast
          ? InkWell(borderRadius: BorderRadius.circular(10), onTap: () => _goToStep(i), child: tile)
          : tile,
    );
  }

  // ignore: unused_element — kept for reference; tab removed from sidebar
  Widget _postTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Icon(Icons.workspace_premium, size: 40, color: _rt_Tw.amber500),
        const SizedBox(height: 4),
        Text(_tx.s('complete'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: _rt_Tw.slate800)),
        const SizedBox(height: 4),
        Text(_tx.s('postActivity.summary'),
            textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: _rt_Tw.slate500)),
        const SizedBox(height: 12),
        _rt_InfoCard(
          title: _tx.s('takeaways'),
          color: _rt_Tw.blue600,
          child: Column(children: [
            for (final p in _tx.list('postActivity.points'))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check, size: 14, color: _rt_Tw.green500),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text.rich(TextSpan(children: [
                      TextSpan(text: '${p['b']} ', style: const TextStyle(fontWeight: FontWeight.w800)),
                      TextSpan(text: p['t'] as String),
                    ]), style: const TextStyle(fontSize: 12, color: _rt_Tw.slate700, height: 1.35)),
                  ),
                ]),
              ),
          ]),
        ),
      ]),
    );
  }
}
