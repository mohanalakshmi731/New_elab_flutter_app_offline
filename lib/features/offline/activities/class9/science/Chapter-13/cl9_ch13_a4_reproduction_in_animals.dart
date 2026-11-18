// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Reproduction in Animals
// Converted from Cl9S-Ch13-A4-ReproductionInAnimals.html (gsap -> Flutter).

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
    'title': 'Reproduction in Animals',
    'subtitle': 'Class 9 • How Life Continues',
    'enterLab': 'ENTER VIRTUAL LAB',
    'labProgress': 'Lab Progress',
    'moduleSel': 'Select Scenario:',
    'missionObj': 'Mission Objective',
    'detailedSteps': 'Detailed Explanation of Steps',
    'what_we_learn': 'What we learn',
    'taskInstr': 'Task Instructions:',
    'expOut': 'Expected Outcome:',
    'conceptLearned': 'Concept Learned:',
    'hint': 'Hint',
    'resetStep': 'Reset',
    'verifyStep': 'VERIFY PLACEMENTS',
    'btnReplay': 'Replay Lab',
    'settings': 'Settings',
    'visTheme': 'Visual Theme',
    'dark': 'Dark',
    'light': 'Light',
    'txtScale': 'Text Scaling',
    'gotIt': 'Got it',
    'step': 'STEP',
    'stage': 'Stage',
    'true': 'True',
    'false': 'False',
    'selectBtn': '[ Select ]',
    'selectedBtn': '✓ Selected',
    'scenario1_opt': '1. External vs Internal (Classification)',
    'scenario2_opt': '2. Rebuild Table 11.4 (Data Matrix)',
    'scenario3_opt': '3. Yolk Strategy & Butterfly Life Cycle',
    'scenario4_opt': '4. Where Does the Zygote Grow? (Mammal)',
    'hud_s1': 'Sort 5 animal tokens into External (Pond) vs Internal (Land/Nest) zones.',
    's1ExtTitle': 'External Fertilisation',
    's1ExtSub': 'Eggs & sperm released into water (aquatic pond zone).',
    's1IntTitle': 'Internal Fertilisation',
    's1IntSub': 'Fertilisation occurs inside female body (land/nest zone).',
    'mammalLabel': 'Mammal (Capybara)',
    'animals': {
      'fish': 'Fish',
      'frog': 'Frog',
      'lizard': 'Lizard',
      'bird': 'Bird',
      'mammal': 'Mammal (Capybara)',
      'butterfly': 'Butterfly',
    },
    'hud_s2': 'Rebuild Table 11.4 by dragging or selecting data chips for all 4 animals.',
    's2TableTitle': 'Step 2/4: Rebuild Table 11.4 - Variations in Reproduction',
    'thAnimal': 'Animal',
    'thHabitat': 'Habitat',
    'thMode': 'Mode of fertilisation',
    'thEggs': 'Number of eggs produced',
    'thSurvival': 'Estimated survival of young ones',
    'hud_s3': 'Assign animals to Yolk Paths and order the 5 Butterfly Life Cycle stages.',
    's3YolkTitle': 'Yolk Strategy',
    'larvaPath': 'Larva Path ➔',
    'directPath': 'Direct-Hatch Path ➔',
    's3CardADesc': 'An egg cutaway shows yolk shrink as embryo grows',
    's3CardBDesc': 'Larva pulses/grows and morphs into adult',
    's3BflyTitle': 'Butterfly Life Cycle',
    'bfly_stages': {
      'b1': 'Egg (on leaf)',
      'b2': 'Larva (caterpillar)',
      'b3': 'Pupa (chrysalis)',
      'b4': 'Emergence',
      'b5': 'Adult (butterfly)',
    },
    'hud_s4': 'Place where the mammal zygote develops and verify post-birth milk nourishment.',
    's4FactChipTitle': 'fact chip',
    's4MilkFact': 'Mammals feed their young ones via breast milk.',
    's4InsideMotherBody': 'inside mother body',
    's4ExternalEgg': 'external egg',
    's1_obj':
        'Sort five representative animal models (Fish, Frog, Lizard, Bird, Mammal) by fertilisation site — external in open water vs internal inside the female body.',
    's2_obj':
        'Rebuild Table 11.4 data relating habitat, fertilisation mode, egg production numbers, and estimated survival rates across animal groups.',
    's3_obj':
        'Differentiate between low-yolk larva-feeding strategy vs rich-yolk direct-hatch strategy, and sequence the 5 stages of the butterfly life cycle (Fig 11.17).',
    's4_obj':
        'Understand mammalian internal gestation where the zygote develops inside the mother, accompanied by postpartum breast milk nourishment.',
    's1_steps': [
      {
        't': 'Step 1: Identify External Fertilisation in Water',
        'i': 'Drag Fish and Frog into the Pond Zone where eggs and sperm meet in open water.',
        'o': 'Fish and frog positioned in aquatic external zone. Fertilisation occurs outside the parental bodies.',
        'c': 'External fertilisation relies on water medium to allow flagellated sperm to reach eggs.',
      },
      {
        't': 'Step 2: Identify Internal Fertilisation on Land',
        'i': 'Drag Lizard, Bird, and Mammal into the Land & Nest Zone where sperm is deposited inside the female body.',
        'o': 'Terrestrial animals anchored in protected internal zone.',
        'c': 'Internal fertilisation protects gametes and zygotes from environmental hazards and desiccation on land.',
      },
    ],
    's2_steps': [
      {
        't': 'Step 1: Populate Aquatic Species Data (Fish & Frog)',
        'i':
            'Match habitat (Aquatic / Aquatic-land), mode (External), egg count (100s-1000s / 5,000-50,000), and survival (Low).',
        'o': 'Fish and frog rows populated. High egg numbers compensate for severe predation and water currents.',
        'c': 'Species with low individual survival probabilities produce vast numbers of offspring.',
      },
      {
        't': 'Step 2: Populate Terrestrial Species Data (Lizard & Bird)',
        'i':
            'Match habitat (Land / Land-water), mode (Internal), egg count (2-20 / 1-15), and survival (Moderate / Moderate-to-High).',
        'o':
            'Lizard and bird rows completed. Fewer eggs are produced because internal fertilisation and shells enhance survival.',
        'c': 'Parental investment and protective shells reduce the need for massive egg counts.',
      },
    ],
    's3_steps': [
      {
        't': 'Step 1: Group by Yolk Nutritional Strategy',
        'i': 'Place Frog and Butterfly on the Larva Path; place Lizard and Bird on the Direct-Hatch Path.',
        'o':
            'Nutritional paths mapped. Low-yolk eggs rely on an active feeding larva stage before adult transformation.',
        'c': 'Yolk volume dictates whether an animal requires an intermediate larval feeding stage.',
      },
      {
        't': 'Step 2: Sequence Butterfly Life Cycle (Clockwise)',
        'i':
            'Order the 5 stages: Egg (on leaf) → Larva (caterpillar) → Pupa (chrysalis) → Emergence → Adult (butterfly).',
        'o': 'Life cycle sequence validated.',
        'c':
            'The larva accumulates nutrients, the pupa undergoes structural transformation, and the adult emerges to reproduce.',
      },
    ],
    's4_steps': [
      {
        't': 'Step 1: Confirm Mammalian Zygote Location & Maternal Care',
        'i': "Select 'inside mother body' for the mammal and set the breast milk fact toggle to True.",
        'o': 'Mammalian reproductive strategy locked.',
        'c':
            'Internal development within the uterus coupled with milk feeding yields the highest survival rate in nature.',
      },
    ],
    's1_learn':
        'Fertilisation can occur outside the body in water (external: fish, frogs) or inside the female body (internal: reptiles, birds, mammals).',
    's2_learn':
        'Animals with external fertilisation produce thousands of eggs with low survival, while internal fertilisation yields fewer eggs with higher survival.',
    's3_learn':
        'Low-yolk eggs hatch into feeding larvae that transform into adults (butterfly, frog), whereas high-yolk eggs nourish the embryo until hatching.',
    's4_learn':
        "In mammals, the zygote develops inside the mother's body, and young ones are nourished with breast milk after birth.",
    'hints': {
      'external': {
        'b': 'Pond Clue:',
        't': 'Animals that release eggs and sperm into open water without internal mating (Fish, Frog).',
      },
      'internal': {
        'b': 'Land/Nest Clue:',
        't':
            'Animals where sperm fertilises eggs inside the female body, producing shelled eggs or internal embryos (Lizard, Bird, Mammal).',
      },
    },
    'concTitle': 'Reproduction in Animals — Scientific Conclusion',
    'concHead1': '1. External vs Internal Fertilisation',
    'concBody1':
        'In aquatic animals like fish and frogs, fertilisation occurs outside the body in water (external). In terrestrial animals like reptiles, birds, and mammals, fertilisation occurs inside the female body (internal), offering superior protection.',
    'concHead2': '2. Egg Number vs Parental Investment Strategy',
    'concBody2':
        'Animals with external fertilisation produce thousands of low-yolk eggs to compensate for high predator mortality. Animals with internal fertilisation produce fewer, nutrient-rich eggs with significantly higher survival chances.',
    'concHead3': '3. Maternal Protection in Mammals',
    'concBody3':
        "In mammals, the zygote grows and develops entirely inside the mother's body. After birth, mammals feed and protect their young ones via breast milk, maximizing offspring survival.",
    // Scenario 2 localisation dictionary (s2Dict in the source).
    's2': {
      'habitat_aquatic': 'Aquatic',
      'habitat_aquatic_land': 'Aquatic/land',
      'habitat_land': 'Land',
      'habitat_land_water': 'Land/water',
      'mode_external': 'External fertilisation',
      'mode_internal': 'Internal fertilisation',
      'eggs_100s_1000s': '100s – 1000s at a time',
      'eggs_5k_50k': '5,000 – 50,000 at a time',
      'eggs_2_20': '2 – 20 at a time',
      'eggs_1_15': '1 – 15 at a time',
      'surv_low': 'Low',
      'surv_mod': 'Moderate',
      'surv_mod_high': 'Moderate to High',
      'select_habitat': '[ Select Habitat ]',
      'select_mode': '[ Select Mode ]',
      'select_eggs': '[ Select Eggs ]',
      'select_survival': '[ Select Survival ]',
      'placed_badge': 'Placed',
    },
    // Feedback messages the source script builds inline.
    'toasts': {
      'selS1': 'Selected "{name}". Drag or tap any neutral "?" slot in Pond or Land/Nest zone.',
      'selYolk': 'Selected "{name}". Tap Larva Path or Direct-Hatch Path.',
      'selBfly': 'Selected "{name}". Tap ring slot 1 to 5.',
      'hintS2':
          'Fish & Frog: External mode with 100s-1000s / 5000-50000 eggs (Low survival). Lizard & Bird: Internal mode with fewer eggs.',
      'hintS3': 'Larva path: Frog, Butterfly. Cycle: Egg → Larva → Pupa → Emergence → Adult.',
      'hintS4': 'In mammals, zygote grows inside mother body, and milk fact is True.',
      'okS1': '✅ External vs Internal classification perfect! Advancing to Table 11.4 Rebuild...',
      'errS1': '❌ Incorrect sorting. Pond: Fish & Frog. Land/Nest: Lizard, Bird & Mammal.',
      'okS2': '✅ Table 11.4 Data Matrix complete! Advancing to Yolk Strategy & Life Cycle...',
      'errS2': '❌ Table data incomplete or incorrect. Ensure all rows match NCERT Table 11.4.',
      'okS3': '✅ Yolk Strategy & Butterfly Cycle complete! Advancing to Mammal Capstone...',
      'errS3': '❌ Check paths and ring order: Egg → Larva → Pupa → Emergence → Adult.',
      'errS4': "❌ Choose 'inside mother body' and toggle Fact Chip to True.",
      'resetStep': 'Current step reset.',
      'locked': 'Canvas View Locked (2D Mode).',
      'unlocked': 'View Unlocked. Zoom and Pan Enabled.',
      'panOn': 'Pan Mode Active. Drag canvas to move.',
      'panOff': 'Pan Mode Disabled.',
      'viewReset': 'View Reset to 100%.',
    },
    'tools': {'lock': 'Lock/Unlock Canvas Zoom & Pan', 'pan': 'Pan Mode', 'labels': 'Toggle Visual Labels'},
  },
  'hi': {
    'title': 'जंतुओं में जनन',
    'subtitle': 'कक्षा 9 • जनन: जीवन कैसे निरंतर चलता है',
    'enterLab': 'वर्चुअल लैब में प्रवेश करें',
    'labProgress': 'लैब प्रगति',
    'moduleSel': 'परिदृश्य चुनें:',
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
    'gotIt': 'समझ गया',
    'step': 'चरण',
    'stage': 'अवस्था',
    'true': 'सत्य',
    'false': 'असत्य',
    'selectBtn': '[ चुनें ]',
    'selectedBtn': '✓ चयनित',
    'scenario1_opt': '1. बाह्य बनाम आंतरिक (वर्गीकरण)',
    'scenario2_opt': '2. सारणी 11.4 पुनर्निर्माण (डेटा)',
    'scenario3_opt': '3. पीतक रणनीति व तितली जीवन चक्र',
    'scenario4_opt': '4. युग्मनज स्थिति (स्तनधारी)',
    'hud_s1': '5 जंतुओं को बाह्य (तालाब) या आंतरिक (स्थल/घोंसला) क्षेत्र में छाँटें।',
    's1ExtTitle': 'बाह्य निषेचन',
    's1ExtSub': 'अंडे व शुक्राणु जल में छोड़े जाते हैं (जलीय तालाब क्षेत्र)।',
    's1IntTitle': 'आंतरिक निषेचन',
    's1IntSub': 'मादा के शरीर के भीतर निषेचन (स्थलीय घोंसला क्षेत्र)।',
    'mammalLabel': 'स्तनधारी (कैपीबारा)',
    'animals': {
      'fish': 'मछली',
      'frog': 'मेंढक',
      'lizard': 'छिपकली',
      'bird': 'पक्षी',
      'mammal': 'स्तनधारी (कैपीबारा)',
      'butterfly': 'तितली',
    },
    'hud_s2': 'सभी 4 जंतुओं के लिए डेटा चिप्स चुनकर सारणी 11.4 भरें।',
    's2TableTitle': 'चरण 2/4: सारणी 11.4 का पुनर्निर्माण - जनन में विविधताएं',
    'thAnimal': 'जंतु',
    'thHabitat': 'आवास',
    'thMode': 'निषेचन का प्रकार',
    'thEggs': 'उत्पादित अंडों की संख्या',
    'thSurvival': 'अनुमानित उत्तरजीविता',
    'hud_s3': 'जंतुओं को पीतक पथों में रखें और तितली के 5 चरणों को क्रम में लगाएं।',
    's3YolkTitle': 'पीतक रणनीति',
    'larvaPath': 'लार्वा पथ ➔',
    'directPath': 'प्रत्यक्ष पथ ➔',
    's3CardADesc': 'अंडे का कटअवे दिखाता है कि भ्रूण बढ़ने पर पीतक घटता है',
    's3CardBDesc': 'लार्वा पोषण लेकर बढ़ता है और वयस्क में बदलता है',
    's3BflyTitle': 'तितली का जीवन चक्र',
    'bfly_stages': {
      'b1': 'अंडा (पत्ती पर)',
      'b2': 'लार्वा (कैटरपिलर)',
      'b3': 'प्यूपा (कोकून)',
      'b4': 'प्रस्फुटन',
      'b5': 'वयस्क (तितली)',
    },
    'hud_s4': 'स्तनधारी युग्मनज का स्थान चुनें और स्तनपान तथ्य की पुष्टि करें।',
    's4FactChipTitle': 'तथ्य चिप',
    's4MilkFact': 'स्तनधारी अपने नवजात को स्तन का दूध पिलाते हैं।',
    's4InsideMotherBody': 'माँ के शरीर के भीतर',
    's4ExternalEgg': 'बाहरी अंडा',
    's1_obj': 'पाँच प्रतिनिधि जंतुओं को निषेचन स्थल के आधार पर वर्गीकृत करना।',
    's2_obj': 'आवास, निषेचन प्रकार, अंडों की संख्या और उत्तरजीविता दर से संबंधित सारणी 11.4 का पुनर्निर्माण।',
    's3_obj':
        'अल्प पीतक लार्वा रणनीति व प्रचुर पीतक प्रत्यक्ष प्रस्फुटन में अंतर समझना तथा तितली चक्र को क्रमबद्ध करना।',
    's4_obj': 'स्तनधारियों में आंतरिक गर्भधारण और जन्म उपरांत स्तनपान पोषण को समझना।',
    's1_steps': [
      {
        't': 'कदम 1: जल में बाह्य निषेचन की पहचान',
        'i': 'मछली और मेंढक को तालाब क्षेत्र में रखें।',
        'o': 'मछली और मेंढक बाह्य क्षेत्र में स्थापित।',
        'c': 'बाह्य निषेचन के लिए जल माध्यम आवश्यक है।',
      },
      {
        't': 'कदम 2: स्थल पर आंतरिक निषेचन की पहचान',
        'i': 'छिपकली, पक्षी और स्तनधारी को आंतरिक क्षेत्र में रखें।',
        'o': 'स्थलीय जंतु आंतरिक क्षेत्र में स्थापित।',
        'c': 'आंतरिक निषेचन युग्मकों को सूखने और शिकारियों से बचाता है।',
      },
    ],
    's2_steps': [
      {
        't': 'कदम 1: जलीय प्रजातियों का डेटा भरें (मछली व मेंढक)',
        'i': 'आवास (जल/जल-थल), प्रकार (बाह्य), अंडों की संख्या (सैकड़ों-हजारों/5000-50000) और उत्तरजीविता (कम) भरें।',
        'o': 'मछली व मेंढक की पंक्ति पूर्ण।',
        'c': 'अधिक अंडों का उत्पादन शिकारियों से होने वाले नुकसान की भरपाई करता है।',
      },
      {
        't': 'कदम 2: स्थलीय प्रजातियों का डेटा भरें (छिपकली व पक्षी)',
        'i': 'आवास (थल/जल-थल), प्रकार (आंतरिक), अंडों की संख्या (2-20/1-15) और उत्तरजीविता (मध्यम/मध्यम से उच्च) भरें।',
        'o': 'छिपकली और पक्षी की पंक्ति पूर्ण।',
        'c': 'कवचयुक्त अंडों और आंतरिक सुरक्षा के कारण कम अंडों की आवश्यकता होती है।',
      },
    ],
    's3_steps': [
      {
        't': 'कदम 1: पीतक रणनीति अनुसार वर्गीकरण',
        'i': 'मेंढक व तितली को लार्वा पथ में तथा छिपकली व पक्षी को प्रत्यक्ष पथ में रखें।',
        'o': 'पथ निर्धारित।',
        'c': 'पीतक की मात्रा तय करती है कि लार्वा अवस्था होगी या नहीं।',
      },
      {
        't': 'कदम 2: तितली जीवन चक्र का अनुक्रम',
        'i': '5 चरणों को क्रमबद्ध करें: अंडा → लार्वा → प्यूपा → प्रस्फुटन → वयस्क।',
        'o': 'जीवन चक्र अनुक्रम सत्यापित।',
        'c': 'लार्वा पोषण एकत्र करता है, प्यूपा में कायांतरण होता है, और वयस्क जनन करता है।',
      },
    ],
    's4_steps': [
      {
        't': 'कदम 1: स्तनधारी युग्मनज स्थिति व पोषण',
        'i': "'माँ के शरीर के भीतर' चुनें और स्तनपान तथ्य को 'सत्य' पर सेट करें।",
        'o': 'रणनीति पूर्ण।',
        'c': 'आंतरिक विकास और दुग्धपान से उत्तरजीविता दर सर्वाधिक होती है।',
      },
    ],
    's1_learn':
        'निषेचन शरीर के बाहर पानी में (बाह्य: मछली, मेंढक) या मादा शरीर के भीतर (आंतरिक: सरीसृप, पक्षी, स्तनधारी) हो सकता है।',
    's2_learn':
        'बाह्य निषेचन वाले जंतु हजारों अंडे देते हैं जिनकी उत्तरजीविता कम होती है, जबकि आंतरिक निषेचन में कम अंडे अधिक सुरक्षित रहते हैं।',
    's3_learn':
        'अल्प पीतक वाले अंडे लार्वा बनते हैं जो पोषण पाकर वयस्क बनते हैं (तितली, मेंढक), जबकि अधिक पीतक वाले अंडों से सीधे बच्चे निकलते हैं।',
    's4_learn': 'स्तनधारियों में युग्मनज का विकास माँ के शरीर में होता है और जन्म के बाद बच्चों को दूध पिलाया जाता है।',
    'hints': {
      'external': {'b': 'तालाब संकेत:', 't': 'वे जंतु जो खुले पानी में अंडे व शुक्राणु छोड़ते हैं (मछली, मेंढक)।'},
      'internal': {
        'b': 'घोंसला संकेत:',
        't': 'वे जंतु जहाँ मादा के शरीर में निषेचन होता है (छिपकली, पक्षी, स्तनधारी)।',
      },
    },
    'concTitle': 'जंतुओं में जनन — वैज्ञानिक निष्कर्ष',
    'concHead1': '1. बाह्य बनाम आंतरिक निषेचन',
    'concBody1':
        'जलीय जंतुओं में निषेचन शरीर के बाहर पानी में होता है, जबकि स्थलीय जंतुओं में मादा के शरीर के भीतर आंतरिक निषेचन होता है जो अधिक सुरक्षा प्रदान करता है।',
    'concHead2': '2. अंडों की संख्या बनाम पैतृक देखभाल',
    'concBody2':
        'बाह्य निषेचन वाले जंतु भारी नुकसान की भरपाई के लिए हजारों अंडे देते हैं, जबकि आंतरिक निषेचन वाले जंतु कम लेकिन सुरक्षित अंडे देते हैं।',
    'concHead3': '3. स्तनधारियों में मातृ संरक्षण',
    'concBody3':
        'स्तनधारियों में युग्मनज का विकास माँ के शरीर में होता है और जन्म के बाद दुग्धपान कराकर नवजात की रक्षा की जाती है।',
    's2': {
      'habitat_aquatic': 'जलीय',
      'habitat_aquatic_land': 'जल/थल',
      'habitat_land': 'स्थलीय',
      'habitat_land_water': 'थल/जल',
      'mode_external': 'बाह्य निषेचन',
      'mode_internal': 'आंतरिक निषेचन',
      'eggs_100s_1000s': 'एक बार में सैकड़ों – हजारों',
      'eggs_5k_50k': 'एक बार में 5,000 – 50,000',
      'eggs_2_20': 'एक बार में 2 – 20',
      'eggs_1_15': 'एक बार में 1 – 15',
      'surv_low': 'कम',
      'surv_mod': 'मध्यम',
      'surv_mod_high': 'मध्यम से उच्च',
      'select_habitat': '[ आवास चुनें ]',
      'select_mode': '[ निषेचन चुनें ]',
      'select_eggs': '[ अंडों की संख्या ]',
      'select_survival': '[ उत्तरजीविता ]',
      'placed_badge': 'स्थापित',
    },
    'toasts': {
      'selS1': '"{name}" चुना गया। इसे तालाब या स्थल/घोंसला क्षेत्र के किसी भी "?" स्थान पर खींचें या टैप करें।',
      'selYolk': '"{name}" चुना गया। लार्वा पथ या प्रत्यक्ष पथ पर टैप करें।',
      'selBfly': '"{name}" चुना गया। वलय के स्थान 1 से 5 पर टैप करें।',
      'hintS2':
          'मछली व मेंढक: बाह्य निषेचन, सैकड़ों-हजारों / 5000-50000 अंडे (कम उत्तरजीविता)। छिपकली व पक्षी: आंतरिक निषेचन, कम अंडे।',
      'hintS3': 'लार्वा पथ: मेंढक, तितली। चक्र: अंडा → लार्वा → प्यूपा → प्रस्फुटन → वयस्क।',
      'hintS4': 'स्तनधारियों में युग्मनज माँ के शरीर के भीतर बढ़ता है, और दूध वाला तथ्य सत्य है।',
      'okS1': '✅ बाह्य बनाम आंतरिक वर्गीकरण सही! सारणी 11.4 पुनर्निर्माण की ओर बढ़ रहे हैं...',
      'errS1': '❌ गलत छँटाई। तालाब: मछली व मेंढक। स्थल/घोंसला: छिपकली, पक्षी व स्तनधारी।',
      'okS2': '✅ सारणी 11.4 डेटा पूर्ण! पीतक रणनीति व जीवन चक्र की ओर बढ़ रहे हैं...',
      'errS2': '❌ सारणी का डेटा अधूरा या गलत है। सुनिश्चित करें कि सभी पंक्तियाँ NCERT सारणी 11.4 से मेल खाती हैं।',
      'okS3': '✅ पीतक रणनीति व तितली चक्र पूर्ण! स्तनधारी चरण की ओर बढ़ रहे हैं...',
      'errS3': '❌ पथ और वलय का क्रम जाँचें: अंडा → लार्वा → प्यूपा → प्रस्फुटन → वयस्क।',
      'errS4': "❌ 'माँ के शरीर के भीतर' चुनें और तथ्य चिप को 'सत्य' पर करें।",
      'resetStep': 'वर्तमान चरण रीसेट किया गया।',
      'locked': 'कैनवास दृश्य लॉक (2D मोड)।',
      'unlocked': 'दृश्य अनलॉक। ज़ूम और पैन सक्षम।',
      'panOn': 'पैन मोड सक्रिय। खिसकाने के लिए कैनवास खींचें।',
      'panOff': 'पैन मोड बंद।',
      'viewReset': 'दृश्य 100% पर रीसेट।',
    },
    'tools': {'lock': 'कैनवास ज़ूम व पैन लॉक/अनलॉक करें', 'pan': 'पैन मोड', 'labels': 'दृश्य लेबल दिखाएँ/छिपाएँ'},
  },
});

