// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 13.5: Antibiotics and Antibiotic Resistance
// Converted from Cl8S-Ch13-A5-antibiotics-and-antibiotic-resistance.html
// (three.js r128 + tween.js -> mini3d).
//
// Five scenarios picked from the sidebar, each opened by a chalkboard:
// (1) Fleming's dish - streak bacteria with the loop, drop the mould spore
// at the dish edge, watch the clear zone form and measure it with the
// ruler; (2) Decision pathway - draw the wrong self-medication link, then
// the right path Mother -> Doctor -> Pharmacy -> Mother; (3) Mechanism -
// drop the antibiotic on the virus (no target) and on the bacterium
// (lysis); (4) Saniya's claim - sort four diseases into Effective /
// Ineffective and build Vinita's question; (5) Flu - give the pill to an
// infected cell, then answer why it fails. Every 3D drag also has a
// sidebar button, and each finished scenario shows its summary with
// "Next Scenario".
//
// SOURCE BUG FIXES:
// * Pending timers and tweens survived a scenario change: S3/S5 endings
//   fired inside the next scenario, S1's zone clean-up crashed on a null
//   scene, and S5's endless virus tweens piled up on every visit. Every
//   delayed step is cancelled on scenario change/restart; viruses drift by
//   a per-frame formula.
// * Repeated actions advanced twice into dead ends (S2 wrong path, S3
//   bounce, S4 Check, S5 pill / MCQ); all actions are latched.
// * Re-entering S4 kept sorted cards and doubled the drop listeners (a card
//   could count twice), and re-entering S5 left the MCQ disabled for good.
//   Scenarios are rebuilt cleanly.
// * The Pan tool had no way back and blocked the 2D boards; HTML5
//   drag-and-drop in S4 did not work on touch screens. Boards use Flutter
//   drag targets with tap-to-place; the sentence builder adds and removes
//   words by tap, so they can be reordered.
// * Drops were tested by distance from the object's origin, so a short
//   drag counted and a miss left S3/S5 objects floating; drops are judged
//   from the handle against tight targets, need a real move, snap back with
//   a hint otherwise, and objects lock after use. Wrong drops explain (try
//   the virus first / now the bacterium).
// * The MCQ printed "A | A. ..." (the letters were in the strings), did not
//   mark a wrong pick and could not be replayed; the S5 step text gave the
//   answer away ("Connect 'Flu Virus' to Option 2") and S4's step text was
//   a developer note. Fixed.
// * Labels: the toggle was not applied to new scenes, labels inside
//   rotated groups floated diagonally, and the two-line node names lost
//   their line break. The camera had no zoom or orbit limits (it could go
//   under the table or past the far plane); it is clamped and framed per
//   step for phones. Restart keeps the language (the source forced
//   English). Hindi was abridged with placeholders such as "तैयारी।" and
//   called the ruler "शासक" (a ruler of a country); it is rewritten.
//
// CONTENT FIXES (approved by the user):
// * S1: the mould now lands near the dish edge, its clear zone stays
//   inside the agar and forms before the step ends, and the ruler lies
//   across it with a reading of about 2 cm (the source's ring spilled past
//   the dish and the ruler measured nothing).
// * S2: "Bacteria mutate and shield themselves" -> resistance by selection
//   (incomplete doses kill the weakest bacteria; resistant ones survive and
//   multiply); the cabinet shows bacteria, not a virus icon.
// * S3: "Some antibiotics, like penicillin, kill bacteria by breaking their
//   cell wall"; the virus is labelled "No cell wall" (not "Protein Coat
//   Only").
// * S5: the pill enters the infected cell and finds "No target" (the source
//   showed a shield, as if the cell repelled the drug).
// --- TRANSLATION DATA (source `i18n` + `ScenariosData`, en + hi; te
// ignored; summaries keep their bold words as **...**). Keys marked
// `// added` have no source string; their Hindi is written to match. ---

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
    'appTitle': 'Antibiotics and Antibiotic Resistance',
    'appSubtitle': 'Class 8. Health: The Ultimate Treasure',
    'enterLab': 'Enter Lab',
    'selectScenario': 'Select Scenario',
    'missionObj': 'Mission Objective',
    'conceptExp': 'Exploration Steps',
    'currObj': 'Current Task',
    'exploration': 'Step',
    'conceptFocus': 'Focus',
    'action': 'Action',
    'observation': 'Observation',
    'nextScenario': 'Next Scenario', // added
    'restartLab': 'Restart Virtual Lab',
    'scComplete': 'Scenario {n} Complete!',
    'labComplete': 'All Scenarios Complete!', // added
    'scenarioDoneHud':
        'Scenario {n} complete! Go on to the next scenario.', // added
    'labDoneHud': 'All scenarios complete! Restart the lab any time.', // added
    'labControls': 'Lab Controls', // added
    'controlsHint':
        'Drag the objects in the 3D view, or use these buttons.', // added
    'ttLabels': 'Toggle labels', // added
    'ttLock': 'Lock / unlock camera', // added
    'incorrect': 'Incorrect. Try again.',
    'lbl': {
      'agar': 'Agar Plate',
      'loop': 'Bacterial Culture',
      'mould': 'Mould Spore',
      'ruler': 'Ruler',
      'reading': 'about 2 cm', // added (content fix: a real reading)
      // Content fix: the virus lacks a cell wall (it is not "protein coat
      // only" - the flu virus also has an envelope).
      'bacterium': 'Bacterium (cell wall)',
      'virus': 'Virus (no cell wall)',
      'antibiotic': 'Antibiotic',
      'hostCell': 'Human Host Cell',
      'noTarget': 'No target found', // added (content fix)
    },
    // Lab-control twins (added).
    'twLoop': 'Streak the bacteria on the dish',
    'twMould': 'Add the mould at the dish edge',
    'twRuler': 'Measure the clear zone',
    'twVirus': 'Antibiotic onto the virus',
    'twBacterium': 'Antibiotic onto the bacterium',
    'twPill': 'Give the antibiotic pill',
    // Scenario 1 (toasts added).
    'fbDishMiss': 'Drop it onto the petri dish.',
    'fbStreaked': 'Bacterial colonies grow across the whole dish.',
    'fbEdgeMiss': 'Drop the mould spore on the edge of the dish.',
    'fbZone': 'A clear zone forms around the mould - no bacteria grow there.',
    'fbRulerMiss': 'Lay the ruler across the clear zone.',
    'fbMeasured': 'The clear zone measures about 2 cm.',
    // Scenario 2.
    's2Title': 'Medical Decision Pathway',
    'node': {
      'mother': 'Mother Sick',
      'cabinet': 'Home Cabinet (Leftovers)',
      'doctor': "Doctor's Clinic",
      'pharmacy': 'Pharmacy (Prescription)',
    },
    's2Instruction':
        'Drag from one circle to another (or tap two circles) to draw a path.',
    // Content fix: resistance arises by selection, not because bacteria
    // decide to "mutate and shield themselves".
    'fbSelfMed':
        'Wrong path! Leftover or incomplete doses kill only the weakest bacteria; the resistant ones survive and multiply. Self-medication promotes antibiotic resistance.',
    'fbFollow': 'Follow the instructions for this step.',
    'fbSequence':
        "Please follow the correct sequence: Mother Sick, then Doctor's Clinic, then Pharmacy, then back to Mother Sick.",
    'fbNotPath': 'That is not the correct path.',
    'fbLinkOk': 'Correct link!', // added
    // Scenario 3.
    'fbNoTarget':
        'No target found! Antibiotics cannot attach - viruses have no cell wall.',
    'fbVirusFirst': 'First try the antibiotic on the virus (right).', // added
    'fbTryBacterium':
        'No target on the virus - now try the bacterium (left).', // added
    'fbCellMiss': 'Drop the antibiotic onto one of the cells.', // added
    'fbLysis':
        'The cell wall breaks and the bacterium bursts (lysis).', // added
    // Scenario 4.
    's4Title': "Saniya's Claim Analysis",
    's4Quote':
        '"Antibiotics can cure any infection, no matter what causes it." - Saniya',
    's4SortTitle': 'Classify the Pathogens',
    'card': {
      'tb': 'Tuberculosis (Bacteria)',
      'cold': 'Common Cold (Virus)',
      'malaria': 'Malaria (Protozoa)',
      'strep': 'Strep Throat (Bacteria)',
    },
    'zoneEff': 'Antibiotic Effective',
    'zoneIneff': 'Antibiotic Ineffective',
    'fbSortWrong':
        'Incorrect. Antibiotics work only against bacteria.', // added hint
    's4SentenceTitle': "Formulate Vinita's Question",
    'tapWords':
        'Tap the words in order; tap a placed word to remove it.', // added
    'checkQ': 'Check Question',
    'fbQRight': 'Excellent! That is the perfect question.',
    'fbQWrong': 'Not quite right. Try rearranging the words.',
    // Word tiles and the accepted orders (by tile id) for this language.
    'w': {
      'do': 'Do',
      'antibiotics': 'antibiotics',
      'kill': 'kill',
      'viruses': 'viruses',
      'or': 'or',
      'protozoa': 'protozoa',
      'q': '?',
    },
    'qOrders': [
      ['do', 'antibiotics', 'kill', 'viruses', 'or', 'protozoa', 'q'],
      ['do', 'antibiotics', 'kill', 'protozoa', 'or', 'viruses', 'q'],
    ],
    // Scenario 5.
    'fbNoTargetCell':
        'No target found! The flu viruses hide inside our own cells and have no cell wall to attack.', // content fix
    'fbPillMiss': 'Drop the pill onto the human cell.', // added
    'mcqTitle': 'Quiz', // added
    'mcqQ': 'Why do antibiotics fail against viral infections like the Flu?',
    // The source repeated "A." in front of its A/B/C badges.
    'mcqA': 'The flu virus is too strong for normal antibiotics.',
    'mcqB':
        'Viruses use human host cell machinery and lack bacterial structures like cell walls.',
    'mcqC': 'Antibiotics only work when mixed with cough syrup.',
    'fbMcqWrong': 'Incorrect. Think about what we saw in the microscope.',
    'fbMcqRight': 'Correct!', // added
    'scenarios': [
      {
        'title': 'Scenario 1: Discovery of Penicillin',
        'objective':
            "Recreate Alexander Fleming's accidental discovery of the first antibiotic.",
        'board':
            'In 1928, Alexander Fleming observed a petri dish containing Staphylococcus bacteria that had been accidentally contaminated by a mould called Penicillium notatum.',
        'boardBtn': "Enter Fleming's Lab",
        'hud': [
          "Step 1: Read the objective, then click 'Enter Fleming's Lab'.",
          "Step 2: Drag the 'Bacterial Culture' tool onto the petri dish to streak it.",
          "Step 3: Drag the 'Mould Spore' onto the edge of the dish to introduce Penicillium.",
          "Step 4: Drag the 'Ruler' onto the dish to measure the clear ring around the mould.",
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': "Click 'Enter Fleming's Lab'.",
            'observation':
                'Alexander Fleming observed a petri dish contaminated by a mould called Penicillium notatum.',
          },
          {
            'concept': 'The Contaminated Dish',
            'action': "Drag the 'Bacterial Culture' tool to streak the plate.",
            'observation':
                'Small yellow colonies appear across the entire dish.',
          },
          {
            'concept': 'The Contaminated Dish',
            'action':
                "Drag the 'Mould Spore' onto one specific edge of the dish.",
            'observation':
                'A fuzzy green mould colony grows at the drop site, and a clear zone forms around it.',
          },
          {
            'concept': 'Observing the Zone of Inhibition',
            'action': "Use the virtual 'Ruler' tool to measure the distance.",
            'observation':
                'A clear ring of approximately 2 cm where bacteria cannot grow is identified.',
          },
        ],
        'summaryTitle': 'Discovery!',
        'summary':
            'The mould released a substance (**Penicillin**) that killed the bacteria in this zone.',
      },
      {
        'title': 'Scenario 2: Dialogue on Resistance',
        'objective':
            'Understand the correct medical pathway to prevent antibiotic resistance.',
        'board':
            'Indiscriminate use of antibiotics leads to resistance. Resistance means bacteria evolve to survive the drug. Always follow the correct medical pathway.',
        'boardBtn': 'Start Decision Pathway',
        'hud': [
          "Step 1: Click 'Start Decision Pathway'.",
          "Step 2: Try self-medicating by dragging a line from 'Mother Sick' to 'Home Cabinet'.",
          "Step 3: Correct the mistake. Draw the path: Mother Sick, Doctor's Clinic, Pharmacy, back to Mother Sick.",
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': "Click 'Start Decision Pathway'.",
            'observation':
                'Indiscriminate use of antibiotics leads to resistance.',
          },
          {
            'concept': 'The Wrong Path (Self-Medication)',
            'action':
                'Drag a connection line from [Mother Sick] directly to [Home Medicine Cabinet].',
            'observation':
                'Leftover or incomplete doses kill only the weakest bacteria; the resistant ones survive and multiply. Self-medication promotes antibiotic resistance.',
          },
          {
            'concept': 'The Correct Path (Prescription)',
            'action':
                "Drag connection lines: Mother Sick, Doctor's Clinic, Pharmacy, back to Mother Sick.",
            'observation':
                '1. Consult Doctor. 2. Obtain Prescription. 3. Complete Course.',
          },
        ],
        'summaryTitle': 'Pathway Complete!',
        'summary':
            '1. **Consult Doctor.** 2. **Obtain Prescription.** 3. **Complete Course.**',
      },
      {
        'title': 'Scenario 3: Mechanism of Action',
        'objective':
            'Learn why antibiotics only work against bacterial infections.',
        'board':
            'Antibiotics target specific bacterial structures, such as the cell wall synthesis machinery. Viruses lack these structures.',
        'boardBtn': 'Microscope View',
        'hud': [
          "Step 1: Read the objective, then click 'Microscope View'.",
          "Step 2: Drag the 'Antibiotic' molecule from the bottom and drop it onto the 'Virus' (on the right).",
          "Step 3: Drag the 'Antibiotic' molecule and drop it onto the 'Bacterium' (on the left).",
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': "Click 'Microscope View'.",
            'observation':
                'Antibiotics target specific bacterial structures. Viruses lack these.',
          },
          {
            'concept': 'Identifying Targets',
            'action': 'Drag an Antibiotic Molecule to the Virus.',
            'observation':
                "The molecule bounces off the Virus. Text appears: 'No target found'.",
          },
          {
            'concept': 'Cell Wall Destruction',
            'action': 'Drag an Antibiotic Molecule to the Bacterium.',
            'observation':
                'The molecule attaches to the Cell Wall. The cell wall fractures, and the bacterium bursts (lysis).',
          },
        ],
        'summaryTitle': 'Target Destroyed!',
        // Content fix: only some antibiotics act on the cell wall.
        'summary':
            'Some antibiotics, like **penicillin**, kill bacteria by breaking their **cell wall**. Antibiotics cannot kill viruses.',
      },
      {
        'title': "Scenario 4: Saniya's Claim",
        'objective':
            "Use logic to disprove the idea that antibiotics are a 'cure-all'.",
        'board':
            "Saniya believes antibiotics are a 'cure-all'. We must use logic to disprove this generalization using the classification of pathogens.",
        'boardBtn': 'Debate Logic Builder',
        'hud': [
          "Step 1: Click 'Debate Logic Builder'.",
          "Step 2: Drag the pathogen cards into the correct 'Effective' or 'Ineffective' bins.",
          "Step 3: Build Vinita's counter-question from the word blocks, then check it.",
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': "Click 'Debate Logic Builder'.",
            'observation':
                "Saniya believes antibiotics are a 'cure-all'. We must use logic to disprove this.",
          },
          {
            'concept': 'Sorting Pathogens',
            // Was a developer note and named only 2 of the 4 cards.
            'action':
                "Drag each pathogen card into the 'Antibiotic Effective' or 'Antibiotic Ineffective' bin.",
            'observation':
                "Antibiotics act only on bacteria: Tuberculosis and Strep Throat go to 'Effective'; Common Cold and Malaria go to 'Ineffective'.",
          },
          {
            'concept': 'Formulating the Question',
            'action':
                "Assemble Vinita's counter-question from the word blocks: 'Do antibiotics kill viruses or protozoa ?'",
            'observation':
                'Saniya understands that antibiotics only work on bacteria.',
          },
        ],
        'summaryTitle': 'Logic Applied!',
        'summary':
            'Saniya now understands that antibiotics are useless against non-bacterial diseases like **viruses** and **protozoa**.',
      },
      {
        'title': 'Scenario 5: Viral Infection',
        'objective':
            'Identify the biological reason antibiotics fail against the flu.',
        'board':
            'Taking antibiotics for the flu is useless and dangerous. We must identify the biological reason why antibiotics fail against the flu.',
        'boardBtn': 'Investigate the Flu',
        'hud': [
          "Step 1: Click 'Investigate the Flu'.",
          "Step 2: Drag the 'Antibiotic Pill' onto the large 'Human Cell' containing viruses.",
          'Step 3: Select the correct biological reason for the antibiotic\'s failure from the quiz.',
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': "Click 'Investigate the Flu'.",
            'observation':
                'Taking antibiotics for the flu is useless and dangerous.',
          },
          {
            'concept': 'Inside the Host Cell',
            'action': 'Apply the Antibiotic Pill to the Human Cell.',
            // Content fix: no "shield" - the drug simply finds no target.
            'observation':
                'The antibiotic finds no target: the viruses are inside the human cell and have no cell wall.',
          },
          {
            'concept': 'Selecting the Reason',
            // Was "Connect 'Flu Virus' to Option 2" (gave the answer away).
            'action': 'Select the correct reason in the quiz.',
            'observation':
                'Viruses hide inside host cells and lack cell walls, so antibiotics have no mechanism to attack them.',
          },
        ],
        'summaryTitle': 'Investigation Complete!',
        'summary':
            'Since viruses hide **inside host cells** and **lack cell walls**, antibiotics have no mechanism to attack them without hurting the human.',
      },
    ],
  },
  'hi': {
    'appTitle': 'एंटीबायोटिक्स और एंटीबायोटिक प्रतिरोध',
    'appSubtitle': 'कक्षा 8. स्वास्थ्य: सबसे बड़ा खज़ाना',
    'enterLab': 'प्रयोगशाला में प्रवेश करें',
    'selectScenario': 'परिदृश्य चुनें',
    'missionObj': 'मिशन उद्देश्य',
    'conceptExp': 'अन्वेषण चरण',
    'currObj': 'वर्तमान कार्य',
    'exploration': 'चरण',
    'conceptFocus': 'ध्यान',
    'action': 'क्रिया',
    'observation': 'अवलोकन',
    'nextScenario': 'अगला परिदृश्य',
    'restartLab': 'वर्चुअल लैब फिर से शुरू करें',
    'scComplete': 'परिदृश्य {n} पूर्ण!',
    'labComplete': 'सभी परिदृश्य पूर्ण!',
    'scenarioDoneHud': 'परिदृश्य {n} पूर्ण! अगले परिदृश्य पर जाएँ।',
    'labDoneHud': 'सभी परिदृश्य पूरे हुए! प्रयोगशाला कभी भी पुनः आरंभ करें।',
    'labControls': 'प्रयोगशाला नियंत्रण',
    'controlsHint':
        '3D दृश्य में वस्तुओं को खींचें, या इन बटनों का उपयोग करें।',
    'ttLabels': 'लेबल दिखाएँ/छिपाएँ',
    'ttLock': 'कैमरा लॉक / अनलॉक',
    'incorrect': 'गलत। पुनः प्रयास करें।',
    'lbl': {
      'agar': 'अगार प्लेट',
      'loop': 'बैक्टीरिया कल्चर',
      'mould': 'फफूंद बीजाणु',
      'ruler': 'स्केल', // was "शासक" (a ruler of a country)
      'reading': 'लगभग 2 सेमी',
      'bacterium': 'बैक्टीरिया (कोशिका भित्ति)',
      'virus': 'वायरस (कोशिका भित्ति नहीं)',
      'antibiotic': 'एंटीबायोटिक',
      'hostCell': 'मानव मेज़बान कोशिका',
      'noTarget': 'कोई लक्ष्य नहीं मिला',
    },
    'twLoop': 'डिश पर बैक्टीरिया फैलाएँ',
    'twMould': 'डिश के किनारे पर फफूंद डालें',
    'twRuler': 'साफ़ क्षेत्र को मापें',
    'twVirus': 'एंटीबायोटिक वायरस पर डालें',
    'twBacterium': 'एंटीबायोटिक बैक्टीरिया पर डालें',
    'twPill': 'एंटीबायोटिक गोली दें',
    'fbDishMiss': 'इसे पेट्री डिश पर छोड़ें।',
    'fbStreaked': 'पूरी डिश पर बैक्टीरिया की कॉलोनियाँ उग आईं।',
    'fbEdgeMiss': 'फफूंद बीजाणु को डिश के किनारे पर छोड़ें।',
    'fbZone':
        'फफूंद के चारों ओर एक साफ़ क्षेत्र बनता है - वहाँ बैक्टीरिया नहीं उगते।',
    'fbRulerMiss': 'स्केल को साफ़ क्षेत्र के आर-पार रखें।',
    'fbMeasured': 'साफ़ क्षेत्र लगभग 2 सेमी का है।',
    's2Title': 'चिकित्सा निर्णय मार्ग',
    'node': {
      'mother': 'बीमार माँ',
      'cabinet': 'घर की दवा अलमारी (बची हुई दवाएँ)',
      'doctor': 'डॉक्टर का क्लिनिक',
      'pharmacy': 'फार्मेसी (पर्चा)',
    },
    's2Instruction':
        'मार्ग बनाने के लिए एक वृत्त से दूसरे वृत्त तक खींचें (या दो वृत्तों पर टैप करें)।',
    'fbSelfMed':
        'गलत मार्ग! बची हुई या अधूरी खुराक केवल सबसे कमज़ोर बैक्टीरिया को मारती है; प्रतिरोधी बैक्टीरिया बच जाते हैं और बढ़ते हैं। स्व-दवा एंटीबायोटिक प्रतिरोध को बढ़ाती है।',
    'fbFollow': 'इस चरण के निर्देशों का पालन करें।',
    'fbSequence':
        'कृपया सही क्रम अपनाएँ: बीमार माँ, फिर डॉक्टर का क्लिनिक, फिर फार्मेसी, फिर वापस बीमार माँ।',
    'fbNotPath': 'यह सही मार्ग नहीं है।',
    'fbLinkOk': 'सही कड़ी!',
    'fbNoTarget':
        'कोई लक्ष्य नहीं मिला! एंटीबायोटिक जुड़ नहीं सकता - वायरस में कोशिका भित्ति नहीं होती।',
    'fbVirusFirst': 'पहले एंटीबायोटिक को वायरस (दाईं ओर) पर आज़माएँ।',
    'fbTryBacterium':
        'वायरस पर कोई लक्ष्य नहीं - अब बैक्टीरिया (बाईं ओर) पर आज़माएँ।',
    'fbCellMiss': 'एंटीबायोटिक को किसी एक कोशिका पर छोड़ें।',
    'fbLysis': 'कोशिका भित्ति टूट जाती है और बैक्टीरिया फट जाता है (लयन)।',
    's4Title': 'सानिया के दावे का विश्लेषण',
    's4Quote':
        '"एंटीबायोटिक्स कोई भी संक्रमण ठीक कर सकते हैं, चाहे वह किसी भी कारण से हो।" - सानिया',
    's4SortTitle': 'रोगजनकों का वर्गीकरण करें',
    'card': {
      'tb': 'तपेदिक (बैक्टीरिया)',
      'cold': 'सामान्य सर्दी (वायरस)',
      'malaria': 'मलेरिया (प्रोटोजोआ)',
      'strep': 'स्ट्रेप थ्रोट (बैक्टीरिया)',
    },
    'zoneEff': 'एंटीबायोटिक प्रभावी',
    'zoneIneff': 'एंटीबायोटिक अप्रभावी',
    'fbSortWrong': 'गलत। एंटीबायोटिक्स केवल बैक्टीरिया पर काम करते हैं।',
    's4SentenceTitle': 'विनीता का प्रश्न बनाएँ',
    'tapWords':
        'शब्दों को क्रम से टैप करें; रखे गए शब्द को हटाने के लिए उस पर टैप करें।',
    'checkQ': 'प्रश्न जाँचें',
    'fbQRight': 'बहुत बढ़िया! यही सही प्रश्न है।',
    'fbQWrong': 'पूरी तरह सही नहीं। शब्दों को फिर से क्रम में लगाएँ।',
    'w': {
      'do': 'क्या',
      'antibiotics': 'एंटीबायोटिक्स',
      'kill': 'को मारते हैं',
      'viruses': 'वायरस',
      'or': 'या',
      'protozoa': 'प्रोटोजोआ',
      'q': '?',
    },
    'qOrders': [
      ['do', 'antibiotics', 'viruses', 'or', 'protozoa', 'kill', 'q'],
      ['do', 'antibiotics', 'protozoa', 'or', 'viruses', 'kill', 'q'],
    ],
    'fbNoTargetCell':
        'कोई लक्ष्य नहीं मिला! फ्लू के वायरस हमारी अपनी कोशिकाओं के अंदर छिपे हैं और उनमें कोशिका भित्ति नहीं होती।',
    'fbPillMiss': 'गोली को मानव कोशिका पर छोड़ें।',
    'mcqTitle': 'प्रश्नोत्तरी',
    'mcqQ':
        'फ्लू जैसे वायरल संक्रमणों के विरुद्ध एंटीबायोटिक्स क्यों विफल होते हैं?',
    'mcqA': 'फ्लू वायरस सामान्य एंटीबायोटिक्स के लिए बहुत मज़बूत है।',
    'mcqB':
        'वायरस मानव मेज़बान कोशिका की मशीनरी का उपयोग करते हैं और उनमें कोशिका भित्ति जैसी बैक्टीरियल संरचनाएँ नहीं होतीं।',
    'mcqC': 'एंटीबायोटिक्स केवल कफ सिरप के साथ मिलाकर काम करते हैं।',
    'fbMcqWrong': 'गलत। सोचें कि हमने सूक्ष्मदर्शी में क्या देखा।',
    'fbMcqRight': 'सही!',
    // Rewritten from the English (the source Hindi was abridged, with
    // placeholders such as "तैयारी।").
    'scenarios': [
      {
        'title': 'परिदृश्य 1: पेनिसिलिन की खोज',
        'objective':
            'अलेक्जेंडर फ्लेमिंग की पहले एंटीबायोटिक की आकस्मिक खोज को फिर से करें।',
        'board':
            '1928 में, अलेक्जेंडर फ्लेमिंग ने स्टैफिलोकोकस बैक्टीरिया वाली एक पेट्री डिश देखी जो गलती से पेनिसिलियम नोटेटम नामक फफूंद से दूषित हो गई थी।',
        'boardBtn': 'फ्लेमिंग की लैब में जाएँ',
        'hud': [
          "चरण 1: उद्देश्य पढ़ें, फिर 'फ्लेमिंग की लैब में जाएँ' पर क्लिक करें।",
          "चरण 2: 'बैक्टीरिया कल्चर' उपकरण को पेट्री डिश पर खींचकर फैलाएँ।",
          "चरण 3: पेनिसिलियम डालने के लिए 'फफूंद बीजाणु' को डिश के किनारे पर खींचें।",
          "चरण 4: फफूंद के चारों ओर के साफ़ घेरे को मापने के लिए 'स्केल' को डिश पर खींचें।",
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और तैयारी',
            'action': "'फ्लेमिंग की लैब में जाएँ' पर क्लिक करें।",
            'observation':
                'अलेक्जेंडर फ्लेमिंग ने पेनिसिलियम नोटेटम नामक फफूंद से दूषित एक पेट्री डिश देखी।',
          },
          {
            'concept': 'दूषित डिश',
            'action': "प्लेट पर फैलाने के लिए 'बैक्टीरिया कल्चर' उपकरण खींचें।",
            'observation': 'पूरी डिश पर छोटी पीली कॉलोनियाँ दिखाई देती हैं।',
          },
          {
            'concept': 'दूषित डिश',
            'action': "'फफूंद बीजाणु' को डिश के एक किनारे पर खींचें।",
            'observation':
                'जहाँ बीजाणु छोड़ा गया वहाँ हरी रोएँदार फफूंद उगती है, और उसके चारों ओर एक साफ़ क्षेत्र बनता है।',
          },
          {
            'concept': 'निरोध क्षेत्र का अवलोकन',
            'action': "दूरी मापने के लिए 'स्केल' उपकरण का उपयोग करें।",
            'observation':
                'लगभग 2 सेमी का एक साफ़ घेरा मिलता है जहाँ बैक्टीरिया नहीं उग सकते।',
          },
        ],
        'summaryTitle': 'खोज!',
        'summary':
            'फफूंद ने एक पदार्थ (**पेनिसिलिन**) छोड़ा जिसने इस क्षेत्र के बैक्टीरिया को मार दिया।',
      },
      {
        'title': 'परिदृश्य 2: प्रतिरोध पर संवाद',
        'objective':
            'एंटीबायोटिक प्रतिरोध को रोकने के लिए सही चिकित्सा मार्ग समझें।',
        'board':
            'एंटीबायोटिक्स का अंधाधुंध उपयोग प्रतिरोध पैदा करता है। प्रतिरोध का अर्थ है कि बैक्टीरिया दवा के बावजूद जीवित रहना सीख जाते हैं। हमेशा सही चिकित्सा मार्ग अपनाएँ।',
        'boardBtn': 'निर्णय मार्ग शुरू करें',
        'hud': [
          "चरण 1: 'निर्णय मार्ग शुरू करें' पर क्लिक करें।",
          "चरण 2: 'बीमार माँ' से 'घर की दवा अलमारी' तक रेखा खींचकर स्व-दवा आज़माएँ।",
          'चरण 3: गलती सुधारें। मार्ग बनाएँ: बीमार माँ, डॉक्टर का क्लिनिक, फार्मेसी, फिर वापस बीमार माँ।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और तैयारी',
            'action': "'निर्णय मार्ग शुरू करें' पर क्लिक करें।",
            'observation':
                'एंटीबायोटिक्स का अंधाधुंध उपयोग प्रतिरोध पैदा करता है।',
          },
          {
            'concept': 'गलत मार्ग (स्व-दवा)',
            'action':
                '[बीमार माँ] से सीधे [घर की दवा अलमारी] तक जोड़ने वाली रेखा खींचें।',
            'observation':
                'बची हुई या अधूरी खुराक केवल सबसे कमज़ोर बैक्टीरिया को मारती है; प्रतिरोधी बैक्टीरिया बचकर बढ़ते हैं। स्व-दवा एंटीबायोटिक प्रतिरोध को बढ़ाती है।',
          },
          {
            'concept': 'सही मार्ग (पर्चा)',
            'action':
                'जोड़ने वाली रेखाएँ खींचें: बीमार माँ, डॉक्टर का क्लिनिक, फार्मेसी, फिर वापस बीमार माँ।',
            'observation':
                '1. डॉक्टर से सलाह लें। 2. पर्चा लें। 3. पूरा कोर्स करें।',
          },
        ],
        'summaryTitle': 'मार्ग पूर्ण!',
        'summary':
            '1. **डॉक्टर से सलाह लें।** 2. **पर्चा लें।** 3. **पूरा कोर्स करें।**',
      },
      {
        'title': 'परिदृश्य 3: कार्य करने का तरीका',
        'objective':
            'जानें कि एंटीबायोटिक्स केवल बैक्टीरियल संक्रमणों के विरुद्ध ही क्यों काम करते हैं।',
        'board':
            'एंटीबायोटिक्स बैक्टीरिया की विशेष संरचनाओं को निशाना बनाते हैं, जैसे कोशिका भित्ति बनाने वाली मशीनरी। वायरस में ये संरचनाएँ नहीं होतीं।',
        'boardBtn': 'सूक्ष्मदर्शी दृश्य',
        'hud': [
          "चरण 1: उद्देश्य पढ़ें, फिर 'सूक्ष्मदर्शी दृश्य' पर क्लिक करें।",
          "चरण 2: नीचे से 'एंटीबायोटिक' अणु को खींचकर दाईं ओर के 'वायरस' पर छोड़ें।",
          "चरण 3: 'एंटीबायोटिक' अणु को खींचकर बाईं ओर के 'बैक्टीरिया' पर छोड़ें।",
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और तैयारी',
            'action': "'सूक्ष्मदर्शी दृश्य' पर क्लिक करें।",
            'observation':
                'एंटीबायोटिक्स बैक्टीरिया की विशेष संरचनाओं को निशाना बनाते हैं। वायरस में ये नहीं होतीं।',
          },
          {
            'concept': 'लक्ष्य पहचानना',
            'action': 'एंटीबायोटिक अणु को वायरस पर खींचें।',
            'observation':
                "अणु वायरस से टकराकर लौट आता है। संदेश आता है: 'कोई लक्ष्य नहीं मिला'।",
          },
          {
            'concept': 'कोशिका भित्ति का विनाश',
            'action': 'एंटीबायोटिक अणु को बैक्टीरिया पर खींचें।',
            'observation':
                'अणु कोशिका भित्ति से जुड़ता है। कोशिका भित्ति टूटती है और बैक्टीरिया फट जाता है (लयन)।',
          },
        ],
        'summaryTitle': 'लक्ष्य नष्ट!',
        'summary':
            'कुछ एंटीबायोटिक्स, जैसे **पेनिसिलिन**, बैक्टीरिया की **कोशिका भित्ति** तोड़कर उन्हें मारते हैं। एंटीबायोटिक्स वायरस को नहीं मार सकते।',
      },
      {
        'title': 'परिदृश्य 4: सानिया का दावा',
        'objective':
            "तर्क से यह गलत साबित करें कि एंटीबायोटिक्स 'हर रोग की दवा' हैं।",
        'board':
            "सानिया मानती है कि एंटीबायोटिक्स 'हर रोग की दवा' हैं। हमें रोगजनकों के वर्गीकरण से तर्क देकर इस सामान्यीकरण को गलत साबित करना है।",
        'boardBtn': 'तर्क निर्माता',
        'hud': [
          "चरण 1: 'तर्क निर्माता' पर क्लिक करें।",
          "चरण 2: रोगजनक कार्डों को सही 'प्रभावी' या 'अप्रभावी' डिब्बे में खींचें।",
          'चरण 3: शब्द-खंडों से विनीता का प्रति-प्रश्न बनाएँ, फिर जाँचें।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और तैयारी',
            'action': "'तर्क निर्माता' पर क्लिक करें।",
            'observation':
                "सानिया मानती है कि एंटीबायोटिक्स 'हर रोग की दवा' हैं। हमें तर्क से इसे गलत साबित करना है।",
          },
          {
            'concept': 'रोगजनकों को छाँटना',
            'action':
                "हर रोगजनक कार्ड को 'एंटीबायोटिक प्रभावी' या 'एंटीबायोटिक अप्रभावी' डिब्बे में खींचें।",
            'observation':
                "एंटीबायोटिक्स केवल बैक्टीरिया पर काम करते हैं: तपेदिक और स्ट्रेप थ्रोट 'प्रभावी' में; सामान्य सर्दी और मलेरिया 'अप्रभावी' में।",
          },
          {
            'concept': 'प्रश्न बनाना',
            'action':
                "शब्द-खंडों से विनीता का प्रति-प्रश्न बनाएँ: 'क्या एंटीबायोटिक्स वायरस या प्रोटोजोआ को मारते हैं ?'",
            'observation':
                'सानिया समझ जाती है कि एंटीबायोटिक्स केवल बैक्टीरिया पर काम करते हैं।',
          },
        ],
        'summaryTitle': 'तर्क लागू!',
        'summary':
            'सानिया अब समझती है कि एंटीबायोटिक्स **वायरस** और **प्रोटोजोआ** जैसे गैर-बैक्टीरियल रोगों के विरुद्ध बेकार हैं।',
      },
      {
        'title': 'परिदृश्य 5: वायरल संक्रमण',
        'objective':
            'फ्लू के विरुद्ध एंटीबायोटिक्स के विफल होने का जैविक कारण पहचानें।',
        'board':
            'फ्लू के लिए एंटीबायोटिक्स लेना बेकार और खतरनाक है। हमें पता लगाना है कि फ्लू के विरुद्ध एंटीबायोटिक्स क्यों विफल होते हैं।',
        'boardBtn': 'फ्लू की जाँच करें',
        'hud': [
          "चरण 1: 'फ्लू की जाँच करें' पर क्लिक करें।",
          "चरण 2: 'एंटीबायोटिक गोली' को वायरस वाली बड़ी 'मानव कोशिका' पर खींचें।",
          'चरण 3: प्रश्नोत्तरी में एंटीबायोटिक के विफल होने का सही जैविक कारण चुनें।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और तैयारी',
            'action': "'फ्लू की जाँच करें' पर क्लिक करें।",
            'observation': 'फ्लू के लिए एंटीबायोटिक्स लेना बेकार और खतरनाक है।',
          },
          {
            'concept': 'मेज़बान कोशिका के अंदर',
            'action': 'एंटीबायोटिक गोली को मानव कोशिका पर डालें।',
            'observation':
                'एंटीबायोटिक को कोई लक्ष्य नहीं मिलता: वायरस मानव कोशिका के अंदर हैं और उनमें कोशिका भित्ति नहीं होती।',
          },
          {
            'concept': 'कारण चुनना',
            'action': 'प्रश्नोत्तरी में सही कारण चुनें।',
            'observation':
                'वायरस मेज़बान कोशिकाओं में छिपे रहते हैं और उनमें कोशिका भित्ति नहीं होती, इसलिए एंटीबायोटिक्स के पास उन पर हमला करने का कोई तरीका नहीं है।',
          },
        ],
        'summaryTitle': 'जाँच पूरी!',
        'summary':
            'क्योंकि वायरस **मेज़बान कोशिकाओं के अंदर** छिपे रहते हैं और उनमें **कोशिका भित्ति नहीं** होती, इसलिए एंटीबायोटिक्स मनुष्य को नुकसान पहुँचाए बिना उन पर हमला नहीं कर सकते।',
      },
    ],
  },
});

