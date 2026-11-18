// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// The Basis and need for classification
// Converted from Cl9S-Ch12-A1-BasisAndNeedForClassification.html (gsap/Draggable -> Flutter).

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
    'title': 'The Basis and need for classification',
    'subtitle': 'Class 9 • Diversity in Living Organism',
    'enterLab': 'ENTER VIRTUAL LAB',
    'moduleSel': 'Module Select',
    'settings': 'Settings',
    'visTheme': 'Visual Theme',
    'dark': 'Dark',
    'light': 'Light',
    'txtScale': 'Text Scaling',
    'missionReady': 'Mission Status',
    'btn_verify': 'VERIFY',
    'restart_lab': 'Restart Lab',
    'fb_success': 'Correct! Excellent job.',
    'fb_fail': 'Incorrect. Please try again.',
    'conclusion_title': 'Mission Complete!',
    'final_conclusion':
        'You have successfully completed all the classification exercises. You now understand how organisms can be grouped by different criteria like habitat and diet, and how classification aids in real-world conservation.',
    'what_to_do': 'What to do',
    'what_we_learn': 'What we learn',
    's1_title': '1. One Ecosystem, Many Groupings',
    's2_title': '2. Match the Criterion',
    's3_title': '3. Library Organization',
    's4_title': '4. Pakke Case File',
    'teacher_step1':
        "<p>1. Observe the massive full-screen Day/Night environment.</p><p>2. You have four animals in the tray. Drag the Owl, Eagle, Tiger, and Leopard into their correct Habitat/Time zones marked on the canvas.</p><p>3. Click the <strong>'VERIFY'</strong> button in the bottom right.</p><p>4. Next, click <strong>'Table 12.2 (Diet)'</strong> in the bottom left footer to group the exact same animals based on their diet instead.</p>",
    'learn_step1':
        'Organisms in the exact same physical ecosystem can be classified in completely different ways based on the criteria we choose (e.g., Habitat vs Diet).',
    'teacher_step2':
        '<p>1. Read the 7 distinct plaques on the central classification rack.</p><p>2. Drag each colorful criteria token (like Cell Structure or Nutrition) onto the dashed slot below the plaque that describes it correctly.</p><p>3. Once all 7 tokens are placed, click <strong>VERIFY</strong>.</p>',
    'learn_step2':
        'Scientists rely on a hierarchy of specific, objective characteristics to systematically classify all life forms accurately.',
    'teacher_step3':
        "<p>1. Observe the 6 scattered 'Benefit' cards.</p><p>2. Drag each benefit onto one of the dashed slots on the bookshelf to organize them neatly.</p><p>3. Click <strong>VERIFY</strong> to confirm your organization.</p>",
    'learn_step3':
        'Classification is essential. It simplifies the study of vast biodiversity and helps us trace evolutionary paths.',
    'teacher_step4':
        '<p>1. Read the case study panel about the Pakke Tiger Reserve.</p><p>2. Reflect on how biological classification affects real-world conservation.</p><p>3. Fill out the three short-answer questions in the provided text boxes and click <strong>VERIFY</strong>.</p>',
    'learn_step4':
        'Real-world conservation, like protecting the Hornbill, relies entirely on our ability to correctly classify and survey wildlife populations.',
    'hud_s1_t1': 'Sort the animals into Air/Day, Water/Day, or Tree/Night.',
    'hud_s1_t2': "Sort the animals into Carnivore or 'Not in this group'. (All 4 animals here are carnivores!)",
    'hud_s2': 'Drag the 7 criteria tokens to their matching plaques.',
    'hud_s3': 'Drag the 6 benefits to the bookshelf slots.',
    'hud_s4': 'Read the text and fill out the discussion questions.',
    'air_day': 'Air • Day',
    'water_day': 'Water • Day',
    'tree_night': 'Tree • Night',
    'carnivore': 'Carnivore',
    'not_in_group': 'Not in this group',
    'table12_2': 'Table 12.2 Grouping',
    'owl': 'Owl',
    'eagle': 'Eagle',
    'tiger': 'Tiger',
    'leopard': 'Leopard',
    'l1': 'Prokaryotic/Eukaryotic',
    'l2': 'Cellular nature',
    'l3': 'Mode of nutrition',
    'l4': 'External features',
    'l5': 'Internal structure',
    'l6': 'Evolution',
    'l7': 'Habitat',
    'c1': 'Cell Structure',
    'c2': 'Body Organization',
    'c3': 'Nutrition',
    'c4': 'Morphology',
    'c5': 'Anatomy',
    'c6': 'Phylogeny',
    'c7': 'Ecology',
    'benefit_1': 'Benefit 1',
    'benefit_2': 'Benefit 2',
    'benefit_3': 'Benefit 3',
    'benefit_4': 'Benefit 4',
    'benefit_5': 'Benefit 5',
    'benefit_6': 'Benefit 6',
    's3_1': 'Makes study easy',
    's3_2': 'Evolutionary relations',
    's3_3': 'Provides knowledge',
    's3_4': 'Helps identification',
    's3_5': 'Shows relationship',
    's3_6': 'Essential for ecology',
    's4_text':
        'The Pakke Tiger Reserve in Arunachal Pradesh is home to a rich diversity of flora and fauna, including the endangered Hornbill. Conservationists rely on accurate classification to track populations, understand ecological roles, and implement targeted protection strategies.',
    's4_q1_lbl': 'Q1. Why is classification important for conservation?',
    's4_q2_lbl': 'Q2. What role do Hornbills play in their ecosystem?',
    's4_q3_lbl': 'Q3. How can local communities help?',
    // Shown in English in every language by the HTML (hard-coded, outside
    // its I18N table). Kept identical in 'hi' so both maps have the same keys.
    'ui': {
      'btn_t1': 'Table 12.1 (Habitat)',
      'btn_t2': 'Table 12.2 (Diet)',
      'verifying': 'VERIFYING...',
      'placeholder_q1': 'Type your answer here... (Any answer is accepted)',
      'placeholder': 'Type your answer here...',
    },
  },
  'hi': {
    'title': 'वर्गीकरण का आधार और आवश्यकता',
    'subtitle': 'कक्षा 9 • जीवों में विविधता',
    'enterLab': 'वर्चुअल लैब में प्रवेश करें',
    'moduleSel': 'मॉड्यूल का चयन करें',
    'settings': 'सेटिंग्स',
    'visTheme': 'दृश्य थीम',
    'dark': 'डार्क',
    'light': 'लाइट',
    'txtScale': 'टेक्स्ट स्केलिंग',
    'missionReady': 'मिशन स्थिति',
    'btn_verify': 'सत्यापित करें',
    'restart_lab': 'लैब पुनः आरंभ करें',
    'fb_success': 'सही! बहुत बढ़िया।',
    'fb_fail': 'गलत। कृपया पुनः प्रयास करें।',
    'conclusion_title': 'मिशन पूरा हुआ!',
    'final_conclusion': 'आपने सभी वर्गीकरण अभ्यास सफलतापूर्वक पूरे कर लिए हैं।',
    'what_to_do': 'क्या करना है',
    'what_we_learn': 'हम क्या सीखते हैं',
    's1_title': '1. एक पारिस्थितिकी तंत्र, कई समूह',
    's2_title': '2. मानदंड का मिलान करें',
    's3_title': '3. पुस्तकालय संगठन',
    's4_title': '4. पक्के केस फ़ाइल',
    'teacher_step1':
        "<p>1. फुल-स्क्रीन दिन/रात का माहौल देखें।</p><p>2. उल्लू, चील, बाघ और तेंदुए को उनके सही आवास में खींचें।</p><p>3. 'सत्यापित करें' पर क्लिक करें।</p>",
    'learn_step1': 'एक ही आवास में जीवों को उनके आहार जैसे अन्य मानदंडों के आधार पर अलग-अलग समूहीकृत किया जा सकता है।',
    'teacher_step2':
        '<p>1. रैक पर 7 पट्टिकाओं को पढ़ें।</p><p>2. प्रत्येक रंगीन मानदंड टोकन को उस पट्टिका पर खींचें जो इसका सही वर्णन करती है।</p><p>3. पूरा होने पर सत्यापित करें।</p>',
    'learn_step2': 'वैज्ञानिक जीवों को व्यवस्थित रूप से वर्गीकृत करने के लिए विविध विशेषताओं का उपयोग करते हैं।',
    'teacher_step3':
        '<p>1. वर्गीकरण के 6 बिखरे हुए लाभों का निरीक्षण करें।</p><p>2. प्रत्येक लाभ को व्यवस्थित करने के लिए बुकशेल्फ़ पर खींचें।</p><p>3. सत्यापित करें।</p>',
    'learn_step3': 'वर्गीकरण हमें जीवन की विविध किस्मों का आसानी से अध्ययन करने में मदद करता है।',
    'teacher_step4':
        '<p>1. पक्के टाइगर रिजर्व के बारे में केस स्टडी पढ़ें।</p><p>2. चिंतन करें कि वर्गीकरण संरक्षण को कैसे प्रभावित करता है।</p><p>3. प्रश्नों के उत्तर दें।</p>',
    'learn_step4': 'उचित वर्गीकरण संरक्षणवादियों को जैव विविधता की प्रभावी ढंग से रक्षा करने में मदद करते हैं।',
    'hud_s1_t1': 'जानवरों को वायु/दिन, जल/दिन, या पेड़/रात में छाँटें।',
    'hud_s1_t2': "जानवरों को मांसाहारी या 'इस समूह में नहीं' में छाँटें।",
    'hud_s2': '7 मानदंड टोकन को उनके मेल खाने वाले पट्टिकाओं पर खींचें।',
    'hud_s3': '6 लाभों को बुकशेल्फ़ स्लॉट में खींचें।',
    'hud_s4': 'पाठ पढ़ें और चर्चा के प्रश्न भरें।',
    'air_day': 'वायु • दिन',
    'water_day': 'जल • दिन',
    'tree_night': 'पेड़ • रात',
    'carnivore': 'मांसाहारी',
    'not_in_group': 'इस समूह में नहीं',
    'table12_2': 'तालिका 12.2 समूहन',
    'owl': 'उल्लू',
    'eagle': 'चील',
    'tiger': 'बाघ',
    'leopard': 'तेंदुआ',
    'l1': 'प्रोकैरियोटिक',
    'l2': 'कोशिकीय प्रकृति',
    'l3': 'पोषण',
    'l4': 'बाहरी विशेषताएं',
    'l5': 'आंतरिक संरचना',
    'l6': 'विकासवादी',
    'l7': 'आवास',
    'c1': 'कोशिका संरचना',
    'c2': 'संगठन',
    'c3': 'पोषण',
    'c4': 'आकारिकी',
    'c5': 'शरी रचना',
    'c6': 'जातिवृत्त',
    'c7': 'पारिस्थितिकी',
    'benefit_1': 'लाभ 1',
    'benefit_2': 'लाभ 2',
    'benefit_3': 'लाभ 3',
    'benefit_4': 'लाभ 4',
    'benefit_5': 'लाभ 5',
    'benefit_6': 'लाभ 6',
    's3_1': 'अध्ययन आसान',
    's3_2': 'विकासवादी संबंध',
    's3_3': 'ज्ञान प्रदान',
    's3_4': 'पहचान में मदद',
    's3_5': 'संबंध दर्शाता',
    's3_6': 'पारिस्थितिकी',
    's4_text':
        'अरुणाचल प्रदेश में पक्के टाइगर रिजर्व लुप्तप्राय हॉर्नबिल सहित वनस्पतियों और जीवों की समृद्ध विविधता का घर है।',
    's4_q1_lbl': 'Q1. संरक्षण के लिए वर्गीकरण क्यों महत्वपूर्ण है?',
    's4_q2_lbl': 'Q2. हॉर्नबिल अपने पारिस्थितिकी तंत्र में क्या भूमिका निभाते हैं?',
    's4_q3_lbl': 'Q3. स्थानीय समुदाय कैसे मदद कर सकते हैं?',
    'ui': {
      'btn_t1': 'Table 12.1 (Habitat)',
      'btn_t2': 'Table 12.2 (Diet)',
      'verifying': 'VERIFYING...',
      'placeholder_q1': 'Type your answer here... (Any answer is accepted)',
      'placeholder': 'Type your answer here...',
    },
  },
});