// ---------------------------------------------------------------------------
// Tailwind shades used by the source that _rt_Tw does not carry.
const _cCyan200 = Color(0xFFA5F3FC);
const _cCyan300 = Color(0xFF67E8F9);
const _cCyan400 = Color(0xFF22D3EE);
const _cCyan500 = Color(0xFF06B6D4);
const _cCyan600 = Color(0xFF0891B2);
const _cCyan700 = Color(0xFF0E7490);
const _cAmber200 = Color(0xFFFDE68A);
const _cAmber300 = Color(0xFFFCD34D);
const _cAmber400 = Color(0xFFFBBF24);
const _cAmber500 = Color(0xFFF59E0B);
const _cAmber700 = Color(0xFFB45309);
const _cEmerald300 = Color(0xFF6EE7B7);
const _cEmerald400 = Color(0xFF34D399);
const _cEmerald500 = Color(0xFF10B981);
const _cEmerald700 = Color(0xFF047857);
const _cRose200 = Color(0xFFFECDD3);
const _cRose400 = Color(0xFFFB7185);
const _cRose500 = Color(0xFFF43F5E);
const _cRose700 = Color(0xFFBE123C);
const _cSky200 = Color(0xFFBAE6FD);
const _cSky300 = Color(0xFF7DD3FC);
const _cSky400 = Color(0xFF38BDF8);
const _cSky700 = Color(0xFF0369A1);
const _cBlue200 = Color(0xFFBFDBFE);
const _cBlue300 = Color(0xFF93C5FD);
const _cBlue400 = Color(0xFF60A5FA);
const _cBlue700 = Color(0xFF1D4ED8);
const _cLime400 = Color(0xFFA3E635);
const _cOrange400 = Color(0xFFFB923C);

bool get _isDark => _rt_appTheme.isDark;

/// Dark- or light-theme variant (the source's `.light-theme` overrides).
Color _pick(Color dark, Color light) => _isDark ? dark : light;

/// `text-slate-N`, including the source's high-contrast light overrides.
Color _slateText(int shade) => switch (shade) {
  100 => _pick(_rt_Tw.slate100, _rt_Tw.slate900),
  200 => _pick(_rt_Tw.slate200, _rt_Tw.slate800),
  300 => _pick(_rt_Tw.slate300, _rt_Tw.slate700),
  400 => _pick(_rt_Tw.slate400, _rt_Tw.slate600),
  _ => _rt_Tw.slate500,
};

/// `.glass-panel` background.
Color get _glassBg => _isDark ? const Color(0xF00F172A) : Colors.white.withValues(alpha: 0.98);

/// `bg-slate-900/NN` (white in the light theme).
Color _slate900(double alpha) => _isDark ? _rt_Tw.slate900.withValues(alpha: alpha) : Colors.white;

/// `border-slate-700` / `--border`.
Color get _borderC => _isDark ? _rt_Tw.slate700 : _rt_Tw.slate300;

/// 60 % grayscale (the source's `.token-disc.is-placed` filter).
const _kDesaturate = ColorFilter.matrix(<double>[
  0.52756, 0.42912, 0.04332, 0, 0, //
  0.12756, 0.82912, 0.04332, 0, 0, //
  0.12756, 0.42912, 0.44332, 0, 0, //
  0, 0, 0, 1, 0,
]);

/// Payload of every draggable token: [kind] is 's1' (animal disc),
/// 'chip' (table data chip, id = 'column|option'), 'yolk' or 'bfly'.
class _RaToken {
  const _RaToken(this.kind, this.id);
  final String kind;
  final String id;
}

/// Token colours (`animalMeta.color` / `.border`).
class _RaAnimalMeta {
  const _RaAnimalMeta(this.gradient, this.border);
  final List<Color> gradient;
  final Color border;
}

