// Imported from new-elab-app-9; Class 9 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// ZSL Virtual Lab | Blood Donation & Transfusion
// Converted from Cl9S-Ch6-A5-BloodDonationTransfusion.html (gsap -> Flutter).

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
    'app_title': 'Blood Groups',
    'app_subtitle': 'Class 9 • Tissues',
    'start_mission': 'START MISSION',
    'header_subtitle': 'Class 9 • Tissues',
    'settings': 'Settings',
    'visTheme': 'Visual Theme',
    'dark': 'Dark',
    'light': 'Light',
    'txtScale': 'Text Scaling',
    'instructions_title': 'Instructions',
    'missionReady': 'Mission Ready',
    'btn_reset': 'Reset Step',
    'btn_verify': 'VERIFY',
    'start_centrifuge': 'Start Centrifuge',
    'mission_objective_title': 'Mission Objective',
    'mission_objective_text':
        'Spin donated blood in a centrifuge to see it separate into its layers, then follow the journey of donated blood from a healthy donor to a patient who needs it.',
    'teacher_step1':
        'Centrifugation spins a mixture in a tube at high speed; the tubes become horizontal and centrifugal force pushes heavier particles outward/down to settle at the bottom, while the lighter liquid stays on top. Labs use this to separate blood into: plasma, platelets and white blood cells, and red blood cells.',
    'teacher_step2':
        'Blood transfusion transfers blood from a healthy donor to a patient. Donated blood is tested, blood group identified, separated, stored safely in blood banks, then supplied when required. The body replaces the donated blood naturally within a few weeks, making donation safe.',
    'teacher_fact':
        'Supporting fact: Blood is neither a solution nor a true suspension — it is a <b>colloid</b>; its particles do not settle over time and stay uniformly dispersed.',
    'conclusion_title': 'Conclusion',
    'conclusion_text':
        "Blood is a colloid that a centrifuge can separate into plasma, platelets and white blood cells, and red blood cells. Donated blood follows a clear path — donate, test and identify the blood group, separate by centrifugation, store in a blood bank, then supply to a patient — and the donor's body safely replaces the donated blood within a few weeks.",
    'restart_lab': 'RESTART LAB',
    's1_title': 'S1: Centrifuge the Blood Sample',
    's1_desc_pre': "Click 'Start Centrifuge' to spin the tube.",
    's1_desc_post':
        "Drag the layer names to the correct bands on the spun tube. Use '?' for hints.",
    's2_title': 'S2: Donation Journey',
    's2_desc':
        'Place the steps in order, then select if donation is safe and the reason why.',
    't_plasma': 'Plasma',
    't_p_wbc': 'Platelets and White Blood Cells',
    't_rbc': 'Red Blood Cells',
    'j_donate': 'Donate Blood',
    'j_test': 'Test Blood & Identify Blood Group',
    'j_cent': 'Separate by Centrifugation',
    'j_store': 'Store in Blood Bank',
    'j_trans': 'Supply/Transfuse to Patient',
    'hint_top':
        'the lightest part of the mixture — it rises above everything else once spinning stops.',
    'hint_mid':
        'a thin band sitting between the top and the bottom — neither the lightest nor the heaviest part.',
    'hint_bot':
        'the heaviest part of the mixture — the centrifugal force pushes it all the way down.',
    'slot1_hint': 'Step 1',
    'slot2_hint': 'Step 2',
    'slot3_hint': 'Step 3',
    'slot4_hint': 'Step 4',
    'slot5_hint': 'Step 5',
    'h_donate': 'The first step: a healthy person gives blood.',
    'h_test': 'The lab checks the blood and finds its type.',
    'h_cent': 'The step where the machine spins the blood.',
    'h_store': 'Keeping the blood safe until it is needed.',
    'h_trans': 'Giving the blood to a patient who needs it.',
    'safety_question': 'Is blood donation safe?',
    'safe_yes': 'Yes, it is safe',
    'safe_no': 'No, it is not safe',
    'select_reason': 'Select reason...',
    'reason1':
        'The body replaces the donated blood naturally within a few weeks.',
    'reason2': 'Donation permanently lowers blood volume.',
    'reason3': 'The donor needs an immediate transfusion afterward.',
    // Strings the HTML hard-codes in its markup / scripts.
    'ui': {
      'lab_progress': 'Lab Progress',
      'step': 'STEP',
      'journey_title': 'Transfusion Journey',
      'feedback_correct': 'Excellent!',
      'feedback_wrong': 'Not quite right. Try again!',
      'unlock_first': 'Unlock view first!',
      'rpm': 'RPM',
      'tool_lock': 'Lock View',
      'tool_pan': 'Pan Mode',
      'tool_labels': 'Toggle Labels',
    },
    'labels': {
      'centrifuge': 'Centrifuge Machine',
      'tube': 'Test Tube',
      'donor': 'Donor Hand',
      'bag': 'Blood Bag',
      'iv_tube': 'IV Tube',
      'blood': 'Donated Blood',
    },
  },
  'hi': {
    'app_title': 'रक्त समूह',
    'app_subtitle': 'कक्षा 9 • ऊतक',
    'start_mission': 'मिशन शुरू करें',
    'header_subtitle': 'कक्षा 9 • ऊतक',
    'settings': 'सेटिंग्स',
    'visTheme': 'दृश्य थीम',
    'dark': 'डार्क',
    'light': 'लाइट',
    'txtScale': 'टेक्स्ट स्केलिंग',
    'instructions_title': 'निर्देश',
    'missionReady': 'मिशन तैयार है',
    'btn_reset': 'कदम रीसेट करें',
    'btn_verify': 'सत्यापित करें',
    'start_centrifuge': 'अपकेंद्रित्र शुरू करें',
    'mission_objective_title': 'मिशन का उद्देश्य',
    'mission_objective_text':
        'दान किए गए रक्त को अपकेंद्रित्र (centrifuge) में घुमाएं और इसे परतों में अलग होते हुए देखें, फिर एक स्वस्थ दाता से लेकर जरूरतमंद रोगी तक दान किए गए रक्त की यात्रा का पालन करें।',
    'teacher_step1':
        'अपकेंद्रीकरण (Centrifugation) एक ट्यूब में मिश्रण को उच्च गति पर घुमाता है; ट्यूब क्षैतिज हो जाते हैं और अपकेंद्री बल भारी कणों को बाहर/नीचे की ओर धकेलता है जिससे वे नीचे बैठ जाते हैं, जबकि हल्का तरल ऊपर रहता है। प्रयोगशालाएं इसका उपयोग रक्त को अलग करने के लिए करती हैं: प्लाज्मा, प्लेटलेट्स और श्वेत रक्त कोशिकाएं, और लाल रक्त कोशिकाएं।',
    'teacher_step2':
        'रक्त आधान (Blood transfusion) एक स्वस्थ दाता से रोगी को रक्त स्थानांतरित करता है। दान किए गए रक्त का परीक्षण किया जाता है, रक्त समूह की पहचान की जाती है, अलग किया जाता है, रक्त बैंकों में सुरक्षित रूप से संग्रहीत किया जाता है, फिर आवश्यकता पड़ने पर आपूर्ति की जाती है। शरीर स्वाभाविक रूप से कुछ ही हफ्तों में दान किए गए रक्त की भरपाई कर लेता है, जिससे दान सुरक्षित हो जाता है।',
    'teacher_fact':
        'सहायक तथ्य: रक्त न तो समाधान (solution) है और न ही एक वास्तविक निलंबन (suspension) — यह एक <b>कोलॉइड (colloid)</b> है; इसके कण समय के साथ नीचे नहीं बैठते हैं और समान रूप से फैले रहते हैं।',
    'conclusion_title': 'निष्कर्ष',
    'conclusion_text':
        'रक्त एक कोलॉइड है जिसे अपकेंद्रित्र द्वारा अलग किया जा सकता है। दान किया गया रक्त एक स्पष्ट मार्ग का अनुसरण करता है - दान, परीक्षण, अपकेंद्रीकरण द्वारा पृथक्करण, भंडारण, रोगी को आपूर्ति।',
    'restart_lab': 'प्रयोगशाला पुनः आरंभ करें',
    's1_title': 'चरण 1: रक्त को अपकेंद्रित करें',
    's1_desc_pre':
        "ट्यूब को घुमाने के लिए 'अपकेंद्रित्र शुरू करें' पर क्लिक करें।",
    's1_desc_post': 'परत के नामों को सही बैंड पर खींचें।',
    's2_title': 'चरण 2: दान की यात्रा',
    's2_desc':
        'चरणों को सही क्रम में रखें, फिर चुनें कि क्या दान सुरक्षित है और कारण चुनें।',
    't_plasma': 'प्लाज्मा (Plasma)',
    't_p_wbc': 'प्लेटलेट्स और श्वेत रक्त कोशिकाएं',
    't_rbc': 'लाल रक्त कोशिकाएं',
    'j_donate': 'रक्त दान करें',
    'j_test': 'रक्त का परीक्षण और रक्त समूह की पहचान',
    'j_cent': 'अपकेंद्रीकरण द्वारा अलग करें',
    'j_store': 'रक्त बैंक में स्टोर करें',
    'j_trans': 'रोगी को आपूर्ति / आधान करें',
    'hint_top': 'मिश्रण का सबसे हल्का हिस्सा - यह सबसे ऊपर उठता है।',
    'hint_mid':
        'शीर्ष और तल के बीच बैठा एक पतला बैंड - न तो सबसे हल्का और न ही सबसे भारी।',
    'hint_bot':
        'मिश्रण का सबसे भारी हिस्सा - अपकेंद्री बल इसे पूरा नीचे धकेलता है।',
    'slot1_hint': 'कदम 1',
    'slot2_hint': 'कदम 2',
    'slot3_hint': 'कदम 3',
    'slot4_hint': 'कदम 4',
    'slot5_hint': 'कदम 5',
    'h_donate': 'पहला कदम: एक स्वस्थ व्यक्ति रक्त देता है।',
    'h_test': 'लैब रक्त की जांच करती है और उसका प्रकार ढूंढती है।',
    'h_cent': 'वह कदम जहां मशीन रक्त को घुमाती है।',
    'h_store': 'रक्त को सुरक्षित रखना जब तक उसकी आवश्यकता न हो।',
    'h_trans': 'रक्त को उस रोगी को देना जिसे इसकी आवश्यकता है।',
    'safety_question': 'क्या रक्तदान सुरक्षित है?',
    'safe_yes': 'हाँ, यह सुरक्षित है',
    'safe_no': 'नहीं, यह सुरक्षित नहीं है',
    'select_reason': 'कारण चुनें...',
    'reason1':
        'शरीर स्वाभाविक रूप से कुछ हफ्तों में दान किए गए रक्त की भरपाई कर लेता है।',
    'reason2': 'दान स्थायी रूप से रक्त की मात्रा को कम करता है।',
    'reason3': 'दाता को बाद में तत्काल आधान की आवश्यकता होती है।',
    'ui': {
      'lab_progress': 'लैब प्रगति',
      'step': 'चरण',
      'journey_title': 'आधान यात्रा',
      'feedback_correct': 'उत्कृष्ट!',
      'feedback_wrong': 'पूरी तरह सही नहीं। फिर से प्रयास करें!',
      'unlock_first': 'पहले दृश्य अनलॉक करें!',
      'rpm': 'RPM',
      'tool_lock': 'दृश्य लॉक करें',
      'tool_pan': 'पैन मोड',
      'tool_labels': 'लेबल टॉगल करें',
    },
    'labels': {
      'centrifuge': 'अपकेंद्रित्र मशीन',
      'tube': 'परखनली',
      'donor': 'दाता का हाथ',
      'bag': 'रक्त थैली',
      'iv_tube': 'आईवी ट्यूब',
      'blood': 'दान किया गया रक्त',
    },
  },
});

