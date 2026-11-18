// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Reproduction in Plants
// Converted from Cl9S-Ch13-A3-ReproductionInPlants.html (gsap -> Flutter).

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
    'title': 'Reproduction in Plants',
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
    'pending': '[ Pending ]',
    'completed': '[ Completed ✓ ]',
    'scenario1_opt': '1. Flower Anatomy (Labeling)',
    'scenario2_opt': '2. Pollination (Transfer)',
    'scenario3_opt': '3. Fertilisation (Fusion)',
    'scenario4_opt': '4. Flower to Fruit (Sequence)',
    // Scenario 1 canvas text
    'hud_s1': 'Label all parts of the flower from outside in.',
    'stamenGroup': 'Stamen (Male)',
    'pistilGroup': 'Pistil/Carpel (Female)',
    'outerGroup': 'Accessory Whorls',
    'pinPrefix': 'Pin',
    'parts': {
      'sepal': 'Sepal',
      'petal': 'Petal',
      'stamen': 'Stamen',
      'filament': 'Filament',
      'anther': 'Anther',
      'pistil': 'Pistil / Carpel',
      'stigma': 'Stigma',
      'style': 'Style',
      'ovary': 'Ovary',
      'ovule': 'Ovule',
    },
    // Scenario 2 canvas text
    'hud_s2': 'Trigger pollen transfer and understand Self vs Cross-Pollination.',
    'selfPollTitle': '1. Self-Pollination (Autogamy)',
    'selfPollDesc':
        'Transfer of pollen grains from the anther to the stigma of the <strong>same flower</strong> or another flower on the <strong>same plant</strong>.',
    'btnSelfPoll': 'Transfer Pollen (Self)',
    'crossPollTitle': '2. Cross-Pollination (Allogamy)',
    'crossPollDesc':
        'Transfer of pollen from anther to stigma of a flower on a <strong>different plant of the same kind</strong> via agents like <strong>insects (bees)</strong> or <strong>wind</strong>.',
    'btnCrossPoll': 'Transfer Pollen (Cross via Bee/Wind)',
    'windBeeLabel': '彡 Wind / Bee Vector',
    // Scenario 3 canvas text
    'hud_s3': 'Grow pollen tube down the style to achieve gamete fusion (zygote).',
    's3TubeTitle': 'Fertilisation (Gamete Fusion)',
    's3TubeSub': 'Pollen tube grows down the style into the ovary to reach the ovule',
    'btnGrowTube': 'Grow Pollen Tube',
    's3_svg_stigma': 'Stigma',
    's3_svg_pollen': 'Pollen Grain',
    's3_svg_style': 'Style',
    's3_svg_tube': 'Pollen Tube',
    's3_svg_ovary': 'Ovary',
    's3_svg_ovule': 'Ovule',
    's3_svg_zygote': '✦ Zygote Formation',
    's3_svg_fusion': '(Gamete Fusion)',
    // Scenario 4 canvas text
    'hud_s4': 'Arrange the 5 transformation stages in correct chronological order.',
    's4_sb1_t': '1. Pollination',
    's4_sb1_d': 'Pollen transfer to stigma',
    's4_sb2_t': '2. Fertilisation',
    's4_sb2_d': 'Pollen tube reaches ovule',
    's4_sb3_t': '3. Zygote',
    's4_sb3_d': 'Gamete fusion complete (2n)',
    's4_before_t': 'BEFORE FERTILISATION',
    's4_before_d': '• Ovule (becomes seed)<br>• Ovary (becomes fruit)',
    's4_after_t': 'AFTER FERTILISATION',
    's4_after_d': '• Seed protects embryo<br>• Fruit ripens from ovary',
    's4SeqTitle': 'Sequence Flower-to-Fruit Transformation',
    's4SeqSub': 'Drag or tap cards into chronological slots 1 to 5',
    's4_cards': {
      'c1': '1. Pollination (Anther → Stigma)',
      'c2': '2. Pollen Tube Growth (Down Style)',
      'c3': '3. Fertilisation (Gamete Fusion)',
      'c4': '4. Zygote Formation',
      'c5': '5. Ovule → Seed & Ovary → Fruit',
    },
    // Pedagogical objectives & steps
    's1_obj':
        'Identify and label all four floral whorls on the cross-section botanical specimen: the non-essential protective whorls (Sepals, Petals), the male reproductive organ (Stamen: Filament, Anther), and the female reproductive organ (Carpel/Pistil: Stigma, Style, Ovary, Ovule).',
    's2_obj':
        'Understand how pollen is transferred from the anther to the stigma and distinguish between self-pollination (occurring within the same plant) and cross-pollination (occurring between different plants of the same species via biotic and abiotic agents).',
    's3_obj':
        'Trace the path of the pollen tube from the stigma down the style into the ovary, where the male gamete fuses with the female egg cell to form a single-celled diploid zygote.',
    's4_obj':
        'Trace the complete post-fertilisation developmental transformation where the fertilised ovule becomes a seed protecting the embryo and the surrounding ovary transforms into a fruit.',
    's1_steps': [
      {
        't': 'Step 1: Identify the Non-Essential Protective Whorls',
        'i':
            'Drag or tap the green protective Sepal token and place it at Pin 08 (calyx base). Next, place the vibrant Petal token at Pin 07 (corolla).',
        'o':
            'Outer whorls correctly anchored. Sepals protect delicate inner organs during the bud stage, while colorful petals attract insect pollinators.',
        'c':
            'Calyx and corolla are accessory (non-reproductive) whorls that provide mechanical defense and facilitate biotic pollination.',
      },
      {
        't': 'Step 2: Label the Male Reproductive Organ (Stamen / Androecium)',
        'i':
            'Identify the male structures: map the slender supporting Filament to Pin 05 and the bilobed pollen-producing Anther to Pin 04.',
        'o':
            'Stamen parts accurately identified. Anthers develop microspores that mature into golden pollen grains carrying male gametes (sperm nuclei).',
        'c':
            'The stamen is the male reproductive unit. Each pollen grain serves as the vehicle for male gamete transmission during pollination.',
      },
      {
        't': 'Step 3: Label the Female Reproductive Organ (Pistil / Carpel / Gynoecium)',
        'i':
            'Map the central female unit: sticky Stigma to Pin 01, slender tubular Style to Pin 02, swollen basal Ovary to Pin 03, and internal Ovule to Pin 06.',
        'o':
            'Pistil structures positioned. The sticky stigma captures airborne/insect pollen, the style guides pollen tube descent, and the ovary shelters ovules containing female egg cells.',
        'c':
            'The carpel is the female reproductive unit. Inside the ovary, each fertilized ovule is destined to become a seed.',
      },
    ],
    's2_steps': [
      {
        't': 'Step 1: Observe Self-Pollination (Autogamy)',
        'i':
            "Click 'Transfer Pollen (Self)' to observe pollen grains travel from the anther directly to the stigma of the same flower or another flower on the same plant.",
        'o':
            "Pollen lands securely on the same flower's stigma. Does not depend on external vectors and ensures high reproductive assurance.",
        'c':
            'Self-pollination preserves parental genetic traits across generations without introducing genetic diversity.',
      },
      {
        't': 'Step 2: Observe Cross-Pollination (Allogamy / Xenogamy)',
        'i':
            "Click 'Transfer Pollen (Cross via Bee/Wind)' to observe bees and wind currents transferring pollen from one plant to a flower on a different plant of the same species.",
        'o':
            'Pollen transfers between genetically distinct individuals via biotic (insects) and abiotic (wind) vectors.',
        'c':
            'Cross-pollination creates new genetic combinations, resulting in healthier offspring with greater adaptability to changing environments.',
      },
    ],
    's3_steps': [
      {
        't': 'Step 1: Initiate Chemotropic Pollen Tube Growth',
        'i':
            "Click 'Grow Pollen Tube' to watch the pollen grain germinate on the sugary stigma secretions and extend a tube down through the style into the ovary.",
        'o':
            'The pollen tube navigates through stylar tissues toward the micropyle opening of the ovule, protecting the non-motile male gametes during transit.',
        'c':
            'Pollen tube elongation is guided by chemical gradients released by the ovule, ensuring accurate targeting of the female gamete.',
      },
      {
        't': 'Step 2: Gamete Fusion & Zygote Formation',
        'i':
            'Watch the culminating fusion of the male gamete nucleus with the female egg cell nucleus inside the ovule, sparking a golden starburst.',
        'o':
            'Gametes fuse successfully, forming a diploid (2n) single-celled zygote that will divide to form the plant embryo.',
        'c':
            'Fertilisation is the biological union of haploid male and female gametes that restores the diploid chromosome number and starts embryonic growth.',
      },
    ],
    's4_steps': [
      {
        't': 'Step 1: Sequence Flower-to-Fruit Transformation',
        'i':
            'Arrange the 5 developmental cards into strict chronological order: 1. Pollination → 2. Tube Growth → 3. Fertilisation → 4. Zygote → 5. Ovule to Seed & Ovary to Fruit.',
        'o':
            'Developmental sequence locked. After fertilisation, petals and stamens wither, the ovule develops into a seed with a tough coat, and the ovary ripens into a fruit.',
        'c':
            'The fruit protects the developing seeds and facilitates their dispersal across nature, while the seed encloses the dormant embryo ready to germinate.',
      },
    ],
    's1_learn':
        'A typical flower comprises four distinct whorls: Sepals (Calyx), Petals (Corolla), Stamens (Androecium: Filament + Anther), and Carpel/Pistil (Gynoecium: Stigma + Style + Ovary with Ovules).',
    's2_learn':
        'Pollination transfers pollen from anther to stigma; self-pollination stays within one plant, while cross-pollination transfers pollen between different plants of the same species.',
    's3_learn':
        'Fertilisation is the fusion of the male gamete (carried by the pollen tube) and female gamete (in the ovule) to form a diploid zygote.',
    's4_learn':
        'Following fertilisation, the fertilized ovule develops into a seed containing the embryo, and the surrounding ovary ripens into a fruit.',
    'pinHints': {
      'sepal':
          '<strong>Pin Clue:</strong> Outermost green leaf-like whorl (Calyx) that protects the flower during the bud stage.',
      'petal':
          '<strong>Pin Clue:</strong> Brightly colored, scented leaf-like whorl (Corolla) that attracts insect pollinators.',
      'anther':
          '<strong>Pin Clue:</strong> Bilobed terminal chamber of the stamen where yellow pollen grains carrying male gametes are produced.',
      'filament':
          '<strong>Pin Clue:</strong> Slender stalk that holds up and positions the pollen-bearing anther for effective dispersal.',
      'stigma':
          '<strong>Pin Clue:</strong> Sticky terminal knob of the carpel adapted to receive and hold pollen grains.',
      'style':
          '<strong>Pin Clue:</strong> Elongated slender neck through which the pollen tube germinates and grows downward.',
      'ovary':
          '<strong>Pin Clue:</strong> Swollen basal chamber that houses the ovules and transforms into fruit after fertilisation.',
      'ovule':
          '<strong>Pin Clue:</strong> Egg-bearing structure inside the ovary that develops into a protective seed after fertilisation.',
    },
    'concTitle': 'Reproduction in Plants — Scientific Conclusion',
    'concHead1': '1. Flower as the Reproductive Organ',
    'concBody1':
        'The flower is the reproductive part of angiosperms. The stamen represents the male reproductive organ (producing pollen grains containing male gametes), while the carpel/pistil represents the female reproductive organ (containing the ovary with ovules).',
    'concHead2': '2. Pollination vs Fertilisation',
    'concBody2':
        'Pollination is the physical transfer of pollen grains from anther to stigma (via self or cross-pollination). Fertilisation is the internal biological fusion of male and female gametes to produce a single-celled zygote.',
    'concHead3': '3. Transformation from Flower to Fruit',
    'concBody3':
        'Post-fertilisation, the zygote divides to form an embryo within the ovule. The ovule develops into a protective seed, while the surrounding ovary grows rapidly and ripens into a fruit.',
    // Toasts and tool tips (hard-coded English in the source page).
    'toasts': {
      'selectPart': 'Selected "{label}". Tap any neutral pin 01 to 08 on the flower.',
      'placedPart': 'Placed {part} on Pin!',
      'selfDone': '🐝 Pollen reached the stigma of the same flower! (Self-Pollination)',
      'crossDone': '🐝💨 Pollen transferred from another plant of the same kind! (Cross-Pollination)',
      'zygote': '✨ Male gamete reached the ovule! Male + Female gametes fused to form Zygote!',
      'selectCard': 'Selected "{label}". Tap any sequence slot 1 to 5.',
      'selectFirst': 'Select a Stage Card from above first!',
      'hint2': 'Pollen transfer from anther to stigma is pollination (self = same plant; cross = different plant).',
      'hint3': "Click 'Grow Pollen Tube' to see male gamete travel down the style to fuse with the egg cell.",
      'hint4':
          'Sequence: Pollination → Tube Growth → Fertilisation → Zygote → Ovule becomes Seed & Ovary becomes Fruit.',
      's1Ok': 'Flower anatomy perfectly identified! Advancing to Pollination...',
      's1Wrong': "{n} pin(s) are incorrectly labelled or unplaced. Use '?' hints for guidance.",
      's2Ok': 'Pollination mechanics understood! Advancing to Fertilisation...',
      's2Wrong': 'Complete both Self-Pollination and Cross-Pollination animations to proceed.',
      's3Ok': 'Fertilisation & Zygote verified! Advancing to Flower-to-Fruit Transformation...',
      's3Wrong': "Click 'Grow Pollen Tube' to execute gamete fusion into a zygote.",
      's4Wrong':
          'Chronological sequence is incorrect. Ensure stages follow: Pollination → Tube Growth → Fertilisation → Zygote → Seed & Fruit.',
      'stepReset': 'Current step reset.',
      'locked': 'Canvas View Locked (2D Mode).',
      'unlocked': 'View Unlocked. Zoom and Pan Enabled.',
      'panOn': 'Pan Mode Active. Drag canvas to move.',
      'panOff': 'Pan Mode Disabled.',
      'viewReset': 'View Reset to 100%.',
    },
    'tools': {'lock': 'Lock/Unlock Canvas Zoom & Pan', 'pan': 'Pan Mode', 'labels': 'Toggle Visual Labels'},
  },
  'hi': {
    'title': 'पादपों में जनन',
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
    'pending': '[ लंबित ]',
    'completed': '[ पूर्ण ✓ ]',
    'scenario1_opt': '1. पुष्प की संरचना (नामांकन)',
    'scenario2_opt': '2. परागण (स्थानांतरण)',
    'scenario3_opt': '3. निषेचन (संलयन)',
    'scenario4_opt': '4. पुष्प से फल (अनुक्रम)',
    // Scenario 1 canvas text
    'hud_s1': 'पुष्प के सभी भागों को बाहर से अंदर की ओर लेबल करें।',
    'stamenGroup': 'पुंकेसर (नर भाग)',
    'pistilGroup': 'स्त्रीकेसर (मादा भाग)',
    'outerGroup': 'सहायक चक्र',
    'pinPrefix': 'पिन',
    'parts': {
      'sepal': 'बाह्यदल',
      'petal': 'दल / पंखुड़ी',
      'stamen': 'पुंकेसर',
      'filament': 'तंतु',
      'anther': 'परागकोश',
      'pistil': 'स्त्रीकेसर',
      'stigma': 'वर्तिकाग्र',
      'style': 'वर्तिका',
      'ovary': 'अंडाशय',
      'ovule': 'बीजांड',
    },
    // Scenario 2 canvas text
    'hud_s2': 'परागण की प्रक्रिया देखकर स्व-परागण व पर-परागण पहचानें।',
    'selfPollTitle': '1. स्व-परागण (ऑटोगैमी)',
    'selfPollDesc': 'जब परागकण उसी पुष्प या उसी पौधे के अन्य पुष्प के वर्तिकाग्र पर पहुंचते हैं।',
    'btnSelfPoll': 'परागण ट्रिगर करें (स्व-परागण)',
    'crossPollTitle': '2. पर-परागण (एलोगैमी)',
    'crossPollDesc':
        'जब परागकण उसी प्रजाति के किसी दूसरे पौधे के पुष्प के वर्तिकाग्र पर पहुंचते हैं (वायु, कीट द्वारा)।',
    'btnCrossPoll': 'परागण ट्रिगर करें (कीट/हवा द्वारा)',
    'windBeeLabel': '彡 वायु / कीट माध्यम',
    // Scenario 3 canvas text
    'hud_s3': 'पराग नली को बीजांड तक पहुंचाकर निषेचन कराएं।',
    's3TubeTitle': 'निषेचन (युग्मक संलयन)',
    's3TubeSub': 'पराग नली वर्तिकाग्र से वर्तिका होते हुए अंडाशय तक बढ़ती है',
    'btnGrowTube': 'पराग नली विकसित करें',
    's3_svg_stigma': 'वर्तिकाग्र',
    's3_svg_pollen': 'परागकण',
    's3_svg_style': 'वर्तिका',
    's3_svg_tube': 'पराग नली',
    's3_svg_ovary': 'अंडाशय',
    's3_svg_ovule': 'बीजांड',
    's3_svg_zygote': '✦ युग्मनज (जाइगोट) निर्माण',
    's3_svg_fusion': '(युग्मक संलयन)',
    // Scenario 4 canvas text
    'hud_s4': 'पुष्प से फल बनने के 5 चरणों को क्रम में लगाएं।',
    's4_sb1_t': '1. परागण',
    's4_sb1_d': 'वर्तिकाग्र पर परागकण',
    's4_sb2_t': '2. निषेचन',
    's4_sb2_d': 'बीजांड तक पराग नली',
    's4_sb3_t': '3. युग्मनज',
    's4_sb3_d': 'युग्मक संलयन पूर्ण (2n)',
    's4_before_t': 'निषेचन से पूर्व',
    's4_before_d': '• बीजांड (बीज बनता है)<br>• अंडाशय (फल बनता है)',
    's4_after_t': 'निषेचन के पश्चात',
    's4_after_d': '• बीज भ्रूण की रक्षा करता है<br>• अंडाशय फल बन जाता है',
    's4SeqTitle': 'पुष्प से फल निर्माण का अनुक्रम',
    's4SeqSub': 'चरणों को 1 से 5 के सही कालानुक्रम में व्यवस्थित करें',
    's4_cards': {
      'c1': '1. परागण (परागकोश → वर्तिकाग्र)',
      'c2': '2. पराग नली की वृद्धि (वर्तिका में)',
      'c3': '3. निषेचन (युग्मक संलयन)',
      'c4': '4. युग्मनज (जाइगोट) निर्माण',
      'c5': '5. बीजांड से बीज व अंडाशय से फल',
    },
    's1_obj':
        'मॉडल पर पुष्प के सभी प्रमुख सहायक एवं जननांग चक्रों (बाह्यदल, पंखुड़ी, पुंकेसर: परागकोश व तंतु, स्त्रीकेसर: वर्तिकाग्र, वर्तिका, अंडाशय व बीजांड) की पहचान व नामांकन करना।',
    's2_obj':
        'परागण की परिभाषा समझना तथा स्व-परागण (एक ही पौधे में) और पर-परागण (समान प्रजाति के दो अलग पौधों में) के बीच अंतर स्पष्ट करना।',
    's3_obj':
        'पराग नली के माध्यम से नर युग्मक का बीजांड तक पहुंचना और संलयन द्वारा द्विगुणित युग्मनज बनने की प्रक्रिया समझना।',
    's4_obj': 'निषेचन के पश्चात बीजांड से बीज और अंडाशय से फल बनने के संपूर्ण विकास क्रम को समझना।',
    's1_steps': [
      {
        't': 'कदम 1: बाहरी सुरक्षात्मक चक्रों की पहचान',
        'i': 'हरे बाह्यदल को पिन 08 पर और रंगीन पंखुड़ी (दल) को पिन 07 पर लगाएं।',
        'o':
            'बाहरी चक्र व्यवस्थित। बाह्यदल कली अवस्था में पुष्प की रक्षा करता है और रंगीन दल कीटों को आकर्षित करते हैं।',
        'c': 'बाह्यदलपुंज और दलपुंज सहायक चक्र हैं जो सुरक्षा और परागण में मदद करते हैं।',
      },
      {
        't': 'कदम 2: नर जनन अंग (पुंकेसर / पुमंग) का नामांकन',
        'i': 'तंतु (पतला डंठल) को पिन 05 पर और परागकोश (पराग उत्पादक) को पिन 04 पर लगाएं।',
        'o': 'पुंकेसर के भाग व्यवस्थित। परागकोश में परागकण बनते हैं जिनमें नर युग्मक होते हैं।',
        'c': 'पुंकेसर नर जनन इकाई है जो परागकणों का निर्माण करता है।',
      },
      {
        't': 'कदम 3: मादा जनन अंग (स्त्रीकेसर / जायांग) का नामांकन',
        'i': 'चिपचिपा वर्तिकाग्र पिन 01, वर्तिका पिन 02, अंडाशय पिन 03 और बीजांड पिन 06 पर लगाएं।',
        'o': 'स्त्रीकेसर के भाग व्यवस्थित। अंडाशय में बीजांड होते हैं जिनमें मादा अंड कोशिका होती है।',
        'c': 'स्त्रीकेसर मादा जनन इकाई है। निषेचन के बाद बीजांड बीज बनता है और अंडाशय फल बनता है।',
      },
    ],
    's2_steps': [
      {
        't': 'कदम 1: स्व-परागण (ऑटोगैमी) का निरीक्षण',
        'i': "'स्व-परागण' पर क्लिक करके उसी पुष्प के भीतर परागकण की गति देखें।",
        'o': 'परागकण उसी पुष्प के वर्तिकाग्र पर पहुंचते हैं। इसमें बाहरी माध्यम की आवश्यकता नहीं होती।',
        'c': 'स्व-परागण पैतृक गुणों को सुरक्षित रखता है।',
      },
      {
        't': 'कदम 2: पर-परागण (एलोगैमी) का निरीक्षण',
        'i': "'पर-परागण' पर क्लिक करके कीट/हवा द्वारा दूसरे पौधे के पुष्प तक गति देखें।",
        'o': 'परागकण दूसरी पौधे के पुष्प पर पहुंचते हैं।',
        'c': 'पर-परागण से आनुवंशिक विविधता आती है जिससे पौधे अधिक स्वस्थ बनते हैं।',
      },
    ],
    's3_steps': [
      {
        't': 'कदम 1: पराग नली का विकास',
        'i': "'पराग नली विकसित करें' बटन दबाएं और नली को अंडाशय तक बढ़ते देखें।",
        'o': 'पराग नली वर्तिका से होते हुए बीजांड तक नर युग्मक पहुंचाती है।',
        'c': 'पराग नली नर युग्मक को सुरक्षापूर्वक मादा अंड कोशिका तक ले जाती है।',
      },
      {
        't': 'कदम 2: युग्मक संलयन व युग्मनज',
        'i': 'बीजांड के अंदर नर और मादा युग्मकों का संलयन देखें।',
        'o': 'द्विगुणित युग्मनज (जाइगोट) बनता है।',
        'c': 'नर और मादा युग्मकों का संलयन निषेचन कहलाता है जिससे नया भ्रूण बनता है।',
      },
    ],
    's4_steps': [
      {
        't': 'कदम 1: पुष्प से फल बनने का क्रम व्यवस्थित करें',
        'i': 'चरण 1 से 5 को क्रम में लगाएं: परागण → पराग नली → निषेचन → युग्मनज → बीज व फल।',
        'o': 'क्रम पूर्ण। बीजांड बीज में और अंडाशय फल में रूपांतरित होता है।',
        'c': 'फल बीज की रक्षा करता है और बीजों के प्रकीर्णन में मदद करता है।',
      },
    ],
    's1_learn':
        'पुष्प के चार मुख्य भाग होते हैं: बाह्यदल, दल, पुंकेसर (तंतु + परागकोश), और स्त्रीकेसर (वर्तिकाग्र + वर्तिका + अंडाशय व बीजांड)।',
    's2_learn': 'परागण परागकणों का स्थानांतरण है; स्व-परागण एक ही पौधे में तथा पर-परागण दो अलग पौधों के बीच होता है।',
    's3_learn': 'निषेचन नर और मादा युग्मकों का संलयन है जिससे युग्मनज (जाइगोट) बनता है।',
    's4_learn': 'निषेचन के बाद बीजांड से बीज और अंडाशय से फल बनता है।',
    'pinHints': {
      'sepal': '<strong>संकेत:</strong> सबसे बाहरी हरा पत्ती जैसा भाग जो कली अवस्था में पुष्प की रक्षा करता है।',
      'petal': '<strong>संकेत:</strong> चमकीला रंगीन भाग जो परागण हेतु कीटों को आकर्षित करता है।',
      'anther': '<strong>संकेत:</strong> पुंकेसर का शीर्ष भाग जिसमें पीले परागकण बनते हैं।',
      'filament': '<strong>संकेत:</strong> पतला डंठल जो परागकोश को साधे रखता है।',
      'stigma': '<strong>संकेत:</strong> स्त्रीकेसर का चिपचिपा शीर्ष भाग जो परागकणों को ग्रहण करता है।',
      'style': '<strong>संकेत:</strong> लंबी नली जैसी संरचना जिससे होकर पराग नली नीचे जाती है।',
      'ovary': '<strong>संकेत:</strong> स्त्रीकेसर का फूला हुआ निचला भाग जो फल में बदलता है।',
      'ovule': '<strong>संकेत:</strong> अंडाशय के अंदर अंड कोशिका युक्त संरचना जो बीज में बदलती है।',
    },
    'concTitle': 'पादपों में जनन — वैज्ञानिक निष्कर्ष',
    'concHead1': '1. जनन अंग के रूप में पुष्प',
    'concBody1':
        'पुष्प आवृतबीजी पौधों का जनन अंग है। पुंकेसर नर अंग (परागकण उत्पादक) और स्त्रीकेसर मादा अंग (अंडाशय व बीजांड युक्त) होता है।',
    'concHead2': '2. परागण बनाम निषेचन',
    'concBody2':
        'परागण परागकणों का परागकोश से वर्तिकाग्र तक स्थानांतरण है, जबकि निषेचन नर और मादा युग्मकों का आंतरिक संलयन है।',
    'concHead3': '3. पुष्प से फल का निर्माण',
    'concBody3': 'निषेचन के बाद बीजांड सुरक्षात्मक बीज बन जाता है और अंडाशय पककर फल बन जाता है।',
    'toasts': {
      'selectPart': 'चयनित "{label}"। अब पुष्प पर किसी भी खाली पिन 01 से 08 पर टैप करें।',
      'placedPart': '{part} को पिन पर लगाया गया!',
      'selfDone': '🐝 परागकण उसी पुष्प के वर्तिकाग्र पर पहुँच गए! (स्व-परागण)',
      'crossDone': '🐝💨 परागकण उसी प्रकार के दूसरे पौधे से स्थानांतरित हुए! (पर-परागण)',
      'zygote': '✨ नर युग्मक बीजांड तक पहुँच गया! नर + मादा युग्मकों के संलयन से युग्मनज बना!',
      'selectCard': 'चयनित "{label}"। अब किसी भी अनुक्रम स्लॉट 1 से 5 पर टैप करें।',
      'selectFirst': 'पहले ऊपर से कोई अवस्था कार्ड चुनें!',
      'hint2': 'परागकोश से वर्तिकाग्र तक परागकणों का स्थानांतरण परागण है (स्व = एक ही पौधा; पर = अलग पौधा)।',
      'hint3':
          "'पराग नली विकसित करें' पर क्लिक करें और नर युग्मक को वर्तिका से होकर अंड कोशिका से संलयन हेतु जाते देखें।",
      'hint4': 'क्रम: परागण → पराग नली की वृद्धि → निषेचन → युग्मनज → बीजांड से बीज व अंडाशय से फल।',
      's1Ok': 'पुष्प की संरचना की सही पहचान हुई! परागण की ओर बढ़ रहे हैं...',
      's1Wrong': "{n} पिन गलत लेबल हैं या खाली हैं। मार्गदर्शन के लिए '?' संकेतों का उपयोग करें।",
      's2Ok': 'परागण की प्रक्रिया समझ ली गई! निषेचन की ओर बढ़ रहे हैं...',
      's2Wrong': 'आगे बढ़ने के लिए स्व-परागण और पर-परागण दोनों एनिमेशन पूरे करें।',
      's3Ok': 'निषेचन व युग्मनज सत्यापित! पुष्प से फल रूपांतरण की ओर बढ़ रहे हैं...',
      's3Wrong': "युग्मक संलयन द्वारा युग्मनज बनाने के लिए 'पराग नली विकसित करें' पर क्लिक करें।",
      's4Wrong':
          'कालानुक्रम गलत है। सुनिश्चित करें कि चरण इस क्रम में हों: परागण → पराग नली की वृद्धि → निषेचन → युग्मनज → बीज व फल।',
      'stepReset': 'वर्तमान चरण रीसेट किया गया।',
      'locked': 'कैनवास दृश्य लॉक (2D मोड)।',
      'unlocked': 'दृश्य अनलॉक। ज़ूम और पैन सक्षम।',
      'panOn': 'पैन मोड सक्रिय। कैनवास को खिसकाने के लिए खींचें।',
      'panOff': 'पैन मोड बंद।',
      'viewReset': 'दृश्य 100% पर रीसेट।',
    },
    'tools': {'lock': 'कैनवास ज़ूम और पैन लॉक/अनलॉक करें', 'pan': 'पैन मोड', 'labels': 'दृश्य लेबल दिखाएँ/छिपाएँ'},
  },
});