const _kAnimalMeta = {
  'fish': _RaAnimalMeta([Color(0xFF38BDF8), Color(0xFF2563EB)], Color(0xFF38BDF8)),
  'frog': _RaAnimalMeta([Color(0xFF4ADE80), Color(0xFF059669)], Color(0xFF34D399)),
  'lizard': _RaAnimalMeta([Color(0xFFA3E635), Color(0xFF16A34A)], Color(0xFFA3E635)),
  'bird': _RaAnimalMeta([Color(0xFFFBBF24), Color(0xFFF97316)], Color(0xFFFB923C)),
  'mammal': _RaAnimalMeta([Color(0xFFB45309), Color(0xFF713F12)], Color(0xFFD97706)),
};

/// viewBox of each inline animal SVG.
const _kAnimalViewBox = {
  'fish': Size(46, 28),
  'frog': Size(42, 34),
  'lizard': Size(46, 28),
  'bird': Size(46, 30),
  'mammal': Size(46, 30),
};

const _kS1Animals = ['fish', 'frog', 'lizard', 'bird', 'mammal'];
const _kS1Slots = ['ext_1', 'ext_2', 'int_1', 'int_2', 'int_3'];
const _kS2Animals = ['fish', 'frog', 'lizard', 'bird'];
const _kS2Cols = ['habitat', 'mode', 'eggs', 'survival'];

/// NCERT Table 11.4 answer key (`table11_4_Answers`).
const _kTable114 = {
  'fish': {'habitat': 'habitat_aquatic', 'mode': 'mode_external', 'eggs': 'eggs_100s_1000s', 'survival': 'surv_low'},
  'frog': {'habitat': 'habitat_aquatic_land', 'mode': 'mode_external', 'eggs': 'eggs_5k_50k', 'survival': 'surv_low'},
  'lizard': {'habitat': 'habitat_land', 'mode': 'mode_internal', 'eggs': 'eggs_2_20', 'survival': 'surv_mod'},
  'bird': {'habitat': 'habitat_land_water', 'mode': 'mode_internal', 'eggs': 'eggs_1_15', 'survival': 'surv_mod_high'},
};

/// Mini bar chart shown beside a filled egg-count cell (bar heights in px).
const _kTableBars = {
  'fish': [8.0, 12.0, 16.0, 20.0],
  'frog': [6.0, 12.0, 20.0],
  'lizard': [6.0, 10.0, 16.0],
  'bird': [16.0, 8.0, 4.0],
};
const _kTableBarColors = {'fish': _cSky400, 'frog': _cEmerald400, 'lizard': _cLime400, 'bird': _cOrange400};

const _kCategoryOptions = {
  'habitat': ['habitat_aquatic', 'habitat_aquatic_land', 'habitat_land', 'habitat_land_water'],
  'mode': ['mode_external', 'mode_internal'],
  'eggs': ['eggs_100s_1000s', 'eggs_5k_50k', 'eggs_2_20', 'eggs_1_15'],
  'survival': ['surv_low', 'surv_mod', 'surv_mod_high'],
};

const _kColHeaderKeys = {'habitat': 'thHabitat', 'mode': 'thMode', 'eggs': 'thEggs', 'survival': 'thSurvival'};

const _kPathAnimals = ['frog', 'butterfly', 'lizard', 'bird'];
const _kBflyStages = ['b1', 'b2', 'b3', 'b4', 'b5'];

/// Column accent (sky / blue / amber / slate in the source table).
Color _colAccent(String col) => switch (col) {
  'habitat' => _cSky400,
  'mode' => _cBlue400,
  'eggs' => _cAmber400,
  _ => _rt_Tw.slate400,
};

/// Text on a filled table cell.
Color _colCellText(String col) => switch (col) {
  'habitat' => _pick(_cSky200, _cSky700),
  'mode' => _pick(_cBlue200, _cBlue700),
  'eggs' => _pick(_cAmber200, _cAmber700),
  _ => _slateText(200),
};

/// Text on a category chip.
Color _colChipText(String col) => switch (col) {
  'habitat' => _pick(_cSky300, _cSky700),
  'mode' => _pick(_cBlue300, _cBlue700),
  'eggs' => _pick(_cAmber300, _cAmber700),
  _ => _slateText(300),
};

class Cl9Ch13A4ReproductionInAnimalsPage extends StatefulWidget {
  const Cl9Ch13A4ReproductionInAnimalsPage({super.key});

  @override
  State<Cl9Ch13A4ReproductionInAnimalsPage> createState() => _Cl9Ch13A4ReproductionInAnimalsPageState();
}