// ---------------------------------------------------------------------------
// Scene geometry. Coordinates are the HTML `.svg-scene` pixels (800 x 600).

/// Part of the 800x600 scene fitted into the canvas (all drawn content).
const Rect _kSceneView = Rect.fromLTRB(60, 95, 820, 530);

/// Canvas width kept free on the right for the shell's back button / toolbar.
const double _kToolbarReserve = 64;

/// Length of the GSAP centrifuge timeline (1 + 0.1 + 0.5 + 3 + 0.5 + 0.1 + 1 s).
const int _kSpinMs = 6200;

/// S1 bands on the spun tube, top to bottom (HTML `data-band`).
const List<String> _kBands = ['plasma', 'wbc', 'rbc'];

/// TOKENS_S1: token id -> label key.
const Map<String, String> _kS1Keys = {
  'plasma': 't_plasma',
  'wbc': 't_p_wbc',
  'rbc': 't_rbc',
};

/// `showHint(1|2|3)`: pin -> hint key.
const Map<String, String> _kS1HintKeys = {
  'plasma': 'hint_top',
  'wbc': 'hint_mid',
  'rbc': 'hint_bot',
};

/// Pin centre line of each band in scene px (tube top 180 + pin top 35/125/170).
const Map<String, double> _kPinY = {'plasma': 215, 'wbc': 305, 'rbc': 350};

/// Centre of each separated layer on the spun tube (leader-line start).
const Map<String, double> _kBandY = {'plasma': 286, 'wbc': 313.5, 'rbc': 351};

/// TOKENS_S2 in tray order; this is also the correct journey order.
const List<String> _kS2Order = ['donate', 'test', 'cent', 'store', 'trans'];
const Map<String, String> _kS2Keys = {
  'donate': 'j_donate',
  'test': 'j_test',
  'cent': 'j_cent',
  'store': 'j_store',
  'trans': 'j_trans',
};
const Map<String, String> _kS2Hints = {
  'donate': 'h_donate',
  'test': 'h_test',
  'cent': 'h_cent',
  'store': 'h_store',
  'trans': 'h_trans',
};
const List<String> _kReasons = ['reason1', 'reason2', 'reason3'];

/// Parses the absolute SVG path commands used by the source (M L C Q A Z).
Path _svgPath(String d) {
  final tokens = RegExp(
    r'[MLCQAZ]|-?(?:\d+\.?\d*|\.\d+)',
  ).allMatches(d).map((m) => m.group(0)!).toList();
  final path = Path();
  var i = 0;
  var cmd = 'M';
  double n() => double.parse(tokens[i++]);
  while (i < tokens.length) {
    final t = tokens[i];
    if ('MLCQAZ'.contains(t)) {
      cmd = t;
      i++;
      if (cmd == 'Z') {
        path.close();
        continue;
      }
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
      case 'A':
        final rx = n(),
            ry = n(),
            rot = n(),
            large = n(),
            sweep = n(),
            x = n(),
            y = n();
        path.arcToPoint(
          Offset(x, y),
          radius: Radius.elliptical(rx, ry),
          rotation: rot,
          largeArc: large != 0,
          clockwise: sweep != 0,
        );
      default:
        i++;
    }
  }
  return path;
}

final Map<String, Path> _svgCache = {};
Path _p(String d) => _svgCache.putIfAbsent(d, () => _svgPath(d));

Paint _fill(Color c, [double opacity = 1]) =>
    Paint()..color = c.withValues(alpha: c.a * opacity);

Paint _stroke(
  Color c,
  double width, {
  double opacity = 1,
  bool round = false,
}) => Paint()
  ..style = PaintingStyle.stroke
  ..strokeWidth = width
  ..strokeCap = round ? StrokeCap.round : StrokeCap.butt
  ..strokeJoin = StrokeJoin.round
  ..color = c.withValues(alpha: c.a * opacity);

/// Paints [text] centred on [baselineCenter] (SVG `text-anchor="middle"`).
void _drawText(
  Canvas canvas,
  String text,
  Offset baselineCenter,
  TextStyle style,
) {
  final tp = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();
  final baseline = tp.computeDistanceToActualBaseline(TextBaseline.alphabetic);
  tp.paint(
    canvas,
    Offset(baselineCenter.dx - tp.width / 2, baselineCenter.dy - baseline),
  );
  tp.dispose();
}

void _dashLine(
  Canvas canvas,
  Offset a,
  Offset b,
  Paint paint, {
  double dash = 5,
  double gap = 4,
}) {
  final d = b - a;
  final len = d.distance;
  if (len == 0) return;
  final dir = d / len;
  for (double s = 0; s < len; s += dash + gap) {
    canvas.drawLine(a + dir * s, a + dir * math.min(s + dash, len), paint);
  }
}

/// One animation frame of the HTML `startSpin` GSAP timeline.
class _SpinFrame {
  const _SpinFrame({
    required this.tubeOffset,
    required this.tubeScale,
    required this.tubeOpacity,
    required this.lid,
    required this.rotorDeg,
    required this.rpm,
    required this.fluid,
  });

  final Offset tubeOffset;
  final double tubeScale;
  final double tubeOpacity;
  final double lid;
  final double rotorDeg;
  final int rpm;

  /// 0 = whole blood, 1 = separated (plasma / buffy coat / red cells).
  final double fluid;

  static double _seg(double t, double start, double dur) =>
      ((t - start) / dur).clamp(0.0, 1.0);

  /// [t] is the timeline time in seconds (0..6.2).
  factory _SpinFrame.at(double t) {
    // 1. Tube moves into the rotor hole (power2.inOut, 1 s); 7. returns at 5.2 s.
    final move = t < 5.2
        ? _rt_Ease.inOutCubic(_seg(t, 0, 1))
        : 1 - _rt_Ease.inOutCubic(_seg(t, 5.2, 1));
    final double opacity;
    if (t < 1.1) {
      opacity = 1 - _seg(t, 1, 0.1);
    } else if (t < 5.1) {
      opacity = 0;
    } else {
      opacity = _seg(t, 5.1, 0.1);
    }
    // 2./4. Lid closes at 1.1 s and opens at 4.6 s (power1.out, 0.5 s each).
    final lid = t < 4.6
        ? _rt_Ease.outQuad(_seg(t, 1.1, 0.5))
        : 1 - _rt_Ease.outQuad(_seg(t, 4.6, 0.5));
    // 3. Spin: 15 turns over 3 s (power1.inOut); the RPM read-out uses the
    // tween's linear progress, peaking at 5000 RPM half-way.
    final p = _seg(t, 1.6, 3);
    return _SpinFrame(
      tubeOffset: Offset(-325 * move, 20 * move),
      tubeScale: 1 - 0.85 * move,
      tubeOpacity: opacity,
      lid: lid,
      rotorDeg: 360 * 15 * _rt_Ease.inOutQuad(p),
      rpm: (p * (1 - p) * 4 * 5000).floor(),
      // Layers separate during the first 2 s of the spin (power2.inOut).
      fluid: _rt_Ease.inOutCubic(_seg(t, 1.6, 2)),
    );
  }
}

