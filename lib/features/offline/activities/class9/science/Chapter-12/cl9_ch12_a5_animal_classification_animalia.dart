// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// ZSL Virtual Lab | Animal Classification(Animalia Groups)
// Converted from Cl9S-Ch12-A5-AnimalClassificationAnimalia.html (gsap -> Flutter).

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
    'title': 'Animal Classification(Animalia Groups)',
    'subtitle': 'Class 9 • Diversity in Living Organism',
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
    'scenario1_opt': '1. The Notochord Gate',
    'scenario2_opt': '2. Invertebrate Complexity Ladder',
    'scenario3_opt': '3. Diagnostic Feature Matcher',
    'gateLaneNonChordata': 'Invertebrata (Non-chordata) — No flexible rod',
    'gateLaneChordata': 'Chordata — Notochord present',
    'platProto': 'Protochordata',
    'platVert': 'Vertebrata',
    'vertTrayTitle': 'Vertebrata 5-Group Sequence',
    'vertTraySub': 'in book-printed order',
    's3TokensTitle': 'Phylum Tokens Palette',
    's2_r1_label': 'Rung ①: Porifera',
    's2_r2_label': 'Rung ②: Cnidaria',
    's2_r3_label': 'Rung ③: Platyhelminthes',
    's2_r4_label': 'Rung ④: Nematoda',
    's2_r5_label': 'Rung ⑤: Annelida',
    's2_r6_label': 'Rung ⑥: Arthropoda',
    's2_r7_label': 'Rung ⑦: Mollusca',
    's2_r8_label': 'Rung ⑧: Echinodermata',
    'sponge': 'Sponge',
    'hydra': 'Hydra',
    'flatworm': 'Flatworm',
    'roundworm': 'Roundworm',
    'earthworm': 'Earthworm',
    'arthropod': 'Insect / Crab',
    'mollusc': 'Snail',
    'starfish': 'Starfish',
    'amphioxus': 'Amphioxus',
    'vertebrate': 'Vertebrate',
    'vert_fish': 'Fish',
    'vert_amphibian': 'Amphibians',
    'vert_reptile': 'Reptiles',
    'vert_bird': 'Birds',
    'vert_mammal': 'Mammals',
    'phyla': {
      'porifera': 'Porifera',
      'cnidaria': 'Cnidaria',
      'platyhelminthes': 'Platyhelminthes',
      'nematoda': 'Nematoda',
      'annelida': 'Annelida',
      'arthropoda': 'Arthropoda',
      'mollusca': 'Mollusca',
      'echinodermata': 'Echinodermata',
    },
    'hud_s1': 'Sort 10 animal specimens across the Notochord Gate.',
    'hud_s2':
        'Arrange 8 invertebrate species on Rungs ① to ⑧ in complexity order.',
    'hud_s3':
        'Match the 8 Phylum tokens to the correct specimen diagnostic pins.',
    's1_obj':
        'Sort 10 animal specimens across the Notochord Gate into Non-chordata (8 invertebrates) and Chordata (Amphioxus and Vertebrate), then separate Protochordata from Vertebrata and sequence the 5 vertebrate classes.',
    's2_obj':
        'Arrange the 8 invertebrate phyla on the 8-rung complexity ladder from simplest cellular sponges to organ-system level echinoderms.',
    's3_obj':
        'Match the 8 Phylum name tokens to their correct anatomical specimen body plans using textbook diagnostic features.',
    's1_steps': [
      {
        't': 'Step 1: Pass Invertebrates into Lane ①',
        'i':
            'Drag Sponge, Hydra, Flatworm, Roundworm, Earthworm, Arthropod, Snail, and Starfish into Invertebrata.',
        'o': '8 Invertebrates assigned to Non-chordata.',
        'c': 'Non-chordates lack any internal flexible rod-shaped notochord.',
      },
      {
        't': 'Step 2: Pass Chordates into Lane ②',
        'i': 'Drag Amphioxus and the Vertebrate into Chordata.',
        'o': 'Amphioxus & Vertebrate pass into Chordata.',
        'c':
            'Chordates possess a flexible rod-shaped notochord at least once during life.',
      },
      {
        't': 'Step 3: Sort Protochordata vs Vertebrata',
        'i': 'Place Amphioxus on Protochordata and Vertebrate on Vertebrata.',
        'o': 'Platforms occupied.',
        'c':
            'Protochordates keep the notochord; Vertebrates replace it with a vertebral column (backbone).',
      },
      {
        't': 'Step 4: Sequence the 5 Vertebrate Classes',
        'i':
            'Drag Fish → Amphibians → Reptiles → Birds → Mammals into the 5-slot sequence tray.',
        'o': '5 Vertebrate groups ordered.',
        'c':
            'Vertebrata is classified into fish, amphibians, reptiles, birds, and mammals based on habitat, body covering, and reproduction.',
      },
    ],
    's2_steps': [
      {
        't': 'Step 1: Inspect 8 Complexity Rungs',
        'i':
            'Observe the 8 rungs ascending from simple cellular forms to complex organ-system animals.',
        'o': '8 Rungs ready.',
        'c':
            'Animal body plans evolve from simple tissue-less sponges to articulated organ systems.',
      },
      {
        't': 'Step 2: Climb the Invertebrate Ladder',
        'i':
            'Place the 8 invertebrate species onto Rungs ① to ⑧: Porifera → Cnidaria → Platyhelminthes → Nematoda → Annelida → Arthropoda → Mollusca → Echinodermata.',
        'o': 'All 8 rungs occupied.',
        'c':
            'New structural features improve feeding, movement, and protection but introduce new survival challenges.',
      },
    ],
    's3_steps': [
      {
        't': 'Step 1: Inspect Specimen Diagnostic Pins',
        'i':
            'Read the diagnostic feature clue on each numbered specimen pin card.',
        'o': 'Specimen features revealed.',
        'c':
            'Each phylum has a unique diagnostic structure defined in NCERT §12.6.5.',
      },
      {
        't': 'Step 2: Match 8 Phylum Tokens',
        'i':
            'Drag or tap each Phylum token to place it on its corresponding numbered pin.',
        'o': '8 Phylum tokens matched.',
        'c':
            'Porifera = pores/no tissues; Cnidaria = tentacles/1 opening; Arthropoda = jointed legs/exoskeleton; Echinodermata = spiny skeleton.',
      },
    ],
    's1_learn':
        'The notochord is the major classification criterion splitting animals into non-chordata and chordata; chordates split into protochordata (Amphioxus) and vertebrata (five groups: fish, amphibians, reptiles, birds, mammals).',
    's2_learn':
        'Invertebrate phyla follow a clear evolutionary sequence of increasing complexity: Porifera → Cnidaria → Platyhelminthes → Nematoda → Annelida → Arthropoda → Mollusca → Echinodermata.',
    's3_learn':
        'Each invertebrate phylum possesses a single defining diagnostic feature that adapts it for feeding, movement, and protection in its environment.',
    'gateHints': {
      'nonchordata':
          '<strong>Lane ① (Invertebrata / Non-chordata):</strong><br>• For animals lacking any flexible rod-shaped internal support structure.<br>• Includes 8 invertebrate groups (Porifera to Echinodermata).',
      'chordata':
          '<strong>Lane ② (Chordata):</strong><br>• For animals that develop a flexible rod-shaped notochord at least once during life.<br>• Includes Amphioxus and Vertebrates.',
    },
    'rungHints': {
      '1':
          '<strong>Rung ① (Porifera):</strong> Multicellular but lack tissue/organ organisation; porous body for water flow.',
      '2':
          '<strong>Rung ② (Cnidaria):</strong> Tissue-level organisation; tentacles; single opening for food and waste.',
      '3':
          '<strong>Rung ③ (Platyhelminthes):</strong> Bilateral symmetry; flattened body; single opening.',
      '4':
          '<strong>Rung ④ (Nematoda):</strong> Elongated cylindrical body; two openings: mouth and anus.',
      '5':
          '<strong>Rung ⑤ (Annelida):</strong> Segmented body; organ system level; true body cavity present.',
      '6':
          '<strong>Rung ⑥ (Arthropoda):</strong> Jointed appendages; tough external exoskeleton.',
      '7':
          '<strong>Rung ⑦ (Mollusca):</strong> Soft body; organ system level; shell development in many.',
      '8':
          '<strong>Rung ⑧ (Echinodermata):</strong> Hard internal skeleton of calcium carbonate; no notochord.',
    },
    's3_diagnostics': {
      'porifera':
          'Multicellular without tissues; body covered with pores for water current.',
      'cnidaria':
          'Tissue-level organisation; radiating tentacles; single opening for food and waste.',
      'platyhelminthes':
          'Dorsoventrally flattened ribbon; bilateral symmetry; single opening.',
      'nematoda':
          'Cylindrical round body; complete gut with two openings (mouth and anus).',
      'annelida':
          'Ringed metameric body segments; true body cavity; organ system level.',
      'arthropoda':
          'Jointed appendages for movement; hard chitinous exoskeleton.',
      'mollusca':
          'Soft unsegmented body with muscular foot and protective calcified shell.',
      'echinodermata':
          'Spiny-skinned marine animal; hard internal calcium-carbonate skeleton.',
    },
    'concTitle': 'Kingdom Animalia Classification & Notochord Criterion',
    'concHead1': '1. The Notochord as the Primary Criterion',
    'concBody1':
        'The presence or absence of a flexible rod-shaped notochord divides the entire animal kingdom into Non-chordata (invertebrates) and Chordata. Chordata further divides into Protochordata (possessing a notochord at least once in life, e.g., Amphioxus) and Vertebrata (possessing a true vertebral column/backbone).',
    'concHead2': '2. The 8 Invertebrate Phyla in Increasing Complexity',
    'concBody2':
        'Body organisation progresses systematically: Porifera (cellular, pores) → Cnidaria (tissue-level, single opening, tentacles) → Platyhelminthes (bilateral flatworms, 1 opening) → Nematoda (cylindrical roundworms, 2 openings) → Annelida (segmented, true body cavity) → Arthropoda (jointed appendages, hard exoskeleton) → Mollusca (soft body, shell) → Echinodermata (spiny calcium-carbonate internal skeleton).',
    'concHead3': '3. Vertebrate Diversity',
    'concBody3':
        'Vertebrates possess an internal backbone and are classified into five major groups: Fish, Amphibians, Reptiles, Birds, and Mammals based on broad patterns of habitat use, body covering, and reproduction.',
    // Labels the HTML hard-codes in its markup / scripts (English only there).
    'ui': {
      'speciesPaletteTitle': '10 Animal Species (Drag or Tap to Select)',
      'laneNonChordataNote':
          'Drop all 8 Invertebrate specimens here (cellular to organ-system animals without notochord).',
      'placed': '{n}/{total} Placed',
      'dropInverts': '[ Drop Invertebrates Here ]',
      'protoSlot': '[ Amphioxus ]',
      'vertSlotPlat': '[ Vertebrate ]',
      'protoNote': 'Notochord remains flexible at least once in life',
      'vertNote': 'Notochord replaced by vertebral column (backbone)',
      'slot': '[ Slot {n} ]',
      's2PaletteTitle': '8 Invertebrate Species',
      'complexityArrow': 'Increasing Body Organisation Complexity',
      'rungBadge': 'Rung {n}',
      'dropSpecies': '[ Drop Species Here ]',
      's3TokensNote':
          '(drag token onto matching specimen pin or tap to select)',
      'dropToken': '[ Drop Phylum Token ]',
      'pinLabel': 'Pin #{n}',
      'stepBadge': 'STEP {n}/3',
      'gateHintTitle': 'Gate Lane Criteria',
      'rungHintTitle': 'Rung 0{n} Diagnostic',
    },
    'tools': {
      'lock': 'Lock/Unlock Canvas Pan & Zoom',
      'zoomIn': 'Zoom In (Unlock to use)',
      'zoomOut': 'Zoom Out (Unlock to use)',
      'pan': 'Pan Mode (Unlock to use)',
      'labels': 'Toggle Visual Labels (Always Works)',
      'resetView': 'Reset View (Unlock to use)',
    },
    'toasts': {
      'selectS1':
          'Selected "{name}". Tap Lane 1 (Invertebrata) or Lane 2 (Chordata).',
      'selectVert': 'Selected "{name}". Tap any sequence slot 1-5.',
      'movedLane': 'Moved {name} into {lane}',
      'laneInvertebrata': 'Invertebrata',
      'laneChordata': 'Chordata',
      'needVertChip': 'Select a Vertebrate Group Chip above first!',
      'selectS2': 'Selected "{name}". Tap any Rung 1-8 on the Ladder.',
      'placedRung': '{name} placed on Rung {n}',
      'selectS3': 'Selected "{name}". Tap any Pin card below.',
      'needPhylum': 'Select a Phylum Name Token above first!',
      's3Hint':
          'Read the diagnostic quote on each pin card carefully to match the phylum!',
      's1Success':
          'Notochord Gate successfully cleared! Advancing to Complexity Ladder...',
      's1ErrLanes':
          'Ensure all 8 invertebrates enter Invertebrata lane and Amphioxus + Vertebrate enter Chordata lane.',
      's1ErrSeq':
          'Arrange the 5 vertebrate classes in order: Fish → Amphibians → Reptiles → Birds → Mammals.',
      's2Success':
          'Invertebrate Ladder correctly ordered! Advancing to Diagnostic Matcher...',
      's2Err':
          '{n} rung(s) are misplaced. Order: Porifera → Cnidaria → Platyhelminthes → Nematoda → Annelida → Arthropoda → Mollusca → Echinodermata.',
      's3Err': '{n} pin(s) are incorrectly matched. Check diagnostic clues.',
      'stepReset': 'Current step reset.',
      'locked': 'Canvas View Locked (2D Mode).',
      'unlocked': 'View Unlocked. Zoom and Pan Enabled.',
      'panOn': 'Pan Mode Active. Drag canvas to move.',
      'panOff': 'Pan Mode Disabled.',
      'viewReset': 'View Reset to 100%.',
      'labelsOn': 'Labels Visible.',
      'labelsOff': 'Labels Dimmed.',
    },
  },
  'hi': {
    'title': 'जंतु वर्गीकरण (ऐनिमेलिया समूह)',
    'subtitle': 'कक्षा 9 • जीवों में विविधता',
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
    'scenario1_opt': '1. नोटोकार्ड गेट',
    'scenario2_opt': '2. अकशेरुकी जटिलता सीढ़ी',
    'scenario3_opt': '3. नैदानिक लक्षण मिलान',
    'gateLaneNonChordata': 'अकशेरुकी (नॉन-कोर्डेटा) — नोटोकार्ड अनुपस्थित',
    'gateLaneChordata': 'कोर्डेटा — नोटोकार्ड उपस्थित',
    'platProto': 'प्रोटोकोर्डेटा',
    'platVert': 'वर्टिब्रेटा',
    'vertTrayTitle': 'कशेरुकी 5-वर्ग अनुक्रम',
    'vertTraySub': 'पाठ्यपुस्तक के अनुसार क्रम में',
    's3TokensTitle': 'उपलब्ध संघ टोकन',
    's2_r1_label': 'पायदान ①: पोरिफेरा',
    's2_r2_label': 'पायदान ②: नाइडेरिया',
    's2_r3_label': 'पायदान ③: प्लैटिहेल्मिंथीज',
    's2_r4_label': 'पायदान ④: नेमाटोडा',
    's2_r5_label': 'पायदान ⑤: एनेलिडा',
    's2_r6_label': 'पायदान ⑥: आर्थ्रोपोडा',
    's2_r7_label': 'पायदान ⑦: मोलस्का',
    's2_r8_label': 'पायदान ⑧: इकाइनोडर्मेटा',
    'sponge': 'स्पंज',
    'hydra': 'हाइड्रा',
    'flatworm': 'चपटाकृमि',
    'roundworm': 'गोलकृमि',
    'earthworm': 'केंचुआ',
    'arthropod': 'कीट / केकड़ा',
    'mollusc': 'घोंघा',
    'starfish': 'तारा मछली',
    'amphioxus': 'एम्फिऑक्सस',
    'vertebrate': 'कशेरुकी',
    'vert_fish': 'मत्स्य (मछली)',
    'vert_amphibian': 'जल-स्थलचर',
    'vert_reptile': 'सरीसृप',
    'vert_bird': 'पक्षी',
    'vert_mammal': 'स्तनधारी',
    'phyla': {
      'porifera': 'पोरिफेरा',
      'cnidaria': 'नाइडेरिया',
      'platyhelminthes': 'प्लैटिहेल्मिंथीज',
      'nematoda': 'नेमाटोडा',
      'annelida': 'एनेलिडा',
      'arthropoda': 'आर्थ्रोपोडा',
      'mollusca': 'मोलस्का',
      'echinodermata': 'इकाइनोडर्मेटा',
    },
    'hud_s1': '10 जंतु नमूनों को नोटोकार्ड गेट के माध्यम से छांटें।',
    'hud_s2': '8 अकशेरुकी प्रजातियों को पायदान ① से ⑧ पर लगाएं।',
    'hud_s3': 'संघ टोकनों को संबंधित नमूना पिन से मिलाएं।',
    's1_obj':
        '10 जंतु नमूनों को नोटोकार्ड गेट के माध्यम से नॉन-कोर्डेटा (8 अकशेरुकी) और कोर्डेटा (एम्फिऑक्सस व कशेरुकी) में छांटें, फिर प्रोटोकोर्डेटा और वर्टिब्रेटा को अलग करें।',
    's2_obj':
        '8 अकशेरुकी संघों को सरल कोशिकीय स्पंज से लेकर जटिल इकाइनोडर्म्स तक 8-पायदान सीढ़ी पर लगाएं।',
    's3_obj':
        '8 संघ नाम टोकनों को पाठ्यपुस्तक के लक्षणों के आधार पर सही नमूने से मिलाएं।',
    's1_steps': [
      {
        't': 'कदम 1: अकशेरुकियों को लेन ① में रखें',
        'i':
            'स्पंज, हाइड्रा, चपटाकृमि, गोलकृमि, केंचुआ, कीट, घोंघा और तारा मछली को अकशेरुकी लेन में ले जाएं।',
        'o': '8 अकशेरुकी नॉन-कोर्डेटा में रखे गए।',
        'c': 'अकशेरुकियों में कोई नोटोकार्ड नहीं होती।',
      },
      {
        't': 'कदम 2: कोर्डेट्स को लेन ② में रखें',
        'i': 'एम्फिऑक्सस और कशेरुकी को कोर्डेटा लेन में ले जाएं।',
        'o': 'कोर्डेट्स लेन ② में पहुंचे।',
        'c': 'कोर्डेटा में जीवन में कभी न कभी लचीली नोटोकार्ड पाई जाती है।',
      },
      {
        't': 'कदम 3: प्रोटोकोर्डेटा और वर्टिब्रेटा को अलग करें',
        'i':
            'एम्फिऑक्सस को प्रोटोकोर्डेटा पर और कशेरुकी को वर्टिब्रेटा प्लेटफॉर्म पर रखें।',
        'o': 'प्लेटफॉर्म भरे।',
        'c':
            'प्रोटोकोर्डेटा में केवल नोटोकार्ड होती है; वर्टिब्रेटा में रीढ़ की हड्डी बन जाती है।',
      },
      {
        't': 'कदम 4: 5 कशेरुकी वर्गों को क्रम में रखें',
        'i':
            'मत्स्य → जल-स्थलचर → सरीसृप → पक्षी → स्तनधारी को 5-खांचों में रखें।',
        'o': '5 वर्ग व्यवस्थित।',
        'c':
            'कशेरुकी को आवास, त्वचा आवरण और जनन के आधार पर 5 वर्गों में बांटा गया है।',
      },
    ],
    's2_steps': [
      {
        't': 'कदम 1: 8 पायदानों का निरीक्षण करें',
        'i': 'कोशिकीय स्तर से अंग-तंत्र स्तर तक बढ़ते 8 पायदानों को देखें।',
        'o': 'पायदान तैयार।',
        'c': 'जंतु शरीर सरल से जटिल की ओर विकसित हुआ है।',
      },
      {
        't': 'कदम 2: अकशेरुकी सीढ़ी पर चढ़ें',
        'i':
            '8 नमूनों को पायदान ① से ⑧ पर रखें: पोरिफेरा → नाइडेरिया → प्लैटिहेल्मिंथीज → नेमाटोडा → एनेलिडा → आर्थ्रोपोडा → मोलस्का → इकाइनोडर्मेटा।',
        'o': 'सीढ़ी पूर्ण।',
        'c': 'नई शारीरिक विशेषताएं पोषण, गति और सुरक्षा को बेहतर बनाती हैं।',
      },
    ],
    's3_steps': [
      {
        't': 'कदम 1: नमूना पिन का निरीक्षण',
        'i': 'प्रत्येक नमूने के पिन कार्ड पर लिखे लक्षण को पढ़ें।',
        'o': 'विशेषताएं प्रदर्शित।',
        'c': 'प्रत्येक संघ की अपनी पहचान होती है।',
      },
      {
        't': 'कदम 2: 8 संघ टोकनों का मिलान',
        'i': 'प्रत्येक संघ नाम टोकन को उसके सही नमूने पर रखें।',
        'o': 'टोकन मिलान पूर्ण।',
        'c':
            'पोरिफेरा = छिद्र/ऊतकहीन; नाइडेरिया = स्पर्शक/1 छिद्र; आर्थ्रोपोडा = संधिपाद/बाह्यकंकाल।',
      },
    ],
    's1_learn':
        'नोटोकार्ड जंतुओं को नॉन-कोर्डेटा और कोर्डेटा में बांटती है; कोर्डेटा आगे प्रोटोकोर्डेटा और वर्टिब्रेटा में बंटता है।',
    's2_learn':
        'अकशेरुकी संघ जटिलता के स्पष्ट क्रम में हैं: पोरिफेरा → नाइडेरिया → प्लैटिहेल्मिंथीज → नेमाटोडा → एनेलिडा → आर्थ्रोपोडा → मोलस्का → इकाइनोडर्मेटा।',
    's3_learn':
        'प्रत्येक अकशेरुकी संघ में एक विशिष्ट लक्षण होता है जो उसे जीवित रहने में सक्षम बनाता है।',
    'gateHints': {
      'nonchordata':
          '<strong>लेन ① (अकशेरुकी / नॉन-कोर्डेटा):</strong><br>• उन जंतुओं के लिए जिनमें नोटोकार्ड अनुपस्थित होती है।<br>• इसमें 8 अकशेरुकी संघ शामिल हैं।',
      'chordata':
          '<strong>लेन ② (कोर्डेटा):</strong><br>• उन जंतुओं के लिए जिनमें जीवन में कभी न कभी नोटोकार्ड पाई जाती है।<br>• इसमें एम्फिऑक्सस और कशेरुकी आते हैं।',
    },
    'rungHints': {
      '1':
          '<strong>पायदान ① (पोरिफेरा):</strong> कोशिकीय स्तर; ऊतकों का अभाव; छिद्रयुक्त शरीर।',
      '2':
          '<strong>पायदान ② (नाइडेरिया):</strong> ऊतक स्तर; स्पर्शक; एक ही द्वार।',
      '3':
          '<strong>पायदान ③ (प्लैटिहेल्मिंथीज):</strong> द्विपार्श्व सममिति; चपटा शरीर; एक ही द्वार।',
      '4':
          '<strong>पायदान ④ (नेमाटोडा):</strong> गोल बेलनाकार शरीर; दो द्वार (मुख और गुदा)।',
      '5':
          '<strong>पायदान ⑤ (एनेलिडा):</strong> खंडीय शरीर; वास्तविक देहगुहा; अंग तंत्र।',
      '6':
          '<strong>पायदान ⑥ (आर्थ्रोपोडा):</strong> जोड़ेदार संधित पैर; कठोर बाह्यकंकाल।',
      '7':
          '<strong>पायदान ⑦ (मोलस्का):</strong> कोमल शरीर; पेशीय पाद; कठोर कवच।',
      '8':
          '<strong>पायदान ⑧ (इकाइनोडर्मेटा):</strong> कंटीली त्वचा; कैल्सियम का अंतःकंकाल; नोटोकार्ड अनुपस्थित।',
    },
    's3_diagnostics': {
      'porifera': 'ऊतकहीन कोशिकीय संगठन; जल प्रवाह हेतु पूरे शरीर पर छिद्र।',
      'cnidaria':
          'ऊतक स्तर; शिकार हेतु स्पर्शक; भोजन व अपशिष्ट हेतु केवल एक द्वार।',
      'platyhelminthes':
          'चपटा फीते जैसा शरीर; द्विपार्श्व सममिति; एक ही द्वार।',
      'nematoda':
          'बेलनाकार गोल शरीर; पूर्ण आहारनाल (मुख और गुदा दो अलग द्वार)।',
      'annelida': 'वलयाकार खंडीय शरीर; वास्तविक देहगुहा; अंग-तंत्र स्तर।',
      'arthropoda': 'गति हेतु जोड़ेदार संधित पैर; काइटिनयुक्त कठोर बाह्यकंकाल।',
      'mollusca': 'कोमल शरीर, पेशीय पाद और कैल्सियम का सुरक्षात्मक कवच।',
      'echinodermata':
          'कंटीली त्वचा वाला समुद्री जीव; कैल्सियम कार्बोनेट का कठोर अंतःकंकाल।',
    },
    'concTitle': 'जंतु जगत वर्गीकरण एवं नोटोकार्ड मानदंड',
    'concHead1': '1. नोटोकार्ड: प्राथमिक वर्गीकरण मानदंड',
    'concBody1':
        'लचीली छड़ जैसी नोटोकार्ड की उपस्थिति या अनुपस्थिति जंतु जगत को अकशेरुकी (नॉन-कोर्डेटा) और कोर्डेटा में विभाजित करती है।',
    'concHead2': '2. 8 अकशेरुकी संघों का जटिलता क्रम',
    'concBody2':
        'शारीरिक संरचना स्पष्ट क्रम में विकसित हुई: पोरिफेरा → नाइडेरिया → प्लैटिहेल्मिंथीज → नेमाटोडा → एनेलिडा → आर्थ्रोपोडा → मोलस्का → इकाइनोडर्मेटा।',
    'concHead3': '3. कशेरुकी जीवों की विविधता',
    'concBody3':
        'कशेरुकी जीवों में रीढ़ की हड्डी होती है और इन्हें पांच प्रमुख वर्गों में बांटा गया है: मत्स्य, जल-स्थलचर, सरीसृप, पक्षी और स्तनधारी।',
    'ui': {
      'speciesPaletteTitle':
          '10 जंतु प्रजातियाँ (खींचें या चुनने के लिए टैप करें)',
      'laneNonChordataNote':
          'सभी 8 अकशेरुकी नमूने यहाँ छोड़ें (नोटोकार्ड रहित, कोशिकीय से अंग-तंत्र स्तर तक के जंतु)।',
      'placed': '{n}/{total} रखे गए',
      'dropInverts': '[ अकशेरुकी यहाँ छोड़ें ]',
      'protoSlot': '[ एम्फिऑक्सस ]',
      'vertSlotPlat': '[ कशेरुकी ]',
      'protoNote': 'जीवन में कम से कम एक बार लचीली नोटोकार्ड रहती है',
      'vertNote': 'नोटोकार्ड का स्थान कशेरुक दंड (रीढ़ की हड्डी) ले लेता है',
      'slot': '[ खांचा {n} ]',
      's2PaletteTitle': '8 अकशेरुकी प्रजातियाँ',
      'complexityArrow': 'शारीरिक संगठन की बढ़ती जटिलता',
      'rungBadge': 'पायदान {n}',
      'dropSpecies': '[ प्रजाति यहाँ छोड़ें ]',
      's3TokensNote':
          '(टोकन को मिलते नमूना पिन पर खींचें या चुनने के लिए टैप करें)',
      'dropToken': '[ संघ टोकन छोड़ें ]',
      'pinLabel': 'पिन #{n}',
      'stepBadge': 'चरण {n}/3',
      'gateHintTitle': 'गेट लेन मानदंड',
      'rungHintTitle': 'पायदान 0{n} नैदानिक लक्षण',
    },
    'tools': {
      'lock': 'कैनवास पैन और ज़ूम लॉक/अनलॉक करें',
      'zoomIn': 'ज़ूम इन (उपयोग के लिए अनलॉक करें)',
      'zoomOut': 'ज़ूम आउट (उपयोग के लिए अनलॉक करें)',
      'pan': 'पैन मोड (उपयोग के लिए अनलॉक करें)',
      'labels': 'दृश्य लेबल दिखाएँ/छिपाएँ (हमेशा काम करता है)',
      'resetView': 'दृश्य रीसेट करें (उपयोग के लिए अनलॉक करें)',
    },
    'toasts': {
      'selectS1':
          '"{name}" चुना गया। लेन 1 (अकशेरुकी) या लेन 2 (कोर्डेटा) पर टैप करें।',
      'selectVert': '"{name}" चुना गया। किसी भी क्रम खांचे 1-5 पर टैप करें।',
      'movedLane': '{name} को {lane} में रखा गया',
      'laneInvertebrata': 'अकशेरुकी',
      'laneChordata': 'कोर्डेटा',
      'needVertChip': 'पहले ऊपर से कोई कशेरुकी वर्ग चिप चुनें!',
      'selectS2': '"{name}" चुना गया। सीढ़ी के किसी भी पायदान 1-8 पर टैप करें।',
      'placedRung': '{name} पायदान {n} पर रखा गया',
      'selectS3': '"{name}" चुना गया। नीचे किसी भी पिन कार्ड पर टैप करें।',
      'needPhylum': 'पहले ऊपर से कोई संघ नाम टोकन चुनें!',
      's3Hint':
          'संघ मिलाने के लिए प्रत्येक पिन कार्ड पर लिखे नैदानिक लक्षण को ध्यान से पढ़ें!',
      's1Success':
          'नोटोकार्ड गेट सफलतापूर्वक पार! जटिलता सीढ़ी की ओर बढ़ रहे हैं...',
      's1ErrLanes':
          'सुनिश्चित करें कि सभी 8 अकशेरुकी, अकशेरुकी लेन में और एम्फिऑक्सस + कशेरुकी, कोर्डेटा लेन में जाएं।',
      's1ErrSeq':
          '5 कशेरुकी वर्गों को क्रम में लगाएं: मत्स्य → जल-स्थलचर → सरीसृप → पक्षी → स्तनधारी।',
      's2Success':
          'अकशेरुकी सीढ़ी सही क्रम में! नैदानिक लक्षण मिलान की ओर बढ़ रहे हैं...',
      's2Err':
          '{n} पायदान गलत हैं। क्रम: पोरिफेरा → नाइडेरिया → प्लैटिहेल्मिंथीज → नेमाटोडा → एनेलिडा → आर्थ्रोपोडा → मोलस्का → इकाइनोडर्मेटा।',
      's3Err': '{n} पिन गलत मिलाए गए हैं। नैदानिक संकेत जाँचें।',
      'stepReset': 'वर्तमान चरण रीसेट किया गया।',
      'locked': 'कैनवास दृश्य लॉक (2D मोड)।',
      'unlocked': 'दृश्य अनलॉक। ज़ूम और पैन सक्षम।',
      'panOn': 'पैन मोड सक्रिय। खिसकाने के लिए कैनवास खींचें।',
      'panOff': 'पैन मोड बंद।',
      'viewReset': 'दृश्य 100% पर रीसेट।',
      'labelsOn': 'लेबल दृश्यमान।',
      'labelsOff': 'लेबल धुंधले।',
    },
  },
});