class _Cl9Ch13A4ReproductionInAnimalsPageState extends State<Cl9Ch13A4ReproductionInAnimalsPage>
    with SingleTickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();

  /// Drives the looping "living moments" (fish swim, frog breathe, ripples,
  /// egg glow, butterfly flutter, zygote pulse). `value * 1000` = seconds.
  late final AnimationController _clock;

  // --- App state (currentStep / selectedToken) ---
  int _step = 1;
  String? _selKind;
  String? _selId;
  bool _learnVisible = false;

  // --- Scenario 1: External or internal? (s1State.slots) ---
  final Map<String, String?> _s1 = {for (final k in _kS1Slots) k: null};

  // --- Scenario 2: Rebuild Table 11.4 (s2State + pendingTableCell) ---
  final Map<String, Map<String, String?>> _s2 = {
    for (final a in _kS2Animals) a: {for (final c in _kS2Cols) c: null},
  };
  String? _pendingAnimal;
  String? _pendingCol;

  // --- Scenario 3: Yolk strategy & butterfly cycle (s3State) ---
  final List<String> _larva = [];
  final List<String> _direct = [];
  final List<String?> _ring = List<String?>.filled(5, null);

  // --- Scenario 4: Where does the zygote grow? (s4State) ---
  String? _target;
  bool _milkFact = false;

  // --- Canvas tools (lock / zoom / pan / labels) ---
  bool _locked = true;
  bool _panMode = false;
  bool _labelsOn = true;
  double _zoom = 1.0;
  Offset _pan = Offset.zero;
  Offset _hudOffset = Offset.zero;
  Size _overlaySize = Size.zero;

  // Timers (setTimeout) — cancelled on restart / dispose.
  final List<Timer> _timers = [];
  int _gen = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _clock = AnimationController(vsync: this, duration: const Duration(seconds: 1000))..repeat();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _clock.dispose();
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

  double get _seconds => _clock.value * 1000;

  // ------------------------------------------------------------ feedback ---
  void _toast(String msg) => _shell.showToast(msg, color: _cCyan500, icon: Icons.info);
  void _toastOk(String msg) => _shell.showToast(msg, color: _rt_Tw.green500, icon: Icons.check_circle);
  void _toastErr(String msg) => _shell.showToast(msg, color: _cRose500, icon: Icons.cancel);

  String _animal(String id) => _tx.s('animals.$id');
  String _stage(String id) => _tx.s('bfly_stages.$id');
  String _named(String key, String name) => _tx.s('toasts.$key').replaceAll('{name}', name);

  bool _isSel(String kind, String id) => _selKind == kind && _selId == id;

  // ------------------------------------------------------------ setStep ---
  void _setStep(int n) {
    setState(() {
      _step = n;
      _selKind = null;
      _selId = null;
      _pendingAnimal = null;
      _pendingCol = null;
    });
  }

  /// Tap on a token: remember it and explain where it can go.
  void _select(String kind, String id) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _selKind = kind;
      _selId = id;
    });
    switch (kind) {
      case 's1':
        _toast(_named('selS1', _animal(id)));
      case 'yolk':
        _toast(_named('selYolk', _animal(id)));
      default:
        _toast(_named('selBfly', _stage(id)));
    }
  }

  // --------------------------------------------------------- Scenario 1 ---
  void _onS1SlotTap(String slot) {
    final sel = _selId;
    if (_selKind == 's1' && sel != null) {
      _placeS1(sel, slot);
    } else {
      _showZoneHint(slot.startsWith('ext') ? 'external' : 'internal');
    }
  }

  void _placeS1(String animal, String slot) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      for (final k in _kS1Slots) {
        if (_s1[k] == animal) _s1[k] = null;
      }
      _s1[slot] = animal;
      _selKind = null;
      _selId = null;
    });
  }

  void _clearS1(String slot) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _s1[slot] = null);
  }

  /// Hint modal for the pond (external) or land/nest (internal) zone.
  void _showZoneHint(String type) {
    _rt_playSfx(_rt_Sfx.click);
    final zone = _tx.s(type == 'external' ? 's1ExtTitle' : 's1IntTitle');
    _rt_showShellPopup(
      context,
      title: '${_tx.s('hint')} — $zone',
      icon: Icons.info,
      color: _cCyan600,
      buttonLabel: _tx.s('gotIt'),
      body: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${_tx.s('hints.$type.b')} ',
              style: TextStyle(fontWeight: FontWeight.w900, color: _rt_Lab.text),
            ),
            TextSpan(text: _tx.s('hints.$type.t')),
          ],
        ),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 13.5, color: _rt_Lab.textMuted, height: 1.45),
      ),
    );
  }

  // --------------------------------------------------------- Scenario 2 ---
  void _onCellTap(String animal, String col) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _pendingAnimal = animal;
      _pendingCol = col;
    });
    _toast('${_animal(animal)} ➔ ${_tx.s(_kColHeaderKeys[col]!)}');
  }

  void _pickChip(String col, String opt) {
    final pending = _pendingAnimal;
    if (pending != null && _pendingCol == col) {
      _rt_playSfx(_rt_Sfx.pop);
      setState(() {
        _s2[pending]![col] = opt;
        _pendingAnimal = null;
        _pendingCol = null;
      });
      return;
    }
    String? empty;
    for (final a in _kS2Animals) {
      if (_s2[a]![col] == null) {
        empty = a;
        break;
      }
    }
    if (empty != null) {
      final target = empty;
      _rt_playSfx(_rt_Sfx.pop);
      setState(() => _s2[target]![col] = opt);
    } else {
      _toast(_tx.s('s2.$opt'));
    }
  }

  void _dropChip(String animal, String col, String opt) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _s2[animal]![col] = opt;
      if (_pendingAnimal == animal && _pendingCol == col) {
        _pendingAnimal = null;
        _pendingCol = null;
      }
    });
  }

  int get _s2Placed {
    var n = 0;
    for (final a in _kS2Animals) {
      for (final c in _kS2Cols) {
        if (_s2[a]![c] != null) n++;
      }
    }
    return n;
  }

  // --------------------------------------------------------- Scenario 3 ---
  void _onPathTap(String path) {
    final sel = _selId;
    if (_selKind == 'yolk' && sel != null) _placeYolk(sel, path);
  }

  void _placeYolk(String pk, String path) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _larva.remove(pk);
      _direct.remove(pk);
      (path == 'larva' ? _larva : _direct).add(pk);
      _selKind = null;
      _selId = null;
    });
  }

  void _removeYolk(String path, String pk) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => (path == 'larva' ? _larva : _direct).remove(pk));
  }

  void _onRingTap(int i) {
    final sel = _selId;
    if (_selKind == 'bfly' && sel != null) {
      _placeBfly(sel, i);
    } else {
      _toast(_stage(_kBflyStages[i]));
    }
  }

  void _placeBfly(String bk, int i) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _ring[i] = bk;
      _selKind = null;
      _selId = null;
    });
  }

  void _clearRing(int i) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _ring[i] = null);
  }

  // --------------------------------------------------------- Scenario 4 ---
  void _onTarget(String target) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() => _target = target);
  }

  void _toggleMilk() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _milkFact = !_milkFact);
  }

  // ---------------------------------------------- hint / verify / reset ---
  void _showStepHint() {
    if (_step == 1) {
      _showZoneHint('external');
      return;
    }
    _rt_playSfx(_rt_Sfx.click);
    _toast(_tx.s('toasts.hintS$_step'));
  }

  void _validate() {
    _rt_playSfx(_rt_Sfx.click);
    switch (_step) {
      case 1:
        final ext = [_s1['ext_1'], _s1['ext_2']];
        final inner = [_s1['int_1'], _s1['int_2'], _s1['int_3']];
        final extOk = ext.contains('fish') && ext.contains('frog');
        final intOk = inner.contains('lizard') && inner.contains('bird') && inner.contains('mammal');
        if (extOk && intOk) {
          _passStep('okS1');
        } else {
          _failStep('errS1');
        }
      case 2:
        var ok = true;
        for (final a in _kS2Animals) {
          for (final c in _kS2Cols) {
            if (_s2[a]![c] != _kTable114[a]![c]) ok = false;
          }
        }
        if (ok) {
          _passStep('okS2');
        } else {
          _failStep('errS2');
        }
      case 3:
        final larvaOk = _larva.contains('frog') && _larva.contains('butterfly') && _larva.length == 2;
        final directOk = _direct.contains('lizard') && _direct.contains('bird') && _direct.length == 2;
        var bflyOk = true;
        for (var i = 0; i < _kBflyStages.length; i++) {
          if (_ring[i] != _kBflyStages[i]) bflyOk = false;
        }
        if (larvaOk && directOk && bflyOk) {
          _passStep('okS3');
        } else {
          _failStep('errS3');
        }
      default:
        if (_target == 'inside' && _milkFact) {
          setState(() => _learnVisible = true);
          _showConclusion();
        } else {
          _failStep('errS4');
        }
    }
  }

  /// Correct placement: reveal "What we learn" and advance after 1.4 s.
  void _passStep(String toastKey) {
    final next = _step + 1;
    _rt_playSfx(_rt_Sfx.correct);
    setState(() => _learnVisible = true);
    _toastOk(_tx.s('toasts.$toastKey'));
    _after(1400, () => _setStep(next));
  }

  void _failStep(String toastKey) {
    _rt_playSfx(_rt_Sfx.wrong);
    _toastErr(_tx.s('toasts.$toastKey'));
  }

  /// Scientific conclusion popup (+ success sound in place of confetti).
  Future<void> _showConclusion() async {
    Widget section(IconData icon, Color accent, Color fg, String head, String body) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: fg),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  head,
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: fg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(body, style: TextStyle(fontSize: 12, color: _rt_Lab.textMuted, height: 1.45)),
        ],
      ),
    );
    await _shell.showSuccess(
      title: _tx.s('concTitle'),
      icon: Icons.check_circle,
      color: _cCyan600,
      buttonLabel: _tx.s('btnReplay'),
      body: Column(
        children: [
          section(Icons.waves, _cCyan500, _pick(_cCyan400, _cCyan700), _tx.s('concHead1'), _tx.s('concBody1')),
          section(Icons.egg, _cAmber500, _pick(_cAmber400, _cAmber700), _tx.s('concHead2'), _tx.s('concBody2')),
          section(Icons.favorite, _cRose500, _pick(_cRose400, _cRose700), _tx.s('concHead3'), _tx.s('concBody3')),
        ],
      ),
      onConfirm: () {
        if (mounted) _restart(); // "Replay Lab"; a tap outside just closes it
      },
    );
  }

  void _resetStep() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _selKind = null;
      _selId = null;
      _learnVisible = false;
      switch (_step) {
        case 1:
          for (final k in _kS1Slots) {
            _s1[k] = null;
          }
        case 2:
          for (final a in _kS2Animals) {
            for (final c in _kS2Cols) {
              _s2[a]![c] = null;
            }
          }
          _pendingAnimal = null;
          _pendingCol = null;
        case 3:
          _larva.clear();
          _direct.clear();
          _ring.fillRange(0, _ring.length, null);
        default:
          _target = null;
          _milkFact = false;
      }
    });
    _toast(_tx.s('toasts.resetStep'));
  }

  /// resetLab: every scenario, the view and the step go back to the start.
  void _restart() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _gen++;
    setState(() {
      for (final k in _kS1Slots) {
        _s1[k] = null;
      }
      for (final a in _kS2Animals) {
        for (final c in _kS2Cols) {
          _s2[a]![c] = null;
        }
      }
      _pendingAnimal = null;
      _pendingCol = null;
      _larva.clear();
      _direct.clear();
      _ring.fillRange(0, _ring.length, null);
      _target = null;
      _milkFact = false;
      _selKind = null;
      _selId = null;
      _learnVisible = false;
      _zoom = 1.0;
      _pan = Offset.zero;
      _locked = true;
      _panMode = false;
      _hudOffset = Offset.zero;
      _step = 1;
    });
  }

  // --------------------------------------------------------- view tools ---
  void _toggleLock() {
    setState(() {
      _locked = !_locked;
      if (_locked) _panMode = false;
    });
    _toast(_tx.s(_locked ? 'toasts.locked' : 'toasts.unlocked'));
  }

  void _zoomBy(int dir) {
    if (_locked) return;
    setState(() => _zoom = dir > 0 ? math.min(_zoom + 0.15, 1.8) : math.max(_zoom - 0.15, 0.65));
  }

  void _togglePan() {
    if (_locked) return;
    setState(() => _panMode = !_panMode);
    _toast(_tx.s(_panMode ? 'toasts.panOn' : 'toasts.panOff'));
  }

  void _resetView() {
    if (_locked) return;
    setState(() {
      _zoom = 1.0;
      _pan = Offset.zero;
    });
    _toast(_tx.s('toasts.viewReset'));
  }

  void _toggleLabels() => setState(() => _labelsOn = !_labelsOn);

  // ----------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: _rt_LangBuilder(
        builder: (context, lang) {
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            theme: const _rt_ShellTheme(
              accent: _cCyan600,
              headerGradient: [_rt_Tw.slate950, Color(0xFF083344)],
              headerSubtitleColor: _cCyan300,
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('title'),
              subtitle: _tx.s('subtitle'),
              buttonLabel: _tx.s('enterLab'),
              icon: Icons.pets,
              buttonIcon: Icons.rocket_launch,
            ),
            onRestart: _restart,
            // Zoom / reset view exist only while the canvas is unlocked.
            onZoomIn: _locked ? null : () => _zoomBy(1),
            onZoomOut: _locked ? null : () => _zoomBy(-1),
            onResetView: _locked ? null : _resetView,
            toolbarExtras: [
              _toolButton(
                icon: _locked ? Icons.lock : Icons.lock_open,
                tip: _tx.s('tools.lock'),
                active: _locked,
                onTap: _toggleLock,
              ),
              if (!_locked) ...[
                const SizedBox(height: 4),
                _toolButton(icon: Icons.pan_tool, tip: _tx.s('tools.pan'), active: _panMode, onTap: _togglePan),
              ],
              const SizedBox(height: 4),
              _toolButton(
                icon: _labelsOn ? Icons.sell : Icons.sell_outlined,
                tip: _tx.s('tools.labels'),
                active: _labelsOn,
                onTap: _toggleLabels,
              ),
            ],
            sidebarTop: _sidebarTop(),
            tabs: [_rt_ShellTab(label: _tx.s('labProgress'), icon: Icons.co_present, builder: (_) => _guideTab())],
            canvasBackground: _rt_Lab.canvas,
            canvas: _rt_MinWidthGate(minWidth: 200, child: _canvas()),
            canvasOverlays: [Positioned.fill(child: _overlayLayer())],
          );
        },
      ),
    );
  }

  Widget _toolButton({required IconData icon, required String tip, required bool active, required VoidCallback onTap}) {
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
          decoration: BoxDecoration(color: active ? _cCyan600 : _rt_Lab.surface, shape: BoxShape.circle),
          child: Icon(icon, size: 18, color: active ? Colors.white : _rt_Lab.textMuted),
        ),
      ),
    );
  }

  /// Visual labels fade to 25 % when the label tool is off (toggleLabels).
  Widget _lab(Widget child) =>
      AnimatedOpacity(duration: const Duration(milliseconds: 200), opacity: _labelsOn ? 1 : 0.25, child: child);

  BoxDecoration _glass({Color? border, double radius = 16, double width = 1}) => BoxDecoration(
    color: _glassBg,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: border ?? _borderC, width: width),
    boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 14, offset: const Offset(0, 6))],
  );

  /// Drag ghost (`.token-disc.is-dragging`). Bounded so chip rows with
  /// Flexible labels stay valid inside the unconstrained drag overlay.
  Widget _dragFeedback(Widget child) => Material(
    type: MaterialType.transparency,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: Transform.rotate(
        angle: 4 * math.pi / 180,
        child: Transform.scale(scale: 1.2, child: Opacity(opacity: 0.95, child: child)),
      ),
    ),
  );

  Widget _clearButton(VoidCallback onTap, double size) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: _cRose500, shape: BoxShape.circle),
      child: Icon(Icons.close, size: size * 0.62, color: Colors.white),
    ),
  );

  // ------------------------------------------------------------- canvas ---
  /// The transformable stage (`#stage-transform-container`) plus the pan
  /// layer used while Pan Mode is on.
  Widget _canvas() {
    return Stack(
      children: [
        Positioned.fill(
          child: Transform.translate(
            offset: _pan,
            child: Transform.scale(scale: _zoom, child: _stageView()),
          ),
        ),
        if (_panMode && !_locked)
          Positioned.fill(
            child: MouseRegion(
              cursor: SystemMouseCursors.grab,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (d) => setState(() => _pan += d.delta),
              ),
            ),
          ),
      ],
    );
  }

  Widget _stageView() {
    return LayoutBuilder(
      builder: (context, c) {
        // Room for the HUD (top), action bar (bottom) and toolbar (right).
        const pad = EdgeInsets.fromLTRB(10, 62, 56, 64);
        final w = math.min(c.maxWidth - pad.horizontal, 900.0);
        final Widget view = switch (_step) {
          1 => _scenario1(w),
          2 => _scenario2(w),
          3 => _scenario3(w),
          _ => _scenario4(w),
        };
        return SingleChildScrollView(
          key: ValueKey('stage-$_step'),
          padding: pad,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: math.max(0.0, c.maxHeight - pad.vertical)),
            child: Center(
              child: SizedBox(width: w, child: view),
            ),
          ),
        );
      },
    );
  }

  /// HUD (top) and canvas action bar (bottom right).
  Widget _overlayLayer() {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 200) return const SizedBox.shrink();
        _overlaySize = c.biggest;
        // While the sidebar is closed the shell's menu button sits over the
        // canvas' top-left corner, so the HUD starts to its right.
        final sidebarOpen = c.maxWidth < MediaQuery.sizeOf(context).width - 40;
        final left = sidebarOpen ? 10.0 : 76.0;
        final hudMax = math.max(140.0, c.maxWidth - left - 70);
        return Stack(
          children: [
            Positioned(left: left + _hudOffset.dx, top: 10 + _hudOffset.dy, child: _hud(hudMax, left)),
            Positioned(right: 56, bottom: 8, child: _actionBar(c.maxWidth < 470)),
          ],
        );
      },
    );
  }

  /// Draggable top mini-HUD (`#top-hud`).
  Widget _hud(double maxW, double left) {
    return GestureDetector(
      onPanUpdate: (d) => setState(() {
        final s = _overlaySize;
        _hudOffset = Offset(
          (_hudOffset.dx + d.delta.dx).clamp(-left, math.max(-left, s.width - left - 120)),
          (_hudOffset.dy + d.delta.dy).clamp(-10.0, math.max(-10.0, s.height - 60)),
        );
      }),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: _glass(radius: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.drag_indicator, size: 14, color: _rt_Tw.slate400),
              const SizedBox(width: 4),
              const Icon(Icons.navigation, size: 14, color: _cCyan400),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _tx.s('hud_s$_step'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _rt_Lab.text, height: 1.2),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: _cCyan500.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_tx.s('step')} $_step/4',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: _pick(_cCyan400, _cCyan700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Hint / Reset / VERIFY PLACEMENTS (`#canvas-action-bar`).
  Widget _actionBar(bool compact) {
    Widget glassBtn(IconData icon, String label, Color color, VoidCallback onTap) {
      final btn = Material(
        color: _glassBg,
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: _borderC),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: color),
                if (!compact) ...[
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
      return compact ? Tooltip(message: label, child: btn) : btn;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        glassBtn(Icons.lightbulb, _tx.s('hint'), _pick(_cAmber400, _cAmber700), _showStepHint),
        const SizedBox(width: 6),
        glassBtn(Icons.replay, _tx.s('resetStep'), _slateText(300), _resetStep),
        const SizedBox(width: 6),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: _cCyan500.withValues(alpha: 0.4), blurRadius: 20)],
          ),
          child: Material(
            color: _cCyan500,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: _validate,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 18, color: _rt_Tw.slate950),
                    const SizedBox(width: 6),
                    Text(
                      _tx.s('verifyStep').toUpperCase(),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: _rt_Tw.slate950,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ sidebar ---
  /// Lab Progress header + scenario dropdown (`#scenario-dropdown`).
  Widget _sidebarTop() {
    final accent = _pick(_cCyan400, _cCyan700);
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
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _cCyan500.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.co_present, size: 14, color: accent),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _tx.s('labProgress').toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, color: _rt_Lab.text),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _cCyan500.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '${_tx.s('step')} $_step/4',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _tx.s('moduleSel').toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: _rt_Lab.textMuted),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _rt_Lab.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rt_Lab.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _step,
                isExpanded: true,
                dropdownColor: _rt_Lab.surface,
                iconEnabledColor: _rt_Lab.textMuted,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _rt_Lab.text),
                selectedItemBuilder: (_) => [
                  for (var i = 1; i <= 4; i++)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(_tx.s('scenario${i}_opt'), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                ],
                items: [
                  for (var i = 1; i <= 4; i++)
                    DropdownMenuItem<int>(
                      value: i,
                      child: Text(_tx.s('scenario${i}_opt'), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  _rt_playSfx(_rt_Sfx.scenario);
                  _setStep(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sideHeading(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(
      children: [
        Icon(icon, size: 16, color: _cCyan500),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.6, color: _rt_Lab.text),
          ),
        ),
      ],
    ),
  );

  /// Mission objective, detailed step cards and "What we learn".
  Widget _guideTab() {
    final steps = _tx.list('s${_step}_steps');
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _sideHeading(Icons.gps_fixed, _tx.s('missionObj')),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _rt_Lab.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rt_Lab.border),
            ),
            child: Text(
              _tx.s('s${_step}_obj'),
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w500, color: _rt_Lab.textMuted, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          _sideHeading(Icons.format_list_numbered, _tx.s('detailedSteps')),
          Divider(height: 1, color: _rt_Lab.border),
          const SizedBox(height: 10),
          for (var i = 0; i < steps.length; i++) _stepCard(i, (steps[i] as Map).cast<String, dynamic>()),
          if (_learnVisible) _learnBox(),
        ],
      ),
    );
  }

  Widget _stepCard(int index, Map<String, dynamic> step) {
    Widget para(String labelKey, Color color, String text) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '${_tx.s(labelKey)} ',
              style: TextStyle(fontWeight: FontWeight.w800, color: color),
            ),
            TextSpan(text: text),
          ],
        ),
        style: TextStyle(fontSize: 12, color: _rt_Lab.textMuted, height: 1.5),
      ),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _cCyan500.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Text(
                  '${index + 1}',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _pick(_cCyan400, _cCyan700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step['t'] as String,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _rt_Lab.text, height: 1.35),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Divider(height: 1, color: _rt_Lab.border),
          para('taskInstr', _pick(_cCyan400, _cCyan700), step['i'] as String),
          para('expOut', _pick(_cEmerald400, _cEmerald700), step['o'] as String),
          para('conceptLearned', _pick(_cAmber400, _cAmber700), step['c'] as String),
        ],
      ),
    );
  }

  Widget _learnBox() {
    final accent = _pick(_cCyan400, _cCyan700);
    return Container(
      margin: const EdgeInsets.only(top: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cCyan500.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _cCyan500.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb, size: 16, color: accent),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _tx.s('what_we_learn').toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _tx.s('s${_step}_learn'),
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w500,
              color: _pick(_cCyan200.withValues(alpha: 0.9), _cCyan700),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================= SCENARIO 1 ===
  Widget _animalArt(String a, double width) {
    final vb = _kAnimalViewBox[a]!;
    return CustomPaint(
      size: Size(width, width * vb.height / vb.width),
      painter: _RaAnimalPainter(a, (a == 'fish' || a == 'frog') ? _clock : null),
    );
  }

  Widget _animalDisc(String a, double size, {bool selected = false, bool placed = false}) {
    final meta = _kAnimalMeta[a]!;
    Widget disc = Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(colors: meta.gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
        border: Border.all(color: selected ? _cCyan500 : meta.border, width: 2),
        boxShadow: [
          selected
              ? BoxShadow(color: _cCyan500.withValues(alpha: 0.85), blurRadius: 22)
              : BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: _rt_Tw.slate950.withValues(alpha: 0.4)),
        child: _animalArt(a, size * 0.7),
      ),
    );
    if (placed) {
      disc = Opacity(
        opacity: 0.35,
        child: ColorFiltered(colorFilter: _kDesaturate, child: disc),
      );
    }
    return AnimatedScale(duration: const Duration(milliseconds: 150), scale: selected ? 1.1 : 1, child: disc);
  }

  Widget _scenario1(double w) {
    final token = ((w - 20) / 5 - 12).clamp(30.0, 56.0);
    return Column(
      children: [
        // Top row: 5 illustrated animal tokens.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          decoration: _glass(),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final a in _kS1Animals) Expanded(child: _s1Token(a, token))],
          ),
        ),
        const SizedBox(height: 12),
        _diorama(w),
      ],
    );
  }

  Widget _s1Token(String a, double size) {
    final placed = _s1.containsValue(a);
    final selected = _isSel('s1', a);
    final body = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _animalDisc(a, size, selected: selected, placed: placed),
        const SizedBox(height: 4),
        _lab(
          Text(
            _animal(a),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _slateText(200), height: 1.15),
          ),
        ),
      ],
    );
    return Draggable<_RaToken>(
      data: _RaToken('s1', a),
      feedback: _dragFeedback(_animalDisc(a, size)),
      childWhenDragging: Opacity(opacity: 0.35, child: body),
      onDragStarted: () => _rt_playSfx(_rt_Sfx.click),
      onDraggableCanceled: (_, _) => _rt_playSfx(_rt_Sfx.click),
      child: GestureDetector(
        onTap: () => _select('s1', a),
        child: MouseRegion(cursor: SystemMouseCursors.grab, child: body),
      ),
    );
  }

  /// Pond vs land/nest diorama with the five neutral "?" slots.
  Widget _diorama(double w) {
    final h = (w * 0.45).clamp(230.0, 300.0);
    final gap = w >= 460 ? 14.0 : 6.0;
    final d = ((w - 24 - 16 - 4 * gap) / 6).clamp(20.0, 60.0);
    return Container(
      height: h,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: _slate900(0.8),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _borderC, width: 2),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 24, offset: const Offset(0, 10))],
      ),
      child: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _RaDioramaPainter(_clock))),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // External fertilisation zone (2 live slots + 1 inactive).
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _s1Slot('ext_1', d),
                              SizedBox(width: gap),
                              _s1Slot('ext_2', d),
                              SizedBox(width: gap),
                              _s1InactiveSlot(d),
                            ],
                          ),
                          // Internal fertilisation zone (3 slots).
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _s1Slot('int_1', d),
                              SizedBox(width: gap),
                              _s1Slot('int_2', d),
                              SizedBox(width: gap),
                              _s1Slot('int_3', d),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: _zoneBanner(false),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 260),
                          child: _zoneBanner(true),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _zoneBanner(bool internal) {
    final accent = internal ? _cAmber500 : _cCyan500;
    final align = internal ? TextAlign.right : TextAlign.left;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: _glass(border: accent.withValues(alpha: 0.4)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: internal ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          _lab(
            Text(
              _tx.s(internal ? 's1IntTitle' : 's1ExtTitle').toUpperCase(),
              textAlign: align,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.4,
                color: internal ? _pick(_cAmber300, _cAmber700) : _pick(_cCyan300, _cCyan700),
              ),
            ),
          ),
          const SizedBox(height: 2),
          _lab(
            Text(
              _tx.s(internal ? 's1IntSub' : 's1ExtSub'),
              textAlign: align,
              style: TextStyle(fontSize: 9.5, color: _slateText(300), height: 1.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _s1Slot(String slot, double d) {
    final assigned = _s1[slot];
    final internal = slot.startsWith('int');
    final accent = internal ? _cAmber400 : _cCyan400;
    return DragTarget<_RaToken>(
      onWillAcceptWithDetails: (det) => det.data.kind == 's1',
      onAcceptWithDetails: (det) => _placeS1(det.data.id, slot),
      builder: (context, cand, _) {
        final over = cand.isNotEmpty;
        final filled = assigned != null;
        return GestureDetector(
          onTap: () => _onS1SlotTap(slot),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: over ? 1.12 : 1,
            child: SizedBox(
              width: d,
              height: d,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: over
                            ? _cCyan500.withValues(alpha: 0.35)
                            : filled
                            ? Color.alphaBlend(_cCyan500.withValues(alpha: 0.2), _glassBg)
                            : _glassBg,
                        border: Border.all(color: over || filled ? _cCyan400 : accent.withValues(alpha: 0.8), width: 2),
                        boxShadow: [
                          over
                              ? BoxShadow(color: _cCyan500.withValues(alpha: 0.6), blurRadius: 25)
                              : BoxShadow(color: _rt_Lab.shadow, blurRadius: 10, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: assigned != null
                          ? _animalArt(assigned, d * 0.62)
                          : _lab(
                              Text(
                                '?',
                                style: TextStyle(
                                  fontSize: math.max(12.0, d * 0.3),
                                  fontWeight: FontWeight.w800,
                                  color: internal ? _pick(_cAmber300, _cAmber700) : _pick(_cCyan300, _cCyan700),
                                ),
                              ),
                            ),
                    ),
                  ),
                  if (filled) Positioned(top: 0, right: 0, child: _clearButton(() => _clearS1(slot), 18)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// The third pond disc is a dashed, inactive placeholder in the source.
  Widget _s1InactiveSlot(double d) => Opacity(
    opacity: 0.4,
    child: CustomPaint(
      foregroundPainter: _RaDashedBorderPainter(color: _rt_Tw.slate600, radius: d / 2, strokeWidth: 2),
      child: Container(
        width: d,
        height: d,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: _glassBg),
        child: _lab(const Text('?', style: TextStyle(fontSize: 12, color: _rt_Tw.slate500))),
      ),
    ),
  );

  // ========================================================= SCENARIO 2 ===
  Widget _scenario2(double w) {
    final cols = w >= 520 ? 4 : 2;
    final pillW = ((w - 20 - (cols - 1) * 8) / cols).floorToDouble();
    final accent = _pick(_cCyan300, _cCyan700);
    return Column(
      children: [
        // Table card.
        Container(
          padding: const EdgeInsets.all(12),
          decoration: _glass(border: _cCyan500.withValues(alpha: 0.4), radius: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _tx.s('s2TableTitle').toUpperCase(),
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.6, color: accent),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _cCyan500.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_tx.s('s2.placed_badge')} $_s2Placed/16',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(height: 18, color: _borderC),
              SingleChildScrollView(scrollDirection: Axis.horizontal, child: _table114()),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // Four category trays of data chips.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: _glass(),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceAround,
            children: [for (final c in _kS2Cols) SizedBox(width: pillW, child: _categoryPill(c, pillW))],
          ),
        ),
      ],
    );
  }

  Widget _table114() {
    const widths = [104.0, 104.0, 120.0, 160.0, 112.0];
    Widget head(String key) => Padding(
      padding: const EdgeInsets.all(8),
      child: _lab(
        Text(
          _tx.s(key).toUpperCase(),
          style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.3, color: _slateText(300)),
        ),
      ),
    );
    Widget cell(Widget child) => Padding(padding: const EdgeInsets.all(6), child: child);
    return Table(
      columnWidths: {for (var i = 0; i < widths.length; i++) i: FixedColumnWidth(widths[i])},
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(horizontalInside: BorderSide(color: _pick(_rt_Tw.slate800, _rt_Tw.slate200))),
      children: [
        TableRow(
          decoration: BoxDecoration(color: _slate900(0.8)),
          children: [head('thAnimal'), head('thHabitat'), head('thMode'), head('thEggs'), head('thSurvival')],
        ),
        for (final a in _kS2Animals)
          TableRow(
            children: [
              cell(
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _slate900(1),
                        border: Border.all(color: _borderC),
                      ),
                      child: _animalArt(a, 24),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        _animal(a),
                        style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _slateText(100)),
                      ),
                    ),
                  ],
                ),
              ),
              cell(_tableCell(a, 'habitat')),
              cell(_tableCell(a, 'mode')),
              cell(
                Row(
                  children: [
                    Flexible(child: _tableCell(a, 'eggs')),
                    if (_s2[a]!['eggs'] != null) ...[const SizedBox(width: 6), _bars(a)],
                  ],
                ),
              ),
              cell(_tableCell(a, 'survival')),
            ],
          ),
      ],
    );
  }

  Widget _tableCell(String a, String col) {
    final val = _s2[a]![col];
    final pending = _pendingAnimal == a && _pendingCol == col;
    final accent = _colAccent(col);
    return DragTarget<_RaToken>(
      onWillAcceptWithDetails: (d) => d.data.kind == 'chip' && d.data.id.startsWith('$col|'),
      onAcceptWithDetails: (d) => _dropChip(a, col, d.data.id.split('|').last),
      builder: (context, cand, _) {
        final over = cand.isNotEmpty;
        final dashed = val == null && !over && !pending;
        final box = AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: over
                ? _cCyan500.withValues(alpha: 0.3)
                : val != null
                ? accent.withValues(alpha: 0.2)
                : _slate900(0.6),
            border: Border.all(
              color: dashed
                  ? Colors.transparent
                  : over || pending
                  ? _cCyan400
                  : accent.withValues(alpha: 0.6),
              width: pending ? 2 : 1,
            ),
          ),
          child: Text(
            val != null ? _tx.s('s2.$val') : _tx.s('s2.select_$col'),
            style: TextStyle(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: val != null ? _colCellText(col) : _rt_Tw.slate500,
              height: 1.2,
            ),
          ),
        );
        return GestureDetector(
          onTap: () => _onCellTap(a, col),
          child: dashed
              ? CustomPaint(
                  foregroundPainter: _RaDashedBorderPainter(color: _borderC, radius: 12),
                  child: box,
                )
              : box,
        );
      },
    );
  }

  Widget _bars(String a) {
    final bars = _kTableBars[a]!;
    return SizedBox(
      height: 20,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < bars.length; i++) ...[
            if (i > 0) const SizedBox(width: 4),
            Container(
              width: 6,
              height: bars[i],
              decoration: BoxDecoration(
                color: _kTableBarColors[a],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _categoryPill(String col, double width) {
    final accent = _colAccent(col);
    Widget chip(String opt, {double? w}) => Container(
      width: w,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: Color.alphaBlend(accent.withValues(alpha: 0.1), _glassBg),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Text(
        _tx.s('s2.$opt'),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _colChipText(col), height: 1.2),
      ),
    );
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _slate900(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _lab(
            Text(
              _tx.s(_kColHeaderKeys[col]!).toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, color: _slateText(400)),
            ),
          ),
          const SizedBox(height: 6),
          for (final opt in _kCategoryOptions[col]!)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Draggable<_RaToken>(
                data: _RaToken('chip', '$col|$opt'),
                feedback: _dragFeedback(chip(opt, w: math.max(60.0, width - 16))),
                childWhenDragging: Opacity(opacity: 0.4, child: chip(opt)),
                onDragStarted: () => _rt_playSfx(_rt_Sfx.click),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => _pickChip(col, opt),
                    child: chip(opt),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ========================================================= SCENARIO 3 ===
  Widget _scenario3(double w) {
    final twoCol = w >= 560;
    final inner = w - 34; // 16 px padding + 1 px border on each side
    final colW = twoCol ? (inner - 25) / 2 : inner;
    final yolk = _yolkSection();
    final bfly = _bflySection(colW);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _glass(border: _cCyan500.withValues(alpha: 0.3), radius: 24),
      child: twoCol
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: colW + 12,
                  padding: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    border: Border(right: BorderSide(color: _borderC)),
                  ),
                  child: yolk,
                ),
                const SizedBox(width: 12),
                SizedBox(width: colW, child: bfly),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                yolk,
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Divider(height: 1, color: _borderC),
                ),
                bfly,
              ],
            ),
    );
  }

  Widget _sectionTitle(String text, Widget icon) => Row(
    children: [
      Expanded(
        child: Text(
          text.toUpperCase(),
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: _slateText(100)),
        ),
      ),
      icon,
    ],
  );

  /// Left half: yolk strategy branching tree, tokens and explainer cards.
  Widget _yolkSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(_tx.s('s3YolkTitle'), Icon(Icons.call_split, size: 20, color: _pick(_cCyan400, _cCyan700))),
        const SizedBox(height: 10),
        _branchDiagram(),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          alignment: WrapAlignment.spaceBetween,
          children: [for (final pk in _kPathAnimals) _yolkToken(pk)],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _subCard('A', _cAmber500, const _RaEggCutawayPainter(), const Size(64, 32), 's3CardADesc')),
            const SizedBox(width: 8),
            Expanded(
              child: _subCard('B', _cEmerald500, const _RaMetamorphosisPainter(), const Size(80, 32), 's3CardBDesc'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _branchDiagram() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _slate900(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderC),
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: CustomPaint(painter: _RaBranchPainter())),
          Row(
            children: [
              _glowEgg(),
              const SizedBox(width: 36),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [_pathZone('larva'), const SizedBox(height: 12), _pathZone('direct')],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Glowing yolk egg at the root of the tree (`animate-egg-glow`, 2.2 s).
  Widget _glowEgg() => AnimatedBuilder(
    animation: _clock,
    builder: (context, _) {
      final p = 0.5 - 0.5 * math.cos(2 * math.pi * (_seconds % 2.2) / 2.2);
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _cAmber500.withValues(alpha: 0.2),
          border: Border.all(color: _cAmber400, width: 2),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFACC15).withValues(alpha: 0.6 + 0.4 * p),
              blurRadius: 4 + 11 * p,
            ),
          ],
        ),
        child: Icon(Icons.egg, size: 22, color: _pick(_cAmber300, _cAmber700)),
      );
    },
  );

  Widget _pathZone(String path) {
    final larva = path == 'larva';
    final accent = larva ? _cEmerald500 : _cAmber500;
    final items = larva ? _larva : _direct;
    final placeholder = larva
        ? '[ ${_animal('frog')}, ${_animal('butterfly')} ]'
        : '[ ${_animal('bird')}, ${_animal('lizard')} ]';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _lab(
          Text(
            _tx.s(larva ? 'larvaPath' : 'directPath').toUpperCase(),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: larva ? _pick(_cEmerald400, _cEmerald700) : _pick(_cAmber400, _cAmber700),
            ),
          ),
        ),
        const SizedBox(height: 4),
        DragTarget<_RaToken>(
          onWillAcceptWithDetails: (d) => d.data.kind == 'yolk',
          onAcceptWithDetails: (d) => _placeYolk(d.data.id, path),
          builder: (context, cand, _) {
            final over = cand.isNotEmpty;
            return GestureDetector(
              onTap: () => _onPathTap(path),
              child: CustomPaint(
                foregroundPainter: _RaDashedBorderPainter(
                  color: over ? _cCyan400 : accent.withValues(alpha: 0.8),
                  radius: 12,
                  strokeWidth: 2,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: double.infinity,
                  constraints: const BoxConstraints(minHeight: 38),
                  padding: const EdgeInsets.all(6),
                  alignment: Alignment.centerLeft,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: over ? _cCyan500.withValues(alpha: 0.3) : accent.withValues(alpha: _isDark ? 0.14 : 0.08),
                  ),
                  child: items.isEmpty
                      ? Text(
                          placeholder,
                          style: const TextStyle(fontSize: 9.5, fontStyle: FontStyle.italic, color: _rt_Tw.slate500),
                        )
                      : Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [for (final pk in items) _pathChip(path, pk, accent)],
                        ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _pathChip(String path, String pk, Color accent) => Container(
    padding: const EdgeInsets.fromLTRB(8, 2, 2, 2),
    decoration: BoxDecoration(
      color: accent.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: accent.withValues(alpha: 0.4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Flexible(
          child: Text(
            _animal(pk),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: path == 'larva' ? _pick(_cEmerald300, _cEmerald700) : _pick(_cAmber300, _cAmber700),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _removeYolk(path, pk),
          child: const Padding(
            padding: EdgeInsets.all(3),
            child: Icon(Icons.close, size: 12, color: _rt_Tw.slate400),
          ),
        ),
      ],
    ),
  );

  Widget _yolkToken(String pk) {
    final placed = _larva.contains(pk) || _direct.contains(pk);
    final selected = _isSel('yolk', pk);
    Widget visual() => AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _isDark ? _rt_Tw.slate900 : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? _cCyan500 : _borderC, width: selected ? 2 : 1),
        boxShadow: [
          selected
              ? BoxShadow(color: _cCyan500.withValues(alpha: 0.85), blurRadius: 18)
              : BoxShadow(color: _rt_Lab.shadow, blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sell, size: 13, color: _pick(_cCyan400, _cCyan700)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              _animal(pk),
              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: _slateText(200)),
            ),
          ),
        ],
      ),
    );
    final body = Opacity(
      opacity: placed ? 0.35 : 1,
      child: AnimatedScale(duration: const Duration(milliseconds: 150), scale: selected ? 1.08 : 1, child: visual()),
    );
    return Draggable<_RaToken>(
      data: _RaToken('yolk', pk),
      feedback: _dragFeedback(visual()),
      childWhenDragging: Opacity(opacity: 0.3, child: visual()),
      onDragStarted: () => _rt_playSfx(_rt_Sfx.click),
      onDraggableCanceled: (_, _) => _rt_playSfx(_rt_Sfx.click),
      child: GestureDetector(onTap: () => _select('yolk', pk), child: body),
    );
  }

  Widget _subCard(String letter, Color accent, CustomPainter painter, Size artSize, String descKey) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _slate900(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.3)),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 6, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: BoxDecoration(shape: BoxShape.circle, color: accent.withValues(alpha: 0.2)),
            child: Text(
              letter,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: accent),
            ),
          ),
          const SizedBox(height: 4),
          CustomPaint(size: artSize, painter: painter),
          const SizedBox(height: 4),
          _lab(
            Text(
              _tx.s(descKey),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: _slateText(300), height: 1.25),
            ),
          ),
        ],
      ),
    );
  }

  /// Right half: clockwise butterfly life-cycle ring with 5 stage slots.
  Widget _bflySection(double sw) {
    final rw = math.min(sw, 320.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(
          _tx.s('s3BflyTitle'),
          SizedBox(
            width: 30,
            height: 26,
            child: CustomPaint(painter: _RaButterflyIconPainter(_clock, _pick(_cCyan400, _cCyan600))),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: SizedBox(width: rw, height: 224, child: _ringView(rw)),
        ),
        const SizedBox(height: 8),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [for (final bk in _kBflyStages) _bflyChip(bk)],
        ),
      ],
    );
  }

  Widget _ringView(double rw) {
    const h = 224.0;
    const colW = 80.0;
    Widget slotColumn(int i) => SizedBox(
      width: colW,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ringSlot(i),
          const SizedBox(height: 3),
          _lab(
            Text(
              _stage(_kBflyStages[i]),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: _pick(_cEmerald300, _cEmerald700),
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
    return Stack(
      children: [
        const Positioned.fill(child: CustomPaint(painter: _RaRingPainter())),
        Positioned(top: 0, left: rw / 2 - colW / 2, child: slotColumn(0)),
        Positioned(top: h * 0.22, right: rw * 0.04, child: slotColumn(1)),
        Positioned(bottom: h * 0.02, right: rw * 0.12, child: slotColumn(2)),
        Positioned(bottom: h * 0.02, left: rw * 0.12, child: slotColumn(3)),
        Positioned(top: h * 0.22, left: rw * 0.04, child: slotColumn(4)),
      ],
    );
  }

  Widget _ringSlot(int i) {
    final val = _ring[i];
    return DragTarget<_RaToken>(
      onWillAcceptWithDetails: (d) => d.data.kind == 'bfly',
      onAcceptWithDetails: (d) => _placeBfly(d.data.id, i),
      builder: (context, cand, _) {
        final over = cand.isNotEmpty;
        final filled = val != null;
        return GestureDetector(
          onTap: () => _onRingTap(i),
          child: AnimatedScale(
            duration: const Duration(milliseconds: 200),
            scale: over ? 1.12 : 1,
            child: SizedBox(
              width: 48,
              height: 48,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: over
                            ? _cCyan500.withValues(alpha: 0.35)
                            : filled
                            ? Color.alphaBlend(_cCyan500.withValues(alpha: 0.3), _glassBg)
                            : _glassBg,
                        border: Border.all(
                          color: over || filled ? _cCyan400 : _cEmerald400.withValues(alpha: 0.8),
                          width: 2,
                        ),
                        boxShadow: [
                          over
                              ? BoxShadow(color: _cCyan500.withValues(alpha: 0.6), blurRadius: 25)
                              : BoxShadow(color: _rt_Lab.shadow, blurRadius: 8, offset: const Offset(0, 3)),
                        ],
                      ),
                      child: Text(
                        filled ? '✓' : '${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: filled ? _pick(_cCyan200, _cCyan700) : _pick(_cEmerald300, _cEmerald700),
                        ),
                      ),
                    ),
                  ),
                  if (filled) Positioned(top: 0, right: 0, child: _clearButton(() => _clearRing(i), 16)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _bflyChip(String bk) {
    final placed = _ring.contains(bk);
    final selected = _isSel('bfly', bk);
    Widget visual() => AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Color.alphaBlend(_cCyan500.withValues(alpha: 0.1), _glassBg),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: selected ? _cCyan500 : _cCyan500.withValues(alpha: 0.4), width: selected ? 2 : 1),
        boxShadow: selected ? [BoxShadow(color: _cCyan500.withValues(alpha: 0.85), blurRadius: 18)] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle, size: 13, color: _pick(_cCyan400, _cCyan700)),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              _stage(bk),
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _pick(_cCyan200, _cCyan700)),
            ),
          ),
        ],
      ),
    );
    final body = Opacity(
      opacity: placed ? 0.35 : 1,
      child: AnimatedScale(duration: const Duration(milliseconds: 150), scale: selected ? 1.08 : 1, child: visual()),
    );
    return Draggable<_RaToken>(
      data: _RaToken('bfly', bk),
      feedback: _dragFeedback(visual()),
      childWhenDragging: Opacity(opacity: 0.3, child: visual()),
      onDragStarted: () => _rt_playSfx(_rt_Sfx.click),
      onDraggableCanceled: (_, _) => _rt_playSfx(_rt_Sfx.click),
      child: GestureDetector(onTap: () => _select('bfly', bk), child: body),
    );
  }

  // ========================================================= SCENARIO 4 ===
  Widget _scenario4(double w) {
    final row = w >= 540;
    const factW = 236.0;
    final inner = w - 36; // 16 px padding + 2 px border on each side
    final artW = row ? inner - factW - 20 : inner;
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _slate900(0.9),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _cRose500.withValues(alpha: 0.4), width: 2),
            boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 24, offset: const Offset(0, 10))],
          ),
          child: row
              ? Row(
                  children: [
                    SizedBox(width: artW, child: _capybara(artW)),
                    const SizedBox(width: 20),
                    SizedBox(width: factW, child: _factChip()),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [_capybara(artW), const SizedBox(height: 16), _factChip()],
                ),
        ),
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 32,
          runSpacing: 12,
          children: [_pedestal('inside'), _pedestal('outside')],
        ),
      ],
    );
  }

  /// Capybara with womb cutaway, pulsing zygote and the floating label.
  Widget _capybara(double aw) {
    final h = (aw * 250 / 440 + 18).clamp(140.0, 280.0);
    return SizedBox(
      height: h,
      child: Stack(
        children: [
          Positioned.fill(top: 18, child: CustomPaint(painter: _RaCapybaraPainter(_clock))),
          Positioned(
            top: 0,
            left: 12,
            child: _lab(
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: _isDark ? _rt_Tw.slate950.withValues(alpha: 0.8) : Colors.white,
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: _cAmber500.withValues(alpha: 0.6), width: 2),
                  boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.pets, size: 13, color: _cAmber400),
                    const SizedBox(width: 6),
                    Text(
                      _tx.s('mammalLabel').toUpperCase(),
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.6,
                        color: _pick(_cAmber300, _cAmber700),
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

  /// "fact chip" card with the True / False breast-milk toggle.
  Widget _factChip() {
    final accent = _pick(_cCyan300, _cCyan700);
    final toggleText = TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: _slateText(300));
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _glass(border: _cCyan500.withValues(alpha: 0.4), radius: 24, width: 2),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _tx.s('s4FactChipTitle').toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.8, color: accent),
                ),
              ),
              Icon(Icons.workspace_premium, size: 18, color: _pick(_cCyan400, _cCyan700)),
            ],
          ),
          Divider(height: 16, color: _cCyan500.withValues(alpha: 0.3)),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _slate900(0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _borderC),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(_tx.s('true'), textAlign: TextAlign.center, style: toggleText),
                ),
                _milkToggle(),
                Expanded(
                  child: Text(_tx.s('false'), textAlign: TextAlign.center, style: toggleText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _tx.s('s4MilkFact'),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _slateText(200), height: 1.5),
          ),
        ],
      ),
    );
  }

  /// Switch: on (cyan, knob right) means the fact is marked True.
  Widget _milkToggle() => GestureDetector(
    onTap: _toggleMilk,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 56,
      height: 28,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _milkFact ? _cCyan500 : _rt_Tw.slate700,
        borderRadius: BorderRadius.circular(99),
        boxShadow: _milkFact ? [BoxShadow(color: _cCyan500.withValues(alpha: 0.6), blurRadius: 20)] : null,
      ),
      child: AnimatedAlign(
        duration: const Duration(milliseconds: 300),
        alignment: _milkFact ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.25), blurRadius: 4)],
          ),
        ),
      ),
    ),
  );

  /// One of the two pedestal targets under the mammal.
  Widget _pedestal(String target) {
    final inside = target == 'inside';
    final sel = _target == target;
    final dim = _target != null && !sel;
    final hue = inside ? _cCyan500 : _cRose500;
    final Color border;
    final Color bg;
    final Color fg;
    if (sel) {
      border = inside ? _cCyan400 : _cRose500;
      bg = Color.alphaBlend(hue.withValues(alpha: 0.3), _glassBg);
      fg = inside ? _pick(_cCyan200, _cCyan700) : _pick(_cRose200, _cRose700);
    } else if (dim) {
      border = _rt_Tw.slate700;
      bg = _glassBg;
      fg = _rt_Tw.slate500;
    } else {
      border = inside ? _cCyan400.withValues(alpha: 0.8) : _rt_Tw.slate600;
      bg = _glassBg;
      fg = inside ? _pick(_cCyan300, _cCyan700) : _slateText(400);
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => _onTarget(target),
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: dim ? 0.4 : 1,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 128,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(99),
                border: Border.all(color: border, width: 2),
                boxShadow: [
                  sel
                      ? BoxShadow(color: hue.withValues(alpha: 0.6), blurRadius: 30)
                      : BoxShadow(color: _rt_Lab.shadow, blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Text(
                _tx.s(sel ? 'selectedBtn' : 'selectBtn'),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: fg),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        _lab(
          Text(
            _tx.s(inside ? 's4InsideMotherBody' : 's4ExternalEgg').toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
              color: inside ? _slateText(200) : _slateText(400),
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Inline SVG artwork of the source, redrawn with CustomPainter.

/// Scales [canvas] so a viewBox of [vw] x [vh] fits [size] (xMidYMid meet).
void _raFit(Canvas canvas, Size size, double vw, double vh) {
  final s = math.min(size.width / vw, size.height / vh);
  canvas.translate((size.width - vw * s) / 2, (size.height - vh * s) / 2);
  canvas.scale(s);
}

Paint _raFill(Color color, [double opacity = 1]) => Paint()..color = color.withValues(alpha: opacity);

Paint _raStroke(Color color, double width, {double opacity = 1, StrokeCap cap = StrokeCap.butt}) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = cap
  ..color = color.withValues(alpha: opacity);

void _raOval(Canvas canvas, double cx, double cy, double rx, double ry, Paint paint, {double rotDeg = 0}) {
  if (rotDeg == 0) {
    canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2), paint);
    return;
  }
  canvas.save();
  canvas.translate(cx, cy);
  canvas.rotate(rotDeg * math.pi / 180);
  canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: rx * 2, height: ry * 2), paint);
  canvas.restore();
}

/// Ellipse filled with an objectBoundingBox `<radialGradient>` (cx, cy, r as
/// fractions of the box), stretched with the ellipse like the SVG does.
void _raOvalGradient(
  Canvas canvas,
  double cx,
  double cy,
  double rx,
  double ry,
  List<Color> colors,
  List<double> stops, {
  double fx = 0.5,
  double fy = 0.5,
  double r = 0.5,
  double rotDeg = 0,
}) {
  canvas.save();
  canvas.translate(cx, cy);
  if (rotDeg != 0) canvas.rotate(rotDeg * math.pi / 180);
  canvas.scale(rx, ry);
  const box = Rect.fromLTWH(-1, -1, 2, 2);
  canvas.drawOval(
    box,
    Paint()
      ..shader = RadialGradient(
        center: Alignment(fx * 2 - 1, fy * 2 - 1),
        radius: r,
        colors: colors,
        stops: stops,
      ).createShader(box),
  );
  canvas.restore();
}

/// `stroke-dasharray` for an arbitrary path.
Path _raDash(Path source, double dash, double gap) {
  final out = Path();
  for (final m in source.computeMetrics()) {
    var d = 0.0;
    while (d < m.length) {
      out.addPath(m.extractPath(d, math.min(d + dash, m.length)), Offset.zero);
      d += dash + gap;
    }
  }
  return out;
}

/// Piecewise CSS keyframe interpolation (ease-in-out per segment).
double _raKeyframes(double p, List<double> stops, List<double> values) {
  for (var i = 0; i < stops.length - 1; i++) {
    if (p <= stops[i + 1]) {
      final local = ((p - stops[i]) / (stops[i + 1] - stops[i])).clamp(0.0, 1.0);
      return values[i] + (values[i + 1] - values[i]) * Curves.easeInOut.transform(local);
    }
  }
  return values.last;
}

/// Dashed rounded-rect / circle outline (`border-dashed`).
class _RaDashedBorderPainter extends CustomPainter {
  const _RaDashedBorderPainter({required this.color, required this.radius, this.strokeWidth = 1.5});

  final Color color;
  final double radius;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = (Offset.zero & size).deflate(strokeWidth / 2);
    final rr = RRect.fromRectAndRadius(rect, Radius.circular(math.min(radius, rect.shortestSide / 2)));
    canvas.drawPath(_raDash(Path()..addRRect(rr), 5, 4), _raStroke(color, strokeWidth));
  }

  @override
  bool shouldRepaint(_RaDashedBorderPainter old) =>
      old.color != color || old.radius != radius || old.strokeWidth != strokeWidth;
}

/// The five token animals (`animalMeta[*].svg`), with the fish swim and
/// frog breathe loops.
class _RaAnimalPainter extends CustomPainter {
  _RaAnimalPainter(this.kind, this.clock) : super(repaint: clock);

  final String kind;
  final Animation<double>? clock;

  @override
  void paint(Canvas canvas, Size size) {
    final vb = _kAnimalViewBox[kind]!;
    final t = (clock?.value ?? 0) * 1000;
    canvas.save();
    _raFit(canvas, size, vb.width, vb.height);
    switch (kind) {
      case 'fish':
        _fish(canvas, t);
      case 'frog':
        _frog(canvas, t);
      case 'lizard':
        _lizard(canvas);
      case 'bird':
        _bird(canvas);
      default:
        _mammal(canvas);
    }
    canvas.restore();
  }

  void _fish(Canvas c, double t) {
    // swimFish 3.2 s: 25 % (8, -4, 3deg), 75 % (-6, 5, -3deg).
    final p = (t % 3.2) / 3.2;
    const stops = [0.0, 0.25, 0.75, 1.0];
    final dx = _raKeyframes(p, stops, const [0, 8, -6, 0]);
    final dy = _raKeyframes(p, stops, const [0, -4, 5, 0]);
    final rot = _raKeyframes(p, stops, const [0, 3, -3, 0]);
    c.translate(23 + dx, 14 + dy);
    c.rotate(rot * math.pi / 180);
    c.translate(-23, -14);
    final body = Path()
      ..moveTo(8, 14)
      ..cubicTo(16, 4, 34, 6, 42, 14)
      ..cubicTo(34, 22, 16, 24, 8, 14)
      ..close();
    c.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFF0284C7), Color(0xFF38BDF8), Color(0xFF7DD3FC)],
        ).createShader(body.getBounds()),
    );
    c.drawPath(body, _raStroke(const Color(0xFF0369A1), 1.8));
    final tail = Path()
      ..moveTo(8, 14)
      ..lineTo(1, 6)
      ..lineTo(4, 14)
      ..lineTo(1, 22)
      ..close();
    c.drawPath(tail, _raFill(const Color(0xFF0284C7)));
    c.drawPath(tail, _raStroke(const Color(0xFF0369A1), 1));
    c.drawCircle(const Offset(36, 11.5), 2, _raFill(const Color(0xFF0F172A)));
    c.drawCircle(const Offset(37, 11), 0.7, _raFill(Colors.white));
    c.drawPath(
      Path()
        ..moveTo(22, 8)
        ..quadraticBezierTo(20, 3, 15, 5),
      _raStroke(const Color(0xFF0284C7), 1.5),
    );
    c.drawPath(
      Path()
        ..moveTo(20, 20)
        ..quadraticBezierTo(18, 25, 14, 23),
      _raStroke(const Color(0xFF0284C7), 1.5),
    );
    c.drawPath(
      Path()
        ..moveTo(25, 10)
        ..quadraticBezierTo(28, 14, 25, 18),
      _raStroke(Colors.white, 1, opacity: 0.6),
    );
  }

  void _frog(Canvas c, double t) {
    // breatheFrog 2.4 s: 50 % scale(1.08) translateY(-3).
    final p = (t % 2.4) / 2.4;
    const stops = [0.0, 0.5, 1.0];
    final s = _raKeyframes(p, stops, const [1, 1.08, 1]);
    final ty = _raKeyframes(p, stops, const [0, -3, 0]);
    c.translate(21, 17 + ty);
    c.scale(s);
    c.translate(-21, -17);
    _raOvalGradient(
      c,
      21,
      19,
      14,
      10,
      const [Color(0xFF4ADE80), Color(0xFF16A34A), Color(0xFF14532D)],
      const [0, 0.7, 1],
      fx: 0.4,
      fy: 0.3,
      r: 0.7,
    );
    _raOval(c, 21, 19, 14, 10, _raStroke(const Color(0xFF14532D), 1.8));
    for (final x in const [14.0, 28.0]) {
      c.drawCircle(Offset(x, 10), 4.2, _raFill(const Color(0xFF22C55E)));
      c.drawCircle(Offset(x, 10), 4.2, _raStroke(const Color(0xFF14532D), 1.5));
    }
    for (final x in const [14.5, 27.5]) {
      c.drawCircle(Offset(x, 9.5), 2.2, _raFill(const Color(0xFFFACC15)));
      c.drawCircle(Offset(x, 9.5), 1.2, _raFill(Colors.black));
    }
    _raOval(c, 11, 24, 5, 3.5, _raFill(const Color(0xFF15803D)));
    _raOval(c, 31, 24, 5, 3.5, _raFill(const Color(0xFF15803D)));
    c.drawCircle(const Offset(18, 17), 1.2, _raFill(const Color(0xFF14532D), 0.7));
    c.drawCircle(const Offset(24, 18), 1.5, _raFill(const Color(0xFF14532D), 0.7));
  }

  void _lizard(Canvas c) {
    final body = Path()
      ..moveTo(4, 14)
      ..quadraticBezierTo(16, 6, 28, 14)
      ..quadraticBezierTo(36, 21, 42, 14);
    c.drawPath(body, _raStroke(const Color(0xFF65A30D), 4, cap: StrokeCap.round));
    c.drawPath(body, _raStroke(const Color(0xFF84CC16), 2, cap: StrokeCap.round));
    c.drawCircle(const Offset(42, 14), 3.8, _raFill(const Color(0xFF4D7C0F)));
    c.drawCircle(const Offset(43, 13), 1.2, _raFill(Colors.black));
    final legs = Path()
      ..moveTo(14, 11)
      ..lineTo(9, 5)
      ..moveTo(24, 10)
      ..lineTo(26, 4)
      ..moveTo(18, 17)
      ..lineTo(13, 23)
      ..lineTo(10, 24)
      ..moveTo(30, 18)
      ..lineTo(33, 24);
    c.drawPath(legs, _raStroke(const Color(0xFF3F6212), 2.2, cap: StrokeCap.round));
  }

  void _bird(Canvas c) {
    _raOval(c, 22, 14, 12, 9, _raFill(const Color(0xFF0284C7)));
    _raOval(c, 22, 14, 12, 9, _raStroke(const Color(0xFF0369A1), 1.5));
    c.drawCircle(const Offset(12, 10), 5.5, _raFill(const Color(0xFF38BDF8)));
    c.drawPath(
      Path()
        ..moveTo(7, 10)
        ..lineTo(2, 11)
        ..lineTo(7, 13)
        ..close(),
      _raFill(const Color(0xFFFACC15)),
    );
    c.drawCircle(const Offset(11, 9), 1.5, _raFill(Colors.black));
    c.drawPath(
      Path()
        ..moveTo(18, 14)
        ..quadraticBezierTo(26, 8, 30, 16)
        ..quadraticBezierTo(24, 20, 18, 14)
        ..close(),
      _raFill(const Color(0xFFF97316)),
    );
    _raOval(c, 36, 19, 4.8, 7.5, _raFill(Colors.white));
    _raOval(c, 36, 19, 4.8, 7.5, _raStroke(const Color(0xFFCBD5E1), 1.2));
  }

  void _mammal(Canvas c) {
    _raOval(c, 25, 16, 15, 10, _raFill(const Color(0xFFA16207)));
    _raOval(c, 25, 16, 15, 10, _raStroke(const Color(0xFF713F12), 1.8));
    c.drawCircle(const Offset(11, 12), 6, _raFill(const Color(0xFF854D0E)));
    _raOval(c, 10, 5, 2, 3.8, _raFill(const Color(0xFF713F12)));
    c.drawCircle(const Offset(9, 11.5), 1.5, _raFill(Colors.black));
    final leg = _raFill(const Color(0xFF713F12));
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(16, 22, 4, 6.5), const Radius.circular(1)), leg);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(31, 22, 4, 6.5), const Radius.circular(1)), leg);
  }

  @override
  bool shouldRepaint(_RaAnimalPainter old) => old.kind != kind || old.clock != clock;
}