// ------------------------------------------------------------------ model --

const Color _accent = _rt_Tw.cyan500;
const Color _accentSoft = Color(0xFF67E8F9); // cyan-300

/// Steps per scenario (step 1 is always the chalkboard).
const List<int> _stepCounts = [4, 3, 3, 3, 3];

/// S1: 1 cm on the dish (a 9 cm dish of radius 3.9 units).
const double _cm = 0.87;

/// S1: where the mould lands (x, z) and the radius of its clear zone; the
/// zone stays inside the agar (content fix: the source's ring spilled past
/// the dish).
const double _mouldX = 2.0, _mouldZ = 0.8, _zoneR = 1.65;

/// S2 nodes: id -> (x, y as fractions of the board, icon, colour).
const Map<String, (double, double, IconData, Color)> _nodes = {
  'mother': (0.5, 0.12, Icons.sick, Color(0xFFF87171)),
  'cabinet': (0.17, 0.46, Icons.medical_services, Color(0xFFFACC15)),
  'doctor': (0.5, 0.46, Icons.local_hospital, Color(0xFF06B6D4)),
  'pharmacy': (0.5, 0.78, Icons.local_pharmacy, Color(0xFF22C55E)),
};

/// S2 step 3: the correct pathway, in order.
const List<(String, String)> _pathway = [
  ('mother', 'doctor'),
  ('doctor', 'pharmacy'),
  ('pharmacy', 'mother'),
];