// ------------------------------------------------------------ data ---

/// The 8 invertebrate specimens (HTML `invKeys`).
const _invertebrateKeys = [
  'sponge',
  'hydra',
  'flatworm',
  'roundworm',
  'earthworm',
  'arthropod',
  'mollusc',
  'starfish',
];

/// The 10 specimens sorted at the Notochord Gate (scenario 1).
const _gateSpeciesKeys = [..._invertebrateKeys, 'amphioxus', 'vertebrate'];

/// Vertebrate classes in book-printed order (the expected sequence).
const _vertClassKeys = [
  'vert_fish',
  'vert_amphibian',
  'vert_reptile',
  'vert_bird',
  'vert_mammal',
];

const _phylumKeys = [
  'porifera',
  'cnidaria',
  'platyhelminthes',
  'nematoda',
  'annelida',
  'arthropoda',
  'mollusca',
  'echinodermata',
];

/// Correct occupant of each ladder rung (scenario 2 `expectedOrder`).
const _ladderOrder = {
  1: 'sponge',
  2: 'hydra',
  3: 'flatworm',
  4: 'roundworm',
  5: 'earthworm',
  6: 'arthropod',
  7: 'mollusc',
  8: 'starfish',
};

/// Correct phylum token for each specimen pin (scenario 3 `expectedPins`).
const _expectedPins = {
  'sponge': 'porifera',
  'hydra': 'cnidaria',
  'flatworm': 'platyhelminthes',
  'roundworm': 'nematoda',
  'earthworm': 'annelida',
  'arthropod': 'arthropoda',
  'mollusc': 'mollusca',
  'starfish': 'echinodermata',
};