class _Particle {
  const _Particle(this.x, this.y, this.r);
  final double x, y, r;
}

// ------------------------------------------------------------ painters ---
// Redraws of the inline SVGs. Each painter works in the SVG's own viewBox.

/// Centrifuge SVG (isometric top-down), viewBox 340 x 340.
class _CentrifugePainter extends CustomPainter {
  const _CentrifugePainter({
    required this.rotorDeg,
    required this.lid,
    required this.display,
  });

  final double rotorDeg;

  /// Lid scaleY: 0 = open (hidden), 1 = closed.
  final double lid;
  final String display;

  static const _holes = [
    Offset(0, -65),
    Offset(0, 65),
    Offset(-65, 0),
    Offset(65, 0),
    Offset(-45, -45),
    Offset(45, 45),
    Offset(-45, 45),
    Offset(45, -45),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    // Drop shadow.
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(170, 290), width: 280, height: 40),
      _fill(const Color(0x33000000)),
    );
    // Base body + dome.
    final body = _p(
      'M 30 140 L 310 140 L 330 280 A 10 10 0 0 1 320 290 L 20 290 A 10 10 0 0 1 10 280 Z',
    );
    canvas.drawPath(body, _fill(const Color(0xFFCBD5E1)));
    canvas.drawPath(body, _stroke(const Color(0xFF94A3B8), 4));
    final dome = _p('M 30 140 C 30 100, 310 100, 310 140 Z');
    canvas.drawPath(dome, _fill(const Color(0xFFE2E8F0)));
    canvas.drawPath(dome, _stroke(const Color(0xFF94A3B8), 4));
    // Control panel with the RPM display.
    canvas.drawPath(
      _p('M 100 240 L 240 240 L 250 280 L 90 280 Z'),
      _fill(const Color(0xFF0F172A)),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(130, 248, 80, 24),
        const Radius.circular(4),
      ),
      _fill(const Color(0xFF1E293B)),
    );
    _drawText(
      canvas,
      display,
      const Offset(170, 265),
      const TextStyle(
        fontFamily: 'monospace',
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF10B981),
      ),
    );
    canvas.drawCircle(
      const Offset(110, 260),
      8,
      _fill(const Color(0xFFEF4444)),
    );
    canvas.drawCircle(
      const Offset(230, 260),
      8,
      _fill(const Color(0xFF3B82F6)),
    );

    // Rotor chamber (perspective scale 1 x 0.45).
    canvas.save();
    canvas.translate(170, 130);
    canvas.scale(1, 0.45);
    canvas.drawCircle(Offset.zero, 100, _fill(const Color(0xFF1E293B)));
    canvas.save();
    canvas.rotate(_rt_degToRad(rotorDeg));
    canvas.drawCircle(Offset.zero, 90, _fill(const Color(0xFF94A3B8)));
    canvas.drawCircle(Offset.zero, 20, _fill(const Color(0xFF475569)));
    for (final h in _holes) {
      canvas.drawCircle(h, 12, _fill(const Color(0xFF0F172A)));
    }
    canvas.restore();
    canvas.restore();

    // Lid: flips down from its back hinge (transform-origin at the top edge).
    if (lid > 0.001) {
      canvas.save();
      canvas.translate(170, 130 - 47);
      canvas.scale(1, lid);
      canvas.translate(0, 47);
      canvas.scale(1, 0.45);
      canvas.drawCircle(Offset.zero, 105, _fill(const Color(0xD9F1F5F9)));
      canvas.drawCircle(Offset.zero, 105, _stroke(const Color(0xFF94A3B8), 4));
      canvas.drawCircle(Offset.zero, 80, _stroke(const Color(0x99FFFFFF), 8));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_CentrifugePainter old) =>
      old.rotorDeg != rotorDeg || old.lid != lid || old.display != display;
}

/// Test tube rack SVG, viewBox 150 x 150.
class _RackPainter extends CustomPainter {
  const _RackPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const leg = Color(0xFF94A3B8);
    canvas.drawRect(const Rect.fromLTWH(20, 20, 10, 100), _fill(leg));
    canvas.drawRect(const Rect.fromLTWH(120, 20, 10, 100), _fill(leg));
    for (final y in const [40.0, 90.0]) {
      final shelf = RRect.fromRectAndRadius(
        Rect.fromLTWH(10, y, 130, 10),
        const Radius.circular(5),
      );
      canvas.drawRRect(shelf, _fill(const Color(0xFFCBD5E1)));
      canvas.drawRRect(shelf, _stroke(leg, 2));
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 120, 130, 20),
        const Radius.circular(5),
      ),
      _fill(leg),
    );
  }

  @override
  bool shouldRepaint(_RackPainter old) => false;
}

/// The animated test tube SVG, viewBox 70 x 220.
class _TubePainter extends CustomPainter {
  const _TubePainter({required this.fluid, required this.particles});

  final double fluid;
  final List<_Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    // Back glass.
    final glass = _p('M 15 10 L 15 190 A 20 20 0 0 0 55 190 L 55 10');
    canvas.drawPath(glass, _fill(const Color(0x1AFFFFFF)));
    canvas.drawPath(glass, _stroke(const Color(0xFF94A3B8), 3));

    // Red cells: whole tube before the spin, the bottom layer after it
    // (the GSAP `attr: {d}` tween interpolates every number of the path).
    final e = fluid;
    final left = 18 + 4 * e,
        right = 52 - 4 * e,
        top = 80 + 55 * e,
        r = 17 - 4 * e;
    final rbc = Path()
      ..moveTo(left, top)
      ..lineTo(left, 190)
      ..arcToPoint(
        Offset(right, 190),
        radius: Radius.circular(r),
        clockwise: false,
      )
      ..lineTo(right, top)
      ..close();
    canvas.drawPath(rbc, _fill(const Color(0xFF991B1B)));
    if (e > 0) {
      // Buffy coat (platelets + white cells) and plasma.
      canvas.drawRect(
        Rect.fromLTWH(18, 80 + 52 * e, 34, 3 * e),
        _fill(const Color(0xFFF8FAFC), e),
      );
      canvas.drawRect(
        Rect.fromLTRB(18, 80, 52, 80 + 52 * e),
        _fill(const Color(0xFFEAB308), 0.9),
      );
    }
    // Front glass highlight.
    canvas.drawPath(
      _p('M 22 20 L 22 180 A 12 12 0 0 0 35 195'),
      _stroke(const Color(0xB3FFFFFF), 4, round: true),
    );
    // Particles sink with the red cells (kept inside that layer).
    canvas.save();
    canvas.clipPath(rbc);
    final dot = _fill(const Color(0xFFDC2626), 0.6 * (1 - 0.2 * e));
    for (final p in particles) {
      canvas.drawCircle(Offset(p.x, p.y + 45 * e), p.r, dot);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TubePainter old) =>
      old.fluid != fluid || old.particles != particles;
}

/// S2 visuals SVG (IV stand, blood bag, IV tube, donor arm), viewBox 350 x 350.
class _TransfusionPainter extends CustomPainter {
  const _TransfusionPainter();

  static const _skin = Color(0xFFE2A378);
  static const _skinDark = Color(0xFFC0825C);
  static const _skinLight = Color(0xFFF5BA8E);