/// S4 cards: id -> bin ('eff' or 'ineff').
const Map<String, String> _cards = {
  'tb': 'eff',
  'cold': 'ineff',
  'malaria': 'ineff',
  'strep': 'eff',
};

/// S4 word tiles in the source's bank order.
const List<String> _words = [
  'kill',
  'viruses',
  'do',
  'or',
  'protozoa',
  'q',
  'antibiotics',
];

/// Where a dragged object's handle must be released, on the vertical drag
/// plane through [centre]: at most [halfWidth] to either side, and between
/// [below] under and [above] over the centre.
class _DropWindow {
  const _DropWindow(this.centre, this.halfWidth, this.below, this.above);

  final _rt_V3 centre;
  final double halfWidth;
  final double below;
  final double above;

  bool contains(_rt_V3 h, _rt_V3 side) {
    final across = (h - centre).dot(side).abs();
    final dy = h.y - centre.y;
    return across <= halfWidth && dy >= -below && dy <= above;
  }
}

class _ConfettiPiece {
  _ConfettiPiece(math.Random r)
    : angle = (-90 + (r.nextDouble() - 0.5) * 140) * math.pi / 180,
      speed = 420 + r.nextDouble() * 480,
      color = const [
        Color(0xFF06B6D4),
        Color(0xFF3B82F6),
        Color(0xFFFEF08A),
        Colors.white,
        _rt_Tw.emerald400,
      ][r.nextInt(5)],
      size = 5 + r.nextDouble() * 5,
      spin = (r.nextDouble() - 0.5) * 12;

  final double angle;
  final double speed;
  final Color color;
  final double size;
  final double spin;
}

// ------------------------------------------------------------------- page --

class Cl8Ch13A5AntibioticsResistancePage extends StatefulWidget {
  const Cl8Ch13A5AntibioticsResistancePage({super.key});

  @override
  State<Cl8Ch13A5AntibioticsResistancePage> createState() =>
      _Cl8Ch13A5AntibioticsResistancePageState();
}

