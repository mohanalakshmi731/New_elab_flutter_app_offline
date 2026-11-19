// Imported from new-elab-app-8; Class 8 local activity.
// ignore_for_file: type=lint
// ignore_for_file: camel_case_types, constant_identifier_names, no_leading_underscores_for_local_identifiers, non_constant_identifier_names, unnecessary_import, unused_element, unused_element_parameter, unused_field, unused_import, duplicate_ignore
// Class 8, Activity 14.1: Habitat Components and Ecosystems
// Converted from Cl8S-Ch14-A1-habitat-components-and-ecosystems.html
// (three.js r128 + tween.js -> mini3d).
//
// Five scenarios picked from the sidebar, each opened by a chalkboard:
// (1) sort a pond's components into Biotic and Abiotic bins; (2) identify
// six components of a forest; (3) link the parts of a landscape to show
// how they interact; (4) fill Table 12.1 for a large tree and a pond;
// (5) scan a park and a roadside, compare their shares of living things
// and answer Exercise Q7. Every 3D action also has a sidebar or panel
// button, and each finished scenario shows its summary with "Next
// Scenario".
//
// SOURCE BUG FIXES:
// * Re-entering a scenario was a dead end (stale counters; scenario 5
//   could not be replayed) and pending timers and tweens ran on;
//   scenarios are rebuilt cleanly and every timer is cancelled. The scan
//   could run twice; links could be counted twice or out of order.
// * Scenario 2's lens followed a hovering mouse (not on touch screens) and
//   its step 3 was never reached; targets are tapped and classified in an
//   inventory panel, in one step. A drop outside a bin raised an error and
//   drags could stick; drops snap back with an explanation of where the
//   item belongs. Scenario 4 did not enforce 2 + 2 items per habitat.
// * Overlay positions drifted, labels overlapped, the correct-link line
//   was black, the squirrel was buried in the tree and the label toggle
//   was lost; the toolbar's pan blocked drags; the camera is clamped and
//   framed per step for phones. The summary's close left an empty screen;
//   each scenario ends with Next Scenario / Restart, and Restart keeps the
//   language. Hindi summaries, HUDs and observations were abridged (and
//   scenario 5 dropped its thresholds); the Hindi is complete.
//
// CONTENT FIXES (approved by the user):
// * S1: the item names match the HUD (Water, Mud (soil), Oxygen
//   (dissolved)). S2: sunlight and temperature are "non-living physical
//   factors", not "invisible", and temperature is a thermometer.
// * S3: a real link made in the wrong step gets a neutral hint (not
//   "wrong"); the node is "Trees" (not "Forest (Biotic)"); "the water they
//   need" (not "for hydration"); the summary includes the Sun.
// * S4: the tree's living things are organisms (squirrel, bird, ants), not
//   its own bark and leaves; exactly 2 biotic + 2 abiotic per habitat.
// * S5: the shares of living things are measured from the scene's counts
//   and judged High / Low (not fixed slider thresholds); the park and the
//   roadside differ in living things vs human-made objects (not
//   "artificial abiotic").
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
    'appTitle': 'Habitat Components and Ecosystems',
    'appSubtitle': 'Class 8. How Nature Works in Harmony',
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
    'restartLab': 'Restart Virtual Lab', // added
    'scComplete': 'Scenario {n} Complete!',
    'labComplete': 'All Scenarios Complete!', // added
    'scenarioDoneHud':
        'Scenario {n} complete! Go on to the next scenario.', // added
    'labDoneHud': 'All scenarios complete! Restart the lab any time.', // added
    'labControls': 'Lab Controls', // added
    'controlsHint':
        'Drag or tap the objects in the 3D view, or use these buttons.', // added
    'ttLabels': 'Toggle labels', // added
    'ttLock': 'Lock / unlock camera', // added
    'incorrect': 'Incorrect! Try again.',
    'lbl': {
      // Scenario 1 (content fix: names match the HUD).
      'fish': 'Fish',
      'frog': 'Frog',
      'turtle': 'Turtle',
      'lotus': 'Lotus',
      'algae': 'Algae',
      'water': 'Water',
      'mud': 'Mud (soil)',
      'oxygen': 'Oxygen (dissolved)',
      'binBiotic': 'Biotic (living)',
      'binAbiotic': 'Abiotic (non-living)',
      // Scenario 2.
      'pine': 'Pine tree',
      'bird': 'Bird',
      'grass': 'Tall grass',
      'sunlight': 'Sunlight',
      'temperature': 'Temperature',
      'soil': 'Soil',
      // Scenario 3 (content fix: "Trees", not "Forest (Biotic)").
      'mountains': 'Mountains',
      'river': 'River',
      'trees': 'Trees',
      'sun': 'Sun',
      'plants': 'Plants',
      // Scenario 4 (content fix: organisms, not bark and leaves).
      'squirrel': 'Squirrel',
      'ants': 'Ants',
      'air': 'Air',
      'lily': 'Water lily',
      'rocks': 'Rocks',
      'habTree': 'Habitat 1: Large tree',
      'habPond': 'Habitat 2: Pond',
      // Scenario 5.
      'park': 'Scene A: Park',
      'road': 'Scene B: Roadside',
    },
    // Lab-control twins (added).
    'twSort': 'Sort the next item',
    'twIdentify': 'Pick the next target',
    'twLink': 'Make the link',
    'twObserve': 'Observe the next item',
    // Scenario 1 (added: every wrong drop explains itself).
    'hint': {
      'fish': 'The fish is alive - it feeds, breathes and grows. It is biotic.',
      'frog': 'The frog is alive - it is biotic.',
      'turtle': 'The turtle is alive - it is biotic.',
      'lotus': 'The lotus is a living plant - it is biotic.',
      'algae': 'Algae are tiny living plant-like organisms - they are biotic.',
      'water': 'Water is not alive - it is abiotic.',
      'mud': 'Mud (soil) is not alive - it is abiotic.',
      'oxygen':
          'Oxygen dissolved in the water is a gas, not a living thing - it is abiotic.',
    },
    'fbDropBin': 'Drop the item into one of the two bins.',
    'fbSorted': 'Every component is in the right bin!',
    // Scenario 2.
    'invTitle': 'Forest Inventory',
    'pickTarget': 'Tap a glowing target in the forest.', // added
    'isIt': 'Is it biotic or abiotic?', // added
    'biotic': 'Biotic',
    'abiotic': 'Abiotic',
    'bioticList': 'Biotic (living):',
    'abioticList': 'Abiotic (non-living):',
    'why': {
      'pine':
          'Not quite. The pine tree is alive - it grows and makes its own food.',
      'bird': 'Not quite. The bird is a living animal.',
      'grass': 'Not quite. The grass is a living plant.',
      // Content fix: "non-living physical factors", not "invisible".
      'sunlight':
          'Not quite. Sunlight is a non-living physical factor - it gives energy but is not alive.',
      'temperature':
          'Not quite. Temperature (how hot or cold it is) is a non-living physical factor.',
      'soil': 'Not quite. Soil is non-living, though living things grow in it.',
    },
    'fbAdded': 'Correct - added to the inventory.', // added
    'fbForestDone': 'All six components are identified!', // added
    // Scenario 3.
    'linkTitle': 'Ecosystem Links', // added
    'linkHint':
        'Tap two components (or drag one onto the other) to link them.', // added
    'fbLinked': {
      'river-trees': 'Linked! The trees take up water from the river.',
      'plants-sun': 'Linked! Plants use sunlight to make their food.',
      'mountains-river':
          'Linked! Snow and rain on the mountains feed the river.',
    },
    // Content fix: real links are not marked wrong.
    'fbReal': 'That link is real too, but this step asks for {a} and {b}.',
    'fbAsk': 'Not this pair - this step asks for {a} and {b}.',
    // Scenario 4.
    'tableTitle': 'Table 12.1: Habitat Observations',
    'colBiotic': 'Biotic',
    'colAbiotic': 'Abiotic',
    'fbFull': {
      'biotic':
          'You already have 2 living things here - now find 2 non-living things.',
      'abiotic':
          'You already have 2 non-living things here - now find 2 living things.',
    },
    'fbTreeDone': 'The large tree is recorded.', // added
    'fbPondDone': 'Table 12.1 is complete!', // added
    // Scenario 5.
    'scanTitle': 'Environment Scanner', // added
    'scan': 'Scan Environments',
    'living': 'Living things',
    'made': 'Human-made objects',
    'share': 'Share of living things',
    'shareQ': 'Is the share of living things high or low?', // added
    'high': 'High',
    'low': 'Low',
    'check': 'Check',
    'fbScanned': 'Scan complete: every component is counted.', // added
    'fbPickAll': 'Choose High or Low for both scenes.', // added
    'fbShareWrong':
        'Not quite - compare the share of living things in each scene.', // added
    'fbShareOk':
        "Correct! The park's share of living things is high; the roadside's is low.", // added
    'mcqQ': 'How are the two places different?',
    // Content fix: living things vs human-made objects (the source said
    // the park had little "abiotic" and the road "artificial abiotic").
    'opt': {
      'a': 'They have the same components, just arranged differently.',
      'b':
          'The park has many living things; the roadside has few living things and many human-made objects.',
      'c': 'The roadside has more living things than the park.',
    },
    'whyOpt': {
      'a':
          'Not quite. Look at the counts: the two places have different components.',
      'c':
          'Not quite. Compare the numbers of living things the scanner counted.',
    },
    'fbMcqOk': 'Correct!', // added
    'scenarios': [
      {
        'title': 'Scenario 1: The Pond Habitat Classification',
        'objective':
            'Identify and sort the biotic and abiotic components of a pond habitat.',
        'board':
            'A habitat is a place where organisms live. Biotic components are living things. Abiotic components are non-living things.',
        'boardBtn': 'Setup Activity',
        'hud': [
          "Step 1: Read the objective, then click 'Setup Activity'.",
          'Step 2: Drag every item into the Biotic or the Abiotic bin.',
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': "Click 'Setup Activity'.",
            'observation':
                'In a pond, the biotic components include fish, frogs, turtles, lotus and algae; the abiotic components include water, mud (soil) and dissolved oxygen.',
          },
          {
            'concept': 'Sorting Components',
            'action': 'Drag each item into the Biotic or the Abiotic bin.',
            'observation':
                'The living and the non-living components are sorted into their bins.',
          },
        ],
        'summaryTitle': 'Habitat Classified!',
        'summary':
            'You separated the **living (biotic)** organisms from the **non-living (abiotic)** components they depend on: water, mud (soil) and dissolved oxygen.',
      },
      {
        'title': 'Scenario 2: The Forest Habitat Analysis',
        'objective':
            'Analyze a forest habitat by identifying its biotic and abiotic components.',
        'board':
            'Forests are dense habitats. The survival of the biotic components depends on abiotic factors such as sunlight, temperature and soil.',
        'boardBtn': 'Setup Activity',
        // The source's step 3 was never reached; it is part of step 2.
        'hud': [
          "Step 1: Read the objective, then click 'Setup Activity'.",
          'Step 2: Tap the 6 glowing targets one by one and say whether each is biotic or abiotic.',
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': "Click 'Setup Activity'.",
            'observation':
                'In a forest, the biotic components include trees, birds and grass; the abiotic components include sunlight, temperature and soil.',
          },
          {
            'concept': 'Classification',
            'action':
                'Tap each glowing target, then choose Biotic or Abiotic in the inventory.',
            'observation':
                'The inventory lists 3 biotic and 3 abiotic components of the forest.',
          },
        ],
        'summaryTitle': 'Analysis Complete!',
        // Content fix: "non-living physical factors", not "invisible".
        'summary':
            'You identified the **living organisms** of the forest and the **non-living physical factors** - sunlight, temperature and soil - that sustain them.',
      },
      {
        'title': 'Scenario 3: Ecosystem Interactions',
        'objective':
            'Draw connections to show how biotic and abiotic components interact.',
        'board':
            'An ecosystem is not just a list of things; it is the interaction between them. Living things depend on non-living things.',
        'boardBtn': 'Setup Activity',
        'hud': [
          "Step 1: Read the objective, then click 'Setup Activity'.",
          "Step 2: Link 'River' and 'Trees' to show that the trees need water.",
          "Step 3: Link 'Sun' and 'Plants' to show the flow of energy.",
          "Step 4: Link 'Mountains' and 'River' to show where the water comes from.",
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': "Click 'Setup Activity'.",
            'observation':
                'An ecosystem is formed by the interaction of the biotic and abiotic components of a habitat.',
          },
          {
            'concept': 'Water Interaction',
            'action': 'Link the river and the trees.',
            // Content fix: "the water they need" (was "for hydration").
            'observation':
                'The trees (biotic) depend on the river (abiotic) for the water they need.',
          },
          {
            'concept': 'Energy Interaction',
            'action': 'Link the Sun and the plants.',
            'observation':
                'The plants (biotic) depend on the Sun (abiotic) for the energy to make their food.',
          },
          {
            'concept': 'Geological Interaction',
            'action': 'Link the mountains and the river.',
            'observation':
                'Snow and rain on the mountains (abiotic) feed the river (abiotic), and the mountains shape its path.',
          },
        ],
        'summaryTitle': 'Ecosystem Mapped!',
        // Content fix: the Sun is included.
        'summary':
            'The **Sun** gives the plants and trees energy, the **mountains** feed the river, and the **river** gives the trees water. An ecosystem is the living and non-living components of a place **interacting with each other**.',
      },
      {
        'title': 'Scenario 4: Activity 12.1 - Observation',
        'objective':
            'Observe two habitats (a large tree and a pond) and fill Table 12.1.',
        'board':
            'We will simulate an outdoor observation. For each habitat, record 2 living and 2 non-living things in Table 12.1.',
        'boardBtn': 'Setup Activity',
        'hud': [
          "Step 1: Read the objective, then click 'Setup Activity'.",
          'Step 2: At the large tree, tap 2 biotic and 2 abiotic items to record them.',
          'Step 3: At the pond, tap 2 biotic and 2 abiotic items to record them.',
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': "Click 'Setup Activity'.",
            'observation':
                'Activity 12.1: identify two habitats and list the living and non-living things observed.',
          },
          {
            'concept': 'Observing a Large Tree',
            // Content fix: organisms on the tree (bark and leaves are parts
            // of the tree, not separate organisms).
            'action':
                'Tap 2 living things (squirrel, bird, ants) and 2 non-living things (soil, air).',
            'observation':
                'The items are recorded under the large tree in Table 12.1.',
          },
          {
            'concept': 'Observing a Pond',
            'action':
                'Tap 2 living things (fish, frog, water lily) and 2 non-living things (water, rocks).',
            'observation':
                'The items are recorded under the pond in Table 12.1.',
          },
        ],
        'summaryTitle': 'Table 12.1 Complete!',
        'summary':
            'You observed and recorded **living and non-living components** in two different habitats. Every habitat has both.',
      },
      {
        'title': 'Scenario 5: Exercise Q7 - Comparative Analysis',
        'objective':
            'Compare the living things and the human-made objects in a park and on a roadside.',
        'board':
            'Ecosystems vary with their components. We will scan a park and a roadside to see how they differ.',
        'boardBtn': 'Setup Activity',
        'hud': [
          "Step 1: Read the objective, then click 'Setup Activity'.",
          "Step 2: Click 'Scan Environments' to count the components in both scenes.",
          // Content fix: judged from the measured shares (the source used
          // fixed slider thresholds).
          'Step 3: For each scene, say whether the share of living things is high or low.',
          'Step 4: Answer the final question.',
        ],
        'steps': [
          {
            'concept': 'Theory & Setup',
            'action': "Click 'Setup Activity'.",
            'observation':
                'Exercise Q7: observe two different places. How are the two ecosystems different?',
          },
          {
            'concept': 'Scanning Components',
            'action': "Click 'Scan Environments'.",
            'observation':
                'The scanner counts many living things in the park, but mostly human-made objects on the roadside.',
          },
          {
            'concept': 'Comparing Shares',
            'action': 'Choose High or Low for each scene, then check.',
            'observation':
                'The park has a high share of living things; the roadside has a low share.',
          },
          {
            'concept': 'Conclusion',
            'action': 'Choose the correct answer.',
            'observation':
                'The park has many living things; the roadside has few living things and many human-made objects.',
          },
        ],
        'summaryTitle': 'Analysis Complete!',
        'summary':
            'The park is dominated by **living things** (trees, flowers, butterflies), while the roadside is dominated by **human-made objects** (road, poles, vehicles). Both places still have natural non-living components such as **air, soil, water and sunlight**.',
      },
    ],
  },
  'hi': {
    'appTitle': 'आवास के घटक और पारितंत्र',
    'appSubtitle': 'कक्षा 8. प्रकृति सामंजस्य में कैसे काम करती है',
    'enterLab': 'प्रयोगशाला में प्रवेश करें',
    'selectScenario': 'परिदृश्य चुनें',
    'missionObj': 'मिशन उद्देश्य',
    'conceptExp': 'अन्वेषण चरण',
    'currObj': 'वर्तमान कार्य',
    'exploration': 'चरण',
    'conceptFocus': 'मुख्य अवधारणा',
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
        '3D दृश्य में वस्तुओं को खींचें या टैप करें, या इन बटनों का उपयोग करें।',
    'ttLabels': 'लेबल दिखाएँ/छिपाएँ',
    'ttLock': 'कैमरा लॉक / अनलॉक',
    'incorrect': 'गलत! फिर से प्रयास करें।',
    'lbl': {
      'fish': 'मछली',
      'frog': 'मेंढक',
      'turtle': 'कछुआ',
      'lotus': 'कमल',
      'algae': 'शैवाल',
      'water': 'पानी',
      'mud': 'कीचड़ (मिट्टी)',
      'oxygen': 'ऑक्सीजन (घुली हुई)',
      'binBiotic': 'जैविक (सजीव)',
      'binAbiotic': 'अजैविक (निर्जीव)',
      'pine': 'चीड़ का पेड़',
      'bird': 'पक्षी',
      'grass': 'लंबी घास',
      'sunlight': 'सूर्य का प्रकाश',
      'temperature': 'तापमान',
      'soil': 'मिट्टी',
      'mountains': 'पहाड़',
      'river': 'नदी',
      'trees': 'पेड़',
      'sun': 'सूर्य',
      'plants': 'पौधे',
      'squirrel': 'गिलहरी',
      'ants': 'चींटियाँ',
      'air': 'हवा',
      'lily': 'कुमुदिनी',
      'rocks': 'चट्टानें',
      'habTree': 'आवास 1: बड़ा पेड़',
      'habPond': 'आवास 2: तालाब',
      'park': 'दृश्य A: पार्क',
      'road': 'दृश्य B: सड़क किनारा',
    },
    'twSort': 'अगली वस्तु छाँटें',
    'twIdentify': 'अगला लक्ष्य चुनें',
    'twLink': 'संबंध जोड़ें',
    'twObserve': 'अगली वस्तु देखें',
    'hint': {
      'fish': 'मछली सजीव है - वह खाती, साँस लेती और बढ़ती है। वह जैविक है।',
      'frog': 'मेंढक सजीव है - वह जैविक है।',
      'turtle': 'कछुआ सजीव है - वह जैविक है।',
      'lotus': 'कमल एक सजीव पौधा है - वह जैविक है।',
      'algae': 'शैवाल छोटे सजीव पौधे जैसे जीव हैं - वे जैविक हैं।',
      'water': 'पानी सजीव नहीं है - वह अजैविक है।',
      'mud': 'कीचड़ (मिट्टी) सजीव नहीं है - वह अजैविक है।',
      'oxygen': 'पानी में घुली ऑक्सीजन एक गैस है, सजीव नहीं - वह अजैविक है।',
    },
    'fbDropBin': 'वस्तु को दोनों में से किसी एक डिब्बे में छोड़ें।',
    'fbSorted': 'हर घटक सही डिब्बे में है!',
    'invTitle': 'वन सूची',
    'pickTarget': 'वन में किसी चमकते लक्ष्य पर टैप करें।',
    'isIt': 'यह जैविक है या अजैविक?',
    'biotic': 'जैविक',
    'abiotic': 'अजैविक',
    'bioticList': 'जैविक (सजीव):',
    'abioticList': 'अजैविक (निर्जीव):',
    'why': {
      'pine':
          'पूरी तरह सही नहीं। चीड़ का पेड़ सजीव है - वह बढ़ता है और अपना भोजन बनाता है।',
      'bird': 'पूरी तरह सही नहीं। पक्षी एक सजीव प्राणी है।',
      'grass': 'पूरी तरह सही नहीं। घास एक सजीव पौधा है।',
      'sunlight':
          'पूरी तरह सही नहीं। सूर्य का प्रकाश एक निर्जीव भौतिक कारक है - वह ऊर्जा देता है पर सजीव नहीं है।',
      'temperature':
          'पूरी तरह सही नहीं। तापमान (कितना गर्म या ठंडा है) एक निर्जीव भौतिक कारक है।',
      'soil':
          'पूरी तरह सही नहीं। मिट्टी निर्जीव है, भले ही उसमें सजीव उगते हैं।',
    },
    'fbAdded': 'सही - सूची में जोड़ा गया।',
    'fbForestDone': 'सभी छह घटक पहचान लिए गए!',
    'linkTitle': 'पारितंत्र के संबंध',
    'linkHint':
        'दो घटकों पर टैप करें (या एक को दूसरे पर खींचें) ताकि वे जुड़ जाएँ।',
    'fbLinked': {
      'river-trees': 'जुड़ गया! पेड़ नदी से पानी लेते हैं।',
      'plants-sun':
          'जुड़ गया! पौधे भोजन बनाने के लिए सूर्य के प्रकाश का उपयोग करते हैं।',
      'mountains-river': 'जुड़ गया! पहाड़ों पर बर्फ और बारिश से नदी बनती है।',
    },
    'fbReal': 'यह संबंध भी सही है, पर इस चरण में {a} और {b} को जोड़ना है।',
    'fbAsk': 'यह जोड़ी नहीं - इस चरण में {a} और {b} को जोड़ना है।',
    'tableTitle': 'तालिका 12.1: आवास के अवलोकन',
    'colBiotic': 'जैविक',
    'colAbiotic': 'अजैविक',
    'fbFull': {
      'biotic': 'यहाँ 2 सजीव पहले से हैं - अब 2 निर्जीव चीज़ें खोजें।',
      'abiotic': 'यहाँ 2 निर्जीव चीज़ें पहले से हैं - अब 2 सजीव खोजें।',
    },
    'fbTreeDone': 'बड़ा पेड़ दर्ज हो गया।',
    'fbPondDone': 'तालिका 12.1 पूरी हो गई!',
    'scanTitle': 'पर्यावरण स्कैनर',
    'scan': 'पर्यावरण स्कैन करें',
    'living': 'सजीव',
    'made': 'मानव-निर्मित वस्तुएँ',
    'share': 'सजीवों का हिस्सा',
    'shareQ': 'सजीवों का हिस्सा अधिक है या कम?',
    'high': 'अधिक',
    'low': 'कम',
    'check': 'जाँचें',
    'fbScanned': 'स्कैन पूरा: हर घटक गिना गया।',
    'fbPickAll': 'दोनों दृश्यों के लिए अधिक या कम चुनें।',
    'fbShareWrong':
        'पूरी तरह सही नहीं - हर दृश्य में सजीवों के हिस्से की तुलना करें।',
    'fbShareOk': 'सही! पार्क में सजीवों का हिस्सा अधिक है; सड़क किनारे कम है।',
    'mcqQ': 'दोनों स्थान कैसे अलग हैं?',
    'opt': {
      'a': 'उनके घटक एक जैसे हैं, बस अलग ढंग से रखे हैं।',
      'b':
          'पार्क में बहुत से सजीव हैं; सड़क किनारे कम सजीव और बहुत सी मानव-निर्मित वस्तुएँ हैं।',
      'c': 'सड़क किनारे पार्क से अधिक सजीव हैं।',
    },
    'whyOpt': {
      'a': 'पूरी तरह सही नहीं। गिनती देखें: दोनों स्थानों के घटक अलग हैं।',
      'c':
          'पूरी तरह सही नहीं। स्कैनर द्वारा गिने गए सजीवों की संख्या की तुलना करें।',
    },
    'fbMcqOk': 'सही!',
    'scenarios': [
      {
        'title': 'परिदृश्य 1: तालाब आवास का वर्गीकरण',
        'objective':
            'तालाब आवास के जैविक और अजैविक घटकों को पहचानें और छाँटें।',
        'board':
            'आवास वह स्थान है जहाँ जीव रहते हैं। जैविक घटक सजीव होते हैं। अजैविक घटक निर्जीव होते हैं।',
        'boardBtn': 'गतिविधि सेट करें',
        'hud': [
          "चरण 1: उद्देश्य पढ़ें, फिर 'गतिविधि सेट करें' पर क्लिक करें।",
          'चरण 2: हर वस्तु को जैविक या अजैविक डिब्बे में खींचें।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और सेटअप',
            'action': "'गतिविधि सेट करें' पर क्लिक करें।",
            'observation':
                'तालाब में जैविक घटकों में मछली, मेंढक, कछुए, कमल और शैवाल शामिल हैं; अजैविक घटकों में पानी, कीचड़ (मिट्टी) और घुली हुई ऑक्सीजन शामिल हैं।',
          },
          {
            'concept': 'घटकों को छाँटना',
            'action': 'हर वस्तु को जैविक या अजैविक डिब्बे में खींचें।',
            'observation': 'सजीव और निर्जीव घटक अपने-अपने डिब्बों में छँट गए।',
          },
        ],
        'summaryTitle': 'आवास का वर्गीकरण हुआ!',
        'summary':
            'आपने **सजीव (जैविक)** जीवों को उन **निर्जीव (अजैविक)** घटकों से अलग किया जिन पर वे निर्भर हैं: पानी, कीचड़ (मिट्टी) और घुली हुई ऑक्सीजन।',
      },
      {
        'title': 'परिदृश्य 2: वन आवास का विश्लेषण',
        'objective':
            'वन आवास के जैविक और अजैविक घटकों को पहचानकर उसका विश्लेषण करें।',
        'board':
            'वन घने आवास हैं। जैविक घटकों का जीवन सूर्य के प्रकाश, तापमान और मिट्टी जैसे अजैविक कारकों पर निर्भर करता है।',
        'boardBtn': 'गतिविधि सेट करें',
        'hud': [
          "चरण 1: उद्देश्य पढ़ें, फिर 'गतिविधि सेट करें' पर क्लिक करें।",
          'चरण 2: 6 चमकते लक्ष्यों पर एक-एक करके टैप करें और बताएँ कि हर एक जैविक है या अजैविक।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और सेटअप',
            'action': "'गतिविधि सेट करें' पर क्लिक करें।",
            'observation':
                'वन में जैविक घटकों में पेड़, पक्षी और घास शामिल हैं; अजैविक घटकों में सूर्य का प्रकाश, तापमान और मिट्टी शामिल हैं।',
          },
          {
            'concept': 'वर्गीकरण',
            'action':
                'हर चमकते लक्ष्य पर टैप करें, फिर सूची में जैविक या अजैविक चुनें।',
            'observation': 'सूची में वन के 3 जैविक और 3 अजैविक घटक हैं।',
          },
        ],
        'summaryTitle': 'विश्लेषण पूरा!',
        'summary':
            'आपने वन के **सजीव जीवों** और उन्हें बनाए रखने वाले **निर्जीव भौतिक कारकों** - सूर्य का प्रकाश, तापमान और मिट्टी - को पहचाना।',
      },
      {
        'title': 'परिदृश्य 3: पारितंत्र में परस्पर क्रिया',
        'objective':
            'जैविक और अजैविक घटकों की परस्पर क्रिया दिखाने के लिए संबंध बनाएँ।',
        'board':
            'पारितंत्र केवल चीज़ों की सूची नहीं है; यह उनके बीच की परस्पर क्रिया है। सजीव निर्जीव चीज़ों पर निर्भर करते हैं।',
        'boardBtn': 'गतिविधि सेट करें',
        'hud': [
          "चरण 1: उद्देश्य पढ़ें, फिर 'गतिविधि सेट करें' पर क्लिक करें।",
          "चरण 2: 'नदी' और 'पेड़' को जोड़ें ताकि दिखे कि पेड़ों को पानी चाहिए।",
          "चरण 3: ऊर्जा का प्रवाह दिखाने के लिए 'सूर्य' और 'पौधे' को जोड़ें।",
          "चरण 4: पानी कहाँ से आता है यह दिखाने के लिए 'पहाड़' और 'नदी' को जोड़ें।",
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और सेटअप',
            'action': "'गतिविधि सेट करें' पर क्लिक करें।",
            'observation':
                'किसी आवास के जैविक और अजैविक घटकों की परस्पर क्रिया से पारितंत्र बनता है।',
          },
          {
            'concept': 'जल की परस्पर क्रिया',
            'action': 'नदी और पेड़ों को जोड़ें।',
            'observation':
                'पेड़ (जैविक) अपनी ज़रूरत के पानी के लिए नदी (अजैविक) पर निर्भर हैं।',
          },
          {
            'concept': 'ऊर्जा की परस्पर क्रिया',
            'action': 'सूर्य और पौधों को जोड़ें।',
            'observation':
                'पौधे (जैविक) अपना भोजन बनाने की ऊर्जा के लिए सूर्य (अजैविक) पर निर्भर हैं।',
          },
          {
            'concept': 'भूवैज्ञानिक परस्पर क्रिया',
            'action': 'पहाड़ों और नदी को जोड़ें।',
            'observation':
                'पहाड़ों (अजैविक) पर बर्फ और बारिश से नदी (अजैविक) बनती है, और पहाड़ उसका रास्ता तय करते हैं।',
          },
        ],
        'summaryTitle': 'पारितंत्र का नक्शा बना!',
        'summary':
            '**सूर्य** पौधों और पेड़ों को ऊर्जा देता है, **पहाड़** नदी को पानी देते हैं, और **नदी** पेड़ों को पानी देती है। पारितंत्र किसी स्थान के सजीव और निर्जीव घटकों की **आपसी परस्पर क्रिया** है।',
      },
      {
        'title': 'परिदृश्य 4: क्रियाकलाप 12.1 - अवलोकन',
        'objective':
            'दो आवासों (एक बड़ा पेड़ और एक तालाब) का अवलोकन करें और तालिका 12.1 भरें।',
        'board':
            'हम बाहर के एक अवलोकन का अनुकरण करेंगे। हर आवास के लिए तालिका 12.1 में 2 सजीव और 2 निर्जीव चीज़ें दर्ज करें।',
        'boardBtn': 'गतिविधि सेट करें',
        'hud': [
          "चरण 1: उद्देश्य पढ़ें, फिर 'गतिविधि सेट करें' पर क्लिक करें।",
          'चरण 2: बड़े पेड़ पर 2 जैविक और 2 अजैविक वस्तुओं पर टैप करके उन्हें दर्ज करें।',
          'चरण 3: तालाब पर 2 जैविक और 2 अजैविक वस्तुओं पर टैप करके उन्हें दर्ज करें।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और सेटअप',
            'action': "'गतिविधि सेट करें' पर क्लिक करें।",
            'observation':
                'क्रियाकलाप 12.1: दो आवास पहचानें और उनमें देखी गई सजीव और निर्जीव चीज़ों की सूची बनाएँ।',
          },
          {
            'concept': 'बड़े पेड़ का अवलोकन',
            'action':
                '2 सजीव (गिलहरी, पक्षी, चींटियाँ) और 2 निर्जीव (मिट्टी, हवा) चीज़ों पर टैप करें।',
            'observation':
                'वस्तुएँ तालिका 12.1 में बड़े पेड़ के नीचे दर्ज हो जाती हैं।',
          },
          {
            'concept': 'तालाब का अवलोकन',
            'action':
                '2 सजीव (मछली, मेंढक, कुमुदिनी) और 2 निर्जीव (पानी, चट्टानें) चीज़ों पर टैप करें।',
            'observation':
                'वस्तुएँ तालिका 12.1 में तालाब के नीचे दर्ज हो जाती हैं।',
          },
        ],
        'summaryTitle': 'तालिका 12.1 पूरी!',
        'summary':
            'आपने दो अलग-अलग आवासों में **सजीव और निर्जीव घटकों** का अवलोकन करके उन्हें दर्ज किया। हर आवास में दोनों होते हैं।',
      },
      {
        'title': 'परिदृश्य 5: अभ्यास प्रश्न 7 - तुलनात्मक विश्लेषण',
        'objective':
            'पार्क और सड़क किनारे के सजीवों और मानव-निर्मित वस्तुओं की तुलना करें।',
        'board':
            'पारितंत्र अपने घटकों के अनुसार अलग-अलग होते हैं। हम एक पार्क और एक सड़क किनारे को स्कैन करके देखेंगे कि वे कैसे अलग हैं।',
        'boardBtn': 'गतिविधि सेट करें',
        'hud': [
          "चरण 1: उद्देश्य पढ़ें, फिर 'गतिविधि सेट करें' पर क्लिक करें।",
          "चरण 2: दोनों दृश्यों के घटक गिनने के लिए 'पर्यावरण स्कैन करें' पर क्लिक करें।",
          'चरण 3: हर दृश्य के लिए बताएँ कि सजीवों का हिस्सा अधिक है या कम।',
          'चरण 4: अंतिम प्रश्न का उत्तर दें।',
        ],
        'steps': [
          {
            'concept': 'सिद्धांत और सेटअप',
            'action': "'गतिविधि सेट करें' पर क्लिक करें।",
            'observation':
                'अभ्यास प्रश्न 7: दो अलग-अलग स्थानों का अवलोकन करें। दोनों पारितंत्र कैसे अलग हैं?',
          },
          {
            'concept': 'घटकों की स्कैनिंग',
            'action': "'पर्यावरण स्कैन करें' पर क्लिक करें।",
            'observation':
                'स्कैनर पार्क में बहुत से सजीव गिनता है, पर सड़क किनारे ज़्यादातर मानव-निर्मित वस्तुएँ।',
          },
          {
            'concept': 'हिस्सों की तुलना',
            'action': 'हर दृश्य के लिए अधिक या कम चुनें, फिर जाँचें।',
            'observation':
                'पार्क में सजीवों का हिस्सा अधिक है; सड़क किनारे कम है।',
          },
          {
            'concept': 'निष्कर्ष',
            'action': 'सही उत्तर चुनें।',
            'observation':
                'पार्क में बहुत से सजीव हैं; सड़क किनारे कम सजीव और बहुत सी मानव-निर्मित वस्तुएँ हैं।',
          },
        ],
        'summaryTitle': 'विश्लेषण पूरा!',
        'summary':
            'पार्क में **सजीवों** (पेड़, फूल, तितलियाँ) की अधिकता है, जबकि सड़क किनारे **मानव-निर्मित वस्तुओं** (सड़क, खंभे, वाहन) की। दोनों स्थानों पर **हवा, मिट्टी, पानी और सूर्य का प्रकाश** जैसे प्राकृतिक निर्जीव घटक भी हैं।',
      },
    ],
  },
});