  @override
  void paint(Canvas canvas, Size size) {
    // --- Medical IV stand ---
    canvas.save();
    canvas.translate(240, 10);
    canvas.drawRect(
      const Rect.fromLTWH(18, -10, 6, 200),
      _fill(const Color(0xFF94A3B8)),
    );
    canvas.drawPath(
      _p('M 0 0 C 10 -10, 30 -10, 42 0'),
      _stroke(const Color(0xFF64748B), 4, round: true),
    );
    canvas.drawCircle(Offset.zero, 3, _fill(const Color(0xFFCBD5E1)));
    canvas.drawCircle(const Offset(42, 0), 3, _fill(const Color(0xFFCBD5E1)));
    canvas.restore();

    // --- Blood bag hanging on the left hook ---
    canvas.save();
    canvas.translate(200, 12);
    canvas.drawPath(_p('M 40 -12 L 40 5'), _stroke(const Color(0xFF94A3B8), 3));
    canvas.drawPath(
      _p('M 30 5 C 30 -5, 50 -5, 50 5'),
      _stroke(const Color(0xFFCBD5E1), 4),
    );
    final bag = RRect.fromRectAndRadius(
      const Rect.fromLTWH(10, 5, 60, 120),
      const Radius.circular(10),
    );
    canvas.drawRRect(bag, _fill(const Color(0xD9FFFFFF)));
    canvas.drawRRect(bag, _stroke(const Color(0xFF64748B), 2));
    canvas.drawPath(
      _p(
        'M 12 40 L 68 40 L 68 115 C 68 120, 60 123, 40 123 C 20 123, 12 120, 12 115 Z',
      ),
      _fill(const Color(0xFFDC2626)),
    );
    canvas.drawPath(
      _p('M 12 40 Q 40 45 68 40 L 68 45 Q 40 50 12 45 Z'),
      _fill(const Color(0xFFB91C1C)),
    );
    canvas.drawPath(
      _p(
        'M 16 45 L 16 110 C 20 115, 30 118, 40 118 C 50 118, 60 115, 64 110 L 64 45 Z',
      ),
      _fill(const Color(0xFFEF4444), 0.5),
    );
    canvas.drawPath(
      _p('M 18 50 L 25 50 L 25 100 L 18 100 Z'),
      _fill(const Color(0xFFFCA5A5), 0.6),
    );
    // Medical label.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 55, 44, 40),
        const Radius.circular(4),
      ),
      _fill(Colors.white),
    );
    canvas.drawRect(
      const Rect.fromLTWH(22, 60, 36, 6),
      _fill(const Color(0xFFF87171)),
    );
    _drawText(
      canvas,
      'O+',
      const Offset(40, 78),
      const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w900,
        color: Color(0xFF0F172A),
      ),
    );
    for (final r in const [
      Rect.fromLTWH(22, 82, 20, 2),
      Rect.fromLTWH(22, 86, 30, 2),
      Rect.fromLTWH(22, 90, 15, 2),
    ]) {
      canvas.drawRect(r, _fill(const Color(0xFF94A3B8)));
    }
    // Output ports.
    for (final x in const [25.0, 45.0]) {
      final port = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, 125, 10, 18),
        const Radius.circular(2),
      );
      canvas.drawRRect(port, _fill(const Color(0xFFE2E8F0)));
      canvas.drawRRect(port, _stroke(const Color(0xFF64748B), 1.5));
    }
    canvas.drawLine(
      const Offset(30, 143),
      const Offset(30, 155),
      _stroke(const Color(0xFF94A3B8), 2),
    );
    // Measurement ticks.
    for (final y in const [50.0, 70.0, 90.0, 110.0]) {
      canvas.drawLine(
        Offset(12, y),
        Offset(16, y),
        _stroke(const Color(0xFF334155), 1),
      );
    }
    canvas.restore();

    // --- IV tube from the bag to the arm ---
    final tube = _p('M 230 155 Q 230 250 160 255');
    canvas.drawPath(tube, _stroke(const Color(0xFFEF4444), 4, round: true));
    canvas.drawPath(
      tube,
      _stroke(const Color(0xFFFCA5A5), 1.5, opacity: 0.8, round: true),
    );

    // --- Donor arm ---
    canvas.save();
    canvas.translate(-10, 240);
    canvas.drawPath(
      _p(
        'M -10 10 Q 30 -5 70 -5 Q 110 -5 150 10 Q 155 35 150 50 Q 110 65 70 65 Q 20 65 -10 50 Z',
      ),
      _fill(_skin),
    );
    canvas.drawPath(
      _p(
        'M 140 0 C 180 -10, 210 -15, 240 -10 C 255 -5, 260 10, 260 25 C 260 40, 240 50, 220 50 C 180 50, 150 60, 140 50 Z',
      ),
      _fill(_skin),
    );
    // Shading and highlights.
    canvas.drawPath(
      _p('M 140 0 C 180 -10, 210 -15, 240 -10 C 230 5, 180 10, 140 10 Z'),
      _fill(_skinLight, 0.7),
    );
    canvas.drawPath(
      _p('M 140 40 C 180 40, 220 45, 220 50 C 180 50, 150 60, 140 50 Z'),
      _fill(_skinDark, 0.6),
    );
    canvas.drawPath(
      _p('M 0 50 Q 70 65 140 50 L 140 40 Q 70 55 0 40 Z'),
      _fill(_skinDark, 0.6),
    );
    canvas.drawPath(
      _p('M 0 10 Q 70 -5 140 0 L 140 10 Q 70 5 0 20 Z'),
      _fill(_skinLight, 0.7),
    );
    // Elbow crease.
    canvas.drawPath(
      _p('M 140 10 Q 150 25 140 45'),
      _stroke(_skinDark, 3, opacity: 0.5, round: true),
    );
    canvas.drawPath(
      _p('M 130 15 Q 140 25 130 40'),
      _stroke(_skinDark, 2, opacity: 0.3, round: true),
    );
    // Veins.
    canvas.drawPath(
      _p('M 160 30 Q 190 20 220 25'),
      _stroke(const Color(0xFF60A5FA), 3, opacity: 0.25, round: true),
    );
    canvas.drawPath(
      _p('M 155 35 Q 185 45 220 35'),
      _stroke(const Color(0xFF60A5FA), 2.5, opacity: 0.2, round: true),
    );
    // Squeeze ball.
    canvas.drawCircle(
      const Offset(265, 22),
      16,
      _fill(const Color(0xFFF87171)),
    );
    canvas.drawCircle(
      const Offset(260, 18),
      6,
      _fill(const Color(0xFFFCA5A5), 0.8),
    );
    // Palm and fingers wrapping the ball.
    canvas.drawPath(
      _p(
        'M 240 -10 C 265 -10, 275 -5, 280 5 C 285 20, 285 30, 275 45 C 265 55, 240 50, 230 48 Z',
      ),
      _fill(_skin),
    );
    for (final d in const [
      'M 270 -5 C 280 -5, 285 0, 285 10 C 285 20, 275 25, 260 20 C 255 18, 255 5, 270 -5 Z',
      'M 275 5 C 285 5, 290 10, 288 20 C 286 30, 275 35, 260 30 C 255 28, 260 15, 275 5 Z',
      'M 270 15 C 280 15, 285 20, 282 30 C 279 40, 268 45, 255 40 C 250 38, 255 25, 270 15 Z',
      'M 265 25 C 272 25, 278 30, 272 40 C 266 50, 255 52, 245 48 C 240 46, 250 35, 265 25 Z',
      // Thumb over the fingers.
      'M 235 48 C 255 50, 275 35, 265 20 C 260 15, 250 15, 240 20 Z',
    ]) {
      canvas.drawPath(_p(d), _fill(_skin));
      canvas.drawPath(_p(d), _stroke(_skinDark, 1.5));
    }
    canvas.drawPath(
      _p('M 260 22 C 265 22, 268 25, 265 28 C 262 30, 258 28, 260 22 Z'),
      _fill(const Color(0xFFFCD34D), 0.6),
    );
    // Butterfly needle, tape and blood at the needle.
    canvas.drawPath(
      _p('M 166 12 L 176 17 L 166 22 Z'),
      _fill(const Color(0xFF38BDF8)),
    );
    canvas.drawPath(
      _p('M 166 12 L 156 17 L 166 22 Z'),
      _fill(const Color(0xFF38BDF8)),
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(166, 17), width: 6, height: 10),
      _fill(const Color(0xFF0284C7)),
    );
    canvas.drawLine(
      const Offset(166, 17),
      const Offset(146, 17),
      _stroke(const Color(0xFF94A3B8), 1.5),
    );
    void tape(Rect r, double deg, Offset pivot) {
      canvas.save();
      canvas.translate(pivot.dx, pivot.dy);
      canvas.rotate(_rt_degToRad(deg));
      canvas.translate(-pivot.dx, -pivot.dy);
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(2)),
        _fill(const Color(0xFFF8FAFC), 0.85),
      );
      canvas.restore();
    }

    tape(const Rect.fromLTWH(150, 8, 12, 18), -15, const Offset(156, 17));
    tape(const Rect.fromLTWH(160, 10, 12, 18), 10, const Offset(166, 17));
    canvas.drawPath(
      _p('M 166 17 Q 170 15 170 15'),
      _stroke(const Color(0xFFDC2626), 4, round: true),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_TransfusionPainter old) => false;
}

