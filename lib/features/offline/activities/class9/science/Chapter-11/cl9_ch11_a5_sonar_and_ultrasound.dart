// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Beyond Hearing: SONAR & Ultrasound
// Converted from Cl9S-Ch11-A5-SONARandUltrasound.html (three.js -> mini3d).




// --- TRANSLATION DATA (CONTENT) ---

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
    'header': {'title': 'Beyond Hearing: SONAR & Ultrasound', 'subtitle': 'Class 9 • Sound'},
    'intro': {'title': 'SONAR & Ultrasound', 'desc': 'Class 9 • Sound', 'btn': 'ENTER PHYSICS LAB'},
    'drawer': {'title': 'Interactive _rt_Lab', 'subtitle': 'Physics Concepts'},
    'hud': {
      'title': 'OSCILLOSCOPE',
      'mode': 'MODE:',
      'time': 'TIME (t):',
      'dist': 'DEPTH (d):',
      'sig': 'STATE:',
      'waiting': 'WAITING',
      'ready': 'READY',
      'received': 'RECEIVED',
      'locked': 'LOCKED',
      'fault': 'CRACK DETECTED',
      'clean': '100% CLEAN',
      'echolocation': 'ECHOLOCATION',
      'tapLog': 'TAP TO LOG DATA',
      'actionTask': 'Action Task',
    },
    'modes': {'sonar': 'SONAR', 'flaw': 'FLAW DETECT', 'bio': 'BIOLOGY'},
    'labels': {
      'ship': 'Survey Ship',
      'sub': 'Submarine',
      'whale': 'Whale',
      'block': 'Solid Metal Section',
      'crack': 'Hidden Crack',
      'probe': 'Scanner Probe',
      'bat': 'Bat',
      'moth': 'Moth',
    },
    'ui': {
      'step': 'Step',
      'depth': 'Depth:',
      'ultra': 'Ultrasound',
      'audio': 'Audible (1kHz)',
      'labels': 'Toggle Labels',
      'pan': 'Move/Pan',
      'lock': 'Unlock Interaction',
      'unlock': 'Lock Interaction',
      'settings': 'Settings',
    },
    'settings': {
      'title': '_rt_Lab Settings',
      'theme': 'Theme Appearance',
      'dark': 'Dark',
      'light': 'Light',
      'font': 'Global Font Size:',
      'done': 'Done',
    },
    'explore': [
      {
        'act': 'Oceanography _rt_Lab',
        'concept':
            'SONAR (Sound Navigation and Ranging) uses sound propagation to navigate or detect objects underwater.',
        'task': 'Drag the Research Ship to the center. Then, drag the Submarine down to a hidden depth.',
        'icon': 'grab',
      },
      {
        'act': 'The Pulse',
        'concept':
            'A transmitter emits high-frequency (>20kHz) ultrasound because it travels linearly without scattering.',
        'task': "Tap directly on the Ship's hull to transmit a 50 kHz Ultrasound pulse.",
        'icon': 'tap',
      },
      {
        'act': 'The Reflection',
        'concept': 'When sound waves hit a denser medium (like a metal hull), they bounce back as an echo.',
        'task': 'Observe the physics. The pulse hits the Submarine and bounces back as an Echo.',
        'icon': 'eye',
      },
      {
        'act': 'Time Measurement',
        'concept': 'The distance to the object is proportional to the time it takes for the echo to return.',
        'task': 'Echo returned! The Oscilloscope shows a 1.0s time lag. Tap the Monitor to log this.',
        'icon': 'tap',
      },
      {
        'act': 'Calculating Depth',
        'concept': 'Using d = (v × t) / 2, we halve the total distance because the sound travels there and back.',
        'task': 'Calculate: (1531 × 1.0) / 2 = 765.5 m. Drag the Red Depth Marker down to 765m.',
        'icon': 'updown',
      },
      {
        'act': 'Variable Challenge',
        'concept': 'Different objects reflect at different times depending on their depth.',
        'task': 'A Whale! Tap Ship to ping, wait for echo, then calculate ((1531 × 2.0)/2 = 1531m) and drag marker.',
        'icon': 'calc',
      },
      {
        'act': 'Industrial Flaw Detection',
        'concept': 'Ultrasound can penetrate solid objects like metal to check for internal structural integrity.',
        'task': 'Factory Mode. Drag the green Scanner Probe onto the left side of the Metal Block.',
        'icon': 'grab',
      },
      {
        'act': 'Scanning Perfect Metal',
        'concept': 'In a uniform medium, ultrasound waves pass straight through to the receiver.',
        'task': 'Drag the Probe over the clean left section. Watch waves pass straight through.',
        'icon': 'leftright',
      },
      {
        'act': 'Scanning the Flaw',
        'concept': 'Internal cracks cause premature reflection, indicating a flaw to the detectors.',
        'task': 'Drag Probe over the right side. Waves hit the hidden crack and reflect early!',
        'icon': 'leftright',
      },
      {
        'act': 'Defect Analysis',
        'concept':
            'Why use Ultrasound? Low-frequency (audible) sound has long wavelengths that diffract (bend) around small flaws.',
        'task': 'Use the toggle switch below to change to Audible Sound. Long waves bend around the crack!',
        'icon': 'toggle',
      },
      {
        'act': 'Biological Analogy',
        'concept': 'Many animals use natural echolocation to navigate and hunt in complete darkness.',
        'task': 'Night Mode. Drag the Bat towards the Moth. Watch it use Echolocation to find prey.',
        'icon': 'grab',
      },
      {
        'act': 'Conclusion',
        'concept':
            'SONAR, industrial flaw detection, and echolocation are all built on the same principle of sound reflection.',
        'task': 'Synthesize your learning: Drag and drop the applications into their correct fields.',
        'icon': 'puzzle',
      },
    ],
    'quiz': {
      'title': 'Module Conclusion',
      'desc': 'Drag applications to correct fields:',
      'l1': 'Oceanography / Navigation',
      'l2': 'Industrial Safety',
      'l3': 'Biology / Nature',
      'a1': 'SONAR',
      'a2': 'Flaw Detection',
      'a3': 'Echolocation',
    },
    'modal': {
      'title': 'Simulation Complete!',
      'outcomeB': 'Learning Outcome:',
      'outcome1': ' Ultrasound reflects off objects and flaws. Distance is calculated using ',
      'formula': 'd = (v × t)/2',
      'outcome2': '.',
      'findingB': 'Key Finding:',
      'finding':
          ' High frequency (Ultrasound) is required for flaw detection because its short wavelength reflects rather than diffracts around small cracks.',
      'btn': 'Restart _rt_Lab',
    },
  },
  'hi': {
    'header': {'title': 'श्रवण से परे: सोनार और अल्ट्रासाउंड', 'subtitle': 'कक्षा 9 • ध्वनि'},
    'intro': {'title': 'सोनार और अल्ट्रासाउंड', 'desc': 'कक्षा 9 • ध्वनि', 'btn': 'भौतिकी लैब में प्रवेश करें'},
    'drawer': {'title': 'इंटरैक्टिव लैब', 'subtitle': 'भौतिकी अवधारणाएँ'},
    'hud': {
      'title': 'ऑसिलोस्कोप',
      'mode': 'मोड:',
      'time': 'समय (t):',
      'dist': 'गहराई (d):',
      'sig': 'स्थिति:',
      'waiting': 'प्रतीक्षा',
      'ready': 'तैयार',
      'received': 'प्राप्त',
      'locked': 'लॉक',
      'fault': 'दरार पाई गई',
      'clean': '100% साफ',
      'echolocation': 'इकोलोकेशन',
      'tapLog': 'डेटा लॉग करने के लिए टैप करें',
      'actionTask': 'कार्य',
    },
    'modes': {'sonar': 'सोनार', 'flaw': 'दोष पहचान', 'bio': 'जीव विज्ञान'},
    'labels': {
      'ship': 'सर्वेक्षण जहाज',
      'sub': 'पनडुब्बी',
      'whale': 'व्हेल',
      'block': 'ठोस धातु खंड',
      'crack': 'छिपी दरार',
      'probe': 'स्कैनर प्रोब',
      'bat': 'चमगादड़',
      'moth': 'पतंगा',
    },
    'ui': {
      'step': 'चरण',
      'depth': 'गहराई:',
      'ultra': 'अल्ट्रासाउंड',
      'audio': 'श्रव्य (1kHz)',
      'labels': 'लेबल दिखाएँ/छिपाएँ',
      'pan': 'खिसकाएँ',
      'lock': 'इंटरैक्शन अनलॉक करें',
      'unlock': 'इंटरैक्शन लॉक करें',
      'settings': 'सेटिंग्स',
    },
    'settings': {
      'title': 'लैब सेटिंग्स',
      'theme': 'थीम रूप',
      'dark': 'डार्क',
      'light': 'लाइट',
      'font': 'फ़ॉन्ट आकार:',
      'done': 'पूर्ण',
    },
    'explore': [
      {
        'act': 'समुद्र विज्ञान लैब',
        'concept':
            'सोनार (साउंड नेविगेशन एंड रेंजिंग) पानी के नीचे नेविगेट करने या वस्तुओं का पता लगाने के लिए ध्वनि प्रसार का उपयोग करता है।',
        'task': 'अनुसंधान जहाज को केंद्र में खींचें। फिर, पनडुब्बी को एक छिपी हुई गहराई तक नीचे खींचें।',
        'icon': 'grab',
      },
      {
        'act': 'पल्स',
        'concept':
            'एक ट्रांसमीटर उच्च-आवृत्ति (>20kHz) अल्ट्रासाउंड का उत्सर्जन करता है क्योंकि यह बिना बिखरे रैखिक रूप से यात्रा करता है।',
        'task': '50 kHz अल्ट्रासाउंड पल्स प्रसारित करने के लिए सीधे जहाज के पतवार पर टैप करें।',
        'icon': 'tap',
      },
      {
        'act': 'परावर्तन',
        'concept':
            'जब ध्वनि तरंगें सघन माध्यम (जैसे धातु के पतवार) से टकराती हैं, तो वे गूँज के रूप में वापस लौट आती हैं।',
        'task': 'भौतिकी का निरीक्षण करें। पल्स पनडुब्बी से टकराता है और गूँज के रूप में वापस उछलता है।',
        'icon': 'eye',
      },
      {
        'act': 'समय मापन',
        'concept': 'वस्तु की दूरी उस समय के समानुपाती होती है जो गूँज को लौटने में लगता है।',
        'task': 'गूँज वापस आ गई है! ऑसिलोस्कोप 1.0s समय अंतराल दिखाता है। इसे लॉग करने के लिए मॉनिटर पर टैप करें।',
        'icon': 'tap',
      },
      {
        'act': 'गहराई की गणना',
        'concept':
            'd = (v × t) / 2 का उपयोग करके, हम कुल दूरी को आधा कर देते हैं क्योंकि ध्वनि वहां जाती है और वापस आती है।',
        'task': 'गणना: (1531 × 1.0) / 2 = 765.5 m। लाल गहराई मार्कर को 765m तक नीचे खींचें।',
        'icon': 'updown',
      },
      {
        'act': 'परिवर्तनीय चुनौती',
        'concept': 'विभिन्न वस्तुएं अपनी गहराई के आधार पर अलग-अलग समय पर परावर्तित होती हैं।',
        'task':
            'एक व्हेल! पिंग करने के लिए जहाज पर टैप करें, गूँज की प्रतीक्षा करें, फिर गणना करें ((1531 × 2.0)/2 = 1531m) और मार्कर को खींचें।',
        'icon': 'calc',
      },
      {
        'act': 'औद्योगिक दोष पहचान',
        'concept':
            'अल्ट्रासाउंड आंतरिक संरचनात्मक अखंडता की जांच करने के लिए धातु जैसी ठोस वस्तुओं में प्रवेश कर सकता है।',
        'task': 'फैक्ट्री मोड। हरे स्कैनर प्रोब को धातु ब्लॉक के बाईं ओर खींचें।',
        'icon': 'grab',
      },
      {
        'act': 'सही धातु की स्कैनिंग',
        'concept': 'एक समान माध्यम में, अल्ट्रासाउंड तरंगें सीधे रिसीवर तक जाती हैं।',
        'task': 'स्कैनर प्रोब को साफ बाएं हिस्से पर खींचें। तरंगों को सीधे गुजरते हुए देखें।',
        'icon': 'leftright',
      },
      {
        'act': 'दोष की स्कैनिंग',
        'concept': 'आंतरिक दरारें समय से पहले परावर्तन का कारण बनती हैं, जो डिटेक्टरों को एक दोष का संकेत देती हैं।',
        'task': 'प्रोब को दाईं ओर खींचें। तरंगें छिपी हुई दरार से टकराती हैं और जल्दी परावर्तित हो जाती हैं!',
        'icon': 'leftright',
      },
      {
        'act': 'दोष विश्लेषण',
        'concept':
            'अल्ट्रासाउंड का उपयोग क्यों करें? कम-आवृत्ति (श्रव्य) ध्वनि में लंबी तरंग दैर्ध्य होती है जो छोटी खामियों के चारों ओर विवर्तित (झुकती) होती है।',
        'task':
            'श्रव्य ध्वनि में बदलने के लिए नीचे दिए टॉगल स्विच का उपयोग करें। लंबी तरंगें दरार के चारों ओर मुड़ जाती हैं!',
        'icon': 'toggle',
      },
      {
        'act': 'जैविक सादृश्य',
        'concept': 'कई जानवर पूर्ण अंधेरे में नेविगेट करने और शिकार करने के लिए प्राकृतिक इकोलोकेशन का उपयोग करते हैं।',
        'task': 'नाइट मोड। चमगादड़ को पतंगे की ओर खींचें। इसे शिकार खोजने के लिए इकोलोकेशन का उपयोग करते हुए देखें।',
        'icon': 'grab',
      },
      {
        'act': 'निष्कर्ष',
        'concept': 'सोनार, औद्योगिक दोष का पता लगाना, और इकोलोकेशन सभी ध्वनि परावर्तन के एक ही सिद्धांत पर बने हैं।',
        'task': 'अपने सीखने को संश्लेषित करें: अनुप्रयोगों को उनके सही क्षेत्रों में खींचें और छोड़ें।',
        'icon': 'puzzle',
      },
    ],
    'quiz': {
      'title': 'मॉड्यूल निष्कर्ष',
      'desc': 'अनुप्रयोगों को सही क्षेत्रों में खींचें:',
      'l1': 'समुद्र विज्ञान / नेविगेशन',
      'l2': 'औद्योगिक सुरक्षा',
      'l3': 'जीव विज्ञान / प्रकृति',
      'a1': 'सोनार (SONAR)',
      'a2': 'दोष का पता लगाना',
      'a3': 'इकोलोकेशन',
    },
    'modal': {
      'title': 'सिमुलेशन पूर्ण!',
      'outcomeB': 'सीखने का परिणाम:',
      'outcome1': ' अल्ट्रासाउंड वस्तुओं और खामियों से परावर्तित होता है। दूरी की गणना ',
      'formula': 'd = (v × t)/2',
      'outcome2': ' का उपयोग करके की जाती है।',
      'findingB': 'मुख्य निष्कर्ष:',
      'finding':
          ' दोष का पता लगाने के लिए उच्च आवृत्ति (अल्ट्रासाउंड) की आवश्यकता होती है क्योंकि इसका छोटा तरंग दैर्ध्य छोटी दरारों के चारों ओर विवर्तन के बजाय परावर्तित होता है।',
      'btn': 'पुनः आरंभ करें',
    },
  },
});