/// Scenario 1 backdrop (800 x 380 viewBox): pond with reeds, lily and
/// ripples on the left; hill, oak tree and twig nest on the right.
class _RaDioramaPainter extends CustomPainter {
  _RaDioramaPainter(this.clock) : super(repaint: clock);

  final Animation<double> clock;

  @override
  void paint(Canvas c, Size size) {
    final t = clock.value * 1000;
    c.save();
    c.scale(size.width / 800, size.height / 380);

    // Pond water body.
    final pond = Path()
      ..moveTo(0, 50)
      ..quadraticBezierTo(230, 30, 400, 180)
      ..quadraticBezierTo(420, 300, 0, 380)
      ..close();
    c.drawPath(
      pond,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x8C38BDF8), Color(0x730284C7), Color(0xA6075985)],
          stops: [0, 0.45, 1],
        ).createShader(pond.getBounds()),
    );
    _raOval(c, 180, 140, 90, 25, _raFill(Colors.white, 0.08));
    _ripple(c, t, 140, 230, 45, 14, 0, 0.7);
    _ripple(c, t, 290, 270, 38, 12, 1.3, 0.5);

    // Cattails / reeds on the left bank.
    c.drawPath(
      Path()
        ..moveTo(12, 270)
        ..quadraticBezierTo(5, 170, 18, 90),
      _raStroke(const Color(0xFF166534), 3),
    );
    c.drawPath(
      Path()
        ..moveTo(28, 290)
        ..quadraticBezierTo(38, 180, 25, 80),
      _raStroke(const Color(0xFF14532D), 3.5),
    );
    _raOval(c, 18, 110, 5, 22, _raFill(const Color(0xFF451A03)));
    _raOval(c, 25, 98, 5, 20, _raFill(const Color(0xFF451A03)));
    c.drawPath(
      Path()
        ..moveTo(22, 260)
        ..quadraticBezierTo(15, 150, 30, 120),
      _raStroke(const Color(0xFF16A34A), 4.5),
    );
    c.drawPath(
      Path()
        ..moveTo(42, 280)
        ..quadraticBezierTo(52, 140, 38, 110),
      _raStroke(const Color(0xFF15803D), 4.5),
    );
    _raOval(c, 30, 135, 6.5, 24, _raFill(const Color(0xFF78350F)));
    _raOval(c, 38, 125, 6.5, 22, _raFill(const Color(0xFF581C87), 0.2));
    _raOval(c, 38, 125, 6, 22, _raFill(const Color(0xFF78350F)));
    c.drawCircle(const Offset(30, 110), 2.5, _raFill(const Color(0xFFCA8A04)));
    c.drawCircle(const Offset(38, 102), 2.5, _raFill(const Color(0xFFCA8A04)));

    // Floating lily pad with lotus.
    c.save();
    c.translate(60, 240);
    final pad = Path()
      ..moveTo(30, 30)
      ..lineTo(0, 20)
      ..cubicTo(-20, 0, 20, -30, 40, -10)
      ..cubicTo(60, 10, 50, 40, 30, 30)
      ..close();
    c.drawPath(pad, _raFill(const Color(0xFF16A34A)));
    c.drawPath(pad, _raStroke(const Color(0xFF14532D), 2));
    c.drawPath(
      Path()
        ..moveTo(25, 10)
        ..lineTo(10, 0)
        ..moveTo(25, 10)
        ..lineTo(35, -15)
        ..moveTo(25, 10)
        ..lineTo(45, 15),
      _raStroke(const Color(0xFF4ADE80), 1.2, opacity: 0.6),
    );
    for (final rot in const [-30.0, 30.0]) {
      _raOval(c, 25, 5, 7, 14, _raFill(const Color(0xFFFDA4AF)), rotDeg: rot);
      _raOval(c, 25, 5, 7, 14, _raStroke(const Color(0xFFE11D48), 1), rotDeg: rot);
    }
    _raOval(c, 25, 5, 6, 15, _raFill(const Color(0xFFFFF1F2)));
    _raOval(c, 25, 5, 6, 15, _raStroke(const Color(0xFFE11D48), 1));
    c.drawCircle(const Offset(25, 5), 3.5, _raFill(const Color(0xFFFACC15)));
    c.restore();

    // Terrestrial hill.
    final land = Path()
      ..moveTo(400, 180)
      ..quadraticBezierTo(540, 100, 800, 70)
      ..lineTo(800, 380)
      ..lineTo(400, 380)
      ..close();
    c.drawPath(
      land,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x6622C55E), Color(0x7315803D), Color(0x8C713F12)],
          stops: [0, 0.6, 1],
        ).createShader(land.getBounds()),
    );

    // Oak tree.
    c.drawPath(
      Path()
        ..moveTo(720, 250)
        ..quadraticBezierTo(745, 150, 765, 50),
      _raStroke(const Color(0xFF582900), 24, cap: StrokeCap.round),
    );
    c.drawPath(
      Path()
        ..moveTo(730, 240)
        ..quadraticBezierTo(750, 160, 760, 70),
      _raStroke(const Color(0xFF78350F), 14, cap: StrokeCap.round),
    );
    c.drawPath(
      Path()
        ..moveTo(725, 160)
        ..quadraticBezierTo(700, 130, 685, 110),
      _raStroke(const Color(0xFF582900), 8, cap: StrokeCap.round),
    );
    for (final f in const [(740.0, 65.0, 60.0), (780.0, 90.0, 50.0), (695.0, 85.0, 45.0)]) {
      _raOvalGradient(
        c,
        f.$1,
        f.$2,
        f.$3,
        f.$3,
        const [Color(0xFF4ADE80), Color(0xFF15803D), Color(0xFF14532D)],
        const [0, 0.7, 1],
        fx: 0.4,
        fy: 0.4,
        r: 0.6,
      );
    }
    c.drawCircle(const Offset(735, 105), 38, _raFill(const Color(0xFF16A34A), 0.8));

    // Woven twig nest with three speckled eggs.
    c.save();
    c.translate(570, 190);
    _raOval(c, 60, 48, 65, 18, _raFill(Colors.black, 0.35));
    _raOval(c, 60, 38, 58, 24, _raFill(const Color(0xFF451A03)));
    _raOval(c, 60, 38, 58, 24, _raStroke(const Color(0xFF271003), 3));
    c.drawPath(
      Path()
        ..moveTo(5, 32)
        ..quadraticBezierTo(60, 56, 115, 32),
      _raStroke(const Color(0xFF78350F), 3),
    );
    c.drawPath(
      Path()
        ..moveTo(10, 40)
        ..quadraticBezierTo(60, 20, 110, 40),
      _raStroke(const Color(0xFF92400E), 3),
    );
    c.drawPath(
      Path()
        ..moveTo(18, 46)
        ..quadraticBezierTo(60, 60, 102, 46),
      _raStroke(const Color(0xFFB45309), 2.5),
    );
    c.drawPath(
      Path()
        ..moveTo(2, 36)
        ..quadraticBezierTo(60, 42, 118, 36),
      _raStroke(const Color(0xFF582900), 2),
    );
    for (final e in const [
      (42.0, 30.0, 10.0, 15.0, -18.0),
      (60.0, 27.0, 11.0, 16.0, 0.0),
      (78.0, 32.0, 10.0, 15.0, 22.0),
    ]) {
      _raOvalGradient(
        c,
        e.$1,
        e.$2,
        e.$3,
        e.$4,
        const [Colors.white, Color(0xFFF1F5F9), Color(0xFF94A3B8)],
        const [0, 0.6, 1],
        fx: 0.35,
        fy: 0.3,
        r: 0.65,
        rotDeg: e.$5,
      );
      _raOval(c, e.$1, e.$2, e.$3, e.$4, _raStroke(const Color(0xFFCBD5E1), 1.5), rotDeg: e.$5);
    }
    for (final s in const [(40.0, 28.0, 0.9), (62.0, 24.0, 1.0), (76.0, 30.0, 0.9)]) {
      c.drawCircle(Offset(s.$1, s.$2), s.$3, _raFill(const Color(0xFF92400E), 0.6));
    }
    c.restore();

    // Dashed guide curves from the token row down to the slots.
    for (final f in const [
      (120.0, 30.0, 130.0, 110.0, 100.0, 180.0, Color(0xFF38BDF8)),
      (240.0, 30.0, 220.0, 120.0, 190.0, 180.0, Color(0xFF22C55E)),
      (420.0, 30.0, 450.0, 110.0, 470.0, 180.0, Color(0xFF84CC16)),
      (540.0, 30.0, 550.0, 110.0, 570.0, 180.0, Color(0xFFF97316)),
      (660.0, 30.0, 670.0, 110.0, 670.0, 180.0, Color(0xFFA8A29E)),
    ]) {
      final p = Path()
        ..moveTo(f.$1, f.$2)
        ..quadraticBezierTo(f.$3, f.$4, f.$5, f.$6);
      c.drawPath(_raDash(p, 5, 5), _raStroke(f.$7, 2.5, opacity: 0.6));
    }
    c.restore();
  }

  /// `waterRipple` (2.6 s): the ring fades out while its stroke thins.
  void _ripple(Canvas c, double t, double cx, double cy, double rx, double ry, double delay, double restOpacity) {
    var opacity = restOpacity;
    var width = 1.8;
    if (t >= delay) {
      final e = const Cubic(0.1, 0.8, 0.3, 1).transform(((t - delay) % 2.6) / 2.6);
      opacity = 0.9 * (1 - e);
      width = 2.5 - 2 * e;
    }
    _raOval(c, cx, cy, rx, ry, _raStroke(const Color(0xFF7DD3FC), width, opacity: opacity));
  }

  @override
  bool shouldRepaint(_RaDioramaPainter old) => old.clock != clock;
}