/// Specimen pin cards in the order (and numbering) the HTML lays them out.
const _pinSpecimens = [
  ('arthropod', 1),
  ('mollusc', 2),
  ('sponge', 3),
  ('earthworm', 4),
  ('hydra', 5),
  ('roundworm', 6),
  ('flatworm', 7),
  ('starfish', 8),
];

// ---------------------------------------------------------- colours ---
const _emerald = Color(0xFF10B981);
const _emeraldDeep = Color(0xFF059669);
const _cyan = Color(0xFF06B6D4);
const _purple = Color(0xFFA855F7);
const _amber = Color(0xFFF59E0B);
const _rose = Color(0xFFF43F5E);
const _violet = Color(0xFF8B5CF6);
const _indigo = Color(0xFF6366F1);
const _blue = Color(0xFF3B82F6);

/// Border / tint colour of each ladder rung.
const _rungAccents = {
  8: _emerald,
  7: _rose,
  6: _amber,
  5: _purple,
  4: _violet,
  3: _indigo,
  2: _blue,
  1: _cyan,
};

/// Low-alpha wash of [accent] over the current surface (Tailwind `bg-x-500/10`).
Color _wash(Color accent, [double alpha = 0.12]) =>
    Color.alphaBlend(accent.withValues(alpha: alpha), _rt_Lab.surface);