// --- Palette (the HTML :root variables, dark theme) ---
const _accent = _rt_Tw.green500; // --accent
const _accentHover = _rt_Tw.green600; // --accent-hover
const _borderVar = _rt_Tw.slate700; // --border

// Canvas insets keeping the scene clear of the HUD (top), the verify footer
// (bottom) and the shell's vertical zoom toolbar (right).
const double _kInsetTop = 66;
const double _kInsetBottom = 56;
const double _kInsetLeft = 8;
const double _kInsetRight = 58;

// Scenes 1-3 are laid out in a virtual box (at least 640 x 300) that matches
// the canvas aspect ratio and is scaled to fit with a FittedBox. The HTML used
// fixed px on a large desktop canvas, which does not fit a 640 x 360 phone.
const double _kVirtualHeight = 300;
const double _kMinVirtualWidth = 640;

const _s1Animals = ['owl', 'eagle', 'tiger', 'leopard'];

// The HTML loads the animal photos from the web; this page must work offline
// and ship no assets, so they are drawn as emoji.
const _s1Emoji = {'owl': '🦉', 'eagle': '🦅', 'tiger': '🐅', 'leopard': '🐆'};

// Phosphor icons of the criteria tokens -> nearest Material icons.
const _s2Icons = <String, (IconData, Color)>{
  'c1': (Icons.grid_view_rounded, _rt_Tw.green500), // ph-squares-four
  'c2': (Icons.account_tree, _rt_Tw.amber500), // ph-tree-structure
  'c3': (Icons.eco, _rt_Tw.teal500), // ph-leaf
  'c4': (Icons.visibility, _rt_Tw.pink500), // ph-eye
  'c5': (Icons.biotech, _rt_Tw.purple500), // ph-dna
  'c6': (Icons.call_split, _rt_Tw.blue500), // ph-git-branch
  'c7': (Icons.public, _rt_Tw.cyan500), // ph-globe-hemisphere-west
};

/// One draggable token (HTML `.draggable`). Its [zone] is the single source
/// of truth for verification (the HTML kept a parallel `state.placements`).
class _Token {
  _Token(this.id, this.scene);

  final String id;

  /// Scene (= step) the token belongs to: 1, 2 or 3.
  final int scene;

  /// Drop zone holding the token, or null.
  String? zone;

  /// Centre, as a fraction of the scene box, where it was dropped outside any
  /// zone (GSAP leaves it there). Null = at its home position.
  Offset? loose;

  /// Order it entered a multi-token zone, so the row stays stable.
  int placedOrder = 0;

  /// Book tilt in degrees (scene 3).
  double tilt = 0;

  /// Slide duration of the next move; 0 = jump (while dragging / resizing).
  int slideMs = 0;
  int slideSeq = 0;
}

/// A drop zone (HTML `.dropzone`) in scene-box coordinates.
class _Zone {
  const _Zone(this.id, this.rect, {this.multi = false, this.labelTop = 0, this.labelBottom = 0});

  final String id;
  final Rect rect;

  /// Holds any number of tokens (the HTML 'carnivore' / 'outside' lists).
  final bool multi;

  /// Label bands inside the zone edges that tokens should not cover.
  final double labelTop;
  final double labelBottom;

  Rect get content => Rect.fromLTRB(rect.left, rect.top + labelTop, rect.right, rect.bottom - labelBottom);
}

/// Geometry of the current scene, shared by painting and hit-testing.
class _SceneLayout {
  _SceneLayout({
    required this.size,
    required this.tokenSize,
    required this.zones,
    required this.homes,
    required this.decor,
  });

  final Size size;
  final Size tokenSize;

  /// Zones that accept drops in the current scene / mode (`getHitZone`).
  final List<_Zone> zones;

  /// Token start positions (centres).
  final Map<String, Offset> homes;

  /// Rectangles of the scenery (tray, rack, plaques, shelves...).
  final Map<String, Rect> decor;
}

class Cl9Ch12A1BasisNeedClassificationPage extends StatefulWidget {
  const Cl9Ch12A1BasisNeedClassificationPage({super.key});

  @override
  State<Cl9Ch12A1BasisNeedClassificationPage> createState() => _Cl9Ch12A1BasisNeedClassificationPageState();
}

class _Cl9Ch12A1BasisNeedClassificationPageState extends State<Cl9Ch12A1BasisNeedClassificationPage> {
  final _rt_ShellController _shell = _rt_ShellController();
  final GlobalKey _sceneKey = GlobalKey();
  final math.Random _rng = math.Random();

  // --- ACTIVITY STATE (HTML `state`) ---
  int _step = 1;
  String _s1Mode = 't1';
  final Map<String, _Token> _tokens = {};
  final List<Offset> _bookScatter = [];
  final List<TextEditingController> _answers = List.generate(3, (_) => TextEditingController());
  int _placeSeq = 0;

  // Drag in progress (GSAP Draggable).
  String? _dragId;
  Offset _dragCenter = Offset.zero;
  Offset _grab = Offset.zero;
  String? _hoverZone;
  _SceneLayout? _layout;

  // Verify / feedback (`verifyStep`, `#inst-feedback`).
  bool _verifying = false;
  bool _advancing = false;
  bool? _feedbackOk;
  int _feedbackSeq = 0;
  int _advanceToken = 0;
  int _confettiSeq = 0;

  // Canvas tools (pan mode, labels, zoom).
  bool _labelsVisible = true;
  bool _panMode = false;
  double _zoom = 1;
  Offset _pan = Offset.zero;
  int _viewAnimMs = 300;