// ------------------------------------------------------------------ model --

const Color _accent = _rt_Tw.cyan600;
const Color _accentSoft = Color(0xFF67E8F9); // cyan-300

/// Steps per scenario (step 1 is always the chalkboard).
const List<int> _stepCounts = [2, 2, 4, 3, 4];

/// Every living component used in the lab (the rest are abiotic).
const Set<String> _biotic = {
  'fish', 'frog', 'turtle', 'lotus', 'algae', //
  'pine', 'bird', 'grass', 'squirrel', 'ants', 'lily',
};

// --- Scenario 1: pond items and the two bins ---
const List<String> _pondItems = [
  'fish', 'frog', 'turtle', 'lotus', //
  'algae', 'water', 'mud', 'oxygen',
];
const Map<String, (double, double, double)> _pondHome = {
  'fish': (-2.6, -0.35, 0.6),
  'lotus': (2.4, 0.05, -2.0),
  'algae': (-1.2, 0.05, -2.6),
  'oxygen': (1.2, 0.0, 1.0),
  'frog': (-5.4, 0.0, 3.6),
  'turtle': (4.6, 0.0, 3.8),
  'mud': (-2.4, 0.0, 5.2),
  'water': (1.4, 0.0, 5.0),
};
double _binX(String bin) => bin == 'biotic' ? -9.6 : 9.6;