/// Readable foreground for text drawn on a [_wash] of [accent].
Color _ink(Color accent) =>
    _rt_Lab.onTinted(accent, Color.lerp(accent, Colors.black, 0.4)!);

/// The HTML `.glass-panel` background.
Color get _glass => _rt_Lab.surface.withValues(alpha: 0.92);

/// A token being dragged or tap-selected (HTML `data-token-type` / `data-token-id`).
class _DragToken {
  const _DragToken(this.type, this.id);

  /// 's1_specimen', 'vert_chip', 's2_specimen' or 'phylum_token'.
  final String type;
  final String id;
}

// ------------------------------------------------- specimen artwork ---

/// Parses the absolute `M L C Q Z` SVG path data used by the HTML `BioSVG` icons.
Path _svgPath(String d) {
  final path = Path();
  final tokens = RegExp(
    r'[MLCQZ]|-?\d*\.?\d+',
  ).allMatches(d).map((m) => m.group(0)!).toList();
  var i = 0;
  var cmd = 'M';
  double n() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    final t = tokens[i];
    if (RegExp(r'^[MLCQZ]$').hasMatch(t)) {
      cmd = t;
      i++;
      if (cmd == 'Z') path.close();
      continue;
    }
    switch (cmd) {
      case 'M':
        path.moveTo(n(), n());
        cmd = 'L'; // extra coordinate pairs after M are line-tos
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

/// Redraws the inline SVG specimen icons of the HTML (`BioSVG`).
class _BioArtPainter extends CustomPainter {
  const _BioArtPainter(this.kind);

  final String kind;

  static final Map<String, Path> _cache = {};
  static Path _p(String d) => _cache.putIfAbsent(d, () => _svgPath(d));

  @override
  void paint(Canvas canvas, Size size) {
    final viewBox = kind.startsWith('vert_') ? 48.0 : 64.0;
    canvas.save();
    canvas.scale(size.width / viewBox, size.height / viewBox);
    switch (kind) {
      case 'sponge':
        _shape(
          canvas,
          _p(
            'M22 58 C16 58 14 42 16 30 C18 20 22 14 26 14 C30 14 34 22 36 32 C38 24 42 18 46 18 C50 18 52 30 50 42 C48 54 42 58 36 58 Z',
          ),
          0xFFF59E0B,
          0xFFB45309,
          2,
        );
        _fill(canvas, _oval(26, 14, 4, 2), 0xFF78350F);
        _fill(canvas, _oval(46, 18, 4, 2), 0xFF78350F);
        for (final c in const [
          (24.0, 28.0),
          (30.0, 38.0),
          (44.0, 32.0),
          (38.0, 46.0),
          (28.0, 48.0),
        ]) {
          _fill(canvas, _oval(c.$1, c.$2, 1.5, 1.5), 0xFF78350F);
        }
      case 'hydra':
        _shape(
          canvas,
          _p('M30 60 C30 45 28 35 32 30 C36 35 34 45 34 60 Z'),
          0xFF38BDF8,
          0xFF0284C7,
          2,
        );
        for (final d in const [
          'M32 30 C24 24 16 26 12 18',
          'M32 30 C26 18 22 14 20 8',
          'M32 30 C32 16 34 10 32 6',
          'M32 30 C38 18 42 14 44 8',
          'M32 30 C40 24 48 26 52 18',
        ]) {
          _stroke(canvas, _p(d), 0xFF38BDF8, 3, round: true);
        }
        _fill(canvas, _oval(32, 30, 3, 2), 0xFF0369A1);
      case 'flatworm':
        _shape(
          canvas,
          _p(
            'M12 40 C16 48 42 36 54 24 C56 22 52 16 48 18 C36 24 16 28 12 40 Z',
          ),
          0xFFF472B6,
          0xFFDB2777,
          2,
        );
        _fill(canvas, _oval(50, 20, 1.5, 1.5), 0xFF000000);
        _fill(canvas, _oval(48, 23, 1.5, 1.5), 0xFF000000);
      case 'roundworm':
        final body = _p('M14 50 C24 60 48 46 36 30 C24 14 48 10 52 16');
        _stroke(canvas, body, 0xFFFDE047, 6, round: true);
        _stroke(canvas, body, 0xFFCA8A04, 2, round: true);
      case 'earthworm':
        _stroke(
          canvas,
          _p('M12 46 C20 54 36 48 30 34 C24 20 44 14 52 22'),
          0xFFE11D48,
          6,
          round: true,
        );
        _fill(canvas, _oval(32, 26, 4, 4), 0xFFFB7185);
        _stroke(
          canvas,
          _p(
            'M16 48 L17 46 M22 50 L23 48 M28 42 L29 40 M38 22 L39 20 M44 18 L45 16 M48 20 L49 18',
          ),
          0xFF881337,
          2,
        );
      case 'arthropod':
        _shape(canvas, _oval(32, 34, 8, 12), 0xFFB45309, 0xFF78350F, 2);
        _shape(canvas, _oval(32, 20, 5, 5), 0xFFB45309, 0xFF78350F, 2);
        _stroke(
          canvas,
          _p('M30 16 L24 10 M34 16 L40 10'),
          0xFF78350F,
          2,
          round: true,
        );
        _stroke(
          canvas,
          _p('M26 28 L14 24 M24 34 L12 34 M26 40 L14 46'),
          0xFF78350F,
          3,
          round: true,
        );
        _stroke(
          canvas,
          _p('M38 28 L50 24 M40 34 L52 34 M38 40 L50 46'),
          0xFF78350F,
          3,
          round: true,
        );
        _stroke(canvas, _p('M32 26 L32 44'), 0xFF78350F, 2);
      case 'mollusc':
        _shape(
          canvas,
          _p(
            'M14 48 C24 50 48 50 54 44 C56 42 50 40 44 42 C30 42 16 42 14 48 Z',
          ),
          0xFF94A3B8,
          0xFF475569,
          2,
        );
        _shape(
          canvas,
          _p('M46 40 C48 34 46 22 36 22 C26 22 22 32 26 42 Z'),
          0xFFD97706,
          0xFF92400E,
          2,
        );
        _stroke(
          canvas,
          _p('M36 26 C42 28 42 36 34 36 C30 36 30 32 34 32'),
          0xFF92400E,
          2,
        );
        _stroke(
          canvas,
          _p('M50 42 L56 34 M52 42 L58 38'),
          0xFF475569,
          1.5,
          round: true,
        );
      case 'starfish':
        _shape(
          canvas,
          _poly(const [
            32,
            8,
            39,
            24,
            56,
            26,
            43,
            38,
            47,
            56,
            32,
            46,
            17,
            56,
            21,
            38,
            8,
            26,
            25,
            24,
          ]),
          0xFFEA580C,
          0xFF9A3412,
          2,
        );
        _fill(canvas, _oval(32, 34, 3, 3), 0xFFC2410C);
      case 'amphioxus':
        _shape(
          canvas,
          _p('M10 32 C20 22 44 22 56 32 C44 42 20 42 10 32 Z'),
          0xFF67E8F9,
          0xFF0891B2,
          2,
        );
        _stroke(canvas, _p('M14 32 L52 32'), 0xFFA855F7, 3, round: true);
        _fill(canvas, _oval(50, 30, 1.5, 1.5), 0xFF000000);
      case 'vertebrate':
        _shape(
          canvas,
          _p('M8 32 C18 20 42 20 54 32 C42 44 18 44 8 32 Z'),
          0xFF3B82F6,
          0xFF1D4ED8,
          2,
        );
        _fill(canvas, _poly(const [8, 32, 2, 24, 2, 40]), 0xFF1D4ED8);
        // Backbone: stroke-dasharray="2,2".
        for (var x = 16.0; x < 48; x += 4) {
          _stroke(
            canvas,
            Path()
              ..moveTo(x, 32)
              ..lineTo(math.min(x + 2, 48), 32),
            0xFFFACC15,
            3,
          );
        }
        _fill(canvas, _oval(46, 28, 2, 2), 0xFF000000);
      case 'vert_fish':
        _fill(
          canvas,
          _p('M6 24 C14 15 32 15 42 24 C32 33 14 33 6 24 Z'),
          0xFF38BDF8,
        );
        _fill(canvas, _poly(const [6, 24, 2, 18, 2, 30]), 0xFF0284C7);
        _fill(canvas, _oval(36, 22, 1.5, 1.5), 0xFF000000);
      case 'vert_amphibian':
        _fill(canvas, _oval(24, 26, 12, 9), 0xFF4ADE80);
        _fill(canvas, _oval(18, 18, 4, 4), 0xFF22C55E);
        _fill(canvas, _oval(30, 18, 4, 4), 0xFF22C55E);
        _fill(canvas, _oval(18, 18, 1.5, 1.5), 0xFF000000);
        _fill(canvas, _oval(30, 18, 1.5, 1.5), 0xFF000000);
      case 'vert_reptile':
        _fill(canvas, _p('M10 24 Q24 12 38 24 Q24 36 10 24'), 0xFFA3E635);
        _fill(canvas, _oval(32, 20, 1.5, 1.5), 0xFF000000);
      case 'vert_bird':
        _fill(
          canvas,
          _p('M12 30 C18 16 32 16 38 26 C30 34 20 34 12 30 Z'),
          0xFFFB923C,
        );
        _fill(canvas, _poly(const [38, 24, 46, 26, 38, 28]), 0xFFEA580C);
      case 'vert_mammal':
        _fill(canvas, _oval(24, 24, 12, 12), 0xFFF472B6);
        _fill(canvas, _oval(15, 14, 4, 4), 0xFFEC4899);
        _fill(canvas, _oval(33, 14, 4, 4), 0xFFEC4899);
        _fill(canvas, _oval(20, 22, 1.5, 1.5), 0xFF000000);
        _fill(canvas, _oval(28, 22, 1.5, 1.5), 0xFF000000);
        _fill(canvas, _oval(24, 27, 3, 2), 0xFFBE185D);
    }
    canvas.restore();
  }

  static Path _oval(double cx, double cy, double rx, double ry) => Path()
    ..addOval(
      Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry * 2),
    );

  static Path _poly(List<double> pts) => Path()
    ..addPolygon([
      for (var i = 0; i + 1 < pts.length; i += 2) Offset(pts[i], pts[i + 1]),
    ], true);

  static void _fill(Canvas canvas, Path path, int color) =>
      canvas.drawPath(path, Paint()..color = Color(color));

  static void _stroke(
    Canvas canvas,
    Path path,
    int color,
    double width, {
    bool round = false,
  }) => canvas.drawPath(
    path,
    Paint()
      ..color = Color(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = round ? StrokeCap.round : StrokeCap.butt,
  );

  static void _shape(
    Canvas canvas,
    Path path,
    int fill,
    int stroke,
    double width,
  ) {
    _fill(canvas, path, fill);
    _stroke(canvas, path, stroke, width);
  }

  @override
  bool shouldRepaint(_BioArtPainter old) => old.kind != kind;
}

/// One specimen / vertebrate-class icon.
class _BioArt extends StatelessWidget {
  const _BioArt(this.kind, {this.size = 32});

  final String kind;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: _BioArtPainter(kind)),
  );
}