  // Timers (setTimeout) -- cancelled on restart / dispose.
  final List<Timer> _timers = [];
  int _gen = 0;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _initTokens();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    for (final c in _answers) {
      c.dispose();
    }
    super.dispose();
  }

  /// setTimeout that dies with Restart / dispose.
  void _after(int ms, VoidCallback fn) {
    final g = _gen;
    late final Timer timer;
    timer = Timer(Duration(milliseconds: ms), () {
      _timers.remove(timer);
      if (!mounted || g != _gen) return;
      fn();
    });
    _timers.add(timer);
  }

  // ------------------------------------------------------------- state ---
  /// HTML `initScenes`: 4 animals, 7 criteria, 6 scattered books.
  void _initTokens() {
    _tokens
      ..clear()
      ..addAll({for (final a in _s1Animals) a: _Token(a, 1)})
      ..addAll({for (var i = 1; i <= 7; i++) 'c$i': _Token('c$i', 2)})
      ..addAll({for (var i = 1; i <= 6; i++) 's3_$i': _Token('s3_$i', 3)..tilt = _randomTilt()});
    _bookScatter
      ..clear()
      ..addAll(List.generate(6, (_) => Offset(_rng.nextDouble() - 0.5, _rng.nextDouble() - 0.5)));
    _placeSeq = 0;
  }

  double _randomTilt() => (_rng.nextDouble() - 0.5) * 30;

  Iterable<_Token> get _sceneTokens => _tokens.values.where((t) => t.scene == _step);

  void _slide(_Token t, int ms) {
    t.slideMs = ms;
    final seq = ++t.slideSeq;
    _after(ms + 60, () {
      if (t.slideSeq == seq && t.slideMs != 0) setState(() => t.slideMs = 0);
    });
  }

  /// Step selector (HTML `setStep`, the `#scenario-select` onchange).
  void _onSelectStep(int s) {
    if (s == _step) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      // A manual switch cancels a pending auto-advance.
      if (_advancing) _feedbackOk = null;
      _advanceToken++;
      _advancing = false;
    });
    _goToStep(s);
  }

  void _goToStep(int s) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _step = s;
      _dragId = null;
      _hoverZone = null;
    });
  }

  /// HTML `toggleS1Mode`: switch Table 12.1 / 12.2 and reset the tokens.
  void _toggleS1Mode(String mode) {
    setState(() => _s1Mode = mode);
    _rt_playSfx(_rt_Sfx.click);
    _resetCurrentPhase();
  }

  /// HTML `resetCurrentPhase`: clear the placements and tween the tokens of
  /// the current scene back to where they started (rotation is kept).
  void _resetCurrentPhase() {
    _rt_playSfx(_rt_Sfx.click);
    if (_step > 3) return; // the HTML has no placements for step 4
    setState(() {
      _dragId = null;
      _hoverZone = null;
      for (final t in _sceneTokens) {
        t.zone = null;
        t.loose = null;
        _slide(t, 500);
      }
    });
  }

  // ------------------------------------------------------------ verify ---
  bool _isCurrentStepCorrect() {
    String? holder(String zone) {
      for (final t in _sceneTokens) {
        if (t.zone == zone) return t.id;
      }
      return null;
    }

    switch (_step) {
      case 1:
        if (_s1Mode == 't1') return holder('tree_night') == 'owl' && holder('air_day') == 'eagle';
        // Accept all 4 as carnivores, because they are!
        return _sceneTokens.where((t) => t.zone == 'carnivore').length == 4;
      case 2:
        return [for (var i = 1; i <= 7; i++) 'c$i'].every((id) => holder(id) == id);
      case 3:
        return [for (var i = 1; i <= 6; i++) 's3_$i'].every((id) => holder(id) != null);
      default:
        // Any non-empty answer is accepted for the free-form case study.
        return _answers.every((c) => c.text.trim().isNotEmpty);
    }
  }

  /// HTML `verifyStep`: 800 ms "verifying", then feedback; a correct answer
  /// shows confetti and advances after 2.5 s (success popup after step 4).
  void _verifyStep() {
    if (_verifying || _advancing) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _verifying = true);
    _after(800, () {
      final ok = _isCurrentStepCorrect();
      final seq = ++_feedbackSeq;
      setState(() {
        _verifying = false;
        _feedbackOk = ok;
      });
      if (ok) {
        _rt_playSfx(_rt_Sfx.correct);
        final token = ++_advanceToken;
        final verified = _step;
        setState(() {
          _advancing = true;
          _confettiSeq++;
        });
        _after(2500, () {
          if (token != _advanceToken) return;
          setState(() {
            _advancing = false;
            if (seq == _feedbackSeq) _feedbackOk = null;
          });
          if (verified < 4) {
            _goToStep(verified + 1);
            _rt_playSfx(_rt_Sfx.click);
          } else {
            _showCompletion();
          }
        });
      } else {
        _rt_playSfx(_rt_Sfx.wrong);
        _after(3000, () {
          if (seq == _feedbackSeq) setState(() => _feedbackOk = null);
        });
      }
    });
  }

  Future<void> _showCompletion() async {
    await _shell.showSuccess(
      title: _tx.s('conclusion_title'),
      message: _tx.s('final_conclusion'),
      buttonLabel: _tx.s('restart_lab'),
      color: _accentHover,
      onConfirm: () {
        if (mounted) _restart(); // a tap outside just closes the popup
      },
    );
  }

  /// HTML `resetLab` (page reload): everything back to the start.
  void _restart() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _gen++;
    FocusManager.instance.primaryFocus?.unfocus();
    for (final c in _answers) {
      c.clear();
    }
    setState(() {
      _step = 1;
      _s1Mode = 't1';
      _initTokens();
      _dragId = null;
      _hoverZone = null;
      _verifying = false;
      _advancing = false;
      _feedbackOk = null;
      _feedbackSeq++;
      _advanceToken++;
      _confettiSeq = 0;
      _labelsVisible = true;
      _panMode = false;
      _zoom = 1;
      _pan = Offset.zero;
      _viewAnimMs = 0;
    });
  }

  // ------------------------------------------------------------- tools ---
  void _togglePanMode() => setState(() => _panMode = !_panMode);

  void _toggleLabels() => setState(() => _labelsVisible = !_labelsVisible);

  /// HTML `zoomCanvas(±0.2)`, clamped to 0.5..2.5.
  void _zoomBy(double delta) => setState(() {
    _viewAnimMs = 300;
    _zoom = (_zoom + delta).clamp(0.5, 2.5);
  });

  /// HTML `resetCanvas`.
  void _resetView() => setState(() {
    _viewAnimMs = 500;
    _zoom = 1;
    _pan = Offset.zero;
  });

  // ------------------------------------------------------------ layout ---
  _SceneLayout _layoutFor(Size size) => switch (_step) {
    1 => _layoutScene1(size),
    2 => _layoutScene2(size),
    _ => _layoutScene3(size),
  };

  /// Scene 1: tray of animals under three habitat zones (Table 12.1) or the
  /// diet panel with 'carnivore' / 'not in this group' (Table 12.2).
  _SceneLayout _layoutScene1(Size size) {
    final w = size.width;
    final h = size.height;
    const tokenW = 72.0;
    const tokenH = 92.0;
    const gap = 14.0;
    const trayW = 4 * tokenW + 5 * gap;
    const trayH = tokenH + 16;
    final tray = Rect.fromLTWH((w - trayW) / 2, h - 6 - trayH, trayW, trayH);
    final homes = <String, Offset>{
      for (var i = 0; i < _s1Animals.length; i++)
        _s1Animals[i]: Offset(tray.left + gap + tokenW / 2 + i * (tokenW + gap), tray.top + 3 + (trayH - 11) / 2),
    };
    final decor = <String, Rect>{'tray': tray};
    final List<_Zone> zones;
    if (_s1Mode == 't1') {
      const bandTop = 8.0;
      final bandBottom = tray.top - 8;
      final bandH = bandBottom - bandTop;
      final zh = math.min(bandH * 0.78, 240.0);
      final zw = (w * 0.22).clamp(130.0, 240.0);
      _Zone zone(String id, double cx, double top) =>
          _Zone(id, Rect.fromLTWH(cx - zw / 2, top, zw, zh), labelBottom: 28);
      zones = [
        zone('air_day', w * 0.13, bandTop),
        zone('water_day', w * 0.37, bandBottom - zh),
        zone('tree_night', w * 0.74, bandTop + (bandH - zh) / 2),
      ];
    } else {
      final panel = Rect.fromLTRB(w * 0.06, 6, w * 0.94, tray.top - 6);
      decor['panel'] = panel;
      final innerW = panel.width - 32;
      final carnW = math.min(innerW * 0.58, 500.0);
      final outW = math.min(innerW * 0.34, 300.0);
      final left = panel.center.dx - (carnW + 20 + outW) / 2;
      final top = panel.top + 44;
      final zh = panel.bottom - 10 - top;
      zones = [
        _Zone('carnivore', Rect.fromLTWH(left, top, carnW, zh), multi: true, labelTop: 24),
        _Zone('outside', Rect.fromLTWH(left + carnW + 20, top, outW, zh), multi: true, labelTop: 24),
      ];
    }
    return _SceneLayout(size: size, tokenSize: const Size(tokenW, tokenH), zones: zones, homes: homes, decor: decor);
  }

  /// Scene 2: classification rack -- 7 plaques with slots on the top shelf,
  /// the 7 criteria tokens on the bottom shelf. (The HTML's 4 + 3 plaque rows
  /// on a 700 px rack do not fit a landscape phone, so they form one row.)
  _SceneLayout _layoutScene2(Size size) {
    final w = size.width;
    final h = size.height;
    const border = 6.0;
    const pad = 10.0;
    const labelH = 30.0;
    final rackW = math.min(w * 0.94, 980.0);
    final innerW = rackW - 2 * border - 2 * pad;
    final cell = math.min(math.min(innerW / 7, (h - 86) / 2), 120.0);
    final plaqueW = cell - 6;
    final slot = plaqueW - 8;
    final tokenS = slot - 6;
    final plaqueH = labelH + 6 + slot + 6;
    final rackH = 2 * border + 2 * pad + plaqueH + 12 + 14 + tokenS + 12;
    final rack = Rect.fromLTWH((w - rackW) / 2, (h - rackH) / 2, rackW, rackH);
    final left = rack.left + border + pad + (innerW - 7 * cell) / 2;
    final top = rack.top + border + pad;
    final shelfW = rackW - 2 * border;
    final decor = <String, Rect>{
      'rack': rack,
      'shelf1': Rect.fromLTWH(rack.left + border, top + plaqueH, shelfW, 12),
      'shelf2': Rect.fromLTWH(rack.left + border, top + plaqueH + 26 + tokenS, shelfW, 12),
    };
    final zones = <_Zone>[];
    final homes = <String, Offset>{};
    for (var i = 0; i < 7; i++) {
      final plaque = Rect.fromLTWH(left + i * cell + 3, top, plaqueW, plaqueH);
      decor['l${i + 1}'] = plaque;
      zones.add(_Zone('c${i + 1}', Rect.fromLTWH(plaque.left + 4, plaque.top + labelH + 6, slot, slot)));
      homes['c${i + 1}'] = Offset(plaque.center.dx, top + plaqueH + 12 + 14 + tokenS / 2);
    }
    return _SceneLayout(size: size, tokenSize: Size(tokenS, tokenS), zones: zones, homes: homes, decor: decor);
  }

  /// Scene 3: bookshelf with 2 x 3 slots on the right, the 6 benefit books
  /// scattered (random offset and tilt) on the left.
  _SceneLayout _layoutScene3(Size size) {
    final w = size.width;
    final h = size.height;
    const frame = 8.0;
    const board = 14.0;
    final shelf = Rect.fromLTRB(w * 0.40, 6, w * 0.97, h - 6);
    final inner = shelf.deflate(frame);
    final rowH = inner.height / 2;
    final slotH = math.min(math.min(rowH - board - 14, 130.0), (inner.width / 3 - 12) * 150 / 110);
    final slotW = slotH * 110 / 150;
    final bookH = slotH - 8;
    final bookW = bookH * 100 / 140;
    final zones = <_Zone>[];
    final decor = <String, Rect>{'bookshelf': shelf};
    for (var r = 0; r < 2; r++) {
      final rowBottom = inner.top + rowH * (r + 1);
      decor['board$r'] = Rect.fromLTWH(inner.left, rowBottom - board, inner.width, board);
      for (var c = 0; c < 3; c++) {
        final cx = inner.left + inner.width * (c + 0.5) / 3;
        final bottom = rowBottom - board - 5;
        zones.add(_Zone('s3_${r * 3 + c + 1}', Rect.fromLTWH(cx - slotW / 2, bottom - slotH, slotW, slotH)));
      }
    }
    final area = Rect.fromLTRB(w * 0.02, 6, w * 0.38, h - 6);
    final cols = area.width >= 3 * bookW * 1.05 ? 3 : 2;
    final rows = (6 / cols).ceil();
    final cellW = area.width / cols;
    final cellH = area.height / rows;
    final homes = <String, Offset>{};
    for (var i = 0; i < 6; i++) {
      final jitter = i < _bookScatter.length ? _bookScatter[i] : Offset.zero;
      homes['s3_${i + 1}'] = Offset(
        area.left + cellW * (i % cols + 0.5) + jitter.dx * math.max(0.0, cellW - bookW),
        area.top + cellH * (i ~/ cols + 0.5) + jitter.dy * math.max(0.0, cellH - bookH),
      );
    }
    return _SceneLayout(size: size, tokenSize: Size(bookW, bookH), zones: zones, homes: homes, decor: decor);
  }

  _Zone? _zoneById(_SceneLayout l, String? id) {
    if (id == null) return null;
    for (final z in l.zones) {
      if (z.id == id) return z;
    }
    return null;
  }

  /// HTML `getHitZone`: the zone containing the token centre (last match wins).
  _Zone? _hitZone(Offset center, _SceneLayout l) {
    _Zone? best;
    for (final z in l.zones) {
      if (z.rect.contains(center)) best = z;
    }
    return best;
  }

  Offset _centerOf(_Token t, _SceneLayout l) {
    if (t.id == _dragId) return _dragCenter;
    final zone = _zoneById(l, t.zone);
    if (zone != null) {
      final c = zone.content;
      if (!zone.multi) return c.center;
      // Several tokens share the zone: lay them out in a row (the HTML
      // scattered them randomly by +-40 px, so they overlapped).
      final members = _sceneTokens.where((o) => o.zone == zone.id).toList()
        ..sort((a, b) => a.placedOrder.compareTo(b.placedOrder));
      final n = members.length;
      final k = members.indexOf(t);
      final tw = l.tokenSize.width;
      final step = n > 1 ? math.min(tw + 6, (c.width - 12 - tw) / (n - 1)) : 0.0;
      return Offset(c.center.dx - step * (n - 1) / 2 + step * k, c.center.dy);
    }
    final loose = t.loose;
    if (loose != null) return Offset(loose.dx * l.size.width, loose.dy * l.size.height);
    return l.homes[t.id] ?? l.size.center(Offset.zero);
  }

  // -------------------------------------------------------------- drag ---
  RenderBox? get _sceneBox {
    final ro = _sceneKey.currentContext?.findRenderObject();
    return ro is RenderBox && ro.hasSize ? ro : null;
  }

  void _onTokenDragStart(_Token t, Offset global) {
    final box = _sceneBox;
    final l = _layout;
    if (_dragId != null || box == null || l == null || t.scene != _step) return;
    final p = box.globalToLocal(global);
    final c = _centerOf(t, l);
    _rt_playSfx(_rt_Sfx.tap); // HTML 'pickup'
    setState(() {
      _dragId = t.id;
      _grab = p - c;
      _dragCenter = c;
      _hoverZone = _hitZone(c, l)?.id;
      t.slideMs = 0;
      if (t.scene == 3) t.tilt = 0; // books straighten when picked up
    });
  }

  void _onTokenDragUpdate(_Token t, Offset global) {
    final box = _sceneBox;
    final l = _layout;
    if (_dragId != t.id || box == null || l == null) return;
    final p = box.globalToLocal(global) - _grab;
    final hw = l.tokenSize.width / 2;
    final hh = l.tokenSize.height / 2;
    final c = Offset(p.dx.clamp(hw, l.size.width - hw), p.dy.clamp(hh, l.size.height - hh));
    setState(() {
      _dragCenter = c;
      _hoverZone = _hitZone(c, l)?.id;
    });
  }

  /// HTML `onDragEnd`: snap into the zone under the token centre, or leave it
  /// where it was dropped.
  void _onTokenDragEnd(_Token t) {
    final l = _layout;
    if (_dragId != t.id) return;
    if (l == null) {
      setState(() => _dragId = null);
      return;
    }
    final hit = _hitZone(_dragCenter, l);
    setState(() {
      for (final o in _sceneTokens) {
        if (o != t) _slide(o, 250);
      }
      if (hit != null) {
        if (!hit.multi) {
          // One token per slot: a token already there goes back home (the
          // HTML overwrote the slot but left the old token on top of it).
          for (final o in _sceneTokens) {
            if (o != t && o.zone == hit.id) {
              o.zone = null;
              o.loose = null;
            }
          }
        }
        t.zone = hit.id;
        t.loose = null;
        t.placedOrder = ++_placeSeq;
        _slide(t, 200);
      } else {
        t.zone = null;
        t.loose = Offset(_dragCenter.dx / l.size.width, _dragCenter.dy / l.size.height);
        t.slideMs = 0;
        if (t.scene == 3) t.tilt = _randomTilt(); // scatter the book again
      }
      _dragId = null;
      _hoverZone = null;
    });
    _rt_playSfx(_rt_Sfx.pop); // HTML 'drop'
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
        builder: (context, lang) => _rt_ActivityShell(
          controller: _shell,
          title: _tx.s('title'),
          subtitle: _tx.s('subtitle'),
          theme: const _rt_ShellTheme(
            accent: _accentHover,
            headerGradient: [_rt_Tw.slate900, Color(0xFF14532D)],
            headerSubtitleColor: _rt_Tw.green400,
          ),
          intro: _rt_IntroConfig(
            title: _tx.s('title'),
            subtitle: _tx.s('subtitle'),
            buttonLabel: _tx.s('enterLab'),
            icon: Icons.menu_book,
            buttonIcon: Icons.rocket_launch,
          ),
          onRestart: _restart,
          onZoomIn: () => _zoomBy(0.2),
          onZoomOut: () => _zoomBy(-0.2),
          onResetView: _resetView,
          toolbarExtras: [
            _toolButton(key: const ValueKey('btn-pan'), icon: Icons.pan_tool, active: _panMode, onTap: _togglePanMode),
            const SizedBox(height: 4),
            _toolButton(
              key: const ValueKey('btn-labels'),
              icon: _labelsVisible ? Icons.label : Icons.label_off,
              active: false,
              onTap: _toggleLabels,
            ),
          ],
          sidebarTop: _moduleSelect(),
          tabs: [_rt_ShellTab(label: _tx.s('what_to_do'), icon: Icons.play_circle_fill, builder: (_) => _guideTab())],
          canvasBackground: const Color(0xFF0F172A),
          canvas: _canvas(),
          canvasOverlays: [Positioned.fill(child: LayoutBuilder(builder: (context, box) => _overlays(box.biggest)))],
        ),
      ),
    );
  }

  Widget _toolButton({Key? key, required IconData icon, required bool active, required VoidCallback onTap}) {
    return InkResponse(
      key: key,
      radius: 22,
      onTap: () {
        _rt_playSfx(_rt_Sfx.click);
        onTap();
      },
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(color: active ? _accentHover : _rt_Lab.surface, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: active ? Colors.white : _rt_Lab.textMuted),
      ),
    );
  }

  // --- SIDEBAR (#teacher-board) ---
  Widget _moduleSelect() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_SectionLabel(_tx.s('moduleSel'), icon: Icons.science, color: _accent),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _rt_Lab.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _rt_Lab.borderStrong, width: 2),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                key: const ValueKey('scenario-select'),
                value: _step,
                isExpanded: true,
                dropdownColor: _rt_Lab.surface,
                borderRadius: BorderRadius.circular(12),
                iconEnabledColor: _rt_Lab.textMuted,
                style: TextStyle(color: _rt_Lab.text, fontSize: 13.5, fontWeight: FontWeight.w700),
                items: [
                  for (var i = 1; i <= 4; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Text(_tx.s('s${i}_title'), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) _onSelectStep(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// `#sb-desc` ("What to do") and `#sb-learn` ("What we learn").
  Widget _guideTab() {
    final muted = TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: _rt_Lab.textMuted, height: 1.45);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_SectionLabel(_tx.s('what_to_do'), icon: Icons.play_circle_fill, color: _accent),
          ..._htmlParagraphs(_tx.s('teacher_step$_step'), muted),
          const SizedBox(height: 8),
          _rt_InfoCard(
            title: _tx.s('what_we_learn'),
            body: _tx.s('learn_step$_step'),
            icon: Icons.lightbulb,
            color: _rt_Tw.blue500,
          ),
        ],
      ),
    );
  }

  // --- CANVAS (#canvas-section) ---
  Widget _canvas() {
    return LayoutBuilder(
      builder: (context, box) {
        final area = Rect.fromLTRB(_kInsetLeft, _kInsetTop, box.maxWidth - _kInsetRight, box.maxHeight - _kInsetBottom);
        return Stack(
          children: [
            // Fixed backgrounds (#bg-scene-N): not affected by pan / zoom.
            Positioned.fill(child: CustomPaint(painter: _SceneBackdropPainter(_step))),
            if (area.width >= 80 && area.height >= 80) Positioned.fromRect(rect: area, child: _viewport(area.size)),
          ],
        );
      },
    );
  }

  /// `#pan-zoom-container`: zoom (toolbar) and drag-to-pan in pan mode.
  Widget _viewport(Size area) {
    final content = IgnorePointer(ignoring: _panMode, child: _step == 4 ? _caseFile() : _virtualScene(area));
    return GestureDetector(
      behavior: _panMode ? HitTestBehavior.opaque : HitTestBehavior.deferToChild,
      onPanStart: _panMode ? (_) => setState(() => _viewAnimMs = 0) : null,
      onPanUpdate: _panMode ? (d) => setState(() => _pan += d.delta) : null,
      child: AnimatedContainer(
        duration: Duration(milliseconds: _viewAnimMs),
        curve: Curves.easeOutCubic,
        transformAlignment: Alignment.center,
        transform: Matrix4.translationValues(_pan.dx, _pan.dy, 0)..multiply(Matrix4.diagonal3Values(_zoom, _zoom, 1)),
        child: content,
      ),
    );
  }

  Widget _virtualScene(Size area) {
    final aspect = area.width / area.height;
    var vw = _kVirtualHeight * aspect;
    var vh = _kVirtualHeight;
    if (vw < _kMinVirtualWidth) {
      vw = _kMinVirtualWidth;
      vh = vw / aspect;
    }
    final layout = _layoutFor(Size(vw, vh));
    _layout = layout; // read by the drag handlers
    final scenery = switch (_step) {
      1 => _scene1(layout),
      2 => _scene2(layout),
      _ => _scene3(layout),
    };
    return FittedBox(
      child: SizedBox(
        key: _sceneKey,
        width: vw,
        height: vh,
        child: Stack(clipBehavior: Clip.none, children: [...scenery, ..._tokenWidgets(layout)]),
      ),
    );
  }

  Widget _label(Widget child) =>
      AnimatedOpacity(opacity: _labelsVisible ? 1 : 0, duration: const Duration(milliseconds: 150), child: child);

  /// Text that wraps inside [width] and scales down when it is still too big.
  Widget _wrapFit(String text, double width, TextStyle style, {int maxLines = 2}) => FittedBox(
    fit: BoxFit.scaleDown,
    child: SizedBox(
      width: math.max(1.0, width),
      child: Text(text, textAlign: TextAlign.center, maxLines: maxLines, overflow: TextOverflow.ellipsis, style: style),
    ),
  );

  Widget _zoneBox(
    _Zone z, {
    required Color border,
    required Color fill,
    required Color hotFill,
    bool glow = false,
    double stroke = 3,
    double radius = 14,
    Widget? child,
  }) {
    final hot = _hoverZone == z.id; // HTML `.dropzone.highlight`
    return Positioned.fromRect(
      rect: z.rect,
      child: CustomPaint(
        painter: _DashedZonePainter(
          color: hot ? _accent : border,
          fill: hot ? hotFill : fill,
          strokeWidth: stroke,
          radius: radius,
          glow: hot && glow,
        ),
        child: child ?? const SizedBox.expand(),
      ),
    );
  }

  // --- SCENE 1: ECOSYSTEM GROUPING ---
  List<Widget> _scene1(_SceneLayout l) {
    final widgets = <Widget>[Positioned.fromRect(rect: l.decor['tray']!, child: _tray())];
    if (_s1Mode == 't1') {
      for (final z in l.zones) {
        final night = z.id == 'tree_night';
        widgets.add(
          _zoneBox(
            z,
            border: Colors.white.withValues(alpha: 0.8),
            fill: switch (z.id) {
              'air_day' => Colors.white.withValues(alpha: 0.1),
              'water_day' => _accent.withValues(alpha: 0.1),
              _ => Colors.black.withValues(alpha: 0.3),
            },
            hotFill: _accent.withValues(alpha: 0.3),
            glow: true,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 0, 6, 5),
                child: _label(_pill(_tx.s(z.id), dark: night)),
              ),
            ),
          ),
        );
      }
    } else {
      // #s1-t2-overlay (Table 12.2 grouping).
      widgets.add(Positioned.fromRect(rect: l.decor['panel']!, child: _dietPanel()));
      for (final z in l.zones) {
        final carnivore = z.id == 'carnivore';
        final color = carnivore ? _accent : _rt_Tw.red500;
        widgets.add(
          _zoneBox(
            z,
            border: color,
            fill: color.withValues(alpha: 0.1),
            hotFill: _accent.withValues(alpha: 0.3),
            glow: true,
            stroke: 4,
            radius: 16,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(6, 3, 6, 0),
                child: _label(
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      _tx.s(carnivore ? 'carnivore' : 'not_in_group'),
                      style: TextStyle(fontSize: carnivore ? 17 : 14, fontWeight: FontWeight.w900, color: color),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }
    return widgets;
  }

  Widget _pill(String text, {required bool dark}) => FittedBox(
    fit: BoxFit.scaleDown,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: dark ? Colors.black.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: dark ? Colors.white : _rt_Tw.slate800),
      ),
    ),
  );

  /// #s1-tray (thick bottom edge drawn as an outer frame).
  Widget _tray() => Container(
    padding: const EdgeInsets.fromLTRB(3, 3, 3, 8),
    decoration: BoxDecoration(
      color: _borderVar,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 24, offset: const Offset(0, 12))],
    ),
    child: DecoratedBox(
      decoration: BoxDecoration(color: const Color(0xF21E293B), borderRadius: BorderRadius.circular(8)),
    ),
  );

  Widget _dietPanel() => Container(
    alignment: Alignment.topCenter,
    padding: const EdgeInsets.fromLTRB(12, 5, 12, 0),
    decoration: BoxDecoration(
      color: const Color(0xF20F172A),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: _borderVar, width: 3),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.8),
          blurRadius: 40,
          spreadRadius: -10,
          offset: const Offset(0, 24),
        ),
      ],
    ),
    child: SizedBox(
      height: 32,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Container(
          padding: const EdgeInsets.only(bottom: 2),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: _accent, width: 3)),
          ),
          child: Text(
            _tx.s('table12_2'),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white, height: 1.1),
          ),
        ),
      ),
    ),
  );

  // --- SCENE 2: MATCH THE CRITERION ---
  List<Widget> _scene2(_SceneLayout l) {
    return [
      Positioned.fromRect(
        rect: l.decor['rack']!,
        child: Container(
          decoration: BoxDecoration(
            color: _rt_Tw.slate700.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _rt_Tw.slate600, width: 6),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.6), blurRadius: 40, offset: const Offset(0, 20)),
            ],
          ),
        ),
      ),
      for (final key in ['shelf1', 'shelf2']) Positioned.fromRect(rect: l.decor[key]!, child: _shelfBar()),
      for (var i = 1; i <= 7; i++)
        Positioned.fromRect(rect: l.decor['l$i']!, child: _plaque('l$i', l.decor['l$i']!.width)),
      // The HTML slot border is white/40 on a white plaque (invisible), so the
      // dashes use slate-400 here.
      for (final z in l.zones)
        _zoneBox(
          z,
          border: _rt_Tw.slate400,
          fill: Colors.transparent,
          hotFill: _accent.withValues(alpha: 0.2),
          radius: 10,
        ),
    ];
  }

  Widget _shelfBar() => DecoratedBox(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(6),
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_rt_Tw.slate400, _rt_Tw.slate500, _rt_Tw.slate500],
        stops: [0, 0.2, 1],
      ),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 10, offset: const Offset(0, 6))],
    ),
  );

  Widget _plaque(String key, double width) => Container(
    alignment: Alignment.topCenter,
    padding: const EdgeInsets.fromLTRB(4, 3, 4, 0),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFF8FAFC), Color(0xFFE2E8F0)],
      ),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: _rt_Tw.slate300, width: 2),
      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 6, offset: const Offset(0, 4))],
    ),
    child: SizedBox(
      height: 26,
      child: Center(
        child: _label(
          _wrapFit(
            _tx.s(key),
            width - 12,
            const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w900, color: _rt_Tw.slate800, height: 1.1),
            maxLines: 3,
          ),
        ),
      ),
    ),
  );

  // --- SCENE 3: LIBRARY ORGANIZATION ---
  List<Widget> _scene3(_SceneLayout l) {
    return [
      Positioned.fromRect(
        rect: l.decor['bookshelf']!,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF5C3A21),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF3E2723), width: 8),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.55), blurRadius: 24, offset: const Offset(0, 12)),
            ],
          ),
        ),
      ),
      for (final key in ['board0', 'board1'])
        Positioned.fromRect(
          rect: l.decor[key]!,
          child: const DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFF4E342E),
              border: Border(
                top: BorderSide(color: Color(0xFF6D4C41), width: 2),
                bottom: BorderSide(color: Color(0xFF3E2723), width: 3),
              ),
            ),
          ),
        ),
      for (final z in l.zones)
        _zoneBox(
          z,
          border: Colors.white.withValues(alpha: 0.4),
          fill: Colors.transparent,
          hotFill: _accent.withValues(alpha: 0.3),
          radius: 6,
        ),
    ];
  }

  // --- TOKENS ---
  List<Widget> _tokenWidgets(_SceneLayout l) {
    final tokens = _sceneTokens.toList();
    // The dragged token paints last (HTML `.is-dragging` z-index 999).
    final ordered = [...tokens.where((t) => t.id != _dragId), ...tokens.where((t) => t.id == _dragId)];
    return [for (final t in ordered) _positionedToken(t, l)];
  }

  Widget _positionedToken(_Token t, _SceneLayout l) {
    final c = _centerOf(t, l);
    final s = l.tokenSize;
    final dragging = t.id == _dragId;
    return AnimatedPositioned(
      key: ValueKey(t.id),
      duration: Duration(milliseconds: dragging ? 0 : t.slideMs),
      curve: Curves.easeOutCubic,
      left: c.dx - s.width / 2,
      top: c.dy - s.height / 2,
      width: s.width,
      height: s.height,
      child: GestureDetector(
        dragStartBehavior: DragStartBehavior.down,
        onPanStart: (d) => _onTokenDragStart(t, d.globalPosition),
        onPanUpdate: (d) => _onTokenDragUpdate(t, d.globalPosition),
        onPanEnd: (_) => _onTokenDragEnd(t),
        child: AnimatedRotation(
          turns: t.tilt / 360,
          duration: const Duration(milliseconds: 200),
          child: AnimatedScale(
            scale: dragging ? 1.1 : 1,
            duration: const Duration(milliseconds: 100),
            child: Opacity(
              opacity: dragging ? 0.95 : 1,
              child: switch (t.scene) {
                1 => _animalCard(t, s, dragging),
                2 => _criterionToken(t, s, dragging),
                _ => _book(t, s, dragging),
              },
            ),
          ),
        ),
      ),
    );
  }

  List<BoxShadow> _tokenShadow(bool dragging) => [
    BoxShadow(
      color: Colors.black.withValues(alpha: dragging ? 0.6 : 0.3),
      blurRadius: dragging ? 24 : 12,
      offset: Offset(0, dragging ? 16 : 6),
    ),
  ];

  /// `.s1-token`: animal card (photo -> emoji) with its name.
  Widget _animalCard(_Token t, Size s, bool dragging) => Container(
    padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: _rt_Tw.slate300, width: 2.5),
      boxShadow: _tokenShadow(dragging),
    ),
    child: Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: _rt_Tw.slate100.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(6),
            ),
            padding: const EdgeInsets.all(4),
            child: FittedBox(child: Text(_s1Emoji[t.id] ?? '', style: const TextStyle(fontSize: 40))),
          ),
        ),
        SizedBox(
          height: 18,
          child: Center(
            child: _label(
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  _tx.s(t.id),
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: _rt_Tw.slate800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  /// `.s2-token`: criterion with its coloured icon.
  Widget _criterionToken(_Token t, Size s, bool dragging) {
    final (icon, color) = _s2Icons[t.id] ?? (Icons.help_outline, _rt_Tw.slate500);
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 5, 4, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _rt_Tw.slate300, width: 2.5),
        boxShadow: _tokenShadow(dragging),
      ),
      child: Column(
        children: [
          Expanded(
            flex: 5,
            child: FittedBox(child: Icon(icon, color: color)),
          ),
          const SizedBox(height: 2),
          Expanded(
            flex: 4,
            child: Center(
              child: _label(
                _wrapFit(
                  _tx.s(t.id),
                  s.width - 13,
                  const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: _rt_Tw.slate800, height: 1.1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// `.s3-token`: a book with a darker spine.
  Widget _book(_Token t, Size s, bool dragging) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: const Color(0xFFE0BB8B),
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(3), right: Radius.circular(9)),
      border: Border.all(color: Colors.black.withValues(alpha: 0.4), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: dragging ? 0.7 : 0.6),
          blurRadius: dragging ? 20 : 12,
          offset: dragging ? const Offset(8, 12) : const Offset(5, 5),
        ),
      ],
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(width: s.width * 0.14, color: const Color(0xFF8D6E63)),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
              child: _label(
                _wrapFit(
                  _tx.s(t.id),
                  s.width * 0.86 - 11,
                  const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF3E2723), height: 1.15),
                  maxLines: 4,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );

  // --- SCENE 4: PAKKE CASE FILE ---
  Widget _caseFile() {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _rt_Tw.slate300, width: 3),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 40, offset: const Offset(0, 20)),
          ],
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 6),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: _rt_Tw.slate300, width: 2)),
                ),
                child: Text(
                  _tx.s('s4_title'),
                  style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: _rt_Tw.amber600),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                _tx.s('s4_text'),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _rt_Tw.slate700, height: 1.5),
              ),
              const SizedBox(height: 14),
              for (var i = 0; i < 3; i++) ...[
                Text(
                  _tx.s('s4_q${i + 1}_lbl'),
                  style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900, color: _accent),
                ),
                const SizedBox(height: 4),
                _answerField(i),
                if (i < 2) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _answerField(int i) {
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c, width: 2),
    );
    return TextField(
      key: ValueKey('s4_q${i + 1}'),
      controller: _answers[i],
      minLines: 2,
      maxLines: 4,
      keyboardType: TextInputType.multiline,
      cursorColor: _accentHover,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _rt_Tw.slate800),
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: _rt_Tw.slate100,
        hintText: _tx.s(i == 0 ? 'ui.placeholder_q1' : 'ui.placeholder'),
        hintStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: _rt_Tw.slate400),
        contentPadding: const EdgeInsets.all(10),
        enabledBorder: border(_rt_Tw.slate300),
        focusedBorder: border(_accent),
      ),
    );
  }

  // --- OVERLAYS: HUD, footer (mode toggles, reset, verify), feedback ---
  Widget _overlays(Size size) {
    // First frames are laid out in portrait (before the landscape switch).
    if (size.width < 240 || size.height < 160) return const SizedBox.shrink();
    final narrow = size.width < 600;
    return Stack(
      children: [
        Positioned(
          top: 8,
          left: 72,
          right: 72,
          child: IgnorePointer(child: Center(child: _hud())),
        ),
        Positioned(left: 8, right: 10, bottom: 8, child: _footer(narrow, size.width - 18)),
        if (_feedbackOk != null)
          Positioned(
            left: 8,
            right: 64, // left of the shell's vertical toolbar
            bottom: _step == 1 && narrow ? 100 : 62,
            child: IgnorePointer(
              child: Align(alignment: Alignment.bottomRight, child: _feedback(_feedbackOk!)),
            ),
          ),
        if (_confettiSeq > 0)
          Positioned.fill(
            child: IgnorePointer(child: _ConfettiBurst(key: ValueKey(_confettiSeq))),
          ),
      ],
    );
  }

  /// `#hud-container`: Mission Status + current instruction.
  Widget _hud() {
    final instruction = _step == 1 ? _tx.s('hud_s1_$_s1Mode') : _tx.s('hud_s$_step');
    return Container(
      constraints: const BoxConstraints(maxWidth: 600),
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 30, offset: const Offset(0, 8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Opacity(
            opacity: 0.7,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info, size: 11, color: _rt_Lab.text),
                const SizedBox(width: 5),
                Flexible(
                  child: Text(
                    _tx.s('missionReady').toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: _rt_Lab.text,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            instruction,
            key: const ValueKey('hud-instruction'),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: _accent, height: 1.2),
          ),
        ],
      ),
    );
  }

  /// `#canvas-footer`: Table 12.1 / 12.2 toggles (step 1), reset, VERIFY.
  Widget _footer(bool narrow, double width) {
    // VERIFY may use what is left after the reset button and a minimum for
    // the toggles; it scales down beyond that (long labels, large text).
    final verifyMax = math.max(90.0, width - 8 - (_step <= 3 ? 52 : 0) - (_step == 1 ? 96 : 0));
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomLeft,
            child: _step == 1
                ? FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.bottomLeft,
                    child: _modeToggles(vertical: narrow),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        const SizedBox(width: 8),
        if (_step <= 3) ...[_phaseResetButton(), const SizedBox(width: 8)],
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: verifyMax),
          child: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.bottomRight, child: _verifyButton()),
        ),
      ],
    );
  }

  Widget _modeToggles({required bool vertical}) {
    Widget button(String mode, String label) {
      final active = _s1Mode == mode;
      return Material(
        color: active ? _accent : _rt_Lab.base,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          key: ValueKey('btn-$mode'),
          borderRadius: BorderRadius.circular(10),
          onTap: () => _toggleS1Mode(mode),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: active ? _accent : Colors.transparent, width: 2),
            ),
            child: Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: active ? Colors.white : _rt_Lab.textMuted,
              ),
            ),
          ),
        ),
      );
    }

    final t1 = button('t1', _tx.s('ui.btn_t1'));
    final t2 = button('t2', _tx.s('ui.btn_t2'));
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: _rt_Lab.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _rt_Lab.border, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 20)],
      ),
      child: vertical
          ? Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [t1, const SizedBox(height: 5), t2],
            )
          : Row(mainAxisSize: MainAxisSize.min, children: [t1, const SizedBox(width: 6), t2]),
    );
  }

  /// Resets the placements of the current phase (HTML `resetCurrentPhase`,
  /// which the HTML only reached through the Table 12.1 / 12.2 toggles).
  Widget _phaseResetButton() => Material(
    color: _rt_Lab.surface,
    elevation: 4,
    shape: CircleBorder(side: BorderSide(color: _rt_Lab.border, width: 2)),
    child: InkWell(
      key: const ValueKey('btn-reset-phase'),
      customBorder: const CircleBorder(),
      onTap: _resetCurrentPhase,
      child: SizedBox(width: 44, height: 44, child: Icon(Icons.restart_alt, size: 22, color: _rt_Lab.textMuted)),
    ),
  );

  Widget _verifyButton() {
    final enabled = !_verifying && !_advancing;
    return Material(
      color: enabled ? _accent : _accent.withValues(alpha: 0.7),
      borderRadius: BorderRadius.circular(14),
      elevation: 6,
      shadowColor: _accent.withValues(alpha: 0.6),
      child: InkWell(
        key: const ValueKey('btn-verify'),
        borderRadius: BorderRadius.circular(14),
        onTap: enabled ? _verifyStep : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _rt_Tw.green400.withValues(alpha: 0.5), width: 2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_verifying)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
              else
                const Icon(Icons.check_circle, size: 22, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                _verifying ? _tx.s('ui.verifying') : _tx.s('btn_verify'),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// `#inst-feedback`.
  Widget _feedback(bool ok) {
    final box = Container(
      constraints: const BoxConstraints(minWidth: 180, maxWidth: 280),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: ok ? _rt_Tw.emerald500 : _rt_Tw.red600,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ok ? _rt_Tw.emerald400 : _rt_Tw.red400, width: 2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 18)],
      ),
      child: Text(
        _tx.s(ok ? 'fb_success' : 'fb_fail'),
        key: const ValueKey('inst-feedback'),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Colors.white),
      ),
    );
    return ok ? box : _Pulse(child: box); // `animate-pulse` on failure
  }
}

