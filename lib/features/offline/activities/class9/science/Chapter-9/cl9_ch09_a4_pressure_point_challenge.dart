// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// The Pressure Point Challenge
// Converted from Cl9S-Ch9-A4-The_Pressure_Point_Challenge.html (three.js -> mini3d).




// --- TRANSLATION DATA (DATA) ---

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
    'intro': {'title': 'Pressure Point', 'subtitle': 'Class 9 • Gravitation', 'button': 'Enter _rt_Lab'},
    'title': 'The Pressure Point Challenge',
    'subtitle': 'Class 9 • Gravitation',
    'tabs': {'why': 'Why Learn?', 'explore': 'Explore', 'outcomes': 'Outcomes'},
    'protocol': 'WORKFLOW',
    'conclusion': 'Final Conclusion',
    'submit_def': 'Check Answer',
    'success': 'Success!',
    'success_msg': 'You have verified that smaller area leads to higher pressure.',
    'restart': 'RESTART LAB',
    'labels': {'block': '5kg Wooden Block', 'tray': 'Sand Pit', 'scale': 'Digital Scale'},
    'gauge': 'GAUGE',
    'thrust_label': 'Thrust (F)',
    'area_label': 'Area (A)',
    'area_word': 'Area',
    'depth': 'Depth',
    'pressure': 'Pressure',
    'high': 'HIGH',
    'low': 'LOW',
    'ready': 'READY',
    'sinking': 'SINKING',
    'calculated': 'CALCULATED',
    'outcome': 'OUTCOME',
    'instruction': 'INSTRUCTION',
    'welcome': 'Welcome to the _rt_Lab',
    'rotate_vert': 'ROTATE VERTICAL',
    'rotate_horiz': 'ROTATE HORIZONTAL',
    'reset_sand': 'RESET SAND',
    'calc_press': 'Calculate Pressure',
    'force_label': 'Force (N)',
    'area_input': 'Area (m²)',
    'formula': 'Formula',
    'calc_btn': 'Calculate',
    'try_again': 'Try again',
    'correct_msg': 'Correct!',
    'pin_label': '1 PIN',
    'pins_label': '100 PINS',
    'pop_label': 'POP!',
    'safe_label': 'SAFE',
    'sharp_knife': 'SHARP KNIFE',
    'blunt_knife': 'BLUNT KNIFE',
    'narrow_tires': 'NARROW TIRES',
    'wide_tires': 'WIDE TIRES',
    'cut': 'CUT',
    'no_cut': 'NO CUT',
    'float': 'FLOAT',
    'sink': 'SINK',
    'hint_wrong': 'Hint: Inverse means opposite.',
    'sentence': ['Pressure is ', '{1}', ' proportional to ', '{2}', ' for a constant force.'],
    'words': [
      {'id': 'directly', 'text': 'Directly'},
      {'id': 'inversely', 'text': 'Inversely'},
      {'id': 'area', 'text': 'Area'},
      {'id': 'volume', 'text': 'Volume'},
      {'id': 'Pa', 'text': 'Pa'},
      {'id': 'N', 'text': 'N'},
    ],
    'drag_hint': 'Drag (or tap) the words into the blanks.',
    'feedback_err': 'Incorrect. Think about P = F / A.',
    'feedback_ok': 'Correct! P = F / A.',
    'tools': {'lock': 'Unlock Camera', 'unlock': 'Lock Camera', 'labels': 'Toggle Labels'},
    'assist': {
      'place': 'Auto-place',
      'weigh': 'Place on Scale',
      'drop': 'Release Block',
      'calc': 'Open Calculator',
      'conclude': 'Open Conclusion',
    },
    'why_learn': [
      {
        'icon': 'ski',
        'title': 'Snowshoes',
        'desc': 'Flat snowshoes distribute weight over a large area, preventing sinking.',
      },
      {'icon': 'tack', 'title': 'Sharp Nails', 'desc': 'A tiny tip area creates huge pressure to drive into wood.'},
      {
        'icon': 'truck',
        'title': 'Heavy Trucks',
        'desc': 'Wide tires increase contact area, reducing pressure on roads.',
      },
    ],
    'outcomes_title': 'Learning Outcomes',
    'outcomes': [
      {
        'title': '1. Concept Mastery',
        'desc':
            'We learned that Pressure is the force applied perpendicular to the surface of an object per unit area. The formula is P = F / A.',
      },
      {
        'title': '2. The Relationship',
        'desc':
            'We understood that Pressure and Area are inversely proportional. If you keep the Force (Thrust) constant but decrease the Area, the Pressure increases drastically.',
      },
      {
        'title': '3. Experimental Proof',
        'desc':
            'In the lab, the 5kg block exerted the same 49N thrust in both cases. However, standing it vertically (small area) created 2450 Pa of pressure, causing it to sink deep. Laying it flat (large area) created only 612.5 Pa, causing it to float on top.',
      },
      {
        'title': '4. Real World Grip',
        'desc':
            "This is why a sharp knife cuts easily (tiny area = huge pressure) and why camels have wide feet (large area = low pressure, don't sink in sand).",
      },
    ],
    'steps': [
      {
        't': '1. Initialization',
        'd': 'Drag Sand Tray and Block to center one by one.',
        'outcome': 'Setup Complete. Ready for experiment.',
      },
      {'t': '2. Weighing', 'd': 'Drag Block onto the Digital Scale.', 'outcome': 'Mass: 5kg. Thrust (Weight): 49N.'},
      {
        't': '3. Orientation A',
        'd': 'Click button to rotate Block vertical (20×10 cm).',
        'outcome': 'Area = 0.02 m². High Pressure config.',
      },
      {
        't': '4. The Drop',
        'd': 'Click the Block to release it into sand.',
        'outcome': 'Block sinks DEEP (>5cm). High Impact.',
      },
      {'t': '5. Calculation A', 'd': 'Calculate P = 49 / 0.02.', 'outcome': 'Pressure = 2450 Pascal (Pa).'},
      {
        't': '6. Orientation B',
        'd': 'Click Reset Sand then Rotate Block horizontal.',
        'outcome': 'Area = 0.08 m². Low Pressure config.',
      },
      {
        't': '7. The Drop',
        'd': 'Click the Block to release it again.',
        'outcome': 'Block sinks SHALLOW (<1cm). Low Impact.',
      },
      {'t': '8. Calculation B', 'd': 'Calculate P = 49 / 0.08.', 'outcome': 'Pressure = 612.5 Pascal (Pa).'},
      {
        't': '9. Analogy',
        'd': 'Compare 1 Pin vs 100 Pins on a balloon.',
        'outcome': '1 Pin = Pop. 100 Pins = Safe (Distributed Force).',
      },
      {
        't': '10. Application',
        'd': 'Try cutting with Sharp vs Blunt knife.',
        'outcome': 'Sharp (Low Area) cuts easily.',
      },
      {
        't': '11. Real World',
        'd': 'Add double tires to heavy truck.',
        'outcome': 'Wider tires prevent sinking in mud.',
      },
      {'t': '12. Taxonomy', 'd': 'Complete the final definition.', 'outcome': 'Concept Mastered.'},
    ],
  },
  'hi': {
    'intro': {'title': 'प्रेशर पॉइंट', 'subtitle': 'कक्षा 9 • गुरुत्वाकर्षण', 'button': 'लैब में प्रवेश करें'},
    'title': 'प्रेशर पॉइंट चैलेंज',
    'subtitle': 'कक्षा 9 • गुरुत्वाकर्षण',
    'tabs': {'why': 'क्यों सीखें?', 'explore': 'अन्वेषण', 'outcomes': 'परिणाम'},
    'protocol': 'कार्यप्रवाह',
    'conclusion': 'अंतिम निष्कर्ष',
    'submit_def': 'जाँच करें',
    'success': 'सफल!',
    'success_msg': 'आपने सत्यापित किया कि छोटा क्षेत्रफल अधिक दबाव उत्पन्न करता है।',
    'restart': 'पुनः आरंभ करें',
    'labels': {'block': '5kg लकड़ी का ब्लॉक', 'tray': 'रेत का गड्ढा', 'scale': 'डिजिटल तराजू'},
    'gauge': 'गेज',
    'thrust_label': 'प्रणोद (F)',
    'area_label': 'क्षेत्रफल (A)',
    'area_word': 'क्षेत्रफल',
    'depth': 'गहराई',
    'pressure': 'दबाव',
    'high': 'उच्च',
    'low': 'कम',
    'ready': 'तैयार',
    'sinking': 'धंस रहा है',
    'calculated': 'गणना की गई',
    'outcome': 'परिणाम',
    'instruction': 'निर्देश',
    'welcome': 'लैब में आपका स्वागत है',
    'rotate_vert': 'लंबवत घुमाएं',
    'rotate_horiz': 'क्षैतिज घुमाएं',
    'reset_sand': 'रेत रीसेट करें',
    'calc_press': 'दबाव की गणना करें',
    'force_label': 'बल (N)',
    'area_input': 'क्षेत्रफल (m²)',
    'formula': 'सूत्र',
    'calc_btn': 'गणना करें',
    'try_again': 'पुनः प्रयास करें',
    'correct_msg': 'सही!',
    'pin_label': '1 पिन',
    'pins_label': '100 पिन',
    'pop_label': 'फूट गया!',
    'safe_label': 'सुरक्षित',
    'sharp_knife': 'तेज चाकू',
    'blunt_knife': 'कुंद चाकू',
    'narrow_tires': 'पतले टायर',
    'wide_tires': 'चौड़े टायर',
    'cut': 'कट गया',
    'no_cut': 'नहीं कटा',
    'float': 'ऊपर टिका',
    'sink': 'धंस गया',
    'hint_wrong': 'संकेत: व्युत्क्रम का अर्थ है विपरीत।',
    'sentence': ['एक स्थिर बल के लिए दबाव ', '{2}', ' के ', '{1}', ' समानुपाती होता है।'],
    'words': [
      {'id': 'directly', 'text': 'अनुक्रमतः'},
      {'id': 'inversely', 'text': 'व्युत्क्रमतः'},
      {'id': 'area', 'text': 'क्षेत्रफल'},
      {'id': 'volume', 'text': 'आयतन'},
      {'id': 'Pa', 'text': 'Pa'},
      {'id': 'N', 'text': 'N'},
    ],
    'drag_hint': 'शब्दों को खाली स्थानों में खींचें (या टैप करें)।',
    'feedback_err': 'गलत। P = F / A के बारे में सोचें।',
    'feedback_ok': 'सही! P = F / A.',
    'tools': {'lock': 'कैमरा अनलॉक करें', 'unlock': 'कैमरा लॉक करें', 'labels': 'लेबल दिखाएँ/छिपाएँ'},
    'assist': {
      'place': 'स्वतः रखें',
      'weigh': 'तराजू पर रखें',
      'drop': 'ब्लॉक छोड़ें',
      'calc': 'कैलकुलेटर खोलें',
      'conclude': 'निष्कर्ष खोलें',
    },
    'why_learn': [
      {
        'icon': 'ski',
        'title': 'स्नोशूज़',
        'desc':
            'सपाट स्नोशूज़ (बर्फ के जूते) आपके शरीर के वजन को एक बड़े क्षेत्र में वितरित करते हैं, जिससे आप गहरी बर्फ में नहीं धंसते।',
      },
      {
        'icon': 'tack',
        'title': 'नुकीली कील',
        'desc':
            'एक कील की नोक का क्षेत्रफल बहुत कम होता है। यह लकड़ी में घुसने के लिए एक छोटा सा बल लगाकर भी भारी दबाव पैदा करती है।',
      },
      {
        'icon': 'truck',
        'title': 'भारी ट्रक',
        'desc':
            'सड़क पर दबाव कम करने और टायरों को फटने से बचाने के लिए भारी ट्रकों में संपर्क क्षेत्र बढ़ाने हेतु कई चौड़े टायर होते हैं।',
      },
    ],
    'outcomes_title': 'सीखने के परिणाम',
    'outcomes': [
      {
        'title': '1. अवधारणा',
        'desc': 'हमने सीखा कि दबाव (Pressure) प्रति इकाई क्षेत्रफल पर लंबवत लगने वाला बल है। इसका सूत्र P = F / A है।',
      },
      {
        'title': '2. संबंध',
        'desc':
            'हमने समझा कि दबाव और क्षेत्रफल व्युत्क्रमानुपाती (inversely proportional) होते हैं। यदि आप बल (Thrust) को स्थिर रखते हैं लेकिन क्षेत्रफल कम करते हैं, तो दबाव काफी बढ़ जाता है।',
      },
      {
        'title': '3. प्रयोगात्मक प्रमाण',
        'desc':
            'लैब में, 5kg के ब्लॉक ने दोनों स्थितियों में समान 49N बल लगाया। हालाँकि, इसे लंबवत (कम क्षेत्रफल) रखने पर 2450 Pa दबाव बना, जिससे यह गहरा धंस गया। इसे सपाट (बड़ा क्षेत्रफल) रखने पर केवल 612.5 Pa दबाव बना, जिससे यह ऊपर ही रहा।',
      },
      {
        'title': '4. वास्तविक जीवन',
        'desc':
            'यही कारण है कि तेज चाकू आसानी से काटता है (छोटा क्षेत्रफल = भारी दबाव) और ऊंट के पैर चौड़े होते हैं (बड़ा क्षेत्रफल = कम दबाव, रेत में नहीं धंसते)।',
      },
    ],
    'steps': [
      {
        't': '1. सेटअप',
        'd': 'रेत की ट्रे और ब्लॉक को एक-एक करके केंद्र में खींचें।',
        'outcome': 'सेटअप पूर्ण। प्रयोग के लिए तैयार।',
      },
      {'t': '2. तौलना', 'd': 'ब्लॉक को डिजिटल तराजू पर खींचें।', 'outcome': 'द्रव्यमान: 5kg। प्रणोद (भार): 49N।'},
      {
        't': '3. स्थिति A (लंबवत)',
        'd': 'ब्लॉक को लंबवत (20×10 cm) घुमाने के लिए बटन दबाएँ।',
        'outcome': 'क्षेत्रफल = 0.02 m²। उच्च दबाव व्यवस्था।',
      },
      {
        't': '4. ब्लॉक गिराना',
        'd': 'ब्लॉक को रेत में छोड़ने के लिए उस पर क्लिक करें।',
        'outcome': 'ब्लॉक गहरा (>5cm) धंसता है। अधिक प्रभाव।',
      },
      {'t': '5. गणना A', 'd': 'P = 49 / 0.02 की गणना करें।', 'outcome': 'दबाव = 2450 पास्कल (Pa)।'},
      {
        't': '6. स्थिति B (क्षैतिज)',
        'd': 'रेत रीसेट करें, फिर ब्लॉक को क्षैतिज घुमाएँ।',
        'outcome': 'क्षेत्रफल = 0.08 m²। कम दबाव व्यवस्था।',
      },
      {
        't': '7. ब्लॉक गिराना',
        'd': 'ब्लॉक को फिर से छोड़ने के लिए उस पर क्लिक करें।',
        'outcome': 'ब्लॉक कम (<1cm) धंसता है। कम प्रभाव।',
      },
      {'t': '8. गणना B', 'd': 'P = 49 / 0.08 की गणना करें।', 'outcome': 'दबाव = 612.5 पास्कल (Pa)।'},
      {
        't': '9. उपमा (गुब्बारा)',
        'd': 'गुब्बारे पर 1 पिन और 100 पिनों की तुलना करें।',
        'outcome': '1 पिन = फूटा। 100 पिन = सुरक्षित (बल वितरित)।',
      },
      {
        't': '10. अनुप्रयोग (चाकू)',
        'd': 'तेज और कुंद चाकू से काटकर देखें।',
        'outcome': 'तेज चाकू (कम क्षेत्रफल) आसानी से काटता है।',
      },
      {
        't': '11. वास्तविक जीवन (ट्रक)',
        'd': 'भारी ट्रक में दोहरे (चौड़े) टायर लगाएँ।',
        'outcome': 'चौड़े टायर कीचड़ में धंसने से रोकते हैं।',
      },
      {'t': '12. निष्कर्ष', 'd': 'अंतिम परिभाषा पूरी करें।', 'outcome': 'अवधारणा में महारत हासिल।'},
    ],
  },
});