/// Icon bouncing like Tailwind's `animate-bounce` (complexity arrow).
class _BounceIcon extends StatefulWidget {
  const _BounceIcon({required this.icon, required this.color, this.size = 18});

  final IconData icon;
  final Color color;
  final double size;

  @override
  State<_BounceIcon> createState() => _BounceIconState();
}

class _BounceIconState extends State<_BounceIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (context, child) => Transform.translate(
      offset: Offset(
        0,
        -0.25 * widget.size * math.cos(math.pi * _ctrl.value).abs(),
      ),
      child: child,
    ),
    child: Icon(widget.icon, size: widget.size, color: widget.color),
  );
}

/// Turns the HTML hint markup (`<strong>`, `<br>`) into styled text.
Widget _hintMarkup(String html) {
  final text = html.replaceAll('<br>', '\n');
  final spans = <TextSpan>[];
  var last = 0;
  for (final m in RegExp(r'<strong>(.*?)</strong>').allMatches(text)) {
    if (m.start > last) {
      spans.add(TextSpan(text: text.substring(last, m.start)));
    }
    spans.add(
      TextSpan(
        text: m.group(1),
        style: TextStyle(fontWeight: FontWeight.w900, color: _rt_Lab.text),
      ),
    );
    last = m.end;
  }
  if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
  return Text.rich(
    TextSpan(children: spans),
    style: TextStyle(fontSize: 13, color: _rt_Lab.textMuted, height: 1.5),
  );
}

// ------------------------------------------------------------- page ---

class Cl9Ch12A5AnimalClassificationAnimaliaPage extends StatefulWidget {
  const Cl9Ch12A5AnimalClassificationAnimaliaPage({super.key});

  @override
  State<Cl9Ch12A5AnimalClassificationAnimaliaPage> createState() =>
      _Cl9Ch12A5AnimalClassificationAnimaliaPageState();
}