/// Renders the HTML's `<p>...</p>` step text (with `<strong>`) as paragraphs,
/// so the translation strings can stay verbatim.
List<Widget> _htmlParagraphs(String html, TextStyle style) {
  final paragraphs = [for (final m in RegExp(r'<p>(.*?)</p>', dotAll: true).allMatches(html)) m.group(1)!];
  if (paragraphs.isEmpty) paragraphs.add(html);
  final bold = style.copyWith(fontWeight: FontWeight.w800, color: _rt_Lab.text);
  final strong = RegExp(r'<(strong|b)>(.*?)</\1>', dotAll: true);
  String plain(String s) => s.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').replaceAll('&amp;', '&');
  List<InlineSpan> spans(String p) {
    final out = <InlineSpan>[];
    var i = 0;
    for (final m in strong.allMatches(p)) {
      if (m.start > i) out.add(TextSpan(text: plain(p.substring(i, m.start))));
      out.add(TextSpan(text: plain(m.group(2)!), style: bold));
      i = m.end;
    }
    if (i < p.length) out.add(TextSpan(text: plain(p.substring(i))));
    return out;
  }

  return [
    for (final p in paragraphs)
      Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text.rich(TextSpan(style: style, children: spans(p))),
      ),
  ];
}

/// Dashed rounded-rect drop zone (CSS `border: dashed`), with the green
/// `.highlight` glow.
class _DashedZonePainter extends CustomPainter {
  const _DashedZonePainter({
    required this.color,
    required this.fill,
    this.strokeWidth = 3,
    this.radius = 14,
    this.glow = false,
  });