/// Card A: egg cutaway — big yolk, then a shrunken yolk with an embryo.
class _RaEggCutawayPainter extends CustomPainter {
  const _RaEggCutawayPainter();

  @override
  void paint(Canvas c, Size size) {
    c.save();
    _raFit(c, size, 70, 35);
    _raOval(c, 18, 18, 14, 16, _raFill(const Color(0xFFFEF08A)));
    _raOval(c, 18, 18, 14, 16, _raStroke(const Color(0xFFCA8A04), 1));
    c.drawCircle(const Offset(18, 18), 7, _raFill(const Color(0xFFF59E0B)));
    c.drawLine(const Offset(35, 18), const Offset(42, 18), _raStroke(const Color(0xFF94A3B8), 1.5));
    _raOval(c, 56, 18, 14, 16, _raFill(const Color(0xFFFFEDD5)));
    _raOval(c, 56, 18, 14, 16, _raStroke(const Color(0xFFEA580C), 1));
    c.drawCircle(const Offset(56, 18), 4, _raFill(const Color(0xFFEA580C)));
    c.drawPath(
      Path()
        ..moveTo(52, 14)
        ..quadraticBezierTo(58, 22, 54, 24),
      _raStroke(const Color(0xFFC2410C), 2),
    );
    c.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Card B: larva -> pupa -> adult butterfly.
class _RaMetamorphosisPainter extends CustomPainter {
  const _RaMetamorphosisPainter();

  @override
  void paint(Canvas c, Size size) {
    c.save();
    _raFit(c, size, 80, 35);
    final arrow = _raStroke(const Color(0xFF94A3B8), 1.5);
    _raOval(c, 12, 18, 8, 4, _raFill(const Color(0xFF84CC16)));
    c.drawLine(const Offset(22, 18), const Offset(26, 18), arrow);
    c.drawPath(
      Path()
        ..moveTo(36, 12)
        ..cubicTo(40, 12, 42, 24, 36, 26)
        ..close(),
      _raFill(const Color(0xFF15803D)),
    );
    c.drawLine(const Offset(44, 18), const Offset(48, 18), arrow);
    c.drawPath(
      Path()
        ..moveTo(64, 18)
        ..cubicTo(56, 10, 56, 26, 64, 18)
        ..cubicTo(72, 10, 72, 26, 64, 18)
        ..close(),
      _raFill(const Color(0xFFF97316)),
    );
    c.drawLine(const Offset(64, 12), const Offset(64, 24), _raStroke(Colors.black, 1.5));
    c.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Duotone butterfly header icon with the `flutterButterfly` loop (1.8 s).
class _RaButterflyIconPainter extends CustomPainter {
  _RaButterflyIconPainter(this.clock, this.color) : super(repaint: clock);

  final Animation<double> clock;
  final Color color;

  @override
  void paint(Canvas c, Size size) {
    final p = ((clock.value * 1000) % 1.8) / 1.8;
    const stops = [0.0, 0.25, 0.75, 1.0];
    final ty = _raKeyframes(p, stops, const [0, -6, 4, 0]) * 0.5;
    final rot = _raKeyframes(p, stops, const [0, -4, 4, 0]);
    final sx = _raKeyframes(p, stops, const [1, 0.8, 0.9, 1]);
    c.save();
    _raFit(c, size, 24, 24);
    c.translate(12, 12 + ty);
    c.rotate(rot * math.pi / 180);
    c.scale(sx, 1);
    c.translate(-12, -12);
    final fill = _raFill(color, 0.3);
    final line = _raStroke(color, 1.6, cap: StrokeCap.round);
    for (final w in const [
      (7.5, 8.5, 5.0, 4.2, -25.0),
      (16.5, 8.5, 5.0, 4.2, 25.0),
      (8.5, 15.5, 3.6, 3.0, 30.0),
      (15.5, 15.5, 3.6, 3.0, -30.0),
    ]) {
      _raOval(c, w.$1, w.$2, w.$3, w.$4, fill, rotDeg: w.$5);
      _raOval(c, w.$1, w.$2, w.$3, w.$4, line, rotDeg: w.$5);
    }
    c.drawLine(const Offset(12, 6), const Offset(12, 19), _raStroke(color, 1.8, cap: StrokeCap.round));
    c.drawLine(const Offset(12, 6), const Offset(10, 3), _raStroke(color, 1.2, cap: StrokeCap.round));
    c.drawLine(const Offset(12, 6), const Offset(14, 3), _raStroke(color, 1.2, cap: StrokeCap.round));
    c.restore();
  }

  @override
  bool shouldRepaint(_RaButterflyIconPainter old) => old.color != color || old.clock != clock;
}

/// Dashed life-cycle ring with clockwise arrow heads (240 x 240 viewBox).
class _RaRingPainter extends CustomPainter {
  const _RaRingPainter();

  @override
  void paint(Canvas c, Size size) {
    c.save();
    _raFit(c, size, 240, 240);
    final ring = Path()..addOval(Rect.fromCircle(center: const Offset(120, 120), radius: 82));
    c.drawPath(_raDash(ring, 6, 6), _raStroke(const Color(0xFF06B6D4), 2, opacity: 0.5));
    final head = _raFill(const Color(0xFF06B6D4));
    for (final tri in const [
      [175.0, 55.0, 185.0, 50.0, 178.0, 65.0],
      [205.0, 145.0, 210.0, 135.0, 195.0, 140.0],
      [120.0, 205.0, 110.0, 200.0, 120.0, 195.0],
      [35.0, 115.0, 30.0, 125.0, 45.0, 120.0],
    ]) {
      c.drawPath(
        Path()
          ..moveTo(tri[0], tri[1])
          ..lineTo(tri[2], tri[3])
          ..lineTo(tri[4], tri[5])
          ..close(),
        head,
      );
    }
    c.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Green (larva) and orange (direct-hatch) branches leaving the yolk egg.
class _RaBranchPainter extends CustomPainter {
  const _RaBranchPainter();

  @override
  void paint(Canvas c, Size size) {
    final y0 = size.height / 2;
    const x0 = 48.0;
    const x1 = 84.0;
    final yTop = math.min(37.0, y0);
    final yBottom = math.max(size.height - 20, y0);
    c.drawPath(
      Path()
        ..moveTo(x0, y0)
        ..cubicTo(x0 + 18, y0, x1 - 18, yTop, x1, yTop),
      _raStroke(const Color(0xFF22C55E), 3),
    );
    c.drawPath(
      Path()
        ..moveTo(x0, y0)
        ..cubicTo(x0 + 18, y0, x1 - 18, yBottom, x1, yBottom),
      _raStroke(const Color(0xFFF97316), 3),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Scenario 4 capybara (440 x 250 viewBox) with the ultrasound womb, the
/// pulsing zygote (`pulseZygoteMammal`, 1.8 s) and the pointer arrow.
class _RaCapybaraPainter extends CustomPainter {
  _RaCapybaraPainter(this.clock) : super(repaint: clock);

  final Animation<double> clock;

  @override
  void paint(Canvas c, Size size) {
    final t = clock.value * 1000;
    c.save();
    _raFit(c, size, 440, 250);

    _raOval(c, 230, 225, 160, 18, _raFill(Colors.black, 0.4));
    final shade = _raFill(const Color(0xFF581C87), 0.35);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(160, 165, 22, 52), const Radius.circular(9)), shade);
    c.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(300, 165, 24, 52), const Radius.circular(9)), shade);

    final outline = _raStroke(const Color(0xFF381A05), 3.5);
    final body = Path()
      ..moveTo(85, 155)
      ..cubicTo(72, 95, 115, 46, 220, 46)
      ..cubicTo(325, 46, 380, 72, 390, 120)
      ..cubicTo(395, 165, 355, 192, 290, 192)
      ..lineTo(125, 192)
      ..close();
    c.drawPath(
      body,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFCA8A04), Color(0xFFB45309), Color(0xFF92400E), Color(0xFF713F12)],
          stops: [0, 0.35, 0.7, 1],
        ).createShader(body.getBounds()),
    );
    c.drawPath(body, outline);
    final snout = Path()
      ..moveTo(85, 138)
      ..cubicTo(58, 128, 42, 95, 68, 68)
      ..cubicTo(90, 48, 122, 62, 132, 90)
      ..close();
    c.drawPath(
      snout,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF92400E), Color(0xFF78350F), Color(0xFF451A03)],
          stops: [0, 0.5, 1],
        ).createShader(snout.getBounds()),
    );
    c.drawPath(snout, outline);
    c.drawPath(
      Path()
        ..moveTo(140, 58)
        ..cubicTo(220, 52, 300, 56, 360, 95),
      _raStroke(const Color(0xFFFDE047), 4, opacity: 0.3, cap: StrokeCap.round),
    );