// --- Extra Tailwind shades used by the source page --------------------------
const _rose400 = Color(0xFFFB7185);
const _rose600 = Color(0xFFE11D48);
const _rose700 = Color(0xFFBE123C);
const _green800 = Color(0xFF166534);
const _green900 = Color(0xFF14532D);
const _yellow200 = Color(0xFFFEF08A);
const _yellow300 = Color(0xFFFDE047);
const _yellow600 = Color(0xFFCA8A04);
const _amber900 = Color(0xFF78350F);
const _cyan300 = Color(0xFF67E8F9);
const _emerald300 = Color(0xFF6EE7B7);
const _amber300 = Color(0xFFFCD34D);
const _purple300 = Color(0xFFD8B4FE);
const _purple400 = Color(0xFFC084FC);
const _orange200 = Color(0xFFFED7AA);
const _orange700 = Color(0xFFC2410C);
const _orange50Peach = Color(0xFFFFEDD5);
const _sky100 = Color(0xFFE0F2FE);

// --- Inline-SVG redraw helpers ----------------------------------------------

/// Parsed SVG path data, cached by its `d` string. Only the absolute
/// M / L / C / Q / Z commands used by the source drawings are supported.
final Map<String, Path> _svgCache = {};

Path _svg(String d) => _svgCache.putIfAbsent(d, () => _parseSvgPath(d));