  final Color color;
  final Color fill;
  final double strokeWidth;
  final double radius;
  final bool glow;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius((Offset.zero & size).deflate(strokeWidth / 2), Radius.circular(radius));
    if (glow) {
      canvas.drawRRect(
        rrect,
        Paint()
          ..color = _accent.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 15),
      );
    }
    canvas.drawRRect(rrect, Paint()..color = fill);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final dash = strokeWidth * 3;
    final gap = strokeWidth * 2;
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, math.min(d + dash, metric.length)), stroke);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedZonePainter old) =>
      old.color != color ||
      old.fill != fill ||
      old.strokeWidth != strokeWidth ||
      old.radius != radius ||
      old.glow != glow;
}

/// The fixed scene backgrounds (`#bg-scene-1..4`), drawn from the HTML's
/// gradients and inline SVGs.
class _SceneBackdropPainter extends CustomPainter {
  const _SceneBackdropPainter(this.step);

  final int step;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    switch (step) {
      case 1:
        _dayNight(canvas, size);
      case 2:
        canvas.drawRect(full, Paint()..color = _rt_Tw.slate800);
      case 3:
        canvas.drawRect(full, Paint()..color = const Color(0xFF2D180D));
      default:
        canvas.drawRect(full, Paint()..color = const Color(0xFF0F172A));
        _island(canvas, size);
    }
  }

  /// HTML px were laid out on a ~900 px tall desktop canvas.
  static double _unit(Size size) => size.height / 900;

  static Path _poly(Offset o, double s, List<double> xy) {
    final path = Path()..moveTo(o.dx + xy[0] * s, o.dy + xy[1] * s);
    for (var i = 2; i < xy.length; i += 2) {
      path.lineTo(o.dx + xy[i] * s, o.dy + xy[i + 1] * s);
    }
    return path..close();
  }

  static void _shape(Canvas canvas, Path path, Color fill, {Color? stroke, double strokeWidth = 0}) {
    canvas.drawPath(path, Paint()..color = fill);
    if (stroke != null) {
      canvas.drawPath(
        path,
        Paint()
          ..color = stroke
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth,
      );
    }
  }

  void _dayNight(Canvas canvas, Size size) {
    final u = _unit(size);
    final half = size.width / 2;
    final h = size.height;
    final day = Rect.fromLTWH(0, 0, half, h);
    final night = Rect.fromLTWH(half, 0, size.width - half, h);
    canvas.drawRect(
      day,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7DD3FC), Color(0xFFBBF7D0)],
        ).createShader(day),
    );
    canvas.drawRect(
      night,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF020617), Color(0xFF1E293B)],
        ).createShader(night),
    );
    // Sun: 150 px disc with an 80 px glow, top 10% / left 15% of the day half.
    final sunR = 75 * u;
    final sun = Offset(half * 0.15 + sunR, h * 0.10 + sunR);
    canvas.drawCircle(
      sun,
      sunR,
      Paint()
        ..color = const Color(0xFFFEF08A)
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, 40 * u),
    );
    canvas.drawCircle(sun, sunR, Paint()..color = const Color(0xFFFEF08A));
    // Day tree: 300 x 400 svg, bottom 25%, left 10%.
    _tree(canvas, Rect.fromLTWH(half * 0.10, h * 0.75 - 400 * u, 300 * u, 400 * u), night: false);
    // Moon: the crescent left by box-shadow -25px 15px on a 120 px circle.
    final moonR = 60 * u;
    final moon = Offset(size.width - night.width * 0.15 - moonR, h * 0.10 + moonR);
    final crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: moon + Offset(-25 * u, 15 * u), radius: moonR)),
      Path()..addOval(Rect.fromCircle(center: moon, radius: moonR)),
    );
    canvas.drawPath(crescent, Paint()..color = const Color(0xFFE2E8F0));
    // Night tree: 250 x 350 svg at 70% opacity, bottom 20%, left 20%.
    _tree(canvas, Rect.fromLTWH(half + night.width * 0.20, h * 0.80 - 350 * u, 250 * u, 350 * u), night: true);
    canvas.drawRect(Rect.fromLTWH(half, 0, 2, h), Paint()..color = Colors.white.withValues(alpha: 0.1));
  }

  /// The inline tree SVGs (viewBox 0 0 100 100, centred in their box).
  void _tree(Canvas canvas, Rect box, {required bool night}) {
    final s = math.min(box.width, box.height) / 100;
    final o = Offset(box.left + (box.width - 100 * s) / 2, box.top + (box.height - 100 * s) / 2);
    if (night) {
      canvas.saveLayer(box.inflate(4 * s), Paint()..color = Colors.black.withValues(alpha: 0.7));
      _shape(
        canvas,
        _poly(o, s, const [50, 10, 80, 90, 20, 90]),
        const Color(0xFF064E3B),
        stroke: const Color(0xFF065F46),
        strokeWidth: 2 * s,
      );
      canvas.drawRect(
        Rect.fromLTWH(o.dx + 45 * s, o.dy + 90 * s, 10 * s, 20 * s),
        Paint()..color = const Color(0xFF451A03),
      );
      canvas.restore();
    } else {
      _shape(
        canvas,
        _poly(o, s, const [50, 10, 80, 90, 20, 90]),
        const Color(0xFF15803D),
        stroke: const Color(0xFF166534),
        strokeWidth: 2 * s,
      );
      _shape(
        canvas,
        _poly(o, s, const [50, 30, 90, 100, 10, 100]),
        const Color(0xFF16A34A),
        stroke: const Color(0xFF15803D),
        strokeWidth: 2 * s,
      );
      canvas.drawRect(
        Rect.fromLTWH(o.dx + 42 * s, o.dy + 95 * s, 16 * s, 20 * s),
        Paint()..color = const Color(0xFF78350F),
      );
    }
  }

  /// Scene 4: isometric grass block (1200 x 800 svg, viewBox 200 x 100,
  /// centred 100 px below the middle).
  void _island(Canvas canvas, Size size) {
    final u = _unit(size);
    final s = 6 * u;
    final o = Offset(size.width / 2 - 600 * u, size.height / 2 - 200 * u);
    _shape(
      canvas,
      _poly(o, s, const [100, 20, 190, 55, 100, 90, 10, 55]),
      const Color(0xFF4ADE80),
      stroke: const Color(0xFF22C55E),
      strokeWidth: s,
    );
    _shape(canvas, _poly(o, s, const [10, 55, 100, 90, 100, 105, 10, 70]), const Color(0xFF78350F));
    _shape(canvas, _poly(o, s, const [100, 90, 190, 55, 190, 70, 100, 105]), const Color(0xFF451A03));
  }

  @override
  bool shouldRepaint(_SceneBackdropPainter old) => old.step != step;
}