const _brandTeal = Color(0xFF0D9488);
const _brandWarn = Color(0xFFF59E0B);
const _sandTop = 2.1;

class Cl9Ch09A4PressurePointChallengePage extends StatefulWidget {
  const Cl9Ch09A4PressurePointChallengePage({super.key});

  @override
  State<Cl9Ch09A4PressurePointChallengePage> createState() => _Cl9Ch09A4PressurePointChallengePageState();
}

class _Cl9Ch09A4PressurePointChallengePageState extends State<Cl9Ch09A4PressurePointChallengePage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(backgroundGradient: const [Color(0xFF1E293B), Color(0xFF0F172A)]);
  final _rt_Camera3D _camera = _rt_Camera3D(fov: 45, position: _rt_V3(0, 40, 52), target: _rt_V3(0, 0, 0));
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner();
  final _rt_ShellController _shell = _rt_ShellController();
  final math.Random _rng = math.Random();
  final Map<String, _rt_Node3D> _items = {};
  final Map<String, _rt_Node3D> _groups = {};
  final List<_rt_Mesh3D> _wheels = [];

  // --- WORLD STATE ---
  int _curStep = 0;
  int _gen = 0;
  int _visit = 0; // bumped on every step change: drops that step's pending chain
  bool _stepFinished = false, _dropped = false; // per step visit
  bool _showLabels = true;
  bool _camLocked = true;
  bool _simulating = false;
  double _targetY = 5;
  _rt_Node3D? _dragObj;
  bool _sandPlaced = false, _blockPlaced = false, _sandReset = false;
  String _blockOrient = 'flat'; // flat | vert | horiz

  // --- GAUGE (language-neutral keys) ---
  String _valA = '--';
  String _valP = '0';
  String? _depthKey; // null => "--"
  String _statusKey = 'ready';

  // --- HUD notification ---
  bool _hudVisible = false;
  String _hudTitleKey = 'instruction';
  String Function() _hudMsg = () => _tx.s('welcome');

  // --- CALCULATOR ---
  bool _calcVisible = false;
  final TextEditingController _calcF = TextEditingController();
  final TextEditingController _calcA = TextEditingController();
  String Function()? _calcFeedback;
  bool _calcOk = false;

  // --- default camera view per step (activity-wide reset target) ---
  final _rt_V3 _viewPos = _rt_V3(0, 40, 52);
  final _rt_V3 _viewTarget = _rt_V3(0, 0, 0);

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _applyLock();
    _initWorld();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gen++;
    _tweens.cancelAll();
    _viewCtrl.dispose();
    _calcF.dispose();
    _calcA.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ helpers ---
  void _later(int ms, VoidCallback fn) {
    final g = _gen, v = _visit;
    Future.delayed(Duration(milliseconds: ms), () {
      if (!mounted || g != _gen || v != _visit) return;
      fn();
    });
  }

  /// Runs a tween; returns false when the activity was restarted meanwhile.
  Future<bool> _tw(int ms, void Function(double t) fn, {double Function(double) ease = _rt_Ease.linear}) async {
    final g = _gen;
    await _tweens.run(ms, fn, ease: ease);
    return mounted && g == _gen;
  }

  Future<bool> _tweenPos(_rt_Node3D n, {double? x, double? y, double? z, int ms = 500}) {
    final sx = n.position.x, sy = n.position.y, sz = n.position.z;
    return _tw(ms, (t) {
      if (x != null) n.position.x = sx + (x - sx) * t;
      if (y != null) n.position.y = sy + (y - sy) * t;
      if (z != null) n.position.z = sz + (z - sz) * t;
    }, ease: _rt_Ease.inOutQuad);
  }

  void _applyLock() {
    _camera.enableRotate = !_camLocked;
    _camera.enablePan = !_camLocked;
  }

  _rt_Mesh3D get _block => _items['block']! as _rt_Mesh3D;

  // ------------------------------------------------------------ 3D WORLD ---
  void _initWorld() {
    _scene.setLights([_rt_Light3D.ambient(intensity: 0.6), _rt_Light3D.directional(_rt_V3(20, 50, 20), intensity: 1.0)]);

    // --- SCENE GROUPS ---
    final lab = _rt_Node3D(name: 'lab');
    final balloonG = _rt_Node3D(name: 'balloonGroup')..visible = false;
    final knifeG = _rt_Node3D(name: 'knifeGroup')..visible = false;
    final truckG = _rt_Node3D(name: 'truckGroup')..visible = false;
    _scene.root.addAll([lab, balloonG, knifeG, truckG]);
    _groups
      ..['lab'] = lab
      ..['balloon'] = balloonG
      ..['knife'] = knifeG
      ..['truck'] = truckG;

    // --- LAB ASSETS ---
    final table =
        _rt_Mesh3D(_rt_Geometry3D.box(60, 1, 40), _rt_Material3D(color: const Color(0xFFC0C0C0), shininess: 0.3, metalness: 0.2))
          ..position.y = -3
          ..pickable = false;
    lab.add(table);

    final tray = _rt_Node3D(name: 'tray');
    final trayBox = _rt_Mesh3D(_rt_Geometry3D.box(25, 4, 20), _rt_Material3D(color: const Color(0xFF2D3748)));
    final sand = _rt_Mesh3D(_rt_Geometry3D.plane(23, 18), _rt_Material3D(color: const Color(0xFFFACC15)))
      ..rotation.x = -math.pi / 2
      ..position.y = _sandTop
      ..depthBias = -1;
    tray.addAll([trayBox, sand]);
    tray.position.set(-22, 0, 0);
    lab.add(tray);
    _items['tray'] = tray;

    final block = _rt_Mesh3D(_rt_Geometry3D.box(8, 4, 2), _rt_Material3D(color: const Color(0xFF8B4513)), name: 'block')
      ..position.set(22, 0, 0)
      ..depthBias = -3;
    lab.add(block);
    _items['block'] = block;

    // Visible (above-sand) part of the block while it is buried in sand.
    // Pickable: it stands in for the hidden block when the block is tapped.
    final blockClip = _rt_Mesh3D(_rt_Geometry3D.box(1, 1, 1), _rt_Material3D(color: const Color(0xFF8B4513)))
      ..visible = false
      ..depthBias = -3;
    lab.add(blockClip);
    _items['blockClip'] = blockClip;

    // Contact Highlight
    final hl =
        _rt_Mesh3D(
            _rt_Geometry3D.plane(4, 2),
            _rt_Material3D(color: const Color(0xFFFF0000), opacity: 0.6, doubleSided: true, unlit: true),
          )
          ..visible = false
          ..pickable = false
          ..depthBias = -2;
    _scene.add(hl);
    _items['highlight'] = hl;

    // Scale with a digital read-out (canvas texture -> label).
    final scale = _rt_Node3D(name: 'scale');
    scale.add(_rt_Mesh3D(_rt_Geometry3D.box(10, 1, 10), _rt_Material3D(color: const Color(0xFF222222)))..pickable = false);
    final disp = _rt_Label3D(
      '0.00',
      position: _rt_V3(0, 0.6, 5.1),
      worldHeight: 1.6,
      color: const Color(0xFF00FF00),
      background: Colors.black,
      alwaysOnTop: false,
    )..pickable = false;
    scale.add(disp);
    scale.position.set(20, -2, -10);
    lab.add(scale);
    _items['scale'] = scale;
    _items['scaleDisp'] = disp;

    // Object labels (HTML .scene-label.obj-label), follow their objects.
    for (final key in ['tray', 'block', 'scale']) {
      final l = _rt_Label3D(
        '',
        pixelHeight: 11,
        background: const Color(0x99000000),
        borderColor: const Color(0x33FFFFFF),
        color: const Color(0xFFCCCCCC),
      )..pickable = false;
      lab.add(l);
      _items['lbl-$key'] = l;
    }

    // Particles (Splash/Dust)
    final parts = _rt_Points3D(
      [
        for (var i = 0; i < 150; i++)
          _rt_V3((_rng.nextDouble() - 0.5) * 4, (_rng.nextDouble() - 0.5) * 4, (_rng.nextDouble() - 0.5) * 4),
      ],
      color: const Color(0xFFFACC15),
      size: 5,
    )..visible = false;
    _scene.add(parts);
    _items['particles'] = parts;

    // POP effect for balloon
    final popParts = _rt_Points3D(
      [
        for (var i = 0; i < 100; i++)
          _rt_V3((_rng.nextDouble() - 0.5) * 2, (_rng.nextDouble() - 0.5) * 2, (_rng.nextDouble() - 0.5) * 2),
      ],
      color: const Color(0xFFFF0000),
      size: 3,
    )..visible = false;
    _scene.add(popParts);
    _items['popParts'] = popParts;

    // --- BALLOON ASSETS ---
    final balloon = _rt_Node3D(name: 'balloon');
    final bBody = _rt_Mesh3D(
      _rt_Geometry3D.sphere(3, widthSegments: 24, heightSegments: 16),
      _rt_Material3D(color: const Color(0xFFFF0000), shininess: 1.0, emissive: const Color(0xFF330000)),
    )..scale.y = 1.2;
    final bKnot = _rt_Mesh3D(_rt_Geometry3D.cylinder(0.2, 0.1, 0.5, segments: 12), _rt_Material3D(color: const Color(0xFFFF0000)))
      ..position.y = -3.5;
    balloon.addAll([bBody, bKnot]);
    balloon.position.set(0, 5, 0);
    balloonG.add(balloon);
    _items['balloon'] = balloon;

    // Single Pin
    final pin1 =
        _rt_Mesh3D(
            _rt_Geometry3D.cone(0.1, 2, segments: 16),
            _rt_Material3D(color: const Color(0xFFCCCCCC), metalness: 0.8, shininess: 0.8),
          )
          ..position.y = 1
          ..visible = false;
    balloonG.add(pin1);
    _items['pin1'] = pin1;

    // Bed of Nails
    final bed = _rt_Node3D(name: 'bed');
    bed.add(_rt_Mesh3D(_rt_Geometry3D.box(6, 0.5, 6), _rt_Material3D(color: const Color(0xFF8B4513)))..position.y = 0.5);
    final nailGeo = _rt_Geometry3D.cone(0.05, 1.5, segments: 8);
    final nailMat = _rt_Material3D(color: const Color(0xFFEEEEEE), metalness: 0.9, shininess: 0.9);
    for (var x = -2.0; x <= 2.0; x += 0.5) {
      for (var z = -2.0; z <= 2.0; z += 0.5) {
        bed.add(_rt_Mesh3D(nailGeo, nailMat)..position.set(x, 1.25, z));
      }
    }
    bed.visible = false;
    balloonG.add(bed);
    _items['bed'] = bed;

    // --- KNIFE ASSETS ---
    final knife = _rt_Node3D(name: 'knife');
    final blade = _rt_Mesh3D(
      _rt_Geometry3D.box(0.1, 4, 1.5),
      _rt_Material3D(color: const Color(0xFFCCCCCC), metalness: 0.8, shininess: 0.8),
    );
    final handle = _rt_Mesh3D(_rt_Geometry3D.cylinder(0.3, 0.3, 2, segments: 16), _rt_Material3D(color: const Color(0xFF333333)))
      ..position.y = 3;
    knife.addAll([blade, handle]);
    knife.position.set(0, 6, 0);
    knife.rotation.z = math.pi / 2;
    knifeG.add(knife);
    _items['knife'] = knife;
    final apple = _rt_Sphere3D(2, _rt_Material3D(color: const Color(0xFF00FF00)), name: 'apple');
    knifeG.add(apple);
    _items['apple'] = apple;

    // --- TRUCK ASSETS ---
    final mud = _rt_Mesh3D(_rt_Geometry3D.box(20, 1, 40), _rt_Material3D(color: const Color(0xFF3E2723)))..position.y = -2;
    truckG.add(mud);
    final truck = _rt_Node3D(name: 'truck');
    truck.add(_rt_Mesh3D(_rt_Geometry3D.box(4, 1, 10), _rt_Material3D(color: const Color(0xFF111111)))..position.y = 1); // Chassis
    truck.add(
      _rt_Mesh3D(_rt_Geometry3D.box(4, 3, 3), _rt_Material3D(color: const Color(0xFFFF0000)))..position.set(0, 3, 3.5),
    ); // Cab
    truck.add(
      _rt_Mesh3D(_rt_Geometry3D.box(4.2, 3.5, 6), _rt_Material3D(color: const Color(0xFF3366FF)))..position.set(0, 3.2, -1.5),
    ); // Container
    _wheels.clear();
    for (final p in [
      [-2.2, 1.0, -3.0],
      [2.2, 1.0, -3.0],
      [-2.2, 1.0, 3.0],
      [2.2, 1.0, 3.0],
    ]) {
      final w = _rt_Mesh3D(_rt_Geometry3D.cylinder(1, 1, 0.8, segments: 16), _rt_Material3D(color: const Color(0xFF222222)))
        ..rotation.z = math.pi / 2
        ..position.set(p[0], p[1], p[2]);
      truck.add(w);
      _wheels.add(w);
    }
    truck.position.y = 1;
    truckG.add(truck);
    _items['truck'] = truck;

    _syncLabels();
  }

  void _syncLabels() {
    for (final key in ['tray', 'block', 'scale']) {
      final l = _items['lbl-$key'];
      if (l is _rt_Label3D) l.text = _tx.s('labels.$key');
    }
  }

  void _updateScaleDisplay(String val) {
    final d = _items['scaleDisp'];
    if (d is _rt_Label3D) d.text = val;
  }

  // World-space extents of the block for its current orientation.
  _rt_V3 get _blockDims => switch (_blockOrient) {
    'vert' => _rt_V3(4, 8, 2),
    'horiz' => _rt_V3(8, 2, 4),
    _ => _rt_V3(8, 4, 2),
  };

  void _onFrame(double dt) {
    _tweens.update(dt);
    final blk = _items['block'];
    if (blk == null) return;

    if (_simulating) {
      final k = 1 - math.pow(0.9, dt * 60).toDouble();
      blk.position.y += (_targetY - blk.position.y) * k;
      if ((blk.position.y - _targetY).abs() < 0.01) {
        blk.position.y = _targetY;
        _simulating = false;
        if (_curStep == 4 || _curStep == 7) {
          final s = _curStep == 4 ? 3.0 : 1.0;
          final yOff = _curStep == 4 ? 0.5 : 2.1;
          final parts = _items['particles']!;
          parts.position.set(blk.position.x, yOff + 2, blk.position.z);
          parts.visible = true;
          parts.scale.set(0.1, 0.1, 0.1);
          _tw(600, (t) {
            final v = 0.1 + (s - 0.1) * t;
            parts.scale.set(v, v, v);
          }).then((ok) {
            if (ok) parts.visible = false;
          });
        }
      }
    }

    // Contact highlight follows the block's bottom face.
    final hl = _items['highlight'];
    if (hl != null && (_curStep == 3 || _curStep == 4 || _curStep == 6 || _curStep == 7)) {
      final dims = _blockDims;
      hl.rotation.x = -math.pi / 2;
      hl.rotation.z = 0;
      hl.position.set(blk.position.x, math.max(blk.position.y - dims.y / 2 - 0.1, _sandTop + 0.05), blk.position.z);
    }

    // Clip the block at the sand surface (no depth buffer in mini3d).
    final clip = _items['blockClip'] as _rt_Mesh3D;
    final tray = _items['tray']!;
    final dims = _blockDims;
    final bottom = blk.position.y - dims.y / 2;
    final top = blk.position.y + dims.y / 2;
    final overTray = (blk.position.x - tray.position.x).abs() < 12.5 && (blk.position.z - tray.position.z).abs() < 10;
    final settledOrient = _blockOrient != 'flat' || (blk.rotation.x == 0 && blk.rotation.z == 0);
    if (overTray && bottom < _sandTop && settledOrient && _groups['lab']!.visible) {
      blk.visible = false;
      final h = math.max(0.05, top - _sandTop);
      clip.geometry = _rt_Geometry3D.box(dims.x, h, dims.z);
      clip.position.set(blk.position.x, _sandTop + h / 2, blk.position.z);
      clip.visible = top > _sandTop;
    } else {
      blk.visible = true;
      clip.visible = false;
    }

    // Label sync (offset above each object).
    for (final key in ['tray', 'block', 'scale']) {
      final l = _items['lbl-$key'];
      final o = _items[key];
      if (l == null || o == null) continue;
      l.position.set(o.position.x, o.position.y + 5, o.position.z);
      l.visible = _showLabels;
    }
  }

  // ------------------------------------------------------------ pointer ---
  bool _onPointerDown(_rt_SceneEvent e) {
    if (_curStep == 4 || _curStep == 7) {
      if (e.hitWhere((n) => n.name == 'block' || n == _items['blockClip']) != null) {
        _triggerDrop();
        return true;
      }
    }
    if (!_camLocked) return false;
    if (_curStep != 1 && _curStep != 2) return false;
    final hit = e.hitWhere((n) => n.name == 'tray' || n.name == 'block');
    if (hit != null) {
      _dragObj = hit;
      return true;
    }
    return false;
  }

  void _onPointerMove(_rt_SceneEvent e) {
    final obj = _dragObj;
    if (obj == null) return;
    final pt = e.ray.intersectY(obj.position.y);
    if (pt != null) {
      obj.position.x = pt.x.clamp(-45.0, 45.0);
      obj.position.z = pt.z.clamp(-25.0, 25.0);
    }
  }

  void _onPointerUp(_rt_SceneEvent e) {
    final obj = _dragObj;
    if (obj == null) return;
    _dragObj = null;
    _checkDrop(obj);
  }

  void _checkDrop(_rt_Node3D obj) {
    final tray = _items['tray']!;
    final block = _items['block']!;
    if (_curStep == 1) {
      final dist = math.sqrt(obj.position.x * obj.position.x + obj.position.z * obj.position.z);
      if (dist < 25) {
        if (obj == tray) {
          _tweenPos(obj, x: -10, z: 0);
          _sandPlaced = true;
        } else if (obj == block) {
          _tweenPos(obj, x: 10, z: 5);
          _blockPlaced = true;
        }
        _rt_playSfx(_rt_Sfx.pop);
        if (_sandPlaced && _blockPlaced) _finishStep(1);
      }
    } else if (_curStep == 2 && obj == block) {
      final sp = _items['scale']!.position;
      final dx = obj.position.x - sp.x, dz = obj.position.z - sp.z;
      if (math.sqrt(dx * dx + dz * dz) < 15) {
        final v = _visit;
        _tweenPos(obj, x: sp.x, y: 0.5, z: sp.z).then((ok) {
          if (!ok || v != _visit) return;
          _updateScaleDisplay('5.00');
          _rt_playSfx(_rt_Sfx.correct);
          _finishStep(2);
        });
      }
    }
  }

  // Assist for touch screens: performs the drag of steps 1 and 2.
  void _autoPlace() {
    if (_curStep == 1) {
      final tray = _items['tray']!, block = _items['block']!;
      if (!_sandPlaced) {
        tray.position.set(-8, tray.position.y, 0);
        _checkDrop(tray);
      }
      if (!_blockPlaced) {
        block.position.set(8, block.position.y, 4);
        _checkDrop(block);
      }
    } else if (_curStep == 2) {
      final block = _items['block']!;
      final sp = _items['scale']!.position;
      block.position.set(sp.x, block.position.y, sp.z + 4);
      _checkDrop(block);
    }
  }

  // ------------------------------------------------------------ APP ---
  void _updateHUD(String a, String p, String? depthKey, String statusKey) {
    setState(() {
      _valA = a;
      _valP = p;
      _depthKey = depthKey;
      _statusKey = statusKey;
    });
  }

  Future<void> _handleStepAction([String? actionType]) async {
    final o = _items;
    final visit = _visit; // the user may change step while a tween runs
    if (_curStep == 3) {
      // Rotate Vert
      _block.rotation.z = math.pi / 2;
      _blockOrient = 'vert';
      setState(() => _curStepActionsHidden = true);
      _rt_playSfx(_rt_Sfx.click);
      if (!await _tweenPos(_block, x: 0, y: 6, z: 0, ms: 800) || visit != _visit) return;
      o['highlight']!
        ..scale.set(1, 1, 1)
        ..visible = true;
      _rt_playSfx(_rt_Sfx.correct);
      _updateHUD('0.02', '0', null, 'ready');
      _finishStep(3);
    } else if (_curStep == 6) {
      if (!_sandReset) {
        // Reset Sand
        _rt_playSfx(_rt_Sfx.pop);
        setState(() => _sandReset = true);
        await _tweenPos(_block, y: 5);
      } else {
        // Rotate Horiz
        setState(() => _curStepActionsHidden = true);
        _block.position.y = 5;
        final sx = _block.rotation.x, sz = _block.rotation.z;
        if (!await _tw(800, (t) {
          _block.rotation.z = sz + (0 - sz) * t;
          _block.rotation.x = sx + (math.pi / 2 - sx) * t;
        }, ease: _rt_Ease.inOutQuad)) {
          return;
        }
        if (visit != _visit) return;
        _blockOrient = 'horiz';
        o['highlight']!
          ..scale.set(2, 2, 1)
          ..visible = true;
        _rt_playSfx(_rt_Sfx.correct);
        _updateHUD('0.08', '0', null, 'ready');
        _finishStep(6);
      }
    } else if (_curStep == 9) {
      // Balloon
      final balloon = o['balloon']!;
      if (actionType == '1pin') {
        o['pin1']!.visible = true;
        o['bed']!.visible = false;
        balloon.scale.set(1, 1, 1);
        balloon.position.y = 5;
        if (!await _tweenPos(balloon, y: 2.2) || visit != _visit) return;
        _rt_playSfx(_rt_Sfx.pop);
        final pop = o['popParts']!;
        pop.position.copy(balloon.position);
        pop.scale.set(1, 1, 1);
        pop.visible = true;
        _tw(300, (t) {
          final v = 1 + t;
          pop.scale.set(v, v, v);
        }).then((ok) {
          if (ok) pop.visible = false;
        });
        _tw(100, (t) {
          final v = 1 - 0.9 * t;
          balloon.scale.set(v, v, v);
        });
        _notify(
          () => '${_tx.s('pin_label')} = ${_tx.s('high')} ${_tx.s('pressure')} = ${_tx.s('pop_label')}',
          outcome: true,
        );
        _rt_playSfx(_rt_Sfx.wrong);
      } else {
        o['pin1']!.visible = false;
        o['bed']!.visible = true;
        balloon.scale.set(1, 1, 1);
        balloon.position.y = 5;
        if (!await _tweenPos(balloon, y: 2.5, ms: 1000) || visit != _visit) return;
        _rt_playSfx(_rt_Sfx.correct);
        _notify(
          () => '${_tx.s('pins_label')} = ${_tx.s('low')} ${_tx.s('pressure')} = ${_tx.s('safe_label')}',
          outcome: true,
        );
        _later(2000, () => _finishStep(9));
      }
    } else if (_curStep == 10) {
      // Knife
      final knife = o['knife']!;
      final apple = o['apple']!;
      if (actionType == 'sharp') {
        if (!await _tweenPos(knife, y: 2, ms: 300) || visit != _visit) return;
        _rt_playSfx(_rt_Sfx.correct);
        _tw(200, (t) {
          final v = 1 - t;
          apple.scale.set(v, v, v);
        }); // Sliced
        _notify(
          () => '${_tx.s('sharp_knife')} = ${_tx.s('low')} ${_tx.s('area_word')} = ${_tx.s('cut')}',
          outcome: true,
        );
        _later(2000, () => _finishStep(10));
      } else {
        _rt_playSfx(_rt_Sfx.wrong);
        _notify(
          () => '${_tx.s('blunt_knife')} = ${_tx.s('high')} ${_tx.s('area_word')} = ${_tx.s('no_cut')}',
          outcome: true,
        );
        if (!await _tweenPos(knife, y: 3.5, ms: 300) || visit != _visit) return;
        await _tweenPos(knife, y: 6, ms: 300);
      }
    } else if (_curStep == 11) {
      // Truck
      final truck = o['truck']!;
      if (actionType == 'wide') {
        for (final w in _wheels) {
          w.scale.set(1, 3, 1); // Wide
        }
        _rt_playSfx(_rt_Sfx.correct);
        _tweenPos(truck, y: 1, ms: 1000); // Float
        _notify(
          () => '${_tx.s('wide_tires')} = ${_tx.s('low')} ${_tx.s('pressure')} = ${_tx.s('float')}',
          outcome: true,
        );
        _later(2000, () => _finishStep(11));
      } else {
        for (final w in _wheels) {
          w.scale.set(1, 1, 1); // Narrow
        }
        _rt_playSfx(_rt_Sfx.wrong);
        _tweenPos(truck, y: -0.5, ms: 1000); // Sink
        _notify(
          () => '${_tx.s('narrow_tires')} = ${_tx.s('high')} ${_tx.s('pressure')} = ${_tx.s('sink')}',
          outcome: true,
        );
      }
    }
  }

  bool _curStepActionsHidden = false;

  void _triggerDrop() {
    if (_simulating || _dropped) return;
    double targetY;
    if (_curStep == 4) {
      targetY = -1.5; // Deep sink (Sand at 2.1)
    } else if (_curStep == 7) {
      targetY = 2.0; // Shallow sink
    } else {
      return;
    }
    _targetY = targetY;
    _simulating = true;
    setState(() => _dropped = true); // one release per visit of the step
    _rt_playSfx(_rt_Sfx.pop);
    final step = _curStep;
    _later(1500, () => _finishStep(step));
  }

  void _checkCalculation() {
    final f = double.tryParse(_calcF.text.trim());
    final a = double.tryParse(_calcA.text.trim());
    if (_curStep == 5 || _curStep == 8) {
      final wantA = _curStep == 5 ? 0.02 : 0.08;
      final result = _curStep == 5 ? '2450' : '612.5';
      if (f == 49 && a == wantA) {
        final step = _curStep;
        setState(() {
          _calcOk = true;
          _calcFeedback = () => '${_tx.s('correct_msg')} $result Pa';
        });
        _rt_playSfx(_rt_Sfx.correct);
        _later(1000, () {
          setState(() => _calcVisible = false);
          _finishStep(step);
        });
      } else {
        setState(() {
          _calcOk = false;
          _calcFeedback = () => '${_tx.s('try_again')}. F=49, A=$wantA';
        });
        _rt_playSfx(_rt_Sfx.wrong);
      }
    }
  }

  void _setGroupVisibility(int id) {
    final g = _groups;
    g['lab']!.visible = id <= 8;
    if (id > 8) {
      _items['highlight']!.visible = false;
      _items['particles']!.visible = false;
    }
    if (id <= 8) {
      g['balloon']!.visible = false;
      g['knife']!.visible = false;
      g['truck']!.visible = false;
    } else if (id <= 11) {
      g['balloon']!.visible = id == 9;
      g['knife']!.visible = id == 10;
      g['truck']!.visible = id == 11;
    }
    // Camera framing: the small analogy props get a closer view.
    if (id <= 8) {
      _flyTo(_rt_V3(0, 40, 52), _rt_V3(0, 0, 0));
    } else if (id == 9) {
      _flyTo(_rt_V3(0, 10, 18), _rt_V3(0, 3, 0));
    } else if (id == 10) {
      _flyTo(_rt_V3(0, 9, 16), _rt_V3(0, 2, 0));
    } else if (id == 11) {
      _flyTo(_rt_V3(14, 12, 20), _rt_V3(0, 1, 0));
    }
  }

  void _flyTo(_rt_V3 pos, _rt_V3 target) {
    if (_viewPos.distanceTo(pos) < 1e-6 && _viewTarget.distanceTo(target) < 1e-6) return;
    _viewPos.copy(pos);
    _viewTarget.copy(target);
    final sp = _camera.position.clone(), st = _camera.target.clone();
    _tw(1000, (t) {
      _camera.position.copy(sp.lerp(pos, t));
      _camera.target.copy(st.lerp(target, t));
    }, ease: _rt_Ease.inOutCubic);
  }

  void _resetView() {
    _camera.zoom = 1;
    _flyToNow();
  }

  void _flyToNow() {
    final pos = _viewPos.clone(), target = _viewTarget.clone();
    final sp = _camera.position.clone(), st = _camera.target.clone();
    _tw(1000, (t) {
      _camera.position.copy(sp.lerp(pos, t));
      _camera.target.copy(st.lerp(target, t));
    }, ease: _rt_Ease.inOutCubic);
  }

  void _executeStep(int id) {
    if (id < 1 || id > 12) return;
    _rt_playSfx(_rt_Sfx.scenario, volume: 0.6);
    if (id != _curStep) {
      // A different step: drop the old step's pending chain and its state.
      _visit++;
      _stepFinished = false;
      _dropped = false;
    }
    setState(() {
      _curStep = id;
      _curStepActionsHidden = false;
      _calcVisible = false; // steps 5 and 8 re-open it below
    });
    _notify(() => _tx.s('steps.${id - 1}.d'));
    _setGroupVisibility(id);
    final o = _items;

    switch (id) {
      case 3: // Vert
        _simulating = false;
        o['block']!.position.set(0, 5, 0);
      case 5: // Calc A
      case 8: // Calc B
        _openCalculator();
      case 6: // Reset & Horiz
        o['highlight']!.visible = false;
        setState(() => _sandReset = false);
      case 9: // Balloon
        o['balloon']!
          ..position.y = 5
          ..scale.set(1, 1, 1);
        o['popParts']!.visible = false;
        o['pin1']!.visible = false;
        o['bed']!.visible = false;
      case 10: // Knife
        o['knife']!.position.y = 6;
        o['apple']!.scale.set(1, 1, 1);
      case 11: // Truck
        o['truck']!.position.y = 1;
      case 12: // Conclusion
        _openConclusion();
    }
  }

  void _openCalculator() {
    _calcF.clear();
    _calcA.clear();
    setState(() {
      _calcVisible = true;
      _calcFeedback = null;
      _calcOk = false;
    });
  }

  void _finishStep(int id) {
    // Once per visit of the step: a repeated tap (WIDE TIRES, Release) must not
    // chain the next step twice, and a stale finish must not pull the user back.
    if (!mounted || id != _curStep || _stepFinished) return;
    _stepFinished = true;
    _notify(() => _tx.s('steps.${id - 1}.outcome'), outcome: true);
    setState(() => _done = math.max(_done, id));
    if (id == 1) _later(1000, () => _executeStep(2));
    if (id == 2) {
      _updateHUD('--', '0', null, 'ready');
      _later(1500, () => _executeStep(3));
    }
    if (id == 3) {
      _updateHUD('0.02', '0', null, 'ready');
      _later(1500, () => _executeStep(4));
    }
    if (id == 4) {
      _updateHUD('0.02', '2450', 'high', 'sinking');
      _later(2000, () => _executeStep(5));
    }
    if (id == 5) {
      _updateHUD('0.02', '2450', 'high', 'calculated');
      _later(2000, () => _executeStep(6));
    }
    if (id == 6) {
      _updateHUD('0.08', '--', 'low', 'ready');
      _later(1500, () => _executeStep(7));
    }
    if (id == 7) {
      _updateHUD('0.08', '612.5', 'low', 'sinking');
      _later(2000, () => _executeStep(8));
    }
    if (id == 8) {
      _updateHUD('0.08', '612.5', 'low', 'calculated');
      _later(2000, () => _executeStep(9));
    }
    if (id == 9) _later(2000, () => _executeStep(10));
    if (id == 10) _later(2000, () => _executeStep(11));
    if (id == 11) _later(2000, () => _executeStep(12));
  }

  int _done = 0;

  void _notify(String Function() msg, {bool outcome = false}) {
    setState(() {
      _hudVisible = true;
      _hudTitleKey = outcome ? 'outcome' : 'instruction';
      _hudMsg = msg;
    });
  }

  // --- Drag Drop Conclusion ---
  Future<void> _openConclusion() async {
    final g = _gen;
    var solved = false;
    await _rt_showShellPopup(
      context,
      title: _tx.s('conclusion'),
      icon: Icons.edit_note,
      color: _brandTeal,
      barrierDismissible: false,
      actions: const [],
      body: _ConclusionPuzzle(
        onSolved: () {
          solved = true;
        },
      ),
    );
    if (!mounted || g != _gen || !solved) return;
    setState(() => _done = 12);
    await _shell.showSuccess(
      title: _tx.s('success'),
      message: _tx.s('success_msg'),
      buttonLabel: _tx.s('restart'),
      icon: Icons.emoji_events,
      color: _brandTeal,
      onConfirm: _restart, // a tap outside just closes the popup
    );
  }

  void _restart() {
    _gen++;
    _tweens.cancelAll();
    _scene.clear();
    _items.clear();
    _groups.clear();
    _camera.reset();
    _viewPos.set(0, 40, 52);
    _viewTarget.set(0, 0, 0);
    _calcF.clear();
    _calcA.clear();
    setState(() {
      _curStep = 0;
      _done = 0;
      _simulating = false;
      _targetY = 5;
      _dragObj = null;
      _sandPlaced = false;
      _blockPlaced = false;
      _sandReset = false;
      _blockOrient = 'flat';
      _valA = '--';
      _valP = '0';
      _depthKey = null;
      _statusKey = 'ready';
      _hudVisible = false;
      _calcVisible = false;
      _calcFeedback = null;
      _curStepActionsHidden = false;
    });
    _initWorld();
    _executeStep(1);
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
          _syncLabels();
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            theme: const _rt_ShellTheme(
              accent: _brandTeal,
              headerGradient: [_rt_Tw.slate900, _rt_Tw.slate800],
              headerSubtitleColor: _brandWarn,
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.subtitle'),
              buttonLabel: _tx.s('intro.button'),
              icon: Icons.fitness_center,
              buttonIcon: Icons.arrow_forward,
            ),
            onStart: () => _executeStep(1),
            onRestart: _restart,
            onZoomIn: _camera.zoomIn,
            onZoomOut: _camera.zoomOut,
            onResetView: _resetView,
            toolbarExtras: [
              if (!_camLocked) ...[
                _rt_RotatePanToggle(controller: _viewCtrl, accent: _brandTeal),
                const SizedBox(height: 4),
              ],
              _toolBtn(
                _camLocked ? Icons.lock : Icons.lock_open,
                _tx.s(_camLocked ? 'tools.lock' : 'tools.unlock'),
                active: !_camLocked,
                color: _camLocked ? _brandWarn : _brandTeal,
                onTap: () => setState(() {
                  _camLocked = !_camLocked;
                  _applyLock();
                }),
              ),
              const SizedBox(height: 4),
              _toolBtn(
                _showLabels ? Icons.visibility : Icons.visibility_off,
                _tx.s('tools.labels'),
                active: _showLabels,
                color: _brandTeal,
                onTap: () => setState(() => _showLabels = !_showLabels),
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
    final gaugeW = math.min(200.0, c.maxWidth * 0.38);
    return Stack(
      children: [
        // Pressure Gauge (top right, left of the toolbar)
        Positioned(top: 12, right: 60, width: gaugeW, child: _gauge(small)),
        // HUD Message
        Positioned(
          left: 76,
          right: 60,
          bottom: 14,
          child: IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _hudVisible ? 1 : 0,
              child: Center(child: _hudBox(small)),
            ),
          ),
        ),
        // Action Button Overlay
        if (_stepButtons().isNotEmpty)
          Positioned(
            left: 60,
            right: 60,
            bottom: small ? 62 : 80,
            child: Wrap(alignment: WrapAlignment.center, spacing: 10, runSpacing: 8, children: _stepButtons()),
          ),
        // Calculator Overlay
        if (_calcVisible)
          Positioned.fill(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: math.min(300, c.maxWidth - 24), maxHeight: c.maxHeight - 16),
                child: SingleChildScrollView(child: _calculator(small)),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _stepButtons() {
    if (_curStepActionsHidden) return const [];
    Widget b(String label, Color bg, Color fg, IconData? icon, VoidCallback onTap) {
      return Material(
        color: bg,
        shape: const StadiumBorder(),
        elevation: 4,
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: () {
            _rt_playSfx(_rt_Sfx.click);
            onTap();
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 6)],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: fg, fontWeight: FontWeight.w800, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    const stone = Color(0xFF1C1917);
    switch (_curStep) {
      case 3:
        return [b(_tx.s('rotate_vert'), _brandWarn, stone, Icons.rotate_right, _handleStepAction)];
      case 6:
        return [
          if (!_sandReset)
            b(_tx.s('reset_sand'), _brandTeal, Colors.white, Icons.cleaning_services, _handleStepAction)
          else
            b(_tx.s('rotate_horiz'), _brandWarn, stone, Icons.rotate_right, _handleStepAction),
        ];
      case 9:
        return [
          b(_tx.s('pin_label'), _rt_Tw.red500, Colors.white, null, () => _handleStepAction('1pin')),
          b(_tx.s('pins_label'), _rt_Tw.green500, Colors.white, null, () => _handleStepAction('100pin')),
        ];
      case 10:
        return [
          b(_tx.s('sharp_knife'), _rt_Tw.blue500, Colors.white, null, () => _handleStepAction('sharp')),
          b(_tx.s('blunt_knife'), _rt_Tw.gray500, Colors.white, null, () => _handleStepAction('blunt')),
        ];
      case 11:
        return [
          b(_tx.s('narrow_tires'), _rt_Tw.red500, Colors.white, null, () => _handleStepAction('narrow')),
          b(_tx.s('wide_tires'), _rt_Tw.green500, Colors.white, null, () => _handleStepAction('wide')),
        ];
    }
    return const [];
  }

  Widget _gauge(bool small) {
    final fs = small ? 10.0 : 11.5;
    TextStyle lbl() => TextStyle(fontSize: fs, color: _rt_Tw.slate500, fontFamily: 'monospace');
    TextStyle val(Color c) => TextStyle(fontSize: fs, color: c, fontWeight: FontWeight.bold, fontFamily: 'monospace');
    Widget row(String l, String v, Color c) => Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(l, maxLines: 1, overflow: TextOverflow.ellipsis, style: lbl()),
          ),
          // Values shrink rather than overflow a narrow gauge (never truncated).
          Flexible(child: FittedBox(fit: BoxFit.scaleDown, child: Text(v, style: val(c)))),
        ],
      ),
    );
    final sinking = _statusKey == 'sinking';
    return IgnorePointer(
      child: Transform.rotate(
        angle: 0.017,
        child: Container(
          padding: EdgeInsets.fromLTRB(10, small ? 6 : 8, 10, small ? 6 : 8),
          decoration: BoxDecoration(
            color: _rt_Tw.slate100,
            borderRadius: BorderRadius.circular(4),
            border: const Border(top: BorderSide(color: _brandTeal, width: 6)),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 12)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.speed, size: fs + 2, color: _brandTeal),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      _tx.s('gauge'),
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: fs,
                        fontWeight: FontWeight.w900,
                        color: _brandTeal,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 8, color: _rt_Tw.slate300),
              row(_tx.s('thrust_label'), '49 N', _rt_Tw.slate800),
              row(_tx.s('area_label'), '$_valA m²', _rt_Tw.blue600),
              row(_tx.s('depth'), _depthKey == null ? '--' : _tx.s(_depthKey!), _rt_Tw.slate600),
              const Divider(height: 6, color: _rt_Tw.slate300),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _tx.s('pressure'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: fs, fontWeight: FontWeight.bold, color: _rt_Tw.slate500),
                    ),
                  ),
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: _rt_Tw.slate800, borderRadius: BorderRadius.circular(4)),
                      child: FittedBox(fit: BoxFit.scaleDown, child: Text('$_valP Pa', style: val(_brandWarn))),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 1),
                decoration: BoxDecoration(
                  color: sinking ? _brandWarn : _rt_Tw.slate400,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _tx.s(_statusKey).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: Colors.white),
                ),
              ),
            ],
          ),
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
        borderRadius: BorderRadius.circular(40),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: small ? 14 : 22, vertical: small ? 7 : 10),
          decoration: const BoxDecoration(
            color: Color(0xF20F172A),
            border: Border(bottom: BorderSide(color: _brandWarn, width: 3)),
          ),
          child: _hudRow(small),
        ),
      ),
    );
  }

  Widget _hudRow(bool small) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _tx.s(_hudTitleKey),
          style: const TextStyle(color: _brandWarn, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1),
        ),
        Container(width: 1, height: 16, margin: const EdgeInsets.symmetric(horizontal: 10), color: _rt_Tw.slate600),
        Flexible(
          child: Text(
            _hudMsg(),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: _rt_Tw.slate100, fontSize: small ? 12 : 14, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _calculator(bool small) {
    InputDecoration deco(String hint) => InputDecoration(
      isDense: true,
      hintText: hint,
      hintStyle: const TextStyle(color: _rt_Tw.slate500),
      filled: true,
      fillColor: _rt_Tw.slate800,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _rt_Tw.slate600),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: _rt_Tw.slate600),
      ),
    );
    Widget field(String label, TextEditingController ctl, String hint, Key key) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: _rt_Tw.slate400)),
        const SizedBox(height: 3),
        TextField(
          key: key,
          controller: ctl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontSize: 14),
          decoration: deco(hint),
        ),
      ],
    );
    return Container(
      padding: EdgeInsets.fromLTRB(18, small ? 10 : 16, 18, small ? 10 : 16),
      decoration: BoxDecoration(
        color: const Color(0xF20F172A),
        borderRadius: BorderRadius.circular(16),
        border: const Border(left: BorderSide(color: _brandTeal, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 24)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _tx.s('calc_press'),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: small ? 17 : 21, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: small ? 8 : 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: field(_tx.s('force_label'), _calcF, '49', const ValueKey('calc-f'))),
              const SizedBox(width: 12),
              Expanded(
                child: field(_tx.s('area_input'), _calcA, _curStep == 8 ? '0.08' : '0.02', const ValueKey('calc-a')),
              ),
            ],
          ),
          SizedBox(height: small ? 6 : 10),
          Text(
            '${_tx.s('formula')}: P = F / A',
            style: const TextStyle(fontSize: 11, color: _rt_Tw.slate500, fontFamily: 'monospace'),
          ),
          SizedBox(height: small ? 6 : 10),
          _rt_ActionButton(
            label: _tx.s('calc_btn'),
            icon: Icons.calculate,
            color: _brandTeal,
            expand: true,
            onPressed: _calcOk ? null : _checkCalculation,
          ),
          if (_calcFeedback != null) ...[
            const SizedBox(height: 6),
            Text(
              _calcFeedback!(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _calcOk ? _rt_Tw.green400 : _rt_Tw.red400),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------- sidebar ---
  Widget _exploreTab() {
    final steps = _tx.list('steps');
    String? assistLabel;
    VoidCallback? assist;
    switch (_curStep) {
      case 1:
        assistLabel = _tx.s('assist.place');
        assist = _autoPlace;
      case 2:
        assistLabel = _tx.s('assist.weigh');
        assist = _autoPlace;
      case 4:
      case 7:
        assistLabel = _tx.s('assist.drop');
        assist = _simulating || _dropped ? null : _triggerDrop;
      case 5:
      case 8:
        if (!_calcVisible) {
          assistLabel = _tx.s('assist.calc');
          assist = _openCalculator;
        }
      case 12:
        if (_done < 12) {
          assistLabel = _tx.s('assist.conclude');
          assist = _openConclusion;
        }
    }
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
              _tx.s('protocol'),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: _brandWarn),
            ),
          ),
          for (var i = 0; i < steps.length; i++)
            _stepItem(i + 1, steps[i] as Map, assistLabel: i + 1 == _curStep ? assistLabel : null, assist: assist),
        ],
      ),
    );
  }

  Widget _stepItem(int idx, Map s, {String? assistLabel, VoidCallback? assist}) {
    final completed = idx < _curStep || idx <= _done;
    final active = idx == _curStep;
    final border = active ? _brandWarn : (completed ? _rt_Tw.emerald500 : _rt_Tw.slate300);
    return Opacity(
      opacity: active ? 1 : (completed ? 0.7 : 0.8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: active ? _rt_Tw.amber50 : Colors.white,
          borderRadius: BorderRadius.circular(6),
          border: Border(left: BorderSide(color: border, width: 4)),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 3)],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _rt_playSfx(_rt_Sfx.tap);
              _executeStep(idx);
            },
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s['t'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: active ? _brandTeal : _rt_Tw.slate600,
                          ),
                        ),
                      ),
                      if (completed && !active)
                        const Icon(Icons.check, size: 16, color: _rt_Tw.green500)
                      else if (active)
                        const Icon(Icons.play_arrow, size: 16, color: _brandWarn),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(s['d'] as String, style: const TextStyle(fontSize: 11.5, color: _rt_Tw.slate500, height: 1.3)),
                  if (assistLabel != null) ...[
                    const SizedBox(height: 8),
                    _rt_ActionButton(label: assistLabel, icon: Icons.touch_app, color: _brandTeal, onPressed: assist),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ignore: unused_element — kept for reference; tab removed from sidebar
  Widget _whyTab() {
    const icons = {'ski': Icons.downhill_skiing, 'tack': Icons.push_pin, 'truck': Icons.local_shipping};
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          for (final x in _tx.list('why_learn'))
            _rt_InfoCard(
              title: x['title'] as String,
              body: x['desc'] as String,
              icon: icons[x['icon']] ?? Icons.lightbulb,
              color: _brandTeal,
            ),
        ],
      ),
    );
  }

  // ignore: unused_element — kept for reference; tab removed from sidebar
  Widget _outcomesTab() {
    const colors = [_brandTeal, _brandWarn, _rt_Tw.blue500, _rt_Tw.purple500];
    final list = _tx.list('outcomes');
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_SectionLabel(_tx.s('outcomes_title'), color: _rt_Tw.slate700, icon: Icons.track_changes),
          for (var i = 0; i < list.length; i++)
            _rt_InfoCard(
              title: list[i]['title'] as String,
              body: list[i]['desc'] as String,
              color: colors[i % colors.length],
              leftBorder: true,
            ),
        ],
      ),
    );
  }
}