// --- Scenario 2: forest targets ---
const List<String> _forestTargets = [
  'pine', 'bird', 'grass', //
  'sunlight', 'temperature', 'soil',
];
const Map<String, (double, double, double)> _targetSpot = {
  'pine': (-5.0, 3.0, -1.5),
  'bird': (3.5, 5.6, -2.0),
  'grass': (2.6, 0.7, 3.0),
  'sunlight': (-8.5, 9.5, -9.0),
  'temperature': (7.0, 1.4, 0.8),
  'soil': (-1.2, 0.2, 3.6),
};

// --- Scenario 3: landscape nodes and the links asked for ---
const List<String> _nodes3 = ['mountains', 'sun', 'trees', 'river', 'plants'];
const List<String> _asked = ['river-trees', 'plants-sun', 'mountains-river'];

/// Links that are real but not asked for in the current step (content
/// fix: they get a neutral hint, not "wrong").
const Set<String> _realLinks = {
  'river-trees',
  'plants-sun',
  'mountains-river',
  'sun-trees',
  'plants-river',
};

/// Where each link's arrow starts and ends (food, water or energy flow).
const Map<String, (String, String)> _flow3 = {
  'river-trees': ('river', 'trees'),
  'plants-sun': ('sun', 'plants'),
  'mountains-river': ('mountains', 'river'),
};
const Map<String, (double, double, double)> _anchor3 = {
  'mountains': (-3.0, 5.4, -7.5),
  'sun': (9.0, 8.4, -6.0),
  'trees': (-7.4, 4.4, 1.0),
  'river': (0.6, 0.4, 1.6),
  'plants': (7.0, 1.6, 1.6),
};

String _pairKey(String a, String b) => a.compareTo(b) < 0 ? '$a-$b' : '$b-$a';

// --- Scenario 4: the two habitats ---
const List<String> _treeItems = ['squirrel', 'bird', 'ants', 'soil', 'air'];
const List<String> _pondItems4 = ['fish', 'frog', 'lily', 'water', 'rocks'];

// --- Scenario 5: the two scenes (answers: park High, roadside Low) ---
const Map<String, String> _shareAnswers = {'park': 'high', 'road': 'low'};

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
        Color(0xFF22C55E),
        Color(0xFF84CC16),
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

class Cl8Ch14A1HabitatComponentsEcosystemsPage extends StatefulWidget {
  const Cl8Ch14A1HabitatComponentsEcosystemsPage({super.key});

  @override
  State<Cl8Ch14A1HabitatComponentsEcosystemsPage> createState() =>
      _Cl8Ch14A1HabitatComponentsEcosystemsPageState();
}