    // Ear, eye, nose and whisker dots.
    _raOval(c, 118, 58, 10, 15, _raFill(const Color(0xFF713F12)), rotDeg: -15);
    _raOval(c, 118, 58, 10, 15, _raStroke(const Color(0xFF381A05), 2.5), rotDeg: -15);
    _raOval(c, 118, 58, 6, 10, _raFill(const Color(0xFFF43F5E), 0.55), rotDeg: -15);
    c.drawCircle(const Offset(80, 82), 6, _raFill(const Color(0xFF0F172A)));
    c.drawCircle(const Offset(82, 80), 2, _raFill(Colors.white));
    c.drawCircle(const Offset(54, 112), 3.8, _raFill(const Color(0xFF1E1B4B)));
    c.drawPath(
      Path()
        ..moveTo(54, 118)
        ..quadraticBezierTo(65, 125, 76, 120),
      _raStroke(const Color(0xFF1E1B4B), 2.5),
    );
    for (final o in const [Offset(62, 104), Offset(68, 108), Offset(64, 114)]) {
      c.drawCircle(o, 1, _raFill(const Color(0xFF451A03)));
    }

    // Legs.
    final legFill = _raFill(const Color(0xFF78350F));
    final legStroke = _raStroke(const Color(0xFF381A05), 3);
    for (final r in const [
      Rect.fromLTWH(115, 175, 22, 48),
      Rect.fromLTWH(170, 175, 22, 48),
      Rect.fromLTWH(285, 175, 24, 48),
      Rect.fromLTWH(330, 175, 24, 48),
    ]) {
      final rr = RRect.fromRectAndRadius(r, const Radius.circular(8));
      c.drawRRect(rr, legFill);
      c.drawRRect(rr, legStroke);
    }

