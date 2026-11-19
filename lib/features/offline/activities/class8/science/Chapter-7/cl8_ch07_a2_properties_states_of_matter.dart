// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 7.2: Properties of States of Matter
// Converted from Cl8S-Ch7-A2-Properties_of_States_of_Matter.html (three.js -> mini3d).
//
// Five scenarios chosen from a sidebar dropdown: (1) Solids & Rigidity — strike
// an iron nail with a hammer, then inspect a stone's particles through a
// microscope viewer with a spacing slider; (2) Liquid Shape & Volume — measure
// 200 mL in Container A, pour A->B->C and confirm the shape changes while the
// volume stays fixed; (3) Compressibility — push the air and water syringe
// plungers, then tag them [Compressible]/[Incompressible]; (4) Rice Grain
// Paradox — pour bulk rice into a jar, tilt a single grain under the lens and
// classify rice as a solid; (5) Spilled Milk — knock over the tumbler, map the
// puddle's irregular boundary, caliper the glass and finish a word-fill proof.
// Every scenario ends with the source's "Final Observation" outcome popup.




// --- TRANSLATION DATA (SCENARIOS + T dictionaries of the source) ---

import 'dart:async';
import 'dart:math' as math;


import 'package:audioplayers/audioplayers.dart' as ap;
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
// Activity-local feedback service: short tones bundled in assets/audio/class8/ (the
// same files the Math Zone pages use). Moving this page to another app means
// taking those files and the `audioplayers` dependency along with it.
enum _rt_Sfx { click, tap, toggle, scenario, correct, wrong, success, curtain, pop, magic }

class _rt_SoundService {
  _rt_SoundService._();
  static final _rt_SoundService instance = _rt_SoundService._();
  bool enabled = true;

  /// The tone (path under assets/) played for each effect.
  static const Map<_rt_Sfx, String> _files = {
    _rt_Sfx.click: 'audio/class8/mixkit_2568.mp3',
    _rt_Sfx.tap: 'audio/class8/mixkit_2568.mp3',
    _rt_Sfx.toggle: 'audio/class8/mixkit_2568.mp3',
    _rt_Sfx.scenario: 'audio/class8/mixkit_2574.mp3',
    _rt_Sfx.correct: 'audio/class8/mixkit_2013.mp3',
    _rt_Sfx.wrong: 'audio/class8/mixkit_955.mp3',
    _rt_Sfx.success: 'audio/class8/mixkit_2018.mp3',
    _rt_Sfx.curtain: 'audio/class8/mixkit_2988.mp3',
    _rt_Sfx.pop: 'audio/class8/mixkit_2690.mp3',
    _rt_Sfx.magic: 'audio/class8/mixkit_2000.mp3',
  };

  /// One player per effect, created on first use.
  final Map<_rt_Sfx, ap.AudioPlayer> _players = {};

  void preload() {}

  Future<void> play(_rt_Sfx sfx, {double volume = 1.0}) async {
    if (!enabled) return;
    try {
      final player = _players.putIfAbsent(sfx, ap.AudioPlayer.new);
      await player.stop();
      await player.play(ap.AssetSource(_files[sfx]!), volume: volume);
    } catch (_) {
      // No audio output (or no audio plugin, as in widget tests): fall back
      // to the platform click so the action still gets feedback.
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {}
    }
  }