/// Dashed leader lines from the tube layers to the S1 pins (scene px).
class _LeaderPainter extends CustomPainter {
  const _LeaderPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = _stroke(color, 2);
    for (final band in _kBands) {
      _dashLine(
        canvas,
        Offset(598, _kBandY[band]!),
        Offset(650, _kPinY[band]!),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_LeaderPainter old) => old.color != color;
}

/// Dashed rounded border (HTML `border-2 border-dashed`), with optional fill.
class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    this.fill,
    this.radius = 8,
    this.width = 2,
  });

  final Color color;
  final Color? fill;
  final double radius;
  final double width;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      (Offset.zero & size).deflate(width / 2),
      Radius.circular(radius),
    );
    if (fill != null) canvas.drawRRect(rrect, _fill(fill!));
    final paint = _stroke(color, width);
    for (final metric in (Path()..addRRect(rrect)).computeMetrics()) {
      for (double d = 0; d < metric.length; d += 10) {
        canvas.drawPath(
          metric.extractPath(d, math.min(d + 6, metric.length)),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.fill != fill ||
      old.radius != radius ||
      old.width != width;
}

// ---------------------------------------------------------------- page ---
class Cl9Ch06A5BloodDonationTransfusionPage extends StatefulWidget {
  const Cl9Ch06A5BloodDonationTransfusionPage({super.key});

  @override
  State<Cl9Ch06A5BloodDonationTransfusionPage> createState() =>
      _Cl9Ch06A5BloodDonationTransfusionPageState();
}

class _Cl9Ch06A5BloodDonationTransfusionPageState
    extends State<Cl9Ch06A5BloodDonationTransfusionPage>
    with TickerProviderStateMixin {
  final _rt_ShellController _shell = _rt_ShellController();

  /// The `startSpin` GSAP timeline.
  late final AnimationController _spinCtrl;

  /// `transitionToS2` fades (S1 out 1 s, S2 in 1 s after 0.5 s, rail 0.8 s).
  late final AnimationController _s2Ctrl;

  /// Tailwind `animate-pulse` on the "try again" feedback.
  late final AnimationController _pulseCtrl;

  /// `initParticles`: red-cell dots drawn inside the tube.
  late final List<_Particle> _particles;

  // --- ACTIVITY STATE (HTML `state`) ---
  int _step = 1;
  bool _spinning = false;
  bool _spinDone = false;
  final Map<String, String> _s1Placed = {}; // band -> token id
  final Map<int, String> _s2Placed = {}; // journey slot (1..5) -> token id
  bool? _isSafe;
  String? _reason;
  String? _feedback; // null | 'correct' | 'wrong'
  bool _verifying = false;
  bool _advancing = false;
  String? _hintBand;

  // Viewport tools (zoom / reset / lock / pan / labels).
  bool _locked = true;
  bool _panMode = false;
  bool _showLabels = true;
  double _zoom = 1;
  Offset _pan = Offset.zero;

  // Draggable HUDs (HTML `.hud-draggable`).
  Offset _instrOffset = Offset.zero;
  Offset _actionOffset = Offset.zero;
  bool _instrCollapsed = false;
  bool _actionCollapsed = false;

  // Timers (setTimeout) -- cancelled on restart / dispose.
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
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _kSpinMs),
    );
    _s2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      value: 1,
    );
    final rng = math.Random();
    _particles = List.generate(
      30,
      (_) => _Particle(
        20 + rng.nextDouble() * 30,
        90 + rng.nextDouble() * 95,
        1.5 + rng.nextDouble() * 1.5,
      ),
    );
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
    _spinCtrl.dispose();
    _s2Ctrl.dispose();
    _pulseCtrl.dispose();
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

  // ------------------------------------------------- colours (CSS vars) ---
  bool get _dark => _rt_appTheme.isDark;
  Color get _bgMain =>
      _dark ? const Color(0xFF020617) : const Color(0xFFF8FAFC);
  Color get _bgPanel => _dark ? const Color(0xFF0F172A) : Colors.white;
  Color get _glass => _dark ? const Color(0xD90F172A) : const Color(0xE6FFFFFF);
  Color get _glassBorder =>
      _dark ? const Color(0x991E293B) : const Color(0x99CBD5E1);
  Color get _textMain =>
      _dark ? const Color(0xFFF8FAFC) : const Color(0xFF020617);
  Color get _textMuted =>
      _dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
  Color get _border =>
      _dark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);
  Color get _accent =>
      _dark ? const Color(0xFFEF4444) : const Color(0xFFDC2626);

  // ----------------------------------------------------------- viewport ---
  void _zoomBy(double delta) =>
      setState(() => _zoom = (_zoom + delta).clamp(0.5, 2.5));

  void _resetView() => setState(() {
    _zoom = 1;
    _pan = Offset.zero;
  });

  void _toggleLock() => setState(() {
    _locked = !_locked;
    if (_locked) {
      _zoom = 1;
      _pan = Offset.zero;
      _panMode = false;
    }
  });

  void _togglePan() {
    if (_locked) {
      _shell.showToast(
        _tx.s('ui.unlock_first'),
        color: _rt_Tw.red500,
        icon: Icons.lock,
      );
      return;
    }
    setState(() => _panMode = !_panMode);
  }

  void _toggleLabels() => setState(() => _showLabels = !_showLabels);

  /// Maps the 800x600 scene into a canvas of [size] (fit, then zoom + pan).
  ({double scale, Offset origin}) _sceneXf(Size size) {
    final areaW = math.max(1.0, size.width - _kToolbarReserve);
    final fit = math.min(
      areaW / _kSceneView.width,
      size.height / _kSceneView.height,
    );
    final scale = fit * _zoom;
    final center = Offset(areaW / 2, size.height / 2) + _pan;
    return (scale: scale, origin: center - _kSceneView.center * scale);
  }

  // ------------------------------------------------------ S1: centrifuge ---
  void _startSpin() {
    if (_spinDone || _spinning) return;
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _spinning = true);
    final g = _gen;
    _spinCtrl.forward(from: 0).then((_) {
      if (!mounted || g != _gen) return;
      _rt_playSfx(_rt_Sfx.success);
      setState(() {
        _spinning = false;
        _spinDone = true;
        _s1Placed.clear(); // loadTokens_S1
        _actionOffset = Offset.zero; // re-dock the action HUD for labelling
      });
    });
  }

  void _placeS1(String token, String band) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _s1Placed.removeWhere((_, v) => v == token);
      _s1Placed[band] =
          token; // a token already on this band returns to the tray
    });
  }

  void _returnS1(String token) {
    if (!mounted) return;
    setState(() => _s1Placed.removeWhere((_, v) => v == token));
  }

  // ------------------------------------------------- S2: donation journey ---
  void _placeS2(String token, int slot) {
    _rt_playSfx(_rt_Sfx.pop);
    setState(() {
      _s2Placed.removeWhere((_, v) => v == token);
      _s2Placed[slot] = token;
    });
  }

  void _returnS2(String token) {
    if (!mounted) return;
    setState(() => _s2Placed.removeWhere((_, v) => v == token));
  }

  void _showS2Hint(String token) {
    _rt_playSfx(_rt_Sfx.click);
    _shell.showToast(
      _tx.s(_kS2Hints[token]!),
      color: _rt_Tw.green500,
      icon: Icons.lightbulb,
    );
  }

  void _selectSafety(bool safe) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _isSafe = safe);
  }

  void _selectReason(String reason) {
    _rt_playSfx(_rt_Sfx.click);
    setState(() => _reason = reason);
  }

  // --------------------------------------------------- verify & phases ---
  void _resetCurrentPhase() {
    _rt_playSfx(_rt_Sfx.click);
    setState(() {
      if (_step == 1) {
        _s1Placed.clear();
      } else {
        _s2Placed.clear();
        _isSafe = null;
        _reason = null;
      }
    });
  }

  void _verifyStep() {
    if (_verifying || _advancing) return;
    setState(() => _verifying = true);
    _after(800, () {
      final bool isCorrect;
      if (_step == 1) {
        isCorrect =
            _s1Placed['plasma'] == 'plasma' &&
            _s1Placed['wbc'] == 'wbc' &&
            _s1Placed['rbc'] == 'rbc';
      } else {
        var orderOk = true;
        for (var i = 1; i <= 5; i++) {
          if (_s2Placed[i] != _kS2Order[i - 1]) orderOk = false;
        }
        isCorrect = orderOk && _isSafe == true && _reason == 'reason1';
      }
      setState(() {
        _verifying = false;
        _feedback = isCorrect ? 'correct' : 'wrong';
        _advancing = isCorrect;
      });
      if (isCorrect) {
        _pulseCtrl.stop();
        _pulseCtrl.value = 1;
        _rt_playSfx(_rt_Sfx.correct);
        _after(2000, () {
          if (_step == 1) {
            _transitionToS2();
          } else {
            _showConclusion();
          }
        });
      } else {
        _rt_playSfx(_rt_Sfx.wrong);
        _pulseCtrl.repeat(reverse: true);
      }
    });
  }

  void _transitionToS2() {
    _pulseCtrl.stop();
    setState(() {
      _step = 2;
      _feedback = null;
      _advancing = false;
      _hintBand = null;
      _s2Placed.clear(); // loadTokens_S2
      _isSafe = null;
      _reason = null;
      _instrOffset = Offset.zero;
      _actionOffset = Offset.zero;
    });
    _s2Ctrl.forward(from: 0);
  }

  Future<void> _showConclusion() async {
    setState(() => _advancing = false);
    await _shell.showSuccess(
      title: _tx.s('conclusion_title'),
      message: _tx.s('conclusion_text'),
      buttonLabel: _tx.s('restart_lab'),
      icon: Icons.check_circle,
      color: _rt_Tw.red500,
      onConfirm: () {
        if (mounted) _restart(); // closing the popup just leaves the lab as is
      },
    );
  }

  /// Full reset (HTML `resetLab` / RESTART LAB reload the page).
  void _restart() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
    _gen++;
    _spinCtrl.stop();
    _spinCtrl.value = 0;
    _s2Ctrl.stop();
    _s2Ctrl.value = 0;
    _pulseCtrl.stop();
    _pulseCtrl.value = 1;
    setState(() {
      _step = 1;
      _spinning = false;
      _spinDone = false;
      _s1Placed.clear();
      _s2Placed.clear();
      _isSafe = null;
      _reason = null;
      _feedback = null;
      _verifying = false;
      _advancing = false;
      _hintBand = null;
      _locked = true;
      _panMode = false;
      _showLabels = true;
      _zoom = 1;
      _pan = Offset.zero;
      _instrOffset = Offset.zero;
      _actionOffset = Offset.zero;
      _instrCollapsed = false;
      _actionCollapsed = false;
    });
  }

  // ----------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
      },
      child: _rt_LangBuilder(
        builder: (context, _) => _rt_ActivityShell(
          controller: _shell,
          title: _tx.s('app_title'),
          subtitle: _tx.s('header_subtitle'),
          theme: const _rt_ShellTheme(
            accent: _rt_Tw.red600,
            headerGradient: [_rt_Tw.slate950, Color(0xFF450A0A)],
            headerSubtitleColor: Color(0xFFFCA5A5),
          ),
          intro: _rt_IntroConfig(
            title: _tx.s('app_title'),
            subtitle: _tx.s('app_subtitle'),
            buttonLabel: _tx.s('start_mission'),
            icon: Icons.science,
            buttonIcon: Icons.arrow_forward,
          ),
          onRestart: _restart,
          onZoomIn: () => _zoomBy(0.1),
          onZoomOut: () => _zoomBy(-0.1),
          onResetView: _resetView,
          toolbarExtras: [
            _toolButton(
              icon: _locked ? Icons.lock : Icons.lock_open,
              tip: _tx.s('ui.tool_lock'),
              active: _locked,
              onTap: _toggleLock,
            ),
            const SizedBox(height: 4),
            _toolButton(
              icon: Icons.pan_tool,
              tip: _tx.s('ui.tool_pan'),
              active: _panMode,
              onTap: _togglePan,
            ),
            const SizedBox(height: 4),
            _toolButton(
              icon: _showLabels ? Icons.label : Icons.label_off,
              tip: _tx.s('ui.tool_labels'),
              active: _showLabels,
              onTap: _toggleLabels,
            ),
          ],
          sidebarTop: _progressHeader(),
          tabs: [
            _rt_ShellTab(
              label: _tx.s('mission_objective_title'),
              icon: Icons.menu_book,
              builder: (_) => _boardTab(),
            ),
          ],
          canvasBackground: const Color(0xFFCBD5E1),
          canvas: _buildCanvas(),
          canvasOverlays: [
            Positioned.fill(child: _buildHudLayer()),
            // Any press closes the S1 hint popup (HTML `closeHint`).
            if (_hintBand != null)
              Positioned.fill(
                child: Listener(
                  behavior: HitTestBehavior.translucent,
                  onPointerDown: (_) => setState(() => _hintBand = null),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _toolButton({
    required IconData icon,
    required String tip,
    required bool active,
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
            color: active ? _rt_Tw.red500 : _rt_Lab.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 18,
            color: active ? Colors.white : _rt_Lab.textMuted,
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------ sidebar ---
  Widget _progressHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _rt_Lab.overlay,
        border: Border(bottom: BorderSide(color: _rt_Lab.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _tx.s('ui.lab_progress').toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.8,
              color: _rt_Tw.red500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_tx.s('ui.step')} $_step/2',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: _rt_Lab.text,
            ),
          ),
        ],
      ),
    );
  }

  /// `teacher_fact` keeps the HTML `<b>` markup; render it as bold spans.
  List<TextSpan> _boldSpans(String s, TextStyle bold) {
    final spans = <TextSpan>[];
    var last = 0;
    for (final m in RegExp(r'<b>(.*?)</b>').allMatches(s)) {
      if (m.start > last) spans.add(TextSpan(text: s.substring(last, m.start)));
      spans.add(TextSpan(text: m.group(1), style: bold));
      last = m.end;
    }
    if (last < s.length) spans.add(TextSpan(text: s.substring(last)));
    return spans;
  }

  Widget _boardTab() {
    Widget stepCard(int n, String key) {
      final active = _step == n;
      return Opacity(
        opacity: active ? 1 : 0.6,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _rt_Lab.surface,
            borderRadius: BorderRadius.circular(12),
            border: active
                ? const Border(left: BorderSide(color: _rt_Tw.red500, width: 4))
                : Border.all(color: _rt_Lab.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$n.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: active ? _rt_Tw.red500 : _rt_Lab.text,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  _tx.s(key),
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _rt_Lab.textMuted,
                    height: 1.45,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _tx.s('mission_objective_title'),
          desc: _tx.s('mission_objective_text'),
          accent: _rt_Tw.red600,
          icon: Icons.gps_fixed,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              stepCard(1, 'teacher_step1'),
              stepCard(2, 'teacher_step2'),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _rt_Lab.surface.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _rt_Lab.border),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.lightbulb,
                      size: 16,
                      color: _rt_Tw.yellow500,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: _boldSpans(
                            _tx.s('teacher_fact'),
                            TextStyle(
                              fontWeight: FontWeight.w900,
                              color: _rt_Lab.text,
                            ),
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 11.5,
                          color: _rt_Lab.textMuted,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _themeSettings(),
            ],
          ),
        ),
      ],
    );
  }

  /// The theme half of the HTML settings modal (text scaling is dropped: the
  /// shell has no equivalent).
  Widget _themeSettings() {
    Widget option(bool dark, IconData icon, String label) {
      final active = _rt_appTheme.isDark == dark;
      return Expanded(
        child: Material(
          color: active ? _rt_Lab.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              _rt_playSfx(_rt_Sfx.tap);
              _rt_appTheme.set(
                dark ? _rt_LabThemeMode.dark : _rt_LabThemeMode.light,
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: active ? _rt_Lab.borderStrong : Colors.transparent,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 14,
                    color: active ? _rt_Lab.text : _rt_Lab.textMuted,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      label,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: active ? _rt_Lab.text : _rt_Lab.textMuted,
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_SectionLabel(
          _tx.s('settings'),
          icon: Icons.tune,
          color: _rt_Tw.red500,
        ),
        Text(
          _tx.s('visTheme').toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: _rt_Lab.textMuted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: _rt_Lab.overlay,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _rt_Lab.border),
          ),
          child: Row(
            children: [
              option(true, Icons.dark_mode, _tx.s('dark')),
              const SizedBox(width: 4),
              option(false, Icons.light_mode, _tx.s('light')),
            ],
          ),
        ),
      ],
    );
  }

  // ------------------------------------------------------------- canvas ---
  Widget _buildCanvas() {
    return LayoutBuilder(
      builder: (context, c) {
        final xf = _sceneXf(c.biggest);
        final canPan = _panMode && !_locked;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanUpdate: canPan ? (d) => setState(() => _pan += d.delta) : null,
          child: MouseRegion(
            cursor: canPan ? SystemMouseCursors.grab : MouseCursor.defer,
            child: Stack(
              clipBehavior: Clip.hardEdge,
              children: [
                // #canvas-container background: wall over floor.
                const Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFF1F5F9),
                          Color(0xFFCBD5E1),
                          Color(0xFF64748B),
                          Color(0xFF475569),
                        ],
                        stops: [0, 0.6, 0.6, 1],
                      ),
                    ),
                  ),
                ),
                // #pan-zoom-container > .svg-scene
                Positioned(
                  left: 0,
                  top: 0,
                  width: 800,
                  height: 600,
                  child: Transform(
                    transform: Matrix4.translationValues(
                      xf.origin.dx,
                      xf.origin.dy,
                      0,
                    )..multiply(Matrix4.diagonal3Values(xf.scale, xf.scale, 1)),
                    child: _buildScene(),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildScene() {
    return AnimatedBuilder(
      animation: Listenable.merge([_spinCtrl, _s2Ctrl]),
      builder: (context, _) {
        final f = _SpinFrame.at(_spinCtrl.value * _kSpinMs / 1000);
        final t2 = _s2Ctrl.value * 1.5;
        final s1 = 1 - t2.clamp(0.0, 1.0);
        final s2 = (t2 - 0.5).clamp(0.0, 1.0);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            if (s1 > 0) ...[
              Positioned(
                left: 80,
                top: 180,
                width: 340,
                height: 340,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: s1,
                    child: CustomPaint(
                      painter: _CentrifugePainter(
                        rotorDeg: f.rotorDeg,
                        lid: f.lid,
                        display: '${f.rpm} ${_tx.s('ui.rpm')}',
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 500,
                top: 300,
                width: 150,
                height: 150,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: s1,
                    child: const CustomPaint(painter: _RackPainter()),
                  ),
                ),
              ),
              Positioned(
                left: 540,
                top: 180,
                width: 70,
                height: 220,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: (f.tubeOpacity * s1).clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: f.tubeOffset,
                      child: Transform.scale(
                        scale: f.tubeScale,
                        child: CustomPaint(
                          painter: _TubePainter(
                            fluid: f.fluid,
                            particles: _particles,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (s2 > 0)
              Positioned(
                left: 350,
                top: 100,
                width: 350,
                height: 350,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: s2,
                    child: const CustomPaint(painter: _TransfusionPainter()),
                  ),
                ),
              ),
            // #scene-labels (toggled by the labels tool).
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: _showLabels ? 1 : 0,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (s1 > 0) ...[
                        _sceneLabel(
                          _tx.s('labels.centrifuge'),
                          200,
                          140,
                          opacity: s1,
                        ),
                        _sceneLabel(
                          _tx.s('labels.tube'),
                          540,
                          140,
                          opacity: s1,
                        ),
                      ],
                      if (_step == 2) ...[
                        _sceneLabel(_tx.s('labels.donor'), 340, 320),
                        _sceneLabel(
                          _tx.s('labels.bag'),
                          590,
                          130,
                          color: _rt_Tw.red500,
                          borderColor: _rt_Tw.red500,
                        ),
                        _sceneLabel(
                          _tx.s('labels.iv_tube'),
                          520,
                          280,
                          color: _rt_Tw.red400,
                          borderColor: _rt_Tw.red400.withValues(alpha: 0.5),
                          small: true,
                        ),
                        _sceneLabel(
                          _tx.s('labels.blood'),
                          600,
                          180,
                          color: _rt_Tw.red600,
                          borderColor: _rt_Tw.red600.withValues(alpha: 0.5),
                          small: true,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            // S1 pins + drop zones (shown once the tube has been spun).
            if (_spinDone && s1 > 0) ..._pins(s1),
          ],
        );
      },
    );
  }

  Widget _sceneLabel(
    String text,
    double left,
    double top, {
    double opacity = 1,
    Color? color,
    Color? borderColor,
    bool small = false,
  }) {
    return Positioned(
      left: left,
      top: top,
      child: Opacity(
        opacity: opacity,
        child: Container(
          padding: small
              ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
              : const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _bgPanel,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: borderColor ?? _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
          child: Text(
            text,
            softWrap: false,
            style: TextStyle(
              fontSize: small ? 12 : 14,
              fontWeight: FontWeight.bold,
              color: color ?? _textMain,
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _pins(double opacity) {
    final interactive = _step == 1;
    return [
      Positioned.fill(
        child: IgnorePointer(
          child: Opacity(
            opacity: opacity,
            child: CustomPaint(painter: _LeaderPainter(_textMuted)),
          ),
        ),
      ),
      for (final band in _kBands) ...[
        Positioned(
          left: 686,
          top: _kPinY[band]! - 22,
          width: 124,
          height: 44,
          child: IgnorePointer(
            ignoring: !interactive,
            child: Opacity(opacity: opacity, child: _s1Zone(band)),
          ),
        ),
        Positioned(
          left: 650,
          top: _kPinY[band]! - 16,
          width: 32,
          height: 32,
          child: IgnorePointer(
            ignoring: !interactive,
            child: Opacity(opacity: opacity, child: _pinHintButton(band)),
          ),
        ),
      ],
    ];
  }

  Widget _pinHintButton(String band) {
    final open = _hintBand == band;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        _rt_playSfx(_rt_Sfx.click);
        setState(() => _hintBand = band);
      },
      child: Center(
        child: Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _bgMain,
            shape: BoxShape.circle,
            border: Border.all(color: open ? _accent : _border),
            boxShadow: const [
              BoxShadow(
                color: Color(0x40000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            '?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: open ? _accent : _textMuted,
            ),
          ),
        ),
      ),
    );
  }

  /// `.tube-dropzone` for one band; holds the token dropped on it.
  Widget _s1Zone(String band) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) =>
          _step == 1 && _spinDone && _kS1Keys.containsKey(d.data),
      onAcceptWithDetails: (d) => _placeS1(d.data, band),
      builder: (context, candidates, _) {
        final token = _s1Placed[band];
        final hot = candidates.isNotEmpty;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: CustomPaint(
            painter: _DashedBorderPainter(
              color: hot ? _accent : const Color(0x8064748B),
              fill: hot ? _accent.withValues(alpha: 0.2) : null,
            ),
            child: Center(
              child: token == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.all(3),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 112),
                          child: _s1Token(token, inScene: true),
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------- tokens ---
  Widget _s1Chip(String token, {bool lifted = false, bool scene = false}) {
    return Material(
      color: _bgMain,
      elevation: lifted ? 10 : 3,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: scene ? 8 : 12,
          vertical: scene ? 4 : 7,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: lifted ? _accent : _border),
        ),
        child: Text(
          _tx.s(_kS1Keys[token]!),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: scene ? 13 : 11,
            fontWeight: FontWeight.bold,
            color: _textMain,
            height: 1.15,
          ),
        ),
      ),
    );
  }

  Widget _s1Token(String token, {bool inScene = false}) {
    return Draggable<String>(
      data: token,
      // Tokens on the (scaled) tube lift with the finger near their left edge.
      dragAnchorStrategy: inScene
          ? (_, _, _) => const Offset(40, 16)
          : childDragAnchorStrategy,
      feedback: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 220),
        child: _s1Chip(token, lifted: true),
      ),
      childWhenDragging: inScene
          ? const SizedBox.shrink()
          : Opacity(opacity: 0.3, child: _s1Chip(token)),
      onDragStarted: () => _rt_playSfx(_rt_Sfx.click),
      onDraggableCanceled: (_, _) =>
          _returnS1(token), // dropped elsewhere: back to the tray
      child: _s1Chip(token, scene: inScene),
    );
  }

  Widget _s2Chip(String token, {bool lifted = false, bool fill = false}) {
    return Material(
      color: _bgMain,
      elevation: lifted ? 10 : 3,
      shadowColor: Colors.black54,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        constraints: fill ? const BoxConstraints(minHeight: 40) : null,
        padding: const EdgeInsets.fromLTRB(8, 5, 5, 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: lifted ? _accent : _border),
        ),
        child: Row(
          mainAxisSize: fill ? MainAxisSize.max : MainAxisSize.min,
          children: [
            const Icon(Icons.water_drop, size: 13, color: _rt_Tw.red500),
            const SizedBox(width: 5),
            Flexible(
              fit: fill ? FlexFit.tight : FlexFit.loose,
              child: Text(
                _tx.s(_kS2Keys[token]!),
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: _textMain,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 6),
            GestureDetector(
              onTap: () => _showS2Hint(token),
              child: Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _bgPanel,
                  shape: BoxShape.circle,
                  border: Border.all(color: _border),
                ),
                child: Text(
                  '?',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _textMuted,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _s2Token(String token, {bool inSlot = false}) {
    return Draggable<String>(
      data: token,
      feedback: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 240),
        child: _s2Chip(token, lifted: true),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _s2Chip(token, fill: inSlot),
      ),
      onDragStarted: () => _rt_playSfx(_rt_Sfx.click),
      onDraggableCanceled: (_, _) =>
          _returnS2(token), // dropped elsewhere: back to the tray
      child: _s2Chip(token, fill: inSlot),
    );
  }

  // -------------------------------------------------------- HUD overlay ---
  Widget _buildHudLayer() {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth, h = c.maxHeight;
        // First frames run in portrait (narrow canvas) before the rotation.
        if (w < 200 || h < 160) return const SizedBox.shrink();
        // While the sidebar is closed the shell's menu button sits top-left.
        final menuInset = _shell.isSidebarOpen ? 8.0 : 72.0;
        // Keep the back button + vertical toolbar column (right) free.
        final rightEdge = w - 72;
        final children = <Widget>[];

        double instrLeft, instrW, actLeft, actW;
        if (_step == 1) {
          instrLeft = menuInset;
          instrW = math.min(300.0, rightEdge - menuInset);
          actW = math.min(320.0, rightEdge - 8);
          // Before the spin keep the centrifuge's RPM display visible; after
          // it keep the tube's drop zones visible.
          actLeft = _spinDone ? 8 : rightEdge - actW;
        } else {
          final railW = ((rightEdge - 8) * 0.42).clamp(150.0, 230.0);
          children.add(
            Positioned(
              left: 8,
              top: menuInset,
              bottom: 8,
              width: railW,
              child: AnimatedBuilder(
                animation: _s2Ctrl,
                // gsap.from('#journey-rail', {x: -300, opacity: 0, ease: back.out})
                builder: (context, child) {
                  final e = _rt_Ease.outBack(
                    (_s2Ctrl.value * 1.5 / 0.8).clamp(0.0, 1.0),
                  );
                  return Transform.translate(
                    offset: Offset(-300 * (1 - e), 0),
                    child: Opacity(opacity: e.clamp(0.0, 1.0), child: child),
                  );
                },
                child: _journeyRail(),
              ),
            ),
          );
          final besideRail = 8 + railW + 8;
          final left = rightEdge - besideRail >= 220 ? besideRail : 8.0;
          instrLeft = left;
          instrW = math.min(300.0, rightEdge - left);
          actLeft = left;
          actW = math.min(380.0, rightEdge - left);
        }
        instrW = instrW.clamp(160.0, w - 16);
        actW = actW.clamp(160.0, w - 16);

        // Instruction HUD (top, draggable by its header).
        final iLeft = (instrLeft + _instrOffset.dx)
            .clamp(0.0, math.max(0.0, w - instrW))
            .toDouble();
        final iTop = (8 + _instrOffset.dy)
            .clamp(0.0, math.max(0.0, h - 48))
            .toDouble();
        children.add(
          Positioned(
            left: iLeft,
            top: iTop,
            width: instrW,
            child: _instructionHud(
              maxHeight: math.max(40.0, math.min(h * 0.42, h - iTop - 8)),
              onDrag: (d) => setState(() {
                _instrOffset = Offset(
                  iLeft + d.delta.dx - instrLeft,
                  iTop + d.delta.dy - 8,
                );
              }),
            ),
          ),
        );

        // Action HUD (bottom, draggable by its header).
        final aLeft = (actLeft + _actionOffset.dx)
            .clamp(0.0, math.max(0.0, w - actW))
            .toDouble();
        final aBottom = (8 - _actionOffset.dy)
            .clamp(0.0, math.max(0.0, h - 48))
            .toDouble();
        children.add(
          Positioned(
            left: aLeft,
            bottom: aBottom,
            width: actW,
            child: _actionHud(
              maxHeight: math.max(40.0, math.min(h * 0.62, h - aBottom - 8)),
              onDrag: (d) => setState(() {
                _actionOffset = Offset(
                  aLeft + d.delta.dx - actLeft,
                  8 - (aBottom - d.delta.dy),
                );
              }),
            ),
          ),
        );

        // #hint-popup under the pressed "?" pin.
        final hintBand = _hintBand;
        if (hintBand != null && _step == 1) {
          final xf = _sceneXf(Size(w, h));
          final anchor =
              xf.origin + Offset(666, _kPinY[hintBand]! + 14) * xf.scale;
          final pw = math.min(220.0, w - 16);
          children.add(
            Positioned(
              left: (anchor.dx - pw / 2).clamp(8.0, math.max(8.0, w - pw - 8)),
              top: (anchor.dy + 8).clamp(8.0, math.max(8.0, h - 80)),
              width: pw,
              child: IgnorePointer(
                child: _hintPopup(_tx.s(_kS1HintKeys[hintBand]!)),
              ),
            ),
          );
        }
        return Stack(clipBehavior: Clip.none, children: children);
      },
    );
  }

  Widget _hintPopup(String text) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _bgPanel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _accent, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          color: _textMain,
          height: 1.3,
        ),
      ),
    );
  }

  /// Glass HUD card with a draggable header (tap the header to fold it).
  Widget _hudPanel({
    required String label,
    required bool accentOnTop,
    required double maxHeight,
    required bool collapsed,
    required VoidCallback onToggle,
    required GestureDragUpdateCallback onDrag,
    required Widget child,
  }) {
    final strip = Container(height: 4, color: _accent);
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          color: _glass,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _glassBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (accentOnTop) strip,
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: onDrag,
                onTap: () {
                  _rt_playSfx(_rt_Sfx.tap);
                  onToggle();
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.move,
                  child: Container(
                    color: _bgMain,
                    padding: const EdgeInsets.fromLTRB(10, 5, 8, 5),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              color: _textMain,
                            ),
                          ),
                        ),
                        Icon(
                          collapsed ? Icons.expand_more : Icons.expand_less,
                          size: 15,
                          color: _textMuted,
                        ),
                        const SizedBox(width: 4),
                        Icon(Icons.open_with, size: 14, color: _textMuted),
                      ],
                    ),
                  ),
                ),
              ),
              if (!collapsed)
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(10),
                    child: child,
                  ),
                ),
              if (!accentOnTop) strip,
            ],
          ),
        ),
      ),
    );
  }

  /// #instruction-hud
  Widget _instructionHud({
    required double maxHeight,
    required GestureDragUpdateCallback onDrag,
  }) {
    final title = _tx.s(_step == 1 ? 's1_title' : 's2_title');
    final desc = _tx.s(
      _step == 1 ? (_spinDone ? 's1_desc_post' : 's1_desc_pre') : 's2_desc',
    );
    return _hudPanel(
      label: _tx.s('instructions_title'),
      accentOnTop: true,
      maxHeight: maxHeight,
      collapsed: _instrCollapsed,
      onToggle: () => setState(() => _instrCollapsed = !_instrCollapsed),
      onDrag: onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: TextStyle(fontSize: 12, color: _textMain, height: 1.3),
          ),
          if (_feedback != null) ...[const SizedBox(height: 8), _feedbackBox()],
        ],
      ),
    );
  }

  /// #inst-feedback
  Widget _feedbackBox() {
    final ok = _feedback == 'correct';
    final c = ok ? _rt_Tw.green500 : _rt_Tw.red500;
    final box = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.withValues(alpha: 0.5)),
      ),
      child: Text(
        _tx.s(ok ? 'ui.feedback_correct' : 'ui.feedback_wrong'),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: ok
              ? (_dark ? _rt_Tw.green400 : _rt_Tw.green700)
              : (_dark ? _rt_Tw.red400 : _rt_Tw.red700),
        ),
      ),
    );
    return ok
        ? box
        : FadeTransition(
            opacity: _pulseCtrl.drive(Tween(begin: 0.5, end: 1.0)),
            child: box,
          );
  }

  /// #action-hud: spin button, then token tray + Reset Step / VERIFY.
  Widget _actionHud({
    required double maxHeight,
    required GestureDragUpdateCallback onDrag,
  }) {
    final labelling = _step == 2 || _spinDone;
    return _hudPanel(
      label: _tx.s('missionReady'),
      accentOnTop: false,
      maxHeight: maxHeight,
      collapsed: _actionCollapsed,
      onToggle: () => setState(() => _actionCollapsed = !_actionCollapsed),
      onDrag: onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!labelling)
            Opacity(
              opacity: _spinning ? 0.5 : 1,
              child: _gradientButton(
                label: _tx.s('start_centrifuge').toUpperCase(),
                icon: Icons.autorenew,
                colors: const [_rt_Tw.blue600, _rt_Tw.blue500],
                border: _rt_Tw.blue400,
                vertical: 12,
                onTap: _spinning ? null : _startSpin,
              ),
            ),
          if (labelling) ...[
            _tray(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _gradientButton(
                    label: _tx.s('btn_reset'),
                    icon: Icons.restart_alt,
                    colors: const [_rt_Tw.slate800, _rt_Tw.slate800],
                    border: _rt_Tw.slate700,
                    onTap: _resetCurrentPhase,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: _gradientButton(
                    label: _tx.s('btn_verify'),
                    icon: Icons.check_circle,
                    colors: const [_rt_Tw.red600, _rt_Tw.red500],
                    border: _rt_Tw.red400,
                    busy: _verifying,
                    onTap: _verifyStep,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// #hud-tray: the tokens that are not placed yet.
  Widget _tray() {
    final tokens = _step == 1
        ? [
            for (final t in _kBands)
              if (!_s1Placed.containsValue(t)) _s1Token(t),
          ]
        : [
            for (final t in _kS2Order)
              if (!_s2Placed.containsValue(t)) _s2Token(t),
          ];
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 40),
      child: Center(
        child: Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: tokens,
        ),
      ),
    );
  }

  Widget _gradientButton({
    required String label,
    required IconData icon,
    required List<Color> colors,
    required Color border,
    required VoidCallback? onTap,
    bool busy = false,
    double vertical = 9,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: colors.last.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap == null || busy ? null : onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: vertical),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 20),
              child: busy
                  ? const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 16, color: Colors.white),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 11.5,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------ journey rail ---
  /// #journey-rail: five ordered drop slots + the safety question.
  Widget _journeyRail() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _glass,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _glassBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _tx.s('ui.journey_title').toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: _accent,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 1; i <= 5; i++) ...[
                    _journeySlot(i),
                    if (i < 5)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Icon(
                          Icons.arrow_downward,
                          size: 14,
                          color: _textMuted,
                        ),
                      ),
                  ],
                  const SizedBox(height: 10),
                  _safetyBox(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _journeySlot(int slot) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (d) =>
          _step == 2 &&
          _kS2Keys.containsKey(d.data) &&
          (_s2Placed[slot] == null || _s2Placed[slot] == d.data),
      onAcceptWithDetails: (d) => _placeS2(d.data, slot),
      builder: (context, candidates, _) {
        final token = _s2Placed[slot];
        if (token != null) {
          return SizedBox(
            width: double.infinity,
            child: _s2Token(token, inSlot: true),
          );
        }
        final hot = candidates.isNotEmpty;
        return CustomPaint(
          painter: _DashedBorderPainter(
            color: hot ? _rt_Tw.red500 : _textMuted,
            fill: hot ? _rt_Tw.red500.withValues(alpha: 0.1) : null,
          ),
          child: SizedBox(
            width: double.infinity,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 40),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: Text(
                    _tx.s('slot${slot}_hint'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: hot ? _rt_Tw.red500 : _textMuted,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _safetyBox() {
    Widget choice(bool safe) {
      final selected = _isSafe == safe;
      final c = safe ? _rt_Tw.green500 : _rt_Tw.red500;
      return Expanded(
        child: Material(
          color: selected ? c.withValues(alpha: 0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _selectSafety(safe),
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: selected ? c : _border),
              ),
              child: Text(
                _tx.s(safe ? 'safe_yes' : 'safe_no'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: selected ? c : _textMuted,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _bgMain,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _tx.s('safety_question'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
              color: _textMain,
            ),
          ),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [choice(true), const SizedBox(width: 6), choice(false)],
            ),
          ),
          // #safety-reason appears once Yes/No has been chosen.
          if (_isSafe != null) ...[const SizedBox(height: 8), _reasonPicker()],
        ],
      ),
    );
  }

  Widget _reasonPicker() {
    final reason = _reason;
    return PopupMenuButton<String>(
      tooltip: _tx.s('select_reason'),
      onSelected: _selectReason,
      color: _bgPanel,
      itemBuilder: (context) => [
        for (final r in _kReasons)
          PopupMenuItem<String>(
            value: r,
            child: Text(
              _tx.s(r),
              style: TextStyle(fontSize: 12, color: _textMain),
            ),
          ),
      ],
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
        decoration: BoxDecoration(
          color: _bgPanel,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                reason == null ? _tx.s('select_reason') : _tx.s(reason),
                style: TextStyle(
                  fontSize: 10.5,
                  color: reason == null ? _textMuted : _textMain,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down, size: 18, color: _textMuted),
          ],
        ),
      ),
    );
  }
}