Path _parseSvgPath(String d) {
  final path = Path();
  final tokens = RegExp(r'[MLCQZ]|-?\d*\.?\d+').allMatches(d).map((m) => m.group(0)!).toList();
  var i = 0;
  var cmd = 'M';
  double n() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    final tok = tokens[i];
    if (tok.length == 1 && 'MLCQZ'.contains(tok)) {
      cmd = tok;
      i++;
      if (cmd == 'Z') path.close();
      continue;
    }
    switch (cmd) {
      case 'M':
        path.moveTo(n(), n());
        cmd = 'L';
      case 'L':
        path.lineTo(n(), n());
      case 'C':
        path.cubicTo(n(), n(), n(), n(), n(), n());
      case 'Q':
        path.quadraticBezierTo(n(), n(), n(), n());
      default:
        i++;
    }
  }
  return path;
}

Paint _fillP(Color c) => Paint()..color = c;

Paint _strokeP(Color c, double w, {StrokeCap cap = StrokeCap.butt}) => Paint()
  ..color = c
  ..style = PaintingStyle.stroke
  ..strokeWidth = w
  ..strokeCap = cap
  ..strokeJoin = StrokeJoin.round;

Paint _gradP(Rect r, List<Color> colors, List<double> stops, Alignment begin, Alignment end) =>
    Paint()..shader = LinearGradient(colors: colors, stops: stops, begin: begin, end: end).createShader(r);

/// Draws [p] filled with [fill] and outlined with [stroke] (SVG fill + stroke).
void _fs(Canvas c, Path p, Paint? fill, [Paint? stroke]) {
  if (fill != null) c.drawPath(p, fill);
  if (stroke != null) c.drawPath(p, stroke);
}

/// Maps an SVG viewBox onto [size] (preserveAspectRatio "xMidYMid meet") and
/// returns the scale factor.
double _fitViewBox(Canvas canvas, Size size, Rect vb) {
  final s = math.min(size.width / vb.width, size.height / vb.height);
  canvas.translate((size.width - vb.width * s) / 2 - vb.left * s, (size.height - vb.height * s) / 2 - vb.top * s);
  canvas.scale(s);
  return s;
}

/// 0 -> 1 -> 0 eased loop over [period] seconds (CSS `ease-in-out` keyframes
/// with the peak at 50%).
double _wave(double t, double period) {
  final p = (t % period) / period;
  return Curves.easeInOut.transform(p < 0.5 ? p * 2 : (1 - p) * 2);
}

/// Soft coloured halo behind [p] (CSS `drop-shadow` glow).
void _glow(Canvas c, Path p, Color color, double radius) {
  c.drawPath(
    p,
    Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius / 2),
  );
}

/// `.animate-shimmer`: pulsing golden glow (2.4 s).
void _shimmer(Canvas c, Path p, double t) {
  final w = _wave(t, 2.4);
  _glow(c, p, _rt_Tw.yellow400.withValues(alpha: 0.4 + 0.5 * w), 3 + 7 * w);
}

/// Dash pattern along [src] (SVG `stroke-dasharray` + `stroke-dashoffset`).
Path _dashed(Path src, double dash, double gap, {double offset = 0}) {
  final out = Path();
  final period = dash + gap;
  for (final m in src.computeMetrics()) {
    var d = -(offset % period);
    while (d < m.length) {
      final s = math.max(d, 0.0);
      final e = math.min(d + dash, m.length);
      if (e > s) out.addPath(m.extractPath(s, e), Offset.zero);
      d += period;
    }
  }
  return out;
}

/// The first [frac] of [src] by length (animated `stroke-dashoffset` draw-in).
Path _partialPath(Path src, double frac) {
  final out = Path();
  final metrics = src.computeMetrics().toList();
  var remain = metrics.fold<double>(0, (a, m) => a + m.length) * frac;
  for (final m in metrics) {
    if (remain <= 0) break;
    out.addPath(m.extractPath(0, math.min(remain, m.length)), Offset.zero);
    remain -= m.length;
  }
  return out;
}

/// SVG `<text>` at baseline ([x], [baseline]); `text-anchor="end"` when
/// [alignEnd]. The font never drops below [minPx] on screen so the callouts
/// stay legible when the drawing is scaled down for a phone.
void _svgText(
  Canvas c,
  String text,
  double x,
  double baseline, {
  required Color color,
  required double size,
  required double scale,
  double minPx = 9,
  bool alignEnd = false,
  FontWeight weight = FontWeight.w900,
  double opacity = 1,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        color: color.withValues(alpha: opacity),
        fontSize: math.max(size, minPx / scale),
        fontWeight: weight,
      ),
    ),
    textDirection: TextDirection.ltr,
  )..layout();
  final ascent = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  tp.paint(c, Offset(alignEnd ? x - tp.width : x, baseline - ascent));
  tp.dispose();
}

void _dashedLine(Canvas c, Offset a, Offset b, Paint p, {double dash = 3, double gap = 3}) {
  c.drawPath(
    _dashed(
      Path()
        ..moveTo(a.dx, a.dy)
        ..lineTo(b.dx, b.dy),
      dash,
      gap,
    ),
    p,
  );
}

/// `.animate-bee-live` keyframes (2 s): translate + rotate offsets.
(double, double, double) _beeHover(double t) {
  const k = [(0.0, 0.0, 0.0, 0.0), (0.25, -4.0, -8.0, -4.0), (0.75, 5.0, -4.0, 3.0), (1.0, 0.0, 0.0, 0.0)];
  final p = (t % 2.0) / 2.0;
  for (var i = 0; i < k.length - 1; i++) {
    final a = k[i];
    final b = k[i + 1];
    if (p <= b.$1) {
      final f = Curves.easeInOut.transform((p - a.$1) / (b.$1 - a.$1));
      return (a.$2 + (b.$2 - a.$2) * f, a.$3 + (b.$3 - a.$3) * f, a.$4 + (b.$4 - a.$4) * f);
    }
  }
  return (0, 0, 0);
}