class _Cl8Ch13A5AntibioticsResistancePageState
    extends State<Cl8Ch13A5AntibioticsResistancePage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF0E2A33), Color(0xFF020617)],
  );
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 45,
    position: _rt_V3(0, 8.5, 25.5),
    target: _rt_V3(0, 0, 0),
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner(resumeOnCancel: false);
  math.Random _rng = math.Random(135);
  final _rt_Node3D _root = _rt_Node3D(name: 'scenario-root');
  final ValueNotifier<int> _frameTick = ValueNotifier(0);
  final ValueNotifier<double> _confettiT = ValueNotifier(0);
  final List<_rt_Label3D> _labels = [];

  // Scenario objects (rebuilt on every scenario change). Draggable objects
  // are kept by id in [_objects].
  final Map<String, _rt_Node3D> _objects = {};
  _rt_Points3D? _colonies;
  final List<_rt_V3> _colonySpots = [];
  _rt_Node3D? _mould;
  _rt_Node3D? _zoneRing;
  _rt_Label3D? _readout;
  _rt_Label3D? _rulerLabel;
  _rt_Node3D? _virus;
  _rt_Node3D? _bacterium;
  _rt_Material3D? _wallMat;
  _rt_Label3D? _noTargetLabel;
  _rt_Mesh3D? _scanRing;
  final List<(_rt_Node3D, _rt_V3, double)> _floaters = [];

  // --- LAB STATE ---
  int _scenario = 1;
  int _step = 1;
  int _run = 0; // bumped on every scenario change (stale async guard)
  bool _scenarioDone = false;
  bool _busy = false;
  final Set<int> _doneScenarios = {};
  final Set<int> _expandedSteps = {1};
  bool _labelsOn = true;
  bool _locked = true; // the source starts with the camera locked
  double _clock = 0;
  double? _confettiStart;
  List<_ConfettiPiece> _confetti = const [];
  final List<Timer> _timers = [];

  bool _streaked = false; // S1
  bool _mouldAdded = false;
  bool _measured = false;
  final List<(String, String, bool)> _edges = []; // S2 (from, to, correct)
  bool _cabinetAlarm = false;
  String? _linkFrom;
  Offset? _linkPointer;
  bool _virusTested = false; // S3
  bool _lysed = false;
  final Map<String, String> _sorted = {}; // S4 card -> bin
  final List<String> _sentence = [];
  bool _questionDone = false;
  bool _pillGiven = false; // S5
  bool _mcqDone = false;
  String? _mcqWrong;
  String? _selectedChip;
  String? _wrongZone;

  // 3D drag (on the vertical plane through the drop targets, facing the
  // camera, so the object stays under the finger).
  String? _dragId;
  _rt_V3? _planePoint;
  _rt_V3? _planeNormal;
  Offset _grabOffset = Offset.zero;
  double _dragTravel = 0;
  Offset? _lastPointer;

  /// The 2D boards (S2 pathway, S4 debate): no 3D toolbar.
  bool get _panelMode => (_scenario == 2 || _scenario == 4) && _step > 1;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _camera
      ..minDistance = 6
      ..maxDistance = 50
      ..maxPolarAngle = math.pi * 0.47;
    _scene.setLights([
      _rt_Light3D.ambient(intensity: 0.7),
      _rt_Light3D.directional(_rt_V3(10, 20, 10), intensity: 0.75),
    ]);
    _scene.add(_root);
    _changeScenario(1, sound: false);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _cancelTimers();
    _tweens.cancelAll();
    _viewCtrl.dispose();
    _frameTick.dispose();
    _confettiT.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------- timers ---
  /// Runs [fn] after [ms] unless the scenario changes first.
  void _after(int ms, VoidCallback fn) {
    late final Timer timer;
    timer = Timer(Duration(milliseconds: ms), () {
      _timers.remove(timer);
      if (mounted) fn();
    });
    _timers.add(timer);
  }

  void _cancelTimers() {
    for (final t in _timers) {
      t.cancel();
    }
    _timers.clear();
  }

  /// True while the async step started in [run] is still current.
  bool _alive(int run) => mounted && run == _run;

  // ------------------------------------------------------ scene helpers ---
  _rt_Mesh3D _mesh(
    _rt_Geometry3D g,
    Color color, {
    double opacity = 1,
    double shininess = 0.2,
    bool doubleSided = false,
    Color? edge,
  }) {
    return _rt_Mesh3D(
      g,
      _rt_Material3D(
        color: color,
        opacity: opacity,
        shininess: shininess,
        doubleSided: doubleSided,
        edgeColor: edge,
        edgeWidth: 1.5,
      ),
    );
  }

  /// Invisible, finger-sized grab area around a thin object.
  _rt_Mesh3D _proxy(_rt_Geometry3D g) =>
      _mesh(g, Colors.white, opacity: 0)..userData['proxy'] = true;

  _rt_Sphere3D _ball(double r, Color color, {double opacity = 1}) =>
      _rt_Sphere3D(
        r,
        _rt_Material3D(color: color, opacity: opacity, shininess: 0.4),
      );

  _rt_Label3D _label(String key, double x, double y, double z) {
    final label =
        _rt_Label3D(
            _tx.s('lbl.$key'),
            position: _rt_V3(x, y, z),
            pixelHeight: 12,
            color: Colors.white,
            background: const Color(0xD90F172A),
            borderColor: _accent,
          )
          ..pickable = false
          ..visible = _labelsOn;
    label.userData['key'] = key;
    _labels.add(label);
    return label;
  }

  /// Applies the labels toggle (labels marked hidden stay hidden).
  void _syncLabels() {
    for (final l in _labels) {
      l.text = _tx.s('lbl.${l.userData['key']}');
      l.visible = _labelsOn && l.userData['hidden'] != true;
    }
  }

  void _showLabel(_rt_Label3D? l, bool show) {
    if (l == null) return;
    l.userData['hidden'] = !show;
    l.visible = _labelsOn && show;
  }

  void _setHome(_rt_Node3D n, double x, double y, double z) {
    n.position.set(x, y, z);
    n.userData['home'] = _rt_V3(x, y, z);
    n.userData['homeRot'] = n.rotation.clone();
  }

  _rt_Node3D _draggable(String id, _rt_Node3D n) {
    n.userData['drag'] = id;
    _objects[id] = n;
    return n;
  }

  Future<void> _tweenNode(
    _rt_Node3D n,
    _rt_V3 to,
    int ms, {
    _rt_V3? rot,
    double Function(double) ease = _rt_Ease.inOutCubic,
  }) {
    final from = n.position.clone();
    final fromRot = n.rotation.clone();
    return _tweens.run(ms, (t) {
      n.position.copy(from.lerp(to, t));
      if (rot != null) n.rotation.copy(fromRot.lerp(rot, t));
    }, ease: ease);
  }

  // ---------------------------------------------------------- scenes ---
  void _buildScenario() {
    _root.clear();
    _labels.clear();
    _objects.clear();
    _colonySpots.clear();
    _floaters.clear();
    _colonies = null;
    _mould = _zoneRing = _virus = _bacterium = null;
    _readout = _noTargetLabel = _rulerLabel = null;
    _wallMat = null;
    _scanRing = null;
    _rng = math.Random(135 + _scenario);
    switch (_scenario) {
      case 1:
        _buildDish();
      case 3:
        _buildCells();
      case 5:
        _buildHostCell();
    }
    _syncLabels();
  }

  void _buildDish() {
    _root
      ..add(
        _mesh(_rt_Geometry3D.box(18, 0.3, 11), const Color(0xFF1E293B))
          ..position.set(0, -0.35, 0.5)
          ..depthBias = 40,
      )
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(4, 4, 0.2, segments: 48),
            const Color(0xFFE0F2FE),
            opacity: 0.35,
          )
          ..position.y = -0.1
          ..depthBias = 20,
      )
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(3.9, 3.9, 0.2, segments: 48),
            const Color(0xFFFEF08A),
            opacity: 0.8,
          )
          ..position.y = 0.05
          ..depthBias = 10,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.torus(4, 0.06, radialSegments: 6, tubularSegments: 48),
          const Color(0xFFE0F2FE),
          opacity: 0.6,
        )..rotation.x = math.pi / 2,
      )
      ..add(_label('agar', 0, 1.6, -3.6));
    // Bacterial colonies, revealed by the streak.
    for (var i = 0; i < 150; i++) {
      final a = _rng.nextDouble() * 2 * math.pi;
      final r = math.sqrt(_rng.nextDouble()) * 3.7;
      _colonySpots.add(_rt_V3(r * math.cos(a), 0.17, r * math.sin(a)));
    }
    final colonies = _rt_Points3D(
      [],
      color: const Color(0xFFEAB308),
      size: 5,
      sizeAttenuation: false,
    );
    _colonies = colonies;
    _root.add(colonies);
    // Penicillium colony (grows from a speck) and its clear zone.
    final mould = _rt_Node3D()
      ..position.set(_mouldX, 0.18, _mouldZ)
      ..scale.set(0.05, 0.05, 0.05)
      ..visible = false;
    for (var k = 0; k < 6; k++) {
      final a = k / 6 * 2 * math.pi;
      mould.add(
        _ball(0.22 + _rng.nextDouble() * 0.12, const Color(0xFF22C55E))
          ..position.set(0.25 * math.cos(a), 0.05, 0.25 * math.sin(a)),
      );
    }
    mould.add(_ball(0.3, const Color(0xFF16A34A))..position.y = 0.12);
    _mould = mould;
    final ring =
        _mesh(
            _rt_Geometry3D.ring(_zoneR - 0.05, _zoneR + 0.05, segments: 48),
            const Color(0xFF06B6D4),
            opacity: 0.9,
            doubleSided: true,
          )
          ..rotation.x = -math.pi / 2
          ..position.set(_mouldX, 0.19, _mouldZ)
          ..visible = false;
    _zoneRing = ring;
    _root
      ..add(mould)
      ..add(ring);

    // Inoculating loop.
    final loop = _rt_Node3D(name: 'loop')
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.1, 0.1, 2, segments: 10),
          const Color(0xFF94A3B8),
        )..position.y = 0.6,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.025, 0.025, 1.4, segments: 6),
          const Color(0xFFCCCCCC),
        )..position.y = -1.1,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.torus(0.16, 0.025, radialSegments: 5),
          const Color(0xFFCCCCCC),
        )..position.y = -1.95,
      )
      ..add(_proxy(_rt_Geometry3D.capsule(0.45, 3.2))..position.y = -0.3)
      ..add(_label('loop', 0, 2.2, 0));
    _setHome(loop, -5.6, 2.1, 2.6);
    // Mould-spore dropper.
    final dropper = _rt_Node3D(name: 'dropper')
      ..add(
        _mesh(
            _rt_Geometry3D.sphere(0.3, widthSegments: 12, heightSegments: 8),
            const Color(0xFFEF4444),
            shininess: 0.5,
          )
          ..position.y = 1.4
          ..scale.set(1, 1.6, 1),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.1, 0.04, 2, segments: 10),
          const Color(0xFFE0F2FE),
          opacity: 0.5,
        )..position.y = 0.0,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.07, 0.03, 0.9, segments: 8),
          const Color(0xFF22C55E),
        )..position.y = -0.4,
      )
      ..add(_proxy(_rt_Geometry3D.capsule(0.45, 2.6))..position.y = 0.2)
      ..add(_label('mould', 0, 2.5, 0));
    _setHome(dropper, -5.6, 1.6, 2.6);
    // Ruler: zero at its local origin, 1 cm ticks along +x.
    final ruler = _rt_Node3D(name: 'ruler')
      ..add(
        _mesh(_rt_Geometry3D.box(3.4, 0.08, 0.6), const Color(0xFFFDE047))
          ..position.x = 1.7,
      );
    for (var k = 0; k <= 3; k++) {
      ruler.add(
        _mesh(_rt_Geometry3D.box(0.05, 0.1, 0.32), const Color(0xFF111827))
          ..position.set(k * _cm, 0.02, 0.12),
      );
      if (k < 3) {
        ruler.add(
          _mesh(_rt_Geometry3D.box(0.03, 0.1, 0.18), const Color(0xFF111827))
            ..position.set((k + 0.5) * _cm, 0.02, 0.19),
        );
      }
    }
    final readout = _label('reading', _zoneR / 2, 0.9, 0)
      ..userData['hidden'] = true;
    _readout = readout;
    ruler
      ..add(_proxy(_rt_Geometry3D.box(3.8, 0.6, 1.2))..position.x = 1.7)
      ..add(readout)
      ..add(_rulerLabel = _label('ruler', 1.7, 0.6, 0));
    _setHome(ruler, 4.6, -0.12, 3.0);
    _root
      ..add(_draggable('loop', loop))
      ..add(_draggable('dropper', dropper))
      ..add(_draggable('ruler', ruler));
  }

  void _buildCells() {
    _root
      ..add(
        _mesh(_rt_Geometry3D.plane(32, 20), const Color(0xFF1E293B))
          ..position.z = -5
          ..depthBias = 60,
      )
      ..add(
        _mesh(_rt_Geometry3D.plane(0.2, 20), const Color(0xFF334155))
          ..position.set(0, 0, -4.9)
          ..depthBias = 50,
      );
    // Rod-shaped bacterium with a cell wall and pili.
    final wallMat = _rt_Material3D(
      color: const Color(0xFF10B981),
      opacity: 0.8,
      shininess: 0.3,
    );
    _wallMat = wallMat;
    final bacterium = _rt_Node3D(name: 'bacterium')
      ..position.set(-5, 0.8, 0)
      ..rotation.z = math.pi / 4;
    bacterium
      ..add(_rt_Mesh3D(_rt_Geometry3D.capsule(1.2, 1.6, segments: 20), wallMat))
      ..add(
        _mesh(
          _rt_Geometry3D.capsule(1.0, 1.4, segments: 16),
          const Color(0xFF059669),
        ),
      );
    final pili = <_rt_V3>[];
    for (var i = 0; i < 28; i++) {
      final a = _rng.nextDouble() * 2 * math.pi;
      final y = (_rng.nextDouble() - 0.5) * 2.6;
      final dir = _rt_V3(math.cos(a), 0, math.sin(a));
      final base = dir * 1.2 + _rt_V3(0, y, 0);
      pili
        ..add(base)
        ..add(base + dir * 0.35);
    }
    bacterium.add(
      _rt_Line3D(
        pili,
        color: const Color(0xFFA7F3D0),
        width: 1.5,
        segments: true,
      ),
    );
    _bacterium = bacterium;
    // Virus: capsid with spikes (no cell wall).
    final virus = _rt_Node3D(name: 'virus')..position.set(5, 0.8, 0);
    virus.add(
      _mesh(_rt_Geometry3D.icosahedron(1.3), const Color(0xFF8B5CF6))
        ..userData['body'] = true,
    );
    for (final v in _rt_Geometry3D.icosahedron(1.3).vertices) {
      final dir = v.normalized();
      virus
        ..add(
          _mesh(
              _rt_Geometry3D.cylinder(0.04, 0.04, 0.6, segments: 5),
              const Color(0xFF4C1D95),
            )
            ..position.copy(dir * 1.55)
            ..pointAlong(dir),
        )
        ..add(_ball(0.13, const Color(0xFFC4B5FD))..position.copy(dir * 1.9));
    }
    _virus = virus;
    // Below the virus, clear of its name label.
    final noTarget = _label('noTarget', 5, -1.8, 1.0)
      ..userData['hidden'] = true;
    _noTargetLabel = noTarget;
    // Antibiotic molecule with a "key" that fits a bacterial target.
    final drug = _rt_Node3D(name: 'antibiotic')
      ..add(
        _mesh(
          _rt_Geometry3D.capsule(0.22, 0.8, segments: 12),
          const Color(0xFF3B82F6),
          shininess: 0.5,
        ),
      )
      ..add(
        _mesh(_rt_Geometry3D.box(0.18, 0.34, 0.18), const Color(0xFF93C5FD))
          ..position.set(0.24, 0.2, 0),
      )
      ..add(_proxy(_rt_Geometry3D.sphere(0.9)))
      ..add(_label('antibiotic', 0, 1.2, 0));
    _setHome(drug, 0, -3.0, 2.2);
    _root
      ..add(bacterium)
      ..add(virus)
      ..add(_label('bacterium', -5, 4.0, 0))
      ..add(_label('virus', 5, 3.0, 0))
      ..add(noTarget)
      ..add(_draggable('antibiotic', drug));
  }

  void _buildHostCell() {
    final cell = _rt_Node3D(name: 'cell')..position.set(0, 1, 0);
    cell
      ..add(_ball(3.4, const Color(0xFFFCA5A5), opacity: 0.35))
      ..add(
        _ball(1.2, const Color(0xFF6366F1), opacity: 0.9)
          ..position.set(-1, 0.4, -1.2),
      );
    // Flu viruses inside the cell (sampled in a sphere so none pokes out).
    for (var i = 0; i < 8; i++) {
      _rt_V3 p;
      do {
        p = _rt_V3(
          (_rng.nextDouble() - 0.5) * 4.4,
          (_rng.nextDouble() - 0.5) * 4.4,
          (_rng.nextDouble() - 0.5) * 4.4,
        );
      } while (p.length > 2.3);
      final v = _mesh(_rt_Geometry3D.icosahedron(0.3), const Color(0xFFEF4444))
        ..position.copy(p);
      _floaters.add((v, p.clone(), _rng.nextDouble() * 6));
      cell.add(v);
    }
    final scan =
        _mesh(
            _rt_Geometry3D.ring(0.9, 1.0, segments: 40),
            const Color(0xFF22D3EE),
            opacity: 0,
            doubleSided: true,
          )
          ..pickable = false
          ..visible = false;
    _scanRing = scan;
    cell.add(scan);
    final noTarget = _label('noTarget', 0, -2.9, 1.6)
      ..userData['hidden'] = true;
    _noTargetLabel = noTarget;
    final pill = _rt_Node3D(name: 'pill')
      ..add(
        _mesh(
          _rt_Geometry3D.capsule(0.5, 0.9, segments: 16),
          const Color(0xFF3B82F6),
          shininess: 0.5,
        )..scale.set(1, 1, 1),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.51, 0.51, 0.7, segments: 16),
          Colors.white,
          shininess: 0.5,
        )..position.y = 0.3,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.sphere(
            0.51,
            widthSegments: 16,
            heightSegments: 6,
            thetaLength: math.pi / 2,
          ),
          Colors.white,
          shininess: 0.5,
        )..position.y = 0.65,
      )
      ..add(_proxy(_rt_Geometry3D.sphere(1.1)))
      ..add(_label('antibiotic', 0, 1.8, 0));
    _setHome(pill, -6.2, -2.4, 2.0);
    _root
      ..add(cell)
      ..add(_label('hostCell', 0, 5.0, 0))
      ..add(noTarget)
      ..add(_draggable('pill', pill));
  }

  /// Shows only the current S1 tool (the source did the same) plus the
  /// placed ruler.
  void _applyStepVisuals() {
    if (_scenario != 1) return;
    _objects['loop']?.visible = _step <= 2 && !_streaked;
    _objects['dropper']?.visible = _step == 3 && !_mouldAdded;
    _objects['ruler']?.visible = _step >= 4;
  }

  // ------------------------------------------------------------ camera ---
  /// Points that must stay on screen in the current step.
  List<_rt_V3> get _framePoints => switch (_scenario) {
    1 => [
      _rt_V3(-7.8, -0.2, 2.6),
      _rt_V3(8.2, -0.1, 3.0),
      _rt_V3(0, 0, -4.2),
      _rt_V3(0, 0, 4.4),
      _rt_V3(0, 2.4, -3.6),
      _rt_V3(-5.6, 4.6, 2.6),
    ],
    3 => [
      _rt_V3(-7.6, -1.6, 0),
      _rt_V3(7.2, -1.6, 0),
      _rt_V3(-7.6, 4.4, 0),
      _rt_V3(7.2, 4.4, 0),
      _rt_V3(0, -3.6, 2.2),
    ],
    5 => [
      _rt_V3(-7.0, -3.4, 2.0),
      _rt_V3(4.2, -2.4, 0),
      _rt_V3(0, 5.6, 0),
      _rt_V3(-4.2, 1, 0),
      _rt_V3(4.2, 1, 0),
    ],
    _ => [_rt_V3()],
  };

  double get _elevation => switch (_scenario) {
    1 => 0.8,
    5 => 0.2,
    _ => 0.12,
  };

  /// Height of the panel over the top of the 3D view: the camera frames the
  /// props below it.
  double _topReserve(bool compact) =>
      _scenario == 5 && _step == 3 ? (compact ? 200 : 250) : 0;

  /// Width of the chalkboard on the left (step 1).
  double _boardWidth(Size size, bool compact) =>
      math.min(compact ? 270.0 : 420.0, size.width * 0.5);

  /// Canvas size the camera was last fitted for (per scenario and step).
  (int, int, Size, double)? _fitKey;

  /// Frames the step's props in the space left by the chalkboard, the top
  /// panel, the HUD and the toolbar (the source's fixed camera pushed props
  /// off narrow screens). A few projection passes converge.
  void _fitCamera(Size size, bool compact) {
    final reserve = _topReserve(compact);
    final key = (_scenario, _step, size, reserve);
    if (_fitKey == key || size.isEmpty || _panelMode) return;
    _fitKey = key;
    if (_scenario == 2 || _scenario == 4) return; // no 3D scene
    final points = _framePoints;
    const margin = 14.0;
    final top = (compact ? 8.0 : 16.0) + reserve + margin;
    final bottom = size.height - (compact ? 62.0 : 90.0) - margin;
    final left = (_step == 1 ? 12 + _boardWidth(size, compact) : 10.0) + margin;
    final right = size.width - 60.0 - margin;
    if (bottom - top < 40 || right - left < 40) return;
    final e = _elevation;
    final back = _rt_V3(0, math.sin(e), math.cos(e));
    final up = _rt_V3(0, math.cos(e), -math.sin(e));
    var target = _rt_V3();
    for (final p in points) {
      target.add(p);
    }
    target = target / points.length.toDouble();
    var distance = 20.0;
    for (var pass = 0; pass < 6; pass++) {
      _camera.target.copy(target);
      _camera.position.copy(target + back * distance);
      final frame = _camera.frame(size);
      var minX = double.infinity, maxX = -double.infinity;
      var minY = double.infinity, maxY = -double.infinity;
      for (final p in points) {
        final s = frame.project(p);
        if (s == null) continue;
        minX = math.min(minX, s.dx);
        maxX = math.max(maxX, s.dx);
        minY = math.min(minY, s.dy);
        maxY = math.max(maxY, s.dy);
      }
      final ppu = frame.pixelsPerUnit(distance);
      target =
          target +
          _rt_V3(((minX + maxX) - (left + right)) / 2 / ppu, 0, 0) -
          up * (((minY + maxY) - (top + bottom)) / 2 / ppu);
      final scale = math.max(
        (maxX - minX) / (right - left),
        (maxY - minY) / (bottom - top),
      );
      distance = (distance * scale).clamp(
        _camera.minDistance,
        _camera.maxDistance,
      );
    }
    _camera
      ..target.copy(target)
      ..position.copy(target + back * distance)
      ..zoom = 1;
    _camera.saveHome();
    // Smaller labels on phones, where the props stand close together.
    for (final l in _labels) {
      l.pixelHeight = compact ? 10 : 12;
    }
  }

  // ------------------------------------------------------------- frame ---
  void _onFrame(double dt) {
    _clock += dt;
    _tweens.update(dt);
    // S5 viruses drift inside the cell (the source stacked endless tweens
    // each time the scenario was entered).
    for (final (node, base, phase) in _floaters) {
      node
        ..position.set(
          base.x + 0.35 * math.sin(_clock * 0.9 + phase),
          base.y + 0.35 * math.cos(_clock * 0.7 + phase),
          base.z,
        )
        ..rotation.y = _clock + phase;
    }
    if (_confettiStart != null) {
      final t = (_clock - _confettiStart!) / 2.2;
      if (t >= 1) {
        _confettiStart = null;
        _confettiT.value = 0;
        if (mounted) setState(() => _confetti = const []);
      } else {
        _confettiT.value = t;
      }
    }
    _frameTick.value++;
  }

  void _launchConfetti() {
    setState(() => _confetti = List.generate(120, (_) => _ConfettiPiece(_rng)));
    _confettiStart = _clock;
  }

  // ------------------------------------------------------- scenario flow ---
  void _changeScenario(int s, {bool sound = true}) {
    _cancelTimers();
    _tweens.cancelAll();
    _run++;
    if (sound) _rt_playSfx(_rt_Sfx.scenario);
    setState(() {
      _scenario = s;
      _step = 1;
      _scenarioDone = false;
      _busy = false;
      _expandedSteps
        ..clear()
        ..add(1);
      _streaked = _mouldAdded = _measured = false;
      _edges.clear();
      _cabinetAlarm = false;
      _linkFrom = null;
      _linkPointer = null;
      _virusTested = _lysed = false;
      _sorted.clear();
      _sentence.clear();
      _questionDone = false;
      _pillGiven = _mcqDone = false;
      _mcqWrong = null;
      _selectedChip = null;
      _wrongZone = null;
      _dragId = null;
    });
    _buildScenario();
    _applyStepVisuals();
    _fitKey = null;
  }

  void _restart() {
    _confettiStart = null;
    setState(() {
      _doneScenarios.clear();
      _labelsOn = true;
      _locked = true;
      _confetti = const [];
    });
    _viewCtrl.setMode(_rt_DragMode.rotate);
    _changeScenario(1, sound: false);
  }

  /// Moves to the next step (latched so a double tap cannot skip one).
  void _advance() {
    if (_scenarioDone) return;
    if (_step >= _stepCounts[_scenario - 1]) {
      _completeScenario();
      return;
    }
    setState(() {
      _step++;
      _expandedSteps
        ..clear()
        ..add(_step);
      _busy = false;
      _selectedChip = null;
    });
    _applyStepVisuals();
    _fitKey = null;
  }

  /// Chalkboard button.
  void _setupActivity() {
    if (_step != 1 || _busy) return;
    _rt_playSfx(_rt_Sfx.pop);
    _advance();
  }

  void _completeScenario() {
    if (_scenarioDone) return;
    _rt_playSfx(_rt_Sfx.success);
    setState(() {
      _scenarioDone = true;
      _busy = false;
      _selectedChip = null;
      _doneScenarios.add(_scenario);
      _expandedSteps.clear();
    });
    _launchConfetti();
    final scenario = _scenario;
    final last = scenario == _stepCounts.length;
    _after(600, () {
      if (_scenario != scenario) return;
      _shell.showSuccess(
        title: _tx.s('scComplete').replaceAll('{n}', '$scenario'),
        message: last ? _tx.s('labComplete') : null,
        body: _summaryBody(scenario),
        icon: last ? Icons.flag : Icons.emoji_events,
        color: _accent,
        buttonLabel: last ? _tx.s('restartLab') : _tx.s('nextScenario'),
        sound: _rt_Sfx.correct,
        onConfirm: () {
          if (_scenario != scenario) return;
          if (last) {
            _restart();
          } else {
            _changeScenario(scenario + 1);
          }
        },
      );
    });
  }

  /// The per-scenario summary (bold kept).
  Widget _summaryBody(int scenario) {
    final key = 'scenarios.${scenario - 1}';
    final parts = _tx.s('$key.summary').split('**');
    final base = TextStyle(fontSize: 13, color: _rt_Lab.text, height: 1.45);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _tx.s('$key.summaryTitle'),
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: _accentSoft,
          ),
        ),
        const SizedBox(height: 6),
        Text.rich(
          TextSpan(
            children: [
              for (final (i, part) in parts.indexed)
                TextSpan(
                  text: part,
                  style: i.isOdd
                      ? base.copyWith(
                          fontWeight: FontWeight.w900,
                          color: _accentSoft,
                        )
                      : base,
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _toast(String key, {bool good = true, int ms = 3000}) {
    _rt_playSfx(good ? _rt_Sfx.correct : _rt_Sfx.wrong);
    _shell.showToast(
      _tx.s(key),
      color: good ? _rt_Tw.green500 : _rt_Tw.red500,
      icon: good ? Icons.check : Icons.info_outline,
      ms: ms,
    );
  }

  void _flashZone(String zone) {
    setState(() => _wrongZone = zone);
    _after(600, () => setState(() => _wrongZone = null));
  }

  // ------------------------------------------------------------ 3D drags ---
  /// True if [id] may be picked up in the current step.
  bool _grabbable(String id) {
    if (_busy || _scenarioDone) return false;
    return switch ((_scenario, _step, id)) {
      (1, 2, 'loop') => !_streaked,
      (1, 3, 'dropper') => !_mouldAdded,
      (1, 4, 'ruler') => !_measured,
      (3, 2, 'antibiotic') => !_virusTested,
      (3, 3, 'antibiotic') => !_lysed,
      (5, 2, 'pill') => !_pillGiven,
      _ => false,
    };
  }

  /// Ids that can be dragged right now (for the grab / target markers).
  List<String> get _grabbableIds => [
    for (final id in _objects.keys)
      if (_grabbable(id) && _objects[id]!.isVisibleInTree) id,
  ];

  /// Point of the object that follows the finger (inside its grab area).
  _rt_V3 _handleLocal(String id) => switch (id) {
    'loop' => _rt_V3(0, -1.4, 0),
    'dropper' => _rt_V3(0, -0.7, 0),
    'ruler' => _rt_V3(1.0, 0.1, 0),
    _ => _rt_V3(),
  };

  _rt_V3 _handleWorld(String id) =>
      _objects[id]!.localTransform.apply(_handleLocal(id));

  /// Every place [id] can be released over (judged on release, so a wrong
  /// one can explain itself), measured from the handle with tight windows.
  List<(String, _DropWindow)> _targets(String id) => switch ((_scenario, id)) {
    // Loop tip down on the agar anywhere on the dish.
    (1, 'loop') => [('dish', _DropWindow(_rt_V3(0, 0.9, 0), 3.4, 0.9, 1.6))],
    // Dropper tip over the edge spot where the mould goes.
    (1, 'dropper') => [
      ('edge', _DropWindow(_rt_V3(_mouldX, 1.0, _mouldZ), 0.9, 0.9, 1.4)),
    ],
    (1, 'ruler') => [
      ('zone', _DropWindow(_rt_V3(_mouldX - 0.4, 0.6, _mouldZ), 1.8, 1.0, 1.6)),
    ],
    (3, _) => [
      ('virus', _DropWindow(_rt_V3(5, 0.8, 0), 1.9, 1.9, 1.9)),
      ('bacterium', _DropWindow(_rt_V3(-5, 0.8, 0), 2.2, 2.2, 2.2)),
    ],
    (5, _) => [('cell', _DropWindow(_rt_V3(0, 1, 0), 3.2, 3.2, 3.2))],
    _ => const [],
  };

  /// The targets shown as rings for [id]: only the right one.
  Iterable<String> _ringTargets(String id) => switch ((_scenario, _step)) {
    (1, 2) => const ['dish'],
    (1, 3) => const ['edge'],
    (1, 4) => const ['zone'],
    (3, 2) => const ['virus'],
    (3, 3) => const ['bacterium'],
    (5, _) => const ['cell'],
    _ => const [],
  };

  /// Lowest the handle may go (no dragging through the table).
  double _floorY(String id) => switch (_scenario) {
    1 => 0.25,
    3 => -4.0,
    _ => -4.0,
  };

  bool _onPointerDown(_rt_SceneEvent e) {
    final hit = e.hitWhere((n) => n.userData['drag'] != null);
    if (hit == null) return false;
    final id = hit.userData['drag'] as String;
    if (!_grabbable(id)) return false;
    final targets = _targets(id);
    final handle = e.frame.project(_handleWorld(id));
    if (targets.isEmpty || handle == null) return false;
    final fwd = e.frame.fwd;
    final normal = _rt_V3(fwd.x, 0, fwd.z);
    if (normal.lengthSq < 1e-6) {
      normal.set(0, 0, 1);
    } else {
      normal.normalize();
    }
    _planePoint = targets.first.$2.centre;
    _planeNormal = normal;
    _grabOffset = handle - e.position;
    _dragTravel = 0;
    _lastPointer = e.position;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _dragId = id);
    return true;
  }

  void _onPointerMove(_rt_SceneEvent e) {
    final id = _dragId;
    final node = _objects[id];
    if (id == null || node == null) return;
    _dragTravel += (e.position - (_lastPointer ?? e.position)).distance;
    _lastPointer = e.position;
    final p = e.frame
        .ray(e.position + _grabOffset)
        .intersectPlane(_planePoint!, _planeNormal!);
    if (p == null) return;
    p.y = math.max(p.y, _floorY(id));
    node.position.copy(p - (_handleWorld(id) - node.position));
  }

  void _onPointerUp(_rt_SceneEvent e) {
    final id = _dragId;
    if (id == null) return;
    setState(() => _dragId = null);
    // A tap (no real move) never counts as a drop.
    if (_dragTravel < 12) {
      _snapBack(id);
      return;
    }
    _release(id);
  }

  /// Judges where [id] was let go: the nearest target whose window holds
  /// the handle.
  void _release(String id) {
    final n = _planeNormal;
    if (n == null) return;
    final h = _handleWorld(id);
    final side = _rt_V3(n.z, 0, -n.x);
    String? hit;
    var best = double.infinity;
    for (final (t, w) in _targets(id)) {
      if (!w.contains(h, side)) continue;
      final d = (h - w.centre).length;
      if (d < best) {
        best = d;
        hit = t;
      }
    }
    switch ((_scenario, _step, hit)) {
      case (1, 2, 'dish'):
        _streak();
      case (1, 3, 'edge'):
        _addMould();
      case (1, 4, 'zone'):
        _placeRuler();
      case (1, 2, _):
        _miss(id, 'fbDishMiss');
      case (1, 3, _):
        _miss(id, 'fbEdgeMiss');
      case (1, 4, _):
        _miss(id, 'fbRulerMiss');
      case (3, 2, 'virus'):
        _testVirus();
      case (3, 2, 'bacterium'):
        _miss(id, 'fbVirusFirst');
      case (3, 3, 'bacterium'):
        _lyse();
      case (3, 3, 'virus'):
        _miss(id, 'fbTryBacterium');
      case (3, _, _):
        _miss(id, 'fbCellMiss');
      case (5, _, 'cell'):
        _givePill();
      default:
        _miss(id, 'fbPillMiss');
    }
  }

  void _miss(String id, String key) {
    _toast(key, good: false, ms: 3000);
    _snapBack(id);
  }

  Future<void> _snapBack(String id) async {
    final node = _objects[id];
    if (node == null) return;
    final run = _run;
    setState(() => _busy = true);
    await _tweenNode(
      node,
      node.userData['home'] as _rt_V3,
      350,
      rot: node.userData['homeRot'] as _rt_V3,
    );
    if (!_alive(run)) return;
    setState(() => _busy = false);
  }

  // ------------------------------------------------- scenario 1 actions ---
  /// Streaks the loop across the agar; colonies appear behind it.
  Future<void> _streak() async {
    if (_busy || _streaked || _scenario != 1 || _step != 2) return;
    final run = _run;
    setState(() => _busy = true);
    final loop = _objects['loop']!;
    await _tweenNode(loop, _rt_V3(-2.6, 2.3, -1.6), 400);
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    final dots = _colonies!;
    final spots = _colonySpots;
    await _tweens.run(1000, (t) {
      // Zig-zag streak over the dish.
      final zig = math.sin(t * math.pi * 6);
      loop.position.set(-2.6 + 5.2 * t, 2.3, -1.6 + 3.2 * (zig * 0.5 + 0.5));
      dots.points = spots.sublist(0, (spots.length * t).round());
    }, ease: _rt_Ease.linear);
    if (!_alive(run)) return;
    dots.points = List.of(spots);
    await _tweenNode(loop, loop.userData['home'] as _rt_V3, 400);
    if (!_alive(run)) return;
    loop.visible = false;
    _streaked = true;
    _toast('fbStreaked');
    _advance();
  }

  /// Drops the spore at the edge, grows the mould, then clears the zone -
  /// the step only advances once the zone has formed (the source advanced
  /// first).
  Future<void> _addMould() async {
    if (_busy || _mouldAdded || _scenario != 1 || _step != 3) return;
    final run = _run;
    setState(() => _busy = true);
    final dropper = _objects['dropper']!;
    await _tweenNode(dropper, _rt_V3(_mouldX, 1.35, _mouldZ), 450);
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    final mould = _mould!..visible = true;
    unawaited(_tweenNode(dropper, dropper.userData['home'] as _rt_V3, 450));
    await _tweens.run(1000, (t) {
      final s = 0.05 + 0.95 * t;
      mould.scale.set(s, s, s);
    }, ease: _rt_Ease.outCubic);
    if (!_alive(run)) return;
    dropper.visible = false;
    // Bacteria near the mould die, nearest first.
    final dots = _colonies!;
    final centre = _rt_V3(_mouldX, 0.17, _mouldZ);
    final doomed = [
      for (final p in dots.points)
        if ((p - centre).length < _zoneR) p,
    ]..sort((a, b) => (a - centre).length.compareTo((b - centre).length));
    final kept = [
      for (final p in dots.points)
        if ((p - centre).length >= _zoneR) p,
    ];
    await _tweens.run(700, (t) {
      dots.points = [...kept, ...doomed.sublist((doomed.length * t).round())];
    }, ease: _rt_Ease.linear);
    if (!_alive(run)) return;
    dots.points = kept;
    _zoneRing?.visible = true;
    _mouldAdded = true;
    _toast('fbZone', ms: 3500);
    _after(600, _advance);
  }

  /// Lays the ruler from the mould across the clear zone, towards the dish
  /// centre, and shows the reading.
  Future<void> _placeRuler() async {
    if (_busy || _measured || _scenario != 1 || _step != 4) return;
    final run = _run;
    setState(() => _busy = true);
    final ruler = _objects['ruler']!;
    final dx = -_mouldX, dz = -_mouldZ;
    final angle = math.atan2(-dz, dx);
    await _tweenNode(
      ruler,
      _rt_V3(_mouldX, 0.22, _mouldZ),
      600,
      rot: _rt_V3(0, angle, 0),
    );
    if (!_alive(run)) return;
    _showLabel(_readout, true);
    _showLabel(_rulerLabel, false); // the reading takes its place
    _measured = true;
    _toast('fbMeasured', ms: 3500);
    _after(900, _completeScenario);
  }

  // ------------------------------------------------- scenario 2 actions ---
  /// A connector drawn from [a] to [b] (by drag, or two taps).
  void _link(String a, String b) {
    if (_scenario != 2 || _busy || _scenarioDone || a == b) return;
    setState(() {
      _linkFrom = null;
      _linkPointer = null;
    });
    if (_step == 2) {
      if (a != 'mother' || b != 'cabinet') {
        _toast('fbFollow', good: false);
        return;
      }
      // The wrong path, shown on purpose: red line, alarmed cabinet.
      setState(() {
        _edges.add((a, b, false));
        _cabinetAlarm = true;
        _busy = true;
      });
      _rt_playSfx(_rt_Sfx.wrong);
      _shell.showToast(
        _tx.s('fbSelfMed'),
        color: _rt_Tw.red500,
        icon: Icons.warning_amber,
        ms: 5000,
      );
      _after(3000, () {
        setState(() {
          _edges.clear();
          _cabinetAlarm = false;
        });
        _advance();
      });
      return;
    }
    final done = _edges.where((e) => e.$3).length;
    if (done >= _pathway.length) return;
    final expected = _pathway[done];
    if ((a, b) == expected) {
      _rt_playSfx(_rt_Sfx.pop);
      setState(() => _edges.add((a, b, true)));
      if (done + 1 == _pathway.length) {
        _busy = true;
        _after(1200, _completeScenario);
      } else {
        _shell.showToast(
          _tx.s('fbLinkOk'),
          color: _rt_Tw.green500,
          icon: Icons.check,
          ms: 1200,
        );
      }
    } else if (_pathway.contains((a, b))) {
      _toast('fbSequence', good: false, ms: 4000);
    } else {
      _toast('fbNotPath', good: false);
    }
  }

  void _tapNode(String id) {
    if (_scenario != 2 || _step < 2 || _busy || _scenarioDone) return;
    final from = _linkFrom;
    if (from == null) {
      _rt_playSfx(_rt_Sfx.tap);
      setState(() => _linkFrom = id);
    } else if (from == id) {
      setState(() => _linkFrom = null);
    } else {
      _link(from, id);
    }
  }

  // ------------------------------------------------- scenario 3 actions ---
  /// The antibiotic finds no target on the virus and bounces off.
  Future<void> _testVirus() async {
    if (_busy || _virusTested || _scenario != 3 || _step != 2) return;
    final run = _run;
    setState(() => _busy = true);
    final drug = _objects['antibiotic']!;
    await _tweenNode(drug, _rt_V3(3.4, 0.8, 0.6), 300);
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.wrong);
    _shell.showToast(
      _tx.s('fbNoTarget'),
      color: _rt_Tw.amber500,
      icon: Icons.block,
      ms: 4000,
    );
    _showLabel(_noTargetLabel, true);
    final virus = _virus!;
    unawaited(
      _tweens.run(600, (t) {
        virus.rotation.set(0, math.pi / 3 * t, math.pi / 3 * t);
      }, ease: _rt_Ease.outQuad),
    );
    await _tweenNode(drug, _rt_V3(0.4, 2.8, 1.6), 400, ease: _rt_Ease.outQuad);
    if (!_alive(run)) return;
    await _tweenNode(drug, drug.userData['home'] as _rt_V3, 500);
    if (!_alive(run)) return;
    _virusTested = true;
    _after(1200, () => _showLabel(_noTargetLabel, false));
    _advance();
  }

  /// The antibiotic breaks the bacterium's cell wall and it bursts.
  Future<void> _lyse() async {
    if (_busy || _lysed || _scenario != 3 || _step != 3) return;
    final run = _run;
    setState(() => _busy = true);
    final drug = _objects['antibiotic']!;
    await _tweenNode(drug, _rt_V3(-3.6, 1.2, 1.1), 400);
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    _wallMat
      ?..color = const Color(0xFFEF4444)
      ..wireframe = true;
    await _tweens.wait(1000);
    if (!_alive(run)) return;
    final bacterium = _bacterium!;
    await _tweens.run(250, (t) {
      bacterium.scale.set(1 + 0.8 * t, 1 + 1.0 * t, 1 + 0.8 * t);
    }, ease: _rt_Ease.outQuad);
    if (!_alive(run)) return;
    bacterium.visible = false;
    drug.visible = false;
    _lysed = true;
    _toast('fbLysis');
    _after(800, _completeScenario);
  }

  // ------------------------------------------------- scenario 4 actions ---
  void _sortCard(String card, String bin) {
    if (_scenario != 4 || _step != 2 || _busy || _sorted.containsKey(card)) {
      return;
    }
    setState(() => _selectedChip = null);
    if (_cards[card] != bin) {
      _flashZone(bin);
      _toast('fbSortWrong', good: false, ms: 3500);
      return;
    }
    _rt_playSfx(_rt_Sfx.correct);
    setState(() => _sorted[card] = bin);
    if (_sorted.length == _cards.length) {
      _busy = true;
      _after(900, _advance);
    }
  }

  void _addWord(String id) {
    if (_scenario != 4 || _step != 3 || _questionDone) return;
    if (_sentence.contains(id)) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() {
      _sentence.add(id);
      _selectedChip = null;
    });
  }

  void _removeWord(String id) {
    if (_scenario != 4 || _step != 3 || _questionDone) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _sentence.remove(id));
  }

  void _checkQuestion() {
    if (_scenario != 4 || _step != 3 || _questionDone || _busy) return;
    final orders = _tx.list('qOrders');
    final ok = orders.any((o) {
      final order = (o as List).cast<String>();
      if (order.length != _sentence.length) return false;
      for (var i = 0; i < order.length; i++) {
        if (order[i] != _sentence[i]) return false;
      }
      return true;
    });
    if (!ok) {
      _toast('fbQWrong', good: false, ms: 3500);
      return;
    }
    setState(() {
      _questionDone = true;
      _busy = true;
    });
    _toast('fbQRight');
    _after(1500, _completeScenario);
  }

  // ------------------------------------------------- scenario 5 actions ---
  /// The pill goes into the infected cell and finds nothing to attack
  /// (content fix: the source showed a shield, as if the cell repelled it).
  Future<void> _givePill() async {
    if (_busy || _pillGiven || _scenario != 5 || _step != 2) return;
    final run = _run;
    setState(() => _busy = true);
    final pill = _objects['pill']!;
    await _tweenNode(pill, _rt_V3(0, 1, 1.2), 600);
    if (!_alive(run)) return;
    await _tweens.run(400, (t) {
      final s = 1 - 0.6 * t;
      pill.scale.set(s, s, s);
    });
    if (!_alive(run)) return;
    // A search ring sweeps the cell: no cell wall, no target.
    final scan = _scanRing!..visible = true;
    _rt_playSfx(_rt_Sfx.wrong);
    await _tweens.run(900, (t) {
      final s = 0.8 + 2.6 * t;
      scan
        ..scale.set(s, s, s)
        ..material.opacity = 0.9 * (1 - t);
    }, ease: _rt_Ease.outCubic);
    if (!_alive(run)) return;
    scan.visible = false;
    _showLabel(_noTargetLabel, true);
    _shell.showToast(
      _tx.s('fbNoTargetCell'),
      color: _rt_Tw.amber500,
      icon: Icons.block,
      ms: 4500,
    );
    _pillGiven = true;
    _after(1500, _advance);
  }

  void _answerMcq(String option) {
    if (_scenario != 5 || _step != 3 || _mcqDone || _busy) return;
    if (option != 'B') {
      setState(() => _mcqWrong = option);
      _toast('fbMcqWrong', good: false, ms: 3500);
      return;
    }
    setState(() {
      _mcqDone = true;
      _mcqWrong = null;
      _busy = true;
    });
    _toast('fbMcqRight');
    _after(1200, _completeScenario);
  }

  // ------------------------------------------------------------- misc ---
  void _selectChip(String id) {
    if (_busy) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() => _selectedChip = _selectedChip == id ? null : id);
  }

  void _toggleLabels() {
    _rt_playSfx(_rt_Sfx.toggle);
    setState(() => _labelsOn = !_labelsOn);
    _syncLabels();
  }

  /// Sidebar twins of the 3D drags: (key, label, action, done). The action
  /// is null while it is not available (busy or done).
  List<(String, String, VoidCallback?, bool)> get _twins {
    (String, String, VoidCallback?, bool) twin(
      String key,
      String labelKey,
      bool done,
      VoidCallback fn,
    ) => (key, _tx.s(labelKey), !done && !_busy ? fn : null, done);
    return switch ((_scenario, _step)) {
      (1, 2) => [twin('twin-loop', 'twLoop', _streaked, _streak)],
      (1, 3) => [twin('twin-mould', 'twMould', _mouldAdded, _addMould)],
      (1, 4) => [twin('twin-ruler', 'twRuler', _measured, _placeRuler)],
      (3, 2) => [twin('twin-virus', 'twVirus', _virusTested, _testVirus)],
      (3, 3) => [twin('twin-bacterium', 'twBacterium', _lysed, _lyse)],
      (5, 2) => [twin('twin-pill', 'twPill', _pillGiven, _givePill)],
      _ => const [],
    };
  }

  /// Tap markers for 3D objects that are tapped, not dragged (none here).
  List<(String, _rt_V3)> get _tapSpots => const [];

  /// Nothing in this lab is tapped in 3D; every 3D action is a drag.
  void _onCanvasTap(_rt_SceneEvent e) {}

  // --------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          for (final l in _labels) {
            l.text = _tx.s('lbl.${l.userData['key']}');
          }
          return _rt_ActivityShell(
            controller: _shell,
            title: _tx.s('appTitle'),
            subtitle: _tx.s('appSubtitle'),
            canvasBackground: _rt_Tw.slate950,
            theme: const _rt_ShellTheme(
              accent: _accent,
              headerGradient: [_rt_Tw.slate900, Color(0xFF164E63)],
              headerSubtitleColor: Color(0xFFA5F3FC),
            ),
            intro: _rt_IntroConfig(
              title: _tx.s('appTitle'),
              subtitle: _tx.s('appSubtitle'),
              buttonLabel: _tx.s('enterLab'),
              icon: Icons.medication,
              buttonIcon: Icons.science,
            ),
            onRestart: _restart,
            // The 2D boards have nothing to zoom or rotate.
            onZoomIn: _panelMode ? null : _camera.zoomIn,
            onZoomOut: _panelMode ? null : _camera.zoomOut,
            onResetView: _panelMode ? null : _camera.reset,
            toolbarExtras: _panelMode
                ? const []
                : [
                    _rt_RotatePanToggle(controller: _viewCtrl, accent: _accent),
                    const SizedBox(height: 4),
                    _toolButton(
                      key: const ValueKey('btn-lock'),
                      // The source showed an open lock while locked.
                      icon: _locked ? Icons.lock : Icons.lock_open,
                      tip: _tx.s('ttLock'),
                      active: _locked,
                      onTap: () {
                        _rt_playSfx(_rt_Sfx.toggle);
                        setState(() => _locked = !_locked);
                      },
                    ),
                    const SizedBox(height: 4),
                    _toolButton(
                      key: const ValueKey('btn-labels'),
                      icon: Icons.sell,
                      tip: _tx.s('ttLabels'),
                      active: _labelsOn,
                      onTap: _toggleLabels,
                    ),
                  ],
            tabs: [
              _rt_ShellTab(
                label: _tx.s('conceptExp'),
                icon: Icons.science,
                builder: (_) => _sidebar(),
              ),
            ],
            canvas: _rt_Scene3DView(
              scene: _scene,
              camera: _camera,
              controller: _viewCtrl,
              cameraControls: !_locked,
              onFrame: _onFrame,
              onTap: _onCanvasTap,
              onPointerDown: _onPointerDown,
              onPointerMove: _onPointerMove,
              onPointerUp: _onPointerUp,
            ),
            canvasOverlays: [
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, c) => _overlay(c.biggest),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _toolButton({
    required Key key,
    required IconData icon,
    required String tip,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tip,
      child: InkResponse(
        key: key,
        radius: 22,
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: active ? _accent : _rt_Lab.surface,
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

  Widget _overlay(Size size) {
    final compact = size.height < 480;
    _fitCamera(size, compact);
    return Stack(
      children: [
        if (!_panelMode && !_scenarioDone)
          Positioned.fill(
            child: IgnorePointer(
              child: ValueListenableBuilder<int>(
                valueListenable: _frameTick,
                builder: (context, _, _) => _markers(size, compact),
              ),
            ),
          ),
        if (_scenario == 2 && _step > 1)
          Positioned.fill(child: _pathwayBoard(compact)),
        if (_scenario == 4 && _step > 1)
          Positioned.fill(child: _debateBoard(compact)),
        if (_step == 1) _chalkboard(size, compact),
        ..._stepPanels(compact),
        Positioned(
          left: 64,
          right: 64,
          bottom: 10,
          child: Center(child: _hud(compact)),
        ),
        if (_confetti.isNotEmpty)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _ConfettiPainter(_confettiT, _confetti),
              ),
            ),
          ),
      ],
    );
  }

  // ------------------------------------------------------- step panels ---
  List<Widget> _stepPanels(bool compact) {
    if (_scenarioDone) return const [];
    if (_scenario == 5 && _step == 3) return [_topPanel(_mcqPanel(compact))];
    return const [];
  }

  Widget _mcqPanel(bool compact) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('mcqTitle')),
        Text(
          _tx.s('mcqQ'),
          style: TextStyle(
            fontSize: compact ? 12.5 : 14,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            height: 1.35,
          ),
        ),
        SizedBox(height: compact ? 6 : 10),
        for (final o in const ['A', 'B', 'C'])
          Padding(
            padding: EdgeInsets.only(bottom: compact ? 4 : 6),
            child: _rt_ChoiceButton(
              key: ValueKey('mcq-$o'),
              label: '$o. ${_tx.s('mcq$o')}',
              state: _mcqDone && o == 'B'
                  ? _rt_ChoiceState.correct
                  : (_mcqWrong == o
                        ? _rt_ChoiceState.wrong
                        : _rt_ChoiceState.idle),
              onTap: _mcqDone ? null : () => _answerMcq(o),
            ),
          ),
      ],
    );
  }

  Widget _boardTitle(String key, bool compact) => Text(
    _tx.s(key),
    textAlign: TextAlign.center,
    style: TextStyle(
      fontSize: compact ? 14 : 19,
      fontWeight: FontWeight.w900,
      color: Colors.white,
    ),
  );

  // ------------------------------------------------- S2 decision pathway ---
  Widget _pathwayBoard(bool compact) {
    final nodeSize = compact ? 52.0 : 74.0;
    return Container(
      color: const Color(0xF20F172A),
      padding: EdgeInsets.fromLTRB(12, compact ? 6 : 14, 12, compact ? 72 : 88),
      child: Column(
        children: [
          _boardTitle('s2Title', compact),
          const SizedBox(height: 2),
          Text(
            _tx.s('s2Instruction'),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: compact ? 10.5 : 12,
              fontWeight: FontWeight.w700,
              color: Colors.white60,
            ),
          ),
          SizedBox(height: compact ? 2 : 8),
          Expanded(
            child: LayoutBuilder(
              builder: (context, c) {
                final size = c.biggest;
                Offset centre(String id) {
                  final (fx, fy, _, _) = _nodes[id]!;
                  return Offset(fx * size.width, fy * size.height);
                }

                final from = _linkFrom;
                final pointer = _linkPointer;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PathwayPainter(
                          edges: [
                            for (final (a, b, ok) in _edges)
                              (
                                centre(a),
                                centre(b),
                                ok,
                                a == 'pharmacy' && b == 'mother',
                              ),
                          ],
                          preview: from != null && pointer != null
                              ? (centre(from), pointer)
                              : null,
                          nodeRadius: nodeSize / 2,
                        ),
                      ),
                    ),
                    for (final id in _nodes.keys)
                      ..._nodeWidgets(id, centre, nodeSize, compact),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _nodeWidgets(
    String id,
    Offset Function(String) centre,
    double size,
    bool compact,
  ) {
    final (_, _, icon, color) = _nodes[id]!;
    final c = centre(id);
    final selected = _linkFrom == id;
    final alarm = id == 'cabinet' && _cabinetAlarm;
    Offset toBoard(Offset local) => c - Offset(size / 2, size / 2) + local;
    String? nodeAt(Offset p) {
      for (final other in _nodes.keys) {
        if (other != id && (centre(other) - p).distance < size * 0.75) {
          return other;
        }
      }
      return null;
    }

    return [
      Positioned(
        left: c.dx - size / 2,
        top: c.dy - size / 2,
        width: size,
        height: size,
        child: GestureDetector(
          key: ValueKey('node-$id'),
          behavior: HitTestBehavior.opaque,
          onTap: () => _tapNode(id),
          onPanStart: (d) {
            if (_busy || _scenarioDone) return;
            setState(() {
              _linkFrom = id;
              _linkPointer = toBoard(d.localPosition);
            });
          },
          onPanUpdate: (d) {
            if (_linkFrom != id) return;
            setState(() => _linkPointer = toBoard(d.localPosition));
          },
          onPanEnd: (_) {
            final p = _linkPointer;
            final target = p == null ? null : nodeAt(p);
            if (_linkFrom == id && target != null) {
              _link(id, target);
            } else {
              setState(() {
                _linkFrom = null;
                _linkPointer = null;
              });
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: alarm ? const Color(0xCC7F1D1D) : const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(size * 0.3),
              border: Border.all(
                color: selected ? _rt_Tw.amber400 : color,
                width: selected ? 3 : 2,
              ),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 14),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(icon, size: size * 0.5, color: color),
                // Content fix: the danger is resistant bacteria (the source
                // showed a virus icon here).
                if (alarm)
                  Positioned(
                    right: 2,
                    top: 2,
                    child: CustomPaint(
                      size: Size.square(size * 0.42),
                      painter: const _BacteriaIconPainter(),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      Positioned(
        left: c.dx - 80,
        top: c.dy + size / 2 + 2,
        width: 160,
        child: IgnorePointer(
          child: Text(
            _tx.s('node.$id'),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: compact ? 10 : 12,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    ];
  }

  // ---------------------------------------------------- S4 debate board ---
  Widget _debateBoard(bool compact) {
    return Container(
      color: const Color(0xF20F172A),
      padding: EdgeInsets.fromLTRB(12, compact ? 6 : 14, 12, compact ? 72 : 88),
      child: Column(
        children: [
          _boardTitle('s4Title', compact),
          SizedBox(height: compact ? 4 : 8),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: compact ? 4 : 8,
            ),
            decoration: BoxDecoration(
              color: const Color(0x33F59E0B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _rt_Tw.amber400),
            ),
            child: Text(
              _tx.s('s4Quote'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: compact ? 11 : 13,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFFDE68A),
              ),
            ),
          ),
          SizedBox(height: compact ? 6 : 12),
          Expanded(
            child: _step == 2 ? _sortPart(compact) : _sentencePart(compact),
          ),
        ],
      ),
    );
  }

  Widget _sortPart(bool compact) {
    return Column(
      children: [
        _panelTitle(_tx.s('s4SortTitle')),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _bin('eff', _rt_Tw.green500, compact)),
              SizedBox(width: compact ? 8 : 16),
              Expanded(child: _bin('ineff', _rt_Tw.red500, compact)),
            ],
          ),
        ),
        SizedBox(height: compact ? 6 : 10),
        Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: WrapAlignment.center,
          children: [
            for (final id in _cards.keys)
              if (!_sorted.containsKey(id))
                _draggableChip(id, 'card.$id', _accentSoft, compact),
          ],
        ),
      ],
    );
  }

  Widget _bin(String bin, Color color, bool compact) {
    return _dropZone(
      key: 'bin-$bin',
      zone: bin,
      idle: color,
      onDrop: (card) => _sortCard(card, bin),
      builder: (hover, c) => Container(
        padding: EdgeInsets.all(compact ? 6 : 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: hover ? 0.25 : 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c, width: 2),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _tx.s(bin == 'eff' ? 'zoneEff' : 'zoneIneff'),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 11.5 : 13,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
              ),
              SizedBox(height: compact ? 4 : 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                alignment: WrapAlignment.center,
                children: [
                  for (final MapEntry(key: card, value: b) in _sorted.entries)
                    if (b == bin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _tx.s('card.$card'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _wordTile(String id, {bool placed = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: placed ? _accent : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: placed ? _accentSoft : Colors.white38),
      ),
      child: Text(
        _tx.s('w.$id'),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Vinita's question: tap (or drag) words into the sentence; tap a
  /// placed word to send it back (the source's HTML5 drag-and-drop failed
  /// on touch screens and could not reorder).
  Widget _sentencePart(bool compact) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _panelTitle(_tx.s('s4SentenceTitle')),
          Text(
            _tx.s('tapWords'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 10.5, color: Colors.white60),
          ),
          SizedBox(height: compact ? 6 : 10),
          DragTarget<String>(
            onWillAcceptWithDetails: (_) => !_questionDone,
            onAcceptWithDetails: (d) => _addWord(d.data),
            builder: (context, candidates, _) => Container(
              key: const ValueKey('sentence'),
              width: double.infinity,
              constraints: BoxConstraints(minHeight: compact ? 44 : 56),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: candidates.isNotEmpty
                    ? const Color(0x33FBBF24)
                    : const Color(0x22FFFFFF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _questionDone ? _rt_Tw.green500 : Colors.white54,
                  width: 1.5,
                ),
              ),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  for (final id in _sentence)
                    GestureDetector(
                      key: ValueKey('placed-$id'),
                      onTap: () => _removeWord(id),
                      child: _wordTile(id, placed: true),
                    ),
                ],
              ),
            ),
          ),
          SizedBox(height: compact ? 8 : 14),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              for (final id in _words)
                if (!_sentence.contains(id))
                  Draggable<String>(
                    key: ValueKey('word-$id'),
                    data: id,
                    maxSimultaneousDrags: _questionDone ? 0 : 1,
                    feedback: Material(
                      color: Colors.transparent,
                      child: _wordTile(id),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: _wordTile(id),
                    ),
                    child: GestureDetector(
                      onTap: () => _addWord(id),
                      child: _wordTile(id),
                    ),
                  ),
            ],
          ),
          SizedBox(height: compact ? 8 : 16),
          _rt_ActionButton(
            key: const ValueKey('btn-check'),
            label: _tx.s('checkQ'),
            icon: Icons.fact_check,
            color: _accent,
            done: _questionDone,
            onPressed: _questionDone || _sentence.isEmpty
                ? null
                : _checkQuestion,
          ),
        ],
      ),
    );
  }

  /// Dashed rings on the right containers, a hand on each grabbable object
  /// and on each object to tap (the source only showed a hand mid-drag).
  Widget _markers(Size size, bool compact) {
    if (size.isEmpty) return const SizedBox.shrink();
    final frame = _camera.frame(size);
    final dragging = _dragId;
    final ids = dragging != null ? [dragging] : _grabbableIds;
    final ring = compact ? 46.0 : 60.0;
    final windows = <String, _DropWindow>{
      for (final id in ids)
        for (final (t, w) in _targets(id)) t: w,
    };
    final rings = <String>{for (final id in ids) ..._ringTargets(id)};
    final children = <Widget>[];
    for (final t in rings) {
      final w = windows[t];
      final p = w == null ? null : frame.project(w.centre);
      if (p == null) continue;
      children.add(
        Positioned(
          left: p.dx - ring / 2,
          top: p.dy - ring / 2,
          width: ring,
          height: ring,
          child: CustomPaint(
            key: ValueKey('target-$t'),
            painter: _DashedPainter(
              dragging != null ? _rt_Tw.amber400 : Colors.white70,
              round: true,
              fill: dragging != null,
            ),
          ),
        ),
      );
    }
    if (dragging == null) {
      for (final id in ids) {
        final h = frame.project(_handleWorld(id));
        if (h != null) children.add(_hand('grab-$id', h, Icons.pan_tool_alt));
      }
      for (final (key, world) in _tapSpots) {
        final p = frame.project(world);
        if (p != null) children.add(_hand(key, p, Icons.touch_app));
      }
    }
    return Stack(clipBehavior: Clip.none, children: children);
  }

  Widget _hand(String key, Offset at, IconData icon) {
    final pulse = 1 + 0.12 * math.sin(_clock * 5);
    return Positioned(
      left: at.dx - 15,
      top: at.dy - 15,
      width: 30,
      height: 30,
      child: Transform.scale(
        key: ValueKey(key),
        scale: pulse,
        child: Container(
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
      ),
    );
  }

  // ------------------------------------------------------ chalkboard ---
  Widget _chalkboard(Size size, bool compact) {
    final key = 'scenarios.${_scenario - 1}';
    return Positioned(
      left: 12,
      top: 8,
      bottom: compact ? 64 : 84,
      width: _boardWidth(size, compact),
      child: Center(
        child: SingleChildScrollView(
          child: Container(
            key: const ValueKey('chalkboard'),
            padding: EdgeInsets.all(compact ? 12 : 20),
            decoration: BoxDecoration(
              color: const Color(0xFF064E3B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF78350F),
                width: compact ? 7 : 12,
              ),
              boxShadow: const [
                BoxShadow(color: Colors.black54, blurRadius: 18),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _tx.s('$key.board'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: compact ? 13 : 17,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: compact ? 10 : 18),
                Center(
                  child: _rt_ActionButton(
                    key: const ValueKey('btn-setup'),
                    label: _tx.s('$key.boardBtn'),
                    icon: Icons.play_arrow,
                    color: const Color(0xFFB45309),
                    sound: null,
                    onPressed: _setupActivity,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------- shared widgets ---
  Widget _glass({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xE60F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _accent.withValues(alpha: 0.5)),
        boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12)],
      ),
      child: child,
    );
  }

  Widget _panelTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
        color: _accentSoft,
      ),
    ),
  );

  Widget _topPanel(Widget child) => Positioned(
    top: 10,
    left: 12,
    right: _panelMode ? 12 : 64,
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: _glass(child: child),
      ),
    ),
  );

  Widget _chipBody(
    String labelKey,
    Color color,
    bool compact, {
    bool selected = false,
    Widget? icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: compact ? 6 : 8),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF3B2F0B) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected ? _rt_Tw.amber400 : color.withValues(alpha: 0.8),
          width: selected ? 2 : 1.2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[icon, const SizedBox(width: 6)],
          Flexible(
            child: Text(
              _tx.s(labelKey),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// A chip that can be dragged onto a zone, or tapped and then the zone.
  Widget _draggableChip(
    String id,
    String labelKey,
    Color color,
    bool compact, {
    Widget? icon,
  }) {
    final chip = _chipBody(
      labelKey,
      color,
      compact,
      selected: _selectedChip == id,
      icon: icon,
    );
    return Draggable<String>(
      key: ValueKey('chip-$id'),
      data: id,
      maxSimultaneousDrags: _busy ? 0 : 1,
      onDragStarted: () => setState(() => _selectedChip = null),
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.08,
          child: _chipBody(labelKey, color, compact, icon: icon),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: chip),
      child: GestureDetector(onTap: () => _selectChip(id), child: chip),
    );
  }

  /// Drop zone for chips (drag or tap-to-place).
  Widget _dropZone({
    required String key,
    required String zone,
    required void Function(String chip) onDrop,
    required Widget Function(bool hover, Color color) builder,
    Color idle = Colors.white70,
  }) {
    return DragTarget<String>(
      onWillAcceptWithDetails: (_) => !_busy,
      onAcceptWithDetails: (d) => onDrop(d.data),
      builder: (context, candidates, _) {
        final hover = candidates.isNotEmpty;
        final color = _wrongZone == zone
            ? _rt_Tw.red500
            : hover || _selectedChip != null
            ? _rt_Tw.amber400
            : idle;
        return GestureDetector(
          key: ValueKey(key),
          behavior: HitTestBehavior.opaque,
          onTap: () {
            final chip = _selectedChip;
            if (chip != null) onDrop(chip);
          },
          child: builder(hover, color),
        );
      },
    );
  }

  // --------------------------------------------------------------- HUD ---
  Widget _hud(bool compact) {
    final last = _scenario == _stepCounts.length;
    final text = _scenarioDone
        ? _tx
              .s(last ? 'labDoneHud' : 'scenarioDoneHud')
              .replaceAll('{n}', '$_scenario')
        : _tx.s('scenarios.${_scenario - 1}.hud.${_step - 1}');
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: compact ? 6 : 9,
        ),
        decoration: BoxDecoration(
          color: const Color(0xEB0F172A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _accent, width: 1.4),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 12)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info, size: 18, color: _accentSoft),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _tx.s('currObj').toUpperCase(),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                      color: _accentSoft,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    text,
                    key: const ValueKey('hud-text'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 11.5 : 13,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (_scenarioDone) ...[
              const SizedBox(width: 8),
              _rt_ActionButton(
                key: const ValueKey('btn-hud-next'),
                label: last ? _tx.s('restartLab') : _tx.s('nextScenario'),
                icon: last ? Icons.replay : Icons.arrow_forward,
                color: _accent,
                sound: _rt_Sfx.scenario,
                onPressed: last
                    ? _restart
                    : () => _changeScenario(_scenario + 1, sound: false),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------- sidebar ---
  Widget _sidebar() {
    final scenarioKey = 'scenarios.${_scenario - 1}';
    final twins = _scenarioDone
        ? const <(String, String, VoidCallback?, bool)>[]
        : _twins;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (twins.isNotEmpty) ...[
            _rt_SectionLabel(
              _tx.s('labControls'),
              icon: Icons.touch_app,
              color: _accent,
            ),
            Text(
              _tx.s('controlsHint'),
              style: TextStyle(fontSize: 11.5, color: _rt_Lab.textMuted),
            ),
            const SizedBox(height: 6),
            for (final (key, label, action, done) in twins)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: _rt_ActionButton(
                  key: ValueKey(key),
                  label: label,
                  icon: Icons.pan_tool_alt,
                  color: _accent,
                  expand: true,
                  done: done,
                  onPressed: action,
                ),
              ),
            const SizedBox(height: 6),
          ],
          _rt_SectionLabel(
            _tx.s('selectScenario'),
            icon: Icons.list_alt,
            color: _accent,
          ),
          for (var s = 1; s <= _stepCounts.length; s++)
            _rt_ChoiceButton(
              key: ValueKey('scn-$s'),
              label: _tx.s('scenarios.${s - 1}.title'),
              state: s == _scenario
                  ? _rt_ChoiceState.selected
                  : (_doneScenarios.contains(s)
                        ? _rt_ChoiceState.correct
                        : _rt_ChoiceState.idle),
              onTap: s == _scenario ? null : () => _changeScenario(s),
            ),
          const SizedBox(height: 8),
          _rt_ObjectiveCard(
            title: _tx.s('missionObj'),
            desc: _tx.s('$scenarioKey.objective'),
            accent: _accent,
          ),
          const SizedBox(height: 10),
          _rt_SectionLabel(
            _tx.s('conceptExp'),
            icon: Icons.checklist,
            color: _accent,
          ),
          for (var i = 1; i <= _stepCounts[_scenario - 1]; i++) _stepCard(i),
        ],
      ),
    );
  }

  Widget _stepCard(int i) {
    final step = _tx.map('scenarios.${_scenario - 1}.steps.${i - 1}');
    final done = i < _step || _scenarioDone;
    final current = i == _step && !_scenarioDone;
    final open = _expandedSteps.contains(i);
    TextStyle line = TextStyle(fontSize: 12, color: _rt_Lab.text, height: 1.35);
    TextStyle tag = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w900,
      color: _rt_Lab.onTinted(_accentSoft, _rt_Tw.green700),
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: current
            ? _rt_Lab.tinted(_rt_Tw.green50, _accent)
            : _rt_Lab.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          key: ValueKey('stepcard-$i'),
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            _rt_playSfx(_rt_Sfx.tap);
            setState(() {
              if (!_expandedSteps.remove(i)) _expandedSteps.add(i);
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: current
                    ? _accent
                    : (done ? _rt_Tw.emerald500 : _rt_Lab.border),
                width: current ? 2 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: done
                            ? _rt_Tw.emerald500
                            : (current ? _accent : _rt_Lab.overlay),
                        shape: BoxShape.circle,
                      ),
                      child: done
                          ? const Icon(
                              Icons.check,
                              size: 15,
                              color: Colors.white,
                            )
                          : Text(
                              '$i',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: current
                                    ? Colors.white
                                    : _rt_Lab.textMuted,
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_tx.s('exploration')} $i: ${step['concept']}',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w900,
                          color: _rt_Lab.text,
                        ),
                      ),
                    ),
                    Icon(
                      open ? Icons.expand_less : Icons.expand_more,
                      size: 18,
                      color: _rt_Lab.textMuted,
                    ),
                  ],
                ),
                if (open) ...[
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: '${_tx.s('conceptFocus')}: ',
                          style: tag,
                        ),
                        TextSpan(text: '${step['concept']}', style: line),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: '${_tx.s('action')}: ', style: tag),
                        TextSpan(text: '${step['action']}', style: line),
                      ],
                    ),
                  ),
                  if (done) ...[
                    const SizedBox(height: 3),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${_tx.s('observation')}: ',
                            style: tag,
                          ),
                          TextSpan(text: '${step['observation']}', style: line),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------- painters --