    // Ultrasound uterus cutaway.
    _raOvalGradient(
      c,
      238,
      138,
      46,
      30,
      const [Color(0xF2FECDD3), Color(0xA6FDA4AF), Color(0x4DF43F5E), Color(0x00BE123C)],
      const [0, 0.45, 0.85, 1],
    );
    c.drawPath(
      _raDash(Path()..addOval(Rect.fromCenter(center: const Offset(238, 138), width: 92, height: 60)), 5, 5),
      _raStroke(const Color(0xFFF43F5E), 2.5),
    );

    // Pulsing zygote.
    final pulse = _raKeyframes((t % 1.8) / 1.8, const [0, 0.5, 1], const [0, 1, 0]);
    final op = 0.9 + 0.1 * pulse;
    c.save();
    c.translate(238, 138);
    c.scale(1 + 0.25 * pulse);
    c.drawCircle(
      Offset.zero,
      20,
      Paint()
        ..color = Color.lerp(const Color(0xFFF43F5E), const Color(0xFFFB7185), pulse)!.withValues(alpha: 0.8)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, (8 + 14 * pulse) / 2),
    );
    c.drawCircle(Offset.zero, 20, _raFill(const Color(0xFFFDA4AF), 0.95 * op));
    c.drawCircle(Offset.zero, 20, _raStroke(const Color(0xFFE11D48), 3, opacity: op));
    final nucleus = Path()
      ..moveTo(-6, -8)
      ..cubicTo(-12, -4, -12, 8, -4, 10)
      ..cubicTo(4, 12, 10, 6, 6, -2)
      ..cubicTo(4, -6, -2, -8, -6, -8)
      ..close();
    c.drawPath(nucleus, _raFill(Colors.white, op));
    c.drawPath(nucleus, _raStroke(const Color(0xFFE11D48), 1.5, opacity: op));
    c.drawCircle(const Offset(-4, -4), 2.5, _raFill(const Color(0xFFE11D48), op));
    c.drawPath(
      Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(6, 6, 12, 2),
      _raStroke(const Color(0xFFBE123C), 1.8, opacity: op),
    );
    c.restore();

    // Pointer arrow into the womb (marker-end scales with the 4 px stroke).
    final arrow = Path()
      ..moveTo(310, 95)
      ..quadraticBezierTo(280, 102, 262, 125);
    c.drawPath(arrow, _raStroke(Colors.white, 4));
    const tip = Offset(262, 125);
    const dir = Offset(262 - 280, 125 - 102);
    final u = dir / dir.distance;
    final n = Offset(-u.dy, u.dx);
    c.drawPath(
      Path()
        ..moveTo(tip.dx + n.dx * 14, tip.dy + n.dy * 14)
        ..lineTo(tip.dx + u.dx * 40, tip.dy + u.dy * 40)
        ..lineTo(tip.dx - n.dx * 14, tip.dy - n.dy * 14)
        ..close(),
      _raFill(Colors.white),
    );
    c.drawPath(_raDash(arrow, 2, 2), _raStroke(Colors.black, 1.5));
    c.restore();
  }

  @override
  bool shouldRepaint(_RaCapybaraPainter old) => old.clock != clock;
}