/// The bee `<g>` (local 34 x 30 units), placed at [at] with [scale].
void _drawBee(Canvas c, Offset at, double scale, double t) {
  final (dx, dy, rot) = _beeHover(t);
  c.save();
  c.translate(at.dx + dx, at.dy + dy);
  c.translate(20 * scale, 15 * scale);
  c.rotate(rot * math.pi / 180);
  c.translate(-20 * scale, -15 * scale);
  c.scale(scale);
  final body = Rect.fromCenter(center: const Offset(20, 15), width: 28, height: 20);
  c.drawOval(body, _fillP(_rt_Tw.amber400));
  c.drawOval(body, _strokeP(_amber900, 2));
  c.drawLine(const Offset(14, 5), const Offset(14, 25), _strokeP(Colors.black, 2.5));
  c.drawLine(const Offset(20, 5), const Offset(20, 25), _strokeP(Colors.black, 2.5));
  final wing = Rect.fromCenter(center: const Offset(16, 5), width: 16, height: 10);
  c.drawOval(wing, _fillP(_sky100));
  c.drawOval(wing, _strokeP(_rt_Tw.sky400, 1.5));
  c.drawCircle(const Offset(30, 12), 3, _fillP(Colors.black));
  c.restore();
}

void _drawPollenDot(Canvas c, Offset at) {
  c.drawCircle(at, 4, _fillP(_rt_Tw.yellow400));
  c.drawCircle(at, 4, _strokeP(_rt_Tw.amber600, 1));
}

// --- Scenario 1: botanical flower cross-section (viewBox 600 x 440) ---------
class _FlowerPainter extends CustomPainter {
  _FlowerPainter(this.clock) : super(repaint: clock);

  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    canvas.save();
    _fitViewBox(canvas, size, const Rect.fromLTWH(0, 0, 600, 440));
    // .animate-sway (5 s) around (300, 360).
    final sway = _wave(t, 5);
    canvas.translate(300, 360);
    canvas.rotate(0.8 * sway * math.pi / 180);
    canvas.scale(1 + 0.008 * sway);
    canvas.translate(-300, -360);

    // 1. Stem / pedicel and receptacle.
    final stem = _svg('M285 360 L285 420 C285 425 315 425 315 420 L315 360 Z');
    _fs(
      canvas,
      stem,
      _gradP(
        stem.getBounds(),
        const [_rt_Tw.green700, _green800],
        const [0, 1],
        Alignment.centerLeft,
        Alignment.centerRight,
      ),
      _strokeP(_green900, 2),
    );
    _fs(
      canvas,
      _svg('M250 350 C250 380 350 380 350 350 C370 330 330 310 300 310 C270 310 230 330 250 350 Z'),
      _fillP(_rt_Tw.green700),
      _strokeP(_green900, 2),
    );

    // 2. Sepals.
    for (final d in const [
      'M250 340 C190 350 160 380 130 395 C170 365 210 335 250 330 Z',
      'M350 340 C410 350 440 380 470 395 C430 365 390 335 350 330 Z',
    ]) {
      _fs(canvas, _svg(d), _fillP(_rt_Tw.green500), _strokeP(_rt_Tw.green700, 2));
    }

    // 3. Petals: back pair then the flaring front pair.
    for (final d in const [
      'M300 320 C240 180 170 120 120 160 C90 190 140 260 250 320 Z',
      'M300 320 C360 180 430 120 480 160 C510 190 460 260 350 320 Z',
    ]) {
      _fs(canvas, _svg(d), _fillP(_rt_Tw.rose500.withValues(alpha: 0.85)));
    }
    for (final d in const [
      'M280 330 C180 330 80 310 20 220 C60 180 140 210 270 320 Z',
      'M320 330 C420 330 520 310 580 220 C540 180 460 210 330 320 Z',
    ]) {
      final p = _svg(d);
      _fs(
        canvas,
        p,
        _gradP(
          p.getBounds(),
          const [_rose400, _rt_Tw.rose500, _rose600],
          const [0, 0.6, 1],
          Alignment.topLeft,
          Alignment.bottomRight,
        ),
        _strokeP(_rose700, 2.5),
      );
    }

    // 4. Stamens: filaments + anthers.
    const anthers = [(168.0, 175.0, -25.0), (218.0, 145.0, -10.0), (382.0, 145.0, 10.0), (432.0, 175.0, 25.0)];
    for (final d in const [
      'M270 320 C230 290 190 240 170 180',
      'M280 320 C250 260 230 200 220 150',
      'M320 320 C350 260 370 200 380 150',
      'M330 320 C370 290 410 240 430 180',
    ]) {
      canvas.drawPath(_svg(d), _strokeP(_yellow200, 4.5, cap: StrokeCap.round));
    }
    for (final (cx, cy, rot) in anthers) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(rot * math.pi / 180);
      final r = Rect.fromCenter(center: Offset.zero, width: 16, height: 28);
      final oval = Path()..addOval(r);
      _shimmer(canvas, oval, t);
      _fs(
        canvas,
        oval,
        _gradP(
          r,
          const [_yellow200, _rt_Tw.yellow400, _rt_Tw.amber600],
          const [0, 0.5, 1],
          Alignment.topLeft,
          Alignment.bottomRight,
        ),
        _strokeP(_rt_Tw.amber700, 2),
      );
      canvas.restore();
    }

    // 5. Carpel / pistil: ovary, ovule chamber, ovules, style, stigma.
    final ovary = _svg(
      'M260 330 C250 270 280 250 288 220 L312 220 C320 250 350 270 340 330 C330 350 270 350 260 330 Z',
    );
    Paint pistilGrad(Rect r) => _gradP(
      r,
      const [_rt_Tw.green500, _rt_Tw.green400, _rt_Tw.green600],
      const [0, 0.4, 1],
      Alignment.topCenter,
      Alignment.bottomCenter,
    );
    _fs(canvas, ovary, pistilGrad(ovary.getBounds()), _strokeP(_rt_Tw.green700, 2));
    final chamber = Rect.fromCenter(center: const Offset(300, 295), width: 52, height: 64);
    canvas.drawOval(chamber, _fillP(_rt_Tw.green100));
    canvas.drawOval(chamber, _strokeP(_rt_Tw.green600, 1.5));
    for (final o in const [Offset(292, 290), Offset(308, 290), Offset(292, 306), Offset(308, 306)]) {
      final p = Path()..addOval(Rect.fromCircle(center: o, radius: 7));
      _shimmer(canvas, p, t);
      _fs(canvas, p, _fillP(_yellow200), _strokeP(_yellow600, 1.5));
    }
    final style = _svg('M288 220 L288 150 L312 150 L312 220 Z');
    _fs(canvas, style, pistilGrad(style.getBounds()), _strokeP(_rt_Tw.green700, 1.5));
    final stigma = Rect.fromCenter(center: const Offset(300, 142), width: 36, height: 20);
    canvas.drawOval(stigma, _fillP(_rt_Tw.green700));
    canvas.drawOval(stigma, _strokeP(_green900, 2));
    canvas.drawCircle(const Offset(290, 138), 6, _fillP(_rt_Tw.green600));
    canvas.drawCircle(const Offset(310, 138), 6, _fillP(_rt_Tw.green600));
    canvas.drawCircle(const Offset(300, 134), 6, _fillP(_rt_Tw.green500));

    // Pointer guide lines.
    final guide = _strokeP(_rt_Tw.slate400, 1.5);
    for (final (a, b) in const [
      (Offset(300, 125), Offset(300, 70)), // stigma
      (Offset(432, 160), Offset(490, 120)), // anther
      (Offset(410, 240), Offset(490, 240)), // filament
      (Offset(288, 180), Offset(160, 180)), // style
      (Offset(120, 230), Offset(60, 230)), // petal
      (Offset(260, 300), Offset(160, 300)), // ovary
      (Offset(308, 290), Offset(440, 290)), // ovule
      (Offset(160, 380), Offset(100, 380)), // sepal
    ]) {
      _dashedLine(canvas, a, b, guide);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FlowerPainter old) => false;
}

// --- Scenario 2: pollination artwork -----------------------------------------
void _drawFlowerHead(Canvas c, {required bool self}) {
  // Shared petals/pistil of the small flowers (self: viewBox 280 x 180).
  if (self) {
    c.drawPath(_svg('M140 140 L140 175'), _strokeP(_rt_Tw.green700, 6, cap: StrokeCap.round));
    _fs(c, _svg('M115 140 C125 155 155 155 165 140 Z'), _fillP(_rt_Tw.green600));
    _fs(c, _svg('M140 135 C100 135 60 120 40 80 C60 65 95 80 135 130 Z'), _fillP(_rt_Tw.rose500));
    _fs(c, _svg('M140 135 C180 135 220 120 240 80 C220 65 185 80 145 130 Z'), _fillP(_rt_Tw.rose500));
    _fs(c, _svg('M140 135 C110 90 90 40 140 40 C190 40 170 90 140 135 Z'), _fillP(_rose400));
    return;
  }
  // Cross-pollination flower (local units, drawn inside a scaled group).
  c.drawPath(_svg('M80 140 L80 180'), _strokeP(_rt_Tw.green700, 6));
  _fs(c, _svg('M55 140 C65 155 95 155 105 140 Z'), _fillP(_rt_Tw.green600));
  _fs(c, _svg('M80 135 C40 135 10 120 -5 80 C15 65 45 80 75 130 Z'), _fillP(_rt_Tw.rose500));
  _fs(c, _svg('M80 135 C120 135 150 120 165 80 C145 65 115 80 85 130 Z'), _fillP(_rt_Tw.rose500));
  _fs(c, _svg('M80 135 C50 90 30 40 80 40 C130 40 110 90 80 135 Z'), _fillP(_rose400));
}

class _SelfPollinationPainter extends CustomPainter {
  _SelfPollinationPainter(this.clock, this.progress) : super(repaint: clock);

  final ValueNotifier<double> clock;
  final Animation<double> progress;

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    canvas.save();
    _fitViewBox(canvas, size, const Rect.fromLTWH(0, 0, 280, 180));
    _drawFlowerHead(canvas, self: true);
    // Stamens.
    canvas.drawPath(_svg('M130 130 Q110 80 100 65'), _strokeP(_yellow200, 3));
    canvas.drawPath(_svg('M150 130 Q170 80 180 65'), _strokeP(_yellow200, 3));
    for (final o in const [Offset(98, 62), Offset(182, 62)]) {
      final p = Path()..addOval(Rect.fromCircle(center: o, radius: 5));
      _shimmer(canvas, p, t);
      _fs(canvas, p, _fillP(_rt_Tw.yellow400), _strokeP(_rt_Tw.amber700, 1.5));
    }
    // Pistil + stigma.
    canvas.drawPath(_svg('M140 130 L140 55'), _strokeP(_rt_Tw.green500, 4));
    canvas.drawOval(Rect.fromCenter(center: const Offset(140, 52), width: 16, height: 10), _fillP(_rt_Tw.green700));
    // Bee.
    _drawBee(canvas, const Offset(105, 20), 0.75, t);
    // Curved pollen path (.animate-wind-flow).
    final flow = 60 * (1 - (t % 1.8) / 1.8);
    canvas.drawPath(_dashed(_svg('M100 60 C100 25 135 25 138 46'), 8, 8, offset: flow), _strokeP(_rt_Tw.sky400, 2.5));
    // Pollen grain: (100,60) -> (140,50), power2.out.
    final f = Curves.easeOutCubic.transform(progress.value);
    _drawPollenDot(canvas, Offset.lerp(const Offset(100, 60), const Offset(140, 50), f)!);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SelfPollinationPainter old) => old.progress != progress;
}

class _CrossPollinationPainter extends CustomPainter {
  _CrossPollinationPainter(this.clock, this.progress, this.label) : super(repaint: clock);