/// S2 connector lines: dashed, green (correct) or red (wrong), plus the
/// line being drawn. The return trip Pharmacy -> Mother bows to the right
/// around the Doctor node.
class _PathwayPainter extends CustomPainter {
  _PathwayPainter({
    required this.edges,
    required this.preview,
    required this.nodeRadius,
  });

  final List<(Offset, Offset, bool, bool)> edges;
  final (Offset, Offset)? preview;
  final double nodeRadius;

  void _dashed(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 20) {
        canvas.drawPath(metric.extractPath(d, d + 12), paint);
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final (a, b, ok, curved) in edges) {
      final paint = Paint()
        ..color = ok ? const Color(0xFF22C55E) : const Color(0xFFEF4444)
        ..strokeWidth = 5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      final path = Path();
      if (curved) {
        final start = a + Offset(nodeRadius, 0);
        final end = b + Offset(nodeRadius, 0);
        path
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(
            start.dx + size.width * 0.3,
            (start.dy + end.dy) / 2,
            end.dx,
            end.dy,
          );
      } else {
        final dir = (b - a) / (b - a).distance;
        final start = a + dir * nodeRadius;
        final end = b - dir * nodeRadius;
        path
          ..moveTo(start.dx, start.dy)
          ..lineTo(end.dx, end.dy);
      }
      _dashed(canvas, path, paint);
      // Arrow head at the end of the path.
      final metric = path.computeMetrics().last;
      final tip = metric.getTangentForOffset(metric.length);
      if (tip != null) {
        final back = -tip.vector;
        final side = Offset(-back.dy, back.dx);
        canvas.drawPath(
          Path()
            ..moveTo(tip.position.dx, tip.position.dy)
            ..lineTo(
              tip.position.dx + back.dx * 14 + side.dx * 8,
              tip.position.dy + back.dy * 14 + side.dy * 8,
            )
            ..lineTo(
              tip.position.dx + back.dx * 14 - side.dx * 8,
              tip.position.dy + back.dy * 14 - side.dy * 8,
            )
            ..close(),
          Paint()..color = paint.color,
        );
      }
    }
    final p = preview;
    if (p != null) {
      _dashed(
        canvas,
        Path()
          ..moveTo(p.$1.dx, p.$1.dy)
          ..lineTo(p.$2.dx, p.$2.dy),
        Paint()
          ..color = const Color(0xFF06B6D4)
          ..strokeWidth = 5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PathwayPainter oldDelegate) => true;
}

/// Three rod-shaped bacteria (the alarmed medicine cabinet).
class _BacteriaIconPainter extends CustomPainter {
  const _BacteriaIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 20;
    final paint = Paint()..color = const Color(0xFFF472B6);
    for (final (x, y, a) in const [
      (6.0, 6.0, 0.5),
      (13.0, 9.0, -0.4),
      (8.0, 14.0, 0.1),
    ]) {
      canvas
        ..save()
        ..translate(x * s, y * s)
        ..rotate(a)
        ..drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset.zero, width: 9 * s, height: 3.6 * s),
            Radius.circular(1.8 * s),
          ),
          paint,
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Dashed drop-target outline (rounded box or circle).
class _DashedPainter extends CustomPainter {
  _DashedPainter(this.color, {this.round = false, this.fill = false});