/// Tailwind `animate-pulse` (opacity 1 -> 0.5 -> 1).
class _Pulse extends StatefulWidget {
  const _Pulse({required this.child});

  final Widget child;

  @override
  State<_Pulse> createState() => _PulseState();
}

class _PulseState extends State<_Pulse> with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(vsync: this, duration: const Duration(seconds: 1))
    ..repeat(reverse: true);
  late final Animation<double> _opacity = Tween<double>(
    begin: 1,
    end: 0.5,
  ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeInOut));

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _opacity, child: widget.child);
}

/// One confetti piece.
class _Fetti {
  _Fetti(math.Random rng, double spread, this.color)
    : angle = -math.pi / 2 + (rng.nextDouble() - 0.5) * spread,
      velocity = 45 * 0.5 + rng.nextDouble() * 45,
      spin = rng.nextDouble() * math.pi * 2,
      wobble = rng.nextDouble() * 10;

  /// Launch direction (screen radians; -pi/2 is straight up).
  final double angle;

  /// Start speed in px per 60 fps tick (canvas-confetti `startVelocity` 45).
  final double velocity;
  final double spin;
  final double wobble;
  final Color color;
}

/// Stand-in for canvas-confetti's
/// `confetti({particleCount: 150, spread: 80, origin: {y: 0.8},
/// colors: ['#10b981', '#f8fafc']})`, played on every correct VERIFY.
class _ConfettiBurst extends StatefulWidget {
  const _ConfettiBurst({super.key});