  final ValueNotifier<double> clock;
  final Animation<double> progress;
  final String label;

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    canvas.save();
    final s = _fitViewBox(canvas, size, const Rect.fromLTWH(0, 0, 340, 180));
    // Flower 1 (plant A) with a stamen.
    canvas.save();
    canvas.translate(10, 10);
    canvas.scale(0.85);
    _drawFlowerHead(canvas, self: false);
    canvas.drawPath(_svg('M90 130 Q110 80 120 65'), _strokeP(_yellow200, 3));
    final anther = Path()..addOval(Rect.fromCircle(center: const Offset(122, 62), radius: 5));
    _shimmer(canvas, anther, t);
    _fs(canvas, anther, _fillP(_rt_Tw.yellow400), _strokeP(_rt_Tw.amber700, 1.5));
    canvas.drawPath(_svg('M80 130 L80 55'), _strokeP(_rt_Tw.green500, 4));
    canvas.drawOval(Rect.fromCenter(center: const Offset(80, 52), width: 14, height: 8), _fillP(_rt_Tw.green700));
    canvas.restore();
    // Flower 2 (plant B, same kind).
    canvas.save();
    canvas.translate(180, 10);
    canvas.scale(0.85);
    _drawFlowerHead(canvas, self: false);
    canvas.drawPath(_svg('M80 130 L80 55'), _strokeP(_rt_Tw.green500, 4));
    canvas.drawOval(Rect.fromCenter(center: const Offset(80, 52), width: 14, height: 8), _fillP(_rt_Tw.green700));
    canvas.restore();
    // Bee flying between the flowers.
    _drawBee(canvas, const Offset(150, 15), 0.7, t);
    // Wind breeze stream.
    final flow = 60 * (1 - (t % 1.8) / 1.8);
    canvas.drawPath(_dashed(_svg('M120 90 C180 70 200 95 245 65'), 8, 8, offset: flow), _strokeP(_rt_Tw.cyan400, 2.5));
    _svgText(canvas, label, 180, 115, color: _rt_Tw.cyan400, size: 10, scale: s, minPx: 8.5, weight: FontWeight.bold);
    // Pollen particle: (115,65) -> (248,52), power1.inOut.
    final f = Curves.easeInOutQuad.transform(progress.value);
    _drawPollenDot(canvas, Offset.lerp(const Offset(115, 65), const Offset(248, 52), f)!);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CrossPollinationPainter old) => old.label != label || old.progress != progress;
}

// --- Scenario 3: pistil section with pollen tube (viewBox 500 x 520) --------
class _FertilisationPainter extends CustomPainter {
  _FertilisationPainter({
    required this.clock,
    required this.tube,
    required this.zygote,
    required this.labels,
    required this.showLabels,
  }) : super(repaint: clock);

  final ValueNotifier<double> clock;
  final Animation<double> tube;
  final bool zygote;
  final Map<String, String> labels;
  final bool showLabels;

  @override
  void paint(Canvas canvas, Size size) {
    final t = clock.value;
    canvas.save();
    final s = _fitViewBox(canvas, size, const Rect.fromLTRB(0, 30, 500, 492));

    // 1. Stigma knob.
    final knob = Rect.fromCenter(center: const Offset(250, 100), width: 72, height: 40);
    canvas.drawOval(knob, _fillP(_rt_Tw.green700));
    canvas.drawOval(knob, _strokeP(_green900, 3));
    canvas.drawCircle(const Offset(235, 95), 12, _fillP(_rt_Tw.green600));
    canvas.drawCircle(const Offset(265, 95), 12, _fillP(_rt_Tw.green600));
    canvas.drawCircle(const Offset(250, 90), 12, _fillP(_rt_Tw.green500));
    // 2. Style + ovary outline.
    _fs(
      canvas,
      _svg('M232 105 L232 300 C232 360 170 380 170 430 C170 480 330 480 330 430 C330 380 268 360 268 300 L268 105 Z'),
      _fillP(_rt_Tw.green400),
      _strokeP(_rt_Tw.green700, 4),
    );
    // 3. Ovary cavity, 4. ovule and egg cell.
    final cavity = Rect.fromCenter(center: const Offset(250, 420), width: 110, height: 120);
    canvas.drawOval(cavity, _fillP(_rt_Tw.green100));
    canvas.drawOval(cavity, _strokeP(_rt_Tw.green600, 2.5));
    final ovule = Rect.fromCenter(center: const Offset(250, 420), width: 68, height: 84);
    canvas.drawOval(ovule, _fillP(_orange50Peach));
    canvas.drawOval(ovule, _strokeP(_rt_Tw.orange600, 2));
    canvas.drawCircle(const Offset(250, 430), 12, _fillP(_orange200));
    canvas.drawCircle(const Offset(250, 430), 12, _strokeP(_orange700, 2));
    canvas.drawCircle(const Offset(250, 430), 5, _fillP(_rt_Tw.orange600));
    // 5. Spiky pollen grain on the stigma.
    canvas.save();
    canvas.translate(250, 60);
    canvas.drawCircle(Offset.zero, 18, _fillP(_rt_Tw.amber500));
    canvas.drawCircle(Offset.zero, 18, _strokeP(_rt_Tw.amber700, 2.5));
    final spike = _strokeP(_rt_Tw.amber700, 2.5);
    for (final (a, b) in const [
      (Offset(0, -18), Offset(0, -24)),
      (Offset(0, 18), Offset(0, 24)),
      (Offset(-18, 0), Offset(-24, 0)),
      (Offset(18, 0), Offset(24, 0)),
      (Offset(-13, -13), Offset(-18, -18)),
      (Offset(13, -13), Offset(18, -18)),
      (Offset(-13, 13), Offset(-18, 18)),
      (Offset(13, 13), Offset(18, 18)),
    ]) {
      canvas.drawLine(a, b, spike);
    }
    canvas.restore();
    // 6. Pollen tube growing down the style (2.2 s, power1.inOut).
    final grow = Curves.easeInOutQuad.transform(tube.value);
    if (grow > 0) {
      canvas.drawPath(
        _partialPath(_svg('M250 78 L250 330 C250 380 275 400 275 425 C275 450 255 455 250 442'), grow),
        _strokeP(_rt_Tw.yellow400, 8, cap: StrokeCap.round),
      );
    }
    // 7. Zygote starburst (.animate-starburst, 1.8 s around 250,442).
    if (zygote) {
      final w = _wave(t, 1.8);
      canvas.save();
      canvas.translate(250, 442);
      canvas.rotate(15 * w * math.pi / 180);
      canvas.scale(1 + 0.3 * w);
      canvas.translate(-250, -442);
      final star1 = _polygon(const [250, 400, 256, 435, 290, 442, 256, 449, 250, 484, 244, 449, 210, 442, 244, 435]);
      final star2 = _polygon(const [220, 412, 245, 438, 220, 472, 248, 446, 280, 472, 255, 438, 280, 412, 252, 438]);
      _glow(canvas, star1, Color.lerp(_rt_Tw.amber500, _yellow300, w)!, 15 + 20 * w);
      final a = 0.85 + 0.15 * w;
      canvas.drawCircle(const Offset(250, 442), 14, _fillP(_rt_Tw.amber400.withValues(alpha: a)));
      canvas.drawPath(star1, _fillP(_yellow200.withValues(alpha: a)));
      canvas.drawPath(star2, _fillP(_rt_Tw.amber500.withValues(alpha: 0.8 * a)));
      canvas.drawCircle(const Offset(250, 442), 8, _fillP(Colors.white.withValues(alpha: a)));
      canvas.restore();
    }
    // Callout labels (dimmed by the "labels" tool).
    final o = showLabels ? 1.0 : 0.15;
    void label(
      String text,
      double x,
      double y,
      Color color, {
      bool end = false,
      double fs = 13,
      FontWeight w = FontWeight.w900,
    }) => _svgText(
      canvas,
      text,
      x,
      y,
      color: color,
      size: fs,
      scale: s,
      minPx: fs < 13 ? 8.5 : 9.5,
      alignEnd: end,
      weight: w,
      opacity: o,
    );
    label('${labels['stigma']} —', 80, 105, _rt_Tw.green400, end: true);
    label('— ${labels['pollen']}', 310, 65, _rt_Tw.yellow400);
    label('${labels['style']} —', 140, 240, _rt_Tw.green400, end: true);
    label('— ${labels['tube']}', 310, 220, _rt_Tw.yellow400);
    label('${labels['ovary']} —', 100, 425, _rt_Tw.green500, end: true);
    label('— ${labels['ovule']}', 340, 390, _rt_Tw.orange400);
    label(labels['zygote']!, 330, 465, _yellow300);
    label(labels['fusion']!, 330, 482, _rt_Tw.amber400, fs: 11, w: FontWeight.bold);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FertilisationPainter old) =>
      old.zygote != zygote ||
      old.showLabels != showLabels ||
      old.tube != tube ||
      old.labels.toString() != labels.toString();
}

Path _polygon(List<double> pts) {
  final p = Path()..moveTo(pts[0], pts[1]);
  for (var i = 2; i < pts.length; i += 2) {
    p.lineTo(pts[i], pts[i + 1]);
  }
  return p..close();
}

// --- Scenario 4: before / after thumbnails ----------------------------------
class _PistilThumbPainter extends CustomPainter {
  _PistilThumbPainter(this.clock) : super(repaint: clock);

  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    _fitViewBox(canvas, size, const Rect.fromLTWH(0, 0, 80, 100));
    _fs(
      canvas,
      _svg('M36 20 L36 60 C36 80 20 85 20 95 C20 100 60 100 60 95 C60 85 44 80 44 60 L44 20 Z'),
      _fillP(_rt_Tw.green400),
      _strokeP(_rt_Tw.green700, 2),
    );
    canvas.drawCircle(const Offset(40, 18), 6, _fillP(_rt_Tw.green700));
    canvas.drawOval(Rect.fromCenter(center: const Offset(40, 82), width: 24, height: 28), _fillP(_rt_Tw.green100));
    final ovule = Path()..addOval(Rect.fromCircle(center: const Offset(40, 82), radius: 5));
    _shimmer(canvas, ovule, clock.value);
    _fs(canvas, ovule, _fillP(_yellow200), _strokeP(_rt_Tw.orange600, 1.5));
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _PistilThumbPainter old) => false;
}

class _FruitThumbPainter extends CustomPainter {
  _FruitThumbPainter(this.clock) : super(repaint: clock);

  final ValueNotifier<double> clock;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    _fitViewBox(canvas, size, const Rect.fromLTWH(0, 0, 100, 100));
    // .animate-fruit-glow (3 s).
    final w = _wave(clock.value, 3);
    final fruit = Path()..addOval(Rect.fromCircle(center: const Offset(50, 54), radius: 38));
    _glow(canvas, fruit, _rt_Tw.orange500.withValues(alpha: 0.4 + 0.4 * w), 5 + 15 * w);
    _fs(canvas, fruit, _fillP(_rt_Tw.orange500), _strokeP(_orange700, 3));
    _fs(canvas, _svg('M50 16 C50 6 62 8 68 4 C64 16 54 18 50 16 Z'), _fillP(_rt_Tw.green600));
    canvas.drawCircle(const Offset(50, 18), 4, _fillP(_amber900));
    canvas.save();
    canvas.translate(38, 40);
    canvas.rotate(-30 * math.pi / 180);
    canvas.drawOval(
      Rect.fromCenter(center: Offset.zero, width: 20, height: 12),
      _fillP(_rt_Tw.orange400.withValues(alpha: 0.6)),
    );
    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FruitThumbPainter old) => false;
}

/// Renders `<strong>` and `<br>` from the source strings as rich text.
List<InlineSpan> _richSpans(String html, TextStyle bold) {
  final spans = <InlineSpan>[];
  final re = RegExp(r'<strong>(.*?)</strong>|<br\s*/?>');
  var last = 0;
  for (final m in re.allMatches(html)) {
    if (m.start > last) spans.add(TextSpan(text: html.substring(last, m.start)));
    final strong = m.group(1);
    spans.add(strong != null ? TextSpan(text: strong, style: bold) : const TextSpan(text: '\n'));
    last = m.end;
  }
  if (last < html.length) spans.add(TextSpan(text: html.substring(last)));
  return spans;
}

/// Flower-anatomy pins in the order of their on-diagram numbers.
const _pinOrder = ['stigma', 'style', 'ovary', 'anther', 'filament', 'ovule', 'petal', 'sepal'];
const _pinNumbers = {
  'stigma': '01',
  'style': '02',
  'ovary': '03',
  'anther': '04',
  'filament': '05',
  'ovule': '06',
  'petal': '07',
  'sepal': '08',
};

/// Flower-to-fruit stage cards; the correct order is exactly this list.
const _stageKeys = ['c1', 'c2', 'c3', 'c4', 'c5'];

const _accent = _rt_Tw.emerald500;
const _accentDeep = _rt_Tw.emerald600;

class Cl9Ch13A3ReproductionInPlantsPage extends StatefulWidget {
  const Cl9Ch13A3ReproductionInPlantsPage({super.key});

  @override
  State<Cl9Ch13A3ReproductionInPlantsPage> createState() => _Cl9Ch13A3ReproductionInPlantsPageState();
}