/// Fill-in-the-blanks conclusion (the HTML drag-and-drop sentence).
class _ConclusionPuzzle extends StatefulWidget {
  const _ConclusionPuzzle({required this.onSolved});

  final VoidCallback onSolved;

  @override
  State<_ConclusionPuzzle> createState() => _ConclusionPuzzleState();
}

class _ConclusionPuzzleState extends State<_ConclusionPuzzle> {
  final Map<int, String> _slots = {}; // slot number -> word id
  String? _feedbackKey;
  bool _ok = false;
  bool _locked = false;

  String _wordText(String id) {
    for (final w in _tx.list('words')) {
      if (w['id'] == id) return w['text'] as String;
    }
    return id;
  }

  void _fill(int slot, String id) {
    if (_locked || _slots.containsKey(slot) || _slots.containsValue(id)) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _slots[slot] = id);
  }

  void _tapWord(String id) {
    for (final s in [1, 2]) {
      if (!_slots.containsKey(s)) {
        _fill(s, id);
        return;
      }
    }
  }

  void _check() {
    if (_slots[1] == 'inversely' && _slots[2] == 'area') {
      setState(() {
        _ok = true;
        _locked = true;
        _feedbackKey = 'correct_msg';
      });
      _rt_playSfx(_rt_Sfx.correct);
      widget.onSolved();
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) Navigator.of(context).pop();
      });
    } else {
      setState(() {
        _ok = false;
        _locked = true;
        _feedbackKey = 'hint_wrong';
      });
      _rt_playSfx(_rt_Sfx.wrong);
      // Reset Logic: Clear Slots and Re-populate Bank
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted) return;
        setState(() {
          _feedbackKey = null;
          _slots.clear();
          _locked = false;
        });
      });
    }
  }

  Widget _chip(String text, {bool dragging = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: _rt_Tw.slate700,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: _rt_Tw.slate600),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: dragging ? 0.5 : 0.3),
          blurRadius: dragging ? 14 : 5,
        ),
      ],
    ),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 14,
        decoration: TextDecoration.none,
      ),
    ),
  );

  Widget _slot(int n) {
    final id = _slots[n];
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => id == null && !_locked,
      onAcceptWithDetails: (d) => _fill(n, d.data),
      builder: (context, cand, rej) => GestureDetector(
        onTap: () {
          if (id != null && !_locked) {
            _rt_playSfx(_rt_Sfx.tap);
            setState(() => _slots.remove(n));
          }
        },
        child: Container(
          key: ValueKey('slot-$n'),
          constraints: const BoxConstraints(minWidth: 90, minHeight: 32),
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: id != null ? _brandTeal : _brandWarn.withValues(alpha: cand.isNotEmpty ? 0.3 : 0.1),
            borderRadius: BorderRadius.circular(6),
            border: id != null ? null : Border.all(color: _brandWarn, width: 2),
          ),
          child: Text(
            id == null ? '' : _wordText(id),
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: id != null ? Colors.white : _brandWarn),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _rt_LangBuilder(
      builder: (context, lang) {
        final parts = _tx.list('sentence');
        final words = _tx.list('words');
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 6,
              children: [
                for (final p in parts)
                  if (p == '{1}')
                    _slot(1)
                  else if (p == '{2}')
                    _slot(2)
                  else
                    Text(p as String, style: TextStyle(fontSize: 16, color: _rt_Lab.text, height: 1.6)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              _tx.s('drag_hint'),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: _rt_Tw.slate400),
            ),
            const SizedBox(height: 10),
            Container(
              constraints: const BoxConstraints(minHeight: 60),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _rt_Tw.slate900, borderRadius: BorderRadius.circular(12)),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final w in words)
                    if (!_slots.containsValue(w['id']))
                      Draggable<String>(
                        data: w['id'] as String,
                        maxSimultaneousDrags: _locked ? 0 : 1,
                        feedback: Material(
                          color: Colors.transparent,
                          child: Transform.scale(scale: 1.1, child: _chip(w['text'] as String, dragging: true)),
                        ),
                        childWhenDragging: Opacity(opacity: 0.3, child: _chip(w['text'] as String)),
                        child: GestureDetector(
                          onTap: () => _tapWord(w['id'] as String),
                          child: _chip(w['text'] as String),
                        ),
                      ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 20,
              child: _feedbackKey == null
                  ? null
                  : Text(
                      _tx.s(_feedbackKey!),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _ok ? _rt_Tw.green600 : _rt_Tw.red500),
                    ),
            ),
            const SizedBox(height: 6),
            Center(
              child: _rt_ActionButton(
                label: _tx.s('submit_def'),
                icon: Icons.fact_check,
                color: _brandTeal,
                onPressed: _locked ? null : _check,
              ),
            ),
          ],
        );
      },
    );
  }
}