const _teal400 = _rt_Tw.teal400;
const _teal700 = _rt_Tw.teal700;

const Map<String, IconData> _stepIcons = {
  'grab': Icons.back_hand,
  'tap': Icons.touch_app,
  'eye': Icons.visibility,
  'updown': Icons.swap_vert,
  'calc': Icons.calculate,
  'leftright': Icons.swap_horiz,
  'toggle': Icons.toggle_on,
  'puzzle': Icons.extension,
};

class Cl9Ch11A5SonarAndUltrasoundPage extends StatefulWidget {
  const Cl9Ch11A5SonarAndUltrasoundPage({super.key});

  @override
  State<Cl9Ch11A5SonarAndUltrasoundPage> createState() => _Cl9Ch11A5SonarAndUltrasoundPageState();
}

class _Cl9Ch11A5SonarAndUltrasoundPageState extends State<Cl9Ch11A5SonarAndUltrasoundPage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(background: const Color(0xFF020617));
  final _rt_Camera3D _camera = _rt_Camera3D(fov: 30, position: _rt_V3(0, 0, 150), target: _rt_V3(0, -20, 0));
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner();
  final _rt_ShellController _shell = _rt_ShellController();
  final math.Random _rng = math.Random();

  // Scene objects
  late _rt_Node3D _s1Group, _s2Group, _s3Group;
  late _rt_Node3D _ship, _sub, _whale, _pulses, _probe, _diffRays, _bat, _moth, _batPulses;
  late _rt_Mesh3D _shipCone, _block, _crack, _sensorBox, _bWing1, _bWing2;
  final List<_rt_Mesh3D> _rays = [];
  final Map<String, (_rt_Label3D, _rt_Node3D, double)> _labels = {};

  // --- STATE ---
  int _step = 0;
  bool _isAnimating = false;
  bool _whalePinged = false;
  final Set<int> _stepDoneFlags = {};
  bool _isDragging = false;
  String? _dragTarget;
  double _time = 0;
  int _gen = 0;
  bool _completed = false;
  Size _canvasSize = const Size(640, 412);

  bool _labelsVisible = true;
  bool _panMode = false;
  bool _locked = true;
  bool _lightMode = false;
  double _fontSize = 16;

  // HUD
  String _hudModeKey = 'sonar';
  String _hudTime = '-- s';
  String _hudDist = '-- m';
  String _hudSigKey = 'waiting';
  bool _tapGuide = false;

  // Message HUD (draggable)
  Offset _msgDrag = Offset.zero;

  // Depth marker
  double _markerFrac = 0.3;
  double _markerRaw = 0.3;
  String _depthVal = '0';
  bool _audioMode = false;

  // Quiz
  final Set<int> _quizDone = {};
  List<int> _quizOrder = [0, 1, 2];
  int? _quizSelected;
  int? _quizWrongZone;
  Offset _quizDrag = Offset.zero;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _camera.enableRotate = false;
    _scene.setLights([_rt_Light3D.ambient(intensity: 1.0), _rt_Light3D.directional(_rt_V3(0, 50, 50), intensity: 0.8)]);
    _buildScenario1();
    _buildScenario2();
    _buildScenario3();
    _loadStep(0, animateCamera: false);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _gen++;
    _tweens.cancelAll();
    _viewCtrl.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ scene ---
  void _addLabel(_rt_Node3D obj, String key, double offset) {
    final l = _rt_Label3D(
      '',
      pixelHeight: 12,
      background: const Color(0xCC0F172A),
      borderColor: _teal400,
      color: Colors.white,
    )..pickable = false;
    _scene.add(l);
    _labels[key] = (l, obj, offset);
  }

  void _updateLabels() {
    for (final e in _labels.entries) {
      final (l, obj, off) = e.value;
      l.text = _tx.s('labels.${e.key}');
      l.visible = _labelsVisible && obj.isVisibleInTree;
      final p = obj.worldPosition;
      l.position.set(p.x, p.y + off, p.z);
    }
  }

  _rt_Mesh3D _invisibleBox(double w, double h, double d) =>
      _rt_Mesh3D(_rt_Geometry3D.box(w, h, d), _rt_Material3D(opacity: 0, unlit: true))..depthBias = 50;

  void _buildScenario1() {
    _s1Group = _rt_Node3D(name: 's1');
    _rt_Mesh3D bg(double w, double h, Color c, {double opacity = 1}) =>
        _rt_Mesh3D(_rt_Geometry3D.plane(w, h), _rt_Material3D(color: c, unlit: true, opacity: opacity))..pickable = false;
    _s1Group.add(
      bg(400, 200, const Color(0xFF87CEEB))
        ..position.set(0, 100, -20)
        ..depthBias = 500,
    );
    _s1Group.add(
      bg(400, 200, const Color(0xFF0284C7), opacity: 0.85)
        ..position.set(0, -100, -15)
        ..depthBias = 400,
    );
    _s1Group.add(
      bg(400, 100, const Color(0xFFD97706))
        ..position.set(0, -120, -10)
        ..depthBias = 300,
    );
    _s1Group.add(
      bg(400, 0.5, const Color(0xFF38BDF8))
        ..position.set(0, 0, -14)
        ..depthBias = 200,
    );

    // Ship
    _ship = _rt_Node3D(name: 'ship')..position.set(-40, 2, 0);
    final hull = _rt_Mesh3D(_rt_Geometry3D.box(16, 3, 4), _rt_Material3D(color: const Color(0xFFE2E8F0), shininess: 0.5));
    final bot = _rt_Mesh3D(_rt_Geometry3D.box(14, 1.5, 3), _rt_Material3D(color: const Color(0xFF9F1239)))..position.y = -2.25;
    final cabin = _rt_Mesh3D(_rt_Geometry3D.box(6, 4, 3), _rt_Material3D(color: Colors.white))..position.set(-2, 3.5, 0);
    _shipCone = _rt_Mesh3D(_rt_Geometry3D.cone(0.8, 1.5, segments: 16), _rt_Material3D(color: const Color(0xFFFF0000)))
      ..rotation.x = math.pi
      ..position.y = -3.5;
    _ship.addAll([hull, bot, cabin, _shipCone, _invisibleBox(20, 10, 10)]);
    _s1Group.add(_ship);
    _addLabel(_ship, 'ship', 8);

    // Submarine
    _sub = _rt_Node3D(name: 'sub')..position.set(25, -20, 0);
    final subMat = _rt_Material3D(color: const Color(0xFFEAB308), shininess: 0.5);
    final subBody = _rt_Mesh3D(_rt_Geometry3D.cylinder(2.5, 2.5, 16, segments: 24), subMat)..rotation.z = math.pi / 2;
    final subNose = _rt_Sphere3D(2.5, subMat)..position.x = 8;
    final subTail = _rt_Mesh3D(_rt_Geometry3D.cone(2.5, 6, segments: 24), subMat)
      ..position.x = -11
      ..rotation.z = -math.pi / 2;
    final tower = _rt_Mesh3D(_rt_Geometry3D.box(3, 3, 2), subMat)..position.set(3, 3.5, 0);
    final prop = _rt_Mesh3D(_rt_Geometry3D.cylinder(1.5, 1.5, 0.5, segments: 16), _rt_Material3D(color: const Color(0xFF9CA3AF)))
      ..position.x = -14
      ..rotation.z = math.pi / 2;
    _sub.addAll([subBody, subNose, subTail, tower, prop, _invisibleBox(30, 10, 10)]);
    _s1Group.add(_sub);
    _addLabel(_sub, 'sub', 6);

    // Whale
    _whale = _rt_Node3D(name: 'whale')..position.set(-20, -40, 0);
    final wMat = _rt_Material3D(color: const Color(0xFF334155), shininess: 0.3);
    final wBody = _rt_Mesh3D(_rt_Geometry3D.sphere(4, widthSegments: 20, heightSegments: 12), wMat)..scale.set(2, 1, 0.8);
    final wTail = _rt_Mesh3D(_rt_Geometry3D.cone(2, 5, segments: 16), wMat)
      ..position.set(9.5, 0, 0)
      ..rotation.z = -math.pi / 2;
    final wTailFin = _rt_Mesh3D(_rt_Geometry3D.cylinder(2, 2, 0.5, segments: 3), wMat)
      ..position.set(12, 0, 0)
      ..rotation.x = math.pi / 2
      ..scale.set(1, 4, 1);
    final wFlip1 = _rt_Mesh3D(_rt_Geometry3D.cone(1, 4, segments: 12), wMat)
      ..position.set(0, -2, 2)
      ..rotation.x = math.pi / 4
      ..rotation.z = -math.pi / 4;
    final wFlip2 = _rt_Mesh3D(_rt_Geometry3D.cone(1, 4, segments: 12), wMat)
      ..position.set(0, -2, -2)
      ..rotation.x = -math.pi / 4
      ..rotation.z = -math.pi / 4;
    final wEye = _rt_Sphere3D(0.3, _rt_Material3D(color: Colors.black, unlit: true))..position.set(-5, 1, 3.3);
    _whale.addAll([wBody, wTail, wTailFin, wFlip1, wFlip2, wEye, _invisibleBox(26, 10, 10)]);
    _whale.visible = false;
    _s1Group.add(_whale);
    _addLabel(_whale, 'whale', 5);

    // Pulses
    _pulses = _rt_Node3D();
    for (var i = 0; i < 4; i++) {
      _pulses.add(
        _rt_Mesh3D(
            _rt_Geometry3D.ring(0.8, 1.4, segments: 40),
            _rt_Material3D(color: const Color(0xFF22D3EE), opacity: 0, doubleSided: true, unlit: true),
          )
          ..pickable = false
          ..depthBias = -20,
      );
    }
    _s1Group.add(_pulses);
    _scene.add(_s1Group);
  }

  void _buildScenario2() {
    _s2Group = _rt_Node3D(name: 's2');
    _s2Group.add(
      _rt_Mesh3D(_rt_Geometry3D.plane(400, 400), _rt_Material3D(color: const Color(0xFFCBD5E1), unlit: true))
        ..position.z = -20
        ..depthBias = 500
        ..pickable = false,
    );

    // Metal Block
    _block =
        _rt_Mesh3D(_rt_Geometry3D.plane(30, 15), _rt_Material3D(color: const Color(0xFF475569), doubleSided: true, unlit: true))
          ..position.y = -5
          ..depthBias = 10
          ..pickable = false;
    _s2Group.add(_block);
    _addLabel(_block, 'block', 9);

    // Crack
    _crack = _rt_Mesh3D(_rt_Geometry3D.plane(4, 0.8), _rt_Material3D(color: const Color(0xFFEF4444), unlit: true))
      ..position.set(7, -5, 0.1)
      ..pickable = false;
    _s2Group.add(_crack);
    _addLabel(_crack, 'crack', -2);

    // Probe
    _probe = _rt_Node3D(name: 'probe')..position.set(-15, 3.5, 0.2);
    _probe.addAll([
      _rt_Mesh3D(_rt_Geometry3D.box(4, 2, 1), _rt_Material3D(color: const Color(0xFF10B981), unlit: true)),
      _invisibleBox(10, 8, 4),
    ]);
    _s2Group.add(_probe);
    _addLabel(_probe, 'probe', 3);

    // Sensors
    _sensorBox = _rt_Mesh3D(_rt_Geometry3D.box(4, 1, 1), _rt_Material3D(color: const Color(0xFF10B981), unlit: true))
      ..position.set(-15, -13, 0.2)
      ..pickable = false;
    _s2Group.add(_sensorBox);

    // Rays
    for (var i = 0; i < 3; i++) {
      final r = _rt_Mesh3D(_rt_Geometry3D.plane(0.3, 15), _rt_Material3D(color: const Color(0xFF3B82F6), opacity: 0.9, unlit: true))
        ..position.set(-15 + (i - 1) * 0.5, -5, 0.1)
        ..pickable = false
        ..depthBias = -1;
      _s2Group.add(r);
      _rays.add(r);
    }

    // Diff Rays (Audible)
    _diffRays = _rt_Node3D();
    for (var i = 0; i < 4; i++) {
      _diffRays.add(
        _rt_Mesh3D(
            _rt_Geometry3D.ring(1.8, 2.2, segments: 24, thetaStart: 0, thetaLength: math.pi),
            _rt_Material3D(color: const Color(0xFFFACC15), opacity: 0.8, unlit: true, doubleSided: true),
          )
          ..position.set(7, -5 - i * 2.0, 0.1)
          ..rotation.z = math.pi
          ..depthBias = -2
          ..pickable = false,
      );
    }
    _diffRays.visible = false;
    _s2Group.add(_diffRays);

    _s2Group.visible = false;
    _scene.add(_s2Group);
  }

  _rt_Geometry3D _shape(List<Offset> pts) =>
      _rt_Geometry3D([for (final p in pts) _rt_V3(p.dx, p.dy, 0)], [List.generate(pts.length, (i) => i)]);

  /// Samples a THREE.Shape made of lines and quadratic curves.
  List<Offset> _wingPath(Offset start, List<List<double>> segs) {
    final pts = <Offset>[start];
    var cur = start;
    for (final s in segs) {
      if (s.length == 2) {
        cur = Offset(s[0], s[1]);
        pts.add(cur);
      } else {
        final c = Offset(s[0], s[1]), e = Offset(s[2], s[3]);
        for (var k = 1; k <= 6; k++) {
          final t = k / 6;
          pts.add(cur * ((1 - t) * (1 - t)) + c * (2 * (1 - t) * t) + e * (t * t));
        }
        cur = e;
      }
    }
    return pts;
  }

  void _buildScenario3() {
    _s3Group = _rt_Node3D(name: 's3');
    _s3Group.add(
      _rt_Mesh3D(_rt_Geometry3D.plane(400, 400), _rt_Material3D(color: const Color(0xFF0F172A), unlit: true))
        ..position.z = -20
        ..depthBias = 500
        ..pickable = false,
    );
    // Stars
    final stars = <_rt_V3>[
      for (var i = 0; i < 30; i++) _rt_V3((_rng.nextDouble() - 0.5) * 100, (_rng.nextDouble() - 0.5) * 80, -19),
    ];
    _s3Group.add(_rt_Points3D(stars, color: Colors.white, size: 5)..depthBias = 400);

    // Bat
    _bat = _rt_Node3D(name: 'bat')..position.set(-25, 0, 0);
    final bodyMat = _rt_Material3D(color: const Color(0xFF6A6D8A), unlit: true);
    final wingMat = _rt_Material3D(color: const Color(0xFF8386A6), unlit: true, doubleSided: true);
    final pinkMat = _rt_Material3D(color: const Color(0xFFFBCAD2), unlit: true);
    final blackMat = _rt_Material3D(color: Colors.black, unlit: true, doubleSided: true);
    final whiteMat = _rt_Material3D(color: Colors.white, unlit: true);

    final g = _rt_Node3D();
    g.add(_rt_Sphere3D(1.5, blackMat)..position.set(0, 0.8, -0.1));
    g.add(_rt_Sphere3D(1.4, bodyMat)..position.set(0, 0.8, 0));
    g.add(
      _rt_Mesh3D(_rt_Geometry3D.sphere(1.3, widthSegments: 16, heightSegments: 10), blackMat)
        ..scale.set(1, 1.2, 0.8)
        ..position.set(0, -0.5, -0.4),
    );
    g.add(
      _rt_Mesh3D(_rt_Geometry3D.sphere(1.2, widthSegments: 16, heightSegments: 10), bodyMat)
        ..scale.set(1, 1.2, 0.8)
        ..position.set(0, -0.5, -0.1),
    );

    _rt_Node3D ear(double x, double rz) {
      final e = _rt_Node3D()
        ..position.set(x, 2.2, -0.2)
        ..rotation.z = rz;
      e.add(_rt_Mesh3D(_rt_Geometry3D.cone(0.8, 2.0, segments: 12), blackMat)..position.set(0, 0, -0.1));
      e.add(_rt_Mesh3D(_rt_Geometry3D.cone(0.7, 1.8, segments: 12), bodyMat));
      e.add(
        _rt_Mesh3D(_rt_Geometry3D.cone(0.4, 1.4, segments: 12), pinkMat)
          ..position.set(0, -0.1, 0.2)
          ..rotation.x = 0.1
          ..depthBias = -0.5,
      );
      return e;
    }

    g.addAll([ear(-0.8, math.pi / 8), ear(0.8, -math.pi / 8)]);
    for (final sx in [-1.0, 1.0]) {
      g.add(
        _rt_Mesh3D(_rt_Geometry3D.sphere(0.18, widthSegments: 10, heightSegments: 8), blackMat)
          ..scale.set(1, 1.5, 0.5)
          ..position.set(0.4 * sx, 1.0, 1.35)
          ..depthBias = -2,
      );
      g.add(
        _rt_Mesh3D(_rt_Geometry3D.box(0.2, 0.05, 0.05), blackMat)
          ..position.set(0.4 * sx, 1.4, 1.35)
          ..rotation.z = -sx * math.pi / 8
          ..depthBias = -2,
      );
      g.add(
        _rt_Mesh3D(_rt_Geometry3D.cone(0.06, 0.3, segments: 8), whiteMat)
          ..rotation.x = math.pi
          ..position.set(0.25 * sx, 0.45, 1.39)
          ..depthBias = -2,
      );
    }
    g.add(
      _rt_Mesh3D(_rt_Geometry3D.circle(0.04, segments: 8), whiteMat)
        ..position.set(-0.45, 1.1, 1.45)
        ..depthBias = -3,
    );
    g.add(
      _rt_Mesh3D(_rt_Geometry3D.circle(0.04, segments: 8), whiteMat)
        ..position.set(0.35, 1.1, 1.45)
        ..depthBias = -3,
    );
    g.add(
      _rt_Mesh3D(_rt_Geometry3D.circle(0.12, segments: 3), pinkMat)
        ..rotation.z = -math.pi / 2
        ..position.set(0, 0.65, 1.4)
        ..depthBias = -2,
    );
    g.add(
      _rt_Mesh3D(_rt_Geometry3D.torus(0.2, 0.04, radialSegments: 6, tubularSegments: 12, arc: math.pi), blackMat)
        ..position.set(0, 0.55, 1.38)
        ..rotation.z = math.pi
        ..rotation.x = math.pi / 10
        ..depthBias = -2,
    );
    for (final sx in [-1.0, 1.0]) {
      final foot = _rt_Node3D()
        ..position.set(0.6 * sx, -2, -0.3)
        ..rotation.z = -sx * math.pi / 10
        ..rotation.x = math.pi;
      foot.add(_rt_Mesh3D(_rt_Geometry3D.cone(0.6, 2.7, segments: 10), blackMat)..position.z = -0.1);
      foot.add(_rt_Mesh3D(_rt_Geometry3D.cone(0.5, 2.5, segments: 10), bodyMat));
      g.add(foot);
    }

    List<Offset> mirror(List<Offset> p) => [for (final o in p) Offset(-o.dx, o.dy)];
    final lWing = _wingPath(Offset.zero, [
      [-2, 2],
      [-6, 1],
      [-4, -0.5, -4.5, -2.5],
      [-2.5, -1, -1.5, -2.5],
      [-0.5, -1, 0, -1],
    ]);
    final lWingOutline = _wingPath(const Offset(0.2, 0.2), [
      [-2, 2.3],
      [-6.3, 1.2],
      [-4, -0.6, -4.6, -2.8],
      [-2.5, -1.2, -1.5, -2.8],
      [-0.5, -1.2, 0.2, -1.2],
    ]);
    _bWing1 = _rt_Mesh3D(_shape(lWing), wingMat)..position.set(-0.8, 0.5, -0.5);
    _bWing1.add(_rt_Mesh3D(_shape(lWingOutline), blackMat)..position.z = -0.05);
    _bWing2 = _rt_Mesh3D(_shape(mirror(lWing)), wingMat)..position.set(0.8, 0.5, -0.5);
    _bWing2.add(_rt_Mesh3D(_shape(mirror(lWingOutline)), blackMat)..position.z = -0.05);

    final bHit = _rt_Sphere3D(8, _rt_Material3D(opacity: 0, unlit: true))..depthBias = 50;
    _bat.addAll([_bWing1, _bWing2, g, bHit]);
    _bat.scale.set(1.2, 1.2, 1.2);
    _s3Group.add(_bat);
    _addLabel(_bat, 'bat', 5);

    _moth = _rt_Node3D()..position.set(20, 0, 0);
    _moth.add(_rt_Sphere3D(0.8, _rt_Material3D(color: const Color(0xFFFACC15), unlit: true)));
    _s3Group.add(_moth);
    _addLabel(_moth, 'moth', 3);

    _batPulses = _rt_Node3D();
    for (var i = 0; i < 3; i++) {
      _batPulses.add(
        _rt_Mesh3D(
          _rt_Geometry3D.ring(0.5, 0.8, segments: 20, thetaStart: -math.pi / 2, thetaLength: math.pi),
          _rt_Material3D(color: const Color(0xFF38BDF8), opacity: 0, doubleSided: true, unlit: true),
        )..pickable = false,
      );
    }
    _s3Group.add(_batPulses);

    _s3Group.visible = false;
    _scene.add(_s3Group);
  }

  void _onFrame(double dt) {
    _tweens.update(dt);
    _time += 0.02 * dt * 60;
    if (_s1Group.visible && !_isDragging) {
      _ship.position.y = 2 + math.sin(_time) * 0.2;
      _ship.rotation.z = math.sin(_time * 0.5) * 0.02;
    }
    if (_diffRays.visible) {
      for (var i = 0; i < _diffRays.children.length; i++) {
        final s = 1 + math.sin(_time * 2 + i) * 0.1;
        _diffRays.children[i].scale.set(s, s, s);
      }
    }
    if (_s3Group.visible) {
      _moth.position.y = math.cos(_time * 2) * 2;
      _bWing1.rotation.y = math.sin(_time * 10) * 0.5;
      _bWing2.rotation.y = -math.sin(_time * 10) * 0.5;
      // Echolocation clicks travelling from the bat towards the prey.
      final hunting = _moth.scale.x > 0.01;
      for (var i = 0; i < _batPulses.children.length; i++) {
        final r = _batPulses.children[i] as _rt_Mesh3D;
        final ph = (_time * 0.6 + i / 3) % 1.0;
        r.position.set(_bat.position.x + 2.5 + ph * 12, _bat.position.y + 0.6, 0.3);
        final s = 1 + ph * 4;
        r.scale.set(s, s, 1);
        r.material.opacity = hunting ? (1 - ph) * 0.8 : 0;
      }
    }
    _updateLabels();
  }

  // -------------------------------------------------------- interaction ---
  bool _onPointerDown(_rt_SceneEvent e) {
    if (_isAnimating || _panMode) return false;
    if (_step == 0) {
      if (e.hitNamed('ship') != null) {
        _isDragging = true;
        _dragTarget = 'ship';
        return true;
      } else if (e.hitNamed('sub') != null) {
        _isDragging = true;
        _dragTarget = 'sub';
        return true;
      }
    } else if (_step == 1) {
      if (e.hitNamed('ship') != null) {
        _actionPulse();
        return true;
      }
    } else if (_step == 5 && !_whalePinged) {
      if (e.hitNamed('ship') != null) {
        _actionWhalePing();
        return true;
      }
    } else if (_step >= 6 && _step <= 9) {
      if (e.hitNamed('probe') != null) {
        _isDragging = true;
        _dragTarget = 'probe';
        return true;
      }
    } else if (_step == 10) {
      if (e.hitNamed('bat') != null) {
        _isDragging = true;
        _dragTarget = 'bat';
        return true;
      }
    }
    return false;
  }

  void _onPointerMove(_rt_SceneEvent e) {
    if (_isAnimating || !_isDragging) return;
    final pt = e.ray.intersectZ(0);
    if (pt == null) return;
    _dragTo(pt.x, pt.y);
  }

  void _dragTo(double x, double y) {
    switch (_dragTarget) {
      case 'ship':
        _ship.position.x = x.clamp(-40.0, 40.0);
        _checkSetupComplete();
      case 'sub':
        _sub.position.x = x.clamp(-30.0, 30.0);
        _sub.position.y = y.clamp(-45.0, -10.0);
        _checkSetupComplete();
      case 'probe':
        _probe.position.x = x.clamp(-15.0, 15.0);
        _sensorBox.position.x = _probe.position.x;
        _updateIndustrialRays(_probe.position.x);
        final px = _probe.position.x;
        final g = _gen;
        if (_step == 6 && px > -12) {
          if (_stepDoneFlags.add(6)) {
            _rt_playSfx(_rt_Sfx.correct);
            Future.delayed(const Duration(milliseconds: 600), () {
              if (!mounted || g != _gen) return;
              _onUp();
              _advanceStep();
            });
          }
        } else if (_step == 7 && px > -8 && px < -2) {
          if (_stepDoneFlags.add(7)) {
            Future.delayed(const Duration(milliseconds: 1500), () {
              if (!mounted || g != _gen) return;
              _rt_playSfx(_rt_Sfx.correct);
              _onUp();
              _advanceStep();
            });
          }
        } else if (_step == 8 && (px - 7).abs() < 2.5) {
          if (_stepDoneFlags.add(8)) {
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (!mounted || g != _gen) return;
              _rt_playSfx(_rt_Sfx.correct);
              _onUp();
              _advanceStep();
            });
          }
        }
      case 'bat':
        _bat.position.x = x.clamp(-25.0, 15.0);
        _bat.position.y = y.clamp(-15.0, 15.0);
        if (_rng.nextDouble() > 0.8) _rt_playSfx(_rt_Sfx.tap, volume: 0.15);
        if (_bat.position.x > 10) {
          _onUp();
          _actionBatCatch();
        }
    }
  }

  void _onUp() {
    _isDragging = false;
  }

  void _checkSetupComplete() {
    if (_step == 0 && _ship.position.x.abs() < 10 && _sub.position.y < -15) {
      if (_stepDoneFlags.add(0)) {
        _isDragging = false;
        final sx = _ship.position.x, ux = _sub.position.x;
        final g = _gen;
        _tweens
            .run(500, (t) {
              _ship.position.x = sx * (1 - t);
              _sub.position.x = ux * (1 - t);
            })
            .then((_) {
              if (mounted && g == _gen) _advanceStep();
            });
      }
    }
  }

  Future<void> _animateSonar(double targetY, Color color, bool reverse) async {
    final startY = reverse ? targetY : 0.0;
    final endY = reverse ? 0.0 : targetY;
    _pulses.position.x = _ship.position.x;
    _pulses.position.y = 2;
    final rings = _pulses.children.cast<_rt_Mesh3D>();
    for (final r in rings) {
      r.position.set(0, startY, 0);
      r.scale.set(1, 1, 1);
      r.material.opacity = 1;
      r.material.color = color;
    }
    await _tweens.run(1500, (t) {
      final ms = t * 1500;
      for (var i = 0; i < rings.length; i++) {
        final r = rings[i];
        final local = ((ms - i * 150) / 1000).clamp(0.0, 1.0);
        final e = _rt_Ease.inOutQuad(local);
        r.position.y = startY + (endY - startY) * e;
        final s = 1 + 14 * e;
        r.scale.set(s, s, 1);
        final fade = ((ms - (i * 150 + 800)) / 200).clamp(0.0, 1.0);
        r.material.opacity = 1 - fade;
      }
    }, ease: _rt_Ease.linear);
  }

  void _updateIndustrialRays(double xPos) {
    final hitCrack = (xPos - 7).abs() < 2;
    for (var i = 0; i < _rays.length; i++) {
      final r = _rays[i];
      r.position.set(xPos + (i - 1) * 0.5, -5, 0.1);
      if (hitCrack && _step != 9) {
        r.scale.y = 0.5;
        r.position.y = -1;
        r.material.color = const Color(0xFFEF4444);
      } else {
        r.scale.y = 1;
        r.position.y = -5;
        r.material.color = const Color(0xFF3B82F6);
      }
    }
    if (hitCrack && _step != 9) {
      _sensorBox.material.color = const Color(0xFFEF4444);
      if (_step >= 6) _updateHud('0.005 ms', '5 cm', 'fault');
    } else {
      _sensorBox.material.color = const Color(0xFF10B981);
      if (_step >= 6 && _step != 9) _updateHud('0.01 ms', '10 cm', 'clean');
    }
  }

  // ----------------------------------------------------------- actions ---
  void _handleHudClick() {
    if (_step == 3) {
      _rt_playSfx(_rt_Sfx.correct);
      setState(() => _tapGuide = false);
      _advanceStep();
    }
  }

  Future<void> _actionPulse() async {
    final g = _gen;
    _isAnimating = true;
    _rt_playSfx(_rt_Sfx.magic); // ping
    _shipCone.material.emissive = const Color(0xFF550000);
    await _animateSonar(-22, const Color(0xFF22D3EE), false);
    if (!mounted || g != _gen) return;
    _shipCone.material.emissive = null;
    _isAnimating = false;
    _advanceStep();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted || g != _gen) return;
    _actionReflection();
  }

  Future<void> _actionReflection() async {
    final g = _gen;
    _isAnimating = true;
    _rt_playSfx(_rt_Sfx.pop); // echo
    _tweens.run(600, (t) {
      final s = 1 + 0.1 * math.sin(t * math.pi * 2).abs();
      _sub.scale.set(s, s, s);
    }, ease: _rt_Ease.linear);
    await _animateSonar(-22, const Color(0xFF4ADE80), true);
    if (!mounted || g != _gen) return;
    _isAnimating = false;
    _advanceStep();
  }

  Future<void> _actionWhalePing() async {
    final g = _gen;
    _isAnimating = true;
    _rt_playSfx(_rt_Sfx.magic);
    await _animateSonar(-40, const Color(0xFF22D3EE), false);
    if (!mounted || g != _gen) return;
    _rt_playSfx(_rt_Sfx.pop, volume: 0.8); // whale call / echo
    await _animateSonar(-40, const Color(0xFF4ADE80), true);
    if (!mounted || g != _gen) return;
    _isAnimating = false;
    _whalePinged = true;
    _updateHud('2.00 s', '? m', 'received');
  }

  Future<void> _actionDiffract() async {
    final g = _gen;
    _isAnimating = true;
    _rt_playSfx(_rt_Sfx.magic, volume: 0.5);
    for (final r in _rays) {
      r.visible = false;
    }
    _diffRays.visible = true;
    _sensorBox.material.color = const Color(0xFF10B981);
    _updateHud('0.01 ms', '10 cm', 'clean');
    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted || g != _gen) return;
    _isAnimating = false;
    _advanceStep();
  }

  Future<void> _actionBatCatch() async {
    if (_isAnimating) return;
    final g = _gen;
    _isAnimating = true;
    _rt_playSfx(_rt_Sfx.correct);
    _tweens.run(500, (t) => _moth.scale.setAll3(1 - t));
    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted || g != _gen) return;
    _isAnimating = false;
    _advanceStep();
  }

  void _setFrequency(String type) {
    if (_step != 9 || _audioMode || _isAnimating) return;
    if (type == 'audio') {
      _rt_playSfx(_rt_Sfx.click);
      setState(() => _audioMode = true);
      _actionDiffract();
    }
  }

  void _onMarkerDrag(double dy, double h) {
    if (_step != 4 && _step != 5) return;
    _markerRaw = (_markerRaw + dy / h).clamp(0.0, 1.0);
    final depth = ((_markerRaw - 0.3) * 3000).floor();
    if (depth < 0) return;
    setState(() {
      _markerFrac = _markerRaw;
      _depthVal = '$depth';
    });
    if (_step == 4 && (depth - 765).abs() < 100) {
      _markerSnap(0.55, '765.5');
    } else if (_step == 5 && _whalePinged && (depth - 1531).abs() < 120) {
      _markerSnap(0.80, '1531');
    }
  }

  void _markerSnap(double frac, String val) {
    if (!_stepDoneFlags.add(100 + _step)) return;
    setState(() {
      _markerFrac = frac;
      _markerRaw = frac;
      _depthVal = val;
    });
    _rt_playSfx(_rt_Sfx.correct);
    _advanceStep();
  }

  // Quiz
  void _quizDrop(int zone, int answer) {
    if (_step != 11 || _quizDone.contains(zone)) return;
    if (zone == answer) {
      _rt_playSfx(_rt_Sfx.correct);
      setState(() {
        _quizDone.add(zone);
        _quizSelected = null;
      });
      if (_quizDone.length == 3) {
        final g = _gen;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted && g == _gen) _showCompletion();
        });
      }
    } else {
      _rt_playSfx(_rt_Sfx.wrong);
      setState(() {
        _quizWrongZone = zone;
        _quizSelected = null;
      });
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) setState(() => _quizWrongZone = null);
      });
    }
  }

  // ------------------------------------------------------------- flow ---
  void _advanceStep() {
    if (_step < _tx.list('explore').length - 1) {
      _loadStep(_step + 1);
    } else {
      _showCompletion();
    }
  }

  (_rt_V3, _rt_V3) _viewFor(int id) {
    final aspect = _canvasSize.height > 0 ? _canvasSize.width / _canvasSize.height : 1.6;
    final halfTan = math.tan(15 * math.pi / 180);
    if (id <= 5) {
      final z = math.max(150.0, 62 / (halfTan * aspect));
      return (_rt_V3(0, 0, z), _rt_V3(0, -20, 0));
    } else if (id <= 9) {
      final z = math.max(40.0, 19 / (halfTan * aspect));
      return (_rt_V3(0, -5, z), _rt_V3(0, -5, 0));
    }
    final z = math.max(40.0, 30 / (halfTan * aspect));
    return (_rt_V3(0, 0, z), _rt_V3(0, 0, 0));
  }

  Future<void> _centerView({bool animate = true}) async {
    final (pos, tgt) = _viewFor(_step);
    if (!animate) {
      _camera.position.copy(pos);
      _camera.target.copy(tgt);
      _camera.zoom = 1;
      _camera.saveHome();
      return;
    }
    final p0 = _camera.position.clone(), t0 = _camera.target.clone(), z0 = _camera.zoom;
    await _tweens.run(1500, (t) {
      _camera.position.copy(p0.lerp(pos, t));
      _camera.target.copy(t0.lerp(tgt, t));
      _camera.zoom = z0 + (1 - z0) * t;
    }, ease: _rt_Ease.outQuad);
    _camera.saveHome();
  }

  void _loadStep(int id, {bool animateCamera = true}) {
    _step = id;
    _stepDoneFlags.clear();
    _isDragging = false;
    _s1Group.visible = id <= 5;
    _s2Group.visible = id >= 6 && id <= 9;
    _s3Group.visible = id == 10;
    _tapGuide = false;
    _centerView(animate: animateCamera);

    switch (id) {
      case 0:
        _hudModeKey = 'sonar';
        _updateHud('-- s', '-- m', 'waiting');
        _sub.visible = true;
        _whale.visible = false;
        _ship.position.set(-40, 2, 0);
        _sub.position.set(25, -20, 0);
        _sub.scale.setAll3(1);
      case 1:
        _updateHud('0.00 s', '0 m', 'ready');
      case 3:
        _updateHud('1.00 s', '? m', 'received');
        _tapGuide = true;
      case 4:
        _updateHud('1.00 s', '765.5 m', 'locked');
        _markerFrac = 0.3;
        _markerRaw = 0.3;
        _depthVal = '0';
      case 5:
        _sub.visible = false;
        _whale.visible = true;
        _whalePinged = false;
        _updateHud('0.00 s', '? m', 'ready');
        _markerFrac = 0.3;
        _markerRaw = 0.3;
        _depthVal = '0';
      case 6:
        _hudModeKey = 'flaw';
        _audioMode = false;
        for (final r in _rays) {
          r.visible = true;
        }
        _diffRays.visible = false;
        _probe.position.x = -15;
        _sensorBox.position.x = -15;
        _updateIndustrialRays(-15);
        _updateHud('--', '--', 'ready');
      case 7:
        _probe.position.x = -10;
        _sensorBox.position.x = -10;
        _updateIndustrialRays(-10);
      case 8:
        _probe.position.x = -2;
        _sensorBox.position.x = -2;
        _updateIndustrialRays(-2);
      case 9:
        _probe.position.x = 7;
        _sensorBox.position.x = 7;
        _updateIndustrialRays(7);
      case 10:
        _hudModeKey = 'bio';
        _updateHud('--', '--', 'echolocation');
        _bat.position.set(-25, 0, 0);
        _moth.scale.setAll3(1);
        _moth.position.set(20, 0, 0);
      case 11:
        _quizDone.clear();
        _quizOrder = [0, 1, 2]..shuffle(_rng);
        _quizSelected = null;
        _quizDrag = Offset.zero;
    }
    if (mounted) setState(() {});
  }

  void _updateHud(String t, String d, String sigKey) {
    _hudTime = t;
    _hudDist = d;
    _hudSigKey = sigKey;
    if (mounted) setState(() {});
  }

  Future<void> _showCompletion() async {
    if (_completed) return;
    setState(() => _completed = true);
    _rt_playSfx(_rt_Sfx.success);
    const bold = TextStyle(fontWeight: FontWeight.w800, color: _rt_Tw.slate800);
    await _rt_showShellPopup(
      context,
      title: _tx.s('modal.title'),
      icon: Icons.emoji_events,
      color: _rt_Tw.teal500,
      barrierDismissible: false,
      body: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: _rt_Tw.slate100, borderRadius: BorderRadius.circular(12)),
        child: Text.rich(
          TextSpan(
            style: const TextStyle(fontSize: 14, color: _rt_Tw.slate600, height: 1.45),
            children: [
              TextSpan(text: _tx.s('modal.outcomeB'), style: bold),
              TextSpan(text: _tx.s('modal.outcome1')),
              TextSpan(text: _tx.s('modal.formula'), style: bold),
              TextSpan(text: '${_tx.s('modal.outcome2')}\n\n'),
              TextSpan(text: _tx.s('modal.findingB'), style: bold),
              TextSpan(text: _tx.s('modal.finding')),
            ],
          ),
        ),
      ),
      actions: [
        Builder(
          builder: (ctx) => _rt_ActionButton(
            label: _tx.s('modal.btn'),
            icon: Icons.refresh,
            color: _rt_Tw.teal600,
            onPressed: () {
              Navigator.of(ctx).pop();
              _restart();
            },
          ),
        ),
      ],
    );
  }

  void _restart() {
    _gen++;
    _tweens.cancelAll();
    _completed = false;
    _isAnimating = false;
    _whalePinged = false;
    _audioMode = false;
    _msgDrag = Offset.zero;
    _shipCone.material.emissive = null;
    for (final r in _pulses.children.cast<_rt_Mesh3D>()) {
      r.material.opacity = 0;
    }
    _loadStep(0, animateCamera: false);
  }

  void _openSettings() {
    _rt_playSfx(_rt_Sfx.click);
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) {
          final size = MediaQuery.sizeOf(ctx);
          Widget themeBtn(bool light, IconData icon, String label) {
            final active = _lightMode == light;
            return Expanded(
              child: InkWell(
                onTap: () {
                  _rt_playSfx(_rt_Sfx.click);
                  setState(() => _lightMode = light);
                  setD(() {});
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(
                    color: active ? _rt_Tw.slate700 : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: active ? _teal400 : Colors.transparent),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 14, color: active ? Colors.white : _rt_Tw.slate400),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          label,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: active ? Colors.white : _rt_Tw.slate400),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Dialog(
            backgroundColor: _rt_Tw.slate900,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: _teal400.withValues(alpha: 0.3)),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 360, maxHeight: size.height * 0.9),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.tune, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _tx.s('settings.title'),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _rt_playSfx(_rt_Sfx.click);
                            Navigator.of(ctx).pop();
                          },
                          icon: const Icon(Icons.close, color: _rt_Tw.slate400),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _tx.s('settings.theme'),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _rt_Tw.slate300),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _rt_Tw.slate800,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _rt_Tw.slate700),
                      ),
                      child: Row(
                        children: [
                          themeBtn(false, Icons.dark_mode, _tx.s('settings.dark')),
                          const SizedBox(width: 4),
                          themeBtn(true, Icons.light_mode, _tx.s('settings.light')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text.rich(
                      TextSpan(
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _rt_Tw.slate300),
                        children: [
                          TextSpan(text: '${_tx.s('settings.font')} '),
                          TextSpan(
                            text: '${_fontSize.round()}px',
                            style: const TextStyle(color: _teal400),
                          ),
                        ],
                      ),
                    ),
                    Slider(
                      value: _fontSize,
                      min: 12,
                      max: 32,
                      divisions: 20,
                      activeColor: _rt_Tw.teal500,
                      onChanged: (v) {
                        setState(() => _fontSize = v);
                        setD(() {});
                      },
                    ),
                    const SizedBox(height: 12),
                    _rt_ActionButton(
                      label: _tx.s('settings.done'),
                      icon: Icons.check,
                      color: _rt_Tw.slate700,
                      expand: true,
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
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
          _updateLabels();
          _scene.background = _lightMode ? const Color(0xFFE2E8F0) : const Color(0xFF020617);
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('header.title'),
            subtitle: _tx.s('header.subtitle'),
            theme: const _rt_ShellTheme(
              accent: _rt_Tw.teal600,
              headerGradient: [_rt_Tw.slate900, _rt_Tw.teal900],
              headerSubtitleColor: _rt_Tw.teal400,
            ),
            canvasBackground: _lightMode ? _rt_Tw.slate100 : const Color(0xFF020617),
            intro: _rt_IntroConfig(
              title: _tx.s('intro.title'),
              subtitle: _tx.s('intro.desc'),
              buttonLabel: _tx.s('intro.btn'),
              icon: Icons.waves,
            ),
            onRestart: _restart,
            onZoomIn: _camera.zoomIn,
            onZoomOut: _camera.zoomOut,
            onResetView: () => _centerView(),
            toolbarExtras: [
              _toolBtn(_labelsVisible ? Icons.visibility : Icons.visibility_off, _tx.s('ui.labels'), false, () {
                setState(() => _labelsVisible = !_labelsVisible);
              }),
              const SizedBox(height: 4),
              _toolBtn(Icons.open_with, _tx.s('ui.pan'), _panMode, () {
                setState(() => _panMode = !_panMode);
                _viewCtrl.setMode(_panMode ? _rt_DragMode.pan : _rt_DragMode.rotate);
              }),
              const SizedBox(height: 4),
              _toolBtn(_locked ? Icons.lock : Icons.lock_open, _tx.s(_locked ? 'ui.lock' : 'ui.unlock'), _locked, () {
                setState(() => _locked = !_locked);
              }),
            ],
            tabs: [_rt_ShellTab(label: _tx.s('drawer.title'), icon: Icons.science, builder: (_) => _drawer())],
            canvas: LayoutBuilder(
              builder: (context, box) {
                if (box.biggest != _canvasSize && box.biggest.width > 0) {
                  final first = _canvasSize == const Size(640, 412);
                  _canvasSize = box.biggest;
                  if (first) _centerView(animate: false);
                }
                return _rt_Scene3DView(
                  scene: _scene,
                  camera: _camera,
                  controller: _viewCtrl,
                  cameraControls: !_locked || _panMode,
                  onFrame: _onFrame,
                  onPointerDown: _onPointerDown,
                  onPointerMove: _onPointerMove,
                  onPointerUp: (_) => _onUp(),
                );
              },
            ),
            canvasOverlays: [Positioned.fill(child: LayoutBuilder(builder: (context, box) => _overlays(box.biggest)))],
          );
        },
      ),
    );
  }

  Widget _toolBtn(IconData icon, String tip, bool active, VoidCallback onTap) {
    return Tooltip(
      message: tip,
      child: InkResponse(
        radius: 22,
        onTap: () {
          _rt_playSfx(_rt_Sfx.click);
          onTap();
        },
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(color: active ? _teal700 : Colors.white, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: active ? Colors.white : _rt_Tw.gray500),
        ),
      ),
    );
  }

  Color get _glass => _lightMode ? Colors.white.withValues(alpha: 0.92) : const Color(0xD90F172A);
  Color get _glassText => _lightMode ? _rt_Tw.slate900 : Colors.white;

  Widget _overlays(Size size) {
    final hudVisible = _step > 0 && _step <= 9;
    final hudW = math.min(220.0, size.width * 0.42);
    final stepData = _tx.map('explore.$_step');
    final textScale = TextScaler.linear(_fontSize / 16);
    return Stack(
      children: [
        // Depth marker
        if (_step == 4 || _step == 5)
          Positioned(
            left: 0,
            right: 0,
            top: _markerFrac * size.height - 14,
            height: 28,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onVerticalDragUpdate: (d) => _onMarkerDrag(d.delta.dy, size.height),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: _rt_Tw.red500.withValues(alpha: 0.85),
                      boxShadow: [BoxShadow(color: _rt_Tw.red500.withValues(alpha: 0.6), blurRadius: 12)],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F1D1D),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: _rt_Tw.red400),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.swap_vert, size: 14, color: Colors.white),
                        const SizedBox(width: 4),
                        Text(
                          '${_tx.s('ui.depth')} $_depthVal m',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        // Oscilloscope HUD
        if (hudVisible) Positioned(top: 12, right: 66, width: hudW, child: _hudPanel()),
        // Message HUD (draggable)
        Positioned(
          left: 80,
          right: 16,
          bottom: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_step == 9) ...[_freqToggle(), const SizedBox(height: 10)],
              Transform.translate(
                offset: _msgDrag,
                child: Center(
                  child: GestureDetector(
                    onPanUpdate: (d) => setState(() {
                      _msgDrag = Offset(
                        (_msgDrag.dx + d.delta.dx).clamp(-60.0, size.width * 0.3),
                        (_msgDrag.dy + d.delta.dy).clamp(-(size.height - 100), 0.0),
                      );
                    }),
                    child: MediaQuery(
                      data: MediaQuery.of(context).copyWith(textScaler: textScale),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 560),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _glass,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: _rt_Tw.teal500.withValues(alpha: 0.5), width: 2),
                          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 30)],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: _rt_Tw.teal500.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                                border: Border.all(color: _rt_Tw.teal500.withValues(alpha: 0.5)),
                              ),
                              child: Icon(
                                _stepIcons[stepData['icon']] ?? Icons.notifications,
                                size: 15,
                                color: _teal400,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _tx.s('hud.actionTask').toUpperCase(),
                                    maxLines: 1,
                                    style: const TextStyle(
                                      color: _teal400,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                      letterSpacing: 1.5,
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                  Text(
                                    stepData['task'] as String,
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: _glassText, fontSize: 12, height: 1.25),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(Icons.drag_indicator, size: 18, color: _rt_Tw.teal500.withValues(alpha: 0.5)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_step == 11) _quizPopup(size),
      ],
    );
  }

  Widget _freqToggle() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 340),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: _rt_Tw.slate900,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _rt_Tw.teal500),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 20)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _freqBtn(_tx.s('ui.ultra'), !_audioMode, () => _setFrequency('ultra')),
            _freqBtn(_tx.s('ui.audio'), _audioMode, () => _setFrequency('audio')),
          ],
        ),
      ),
    );
  }

  Widget _freqBtn(String label, bool active, VoidCallback onTap) {
    return Flexible(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          decoration: BoxDecoration(
            color: active ? _rt_Tw.teal600 : Colors.transparent,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: active ? Colors.white : _rt_Tw.slate400,
              fontWeight: FontWeight.bold,
              fontSize: 10,
              letterSpacing: 1,
            ),
          ),
        ),
      ),
    );
  }

  Widget _hudPanel() {
    final sigColor = _hudSigKey == 'fault'
        ? _rt_Tw.red500
        : (_hudSigKey == 'clean' || _hudSigKey == 'locked')
        ? _rt_Tw.green500
        : _rt_Tw.slate500;
    final chipBg = _lightMode ? _rt_Tw.slate100 : Colors.black.withValues(alpha: 0.5);
    Widget row(String label, String value, Color c, {bool chip = true}) => Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: _lightMode ? _rt_Tw.slate500 : _rt_Tw.slate400, fontSize: 10, fontFamily: 'monospace'),
            ),
          ),
          const SizedBox(width: 4),
          Flexible(
            flex: 2,
            child: Container(
              padding: chip ? const EdgeInsets.symmetric(horizontal: 6, vertical: 1) : EdgeInsets.zero,
              decoration: chip ? BoxDecoration(color: chipBg, borderRadius: BorderRadius.circular(4)) : null,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.bold, fontFamily: 'monospace'),
              ),
            ),
          ),
        ],
      ),
    );
    final panel = Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(16),
        border: const Border(top: BorderSide(color: _rt_Tw.teal500, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 30)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tx.s('hud.title'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _teal400,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
              const Icon(Icons.graphic_eq, size: 16, color: _teal400),
            ],
          ),
          Container(height: 1, margin: const EdgeInsets.only(top: 4), color: _rt_Tw.slate700),
          row(_tx.s('hud.mode'), _tx.s('modes.$_hudModeKey'), _glassText),
          row(_tx.s('hud.time'), _hudTime, _rt_Tw.teal400),
          row(_tx.s('hud.dist'), _hudDist, _glassText),
          row(_tx.s('hud.sig'), _tx.s('hud.$_hudSigKey'), sigColor, chip: false),
        ],
      ),
    );
    return GestureDetector(
      onTap: _tapGuide ? _handleHudClick : null,
      child: Stack(
        children: [
          panel,
          if (_tapGuide)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: _rt_Tw.teal500.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _rt_Tw.teal200, width: 2),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.touch_app, size: 28, color: Colors.white),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        _tx.s('hud.tapLog'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _quizPopup(Size size) {
    final w = math.min(360.0, size.width - 90);
    final baseLeft = (size.width - w) / 2;
    const baseTop = 10.0;
    final left = (baseLeft + _quizDrag.dx).clamp(0.0, math.max(0.0, size.width - w)).toDouble();
    final top = (baseTop + _quizDrag.dy).clamp(0.0, math.max(0.0, size.height - 80)).toDouble();
    final maxH = math.max(80.0, size.height - top - 8);
    final panelBg = _lightMode ? Colors.white : _rt_Tw.slate900.withValues(alpha: 0.97);

    Widget chip(int i, {bool lifted = false}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: _quizSelected == i ? const Color(0xFF115E59) : _teal700,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _quizSelected == i ? Colors.white : _teal400, width: _quizSelected == i ? 2 : 1),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: lifted ? 0.6 : 0.4), blurRadius: 10)],
      ),
      child: Text(
        _tx.s('quiz.a${i + 1}'),
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );

    Widget zone(int z) {
      final done = _quizDone.contains(z);
      final wrong = _quizWrongZone == z;
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _tx.s('quiz.l${z + 1}'),
              style: const TextStyle(color: _teal400, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            DragTarget<int>(
              onWillAcceptWithDetails: (_) => !done,
              onAcceptWithDetails: (d) => _quizDrop(z, d.data),
              builder: (context, cand, rej) {
                final over = cand.isNotEmpty;
                return GestureDetector(
                  onTap: () {
                    if (_quizSelected != null && !done) _quizDrop(z, _quizSelected!);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: done
                          ? const Color(0xE60F172A)
                          : wrong
                          ? const Color(0x33EF4444)
                          : over
                          ? const Color(0xE60F172A)
                          : (_lightMode ? _rt_Tw.slate50 : Colors.white.withValues(alpha: 0.05)),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: done || over ? _teal400 : (wrong ? _rt_Tw.red500 : _rt_Tw.slate500), width: 2),
                    ),
                    child: done
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  _tx.s('quiz.a${z + 1}'),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: _teal400, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.check, size: 14, color: _teal400),
                            ],
                          )
                        : null,
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return Positioned(
      left: left,
      top: top,
      width: w,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: panelBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _rt_Tw.teal500, width: 2),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.7), blurRadius: 40)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onPanUpdate: (d) => setState(() => _quizDrag += d.delta),
                child: Container(
                  color: const Color(0xE6134E4A),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  child: Row(
                    children: [
                      const Icon(Icons.extension, size: 14, color: _teal400),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _tx.s('quiz.title').toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const Icon(Icons.drag_handle, size: 16, color: _rt_Tw.teal500),
                    ],
                  ),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _tx.s('quiz.desc').toUpperCase(),
                        style: TextStyle(
                          color: _lightMode ? _rt_Tw.slate600 : _rt_Tw.slate300,
                          fontSize: 10,
                          fontFamily: 'monospace',
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      for (var z = 0; z < 3; z++) zone(z),
                      Container(
                        constraints: const BoxConstraints(minHeight: 50),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _lightMode ? _rt_Tw.slate100 : _rt_Tw.slate800.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white10),
                        ),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          alignment: WrapAlignment.center,
                          children: [
                            for (final i in _quizOrder)
                              if (!_quizDone.contains(i))
                                Draggable<int>(
                                  data: i,
                                  feedback: Material(color: Colors.transparent, child: chip(i, lifted: true)),
                                  childWhenDragging: Opacity(opacity: 0.3, child: chip(i)),
                                  child: GestureDetector(
                                    onTap: () {
                                      _rt_playSfx(_rt_Sfx.tap);
                                      setState(() => _quizSelected = _quizSelected == i ? null : i);
                                    },
                                    child: chip(i),
                                  ),
                                ),
                          ],
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
    );
  }

  // ------------------------------------------------------------ sidebar ---
  Widget _drawer() {
    final steps = _tx.list('explore');
    return Builder(
      builder: (context) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(_fontSize / 16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                decoration: const BoxDecoration(
                  color: _rt_Tw.slate100,
                  border: Border(bottom: BorderSide(color: _rt_Tw.slate200)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tx.s('drawer.title'),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _rt_Tw.slate900),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _tx.s('drawer.subtitle').toUpperCase(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: _rt_Tw.teal600,
                              fontFamily: 'monospace',
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: _tx.s('ui.settings'),
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings, color: _rt_Tw.slate600, size: 20),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [for (var i = 0; i < steps.length; i++) _stepCard(i, steps[i] as Map)],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _stepCard(int i, Map s) {
    final active = i == _step && !_completed;
    final done = i < _step || _completed;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.only(bottom: 10, left: active ? 6 : 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: active ? LinearGradient(colors: [_rt_Tw.teal100.withValues(alpha: 0.9), Colors.white]) : null,
        color: active ? null : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: active ? _teal400 : Colors.transparent, width: 4)),
        boxShadow: active ? [BoxShadow(color: _rt_Tw.teal500.withValues(alpha: 0.35), blurRadius: 10)] : null,
      ),
      child: Opacity(
        opacity: active || done ? 1 : 0.45,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${_tx.s('ui.step')} ${i + 1}'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: active ? _rt_Tw.teal600 : _rt_Tw.slate500,
                    ),
                  ),
                ),
                if (done) const Icon(Icons.check_circle, size: 14, color: _rt_Tw.teal500),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              s['act'] as String,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _rt_Tw.slate900),
            ),
            const SizedBox(height: 4),
            Text(s['concept'] as String, style: const TextStyle(fontSize: 12, color: _rt_Tw.slate600, height: 1.35)),
          ],
        ),
      ),
    );
  }
}

extension on _rt_V3 {
  void setAll3(double v) => set(v, v, v);
}