class _Cl9Ch12A5AnimalClassificationAnimaliaPageState
    extends State<Cl9Ch12A5AnimalClassificationAnimaliaPage> {
  final _rt_ShellController _shell = _rt_ShellController();
  final ScrollController _scroll = ScrollController(keepScrollOffset: false);
  final GlobalKey _stageKey = GlobalKey();

  /// Room left around the scenario content for the HUD (top), the canvas
  /// toolbar (right) and the Hint / Reset / Verify buttons (bottom).
  static const EdgeInsets _contentPadding = EdgeInsets.fromLTRB(10, 60, 56, 58);

  // --- App state (currentStep / selectedToken) ---
  int _step = 1;
  _DragToken? _selected;
  bool _learnVisible = false;

  // --- Validation state (s1State / s2State / s3State) ---
  final Map<String, String?> _s1Lanes = {
    for (final k in _gateSpeciesKeys) k: null,
  };
  final List<String?> _s1VertOrder = List<String?>.filled(5, null);
  final Map<int, String?> _s2Rungs = {for (var r = 1; r <= 8; r++) r: null};
  final Map<String, String?> _s3Pins = {
    for (final k in _invertebrateKeys) k: null,
  };

  // --- Canvas view tools (lock / zoom / pan / labels) ---
  bool _locked = true;
  bool _panMode = false;
  bool _showLabels = true;
  double _zoom = 1;
  Offset _pan = Offset.zero;
  Offset _hudOffset = Offset.zero;

  // --- Timers (setTimeout) and drag auto-scroll ---
  final List<Timer> _timers = [];
  int _gen = 0;
  Timer? _autoScroll;
  Offset? _dragPosition;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
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
    _autoScroll?.cancel();
    _scroll.dispose();
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

  void _toast(
    String message, {
    Color color = _emeraldDeep,
    IconData icon = Icons.info_outline,
  }) => _shell.showToast(message, color: color, icon: icon);

  bool _isSelected(String type, String id) =>
      _selected?.type == type && _selected?.id == id;

  // ------------------------------------------------------- navigation ---
  void _setStep(int step) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _step = step;
      _selected = null;
      _learnVisible = false;
    });
  }

  void _select(_DragToken token, String toastKey, String name) {
    setState(() => _selected = token);
    _toast(
      _tx.s('toasts.$toastKey').replaceAll('{name}', name),
      icon: Icons.touch_app,
    );
  }

  // ------------------------------------------ scenario 1: notochord gate ---
  void _handleLaneClick(String lane) {
    final sel = _selected;
    if (sel != null && sel.type == 's1_specimen') {
      _assignS1Lane(sel.id, lane);
    } else {
      _showGateHint(lane);
    }
  }

  void _assignS1Lane(String id, String lane) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _s1Lanes[id] = lane;
      _selected = null;
    });
    final laneName = _tx.s(
      lane == 'nonchordata' ? 'toasts.laneInvertebrata' : 'toasts.laneChordata',
    );
    _toast(
      _tx
          .s('toasts.movedLane')
          .replaceAll('{name}', _tx.s(id))
          .replaceAll('{lane}', laneName),
      icon: Icons.check,
    );
  }

  void _handleVertSlotClick(int slot) {
    final sel = _selected;
    if (sel == null || sel.type != 'vert_chip') {
      _toast(
        _tx.s('toasts.needVertChip'),
        color: _rt_Tw.amber500,
        icon: Icons.warning_amber,
      );
      return;
    }
    _placeVertChip(sel.id, slot);
  }

  void _placeVertChip(String id, int slot) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _s1VertOrder[slot] = id;
      _selected = null;
    });
  }

  void _clearVertSlot(int slot) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _s1VertOrder[slot] = null);
  }

  // ---------------------------------------- scenario 2: complexity ladder ---
  void _handleRungClick(int rung) {
    final sel = _selected;
    if (sel != null && sel.type == 's2_specimen') {
      _assignS2Rung(sel.id, rung);
    } else {
      _showRungHint(rung);
    }
  }

  void _assignS2Rung(String id, int rung) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      for (final r in _s2Rungs.keys.toList()) {
        if (_s2Rungs[r] == id) _s2Rungs[r] = null;
      }
      _s2Rungs[rung] = id;
      _selected = null;
    });
    _toast(
      _tx
          .s('toasts.placedRung')
          .replaceAll('{name}', _tx.s(id))
          .replaceAll('{n}', '$rung'),
      icon: Icons.check,
    );
  }

  void _clearS2Rung(int rung) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _s2Rungs[rung] = null);
  }

  // ------------------------------------- scenario 3: diagnostic matcher ---
  void _quickAssignS3Pin(String specimen) {
    final sel = _selected;
    if (sel == null || sel.type != 'phylum_token') {
      _toast(
        _tx.s('toasts.needPhylum'),
        color: _rt_Tw.amber500,
        icon: Icons.warning_amber,
      );
      return;
    }
    _assignS3Pin(specimen, sel.id);
  }

  void _assignS3Pin(String specimen, String phylum) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      for (final k in _s3Pins.keys.toList()) {
        if (_s3Pins[k] == phylum) _s3Pins[k] = null;
      }
      _s3Pins[specimen] = phylum;
      _selected = null;
    });
  }

  void _clearS3Pin(String specimen) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _s3Pins[specimen] = null);
  }

  // ------------------------------------------------ validation & modals ---
  void _showStepHint() {
    switch (_step) {
      case 1:
        _showGateHint('nonchordata');
      case 2:
        _showRungHint(1);
      default:
        _toast(
          _tx.s('toasts.s3Hint'),
          color: _rt_Tw.amber500,
          icon: Icons.lightbulb,
        );
    }
  }

  void _validateStep() {
    _rt_playSfx(_rt_Sfx.click);
    switch (_step) {
      case 1:
        final invsOk = _invertebrateKeys.every(
          (k) => _s1Lanes[k] == 'nonchordata',
        );
        final chordsOk =
            _s1Lanes['amphioxus'] == 'chordata' &&
            _s1Lanes['vertebrate'] == 'chordata';
        var vertSeqOk = true;
        for (var i = 0; i < _vertClassKeys.length; i++) {
          if (_s1VertOrder[i] != _vertClassKeys[i]) vertSeqOk = false;
        }
        if (invsOk && chordsOk && vertSeqOk) {
          _passStep('toasts.s1Success', next: 2);
        } else {
          _failStep(
            _tx.s(invsOk && chordsOk ? 'toasts.s1ErrSeq' : 'toasts.s1ErrLanes'),
          );
        }
      case 2:
        var wrongRungs = 0;
        for (var r = 1; r <= 8; r++) {
          if (_s2Rungs[r] != _ladderOrder[r]) wrongRungs++;
        }
        if (wrongRungs == 0) {
          _passStep('toasts.s2Success', next: 3);
        } else {
          _failStep(_tx.s('toasts.s2Err').replaceAll('{n}', '$wrongRungs'));
        }
      default:
        var wrongPins = 0;
        for (final e in _expectedPins.entries) {
          if (_s3Pins[e.key] != e.value) wrongPins++;
        }
        if (wrongPins == 0) {
          setState(() => _learnVisible = true);
          _showConclusion();
        } else {
          _failStep(_tx.s('toasts.s3Err').replaceAll('{n}', '$wrongPins'));
        }
    }
  }

  void _passStep(String toastKey, {required int next}) {
    _rt_playSfx(_rt_Sfx.success);
    setState(() => _learnVisible = true);
    _toast(_tx.s(toastKey), color: _rt_Tw.green500, icon: Icons.check_circle);
    _after(1400, () => _setStep(next));
  }

  void _failStep(String message) {
    _rt_playSfx(_rt_Sfx.wrong);
    _toast(message, color: _rt_Tw.red500, icon: Icons.cancel);
  }

  void _clearScenario(int step) {
    switch (step) {
      case 1:
        for (final k in _s1Lanes.keys.toList()) {
          _s1Lanes[k] = null;
        }
        _s1VertOrder.fillRange(0, _s1VertOrder.length, null);
      case 2:
        for (final r in _s2Rungs.keys.toList()) {
          _s2Rungs[r] = null;
        }
      default:
        for (final k in _s3Pins.keys.toList()) {
          _s3Pins[k] = null;
        }
    }
  }

  void _resetStep() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _selected = null;
      _learnVisible = false;
      _clearScenario(_step);
    });
    _toast(_tx.s('toasts.stepReset'), icon: Icons.refresh);
  }

  void _restart() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _gen++;
    _stopAutoScroll();
    setState(() {
      for (var s = 1; s <= 3; s++) {
        _clearScenario(s);
      }
      _zoom = 1;
      _pan = Offset.zero;
      _locked = true;
      _panMode = false;
    });
    _setStep(1);
  }

  void _showGateHint(String lane) =>
      _showHintModal(_tx.s('ui.gateHintTitle'), _tx.s('gateHints.$lane'));

  void _showRungHint(int rung) => _showHintModal(
    _tx.s('ui.rungHintTitle').replaceAll('{n}', '$rung'),
    _tx.s('rungHints.$rung'),
  );

  void _showHintModal(String title, String markup) {
    _rt_playSfx(_rt_Sfx.click);
    _rt_showShellPopup(
      context,
      title: title,
      icon: Icons.info,
      color: _emeraldDeep,
      buttonLabel: _tx.s('gotIt'),
      body: SizedBox(width: double.infinity, child: _hintMarkup(markup)),
    );
  }

  Future<void> _showConclusion() async {
    Widget section(Color accent, IconData icon, String head, String body) =>
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _wash(accent, 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accent.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 15, color: _ink(accent)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      head,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: _ink(accent),
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
                  color: _rt_Lab.textMuted,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
    await _shell.showSuccess(
      title: _tx.s('concTitle'),
      icon: Icons.check_circle,
      color: _emeraldDeep,
      buttonLabel: _tx.s('btnReplay'),
      body: Column(
        children: [
          section(
            _emerald,
            Icons.biotech,
            _tx.s('concHead1'),
            _tx.s('concBody1'),
          ),
          section(
            _cyan,
            Icons.account_tree,
            _tx.s('concHead2'),
            _tx.s('concBody2'),
          ),
          section(
            _amber,
            Icons.view_column,
            _tx.s('concHead3'),
            _tx.s('concBody3'),
          ),
        ],
      ),
      onConfirm: () {
        if (mounted) _restart(); // a tap outside just closes the popup
      },
    );
  }

  // ------------------------------------------------------- view tools ---
  void _toggleLock() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _locked = !_locked;
      if (_locked) _panMode = false;
    });
    _toast(
      _tx.s(_locked ? 'toasts.locked' : 'toasts.unlocked'),
      icon: _locked ? Icons.lock : Icons.lock_open,
    );
  }

  void _zoomBy(int dir) {
    if (_locked) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(
      () => _zoom = dir > 0
          ? math.min(_zoom + 0.15, 1.8)
          : math.max(_zoom - 0.15, 0.65),
    );
  }

  void _togglePan() {
    if (_locked) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _panMode = !_panMode);
    _toast(
      _tx.s(_panMode ? 'toasts.panOn' : 'toasts.panOff'),
      icon: Icons.pan_tool,
    );
  }

  void _resetView() {
    if (_locked) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      _zoom = 1;
      _pan = Offset.zero;
    });
    _toast(_tx.s('toasts.viewReset'), icon: Icons.center_focus_strong);
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _showLabels = !_showLabels);
    _toast(
      _tx.s(_showLabels ? 'toasts.labelsOn' : 'toasts.labelsOff'),
      icon: Icons.sell,
    );
  }

  // ---------------------------------------------- drag edge auto-scroll ---
  void _dragStarted() {
    _autoScroll?.cancel();
    _autoScroll = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _autoScrollTick(),
    );
  }

  void _stopAutoScroll() {
    _autoScroll?.cancel();
    _autoScroll = null;
    _dragPosition = null;
  }

  /// Scrolls the scenario while a dragged token is held over the HUD strip
  /// (top) or the button strip (bottom), so every drop zone stays reachable.
  void _autoScrollTick() {
    final pos = _dragPosition;
    final box = _stageKey.currentContext?.findRenderObject();
    if (!mounted ||
        pos == null ||
        !_scroll.hasClients ||
        box is! RenderBox ||
        !box.hasSize) {
      return;
    }
    final y = box.globalToLocal(pos).dy;
    final top = _contentPadding.top;
    final bottom = box.size.height - _contentPadding.bottom;
    double delta = 0;
    if (y < top) {
      delta = -(2 + 12 * ((top - y) / top).clamp(0.0, 1.0));
    } else if (y > bottom) {
      delta = 2 + 12 * ((y - bottom) / _contentPadding.bottom).clamp(0.0, 1.0);
    }
    if (delta == 0) return;
    final p = _scroll.position;
    final target = (p.pixels + delta).clamp(
      p.minScrollExtent,
      p.maxScrollExtent,
    );
    if (target != p.pixels) _scroll.jumpTo(target);
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
              accent: _emeraldDeep,
              headerGradient: [_rt_Tw.slate950, Color(0xFF064E3B)],
              headerSubtitleColor: _rt_Tw.emerald400,
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('title'),
              subtitle: _tx.s('subtitle'),
              buttonLabel: _tx.s('enterLab'),
              icon: Icons.biotech,
              buttonIcon: Icons.rocket_launch,
            ),
            onRestart: _restart,
            toolbarExtras: _tools(),
            sidebarTop: _sidebarTop(),
            tabs: [
              _rt_ShellTab(
                label: _tx.s('labProgress'),
                icon: Icons.co_present,
                builder: (_) => _labTab(),
              ),
            ],
            canvasBackground: _rt_Lab.canvas,
            canvas: _stage(),
            canvasOverlays: [
              Positioned(
                top: 12 + _hudOffset.dy,
                left: 70 + _hudOffset.dx,
                right: 70 - _hudOffset.dx,
                child: Center(child: _hud()),
              ),
              Positioned(left: 10, right: 10, bottom: 10, child: _actionBar()),
            ],
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------- sidebar ---
  Widget _stepBadge() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: _wash(_emerald, 0.2),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(
      _tx.s('ui.stepBadge').replaceAll('{n}', '$_step'),
      style: TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w900,
        fontFamily: 'monospace',
        color: _ink(_emerald),
      ),
    ),
  );

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
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: _wash(_emerald, 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.co_present, size: 13, color: _ink(_emerald)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _tx.s('labProgress').toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1,
                    color: _rt_Lab.text,
                  ),
                ),
              ),
              _stepBadge(),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _tx.s('moduleSel').toUpperCase(),
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: _rt_Lab.textMuted,
            ),
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
                iconEnabledColor: _emerald,
                borderRadius: BorderRadius.circular(12),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _rt_Lab.text,
                ),
                items: [
                  for (var n = 1; n <= 3; n++)
                    DropdownMenuItem(
                      value: n,
                      child: Text(
                        _tx.s('scenario${n}_opt'),
                        overflow: TextOverflow.ellipsis,
                      ),
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

  Widget _labTab() {
    final steps = _tx.list('s${_step}_steps');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('missionObj'),
          desc: _tx.s('s${_step}_obj'),
          accent: _emeraldDeep,
          icon: Icons.gps_fixed,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(
                _tx.s('detailedSteps'),
                icon: Icons.format_list_numbered,
                color: _ink(_emerald),
              ),
              for (var i = 0; i < steps.length; i++)
                _stepCard(i, steps[i] as Map),
              if (_learnVisible)
                _rt_InfoCard(
                  title: _tx.s('what_we_learn'),
                  body: _tx.s('s${_step}_learn'),
                  icon: Icons.lightbulb,
                  color: _emeraldDeep,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepCard(int index, Map step) {
    Widget section(
      IconData icon,
      String label,
      String body,
      Color accent,
      Color bodyColor,
    ) => Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: accent),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: accent,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            body,
            style: TextStyle(
              fontSize: 12,
              color: bodyColor,
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: _rt_Lab.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _wash(_emerald, 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: _ink(_emerald),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    step['t'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: _rt_Lab.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
          section(
            Icons.play_arrow,
            _tx.s('taskInstr'),
            step['i'] as String,
            _ink(_emerald),
            _rt_Lab.text,
          ),
          section(
            Icons.visibility,
            _tx.s('expOut'),
            step['o'] as String,
            _ink(_blue),
            _rt_Lab.textMuted,
          ),
          section(
            Icons.lightbulb,
            _tx.s('conceptLearned'),
            step['c'] as String,
            _ink(_emerald),
            _ink(_emerald),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------------- canvas overlays ---
  List<Widget> _tools() {
    Widget tool({
      required IconData icon,
      required String tip,
      required VoidCallback onTap,
      bool active = false,
      bool enabled = true,
    }) {
      return Tooltip(
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
                color: active ? _emeraldDeep : _rt_Lab.surface,
                shape: BoxShape.circle,
                border: Border.all(color: active ? _emerald : _rt_Lab.border),
              ),
              child: Icon(
                icon,
                size: 16,
                color: active ? Colors.white : _rt_Lab.textMuted,
              ),
            ),
          ),
        ),
      );
    }

    const gap = SizedBox(height: 4);
    return [
      tool(
        icon: _locked ? Icons.lock : Icons.lock_open,
        tip: _tx.s('tools.lock'),
        active: _locked,
        onTap: _toggleLock,
      ),
      gap,
      tool(
        icon: Icons.add,
        tip: _tx.s('tools.zoomIn'),
        enabled: !_locked,
        onTap: () => _zoomBy(1),
      ),
      gap,
      tool(
        icon: Icons.remove,
        tip: _tx.s('tools.zoomOut'),
        enabled: !_locked,
        onTap: () => _zoomBy(-1),
      ),
      gap,
      tool(
        icon: Icons.pan_tool,
        tip: _tx.s('tools.pan'),
        enabled: !_locked,
        active: _panMode,
        onTap: _togglePan,
      ),
      gap,
      tool(
        icon: Icons.sell,
        tip: _tx.s('tools.labels'),
        active: _showLabels,
        onTap: _toggleLabels,
      ),
      gap,
      tool(
        icon: Icons.center_focus_strong,
        tip: _tx.s('tools.resetView'),
        enabled: !_locked,
        onTap: _resetView,
      ),
    ];
  }

  /// Top mini-HUD (draggable, like the HTML `#top-hud`).
  Widget _hud() {
    return GestureDetector(
      onPanUpdate: (d) => setState(() {
        _hudOffset = Offset(
          (_hudOffset.dx + d.delta.dx).clamp(-120.0, 120.0),
          (_hudOffset.dy + d.delta.dy).clamp(-8.0, 220.0),
        );
      }),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _glass,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _rt_Lab.border),
          boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 14)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.drag_indicator, size: 14, color: _rt_Lab.textFaint),
            const SizedBox(width: 2),
            const Icon(Icons.navigation, size: 13, color: _emerald),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _tx.s('hud_s$_step'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _rt_Lab.text,
                  height: 1.25,
                ),
              ),
            ),
            const SizedBox(width: 8),
            _stepBadge(),
          ],
        ),
      ),
    );
  }

  /// Hint / Reset / Verify buttons (bottom-right of the HTML canvas).
  Widget _actionBar() {
    Widget button({
      required IconData icon,
      required String label,
      required Color color,
      required VoidCallback onTap,
      bool filled = false,
    }) {
      final fg = filled ? _rt_Tw.slate950 : color;
      return Material(
        color: filled ? _emerald : _glass,
        elevation: 4,
        shadowColor: filled ? _emerald.withValues(alpha: 0.5) : _rt_Lab.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: filled ? Colors.transparent : _rt_Lab.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: filled ? 14 : 11,
              vertical: 9,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: filled ? 0.6 : 0,
                    color: fg,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.centerRight,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            button(
              icon: Icons.lightbulb,
              label: _tx.s('hint'),
              color: _rt_Tw.amber400,
              onTap: _showStepHint,
            ),
            const SizedBox(width: 8),
            button(
              icon: Icons.refresh,
              label: _tx.s('resetStep'),
              color: _rt_Lab.textMuted,
              onTap: _resetStep,
            ),
            const SizedBox(width: 8),
            button(
              icon: Icons.check_circle,
              label: _tx.s('verifyStep').toUpperCase(),
              color: _emerald,
              filled: true,
              onTap: _validateStep,
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------ stage ---
  /// The transformable stage (HTML `#stage-transform-container`).
  Widget _stage() {
    final panning = _panMode && !_locked;
    final view = _rt_MinWidthGate(
      minWidth: 240,
      child: LayoutBuilder(
        builder: (context, c) {
          final w = math.max(0.0, c.maxWidth - _contentPadding.horizontal);
          return SingleChildScrollView(
            key: ValueKey('scenario-$_step'),
            controller: _scroll,
            physics: panning ? const NeverScrollableScrollPhysics() : null,
            padding: _contentPadding,
            child: switch (_step) {
              1 => _s1View(w),
              2 => _s2View(w),
              _ => _s3View(w),
            },
          );
        },
      ),
    );
    return Container(
      key: _stageKey,
      color: _rt_Lab.canvas,
      child: ClipRect(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: panning ? (d) => setState(() => _pan += d.delta) : null,
          child: Transform.translate(
            offset: _pan,
            child: Transform.scale(
              scale: _zoom,
              child: DefaultTextStyle.merge(
                style: TextStyle(color: _rt_Lab.text),
                child: view,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------- shared building ---
  Widget _panelBox({
    required Widget child,
    double padding = 10,
    Color? borderColor,
    double radius = 16,
  }) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor ?? _rt_Lab.border),
        boxShadow: [
          BoxShadow(
            color: _rt_Lab.shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  /// Labels dimmed by the "Toggle Visual Labels" tool.
  Widget _label(Widget child) => AnimatedOpacity(
    opacity: _showLabels ? 1 : 0.2,
    duration: const Duration(milliseconds: 200),
    child: child,
  );

  Widget _panelTitle(
    IconData icon,
    String text,
    Color accent, {
    Widget? trailing,
  }) => Row(
    children: [
      Icon(icon, size: 12, color: _ink(accent)),
      const SizedBox(width: 4),
      Expanded(
        child: Text(
          text.toUpperCase(),
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: _ink(accent),
          ),
        ),
      ),
      ?trailing,
    ],
  );

  /// A draggable / tappable card (HTML `.bio-card`: `.selected`, `.is-placed`, `.is-dragging`).
  Widget _tokenFrame({
    required Widget child,
    required Color accent,
    bool selected = false,
    bool placed = false,
    bool dragging = false,
    double? width,
    EdgeInsets padding = const EdgeInsets.all(4),
    double radius = 12,
    Color? background,
  }) {
    final borderColor = selected || dragging
        ? _emerald
        : accent.withValues(alpha: placed ? 0.25 : 0.45);
    return AnimatedScale(
      scale: selected ? 1.04 : 1,
      duration: const Duration(milliseconds: 150),
      child: Opacity(
        opacity: placed && !dragging ? 0.4 : 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: width,
          padding: padding,
          decoration: BoxDecoration(
            color: background ?? _rt_Lab.surface,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: _emerald.withValues(alpha: 0.4),
                  blurRadius: 12,
                ),
              if (dragging)
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _draggable({
    required _DragToken token,
    required Widget Function(bool dragging) builder,
    required VoidCallback onTap,
  }) {
    return Draggable<_DragToken>(
      data: token,
      feedback: Material(
        type: MaterialType.transparency,
        child: Transform.rotate(
          angle: 0.02,
          child: Transform.scale(scale: 1.08, child: builder(true)),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.5, child: builder(false)),
      onDragStarted: _dragStarted,
      onDragUpdate: (d) => _dragPosition = d.globalPosition,
      onDragEnd: (_) => _stopAutoScroll(),
      onDraggableCanceled: (_, _) => _stopAutoScroll(),
      child: GestureDetector(onTap: onTap, child: builder(false)),
    );
  }

  Widget _dropZone({
    required String accepts,
    required void Function(String id) onDrop,
    required Widget Function(bool hovering) builder,
  }) {
    return DragTarget<_DragToken>(
      onWillAcceptWithDetails: (d) => d.data.type == accepts,
      onAcceptWithDetails: (d) => onDrop(d.data.id),
      builder: (context, candidates, _) => builder(candidates.isNotEmpty),
    );
  }

  /// Drop-zone frame with the HTML `.drag-over` highlight.
  BoxDecoration _zoneDecoration({
    required bool hover,
    required bool filled,
    required Color accent,
    required Color idleFill,
    double radius = 10,
    double width = 2,
  }) {
    return BoxDecoration(
      color: hover
          ? _wash(_emerald, 0.18)
          : (filled ? _wash(accent, 0.2) : idleFill),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: hover ? _emerald : (filled ? accent : _rt_Lab.borderStrong),
        width: width,
      ),
      boxShadow: hover
          ? [BoxShadow(color: _emerald.withValues(alpha: 0.3), blurRadius: 16)]
          : null,
    );
  }

  Widget _clearButton(VoidCallback onTap) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.all(2),
      child: Icon(Icons.close, size: 13, color: _rt_Lab.textMuted),
    ),
  );

  // ------------------------------------------ scenario 1: notochord gate ---
  Widget _s1View(double width) {
    final wide = width >= 500;
    final palette = _s1Palette(width);
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          palette,
          const SizedBox(height: 10),
          _s1LaneNonChordata(stretch: false),
          const SizedBox(height: 10),
          _s1LaneChordata(),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        palette,
        const SizedBox(height: 10),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 4, child: _s1LaneNonChordata(stretch: true)),
              const SizedBox(width: 10),
              Expanded(flex: 5, child: _s1LaneChordata()),
            ],
          ),
        ),
      ],
    );
  }

  /// Staging row with the 10 animal specimens.
  Widget _s1Palette(double width) {
    const gap = 6.0;
    final inner = width - 20;
    final cols = math.max(2, math.min(10, (inner + gap) ~/ 52));
    final cardWidth = ((inner - gap * (cols - 1)) / cols).floorToDouble();
    return _panelBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _panelTitle(Icons.pets, _tx.s('ui.speciesPaletteTitle'), _emerald),
          const SizedBox(height: 6),
          Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final id in _gateSpeciesKeys) _speciesCard(id, cardWidth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _speciesCard(String id, double width) {
    final token = _DragToken('s1_specimen', id);
    final name = _tx.s(id);
    Widget card(bool dragging) => _tokenFrame(
      width: width,
      accent: _rt_Lab.borderStrong,
      selected: _isSelected(token.type, id),
      placed: _s1Lanes[id] != null,
      dragging: dragging,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: _rt_Lab.overlay,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _BioArt(id, size: 30),
          ),
          const SizedBox(height: 3),
          SizedBox(
            height: 22,
            child: Center(
              child: _label(
                Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5,
                    fontWeight: FontWeight.w800,
                    color: _rt_Lab.text,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    return _draggable(
      token: token,
      builder: card,
      onTap: () => _select(token, 'selectS1', name),
    );
  }

  Widget _laneFrame({
    required Color accent,
    required bool hover,
    required Widget child,
  }) {
    return AnimatedScale(
      scale: hover ? 1.02 : 1,
      duration: const Duration(milliseconds: 200),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: hover ? _wash(_emerald, 0.18) : _glass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hover ? _emerald : accent.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: hover ? _emerald.withValues(alpha: 0.3) : _rt_Lab.shadow,
              blurRadius: hover ? 20 : 14,
            ),
          ],
        ),
        child: child,
      ),
    );
  }

  Widget _laneHeader(String badge, String label, String count, Color accent) {
    return Container(
      padding: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: accent.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: _wash(accent, 0.2),
              shape: BoxShape.circle,
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: _ink(accent),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w900,
                color: _ink(accent),
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: _wash(accent, 0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              count,
              style: TextStyle(
                fontSize: 9.5,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w800,
                color: _ink(accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _placedCount(int n, int total) => _tx
      .s('ui.placed')
      .replaceAll('{n}', '$n')
      .replaceAll('{total}', '$total');

  Widget _specimenBadge(
    String id,
    Color accent, {
    double art = 18,
    double font = 9.5,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      decoration: BoxDecoration(
        color: _wash(accent, 0.22),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BioArt(id, size: art),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              _tx.s(id),
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: font,
                fontWeight: FontWeight.w800,
                color: _ink(accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Lane ① Invertebrata (Non-chordata).
  Widget _s1LaneNonChordata({required bool stretch}) {
    final placed = [
      for (final k in _invertebrateKeys)
        if (_s1Lanes[k] == 'nonchordata') k,
    ];
    final box = Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _wash(_cyan, 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _cyan.withValues(alpha: 0.25)),
      ),
      child: placed.isEmpty
          ? Center(
              child: Text(
                _tx.s('ui.dropInverts'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontStyle: FontStyle.italic,
                  color: _rt_Lab.textFaint,
                ),
              ),
            )
          : Align(
              alignment: Alignment.topLeft,
              child: Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [for (final k in placed) _specimenBadge(k, _cyan)],
              ),
            ),
    );
    return _dropZone(
      accepts: 's1_specimen',
      onDrop: (id) => _assignS1Lane(id, 'nonchordata'),
      builder: (hover) => GestureDetector(
        onTap: () => _handleLaneClick('nonchordata'),
        child: _laneFrame(
          accent: _cyan,
          hover: hover,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _laneHeader(
                '①',
                _tx.s('gateLaneNonChordata'),
                _placedCount(placed.length, 8),
                _cyan,
              ),
              const SizedBox(height: 6),
              Text(
                _tx.s('ui.laneNonChordataNote'),
                style: TextStyle(
                  fontSize: 9.5,
                  fontStyle: FontStyle.italic,
                  color: _rt_Lab.textMuted,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              if (stretch) Expanded(child: box) else box,
            ],
          ),
        ),
      ),
    );
  }

  /// Lane ② Chordata with the Protochordata / Vertebrata platforms and the
  /// 5-group vertebrate sequence tray.
  Widget _s1LaneChordata() {
    final protoPlaced = _s1Lanes['amphioxus'] == 'chordata';
    final vertPlaced = _s1Lanes['vertebrate'] == 'chordata';
    final count = (protoPlaced ? 1 : 0) + (vertPlaced ? 1 : 0);
    return _dropZone(
      accepts: 's1_specimen',
      onDrop: (id) => _assignS1Lane(id, 'chordata'),
      builder: (hover) => GestureDetector(
        onTap: () => _handleLaneClick('chordata'),
        child: _laneFrame(
          accent: _emerald,
          hover: hover,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _laneHeader(
                '②',
                _tx.s('gateLaneChordata'),
                _placedCount(count, 2),
                _emerald,
              ),
              const SizedBox(height: 8),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _platform(
                        accent: _purple,
                        title: _tx.s('platProto'),
                        occupant: protoPlaced ? 'amphioxus' : null,
                        placeholder: _tx.s('ui.protoSlot'),
                        note: _tx.s('ui.protoNote'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _platform(
                        accent: _amber,
                        title: _tx.s('platVert'),
                        occupant: vertPlaced ? 'vertebrate' : null,
                        placeholder: _tx.s('ui.vertSlotPlat'),
                        note: _tx.s('ui.vertNote'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              _vertTray(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _platform({
    required Color accent,
    required String title,
    required String? occupant,
    required String placeholder,
    required String note,
  }) {
    return Container(
      constraints: const BoxConstraints(minHeight: 96),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: _wash(accent, 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.8,
              color: _ink(accent),
            ),
          ),
          const SizedBox(height: 4),
          if (occupant != null)
            _specimenBadge(occupant, accent, art: 26, font: 10)
          else
            Text(
              placeholder,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontStyle: FontStyle.italic,
                color: _ink(accent).withValues(alpha: 0.6),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            note,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 8,
              color: _ink(accent).withValues(alpha: 0.85),
              height: 1.25,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vertTray() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _amber.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 4),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: _rt_Lab.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _label(
                    Text(
                      _tx.s('vertTrayTitle').toUpperCase(),
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        color: _ink(_amber),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: _label(
                    Text(
                      _tx.s('vertTraySub'),
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w700,
                        color: _rt_Lab.textMuted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 5,
            runSpacing: 5,
            children: [for (final id in _vertClassKeys) _vertChip(id)],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (var i = 0; i < 5; i++) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(child: _vertSlot(i)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _vertChip(String id) {
    final token = _DragToken('vert_chip', id);
    final name = _tx.s(id);
    Widget chip(bool dragging) => _tokenFrame(
      accent: _amber,
      background: _wash(_amber, 0.1),
      radius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      selected: _isSelected(token.type, id),
      placed: _s1VertOrder.contains(id),
      dragging: dragging,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BioArt(id, size: 18),
          const SizedBox(width: 4),
          _label(
            Text(
              name,
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                color: _ink(_amber),
              ),
            ),
          ),
        ],
      ),
    );
    return _draggable(
      token: token,
      builder: chip,
      onTap: () => _select(token, 'selectVert', name),
    );
  }

  Widget _vertSlot(int slot) {
    final value = _s1VertOrder[slot];
    return _dropZone(
      accepts: 'vert_chip',
      onDrop: (id) => _placeVertChip(id, slot),
      builder: (hover) => GestureDetector(
        onTap: () => _handleVertSlotClick(slot),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 46,
          padding: const EdgeInsets.all(3),
          decoration: _zoneDecoration(
            hover: hover,
            filled: value != null,
            accent: _amber,
            idleFill: _rt_Lab.surface,
          ),
          child: value != null
              ? Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: _rt_Tw.amber400,
                            shape: BoxShape.circle,
                          ),
                          child: _label(
                            Text(
                              '${slot + 1}',
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                                color: _rt_Tw.slate950,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        _clearButton(() => _clearVertSlot(slot)),
                      ],
                    ),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: _label(
                            Text(
                              _tx.s(value),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: _ink(_amber),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _label(
                      Text(
                        '${slot + 1}',
                        style: TextStyle(
                          fontSize: 9.5,
                          fontFamily: 'monospace',
                          color: _rt_Lab.textFaint,
                        ),
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _label(
                        Text(
                          _tx.s('ui.slot').replaceAll('{n}', '${slot + 1}'),
                          style: TextStyle(
                            fontSize: 8,
                            fontStyle: FontStyle.italic,
                            color: _rt_Lab.textFaint,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ---------------------------------------- scenario 2: complexity ladder ---
  Widget _s2View(double width) {
    if (width >= 440) {
      const paletteWidth = 160.0;
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: paletteWidth,
              child: _s2Palette(paletteWidth - 16, columns: 1),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _s2Ladder(showArrow: width - paletteWidth - 10 >= 330),
            ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _s2Palette(width - 16, columns: 2),
        const SizedBox(height: 10),
        _s2Ladder(showArrow: width >= 330),
      ],
    );
  }

  Widget _s2Palette(double inner, {required int columns}) {
    const gap = 5.0;
    final cardWidth = ((inner - gap * (columns - 1)) / columns).floorToDouble();
    return _panelBox(
      padding: 8,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: _rt_Lab.border)),
            ),
            child: _panelTitle(
              Icons.pets,
              _tx.s('ui.s2PaletteTitle'),
              _emerald,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: gap,
            runSpacing: gap,
            children: [
              for (final id in _invertebrateKeys) _s2Card(id, cardWidth),
            ],
          ),
        ],
      ),
    );
  }

  Widget _s2Card(String id, double width) {
    final token = _DragToken('s2_specimen', id);
    final name = _tx.s(id);
    int? rung;
    for (var r = 1; r <= 8; r++) {
      if (_s2Rungs[r] == id) {
        rung = r;
        break;
      }
    }
    Widget card(bool dragging) => _tokenFrame(
      width: width,
      accent: _rt_Lab.borderStrong,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3),
      selected: _isSelected(token.type, id),
      placed: rung != null,
      dragging: dragging,
      child: Row(
        children: [
          _BioArt(id, size: 22),
          const SizedBox(width: 5),
          Expanded(
            child: _label(
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: _rt_Lab.text,
                ),
              ),
            ),
          ),
          if (rung != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: _wash(_emerald, 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: _label(
                Text(
                  _tx.s('ui.rungBadge').replaceAll('{n}', '$rung'),
                  style: TextStyle(
                    fontSize: 8,
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w900,
                    color: _ink(_emerald),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    return _draggable(
      token: token,
      builder: card,
      onTap: () => _select(token, 'selectS2', name),
    );
  }

  /// The 8-rung ladder (top = Echinodermata R8, bottom = Porifera R1).
  Widget _s2Ladder({required bool showArrow}) {
    return _panelBox(
      borderColor: _emerald.withValues(alpha: 0.3),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var r = 8; r >= 1; r--) ...[
                    _rung(r),
                    if (r > 1) const SizedBox(height: 5),
                  ],
                ],
              ),
            ),
            if (showArrow) ...[
              const SizedBox(width: 6),
              SizedBox(
                width: 22,
                child: Column(
                  children: [
                    const _BounceIcon(
                      icon: Icons.arrow_upward,
                      color: _cyan,
                      size: 16,
                    ),
                    Expanded(
                      child: Center(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: RotatedBox(
                            quarterTurns: 3,
                            child: Text(
                              _tx.s('ui.complexityArrow').toUpperCase(),
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 8.5,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1,
                                color: _ink(_cyan),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Icon(Icons.arrow_upward, size: 16, color: _cyan),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _rung(int rung) {
    final occupant = _s2Rungs[rung];
    final accent = _rungAccents[rung]!;
    return _dropZone(
      accepts: 's2_specimen',
      onDrop: (id) => _assignS2Rung(id, rung),
      builder: (hover) => GestureDetector(
        onTap: () => _handleRungClick(rung),
        child: AnimatedScale(
          scale: hover ? 1.02 : 1,
          duration: const Duration(milliseconds: 200),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 30),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration:
                _zoneDecoration(
                  hover: hover,
                  filled: occupant != null,
                  accent: _emerald,
                  idleFill: _wash(accent, 0.1),
                  radius: 14,
                ).copyWith(
                  border: Border.all(
                    color: hover || occupant != null
                        ? _rt_Tw.emerald400
                        : accent.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: occupant != null ? _emerald : _rt_Lab.overlay,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$rung',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: occupant != null
                          ? _rt_Tw.slate950
                          : _rt_Lab.textMuted,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  flex: 3,
                  child: Text(
                    _tx.s('s2_r${rung}_label'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: _ink(accent),
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                if (occupant != null) ...[
                  _BioArt(occupant, size: 20),
                  const SizedBox(width: 3),
                  Flexible(
                    flex: 2,
                    child: Text(
                      _tx.s(occupant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: _ink(_emerald),
                      ),
                    ),
                  ),
                  _clearButton(() => _clearS2Rung(rung)),
                ] else
                  Flexible(
                    flex: 2,
                    child: Text(
                      _tx.s('ui.dropSpecies'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 9,
                        fontStyle: FontStyle.italic,
                        color: _rt_Lab.textFaint,
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

  // ------------------------------------- scenario 3: diagnostic matcher ---
  Widget _s3View(double width) {
    const gap = 8.0;
    final cols = math.max(1, math.min(4, (width + gap) ~/ 136));
    final rows = <Widget>[];
    for (var i = 0; i < _pinSpecimens.length; i += cols) {
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < cols; j++) ...[
                if (j > 0) const SizedBox(width: gap),
                Expanded(
                  child: i + j < _pinSpecimens.length
                      ? _pinCard(_pinSpecimens[i + j])
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
      rows.add(const SizedBox(height: gap));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_s3Tokens(), const SizedBox(height: 10), ...rows],
    );
  }

  /// Compact phylum name tokens tray.
  Widget _s3Tokens() {
    return _panelBox(
      padding: 8,
      borderColor: _emerald.withValues(alpha: 0.4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 2,
            children: [
              Text(
                _tx.s('s3TokensTitle').toUpperCase(),
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                  color: _ink(_emerald),
                ),
              ),
              Text(
                _tx.s('ui.s3TokensNote'),
                style: TextStyle(fontSize: 8.5, color: _rt_Lab.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: [for (final pk in _phylumKeys) _phylumChip(pk)],
          ),
        ],
      ),
    );
  }

  Widget _phylumChip(String phylum) {
    final token = _DragToken('phylum_token', phylum);
    final name = _tx.s('phyla.$phylum');
    Widget chip(bool dragging) => _tokenFrame(
      accent: _emerald,
      background: _wash(_emerald, 0.1),
      radius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      selected: _isSelected(token.type, phylum),
      placed: _s3Pins.containsValue(phylum),
      dragging: dragging,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.sell, size: 12, color: _emerald),
          const SizedBox(width: 4),
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: _ink(_emerald),
            ),
          ),
        ],
      ),
    );
    return _draggable(
      token: token,
      builder: chip,
      onTap: () => _select(token, 'selectS3', name),
    );
  }

  Widget _pinCard((String, int) pin) {
    final (id, number) = pin;
    final assigned = _s3Pins[id];
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: assigned != null ? _wash(_emerald, 0.06) : _glass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: assigned != null
              ? _emerald.withValues(alpha: 0.5)
              : _rt_Lab.border,
        ),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 12)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: _rt_Lab.border)),
            ),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _wash(_emerald, 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '0$number',
                    style: TextStyle(
                      fontSize: 9,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.w900,
                      color: _ink(_emerald),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    _tx.s(id),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: _rt_Lab.text,
                    ),
                  ),
                ),
                _BioArt(id, size: 26),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: _rt_Lab.overlay,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _rt_Lab.border),
            ),
            child: Text(
              '"${_tx.s('s3_diagnostics.${_expectedPins[id]}')}"',
              style: TextStyle(
                fontSize: 9,
                color: _rt_Lab.textMuted,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Spacer(),
          const SizedBox(height: 6),
          _pinDropZone(id, number, assigned),
        ],
      ),
    );
  }

  Widget _pinDropZone(String id, int number, String? assigned) {
    return _dropZone(
      accepts: 'phylum_token',
      onDrop: (phylum) => _assignS3Pin(id, phylum),
      builder: (hover) => GestureDetector(
        onTap: () => _quickAssignS3Pin(id),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: _zoneDecoration(
            hover: hover,
            filled: assigned != null,
            accent: _emerald,
            idleFill: _rt_Lab.overlay,
          ),
          child: Row(
            children: assigned != null
                ? [
                    const Icon(Icons.check_circle, size: 13, color: _emerald),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        _tx.s('phyla.$assigned').toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w900,
                          color: _ink(_emerald),
                        ),
                      ),
                    ),
                    _clearButton(() => _clearS3Pin(id)),
                  ]
                : [
                    Expanded(
                      child: Text(
                        _tx.s('ui.dropToken'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 8.5,
                          fontStyle: FontStyle.italic,
                          color: _rt_Lab.textFaint,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _tx.s('ui.pinLabel').replaceAll('{n}', '$number'),
                      style: TextStyle(
                        fontSize: 8,
                        fontFamily: 'monospace',
                        color: _ink(_emerald).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
          ),
        ),
      ),
    );
  }
}