  Future<void> stop(_rt_Sfx sfx) async {
    try {
      await _players[sfx]?.stop();
    } catch (_) {}
  }
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
    'appTitle': 'Properties of States of Matter',
    'appSub': 'Class 8 • Particulate Nature of Matter',
    'enterLab': 'Enter _rt_Lab',
    'footnote': 'Solid • Liquid • Gas',
    'tabExperiment': 'Experiment',
    'selectScenario': 'Select Scenario',
    'action': 'Action',
    'waiting': 'Waiting...',
    'reopen': 'Re-open Question',
    'theoryLbl': 'Theory',
    'stepsLbl': 'Steps',
    'toolLabels': 'Toggle labels',
    'done': 'Done',
    'continue': 'Continue',
    'tryAgain': 'Try Again',
    'finalObs': 'Final Observation',
    'whatWeLearned': 'What we learned:',
    'scen': [
      {
        'title': 'Scenario 1: Solids & Rigidity (Act 7.3)',
        'theory':
            'Solids have a definite shape, distinct boundaries, and fixed volumes. They have negligible compressibility.',
        'outcome':
            'Solids have a fixed shape and volume. Their particles are tightly packed together, making them highly rigid and incapable of changing shape when subjected to normal external forces.',
        'steps': [
          {
            't': 'Theory & Setup',
            'i': 'Observe the materials provided on the table: an iron nail, a stone, a hammer, and a microscope. These objects represent solid matter.',
          },
          {
            't': 'Testing Rigidity',
            'i': "Use the hammer to strike the iron nail. Observe closely if the applied force causes any change in the nail's physical shape or its boundaries.",
            'g': 'Drag the Hammer to strike the Iron Nail.',
            'btn': 'Strike Nail',
          },
          {
            't': 'Particle Inspection',
            'i': 'Use the microscope to look inside the stone. Adjust the slider to see how particles are tightly arranged together in a solid state.',
            'g': 'Drag the Microscope lens over the Stone.',
            'btn': 'Use Microscope',
          },
          {
            't': 'Conclusion',
            'i': 'Solids maintain their distinct shape and have clear boundaries even when subjected to external outside force. The particles are tightly packed and highly ordered.',
            'g': 'Scenario complete! Select another scenario.',
            'btn': 'Review Result',
          },
        ],
      },
      {
        'title': 'Scenario 2: Liquid Shape & Volume (Act 7.4)',
        'theory':
            'Liquids have no fixed shape but have a fixed volume. They take the shape of the container.',
        'outcome':
            'Liquids have a fixed volume but no fixed shape. They conform to the shape of the container they are poured into, demonstrating fluidity and lack of rigidity.',
        'steps': [
          {
            't': 'Theory & Setup',
            'i': 'You have three uniquely shaped containers (A, B, and C). Container A is a regular cylinder currently holding some liquid (water).',
          },
          {
            't': 'Establishing Initial Volume',
            'i': 'Click the measure button to determine and tag the exact initial volume of the liquid in Container A.',
            'g': "Click the 'Measure' button on Container A.",
            'btn': 'Measure Volume',
            'btn2': 'Attach 200 mL Tag',
          },
          {
            't': 'Transferring to Container B',
            'i': 'Transfer the liquid from the cylindrical container (A) into the conical flask (Container B). Observe what happens to the shape of the liquid.',
            'g': 'Drag Container A over Container B to pour.',
            'btn': 'Pour A into B',
            'btn2': 'Measure Container B',
          },
          {
            't': 'Transferring to Container C',
            'i': 'Transfer the liquid again, this time into the flat-bottomed flask (Container C). Take note of the final shape and whether the total volume changed.',
            'g': 'Drag Container B over Container C.',
            'btn': 'Pour B into C',
            'btn2': 'Open Question',
          },
          {
            't': 'Conclusion',
            'i': 'Liquids fluidly flow and immediately take the shape of any container they are placed in, but importantly, their total volume remains completely fixed.',
            'g': 'Scenario complete!',
            'btn': 'Review Result',
          },
        ],
      },
      {
        'title': 'Scenario 3: Compressibility (Act 7.6)',
        'theory':
            'Gases are highly compressible compared to solids and liquids. Large volumes of gas can be compressed into small cylinders.',
        'outcome':
            'Gases have large spaces between their particles, making them highly compressible. Liquids, on the other hand, have tightly packed particles and cannot be easily compressed.',
        'steps': [
          {
            't': 'Theory & Setup',
            'i': 'Two identical closed syringes are provided on the setup. One is filled with air (representing a gas) and the other with water (representing a liquid).',
          },
          {
            't': 'Compressing Air',
            'i': 'Push the plunger of the air syringe downwards to apply heavy pressure. Notice how much the volume of the gas decreases.',
            'g': 'Slide the controller for the Air Syringe downwards.',
            'btn': 'Push Air Plunger',
          },
          {
            't': 'Compressing Water',
            'i': 'Now, attempt to forcefully push the plunger of the water syringe. Observe the mechanical resistance and the final internal volume.',
            'g': 'Slide the controller for the Water Syringe downwards.',
            'btn': 'Push Water Plunger',
          },
          {
            't': 'Comparative Conclusion',
            'i': 'Categorize both substances accurately by dragging the correct classification tags to their respective syringes based on your earlier compression tests.',
            'g': 'Drag [Compressible] and [Incompressible] tags to the correct syringe.',
            'btn': 'Use the Tags on the Canvas',
          },
          {
            't': 'Conclusion',
            'i': 'Gases are highly compressible due to large inter-particle spaces, whereas liquids are nearly incompressible due to tight spaces.',
            'g': 'Scenario complete!',
            'btn': 'Review Result',
          },
        ],
      },
      {
        'title': 'Scenario 4: Rice Grain Paradox (Q 10)',
        'theory': 'Rice takes the shape of a jar. Does this make it a liquid?',
        'outcome':
            "Although bulk materials like rice or sugar seem to 'flow' and take the shape of a container, each individual grain retains its fixed shape. Thus, they are classified as solids.",
        'steps': [
          {
            't': 'Theory & Setup',
            'i': 'On the table, you have a bowl full of bulk rice and an empty transparent glass jar to test the macroscopic behavior of granules.',
          },
          {
            't': 'Bulk Observation',
            'i': 'Pour the bulk rice into the glass jar. Notice how the pile of rice completely conforms to the shape of the jar, behaving similar to a liquid.',
            'g': 'Drag the bowl of rice over the Glass Jar.',
            'btn': 'Pour Rice into Jar',
          },
          {
            't': 'Individual Observation',
            'i': 'Use the magnifying glass to closely inspect a single isolated grain of rice. Tilt it to see if its individual structural shape changes at all.',
            'g': 'Drag the Magnifying Glass over the rice inside the jar.',
            'btn': 'Inspect Single Grain',
          },
          {
            't': 'Conclusion',
            'i': 'Answer the logical deduction popup regarding the true state of matter of the rice based on the individual grain\'s behavior.',
            'g': 'Complete the logic puzzle in the popup.',
            'btn': 'Open Question',
          },
          {
            't': 'Finished',
            'i': 'Even though bulk granular materials like rice or sand can flow, they are solids because their individual constituent particles confidently maintain a fixed, rigid shape.',
            'g': 'Scenario complete!',
            'btn': 'Review Result',
          },
        ],
      },
      {
        'title': 'Scenario 5: Spilled Milk (Q 5)',
        'theory':
            'Justify why milk is a liquid and the tumbler is a solid based on behavior during a spill.',
        'outcome':
            'Matter is classified by physical behavior. Milk flows and spreads on the surface (fluidity), classifying it as a liquid. The glass tumbler maintains a rigid, fixed boundary, proving it is a solid.',
        'steps': [
          {
            't': 'Theory & Setup',
            'i': 'A standard rigid glass tumbler completely filled with milk is placed stably on the table surface.',
          },
          {
            't': 'The Spill',
            'i': 'Apply a lateral force to decisively knock over the tumbler. Carefully watch how the contained milk and the glass itself behave upon impact.',
            'g': 'Swipe/drag the Tumbler to the right to tip it over.',
            'btn': 'Tip the Tumbler',
          },
          {
            't': 'Analyzing the Milk (Fluidity)',
            'i': 'Click on three different outer edge points of the spilled milk puddle to map its irregular, continuously flowing boundary.',
            'g': 'Click 3 points on the spilled milk puddle to measure its shape.',
            'btn': 'Mark Edge Point',
          },
          {
            't': 'Analyzing the Tumbler (Rigidity)',
            'i': 'Click on the fallen glass tumbler to measure its structural dimensions using a caliper, checking meticulously for any physical deformation.',
            'g': 'Click on the fallen tumbler to measure it.',
            'btn': 'Measure Tumbler',
          },
          {
            't': 'Final Justification',
            'i': 'Complete the provided sentences via the popup to formally justify the states of matter based strictly on fluidity and rigidity metrics.',
            'g': 'Complete the sentence logic in the popup.',
            'btn': 'Open Question',
          },
          {
            't': 'Finished',
            'i': 'The milk evidently demonstrated fluidity (classifying it as liquid), while the hard tumbler clearly maintained its fixed shape (classifying it as solid).',
            'g': 'Scenario complete!',
            'btn': 'Review Result',
          },
        ],
      },
    ],
    // Static tags
    'tagComp': '[Compressible]',
    'tagIncomp': '[Incompressible]',
    'tag200': '200 mL',
    'tag200Tagged': '200 mL [TAGGED]',
    'tagFluid': 'Fluidity (Flows)',
    'tagRigid': 'Rigid (Fixed Shape)',
    'tagsLbl': 'Tags',
    'tapTagHint': 'Tap a tag, then tap its target (or drag it there).',
    // 3D canvas labels
    'ironNail': 'Iron Nail',
    'hammer': 'Hammer',
    'stone': 'Stone',
    'microscope': 'Microscope',
    'contA': 'Container A',
    'contB': 'Container B',
    'contC': 'Container C',
    'measure': 'Measure',
    'airGas': 'Air (Gas)',
    'waterLiq': 'Water (Liquid)',
    'pushGas': 'Push Gas',
    'pushLiq': 'Push Liquid',
    'glassJar': 'Glass Jar',
    'riceBulk': 'Rice Bulk',
    'glassMilk': 'Glass of Milk',
    'irregBound': 'Irregular Boundary',
    'mlUnit': 'mL',
    // Modals & popup logic (S1)
    'obs': 'Observation',
    's1q1': 'Did the Iron Nail change its shape to fit the Hammer?',
    'yes': 'Yes',
    'no': 'No',
    'incorrect': 'Incorrect',
    's1q1err': 'Solids retain shape even under force.',
    'correct': 'Correct!',
    's1q1corr': 'Solids maintain shape even subjected to outside force.',
    'interPart': 'Inter-particle Space',
    'tight': 'Tightly Packed (Solid)',
    'loose': 'Loose',
    'verifyStruct': 'Verify Structure',
    's1q2corr': 'In solids, particles are tightly packed.',
    's1q2err': '✗ Try Again: Slide all the way to 0.',
    // S2
    'measComp': 'Measurement Complete',
    's2q1':
        'The volume is 200 mL.\n\nNext Step: Drag the new [200 mL] tag from the bottom of the screen and drop it onto Container A.',
    'gotIt': 'Got it!',
    's2q2': 'Has the shape changed?',
    's2q2err': "Look at Container B's conical shape.",
    'awesome': 'Awesome!',
    's2q2corrHover': "Has volume changed? Click 'Measure' on Container B to find out.",
    's2q3': 'The volume is still 200 mL. This confirms liquids have a fixed volume!',
    'assessment': 'Assessment',
    's2q4': 'Complete the sentence based on your observations.',
    'waterChanged': 'The water changed its:',
    'keptVol': 'but kept a fixed volume of:',
    'submit': 'Submit',
    'shape': 'Shape',
    'color': 'Color',
    'temp': 'Temperature',
    'vol200': '200 mL',
    'vol100b': '100 mL',
    'vol500': '500 mL',
    's2q4corr': 'It changed shape but kept a 200mL volume.',
    's2q4err': "Hint: It changed its 'Shape' and kept '200 mL'.",
    // S3
    'excellent': 'Excellent',
    's3q1corr': 'You compressed the gas volume down to ~10 mL.',
    'obsNoted': 'Observation Noted',
    's3q2corr': 'The system resists the drag. Water is incompressible.',
    's3q3err1': 'Water is not compressible.',
    's3q3err2': 'Air can be compressed.',
    'fantastic': 'Fantastic!',
    's3q3corr': 'Air is compressible. Water is incompressible.',
    'drag200A': 'Now drag the [200 mL] tag onto Container A.',
    // S4
    'tiltJar': 'Tilt Jar (Check single grain)',
    'analyze': 'Analyze Shape',
    'bulkObs': 'Bulk Observation',
    's4q1': 'The bulk pile of rice took the shape of the container.',
    'true': 'True',
    'false': 'False',
    's4q1corr': 'The pile conforms to the cylinder.',
    's4q1err': 'Look closely, the pile is now cylindrical.',
    'conclusion': 'Conclusion',
    's4q2': 'Classify the state of matter:',
    'indShape': 'Individual Grain Shape:',
    'fixed': 'Fixed',
    'changing': 'Changing',
    'thereforeRice': 'Therefore, Rice is:',
    'solid': 'Solid',
    'liquid': 'Liquid',
    's4q2corr':
        "The shape of each individual grain remains fixed. The 'flow' is just the movement of many solid particles.",
    's4q2err': 'Hint: Did the single grain change shape when tilted?',
    // S5
    'spill': 'Spill!',
    's5q1': 'The milk poured out and spread across the surface.',
    'fluidity': 'Fluidity',
    's5q2': 'The boundary is irregular and flat, unlike the tumbler.',
    'ok': 'OK',
    'analyzingRigid': 'Analyzing Rigidity',
    's5q3': 'Did the dimensions of the glass change after falling?',
    'useCaliper': 'Use Caliper to Measure',
    's5q3corr':
        'Measurement reads 8 cm (same as before the fall). The glass kept its rigid shape.',
    'finalJust': 'Final Justification',
    's5q4': 'Drag, drop, or click the correct words to complete the sentences:',
    'verifyAns': 'Verify Answers',
    's5q4corr': 'You perfectly classified the properties based on behavior.',
    's5q4err': 'Please review your word placements.',
    'milkIsA': 'Milk is a',
    'becauseIt': 'because it',
    'tumblerIsA': 'The Tumbler is a',
    'becauseItMaintains': 'because it maintains a',
    'clickToClear': '(Click a slot to clear it)',
    'flowsSpreads': 'Flows/Spreads',
    'fixedShape': 'Fixed Shape',
    'dragFluidity': 'Drag [Fluidity (Flows)] tag to the label.',
    'dragRigid': 'Drag [Rigid (Fixed Shape)] tag to the label.',
  },
  'hi': {
    'appTitle': 'पदार्थ की अवस्थाओं के गुण',
    'appSub': 'कक्षा 8 • पदार्थ की कण प्रकृति',
    'enterLab': 'लैब में प्रवेश करें',
    'footnote': 'ठोस • तरल • गैस',
    'tabExperiment': 'प्रयोग',
    'selectScenario': 'परिदृश्य चुनें',
    'action': 'कार्रवाई',
    'waiting': 'प्रतीक्षा में...',
    'reopen': 'प्रश्न फिर से खोलें',
    'theoryLbl': 'सिद्धांत',
    'stepsLbl': 'चरण',
    'toolLabels': 'लेबल टॉगल करें',
    'done': 'संपन्न',
    'continue': 'जारी रखें',
    'tryAgain': 'पुनः प्रयास करें',
    'finalObs': 'अंतिम अवलोकन',
    'whatWeLearned': 'हमने क्या सीखा:',
    'scen': [
      {
        'title': 'परिदृश्य 1: ठोस और कठोरता (गतिविधि 7.3)',
        'theory':
            'ठोस का एक निश्चित आकार, स्पष्ट सीमाएँ और निश्चित आयतन होता है। इनकी संपीड्यता नगण्य होती है।',
        'outcome':
            'ठोस का आकार और आयतन निश्चित होता है। इसके कण आपस में कसकर बंधे होते हैं, जिससे वे अत्यधिक कठोर हो जाते हैं और सामान्य बलों के अधीन होने पर आकार बदलने में असमर्थ होते हैं।',
        'steps': [
          {
            't': 'सिद्धांत और सेटअप',
            'i': 'मेज पर उपलब्ध सामग्रियों का निरीक्षण करें: एक लोहे की कील, एक पत्थर, एक हथौड़ा और एक सूक्ष्मदर्शी। ये वस्तुएं ठोस पदार्थ का प्रतिनिधित्व करती हैं।',
          },
          {
            't': 'कठोरता का परीक्षण',
            'i': 'लोहे की कील पर प्रहार करने के लिए हथौड़े का प्रयोग करें। ध्यान से देखें कि क्या लगाया गया बल कील के भौतिक आकार या उसकी सीमाओं में कोई परिवर्तन लाता है।',
            'g': 'लोहे की कील पर प्रहार करने के लिए हथौड़े को खींचें।',
            'btn': 'कील पर प्रहार करें',
          },
          {
            't': 'कण निरीक्षण',
            'i': 'पत्थर के अंदर देखने के लिए सूक्ष्मदर्शी का उपयोग करें। स्लाइडर को यह देखने के लिए समायोजित करें कि ठोस अवस्था में कण कितनी कसकर व्यवस्थित होते हैं।',
            'g': 'सूक्ष्मदर्शी लेंस को पत्थर के ऊपर खींचें।',
            'btn': 'सूक्ष्मदर्शी का उपयोग करें',
          },
          {
            't': 'निष्कर्ष',
            'i': 'ठोस अपना विशिष्ट आकार बनाए रखते हैं और बाहरी बल के अधीन होने पर भी उनकी स्पष्ट सीमाएँ होती हैं। कण कसकर पैक और अत्यधिक व्यवस्थित होते हैं।',
            'g': 'परिदृश्य पूर्ण! एक और परिदृश्य चुनें।',
            'btn': 'परिणाम देखें',
          },
        ],
      },
      {
        'title': 'परिदृश्य 2: तरल का आकार और आयतन (गतिविधि 7.4)',
        'theory':
            'तरल पदार्थों का कोई निश्चित आकार नहीं होता लेकिन आयतन निश्चित होता है। वे कंटेनर का आकार ले लेते हैं।',
        'outcome':
            'तरल पदार्थों का आयतन निश्चित होता है लेकिन आकार निश्चित नहीं होता। उन्हें जिस कंटेनर में डाला जाता है वे उसी का आकार ले लेते हैं, जो उनकी तरलता को दर्शाता है।',
        'steps': [
          {
            't': 'सिद्धांत और सेटअप',
            'i': 'आपके पास तीन विशिष्ट आकार के कंटेनर (A, B और C) हैं। कंटेनर A एक नियमित सिलेंडर है जिसमें वर्तमान में कुछ तरल (पानी) है।',
          },
          {
            't': 'प्रारंभिक आयतन मापना',
            'i': 'कंटेनर A में तरल के सटीक प्रारंभिक आयतन को निर्धारित करने और टैग करने के लिए माप बटन पर क्लिक करें।',
            'g': "कंटेनर A पर 'मापें' बटन पर क्लिक करें।",
            'btn': 'आयतन मापें',
            'btn2': '200 मिली टैग लगाएं',
          },
          {
            't': 'कंटेनर B में स्थानांतरित करना',
            'i': 'बेलनाकार कंटेनर (A) से शंक्वाकार फ्लास्क (कंटेनर B) में तरल को स्थानांतरित करें। ध्यान दें कि तरल के आकार का क्या होता है।',
            'g': 'डालने के लिए कंटेनर A को कंटेनर B के ऊपर खींचें।',
            'btn': 'A को B में डालें',
            'btn2': 'कंटेनर B मापें',
          },
          {
            't': 'कंटेनर C में स्थानांतरित करना',
            'i': 'तरल को फिर से स्थानांतरित करें, इस बार फ्लैट-बॉटम फ्लास्क (कंटेनर C) में। अंतिम आकार और क्या कुल आयतन बदल गया है, इस पर ध्यान दें।',
            'g': 'कंटेनर B को कंटेनर C के ऊपर खींचें।',
            'btn': 'B को C में डालें',
            'btn2': 'प्रश्न खोलें',
          },
          {
            't': 'निष्कर्ष',
            'i': 'तरल पदार्थ आसानी से बहते हैं और किसी भी कंटेनर का आकार ले लेते हैं, लेकिन महत्वपूर्ण बात यह है कि उनका कुल आयतन पूरी तरह से स्थिर रहता है।',
            'g': 'परिदृश्य पूर्ण!',
            'btn': 'परिणाम देखें',
          },
        ],
      },
      {
        'title': 'परिदृश्य 3: संपीड्यता (गतिविधि 7.6)',
        'theory':
            'ठोस और तरल पदार्थों की तुलना में गैसें अत्यधिक संपीड्य होती हैं। गैस के बड़े आयतन को छोटे सिलेंडरों में संपीडित किया जा सकता है।',
        'outcome':
            'गैसों के कणों के बीच काफी खाली स्थान होता है, जिससे वे अत्यधिक संपीड्य हो जाती हैं। दूसरी ओर, तरल पदार्थों के कण करीब होते हैं और उन्हें आसानी से संपीडित नहीं किया जा सकता।',
        'steps': [
          {
            't': 'सिद्धांत और सेटअप',
            'i': 'सेटअप पर दो समान बंद सिरिंज प्रदान किए गए हैं। एक हवा (गैस का प्रतिनिधित्व) से और दूसरा पानी (तरल का प्रतिनिधित्व) से भरा हुआ है।',
          },
          {
            't': 'हवा को संपीडित करना',
            'i': 'भारी दबाव लागू करने के लिए एयर सिरिंज के प्लंजर को नीचे की ओर धकेलें। ध्यान दें कि गैस का आयतन कितना कम हो जाता है।',
            'g': 'एयर सिरिंज के लिए नियंत्रक को नीचे की ओर खिसकाएं।',
            'btn': 'एयर प्लंजर दबाएं',
          },
          {
            't': 'पानी को संपीडित करना',
            'i': 'अब, पानी की सिरिंज के प्लंजर को बलपूर्वक धकेलने का प्रयास करें। यांत्रिक प्रतिरोध और अंतिम आंतरिक आयतन का निरीक्षण करें।',
            'g': 'वाटर सिरिंज के लिए नियंत्रक को नीचे की ओर खिसकाएं।',
            'btn': 'वाटर प्लंजर दबाएं',
          },
          {
            't': 'तुलनात्मक निष्कर्ष',
            'i': 'अपने पहले के संपीड़न परीक्षणों के आधार पर सही वर्गीकरण टैग को उनके संबंधित सिरिंज पर खींचकर दोनों पदार्थों को सटीक रूप से वर्गीकृत करें।',
            'g': '[संपीड्य] और [असंपीड्य] टैग को सही सिरिंज पर खींचें।',
            'btn': 'कैनवास पर टैग का उपयोग करें',
          },
          {
            't': 'निष्कर्ष',
            'i': 'बड़े अंतर-कण स्थानों के कारण गैसें अत्यधिक संपीड्य होती हैं, जबकि तरल पदार्थ तंग स्थानों के कारण लगभग असंपीड्य होते हैं।',
            'g': 'परिदृश्य पूर्ण!',
            'btn': 'परिणाम देखें',
          },
        ],
      },
      {
        'title': 'परिदृश्य 4: चावल के दाने का विरोधाभास (प्र 10)',
        'theory': 'चावल जार का आकार ले लेता है। क्या यह इसे तरल बनाता है?',
        'outcome':
            "हालाँकि चावल या चीनी जैसी सामग्री 'बहती' प्रतीत होती है और एक कंटेनर का आकार ले लेती है, लेकिन प्रत्येक दाना अपना निश्चित आकार बनाए रखता है। इस प्रकार, वे ठोस हैं, तरल नहीं।",
        'steps': [
          {
            't': 'सिद्धांत और सेटअप',
            'i': 'मेज पर, आपके पास दानों के मैक्रोस्कोपिक व्यवहार का परीक्षण करने के लिए थोक चावल से भरा एक कटोरा और एक खाली पारदर्शी कांच का जार है।',
          },
          {
            't': 'थोक अवलोकन',
            'i': 'कांच के जार में थोक चावल डालें। ध्यान दें कि चावल का ढेर पूरी तरह से जार के आकार के अनुरूप कैसे होता है, एक तरल के समान व्यवहार करता है।',
            'g': 'चावल के कटोरे को कांच के जार के ऊपर खींचें।',
            'btn': 'चावल जार में डालें',
          },
          {
            't': 'व्यक्तिगत अवलोकन',
            'i': 'चावल के एक अलग दाने का बारीकी से निरीक्षण करने के लिए आवर्धक कांच का उपयोग करें। यह देखने के लिए इसे झुकाएं कि क्या इसका व्यक्तिगत संरचनात्मक आकार बिल्कुल बदलता है।',
            'g': 'जार के अंदर चावल के ऊपर आवर्धक कांच को खींचें।',
            'btn': 'एक दाने का निरीक्षण करें',
          },
          {
            't': 'निष्कर्ष',
            'i': 'व्यक्तिगत दाने के व्यवहार के आधार पर चावल की पदार्थ की सही स्थिति के बारे में तार्किक कटौती पॉपअप का उत्तर दें।',
            'g': 'पॉपअप में तर्क पहेली को पूरा करें।',
            'btn': 'प्रश्न खोलें',
          },
          {
            't': 'समाप्त',
            'i': 'भले ही चावल या रेत जैसी थोक दानेदार सामग्री प्रवाहित हो सकती है, वे ठोस हैं क्योंकि उनके व्यक्तिगत घटक कण आत्मविश्वास से एक निश्चित, कठोर आकार बनाए रखते हैं।',
            'g': 'परिदृश्य पूर्ण!',
            'btn': 'परिणाम देखें',
          },
        ],
      },
      {
        'title': 'परिदृश्य 5: गिरा हुआ दूध (प्र 5)',
        'theory':
            'गिरने के दौरान व्यवहार के आधार पर उचित ठहराएं कि दूध तरल क्यों है और गिलास ठोस क्यों है।',
        'outcome':
            'पदार्थ को उसके भौतिक व्यवहार द्वारा वर्गीकृत किया जाता है। दूध बहता और फैलता है (तरलता), जिसे एक तरल के रूप में वर्गीकृत किया जाता है। कांच का गिलास एक कठोर सीमा बनाए रखता है, जो साबित करता है कि यह एक ठोस है।',
        'steps': [
          {
            't': 'सिद्धांत और सेटअप',
            'i': 'दूध से पूरी तरह से भरा एक मानक कठोर कांच का गिलास मेज की सतह पर स्थिर रूप से रखा गया है।',
          },
          {
            't': 'फैलना',
            'i': 'गिलास को निर्णायक रूप से गिराने के लिए एक पार्श्व बल लागू करें। ध्यान से देखें कि प्रभाव पर दूध और कांच स्वयं कैसा व्यवहार करते हैं।',
            'g': 'इसे पलटने के लिए गिलास को दाईं ओर स्वाइप/ड्रैग करें।',
            'btn': 'गिलास को पलटें',
          },
          {
            't': 'दूध का विश्लेषण (तरलता)',
            'i': 'फैले हुए दूध के पोखर के तीन अलग-अलग बाहरी किनारे बिंदुओं पर क्लिक करें ताकि इसकी अनियमित, लगातार बहने वाली सीमा को मैप किया जा सके।',
            'g': 'इसके आकार को मापने के लिए फैले हुए दूध के पोखर पर 3 बिंदुओं पर क्लिक करें।',
            'btn': 'किनारा बिंदु चिह्नित करें',
          },
          {
            't': 'गिलास का विश्लेषण (कठोरता)',
            'i': 'कैलिपर का उपयोग करके इसके संरचनात्मक आयामों को मापने के लिए गिरे हुए कांच के गिलास पर क्लिक करें, किसी भी भौतिक विरूपण के लिए सावधानीपूर्वक जाँच करें।',
            'g': 'इसे मापने के लिए गिरे हुए गिलास पर क्लिक करें।',
            'btn': 'गिलास मापें',
          },
          {
            't': 'अंतिम औचित्य',
            'i': 'तरलता और कठोरता मेट्रिक्स के आधार पर पदार्थ की अवस्थाओं को औपचारिक रूप से सही ठहराने के लिए पॉपअप के माध्यम से दिए गए वाक्यों को पूरा करें।',
            'g': 'पॉपअप में वाक्य तर्क पूरा करें।',
            'btn': 'प्रश्न खोलें',
          },
          {
            't': 'समाप्त',
            'i': 'दूध ने स्पष्ट रूप से तरलता प्रदर्शित की (इसे तरल के रूप में वर्गीकृत किया गया), जबकि कठोर गिलास ने स्पष्ट रूप से अपना निश्चित आकार बनाए रखा (इसे ठोस के रूप में वर्गीकृत किया गया)।',
            'g': 'परिदृश्य पूर्ण!',
            'btn': 'परिणाम देखें',
          },
        ],
      },
    ],
    'tagComp': '[संपीड्य]',
    'tagIncomp': '[असंपीड्य]',
    'tag200': '200 मिली',
    'tag200Tagged': '200 मिली [टैग किया गया]',
    'tagFluid': 'तरलता (बहता है)',
    'tagRigid': 'कठोर (निश्चित आकार)',
    'tagsLbl': 'टैग',
    'tapTagHint': 'टैग पर टैप करें, फिर उसके लक्ष्य पर टैप करें (या उसे वहां खींचें)।',
    'ironNail': 'लोहे की कील',
    'hammer': 'हथौड़ा',
    'stone': 'पत्थर',
    'microscope': 'सूक्ष्मदर्शी',
    'contA': 'कंटेनर A',
    'contB': 'कंटेनर B',
    'contC': 'कंटेनर C',
    'measure': 'मापें',
    'airGas': 'हवा (गैस)',
    'waterLiq': 'पानी (तरल)',
    'pushGas': 'गैस दबाएं',
    'pushLiq': 'तरल दबाएं',
    'glassJar': 'कांच का जार',
    'riceBulk': 'चावल का ढेर',
    'glassMilk': 'दूध का गिलास',
    'irregBound': 'अनियमित सीमा',
    'mlUnit': 'मिली',
    'obs': 'अवलोकन',
    's1q1': 'क्या हथौड़े के अनुकूल होने के लिए लोहे की कील ने अपना आकार बदला?',
    'yes': 'हाँ',
    'no': 'नहीं',
    'incorrect': 'गलत',
    's1q1err': 'ठोस बल लगाने पर भी अपना आकार बनाए रखते हैं।',
    'correct': 'सही!',
    's1q1corr': 'बाहरी बल के अधीन होने पर भी ठोस आकार बनाए रखते हैं।',
    'interPart': 'कणों के बीच का स्थान',
    'tight': 'कसकर बंधे हुए (ठोस)',
    'loose': 'ढीला',
    'verifyStruct': 'संरचना सत्यापित करें',
    's1q2corr': 'ठोस में कण कसकर बंधे होते हैं।',
    's1q2err': '✗ पुनः प्रयास करें: स्लाइडर को 0 तक ले जाएं।',
    'measComp': 'माप पूर्ण',
    's2q1':
        'आयतन 200 मिली है।\n\nअगला कदम: स्क्रीन के नीचे से नए [200 मिली] टैग को खींचें और इसे कंटेनर A पर छोड़ें।',
    'gotIt': 'समझ गया!',
    's2q2': 'क्या आकार बदल गया है?',
    's2q2err': 'कंटेनर B के शंक्वाकार आकार को देखें।',
    'awesome': 'बहुत बढ़िया!',
    's2q2corrHover': "क्या आयतन बदल गया है? जानने के लिए कंटेनर B पर 'मापें' क्लिक करें।",
    's2q3': 'आयतन अभी भी 200 मिली है। यह पुष्टि करता है कि तरल पदार्थों का एक निश्चित आयतन होता है!',
    'assessment': 'मूल्यांकन',
    's2q4': 'अपने अवलोकनों के आधार पर वाक्य पूरा करें।',
    'waterChanged': 'पानी ने अपना बदल दिया:',
    'keptVol': 'लेकिन इसका एक निश्चित आयतन रखा:',
    'submit': 'जमा करें',
    'shape': 'आकार',
    'color': 'रंग',
    'temp': 'तापमान',
    'vol200': '200 मिली',
    'vol100b': '100 मिली',
    'vol500': '500 मिली',
    's2q4corr': 'इसने आकार बदल दिया लेकिन 200 मिली आयतन बनाए रखा।',
    's2q4err': "संकेत: इसने अपना 'आकार' बदल दिया और '200 मिली' बनाए रखा।",
    'excellent': 'बहुत बढ़िया',
    's3q1corr': 'आपने गैस का आयतन लगभग 10 मिली तक संपीडित कर दिया है।',
    'obsNoted': 'अवलोकन दर्ज किया गया',
    's3q2corr': 'सिस्टम खिंचाव का विरोध करता है। पानी असंपीड्य है।',
    's3q3err1': 'पानी संपीड्य नहीं है।',
    's3q3err2': 'हवा को संपीड्य किया जा सकता है।',
    'fantastic': 'शानदार!',
    's3q3corr': 'हवा संपीड्य है। पानी असंपीड्य है।',
    'drag200A': 'अब [200 मिली] टैग को कंटेनर A पर खींचें।',
    'tiltJar': 'जार झुकाएं (एक दाने की जांच करें)',
    'analyze': 'आकार का विश्लेषण करें',
    'bulkObs': 'थोक अवलोकन',
    's4q1': 'चावल के ढेर ने कंटेनर का आकार ले लिया।',
    'true': 'सत्य',
    'false': 'असत्य',
    's4q1corr': 'ढेर सिलेंडर के आकार के अनुरूप है।',
    's4q1err': 'ध्यान से देखें, ढेर अब बेलनाकार है।',
    'conclusion': 'निष्कर्ष',
    's4q2': 'पदार्थ की अवस्था को वर्गीकृत करें:',
    'indShape': 'व्यक्तिगत दाने का आकार:',
    'fixed': 'निश्चित',
    'changing': 'बदल रहा है',
    'thereforeRice': 'इसलिए, चावल है:',
    'solid': 'ठोस',
    'liquid': 'तरल',
    's4q2corr': "प्रत्येक दाने का आकार निश्चित रहता है। 'प्रवाह' केवल कई ठोस कणों की गति है।",
    's4q2err': 'संकेत: क्या झुकाने पर एक दाने ने आकार बदला?',
    'spill': 'गिर गया!',
    's5q1': 'दूध बाहर निकल गया और सतह पर फैल गया।',
    'fluidity': 'तरलता',
    's5q2': 'गिलास के विपरीत, सीमा अनियमित और सपाट है।',
    'ok': 'ठीक है',
    'analyzingRigid': 'कठोरता का विश्लेषण',
    's5q3': 'क्या गिरने के बाद गिलास के आयाम बदल गए?',
    'useCaliper': 'मापने के लिए कैलिपर का उपयोग करें',
    's5q3corr': 'माप 8 सेमी (गिरने से पहले के समान) पढ़ता है। गिलास ने अपना कठोर आकार बनाए रखा।',
    'finalJust': 'अंतिम औचित्य',
    's5q4': 'वाक्यों को पूरा करने के लिए सही शब्दों को खींचें, छोड़ें या क्लिक करें:',
    'verifyAns': 'उत्तर सत्यापित करें',
    's5q4corr': 'आपने व्यवहार के आधार पर गुणों को पूरी तरह से वर्गीकृत किया।',
    's5q4err': 'कृपया अपने शब्द स्थानों की समीक्षा करें।',
    'milkIsA': 'दूध एक',
    'becauseIt': 'है क्योंकि यह',
    'tumblerIsA': 'गिलास एक',
    'becauseItMaintains': 'है क्योंकि यह बनाए रखता है एक',
    'clickToClear': '(इसे साफ़ करने के लिए एक स्लॉट पर क्लिक करें)',
    'flowsSpreads': 'बहता/फैलता है',
    'fixedShape': 'निश्चित आकार',
    'dragFluidity': '[तरलता (बहता है)] टैग को लेबल पर खींचें।',
    'dragRigid': '[कठोर (निश्चित आकार)] टैग को लेबल पर खींचें।',
  },
});