class _Cl9Ch13A3ReproductionInPlantsPageState extends State<Cl9Ch13A3ReproductionInPlantsPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();

  /// Seconds since the page opened; drives the looping CSS animations
  /// (sway, shimmer, bee, wind flow, starburst, fruit glow).
  final ValueNotifier<double> _clock = ValueNotifier(0);
  late final Ticker _ticker;

  // GSAP tweens of the source page.
  late final AnimationController _selfAnim; // pollen-dot-self, 1.2 s
  late final AnimationController _crossAnim; // pollen-dot-cross, 1.5 s
  late final AnimationController _tubeAnim; // tube-path-anim, 2.2 s
  Timer? _advanceTimer;

  // --- Lab state (currentStep + s1State..s4State) ---
  int _step = 1;
  final Map<String, String?> _pins = {for (final k in _pinOrder) k: null};
  String? _selType; // 'flower_part' or 's4_chip' (selectedToken.type)
  String? _selId;
  bool _selfDone = false;
  bool _crossDone = false;
  bool _tubeGrown = false;
  bool _zygoteFormed = false;
  final List<String?> _order = List<String?>.filled(5, null);

  /// Scenarios verified since their last reset ("What we learn" box).
  final Set<int> _learned = {};

  // --- Canvas tools ---
  bool _showLabels = true;
  bool _locked = true;
  bool _panMode = false;
  double _zoom = 1;
  Offset _pan = Offset.zero;
  Offset _hudOffset = Offset.zero;
  Rect _hudBounds = Rect.zero;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _selfAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _crossAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    _tubeAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _ticker = createTicker((elapsed) => _clock.value = elapsed.inMicroseconds / 1e6)..start();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _advanceTimer?.cancel();
    _ticker.dispose();
    _selfAnim.dispose();
    _crossAnim.dispose();
    _tubeAnim.dispose();
    _clock.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ helpers ---
  bool get _dark => _rt_appTheme.isDark;
  Color _tone(Color dark, Color light) => _dark ? dark : light;
  Color get _glass => _dark ? const Color(0xEB0F172A) : const Color(0xFAFFFFFF);
  Color get _line => _dark ? _rt_Tw.slate700 : _rt_Tw.slate300;
  Color get _soft => _dark ? _rt_Tw.slate300 : _rt_Tw.slate700;
  Color get _faint => _dark ? _rt_Tw.slate400 : _rt_Tw.slate600;
  Color get _well => _dark ? const Color(0x990F172A) : Colors.white;

  String _part(String id) => _tx.s('parts.$id');
  String _msg(String key) => _tx.s('toasts.$key');
  String get _badge => '${_tx.s('step')} $_step/4';

  void _toast(String msg, {Color color = _accent, IconData icon = Icons.info}) =>
      _shell.showToast(msg, color: color, icon: icon);

  // -------------------------------------------------- scenario routing ---
  void _setStep(int n) {
    _advanceTimer?.cancel();
    setState(() {
      _step = n;
      _selType = null;
      _selId = null;
    });
  }

  // ------------------------------------------- scenario 1: anatomy pins ---
  void _selectPart(String id) {
    setState(() {
      _selType = 'flower_part';
      _selId = id;
    });
    _toast(_msg('selectPart').replaceAll('{label}', _part(id)));
  }

  /// A part can sit on one pin only: placing it again moves it.
  void _assignPin(String pinId, String partId) {
    _pins.updateAll((_, v) => v == partId ? null : v);
    _pins[pinId] = partId;
  }

  void _pinTap(String pinId) {
    final sel = _selId;
    if (_selType == 'flower_part' && sel != null) {
      _rt_playSfx(_rt_Sfx.pop);
      setState(() {
        _assignPin(pinId, sel);
        _selType = null;
        _selId = null;
      });
    } else {
      _showPinHint(pinId);
    }
  }

  void _dropPart(String partId, String pinId) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() => _assignPin(pinId, partId));
    _toast(_msg('placedPart').replaceAll('{part}', _part(partId)));
  }

  void _clearPin(String pinId) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _pins[pinId] = null);
  }

  Future<void> _showPinHint(String pinId) async {
    _rt_playSfx(_rt_Sfx.click);
    await _rt_showShellPopup(
      context,
      title: '${_tx.s('hint')} — ${_part(pinId)}',
      icon: Icons.info,
      color: _accent,
      buttonLabel: _tx.s('gotIt'),
      body: Text.rich(
        TextSpan(
          children: _richSpans(_tx.s('pinHints.$pinId'), TextStyle(fontWeight: FontWeight.w900, color: _rt_Lab.text)),
        ),
        style: TextStyle(fontSize: 13.5, color: _rt_Lab.textMuted, height: 1.45),
      ),
    );
    if (mounted) _rt_playSfx(_rt_Sfx.click);
  }

  // ------------------------------------------- scenario 2: pollination ---
  void _triggerPollen({required bool self}) {
    _rt_playSfx(_rt_Sfx.pop);
    final ctrl = self ? _selfAnim : _crossAnim;
    // A stopped/reset controller never completes this future.
    ctrl.forward(from: 0).then((_) {
      if (!mounted) return;
      _rt_playSfx(_rt_Sfx.correct);
      setState(() {
        if (self) {
          _selfDone = true;
        } else {
          _crossDone = true;
        }
      });
      _toast(_msg(self ? 'selfDone' : 'crossDone'));
    });
  }

  // ----------------------------------------- scenario 3: fertilisation ---
  void _growTube() {
    if (_tubeAnim.isAnimating) return;
    _rt_playSfx(_rt_Sfx.pop);
    _tubeAnim.forward(from: 0).then((_) {
      if (!mounted) return;
      _rt_playSfx(_rt_Sfx.correct);
      setState(() {
        _tubeGrown = true;
        _zygoteFormed = true;
      });
      _toast(_msg('zygote'), icon: Icons.auto_awesome);
    });
  }

  // ------------------------------------------ scenario 4: flower→fruit ---
  void _selectCard(String id) {
    setState(() {
      _selType = 's4_chip';
      _selId = id;
    });
    _toast(_msg('selectCard').replaceAll('{label}', _tx.s('s4_cards.$id')));
  }

  void _slotTap(int i) {
    final sel = _selId;
    if (_selType != 's4_chip' || sel == null) {
      _toast(_msg('selectFirst'), color: _rt_Tw.amber500, icon: Icons.touch_app);
      return;
    }
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _order[i] = sel;
      _selType = null;
      _selId = null;
    });
  }

  void _dropCard(String id, int i) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() => _order[i] = id);
  }

  void _clearSlot(int i) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _order[i] = null);
  }

  // ------------------------------------------------ hint / verify / reset ---
  void _showStepHint() {
    switch (_step) {
      case 1:
        _showPinHint('stigma');
      case 2:
        _toast(_msg('hint2'), color: _rt_Tw.amber500, icon: Icons.lightbulb);
      case 3:
        _toast(_msg('hint3'), color: _rt_Tw.amber500, icon: Icons.lightbulb);
      default:
        _toast(_msg('hint4'), color: _rt_Tw.amber500, icon: Icons.lightbulb);
    }
  }

  void _validate() {
    _rt_playSfx(_rt_Sfx.click);
    switch (_step) {
      case 1:
        final wrong = _pinOrder.where((k) => _pins[k] != k).length;
        if (wrong == 0) {
          _passStep('s1Ok');
        } else {
          _failStep(_msg('s1Wrong').replaceAll('{n}', '$wrong'));
        }
      case 2:
        if (_selfDone && _crossDone) {
          _passStep('s2Ok');
        } else {
          _failStep(_msg('s2Wrong'));
        }
      case 3:
        if (_tubeGrown && _zygoteFormed) {
          _passStep('s3Ok');
        } else {
          _failStep(_msg('s3Wrong'));
        }
      default:
        var seqOk = true;
        for (var i = 0; i < _stageKeys.length; i++) {
          if (_order[i] != _stageKeys[i]) seqOk = false;
        }
        if (seqOk) {
          setState(() => _learned.add(4));
          _showConclusion();
        } else {
          _failStep(_msg('s4Wrong'));
        }
    }
  }

  /// Correct: reveal "What we learn" and advance after 1.4 s.
  void _passStep(String key) {
    _rt_playSfx(_rt_Sfx.correct);
    final next = _step + 1;
    setState(() => _learned.add(_step));
    _toast(_msg(key), color: _rt_Tw.green500, icon: Icons.check_circle);
    _advanceTimer?.cancel();
    _advanceTimer = Timer(const Duration(milliseconds: 1400), () {
      if (mounted) _setStep(next);
    });
  }

  void _failStep(String text) {
    _rt_playSfx(_rt_Sfx.wrong);
    _toast(text, color: _rt_Tw.red500, icon: Icons.cancel);
  }

  void _resetStep() {
    _rt_playSfx(_rt_Sfx.click);
    _advanceTimer?.cancel();
    setState(() {
      _selType = null;
      _selId = null;
      _learned.remove(_step);
      switch (_step) {
        case 1:
          _pins.updateAll((_, _) => null);
        case 2:
          _selfAnim.reset();
          _crossAnim.reset();
          _selfDone = false;
          _crossDone = false;
        case 3:
          _tubeAnim.reset();
          _tubeGrown = false;
          _zygoteFormed = false;
        default:
          _order.fillRange(0, _order.length, null);
      }
    });
    _toast(_msg('stepReset'), color: _rt_Tw.slate500, icon: Icons.restart_alt);
  }

  /// resetLab(): every scenario back to its start, view re-locked at 100%.
  void _restart() {
    _advanceTimer?.cancel();
    _selfAnim.reset();
    _crossAnim.reset();
    _tubeAnim.reset();
    final wasUnlocked = !_locked;
    setState(() {
      _pins.updateAll((_, _) => null);
      _selfDone = false;
      _crossDone = false;
      _tubeGrown = false;
      _zygoteFormed = false;
      _order.fillRange(0, _order.length, null);
      _learned.clear();
      _selType = null;
      _selId = null;
      _zoom = 1;
      _pan = Offset.zero;
      _locked = true;
      _panMode = false;
      _step = 1;
    });
    if (wasUnlocked) _toast(_msg('locked'), icon: Icons.lock);
  }

  Future<void> _showConclusion() async {
    Widget section(IconData icon, Color color, String head, String body) => Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(Color.lerp(color, Colors.white, 0.9)!, color),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.tintedBorder(color)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  head,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.onTinted(color, Color.lerp(color, Colors.black, 0.35)!),
                  ),
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
      color: _accent,
      buttonLabel: _tx.s('btnReplay'),
      body: Column(
        children: [
          section(Icons.local_florist, _rt_Tw.emerald500, _tx.s('concHead1'), _tx.s('concBody1')),
          section(Icons.air, _rt_Tw.cyan500, _tx.s('concHead2'), _tx.s('concBody2')),
          section(Icons.park, _rt_Tw.amber500, _tx.s('concHead3'), _tx.s('concBody3')),
        ],
      ),
      onConfirm: () {
        if (mounted) _restart(); // a tap outside just closes the popup
      },
    );
  }

  // ------------------------------------------------------- canvas tools ---
  void _toggleLock() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _locked = !_locked;
      if (_locked) _panMode = false;
    });
    _toast(_msg(_locked ? 'locked' : 'unlocked'), icon: _locked ? Icons.lock : Icons.lock_open);
  }

  void _togglePan() {
    if (_locked) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _panMode = !_panMode);
    _toast(_msg(_panMode ? 'panOn' : 'panOff'), icon: Icons.pan_tool);
  }

  void _zoomBy(int dir) {
    if (_locked) return;
    setState(() => _zoom = dir > 0 ? math.min(_zoom + 0.15, 1.8) : math.max(_zoom - 0.15, 0.65));
  }

  void _resetView() {
    if (_locked) return;
    setState(() {
      _zoom = 1;
      _pan = Offset.zero;
    });
    _toast(_msg('viewReset'), icon: Icons.center_focus_strong);
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _showLabels = !_showLabels);
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
              icon: Icons.local_florist,
              buttonIcon: Icons.rocket_launch,
            ),
            onRestart: _restart,
            // Zoom / reset stay disabled until the view is unlocked.
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
              const SizedBox(height: 4),
              _toolButton(
                icon: _showLabels ? Icons.label : Icons.label_off,
                tip: _tx.s('tools.labels'),
                active: _showLabels,
                onTap: _toggleLabels,
              ),
              if (!_locked) ...[
                const SizedBox(height: 4),
                _toolButton(icon: Icons.pan_tool, tip: _tx.s('tools.pan'), active: _panMode, onTap: _togglePan),
              ],
            ],
            sidebarTop: _sidebarTop(),
            tabs: [
              _rt_ShellTab(label: _tx.s('detailedSteps'), icon: Icons.local_florist, builder: (_) => _sidebarBody()),
            ],
            canvasBackground: _rt_Lab.canvas,
            canvas: _stage(),
            canvasOverlays: [Positioned.fill(child: _canvasChrome())],
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
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? _accentDeep : _rt_Lab.surface,
            shape: BoxShape.circle,
            boxShadow: active ? [BoxShadow(color: _accent.withValues(alpha: 0.4), blurRadius: 6)] : null,
          ),
          child: Icon(icon, size: 18, color: active ? Colors.white : _rt_Lab.textMuted),
        ),
      ),
    );
  }

  // ----------------------------------------------------------- sidebar ---
  Widget _sidebarTop() {
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
                  color: _accent.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.school, size: 14, color: _tone(_rt_Tw.emerald400, _rt_Tw.emerald700)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _tx.s('labProgress').toUpperCase(),
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1, color: _rt_Lab.text),
                ),
              ),
              _badgeChip(_badge),
            ],
          ),
          const SizedBox(height: 10),
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
                iconEnabledColor: _accent,
                borderRadius: BorderRadius.circular(12),
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: _rt_Lab.text),
                items: [
                  for (var i = 1; i <= 4; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(_tx.s('scenario${i}_opt'), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) {
                  if (v == null || v == _step) return;
                  _rt_playSfx(_rt_Sfx.click);
                  _setStep(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _badgeChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: _accent.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 10,
          fontWeight: FontWeight.w900,
          color: _tone(_rt_Tw.emerald400, _rt_Tw.emerald700),
        ),
      ),
    );
  }

  Widget _sidebarBody() {
    final steps = _tx.list('s${_step}_steps');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('missionObj'),
          desc: _tx.s('s${_step}_obj'),
          accent: _accentDeep,
          icon: Icons.gps_fixed,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(_tx.s('detailedSteps'), icon: Icons.format_list_numbered, color: _accentDeep),
              for (var i = 0; i < steps.length; i++) _detailCard(i + 1, (steps[i] as Map).cast<String, dynamic>()),
              if (_learned.contains(_step))
                _rt_InfoCard(
                  title: _tx.s('what_we_learn'),
                  body: _tx.s('s${_step}_learn'),
                  icon: Icons.lightbulb,
                  color: _accentDeep,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _detailCard(int n, Map<String, dynamic> step) {
    Widget para(String label, String body, Color color) => Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label ',
              style: TextStyle(fontWeight: FontWeight.w800, color: color),
            ),
            TextSpan(text: body),
          ],
        ),
        style: TextStyle(fontSize: 12, color: _rt_Lab.textMuted, height: 1.45),
      ),
    );
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: _accent.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Text(
                  '$n',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _tone(_rt_Tw.emerald400, _rt_Tw.emerald700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  step['t'] as String,
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: _rt_Lab.text, height: 1.3),
                ),
              ),
            ],
          ),
          Container(height: 1, margin: const EdgeInsets.only(top: 8, bottom: 2), color: _rt_Lab.border),
          para(_tx.s('taskInstr'), step['i'] as String, _tone(_rt_Tw.emerald400, _rt_Tw.emerald700)),
          para(_tx.s('expOut'), step['o'] as String, _tone(_rt_Tw.cyan400, _rt_Tw.cyan600)),
          para(_tx.s('conceptLearned'), step['c'] as String, _tone(_rt_Tw.amber400, _rt_Tw.amber700)),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ canvas ---
  /// The zoom / pan "stage-transform-container" holding the active scenario.
  Widget _stage() {
    final panActive = !_locked && _panMode;
    final view = switch (_step) {
      1 => _s1View(),
      2 => _s2View(),
      3 => _s3View(),
      _ => _s4View(),
    };
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onPanUpdate: panActive ? (d) => setState(() => _pan += d.delta) : null,
      child: ColoredBox(
        color: _rt_Lab.canvas,
        child: Transform.translate(
          offset: _pan,
          child: AnimatedScale(
            scale: _zoom,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: IgnorePointer(
              ignoring: panActive,
              // Room for the HUD (top), action bar (bottom) and toolbar (right).
              child: Padding(padding: const EdgeInsets.fromLTRB(10, 54, 62, 50), child: view),
            ),
          ),
        ),
      ),
    );
  }

  /// Lays [builder] out at no less than [minW] x [minH] and scales it down
  /// to fit, so a narrow canvas (sidebar open) never overflows.
  Widget _fitStage({required double minW, required double minH, required Widget Function(double w, double h) builder}) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 40 || c.maxHeight < 40 || !c.maxWidth.isFinite || !c.maxHeight.isFinite) {
          return const SizedBox.shrink();
        }
        final scale = math.min(1.0, math.min(c.maxWidth / minW, c.maxHeight / minH));
        final w = c.maxWidth / scale;
        final h = c.maxHeight / scale;
        final child = SizedBox(width: w, height: h, child: builder(w, h));
        return scale >= 1 ? child : FittedBox(fit: BoxFit.fill, child: child);
      },
    );
  }

  /// HUD (top, draggable) + Hint / Reset / Verify bar (bottom).
  Widget _canvasChrome() {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 220 || c.maxHeight < 120) return const SizedBox.shrink();
        // With the sidebar closed the shell's menu button floats over the
        // canvas' top-left corner; the back button always sits top-right.
        final menuOver = c.maxWidth >= MediaQuery.sizeOf(context).width - 4;
        final left = menuOver ? 74.0 : 12.0;
        final maxW = math.max(140.0, c.maxWidth - left - 74);
        _hudBounds = Rect.fromLTRB(
          -left + 4,
          -8,
          math.max(-left + 4, c.maxWidth - left - 150),
          math.max(-8, c.maxHeight - 110),
        );
        final dx = _hudOffset.dx.clamp(_hudBounds.left, _hudBounds.right);
        final dy = _hudOffset.dy.clamp(_hudBounds.top, _hudBounds.bottom);
        return Stack(
          children: [
            Positioned(
              left: left + dx,
              top: 12 + dy,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: _hud(),
              ),
            ),
            Positioned(
              left: 8,
              right: 62,
              bottom: 8,
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(fit: BoxFit.scaleDown, child: _actionBar()),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _hud() {
    return GestureDetector(
      onPanUpdate: (d) => setState(() {
        final o = _hudOffset + d.delta;
        _hudOffset = Offset(
          o.dx.clamp(_hudBounds.left, _hudBounds.right),
          o.dy.clamp(_hudBounds.top, _hudBounds.bottom),
        );
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _glass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _line),
          boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 14)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.drag_indicator, size: 14, color: _rt_Tw.slate400),
            const SizedBox(width: 4),
            Icon(Icons.navigation, size: 13, color: _tone(_rt_Tw.emerald400, _rt_Tw.emerald600)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _tx.s('hud_s$_step'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: _rt_Lab.text),
              ),
            ),
            const SizedBox(width: 8),
            _badgeChip(_badge),
          ],
        ),
      ),
    );
  }

  Widget _actionBar() {
    Widget glassButton(IconData icon, String label, Color color, VoidCallback onTap) => Material(
      color: _glass,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _line),
      ),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: color),
              ),
            ],
          ),
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        glassButton(Icons.lightbulb, _tx.s('hint'), _tone(_rt_Tw.amber400, _rt_Tw.amber600), _showStepHint),
        const SizedBox(width: 8),
        glassButton(Icons.restart_alt, _tx.s('resetStep'), _soft, _resetStep),
        const SizedBox(width: 8),
        Material(
          color: _accent,
          borderRadius: BorderRadius.circular(12),
          elevation: 4,
          shadowColor: _accent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: _validate,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                      letterSpacing: 0.8,
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

  /// Filled pill button (the scenario action buttons).
  Widget _pill({required String label, required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15, color: _rt_Tw.slate950),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: _rt_Tw.slate950,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Token / stage-card chip (`.token`, `.selected`, `.is-placed`).
  Widget _chip({
    required String label,
    required IconData icon,
    required Color iconColor,
    bool placed = false,
    bool selected = false,
    bool stageCard = false,
    double fontSize = 10.5,
  }) {
    final bg = stageCard && _dark
        ? Color.alphaBlend(_rt_Tw.amber500.withValues(alpha: 0.1), _rt_Tw.slate900)
        : _tone(_rt_Tw.slate900, Colors.white);
    final border = selected
        ? _accent
        : stageCard && _dark
        ? _rt_Tw.amber500.withValues(alpha: 0.4)
        : _tone(_rt_Tw.slate700, _rt_Tw.slate400);
    final fg = stageCard && _dark ? _rt_Tw.amber200 : _rt_Lab.text;
    return Opacity(
      opacity: placed ? 0.35 : 1,
      child: AnimatedScale(
        scale: selected ? 1.06 : 1,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: border, width: selected ? 2 : 1),
            boxShadow: [
              selected
                  ? BoxShadow(color: _accent.withValues(alpha: 0.6), blurRadius: 12)
                  : BoxShadow(color: _rt_Lab.shadow, blurRadius: 4),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 12, color: iconColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w800, color: fg, height: 1.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Drag clone: centred on the finger, tilted and lifted (`.is-dragging`).
  Widget _dragFeedback(Widget chip) {
    return Material(
      type: MaterialType.transparency,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5),
        child: Transform.rotate(
          angle: 2 * math.pi / 180,
          child: Transform.scale(
            scale: 1.1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24, offset: const Offset(0, 12)),
                ],
              ),
              child: chip,
            ),
          ),
        ),
      ),
    );
  }

  Widget _miniIcon(IconData icon, Color color, VoidCallback onTap, {Color? bg}) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, size: 12, color: color),
      ),
    );
  }

  // ----------------------------------------- scenario 1: flower anatomy ---
  Widget _s1View() => _fitStage(
    minW: 540,
    minH: 250,
    builder: (w, h) => Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: _flowerStage()),
        const SizedBox(width: 8),
        SizedBox(width: 180, child: _s1Palette()),
      ],
    ),
  );

  /// Flower cross-section with the eight numbered pins laid over it at the
  /// source page's percentage positions.
  Widget _flowerStage() {
    return LayoutBuilder(
      builder: (context, c) {
        final bw = c.maxWidth;
        final bh = c.maxHeight;
        Widget at(String id, double top, {double? left, double? right}) => Positioned(
          top: top * bh,
          left: left == null ? null : left * bw,
          right: right == null ? null : right * bw,
          child: _pin(id),
        );
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: RepaintBoundary(child: CustomPaint(painter: _FlowerPainter(_clock))),
            ),
            Positioned(
              top: 0.02 * bh,
              left: 0,
              right: 0,
              child: Center(child: _pin('stigma')),
            ),
            at('style', 0.36, left: 0.14),
            at('ovary', 0.64, left: 0.14),
            at('anther', 0.18, right: 0.04),
            at('filament', 0.50, right: 0.04),
            at('ovule', 0.64, right: 0.16),
            at('petal', 0.48, left: 0),
            at('sepal', 0.84, left: 0.04),
          ],
        );
      },
    );
  }

  Widget _pin(String id) {
    final num = _pinNumbers[id]!;
    final assigned = _pins[id];
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => d.data.startsWith('part:'),
      onAcceptWithDetails: (d) => _dropPart(d.data.substring(5), id),
      builder: (context, candidates, _) {
        final over = candidates.isNotEmpty;
        final filled = assigned != null;
        final border = over || filled ? (over ? _accent : _rt_Tw.emerald400) : _tone(_rt_Tw.slate700, _rt_Tw.slate400);
        final bg = over
            ? Color.alphaBlend(_accent.withValues(alpha: 0.25), _glass)
            : filled
            ? Color.alphaBlend(_accent.withValues(alpha: 0.2), _glass)
            : _tone(const Color(0xE60F172A), _rt_Tw.slate50);
        return GestureDetector(
          onTap: () => _pinTap(id),
          child: AnimatedScale(
            scale: over ? 1.04 : 1,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.fromLTRB(5, 4, 4, 4),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border, width: 2),
                boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: filled ? _rt_Tw.emerald400 : _accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      num,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: filled ? _rt_Tw.slate950 : _tone(_rt_Tw.emerald400, _rt_Tw.emerald700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 5),
                  if (filled)
                    Text(
                      _part(assigned).toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: _tone(_emerald300, _rt_Tw.emerald700),
                      ),
                    )
                  else
                    Opacity(
                      opacity: _showLabels ? 1 : 0.15,
                      child: Text(
                        '[ ${_tx.s('pinPrefix')} $num ]',
                        style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: _soft),
                      ),
                    ),
                  const SizedBox(width: 3),
                  if (filled)
                    _miniIcon(Icons.close, _rt_Tw.slate400, () => _clearPin(id))
                  else
                    _miniIcon(
                      Icons.question_mark,
                      _tone(_amber300, _rt_Tw.amber700),
                      () => _showPinHint(id),
                      bg: _rt_Tw.amber500.withValues(alpha: 0.2),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Hierarchical token palette: Stamen, Pistil/Carpel and the accessory whorls.
  Widget _s1Palette() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _tokenGroup(_tx.s('stamenGroup'), _rt_Tw.amber500, const ['anther', 'filament']),
          const SizedBox(height: 6),
          _tokenGroup(_tx.s('pistilGroup'), _rt_Tw.emerald500, const ['stigma', 'style', 'ovary', 'ovule']),
          const SizedBox(height: 6),
          _tokenGroup(_tx.s('outerGroup'), _rt_Tw.rose500, const ['sepal', 'petal']),
        ],
      ),
    );
  }

  Widget _tokenGroup(String title, Color color, List<String> ids) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(Color.lerp(color, Colors.white, 0.9)!, color.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w900,
                    color: _rt_Lab.onTinted(color, Color.lerp(color, Colors.black, 0.35)!),
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.account_tree, size: 12, color: color),
            ],
          ),
          const SizedBox(height: 5),
          Wrap(spacing: 4, runSpacing: 4, children: [for (final id in ids) _partToken(id)]),
        ],
      ),
    );
  }

  Widget _partToken(String id) {
    final label = _part(id);
    final chip = _chip(
      label: label,
      icon: Icons.label,
      iconColor: _rt_Tw.emerald400,
      placed: _pins.containsValue(id),
      selected: _selType == 'flower_part' && _selId == id,
    );
    return Draggable<String>(
      data: 'part:$id',
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _dragFeedback(_chip(label: label, icon: Icons.label, iconColor: _rt_Tw.emerald400)),
      childWhenDragging: Opacity(opacity: 0.4, child: chip),
      child: GestureDetector(onTap: () => _selectPart(id), child: chip),
    );
  }

  // -------------------------------------------- scenario 2: pollination ---
  Widget _s2View() => _fitStage(
    minW: 540,
    minH: 250,
    builder: (w, h) => Align(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: _pollinationPanel(self: true)),
            const SizedBox(width: 10),
            Expanded(child: _pollinationPanel(self: false)),
          ],
        ),
      ),
    ),
  );

  Widget _pollinationPanel({required bool self}) {
    final accent = self ? _rt_Tw.cyan500 : _rt_Tw.emerald500;
    final titleColor = self ? _tone(_cyan300, _rt_Tw.cyan600) : _tone(_emerald300, _rt_Tw.emerald700);
    final done = self ? _selfDone : _crossDone;
    final bold = TextStyle(fontWeight: FontWeight.w900, color: _rt_Lab.text);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 2),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 16)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: accent.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Text(
                  self ? '①' : '②',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: titleColor),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _tx.s(self ? 'selfPollTitle' : 'crossPollTitle'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w900, color: titleColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(children: _richSpans(_tx.s(self ? 'selfPollDesc' : 'crossPollDesc'), bold)),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.5, color: _soft, height: 1.35, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: _well,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: accent.withValues(alpha: 0.2)),
              ),
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: self
                      ? _SelfPollinationPainter(_clock, _selfAnim)
                      : _CrossPollinationPainter(_clock, _crossAnim, _tx.s('windBeeLabel')),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _pill(
                  label: _tx.s(self ? 'btnSelfPoll' : 'btnCrossPoll'),
                  icon: Icons.play_arrow,
                  color: accent,
                  onTap: () => _triggerPollen(self: self),
                ),
              ),
              const SizedBox(width: 6),
              _statusChip(done, accent, self ? _rt_Tw.cyan400 : _rt_Tw.emerald400),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusChip(bool done, Color accent, Color doneText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: done ? _rt_Lab.tinted(Color.lerp(accent, Colors.white, 0.88)!, accent) : _well,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: done ? accent.withValues(alpha: 0.5) : _line),
      ),
      child: Text(
        _tx.s(done ? 'completed' : 'pending'),
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: done ? _tone(doneText, Color.lerp(accent, Colors.black, 0.3)!) : _faint,
        ),
      ),
    );
  }

  // ------------------------------------------ scenario 3: fertilisation ---
  Widget _s3View() => _fitStage(
    minW: 420,
    minH: 250,
    builder: (w, h) => Align(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _FertilisationPainter(
                    clock: _clock,
                    tube: _tubeAnim,
                    zygote: _zygoteFormed,
                    showLabels: _showLabels,
                    labels: {
                      'stigma': _tx.s('s3_svg_stigma'),
                      'pollen': _tx.s('s3_svg_pollen'),
                      'style': _tx.s('s3_svg_style'),
                      'tube': _tx.s('s3_svg_tube'),
                      'ovary': _tx.s('s3_svg_ovary'),
                      'ovule': _tx.s('s3_svg_ovule'),
                      'zygote': _tx.s('s3_svg_zygote'),
                      'fusion': _tx.s('s3_svg_fusion'),
                    },
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(width: 196, child: Center(child: _s3ActionCard())),
          ],
        ),
      ),
    ),
  );

  Widget _s3ActionCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _rt_Tw.purple500.withValues(alpha: 0.4)),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 16)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _tx.s('s3TubeTitle'),
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _tone(_purple300, _rt_Tw.purple600)),
          ),
          const SizedBox(height: 4),
          Text(
            _tx.s('s3TubeSub'),
            style: TextStyle(fontSize: 10.5, color: _soft, height: 1.35, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 10),
          _pill(label: _tx.s('btnGrowTube'), icon: Icons.play_arrow, color: _purple400, onTap: _growTube),
        ],
      ),
    );
  }

  // ------------------------------------------- scenario 4: flower→fruit ---
  Widget _s4View() => _fitStage(
    // Taller than the canvas on a 360 px phone so the stage-card palette
    // keeps room for three rows of cards.
    minW: 560,
    minH: 290,
    builder: (w, h) => Align(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _storyboard(),
            const SizedBox(height: 5),
            _beforeAfter(),
            const SizedBox(height: 6),
            Expanded(child: _sequenceBox()),
          ],
        ),
      ),
    ),
  );

  Widget _pulse(Widget child) => ValueListenableBuilder<double>(
    valueListenable: _clock,
    builder: (_, t, c) => Opacity(opacity: 1 - 0.5 * _wave(t, 2), child: c),
    child: child,
  );

  /// Pollination ➔ Fertilisation ➔ Zygote storyboard.
  Widget _storyboard() {
    Widget card(IconData icon, Color iconColor, Color accent, String titleKey, String descKey, {bool pulse = false}) {
      final iconWidget = Icon(icon, size: 20, color: iconColor);
      return Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: _glass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _rt_Lab.tinted(Color.lerp(accent, Colors.white, 0.9)!, accent.withValues(alpha: 0.5)),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: accent.withValues(alpha: 0.3)),
                ),
                child: pulse ? _pulse(iconWidget) : iconWidget,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tx.s(titleKey).toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: _rt_Lab.onTinted(accent, Color.lerp(accent, Colors.black, 0.3)!),
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _tx.s(descKey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 9, color: _faint, height: 1.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        card(Icons.local_florist, _rose400, _rt_Tw.cyan500, 's4_sb1_t', 's4_sb1_d'),
        const SizedBox(width: 6),
        card(Icons.call_split, _purple400, _rt_Tw.purple500, 's4_sb2_t', 's4_sb2_d'),
        const SizedBox(width: 6),
        card(Icons.auto_awesome, _rt_Tw.amber400, _rt_Tw.amber500, 's4_sb3_t', 's4_sb3_d', pulse: true),
      ],
    );
  }

  /// BEFORE (pistil with ovule) ➔ AFTER (ripe fruit) banner.
  Widget _beforeAfter() {
    Widget side(Widget thumb, String titleKey, String descKey, Color color) => Expanded(
      child: Row(
        children: [
          thumb,
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tx.s(titleKey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: color),
                ),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(children: _richSpans(_tx.s(descKey), const TextStyle(fontWeight: FontWeight.w900))),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: _soft, height: 1.25),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Tw.amber500.withValues(alpha: 0.4), width: 2),
      ),
      child: Row(
        children: [
          side(
            Container(
              width: 36,
              height: 44,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _well,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _rt_Tw.emerald500.withValues(alpha: 0.3)),
              ),
              child: RepaintBoundary(child: CustomPaint(painter: _PistilThumbPainter(_clock))),
            ),
            's4_before_t',
            's4_before_d',
            _tone(_rt_Tw.emerald400, _rt_Tw.emerald700),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: _pulse(Icon(Icons.arrow_forward, size: 22, color: _tone(_rt_Tw.amber400, _rt_Tw.amber600))),
          ),
          side(
            Container(
              width: 44,
              height: 44,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: _rt_Lab.tinted(_rt_Tw.amber50, _rt_Tw.amber500.withValues(alpha: 0.5)),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _rt_Tw.amber500.withValues(alpha: 0.4)),
              ),
              child: RepaintBoundary(child: CustomPaint(painter: _FruitThumbPainter(_clock))),
            ),
            's4_after_t',
            's4_after_d',
            _tone(_rt_Tw.amber400, _rt_Tw.amber700),
          ),
        ],
      ),
    );
  }

  /// Stage-card palette + the five chronological slots.
  Widget _sequenceBox() {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _line),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  _tx.s('s4SeqTitle').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.6,
                    color: _tone(_rt_Tw.amber400, _rt_Tw.amber700),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _tx.s('s4SeqSub'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _faint),
                ),
              ),
            ],
          ),
          Container(height: 1, margin: const EdgeInsets.symmetric(vertical: 5), color: _line),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 5,
                  runSpacing: 5,
                  children: [for (final k in _stageKeys) _stageCard(k)],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 46,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < 5; i++) ...[if (i > 0) const SizedBox(width: 5), Expanded(child: _slot(i))],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stageCard(String key) {
    final label = _tx.s('s4_cards.$key');
    Widget build({bool placed = false, bool selected = false}) => _chip(
      label: label,
      icon: Icons.check_circle,
      iconColor: _rt_Tw.amber400,
      placed: placed,
      selected: selected,
      stageCard: true,
      fontSize: 9.5,
    );
    final chip = build(placed: _order.contains(key), selected: _selType == 's4_chip' && _selId == key);
    return Draggable<String>(
      data: 'card:$key',
      dragAnchorStrategy: pointerDragAnchorStrategy,
      feedback: _dragFeedback(build()),
      childWhenDragging: Opacity(opacity: 0.4, child: chip),
      child: GestureDetector(onTap: () => _selectCard(key), child: chip),
    );
  }

  Widget _slot(int i) {
    final value = _order[i];
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) => d.data.startsWith('card:'),
      onAcceptWithDetails: (d) => _dropCard(d.data.substring(5), i),
      builder: (context, candidates, _) {
        final over = candidates.isNotEmpty;
        final filled = value != null;
        final border = over
            ? _accent
            : filled
            ? _rt_Tw.amber500.withValues(alpha: 0.6)
            : _tone(_rt_Tw.slate700, _rt_Tw.slate400);
        final bg = over
            ? Color.alphaBlend(_accent.withValues(alpha: 0.25), _glass)
            : filled
            ? _rt_Lab.tinted(_rt_Tw.amber50, _rt_Tw.amber500.withValues(alpha: 0.55))
            : _tone(const Color(0x990F172A), _rt_Tw.slate50);
        return GestureDetector(
          onTap: () => _slotTap(i),
          child: AnimatedScale(
            scale: over ? 1.04 : 1,
            duration: const Duration(milliseconds: 200),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: border, width: 2),
              ),
              child: filled
                  ? Row(
                      children: [
                        Container(
                          width: 15,
                          height: 15,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(color: _rt_Tw.amber400, shape: BoxShape.circle),
                          child: Text(
                            '${i + 1}',
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: _rt_Tw.slate950),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _tx.s('s4_cards.$value'),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 8.5,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              color: _tone(_rt_Tw.amber200, _rt_Tw.amber700),
                            ),
                          ),
                        ),
                        _miniIcon(Icons.close, _rt_Tw.slate400, () => _clearSlot(i)),
                      ],
                    )
                  : Row(
                      children: [
                        Text(
                          '${i + 1}',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: _faint),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '[ ${_tx.s('stage')} 0${i + 1} ]',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 9.5, fontStyle: FontStyle.italic, color: _faint),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }
}