class _Cl8Ch14A1HabitatComponentsEcosystemsPageState
    extends State<Cl8Ch14A1HabitatComponentsEcosystemsPage> {
  // --- 3D ENGINE ---
  final _rt_Scene3D _scene = _rt_Scene3D(
    backgroundGradient: const [Color(0xFF0B2530), Color(0xFF020617)],
  );
  final _rt_Camera3D _camera = _rt_Camera3D(
    fov: 45,
    position: _rt_V3(0, 8.5, 25.5),
    target: _rt_V3(0, 0, 0),
  );
  final _rt_Scene3DController _viewCtrl = _rt_Scene3DController();
  final _rt_ShellController _shell = _rt_ShellController();
  final _rt_TweenRunner _tweens = _rt_TweenRunner(resumeOnCancel: false);
  math.Random _rng = math.Random(141);
  final _rt_Node3D _root = _rt_Node3D(name: 'scenario-root');
  final ValueNotifier<int> _frameTick = ValueNotifier(0);
  final ValueNotifier<double> _confettiT = ValueNotifier(0);
  final List<_rt_Label3D> _labels = [];

  // Scenario objects (rebuilt on every scenario change). Draggable objects
  // are kept by id in [_objects]; tappable ones in [_tapNodes].
  final Map<String, _rt_Node3D> _objects = {};
  final Map<String, _rt_Node3D> _tapNodes = {};
  final Map<String, _rt_Node3D> _rings = {}; // S2 target glows
  final Map<String, _rt_Material3D> _ringMats = {};
  final Map<String, _rt_Node3D> _linkArrows = {}; // S3
  final List<_rt_Node3D> _flappers = []; // wings that flap
  final List<_rt_Node3D> _fliers = []; // birds / butterflies that circle
  _rt_Node3D? _beam; // S5 scanner
  final Map<String, (int, int)> _counts = {}; // S5: (living, human-made)

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

  final Map<String, List<String>> _bins = {'biotic': [], 'abiotic': []};
  String? _target; // S2: the target being classified
  bool _targetWrong = false;
  final List<String> _identified = [];
  final Set<String> _links = {}; // S3
  final Map<String, List<String>> _observed = {'tree': [], 'pond': []};
  bool _scanned = false; // S5
  final Map<String, String> _shares = {};
  final Set<String> _shareWrong = {};
  bool _sharesDone = false;
  String? _mcq;
  bool _mcqDone = false;
  String? _selectedChip; // S3: the component picked first
  String? _wrongZone;

  // 3D drag (on the vertical plane through the bins, facing the camera).
  String? _dragId;
  _rt_V3? _planePoint;
  _rt_V3? _planeNormal;
  Offset _grabOffset = Offset.zero;
  double _dragTravel = 0;
  Offset? _lastPointer;

  bool get _panelMode => false;

  String get _habitat => _step == 2 ? 'tree' : 'pond';

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _camera
      ..minDistance = 8
      ..maxDistance = 80
      ..maxPolarAngle = math.pi * 0.47;
    _scene.setLights([
      _rt_Light3D.ambient(intensity: 0.75),
      _rt_Light3D.directional(_rt_V3(10, 20, 10), intensity: 0.85),
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

  /// A label whose text follows the language ([tkey] is a translation
  /// path; the 3D labels live under `lbl.`).
  _rt_Label3D _label(String key, double x, double y, double z) {
    final path = 'lbl.$key';
    final label =
        _rt_Label3D(
            _tx.s(path),
            position: _rt_V3(x, y, z),
            pixelHeight: 12,
            color: Colors.white,
            background: const Color(0xD90F172A),
            borderColor: const Color(0xFF22C55E),
          )
          ..pickable = false
          ..visible = _labelsOn;
    label.userData['key'] = key;
    label.userData['tkey'] = path;
    _labels.add(label);
    return label;
  }

  /// A number readout (no translation).
  _rt_Label3D _rawLabel(double x, double y, double z) {
    final label = _rt_Label3D(
      '',
      position: _rt_V3(x, y, z),
      pixelHeight: 12,
      color: Colors.white,
      background: const Color(0xE614532D),
      borderColor: _accentSoft,
    )..pickable = false;
    _labels.add(label);
    return label;
  }

  /// Applies the labels toggle and language (labels marked hidden stay
  /// hidden).
  void _syncLabels() {
    for (final l in _labels) {
      final path = l.userData['tkey'];
      if (path is String) l.text = _tx.s(path);
      l.visible = _labelsOn && l.userData['hidden'] != true;
    }
  }

  void _showLabel(_rt_Label3D? l, bool show) {
    if (l == null) return;
    l.userData['hidden'] = !show;
    l.visible = _labelsOn && show;
  }

  _rt_Label3D _hiddenLabel(String key, double x, double y, double z) =>
      _label(key, x, y, z)..userData['hidden'] = true;

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

  /// A pause that ends early (never completes) when the scenario changes.
  Future<void> _pause(int ms) => _tweens.run(ms, (_) {});

  // ------------------------------------------------------------ models ---
  _rt_V3 _v((double, double, double) p) => _rt_V3(p.$1, p.$2, p.$3);

  _rt_Node3D _frogModel() {
    const skin = Color(0xFF16A34A);
    final n = _rt_Node3D(name: 'frog')
      ..add(
        _mesh(
            _rt_Geometry3D.sphere(0.42, widthSegments: 12, heightSegments: 8),
            skin,
          )
          ..position.y = 0.26
          ..scale.set(1.25, 0.62, 1.0),
      );
    for (final side in const [-1.0, 1.0]) {
      n
        ..add(
          _mesh(
              _rt_Geometry3D.sphere(0.22, widthSegments: 8, heightSegments: 5),
              const Color(0xFF15803D),
            )
            ..position.set(-0.3, 0.12, 0.34 * side)
            ..scale.set(1.4, 0.5, 0.8),
        )
        ..add(_ball(0.11, Colors.white)..position.set(0.3, 0.5, 0.17 * side))
        ..add(
          _ball(0.055, const Color(0xFF111827))
            ..position.set(0.38, 0.53, 0.19 * side),
        );
    }
    return n;
  }

  _rt_Node3D _fishModel() {
    const skin = Color(0xFFF97316);
    return _rt_Node3D(name: 'fish')
      ..add(
        _mesh(
          _rt_Geometry3D.sphere(0.3, widthSegments: 10, heightSegments: 6),
          skin,
        )..scale.set(1.7, 0.65, 0.6),
      )
      ..add(
        _mesh(_rt_Geometry3D.cone(0.24, 0.42, segments: 4), skin)
          ..position.x = -0.62
          ..rotation.z = math.pi / 2,
      )
      ..add(
        _ball(0.05, const Color(0xFF111827))..position.set(0.36, 0.06, 0.12),
      );
  }

  _rt_Node3D _turtleModel() {
    final n = _rt_Node3D(name: 'turtle')
      ..add(
        _mesh(
            _rt_Geometry3D.sphere(
              0.6,
              widthSegments: 12,
              heightSegments: 6,
              thetaLength: math.pi / 2,
            ),
            const Color(0xFF065F46),
          )
          ..position.y = 0.15
          ..scale.set(1.2, 0.75, 1.0),
      )
      ..add(_ball(0.2, const Color(0xFF84CC16))..position.set(0.85, 0.25, 0));
    for (final (x, z) in const [
      (0.45, 0.45),
      (0.45, -0.45),
      (-0.45, 0.45),
      (-0.45, -0.45),
    ]) {
      n.add(_ball(0.14, const Color(0xFF84CC16))..position.set(x, 0.1, z));
    }
    return n;
  }

  _rt_Node3D _lotusModel() {
    final n = _rt_Node3D(name: 'lotus')
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.85, 0.85, 0.05, segments: 18),
          const Color(0xFF15803D),
        )..depthBias = -4,
      );
    for (var k = 0; k < 6; k++) {
      final a = k / 6 * 2 * math.pi;
      n.add(
        _mesh(
            _rt_Geometry3D.sphere(0.25, widthSegments: 8, heightSegments: 5),
            k.isEven ? const Color(0xFFF472B6) : const Color(0xFFFBCFE8),
          )
          ..position.set(0.2 * math.cos(a), 0.3, 0.2 * math.sin(a))
          ..rotation.set(0.6 * math.sin(a), 0, -0.6 * math.cos(a))
          ..scale.set(0.5, 1.0, 0.5),
      );
    }
    return n..add(_ball(0.1, const Color(0xFFFACC15))..position.y = 0.32);
  }

  _rt_Node3D _algaeModel() {
    final n = _rt_Node3D(name: 'algae');
    for (var k = 0; k < 9; k++) {
      final a = k * 2.39996;
      final r = 0.55 * math.sqrt((k + 0.5) / 9);
      n.add(
        _ball(
          0.12,
          k.isEven ? const Color(0xFF84CC16) : const Color(0xFF65A30D),
        )..position.set(r * math.cos(a), 0.06, r * math.sin(a)),
      );
    }
    return n;
  }

  _rt_Node3D _waterDropModel() {
    const blue = Color(0xFF38BDF8);
    return _rt_Node3D(name: 'water')
      ..add(
        _mesh(_rt_Geometry3D.sphere(0.5), blue, shininess: 0.8)
          ..position.y = 0.5,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cone(0.42, 0.7, segments: 14),
          blue,
          shininess: 0.8,
        )..position.y = 1.08,
      );
  }

  _rt_Node3D _mudModel() {
    return _rt_Node3D(name: 'mud')
      ..add(
        _mesh(
          _rt_Geometry3D.sphere(
            0.8,
            widthSegments: 12,
            heightSegments: 5,
            thetaLength: math.pi / 2,
          ),
          const Color(0xFF451A03),
        )..scale.set(1, 0.5, 1),
      )
      ..add(_ball(0.1, const Color(0xFF78716C))..position.set(0.3, 0.32, 0.3));
  }

  _rt_Node3D _bubblesModel() {
    final n = _rt_Node3D(name: 'oxygen');
    for (final (x, y, r) in const [
      (0.0, 0.25, 0.22),
      (0.25, 0.65, 0.16),
      (-0.2, 0.95, 0.13),
      (0.1, 1.3, 0.1),
      (-0.1, 1.55, 0.08),
    ]) {
      n.add(
        _ball(r, const Color(0xFFE0F2FE), opacity: 0.7)..position.set(x, y, 0),
      );
    }
    return n;
  }

  _rt_Node3D _pineModel() {
    final n = _rt_Node3D(name: 'pine')
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.18, 0.28, 1.6, segments: 8),
          const Color(0xFF5C4033),
        )..position.y = 0.8,
      );
    for (final (y, r, h, c) in const [
      (1.9, 1.3, 1.6, Color(0xFF14532D)),
      (2.8, 1.05, 1.4, Color(0xFF166534)),
      (3.6, 0.8, 1.2, Color(0xFF15803D)),
    ]) {
      n.add(_mesh(_rt_Geometry3D.cone(r, h, segments: 10), c)..position.y = y);
    }
    return n;
  }

  /// A bird with flapping wings (facing +x).
  _rt_Node3D _birdModel(Color body) {
    final n = _rt_Node3D(name: 'bird')
      ..add(
        _mesh(
          _rt_Geometry3D.sphere(0.3, widthSegments: 10, heightSegments: 6),
          body,
        )..scale.set(1.5, 0.8, 0.8),
      )
      ..add(_ball(0.18, body)..position.set(0.45, 0.15, 0))
      ..add(
        _mesh(
            _rt_Geometry3D.cone(0.07, 0.22, segments: 5),
            const Color(0xFFF59E0B),
          )
          ..position.set(0.68, 0.13, 0)
          ..rotation.z = -math.pi / 2,
      );
    for (final side in const [-1.0, 1.0]) {
      final wing = _rt_Node3D()
        ..position.set(0, 0.1, 0.15 * side)
        ..userData['side'] = side
        ..add(
          _mesh(
              _rt_Geometry3D.sphere(0.35, widthSegments: 8, heightSegments: 5),
              body,
            )
            ..position.set(-0.05, 0, 0.35 * side)
            ..scale.set(0.8, 0.1, 1.0),
        );
      _flappers.add(wing);
      n.add(wing);
    }
    return n;
  }

  _rt_Node3D _grassModel() {
    final n = _rt_Node3D(name: 'grass');
    for (final (dx, dz) in const [(-0.6, 0.2), (0.5, -0.2), (0.0, 0.6)]) {
      for (var k = 0; k < 6; k++) {
        final a = k / 6 * 2 * math.pi;
        n.add(
          _mesh(
              _rt_Geometry3D.cone(0.15, 1.6, segments: 4),
              k.isEven ? const Color(0xFF4ADE80) : const Color(0xFF22C55E),
            )
            ..position.set(
              dx + 0.25 * math.cos(a),
              0.8,
              dz + 0.25 * math.sin(a),
            )
            ..rotation.set(0.25 * math.sin(a), 0, -0.25 * math.cos(a)),
        );
      }
    }
    return n;
  }

  _rt_Node3D _sunModel(double r) {
    final n = _rt_Node3D(name: 'sun')
      ..add(
        _rt_Sphere3D(
          r,
          _rt_Material3D(color: const Color(0xFFFDE047), unlit: true),
        ),
      );
    for (var k = 0; k < 10; k++) {
      final a = k / 10 * 2 * math.pi;
      final dir = _rt_V3(math.cos(a), math.sin(a), 0);
      n.add(
        _mesh(
            _rt_Geometry3D.cone(0.18, 0.8, segments: 5),
            const Color(0xFFFACC15),
          )
          ..position.copy(dir * (r + 0.55))
          ..pointAlong(dir),
      );
    }
    return n;
  }

  /// A thermometer on a stand (content fix: temperature is shown with a
  /// thermometer).
  _rt_Node3D _thermometerModel() {
    return _rt_Node3D(name: 'thermometer')
      ..add(
        _mesh(_rt_Geometry3D.box(0.9, 0.15, 0.6), const Color(0xFF475569))
          ..position.y = 0.08,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.16, 0.16, 2.2, segments: 10),
          const Color(0xFFF1F5F9),
          opacity: 0.55,
        )..position.y = 1.4,
      )
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.07, 0.07, 1.3, segments: 8),
          const Color(0xFFEF4444),
        )..position.y = 1.0,
      )
      ..add(_ball(0.22, const Color(0xFFEF4444))..position.y = 0.4);
  }

  _rt_Node3D _soilPatch(double r) {
    final n = _rt_Node3D(name: 'soil')
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(r, r, 0.1, segments: 16),
            const Color(0xFF78350F),
          )
          ..position.y = 0.05
          ..depthBias = 8,
      );
    for (var k = 0; k < 5; k++) {
      final a = k * 1.3;
      n.add(
        _ball(0.1, const Color(0xFFA8A29E))
          ..position.set(0.6 * r * math.cos(a), 0.12, 0.6 * r * math.sin(a)),
      );
    }
    return n;
  }

  _rt_Node3D _squirrelModel() {
    const fur = Color(0xFFEA580C);
    final n = _rt_Node3D(name: 'squirrel')
      ..add(
        _mesh(
            _rt_Geometry3D.sphere(0.35, widthSegments: 10, heightSegments: 6),
            fur,
          )
          ..position.y = 0.4
          ..scale.set(1.2, 1.0, 0.9),
      )
      ..add(
        _mesh(
          _rt_Geometry3D.sphere(0.22, widthSegments: 8, heightSegments: 6),
          fur,
        )..position.set(0.36, 0.7, 0),
      )
      ..add(
        _mesh(
            _rt_Geometry3D.sphere(0.3, widthSegments: 8, heightSegments: 6),
            const Color(0xFFC2410C),
          )
          ..position.set(-0.45, 0.78, 0)
          ..scale.set(0.7, 1.6, 0.7)
          ..rotation.z = 0.45,
      );
    for (final side in const [-1.0, 1.0]) {
      n.add(
        _ball(0.04, const Color(0xFF111827))
          ..position.set(0.53, 0.76, 0.1 * side),
      );
    }
    return n;
  }

  _rt_Node3D _rockModel(double s) => _rt_Node3D(name: 'rock')
    ..add(
      _mesh(_rt_Geometry3D.icosahedron(0.5), const Color(0xFF78716C))
        ..position.y = 0.3 * s
        ..scale.set(1.2 * s, 0.7 * s, s),
    );

  /// A round-topped park tree.
  _rt_Node3D _parkTree(double s) => _rt_Node3D(name: 'tree')
    ..scale.set(s, s, s)
    ..add(
      _mesh(
        _rt_Geometry3D.cylinder(0.2, 0.28, 2.0, segments: 8),
        const Color(0xFF78350F),
      )..position.y = 1.0,
    )
    ..add(_ball(1.1, const Color(0xFF16A34A))..position.y = 2.6);

  _rt_Node3D _flowerModel(Color c) => _rt_Node3D(name: 'flower')
    ..add(
      _mesh(
        _rt_Geometry3D.cylinder(0.03, 0.04, 0.7, segments: 5),
        const Color(0xFF16A34A),
      )..position.y = 0.35,
    )
    ..add(_ball(0.18, c)..position.y = 0.75);

  _rt_Node3D _butterflyModel() {
    final n = _rt_Node3D(name: 'butterfly')
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.03, 0.03, 0.35, segments: 5),
          const Color(0xFF1C1917),
        )..rotation.z = math.pi / 2,
      );
    for (final side in const [-1.0, 1.0]) {
      final wing = _rt_Node3D()
        ..userData['side'] = side
        ..add(
          _mesh(
              _rt_Geometry3D.sphere(0.28, widthSegments: 8, heightSegments: 5),
              const Color(0xFFF97316),
            )
            ..position.set(0, 0, 0.25 * side)
            ..scale.set(1.0, 0.08, 0.9),
        );
      _flappers.add(wing);
      n.add(wing);
    }
    return n;
  }

  _rt_Node3D _bushModel() => _rt_Node3D(name: 'bush')
    ..add(_ball(0.6, const Color(0xFF15803D))..position.set(0, 0.5, 0))
    ..add(_ball(0.45, const Color(0xFF16A34A))..position.set(0.55, 0.4, 0.1))
    ..add(_ball(0.45, const Color(0xFF22C55E))..position.set(-0.5, 0.4, 0.1));

  _rt_Node3D _benchModel() {
    const wood = Color(0xFF92400E);
    final n = _rt_Node3D(name: 'bench')
      ..add(_mesh(_rt_Geometry3D.box(2.0, 0.12, 0.6), wood)..position.y = 0.5)
      ..add(
        _mesh(_rt_Geometry3D.box(2.0, 0.5, 0.1), wood)
          ..position.set(0, 0.85, -0.28),
      );
    for (final x in const [-0.85, 0.85]) {
      n.add(
        _mesh(_rt_Geometry3D.box(0.1, 0.5, 0.5), const Color(0xFF334155))
          ..position.set(x, 0.25, 0),
      );
    }
    return n;
  }

  _rt_Node3D _poleModel({bool lamp = false}) {
    final n = _rt_Node3D(name: 'pole')
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.08, 0.1, 4.0, segments: 8),
          const Color(0xFF64748B),
        )..position.y = 2.0,
      );
    if (lamp) {
      n.add(_ball(0.25, const Color(0xFFFEF9C3))..position.y = 4.1);
    } else {
      n.add(
        _mesh(_rt_Geometry3D.box(1.6, 0.08, 0.08), const Color(0xFF64748B))
          ..position.y = 3.7,
      );
    }
    return n;
  }

  _rt_Node3D _carModel(Color c) {
    final n = _rt_Node3D(name: 'car')
      ..add(_mesh(_rt_Geometry3D.box(2.2, 0.55, 1.1), c)..position.y = 0.5)
      ..add(
        _mesh(_rt_Geometry3D.box(1.2, 0.45, 1.0), const Color(0xFFBAE6FD))
          ..position.set(-0.1, 0.98, 0),
      );
    for (final x in const [-0.7, 0.7]) {
      for (final z in const [-0.55, 0.55]) {
        n.add(
          _mesh(
              _rt_Geometry3D.cylinder(0.25, 0.25, 0.15, segments: 10),
              const Color(0xFF111827),
            )
            ..position.set(x, 0.25, z)
            ..rotation.x = math.pi / 2,
        );
      }
    }
    return n;
  }

  _rt_Node3D _signModel() => _rt_Node3D(name: 'sign')
    ..add(
      _mesh(
        _rt_Geometry3D.cylinder(0.06, 0.06, 2.2, segments: 6),
        const Color(0xFF64748B),
      )..position.y = 1.1,
    )
    ..add(
      _mesh(_rt_Geometry3D.box(1.0, 0.7, 0.06), const Color(0xFF2563EB))
        ..position.y = 2.3,
    );

  _rt_Node3D _dogModel() {
    const fur = Color(0xFFA16207);
    final n = _rt_Node3D(name: 'dog')
      ..add(
        _mesh(
            _rt_Geometry3D.sphere(0.35, widthSegments: 10, heightSegments: 6),
            fur,
          )
          ..position.y = 0.6
          ..scale.set(1.5, 0.8, 0.8),
      )
      ..add(_ball(0.25, fur)..position.set(0.6, 0.85, 0))
      ..add(
        _mesh(_rt_Geometry3D.cone(0.06, 0.4, segments: 4), fur)
          ..position.set(-0.6, 0.85, 0)
          ..rotation.z = 0.8,
      );
    for (final x in const [-0.3, 0.3]) {
      for (final z in const [-0.15, 0.15]) {
        n.add(
          _mesh(_rt_Geometry3D.cylinder(0.06, 0.06, 0.45, segments: 5), fur)
            ..position.set(x, 0.22, z),
        );
      }
    }
    return n;
  }

  /// An arc from [a] to [b] rising [peak] above them, with a head at [b].
  _rt_Node3D _arcArrow(_rt_V3 a, _rt_V3 b, double peak, Color color) {
    _rt_V3 at(double t) => a.lerp(b, t)..y += peak * math.sin(math.pi * t);
    final tip = at(1);
    final dir = (tip - at(0.93))..normalize();
    return _rt_Node3D()
      ..add(
        _rt_Line3D(
          [for (var k = 0; k <= 24; k++) at(k / 24)],
          color: color,
          width: 4,
        )..pickable = false,
      )
      ..add(
        _mesh(_rt_Geometry3D.cone(0.3, 0.65, segments: 10), color)
          ..position.copy(tip)
          ..pointAlong(dir),
      );
  }

  /// Makes [n] tappable as [tap] (with a finger-sized proxy of radius [r]
  /// around [at]).
  _rt_Node3D _tappable(String tap, _rt_Node3D n, {double r = 0.8, _rt_V3? at}) {
    n.add(
      _proxy(_rt_Geometry3D.sphere(r))
        ..position.copy(at ?? _rt_V3(0, r * 0.6, 0)),
    );
    n.userData['tap'] = tap;
    _tapNodes[tap] = n;
    return n;
  }

  // ---------------------------------------------------------- scenes ---
  void _buildScenario() {
    _root.clear();
    _labels.clear();
    _objects.clear();
    _tapNodes.clear();
    _rings.clear();
    _ringMats.clear();
    _linkArrows.clear();
    _flappers.clear();
    _fliers.clear();
    _counts.clear();
    _beam = null;
    _rng = math.Random(141 + _scenario);
    switch (_scenario) {
      case 1:
        _buildPond();
      case 2:
        _buildForest();
      case 3:
        _buildLandscape();
      case 4:
        _buildHabitats();
      default:
        _buildParkRoad();
    }
    _syncLabels();
  }

  void _ground(double w, double d, Color c, {double x = 0, double z = 0}) {
    _root.add(
      _mesh(_rt_Geometry3D.box(w, 0.2, d), c)
        ..position.set(x, -0.1, z)
        ..depthBias = 40,
    );
  }

  /// A pond: bank, bed and a translucent surface (drawn over what swims
  /// below it).
  void _pond(double x, double z, double r) {
    _root
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(r + 0.8, r + 1.0, 0.2, segments: 40),
            const Color(0xFF78350F),
          )
          ..position.set(x, -0.05, z)
          ..depthBias = 38,
      )
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(r, r - 0.4, 0.9, segments: 40),
            const Color(0xFF1E3A8A),
          )
          ..position.set(x, -0.5, z)
          ..depthBias = 30,
      )
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(r, r, 0.04, segments: 40),
            const Color(0xFF0EA5E9),
            opacity: 0.7,
            shininess: 0.7,
          )
          ..position.set(x, 0.0, z)
          ..depthBias = -3,
      );
  }

  /// S1: the pond, its eight items and the two bins.
  void _buildPond() {
    _ground(34, 16, const Color(0xFF4D7C0F));
    _pond(0, -0.6, 5.2);
    for (final bin in const ['biotic', 'abiotic']) {
      final x = _binX(bin);
      final edge = bin == 'biotic'
          ? const Color(0xFF22C55E)
          : const Color(0xFF94A3B8);
      _root
        ..add(
          _mesh(
            _rt_Geometry3D.box(4.4, 2.6, 3.4),
            Colors.white,
            opacity: 0.12,
            edge: edge,
          )..position.set(x, 1.3, 0.5),
        )
        ..add(
          _label(bin == 'biotic' ? 'binBiotic' : 'binAbiotic', x, 3.2, 0.5),
        );
    }
    for (final id in _pondItems) {
      final node = switch (id) {
        'fish' => _fishModel()..scale.set(1.5, 1.5, 1.5),
        'frog' => _frogModel()..scale.set(1.6, 1.6, 1.6),
        'turtle' => _turtleModel()..scale.set(1.2, 1.2, 1.2),
        'lotus' => _lotusModel(),
        'algae' => _algaeModel()..scale.set(1.3, 1.3, 1.3),
        'water' => _waterDropModel(),
        'mud' => _mudModel(),
        _ => _bubblesModel(),
      };
      node
        ..add(_proxy(_rt_Geometry3D.sphere(0.75))..position.y = 0.4)
        ..add(_label(id, 0, -0.1, 1.0));
      final (x, y, z) = _pondHome[id]!;
      _setHome(node, x, y, z);
      _root.add(_draggable(id, node));
    }
  }

  /// S2: a forest with six targets, each with a glowing ring.
  void _buildForest() {
    _ground(36, 18, const Color(0xFF166534));
    for (final (x, z, r) in const [
      (-11.0, -8.0, 5.0),
      (2.0, -9.0, 6.0),
      (12.0, -8.0, 4.5),
    ]) {
      _root.add(
        _mesh(
            _rt_Geometry3D.sphere(r, widthSegments: 16, heightSegments: 8),
            const Color(0xFF14532D),
          )
          ..position.set(x, -1.0, z)
          ..scale.set(1.4, 0.6, 1.0)
          ..depthBias = 20,
      );
    }
    for (final (x, z, s) in const [
      (-9.0, -3.0, 1.2),
      (-7.4, 1.0, 1.0),
      (8.5, -3.5, 1.1),
      (-2.0, -4.0, 0.9),
    ]) {
      _root.add(
        _pineModel()
          ..position.set(x, 0, z)
          ..scale.set(s, s, s),
      );
    }
    final targets = <String, _rt_Node3D>{
      'pine': _pineModel()..scale.set(1.5, 1.5, 1.5),
      'bird': _birdModel(const Color(0xFF2563EB))..scale.set(1.3, 1.3, 1.3),
      'grass': _grassModel(),
      'sunlight': _sunModel(1.4),
      'temperature': _thermometerModel(),
      'soil': _soilPatch(1.3),
    };
    for (final MapEntry(key: id, value: node) in targets.entries) {
      final (x, y, z) = _targetSpot[id]!;
      final base = switch (id) {
        'pine' => _rt_V3(x, 0, z),
        'grass' || 'soil' || 'temperature' => _rt_V3(x, 0, z),
        _ => _rt_V3(x, y, z),
      };
      node.position.copy(base);
      final local = _rt_V3(x, y, z) - base;
      _tappable(
        'target:$id',
        node,
        r: id == 'sunlight' ? 1.8 : 1.0,
        at: local / node.scale.x,
      );
      if (id == 'bird') {
        node.userData['orbit'] = _rt_V3(x, y, z);
        _fliers.add(node);
      }
      _root.add(node);
      // The glowing ring around the target.
      final mat = _rt_Material3D(
        color: const Color(0xFF22D3EE),
        unlit: true,
        opacity: 0.85,
      );
      final ring = _rt_Node3D()
        ..position.set(x, y, z)
        ..add(
          _rt_Mesh3D(
            _rt_Geometry3D.torus(
              id == 'sunlight' ? 2.4 : 1.2,
              0.06,
              tubularSegments: 28,
            ),
            mat,
          ),
        );
      _rings[id] = ring;
      _ringMats[id] = mat;
      _root
        ..add(ring)
        ..add(
          _hiddenLabel(id, x, y - (id == 'sunlight' ? 2.6 : 1.4), z)
            ..userData['target'] = id,
        );
    }
  }

  /// S3: mountains, a river, trees, plants and the Sun.
  void _buildLandscape() {
    _ground(34, 20, const Color(0xFF4D7C0F), z: -1);
    for (final (x, h, r) in const [
      (-8.0, 7.0, 4.0),
      (-3.0, 9.0, 4.6),
      (2.5, 6.0, 3.6),
    ]) {
      _root
        ..add(
          _mesh(_rt_Geometry3D.cone(r, h, segments: 8), const Color(0xFF64748B))
            ..position.set(x, h / 2, -8.0)
            ..depthBias = 10,
        )
        ..add(
          _mesh(
              _rt_Geometry3D.cone(r * 0.32, h * 0.32, segments: 8),
              Colors.white,
            )
            ..position.set(x, h * 0.84, -8.0)
            ..depthBias = 8,
        );
    }
    // The river: from the mountains to the front, a flat ribbon.
    final path = [
      for (var t = 0; t <= 20; t++)
        _rt_V3(
          -3.0 + 4.0 * t / 20 + 1.6 * math.sin(t / 20 * 2.4 * math.pi),
          0,
          -5.6 + 12.0 * t / 20,
        ),
    ];
    _root.add(
      _mesh(
          _rt_Geometry3D.tube(path, 0.7, radialSegments: 8),
          const Color(0xFF0EA5E9),
          shininess: 0.7,
        )
        ..position.y = 0.04
        ..scale.set(1, 0.08, 1)
        ..depthBias = 6,
    );
    for (final (x, z, s) in const [
      (-11.0, -1.5, 1.1),
      (-9.0, 0.5, 1.3),
      (-7.0, -2.0, 1.0),
      (-10.0, 3.0, 0.9),
      (-6.4, 2.2, 1.1),
    ]) {
      _root.add(
        _pineModel()
          ..position.set(x, 0, z)
          ..scale.set(s, s, s),
      );
    }
    for (final (x, z) in const [(6.0, 0.5), (8.0, 2.4), (9.6, 0.0)]) {
      _root
        ..add(_bushModel()..position.set(x, 0, z))
        ..add(
          _flowerModel(const Color(0xFFF472B6))
            ..position.set(x + 0.8, 0, z + 0.8),
        );
    }
    _root.add(
      _sunModel(1.6)..position.copy(_v(_anchor3['sun']!) + _rt_V3(0, 1.6, -1)),
    );
    for (final MapEntry(key: id, value: (x, y, z)) in _anchor3.entries) {
      _root.add(
        _label(
          id,
          x,
          id == 'sun' ? y - 1.4 : (id == 'river' ? 0.1 : y + 0.6),
          z + (id == 'river' ? 1.6 : 0),
        ),
      );
    }
    for (final MapEntry(key: key, value: (from, to)) in _flow3.entries) {
      final arrow = _arcArrow(
        _v(_anchor3[from]!),
        _v(_anchor3[to]!),
        2.4,
        const Color(0xFF22C55E),
      )..visible = false;
      _linkArrows[key] = arrow;
      _root.add(arrow);
    }
  }

  /// S4: a large tree (left) and a pond (right), each with five items.
  void _buildHabitats() {
    _ground(34, 16, const Color(0xFF4D7C0F));
    const tx = -6.0;
    _root
      ..add(
        _mesh(
          _rt_Geometry3D.cylinder(0.55, 0.85, 6.5, segments: 12),
          const Color(0xFF78350F),
        )..position.set(tx, 3.25, -1.0),
      )
      ..add(
        _mesh(
            _rt_Geometry3D.cylinder(0.15, 0.25, 3.0, segments: 8),
            const Color(0xFF78350F),
          )
          ..position.set(tx + 1.3, 4.6, -1.0)
          ..rotation.z = -0.9,
      );
    for (final (x, y, z, r) in const [
      (-6.0, 7.6, -1.4, 2.2),
      (-4.2, 7.0, -1.2, 1.7),
      (-7.8, 7.0, -1.2, 1.7),
      (-6.0, 8.6, -0.6, 1.5),
    ]) {
      _root.add(_ball(r, const Color(0xFF15803D))..position.set(x, y, z));
    }
    _pond(6.0, 0.4, 4.0);
    final items = <String, (_rt_Node3D, double)>{
      'squirrel': (
        _squirrelModel()
          ..position.set(tx + 2.2, 5.5, -0.8)
          ..scale.set(1.3, 1.3, 1.3),
        0.7,
      ),
      'bird': (
        _birdModel(const Color(0xFFDC2626))..position.set(tx - 1.4, 8.0, 1.0),
        0.8,
      ),
      'ants': (_antsModel()..position.set(tx, 1.2, -0.4), 0.8),
      'soil': (_soilPatch(2.0)..position.set(tx, 0, -0.4), 1.0),
      'air': (_airModel()..position.set(tx + 3.8, 3.2, 1.4), 1.0),
      'fish': (
        _fishModel()
          ..position.set(4.4, -0.32, 0.4)
          ..scale.set(1.5, 1.5, 1.5),
        0.8,
      ),
      'frog': (
        _frogModel()
          ..position.set(9.6, 0.0, 2.6)
          ..scale.set(1.5, 1.5, 1.5),
        0.8,
      ),
      'lily': (_lotusModel()..position.set(6.6, 0.04, -1.2), 0.9),
      'water': (_rt_Node3D(name: 'water')..position.set(7.6, 0.05, 1.8), 0.9),
      'rocks': (
        _rt_Node3D(name: 'rocks')
          ..position.set(2.0, 0, 3.4)
          ..add(_rockModel(1.0))
          ..add(_rockModel(0.7)..position.set(0.8, 0, 0.4)),
        0.9,
      ),
    };
    for (final MapEntry(key: id, value: (node, r)) in items.entries) {
      _tappable('obs:$id', node, r: r / node.scale.x, at: _rt_V3(0, 0.4, 0));
      // Labels sit above things up in the tree and in front of the rest.
      final p = node.position;
      final at = switch (id) {
        'bird' || 'squirrel' || 'air' => p + _rt_V3(0, 1.0, 0),
        'ants' => p + _rt_V3(1.4, 0.6, 0.4),
        _ => _rt_V3(p.x, -0.05, p.z + 1.2),
      };
      _root
        ..add(node)
        ..add(_label(id, at.x, at.y, at.z));
    }
    _root
      ..add(_label('habTree', tx, 0.05, 4.4))
      ..add(_label('habPond', 6.0, 0.05, 6.4));
  }

  /// Ants climbing the trunk.
  _rt_Node3D _antsModel() {
    final n = _rt_Node3D(name: 'ants');
    for (var k = 0; k < 6; k++) {
      n
        ..add(
          _ball(0.07, const Color(0xFF111827))
            ..position.set(0.05 * (k.isEven ? 1 : -1), 0.25 * k, 0),
        )
        ..add(
          _ball(0.05, const Color(0xFF111827))
            ..position.set(0.05 * (k.isEven ? 1 : -1), 0.25 * k + 0.09, 0),
        );
    }
    return n;
  }

  /// Air: a few swirling gusts.
  _rt_Node3D _airModel() {
    final n = _rt_Node3D(name: 'air');
    for (var k = 0; k < 3; k++) {
      n.add(
        _rt_Line3D(
          [
            for (var t = 0; t <= 16; t++)
              _rt_V3(
                -1.0 + 2.0 * t / 16,
                0.5 * k + 0.25 * math.sin(t / 16 * 2 * math.pi + k),
                0,
              ),
          ],
          color: const Color(0xFFBAE6FD),
          width: 3,
        )..pickable = false,
      );
    }
    return n;
  }

  /// S5: a park (left) and a roadside (right); every component is tagged
  /// living or human-made and counted by the scanner (content fix: the
  /// shares come from these counts).
  void _buildParkRoad() {
    _ground(12, 13, const Color(0xFF4D7C0F), x: -6.4);
    _ground(12, 13, const Color(0xFF57534E), x: 6.4);
    _root
      ..add(
        _mesh(_rt_Geometry3D.box(0.5, 0.4, 13), const Color(0xFFD6D3D1))
          ..position.set(0, 0.2, 0),
      )
      ..add(
        _mesh(_rt_Geometry3D.box(5.0, 0.04, 13), const Color(0xFF292524))
          ..position.set(6.8, 0.02, 0)
          ..depthBias = 30,
      );
    for (var k = 0; k < 5; k++) {
      _root.add(
        _mesh(_rt_Geometry3D.box(0.15, 0.03, 1.4), const Color(0xFFFDE047))
          ..position.set(6.8, 0.06, -5.0 + 2.5 * k)
          ..depthBias = 28,
      );
    }
    void put(String scene, String comp, _rt_Node3D n) {
      n.userData['comp'] = '$scene:$comp';
      _root.add(n);
    }

    // Park: 11 living things, 2 human-made objects.
    for (final (x, z, s) in const [
      (-9.5, -3.5, 1.1),
      (-4.0, -4.0, 1.0),
      (-8.0, 2.5, 0.9),
    ]) {
      put('park', 'living', _parkTree(s)..position.set(x, 0, z));
    }
    for (final (x, z, c) in const [
      (-6.0, 1.0, Color(0xFFF472B6)),
      (-5.2, 2.0, Color(0xFFFACC15)),
      (-3.6, 0.4, Color(0xFFF472B6)),
      (-2.4, 3.0, Color(0xFFFACC15)),
    ]) {
      put('park', 'living', _flowerModel(c)..position.set(x, 0, z));
    }
    for (final (x, z) in const [(-10.0, 0.0), (-2.4, -1.8)]) {
      put('park', 'living', _bushModel()..position.set(x, 0, z));
    }
    for (final (x, y, z) in const [(-6.5, 2.2, -1.0), (-3.0, 1.8, 1.8)]) {
      final b = _butterflyModel()..userData['orbit'] = _rt_V3(x, y, z);
      _fliers.add(b);
      put('park', 'living', b..position.set(x, y, z));
    }
    put('park', 'made', _benchModel()..position.set(-6.0, 0, -1.2));
    put('park', 'made', _poleModel(lamp: true)..position.set(-1.4, 0, -4.6));
    // Roadside: 2 living things, 8 human-made objects (the road counts).
    final road = _rt_Node3D(name: 'road');
    put('road', 'made', road);
    for (final (x, z, c) in const [
      (6.0, -3.0, Color(0xFFDC2626)),
      (7.6, 1.6, Color(0xFF2563EB)),
      (6.0, 4.6, Color(0xFFFACC15)),
    ]) {
      put(
        'road',
        'made',
        _carModel(c)
          ..position.set(x, 0, z)
          ..rotation.y = math.pi / 2,
      );
    }
    for (final z in const [-5.0, 0.0, 5.0]) {
      put('road', 'made', _poleModel()..position.set(10.4, 0, z));
    }
    put('road', 'made', _signModel()..position.set(3.4, 0, -4.4));
    put('road', 'living', _dogModel()..position.set(3.4, 0, 2.0));
    put(
      'road',
      'living',
      _grassModel()
        ..position.set(10.6, 0, 2.6)
        ..scale.set(0.6, 0.6, 0.6),
    );
    _root
      ..add(_label('park', -6.4, 0.05, 6.0))
      ..add(_label('road', 6.4, 0.05, 6.0));
    final beam = _rt_Node3D()
      ..visible = false
      ..add(
        _rt_Mesh3D(
          _rt_Geometry3D.box(0.25, 6.0, 13.0),
          _rt_Material3D(
            color: const Color(0xFF22D3EE),
            opacity: 0.35,
            unlit: true,
          ),
        )..position.y = 3.0,
      );
    beam.pickable = false;
    _beam = beam;
    _root.add(beam);
  }

  // ------------------------------------------------------------ camera ---
  /// Points that must stay on screen in the current scenario.
  List<_rt_V3> get _framePoints => switch (_scenario) {
    1 => [
      _rt_V3(-12.0, 2.6, 2.3),
      _rt_V3(12.0, 2.6, 2.3),
      _rt_V3(-12.4, 0, 2.4),
      _rt_V3(12.4, 0, 2.4),
      _rt_V3(-11.8, 3.6, 0.5),
      _rt_V3(11.8, 3.6, 0.5),
      _rt_V3(-6.2, 0, 6.8),
      _rt_V3(4.6, 0, 6.6),
      _rt_V3(0, 0, -6.4),
    ],
    2 => [
      _rt_V3(-10.4, 11.4, -9.0),
      _rt_V3(-10.4, 0, 2.0),
      _rt_V3(9.0, 0, 2.4),
      _rt_V3(5.6, 7.0, -2.0),
      _rt_V3(-2.0, 0, 5.4),
      _rt_V3(9.4, 0, -4.0),
    ],
    3 => [
      _rt_V3(-12.4, 0, 3.6),
      _rt_V3(11.4, 0, 3.6),
      _rt_V3(-3.0, 9.4, -8.0),
      _rt_V3(9.0, 11.6, -7.0),
      _rt_V3(1.4, 0, 8.4),
      _rt_V3(-11.6, 0, -8.0),
    ],
    4 => [
      _rt_V3(-10.4, 0, 4.6),
      _rt_V3(11.2, 0, 4.6),
      _rt_V3(6.0, 0, 7.0),
      _rt_V3(-6.0, 10.4, -1.0),
      _rt_V3(-8.6, 9.2, 1.0),
      _rt_V3(6.0, 0, 6.2),
      _rt_V3(2.0, 0, 4.8),
    ],
    _ => [
      _rt_V3(-12.4, 0, 6.6),
      _rt_V3(12.4, 0, 6.6),
      _rt_V3(-12.4, 0, -6.6),
      _rt_V3(12.4, 0, -6.6),
      _rt_V3(-9.5, 4.0, -3.5),
      _rt_V3(10.4, 4.2, -5.0),
    ],
  };

  double get _elevation => switch (_scenario) {
    1 => 0.6,
    2 => 0.3,
    3 => 0.45,
    4 => 0.3,
    _ => 0.65,
  };

  /// Width of the chalkboard (step 1) or the step panel on the left.
  double _boardWidth(Size size, bool compact) =>
      math.min(compact ? 270.0 : 420.0, size.width * 0.5);

  double _panelWidth(Size size, bool compact) =>
      math.min(compact ? 220.0 : 330.0, size.width * 0.46);

  /// True for steps that show a panel on the left of the 3D view.
  bool get _hasSidePanel => _scenario != 1 && _step >= 2;

  double _topReserve(bool compact) => 0;

  /// Canvas size the camera was last fitted for (per scenario and step).
  (int, int, Size)? _fitKey;

  /// Frames the scene in the space left by the chalkboard or step panel,
  /// the monitor, the HUD and the toolbar (the source's fixed camera
  /// pushed props off narrow screens). A few projection passes converge.
  void _fitCamera(Size size, bool compact) {
    final key = (_scenario, _step, size);
    if (_fitKey == key || size.isEmpty || _panelMode) return;
    _fitKey = key;
    final points = _framePoints;
    const margin = 14.0;
    final top = (compact ? 8.0 : 16.0) + margin + _topReserve(compact);
    final bottom = size.height - (compact ? 62.0 : 90.0) - margin;
    final left =
        (_step == 1
            ? 12 + _boardWidth(size, compact)
            : (_hasSidePanel ? 12 + _panelWidth(size, compact) : 10.0)) +
        margin;
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
    var distance = 30.0;
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
      l.pixelHeight = compact ? 9 : 12;
    }
  }

  // ------------------------------------------------------------- frame ---
  void _onFrame(double dt) {
    _clock += dt;
    _tweens.update(dt);
    final beat = 0.6 * math.sin(_clock * 18);
    for (final w in _flappers) {
      w.rotation.x = beat * (w.userData['side'] as double);
    }
    for (final (k, f) in _fliers.indexed) {
      final o = f.userData['orbit'] as _rt_V3;
      final a = _clock * 0.8 + k * 2.0;
      final r = f.name == 'bird' ? 1.2 : 0.6;
      f
        ..position.set(
          o.x + r * math.cos(a),
          o.y + 0.2 * math.sin(a * 2),
          o.z + r * math.sin(a),
        )
        ..rotation.y = -a - math.pi / 2;
    }
    final pulse = 1 + 0.08 * math.sin(_clock * 4);
    for (final MapEntry(key: id, value: ring) in _rings.entries) {
      ring.scale.set(pulse, pulse, pulse);
      if (id == 'bird') {
        final bird = _tapNodes['target:bird'];
        if (bird != null) ring.position.copy(bird.position);
      }
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
      _bins['biotic']!.clear();
      _bins['abiotic']!.clear();
      _target = null;
      _targetWrong = false;
      _identified.clear();
      _links.clear();
      _observed['tree']!.clear();
      _observed['pond']!.clear();
      _scanned = false;
      _shares.clear();
      _shareWrong.clear();
      _sharesDone = false;
      _mcq = null;
      _mcqDone = false;
      _selectedChip = null;
      _wrongZone = null;
      _dragId = null;
    });
    _buildScenario();
    _applyStepVisuals();
    _fitKey = null;
  }

  /// Shows only what the current step uses: the S2 target labels appear
  /// once identified.
  void _applyStepVisuals() {
    for (final l in _labels) {
      final t = l.userData['target'];
      if (t is String) _showLabel(l, _identified.contains(t));
    }
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
            color: _accent,
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
                          color: _accent,
                        )
                      : base,
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _toastText(String text, {bool good = true, int ms = 3000}) {
    _rt_playSfx(good ? _rt_Sfx.correct : _rt_Sfx.wrong);
    _shell.showToast(
      text,
      color: good ? _rt_Tw.green500 : _rt_Tw.red500,
      icon: good ? Icons.check : Icons.info_outline,
      ms: ms,
    );
  }

  void _toast(String key, {bool good = true, int ms = 3000}) =>
      _toastText(_tx.s(key), good: good, ms: ms);

  /// A neutral hint (no sound of success or failure).
  void _hint(String key, {int ms = 4000}) {
    _shell.showToast(
      _tx.s(key),
      color: _accent,
      icon: Icons.lightbulb_outline,
      ms: ms,
    );
  }

  // ------------------------------------------------------------ 3D drags ---
  /// True if [id] may be picked up in the current step.
  bool _grabbable(String id) =>
      !_busy &&
      !_scenarioDone &&
      _scenario == 1 &&
      _step == 2 &&
      _pondItems.contains(id) &&
      !_bins.values.any((b) => b.contains(id));

  /// Ids that can be dragged right now (for the grab / target markers).
  List<String> get _grabbableIds => [
    for (final id in _objects.keys)
      if (_grabbable(id) && _objects[id]!.isVisibleInTree) id,
  ];

  _rt_V3 _handleWorld(String id) =>
      _objects[id]!.localTransform.apply(_rt_V3(0, 0.3, 0));

  /// Both bins (a wrong one explains why).
  List<(String, _DropWindow)> _targets(String id) => [
    for (final bin in const ['biotic', 'abiotic'])
      (bin, _DropWindow(_rt_V3(_binX(bin), 1.3, 0.5), 2.6, 1.8, 2.6)),
  ];

  Iterable<String> _ringTargets(String id) => const ['biotic', 'abiotic'];

  bool _onPointerDown(_rt_SceneEvent e) {
    final hit = e.hitWhere((n) => n.userData['drag'] != null);
    if (hit == null) return false;
    final id = hit.userData['drag'] as String;
    if (!_grabbable(id)) return false;
    final targets = _targets(id);
    final handle = e.frame.project(_handleWorld(id));
    if (handle == null) return false;
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
    p.y = math.max(p.y, 0.2);
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
    final n = _planeNormal;
    if (n == null) return;
    final h = _handleWorld(id);
    final side = _rt_V3(n.z, 0, -n.x);
    String? bin;
    var best = double.infinity;
    for (final (t, w) in _targets(id)) {
      if (!w.contains(h, side)) continue;
      final d = (h - w.centre).length;
      if (d < best) {
        best = d;
        bin = t;
      }
    }
    if (bin == null) {
      _toast('fbDropBin', good: false);
      _snapBack(id);
    } else if ((bin == 'biotic') == _biotic.contains(id)) {
      _sort(id);
    } else {
      // The source said only "Incorrect"; now it explains.
      _toast('hint.$id', good: false, ms: 4000);
      _snapBack(id);
    }
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
  /// Item [id] goes into its bin.
  Future<void> _sort(String id, {bool fromHome = false}) async {
    if (_busy || _scenario != 1 || _step != 2) return;
    final bin = _biotic.contains(id) ? 'biotic' : 'abiotic';
    if (_bins[bin]!.contains(id)) return;
    final run = _run;
    final slot = _bins[bin]!.length;
    setState(() {
      _busy = true;
      _bins[bin]!.add(id);
    });
    final node = _objects[id]!;
    for (final c in node.children) {
      if (c is _rt_Label3D) _showLabel(c, false);
    }
    final to = _rt_V3(
      _binX(bin) - 1.3 + 1.3 * (slot % 3),
      0.3,
      0.5 - 0.7 + 1.4 * (slot ~/ 3),
    );
    final s0 = node.scale.x;
    await Future.wait([
      _tweenNode(node, to, fromHome ? 650 : 400),
      _tweens.run(400, (t) {
        final s = s0 * (1 - 0.3 * t);
        node.scale.set(s, s, s);
      }),
    ]);
    if (!_alive(run)) return;
    _rt_playSfx(_rt_Sfx.pop);
    final sorted = _bins.values.fold(0, (a, b) => a + b.length);
    if (sorted == _pondItems.length) {
      _toast('fbSorted', ms: 3500);
      _after(1200, _completeScenario);
      return;
    }
    setState(() => _busy = false);
  }

  void _sortNext() {
    for (final id in _pondItems) {
      if (!_bins.values.any((b) => b.contains(id))) {
        _sort(id, fromHome: true);
        return;
      }
    }
  }

  // ------------------------------------------------- scenario 2 actions ---
  /// Picks target [id] for classification (the source's lens followed a
  /// hovering mouse; touch screens now tap).
  void _pickTarget(String id) {
    if (_busy || _scenario != 2 || _step != 2 || _identified.contains(id)) {
      return;
    }
    _rt_playSfx(_rt_Sfx.tap);
    for (final MapEntry(key: k, value: m) in _ringMats.entries) {
      if (!_identified.contains(k)) {
        m.color = k == id ? const Color(0xFFFBBF24) : const Color(0xFF22D3EE);
      }
    }
    setState(() {
      _target = id;
      _targetWrong = false;
    });
  }

  void _pickNext() {
    for (final id in _forestTargets) {
      if (!_identified.contains(id) && id != _target) {
        _pickTarget(id);
        return;
      }
    }
  }

  void _classify(String kind) {
    final id = _target;
    if (id == null || _busy || _scenario != 2 || _step != 2) return;
    if ((kind == 'biotic') != _biotic.contains(id)) {
      setState(() => _targetWrong = true);
      _toast('why.$id', good: false, ms: 4500);
      return;
    }
    setState(() {
      _identified.add(id);
      _target = null;
      _targetWrong = false;
    });
    _rings[id]?.visible = false;
    _applyStepVisuals();
    if (_identified.length < _forestTargets.length) {
      _toast('fbAdded', ms: 2000);
      return;
    }
    setState(() => _busy = true);
    _toast('fbForestDone', ms: 3500);
    _after(1200, _completeScenario);
  }

  // ------------------------------------------------- scenario 3 actions ---
  String get _askedKey => _asked[_step - 2];

  void _tapNode(String id) {
    if (_busy || _scenario != 3 || _step < 2) return;
    final first = _selectedChip;
    if (first == null || first == id) {
      _selectChip(id);
      return;
    }
    _link(first, id);
  }

  /// Links two components: the pair this step asks for, another real
  /// link (a neutral hint - content fix) or neither.
  void _link(String a, String b) {
    if (_busy || _scenario != 3 || _step < 2 || a == b) return;
    final key = _pairKey(a, b);
    setState(() => _selectedChip = null);
    final asked = _askedKey;
    if (key != asked) {
      final names = asked.split('-');
      final text = _tx
          .s(_realLinks.contains(key) ? 'fbReal' : 'fbAsk')
          .replaceAll('{a}', _tx.s('lbl.${names[0]}'))
          .replaceAll('{b}', _tx.s('lbl.${names[1]}'));
      if (_realLinks.contains(key)) {
        _shell.showToast(
          text,
          color: _accent,
          icon: Icons.lightbulb_outline,
          ms: 4000,
        );
      } else {
        _toastText(text, good: false, ms: 4000);
      }
      return;
    }
    setState(() {
      _links.add(key);
      _busy = true;
    });
    _rt_playSfx(_rt_Sfx.correct);
    _linkArrows[key]?.visible = true;
    _toast('fbLinked.$key', ms: 3500);
    _after(_step == 4 ? 1200 : 1000, _advance);
  }

  void _linkNext() {
    if (_scenario != 3 || _step < 2) return;
    final names = _askedKey.split('-');
    _link(names[0], names[1]);
  }

  // ------------------------------------------------- scenario 4 actions ---
  /// Records item [id] in Table 12.1 (content fix: exactly 2 biotic and 2
  /// abiotic per habitat - the source did not enforce it).
  void _observe(String id) {
    if (_busy || _scenario != 4 || _step < 2) return;
    final list = _observed[_habitat]!;
    final items = _habitat == 'tree' ? _treeItems : _pondItems4;
    if (!items.contains(id) || list.contains(id)) return;
    final living = _biotic.contains(id);
    if (list.where((x) => _biotic.contains(x) == living).length >= 2) {
      _toast('fbFull.${living ? 'biotic' : 'abiotic'}', good: false, ms: 4000);
      return;
    }
    _rt_playSfx(_rt_Sfx.pop);
    setState(() => list.add(id));
    if (list.length < 4) return;
    setState(() => _busy = true);
    if (_step == 2) {
      _toast('fbTreeDone');
      _after(900, _advance);
    } else {
      _toast('fbPondDone', ms: 3500);
      _after(1200, _completeScenario);
    }
  }

  void _observeNext() {
    if (_scenario != 4 || _step < 2) return;
    final list = _observed[_habitat]!;
    final items = _habitat == 'tree' ? _treeItems : _pondItems4;
    for (final id in items) {
      if (list.contains(id)) continue;
      final living = _biotic.contains(id);
      if (list.where((x) => _biotic.contains(x) == living).length < 2) {
        _observe(id);
        return;
      }
    }
  }

  // ------------------------------------------------- scenario 5 actions ---
  /// The scanner sweeps both scenes and counts their components.
  Future<void> _scan() async {
    if (_busy || _scanned || _scenario != 5 || _step != 2) return;
    final run = _run;
    setState(() => _busy = true);
    _rt_playSfx(_rt_Sfx.magic);
    final beam = _beam;
    beam?.visible = true;
    await _tweens.run(2000, (t) => beam?.position.x = -12 + 24 * t);
    if (!_alive(run)) return;
    beam?.visible = false;
    final counts = <String, (int, int)>{'park': (0, 0), 'road': (0, 0)};
    _root.traverse((n) {
      final c = n.userData['comp'];
      if (c is! String) return;
      final [scene, comp] = c.split(':');
      final (l, m) = counts[scene]!;
      counts[scene] = comp == 'living' ? (l + 1, m) : (l, m + 1);
    });
    setState(() {
      _counts.addAll(counts);
      _scanned = true;
    });
    _toast('fbScanned');
    _after(600, _advance);
  }

  /// Share of living things in [scene] (%).
  int _share(String scene) {
    final (l, m) = _counts[scene] ?? (0, 0);
    return l + m == 0 ? 0 : (100 * l / (l + m)).round();
  }

  void _pickShare(String scene, String v) {
    if (_busy || _sharesDone || _scenario != 5 || _step != 3) return;
    _rt_playSfx(_rt_Sfx.tap);
    setState(() {
      _shares[scene] = v;
      _shareWrong.remove(scene);
    });
  }

  void _checkShares() {
    if (_busy || _sharesDone || _scenario != 5 || _step != 3) return;
    if (_shares.length < _shareAnswers.length) {
      _toast('fbPickAll', good: false);
      return;
    }
    final wrong = {
      for (final MapEntry(key: s, value: a) in _shareAnswers.entries)
        if (_shares[s] != a) s,
    };
    if (wrong.isNotEmpty) {
      setState(
        () => _shareWrong
          ..clear()
          ..addAll(wrong),
      );
      _toast('fbShareWrong', good: false, ms: 4000);
      return;
    }
    setState(() {
      _sharesDone = true;
      _busy = true;
    });
    _toast('fbShareOk', ms: 3500);
    _after(800, _advance);
  }

  void _answer(String o) {
    if (_busy || _mcqDone || _scenario != 5 || _step != 4) return;
    setState(() => _mcq = o);
    if (o != 'b') {
      _toast('whyOpt.$o', good: false, ms: 4000);
      return;
    }
    setState(() {
      _mcqDone = true;
      _busy = true;
    });
    _toast('fbMcqOk');
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

  /// Sidebar twins of the 3D actions: (key, label, action, done).
  List<(String, String, VoidCallback?, bool)> get _twins {
    (String, String, VoidCallback?, bool) twin(
      String key,
      String labelKey,
      bool done,
      VoidCallback fn,
    ) => (key, _tx.s(labelKey), !done && !_busy ? fn : null, done);
    final sorted = _bins.values.fold(0, (a, b) => a + b.length);
    return switch ((_scenario, _step)) {
      (1, 2) => [
        twin('twin-sort', 'twSort', sorted == _pondItems.length, _sortNext),
      ],
      (2, 2) => [
        twin(
          'twin-identify',
          'twIdentify',
          _identified.length == _forestTargets.length,
          _pickNext,
        ),
      ],
      (3, >= 2) => [twin('twin-link', 'twLink', false, _linkNext)],
      (4, >= 2) => [
        twin(
          'twin-observe',
          'twObserve',
          _observed[_habitat]!.length == 4,
          _observeNext,
        ),
      ],
      _ => const [],
    };
  }

  /// Tap markers: the forest targets (S2) and the habitat items (S4).
  List<(String, _rt_V3)> get _tapSpots {
    if (_busy || _scenarioDone) return const [];
    return switch ((_scenario, _step)) {
      (2, 2) => [
        for (final id in _forestTargets)
          if (!_identified.contains(id))
            (
              'tap-$id',
              id == 'bird'
                  ? _tapNodes['target:bird']!.position.clone()
                  : _v(_targetSpot[id]!),
            ),
      ],
      (4, >= 2) => [
        for (final id in _step == 2 ? _treeItems : _pondItems4)
          if (!_observed[_habitat]!.contains(id))
            ('tap-$id', _tapNodes['obs:$id']!.position + _rt_V3(0, 0.4, 0)),
      ],
      _ => const [],
    };
  }

  void _onCanvasTap(_rt_SceneEvent e) {
    final hit = e.hitWhere((n) => n.userData['tap'] != null);
    final tap = hit?.userData['tap'];
    if (tap is! String) return;
    if (tap.startsWith('target:')) {
      _pickTarget(tap.substring(7));
    } else if (tap.startsWith('obs:')) {
      _observe(tap.substring(4));
    }
  }

  // --------------------------------------------------------------- UI ---
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () => SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),
      child: _rt_LangBuilder(
        builder: (context, lang) {
          for (final l in _labels) {
            final path = l.userData['tkey'];
            if (path is String) l.text = _tx.s(path);
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
              icon: Icons.forest,
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
        if (!_scenarioDone)
          Positioned.fill(
            child: IgnorePointer(
              child: ValueListenableBuilder<int>(
                valueListenable: _frameTick,
                builder: (context, _, _) => _markers(size, compact),
              ),
            ),
          ),
        if (_step == 1) _chalkboard(size, compact),
        if (_hasSidePanel && !_scenarioDone) _sidePanel(size, compact),
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
  Widget _sidePanel(Size size, bool compact) {
    final panel = switch (_scenario) {
      2 => _inventoryPanel(compact),
      3 => _linksPanel(compact),
      4 => _tablePanel(compact),
      _ => _scanPanel(compact),
    };
    return Positioned(
      left: 12,
      top: 8,
      bottom: compact ? 64 : 84,
      width: _panelWidth(size, compact),
      child: Center(
        child: SingleChildScrollView(
          child: _glass(
            padding: EdgeInsets.all(compact ? 8 : 12),
            child: panel,
          ),
        ),
      ),
    );
  }

  Text _line(
    String text,
    bool compact, {
    Key? key,
    Color? color,
    bool bold = true,
  }) => Text(
    text,
    key: key,
    style: TextStyle(
      fontSize: compact ? 11.5 : 13,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: color ?? Colors.white,
    ),
  );

  Widget _choiceChip(
    String key,
    String label,
    _rt_ChoiceState state,
    VoidCallback? onTap,
    bool compact,
  ) {
    final (bg, border) = switch (state) {
      _rt_ChoiceState.correct => (_rt_Tw.green600, _rt_Tw.green500),
      _rt_ChoiceState.wrong => (const Color(0xFF7F1D1D), _rt_Tw.red500),
      _rt_ChoiceState.selected => (const Color(0xFF164E63), _accentSoft),
      _rt_ChoiceState.idle => (const Color(0xFF1E293B), Colors.white24),
    };
    return GestureDetector(
      key: ValueKey(key),
      onTap: onTap,
      child: Container(
        height: compact ? 30 : 36,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: 1.5),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: TextStyle(
              fontSize: compact ? 11 : 12.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  /// S2: classify the picked target; the inventory fills up (the source's
  /// step 3 was never reached).
  Widget _inventoryPanel(bool compact) {
    final t = _target;
    final living = [
      for (final id in _identified)
        if (_biotic.contains(id)) id,
    ];
    final dead = [
      for (final id in _identified)
        if (!_biotic.contains(id)) id,
    ];
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('invTitle')),
        if (t == null)
          _line(_tx.s('pickTarget'), compact, key: const ValueKey('inv-prompt'))
        else ...[
          _line(
            _tx.s('lbl.$t'),
            compact,
            key: const ValueKey('inv-target'),
            color: _rt_Tw.amber400,
          ),
          const SizedBox(height: 2),
          _line(_tx.s('isIt'), compact, bold: false),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final (i, k) in const ['biotic', 'abiotic'].indexed) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _choiceChip(
                    'class-$k',
                    _tx.s(k),
                    _rt_ChoiceState.idle,
                    () => _classify(k),
                    compact,
                  ),
                ),
              ],
            ],
          ),
        ],
        SizedBox(height: compact ? 8 : 12),
        _line(_tx.s('bioticList'), compact, color: _rt_Tw.green400),
        _line(
          living.map((id) => _tx.s('lbl.$id')).join(', '),
          compact,
          key: const ValueKey('inv-biotic'),
          bold: false,
        ),
        const SizedBox(height: 6),
        _line(_tx.s('abioticList'), compact, color: _rt_Tw.slate300),
        _line(
          dead.map((id) => _tx.s('lbl.$id')).join(', '),
          compact,
          key: const ValueKey('inv-abiotic'),
          bold: false,
        ),
      ],
    );
  }

  /// One component badge: tap it (then another) or drag it onto another.
  Widget _nodeBadge(String id, bool compact) {
    final selected = _selectedChip == id;
    final w = compact ? 74.0 : 92.0;
    Widget body({bool lifted = false}) => Container(
      width: w,
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: compact ? 7 : 9),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF164E63) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: selected || lifted ? _rt_Tw.amber400 : _accentSoft,
          width: selected ? 2 : 1.2,
        ),
      ),
      child: Text(
        _tx.s('lbl.$id'),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: compact ? 10.5 : 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
    return Draggable<String>(
      data: id,
      maxSimultaneousDrags: _busy ? 0 : 1,
      onDragStarted: () => setState(() => _selectedChip = null),
      feedback: Material(color: Colors.transparent, child: body(lifted: true)),
      childWhenDragging: Opacity(opacity: 0.4, child: body()),
      child: DragTarget<String>(
        onWillAcceptWithDetails: (d) => !_busy && d.data != id,
        onAcceptWithDetails: (d) => _link(d.data, id),
        builder: (context, candidates, _) => GestureDetector(
          key: ValueKey('node-$id'),
          onTap: () => _tapNode(id),
          child: candidates.isEmpty
              ? body()
              : Transform.scale(scale: 1.06, child: body(lifted: true)),
        ),
      ),
    );
  }

  /// S3: the five components; links found are drawn between them.
  Widget _linksPanel(bool compact) {
    final h = compact ? 140.0 : 170.0;
    final bw = compact ? 74.0 : 92.0;
    final bh = compact ? 30.0 : 36.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('linkTitle')),
        _line(_tx.s('linkHint'), compact, bold: false),
        SizedBox(height: compact ? 6 : 10),
        SizedBox(
          height: h,
          child: LayoutBuilder(
            builder: (context, c) {
              final w = c.maxWidth;
              double x(double f) => (f * w).clamp(bw / 2, w - bw / 2);
              final centres = {
                'mountains': Offset(x(0.22), bh / 2 + 2),
                'sun': Offset(x(0.8), bh / 2 + 2),
                'river': Offset(x(0.5), h / 2),
                'trees': Offset(x(0.16), h - bh / 2 - 2),
                'plants': Offset(x(0.84), h - bh / 2 - 2),
              };
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _LinkPainter(
                        [
                          for (final key in _links)
                            (
                              centres[_flow3[key]!.$1]!,
                              centres[_flow3[key]!.$2]!,
                            ),
                        ],
                        _rt_Tw.green500,
                        Size(bw / 2, bh / 2),
                      ),
                    ),
                  ),
                  for (final MapEntry(key: id, value: o) in centres.entries)
                    Positioned(
                      left: o.dx - bw / 2,
                      top: o.dy - bh / 2,
                      child: _nodeBadge(id, compact),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  /// S4: Table 12.1, filled as items are observed.
  Widget _tablePanel(bool compact) {
    TextStyle head = TextStyle(
      fontSize: compact ? 10 : 11,
      fontWeight: FontWeight.w900,
      color: _accentSoft,
    );
    TextStyle cell = TextStyle(
      fontSize: compact ? 10.5 : 12,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    );
    Widget row(String habitat) {
      final list = _observed[habitat]!;
      String names(bool living) => list
          .where((id) => _biotic.contains(id) == living)
          .map((id) => _tx.s('lbl.$id'))
          .join(', ');
      final active = _habitat == habitat && _step >= 2;
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF164E63) : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? _accentSoft : Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _tx.s(habitat == 'tree' ? 'lbl.habTree' : 'lbl.habPond'),
              style: head,
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tx.s('colBiotic'),
                        style: head.copyWith(color: _rt_Tw.green400),
                      ),
                      Text(
                        names(true),
                        key: ValueKey('cell-$habitat-biotic'),
                        style: cell,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _tx.s('colAbiotic'),
                        style: head.copyWith(color: _rt_Tw.slate300),
                      ),
                      Text(
                        names(false),
                        key: ValueKey('cell-$habitat-abiotic'),
                        style: cell,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [_panelTitle(_tx.s('tableTitle')), row('tree'), row('pond')],
    );
  }

  /// S5: the scanner, the counts, the High/Low shares and the question.
  Widget _scanPanel(bool compact) {
    Widget counts(String scene) {
      final (l, m) = _counts[scene] ?? (0, 0);
      return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _line(_tx.s('lbl.$scene'), compact, color: _accentSoft),
            _line(
              '${_tx.s('living')}: $l   ${_tx.s('made')}: $m',
              compact,
              bold: false,
            ),
            _line(
              '${_tx.s('share')}: ${_share(scene)}%',
              compact,
              key: ValueKey('share-$scene'),
            ),
            if (_step == 3) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  for (final (i, v) in const ['high', 'low'].indexed) ...[
                    if (i > 0) const SizedBox(width: 6),
                    Expanded(
                      child: _choiceChip(
                        'share-$scene-$v',
                        _tx.s(v),
                        _shares[scene] != v
                            ? _rt_ChoiceState.idle
                            : (_sharesDone
                                  ? _rt_ChoiceState.correct
                                  : (_shareWrong.contains(scene)
                                        ? _rt_ChoiceState.wrong
                                        : _rt_ChoiceState.selected)),
                        _sharesDone ? null : () => _pickShare(scene, v),
                        compact,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _panelTitle(_tx.s('scanTitle')),
        if (!_scanned)
          _rt_ActionButton(
            key: const ValueKey('btn-scan'),
            label: _tx.s('scan'),
            icon: Icons.radar,
            color: _accent,
            expand: true,
            onPressed: _busy ? null : _scan,
          )
        else ...[
          counts('park'),
          counts('road'),
          if (_step == 3) ...[
            _line(_tx.s('shareQ'), compact, bold: false),
            const SizedBox(height: 6),
            _rt_ActionButton(
              key: const ValueKey('btn-check'),
              label: _tx.s('check'),
              icon: Icons.fact_check,
              color: _accent,
              expand: true,
              done: _sharesDone,
              onPressed: _sharesDone || _busy ? null : _checkShares,
            ),
          ],
          if (_step == 4) ...[
            _line(_tx.s('mcqQ'), compact),
            const SizedBox(height: 6),
            for (final o in const ['a', 'b', 'c'])
              _rt_ChoiceButton(
                key: ValueKey('opt-$o'),
                label: _tx.s('opt.$o'),
                state: _mcq != o
                    ? _rt_ChoiceState.idle
                    : (o == 'b'
                          ? _rt_ChoiceState.correct
                          : _rt_ChoiceState.wrong),
                onTap: _mcqDone ? null : () => _answer(o),
              ),
          ],
        ],
      ],
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
        // Many frogs at once get smaller hands, so the frogs stay visible.
        if (h != null) {
          children.add(
            _hand('grab-$id', h, Icons.pan_tool_alt, small: ids.length > 6),
          );
        }
      }
      for (final (key, world) in _tapSpots) {
        final p = frame.project(world);
        if (p != null) {
          children.add(
            _hand(key, p, Icons.touch_app, small: _tapSpots.length > 6),
          );
        }
      }
    }
    return Stack(clipBehavior: Clip.none, children: children);
  }

  Widget _hand(String key, Offset at, IconData icon, {bool small = false}) {
    final d = small ? 20.0 : 30.0;
    final pulse = 1 + 0.12 * math.sin(_clock * 5);
    return Positioned(
      left: at.dx - d / 2,
      top: at.dy - d / 2,
      width: d,
      height: d,
      child: Transform.scale(
        key: ValueKey(key),
        scale: pulse,
        child: Container(
          decoration: BoxDecoration(
            color: _accent.withValues(alpha: 0.85),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Icon(icon, size: small ? 11 : 16, color: Colors.white),
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

/// Arrows between linked population badges (from food to feeder).
class _LinkPainter extends CustomPainter {
  _LinkPainter(this.links, this.color, this.halfSize);

  final List<(Offset, Offset)> links;
  final Color color;

  /// Half the badge size: the arrows end at the badges' edges.
  final Size halfSize;

  double _trim(Offset u) =>
      math.min(
        u.dx.abs() < 1e-3 ? 1e9 : halfSize.width / u.dx.abs(),
        u.dy.abs() < 1e-3 ? 1e9 : halfSize.height / u.dy.abs(),
      ) +
      4;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (final (a, b) in links) {
      final d = b - a;
      final len = d.distance;
      final u = d / len;
      final cut = _trim(u);
      if (len < 2 * cut + 12) continue;
      final from = a + u * cut, to = b - u * cut;
      canvas.drawLine(from, to, paint);
      final n = Offset(-u.dy, u.dx);
      final head = Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo((to - u * 11 + n * 6).dx, (to - u * 11 + n * 6).dy)
        ..lineTo((to - u * 11 - n * 6).dx, (to - u * 11 - n * 6).dy)
        ..close();
      canvas.drawPath(head, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(_LinkPainter old) =>
      old.links.length != links.length || old.color != color;
}