// ---------------------------------------------------------------- modal ---

class _Opt {
  _Opt(this.label, this.onTap, {this.secondary = false, this.key});
  final String label;
  final VoidCallback onTap;
  final bool secondary;
  final Key? key;
}

class _Modal {
  _Modal({
    required this.title,
    this.message,
    this.color = _rt_Tw.yellow500,
    this.icon = Icons.help_outline,
    this.bodyBuilder,
    this.opts = const [],
  });
  final String title;
  final String? message;
  final Color color;
  final IconData icon;
  final WidgetBuilder? bodyBuilder;
  final List<_Opt> opts;
}

class Cl8Ch07A2PropertiesStatesOfMatterPage extends StatefulWidget {
  const Cl8Ch07A2PropertiesStatesOfMatterPage({super.key});

  @override
  State<Cl8Ch07A2PropertiesStatesOfMatterPage> createState() =>
      _Cl8Ch07A2PropertiesStatesOfMatterPageState();
}

class _Cl8Ch07A2PropertiesStatesOfMatterPageState
    extends State<Cl8Ch07A2PropertiesStatesOfMatterPage> {
  // --- 3D engine ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF0B1021), Color(0xFF3B0A18)],
  );
  final _rt_Camera3D _camera = _rt_Camera3D(fov: 45, position: _rt_V3(0, 15, 35));
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner();
  final math.Random _rng = math.Random(7);

  // --- global state ---
  int _scenario = 1;
  int _step = 1; // step 0 (Theory & Setup) auto-completes, as in the source.
  bool _busy = false;
  int _gen = 0;
  bool _labelsVisible = true;
  final List<_rt_Label3D> _labels = [];

  // Modal (the source's draggable #canvas-modal).
  _Modal? _modal;
  bool _modalHidden = false;
  String? _modalError;

  // Tag chips (the source's .interactive-tag): id currently selected by tap.
  String? _pickedTag;

  // --- Scenario 1 ---
  _rt_Node3D? _nail, _hammer, _stone, _micro;
  bool _particleViewerOpen = false;
  double _particleSpacing = 10;
  bool _particleError = false;

  // --- Scenario 2 ---
  _rt_Node3D? _contA, _contB, _contC;
  _rt_Node3D? _waterA, _waterB, _waterC;
  bool _s2MeasuredA = false,
      _s2TagAttached = false,
      _s2PouredAB = false,
      _s2ShapeAnswered = false,
      _s2MeasuredB = false,
      _s2PouredBC = false;
  String? _s2Sel1, _s2Sel2;

  // --- Scenario 3 ---
  _rt_Node3D? _airPlunger, _waterPlunger;
  _rt_Mesh3D? _airContent, _waterContent;
  _rt_Label3D? _airVolLbl, _waterVolLbl;
  double _airVal = 100, _waterVal = 100;
  bool _airCompressed = false, _waterTried = false;
  bool _tagAirDone = false, _tagWaterDone = false;

  // --- Scenario 4 ---
  _rt_Node3D? _jar, _jarRice, _bowl, _bowlRice, _grain;
  bool _s4Poured = false, _grainViewOpen = false, _s4Answered = false;
  double _tilt = 0;
  String? _s4Sel1, _s4Sel2;

  // --- Scenario 5 ---
  _rt_Node3D? _tumbler, _milk, _puddle;
  _rt_Label3D? _puddleLbl, _caliperLbl;
  bool _s5Knocked = false,
      _s5TagFluid = false,
      _s5FluidDone = false,
      _s5CaliperShown = false,
      _s5TagRigid = false,
      _s5RigidDone = false;
  final List<_rt_Node3D> _dots = [];
  final List<String?> _s5Slots = List<String?>.filled(4, null);
  String? _s5Word;

  bool _finished = false;
  _rt_Node3D? _dragTarget;

  // ------------------------------------------------------------ helpers ---
  List<dynamic> get _stepsData => _tx.list('scen.${_scenario - 1}.steps');
  String _sc(String key) => _tx.s('scen.${_scenario - 1}.$key');
  String? _stepStr(int i, String k) =>
      _tx.get('scen.${_scenario - 1}.steps.$i.$k')?.toString();
  int get _doneStep => _stepsData.length - 1;

  String get _guide {
    if (_scenario == 2) {
      if (_step == 1 && _s2MeasuredA && !_s2TagAttached) return _tx.s('drag200A');
      if (_step == 2 && _s2ShapeAnswered && !_s2MeasuredB) {
        return _tx.s('s2q2corrHover');
      }
    }
    if (_scenario == 5) {
      if (_step == 2 && _s5TagFluid && !_s5FluidDone) return _tx.s('dragFluidity');
      if (_step == 3 && _s5TagRigid && !_s5RigidDone) return _tx.s('dragRigid');
    }
    return _stepStr(_step, 'g') ?? _tx.s('waiting');
  }

  bool _alive(int gen) => mounted && gen == _gen;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _buildScene();
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

  void _onFrame(double dt) => _tweens.update(dt);

  // -------------------------------------------------------------- scene ---
  _rt_Label3D _makeLabel(String text, _rt_V3 pos) {
    final l = _rt_Label3D(
      text,
      position: pos,
      pixelHeight: 12,
      color: Colors.white,
      background: const Color(0xB3000000),
      borderColor: const Color(0x33FFFFFF),
    );
    l.visible = _labelsVisible;
    _labels.add(l);
    return l;
  }

  void _buildScene() {
    _scene.clear();
    _labels.clear();
    _dots.clear();
    _scene.setLights([
      _rt_Light3D.ambient(intensity: 0.7),
      _rt_Light3D.directional(_rt_V3(10, 20, 10), intensity: 0.8),
    ]);

    // Wooden brown floor mat (subdivided: a single big quad painter-sorts by
    // its centre and can hide objects behind it).
    _scene.add(_rt_Mesh3D(
      _rt_Geometry3D.plane(70, 70, widthSegments: 10, heightSegments: 10),
      _rt_Material3D(color: const Color(0xFF5C4033)),
    )..rotation.x = -math.pi / 2);

    switch (_scenario) {
      case 1:
        _buildS1();
      case 2:
        _buildS2();
      case 3:
        _buildS3();
      case 4:
        _buildS4();
      case 5:
        _buildS5();
    }
  }

  void _setCamera(_rt_V3 pos, _rt_V3 target) {
    _camera.position.copy(pos);
    _camera.target.copy(target);
    _camera.zoom = 1;
    _camera.saveHome();
  }

  // Scenario 1: nail, hammer, stone, microscope.
  void _buildS1() {
    final matIron = _rt_Material3D(color: const Color(0xFF888888), metalness: 0.6, shininess: 0.6);
    final matWood = _rt_Material3D(color: const Color(0xFF8B5A2B));
    final matStone = _rt_Material3D(color: const Color(0xFF555555));

    _nail = _rt_Node3D(name: 'nail')..position.set(-6, 4, 0);
    _nail!.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(1.5, 1.5, 0.5, segments: 16), matIron)
      ..position.y = 4);
    _nail!.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.5, 0.1, 8, segments: 16), matIron));
    _nail!.add(_makeLabel(_tx.s('ironNail'), _rt_V3(0, 6.5, 0)));
    _scene.add(_nail!);

    _hammer = _rt_Node3D(name: 'hammer')..position.set(6, 5, 0);
    _hammer!.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.5, 0.5, 10, segments: 12), matWood));
    _hammer!.add(_rt_Mesh3D(_rt_Geometry3D.box(4, 2, 2), matIron)..position.set(1, 5, 0));
    _hammer!.add(_makeLabel(_tx.s('hammer'), _rt_V3(0, 7.5, 0)));
    _scene.add(_hammer!);

    _stone = _rt_Node3D(name: 'stone')..position.set(12, 3, 0);
    _stone!.add(_rt_Mesh3D(_rt_Geometry3D.icosahedron(3), matStone));
    _stone!.add(_makeLabel(_tx.s('stone'), _rt_V3(0, 5, 0)));
    _scene.add(_stone!);

    _micro = _buildMicroscope()..position.set(0, 4, 0);
    _micro!.add(_makeLabel(_tx.s('microscope'), _rt_V3(0, 8, 0)));
    _scene.add(_micro!);

    _setCamera(_rt_V3(3, 12, 34), _rt_V3(3, 3, 0));
  }

  _rt_Node3D _buildMicroscope() {
    final matIron = _rt_Material3D(color: const Color(0xFF9AA2AF), metalness: 0.5, shininess: 0.5);
    final matTube = _rt_Material3D(color: const Color(0xFFDDDDDD), shininess: 0.6);
    final matLens = _rt_Material3D(color: const Color(0xFF111111), metalness: 0.8);
    final g = _rt_Node3D(name: 'microscope');
    g.add(_rt_Mesh3D(_rt_Geometry3D.box(4, 0.5, 6), matIron)..position.y = 0.25);
    g.add(_rt_Mesh3D(_rt_Geometry3D.box(1.5, 7, 1.5), matIron)
      ..position.set(0, 3.5, -2)
      ..rotation.x = math.pi / 16);
    g.add(_rt_Mesh3D(_rt_Geometry3D.box(3.5, 0.2, 3.5), matIron)..position.set(0, 3, 0.5));
    g.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.6, 0.6, 5, segments: 16), matTube)
      ..position.set(0, 6, 0.5)
      ..rotation.x = math.pi / 16);
    g.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.25, 0.25, 1.5, segments: 12), matLens)
      ..position.set(0, 8.5, 0.2)
      ..rotation.x = math.pi / 16);
    g.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.2, 0.4, 1.2, segments: 12), matLens)
      ..position.set(0, 3.2, 0.5));
    g.scale.set(0.7, 0.7, 0.7);
    return g;
  }

  // Scenario 2: containers A (cylinder), B (cone), C (flask).
  _rt_Node3D _buildContainer(String type, double x) {
    final matGlass = _rt_Material3D(
        color: const Color(0xFF88CCFF), opacity: 0.35, shininess: 0.8, doubleSided: true);
    final matWater = _rt_Material3D(color: const Color(0xFF38BDF8), opacity: 0.75);
    final g = _rt_Node3D(name: 'container_$type')..position.set(x, 4, 0);
    _rt_Node3D water;
    if (type == 'A') {
      g.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(3, 3, 8, segments: 20), matGlass));
      water = _rt_Mesh3D(_rt_Geometry3D.cylinder(2.9, 2.9, 4, segments: 20), matWater)
        ..position.y = -2;
    } else if (type == 'B') {
      g.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(1.5, 4, 8, segments: 20), matGlass));
      water = _rt_Mesh3D(_rt_Geometry3D.cylinder(2.5, 3.9, 4, segments: 20), matWater)
        ..position.y = -2;
    } else {
      g.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(3, 3, 2, segments: 20), matGlass)..position.y = -2);
      g.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(1, 3, 3, segments: 20), matGlass)..position.y = 0.5);
      g.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(1, 1, 2, segments: 20), matGlass)..position.y = 3);
      water = _rt_Node3D(name: 'water_C');
      water.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(2.9, 2.9, 1.9, segments: 20), matWater)
        ..position.y = 1);
      water.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.9, 2.9, 2.9, segments: 20), matWater)
        ..position.y = 3.4);
      water.position.y = -3;
    }
    g.add(water);
    g.userData['water'] = water;
    return g;
  }

  void _buildS2() {
    _contA = _buildContainer('A', -10);
    _contB = _buildContainer('B', 0);
    _contC = _buildContainer('C', 10);
    _waterA = _contA!.userData['water'] as _rt_Node3D;
    _waterB = (_contB!.userData['water'] as _rt_Node3D)..visible = false;
    _waterC = (_contC!.userData['water'] as _rt_Node3D)..visible = false;
    _contA!.add(_makeLabel(_tx.s('contA'), _rt_V3(0, 6, 0)));
    _contB!.add(_makeLabel(_tx.s('contB'), _rt_V3(0, 6, 0)));
    _contC!.add(_makeLabel(_tx.s('contC'), _rt_V3(0, 6, 0)));
    _scene.add(_contA!);
    _scene.add(_contB!);
    _scene.add(_contC!);
    _setCamera(_rt_V3(0, 12, 36), _rt_V3(0, 3, 0));
  }

  // Scenario 3: two syringes with plungers.
  _rt_Node3D _buildSyringe(double x, bool isWater) {
    final matGlass = _rt_Material3D(
        color: const Color(0xFFB9D9F5), opacity: 0.3, shininess: 0.8, doubleSided: true);
    final g = _rt_Node3D(name: isWater ? 'syr_water' : 'syr_air')..position.set(x, 1.5, 0);
    g.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(1.5, 1.5, 8, segments: 20), matGlass)..position.y = 4);
    g.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.5, 1.5, 1, segments: 16),
        _rt_Material3D(color: const Color(0xFF555555)))
      ..position.y = -0.5);
    g.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.1, 0.1, 3, segments: 8),
        _rt_Material3D(color: const Color(0xFFCCCCCC)))
      ..position.y = -2);

    final contColor = isWater ? const Color(0xFFF43F5E) : const Color(0xFFAAAAAA);
    final content = _rt_Mesh3D(_rt_Geometry3D.cylinder(1.4, 1.4, 7.8, segments: 20),
        _rt_Material3D(color: contColor, opacity: isWater ? 0.8 : 0.25))
      ..position.y = 0.1 + 3.9;
    g.add(content);

    final plunger = _rt_Node3D(name: 'plunger');
    plunger.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(1.45, 1.45, 0.5, segments: 20),
        _rt_Material3D(color: const Color(0xFF333333)))
      ..position.y = 0.25);
    plunger.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(0.4, 0.4, 7, segments: 12),
        _rt_Material3D(color: const Color(0xFFDDDDDD)))
      ..position.y = 3.5);
    plunger.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(1.8, 1.8, 0.4, segments: 20),
        _rt_Material3D(color: const Color(0xFF555555)))
      ..position.y = 7);
    plunger.position.y = 7.5;
    g.add(plunger);
    g.userData['plunger'] = plunger;
    g.userData['content'] = content;
    return g;
  }

  void _buildS3() {
    final air = _buildSyringe(-7, false);
    final water = _buildSyringe(7, true);
    _airPlunger = air.userData['plunger'] as _rt_Node3D;
    _waterPlunger = water.userData['plunger'] as _rt_Node3D;
    _airContent = air.userData['content'] as _rt_Mesh3D;
    _waterContent = water.userData['content'] as _rt_Mesh3D;
    air.add(_makeLabel(_tx.s('airGas'), _rt_V3(0, -2.5, 0)));
    water.add(_makeLabel(_tx.s('waterLiq'), _rt_V3(0, -2.5, 0)));
    _airVolLbl = _makeLabel('100 ${_tx.s('mlUnit')}', _rt_V3(0, 3.2, 0));
    _waterVolLbl = _makeLabel('100 ${_tx.s('mlUnit')}', _rt_V3(0, 3.2, 0));
    _airPlunger!.add(_airVolLbl!);
    _waterPlunger!.add(_waterVolLbl!);
    _scene.add(air);
    _scene.add(water);
    _setCamera(_rt_V3(0, 10, 34), _rt_V3(0, 6, 0));
  }

  void _syncSyringes() {
    void apply(_rt_Node3D? plunger, _rt_Mesh3D? content, double val) {
      if (plunger == null || content == null) return;
      final yPos = 0.5 + (val / 100) * 7.0;
      plunger.position.y = yPos;
      final s = math.max(0.01, yPos / 7.8);
      content.scale.y = s;
      content.position.y = 0.1 + 3.9 * s;
    }

    apply(_airPlunger, _airContent, _airVal);
    apply(_waterPlunger, _waterContent, _waterVal);
    _airVolLbl?.text = '${math.max(10, _airVal.round())} ${_tx.s('mlUnit')}';
    _waterVolLbl?.text = '${math.max(95, _waterVal.round())} ${_tx.s('mlUnit')}';
  }

  // Scenario 4: jar, rice bowl, microscope (magnifier).
  void _buildS4() {
    final matGlass = _rt_Material3D(
        color: const Color(0xFF88CCFF), opacity: 0.3, shininess: 0.8, doubleSided: true);
    final matRice = _rt_Material3D(color: const Color(0xFFFDF5E6));

    _jar = _rt_Node3D(name: 'jar')..position.set(-4, 0, 0);
    _jar!.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(3, 3, 8, segments: 20), matGlass)..position.y = 4);
    _jarRice = _rt_Node3D(name: 'jarRice')..visible = false;
    _jarRice!.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(2.9, 2.9, 4, segments: 12), matRice)
      ..position.y = 2);
    for (var i = 0; i < 40; i++) {
      final r = _rng.nextDouble() * 2.5;
      final th = _rng.nextDouble() * math.pi * 2;
      _jarRice!.add(_rt_Mesh3D(_rt_Geometry3D.box(0.4, 0.4, 0.4), matRice)
        ..position.set(r * math.cos(th), 3.9 + _rng.nextDouble() * 0.4, r * math.sin(th))
        ..rotation.set(_rng.nextDouble(), _rng.nextDouble(), _rng.nextDouble()));
    }
    _jarRice!.scale.set(1, 0.01, 1);
    _jar!.add(_jarRice!);
    _jar!.add(_makeLabel(_tx.s('glassJar'), _rt_V3(0, 9.5, 0)));
    _scene.add(_jar!);

    _bowl = _rt_Node3D(name: 'bowl')..position.set(4, 0, 0);
    _bowl!.add(_rt_Mesh3D(
      _rt_Geometry3D.sphere(3, widthSegments: 20, heightSegments: 10,
          thetaStart: math.pi / 2, thetaLength: math.pi / 2),
      matGlass,
    )..position.y = 3);
    _bowlRice = _rt_Node3D(name: 'bowlRice');
    _bowlRice!.add(_rt_Mesh3D(
      _rt_Geometry3D.sphere(2.8, widthSegments: 14, heightSegments: 7,
          thetaStart: math.pi / 2, thetaLength: math.pi / 2),
      matRice,
    )..position.y = 3);
    for (var i = 0; i < 30; i++) {
      final r = _rng.nextDouble() * 2.5;
      final th = _rng.nextDouble() * math.pi * 2;
      _bowlRice!.add(_rt_Mesh3D(_rt_Geometry3D.box(0.4, 0.4, 0.4), matRice)
        ..position.set(r * math.cos(th), 3.0 + _rng.nextDouble() * 0.4, r * math.sin(th))
        ..rotation.set(_rng.nextDouble(), _rng.nextDouble(), _rng.nextDouble()));
    }
    _bowl!.add(_bowlRice!);
    _bowl!.add(_makeLabel(_tx.s('riceBulk'), _rt_V3(0, 6, 0)));
    _scene.add(_bowl!);

    _micro = _buildMicroscope()..position.set(12, 4, 0);
    _micro!.add(_makeLabel(_tx.s('microscope'), _rt_V3(0, 8, 0)));
    _scene.add(_micro!);

    _grain = _rt_Node3D(name: 'grain')..visible = false;
    _grain!.add(_rt_Mesh3D(_rt_Geometry3D.sphere(1, widthSegments: 12, heightSegments: 8), matRice)
      ..scale.set(0.5, 1.5, 0.5));
    _grain!.position.set(4, 6, 6);
    _scene.add(_grain!);

    _setCamera(_rt_V3(4, 11, 32), _rt_V3(4, 3, 0));
  }

  // Scenario 5: milk tumbler + puddle.
  void _buildS5() {
    final matGlass = _rt_Material3D(
        color: const Color(0xFF88CCFF), opacity: 0.35, shininess: 0.8, doubleSided: true);
    final matMilk = _rt_Material3D(color: Colors.white, shininess: 0.3);

    _tumbler = _rt_Node3D(name: 'tumbler')..position.set(-4, 3, 0);
    _tumbler!.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(2, 2, 6, segments: 20), matGlass));
    _milk = _rt_Mesh3D(_rt_Geometry3D.cylinder(1.9, 1.9, 5.5, segments: 20), matMilk)
      ..position.y = -0.1;
    _tumbler!.add(_milk!);
    _tumbler!.add(_makeLabel(_tx.s('glassMilk'), _rt_V3(0, 5, 0)));
    _scene.add(_tumbler!);

    _puddle = _rt_Node3D(name: 'puddle')..visible = false;
    _puddle!.add(_rt_Mesh3D(_rt_Geometry3D.cylinder(4, 4, 0.2, segments: 16), matMilk));
    _puddle!.position.set(4, 0.15, 0);
    _puddle!.scale.set(0.2, 1, 0.2);
    _scene.add(_puddle!);

    _setCamera(_rt_V3(0, 9, 26), _rt_V3(0, 2, 0));
  }

  // ------------------------------------------------------------- modals ---
  void _openModal(_Modal m) {
    setState(() {
      _modal = m;
      _modalHidden = false;
      _modalError = null;
    });
  }

  void _dismissModal() {
    // The source's closeModal: hides the card, offers "Re-open Question".
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _modalHidden = true);
  }

  void _clearModal() => setState(() {
        _modal = null;
        _modalHidden = false;
        _modalError = null;
      });

  void _showSuccessModal(String title, String msg, VoidCallback next) {
    _rt_playSfx(_rt_Sfx.correct); // HTML playSound('success')
    _openModal(_Modal(
      title: title,
      message: msg,
      color: _rt_Tw.green500,
      icon: Icons.check_circle,
      opts: [
        _Opt(_tx.s('continue'), () {
          _clearModal();
          next();
        }, key: const ValueKey('modal-continue')),
      ],
    ));
  }

  /// HTML showError: inline feedback if a modal is open, else its own card.
  void _showError(String title, String msg) {
    _rt_playSfx(_rt_Sfx.wrong); // HTML playSound('error')
    if (_modal != null && !_modalHidden) {
      setState(() => _modalError = '✗ $title: $msg');
    } else {
      _openModal(_Modal(
        title: title,
        message: msg,
        color: _rt_Tw.red500,
        icon: Icons.cancel,
        opts: [
          _Opt(_tx.s('tryAgain'), _clearModal,
              secondary: true, key: const ValueKey('modal-tryagain')),
        ],
      ));
    }
  }

  // -------------------------------------------------------------- steps ---
  void _advance() {
    if (_step >= _doneStep) return;
    setState(() => _step++);
    if (_step == _doneStep) {
      final gen = _gen;
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!_alive(gen)) return;
        _rt_playSfx(_rt_Sfx.success); // HTML playSound('success') before the trophy
        setState(() => _finished = true);
        _showFinalObservation();
      });
    }
  }

  void _showFinalObservation() {
    _openModal(_Modal(
      title: '🏆 ${_tx.s('finalObs')}',
      message: '${_tx.s('whatWeLearned')}\n\n${_sc('outcome')}',
      color: _rt_Tw.yellow500,
      icon: Icons.emoji_events,
      opts: [
        _Opt(_tx.s('done'), _clearModal, key: const ValueKey('modal-done')),
      ],
    ));
  }

  void _loadScenario(int n, {bool sound = true}) {
    if (sound) _rt_playSfx(_rt_Sfx.scenario);
    _gen++;
    _tweens.cancelAll();
    setState(() {
      _scenario = n;
      _step = 1;
      _busy = false;
      _finished = false;
      _modal = null;
      _modalHidden = false;
      _modalError = null;
      _pickedTag = null;
      _dragTarget = null;
      // S1
      _particleViewerOpen = false;
      _particleSpacing = 10;
      _particleError = false;
      // S2
      _s2MeasuredA = _s2TagAttached = _s2PouredAB = false;
      _s2ShapeAnswered = _s2MeasuredB = _s2PouredBC = false;
      _s2Sel1 = _s2Sel2 = null;
      // S3
      _airVal = _waterVal = 100;
      _airCompressed = _waterTried = false;
      _tagAirDone = _tagWaterDone = false;
      // S4
      _s4Poured = _grainViewOpen = _s4Answered = false;
      _tilt = 0;
      _s4Sel1 = _s4Sel2 = null;
      // S5
      _s5Knocked = _s5TagFluid = _s5FluidDone = false;
      _s5CaliperShown = _s5TagRigid = _s5RigidDone = false;
      _s5Word = null;
      for (var i = 0; i < _s5Slots.length; i++) {
        _s5Slots[i] = null;
      }
      _puddleLbl = null;
      _caliperLbl = null;
      _buildScene();
    });
  }

  void _restart() => _loadScenario(1, sound: false);

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() {
      _labelsVisible = !_labelsVisible;
      for (final l in _labels) {
        l.visible = _labelsVisible;
      }
    });
  }

  // ------------------------------------------------- scenario 1 actions ---
  Future<void> _strikeNail() async {
    if (_busy || _scenario != 1 || _step != 1) return;
    final gen = _gen;
    setState(() => _busy = true);
    final h = _hammer!;
    final start = h.position.clone();
    final target = _rt_V3(_nail!.position.x + 2, _nail!.position.y + 3, 0);
    await _tweens.run(250, (t) {
      h.position.copy(start + (target - start) * t);
    });
    for (var i = 0; i < 3 && _alive(gen); i++) {
      _rt_playSfx(_rt_Sfx.pop); // each hammer blow
      await _tweens.run(120, (t) => h.rotation.z = math.pi / 4 * t);
      await _tweens.run(120, (t) => h.rotation.z = math.pi / 4 * (1 - t));
    }
    if (!_alive(gen)) return;
    h.rotation.z = 0;
    h.position.set(6, 5, 0);
    setState(() => _busy = false);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!_alive(gen)) return;
    _askHammerQuestion();
  }

  void _askHammerQuestion() {
    _openModal(_Modal(
      title: _tx.s('obs'),
      message: _tx.s('s1q1'),
      opts: [
        _Opt(_tx.s('yes'), () => _showError(_tx.s('incorrect'), _tx.s('s1q1err')),
            secondary: true, key: const ValueKey('modal-yes')),
        _Opt(_tx.s('no'), () {
          _clearModal();
          _showSuccessModal(_tx.s('correct'), _tx.s('s1q1corr'), _advance);
        }, key: const ValueKey('modal-no')),
      ],
    ));
  }

  Future<void> _inspectStone() async {
    if (_busy || _scenario != 1 || _step != 2 || _particleViewerOpen) return;
    final gen = _gen;
    setState(() => _busy = true);
    final m = _micro!;
    final start = m.position.clone();
    final target = _rt_V3(_stone!.position.x, _stone!.position.y + 8, 0);
    await _tweens.run(400, (t) => m.position.copy(start + (target - start) * t));
    if (!_alive(gen)) return;
    _rt_playSfx(_rt_Sfx.magic); // lens reveal
    setState(() {
      _busy = false;
      _particleViewerOpen = true;
      _particleSpacing = 10;
      _particleError = false;
    });
  }

  void _verifyParticles() {
    if (_particleSpacing.round() == 0) {
      setState(() {
        _particleViewerOpen = false;
        _particleError = false;
      });
      _showSuccessModal(_tx.s('correct'), _tx.s('s1q2corr'), _advance);
    } else {
      _rt_playSfx(_rt_Sfx.wrong);
      setState(() => _particleError = true);
    }
  }

  // ------------------------------------------------- scenario 2 actions ---
  void _measureA() {
    if (_scenario != 2 || _step != 1 || _s2MeasuredA) return;
    _rt_playSfx(_rt_Sfx.magic); // HTML playSound('measure')
    setState(() => _s2MeasuredA = true);
    _openModal(_Modal(
      title: _tx.s('measComp'),
      message: _tx.s('s2q1'),
      color: _rt_Tw.sky500,
      icon: Icons.straighten,
      opts: [
        _Opt(_tx.s('gotIt'), _clearModal, key: const ValueKey('modal-gotit')),
      ],
    ));
  }

  void _attach200Tag() {
    if (_scenario != 2 || _step != 1 || !_s2MeasuredA || _s2TagAttached) return;
    _rt_playSfx(_rt_Sfx.pop); // tag drop
    setState(() {
      _s2TagAttached = true;
      _pickedTag = null;
    });
    _advance();
  }

  Future<void> _pourAB() async {
    if (_busy || _scenario != 2 || _step != 2 || _s2PouredAB) return;
    final gen = _gen;
    setState(() {
      _busy = true;
      _s2PouredAB = true;
    });
    final a = _contA!;
    await _tweens.run(500, (t) {
      a.position.set(-10 + 8 * t, 4 + 3 * t, 0);
      a.rotation.z = -math.pi / 4 * t;
    });
    if (!_alive(gen)) return;
    _rt_playSfx(_rt_Sfx.pop); // splash
    _waterA!.visible = false;
    _waterB!.visible = true;
    _waterB!.scale.set(1, 0.01, 1);
    await _tweens.run(900, (t) => _waterB!.scale.y = math.max(0.01, t));
    await _tweens.run(400, (t) {
      a.position.set(-2 - 8 * t, 7 - 3 * t, 0);
      a.rotation.z = -math.pi / 4 * (1 - t);
    });
    if (!_alive(gen)) return;
    setState(() => _busy = false);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!_alive(gen)) return;
    _askShapeQuestion();
  }

  void _askShapeQuestion() {
    _openModal(_Modal(
      title: _tx.s('obs'),
      message: _tx.s('s2q2'),
      opts: [
        _Opt(_tx.s('no'), () => _showError(_tx.s('incorrect'), _tx.s('s2q2err')),
            secondary: true, key: const ValueKey('modal-no')),
        _Opt(_tx.s('yes'), () {
          _rt_playSfx(_rt_Sfx.correct);
          _clearModal();
          setState(() => _s2ShapeAnswered = true);
        }, key: const ValueKey('modal-yes')),
      ],
    ));
  }

  void _measureB() {
    if (_scenario != 2 || _step != 2 || !_s2ShapeAnswered || _s2MeasuredB) return;
    _rt_playSfx(_rt_Sfx.magic); // HTML playSound('measure')
    setState(() => _s2MeasuredB = true);
    _openModal(_Modal(
      title: _tx.s('measComp'),
      message: _tx.s('s2q3'),
      color: _rt_Tw.sky500,
      icon: Icons.straighten,
      opts: [
        _Opt(_tx.s('awesome'), () {
          _clearModal();
          _advance();
        }, key: const ValueKey('modal-awesome')),
      ],
    ));
  }

  Future<void> _pourBC() async {
    if (_busy || _scenario != 2 || _step != 3 || _s2PouredBC) return;
    final gen = _gen;
    setState(() {
      _busy = true;
      _s2PouredBC = true;
    });
    final b = _contB!;
    await _tweens.run(500, (t) {
      b.position.set(8 * t, 4 + 3 * t, 0);
      b.rotation.z = -math.pi / 4 * t;
    });
    if (!_alive(gen)) return;
    _rt_playSfx(_rt_Sfx.pop); // splash
    _waterB!.visible = false;
    _waterC!.visible = true;
    _waterC!.scale.set(1, 0.01, 1);
    await _tweens.run(900, (t) => _waterC!.scale.y = math.max(0.01, t));
    await _tweens.run(400, (t) {
      b.position.set(8 - 8 * t, 7 - 3 * t, 0);
      b.rotation.z = -math.pi / 4 * (1 - t);
    });
    if (!_alive(gen)) return;
    setState(() => _busy = false);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!_alive(gen)) return;
    _askAssessment();
  }

  void _askAssessment() {
    _openModal(_Modal(
      title: _tx.s('assessment'),
      message: _tx.s('s2q4'),
      color: _rt_Tw.violet500,
      icon: Icons.quiz,
      bodyBuilder: (_) => _s2AssessmentBody(),
      opts: [
        _Opt(_tx.s('submit'), () {
          if (_s2Sel1 == 'shape' && _s2Sel2 == 'vol200') {
            _clearModal();
            _showSuccessModal(_tx.s('correct'), _tx.s('s2q4corr'), _advance);
          } else {
            _showError(_tx.s('incorrect'), _tx.s('s2q4err'));
          }
        }, key: const ValueKey('modal-submit')),
      ],
    ));
  }

  // ------------------------------------------------- scenario 3 actions ---
  void _setAirVal(double v) {
    if (_scenario != 3 || _step != 1) return;
    setState(() {
      _airVal = v;
      _syncSyringes();
    });
    if (v <= 10 && !_airCompressed) {
      _airCompressed = true;
      final gen = _gen;
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!_alive(gen)) return;
        _showSuccessModal(_tx.s('excellent'), _tx.s('s3q1corr'), _advance);
      });
    }
  }

  void _setWaterVal(double v) {
    if (_scenario != 3 || _step != 2) return;
    var clamped = v;
    if (v < 95) {
      clamped = 95;
      if (!_waterTried) {
        _waterTried = true;
        _rt_playSfx(_rt_Sfx.wrong, volume: 0.5); // mechanical resistance buzz
        final gen = _gen;
        Future.delayed(const Duration(milliseconds: 1200), () {
          if (!_alive(gen)) return;
          _showSuccessModal(_tx.s('obsNoted'), _tx.s('s3q2corr'), _advance);
        });
      }
    }
    setState(() {
      _waterVal = clamped;
      _syncSyringes();
    });
  }

  Future<void> _autoCompressAir() async {
    if (_busy || _scenario != 3 || _step != 1 || _airCompressed) return;
    final gen = _gen;
    setState(() => _busy = true);
    await _tweens.run(900, (t) {
      _airVal = 100 - 95 * t;
      _syncSyringes();
    });
    if (!_alive(gen)) return;
    setState(() => _busy = false);
    _setAirVal(5);
  }

  Future<void> _autoCompressWater() async {
    if (_busy || _scenario != 3 || _step != 2 || _waterTried) return;
    final gen = _gen;
    setState(() => _busy = true);
    await _tweens.run(500, (t) {
      _waterVal = 100 - 10 * t;
      _syncSyringes();
    });
    if (!_alive(gen)) return;
    setState(() => _busy = false);
    _setWaterVal(90);
  }

  void _dropS3Tag(String tagId, String zoneId) {
    if (_scenario != 3 || _step != 3) return;
    _rt_playSfx(_rt_Sfx.pop); // tag drop
    setState(() => _pickedTag = null);
    if (tagId == 'comp' && zoneId == 'air') {
      if (_tagAirDone) return;
      _rt_playSfx(_rt_Sfx.correct);
      setState(() => _tagAirDone = true);
    } else if (tagId == 'incomp' && zoneId == 'water') {
      if (_tagWaterDone) return;
      _rt_playSfx(_rt_Sfx.correct);
      setState(() => _tagWaterDone = true);
    } else if (tagId == 'comp' && zoneId == 'water') {
      _showError(_tx.s('incorrect'), _tx.s('s3q3err1'));
      return;
    } else if (tagId == 'incomp' && zoneId == 'air') {
      _showError(_tx.s('incorrect'), _tx.s('s3q3err2'));
      return;
    }
    if (_tagAirDone && _tagWaterDone) {
      final gen = _gen;
      Future.delayed(const Duration(milliseconds: 500), () {
        if (!_alive(gen)) return;
        _showSuccessModal(_tx.s('fantastic'), _tx.s('s3q3corr'), _advance);
      });
    }
  }

  // ------------------------------------------------- scenario 4 actions ---
  Future<void> _pourRice() async {
    if (_busy || _scenario != 4 || _step != 1 || _s4Poured) return;
    final gen = _gen;
    setState(() {
      _busy = true;
      _s4Poured = true;
    });
    final b = _bowl!;
    final start = b.position.clone();
    final target = _rt_V3(_jar!.position.x, _jar!.position.y + 9, 0);
    await _tweens.run(500, (t) {
      b.position.copy(start + (target - start) * t);
      b.rotation.z = math.pi / 2 * t;
    });
    if (!_alive(gen)) return;
    _rt_playSfx(_rt_Sfx.pop); // grains cascade
    _bowlRice!.scale.set(0.1, 0.1, 0.1);
    _jarRice!.visible = true;
    await _tweens.run(900, (t) {
      final s = math.max(0.01, t);
      _jarRice!.scale.set(1, s, 1);
    });
    if (!_alive(gen)) return;
    setState(() => _busy = false);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!_alive(gen)) return;
    _askRiceBulkQuestion();
  }

  void _askRiceBulkQuestion() {
    _openModal(_Modal(
      title: _tx.s('bulkObs'),
      message: _tx.s('s4q1'),
      opts: [
        _Opt(_tx.s('true'), () {
          _clearModal();
          _showSuccessModal(_tx.s('correct'), _tx.s('s4q1corr'), _advance);
        }, key: const ValueKey('modal-true')),
        _Opt(_tx.s('false'), () => _showError(_tx.s('incorrect'), _tx.s('s4q1err')),
            secondary: true, key: const ValueKey('modal-false')),
      ],
    ));
  }

  Future<void> _inspectGrain() async {
    if (_busy || _scenario != 4 || _step != 2 || _grainViewOpen) return;
    final gen = _gen;
    setState(() => _busy = true);
    final m = _micro!;
    final start = m.position.clone();
    final target = _rt_V3(_jar!.position.x, _jar!.position.y + 10, 0);
    await _tweens.run(400, (t) => m.position.copy(start + (target - start) * t));
    if (!_alive(gen)) return;
    _rt_playSfx(_rt_Sfx.magic); // zoom into the single grain
    _jar!.visible = false;
    _bowl!.visible = false;
    _micro!.visible = false;
    _grain!.visible = true;
    _grain!.rotation.z = 0;
    _tilt = 0;
    final camStart = _camera.position.clone();
    final tgtStart = _camera.target.clone();
    await _tweens.run(700, (t) {
      _camera.position.copy(camStart + (_rt_V3(4, 7, 14) - camStart) * t);
      _camera.target.copy(tgtStart + (_rt_V3(4, 6, 6) - tgtStart) * t);
    });
    if (!_alive(gen)) return;
    setState(() {
      _busy = false;
      _grainViewOpen = true;
    });
  }

  void _analyzeGrain() {
    if (!_grainViewOpen) return;
    setState(() => _grainViewOpen = false);
    _jar!.visible = true;
    _bowl!.visible = true;
    _micro!.visible = true;
    _grain!.visible = false;
    _camera.reset();
    _advance();
    final gen = _gen;
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_alive(gen)) return;
      _askRiceConclusion();
    });
  }

  void _askRiceConclusion() {
    _openModal(_Modal(
      title: _tx.s('conclusion'),
      message: _tx.s('s4q2'),
      color: _rt_Tw.violet500,
      icon: Icons.quiz,
      bodyBuilder: (_) => _s4ConclusionBody(),
      opts: [
        _Opt(_tx.s('submit'), () {
          if (_s4Sel1 == 'fixed' && _s4Sel2 == 'solid') {
            setState(() => _s4Answered = true);
            _clearModal();
            _showSuccessModal(_tx.s('correct'), _tx.s('s4q2corr'), _advance);
          } else {
            _showError(_tx.s('incorrect'), _tx.s('s4q2err'));
          }
        }, key: const ValueKey('modal-submit')),
      ],
    ));
  }

  // ------------------------------------------------- scenario 5 actions ---
  Future<void> _tipTumbler() async {
    if (_busy || _scenario != 5 || _step != 1 || _s5Knocked) return;
    final gen = _gen;
    setState(() {
      _busy = true;
      _s5Knocked = true;
    });
    final t0 = _tumbler!;
    _rt_playSfx(_rt_Sfx.pop); // the glass topples
    await _tweens.run(500, (t) {
      t0.rotation.z = -math.pi / 2 * t;
      t0.position.set(-4 + 3 * t, 3 - t, 0);
    });
    if (!_alive(gen)) return;
    _milk!.visible = false;
    _puddle!.visible = true;
    await _tweens.run(800, (t) {
      _puddle!.scale.set(0.2 + 1.3 * t, 1, 0.2 + 1.8 * t);
    }, ease: _rt_Ease.outBack);
    if (!_alive(gen)) return;
    setState(() => _busy = false);
    await Future.delayed(const Duration(milliseconds: 700));
    if (!_alive(gen)) return;
    _showSuccessModal(_tx.s('spill'), _tx.s('s5q1'), _advance);
  }

  static final List<_rt_V3> _fallbackDots = [
    _rt_V3(8.2, 0.45, 2.1),
    _rt_V3(0.6, 0.45, -2.6),
    _rt_V3(5.0, 0.45, 3.4),
  ];

  void _markPuddlePoint({_rt_V3? at}) {
    if (_scenario != 5 || _step != 2 || _dots.length >= 3 || _s5TagFluid) return;
    _rt_playSfx(_rt_Sfx.tap);
    final pos = at ?? _fallbackDots[_dots.length];
    final dot = _rt_Sphere3D(0.32, _rt_Material3D(color: const Color(0xFFEAB308), unlit: true))
      ..position.copy(pos);
    _scene.add(dot);
    _dots.add(dot);
    setState(() {});
    if (_dots.length == 3) {
      _openModal(_Modal(
        title: _tx.s('fluidity'),
        message: _tx.s('s5q2'),
        color: _rt_Tw.sky500,
        icon: Icons.water_drop,
        opts: [
          _Opt(_tx.s('ok'), () {
            _clearModal();
            _puddleLbl = _makeLabel(_tx.s('irregBound'), _rt_V3(0, 2, 0));
            _puddle!.add(_puddleLbl!);
            setState(() => _s5TagFluid = true);
          }, key: const ValueKey('modal-ok')),
        ],
      ));
    }
  }

  void _applyFluidityTag() {
    if (!_s5TagFluid || _s5FluidDone) return;
    _rt_playSfx(_rt_Sfx.pop);
    _rt_playSfx(_rt_Sfx.correct);
    _puddleLbl?.text = '${_tx.s('irregBound')} [${_tx.s('fluidity')}]';
    setState(() {
      _s5FluidDone = true;
      _pickedTag = null;
    });
    _advance();
  }

  void _measureTumbler() {
    if (_scenario != 5 || _step != 3 || _s5CaliperShown) return;
    _openModal(_Modal(
      title: _tx.s('analyzingRigid'),
      message: _tx.s('s5q3'),
      color: _rt_Tw.sky500,
      icon: Icons.straighten,
      opts: [
        _Opt(_tx.s('useCaliper'), () {
          _rt_playSfx(_rt_Sfx.magic); // HTML playSound('measure')
          _caliperLbl = _makeLabel('⟷ 8 cm', _rt_V3(0, 3.5, 0));
          _tumbler!.add(_caliperLbl!);
          setState(() => _s5CaliperShown = true);
          _clearModal();
          _rt_playSfx(_rt_Sfx.correct);
          _openModal(_Modal(
            title: _tx.s('measComp'),
            message: _tx.s('s5q3corr'),
            color: _rt_Tw.green500,
            icon: Icons.check_circle,
            opts: [
              _Opt(_tx.s('continue'), () {
                _clearModal();
                setState(() => _s5TagRigid = true);
              }, key: const ValueKey('modal-continue')),
            ],
          ));
        }, key: const ValueKey('modal-caliper')),
      ],
    ));
  }

  void _applyRigidTag() {
    if (!_s5TagRigid || _s5RigidDone) return;
    _rt_playSfx(_rt_Sfx.pop);
    _rt_playSfx(_rt_Sfx.correct);
    _caliperLbl?.text = '⟷ 8 cm [${_tx.s('solid')}]';
    setState(() {
      _s5RigidDone = true;
      _pickedTag = null;
    });
    _advance();
    final gen = _gen;
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!_alive(gen)) return;
      _askSpillConclusion();
    });
  }

  static const List<String> _s5WordIds = ['solid', 'liquid', 'flows', 'fixedShape'];
  static const List<String> _s5Answer = ['liquid', 'flows', 'solid', 'fixedShape'];

  String _s5WordLabel(String id) => switch (id) {
        'solid' => _tx.s('solid'),
        'liquid' => _tx.s('liquid'),
        'flows' => _tx.s('flowsSpreads'),
        _ => _tx.s('fixedShape'),
      };

  void _askSpillConclusion() {
    _openModal(_Modal(
      title: _tx.s('finalJust'),
      message: _tx.s('s5q4'),
      color: _rt_Tw.violet500,
      icon: Icons.quiz,
      bodyBuilder: (_) => _s5PuzzleBody(),
      opts: [
        _Opt(_tx.s('verifyAns'), () {
          var allRight = true;
          for (var i = 0; i < 4; i++) {
            if (_s5Slots[i] != _s5Answer[i]) allRight = false;
          }
          if (allRight) {
            _clearModal();
            _showSuccessModal(_tx.s('correct'), _tx.s('s5q4corr'), _advance);
          } else {
            _showError(_tx.s('incorrect'), _tx.s('s5q4err'));
          }
        }, key: const ValueKey('modal-verify')),
      ],
    ));
  }

  // -------------------------------------------------- canvas 3D gestures ---
  bool _onPointerDown(_rt_SceneEvent e) {
    _rt_Node3D? grab;
    if (_scenario == 1 && _step == 1 && !_busy) {
      grab = e.hitWhere((n) => n == _hammer);
    } else if (_scenario == 1 && _step == 2 && !_busy && !_particleViewerOpen) {
      grab = e.hitWhere((n) => n == _micro);
    } else if (_scenario == 2 && _step == 2 && !_busy && !_s2PouredAB) {
      grab = e.hitWhere((n) => n == _contA);
    } else if (_scenario == 2 && _step == 3 && !_busy && !_s2PouredBC) {
      grab = e.hitWhere((n) => n == _contB);
    } else if (_scenario == 4 && _step == 1 && !_busy && !_s4Poured) {
      grab = e.hitWhere((n) => n == _bowl);
    } else if (_scenario == 4 && _step == 2 && !_busy && !_grainViewOpen) {
      grab = e.hitWhere((n) => n == _micro);
    } else if (_scenario == 5 && _step == 1 && !_busy && !_s5Knocked) {
      grab = e.hitWhere((n) => n == _tumbler);
    }
    if (grab == null) return false;
    _dragTarget = grab;
    _rt_playSfx(_rt_Sfx.tap); // HTML playSound('drag')
    return true;
  }

  void _onPointerMove(_rt_SceneEvent e) {
    final t = _dragTarget;
    if (t == null) return;
    final p = e.ray.intersectZ(0);
    if (p == null) return;
    if (t == _hammer || t == _micro) {
      t.position.set(p.x, math.max(1.0, p.y), 0);
    } else if (t == _contA || t == _contB || t == _bowl) {
      t.position.x = p.x;
    } else if (t == _tumbler && !_s5Knocked) {
      t.position.x = math.max(-4.0, p.x);
      if (t.position.x > -2) {
        _dragTarget = null;
        _tumbler!.position.x = -4;
        _tipTumbler();
      }
    }
  }

  void _onPointerUp(_rt_SceneEvent e) {
    final t = _dragTarget;
    _dragTarget = null;
    if (t == null) return;
    _rt_playSfx(_rt_Sfx.pop); // HTML playSound('drop')
    if (_scenario == 1 && t == _hammer) {
      if (t.position.distanceTo(_nail!.position) < 4.5) {
        t.position.set(6, 5, 0);
        _strikeNail();
      }
    } else if (_scenario == 1 && t == _micro) {
      if (t.position.distanceTo(_stone!.position) < 5.5) {
        _inspectStone();
      }
    } else if (t == _contA) {
      if ((t.position.x - _contB!.position.x).abs() < 6) {
        t.position.set(-10, 4, 0);
        _pourAB();
      } else {
        t.position.set(-10, 4, 0);
      }
    } else if (t == _contB) {
      if ((t.position.x - _contC!.position.x).abs() < 6) {
        t.position.set(0, 4, 0);
        _pourBC();
      } else {
        t.position.set(0, 4, 0);
      }
    } else if (t == _bowl) {
      if ((t.position.x - _jar!.position.x).abs() < 5) {
        t.position.set(4, 0, 0);
        _pourRice();
      } else {
        t.position.set(4, 0, 0);
      }
    } else if (_scenario == 4 && t == _micro) {
      if ((t.position.x - _jar!.position.x).abs() < 5.5) {
        _inspectGrain();
      }
    }
  }

  void _onTap(_rt_SceneEvent e) {
    if (_scenario == 5 && _step == 2 && !_s5TagFluid) {
      if (e.hitWhere((n) => n == _puddle) != null) {
        final p = e.ray.intersectY(0.35);
        if (p != null) _markPuddlePoint(at: _rt_V3(p.x, 0.45, p.z));
      }
    } else if (_scenario == 5 && _step == 3 && !_s5CaliperShown) {
      if (e.hitWhere((n) => n == _tumbler) != null) {
        _rt_playSfx(_rt_Sfx.tap);
        _measureTumbler();
      }
    }
  }

  // ------------------------------------------------------------------ UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(builder: (context, lang) {
        return _rt_ActivityShell(
          controller: _shell,
          title: _tx.s('appTitle'),
          subtitle: _tx.s('appSub'),
          canvasBackground: _rt_Tw.slate950,
          theme: const _rt_ShellTheme(
            accent: _rt_Tw.amber600,
            headerGradient: [_rt_Tw.slate900, Color(0xFF713F12)],
            headerSubtitleColor: _rt_Tw.amber200,
          ),
          intro: _rt_IntroConfig(
            title: _tx.s('appTitle'),
            subtitle: _tx.s('appSub'),
            buttonLabel: _tx.s('enterLab'),
            footnote: _tx.s('footnote'),
            icon: Icons.science,
          ),
          onRestart: _restart,
          onZoomIn: _camera.zoomIn,
          onZoomOut: _camera.zoomOut,
          onResetView: _camera.reset,
          toolbarExtras: [
            _rt_RotatePanToggle(controller: _viewCtrl, accent: _rt_Tw.amber600),
            const SizedBox(height: 4),
            _labelsButton(),
          ],
          sidebarTop: _scenarioSelector(),
          tabs: [
            _rt_ShellTab(
              label: _tx.s('tabExperiment'),
              icon: Icons.science,
              builder: (_) => _sidebar(),
            ),
          ],
          canvas: _rt_Scene3DView(
            scene: _scene,
            camera: _camera,
            controller: _viewCtrl,
            onFrame: _onFrame,
            onTap: _onTap,
            onPointerDown: _onPointerDown,
            onPointerMove: _onPointerMove,
            onPointerUp: _onPointerUp,
          ),
          canvasOverlays: [
            // Top HUD ("Action: ..." guide).
            Positioned(
              top: 12,
              left: 70,
              right: 70,
              child: IgnorePointer(child: Center(child: _hudBanner())),
            ),
            // Contextual bottom panel (measure buttons, sliders, tag chips).
            Positioned(
              bottom: 12,
              left: 60,
              right: 60,
              child: Center(child: _bottomPanel()),
            ),
            // Tag drop zones over the scene.
            ..._tagZones(),
            // The particle viewer (S1) sits over everything.
            if (_particleViewerOpen) Positioned.fill(child: _particleViewer()),
            // Observation / question modal, plus its re-open pill.
            if (_modal != null && !_modalHidden)
              Positioned(left: 12, top: 44, child: _modalCard()),
            if (_modal != null && _modalHidden)
              Positioned(
                bottom: 64,
                left: 0,
                right: 0,
                child: Center(child: _reopenButton()),
              ),
          ],
        );
      }),
    );
  }

  Widget _labelsButton() {
    return Tooltip(
      message: _tx.s('toolLabels'),
      child: InkResponse(
        key: const ValueKey('labels-toggle'),
        radius: 22,
        onTap: _toggleLabels,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: _labelsVisible ? _rt_Tw.amber600 : _rt_Lab.surface,
            shape: BoxShape.circle,
          ),
          child: Icon(
            _labelsVisible ? Icons.visibility : Icons.visibility_off,
            size: 18,
            color: _labelsVisible ? Colors.white : _rt_Lab.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _scenarioSelector() {
    return Container(
      color: _rt_Lab.base,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _rt_SectionLabel(_tx.s('selectScenario'), icon: Icons.tune),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: _rt_Lab.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _rt_Lab.borderStrong),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                key: const ValueKey('scenario-select'),
                value: _scenario,
                isExpanded: true,
                isDense: true,
                icon: const Icon(Icons.arrow_drop_down, color: _rt_Tw.amber400),
                dropdownColor: _rt_Lab.surface,
                style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w700, color: _rt_Lab.text),
                items: [
                  for (var i = 1; i <= 5; i++)
                    DropdownMenuItem(
                      value: i,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _tx.s('scen.${i - 1}.title'),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                ],
                onChanged: (v) {
                  if (v != null && v != _scenario) _loadScenario(v);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _hudBanner() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 8)],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text('${_tx.s('action')}: ',
            style: TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w800, color: _rt_Lab.textMuted)),
        Flexible(
          child: Text(
            _guide,
            key: const ValueKey('hud-guide'),
            style: const TextStyle(
                fontSize: 11.5, fontWeight: FontWeight.w800, color: _rt_Tw.sky400),
          ),
        ),
      ]),
    );
  }

  // ------------------------------------------------------- bottom panel ---
  Widget _bottomPanel() {
    final children = <Widget>[];

    if (_scenario == 2) {
      if (_step == 1 && !_s2MeasuredA) {
        children.add(_rt_ActionButton(
          key: const ValueKey('canvas-measure-a'),
          label: '⏱ ${_tx.s('measure')} A',
          icon: Icons.straighten,
          color: _rt_Tw.sky500,
          onPressed: _measureA,
        ));
      }
      if (_step == 2 && _s2ShapeAnswered && !_s2MeasuredB) {
        children.add(_rt_ActionButton(
          key: const ValueKey('canvas-measure-b'),
          label: '⏱ ${_tx.s('measure')} B',
          icon: Icons.straighten,
          color: _rt_Tw.sky500,
          onPressed: _measureB,
        ));
      }
      if (_s2TagAttached) {
        children.add(_staticTag(_tx.s('tag200Tagged')));
      }
    }

    if (_scenario == 3 && _step >= 1 && _step <= 2) {
      children.add(_syringeSliders());
    }

    if (_grainViewOpen) {
      children.add(_grainPanel());
    }

    final tags = _activeTagChips();
    if (tags.isNotEmpty) {
      children.add(Column(mainAxisSize: MainAxisSize.min, children: [
        Wrap(spacing: 8, runSpacing: 6, alignment: WrapAlignment.center, children: tags),
        const SizedBox(height: 4),
        Text(_tx.s('tapTagHint'),
            style: TextStyle(fontSize: 9.5, color: Colors.white.withValues(alpha: 0.85))),
      ]));
    }

    if (children.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _rt_Lab.border),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 10)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            children[i],
          ],
        ],
      ),
    );
  }

  Widget _staticTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: _rt_Lab.tinted(_rt_Tw.green100, _rt_Tw.green500),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _rt_Tw.green500, width: 2),
      ),
      child: Text(text,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: _rt_Lab.onTinted(_rt_Tw.green400, _rt_Tw.green700))),
    );
  }

  Widget _syringeSliders() {
    return SizedBox(
      width: 380,
      child: Row(children: [
        Expanded(
          child: _rt_LabeledSlider(
            key: const ValueKey('slider-air'),
            label: _tx.s('pushGas'),
            value: _airVal,
            min: 0,
            max: 100,
            color: _rt_Tw.amber500,
            valueText: '${math.max(10, _airVal.round())} ${_tx.s('mlUnit')}',
            onChanged: _step == 1 ? _setAirVal : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _rt_LabeledSlider(
            key: const ValueKey('slider-water'),
            label: _tx.s('pushLiq'),
            value: _waterVal,
            min: 0,
            max: 100,
            color: _rt_Tw.rose500,
            valueText: '${math.max(95, _waterVal.round())} ${_tx.s('mlUnit')}',
            onChanged: _step == 2 ? _setWaterVal : null,
          ),
        ),
      ]),
    );
  }

  Widget _grainPanel() {
    return SizedBox(
      width: 260,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        _rt_LabeledSlider(
          key: const ValueKey('tilt-slider'),
          label: _tx.s('tiltJar'),
          value: _tilt,
          min: 0,
          max: 100,
          color: _rt_Tw.amber500,
          valueText: '${_tilt.round()}°',
          onChanged: (v) {
            setState(() {
              _tilt = v;
              _grain?.rotation.z = (v / 100) * math.pi;
            });
          },
        ),
        _rt_ActionButton(
          key: const ValueKey('analyze-grain'),
          label: _tx.s('analyze'),
          icon: Icons.search,
          color: _rt_Tw.amber600,
          onPressed: _analyzeGrain,
        ),
      ]),
    );
  }

  // ------------------------------------------------------------ tag UI ---
  List<Widget> _activeTagChips() {
    final chips = <Widget>[];
    void chip(String id, String label) {
      chips.add(_tagChip(id, label));
    }

    if (_scenario == 2 && _step == 1 && _s2MeasuredA && !_s2TagAttached) {
      chip('tag200', _tx.s('tag200'));
    }
    if (_scenario == 3 && _step == 3) {
      if (!_tagAirDone) chip('comp', _tx.s('tagComp'));
      if (!_tagWaterDone) chip('incomp', _tx.s('tagIncomp'));
    }
    if (_scenario == 5 && _step == 2 && _s5TagFluid && !_s5FluidDone) {
      chip('fluid', _tx.s('tagFluid'));
    }
    if (_scenario == 5 && _step == 3 && _s5TagRigid && !_s5RigidDone) {
      chip('rigid', _tx.s('tagRigid'));
    }
    return chips;
  }

  Widget _tagChip(String id, String label) {
    final selected = _pickedTag == id;
    final chip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _rt_Tw.yellow500,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? Colors.white : Colors.transparent, width: 2),
        boxShadow: selected
            ? [BoxShadow(color: _rt_Tw.yellow500.withValues(alpha: 0.7), blurRadius: 8)]
            : null,
      ),
      child: Text(label,
          style: const TextStyle(
              fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.black)),
    );
    return GestureDetector(
      key: ValueKey('tag-$id'),
      onTap: () {
        _rt_playSfx(_rt_Sfx.tap);
        setState(() => _pickedTag = selected ? null : id);
      },
      child: Draggable<String>(
        data: id,
        onDragStarted: () {
          _rt_playSfx(_rt_Sfx.tap); // HTML playSound('drag')
          setState(() => _pickedTag = id);
        },
        feedback: Material(color: Colors.transparent, child: chip),
        childWhenDragging: Opacity(opacity: 0.3, child: chip),
        child: chip,
      ),
    );
  }

  void _applyTag(String tagId, String zoneId) {
    switch (tagId) {
      case 'tag200':
        if (zoneId == 'a') _attach200Tag();
      case 'comp':
      case 'incomp':
        _dropS3Tag(tagId, zoneId);
      case 'fluid':
        if (zoneId == 'puddle') _applyFluidityTag();
      case 'rigid':
        if (zoneId == 'tumbler') _applyRigidTag();
    }
  }

  List<Widget> _tagZones() {
    final zones = <({String id, String label, Alignment align, bool done})>[];
    if (_scenario == 2 && _step == 1 && _s2MeasuredA && !_s2TagAttached) {
      zones.add((
        id: 'a',
        label: _tx.s('contA'),
        align: const Alignment(-0.62, 0.05),
        done: false
      ));
    }
    if (_scenario == 3 && _step == 3) {
      zones.add((
        id: 'air',
        label: _tx.s('airGas'),
        align: const Alignment(-0.45, 0.1),
        done: _tagAirDone
      ));
      zones.add((
        id: 'water',
        label: _tx.s('waterLiq'),
        align: const Alignment(0.45, 0.1),
        done: _tagWaterDone
      ));
    }
    if (_scenario == 5 && _step == 2 && _s5TagFluid && !_s5FluidDone) {
      zones.add((
        id: 'puddle',
        label: _tx.s('irregBound'),
        align: const Alignment(0.4, 0.35),
        done: false
      ));
    }
    if (_scenario == 5 && _step == 3 && _s5TagRigid && !_s5RigidDone) {
      zones.add((
        id: 'tumbler',
        label: _tx.s('glassMilk'),
        align: const Alignment(-0.3, 0.1),
        done: false
      ));
    }
    return [
      for (final z in zones)
        Positioned.fill(
          child: Align(
            alignment: z.align,
            child: DragTarget<String>(
              onAcceptWithDetails: (d) => _applyTag(d.data, z.id),
              builder: (context, cand, _) {
                final hover = cand.isNotEmpty;
                return GestureDetector(
                  key: ValueKey('zone-${z.id}'),
                  onTap: _pickedTag == null
                      ? null
                      : () => _applyTag(_pickedTag!, z.id),
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 110),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: z.done
                          ? _rt_Tw.green500.withValues(alpha: 0.35)
                          : Colors.black.withValues(alpha: hover ? 0.6 : 0.35),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: z.done
                            ? _rt_Tw.green500
                            : (hover || _pickedTag != null
                                ? _rt_Tw.amber400
                                : Colors.white.withValues(alpha: 0.5)),
                        width: 2,
                      ),
                    ),
                    child: Text(
                      z.done ? '✓ ${z.label}' : z.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
    ];
  }

  // ---------------------------------------------------- particle viewer ---
  Widget _particleViewer() {
    final v = _particleSpacing;
    final tight = v.round() == 0;
    return Container(
      color: Colors.black.withValues(alpha: 0.45),
      alignment: Alignment.center,
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 190,
          height: 190,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.85),
            border: Border.all(color: _rt_Tw.yellow500, width: 4),
          ),
          child: ClipOval(
            child: Stack(children: [
              for (var i = 0; i < 30; i++)
                Positioned(
                  left: 34 + (i % 6) * (10 + v * 2.2),
                  top: 40 + (i ~/ 6) * (10 + v * 2.2),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _rt_Tw.sky400,
                    ),
                  ),
                ),
            ]),
          ),
        ),
        const SizedBox(width: 16),
        Container(
          width: 210,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _rt_Lab.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _rt_Tw.yellow500, width: 2),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _rt_LabeledSlider(
              key: const ValueKey('particle-slider'),
              label: _tx.s('interPart'),
              value: v,
              min: 0,
              max: 10,
              divisions: 10,
              color: _rt_Tw.amber500,
              valueText: '${v.round()}',
              onChanged: (nv) => setState(() => _particleSpacing = nv),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                tight ? _tx.s('tight') : _tx.s('loose'),
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: tight ? _rt_Tw.green400 : _rt_Lab.textMuted),
              ),
            ),
            _rt_ActionButton(
              key: const ValueKey('verify-particles'),
              label: _tx.s('verifyStruct'),
              icon: Icons.fact_check,
              color: _rt_Tw.amber600,
              onPressed: _verifyParticles,
            ),
            if (_particleError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(_tx.s('s1q2err'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w800, color: _rt_Tw.red400)),
              ),
          ]),
        ),
      ]),
    );
  }

  // -------------------------------------------------------- modal widget ---
  Widget _modalCard() {
    final m = _modal!;
    return Container(
      width: 330,
      constraints: const BoxConstraints(maxHeight: 292),
      decoration: BoxDecoration(
        color: _rt_Lab.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: m.color, width: 2),
        boxShadow: [BoxShadow(color: _rt_Lab.shadow, blurRadius: 16)],
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        // Header (title + close X).
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
          decoration: BoxDecoration(
            color: _rt_Lab.overlay,
            border: Border(bottom: BorderSide(color: _rt_Lab.border)),
          ),
          child: Row(children: [
            Icon(m.icon, size: 16, color: m.color),
            const SizedBox(width: 6),
            Expanded(
              child: Text(m.title,
                  style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: _rt_Lab.onTinted(m.color, m.color))),
            ),
            InkResponse(
              key: const ValueKey('modal-close'),
              radius: 16,
              onTap: _dismissModal,
              child: Icon(Icons.close, size: 18, color: _rt_Lab.textMuted),
            ),
          ]),
        ),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (m.message != null)
                  Text(m.message!,
                      style: TextStyle(fontSize: 12, color: _rt_Lab.text, height: 1.35)),
                if (m.bodyBuilder != null) m.bodyBuilder!(context),
                if (_modalError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_modalError!,
                        key: const ValueKey('modal-error'),
                        style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w800,
                            color: _rt_Tw.red400)),
                  ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 6, 12, 10),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final o in m.opts)
                _rt_ActionButton(
                  key: o.key,
                  label: o.label,
                  icon: o.secondary ? Icons.close : Icons.check,
                  color: o.secondary ? _rt_Tw.slate600 : m.color,
                  onPressed: o.onTap,
                ),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _reopenButton() {
    return Material(
      color: _rt_Tw.red500,
      shape: const StadiumBorder(),
      child: InkWell(
        key: const ValueKey('reopen-modal'),
        customBorder: const StadiumBorder(),
        onTap: () {
          _rt_playSfx(_rt_Sfx.click);
          setState(() => _modalHidden = false);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(_tx.s('reopen'),
              style: const TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w900, color: Colors.white)),
        ),
      ),
    );
  }

  // ------------------------------------------------------- modal bodies ---
  Widget _choiceRow(String label, List<(String, String)> options, String? current,
      void Function(String) onPick, String keyPrefix) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(label,
              style: TextStyle(
                  fontSize: 11.5, fontWeight: FontWeight.w800, color: _rt_Lab.textMuted)),
        ),
        Wrap(spacing: 6, runSpacing: 6, children: [
          for (final (id, text) in options)
            GestureDetector(
              key: ValueKey('$keyPrefix-$id'),
              onTap: () {
                _rt_playSfx(_rt_Sfx.tap);
                onPick(id);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: current == id ? _rt_Tw.amber600 : _rt_Lab.overlay,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: current == id ? _rt_Tw.amber400 : _rt_Lab.borderStrong),
                ),
                child: Text(text,
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: current == id ? Colors.white : _rt_Lab.text)),
              ),
            ),
        ]),
      ],
    );
  }

  Widget _s2AssessmentBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _choiceRow(
          _tx.s('waterChanged'),
          [('shape', _tx.s('shape')), ('color', _tx.s('color')), ('temp', _tx.s('temp'))],
          _s2Sel1,
          (v) => setState(() => _s2Sel1 = v),
          's2sel1',
        ),
        _choiceRow(
          _tx.s('keptVol'),
          [
            ('vol200', _tx.s('vol200')),
            ('vol100', _tx.s('vol100b')),
            ('vol500', _tx.s('vol500')),
          ],
          _s2Sel2,
          (v) => setState(() => _s2Sel2 = v),
          's2sel2',
        ),
      ],
    );
  }

  Widget _s4ConclusionBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _choiceRow(
          _tx.s('indShape'),
          [('fixed', _tx.s('fixed')), ('changing', _tx.s('changing'))],
          _s4Sel1,
          (v) => setState(() => _s4Sel1 = v),
          's4sel1',
        ),
        _choiceRow(
          _tx.s('thereforeRice'),
          [('solid', _tx.s('solid')), ('liquid', _tx.s('liquid'))],
          _s4Sel2,
          (v) => setState(() => _s4Sel2 = v),
          's4sel2',
        ),
      ],
    );
  }

  Widget _s5Slot(int i) {
    final filled = _s5Slots[i];
    return GestureDetector(
      key: ValueKey('slot-$i'),
      onTap: () {
        if (_s5Word != null) {
          _rt_playSfx(_rt_Sfx.pop);
          setState(() {
            _s5Slots[i] = _s5Word;
            _s5Word = null;
          });
        } else if (filled != null) {
          _rt_playSfx(_rt_Sfx.tap);
          setState(() => _s5Slots[i] = null);
        }
      },
      child: Container(
        constraints: const BoxConstraints(minWidth: 72),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: filled != null
              ? _rt_Lab.tinted(_rt_Tw.green100, _rt_Tw.green500)
              : Colors.black.withValues(alpha: 0.25),
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color: filled != null ? _rt_Tw.green500 : _rt_Lab.borderStrong,
            width: filled != null ? 2 : 1.4,
          ),
        ),
        child: Text(
          filled != null ? _s5WordLabel(filled) : '…',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: filled != null
                  ? _rt_Lab.onTinted(_rt_Tw.green400, _rt_Tw.green700)
                  : _rt_Lab.textFaint),
        ),
      ),
    );
  }

  Widget _s5PuzzleBody() {
    Widget sentence(List<Widget> parts) => Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5,
            runSpacing: 6,
            children: parts,
          ),
        );
    TextStyle t() => TextStyle(fontSize: 11.5, color: _rt_Lab.text, height: 1.4);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        sentence([
          Text(_tx.s('milkIsA'), style: t()),
          _s5Slot(0),
          Text(_tx.s('becauseIt'), style: t()),
          _s5Slot(1),
        ]),
        sentence([
          Text(_tx.s('tumblerIsA'), style: t()),
          _s5Slot(2),
          Text(_tx.s('becauseItMaintains'), style: t()),
          _s5Slot(3),
        ]),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(_tx.s('clickToClear'),
              style: TextStyle(fontSize: 9.5, color: _rt_Lab.textFaint)),
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Wrap(spacing: 6, runSpacing: 6, children: [
            for (final id in _s5WordIds)
              if (!_s5Slots.contains(id))
                GestureDetector(
                  key: ValueKey('word-$id'),
                  onTap: () {
                    _rt_playSfx(_rt_Sfx.tap);
                    setState(() => _s5Word = _s5Word == id ? null : id);
                  },
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: _rt_Tw.yellow500,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                          color: _s5Word == id ? Colors.white : Colors.transparent,
                          width: 2),
                    ),
                    child: Text(_s5WordLabel(id),
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: Colors.black)),
                  ),
                ),
          ]),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ sidebar ---
  Widget _sidebar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _rt_ObjectiveCard(
          title: _sc('title'),
          desc: _sc('theory'),
          accent: _rt_Tw.amber600,
          icon: Icons.flag,
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _rt_SectionLabel(_tx.s('stepsLbl'), icon: Icons.checklist),
              for (var i = 0; i < _stepsData.length; i++)
                if (i < _doneStep || _step >= _doneStep) _stepCard(i),
              if (_finished)
                _rt_InfoCard(
                  title: _tx.s('whatWeLearned'),
                  body: _sc('outcome'),
                  icon: Icons.emoji_events,
                  color: _rt_Tw.green600,
                  leftBorder: true,
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _stepCard(int i) {
    final active = i == _step;
    final done = i < _step || (i == _doneStep && _finished);
    return _rt_StepCard(
      key: ValueKey('step-$i'),
      number: i + 1,
      title: _stepStr(i, 't') ?? '',
      desc: _stepStr(i, 'i') ?? '',
      actionLabel: _stepActionLabel(i),
      actionIcon: _stepIcon(i),
      accent: _rt_Tw.amber600,
      active: active,
      done: done && i != _doneStep,
      locked: !active || _busy || _stepAction(i) == null,
      onAction: _stepAction(i),
    );
  }

  String _stepActionLabel(int i) {
    if (_scenario == 2) {
      if (i == 1 && _s2MeasuredA && !_s2TagAttached) return _stepStr(i, 'btn2') ?? '';
      if (i == 2 && _s2ShapeAnswered && !_s2MeasuredB) return _stepStr(i, 'btn2') ?? '';
      if (i == 3 && _s2PouredBC) return _stepStr(i, 'btn2') ?? '';
    }
    return _stepStr(i, 'btn') ?? _tx.s('continue');
  }

  IconData _stepIcon(int i) {
    if (i == _doneStep) return Icons.emoji_events;
    return switch (_scenario) {
      1 => i == 1 ? Icons.hardware : Icons.biotech,
      2 => i == 1 ? Icons.straighten : Icons.water_drop,
      3 => Icons.compress,
      4 => i == 1 ? Icons.rice_bowl : Icons.search,
      _ => Icons.local_drink,
    };
  }

  VoidCallback? _stepAction(int i) {
    if (i != _step && !(i == _doneStep && _finished)) return null;
    if (i == _doneStep) return _finished ? _showFinalObservation : null;
    switch (_scenario) {
      case 1:
        if (i == 1) return _strikeNail;
        if (i == 2) return _particleViewerOpen ? null : _inspectStone;
      case 2:
        if (i == 1) {
          if (!_s2MeasuredA) return _measureA;
          if (!_s2TagAttached) return _attach200Tag;
        }
        if (i == 2) {
          if (!_s2PouredAB) return _pourAB;
          if (_s2ShapeAnswered && !_s2MeasuredB) return _measureB;
          if (!_s2ShapeAnswered && _modal == null) return _askShapeQuestion;
        }
        if (i == 3) {
          if (!_s2PouredBC) return _pourBC;
          if (_modal == null) return _askAssessment;
        }
      case 3:
        if (i == 1) return _airCompressed ? null : _autoCompressAir;
        if (i == 2) return _waterTried ? null : _autoCompressWater;
        if (i == 3) return null; // classification must be done with the tags
      case 4:
        if (i == 1) return _s4Poured ? null : _pourRice;
        if (i == 2) return _grainViewOpen ? null : _inspectGrain;
        if (i == 3) return (_modal == null && !_s4Answered) ? _askRiceConclusion : null;
      case 5:
        if (i == 1) return _s5Knocked ? null : _tipTumbler;
        if (i == 2) {
          if (!_s5TagFluid && _dots.length < 3) return _markPuddlePoint;
          return null;
        }
        if (i == 3) return _s5CaliperShown ? null : _measureTumbler;
        if (i == 4) return _modal == null ? _askSpillConclusion : null;
    }
    return null;
  }
}