  final Color color;
  final bool round;
  final bool fill;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = round
        ? (Path()..addOval(rect.deflate(1.5)))
        : (Path()..addRRect(
            RRect.fromRectAndRadius(
              rect.deflate(1.5),
              const Radius.circular(10),
            ),
          ));
    canvas.drawPath(
      shape,
      Paint()..color = color.withValues(alpha: fill ? 0.28 : 0.1),
    );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (final metric in shape.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 12) {
        canvas.drawPath(metric.extractPath(d, d + 7), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.fill != fill;
}

/// One `confetti({particleCount: 150, spread: 70})` burst.
class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress, this.pieces) : super(repaint: progress);

  final ValueNotifier<double> progress;
  final List<_ConfettiPiece> pieces;

  @override
  void paint(Canvas canvas, Size size) {
    final t = progress.value;
    if (t <= 0 || t >= 1) return;
    final seconds = t * 2.2;
    final origin = Offset(size.width / 2, size.height * 0.6);
    const drag = 2.2;
    final travel = (1 - math.exp(-drag * seconds)) / drag;
    final opacity = (1 - t * t).clamp(0.0, 1.0);
    for (final piece in pieces) {
      final x = origin.dx + math.cos(piece.angle) * piece.speed * travel;
      final y =
          origin.dy +
          math.sin(piece.angle) * piece.speed * travel +
          240 * seconds * seconds;
      canvas
        ..save()
        ..translate(x, y)
        ..rotate(piece.spin * seconds)
        ..drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.6,
          ),
          Paint()..color = piece.color.withValues(alpha: opacity),
        )
        ..restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.pieces != pieces;
}