  @override
  State<_ConfettiBurst> createState() => _ConfettiBurstState();
}

class _ConfettiBurstState extends State<_ConfettiBurst> with SingleTickerProviderStateMixin {
  static const int _ticks = 200; // canvas-confetti default lifetime
  static const List<Color> _colors = [Color(0xFF10B981), Color(0xFFF8FAFC)];

  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: _ticks * 1000 ~/ 60),
  );
  late final List<_Fetti> _fetti;

  @override
  void initState() {
    super.initState();
    final rng = math.Random();
    _fetti = List.generate(150, (i) => _Fetti(rng, 80 * math.pi / 180, _colors[i % _colors.length]));
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CustomPaint(painter: _ConfettiPainter(_anim, _fetti), size: Size.infinite);
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.anim, this.fetti) : super(repaint: anim);

  final Animation<double> anim;
  final List<_Fetti> fetti;

  @override
  void paint(Canvas canvas, Size size) {
    final t = anim.value;
    if (t <= 0 || t >= 1) return;
    final tick = t * _ConfettiBurstState._ticks;
    final unit = size.height / 900; // canvas-confetti works in window px
    final origin = Offset(size.width * 0.5, size.height * 0.8);
    // Distance covered with velocity decaying by 0.9 per tick.
    final travel = (1 - math.pow(0.9, tick)) / 0.1;
    final alpha = (1 - t).clamp(0.0, 1.0);
    final scale = math.max(unit, 0.6);
    final paint = Paint();
    for (final f in fetti) {
      final d = f.velocity * travel * unit;
      final p =
          origin +
          Offset(
            math.cos(f.angle) * d + math.sin(f.wobble + tick * 0.1) * 6 * unit,
            math.sin(f.angle) * d + 3 * tick * unit, // gravity 3 px per tick
          );
      paint.color = f.color.withValues(alpha: alpha);
      canvas.save();
      canvas.translate(p.dx, p.dy);
      canvas.rotate(f.spin + tick * 0.1);
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: 10 * scale,
          height: 6 * scale * (0.4 + 0.6 * math.cos(f.wobble + tick * 0.12).abs()),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => false;
}
